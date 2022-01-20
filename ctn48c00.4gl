###############################################################################
# Nome do Modulo: CTN48C00                                            GUSTAVO #
#                                                                             #
# Consulta servicos enviados para o teletrim                          JAN/2001#
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctn48c00()
#------------------------------------------------------------

 define a_ctn48c00   array[500]   of record
        tltmvtnum    like datmtltmsglog.tltmvtnum,
        mstnum       like datmtltmsglog.mstnum,
        mststt       like datmtltmsglog.mststt,
        desc         char(22),
        atldat       like datmtltmsglog.atldat,
        atlhor       char(05),
        cadnom       like isskfunc.funnom
 end record

 define arr_aux      smallint
 define scr_aux      smallint

 define d_ctn48c00   record
        tltmvtnum    like datmtltmsglog.tltmvtnum,
        mstnum       like datmtltmsglog.mstnum,
        trxdat       date,
        mststt       like datmtltmsglog.mststt
 end record

 define ws           record
        result       char(09),
        total        char(10),
        comando      char(500),
        comando2     char(800),
        atlhor       char(08),
        atlemp       like datmtltmsglog.atlemp,
        atlmat       like datmtltmsglog.atlmat,
        atlusrtip    like datmtltmsglog.atlusrtip,
        cadnom       like isskfunc.funnom,
        count        smallint
 end record


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  500
		initialize  a_ctn48c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn48c00.*  to  null

	initialize  ws.*  to  null

 open window w_ctn48c00 at  06,02 with form "ctn48c00"
            attribute(form line first)

while true

   initialize ws.*          to null
   initialize a_ctn48c00    to null
   initialize d_ctn48c00.*  to null
   let int_flag   = false
   let arr_aux    = 1
   clear form

   input d_ctn48c00.tltmvtnum,
         d_ctn48c00.mstnum,
         d_ctn48c00.trxdat,
         d_ctn48c00.mststt
   without defaults from tltmvtnum_d,
                         mstnum_d,
                         trxdat_d,
                         mststt_d

         before field tltmvtnum_d
            display d_ctn48c00.tltmvtnum to tltmvtnum_d attribute (reverse)

         after  field tltmvtnum_d
            display d_ctn48c00.tltmvtnum to tltmvtnum_d

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field mstnum_d
            end if

            if d_ctn48c00.tltmvtnum is null then
               next field mstnum_d
            else
               select count(*)
                 into ws.count
                 from datmtltmsglog
               where tltmvtnum = d_ctn48c00.tltmvtnum

               if ws.count > 0 then
                  exit input
               else
                  error "Nro. Movimento nao existe!"
                  next field tltmvtnum_d
               end if
            end if

         before field mstnum_d
            display d_ctn48c00.mstnum to mstnum_d   attribute (reverse)

         after  field mstnum_d
            display d_ctn48c00.mstnum to mstnum_d

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               next field tltmvtnum_d
            end if

            if d_ctn48c00.mstnum is null    then
               next field trxdat_d
            else
               select count(*)
                  into ws.count
                  from datmtltmsglog
               where mstnum = d_ctn48c00.mstnum

               if ws.count > 0 then
                  exit input
               else
                  error "Nro. Mensagem nao existe!"
                  next field mstnum_d
               end if
            end if

         before field trxdat_d
            display d_ctn48c00.trxdat to trxdat_d attribute (reverse)

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               clear form
               next field mstnum_d
            end if

         after  field trxdat_d
            display d_ctn48c00.trxdat to trxdat_d

            if d_ctn48c00.trxdat is null then
               error " Informe a data da transmissao do servico!"
               next field trxdat_d
            else
               select count(*)
                  into ws.count
                  from datmtltmsglog
               where atldat = d_ctn48c00.trxdat

               if ws.count > 0 then
                  next field mststt_d
               else
                  error "Nao houve nenhum movimento referente a esta data!"
                  next field trxdat_d
               end if
            end if

         before field mststt_d
            display d_ctn48c00.mststt to mststt_d attribute (reverse)

         after  field mststt_d
            display d_ctn48c00.mststt to mststt_d

            if d_ctn48c00.mststt is null then
               exit input
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

   if d_ctn48c00.tltmvtnum is not null then
      let ws.comando = " from datmtltmsglog      ",
                       " where tltmvtnum = ?     ",
                       " order by tltmvtnum,     ",
                       "          mstnum         "
   else
      if d_ctn48c00.mstnum is not null then
         let ws.comando = " from datmtltmsglog     ",
                          " where mstnum = ?       ",
                          " order by mstnum,       ",
                          "          tltmvtnum     "
      else
        if d_ctn48c00.trxdat is not null    then
           if d_ctn48c00.mststt is not null then
              let ws.comando = " from datmtltmsglog     ",
                           " where mstnum    > 0        ",
                           " and   tltmvtnum > 0        ",
                           " and   atldat    = ?        ",
                           " and   mststt    = ?        ",
                           " order by tltmvtnum,        ",
                           "          mstnum            "
           else
              let ws.comando = " from datmtltmsglog     ",
                           " where mstnum    > 0        ",
                           " and   tltmvtnum > 0        ",
                           " and   atldat    = ?        ",
                           " order by tltmvtnum,        ",
                           "          mstnum            "
           end if
        end if
      end if
   end if

   let ws.comando2 = " select datmtltmsglog.tltmvtnum, datmtltmsglog.mstnum, ",
                     "        datmtltmsglog.mststt, datmtltmsglog.atldat,    ",
                     "        datmtltmsglog.atlhor, datmtltmsglog.atlemp,    ",
                     "        datmtltmsglog.atlmat, datmtltmsglog.atlusrtip  ",
                     ws.comando clipped

   prepare s_seleciona from ws.comando2
   declare c_ctn48c00  cursor for s_seleciona

   if d_ctn48c00.tltmvtnum is not null then
      open c_ctn48c00 using d_ctn48c00.tltmvtnum
   else
      if d_ctn48c00.mstnum is not null then
         open c_ctn48c00 using d_ctn48c00.mstnum
      else
         if d_ctn48c00.mststt is not null then
            open c_ctn48c00 using d_ctn48c00.trxdat, d_ctn48c00.mststt
         else
            open c_ctn48c00 using d_ctn48c00.trxdat
         end if
      end if
   end if

   foreach c_ctn48c00 into a_ctn48c00[arr_aux].tltmvtnum,
                           a_ctn48c00[arr_aux].mstnum,
                           a_ctn48c00[arr_aux].mststt,
                           a_ctn48c00[arr_aux].atldat,
                           ws.atlhor,
                           ws.atlemp,
                           ws.atlmat,
                           ws.atlusrtip

     case a_ctn48c00[arr_aux].mststt
       when 00 let a_ctn48c00[arr_aux].desc = "TEXTO ENVIADO"
       when 01 let a_ctn48c00[arr_aux].desc = "TRANSACAO C/ SUCESSO"
       when 02 let a_ctn48c00[arr_aux].desc = "PARAM. SUSEP INVALIDO"
       when 03 let a_ctn48c00[arr_aux].desc = "ASSUNTO INVALIDO"
       when 04 let a_ctn48c00[arr_aux].desc = "USUARIO CANCELADO"
       when 05 let a_ctn48c00[arr_aux].desc = "PAGER USUAR. CANCELADO"
       when 06 let a_ctn48c00[arr_aux].desc = "ERRO GRAV ASSUNTO"
       when 07 let a_ctn48c00[arr_aux].desc = "ERRO GRAV TEXTO"
       when 08 let a_ctn48c00[arr_aux].desc = "ERRO GRAV DESTINAT"
       when 09 let a_ctn48c00[arr_aux].desc = "ERRO GRAV HISTORICO"
       when 10 let a_ctn48c00[arr_aux].desc = "ERRO GRAV SITUACAO MSG"
     end case

     let a_ctn48c00[arr_aux].atlhor = ws.atlhor
     call ctn48c00_func(ws.atlemp, ws.atlmat)
            returning ws.cadnom
     let a_ctn48c00[arr_aux].cadnom = ws.cadnom
     let arr_aux = arr_aux + 1

     if arr_aux > 500  then
        error " Limite excedido, pesquisa com mais de 500 Mensagens!"
        exit foreach
     end if
   end foreach

   message " (F17)Abandona"
   call set_count(arr_aux-1)

   display array  a_ctn48c00 to s_ctn48c00.*

end while

let int_flag = false
close window  w_ctn48c00

end function  #  ctn48c00

#---------------------------------------------------------
 function ctn48c00_func(k_ctn48c00)
#---------------------------------------------------------

 define k_ctn48c00 record
    empcod         like isskfunc.empcod ,
    funmat         like isskfunc.funmat
 end record

 define ws         record
    funnom         like isskfunc.funnom
 end record



	initialize  ws.*  to  null

 let ws.funnom = "NAO CADASTRADO!"

 select funnom
   into ws.funnom
   from isskfunc
  where empcod = k_ctn48c00.empcod  and
        funmat = k_ctn48c00.funmat

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  ctn48c00_func

