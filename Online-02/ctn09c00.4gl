 #############################################################################
 # Nome do Modulo: CTN09C00                                            Pedro #
 #                                                                           #
 # Consulta Corretores Susep/Nome                                   Out/1994 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 19/07/1999  Via correio  Gilberto     Incluir mais duas unidades para vi- #
 #                                       sualizar o codigo da URA.           #
 #---------------------------------------------------------------------------#
 # 17/07/2000  PSI 11147-3  Akio         Incluir nome e telefone do respon-  #
 #                                       savel.                              #
 #---------------------------------------------------------------------------#
 # 25/07/2001  Rosana       Ruiz         Gravar a susep selecionada na       #
 #                                       datkgeral para tela cts06m00.       #
 #---------------------------------------------------------------------------#
 # 01/03/2002  CORREIO      Wagner       Incluir dptsgl psocor nas pesquisas.#
 #############################################################################
#=============================================================================#
# Alterado : 23/07/2002 - Celso                                               #
#            Utilizacao da funcao fgckc811 para enderecamento de corretores   #
#=============================================================================#
#----------------------------------------------------------------------------#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 18/05/2005 James, Meta       PSI 192333 Implementado campo dddfax          #
#----------------------------------------------------------------------------#
# 18/05/2005 Raquel, Meta      PSI 214140 Chamar a funcao fpoac006           #
#----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctn09c00(k_ctn09c00)
#---------------------------------------------------------------

 define k_ctn09c00 record
    corsus         like gcaksusep.corsus
 end record

 define ws_resp    char (01)

 define lr_corretor record
        corsus      char(06),
        cornom      char(60),
        endlgd      char(80),
        endcmp      char(40),
        endnum      char(07),
        cepfinal    char(08),
        endbrr      char(40),
        endcid      char(50),
        logradouro  char(60),
        endtip      char(20),
        endufd      char(02),
        endcep      char(10),
        endcepcmp   char(03),
        dddcod      char(05),
        teltxt      char(30),
        dddfax      char(05),
        factxt      char(30),
        codacsura   char(10),
        suslnhqtd   char(10),
        maides      char(100)
 end record

 define l_azlaplcod  integer,
        l_resultado  smallint,
        l_mensagem   char(80),
        l_doc_handle integer,
        l_acesso     smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 let ws_resp      = null
 let l_azlaplcod  = null
 let l_resultado  = null
 let l_mensagem   = null
 let l_doc_handle = null

 initialize lr_corretor.* to null

 open window w_ctn09c00 at 04,02 with form "ctn09c00"

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

       # -> BUSCA OS DADOS DO CORRETOR
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "CORRETOR")
       returning lr_corretor.corsus,
                 lr_corretor.cornom,
                 lr_corretor.dddcod,
                 lr_corretor.teltxt,
                 lr_corretor.dddfax,
                 lr_corretor.factxt,
                 lr_corretor.maides

       # -> BUSCA OS DADOS DO ENDERECO DO CORRETOR
       call cts40g02_extraiDoXML(l_doc_handle,
                                 "CORRETOR_ENDERECO")
       returning lr_corretor.endufd,
                 lr_corretor.endcid,
                 lr_corretor.endtip,
                 lr_corretor.logradouro,
                 lr_corretor.endnum,
                 lr_corretor.endcmp,
                 lr_corretor.endbrr,
                 lr_corretor.cepfinal

       let lr_corretor.endcep    = lr_corretor.cepfinal[1,5]
       let lr_corretor.endcepcmp = lr_corretor.cepfinal[6,8]

       let lr_corretor.endlgd = lr_corretor.endtip     clipped, " ",
                                lr_corretor.logradouro clipped, ", ",
                                lr_corretor.endnum     clipped

       display by name lr_corretor.corsus,
                       lr_corretor.cornom,
                       lr_corretor.endlgd,
                       lr_corretor.endcmp,
                       lr_corretor.endbrr,
                       lr_corretor.endcid,
                       lr_corretor.endufd,
                       lr_corretor.endcep,
                       lr_corretor.endcepcmp,
                       lr_corretor.dddcod,
                       lr_corretor.teltxt,
                       lr_corretor.dddfax,
                       lr_corretor.factxt,
                       lr_corretor.maides

       error  "Consulta efetuada. Tecle ENTER para sair..."
       prompt "" for char ws_resp

    else
       error "AZLAPLCOD esta nulo ! cta01m04.4gl" sleep 4
       return
    end if
 else
    if k_ctn09c00.corsus is not null  then #consulta via pop_up
       call ctn09c00_seleciona(k_ctn09c00.corsus) returning k_ctn09c00.*
       error  "Consulta efetuada....., tecle ENTER!"
       prompt "" for char ws_resp
       close window w_ctn09c00
       let int_flag = false
       initialize k_ctn09c00.* to null
       return
    end if

    menu "CORRETORES"

      before menu

         call cta00m06_acionamento(g_issk.dptsgl)
         returning l_acesso
         if l_acesso = false then
            hide option "Pager"
         end if
      command key ("S") "Seleciona"
                        "Pesquisa tabela conforme criterios"
              initialize k_ctn09c00.* to null
              call ctn09c00_seleciona("") returning k_ctn09c00.*

      command key ("P") "Pager"
                        "Informacoes sobre o pager do corretor"

              if k_ctn09c00.corsus  is not null   then
                 call ctn09c03(k_ctn09c00.corsus)
              else
                 error " Nenhuma SUSEP foi selecionada!"
              end if
              next option "Seleciona"

      command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
              exit menu
    end menu
 end if

 close window w_ctn09c00
 let int_flag = false

end function  ##-- ctn09c00

#-------------------------------------------------------------------
 function ctn09c00_seleciona(w_corsus)
#-------------------------------------------------------------------

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

 define w_corsus like gcaksusep.corsus

 define k_ctn09c00 record
    corsus         like gcaksusep.corsus,
    cornom         like gcakcorr.cornom
 end record

 define d_ctn09c00 record
    corsus         like gcaksusep.corsus,
    endlgd         like gcakfilial.endlgd,
    endbrr         like gcakfilial.endbrr,
    endcid         like gcakfilial.endcid,
    endufd         like gcakfilial.endufd,
    endcep         like gcakfilial.endcep,
    endcmp         like gcakfilial.endcmp,
    endcepcmp      like gcakfilial.endcepcmp,
    dddcod         like gcakfilial.dddcod,
    teltxt         like gcakfilial.teltxt,
    dddfax         like gcakfilial.dddfax,    ## PSI 192333
    factxt         like gcakfilial.factxt,
    codacsura      char (16),
    suslnhqtd      like gcaksusep.suslnhqtd ,
    maides         like gcakfilial.maides,
    pdtnom         like gcbkprod.pdtnom,
    inpnom         like gcbkinsp.inpnom,
    unonom         like gabkuno.unonom,
    cvnnom         char(40),
    endcordes      char(54),
    rspnom         char(40),
    rsptel         char(14)
 end record

 define ws         record
    unocod         like gcaksusep.unocod,
    inpcod         like gcaksusep.inpcod,
    pdtcod         like gcbkprod.pdtcod ,
    cvnnum         like gcaksusep.cvnnum,
    endnum         like gcakfilial.endnum,
    crrdstcod      like gcaksusep.crrdstcod,
    crrdstnum      like gcaksusep.crrdstnum,
    crrdstsuc      like gcaksusep.crrdstsuc,
    pgtdstdes      like fpgkpgtdst.pgtdstdes,
    sucsgl         like gabksuc.sucsgl      ,
    atdempcod      like gcbkprod.atdempcod  ,
    atdfunmat      like gcbkprod.atdfunmat  ,
    atddddcod      like gcbkprod.atddddcod  ,
    atdteltxt      like gcbkprod.atdteltxt  ,
    grlchv         like datkgeral.grlchv    ,
    count          integer
 end record

   define retorno          record
          destino          char(07)
         ,extensao         char(04)
         ,completo         char(21)
   end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  r_gcakfilial.*  to  null

        initialize  k_ctn09c00.*  to  null

        initialize  d_ctn09c00.*  to  null

        initialize  ws.*  to  null

        initialize  r_gcakfilial.*  to  null

        initialize  k_ctn09c00.*  to  null

        initialize  d_ctn09c00.*  to  null

        initialize  ws.*  to  null

        initialize  retorno.*  to  null

 while true

   let int_flag = false

   if g_issk.dptsgl  =  "ct24hs"   or
      g_issk.dptsgl  =  "psocor"   or
      g_issk.dptsgl  =  "dsvatd"   or
      g_issk.dptsgl  =  "tlprod"   or
      g_issk.dptsgl  =  "desenv"   then
      clear form
   end if

   input by name k_ctn09c00.corsus,
                 k_ctn09c00.cornom  without defaults

      before field corsus
             if w_corsus is not null then  #consulta via pop_up
                let k_ctn09c00.corsus = w_corsus
                exit input
             end if

             display by name k_ctn09c00.corsus attribute (reverse)
             initialize d_ctn09c00.*  to null
             initialize ws.*          to null

      after  field corsus
             display by name k_ctn09c00.corsus

             if k_ctn09c00.corsus is not null then
                select *
                  from gcaksusep
                 where gcaksusep.corsus = k_ctn09c00.corsus

                if sqlca.sqlcode <> 0 then
                   error " Susep nao cadastrada!"
                   next field corsus
                end if
                exit input
             end if

      before field cornom
             display by name k_ctn09c00.cornom attribute (reverse)

      after  field cornom
             display by name k_ctn09c00.cornom

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field  corsus
             end if

             if k_ctn09c00.cornom is null or
                k_ctn09c00.cornom =  "  " then
                error " Informe SUSEP ou NOME para pesquisa!"
                next field cornom
             end if

             call aggucora_pesq_nome(k_ctn09c00.cornom)
                  returning k_ctn09c00.corsus

             if k_ctn09c00.corsus is null then
                next field cornom
             end if

       on key (interrupt)
          initialize d_ctn09c00.*  to null
          initialize ws.*          to null
          clear form
          exit input

   end input

   if int_flag then
      exit while
   end if

   select corsus   , cornom   ,
          unocod   , inpcod   ,
          cvnnum   , suslnhqtd
    into  d_ctn09c00.corsus,
          k_ctn09c00.cornom,
          ws.unocod        ,
          ws.inpcod        ,
          ws.cvnnum        ,
          d_ctn09c00.suslnhqtd
     from gcaksusep, gcakcorr
    where gcaksusep.corsus     = k_ctn09c00.corsus    and
          gcakcorr.corsuspcp   = gcaksusep.corsuspcp


   #---> Utilizacao da nova funcao de comissoes p/ enderecamento

   initialize r_gcakfilial.* to null

   call fgckc811(k_ctn09c00.corsus)
        returning r_gcakfilial.*

   call fpoac006(k_ctn09c00.corsus)
      returning retorno.destino
               ,retorno.extensao
               ,retorno.completo

   let d_ctn09c00.endlgd     = r_gcakfilial.endlgd
   let d_ctn09c00.endbrr     = r_gcakfilial.endbrr
   let d_ctn09c00.endcid     = r_gcakfilial.endcid
   let d_ctn09c00.endufd     = r_gcakfilial.endufd
   let d_ctn09c00.endcep     = r_gcakfilial.endcep
   let d_ctn09c00.endcepcmp  = r_gcakfilial.endcepcmp
   let d_ctn09c00.dddcod     = r_gcakfilial.dddcod
   let d_ctn09c00.teltxt     = r_gcakfilial.teltxt
   let d_ctn09c00.dddfax     = r_gcakfilial.dddfax    ## PSI 192333
   let d_ctn09c00.factxt     = r_gcakfilial.factxt
   let d_ctn09c00.endcmp     = r_gcakfilial.endcmp
   let ws.endnum             = r_gcakfilial.endnum
   let ws.crrdstcod          = r_gcakfilial.crrdstcod
   let ws.crrdstnum          = r_gcakfilial.crrdstnum
   let ws.crrdstsuc          = r_gcakfilial.crrdstsuc
   let d_ctn09c00.maides     = r_gcakfilial.maides

   #------------------------------------------------------------

   let d_ctn09c00.endlgd = d_ctn09c00.endlgd clipped, " ",
                           ws.endnum  using "#######"

   initialize d_ctn09c00.unonom  to null
   select unonom
     into d_ctn09c00.unonom
     from gabkuno
    where gabkuno.unocod  = ws.unocod

   initialize d_ctn09c00.inpnom  to null
   initialize ws.pdtcod          to null
   select inpnom, pdtcod
     into d_ctn09c00.inpnom, ws.pdtcod
     from gcbkinsp
      where gcbkinsp.inpcod = ws.inpcod

   initialize d_ctn09c00.pdtnom  to null
   select pdtnom   ,
          atdempcod,
          atdfunmat,
          atddddcod,
          atdteltxt
     into d_ctn09c00.pdtnom,
          ws.atdempcod     ,
          ws.atdfunmat     ,
          ws.atddddcod     ,
          ws.atdteltxt
     from GCBKPROD
    where gcbkprod.pdtcod = ws.pdtcod

   select funnom
     into d_ctn09c00.rspnom
     from ISSKFUNC
          where empcod = ws.atdempcod
            and funmat = ws.atdfunmat

   if  ws.atddddcod = " "    or
       ws.atddddcod is null  then
       let d_ctn09c00.rsptel = ws.atdteltxt clipped
   else
       let d_ctn09c00.rsptel = "(", ws.atddddcod clipped, ") ",
                               ws.atdteltxt clipped
   end if


   initialize d_ctn09c00.cvnnom  to null
   if ws.cvnnum  is null   then
      let ws.cvnnum = 0
   end if

   select cpodes
     into d_ctn09c00.cvnnom
     from datkdominio
    where datkdominio.cponom = "cvnnum"   and
          datkdominio.cpocod = ws.cvnnum

   let d_ctn09c00.cvnnom = upshift(d_ctn09c00.cvnnom)

   let d_ctn09c00.codacsura = "Cod. Acesso URA: "

   if ws.crrdstnum  is not null   and
      ws.crrdstcod  = "M"         then
      select pgtdstdes
        into ws.pgtdstdes
        from fpgkpgtdst
       where pgtdstcod = ws.crrdstnum
   end if

   if ws.crrdstsuc  is not null   then
      select sucsgl
        into ws.sucsgl
        from gabksuc
       where succod  =  ws.crrdstsuc
   end if

   case ws.crrdstcod
        when "C"
             let d_ctn09c00.endcordes = "CORREIO "
        when "B"
             let d_ctn09c00.endcordes = "BOY "
             let d_ctn09c00.endcordes = d_ctn09c00.endcordes     clipped,"(",
                                        ws.crrdstnum using "&&&"
             if ws.sucsgl  is not null   then
                let d_ctn09c00.endcordes = d_ctn09c00.endcordes  clipped,"-",
                                           ws.sucsgl             clipped,") "
             else
                let d_ctn09c00.endcordes = d_ctn09c00.endcordes  clipped,")"
             end if

        when "E"
             let d_ctn09c00.endcordes = "EXPEDICAO "
             let d_ctn09c00.endcordes = d_ctn09c00.endcordes     clipped,"(",
                                        ws.crrdstnum using "&&&"
             if ws.sucsgl  is not null   then
                let d_ctn09c00.endcordes = d_ctn09c00.endcordes  clipped,"-",
                                           ws.sucsgl             clipped,") "
             else
                let d_ctn09c00.endcordes = d_ctn09c00.endcordes  clipped,")"
             end if

        when "M"
             let d_ctn09c00.endcordes = "MALOTE "
             let d_ctn09c00.endcordes = d_ctn09c00.endcordes     clipped,"(",
                                        ws.crrdstnum using "&&&" clipped," "
             # Conforme cadastro do Controle de Producao
             # Se for Malote e Sucursal = 1 (Matriz) mostra o destino de Pagamento
             if ws.crrdstsuc <> 1 then
                 let ws.pgtdstdes = null
             end if
             if ws.sucsgl  is not null   then
                let d_ctn09c00.endcordes = d_ctn09c00.endcordes  clipped,"-",
                                           ws.sucsgl             clipped,") ",
                                           ws.pgtdstdes
             else
                let d_ctn09c00.endcordes = d_ctn09c00.endcordes  clipped,")",
                                           ws.pgtdstdes
             end if

             let d_ctn09c00.endcordes = d_ctn09c00.endcordes clipped, ' - ', retorno.completo clipped

        otherwise
             let d_ctn09c00.endcordes = "N/PREVISTO"
   end case

   display by name k_ctn09c00.*
   display by name d_ctn09c00.*

   if d_ctn09c00.corsus is null then
      let d_ctn09c00.corsus = 0
   end if
   let ws.grlchv = "mvisto",
                   g_issk.funmat using "&&&&&&",
                   g_issk.maqsgl clipped
   select count(*)
       into ws.count
       from datkgeral
      where grlchv = ws.grlchv
   if ws.count > 0  then
      update  datkgeral set grlinf = d_ctn09c00.corsus
          where grlchv = ws.grlchv
   end if

   if g_issk.dptsgl =  "ct24hs"   or
      g_issk.dptsgl =  "psocor"   or
      g_issk.dptsgl =  "dsvatd"   or
      g_issk.dptsgl =  "tlprod"   or
      g_issk.dptsgl =  "desenv"   then
      return k_ctn09c00.corsus
   end if

   if w_corsus is not null then  #consulta via pop_up
      exit while
   end if

 end while

 let int_flag = false

 initialize k_ctn09c00.* to null
 return k_ctn09c00.corsus

end function  ##--  ctn09c00_seleciona
