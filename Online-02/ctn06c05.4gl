############################################################################
# Nome do Modulo: CTN06C05                                           Pedro #
#                                                                          #
# Consulta Lista_OESP por Cep                                     Jan/1995 #
############################################################################

#---------------------------------------------------------------
# Modulo de consulta na tabela dpaklista
# Gerado por: ct24h em: 06/01/95
#---------------------------------------------------------------

database porto

define i              smallint
define gm_seqpesquisa smallint

define w_ctn06c05 record
       pstsrvtip  like   dpckserv.pstsrvtip,
       pstsrvdes  like   dpckserv.pstsrvdes
end    record

#---------------------------------------------------------------
function ctn06c05(k_ctn06c05)
#---------------------------------------------------------------
#

   define k_ctn06c05 record
       endcep             like glaklgd.lgdcep
   end record



   open window j_ctn06c05 at 4,2 with form "ctn06c05"

   let gm_seqpesquisa = 0
   let int_flag       = false

   menu "LISTA_OESP"

   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
           message ""
           initialize w_ctn06c05.* to null

           if k_ctn06c05.endcep    is  null then
              error "Nenhum logradouro foi selecionado!"
              next option "Encerra"
           else
              clear form
              call pesquisa_ctn06c05(k_ctn06c05.*)
              let  gm_seqpesquisa = 0
              if  i > 1  then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa proxima regiao do cep"
           message ""
           if k_ctn06c05.endcep is null     then
              error "Nenhum Cep Selecionado!"
              next option "Encerra"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn06c05(k_ctn06c05.*)
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window j_ctn06c05

end function  # ctn06c05

#-------------------------------------------------------------------
function pesquisa_ctn06c05(k_ctn06c05)
#-------------------------------------------------------------------

   define k_ctn06c05 record
          endcep     like glaklgd.lgdcep
   end    record

   define a_ctn06c05 array[100] of record
          empnom     like dpaklista.empnom   ,
          emplstcod  like dpaklista.emplstcod,
          endlgdnom  like dpaklista.endlgd   ,
          endbrr     like dpaklista.endbrr   ,
          endcid     like dpaklista.endcid   ,
          endufd     like dpaklista.endufd   ,
          endcep     like dpaklista.endcep   ,
          endcepcmp  like dpaklista.endcepcmp,
          dddcod     like dpaklista.dddcod   ,
          teltxt     like dpaklista.teltxt   ,
          hormnhinc  like dpaklista.horsegsexinc,
          hormnhfnl  like dpaklista.horsegsexfnl,
          hortrdinc  like dpaklista.horsabinc,
          hortrdfnl  like dpaklista.horsabfnl,
          horsabinc  like dpaklista.hordominc,
          horsabfnl  like dpaklista.hordomfnl,
          hs24flg    like dpaklista.hs24flg
   end    record

   define nro_lin_corr        integer
   define scr_lin_corr        integer


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn06c05[w_pf1].*  to  null
	end	for

   input by name w_ctn06c05.pstsrvtip

         before  field pstsrvtip
                 display by name w_ctn06c05.pstsrvtip attribute (reverse)

         after   field pstsrvtip
                 display by name w_ctn06c05.pstsrvtip

                 select pstsrvdes
                   into w_ctn06c05.pstsrvdes
                   from dpckserv
                  where pstsrvtip  =  w_ctn06c05.pstsrvtip

                 if status = notfound then
                    error "Tipo de servico nao cadastrado!"

                    call ctn06c03() returning w_ctn06c05.pstsrvtip,
                                              w_ctn06c05.pstsrvdes

                    if w_ctn06c05.pstsrvtip is null or
                       w_ctn06c05.pstsrvtip =  " "  then
                       error "Tipo de servico e' obrigatorio!"
                       next field pstsrvtip
                    end if
                 end if

                 display w_ctn06c05.pstsrvtip to pstsrvtip
                 display w_ctn06c05.pstsrvdes to pstsrvdes
   end input

   let int_flag = false

   message " Aguarde, pesquisando... ", k_ctn06c05.endcep   attribute(reverse)

   while not int_flag
      declare c_ctn06c05 cursor for
        select
           dpaklista.empnom   ,
           dpaklista.emplstcod,
           dpaklista.endlgd,
           dpaklista.endbrr,
           dpaklista.endcid,
           dpaklista.endufd,
           dpaklista.endcep,
           dpaklista.endcepcmp,
           dpaklista.dddcod,
           dpaklista.teltxt,
           dpaklista.horsegsexinc,
           dpaklista.horsegsexfnl,
           dpaklista.horsabinc,
           dpaklista.horsabfnl,
           dpaklista.hordominc,
           dpaklista.hordomfnl,
           dpaklista.hs24flg
        from   dpaklista, dparservlista
        where
               dpaklista.endcep        = k_ctn06c05.endcep    and
               dpaklista.endlgd        is not null            and
               dparservlista.emplstcod = dpaklista.emplstcod  and
               dparservlista.pstsrvtip = w_ctn06c05.pstsrvtip
        order by
               endcep,
               empnom

      let i = 1

      message ""

      foreach c_ctn06c05 into a_ctn06c05[i].*
         let i          = i + 1

         if i > 100 then
	    error "Limite de consulta excedido (100). Avise a informatica!"
	    sleep 3
	    exit foreach
         end if
      end foreach

      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn06c05 to s_ctn06c05.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error "Este servico nao foi localizado neste cep - Tente Proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  ctn06c05

#-------------------------------------------------------------------
function proxreg_ctn06c05(k_ctn06c05)
#-------------------------------------------------------------------

   define k_ctn06c05 record
          endcep     like  glaklgd.lgdcep
   end    record

   define a_ctn06c05    array[100] of record
          empnom        like dpaklista.empnom   ,
          emplstcod     like dpaklista.emplstcod,
          endlgd        like dpaklista.endlgd,
          endbrr        like dpaklista.endbrr,
          endcid        like dpaklista.endcid,
          endufd        like dpaklista.endufd,
          endcep        like glaklgd.lgdcep,
          endcepcmp     like glaklgd.lgdcepcmp,
          dddcod        like dpaklista.dddcod,
          teltxt        like dpaklista.teltxt,
          horsegsexinc  like dpaklista.horsegsexinc,
          horsegsexfnl  like dpaklista.horsegsexfnl,
          horsabinc     like dpaklista.horsabinc,
          horsabfnl     like dpaklista.horsabfnl,
          hordominc     like dpaklista.hordominc,
          hordomfnl     like dpaklista.hordomfnl,
          hs24flg       like dpaklista.hs24flg
   end    record

   define nro_lin_corr integer
   define scr_lin_corr integer
   define aux_cep char(5)


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null
	let	aux_cep  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn06c05[w_pf1].*  to  null
	end	for

   let  aux_cep = k_ctn06c05.endcep

   if   gm_seqpesquisa   =   1  then
        if aux_cep[4,5]     =   "00"  then
           let  gm_seqpesquisa   =   2
        end if
   end if

   case gm_seqpesquisa
     when  1
       let  aux_cep[5,5] = "*"
     when  2
       let  aux_cep[4,5] = "* "
     when  3
       let  aux_cep[3,5] = "*  "
     when  4
       let  aux_cep[2,5] = "*   "
     otherwise
       error "Nao ha' nenhuma empresa com este servico localizado nesta regiao!"
       message ""
       return
   end case

   message " Aguarde, pesquisando... ", aux_cep    attribute(reverse)

   let int_flag = false
   while not int_flag
      declare prim_ctn06c05 cursor for
          select
           dpaklista.empnom   ,
           dpaklista.emplstcod,
           dpaklista.endlgd,
           dpaklista.endbrr,
           dpaklista.endcid,
           dpaklista.endufd,
           dpaklista.endcep,
           dpaklista.endcepcmp,
           dpaklista.dddcod,
           dpaklista.teltxt,
           dpaklista.horsegsexinc,
           dpaklista.horsegsexfnl,
           dpaklista.horsabinc,
           dpaklista.horsabfnl,
           dpaklista.hordominc,
           dpaklista.hordomfnl,
           dpaklista.hs24flg
        from   dpaklista, dparservlista
        where
               dpaklista.endcep          matches    aux_cep   and
               dpaklista.endlgd          is not null          and
               dparservlista.emplstcod = dpaklista.emplstcod  and
               dparservlista.pstsrvtip = w_ctn06c05.pstsrvtip
        order by
               endcep desc,
               empnom

      let i = 1

      foreach prim_ctn06c05 into a_ctn06c05[i].*
         let i          = i + 1

         if i > 100 then
	    error "Limite de consulta excedido (100). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      message ""

      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn06c05 to s_ctn06c05.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error "Este servico nao foi localizado nesta regiao - Tente Proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  proxreg_ctn06c05 #Proxima  Regiao do Cep
