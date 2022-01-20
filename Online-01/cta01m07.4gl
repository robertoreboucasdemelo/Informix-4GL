###############################################################################
# Nome do Modulo: CTA01M07                                           Gilberto #
#                                                                     Marcelo #
# Recalcula valor a pagar para parcela selecionada                   Set/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 19/04/1999  PSI 8181-7   Wagner       Fazer acesso a rotina cobranca para   #
#                                       informar taxa de reativacao.          #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------------
 function cta01m07(param)
#---------------------------------------------------------------------

 define param       record
    succod          like fctrpevparc.succod,
    ramcod          like fctrpevparc.ramcod,
    aplnumdig       like fctrpevparc.aplnumdig,
    segtip          like abamapol.segtip,
    parnum          like fctrpevparc.parnum,
    titnumdig       like fctmtitulos.titnumdig,
    vctdat          like fctmtitulos.vctdat,
    parvlr          like fctmtitulos.parvlr,
    edstipdes       char(40)
 end record

 define d_cta01m07  record
    estvctdat       like fctmtitulos.vctdat,
    qtddias         integer,
    jrstx           like fcgtminimo.atzjurtax,
    vlrjrs          dec(15,2),
    vlrcor          dec(15,2),
    obs             char(40)
 end record

 define ws          record
    itmnumdig       like abbmitem.itmnumdig,
    edsnumref       like fctrpevparc.edsnumdig,
    grlinf          char(06),
    datatu          date,
    dialimpgt       integer,
    dialimvct       integer,
    dialimvct2      integer,
    vctsgndat       like fctmvctalt.vctsgndat,
    vstlimdat       date,
    vctaltflg       char(01),
    diasem          integer,
    sqlcode         integer,
    prxdatutil      date,
    status          integer,
    inadimplente    smallint,
    edsstt          char(1),
    vigini          date,
    vigfin          date,
    przctodia       smallint,
    przfincob       date,
    prmlipag        dec(15,5),
    prmliqdev       dec(15,5),
    segtip          like abamapol.segtip,
    mens            char(90),
    msglin1         char(40),
    msglin2         char(40),
    msglin3         char(40),
    msglin4         char(40),
    confirma        char(1),
    dctrtvtax       like fcgtminimo.dctrtvtax,
    itmqtd          integer
 end record

 define l_host      like ibpkdbspace.srvnom #Saymon ambnovo
 define l_sql       char(500) #Saymon ambnovo



	initialize  d_cta01m07.*  to  null

	initialize  ws.*  to  null

 initialize d_cta01m07.*  to null
 initialize ws.*          to null
 let ws.datatu            = today
 let ws.dctrtvtax         = 0

 #------------Saymon---------------------#
 # Carrega host do banco de dados        #
 #---------------------------------------#
 #ambnovo
 let l_host = fun_dba_servidor("CPAGAR")
 #ambnovo

 #---------------------------------------------------------------------
 # Carrega limite de dias permitido para o recalculo das parcelas
 #---------------------------------------------------------------------
 let l_sql = 'select grlinf                 '
            ,'  from porto@',l_host clipped,':igbkgeral '
            ,' where mducod  =  "FCT"   and '
            ,'       grlchv  =  "CENTRAL"   '

 prepare p_cta01m07_01 from  l_sql
 declare c_cta01m07_01 cursor with hold for p_cta01m07_01

 open c_cta01m07_01
 whenever error stop
 fetch c_cta01m07_01 into ws.grlinf
 whenever error continue
 if sqlca.sqlcode <> 0   then
    error " Erro (",sqlca.sqlcode,") no limite de dias, AVISE INFORMATICA!"
    sleep 4
    return
 end if

 let ws.dialimpgt  =  ws.grlinf[1,2]
 let ws.dialimvct  =  ws.grlinf[3,4]
 let ws.dialimvct2 =  ws.grlinf[5,6]

 #---------------------------------------------------------------------
 # Verifica se apolice de seguro mensal/Troca limite de dias de vencto
 #---------------------------------------------------------------------
 if (param.ramcod  = 31   or
     param.ramcod  = 531) and
    param.segtip  = 2    then
    let ws.dialimvct = ws.dialimvct2
 end if

 #---------------------------------------------------------------------
 # Verifica se titulo tem vencimento alternativo
 # Calcula data limite para vistoria/carta de isencao
 #---------------------------------------------------------------------
 select vctsgndat
   into ws.vctsgndat
   from fctmvctalt
  where titnumdig = param.titnumdig

 if sqlca.sqlcode <> 0     and
    sqlca.sqlcode <> 100   then
    error " Erro (",sqlca.sqlcode,") no vencto alternativo, AVISE INFORMATICA!"
    sleep 4
    return
 end if

 open window cta01m07 at 6,2 with form "cta01m07"
      attribute (form line first, comment line last - 1)

 if ws.vctsgndat  is not null   then   #--> Vencto alternativo
    display " VENCTO ALTERNATIVO"  to  vctaltdes  attribute(reverse)
 end if

 display by name  param.titnumdig
 display by name  param.parnum
 display by name  param.parvlr
 display by name  param.vctdat
 display by name  param.edstipdes

 message " (F17)Abandona, (F8)Vencto alternativo"

 let ws.itmnumdig  = g_documento.itmnumdig
 let ws.edsnumref  = 0   # ruiz
 if ws.itmnumdig  is null then
    let ws.itmnumdig  = 0
 end if

 let ws.itmqtd = 0
 select count(*)
   into ws.itmqtd
   from abbmitem
  where succod    = param.succod
    and aplnumdig = param.aplnumdig

 if ws.itmqtd > 1  then
   #let ws.itmnumdig = 0   # --> APOLICE COLETIVA
    let ws.edsnumref = g_documento.edsnumref  # ruiz
 end if

 if param.segtip = 1  then
    # ---> TIPO DE SEGURO NORMAL
    call ffcic062_inad(param.succod,
                       param.ramcod,
                       param.aplnumdig,
                      #0,
                       ws.edsnumref,  # ruiz
                       ws.itmnumdig,
                       today)
             returning ws.status,
                       ws.inadimplente,
                       ws.edsstt,
                       ws.vigini,
                       ws.vigfin,
                       ws.przctodia,
                       ws.przfincob,
                       ws.prmlipag,
                       ws.prmliqdev,
                       ws.segtip,
                       ws.mens

    if ws.status = 0 then
       if ws.inadimplente = 0 then
          let ws.vstlimdat = ws.vigfin      # <-- data cobertura adimpl.
       else
          if ws.przfincob < today then
             initialize ws.msglin1 to null
             let ws.msglin1 = "SEM COBERTURA DESDE : ",ws.przfincob
             call cts08g01("I","N", "", "", ws.msglin1, "")
                            returning ws.confirma
          end if
          let ws.vstlimdat = ws.przfincob   # <-- data cobertura inadimpl.
       end if
    else
       if ws.mens[1,40] = "Documento nao possui cobranca" then
          let ws.mens[1,40]="Favor Transferir Ligacao para Cobranca, "
          let ws.mens[41,80]="documento com problemas para calculo das"
          let ws.mens[81,90]=" parcelas."
       end if
       call cts08g01("A","N", "", ws.mens[1,40],ws.mens[41,80],ws.mens[81,90])
                      returning ws.confirma
       sleep 4
       close window cta01m07
       return
    end if
 else
    # ---> TIPO DE SEGURO MENSAL
    if param.vctdat < today  then
       call cts08g01("I","N", "", "APOLICE MENSAL SEM COBERTURA DESDE",
                                  "A ULTIMA FATURA NAO PAGA", "")
                            returning ws.confirma
    end if
    let ws.vstlimdat = param.vctdat
 end if

 input by name d_cta01m07.estvctdat

    before field estvctdat
       display by name d_cta01m07.estvctdat  attribute (reverse)

       initialize d_cta01m07.qtddias,
                  d_cta01m07.jrstx,
                  d_cta01m07.vlrjrs,
                  d_cta01m07.vlrcor,
                  d_cta01m07.obs      to null

    after  field estvctdat
       display by name d_cta01m07.*

       if d_cta01m07.estvctdat  is null   then
          error " Data estimada deve ser informada!"
          next field estvctdat
       end if

       if d_cta01m07.estvctdat  <  today   then
          error " Data estimada nao deve ser anterior a data atual!"
          next field estvctdat
       end if

       if ws.vctsgndat   is not null   then
          if d_cta01m07.estvctdat  <=  ws.vctsgndat    then
             error " Consulte vencto alternativo!"
             next field estvctdat
          end if
       end if

       let ws.diasem = weekday(d_cta01m07.estvctdat)
       case ws.diasem
            when  0
                  error " Data estimada nao deve ser DOMINGO!"
                  next field estvctdat
            when  6
                  error " Data estimada nao deve ser SABADO!"
                  next field estvctdat
       end case

       #---------------------------------------------------------------------
       # Verifica data de vencimento dentro do limite permitido
       #---------------------------------------------------------------------
       if param.vctdat < (ws.datatu - ws.dialimvct)   then
          error " Vencto anterior ao limite de ", ws.dialimvct,
                " dias - Tratar com Depto de Cobranca!"
          next field estvctdat
       end if

       #---------------------------------------------------------------------
       # Verifica nova data de pagto (estimada) dentro do limite permitido
       #---------------------------------------------------------------------
       call cta01m07_prxdat()  returning ws.prxdatutil

       if ws.vctsgndat   is null   then
          if param.vctdat  >=  today   then
             if d_cta01m07.estvctdat > (param.vctdat + ws.dialimpgt)   then
                error " Dt estimada maior que limite (Vencto+", ws.dialimpgt,
                      " dias) - Tratar com Depto de Cobranca!"
                next field estvctdat
             end if
          else
             if d_cta01m07.estvctdat > ws.prxdatutil   then
                error " Data estimada maior que limite ", ws.prxdatutil,
                      " - Tratar com Depto de Cobranca!"
                next field estvctdat
             end if
          end if
       else
          if d_cta01m07.estvctdat > ws.prxdatutil   then
             error " Data estimada maior que limite ", ws.prxdatutil,
                   " - Tratar com Depto de Cobranca!"
             next field estvctdat
          end if
       end if

       #---------------------------------------------------------------------
       # Verifica obrigatoriedade de vistoria e taxa de reativacao
       #---------------------------------------------------------------------
       call ffcic062_inad(param.succod,
                          param.ramcod,
                          param.aplnumdig,
                         #0,                  #ruiz
                          ws.edsnumref,       #ruiz
                          ws.itmnumdig,
                          d_cta01m07.estvctdat)
                returning ws.status,
                          ws.inadimplente,
                          ws.edsstt,
                          ws.vigini,
                          ws.vigfin,
                          ws.przctodia,
                          ws.przfincob,
                          ws.prmlipag,
                          ws.prmliqdev,
                          ws.segtip,
                          ws.mens

       if ws.status = 0 then
          if ws.inadimplente = 0 then
             let ws.vstlimdat = ws.vigfin      # <-- data cobertura adimpl.
          else
             let ws.vstlimdat = ws.przfincob   # <-- data cobertura inadimpl.
          end if
       end if

       call ffcic003 (param.titnumdig, d_cta01m07.estvctdat)
            returning ws.sqlcode,
                      d_cta01m07.qtddias,
                      d_cta01m07.jrstx,
                      d_cta01m07.vlrjrs,
                      d_cta01m07.vlrcor,
                      ws.vctaltflg,       ###  Flag Vencimento Alternativo
                      d_cta01m07.obs,
                      ws.dctrtvtax

       if ws.sqlcode <> 0  then
          error " Erro (", ws.sqlcode, ") no recalculo da parcela. AVISE A INFORMATICA!"
          sleep 4
          exit input
       end if

       if ws.dctrtvtax is null then
          let ws.dctrtvtax  = 0
       end if

       initialize ws.msglin1, ws.msglin2 ,ws.msglin3, ws.msglin4 to null
       let ws.msglin1 = "PAGAMENTO EFETUADO SOMENTE NA COMPANHIA "
       let ws.msglin2 = "APOS ",ws.vstlimdat," REALIZACAO DE NOVA"
       let ws.msglin3 = "VISTORIA PREVIA"

       if d_cta01m07.estvctdat  >  ws.vstlimdat   then
          if param.ramcod  =  31  or
             param.ramcod  =  531  then
             #---------------------------------------------
             #  AUTOMOVEL
             #---------------------------------------------
             if ws.dctrtvtax <> 0 then
                let ws.msglin3 = "VISTORIA PREVIA E PAGAMENTO DE TAXA DE"
                let ws.msglin4 = "REATIVACAO DE R$ ",
                                  ws.dctrtvtax using "###&.&&"
                call cts08g01("I","N", ws.msglin1, ws.msglin2,
                                       ws.msglin3, ws.msglin4)
                               returning ws.confirma
              else
                call cts08g01("I","N", ws.msglin1," ",
                                       ws.msglin2, ws.msglin3)
                               returning ws.confirma
             end if
          else
             #---------------------------------------------
             #  RE E OUTROS
             #---------------------------------------------
             let ws.msglin2 = "MEDIANTE CARTA DE ISENCAO DE SINISTRO"
             if ws.dctrtvtax <> 0 then
                let ws.msglin3 = "E PAGAMENTO DE TAXA DE REATIVACAO "
                let ws.msglin4 = "DE R$ ",
                                  ws.dctrtvtax using "###&.&&"
                call cts08g01("I","N", ws.msglin1, ws.msglin2,
                                       ws.msglin3, ws.msglin4)
                               returning ws.confirma
              else
                call cts08g01("I","N", "", "",ws.msglin1, ws.msglin2)
                               returning ws.confirma
             end if
          end if
         else
          let ws.dctrtvtax  = 0
          if (param.ramcod  =  31   or
              param.ramcod  =  531) and
             ws.inadimplente = 1   then
             call cts08g01("I","N", ws.msglin1," ",
                                    ws.msglin2, ws.msglin3)
                            returning ws.confirma
          end if
       end if

       let d_cta01m07.vlrcor =  d_cta01m07.vlrcor + ws.dctrtvtax

       display by name d_cta01m07.qtddias,
                       d_cta01m07.jrstx,
                       d_cta01m07.vlrjrs,
                       ws.dctrtvtax,
                       d_cta01m07.vlrcor,
                       d_cta01m07.obs    attribute(reverse)

       next field estvctdat

    on key (interrupt)
       exit input

    on key (F8)
       call cta01m08(param.titnumdig)

 end input

 close window cta01m07

end function  ###  cta01m07


#---------------------------------------------------------------------
 function cta01m07_prxdat()
#---------------------------------------------------------------------

 define ws2         record
    prxdatutil      date,
    diasem          integer,
    qtddia          integer,
    cont            integer
 end record




	initialize  ws2.*  to  null

 let ws2.cont   = 0
 let ws2.qtddia = 1

 while true

    if ws2.qtddia  >  3   then
       exit while
    end if

    let ws2.prxdatutil = today + ws2.cont units day
    let ws2.diasem     = weekday(ws2.prxdatutil)

    let ws2.cont       = ws2.cont + 1

    if ws2.diasem  =  0   or
       ws2.diasem  =  6   then
       continue while
    end if

    let ws2.qtddia = ws2.qtddia + 1

 end while

 return ws2.prxdatutil

end function  ###  cta01m07_prxdat

