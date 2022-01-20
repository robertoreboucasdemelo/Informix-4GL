###############################################################################
# Nome do Modulo: CTA00M03                                           Marcelo  #
#                                                                    Gilberto #
# Pesquisa apolice por numero de proposta (AUTO)                     Jan/1996 #
###############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 01/12/1998  PSI 7263-0   Gilberto     Localizar propostas atraves do      #
#                                       Acompanhamento de Propostas         #
#############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------------
 function cta00m03(param)
#------------------------------------------------------------------------------

 define param      record
    prporgpcp      like abamdoc.prporgpcp,
    prpnumpcp      like abamdoc.prpnumpcp
 end record

 define r_cta00m03 record
    succod         like abamdoc.succod,
    ramcod         like gtakram.ramcod,
    aplnumdig      like abamdoc.aplnumdig,
    itmnumdig      like abbmdoc.itmnumdig
 end record

 define a_cta00m03 array[50] of record
    succod         like abamdoc.succod   ,
    ramcod         like gtakram.ramcod ,
    aplnumdig      like abamdoc.aplnumdig,
    itmnumdig      like abbmdoc.itmnumdig,
    viginc         like abbmdoc.viginc   ,
    vigfnl         like abbmdoc.vigfnl   ,
    aplsit         char (10),
    vcldes         char (75),
    vcllicnum      like abbmveic.vcllicnum,
    segnom         like gsakseg.segnom
 end record

 define ws         record
    sql            char (500),
    vclcoddig      like abbmveic.vclcoddig,
    segnumdig      like abbmdoc.segnumdig,
    aplstt         like abamapol.aplstt,
    itmsttatu      like abbmitem.itmsttatu,
    vclprivez      dec (1,0),
    emsdat         like abamdoc.emsdat,
    dtresol86      date
 end record

 define arr_aux    smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_cta00m03[w_pf1].*  to  null
	end	for

	initialize  r_cta00m03.*  to  null

	initialize  ws.*  to  null

 initialize r_cta00m03.* to null

 let int_flag = false
 let arr_aux  = 1

 let ws.vclprivez = true

 message " Aguarde, pesquisando..."  attribute(reverse)

 let ws.sql = "select distinct itmnumdig",
              "  from abbmdoc           ",
              " where succod    = ?  and",
              "       aplnumdig = ?"
 prepare p_cta00m03_001 from ws.sql
 declare c_cta00m03_001 cursor for p_cta00m03_001

 let ws.sql = "select viginc, vigfnl,",
              "       segnumdig      ",
              "  from abbmdoc        ",
              " where succod    = ?  ",
              "   and aplnumdig = ?  ",
              "   and itmnumdig = ?  ",
              "   and dctnumseq = ?  "
 prepare p_cta00m03_002 from ws.sql
 declare c_cta00m03_002 cursor for p_cta00m03_002

 let ws.sql = "select itmsttatu    ",
              "  from abbmitem     ",
              " where succod    = ?",
              "   and aplnumdig = ?",
              "   and itmnumdig = ?"
 prepare p_cta00m03_003 from ws.sql
 declare c_cta00m03_003 cursor for p_cta00m03_003

 let ws.sql = "select aplstt  ",
              "  from abamapol",
              " where succod    = ?",
              "   and aplnumdig = ?"
 prepare p_cta00m03_004 from ws.sql
 declare c_cta00m03_004 cursor for p_cta00m03_004

 let ws.sql = "select vclcoddig,   ",
              "       vcllicnum    ",
              "  from abbmveic     ",
              " where succod    = ?",
              "   and aplnumdig = ?",
              "   and itmnumdig = ?",
              "   and dctnumseq = ?"
 prepare p_cta00m03_005 from ws.sql
 declare c_cta00m03_005 cursor for p_cta00m03_005

 let ws.sql = "select segnom from gsakseg",
              " where segnumdig = ? "
 prepare p_cta00m03_006 from ws.sql
 declare c_cta00m03_006 cursor for p_cta00m03_006

 set isolation to dirty read

 select grlinf[01,10] into ws.dtresol86
   from datkgeral
   where grlchv='ct24resolucao86'


 declare c_cta00m03_007 cursor for
    select succod, aplnumdig
      from abamdoc
     where abamdoc.prporgpcp = param.prporgpcp
       and abamdoc.prpnumpcp = param.prpnumpcp

 foreach c_cta00m03_007 into a_cta00m03[arr_aux].succod   ,
                         a_cta00m03[arr_aux].aplnumdig
    select emsdat into ws.emsdat
         from abamdoc
      where succod    = a_cta00m03[arr_aux].succod
        and aplnumdig = a_cta00m03[arr_aux].aplnumdig
        and edsnumdig = 0
    if ws.emsdat >= ws.dtresol86 then
       let a_cta00m03[arr_aux].ramcod = 531
    else
       let a_cta00m03[arr_aux].ramcod = 31
    end if

    open    c_cta00m03_001 using a_cta00m03[arr_aux].succod,
                               a_cta00m03[arr_aux].aplnumdig
    foreach c_cta00m03_001 into  a_cta00m03[arr_aux].itmnumdig

       call f_funapol_ultima_situacao (a_cta00m03[arr_aux].succod, a_cta00m03[arr_aux].aplnumdig, a_cta00m03[arr_aux].itmnumdig)
             returning g_funapol.*

       open  c_cta00m03_002 using a_cta00m03[arr_aux].succod,
                             a_cta00m03[arr_aux].aplnumdig,
                             a_cta00m03[arr_aux].itmnumdig,
                             g_funapol.dctnumseq
       fetch c_cta00m03_002 into  a_cta00m03[arr_aux].viginc,
                             a_cta00m03[arr_aux].vigfnl,
                             ws.segnumdig

       if sqlca.sqlcode = notfound  then
          continue foreach
       end if

       close c_cta00m03_002

       open  c_cta00m03_003 using a_cta00m03[arr_aux].succod,
                              a_cta00m03[arr_aux].aplnumdig,
                              a_cta00m03[arr_aux].itmnumdig
       fetch c_cta00m03_003 into  ws.itmsttatu
       if ws.itmsttatu = "A"  then
          let a_cta00m03[arr_aux].aplsit = "ATIVO"
       else
          if ws.itmsttatu = "C"  then
             let a_cta00m03[arr_aux].aplsit = "CANCELADO"
          else
             let a_cta00m03[arr_aux].aplsit = "N/PREVISTO"
          end if
       end if
       close c_cta00m03_003

       open  c_cta00m03_004 using a_cta00m03[arr_aux].succod,
                              a_cta00m03[arr_aux].aplnumdig
       fetch c_cta00m03_004 into  ws.aplstt
       close c_cta00m03_004

       if ws.aplstt  = "C"  then
          let a_cta00m03[arr_aux].aplsit = "CANCELADO"
       end if

       open  c_cta00m03_005 using a_cta00m03[arr_aux].succod,
                              a_cta00m03[arr_aux].aplnumdig,
                              a_cta00m03[arr_aux].itmnumdig,
                              g_funapol.dctnumseq
       fetch c_cta00m03_005 into  ws.vclcoddig, a_cta00m03[arr_aux].vcldes
       close c_cta00m03_005

       if ws.vclcoddig is not null  then
          call cts15g00_vcldes(ws.vclcoddig, ws.vclprivez)
               returning a_cta00m03[arr_aux].vcldes, ws.vclprivez
       end if

       let a_cta00m03[arr_aux].segnom = "** NAO CADASTRADO **"

       open  c_cta00m03_006 using ws.segnumdig
       fetch c_cta00m03_006 into  a_cta00m03[arr_aux].segnom
       close c_cta00m03_006

       let arr_aux = arr_aux + 1
       if arr_aux > 50 then
          let arr_aux = 50
          error " Existem mais de 50 documentos para esta proposta!"
          exit foreach
       end if
    end foreach
 end foreach

 if arr_aux = 1  then
    error " Nenhum documento foi encontrado/selecionado!"
    return r_cta00m03.*
 end if

 if arr_aux > 2 then
    open window cta00m03 at 06,02 with form "cta00m03"
                attribute (form line first)

    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux - 1)

    display array a_cta00m03 to s_cta00m03.*
       on key (F8)
          let arr_aux               = arr_curr()
          let r_cta00m03.succod     = a_cta00m03[arr_aux].succod
          let r_cta00m03.ramcod     = a_cta00m03[arr_aux].ramcod
          let r_cta00m03.aplnumdig  = a_cta00m03[arr_aux].aplnumdig
          let r_cta00m03.itmnumdig  = a_cta00m03[arr_aux].itmnumdig
          exit display

       on key (interrupt)
          let int_flag = false
          initialize r_cta00m03.* to null
          exit display
    end display

    close window cta00m03
 else
    if arr_aux = 2  then
       let r_cta00m03.succod     = a_cta00m03[arr_aux - 1].succod
       let r_cta00m03.ramcod     = a_cta00m03[arr_aux - 1].ramcod
       let r_cta00m03.aplnumdig  = a_cta00m03[arr_aux - 1].aplnumdig
       let r_cta00m03.itmnumdig  = a_cta00m03[arr_aux - 1].itmnumdig
    end if
 end if

 return r_cta00m03.*

 let int_flag = false

end function  ###  cta00m03
