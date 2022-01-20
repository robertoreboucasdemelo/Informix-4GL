#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24 Horas/Porto Socorro                            #
# Modulo.........: ctc82m00                                                  #
# Objetivo.......: Cadastro de Permissoes do Cartao                          #
# Analista Resp. : Roberto Melo                                              #
# PSI            : 211982                                                    #
#............................................................................#
# Desenvolvimento: Alinne, Meta                                              #
# Liberacao      : 12/09/2007                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica  PSI         Alteracao                            #
# --------   -------------  ------      -------------------------------------#
# 11/11/2008 Carla Rampazzo PSI 230650  Tratar 1a. posigco do Assunto para   #
#                                       carregar pop-up com esta inicial     #
#----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail  #
##############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define mr_tela record
                  empcod      like gabkemp.empcod
                 ,empnom      like gabkemp.empnom
                 ,cidnom      like glakcid.cidnom
                 ,ufdcod      like glakcid.ufdcod
                 ,c24astcod   like datkassunto.c24astcod
                 ,c24astdes   like datkassunto.c24astdes
                 ,atvstt      like datkcarpms.atvstt
                 ,situacaodes char(008)
   end record

   define mr_tela_aux record
                      caddat  like datkcarpms.caddat
                     ,cademp  like datkcarpms.cademp
                     ,cadmat  like datkcarpms.cadmat
                     ,funnom1 like isskfunc.funnom
                     ,atldat  like datkcarpms.atldat
                     ,atlemp  like datkcarpms.atlemp
                     ,atlmat  like datkcarpms.atlmat
                     ,funnom2 like isskfunc.funnom
   end record

   define m_cidcod like datkcarpms.cidcod

   define m_prep_ctc82m00 smallint
         ,m_erro          char(100)

#---------------------------#
 function ctc82m00_prepare()
#---------------------------#

   define l_sql  char(500)

   let l_sql = ' select empnom '
              ,'   from gabkemp '
              ,'  where empcod = ? '

   prepare pctc82m00001 from l_sql
   declare cctc82m00001 cursor for pctc82m00001

   let l_sql = ' select cidcod '
              ,'   from glakcid '
              ,'  where ufdcod = ? '
              ,'    and cidnom = ? '

   prepare pctc82m00002 from l_sql
   declare cctc82m00002 cursor for pctc82m00002

   let l_sql = ' select cidnom '
              ,'       ,ufdcod '
              ,'   from glakcid '
              ,'  where cidcod = ? '

   prepare pctc82m00004 from l_sql
   declare cctc82m00004 cursor for pctc82m00004

   let l_sql = ' insert into datkcarpms (empcod '
                                     ,' ,cidcod '
                                     ,' ,c24astcod '
                                     ,' ,atvstt '
                                     ,' ,cademp '
                                     ,' ,cadmat '
                                     ,' ,caddat '
                                     ,' ,atlemp '
                                     ,' ,atlmat '
                                     ,' ,atldat) '
                      ,' values (?,?,?,?,?,?,today,"","","") '

   prepare pctc82m00005 from l_sql

   let l_sql = ' update datkcarpms '
              ,'    set atvstt    = ? '
              ,'       ,atlemp    = ? '
              ,'       ,atlmat    = ? '
              ,'       ,atldat    = today '
              ,'  where empcod    = ? '
              ,'    and cidcod    = ? '
              ,'    and c24astcod = ? '

   prepare pctc82m00006 from l_sql

   let l_sql = ' update datkcarpms '
              ,'    set atvstt    = "I" '
              ,'       ,atlemp    = ? '
              ,'       ,atlmat    = ? '
              ,'       ,atldat    = today '

   prepare pctc82m00007 from l_sql

   let l_sql = ' select 1 '
              ,'   from datkcarpms '
              ,'  where empcod    = ? '
              ,'    and cidcod    = ? '
              ,'    and c24astcod = ? '

   prepare pctc82m00008 from l_sql
   declare cctc82m00008 cursor for pctc82m00008


   let m_prep_ctc82m00 = true

 end function

#-------------------#
 function ctc82m00()
#-------------------#

   if m_prep_ctc82m00 is null or
      m_prep_ctc82m00 <> true then
      call ctc82m00_prepare()
   end if

   open window w_ctc82m00 at 4,2 with form "ctc82m00"

   menu 'PERMISSAO'

      before menu
          hide option 'Proxima'
          hide option 'Anterior'

      command key('S') 'Seleciona' 'Selecionar permissoes do cartao'
          call ctc82m00_input('S')

          if m_cidcod is not null then
             show option 'Proxima'
             show option 'Anterior'
          else
             hide option 'Proxima'
             hide option 'Anterior'
          end if

      command key('P') 'Proxima' 'Proxima permissao do cartao'
          call ctc82m00_posicao('P')

      command key('A') 'Anterior' 'Permissao Anterior do cartao'
          call ctc82m00_posicao('A')

      command key('I') 'Inclui' 'Incluir permissoes do cartao'
          call ctc82m00_input('I')

          hide option 'Proxima'
          hide option 'Anterior'
          next option 'Seleciona'

      command key('M') 'Modifica' 'Modificar permissoes do cartao'
          if mr_tela.empcod is not null then
             call ctc82m00_input('A')

             hide option 'Proxima'
             hide option 'Anterior'
          else
             error 'Selecione um registro!'
          end if
          next option 'Seleciona'

      command key('X') 'Inativa_Todos' 'Inativar todas as permissoes'
          call ctc82m00_inativa()

      command key('E') 'Encerrar' 'Sair do menu'
         exit menu

   end menu

   close window w_ctc82m00

   let int_flag = false

 end function

#-----------------------------------#
 function ctc82m00_input(l_acao)
#-----------------------------------#

   define l_acao      char(001)

   define l_sql       char(100)
         ,l_achou     smallint
         ,l_erro      smallint

   let l_achou = null

   if l_acao <> 'A' then
      initialize mr_tela     to null
      initialize mr_tela_aux to null
      let m_cidcod = null
      clear form
   end if

   input by name mr_tela.empcod
                ,mr_tela.cidnom
                ,mr_tela.ufdcod
                ,mr_tela.c24astcod
                ,mr_tela.atvstt   without defaults

      before field empcod
         if l_acao = 'A' then
            next field atvstt
         else
            display by name mr_tela.empcod attribute(reverse)
         end if

      after field empcod
         display by name mr_tela.empcod

         if mr_tela.empcod is not null and
            mr_tela.empcod <> 1        and
            mr_tela.empcod <> 35       and ---> Azul
            mr_tela.empcod <> 50       and ---> Saude
            mr_tela.empcod <> 40       then
            error 'Informe uma empresa valida!'
            let mr_tela.empcod = null
         end if

         if mr_tela.empcod is not null then

            let l_achou = ctc82m00_empresa()

            if l_achou = 1 then
               error 'Informe um codigo de empresa!'
               next field empcod
            else
               if l_achou = 2 then
                  exit input
               end if
            end if
         else
            call cty14g00_popup_empresa()
               returning l_erro
                        ,mr_tela.empcod
                        ,mr_tela.empnom

            if l_erro = 3 then
               error 'Codigo de empresa nao selecionado!'
               next field empcod
            end if

            if mr_tela.empcod is null then
               error 'Informe um codigo de empresa!'
               next field empcod
            end if
         end if

         display by name mr_tela.empnom

      before field cidnom
         display by name mr_tela.cidnom attribute(reverse)

      after field cidnom
         display by name mr_tela.cidnom

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field empcod
         end if

         if mr_tela.cidnom is null or
            mr_tela.cidnom = ' '   then
            if l_acao <> 'S' then
               error 'Informe um nome de cidade!'
               next field cidnom
            else
               next field c24astcod
            end if
         end if

      before field ufdcod
         display by name mr_tela.ufdcod attribute(reverse)

      after field ufdcod
         display by name mr_tela.ufdcod

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field cidnom
         end if

         if mr_tela.ufdcod is null or
            mr_tela.ufdcod = ' '   then
            error 'Informe uma Unidade de Federacao!'
            next field ufdcod
         end if

         open cctc82m00002 using mr_tela.ufdcod
                                ,mr_tela.cidnom
         whenever error continue
         fetch cctc82m00002 into m_cidcod
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               error 'Cidade nao cadastrada!'
               let mr_tela.ufdcod = null
               let mr_tela.cidnom = null
               display by name mr_tela.ufdcod
               next field cidnom
            else
               error 'Erro SELECT cctc82m00002: ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
               error 'ctc82m00/ ctc82m00_input/ ',mr_tela.ufdcod
                                           ,' / ',mr_tela.cidnom sleep 2
               exit input
            end if
         end if

      before field c24astcod
         display by name mr_tela.c24astcod attribute(reverse)

      after field c24astcod
         display by name mr_tela.c24astcod

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            if l_acao = 'S' then
               next field cidnom
            else
               next field ufdcod
            end if
         end if

         if mr_tela.c24astcod is not null then
            let mr_tela.c24astdes = c24geral8(mr_tela.c24astcod)
         else
            call cta02m03(g_issk.dptsgl
                         ,mr_tela.c24astcod)
               returning mr_tela.c24astcod
                        ,mr_tela.c24astdes
            display by name mr_tela.c24astcod

            if mr_tela.c24astcod is not null then
               next field c24astcod
            end if
         end if

         display by name mr_tela.c24astdes

         if l_acao = 'I' then
            open cctc82m00008 using mr_tela.empcod
                                   ,m_cidcod
                                   ,mr_tela.c24astcod
            whenever error continue
            fetch cctc82m00008
            whenever error stop

            if sqlca.sqlcode = 0 then
               error 'Registro ja cadastrado!'
               next field c24astcod
            else
               if sqlca.sqlcode <> notfound then
                  error 'Erro SELECT cctc82m00008: ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
                  error 'ctc82m00/ ctc82m00_input/ ',mr_tela.empcod
                                              ,' / ',m_cidcod
                                              ,' / ',mr_tela.c24astcod  sleep 2
                  exit input
               end if
            end if
         end if

      before field atvstt
         display by name mr_tela.atvstt attribute(reverse)

      after field atvstt
         display by name mr_tela.atvstt

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            if l_acao = 'A' then
               next field atvstt
            else
               next field c24astcod
            end if
         end if

         if l_acao <> 'S' then
             if mr_tela.atvstt is null or
               (mr_tela.atvstt <> 'I'  and
                mr_tela.atvstt <> 'A') then
                error 'Informe um "A" ou "I" !'
                next field atvstt
             end if
         else
            if mr_tela.atvstt is not null and
               mr_tela.atvstt <> 'I'      and
               mr_tela.atvstt <> 'A'      then
                error 'Informe um "A" ou "I" !'
                next field atvstt
             end if
         end if

         call ctc82m00_situacao()

         display by name mr_tela.situacaodes

         if l_acao = 'S' then
            call ctc82m00_seleciona()
         else
            if not ctc82m00_atualiza_reg(l_acao) then
               exit input
            end if
         end if

      on key(interrupt,control-c,f17)
         clear form
         exit input

   end input

 end function

#-------------------------------#
 function ctc82m00_seleciona()
#-------------------------------#

   define l_sql   char(500)

   let l_sql = ' select empcod    '
              ,'       ,cidcod    '
              ,'       ,c24astcod '
              ,'       ,atvstt    '
              ,'       ,cademp    '
              ,'       ,cadmat    '
              ,'       ,caddat    '
              ,'       ,atlemp    '
              ,'       ,atlmat    '
              ,'       ,atldat    '
              ,'   from datkcarpms '
              ,' where empcod = ',mr_tela.empcod

   if m_cidcod is not null then
      let l_sql = l_sql clipped, ' and cidcod = ',m_cidcod
   end if

   if mr_tela.c24astcod is not null then
      let l_sql = l_sql clipped, ' and c24astcod = "',mr_tela.c24astcod,'"'
   end if


   if mr_tela.atvstt is not null then
      let l_sql = l_sql clipped, ' and atvstt = "',mr_tela.atvstt,'"'
   end if

   let l_sql = l_sql clipped, ' order by empcod '

   prepare pctc82m00003 from l_sql
   declare cctc82m00003 scroll cursor for pctc82m00003

   call ctc82m00_posicao('F')

 end function

#-----------------------------------#
 function ctc82m00_posicao(l_pos)
#-----------------------------------#

   define l_pos   char(001)
         ,l_achou smallint

   let l_achou = 0

   case
      when l_pos = 'F'
         open cctc82m00003
         whenever error continue
         fetch first cctc82m00003 into mr_tela.empcod
                                      ,m_cidcod
                                      ,mr_tela.c24astcod
                                      ,mr_tela.atvstt
                                      ,mr_tela_aux.cademp
                                      ,mr_tela_aux.cadmat
                                      ,mr_tela_aux.caddat
                                      ,mr_tela_aux.atlemp
                                      ,mr_tela_aux.atlmat
                                      ,mr_tela_aux.atldat
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               error 'Nenhum registro cadastrado'
               let l_achou = 1
               initialize mr_tela     to null
               initialize mr_tela_aux to null
               clear form
            else
               error 'Erro SELECT cctc82m00003 ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
               error 'ctc82m00/ ctc82m00_posicao/ ' sleep 2
               let l_achou = 2
            end if
         end if

      when l_pos = 'P'
         whenever error continue
         fetch next cctc82m00003 into mr_tela.empcod
                                     ,m_cidcod
                                     ,mr_tela.c24astcod
                                     ,mr_tela.atvstt
                                     ,mr_tela_aux.cademp
                                     ,mr_tela_aux.cadmat
                                     ,mr_tela_aux.caddat
                                     ,mr_tela_aux.atlemp
                                     ,mr_tela_aux.atlmat
                                     ,mr_tela_aux.atldat
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               error 'Nao existem mais registros nesta direcao!'
               let l_achou = 1
            else
               error 'Erro SELECT cctc82m00003 ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
               error 'ctc82m00/ ctc82m00_posicao/ ' sleep 2
               let l_achou = 2
            end if
         end if

      when l_pos = 'A'
         whenever error continue
         fetch previous cctc82m00003 into mr_tela.empcod
                                         ,m_cidcod
                                         ,mr_tela.c24astcod
                                         ,mr_tela.atvstt
                                         ,mr_tela_aux.cademp
                                         ,mr_tela_aux.cadmat
                                         ,mr_tela_aux.caddat
                                         ,mr_tela_aux.atlemp
                                         ,mr_tela_aux.atlmat
                                         ,mr_tela_aux.atldat
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = notfound then
               error 'Nao existem mais registros nesta direcao!'
               let l_achou = 1
            else
               error 'Erro SELECT cctc82m00003: ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
               error 'ctc82m00/ ctc82m00_posicao/ ' sleep 2
               let l_achou = 2
            end if
         end if

   end case

   if l_achou = 0 then
      let l_achou = ctc82m00_empresa()

      if l_achou <> 2 then
         let l_achou = ctc82m00_cidade()

         if l_achou <> 2 then

            let mr_tela.c24astdes = c24geral8(mr_tela.c24astcod)

            let mr_tela_aux.funnom1 = ctc82m00_func(mr_tela_aux.cademp
                                                   ,mr_tela_aux.cadmat)

            let mr_tela_aux.funnom2 = ctc82m00_func(mr_tela_aux.atlemp
                                                   ,mr_tela_aux.atlmat)

            call ctc82m00_situacao()
            call ctc82m00_display()

         end if
      end if
   end if

 end function

#-------------------------------#
 function ctc82m00_empresa()
#-------------------------------#

   define l_achou smallint

   let l_achou = 0

   open cctc82m00001 using mr_tela.empcod
   whenever error continue
   fetch cctc82m00001 into mr_tela.empnom
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error 'Empresa nao cadastrada!'
         let l_achou = 1
      else
         error 'Erro SELECT cctc82m00001: ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
         error 'CTC82M00 / ctc82m00_empresa()/ ',mr_tela.empcod sleep 2
         let l_achou = 2
      end if
   end if

   return l_achou

 end function

#-------------------------------#
 function ctc82m00_cidade()
#-------------------------------#

   define l_achou smallint

   let l_achou = 0

   open cctc82m00004 using m_cidcod
   whenever error continue
   fetch cctc82m00004 into mr_tela.cidnom
                          ,mr_tela.ufdcod
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let mr_tela.cidnom = null
         let l_achou = 1
      else
         error 'Erro SELECT cctc82m00004: ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
         error 'CTC82M00 / ctc82m00_cidade()/ ',m_cidcod sleep 2
         let l_achou = 2
      end if
   end if

   return l_achou

 end function

#--------------------------------------#
 function ctc82m00_atualiza_reg(l_acao)
#--------------------------------------#

   define l_acao  char(001)
         ,l_ok    smallint

   let l_ok = true

   case l_acao
      when 'I'
         let mr_tela_aux.caddat = today
         let mr_tela_aux.cademp = g_issk.empcod
         let mr_tela_aux.cadmat = g_issk.funmat

         whenever error continue
         execute pctc82m00005 using mr_tela.empcod
                                   ,m_cidcod
                                   ,mr_tela.c24astcod
                                   ,mr_tela.atvstt
                                   ,g_issk.empcod
                                   ,g_issk.funmat
         whenever error stop

         if sqlca.sqlcode = 0 then
            error 'Registro incluido com sucesso'
            call ctc82m00_envia_email()
         else
            error 'Erro INSERT pctc82m00005 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
            error 'CTC82M00 / ctc82m00_atualiza_reg() / ',mr_tela.empcod
                                                   ,' / ',m_cidcod
                                                   ,' / ',mr_tela.c24astcod
                                                   ,' / ',mr_tela.atvstt
                                                   ,' / ',g_issk.empcod
                                                   ,' / ',g_issk.funmat  sleep 2
            let l_ok = false
         end if

      when 'A'
         let mr_tela_aux.atldat = today
         let mr_tela_aux.atlemp = g_issk.empcod
         let mr_tela_aux.atlmat = g_issk.funmat

         whenever error continue
         execute pctc82m00006 using mr_tela.atvstt
                                   ,g_issk.empcod
                                   ,g_issk.funmat
                                   ,mr_tela.empcod
                                   ,m_cidcod
                                   ,mr_tela.c24astcod
         whenever error stop
         if sqlca.sqlcode = 0 then
            error 'Registro atualizado com sucesso'
            call ctc82m00_envia_email()
         else
            error 'Erro UPDATE pctc82m00006 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
            error 'CTC82M00 / ctc82m00_atualiza_reg() / ',mr_tela.atvstt
                                                   ,' / ',g_issk.empcod
                                                   ,' / ',g_issk.funmat
                                                   ,' / ',mr_tela.empcod
                                                   ,' / ',m_cidcod
                                                   ,' / ',mr_tela.c24astcod sleep 2
            let l_ok = false
         end if

   end case

   if l_ok then
      let mr_tela_aux.funnom1 = ctc82m00_func(mr_tela_aux.cademp
                                             ,mr_tela_aux.cadmat)
      if l_acao = 'A' then
         let mr_tela_aux.funnom2 = ctc82m00_func(mr_tela_aux.atlemp
                                                ,mr_tela_aux.atlmat)
      end if

      call ctc82m00_display()
   end if

   return l_ok

 end function

#-------------------------------#
 function ctc82m00_inativa()
#-------------------------------#

   define l_resp char(001)

   let l_resp = ' '

   while l_resp <> 'S' and
         l_resp <> 'N'

      prompt 'DESEJA INATIVAR TODAS AS PERMISSOES? <S/N>? ' for l_resp

      if int_flag then
         let int_flag = false
         let l_resp = 'N'
      else
         let l_resp = upshift(l_resp)
      end if

   end while

   if l_resp = 'S' then
      whenever error continue
      execute pctc82m00007 using g_issk.empcod
                                ,g_issk.funmat
      whenever error stop
      if sqlca.sqlcode = 0 then
         error 'Atualizacao efetuada com sucesso!'
         initialize mr_tela     to null
         initialize mr_tela_aux to null
         let m_cidcod = null
         call ctc82m00_envia_email()
         clear form
      else
         error 'Erro UPDATE pctc82m00007 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] sleep 2
         error 'CTC82M00 / ctc82m00_inativa() / ',g_issk.empcod
                                           ,' / ',g_issk.funmat sleep 2
      end if
   end if

 end function

#-------------------------------#
 function ctc82m00_display()
#-------------------------------#

   display by name mr_tela.empcod
   display by name mr_tela.empnom
   display by name mr_tela.cidnom
   display by name mr_tela.ufdcod
   display by name mr_tela.cidnom
   display by name mr_tela.c24astcod
   display by name mr_tela.c24astdes
   display by name mr_tela.atvstt
   display by name mr_tela.situacaodes
   display by name mr_tela_aux.caddat
   display by name mr_tela_aux.funnom1
   display by name mr_tela_aux.atldat
   display by name mr_tela_aux.funnom2

 end function

#---------------------------------------------------------
 function ctc82m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom  ,
    res               smallint              ,
    msg               char(40)
 end record


 initialize ws.* to null

 call cty08g00_nome_func(param.empcod, param.funmat, "F")
      returning ws.res, ws.msg, ws.funnom

 return ws.funnom

end function

#---------------------------------------------------------
function ctc82m00_envia_email()
#---------------------------------------------------------

define lr_retorno record
   comando    char(500)          ,
   de         char(50)           ,
   para       char(1000)         ,
   msg        char(1000)         ,
   assunto    char(400)          ,
   cidnom     like glakcid.cidnom,
   ufdcod     like glakcid.ufdcod
end record

define  l_mail             record
   de                 char(500)   # De
  ,para               char(5000)  # Para
  ,cc                 char(500)   # cc
  ,cco                char(500)   # cco
  ,assunto            char(500)   # Assunto do e-mail
  ,mensagem           char(32766) # Nome do Anexo
  ,id_remetente       char(20)
  ,tipo               char(4)     #
end  record

define l_coderro  smallint
define msg_erro char(500)
initialize lr_retorno.* to null

  let lr_retorno.assunto = "Acesso Permissao do Cartao"
  let lr_retorno.de      = "EmailCorr.ct24hs@correioporto"
  let lr_retorno.para    = "roberto_melo@correioporto"

  open cctc82m00004 using m_cidcod
  whenever error continue
  fetch cctc82m00004 into lr_retorno.cidnom
                         ,lr_retorno.ufdcod
  whenever error stop

  let lr_retorno.msg =  "EMPRESA..: ", mr_tela.empcod    , "<br>"
                       ,"ASSUNTO..: ", mr_tela.c24astcod clipped , "<br>"
                       ,"CIDADE...: ", lr_retorno.cidnom clipped, "-", lr_retorno.ufdcod, "<br>"
                       ,"STATUS...: ", mr_tela.atvstt, "<br>"
                       ,"MATRICULA: ", g_issk.funmat, "<br>"
                       ,"DATA.....: ", today , "<br>"
                       ,"HORA.....: ", current hour to minute

  #PSI-2013-23297 - Inicio
   let l_mail.de = lr_retorno.de
   #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
   let l_mail.para = lr_retorno.para
   let l_mail.cc = ""
   let l_mail.cco = ""
   let l_mail.assunto = lr_retorno.assunto
   let l_mail.mensagem = lr_retorno.msg
   let l_mail.id_remetente = "CT24HS"
   let l_mail.tipo = "html"

   call figrc009_mail_send1 (l_mail.*)
      returning l_coderro,msg_erro
   #PSI-2013-23297 - Fim

end function

#---------------------------------------------------------
function ctc82m00_situacao()
#---------------------------------------------------------

  case mr_tela.atvstt
     when "A"
         let mr_tela.situacaodes = 'ATIVO'
     when "I"
         let mr_tela.situacaodes = 'INATIVO'
     otherwise
         let mr_tela.situacaodes = null
  end case

end function

















































