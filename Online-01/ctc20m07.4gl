#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: PORTO SOCORRO                                              #
# Modulo.........: ctc20m07                                                   #
# Analista Resp..: Sergio Burini                                              #
# PSI/OSF........: 237248                                                     #
#                  Modulo para manutenção do relacionamento de prestadores e  #
#                  processos de Bonificação.                                  #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 24/09/2010 Robert Lima     00009EV    Foi adicionada a função obrigatorio e #
#                                       a validação de efetuar pelo menos um  #
#                                       cadastro.                             #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

    define ma_entrada array[30] of record
                          prtbnfprccod like dparbnfprt.prtbnfprccod,
                          prtbnfprcdes like dpakprtbnfprc.prtbnfprcdes,
                          altdat       like dparbnfprt.altdat,
                          funnom       like isskfunc.funnom
                      end record

    define m_prepare     smallint
    define m_obrigatorio smallint

#---------------------------#
 function ctc20m07_prepare()
#---------------------------#

     define l_sql char(1000)

     let l_sql = "select prtbnfprccod, ",
                       " altdat, ",
                       " funmat ",
                  " from dparbnfprt ",
                 " where pstcoddig = ? ",
                 " order by prtbnfprccod"

     prepare prctc20m07_01 from l_sql
     declare cqctc20m07_01 cursor for prctc20m07_01

     let l_sql = "select prtbnfprcdes ",
                  " from dpakprtbnfprc ",
                 " where prtbnfprccod = ? "

     prepare prctc20m07_02 from l_sql
     declare cqctc20m07_02 cursor for prctc20m07_02

     let l_sql = "select 1 ",
                  " from dparbnfprt ",
                 " where pstcoddig    = ? ",
                   " and prtbnfprccod = ? "

     prepare prctc20m07_03 from l_sql
     declare cqctc20m07_03 cursor for prctc20m07_03

     let l_sql = "delete from dparbnfprt ",
                 " where pstcoddig   = ? ",
                  " and prtbnfprccod = ? "

     prepare prctc20m07_04 from l_sql

     let l_sql = "insert into dparbnfprt values (?,?,?,?)"

     prepare prctc20m07_05 from l_sql


     let l_sql = "select count(*)        ",
                 " from dparbnfprt       ",
                 " where pstcoddig = ?   ",
                 "  and prtbnfprccod <> 0"     ## Código 0 = PREST SEM BONIFICACA


     prepare prctc20m07_06 from l_sql
     declare cqctc20m07_06 cursor for prctc20m07_06


     let l_sql = "delete from dpamprsbnsple ",
                 " where pstcoddig   = ? ",
                  " and prtbnfprccod = ? "

     prepare prctc20m07_07 from l_sql





     let m_prepare = true


 end function

#------------------------------#
 function ctc20m07(param)
#------------------------------#

     define param record
                      pstcoddig like datrassprs.pstcoddig,
                      rspnom    like dpaksocor.rspnom
                  end record

     define lr_retorno record
                           errcod  smallint,
                           errmsg  char(50)
                       end record

     define lr_popup record
                         lin     smallint,
                         col     smallint,
                         titulo  char (054),
                         tit2    char (012),
                         tit3    char (040),
                         tipcod  char (001),
                         cmd_sql char (1999),
                         aux_sql char (200),
                         tipo    char (001)
                     end record

     define l_curr          smallint,
            l_arr           smallint,
            l_scr           smallint,
            l_status        smallint,
            l_sair          smallint,
            l_prtbnfprccod  like dparbnfprt.prtbnfprccod


     initialize lr_popup.*,
                lr_retorno.* to null

     call ctc20m07_prepare()

     options
       insert key f37,
       delete key f36

     open window w_ctc20m07 at 6,2 with form "ctc20m07"
          attribute(form line first, comment line last - 2, border)

     display by name param.pstcoddig   attribute(reverse)
     display by name param.rspnom      attribute(reverse)
     display "INFORME SE ESTE PRESTADOR PARTICIPA DE ALGUM PROGRAMA DE BONIFICACAO" to cabec
     message "(F6) Penalidade (F7) Valores (F8) Voltar"

     let l_sair = false

     while true
          call ctc20m07_carrega_array(param.pstcoddig)

          input array ma_entrada without defaults from s_ctc20m07.*

              before row
                     let l_curr         = arr_curr()
                     let l_arr          = arr_count()
                     let l_scr          = scr_line()
                     let l_prtbnfprccod = ma_entrada[l_curr].prtbnfprccod

              after field prtbnfprccod

                         if  ma_entrada[l_curr].prtbnfprccod is null or
                             ma_entrada[l_curr].prtbnfprccod = " " then

                             if  l_prtbnfprccod is not null then
                                 call ctc20m07_exclui(param.pstcoddig, l_prtbnfprccod)
                                      returning lr_retorno.errcod,
                                                lr_retorno.errmsg

                                      if  lr_retorno.errcod <> 0 then
                                          error lr_retorno.errmsg
                                          next field prtbnfprccod
                                      end if
                                 exit input
                             end if

                             if  fgl_lastkey() <> fgl_keyval("up") and
                                 fgl_lastkey() <> fgl_keyval("left") then
                                 error 'O campo Codigo do Processo deve ser informado.'

                                 let lr_popup.lin    = 6
                                 let lr_popup.col    = 2
                                 let lr_popup.titulo = "PROCESSOS"
                                 let lr_popup.tit2   = "Codigo"
                                 let lr_popup.tit3   = "Descricao"
                                 let lr_popup.tipcod = "A"
                                 let lr_popup.cmd_sql = "select prtbnfprccod, ",
                                                              " prtbnfprcdes ",
                                                         " from dpakprtbnfprc ",
                                                         " order by prtbnfprccod "
                                 let lr_popup.tipo   = "D"

                                 call ofgrc001_popup(lr_popup.*)
                                      returning lr_retorno.errcod,
                                                ma_entrada[l_curr].prtbnfprccod,
                                                lr_retorno.errmsg

                                 display ma_entrada[l_curr].prtbnfprccod to s_ctc20m07[l_scr].prtbnfprccod

                                 next field prtbnfprccod
                             end if

                         end if

                         if  ma_entrada[l_curr].prtbnfprccod is not null and
                             ma_entrada[l_curr].prtbnfprccod <> " " then

                             if  field_touched(prtbnfprccod) then

                                 open cqctc20m07_02 using ma_entrada[l_curr].prtbnfprccod
                                 fetch cqctc20m07_02 into ma_entrada[l_curr].prtbnfprcdes

                                 if  sqlca.sqlcode =  100 then
                                     error 'Processo não cadastrado.'

                                     let ma_entrada[l_curr].prtbnfprccod = ""
                                     display ma_entrada[l_curr].prtbnfprccod to s_ctc20m07[l_scr].prtbnfprccod

                                     next field prtbnfprccod
                                 end if

                                 open cqctc20m07_03 using param.pstcoddig,
                                                          ma_entrada[l_curr].prtbnfprccod
                                 fetch cqctc20m07_03 into l_status

                                 if  sqlca.sqlcode = 0 then
                                     error 'Processo já cadastrado para esse prestador.'

                                     initialize ma_entrada[l_curr].* to null

                                     display ma_entrada[l_curr].* to s_ctc20m07[l_scr].*

                                     next field prtbnfprccod
                                 else
                                     if  sqlca.sqlcode <> 100 then
                                         error "Problema na SELECAO. ERRO: ", sqlca.sqlcode
                                     end if
                                 end if

                                  if  l_prtbnfprccod is not null and l_prtbnfprccod <> " " then
                                      call ctc20m07_exclui(param.pstcoddig, l_prtbnfprccod)
                                           returning lr_retorno.errcod,
                                                     lr_retorno.errmsg

                                      if  lr_retorno.errcod <> 0 then
                                          error lr_retorno.errmsg
                                          next field prtbnfprccod

                                      end if
                                  end if

                                  let ma_entrada[l_curr].altdat = current

                                  call cty08g00_nome_func(1, g_issk.funmat, 'F')
                                       returning lr_retorno.errcod,
                                                 lr_retorno.errmsg,
                                                 ma_entrada[l_curr].funnom

                                  call ctc20m07_inclui(param.pstcoddig,
                                                       ma_entrada[l_curr].prtbnfprccod,
                                                       ma_entrada[l_curr].altdat,
                                                       g_issk.funmat)
                                       returning lr_retorno.errcod,
                                                 lr_retorno.errmsg

                                  if  lr_retorno.errcod <> 0 then
                                      error lr_retorno.errmsg
                                      next field prtbnfprccod
                                  end if

                                  display ma_entrada[l_curr].prtbnfprcdes to s_ctc20m07[l_scr].prtbnfprcdes
                                  display ma_entrada[l_curr].altdat       to s_ctc20m07[l_scr].altdat
                                  display ma_entrada[l_curr].funnom       to s_ctc20m07[l_scr].funnom
                             end if
                         else

                         end if
                #  end if

              on key (f2)

                  call ctc20m07_exclui(param.pstcoddig, ma_entrada[l_curr].prtbnfprccod)
                       returning lr_retorno.errcod,
                                 lr_retorno.errmsg

                  if  lr_retorno.errcod <> 0 then
                      error lr_retorno.errmsg
                  end if

                  exit input

              on key (f6)
                 call ctc20m07a(param.pstcoddig, ma_entrada[l_curr].prtbnfprccod, ma_entrada[l_curr].prtbnfprcdes)
                 exit input

              on key (f7)
                 call ctc20m07b(param.pstcoddig, ma_entrada[l_curr].prtbnfprccod, ma_entrada[l_curr].prtbnfprcdes)
                 exit input

              after input
                  if  int_flag and m_obrigatorio then
                      if ma_entrada[1].prtbnfprccod is not null then
                         let l_sair = true
                      else
                         error "E' OBRIGATORIO O CADASTRO DE UM ITEM"
                      end if
                  else
                      let l_sair = true
                  end if
          end input

          if  l_sair then
              exit while
          end if

     end while

     close window w_ctc20m07

 end function

#--------------------------------------------#
 function ctc20m07_carrega_array(l_pstcoddig)
#--------------------------------------------#

     define l_pstcoddig like dpaksocor.pstcoddig,
            l_ind       smallint,
            l_atlusr    like isskfunc.funmat

     define lr_retorno record
                           errcod  smallint,
                           errmsg  char(50)
                       end record

     initialize ma_entrada to null

     let l_ind = 1

     open cqctc20m07_01 using l_pstcoddig
     fetch cqctc20m07_01 into ma_entrada[l_ind].prtbnfprccod,
                              ma_entrada[l_ind].altdat,
                              l_atlusr

     if  sqlca.sqlcode = 0 then
         foreach cqctc20m07_01 into ma_entrada[l_ind].prtbnfprccod,
                                    ma_entrada[l_ind].altdat,
                                    l_atlusr

         open cqctc20m07_02 using ma_entrada[l_ind].prtbnfprccod
         fetch cqctc20m07_02 into ma_entrada[l_ind].prtbnfprcdes

         call cty08g00_nome_func(1, l_atlusr, 'F')
              returning lr_retorno.errcod,
                        lr_retorno.errmsg,
                        ma_entrada[l_ind].funnom

             let l_ind = l_ind + 1
         end foreach
     end if

     call set_count(l_ind -1)

 end function

#-------------------------------#
 function ctc20m07_exclui(param)
#-------------------------------#

     define param record
                      pstcoddig    like dparbnfprt.pstcoddig,
                      prtbnfprccod like dparbnfprt.prtbnfprccod
                  end record

     define lr_retorno record
            errcod  smallint,
            errmsg  char(50)
     end record

     define l_prtbnfprcdes like dpakprtbnfprc.prtbnfprcdes
     define l_msg          char(300)

     ##exclui penalidades relacionadas a Bonificacao
     execute prctc20m07_07 using param.pstcoddig,
                                 param.prtbnfprccod

     if  sqlca.sqlerrd[3] > 0 then
         let lr_retorno.errcod = 0
         let lr_retorno.errmsg = "Exclusao efetuada com sucesso"
     else
         let lr_retorno.errcod = sqlca.sqlcode
         let lr_retorno.errmsg = "Problema na exclusao prctc20m07_07. ERRO: ", sqlca.sqlcode
     end if


     #exclui bonificacao do prestador
     execute prctc20m07_04 using param.pstcoddig,
                                 param.prtbnfprccod

     if  sqlca.sqlerrd[3] > 0 then
         let lr_retorno.errcod = 0
         let lr_retorno.errmsg = "Exclusao efetuada com sucesso"
     else
         let lr_retorno.errcod = sqlca.sqlcode
         let lr_retorno.errmsg = "Problema na SELECAO. ERRO: ", sqlca.sqlcode
     end if

     ## se tudo deu certo  e tipo de bonificacao diferente de zero (Sem Bonificacao)
     ## envia e-mail comunicando area de negocio que bonificacao foi deletada
     if lr_retorno.errcod = 0 and param.prtbnfprccod <> 0 then
        #verifica descricao do tipo de bonificacao
        open cqctc20m07_02 using param.prtbnfprccod
        fetch cqctc20m07_02 into l_prtbnfprcdes

        let l_msg = "TIPO DE BONIFICACAO ", l_prtbnfprcdes, " DELETADA."

        call ctc00m02_grava_hist(param.pstcoddig,
                                 l_msg,"E")

     end if


     return lr_retorno.errcod,
            lr_retorno.errmsg

 end function

#-------------------------------#
 function ctc20m07_inclui(param)
#-------------------------------#

     define param record
                      pstcoddig    like dparbnfprt.pstcoddig,
                      prtbnfprccod like dparbnfprt.prtbnfprccod,
                      altdat       like dparbnfprt.altdat,
                      funmat       like dparbnfprt.funmat
                  end record

     define lr_retorno record
                           errcod  smallint,
                           errmsg  char(50)
                       end record

     define l_current      like dparbnfprt.altdat
     define l_prtbnfprcdes like dpakprtbnfprc.prtbnfprcdes
     define l_msg          char(300)

     let l_current = current

     execute prctc20m07_05 using param.pstcoddig,
                                 param.prtbnfprccod,
                                 param.altdat,
                                 param.funmat

     if  sqlca.sqlcode = 0 then
         let lr_retorno.errcod = 0
         let lr_retorno.errmsg = "Inclusão efetuada com sucesso"
     else
         let lr_retorno.errcod = sqlca.sqlcode
         let lr_retorno.errmsg = "Problema na Inclusão. ERRO: ", sqlca.sqlcode
     end if

     if sqlca.sqlcode = 0 and param.prtbnfprccod <> 0 then
        #verifica descricao do tipo de bonificacao
        open cqctc20m07_02 using param.prtbnfprccod
        fetch cqctc20m07_02 into l_prtbnfprcdes

        let l_msg = "TIPO DE BONIFICACAO ", l_prtbnfprcdes, " INCLUIDA."

        call ctc00m02_grava_hist(param.pstcoddig,
                                 l_msg,"I")

     end if



     return lr_retorno.errcod,
            lr_retorno.errmsg

 end function

#----------------------------------------#
 function ctc20m07_verifica_prtbnf(param)
#----------------------------------------#

     define param record
                      pstcoddig    like dparbnfprt.pstcoddig,
                      prtbnfprccod like dparbnfprt.prtbnfprccod
                  end record

     define l_status smallint

     if  not m_prepare then
         call ctc20m07_prepare()
     end if

     open cqctc20m07_03 using param.pstcoddig,
                              param.prtbnfprccod

     fetch cqctc20m07_03  into l_status

     if  sqlca.sqlcode <> 0 then
         return false
     end if

     return true

 end function

#----------------------------------------#
function ctc20m07_obrigatorio(param)
#----------------------------------------#

define param record
    pstcoddig like datrassprs.pstcoddig,
    rspnom    like dpaksocor.rspnom
end record


let m_obrigatorio = true
call ctc20m07(param.pstcoddig,param.rspnom)
let m_obrigatorio = false

end function


#----------------------------------------#
 function ctc20m07_participa_bonificacao(l_pstcoddig)
#----------------------------------------#

 define l_pstcoddig like dparbnfprt.pstcoddig


 define l_aux smallint

 if  not m_prepare then
     call ctc20m07_prepare()
 end if

 open cqctc20m07_06 using l_pstcoddig


 fetch cqctc20m07_06  into l_aux

 close cqctc20m07_06

 ## se quantidade de registros maior que 0 prestador possui bonificação
 if  l_aux > 0 then
     return true
 else
    return false
 end if

 end function 