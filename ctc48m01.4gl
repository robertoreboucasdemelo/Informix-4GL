###############################################################################
# Nome do Modulo: ctc48m01                                           Raji     #
#                                                                             #
# Mostra o cadastro de problemas por agrupamento                     Dez/2000 #
#-----------------------------------------------------------------------------#
# 18/09/2008  Nilo    PSI  221635   Agendamento de Servicos a Residencia      #
#                                   Portal do Segurado                        #
# 10/09/2012 Fornax-Hamilton PSI-2012-16039/EV Restricao de Problemas para    #
#                            servico S40 clausulas 044 44R 048 48R            #
###############################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"
database porto

#-----------------------------------------------------------
 function ctc48m01(ws_codagrup,ws_pgm)
#-----------------------------------------------------------

 define ws_codagrup  like datkpbm.c24pbmgrpcod
 define ws_pgm       char (08)

 define a_ctc48m01 array[200] of record
        c24pbmcod   like datkpbm.c24pbmcod,
        c24pbmdes   like datkpbm.c24pbmdes
 end record

 define arr_aux    smallint

 ---> PSI - 221635
 define l_cod_erro   smallint
       ,l_desc_erro  char(40)


	define	w_pf1	integer

	let	arr_aux  =  null

        ---> PSI - 221635
        let l_cod_erro   = null
        let l_desc_erro  = null

	for	w_pf1  =  1  to  200
		initialize  a_ctc48m01[w_pf1].*  to  null
	end	for

 if ws_codagrup = 999 then  # NAO ABRE POP-UP PARA GRUPO 999
   return 999,
          ""
 end if

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------
   initialize a_ctc48m01,
              arr_aux     to null

 let arr_aux = 1

 ---> PSI - 221635
 call ctc48m04(ws_codagrup,ws_pgm)
    returning l_cod_erro ,l_desc_erro

 if l_cod_erro <> 0 then
    error l_desc_erro
    return a_ctc48m01[arr_aux].c24pbmcod,
           a_ctc48m01[arr_aux].c24pbmdes
 end if

 open window ctc48m01 at 3,24 with form "ctc48m01"
                     attribute(form line 1, border)

 let int_flag = false
 initialize a_ctc48m01  to null

 declare c_ctc48m01 cursor for
    select c24pbmcod,c24pbmdes
      from ctc48m04_problema
     order by c24pbmdes

 foreach c_ctc48m01  into  a_ctc48m01[arr_aux].c24pbmcod,
                           a_ctc48m01[arr_aux].c24pbmdes
       let arr_aux = arr_aux + 1
 end foreach

 ##################################################
 # Adiciona o codigo 999 OUTROS no final da lista
 ##################################################
 #let a_ctc48m01[arr_aux].c24pbmcod = 999
 #let a_ctc48m01[arr_aux].c24pbmdes = "OUTROS"
 #let arr_aux = arr_aux + 1

 message "(F17)Abandona  (F8)Seleciona  (F3)Proximo  (F4)Anterior"
 call set_count(arr_aux - 1)

 display array a_ctc48m01 to s_ctc48m01.*

    on key (interrupt,control-c)
       initialize a_ctc48m01   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

   end display

   let int_flag = false

   close window  ctc48m01

   #if a_ctc48m01[arr_aux].c24pbmcod = 999 then
   #   let a_ctc48m01[arr_aux].c24pbmdes = ""
   #end if
   #
   return a_ctc48m01[arr_aux].c24pbmcod,
          a_ctc48m01[arr_aux].c24pbmdes

end function  ###  ctc48m01
