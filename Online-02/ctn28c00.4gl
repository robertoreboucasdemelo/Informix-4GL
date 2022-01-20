###############################################################################
# Nome do Modulo: CTN28C00                                           Marcelo  #
#                                                                    Gilberto #
# Consulta servicos enviados p/ impressoras remotas                  Set/1996 #
###############################################################################
# 07/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo         #
#                                       atdsrvnum de 6 p/ 10.                 #
#                                       Troca do campo atdtip p/ atdsrvorg.   #
###############################################################################
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctn28c00()
#------------------------------------------------------------

 define a_ctn28c00   array[500]   of record
    atdtrxnum        like datmtrxfila.atdtrxnum,
    situacao         char(30)                  ,
    atdtrxdat        char(05)                  ,
    atdtrxhor        like datmtrxfila.atdtrxhor,
    atdtrxsit        like datmtrxfila.atdtrxsit,
    espera           datetime minute to second ,
    servico          char(13)
 end record

 define arr_aux      smallint
 define scr_aux      smallint

 define d_ctn28c00    record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    trxdat            date                      ,
    atdtrxsit         like datmtrxfila.atdtrxsit
 end record

 define hora          record
    atual             datetime hour to second ,
    result            char (09)
 end record

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atdsrvorg         like datmservico.atdsrvorg,
    atdtrxdat         char(10),
    total             char(10)
 end record

 define sql_comando   char(800)
 define sql_condition char(500)



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	sql_comando  =  null
	let	sql_condition  =  null

	for	w_pf1  =  1  to  500
		initialize  a_ctn28c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn28c00.*  to  null

	initialize  hora.*  to  null

	initialize  ws.*  to  null

open window w_ctn28c00 at  06,02 with form "ctn28c00"
            attribute(form line first)

while true

   initialize ws.*          to null
   initialize hora.*        to null
   initialize a_ctn28c00    to null
   let int_flag   = false
   let arr_aux    = 1
   let hora.atual = current

   input by name d_ctn28c00.*

      before field atdsrvnum
         display by name d_ctn28c00.atdsrvnum  attribute (reverse)

      after  field atdsrvnum
         display by name d_ctn28c00.atdsrvnum

         if d_ctn28c00.atdsrvnum is null    then
            next field trxdat
         end if

      before field atdsrvano
         display by name d_ctn28c00.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name d_ctn28c00.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if d_ctn28c00.atdsrvano   is null      and
            d_ctn28c00.atdsrvnum   is not null  then
            error " Informe o ano do servico!"
            next field atdsrvano
         end if

         if d_ctn28c00.atdsrvano   is not null   and
            d_ctn28c00.atdsrvnum   is null       then
            error " Informe o numero do servico!"
            next field atdsrvnum
         end if

         initialize ws.atdsrvorg  to null
         select atdsrvorg
           into ws.atdsrvorg
           from datmservico
          where atdsrvnum = d_ctn28c00.atdsrvnum    and
                atdsrvano = d_ctn28c00.atdsrvano

         if sqlca.sqlcode = notfound   then
            error " Servico nao cadastrado !"
            next field atdsrvano
         end if

         if ws.atdsrvorg <>  4    and     #-> Remocao
            ws.atdsrvorg <>  6    and     #-> Daf
            ws.atdsrvorg <>  1    and     #-> Socorro
            ws.atdsrvorg <> 10    and     #-> Vistoria Previa
            ws.atdsrvorg <>  5    and     #-> Rpt
            ws.atdsrvorg <>  7    and     #-> Replace
            ws.atdsrvorg <> 17    then    #-> Replace s/ docto
           error "Transmissao p/ servicos de: Remocao, DAF, Socorro, VP, RPT ou Replace!"
            next field atdsrvano
         end if

         if d_ctn28c00.atdsrvnum  is not null   and
            d_ctn28c00.atdsrvano  is not null   then
            exit input
         end if

      before field trxdat
         display by name d_ctn28c00.trxdat    attribute (reverse)

         let d_ctn28c00.trxdat = today

      after  field trxdat
         display by name d_ctn28c00.trxdat

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if d_ctn28c00.trxdat  is null   then
            error " Informe a data da transmissao do servico!"
            next field trxdat
         end if

      before field atdtrxsit
         display by name d_ctn28c00.atdtrxsit attribute (reverse)

      after  field atdtrxsit
         display by name d_ctn28c00.atdtrxsit

         if d_ctn28c00.atdtrxsit  is not null   then
            if d_ctn28c00.atdtrxsit  >= 0       and
               d_ctn28c00.atdtrxsit  <= 5       then
               exit input
            else
               error "Codigo de situacao invalida !"
               call ctn28c02() returning d_ctn28c00.atdtrxsit
               next field atdtrxsit
            end if
         end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   #-------------------------------------------
   # Consulta transmissoes conforme parametro
   #-------------------------------------------
   message " Aguarde, pesquisando..."  attribute(reverse)

   if d_ctn28c00.atdsrvnum  is not null   then
      let sql_condition = " from datmtrxfila    ",
                          " where atdsrvnum = ? ",
                          "   and atdsrvano = ? ",
                          " order by atdtrxdat, ",
                          "          atdtrxhor  "
   else
      if d_ctn28c00.trxdat is not null then
         if d_ctn28c00.atdtrxsit is not null then
            let sql_condition = " from datmtrxfila     ",
                                " where atdtrxnum  > 0 ",
                                "   and atdtrxdat  = ? ",
                                "   and atdtrxsit  = ? ",
                                " order by atdtrxdat , ",
                                "          atdtrxhor   "
         else
            let sql_condition = " from datmtrxfila     ",
                                " where atdtrxnum  > 0 ",
                                "   and atdtrxdat  = ? ",
                                " order by atdtrxdat , ",
                                "          atdtrxhor   "
         end if
      end if
   end if

  let sql_comando = " select datmtrxfila.atdtrxnum, datmtrxfila.atdtrxsit, " ,
                    "        datmtrxfila.atdtrxdat, datmtrxfila.atdtrxhor, " ,
                    "        datmtrxfila.atdsrvnum, datmtrxfila.atdsrvano  " ,
                    sql_condition clipped

  prepare sql_select from sql_comando
  declare c_ctn28c00 cursor for sql_select

  if d_ctn28c00.atdsrvnum  is not null   then
     open c_ctn28c00  using d_ctn28c00.atdsrvnum, d_ctn28c00.atdsrvano
  else
     if d_ctn28c00.atdtrxsit  is not null   then
        open c_ctn28c00  using d_ctn28c00.trxdat, d_ctn28c00.atdtrxsit
     else
        open c_ctn28c00  using d_ctn28c00.trxdat
     end if
   end if

   foreach  c_ctn28c00  into  a_ctn28c00[arr_aux].atdtrxnum ,
                              a_ctn28c00[arr_aux].atdtrxsit ,
                              ws.atdtrxdat                  ,
                              a_ctn28c00[arr_aux].atdtrxhor ,
                              ws.atdsrvnum                  ,
                              ws.atdsrvano
      select atdsrvorg
        into ws.atdsrvorg
        from datmservico
             where atdsrvnum = ws.atdsrvnum
               and atdsrvano = ws.atdsrvano

      let a_ctn28c00[arr_aux].servico =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                                    "/", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                                    "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)

      select cpodes into a_ctn28c00[arr_aux].situacao
        from iddkdominio
       where cponom = "atdtrxsit" and
             cpocod = a_ctn28c00[arr_aux].atdtrxsit

      let a_ctn28c00[arr_aux].atdtrxdat = ws.atdtrxdat[1,5]

      if a_ctn28c00[arr_aux].atdtrxsit = 1  or
         a_ctn28c00[arr_aux].atdtrxsit = 2  then
         let hora.result = hora.atual - a_ctn28c00[arr_aux].atdtrxhor
         let a_ctn28c00[arr_aux].espera = hora.result[5,9]
      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 500  then
         error " Limite excedido, pesquisa com mais de 500 transmissoes!"
         exit foreach
      end if

   end foreach

   if arr_aux  >  1   then
      let ws.total = "Total: ", arr_aux - 1 using "&&&"
      display by name ws.total  attribute (reverse)

      message " (F17)Abandona, (F8)Consulta Log"
      call set_count(arr_aux-1)

      display array  a_ctn28c00 to s_ctn28c00.*
         on key (interrupt)
            exit display

         on key (F8)    ##--- Consulta log das transmissoes ---
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            call ctn28c01(a_ctn28c00[arr_aux].atdtrxnum)
      end display

      display " "  to  total

      for scr_aux = 1 to 11
         clear s_ctn28c00[scr_aux].*
      end for
   else
      error " Nao existem transmissoes para pesquisa!"
   end if

end while

let int_flag = false
close window  w_ctn28c00

end function  #  ctn28c00
