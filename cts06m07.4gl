#############################################################################
# Nome do Modulo: CTS06M07                                         Marcelo  #
#                                                                  Gilberto #
# Mostra regioes do Roteiro de Vistoria Previa                     Mai/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 31/03/1999  PSI 5591-3   Gilberto     Alteracao do retorno da popup, pas- #
#                                       sando a retorno o codigo da regiao  #
#                                       ao inves da descricao.              #
#############################################################################

database porto

#---------------------------------------------------------------
 function cts06m07(param)
#---------------------------------------------------------------

 define param          record
    vstatdtip          like avckreg.vstatdtip
 end record

 define a_cts06m07     array[70] of record
    vstregsgl          like avckreg.vstregsgl,
    vstregcod          like avckreg.vstregcod
 end record

 define arr_aux        smallint


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  70
		initialize  a_cts06m07[w_pf1].*  to  null
	end	for

 initialize a_cts06m07  to null

 open window w_cts06m07 at 12,49 with form "cts06m07"
                        attribute(form line first, border)

 message " Aguarde, pesquisando..." attribute (reverse)

 declare c_cts06m07_001 cursor for
    select vstregsgl, vstregcod
      from avckreg
     where vstatdtip >= param.vstatdtip
     order by vstregsgl

 let arr_aux = 1

 foreach c_cts06m07_001 into a_cts06m07[arr_aux].*
    let arr_aux = arr_aux + 1
    if arr_aux > 70 then
       error " Limite excedido! Foram encontradas mais de 70 regioes!"
       exit foreach
    end if
 end foreach

 message "(F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_cts06m07 to s_cts06m07.*
    on key (interrupt,control-c)
       initialize a_cts06m07   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display
 end display

 close window  w_cts06m07
 let int_flag = false

 return a_cts06m07[arr_aux].vstregcod

end function  ###  cts06m07
