#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Porto Socorro                                       #
# Modulo        : ctc18m05.4gl                                        #
# Analista Resp.: Priscila Staingel                                   #
# OSF/PSI       : 198390                                              #
#                Cadastro dos locais de entrega de uma loja para      #
#                CARRO EXTA                                           #
#                                                                     #
# Desenvolvedor  : Priscila Staingel                                  #
# DATA           : 14/02/2006                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 05/08/2008  Douglas,Meta   PSI226300 Adicionado o envio de email    #
#                                      para notificacao de inclusao   #
#                                      exclusao de cadastros locais p/#
#                                      entrega                        #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_ctc18m05  record
          lcvcod      like datklcletgvclext.lcvcod,
          lcvnom      like datklocadora.lcvnom,
          aviestcod   like datklcletgvclext.aviestcod,
          aviestnom   like datkavislocal.aviestnom,
          lcvextcod   like datkavislocal.lcvextcod
end record

define am_ctc18m05 array[100] of record
          navega         char(1),
          cidnom         like glakcid.cidnom,
          ufdcod         like glakcid.ufdcod,
          etgtaxvlr      like datklcletgvclext.etgtaxvlr,
          etglclsitflg   like datklcletgvclext.etglclsitflg,
          situacao       char(10),
          caddat         like datklcletgvclext.caddat,
          cademp         like datklcletgvclext.cademp,
          cadmat         like datklcletgvclext.cadmat,
          cadnom         like isskfunc.funnom,
          atldat         like datklcletgvclext.atldat,
          atlemp         like datklcletgvclext.atlemp,
          atlmat         like datklcletgvclext.atlmat,
          atlnom         like isskfunc.funnom
end record

define am_ctc18m0502 array[100] of record
          cidcod         like datklcletgvclext.cidcod,
          cadusrtip      like datklcletgvclext.cadusrtip,
          atlusrtip      like datklcletgvclext.atlusrtip
end record

define m_prepara_sql     smallint,
       m_permissao       smallint,
       m_count           smallint,
       m_arr             smallint

#------------------------#
function ctc18m05_prep()
#------------------------#
  define l_sql_stmt  char(1500)

   #Buscar nome da locadora
   let l_sql_stmt = 'select lcvnom     '
                   ,'from datklocadora '
                   ,'where lcvcod = ?  '
   prepare pctc18m05001  from l_sql_stmt
   declare cctc18m05001 cursor for pctc18m05001

   #Buscar nome da loja
   let l_sql_stmt = 'select aviestcod, aviestnom   '
                   ,'from datkavislocal '
                   ,'where lcvcod = ?   '
                   ,' and lcvextcod = ? '
   prepare pctc18m05002  from l_sql_stmt
   declare cctc18m05002 cursor for pctc18m05002

   #Buscar nome da loja pelo aviestcod (codigo da loja)
   let l_sql_stmt = 'select lcvextcod, aviestnom   '
                   ,'from datkavislocal '
                   ,'where lcvcod = ?   '
                   ,' and aviestcod = ? '
   prepare pctc18m05003  from l_sql_stmt
   declare cctc18m05003 cursor for pctc18m05003

   #Buscar registros de cidades de entrega para a loja
   let l_sql_stmt = ' select cidcod, etglclsitflg, etgtaxvlr, '
                   ,' caddat, cademp, cadusrtip, cadmat,      '
                   ,' atldat, atlemp, atlusrtip, atlmat       '
                   ,' from datklcletgvclext                   '
                   ,' where lcvcod = ?                        '
                   ,'   and aviestcod = ?                     '
   prepare pctc18m05004  from l_sql_stmt
   declare cctc18m05004 cursor for pctc18m05004

   #Excluir registro da tabela
   let l_sql_stmt = ' delete from datklcletgvclext '
                   ,' where lcvcod = ?             '
                   ,'   and aviestcod = ?          '
                   ,'   and cidcod = ?             '
   prepare pctc18m05005  from l_sql_stmt

   #Incluir registro na tabela
   let l_sql_stmt = ' insert into datklcletgvclext '
                   ,' (lcvcod, aviestcod, cidcod,  '
                   ,'  etglclsitflg, etgtaxvlr,    '
                   ,'  caddat, cademp, cadusrtip,  '
                   ,'  cadmat, atldat, atlemp,     '
                   ,'  atlusrtip, atlmat) values      '
                   ,' (?,?,?,?,?,?,?,?,?,?,?,?,?)  '
   prepare pctc18m05006  from l_sql_stmt

  let m_prepara_sql = true
end function


#-----------------#
function ctc18m05(l_param)
#-----------------#
  define l_param record
     lcvcod     like datklcletgvclext.lcvcod,
     aviestcod  like datklcletgvclext.aviestcod
  end record

  if m_prepara_sql is null or
     m_prepara_sql <> true then
     call ctc18m05_prep()
  end if

  let m_arr = null

   options
    prompt line last - 1,
    insert key f1,
    delete key control-y

  open window ctc18m05 at 6,2 with form "ctc18m05"
  attribute (form line 1,comment line last - 1)

  if g_issk.acsnivcod >= g_issk.acsnivcns  then
     #permissao para visualizar
     message " (F17)Abandona"
     let m_permissao = false
  end if
  if g_issk.acsnivcod >= g_issk.acsnivatl  then
      #permissao para inserir, excluir
      message " (F17)Abandona, (F1)Inclui, (F2)Exclui, (F6)Altera"
      let m_permissao = true
  end if

  initialize mr_ctc18m05.*   to null
  initialize am_ctc18m05     to null

  let int_flag = false

  let mr_ctc18m05.lcvcod = l_param.lcvcod
  let mr_ctc18m05.aviestcod = l_param.aviestcod

  #Tratamento para locadora e loja
  call ctc18m05_entrada_dados()

  if int_flag = true then
     close window ctc18m05
     return
  end if

  call ctc18m05_busca_dados()

  #chama funcao que carrega locais de entrega da loja
  call ctc18m05_entrada_cidades()

  close window ctc18m05

end function



#----------------------------#
function ctc18m05_entrada_dados()
#----------------------------#

  define l_ret smallint

  input by name mr_ctc18m05.lcvcod, mr_ctc18m05.lcvextcod without defaults

    before field lcvcod
         if mr_ctc18m05.lcvcod is not null and
            mr_ctc18m05.aviestcod is not null then

            #busca nome locadora e nome loja e da display
            open cctc18m05001 using mr_ctc18m05.lcvcod
            fetch cctc18m05001 into mr_ctc18m05.lcvnom

            open cctc18m05003 using mr_ctc18m05.lcvcod,
                                    mr_ctc18m05.aviestcod
            fetch cctc18m05003 into mr_ctc18m05.lcvextcod,
                                    mr_ctc18m05.aviestnom

            display by name mr_ctc18m05.lcvcod
            display by name mr_ctc18m05.lcvnom
            display by name mr_ctc18m05.lcvextcod
            display by name mr_ctc18m05.aviestnom

            exit input
         end if
         display by name mr_ctc18m05.lcvcod attribute (reverse)

    after field lcvcod
         display by name mr_ctc18m05.lcvcod
         if mr_ctc18m05.lcvcod is null then
             error "Codigo da locadora deve ser informado."
             next field lcvcod
         end if
         #buscar nome da locadora
         open cctc18m05001 using mr_ctc18m05.lcvcod
         whenever error continue
         fetch cctc18m05001 into mr_ctc18m05.lcvnom
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = 100 then
                error "Locadora nao encontrada."
                let mr_ctc18m05.lcvcod = null
                let mr_ctc18m05.lcvnom = null
                next field lcvcod
            else
                error "Problemas ao buscar nome da locadora!!"
            end if
          end if
          display by name mr_ctc18m05.lcvnom

    before field lcvextcod
         display by name mr_ctc18m05.lcvextcod attribute (reverse)

    after field lcvextcod
         display by name mr_ctc18m05.lcvextcod
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field lcvcod
         end if
         if mr_ctc18m05.lcvextcod is null then
             error "Codigo da loja deve ser informado."
             next field lcvextcod
         end if
         #buscar nome e codigo da loja
         open cctc18m05002 using mr_ctc18m05.lcvcod,
                                 mr_ctc18m05.lcvextcod
         whenever error continue
         fetch cctc18m05002 into mr_ctc18m05.aviestcod,
                                 mr_ctc18m05.aviestnom
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = 100 then
                error "Loja nao encontrada para Locadora."
                let mr_ctc18m05.lcvextcod = null
                next field lcvextcod
            else
                error "Problemas ao buscar nome da loja!!"
            end if
          end if
          display by name mr_ctc18m05.aviestnom


    on key (f17, control-c, interrupt)
          let int_flag = true
          exit input

  end input

end function


#----------------------------#
function ctc18m05_busca_dados()
#----------------------------#
   define l_mensagem char (60),
          l_resultado smallint

   let m_count = 1

   open cctc18m05004 using mr_ctc18m05.lcvcod,
                           mr_ctc18m05.aviestcod
   foreach cctc18m05004 into am_ctc18m0502[m_count].cidcod,
                             am_ctc18m05[m_count].etglclsitflg,
                             am_ctc18m05[m_count].etgtaxvlr,
                             am_ctc18m05[m_count].caddat,
                             am_ctc18m05[m_count].cademp,
                             am_ctc18m0502[m_count].cadusrtip,
                             am_ctc18m05[m_count].cadmat,
                             am_ctc18m05[m_count].atldat,
                             am_ctc18m05[m_count].atlemp,
                             am_ctc18m0502[m_count].atlusrtip,
                             am_ctc18m05[m_count].atlmat

         #Buscar cidade e estado correspondente ao codigo cidade
         call cty10g00_cidade_uf(am_ctc18m0502[m_count].cidcod)
             returning l_resultado,
                       l_mensagem,
                       am_ctc18m05[m_count].cidnom,
                       am_ctc18m05[m_count].ufdcod

         #Descricao da situação da entrega
         if am_ctc18m05[m_count].etglclsitflg = 'A' then
             let am_ctc18m05[m_count].situacao = 'Ativo'
         else
             let am_ctc18m05[m_count].situacao = 'Cancelado'
         end if

         #Buscar nome do funcionario que cadastrou
         call cty08g00_nome_func(am_ctc18m05[m_count].cademp,
                                 am_ctc18m05[m_count].cadmat,
                                 am_ctc18m0502[m_count].cadusrtip)
              returning l_resultado,
                        l_mensagem,
                        am_ctc18m05[m_count].cadnom
         if am_ctc18m05[m_count].atlmat is not null then
            #buscar nome do funcionario que fez alteracao
            call cty08g00_nome_func(am_ctc18m05[m_count].atlemp,
                                    am_ctc18m05[m_count].atlmat,
                                    am_ctc18m0502[m_count].atlusrtip)
                 returning l_resultado,
                           l_mensagem,
                           am_ctc18m05[m_count].atlnom
         else
            let am_ctc18m05[m_count].atlnom = null
         end if

         let m_count = m_count + 1
         if m_count > 100 then
            exit foreach
         end if
   end foreach
   let m_count = m_count - 1
   close cctc18m05004

end function




#----------------------------#
function ctc18m05_entrada_cidades()
#----------------------------#
  define l_msg char (20),
         l_tela smallint,
         l_arr  smallint,
         l_modifica_chave smallint,
         l_salva_taxa   like datklcletgvclext.etgtaxvlr,
         l_salva_flg  like datklcletgvclext.etglclsitflg,
         l_aux  smallint,
         l_hora2   datetime hour to minute,
         l_operacao   char(1),
         l_aux2       char(300),
         l_mensagem   char(2000),
         l_titulo     char(100),
         l_cmd        char(200),
         l_erro       smallint,
         l_mesg       char(100),
         l_caminho    char(100),
         l_aux3       char(100)

  let l_aux = true
  let l_modifica_chave = false
  let l_operacao = null
  let l_aux2 = null
  let l_aux3 = null
  let l_cmd  = null
  let l_erro = null
  let l_mesg = null
  let l_caminho = null
  call set_count(m_count)

  input array am_ctc18m05 without defaults from s_tela.*

    before row
        let l_tela  = scr_line()
        let l_arr   = arr_curr()


    before field navega
           if l_operacao = "I" then
              next field cidnom
           end if


    after field navega
           if fgl_lastkey() = 2014 and ##f1
              m_permissao = true then  ##usuario tem permissao para inserir
              let l_operacao = "I"
           else
              #se tenta ir para baixo, mas nao tem registro, continua onde está
              if fgl_lastkey() = fgl_keyval('down') then
                  if am_ctc18m05[l_arr + 1].cidnom is null then
                      next field navega
                  else
                      continue input
                  end if
              end if
              #permite ir para cima, qq outra tecla faz com que fique onde está
              if fgl_lastkey() = fgl_keyval('up') then
                 continue input
              else
                 next field navega
              end if
           end if


    before field cidnom
        display am_ctc18m05[l_arr].cidnom to s_tela[l_tela].cidnom attribute (reverse)

    after field cidnom
        display am_ctc18m05[l_arr].cidnom to s_tela[l_tela].cidnom
        if am_ctc18m05[l_arr].cidnom is null then
              error "Cidade deve ser informada."
              next field cidnom
        end if
        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
              next field cidnom
        end if
        if fgl_lastkey() = fgl_keyval("down") then
              next field ufdcod
        end if


    before field ufdcod
       display am_ctc18m05[l_arr].ufdcod to s_tela[l_tela].ufdcod attribute (reverse)

    after field ufdcod
       display am_ctc18m05[l_arr].ufdcod to s_tela[l_tela].ufdcod
       #Buscar codigo para essa cidade e estado
         call cty10g00_obter_cidcod(am_ctc18m05[l_arr].cidnom,
                                    am_ctc18m05[l_arr].ufdcod)
              returning l_aux,
                        l_msg,
                        am_ctc18m0502[l_arr].cidcod

         if l_aux <> 0 then
             if l_aux = 1 then
                 call cts06g04(am_ctc18m05[l_arr].cidnom,
                               am_ctc18m05[l_arr].ufdcod)
                     returning am_ctc18m0502[l_arr].cidcod,
                               am_ctc18m05[l_arr].cidnom,
                               am_ctc18m05[l_arr].ufdcod
                 if am_ctc18m05[l_arr].cidnom  is null   then
                     next field cidnom
                 end if
             else
                 error l_msg sleep 2
                 next field cidnom
             end if
         end if
        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
              next field cidnom
        end if
        if fgl_lastkey() = fgl_keyval("down") then
              next field etgtaxvlr
        end if

   before field etgtaxvlr
         display am_ctc18m05[l_arr].etgtaxvlr to s_tela[l_tela].etgtaxvlr attribute (reverse)

   after field etgtaxvlr
         display am_ctc18m05[l_arr].etgtaxvlr to s_tela[l_tela].etgtaxvlr
         #se tentar acessar campo superior
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            if l_operacao = "I" then
               #se for uma insecao vai para cidnom
               next field cidnom
            else
               #senao nao permite sair do lugar
               next field etgtaxvlr
            end if
         end if
         if am_ctc18m05[l_arr].etgtaxvlr is null then
               error "Informe a taxa de entrega"
               next field etgtaxvlr
         end if
         #se tentar ir para baixo vai para etglclsitflg
         if fgl_lastkey() = fgl_keyval("down") then
            next field etglclsitflg
         end if

    before field etglclsitflg
         display am_ctc18m05[l_arr].etglclsitflg to s_tela[l_tela].etglclsitflg attribute (reverse)

    after field etglclsitflg
         display am_ctc18m05[l_arr].etglclsitflg to s_tela[l_tela].etglclsitflg
         # se tentar ir para linha de cima vai para etgtaxvlr
         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
             next field etgtaxvlr
         end if
         if am_ctc18m05[l_arr].etglclsitflg is null or
            (am_ctc18m05[l_arr].etglclsitflg <> 'A' and
             am_ctc18m05[l_arr].etglclsitflg <> 'C') then
              error "Flag Situacao- (A)tivo ou (C)ancelado"
              next field etglclsitflg
         end if
         if am_ctc18m05[l_arr].etglclsitflg = 'A' then
               let am_ctc18m05[l_arr].situacao = 'Ativo'
         else
               let am_ctc18m05[l_arr].situacao = 'Cancelado'
         end if
         display am_ctc18m05[l_arr].situacao to s_tela[l_tela].situacao
         #se tentar ir para linha de baixo - nao permite
         if fgl_lastkey() = fgl_keyval("down") then
            next field etglclsitflg
         end if

         #grava linha se foi alterada
         let l_aux = false
         if (l_salva_taxa <> am_ctc18m05[l_arr].etgtaxvlr or
              l_salva_flg <> am_ctc18m05[l_arr].etglclsitflg) and
              l_operacao = "A" then
               #alterou dados
               begin work
               let l_aux = true
               let m_arr = l_arr
               call ctc18m05_apaga(mr_ctc18m05.lcvcod,
                                    mr_ctc18m05.aviestcod,
                                    am_ctc18m0502[l_arr].cidcod)
                     returning l_aux
               #Busca matricula funcionario alteracao
               call cts40g03_data_hora_banco(2)
                    returning am_ctc18m05[l_arr].atldat, l_hora2
               let am_ctc18m05[l_arr].atlmat      = g_issk.funmat
               let am_ctc18m05[l_arr].atlnom      = g_issk.funnom
               let am_ctc18m05[l_arr].atlemp      = g_issk.empcod
               let am_ctc18m0502[l_arr].atlusrtip = g_issk.usrtip
         end if
         if l_operacao = "I" then
                  begin work
                  #novo registro - Busca matricula funcionario insercao
                  call cts40g03_data_hora_banco(2)
                      returning am_ctc18m05[l_arr].caddat, l_hora2
                  let am_ctc18m05[l_arr].cadmat      = g_issk.funmat
                  let am_ctc18m05[l_arr].cadnom      = g_issk.funnom
                  let am_ctc18m05[l_arr].cademp      = g_issk.empcod
                  let am_ctc18m0502[l_arr].cadusrtip = g_issk.usrtip
                  let am_ctc18m05[l_arr].atldat      = null
                  let am_ctc18m05[l_arr].atlmat      = null
                  let am_ctc18m05[l_arr].atlnom      = null
                  let am_ctc18m05[l_arr].atlemp      = null
                  let am_ctc18m0502[l_arr].atlusrtip = null
                  let l_aux = true
         end if

         display am_ctc18m05[l_arr].caddat to s_tela[l_tela].caddat
         display am_ctc18m05[l_arr].cademp to s_tela[l_tela].cademp
         display am_ctc18m05[l_arr].cadmat to s_tela[l_tela].cadmat
         display am_ctc18m05[l_arr].cadnom to s_tela[l_tela].cadnom
         display am_ctc18m05[l_arr].atldat to s_tela[l_tela].atldat
         display am_ctc18m05[l_arr].atlemp to s_tela[l_tela].atlemp
         display am_ctc18m05[l_arr].atlmat to s_tela[l_tela].atlmat
         display am_ctc18m05[l_arr].atlnom to s_tela[l_tela].atlnom

         if l_aux = true then
             #insere
             whenever error continue
             execute pctc18m05006 using mr_ctc18m05.lcvcod,
                                        mr_ctc18m05.aviestcod,
                                        am_ctc18m0502[l_arr].cidcod,
                                        am_ctc18m05[l_arr].etglclsitflg,
                                        am_ctc18m05[l_arr].etgtaxvlr,
                                        am_ctc18m05[l_arr].caddat,
                                        am_ctc18m05[l_arr].cademp,
                                        am_ctc18m0502[l_arr].cadusrtip,
                                        am_ctc18m05[l_arr].cadmat,
                                        am_ctc18m05[l_arr].atldat,
                                        am_ctc18m05[l_arr].atlemp,
                                        am_ctc18m0502[l_arr].atlusrtip,
                                        am_ctc18m05[l_arr].atlmat

             whenever error stop
             if sqlca.sqlcode <> 0 then
                error "Erro ", sqlca.sqlcode, " ao inserir dados da tabela locais de entrega da loja!!"
                rollback work
             else
                commit work
                error "Inclusao/Alteracao efetuada!"
             end if
         end if
         let l_operacao = null

         let l_titulo = 'Inclusao de Locais de entrega [',mr_ctc18m05.lcvcod using '<<<<<<' clipped,'|',mr_ctc18m05.aviestcod using '<<<<' clipped,'] !'
         let l_aux2 = 'Locais de entrega incluido !'
         let l_aux3 = mr_ctc18m05.lcvcod using '<<<<<<' clipped,'|',mr_ctc18m05.aviestcod using '<<<<'
         call ctb85g01_grava_hist(3
                                 ,l_aux3
                                 ,l_aux2
                                 ,today
                                 ,am_ctc18m05[l_arr].cademp
                                 ,am_ctc18m05[l_arr].cadmat
                                 ,am_ctc18m0502[l_arr].cadusrtip)
            returning l_erro
                     ,l_mesg

         if l_erro <> 0 then
            error l_mesg
            exit input
         end if

	  let l_mensagem = l_aux2, " ", l_aux3

          call ctb85g01_mtcorpo_email_html('CTC18M00',
                                           am_ctc18m05[l_arr].caddat,
		                           current hour to minute,
                                           am_ctc18m05[l_arr].cademp,
                                           am_ctc18m0502[l_arr].cadusrtip,
                                           am_ctc18m05[l_arr].cadmat,
		                           l_titulo,
		                           l_mensagem )
		returning l_erro

         if l_erro <> 0 then
            error 'Erro ao enviar e-mail'
            exit input
         end if

         next field navega

    on key (f17, control-c, interrupt)
          exit input

    on key (f2)
          #apagar linha corrente da tabela
          if m_permissao = true then
             prompt "Confirma a exclusao? (S/N) " for l_operacao
             if upshift(l_operacao) = 'S'   then
                begin work
                let m_arr = l_arr
                call ctc18m05_apaga(mr_ctc18m05.lcvcod,
                                 mr_ctc18m05.aviestcod,
                                 am_ctc18m0502[l_arr].cidcod)
                  returning l_aux
                if l_aux = true then
                   #commit
                   commit work
                   error "Exclusao efetuada!"
                   call ctc18m05_apaga_linha_tela(l_arr, l_tela)
                else
                   #rollback
                   rollback work
                   exit input
                end if
             end if
          end if
          let l_operacao = null

     on key (f6)
        #salva dados que podem ser alterados
        if m_permissao = true then
           if l_operacao = "I" or
              l_operacao = "A" then
                error "F6 nao pode ser pressionado no momento!!"
           else
              let l_operacao = "A"
              let l_salva_taxa = am_ctc18m05[l_arr].etgtaxvlr
              let l_salva_flg  = am_ctc18m05[l_arr].etglclsitflg
              next field etgtaxvlr
           end if
        end if


   end input
end function

#----------------------------#
function ctc18m05_apaga(l_param)
#----------------------------#
     define l_param record
         lcvcod      like datklcletgvclext.lcvcod,
         aviestcod   like datklcletgvclext.aviestcod,
         cidcod      like datklcletgvclext.cidcod
     end record
     define l_aux  char(300)
           ,l_cmd  char(200)
           ,l_erro smallint
           ,l_msg  char(100)
           ,l_caminho char(100)
           ,l_titulo     char(100)
           ,l_aux2    char(100)

     let l_aux     = null
     let l_cmd     = null
     let l_erro    = null
     let l_msg     = null
     let l_caminho = null
     let l_aux2    = null


     whenever error continue
     execute pctc18m05005 using l_param.lcvcod,
                                l_param.aviestcod,
                                l_param.cidcod
     whenever error stop
     if sqlca.sqlcode <> 0 then
        error "Erro ao excluir dados da tabela locais de entrega da loja!!"
        return false
     end if

     let l_titulo = 'Delecao  no cadastro de locais de entrega de uma ',
	 ' loja para carro extra [',l_param.lcvcod using '<<<<<<' clipped,'|',l_param.aviestcod using '<<<<' clipped,'] !'
     let l_aux = 'Local de entrega [',l_param.lcvcod using '<<<<<<' clipped,'|',l_param.aviestcod using '<<<<' clipped,'] excluido !'
     let l_aux2 = l_param.lcvcod using '<<<<<<' clipped,'|',l_param.aviestcod using '<<<<'
     call ctb85g01_grava_hist(3
                             ,l_aux2
                             ,l_aux
                             ,today
                             ,am_ctc18m05[m_arr].cademp
                             ,am_ctc18m05[m_arr].cadmat
                             ,am_ctc18m0502[m_arr].cadusrtip)
        returning l_erro
                 ,l_msg

     if l_erro <> 0 then
        error l_msg
        return false
     end if

      call ctb85g01_mtcorpo_email_html('CTC18M00',
                                      am_ctc18m05[m_arr].caddat,
	                               current hour to minute,
                                       am_ctc18m05[m_arr].cademp,
                                       am_ctc18m0502[m_arr].cadusrtip,
                                       am_ctc18m05[m_arr].cadmat,
		                       l_titulo,
		                       l_aux)
		returning l_erro

     if l_erro <> 0 then
        error 'Erro ao enviar e-mail'
        return false
     end if

     return true
end function


#---------------------------------------#
function ctc18m05_apaga_linha_tela(l_arr, l_scr)
#---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint

  for l_cont = l_arr to 99
     if am_ctc18m05[l_arr].cidnom is not null then
        let am_ctc18m05[l_cont].* = am_ctc18m05[l_cont + 1].*
     else
        initialize am_ctc18m05[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 2
     display am_ctc18m05[l_arr].cidnom       to s_tela[l_cont].cidnom
     display am_ctc18m05[l_arr].ufdcod       to s_tela[l_cont].ufdcod
     display am_ctc18m05[l_arr].etgtaxvlr    to s_tela[l_cont].etgtaxvlr
     display am_ctc18m05[l_arr].etglclsitflg to s_tela[l_cont].etglclsitflg
     display am_ctc18m05[l_arr].situacao     to s_tela[l_cont].situacao
     display am_ctc18m05[l_arr].caddat       to s_tela[l_cont].caddat
     display am_ctc18m05[l_arr].cademp       to s_tela[l_cont].cademp
     display am_ctc18m05[l_arr].cadmat       to s_tela[l_cont].cadmat
     display am_ctc18m05[l_arr].cadnom       to s_tela[l_cont].cadnom
     display am_ctc18m05[l_arr].atldat       to s_tela[l_cont].atldat
     display am_ctc18m05[l_arr].atlemp       to s_tela[l_cont].atlemp
     display am_ctc18m05[l_arr].atlmat       to s_tela[l_cont].atlmat
     display am_ctc18m05[l_arr].atlnom       to s_tela[l_cont].atlnom
     let l_arr = l_arr + 1
  end for

end function


