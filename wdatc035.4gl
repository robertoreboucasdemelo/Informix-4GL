#############################################################################
# Nome do Modulo: wdatc035                                          Marcus  #
#                                                                           #
# Envia mensagens do prestador on line  via teletrim               Dez/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Alterado caminho da global,         #
#                                         incluida funcao fun_dba_abre_banco. #
###############################################################################
#-----------------------------------------------------------------------------#
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 23/08/2007 Saulo, Meta     AS146056   fun_dba movida para o inicio do modulo#
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------------
 main
#----------------------------------------------------------------------

 define param     record
  usrtip          char (1),
  webusrcod       char (06),
  sesnum          char (10),
  macsissgl       char (10),
  pgrnum          like datkveiculo.pgrnum,
  mensagem        char(360)
 end record  

 define ws         record
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

 define ws1       record
  ustcod          like htlrust.ustcod,
  mstnum          like htlmmst.mstnum,
  errcod          smallint,
  pgrnum          like datkveiculo.pgrnum,
  atdvclsgl       like datkveiculo.atdvclsgl,
  sqlcod          integer
 end record

 define  ws2        record
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

 define comando   char(500)
 define sttsess   integer

 call fun_dba_abre_banco("CT24HS")

 initialize ws.*          to null
 initialize ws1.*         to null    
 initialize ws2.*         to null
 initialize param.*         to null
 initialize comando   to null
 initialize sttsess   to null

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.pgrnum     = arg_val(5)
 let param.mensagem   = arg_val(6) clipped

 let g_issk.funmat = 79
 let g_issk.empcod = 01
 
 let comando = " select atdvclsgl,pgrnum  ",
               " from datkveiculo         ",
               " where pstcoddig    = ?   "
 prepare s_datkveiculo from comando
 declare c_datkveiculo cursor for s_datkveiculo 

 #----------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #----------------------------------------------

 call wdatc002(param.usrtip,
               param.webusrcod,
               param.sesnum,
               param.macsissgl)
      returning ws.*

   if ws.statusprc <> 0 then
     display "NOSESS@@Por questões de segurança seu tempo de<BR> permanência nesta página atingiu seu limite máximo.@@"
      exit program(0)
   end if                     

 if param.pgrnum <> 0 then
    #-----------------------------------
    # Acessa nro codigo tabela teletrim
    #-----------------------------------
    select ustcod
      into ws1.ustcod
      from htlrust
     where pgrnum = param.pgrnum

     if sqlca.sqlcode <> 0 then
   #   display "PADRAO@@1@@N@@C@@0@@",sqlca.sqlcode,"@@"     
       # erro  return
     end if

       call wdatc035_env_msgtel(ws1.ustcod,
                                "PRESTADO ON-LINE",
                                param.mensagem clipped,
                                g_issk.funmat,
                                g_issk.empcod,
                                g_issk.maqsgl,
                                0            )
                      returning ws1.errcod,
                                ws1.sqlcod,
                                ws1.mstnum

           if ws1.errcod >= 5  then
              display "ERRO@@Problema ao enviar mensagem : ", ws1.errcod, " - ", ws1.sqlcod,"@@"
           else
              display "PADRAO@@1@@B@@C@@3@@Mensagem enviada com sucesso !@@"
           end if
else
   open  c_datkveiculo using ws.webprscod

   while true
     fetch c_datkveiculo into ws1.atdvclsgl,
                              ws1.pgrnum

     if sqlca.sqlcode <> 0 then
        exit while
     end if

     if ws1.pgrnum is not null then

        select ustcod
          into ws1.ustcod
          from htlrust
        where pgrnum = ws1.pgrnum

        if sqlca.sqlcode = 0 then
           call wdatc035_env_msgtel(ws1.ustcod,
                                    "PRESTADOR ON LINE",
                                    param.mensagem,
                                    g_issk.funmat,
                                    g_issk.empcod,
                                    g_issk.maqsgl,
                                    0)
                          returning ws1.errcod,
                                    ws1.sqlcod,
                                    ws1.mstnum

           if ws1.errcod >= 5  then
              display "PADRAO@@1@@B@@L@@3@@Problema ao enviar mensagem para ", ws1.atdvclsgl, " erro : ", ws1.errcod, " - ", ws1.sqlcod,"@@"
           else
              display "PADRAO@@1@@B@@L@@3@@Mensagem enviada para ", ws1.atdvclsgl,"@@"
           end if  
        end if
     end if
   end while
   close c_datkveiculo   

 #------------------------------------
 # ATUALIZA TEMPO DE SESSAO DO USUARIO
 #------------------------------------

  call wdatc003(param.usrtip,
                param.webusrcod,
                param.sesnum,
                param.macsissgl,
                ws2.*)
      returning sttsess

end if
end main


#-----------------------------------
function wdatc035_env_msgtel(param)
#-----------------------------------

 define param       record
    ustcod          like htlrust.ustcod,
    titulo          char (40),
    msgtxt          char (360),
    funmat          like isskfunc.funmat,
    empcod          like isskfunc.empcod,
    maqsgl          like ismkmaq.maqsgl,
    tltmvtnum       like datmtltmsglog.tltmvtnum
 end record

 define ws          record
    errcod          smallint,
    sqlcod          integer,
    mstnum          like htlmmst.mstnum,
    atldat          like datmtltmsglog.atldat,
    atlhor          like datmtltmsglog.atlhor,
    atlhorant       like datmtltmsglog.atlhor,
    mststt          like datmtltmsglog.mststt,
    mstnumseq       like datmtltmsglog.mstnumseq
 end record

 define arr_aux   integer

 initialize ws.* to null
 initialize arr_aux   to null

 let ws.atlhorant = current

 call fptla025_usuario(param.ustcod,   ## NRO.CODIGO TELETRIM
                       param.titulo,   ## TITULO DA MENSAGEM
                       param.msgtxt,   ## TEXTO DA MENSAGEM 9 x 40
                       param.funmat,   ## MATRICULA FUNCIONARIO
                       param.empcod,   ## EMPRESA FUNCIONARIO
                       false,          ## 0 = NAO 1 = CONTROLAR TRANSACAO
                       "O",            ## B = batch ou O = online
                       "M",            ## D = discada  M = mailtrim
                       "",             ## DATA TRANSMISSAO
                       "",             ## HORA TRANSMISSAO
                       param.maqsgl)   ## SERVIDOR APLICACAO OU BANCO
             returning ws.errcod,
                       ws.sqlcod,
                       ws.mstnum

#if ws.errcod >= 5  then
#   display "ERRO@@Problema ao enviar mensagem : ", ws.errcod, " - ", ws.sqlcod,"@@"
#else
#   display "PADRAO@@1@@B@@C@@3@@Mensagem enviada !@@"
#end if

 for arr_aux = 1 to 2
    let ws.atldat = today
    let ws.atlhor = current
    let ws.mststt = ws.errcod + 1

    if arr_aux = 1 then
       let ws.atlhor = ws.atlhorant
       let ws.mststt = 0
    end if

    whenever error continue

    insert into datmtltmsglog (mstnum,
                               mstnumseq,
                               tltmvtnum,
                               mststt,
                               atldat,
                               atlhor,
                               atlemp,
                               atlmat,
                               atlusrtip)
                       values (ws.mstnum,
                               arr_aux  ,
                               param.tltmvtnum,
                               ws.mststt,
                               ws.atldat,
                               ws.atlhor,
                               param.empcod,
                               param.funmat,
                               g_issk.usrtip)
 end for

 whenever error stop

 return ws.errcod, ws.sqlcod, ws.mstnum

end function #-- wdatc035_env_msgtel
