############################################################################
# Nome do Modulo: CTN09C01                                           Pedro #
#                                                                          #
# Consulta Corretores por Cep                                     Out/1994 #
############################################################################

#---------------------------------------------------------------
# Modulo de consulta na tabela gcakcor
# Gerado por: ct24h em: 24/10/94
#---------------------------------------------------------------

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define gm_seqpesquisa smallint
define w_flgf8 char (01)

#---------------------------------------------------------------
function ctn09c01( k_ctn09c01 )
#---------------------------------------------------------------

   define k_ctn09c01 record
     endcep   like  gcakfilial.endcep
   end record



   open window w_ctn09c01 at 4,2 with form "ctn09c01"

   let  gm_seqpesquisa = 0

   menu "CORRETORES"

   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
           if k_ctn09c01.endcep is null     then
              message "Nenhum Cep Selecionado"
              next option "Encerra"
           else
              call pesquisa_ctn09c01(k_ctn09c01.*)
              let  gm_seqpesquisa = 0
              if  w_flgf8 = "S" then
                  exit menu
              end if
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa Proxima Regiao do Cep "
           if k_ctn09c01.endcep is null     then
              message "Nenhum Cep Selecionado"
              next option "Seleciona"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn09c01(k_ctn09c01.*)
              if w_flgf8 = "S" then
                 exit menu
              end if
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctn09c01

end function  # ctn09c01

#-------------------------------------------------------------------
function pesquisa_ctn09c01(k_ctn09c01 )
#-------------------------------------------------------------------

   define k_ctn09c01 record
     endcep          like gcakfilial.endcep
   end record

   define a_ctn09c01 array[100] of record
      cornom         like gcakcorr.cornom     ,
      corsus         like gcaksusep.corsus    ,
      endlgd         like gcakfilial.endlgd   ,
      endbrr         like gcakfilial.endbrr   ,
      endcid         like gcakfilial.endcid   ,
      endufd         like gcakfilial.endufd   ,
      endcep         like gcakfilial.endcep   ,
      endcepcmp      like gcakfilial.endcepcmp,
      dddcod         like gcakfilial.dddcod   ,
      teltxt         like gcakfilial.teltxt   ,
      factxt         like gcakfilial.factxt
   end record
   define ws   record
          grlchv     like datkgeral.grlchv,
          count      integer
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer
   define i smallint


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null
	let	i  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn09c01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   initialize ws.* to null

   let int_flag = false

   message " Aguarde, pesquisando... ", k_ctn09c01.endcep   attribute (reverse)

   while not int_flag
      declare c_ctn09c01 cursor for
          select
            gcakcorr.cornom     ,
            gcaksusep.corsus    ,
            gcakfilial.endlgd   ,
            gcakfilial.endbrr   ,
            gcakfilial.endcid   ,
            gcakfilial.endufd   ,
            gcakfilial.endcep   ,
            gcakfilial.endcepcmp,
            gcakfilial.dddcod   ,
            gcakfilial.teltxt   ,
            gcakfilial.factxt
       from gcakfilial, gcakcorr, gcaksusep
      where gcakfilial.endcep    = k_ctn09c01.endcep    and

            gcaksusep.corsuspcp  = gcakfilial.corsuspcp and
            gcaksusep.corfilnum  = gcakfilial.corfilnum and

            gcakcorr.corsuspcp   = gcaksusep.corsuspcp  and
            gcaksusep.corfilnum  = gcakfilial.corfilnum
      order by endcep

      let i = 1

      foreach c_ctn09c01 into a_ctn09c01[i].*

         let i          = i + 1

         if i > 100 then
	    error " Limite de consulta excedido(100). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      message " "

      if  i  >  1  then
          let ws.grlchv = "mvisto",
                          g_issk.funmat using "&&&&&&",
                          g_issk.maqsgl clipped
          let ws.count  = 0
          select count(*)
              into ws.count
              from datkgeral
             where grlchv = ws.grlchv
          if ws.count > 0 then        # veio da tela da VP (cts06m00)
             message " (F17)Abandona (F8)Seleciona"
          else
             message " (F17)Abandona "
          end if
          initialize w_flgf8 to null
          call set_count(i-1)

          display array a_ctn09c01 to s_ctn09c01.*
             on key (interrupt,control-m)
                exit display

             on key (F8)
                let i  =  arr_curr()
                if a_ctn09c01[i].corsus is null then
                   let a_ctn09c01[i].corsus = 0
                end if
                if ws.count > 0  then
                   update  datkgeral set grlinf = a_ctn09c01[i].corsus
                       where grlchv = ws.grlchv
                   let w_flgf8 = "S"
                end if
                exit display
          end display
      else
          error "Nenhuma corretora localizada neste cep - Tente proxima regiao!"
          let int_flag =  true
      end if
      if w_flgf8 = "S"  then
         exit while
      end if

   end while

   let int_flag = false
   if w_flgf8 = "S"  then
      return
   end if

end function  #  ctn09c01

#-------------------------------------------------------------------
function proxreg_ctn09c01(k_ctn09c01 )
#-------------------------------------------------------------------
   define k_ctn09c01 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn09c01 array[100] of record
      cornom         like gcakcorr.cornom     ,
      corsus         like gcaksusep.corsus    ,
      endlgd         like gcakfilial.endlgd   ,
      endbrr         like gcakfilial.endbrr   ,
      endcid         like gcakfilial.endcid   ,
      endufd         like gcakfilial.endufd   ,
      endcep         like gcakfilial.endcep   ,
      endcepcmp      like gcakfilial.endcepcmp,
      dddcod         like gcakfilial.dddcod   ,
      teltxt         like gcakfilial.teltxt   ,
      factxt         like gcakfilial.factxt
   end record
   define ws   record
          grlchv     like datkgeral.grlchv,
          count      integer
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer
   define i            smallint
   define aux_cep      char(5)


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null
	let	i  =  null
	let	aux_cep  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn09c01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

   initialize ws.* to null

   let  aux_cep = k_ctn09c01.endcep

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
       error " Nenhuma corretora localizada nesta regiao!"
       return
   end case

   message " Aguarde, pesquisando... ", aux_cep   attribute (reverse)

   let int_flag = false

   while not int_flag
      declare prim_ctn09c01 cursor for
          select
            gcakcorr.cornom     ,
            gcaksusep.corsus    ,
            gcakfilial.endlgd   ,
            gcakfilial.endbrr   ,
            gcakfilial.endcid   ,
            gcakfilial.endufd   ,
            gcakfilial.endcep   ,
            gcakfilial.endcepcmp,
            gcakfilial.dddcod   ,
            gcakfilial.teltxt   ,
            gcakfilial.factxt
       from gcakfilial, gcakcorr, gcaksusep
      where gcakfilial.endcep    = aux_cep              and

            gcaksusep.corsuspcp  = gcakfilial.corsuspcp and
            gcaksusep.corfilnum  = gcakfilial.corfilnum and

            gcakcorr.corsuspcp   = gcaksusep.corsuspcp  and
            gcaksusep.corfilnum  = gcakfilial.corfilnum
      order by endcep desc

      let i = 1

      foreach prim_ctn09c01 into a_ctn09c01[i].*

         let i          = i + 1

         if i > 100 then
	    error " Limite de consulta excedido(100). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      message " "

      if  i  >  1  then
          let ws.grlchv = "mvisto",
                          g_issk.funmat using "&&&&&&",
                          g_issk.maqsgl clipped
          let ws.count  = 0
          select count(*)
              into ws.count
              from datkgeral
             where grlchv = ws.grlchv
          if ws.count > 0 then        # veio da tela da VP (cts06m00)
             message " (F17)Abandona (F8)Seleciona"
          else
             message " (F17)Abandona "
          end if
          initialize w_flgf8 to null

          call set_count(i-1)

          display array a_ctn09c01 to s_ctn09c01.*
             on key (interrupt,control-m)
                exit display

             on key (F8)
                let i  =  arr_curr()
                if a_ctn09c01[i].corsus is null then
                   let a_ctn09c01[i].corsus = 0
                end if
                if ws.count > 0  then
                   update  datkgeral set grlinf = a_ctn09c01[i].corsus
                       where grlchv = ws.grlchv
                   let w_flgf8 = "S"
                end if
                exit display

          end display
      else
          error "Nenhuma corretora localizada nesta regiao - ",
                "Tente proxima regiao!"
          let int_flag =  true
      end if
      if w_flgf8 = "S" then
         exit while
      end if
   end while

   let int_flag = false
   if w_flgf8 = "S"  then
      return
   end if

end function  #  proxreg_ctn09c01 #Proxima  Regiao do Cep
