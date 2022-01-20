###############################################################################
# Nome do Modulo: CTC00M09                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Manutencao e-mail e codigo do cronograma do prestador              Dez/1999 #
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica         CT        Alteracao                        #
# ---------- ------------------ --------- ------------------------------------#
# 08/2008    Meta-Norton Nery   226300    Grava no Historico e envia de email #
#                                                                             #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function ctc00m09(param)
#--------------------------------------------------------------

 define param        record
    pstcoddig        like dpaksocor.pstcoddig
 end record

 define d_ctc00m09   record
    maides           like dpaksocor.maides,
    crnpgtcod        like dpaksocor.crnpgtcod,
    crnpgtdes        like dbsmcrnpgt.crnpgtdes
 end record

 define lr_ctc00m09_ant record
    maides           like dpaksocor.maides,
    crnpgtcod        like dpaksocor.crnpgtcod,
    crnpgtdes        like dbsmcrnpgt.crnpgtdes
 end record

 define ws           record
    crnpgtstt        like dbsmcrnpgt.crnpgtstt,
    count            smallint,
    confirma         char (01)
 end record

 define l_prshstdes  char(500),
        l_length     smallint

 initialize d_ctc00m09.* to null
 initialize ws.*         to null

 let int_flag = false

 select count(*)
   into ws.count
   from dbsmopg
  where pstcoddig    = param.pstcoddig
    and socopgsitcod = "7"

 if ws.count is null or
    ws.count = 0     then
    call cts08g01("A","N","","PRESTADOR NAO CONTEM NENHUMA OP EMITIDA",
                             "NO SISTEMA, FAVOR VERIFICAR","")
        returning ws.confirma
    return
 end if

 open window w_ctc00m09 at 14,08 with form "ctc00m09"
      attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona"

 select maides, crnpgtcod
   into d_ctc00m09.maides, d_ctc00m09.crnpgtcod
   from dpaksocor
  where dpaksocor.pstcoddig = param.pstcoddig

 if d_ctc00m09.crnpgtcod is not null  then
    select crnpgtdes
      into d_ctc00m09.crnpgtdes
      from dbsmcrnpgt
     where crnpgtcod = d_ctc00m09.crnpgtcod
 end if

 let lr_ctc00m09_ant.* = d_ctc00m09.*

 display by name d_ctc00m09.*

 while true

    input by name d_ctc00m09.maides,
                  d_ctc00m09.crnpgtcod  without defaults

       before field maides
          display by name d_ctc00m09.maides attribute (reverse)

       after  field maides
          display by name d_ctc00m09.maides

          if d_ctc00m09.maides is null  then
             error " Nro do e-mail deve ser informado!"
             next field maides
          end if

          if ctb00g02(d_ctc00m09.maides) = "1" then
             call cts08g01("A","N","","ENDERECO E-MAIL INCORRETO",
                                      "","")
                  returning ws.confirma
             next field maides
          end if

       before field crnpgtcod
          display by name d_ctc00m09.crnpgtcod  attribute (reverse)

       after  field crnpgtcod
          display by name d_ctc00m09.crnpgtcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field maides
          end if

          if d_ctc00m09.crnpgtcod is not null  then
             select crnpgtdes, crnpgtstt
               into d_ctc00m09.crnpgtdes, ws.crnpgtstt
               from dbsmcrnpgt
              where crnpgtcod = d_ctc00m09.crnpgtcod

             if sqlca.sqlcode <> 0 then
                error " Codigo cronograma nao existe!"
                call ctb18m02() returning d_ctc00m09.crnpgtcod
                next field crnpgtcod
             else
                if ws.crnpgtstt <> "A" then
                   error " Codigo cronograma nao esta (A)tivo!"
                   next field crnpgtcod
                end if
             end if
             display by name d_ctc00m09.crnpgtdes
          end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    else
       call cts08g01("C","S","","DADOS ESTAO CORRETOS ?",
                                 "","")
        returning ws.confirma

       if ws.confirma = "S"  then
          begin work
            update dpaksocor set ( maides   ,
                                   crnpgtcod,
                                   atldat   ,
                                   funmat   )
                               = ( d_ctc00m09.maides   ,
                                   d_ctc00m09.crnpgtcod,
                                   today               ,
                                   g_issk.funmat       )
             where dpaksocor.pstcoddig = param.pstcoddig

          if sqlca.sqlcode <> 0  then
             error " Erro (", sqlca.sqlcode, ") na alteracao prestador. AVISE A INFORMATICA!"
             rollback work
             sleep 2
          else
             let l_prshstdes = null

             if  d_ctc00m09.maides <> lr_ctc00m09_ant.maides then
                 let l_prshstdes = l_prshstdes clipped,
                     "E-mail alterado de [",
                     lr_ctc00m09_ant.maides clipped,"] para [",
                     d_ctc00m09.maides clipped,"],"
             end if

             if  d_ctc00m09.crnpgtcod <> lr_ctc00m09_ant.crnpgtcod then
                 let l_prshstdes = l_prshstdes clipped,
                     "Cronograma alterado de [",
                     lr_ctc00m09_ant.crnpgtcod, "] para [",
                     d_ctc00m09.crnpgtcod, "],"
             end if

             let l_length = length(l_prshstdes clipped)
             display l_length, " ", l_prshstdes clipped, " ",
                     lr_ctc00m09_ant.maides clipped, " ", d_ctc00m09.maides clipped
             if  l_prshstdes is not null and l_length > 0 then
                 if  l_prshstdes[l_length] = "," then
                     let l_prshstdes = l_prshstdes[1,l_length - 1]
                 end if

                 call ctc00m02_grava_hist(param.pstcoddig,l_prshstdes,"A")
             end if

             error " Alteracao efetuada com sucesso!"
             commit work
          end if
          exit while
       end if
    end if

 end while

 close window w_ctc00m09

 let int_flag = false

end function  ###  ctc00m09
