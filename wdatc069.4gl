#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24h / Porto Socorro                                 #
# Modulo         : wdatc069.4gl                                                #
#                  Parametros para a Consulta de Mensagens.                    #
#                  Portal de Negocios(Prestador On-line)->Mensagens->Historico #
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 187801                                                      #
#..............................................................................#
# Desenvolvimento: META, Marcos M.P.                                           #
# Data           : 05/10/2004                                                  #
#..............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco. #
###############################################################################
database porto 

#-------------------------------------------------------------------------------
main
#-------------------------------------------------------------------------------

   call fun_dba_abre_banco("CT24HS") 

   set isolation to dirty read

   call startlog ("wdatc069.log")

   call wdatc069()

end main

#=> RECEBE PARAMETROS DO wdatc068.pl E VALIDA SESSAO
#-------------------------------------------------------------------------------
function wdatc069()
#-------------------------------------------------------------------------------
   define lr_param        record
          usrtip          char(1),
          webusrcod       dec(8,0),
          sesnum          integer,
          macsissgl       char(50)
   end record
   define lr_ret002       record
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

   initialize lr_param.* to null
   initialize lr_ret002.* to null

#=> OBTEM PARAMETROS
   let lr_param.usrtip    = arg_val(01)
   let lr_param.webusrcod = arg_val(02)
   let lr_param.sesnum    = arg_val(03)
   let lr_param.macsissgl = arg_val(04)

#=> CRITICA PARAMETROS RECEBIDOS
   if lr_param.macsissgl is null or
      lr_param.webusrcod is null or
      lr_param.usrtip    is null or
      lr_param.sesnum    is null then
      display "ERRO@@Parâmetros não recebidos@@"  
      exit program
   end if

#=> VALIDA SESSAO DO 'PRESTADOR ON-LINE' (WEB)
   call wdatc002(lr_param.*)
         returning lr_ret002.*
   if lr_ret002.statusprc then
      display "NOSESS@@Por questões de segurança, seu tempo de permanência ",
              "nesta página atingiu o limite máximo@@"
      exit program
   end if

#=> ENVIA DISPLAYs PADRAO...
   call wdatc069_display()

#=> ATUALIZA SESSAO DO 'PRESTADOR ON-LINE'
   if wdatc003(lr_param.*, lr_ret002.*) then
      display "NOSESS@@Sessão Inválida!!@@"
      exit program
   end if

end function

#=> GERA PAGINA WEB PARA CONSULTA DE MENSAGENS
#-------------------------------------------------------------------------------
function wdatc069_display()
#-------------------------------------------------------------------------------

#=> CABECALHO
   display "PADRAO@@1@@B@@C@@0@@Consulta de Mensagens"

#=> TEXT FIELDs
   display "PADRAO@@5@@De@@0@@@@(dd/mm/aaaa)@@10@@10@@text@@dataini@@@@@@"
   display "PADRAO@@5@@Até@@0@@@@(dd/mm/aaaa)@@10@@10@@text@@datafim@@@@@@"
   
end function
