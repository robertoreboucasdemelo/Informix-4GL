#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24hs                                              #
# Modulo.........: cts75m00                                                  #
#............................................................................#
# Objetivo.......: Alerta Bandeira                                           #
# Analista Resp. : Humberto Santos                                           #
# PSI            : PSI-2012-23721/EV                                         #
#............................................................................#
# Desenvolvimento: Humberto Santos                                           #
# Liberacao      : 31/05/2013                                                #
#............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#database porto

 define m_prepare  smallint

 define mr_cts7500 record
        resultado  smallint,
        azlaplcod  integer,
        doc_handle integer
 end record

 define m_index smallint
#-----------------------------#
 function cts75m00_prepare()
#-----------------------------#
define l_sql        char(2000)

let l_sql = " SELECT a.azlaplcod                                ",
            " FROM datkazlapl a                                 ",
            " WHERE a.vcllicnum = ?                             ",
            " AND a.edsnumdig IN (SELECT max(edsnumdig)         ",
            "                     FROM datkazlapl b             ",
            "                     WHERE a.succod  = b.succod    ",
            "                     AND a.aplnumdig = b.aplnumdig ",
            "                     AND a.itmnumdig = b.itmnumdig ",
            "                     AND a.ramcod    = b.ramcod)   "

prepare p_cts75m00_001 from l_sql
declare c_cts75m00_001 cursor for p_cts75m00_001

let l_sql = " SELECT a.azlaplcod                                ",
            " FROM datkazlapl a                                 ",
            " WHERE a.cgccpfnum = ?                             ",
            " AND a.cgccpfdig = ?                               ",
            " AND a.edsnumdig IN (SELECT max(edsnumdig)         ",
            "                     FROM datkazlapl b             ",
            "                     WHERE a.succod  = b.succod    ",
            "                     AND a.aplnumdig = b.aplnumdig ",
            "                     AND a.itmnumdig = b.itmnumdig ",
            "                     AND a.ramcod    = b.ramcod)   "

prepare p_cts75m00_002 from l_sql
declare c_cts75m00_002 cursor for p_cts75m00_002

let l_sql = " SELECT a.azlaplcod                                ",
            " FROM datkazlapl a                                 ",
            " WHERE a.cgccpfnum = ?                             ",
            " AND a.cgcord    = ?                               ",
            " AND a.cgccpfdig = ?                               ",
            " AND a.edsnumdig IN (SELECT max(edsnumdig)         ",
            "                     FROM datkazlapl b             ",
            "                     WHERE a.succod  = b.succod    ",
            "                     AND a.aplnumdig = b.aplnumdig ",
            "                     AND a.itmnumdig = b.itmnumdig ",
            "                     AND a.ramcod    = b.ramcod)   "

prepare p_cts75m00_003 from l_sql
declare c_cts75m00_003 cursor for p_cts75m00_003

let l_sql = " select a.itaaplvigincdat,                            ",
            "        a.itaaplvigfnldat,                            ",
            "        b.itaaplcanmtvcod                             ",
            " from datmitaapl a  ,                                 ",
            "      datmitaaplitm b                                 ",
            " where a.itaciacod  = b.itaciacod                     ",
            " and   a.itaramcod  = b.itaramcod                     ",
            " and   a.itaaplnum  = b.itaaplnum                     ",
            " and   a.aplseqnum  = b.aplseqnum                     ",
            " and   b.autplcnum  = ?                               ",
            " and   a.aplseqnum  =(select max(c.aplseqnum)         ",
            "                      from datmitaapl c               ",
            "                      where a.itaciacod = c.itaciacod ",
            "                      and   a.itaramcod = c.itaramcod ",
            "                      and   a.itaaplnum = c.itaaplnum)",
            " order by a.itaaplvigfnldat desc                      "
prepare p_cts75m00_004  from l_sql
declare c_cts75m00_004  cursor for p_cts75m00_004

let l_sql = " select a.itaciacod  ,                    ",
            "        a.itaramcod  ,                    ",
            "        a.itaaplnum  ,                    ",
            "        a.aplseqnum  ,                    ",
            "  a.itaaplvigincdat  ,                    ",
            "  a.itaaplvigfnldat                       ",
            " from datmitaapl a                        ",
            " where a.pestipcod    = ?                 ",
            " and   a.segcgccpfnum = ?                 ",
            " and   a.segcgcordnum = ?                 ",
            " and   a.segcgccpfdig = ?                 ",
            " and a.aplseqnum =(select max(b.aplseqnum)",
            " from datmitaapl b                        ",
            " where a.itaciacod = b.itaciacod          ",
            " and   a.itaramcod = b.itaramcod          ",
            " and   a.itaaplnum = b.itaaplnum)         ",
            " order by a.segnom, a.itaaplvigfnldat desc"
prepare p_cts75m00_005  from l_sql
declare c_cts75m00_005  cursor for p_cts75m00_005

let l_sql = " select itaaplcanmtvcod ",
            " from datmitaaplitm     ",
            " where itaciacod = ?    ",
            " and   itaramcod = ?    ",
            " and   itaaplnum = ?    ",
            " and   aplseqnum = ?    ",
            " order by itaaplitmnum  "
prepare p_cts75m00_006  from l_sql
declare c_cts75m00_006  cursor for p_cts75m00_006

let l_sql = " select count(*)      ",
            " from datkitavippes   ",
            " where cgccpfnum = ?  ",
            " and   cgccpford = ?  ",
            " and   cgccpfdig = ?  ",
            " and   pestipcod = ?  "
prepare p_cts75m00_007  from l_sql
declare c_cts75m00_007  cursor for p_cts75m00_007

let l_sql = " select abamapol.viginc,                        ",
            "        abamapol.vigfnl,                        ",
            "        abamapol.aplstt                         ",
            "  from  abbmveic                                ",
            "       ,abamapol                                ",
            "  where abbmveic.vcllicnum = ?                  ",
            "    and abamapol.succod = abbmveic.succod       ",
            "    and abamapol.aplnumdig = abbmveic.aplnumdig ",
            "  group by abamapol.viginc,                     ",
            "           abamapol.vigfnl,                     ",
            "           abamapol.aplstt                      "
prepare p_cts75m00_008 from l_sql
declare c_cts75m00_008 cursor for p_cts75m00_008

let l_sql = "select segnumdig   "
           ," from gsakseg      "
           ," where pestip = ?  "
           ," and cgccpfnum = ? "
           ," and cgcord = ?    "
           ," and cgccpfdig = ? "
prepare p_cts75m00_009 from l_sql
declare c_cts75m00_009 cursor for p_cts75m00_009

let l_sql = " select aplstt,       ",
            "        viginc,       ",
            "        vigfnl        ",
            "   from abamapol      ",
            "  where etpnumdig = ? "
prepare p_cts75m00_010 from l_sql
declare c_cts75m00_010 cursor for p_cts75m00_010


let m_prepare = true

end function

#------------------------------------------------#
 function cts75m00_rec_placa_azul(l_par,l_tipo)
#------------------------------------------------#

     define l_par     char(07),
            l_tipo    char(01),
            l_ind     smallint,
            i         smallint

     define lr_cts75m00 record
            documento   char(30),
            itmnumdig   decimal(7,0),
            edsnumref   decimal(9,0),
            succod      smallint,
            ramcod      smallint,
            emsdat      date,
            viginc      date,
            vigfnl      date,
            segcod      integer,
            segnom      char(50),
            vcldes      char(25),
            corsus      char(06),
            situacao    char(10)
     end record

     define la_aux     array[3000] of record
            situacao   char(10)
     end record

     define la_placa  array[3000] of record
            vigfnl    date
     end record

     call cts75m00_prepare()

     initialize lr_cts75m00.*,
                mr_cts7500.*,
                la_placa,
                la_aux to null

     let mr_cts7500.resultado = 0

     let i = null

     if  l_par is not null then

         open c_cts75m00_001 using l_par

         whenever error continue
         fetch c_cts75m00_001 into  mr_cts7500.azlaplcod
         whenever error stop

         let l_ind = 0

         if  sqlca.sqlcode = 0 then

             foreach c_cts75m00_001 into  mr_cts7500.azlaplcod

                 let mr_cts7500.doc_handle = ctd02g00_agrupaXML(mr_cts7500.azlaplcod)
                 let l_ind = l_ind + 1

                 call cts38m00_extrai_dados_xml(mr_cts7500.doc_handle)
                      returning lr_cts75m00.documento,
                                lr_cts75m00.itmnumdig,
                                lr_cts75m00.edsnumref,
                                lr_cts75m00.succod,
                                lr_cts75m00.ramcod,
                                lr_cts75m00.emsdat,
                                lr_cts75m00.viginc,
                                lr_cts75m00.vigfnl,
                                lr_cts75m00.segcod,
                                lr_cts75m00.segnom,
                                lr_cts75m00.vcldes,
                                lr_cts75m00.corsus,
                                lr_cts75m00.situacao

                 let la_placa[l_ind].vigfnl = lr_cts75m00.vigfnl
                 let la_aux[l_ind].situacao = lr_cts75m00.situacao

                 if la_placa[l_ind].vigfnl >= today and
                    la_aux[l_ind].situacao = 'ATIVA' then
                     let mr_cts7500.resultado = 1
                     exit foreach
                 end if

             end foreach
         end if
     end if
     return mr_cts7500.resultado

 end function


#-------------------------------------------#
 function cts75m00_rec_cpfcgc_azul(lr_par)
#-------------------------------------------#

     define l_arr_aux smallint,
            l_ind     smallint,
            i         smallint

     define lr_par      record
            tipo        char(01),
            cgccpfnum   decimal(14,0),
            cgcord      decimal(4,0),
            cgccpfdig   decimal(2,0),
            ramcod      like gtakram.ramcod
     end record

     define lr_cts75m00 record
            documento   char(30),
            itmnumdig   decimal(7,0),
            edsnumref   decimal(9,0),
            succod      smallint,
            ramcod      smallint,
            emsdat      date,
            viginc      date,
            vigfnl      date,
            segcod      integer,
            segnom      char(50),
            vcldes      char(25),
            corsus      char(06),
            situacao    char(10)
     end record

     define la_cpfcgc array[500] of record
            vigfnl    date
     end record

     define la_aux     array[500] of record
            situacao   char(10)
     end record

     initialize la_aux to null
     initialize la_cpfcgc to null

     initialize lr_cts75m00.* to null
     initialize mr_cts7500.* to null

     let l_ind = 0
     let mr_cts7500.resultado = 0
     let i = null

     call cts75m00_prepare()

   if lr_par.ramcod = 31 or
      lr_par.ramcod = 531 then
     if  lr_par.tipo is not null and
         lr_par.cgccpfnum is not null and
         lr_par.cgccpfdig is not null then


         if  lr_par.tipo = 'F' then

             open c_cts75m00_002 using lr_par.cgccpfnum,
                                       lr_par.cgccpfdig

             whenever error continue
             fetch c_cts75m00_002 into  mr_cts7500.azlaplcod
             whenever error stop

             if  sqlca.sqlcode = 0 then

                 foreach c_cts75m00_002 into  mr_cts7500.azlaplcod
                     let l_ind = l_ind + 1

                     let mr_cts7500.doc_handle = ctd02g00_agrupaXML(mr_cts7500.azlaplcod)

                     call cts38m00_extrai_dados_xml(mr_cts7500.doc_handle)
                          returning lr_cts75m00.documento,
                                    lr_cts75m00.itmnumdig,
                                    lr_cts75m00.edsnumref,
                                    lr_cts75m00.succod,
                                    lr_cts75m00.ramcod,
                                    lr_cts75m00.emsdat,
                                    lr_cts75m00.viginc,
                                    lr_cts75m00.vigfnl,
                                    lr_cts75m00.segcod,
                                    lr_cts75m00.segnom,
                                    lr_cts75m00.vcldes,
                                    lr_cts75m00.corsus,
                                    lr_cts75m00.situacao


                     let la_cpfcgc[l_ind].vigfnl = lr_cts75m00.vigfnl
                     let la_aux[l_ind].situacao  = lr_cts75m00.situacao

                     if la_cpfcgc[l_ind].vigfnl >= today and
                        la_aux[l_ind].situacao = 'ATIVA' then

                        let mr_cts7500.resultado = 1
                        exit foreach
                     end if
                 end foreach
             end if
         else
             open c_cts75m00_003 using lr_par.cgccpfnum,
                                       lr_par.cgcord,
                                       lr_par.cgccpfdig

             whenever error continue
             fetch c_cts75m00_003 into  mr_cts7500.azlaplcod
             whenever error stop

             if  sqlca.sqlcode = 0 then
                 let l_ind = 0

                 foreach c_cts75m00_003 into  mr_cts7500.azlaplcod
                     let l_ind = l_ind + 1

                     let mr_cts7500.doc_handle = ctd02g00_agrupaXML(mr_cts7500.azlaplcod)

                     call cts38m00_extrai_dados_xml(mr_cts7500.doc_handle)
                          returning lr_cts75m00.documento,
                                    lr_cts75m00.itmnumdig,
                                    lr_cts75m00.edsnumref,
                                    lr_cts75m00.succod,
                                    lr_cts75m00.ramcod,
                                    lr_cts75m00.emsdat,
                                    lr_cts75m00.viginc,
                                    lr_cts75m00.vigfnl,
                                    lr_cts75m00.segcod,
                                    lr_cts75m00.segnom,
                                    lr_cts75m00.vcldes,
                                    lr_cts75m00.corsus,
                                    lr_cts75m00.situacao



                     let la_cpfcgc[l_ind].vigfnl = lr_cts75m00.vigfnl
                     let la_aux[l_ind].situacao  = lr_cts75m00.situacao

                       if la_cpfcgc[l_ind].vigfnl >= today and
                          la_aux[l_ind].situacao = 'ATIVA' then

                          let mr_cts7500.resultado = 1
                         exit foreach
                      end if
                 end foreach
             end if
         end if
     end if
  end if
     return mr_cts7500.resultado
 end function

#--------------------------------------------#
function cts75m00_rec_placa_itau(lr_param)
#--------------------------------------------#

define lr_param   record
       autplcnum  like datmitaaplitm.autplcnum
end record

define lr_retorno record
       resultado smallint
end record

define lr_aux           record
       itaaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod,
       itaaplvigincdat  like datmitaapl.itaaplvigincdat,
       itaaplvigfnldat  like datmitaapl.itaaplvigfnldat
end record



initialize lr_aux.*    to null

   call cts75m00_prepare()



let lr_retorno.resultado = 0

   open c_cts75m00_004 using lr_param.autplcnum


   foreach c_cts75m00_004 into lr_aux.itaaplvigincdat,
                               lr_aux.itaaplvigfnldat,
                               lr_aux.itaaplcanmtvcod


      if lr_aux.itaaplvigincdat <= today and
         lr_aux.itaaplvigfnldat  >= today then
            if lr_aux.itaaplcanmtvcod is null or
               lr_aux.itaaplcanmtvcod = " " then
               let lr_retorno.resultado = 1
               exit foreach
            end if
      end if
   end foreach

   return lr_retorno.resultado

end function

#--------------------------------------------#
function cts75m00_rec_cgccpf_itau(lr_param)
#--------------------------------------------#

define lr_param     record
       pestipcod    like datmitaapl.pestipcod,
       segcgccpfnum like datmitaapl.segcgccpfnum,
       segcgcordnum like datmitaapl.segcgcordnum,
       segcgccpfdig like datmitaapl.segcgccpfdig,
       ramcod       like gtakram.ramcod
end record

define lr_retorno record
       resultado  smallint
end record

define lr_aux          record
       itaciacod       like datmitaapl.itaciacod,
       itaramcod       like datmitaapl.itaramcod,
       itaaplnum       like datmitaapl.itaaplnum,
       aplseqnum       like datmitaapl.aplseqnum,
       itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod,
       itaaplvigincdat like datmitaapl.itaaplvigincdat,
       itaaplvigfnldat like datmitaapl.itaaplvigfnldat
end record

initialize lr_aux.*    to null


   call cts75m00_prepare()


let lr_retorno.resultado = 0
 if lr_param.ramcod = 31 or
    lr_param.ramcod = 531 then

   let m_index = 0

   if lr_param.pestipcod = "F" then
      let lr_param.segcgcordnum = 0
   end if

   open c_cts75m00_005 using lr_param.pestipcod,
                             lr_param.segcgccpfnum,
                             lr_param.segcgcordnum,
                             lr_param.segcgccpfdig

   foreach c_cts75m00_005 into lr_aux.itaciacod,
                               lr_aux.itaramcod,
                               lr_aux.itaaplnum,
                               lr_aux.aplseqnum,
                               lr_aux.itaaplvigincdat,
                               lr_aux.itaaplvigfnldat

            open c_cts75m00_006 using  lr_aux.itaciacod,
                                       lr_aux.itaramcod,
                                       lr_aux.itaaplnum,
                                       lr_aux.aplseqnum

            foreach c_cts75m00_006 into lr_aux.itaaplcanmtvcod

                  if lr_aux.itaaplvigincdat <= today and
                     lr_aux.itaaplvigfnldat  >= today then

                       if lr_aux.itaaplcanmtvcod is null or
                          lr_aux.itaaplcanmtvcod = " " then

                          let lr_retorno.resultado = 1
                          exit foreach
                       end if
                  end if
            end foreach
            if lr_retorno.resultado = 1 then
               exit foreach
            end if
   end foreach

     if lr_retorno.resultado <> 1 then
        call cts75m00_rec_cgccpf_vip_itau (lr_param.segcgccpfnum,
                                           lr_param.segcgcordnum,
                                           lr_param.segcgccpfdig,
                                           lr_param.pestipcod)
           returning lr_retorno.resultado
      end if
 end if
   return lr_retorno.resultado

end function

#--------------------------------------------------#
function cts75m00_rec_cgccpf_vip_itau(lr_param)
#--------------------------------------------------#

define lr_param   record
       cgccpfnum  like datkitavippes.cgccpfnum      ,
       cgccpford  like datkitavippes.cgccpford      ,
       cgccpfdig  like datkitavippes.cgccpfdig      ,
       pestipcod  like datkitavippes.pestipcod
end record

define lr_retorno record
       resultado  smallint
end record


   call cts75m00_prepare()


let lr_retorno.resultado = 0

   if lr_param.pestipcod = "F" then
      let lr_param.cgccpford = 0
   end if

   open c_cts75m00_007 using  lr_param.cgccpfnum ,
                              lr_param.cgccpford ,
                              lr_param.cgccpfdig ,
                              lr_param.pestipcod

   foreach c_cts75m00_007 into lr_retorno.resultado

   end foreach

   return lr_retorno.resultado

end function

#-------------------------------------------------------#
function cts75m00_rec_placa_porto(par_vcllicnum)
#-------------------------------------------------------#

 define par_vcllicnum like abbmveic.vcllicnum

 define d_abamapol record
        etpnumdig  like abamapol.etpnumdig,
        aplstt     like abamapol.aplstt   ,
        viginc     like abamapol.viginc   ,
        vigfnl     like abamapol.vigfnl
 end record

 define lr_retorno record
	 	    prporgpcp  like apamcapa.prporgpcp,
		    prpnumpcp  like apamcapa.prpnumpcp,
		    succod     like apamcapa.succod,
        viginc     like apamcapa.viginc,
        vigfnl     like apamcapa.vigfnl,
        resultado  smallint
 end record

	initialize d_abamapol.*  to  null
  initialize lr_retorno.* to null

 call cts75m00_prepare()


  let lr_retorno.resultado = 0

   open c_cts75m00_008 using par_vcllicnum

    foreach c_cts75m00_008 into d_abamapol.viginc,
                                d_abamapol.vigfnl,
                                d_abamapol.aplstt

          if d_abamapol.aplstt = "A" and
             d_abamapol.vigfnl >= today then
             let lr_retorno.resultado = 1
             exit foreach
          end if
   end foreach

    if lr_retorno.resultado = 0 then
				call faemc916_proposta_por_placa (par_vcllicnum)
					returning lr_retorno.prporgpcp,
				         		lr_retorno.prpnumpcp,
				         		lr_retorno.viginc,
				         		lr_retorno.vigfnl,
				         		lr_retorno.succod
				 if lr_retorno.prpnumpcp is not null then
				    let lr_retorno.resultado = 1
				 end if
	  end if

	return lr_retorno.resultado

end function

#------------------------------------------------------#
function cts75m00_rec_cgccpf_porto(lr_param)
#------------------------------------------------------#
define lr_param  record
       cgccpfnum like gsakseg.cgccpfnum,
       cgcord    like gsakseg.cgcord,
       cgccpfdig like gsakseg.cgccpfdig,
       pestip    like gsakseg.pestip,
       ramcod    like gtakram.ramcod
end record

define lr_retorno record
       segnumdig  like gsakseg.segnumdig,
       viginc     like abamapol.viginc,
       vigfnl     like abamapol.vigfnl,
       aplstt     like abamapol.aplstt,
       resultado  smallint
end record



   call cts75m00_prepare()


initialize lr_retorno.* to null

let lr_retorno.resultado = 0
if lr_param.ramcod = 531 or
   lr_param.ramcod = 31 then

   if lr_param.pestip = "F" then
      let lr_param.cgcord = 0
   end if

 open c_cts75m00_009 using lr_param.pestip,
                           lr_param.cgccpfnum,
                           lr_param.cgcord,
                           lr_param.cgccpfdig

  foreach c_cts75m00_009 into lr_retorno.segnumdig

    open c_cts75m00_010 using lr_retorno.segnumdig

     foreach c_cts75m00_010 into lr_retorno.aplstt,
                                 lr_retorno.viginc,
                                 lr_retorno.vigfnl
          if lr_retorno.aplstt = "A" and
             lr_retorno.vigfnl >= today then
             let lr_retorno.resultado = 1
             exit foreach
          end if
     end foreach

       if lr_retorno.resultado = 1 then
          exit foreach
       end if
  end foreach
end if
  return lr_retorno.resultado

end function