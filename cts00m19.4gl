 #############################################################################
 # Nome do Modulo: CTS00M19                                         Marcelo  #
 #                                                                  Gilberto #
 #                                                                  Wagner   #
 # Consulta fax enviados VIDROS                                     Mar/1999 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 26/03/1999  PSI 8127-2   Wagner       Permitir re-envio de fax tambem para#
 #                                       situacao = 1-aguardando com mais de #
 #                                       15 minutos.                         #
 #############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts00m19(param)
#-----------------------------------------------------------

 define param   record
    servico         char(13)
 end record

 define a_cts00m19 array[200] of record
    faxch1          char (13)              ,
    faxenvdat       like datmfax.faxenvdat ,
    faxenvhor       like datmfax.faxenvhor ,
    faxch2          like datmfax.faxch2    ,
    faxsttdsc       char (21)              ,
    retornoflg      char (01)
 end record

 define d_cts00m19  record
    faxch1          dec  (10,0)           ,
    faxenvdat       like datmfax.faxenvdat,
    faxenvsit       like datmfax.faxenvsit,
    faxsttdsc       char (25)
 end record

 define ws          record
    succod          like datrligapol.succod   ,
    ramcod          like datrligapol.ramcod   ,
    aplnumdig       like datrligapol.aplnumdig,
    itmnumdig       like datrligapol.itmnumdig,
    faxenvsit       like datmfax.faxenvsit    ,
    tempo           char (08)                 ,
    resp            char (01)                 ,
    total           char (12)                  ,
    hatual          datetime hour to second   ,
    h24             datetime hour to second   ,
    hespera         char (09)                 ,
    confirma        char (01)                 ,
    atdsrvnum       dec  (8,0)                ,
    atdsrvano       dec  (2,0)                ,
    faxch1          char (10)
 end record

 define sql         record
    comando         char (370),
    condicao        char (100)
 end record

 define ws_privez   dec  (1,0)

 define arr_aux     smallint
 define scr_aux     smallint

	define	w_pf1	integer

	let	ws_privez  =  null
	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cts00m19[w_pf1].*  to  null
	end	for

	initialize  d_cts00m19.*  to  null

	initialize  ws.*  to  null

	initialize  sql.*  to  null

 initialize ws.*    to null

 if param.servico is null  then
    error "parametro invalido"
    return
 end if
 let ws.atdsrvnum      =  param.servico[4,10]
 let ws.atdsrvano      =  param.servico[12,13]
 let ws.faxch1          = param.servico[4,10],param.servico[12,13]
 let d_cts00m19.faxch1 = ws.faxch1

 let sql.comando = "select cpodes from iddkdominio  ",
                  " where cponom = 'faxenvsit' ",
                  "   and cpocod = ? "
 prepare p_cts00m19_001  from  sql.comando
 declare c_cts00m19_001 cursor for  p_cts00m19_001


 open window cts00m19 at 06,02 with form "cts00m19"
             attribute (form line 1)

#while true
#  let int_flag      = false
#
#  input by name d_cts00m19.faxch1,
#                d_cts00m19.faxenvdat,
#                d_cts00m19.faxenvsit   without defaults
#
#     before field faxch1
#            initialize d_cts00m19.* to null
#            display by name d_cts00m19.*
#            display by name d_cts00m19.faxch1   attribute (reverse)
#
#     after  field faxch1
#            display by name d_cts00m19.faxch1
#
#            if d_cts00m19.faxch1 is not null then
#               exit input
#            end if
#
#     before field faxenvdat
#            display by name d_cts00m19.faxenvdat   attribute (reverse)
#
#            #-------------------------------------------------------------
#            # Quando "mostrar" a tela na primeira vez deve ser data atual
#            #-------------------------------------------------------------
#            if ws_privez  is null   then
#               let ws_privez            = 0
#               let d_cts00m19.faxenvdat = today
#               display by name d_cts00m19.faxenvdat
#            end if
#
#     after  field faxenvdat
#            display by name d_cts00m19.faxenvdat
#
#            if fgl_lastkey() = fgl_keyval ("up")     or
#               fgl_lastkey() = fgl_keyval ("left")   then
#               next field  faxch1
#            end if
#
#            if d_cts00m19.faxenvdat  is null   then
#               error " Data de envio deve ser informada!"
#               next field faxenvdat
#            else
#               if d_cts00m19.faxenvdat  > today   then
#                  error " Data de envio nao deve ser maior que data atual!"
#                  next field faxenvdat
#               end if
#            end if
#
#     before field faxenvsit
#            display by name d_cts00m19.faxenvsit   attribute (reverse)
#
#     after  field faxenvsit
#            display by name d_cts00m19.faxenvsit
#
#            if fgl_lastkey() = fgl_keyval ("up")     or
#               fgl_lastkey() = fgl_keyval ("left")   then
#               next field  faxenvdat
#            end if
#
#            if d_cts00m19.faxenvsit is null then
#               let d_cts00m19.faxsttdsc = "TODOS"
#              else
#               open  c_cts00m19_001  using  d_cts00m19.faxenvsit
#               fetch c_cts00m19_001  into   d_cts00m19.faxsttdsc
#
#               if sqlca.sqlcode <> 0 then
#                  error " Situacao invalida!"
#                  next field faxenvsit
#               end if
#            end if
#           display by name d_cts00m19.faxsttdsc
#
#     on key(interrupt)
#        exit input
#
#  end input
#
#  if int_flag   then
#     exit while
#  end if

   if d_cts00m19.faxch1 is not null then
      let sql.condicao = "   and faxch1    = ? "
     else
      if d_cts00m19.faxenvsit is null then
         let sql.condicao = "   and faxenvdat = ? "
        else
         let sql.condicao = "   and faxenvsit = ? ",
                            "   and faxenvdat = ? "
      end if
   end if

   let sql.comando = "select faxch1, faxenvdat, faxenvhor, faxch2, faxenvsit ",
                    "  from datmfax  ",
                    " where faxsiscod = 'CT' ",
                    "   and faxsubcod = 'VD' ",
                        sql.condicao clipped ,
                    "  order by faxenvdat, faxenvhor "

   prepare p_cts00m19_002 from sql.comando
   declare c_cts00m19_002 cursor for p_cts00m19_002


   while true

      let int_flag = false
      initialize a_cts00m19  to null
      let arr_aux  = 1
      let ws.tempo    =  time
      let ws.hatual   =  time

     #display ws.tempo to horaatu

      message " Aguarde, pesquisando..."  attribute(reverse)

      if d_cts00m19.faxch1 is not null then
         open c_cts00m19_002  using  d_cts00m19.faxch1
        else
         if d_cts00m19.faxenvsit is null then
            open c_cts00m19_002  using  d_cts00m19.faxenvdat
           else
            open c_cts00m19_002  using  d_cts00m19.faxenvsit,
                                   d_cts00m19.faxenvdat
         end if
      end if

      foreach  c_cts00m19_002   into  ws.faxch1                     ,
                                 a_cts00m19[arr_aux].faxenvdat ,
                                 a_cts00m19[arr_aux].faxenvhor ,
                                 a_cts00m19[arr_aux].faxch2    ,
                                 ws.faxenvsit

         if ws.faxenvsit = 4  then
            continue foreach        # 4-fax c/situacao cancelada
         end if
         let ws.atdsrvnum  =  ws.faxch1[1,7]
         let ws.atdsrvano  =  ws.faxch1[8,9]

         let a_cts00m19[arr_aux].faxch1 =  "14"                   ,
                                      "/", ws.atdsrvnum using "&&&&&&&",
                                      "-", ws.atdsrvano using "&&"
         #-----------------------------------------------------------------
         # Verifica se aguardando envio > 15 minutos
         #-----------------------------------------------------------------
         let a_cts00m19[arr_aux].retornoflg = "n"

         if a_cts00m19[arr_aux].faxenvdat = today  then
            let ws.hespera = ws.hatual - a_cts00m19[arr_aux].faxenvhor
         else
            let ws.h24     = "23:59:59"
            let ws.hespera = ws.h24     - a_cts00m19[arr_aux].faxenvhor
            let ws.h24     = "00:00:00"
            let ws.hespera = ws.hespera + (ws.hatual - ws.h24 ) + "00:00:01"
         end if

         if ws.hespera[3,9] > "0:15:00"  then
            let a_cts00m19[arr_aux].retornoflg = "s"
         end if

         if g_issk.funmat = 61566 then
            display "servico-ws.faxch1   =  ",ws.faxch1
            display "Hora atual          =  ",ws.hatual
            display "hora tabela         =  ",a_cts00m19[arr_aux].faxenvhor
            display "espera              =  ",ws.hespera
         end if
         open  c_cts00m19_001  using  ws.faxenvsit
         fetch c_cts00m19_001  into   a_cts00m19[arr_aux].faxsttdsc

         let arr_aux = arr_aux + 1
         if arr_aux > 200 then
            error " Limite excedido. Pesquisa com mais de 200 transmissoes!"
            exit foreach
         end if

      end foreach

      if arr_aux  = 1   then
         error  " Nao existem faxes para pesquisa!"
      end if

      message " (F17)Abandona, (F6)Nova consulta, (F8)Seleciona, (F9)Cancela"

     #let ws.total = "Vidros: ", arr_aux - 1  using "&&&"
     #display by name ws.total  attribute (reverse)

      call set_count(arr_aux-1)

      display array  a_cts00m19 to s_cts00m19.*

        on key(interrupt)
           let int_flag = true
           exit display

        on key(F6)
           exit display

        on key(F8)
           let arr_aux = arr_curr()
           if a_cts00m19[arr_aux].retornoflg = "s"   then
              let g_documento.atdsrvnum = ws.atdsrvnum
              let g_documento.atdsrvano = ws.atdsrvano
              call cts19m06()
            else
              error " Fax aguardando transmissao !"
           end if

        on key (F9)    ##--- Cancelamento de envio ---
           let arr_aux = arr_curr()
           let scr_aux = scr_line()

           call cts08g01("A","S","","CONFIRMA O CANCELAMENTO","DO ENVIO ?","")
                returning ws.confirma

           if ws.confirma  =  "S"   then
              call cts10g01_sit_fax( 4,
                                     "VD",
                                     a_cts00m19[arr_aux].faxch1,
                                     a_cts00m19[arr_aux].faxch2)
              exit display
           end if

      end display

     #display " "  to  total

      for scr_aux = 1 to 11
          clear s_cts00m19[scr_aux].*
      end for

      if int_flag then
         exit while
      end if

   end while

#end while

 let int_flag = false
 close window cts00m19

end function  #  cts00m19

