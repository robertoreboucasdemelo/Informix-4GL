############################################################################
# Nome do Modulo: CTN02C01                                           Pedro #
#                                                                          #
# Consulta Inspetorias por Cep                                    Out/1994 #
############################################################################

#---------------------------------------------------------------
# Modulo de consulta na tabela gabkins
# Gerado por: ct24h em: 24/10/94
#---------------------------------------------------------------

database porto

define i              smallint
define gm_seqpesquisa smallint

#---------------------------------------------------------------
function ctn02c01( k_ctn02c01 )
#---------------------------------------------------------------
#

   define k_ctn02c01 record
     endcep   like  glaklgd.lgdcep
   end record



   open window w_ctn02c01 at 4,2 with form "ctn02c01"

   let  gm_seqpesquisa = 0

   menu "INSPETORIAS"

   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"

           if k_ctn02c01.endcep is null     then
              message "Nenhum Cep Selecionado"
              next option "Encerra"
           else
              call pesquisa_ctn02c01(k_ctn02c01.*)
              let  gm_seqpesquisa = 0
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa Proxima  Regiao do Cep "
           if k_ctn02c01.endcep is null     then
              message "Nenhum Cep Selecionado"
              next option "Seleciona"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn02c01(k_ctn02c01.*)
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctn02c01

end function  # ctn02c01

#-------------------------------------------------------------------
function pesquisa_ctn02c01(k_ctn02c01 )
#-------------------------------------------------------------------

   define k_ctn02c01 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn02c01 array[200] of record
      iptnom         like gabkins.iptnom,
      iptcod         like gabkins.iptcod,
      endlgd         like gabkins.endlgd,
      endnum         like gabkins.endnum,
      endcmp         like gabkins.endcmp,
      endbrr         like gabkins.endbrr,
      endcid         like gabkins.endcid,
      endufd         like gabkins.endufd,
      endcep         like glaklgd.lgdcep  ,
      endcepcmp      like glaklgd.lgdcepcmp,
      dddcod         like gabkins.dddcod,
      teltxt         like gabkins.teltxt,
      tlxtxt         like gabkins.tlxtxt,
      factxt         like gabkins.factxt,
      rspnom         like gabkins.rspnom
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctn02c01[w_pf1].*  to  null
	end	for

   let int_flag = false
   while not int_flag
      declare c_ctn02c01 cursor for
          select
            iptnom,
            iptcod,
            endlgd,
            endnum,
            endcmp,
            endbrr,
            endcid,
            endufd,
            endcep  ,
            endcepcmp,
            dddcod,
            teltxt,
            tlxtxt,
            factxt,
            rspnom
          from gabkins
          where
            endcep       =      k_ctn02c01.endcep     and
            endlgd      is not  null
          order by
            endcep,
            iptnom

      let i = 1

      foreach c_ctn02c01 into a_ctn02c01[i].*

         let i          = i + 1

         if i > 1000 then
	    error "Limite de consulta excedido(1000). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn02c01 to s_ctn02c01.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error "Nenhuma inspetoria localizada neste cep - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  ctn02c01

#-------------------------------------------------------------------
function proxreg_ctn02c01(k_ctn02c01 )
#-------------------------------------------------------------------
   define k_ctn02c01 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn02c01 array[200] of record
      iptnom         like gabkins.iptnom,
      iptcod         like gabkins.iptcod,
      endlgd         like gabkins.endlgd,
      endnum         like gabkins.endnum,
      endcmp         like gabkins.endcmp,
      endbrr         like gabkins.endbrr,
      endcid         like gabkins.endcid,
      endufd         like gabkins.endufd,
      endcep         like glaklgd.lgdcep  ,
      endcepcmp      like glaklgd.lgdcepcmp,
      dddcod         like gabkins.dddcod,
      teltxt         like gabkins.teltxt,
      tlxtxt         like gabkins.tlxtxt,
      factxt         like gabkins.factxt,
      rspnom         like gabkins.rspnom
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer

   define aux_cep char(5)


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null
	let	aux_cep  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctn02c01[w_pf1].*  to  null
	end	for

   let  aux_cep = k_ctn02c01.endcep

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
       error "Nenhuma inspetoria localizada nesta regiao!"
       return
   end case

   message " Aguarde, pesquisando... ", aux_cep   attribute (reverse)

   let int_flag = false

   while not int_flag
      declare prim_ctn02c01 cursor for
          select
            iptnom,
            iptcod,
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
            tlxtxt,
            factxt,
            rspnom
          from gabkins
          where
            endcep      matches aux_cep               and
            endlgd      is not  null
          order by
            endcep desc,
            iptnom

      let i = 1
      foreach prim_ctn02c01 into a_ctn02c01[i].*

         let i          = i + 1

         if i > 200 then
	    error "Limite de consulta excedido(200). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      message " "
      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn02c01 to s_ctn02c01.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error "Nenhuma inspetoria localizada nesta regiao - Tente proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  proxreg_ctn02c01 #Proxima  Regiao do Cep
