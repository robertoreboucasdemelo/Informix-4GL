############################################################################
# Nome do Modulo: CTN08C01                                           Pedro #
#                                                                          #
# Consulta Escritorios de Corretagem por Cep                      Out/1994 #
############################################################################

#---------------------------------------------------------------
# Modulo de consulta na tabela gabkesc
# Gerado por: ct24h em: 24/10/94
#---------------------------------------------------------------

database porto

define i smallint
define gm_seqpesquisa smallint

#---------------------------------------------------------------
function ctn08c01( k_ctn08c01 )
#---------------------------------------------------------------

   define k_ctn08c01 record
     endcep   like  glaklgd.lgdcep
   end record



   open window w_ctn08c01 at 4,2 with form "ctn08c01"

   let  gm_seqpesquisa = 0

   menu "ESCRITORIOS"

   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"

           if k_ctn08c01.endcep is null     then
              message "Nenhum Cep Selecionado"
              next option "Encerra"
           else
              call pesquisa_ctn08c01(k_ctn08c01.*)
              let  gm_seqpesquisa = 0
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa Proxima Regiao do Cep"
           if k_ctn08c01.endcep is null     then
              error " Nenhum Cep Selecionado!"
              next option "Seleciona"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn08c01(k_ctn08c01.*)
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctn08c01

end function  # ctn08c01

#-------------------------------------------------------------------
function pesquisa_ctn08c01(k_ctn08c01 )
#-------------------------------------------------------------------

   define k_ctn08c01 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn08c01 array[100] of record
      escnom         like gabkesc.escnom,
      esccod         like gabkesc.esccod,
      endlgd         like gabkesc.endlgd,
      endnum         like gabkesc.endnum,
      endcmp         like gabkesc.endcmp,
      endbrr         like gabkesc.endbrr,
      endcid         like gabkesc.endcid,
      endufd         like gabkesc.endufd,
      endcep         like glaklgd.lgdcep,
      endcepcmp      like glaklgd.lgdcepcmp,
      dddcod         like gabkesc.dddcod,
      teltxt         like gabkesc.teltxt,
      factxt         like gabkesc.factxt,
      rspnom         like gabkesc.rspnom
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn08c01[w_pf1].*  to  null
	end	for

   let int_flag = false
   while not int_flag
      declare c_ctn08c01 cursor for
          select
            escnom,
            esccod,
            endlgd,
            endnum,
            endcmp,
            endbrr,
            endcid,
            endufd,
            endcep,
            endcepcmp,
            dddcod,
            teltxt,
            factxt,
            rspnom
          from gabkesc
          where
            gabkesc.endcep  = k_ctn08c01.endcep     and
            gabkesc.endlgd is not  null
          order by
            endcep,
            escnom

      let i = 1

      foreach c_ctn08c01 into a_ctn08c01[i].*

         let i          = i + 1

         if i > 100 then
	    error " Limite de consulta excedido(100). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn08c01 to s_ctn08c01.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error " Nenhum escritorio localizado neste cep - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  ctn08c01

#-------------------------------------------------------------------
function proxreg_ctn08c01(k_ctn08c01 )
#-------------------------------------------------------------------
   define k_ctn08c01 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn08c01 array[100] of record
      escnom         like gabkesc.escnom,
      esccod         like gabkesc.esccod,
      endlgd         like gabkesc.endlgd,
      endnum         like gabkesc.endnum,
      endcmp         like gabkesc.endcmp,
      endbrr         like gabkesc.endbrr,
      endcid         like gabkesc.endcid,
      endufd         like gabkesc.endufd,
      endcep         like glaklgd.lgdcep,
      endcepcmp      like glaklgd.lgdcepcmp,
      dddcod         like gabkesc.dddcod,
      teltxt         like gabkesc.teltxt,
      factxt         like gabkesc.factxt,
      rspnom         like gabkesc.rspnom
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer

   define aux_cep char(5)


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null
	let	aux_cep  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn08c01[w_pf1].*  to  null
	end	for

   let  aux_cep = k_ctn08c01.endcep

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
       error " Nenhum escritorio localizado nesta regiao!"
       return
   end case

   message " Aguarde, pesquisando... ", aux_cep    attribute (reverse)

   let int_flag = false
   while not int_flag
      declare prim_ctn08c01 cursor for
          select
            escnom,
            esccod,
            endlgd,
            endnum,
            endcmp,
            endbrr,
            endcid,
            endufd,
            endcep,
            endcepcmp,
            dddcod,
            teltxt,
            factxt,
            rspnom
          from gabkesc
          where
            gabkesc.endcep matches aux_cep          and
            gabkesc.endlgd is not  null
          order by
            endcep desc,
            escnom

      let i = 1

      foreach prim_ctn08c01 into a_ctn08c01[i].*

         let i          = i + 1

         if i > 100 then
	    error " Limite de consulta excedido(100). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      message " "

      if  i  >  1  then
          call set_count(i-1)

          display array a_ctn08c01 to s_ctn08c01.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error " Nenhum escritorio localizado nesta regiao - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  proxreg_ctn08c01 #Proxima  Regiao do Cep
