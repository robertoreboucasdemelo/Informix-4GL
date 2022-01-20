#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : ctc72m00.4gl                                        #
# Analista Resp.: Priscila Staingel                                   #
# OSF/PSI       : 195138                                              #
#                Cadastro de parametros para acionamento automático   #
#                                                                     #
# Desenvolvedor  : Priscila Staingel                                  #
# DATA           : 26/10/2005                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 02/10/2006  Ligia Mattge   PSI202363 Campo distancia por cidade sede#
#---------------------------------------------------------------------#
# 10/11/2006  Priscila       AS        Chamar funcao para acessar     #
#                                      datrcidsed                     #
#---------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_ctc72m00       record
          atdsrvorg    like  datkatmacnprt.atdsrvorg,
          srvtipdes    like  datksrvtip.srvtipdes,
          vigincdat    like  datkatmacnprt.vigincdat,
          ##atdvtrdst    like  datkatmacnprt.atdvtrdst, # PSI 202363
          acnlmttmp    like  datkatmacnprt.acnlmttmp,
          ##acntntlmtqtd like  datkatmacnprt.acntntlmtqtd, #ligia 27/12/06
          netacnflg    like  datkatmacnprt.netacnflg,
          cplSitNet    char(10),
          caddat       like  datkatmacnprt.caddat,
          cadhor       like  datkatmacnprt.cadhor,
          cadmat       like  datkatmacnprt.cadmat,
          cadFunnom    like  isskfunc.funnom,
          atldat       like  datkatmacnprt.atldat,
          atlhor       like  datkatmacnprt.atlhor,
          atlmat       like  datkatmacnprt.atlmat,
          altFunnom    like  isskfunc.funnom
end record

define mr_ctc72m002   record
          atmacnprtcod like datkatmacnprt.atmacnprtcod,
          cademp       like  datkatmacnprt.cademp,
          atlemp       like  datkatmacnprt.atlemp
end record

define am_ctc72m00 array[500] of record
          cidnom          like glakcid.cidnom,
          ufdcod          like glakcid.ufdcod,
          cidacndst       like datracncid.cidacndst,
          atdprvtmp       like datracncid.atdprvtmp,
          acnsttflg       like datracncid.acnsttflg,
          cplSitFlg       char(10),
          atdhrrfxahorqtd like datracncid.atdhrrfxahorqtd
end record

define am_ctc72m002 array[500] of record
          cidcod     like datracncid.cidcod
end record

define m_prepara_sql     smallint,
       m_consulta_ativa  smallint,
       m_linha           smallint,
       m_count           smallint,
       m_total           smallint,
       m_aux             smallint



#------------------------#
function ctc72m00_prep()
#------------------------#
  define l_sql_stmt    char(1500)

  #Busca registros na tabela de parametros
  let l_sql_stmt = 'select atmacnprtcod, '
                  ,'  atdsrvorg, vigincdat, '
                  ###,'  atdvtrdst, acnlmttmp, ' ## PSI 202363
                  ,'  acnlmttmp, '
                  ###,'  acntntlmtqtd, netacnflg, ' #ligia 27/12/06
                  ,'   netacnflg, '
                  ,'  caddat, cadhor, cademp, '
                  ,'  cadmat, atldat, atlhor, '
                  ,'  atlemp, atlmat '
                  ,' from datkatmacnprt'
                  ,' where (1 = ? or atdsrvorg = ?)'
                  ,'   and (1 = ? or vigincdat = ?)'
                  ,' order by atdsrvorg,  '
                  ,'          vigincdat desc'
  prepare pctc72m00002 from l_sql_stmt
  declare cctc72m00002 scroll cursor for pctc72m00002

  #Busca registros na tabela de cidades para o parametros de acionamento
  let l_sql_stmt = ' select a.cidcod, a.acnsttflg, '
                  ,'   b.cidnom, b.ufdcod, a.cidacndst, a.atdprvtmp, a.atdhrrfxahorqtd '
                  ,'  from datracncid a, glakcid b '
                  ,'  where atmacnprtcod = ?       '
                  ,'    and a.cidcod = b.cidcod    '
  prepare pctc72m00003 from l_sql_stmt
  declare cctc72m00003  cursor with hold for  pctc72m00003

  #Insere registro na tabela de parametros de acionamento
  let l_sql_stmt = ' insert into datkatmacnprt '
                 , '(atmacnprtcod, atdsrvorg, vigincdat, '
                 , ' atdvtrdst, acnlmttmp, acntntlmtqtd, '
                 , ' netacnflg, caddat, cadhor, cademp,  '
                 , ' cadmat, atldat, atlhor, atlemp, atlmat)'
                 , ' values ( ?, ?, ?,                   '
                 , '          0, ?, 0,                   '
                 , '          ?, ?, ?, ?,                '
                 , '          ?, ?, ?, ?, ?)             '
   prepare pctc72m00004 from l_sql_stmt

   #Busca o maior código de parametro de acionamento
   let l_sql_stmt = ' select max(atmacnprtcod) '
                   ,' from datkatmacnprt'
   prepare pctc72m00005 from l_sql_stmt
   declare cctc72m00005 cursor for pctc72m00005

   #Busca registro para um servico com certa data de vigencia
   let l_sql_stmt = ' select atmacnprtcod from datkatmacnprt '
                  , ' where atdsrvorg = ? '
                  , '   and vigincdat = ? '
   prepare pctc72m00006 from l_sql_stmt
   declare cctc72m00006 cursor for pctc72m00006

   #Priscila AS - 10/11
   #Verifica se cidade eh cidade sede
   #let l_sql_stmt = 'select count(cidcod) '
   #               , 'from datrcidsed      '
   #               , 'where cidsedcod = ?  '
   #prepare pctc72m00008  from l_sql_stmt
   #declare cctc72m00008 cursor for pctc72m00008

   #Inserir registros na tabela de cidade sede para parametro de acionamento
   let l_sql_stmt = 'insert into datracncid '
                  , ' (atmacnprtcod, cidcod, cidacndst, atdprvtmp, acnsttflg,atdhrrfxahorqtd) '
                  , ' values (?, ?, ?, ?, ?, ?) '
   prepare pctc72m00009 from l_sql_stmt

   #Excluir registros na tabela de cidade sede para parametro de acionamento
   let l_sql_stmt = 'delete from datracncid '
                   ,' where atmacnprtcod = ?'
   prepare pctc72m00010 from l_sql_stmt

   #Excluir registros na tabela de parametros de acionamento
   let l_sql_stmt = 'delete from datkatmacnprt '
                   ,' where atmacnprtcod = ?   '
   prepare pctc72m00011 from l_sql_stmt

 let m_prepara_sql = true
end function

#-----------------#
function ctc72m00()
#-----------------#
 define l_consulta  char(01)
 define l_ret  smallint

 let m_consulta_ativa = false
 let m_count = 0
 let m_linha = 0
 let m_total = 0

  if m_prepara_sql is null or
     m_prepara_sql <> true then
     call ctc72m00_prep()
  end if

 open window ctc72m00 at 4,2 with form "ctc72m00"
 attribute (comment line last)

 menu "Opcao"

    before menu
       clear form

    command key("I") "Incluir" "Inclui novos parametros."
            message " "
            clear form
            call ctc72m00_incluir()

    command key("S") "Selecionar" "Seleciona um parametro."
            message " "
            clear form
            call ctc72m00_selecionar()

    command key("P") "Proximo" "Vai para o próximo parametro."
            message " "
            if m_consulta_ativa = true then
               let l_consulta = "P"
               if not ctc72m00_busca_dados(l_consulta) then
                  error "Nao existem registros nessa direcao"
               end if
            else
               error "Nenhuma linha foi selecionada! "
               next option "Selecionar"
            end if

    command key("A") "Anterior" "Vai para o parametro anterior."
            message " "
            if m_consulta_ativa = true then
               let l_consulta = "A"
               if not ctc72m00_busca_dados(l_consulta) then
                  error "Nao existem registros nessa direcao"
               end if
            else
               error "Nenhuma linha foi selecionada! "
               next option "Selecionar"
            end if

    command key("M") "Modificar" "Modifica um parametro."
            message " "
            if m_consulta_ativa then
               call ctc72m00_modificar()
            else
               error "Nenhum registro foi selecionado! Utilize primeiro a opcao Seleciona. "
               next option "Selecionar"
            end if

    command key (interrupt,"E") "Encerra" "Retorna ao menu anterior"
            exit menu
 end menu

 close window ctc72m00

end function

#----------------------------#
function ctc72m00_incluir()
#----------------------------#
  define l_funcao       char(11),
         l_ret          smallint

  let l_ret = true
  let l_funcao = 'inclusao'
  let m_total = 0
  let m_count = 0
  let m_linha = 0

  initialize mr_ctc72m00.*   to null
  initialize mr_ctc72m002.*   to null
  initialize am_ctc72m00     to null

  if not ctc72m00_entrada_dados(l_funcao) then
     ##funcao que retorna data e hora (hour to second)
     call cts40g03_data_hora_banco(1)
          returning mr_ctc72m00.caddat, mr_ctc72m00.cadhor
     let mr_ctc72m00.cadmat    = g_issk.funmat
     let mr_ctc72m00.cadFunnom = g_issk.funnom
     let mr_ctc72m002.cademp   = g_issk.empcod
     display by name mr_ctc72m00.caddat
     display by name mr_ctc72m00.cadhor
     display by name mr_ctc72m00.cadmat
     display by name mr_ctc72m00.cadFunnom

     #chama funcao que carrega dados da cidade
     call ctc72m00_entrada_dados_cidade(l_funcao)
     if int_flag = false then
        #gravar dados nas tabelas
        call ctc72m00_gravar(l_funcao)
     else
        error "Inclusao cancelada! - Nao pressionada tecla f8!"
     end if
  end if

  if int_flag = true then
     clear form
  end if

end function

#----------------------------------------#
function ctc72m00_entrada_dados(l_funcao)
#----------------------------------------#
#entrada dados para os campos origem, vigencia, distancia, tempo, tentativas,
#aciona internet, cadastrado, atualizado
#se ok chama a funcao para entrada de dados do campo cidade sede
 define l_funcao  char(11)
 define l_ret smallint
 define l_mensagem  char(100)

 let int_flag = false

 input by name mr_ctc72m00.* without defaults

   before field atdsrvorg
        #caso seja manutencao nao pode alterar servico origem e data vigencia
        if l_funcao = 'modificacao' then
           next field acnlmttmp
        end if
        display by name mr_ctc72m00.atdsrvorg attribute (reverse)

   after field atdsrvorg
        display by name mr_ctc72m00.atdsrvorg
        if mr_ctc72m00.atdsrvorg is not null then
             call cts35g00_descricao_orig_servico(mr_ctc72m00.atdsrvorg)
                  returning l_ret,
                            l_mensagem,
                            mr_ctc72m00.srvtipdes
             if l_ret <> 0 then
                if l_ret = 1 and l_funcao = 'inclusao' then #nao encontrou
                   call cts35g00_lista_origem_servico()
                      returning l_ret,
                                mr_ctc72m00.atdsrvorg,
                                mr_ctc72m00.srvtipdes
                else
                   error l_mensagem
                   exit input
                end if
             else
                if l_funcao = 'seleciona' then
                   #verificar se existe esse codigo na tabela de parametros
                   call cts32g00_busca_codigo_acionamento(mr_ctc72m00.atdsrvorg)
                        returning l_ret,
                                  mr_ctc72m002.atmacnprtcod,
                                  mr_ctc72m00.netacnflg
                   if l_ret <> 0 then
                      error "Servico nao cadastrado na tabela de parametros!!"
                   end if
                end if
             end if
        else
             if l_funcao = 'inclusao' then
                call cts35g00_lista_origem_servico()
                     returning l_ret,
                               mr_ctc72m00.atdsrvorg,
                               mr_ctc72m00.srvtipdes
                #caso nao tenha selecionado nenhum codigo de origem de servico
                if mr_ctc72m00.srvtipdes is null or
                   mr_ctc72m00.atdsrvorg is null then
                      error "Informe um servico!!"
                      next field atdsrvorg
                end if
             end if
        end if

        display by name mr_ctc72m00.atdsrvorg
        display by name mr_ctc72m00.srvtipdes
        # a selecao e feita apenas pelo atdsrvorg
        if l_funcao = 'seleciona' then
             exit input
        end if

     before field vigincdat
          display by name mr_ctc72m00.vigincdat attribute (reverse)
     after field vigincdat
          display by name mr_ctc72m00.vigincdat
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atdsrvorg
          end if
          if mr_ctc72m00.vigincdat is null then
             error "Data de Vigencia obrigatoria!!"
             next field vigincdat
          end if
          #buscar se ja existe esse servico para a mesma data de vigencia
          open cctc72m00006 using mr_ctc72m00.atdsrvorg,
                                  mr_ctc72m00.vigincdat
          whenever error continue
          fetch cctc72m00006 into mr_ctc72m002.atmacnprtcod
          whenever error stop
          if sqlca.sqlcode <> 100 then
                error 'Servico ja cadastrado para essa data de vigencia!'
                next field vigincdat
          end if

     before field acnlmttmp
          display by name mr_ctc72m00.acnlmttmp attribute (reverse)
     after field acnlmttmp
          display by name mr_ctc72m00.acnlmttmp
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field acnlmttmp
          end if
          if mr_ctc72m00.acnlmttmp is null then
             error "Informe o tempo minimo para acionamento agendado!!"
             next field acnlmttmp
          end if
{
     before field acntntlmtqtd
          display by name mr_ctc72m00.acntntlmtqtd attribute (reverse)
     after field acntntlmtqtd
          display by name mr_ctc72m00.acntntlmtqtd
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field acnlmttmp
          end if
          if mr_ctc72m00.acntntlmtqtd is null then
             error "Informe a quantidade de tentativas de acionamento."
             next field acntntlmtqtd
          end if
}  ## ligia 27/12/06

     before field netacnflg
          display by name mr_ctc72m00.netacnflg attribute (reverse)
     after field netacnflg
          display by name mr_ctc72m00.netacnflg
          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field acnlmttmp
          end if
          if mr_ctc72m00.netacnflg is null or
            (mr_ctc72m00.netacnflg <> 'A' and mr_ctc72m00.netacnflg <> 'I')
            then
             error "Flag Internet: A - Ativo  I-Inativo"
             next field netacnflg
          else
             if mr_ctc72m00.netacnflg = 'A' then
                let mr_ctc72m00.cplSitNet = 'Ativo'
             else
                let mr_ctc72m00.cplSitNet = 'Inativo'
             end if
             display by name mr_ctc72m00.cplSitNet
          end if

     on key (f17, control-c, interrupt)
          let int_flag = true
          exit input

   end input

   return int_flag
end function


#----------------------------------------#
function ctc72m00_entrada_dados_cidade(l_funcao)
#----------------------------------------#
   define l_funcao char(11),
          l_aux    smallint ,
          l_ret    smallint,
          l_mensagem  char (100)

   let l_aux = null
   let l_ret = null
   let l_mensagem = null

     call set_count(m_count)
     #call set_count(m_count - 1)

   input array am_ctc72m00 without defaults from s_tela.*

   before row
        let m_linha = scr_line()
        let m_count = arr_curr()
        let m_total = arr_count()

   before field cidnom
       display am_ctc72m00[m_count].cidnom to s_tela[m_linha].cidnom attribute (reverse)
   after field cidnom
       display am_ctc72m00[m_count].cidnom to s_tela[m_linha].cidnom
       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if am_ctc72m00[m_count].cidnom is null then
             error "Pressione f17 para cancelar ou f8 para gravar!"
             next field cidnom
          end if
       end if

   before field ufdcod
       display am_ctc72m00[m_count].ufdcod to s_tela[m_linha].ufdcod attribute (reverse)
   after field ufdcod
       display am_ctc72m00[m_count].ufdcod to s_tela[m_linha].ufdcod
       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
           next field cidnom
       end if
       #Buscar codigo para essa cidade e estado
       call cty10g00_obter_cidcod(am_ctc72m00[m_count].cidnom,
                                  am_ctc72m00[m_count].ufdcod)
            returning l_ret,
                      l_mensagem,
                      am_ctc72m002[m_count].cidcod

       if l_ret <> 0 then
             if l_ret = 1 then
                 call cts06g04(am_ctc72m00[m_count].cidnom,
                               am_ctc72m00[m_count].ufdcod)
                     returning am_ctc72m002[m_count].cidcod,
                               am_ctc72m00[m_count].cidnom,
                               am_ctc72m00[m_count].ufdcod
                 if am_ctc72m00[m_count].cidnom is null then
                     next field cidnom
                 end if
             else
                 error l_mensagem
                 next field cidnom
             end if
       end if

       call ctd01g00_verifica_cidsed(1, am_ctc72m002[m_count].cidcod)
            returning l_ret,
                      l_mensagem
       if l_ret <> 1 then
          error "cidade nao e cidade sede" sleep 2
          next field cidnom
       end if

     before field cidacndst
          display am_ctc72m00[m_count].cidacndst to s_tela[m_linha].cidacndst
                  attribute (reverse)

     after field cidacndst
          display am_ctc72m00[m_count].cidacndst to s_tela[m_linha].cidacndst

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
              next field ufdcod
          end if

          if am_ctc72m00[m_count].cidacndst is null then
             error "Distancia deve ser informada!!"
             next field cidacndst
          end if

     before field atdprvtmp
          display am_ctc72m00[m_count].atdprvtmp to s_tela[m_linha].atdprvtmp
                  attribute (reverse)

     after field atdprvtmp
          display am_ctc72m00[m_count].atdprvtmp to s_tela[m_linha].atdprvtmp

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
              next field cidacndst
          end if

   before field acnsttflg
       display am_ctc72m00[m_count].acnsttflg to s_tela[m_linha].acnsttflg attribute (reverse)
   after field acnsttflg
       display am_ctc72m00[m_count].acnsttflg to s_tela[m_linha].acnsttflg
       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
           next field atdhrrfxahorqtd
       end if

       if am_ctc72m00[m_count].acnsttflg is null or
         (am_ctc72m00[m_count].acnsttflg <> 'A' and am_ctc72m00[m_count].acnsttflg <> 'I')
         then
          error "Flag: A - Ativo  I-Inativo"
          next field acnsttflg
       else
          if am_ctc72m00[m_count].acnsttflg = 'A' then
             let am_ctc72m00[m_count].cplSitFlg = 'Ativo'
          else
             let am_ctc72m00[m_count].cplSitFlg = 'Inativo'
          end if
          display am_ctc72m00[m_count].cplSitFlg to s_tela[m_linha].cplSitFlg
       end if


   before field atdhrrfxahorqtd
       display am_ctc72m00[m_count].atdhrrfxahorqtd to s_tela[m_linha].atdhrrfxahorqtd attribute (reverse)


   after field atdhrrfxahorqtd
       display am_ctc72m00[m_count].atdhrrfxahorqtd to s_tela[m_linha].atdhrrfxahorqtd

       if am_ctc72m00[m_count].atdhrrfxahorqtd is null or
            (am_ctc72m00[m_count].atdhrrfxahorqtd < 0 or am_ctc72m00[m_count].atdhrrfxahorqtd > 23) then
             error "Favor digitar um valor inteiro no intervalo de 0 a 23"
             next field atdhrrfxahorqtd
       end if


     on key (f17, control-c, interrupt)
          let int_flag = true
          exit input

     on key (f8)

     	  if am_ctc72m00[m_count].atdhrrfxahorqtd is null or
            (am_ctc72m00[m_count].atdhrrfxahorqtd < 0 or am_ctc72m00[m_count].atdhrrfxahorqtd > 23) then
             error "Favor digitar um valor inteiro no intervalo de 0 a 23"
             next field atdhrrfxahorqtd
          else
          let int_flag = false
          exit input
          end if

   end input

end function

#------------------------------#
 function ctc72m00_selecionar()
#------------------------------#
  define l_funcao       char(11),
         l_consulta     char(01),
         l_aux          smallint,
         l_aux2         smallint

  let l_funcao = 'seleciona'

  initialize mr_ctc72m00.*   to null
  initialize mr_ctc72m002.*   to null
  initialize am_ctc72m00     to null

  if not ctc72m00_entrada_dados(l_funcao) then
     #a busca pode ser feita apenas pela origem ou todos os registros
     if mr_ctc72m00.atdsrvorg is null then
        let l_aux = 1    #buscar todos os registros
     else
        let l_aux = 0    #buscar apenas o digitado
     end if

     let l_aux2 = 1
     #abre cursor para buscar dados
     open cctc72m00002 using l_aux,
                             mr_ctc72m00.atdsrvorg,
                             l_aux2,
                             mr_ctc72m00.vigincdat
     let l_consulta = 'P'
     if ctc72m00_busca_dados(l_consulta) then
        let m_consulta_ativa = true
     else
        error "Nao ha registros na selecao efetuada!! "
     end if
  end if

end function

#---------------------------------------#
function ctc72m00_busca_dados(l_consulta)
#---------------------------------------#
  define l_consulta  char(01),
         l_flag      smallint,
         l_erro      smallint,
         l_aux       smallint,
         l_mensagem  char(60)

  #initialize mr_ctc72m00.*   to null
  #initialize mr_ctc72m002.*   to null

  let l_flag = true
  let m_linha = 1
  whenever error continue
  if l_consulta <> "A" then
     whenever error continue
     fetch next cctc72m00002 into mr_ctc72m002.atmacnprtcod,
                                  mr_ctc72m00.atdsrvorg,
                                  mr_ctc72m00.vigincdat,
                                  ###mr_ctc72m00.atdvtrdst, ## PSI 202363
                                  mr_ctc72m00.acnlmttmp,
                                  ##mr_ctc72m00.acntntlmtqtd, #ligia 27/12/06
                                  mr_ctc72m00.netacnflg,
                                  mr_ctc72m00.caddat,
                                  mr_ctc72m00.cadhor,
                                  mr_ctc72m002.cademp,
                                  mr_ctc72m00.cadmat,
                                  mr_ctc72m00.atldat,
                                  mr_ctc72m00.atlhor,
                                  mr_ctc72m002.atlemp,
                                  mr_ctc72m00.atlmat
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = 100 then
            let l_flag = false
         else
            error "ERRO SQL - cctc72m00002: ",sqlca.sqlcode," / ",sqlca.sqlerrd[2]

            let l_flag = false
         end if
      else
         #buscar descricao do servico
         call cts35g00_descricao_orig_servico(mr_ctc72m00.atdsrvorg)
              returning l_erro,
                        l_mensagem,
                        mr_ctc72m00.srvtipdes
         if l_erro <> 0 then
            error 'Tipo de servico invalido - sem descricao'
         end if

         #buscar nome do funcionario
         call cty08g00_nome_func(mr_ctc72m002.cademp, mr_ctc72m00.cadmat, 'F')
              returning l_erro,
                        l_mensagem,
                        mr_ctc72m00.cadFunnom
         if mr_ctc72m00.atlmat is not null then
            #buscar nome do funcionario que fez alteracao
            call cty08g00_nome_func(mr_ctc72m002.atlemp, mr_ctc72m00.atlmat, 'F')
                 returning l_erro,
                           l_mensagem,
                           mr_ctc72m00.altFunnom
         else
            let mr_ctc72m00.altFunnom = null
         end if

         #validar flag Internet(Ativo-Inativo)
         if mr_ctc72m00.netacnflg = 'A' then
            let mr_ctc72m00.cplSitNet = 'Ativo'
         else
            let mr_ctc72m00.cplSitNet = 'Inativo'
         end if

         display by name mr_ctc72m00.*

         initialize am_ctc72m00     to null
         #buscar cidades sede desse parametro
         open cctc72m00003 using mr_ctc72m002.atmacnprtcod
         let m_count = 1
         foreach cctc72m00003 into am_ctc72m002[m_count].cidcod,
                                   am_ctc72m00[m_count].acnsttflg,
                                   am_ctc72m00[m_count].cidnom,
                                   am_ctc72m00[m_count].ufdcod,
                                   am_ctc72m00[m_count].cidacndst,
                                   am_ctc72m00[m_count].atdprvtmp,
                                   am_ctc72m00[m_count].atdhrrfxahorqtd
            if am_ctc72m00[m_count].acnsttflg = 'A' then
               let am_ctc72m00[m_count].cplSitFlg = 'Ativo'
            else
               let am_ctc72m00[m_count].cplSitFlg = 'Inativo'
            end if
            let m_count = m_count + 1
            if m_count > 1000 then
               exit foreach
            end if
         end foreach
         close cctc72m00003
      end if
  else
     whenever error continue
     fetch previous cctc72m00002 into mr_ctc72m002.atmacnprtcod,
                                      mr_ctc72m00.atdsrvorg,
                                      mr_ctc72m00.vigincdat,
                                      ##mr_ctc72m00.atdvtrdst, #PSI 202363
                                      mr_ctc72m00.acnlmttmp,
                                      ##mr_ctc72m00.acntntlmtqtd,
                                      mr_ctc72m00.netacnflg,
                                      mr_ctc72m00.caddat,
                                      mr_ctc72m00.cadhor,
                                      mr_ctc72m002.cademp,
                                      mr_ctc72m00.cadmat,
                                      mr_ctc72m00.atldat,
                                      mr_ctc72m00.atlhor,
                                      mr_ctc72m002.atlemp,
                                      mr_ctc72m00.atlmat
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = 100 then
            let l_flag = false
         else
            error "ERRO SQL - cctc72m00002: ",sqlca.sqlcode," / ",sqlca.sqlerrd[2]

            let l_flag = false
         end if
      else
         #buscar descricao do servico
         call cts35g00_descricao_orig_servico(mr_ctc72m00.atdsrvorg)
              returning l_erro,
                        l_mensagem,
                        mr_ctc72m00.srvtipdes

         if l_erro <> 0 then
            error 'Tipo de servico invalido - sem descricao'
         end if

         #buscar nome do funcionario
         call cty08g00_nome_func(mr_ctc72m002.cademp, mr_ctc72m00.cadmat, 'F')
              returning l_erro,
                        l_mensagem,
                        mr_ctc72m00.cadFunnom
         if mr_ctc72m00.atlmat is not null then
            #buscar nome do funcionario que fez alteracao
            call cty08g00_nome_func(mr_ctc72m002.atlemp, mr_ctc72m00.atlmat, 'F')
                 returning l_erro,
                           l_mensagem,
                           mr_ctc72m00.altFunnom
         else
            let mr_ctc72m00.altFunnom = null
         end if

         #validar flag Internet(Ativo-Inativo)
         if mr_ctc72m00.netacnflg = 'A' then
            let mr_ctc72m00.cplSitNet = 'Ativo'
         else
            let mr_ctc72m00.cplSitNet = 'Inativo'
         end if

         display by name mr_ctc72m00.*

         initialize am_ctc72m00     to null
         #buscar cidades sede desse parametro
         open cctc72m00003 using mr_ctc72m002.atmacnprtcod
         let m_count = 1
         foreach cctc72m00003 into am_ctc72m002[m_count].cidcod,
                                   am_ctc72m00[m_count].acnsttflg,
                                   am_ctc72m00[m_count].cidnom,
                                   am_ctc72m00[m_count].ufdcod,
                                   am_ctc72m00[m_count].cidacndst,
                                   am_ctc72m00[m_count].atdprvtmp
            if am_ctc72m00[m_count].acnsttflg = 'A' then
               let am_ctc72m00[m_count].cplSitFlg = 'Ativo'
            else
               let am_ctc72m00[m_count].cplSitFlg = 'Inativo'
            end if
            let m_count = m_count + 1
            if m_count > 500 then
               exit foreach
            end if
         end foreach
         close cctc72m00003
      end if
  end if

  if l_consulta <> 'M' then
  let l_aux = 1
  for m_linha = 1 to 4
      #exibir apenas as 4 primeiras linhas no seleciona
      display am_ctc72m00[l_aux].cidnom  to s_tela[m_linha].cidnom
      display am_ctc72m00[l_aux].ufdcod  to s_tela[m_linha].ufdcod
      display am_ctc72m00[l_aux].cidacndst to s_tela[m_linha].cidacndst
      display am_ctc72m00[l_aux].atdprvtmp to s_tela[m_linha].atdprvtmp
      display am_ctc72m00[l_aux].acnsttflg to s_tela[m_linha].acnsttflg
      display am_ctc72m00[l_aux].cplSitFlg to s_tela[m_linha].cplSitFlg
      display am_ctc72m00[l_aux].atdhrrfxahorqtd to s_tela[m_linha].atdhrrfxahorqtd
      let l_aux = l_aux + 1
  end for
  end if

  if l_flag = false then
     return false
  end if
  return true
end function


#----------------------------#
function ctc72m00_modificar()
#----------------------------#
  define l_funcao  char (11),
         l_consulta char(01),
         l_aux   smallint

  let l_aux = 0
  #Buscar novamente o registro
  open cctc72m00002 using l_aux,
                          mr_ctc72m00.atdsrvorg,
                          l_aux,
                          mr_ctc72m00.vigincdat

  let l_consulta = "M"
  call ctc72m00_busca_dados(l_consulta)
     returning l_aux

  let l_funcao = 'modificacao'

  if not ctc72m00_entrada_dados (l_funcao) then
     call cts40g03_data_hora_banco(1)
          returning mr_ctc72m00.atldat, mr_ctc72m00.atlhor
     let mr_ctc72m00.atlmat    = g_issk.funmat
     let mr_ctc72m00.altFunnom = g_issk.funnom
     let mr_ctc72m002.atlemp   = g_issk.empcod
     display by name mr_ctc72m00.atldat
     display by name mr_ctc72m00.atlhor
     display by name mr_ctc72m00.atlmat
     display by name mr_ctc72m00.altFunnom

     call ctc72m00_entrada_dados_cidade(l_funcao)
     if int_flag = true then
        return
     end if

     #int_flag sera igual a false caso tenha pressionado F8
     if int_flag = false then
        #gravar dados nas tabelas
        call ctc72m00_gravar(l_funcao)
     else
        error "Modificacao cancelada! - Nao pressionada tecla f8!"
     end if

  end if


end function

#--------------------------------#
function ctc72m00_gravar(l_funcao)
#--------------------------------#
  define l_funcao char(11),
         l_ret    smallint,
         l_aux    smallint,
         l_ret_busca smallint,
         l_mensagem char(100)

  let l_ret = true

  if l_funcao = 'inclusao' then
     #buscar proximo atmacnprtcod
     open cctc72m00005
     whenever error continue
     fetch cctc72m00005 into mr_ctc72m002.atmacnprtcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
         error "Problemas ao acessar tabela de parametros!!"
         display "Problemas ao acessar tabela de parametros!!"
         return
     end if
     if mr_ctc72m002.atmacnprtcod is null then
        let mr_ctc72m002.atmacnprtcod = 1
     else
        let mr_ctc72m002.atmacnprtcod = mr_ctc72m002.atmacnprtcod + 1
     end if
     begin work
  else

     #caso seja 'modificacao'
     begin work

     #exclui dados da tabela datracncid
     execute pctc72m00010 using mr_ctc72m002.atmacnprtcod

     #exclui dados da tabela datkatmacnprt
     execute pctc72m00011 using mr_ctc72m002.atmacnprtcod
  end if

  whenever error continue
  execute pctc72m00004 using mr_ctc72m002.atmacnprtcod,
                             mr_ctc72m00.atdsrvorg,
                             mr_ctc72m00.vigincdat ,
                             mr_ctc72m00.acnlmttmp,
                             ##mr_ctc72m00.acntntlmtqtd,
                             mr_ctc72m00.netacnflg,
                             mr_ctc72m00.caddat,
                             mr_ctc72m00.cadhor,
                             mr_ctc72m002.cademp,
                             mr_ctc72m00.cadmat,
                             mr_ctc72m00.atldat,
                             mr_ctc72m00.atlhor,
                             mr_ctc72m002.atlemp,
                             mr_ctc72m00.atlmat
  whenever error stop
  if sqlca.sqlcode <> 0 then
      error "Erro na tabela de parametros ", sqlca.sqlcode
      let l_ret = false
  end if

  if l_ret <> false and m_total > 0 then
     #se a ultima linha for nula
     if am_ctc72m00[m_total].cidnom is null then
         let m_total = m_total - 1
     end if
     for l_aux =1 to m_total
         #busca o codigo da cidade para reorganizar o array do cidcod caso
         # delete linha (f2)
         call cty10g00_obter_cidcod(am_ctc72m00[l_aux].cidnom,
                                  am_ctc72m00[l_aux].ufdcod)
            returning l_ret_busca,
                      l_mensagem,
                      am_ctc72m002[l_aux].cidcod

         if l_ret_busca <> 0 and l_mensagem <> 100 then
             error l_mensagem
         end if
         if am_ctc72m002[l_aux].cidcod is null or
            am_ctc72m00[l_aux].acnsttflg is null then
            let l_ret = false
            exit for
         end if

         whenever error continue
         execute pctc72m00009 using mr_ctc72m002.atmacnprtcod,
                                    am_ctc72m002[l_aux].cidcod,
                                    am_ctc72m00[l_aux].cidacndst,
                                    am_ctc72m00[l_aux].atdprvtmp,
                                    am_ctc72m00[l_aux].acnsttflg,
                                    am_ctc72m00[l_aux].atdhrrfxahorqtd
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = 268 then
                error "Erro dados duplicados"
            else
                error "Erro ao inserir dados na tabela de cidades sede para parametros de acionamento!! "
            end if
            let l_ret = false
            exit for
         end if
     end for
  end if

  if l_ret = false then
     rollback work
     let m_consulta_ativa = false
  else
     commit work
     error "Dados incluidos com sucesso!"
     let m_consulta_ativa = true
  end if
end function
