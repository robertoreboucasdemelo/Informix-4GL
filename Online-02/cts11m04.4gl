#############################################################################
# Nome do Modulo: CTS11M04                                         Marcelo  #
#                                                                  Gilberto #
# Mostra informacoes adicionais para assistencia a passageiros     Jun/1997 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 29/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 27/11/2001  PSI 14177-1  Ruiz         Adaptacao para ramop 78-transporte. #
#############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define g_cts11m04   char(01)

#-----------------------------------------------------------
 function cts11m04(param)
#-----------------------------------------------------------

 define param      record
    succod         like datrservapol.succod   ,
    aplnumdig      like datrservapol.aplnumdig,
    itmnumdig      like datrservapol.itmnumdig,
    atddat         like datmservico.atddat,
    ramcod         like datrservapol.ramcod
 end record

 define ws         record
    sql            char (300),
    prisrvflg      smallint,
    pritaxflg      smallint,
    segnumdig      like gsakseg.segnumdig      ,
    endcid         like gsakend.endcid         ,
    endufd         like gsakend.endufd         ,
    clalclcod      like abbmdoc.clalclcod      ,
    clalcldes      like agekregiao.clalcldes   ,
    atdsrvnum      like datmservico.atdsrvnum  ,
    atdsrvano      like datmservico.atdsrvano  ,
    atddat         char (10)                   ,
    atdsrvorg      like datmservico.atdsrvorg  ,
    srvtipabvdes   like datksrvtip.srvtipabvdes,
    atdetpcod      like datmsrvacp.atdetpcod   ,
    atdetpdes      like datketapa.atdetpdes    ,
    atdcstvlr      like datmservico.atdcstvlr  ,
    asimtvcod      like datmassistpassag.asimtvcod,
    asimtvdes      like datkasimtv.asimtvdes
 end record

 define a_cts11m04 array[30] of record
    inftxt         char (55)
 end record

 define arr_aux      smallint,
        l_resultado  smallint,
        l_azlaplcod  integer,
        l_doc_handle integer,
        l_mensagem   char(50)


        define  w_pf1   integer

        let     arr_aux  =  null

        for     w_pf1  =  1  to  30
                initialize  a_cts11m04[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

 if param.succod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  or
    param.atddat    is null  then
    return
 end if

 if  g_cts11m04 is null  then
     let g_cts11m04 = "N"

     let ws.sql = "select asimtvdes "         ,
                    "from DATKASIMTV "        ,
                         "where asimtvcod = ?"
     prepare p_cts11m04_001 from ws.sql
     declare c_cts11m04_001 cursor for p_cts11m04_001

     let ws.sql = "select srvtipabvdes "      ,
                    "from datksrvtip "        ,
                         "where atdsrvorg = ?"
     prepare p_cts11m04_002 from ws.sql
     declare c_cts11m04_002 cursor for p_cts11m04_002

     let ws.sql = "select atdetpcod "          ,
                    "from DATMSRVACP "         ,
                         "where atdsrvnum = ? ",
                           "and atdsrvano = ? ",
                           "and atdsrvseq = (select max(atdsrvseq) "     ,
                                              "froM DATMSRVACP "         ,
                                                   "where atdsrvnum = ? ",
                                                     "and atdsrvano = ?)"
     prepare p_cts11m04_003 from ws.sql
     declare c_cts11m04_003 cursor for p_cts11m04_003

     let ws.sql = "select atdetpdes "         ,
                    "from DATKETAPA "         ,
                         "where atdetpcod = ?"
     prepare p_cts11m04_004 from ws.sql
     declare c_cts11m04_004 cursor for p_cts11m04_004
 end if


 open window cts11m04 at 11,21 with form "cts11m04"
                      attribute(form line 1, border)

 message " Aguarde, pesquisando... "  attribute (reverse)

 let int_flag = false

 initialize ws.*        to null
 initialize a_cts11m04  to null

 let ws.prisrvflg = true
 let ws.pritaxflg = true

 let arr_aux = 1


 call f_funapol_ultima_situacao (param.succod, param.aplnumdig, param.itmnumdig)
       returning g_funapol.*

 if  g_documento.ciaempcod = 1 then
     select segnumdig   , clalclcod
       into ws.segnumdig, ws.clalclcod
       from abbmdoc
      where succod    = param.succod     and
            aplnumdig = param.aplnumdig  and
            itmnumdig = param.itmnumdig  and
            dctnumseq = g_funapol.dctnumseq

     declare c_cts11m04_005 cursor for
      select clalcldes
        from agekregiao
       where clalclcod = ws.clalclcod

     open  c_cts11m04_005
     fetch c_cts11m04_005 into ws.clalcldes
        if sqlca.sqlcode = notfound  then
           let a_cts11m04[arr_aux].inftxt = "Classe Localiz..: NAO ENCONTRADA"
        else
           let a_cts11m04[arr_aux].inftxt = "Classe Localiz..: ", ws.clalcldes clipped
        end if
     close c_cts11m04_005

 else
    if g_documento.ciaempcod = 35 then 
     call ctd02g01_azlaplcod(param.succod,
                             param.ramcod,
                             param.aplnumdig,
                             param.itmnumdig,
                             "")

          returning l_resultado,
                    l_mensagem,
                    l_azlaplcod

     # -> BUSCA O XML DA APOLICE
     let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)

     if l_doc_handle is null then
        error "Nao encontrou o XML da apolice. AVISE A INFORMATICA ! " sleep 4
     end if

     if l_doc_handle is not null then
        call cts40g02_extraiDoXML(l_doc_handle ,'CLASSE_LOCALIZACAO')
             returning ws.clalclcod,
                       ws.clalcldes
     end if

     if  ws.clalcldes is null then
         let a_cts11m04[arr_aux].inftxt = "Classe Localiz..: NAO ENCONTRADA"
     else
         let a_cts11m04[arr_aux].inftxt = "Classe Localiz..: ", ws.clalcldes clipped
     end if
   end if   
 end if

 if g_documento.ciaempcod = 84 then     
       let ws.endcid = g_doc_itau[1].segcidnom clipped
       let ws.endufd = g_doc_itau[1].segufdsgl clipped
        
       let arr_aux = arr_aux + 2
       let a_cts11m04[arr_aux].inftxt = "Residencia......: ", ws.endcid clipped, " - ", ws.endufd    
 else       
    select endcid   , endufd
      into ws.endcid, ws.endufd
      from gsakend
      where segnumdig = ws.segnumdig  and
          endfld    = "1"
    if sqlca.sqlcode = 0  then
       let arr_aux = arr_aux + 2
       let a_cts11m04[arr_aux].inftxt = "Residencia......: ", ws.endcid clipped, " - ", ws.endufd
    end if                    
 
 end if 

 declare c_cts11m04_006 cursor for
    select datmservico.atdsrvnum,
           datmservico.atdsrvano,
           datmservico.atddat   ,
           datmservico.atdsrvorg,
           datmservico.atdcstvlr
      from datrservapol, datmservico
     where datrservapol.succod    = param.succod                      and
           datrservapol.ramcod    = param.ramcod                      and
           datrservapol.aplnumdig = param.aplnumdig                   and
           datrservapol.itmnumdig = param.itmnumdig                   and
           datmservico.atdsrvnum  = datrservapol.atdsrvnum            and
           datmservico.atdsrvano  = datrservapol.atdsrvano            and
           datmservico.atddat     between param.atddat - 2 units day  and
                                          param.atddat                and
           datmservico.atdsrvorg in (4, 6, 1, 11, 2, 3)
     order by atdsrvorg desc, atddat

 foreach c_cts11m04_006 into ws.atdsrvnum,
                            ws.atdsrvano,
                            ws.atddat   ,
                            ws.atdsrvorg   ,
                            ws.atdcstvlr

    open  c_cts11m04_003 using ws.atdsrvnum, ws.atdsrvano,
                             ws.atdsrvano, ws.atdsrvano
    fetch c_cts11m04_003 into  ws.atdetpcod

    if sqlca.sqlcode = 0  then
       open  c_cts11m04_004 using ws.atdetpcod
       fetch c_cts11m04_004 into  ws.atdetpdes
       close c_cts11m04_004
    end if

    close c_cts11m04_003

    let ws.srvtipabvdes = "NAO PREV"

    open  c_cts11m04_002 using ws.atdsrvorg
    fetch c_cts11m04_002 into  ws.srvtipabvdes

    let arr_aux = arr_aux + 1

    if arr_aux > 15  then
       error "Limite excedido! Foram encontradas mais de 15 informacoes."
       exit foreach
    end if

    if ws.atdsrvorg = 2  or    # Transporte
       ws.atdsrvorg = 3  then  # Hospedagem
       select asimtvcod into ws.asimtvcod
         from datmassistpassag
        where atdsrvnum = ws.atdsrvnum  and
              atdsrvano = ws.atdsrvano

       if ws.asimtvcod is not null  then
          let ws.asimtvdes = "NAO CADASTRADO!"

          open  c_cts11m04_001 using ws.asimtvcod
          fetch c_cts11m04_001 into  ws.asimtvdes
          close c_cts11m04_001
       end if

       if ws.pritaxflg = true  then
          let ws.pritaxflg = false

          let arr_aux = arr_aux + 1
          let a_cts11m04[arr_aux].inftxt = "Ass. Passageiros:"
       end if
    else
       if ws.prisrvflg = true  then
          let ws.prisrvflg = false

          let arr_aux = arr_aux + 1
          let a_cts11m04[arr_aux].inftxt = "Ultimos Servicos:"
       end if
    end if

    if a_cts11m04[arr_aux].inftxt is null  then
       let a_cts11m04[arr_aux].inftxt = "                  ",
                                        ws.srvtipabvdes             , " ",
                                        ws.atdsrvorg using "&&"     , "/",
                                        ws.atdsrvnum using "&&&&&&&", "-",
                                        ws.atdsrvano using "&&"     , "  ",
                                        ws.atddat[1,5]              , "  ",
                                        ws.atdetpdes
    else
       let a_cts11m04[arr_aux].inftxt = a_cts11m04[arr_aux].inftxt clipped, " ",
                                        ws.srvtipabvdes             , " ",
                                        ws.atdsrvorg using "&&"     , "/",
                                        ws.atdsrvnum using "&&&&&&&", "-",
                                        ws.atdsrvano using "&&"     , "  ",
                                        ws.atddat[1,5]              , "  ",
                                        ws.atdetpdes
    end if

    if ws.atdsrvorg = 2  or       # Transporte
       ws.atdsrvorg = 3  then     # Hospedagem
       let arr_aux = arr_aux + 1
       let a_cts11m04[arr_aux].inftxt = "                  ",
                                        ws.asimtvdes        , "  ",
                                        ws.atdcstvlr using "--,---,--&.&&"
    end if
 end foreach

 message " (F17)Abandona, (F3)Prox.Pag, (F4)Pag.Anterior"
 call set_count(arr_aux)

 display array a_cts11m04 to s_cts11m04.*
    on key (interrupt,control-c)
       initialize a_cts11m04   to null
       exit display
 end display

 close window  cts11m04
 let int_flag = false

end function  ###  cts11m04
