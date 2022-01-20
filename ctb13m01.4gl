###############################################################################
# Nome do Modulo: CTB13M01                                           Marcelo  #
#                                                                    Gilberto #
# Servicos realizados pela frota sem quilometragem digitada          Jul/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas    #
#                                       para verificacao do servico.          #
#-----------------------------------------------------------------------------#
# 15/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
###############################################################################

database porto

#------------------------------------------------------------
 function ctb13m01()
#------------------------------------------------------------

 define d_ctb13m01 record
    incdat         date,
    fnldat         date
 end record

 define a_ctb13m01 array[300] of record
    atddat         like datmservico.atddat   ,
    atdhor         like datmservico.atdhor   ,
    servico        char (13)                 ,
    atdvclsgl      like datmservico.atdvclsgl,
    cnldat         like datmservico.cnldat   ,
    sitdes         char (10)
 end record

 define ws          record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    atdprscod       like datmservico.atdprscod,
    atdfnlflg       like datmservico.atdfnlflg,
    socvclcod       like datmservico.socvclcod,
    atdetpcod       like datmsrvacp.atdetpcod ,
    contador        char (10),
    diaqtd          smallint,
    atdsrvorg       like datmservico.atdsrvorg
 end record

 define arr_aux     smallint
 define sql_comando char (250)


#----------------------------------------
# PREPARA COMANDO SQL
#----------------------------------------
 let sql_comando = "select atdsrvnum, atdsrvano",
                   "  from datmtrajeto         ",
                   " where atdsrvnum = ?  and  ",
                   "       atdsrvano = ?       "
 prepare sel_trajeto   from sql_comando
 declare c_trajeto   cursor for sel_trajeto

 let sql_comando = "select atdvclsgl ",
                   "  from datkveiculo   ",
                   " where socvclcod = ? "
 prepare sel_datkveiculo   from sql_comando
 declare c_datkveiculo   cursor for sel_datkveiculo

 let sql_comando = "select atdetpcod    ",
                   "  from datmsrvacp   ",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from sql_comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 let sql_comando = "select atdetpdes    ",
                   "  from datketapa    ",
                   " where atdetpcod = ?"
 prepare sel_datketapa from sql_comando
 declare c_datketapa cursor for sel_datketapa


 open window w_ctb13m01 at  06,02 with form "ctb13m01"
             attribute(form line first)

 while true

    initialize d_ctb13m01.*  to null
    initialize ws.*          to null
    initialize a_ctb13m01    to null

    let int_flag = false
    let arr_aux  = 1

    let d_ctb13m01.incdat = today - 1 units day
    let d_ctb13m01.fnldat = today - 1 units day

    input by name d_ctb13m01.*  without defaults

       before field incdat
          display by name d_ctb13m01.incdat    attribute (reverse)

       after field incdat
          display by name d_ctb13m01.incdat

          if d_ctb13m01.incdat  is null   then
             error " Informe a data inicial para pesquisa!"
             next field incdat
          end if

          if d_ctb13m01.incdat < today - 60 units day  then
             error " Data inicial nao pode ser anterior a 60 dias!"
             next field incdat
          end if

          if d_ctb13m01.incdat > today  then
             error " Data inicial nao pode ser maior que hoje!"
             next field incdat
          end if

       before field fnldat
          display by name d_ctb13m01.fnldat    attribute (reverse)

       after field fnldat
          display by name d_ctb13m01.fnldat

          if d_ctb13m01.fnldat  is null   then
             error " Informe a data final para pesquisa!"
             next field fnldat
          end if

          if d_ctb13m01.fnldat < today - 60 units day  then
             error " Data final nao pode ser anterior a 60 dias!"
             next field fnldat
          end if

          if d_ctb13m01.fnldat > today  then
             error " Data final nao pode ser maior que hoje!"
             next field fnldat
          end if

          if d_ctb13m01.fnldat < d_ctb13m01.incdat  then
             error " Data final nao pode ser menor que data inicial!"
             next field incdat
          end if

          let ws.diaqtd = d_ctb13m01.fnldat - d_ctb13m01.incdat

          if ws.diaqtd > 31  then
             error " Intervalo entre datas nao pode ser maior que 31 dias!"
             next field incdat
          end if

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

   declare c_ctb13m01 cursor for
      select atdsrvnum,
             atdsrvano,
             atddat   ,
             atdhor   ,
             atdvclsgl,
             cnldat   ,
             atdprscod,
             atdfnlflg,
             socvclcod,
             atdsrvorg
        from datmservico
       where atddat between d_ctb13m01.incdat   and  d_ctb13m01.fnldat  and
             atdsrvorg <> 10 and  atdsrvorg <> 11 and  atdsrvorg <> 8
       order by atddat, atdhor, atdsrvnum

   message " Aguarde, pesquisando..."  attribute(reverse)

   foreach  c_ctb13m01  into  ws.atdsrvnum,
                              ws.atdsrvano,
                              a_ctb13m01[arr_aux].atddat,
                              a_ctb13m01[arr_aux].atdhor,
                              a_ctb13m01[arr_aux].atdvclsgl,
                              a_ctb13m01[arr_aux].cnldat,
                              ws.atdprscod,
                              ws.atdfnlflg,
                              ws.socvclcod,
                              ws.atdsrvorg

   #  if ws.atdfnlflg is null  then
      if ws.atdfnlflg = "N"    then
         continue foreach
      end if

      if ws.atdprscod = 1  then
      else
         continue foreach
      end if

      open  c_trajeto using ws.atdsrvnum, ws.atdsrvano
      fetch c_trajeto

      if sqlca.sqlcode = 0  then
         continue foreach
      end if

      close c_trajeto

      #------------------------------------------------------------
      # Verifica etapa do servico
      #------------------------------------------------------------
  #   case ws.atdfnlflg
  #      when "C"  let a_ctb13m01[arr_aux].sitdes = "CONCLUIDO"
  #      when "E"  let a_ctb13m01[arr_aux].sitdes = "EXCLUIDO"
  #      when "L"  let a_ctb13m01[arr_aux].sitdes = "CANCELADO"
  #   end case
      open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                               ws.atdsrvnum, ws.atdsrvano
      fetch c_datmsrvacp into  ws.atdetpcod
      close c_datmsrvacp

      if sqlca.sqlcode = 0  then
         open  c_datketapa using ws.atdetpcod
         fetch c_datketapa into  a_ctb13m01[arr_aux].sitdes
         close c_datketapa
        else
         let a_ctb13m01[arr_aux].sitdes = "N/PREVISTO"
      end if

      let a_ctb13m01[arr_aux].servico =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,02),
                                    " ", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,07),
                                    "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,02)

      if ws.socvclcod  is not null   then
         open  c_datkveiculo using ws.socvclcod
         fetch c_datkveiculo  into a_ctb13m01[arr_aux].atdvclsgl
      end if

      let arr_aux = arr_aux + 1

      if arr_aux > 300  then
         error " Limite excedido, pesquisa com mais de 300 servicos!"
         exit foreach
      end if
   end foreach

   if arr_aux  >  1   then
      message " (F17)Abandona"

      let ws.contador = "Total: ", arr_aux - 1  using "<<&"
      display ws.contador to contador attribute (reverse)

      call set_count(arr_aux-1)

      display array  a_ctb13m01 to s_ctb13m01.*
         on key(interrupt)
            initialize ws.contador to null
            display ws.contador to contador
            exit display
      end display
   else
      error " Nao existem servicos sem quilometragem digitada! "
   end if

   for arr_aux = 1  to  11
      clear s_ctb13m01[arr_aux].*
   end for

end while

let int_flag = false
close window  w_ctb13m01

end function  #  ctb13m01
