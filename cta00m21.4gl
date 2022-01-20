#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cta00m21                                                    #
# Objetivo.......: Selecao dos Itens de Apolice para Replicacao do Atendimento #
# Analista Resp. : Roberto Melo                                                #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: Roberto Melo                                                #
# Liberacao      : 20/08/2009                                                  #
#..............................................................................#
#                  * * *  ALTERACOES  * * *                                    #
#                                                                              #
#------------------------------------------------------------------------------#


 globals "/homedsa/projetos/geral/globals/glct.4gl"


 database porto

 define m_prepare smallint

 define hrr_aux   smallint

 define mh_cta00m21 array[300] of record
    c24ligdsc      like datmlighist.c24ligdsc
 end record

 define ma_cta00m21 array[1000] of record
    marca1        char(01)               ,
    seta          char(01)               ,
    marca2        char(01)               ,
    itmnumdig     like abbmitem.itmnumdig,
    vcldes        char (25)              ,
    vcllicnum     like abbmveic.vcllicnum,
    vclchsfnl     like abbmveic.vclchsfnl
 end record

#----------------------------------------------#
 function cta00m21_prepare()
#----------------------------------------------#

define l_sql char(500)

 let l_sql =  "select vclcoddig,    ",
              "       vclchsfnl,    ",
              "       vcllicnum     ",
              "    from abbmveic    ",
              " where succod  = ?   ",
              " and aplnumdig = ?   ",
              " and itmnumdig = ?   ",
              " and dctnumseq = ?   "
 prepare p_cta00m21_001  from l_sql
 declare c_cta00m21_001  cursor for p_cta00m21_001
 let l_sql = "select vclmrccod,    ",
             "       vcltipcod,    ",
             "       vclmdlnom     ",
             "    from agbkveic    ",
             " where vclcoddig = ? "
 prepare pcts00m21m00002  from l_sql
 declare ccts00m21m00002  cursor for pcts00m21m00002
 let l_sql = "select vclmrcnom     ",
              "  from agbkmarca    ",
              " where vclmrccod = ?"
 prepare pcts00m21m00003  from l_sql
 declare ccts00m21m00003  cursor for pcts00m21m00003
 let l_sql =  "select vcltipnom     ",
              "  from agbktip       ",
              " where vclmrccod = ? ",
              " and   vcltipcod = ? "
 prepare pcts00m21m00004  from l_sql
 declare ccts00m21m00004  cursor for pcts00m21m00004
 let l_sql = "select itmnumdig,          ",
             "  max (dctnumseq)          ",
             "  from abbmdoc             ",
             "  where succod  = ?        ",
             "  and aplnumdig = ?        ",
             "  and itmnumdig >= 0       ",
             "  and itmnumdig <= 9999999 ",
             "  group by itmnumdig       "
  prepare pcts00m21m00005  from l_sql
  declare ccts00m21m00005  cursor for pcts00m21m00005
 let l_sql = "select c24ligdsc      ",
             "  from datmlighist    ",
             "  where lignum = ?    ",
             "  order by c24txtseq  "
 prepare pcts00m21m00006  from l_sql
 declare ccts00m21m00006  cursor for pcts00m21m00006
  let m_prepare = true
end function


#----------------------------------------------#
 function cta00m21(lr_param)
#----------------------------------------------#

define lr_param record
   succod            like abbmveic.succod       ,
   aplnumdig         like abbmveic.aplnumdig    ,
   funmat            like isskfunc.funmat       ,
   data              date                       ,
   hora              datetime hour to second    ,
   c24atrflg         like datkassunto.c24atrflg ,
   c24jstflg         like datkassunto.c24jstflg ,
   funnom            like isskfunc.funnom       ,
   lignum            like datmligacao.lignum
end record

define lr_cta00m21   record
   itmnumdig         like abbmdoc.itmnumdig  ,
   dctnumseq         like abbmdoc.dctnumseq  ,
   vclcoddig         like abbmveic.vclcoddig ,
   vclmrccod         like agbkveic.vclmrccod ,
   vcltipcod         like agbkveic.vcltipcod ,
   vclmdlnom         like agbkveic.vclmdlnom ,
   vclmrcnom         like agbkmarca.vclmrcnom,
   vcltipnom         like agbktip.vcltipnom  ,
   obs               char(70)                ,
   minimo            smallint                ,
   maximo            smallint
end record

define lr_funapol     record
   result            char (01),
   dctnumseq         like abbmveic.dctnumseq,
   vclsitatu         like abbmitem.vclsitatu,
   autsitatu         like abbmitem.autsitatu,
   dmtsitatu         like abbmitem.dmtsitatu,
   dpssitatu         like abbmitem.dpssitatu,
   appsitatu         like abbmitem.appsitatu,
   vidsitatu         like abbmitem.vidsitatu
end record

define aux_cta00m21 array[1000] of record
   seta1      char(01)
end record


define arr_aux       smallint,
       scr_aux       smallint,
       arr_aux1      smallint,
       arr_aux2      smallint,
       arr_cou       smallint,
       scr_count     smallint
  for  arr_aux  =  1  to  1000
     initialize  ma_cta00m21[arr_aux].*          ,
                 aux_cta00m21[arr_aux].* to  null
  end  for
  let arr_aux = null

  initialize lr_cta00m21,
             lr_funapol  to null


  if m_prepare is null or
     m_prepare <> true then
     call cta00m21_prepare()
  end if
 message " Aguarde, pesquisando..." attribute (reverse)

 let arr_aux   = 1
 let arr_aux1  = 1
 let arr_cou   = null
 let scr_count = 9

 # Recupera o Item da Apolice
 open ccts00m21m00005  using lr_param.succod   ,
                             lr_param.aplnumdig
 foreach ccts00m21m00005 into lr_cta00m21.itmnumdig,
                              lr_cta00m21.dctnumseq

    # Despreza o Item Original
    if  lr_cta00m21.itmnumdig = g_documento.itmnumdig then
        continue foreach
    end if
    # Reculpera a Ultima situação da Apolice
    call f_funapol_ultima_situacao (lr_param.succod     ,
                                    lr_param.aplnumdig  ,
                                    lr_cta00m21.itmnumdig)
    returning lr_funapol.*

   # Recupera os Dados do Veiculo
   if lr_funapol.result = "O"  then
      open  c_cta00m21_001 using lr_param.succod,
                                  lr_param.aplnumdig,
                                  lr_cta00m21.itmnumdig,
                                  lr_funapol.dctnumseq
      fetch c_cta00m21_001 into  lr_cta00m21.vclcoddig,
                                  ma_cta00m21[arr_aux].vclchsfnl,
                                  ma_cta00m21[arr_aux].vcllicnum

      if sqlca.sqlcode = 0  then
         open  ccts00m21m00002 using lr_cta00m21.vclcoddig
         fetch ccts00m21m00002 into  lr_cta00m21.vclmrccod,
                                     lr_cta00m21.vcltipcod,
                                     lr_cta00m21.vclmdlnom
         close ccts00m21m00002

         open  ccts00m21m00003 using lr_cta00m21.vclmrccod
         fetch ccts00m21m00003 into  lr_cta00m21.vclmrcnom
         close ccts00m21m00003

         open  ccts00m21m00004   using lr_cta00m21.vclmrccod,
                                       lr_cta00m21.vcltipcod
         fetch ccts00m21m00004   into  lr_cta00m21.vcltipnom
         close ccts00m21m00004

         let ma_cta00m21[arr_aux].vcldes  = lr_cta00m21.vclmrcnom clipped," ",
                                            lr_cta00m21.vcltipnom clipped," ",
                                            lr_cta00m21.vclmdlnom

         let ma_cta00m21[arr_aux].itmnumdig = lr_cta00m21.itmnumdig
         let ma_cta00m21[arr_aux].marca1    = "("
         let ma_cta00m21[arr_aux].marca2    = ")"

         let arr_aux = arr_aux + 1

         if arr_aux > 1000  then
            error " Limite excedido. Apolice com mais de 1000 itens!"
            exit foreach
         end if

      end if
   end if

 end foreach

 message " "

 if arr_aux > 1  then
       call set_count(arr_aux - 1)
       let lr_cta00m21.obs =  "(F17)Abandona,(F8)Replica,(F9)Marca Todos,(F10)Desmarca Todos"

       open window cta00m21 at 07,14 with form "cta00m21"
                   attribute(border, form line first)
       options insert   key F40
       options delete   key F35
       options next     key F30
       options previous key F25
       display by name lr_cta00m21.obs

       input array ma_cta00m21 without defaults from s_cta00m21.*
          before row
              let arr_aux  = arr_curr()
              let scr_aux  = scr_line()
              let arr_cou  = arr_count()
         after field seta
          if  fgl_lastkey() <> fgl_keyval("down") and
              fgl_lastkey() <> fgl_keyval("up")   and
              fgl_lastkey() <> fgl_keyval("left") and
              fgl_lastkey() <> fgl_keyval("right")then
              if ma_cta00m21[arr_aux].seta <> "X" and
                 ma_cta00m21[arr_aux].seta is not null then
                   error "Tecle <ENTER> para Marcar ou Desmarcar!"
                   let ma_cta00m21[arr_aux].seta   = null
                   let aux_cta00m21[arr_aux].seta1 = null
                   display  ma_cta00m21[arr_aux].seta to s_cta00m21[scr_aux].seta
                   next field seta
              end if
              if ma_cta00m21[arr_aux].seta is null then
                  let ma_cta00m21[arr_aux].seta   = "X"
                  let aux_cta00m21[arr_aux].seta1 = "X"
                  display  ma_cta00m21[arr_aux].seta to s_cta00m21[scr_aux].seta
              else
                  let ma_cta00m21[arr_aux].seta   = null
                  let aux_cta00m21[arr_aux].seta1 = null
                  display  ma_cta00m21[arr_aux].seta to s_cta00m21[scr_aux].seta
              end if
              if arr_curr() = arr_count() then
                 next field seta
              end if
          else
              if fgl_lastkey() <> fgl_keyval("left") and
                 fgl_lastkey() <> fgl_keyval("up")   then
                    if arr_curr() = arr_count() then
                       next field seta
                    end if
              end if
              if ma_cta00m21[arr_aux].seta <> "X" and
                 ma_cta00m21[arr_aux].seta is not null then
                   error "Tecle <ENTER> para Marcar ou Desmarcar!"
                   let ma_cta00m21[arr_aux].seta   = null
                   let aux_cta00m21[arr_aux].seta1 = null
                   display  ma_cta00m21[arr_aux].seta to s_cta00m21[scr_aux].seta
                   next field seta
              else
                  if (aux_cta00m21[arr_aux].seta1 is null and
                      ma_cta00m21[arr_aux].seta   is not null) or
                     (aux_cta00m21[arr_aux].seta1 is not null  and
                      ma_cta00m21[arr_aux].seta   is null)     then
                      error "Tecle <ENTER> para Marcar ou Desmarcar!"
                      let ma_cta00m21[arr_aux].seta = aux_cta00m21[arr_aux].seta1
                      display  ma_cta00m21[arr_aux].seta to s_cta00m21[scr_aux].seta
                      next field seta
                  end if
              end if
          end if
         on key (F8)
            # Recupera o Historico da Ligação Original
            if not cta00m21_recupera_historico(lr_param.lignum) then
                 exit input
            end if
            # Replica a Ligacao para os Itens Selecionados
            call cta00m21_replica(arr_cou             ,
                                  lr_param.succod     ,
                                  lr_param.aplnumdig  ,
                                  lr_param.funmat     ,
                                  lr_param.data       ,
                                  lr_param.hora       ,
                                  lr_param.c24atrflg  ,
                                  lr_param.c24jstflg  ,
                                  lr_param.funnom     )
         on key (F9)
           let arr_aux2  = 1
           # Calcula quais os Delimitadores a serem Marcados
           call cta00m21_delimitadores(scr_aux  ,
                                       arr_aux  ,
                                       scr_count)
           returning lr_cta00m21.minimo,
                     lr_cta00m21.maximo
           # Carrega Todos os Arrays
           for  arr_aux1  =  1  to  arr_count()
               let ma_cta00m21[arr_aux1].seta   = "X"
               let aux_cta00m21[arr_aux1].seta1 = "X"
           end for
           # Marca o "X" nos Campos da Tela
           for arr_aux1  = lr_cta00m21.minimo to lr_cta00m21.maximo
               display  ma_cta00m21[arr_aux1].seta to s_cta00m21[arr_aux2].seta
               let arr_aux2 = arr_aux2 + 1
           end for
           on key (F10)
             let arr_aux2  = 1
             # Calcula quais os Delimitadores a serem Desmarcados
             call cta00m21_delimitadores(scr_aux  ,
                                         arr_aux  ,
                                         scr_count)
             returning lr_cta00m21.minimo,
                       lr_cta00m21.maximo
             # Descarrega Todos os Arrays
             for  arr_aux1  =  1  to  arr_count()
                 let ma_cta00m21[arr_aux1].seta   = null
                 let aux_cta00m21[arr_aux1].seta1 = null
             end for
             # Desmarca o "X" nos Campos da Tela
             for arr_aux1  = lr_cta00m21.minimo to lr_cta00m21.maximo
                 display  ma_cta00m21[arr_aux1].seta to s_cta00m21[arr_aux2].seta
                 let arr_aux2 = arr_aux2 + 1
             end for
         on key (interrupt)
            initialize ma_cta00m21  to null
            exit input
       end input

       close window cta00m21
 end if

 return

end function

#----------------------------------------------#
 function cta00m21_recupera_qtd(lr_param)
#----------------------------------------------#

define lr_param record
   succod            like abbmveic.succod   ,
   aplnumdig         like abbmveic.aplnumdig
end record
define lr_cta00m21   record
   itmnumdig         like abbmdoc.itmnumdig  ,
   dctnumseq         like abbmdoc.dctnumseq  ,
   vclcoddig         like abbmveic.vclcoddig ,
   vcllicnum         like abbmveic.vcllicnum ,
   vclchsfnl         like abbmveic.vclchsfnl
end record
define lr_funapol     record
   result            char (01),
   dctnumseq         like abbmveic.dctnumseq,
   vclsitatu         like abbmitem.vclsitatu,
   autsitatu         like abbmitem.autsitatu,
   dmtsitatu         like abbmitem.dmtsitatu,
   dpssitatu         like abbmitem.dpssitatu,
   appsitatu         like abbmitem.appsitatu,
   vidsitatu         like abbmitem.vidsitatu
end record

define arr_aux       smallint
  let arr_aux = null
  initialize lr_cta00m21,
             lr_funapol  to null
  if m_prepare is null or
     m_prepare <> true then
     call cta00m21_prepare()
  end if
  message " Aguarde, pesquisando..." attribute (reverse)
  let arr_aux = 1
  open ccts00m21m00005  using lr_param.succod   ,
                              lr_param.aplnumdig
  foreach ccts00m21m00005 into lr_cta00m21.itmnumdig,
                               lr_cta00m21.dctnumseq
     call f_funapol_ultima_situacao (lr_param.succod     ,
                                     lr_param.aplnumdig  ,
                                     lr_cta00m21.itmnumdig)
     returning lr_funapol.*
    if lr_funapol.result = "O"  then
       open  c_cta00m21_001 using lr_param.succod,
                                   lr_param.aplnumdig,
                                   lr_cta00m21.itmnumdig,
                                   lr_funapol.dctnumseq
       fetch c_cta00m21_001 into  lr_cta00m21.vclcoddig,
                                   lr_cta00m21.vclchsfnl,
                                   lr_cta00m21.vcllicnum
       if sqlca.sqlcode = 0  then
          let arr_aux = arr_aux + 1
       end if
    end if
   end foreach
   let arr_aux = arr_aux - 1
   return arr_aux
end function

#----------------------------------------------#
 function cta00m21_recupera_historico(lr_param)
#----------------------------------------------#

define lr_param record
   lignum    like datmligacao.lignum
end record



     if m_prepare is null or
        m_prepare <> true then
        call cta00m21_prepare()
     end if

     for     hrr_aux  =  1  to  300
             initialize  mh_cta00m21[hrr_aux].*  to  null
     end     for

     let hrr_aux = 1

     open ccts00m21m00006  using lr_param.lignum

     foreach ccts00m21m00006 into mh_cta00m21[hrr_aux].c24ligdsc
       let hrr_aux = hrr_aux + 1
       if hrr_aux > 300 then
          exit foreach
       end if

     end foreach
     if hrr_aux = 1 then
        error "Erro ao Recuperar o Historico!"
        return false
     end if
     let hrr_aux = hrr_aux - 1
     return true


end function

#----------------------------------------------#
 function cta00m21_delimitadores(lr_param)
#----------------------------------------------#

define lr_param record
   arr_tela     smallint ,
   arr_corrente smallint ,
   arr_total    smallint
end record

define lr_retorno record
   minimo smallint ,
   maximo smallint
end record

initialize lr_retorno.* to null

   let lr_retorno.minimo = (lr_param.arr_corrente - lr_param.arr_tela) + 1
   let lr_retorno.maximo = (lr_param.arr_total - lr_param.arr_tela) + lr_param.arr_corrente

   return lr_retorno.*

end function


#----------------------------------------------#
 function cta00m21_replica(lr_param)
#----------------------------------------------#

define lr_param record
   qtd               smallint                   ,
   succod            like abbmveic.succod       ,
   aplnumdig         like abbmveic.aplnumdig    ,
   funmat            like isskfunc.funmat       ,
   data              date                       ,
   hora              datetime hour to second    ,
   c24atrflg         like datkassunto.c24atrflg ,
   c24jstflg         like datkassunto.c24jstflg ,
   funnom            like isskfunc.funnom
end record

define lr_retorno record
   lignum       like datmligacao.lignum ,
   ramnom       like gtakram.ramnom     ,
   ramsgl       char(15)                ,
   confirma     smallint                ,
   mensagem     char(60)                ,
   mensagem_aux char(60)                ,
   erro         smallint
end record

define lr_funapol     record
   result            char (01)              ,
   dctnumseq         like abbmveic.dctnumseq,
   vclsitatu         like abbmitem.vclsitatu,
   autsitatu         like abbmitem.autsitatu,
   dmtsitatu         like abbmitem.dmtsitatu,
   dpssitatu         like abbmitem.dpssitatu,
   appsitatu         like abbmitem.appsitatu,
   vidsitatu         like abbmitem.vidsitatu
end record

define lr_cty06g00    record
   resultado      smallint                  ,
   mensagem       char(60)                  ,
   sgrorg         like rsamseguro.sgrorg    ,
   sgrnumdig      like rsamseguro.sgrnumdig ,
   vigfnl         like rsdmdocto.vigfnl     ,
   aplstt         like rsdmdocto.edsstt     ,
   prporg         like rsdmdocto.prporg     ,
   prpnumdig      like rsdmdocto.prpnumdig  ,
   segnumdig      like rsdmdocto.segnumdig  ,
   edsnumref      like rsdmdocto.edsnumdig
end record

define lr_ant record
   itmnumdig  like abbmitem.itmnumdig    ,
   edsnumref  like datrligapol.edsnumref
end record

define arr_aux     smallint
define arr_aux1    smallint
define l_acesso    smallint
define l_replicado smallint

initialize lr_retorno.*  ,
           lr_ant.*      ,
           lr_funapol.*  ,
           lr_cty06g00.* ,
           g_rep_lig     to null

let arr_aux           = null
let arr_aux1          = null
let l_replicado       = 0
let g_rep_lig         = true
let l_acesso          = false
let lr_ant.itmnumdig  = g_documento.itmnumdig
let lr_ant.edsnumref  = g_documento.edsnumref
    for  arr_aux  =  1  to  lr_param.qtd
       let lr_retorno.erro   = 0
       error "Aguarde... Replicando Item ", ma_cta00m21[arr_aux].itmnumdig
       if ma_cta00m21[arr_aux].seta is not null  then
           let l_acesso = true
           # Obtem a Descricao do Ramo
           call cty10g00_descricao_ramo(g_documento.ramcod,1)
                returning lr_retorno.confirma
                         ,lr_retorno.mensagem
                         ,lr_retorno.ramnom
                         ,lr_retorno.ramsgl
           if lr_retorno.confirma <> 1 then
              error lr_retorno.mensagem sleep 3
              let lr_retorno.erro = 1
           end if
           # Recupera Dados do Item Corrente
           if lr_retorno.erro = 0 then
              if g_documento.ciaempcod <> 40 then
                  if g_documento.ramcod = 31 or
                     g_documento.ramcod = 531 then
                     call f_funapol_ultima_situacao (lr_param.succod               ,
                                                     lr_param.aplnumdig            ,
                                                     ma_cta00m21[arr_aux].itmnumdig)
                     returning lr_funapol.*
                     # Recupera o Endosso do Auto
                     call cty05g00_edsnumref(1                   ,
                                             lr_param.succod     ,
                                             lr_param.aplnumdig  ,
                                             lr_funapol.dctnumseq)
                     returning g_documento.edsnumref
                  else
                     # Recupera o Endosso do RE
                     call cty06g00_dados_apolice(lr_param.succod
                                                ,g_documento.ramcod
                                                ,lr_param.aplnumdig
                                                ,lr_retorno.ramsgl )
                          returning lr_cty06g00.*
                     let g_documento.edsnumref = lr_cty06g00.edsnumref
                     if lr_cty06g00.resultado <> 1 then
                        let lr_retorno.erro = 1
                     end if
                  end if
              end if
           end if
           # Grava Ligacao
           if lr_retorno.erro = 0 then
               let g_documento.itmnumdig = ma_cta00m21[arr_aux].itmnumdig
               call cta02m00_grava(lr_param.c24atrflg
                                  ,lr_param.c24jstflg
                                  ,lr_param.funnom)
                returning lr_retorno.confirma,
                          lr_retorno.lignum
               if lr_retorno.confirma = false then
                  let lr_retorno.erro = 1
               end if
           end if
           # Grava Historico
           if lr_retorno.erro = 0 then
             begin work
                for  arr_aux1  =  1  to  hrr_aux
                     call ctd06g01_ins_datmlighist(lr_retorno.lignum                ,
                                                   lr_param.funmat                  ,
                                                   mh_cta00m21[arr_aux1].c24ligdsc   ,
                                                   lr_param.data                    ,
                                                   lr_param.hora                    ,
                                                   g_issk.usrtip                    ,
                                                   g_issk.empcod                    )
                          returning lr_retorno.confirma  ,
                                    lr_retorno.mensagem
                      if lr_retorno.confirma <> 1 then
                         let lr_retorno.erro = 1
                         rollback work
                         exit for
                      end if
                end for
           end if
           # Grava Atendimento
           if lr_retorno.erro = 0 then
               if g_documento.atdnum is not null and
                  g_documento.atdnum <> 0       then
                  let lr_retorno.mensagem_aux = "PRI - cta00m21 1 - chamando ctd25g00"
                  call errorlog(lr_retorno.mensagem_aux)
                  call ctd25g00_insere_atendimento(g_documento.atdnum
                                                  ,lr_retorno.lignum )
                       returning lr_retorno.confirma  ,
                                 lr_retorno.mensagem
                  if lr_retorno.confirma <> 0 then
                     let lr_retorno.erro = 1
                     rollback work
                  end if
               end if
            end if
            # Se deu Erro Exibe Mensagem
            if lr_retorno.erro <> 0 then
               error lr_retorno.mensagem , " Item ", ma_cta00m21[arr_aux].itmnumdig sleep 3
            else
               let l_replicado = l_replicado + 1
               commit work
            end if
       end if
       if not l_acesso then
          error "Selecione Algum Item!"
       else
          error l_replicado, " Iten(s) Replicado(s) com Sucesso. Tecle <CTRL-C> para Sair!"
       end if
    end for
    let g_documento.itmnumdig  = lr_ant.itmnumdig
    let g_documento.edsnumref  = lr_ant.edsnumref
    let g_rep_lig              = false

end function
