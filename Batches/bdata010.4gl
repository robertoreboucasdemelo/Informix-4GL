#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Regras Siebel                                              #
# Modulo.........: bdata010                                                   #
# Objetivo.......: Batch de Geracao de Limpeza do Movimento                   #
# Analista Resp. : Humberto Benedito                                          #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 21/11/2015                                                 #
#-----------------------------------------------------------------------------#


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
   define g_ismqconn smallint
end globals


define m_path_log        char(100)
define m_bdata010_prep   smallint
define m_mensagem        char(150)
define m_commit          integer
define m_quebra          integer
define m_deletou          smallint
define m_msg_mail        char(10000)

define mr_count1 record
   relat    integer,
   apoli    integer,
   lido     integer,
   inco     integer,
   proc     integer,
   dele     integer
end record

define mr_total record
   relat    integer,
   apoli    integer,
   lido     integer,
   inco     integer,
   proc     integer,
   dele     integer     
end record

define mr_param record
    ini date                            ,
    fim date                            ,
    hour_ini datetime hour to second    ,
    hour_fim datetime hour to second
end record

define mr_processo2 record 
	bnfcrgseqnum  integer ,
	icoseqnum     integer      
end record


define mr_data record
  dias   integer,
  fim    date
end record




#========================================================================
main
#========================================================================

   # Funcao responsavel por preparar o programa para a execucao
   # - Prepara as instrucoes SQL
   # - Obtem os caminhos de processamento
   # - Cria o arquivo de log
   #

   initialize mr_count1.*, mr_param.* to null

   call bdata010_cria_log()

   call bdata010_exibe_inicio()

   call fun_dba_abre_banco("CT24HS")

   set lock mode to wait 10
   set isolation to dirty read

   let m_bdata010_prep = false
   
   let mr_total.relat      = 0
   let mr_total.apoli      = 0
   let mr_total.lido       = 0
   let mr_total.inco       = 0
   let mr_total.proc       = 0
   let mr_total.dele       = 0
   let m_deletou            = false
   let m_commit            = 0
   let m_msg_mail          = ""

   display "##################################"
   display " PREPARANDO... "
   display "##################################"
   call bdata010_prepare()


   display "##################################"
   display " RECUPERANDO QUEBRA... "
   display "##################################"
   if not bdata010_recupera_quebra() then
      exit program
   end if  


   ###############################
   # CARGA                       #
   ###############################
  
   if bdata010_valida_carga() then
   
      if not bdata010_carga_full() then
         let m_mensagem = "Carga Abortada. Verificar os Dominios."
         call ERRORLOG(m_mensagem);
         display m_mensagem
      end if
       
   
   end if
     
  
   call bdata010_exibe_final()

   call bdata010_dispara_email()

#========================================================================
end main
#========================================================================

#===============================================================================
function bdata010_prepare()
#===============================================================================

define l_sql char(10000)

   
   let l_sql =  ' select bnfcrgseqnum         '
               ,' from datmbnfcrgmov          '           
               ,' where pcmdat <= ?           '    
               ,' and pcmflg in ("N","E")     '                    
   prepare p_bdata010_001 from l_sql
   declare c_bdata010_001 cursor with hold for p_bdata010_001


   let l_sql = ' select cpodes        '
              ,' from datkdominio     '
              ,' where cponom =  ?    '
              ,' and   cpocod =  ?    '
   prepare p_bdata010_002 from l_sql
   declare c_bdata010_002 cursor for p_bdata010_002
   
 
   let l_sql = ' select cpodes        '
              ,' from datkdominio     '
              ,' where cponom =  ?    '
   prepare p_bdata010_003 from l_sql
   declare c_bdata010_003 cursor for p_bdata010_003
   
   
   let l_sql = ' delete datmbnfcrgmov    '
             ,'  where bnfcrgseqnum = ?  '           
   prepare p_bdata010_004 from l_sql   
   
  
   let l_sql =  ' select icoseqnum               '
               ,' from datmbnfcrgico             '           
               ,' where icodat <= ?              '  
               ,' and dcttipcod not in (999,888) '                   
   prepare p_bdata010_005 from l_sql
   declare c_bdata010_005 cursor with hold for p_bdata010_005
   	
   let l_sql = ' delete datmbnfcrgico '
             ,'  where icoseqnum = ?  '           
   prepare p_bdata010_006 from l_sql   
   
   
   let l_sql =  ' select icoseqnum           '
               ,' from datmbnfcrgico         '           
               ,' where icodat <= ?          '  
               ,' and dcttipcod in (999,888) '                   
   prepare p_bdata010_007 from l_sql
   declare c_bdata010_007 cursor with hold for p_bdata010_007   
   	
   let m_bdata010_prep = true

#========================================================================
end function
#========================================================================


#========================================================================
function bdata010_cria_log()
#========================================================================

   define l_path char(200)

   let l_path = null
   let l_path = f_path("DAT","LOG")

   if l_path is null or
      l_path = " " then
      let l_path = "."
   end if

   let l_path = m_path_log clipped, "bdata010.log"

   call startlog(l_path)

#========================================================================
end function
#========================================================================




#========================================================================
function bdata010_remove_beneficio()
#========================================================================

define lr_retorno record
   cont           integer                   ,
   grava          smallint                  ,
   resultado      smallint                  ,
   mensagem       char(50)
end record

define l_data date
define l_hora datetime hour to second

initialize mr_processo2.* to null
initialize lr_retorno.* to null

let l_data = current
let l_hora = null

let lr_retorno.cont             = 0
let lr_retorno.grava            = false
let mr_count1.relat             = 0
let mr_count1.apoli             = 0



     
     let l_data = l_data - mr_data.dias
     
     begin work;

   
    #--------------------------------------------------------
    # Recupera os Dados da Apolice
    #--------------------------------------------------------
    open c_bdata010_001 using l_data
  
    foreach c_bdata010_001 into mr_processo2.bnfcrgseqnum
                  
                                
             let mr_count1.apoli = mr_count1.apoli + 1
             let mr_total.apoli  = mr_total.apoli + 1
      
          
             call bdata010_deleta_beneficio()
             returning m_deletou
               
             if m_deletou then
                let mr_count1.relat = mr_count1.relat + 1
                let mr_total.relat  = mr_total.relat + 1
                let lr_retorno.grava = true
             end if
             
             if m_commit > m_quebra then
                commit work;
                
                call bdata010_exibe_dados_parciais()
                
                if not bdata010_valida_dia_hora() then
                   exit foreach
                end if
                
                begin work;
                let m_commit = 1
             else
                 let m_commit = m_commit + 1
             end if



    end foreach

    call bdata010_exibe_dados_parciais()

    commit work;

#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_remove_inconsistencia()
#========================================================================

define lr_retorno record
   cont           integer                   ,
   grava          smallint                  ,
   resultado      smallint                  ,
   mensagem       char(50)
end record

define l_data date
define l_hora datetime hour to second

initialize mr_processo2.* to null
initialize lr_retorno.* to null

let l_data = current
let l_hora = null

let lr_retorno.cont            = 0
let lr_retorno.grava           = false
let mr_count1.lido             = 0
let mr_count1.inco             = 0
   
     let l_data = l_data - mr_data.dias
     
     begin work;

   
    #--------------------------------------------------------
    # Recupera os Dados da Inconsistencia
    #--------------------------------------------------------
    open c_bdata010_005 using l_data
  
    foreach c_bdata010_005 into mr_processo2.icoseqnum
                  
                                
             let mr_count1.lido = mr_count1.lido + 1
             let mr_total.lido  = mr_total.lido + 1
      
          
             call bdata010_deleta_incosistencia()
             returning m_deletou
               
             if m_deletou then
                let mr_count1.inco = mr_count1.inco + 1
                let mr_total.inco  = mr_total.inco + 1
                let lr_retorno.grava = true
             end if
             
             if m_commit > m_quebra then
                commit work;
                
                call bdata010_exibe_dados_parciais()
                
                if not bdata010_valida_dia_hora() then
                   exit foreach
                end if
                
                begin work;
                let m_commit = 1
             else
                 let m_commit = m_commit + 1
             end if



    end foreach

    call bdata010_exibe_dados_parciais()

    commit work;

#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_remove_processamento()
#========================================================================

define lr_retorno record
   cont           integer                   ,
   grava          smallint                  ,
   resultado      smallint                  ,
   mensagem       char(50)
end record

define l_data date
define l_hora datetime hour to second

initialize mr_processo2.* to null
initialize lr_retorno.* to null

let l_data = current
let l_hora = null

let lr_retorno.cont            = 0
let lr_retorno.grava           = false
let mr_count1.proc             = 0
let mr_count1.dele             = 0
   
     let l_data = l_data - 365
     
     begin work;

   
    #--------------------------------------------------------
    # Recupera os Dados do Processamento
    #--------------------------------------------------------
    open c_bdata010_007 using l_data
  
    foreach c_bdata010_007 into mr_processo2.icoseqnum
                  
                                
             let mr_count1.proc = mr_count1.proc + 1
             let mr_total.proc  = mr_total.proc + 1
      
          
             call bdata010_deleta_incosistencia()
             returning m_deletou
               
             if m_deletou then
                let mr_count1.dele = mr_count1.dele + 1
                let mr_total.dele  = mr_total.dele + 1
                let lr_retorno.grava = true
             end if
             
             if m_commit > m_quebra then
                commit work;
                
                call bdata010_exibe_dados_parciais()
                
                if not bdata010_valida_dia_hora() then
                   exit foreach
                end if
                
                begin work;
                let m_commit = 1
             else
                 let m_commit = m_commit + 1
             end if



    end foreach

    call bdata010_exibe_dados_parciais()

    commit work;

#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_exibe_inicio()
#========================================================================
define l_data  date,
       l_hora  datetime hour to second

let l_data            = today
let l_hora            = current
let mr_param.ini      = today
let mr_param.hour_ini = current

   display " "
   display "-------------------------------------------------------------------------"
   display " INICIO bdata010 - LIMPEZA DO MOVIMENTO DA BASE DE BENEFICIOS"
   display "-------------------------------------------------------------------------"
   display " "
   display " INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog("------------------------------------------------------")
   let m_mensagem = "INICIO DO PROCESSAMENTO....: ", l_data, " ", l_hora
   call errorlog(m_mensagem)


#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_exibe_final()
#========================================================================
   define l_data  date,
          l_hora  datetime hour to second


   let l_data            = today
   let l_hora            = current
   let mr_param.fim      = today
   let mr_param.hour_fim = current

   display " "
   display " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   let m_mensagem = " TERMINO DO PROCESSAMENTO...: ", l_data, " ", l_hora
   call errorlog(m_mensagem)
   call errorlog("------------------------------------------------------")

#========================================================================
end function
#========================================================================



#========================================================================
function bdata010_valida_carga()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata010_full"
let lr_retorno.cpocod = 1


  open c_bdata010_002 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata010_002 into lr_retorno.cpodes
  whenever error stop

  if lr_retorno.cpodes =  "S"  then
     return true
  end if
  
  return false
#========================================================================
end function
#========================================================================





#========================================================================
function bdata010_recupera_dias()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata010_dias"
let lr_retorno.cpocod = 1


  open c_bdata010_002 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata010_002 into lr_retorno.cpodes
  whenever error stop
 
  if lr_retorno.cpodes is not null  then
     let mr_data.dias =  lr_retorno.cpodes
  end if
  

#========================================================================
end function
#========================================================================





#========================================================================
function bdata010_carga_full()
#========================================================================

   display "##################################"
   display " DELETANDO MOVIMENTO... "
   display "##################################"

   initialize mr_data.* to null
   
   call bdata010_recupera_dias()
        
   if mr_data.dias is null then
      let m_mensagem = "Dias Invalidos!"
      call ERRORLOG(m_mensagem);
      display m_mensagem
      return false
   end if

 
  
   let m_mensagem = " DELETANDO MOVIMENTO.......: ", mr_data.dias, " - ", mr_data.fim   
   call bdata010_monta_mensagem2(m_mensagem)
   
   call bdata010_remove_beneficio()  
   
   call bdata010_remove_inconsistencia() 
   
   call bdata010_remove_processamento() 
           
   call bdata010_exibe_dados_totais()
   
   return true

#========================================================================
end function
#========================================================================




#========================================================================
function bdata010_exibe_dados_parciais()
#========================================================================

   display " "
   display "-----------------------------------------------------------"
   display " DADOS PARCIAIS - DATA ", mr_data.dias
   display "-----------------------------------------------------------"
   display " "
   display " DADOS LIDOS BENEFICIOS DA APOLICE.....: ", mr_count1.apoli
   display " DADOS REMOVIDOS BENEFICIOS............: ", mr_count1.relat
   display " DADOS LIDOS INCOSISTENCIAS DA APOLICE.: ", mr_count1.lido
   display " DADOS REMOVIDOS INCOSISTENCIAS........: ", mr_count1.inco
   display " DADOS LIDOS PROCESSADOS DA APOLICE....: ", mr_count1.proc
   display " DADOS REMOVIDOS PROCESSADOS DA APOLICE: ", mr_count1.dele


#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_exibe_dados_totais()
#========================================================================


   display " "
   display "-----------------------------------------------------------"
   display " DADOS TOTAIS "
   display "-----------------------------------------------------------"
   display " "
   display " TOTAIS LIDOS BENEFICIOS DA APOLICE.....: ", mr_total.apoli
   display " TOTAIS REMOVIDOS BENEFICIOS............: ", mr_total.relat
   display " TOTAIS LIDOS INCOSISTENCIAS DA APOLICE.: ", mr_total.lido
   display " TOTAIS REMOVIDOS INCOSISTENCIAS........: ", mr_total.inco
   display " TOTAIS LIDOS PROCESSADOS DA APOLICE....: ", mr_total.proc
   display " TOTAIS REMOVIDOS PROCESSADOS DA APOLICE: ", mr_total.dele


#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_recupera_quebra()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes
end record

initialize lr_retorno.* to null

let lr_retorno.cponom = "bdata010_quebra"
let lr_retorno.cpocod = 1


  open c_bdata010_002 using  lr_retorno.cponom ,
                             lr_retorno.cpocod
  whenever error continue
  fetch c_bdata010_002 into m_quebra
  whenever error stop

  if m_quebra =  ""   or
     m_quebra is null or
     m_quebra =  0    then
     return false
  end if

  return true
#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_dispara_email()
#========================================================================

define lr_mail      record
       de           char(500)   # De
      ,para         char(5000)  # Para
      ,cc           char(500)   # cc
      ,cco          char(500)   # cco
      ,assunto      char(500)   # Assunto do e-mail
      ,mensagem     char(32766) # Nome do Anexo
      ,id_remetente char(20)
      ,tipo         char(4)     #
  end  record

define l_erro  smallint
define msg_erro char(500)
initialize lr_mail.* to null


    let lr_mail.de      = "ct24hs.email@portoseguro.com.br"
    let lr_mail.para    = bdata010_recupera_email()
    let lr_mail.cc      = ""
    let lr_mail.cco     = ""

    let lr_mail.assunto = "Limpeza Base Beneficios - LIMPEZA DE BENEFICIOS"

    let lr_mail.mensagem  = bdata010_monta_mensagem()
    let lr_mail.id_remetente = "CT24HS"
    let lr_mail.tipo = "html"

    #-----------------------------------------------
    # Dispara o E-mail
    #-----------------------------------------------

     call figrc009_mail_send1 (lr_mail.*)
     returning l_erro
              ,msg_erro



#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_recupera_email()
#========================================================================

define lr_retorno record
  cponom  like datkdominio.cponom,
  cpocod  like datkdominio.cpocod,
  cpodes  like datkdominio.cpodes,
  email   char(32766)            ,
  flag    smallint
end record

initialize lr_retorno.* to null

let lr_retorno.flag = true

let lr_retorno.cponom = "bdata010_email"


  open c_bdata010_003 using  lr_retorno.cponom
  foreach c_bdata010_003 into lr_retorno.cpodes

    if lr_retorno.flag then
      let lr_retorno.email = lr_retorno.cpodes clipped
      let lr_retorno.flag  = false
    else
      let lr_retorno.email = lr_retorno.email clipped, ";", lr_retorno.cpodes clipped
    end if


  end foreach


  return lr_retorno.email


#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_monta_mensagem()
#========================================================================


define lr_retorno record
  mensagem  char(30000)
end record

initialize lr_retorno.* to null


          #-----------------------------------------------
          # Monta a Mensagem
          #-----------------------------------------------

          let lr_retorno.mensagem = "<PRE><P><B>",
                                    " INICIO DO PROCESSAMENTO................: " , mr_param.ini, " - ", mr_param.hour_ini , "<br>",
                                    " FINAL DO PROCESSAMENTO.................: " , mr_param.fim, " - ", mr_param.hour_fim , "</B></P>",
                                    "<P>", m_msg_mail clipped, "</P><br><P>",
                                    " TOTAIS LIDOS BENEFICIOS DA APOLICE.....: " , mr_total.apoli     , "<br>" ,  
                                    " TOTAIS REMOVIDOS BENEFICIOS............: " , mr_total.relat     , "<br>" , 
                                    " TOTAIS LIDOS INCOSISTENCIAS DA APOLICE.: " , mr_total.lido      , "<br>" , 
                                    " TOTAIS REMOVIDOS INCOSISTENCIAS........: " , mr_total.inco      , "<br>" ,
                                    " TOTAIS LIDOS PROCESSADOS DA APOLICE....: " , mr_total.proc      , "<br>" ,
                                    " TOTAIS REMOVIDOS PROCESSADOS DA APOLICE: " , mr_total.dele      , "<br></P></PRE>"   

          return lr_retorno.mensagem
          
  
#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_deleta_beneficio()
#========================================================================

define lr_retorno record
  status  char(30000)
end record

initialize lr_retorno.* to null

   
   whenever error continue
   execute p_bdata010_004 using mr_processo2.bnfcrgseqnum                     
   whenever error continue
   
   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA DELECAO DOS BENEFICIOS! '
      call ERRORLOG(m_mensagem);
      display m_mensagem
      let lr_retorno.status = false
   else
      let lr_retorno.status = true
   end if
   
   return lr_retorno.status
#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_deleta_incosistencia()
#========================================================================

define lr_retorno record
  status  char(30000)
end record

initialize lr_retorno.* to null

   
   whenever error continue
   execute p_bdata010_006 using mr_processo2.icoseqnum                     
   whenever error continue
   
   if sqlca.sqlcode <> 0 then
      let m_mensagem = 'ERRO(',sqlca.sqlcode,') NA DELECAO DA INCONSISTENCIA! '
      call ERRORLOG(m_mensagem);
      display m_mensagem
      let lr_retorno.status = false
   else
      let lr_retorno.status = true
   end if
   
   return lr_retorno.status
#========================================================================
end function
#========================================================================

#========================================================================
function bdata010_monta_mensagem2(l_param)
#========================================================================

   define l_param    char(100)

   let m_msg_mail = m_msg_mail clipped, "<br>"
                    , l_param clipped

#========================================================================
end function
#========================================================================

#======================================================================== 
 function bdata010_valida_dia_hora()
#======================================================================== 

define lr_retorno record
	dia  integer,
	hora datetime hour to second
end record
   
  let lr_retorno.hora = current
  let lr_retorno.dia  = weekday(today)
  
  if lr_retorno.dia <> 6 and
  	 lr_retorno.dia <> 0 then
  
      if lr_retorno.hora >= '04:00:00' and
         lr_retorno.hora <= '05:00:00' then
         return false
      end if
  end if

 
  return true
#======================================================================== 
 end function
#======================================================================== 
