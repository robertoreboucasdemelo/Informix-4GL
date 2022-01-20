############################################################################
# Menu de Modulo: CTP01M04                                        Marcelo  #
#                                                                 Gilberto #
# Implementacao de Dados no Historico da Pesquisa                 Mar/1995 #
############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
function ctp01m04(k_ctp01m04)
#----------------------------------------------------------------
#
   define k_ctp01m04 record
      atdsrvnum like datmpesqhist.atdsrvnum ,
      atdsrvano like datmpesqhist.atdsrvano ,
      funmat    like datmpesqhist.c24funmat ,
      data      like datmservico.atddat     ,
      hora      like datmservico.atdhor
   end record

   define a_ctp01m04 array[200] of record
      c24psqdsc like datmpesqhist.c24psqdsc
   end record

   define ws    record
      ligdat    like datmservico.atddat     ,
      lighor    like datmservico.atdhor     ,
      funmat    like datmpesqhist.c24funmat ,
      c24txtseq like datmpesqhist.c24txtseq ,
      c24psqdsc like datmpesqhist.c24psqdsc
   end record

   define arr_aux      integer
   define scr_aux      integer
   define aux_times    char(11)

   if  k_ctp01m04.data is null then
       let aux_times = time
       let ws.lighor = aux_times[1,5]
       let ws.ligdat = today
       let ws.funmat = g_issk.funmat
   else
       let ws.lighor = k_ctp01m04.hora
       let ws.ligdat = k_ctp01m04.data
       let ws.funmat = k_ctp01m04.funmat
   end if

   let arr_aux  = 1

   while true
      let int_flag = false

      call set_count(arr_aux - 1)

      options
         insert key F35 ,
         delete key F36

      input array a_ctp01m04 without defaults from s_ctp01m03.*
         before row
            let arr_aux  =  arr_curr()
            let scr_aux  =  scr_line()

         before insert
            initialize a_ctp01m04[arr_aux].c24psqdsc  to null

            display a_ctp01m04[arr_aux].c24psqdsc  to
                    s_ctp01m03[scr_aux].c24psqdsc

         before field c24psqdsc
            display a_ctp01m04[arr_aux].c24psqdsc to
                    s_ctp01m03[scr_aux].c24psqdsc attribute (reverse)

         after  field c24psqdsc
            display a_ctp01m04[arr_aux].c24psqdsc to
                    s_ctp01m03[scr_aux].c24psqdsc

            if a_ctp01m04[arr_aux].c24psqdsc is null  or
               a_ctp01m04[arr_aux].c24psqdsc =  "  "  then
               error "Complemento em branco nao e' permitido!"
               next field c24psqdsc
            end if

         on key (interrupt)
            exit input
         on key (up)
            error "Alteracoes/Correcoes nao sao permitidas!"
            next field c24psqdsc
         on key (left)
            error "Alteracoes/Correcoes nao sao permitidas!"
            next field c24psqdsc

         after row

            select max (c24txtseq)
              into ws.c24txtseq
              from datmpesqhist
             where datmpesqhist.atdsrvnum = k_ctp01m04.atdsrvnum and
                   datmpesqhist.atdsrvano = k_ctp01m04.atdsrvano

            if ws.c24txtseq is null then
               let ws.c24txtseq = 0
            end if

            let ws.c24txtseq = ws.c24txtseq + 1

            begin work

                  insert into datmpesqhist ( atdsrvnum            ,
                                             atdsrvano            ,
                                             c24funmat            ,
                                             lighorinc            ,
                                             ligdat               ,
                                             c24txtseq            ,
                                             c24psqdsc            )
                         values            ( k_ctp01m04.atdsrvnum ,
                                             k_ctp01m04.atdsrvano ,
                                             ws.funmat            ,
                                             ws.lighor            ,
                                             ws.ligdat            ,
                                             ws.c24txtseq         ,
                                             a_ctp01m04[arr_aux].c24psqdsc )

                  if sqlca.sqlcode  <>  0    then
                     error "Erro (",sqlca.sqlcode,") na inclusao do historico ",
                           "da pesquisa. Favor re-digitar a linha."
                     rollback work
                     next field c24psqdsc
                  end if

            commit work

       end input

       if int_flag  then
          exit while
       end if

   end while

   let int_flag = false

   clear form

end function # ctp01m04
