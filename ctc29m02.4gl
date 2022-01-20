###############################################################################
# Nome do Modulo: CTC29M02                                           Marcelo  #
#                                                                    Gilberto #
# Consulta aos relatorios solicitados                                Mai/1996 #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctc29m02()
#-----------------------------------------------------------

   define a_ctc29m02 array[30] of record
          relsgl     like dgbkrel.relsgl      ,
          reldes     like dgbkrel.reldes      ,
          relpamseq  like dgbmparam.relpamseq ,
          ultsoldat  date                     ,
          ultsolhor  char (08)                ,
          funmat     like isskfunc.funmat     ,
          funnom     like isskfunc.funnom
   end    record

   define aux        record
          retorno    smallint  ,
          relpamtxt  like dgbmparam.relpamtxt
   end record

   define arr_aux    smallint

   open window ctc29m02 at 06,02 with form "ctc29m02"
        attribute(form line 1)

   let int_flag = false
   initialize  a_ctc29m02   to null
   initialize  aux.*        to null

   declare c_ctc29m02    cursor for
     select relsgl, relpamseq, relpamtxt
       from dgbmparam
      where relsgl <> "ESTAPAR"  and
            relpamtip = 1
      order by relpamseq

   let arr_aux  = 1

   foreach c_ctc29m02 into a_ctc29m02[arr_aux].relsgl   ,
                           a_ctc29m02[arr_aux].relpamseq,
                           aux.relpamtxt

      let a_ctc29m02[arr_aux].ultsoldat = aux.relpamtxt[01,10]
      let a_ctc29m02[arr_aux].ultsolhor = aux.relpamtxt[11,18]
      let a_ctc29m02[arr_aux].funmat    = aux.relpamtxt[19,26]

      select reldes into a_ctc29m02[arr_aux].reldes
        from dgbkrel
       where relsgl = a_ctc29m02[arr_aux].relsgl

      select funnom into a_ctc29m02[arr_aux].funnom
        from isskfunc
       where funmat = a_ctc29m02[arr_aux].funmat

      let arr_aux = arr_aux + 1
      if arr_aux  >  30   then
         error "Limite excedido, foram solicitados mais de 30 relatorios!"
         exit foreach
      end if

   end foreach

   message " (F17)Abandona"
   call set_count(arr_aux-1)

   display array a_ctc29m02 to s_ctc29m02.*

      on key (interrupt,control-c)
         initialize a_ctc29m02   to null
         exit display

   end display

   close window  ctc29m02
   let int_flag = false

end function  #  ctc29m02
