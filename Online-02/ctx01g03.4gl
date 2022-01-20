#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Ct24h                                                       #
# Modulo         : ctx01g03                                                    #
#                  Solicitacao do beneficio "Carro Extra".                     #
# Analista Resp. : Ligia Mattge                                                #
# PSI            : 187887                                                      #
#..............................................................................#
# Desenvolvimento: META, Marcos M.P.                                           #
# Data           : 20/12/2004                                                  #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data       Analista Resp/Autor Fabrica  PSI/Alteracao                        #
# ---------- ---------------------------- -------------------------------------#
#..............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor  Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ----------------------------------------#
# 28/12/2004  Daniel Meta    PSI187887 Inclusao de duas novas funcoes, chamdas #
#                                      ctx01g03_lib_beneficio e ctx01g03_exc_  #
#                                      beneficio.                              #
#                                      Alterar chamadas das funcoes no f6 e f7 #
#                                      na funcao ctx01g03_array()              #
#                                      Alterar foreach principal da funcao     #
#                                      ctx01g03_obter_servicos                 #
#------------------------------------------------------------------------------#
# 18/01/2005 Daniel, Meta   PSI187887  Acertar concordancia de mensagem        #
#                                      Selecionar prporg, prpnumdig, avioccdat #
#                                      de datmavisrent na funcao ctx01g03_obter#
#                                      _servicos()                             #
#                                      Adicionar parametros na funcao ctx01g03_#
#                                      _lib_beneficio()                        #
#                                      Chamar a funcao sinitfopc()             #
#------------------------------------------------------------------------------#
# 03/03/2005 Adriano, Meta   PSI190772 Inclusao de parametro na chamada        #
#                                      da funcao cts10g06_dados_servicos       #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"

define mr_tela              record
       succod               like datrligapol.succod,
       sucnom               like gabksuc.sucnom
end record
define ma_servicos array[200] of record
       ramcod               like datrligapol.ramcod,
       aplnum               char(007),
       apldig               char(001),
       segnom               like gsakseg.segnom,
       atddat               like datmservico.atddat,
       servico              char(13)
end record
define ma_aux array[200] of  record
       atdsrvnum            like datmservico.atdsrvnum,
       atdsrvorg            like datmservico.atdsrvorg,
       atdsrvano            like datmservico.atdsrvano,
       avialgmtv            like datmavisrent.avialgmtv,
       aplnumdig            like datrservapol.aplnumdig,
       itmnumdig            like datrservapol.itmnumdig,
       succod               like datrservapol.itmnumdig,
       prporg               like datmavisrent.prporg,
       prpnumdig            like datmavisrent.prpnumdig,
       avioccdat            like datmavisrent.avioccdat

end record
define mr_ret               record
       err                  smallint,
       msg                  char(80)
end record
define m_flgprep            smallint,
       m_onde               char(80),
       m_chave              char(80)

# LIBERACAO DE CARRO-EXTRA COMO BENEFICIO.
#-------------------------------------------------------------------------------
function ctx01g03_solicitacoes()
#-------------------------------------------------------------------------------

   #=> ABRE JANELA
   open window w_ctx01g03 at 4, 2 with form "ctx01g03"
    attribute (form line 1)

   let int_flag = false

   initialize mr_tela.* to null
    #=> SOLICITA ('INPUT') O CODIGO DA SUCURSAL
   input by name mr_tela.* without defaults

      before field succod
         display by name mr_tela.succod attribute(reverse)

      after field succod
         display by name mr_tela.succod
         if mr_tela.succod is null then
            #=> POPUP DE SUCURSAIS
            call c24geral11()
                 returning mr_tela.*
            let int_flag = false
            display by name mr_tela.sucnom
         else
            #=>OBTEM NOME DA SUCURSAL
            call cty10g00_nome_sucursal(mr_tela.succod)
                 returning mr_ret.*,
                           mr_tela.sucnom
            if mr_ret.err <> 1 then
               error mr_ret.msg
               next field succod
            end if
         end if
         display by name mr_tela.*

         #=>EXIBE ARRAY DE SERVICOS

         if ctx01g03_array() <> 1 then
            let mr_tela.succod = null
            next field succod
         end if
      on key (f17, interrupt)
         exit input

      on key (accept)
         continue input

   end input

   let int_flag = false
   close window w_ctx01g03

end function

#=> EXIBE ARRAY DE SERVICOS
#-------------------------------------------------------------------------------
function ctx01g03_array()
#-------------------------------------------------------------------------------
   define l_i               smallint

   define l_resultado       smallint
   define l_mensagem        char(80)
   define l_flag            smallint
   let l_flag = 0

   while true

#=>   OBTEM OS SERVICOS DE ALOCACAO
      call ctx01g03_obter_servicos(mr_tela.succod)
           returning mr_ret.*
      if mr_ret.err <> 1 then
         error mr_ret.msg
         exit while
      end if
#=>   EXIBE ('DISPLAY ARRAY') OS SERVICOS
      display array ma_servicos to s_ctx01g03.*

         on key(f5) # DETALHAR
#=>         EXIBE O LAUDO DO SERVICO DE LOCACAO
            let l_i = arr_curr()
            let g_documento.atdsrvnum = ma_aux[l_i].atdsrvnum
            let g_documento.atdsrvano = ma_aux[l_i].atdsrvano
            let g_documento.acao      = "SIN" # Sinistro
            call cts15m00()

         on key(f6) # LIBERAR
              let l_i = arr_curr()
              call ctx01g03_lib_beneficio ( ma_aux[l_i].atdsrvnum,ma_aux[l_i].atdsrvano
                                           ,ma_aux[l_i].succod,ma_aux[l_i].aplnumdig
                                           ,ma_aux[l_i].itmnumdig,ma_aux[l_i].prporg
                                           ,ma_aux[l_i].prpnumdig,ma_aux[l_i].avioccdat)
                   returning l_resultado,l_mensagem
              if l_resultado = 1 then
                 exit display
              else
                 error l_mensagem sleep 2
              end if
##=>         LIBERAR SERVICO DE CARRO-EXTRA
#            let l_i = arr_curr()
#            call ctx01g04_liberar('O',
#                                  ma_aux[l_i].atdsrvnum,
#                                  ma_aux[l_i].atdsrvano,
#                                  ma_aux[l_i].avialgmtv,
#                                  mr_tela.succod,
#                                  ma_aux[l_i].aplnumdig,
#                                  ma_aux[l_i].itmnumdig)
#                 returning mr_ret.*
#            if mr_ret.err = 1 then
#               exit display
#            else
#               error mr_ret.msg
#            end if

         on key(f7) # EXCLUIR
            let l_i = arr_curr()
            call ctx01g03_exc_beneficio( ma_aux[l_i].atdsrvnum
                                        ,ma_aux[l_i].atdsrvano)
               returning l_resultado,l_mensagem
            if l_resultado = 1 then
               exit display
            else
               error l_mensagem sleep 2
            end if

##=>         EXCLUIR O BENEFICIO DE CARRO EXTRA
#            call ctx01g04_excluir(ma_aux[l_i].atdsrvnum,
#                                  ma_aux[l_i].atdsrvano)
#                 returning mr_ret.*
#            if mr_ret.err = 1 then
#               exit display
#            else
#               error mr_ret.msg
#            end if

         on key (f17, accept, interrupt)
            let int_flag = true
            let l_flag = 1
            exit display

      end display
      if int_flag then
         initialize ma_servicos to null
         clear form
         exit while
      end if

      if mr_ret.err <> 1 then
         exit while
      end if

   end while

   let int_flag = false
   if l_flag = 1 then
      return false
   end if
   if mr_ret.err = 1 then
      return true
   else
      return false
   end if

end function

# PRAPARA OS COMANDOS SQL DO MODULO E CRIA TABELA TEMPORARIA
#-------------------------------------------------------------------------------
function ctx01g03_prep()
#-------------------------------------------------------------------------------
   define l_prep            char(1500)

   if m_flgprep then
      return true
   end if
#
   whenever error go to ERROPREP
#
   let m_chave = null

   let m_onde = "preparar cctx01g030101 (DATMAVISRENT)"
   let l_prep = " select a.atdsrvnum, a.atdsrvano, a.avialgmtv, a.lcvsinavsflg, "
               ," a.prporg, a.prpnumdig, a.avioccdat "
               ,"   from datmavisrent a ,datmservico b "
               ,"  where a.atdsrvnum = b.atdsrvnum "
               ,"    and a.atdsrvano = b.atdsrvano "
               ,"    and b.atdsrvorg = 8 "
               ,"    and b.atddat > today - 10 units day "
   prepare pctx01g030101 from l_prep
   declare cctx01g030101 cursor for pctx01g030101

   let m_onde = "criar TEMP TABLE"
   create temp table temp_ctx01g03 (ramcod       smallint,
                                    segnom       char(50),
                                    atddat       date,
                                    atdsrvnum    dec(10,0),
                                    atdsrvorg    smallint,
                                    atdsrvano    dec(02,0),
                                    avialgmtv    dec(03,0),
                                    aplnumdig    dec(09,0),
                                    itmnumdig    dec(07,0),
                                    lcvsinavsflg char(001),
                                    succod       decimal(2,0),
                                    prporg       decimal(2,0),
                                    prpnumdig    decimal(8,0),
                                    avioccdat    date) with no log
   let m_onde = "preparar delete TEMP TABLE"
   let l_prep = "delete from temp_ctx01g03"
   prepare pctx01g030202 from l_prep
   let m_onde = "preparar insert TEMP TABLE"
   let l_prep = "insert into temp_ctx01g03 ",
                "values (?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?)"
   prepare pctx01g030303 from l_prep
   let m_onde = "preparar select TEMP TABLE"
   let l_prep = "select *",
                "  from temp_ctx01g03",
                " order by atddat"
   prepare pctx01g030404 from l_prep
   declare cctx01g030404 cursor for pctx01g030404

#
   whenever error stop
#
   let m_flgprep = true

   return true

label ERROPREP:
#-------------
   let mr_ret.err = 2
   let mr_ret.msg = "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                    " ao ", m_onde clipped

   return false

end function

# OBTER OS SERVICOS DE LOCACAO CARRO-EXTRA PARA LIBERACAO DO BENEFICIO
#-------------------------------------------------------------------------------
function ctx01g03_obter_servicos(l_succod)
#-------------------------------------------------------------------------------
   define l_succod          like datrligapol.succod,
          l_succodaux       like datrligapol.succod,
          l_segnumdig       like gsakseg.segnumdig,
          l_aplnumdig       char(09),
          l_i               smallint,
          l_null            dec(1,0)
   define lr_reg            record
          ramcod            like datrligapol.ramcod,
          segnom            like gsakseg.segnom,
          atddat            like datmservico.atddat,
          atdsrvnum         like datmservico.atdsrvnum,
          atdsrvorg         like datmservico.atdsrvorg,
          atdsrvano         like datmservico.atdsrvano,
          avialgmtv         like datmavisrent.avialgmtv,
          aplnumdig         like datrservapol.aplnumdig,
          itmnumdig         like datrservapol.itmnumdig,
          lcvsinavsflg      like datmavisrent.lcvsinavsflg,
          succod            like datrservapol.itmnumdig,
          prporg            like datmavisrent.prporg,
          prpnumdig         like datmavisrent.prpnumdig,
          avioccdat         like datmavisrent.avioccdat
   end record
   define lr_cty05g01       record
          resultado         char(01),
          dctnumseq         dec(4,0),
          vclsitatu         dec(4,0),
          autsitatu         dec(4,0),
          dmtsitatu         dec(4,0),
          dpssitatu         dec(4,0),
          appsitatu         dec(4,0),
          vidsitatu         dec(4,0)
   end record
   define lr_cty03g00       record
          pestip            like gsakseg.pestip,
          cgccpfnum         like gsakseg.cgccpfnum,
          cgcord            like gsakseg.cgcord,
          cgccpfdig         like gsakseg.cgccpfdig
   end record
   define l_tam   smallint
   let mr_ret.err = 1
   let mr_ret.msg = " "
   let l_null = null
   initialize ma_servicos to null

#=> PREPARA COMANDOS SQL
   if not ctx01g03_prep() then
      return mr_ret.*
   end if
#
   whenever error go to ERROOBTER
#
#=> EXCLUIR REGISTROS ANTERIORES DA TABELA TEMPORARIA
   let m_onde = "deletar TEMP TABLE"
   let m_chave = null
   execute pctx01g030202

#=> LOOPING DOS SERVICOS DE LOCACAO DE CARRO-EXTRA MARCADOS PARA SINISTROS
   let m_onde = "selecionar DATMAVISRENT - cctx01g030101"
   let m_chave = "S"
   #Obter os servicos de locacao de carro extra
   foreach cctx01g030101 into lr_reg.atdsrvnum,
                              lr_reg.atdsrvano,
                              lr_reg.avialgmtv,
                              lr_reg.lcvsinavsflg,
                              lr_reg.prporg,
                              lr_reg.prpnumdig,
                              lr_reg.avioccdat
      #Desprezar as locacoes nao marcadas para avisar sinistro
      if lr_reg.lcvsinavsflg  is null or
         lr_reg.lcvsinavsflg = "N" then
         continue foreach
      end if
#=>   OBTER A APOLICE DO SEGURADO DO SERVICO
      call cts28g00_apol_serv(1, lr_reg.atdsrvnum, lr_reg.atdsrvano)
           returning mr_ret.*,
                     l_succodaux,
                     lr_reg.ramcod,
                     lr_reg.aplnumdig,
                     lr_reg.itmnumdig
      if mr_ret.err <> 1 then
         let mr_ret.err = 2
         continue foreach
      end if
      let lr_reg.succod = l_succodaux

#=>   DESPREZAR APOLICES QUE NAO SAO DA SUCURSAL INFORMADA
      if l_succod is not null and l_succodaux is not null then
         if l_succodaux <> l_succod then
            continue foreach
         end if
      end if

#=>   OBTER ORIGEM DO SERVICO('ATDSRVORG') E DATA DE ATENDIMENTO('ATDDAT')
      call cts10g06_dados_servicos(1, lr_reg.atdsrvnum, lr_reg.atdsrvano)
           returning mr_ret.*,
                     lr_reg.atdsrvorg,
                     lr_reg.atddat
      if mr_ret.err <> 1 then
         let mr_ret.err = 2
         continue foreach
      end if
#=>   OBTER A ULTIMA SITUACAO DA APOLICE
      call cty05g01_ultsit_apolice(l_succodaux,
                                   lr_reg.aplnumdig,
                                   lr_reg.itmnumdig)
           returning lr_cty05g01.*
      if lr_cty05g01.resultado <> "O" then
         let mr_ret.err = 2
         let mr_ret.msg = "Ultima situacao da apolice nao encontrada.",
                          " AVISE A INFORMATICA!"
         continue foreach
      end if
      call figrc072_setTratarIsolamento()

#=>   OBTER CODIGO DO SEGURADO
      call cty05g00_segnumdig(l_succodaux,
                              lr_reg.aplnumdig,
                              lr_reg.itmnumdig,
                              lr_cty05g01.dctnumseq,
                              l_null,
                              l_null)
           returning mr_ret.*,
                     l_segnumdig
      if g_isoAuto.sqlCodErr <> 0 then
         let mr_ret.err = g_isoAuto.sqlCodErr
      end if
      if mr_ret.err <> 1 then
         let mr_ret.err = 2
         continue foreach
      end if

#=>   OBTER O NOME DO SEGURADO
      call cty03g00_dados_segurado(l_segnumdig)
           returning mr_ret.*,
                     lr_reg.segnom,
                     lr_cty03g00.*
      if mr_ret.err <> 1 then
         initialize lr_cty03g00.* to null
         let lr_reg.segnom = null
         let mr_ret.err = 1
      end if
#=>   GRAVA REGISTRO NA TABELA TEMPORARIA
      let m_onde = "inserir TEMP TABLE"
      let m_chave = null
      execute pctx01g030303 using lr_reg.*

      let m_onde = "selecionar DATMAVISRENT - cctx01g030101"
      let m_chave = "S"
   end foreach
   if mr_ret.err = 2 then
      return mr_ret.*
   end if
#=> LOOPING DOS SERVICOS ORDENADOS POR 'ATDDAT'
   let l_i = 1
   let m_onde = "selecionar TEMP TABLE"
   let m_chave = null
   foreach cctx01g030404 into lr_reg.*

#=>   MOVIMENTA/FORMATA PARA EXIBICAO NA TELA
      let ma_servicos[l_i].ramcod  = lr_reg.ramcod
      let ma_servicos[l_i].segnom  = lr_reg.segnom
      let ma_servicos[l_i].atddat  = lr_reg.atddat
      let ma_aux[l_i].atdsrvnum    = lr_reg.atdsrvnum
      let ma_aux[l_i].atdsrvorg    = lr_reg.atdsrvorg
      let ma_aux[l_i].atdsrvano    = lr_reg.atdsrvano
      let ma_aux[l_i].avialgmtv    = lr_reg.avialgmtv
      let ma_aux[l_i].aplnumdig    = lr_reg.aplnumdig
      let ma_aux[l_i].itmnumdig    = lr_reg.itmnumdig
      let ma_aux[l_i].succod       = lr_reg.succod
      let ma_aux[l_i].prporg       = lr_reg.prporg
      let ma_aux[l_i].prpnumdig    = lr_reg.prpnumdig
      let ma_aux[l_i].avioccdat    = lr_reg.avioccdat
      let l_aplnumdig = ma_aux[l_i].aplnumdig
      let l_tam = length(l_aplnumdig)
      let ma_servicos[l_i].aplnum  = l_aplnumdig[1,l_tam -1]
      let ma_servicos[l_i].apldig  = l_aplnumdig[l_tam,l_tam]
      let ma_servicos[l_i].servico = ma_aux[l_i].atdsrvorg using "&&", "/",
                                     ma_aux[l_i].atdsrvnum using "&&&&&&&", "-",
                                     ma_aux[l_i].atdsrvano using "&&"

#=>   PROXIMA OCORRENCIA
      let l_i = l_i + 1
      if l_i > 200 then
         error "Quantidade de servicos (200) excedida!"
         sleep 2
         exit foreach
      end if

   end foreach
#
   whenever error stop
#
   let l_i =  l_i - 1
   if l_i = 0 then
      let mr_ret.err = 2
      let mr_ret.msg = "Nao existem servicos de locacao para liberacao"
   else
      call set_count(l_i)
   end if

   return mr_ret.*

label ERROOBTER:
#--------------
   let mr_ret.err = 2
   let mr_ret.msg = "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                    " ao ", m_onde clipped, " com ", m_chave

   return mr_ret.*

end function

#--------------------------------------------------------
function ctx01g03_lib_beneficio (lr_param)
#--------------------------------------------------------

 define lr_param  record
   atdsrvnum      like datmservico.atdsrvnum
  ,atdsrvano      like datmservico.atdsrvano
  ,succod         like datrligapol.succod
  ,aplnumdig      like datrservapol.aplnumdig
  ,itmnumdig      like datrservapol.itmnumdig
  ,prporg         like datmavisrent.prporg
  ,prpnumdig      like datmavisrent.prpnumdig
  ,avioccdat      like datmavisrent.avioccdat
 end record
 define l_resultado smallint
 define l_mensagem  char(80)
 define l_msg1      char(40)
 define l_msg2      char(40)
 define l_confirma  char(001)
 define l_motivo    decimal(1,0)
 define l_hora      like datmservico.atdhor
 define l_code      integer
 define l_tabname   char (30)

 #Verificar consistencias no sinistro
 call ctx01g04_ver_sinistro (lr_param.atdsrvnum
                            ,lr_param.atdsrvano
                            ,lr_param.succod
                            ,lr_param.aplnumdig
                            ,lr_param.itmnumdig)
    returning l_resultado,l_mensagem,l_motivo
 if l_resultado = 2 then
    let l_msg1 = l_mensagem[1,40]
    let l_msg2 = l_mensagem[41,75]
    let l_confirma = cts08g01("A","S",l_msg1,l_msg2,"CONFIRMA A LIBERACAO", "")
 end if
 if l_resultado = 1 or
    l_confirma = "S" then

    if l_motivo = 3 then
       #Interface com Sinistro
       call sinitfopc ("", "", lr_param.succod,lr_param.aplnumdig
                      ,lr_param.itmnumdig,lr_param.prporg,lr_param.prpnumdig
                      ,lr_param.avioccdat,"", 'C', 999999, 'S')
          returning l_code,l_tabname
       if l_code <> 0 then
          let l_resultado = 2
          let l_mensagem =  "Erro ", l_code, " na interface com sinistro - ", l_tabname
          return l_resultado,l_mensagem
       end if
    end if
    #Atualizar o motivo e desmarcar a solicitacao de beneficio
    call ctx01g06_liberar(lr_param.atdsrvnum,lr_param.atdsrvano,l_motivo,"N")
       returning l_resultado,l_mensagem
    if l_resultado = 1 then
       let g_documento.acao = "SIN"
       #Incluir no historico do servico
       let l_hora = current
       call cts10n00(lr_param.atdsrvnum,lr_param.atdsrvano, g_issk.funmat,
                                               today, l_hora)
    end if
 end if
return l_resultado,l_mensagem
end function

#------------------------------------
function ctx01g03_exc_beneficio (lr_param)
#------------------------------------

 define lr_param   record
    atdsrvnum      like datmservico.atdsrvnum
   ,atdsrvano      like datmservico.atdsrvano
 end record
 define l_confirma  char(001)
 define l_resultado smallint
 define l_mensagem  char(80)
 define l_hora      like datmservico.atdhor
 #Confirmar a exclusao
 let l_confirma = cts08g01 ("A","S", "","", "CONFIRMA EXCLUSAO ? ","")
 if l_confirma = "N" then
    return 1,""
 end if
 call ctx01g06_excluir(lr_param.atdsrvnum,lr_param.atdsrvano, "N")
    returning l_resultado,l_mensagem
 if l_resultado = 1 then
    #Incluir a justificativa da exclusao no historico do servico
    let g_documento.acao = "SIN"  #sinistro
    let l_hora = current
    call cts10n00 (lr_param.atdsrvnum,lr_param.atdsrvano, g_issk.funmat,today, l_hora)
 end if
 return l_resultado,l_mensagem

end function
