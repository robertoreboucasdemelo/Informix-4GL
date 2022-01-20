#############################################################################
# Nome do Modulo: wdatc002                                           Marcus #
#                                                                      Raji #
# Funcao de Validacao do Usuario/Sessao WEB                        Mar/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
database porto

#------------------------------------------------------------------------------
 function wdatc002(param)
#------------------------------------------------------------------------------

 define param  record
   usrtip      char (1),
   webusrcod   dec  (6,0),
   sesnum      dec  (10),
   macsissgl   char (10)
 end record

 define ws          record
   comando          char (1000)
 end record

 define ws1         record
   statusprc        dec  (1,0),
   sestblvardes1    char (256),
   sestblvardes2    char (256),
   sestblvardes3    char (256),
   sestblvardes4    char (256),
   sespcsprcnom     char (256),
   prgsgl           char (256),
   acsnivcod        dec  (1,0),
   webprscod        dec  (16,0)
 end record

 #---------------------------------------------------------------------------
 # Valida a sessao do usuario
 #---------------------------------------------------------------------------
 initialize ws.*  to null
 initialize ws1.*  to null

 let ws.comando = "execute procedure isssesextvld (",
                  ascii 34, param.usrtip,    ascii 34,",",
                  ascii 34, param.webusrcod, ascii 34,",",
                  ascii 34, param.sesnum,    ascii 34,",",
                  ascii 34, param.macsissgl, ascii 34,")"

 prepare p_valida_sessao from        ws.comando
 declare c_valida_sessao cursor for  p_valida_sessao

 open  c_valida_sessao
 fetch c_valida_sessao  into  ws1.statusprc,
                              ws1.sestblvardes1,
                              ws1.sestblvardes2,
                              ws1.sestblvardes3,
                              ws1.sestblvardes4,
                              ws1.sespcsprcnom,
                              ws1.prgsgl,
                              ws1.acsnivcod,
                              ws1.webprscod

return ws1.statusprc,
       ws1.sestblvardes1,
       ws1.sestblvardes2,
       ws1.sestblvardes3,
       ws1.sestblvardes4,
       ws1.sespcsprcnom,
       ws1.prgsgl,
       ws1.acsnivcod,
       ws1.webprscod

end function
