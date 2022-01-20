############################################################################
# Nome de Modulo: CTB11M07                                        Gilberto #
#                                                                 Marcelo  #
# Manutencao dos custos dos itens da ordem de pagamento           Dez/1996 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 05/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.  #
#--------------------------------------------------------------------------#
# 10/04/2001  PSI 12759-0  Wagner       Inclusao do desconto automatico.   #
#--------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel #
# 02/06/2006  CT 697796  Adriano   Trava para não duplicar item em outra OP#
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção#
#                                       de mais de duas casas decimais.    #
############################################################################

  database porto

  globals "/homedsa/projetos/geral/globals/glct.4gl"

#define a_ctb11m07  array[10] of record
  define a_ctb11m07  array[20] of record
     soccstcod       like dbsmopgcst.soccstcod,
     soccstdes       like dbskcustosocorro.soccstdes,
     cstqtd          like dbsmopgcst.cstqtd,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     soccstclccod    like dbskcustosocorro.soccstclccod
  end record

#--------------------------------------------------------------------
function ctb11m07(param)
#--------------------------------------------------------------------
  define param       record
     socopgnum       like dbsmopgitm.socopgnum,
     operacao        char (01),
     nfsnum          like dbsmopgitm.nfsnum,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano,
     vlrfxacod       like dbsmopgitm.vlrfxacod,
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socconlibflg    like dbsmopgitm.socconlibflg,
     socopgitmnum    like dbsmopgitm.socopgitmnum,
     soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
     socgtfcod       like dbstgtfcst.socgtfcod,
     checktab        char (01)
  end record

  define ws          record
     atdsrvorg       like datmservico.atdsrvorg,
     soccstexbseq    like dbskcustosocorro.soccstexbseq,
     soccsttabvlr    like dbsmopgcst.socopgitmcst,
     socopgtotvlr    like dbsmopgitm.socopgitmvlr,
     soccstclcvlr    like dbsmopgitm.socopgitmvlr,
     socgtfcod       like dbskgtf.socgtfcod,
     socopgnum       like dbsmopgitm.socopgnum,
     cstqtdmin       dec(4,2),
     cstqtdhor       integer,
     operacao        char (01),
     confirma        char (01),
     achou           char (01),
     incitmok        char (01),   #--> incluiu item?(s/n)
     soctotcst       dec(15,5),
     socdifitm       dec(15,5),
     linhamsg        char (40),
     comando         char (800),
     vlrprm          like dbsmopgitm.socopgitmvlr
  end record

  define arr_aux     smallint
  define scr_aux     smallint


  initialize a_ctb11m07  to null
  initialize ws.*        to null
  let arr_aux = 1

  # MONTA CURSOR DEPENDE DA UTILIZACAO DA TARIFA
  #---------------------------------------------
  if param.soctrfvignum   is not null   then
     let ws.comando =
                  "select dbskcustosocorro.soccstexbseq, ",
                  "       dbskcustosocorro.soccstdes, ",
                  "       dbskcustosocorro.soccstclccod, ",
                  "       dbstgtfcst.soccstcod, ",
                  "       dbsmopgcst.cstqtd, ",
                  "       dbsmopgcst.socopgitmcst ",
                  "  from dbstgtfcst, dbskcustosocorro, outer dbsmopgcst ",
                  " where dbstgtfcst.soctrfvignum     = ?  ",
                  "   and dbskcustosocorro.soccstcod  = dbstgtfcst.soccstcod ",
                  "   and dbskcustosocorro.soctip     = 1 ",
                  "   and dbsmopgcst.socopgnum        = ? ",
                  "   and dbsmopgcst.socopgitmnum     = ? ",
                  "   and dbsmopgcst.soccstcod        = dbstgtfcst.soccstcod ",
                  " group by dbstgtfcst.soccstcod,dbskcustosocorro.soccstdes, ",
                  "          dbskcustosocorro.soccstexbseq, ",
                  "          dbsmopgcst.socopgitmcst, dbsmopgcst.cstqtd, ",
                  "          dbskcustosocorro.soccstclccod ",
                  " order by dbskcustosocorro.soccstexbseq "
  else
     let ws.comando =
                  "select dbskcustosocorro.soccstexbseq, ",
                  "       dbskcustosocorro.soccstdes, ",
                  "       dbskcustosocorro.soccstclccod, ",
                  "       dbskcustosocorro.soccstcod, ",
                  "       dbsmopgcst.cstqtd, ",
                  "       dbsmopgcst.socopgitmcst ",
                  "  from dbskcustosocorro, outer dbsmopgcst ",
                  " where dbskcustosocorro.soccstcod > 0 ",
                  "   and dbskcustosocorro.soctip    = 1 ",
                  "   and dbsmopgcst.socopgnum    = ? ",
                  "   and dbsmopgcst.socopgitmnum = ? ",
                  "   and dbsmopgcst.soccstcod   = dbskcustosocorro.soccstcod ",
                  " order by dbskcustosocorro.soccstexbseq "
  end if

  prepare comando_aux1  from  ws.comando
  declare c_ctb11m07  cursor for  comando_aux1


  # MONTA DADOS DA ORDEM DE PAGAMENTO
  #----------------------------------
  open window w_ctb11m07 at 09,02 with form "ctb11m07"
       attribute(form line first)

  select atdsrvorg
    into ws.atdsrvorg
    from datmservico
   where atdsrvnum = param.atdsrvnum
     and atdsrvano = param.atdsrvano

  display by name ws.atdsrvorg
  display by name param.atdsrvnum
  display by name param.atdsrvano

  #----------------------------------------------------------------------
  #       PARA MONTAR CUSTOS DOS ITENS DA ORDEM DE PAGAMENTO : (c/tarifa)
  # -AGRUPA CUSTOS QUE ESTAO VIGENTES NA DATA DE ATENDIMENTO DO SERVICO
  # -CLASSIFICA POR ORDEM DE EXIBICAO DO CUSTO(PELO CADASTRO DE CUSTOS)
  # -MOSTRA O VALOR SE ESTE JA' FOI DIGITADO
  #----------------------------------------------------------------------
  if param.soctrfvignum   is not null   then
     open c_ctb11m07  using  param.soctrfvignum,
                             param.socopgnum,
                             param.socopgitmnum
  else
     open c_ctb11m07  using  param.socopgnum,
                             param.socopgitmnum
  end if

  foreach c_ctb11m07 into ws.soccstexbseq,
                          a_ctb11m07[arr_aux].soccstdes,
                          a_ctb11m07[arr_aux].soccstclccod,
                          a_ctb11m07[arr_aux].soccstcod,
                          a_ctb11m07[arr_aux].cstqtd,
                          a_ctb11m07[arr_aux].socopgitmcst

     #------------------------------------------------------
     # DESPREZA OS CUSTOS REFERENTES AS FAIXAS DE VALOR
     #------------------------------------------------------
     if a_ctb11m07[arr_aux].soccstcod  =  01   or
        a_ctb11m07[arr_aux].soccstcod  =  02   then
        continue foreach
     end if

     #------------------------------------------------------
     # DESPREZA OS CUSTOS REFERENTES A DESCONTO/RESTITUICAO
     #------------------------------------------------------
     if a_ctb11m07[arr_aux].soccstcod  =  07   or
        a_ctb11m07[arr_aux].soccstcod  =  08   then
        continue foreach
     end if

     if a_ctb11m07[arr_aux].socopgitmcst  is null   then
        let a_ctb11m07[arr_aux].socopgitmcst = 0.00
     end if

     let arr_aux = arr_aux + 1
##   if arr_aux > 10   then
     if arr_aux > 20   then
        error " Limite excedido! Tabela de custos com mais de 20 custos!"
        exit foreach
     end if
  end foreach

 #-----------------------------------------------
 # EXCLUIR LINHA DE DESCONTO PARA POSSIVEL AJUSTE
 #-----------------------------------------------
 delete from dbsmopgcst
  where socopgnum    = param.socopgnum
    and socopgitmnum = param.socopgitmnum
    and soccstcod    = 07

  call set_count(arr_aux-1)
  options insert key F40,
          delete key F45

  message " (F17)Abandona"

  while true
     let int_flag = false

     input array a_ctb11m07 without defaults from s_ctb11m07.*
        before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
              if arr_aux <= arr_count()  then
                 let ws.operacao = "a"
              end if

           before insert
              let ws.operacao = "i"
              initialize a_ctb11m07[arr_aux].*  to null
              display a_ctb11m07[arr_aux].* to s_ctb11m07[scr_aux].*

           before field cstqtd
              if a_ctb11m07[arr_aux].soccstclccod  <>  3   then
                 next field  socopgitmcst
              end if
              display a_ctb11m07[arr_aux].cstqtd  to
                      s_ctb11m07[scr_aux].cstqtd  attribute (reverse)

           after field cstqtd
              let a_ctb11m07[arr_aux].cstqtd = a_ctb11m07[arr_aux].cstqtd using "&&&&&&&&"
              display a_ctb11m07[arr_aux].cstqtd  to
                      s_ctb11m07[scr_aux].cstqtd

              if a_ctb11m07[arr_aux].soccstcod =  03     and  #-> KM EXCEDENTE
                 param.vlrfxacod               =  01     and  #-> FAIXA PRECO
                 a_ctb11m07[arr_aux].cstqtd is not null  then
                 error " Valor faixa 1 nao deve possuir Km excedente!"
                 next field cstqtd
              end if

           before field socopgitmcst
              display a_ctb11m07[arr_aux].socopgitmcst  to
                      s_ctb11m07[scr_aux].socopgitmcst  attribute (reverse)

              if a_ctb11m07[arr_aux].soccstcod = 23 or a_ctb11m07[arr_aux].soccstcod = 24 then
                 let ws.vlrprm = a_ctb11m07[arr_aux].socopgitmcst
              end if


           after field socopgitmcst
              let a_ctb11m07[arr_aux].socopgitmcst = a_ctb11m07[arr_aux].socopgitmcst using "&&&&&&&&&&&&&&&.&&"
              display a_ctb11m07[arr_aux].socopgitmcst  to
                      s_ctb11m07[scr_aux].socopgitmcst



              if fgl_lastkey() = fgl_keyval("left")  then
                 if a_ctb11m07[arr_aux].soccstclccod  <>  3   then
                    error " Para este custo a quantidade nao e' informada!"
                    next field  socopgitmcst
                 end if
                 next field  cstqtd
              end if

              if a_ctb11m07[arr_aux].socopgitmcst  is null   then
                 error " Valor do custo deve ser informado!"
                 next field socopgitmcst
              end if

              if a_ctb11m07[arr_aux].soccstcod     =  03     and
                 param.vlrfxacod                   =  01     and
                 a_ctb11m07[arr_aux].socopgitmcst  >  0.00   then
                 error " Valor faixa 1 nao deve possuir Km excedente!"
                 next field socopgitmcst
              end if

              if a_ctb11m07[arr_aux].socopgitmcst  = 0.00    and
                 a_ctb11m07[arr_aux].cstqtd        > 0.00    then
                 error " Valor do custo deve ser informado!"
                 next field socopgitmcst
              end if

              if a_ctb11m07[arr_aux].soccstclccod  =  3      and
                 a_ctb11m07[arr_aux].socopgitmcst  > 0.00    then
                 if a_ctb11m07[arr_aux].cstqtd     is null   or
                    a_ctb11m07[arr_aux].cstqtd     =  0.00   then
                    error " Quantidade deve ser informada!"
                    next field socopgitmcst
                 end if
              end if

              if a_ctb11m07[arr_aux].soccstcod = 23 or a_ctb11m07[arr_aux].soccstcod = 24 then
                 if ws.vlrprm <> a_ctb11m07[arr_aux].socopgitmcst then
                    let a_ctb11m07[arr_aux].socopgitmcst = ws.vlrprm
                    error " Valor Premio nao pode ser alterado!"
                    next field socopgitmcst
                 end if
              end if

              # VERIFICA SE VALOR DO CUSTO ESTA DE ACORDO C/ A TABELA
              #------------------------------------------------------
              message " (F17)Abandona"
              initialize ws.soccsttabvlr  to null
              let ws.cstqtdhor    = 00000
              let ws.cstqtdmin    = 00000
              let ws.soccstclcvlr = 00.00

              if param.checktab  =  "s"   then

                 if a_ctb11m07[arr_aux].socopgitmcst  >  00.00   then
                    call tabela_ctb11m07(param.soctrfvignum,
                                         param.socgtfcod,
                                         a_ctb11m07[arr_aux].soccstcod)
                              returning  ws.soccsttabvlr

                    if ws.soccsttabvlr  is null   then
                       next field socopgitmcst
                    end if

                    # CUSTO COM VALOR FIXO
                    #---------------------
                    if a_ctb11m07[arr_aux].soccstclccod  =  1               and
                       a_ctb11m07[arr_aux].socopgitmcst > ws.soccsttabvlr   then
                       error " Valor maior que a tabela --> ", ws.soccsttabvlr

                       # SO' PERMITE LIBERARACAO SE NIVEL 8
                       #------------------------------------
                       if g_issk.acsnivcod  <  8   then
                          message " Nivel de acesso nao permite liberacao!"
                          next field socopgitmcst
                       else
                          call cts08g01("C","S", "VALOR ADICIONAL MAIOR QUE O ",
                                                 "VALOR FIXO DA TABELA",
                                             "", "CONFIRMA PAGAMENTO ?")
                               returning ws.confirma

                          if ws.confirma = "N"  then
                             next field socopgitmcst
                          end if

                          let param.socconlibflg = "S"
                       end if
                    end if

                    # CUSTO COM VALOR VARIAVEL EM HORAS
                    #----------------------------------
                    if a_ctb11m07[arr_aux].soccstclccod  =  2   then
                       let a_ctb11m07[arr_aux].cstqtd    =
                           a_ctb11m07[arr_aux].socopgitmcst / ws.soccsttabvlr
                       let ws.cstqtdhor = a_ctb11m07[arr_aux].cstqtd
                       let ws.cstqtdmin = a_ctb11m07[arr_aux].cstqtd -
                                          ws.cstqtdhor

                       if ws.cstqtdmin  >  0   then
                       let ws.cstqtdmin = ws.cstqtdmin * 60 / 100
                       end if
                       let a_ctb11m07[arr_aux].cstqtd = ws.cstqtdhor +
                                                        ws.cstqtdmin
                    end if

                    # CUSTO COM VALOR VARIAVEL EM KM
                    #-------------------------------
                    if a_ctb11m07[arr_aux].soccstclccod  =  3   then
                       let ws.soccstclcvlr =
                           ws.soccsttabvlr * a_ctb11m07[arr_aux].cstqtd

                       if a_ctb11m07[arr_aux].socopgitmcst >
                                              ws.soccstclcvlr  then
                          error " Valor nao confere, pois nao pode ser superior a  --> ", ws.soccstclcvlr
                          next field socopgitmcst
                       end if
                    end if
                 end if

              end if

              display a_ctb11m07[arr_aux].cstqtd  to  s_ctb11m07[scr_aux].cstqtd

           on key(interrupt)
              exit input

           after row
              #Formatação do campo alterada para atendimento do chamado 100913299
              let a_ctb11m07[arr_aux].socopgitmcst = a_ctb11m07[arr_aux].socopgitmcst using "&&&&&&&&&&&&&&&.&&"
              let a_ctb11m07[arr_aux].cstqtd       = a_ctb11m07[arr_aux].cstqtd       using "&&&&&&&&"

              case ws.operacao
                 when "a"
                      let ws.achou = "n"
                      select *
                        from dbsmopgcst
                       where socopgnum    = param.socopgnum               and
                             socopgitmnum = param.socopgitmnum            and
                             soccstcod    = a_ctb11m07[arr_aux].soccstcod

                      if sqlca.sqlcode  =  0   then
                         let ws.achou = "s"
                      end if

                     if ws.achou                          = "n"  and
                        a_ctb11m07[arr_aux].socopgitmcst  >  0   then

                        # QUANDO FOR INCLUSAO DE ITEM E CUSTO, A INCLUSAO
                        # SERA' FEITA APOS A DIGITACAO COMPLETA DOS CUSTOS
                        #-------------------------------------------------
                        if param.operacao <> "i"   then
                           begin work
                             insert into dbsmopgcst
                                         (socopgnum,
                                          socopgitmnum,
                                          soccstcod,
                                          cstqtd,
                                          socopgitmcst)
                                  values (param.socopgnum,
                                          param.socopgitmnum,
                                          a_ctb11m07[arr_aux].soccstcod,
                                          a_ctb11m07[arr_aux].cstqtd,
                                          a_ctb11m07[arr_aux].socopgitmcst )
                           commit work
                        end if
                     end if

                     # QUANDO COLOCAR ZERO DELETA REGISTRO
                     #------------------------------------
                     if ws.achou  =  "s"   then
                        if a_ctb11m07[arr_aux].socopgitmcst = 0   then
                           begin work
                             delete from dbsmopgcst
                              where socopgnum    = param.socopgnum       and
                                    socopgitmnum = param.socopgitmnum    and
                                    soccstcod    = a_ctb11m07[arr_aux].soccstcod
                           commit work
                        else
                          # QUANDO VALOR DIFERENTE ATUALIZA
                          #------------------------------------
                          begin work
                            update dbsmopgcst set
                                    (cstqtd,
                                     socopgitmcst)
                                  = (a_ctb11m07[arr_aux].cstqtd,
                                     a_ctb11m07[arr_aux].socopgitmcst)
                              where socopgnum    = param.socopgnum       and
                                    socopgitmnum = param.socopgitmnum    and
                                    soccstcod    = a_ctb11m07[arr_aux].soccstcod
                          commit work
                        end if
                     end if

              end case

              # QUANDO DIGITAR O ULTIMO CUSTO, SAI DA TELA
              #-------------------------------------------
              if a_ctb11m07[arr_aux + 1].soccstcod   is null   then
                 let ws.socopgtotvlr = 0.00
                 let ws.soctotcst    = 0.00

                 call soma_ctb11m07(param.socopgitmvlr)
                      returning  ws.soctotcst
                 call ctb11m08()
                      returning  ws.socopgtotvlr

                 if ws.socopgtotvlr >  ws.soctotcst  then
                   error " Valor total (", ws.soctotcst using "&&&&&&&&&&&&&&&.&&", ") nao confere com valor digitado!"
                   exit input
                 end if

                 let ws.socdifitm =  0
                 if ws.socopgtotvlr <  ws.soctotcst  then
                    let ws.socdifitm =  ws.socopgtotvlr - ws.soctotcst
                    let ws.linhamsg  = "VALOR DIFERENCA R$ ",
                                       ws.socdifitm using "--,---.--"
                    call cts08g01("C","S",
                                      "VALOR DO ITEM INFORMADO ESTA A MENOR",
                                      "REGISTRA A DIFERENCA COMO UM DESCONTO ?",
                                      "", ws.linhamsg)
                               returning ws.confirma

                    if ws.confirma = "N"  then
                       exit input
                    else
                       #Formatação do campo alterada para atendimento do chamado 100913299
                       let ws.socdifitm = ws.socdifitm using "&&&&&&&&&&&&&&&.&&"

                       insert into dbsmopgcst (socopgnum,
                                               socopgitmnum,
                                               soccstcod,
                                               cstqtd,
                                               socopgitmcst)
                                       values (param.socopgnum,
                                               param.socopgitmnum,
                                               07 ,
                                               "",
                                               ws.socdifitm )

                       if sqlca.sqlcode <> 0   then
                          error "Erro (",sqlca.sqlcode,") na inclusao do desconto item!"
                          sleep 2
                          exit input
                       end if
                    end if
                 end if

                 if param.operacao = "i"   then
                    let ws.incitmok = "n"
                    select dbsmopg.socopgnum # CT 697796
                      into ws.socopgnum
                      from dbsmopgitm, dbsmopg
                     where dbsmopgitm.atdsrvnum = param.atdsrvnum and
                           dbsmopgitm.atdsrvano = param.atdsrvano and
                           dbsmopg.socopgnum    = dbsmopgitm.socopgnum          and
                           dbsmopg.socopgsitcod <> 8

                    if sqlca.sqlcode = 0    then
                       if param.socopgnum = ws.socopgnum   then
                          error " O.S. ja' cadastrada!"
                       else
                          error " O.S. ja' foi paga pela O.P. No. ", ws.socopgnum
                       end if
                       sleep 2
                       let int_flag = true
                       exit input
                    else
                       call item_ctb11m07(param.*)
                            returning param.socopgitmnum, ws.incitmok
                    end if
                 end if

                 let int_flag = true
                 exit input
              end if

              display a_ctb11m07[arr_aux].* to s_ctb11m07[scr_aux].*
              let ws.operacao = " "
     end input

     if int_flag    then
        exit while
     end if

 end while

 options insert key F1,
         delete key F2

 let int_flag = false
 close window w_ctb11m07

 let ws.soctotcst    = 0.00
 call soma_ctb11m07(param.socopgitmvlr)
      returning  ws.soctotcst

 if ws.socdifitm is not null  and
    ws.socdifitm <> 0         then
    let ws.soctotcst = ws.soctotcst + ws.socdifitm
 end if

 return param.nfsnum   , param.atdsrvnum   , param.atdsrvano   ,
        param.vlrfxacod, param.socopgitmvlr, param.socopgitmnum,
        ws.soctotcst   , param.socconlibflg, ws.incitmok       ,
        ws.socdifitm

end function  ###  ctb11m07

#--------------------------------------------------------------------
function item_ctb11m07(param2)
#--------------------------------------------------------------------
 define param2      record
    socopgnum       like dbsmopgitm.socopgnum,
    operacao        char(01),
    nfsnum          like dbsmopgitm.nfsnum,
    atdsrvnum       like dbsmopgitm.atdsrvnum,
    atdsrvano       like dbsmopgitm.atdsrvano,
    vlrfxacod       like dbsmopgitm.vlrfxacod,
    socopgitmvlr    like dbsmopgitm.socopgitmvlr,
    socconlibflg    like dbsmopgitm.socconlibflg,
    socopgitmnum    like dbsmopgitm.socopgitmnum,
    soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
    socgtfcod       like dbstgtfcst.socgtfcod,
    checktab        char(01)
 end record

 define ws2         record
    incitmok        char(01),
    retorno         smallint,
    mensagem        char(60)
 end record

 define arr_aux2    smallint


 initialize ws2.*   to null
 let ws2.incitmok = "n"

 select max(socopgitmnum)
   into param2.socopgitmnum
   from dbsmopgitm
  where socopgnum = param2.socopgnum

 if param2.socopgitmnum   is null   then
    let param2.socopgitmnum = 0
 end if
 let param2.socopgitmnum = param2.socopgitmnum + 1

#Formatação do campo alterada para atendimento do chamado 100913299
 let param2.socopgitmvlr = param2.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

 begin work
    # INCLUSAO DO ITEM
    #------------------
    insert into dbsmopgitm
                (socopgnum,
                 atdsrvnum,
                 atdsrvano,
                 socopgitmvlr,
                 nfsnum,
                 socopgitmnum,
                 vlrfxacod,
                 funmat,
                 socconlibflg)
         values (param2.socopgnum,
                 param2.atdsrvnum,
                 param2.atdsrvano,
                 param2.socopgitmvlr,
                 param2.nfsnum,
                 param2.socopgitmnum,
                 param2.vlrfxacod,
                 g_issk.funmat,
                 param2.socconlibflg)

    if sqlca.sqlcode <> 0   then
       error "Erro (",sqlca.sqlcode,") na inclusao do item!"
       initialize param2.socopgitmnum  to null
       sleep 3
       return
    end if

    # INCLUSAO DA FASE (DIGITADA)
    #----------------------------
    # PSI 221074 - BURINI

    call cts50g00_sel_etapa(param2.socopgnum, 3)
         returning ws2.retorno,
                   ws2.mensagem

    if  ws2.retorno = 2  then

        call cts50g00_insere_etapa(param2.socopgnum, 3, g_issk.funmat)
             returning ws2.retorno,
                       ws2.mensagem

        if ws2.retorno <> 1   then
           error ws2.mensagem
           initialize param2.socopgitmnum  to null
           sleep 3
           return
        end if
    else
        if  ws2.retorno = 1 then
            call cts50g00_atualiza_etapa(param2.socopgnum, 3, g_issk.funmat)
                 returning ws2.retorno,
                           ws2.mensagem

            if ws2.retorno <> 1   then
               error ws2.mensagem
               initialize param2.socopgitmnum  to null
               sleep 3
               return
            end if
        else
            error ws2.mensagem
        end if
    end if

     # INCLUSAO DOS CUSTOS DO ITEM
     #----------------------------
#   for arr_aux2 = 1  to  10
     for arr_aux2 = 1  to  20
         if a_ctb11m07[arr_aux2].socopgitmcst  >  0   then
            #Formatação do campo alterada para atendimento do chamado 100913299
            let a_ctb11m07[arr_aux2].socopgitmcst = a_ctb11m07[arr_aux2].socopgitmcst using "&&&&&&&&&&&&&&&.&&"
            let a_ctb11m07[arr_aux2].cstqtd       = a_ctb11m07[arr_aux2].cstqtd       using "&&&&&&&&"

            insert into dbsmopgcst
                        (socopgnum,
                         socopgitmnum,
                         soccstcod,
                         cstqtd,
                         socopgitmcst)
                 values (param2.socopgnum,
                         param2.socopgitmnum,
                         a_ctb11m07[arr_aux2].soccstcod,
                         a_ctb11m07[arr_aux2].cstqtd,
                         a_ctb11m07[arr_aux2].socopgitmcst )

            if sqlca.sqlcode <> 0   then
               error "Erro (",sqlca.sqlcode,") na inclusao do custo do item!"
               initialize param2.socopgitmnum  to null
               sleep 3
               return
            end if
         end if
     end for
 commit work

 let ws2.incitmok = "s"
 return  param2.socopgitmnum, ws2.incitmok

end function  ###  item_ctb11m07

#--------------------------------------------------------------------
function tabela_ctb11m07(param3)
#--------------------------------------------------------------------
 define param3      record
    soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum,
    socgtfcod       like dbstgtfcst.socgtfcod,
    soccstcod       like dbstgtfcst.soccstcod
 end record

 define ws3         record
    socgtfcstvlr    like dbstgtfcst.socgtfcstvlr
 end record


 initialize ws3.*  to null

 select dbstgtfcst.socgtfcstvlr
   into ws3.socgtfcstvlr
   from dbstgtfcst
  where dbstgtfcst.soctrfvignum  =  param3.soctrfvignum   and
        dbstgtfcst.socgtfcod     =  param3.socgtfcod      and
        dbstgtfcst.soccstcod     =  param3.soccstcod

 if sqlca.sqlcode <> 0   then
    error " Grupo tarifario/custo nao cadastrado --> ",param3.socgtfcod,"/",param3.soccstcod
 end if

 return ws3.socgtfcstvlr

end function  ###  tabela_ctb10m07

#--------------------------------------------------------------------
function soma_ctb11m07(param4)             # ACUMULA CUSTOS DIGITADOS
#--------------------------------------------------------------------

 define param4      record
    socopgitmvlr    like dbsmopgitm.socopgitmvlr
 end record

 define ws4         record
    soctotcst       like dbsmopgitm.socopgitmvlr
 end record

 define ws4_ind     smallint


 initialize ws4.*  to null
 let ws4.soctotcst = 0

#for ws4_ind = 1  to  10
 for ws4_ind = 1  to  20
     if a_ctb11m07[ws4_ind].soccstcod   is null    then
        exit for
     end if
     let ws4.soctotcst = ws4.soctotcst + a_ctb11m07[ws4_ind].socopgitmcst
 end for
 let ws4.soctotcst = ws4.soctotcst + param4.socopgitmvlr

 return ws4.soctotcst

end function  ###  soma_ctb10m07
