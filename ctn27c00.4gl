#############################################################################
# Nome do Modulo: CTN27C00                                         Marcelo  #
#                                                                  Gilberto #
# Consulta servicos enviados por fax                               Set/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 27/10/1998  PSI 6966-3   Gilberto     Incluir novo codigo de status do    #
#                                       servidor VSI-Fax.                   #
#############################################################################

database porto

#-----------------------------------------------------------
 function ctn27c00()
#-----------------------------------------------------------

 define d_ctn27c00  record
    faxsiscod       like gfxmfax.faxsiscod    ,
    faxsisdsc       char (20)                 ,
    faxsubcod       like gfxmfax.faxsubcod    ,
    faxsubdsc       char (11)                 ,
    faxenvdat       like datmfax.faxenvdat    ,
    faxsttcod       like gfxmfax.faxsttcod    ,
    faxsttdsc       char (16)                 ,
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    total           char(12)
 end record

 define a_ctn27c00 array[200] of record
    faxsubdes       char (11)              ,
    faxch1          like datmfax.faxch1    ,
    faxch2          like datmfax.faxch2    ,
    faxenvhor       like datmfax.faxenvhor ,
    faxsttdsc       char (16)              ,
    faxsubsis       like datmfax.faxsubcod ,
    retornoflg      char(01)
 end record

 define aux         record
    faxsubcod       like gfxmfax.faxsubcod    ,
    faxchd          like datmfax.faxch1       ,
    faxchx          char(10)                  ,
    faxsttcod       like gfxmfax.faxsttcod
 end    record

 define sql         record
    comando         char(350),
    condition       char(250)
 end record

 define arr_aux     smallint
 define scr_aux     smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_ctn27c00[w_pf1].*  to  null
	end	for

	initialize  d_ctn27c00.*  to  null

	initialize  aux.*  to  null

	initialize  sql.*  to  null

 initialize d_ctn27c00.*    to null
 let sql.comando = "select faxsttcod ",
                  "  from gfxmfax ",
                  " where faxsiscod = ?  ",
                  "   and faxsubcod = ?  ",
                  "   and faxch1    = ?  ",
                  "   and faxch2    = ?  "
 prepare comando_aux1  from  sql.comando
 declare c_aux1        cursor for  comando_aux1


 open window ctn27c00 at 06,02 with form "ctn27c00"
             attribute (form line first)

 let d_ctn27c00.faxsiscod = "CT"
 let d_ctn27c00.faxsisdsc = "CENTRAL 24 HORAS"

 while true

   let int_flag = false
   initialize aux.*       to null
   initialize a_ctn27c00  to null
   let arr_aux  = 1

   input by name d_ctn27c00.faxsubcod thru d_ctn27c00.atdsrvano
                 without defaults

      before field faxsubcod
             display by name d_ctn27c00.faxsisdsc
             display by name d_ctn27c00.faxsubcod attribute (reverse)

      after  field faxsubcod
             display by name d_ctn27c00.faxsubcod

             if d_ctn27c00.faxsubcod is not null then
                case d_ctn27c00.faxsubcod
                     when "RC"
                       let d_ctn27c00.faxsubdsc = "RECLAMACAO"
                     when "RS"
                       let d_ctn27c00.faxsubdsc = "RESERVA"
                     when "FU"
                       let d_ctn27c00.faxsubdsc = "FURTO"
                     when "AL"
                       let d_ctn27c00.faxsubdsc = "ALARME"
                     when "PS"
                       let d_ctn27c00.faxsubdsc = "P.SOCORRO"
                     when "VD"
                       let d_ctn27c00.faxsubdsc = "VIDROS"
                     otherwise
                       error " Sub-sistema invalido!"
                       next field faxsubcod
                end case
             else
                let d_ctn27c00.faxsubdsc = "TODOS"
             end if
             display by name d_ctn27c00.faxsubdsc

      before field faxenvdat
             display by name d_ctn27c00.faxenvdat attribute (reverse)

      after  field faxenvdat
             if d_ctn27c00.faxenvdat  is null   then
                let d_ctn27c00.faxenvdat = today
             end if

             if d_ctn27c00.faxenvdat  > today   then
                error " Data de envio nao deve ser maior que data atual !"
                next field  faxenvdat
             end if

             display by name d_ctn27c00.faxenvdat

      before field faxsttcod
             let d_ctn27c00.faxsttcod = 0
             display by name d_ctn27c00.faxsttcod attribute (reverse)

      after  field faxsttcod
             display by name d_ctn27c00.faxsttcod

             if d_ctn27c00.faxsttcod is null then
                let d_ctn27c00.faxsttdsc = "TODOS"
             else
                if d_ctn27c00.faxsttcod = 0 then
                   let d_ctn27c00.faxsttdsc = "NAO TRANSMITIDOS"
                else
                   if d_ctn27c00.faxsttcod = 1 then
                      let d_ctn27c00.faxsttdsc = "TRANSMITIDOS"
                   else
                      error " Situacao invalida!"
                      next field faxsttcod
                   end if
                end if
             end if

             display by name d_ctn27c00.faxsttdsc

      before field atdsrvnum
             display by name d_ctn27c00.atdsrvnum attribute (reverse)

      after  field atdsrvnum
             if fgl_lastkey() <> fgl_keyval("up")   and
                fgl_lastkey() <> fgl_keyval("left") then
                display by name d_ctn27c00.atdsrvnum

                if d_ctn27c00.atdsrvnum   is null   then
                   initialize d_ctn27c00.atdsrvano   to null
                   display by name d_ctn27c00.atdsrvano
                   exit input
                end if
             else
                display by name d_ctn27c00.atdsrvnum
                next field faxsttcod
             end if

      before field atdsrvano
             display by name d_ctn27c00.atdsrvano attribute (reverse)

      after  field atdsrvano
             display by name d_ctn27c00.atdsrvano

             if fgl_lastkey() <> fgl_keyval("up")   and
                fgl_lastkey() <> fgl_keyval("left") then

                if d_ctn27c00.atdsrvnum is not null and
                   d_ctn27c00.atdsrvano is null     then
                   error " Ano do Servico e' obrigatorio!"
                   next field atdsrvano
                end if
                let aux.faxchx  = d_ctn27c00.atdsrvnum  using "&&&&&&&&",
                                  d_ctn27c00.atdsrvano  using "&&"
                let aux.faxchd  = aux.faxchx

             else
                next field atdsrvnum
             end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   if d_ctn27c00.atdsrvnum is not null   then
      let sql.condition = "  from datmfax    ",
                          " where faxsiscod = ? ",
                          "   and faxch1    = ? ",
                          "   and faxenvdat = ? ",
                          " order by faxenvhor  "
   else
      if d_ctn27c00.faxsubcod is null then
         let sql.condition = "  from datmfax         ",
                             " where faxenvdat  =  ? ",
                             "   and faxsiscod  =  ? ",
                             " order by faxsubcod,   ",
                             "          faxenvhor    "
      else
         let sql.condition = "  from datmfax         ",
                             " where faxsiscod  =  ? ",
                             "   and faxsubcod  =  ? ",
                             "   and faxenvdat  =  ? ",
                             " order by faxsubcod,   ",
                             "          faxenvhor    "
      end if
   end if

   let sql.comando= "select faxsubcod, ",
                   "       faxch1   , ",
                   "       faxch2   , ",
                   "       faxenvhor  ",
                   sql.condition  clipped

   message " Aguarde, pesquisando..."  attribute(reverse)
   prepare comando_sql from sql.comando
   declare c_ctn27c00 cursor for comando_sql

   if d_ctn27c00.atdsrvnum  is not null   then
      open c_ctn27c00  using  d_ctn27c00.faxsiscod,
                              aux.faxchd          ,
                              d_ctn27c00.faxenvdat
   else
      if d_ctn27c00.faxsubcod is null then
         open c_ctn27c00  using  d_ctn27c00.faxenvdat,
                                 d_ctn27c00.faxsiscod
      else
         open c_ctn27c00  using  d_ctn27c00.faxsiscod,
                                 d_ctn27c00.faxsubcod,
                                 d_ctn27c00.faxenvdat
      end if
   end if

   foreach  c_ctn27c00  into  a_ctn27c00[arr_aux].faxsubsis ,
                              a_ctn27c00[arr_aux].faxch1    ,
                              a_ctn27c00[arr_aux].faxch2    ,
                              a_ctn27c00[arr_aux].faxenvhor

      initialize  aux.faxsttcod  to null
      let a_ctn27c00[arr_aux].retornoflg = "n"

      open  c_aux1  using  d_ctn27c00.faxsiscod          ,
                           a_ctn27c00[arr_aux].faxsubsis ,
                           a_ctn27c00[arr_aux].faxch1    ,
                           a_ctn27c00[arr_aux].faxch2

      fetch c_aux1  into   aux.faxsttcod

      if sqlca.sqlcode = NOTFOUND   then
         let a_ctn27c00[arr_aux].faxsttdsc = "EM TRANSMISSAO"
      else
         if sqlca.sqlcode <> 0      then
            error " Erro (", sqlca.sqlcode, ") na leitura do retorno do fax !"
            let a_ctn27c00[arr_aux].faxsttdsc = "N/PREVI."
         else
            let a_ctn27c00[arr_aux].retornoflg = "s"
            if aux.faxsttcod = 0     or    ### Transmissao OK (GS-Fax)
               aux.faxsttcod = 5000  then  ### Transmissao OK (VSI-Fax)
               let a_ctn27c00[arr_aux].faxsttdsc = "TRANSMITIDO"
            else
               let a_ctn27c00[arr_aux].faxsttdsc = "NAO TRANSMITIDO"
            end if
         end if
      end if

      if d_ctn27c00.atdsrvnum is null  then
         if d_ctn27c00.faxsttcod = 0   then  ### Consulta transmissoes pendentes
            if aux.faxsttcod  =  0     or    ### Despreza transmissoes OK
               aux.faxsttcod  =  5000  then  ### GS-Fax e VSI-Fax
               continue foreach
            end if
         end if
         if d_ctn27c00.faxsttcod = 1  then  ### Consulta transmissoes OK
            if (aux.faxsttcod <> 0     and  ### Despreza transmissoes pendentes
                aux.faxsttcod <> 5000) or   ### GS-Fax e VSI-Fax
                aux.faxsttcod is null  then ### Despreza em transmissao
                continue foreach
            end if
         end if
      end if

      case a_ctn27c00[arr_aux].faxsubsis
         when "RC" let a_ctn27c00[arr_aux].faxsubdes = "RECLAMACAO"
         when "RS" let a_ctn27c00[arr_aux].faxsubdes = "RESERVA"
         when "FU" let a_ctn27c00[arr_aux].faxsubdes = "FURTO/ROUBO"
         when "AL" let a_ctn27c00[arr_aux].faxsubdes = "ALARME"
         when "PS" let a_ctn27c00[arr_aux].faxsubdes = "P.SOCORRO"
         when "VD" let a_ctn27c00[arr_aux].faxsubdes = "VIDROS"
         otherwise let a_ctn27c00[arr_aux].faxsubdes = "NAO PREVISTO"
      end case

      let arr_aux = arr_aux + 1
      if arr_aux > 200 then
         error " Limite excedido. Pesquisa com mais de 200 transmissoes!"
         exit foreach
      end if
   end foreach

   if arr_aux  > 1   then
      message " (F17)Abandona, (F8)Seleciona"

      let d_ctn27c00.total = "Total: ", arr_aux - 1  using "&&&"
      display by name d_ctn27c00.total  attribute(reverse)

      call set_count(arr_aux-1)

      display array  a_ctn27c00 to s_ctn27c00.*

        on key(interrupt)
           exit display

        on key(F8)
           let arr_aux = arr_curr()
           if a_ctn27c00[arr_aux].retornoflg = "s"   then
              call ctn27c01(d_ctn27c00.faxsiscod         ,
                            a_ctn27c00[arr_aux].faxsubsis,
                            a_ctn27c00[arr_aux].faxch1   ,
                            a_ctn27c00[arr_aux].faxch2   ,
                            d_ctn27c00.faxenvdat         ,
                            a_ctn27c00[arr_aux].faxenvhor )
           else
              error " Fax aguardando transmissao !"
           end if

      end display

      display " "  to  total

      for scr_aux=1 to 9
          clear s_ctn27c00[scr_aux].*
      end for
   else
      error " Nao existem faxes para pesquisa!"
   end if

end while

let int_flag = false
close window ctn27c00

end function  #  ctn27c00
