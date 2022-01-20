############################################################################
# Menu de Modulo: CTS14M12                                           Pedro #
#                                                                  Marcelo #
# Mostra Historico da Vistoria de Sinistro                        Jul/1995 #
############################################################################
#                        A T E N C A O                                     #
############################################################################
#   ESTE MODULO ESTA NA FORMACAO DE UM PROGRAMA DO SISTEMA DE SINISTRO     #
############################################################################

# ...........................................................................#
#                                                                            #
#                           * * * Alteracoes * * *                           #
#                                                                            #
# Data       Autor Fabrica    Origem    Alteracao                            #
# ---------- --------------   --------- -------------------------------------#
# 30/01/2006 T.Solda, Meta    PSI194387 Passar o "vcompila" no modulo        #
#----------------------------------------------------------------------------#
# 28/09/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario#
#---------------------------------------------------------------------------#
globals '/homedsa/projetos/geral/globals/glct.4gl'

#---------------------------------------------------------------
function cts14m12(k_cts14m12)
#---------------------------------------------------------------

  define a_cts14m12 array[200] of record
     ligdat    like datmsinhist.ligdat   ,
     lighor    like datmsinhist.lighorinc,
     c24txtseq like datmsinhist.c24txtseq,
     c24funmat like datmsinhist.c24funmat,
     c24vstdsc like datmsinhist.c24vstdsc
  end record

  define a_cts14m12d array[200] of record
     c24vstdsc like datmsinhist.c24vstdsc
  end record

  define k_cts14m12 record
    sinvstnum  like datmsinhist.sinvstnum,
    sinvstano  like datmsinhist.sinvstano
  end record

  define ws         record
     ligdatant like datmsinhist.ligdat   ,
     lighorant like datmsinhist.lighorinc,
     funcnome  char (15),
     privez    dec  (1,0)
  end record

  define arr_aux      integer
  define arr_aux2     integer
  define scr_aux      integer
  define operacao_aux char(1)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	arr_aux  =  null
	let	arr_aux2  =  null
	let	scr_aux  =  null
	let	operacao_aux  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  a_cts14m12 to  null

        initialize  a_cts14m12d to  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  ws.*  to  null

  while true
     let int_flag = false

     declare c_cts14m12_001 cursor for
        select
           ligdat   ,
           lighorinc,
           c24txtseq,
           c24funmat,
           c24vstdsc
        from
           datmsinhist
        where
           datmsinhist.sinvstnum = k_cts14m12.sinvstnum and
           datmsinhist.sinvstano = k_cts14m12.sinvstano
        order by
           ligdat   ,
           lighorinc,
           c24txtseq

     let ws.privez    = 1
     let arr_aux      = 1
     let arr_aux2     = 1

     let ws.ligdatant = "31/12/1899"
     let ws.lighorant = "00:00"

     initialize a_cts14m12  to null
     initialize a_cts14m12d to null

     foreach c_cts14m12_001 into a_cts14m12[arr_aux].*
        if ws.ligdatant  <>  a_cts14m12[arr_aux].ligdat   or
           ws.lighorant  <>  a_cts14m12[arr_aux].lighor   then

           if ws.privez   =  1   then
              let ws.privez = 0
           else
              let arr_aux2 = arr_aux2 + 2
           end if

           select funnom
             into ws.funcnome
             from isskfunc
            where isskfunc.empcod = 01
              and isskfunc.funmat = a_cts14m12[arr_aux].c24funmat

           let a_cts14m12d[arr_aux2].c24vstdsc =
           "Em: ",    a_cts14m12[arr_aux].ligdat clipped,
           "  As: ",  a_cts14m12[arr_aux].lighor clipped,
           "  Por: ", ws.funcnome                clipped

           let ws.ligdatant = a_cts14m12[arr_aux].ligdat
           let ws.lighorant = a_cts14m12[arr_aux].lighor
           let arr_aux2     = arr_aux2 + 1
        end if

        let arr_aux2 = arr_aux2 + 1
        let a_cts14m12d[arr_aux2].c24vstdsc = a_cts14m12[arr_aux].c24vstdsc

        let arr_aux  = arr_aux  + 1

        if arr_aux > 200 then
           error "Limite de consulta excedido (200). Avise a informatica!"
           sleep 5
           exit foreach
        end if
     end foreach

     if  arr_aux  >  1  then
         call set_count(arr_aux2)
         display array a_cts14m12d to s_cts14m11.*
            on key (interrupt,control-m)
               exit display
         end display
     else
         error "Nenhum historico foi cadastrado p/ esta vistoria!"
         let int_flag =  true
     end if

     if int_flag  then
        exit while
     end if

  end while

  let int_flag = false

end function # cts14m12
