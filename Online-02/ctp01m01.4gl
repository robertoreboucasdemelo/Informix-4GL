##############################################################################
# Nome do Modulo: ctp01m01                                         Pedro     #
#                                                                  Marcelo   #
# Mostra todas as ligacoes/servicos                                Dez/1994  #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
# 15/10/1998  PSI 6895-0   Gilberto     Permitir registrar RETORNOS para     #
#                                       servicos atraves do codigo RET.      #
#----------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti-  #
#                                       ma etapa do servico.                 #
#----------------------------------------------------------------------------#
# 21/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga-  #
#                                       cao (CTS10G00) para gravar as tabe-  #
#                                       las de relacionamento.               #
#----------------------------------------------------------------------------#
# 08/12/1999  PSI 7263-0   Gilberto     Exibir historico de ligacoes para    #
#                                       propostas.                           #
#----------------------------------------------------------------------------#
# 16/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de       #
#                                       solicitante.                         #
#----------------------------------------------------------------------------#
# 30/03/2000  PSI 10079-0  Akio         Atendimento da perda parcial         #
#----------------------------------------------------------------------------#
# 26/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.    #
#----------------------------------------------------------------------------#
# 06/02/2001  PSI 12479-6  Ruiz         Marcacao de vistoria nos postos      #
#                                       (agendamento).                       #
#----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                #
##############################################################################
#                                                                            #
#                         * * * Alteracoes * * *                             #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- --------------- ---------- -------------------------------------#
# 25/11/2003  Meta, Bruno    PSI172111  Incluir ultimo parametro             #
#                            OSF 29343  na funcao cts20g00_ligacao().        #
#----------------------------------------------------------------------------#
# 22/09/06   Ligia Mattge    PSI 202720 Implementacao do cartao Saude        #
#----------------------------------------------------------------------------#
# 15/11/2006  Ruiz           PSI.205206 Atendimento Azul Seguros             #
#----------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650   Nao utilizar a 1 posicao do assunto  #
#                                       como sendo o agrupamento, buscar cod #
#                                       agrupamento.                         #
#----------------------------------------------------------------------------#
# 10/03/2009 Carla Rampazzo  PSI 235580 Auto Jovem-Curso Direcao Defensiva   #
#                                       Nro.Agendamento Curso(novo para-     #
#                                       metro de cts20g00_ligacao)           #
#----------------------------------------------------------------------------#
# 11/10/2010 Carla Rampazzo  PSI 260606 Tratar Fluxo de Reclamacao p/PSS(107)#
#----------------------------------------------------------------------------#
# 14/02/2011 Carla Rampazzo  PSI        Fluxo de Reclamacao p/ PortoSeg(518) #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 # --- PSI 172111 - Inicio ---
 
 define m_prep_sql         smallint
 
#--------------------------------------------------------------------------
 function ctp01m01_prepare()
#--------------------------------------------------------------------------
  define l_sql     char(100)
  
     let l_sql = " select c24astcod   ",
                 "   from datmligacao ",
                 "  where lignum = ?  "
     prepare pctp01m01001    from l_sql
     declare cctp01m01001    cursor for pctp01m01001

  let m_prep_sql = true

 end function
 
 # --- PSI 172111 - Final ---

#--------------------------------------------------------------------------
 function ctp01m01(param)
#--------------------------------------------------------------------------

 define param     record
    succod        like datrligapol.succod   ,
    ramcod        like datrligapol.ramcod   ,
    aplnumdig     like datrligapol.aplnumdig,
    itmnumdig     like datrligapol.itmnumdig,
    prporg        like datrligprp.prporg    ,
    prpnumdig     like datrligprp.prpnumdig ,
    fcapacorg     like datrligpac.fcapacorg ,
    fcapacnum     like datrligpac.fcapacnum,
    crtsaunum     like datrligsau.crtnum
 end record

 define a_ctp01m01 array[100] of record
    lignum        like datmligacao.lignum,
    ligdat        like datmligacao.ligdat,
    lighorinc     like datmligacao.lighorinc,
    funnom        like isskfunc.funnom,
    c24solnom     like datmligacao.c24solnom,
    c24soltipdes  like datksoltip.c24soltipdes,
    srvtxt        char (13),
    c24astcod     like datmligacao.c24astcod,
    c24astdes     char (72),
    c24paxnum     like datmligacao.c24paxnum,
    msgenv        char (01),
    atdetpdes     like datketapa.atdetpdes,
    atdsrvnum     like datrligsrv.atdsrvnum,
    atdsrvano     like datrligsrv.atdsrvano,
    sinvstnum     like datrligsinvst.sinvstnum,
    sinvstano     like datrligsinvst.sinvstano,
    ramcod        like datrligsinvst.ramcod,
    sinavsnum     like datrligsinavs.sinavsnum,
    sinavsano     like datrligsinavs.sinavsano,
    sinnum        like datrligsin.sinnum,
    sinano        like datrligsin.sinano,
    vstagnnum     like datrligagn.vstagnnum,
    trpavbnum     like datrligtrpavb.trpavbnum
 end record

## PSI 172111 - Inicio
 define al_ctp01m01 array[100] of record
    cnslignum     like datrligcnslig.cnslignum ,
    crtsaunum     like datrligsau.crtnum
 end record
## PSI 172111 - Final


 define ws        record
    funmat        like datmligacao.c24funmat,
    atdetpcod     like datketapa.atdetpcod  ,
    c24rclsitcod  like datmsitrecl.c24rclsitcod,
    c24soltipcod  like datksoltip.c24soltipcod,
    data          char (10)                 ,
    hora          char (05)                 ,
    c24astexbflg  like datkassunto.c24astexbflg,
    atdsrvorg     like datmservico.atdsrvorg,
    vstagnnum     like datrligagn.vstagnnum,
    vstagnstt     like datrligagn.vstagnstt,
    c24astagp     like datkassunto.c24astagp          ##psi230650
 end record

 define sql_comando char (300)

 define arr_aux     smallint
 
 define l_c24astcod      like datmligacao.c24astcod  # PSI 172111
 define l_erro           smallint                    # PSI 172111
 define l_param1         char(15)                    # PSI 172111
 define l_drscrsagdcod   like datrdrscrsagdlig.drscrsagdcod

 open window ctp01m01 at 05,02 with form "ctp01m01" attribute(form line 1)

#--------------------------------------------------------------------------
# Inicializa variaveis
#--------------------------------------------------------------------------

 let int_flag = false

 initialize a_ctp01m01       to null
 initialize ws.*             to null
 initialize l_drscrsagdcod   to null 

 # --- PSI 172111 - Inicio ---

 initialize al_ctp01m01    to null

 if m_prep_sql is null or m_prep_sql <> true then
    call ctp01m01_prepare()
 end if

 let l_erro = false

 # --- PSI 172111 - Final ---

 let ws.data  =  today
 let ws.hora  =  current hour to minute

#---------------------------------------------------------------------
# Preparacao dos comandos SQL
#---------------------------------------------------------------------
 let sql_comando = "select c24astexbflg from datkassunto",
                   " where c24astcod = ?"
 prepare sel_datkassunto from sql_comando
 declare c_datkassunto cursor for sel_datkassunto

 # PSI 230650
 let sql_comando = "select c24astagp from datkassunto",
                   " where c24astcod = ?"
 prepare sel_c24astagp from sql_comando
 declare c_c24astagp cursor for sel_c24astagp

 let sql_comando = "select funnom from isskfunc",
                   " where funmat = ?"
 prepare sel_isskfunc from sql_comando
 declare c_isskfunc cursor for sel_isskfunc

 let sql_comando = " select datrligmens.mstnum    ",
                   "   from datrligmens           ",
                   "  where datrligmens.lignum = ?"
 prepare sel_datrligmens from sql_comando
 declare c_datrligmens cursor for sel_datrligmens

 let sql_comando = "select max(c24rclsitcod)",
                   "  from datmsitrecl      ",
                   " where lignum = ?       "
 prepare sel_datmsitrecl from sql_comando
 declare c_datmsitrecl cursor for sel_datmsitrecl

 let sql_comando = "select cpodes from iddkdominio",
                   " where cponom = 'c24rclsitcod'",
                   "   and cpocod = ? "
 prepare sel_iddkdominio from sql_comando
 declare c_iddkdominio cursor for sel_iddkdominio

 let sql_comando = "select atdetpcod     ",
                   "  from datmsrvacp    ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? ",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from sql_comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let sql_comando = "select atdetpdes    ",
                   "  from datketapa    ",
                   " where atdetpcod = ?"
 prepare sel_datketapa from sql_comando
 declare c_datketapa cursor for sel_datketapa

 let sql_comando = "select canmtvdes     ",
                   "  from datmvstsincanc",
                   " where sinvstnum = ? ",
                   "   and sinvstano = ? "
 prepare sel_datmvstsincanc from sql_comando
 declare c_datmvstsincanc cursor for sel_datmvstsincanc

 let sql_comando = "select atdsrvnum, atdsrvano",
                   "  from datmlimpeza         ",
                   " where atdsrvnum = ?  and  ",
                   "       atdsrvano = ?       "
 prepare sel_datmlimpeza from sql_comando
 declare c_datmlimpeza cursor for sel_datmlimpeza

 let sql_comando = "select ligdat    ,",
                   "       lighorinc ,",
                   "       c24funmat ,",
                   "       c24solnom ,",
                   "       c24soltipcod ,",
                   "       c24astcod ,",
                   "       c24paxnum  ",
                   "  from datmligacao",
                   " where lignum = ? "
 prepare sel_datmligacao from sql_comando
 declare c_datmligacao cursor for sel_datmligacao

 let sql_comando = "select c24soltipdes ",
                     "from datksoltip "  ,
                          "where c24soltipcod = ?"
 prepare s_datksoltip from   sql_comando
 declare c_datksoltip cursor for s_datksoltip

 let sql_comando = "select atdsrvorg     ",
                   "  from datmservico   ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "
 prepare s_datmservico from   sql_comando
 declare c_datmservico cursor for s_datmservico

 let sql_comando = "select vstagnnum,vstagnstt ",
                   " from DATRLIGAGN ",
                   " where lignum    = ? "
 prepare s_datrligagn from sql_comando
 declare c_datrligagn cursor for s_datrligagn

 let sql_comando = "select drscrsagdcod, agdligrelstt ",
                    " from datrdrscrsagdlig ",
                   " where lignum    = ? "
 prepare s_datrdrscrsagdlig from sql_comando
 declare c_datrdrscrsagdlig cursor for s_datrdrscrsagdlig

 let arr_aux = 1
 message " Aguarde, pesquisando..."  attribute(reverse)


 if param.succod is not null  and
    param.ramcod is not null  and
    param.aplnumdig is not null  then
    let sql_comando = "select lignum            ",
                      "  from datrligapol       ",
                      " where succod    = ?  and",
                      "       ramcod    = ?  and",
                      "       aplnumdig = ?  and",
                      "       itmnumdig = ?     ",
                      " order by lignum         "
 else
    if param.prporg    is not null  and
       param.prpnumdig is not null  then
       let sql_comando = "select lignum            ",
                         "  from datrligprp        ",
                         " where prporg    = ?  and",
                         "       prpnumdig = ?     ",
                         " order by lignum         "
    else
       if param.fcapacorg is not null  and
          param.fcapacnum is not null  then
          let sql_comando = "select lignum            ",
                            "  from datrligpac        ",
                            " where fcapacorg = ?  and",
                            "       fcapacnum = ?     ",
                            " order by lignum         "
       else
          if param.crtsaunum is not null then
             let sql_comando = "select lignum      ",
                               "  from datrligsau  ",
                               " where crtnum  = ? ",
                               " order by lignum   "
          else
	     if g_pss.psscntcod is not null then
                let sql_comando = "select lignum        ",
                                  "  from datrcntlig    ",
                                  " where psscntcod = ? ",
                                  " order by lignum     "
             else
                if g_documento.cgccpfnum is not null and   ---> PortoSeg
                   g_documento.cgccpfdig is not null then
                   let sql_comando = "select lignum        ",
                                     "  from datrligcgccpf ",
                                     " where cgccpfnum = ? ",
                                     "   and cgcord    = ? ",
                                     "   and cgccpfdig = ? ",
                                     " order by lignum     "
                else
                   return
                end if
             end if
          end if
       end if
    end if
 end if

 prepare sel_ctp01m01 from sql_comando
 declare c_ctp01m01 cursor for sel_ctp01m01

 if param.succod is not null  and
    param.ramcod is not null  and
    param.aplnumdig is not null  then
    open c_ctp01m01 using param.succod   ,
                          param.ramcod   ,
                          param.aplnumdig,
                          param.itmnumdig
 else
    if param.prporg    is not null  and
       param.prpnumdig is not null  then
       open c_ctp01m01 using param.prporg,
                             param.prpnumdig
    else
       if param.fcapacorg is not null  and
          param.fcapacnum is not null  then
          open c_ctp01m01 using param.fcapacorg,
                                param.fcapacnum
       else
          if param.crtsaunum is not null then
             open c_ctp01m01 using param.crtsaunum
          else    
	     if g_pss.psscntcod is not null then ---> PSS
                open c_ctp01m01 using g_pss.psscntcod

             else    
                if g_documento.cgccpfnum is not null and  ---> PortoSeg
                   g_documento.cgccpfdig is not null then
                   open c_ctp01m01 using g_documento.cgccpfnum
                                        ,g_documento.cgcord
                                        ,g_documento.cgccpfdig
                end if
             end if
          end if
       end if
    end if
 end if

 foreach c_ctp01m01 into a_ctp01m01[arr_aux].lignum

    open  c_datmligacao using a_ctp01m01[arr_aux].lignum
    fetch c_datmligacao into  a_ctp01m01[arr_aux].ligdat   ,
                              a_ctp01m01[arr_aux].lighorinc,
                              ws.funmat                    ,
                              a_ctp01m01[arr_aux].c24solnom,
                              ws.c24soltipcod,
                              a_ctp01m01[arr_aux].c24astcod,
                              a_ctp01m01[arr_aux].c24paxnum

    if sqlca.sqlcode <> 0  then
       continue foreach
    end if

    close c_datmligacao


    #-----------------------------------------------------------------
    # Carrega tipo de solicitante
    #-----------------------------------------------------------------
    open  c_datksoltip  using ws.c24soltipcod
    fetch c_datksoltip  into  a_ctp01m01[arr_aux].c24soltipdes
    close c_datksoltip

    #---------------------------------------------------------------------
    # Verifica se codigo de assunto tem restricao de exibicao
    #---------------------------------------------------------------------
    if g_issk.acsnivcod  <  8   then
       initialize ws.c24astexbflg  to null

       open  c_datkassunto  using a_ctp01m01[arr_aux].c24astcod
       fetch c_datkassunto  into  ws.c24astexbflg
       close c_datkassunto

       if ws.c24astexbflg  =  "N"  then
          continue foreach
       end if
    end if

    #---------------------------------------------------------------------
    # Exibe situacao da reclamacao
    #---------------------------------------------------------------------

    #Busca agrupamento do assunto    ##psi230650
    open  c_c24astagp  using a_ctp01m01[arr_aux].c24astcod
    fetch c_c24astagp  into  ws.c24astagp
    close c_c24astagp

    #if a_ctp01m01[arr_aux].c24astcod[1,1] = "W" or
    #   a_ctp01m01[arr_aux].c24astcod[1,1] = "K" then
    if ws.c24astagp = "W" or
       ws.c24astagp = "K" then
       open  c_datmsitrecl  using a_ctp01m01[arr_aux].lignum
       fetch c_datmsitrecl  into  ws.c24rclsitcod
       if sqlca.sqlcode = 0  then
          let a_ctp01m01[arr_aux].atdetpdes = ""
          open  c_iddkdominio  using ws.c24rclsitcod
          fetch c_iddkdominio  into  a_ctp01m01[arr_aux].atdetpdes
          close c_iddkdominio
       end if
       close c_datmsitrecl
    end if

   #------------------------------------------------------------------
   # Exibe servico relacionado `a ligacao
   #------------------------------------------------------------------
    call cts20g00_ligacao(a_ctp01m01[arr_aux].lignum)
         returning a_ctp01m01[arr_aux].atdsrvnum,
                   a_ctp01m01[arr_aux].atdsrvano,
                   a_ctp01m01[arr_aux].sinvstnum,
                   a_ctp01m01[arr_aux].sinvstano,
                   a_ctp01m01[arr_aux].ramcod,
                   a_ctp01m01[arr_aux].sinavsnum,
                   a_ctp01m01[arr_aux].sinavsano,
                   a_ctp01m01[arr_aux].sinnum,
                   a_ctp01m01[arr_aux].sinano,
                   a_ctp01m01[arr_aux].vstagnnum,
                   a_ctp01m01[arr_aux].trpavbnum,
                   al_ctp01m01[arr_aux].cnslignum,    # PSI 172111
                   al_ctp01m01[arr_aux].crtsaunum,    ### PSI 202720
                   l_drscrsagdcod

    if a_ctp01m01[arr_aux].atdsrvnum is not null  and
       a_ctp01m01[arr_aux].atdsrvano is not null  then
       open  c_datmservico  using a_ctp01m01[arr_aux].atdsrvnum,
                                  a_ctp01m01[arr_aux].atdsrvano
       fetch c_datmservico  into  ws.atdsrvorg
       initialize  a_ctp01m01[arr_aux].srvtxt  to null
       let a_ctp01m01[arr_aux].srvtxt = ws.atdsrvorg using "&&", "/",
                                        a_ctp01m01[arr_aux].atdsrvnum  using "&&&&&&&", "-",
                                        a_ctp01m01[arr_aux].atdsrvano  using "&&"

       open  c_datmsrvacp  using a_ctp01m01[arr_aux].atdsrvnum,
                                 a_ctp01m01[arr_aux].atdsrvano,
                                 a_ctp01m01[arr_aux].atdsrvnum,
                                 a_ctp01m01[arr_aux].atdsrvano
       fetch c_datmsrvacp  into  ws.atdetpcod

       if sqlca.sqlcode = 0  then
          open  c_datketapa using ws.atdetpcod
          fetch c_datketapa into  a_ctp01m01[arr_aux].atdetpdes
          close c_datketapa
       end if

       close c_datmsrvacp
    end if

    if a_ctp01m01[arr_aux].sinvstnum is not null  and
       a_ctp01m01[arr_aux].sinvstano is not null  then
       initialize  a_ctp01m01[arr_aux].srvtxt  to null
       let a_ctp01m01[arr_aux].srvtxt = a_ctp01m01[arr_aux].sinvstnum  using "&&&&&&", "-",
                                        a_ctp01m01[arr_aux].sinvstano

       open  c_datmvstsincanc using a_ctp01m01[arr_aux].sinvstnum,
                                    a_ctp01m01[arr_aux].sinvstano
       fetch c_datmvstsincanc

       if sqlca.sqlcode = 0  then
          let a_ctp01m01[arr_aux].atdetpdes = "CANCELADA"
       end if

       close c_datmvstsincanc
    end if

    if a_ctp01m01[arr_aux].sinavsnum is not null  and
       a_ctp01m01[arr_aux].sinavsano is not null  then
       initialize  a_ctp01m01[arr_aux].srvtxt  to null
       let a_ctp01m01[arr_aux].srvtxt = a_ctp01m01[arr_aux].sinavsnum  using "&&&&&&", "-",
                                     a_ctp01m01[arr_aux].sinavsano
    end if

    if a_ctp01m01[arr_aux].sinnum is not null  and
       a_ctp01m01[arr_aux].sinano is not null  then
       let a_ctp01m01[arr_aux].srvtxt = a_ctp01m01[arr_aux].sinnum  using "&&&&&&", "-",
                                     a_ctp01m01[arr_aux].sinano
    end if
    if a_ctp01m01[arr_aux].vstagnnum is not null then
       open c_datrligagn using a_ctp01m01[arr_aux].lignum
       foreach c_datrligagn into ws.vstagnnum,
                                 ws.vstagnstt
       end foreach
       let a_ctp01m01[arr_aux].srvtxt = ws.vstagnnum using "&&&&&&"
       if ws.vstagnstt = "C"   then
          let a_ctp01m01[arr_aux].atdetpdes = "CANCELADA"
       else
          let a_ctp01m01[arr_aux].atdetpdes = "AGENDADO"
       end if
    end if
    
    ---> Status/Nro.Agendamento do Curso de Direcao Defensiva
    if l_drscrsagdcod is not null then
       open c_datrdrscrsagdlig using a_ctp01m01[arr_aux].lignum
       foreach c_datrdrscrsagdlig into ws.vstagnnum,
                                       ws.vstagnstt
       end foreach
       let a_ctp01m01[arr_aux].srvtxt = ws.vstagnnum using "&&&&&&"
       if ws.vstagnstt = "C"   then
          let a_ctp01m01[arr_aux].atdetpdes = "CANCELADO"
       else
          let a_ctp01m01[arr_aux].atdetpdes = "AGENDADO"
       end if
    end if
    
    # --- PSI 172111 - Inicio ---
    
    if al_ctp01m01[arr_aux].cnslignum is not null then
       
       open  cctp01m01001   using al_ctp01m01[arr_aux].cnslignum
       whenever error continue
       fetch cctp01m01001   into l_c24astcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             error 'Erro SELECT datmligacao ',sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 3
             error 'ctp01m01()/',al_ctp01m01[arr_aux].cnslignum  sleep 3
             let l_erro = true
             exit foreach
          end if
       end if
       
       let l_param1 = al_ctp01m01[arr_aux].cnslignum       
       let a_ctp01m01[arr_aux].srvtxt = l_param1 clipped, "-", l_c24astcod clipped
    
    end if

    ### PSI 202720
    if al_ctp01m01[arr_aux].crtsaunum is not null then
    end if
    
    # --- PSI 172111 - Final ---
    
    #---------------------------------------------------------------------
    # Nome do atendente
    #---------------------------------------------------------------------
    let a_ctp01m01[arr_aux].funnom = "NAO CADASTR."

    open  c_isskfunc using ws.funmat
    fetch c_isskfunc into  a_ctp01m01[arr_aux].funnom
    close c_isskfunc

    let a_ctp01m01[arr_aux].funnom = upshift(a_ctp01m01[arr_aux].funnom)

    #---------------------------------------------------------------------
    # Verifica se houve envio de mensagem para corretor
    #---------------------------------------------------------------------
    open  c_datrligmens  using a_ctp01m01[arr_aux].lignum
    fetch c_datrligmens
    if sqlca.sqlcode = 0  then
       let a_ctp01m01[arr_aux].msgenv = "S"
    else
       initialize a_ctp01m01[arr_aux].msgenv to null
    end if
    close c_datrligmens

    #---------------------------------------------------------------------
    # Monta descricao do assunto
    #---------------------------------------------------------------------
    call c24geral8(a_ctp01m01[arr_aux].c24astcod)
         returning a_ctp01m01[arr_aux].c24astdes

    let arr_aux = arr_aux + 1
    if arr_aux > 100 then
       error " Limite excedido. Consulta com mais de 100 ligacoes!"
       exit foreach
    end if

 end foreach
 
 # --- PSI 172111 - Inicio ---
 
 if l_erro then
    let int_flag = false
    close window ctp01m01
    return
 end if
 
 # --- PSI 172111 - Final ---

 message " (F17)Abandona, (F7)Historico"

 if arr_aux = 1   then
    error " Nao existem ligacoes para esta consulta!"
 end if

 call set_count(arr_aux - 1)

 display array a_ctp01m01 to s_ctp01m01.*
    on key (interrupt,control-c)
       initialize a_ctp01m01   to null
       exit display

    #---------------------------------------------------------------------
    # Chama historico da ligacao
    #---------------------------------------------------------------------
    on key (F7)
       error ""
       let arr_aux = arr_curr()

       if a_ctp01m01[arr_aux].atdsrvnum is not null  and
          a_ctp01m01[arr_aux].atdsrvano is not null  then
          open  c_datmlimpeza using a_ctp01m01[arr_aux].atdsrvnum,
                                    a_ctp01m01[arr_aux].atdsrvano
          fetch c_datmlimpeza

          if sqlca.sqlcode = 0  then
             error " Servico ja' foi removido pelo sistema!"
          else
             call cts10n00(a_ctp01m01[arr_aux].atdsrvnum,
                           a_ctp01m01[arr_aux].atdsrvano,
                           g_issk.funmat, ws.data, ws.hora)
          end if

          close c_datmlimpeza
       end if

       if a_ctp01m01[arr_aux].sinvstnum is not null  and
          a_ctp01m01[arr_aux].sinvstano is not null  then
          if a_ctp01m01[arr_aux].ramcod = 31  or  
             a_ctp01m01[arr_aux].ramcod = 531 then
             call cts14m10(a_ctp01m01[arr_aux].sinvstnum,
                           a_ctp01m01[arr_aux].sinvstano,
                           g_issk.funmat, ws.data, ws.hora)
          end if
       end if

       if a_ctp01m01[arr_aux].sinavsnum is not null  and
          a_ctp01m01[arr_aux].sinavsano is not null  then
          call cts18n04 (a_ctp01m01[arr_aux].sinavsnum,
                         a_ctp01m01[arr_aux].sinavsano)
       end if

       # --- PSI 172111 - Inicio ---

       if al_ctp01m01[arr_aux].cnslignum is not null then
          call cta03n00(al_ctp01m01[arr_aux].cnslignum,
                        g_issk.funmat,
                        ws.data,
                        ws.hora)
       else
          call cta03n00(a_ctp01m01[arr_aux].lignum,
                        g_issk.funmat,
                        ws.data,
                        ws.hora)
       end if
       
       # --- PSI 172111 - Final ---

 end display

 let int_flag = false
 close window ctp01m01

end function  ###  ctp01m01
