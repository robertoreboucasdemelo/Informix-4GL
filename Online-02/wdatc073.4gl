#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24h / Porto Socorro                                 #
# Modulo         : wdatc073.4gl                                                #
#                  Parametros para a Consulta de Cronograma.                   #
#                  Portal de Negocios(Prestador On-line)->Pagamentos           #
#                                     		                 ->Cronograma  #
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 188220                                                      #
#..............................................................................#
# Desenvolvimento: META, Adriana Schneider                                     #
# Data           : 03/12/2004                                                  #
#..............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco. #
###############################################################################
database porto 

define mr_param        record
       usrtip         char (1),
       webusrcod      char (6),
       sesnum         char (10),
       macsissgl      char (10)
end record

define mr_ret002       record
       statusprc      dec  (1,0),
       sestblvardes1  char (256),
       sestblvardes2  char (256),
       sestblvardes3  char (256),
       sestblvardes4  char (256),
       sespcsprcnom   char (256),
       prgsgl         char (256),
       acsnivcod      dec  (1,0),
       webprscod      dec  (16,0)
end record


#-------------------------------------------------------------------------------
main
#-------------------------------------------------------------------------------
   call fun_dba_abre_banco("CT24HS") 

   set isolation to dirty read

   call startlog ("wdatc073.log")

   call wdatc073()
   
end main

#=> RECEBE PARAMETROS DO wdatc066.pl E VALIDA SESSAO
#-------------------------------------------------------------------------------
function wdatc073()
#-------------------------------------------------------------------------------

#=> OBTEM PARAMETROS

   initialize mr_param.* to null 
   initialize mr_ret002.* to null 
   
   let mr_param.usrtip       = arg_val(01)
   let mr_param.webusrcod    = arg_val(02)
   let mr_param.sesnum       = arg_val(03)
   let mr_param.macsissgl    = arg_val(04)
 
  
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
   call wdatc073_display() 

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
function wdatc073_display()
#-------------------------------------------------------------------------------
   
define  l_crnpgtcod    like  dpaksocor.crnpgtcod,
        l_crnpgtetgdat like  dbsmcrnpgtetg.crnpgtetgdat,
        l_existe       char(01)

initialize l_crnpgtcod    to null
initialize l_crnpgtetgdat to null
initialize l_existe       to null
{
#=> CABECALHO
   display "PADRAO@@1@@B@@C@@0@@Próximas datas de fechamento das ordens de pagamento"
 }
      
#=> TEXT FIELDs
   display "PADRAO@@1@@B@@C@@0@@Datas@@"

   select crnpgtcod
   into   l_crnpgtcod
   from   dpaksocor
   where  pstcoddig = mr_ret002.webprscod
          
   declare cwdatc073001 cursor for 
       select crnpgtetgdat
       from   dbsmcrnpgtetg
       where  crnpgtetgdat >= today       and 
              crnpgtcod     = l_crnpgtcod
       order by 1 
       
   let l_existe = "N"     
   foreach  cwdatc073001  into  l_crnpgtetgdat          
  
     let l_existe = "S" 
     display "PADRAO@@1@@N@@L@@1@@",l_crnpgtetgdat using "dd/mm/yyyy","@@"
  
      
   end foreach 
  
   if l_existe = "N" then 
      display "ERRO@@Não existem registros !@@"  
      exit program
   end if 
   
end function
