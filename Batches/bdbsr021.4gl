#*****************************************************************************#
# Modulo .........: bdbsr021.4gl                                               #
# Analista .......: Kennedy Oliveira                                          #
# Desenvolvimento.: Kleiton Nascimento - 07/2013                              #
# Objetivo........: Relátorio de acompanhamento dos testes de conexão         #
#                                                                             #
#-----------------------------------------------------------------------------# 
# 29/07/2013 Kleiton Nascimento                                               #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

define m_log   char(300)
define m_path_log        char(200)
define m_path_relatorio  char(200)
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

call fun_dba_abre_banco("CT24HS")

let m_path_log = f_path("DBS","LOG")
let m_path_log = m_path_log clipped,"/bdbsr021.log"

let m_path_relatorio = f_path("DBS","RELATO")
let m_path_relatorio =  m_path_relatorio clipped,"/bdbsr021.csv"

call startlog(m_path_log)

let l_inicio = current year to second
let m_log =  "Inicio do Programa - ", l_inicio
call errorlog(m_log)

set isolation to dirty read
#Preparar consulta
call bdbsr021_prepare()

#Iniciar processamento
call bdbsr021()

#Compactar arquivo
let l_comando = "gzip -f ", m_path_relatorio
run l_comando
let m_path_relatorio = m_path_relatorio clipped, ".gz"

#Envio de email
let l_modulo = "BDBSR021"
let l_assunto = "Relatorio Status Conexao"

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

call bdbsr021_limpa_registros()

let l_fim  = current year to second
let m_log = "Fim do Programa - ", l_fim
call errorlog(m_log)

let l_tempo = l_fim - l_inicio
let m_log = "Tempo Total - ",l_tempo
call errorlog(m_log)

end main

#------------------------------------------------------------------------------#
function bdbsr021_prepare()
#------------------------------------------------------------------------------#
define l_sql     char(800)
define l_sqlcode integer

let l_sql =  " select datklcdcnxsit.lcdcnxtsthrrdat  "
            ,"       ,datklcdcnxsit.cnxsitflg "
            ,"       ,datklocadora.lcvnom "
            ," from   datklcdcnxsit,datklocadora "
            ," where  datklocadora.lcvcod = datklcdcnxsit.lcvcod " 
            ,"   and  lcdcnxtsthrrdat between ? and ?"
prepare pbdbsr02101 from l_sql
declare cbdbsr02101 cursor with hold for pbdbsr02101 

let l_sql = "select rowid from datklcdcnxsit ",
            "where lcdcnxtsthrrdat < ? "
prepare pbdbsa02102 from l_sql
declare cbdbsa02102 cursor with hold for pbdbsa02102

let l_sql = "delete from datklcdcnxsit ",
            "where rowid  = ? "
prepare pbdbsa02103 from l_sql           

end function

#------------------------------------------------------------------------------#
function bdbsr021()
#------------------------------------------------------------------------------#
define lr_conexao record
       lcdcnxtsthrrdat     like datklcdcnxsit.lcdcnxtsthrrdat
      ,cnxsitflg           like datklcdcnxsit.cnxsitflg
      ,lcvnom              like datklocadora.lcvnom
end record

define l_inicio          date
      ,l_final           date
      ,l_data            char(10)
      ,l_hora            char(8)
      ,l_situacao        char(20)
      ,l_datahora        char(20)

initialize 
       l_inicio   
      ,l_final    
      ,l_data     
      ,l_hora     
      ,l_situacao 
      ,l_datahora 
      ,lr_conexao.*
to null

let l_inicio = current - 8 units day
let l_final = current - 1 units day

#Start Relatorio
start report bdbsr021_relatorio to m_path_relatorio

#Consulta conexões
open cbdbsr02101 using l_inicio,
                       l_final
                       
foreach cbdbsr02101 into lr_conexao.lcdcnxtsthrrdat,
                         lr_conexao.cnxsitflg,
                         lr_conexao.lcvnom
                         
     #Separa data e hora do registro em questão
     let l_datahora = lr_conexao.lcdcnxtsthrrdat
     let l_data = l_datahora[1,10]
     let l_hora = l_datahora[12,19]
 
     
     #Define descrição da situação conexão
     case lr_conexao.cnxsitflg 
          when 0
               let l_situacao = "Conexao Indisponivel"
          
          when 1
               let l_situacao = "Conexao Disponivel"
     end case
     
     #Imprime relatorio
     output to report bdbsr021_relatorio(l_data,
                                         l_hora,
                                         lr_conexao.lcvnom,
                                         l_situacao) 
     
end foreach     

#Finaliza relatorio
finish report bdbsr021_relatorio             

end function

#------------------------------------------------------------------------------#
report bdbsr021_relatorio(lr_param)
#------------------------------------------------------------------------------#

define lr_param record
     data      char(10),
     hora      char(8),
     lcvnom    like datklocadora.lcvnom,
     situacao  char(20)
end record

output
   report to pipe "bdbsr021.csv"
   page   length  01
   left   margin  00
   right  margin  80
   bottom margin  00
   top    margin  00
   
   format

   on every row

      if pageno = 1 then
         print column 001,"Data;Hora;Locadora;Status da Integracao"
      end if  
      
      print column 001,lr_param.data,";"   
                      ,lr_param.hora,";"
                      ,lr_param.lcvnom,";"
                      ,lr_param.situacao
      
end report


#------------------------------------------------------------------------------#
function bdbsr021_limpa_registros()
#------------------------------------------------------------------------------#

define l_rowid           integer
define l_data            date


define l_lidos           integer
define l_lidosTotal      integer
define l_deletados       integer

let l_data = current - 15 units day


let l_deletados  = 0
let l_lidos      = 0
let l_lidosTotal = 0

begin work

open    cbdbsa02102 using l_data
foreach cbdbsa02102 into  l_rowid

     whenever error continue
     execute pbdbsa02103 using l_rowid
     whenever error stop
     
     if sqlca.sqlcode <> 0 then
          let m_log = "Erro ao deletar teste conexao. Erro SQL: ",sqlca.sqlcode
          call errorlog(m_log)
          
          rollback work
          exit program
     else
          let l_deletados = l_deletados +1
     end if
     
     let l_lidos = l_lidos +1
     let l_lidosTotal = l_lidosTotal +1
     
     if l_lidosTotal mod 1000 = 0 then
          let m_log = "Registros lidos: ",l_lidos
          call errorlog(m_log)
          
          let m_log = "Registros deletados: ",l_deletados
          call errorlog(m_log)
     end if 
          
     if l_lidos >= 300 then
          commit work
          begin work
          let l_lidos = 0
     end if
     
end foreach       

commit work 

let m_log = "Registros lidos: ",l_lidosTotal
call errorlog(m_log)    

let m_log = "Registros deletados: ",l_deletados
call errorlog(m_log)

end function
