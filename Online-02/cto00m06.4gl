###############################################################################
# Nome do Modulo: cto00m06                                           Ruiz     #
# Pop-up de tipos de solicitante para sinistro transportes           Ago/2002 #
# Alteracoes:                                                                 #
# DATA       RESPONSAVEL    DESCRICAO                                         #
#-----------------------------------------------------------------------------#
# 13/10/2008 Carla Rampazzo Criar funcao para retornar a descricao            #
###############################################################################

database porto

#-----------------------------------------------------------
 function cto00m06()
#-----------------------------------------------------------

 define a_cto00m06 array[20] of record
    c24soltipdes   like datksoltip.c24soltipdes,
    c24soltipcod   like datksoltip.c24soltipcod
 end record

 define arr_aux    smallint

 define ws         record
    c24soltipcod   like datksoltip.c24soltipcod,
    c24soltipdes   like datksoltip.c24soltipdes,
    c24soltipord   like datksoltip.c24soltipord
 end record

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  20
		initialize  a_cto00m06[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let int_flag = false

 initialize a_cto00m06   to null

 let a_cto00m06[1].c24soltipcod = 1
 let a_cto00m06[1].c24soltipdes = "MOTORISTA"
 let a_cto00m06[2].c24soltipcod = 2
 let a_cto00m06[2].c24soltipdes = "POLICIA RODOVIARIA"
 let a_cto00m06[3].c24soltipcod = 3
 let a_cto00m06[3].c24soltipdes = "PONTO DE APOIO"
 let a_cto00m06[4].c24soltipcod = 4
 let a_cto00m06[4].c24soltipdes = "SEGURADO"
 let a_cto00m06[5].c24soltipcod = 4
 let a_cto00m06[5].c24soltipdes = "CORRETOR"
 let arr_aux  = 6

 if arr_aux > 1  then
    if arr_aux = 2  then
       let ws.c24soltipcod = a_cto00m06[arr_aux - 1].c24soltipcod
    else
       open window cto00m00 at 12,52 with form "cto00m00"
                            attribute(form line 1, border)
       message " (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cto00m06 to s_cto00m00.*
          on key (interrupt,control-c)
             initialize a_cto00m06      to null
             initialize ws.c24soltipcod to null
             exit display
          on key (F8)
             let arr_aux = arr_curr()
             let ws.c24soltipcod = a_cto00m06[arr_aux].c24soltipcod
             let ws.c24soltipdes = a_cto00m06[arr_aux].c24soltipdes
             exit display
       end display
       let int_flag = false
       close window cto00m00
    end if
 else
    initialize ws.c24soltipcod to null
    error " Nao foi encontrado nenhum tipo de solicitante!"
 end if

 return ws.c24soltipcod,ws.c24soltipdes

end function  ###  cto00m06

#-----------------------------------------------------------
 function cto00m06_desc(l_c24soltipcod)
#-----------------------------------------------------------

   define l_c24soltipcod   like datksoltip.c24soltipcod

   define l_c24soltipdes   like datksoltip.c24soltipdes

   initialize l_c24soltipdes to null

   case l_c24soltipcod

      when 1
         let l_c24soltipdes = "MOTORISTA"

      when 2
         let l_c24soltipdes = "POLICIA RODOVIARIA"

      when 3
        let  l_c24soltipdes = "PONTO DE APOIO"

      when 4
         let l_c24soltipdes = "SEGURADO"
   end case

   return l_c24soltipdes

end function
