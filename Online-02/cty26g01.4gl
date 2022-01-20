#------------------------------------------------------
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cty26g01                                                   #
# Analista Resp.: JUNIOR (FORNAX)                                            #
# PSI           : Obter a quantidade de atendimentos conforme assunto.       #
#............................................................................#
# Desenvolvimento: JUNIOR (FORNAX)                                           #
# Liberacao      :   /  /                                                    #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql smallint

#--------------------------#
function cty26g01_prepare()
#--------------------------#
 define l_sql char(600)

 let l_sql = ' select b.atdsrvnum '
                  ,' ,b.atdsrvano '
              ,' from datrservapol a, '
              ,'      datmservico b  '
             ,' where a.atdsrvnum = b.atdsrvnum '
               ,' and a.atdsrvano = b.atdsrvano '
               ,' and a.ramcod    = ? '
               ,' and a.succod    = ? '
               ,' and a.aplnumdig = ? '
               ,' and a.itmnumdig = ? '
               ,' and b.asitipcod = ? '

 prepare p_cty26g01_001 from l_sql
 declare c_cty26g01_001 cursor for p_cty26g01_001

 let l_sql = ' select a.atdsrvnum '
                  ,' ,a.atdsrvano '
              ,' from datmligacao a'
                  ,' ,datrligprp b '
                  ,' ,datmservico c '
             ,' where a.lignum   = b.lignum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and b.prporg    = ? '
               ,' and b.prpnumdig = ? '
               ,' and a.c24astcod = ? '
               ,' and c.asitipcod = ? '

 prepare p_cty26g01_002 from l_sql
 declare c_cty26g01_002 cursor for p_cty26g01_002

 let l_sql = ' select a.atdsrvnum '
                  ,' ,a.atdsrvano '
              ,' from datrsrvsau a '
              ,'     ,datmservico b '
             ,' where b.atdsrvnum = a.atdsrvnum '
              ,'  and b.atdsrvnum = a.atdsrvnum '
              ,'  and a.bnfnum    = ? '
              ,'  and b.asitipcod = ? '

 prepare p_cty26g01_004 from l_sql
 declare c_cty26g01_004 cursor for p_cty26g01_004

 let l_sql = " select edstip, edstxt, dctnumseq "
            ," from abbmdoc "
	    ," where succod    = ? "
	    ,"   and aplnumdig = ? "
	    ,"   and itmnumdig = ? "

 prepare p_cty26g01_005 from l_sql
 declare c_cty26g01_005 cursor with hold for p_cty26g01_005

 let l_sql = "select prporgpcp, prpnumpcp "
	    ,"from abamdoc "
	    ," where succod    = ? "
	    ,"   and aplnumdig = ? "
	    ,"   and dctnumseq = ? "

 prepare p_cty26g01_006 from l_sql
 declare c_cty26g01_006 cursor with hold for p_cty26g01_006

 let l_sql = "select clscod "
	    ," from abbmclaus "
            ," where succod    = ? "
	    ,"   and aplnumdig = ? "
	    ,"   and itmnumdig = ? "
	    ,"   and dctnumseq = ? "
            ,"   and clscod in ('044','048','44R','48R') "

 prepare p_cty26g01_007 from l_sql
 declare c_cty26g01_007 cursor with hold for p_cty26g01_007

 let l_sql = "select clscod "
	    ," from abbmclaus "
            ," where succod    = ? "
	    ,"   and aplnumdig = ? "
	    ,"   and itmnumdig = ? "
	    ,"   and dctnumseq = ? "
	    ,"   and clscod in ('044','048','44R','48R') "

 prepare p_cty26g01_008 from l_sql
 declare c_cty26g01_008 cursor with hold for p_cty26g01_008

 let l_sql = "select clscod "
            ," from abbmclaus "
	    ," where succod    = ? "
	    ,"   and aplnumdig = ? "
	    ,"   and itmnumdig = ? "
	    ,"   and dctnumseq = ? "
            ,"   and clscod in ('044','048','44R','48R') "

 prepare p_cty26g01_009 from l_sql
 declare c_cty26g01_009 cursor with hold for p_cty26g01_009

 let l_sql = "select clscod "
	    ," from abbmclaus "
            ," where succod    = ? "
	    ,"   and aplnumdig = ? "
	    ,"   and itmnumdig = ? "
	    ,"   and dctnumseq = ? "
	    ,"   and clscod in ('044','048','44R','48R') "

 prepare p_cty26g01_010 from l_sql
 declare c_cty26g01_010 cursor with hold for p_cty26g01_010


 let l_sql = "select dctnumseq from abbmclaus "
            ," where succod    = ? "
	    ,"   and aplnumdig = ? "
	    ,"   and itmnumdig = ? "
	    ,"   and dctnumseq = "
	    ," (select max(dctnumseq) from abbmclaus "
	    ," where succod    = ? "
	    ," and   aplnumdig = ? "
	    ," and   itmnumdig = ? "
	    ," and   dctnumseq < ? ) "

 prepare p_cty26g01_011 from l_sql
 declare c_cty26g01_011 cursor with hold for p_cty26g01_011

 let l_sql = "select clscod "
	    ," from abbmclaus "
	    ," where succod    = ? "
	    ,"   and aplnumdig = ? "
	    ,"   and itmnumdig = ? "
	    ,"   and dctnumseq = ? "
	    ,"   and clscod    = ? "

 prepare p_cty26g01_012 from l_sql
 declare c_cty26g01_012 cursor with hold for p_cty26g01_012

 let l_sql = ' select b.atdsrvnum '
                  ,' ,b.atdsrvano '
              ,' from datrservapol a, '
              ,'      datmservico b,  '
              ,'      datmassistpassag c  '
             ,' where a.atdsrvnum = b.atdsrvnum '
               ,' and a.atdsrvano = b.atdsrvano '
             ,'   and c.atdsrvnum = b.atdsrvnum '
               ,' and c.atdsrvano = b.atdsrvano '
               ,' and a.ramcod    = ? '
               ,' and a.succod    = ? '
               ,' and a.aplnumdig = ? '
               ,' and a.itmnumdig = ? '
               ,' and b.asitipcod = ? '
               ,' and c.asimtvcod = ? '

 prepare p_cty26g01_013 from l_sql
 declare c_cty26g01_013 cursor for p_cty26g01_013

 let l_sql = ' select a.atdsrvnum '
                  ,' ,a.atdsrvano '
              ,' from datmligacao a'
                  ,' ,datrligprp b '
                  ,' ,datmservico c '
              ,'     ,datmassistpassag d  '
             ,' where a.lignum   = b.lignum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and d.atdsrvnum = a.atdsrvnum '
               ,' and d.atdsrvnum = a.atdsrvnum '
               ,' and b.prporg    = ? '
               ,' and b.prpnumdig = ? '
               ,' and a.c24astcod = ? '
               ,' and c.asitipcod = ? '
               ,' and d.asimtvcod = ? '

 prepare p_cty26g01_014 from l_sql
 declare c_cty26g01_014 cursor for p_cty26g01_014

 let l_sql = ' select b.atdsrvnum '
                  ,' ,b.atdsrvano '
              ,' from datrservapol a, '
              ,'      datmservico b, '
              ,'      datmsrvre c    '
             ,' where a.atdsrvnum = b.atdsrvnum '
               ,' and a.atdsrvano = b.atdsrvano '
               ,' and a.atdsrvnum = c.atdsrvnum '
               ,' and a.atdsrvano = c.atdsrvano '
               ,' and a.ramcod    = ? '
               ,' and a.succod    = ? '
               ,' and a.aplnumdig = ? '
               ,' and a.itmnumdig = ? '
               ,' and c.socntzcod = ? '

 prepare p_cty26g01_015 from l_sql
 declare c_cty26g01_015 cursor for p_cty26g01_015

 let l_sql = ' select b.atdsrvnum '
                  ,' ,b.atdsrvano '
              ,' from datrservapol a, '
              ,'      datmservico b, '
              ,'      datmsrvre c    '
             ,' where a.atdsrvnum = b.atdsrvnum '
               ,' and a.atdsrvano = b.atdsrvano '
               ,' and a.atdsrvnum = c.atdsrvnum '
               ,' and a.atdsrvano = c.atdsrvano '
               ,' and a.ramcod    = ? '
               ,' and a.succod    = ? '
               ,' and a.aplnumdig = ? '
               ,' and a.itmnumdig = ? '
               ,' and c.socntzcod not in (206,207,273,274) '

 prepare p_cty26g01_016 from l_sql
 declare c_cty26g01_016 cursor for p_cty26g01_016

 let l_sql = ' select a.atdsrvnum '
                  ,' ,a.atdsrvano '
              ,' from datmligacao a'
                  ,' ,datrligprp b '
                  ,' ,datmservico c '
                  ,' ,datmsrvre d    '
             ,' where a.lignum    = b.lignum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and a.atdsrvnum = d.atdsrvnum '
               ,' and a.atdsrvano = d.atdsrvano '
               ,' and b.prporg    = ? '
               ,' and b.prpnumdig = ? '
               ,' and a.c24astcod = ? '
               ,' and d.socntzcod = ? '

 prepare p_cty26g01_017 from l_sql
 declare c_cty26g01_017 cursor for p_cty26g01_017

 let l_sql = ' select a.atdsrvnum '
                  ,' ,a.atdsrvano '
              ,' from datmligacao a'
                  ,' ,datrligprp b '
                  ,' ,datmservico c '
                  ,' ,datmsrvre d    '
             ,' where a.lignum    = b.lignum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and a.atdsrvnum = d.atdsrvnum '
               ,' and a.atdsrvano = d.atdsrvano '
               ,' and b.prporg    = ? '
               ,' and b.prpnumdig = ? '
               ,' and a.c24astcod = ? '
               ,' and d.socntzcod not in(206,207,273,274) '

 prepare p_cty26g01_018 from l_sql
 declare c_cty26g01_018 cursor for p_cty26g01_018

 let l_sql = ' select b.atdsrvnum '
                  ,' ,b.atdsrvano '
              ,' from datrservapol a, '
              ,'      datmservico b  '
             ,' where a.atdsrvnum = b.atdsrvnum '
               ,' and a.atdsrvano = b.atdsrvano '
               ,' and a.ramcod    = ? '
               ,' and a.succod    = ? '
               ,' and a.aplnumdig = ? '
               ,' and a.itmnumdig = ? '

 prepare p_cty26g01_019 from l_sql
 declare c_cty26g01_019 cursor for p_cty26g01_019

 let l_sql = ' select a.atdsrvnum '
                  ,' ,a.atdsrvano '
              ,' from datmligacao a'
                  ,' ,datrligprp b '
                  ,' ,datmservico c '
             ,' where a.lignum   = b.lignum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and c.atdsrvnum = a.atdsrvnum '
               ,' and b.prporg    = ? '
               ,' and b.prpnumdig = ? '
               ,' and a.c24astcod = ? '
               ,' and c.asitipcod = ? '

 prepare p_cty26g01_020 from l_sql
 declare c_cty26g01_020 cursor for p_cty26g01_020


 let m_prep_sql = true

end function

#----------------------------------------#
function cty26g01_qtd_servico(lr_entrada)
#----------------------------------------#
 define lr_entrada record
    ramcod    like datrservapol.ramcod
   ,succod    like datrservapol.succod
   ,aplnumdig like datrservapol.aplnumdig
   ,itmnumdig like datrservapol.itmnumdig
   ,prporgpcp like datrligprp.prporg
   ,prpnumpcp like datrligprp.prpnumdig
   ,clcdat    like datmservico.atddat
   ,c24astcod like datmligacao.c24astcod
   ,bnfnum    like datrligsau.bnfnum
   ,asitipcod like datmservico.asitipcod
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd_srv integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty26g01_prepare()
 end if

 initialize lr_servico to null

 let l_qtd_srv       = 0
 let l_resultado = null
 let l_mensagem  = null

 ##-- Obter a qtide de servcs realizados de acordo com o assunto recebido. --##
 ##-- Esta funcao recebera a apolice (ramcod, succod, aplnumdig e itmnumdig) ou recebera a proposta (prporgpcp, prpnumpcp). --##


 ##-- Obter os servicos dos atendimentos realizados pelo cartao Saude --##

 if lr_entrada.bnfnum is not null then ##PSI 202720
    open c_cty26g01_004 using lr_entrada.bnfnum,
			      lr_entrada.asitipcod

    foreach c_cty26g01_004 into lr_servico.*
       ##-- Consiste o servico para considera-lo na contagem --##

       call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                     ,lr_servico.atdsrvano
                                     ,lr_entrada.c24astcod
                                     ,lr_entrada.clcdat)
       returning l_resultado, l_mensagem

       if l_resultado = 1 then
          let l_qtd_srv  = l_qtd_srv + 1
       else
          if l_resultado = 3 then
             error l_mensagem
             exit foreach
          end if
       end if
    end foreach
    close c_cty26g01_004

 else

    ##-- Obter os servicos dos atendimentos realizados pela apolice --##
    if lr_entrada.aplnumdig is not null then
       open c_cty26g01_001 using lr_entrada.ramcod
                                ,lr_entrada.succod
                                ,lr_entrada.aplnumdig
                                ,lr_entrada.itmnumdig
                                ,lr_entrada.asitipcod

       foreach c_cty26g01_001 into lr_servico.*
          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem

          if l_resultado = 1 then
             let l_qtd_srv  = l_qtd_srv + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cty26g01_001
    end if

    ##-- Obter os servicos dos atendimentos realizados pela proposta --##
    if lr_entrada.prpnumpcp is not null then
       open c_cty26g01_002 using lr_entrada.prporgpcp
                              ,lr_entrada.prpnumpcp
                              ,lr_entrada.c24astcod
			      ,lr_entrada.asitipcod


       foreach c_cty26g01_002 into lr_servico.atdsrvnum
                                ,lr_servico.atdsrvano

          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem


          if l_resultado = 1 then
             let l_qtd_srv  = l_qtd_srv + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cty26g01_002
    end if

 end if

 return l_qtd_srv

end function

#--------------------------------------------------#
function cty26g01_clausula(l_param)
#--------------------------------------------------#

define l_param record
succod     like  isskfunc.succod   ,
aplnumdig  like  abbmveic.aplnumdig,
itmnumdig  like  abbmveic.itmnumdig
end record

define l_out   record
  errocod      smallint  #(0 = OK  ou  1 = Ocorreu Erro)
 ,clscod       char(03)
 ,clcdat       date
 ,edsflg       char(01)  #(tipos 1 ou 2 ou 3/63 = "S", caso contrario = "N")
end record

define l_doc   record
  edstip       dec(2,0)
 ,edstxt       dec(2,0)
 ,dctnumseq    dec(4,0)
 ,prporgpcp    dec(2,0)
 ,prpnumpcp    dec(8,0)
 ,clscod       char(03)
 ,data         date
 ,olddat       date
 ,newdat       date
end record

define l_ret   record
   result       char(1)
  ,dctnumseq    like abbmdoc.dctnumseq
  ,vclsitatu    like abbmitem.vclsitatu
  ,autsitatu    like abbmitem.autsitatu
  ,dmtsitatu    like abbmitem.dmtsitatu
  ,dpssitatu    like abbmitem.dpssitatu
  ,appsitatu    like abbmitem.appsitatu
  ,vidsitatu    like abbmitem.vidsitatu
end record

define l_dctnumseq_ant    like abbmdoc.dctnumseq,
       l_indica_clausula  smallint


  initialize l_doc.* to null
  let l_out.errocod = 0
  let l_out.clscod  = null
  let l_out.clcdat  = null
  let l_out.edsflg  = null

     call cty26g01_prepare()

  if l_param.succod    is null or
     l_param.aplnumdig is null or
     l_param.itmnumdig is null then
     let l_out.errocod = 1
     return l_out.*
  end if

  whenever error continue
  open c_cty26g01_005 using l_param.succod
	                   ,l_param.aplnumdig
			   ,l_param.itmnumdig
  whenever error stop
  if sqlca.sqlcode < 0 then
     let l_out.errocod = 1
     display "Erro no acesso a ABBMDOC <cty26g01>.: ", sqlca.sqlcode
     return l_out.*
  end if

  foreach c_cty26g01_005 into l_doc.edstip ,l_doc.edstxt ,l_doc.dctnumseq

    case
       when l_doc.edstip = 0
            let l_out.edsflg = 'N'

       when l_doc.edstip = 1 or l_doc.edstip = 2
	    let l_out.edsflg = 'S'

       when l_doc.edstip = 3
	    if l_doc.edstxt = 63 then
	       let l_out.edsflg = 'S'
	    end if

       otherwise
            continue foreach
    end case

    if l_doc.edstip = 3 then
       let l_indica_clausula = false

       open c_cty26g01_011 using l_param.succod,
			         l_param.aplnumdig,
			         l_param.itmnumdig,
                                 l_param.succod,
			         l_param.aplnumdig,
			         l_param.itmnumdig,
			         l_doc.dctnumseq
       whenever error continue
       fetch c_cty26g01_011 into l_dctnumseq_ant
       whenever error stop
       if sqlca.sqlcode <> 0 then
	  if sqlca.sqlcode = notfound then
	     let l_dctnumseq_ant = l_doc.dctnumseq
          else
	     display 'Erro - leitura abbmclaus(max), st.: ', sqlca.sqlcode
	     let l_out.errocod = 1
	     return l_out.*
	  end if
       end if

       open c_cty26g01_007 using l_param.succod,
			         l_param.aplnumdig,
			         l_param.itmnumdig,
			         l_doc.dctnumseq
       foreach c_cty26g01_007 into l_out.clscod

	  open c_cty26g01_012 using l_param.succod,
	                            l_param.aplnumdig,
	                            l_param.itmnumdig,
				    l_dctnumseq_ant,
				    l_out.clscod
	     whenever error continue
	     fetch c_cty26g01_012
	     whenever error stop
	     if sqlca.sqlcode = notfound then
		let l_indica_clausula = true
	        exit foreach
	     end if

	     if sqlca.sqlcode <> 0 then
	        display 'Erro - leitura abbmclaus(c_cty26g01_012), st.: ', sqlca.sqlcode
                let l_out.errocod = 1
	        return l_out.*
	     end if

       end foreach
       close c_cty26g01_007

       open c_cty26g01_008 using l_param.succod,
			       l_param.aplnumdig,
			       l_param.itmnumdig,
			       l_doc.dctnumseq
       foreach c_cty26g01_008 into l_out.clscod

           open c_cty26g01_012 using l_param.succod,
				   l_param.aplnumdig,
	                           l_param.itmnumdig,
				   l_dctnumseq_ant,
				   l_out.clscod
	   whenever error continue

           fetch c_cty26g01_012
	   whenever error stop
	   if sqlca.sqlcode = notfound then
	      let l_indica_clausula = true
	      exit foreach
	   end if

	   if sqlca.sqlcode <> 0 then
	      display 'Erro - leitura abbmclaus(c_cty26g01_012), st.: ', sqlca.sqlcode
              let l_out.errocod = 1
	      return l_out.*
	   end if

     end foreach
     close c_cty26g01_008

     if l_indica_clausula = false then
        continue foreach
     end if

  end if

  whenever error continue
   open c_cty26g01_006 using l_param.succod
		            ,l_param.aplnumdig
			    ,l_doc.dctnumseq
   fetch c_cty26g01_006 into l_doc.prporgpcp
		            ,l_doc.prpnumpcp
   whenever error stop

   if sqlca.sqlcode < 0 then
      Display "Erro no acesso a ABBMDOC <faemc144>.: ", sqlca.sqlcode
      let l_out.errocod = 1
      return l_out.*
   end if

   if sqlca.sqlcode = 100 then
      continue foreach
   end if

   let l_doc.data = faemc603_apolice(l_param.succod
		                    ,l_param.aplnumdig
				    ,l_doc.dctnumseq,"")

   if l_doc.data < '01/08/2004' then
      let l_doc.olddat = l_doc.data
      continue foreach
   end if

   let l_out.clcdat = l_doc.data

   end foreach

   if l_out.clcdat is null then
      let l_out.clcdat = l_doc.olddat
   end if

   call f_funapol_ultima_situacao(l_param.succod
				 ,l_param.aplnumdig
	 		 	 ,l_param.itmnumdig)
      returning l_ret.*

   whenever error continue
   open c_cty26g01_007 using l_param.succod
		            ,l_param.aplnumdig
			    ,l_param.itmnumdig
			    ,l_ret.dctnumseq
   fetch c_cty26g01_007 into l_doc.clscod
   whenever error stop

   if sqlca.sqlcode < 0 then
      Display "Erro no acesso a ABBMCLAUS <faemc144>.: ", sqlca.sqlcode
      return l_out.*
   end if

   if sqlca.sqlcode = 0 then
      let l_out.clscod = l_doc.clscod
   else
      whenever error continue
      open c_cty26g01_008 using l_param.succod
			       ,l_param.aplnumdig
			       ,l_param.itmnumdig
			       ,l_ret.dctnumseq
      fetch c_cty26g01_008 into l_doc.clscod

      whenever error stop

      if sqlca.sqlcode < 0 then
         Display "Erro no acesso a ABBMCLAUS <faemc144>.: ", sqlca.sqlcode
	 return l_out.*
      end if

      if sqlca.sqlcode = 0 then
	 let l_out.clscod = l_doc.clscod
      end if
   end if

   return l_out.*

end function

#--------------------------------------------------#
function cty26g01_lim_cext(l_param)
#--------------------------------------------------#

define l_param record
   clscod         like abbmclaus.clscod      ,
   avialgmtv      like datmavisrent.avialgmtv,
   c24astcod      like datkassunto.c24astcod
end record

define l_lim integer

 let l_lim = 0

  ### Porto Socorro Pane Mecanica
  #----------------------------------------

  if l_param.clscod = "044"  or
     l_param.clscod = "44R"  then
     if  l_param.avialgmtv = 2 and
	 l_param.c24astcod = "H10" then
         let l_lim = 07
     end if
  end if


  ### Beneficio de Sinitstro
  #----------------------------------------

  if l_param.clscod = "44R"  or
     l_param.clscod = "048"  or
     l_param.clscod = "48R"  then
     if  l_param.avialgmtv = 3 and
	 (l_param.c24astcod = "H10" or
	  l_param.c24astcod = "H12") then
         let l_lim = 07
     end if
  end if


  ### Departamento / Particular
  #----------------------------------------

  if l_param.clscod = "044"  or
     l_param.clscod = "048"  or
     l_param.clscod = "44R"  or
     l_param.clscod = "48R"  then
     if  (l_param.avialgmtv = 4  or
	  l_param.avialgmtv = 5) and
	 (l_param.c24astcod = "H10" or
	  l_param.c24astcod = "H11" or
	  l_param.c24astcod = "H12" or
	  l_param.c24astcod = "H13") then
         let l_lim = 999
     end if
  end if


  ### Beneficio TercSeg Porto
  #----------------------------------------

  if l_param.clscod = "044"  or
     l_param.clscod = "44R"  or
     l_param.clscod = "048"  or
     l_param.clscod = "48R"  then
     if  l_param.avialgmtv = 6 and
        (l_param.c24astcod = "H11"  or
	 l_param.c24astcod = "H13") then
         let l_lim = 07
     end if
  end if


  ### Terceiro Qualquer
  #----------------------------------------

  if l_param.clscod = "044"  then
     if  l_param.avialgmtv = 7 and
        (l_param.c24astcod = "H11"  or
	 l_param.c24astcod = "H13") then
         let l_lim = 07
     end if
  end if


  ### Seg como Terceiro em Cong/Porto/Part
  #----------------------------------------

  if l_param.clscod = "044"  then
     if  l_param.avialgmtv = 8 and
         l_param.c24astcod = "H10" then
         let l_lim = 07
     end if
  end if


  ### Indenizacao Integral
  #----------------------------------------

  if l_param.clscod = "44R"  then
     if  l_param.avialgmtv = 9 and
         l_param.c24astcod = "H10" then
         let l_lim = 07
     end if
  end if


  ### Indenizacao Integral 30 dias
  #----------------------------------------

  if l_param.clscod = "044"  then
     if  l_param.avialgmtv = 13 and
        (l_param.c24astcod = "H10"  or
         l_param.c24astcod = "H12") then
         let l_lim = 30
     end if
  end if


  ### Tempo Indeterminado Perda Parcial
  #----------------------------------------

  if l_param.clscod = "044"  then
     if  l_param.avialgmtv = 14 and
        (l_param.c24astcod = "H10"  or
         l_param.c24astcod = "H12") then
         let l_lim = 999
     end if
  end if

  if l_param.clscod = "044" or
     l_param.clscod = "047" then
     if  l_param.avialgmtv = 23 and
         l_param.c24astcod = "H10" then
         let l_lim = 15
     end if
  end if
  return l_lim

end function

#----------------------------------------#
function cty26g01_qtd_servico_mtv(lr_entrada)
#----------------------------------------#
 define lr_entrada record
    ramcod    like datrservapol.ramcod
   ,succod    like datrservapol.succod
   ,aplnumdig like datrservapol.aplnumdig
   ,itmnumdig like datrservapol.itmnumdig
   ,prporgpcp like datrligprp.prporg
   ,prpnumpcp like datrligprp.prpnumdig
   ,clcdat    like datmservico.atddat
   ,c24astcod like datmligacao.c24astcod
   ,asitipcod like datmservico.asitipcod
   ,asimtvcod like datkasimtv.asimtvcod
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd_srv integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty26g01_prepare()
 end if

 if lr_entrada.asitipcod <> 5 and
    lr_entrada.asimtvcod <> 14 then
    let l_qtd_srv = 999
    return l_qtd_srv
 end if

 initialize lr_servico to null

 let l_qtd_srv       = 0
 let l_resultado = null
 let l_mensagem  = null

 ##-- Obter a qtide de servcs realizados de acordo com o assunto recebido. --##
 ##-- Esta funcao recebera a apolice (ramcod, succod, aplnumdig e itmnumdig) ou recebera a proposta (prporgpcp, prpnumpcp). --##

    ##-- Obter os servicos dos atendimentos realizados pela apolice --##
    if lr_entrada.aplnumdig is not null then
       open c_cty26g01_013 using lr_entrada.ramcod
                                ,lr_entrada.succod
                                ,lr_entrada.aplnumdig
                                ,lr_entrada.itmnumdig
                                ,lr_entrada.asitipcod
                                ,lr_entrada.asimtvcod

       foreach c_cty26g01_013 into lr_servico.*
          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem

          if l_resultado = 1 then
             let l_qtd_srv  = l_qtd_srv + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cty26g01_001
    end if

    ##-- Obter os servicos dos atendimentos realizados pela proposta --##
    if lr_entrada.prpnumpcp is not null then
       open c_cty26g01_014 using lr_entrada.prporgpcp
                              ,lr_entrada.prpnumpcp
                              ,lr_entrada.c24astcod
			      ,lr_entrada.asitipcod
			      ,lr_entrada.asimtvcod

       foreach c_cty26g01_014 into lr_servico.atdsrvnum
                                  ,lr_servico.atdsrvano

          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem

          if l_resultado = 1 then
             let l_qtd_srv  = l_qtd_srv + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cty26g01_002
    end if

 return l_qtd_srv

end function

#---------------------------------------------#
function cty26g01_qtd_servicos_caca(lr_entrada)
#---------------------------------------------#
 define lr_entrada record
    ramcod    like datrservapol.ramcod
   ,succod    like datrservapol.succod
   ,aplnumdig like datrservapol.aplnumdig
   ,itmnumdig like datrservapol.itmnumdig
   ,prporgpcp like datrligprp.prporg
   ,prpnumpcp like datrligprp.prpnumdig
   ,clcdat    like datmservico.atddat
   ,c24astcod like datmligacao.c24astcod
   ,bnfnum    like datrligsau.bnfnum
   ,socntzcod like datmsrvre.socntzcod
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd_srv integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty26g01_prepare()
 end if

 initialize lr_servico to null

 let l_qtd_srv       = 0
 let l_resultado = null
 let l_mensagem  = null

 ##-- Obter a qtide de servcs realizados de acordo com o assunto recebido. --##
 ##-- Esta funcao recebera a apolice (ramcod, succod, aplnumdig e itmnumdig) ou recebera a proposta (prporgpcp, prpnumpcp). --##

 if lr_entrada.aplnumdig is not null then
    if lr_entrada.socntzcod is not null then
       open c_cty26g01_015 using lr_entrada.ramcod,
			         lr_entrada.succod,
			         lr_entrada.aplnumdig,
			         lr_entrada.itmnumdig,
                                 lr_entrada.socntzcod

       foreach c_cty26g01_015 into lr_servico.*
          ##-- Consiste o servico para considera-lo na contagem --##

          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem

          if l_resultado = 1 then
             let l_qtd_srv  = l_qtd_srv + 1
          else
             if l_resultado = 3 then
                error l_mensagem
                exit foreach
             end if
          end if
       end foreach
       close c_cty26g01_015

    else

       ##-- Obter os servicos dos atendimentos realizados pela apolice --##
       open c_cty26g01_016 using lr_entrada.ramcod
                                   ,lr_entrada.succod
                                   ,lr_entrada.aplnumdig
                                   ,lr_entrada.itmnumdig

       foreach c_cty26g01_016 into lr_servico.*

          if lr_entrada.c24astcod = 'S41' or
	     lr_entrada.c24astcod = 'S42' then
             call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                           ,lr_servico.atdsrvano
					   ,"S41"
					   ,lr_entrada.clcdat)

             returning l_resultado, l_mensagem

             if l_resultado = 1 then
                let l_qtd_srv  = l_qtd_srv + 1
             else
                call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                              ,lr_servico.atdsrvano
					      ,"S42"
					      ,lr_entrada.clcdat)

                returning l_resultado, l_mensagem

                if l_resultado = 1 then
                   let l_qtd_srv  = l_qtd_srv + 1
                end if
	     end if
          else
             ##-- Consiste o servico para considera-lo na contagem --##
             call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                           ,lr_servico.atdsrvano
					   ,lr_entrada.c24astcod
					   ,lr_entrada.clcdat)

             returning l_resultado, l_mensagem

             if l_resultado = 1 then
                let l_qtd_srv  = l_qtd_srv + 1
             else
                if l_resultado = 3 then
                   error l_mensagem sleep 2
                   exit foreach
                end if
             end if
	  end if
       end foreach
       close c_cty26g01_016

   end if
 end if

       ##-- Obter os servicos dos atendimentos realizados pela proposta --##
 if lr_entrada.prpnumpcp is not null then
    if lr_entrada.socntzcod is not null then
       open c_cty26g01_017 using lr_entrada.prporgpcp
                              ,lr_entrada.prpnumpcp
                              ,lr_entrada.c24astcod
			      ,lr_entrada.socntzcod

       foreach c_cty26g01_017 into lr_servico.atdsrvnum
                                  ,lr_servico.atdsrvano

          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem


          if l_resultado = 1 then
             let l_qtd_srv  = l_qtd_srv + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cty26g01_017
    else
       open c_cty26g01_018 using lr_entrada.prporgpcp
                                ,lr_entrada.prpnumpcp
                                ,lr_entrada.c24astcod

       foreach c_cty26g01_018 into lr_servico.atdsrvnum
                                  ,lr_servico.atdsrvano

          if lr_entrada.c24astcod = 'S41' or
	     lr_entrada.c24astcod = 'S42' then
             call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                           ,lr_servico.atdsrvano
					   ,"S41"
					   ,lr_entrada.clcdat)

             returning l_resultado, l_mensagem

             if l_resultado = 1 then
                let l_qtd_srv  = l_qtd_srv + 1
             else
                call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                              ,lr_servico.atdsrvano
					      ,"S42"
					      ,lr_entrada.clcdat)

                returning l_resultado, l_mensagem

                if l_resultado = 1 then
                   let l_qtd_srv  = l_qtd_srv + 1
                end if
	     end if
          else
             ##-- Consiste o servico para considera-lo na contagem --##
             call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                           ,lr_servico.atdsrvano
                                           ,lr_entrada.c24astcod
                                           ,lr_entrada.clcdat)
             returning l_resultado, l_mensagem


             if l_resultado = 1 then
                let l_qtd_srv  = l_qtd_srv + 1
             else
                if l_resultado = 3 then
                   error l_mensagem sleep 2
                   exit foreach
                end if
             end if
          end if
       end foreach
       close c_cty26g01_018
    end if
 end if

 return l_qtd_srv

end function
#--------------------------------------------------------------------------#

#----------------------------------------#
function cty26g01_qtd_servico_s54(lr_entrada)
#----------------------------------------#
 define lr_entrada record
    ramcod    like datrservapol.ramcod
   ,succod    like datrservapol.succod
   ,aplnumdig like datrservapol.aplnumdig
   ,itmnumdig like datrservapol.itmnumdig
   ,prporgpcp like datrligprp.prporg
   ,prpnumpcp like datrligprp.prpnumdig
   ,clcdat    like datmservico.atddat
   ,c24astcod like datmligacao.c24astcod
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd_srv integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty26g01_prepare()
 end if

 initialize lr_servico to null

 let l_qtd_srv       = 0
 let l_resultado = null
 let l_mensagem  = null

 ##-- Obter a qtide de servcs realizados de acordo com o assunto recebido. --##
 ##-- Esta funcao recebera a apolice (ramcod, succod, aplnumdig e itmnumdig) ou recebera a proposta (prporgpcp, prpnumpcp). --##

 ##-- Obter os servicos dos atendimentos realizados pelo cartao Saude --##

    ##-- Obter os servicos dos atendimentos realizados pela apolice --##
    if lr_entrada.aplnumdig is not null then
       open c_cty26g01_019 using lr_entrada.ramcod
                                ,lr_entrada.succod
                                ,lr_entrada.aplnumdig
                                ,lr_entrada.itmnumdig

       foreach c_cty26g01_019 into lr_servico.*
          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem

          if l_resultado = 1 then
             let l_qtd_srv  = l_qtd_srv + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cty26g01_019
    end if

    ##-- Obter os servicos dos atendimentos realizados pela proposta --##
    if lr_entrada.prpnumpcp is not null then
       open c_cty26g01_020 using lr_entrada.prporgpcp
                              ,lr_entrada.prpnumpcp
                              ,lr_entrada.c24astcod


       foreach c_cty26g01_020 into lr_servico.atdsrvnum
                                ,lr_servico.atdsrvano

          ##-- Consiste o servico para considera-lo na contagem --##
          call cta02m15_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_entrada.c24astcod
                                        ,lr_entrada.clcdat)
          returning l_resultado, l_mensagem

          if l_resultado = 1 then
             let l_qtd_srv  = l_qtd_srv + 1
          else
             if l_resultado = 3 then
                error l_mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close c_cty26g01_020
    end if

 return l_qtd_srv

end function
