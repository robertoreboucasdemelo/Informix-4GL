###############################################################################
# Nome do Modulo: cts12g00                                           Marcelo  #
#                                                                    Gilberto #
# Pop-up de especialidades					     Nov/2005 #
###############################################################################

database porto

#---------------------------------------------------------------
 function ctc75m00()
#---------------------------------------------------------------


 define a_ctc75m00 array[100] of record
    espcod         smallint,
    espdes         char(40)
 end record


 define arr_aux    smallint
 define scr_aux    smallint

 define sql        char (1000)

 define  w_pf1   integer

 let     arr_aux  =  null
 let     scr_aux  =  null
 let     sql  =  null

 initialize a_ctc75m00 to null

 let sql = " select espcod, espdes ",
 	"   from dbskesp",
        " where espsit = 'A'"

 prepare sel_especialidade from sql
 declare c_ctc75m00 cursor for sel_especialidade

 initialize a_ctc75m00  to null
 let arr_aux = 1

 open window w_ctc75m00 at 10,29 with form "ctc75m00"
      attribute(form line first, border)

 open    c_ctc75m00
  foreach c_ctc75m00 into a_ctc75m00[arr_aux].espcod,
                         a_ctc75m00[arr_aux].espdes
	let arr_aux = arr_aux + 1
    	if arr_aux > 100  then
       		error " Limite excedido. Foram encontradas mais de 100 especialidades!"
   		exit foreach
    	end if
  end foreach

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array a_ctc75m00 to s_ctc75m00.*
    on key (interrupt,control-c)
       initialize a_ctc75m00   to null
       exit display

   on key (F8)
      let arr_aux = arr_curr()
      exit display
 end display

 close window  w_ctc75m00
 let int_flag = false

 return a_ctc75m00[arr_aux].espcod,a_ctc75m00[arr_aux].espdes
end function

