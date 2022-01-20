#############################################################################
# Nome do Modulo: CTC20M04                                    Sergio Burini #
#                                                                PSI 229784 #
# CADASTRO DE GRUPOS DE SERVIÇOS X CRITERIOS.                      NOV/2008 #
#############################################################################
# ALTERACOES:                                                               #
# DATA        SOLICITACAO RESPONSAVEL  DESCRICAO                            #
# 31/08/2010  PSI 258610  Fabio Costa  Incluir opcao "Tolerancia"           #
#---------------------------------------------------------------------------#

database porto

    globals "/homedsa/projetos/geral/globals/glct.4gl"

    define ma_entrada array[100] of record
                          bnfcrtcod like dpakprtbnfgrpcrt.bnfcrtcod,
                          bnfcrtdes like dpakprtbnfcrt.bnfcrtdes,
                          atldat    like dpakprtbnfgrpcrt.atldat,
                          funnom    like isskfunc.funnom
                      end record

    define mr_aux record
                          bnfcrtcod like dpakprtbnfgrpcrt.bnfcrtcod,
                          bnfcrtdes like dpakprtbnfcrt.bnfcrtdes,
                          atldat    like dpakprtbnfgrpcrt.atldat,
                          funnom    like isskfunc.funnom
                      end record

    define mr_param record
                          prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod,
                          prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes
                      end record
    define m_confirma char(01)

    define m_cur         smallint,
           m_src         smallint

#---------------------------#
 function ctc20m04_prepare()
#---------------------------#

    define l_sql char(1000)

    let l_sql = "select bnfcrtcod, ",
                      " atldat, ",
                      " atlusr ",
                 " from dpakprtbnfgrpcrt ",
                " where prtbnfgrpcod = ? ",
                " order by bnfcrtcod "

    prepare pcctc20m04_01 from l_sql
    declare cqctc20m04_01 cursor for pcctc20m04_01

    let l_sql = "select bnfcrtdes ",
                 " from dpakprtbnfcrt ",
                " where bnfcrtcod = ? "

    prepare pcctc20m04_02 from l_sql
    declare cqctc20m04_02 cursor for pcctc20m04_02

    let l_sql = "select 1 ",
                 " from dpakprtbnfgrpcrt ",
                " where bnfcrtcod    = ? ",
                  " and prtbnfgrpcod = ? "

    prepare pcctc20m04_04 from l_sql
    declare cqctc20m04_04 cursor for pcctc20m04_04

    let l_sql = "insert into dpakprtbnfgrpcrt values (?,?,?,?)"

    prepare pcctc20m04_05 from l_sql

    let l_sql = "delete from dpakprtbnfgrpcrt ",
                " where prtbnfgrpcod = ? and ",
                "       bnfcrtcod = ?"

    prepare pcctc20m04_06 from l_sql

    let l_sql = "select distinct 1 ",
                  " from dpakbnfvlrfxa ",
                 " where prtbnfgrpcod  = ? ",
                   " and bnfcrtcod     = ? "

     prepare pcctc20m04_07 from l_sql
     declare cctc20m04_07 scroll cursor for pcctc20m04_07

     let l_sql = "delete from dpakbnfvlrfxa ",
                 " where prtbnfgrpcod  = ? ",
                 "   and bnfcrtcod     = ? "

    prepare pcctc20m04_08 from l_sql

    let l_sql = "select distinct 1 ",
                 " from dpakprtbnfcrt ",
                " where bnfcrtcod = ? ",
                "   and crttip = 'C'"
    prepare pcctc20m04_09 from l_sql
    declare cqctc20m04_09 scroll cursor for pcctc20m04_09

    let l_sql = "select distinct 1 ",
                  "  from dpakprtbnfgrpcrt ",
                  " where prtbnfgrpcod = ? and ",
                  "       bnfcrtcod = ?"
    prepare pctc20m04_10 from l_sql
    declare cctc20m04_10 scroll cursor for pctc20m04_10


 end function

#------------------------#
 function ctc20m04(param)
#------------------------#

  define param record
                   prtbnfgrpcod like dpaksrvgrp.prtbnfgrpcod,
                   prtbnfgrpdes like dpaksrvgrp.prtbnfgrpdes,
                   atldat       like dpaksrvgrp.atldat   ,
                   atlusr       like dpaksrvgrp.atlusr   ,
                   funnom       like isskfunc.funnom
               end record

  define lr_retorno record
                        erro       smallint,
                        mensagem   char(60)
                    end record

  define tecla         smallint,
         l_flag_insert smallint,
         l_arr_count   smallint,
         l_status      smallint,
         l_flag        smallint,
         l_flag_novo   smallint,
         l_bnfcrtcod   like dpakprtbnfgrpcrt.bnfcrtcod

  let mr_param.prtbnfgrpcod = param.prtbnfgrpcod
  let mr_param.prtbnfgrpdes = param.prtbnfgrpdes

  open window w_ctc20m04 at 4,2 with form "ctc20m04"
       attribute(form line first)

  call ctc20m04_prepare()


  let l_flag_insert = false
  let int_flag = false

  {options
   delete key F13}
  while true

      call ctc20m04_carrega_array()
      input array ma_entrada without defaults from s_ctc20m04.*

          before input
             display mr_param.prtbnfgrpdes to titulo

          before row
             let l_arr_count = arr_count()
             let m_cur = arr_curr()
             let m_src = scr_line()
             let l_bnfcrtcod = ma_entrada[m_cur].bnfcrtcod

          before delete
             call cts08g01("C","F"
                          ,"","CONFIRMA A EXCLUSAO DO CRITERIO DO GRUPO DE SERVICO","SELECIONADO ?","")
            returning m_confirma
            let l_flag_insert = false
            if  m_confirma = "S" then

               if  ma_entrada[m_cur].bnfcrtcod is not null and
                   ma_entrada[m_cur].bnfcrtcod <> " " then

                   open cctc20m04_07 using mr_param.prtbnfgrpcod,
                                           ma_entrada[m_cur].bnfcrtcod
                   fetch cctc20m04_07 into l_status

                   if  sqlca.sqlcode = notfound then
                      let l_flag = false
                   else
                      let l_flag = true
                   end if
               else
                   let l_flag = false
               end if

               if  l_flag then
                  let m_confirma = "N"
                   call cts08g01("C","F",
                                 "EXISTEM RELACIONAMENTO PARA ESSE",
                                 "GRUPO. A EXCLUSAO CONSEQUENTEMENTE",
                                 "ELIMINARA ESSES REGISTROS.",
                                 "CONTINUAR ASSIM MESMO ?")
                      returning m_confirma

                  if  m_confirma = "S" then
                     execute pcctc20m04_08 using mr_param.prtbnfgrpcod,
                                                 ma_entrada[m_cur].bnfcrtcod
                     if  sqlca.sqlcode <> 0 then
                                 error "Erro execute pcctc20m04_08 : ", sqlca.sqlcode
                     end if
                  end if
               end if
               if  m_confirma = "S" then

                  execute pcctc20m04_06 using mr_param.prtbnfgrpcod,
                                              ma_entrada[m_cur].bnfcrtcod
                  if  sqlca.sqlcode <> 0 then
                     error 'Problema no DELETE da tabela dpakprtbnfgrpcrt : ', sqlca.sqlcode

                  end if
               end if
            else
               display ma_entrada[m_cur].bnfcrtcod to s_ctc20m04[m_src].bnfcrtcod
               exit input
            end if

          before insert
             let l_arr_count = arr_count()
             if l_arr_count > 100 then
                 error "O numero de registros ultrapassou o tamanho do array. Favor contatar a informatica"
             end if
             if fgl_lastkey() = 2014 then
                 let l_flag_insert = true
             end if

          before field bnfcrtcod
             display ma_entrada[m_cur].bnfcrtcod to s_ctc20m04[m_src].bnfcrtcod
                attribute(reverse)
             let l_bnfcrtcod = ma_entrada[m_cur].bnfcrtcod
             if  l_bnfcrtcod is null or
                 l_bnfcrtcod = " " then
                 let l_bnfcrtcod = 0
             end if
             let l_flag_novo = true
             initialize mr_aux.* to null
             if  ma_entrada[m_cur].bnfcrtcod is not null and
                 ma_entrada[m_cur].bnfcrtcod <> " " then
                 let l_flag_novo = false
                 let mr_aux.* = ma_entrada[m_cur].*
             end if

          after field bnfcrtcod
             if l_flag_novo = false and
                (mr_aux.bnfcrtcod <> ma_entrada[m_cur].bnfcrtcod or
                (ma_entrada[m_cur].bnfcrtcod is null or
                 ma_entrada[m_cur].bnfcrtcod = " ")) and
                 l_flag_insert = false then

                 error "Para inserir Pressione <F1>"
                 let ma_entrada[m_cur].* = mr_aux.*
                 next field bnfcrtcod
             end if
             display ma_entrada[m_cur].bnfcrtcod to s_ctc20m04[m_src].bnfcrtcod
             if  ma_entrada[m_cur].bnfcrtcod is not null and
                 ma_entrada[m_cur].bnfcrtcod <> " " then
                 if  l_bnfcrtcod <> ma_entrada[m_cur].bnfcrtcod or l_flag_insert = true then
                     if  not ctc20m04_verific_array(m_cur,ma_entrada[m_cur].bnfcrtcod) then
                         open cqctc20m04_02 using ma_entrada[m_cur].bnfcrtcod
                         fetch cqctc20m04_02 into ma_entrada[m_cur].bnfcrtdes

                         case sqlca.sqlcode
                            when 0
                                let ma_entrada[m_cur].atldat = today
                                call cty08g00_nome_func(1,g_issk.usrcod,'F')
                                     returning lr_retorno.erro,
                                               lr_retorno.mensagem,
                                               ma_entrada[m_cur].funnom
                                display ma_entrada[m_cur].bnfcrtdes to s_ctc20m04[m_src].bnfcrtdes
                                display ma_entrada[m_cur].atldat    to s_ctc20m04[m_src].atldat
                                display ma_entrada[m_cur].funnom    to s_ctc20m04[m_src].funnom
                                call ctc20m04_incluir()

                                let l_flag_insert = false

                            when 100
                                error 'Criterio nao encontrado.'
                                next field bnfcrtcod
                            otherwise
                                error 'Problema cqctc20m04_02 erro: ', sqlca.sqlcode
                         end case
                     else
                         let ma_entrada[m_cur].bnfcrtcod = ""
                         let ma_entrada[m_cur].bnfcrtdes = ""
                         let ma_entrada[m_cur].atldat = ""
                         let ma_entrada[m_cur].funnom = ""
                         display ma_entrada[m_cur].* to s_ctc20m04[m_cur].*
                         error 'Criterio já cadastrado para esse grupo.'
                         next field bnfcrtcod
                     end if
                 end if
             else
                 if l_flag_insert = false and fgl_lastkey() = fgl_keyval("UP")  then

                 else
                      if  fgl_lastkey() = fgl_keyval("DOWN")   or
                          fgl_lastkey() = fgl_keyval("RIGHT")  or
                          fgl_lastkey() = fgl_keyval("RETURN") or l_flag_insert then


                          call ofgrc001_popup(10,
                                              2,
                                              "CRITERIOS DE BONIFICACAO",
                                              "CODIGO",
                                              "DESCRICAO",
                                              "N",
                                              "select bnfcrtcod, bnfcrtdes from dpakprtbnfcrt",
                                              "",
                                              "X")
                          returning lr_retorno.erro,
                                    ma_entrada[m_cur].bnfcrtcod,
                                    ma_entrada[m_cur].bnfcrtdes

                          if  not ctc20m04_verific_array(m_cur,ma_entrada[m_cur].bnfcrtcod) then
                              open cqctc20m04_02 using ma_entrada[m_cur].bnfcrtcod
                              fetch cqctc20m04_02 into ma_entrada[m_cur].bnfcrtdes

                              case sqlca.sqlcode
                                 when 0
                                     let ma_entrada[m_cur].atldat = today
                                     call cty08g00_nome_func(1,g_issk.usrcod,'F')
                                          returning lr_retorno.erro,
                                                    lr_retorno.mensagem,
                                                    ma_entrada[m_cur].funnom
                                     display ma_entrada[m_cur].bnfcrtdes to s_ctc20m04[m_src].bnfcrtdes
                                     display ma_entrada[m_cur].atldat    to s_ctc20m04[m_src].atldat
                                     display ma_entrada[m_cur].funnom    to s_ctc20m04[m_src].funnom
                                     call ctc20m04_incluir()
                                     let l_flag_insert = false
                                 when 100
                                     error 'Criterio nao encontrado.'
                                     next field bnfcrtcod
                                 otherwise
                                     error 'Problema cqctc20m04_02 erro: ', sqlca.sqlcode
                              end case
                          else

                              let ma_entrada[m_cur].bnfcrtcod = ""
                              let ma_entrada[m_cur].bnfcrtdes = ""
                              let ma_entrada[m_cur].atldat = ""
                              let ma_entrada[m_cur].funnom = ""
                              display ma_entrada[m_cur].* to s_ctc20m04[m_cur].*

                              error 'Criterio já cadastrado para esse grupo.'
                              next field bnfcrtcod
                          end if
                     end if
                 end if
             end if

          # digitacao da faixa de valores para o criterio
          on key (f6)
              let l_flag = false
              open cqctc20m04_09 using ma_entrada[m_cur].bnfcrtcod
              fetch cqctc20m04_09 into l_status

              if  sqlca.sqlcode = 0 then
                   let l_flag = true
              end if
              if  l_flag then
                  error " Tipo do critério é CREDENCIAL, seus valores não podem ser apresentados! "
              else
                  if  ma_entrada[m_cur].bnfcrtcod is not null then
                      call ctc20m05(mr_param.prtbnfgrpcod, mr_param.prtbnfgrpdes,
                                    ma_entrada[m_cur].bnfcrtcod, ma_entrada[m_cur].bnfcrtdes)
                  end if
             end if
             
          # digitacao da tolerancia para o criterio
          on key (f7)
              let l_flag = false
              
              whenever error continue
              
              open cqctc20m04_09 using ma_entrada[m_cur].bnfcrtcod
              fetch cqctc20m04_09 into l_status
              let l_flag = sqlca.sqlcode
              close cqctc20m04_09
              
              whenever error stop
              
              if l_flag = 0
                 then
                 error " Tipo do critério é CREDENCIAL, seus valores não podem ser apresentados! "
              else
                 if l_flag != 100
                    then
                    error ' Não foi possível identificar o critério, erro: ', l_flag
                 else
                    if ma_entrada[m_cur].bnfcrtcod is not null
                       then
                       call ctc20m08(mr_param.prtbnfgrpcod      , 
                                     mr_param.prtbnfgrpdes      ,
                                     ma_entrada[m_cur].bnfcrtcod,
                                     ma_entrada[m_cur].bnfcrtdes)
                    end if
                 end if
             end if

      end input
      
      if int_flag  then
          let int_flag = false
          exit while
      end if
      
  end while

  close window w_ctc20m04

end function


#---------------------------#
 function ctc20m04_incluir()
#---------------------------#

     define l_status smallint,
            l_flag smallint,
            l_bnfcrtcod smallint
     let l_flag = false
     open cctc20m04_10 using mr_param.prtbnfgrpcod,
                              ma_entrada[m_cur].bnfcrtcod
     fetch cctc20m04_10 into l_status

     if  sqlca.sqlcode = 0 then
         let l_flag = true
     end if
     if  not l_flag then
         execute pcctc20m04_05 using ma_entrada[m_cur].bnfcrtcod,
                                     mr_param.prtbnfgrpcod,
                                     ma_entrada[m_cur].atldat,
                                     g_issk.usrcod
         if  sqlca.sqlcode <> 0 then
             error "Problema na inclusao dos parametros", sqlca.sqlcode
         end if

     else
         error "Registro nao encontrado"
     end if



 end function

#---------------------------------#
 function ctc20m04_carrega_array()
#---------------------------------#

    define lr_entrada record
                          bnfcrtcod like dpakprtbnfgrpcrt.bnfcrtcod,
                          bnfcrtdes like dpakprtbnfcrt.bnfcrtdes,
                          atldat    like dpakprtbnfgrpcrt.atldat,
                          atlusr    like dpakprtbnfgrpcrt.atlusr,
                          funnom    like isskfunc.funnom
                      end record

    define lr_retorno record
                          erro       smallint,
                          mensagem   char(60)
                      end record

    define l_ind smallint

    initialize lr_entrada.*,
               ma_entrada to null

    open cqctc20m04_01 using mr_param.prtbnfgrpcod

    let l_ind = 1

    foreach cqctc20m04_01 into lr_entrada.bnfcrtcod,
                               lr_entrada.atldat,
                               lr_entrada.atlusr

        let ma_entrada[l_ind].bnfcrtcod = lr_entrada.bnfcrtcod
        let ma_entrada[l_ind].atldat    = lr_entrada.atldat

        call cty08g00_nome_func(1,lr_entrada.atlusr,'F')
             returning lr_retorno.erro,
                       lr_retorno.mensagem,
                       ma_entrada[l_ind].funnom

        open cqctc20m04_02 using lr_entrada.bnfcrtcod
        fetch cqctc20m04_02 into ma_entrada[l_ind].bnfcrtdes

        let l_ind = l_ind + 1
        if l_ind > 100 then
             error "O numero de registros ultrapassou o tamanho do array. Favor contatar a informatica"
             exit foreach
         end if
    end foreach

    call set_count(l_ind -1 )

 end function

#---------------------------------------------#
 function ctc20m04_verific_array(l_ind, param)
#---------------------------------------------#

    define param record
                     bnfcrtcod like dpakprtbnfcrt.bnfcrtcod
                 end record

    define l_ind   smallint,
           l_ind2  smallint,
           l_count smallint,
           l_find  smallint

    let l_count = arr_count()
    let l_find = false

    for l_ind2 = 1 to l_count
        if  l_ind2 <> l_ind then
            if  ma_entrada[l_ind2].bnfcrtcod = ma_entrada[l_ind].bnfcrtcod then
                let l_find = true
            end if
        else
            continue for
        end if
    end for

    if  l_find then
        return true
    else
        return false
    end if

 end function
