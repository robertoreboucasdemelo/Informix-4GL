###############################################################################
# Nome do Modulo: ctn39c00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de grupos de distribuicao do veiculos do Porto Socorro      Set/1998 #
#-----------------------------------------------------------------------------#
# Data       Autor             Origem     Alteracao                           #
# ---------- ----------------  ------     ------------------------------------#
# 21/10/2010 Alberto Rodrigues            Correcao de ^M                      #
#-----------------------------------------------------------------------------#
# 09/12/2011 Jose Kurihara     PSI-2011-21009PR Incluir grupo 00-Todos pop-up #
###############################################################################
database porto

 define m_poptodosstt smallint

#-----------------------------------------------------------
 function ctn39c00()
#-----------------------------------------------------------

 define a_ctn39c00 array[100] of record
    vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
 end record

 define ws            record
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
 end record

 define arr_aux    smallint



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_ctn39c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize ws.*         to null
 initialize a_ctn39c00   to null
 let int_flag = false
 let arr_aux  = 1

 #--> 09.12.11 Incluir grupo 00-Todos quando vier da tela cts00m03
 if m_poptodosstt   then
    let a_ctn39c00[arr_aux].vcldtbgrpdes = "Todos"
    let a_ctn39c00[arr_aux].vcldtbgrpcod = 00
    let arr_aux = arr_aux + 1
 end if

 declare c_ctn39c00_001 cursor for
    select vcldtbgrpdes, vcldtbgrpcod
      from datkvcldtbgrp
     where datkvcldtbgrp.vcldtbgrpstt  =  "A"
     order by vcldtbgrpdes

 foreach c_ctn39c00_001 into a_ctn39c00[arr_aux].vcldtbgrpdes,
                         a_ctn39c00[arr_aux].vcldtbgrpcod

    let arr_aux = arr_aux + 1

    if arr_aux > 100  then
       error " Limite excedido. Existem mais de 100 grupos cadastrados!"
       exit foreach
    end if

 end foreach

 if arr_aux > 1  then
    open window ctn39c00 at 10,45 with form "ctn39c00"
         attribute(form line 1, border)

    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array a_ctn39c00 to s_ctn39c00.*

       on key (interrupt,control-c)
          initialize a_ctn39c00    to null
          initialize ws.vcldtbgrpcod  to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.vcldtbgrpcod = a_ctn39c00[arr_aux].vcldtbgrpcod
          exit display

    end display

    let int_flag = false
    close window ctn39c00
 else
    initialize ws.vcldtbgrpcod to null
    error " Nao existem grupos de distribuicao cadastrados!"
 end if

 return ws.vcldtbgrpcod

end function  ###  ctn39c00


#-----------------------------------------------------------
 function ctn39c00_demanda(param)
#-----------------------------------------------------------
   define param record
      tipo_demanda  char(15)
   end record
   define a_ctn39c00 array[100] of record
      vcldtbgrpdes      like datkvcldtbgrp.vcldtbgrpdes,
      vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
   end record
   define ws  record
      cponom           like iddkdominio.cponom,
      vcldtbgrpcod     like datkvcldtbgrp.vcldtbgrpcod
   end record
   define l_sql     char(500)
   define l_cont    dec
   define arr_aux   smallint
   define w_pf1	    integer

   let l_sql = " select cpodes ",  # ruiz
               "   from iddkdominio ",
               "  where cponom = ? "
   prepare p_ctn39c00_001 from l_sql
   declare c_ctn39c00_002 cursor for p_ctn39c00_001

   initialize  ws.*  to  null
   initialize a_ctn39c00   to null
   let	arr_aux  =  null
   for	w_pf1  =  1  to  100
	initialize  a_ctn39c00[w_pf1].*  to  null
   end	for

   let arr_aux  = 1
   if param.tipo_demanda = 'AUTO' then
      let ws.cponom = "demandaauto"
      open c_ctn39c00_002 using ws.cponom
      foreach c_ctn39c00_002 into a_ctn39c00[arr_aux].vcldtbgrpcod
          select vcldtbgrpdes
             into a_ctn39c00[arr_aux].vcldtbgrpdes
             from datkvcldtbgrp
            where vcldtbgrpcod = a_ctn39c00[arr_aux].vcldtbgrpcod
              and vcldtbgrpstt = "A"
          let arr_aux = arr_aux + 1
          if arr_aux > 100 then
             error "Limite de array de grupos excedido(100)"
             exit foreach
          end if
      end foreach
      if arr_aux = 1 then
         initialize ws.vcldtbgrpcod to null
         error " Nao existem grupos cadastrados com dominio(demandaauto)!"
         return ws.vcldtbgrpcod
      end if
   end if
   if param.tipo_demanda = 'RE'   then
      let ws.cponom = "demandare"
      open c_ctn39c00_002 using ws.cponom
      foreach c_ctn39c00_002 into a_ctn39c00[arr_aux].vcldtbgrpcod
          select vcldtbgrpdes
             into a_ctn39c00[arr_aux].vcldtbgrpdes
             from datkvcldtbgrp
            where vcldtbgrpcod = a_ctn39c00[arr_aux].vcldtbgrpcod
              and vcldtbgrpstt = "A"
          let arr_aux = arr_aux + 1
          if arr_aux > 100 then
             error "Limite de array de grupos excedido(100)"
             exit foreach
          end if
      end foreach
      if arr_aux = 1 then
         initialize ws.vcldtbgrpcod to null
         error " Nao existem grupos cadastrados com dominio(demandare)!"
         return ws.vcldtbgrpcod
      end if
   end if
   if param.tipo_demanda = 'VP'   then
      let ws.cponom = "demandavp"
      open c_ctn39c00_002 using ws.cponom
      foreach c_ctn39c00_002 into a_ctn39c00[arr_aux].vcldtbgrpcod
          select vcldtbgrpdes
             into a_ctn39c00[arr_aux].vcldtbgrpdes
             from datkvcldtbgrp
            where vcldtbgrpcod = a_ctn39c00[arr_aux].vcldtbgrpcod
              and vcldtbgrpstt = "A"
          let arr_aux = arr_aux + 1
          if arr_aux > 100 then
             error "Limite de array de grupos excedido(100)"
             exit foreach
          end if
      end foreach
      if arr_aux = 1 then
         initialize ws.vcldtbgrpcod to null
         error " Nao existem grupos cadastrados com dominio(demandavp)!"
         return ws.vcldtbgrpcod
      end if
   end if
   if param.tipo_demanda = 'JIT'   then
      let ws.cponom = "demandajit"
      open c_ctn39c00_002 using ws.cponom
      foreach c_ctn39c00_002 into a_ctn39c00[arr_aux].vcldtbgrpcod
          select vcldtbgrpdes
             into a_ctn39c00[arr_aux].vcldtbgrpdes
             from datkvcldtbgrp
            where vcldtbgrpcod = a_ctn39c00[arr_aux].vcldtbgrpcod
              and vcldtbgrpstt = "A"
          let arr_aux = arr_aux + 1
          if arr_aux > 100 then
             error "Limite de array de grupos excedido(100)"
             exit foreach
          end if
      end foreach
      if arr_aux = 1 then
         initialize ws.vcldtbgrpcod to null
         error " Nao existem grupos cadastrados com dominio(demandajit)!"
         return ws.vcldtbgrpcod
      end if
    end if

   #declare c_ctn39c00a cursor for
   #  select vcldtbgrpdes, vcldtbgrpcod
   #    from datkvcldtbgrp
   #   where datkvcldtbgrp.vcldtbgrpstt  =  "A"
   #   order by vcldtbgrpdes

   #foreach c_ctn39c00a into a_ctn39c00[arr_aux].vcldtbgrpdes,
   #                         a_ctn39c00[arr_aux].vcldtbgrpcod

   #   let arr_aux = arr_aux + 1

   #   if arr_aux > 100  then
   #      error " Limite excedido. Existem mais de 100 grupos cadastrados!"
   #      exit foreach
   #   end if

   #end foreach
    if arr_aux > 1  then
       open window ctn39c00 at 10,45 with form "ctn39c00"
            attribute(form line 1, border)

       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_ctn39c00 to s_ctn39c00.*

          on key (interrupt,control-c)
             initialize a_ctn39c00    to null
             initialize ws.vcldtbgrpcod  to null
          exit display

          on key (F8)
             let arr_aux = arr_curr()
             let ws.vcldtbgrpcod = a_ctn39c00[arr_aux].vcldtbgrpcod
             exit display

       end display

       let int_flag = false
       close window ctn39c00
    else
       initialize ws.vcldtbgrpcod to null
       error " Nao existem grupos de distribuicao cadastrados!"
    end if

    return ws.vcldtbgrpcod
 end function

#-----------------------------------------------------------
 function ctn39c00_putOnOffTodos( l_stt )
#-----------------------------------------------------------
 define l_stt         smallint

 let m_poptodosstt = l_stt

 end function
#-----------------------------------------------------------
