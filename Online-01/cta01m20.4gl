###############################################################################
# Nome do Modulo: CTA01M20                                            Marcelo #
#                                                                       Pedro #
# Consulta apolice de Ramos Elementares                              Mar/1995 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 09/12/1999  PSI 7263-0   Gilberto     Nao exibir solicitante quando nao     #
#                                       estiver em atendimento.               #
#-----------------------------------------------------------------------------#
# 05/06/2001  PSI 11251-8  Raji         Consulta RE Locais de Risco           #
###############################################################################
#=============================================================================#
# Alterado : 23/07/2002 - Celso                                               #
#            Utilizacao da funcao fgckc811 para enderecamento de corretores   #
#=============================================================================#
#                                                                             #
#                       * * * Alteracoes * * *                                #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ----------------------------------- #
# 20/11/2003  Bruno, Meta      PSI172057  Comparar susep informado e o        #
#                              OSF 28991  susep da apolice.                   #
#-----------------------------------------------------------------------------#
# 15/10/2004  Katiucia         CT 252794  Trocar global g_corretor.corsussol  #
#                                         pela g_documento.corsus/            #
#                                         buscar cornom                       #
#-----------------------------------------------------------------------------#
# 25/10/2004  Meta, James      PSI188514  Acrescentar tipo de solicitacao = 8 #
#-----------------------------------------------------------------------------#
# 18/10/2008  Carla Rampazzo   Psi 230650 Incluir Nro.de Atendimento na tela  #
#-----------------------------------------------------------------------------#
# 05/04/2010  Carla Rampazzo   Psi 219444 Mostrar descricao do Local de Risco #
#                                         ou do Bloco de Condominio           #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_prep_sql      smallint

#------------------------------------------------------------------------------
 function cta01m20_prepare()
#------------------------------------------------------------------------------

 define l_sql    char(300)

    let l_sql = " select corsus, slcnom ",
                "   from rsamcortrans  ",
                "  where sgrorg = ?    ",
                "    and sgrnumdig = ? "
    prepare pcta01m20001   from l_sql
    declare ccta01m20001   cursor for pcta01m20001

    let m_prep_sql = true

 end function
#-------------------------------------------------------------------------------
 function cta01m20()
#-------------------------------------------------------------------------------

  define r_gcakfilial    record
         endlgd          like gcakfilial.endlgd
        ,endnum          like gcakfilial.endnum
        ,endcmp          like gcakfilial.endcmp
        ,endbrr          like gcakfilial.endbrr
        ,endcid          like gcakfilial.endcid
        ,endcep          like gcakfilial.endcep
        ,endcepcmp       like gcakfilial.endcepcmp
        ,endufd          like gcakfilial.endufd
        ,dddcod          like gcakfilial.dddcod
        ,teltxt          like gcakfilial.teltxt
        ,dddfax          like gcakfilial.dddfax
        ,factxt          like gcakfilial.factxt
        ,maides          like gcakfilial.maides
        ,crrdstcod       like gcaksusep.crrdstcod
        ,crrdstnum       like gcaksusep.crrdstnum
        ,crrdstsuc       like gcaksusep.crrdstsuc
        ,status          smallint
  end record

 define d_cta01m20       record
        contrato         char(75),
        protecao         char(37),
        cpfnum           char(40),
        ramcod           like rsamseguro.ramcod    ,
        subcod           like rsamseguro.subcod    ,
        ramnom           like gtakram.ramnom       ,
        rmemdlnom        like gtakmodal.rmemdlnom  ,
        localdes         char(17)                  ,
        viginc           like rsdmdocto.viginc     ,
        vigfnl           like rsdmdocto.vigfnl     ,
        emsdat           like rsdmdocto.emsdat     ,
        corsus           like rsampcorre.corsus    ,
        cornom           like gcakcorr.cornom      ,
        teltxtcor        char(31)                  ,
        segnumdig        like rsdmdocto.segnumdig  ,
        segnom           like gsakseg.segnom       ,
        teltxtseg        char(31)                  ,
        situacao         char(09)                  ,
        pgtfrmdes        like gfbkfpag.pgtfrmdes   ,
        edstipdes        like rgdktip.edstipdes    ,
        viginceds        like rsdmdocto.viginc     ,
        vigfnleds        like rsdmdocto.vigfnl     ,
        imsmoeda         char(20)                  ,
        prmmoeda         char(20)                  ,
        carencia         char(38)                  ,
        corretor         char(19),
        etpctrnum        char(30), ##like rgemetpsgr.etpctrnum,
        aprlhdesc        like rgekaprlh.aprlhdesc
 end  record

 define r_cta01m20       record
        succod           like rsamseguro.succod    ,
        aplnumdig        like rsamseguro.aplnumdig ,
        edsnumdig        like rsdmdocto.edsnumdig  ,
        edstip           like rsdmdocto.edstip     ,
        solnom           like datmligacao.c24solnom,
        prporg           like rsdmdocto.prporg     ,
        prpnumdig        like rsdmdocto.prpnumdig
 end record

 define ws       record
    dddcodseg    like gsakend.dddcod      ,
    dddcodcor    like gcakfilial.dddcod   ,
    sgrorg       like rsdmdocto.sgrorg    ,
    sgrnumdig    like rsdmdocto.sgrnumdig ,
    rmemdlcod    like rsamseguro.rmemdlcod,
    edsstt       like rsdmdocto.edsstt    ,
    dctnumseq    like rsdmdocto.dctnumseq ,
    pgtfrm       like rsdmdadcob.pgtfrm   ,
    imsmda       like rsdmdocto.imsmda    ,
    prmmda       like rsdmdocto.prmmda    ,
    adcfrcvlr    like rspmparc.adcfrcvlr  ,
    iofvlr       like rspmparc.iofvlr     ,
    confirma     char(01)                 ,
    pestip       like gsakseg.pestip      ,
    cgccpfnum    like gsakseg.cgccpfnum   ,
    cgcord       like gsakseg.cgcord      ,
    cgccpfdig    like gsakseg.cgccpfdig
 end record

 define arr_aux          smallint
 define ix               integer

# PSI 172057 - Inicio

 define l_param1         char(40)
       ,l_param2         char(40)
       ,l_param3         char(40)
       ,l_param4         char(01)
       ,l_param5         char(01)
       ,l_corsus         like rsamcortrans.corsus
       ,l_slcnom         like rsamcortrans.slcnom
       ,l_res            smallint
       ,l_erro           smallint
       ,l_mensagem       char(60)

 define l_cty00g00    record
    erro              smallint
   ,mensagem          char(60)
   ,cornomsol         like gcakcorr.cornom
 end record

 define l_confirma char(1)

# PSI 172057 - Final

 let arr_aux = null
 let ix      = null
 let l_res   = null

 initialize r_gcakfilial.* to  null
 initialize d_cta01m20.*   to  null
 initialize r_cta01m20.*   to  null
 initialize ws.*           to  null

 open window w_cta01m20 at 3,2 with form "cta01m20"
      attribute(form line first)

 initialize d_cta01m20.*  to null
 initialize ws.*          to null

 if (g_documento.succod    is null  or
     g_documento.ramcod    is null  or
     g_documento.aplnumdig is null) and
     g_ppt.cmnnumdig is null then
     error "Suc/Ram/Apl/Cont nao informado, AVISE INFORMATICA"
     close window w_cta01m20
     let int_flag = false
     return
 end if

 #------------------------------------------------------------
 # Procura dados da apolice
 #------------------------------------------------------------
 message " Aguarde, formatando os dados..."  attribute(reverse)

 let arr_aux = 1

 # --- PSI 172057 - Inicio ---

 if m_prep_sql is null or
    m_prep_sql <> true then
      call cta01m20_prepare()
 end if

 # --- PSI 172057 - Final ---

 if g_ppt.cmnnumdig is not null then
     let d_cta01m20.ramcod          = g_documento.ramcod
     let ws.edsstt                  = g_ppt.edsstt
     let d_cta01m20.viginc          = g_ppt.viginc
     let d_cta01m20.vigfnl          = g_ppt.vigfnl
     let d_cta01m20.emsdat          = g_ppt.emsdat
     let d_cta01m20.corsus          = g_ppt.corsus
     let ws.pgtfrm                  = g_ppt.pgtfrm
     let ws.imsmda                  = g_ppt.mdacod
     let ws.prmmda                  = g_ppt.mdacod
     let d_cta01m20.carencia        = g_a_pptcls[arr_aux].carencia
     let r_cta01m20.prporg          = g_dctoarray[arr_aux].prporg
     let r_cta01m20.prpnumdig       = g_dctoarray[arr_aux].prpnumdig
     let d_cta01m20.segnumdig       = g_ppt.segnumdig
     let r_cta01m20.aplnumdig       = g_ppt.cmnnumdig
     let d_cta01m20.viginceds       = g_ppt.viginc
     let d_cta01m20.vigfnleds       = g_ppt.vigfnl
     let r_cta01m20.solnom          = g_documento.solnom

     let d_cta01m20.contrato = "Contrato.:",r_cta01m20.aplnumdig,"         ",
                                            r_cta01m20.solnom
     let d_cta01m20.protecao = "          CLIENTE"
     let d_cta01m20.ramnom   = "PROTECAO PATRIMONIAL"

     initialize ws.pestip, ws.cgccpfnum, ws.cgcord, ws.cgccpfdig to null

     select pestip, cgccpfnum, cgcord, cgccpfdig
       into ws.pestip, ws.cgccpfnum, ws.cgcord, ws.cgccpfdig
       from gsakseg
      where segnumdig = g_ppt.segnumdig

      if ws.pestip = "F" then
         let d_cta01m20.cpfnum = "CPF: ",
             ws.cgccpfnum using "<<<&&&&&&&&&"," ",
             ws.cgccpfdig using "&&"
      else
         let d_cta01m20.cpfnum = "CNPJ: ",
             ws.cgccpfnum using "<<<&&&&&&&&&"," ",
             ws.cgcord    using "&&&&"," ",
             ws.cgccpfdig using "&&"
      end if

     let d_cta01m20.segnom = "SEGURADO NAO CADASTRADO"

      select  segnom
        into  d_cta01m20.segnom
        from  gsakseg
        where segnumdig = d_cta01m20.segnumdig

       if status  <>  notfound   then
          select  dddcod, teltxt
            into  ws.dddcodseg, d_cta01m20.teltxtseg
            from  gsakend
            where segnumdig = d_cta01m20.segnumdig   and
                  endfld    = "1"

         if status <> notfound   then
            let d_cta01m20.teltxtseg = "(",ws.dddcodseg,") ", d_cta01m20.teltxtseg
         end if
       end if

        let d_cta01m20.cornom = "CORRETOR NAO CADASTRADO"

        select cornom
          into d_cta01m20.cornom
          from gcaksusep, gcakcorr
         where gcaksusep.corsus     =  d_cta01m20.corsus   and
               gcakcorr.corsuspcp   = gcaksusep.corsuspcp

         if sqlca.sqlcode <> notfound   then

            #---> Utilizacao da nova funcao de comissoes p/ enderecamento
            initialize r_gcakfilial.* to null
            call fgckc811(d_cta01m20.corsus)
                 returning r_gcakfilial.*
            let ws.dddcodcor         = r_gcakfilial.dddcod
            let d_cta01m20.teltxtcor = r_gcakfilial.teltxt
            #------------------------------------------------------------

            let d_cta01m20.teltxtcor = "(",ws.dddcodcor,") ", d_cta01m20.teltxtcor
         end if

         case ws.edsstt
            when "A" let d_cta01m20.situacao = "ATIVA"
            when "C" let d_cta01m20.situacao = "CANCELADA"
            when "E" let d_cta01m20.situacao = "E.ANDAMENTO"  #- SOMENTE P/ PPT
            when "I" let d_cta01m20.situacao = "INADIMPLENTE" #- SOMENTE P/ PPT
            when "R" let d_cta01m20.situacao = "REMOVIDO"     #- SOMENTE P/ PPT
         end case

           select pgtfrmdes
             into d_cta01m20.pgtfrmdes
             from gfbkfpag
            where pgtfrm = ws.pgtfrm

        let d_cta01m20.imsmoeda = "MOEDA NAO CADASTRADA"

        select mdanom
          into d_cta01m20.imsmoeda
          from gfakmda
         where mdacod = ws.imsmda

        let d_cta01m20.prmmoeda = "MOEDA NAO CADASTRADA"

         select mdanom
           into d_cta01m20.prmmoeda
           from gfakmda
          where mdacod = ws.prmmda

        display by name d_cta01m20.*

## PSI 172057 - Inicio

        if d_cta01m20.corretor = "CARTA TRANSFERENCIA" then
           display d_cta01m20.corretor to corretor attribute(reverse)
        end if

## PSI 172057 - Final

        if d_cta01m20.vigfnl < today   then
           display d_cta01m20.viginc   to  viginc      attribute(reverse)
           display d_cta01m20.vigfnl   to  vigfnl      attribute(reverse)
           let d_cta01m20.situacao = "VENCIDA"
        end if

        display d_cta01m20.situacao  to  situacao      attribute(reverse)

 else

    select  sgrorg   , sgrnumdig,
            rmemdlcod, subcod
      into  ws.sgrorg   , ws.sgrnumdig,
            ws.rmemdlcod, d_cta01m20.subcod
      from  rsamseguro
      where succod    = g_documento.succod     and
            ramcod    = g_documento.ramcod     and
            aplnumdig = g_documento.aplnumdig

    if status = notfound   then
       error "Apolice nao encontrada, AVISE INFORMATICA"
       close window w_cta01m20
       let int_flag = false
       return
    end if

 #------------------------------------------------------------
 # Procura situacao da apolice/endosso
 #------------------------------------------------------------
    select  edsstt   , viginc           , vigfnl
      into  ws.edsstt, d_cta01m20.viginc, d_cta01m20.vigfnl
      from  rsdmdocto
     where  sgrorg    = ws.sgrorg      and
            sgrnumdig = ws.sgrnumdig   and
            dctnumseq = 1

    select  prporg   , prpnumdig, viginc   , vigfnl  ,
            edsnumdig, edstip   , segnumdig, emsdat  ,
            imsmda   , prmmda   , dctnumseq

      into  r_cta01m20.prporg   , r_cta01m20.prpnumdig,
            d_cta01m20.viginceds, d_cta01m20.vigfnleds,
            r_cta01m20.edsnumdig, r_cta01m20.edstip   ,
            d_cta01m20.segnumdig, d_cta01m20.emsdat   ,
            ws.imsmda           , ws.prmmda           ,
            ws.dctnumseq

      from  rsdmdocto

      where sgrorg    = ws.sgrorg      and
            sgrnumdig = ws.sgrnumdig   and
            dctnumseq = (select max(dctnumseq)
                           from  rsdmdocto
                            where sgrorg     = ws.sgrorg     and
                                  sgrnumdig  = ws.sgrnumdig  and
                                  prpstt     in (19,65,66,88))
    if status = notfound   then
       error "Documento nao encontrado, AVISE INFORMATICA"
       close window w_cta01m20
       let int_flag = false
       return
    end if

    let r_cta01m20.succod    = g_documento.succod
    let d_cta01m20.ramcod    = g_documento.ramcod
    let r_cta01m20.aplnumdig = g_documento.aplnumdig
    let r_cta01m20.solnom    = g_documento.solnom
    let g_documento.edsnumref= r_cta01m20.edsnumdig

    let d_cta01m20.contrato = "Suc.:",r_cta01m20.succod,    " ",
                              "Apl.:",r_cta01m20.aplnumdig, " ",
                              "End.:",r_cta01m20.edsnumdig, " ", "Tipo End.:",
                                      r_cta01m20.edstip," ", r_cta01m20.solnom
    let d_cta01m20.protecao = "          SEGURADO"
    let d_cta01m20.ramnom   = ""

 #------------------------------------------------------------
 # Descricao do ramo da apolice
 #------------------------------------------------------------
    let d_cta01m20.ramnom = "RAMO NAO CADASTRADO"
    select ramnom
      into  d_cta01m20.ramnom
      from  gtakram
      where empcod = 1
        and ramcod = d_cta01m20.ramcod

 #------------------------------------------------------------
 # Dados do segurado
 #------------------------------------------------------------
    let d_cta01m20.segnom = "SEGURADO NAO CADASTRADO"
    select  segnom
      into  d_cta01m20.segnom
      from  gsakseg
      where segnumdig = d_cta01m20.segnumdig

    if status  <>  notfound   then
       select  dddcod, teltxt
         into  ws.dddcodseg, d_cta01m20.teltxtseg
         from  gsakend
         where segnumdig = d_cta01m20.segnumdig   and
               endfld    = "1"

       if status <> notfound   then
          let d_cta01m20.teltxtseg = "(",ws.dddcodseg,") ", d_cta01m20.teltxtseg
       end if
    end if

 #------------------------------------------------------------
 # Descricao da modalidade da apolice
 #------------------------------------------------------------
    let d_cta01m20.rmemdlnom = "MODALIDADE NAO CADASTRADA"
    select rmemdlnom
      into  d_cta01m20.rmemdlnom
     #from  rgpkmodal
      from  gtakmodal
      where empcod    = 1
        and ramcod    = d_cta01m20.ramcod
        and rmemdlcod = ws.rmemdlcod

 #------------------------------------------------------------
 # Dados do corretor
 #------------------------------------------------------------
    select corsus
      into  d_cta01m20.corsus
      from  rsampcorre
      where rsampcorre.sgrorg    = ws.sgrorg      and
            rsampcorre.sgrnumdig = ws.sgrnumdig   and
            rsampcorre.corlidflg = "S"

    let d_cta01m20.cornom = "CORRETOR NAO CADASTRADO"

    select cornom
      into d_cta01m20.cornom
      from gcaksusep, gcakcorr
     where gcaksusep.corsus     =  d_cta01m20.corsus   and
           gcakcorr.corsuspcp   = gcaksusep.corsuspcp

    if sqlca.sqlcode <> notfound   then

       #---> Utilizacao da nova funcao de comissoes p/ enderecamento
       initialize r_gcakfilial.* to null
       call fgckc811(d_cta01m20.corsus)
            returning r_gcakfilial.*
       let ws.dddcodcor         = r_gcakfilial.dddcod
       let d_cta01m20.teltxtcor = r_gcakfilial.teltxt
       #------------------------------------------------------------

       let d_cta01m20.teltxtcor = "(",ws.dddcodcor,") ", d_cta01m20.teltxtcor
    end if

 # --- PSI 172057 - Inicio ---

    let l_param1 = "SUSEPs NAO CONFEREM"
    # -- CT 252794 - Katiucia -- #
    initialize l_cty00g00.* to null
    call cty00g00_nome_corretor ( g_documento.corsus )
         returning l_cty00g00.erro
                  ,l_cty00g00.mensagem
                  ,l_cty00g00.cornomsol

    let l_param2 = "INF: ",g_documento.corsus," - ",l_cty00g00.cornomsol
    let l_param3 = "APL: ",d_cta01m20.corsus," - ",d_cta01m20.cornom
    let l_param4 = "A"
    let l_param5 = "N"

    if g_documento.c24soltipcod = 2 or
       g_documento.c24soltipcod = 8 then
       let   l_corsus = null
       let   l_slcnom = null
       open  ccta01m20001    using  ws.sgrorg,
                                    ws.sgrnumdig
       whenever error continue
       fetch ccta01m20001    into   l_corsus, l_slcnom
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             error 'Erro de select RSAMCORTRANS' ,sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 2
             error 'cta01m20()/',ws.sgrorg, ws.sgrnumdig sleep 2
             close window w_cta01m20
             let int_flag = false
             return
          end if
       end if
       if l_corsus is not null then
          let d_cta01m20.corretor = "CARTA TRANSFERENCIA"
          display d_cta01m20.corretor to corretor attribute(reverse)
       end if

       # -- CT 252794 - Katiucia -- #
       if g_documento.corsus <> d_cta01m20.corsus then
          if l_corsus is null or
            (l_corsus <> g_documento.corsus and
             l_corsus <> d_cta01m20.corsus) then
             call cts08g01(l_param4,l_param5,l_param1,
                           l_param2,
                           l_param3,"")
                 returning ws.confirma
          end if
       end if
    end if

    let g_corretor.corsusapl = d_cta01m20.corsus
    let g_corretor.cornomapl = d_cta01m20.cornom

 # --- PSI 172057 - Final ---

    if ws.edsstt  =  "A"   then
       let d_cta01m20.situacao = "ATIVA"
    else
       if r_cta01m20.edstip = 40 or
          r_cta01m20.edstip = 41 then
          let d_cta01m20.situacao = "ATIVA"
       else
          let d_cta01m20.situacao = "CANCELADA"
       end if
    end if

 ----------[ alertas para o atendente referente as suseps clara ]-------------

    case d_cta01m20.corsus
       when "P5005J"
          call cts08g01 ("A","N","",
                         "Esta apolice pertence a um FUNCIONARIO  ",
                         "da PORTO SEGURO.                        ",
                         "")
               returning ws.confirma
       when "M5005J"
          call cts08g01 ("A","N","",
                         "Esta apolice pertence a um FAMILIAR  de ",
                         "um FUNCIONARIO da PORTO SEGURO.         ",
                         "")
               returning ws.confirma
       when "H5005J"
          call cts08g01 ("A","N","",
                         "Esta apolice pertence a um PRESTADOR de ",
                         "SERVICOS da PORTO SEGURO.               ",
                         "")
               returning ws.confirma
       when "G5005J"
          call cts08g01 ("A","N","",
                         "Esta apolice pertence a um GERENTE ou   ",
                         "DIRETOR da PORTO SEGURO.                ",
                         "")
               returning ws.confirma
       when "04337J "
          call cts08g01 ("A","N",
                         "CONTRATANDO A CLAUSULA BRONZE, PARA    ",
                         "ESSE DOCUMENTO, PERMITIR SERVICOS DO   ",
                         "PLANO PRATA. CONSULTE MAIS INFORMACOES ",
                         "NA BASE DE CONHECIMENTO! ")
               returning ws.confirma

    end case


 # ---> CHAMA TELA DE PROCEDIMENTOS PARA ATENDIMENTO
  message " Aguarde, verificando procedimentos... " attribute (reverse)
  call cts14g00("",
                g_documento.ramcod,
                g_documento.succod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                "",
                "",
                "N",
                "2099-12-31 23:00")
  message ""

 #------------------------------------------------------------
 # Forma de pagamento e moeda
 #------------------------------------------------------------
    select  pgtfrm
      into  ws.pgtfrm
      from  rsdmdadcob
      where prporg    = r_cta01m20.prporg        and
            prpnumdig = r_cta01m20.prpnumdig

    if ws.pgtfrm  is not null  and
       ws.pgtfrm  <>  0        then
       let d_cta01m20.pgtfrmdes = "FORMA PAGTO NAO CADASTRADA"
       select  pgtfrmdes
         into  d_cta01m20.pgtfrmdes
         from  gfbkfpag
         where pgtfrm = ws.pgtfrm
    end if

    let d_cta01m20.imsmoeda = "MOEDA NAO CADASTRADA"

    select mdanom
       into d_cta01m20.imsmoeda
       from gfakmda
       where mdacod = ws.imsmda

    let d_cta01m20.prmmoeda = "MOEDA NAO CADASTRADA"

    select mdanom
       into d_cta01m20.prmmoeda
       from gfakmda
       where mdacod = ws.prmmda


   ---> Define Valores p/ Seq. Local Risco e Bloco, pois os servicos
   ---> antigos nao tem estes dados relacionados a ele
   if g_documento.lclnumseq is null then
      let g_documento.lclnumseq = 1
   end if

   if g_documento.rmerscseq is null then

      if d_cta01m20.ramcod = 116 then ---> Condominio
         let g_documento.rmerscseq = 1
      else
         let g_documento.rmerscseq = 0
      end if
   end if


   #------------------------------------------------------------
   # Cod.Sequencia do Local de Risco ou do Bloco do Condominio
   #------------------------------------------------------------
   initialize d_cta01m20.localdes to null

   if d_cta01m20.ramcod = 116 then    ---> Condominio

      if g_documento.succod    is not null and
         g_documento.succod    <> 0        and
         g_documento.ramcod    is not null and
         g_documento.ramcod    <> 0        and
         g_documento.aplnumdig is not null and
         g_documento.aplnumdig <> 0        then

         call framo240_dados_bloco (true
                                   ,g_documento.succod
                                   ,g_documento.ramcod
                                   ,g_documento.aplnumdig
                                   ,"" --> prporg
                                   ,"" --> prpnumdig
                                   ,g_documento.lclnumseq
                                   ,g_documento.rmerscseq)
                          returning l_erro
			           ,l_mensagem
                                   ,d_cta01m20.localdes
      end if

      if l_erro = 1 then
         error l_mensagem
      end if
   else
      let d_cta01m20.localdes = "Local ",g_documento.lclnumseq using "&&"
   end if

    display by name g_documento.atdnum attribute(reverse)
    display by name d_cta01m20.*

## PSI 172057 - Inicio

    if d_cta01m20.corretor = "CARTA TRANSFERENCIA" then
       display d_cta01m20.corretor to corretor attribute(reverse)
    end if

## PSI 172057 - Final

    if d_cta01m20.vigfnl < today   then
       display d_cta01m20.viginc   to  viginc      attribute(reverse)
       display d_cta01m20.vigfnl   to  vigfnl      attribute(reverse)
       let d_cta01m20.situacao = "VENCIDA"
    end if

    display d_cta01m20.situacao  to  situacao      attribute(reverse)


 #------------------------------------------------------------
 # Descricao do tipo do endosso
 #------------------------------------------------------------
    if r_cta01m20.edstip  is not null    then
       if r_cta01m20.edstip = 0   then
          let d_cta01m20.edstipdes = "APOLICE"
       else
          let d_cta01m20.edstipdes = "TIPO ENDOSSO NAO CADASTRADO"
          select edstipdes
             into d_cta01m20.edstipdes
             from rgdktip
             where edstip = r_cta01m20.edstip
       end if

       if r_cta01m20.edstip = 40  then
          let d_cta01m20.edstipdes = "APOLICE EM PROCESSO DE RE-EMISSAO"
       end if

       if r_cta01m20.edstip = 41  then
          let d_cta01m20.edstipdes = "ENDOSSO EM PROCESSO DE RE-EMISSAO"
       end if

       display by name d_cta01m20.edstipdes attribute(reverse)
    end if

 #------------------------------------------------------------
 # Verifica carencia para apolices de Servicos a Residencia
 #------------------------------------------------------------
    if (d_cta01m20.ramcod     =   71  and
        ws.rmemdlcod          =  232) or
       (d_cta01m20.ramcod     =  171  and
        ws.rmemdlcod          =  232) then

       if r_cta01m20.edstip  =  44   then
          let d_cta01m20.carencia = "LIMITE DE ATENDIMENTOS ATINGIDO"
       else
# Alteracao solicitada por Valdineia Tuquim (CT24H) com aval do
# Macelo Santana (RE) conforme email enviado em 17/09/08
#         call cta01m20_vercaren(ws.sgrorg, ws.sgrnumdig)
#              returning  d_cta01m20.carencia
       end if

       display by name d_cta01m20.carencia  attribute(reverse)
    end if
 end if

 if ( d_cta01m20.ramcod = 171   and
      ws.rmemdlcod      = 417 ) or
    ( d_cta01m20.ramcod = 195   and
      ws.rmemdlcod      = 0   ) then  ## GARANTIA ESTENDIDA

    call framc400_retorna_desc_aparelho(g_documento.succod,
                                        g_documento.ramcod,
                                        g_documento.aplnumdig)
         returning l_res, d_cta01m20.etpctrnum, d_cta01m20.aprlhdesc

    display "Cert:" to tit_certif
    display by name d_cta01m20.etpctrnum

    display "Eqp.:" to tit_aparelho
    display by name d_cta01m20.aprlhdesc

    if d_cta01m20.viginc > today then ## Alberto Garantia
      call cts08g01("A","N",
                    "",
                    "APOLICE FORA DA DATA DE VIGENCIA ",
                    "",
                    "")
          returning ws.confirma
    end if

 end if

#--------------------------------------------------------------------------
# Marcos Goes
# PSI-2011-03410-EV
# Verifica outros documentos (AUTO ou RE) para o segurado
#--------------------------------------------------------------------------

   if cty15g00_verifica_documento(g_documento.succod
                                 ,g_documento.ramcod
                                 ,g_documento.aplnumdig
                                 ,g_documento.itmnumdig
                                 ,""
                                 ,""
                                 ,"") then

      call cts08g01("A", "N",
                    " ",
                    "CLIENTE COM OUTROS SEGUROS ATIVOS.",
                    "CONSULTE (F1) - CLIENTES!",
                    " ")
      returning l_confirma

   end if


  # Atendendo a Solicitacao AS-2012-01100

  if ws.rmemdlcod        = 3         and
     d_cta01m20.ramcod   = 114       and
     d_cta01m20.corsus   = "33217J"  and
     d_cta01m20.situacao = "ATIVA"   then

     call cts08g01("A","N",
                   "ACORDO APSA: LIBERAR ATENDIMENTO ",
                   "DE REPAROS ELETRICOS E DESENTUPIMENTO ",
                   "PELO CENTRO DE CUSTO 11.964 (S64)",
                   "")
     returning ws.confirma


  end if



 #-------------------------------------------------------------
 # Exibe clausulas da apolice e habilita teclas de funcao
 #-------------------------------------------------------------
 if g_documento.lclnumseq is null then
    let g_documento.lclnumseq = 1
 end if
 let int_flag  = false
 call cta01m26(d_cta01m20.ramcod, d_cta01m20.subcod,
               r_cta01m20.prporg, r_cta01m20.prpnumdig,
               g_documento.lclnumseq    , ws.rmemdlcod,
               ws.sgrorg        , ws.sgrnumdig,
               d_cta01m20.viginc, d_cta01m20.vigfnl,
               ws.dctnumseq)

 #--------------------------------------------------------
 # Chama o Processo da Contigencia Online
 #--------------------------------------------------------
 call cty42g00(g_documento.ciaempcod ,
               g_documento.succod    ,
               g_documento.ramcod    ,
               g_documento.aplnumdig ,
               g_documento.itmnumdig ,
               ws.cgccpfnum          ,
               ws.cgcord             ,
               ws.cgccpfdig          ,
               ""                    )
 close window w_cta01m20
 let int_flag = false

end function     ##--  cta01m20


#-------------------------------------------------------------------------------
 function cta01m20_vercaren(param)
#-------------------------------------------------------------------------------

 define param    record
    sgrorg       like rsdmdocto.sgrorg,
    sgrnumdig    like rsdmdocto.sgrnumdig
 end record

 define ws2      record
    viginc       like rsdmdocto.viginc,
    prporg       like rsdmdocto.prporg,
    prpnumdig    like rsdmdocto.prpnumdig,
    rscgracod    like rsdmlocal.rscgracod,
    carencia     char (38),
    crcdat       date
 end record




	initialize  ws2.*  to  null

 initialize ws2.*  to null

 #-------------------------------------------------------------
 # Verifica endossos: (00)Apolice, (45)Reintegracao
 #-------------------------------------------------------------
 select viginc    , prporg    , prpnumdig
   into ws2.viginc, ws2.prporg, ws2.prpnumdig
   from rsdmdocto
  where sgrorg    = param.sgrorg      and
        sgrnumdig = param.sgrnumdig   and
        dctnumseq = (select max(dctnumseq)
                       from rsdmdocto
                      where sgrorg     = param.sgrorg     and
                            sgrnumdig  = param.sgrnumdig  and
                            edstip     in (00,45)         and
                            prpstt     in (19,66,88))

 #-------------------------------------------------------------
 # Verifica pelo grau de risco se existe carencia ou nao
 #-------------------------------------------------------------
 select rscgracod
   into ws2.rscgracod
   from rsdmlocal
  where prporg    = ws2.prporg     and
        prpnumdig = ws2.prpnumdig  and
        lclnumseq = g_documento.lclnumseq

 if ws2.rscgracod  =  1   then
    let ws2.crcdat   = ws2.viginc + 29 units day
    let ws2.carencia = "ATENDIMENTO C/ CARENCIA ATE ", ws2.crcdat
 else
    let ws2.carencia = "ATENDIMENTO SEM CARENCIA"
 end if

 return ws2.carencia

end function     ##--  cta01m20_vercaren

