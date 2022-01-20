###############################################################################
# Nome do Modulo: ctc36m06                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Consulta Vistoria por fase, situacao, data, sigla veic, prestador  Dez/1998 #
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- --------  -----------------------------------------#
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.               #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


#-----------------------------------------------------------
 function ctc36m06()
#-----------------------------------------------------------

 define d_ctc36m06  record
    sigla           like datkveiculo.atdvclsgl,
    prestador       like datkveiculo.pstcoddig,
    presdesc        like dpaksocor.nomgrr,
    situacao        like datmsocvst.socvstsit,
    sitdesc         char(20),
    dataini         date,
    datafim         date,
    total           char(12)
 end record

 define a_ctc36m06 array[300] of record
    socvstnum        like datmsocvst.socvstnum,
    atdvclsgl        like datkveiculo.atdvclsgl,
    vcldesc          char(40),
    nomgrr           like dpaksocor.nomgrr,
    socvstdat        like datmsocvst.socvstdat,
    socvstsit_des    char(20),
    socvstfasnum_des char(10)
 end record

 define ws           record
    prep             char(400),
    condicao         char(300),
    vclcoddig        like datkveiculo.vclcoddig,
    socvclcod        like datkveiculo.socvclcod,
    socvstsit        like datmsocvst.socvstsit,
    socvstfasnum     like datmvstfas.socvstfasnum,
    pstcoddig        like datkveiculo.pstcoddig
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 initialize d_ctc36m06.*    to null
 initialize ws.*            to null

 open window ctc36m06 at 06,02 with form "ctc36m06"
             attribute (form line first)

 while true

   let int_flag = false
   initialize a_ctc36m06  to null
   let arr_aux  = 1

   input by name d_ctc36m06.sigla,
                 d_ctc36m06.prestador,
                 d_ctc36m06.situacao,
                 d_ctc36m06.dataini,
                 d_ctc36m06.datafim  without defaults

      before field sigla
             initialize d_ctc36m06 to null
             display by name d_ctc36m06.*
             display by name d_ctc36m06.sigla    attribute (reverse)

      after  field sigla
             display by name d_ctc36m06.sigla

             if d_ctc36m06.sigla   is null   then
                next field prestador
             end if

             initialize ws.vclcoddig  to null
             initialize ws.socvclcod  to null

             select vclcoddig, socvclcod
               into ws.vclcoddig, ws.socvclcod
               from datkveiculo
              where datkveiculo.atdvclsgl = d_ctc36m06.sigla

             if sqlca.sqlcode <> 0    then
                error " Veiculo nao cadastrado!"
                next field sigla
             end if

             exit input

      before field prestador
             initialize d_ctc36m06 to null
             display by name d_ctc36m06.*
             display by name d_ctc36m06.prestador attribute (reverse)

      after  field prestador
             display by name d_ctc36m06.prestador

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field sigla
             end if

             if d_ctc36m06.prestador   is null   then
                next field situacao
             end if

             initialize d_ctc36m06.presdesc  to null
             display by name d_ctc36m06.presdesc

             if d_ctc36m06.prestador is not null   then
                select nomgrr
                  into d_ctc36m06.presdesc
                  from dpaksocor
                 where pstcoddig = d_ctc36m06.prestador

                if sqlca.sqlcode <> 0   then
                   error " Prestador nao cadastrado!"
                   next field prestador
                end if
               else
                error " Codigo do Prestador obrigatorio para pesquisa!"
                next field prestador
             end if
             display by name d_ctc36m06.presdesc
             next field dataini

      before field situacao
             initialize d_ctc36m06 to null
             display by name d_ctc36m06.*
             display by name d_ctc36m06.situacao    attribute (reverse)

      after  field situacao
             display by name d_ctc36m06.situacao

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field prestador
             end if

             select cpodes
               into d_ctc36m06.sitdesc
               from iddkdominio
              where cponom = "socvstsit"
                and cpocod = d_ctc36m06.situacao

             if sqlca.sqlcode <> 0 then
                error " Obs: 1-Agend., 2-Confirm., 3-Dig.Incompl. 4-Digitada, 5-Realiz. ou 6-Cancelada"
                next field situacao
             end if
             display by name d_ctc36m06.sitdesc

      before field dataini
             display by name d_ctc36m06.dataini      attribute (reverse)

      after  field dataini
             display by name d_ctc36m06.dataini

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                if d_ctc36m06.situacao is not null then
                   next field situacao
                  else
                   next field prestador
                end if
             end if

             if d_ctc36m06.dataini  is null then
                error " Data inicial obrigatorio para pesquisa!"
                next field dataini
             end if

      before field datafim
             display by name d_ctc36m06.datafim      attribute (reverse)

      after  field datafim
             display by name d_ctc36m06.datafim

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field dataini
             end if

             if d_ctc36m06.datafim  is null then
                error " Data final obrigatorio para pesquisa!"
                next field datafim
             end if

             if d_ctc36m06.dataini > d_ctc36m06.datafim then
                error " Data inicial maior que data final!"
                next field datafim
             end if

             if (d_ctc36m06.datafim - d_ctc36m06.dataini) > 30 then
                error " Periodo de pesquisa nao pode ser maior que 30 dias!"
                next field datafim
             end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   if d_ctc36m06.sigla is not null then
      let ws.condicao = "  from datmsocvst ",
                        " where datmsocvst.socvclcod = ? ",
                        " order by datmsocvst.socvstdat "
     else
      if d_ctc36m06.prestador is not null then
         let ws.condicao = "  from datmsocvst, datkveiculo ",
                           " where (datmsocvst.socvstdat >= ? ",
                           "   and  datmsocvst.socvstdat <= ? )",
                           "   and datkveiculo.socvclcod = datmsocvst.socvclcod ",
                           "   and datkveiculo.pstcoddig = ?  ",
                           " order by datmsocvst.socvstdat "
        else
         let ws.condicao = "  from datmsocvst ",
                           " where datmsocvst.socvstsit   = ? ",
                           "   and (datmsocvst.socvstdat >= ? ",
                           "   and  datmsocvst.socvstdat <= ? )",
                           " order by datmsocvst.socvstdat "

      end if
   end if

   let ws.prep = "select datmsocvst.socvstnum, ",
                  "       datmsocvst.socvclcod, ",
                  "       datmsocvst.socvstsit, ",
                  "       datmsocvst.socvstdat  ",
                  ws.condicao  clipped

   message " Aguarde, pesquisando..."  attribute(reverse)
   prepare comando_sql from ws.prep
   declare c_ctc36m06  cursor for  comando_sql

   if d_ctc36m06.sigla is not null then
      open c_ctc36m06  using  ws.socvclcod
     else
      if d_ctc36m06.prestador is not null then
         open c_ctc36m06  using  d_ctc36m06.dataini,
                                 d_ctc36m06.datafim,
                                 d_ctc36m06.prestador
        else
         open c_ctc36m06  using  d_ctc36m06.situacao,
                                 d_ctc36m06.dataini,
                                 d_ctc36m06.datafim

      end if
   end if

   foreach  c_ctc36m06  into  a_ctc36m06[arr_aux].socvstnum,
                              ws.socvclcod,
                              ws.socvstsit,
                              a_ctc36m06[arr_aux].socvstdat

      # MONTA DESCRICAO SITUACAO
        select cpodes
          into a_ctc36m06[arr_aux].socvstsit_des
          from iddkdominio
         where cponom = "socvstsit"
           and cpocod = ws.socvstsit

         if sqlca.sqlcode <> 0 then
            let a_ctc36m06[arr_aux].socvstsit_des = "NAO EXISTE"
         end if

      # MONTA FASE VISTORIA
        select max(socvstfasnum) into ws.socvstfasnum
          from datmvstfas
         where datmvstfas.socvstnum = a_ctc36m06[arr_aux].socvstnum

         if sqlca.sqlcode <> 0 then
            let a_ctc36m06[arr_aux].socvstfasnum_des = "NAO EXISTE"
           else
            select cpodes
              into a_ctc36m06[arr_aux].socvstfasnum_des
              from iddkdominio
             where cponom = "socvstfasnum"
               and cpocod = ws.socvstfasnum

            if sqlca.sqlcode <> 0 then
               let a_ctc36m06[arr_aux].socvstfasnum_des = "NAO EXISTE"
            end if
         end if

      # MONTA VEICULO
        select atdvclsgl, pstcoddig, vclcoddig
          into a_ctc36m06[arr_aux].atdvclsgl,
               ws.pstcoddig,
               ws.vclcoddig
          from datkveiculo
         where datkveiculo.socvclcod = ws.socvclcod

        call cts15g00(ws.vclcoddig) returning a_ctc36m06[arr_aux].vcldesc

      # MONTA PRESTADOR
        select nomgrr
          into a_ctc36m06[arr_aux].nomgrr
          from dpaksocor
         where dpaksocor.pstcoddig = ws.pstcoddig

        if sqlca.sqlcode <> 0    then
           let a_ctc36m06[arr_aux].nomgrr = "Prestador nao cadastrado!"
        end if

      let arr_aux = arr_aux + 1
      if arr_aux > 350 then
         error "Limite excedido. Pesquisa com mais de 350 vistorias!"
         exit foreach
      end if
   end foreach

   if arr_aux  > 1   then
      message " (F17)Abandona, (F8)Seleciona"

      let d_ctc36m06.total = "Total: ", arr_aux - 1  using "&&&"
      display by name d_ctc36m06.total    attribute(reverse)

      call set_count(arr_aux-1)

      display array  a_ctc36m06 to s_ctc36m06.*
        on key(interrupt)
           exit display

        on key(F8)
           let arr_aux = arr_curr()
           call ctc36m07(a_ctc36m06[arr_aux].socvstnum)
      end display

      display " "  to  total
      for scr_aux=1 to 3
          clear s_ctc36m06[scr_aux].*
      end for
   else
      error " Nao existe Vistoria para pesquisa!"
   end if

end while

let int_flag = false
close window ctc36m06

end function  #  ctc36m06
