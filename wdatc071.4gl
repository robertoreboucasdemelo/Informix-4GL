#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24h / Porto Socorro                                 #
# Modulo         : wdatc071.4gl                                                #
#                  Parametros para a Consulta de Mensagens.                    #
#                  Portal de Negocios(Prestador On-line)->Mensagens->Historico #
#                  Pagamento Porto  Socorro  = 2 
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 187801                                                      #
#..............................................................................#
# Desenvolvimento: META, Adriana Schneider                                     #
# Data           : 07/10/2004                                                  #
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
       prsmsgcod       like dpakprsmsg.prsmsgcod
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

   call startlog ("wdatc071.log")

   call wdatc071()
   
end main

#=> RECEBE PARAMETROS DO wdatc066.pl E VALIDA SESSAO
#-------------------------------------------------------------------------------
function wdatc071()
#-------------------------------------------------------------------------------

  

#=> OBTEM PARAMETROS

   initialize mr_param.* to null 
   initialize mr_ret002.* to null 
   
   let mr_param.usrtip       = arg_val(01)
   let mr_param.webusrcod    = arg_val(02)
   let mr_param.sesnum       = arg_val(03)
   let mr_param.macsissgl    = arg_val(04)
   let mr_param.prsmsgcod    = arg_val(05)
  
  
#=> CRITICA PARAMETROS RECEBIDOS
   if mr_param.macsissgl is null or
      mr_param.webusrcod is null or
      mr_param.usrtip    is null or
      mr_param.sesnum    is null then 
      display "ERRO@@Parâmetros não recebidos@@"  
      exit program
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
   call wdatc071_display() 

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
function wdatc071_display()
#-------------------------------------------------------------------------------
define l_existe char(01),
       l_prsmsgcod    like dpakprsmsg.prsmsgcod,
       l_prsmsgtitdes like dpakprsmsg.prsmsgtitdes,
       l_caddat       like dpakprsmsg.caddat,
       l_prsmsgdstsit like dparprsmsgdst.prsmsgdstsit,
       l_usrtip       like dparprsmsgdst.cadusrtip,
       l_webusrcod    like dparprsmsgdst.webusrcod,
       l_prsmsgltrdat like dparprsmsgdst.prsmsgltrdat,
       l_prsmsgtxt    like dpakprsmsgtxt.prsmsgtxt,
       l_prsmsglinseq like dpakprsmsgtxt.prsmsglinseq,
       l_webusrnom    like isskwebusr.webusrnom,
       l_date         date,
       l_hora         datetime hour to second,
       l_dtyear       datetime year to day ,
       l_data         char(19),
       l_texto        char(7000)
   
  
       initialize l_existe  to null
       initialize l_prsmsgcod     to null
       initialize l_prsmsgtitdes  to null
       initialize l_caddat        to null
       initialize l_prsmsgdstsit  to null
       initialize l_usrtip        to null
       initialize l_webusrcod     to null
       initialize l_prsmsgltrdat  to null
       initialize l_prsmsgtxt     to null
       initialize l_prsmsglinseq  to null
       initialize l_webusrnom     to null
       initialize l_date          to null
       initialize l_hora          to null
       initialize l_dtyear        to null
       initialize l_data          to null
       initialize l_texto         to null
                       
   select a.prsmsgcod,a.prsmsgtitdes,a.caddat,
          b.prsmsgdstsit,b.usrtip,b.webusrcod,b.prsmsgltrdat 
    into  l_prsmsgcod,l_prsmsgtitdes,l_caddat,
          l_prsmsgdstsit,l_usrtip,l_webusrcod,l_prsmsgltrdat  
    from dpakprsmsg a, dparprsmsgdst b 
    where 
         a.prsmsgcod    = b.prsmsgcod         and 
         a.prsmsgcod    = mr_param.prsmsgcod  and 
         b.pstcoddig    = mr_ret002.webprscod  
    
    #=> CABECALHO
    display "PADRAO@@1@@B@@C@@0@@Mensagem"
    
    #=> TEXT FIELDs
    display "PADRAO@@8@@Número da mensagem@@",l_prsmsgcod,"@@" ## Verificar qual padrao
    display "PADRAO@@8@@Título@@",l_prsmsgtitdes,"@@"               
    
    let l_date = l_caddat
    let l_hora = l_caddat
    
    display "PADRAO@@8@@Data do envio@@",l_date," ",l_hora,"@@"
   
    if l_prsmsgdstsit = 1 then  
       select webusrnom 
       into   l_webusrnom
       from   isskwebusr
       where usrtip    = mr_param.usrtip    and 
             webusrcod = mr_param.webusrcod
             
       
       let l_date = today
       let l_hora = time  
       
       let l_dtyear       = l_date 
       let l_data         = l_dtyear," " ,l_hora
       let l_prsmsgltrdat = l_data 
       
       display "PADRAO@@8@@Usuário@@",mr_param.usrtip clipped," ",
                                      mr_param.webusrcod using "<<<<<<<<"," ",
                                      l_webusrnom clipped ,"@@"                  
    else 
       select webusrnom 
       into   l_webusrnom
       from   isskwebusr
       where usrtip    = l_usrtip    and 
             webusrcod = l_webusrcod
    
       let l_date = date(l_prsmsgltrdat)
       let l_hora = l_prsmsgltrdat
       
       display "PADRAO@@8@@Usuário@@",l_usrtip clipped," ",
                                      l_webusrcod using "<<<<<<<<"," ",
                                      l_webusrnom clipped ,"@@"                  
    end if    
    
    display "PADRAO@@8@@Data de leitura@@",l_date," " ,l_hora,"@@"                  
    
    display "PADRAO@@1@@B@@C@@0@@Texto"
    
    declare cdpakprsmsgtxt01 cursor for 
      select 
         prsmsglinseq,
         prsmsgtxt
      from 
         dpakprsmsgtxt
      where 
         prsmsgcod = mr_param.prsmsgcod 
      order by 1       
  
  initialize l_texto to null 
  foreach cdpakprsmsgtxt01 into l_prsmsglinseq,l_prsmsgtxt      
       let l_texto = l_texto clipped,
                     l_prsmsgtxt clipped,
                     "<br>"
  end foreach   
  display "PADRAO@@6@@1@@N@@L@@1@@1@@100%@@",l_texto clipped,"@@@@"  

  if l_prsmsgdstsit  =1 then       
     update dparprsmsgdst set prsmsgdstsit = 2,
                              usrtip       = mr_param.usrtip, 
                              webusrcod    = mr_param.webusrcod, 
                              prsmsgltrdat = l_prsmsgltrdat     
     where prsmsgcod = mr_param.prsmsgcod
       and pstcoddig = mr_ret002.webprscod
                 
  end if                      
   
end function
