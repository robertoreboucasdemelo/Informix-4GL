 ############################################################################
 # Nome do Modulo: CTA01M04                                        Pedro    #
 #                                                                 Marcelo  #
 # Mostra outras informacoes da apolice                            Ago/1995 #
 #--------------------------------------------------------------------------#
 # 19/03/2001   12756-6   Raji        Inclusao do motorista do perfil.      #
 #--------------------------------------------------------------------------#
 # 18/07/2001             Ruiz        Inclusao da tecla (F5) para consulta  #
 #                                    do telefone do segurado.              #
 #--------------------------------------------------------------------------#
 # 27/12/2001   14451-7   Ruiz        Inclusao da tecla (F6) para consulta  #
 #                                    do e-mail do segurado.                #
 # 17/06/2003   174882    Amaury      Tarifa Julho/2003                     #
 # 14/09/2004  CT 244716  Katiucia    Trocar variavel de acesso a tabela    #
 # 16/10/2008  PSI 223689  Roberto                                          #
 #                                                                          #
 #                                    Inclusao da funcao figrc072():        #
 #                                    essa funcao evita que o programa      #
 #                                    caia devido ha uma queda da           #
 #                                    instancia da tabela de origem para    #
 #                                    a tabela de replica                   #
 #                                                                          #
 #############################################################################


globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/figrc072.4gl"

define m_host       like ibpkdbspace.srvnom
#-----------------------------------------------------------
 function cta01m04(param)
#-----------------------------------------------------------

 define param      record
    clcdat         like abbmcasco.clcdat   ,
    ctgtrfcod      like abbmcasco.ctgtrfcod,
    clalclcod      like abbmdoc.clalclcod  ,
    frqclacod      like abbmcasco.frqclacod,
    edsviginc      like abbmdoc.viginc     ,
    edsvigfnl      like abbmdoc.vigfnl     ,
    autrevflg      char (01)
 end record

 define a_cta01m04 array[100] of record
    inftxt         char (60)
 end record

 define ws         record
    qstcod    like abbmquesttxt.qstcod,
    txtlin    like abbmquesttxt.txtlin,
    qstdes    like apqkquest.qstdes,
    rspcod    like abbmquestionario.rspcod,
    rspdat    like abbmquestionario.rspdat,
    c18tipcod like abbmquesttxt.c18tipcod,
    segnumdig like abbmdoc.segnumdig,
    dctnumseq like abbmdoc.dctnumseq,
    edsnumref like abamdoc.edsnumdig,
    dddcod    like gsakend.dddcod,
    teltxt    like gsakend.teltxt
 end record

 define l_azlaplcod   like datkazlapl.azlaplcod,
        l_resultado   smallint,
        l_mensagem    char(80),
        l_observacoes char(6000),
        l_doc_handle  integer,
        l_i           smallint,
        l_quebra      smallint,
        l_iquebra     smallint,
        l_fquebra     smallint,
        l_tam_array   smallint,
        l_st_erro     smallint,
        l_msg         char(100)

 define lr_segurado record
        nome        char(60),
        cgccpf      char(15),
        pessoa      char(01),
        dddfone     char(05),
        numfone     char(15),
        email       char(100)
 end record

 define lr_obs      record
        obs1        char(2000),
        obs2        char(2000),
        obs3        char(2000)
 end record

 define w_dsctxt   char(80)
 define arr_aux    smallint
 define l_subrspcod smallint
       ,l_rspsubrspdes  char(250)

 define l_dctnumseq like abbmquesttxt.dctnumseq
 define l_sql      char(1000)

        define  w_pf1   integer

        let     w_dsctxt  =  null
        let     arr_aux  =  null

        for     w_pf1  =  1  to  100
                initialize  a_cta01m04[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

 let l_azlaplcod   = null
 let l_resultado   = null
 let l_mensagem    = null
 let l_doc_handle  = null
 let l_observacoes = null
 let l_i           = 0
 let l_quebra      = 0
 let l_iquebra     = 0
 let l_fquebra     = 0
 let l_tam_array   = 0
 let l_st_erro     = 1
 let m_host        = null
 #Chamado 13127781
 let m_host = fun_dba_servidor("EMISAUTO")
  call cta13m00_verifica_status(m_host)
      returning l_st_erro
               ,l_msg
 if l_st_erro = true then
    let m_host = fun_dba_servidor("CT24HS")
 end if

 initialize lr_segurado.* to null
 initialize lr_obs.* to null

 open window cta01m04 at 10,13 with form "cta01m04"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_cta01m04  to null

 if g_documento.ciaempcod = 35 then # -> AZUL SEGURADORA

    # -> BUSCA O CODIGO DA APOLICE
    call ctd02g01_azlaplcod(g_documento.succod,
                            g_documento.ramcod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.edsnumref)

         returning l_resultado,
                   l_mensagem,
                   l_azlaplcod

    if l_resultado <> 1 then
       error l_mensagem
       sleep 4
       return
    end if

    if l_azlaplcod is not null then
       # -> BUSCA OS DADOS DO XML DA APOLICE
       let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)

       # -> BUSCA OS DADOS DO SEGURADO
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "SEGURADO")
            returning lr_segurado.nome,
                      lr_segurado.cgccpf,
                      lr_segurado.pessoa,
                      lr_segurado.dddfone,
                      lr_segurado.numfone,
                      lr_segurado.email

       # -> BUSCA OS DADOS DAS OBSERVACOES
        call cts40g02_extraiDoXML(l_doc_handle,
                                  "OBSERVACOES")
             returning lr_obs.obs1,
                       lr_obs.obs2,
                       lr_obs.obs3

       # -> MONTA OS DADOS NO ARRAY
       let a_cta01m04[1].inftxt = "SEGURADO:"
       let a_cta01m04[2].inftxt = "  NOME: ",  lr_segurado.nome    clipped
       let a_cta01m04[3].inftxt = "  FONE: ",  lr_segurado.dddfone clipped, " ",
                                               lr_segurado.numfone
       let a_cta01m04[4].inftxt = "  EMAIL: ", lr_segurado.email   clipped

       let a_cta01m04[5].inftxt = " "
       let a_cta01m04[6].inftxt = "OBSERVACOES:"

       let l_observacoes = lr_obs.obs1 clipped,
                           lr_obs.obs2 clipped,
                           lr_obs.obs3 clipped

       # -> DIVIDE AS OBSERVACOES DE 60 EM 60 CARACTERES PARA EXIBIR NO ARRAY
       let l_tam_array = 6
       for l_i = 1 to length(l_observacoes)
          let l_quebra = (l_quebra + 1)
          if l_quebra = 60 then
             let l_quebra    = 0
             let l_iquebra   = ((l_i - 60)+1)
             let l_fquebra   = l_i
             let l_tam_array = (l_tam_array + 1)

             if l_tam_array > 100 then
                error
                "Limite do array superado! cta01m04.4gl" sleep 3
                exit for
             end if

             # -> JOGA A INFORMACAO NO ARRAY
             let a_cta01m04[l_tam_array].inftxt =
                 l_observacoes[l_iquebra,l_fquebra]
          end if
       end for

       # -> CARACTERES QUE SOBRARAM
       if l_quebra <> 0 then
          let l_iquebra   = (l_i - l_quebra)
          let l_fquebra   = l_i
          let l_tam_array = (l_tam_array + 1)

          if l_tam_array > 100 then
             error
             "Limite do array superado! cta01m04.4gl" sleep 3
             return
          end if
          # -> JOGA A INFORMACAO NO ARRAY
          let a_cta01m04[l_tam_array].inftxt =
              l_observacoes[l_iquebra,l_fquebra]
       end if

       # -> RECEBE O TAMANHO DO ARRAY
       let arr_aux = l_tam_array

       message " (F17)Abandona"

    else
       error "AZLAPLCOD esta nulo ! cta01m04.4gl" sleep 4
       return
    end if
 else
    whenever error continue

    let w_dsctxt = "NAO ENCONTRADA"

    select ctgtrfdes
      into w_dsctxt
      from itatvig, agekcateg
     where itatvig.tabnom       =  "agekcateg"    and
           itatvig.viginc      <=  param.clcdat   and
           itatvig.vigfnl      >=  param.clcdat   and
           agekcateg.tabnum     =  itatvig.tabnum and
           agekcateg.ramcod     in (31,531)       and
           agekcateg.ctgtrfcod  =  param.ctgtrfcod

    if sqlca.sqlcode < 0  then
       let w_dsctxt = "NAO DISPONIVEL NO MOMENTO!"
    end if

    let arr_aux = 01
    let a_cta01m04[arr_aux].inftxt = "Categ.Tarif: ", w_dsctxt

    let arr_aux = arr_aux + 2

    select clalcldes
      into w_dsctxt
      from itatvig, agekregiao
     where itatvig.tabnom       =  "agekregiao"   and
           itatvig.viginc      <=  param.clcdat   and
           itatvig.vigfnl      >=  param.clcdat   and
           agekregiao.tabnum    =  itatvig.tabnum and
           agekregiao.clalclcod =  param.clalclcod

    if sqlca.sqlcode < 0  then
       let a_cta01m04[arr_aux].inftxt = "Clas.Local.: ",param.clalclcod,"-",
                                        "NAO DISPONIVEL NO MOMENTO!"
    end if

    if sqlca.sqlcode = notfound  then
       let a_cta01m04[arr_aux].inftxt = "Clas.Local.: ",param.clalclcod,"-",
                                        "NAO ENCONTRADA"
    else
       let a_cta01m04[arr_aux].inftxt = "Clas.Local.: ",param.clalclcod,"-",
                                        w_dsctxt[01,40]
       if w_dsctxt[40,80]   is not null                     and
          w_dsctxt[40,80]   <>     "                    "   then
          let arr_aux = arr_aux + 1
          let a_cta01m04[arr_aux].inftxt = "             ",
                                           w_dsctxt[40,80]
       end if
    end if

    whenever error stop

    let arr_aux = arr_aux + 2
    let w_dsctxt = "NAO ENCONTRADA"

    select cpodes
      into w_dsctxt
      from iddkdominio
     where cponom  =  "frqclacod"    and
           cpocod  =  param.frqclacod

    let a_cta01m04[arr_aux].inftxt = "Franquia...: ",
                                     w_dsctxt

    if param.edsviginc is not null   and
       param.edsvigfnl is not null   then
       let arr_aux = arr_aux + 2
       let a_cta01m04[arr_aux].inftxt = "Vig.Endosso: ", param.edsviginc,
                                        " a ", param.edsvigfnl
    end if

    if param.autrevflg = "S"  then
       let arr_aux = arr_aux + 2

       let l_sql = " select nfscnsnom      "
                  ,"   from porto@",m_host clipped,":abbm0km "
                  ,"  where succod = ?     "
                  ,"    and aplnumdig = ?  "
                  ,"    and itmnumdig = ?  "
                  ,"    and dctnumseq = ?  "
       prepare pcta01m04001 from l_sql
       declare ccta01m04001 cursor with hold for pcta01m04001
       whenever error continue

 			 open ccta01m04001 using g_documento.succod
 			                        ,g_documento.aplnumdig
 			                        ,g_documento.itmnumdig
 			                        ,g_funapol.vclsitatu
 			  fetch ccta01m04001 into w_dsctxt

       if sqlca.sqlcode < 0  then
          let w_dsctxt = "NAO DISPONIVEL NO MOMENTO!"
       end if

       let a_cta01m04[arr_aux].inftxt = "Concession.: ", w_dsctxt

       whenever error stop
    end if

    # -- CT 244716 - Katiucia -- #
    let l_dctnumseq = null
    if g_funapol.autsitatu is not null then
       let l_dctnumseq = g_funapol.autsitatu
    else
       if g_funapol.dmtsitatu is not null then
          let l_dctnumseq = g_funapol.dmtsitatu
       else
          if g_funapol.dpssitatu is not null then
             let l_dctnumseq = g_funapol.dpssitatu
          else
             if g_funapol.appsitatu is not null then
                let l_dctnumseq = g_funapol.appsitatu
             end if
          end if
       end if
    end if

    ####  QUESTIONARIO DO PERFIL  ####
    let w_dsctxt = "PERFIL"
    let l_sql = " select qstcod                                    "
               ,"       ,txtlin                                    "
               ,"       ,0                                         "
               ,"       ,today                                     "
               ,"       ,c18tipcod                                 "
               ,"   from porto@",m_host clipped,":abbmquesttxt     "
               ,"  where succod = ?                                "
               ,"    and aplnumdig = ?                             "
               ,"    and itmnumdig = ?                             "
               ,"    and dctnumseq = ?                             "
               ," union                                            "
               ," select qstcod                                    "
               ,"       ,' '                                       "
               ,"       ,rspcod                                    "
               ,"       ,rspdat                                    "
               ,"       ,c18tipcod                                 "
               ,"   from porto@",m_host clipped,":abbmquestionario "
               ,"  where succod = ?                                "
               ,"    and aplnumdig = ?                             "
               ,"    and itmnumdig = ?                             "
               ,"    and dctnumseq = ?                             "
               ,"    order by 1                                    "
    prepare pcta01m04002 from l_sql
    declare ccta01m04002 cursor with hold for pcta01m04002

    open ccta01m04002 using g_documento.succod
 			                     ,g_documento.aplnumdig
 			                     ,g_documento.itmnumdig
 			                     ,l_dctnumseq
 			                     ,g_documento.succod
 			                     ,g_documento.aplnumdig
 			                     ,g_documento.itmnumdig
 			                     ,l_dctnumseq

    foreach ccta01m04002 into ws.qstcod
                             ,ws.txtlin
                             ,ws.rspcod
                             ,ws.rspdat
                             ,ws.c18tipcod

       select qstdes
              into ws.qstdes
         from apqkquest
        where qstcod = ws.qstcod
          and viginc <= today
          and vigfnl >= today

       #-----> PSI 174882
       let l_subrspcod    = 0
       let l_rspsubrspdes = null
       call apgtsubrspap_exibe_subresposta(g_documento.succod
                                          ,g_documento.aplnumdig
                                          ,g_documento.itmnumdig
                                          ,l_dctnumseq
                                          ,param.clcdat
                                          ,ws.qstcod
                                          ,ws.rspcod
                                          ,1)
            returning l_subrspcod
                     ,l_rspsubrspdes
       if l_rspsubrspdes is not null then
          let ws.txtlin = l_rspsubrspdes
       end if
       #------>

       if ws.txtlin  = " "  then
          if ws.rspcod = 0 then
             let ws.txtlin = ws.rspdat
          else
             select qstrspdsc
               into ws.txtlin
               from apqkdominio
              where rspcod = ws.rspcod
                and qstcod = ws.qstcod
                and viginc <= param.clcdat
                and vigfnl >= param.clcdat
          end if
       end if

       if w_dsctxt = "PERFIL" then
          select cpodes
                 into w_dsctxt
            from iddkdominio
           where cponom = "c18tipcod"
             and cpocod = ws.c18tipcod

          let arr_aux = arr_aux + 2
          let a_cta01m04[arr_aux].inftxt =
              "######### QUESTIONARIO DO PERFIL ######### ",
              w_dsctxt clipped,
              " #########################################"
          let w_dsctxt = ""
       end if

       let arr_aux = arr_aux + 2
       let a_cta01m04[arr_aux].inftxt = ws.qstdes
       let arr_aux = arr_aux + 1
       let a_cta01m04[arr_aux].inftxt = ws.txtlin
    end foreach

    if arr_aux > 09  then
       message " (F17)Abandona (F3)Prox pag (F4)Pag.ant (F5)Telef. (F6)E-mail"
    else
       message " (F17)Abandona (F5)Telef. (F6)E-mail"
    end if

  end if

  call set_count(arr_aux)

  display array a_cta01m04 to s_cta01m04.*
     on key (interrupt,control-c,f17)
        initialize a_cta01m04 to null
        exit display

     on key (F5)
        call f_funapol_ultima_situacao
             (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
                      returning g_funapol.*

        if g_funapol.dctnumseq is null  then
           select min(dctnumseq)
             into g_funapol.dctnumseq
             from abbmdoc
            where succod    = g_documento.succod
              and aplnumdig = g_documento.aplnumdig
              and itmnumdig = g_documento.itmnumdig
        end if
       #-----------------------------------------------------------------------
       # Numero do endosso
       #-----------------------------------------------------------------------
        select edsnumdig
          into ws.edsnumref
          from abamdoc
         where abamdoc.succod    =  g_documento.succod      and
               abamdoc.aplnumdig =  g_documento.aplnumdig   and
               abamdoc.dctnumseq =  g_funapol.dctnumseq
        if sqlca.sqlcode = notfound  then
           let ws.edsnumref = 0
        end if
       #----------------------------------------------------------------------
       # Se a ultima situacao nao for encontrada, atualiza ponteiros novamente
       #----------------------------------------------------------------------
        if g_funapol.resultado = "O"  then
           call f_funapol_auto(g_documento.succod   , g_documento.aplnumdig,
                               g_documento.itmnumdig, ws.edsnumref)
                     returning g_funapol.*
        end if
        select segnumdig
          into ws.segnumdig
          from abbmdoc
         where abbmdoc.succod    =  g_documento.succod      and
               abbmdoc.aplnumdig =  g_documento.aplnumdig   and
               abbmdoc.itmnumdig =  g_documento.itmnumdig   and
               abbmdoc.dctnumseq =  g_funapol.dctnumseq

         call figrc072_setTratarIsolamento()

         call cty17g00_ssgttel (2,ws.segnumdig, g_documento.c24soltipcod)## psi201987

         if g_isoAuto.sqlCodErr <> 0 then
            error "Atualizacao de Telefone Temporariamente Indisponivel! Erro: "
                  ,g_isoAuto.sqlCodErr
         end if

     on key (F6)
        call f_funapol_ultima_situacao
             (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
                      returning g_funapol.*

        if g_funapol.dctnumseq is null  then
           select min(dctnumseq)
             into g_funapol.dctnumseq
             from abbmdoc
            where succod    = g_documento.succod
              and aplnumdig = g_documento.aplnumdig
              and itmnumdig = g_documento.itmnumdig
        end if
       #-----------------------------------------------------------------------
       # Numero do endosso
       #-----------------------------------------------------------------------
        select edsnumdig
          into ws.edsnumref
          from abamdoc
         where abamdoc.succod    =  g_documento.succod      and
               abamdoc.aplnumdig =  g_documento.aplnumdig   and
               abamdoc.dctnumseq =  g_funapol.dctnumseq
        if sqlca.sqlcode = notfound  then
           let ws.edsnumref = 0
        end if
       #----------------------------------------------------------------------
       # Se a ultima situacao nao for encontrada, atualiza ponteiros novamente
       #----------------------------------------------------------------------
        if g_funapol.resultado = "O"  then
           call f_funapol_auto(g_documento.succod   , g_documento.aplnumdig,
                               g_documento.itmnumdig, ws.edsnumref)
                     returning g_funapol.*
        end if
        select segnumdig
          into ws.segnumdig
          from abbmdoc
         where abbmdoc.succod    =  g_documento.succod      and
               abbmdoc.aplnumdig =  g_documento.aplnumdig   and
               abbmdoc.itmnumdig =  g_documento.itmnumdig   and
               abbmdoc.dctnumseq =  g_funapol.dctnumseq

        call figrc072_setTratarIsolamento()

        call cty17g00_ssgtemail(ws.segnumdig,g_documento.c24soltipcod) ## psi201987

        if g_isoAuto.sqlCodErr <> 0 then
           error "Atualizacao do E-mail Temporariamente Indisponivel! Erro: "
                 ,g_isoAuto.sqlCodErr
        end if

  end display

 close window  cta01m04
 let int_flag = false

end function  ###  cta01m04
