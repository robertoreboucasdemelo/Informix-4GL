###############################################################################
# Nome do Modulo: CTA00M14                                           Pedro    #
#                                                                    Marcelo  #
# Mostra Todas Apolices Encontradas por Nome do Segurado (RE)        Mar/1995 #
###############################################################################
#                                 ALTERACOES                                  #
###############################################################################
# 05/06/2001 PSI 112518  Raji    Consulta R.E. Locais de Risco                #
#-----------------------------------------------------------------------------#
# 22/10/2002 Sofia       Raji    Ajuste endereco Locais de Risco endosso      #
#-----------------------------------------------------------------------------#
# 28/04/2004 - CT-203904  Leandro - Ramo igual a Tranp selecionar com seq 1.  #
#-----------------------------------------------------------------------------#
#                         * * * A L T E R A C A O * * *                       #
#  Analista Resp. : Kiandra Antonello                                         #
#  CT             : 205540                                                    #
#.............................................................................#
#  Data        Autor Fabrica  Alteracao                                       #
#  03/05/2004  Gustavo(FSW)   Na  selecao  da  tabela  gtakram, fazer "select #
#                             unique".                                        #
#                                                                             #
#  05/05/2004  Helio (FSW)    CT 206342 No cursor c_cta00m14_005 quando ramo for#
#                             diferente de TRANSPD não selecionar o campo     #
#                             dctnumseq                                       #
#                                                                             #
#   22/03/2007  Roberto        Ordenacao das Apolices Vigentes e por Ramo     #
#                                                                             #
# 10/08/2011 Marcos Goes   PSI            Alteracao na busca de apolices RE   #
#                          2011-14183/EV  para ordenar as apolices vencidas   #
#                                         da mais recente para a mais antiga  #
#                                         e exibir a data de vencimento.      #
#                                                                             #
###############################################################################
#globals  "/homedsa/fontes/ct24h/producao/glct.4gl"
globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------------
function cta00m14_prepare()
#------------------------------------------------------------------------------

#--- Prepare

  define w_cmd char(1000)

  let w_cmd = "select segnom from gsakseg ",
              " where gsakseg.segnumdig = ? "
  prepare p_cta00m14_001 from w_cmd
  declare c_cta00m14_001 cursor for p_cta00m14_001

  let w_cmd = "select sgrorg, sgrnumdig ",
              "  from rsamseguro        ",
              " where succod = ?        ",
              "   and ramcod = ?        ",
              "   and aplnumdig = ?     "
  prepare p_cta00m14_002 from w_cmd
  declare c_cta00m14_002 cursor for p_cta00m14_002

  let w_cmd = "select dctnumseq, vigfnl ",
              " from rsdmdocto ",
              " where prporg    = ?            ",
              "   and prpnumdig = ?            "
  prepare p_cta00m14_003 from w_cmd
  declare c_cta00m14_003 cursor for p_cta00m14_003
                                                             
                                                             
  let w_cmd = "select unique ramsgl from gtakram ",
              " where ramcod  =  ?        "
  prepare p_cta00m14_004 from w_cmd
  declare c_cta00m14_004 cursor for p_cta00m14_004

  let w_cmd = "select max(dctnumseq) from rsdmdocto ",
              " where sgrorg     =  ?  ",
              "   and sgrnumdig  =  ?  ",
              "   and prporg    <> 58  ",
              "   and dctnumseq  =  1  "
  prepare p_cta00m14_005 from w_cmd
  declare c_cta00m14_005 cursor for p_cta00m14_005

  let w_cmd = "select prporg, prpnumdig from rsdmdocto ",
              " where sgrorg    = ?                    ",
              "   and sgrnumdig = ?                    ",
              "   and dctnumseq = ?                    "
  prepare p_cta00m14_006 from w_cmd
  declare c_cta00m14_006 cursor for p_cta00m14_006

  let w_cmd = "select vigfnl from rsdmdocto ",
              " where prporg    = ?         ",
              "   and prpnumdig = ?         "
  prepare p_cta00m14_007 from w_cmd
  declare c_cta00m14_007 cursor for p_cta00m14_007

  let w_cmd = "select max(dctnumseq) from rsdmdocto ",
              " where sgrorg     =  ?  ",
              "   and sgrnumdig  =  ?  ",
              "   and prporg    <> 58  "
  prepare p_cta00m14_008 from w_cmd
  declare c_cta00m14_008 cursor for p_cta00m14_008

  let w_cmd = "select endlgdtip, endlgdnom, endnum,   ",
              "       ufdcod   , endcmp   , endbrr,   ",
              "       endcid   , endcep   , endcepcmp ",
              "  from rlaklocal                       ",
              " where lclrsccod = ?                   "
  prepare p_cta00m14_009 from w_cmd
  declare c_cta00m14_009 cursor for p_cta00m14_009


end function #----fim cta00m14_prepare

#------------------------------------------------------------------------------
function cta00m14_prep_temp()
#------------------------------------------------------------------------------

    define w_ins char(1000)

    let w_ins = 'insert into cta00m14_temp'
	     , ' values(?,?,?,?,?,?,?,?,?,?,?,?,?)'
    prepare p_cta00m14_010 from w_ins

end function #----fim cta00m14_prep_temp

#------------------------------------------------------------------------------
function cta00m14()
#------------------------------------------------------------------------------
 define t_cta00m14 array[500] of record
  segnom    like gsakseg.segnom      ,
  documento char (35)                ,
  endereco  char (75)                ,
  vigente   char (02)                ,
  succod    like abamapol.succod     ,
  ramcod    like rsamseguro.ramcod   ,
  aplnumdig like rsamseguro.aplnumdig,
  lclnumseq like rsdmlocal.lclnumseq ,
  endereco2 char(30)                 ,
  venc      char(5)                  ,#Marcos Goes
  vigfnl    like rsdmdocto.vigfnl    ,#Marcos Goes
  ord       smallint                 ,
  codram    smallint
 end record

 define t_cta00m14ord array[500] of record
   segnom    like gsakseg.segnom      ,
   documento char (35)                ,
   endereco  char (75)                ,
   vigente   char (02)                ,
   succod    like abamapol.succod     ,
   ramcod    like rsamseguro.ramcod   ,
   aplnumdig like rsamseguro.aplnumdig,
   lclnumseq like rsdmlocal.lclnumseq ,
   endereco2 char(30)                 ,
   venc      char(5)                  ,#Marcos Goes
   vigfnl    like rsdmdocto.vigfnl    #Marcos Goes
 end record

 define bd_gsakseg record
  segnumdig like gsakseg.segnumdig,
  segnom    like gsakseg.segnom
 end record


 define d_rsdmlocal record
  lclnumseq like rsdmlocal.lclnumseq,
  lclrsccod like rsdmlocal.lclrsccod
 end record

 define d_rlaklocal record
  lclrsccod like rlaklocal.lclrsccod,
  endlgdtip like rlaklocal.endlgdtip,
  endlgdnom like rlaklocal.endlgdnom,
  endnum    like rlaklocal.endnum   ,
  ufdcod    like rlaklocal.ufdcod   ,
  endcmp    like rlaklocal.endcmp   ,
  endbrr    like rlaklocal.endbrr   ,
  endcid    like rlaklocal.endcid   ,
  endcep    like rlaklocal.endcep   ,
  endcepcmp like rlaklocal.endcepcmp
 end record

 define arr_aux integer
 define arr_loc integer
 define arr_ord integer


 define w_vigfnl    like rsdmdocto.vigfnl
 define l_ramsgl    char(15)

 define l_codvig    smallint
 define l_codram    smallint

 define w_dctoalfa record
  succod    char(02),
  ramcod    char(04),
  aplnumdig char(09),
  edsnumdig char(09)
 end record

 define d_auxord record
   auxsegnom    like gsakseg.segnom      ,
   auxdocumento char (35)                ,
   auxendereco  char (75)                ,
   auxvigente   char (02)                ,
   auxsuccod    like abamapol.succod     ,
   auxramcod    like rsamseguro.ramcod   ,
   auxaplnumdig like rsamseguro.aplnumdig,
   auxlclnumseq like rsdmlocal.lclnumseq ,
   auxendereco2 char(30)                 ,
   auxvenc      char(5)                  ,#Marcos Goes
   auxvigfnl    like rsdmdocto.vigfnl     #Marcos Goes   
 end record

 define aux_dctnumseq  like rsdmdocto.dctnumseq
 define aux_prporg     like rsdmdocto.prporg
 define aux_prpnumdig  like rsdmdocto.prpnumdig
 define aux_sgrorg     like rsamseguro.sgrorg
 define aux_sgrnumdig  like rsamseguro.sgrnumdig
 define l_seq1         like rsdmdocto.dctnumseq
 define l_seq2         like rsdmdocto.dctnumseq



	define	w_pf1	integer

	let	arr_aux  =  null
	let	arr_loc  =  null
	let	arr_ord  =  null
	let	w_vigfnl =  null
	let	l_seq1   =  null
	let	l_seq2   =  null
	let	aux_dctnumseq  =  null
	let	aux_prporg     =  null
	let	aux_prpnumdig  =  null
	let	aux_sgrorg     =  null
	let	aux_sgrnumdig  =  null

        let     l_codvig       =  null
        let     l_codram       =  null

	for	w_pf1  =  1  to  500
		initialize  t_cta00m14[w_pf1].*  to  null
		initialize  t_cta00m14ord[w_pf1].*  to  null
	end	for

	initialize  bd_gsakseg.*  to  null

	initialize  d_rsdmlocal.*  to  null

	initialize  d_rlaklocal.*  to  null

	initialize  w_dctoalfa.*  to  null

	initialize  d_auxord.*  to  null

 # -- Roberto -- Crio uma Temporaria para Ordernar as Apolices

if not cta00m14_cria_temp() then
       call cta00m14_replace()
       return
 end if

 if int_flag then
    let int_flag = false
    return
 end if


  call cta00m14_prepare()

  call cta00m14_prep_temp()



 let int_flag = false

 open window cta00m14 at 4,2 with form "cta00m14"
             attribute(form line first)



 error ""
 message " Aguarde, formatando os dados..." attribute (reverse)


 let arr_aux = 0
 let arr_loc = 0
 let arr_ord = 0

 for arr_aux = 1 to g_index

  if int_flag then
     let arr_aux = 0
     exit for
  end if

  let w_dctoalfa.succod    = g_dctoarray[arr_aux].succod
  let w_dctoalfa.ramcod    = g_dctoarray[arr_aux].ramcod
  let w_dctoalfa.aplnumdig = g_dctoarray[arr_aux].aplnumdig



  open c_cta00m14_001 using g_dctoarray[arr_aux].segnumdig
  fetch c_cta00m14_001 into  bd_gsakseg.segnom

  open c_cta00m14_002 using g_dctoarray[arr_aux].succod,
                          g_dctoarray[arr_aux].ramcod,
                          g_dctoarray[arr_aux].aplnumdig
  fetch c_cta00m14_002 into aux_sgrorg, aux_sgrnumdig

  open c_cta00m14_003 using g_dctoarray[arr_aux].prporg,
                         g_dctoarray[arr_aux].prpnumdig
  fetch c_cta00m14_003 into aux_dctnumseq

  open  c_cta00m14_004 using g_dctoarray[arr_aux].ramcod
  fetch c_cta00m14_004 into l_ramsgl
                                              

     #if l_ramsgl = "TRANSP" then
#	let l_seq1 = 1
	let l_seq2 = 1
#     else
#	let l_seq1 = 0
#	let l_seq2 = aux_dctnumseq
#     end if

     if l_ramsgl = "TRANSP" then      #CT 206342
        open c_cta00m14_005 using aux_sgrorg   ,
   			        aux_sgrnumdig
        fetch c_cta00m14_005 into aux_dctnumseq
     else
        open c_cta00m14_008 using aux_sgrorg   ,
   			        aux_sgrnumdig
        fetch c_cta00m14_008 into aux_dctnumseq
     end if

  close c_cta00m14_004

  open c_cta00m14_006 using aux_sgrorg   ,
                          aux_sgrnumdig,
                          aux_dctnumseq
  fetch c_cta00m14_006 into aux_prporg, aux_prpnumdig

  #------------------------------------------------------------
  # PROCURA ENDERECOS (LOCAIS DE RISCO)
  #------------------------------------------------------------
  declare  c_cta00m14_010   cursor for
     select lclrsccod, lclnumseq
       from rsdmlocal
       where prporg    = aux_prporg         and
             prpnumdig = aux_prpnumdig

  foreach  c_cta00m14_010  into  d_rsdmlocal.lclrsccod,
                             d_rsdmlocal.lclnumseq

     initialize w_vigfnl   to null
     open c_cta00m14_007 using aux_prporg,
                             aux_prpnumdig
     fetch c_cta00m14_007 into w_vigfnl

     let arr_loc = arr_loc + 1
     let t_cta00m14[arr_loc].segnom    = bd_gsakseg.segnom
     let t_cta00m14[arr_loc].documento =
              w_dctoalfa.succod           using "&&"        clipped, ".",
              w_dctoalfa.ramcod           using "&&&&"      clipped, ".",
              w_dctoalfa.aplnumdig        using "&&&&&&&&&" clipped, "/",
              g_dctoarray[arr_aux].prporg using "&&"        clipped, ".",
              g_dctoarray[arr_aux].prpnumdig using "&&&&&&&&"  clipped, " L",
              d_rsdmlocal.lclnumseq       using "&&"
     let t_cta00m14[arr_loc].succod    = g_dctoarray[arr_aux].succod
     let t_cta00m14[arr_loc].ramcod    = g_dctoarray[arr_aux].ramcod
     let t_cta00m14[arr_loc].aplnumdig = g_dctoarray[arr_aux].aplnumdig
     let t_cta00m14[arr_loc].lclnumseq = d_rsdmlocal.lclnumseq       
     

	   let t_cta00m14[arr_loc].venc = "Venc:" #Marcos Goes
	   let t_cta00m14[arr_loc].vigfnl = w_vigfnl #Marcos Goes

      if w_vigfnl  is not null   then
         if w_vigfnl < today   then
            let t_cta00m14[arr_loc].vigente = "Vc"
	         let t_cta00m14[arr_loc].ord = 1
         else
	         let t_cta00m14[arr_loc].ord = 0
         end if
     else
           let t_cta00m14[arr_loc].ord = 0
     end if


     if g_documento.ramcod = w_dctoalfa.ramcod then
        let t_cta00m14[arr_loc].codram = 0
     else
        let t_cta00m14[arr_loc].codram = 1
     end if




     open c_cta00m14_009 using d_rsdmlocal.lclrsccod
     fetch c_cta00m14_009 into d_rlaklocal.endlgdtip,
                            d_rlaklocal.endlgdnom,
                            d_rlaklocal.endnum   ,
                            d_rlaklocal.ufdcod   ,
                            d_rlaklocal.endcmp   ,
                            d_rlaklocal.endbrr   ,
                            d_rlaklocal.endcid   ,
                            d_rlaklocal.endcep   ,
                            d_rlaklocal.endcepcmp

     call frama185_end (d_rlaklocal.endlgdtip, d_rlaklocal.endlgdnom,
                        d_rlaklocal.endnum   , d_rlaklocal.ufdcod   ,
                        d_rlaklocal.endcmp   , d_rlaklocal.endbrr   ,
                        d_rlaklocal.endcid   , d_rlaklocal.endcep)
          returning t_cta00m14[arr_loc].endereco

     let t_cta00m14[arr_loc].endereco2
       = " CEP: ", d_rlaklocal.endcep using "&&&&&",
              "-", d_rlaklocal.endcepcmp using "&&&"

# -- Roberto -- Insiro na Temporaria

      whenever error continue

      execute p_cta00m14_010 using t_cta00m14[arr_loc].segnom     ,
			                          t_cta00m14[arr_loc].documento  ,
				                       t_cta00m14[arr_loc].succod     ,
				                       t_cta00m14[arr_loc].ramcod     ,
                                   t_cta00m14[arr_loc].aplnumdig  ,
				                       t_cta00m14[arr_loc].lclnumseq  ,
				                       t_cta00m14[arr_loc].vigente    ,
				                       t_cta00m14[arr_loc].endereco   ,
				                       t_cta00m14[arr_loc].endereco2  ,
				                       t_cta00m14[arr_loc].ord        ,
				                       t_cta00m14[arr_loc].codram     ,
				                       t_cta00m14[arr_loc].venc       , #Marcos Goes
				                       t_cta00m14[arr_loc].vigfnl       #Marcos Goes

      whenever error stop

 # -- Roberto -- Se Houver Algum Erro de Insercao na Temporaria, Dropo a Temporaria
 # -- e Chamo a Funcao para Trazer as Apolices Desordenadas

      if sqlca.sqlcode <> 0 then
            close window cta00m14
            call cta00m14_drop_temp()
            call cta00m14_replace()
            return
      end if

  end foreach

end for

# -- Roberto -- Recupero da Tabela Temporaria e Descarrego na Tela

       declare c_cta00m14_011 cursor for
       select distinct segnom , documento, succod   ,
              ramcod , aplnumdig, lclnumseq,
              vigente, endereco , endereco2,
              codvig, codram, venc, vigfnl
       from cta00m14_temp
       order by codvig, vigfnl desc, codram, ramcod

       foreach  c_cta00m14_011 into  d_auxord.auxsegnom     ,
                                     d_auxord.auxdocumento  ,
                                     d_auxord.auxsuccod     ,
                                     d_auxord.auxramcod     ,
                                     d_auxord.auxaplnumdig  ,
                                     d_auxord.auxlclnumseq  ,
                                     d_auxord.auxvigente    ,
                                     d_auxord.auxendereco   ,
                                     d_auxord.auxendereco2  ,
                                     l_codvig               ,
                                     l_codram               ,
                                     d_auxord.auxvenc       ,
                                     d_auxord.auxvigfnl     
                                    
       let arr_ord = arr_ord + 1

       let t_cta00m14ord[arr_ord].segnom     = d_auxord.auxsegnom
       let t_cta00m14ord[arr_ord].documento  = d_auxord.auxdocumento
       let t_cta00m14ord[arr_ord].succod     = d_auxord.auxsuccod
       let t_cta00m14ord[arr_ord].ramcod     = d_auxord.auxramcod
       let t_cta00m14ord[arr_ord].aplnumdig  = d_auxord.auxaplnumdig
       let t_cta00m14ord[arr_ord].lclnumseq  = d_auxord.auxlclnumseq
       let t_cta00m14ord[arr_ord].endereco   = d_auxord.auxendereco
       let t_cta00m14ord[arr_ord].endereco2  = d_auxord.auxendereco2
       let t_cta00m14ord[arr_ord].vigente    = d_auxord.auxvigente        
       let t_cta00m14ord[arr_ord].venc       = d_auxord.auxvenc       
       let t_cta00m14ord[arr_ord].vigfnl     = d_auxord.auxvigfnl
       
      end foreach

message " (F17)Abandona, (F8)Seleciona"

if arr_aux > 0 then
   let arr_aux = arr_ord #arr_loc #g_index

   call set_count(arr_aux)   

   display array t_cta00m14ord to s_cta00m14.*
     on key (interrupt)
       let arr_aux = arr_curr()
       let g_index = arr_aux

       initialize g_documento.succod,
                  g_documento.ramcod,
                  g_documento.aplnumdig,
                  g_documento.itmnumdig to null
       let g_documento.lclnumseq = t_cta00m14ord[g_index].lclnumseq

       call cta00m14_drop_temp()

       exit display

     on key (F8)
       let arr_aux = arr_curr()
       let g_index = arr_aux

       let g_documento.succod    = t_cta00m14ord[g_index].succod
       let g_documento.ramcod    = t_cta00m14ord[g_index].ramcod
       let g_documento.aplnumdig = t_cta00m14ord[g_index].aplnumdig
       let g_documento.lclnumseq = t_cta00m14ord[g_index].lclnumseq

       call cta00m14_drop_temp()

       exit display

   end display

end if

let int_flag = false

close window cta00m14

end function #----fim cta00m14



#------------------------------------------------------------------------------
function cta00m14_cria_temp()
#------------------------------------------------------------------------------


 whenever error continue
      create temp table cta00m14_temp(segnom    char (50)    ,
                                      documento char (35)    ,
		                                succod    decimal(2,0) ,
         	                          ramcod    smallint     ,
	                                   aplnumdig decimal(9,0) ,
                                      lclnumseq decimal(4,0) ,
				                          vigente   char (02)    ,
				                          endereco  char (75)    ,
                                      endereco2 char(30)     ,
                                      codvig    smallint     ,
                                      codram    smallint     ,
                                      venc      char(5)      ,
                                      vigfnl    date) with no log
  whenever error stop


      if sqlca.sqlcode <> 0  then

	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        call cta00m14_drop_temp()
	  end if

	 return false

     end if

     return true

end function #----fim cta00m14_cria_temp

#------------------------------------------------------------------------------
function cta00m14_drop_temp()
#------------------------------------------------------------------------------

    whenever error continue
        drop table cta00m14_temp
    whenever error stop

    return

end function #----fim cta00m14_drop_temp


#------------------------------------------------------------------------------
function cta00m14_replace()
#------------------------------------------------------------------------------


define t_cta00m14 array[500] of record
  segnom    like gsakseg.segnom      ,
  documento char (35)                ,
  endereco  char (75)                ,
  vigente   char (02)                ,
  succod    like abamapol.succod     ,
  ramcod    like rsamseguro.ramcod   ,
  aplnumdig like rsamseguro.aplnumdig,
  lclnumseq like rsdmlocal.lclnumseq ,
  endereco2 char(30)                 ,
  venc      char(5)                  ,#Marcos Goes
  vigfnl    like rsdmdocto.vigfnl     #Marcos Goes  
 end record

 define bd_gsakseg record
  segnumdig like gsakseg.segnumdig,
  segnom    like gsakseg.segnom
 end record

 define d_rsdmlocal record
  lclnumseq like rsdmlocal.lclnumseq,
  lclrsccod like rsdmlocal.lclrsccod
 end record

 define d_rlaklocal record
  lclrsccod like rlaklocal.lclrsccod,
  endlgdtip like rlaklocal.endlgdtip,
  endlgdnom like rlaklocal.endlgdnom,
  endnum    like rlaklocal.endnum   ,
  ufdcod    like rlaklocal.ufdcod   ,
  endcmp    like rlaklocal.endcmp   ,
  endbrr    like rlaklocal.endbrr   ,
  endcid    like rlaklocal.endcid   ,
  endcep    like rlaklocal.endcep   ,
  endcepcmp like rlaklocal.endcepcmp
 end record

 define arr_aux integer
 define arr_loc integer

 define w_vigfnl    like rsdmdocto.vigfnl
 define l_ramsgl    char(15)

 define w_cmd char(1000)

 define w_dctoalfa record
  succod    char(02),
  ramcod    char(04),
  aplnumdig char(09),
  edsnumdig char(09)
 end record

 define aux_dctnumseq  like rsdmdocto.dctnumseq
 define aux_prporg     like rsdmdocto.prporg
 define aux_prpnumdig  like rsdmdocto.prpnumdig
 define aux_sgrorg     like rsamseguro.sgrorg
 define aux_sgrnumdig  like rsamseguro.sgrnumdig
 define l_seq1         like rsdmdocto.dctnumseq
 define l_seq2         like rsdmdocto.dctnumseq


	define	w_pf1	integer

	let	arr_aux  =  null
	let	arr_loc  =  null
	let	w_vigfnl =  null
	let	l_seq1   =  null
	let	l_seq2   =  null
	let	aux_dctnumseq  =  null
	let	aux_prporg     =  null
	let	aux_prpnumdig  =  null
	let	aux_sgrorg     =  null
	let	aux_sgrnumdig  =  null

	let	arr_aux  =  null
	let	arr_loc  =  null
	let	w_vigfnl =  null
	let	l_seq1   =  null
	let	l_seq2   =  null
	let	aux_dctnumseq  =  null
	let	aux_prporg     =  null
	let	aux_prpnumdig  =  null
	let	aux_sgrorg     =  null
	let	aux_sgrnumdig  =  null

	for	w_pf1  =  1  to  500
		initialize  t_cta00m14[w_pf1].*  to  null
	end	for

	initialize  bd_gsakseg.*  to  null

	initialize  d_rsdmlocal.*  to  null

	initialize  d_rlaklocal.*  to  null

	initialize  w_dctoalfa.*  to  null

        call cta00m14_prepare()

 if int_flag then
    let int_flag = false
    return
 end if


 let int_flag = false

 open window cta00m14 at 4,2 with form "cta00m14"
             attribute(form line first)


 error ""
 message " Aguarde, formatando2 os dados..." attribute (reverse)

 let arr_aux = 0
 let arr_loc = 0

 for arr_aux = 1 to g_index

  if int_flag then
     let arr_aux = 0
     exit for
  end if

  let w_dctoalfa.succod    = g_dctoarray[arr_aux].succod
  let w_dctoalfa.ramcod    = g_dctoarray[arr_aux].ramcod
  let w_dctoalfa.aplnumdig = g_dctoarray[arr_aux].aplnumdig

  open c_cta00m14_001 using g_dctoarray[arr_aux].segnumdig
  fetch c_cta00m14_001 into  bd_gsakseg.segnom

  open c_cta00m14_002 using g_dctoarray[arr_aux].succod,
                          g_dctoarray[arr_aux].ramcod,
                          g_dctoarray[arr_aux].aplnumdig
  fetch c_cta00m14_002 into aux_sgrorg, aux_sgrnumdig

  open c_cta00m14_003 using g_dctoarray[arr_aux].prporg,
                         g_dctoarray[arr_aux].prpnumdig
  fetch c_cta00m14_003 into aux_dctnumseq

  open  c_cta00m14_004 using g_dctoarray[arr_aux].ramcod
  fetch c_cta00m14_004 into l_ramsgl

     #if l_ramsgl = "TRANSP" then
#	let l_seq1 = 1
	let l_seq2 = 1
#     else
#	let l_seq1 = 0
#	let l_seq2 = aux_dctnumseq
#     end if

     if l_ramsgl = "TRANSP" then      #CT 206342
        open c_cta00m14_005 using aux_sgrorg   ,
   			        aux_sgrnumdig
        fetch c_cta00m14_005 into aux_dctnumseq
     else
        open c_cta00m14_008 using aux_sgrorg   ,
   			        aux_sgrnumdig
        fetch c_cta00m14_008 into aux_dctnumseq
     end if

  close c_cta00m14_004

  open c_cta00m14_006 using aux_sgrorg   ,
                          aux_sgrnumdig,
                          aux_dctnumseq
  fetch c_cta00m14_006 into aux_prporg, aux_prpnumdig

  #------------------------------------------------------------
  # PROCURA ENDERECOS (LOCAIS DE RISCO)
  #------------------------------------------------------------
  declare  c_cta00m14_012   cursor for
     select lclrsccod, lclnumseq
       from rsdmlocal
       where prporg    = aux_prporg         and
             prpnumdig = aux_prpnumdig

  foreach  c_cta00m14_012  into  d_rsdmlocal.lclrsccod,
                                d_rsdmlocal.lclnumseq

     initialize w_vigfnl   to null
     open c_cta00m14_007 using aux_prporg,
                             aux_prpnumdig
     fetch c_cta00m14_007 into w_vigfnl

     let arr_loc = arr_loc + 1
     let t_cta00m14[arr_loc].segnom    = bd_gsakseg.segnom
     let t_cta00m14[arr_loc].documento =
              w_dctoalfa.succod           using "&&"        clipped, ".",
              w_dctoalfa.ramcod           using "&&&&"      clipped, ".",
              w_dctoalfa.aplnumdig        using "&&&&&&&&&" clipped, "/",
              g_dctoarray[arr_aux].prporg using "&&"        clipped, ".",
              g_dctoarray[arr_aux].prpnumdig using "&&&&&&&&"  clipped, " L",
              d_rsdmlocal.lclnumseq       using "&&"
     let t_cta00m14[arr_loc].succod    = g_dctoarray[arr_aux].succod
     let t_cta00m14[arr_loc].ramcod    = g_dctoarray[arr_aux].ramcod
     let t_cta00m14[arr_loc].aplnumdig = g_dctoarray[arr_aux].aplnumdig
     let t_cta00m14[arr_loc].lclnumseq = d_rsdmlocal.lclnumseq

     let t_cta00m14[arr_loc].venc    = "Venc:"   #Marcos Goes
     let t_cta00m14[arr_loc].vigfnl  = w_vigfnl  #Marcos Goes
           
     if w_vigfnl  is not null   then
        if w_vigfnl < today   then
           let t_cta00m14[arr_loc].vigente = "Vc"
        end if
     end if

     open c_cta00m14_009 using d_rsdmlocal.lclrsccod
     fetch c_cta00m14_009 into d_rlaklocal.endlgdtip,
                            d_rlaklocal.endlgdnom,
                            d_rlaklocal.endnum   ,
                            d_rlaklocal.ufdcod   ,
                            d_rlaklocal.endcmp   ,
                            d_rlaklocal.endbrr   ,
                            d_rlaklocal.endcid   ,
                            d_rlaklocal.endcep   ,
                            d_rlaklocal.endcepcmp

     call frama185_end (d_rlaklocal.endlgdtip, d_rlaklocal.endlgdnom,
                        d_rlaklocal.endnum   , d_rlaklocal.ufdcod   ,
                        d_rlaklocal.endcmp   , d_rlaklocal.endbrr   ,
                        d_rlaklocal.endcid   , d_rlaklocal.endcep)
          returning t_cta00m14[arr_loc].endereco

     let t_cta00m14[arr_loc].endereco2
       = " CEP: ", d_rlaklocal.endcep using "&&&&&",
              "-", d_rlaklocal.endcepcmp using "&&&"
  end foreach

end for

message " (F17)Abandona, (F8)Seleciona"

if arr_aux > 0 then
   let arr_aux = arr_loc #g_index

   call set_count(arr_aux)

   display array t_cta00m14 to s_cta00m14.*
     on key (interrupt)
       let arr_aux = arr_curr()
       let g_index = arr_aux

       initialize g_documento.succod,
                  g_documento.ramcod,
                  g_documento.aplnumdig,
                  g_documento.itmnumdig to null
       let g_documento.lclnumseq = t_cta00m14[g_index].lclnumseq


       exit display

     on key (F8)
       let arr_aux = arr_curr()
       let g_index = arr_aux

       let g_documento.succod    = t_cta00m14[g_index].succod
       let g_documento.ramcod    = t_cta00m14[g_index].ramcod
       let g_documento.aplnumdig = t_cta00m14[g_index].aplnumdig
       let g_documento.lclnumseq = t_cta00m14[g_index].lclnumseq
       exit display

   end display

end if

let int_flag = false

close window cta00m14

end function #----fim cta00m14_replace
