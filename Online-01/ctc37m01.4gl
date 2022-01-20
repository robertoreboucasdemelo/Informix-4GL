############################################################################
# Menu de Modulo: ctc37m01                                        Marcelo  #
#                                                                 Gilberto #
#                                                                 Wagner   #
# Implementacao de Dados na OBS da vistoria                       Dez/1998 #
############################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc37m01(k_ctc37m01)
#---------------------------------------------------------------

 define k_ctc37m01 record
    socvstnum      like datmvstobs.socvstnum,
    cademp         like datmvstobs.cademp,
    cadmat         like datmvstobs.cadmat
 end record

 define a_ctc37m01 array[200] of record
    blqobstxt      like datmvstobs.blqobstxt
 end record

 define ws          record
    socvstfasobsseq like datmvstobs.socvstfasobsseq ,
    blqobstxt       like datmvstobs.blqobstxt,
    socvstfasnum    like datmvstfas.socvstfasnum
 end record

 define arr_aux    smallint
 define scr_aux    smallint

 select max(socvstfasnum) into ws.socvstfasnum
   from datmvstfas
  where socvstnum = k_ctc37m01.socvstnum

 if sqlca.sqlcode <> 0 then
    error " Nao foi encontrado fase para esta vistoria !"
    return
 end if

 let arr_aux = 1

 while true
    let int_flag = false

    call set_count(arr_aux - 1)

    options insert key F35,
            delete key F36

    input array a_ctc37m01 without defaults from s_ctc37m01.*
       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

       before insert
          initialize a_ctc37m01[arr_aux].blqobstxt  to null

          display a_ctc37m01[arr_aux].blqobstxt  to
                  s_ctc37m01[scr_aux].blqobstxt

       before field blqobstxt
          display a_ctc37m01[arr_aux].blqobstxt to
                  s_ctc37m01[scr_aux].blqobstxt attribute (reverse)

       after field blqobstxt
          display a_ctc37m01[arr_aux].blqobstxt to
                  s_ctc37m01[scr_aux].blqobstxt

          if a_ctc37m01[arr_aux].blqobstxt is null  or
             a_ctc37m01[arr_aux].blqobstxt =  "  "  then
             error " Complemento deve ser informado!"
             next field blqobstxt
          end if

       on key (interrupt)
          exit input

       on key (up)
          error " Alteracoes/Correcoes nao sao permitidas!"
          next field blqobstxt

       on key (left)
          error " Alteracoes/Correcoes nao sao permitidas!"
          next field blqobstxt

       after row
          select max (socvstfasobsseq)
            into ws.socvstfasobsseq
            from datmvstobs
           where socvstnum    = k_ctc37m01.socvstnum
             and socvstfasnum = ws.socvstfasnum

          if ws.socvstfasobsseq is null then
             let ws.socvstfasobsseq = 0
          end if

          let ws.socvstfasobsseq = ws.socvstfasobsseq + 1

          whenever error continue

          insert into datmvstobs ( socvstnum ,
                                   socvstfasnum,
                                   socvstfasobsseq,
                                   caddat,
                                   cademp,
                                   cadmat,
                                   blqobstxt )
                          values ( k_ctc37m01.socvstnum ,
                                   ws.socvstfasnum      ,
                                   ws.socvstfasobsseq   ,
                                   today                ,
                                   k_ctc37m01.cademp    ,
                                   k_ctc37m01.cadmat    ,
                                   a_ctc37m01[arr_aux].blqobstxt)

          if sqlca.sqlcode <> 0  then
             error "Erro (", sqlca.sqlcode, ") na inclusao da observacao Favor re-digitar a linha."
             next field blqobstxt
          end if

          whenever error stop

    end input

    if int_flag  then
       exit while
    end if

 end while

 let int_flag = false

 clear form

 end function  ###  ctc37m01
