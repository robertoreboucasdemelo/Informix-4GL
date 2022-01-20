#*****************************************************************************#
# Modulo .........: bdbsr023.4gl                                              #
# Analista .......: Fabio Lamartine                                           #
# Desenvolvimento.: Vinicius Morais - 10/2013                                 #
# Objetivo........: Relátorio de Atualizacao de Vinculo                       #
#                                                                             #
#-----------------------------------------------------------------------------# 

database porto

define m_log   char(300)
define m_path_log        char(200)
define m_path_relatorio  char(200)
define m_prcstt          integer
#------------------------------------------------------------------------------#
main
#------------------------------------------------------------------------------#
define l_inicio          datetime year to second
define l_fim             datetime year to second
define l_tempo           interval hour to second
define l_modulo          like igbmparam.relsgl
define l_assunto         char(300)
define l_sitEnvio        smallint
define l_comando         char(300)
define l_datpesq         date
define l_resultado       integer

call fun_dba_abre_banco("CT24HS")

let m_path_log = f_path("DBS","LOG")
let m_path_log = m_path_log clipped,"/bdbsr023.log"

let m_path_relatorio = f_path("DBS","RELATO")
let m_path_relatorio =  m_path_relatorio clipped,"/bdbsr023.csv"

call startlog(m_path_log)

let l_inicio = current year to second
let m_log =  "Inicio do Programa - ", l_inicio
call errorlog(m_log)
display m_log

set isolation to dirty read
#Preparar consulta
call bdbsr023_prepare()

#Iniciar processamento
call bdbsr023()
returning l_resultado


if l_resultado = 0 then 
   #Compactar arquivo
   let l_comando = "gzip -f ", m_path_relatorio
   run l_comando
   let m_path_relatorio = m_path_relatorio clipped, ".gz"
   
   #Envio de email
   let l_modulo = "BDBSR023"
   let l_assunto = "Relatorio Atualizacao Vinculo"
   
   call ctx22g00_envia_email(l_modulo,
                             l_assunto,
                             m_path_relatorio)
        returning l_sitEnvio
   
   #Confirma envio de email     
   if l_sitEnvio = 0 then
        let m_log =  "Email enviado com sucesso"
        call errorlog(m_log)
   else
        if l_sitEnvio = 99 then
             let m_log =  "Não existem destinatários cadastrados"
             call errorlog(m_log)     
        else
             let m_log =  "Erro ao enviar email(ctx22g00) - ", m_path_relatorio, 
                          " – Codigo do erro: ",l_sitEnvio
             call errorlog(m_log)      
        end if
   end if
end if


let l_fim  = current year to second           
let m_log = "Fim do Programa - ", l_fim       
call errorlog(m_log)                          
display m_log                                 
                                              
let l_tempo = l_fim - l_inicio                
let m_log = "Tempo Total - ",l_tempo          
call errorlog(m_log)                          
display m_log 

end main

#------------------------------------------------------------------------------#
function bdbsr023_prepare()
#------------------------------------------------------------------------------#
define l_sql     char(1300)
define l_sqlcode integer

let l_sql ="select "
          ,"atual.prscod || ' - ' ||  prestador.nomrazsoc as codigoEPrestador, "
          ,"atual.webusrtipcod || atual.webusrcod as usuarioWeb, "
          ,"atual.srrcoddig as QRASocorrista, "
          ,"socorrista.srrnom as nomeSocorrista, "
          ,"decode(atual.atoprsflg, 'S', 'Ativo', 'N', 'Inativo') as situacao, "
          ,"vinculo.cpodes as tipoVinculo, "
          ,"TO_CHAR(atual.atldat, '%d/%m/%y') as dataAlteracao, " 
          ,"atual.atlusrtip, "
          ,"atual.atlmat, "
          ," 'Superintendente: ' || cadeiaGestao.sprnom || " 
          ,"',Gerente: ' || cadeiaGestao.gernom || "
          ,"',Coordenador: ' || cadeiaGestao.cdnnom || "
          ,"',Analista: ' || cadeiaGestao.anlnom as cadeiaGestao "
          ,"from datmprscdlatl as atual "
               ,"left outer join datksrr as socorrista on (atual.srrcoddig = socorrista.srrcoddig), "
               ,"dpaksocor as prestador, "
               ,"iddkdominio as vinculo, "
               ,"isskwebusr usrweb, "
               ,"dpakprsgstcdi as cadeiaGestao "
         ,"where TO_CHAR(atual.atldat, '%d/%m/%y') = TO_CHAR(today - 1, '%d/%m/%y') "
           ,"and (atual.atoprsflg = 'N' or atual.prsatlflg = 'S') "
           ,"and atual.prscod = prestador.pstcoddig "
           ,"and vinculo.cponom  =  'pstvintip' "
           ,"and atual.prsvintipcod = vinculo.cpocod "
           ,"and atual.atlusrtip = usrweb.usrtip "
           ,"and atual.atlmat = usrweb.webusrcod "
           ,"and prestador.gstcdicod = cadeiaGestao.gstcdicod "
         ,"order by atual.prscod, atual.srrcoddig asc"
prepare pbdbsr02301 from l_sql
declare cbdbsr02301 cursor with hold for pbdbsr02301       


let l_sql = "select b.srrnom "
           ," from issrusrprs a, datksrr b"
           ," where  b.srrcoddig = a.webprsmatcod"
           ," and a.usrtip = ?"
           ," and a.webusrcod = ?"

prepare pbdbsr02302 from l_sql
declare cbdbsr02302 cursor with hold for pbdbsr02302 


let l_sql = " select 1"          
           ," from datkprsatlcph "
           ,"  where prsatlcphinidat <= ? "
           ,"  and  prsatlcphfimdat >= ? "

prepare pbdbsr02303 from l_sql
declare cbdbsr02303 cursor with hold for pbdbsr02303 

end function

#------------------------------------------------------------------------------#
function bdbsr023()
#------------------------------------------------------------------------------#
   define lr_vinculo record
          pstcodnom           char(48)
         ,webusr              char(11)
         ,srrcoddig           like datmprscdlatl.srrcoddig
         ,srrnom              like datksrr.srrnom
         ,situacao            char(7)
         ,vcltip              like iddkdominio.cpodes
         ,atldat              char(8)
         ,atlusrtip           char(1)      
         ,atlmat              char(10)       
         ,funnom              char(20)
         ,gstcda              char(110)       
   end record
   
   define l_inicio          date
         ,l_final           date
         ,l_data            char(10)
         ,l_hora            char(8)
         ,l_situacao        char(20)
         ,l_datahora        char(20)
         ,l_nom             char(20)
         ,l_cont            integer
         ,l_datpesq         date
         ,l_resultado       integer
   
   initialize lr_vinculo.* to null


   #Verifica se existe campanha ativa para o dia anterior     
   let l_datpesq = today - 1 units day                        
                                                              
   whenever error continue                                    
   open cbdbsr02303 using l_datpesq, l_datpesq                
                                                              
   fetch cbdbsr02303 into l_cont                               
                                                              
   if sqlca.sqlcode = 0 then  
   
      #Start Relatorio
      start report bdbsr023_relatorio to m_path_relatorio
      
      let l_cont = 0 
      
      #Consulta atualizacao de vinculos
      foreach cbdbsr02301 into lr_vinculo.pstcodnom
                              ,lr_vinculo.webusr
                              ,lr_vinculo.srrcoddig 
                              ,lr_vinculo.srrnom 
                              ,lr_vinculo.situacao
                              ,lr_vinculo.vcltip
                              ,lr_vinculo.atldat
                              ,lr_vinculo.atlusrtip
                              ,lr_vinculo.atlmat
                              ,lr_vinculo.gstcda
                               
           let lr_vinculo.funnom =  lr_vinculo.atlusrtip clipped , lr_vinculo.atlmat clipped
                               
           #verifica responsavel por cadastro
           whenever error continue
           open cbdbsr02302 using lr_vinculo.atlusrtip, lr_vinculo.atlmat 
           
           fetch cbdbsr02302 into l_nom 
              
           
           if sqlca.sqlcode = 0 then 
              let lr_vinculo.funnom =  lr_vinculo.funnom clipped, " - ", l_nom clipped        
           end if    
           
           whenever error stop
           
           close cbdbsr02302  
                         
           #Imprime relatorio
           output to report bdbsr023_relatorio(lr_vinculo.pstcodnom
                                              ,lr_vinculo.webusr
                                              ,lr_vinculo.srrcoddig
                                              ,lr_vinculo.srrnom
                                              ,lr_vinculo.situacao
                                              ,lr_vinculo.vcltip
                                              ,lr_vinculo.atldat
                                              ,lr_vinculo.funnom
                                              ,lr_vinculo.gstcda)
          
          let l_cont = l_cont + 1                                 
           
           
      end foreach
      #Finaliza relatorio
      finish report bdbsr023_relatorio 
      
      display "Quantidade registros processados: ", l_cont 
      let l_resultado = 0              
   else 
      let m_log =  "Não existem campanhas no momento para o dia ", l_datpesq
      call errorlog(m_log)
      display m_log
      let l_resultado = 1 
   end if
   whenever error stop
   close cbdbsr02303
   
   return l_resultado

end function

#------------------------------------------------------------------------------#
report bdbsr023_relatorio(lr_vinculo)
#------------------------------------------------------------------------------#

define lr_vinculo record
       pstcodnom           char(48)
      ,webusr              char(11)
      ,srrcoddig           like datmprscdlatl.srrcoddig
      ,srrnom              like datksrr.srrnom
      ,situacao            char(7)
      ,vcltip              like iddkdominio.cpodes
      ,atldat              char(8)     
      ,funnom              like isskfunc.funnom
      ,gstcda              char(110)       
end record

output
   report to pipe "bdbsr023.csv"
   page   length  01
   left   margin  00
   right  margin  80
   bottom margin  00
   top    margin  00
   
   format

   on every row

      if pageno = 1 then
         print column 001,"Codigo e Nome do Prestador;Codigo do Usuario Web " 
                         ,"do Prestador;Codigo do Socorrista;Nome do "
                         ,"Socorrista;Situacao;Tipo de Vinculo; Data de "
                         ,"Alteracao do Vinculo;Funcionario que Realizou  a "
                         ,"Alteracao;Cadeia de Gestao"
      end if  
      
      print column 001, lr_vinculo.pstcodnom,";"
                      , lr_vinculo.webusr,";"
                      , lr_vinculo.srrcoddig,";"
                      , lr_vinculo.srrnom,";"
                      , lr_vinculo.situacao,";"
                      , lr_vinculo.vcltip,";"
                      , lr_vinculo.atldat,";"
                      , lr_vinculo.funnom,";"
                      , lr_vinculo.gstcda
                    
                    
      
end report
