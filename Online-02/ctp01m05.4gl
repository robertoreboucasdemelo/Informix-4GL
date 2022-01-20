############################################################################
# Menu de Modulo: CTP01M05                                           Pedro #
#                                                                  Marcelo #
# Mostra Historico da Pesquisa                                    Mar/1995 #
############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
function ctp01m05(k_ctp01m05)
#----------------------------------------------------------------

  define a_ctp01m05 array[200] of record
     ligdat    like datmpesqhist.ligdat   ,
     lighor    like datmpesqhist.lighorinc,
     c24txtseq like datmpesqhist.c24txtseq,
     c24funmat like datmpesqhist.c24funmat,
     c24psqdsc like datmpesqhist.c24psqdsc
  end record

  define a_ctp01m05d array[200] of record
     c24psqdsc like datmpesqhist.c24psqdsc
  end record

  define k_ctp01m05 record
    atdsrvnum  like datmpesqhist.atdsrvnum,
    atdsrvano  like datmpesqhist.atdsrvano
  end record

  define ws         record
     ligdatant like datmpesqhist.ligdat   ,
     lighorant like datmpesqhist.lighorinc,
     funcnome  char (15),
     privez    dec  (1,0)
  end record

  define arr_aux      integer
  define arr_aux2     integer
  define scr_aux      integer
  define operacao_aux char(1)

  while true
     let int_flag = false

     declare c_ctp01m05 cursor for
        select
           ligdat   ,
           lighorinc,
           c24txtseq,
           c24funmat,
           c24psqdsc
        from
           datmpesqhist
        where
           datmpesqhist.atdsrvnum = k_ctp01m05.atdsrvnum and
           datmpesqhist.atdsrvano = k_ctp01m05.atdsrvano
        order by
           ligdat   ,
           lighorinc,
           c24txtseq

     let ws.privez    = 1
     let arr_aux      = 1
     let arr_aux2     = 1

     let ws.ligdatant = "31/12/1899"
     let ws.lighorant = "00:00"

     initialize a_ctp01m05  to null
     initialize a_ctp01m05d to null

     foreach c_ctp01m05 into a_ctp01m05[arr_aux].*
        if ws.ligdatant  <>  a_ctp01m05[arr_aux].ligdat   or
           ws.lighorant  <>  a_ctp01m05[arr_aux].lighor   then

           if ws.privez   =  1   then
              let ws.privez = 0
           else
              let arr_aux2 = arr_aux2 + 2
           end if

           select funnom
             into ws.funcnome
             from isskfunc
            where isskfunc.funmat = a_ctp01m05[arr_aux].c24funmat

           let a_ctp01m05d[arr_aux2].c24psqdsc =
           "Em: ",    a_ctp01m05[arr_aux].ligdat clipped,
           "  As: ",  a_ctp01m05[arr_aux].lighor clipped,
           "  Por: ", ws.funcnome                clipped

           let ws.ligdatant = a_ctp01m05[arr_aux].ligdat
           let ws.lighorant = a_ctp01m05[arr_aux].lighor
           let arr_aux2     = arr_aux2 + 1
        end if

        let arr_aux2 = arr_aux2 + 1
        let a_ctp01m05d[arr_aux2].c24psqdsc = a_ctp01m05[arr_aux].c24psqdsc

        let arr_aux  = arr_aux  + 1

        if arr_aux > 200 then
           error "Limite de consulta excedido (200). Avise a informatica!"
           sleep 5
           exit foreach
        end if
     end foreach

     if  arr_aux  >  1  then
         call set_count(arr_aux2)
         display array a_ctp01m05d to s_ctp01m03.*
            on key (interrupt,control-m)
               exit display
         end display
     else
         error "Nenhum historico foi cadastrado p/ este pesquisa"
         let int_flag =  true
     end if

     if int_flag  then
        exit while
     end if

  end while

  let int_flag = false

end function # ctp01m05
