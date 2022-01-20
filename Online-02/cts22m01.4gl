#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24hrs                                             #
# Modulo.........: cts22m01                                                  #
# Objetivo.......: Manutencao das informacaes de hospedagem de um servico    #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 196878                                                    #
#............................................................................#
# Desenvolvimento: Alinne, META                                              #
# Liberacao      : 16/02/2006                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

   define mr_tela record
                  hsphotnom    like datmhosped.hsphotnom
                 ,hsphotend    like datmhosped.hsphotend
                 ,hsphotbrr    like datmhosped.hsphotbrr
                 ,hsphotuf     like datmhosped.hsphotuf
                 ,hsphotcid    like datmhosped.hsphotcid
                 ,hsphottelnum like datmhosped.hsphottelnum
                 ,hsphotcttnom like datmhosped.hsphotcttnom
                 ,hsphotdiavlr like datmhosped.hsphotdiavlr
                 ,hsphotacmtip like datmhosped.hsphotacmtip
                 ,obsdes       like datmhosped.obsdes
                 ,hsphotrefpnt like datmhosped.hsphotrefpnt
                  end record

   define m_prep_cts22m01 smallint

#-----------------------------------------#
 function cts22m01_prepare()
#-----------------------------------------#

   define l_sql char(400)

   let l_sql = ' select hsphotnom '
              ,'       ,hsphotend '
              ,'       ,hsphotbrr '
              ,'       ,hsphotuf  '
              ,'       ,hsphotcid '
              ,'       ,hsphottelnum '
              ,'       ,hsphotcttnom '
              ,'       ,hsphotdiavlr '
              ,'       ,hsphotacmtip '
              ,'       ,obsdes       '
              ,'       ,hsphotrefpnt '
              ,'       ,hpddiapvsqtd '
              ,'       ,hpdqrtqtd '
              ,'   from datmhosped   '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '

   prepare p_cts22m01_001 from l_sql
   declare c_cts22m01_001 cursor for p_cts22m01_001

   let l_sql = ' insert into datmhosped(atdsrvnum    '
                                   ,'  ,atdsrvano    '
                                   ,'  ,hpddiapvsqtd '
                                   ,'  ,hpdqrtqtd    '
                                   ,'  ,hsphotnom    '
                                   ,'  ,hsphotend    '
                                   ,'  ,hsphotbrr    '
                                   ,'  ,hsphotuf     '
                                   ,'  ,hsphotcid    '
                                   ,'  ,hsphottelnum '
                                   ,'  ,hsphotcttnom '
                                   ,'  ,hsphotdiavlr '
                                   ,'  ,hsphotacmtip '
                                   ,'  ,obsdes       '
                                   ,'  ,hsphotrefpnt '
                                   ,'  ,hspsegsit)'
                  ,' values(?,?,?,?,?,?,?,?,?,?,?,0,?,?,?,"S") '

   prepare p_cts22m01_002 from l_sql

   let l_sql = ' update datmhosped '
              ,'    set hsphotnom    = ? '
              ,'       ,hsphotend    = ? '
              ,'       ,hsphotbrr    = ? '
              ,'       ,hsphotuf    = ? '
              ,'       ,hsphotcid    = ? '
              ,'       ,hsphottelnum = ? '
              ,'       ,hsphotcttnom = ? '
              ,'       ,hsphotacmtip = ? '
              ,'       ,obsdes       = ? '
              ,'       ,hsphotrefpnt = ? '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '

   prepare p_cts22m01_003 from l_sql

   let l_sql = ' update datmhosped '
              ,'    set hsphotnom    = ? '
              ,'       ,hsphotend    = ? '
              ,'       ,hsphotbrr    = ? '
              ,'       ,hsphotuf     = ? '
              ,'       ,hsphotcid    = ? '
              ,'       ,hsphottelnum = ? '
              ,'       ,hsphotcttnom = ? '
              ,'       ,hpddiapvsqtd = ? '
              ,'       ,hpdqrtqtd    = ? '
              ,'       ,hsphotacmtip = ? '
              ,'       ,obsdes       = ? '
              ,'       ,hsphotrefpnt = ? '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '

   prepare p_cts22m01_004 from l_sql

   let m_prep_cts22m01 = true

 end function

#-----------------------------------------#
 function cts22m01_iniciar(lr_param)
#-----------------------------------------#

   define lr_param record
                   atdsrvnum like datmhosped.atdsrvnum
                  ,atdsrvano like datmhosped.atdsrvano
                  ,acao      char(003)
                   end record

   define lr_hotel record
                   hsphotnom    like datmhosped.hsphotnom
                  ,hsphotend    like datmhosped.hsphotend
                  ,hsphotbrr    like datmhosped.hsphotbrr
                  ,hsphotuf     like datmhosped.hsphotuf
                  ,hsphotcid    like datmhosped.hsphotcid
                  ,hsphottelnum like datmhosped.hsphottelnum
                  ,hsphotcttnom like datmhosped.hsphotcttnom
                  ,hsphotdiavlr like datmhosped.hsphotdiavlr
                  ,hsphotacmtip like datmhosped.hsphotacmtip
                  ,obsdes       like datmhosped.obsdes
                  ,hsphotrefpnt like datmhosped.hsphotrefpnt
                   end record

   define l_resultado smallint
         ,l_mensagem  char(100)

   let l_resultado = null
   let l_mensagem  = null

   initialize lr_hotel to null

   #Entrada de dados do hotel
   call cts22m01_hotel(lr_param.atdsrvnum, lr_param.atdsrvano, lr_param.acao,
                       lr_hotel.*)
      returning lr_hotel.hsphotnom
               ,lr_hotel.hsphotend
               ,lr_hotel.hsphotbrr
               ,lr_hotel.hsphotuf
               ,lr_hotel.hsphotcid
               ,lr_hotel.hsphottelnum
               ,lr_hotel.hsphotcttnom
               ,lr_hotel.hsphotdiavlr
               ,lr_hotel.hsphotacmtip
               ,lr_hotel.obsdes
               ,lr_hotel.hsphotrefpnt

   if lr_param.acao <> 'CON' or lr_param.acao is null then
      #Atualizar hospedagem
      call cts22m01_atualizar('M'
                             ,lr_param.atdsrvnum
                             ,lr_param.atdsrvano
                             ,lr_hotel.hsphotnom
                             ,lr_hotel.hsphotend
                             ,lr_hotel.hsphotbrr
                             ,lr_hotel.hsphotuf
                             ,lr_hotel.hsphotcid
                             ,lr_hotel.hsphottelnum
                             ,lr_hotel.hsphotcttnom
                             ,lr_hotel.hsphotacmtip
                             ,lr_hotel.obsdes
                             ,lr_hotel.hsphotrefpnt)
         returning l_resultado
                  ,l_mensagem

      if l_resultado = 3 then #Deu erro de banco
         error l_mensagem
      end if
   end if

 end function

#-----------------------------------------#
 function cts22m01_hotel(lr_param, lr_retorno)
#-----------------------------------------#

   define lr_param record
                   atdsrvnum like datmhosped.atdsrvnum
                  ,atdsrvano like datmhosped.atdsrvano
                  ,acao      char(003)
                   end record

   define lr_retorno record
                      hsphotnom    like datmhosped.hsphotnom
                     ,hsphotend    like datmhosped.hsphotend
                     ,hsphotbrr    like datmhosped.hsphotbrr
                     ,hsphotuf     like datmhosped.hsphotuf
                     ,hsphotcid    like datmhosped.hsphotcid
                     ,hsphottelnum like datmhosped.hsphottelnum
                     ,hsphotcttnom like datmhosped.hsphotcttnom
                     ,hsphotdiavlr like datmhosped.hsphotdiavlr
                     ,hsphotacmtip like datmhosped.hsphotacmtip
                     ,obsdes       like datmhosped.obsdes
                     ,hsphotrefpnt like datmhosped.hsphotrefpnt
                      end record

   define l_hpddiapvsqtd like datmhosped.hpddiapvsqtd
   define l_hpdqrtqtd    like datmhosped.hpdqrtqtd

   define l_resultado smallint
         ,l_mensagem  char(100)

   let l_resultado = null
   let l_mensagem  = null

   if lr_param.atdsrvnum is not null then

      call cts22m01_selecionar(1, lr_param.atdsrvnum, lr_param.atdsrvano)
         returning l_resultado
                  ,l_mensagem
                  ,lr_retorno.hsphotnom
                  ,lr_retorno.hsphotend
                  ,lr_retorno.hsphotbrr
                  ,lr_retorno.hsphotuf
                  ,lr_retorno.hsphotcid
                  ,lr_retorno.hsphottelnum
                  ,lr_retorno.hsphotcttnom
                  ,lr_retorno.hsphotdiavlr
                  ,lr_retorno.hsphotacmtip
                  ,lr_retorno.obsdes
                  ,lr_retorno.hsphotrefpnt
                  ,l_hpddiapvsqtd
                  ,l_hpdqrtqtd
      if l_resultado = 3 then
         error l_mensagem
         return lr_retorno.hsphotnom
               ,lr_retorno.hsphotend
               ,lr_retorno.hsphotbrr
               ,lr_retorno.hsphotuf
               ,lr_retorno.hsphotcid
               ,lr_retorno.hsphottelnum
               ,lr_retorno.hsphotcttnom
               ,lr_retorno.hsphotdiavlr
               ,lr_retorno.hsphotacmtip
               ,lr_retorno.obsdes
               ,lr_retorno.hsphotrefpnt
      end if

   end if

   let mr_tela.* = lr_retorno.*

   open window w_cts22m01 at 8,2 with form 'cts22m01'
      attribute(form line 1)

   if lr_param.acao = 'CON' or lr_param.acao is null then
      call cts22m01_display(lr_param.acao)
   else
      call cts22m01_input(lr_param.acao)
   end if

   close window w_cts22m01

   let int_flag = false

   let lr_retorno.* = mr_tela.*

   return lr_retorno.hsphotnom
         ,lr_retorno.hsphotend
         ,lr_retorno.hsphotbrr
         ,lr_retorno.hsphotuf
         ,lr_retorno.hsphotcid
         ,lr_retorno.hsphottelnum
         ,lr_retorno.hsphotcttnom
         ,lr_retorno.hsphotdiavlr
         ,lr_retorno.hsphotacmtip
         ,lr_retorno.obsdes
         ,lr_retorno.hsphotrefpnt

 end function

#-----------------------------------------#
 function cts22m01_input(l_acao)
#-----------------------------------------#

   define l_acao char(003)

   define lr_tela_ant record
                      hsphotnom    like datmhosped.hsphotnom
                     ,hsphotend    like datmhosped.hsphotend
                     ,hsphotbrr    like datmhosped.hsphotbrr
                     ,hsphotuf     like datmhosped.hsphotuf
                     ,hsphotcid    like datmhosped.hsphotcid
                     ,hsphottelnum like datmhosped.hsphottelnum
                     ,hsphotcttnom like datmhosped.hsphotcttnom
                     ,hsphotdiavlr like datmhosped.hsphotdiavlr
                     ,hsphotacmtip like datmhosped.hsphotacmtip
                     ,obsdes       like datmhosped.obsdes
                     ,hsphotrefpnt like datmhosped.hsphotrefpnt
                      end record

   initialize lr_tela_ant to null

   let lr_tela_ant.* = mr_tela.*

   call cts22m01_display(l_acao)

   input by name mr_tela.hsphotnom
                ,mr_tela.hsphotuf
                ,mr_tela.hsphotcid
                ,mr_tela.hsphotend
                ,mr_tela.hsphotbrr
                ,mr_tela.hsphotrefpnt
                ,mr_tela.hsphotcttnom
                ,mr_tela.hsphottelnum
                ,mr_tela.hsphotacmtip
                ,mr_tela.obsdes        without defaults

      before field hsphotnom
         display by name mr_tela.hsphotnom attribute(reverse)

      after field hsphotnom
         display by name mr_tela.hsphotnom

         if mr_tela.hsphotnom is null or
            mr_tela.hsphotnom = ' '   then
            error 'Informe o nome do hotel'
            next field hsphotnom
         end if

      before field hsphotuf
         display by name mr_tela.hsphotuf attribute(reverse)

      after field hsphotuf
         display by name mr_tela.hsphotuf

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphotnom
         end if

         if mr_tela.hsphotuf is null or
            mr_tela.hsphotuf = ' '   then
            error 'Informe o estado do hotel'
            next field hsphotuf
         end if

      before field hsphotcid
         display by name mr_tela.hsphotcid attribute(reverse)

      after field hsphotcid
         display by name mr_tela.hsphotcid

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphotuf
         end if

         if mr_tela.hsphotcid is null or
            mr_tela.hsphotcid = ' '   then
            error 'Informe a cidade do hotel'
            next field hsphotcid
         end if

      before field hsphotend
         display by name mr_tela.hsphotend attribute(reverse)

      after field hsphotend
         display by name mr_tela.hsphotend

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphotcid
         end if

         if mr_tela.hsphotend is null or
            mr_tela.hsphotend = ' '   then
            error 'Informe o endereco do hotel'
            next field hsphotend
         end if

      before field hsphotbrr
         display by name mr_tela.hsphotbrr attribute(reverse)

      after field hsphotbrr
         display by name mr_tela.hsphotbrr

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphotend
         end if

      before field hsphotrefpnt
         display by name mr_tela.hsphotrefpnt attribute(reverse)

      after field hsphotrefpnt
         display by name mr_tela.hsphotrefpnt

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphotbrr
         end if

      before field hsphotcttnom
         display by name mr_tela.hsphotcttnom attribute(reverse)

      after field hsphotcttnom
         display by name mr_tela.hsphotcttnom

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphotrefpnt
         end if

         if mr_tela.hsphotcttnom is null or
            mr_tela.hsphotcttnom = ' '   then
            error 'Informe o nome para contato no hotel'
            next field hsphotcttnom
         end if

      before field hsphottelnum
         display by name mr_tela.hsphottelnum attribute(reverse)

      after field hsphottelnum
         display by name mr_tela.hsphottelnum

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphotcttnom
         end if

         if mr_tela.hsphottelnum is null or
            mr_tela.hsphottelnum = ' '   then
            error 'Informe o telefone do hotel'
            next field hsphottelnum
         end if

      before field hsphotacmtip
         display by name mr_tela.hsphotacmtip attribute(reverse)

      after field hsphotacmtip
         display by name mr_tela.hsphotacmtip

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphottelnum
         end if

         if mr_tela.hsphotacmtip is null or
            mr_tela.hsphotacmtip = ' '   then
            error 'Informe o tipo de acomodacao do hotel'
            next field hsphotacmtip
         end if

      before field obsdes
         display by name mr_tela.obsdes attribute(reverse)

      after field obsdes
         display by name mr_tela.obsdes

         if fgl_lastkey() = fgl_keyval('up')   or
            fgl_lastkey() = fgl_keyval('left') then
            next field hsphotacmtip
         end if

      on key(interrupt,control-c,f17)
         let mr_tela.* = lr_tela_ant.*
         exit input

   end input

 end function

#-----------------------------------------#
 function cts22m01_selecionar(lr_param)
#-----------------------------------------#

   define lr_param record
                   nivel     smallint
                  ,atdsrvnum like datmhosped.atdsrvnum
                  ,atdsrvano like datmhosped.atdsrvano
                   end record

   define lr_retorno record
                     resultado    smallint
                    ,mensagem     char(080)
                    ,hsphotnom    like datmhosped.hsphotnom
                    ,hsphotend    like datmhosped.hsphotend
                    ,hsphotbrr    like datmhosped.hsphotbrr
                    ,hsphotuf     like datmhosped.hsphotuf
                    ,hsphotcid    like datmhosped.hsphotcid
                    ,hsphottelnum like datmhosped.hsphottelnum
                    ,hsphotcttnom like datmhosped.hsphotcttnom
                    ,hsphotdiavlr like datmhosped.hsphotdiavlr
                    ,hsphotacmtip like datmhosped.hsphotacmtip
                    ,obsdes       like datmhosped.obsdes
                    ,hsphotrefpnt like datmhosped.hsphotrefpnt
                    ,hpddiapvsqtd like datmhosped.hpddiapvsqtd
                    ,hpdqrtqtd    like datmhosped.hpdqrtqtd
                     end record

   initialize lr_retorno to null

   if m_prep_cts22m01 is null or
      m_prep_cts22m01 <> true then
      call cts22m01_prepare()
   end if

   #Obter as informacoes do hotel
   if lr_param.nivel = 1 then
      open c_cts22m01_001 using lr_param.atdsrvnum
                             ,lr_param.atdsrvano
      whenever error continue
      fetch c_cts22m01_001 into lr_retorno.hsphotnom
                             ,lr_retorno.hsphotend
                             ,lr_retorno.hsphotbrr
                             ,lr_retorno.hsphotuf
                             ,lr_retorno.hsphotcid
                             ,lr_retorno.hsphottelnum
                             ,lr_retorno.hsphotcttnom
                             ,lr_retorno.hsphotdiavlr
                             ,lr_retorno.hsphotacmtip
                             ,lr_retorno.obsdes
                             ,lr_retorno.hsphotrefpnt
                             ,lr_retorno.hpddiapvsqtd
                             ,lr_retorno.hpdqrtqtd
      whenever error stop

      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = 'Hospedagem nao encontrada'
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = 'Erro: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
                                      ,' em datmhosped - cts22m01_selecionar'
         end if
      end if
   end if

   return lr_retorno.resultado
         ,lr_retorno.mensagem
         ,lr_retorno.hsphotnom
         ,lr_retorno.hsphotend
         ,lr_retorno.hsphotbrr
         ,lr_retorno.hsphotuf
         ,lr_retorno.hsphotcid
         ,lr_retorno.hsphottelnum
         ,lr_retorno.hsphotcttnom
         ,lr_retorno.hsphotdiavlr
         ,lr_retorno.hsphotacmtip
         ,lr_retorno.obsdes
         ,lr_retorno.hsphotrefpnt
         ,lr_retorno.hpddiapvsqtd
         ,lr_retorno.hpdqrtqtd

 end function

#-----------------------------------------#
 function cts22m01_gravar(lr_param)
#-----------------------------------------#

   define lr_param record
                   acao         char(001)
                  ,atdsrvnum    like datmhosped.atdsrvnum
                  ,atdsrvano    like datmhosped.atdsrvano
                  ,hpddiapvsqtd like datmhosped.hpddiapvsqtd
                  ,hpdqrtqtd    like datmhosped.hpdqrtqtd
                  ,hsphotnom    like datmhosped.hsphotnom
                  ,hsphotend    like datmhosped.hsphotend
                  ,hsphotbrr    like datmhosped.hsphotbrr
                  ,hsphotuf     like datmhosped.hsphotuf
                  ,hsphotcid    like datmhosped.hsphotcid
                  ,hsphottelnum like datmhosped.hsphottelnum
                  ,hsphotcttnom like datmhosped.hsphotcttnom
                  ,hsphotacmtip like datmhosped.hsphotacmtip
                  ,obsdes       like datmhosped.obsdes
                  ,hsphotrefpnt like datmhosped.hsphotrefpnt
                   end record

   define lr_retorno record
                    resultado smallint
                   ,mensagem  char(080)
                    end record

   let lr_retorno.resultado = 1
   let lr_retorno.mensagem  = null

   if m_prep_cts22m01 is null or
      m_prep_cts22m01 <> true then
      call cts22m01_prepare()
   end if

   if lr_param.acao = 'I' then
      whenever error continue
      execute p_cts22m01_002 using lr_param.atdsrvnum
                                ,lr_param.atdsrvano
                                ,lr_param.hpddiapvsqtd
                                ,lr_param.hpdqrtqtd
                                ,lr_param.hsphotnom
                                ,lr_param.hsphotend
                                ,lr_param.hsphotbrr
                                ,lr_param.hsphotuf
                                ,lr_param.hsphotcid
                                ,lr_param.hsphottelnum
                                ,lr_param.hsphotcttnom
                                ,lr_param.hsphotacmtip
                                ,lr_param.obsdes
                                ,lr_param.hsphotrefpnt
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = 'Erro: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
                                   ,' em datmhosped - cts22m01_gravar'
      end if
   else
      whenever error continue
      execute p_cts22m01_004 using lr_param.hsphotnom
                                ,lr_param.hsphotend
                                ,lr_param.hsphotbrr
                                ,lr_param.hsphotuf
                                ,lr_param.hsphotcid
                                ,lr_param.hsphottelnum
                                ,lr_param.hsphotcttnom
                                ,lr_param.hpddiapvsqtd
                                ,lr_param.hpdqrtqtd
                                ,lr_param.hsphotacmtip
                                ,lr_param.obsdes
                                ,lr_param.hsphotrefpnt
                                ,lr_param.atdsrvnum
                                ,lr_param.atdsrvano
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = 'Erro: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
                                   ,' em datmhosped - cts22m01_gravar'
      end if
   end if

   return lr_retorno.resultado
         ,lr_retorno.mensagem

 end function

#-----------------------------------------#
 function cts22m01_atualizar(lr_param)
#-----------------------------------------#

   define lr_param record
                   acao         char(001)
                  ,atdsrvnum    like datmhosped.atdsrvnum
                  ,atdsrvano    like datmhosped.atdsrvano
                  ,hsphotnom    like datmhosped.hsphotnom
                  ,hsphotend    like datmhosped.hsphotend
                  ,hsphotbrr    like datmhosped.hsphotbrr
                  ,hsphotuf     like datmhosped.hsphotuf
                  ,hsphotcid    like datmhosped.hsphotcid
                  ,hsphottelnum like datmhosped.hsphottelnum
                  ,hsphotcttnom like datmhosped.hsphotcttnom
                  ,hsphotacmtip like datmhosped.hsphotacmtip
                  ,obsdes       like datmhosped.obsdes
                  ,hsphotrefpnt like datmhosped.hsphotrefpnt
                   end record

   define lr_retorno record
                     resultado smallint
                    ,mensagem  char(080)
                     end record

   initialize lr_retorno to null

   if m_prep_cts22m01 is null or
      m_prep_cts22m01 <> true then
      call cts22m01_prepare()
   end if

   if lr_param.acao = 'M' then
      let lr_retorno.resultado = 1
      whenever error continue
      execute p_cts22m01_003 using lr_param.hsphotnom
                                ,lr_param.hsphotend
                                ,lr_param.hsphotbrr
                                ,lr_param.hsphotuf
                                ,lr_param.hsphotcid
                                ,lr_param.hsphottelnum
                                ,lr_param.hsphotcttnom
                                ,lr_param.hsphotacmtip
                                ,lr_param.obsdes
                                ,lr_param.hsphotrefpnt
                                ,lr_param.atdsrvnum
                                ,lr_param.atdsrvano
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = 'Erro: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
                                   ,' em datmhosped - cts22m01_atualizar'
      end if
   end if

   return lr_retorno.resultado
         ,lr_retorno.mensagem

 end function

#-----------------------------------------#
 function cts22m01_display(l_acao)
#-----------------------------------------#

   define l_acao char(003)

   define l_valorhospdes char(019)
         ,l_resp         char(001)

   if mr_tela.hsphotdiavlr > 0 then
      let l_valorhospdes = 'Valor hospedagem..:'
      display l_valorhospdes to valorhospdes
      display by name mr_tela.hsphotdiavlr
   end if

   display by name mr_tela.hsphotnom
   display by name mr_tela.hsphotend
   display by name mr_tela.hsphotuf
   display by name mr_tela.hsphotcid
   display by name mr_tela.hsphotbrr
   display by name mr_tela.hsphottelnum
   display by name mr_tela.hsphotcttnom
   display by name mr_tela.hsphotacmtip
   display by name mr_tela.obsdes
   display by name mr_tela.hsphotrefpnt

   if l_acao = 'CON' or l_acao is null then
      prompt 'Tecle qualquer tecla para sair...' for char l_resp
   end if
 end function
