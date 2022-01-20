#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA SEGUROS GERAIS                       #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSA700                                                   #
# ANALISTA RESP..: VINICIUS MORAIS                                            #
# PSI/OSF........: PSI-2011-06258-PR - CRM BASE UNICA - ENVIA AS ALTERAÇÕES NO#
#                  CADASTRO DE SOCORRISTAS VIA MQ PARA CRM                    #
# ........................................................................... #
# DESENVOLVIMENTO: VINICIUS MORAIS                                            #
# LIBERACAO......:                                                            #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#
database porto

main

   define mr_crm record
      srrcoddig like datksrr.srrcoddig,
      pstcoddig like dpaksocor.pstcoddig,
      retorno   smallint,
      menserro  char(30)  
   end record
   
   define l_dataIni    char(10),
          l_dataFim    char(10),          
          l_dataInicio date,
          l_dataFinal  date,
          l_data       date,
          l_hora       datetime hour to fraction
   
   define ws record
      lidos smallint,
      enviados smallint,
      erro smallint
   end record
   
   initialize mr_crm.*, ws.* to null
   initialize l_dataIni to null
   initialize l_dataFim to null
   
   let ws.lidos    = 0
   let ws.enviados = 0
   let ws.erro     = 0
   
   call fun_dba_abre_banco("CT24HS")
   
   let l_data = today
   let l_hora = current
   display "INCIO DO SINCRONISMO: ",l_data, "  ", l_hora
   display "====================================================================="
   
   let l_dataInicio = ARG_VAL(1)
   let l_dataFinal = ARG_VAL(2)
      
   if l_dataInicio is null or l_dataInicio = " " then      
      let l_dataInicio = "01/01/1900"
   end if   
   
   if l_dataFinal is null or  l_dataFinal = " " then
      let l_dataFinal = today    
   end if   
   
   let l_dataIni = l_dataInicio using "dd/MM/yyyy" 
   let l_dataFim =  l_dataFinal using "dd/MM/yyyy"
   
   call bdbsa700_EnviaSocorrista(l_dataIni, l_dataFim, ws.lidos, ws.enviados, ws.erro)
     RETURNING ws.*
     
   display "====================================================================="
   display "Quantidade de registros lidos   : ", ws.lidos
   display "Quantidade de registros enviados: ", ws.enviados
   display "Quantidade de registros com erro: ", ws.erro      
     
   call bdbsa700_EnviaPrestador(l_dataIni, l_dataFim, ws.lidos, ws.enviados, ws.erro)
     RETURNING ws.*   
   
   display "====================================================================="
   display "Quantidade de registros lidos   : ", ws.lidos
   display "Quantidade de registros enviados: ", ws.enviados
   display "Quantidade de registros com erro: ", ws.erro     

end main


function bdbsa700_EnviaSocorrista(param, ws)
   
   define param record
       dataIni char(10),
       dataFim char(10)
   end record
   
   define mr_crm record
      srrcoddig like datksrr.srrcoddig,
      retorno   smallint,
      menserro  char(30)  
   end record
   
   define ws record
      lidos smallint,
      enviados smallint,
      erro smallint
   end record
   
   define l_patharq    char(100),
          l_pathtxt    char(100),
          l_data       date,
          l_hora       datetime hour to fraction
            
  let ws.lidos    = 0
  let ws.enviados = 0
  let ws.erro     = 0
         
  #DEFINE ARQUIVO PARA RELATORIO DE INCONSISTENTES
  let l_patharq = f_path("DBS", "ARQUIVO")
  let l_pathtxt = l_patharq clipped,"/CRM_Error_Socorrista.xls"
   
  display 'Arquivo:', l_pathtxt clipped
      
  start report bdbsa700_CRM_error to l_pathtxt 
   
   display "SINCRONIZANDO SOCORRISTA"
   whenever error continue
     declare cbdbsa21000001 cursor with hold for
     SELECT srrcoddig from datksrr 
     WHERE atldat >= param.dataIni and atldat <= param.dataFim
          
     foreach cbdbsa21000001 into mr_crm.srrcoddig         
         let ws.lidos = ws.lidos + 1         
         
         call cty29g00_EnviaCrm_Srr(mr_crm.srrcoddig)
             returning mr_crm.retorno,mr_crm.menserro
         
         if mr_crm.retorno = 0 then
            let ws.enviados = ws.enviados + 1
            let l_data = today
            let l_hora = current
            display "[",l_data, " ", l_hora,"] ", mr_crm.srrcoddig, " SINCRONIZADO."
         else
            let ws.erro = ws.erro + 1
            
            output to report bdbsa700_CRM_error("SOCORRISTA", mr_crm.srrcoddig, mr_crm.retorno, mr_crm.menserro)
         end if
                  
     end foreach
   whenever error stop

   finish report bdbsa700_CRM_error
  
   call bdbsa700_enviaEmail(l_pathtxt)

   return ws.lidos, ws.enviados, ws.erro

end function

function bdbsa700_EnviaPrestador(param, ws)
  
  define param record
      dataIni char(10),
      dataFim char(10)
  end record
  
  define ws record
     lidos smallint,
     enviados smallint,
     erro smallint
  end record
  
  define mr_crm record
      pstcoddig like dpaksocor.pstcoddig,
      retorno   smallint,
      menserro  char(30)  
   end record
  
  define l_patharq    char(100),
         l_pathtxt    char(100),
         l_data       date,
         l_hora       datetime hour to fraction
  
  let ws.lidos    = 0
  let ws.enviados = 0
  let ws.erro     = 0
         
  #DEFINE ARQUIVO PARA RELATORIO DE INCONSISTENTES
  let l_patharq = f_path("DBS", "ARQUIVO")
  let l_pathtxt = l_patharq clipped,"/CRM_Error_Prestador.xls"
   
  display 'Arquivo:', l_pathtxt clipped
      
  start report bdbsa700_CRM_error to l_pathtxt         

  display "SINCRONIZANDO PRESTADORES."
  whenever error continue
    declare cbdbsa21000002 cursor with hold for
    select pstcoddig from dpaksocor
    where atldat >= param.dataIni and atldat <= param.dataFim    
        
    foreach cbdbsa21000002 into mr_crm.pstcoddig
        
        let ws.lidos = ws.lidos + 1
  
        call cty29g00_EnviaCrm_Prt(mr_crm.pstcoddig)
            returning mr_crm.retorno,mr_crm.menserro
        
        if mr_crm.retorno = 0 then
           let ws.enviados = ws.enviados + 1
           let l_data = today
           let l_hora = current
           display "[",l_data, " ", l_hora,"] ",  mr_crm.pstcoddig, " SINCRONIZADO"
        else
           let ws.erro = ws.erro + 1           
           
           output to report bdbsa700_CRM_error("PRESTADOR", mr_crm.pstcoddig, mr_crm.retorno, mr_crm.menserro)
           
        end if
                 
    end foreach
  whenever error stop
  
  finish report bdbsa700_CRM_error
  
  call bdbsa700_enviaEmail(l_pathtxt)
  
  return ws.lidos, ws.enviados, ws.erro
  
end function

report bdbsa700_CRM_error(l_param)
    
 define l_param record
   tipo     char(15),
   cod      decimal(8,0),
   errocod  smallint,
   msgerror char(300)
 end record
 
 output
    page length    102
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format     
     
     page header
     
        print "TIPO",ascii(9);
        print "CODIGO",ascii(9);
        print "COD ERRO",ascii(9);
        print "ERRO";
        skip 1 lines;
              
     on every row
        print l_param.tipo,ascii(9);
        print l_param.cod,ascii(9);
        print l_param.errocod,ascii(9);
        print l_param.msgerror 
        
        
end report

function bdbsa700_enviaEmail(l_pathtxt)
 
 define l_comando  char(200),
        l_pathtxt  char(100),
        l_retorno  smallint

 #############################################################
 # Envia e-mail com os pagamentos
 #############################################################
 whenever error continue
 
 let l_comando = "gzip -f ", l_pathtxt
 run l_comando
 let l_pathtxt = l_pathtxt clipped, ".gz" 
 
 let l_retorno = ctx22g00_envia_email("BDBSA700", "CRM - ENVIO DADOS BCP", l_pathtxt)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display "Erro de envio de email(cx22g00)- ",l_pathtxt
    else
       display "Nao ha email cadastrado para o modulo BDBSA700 "
    end if
 end if

 whenever error stop

end function