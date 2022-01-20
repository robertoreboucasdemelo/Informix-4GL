###############################################################################
# Nome do Modulo: CTS10G02                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Funcoes genericas de gravacao de servicos da Central 24 Horas      Set/1999 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
# --------------------------------------------------------------------------- #
# 05/06/2000  PSI 10865-0  Akio         Gravacao da tabela DATMSERVICO        #
#                                       via funcao                            #
# --------------------------------------------------------------------------- #
# 23/06/2000  PSI 10865-0  Akio         A funcao passa a receber o numero     #
#                                       do servico                            #
# --------------------------------------------------------------------------- #
# 07/07/2000  PSI 10865-0  Akio         Exclusao da funcao cts10g02_servico   #
#                                       Ver: cts10g03                         #
###############################################################################
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data        Autor Fabrica  Origem     Alteracao                             #
# ----------  -------------- ---------- --------------------------------------#
# 05/08/2005  James,Meta     PSI 192015 Atualizar Numero do Servico em Local/ #
#                                       Condicoes da tabela temporaria        #
# ----------  -------------- ---------- --------------------------------------#
# 02/07/2008  Carla Rampazzo            g_origem identifica quem chama:       #
#                                       "IFX"/null=Informix / "WEB"=Portal    #
# ----------  -------------- ---------- --------------------------------------#
# 31/07/20    Brunno Silva              CT: 140729234 - Campo que fazia parte #
#                                       da PK da tabela datmservhist esta     #
#                                       sendo inserido como NULO!             # 
# out/2014    Ligia Fornax              PSI-2014-19759EV
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep smallint

function cts10g02_prepare()

   define l_sql char(1000)

   let l_sql = 'insert into datrsrvcls ',
               '(atdsrvnum,atdsrvano,ramcod,clscod) ',
               'values (?,?,?,?)'
   prepare pcts10g02001 from l_sql
   let l_sql = "select c24srvdsc from datmservhist ",
               " where atdsrvnum = ? ",
               " and atdsrvano = ? ",
               " and c24funmat = ? "
   prepare pcts10g02002 from l_sql
   declare ccts10g02002 cursor for pcts10g02002


   let l_sql = " insert into DATMSERVICOCMP ( atdsrvnum , ",
               " atdsrvano ,rmcacpflg ,vclcamtip ,vclcrcdsc ,vclcrgflg  ",
               ",vclcrgpso ,sindat    ,sinhor    ,sinvitflg ,bocflg    ",
               ",bocnum    ,bocemi    ,vcllibflg) ",
               " values ( ?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
   prepare pcts10g02003 from l_sql

   let l_sql = " update DATMSERVICOCMP set smsenvflg = ? ",
               " where atdsrvnum = ? ",
               " and atdsrvano = ? "
   prepare pcts10g02004 from l_sql

   #####  Fornax PSI-2014-19759EV out/2014
   let l_sql = " select ramcod, rmemdlcod from datrmdlramast ",
               " where c24astcod = ? "
   prepare pcts10g02005 from l_sql
   declare ccts10g02005 cursor for pcts10g02005

   let l_sql = " insert into datrctbramsrv (atdsrvnum, atdsrvano, ",
               " c24astcod, ramcod, rmemdlcod) values (?,?,?,?,?) "
   prepare pcts10g02006 from l_sql
   #####  FIM - Fornax PSI-2014-19759EV out/2014

   let m_prep = true

end function


#--------------------------------------------------------------------
 function cts10g02_historico(param, hist_cts10g02)
#--------------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservhist.atdsrvnum,
    atdsrvano         like datmservhist.atdsrvano,
    ligdat            like datmservhist.ligdat   ,
    lighorinc         like datmservhist.lighorinc,
    c24funmat         like datmservhist.c24funmat
 end record

 define hist_cts10g02 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define a_cts10g02    array[05] of record
    histxt            like datmservhist.c24srvdsc
 end record

 define l_ret        smallint,
        l_mensagem   char(60)

 define ws            record
    histerr           smallint,
    c24txtseq         like datmservhist.c24txtseq,
    c24funmat         like datmservhist.c24funmat
 end record

 define arr_aux       smallint


 define w_pf1 integer

 let arr_aux  =  null

 for w_pf1  =  1  to  5
     initialize  a_cts10g02[w_pf1].*  to  null
 end for

 initialize  ws.*  to  null

 if param.c24funmat is null then
   let ws.c24funmat = g_issk.funmat
 else
   let ws.c24funmat = param.c24funmat
 end if


 let a_cts10g02[1].histxt = hist_cts10g02.hist1
 let a_cts10g02[2].histxt = hist_cts10g02.hist2
 let a_cts10g02[3].histxt = hist_cts10g02.hist3
 let a_cts10g02[4].histxt = hist_cts10g02.hist4
 let a_cts10g02[5].histxt = hist_cts10g02.hist5

 #BURINI# select max (c24txtseq)
 #BURINI#   into ws.c24txtseq
 #BURINI#   from datmservhist
 #BURINI#  where atdsrvnum = param.atdsrvnum   and
 #BURINI#        atdsrvano = param.atdsrvano
 #BURINI#
 #BURINI# if ws.c24txtseq  is null   then
 #BURINI#    let ws.c24txtseq = 0
 #BURINI# end if
 #BURINI#
 #BURINI# let ws.c24txtseq = ws.c24txtseq + 1
 #BURINI# let ws.histerr   = 0

 for arr_aux = 1 to 5
    if a_cts10g02[arr_aux].histxt is null then
       continue for
       	
       {exit for}
    else
       #BURINI# insert into datmservhist ( atdsrvnum ,
       #BURINI#                            atdsrvano ,
       #BURINI#                            c24txtseq ,
       #BURINI#                            c24funmat ,
       #BURINI#                            c24empcod ,
       #BURINI#                            c24usrtip ,
       #BURINI#                            ligdat    ,
       #BURINI#                            lighorinc ,
       #BURINI#                            c24srvdsc )
       #BURINI#                   values ( param.atdsrvnum ,
       #BURINI#                            param.atdsrvano ,
       #BURINI#                            ws.c24txtseq    ,
       #BURINI#                            ws.c24funmat    ,
       #BURINI#                            g_issk.empcod   ,
       #BURINI#                            g_issk.usrtip   ,
       #BURINI#                            param.ligdat    ,
       #BURINI#                            param.lighorinc ,
       #BURINI#                            a_cts10g02[arr_aux].histxt )

       call ctd07g01_ins_datmservhist(param.atdsrvnum,
                                      param.atdsrvano,
                                      g_issk.funmat,
                                      a_cts10g02[arr_aux].histxt,
                                      param.ligdat,
                                      param.lighorinc,
                                      g_issk.empcod,
                                      g_issk.usrtip)
            returning l_ret,
                      l_mensagem
       if l_ret <> 1  then

          if g_origem is null   or
	     g_origem =  "IFX"  then
             error l_mensagem, " - CTS10G02 - AVISE A INFORMATICA!"
	  end if

          let ws.histerr = sqlca.sqlcode
          exit for
       end if

       #BURINI# let ws.c24txtseq = ws.c24txtseq + 1

    end if

 end for

 return ws.histerr

end function  ###  cts10g02_historico

#--------------------------------------------------------------------
 function cts10g02_historico_mq(param, hist_cts10g02)
#--------------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservhist.atdsrvnum,
    atdsrvano         like datmservhist.atdsrvano,
    ligdat            like datmservhist.ligdat   ,
    lighorinc         like datmservhist.lighorinc,
    funmat            like datmservhist.c24funmat,
    usrtip            like datmservhist.c24usrtip,
    empcod            like datmservhist.c24empcod
 end record

 define hist_cts10g02 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define a_cts10g02    array[05] of record
    histxt            like datmservhist.c24srvdsc
 end record

 define l_ret        smallint,
        l_mensagem   char(60)

 define ws            record
    histerr           smallint,
    c24txtseq         like datmservhist.c24txtseq
 end record

 define arr_aux       smallint

 define w_pf1 integer

  define l_collen    integer,
         l_txtaux    char(8),
         l_txthor    char(8),
         l_tamtxt    smallint

 let arr_aux  =  null

 for w_pf1  =  1  to  5
     initialize  a_cts10g02[w_pf1].*  to  null
 end for

 initialize  ws.*  to  null

 # VERIFICA TAMANHO DO CAMPO DATETIME NA TABELA TEMPORARIO ATE REORG PRODUCAO
 let l_collen = 0
 select collength into l_collen
   from systables tab, 
        syscolumns col
  where tab.tabname = 'datmservhist'
    and col.tabid = tab.tabid
    and col.colname = 'lighorinc'

 let l_txtaux = param.lighorinc
 let l_tamtxt = length(l_txtaux)
 if l_tamtxt = 5 then
 	  let l_txtaux = l_txtaux clipped, ":00"
 end if

 if l_collen < 1642 then  # 1642 = HH:MM:SS
 	 let l_txthor = l_txtaux[1,5]
 else
 	 let l_txthor = l_txtaux[1,8]
 end if

 let a_cts10g02[1].histxt = hist_cts10g02.hist1
 let a_cts10g02[2].histxt = hist_cts10g02.hist2
 let a_cts10g02[3].histxt = hist_cts10g02.hist3
 let a_cts10g02[4].histxt = hist_cts10g02.hist4
 let a_cts10g02[5].histxt = hist_cts10g02.hist5

 select max (c24txtseq)
   into ws.c24txtseq
   from datmservhist
  where atdsrvnum = param.atdsrvnum   and
        atdsrvano = param.atdsrvano
 
  
 if ws.c24txtseq is null or ws.c24txtseq = " "  then
    let ws.c24txtseq = 0
 end if
 
 let ws.c24txtseq = ws.c24txtseq + 1
 let ws.histerr   = 0

 for arr_aux = 1 to 5
    if a_cts10g02[arr_aux].histxt is null then
       exit for
    else
       #CT: 140729234
       #Descricao: No insert abaixo uma campo que eh chave na tabela era informado
       #           como NULO ocasionando o erro -703 ao executar o comando de 
       #           INSERT na base de dados!
       #           Foi acrescentado uma tratativa de erro para que o programa
       #           nao caisse.
       #Autor: Brunno Silva
       #Equipe: Sistemas Niagara
       whenever error continue
          insert into datmservhist ( atdsrvnum ,
                                     atdsrvano ,
                                     c24txtseq ,
                                     c24funmat ,
                                     c24empcod ,
                                     c24usrtip ,
                                     ligdat    ,
                                     lighorinc ,
                                     c24srvdsc )
                            values ( param.atdsrvnum ,
                                     param.atdsrvano ,
                                     ws.c24txtseq    ,
                                     param.funmat    ,
                                     param.empcod    ,
                                     param.usrtip    ,
                                     param.ligdat    ,
                                     l_txthor        ,
                                     a_cts10g02[arr_aux].histxt )
          
          ### Quando a gravacao vier do AW MQ nao deve chamar a funcao padrao de gravacao porque ela envia informacao para o AW
          ### call ctd07g01_ins_datmservhist(param.atdsrvnum,
          ###                                param.atdsrvano,
          ###                                param.funmat,
          ###                                a_cts10g02[arr_aux].histxt,
          ###                                param.ligdat,
          ###                                param.lighorinc,
          ###                                param.empcod,
          ###                                param.usrtip)
          ###      returning l_ret,
          ###                l_mensagem
          
          if sqlca.sqlcode <> 0  then
             display "Erro: ",sqlca.sqlcode
             let ws.histerr = sqlca.sqlcode
             exit for
          end if
          
          let ws.c24txtseq = ws.c24txtseq + 1
       whenever error stop
       # FIM CT: 140729234
    end if

 end for

 return ws.histerr

end function  ###  cts10g02_historico_mq


#-------------------------------------------------------------------------------
 function cts10g02_grava_servico( param )
#-------------------------------------------------------------------------------

 define param          record
        atdsrvnum      like datmservico.atdsrvnum,
        atdsrvano      like datmservico.atdsrvano,
        atdsoltip      like datmservico.atdsoltip,
        c24solnom      like datmservico.c24solnom,
        vclcorcod      like datmservico.vclcorcod,
        funmat         like datmservico.funmat   ,
        atdlibflg      like datmservico.atdlibflg,
        atdlibhor      like datmservico.atdlibhor,
        atdlibdat      like datmservico.atdlibdat,
        atddat         like datmservico.atddat   ,
        atdhor         like datmservico.atdhor   ,
        atdlclflg      like datmservico.atdlclflg,
        atdhorpvt      like datmservico.atdhorpvt,
        atddatprg      like datmservico.atddatprg,
        atdhorprg      like datmservico.atdhorprg,
        atdtip         like datmservico.atdtip   ,
        atdmotnom      like datmservico.atdmotnom,
        atdvclsgl      like datmservico.atdvclsgl,
        atdprscod      like datmservico.atdprscod,
        atdcstvlr      like datmservico.atdcstvlr,
        atdfnlflg      like datmservico.atdfnlflg,
        atdfnlhor      like datmservico.atdfnlhor,
        atdrsdflg      like datmservico.atdrsdflg,
        atddfttxt      like datmservico.atddfttxt,
        atddoctxt      like datmservico.atddoctxt,
        c24opemat      like datmservico.c24opemat,
        nom            like datmservico.nom      ,
        vcldes         like datmservico.vcldes   ,
        vclanomdl      like datmservico.vclanomdl,
        vcllicnum      like datmservico.vcllicnum,
        corsus         like datmservico.corsus   ,
        cornom         like datmservico.cornom   ,
        cnldat         like datmservico.cnldat   ,
        pgtdat         like datmservico.pgtdat   ,
        c24nomctt      like datmservico.c24nomctt,
        atdpvtretflg   like datmservico.atdpvtretflg,
        atdvcltip      like datmservico.atdvcltip,
        asitipcod      like datmservico.asitipcod,
        socvclcod      like datmservico.socvclcod,
        vclcoddig      like datmservico.vclcoddig,
        srvprlflg      like datmservico.srvprlflg,
        srrcoddig      like datmservico.srrcoddig,
        atdprinvlcod   like datmservico.atdprinvlcod,
        atdsrvorg      like datmservico.atdsrvorg
 end record

 define retorno        record
        tabname        char(30),
        sqlcode        integer
 end record

 define ws            record
    c24funmat         like datmservhist.c24funmat
 end record

 initialize  retorno.*  to  null
 initialize  ws.*       to  null

 if param.funmat is null then
   let ws.c24funmat = g_issk.funmat
 else
   let ws.c24funmat = param.funmat
 end if

 if g_documento.crtsaunum is not null and
    g_documento.crtsaunum <> 0        then
    let g_documento.ciaempcod = 50# empresa Porto Saude
 end if
 --------------------------------------------------------------------
 # Quando a chamada e fora do online,alimentar a global para gravar
 # datmligacao.
 # Quando a chamada e via online a global empresa esta carregada.
 # Alteração para Azul Seguros - psi 205206 - 15/11/06.

 if g_documento.ciaempcod is null or
    g_documento.ciaempcod =  0    then # 01/03/07 Ruiz
    let g_documento.ciaempcod = 1 # empresa Porto Seguro
 end if
 --------------------------------------------------------------------

 while true

    insert into DATMSERVICO( atdsrvnum   , atdsrvano   ,
                             atdsoltip   , c24solnom   , vclcorcod,
                             funmat      , empcod      , usrtip   ,
                             atdlibflg   , atdlibhor   ,
                             atdlibdat   , atddat      , atdhor   ,
                             atdlclflg   , atdhorpvt   , atddatprg,
                             atdhorprg   , atdtip      , atdmotnom,
                             atdvclsgl   , atdprscod   , atdcstvlr,
                             atdfnlflg   , atdfnlhor   , atdrsdflg,
                             atddfttxt   , atddoctxt   , c24opemat,
                             nom         , vcldes      , vclanomdl,
                             vcllicnum   , corsus      , cornom   ,
                             cnldat      , pgtdat      , c24nomctt,
                             atdpvtretflg, atdvcltip   , asitipcod,
                             socvclcod   , vclcoddig   , srvprlflg,
                             srrcoddig   , atdprinvlcod, atdsrvorg,
                             ciaempcod,srvacsblqhordat )

               values( param.atdsrvnum   , param.atdsrvano   ,
                       param.atdsoltip   , param.c24solnom   , param.vclcorcod,
                       ws.c24funmat      , g_issk.empcod     , g_issk.usrtip  ,
                       param.atdlibflg   , param.atdlibhor   ,
                       param.atdlibdat   , param.atddat      , param.atdhor   ,
                       param.atdlclflg   , param.atdhorpvt   , param.atddatprg,
                       param.atdhorprg   , param.atdtip      , param.atdmotnom,
                       param.atdvclsgl   , param.atdprscod   , param.atdcstvlr,
                       param.atdfnlflg   , param.atdfnlhor   , param.atdrsdflg,
                       param.atddfttxt   , param.atddoctxt   , param.c24opemat,
                       param.nom         , param.vcldes      , param.vclanomdl,
                       param.vcllicnum   , param.corsus      , param.cornom   ,
                       param.cnldat      , param.pgtdat      , param.c24nomctt,
                       param.atdpvtretflg, param.atdvcltip   , param.asitipcod,
                       param.socvclcod   , param.vclcoddig   , param.srvprlflg,
                       param.srrcoddig   , param.atdprinvlcod, param.atdsrvorg,
                       g_documento.ciaempcod, current)

    if  sqlca.sqlcode <> 0  then
        let retorno.tabname = "DATMSERVICO"
    else
        let retorno.tabname = ""
    end if
    let retorno.sqlcode = sqlca.sqlcode

    exit while
 end while

 ##Fornax PSI-2014-19759EV out/2014, gravar a tabela datrctbramsrv para contabilizacao dos servicos da empresa 43.
 if retorno.sqlcode = 0 and  g_documento.ciaempcod = 43 then
    call cts10g02_grava_ctb( param.atdsrvnum   , param.atdsrvano )
         # returning retorno.tabname, retorno.sqlcode
 end if

 return retorno.tabname,
        retorno.sqlcode

end function

##Fornax PSI-2014-19759EV out/2014
#---------------------------------------#
function cts10g02_grava_ctb(lr_param)
#---------------------------------------#
   define lr_param         record
          atdsrvnum        like datrcndlclsrv.atdsrvnum,
          atdsrvano        like datrcndlclsrv.atdsrvano
   end record

   define l_ramcod    like datrctbramsrv.ramcod,
	        l_rammdlcod like datrctbramsrv.rmemdlcod

   let l_ramcod    = null
   let l_rammdlcod = null

   if m_prep = false or m_prep = " " then
      call cts10g02_prepare()
   end if

   open ccts10g02005 using g_documento.c24astcod
   fetch ccts10g02005 into l_ramcod, l_rammdlcod
   
   if sqlca.sqlcode = 0 then
      
      execute pcts10g02006 using lr_param.atdsrvnum, 
                                 lr_param.atdsrvano,
	    	                        g_documento.c24astcod, 
	    	                        l_ramcod, 
	    	                        l_rammdlcod      
      
   end if
   
end function


##-- Atualizar Numero do Servico em Local/Condicoes da tabela temporaria
#---------------------------------------#
function cts10g02_grava_loccnd(lr_param)
#---------------------------------------#

 define lr_param         record
        atdsrvnum        like datrcndlclsrv.atdsrvnum,
        atdsrvano        like datrcndlclsrv.atdsrvano
 end record
 define lr_retorno       record
        tabname          char(20),
        errcod           smallint
 end record
 initialize lr_retorno.*  to  null

 whenever error continue
 delete from datrcndlclsrv
  where atdsrvnum = lr_param.atdsrvnum
    and atdsrvano = lr_param.atdsrvano
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let lr_retorno.tabname = "datrcndlclsrv"
    let lr_retorno.errcod  = sqlca.sqlcode
    return lr_retorno.*
 end if
 whenever error continue
 update tmp_datrcndlclsrv
    set atdsrvnum = lr_param.atdsrvnum,
        atdsrvano = lr_param.atdsrvano
  where atdsrvnum = 0
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = -206 then
       let lr_retorno.errcod  = 0
    else
       let lr_retorno.tabname = "tmp_datrcndlclsrv"
       let lr_retorno.errcod  = sqlca.sqlcode
    end if
    return lr_retorno.*
 end if
 ##-- Incluir em Local/Condicoes X Servico, registros da temporaria
 whenever error continue
 insert into datrcndlclsrv
   select atdsrvnum, atdsrvano, vclcndlclcod
     from tmp_datrcndlclsrv
    where atdsrvnum = lr_param.atdsrvnum
      and atdsrvano = lr_param.atdsrvano
    group by atdsrvnum, atdsrvano, vclcndlclcod
 whenever error stop

 if sqlca.sqlcode <> 0 then
    let lr_retorno.tabname = "datrcndlclsrv"
    let lr_retorno.errcod  = sqlca.sqlcode
    return lr_retorno.*
 end if

 whenever error continue
 drop table tmp_datrcndlclsrv
 whenever error stop
 if sqlca.sqlcode <> 0 then
    let lr_retorno.tabname = "tmp_datrcndlclsrv"
    let lr_retorno.errcod  = sqlca.sqlcode
 else
    let lr_retorno.errcod  = 0
 end if

 return lr_retorno.*

end function

#-------------------------------------------------------------------------------
 function cts10g02_grava_servico_apolice(lr_param)
#-------------------------------------------------------------------------------

define lr_param record
       atdsrvnum like datrservapol.atdsrvnum ,
       atdsrvano like datrservapol.atdsrvano ,
       succod    like datrservapol.succod    ,
       ramcod    like datrservapol.ramcod    ,
       aplnumdig like datrservapol.aplnumdig ,
       itmnumdig like datrservapol.itmnumdig ,
       edsnumref like datrservapol.edsnumref
end record

define lr_retorno record
       tabname char(20) ,
       sqlcode integer
end record

initialize lr_retorno.* to null
     if g_documento.ciaempcod = 84 then
        if lr_param.edsnumref is null or
        	 lr_param.edsnumref = 0     then
           call cts01g00_valida_endosso_itau(lr_param.succod     ,
                                             lr_param.ramcod     ,
                                             lr_param.aplnumdig  )
           returning  lr_param.edsnumref
        end if
     else
        if lr_param.edsnumref is null then
              call cts01g00_valida_endosso(lr_param.succod     ,
                                           lr_param.ramcod     ,
                                           lr_param.aplnumdig  )
              returning  lr_param.edsnumref
        end if
     end if
     whenever error continue
     insert into DATRSERVAPOL ( atdsrvnum,
                                atdsrvano,
                                succod   ,
                                ramcod   ,
                                aplnumdig,
                                itmnumdig,
                                edsnumref  )
                       values ( lr_param.atdsrvnum  ,
                                lr_param.atdsrvano  ,
                                lr_param.succod     ,
                                lr_param.ramcod     ,
                                lr_param.aplnumdig  ,
                                lr_param.itmnumdig  ,
                                lr_param.edsnumref )

     whenever error stop
     if  sqlca.sqlcode <> 0  then
         let lr_retorno.tabname = "DATRSERVAPOL"
     else
         let lr_retorno.tabname = ""
     end if
     let lr_retorno.sqlcode = sqlca.sqlcode
     return lr_retorno.*
end function

#-------------------------------------------------------------------------------
 function cts10g02_grava_servico_clausula(lr_param)
#-------------------------------------------------------------------------------

  define lr_param record
         atdsrvnum like datrsrvcls.atdsrvnum ,
         atdsrvano like datrsrvcls.atdsrvano ,
         ramcod    like datrsrvcls.ramcod    ,
         clscod    like datrsrvcls.clscod
  end record
  define lr_retorno record
         tabname char(20) ,
         sqlcode integer
  end record

     initialize lr_retorno.* to null

     if m_prep = false or
        m_prep = " " then
        call cts10g02_prepare()
     end if
     whenever error continue
     execute pcts10g02001 using lr_param.atdsrvnum  ,
                                lr_param.atdsrvano  ,
                                lr_param.ramcod     ,
                                lr_param.clscod
     whenever error stop
     if  sqlca.sqlcode <> 0  then
         let lr_retorno.tabname = "DATRSRVCLS"
     else
         let lr_retorno.tabname = ""
     end if
     let lr_retorno.sqlcode = sqlca.sqlcode
     return lr_retorno.*
end function
#--------------------------------------------------------------------
 function cts10g02_historico_multiplo(param)
#--------------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservhist.atdsrvnum,
    atdsrvano         like datmservhist.atdsrvano,
    orgatdsrvnum      like datmservhist.atdsrvnum,
    orgatdsrvano      like datmservhist.atdsrvano,
    c24funmat         like datmservhist.c24funmat,
    ligdat            like datmservhist.ligdat   ,
    lighorinc         like datmservhist.lighorinc
 end record

 define a_cts10g02    array[200] of record
    histxt            like datmservhist.c24srvdsc
 end record

 define l_ret        smallint,
        l_mensagem   char(60)

 define ws            record
    histerr           smallint,
    c24txtseq         like datmservhist.c24txtseq,
    c24funmat         like datmservhist.c24funmat
 end record

 define arr_aux       smallint

 define w_pf1 integer

 let arr_aux  =  1

 for w_pf1  =  1  to  200
     initialize  a_cts10g02[w_pf1].*  to  null
 end for

 initialize  ws.*  to  null
 if m_prep is null or
    m_prep = false then
    call cts10g02_prepare()
 end if

 if param.c24funmat is null then
   let ws.c24funmat = g_issk.funmat
 else
   let ws.c24funmat = param.c24funmat
 end if


 whenever error continue
 open ccts10g02002 using param.orgatdsrvnum,
                         param.orgatdsrvano,
                         g_issk.funmat
 foreach ccts10g02002 into a_cts10g02[arr_aux].histxt
       call ctd07g01_ins_datmservhist(param.atdsrvnum,
                                      param.atdsrvano,
                                      g_issk.funmat,
                                      a_cts10g02[arr_aux].histxt,
                                      param.ligdat,
                                      param.lighorinc,
                                      g_issk.empcod,
                                      g_issk.usrtip)
            returning l_ret,
                      l_mensagem
       if l_ret <> 1  then
             error l_mensagem, " - CTS10G02_multiplo - AVISE A INFORMATICA!"
          let ws.histerr = sqlca.sqlcode
          exit foreach
       end if
  let arr_aux = arr_aux + 1
  end foreach
  close ccts10g02002
end function

function cts10g02_grava_complemento_servico(lr_param)

  define lr_param record
         atdsrvnum like datmservico.atdsrvnum
         ,atdsrvano like datmservico.atdsrvano
         ,rmcacpflg like datmservicocmp.rmcacpflg
         ,vclcamtip like datmservicocmp.vclcamtip
         ,vclcrcdsc like datmservicocmp.vclcrcdsc
         ,vclcrgflg like datmservicocmp.vclcrgflg
         ,vclcrgpso like datmservicocmp.vclcrgpso
         ,sindat    like datmservicocmp.sindat
         ,sinhor    like datmservicocmp.sinhor
         ,sinvitflg like datmservicocmp.sinvitflg
         ,bocflg    like datmservicocmp.bocflg
         ,bocnum    like datmservicocmp.bocnum
         ,bocemi    like datmservicocmp.bocemi
         ,vcllibflg like datmservicocmp.vcllibflg
   end record

   define lr_retorno record
          sqlcode  smallint
         ,mensagem char(500)
   end record

   initialize lr_retorno.* to null


   if m_prep = false or
      m_prep is null then
      call cts10g02_prepare()
   end if





   whenever error continue
      execute pcts10g02003 using lr_param.atdsrvnum
                                ,lr_param.atdsrvano
                                ,lr_param.rmcacpflg
                                ,lr_param.vclcamtip
                                ,lr_param.vclcrcdsc
                                ,lr_param.vclcrgflg
                                ,lr_param.vclcrgpso
                                ,lr_param.sindat
                                ,lr_param.sinhor
                                ,lr_param.sinvitflg
                                ,lr_param.bocflg
                                ,lr_param.bocnum
                                ,lr_param.bocemi
                                ,lr_param.vcllibflg
  whenever error stop

  let lr_retorno.sqlcode = sqlca.sqlcode
  if lr_retorno.sqlcode <> 0 then

     let lr_retorno.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao do",
                               " complemento do servico. AVISE A INFORMATICA!"
  end if


  return lr_retorno.*


end function

function cts10g02_atualiza_flg_email(lr_param)

 define lr_param record
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano,
        flag      char(1)
 end record

 define lr_retorno record
          sqlcode  smallint
         ,mensagem char(500)
 end record

 initialize lr_retorno.* to null


 if m_prep = false or
    m_prep is null then
    call cts10g02_prepare()
 end if

 #display "lr_param.atdsrvnum = ",lr_param.atdsrvnum
 #display "lr_param.atdsrvano = ",lr_param.atdsrvano
 #display "lr_param.flag      = ",lr_param.flag


 whenever error continue
 execute pcts10g02004 using lr_param.flag,
                            lr_param.atdsrvnum,
                            lr_param.atdsrvano

 whenever error stop

 let lr_retorno.sqlcode = sqlca.sqlcode

 if lr_retorno.sqlcode <> 0 then
    let lr_retorno.mensagem = "Erro <",lr_retorno.sqlcode ,
                              ">Ao alterar flag de envio SMS, AVISE A INFORMATICA"
 end if

 call cts00g07_apos_grvlaudo(lr_param.atdsrvnum,lr_param.atdsrvano)

 return lr_retorno.*


end function





