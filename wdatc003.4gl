#############################################################################
# Nome do Modulo: wdatc003                                           Marcus #
#                                                                      Raji #
# Funcao de Atualizacao da Sessao WEB                              Mar/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
database porto

#------------------------------------------------------------------------------
 function wdatc003(param)
#------------------------------------------------------------------------------

 define param       record
   usrtip           char (1),
   webusrcod        dec  (6,0),
   sesnum           dec  (10),
   macsissgl        char (10),
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

 define ws          record
   comando          char (1000),
   statusprc        dec  (1,0)
 end record

 #---------------------------------------------------------------------------
 # Atualiza sessao do usuario
 #---------------------------------------------------------------------------
 initialize ws.*   to null

 let ws.comando = "execute procedure isssesextatz (",
                  ascii 34, param.usrtip clipped,      ascii 34,",",
                  ascii 34, param.webusrcod clipped,   ascii 34,",",
                  ascii 34, param.sesnum clipped,      ascii 34,",",
                  ascii 34, param.macsissgl clipped,   ascii 34,",",
                  ascii 34, param.prgsgl clipped,      ascii 34,",",
                  ascii 34, param.sespcsprcnom clipped,   ascii 34,",",
                  ascii 34, param.sestblvardes1 clipped,  ascii 34,",",
                  ascii 34, param.sestblvardes2 clipped,  ascii 34,",",
                  ascii 34, param.sestblvardes3 clipped,  ascii 34,",",
                  ascii 34, param.sestblvardes4 clipped,  ascii 34,")"


 prepare p_atualiza_sessao from        ws.comando
 declare c_atualiza_sessao cursor for  p_atualiza_sessao

 begin work

 open  c_atualiza_sessao
 fetch c_atualiza_sessao  into  ws.statusprc

 if ws.statusprc  is null   or  
    ws.statusprc  <> 0      then
    rollback work
    return ws.statusprc
 end if 

 close  c_atualiza_sessao

 commit work

 return ws.statusprc

end function 
