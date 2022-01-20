#############################################################################
# Nome de Modulo: CTB04M07                                        Wagner    #
#                                                                           #
# Manutencao dos custos dos itens da ordem de pagamento - RE      Jan/2002  #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 08/03/2002  PSI 14295-6  Wagner       Carga dos adicionais antecipados.   #
#---------------------------------------------------------------------------#
# 15/07/2002  PSI 15620-5  Wagner       Tratamento precos servicos RE.      #
#---------------------------------------------------------------------------#
# 22/01/2003  CT  35939    Zyon         Valor Km Extra de 0,50 para 0,60    #
#---------------------------------------------------------------------------#
# 06/08/2007  CT  7080842  Burini       Correção no calculo de kilometragem #
#                                       (valores iguais ao do ctb25m01)     #
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel  #
#---------------------------------------------------------------------------#
# 14/10/2010  PGP_2010_00274 Robert lima Foi tratado o problema de inserção #
#                                       de mais de duas casas decimais.     #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define a_ctb04m07  array[20] of record
     soccstcod       like dbsmopgcst.soccstcod,
     soccstdes       like dbskcustosocorro.soccstdes,
     cstqtd          like dbsmopgcst.cstqtd,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     soccstclccod    like dbskcustosocorro.soccstclccod
  end record

#--------------------------------------------------------------------
function ctb04m07(param)
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
     atddat          like datmservico.atddat,
     soccstexbseq    like dbskcustosocorro.soccstexbseq,
     soccsttabvlr    like dbsmopgcst.socopgitmcst,
     socopgtotvlr    like dbsmopgitm.socopgitmvlr,
     soccstclcvlr    like dbsmopgitm.socopgitmvlr,
     socgtfcod       like dbskgtf.socgtfcod,
     cstqtdmin       dec(4,2),
     cstqtdhor       integer,
     operacao        char (01),
     confirma        char (01),
     achou           char (01),
     incitmok        char (01),   #--> incluiu item?(s/n)
     soctotcst       dec(15,5),
     socdifitm       dec(15,5),
     linhamsg        char (40),
     socntzcod       like datmsrvre.socntzcod,
     vlrsugerido     like dbsmopgitm.socopgitmvlr,
     vlrmaximo       like dbsmopgitm.socopgitmvlr,
     vlrdiferenc     like dbsksrvrmeprc.srvrmedifvlr,
     vlrmltdesc      like dbsksrvrmeprc.srvrmedscmltvlr,
     nrsrvs          smallint,   # (nro do servico executado)
     flgtab          smallint,   # (1-tabela) (2-tabela inexistente)
     comando         char (800),
     vlrprm          like dbsmopgitm.socopgitmvlr
  end record

  define arr_aux     smallint
  define scr_aux     smallint


  initialize a_ctb04m07  to null
  initialize ws.*        to null
  let arr_aux = 1

  if param.socopgitmnum is null or
     param.socopgitmnum  = 0    then
     select max(socopgitmnum)
       into param.socopgitmnum
       from dbsmopgitm
      where socopgnum = param.socopgnum

     if param.socopgitmnum   is null   then
        let param.socopgitmnum = 0
     end if
     let param.socopgitmnum = param.socopgitmnum + 1
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
                  "   and dbsmopgcst.soccstcod   = dbskcustosocorro.soccstcod ",
                  " order by dbskcustosocorro.soccstexbseq "
  prepare comando_aux1  from  ws.comando
  declare c_ctb04m07  cursor for  comando_aux1


  # MONTA DADOS DA ORDEM DE PAGAMENTO
  #----------------------------------
  open window w_ctb04m07 at 09,02 with form "ctb04m07"
       attribute(form line first)

  select atdsrvorg, atddat
    into ws.atdsrvorg, ws.atddat
    from datmservico
   where atdsrvnum = param.atdsrvnum
     and atdsrvano = param.atdsrvano

  display by name ws.atdsrvorg
  display by name param.atdsrvnum
  display by name param.atdsrvano

  call ctb04m07_veradic(param.socopgnum,param.socopgitmnum,
                        param.atdsrvnum,param.atdsrvano   )

  #----------------------------------------------------------------------
  #       PARA MONTAR CUSTOS DOS ITENS DA ORDEM DE PAGAMENTO : (c/tarifa)
  # -AGRUPA CUSTOS QUE ESTAO VIGENTES NA DATA DE ATENDIMENTO DO SERVICO
  # -CLASSIFICA POR ORDEM DE EXIBICAO DO CUSTO(PELO CADASTRO DE CUSTOS)
  # -MOSTRA O VALOR SE ESTE JA' FOI DIGITADO
  #----------------------------------------------------------------------
  if param.soctrfvignum   is not null   then
     open c_ctb04m07  using  param.soctrfvignum,
                             param.socopgnum,
                             param.socopgitmnum
  else
     open c_ctb04m07  using  param.socopgnum,
                             param.socopgitmnum
  end if

  foreach c_ctb04m07 into ws.soccstexbseq,
                          a_ctb04m07[arr_aux].soccstdes,
                          a_ctb04m07[arr_aux].soccstclccod,
                          a_ctb04m07[arr_aux].soccstcod,
                          a_ctb04m07[arr_aux].cstqtd,
                          a_ctb04m07[arr_aux].socopgitmcst

     if a_ctb04m07[arr_aux].socopgitmcst  is null   then
        let a_ctb04m07[arr_aux].socopgitmcst = 0.00
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 20   then
        error " Limite excedido! Tabela de custos com mais de 20 custos!"
        exit foreach
     end if
  end foreach

  call ctx15g00_vlrre(param.atdsrvnum, param.atdsrvano)
            returning ws.socntzcod , ws.vlrsugerido,
                      ws.vlrmaximo , ws.vlrdiferenc,
                      ws.vlrmltdesc, ws.nrsrvs, ws.flgtab

  call set_count(arr_aux-1)
  options insert key F40,
          delete key F45

  message " (F17)Abandona"

  while true
     let int_flag = false

     input array a_ctb04m07 without defaults from s_ctb04m07.*
        before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
             let ws.operacao = "i"
             if arr_aux <= arr_count()  then
                let ws.operacao = "a"
             end if

           before insert
              let ws.operacao = "i"
              initialize a_ctb04m07[arr_aux].*  to null
              display a_ctb04m07[arr_aux].* to s_ctb04m07[scr_aux].*

           before field cstqtd
              case a_ctb04m07[arr_aux].soccstcod
                when  9 error " Digite somente 0 ou 1!"
                when 10
                     if ws.flgtab = 1 then
                        error " Digite somente 0 ou 1 !"
                      else
                        error " Digite somente 0, 1, 2, 3 ou 4 !"
                      end if
                when 11 error " Qtde de Km!"
                otherwise next field socopgitmcst
              end case
              display a_ctb04m07[arr_aux].cstqtd  to
                      s_ctb04m07[scr_aux].cstqtd  attribute (reverse)

           after field cstqtd
              display a_ctb04m07[arr_aux].cstqtd  to
                      s_ctb04m07[scr_aux].cstqtd

              if fgl_lastkey() <> fgl_keyval("up")   and
                 fgl_lastkey() <> fgl_keyval("left") then
                 case a_ctb04m07[arr_aux].soccstcod
                   when  9
                      case a_ctb04m07[arr_aux].cstqtd
                         when 0 let a_ctb04m07[arr_aux].socopgitmcst = 0
                         when 1 let a_ctb04m07[arr_aux].socopgitmcst = 20
                         otherwise next field cstqtd
                      end case
                   when 10
                      if ws.flgtab = 1 then
                         case a_ctb04m07[arr_aux].cstqtd
                            when 0 let a_ctb04m07[arr_aux].socopgitmcst = 0
                            when 1
                               if ws.vlrdiferenc is not null and
                                  ws.vlrdiferenc <> 0        then
                                  let a_ctb04m07[arr_aux].socopgitmcst =
                                      ws.vlrdiferenc - (ws.vlrsugerido +
                                                        ws.vlrmltdesc)
                               end if
                            otherwise next field cstqtd
                         end case
                      else
                         case a_ctb04m07[arr_aux].cstqtd
                            when 0 let a_ctb04m07[arr_aux].socopgitmcst = 0
                            when 1 let a_ctb04m07[arr_aux].socopgitmcst = 10
                            when 2 let a_ctb04m07[arr_aux].socopgitmcst = 20
                            when 3 let a_ctb04m07[arr_aux].socopgitmcst = 30
                            when 4 let a_ctb04m07[arr_aux].socopgitmcst = 40
                            otherwise next field cstqtd
                         end case
                      end if
                   when 11
                      if a_ctb04m07[arr_aux].cstqtd is null or
                         a_ctb04m07[arr_aux].cstqtd < 0     then
                         let a_ctb04m07[arr_aux].cstqtd = 0
                         display a_ctb04m07[arr_aux].cstqtd  to
                                 s_ctb04m07[scr_aux].cstqtd
                      end if
                      #-- 22/01/2003 --> A partir de 15/01/2003 o km excedente passa de R$ 0,50 para R$ 0,60
                      if ws.flgtab = 1 then
                          if ws.atddat >= "15/01/2003" then
                              let a_ctb04m07[arr_aux].socopgitmcst =
                                 (a_ctb04m07[arr_aux].cstqtd - 40 ) * .85 # CT 7080842
                          else
                              let a_ctb04m07[arr_aux].socopgitmcst =
                                 (a_ctb04m07[arr_aux].cstqtd - 60 ) * .5
                          end if
                      else
                          if ws.atddat >= "15/01/2003" then
                              let a_ctb04m07[arr_aux].socopgitmcst =
                                 (a_ctb04m07[arr_aux].cstqtd - 40) * .85 # CT 7080842
                          else
                              let a_ctb04m07[arr_aux].socopgitmcst =
                                 (a_ctb04m07[arr_aux].cstqtd - 100) * .5
                          end if
                      end if
                      #-- 22/01/2003 <--
                      if a_ctb04m07[arr_aux].socopgitmcst < 0 then
                         let a_ctb04m07[arr_aux].socopgitmcst = 0
                      end if
                 end case
                 ### para que o valor não fique com mais de duas casas decimais- Beatriz Araujo
                 let a_ctb04m07[arr_aux].socopgitmcst = a_ctb04m07[arr_aux].socopgitmcst using "&&,&&&,&&&,&&&.&&" 
                 ### Fim
                 display a_ctb04m07[arr_aux].socopgitmcst  to
                         s_ctb04m07[scr_aux].socopgitmcst
              end if

           before field socopgitmcst
              if a_ctb04m07[arr_aux].soccstcod <= 11 then
                 continue input
  #              next field soccstclccod
              end if
              display a_ctb04m07[arr_aux].socopgitmcst  to
                      s_ctb04m07[scr_aux].socopgitmcst  attribute (reverse)
                      
              if a_ctb04m07[arr_aux].soccstcod = 23 or a_ctb04m07[arr_aux].soccstcod = 24 then
                 let ws.vlrprm = a_ctb04m07[arr_aux].socopgitmcst
              end if        
                      
                      

           after field socopgitmcst
              display a_ctb04m07[arr_aux].socopgitmcst  to
                      s_ctb04m07[scr_aux].socopgitmcst
                      
               let a_ctb04m07[arr_aux].socopgitmcst = a_ctb04m07[arr_aux].socopgitmcst using "&&,&&&,&&&,&&&.&&" 

   #          if fgl_lastkey() = fgl_keyval("left")  then
   #              if a_ctb04m07[arr_aux].soccstclccod  <>  3   then
   #                 error " Para este custo a quantidade nao e' informada!"
   #                 next field  socopgitmcst
   #              end if
   #              next field  cstqtd
   #           end if
                 
               if a_ctb04m07[arr_aux].soccstcod = 23 or a_ctb04m07[arr_aux].soccstcod = 24 then
                 if ws.vlrprm <> a_ctb04m07[arr_aux].socopgitmcst then
                    let a_ctb04m07[arr_aux].socopgitmcst = ws.vlrprm
                    error " Valor Premio nao pode ser alterado!"
                    next field socopgitmcst
                 end if
              end if  
   

           on key(interrupt)
              exit input

           after row
              #Formatação do campo alterada para atendimento do chamado 100913299
              let a_ctb04m07[arr_aux].socopgitmcst = a_ctb04m07[arr_aux].socopgitmcst using "&&&&&&&&&&&&&&&.&&"
              let a_ctb04m07[arr_aux].cstqtd = a_ctb04m07[arr_aux].cstqtd using "&&&&&&&&"
              
              case ws.operacao
                 when "a"
                      select socopgnum
                        from dbsmopgcst
                       where socopgnum    = param.socopgnum               and
                             socopgitmnum = param.socopgitmnum            and
                             soccstcod    = a_ctb04m07[arr_aux].soccstcod

                        if sqlca.sqlcode = notfound  then
                           begin work
                             insert into dbsmopgcst
                                         (socopgnum,
                                          socopgitmnum,
                                          soccstcod,
                                          cstqtd,
                                          socopgitmcst)
                                  values (param.socopgnum,
                                          param.socopgitmnum,
                                          a_ctb04m07[arr_aux].soccstcod,
                                          a_ctb04m07[arr_aux].cstqtd,
                                          a_ctb04m07[arr_aux].socopgitmcst )
                           commit work
                        else
                          begin work
                            update dbsmopgcst set
                                    (cstqtd,
                                     socopgitmcst)
                                  = (a_ctb04m07[arr_aux].cstqtd,
                                     a_ctb04m07[arr_aux].socopgitmcst)
                              where socopgnum    = param.socopgnum       and
                                    socopgitmnum = param.socopgitmnum    and
                                    soccstcod    = a_ctb04m07[arr_aux].soccstcod
                           commit work
                        end if
              end case

              # QUANDO DIGITAR O ULTIMO CUSTO, SAI DA TELA
              #-------------------------------------------
              if a_ctb04m07[arr_aux + 1].soccstcod is null then  #or
                 #a_ctb04m07[arr_aux].soccstcod       = 13      then
                 let int_flag = true
                 let ws.socopgtotvlr = 0.00
                 let ws.soctotcst    = 0.00
                 exit input
              end if

              display a_ctb04m07[arr_aux].* to s_ctb04m07[scr_aux].*
              let ws.operacao = " "
     end input

     if int_flag    then
        exit while
     end if

 end while

 options insert key F1,
         delete key F2

 let int_flag = false
 message ""
 close window w_ctb04m07

 let ws.soctotcst    = 0.00
 call soma_ctb04m07(param.socopgitmvlr)
      returning  ws.soctotcst

 let ws.socdifitm = ws.soctotcst - param.socopgitmvlr

 return param.nfsnum   , param.atdsrvnum   , param.atdsrvano   ,
        param.vlrfxacod, param.socopgitmvlr, param.socopgitmnum,
        ws.soctotcst   , param.socconlibflg, ws.incitmok       ,
        ws.socdifitm

end function  ###  ctb04m07

#--------------------------------------------------------------------
function item_ctb04m07(param2)
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
 
 define  ws record
                erro smallint,
                msg1 char(50)
            end record

 define ws2         record
    incitmok        char(01)
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
    
    #----------------------------#
    # INCLUSAO DA FASE (DIGITADA)#
    #----------------------------#
    
    # PSI 221074 - BURINI
    call cts50g00_sel_etapa(param2.socopgnum, 3)
         returning ws.erro , ws.msg1

    if  ws.erro = 2  then
        
        call cts50g00_insere_etapa(param2.socopgnum, 3, g_issk.funmat)
             returning ws.erro , ws.msg1
             
        if  ws.erro <> 1 then
            display ws.msg1
        end if
    else
        if  ws.erro = 1 then
        
            call cts50g00_atualiza_etapa(param2.socopgnum, 3, g_issk.funmat)
                 returning ws.erro , ws.msg1
                 
            if  ws.erro <> 1 then     
                display ws.msg1       
            end if                    
                                            
        end if
    end if
    commit work    

    #select socopgnum from dbsmopgfas
    # where socopgnum    = param2.socopgnum    and
    #       socopgfascod = 3
    #
    #if sqlca.sqlcode = notfound  then
    #   insert into dbsmopgfas
    #              (socopgnum,
    #               socopgfascod,
    #               socopgfasdat,
    #               socopgfashor,
    #               funmat)
    #       values (param2.socopgnum,
    #               3,
    #               today,
    #               current hour to minute,
    #               g_issk.funmat)
    #
    #   if sqlca.sqlcode <> 0   then
    #      error "Erro (",sqlca.sqlcode,") na inclusao da fase!"
    #      initialize param2.socopgitmnum  to null
    #      sleep 3
    #      return
    #   end if
    #end if

     # INCLUSAO DOS CUSTOS DO ITEM
     #----------------------------
     for arr_aux2 = 1  to  20
         #Formatação do campo alterada para atendimento do chamado 100913299
         let a_ctb04m07[arr_aux2].socopgitmcst = a_ctb04m07[arr_aux2].socopgitmcst using "&&&&&&&&&&&&&&&.&&"
         let a_ctb04m07[arr_aux2].cstqtd       = a_ctb04m07[arr_aux2].cstqtd       using "&&&&&&&&"
               
         if a_ctb04m07[arr_aux2].socopgitmcst  >  0   then
            insert into dbsmopgcst
                        (socopgnum,
                         socopgitmnum,
                         soccstcod,
                         cstqtd,
                         socopgitmcst)
                 values (param2.socopgnum,
                         param2.socopgitmnum,
                         a_ctb04m07[arr_aux2].soccstcod,
                         a_ctb04m07[arr_aux2].cstqtd,
                         a_ctb04m07[arr_aux2].socopgitmcst )

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

end function  ###  item_ctb04m07

#--------------------------------------------------------------------
function soma_ctb04m07(param4)             # ACUMULA CUSTOS DIGITADOS
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

 for ws4_ind = 1  to  20
     if a_ctb04m07[ws4_ind].soccstcod   is null    then
        exit for
     end if
     let ws4.soctotcst = ws4.soctotcst + a_ctb04m07[ws4_ind].socopgitmcst
 end for
 let ws4.soctotcst = ws4.soctotcst + param4.socopgitmvlr

 return ws4.soctotcst

end function  ###  soma_ctb04m07

#--------------------------------------------------------------------
function ctb04m07_veradic(param5)
#--------------------------------------------------------------------
  define param5      record
     socopgnum       like dbsmopgitm.socopgnum,
     socopgitmnum    like dbsmopgitm.socopgitmnum,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano
  end record

  define ws5         record
     soccstcod       like dbsmopgcst.soccstcod,
     cstqtd          like dbsmopgcst.cstqtd,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     count           smallint
  end record

  let ws5.count = 0
  select count(*)
    into ws5.count
    from dbsmopgcst
   where dbsmopgcst.socopgnum    = param5.socopgnum
     and dbsmopgcst.socopgitmnum = param5.socopgitmnum

   if ws5.count is not null and
      ws5.count <> 0        then
      # OP custo ja' carregado
   else
      let ws5.count = 0
      select count(*)
        into ws5.count
        from dbsmopgcst
       where dbsmopgcst.socopgnum    = param5.atdsrvnum
         and dbsmopgcst.socopgitmnum = param5.atdsrvano
         and dbsmopgcst.atdsrvnum    = param5.atdsrvnum
         and dbsmopgcst.atdsrvano    = param5.atdsrvano

       if ws5.count is not null and
          ws5.count <> 0        then

          declare c_veradic cursor for
           select soccstcod, socopgitmcst, cstqtd
             from dbsmopgcst
            where dbsmopgcst.socopgnum    = param5.atdsrvnum
              and dbsmopgcst.socopgitmnum = param5.atdsrvano
              and dbsmopgcst.atdsrvnum    = param5.atdsrvnum
              and dbsmopgcst.atdsrvano    = param5.atdsrvano

          foreach c_veradic into ws5.soccstcod, ws5.socopgitmcst, ws5.cstqtd
              #Formatação do campo alterada para atendimento do chamado 100913299
              let ws5.socopgitmcst = ws5.socopgitmcst using "&&&&&&&&&&&&&&&.&&"
              let ws5.cstqtd       = ws5.cstqtd       using "&&&&&&&&"               
              
              insert into dbsmopgcst (socopgnum,
                                      socopgitmnum,
                                      soccstcod,
                                      cstqtd,
                                      socopgitmcst,
                                      atdsrvnum,
                                      atdsrvano)
                              values (param5.socopgnum,
                                      param5.socopgitmnum,
                                      ws5.soccstcod,
                                      ws5.cstqtd,
                                      ws5.socopgitmcst,
                                      " "," ")
          end foreach
       end if
   end if

end function  ### ctb04m07_veradic
