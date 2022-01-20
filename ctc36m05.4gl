###############################################################################
# Nome do Modulo: CTC36M05                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Consulta fases da vistoria                                         Dez/1998 #
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- --------  -----------------------------------------#
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.               #
#-----------------------------------------------------------------------------#

database porto

#-----------------------------------------------------------
 function ctc36m05(param)
#-----------------------------------------------------------

 define param       record
    socvstnum       like datmvstfas.socvstnum
 end record

 define a_ctc36m05  array[10] of record
    descfas         char(30),
    caddat          like datmvstfas.caddat,
    cadhor          like datmvstfas.cadhor,
    funnom          like isskfunc.funnom
 end record

 define ws          record
    funmat          like isskfunc.funmat,
    socvstfasnum    like datmvstfas.socvstfasnum
 end record

 define sql         record
    prep            char(350),
    condition       char(250)
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 let sql.prep = "select funnom    ",
                  "  from isskfunc ",
                  " where funmat = ?  "
 prepare comando_aux1  from  sql.prep
 declare c_aux1        cursor for  comando_aux1

 let sql.prep = "select cpodes    ",
                  "  from iddkdominio ",
                  " where cponom = 'socvstfasnum' and ",
                  "       cpocod = ? "
 prepare comando_aux2  from  sql.prep
 declare c_aux2        cursor for  comando_aux2

 initialize a_ctc36m05     to null
 initialize ws.*           to null
 let arr_aux = 1


 open window ctc36m05 at 08,02 with form "ctc36m05"
             attribute (form line first)


 declare  c_ctc36m05  cursor for
   select socvstfasnum, caddat, cadhor, cadmat
     from datmvstfas
    where datmvstfas.socvstnum = param.socvstnum

 foreach  c_ctc36m05  into  ws.socvstfasnum,
                            a_ctc36m05[arr_aux].caddat,
                            a_ctc36m05[arr_aux].cadhor,
                            ws.funmat

      initialize  a_ctc36m05[arr_aux].funnom         to null
      open  c_aux1  using  ws.funmat
      fetch c_aux1  into   a_ctc36m05[arr_aux].funnom

      initialize  a_ctc36m05[arr_aux].descfas   to null
      select cpodes
        into a_ctc36m05[arr_aux].descfas
        from iddkdominio
       where cponom = "socvstfasnum"
         and cpocod = ws.socvstfasnum

      if sqlca.sqlcode <> 0 then
         let a_ctc36m05[arr_aux].descfas = "ERRO !!!  "
      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 10   then
         error "Limite excedido. Vistoria com mais de 10 fases!"
         exit foreach
      end if
 end foreach

 if arr_aux  > 1   then
      message " (F17)Abandona"
      call set_count(arr_aux-1)

      display array  a_ctc36m05 to s_ctc36m05.*
        on key(interrupt)
           exit display
      end display
   else
      error "Nao existem fases cadastradas para Vistoria!"
   end if

let int_flag = false
close c_ctc36m05
close window ctc36m05

end function  #  ctc36m05
