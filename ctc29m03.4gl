############################################################################
# Nome do Modulo: CTC29M03                                        Marcelo  #
#                                                                 Gilberto #
# Cadastramento dos parametros do relatorio CTR03M14              Mai/1996 #
############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc29m03()
#---------------------------------------------------------------

 define a_ctc29m03 array[04] of record
    ultsoldat        date                 ,
    ultsolhor        char (08)            ,
    funmat           like isskfunc.funmat ,
    funnom           like isskfunc.funnom ,
    inicial          date                 ,
    final            date                 ,
    ufdcod           like glakest.ufdcod  ,
    relpamseq        like dgbmparam.relpamseq
 end record

 define salva        record
    inicial          date                 ,
    final            date                 ,
    ufdcod           like glakest.ufdcod
 end record

 define ws           record
    relpamseq        like dgbmparam.relpamseq   ,
    relpamtxt        like dgbmparam.relpamtxt   ,
    retorno          smallint                   ,
    quant            smallint                   ,
    operacao         char (01)
 end record

 define arr_aux       smallint
 define scr_aux       smallint

 declare c_ctc29m03 cursor for
    select relpamseq , relpamtxt
      from dgbmparam
     where relsgl    = 'CTR03M14'  and
           relpamtip = 1
     order by relpamseq

 let arr_aux = 1
 initialize a_ctc29m03  to null
 initialize salva.*     to null
 initialize ws.*        to null

 foreach c_ctc29m03 into a_ctc29m03[arr_aux].relpamseq, ws.relpamtxt

    let a_ctc29m03[arr_aux].ultsoldat = ws.relpamtxt[01,10]
    let a_ctc29m03[arr_aux].ultsolhor = ws.relpamtxt[11,18]
    let a_ctc29m03[arr_aux].funmat    = ws.relpamtxt[19,26]

    select funnom into a_ctc29m03[arr_aux].funnom
      from isskfunc
     where funmat = a_ctc29m03[arr_aux].funmat

    initialize ws.relpamtxt to null
    select relpamtxt into ws.relpamtxt
      from dgbmparam
     where relsgl    = 'CTR03M14'                    and
           relpamseq = a_ctc29m03[arr_aux].relpamseq and
           relpamtip = 2

    let a_ctc29m03[arr_aux].inicial = ws.relpamtxt[01,10]
    let a_ctc29m03[arr_aux].final   = ws.relpamtxt[12,21]
    let a_ctc29m03[arr_aux].ufdcod  = ws.relpamtxt[23,24]

    let arr_aux = arr_aux + 1
    if arr_aux > 4  then
       error " Limite excedido, tabela com 4 ou mais solicitacoes!"
       exit foreach
    end if
 end foreach

 open window ctc29m03 at 09,02 with form "ctc29m03"
             attribute (form line 1)

 options comment line last - 1
 message " (F17)Abandona, (F1)Inclui, (F2)Cancela"

 call set_count(arr_aux-1)

 select count(*) into ws.quant
   from dgbmparam
  where relsgl    = 'CTR03M14'      and
        relpamtip = 1

 if ws.quant >= 4 then
    error " Numero maximo de solicitacoes atingido!"
    let ws.operacao = " "
 end if

 let int_flag  =  false

 while TRUE
    input array a_ctc29m03 without defaults from s_ctc29m03.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao = "a"
          end if

       before insert
          let ws.operacao = "i"

          select count(*) into ws.quant
            from dgbmparam
           where relsgl    = 'RDAT005'
             and relpamtip = 1

          if ws.quant >= 4 then
             error " ATENCAO! So' sao permitidas 4 solicitacoes por dia!"
             exit input
          else
             initialize a_ctc29m03[arr_aux].*    to null
             let a_ctc29m03[arr_aux].ultsoldat = today
             let a_ctc29m03[arr_aux].ultsolhor = time
             let a_ctc29m03[arr_aux].funmat    = g_issk.funmat

             select funnom into a_ctc29m03[arr_aux].funnom
               from isskfunc
              where funmat = a_ctc29m03[arr_aux].funmat

             display a_ctc29m03[arr_aux].* to s_ctc29m03[scr_aux].*
          end if

       before field inicial
          display a_ctc29m03[arr_aux].inicial to
                  s_ctc29m03[scr_aux].inicial attribute (reverse)

          let salva.inicial = a_ctc29m03[arr_aux].inicial
          let salva.final   = a_ctc29m03[arr_aux].final

       after  field inicial
          display a_ctc29m03[arr_aux].inicial to
                  s_ctc29m03[scr_aux].inicial

          if fgl_lastkey() = fgl_keyval("down")  then
             if arr_aux = 4 then
                error " Nao existem linhas nesta direcao!"
                next field inicial
             end if
             if a_ctc29m03[arr_aux + 1].inicial  is null   then
                error " Nao existem linhas nesta direcao!"
                next field inicial
             end if
          end if

          if a_ctc29m03[arr_aux].inicial is null  then
             error " Data inicial invalida!"
             next field inicial
          else
             if a_ctc29m03[arr_aux].inicial > today then
                error " Data inicial nao pode ser maior que hoje!"
                next field inicial
             end if
          end if

          if salva.inicial <> a_ctc29m03[arr_aux].inicial and
             g_issk.funmat <> a_ctc29m03[arr_aux].funmat  then
             error " So' sao permitidas alteracoes nas suas solicitacoes!"
             let a_ctc29m03[arr_aux].inicial = salva.inicial
             display a_ctc29m03[arr_aux].inicial to
                     s_ctc29m03[scr_aux].inicial
          end if

       before field final
          display a_ctc29m03[arr_aux].final   to
                  s_ctc29m03[scr_aux].final   attribute (reverse)

       after  field final
          display a_ctc29m03[arr_aux].final  to
                  s_ctc29m03[scr_aux].final

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field inicial
          end if

          if a_ctc29m03[arr_aux].final   is null  then
             error " Data final invalida!"
             next field final
          else
             if a_ctc29m03[arr_aux].final > today then
                error " Data final nao pode ser maior que hoje!"
                next field final
             end if
          end if

          if a_ctc29m03[arr_aux].final < a_ctc29m03[arr_aux].inicial then
             error " Data inicial maior que a data final!"
             next field inicial
          end if

          call ctc29m03_data(a_ctc29m03[arr_aux].inicial,
                             a_ctc29m03[arr_aux].final  ) returning ws.retorno

          if ws.retorno = FALSE then
             error " Nao e' possivel especificar um periodo maior que 31 dias!"
             next field inicial
          end if

          if salva.final   <> a_ctc29m03[arr_aux].final  and
             g_issk.funmat <> a_ctc29m03[arr_aux].funmat then
             error " So' sao permitidas alteracoes nas suas solicitacoes!"
             let a_ctc29m03[arr_aux].final = salva.final
             display a_ctc29m03[arr_aux].final  to
                     s_ctc29m03[scr_aux].final
          end if

       before field ufdcod
          display a_ctc29m03[arr_aux].ufdcod  to
                  s_ctc29m03[scr_aux].ufdcod  attribute (reverse)

          let salva.ufdcod  = a_ctc29m03[arr_aux].ufdcod
          let salva.ufdcod  = a_ctc29m03[arr_aux].ufdcod

       after  field ufdcod
          display a_ctc29m03[arr_aux].ufdcod  to
                  s_ctc29m03[scr_aux].ufdcod

          if fgl_lastkey() = fgl_keyval("down")  then
             if arr_aux = 4 then
                error " Nao existem linhas nesta direcao!"
                next field ufdcod
             end if
             if a_ctc29m03[arr_aux + 1].ufdcod   is null   then
                error " Nao existem linhas nesta direcao!"
                next field ufdcod
             end if
          end if

          if a_ctc29m03[arr_aux].ufdcod  is not null  then
             select * from glakest
              where ufdcod = a_ctc29m03[arr_aux].ufdcod

             if sqlca.sqlcode = NOTFOUND then
                error " Unidade de Federacao Invalida !"
                next field ufdcod
             end if
          end if

          if salva.ufdcod  <> a_ctc29m03[arr_aux].ufdcod  and
             g_issk.funmat <> a_ctc29m03[arr_aux].funmat  then
             error " So' sao permitidas alteracoes nas suas solicitacoes!"
             let a_ctc29m03[arr_aux].ufdcod  = salva.ufdcod
             display a_ctc29m03[arr_aux].ufdcod  to
                     s_ctc29m03[scr_aux].ufdcod
          end if

    on key (interrupt)
       exit input

    before delete
       let ws.operacao = "d"

       if g_issk.funmat = a_ctc29m03[arr_aux].funmat then
          if a_ctc29m03[arr_aux].inicial  is null   then
             continue input
          else
             if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
                exit input
             end if

             delete from dgbmparam
              where relsgl    = 'CTR03M14'    and
                    relpamseq = a_ctc29m03[arr_aux].relpamseq

             if sqlca.sqlcode <> 0    then
                error " Erro (",sqlca.sqlcode,") no cancelamento da solicitacao!"
             end if

             initialize a_ctc29m03[arr_aux].* to null
             display a_ctc29m03[arr_aux].*    to s_ctc29m03[scr_aux].*
          end if
       else
          error " So' e' permitido cancelamento das suas solicitacoes!"
          exit input
       end if

    after row
       begin work
       case ws.operacao
          when "i"
             select max(relpamseq)
               into ws.relpamseq
               from dgbmparam
              where relsgl    = "RDAT005"
                and relpamtip = 1

             if ws.relpamseq is null  then
                let ws.relpamseq = 0
             end if

             let ws.relpamseq = ws.relpamseq + 1

             let ws.relpamtxt  = today, time, g_issk.funmat
             insert into dgbmparam (relsgl, relpamseq, relpamtip, relpamtxt)
                            values ("RDAT005", ws.relpamseq, 1, ws.relpamtxt)

             let ws.relpamtxt  = a_ctc29m03[arr_aux].inicial, " ",
                                 a_ctc29m03[arr_aux].final  , " ",
                                 a_ctc29m03[arr_aux].ufdcod
             insert into dgbmparam (relsgl, relpamseq, relpamtip, relpamtxt)
                            values ("RDAT005", ws.relpamseq, 2, ws.relpamtxt)

             if sqlca.sqlcode <> 0 then
                error " Erro (",sqlca.sqlcode,") na solicitacao do relatorio. ",
                      "AVISE A INFORMATICA!"
                options comment line last
                close window ctc29m03
                return
             else
                error " Solicitacao concluida!"
                display a_ctc29m03[arr_aux].* to s_ctc29m03[scr_aux].*
             end if

          when "a"
             if salva.inicial <> a_ctc29m03[arr_aux].inicial  or
                salva.final   <> a_ctc29m03[arr_aux].final    or
                salva.ufdcod  <> a_ctc29m03[arr_aux].ufdcod   then
                initialize ws.relpamtxt to null
                let ws.relpamtxt = a_ctc29m03[arr_aux].inicial, " ",
                                   a_ctc29m03[arr_aux].final  , " ",
                                   a_ctc29m03[arr_aux].ufdcod

                update dgbmparam set (relpamtxt) = (ws.relpamtxt)
                 where relsgl    = 'CTR03M14'                     and
                       relpamseq = a_ctc29m03[arr_aux].relpamseq  and
                       relpamtip = 2

                if sqlca.sqlcode <> 0 then
                   error " Erro (",sqlca.sqlcode,") na alteracao da ",
                         "solicitacao. AVISE A INFORMATICA!"
                   options comment line last
                   close window ctc29m03
                   return
                else
                   error " Alteracao concluida!"
                end if
             end if

       end case
       commit work

       let ws.operacao = " "
    end input

    if int_flag then
       exit while
    end if

 end while

 close window ctc29m03
 let int_flag = false

end function  #--- ctc29m03

#------------------------------------
 function ctc29m03_data(param)
#------------------------------------

define param record
  inicial    date ,
  final      date
end record

define data  record
  inicial    date ,
  final      date
end record

initialize data.* to null

let data.inicial = param.final - 31 units day
if data.inicial > param.inicial then
   return FALSE
else
   return TRUE
end if

end function  ## ctc29m03_data
