############################################################################ #
# Nome do Modulo: CTF00M08                                         Nilo      #
#                                                                            #
# Isolamento Funcao - Laudo - Sinistro Ramos Elementares (CTS04M00)Fev/2009  #
#                                                                            #
# -------------------------------------------------------------------------- #
#                      * * * Alteracoes * * *                                #
#                                                                            #
# Data        Autor Fabrica  Origem    Alteracao                             #
# ---------- --------------  -------   ------------------------------------- #
# 20/02/2009  Nilo           Psi234311 Danos Eletricos                       #
#----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo  219444   Receber/retornar p/"ctf00m08_gera_p10" #
#                                     os parametros (lclnumseq / rmerscseq)  #
#                                     Tratar inclusao em datmsrvre           #
#----------------------------------------------------------------------------#
############################################################################ #


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

#----------------------------------------
function ctf00m08_gera_p10(param,param_hist)
#----------------------------------------

  define param         record
         c24astcod     like datkassunto.c24astcod
        ,atdsrvorg     like datksrvtip.atdsrvorg
        ,atdsrvnum     like datmservico.atdsrvnum
        ,atdsrvano     like datmservico.atdsrvano
        ,srvnum        char (13)

	,atddat        like datmservico.atddat
	,atdhor        like datmservico.atdhor
	,funmat        like datmservico.funmat
        ,frmflg        char (01)
        ,atdfnlflg     like datmservico.atdfnlflg
        ,acao_origem   char(03)
        ,prslocflg     char (01)

---> endereço
        ,operacao      char (01)
        ,lclidttxt     like datmlcl.lclidttxt
        ,lgdtxt        char (65)
        ,lgdtip        like datmlcl.lgdtip
        ,lgdnom        like datmlcl.lgdnom
        ,lgdnum        like datmlcl.lgdnum
        ,brrnom        like datmlcl.brrnom
        ,lclbrrnom     like datmlcl.lclbrrnom
        ,endzon        like datmlcl.endzon
        ,cidnom        like datmlcl.cidnom
        ,ufdcod        like datmlcl.ufdcod
        ,lgdcep        like datmlcl.lgdcep
        ,lgdcepcmp     like datmlcl.lgdcepcmp
        ,lclltt        like datmlcl.lclltt
        ,lcllgt        like datmlcl.lcllgt
        ,dddcod        like datmlcl.dddcod
        ,lcltelnum     like datmlcl.lcltelnum
        ,lclcttnom     like datmlcl.lclcttnom
        ,lclrefptotxt  like datmlcl.lclrefptotxt
        ,c24lclpdrcod  like datmlcl.c24lclpdrcod
        ,ofnnumdig     like sgokofi.ofnnumdig
        ,emeviacod     like datmemeviadpt.emeviacod
        ,celteldddcod  like datmlcl.celteldddcod
        ,celtelnum     like datmlcl.celtelnum
        ,endcmp        like datmlcl.endcmp
---< endereço

        ,atdetpcod     like datmsrvacp.atdetpcod
        ,atdlibflg     like datmservico.atdlibflg
        ,srrcoddig     like datmsrvacp.srrcoddig

        ,cnldat        like datmservico.cnldat
        ,atdfnlhor     like datmservico.atdfnlhor
        ,c24opemat     like datmservico.c24opemat

        ,atdprscod     like datmservico.atdprscod
        ,c24nomctt     like datmservico.c24nomctt

        ,lclrsccod     like datmsrvre.lclrsccod
        ,orrdat        like datmsrvre.orrdat
        ,orrhor        like datmsrvre.orrhor
        ,sinntzcod     like datmsrvre.sinntzcod   ---> Natureza Sinistro!!!!
        ,socntzcod     like datmsrvre.socntzcod   ---> Natureza P.Socorro!!!!
        ,lclnumseq     like datmsrvre.lclnumseq   ---> Cod. local de Risco
        ,rmerscseq     like datmsrvre.rmerscseq   ---> Cod. Bloco do Condominio
        ,sinvstnum     like datmpedvist.sinvstnum
        ,sinvstano     like datmpedvist.sinvstano
        ,atdorgsrvnum  like datmsrvre.atdorgsrvnum
        ,atdorgsrvano  like datmsrvre.atdorgsrvano
        ,srvretmtvcod  like datmsrvre.srvretmtvcod
        ,srvretmtvdes  like datksrvret.srvretmtvdes

        ,c24pbmcod     like datkpbm.c24pbmcod
        ,atddfttxt     like datmservico.atddfttxt
        ,nom           like datmservico.nom
        ,corsus        like datmservico.corsus
        ,cornom        like datmservico.cornom
        ,asitipcod     like datmservico.asitipcod
        ,atdprinvlcod  like datmservico.atdprinvlcod
        ,imdsrvflg     char (01)

        ,atdlibhor     like datmservico.atdlibhor
        ,atdlibdat     like datmservico.atdlibdat
        ,atdhorpvt     like datmservico.atdhorpvt
        ,atdhorprg     like datmservico.atdhorprg
        ,atddatprg     like datmservico.atddatprg
        ,atdpvtretflg  like datmservico.atdpvtretflg
        ,socvclcod     like datmservico.socvclcod

  end record

  define param_hist      record
         hist1           like datmservhist.c24srvdsc,
         hist2           like datmservhist.c24srvdsc,
         hist3           like datmservhist.c24srvdsc,
         hist4           like datmservhist.c24srvdsc,
         hist5           like datmservhist.c24srvdsc
  end record

  define ws              record
         char_prompt     char(01)                   ,
         retorno         smallint                   ,
         lignum          like datmligacao.lignum    ,
         atdsrvnum       like datmservico.atdsrvnum ,
         atdsrvano       like datmservico.atdsrvano ,
         codesql         integer                    ,
         tabname         like systables.tabname     ,
         msg             char(80)                ,

         caddat          like datmligfrm.caddat     ,
         cadhor          like datmligfrm.cadhor     ,
         cademp          like datmligfrm.cademp     ,
         cadmat          like datmligfrm.cadmat     ,
         atdsrvseq       like datmsrvacp.atdsrvseq  ,
         etpfunmat       like datmsrvacp.funmat     ,
         atdetpdat       like datmsrvacp.atdetpdat  ,
         atdetphor       like datmsrvacp.atdetphor  ,
         histerr         smallint                   ,
         atdrsdflg     like datmservico.atdrsdflg
  end record

  define l_sql          char(600)

  define l_data_banco   date
        ,l_hora2        datetime hour to minute
        ,l_data_hoje    date
        ,w_retorno      smallint

  initialize ws.* to null

  let l_sql        = null
  let l_data_banco = null
  let l_hora2      = null
  let l_data_hoje  = null
  let w_retorno    = null

  let l_sql = 'insert into datmsrvre (atdsrvnum ',
              '                      ,atdsrvano ',
              '                      ,lclrsccod ',
              '                      ,orrdat ',
              '                      ,orrhor ',
              '                      ,sinntzcod ',
              '                      ,socntzcod ',   ---> Natureza P.Socorro
              '                      ,atdsrvretflg ',
              '                      ,sinvstnum ',
              '                      ,sinvstano '  # PSI186406 - robson - inicio
                                  ,' ,atdorgsrvnum '
                                  ,' ,atdorgsrvano '
                                  ,' ,srvretmtvcod '
                                  ,' ,lclnumseq '
                                  ,' ,rmerscseq) '
             ,'values(?,?,?,?,?,?,?,"N",?,?,?,?,?,?,?) ' # PSI186406-robson-fim
  prepare p_ctf00m08_001   from l_sql

  let l_sql = ' insert into datmsrvretexc (atdsrvnum '
                                       ,' ,atdsrvano '
                                       ,' ,srvretexcdes '
                                       ,' ,caddat '
                                       ,' ,cademp '
                                       ,' ,cadmat '
                                       ,' ,cadusrtip) '
             ,' values ( ?,?,?,?,?,?,?) '

  prepare p_ctf00m08_002 from l_sql

  while true
     initialize ws.*  to null
## Para servicos RET, inicializar campos com nulos.
   if param.acao_origem = 'RET' then
      ##let mr_movimento.srvretmtvcod       = null
      ##let mr_movimento.srvretmtvdes       = null
      let param.prslocflg = null
      let param.imdsrvflg = null
      let param.atdlibflg = null
      let param.atdfnlflg = null
   end if

# PSI186406 - robson - fim

   let g_documento.acao = "INC"

   if  param.atddat is null  then
       call cts40g03_data_hora_banco(2)
           returning l_data_banco, l_hora2
       let param.atddat = l_data_banco
       let param.atdhor = l_hora2
   end if
   if  param.funmat is null  then
       let param.funmat = g_issk.funmat
   end if
   if  param.frmflg = "S"  then
       call cts40g03_data_hora_banco(2)
            returning l_data_banco, l_hora2
       let ws.caddat = l_data_banco
       let ws.cadhor = l_hora2
       let ws.cademp = g_issk.empcod
       let ws.cadmat = g_issk.funmat
   else
       initialize ws.caddat to null
       initialize ws.cadhor to null
       initialize ws.cademp to null
       initialize ws.cadmat to null
   end if
   if  param.atdfnlflg is null  then
       let param.atdfnlflg = "N"
       let param.c24opemat = g_issk.funmat  ###  Bloqueio do servico
   end if

 #------------------------------------------------------------------------------
 # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
 #------------------------------------------------------------------------------
 if g_documento.lclocodesres = "S" then
    let ws.atdrsdflg = "S"
 else
    let ws.atdrsdflg = "N"
 end if
 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / servico
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 2, "0" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codesql  ,
                  ws.msg

   if  ws.codesql = 0  then
       commit work
   else
       let ws.msg = "CTS04M00 - ",ws.msg
       call ctx13g00(ws.codesql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.char_prompt
       let ws.retorno = false
       exit while
   end if
   let g_documento.lignum   = ws.lignum
   let param.atdsrvnum = ws.atdsrvnum
   let param.atdsrvano = ws.atdsrvano

   let g_documento.atdsrvnum = param.atdsrvnum
   let g_documento.atdsrvano = param.atdsrvano

 #------------------------------------------------------------------------------
 # Grava ligacao e servico
 #------------------------------------------------------------------------------
   begin work

   if param.acao_origem = 'RET' then
      let param.c24astcod = 'RET'
   end if

   call cts10g00_ligacao ( g_documento.lignum      ,
                           param.atddat       ,
                           param.atdhor       ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           param.c24astcod   ,
                           param.funmat      ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           ws.atdsrvnum            ,
                           ws.atdsrvano            ,
                           "","","",""             ,
                           g_documento.succod      ,
                           g_documento.ramcod      ,
                           g_documento.aplnumdig   ,
                           g_documento.itmnumdig   ,
                           g_documento.edsnumref   ,
                           g_documento.prporg      ,
                           g_documento.prpnumdig   ,
                           g_documento.fcapacorg   ,
                           g_documento.fcapacnum   ,
                           "","","",""             ,
                           ws.caddat,  ws.cadhor   ,
                           ws.cademp,  ws.cadmat    )
        returning ws.tabname,
                  ws.codesql

   if  ws.codesql  <>  0  then
       error " Erro (", ws.codesql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.char_prompt
       let ws.retorno = false
       exit while
   end if

   call cts10g02_grava_servico( param.atdsrvnum        ,
                                param.atdsrvano        ,
                                g_documento.soltip  ,     # atdsoltip
                                g_documento.solnom  ,     # c24solnom
                                ""                  ,     # vclcorcod
                                param.funmat   ,
                                param.atdlibflg,
                                param.atdlibhor,
                                param.atdlibdat,
                                param.atddat   ,
                                param.atdhor   ,
                                ""                  ,     # atdlclflg
                                param.atdhorpvt,
                                param.atddatprg,
                                param.atdhorprg,
                                "0"                 ,     # ATDTIP
                                ""                  ,     # atdmotnom
                                ""                  ,     # atdvclsgl
                                param.atdprscod,
                                ""                  ,     # atdcstvlr
                                param.atdfnlflg,
                                param.atdfnlhor,
                                ws.atdrsdflg,
                                param.atddfttxt,
                                ""                  ,     # atddoctxt
                                param.c24opemat,
                                param.nom      ,
                                ""                  ,     # vcldes
                                ""                  ,     # vclanomdl
                                ""                  ,     # vcllicnum
                                param.corsus   ,
                                param.cornom   ,
                                param.cnldat   ,
                                ""                  ,     # pgtdat
                                param.c24nomctt,
                                param.atdpvtretflg,
                                ""                  ,     # atdvcltip
                                param.asitipcod,
                                ""                  ,     # socvclcod
                                ""                  ,     # vclcoddig
                                "N"                 ,     # srvprlflg
                                ""                  ,     # srrcoddig
                                param.atdprinvlcod,
                                param.atdsrvorg   ) # ATDSRVORG
        returning ws.tabname,
                  ws.codesql

   if  ws.codesql  <>  0  then
       error " Erro (", ws.codesql, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.char_prompt
       let ws.retorno = false
       exit while
   end if

   #------------------------------------------------------------------------
   # Grava Prestador no local PROVISORIO
   #------------------------------------------------------------------------
   if param.prslocflg = "S" then
      update datmservico set prslocflg = param.prslocflg,
                             socvclcod = param.socvclcod,
                             srrcoddig = param.srrcoddig
       where datmservico.atdsrvnum = param.atdsrvnum
         and datmservico.atdsrvano = param.atdsrvano
   end if

 #------------------------------------------------------------------------------
 # Grava problemas do servico
 #------------------------------------------------------------------------------

   call ctx09g02_inclui(param.atdsrvnum,
                        param.atdsrvano,
                        1                   , # Org. informacao 1-Segurado 2-Pst
                        param.c24pbmcod,
                        param.atddfttxt,
                        ""                  ) # Codigo prestador
        returning ws.codesql,
                  ws.tabname
   if  ws.codesql  <>  0  then
       error "ctx09g02_inclui", ws.codesql, ws.tabname
       rollback work
       prompt "" for char ws.char_prompt
       let ws.retorno = false
       exit while
   end if

 #------------------------------------------------------------------------------
 # Grava locais de ocorrencia
 #------------------------------------------------------------------------------
   if  param.operacao is null  then
       let param.operacao = "I"
   end if

   let ws.codesql = cts06g07_local( param.operacao
                                   ,param.atdsrvnum
                                   ,param.atdsrvano
                                   ,1
                                   ,param.lclidttxt
                                   ,param.lgdtip
                                   ,param.lgdnom
                                   ,param.lgdnum
                                   ,param.lclbrrnom
                                   ,param.brrnom
                                   ,param.cidnom
                                   ,param.ufdcod
                                   ,param.lclrefptotxt
                                   ,param.endzon
                                   ,param.lgdcep
                                   ,param.lgdcepcmp
                                   ,param.lclltt
                                   ,param.lcllgt
                                   ,param.dddcod
                                   ,param.lcltelnum
                                   ,param.lclcttnom
                                   ,param.c24lclpdrcod
                                   ,param.ofnnumdig
                                   ,param.emeviacod
                                   ,param.celteldddcod
                                   ,param.celtelnum
                                   ,param.endcmp)

   if  ws.codesql is null   or
       ws.codesql <> 0      then
       error " Erro (", ws.codesql, ") na gravacao do",
             " local de ocorrencia. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.char_prompt
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava etapas do acompanhamento
 #------------------------------------------------------------------------------

   if  param.atdetpcod is null  then
       if  param.atdlibflg = "S"  then
           let param.atdetpcod = 1
           let ws.etpfunmat = param.funmat
           let ws.atdetpdat = param.atdlibdat
           let ws.atdetphor = param.atdlibhor
       else
           let param.atdetpcod = 2
           let ws.etpfunmat = param.funmat
           let ws.atdetpdat = param.atddat
           let ws.atdetphor = param.atdhor
       end if

   else

      let w_retorno = cts10g04_insere_etapa(ws.atdsrvnum,
                                            ws.atdsrvano,
                                            1,
                                            param.atdprscod,
                                            " ",
                                            " ",
                                            param.srrcoddig)

       if  w_retorno <>  0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " etapa de acompanhamento (1). AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.char_prompt
           let ws.retorno = false
           exit while
       end if

       let ws.atdetpdat = param.cnldat
       let ws.atdetphor = param.atdfnlhor
       let ws.etpfunmat = param.c24opemat

   end if

   let w_retorno = cts10g04_insere_etapa(ws.atdsrvnum        ,
                                         ws.atdsrvano        ,
                                         param.atdetpcod,
                                         param.atdprscod,
                                         param.c24nomctt,
                                         " ",
                                         param.srrcoddig )

   if w_retorno <>  0  then
       error " Erro (", sqlca.sqlcode, ") na gravacao da",
             " etapa de acompanhamento (2). AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.char_prompt
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava informacoes do servico RE
 #------------------------------------------------------------------------------

 ## PSI 172065 - Inicio

   ##-- Gravar servico com nulo, caso seja zero --##
   if param.atdorgsrvnum = 0 then
      let param.atdorgsrvnum = null
      let param.atdorgsrvano = null
   end if

   whenever error continue
   execute p_ctf00m08_001  using ws.atdsrvnum,
                               ws.atdsrvano,
                               param.lclrsccod,
                               param.orrdat,
                               param.orrhor,
                               param.sinntzcod,
                               param.socntzcod,
                               param.sinvstnum,
                               param.sinvstano
                              ,param.atdorgsrvnum      #PSI186406 - robson - inicio
                              ,param.atdorgsrvano
                              ,param.srvretmtvcod      #PSI186406 - robson - fim
                              ,param.lclnumseq
                              ,param.rmerscseq
   whenever error stop

 ## PSI 172065 - Final

   if  sqlca.sqlcode <> 0 then
       error " Erro (", sqlca.sqlcode, ") na gravacao do",
             " servico Ramos Elementares. AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.char_prompt
       let ws.retorno = false
       exit while
   end if

#PSI186406 - robson - inicio

   if param.srvretmtvcod = 999 then
      call cts40g03_data_hora_banco(2)
           returning l_data_hoje, l_hora2

      whenever error continue
      execute p_ctf00m08_002 using ws.atdsrvnum
                                ,ws.atdsrvano
                                ,param.srvretmtvdes
                                ,l_data_hoje
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,g_issk.usrtip
      whenever error stop
      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT pctf00m08005: ' , sqlca.sqlcode, "/",sqlca.sqlerrd[2] sleep 2
         error ' Funcao inclui_ctf00m08() ', ws.atdsrvnum, '/'
                                           , ws.atdsrvano sleep 2
         rollback work
         prompt "" for char ws.char_prompt
         let ws.retorno = false
         exit while
      end if
   end if

#PSI186406 - robson - fim

 #------------------------------------------------------------------------------
 # Grava relacionamento servico / apolice
 #------------------------------------------------------------------------------

   if  g_documento.succod    is not null  and
       g_documento.ramcod    is not null  and
       g_documento.aplnumdig is not null  then

       insert into DATRSERVAPOL( atdsrvnum,
                                 atdsrvano,
                                 succod   ,
                                 ramcod   ,
                                 aplnumdig,
                                 itmnumdig,
                                 edsnumref )
                         values( ws.atdsrvnum         ,
                                 ws.atdsrvano         ,
                                 g_documento.succod   ,
                                 g_documento.ramcod   ,
                                 g_documento.aplnumdig,
                                 0                    ,
                                 g_documento.edsnumref )

       if  sqlca.sqlcode <> 0  then
           error " Erro (", sqlca.sqlcode, ") na gravacao do",
                 " relacionamento servico x apolice. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.char_prompt
           let ws.retorno = false
           exit while
       end if
   end if

   commit work
   # War Room
   # Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(ws.atdsrvnum, 
                               ws.atdsrvano) 

 #------------------------------------------------------------------------------
 # Grava HISTORICO do servico
 #------------------------------------------------------------------------------

   let ws.histerr = cts10g02_historico( ws.atdsrvnum,
                                        ws.atdsrvano,
                                        param.atddat,
                                        param.atdhor,
                                        param.funmat,
                                        param_hist.*   )

### if ws.histerr  = 0  then
### initialize g_documento.acao  to null
### end if


 #------------------------------------------------------------------------------
 # Exibe o numero do servico
 #------------------------------------------------------------------------------

   let param.srvnum = param.atdsrvorg using "&&",
                           "/", ws.atdsrvnum using "&&&&&&&",
                           "-", ws.atdsrvano using "&&"

   let ws.retorno = true

   exit while
 end while

 if ws.retorno = true then
    if cts34g00_acion_auto (param.atdsrvorg,
                            param.cidnom,
                            param.ufdcod) then

       #funcao cts34g00_acion_auto verificou que parametrizacao para origem
       # do servico esta OK
       #chamar funcao para validar regras gerais se um servico sera acionado
       # automaticamente ou nao e atualizar datmservico

       if not cts40g12_regras_aciona_auto (param.atdsrvorg,
                                           param.c24astcod,
                                           param.asitipcod,
                                           param.lclltt,
                                           param.lcllgt,
                                           param.prslocflg,
                                           "N",
                                           param.atdsrvnum,
                                           param.atdsrvano,
                                           g_documento.acao,
                                           "",
                                           "N") then
             #servico nao pode ser acionado automaticamente
             #display "Servico acionado manual"
       else
             #display "Servico foi para acionamento automatico!!"
       end if
    end if
 end if

 return ws.retorno
       ,param.*

end function
