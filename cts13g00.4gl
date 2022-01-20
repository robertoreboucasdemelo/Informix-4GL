###############################################################################
# Nome do Modulo: cts13g00                                           Gilberto #
#                                                                     Marcelo #
# Verifica se existe bloqueio para chaves informadas                 Mai/1998 #
###############################################################################
#                             MANUTENCOES                                     #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                 #
#-----------------------------------------------------------------------------#
# 04/01/2010  Amilton                            projeto sucursal smallint    #
#-----------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts13g00(param)
#-----------------------------------------------------------

 define param       record
    c24astcod       like datmligacao.c24astcod,
    ramcod          like datkblq.ramcod,
    succod          like datkblq.succod,
    aplnumdig       like datkblq.aplnumdig,
    itmnumdig       like datkblq.itmnumdig,
    vcllicnum       like datkblq.vcllicnum,
    vclchsinc       like datkblq.vclchsinc,
    vclchsfnl       like datkblq.vclchsfnl,
    segnumdig       like datkblq.segnumdig
 end record

 define a_cts13g00  array[50]  of record
    blqnum           like datkblq.blqnum,
    blqchvdes        char(09),
    blqchvcnt        char(28),
    blqnivdes        char(08)
 end record

 define ws          record
    ramcod          like datkblq.ramcod,
    succod          like datkblq.succod,
    aplnumdig       like datkblq.aplnumdig,
    itmnumdig       like datkblq.itmnumdig,
    vcllicnum       like datkblq.vcllicnum,
    vclchsinc       like datkblq.vclchsinc,
    vclchsfnl       like datkblq.vclchsfnl,
    segnumdig       like datkblq.segnumdig,
    blqnivcod       like datkblq.blqnivcod,
    c24astcod       like datrastblq.c24astcod,
    astblqsit       like datrastblq.astblqsit,
    comando0        char (1600),
    comando1        char (300),
    comando2        char (300),
    dataatu         date,
    paramqtd        dec  (2,0),
    blqramo         char (04),
    blqnum2         like datkblq.blqnum,
    blqnivcod2      like datkblq.blqnivcod,
    senhaok         char (01),
    funnom          like isskfunc.funnom
 end record

 define arr_aux    smallint
 define scr_aux    smallint



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_cts13g00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_cts13g00  to null
 initialize ws.*        to null
 let int_flag   =  false
 let arr_aux    =  1
 let ws.dataatu = today

 #---------------------------------------------------------------------
 # Consiste parametros enviados para pesquisa
 #---------------------------------------------------------------------
 if param.c24astcod is null   then
    error " Assunto nao informado. AVISE A INFORMATICA!"
    return ws.blqnivcod2, ws.senhaok
 end if

 let ws.paramqtd = 0

 if param.ramcod     is not null   or
    param.succod     is not null   or
    param.aplnumdig  is not null   or
    param.itmnumdig  is not null   then
    let ws.paramqtd = ws.paramqtd +  1
 end if
 if param.vcllicnum  is not null   then
    let ws.paramqtd = ws.paramqtd +  1
 end if
 if param.vclchsinc  is not null   then
    let ws.paramqtd = ws.paramqtd +  1
 end if
 if param.vclchsfnl  is not null   then
    let ws.paramqtd = ws.paramqtd +  1
 end if
 if param.segnumdig  is not null   then
    let ws.paramqtd = ws.paramqtd +  1
 end if

 if ws.paramqtd  =  0   then
    error " Nenhum parametro foi informado. AVISE A INFORMATICA!"
    return ws.blqnivcod2, ws.senhaok
 end if

 if ws.paramqtd  >  1   then
    error " Mais de um parametro foi informado. AVISE A INFORMATICA!"
    return ws.blqnivcod2, ws.senhaok
 end if

 if param.ramcod  =  31             or
    param.ramcod  = 531             or
    param.vcllicnum   is not null   or
    param.vclchsfnl   is not null   then
    let ws.blqramo = "auto"
 else
    if param.ramcod  <>  31  and
       param.ramcod  <> 531  then
       let ws.blqramo = "re"
    else
       error " Erro no parametro. AVISE A INFORMATICA!"
       return ws.blqnivcod2, ws.senhaok
    end if
 end if

 let ws.comando1 = "select datkblq.blqnum, ramcod,",
                   "       succod   , aplnumdig, itmnumdig, vcllicnum,",
                   "       vclchsinc, vclchsfnl, segnumdig, blqnivcod,",
                   "       c24astcod, astblqsit",
                   "  from datkblq, outer datrastblq "

 #---------------------------------------------------------------------
 # Monta select para chaves de Automovel
 #---------------------------------------------------------------------
 if ws.blqramo  = "auto"   then
    let ws.comando2 = "where datkblq.ramcod       = ?",
                      "  and datkblq.succod       = ?",
                      "  and datkblq.aplnumdig    = ?",
                      "  and datkblq.itmnumdig    = ?",
                      "  and ?                      between viginc and vigfnl",
                      "  and datrastblq.blqnum    = datkblq.blqnum",
                      "  and datrastblq.c24astcod = ?"

    let ws.comando0 = ws.comando1 clipped," ", ws.comando2

    let ws.comando2 = "where datkblq.vcllicnum    = ?",
                      "  and ?                      between viginc and vigfnl",
                      "  and datrastblq.blqnum    = datkblq.blqnum",
                      "  and datrastblq.c24astcod = ?"

    let ws.comando0 =  ws.comando0 clipped, " union" clipped, " ",
                       ws.comando1 clipped, " ",
                       ws.comando2

    let ws.comando2 = "where datkblq.vclchsfnl    = ?",
                      "  and ?                      between viginc and vigfnl",
                      "  and datrastblq.blqnum    = datkblq.blqnum",
                      "  and datrastblq.c24astcod = ?"

    let ws.comando0 =  ws.comando0 clipped, " union" clipped, " ",
                       ws.comando1 clipped, " ",
                       ws.comando2

    let ws.comando2 = "where datkblq.segnumdig    = ?",
                      "  and ?                      between viginc and vigfnl",
                      "  and datrastblq.blqnum    = datkblq.blqnum",
                      "  and datrastblq.c24astcod = ?"

    let ws.comando0 =  ws.comando0 clipped, " union" clipped, " ",
                       ws.comando1 clipped, " ",
                       ws.comando2

    #---------------------------------------------------------------------
    # Quando informado numero da apolice, buscar demais chaves
    #---------------------------------------------------------------------
    if param.aplnumdig is not  null    then
       call cts13g00_aplauto(param.succod, param.aplnumdig, param.itmnumdig)
            returning param.segnumdig, param.vcllicnum,
                      param.vclchsinc, param.vclchsfnl
    end if
 end if

 #---------------------------------------------------------------------
 # Monta select para chaves de Ramos Elementares
 #---------------------------------------------------------------------
 if ws.blqramo  =  "re"   then
    let ws.comando2 = "where datkblq.ramcod       = ?",
                      "  and datkblq.succod       = ?",
                      "  and datkblq.aplnumdig    = ?",
                      "  and ?                      between viginc and vigfnl",
                      "  and datrastblq.blqnum    = datkblq.blqnum",
                      "  and datrastblq.c24astcod = ?"

    let ws.comando0 = ws.comando1 clipped," ", ws.comando2

    let ws.comando2 = "where datkblq.segnumdig    = ?",
                      "  and ?                      between viginc and vigfnl",
                      "  and datrastblq.blqnum    = datkblq.blqnum",
                      "  and datrastblq.c24astcod = ?"

    let ws.comando0 =  ws.comando0 clipped, " union" clipped, " ",
                       ws.comando1 clipped, " ",
                       ws.comando2

    #---------------------------------------------------------------------
    # Quando informado numero da apolice, buscar demais chaves
    #---------------------------------------------------------------------
    if param.aplnumdig   is not  null    then
       call cts13g00_aplre(param.succod , param.ramcod , param.aplnumdig)
           returning  param.segnumdig
    end if
 end if

 #---------------------------------------------------------------------
 # Verifica se existe bloqueio para as chaves informadas
 #---------------------------------------------------------------------
 let ws.blqnivcod2  =  0        #--> Sem bloqeuio cadastrado

 prepare p_cts13g00_001   from ws.comando0
 declare c_cts13g00_001  cursor for  p_cts13g00_001

 if ws.blqramo  =  "auto"  then
    open    c_cts13g00_001  using  param.ramcod   , param.succod, param.aplnumdig,
                               param.itmnumdig, ws.dataatu  , param.c24astcod,
                               param.vcllicnum, ws.dataatu  , param.c24astcod,
                               param.vclchsfnl, ws.dataatu  , param.c24astcod,
                               param.segnumdig, ws.dataatu  , param.c24astcod
 else
    open    c_cts13g00_001  using  param.ramcod   , param.succod, param.aplnumdig,
                               ws.dataatu     , param.c24astcod,
                               param.segnumdig, ws.dataatu  , param.c24astcod
 end if

 foreach c_cts13g00_001 into  a_cts13g00[arr_aux].blqnum,
                          ws.ramcod,
                          ws.succod,
                          ws.aplnumdig,
                          ws.itmnumdig,
                          ws.vcllicnum,
                          ws.vclchsinc,
                          ws.vclchsfnl,
                          ws.segnumdig,
                          ws.blqnivcod,
                          ws.c24astcod,
                          ws.astblqsit

    if ws.c24astcod  is null   then
       continue foreach
    end if

    if ws.astblqsit  <>  "A"   then
       continue foreach
    end if

    #---------------------------------------------------------------------
    # Guardar nivel de bloqueio mais alto, se nao houver bloqueio fica = 0
    #---------------------------------------------------------------------
    if ws.blqnivcod   >  ws.blqnivcod2   then
       let ws.blqnum2     =  a_cts13g00[arr_aux].blqnum
       let ws.blqnivcod2  =  ws.blqnivcod
    end if

    case ws.blqnivcod
         when 01   let a_cts13g00[arr_aux].blqnivdes = "ALERTA"
         when 02   let a_cts13g00[arr_aux].blqnivdes = "SENHA"
         when 03   let a_cts13g00[arr_aux].blqnivdes = "N.ATENDE"
    end case

    if ws.ramcod      is not null   then
       let a_cts13g00[arr_aux].blqchvdes = "APOLICE"

       if ws.ramcod  =   31  or
          ws.ramcod  =  531  then
          let a_cts13g00[arr_aux].blqchvcnt =
              ws.ramcod     using "##&&"         clipped, "/",
              ws.succod     using "<<<&&"        clipped, "/",#"&&"         clipped, "/", projeto succod
              ws.aplnumdig  using "<<<<<<<<<"  clipped, "/",
              ws.itmnumdig  using "<<<<<<<"    clipped
       else
          let a_cts13g00[arr_aux].blqchvcnt =
              ws.ramcod     using "##&&"         clipped, "/",
              ws.succod     using "<<<&&"        clipped, "/",#"&&"         clipped, "/", projeto succod
              ws.aplnumdig  using "<<<<<<<<<"
       end if
    end if

    if ws.vcllicnum   is not null   then
       let a_cts13g00[arr_aux].blqchvdes = "PLACA"
       let a_cts13g00[arr_aux].blqchvcnt = ws.vcllicnum
    end if

    if ws.vclchsinc   is not null   then
       let a_cts13g00[arr_aux].blqchvdes = "CHASSI"
       let a_cts13g00[arr_aux].blqchvcnt = ws.vclchsinc clipped, ws.vclchsfnl
    end if

    if ws.segnumdig   is not null   then
       let a_cts13g00[arr_aux].blqchvdes = "SEGURADO"
       let a_cts13g00[arr_aux].blqchvcnt = ws.segnumdig
    end if

    let arr_aux  =  arr_aux + 1
    if arr_aux  >  50   then
      error " Limite excedido, atendimento c/ mais de 50 bloqueios cadastrados!"
       exit foreach
    end if
 end foreach

 #------------------------------------------------------------------
 # Se matricula cadastrada, abrir tela para digitacao de senha
 #------------------------------------------------------------------
 call set_count(arr_aux-1)

 if arr_aux  >  1   then
    open window w_cts13g00 at 07,11 with form "cts13g00"
         attribute(form line 1, border, message line last - 1)

    display "    Bloqueio(s) cadastrado(s) para o atendimento"  to cabec

    if ws.blqnivcod2  =  2   then
       error " Atendimento necessita permissao para liberacao!"
    end if

    message " (F17)Abandona, (F8)Seleciona"

    display array a_cts13g00 to s_cts13g00.*
       on key (interrupt)
          exit display

       on key (f8)
          let arr_aux = arr_curr()
          call cts13g01(a_cts13g00[arr_aux].blqnum)
    end display

    close window  w_cts13g00
 end if

 #---------------------------------------------------------------------
 # Exibe matriculas c/ permissao de liberacao/digitacao de senha
 #---------------------------------------------------------------------
 if ws.blqnivcod2  =  2   then
    call cta02m10("", ws.blqnum2)  returning ws.senhaok,ws.funnom
 end if

 return ws.blqnivcod2, ws.senhaok

end function  ###  cts13g00


#----------------------------------------------------------------------------
 function cts13g00_aplauto(param)
#----------------------------------------------------------------------------

 define param        record
    succod           like datrservapol.succod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig
 end record

 define ws2          record
    segnumdig        like gsakseg.segnumdig,
    vcllicnum        like abbmveic.vcllicnum,
    vclchsinc        like abbmveic.vclchsinc,
    vclchsfnl        like abbmveic.vclchsfnl
 end record




	initialize  ws2.*  to  null

 initialize ws2.*        to null
 initialize g_funapol.*  to null

 call f_funapol_ultima_situacao (param.succod, param.aplnumdig, param.itmnumdig)
      returning g_funapol.*

 select segnumdig
   into ws2.segnumdig
   from abbmdoc
  where succod    = param.succod    and
        aplnumdig = param.aplnumdig and
        itmnumdig = param.itmnumdig and
        dctnumseq = g_funapol.dctnumseq

 select vcllicnum,
        vclchsinc,
        vclchsfnl
   into ws2.vcllicnum,
        ws2.vclchsinc,
        ws2.vclchsfnl
   from abbmveic
  where succod    = param.succod       and
        aplnumdig = param.aplnumdig    and
        itmnumdig = param.itmnumdig    and
        dctnumseq = g_funapol.vclsitatu

 if sqlca.sqlcode = notfound  then
    select vcllicnum,
           vclchsinc,
           vclchsfnl
      into ws2.vcllicnum,
           ws2.vclchsinc,
           ws2.vclchsfnl
      from abbmveic
     where succod    = param.succod       and
           aplnumdig = param.aplnumdig    and
           itmnumdig = param.itmnumdig    and
           dctnumseq = (select max(dctnumseq)
                          from abbmveic
                         where succod    = param.succod       and
                               aplnumdig = param.aplnumdig    and
                               itmnumdig = param.itmnumdig)
 end if

 return ws2.*

end function  ###  cts13g00_aplauto


#----------------------------------------------------------------------------
 function cts13g00_aplre(param)
#----------------------------------------------------------------------------

 define param       record
    succod          like rsamseguro.succod,
    ramcod          like rsamseguro.ramcod,
    aplnumdig       like rsamseguro.aplnumdig
 end record

 define ws3         record
    segnumdig       like abbmdoc.segnumdig,
    sgrorg          like rsamseguro.sgrorg,
    sgrnumdig       like rsamseguro.sgrnumdig
 end record




	initialize  ws3.*  to  null

 initialize ws3.*   to null

 select sgrorg, sgrnumdig
   into ws3.sgrorg, ws3.sgrnumdig
   from rsamseguro
  where succod    =  param.succod     and
        ramcod    =  param.ramcod     and
        aplnumdig =  param.aplnumdig

 select segnumdig
   into ws3.segnumdig
   from rsdmdocto
  where prporg    = ws3.sgrorg
    and prpnumdig = ws3.sgrnumdig

 return ws3.segnumdig

end function  ###  cts13g00_aplre
