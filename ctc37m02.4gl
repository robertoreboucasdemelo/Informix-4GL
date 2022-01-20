############################################################################
# Menu de Modulo: CTC37M02                                        Gilberto #
#                                                                 Marcelo  #
#                                                                 Wagner   #
# Mostra Observacao das vistorias                                 Dez/1998 #
############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc37m02(k_ctc37m02)
#---------------------------------------------------------------

 define a_ctc37m02 array[300] of record
    blqobstxt      char(70)
 end record

 define k_ctc37m02  record
    socvstnum       like datmvstobs.socvstnum
 end record

 define ws          record
    descfas         char(11),
    socvstfasnum    like datmvstobs.socvstfasnum    ,
    caddat          like datmvstobs.caddat          ,
    socvstfasobsseq like datmvstobs.socvstfasobsseq ,
    cadmat          like datmvstobs.cadmat          ,
    blqobstxt       like datmvstobs.blqobstxt       ,
    socvstfasnumant like datmvstobs.socvstfasnum    ,
    caddatant       like datmvstobs.caddat          ,
    funnom          char (015)                      ,
    privez          smallint
 end record

 define arr_aux    smallint
 define scr_aux    smallint

  while true
     let int_flag = false

     declare c_ctc37m02 cursor for
        select socvstfasnum, caddat, socvstfasobsseq, cadmat, blqobstxt
          from datmvstobs
         where socvstnum = k_ctc37m02.socvstnum
         order by socvstfasnum desc, caddat asc , socvstfasobsseq asc

     initialize ws.* to null

     let arr_aux      = 1
     let ws.privez    = true

     let ws.caddatant = "31/12/1899"

     initialize a_ctc37m02  to null

     foreach c_ctc37m02 into ws.socvstfasnum,    ws.caddat,
                             ws.socvstfasobsseq, ws.cadmat,
                             ws.blqobstxt

        if ws.caddatant <> ws.caddat or
           ws.socvstfasnum <> ws.socvstfasnumant then

           if ws.privez  =  true  then
              let ws.privez = false
           else
              let arr_aux = arr_aux + 2
           end if

           select funnom into ws.funnom
             from isskfunc
            where isskfunc.funmat = ws.cadmat

           select cpodes
             into ws.descfas
             from iddkdominio
            where cponom = "socvstfasnum"
              and cpocod =  ws.socvstfasnum

           if sqlca.sqlcode <> 0 then
              let ws.descfas = "ERRO !!!  "
           end if

           let a_ctc37m02[arr_aux].blqobstxt = "Em: ",    ws.caddat clipped,
                                               "  Por: ", ws.funnom clipped,
                                               "      Fase: ", ws.socvstfasnum,
                                               " - ",ws.descfas

           let ws.caddatant = ws.caddat
           let ws.socvstfasnumant = ws.socvstfasnum
           let arr_aux      = arr_aux + 1
        end if

        let arr_aux = arr_aux + 1

        let a_ctc37m02[arr_aux].blqobstxt = ws.blqobstxt

        if arr_aux > 300 then
           error " Limite excedido, observacoes c/ mais de 300 linhas, AVISE INFORMATICA!"
           sleep 5
           exit foreach
        end if
     end foreach

     if arr_aux  >  1  then
        call set_count(arr_aux)
        message " (F17)Abandona"
        display array a_ctc37m02 to s_ctc37m01.*
           on key (interrupt,control-c)
              exit display
        end display
        message ""
     else
        error " Nenhuma observacao foi cadastrada para esta vistoria!"
        let int_flag =  true
     end if

     if int_flag  then
        exit while
     end if

  end while

  let int_flag = false

end function # ctc37m02
