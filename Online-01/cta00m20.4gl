#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto - Porto Residencia                                   #
# Modulo.........: cta00m20                                                  #
# Objetivo.......: Funcoes especificas p/ Porto Seguro seguro                #
# Analista Resp. : Alberto Rodrigues                                         #
# PSI            : 218545                                                    #
#............................................................................#
# Desenvolvimento: Alinne, META                                              #
# Liberacao      : 25/01/2007                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 13/08/2009 Sergio Burini 244236    Inclusão do Sub-Dairro                  #                                                                           #
#----------------------------------------------------------------------------#
# 21/10/2010 Alberto Rodrigues       Correcao de ^M                          #
#----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

   define mr_tela record
                  ligdctnum like datrligsemapl.ligdctnum
                 ,solnom    like datmservico.nom
                 ,lgdcep    like datmlcl.lgdcep
                 ,lgdcepcmp like datmlcl.lgdcepcmp
                 ,cidnom    like datmlcl.cidnom
                 ,ufdcod    like datmlcl.ufdcod
                 ,lgdnom    like datmlcl.lgdnom
                 ,dctitm    like datrligsemapl.dctitm
                 ,lgdnum    like datmlcl.lgdnum
                 ,lclbrrnom like datmlcl.lclbrrnom
                 ,dddport   smallint
                 ,telport   decimal(8,0)
                 ,email     char(060)
                  end record

   define m_lgdtip    like datmlcl.lgdtip
         ,m_relpamtxt like igbmparam.relpamtxt
         ,m_ligdcttip like datrligsemapl.ligdcttip

   define m_prep_cta00m20 smallint

#----------------------------------#
 function cta00m20_prepare()
#----------------------------------#

   define l_sql char(800)

   let l_sql = ' select c.lignum    '
              ,'       ,c.dctitm    '
              ,'       ,a.atdsrvnum '
              ,'       ,a.atdsrvano '
              ,'       ,b.nom       '
              ,'   from datmligacao a, datmservico b, datrligsemapl c '
              ,'  where a.atdsrvnum = b.atdsrvnum '
              ,'    and a.atdsrvano = b.atdsrvano '
              ,'    and a.lignum    = c.lignum    '
              ,'    and c.ligdcttip = 3 '
              ,'    and c.ligdctnum = ? '
              ,' order by lignum desc   '

   prepare p_cta00m20_001 from l_sql
   declare c_cta00m20_001 cursor for p_cta00m20_001

   let l_sql = ' select lgdtip       '
              ,'       ,lgdnom       '
              ,'       ,lgdnum       '
              ,'       ,brrnom    '
              ,'       ,cidnom       '
              ,'       ,ufdcod       '
              ,'       ,lgdcep       '
              ,'       ,lgdcepcmp    '
              ,'   from datmlcl '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'    and c24endtip = 1 '

   prepare p_cta00m20_002 from l_sql
   declare c_cta00m20_002 cursor for p_cta00m20_002

   let l_sql = ' select relpamtxt '
              ,'   from igbmparam '
              ,'  where relsgl    = ? '
              ,'    and relpamseq = 1 '
              ,'    and relpamtip is null '

   prepare p_cta00m20_003 from l_sql
   declare c_cta00m20_003 cursor for p_cta00m20_003

   let m_prep_cta00m20 = true

 end function

#----------------------------------#
 function cta00m20_pesq_cliente()
#----------------------------------#

   define l_cont smallint

   if m_prep_cta00m20 is null or
      m_prep_cta00m20 <> true then
      call cta00m20_prepare()
   end if

   open window w_cta00m20 at 4,2 with form "cta00m20"
      attribute(menu line 1)

   call cta00m20_input()

   close window w_cta00m20

   let int_flag = false

   let l_cont = length(m_lgdtip)

   let mr_tela.lgdnom = mr_tela.lgdnom[l_cont + 1,60]
   let m_ligdcttip    = 3

   return mr_tela.ligdctnum
         ,m_ligdcttip
         ,m_lgdtip
         ,mr_tela.lgdnom
         ,mr_tela.lgdnum
         ,mr_tela.ufdcod
         ,mr_tela.lclbrrnom
         ,mr_tela.cidnom
         ,mr_tela.lgdcep
         ,mr_tela.lgdcepcmp
         ,mr_tela.solnom
         ,m_relpamtxt
         ,mr_tela.dctitm

 end function

#-------------------------------#
 function cta00m20_input()
#-------------------------------#

   define l_ligdctnum like datrligsemapl.ligdctnum

   define l_erro smallint
         ,l_msg  char(060)

   let l_erro      = 0
   let l_msg       = null
   let l_ligdctnum = null

   initialize mr_tela  to null
   clear form

   input by name mr_tela.ligdctnum
                ,mr_tela.solnom
                ,mr_tela.lgdcep
                ,mr_tela.lgdcepcmp
                ,mr_tela.cidnom
                ,mr_tela.ufdcod
                ,mr_tela.lgdnom
                ,mr_tela.lgdnum
                ,mr_tela.dctitm
                ,mr_tela.lclbrrnom
                ,mr_tela.dddport
                ,mr_tela.telport
                ,mr_tela.email    without defaults

      before field ligdctnum
         display by name mr_tela.ligdctnum attribute(reverse)

      after field ligdctnum
         display by name mr_tela.ligdctnum

         if mr_tela.ligdctnum is null then
            error 'Informe um Numero de Contrato'
            next field ligdctnum
         end if

         call ctx29g00_verific_dv(mr_tela.ligdctnum)
            returning l_erro
                     ,l_msg

         if l_erro <> 0 then
            error l_msg clipped
            next field ligdctnum
         end if

         let l_ligdctnum = mr_tela.ligdctnum

         let l_erro = cta00m20_contrato()

         if l_erro = 1 then
            clear form
            initialize mr_tela to null
            let mr_tela.ligdctnum = l_ligdctnum
         else
            if l_erro = 2 then
               clear form
               initialize mr_tela to null
               exit input
            end if
         end if

         display by name mr_tela.ligdctnum

      before field solnom
         display by name mr_tela.solnom attribute(reverse)

      after field solnom
         display by name mr_tela.solnom

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field ligdctnum
         end if

         if mr_tela.solnom is null or
            mr_tela.solnom = ' '   then
            error 'Informe o nome do Solicitante'
            next field solnom
         end if

      before field lgdcep
         display by name mr_tela.lgdcep attribute(reverse)

      after field lgdcep
         display by name mr_tela.lgdcep

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field solnom
         end if

      before field lgdcepcmp
         display by name mr_tela.lgdcepcmp attribute(reverse)

      after field lgdcepcmp
         display by name mr_tela.lgdcepcmp

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field lgdcep
         end if

      before field cidnom
         display by name mr_tela.cidnom attribute(reverse)

      after field cidnom
         display by name mr_tela.cidnom

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            if mr_tela.lgdcepcmp is not null then
               next field lgdcepcmp
            else
               next field lgdcep
            end if
         end if

      before field ufdcod
         display by name mr_tela.ufdcod attribute(reverse)

      after field ufdcod
         display by name mr_tela.ufdcod

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field cidnom
         end if

      before field lgdnom
         display by name mr_tela.lgdnom attribute(reverse)

      after field lgdnom
         display by name mr_tela.lgdnom

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field ufdcod
         end if

      before field lgdnum
         display by name mr_tela.lgdnum attribute(reverse)

      after field lgdnum
         display by name mr_tela.lgdnum

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field lgdnom
         end if

      before field dctitm
         display by name mr_tela.dctitm attribute(reverse)

      after field dctitm
         display by name mr_tela.dctitm

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field lgdnum
         end if

      before field lclbrrnom
         display by name mr_tela.lclbrrnom attribute(reverse)

      after field lclbrrnom
         display by name mr_tela.lclbrrnom

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field dctitm
         end if

      before field dddport
         display by name mr_tela.dddport attribute(reverse)

      after field dddport
         display by name mr_tela.dddport

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field lclbrrnom
         end if

         if mr_tela.dddport is null then
            next field email
         end if

      before field telport
         display by name mr_tela.telport attribute(reverse)

      after field telport
         display by name mr_tela.telport

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            next field dddport
         end if

         if mr_tela.dddport is not null then
            if mr_tela.telport is null then
               error 'Informe o numero de telefone da protaria!'
               next field telport
            end if
         end if

      before field email
         display by name mr_tela.email attribute(reverse)

      after field email
         display by name mr_tela.email

         if fgl_lastkey() = fgl_keyval("left") or
            fgl_lastkey() = fgl_keyval("up"  ) then
            if mr_tela.telport is not null then
               next field telport
            else
               next field dddport
            end if
         end if

         if mr_tela.telport is null then
            if mr_tela.email is null or
               mr_tela.email = ' '   then
               error 'Informe o email da portaria!'
               next field email
            end if
         end if

         let m_relpamtxt = mr_tela.dddport using '&&','|'
                          ,mr_tela.telport using '&&&&&&&&','|'
                          ,mr_tela.email


      on key(control-c,f17,interrupt)
         clear form
         initialize mr_tela to null
         exit input

   end input

   let int_flag = false

 end function

#-------------------------------#
 function cta00m20_contrato()
#-------------------------------#

   define l_lignum    like datrligsemapl.lignum
         ,l_atdsrvnum like datmligacao.atdsrvnum
         ,l_atdsrvano like datmligacao.atdsrvano

   define l_erro smallint

   let l_lignum    = null
   let l_atdsrvnum = null
   let l_atdsrvano = null
   let l_erro      = 0

   open c_cta00m20_001 using mr_tela.ligdctnum
   whenever error continue
   fetch c_cta00m20_001 into l_lignum
                          ,mr_tela.dctitm
                          ,l_atdsrvnum
                          ,l_atdsrvano
                          ,mr_tela.solnom
   whenever error stop

   if sqlca.sqlcode = 0 then
      if not cta00m20_busca_end(l_atdsrvnum, l_atdsrvano) then
         let l_erro = 2
      end if

      if l_erro = 0 then
         if not cta00m20_dados_adicionais() then
            let l_erro = 2
         end if
      end if

      call cta00m20_display()
   else
      if sqlca.sqlcode = notfound then
         let l_erro = 1
      else
         error 'Erro SELECT ccta00m20001: ',sqlca.sqlcode,' | ',sqlca.sqlerrd[2] sleep 2
         error 'cta00m20/ cta00m20_contrato()/ ',mr_tela.ligdctnum sleep 2
         let l_erro = 2
      end if
   end if

   return l_erro

 end function

#---------------------------------------#
 function cta00m20_busca_end(lr_param)
#---------------------------------------#

   define lr_param record
                   atdsrvnum like datmligacao.atdsrvnum
                  ,atdsrvano like datmligacao.atdsrvano
                   end record

   define l_ok smallint

   let m_lgdtip = null
   let l_ok     = true

   open c_cta00m20_002 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
   whenever error continue
   fetch c_cta00m20_002 into m_lgdtip
                          ,mr_tela.lgdnom
                          ,mr_tela.lgdnum
                          ,mr_tela.lclbrrnom
                          ,mr_tela.cidnom
                          ,mr_tela.ufdcod
                          ,mr_tela.lgdcep
                          ,mr_tela.lgdcepcmp
   whenever error stop

   if sqlca.sqlcode = 0 then
      let mr_tela.lgdnom = m_lgdtip clipped, ' ', mr_tela.lgdnom clipped
   else
      if sqlca.sqlcode = notfound then
         let mr_tela.lgdnom    = null
         let mr_tela.lgdnum    = null
         let mr_tela.lclbrrnom = null
         let mr_tela.cidnom    = null
         let mr_tela.ufdcod    = null
         let mr_tela.lgdcep    = null
         let mr_tela.lgdcepcmp = null
      else
         error 'Erro SELECT ccta00m20002: ',sqlca.sqlcode,' | ',sqlca.sqlerrd[2] sleep 2
         error 'cta00m20/ cta00m20_busca_end()/ ',lr_param.atdsrvnum
                                           ,' / ',lr_param.atdsrvano sleep 2
         let l_ok = false
      end if
   end if

   return l_ok

 end function

#--------------------------------------#
 function cta00m20_dados_adicionais()
#--------------------------------------#

   define l_ok        smallint
         ,l_ligdctnum char(011)

   let m_relpamtxt = null
   let l_ok        = true
   let l_ligdctnum = mr_tela.ligdctnum

   open c_cta00m20_003 using l_ligdctnum
   whenever error continue
   fetch c_cta00m20_003 into m_relpamtxt
   whenever error stop

   if sqlca.sqlcode = 0 then
      let mr_tela.dddport = m_relpamtxt[1,2]
      let mr_tela.telport = m_relpamtxt[4,11]
      let mr_tela.email   = m_relpamtxt[13,75]
   else
      if sqlca.sqlcode = notfound then
         let mr_tela.dddport = null
         let mr_tela.telport = null
         let mr_tela.email   = null
      else
         error 'Erro SELECT ccta00m20003: ',sqlca.sqlcode,' | ',sqlca.sqlerrd[2] sleep 2
         error 'cta00m20/ cta00m20_dados_adicionais()/ ',mr_tela.ligdctnum sleep 2
         let l_ok = false
      end if
   end if

   return l_ok

 end function

#---------------------------------------#
 function cta00m20_display()
#---------------------------------------#

  display by name mr_tela.ligdctnum
  display by name mr_tela.solnom
  display by name mr_tela.lgdcep
  display by name mr_tela.lgdcepcmp
  display by name mr_tela.cidnom
  display by name mr_tela.ufdcod
  display by name mr_tela.lgdnom
  display by name mr_tela.dctitm
  display by name mr_tela.lgdnum
  display by name mr_tela.lclbrrnom
  display by name mr_tela.dddport
  display by name mr_tela.telport
  display by name mr_tela.email

 end function
