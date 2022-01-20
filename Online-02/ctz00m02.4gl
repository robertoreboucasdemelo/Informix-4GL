#----------------------------------------------------------------------------#
#                      Porto Seguro Cia Seguros Gerais                       #
#............................................................................#
# Sistema........: CRM                                                       #
# Modulo.........: ctz00m02                                                  #
# Objetivo.......:                                                           #
# Analista Resp. : Rafael Oliveira                                           #
# PSI            : PR-2011-2011-02439                                        #
#............................................................................#
# Desenvolvimento: Eduardo Marques, META                                     #
# Liberacao      :                                                           #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

#globals '/homedsa/projetos/geral/globals/apglglob.4gl'
globals '/homedsa/projetos/geral/globals/glct.4gl'
#globals "/projetos/madeira/D0103627/hdk_funeral/glct.4gl"

database porto

define m_prep        smallint



define m_prep_sql   smallint   # Alberto CRM
define m_prep_sql1  smallint   # Alberto CRM
define m_prep_sql2  smallint   # Alberto CRM

#================================= Integracao HDK - Funeral ======================================

# Cópia do cta01m00, sem apresentar em telas.
#----------------------------------------#
 function ctz00m02_prep()
#----------------------------------------#
 define l_sql      char(500)

 let l_sql =  ' select first 1  legsisnom                    '
             ,' from   datmifxsblitg                         '
             ,' where  atdusrmatcod = ?                      '
             ,' and    legsisltrflg = 0                      '
             ,' and    legsisnom = "CENTRAL24H"              '
             ,' order by envdat desc                         '

 prepare pctz00m01003 from l_sql
 declare cctz00m01003 cursor for pctz00m01003

 let m_prep_sql2 = true

end function

#---------------------------------------#
 function ctz00m02_espaut_prep()
#---------------------------------------#
 define l_sql      char(500)

 let l_sql = ' select corsus, solnom, atlult, cortrftip '
            ,'   from apbmcortrans '
            ,'  where succod = ?    '
            ,'    and aplnumdig = ? '
            ,'    and itmnumdig = ? '

 prepare pctz00m01001 from l_sql
 declare cctz00m01001 cursor for pctz00m01001

 let m_prep_sql = true

end function

#-----------------------------------------------------------
 function ctz00m02_espaut()
#-----------------------------------------------------------


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

 define d_cta01m00     record
    edsnumref          like abamdoc.edsnumref  ,
    edstipdes          like agdktip.edstipdes  ,
    segnumdig          like gsakseg.segnumdig  ,
    segnom             like gsakseg.segnom     ,
    segteltxt          like gsakend.teltxt     ,
    cvnnom             char (25)               ,
    cornom             like gcakcorr.cornom    ,
    corsus             like gcaksusep.corsus   ,
    corteltxt          like gcakfilial.teltxt  ,
    vclmrcnom          like agbkmarca.vclmrcnom,
    vcltipnom          like agbktip.vcltipnom  ,
    vclmdlnom          like agbkveic.vclmdlnom ,
    vclchs             char (20)               ,
    vcllicnum          like abbmveic.vcllicnum ,
    vclanofbc          like abbmveic.vclanofbc ,
    vclanomdl          like abbmveic.vclanomdl ,
    obs                char (13)               ,
    emsdat             like abamapol.emsdat    ,
    viginc             like abamapol.viginc    ,
    vigfnl             like abamapol.vigfnl    ,
    cbtcod             like abbmcasco.cbtcod   ,
    cbtdes             char (19)               ,
    ctgtrfcod          like abbmcasco.ctgtrfcod,
    sitdes             char (15)               ,
    benef              char (09)               ,
    benefx             char (03)               ,
    perfil             char (05)               ,
    ituran             char (09)
 end record

 define ws             record
    segdddcod          like gsakend.dddcod     ,
    cordddcod          like gcakfilial.dddcod  ,
    vclcoddig          like agbkveic.vclcoddig ,
    vclmrccod          like agbkmarca.vclmrccod,
    vcltipcod          like agbktip.vcltipcod  ,
    vclchsinc          like abbmveic.vclchsinc ,
    vclchsfnl          like abbmveic.vclchsfnl ,
    aplstt             like abamapol.aplstt    ,
    itmsttatu          like abbmitem.itmsttatu ,
    cvnnum             like abamapol.cvnnum    ,
    edstip             like abbmdoc.edstip     ,
    edsviginc          like abbmdoc.viginc     ,
    edsvigfnl          like abbmdoc.vigfnl     ,
    clcdat             like abbmcasco.clcdat   ,
    clalclcod          like abbmdoc.clalclcod  ,
    frqclacod          like abbmcasco.frqclacod,
    imsvlr             like abbmcasco.imsvlr   ,
    autrevflg          char (01)               ,
    autrevtxt          char (13)               ,
    plcincflg          smallint                ,
    c18tipcod          like abbmquestionario.c18tipcod,
    cbtstt             like abbmvida2.cbtstt,
    benef              char (01)            ,
    ofnnumdig          like sgokofi.ofnnumdig,
    confirma           char (01),
    vclcircid          like abbmdoc.vclcircid,
    ituran             smallint              ,
    orrdat             like adbmbaixa.orrdat ,
    qtd_dispo_ativo    integer   # Projeto Instalacao de 2 DAF's em caminhoes
 end record

 define l_prporg    like datmatdlig.prporg,            #PSI172081 - robson
        l_prpnumdig like datmatdlig.prpnumdig          #PSI172081 - robson

 define l_corsus      like apbmcortrans.corsus

 define l_erro        char(60)
       ,l_erro2       char(60)

 define l_cty00g00    record
    erro              smallint
   ,mensagem          char(60)
   ,cornomsol         like gcakcorr.cornom
 end record

 define l_confirma char(1)


        initialize  r_gcakfilial.*  to  null

        initialize  d_cta01m00.*  to  null

        initialize  ws.*  to  null


 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctz00m02_espaut_prep()
 end if


 message " Aguarde, formatando os dados..."  attribute(reverse)
#--------------------------------------------------------------------------
# Inicializa variaveis
#--------------------------------------------------------------------------

 initialize d_cta01m00.*  to null
 initialize ws.*          to null

 let ws.plcincflg = true
 let l_prporg    = null                                   #PSI172081 - robson
 let l_prpnumdig = null                                   #PSI172081 - robson


#--------------------------------------------------------------------------
# Ultima situacao da apolice
#--------------------------------------------------------------------------

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
#--------------------------------------------------------------------------
# Numero do endosso
#--------------------------------------------------------------------------

 select edsnumdig, emsdat
   into d_cta01m00.edsnumref,
        d_cta01m00.emsdat
   from abamdoc
  where abamdoc.succod    =  g_documento.succod      and
        abamdoc.aplnumdig =  g_documento.aplnumdig   and
        abamdoc.dctnumseq =  g_funapol.dctnumseq

 if sqlca.sqlcode = notfound  then
    let d_cta01m00.edsnumref = 0
 end if

#--------------------------------------------------------------------------
# Se a ultima situacao nao for encontrada, atualiza ponteiros novamente
#--------------------------------------------------------------------------
 if g_funapol.resultado = "O"  then
    call f_funapol_auto(g_documento.succod   , g_documento.aplnumdig,
                        g_documento.itmnumdig, d_cta01m00.edsnumref)
              returning g_funapol.*
 end if

#--------------------------------------------------------------------------
# Numero do segurado e tipo de endosso
#--------------------------------------------------------------------------

 select segnumdig, edstip, clalclcod,
        viginc   , vigfnl, vclcircid
   into d_cta01m00.segnumdig,
        ws.edstip           ,
        ws.clalclcod        ,
        ws.edsviginc        ,
        ws.edsvigfnl        ,
        ws.vclcircid
   from abbmdoc
  where abbmdoc.succod    =  g_documento.succod      and
        abbmdoc.aplnumdig =  g_documento.aplnumdig   and
        abbmdoc.itmnumdig =  g_documento.itmnumdig   and
        abbmdoc.dctnumseq =  g_funapol.dctnumseq

 if sqlca.sqlcode <> notfound  then
    select edstipdes
      into d_cta01m00.edstipdes
      from agdktip
     where edstip = ws.edstip

#--------------------------------------------------------------------------
# Dados do segurado
#--------------------------------------------------------------------------

    whenever error continue

    select segnom into d_cta01m00.segnom
      from gsakseg
     where gsakseg.segnumdig  =  d_cta01m00.segnumdig

    whenever error stop

    if sqlca.sqlcode = notfound  then
       let d_cta01m00.segnom = "Segurado nao cadastrado!"
    else
       if sqlca.sqlcode < 0  then
          error "Dados do SEGURADO nao disponiveis no momento!"
       else
          select dddcod, teltxt
            into ws.segdddcod,
                 d_cta01m00.segteltxt
            from gsakend
           where segnumdig = d_cta01m00.segnumdig   and
                 endfld    = "1"

          let d_cta01m00.segteltxt = "(", ws.segdddcod, ") ",
                                      d_cta01m00.segteltxt
       end if
    end if
 else
    error "Documento nao encontrado!"
 end if

#--------------------------------------------------------------------------
# Dados do corretor
#--------------------------------------------------------------------------

 select corsus into d_cta01m00.corsus
   from abamcor
  where succod    = g_documento.succod         and
        aplnumdig = g_documento.aplnumdig      and
        corlidflg = "S"

 if sqlca.sqlcode = notfound   then
    let d_cta01m00.cornom = "Corretor nao cadastrado!"
 else
    if sqlca.sqlcode < 0  then
       error "Dados do CORRETOR nao disponiveis no momento!"
    else
       select cornom
         into d_cta01m00.cornom
         from gcaksusep, gcakcorr
        where gcaksusep.corsus     =  d_cta01m00.corsus   and
              gcakcorr.corsuspcp   = gcaksusep.corsuspcp

       if sqlca.sqlcode = notfound   then
          let d_cta01m00.cornom = "Corretor nao cadastrado!"
       end if

       #---> Utilizacao da nova funcao de comissoes p/ enderecamento
       initialize r_gcakfilial.* to null
       call fgckc811(d_cta01m00.corsus)
            returning r_gcakfilial.*
       let ws.cordddcod         = r_gcakfilial.dddcod
       let d_cta01m00.corteltxt = r_gcakfilial.teltxt
       #------------------------------------------------------------

       let d_cta01m00.corteltxt = "(", ws.cordddcod, ") ", d_cta01m00.corteltxt
    end if
 end if

 whenever error stop

#--------------------------------------------------------------------------
# Dados do veiculo
#--------------------------------------------------------------------------

 select vclcoddig, vclanofbc, vclanomdl,
        vcllicnum, vclchsinc, vclchsfnl
   into ws.vclcoddig        , d_cta01m00.vclanofbc,
        d_cta01m00.vclanomdl, d_cta01m00.vcllicnum,
        ws.vclchsinc        , ws.vclchsfnl
   from abbmveic
  where abbmveic.succod     = g_documento.succod     and
        abbmveic.aplnumdig  = g_documento.aplnumdig  and
        abbmveic.itmnumdig  = g_documento.itmnumdig  and
        abbmveic.dctnumseq  = g_funapol.vclsitatu

 if sqlca.sqlcode = notfound  then
    select vclcoddig, vclanofbc, vclanomdl,
           vcllicnum, vclchsinc, vclchsfnl
      into ws.vclcoddig        , d_cta01m00.vclanofbc,
           d_cta01m00.vclanomdl, d_cta01m00.vcllicnum,
           ws.vclchsinc        , ws.vclchsfnl
      from abbmveic
     where succod    = g_documento.succod       and
           aplnumdig = g_documento.aplnumdig    and
           itmnumdig = g_documento.itmnumdig    and
           dctnumseq = (select max(dctnumseq)
                          from abbmveic
                         where succod    = g_documento.succod     and
                               aplnumdig = g_documento.aplnumdig  and
                               itmnumdig = g_documento.itmnumdig)
 end if

 if sqlca.sqlcode <> notfound  then
    select vclmrccod, vcltipcod, vclmdlnom
      into ws.vclmrccod, ws.vcltipcod, d_cta01m00.vclmdlnom
      from agbkveic
     where agbkveic.vclcoddig = ws.vclcoddig

    select vclmrcnom
      into d_cta01m00.vclmrcnom
      from agbkmarca
     where vclmrccod = ws.vclmrccod

    select vcltipnom
      into d_cta01m00.vcltipnom
      from agbktip
     where vclmrccod = ws.vclmrccod    and
           vcltipcod = ws.vcltipcod

    let d_cta01m00.vclchs  =  ws.vclchsinc clipped, ws.vclchsfnl clipped
 else
    error "Dados do veiculo nao encontrado!"
 end if

#--------------------------------------------------------------------------
# Dados do item
#--------------------------------------------------------------------------

 select itmsttatu
   into ws.itmsttatu
   from abbmitem
  where succod    = g_documento.succod     and
        aplnumdig = g_documento.aplnumdig  and
        itmnumdig = g_documento.itmnumdig

 if sqlca.sqlcode <> notfound  then
    if ws.itmsttatu  = "A"  then
       let d_cta01m00.sitdes = "ATIVA"
    else
       if ws.itmsttatu  = "C"  then
          let d_cta01m00.sitdes = "CANCELADA"
       else
          let d_cta01m00.sitdes = "N/PREVISTO"
       end if
       let ws.plcincflg = false
    end if
 else
    error "Dados do item nao encontrado!"
 end if

#--------------------------------------------------------------------------
# Verifica se apolice tem Beneficio(revenda)
#--------------------------------------------------------------------------
 call fbenefic(g_documento.succod,
               g_documento.aplnumdig,
               g_documento.itmnumdig,
               g_documento.edsnumref) returning ws.benef, ws.ofnnumdig
 if ws.benef = "S"  then
    call cta01m11(ws.ofnnumdig)
 end if

 let ws.ituran = false
 call fadic005_existe_dispo(ws.vclchsinc        ,
                            ws.vclchsfnl        ,
                            d_cta01m00.vcllicnum,
                            ws.vclcoddig        ,
                            9099)
 returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo
 if ws.ituran = false then
    call fadic005_existe_dispo (ws.vclchsinc        ,
                                ws.vclchsfnl        ,
                                d_cta01m00.vcllicnum,
                                ws.vclcoddig        ,
                                1333)
      returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo
 else
    if ws.ituran = true then
       let d_cta01m00.ituran = "ITURAN  "
    else
       call fadic005_existe_dispo(ws.vclchsinc        ,
                                  ws.vclchsfnl        ,
                                  d_cta01m00.vcllicnum,
                                  ws.vclcoddig        ,
                                  1546)
       returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo

       if ws.ituran = true then
          let d_cta01m00.ituran = "TRACKER"
       else

          call fadic005_existe_dispo(ws.vclchsinc        ,
                                     ws.vclchsfnl        ,
                                     d_cta01m00.vcllicnum,
                                     ws.vclcoddig        ,
                                     3646)
          returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo  # DAF V

          if ws.ituran then
             let d_cta01m00.ituran = "DAF V"
          else
             ##PSI-2010-01746-EV
             call fadic005_existe_dispo(ws.vclchsinc        ,
                                     ws.vclchsfnl        ,
                                     d_cta01m00.vcllicnum,
                                     ws.vclcoddig        ,
                                     8001)
             returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo

             if ws.ituran = true then
                let d_cta01m00.ituran = "RASTR X3"
             else
               call fadic005_existe_dispo(ws.vclchsinc        ,
                                     ws.vclchsfnl        ,
                                     d_cta01m00.vcllicnum,
                                     ws.vclcoddig        ,
                                     8230)
                returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo
               if ws.ituran = true then
                  let d_cta01m00.ituran = "DAF VIII"
               end if
             end if
             ##PSI-2010-01746-EV
          end if
       end if
    end if
end if
#--------------------------------------------------------------------------
# Dados do casco
#--------------------------------------------------------------------------

 select cbtcod, ctgtrfcod,
        clcdat, frqclacod,
        imsvlr
   into d_cta01m00.cbtcod,
        d_cta01m00.ctgtrfcod,
        ws.clcdat,
        ws.frqclacod,
        ws.imsvlr
   from abbmcasco
  where abbmcasco.succod    = g_documento.succod     and
        abbmcasco.aplnumdig = g_documento.aplnumdig  and
        abbmcasco.itmnumdig = g_documento.itmnumdig  and
        abbmcasco.dctnumseq = g_funapol.autsitatu

#--------------------------------------------------------------------------
# Sem cobertura CASCO, obter franquia e categoria tarifaria a partir de DM
#--------------------------------------------------------------------------

 if sqlca.sqlcode = notfound  then
    select ctgtrfcod, frqclacod, clcdat
      into d_cta01m00.ctgtrfcod,
           ws.frqclacod,
           ws.clcdat
      from abbmdm
     where abbmdm.succod    = g_documento.succod     and
           abbmdm.aplnumdig = g_documento.aplnumdig  and
           abbmdm.itmnumdig = g_documento.itmnumdig  and
           abbmdm.dctnumseq = g_funapol.dmtsitatu
 end if
 if d_cta01m00.cbtcod is null  then
    initialize d_cta01m00.cbtdes to null
 else
    if d_cta01m00.cbtcod = 1  then
       let d_cta01m00.cbtdes = "COMPREENSIVA"
       if ws.imsvlr      is null or
          ws.imsvlr      =  0    then
          initialize d_cta01m00.cbtcod to null
          initialize d_cta01m00.cbtdes to null
       end if
    else
       if d_cta01m00.cbtcod = 2  then
          let d_cta01m00.cbtdes = "INCENDIO/ROUBO"
       else
          if d_cta01m00.cbtcod = 6  then
             let d_cta01m00.cbtdes = "COLISAO"
          else
             if d_cta01m00.cbtcod = 0  then
                let d_cta01m00.cbtdes = "SEM COB. CASCO"
             else
                let d_cta01m00.cbtdes = "** NAO PREVISTA **"
             end if
          end if
       end if
    end if
 end if
 -------[ categorias tarifarias que oferecem desconto ou carro extra ]-----
 let d_cta01m00.benefx = "NAO"
 if d_cta01m00.ctgtrfcod = 10 or
    d_cta01m00.ctgtrfcod = 11 or
    d_cta01m00.ctgtrfcod = 14 or
    d_cta01m00.ctgtrfcod = 15 or
    d_cta01m00.ctgtrfcod = 16 or
    d_cta01m00.ctgtrfcod = 17 or
    d_cta01m00.ctgtrfcod = 20 or
    d_cta01m00.ctgtrfcod = 21 or
    d_cta01m00.ctgtrfcod = 22 or
    d_cta01m00.ctgtrfcod = 23 or
    d_cta01m00.ctgtrfcod = 80 or
    d_cta01m00.ctgtrfcod = 81 then
    let d_cta01m00.benefx = "SIM"
 end if
 if (d_cta01m00.ctgtrfcod = 30  or   # moto
     d_cta01m00.ctgtrfcod = 31) and
    (d_cta01m00.cbtcod    = 01  and  # cobertura compreensiva
     ws.clalclcod         = 11) then # classe de localizacao sao paulo
     let d_cta01m00.benefx = "SIM"
 end if
#--------------------------------------------------------------------------
# Convenio e vigencia da apolice
#--------------------------------------------------------------------------

 select cvnnum, aplstt, viginc, vigfnl
   into ws.cvnnum         ,
        ws.aplstt         ,
        d_cta01m00.viginc ,
        d_cta01m00.vigfnl
   from abamapol
  where abamapol.succod    = g_documento.succod     and
        abamapol.aplnumdig = g_documento.aplnumdig

 if ws.aplstt  = "C"  then
    let d_cta01m00.sitdes = "CANCELADA"
    let ws.plcincflg = false
 end if

 if ws.cvnnum is not null  then
    select cpodes into d_cta01m00.cvnnom
      from datkdominio
     where cponom = "cvnnum"  and
           cpocod = ws.cvnnum
 end if

 # Verifica se o Convenio e do Itau

 if ws.cvnnum = 105 then

  call cts08g01("A","N"," *CONVENIO ITAU* ",
                        "Esta e uma apólice do convênio Itaú .",
                        "Observe os procedimentos diferenciados",
                        "a seguir e através do F1.")
           returning ws.confirma

  end if

#--------------------------------------------------------------------------
# Confere convenio escolhido pelo atendente
#--------------------------------------------------------------------------
 if ws.cvnnum <> g_documento.ligcvntip  then
    select cpocod from datkdominio
     where cponom = "ligcvntip"  and
           cpocod = ws.cvnnum

    if sqlca.sqlcode = 0  then
       let g_documento.ligcvntip = ws.cvnnum
    end if
 end if

#--------------------------------------------------------------------------
# Carrega o perfil
#--------------------------------------------------------------------------
 declare c_abbmquestionario cursor for
         select c18tipcod
           from ABBMQUESTIONARIO
                where succod    = g_documento.succod
                  and aplnumdig = g_documento.aplnumdig
                  and itmnumdig = g_documento.itmnumdig
                  and dctnumseq = g_funapol.dctnumseq
 open  c_abbmquestionario
 fetch c_abbmquestionario into ws.c18tipcod
   if  sqlca.sqlcode = 0  then
       let d_cta01m00.perfil = "PPPPP"
   else
    if  sqlca.sqlcode = 100  then
        declare c_abbmquesttxt cursor for
                select c18tipcod
                  from ABBMQUESTTXT
                       where succod    = g_documento.succod
                         and aplnumdig = g_documento.aplnumdig
                         and itmnumdig = g_documento.itmnumdig
                         and dctnumseq = g_funapol.dmtsitatu
        open  c_abbmquesttxt
        fetch c_abbmquesttxt into ws.c18tipcod
          if  sqlca.sqlcode = 0  then
              let d_cta01m00.perfil = "PPPPP"
          else
           if  sqlca.sqlcode = 100  then
               let d_cta01m00.perfil = "?????"
           else
               let d_cta01m00.perfil = "?????"
           end if
          end if
    else
        let d_cta01m00.perfil = "?????"
    end if
   end if

   if  d_cta01m00.perfil = "PPPPP"  then
       let d_cta01m00.perfil = " SIM "
   else
       let d_cta01m00.perfil = " NAO "
   end if

#--------------------------------------------------------------------------
# Auto Revendas
#--------------------------------------------------------------------------

 let ws.autrevflg = "N"

 whenever error continue

 select cndeslcod from abbmcondesp
  where abbmcondesp.succod    = g_documento.succod     and
        abbmcondesp.aplnumdig = g_documento.aplnumdig  and
        abbmcondesp.itmnumdig = g_documento.itmnumdig  and
        abbmcondesp.dctnumseq = g_funapol.dctnumseq    and
        abbmcondesp.cndeslcod = 50

 if sqlca.sqlcode = 0  then
    let ws.autrevflg = "S"
    let ws.autrevtxt = "AUTO REVENDAS"
 else
    if sqlca.sqlcode < 0  then
       error "Informacao sobre AUTO REVENDAS nao disponivel no momento!"
    end if
 end if
 whenever error stop

 ----------[ alertas para o atendente referente as suseps clara ]-------------
 case d_cta01m00.corsus
    when "P5005J"
       call cts08g01 ("A","N","",
                      "Esta apolice pertence a um FUNCIONARIO  ",
                      "da PORTO SEGURO.                        ",
                      "")
            returning ws.confirma
    when "X5005J"
       call cts08g01 ("A","N","",
                      "Esta apolice pertence a um FAMILIAR  de ",
                      "um FUNCIONARIO da PORTO SEGURO.         ",
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


#--------------------------------------------------#
# PSI172081 - Identifica atendimento em duplicidade       #PSI172081 - robson - inicio
#--------------------------------------------------#

 if g_documento.succod    is not null and
    g_documento.ramcod    is not null and
    g_documento.aplnumdig is not null and
    g_documento.itmnumdig is not null then
    if g_documento.apoio <> 'S' or
       g_documento.apoio is null then
       call cta02m20(g_documento.succod,    g_documento.ramcod,
                     g_documento.aplnumdig, g_documento.itmnumdig,
                     l_prporg, l_prpnumdig )
    end if
 end if                                                   #PSI172081 - robson - fim

 if g_documento.c24soltipcod = 2 or
    g_documento.c24soltipcod = 8 then
    let  l_corsus = null
    open cctz00m01001 using g_documento.succod
                           ,g_documento.aplnumdig
                           ,g_documento.itmnumdig
    whenever error continue
    fetch cctz00m01001 into l_corsus
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> notfound then
          error 'Erro SELECT cctz00m01001:' ,sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
          error 'cta01m00() / ', g_documento.succod,' / ', g_documento.aplnumdig,' / ', g_documento.itmnumdig sleep 2
          let int_flag = false
          return
       end if
    end if
    if l_corsus is not null then
       display "CARTA TRANSFERENCIA" at 08,57   attribute(reverse)
    end if

    # -- CT 252794 - Katiucia -- #
    if g_documento.corsus <> d_cta01m00.corsus then
       if l_corsus is null or
         (l_corsus <> g_documento.corsus and
          l_corsus <> d_cta01m00.corsus) then
          initialize l_cty00g00.* to null
          call cty00g00_nome_corretor ( g_documento.corsus )
               returning l_cty00g00.erro
                        ,l_cty00g00.mensagem
                        ,l_cty00g00.cornomsol

          let l_erro  = "INF: ",g_documento.corsus," - ",l_cty00g00.cornomsol
          let l_erro2 = "APL: ",d_cta01m00.corsus," - ",d_cta01m00.cornom
          call cts08g01("A","N","SUSEPs NAO CONFEREM",l_erro,l_erro2,"")
               returning  ws.confirma
       end if
    end if
    let g_corretor.corsusapl = d_cta01m00.corsus
    let g_corretor.cornomapl = d_cta01m00.cornom
 end if

#--------------------------------------------------------------------------
# verifica se apolice e de auto + vida
#--------------------------------------------------------------------------
  select cbtstt
      into ws.cbtstt
      from abbmvida2
      where  succod    = g_documento.succod
        and  aplnumdig = g_documento.aplnumdig
        and  itmnumdig = g_documento.itmnumdig
        and  dctnumseq =
            (select max(dctnumseq)
                from abbmvida2
               where succod     = g_documento.succod
                 and aplnumdig  = g_documento.aplnumdig
                 and  itmnumdig = g_documento.itmnumdig)
  if sqlca.sqlcode    =   0   and
     ws.cbtstt        =  "A"  then
     let d_cta01m00.obs = " AUTO + VIDA "
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

   # Alerta Tarifa Maio 2011

   if ws.edstip          = 1 or
      d_cta01m00.viginc >= "01/05/2011" then


     call cts08g01_6l("A","N",
                      "VOCE ESTA EM UMA APOLICE COM INÍCIO" ,
                      "DE VIGENCIA A PARTIR DE 01/05/11"    ,
                      "PARA DIVULGACAO DO PROCEDIMENTO"     ,
                      "REFERENTE AO DESCONTO NA FRANQUIA"   ,
                      "CONSULTE O PERCENTUAL EM"            ,
                      "F1-FUNCOES - VANTAGENS!"             )
     returning l_confirma

   end if
#--------------------------------------------------------------------------
# Exibe tela de clausulas e opcoes disponiveis
#--------------------------------------------------------------------------

 let g_monitor.horafnl   = current
 let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini

 if  g_monitor.intervalo is null or
     g_monitor.intervalo = ""    or
     g_monitor.intervalo = " "   or
     g_monitor.intervalo < "0:00:00.000" then
     let g_monitor.intervalo = "0:00:00.999"
 end if

 let  g_monitor.txt = "ESPELHO DO DOCUMENTO|", g_monitor.intervalo,"|",
                      g_issk.funmat clipped ,"|",
                      g_documento.ramcod clipped ,"|",
                      g_documento.succod clipped ,"|",
                      g_documento.aplnumdig clipped ,"|",
                      g_documento.itmnumdig


 if d_cta01m00.vcllicnum is not null  and
    d_cta01m00.vcllicnum <> " "       then
    let ws.plcincflg = false
 end if


 let int_flag = false

end function  ###  ctz00m02_espaut

#---------------------------------------------------------------------------------
###############################################################################

#------------------------------------------------------------------------------
 function ctz00m02_espre_prep()
#------------------------------------------------------------------------------

 define l_sql    char(300)

    let l_sql = " select corsus, slcnom ",
                "   from rsamcortrans  ",
                "  where sgrorg = ?    ",
                "    and sgrnumdig = ? "
    prepare pctz00m02001   from l_sql
    declare cctz00m02001   cursor for pctz00m02001

    let m_prep_sql1 = true

 end function
#-------------------------------------------------------------------------------
 function ctz00m02_espre()
#-------------------------------------------------------------------------------

 #define w_log  char(60) ## flexvision

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

 define ret_espre smallint

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
 initialize ret_espre      to null

 initialize d_cta01m20.*  to null
 initialize ws.*          to null

 let ret_espre = 0

 if ((g_documento.succod    is null   and
      g_documento.ramcod    is null   and
      g_documento.aplnumdig is null   and
      g_ppt.cmnnumdig is null)        and
     (g_documento.prporg    is null   and
      g_documento.prpnumdig is null)) then
     error "Dados da Apolice/Proposta nao informado, AVISE INFORMATICA"
     let int_flag = false
     let ret_espre = 1
     return ret_espre
 end if

 #------------------------------------------------------------
 # Procura dados da apolice
 #------------------------------------------------------------
 message " Aguarde, formatando os dados..."  attribute(reverse)

 let arr_aux = 1

 # --- PSI 172057 - Inicio ---

 if m_prep_sql1 is null or
    m_prep_sql1 <> true then
      call ctz00m02_espre_prep()
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

       if sqlca.sqlcode  <>  notfound   then
          select  dddcod, teltxt
            into  ws.dddcodseg, d_cta01m20.teltxtseg
            from  gsakend
            where segnumdig = d_cta01m20.segnumdig   and
                  endfld    = "1"

         if sqlca.sqlcode <> notfound   then
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

        if d_cta01m20.vigfnl < today   then
           let d_cta01m20.situacao = "VENCIDA"
        end if
 else

    let ret_espre = 0
    select  sgrorg   , sgrnumdig,
            rmemdlcod, subcod
      into  ws.sgrorg   , ws.sgrnumdig,
            ws.rmemdlcod, d_cta01m20.subcod
      from  rsamseguro
      where succod    = g_documento.succod     and
            ramcod    = g_documento.ramcod     and
            aplnumdig = g_documento.aplnumdig

    if sqlca.sqlcode = notfound   then
       error "Apolice nao encontrada, AVISE INFORMATICA"
       let ret_espre = 1
       let int_flag = false
       return ret_espre
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
    if sqlca.sqlcode = notfound   then
       error "Documento nao encontrado, AVISE INFORMATICA"

       let ret_espre = 1
       let int_flag = false

       return ret_espre
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

    if sqlca.sqlcode  <>  notfound   then
       select  dddcod, teltxt
         into  ws.dddcodseg, d_cta01m20.teltxtseg
         from  gsakend
         where segnumdig = d_cta01m20.segnumdig   and
               endfld    = "1"

       if sqlca.sqlcode <> notfound   then
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
       open  cctz00m02001    using  ws.sgrorg,
                                    ws.sgrnumdig
       whenever error continue
       fetch cctz00m02001    into   l_corsus, l_slcnom
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             error 'Erro de select RSAMCORTRANS' ,sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 2
             error 'cta01m20()/',ws.sgrorg, ws.sgrnumdig sleep 2
             let int_flag = false
             return
          end if
       end if
       if l_corsus is not null then
          let d_cta01m20.corretor = "CARTA TRANSFERENCIA"
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
    #display "<1445> ctz00m02-> g_rsc_re.lclrsccod    >> ", g_rsc_re.lclrsccod
    #display "<1446> ctz00m02-> g_documento.lclnumseq >> ", g_documento.lclnumseq
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

    if d_cta01m20.vigfnl < today   then
       let d_cta01m20.situacao = "VENCIDA"
    end if

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
       end if

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

return 0

end function


#-------------------------------------------------------------------------------
 function ctz00m02_vercaren(param)
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

end function     ##--  ctz00m02_vercaren

#-------------------------------------------
function ctz00m02_hdk_funeral()
#-------------------------------------------


 define lr_documento  record
        succod        like datrligapol.succod,      # Codigo Sucursal
        aplnumdig     like datrligapol.aplnumdig,   # Numero Apolice
        itmnumdig     like datrligapol.itmnumdig,   # Numero do Item
        edsnumref     like datrligapol.edsnumref,   # Numero do Endosso
        prporg        like datrligprp.prporg,       # Origem da Proposta
        prpnumdig     like datrligprp.prpnumdig,    # Numero da Proposta
        fcapacorg     like datrligpac.fcapacorg,    # Origem PAC
        fcapacnum     like datrligpac.fcapacnum,    # Numero PAC
        pcacarnum     like eccmpti.pcapticod,       # No. Cartao PortoCard
        pcaprpitm     like epcmitem.pcaprpitm,      # Item (Veiculo) PortoCard
        solnom        char (15),                    # Solicitante
        soltip        char (01),                    # Tipo Solicitante
        c24soltipcod  like datmligacao.c24soltipcod,# Tipo do Solicitante
        ramcod        like datrservapol.ramcod,     # Codigo Ramo
        lignum        like datmligacao.lignum,      # Numero da Ligacao
        c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
        ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
        atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
        atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
        sinramcod     like ssamsin.ramcod,          # Prd Parcial-Ramo sinistro
        sinano        like ssamsin.sinano,          # Prd Parcial-Ano sinistro
        sinnum        like ssamsin.sinnum,          # Prd Parcial-Num sinistro
        sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial-Itemp/ramo 53
        acao          char (03),                    # ALT, REC ou CAN
        atdsrvorg     like datksrvtip.atdsrvorg,    # Origem do tipo de Servico
        cndslcflg     like datkassunto.cndslcflg,   # Flag solicita condutor
        lclnumseq     like rsdmlocal.lclnumseq,     # Local de Risco
        vstnumdig     like datmvistoria.vstnumdig,  # numero da vistoria
        flgIS096      char (01)                  ,  # flag cobertura claus.096
        flgtransp     char (01)                  ,  # flag averbacao transporte
        apoio         char (01)                  ,  # flag atend.peloapoio(S/N)
        empcodatd     like datmligatd.apoemp     ,  # empresa do atendente
        funmatatd     like datmligatd.apomat     ,  # matricula do atendente
        usrtipatd     like datmligatd.apotip     ,  # tipo do atendente
        corsus        like gcaksusep.corsus      ,  # psi172413 eduardo - meta
        dddcod        like datmreclam.dddcod     ,  # cod da area de discagem
        ctttel        like datmreclam.ctttel     ,  # numero do telefone
        funmat        like isskfunc.funmat       ,  # matricula do funcionario
        cgccpfnum     like gsakseg.cgccpfnum     ,  # numero do CGC(CNPJ)
        cgcord        like gsakseg.cgcord        ,  # filial do CGC(CNPJ)
        cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF
        atdprscod     like datmservico.atdprscod ,
        atdvclsgl     like datkveiculo.atdvclsgl ,
        srrcoddig     like datmservico.srrcoddig ,
        socvclcod     like datkveiculo.socvclcod ,
        dstqtd        dec(8,4)                   ,
        prvcalc       interval hour(2) to minute ,
        lclltt        like datmlcl.lclltt        ,
        lcllgt        like datmlcl.lcllgt        ,
        rcuccsmtvcod  like datrligrcuccsmtv.rcuccsmtvcod, ## Codigo do Motivo
        c24paxnum     like datmligacao.c24paxnum ,        # Numero da P.A.
        averbacao     like datrligtrpavb.trpavbnum,       # PSI183431 Daniel
        crtsaunum     like datksegsau.crtsaunum,
        bnfnum        like datksegsau.bnfnum,
        ramgrpcod     like gtakram.ramgrpcod
 end record

 define lr_ppt        record
        segnumdig     like gsakseg.segnumdig,
        cmnnumdig     like pptmcmn.cmnnumdig,
        endlgdtip     like rlaklocal.endlgdtip,
        endlgdnom     like rlaklocal.endlgdnom,
        endnum        like rlaklocal.endnum,
        ufdcod        like rlaklocal.ufdcod,
        endcmp        like rlaklocal.endcmp,
        endbrr        like rlaklocal.endbrr,
        endcid        like rlaklocal.endcid,
        endcep        like rlaklocal.endcep,
        endcepcmp     like rlaklocal.endcepcmp,
        edsstt        like rsdmdocto.edsstt,
        viginc        like rsdmdocto.viginc,
        vigfnl        like rsdmdocto.vigfnl,
        emsdat        like rsdmdocto.emsdat,
        corsus        like rsampcorre.corsus,
        pgtfrm        like rsdmdadcob.pgtfrm,
        mdacod        like gfakmda.mdacod,
        lclrsccod     like rlaklocal.lclrsccod
 end record

 # Integracao CRM HDK / Funeral
 define ctz00m02 record
        ifxsblitgseqnum  like datmifxsblitg.ifxsblitgseqnum
       ,sblitenum        like datmifxsblitg.sblitenum
       ,sblatdnum        like datmifxsblitg.sblatdnum
       ,atdclitipcod     like datmifxsblitg.atdclitipcod
       ,bcpclicod        like datmifxsblitg.bcpclicod
       ,clinom           like datmifxsblitg.clinom
       ,clicpfnum        like datmifxsblitg.clicpfnum
       ,clicnpnum        like datmifxsblitg.clicnpnum
       ,suscod           like datmifxsblitg.suscod
       ,prscod           like datmifxsblitg.prscod
       ,fncclimatcod     like datmifxsblitg.fncclimatcod
       ,sblatdgrpnom     like datmifxsblitg.sblatdgrpnom
       ,trtdcttipnom     like datmifxsblitg.trtdcttipnom
       ,trtdctcod        like datmifxsblitg.trtdctcod
       ,refdcttipnom     like datmifxsblitg.refdcttipnom
       ,refdctcod        like datmifxsblitg.refdctcod
       ,atdasttipnom     like datmifxsblitg.atdasttipnom
       ,atdastdes        like datmifxsblitg.atdastdes
       ,atdsatdes        like datmifxsblitg.atdsatdes
       ,atdusrmatcod     like datmifxsblitg.atdusrmatcod
       ,legsisnom        like datmifxsblitg.legsisnom
       ,envdat           like datmifxsblitg.envdat
       ,legsisltrflg     like datmifxsblitg.legsisltrflg
 end record
 # Funeral
 define l_segnumdig  like gsakseg.segnumdig
 define l_erro        smallint

 define l_conf         char(1)

 define w_apoio   char(01)
 define w_empcodatd like isskfunc.empcod
 define w_funmatatd like isskfunc.funmat
 define w_usrtipatd like isskfunc.usrtip

 define l_resultado  smallint
       ,l_mensagem   char(60)
       ,l_ramgrpcod  like gtakram.ramgrpcod
       ,l_servico    char(30) # CRM
       ,l_ret_siebel smallint # CRM
       ,l_ramo       char(10)

 define l_legado char(15)

 define l_atdusrmatcod     like datmifxsblitg.atdusrmatcod

 define ret_espre smallint

 define l_retorno_capa record
        viginc     like apamcapa.viginc,
        vigfnl     like apamcapa.vigfnl,
        succod     like apamcapa.succod,
        prpstt     like apamcapa.prpstt,
        sucnom     like gabksuc.sucnom,
        aplnumdig  like apamcapa.aplnumdig,
        dscstt     like iddkdominio.cpodes,
        cvnnum     like apamcapa.cvnnum,
        prpqtditm  like apamcapa.prpqtditm
 end record

 initialize l_segnumdig       to null
 initialize lr_documento.*    to null
 initialize lr_ppt.*          to null
 initialize ctz00m02.*        to null
 initialize g_atd_siebel      to null
 initialize l_legado          to null
 initialize l_atdusrmatcod    to null
 initialize ret_espre         to null
 initialize l_ramo            to null
 initialize l_erro            to null
 initialize l_retorno_capa.*  to null

 initialize l_conf, w_apoio, w_empcodatd, w_funmatatd, w_usrtipatd to null
 initialize l_resultado ,l_mensagem  , l_ramgrpcod , l_servico   , l_ret_siebel to null

 let g_atd_siebel = 0
 let g_documento.ciaempcod = '1'
 let g_documento.ligcvntip = 0

 let w_apoio      = g_documento.apoio
 let w_empcodatd  = g_documento.empcodatd
 let w_funmatatd  = g_documento.funmatatd
 let w_usrtipatd  = g_documento.usrtipatd

 let lr_documento.succod         = g_documento.succod
 let lr_documento.aplnumdig      = g_documento.aplnumdig
 let lr_documento.itmnumdig      = g_documento.itmnumdig
 let lr_documento.edsnumref      = g_documento.edsnumref
 let lr_documento.prporg         = g_documento.prporg
 let lr_documento.prpnumdig      = g_documento.prpnumdig
 let lr_documento.fcapacorg      = g_documento.fcapacorg
 let lr_documento.fcapacnum      = g_documento.fcapacnum
 let lr_documento.pcacarnum      = g_documento.pcacarnum
 let lr_documento.pcaprpitm      = g_documento.pcaprpitm
 let lr_documento.solnom         = g_documento.solnom         # Para Funeral, global não carregada.
 let lr_documento.ramcod         = g_documento.ramcod
 let lr_documento.lignum         = g_documento.lignum
 let lr_documento.c24astcod      = g_documento.c24astcod
 let lr_documento.ligcvntip      = g_documento.ligcvntip
 let lr_documento.atdsrvnum      = g_documento.atdsrvnum
 let lr_documento.atdsrvano      = g_documento.atdsrvano
 let lr_documento.sinramcod      = g_documento.sinramcod
 let lr_documento.sinano         = g_documento.sinano
 let lr_documento.sinnum         = g_documento.sinnum
 let lr_documento.sinitmseq      = g_documento.sinitmseq
 let lr_documento.acao           = g_documento.acao
 let lr_documento.atdsrvorg      = g_documento.atdsrvorg
 let lr_documento.cndslcflg      = g_documento.cndslcflg
 let lr_documento.lclnumseq      = g_documento.lclnumseq   # Local de Risco
 let lr_documento.vstnumdig      = g_documento.vstnumdig
 let lr_documento.flgIS096       = g_documento.flgIS096
 let lr_documento.flgtransp      = g_documento.flgtransp
 let lr_documento.apoio          = g_documento.apoio
 let lr_documento.empcodatd      = g_documento.empcodatd
 let lr_documento.funmatatd      = g_documento.funmatatd
 let lr_documento.usrtipatd      = g_documento.usrtipatd
 let lr_documento.corsus         = g_documento.corsus
 let lr_documento.dddcod         = g_documento.dddcod
 let lr_documento.ctttel         = g_documento.ctttel
 let lr_documento.funmat         = g_documento.funmat
 let lr_documento.cgccpfnum      = g_documento.cgccpfnum
 let lr_documento.cgcord         = g_documento.cgcord
 let lr_documento.cgccpfdig      = g_documento.cgccpfdig
 let lr_documento.atdprscod      = g_documento.atdprscod
 let lr_documento.atdvclsgl      = g_documento.atdvclsgl
 let lr_documento.srrcoddig      = g_documento.srrcoddig
 let lr_documento.socvclcod      = g_documento.socvclcod
 let lr_documento.dstqtd         = g_documento.dstqtd
 let lr_documento.prvcalc        = g_documento.prvcalc
 let lr_documento.lclltt         = g_documento.lclltt
 let lr_documento.lcllgt         = g_documento.lcllgt
 let lr_documento.rcuccsmtvcod   = g_documento.rcuccsmtvcod
 let lr_documento.crtsaunum      = g_documento.crtsaunum
 let lr_documento.bnfnum         = g_documento.bnfnum
 let lr_documento.ramgrpcod      = g_documento.ramgrpcod


 if m_prep_sql2 is null or
    m_prep_sql2 <> true then
    call ctz00m02_prep()
 end if

 {monta a matricula completa}
 call f_fungeral_junta_usrcod(g_issk.funmat
                             ,g_issk.empcod
                             ,g_issk.usrtip)
    returning l_atdusrmatcod

 open cctz00m01003 using l_atdusrmatcod
 whenever error continue
 fetch cctz00m01003 into l_legado
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       if ctz00m02.legsisltrflg = false  then

          call cts08g01( "A","N",
                         "ATENDIMENTO NAO LOCALIZADO OU, NAO",
                         "INICIADO PELO SIEBEL-CRM.EXECUTAR ",
                         "PROCEDIMENTO PELO SISTEMA INFORMIX",
                         "CENTRAL 24 HORAS.")
          returning l_conf
          let g_atd_siebel = 0
          let g_atd_siebel_num =null
          let ret_espre = 1
          let int_flag = false
          return ret_espre
       end if
    end if
 end if

 call ctz00m00_verifica_atd_siebel(l_atdusrmatcod,l_legado )
 returning ctz00m02.ifxsblitgseqnum
          ,ctz00m02.sblitenum
          ,ctz00m02.sblatdnum
          ,ctz00m02.atdclitipcod
          ,ctz00m02.bcpclicod
          ,ctz00m02.clinom
          ,ctz00m02.clicpfnum
          ,ctz00m02.clicnpnum
          ,ctz00m02.suscod
          ,ctz00m02.prscod
          ,ctz00m02.fncclimatcod
          ,ctz00m02.sblatdgrpnom
          ,ctz00m02.trtdcttipnom
          ,ctz00m02.trtdctcod
          ,ctz00m02.refdcttipnom
          ,ctz00m02.refdctcod
          ,ctz00m02.atdasttipnom
          ,ctz00m02.atdastdes
          ,ctz00m02.atdsatdes
          ,ctz00m02.atdusrmatcod
          ,ctz00m02.legsisnom
          ,ctz00m02.envdat
          ,ctz00m02.legsisltrflg
 let l_conf = "N"
 let g_documento.solnom = ctz00m02.clinom

 if ctz00m02.legsisltrflg = false  then
    call cts08g01( "A","N",
                   "ATENDIMENTO NAO LOCALIZADO OU, NAO",
                   "INICIADO PELO SIEBEL-CRM.EXECUTAR ",
                   "PROCEDIMENTO PELO SISTEMA INFORMIX",
                   "CENTRAL 24 HORAS.")
    returning l_conf
    let g_atd_siebel = 0
    let g_atd_siebel_num =null
 else
    # Localizou a Integração com Siebel
    let g_atd_siebel = 1

    call ctg2_crm(ctz00m02.trtdcttipnom, ctz00m02.trtdctcod)
    returning lr_documento.succod,
              lr_documento.ramcod,
              lr_documento.aplnumdig,
              lr_documento.itmnumdig,
              g_rsc_re.lclrsccod,
              g_documento.lclnumseq,
              g_documento.rmerscseq,
              lr_documento.prporg,
              lr_documento.prpnumdig
    # Se não for um documento tratável(doc tratado <>  Proposta e Apólice)
    if ((lr_documento.succod    is null   and
         lr_documento.ramcod    is null   and
         lr_documento.aplnumdig is null   and
         lr_documento.itmnumdig is null)  and
        (lr_documento.prporg    is null   and
         lr_documento.prpnumdig is null)) then

        let g_atd_siebel = 0
        let g_atd_siebel_num =null
        let ret_espre = 1
        let int_flag = false
        return ret_espre
    end if


    let g_documento.prporg    = lr_documento.prporg
    let g_documento.prpnumdig = lr_documento.prpnumdig
    let g_documento.succod    = lr_documento.succod
    let g_documento.ramcod    = lr_documento.ramcod
    let g_documento.aplnumdig = lr_documento.aplnumdig
    let g_documento.itmnumdig = lr_documento.itmnumdig
    let g_documento.solnom    = ctz00m02.clinom
    let lr_documento.solnom   = ctz00m02.clinom

    # definido por Roberto/Priscila
    # Definições da Priscila Conforme E-Mail.

    # Para o Tipo "Cliente", "Cliente-Empresa" entendo que corresponde ao "SEGURADO" no sistema da Central 24h.
    # Para o Tipo "Corretor"  entendo que corresponde ao "CORRETOR" no sistema da Central 24h.
    # Para o Tipo "Prestador" entendo que corresponde a "OFICINA" no sistema da Central 24h.
    # Para o Tipo "Funcionário" e "Não Cliente" entendo que corresponde a "OUTROS" no sistema da Central 24h.
    #1 SEGURADO
    #2 CORRETOR
    #3 OUTROS
    #4 OFICINA
    #5 TERCEIRO
    #6 APOIO

    if ctz00m02.atdclitipcod        = "Cliente" or
       ctz00m02.atdclitipcod        = "Cliente - Empresa"  then
       let g_documento.c24soltipcod = 1
       let g_documento.soltip = "S"
       let lr_documento.soltip         = g_documento.soltip
       let lr_documento.c24soltipcod   = g_documento.c24soltipcod
    end if

    if ctz00m02.atdclitipcod        = "Corretor" then
       let g_documento.c24soltipcod = 2
       let g_documento.soltip = "C"
       let lr_documento.soltip         = g_documento.soltip
       let lr_documento.c24soltipcod   = g_documento.c24soltipcod
    end if

    if ctz00m02.atdclitipcod        = "Prestador" then
       let g_documento.c24soltipcod = 4
       let g_documento.soltip = "O"
       let lr_documento.soltip         = g_documento.soltip
       let lr_documento.c24soltipcod   = g_documento.c24soltipcod
    end if

    if ctz00m02.atdclitipcod        = "Funcionário" or
       ctz00m02.atdclitipcod        = "Não cliente" then
       let g_documento.c24soltipcod = 3
       let g_documento.soltip = "O"
       let lr_documento.soltip         = g_documento.soltip
       let lr_documento.c24soltipcod   = g_documento.c24soltipcod
    end if

    if g_issk.acsnivcod <= 6 then
       let g_gera_atd = "S"
    end if


    if ctz00m02.sblatdgrpnom = "Central Vida e Previdência" then
       let g_documento.ramcod = 991
    end if

    # Carregar PA
    if g_c24paxnum is null and g_issk.acsnivcod <= 6 then
        let g_c24paxnum = cta02m09()
        let lr_documento.c24paxnum = g_c24paxnum
    else
       let g_c24paxnum    = 9999
       let lr_documento.c24paxnum = g_c24paxnum
    end if

    #display "<2083> ctz00m02-> l_resultado/l_ramgrpcod > ", l_resultado,"/",l_ramgrpcod
    #display "<2084> ctz00m02-> (g_documento.ciaempcod/g_documento.ramcod > ", g_documento.ciaempcod,"/",g_documento.ramcod
    let l_resultado = 1 # Se for proposta, nao terá ramo definido. Nao pesquisará o grupo de Ramo.
    let l_ramgrpcod = 4 # Definir qual ramo implementar. Para evitar erro, implementad 4=RE
    if g_documento.ramcod is not null then
       call cty10g00_grupo_ramo(g_documento.ciaempcod
                               ,g_documento.ramcod)
                      returning l_resultado
                               ,l_mensagem
                               ,l_ramgrpcod
    end if

    #display "<2095> ctz00m02-> l_resultado <",l_resultado,">"
    #display "<2096> ctz00m02-> l_mensagem  <",l_mensagem ,">"
    #display "<2097> ctz00m02-> l_ramgrpcod <",l_ramgrpcod,">"

    if l_resultado <> 1 then
       let g_atd_siebel = 0
       let g_atd_siebel_num =null
       error "Documento Invalido <", ctz00m02.trtdcttipnom , "><", ctz00m02.trtdctcod ,">"
       let ret_espre = 1
       let int_flag = false
       return ret_espre
    end if

    let g_documento.ramgrpcod = l_ramgrpcod
    #-------------------------------------------
    # Atendimento por Proposta
    #-------------------------------------------
    #display "<2112> ctz00m02-> ctz00m02.trtdcttipnom > ", ctz00m02.trtdcttipnom
    if ctz00m02.trtdcttipnom = "Proposta" then

       #-------------------------------------------
       # Verifica se a Proposta e do Auto
       #-------------------------------------------
       call faemc916_prepare()

       call faemc916_capa_proposta(g_documento.prporg    ,
                                   g_documento.prpnumdig)
       returning l_retorno_capa.*

       if l_retorno_capa.viginc is not null and
          l_retorno_capa.vigfnl is not null then

           #-------------------------------------------
           # Espelho da Proposta Auto
           #-------------------------------------------

           call cta01m18(g_documento.prporg    ,
                         g_documento.prpnumdig)
           returning l_resultado, l_mensagem

       end if


    else

       #-------------------------------------------
       # Atendimento por Apolice
       #-------------------------------------------
       #display "<2143> ctz00m02-> l_ramgrpcod <",l_ramgrpcod,">"
       if l_ramgrpcod = 1 then     # Grupo de Ramo Automovel
          call ctz00m02_espaut()
       else
          if l_ramgrpcod = 4 then  # Grupo de Ramo RE
             #display "<2148> ctz00n02-> g_rsc_re.lclrsccod > ", g_rsc_re.lclrsccod
             call ctz00m02_espre()
             returning ret_espre
             if ret_espre <> 0  then
                call cts08g01( "A","N",
                               "DOCUMENTO NAO LOCALIZADO. EXECUTAR",
                               "PROCEDIMENTO PELO SISTEMA INFORMIX",
                               "CENTRAL 24 HORAS.", "")
                returning l_conf
                let g_atd_siebel = 0
                let g_atd_siebel_num =null

                let ret_espre = 1
                let int_flag = false
                return ret_espre
             end if
          end if
          if l_ramgrpcod = 3 then  # Grupo de Ramo VIDA

             call cta01m32(g_documento.ramcod,
                           g_documento.succod,
                           g_documento.aplnumdig,
                           g_documento.prporg,
                           g_documento.prpnumdig,
                           "",
                           "",
                           "" )
                  returning  lr_documento.aplnumdig,
                             lr_documento.prporg,
                             lr_documento.prpnumdig,
                             l_segnumdig,
                             lr_documento.succod,
                             l_erro,
                             lr_documento.ramcod ---> Funeral

             let g_documento.ramcod = lr_documento.ramcod ---> Funeral
          end if
       end if
    end if

    let g_gera_atd = "S"
    let lr_ppt.lclrsccod   = g_rsc_re.lclrsccod

    #let lr_documento.itmnumdig = 0 retirado em 21/01/2014 - chamado 140116825
    if lr_documento.ramcod <> 531 then
       let lr_documento.itmnumdig = 0
    end if
    call cta02m00_solicitar_assunto(lr_documento.*,lr_ppt.*)

    # Limpar variavel
    let g_documento.c24astcod = null


    # definir servico
    let l_ret_siebel = null
    # Atualzar variavel HDESKCASA ou LAUDOFUN

    if g_atd_siebel_num is not null then
       call ctz00m00_atualiza_siebel(ctz00m02.sblatdnum  #No. Atendimento
       ,l_legado                  #Nome Sist. Legado 'atd_ct24h'
       ,"ORDEM DE SERVIÇO"        #1-APÓLICE
                                  #2-CONTRATO
                                  #3-ORÇAMENTO
                                  #4-VISTORIA PRÉVIA
                                  #5-ORDEM DE PAGAMENTO
                                  #6-ORDEM DE SERVIÇO
                                  #7-COBERTURA PROVISÓRIA
                                  #8-PROPOSTA
                                  #9-ESTUDO ACEITAÇÃO
                                  #10-SINISTRO
       ,g_atd_siebel_num
       ,ctz00m02.sblitenum )
       returning l_ret_siebel

       if l_ret_siebel = 0 then
           call cts08g01( "A","N",
                          "",
                          "Problemas na integracao com Sistema",
                          "Siebel - ctz00m02. ",
                          "AVISE INFORMATICA")
           returning l_conf
           let g_atd_siebel = 0
           let g_atd_siebel_num =null

       end if
       # Verificar variaveis retorno Numero de atd na variavel global para verificar erro
    end if
 end if

 let g_atd_siebel = 0

 let ret_espre = 1

 let int_flag = false

 return ret_espre


end function
