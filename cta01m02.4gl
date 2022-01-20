#############################################################################
# Nome do Modulo: CTA01M02                                         Marcelo  #
#                                                                  Gilberto #
# Clausulas da apolice de automovel                                Jul/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 20/10/1999               Gilberto     Alterar acesso ao cadastro de clau- #
#                                       sulas e descricao do socorro meca-  #
#                                       nico para convenios.                #
#---------------------------------------------------------------------------#
# 26/05/2000  PSI 10860-0  Akio         Exibir as franquias de vidros       #
#                                       clausulas 071 e X71                 #
#---------------------------------------------------------------------------#
# 10/10/2001  PSI 14063-5  Wagner       Liberacao clausulas 34A e 35A.      #
#---------------------------------------------------------------------------#
# 26/11/2001  PSI 14099-6  Ruiz         Msg de alerta para clscod=96.       #
#---------------------------------------------------------------------------#
# 27/03/2002  PSI 14131-8  Raji         Visualiza textos para clausula.     #
#---------------------------------------------------------------------------#
# 27/05/2002  PSI 15418-0  Ruiz         Alerta da cobranca.                 #
#---------------------------------------------------------------------------#
# 11/09/2002  PSI 16073-3  Ruiz         Consulta ao corretor(F4).           #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Henrique Pezella                 OSF : 9377             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 19/11/2002       #
#  Objetivo       : Aprimoramento da clausula 71-Danos aos vidros atraves   #
#                   da clausula 75(contem clausula 71 + espelho retrovisor) #
#  Analista Resp. : Ruiz                             OSF/PSI : 22810/176087 #
#  Por            : FABRICA DE SOFTWARE, Amaury      Data: 03/07/2003       #
#  Objetivo       : Informar o atendente os beneficios da apolice que esta  #
#                   sendo prestado o atendimento.                           #
#  Analista Resp. : Ligia Mattge                     OSF/PSI : 23787/173894 #
#  Por            : FABRICA DE SOFTWARE, Ronaldo Mar Data: 22/07/2003       #
#  Objetivo       : Quando f1, pegar dados no banco e chamar o ctg17.4gi    #
#                   atraves do roda_prog.                                   #
#---------------------------------------------------------------------------#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -------------------------------------#
# 24/11/2003  Paulo, Meta    PSI172057 Incluir item na lista de opcoes do   #
#                            OSF 28991 menu (F1) funcoes                    #
#---------------------------------------------------------------------------#
# 05/01/2004  PSI 181617 / OSF 29904 . Amaury (FSW). Tarifa de Jan/2004     #
#---------------------------------------------------------------------------#
# 30/06/2004  CT 221767                JUNIOR (FSW)  Alteracao de parte do  #
#                                                    modulo (linha 482)     #
#---------------------------------------------------------------------------#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- -------------------------------------#
# 23/07/2004  Marcio Meta    PSI186376 Incluir a chamda da funcao cta01m10()#
# ----------  -------------- --------- -------------------------------------#
#                            OSF038105 com a tecla (F1).                    #
# 16/11/2006  Ligia Mattge   PSI205206 ciaempcod                            #
#---------------------------------------------------------------------------#
# 02/11/2008  Carla Rampazzo PSI230650 Confirmar dados do cliente           #
#---------------------------------------------------------------------------#
# 07/11/2008 Amilton, Meta   Psi223689_2 Verificar status das intancias     #
#                                         evitando indisponilidade total    #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
define m_hostname       char(12) # PSI223689_2 - Amilton
define m_server         char(05) # PSI223689_2 - Amilton

#------------------------------------------------------------------------------
 function cta01m02(param)
#------------------------------------------------------------------------------
 define param      record
    cvnnum         like abamapol.cvnnum,
    clcdat         like abbmcasco.clcdat,
    ctgtrfcod      like abbmcasco.ctgtrfcod,
    clalclcod      like abbmdoc.clalclcod,
    frqclacod      like abbmcasco.frqclacod,
    edsviginc      like abbmdoc.viginc,
    edsvigfnl      like abbmdoc.vigfnl,
    autrevflg      char (01),
    plcincflg      smallint,
    cbtcod         like abbmcasco.cbtcod  ,
    vclmrccod      like agbkveic.vclmrccod,
    vcltipcod      like agbkveic.vcltipcod,
    vclcoddig      like agbkveic.vclcoddig,
    vclanomdl      like abbmveic.vclanomdl,
    vclcircid      like abbmdoc.vclcircid
 end record

 define a_cta01m02 array[20] of record
    clscod         like aackcls.clscod,
    clsdes         like aackcls.clsdes
 end record

 define ws         record
    tabnum         like itatvig.tabnum,
    clsdes         like aackcls.clsdes,
    edsviginc      like abbmdoc.viginc,
    clsviginc      like abbmclaus.viginc,
    confirma       char (01),
    ret            integer,
    frqvidro       like abbmclaus.clscod,
    ofnnumdig      like datmlcl.ofnnumdig,
    lclidttxt      like datmlcl.lclidttxt,
    lgdnom         like datmlcl.lgdnom,
    lclbrrnom      like datmlcl.lclbrrnom,
    cidnom         like datmlcl.cidnom,
    ufdcod         like datmlcl.ufdcod,
    lgdcep         like datmlcl.lgdcep,
    lgdcepcmp      like datmlcl.lgdcepcmp,
    ok             char(01),
    msg1           char(20),
    clscod96       like abbmclaus.clscod,
    flgIS096       char(01),
    grlchv         like datkgeral.grlchv,
    grlinf         like datkgeral.grlinf,
    count          integer,
    titnumdig      like fctmtitulos.titnumdig,
    cobtip         like fctmtitulos.cobtip,
    corsus         like gcaksusep.corsus
 end record

 define d_cta01m02 record
    a   char (1)
 end record

 define arr_aux    smallint
 define l_acesso   smallint

 define ret_clscod char(3)

 define l_ctx14g00 record
        opcao      smallint
       ,opcaodes   char(20)
 end record

 define l_seg           record
        segnom          like gsakseg.segnom,
        pestip          like gsakseg.pestip,
        cgccpfnum       like gsakseg.cgccpfnum,
        cgcord          like gsakseg.cgcord,
        cgccpfdig       like gsakseg.cgccpfdig
 end    record

 define l_sqlca         smallint,
        l_sqler         smallint,
        l_seggernumdig  like gsarsegger.seggernumdig,
        l_comando       char(1000),
        l_status        smallint,
        l_lixo          char(10),
        l_segnumdig     like gsakseg.segnumdig,
        l_confirma      char(01),
        l_st_erro       smallint

define lr_retorno   record
       data_calculo date,
       flag_endosso char(01),
       erro         integer,
       clausula     like abbmclaus.clscod
end record
define perfil char (50)
 define l_arr   array[10] of record l   char(40) end record

        define  w_pf1   integer

 ### Inicio PSI172057 - Paulo
 ###
 define l_param1    char(07)
       ,l_param2    char(61)
       ,l_param3    smallint
  # Auto + RE
  define l_qtd_bas integer,
         l_qtd_bra integer,
         l_clscod  like abbmclaus.clscod

 define w_arg_val_fixos   char(200)  ## psi201154
 define w_comando         char(1000) ## psi201154
 define wg_issparam       char(30)   ## psi201154
 define wg_docto          char(30)     ## Alberto
 define l_msg             char(100)
 # Auto + RE
 initialize  l_qtd_bas, l_qtd_bra, l_clscod to null

 let l_param1 = "FUNCOES"
 let l_param2 = "Clientes|Auto_ct|Con_ct|Procedimentos|Carta_Transf_Corretagem"
 let l_param3 = 0
 let l_st_erro = 1 # psi223689_2
 ###
 ### Final PSI172057 - Paulo

 let w_arg_val_fixos   =  null    ## psi201154
 let w_comando         =  null    ## psi201154
 let wg_issparam       =  null    ## psi201154
 let wg_docto          = " "       ## alberto
 let perfil = ""

        let     arr_aux  =  null
        let     ret_clscod  =  null

        for     w_pf1  =  1  to  20
                initialize  a_cta01m02[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

        initialize  d_cta01m02.*,lr_retorno.*  to  null

 initialize a_cta01m02  to null
 initialize ws.*        to null

 # Auto + RE

 declare c_abbmclaus cursor for
    select clscod, viginc
      from abbmclaus
     where succod    = g_documento.succod     and
           aplnumdig = g_documento.aplnumdig  and
           itmnumdig = g_documento.itmnumdig  and
           dctnumseq = g_funapol.dctnumseq

 let arr_aux = 1

 whenever error continue
 let ws.frqvidro = null

 foreach c_abbmclaus into a_cta01m02[arr_aux].clscod,
                          ws.clsviginc
 # Auto + RE
 if a_cta01m02[arr_aux].clscod = "033"  or
    a_cta01m02[arr_aux].clscod = "034"  or
    a_cta01m02[arr_aux].clscod = "035"  or
    a_cta01m02[arr_aux].clscod = "34A"  or
    a_cta01m02[arr_aux].clscod = "35A"  or
    a_cta01m02[arr_aux].clscod = "35R"  or
    a_cta01m02[arr_aux].clscod = "047"  then
    let l_clscod = a_cta01m02[arr_aux].clscod
 end if

  if a_cta01m02[arr_aux].clscod = "034" or
     a_cta01m02[arr_aux].clscod = "071" or
     a_cta01m02[arr_aux].clscod = "077" then # PSI 239.399 Clausula 77
    if cta13m00_verifica_clausula(g_documento.succod        ,
                                  g_documento.aplnumdig     ,
                                  g_documento.itmnumdig     ,
                                  g_funapol.dctnumseq ,
                                  a_cta01m02[arr_aux].clscod           ) then

     continue foreach
    end if
  end if


    if a_cta01m02[arr_aux].clscod = "111"  then
       let a_cta01m02[arr_aux].clsdes = "R.C. EXTENSIVA FRANQUIA OBRIGATORIA"
    else
       if ws.clsviginc is null  or
          ws.clsviginc = "31/12/1899"  then
          let ws.clsviginc = param.clcdat
       end if

       let a_cta01m02[arr_aux].clsdes = "** NAO CADASTRADA **"

       ## CONFORME CONVERSA C/CRISTINA COELHO, DEVEMOS UTILIZAR A
       ## DATA DE CALCULO DA APOLICE P/BUSCAR A DESCRICAO DA CLAUSULA
       ## DATA DA ALTERACAO: 13/09/2006    AUTORES: LUCAS E RUIZ
       ### let ws.tabnum = F_FUNGERAL_TABNUM("aackcls", ws.clsviginc)

       let ws.tabnum = F_FUNGERAL_TABNUM("aackcls", param.clcdat)

       select clsdes
         into a_cta01m02[arr_aux].clsdes
         from aackcls
        where tabnum = ws.tabnum
          and ramcod = g_documento.ramcod
          and clscod = a_cta01m02[arr_aux].clscod

       if param.cvnnum <> 0  then
          if a_cta01m02[arr_aux].clscod = "034"  or
             a_cta01m02[arr_aux].clscod = "035"  or
             a_cta01m02[arr_aux].clscod = "34A"  or
             a_cta01m02[arr_aux].clscod = "35A"  or
             a_cta01m02[arr_aux].clscod = "35R"  then
             select cvn035des
               into ws.clsdes
               from akckconvenio
              where cvnnum = param.cvnnum

             let ws.clsdes = ws.clsdes clipped

             if ws.clsdes is not null  then
                let a_cta01m02[arr_aux].clsdes = ws.clsdes clipped, " (",
                    a_cta01m02[arr_aux].clsdes[15,40] clipped, ")"
             end if
          end if
       end if

       if ws.frqvidro is null  then
          if a_cta01m02[arr_aux].clscod = "071" then
             let ws.frqvidro  =  "071"
          end if

         ## -- OSF 9377 - Fabrica de Software, Katiucia -- #
          if a_cta01m02[arr_aux].clscod = "075" then
             let ws.frqvidro = "075"
          else
             if a_cta01m02[arr_aux].clscod = "75R" then
                let ws.frqvidro = "75R"
             else
                if a_cta01m02[arr_aux].clscod = "076" then
                   let ws.frqvidro = "076"
                else
                   if a_cta01m02[arr_aux].clscod = "76R" then
                      let ws.frqvidro = "76R"
                   else
                      if a_cta01m02[arr_aux].clscod = "077" then # PSI 239.399 Clausula 77
                         let g_vdr_blindado = "S"
                         let ws.frqvidro  =  "077"
                      end if
                   end if
                end if
             end if
          end if
       end if

       if ws.clscod96 is null then
          if a_cta01m02[arr_aux].clscod = "096"  then
             let ws.clscod96 = "096"
          end if
       end if
    end if
    let a_cta01m02[arr_aux].clsdes = upshift(a_cta01m02[arr_aux].clsdes)
    let arr_aux = arr_aux + 1
 end foreach

 whenever error stop

 if sqlca.sqlcode < 0  then
    error "Informacoes sobre CLAUSULAS nao disponiveis no momento!"
    let a_cta01m02[2].clscod = "***"
    let a_cta01m02[2].clsdes = "SEM CONSULTA NO MOMENTO ***"
    let arr_aux = 3
 end if

 if arr_aux = 1  then
    let a_cta01m02[2].clscod = "***"
    let a_cta01m02[2].clsdes = "NENHUMA CLAUSULA  ***"
    let arr_aux = 3
 end if
 #-----------------------------------------------------------
 # Verifica se usuario tem acesso ao Con_ct24h
 #-----------------------------------------------------------
 message "(F6)Proced,(F7)IS,(F8)Aces,(F9)Parcela,(F10)OutrasInf"

 call cta00m06_acesso_espelho(g_issk.dptsgl)
 returning l_acesso

 if l_acesso = true then
    whenever error continue
    message "(F1)Funcoes(F4)Corr(F5)Historico(F7)IS(F8)Aces(F9)Parc(F10)OutInf"
    whenever error stop

    #-----------------------------------------------------------
    # Verifica se existe ligacao para advertencia ao atendente
    #-----------------------------------------------------------

    call cta01m09(g_documento.succod,
                  g_documento.ramcod,
                  g_documento.aplnumdig,
                  g_documento.itmnumdig)
 end if
 # Auto + RE
 let l_qtd_bas = 0
 let l_qtd_bra = 0

 call framo705_qtd_servicos(l_clscod,
                            g_documento.succod,
                            g_documento.ramcod,
                            g_documento.aplnumdig )
 returning l_qtd_bas, l_qtd_bra
 if ( l_qtd_bas + l_qtd_bra ) > 0 then
    call cts08g01("A","N","","Venda Sincronizada Auto + RE ","","")
    returning ws.confirma
 end if
 if ws.clscod96 = "096" then
    call fsgmc001(g_documento.succod,
                  g_documento.ramcod,
                  g_documento.aplnumdig)
        returning g_documento.flgIS096
    if g_documento.aplnumdig = 19076688 or
       g_documento.aplnumdig = 19076700 then
       let g_documento.flgIS096 = "S"
    end if
    if g_documento.flgIS096 = "S"  then
       call cts08g01("A","N",
                     "O Valor da IS da Clausula 096 Garantia  ",
                     "Mecanica esta esgotado, caso nao se     ",
                     "trate de atendimento pela Clausula      ",
                     "desconsidere esta informacao.")
           returning ws.confirma
    end if
 end if    
 
    #Perfil - Tarifa Dezembro 2013
     call cty31g00_recupera_perfil (g_documento.succod
                                   ,g_documento.aplnumdig
                                   ,g_documento.itmnumdig)
         returning g_nova.perfil,
                   g_nova.clscod    ,
                   g_nova.dt_cal    ,
                   g_nova.vcl0kmflg ,
                   g_nova.imsvlr    ,
                   g_nova.ctgtrfcod ,  
                   g_nova.clalclcod ,
                   g_nova.dctsgmcod ,
                   g_nova.clisgmcod                       
              
        if cty31g00_valida_data()     and
           cty31g00_valida_perfil()   and
           cty31g00_valida_clausula() then
       
           call cty31g00_descricao_segmento(g_nova.perfil)
           returning perfil
              
        end if
 
 
 
 open window cta01m02 at 15,02 with form "cta01m02"
                      attribute(form line first)

 let m_hostname = null

  call cta13m00_verifica_status(m_hostname)
      returning l_st_erro,l_msg


 call set_count(arr_aux - 1)

    if g_nova.dt_cal >= "01/02/2014" and
       perfil  is not null then
        display by name perfil attribute (reverse)
    end if
      display array a_cta01m02 to s_cta01m02.*

    #PSI 176087
    #-----------------------------------------------------------------#

    on key (F1) ### Funcoes                                   # Marcio Meta PSI186376
       let m_hostname = null
       call cta13m00_verifica_status(m_hostname)
       returning l_st_erro,l_msg

       if l_st_erro = true then
       call cta01m10_auto(g_documento.ramcod,
                          g_documento.succod,
                          g_documento.aplnumdig,
                          g_documento.itmnumdig,
                          g_funapol.dctnumseq,
                          g_documento.prporg,
                          g_documento.prpnumdig,
                          param.cvnnum,
                          0)
       else
          error "Tecla F1 não disponivel no momento ! ",l_msg ," ! Avise a Informatica "
          sleep 2
       end if

    on key (F4)
     let m_hostname = null
     call cta13m00_verifica_instancias_u37()
       returning l_st_erro,l_msg

     if l_st_erro = true then
       select corsus into ws.corsus
         from abamcor
         where succod    = g_documento.succod         and
               aplnumdig = g_documento.aplnumdig      and
               corlidflg = "S"

       call ctn09c00(ws.corsus)
     else
       error "Tecla F4 não disponivel no momento ! ",l_msg ," ! Avise a Informatica "
       sleep 2
     end if

    on key (F5)  ### psi201154
     let m_hostname = null
     call cta13m00_verifica_status(m_hostname)
       returning l_st_erro,l_msg

      if l_st_erro = true then
       call get_param()

       let wg_docto = g_documento.succod using "&&"
       let wg_docto = wg_docto clipped, g_documento.aplnumdig using "&&&&&&&&&"
       let wg_docto = wg_docto clipped, g_documento.itmnumdig using "&&&&&&&"

       let wg_issparam = wg_docto

       let w_arg_val_fixos =
       "'",arg_val(01),"' ", "'",arg_val(02),"' ", "'",arg_val(03),"' ",
       "'",arg_val(04),"' ", "'",arg_val(05),"' ", "'",arg_val(06),"' ",
       "'",arg_val(07),"' ", "'",arg_val(08),"' ", "'",arg_val(09),"' ",
       "'",arg_val(10),"' ", "'",arg_val(11),"' ", "'",arg_val(12),"' ",
       "'",arg_val(13),"' ", "'",arg_val(14),"' ", "'",wg_issparam ,"' ",
       "'",arg_val(16),"' ", "'","vago"     ,"' ", "'","vago"     ,"' ",
       "'","vago"     ,"' ", "'","vago"     ,"' "
       #let w_comando =  "novofglgo abs ", w_arg_val_fixos
       #run w_comando

       call roda_prog("abs", w_arg_val_fixos, 1)
            returning l_status

       if l_status = -1 then
          error "Sistema nao disponivel no momento."
          sleep 2
       end if
      else
        error "Tecla F5 não disponivel no momento ! ",l_msg , " ! Avise a Informatica "
        sleep 2
      end if

    on key (F6)  ###  Procedimentos Operacionais
     let m_hostname = null
     call cta13m00_verifica_status(m_hostname)
       returning l_st_erro,l_msg

       if l_st_erro = true then
       call ctn13c00(param.cvnnum)
       else
        error "Tecla F6 não disponivel no momento !",l_msg ," ! Avise a Informatica "
        sleep 2
      end if

    on key (F7)  ###  Importancias Seguradas
     let m_hostname = null
     call cta13m00_verifica_status(m_hostname)
       returning l_st_erro,l_msg

      if l_st_erro = true then
       call cta01m05( param.clcdat,
                      param.cvnnum,
                      param.cbtcod,
                      param.ctgtrfcod,
                      param.clalclcod,
                      param.vclmrccod,
                      param.vcltipcod,
                      param.vclcoddig,
                      param.vclanomdl,
                      ws.frqvidro     )
      else
        error "Tecla F7 não disponivel no momento !",l_msg ," ! Avise a Informatica "
        sleep 2
      end if

    on key (F8)  ###  Acessorios
     let m_hostname = null
     call cta13m00_verifica_status(m_hostname)
       returning l_st_erro,l_msg

       if l_st_erro = true then
       call cta01m01()
       else
          error "Tecla F8 não disponivel no momento !", l_msg ," ! Avise a Informatica "
          sleep 2
       end if

    on key (F9)  ###  Parcelas
     let m_hostname = null
     call cta13m00_verifica_status(m_hostname)
       returning l_st_erro,l_msg

       if l_st_erro = true then
       call cta01m06(g_documento.succod,
                     g_documento.ramcod,
                     00,
                     g_documento.aplnumdig)
       else
          error "Tecla F9 não disponivel no momento !",l_msg , " ! Avise a Informatica "
          sleep 2
       end if

    on key (F10) ###  Outras Informacoes
     let m_hostname = null
     call cta13m00_verifica_status(m_hostname)
       returning l_st_erro,l_msg

       if l_st_erro = true then
       call cta01m04(param.clcdat thru param.autrevflg)
       else
         error "Tecla F10 não disponivel no momento !",l_msg ," ! Avise a Informatica "
         sleep 2
       end if

    on key (interrupt,control-c)
       if param.plcincflg = true  then
          call cts08g01("A","N","","DOCUMENTO NAO POSSUI PLACA",
                                   "DO VEICULO CADASTRADA!","")
               returning ws.confirma
       end if

       if g_documento.atdnum is null or
          g_documento.atdnum =  0    then

          initialize l_confirma to null

          while l_confirma = "N"      or
             l_confirma = " "      or
             l_confirma is null
             call cts08g01("A","S",""
                          ,"CONFIRMOU OS DADOS DO CLIENTE ? "
                          ,"","")
                  returning l_confirma
          end while
       end if
       exit display

    on key (return)
       let arr_aux = arr_curr()
       let ret_clscod = a_cta01m02[arr_aux].clscod

       call ctc56m03(g_documento.ciaempcod, g_documento.ramcod,0,ret_clscod)

 end display

 close window cta01m02

end function  ###  cta01m02

#------------------------------------------------------------------------------
function cta01m02_sqlcode(l_sql,l_tabela)
#------------------------------------------------------------------------------

  define l_sql    char(01)
        ,l_tabela char(20)
        ,l_sqldes char(20)

  case l_sql
     when "D"  let l_sqldes = "declare"
     when "S"  let l_sqldes = "selecao"
  end case

  let l_tabela = upshift(l_tabela)

  if sqlca.sqlcode <> 0 and sqlca.sqlcode <> NOTFOUND then
     error "Erro ",sqlca.sqlcode using "<<<<<&"
          ," na (",l_sqldes clipped,") da tabela (",l_tabela clipped,"). "
          ," ISAM = ",sqlca.sqlerrd[2]  using "<<<<<<&"
     return 1
  end if

  return 0

end function  -------------------------------------> _sqlcode

