###############################################################################
# Nome do Modulo: CTB11M02                                           Marcelo  #
#                                                                    Gilberto #
# Consulta fases da ordem de pagamento                               Dez/1996 #
#----------------------------------------------------------------------------# 
# 18/07/06   Junior, Meta  AS112372      Migracao de versao do 4gl.          # 
#----------------------------------------------------------------------------# 
database porto

#-----------------------------------------------------------
 function ctb11m02(param)
#-----------------------------------------------------------

 define param       record
    socopgnum       like dbsmopgfas.socopgnum
 end record

 define a_ctb11m02 array[20] of record
    socopgfasdes    char(30),
    socopgfasdat    like dbsmopgfas.socopgfasdat,
    socopgfashor    like dbsmopgfas.socopgfashor,
    funnom          like isskfunc.funnom
 end record

 define ws          record
    funmat          like isskfunc.funmat,
    socopgfascod    like dbsmopgfas.socopgfascod
 end    record

 define sql         record
    comando         char(350),
    condition       char(250)
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 let sql.comando = "select funnom    ",
                  "  from isskfunc ",
                  " where funmat = ?  "
 prepare comando_aux1  from  sql.comando 
 declare c_aux1        cursor for  comando_aux1

 let sql.comando  = "select cpodes    ",
                  "  from iddkdominio ",
                  " where cponom = 'socopgfascod' and ",
                  "       cpocod = ? "
 prepare comando_aux2  from  sql.comando 
 declare c_aux2        cursor for  comando_aux2

 initialize a_ctb11m02     to null
 initialize ws.*           to null
 let arr_aux = 1


 open window ctb11m02 at 08,02 with form "ctb11m02"
             attribute (form line first)


 declare  c_ctb11m02  cursor for
   select socopgfascod, socopgfasdat, socopgfashor, funmat
     from dbsmopgfas
    where dbsmopgfas.socopgnum = param.socopgnum

 foreach  c_ctb11m02  into  ws.socopgfascod,
                            a_ctb11m02[arr_aux].socopgfasdat,
                            a_ctb11m02[arr_aux].socopgfashor,
                            ws.funmat

      initialize  a_ctb11m02[arr_aux].funnom         to null
      open  c_aux1  using  ws.funmat
      fetch c_aux1  into   a_ctb11m02[arr_aux].funnom

      initialize  a_ctb11m02[arr_aux].socopgfasdes   to null
      open  c_aux2  using  ws.socopgfascod
      fetch c_aux2  into   a_ctb11m02[arr_aux].socopgfasdes

      let arr_aux = arr_aux + 1
      if arr_aux > 20   then
         error "Limite excedido. Ordem de pagamento com mais de 10 fases!"
         exit foreach
      end if
 end foreach

 if arr_aux  > 1   then
      message " (F17)Abandona"
      call set_count(arr_aux-1)

      display array  a_ctb11m02 to s_ctb11m02.*
        on key(interrupt)
           exit display
      end display
   else
      error "Nao existem fases cadastradas para Ordem de pagamento!"
   end if

let int_flag = false
close c_ctb11m02
close window ctb11m02

end function  #  ctb11m02
