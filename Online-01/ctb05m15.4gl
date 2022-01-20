############################################################################
# Nome de Modulo: CTB05m15                                        Wagner   #
#                                                                          #
# Manutencao do valor e itens adicionais p/ RE                    Mar/2002 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 15/07/2002  PSI 15620-5  Wagner       Tratamento dos precos servicos RE. #
#--------------------------------------------------------------------------#
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção#
#                                       de mais de duas casas decimais.    #
############################################################################

  database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define d_ctb05m15  record
     vlrcstini       like datmservico.atdcstvlr,
     totcstadc       like datmservico.atdcstvlr,
     atdcstvlr       like datmservico.atdcstvlr
  end record

  define a_ctb05m15  array[10] of record
     soccstcod       like dbsmopgcst.soccstcod,
     soccstdes       like dbskcustosocorro.soccstdes,
     cstqtd          like dbsmopgcst.cstqtd,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     soccstclccod    like dbskcustosocorro.soccstclccod
  end record

#--------------------------------------------------------------------
function ctb05m15(param)
#--------------------------------------------------------------------
  define param       record
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano
  end record

  define ws          record
     totcstvlr       like datmservico.atdcstvlr,
     pgtdat          like datmservico.pgtdat   ,
     socopgnum       like dbsmopg.socopgnum    ,
     sqlca_preacp    integer,
     atdsrvorg       like datmservico.atdsrvorg,
     soccstexbseq    like dbskcustosocorro.soccstexbseq,
     operacao        char (01),
     confirma        char (01),
     flgsai          smallint,
     comando         char (800),
     socntzdes       like datksocntz.socntzdes,
     socntzcod       like datmsrvre.socntzcod,
     vlrsugerido     like dbsmopgitm.socopgitmvlr,
     vlrmaximo       like dbsmopgitm.socopgitmvlr,
     vlrdiferenc     like dbsksrvrmeprc.srvrmedifvlr,
     vlrmltdesc      like dbsksrvrmeprc.srvrmedscmltvlr,
     qtdsrv          smallint,   # (1-OK um srv)(2-demais srvs.)
     flgtab          smallint    # (1-tabela) (2-tabela inexistente)
  end record

  define arr_aux     smallint
  define scr_aux     smallint


  initialize d_ctb05m15  to null
  initialize a_ctb05m15  to null
  initialize ws.*        to null
  let arr_aux = 1

  #----------------------------------
  # Verifica SERVICO
  #----------------------------------
  select atdsrvorg, atdcstvlr, pgtdat
    into ws.atdsrvorg, d_ctb05m15.atdcstvlr, ws.pgtdat
    from datmservico
   where atdsrvnum = param.atdsrvnum
     and atdsrvano = param.atdsrvano

  if sqlca.sqlcode <> 0     and
     sqlca.sqlcode <> 100   then
     error " Erro (", sqlca.sqlcode, ") na leitura do servico. AVISE A INFORMATICA!"
     return
  else
     #----------------------------------
     # Verifica se SERVICO ja' pago
     #----------------------------------
     select dbsmopg.socopgnum
       into ws.socopgnum
       from dbsmopgitm, dbsmopg
      where dbsmopgitm.atdsrvnum = param.atdsrvnum
        and dbsmopgitm.atdsrvano = param.atdsrvano
        and dbsmopgitm.socopgnum = dbsmopg.socopgnum
        and dbsmopg.socopgsitcod <> 8

     if sqlca.sqlcode <> 0     and
        sqlca.sqlcode <> 100   then
        error " Erro (", sqlca.sqlcode, ") na leitura da O.P. AVISE A INFORMATICA!"
        return
     end if
  end if

  if ws.pgtdat     is not null   or
     ws.socopgnum  is not null   then
     error " Nao e' possivel fazer o acerto de valor para servico ja' pago!"
     return
  end if

  let ws.comando ="select dbskcustosocorro.soccstexbseq, ",
                  "       dbskcustosocorro.soccstdes, ",
                  "       dbskcustosocorro.soccstclccod, ",
                  "       dbskcustosocorro.soccstcod, ",
                  "       dbsmopgcst.cstqtd, ",
                  "       dbsmopgcst.socopgitmcst ",
                  "  from dbskcustosocorro, outer dbsmopgcst ",
                  " where dbskcustosocorro.soccstcod > 0 ",
                  "   and dbskcustosocorro.soctip    = 3 ",
                  "   and dbsmopgcst.socopgnum    = ? ",
                  "   and dbsmopgcst.socopgitmnum = ? ",
                  "   and dbsmopgcst.soccstcod  = dbskcustosocorro.soccstcod ",
                  "   and dbsmopgcst.atdsrvnum  = ? ",
                  "   and dbsmopgcst.atdsrvano  = ? ",
                  " order by dbskcustosocorro.soccstexbseq "
  prepare comando_aux1  from  ws.comando
  declare c_ctb05m15  cursor for  comando_aux1

  let ws.comando = "select datksocntz.socntzdes ",
                   "  from datmsrvre, datksocntz ",
                   " where datmsrvre.atdsrvnum  = ? ",
                   "   and datmsrvre.atdsrvano  = ? ",
                   "   and datksocntz.socntzcod = datmsrvre.socntzcod "
  prepare comando_aux2  from ws.comando
  declare c_datmsrvre cursor for comando_aux2

  open  c_datmsrvre using  param.atdsrvnum, param.atdsrvano
  fetch c_datmsrvre into   ws.socntzdes
  close c_datmsrvre

  # MONTA DADOS DA ORDEM DE PAGAMENTO
  #----------------------------------
  open window w_ctb05m15 at 08,18 with form "ctb05m15"
       attribute(form line first, border)

  display ws.socntzdes to socntzdes

  #----------------------------------------------------------------------
  #       PARA MONTAR CUSTOS DOS ITENS DA ORDEM DE PAGAMENTO : (c/tarifa)
  # -AGRUPA CUSTOS QUE ESTAO VIGENTES NA DATA DE ATENDIMENTO DO SERVICO
  # -CLASSIFICA POR ORDEM DE EXIBICAO DO CUSTO(PELO CADASTRO DE CUSTOS)
  # -MOSTRA O VALOR SE ESTE JA' FOI DIGITADO
  #----------------------------------------------------------------------
  open c_ctb05m15  using  param.atdsrvnum, param.atdsrvano,
                          param.atdsrvnum, param.atdsrvano

  foreach c_ctb05m15 into ws.soccstexbseq,
                          a_ctb05m15[arr_aux].soccstdes,
                          a_ctb05m15[arr_aux].soccstclccod,
                          a_ctb05m15[arr_aux].soccstcod,
                          a_ctb05m15[arr_aux].cstqtd,
                          a_ctb05m15[arr_aux].socopgitmcst

     if a_ctb05m15[arr_aux].socopgitmcst  is null   then
        let a_ctb05m15[arr_aux].socopgitmcst = 0.00
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 10   then
        error " Limite excedido! Tabela de custos com mais de 10 custos!"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)
  options insert key F40,
          delete key F45

  message " (F17)Abandona"

  while true

     #----------------------------------
     # Apura valores
     #----------------------------------
     select atdcstvlr
       into d_ctb05m15.atdcstvlr
       from datmservico
      where atdsrvnum = param.atdsrvnum
        and atdsrvano = param.atdsrvano

     if d_ctb05m15.atdcstvlr is null then
        let d_ctb05m15.atdcstvlr  = 0
     end if

     let d_ctb05m15.totcstadc  = 0
     for arr_aux = 1 to 20
         if a_ctb05m15[arr_aux].socopgitmcst is null then
            exit for
         else
            let d_ctb05m15.totcstadc  = d_ctb05m15.totcstadc +
                                        a_ctb05m15[arr_aux].socopgitmcst
         end if
     end for

     if d_ctb05m15.totcstadc is null then
        let d_ctb05m15.totcstadc  = 0
     end if

     call ctx15g00_vlrre(param.atdsrvnum, param.atdsrvano)
               returning ws.socntzcod , ws.vlrsugerido,
                         ws.vlrmaximo , ws.vlrdiferenc ,
                         ws.vlrmltdesc, ws.qtdsrv, ws.flgtab

     if d_ctb05m15.atdcstvlr = 0 then
        let d_ctb05m15.atdcstvlr = ws.vlrsugerido
     end if

     let d_ctb05m15.vlrcstini  = d_ctb05m15.atdcstvlr - d_ctb05m15.totcstadc

     display by name d_ctb05m15.vlrcstini
     display by name d_ctb05m15.totcstadc
     display by name d_ctb05m15.atdcstvlr

     let int_flag = false

     input by name d_ctb05m15.vlrcstini without defaults

        before field vlrcstini
           case ws.flgtab
             when 1  # PRESTADOR C/TABELA
                case ws.qtdsrv
                   when 1 error " Primeiro servico preco tabela cheio!"
                   when 2 error " ATENCAO: Servico multiplo desconto padrao de R$ ", ws.vlrmltdesc using "<<<&.&&"
                end case
             when 2  # PRESTADOR S/TABELA
                error " ATENCAO: Prestador sem tabela de preco!"
           end case
           display by name d_ctb05m15.vlrcstini attribute (reverse)

        after field vlrcstini
           display by name d_ctb05m15.vlrcstini
           if d_ctb05m15.vlrcstini  is null   or
              d_ctb05m15.vlrcstini  =  0.00   then
              error " Valor final deve ser informado!"
              next field vlrcstini
           end if
           if d_ctb05m15.vlrcstini  > 5000    then
              error " Valor digitado superior a R$ 5.000,00!"
              next field vlrcstini
           end if

        on key (interrupt)
           exit input

     end input

     if int_flag = true  then
        exit while
     end if

     input array a_ctb05m15 without defaults from s_ctb05m15.*
        before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
             let ws.operacao = "i"
             if arr_aux <= arr_count()  then
                let ws.operacao = "a"
             end if

           before insert
              let ws.operacao = "i"
              initialize a_ctb05m15[arr_aux].*  to null
              display a_ctb05m15[arr_aux].* to s_ctb05m15[scr_aux].*

           before field cstqtd
              case a_ctb05m15[arr_aux].soccstcod
                when  9 error " Digite somente 0 ou 1 !"
                when 10
                     if ws.flgtab = 1 then
                       error " Digite somente 0 ou 1 !"
                     else
                       error " Digite somente 0, 1, 2, 3 ou 4 !"
                     end if
                when 11 error " Qtde de Km!"
                otherwise next field socopgitmcst
              end case
              display a_ctb05m15[arr_aux].cstqtd  to
                      s_ctb05m15[scr_aux].cstqtd  attribute (reverse)

           after field cstqtd
              display a_ctb05m15[arr_aux].cstqtd  to
                      s_ctb05m15[scr_aux].cstqtd

              if fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 case a_ctb05m15[arr_aux].soccstcod
                   when  9
                      case a_ctb05m15[arr_aux].cstqtd
                         when 0 let a_ctb05m15[arr_aux].socopgitmcst = 0
                         when 1 let a_ctb05m15[arr_aux].socopgitmcst = 20
                         otherwise next field cstqtd
                      end case
                   when 10
                      if ws.flgtab = 1 then
                         case a_ctb05m15[arr_aux].cstqtd
                            when 0 let a_ctb05m15[arr_aux].socopgitmcst = 0
                            when 1
                               if ws.vlrdiferenc is not null and
                                  ws.vlrdiferenc <> 0        then
                                  let a_ctb05m15[arr_aux].socopgitmcst =
                                      ws.vlrdiferenc - (ws.vlrsugerido +
                                                        ws.vlrmltdesc)
                               end if
                            otherwise next field cstqtd
                         end case
                      else
                         case a_ctb05m15[arr_aux].cstqtd
                            when 0 let a_ctb05m15[arr_aux].socopgitmcst = 0
                            when 1 let a_ctb05m15[arr_aux].socopgitmcst = 10
                            when 2 let a_ctb05m15[arr_aux].socopgitmcst = 20
                            when 3 let a_ctb05m15[arr_aux].socopgitmcst = 30
                            when 4 let a_ctb05m15[arr_aux].socopgitmcst = 40
                            otherwise next field cstqtd
                         end case
                      end if
                   when 11
                      if a_ctb05m15[arr_aux].cstqtd is null or
                         a_ctb05m15[arr_aux].cstqtd < 0     then
                         let a_ctb05m15[arr_aux].cstqtd = 0
                         display a_ctb05m15[arr_aux].cstqtd  to
                                 s_ctb05m15[scr_aux].cstqtd
                      end if
                      if ws.flgtab = 1 then
                         let a_ctb05m15[arr_aux].socopgitmcst =
                            (a_ctb05m15[arr_aux].cstqtd - 60 ) * .5
                      else
                         let a_ctb05m15[arr_aux].socopgitmcst =
                            (a_ctb05m15[arr_aux].cstqtd - 100) * .5
                      end if
                      if a_ctb05m15[arr_aux].socopgitmcst < 0 then
                         let a_ctb05m15[arr_aux].socopgitmcst = 0
                      end if
                 end case
                 display a_ctb05m15[arr_aux].socopgitmcst  to
                         s_ctb05m15[scr_aux].socopgitmcst
              end if

           before field socopgitmcst
              if a_ctb05m15[arr_aux].soccstcod <= 11 then
                 continue input
              end if
              display a_ctb05m15[arr_aux].socopgitmcst  to
                      s_ctb05m15[scr_aux].socopgitmcst  attribute (reverse)

           after field socopgitmcst
              display a_ctb05m15[arr_aux].socopgitmcst  to
                      s_ctb05m15[scr_aux].socopgitmcst
              let a_ctb05m15[arr_aux].socopgitmcst = a_ctb05m15[arr_aux].socopgitmcst using "&&&&&&&&&&&&&&&.&&"


           on key(interrupt)
              exit input

           after row
              #-------------------------------------------
              # QUANDO DIGITAR O ULTIMO CUSTO, SAI DA TELA
              #-------------------------------------------
              if a_ctb05m15[arr_aux + 1].soccstcod is null then
                 let int_flag = true
                 exit input
              end if
              display a_ctb05m15[arr_aux].* to s_ctb05m15[scr_aux].*
              let ws.operacao = " "

     end input

     let d_ctb05m15.totcstadc  = 0
     for arr_aux = 1 to 20
         if a_ctb05m15[arr_aux].socopgitmcst is null then
            exit for
         else
            let d_ctb05m15.totcstadc  = d_ctb05m15.totcstadc +
                                      a_ctb05m15[arr_aux].socopgitmcst
         end if
     end for

     if d_ctb05m15.totcstadc is null then
        let d_ctb05m15.totcstadc  = 0
     end if

     let d_ctb05m15.atdcstvlr = d_ctb05m15.vlrcstini + d_ctb05m15.totcstadc

     display by name d_ctb05m15.vlrcstini
     display by name d_ctb05m15.totcstadc
     display by name d_ctb05m15.atdcstvlr

     while true
        let ws.flgsai = 0
        prompt " Confirma (S)im, (N)ao ou (A)bandona ? : " for ws.confirma
        let ws.confirma = upshift(ws.confirma)
        if ws.confirma = "A" then
           let ws.flgsai = 1
           exit while
        else
           if ws.confirma = "N" then
              exit while
           else
              if ws.confirma = "S" then
                 let ws.totcstvlr = 0
                 for arr_aux = 1 to 20
                     if a_ctb05m15[arr_aux].socopgitmcst is null then
                        exit for
                     else
                        let ws.totcstvlr = ws.totcstvlr +
                                           a_ctb05m15[arr_aux].socopgitmcst
                     end if
                 end for
                 if ws.totcstvlr > d_ctb05m15.atdcstvlr then
                    error "ATENCAO: A somatoria dos adicionais nao pode ser superior ao total do custo!"
                    let ws.flgsai = 0
                    exit while
                 end if
                 #----------------------------------
                 # Grava Servico e vlr inicial
                 #----------------------------------
                 update datmservico
                    set atdcstvlr = d_ctb05m15.atdcstvlr
                  where atdsrvnum = param.atdsrvnum
                    and atdsrvano = param.atdsrvano

                 if sqlca.sqlcode <> 0  then
                    error " Erro (", sqlca.sqlcode, ") na atualizacao do valor. AVISE A INFORMATICA!"
                 else
                    call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)
                 end if

                 #----------------------------------
                 # Grava adicionais do servico
                 #----------------------------------
                 delete from dbsmopgcst
                  where dbsmopgcst.socopgnum    = param.atdsrvnum
                    and dbsmopgcst.socopgitmnum = param.atdsrvano
                    and dbsmopgcst.atdsrvnum    = param.atdsrvnum
                    and dbsmopgcst.atdsrvano    = param.atdsrvano

                 for arr_aux = 1 to 20
                     if a_ctb05m15[arr_aux].socopgitmcst is null then
                        exit for
                     else
                        let a_ctb05m15[arr_aux].socopgitmcst = a_ctb05m15[arr_aux].socopgitmcst using "&&&&&&&&&&&&&&&.&&"
                        let a_ctb05m15[arr_aux].cstqtd       = a_ctb05m15[arr_aux].cstqtd       using "&&&&&&&&"
                        begin work
                         insert into dbsmopgcst
                                      (socopgnum,
                                       socopgitmnum,
                                       soccstcod,
                                       cstqtd,
                                       socopgitmcst,
                                       atdsrvnum,
                                       atdsrvano)
                               values (param.atdsrvnum,
                                       param.atdsrvano,
                                       a_ctb05m15[arr_aux].soccstcod,
                                       a_ctb05m15[arr_aux].cstqtd,
                                       a_ctb05m15[arr_aux].socopgitmcst,
                                       param.atdsrvnum,
                                       param.atdsrvano)

                           commit work
                     end if
                 end for
                 let ws.flgsai = 1
                 exit while
              end if
           end if
        end if
     end while

     if ws.flgsai = 1 then
        let int_flag = false
        exit while
     end if

 end while

 options insert key F1,
         delete key F2

 let int_flag = false
 message ""
 close window w_ctb05m15

end function  ###  ctb05m15

