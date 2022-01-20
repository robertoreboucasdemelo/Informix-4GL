#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24h / Porto Socorro                                 #
# Modulo         : wdatc067.4gl                                                #
#                  Parametros para a Consulta de Mensagens.                    #
#                  Portal de Negocios(Prestador On-line)->Mensagens->Historico #
#                  Pagamento Porto  Socorro  = 2 
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 187801                                                      #
#..............................................................................#
# Desenvolvimento: META, Adriana Schneider                                     #
# Data           : 05/10/2004                                                  #
#..............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco. #
###############################################################################
database porto 

define mr_param        record
       usrtip          char(1),
       webusrcod       dec(8,0),
       sesnum          integer,
       macsissgl       char(50),
       prsmsgdstsit    like dparprsmsgdst.prsmsgdstsit,
       dataini         datetime year to second,
       datafim         datetime year to second
end record

define mr_ret002       record
          statusprc       smallint,
          sestblvardes1   char(256),
          sestblvardes2   char(256),
          sestblvardes3   char(256),
          sestblvardes4   char(256),
          sespcsprcnom    char(256),
          prgsgl          char(256),
          acsnivcod       dec(1,0),
          webprscod       dec(16,0)
end record

#-------------------------------------------------------------------------------
main
#-------------------------------------------------------------------------------

   call fun_dba_abre_banco("CT24HS") 

   set isolation to dirty read

   call startlog ("wdatc067.log")

   call wdatc067()
   
end main

#=> RECEBE PARAMETROS DO wdatc066.pl E VALIDA SESSAO
#-------------------------------------------------------------------------------
function wdatc067()
#-------------------------------------------------------------------------------
   define l_dataaux          date
 


#=> OBTEM PARAMETROS

   initialize mr_param.* to null 
   initialize mr_ret002.* to null 
   initialize l_dataaux to null
   
   let mr_param.usrtip       = arg_val(01)
   let mr_param.webusrcod    = arg_val(02)
   let mr_param.sesnum       = arg_val(03)
   let mr_param.macsissgl    = arg_val(04)
   let mr_param.prsmsgdstsit = arg_val(05)

   let l_dataaux = arg_val(06)
   let mr_param.dataini = l_dataaux

   let l_dataaux = arg_val(07)
   let l_dataaux = l_dataaux + 1 units day
   let mr_param.datafim = l_dataaux
   let mr_param.datafim = mr_param.datafim - 1 units second


#=> CRITICA PARAMETROS RECEBIDOS
   if mr_param.macsissgl is null or
      mr_param.webusrcod is null or
      mr_param.usrtip    is null or
      mr_param.sesnum    is null then 
      display "ERRO@@Parâmetros não recebidos@@"  
      exit program
   end if
   
   if mr_param.prsmsgdstsit is null or 
      mr_param.prsmsgdstsit <= 0    then 
      let mr_param.prsmsgdstsit = 1 
      let mr_param.dataini = today - 180 units day
      let mr_param.datafim = today + 1 units day 
      let mr_param.datafim = mr_param.datafim - 1 units second 
      
   end if    

#=> VALIDA SESSAO DO 'PRESTADOR ON-LINE' (WEB)
   initialize mr_ret002.* to null 
   call wdatc002(mr_param.usrtip,     
                 mr_param.webusrcod,     
                 mr_param.sesnum,        
                 mr_param.macsissgl )
         returning mr_ret002.*
   if mr_ret002.statusprc then
      display "NOSESS@@Sessão Inválida!@@"
      exit program
   end if

#=> Seleciona os dados para montar a pagina e ENVIA DISPLAYs PADRAO...
   call wdatc067_display() 

#=> ATUALIZA SESSAO DO 'PRESTADOR ON-LINE'
   if wdatc003(mr_param.usrtip,     
               mr_param.webusrcod,     
               mr_param.sesnum,        
               mr_param.macsissgl,mr_ret002.*) then
      display "NOSESS@@Sessão Inválida!!@@"
      exit program
   end if

end function

#=> GERA PAGINA WEB PARA CONSULTA DE MENSAGENS
#-------------------------------------------------------------------------------
function wdatc067_display()
#-------------------------------------------------------------------------------
define l_existe char(01),
       l_prsmsgcod    like dpakprsmsg.prsmsgcod,
       l_prsmsgtitdes like dpakprsmsg.prsmsgtitdes,
       l_caddat       like dpakprsmsg.caddat,
       l_data_fmt     char(30),
       l_data_def     char(30)

 initialize l_existe to null
 initialize l_prsmsgcod    to null
 initialize l_prsmsgtitdes to null
 initialize l_caddat       to null
 initialize l_data_fmt     to null
 initialize l_data_def     to null

#=> CABECALHO
   display "PADRAO@@1@@B@@C@@0@@Consulta de Mensagens"
      
#=> TEXT FIELDs
   display "PADRAO@@6@@3@@N@@C@@0@@1@@20%@@Mensagem@@@@",
                         "N@@C@@0@@1@@40%@@Título@@@@",
                         "N@@C@@0@@1@@20%@@Data@@@@"
           
   declare cwdatc067001 cursor for 
    select a.prsmsgcod,
           a.prsmsgtitdes,
           a.caddat
    from dpakprsmsg a, dparprsmsgdst b 
    where 
       a.prsmsgcod    = b.prsmsgcod          and 
       a.caddat      >= mr_param.dataini     and 
       a.caddat      <= mr_param.datafim     and
       b.pstcoddig    = mr_ret002.webprscod  and 
       b.prsmsgdstsit = mr_param.prsmsgdstsit
    order by 1 

    foreach cwdatc067001 into l_prsmsgcod,l_prsmsgtitdes,l_caddat 

       let l_data_def = l_caddat
       let l_data_fmt = l_data_def[9,10],
                    '/',l_data_def[6,7],
                    '/',l_data_def[1,4],
                    ' ',l_data_def[12,16]
                    
              
     display "PADRAO@@6@@3@@N@@C@@1@@1@@20%@@",l_prsmsgcod,
                               "@@wdatc070.pl?usrtip=",mr_param.usrtip clipped,
                                            "&webusrcod=",mr_param.webusrcod using "<<<<<<<<",   
                                            "&sesnum=",mr_param.sesnum using "<<<<<<<<<<",
                                            "&macsissgl=",mr_param.macsissgl clipped,
                                            "&prsmsgcod=",l_prsmsgcod using "<<<<<<<<<<"	,"@@",
                           "N@@C@@1@@1@@40%@@",l_prsmsgtitdes clipped,"@@@@",
                           "N@@C@@1@@1@@20%@@",l_data_fmt,"@@@@"
      
   end foreach 
  
   
end function
