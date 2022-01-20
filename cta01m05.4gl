#############################################################################
#  Nome do Modulo: CTA01M05                                        Marcelo  #
#                                                                  Gilberto #
#  Consulta importancias seguradas                                 Jul/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 26/05/2000  PSI 10860-0  Akio         Exibir as franquias de vidros       #
#                                       clausulas 071 e X71                 #
#---------------------------------------------------------------------------#
# 28/11/2000  PSI 11831-1  Ruiz         Exibir franquia Auto+Vida           #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Henrique Pezella                 OSF : 9377             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 19/11/2002       #
#  Objetivo       : Aprimoramento da clausula 71-Danos aos vidros atraves   #
#                   da clausula 75(contem clausula 71 + espelho retrovisor) #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

 define d_cta01m05 record
    imsmda         like abamdoc.imsmda,
    mdacottxt      char (14),
    mdacotvlr      like gfatmda.mdacotvlr,
    autimsvlr      like abbmcasco.imsvlr,
    imsvlr         like abbmbli.imsvlr,   # valor blindagem
    dmtimsvlr      like abbmdm.imsvlr,
    dpsimsvlr      like abbmdp.imsvlr,
    imsmorvlr      like abbmapp.imsmorvlr,
    imsinvvlr      like abbmapp.imsinvvlr,
    imsdmhvlr      like abbmapp.imsdmhvlr,
    dmtniv         like abbmdm.imsniv,
    dpsniv         like abbmdp.imsniv,
    frqobrtxt      char (11),
    dmtfrqtxt      char (11),
    dpsfrqtxt      char (11),
    frqobrvlr      like abbmcasco.frqvlr,
    dmtobrvlr      like abbmdm.frqvlr,
    dpsobrvlr      like abbmdp.frqvlr,
    bonclacod      like abbmdoc.bonclacod,
    bondscper      like acatbon.bondscper,
    frqpbr         decimal(14,2),
    frqvig         decimal(14,2),
    frqlat         decimal(14,2),
    frqrtr         decimal(14,2),
    frqfarol       decimal(14,2),
    veiblitxt      char(40),
    texto1         char(34),
    frqvlr         decimal(14,2),
    frqdsc         decimal(14,2),
    orrdat         date,
    sinnum         like ssamsin.sinnum,
    texto          char(25),
    dthoje         date,
    frqhoje        decimal(14,2),
    classcod       like abbmdoc.bonclacod,
    classper       like acatbon.bondscper,
    classvlr       like abbmdp.frqvlr
 end record

define m_host       like ibpkdbspace.srvnom
define m_prep_sql   smallint
#---------------------------------------------
function cta01m05_prepare()
#---------------------------------------------
define l_sql      char(500)

  let l_sql = " select imsvlr       "
             ,"  from porto@",m_host clipped,":abbmbli "
             ," where succod = ?    "
             ,"  and  aplnumdig = ? "
             ,"  and  itmnumdig = ? "
             ,"  and  dctnumseq = ? "
  prepare pcta01m05001 from l_sql
  declare ccta01m05001 cursor with hold for pcta01m05001
  let l_sql = " select cbtstt              "
              ,"       ,pandifvlr           "
              ,"  from porto@",m_host clipped,":abbmvida2 "
              ," where succod = ?           "
              ,"   and aplnumdig = ?        "
              ,"   and itmnumdig = ?        "
              ,"   and dctnumseq = (select max(dctnumseq) "
              ,"                      from porto@",m_host clipped,":abbmvida2 "
              ,"                     where succod = ?     "
              ,"                       and aplnumdig = ?  "
              ,"                       and itmnumdig = ? )"
   prepare pcta01m05002 from l_sql
   declare ccta01m05002 cursor with hold for pcta01m05002
   let l_sql = " select imsinvvlr      "
              ,"       ,imsmorvlr      "
              ,"       ,imsdmhvlr      "
              ,"   from porto@",m_host clipped,":abbmapp "
              ,"  where succod = ?     "
              ,"    and aplnumdig = ?  "
              ,"    and itmnumdig = ?  "
              ,"    and dctnumseq = ?  "
   prepare pcta01m05003 from l_sql
   declare ccta01m05003 cursor with hold for pcta01m05003
   let m_prep_sql = true
end function


#------------------------------------------------------------------------------
 function cta01m05(param)
#------------------------------------------------------------------------------

 define param      record
    clcdat         like abbmcasco.clcdat,
    cvnnum         like abamapol.cvnnum,
    cbtcod         like abbmcasco.cbtcod  ,
    ctgtrfcod      like abbmcasco.ctgtrfcod,
    clalclcod      like abbmdoc.clalclcod,
    vclmrccod      like agbkveic.vclmrccod,
    vcltipcod      like agbkveic.vcltipcod,
    vclcoddig      like agbkveic.vclcoddig,
    vclanomdl      like abbmveic.vclanomdl,
    frqvidro       like abbmclaus.clscod
 end record

 # -- OSF 9377 - Fabrica de Software, Katiucia -- #
 #define d_cta01m05 record
 #   imsmda         like abamdoc.imsmda,
 #   mdacottxt      char (14),
 #   mdacotvlr      like gfatmda.mdacotvlr,
 #   autimsvlr      like abbmcasco.imsvlr,
 #   imsvlr         like abbmbli.imsvlr,   # valor blindagem
 #   dmtimsvlr      like abbmdm.imsvlr,
 #   dpsimsvlr      like abbmdp.imsvlr,
 #   imsmorvlr      like abbmapp.imsmorvlr,
 #   imsinvvlr      like abbmapp.imsinvvlr,
 #   imsdmhvlr      like abbmapp.imsdmhvlr,
 #   dmtniv         like abbmdm.imsniv,
 #   dpsniv         like abbmdp.imsniv,
 #   frqobrtxt      char (11),
 #   dmtfrqtxt      char (11),
 #   dpsfrqtxt      char (11),
 #   frqobrvlr      like abbmcasco.frqvlr,
 #   dmtobrvlr      like abbmdm.frqvlr,
 #   dpsobrvlr      like abbmdp.frqvlr,
 #   bonclacod      like abbmdoc.bonclacod,
 #   bondscper      like acatbon.bondscper,
 #   frqpbr         decimal(14,2),
 #   frqvig         decimal(14,2),
 #   frqlat         decimal(14,2),
 #   frqrtr         decimal(14,2),
 #   frqfarol       decimal(14,2),
 #   texto1         char(34),
 #   frqvlr         decimal(14,2),
 #   frqdsc         decimal(14,2),
 #   orrdat         date,
 #   sinnum         like ssamsin.sinnum,
 #   texto          char(25),
 #   dthoje         date,
 #   frqhoje        decimal(14,2),
 #   classcod       like abbmdoc.bonclacod,
 #   classper       like acatbon.bondscper,
 #   classvlr       like abbmdp.frqvlr
 #end record

 define w_aggclsvl   record
        clscndvlr    like aacmclscnd.clscndvlr   ,
        clscndreivlr like aacmclscnd.clscndreivlr,
        frqvlr       like aacmclscnd.frqvlr
 end record

 define ws         record
    tabnum         smallint,
    viginc         like abbmdoc.viginc,
    viginc1        like abbmdoc.viginc,
    viginc2        like abbmdoc.viginc,
    edsstt         like abamdoc.edsstt,
    dctnumseq      like abamdoc.dctnumseq,
    frqclacod      like abbmcasco.frqclacod,
    dmtfrqcla      like abbmdm.frqclacod,
    dpsfrqcla      like abbmdp.frqclacod,
    clalclcod      like abbmdoc.clalclcod,
    sinano         like ssamitem.sinano,
    sinnum         like ssamitem.sinnum,
    orrdat         like ssamsin.orrdat,
    cbtstt         like abbmvida2.cbtstt,
    pandifvlr      like abbmvida2.pandifvlr,
    temsinis       char(01),
    cpocod         smallint,
    cpodes         char(50)
 end record

 define l_abrir char(01) # PSI 239.399 Clausula 077
 define prompt_key char (01)
 define l_nulo char(40)   # PSI 239.399 Clausula 077
 define l_confirma char(1)
 define l_confirma1 char(1)
 define l_msg1, l_msg2, l_msg3 char(50)
 define l_st_erro  smallint,
        l_msg      char(100)


   let l_nulo      = null
	let prompt_key  = null
	let l_confirma  = null
	let l_confirma1  = null

	initialize  d_cta01m05.*  to  null

	initialize  w_aggclsvl.*  to  null

	initialize  ws.*  to  null

 initialize d_cta01m05.*  to null
 initialize ws.*          to null
 initialize l_abrir to null  # PSI 239.399 Clausula 077

 #Chamado 13127781

  let l_st_erro     = 1
  let m_host = fun_dba_servidor("EMISAUTO")
  call cta13m00_verifica_status(m_host)
      returning l_st_erro
               ,l_msg
 if l_st_erro = true then
    let m_host = fun_dba_servidor("CT24HS")
 end if
         call cts08g01("A",
                       "N",
                       "",
                       "VERIFIQUE EM VANTAGENS SE NESTA APOLICE ",
                       "CONSTA O DESCONTO NA FRANQUIA POR BONUS.",
                       "")
            returning l_confirma
    call cta01m05_prepare()

 open window cta01m05 at 06,11 with form "cta01m05"
                      attribute(form line first, border)

 whenever error continue


#--------------------------------------------------------------------------
# Casco
#--------------------------------------------------------------------------

 select imsvlr, frqvlr, frqclacod
   into d_cta01m05.autimsvlr,
        d_cta01m05.frqobrvlr,
        ws.frqclacod
   from abbmcasco
  where succod    = g_documento.succod    and
        aplnumdig = g_documento.aplnumdig and
        itmnumdig = g_documento.itmnumdig and
        dctnumseq = g_funapol.autsitatu

 if sqlca.sqlcode < 0  then
    error "Informacoes sobre CASCO nao disponiveis no momento!"
 else
    if d_cta01m05.autimsvlr is null  then
       let d_cta01m05.frqobrvlr = 0.00
    end if
 end if

 if d_cta01m05.frqobrvlr is not null  then
    let d_cta01m05.frqobrtxt = "Franquia ", ws.frqclacod using "&" clipped, ":"
 end if


#--------------------------------------------------------------------------
# Valor Blindagem
#--------------------------------------------------------------------------
   let d_cta01m05.imsvlr = 0.00
   {select imsvlr
   into d_cta01m05.imsvlr
   from abbmbli
  where succod    = g_documento.succod    and
        aplnumdig = g_documento.aplnumdig and
        itmnumdig = g_documento.itmnumdig and
        dctnumseq = g_funapol.autsitatu}
   open ccta01m05001 using g_documento.succod
                          ,g_documento.aplnumdig
                          ,g_documento.itmnumdig
                          ,g_funapol.autsitatu
    fetch ccta01m05001 into d_cta01m05.imsvlr

#--------------------------------------------------------------------------
# Danos materiais
#--------------------------------------------------------------------------

 select imsvlr, frqvlr, frqclacod, imsniv
   into d_cta01m05.dmtimsvlr,
        d_cta01m05.dmtobrvlr,
        ws.dmtfrqcla,
        d_cta01m05.dmtniv
   from abbmdm
  where succod    = g_documento.succod    and
        aplnumdig = g_documento.aplnumdig and
        itmnumdig = g_documento.itmnumdig and
        dctnumseq = g_funapol.dmtsitatu

 if sqlca.sqlcode < 0  then
    error "Informacoes sobre DANOS MATERIAIS nao disponiveis no momento!"
 else
    if d_cta01m05.dmtimsvlr is null  then
       let d_cta01m05.dmtimsvlr = 0.00
    end if
 end if

 if d_cta01m05.dmtobrvlr is not null  then
    let d_cta01m05.dmtfrqtxt = "Franquia ", ws.dmtfrqcla using "&" clipped, ":"
 end if

#--------------------------------------------------------------------------
# Danos pessoais
#--------------------------------------------------------------------------

 select imsvlr   , frqvlr,
        frqclacod, imsniv
   into d_cta01m05.dpsimsvlr,
        d_cta01m05.dpsobrvlr,
        ws.dpsfrqcla,
        d_cta01m05.dpsniv
   from abbmdp
  where succod    = g_documento.succod    and
        aplnumdig = g_documento.aplnumdig and
        itmnumdig = g_documento.itmnumdig and
        dctnumseq = g_funapol.dpssitatu

 if sqlca.sqlcode < 0  then
    error "Informacoes sobre DANOS PESSOAIS nao disponiveis no momento!"
 else
    if d_cta01m05.dpsimsvlr is null  then
       let d_cta01m05.dpsimsvlr = 0.00
    end if
 end if

 if d_cta01m05.dpsobrvlr is not null  then
    let d_cta01m05.dpsfrqtxt = "Franquia ", ws.dpsfrqcla using "&" clipped, ":"
 end if

#--------------------------------------------------------------------------
# APP (Morte, invalidez e despesas hospitalares)
#--------------------------------------------------------------------------

 {select imsinvvlr,
        imsmorvlr,
        imsdmhvlr
   into d_cta01m05.imsinvvlr,
        d_cta01m05.imsmorvlr,
        d_cta01m05.imsdmhvlr
   from abbmapp
  where succod    = g_documento.succod    and
        aplnumdig = g_documento.aplnumdig and
        itmnumdig = g_documento.itmnumdig and
        dctnumseq = g_funapol.appsitatu}
  open ccta01m05003 using g_documento.succod
                         ,g_documento.aplnumdig
                         ,g_documento.itmnumdig
                         ,g_funapol.appsitatu
   fetch ccta01m05003 into d_cta01m05.imsinvvlr,
                           d_cta01m05.imsmorvlr,
                           d_cta01m05.imsdmhvlr

 if sqlca.sqlcode < 0  then
    error "Informacoes sobre APP nao disponiveis no momento!"
 else
    if d_cta01m05.imsmorvlr is null  then
       let d_cta01m05.imsmorvlr = 0.00
    end if

    if d_cta01m05.imsinvvlr is null  then
       let d_cta01m05.imsinvvlr = 0.00
    end if

    if d_cta01m05.imsdmhvlr is null  then
       let d_cta01m05.imsdmhvlr = 0.00
    end if
 end if

#--------------------------------------------------------------------------
# Moeda
#--------------------------------------------------------------------------

 select imsmda
   into d_cta01m05.imsmda
   from abamdoc
  where succod    = g_documento.succod    and
        aplnumdig = g_documento.aplnumdig and
        dctnumseq = g_funapol.dctnumseq

 if sqlca.sqlcode < 0  then
    error "MOEDA nao disponivel no momento!"
 end if

#--------------------------------------------------------------------------
# Bonus e Classe de Localizacao
#--------------------------------------------------------------------------

 select viginc, bonclacod, clalclcod
   into ws.viginc,
        d_cta01m05.bonclacod,
        ws.clalclcod
   from abbmdoc
  where succod    = g_documento.succod    and
        aplnumdig = g_documento.aplnumdig and
        itmnumdig = g_documento.itmnumdig and
        dctnumseq = g_funapol.dctnumseq

 if sqlca.sqlcode < 0  then
    error "Informacoes sobre BONUS nao disponiveis no momento!"
 else

#--------------------------------------------------------------------------
# Cotacao da moeda
#--------------------------------------------------------------------------

    if d_cta01m05.imsmda <> "R$ "  then
       select mdacotvlr
         into d_cta01m05.mdacotvlr
         from gfatmda
        where mdacod    = d_cta01m05.imsmda  and
              mdacotdat = ws.viginc

       if sqlca.sqlcode < 0  then
          error "COTACAO DA MOEDA nao disponivel no momento!"
       else
          let d_cta01m05.mdacottxt = "Cotacao de ",d_cta01m05.imsmda
          let d_cta01m05.mdacotvlr = d_cta01m05.mdacotvlr
       end if
    end if

#--------------------------------------------------------------------------
# Percentual de bonus
#--------------------------------------------------------------------------

    let ws.tabnum = F_FUNGERAL_TABNUM("acatbon", ws.viginc)

    select bondscper
      into d_cta01m05.bondscper
      from acatbon
     where tabnum    = ws.tabnum       and
          #ramcod    in (31,531)       and
           ramcod    = g_documento.ramcod and
           clalclcod = ws.clalclcod    and   ###  REGIAO ESPECIFICA
           bonclacod = d_cta01m05.bonclacod

    if sqlca.sqlcode < 0  then
       error "PERCENTUAL DE BONUS nao disponivel no momento!"
    else
       if sqlca.sqlcode = notfound  then
          select bondscper
            into d_cta01m05.bondscper
            from acatbon
           where tabnum    = ws.tabnum       and
               # ramcod    in (31,531)       and
                 ramcod    = g_documento.ramcod and
                 clalclcod = 0               and   ###  DEMAIS REGIOES
                 bonclacod = d_cta01m05.bonclacod

          if sqlca.sqlcode < 0  then
             error "PERCENTUAL DE BONUS nao disponivel no momento!"
          else
             if sqlca.sqlcode = notfound  then
                initialize d_cta01m05.bondscper to null

                if d_cta01m05.bonclacod = 0  then
                   initialize d_cta01m05.bonclacod to null
                end if
             end if
          end if
       end if
    end if
 end if

#-------------------------------------------------------------------------------
# Franquia de vidros
#      071 - Para-brisa e vigia
#      X71 - Laterais
#-------------------------------------------------------------------------------
  # -- OSF 9377 - Fabrica de Software, Katiucia -- #
  let w_aggclsvl.frqvlr   = 0
  let d_cta01m05.frqpbr   = 0 # Retirado a pedido da Judite Esteves.
  let d_cta01m05.frqfarol = 0
  let l_abrir = "N" # PSI 239.399 Clausula 077
  if param.frqvidro = "071" or
     param.frqvidro = "075" or
     param.frqvidro = "75R" or
     param.frqvidro = "076" or
     param.frqvidro = "76R" or
     param.frqvidro = "077" then


     {
        # Foi Retirado a pedido da Judite Esteves.
        Busca a descrição de todas as clasulas

        if param.frqvidro = "077" then      # PSI 239.399 Clausula 077
           let d_cta01m05.frqrtr = null
           #let l_abrir = "S"  # Solicitado a retirada por Judite
           let g_vdr_blindado = "S"  # Aqui é atribuido o valor para "S"
                                     # e no modulo cts19m06 PSI 239.399 Clausula 77
           select clsdes into l_nulo
             from aackcls
            where tabnum =( select max(a.tabnum) from aackcls a
                             where a.ramcod = g_documento.ramcod
                               and a.clscod = param.frqvidro  )
              and ramcod = g_documento.ramcod
              and clscod = param.frqvidro
        end if ## PSI 239.399 Clausula 077
     }

          select clsdes into l_nulo
          from aackcls
         where tabnum =( select max(a.tabnum) from aackcls a
                          where a.ramcod = g_documento.ramcod
                            and a.clscod = param.frqvidro  )
           and ramcod = g_documento.ramcod
           and clscod = param.frqvidro



     #display "ENTRADA funcao apgffger_valor_cfc_cls_novo() "
     #display "param.frqvidro : ", param.frqvidro
     #display "param.clcdat   : ", param.clcdat
     #display "param.cvnnum   : ", param.cvnnum
     #display "param.cbtcod   : ", param.cbtcod
     #display "param.ctgtrfcod: ", param.ctgtrfcod
     #display "param.clalclcod: ", param.clalclcod
     #display "param.vclmrccod: ", param.vclmrccod
     #display "param.vcltipcod: ", param.vcltipcod
     #display "param.vclcoddig: ", param.vclcoddig
     #display "param.vclanomdl: ", param.vclanomdl
     #display ""
   if (param.clcdat < "01/05/2007")  then --varani
     call apgffger_valor_cfc_cls_novo( param.frqvidro
                   ,param.clcdat
                   ,param.cvnnum
                   ,param.cbtcod
                   ,param.ctgtrfcod
                   ,param.clalclcod
                   ,param.vclmrccod
                   ,param.vcltipcod
                   ,param.vclcoddig
                   ,param.vclanomdl
                   ,0
                   ,0 )
           returning w_aggclsvl.clscndvlr
                    ,w_aggclsvl.clscndreivlr
                    ,d_cta01m05.frqpbr
                    ,w_aggclsvl.clscndvlr
                    ,w_aggclsvl.clscndreivlr
                    ,w_aggclsvl.frqvlr
                    ,w_aggclsvl.clscndvlr
                    ,w_aggclsvl.clscndreivlr
                    ,d_cta01m05.frqfarol
   else
       #display "<415> cta01m05 -> l_abrir / g_vdr_blindado >> ",  l_abrir,"/", g_vdr_blindado
       call figrc072_setTratarIsolamento()        --> 223689
       call faemc464(g_documento.prporg --varani
                      ,g_documento.prpnumdig
                      ,g_documento.prporg
                      ,g_documento.prpnumdig
                      ,g_documento.succod
                      ,g_documento.aplnumdig
                      ,g_documento.itmnumdig
                      ,g_funapol.dctnumseq
                      ,param.frqvidro --clausula
                      ,l_nulo
                      ,l_abrir ) # 'N' # PSI 239.399 Clausula 077
        returning d_cta01m05.frqpbr
                  ,w_aggclsvl.frqvlr
                  ,d_cta01m05.frqfarol

       if g_isoAuto.sqlCodErr <> 0 then --> 223689
             error "Função faemc464 indisponivel no momento ! Avise a Informatica !" sleep 2
             return
          end if    --> 223689

    end if
    #display ""
    #display "SAIDA apgffger_valor_cfc_cls_novo"
    #display "w_aggclsvl.clscndvlr   : ", w_aggclsvl.clscndvlr
    #display "w_aggclsvl.clscndreivlr: ", w_aggclsvl.clscndreivlr
    #display "d_cta01m05.frqpbr      : ", d_cta01m05.frqpbr
    #display "w_aggclsvl.clscndvlr   : ", w_aggclsvl.clscndvlr
    #display "w_aggclsvl.clscndreivlr: ", w_aggclsvl.clscndreivlr
    #display "w_aggclsvl.frqvlr      : ", w_aggclsvl.frqvlr
    #display "w_aggclsvl.clscndvlr   : ", w_aggclsvl.clscndvlr
    #display "w_aggclsvl.clscndreivlr: ", w_aggclsvl.clscndreivlr
    #display "d_cta01m05.frqfarol    : ", d_cta01m05.frqfarol

  end if

  let d_cta01m05.frqvig = d_cta01m05.frqpbr

  if param.frqvidro = "071" then
     let d_cta01m05.frqlat = w_aggclsvl.frqvlr
     let d_cta01m05.frqrtr = 0
  else
     if param.frqvidro = "075" or
        param.frqvidro = "75R" or
        param.frqvidro = "076" or
        param.frqvidro = "76R" or
        param.frqvidro = "077" then
        let d_cta01m05.frqrtr = w_aggclsvl.frqvlr
        if param.frqvidro = "077" then
           let d_cta01m05.frqrtr = null
           let l_abrir = "S"
        end if
        let d_cta01m05.frqlat = 0
     end if
  end if


 #---------------------------------------------------------------------------
 # Conforme Arnaldo, nas tarifas anteriores a 15/03/2000, nao existia
 # franquia para troca do vidro traseiro - vigia
 #
 # -- OSF 9377 - Fabrica de Software, Katiucia -- #
 ## if  param.clcdat < "15/03/2000"  then
 ##     let  d_cta01m05.frqvig = 0
 ## else
 ##     let  d_cta01m05.frqvig = w_aggclsvl.frqvlr
 ## end if
 ## if param.frqvidro  = "071" then
 ##    call aggclsvl( "X71",
 ##                   param.clcdat,
 ##                   param.cvnnum,
 ##                   param.cbtcod,
 ##                   param.ctgtrfcod,
 ##                   param.clalclcod,
 ##                   param.vclmrccod,
 ##                   param.vcltipcod,
 ##                   param.vclcoddig,
 ##                   param.vclanomdl )
 ##         returning w_aggclsvl.*
 ## else
 ##    let w_aggclsvl.frqvlr = 0
 ## end if

  #------------------------------------------------
  # verifica se a apolice e de AUTO+VIDA
  #------------------------------------------------
  let d_cta01m05.frqdsc    = 0
  let d_cta01m05.frqvlr    = d_cta01m05.frqobrvlr
  let d_cta01m05.classcod  = d_cta01m05.bonclacod
  let d_cta01m05.classper  = d_cta01m05.bondscper

  {select cbtstt , pandifvlr
      into ws.cbtstt, ws.pandifvlr
      from abbmvida2
      where  succod    = g_documento.succod
        and  aplnumdig = g_documento.aplnumdig
        and  itmnumdig = g_documento.itmnumdig
        and  dctnumseq =
            (select max(dctnumseq)
                from abbmvida2
               where succod     = g_documento.succod
                 and aplnumdig  = g_documento.aplnumdig
                 and  itmnumdig = g_documento.itmnumdig)}
    open ccta01m05002 using g_documento.succod
                           ,g_documento.aplnumdig
                           ,g_documento.itmnumdig
                           ,g_documento.succod
                           ,g_documento.aplnumdig
                           ,g_documento.itmnumdig
      fetch ccta01m05002 into ws.cbtstt
                             ,ws.pandifvlr
  if sqlca.sqlcode     = 0   and
     ws.cbtstt         = "A" then
     call fssac029(g_documento.ramcod,g_documento.aplnumdig,   #funcao informa
                   g_documento.succod,g_documento.itmnumdig,0) #se o sinistro
              returning ws.temsinis,ws.sinnum,ws.orrdat        #foi indenizado
     if ws.temsinis       = "S"  then
        let d_cta01m05.sinnum  = ws.sinnum
        let d_cta01m05.orrdat  = ws.orrdat
        let d_cta01m05.frqdsc  = 0
     else
       #if g_hostname   =  "u07"  then
       #   select grlinf
       #       into d_cta01m05.frqdsc
       #       from igbkgeral
       #      where mducod  =  "VDA"
       #        and grlchv  =  "PREMIO"
       #else
       #   select grlinf
       #       into d_cta01m05.frqdsc
       #       from porto@u01:igbkgeral
       #      where mducod  =  "VDA"
       #        and grlchv  =  "PREMIO"
       #end if
       # conforme Alexandre Farias do auto o valor do desconto para Vida
       # esta no campo pandifvlr da tabela abbmvida2. 12/02/07(Ruiz)
        let d_cta01m05.frqdsc = ws.pandifvlr
     end if
  end if
  #-------------------------------------------
  # vigencia da apolice
  #-------------------------------------------
  select viginc
     into ws.viginc
     from abamapol
    where succod    =  g_documento.succod   and
          aplnumdig =  g_documento.aplnumdig
  if ws.viginc      >= "15/03/2000" then
     let ws.viginc1  = ws.viginc
  else
     select viginc,dctnumseq  # procura endosso de substituicao
        into ws.viginc2,ws.dctnumseq
        from abbmdoc
       where succod    = g_documento.succod    and
             aplnumdig = g_documento.aplnumdig and
             itmnumdig = g_documento.itmnumdig and
             edstip    = 2
     if sqlca.sqlcode  = 0  then
        select edsstt    # verifica se o endosso de substituicao esta ativo
           into ws.edsstt
           from abamdoc
          where succod    = g_documento.succod    and
                aplnumdig = g_documento.aplnumdig and
                dctnumseq = ws.dctnumseq
          if ws.edsstt    = "A"  then
             let ws.viginc1  = ws.viginc2
          else
             let ws.viginc1  = ws.viginc
          end if
     else
         let ws.viginc1  = ws.viginc
     end if
  end if

  let d_cta01m05.dthoje  =  today

  if param.clcdat < "01/07/2003" then
     let d_cta01m05.frqhoje =  d_cta01m05.frqvlr - d_cta01m05.frqdsc
  else
     let d_cta01m05.frqhoje =  d_cta01m05.frqvlr
     display by name d_cta01m05.frqdsc
  end if

  if  d_cta01m05.classcod   >=  5  and           # desc. bonus franquia
      d_cta01m05.classper   >   0  and
      ws.viginc1            >= "15/03/2000" then
      call fssac029(g_documento.ramcod,g_documento.aplnumdig,   #funcao informa
                    g_documento.succod,g_documento.itmnumdig,0) #se o sinistro
               returning ws.temsinis,ws.sinnum,ws.orrdat        #foi indenizado
      if ws.temsinis       = "S"  then
         let d_cta01m05.sinnum  = ws.sinnum
         let d_cta01m05.orrdat  = ws.orrdat
         let d_cta01m05.classper = 0
      end if

      if param.clcdat < "01/07/2003" then
         let d_cta01m05.classvlr = (d_cta01m05.classper *
                                    d_cta01m05.frqhoje ) / 100
      else
         let d_cta01m05.classvlr = 0
      end if

      let d_cta01m05.frqhoje = d_cta01m05.frqhoje - d_cta01m05.classvlr

      if d_cta01m05.classper = 0 then
         initialize d_cta01m05.classcod to null
         initialize d_cta01m05.classper to null
      end if
  else
      initialize d_cta01m05.classcod to null
      initialize d_cta01m05.classper to null
  end if
  let d_cta01m05.texto1  = "FRANQUIA PARA ABERTURA DE PROCESSO"
  initialize d_cta01m05.dthoje to null
  let d_cta01m05.texto   = "Franquia com desconto: ", d_cta01m05.dthoje
  initialize d_cta01m05.frqobrtxt to null
  initialize d_cta01m05.frqobrvlr to null
  #----------fim do auto+vida-------------------------------------

  whenever error stop


  #------------------------------------------------
  # Verifica se o Veiculo e Blindado
  #------------------------------------------------

  if cty32g00_verifblindagem() then
		 let d_cta01m05.veiblitxt = "VEICULO BLINDADO"
	end if

  { Foi Criando a função cta01m05_display para exibir somente os campos que estão na tela
    Foram retirados da tela os campos de franquia de vidros a pedido da
    Judite Esteves.

    display by name d_cta01m05.*
    display by name d_cta01m05.texto1 attribute(reverse)
   }

   call cta01m05_display()

    #---------------------------------------------------------------
		# Alerta Franquia
		#---------------------------------------------------------------
		select count(cpocod)
		  into ws.cpocod
		  from datkdominio
		 where cponom = 'alerta_franquia'
		   and cpodes = param.ctgtrfcod

		select cpodes
		  into ws.cpodes
		  from datkdominio
		 where cponom = 'valor_franquia'

		 let l_msg1 ="PARA ATENDIMENTO AO TERCEIRO"
	   let l_msg2 = "DANOS TERAO QUE SUPERAR O VALOR"
	   let l_msg3 = "DA FRANQUIA DE R$ " clipped,ws.cpodes

		 if ws.cpocod = 1 then
		 			call cts08g01("A","N","",l_msg1,l_msg2,l_msg3)
		            returning l_confirma1
		 end if

  while true

      prompt " (F5) Franquia Vidros (F17)Abandona" attribute(reverse) for prompt_key

      on key (F5)

      call faemc464(g_documento.prporg
                         ,g_documento.prpnumdig
                         ,g_documento.prporg
                         ,g_documento.prpnumdig
                         ,g_documento.succod
                         ,g_documento.aplnumdig
                         ,g_documento.itmnumdig
                         ,g_funapol.dctnumseq
                         ,param.frqvidro --clausula
                         ,l_nulo
                         ,"S" ) # 'N' # PSI 239.399 Clausula 077
           returning d_cta01m05.frqpbr
                     ,w_aggclsvl.frqvlr
                     ,d_cta01m05.frqfarol

       on key (interrupt)
       close window cta01m05
       exit while

      end prompt
  end while

end function  ###  cta01m05

function cta01m05_display()

     display by name d_cta01m05.imsmda
     display by name d_cta01m05.mdacottxt
     display by name d_cta01m05.mdacotvlr
     display by name d_cta01m05.autimsvlr
     display by name d_cta01m05.imsvlr
     display by name d_cta01m05.dmtimsvlr
     display by name d_cta01m05.dpsimsvlr
     display by name d_cta01m05.imsmorvlr
     display by name d_cta01m05.imsinvvlr
     display by name d_cta01m05.imsdmhvlr
     display by name d_cta01m05.dmtniv
     display by name d_cta01m05.dpsniv
     display by name d_cta01m05.frqobrtxt
     display by name d_cta01m05.dmtfrqtxt
     display by name d_cta01m05.dpsfrqtxt
     display by name d_cta01m05.frqobrvlr
     display by name d_cta01m05.dmtobrvlr
     display by name d_cta01m05.dpsobrvlr
     display by name d_cta01m05.bonclacod
     display by name d_cta01m05.bondscper
     display by name d_cta01m05.veiblitxt attribute(reverse)
     display by name d_cta01m05.texto1
     display by name d_cta01m05.frqvlr
     display by name d_cta01m05.frqdsc
     display by name d_cta01m05.orrdat
     display by name d_cta01m05.sinnum
     display by name d_cta01m05.texto
     display by name d_cta01m05.dthoje
     display by name d_cta01m05.frqhoje
     display by name d_cta01m05.classcod
     display by name d_cta01m05.classper
     display by name d_cta01m05.classvlr
     display by name d_cta01m05.texto1 attribute(reverse)

end function