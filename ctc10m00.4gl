# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: ctc10m00                                                  #
# Objetivo.......: Obter o tipo de acionamento/email da locadora             #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 196878                                                    #
#............................................................................#
# Desenvolvimento: Andrei, META                                              #
# Liberacao      : 23/02/2006                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql smallint

 define m_atlhor    char(05)
 define mr_ctc10m00 record
                    aerciacod    like datkciaaer.aerciacod
                   ,aercianom    like datkciaaer.aercianom
                   ,cgccpfnumdig like datkciaaer.cgccpfnumdig
                   ,cgccpford    like datkciaaer.cgccpford
                   ,cgccpfdig    like datkciaaer.cgccpfdig
                   ,fonnum       like datkciaaer.fonnum
                   ,faxnum       like datkciaaer.faxnum
                   ,enddes       like datkciaaer.enddes
                   ,endbrr       like datkciaaer.endbrr
                   ,cidcod       like datkciaaer.cidcod
                   ,cidnom       like glakcid.cidnom
                   ,ufdcod       like glakcid.ufdcod
                   ,aerpsgrsrflg like datkciaaer.aerpsgrsrflg
                   ,aerpsgemsflg like datkciaaer.aerpsgemsflg
                   ,aercmpsit    like datkciaaer.aercmpsit
                   ,atldat       like datkciaaer.atldat
                   ,atlhor       like datkciaaer.atlhor
                   ,atlusrtip    like datkciaaer.atlusrtip
                   ,atlemp       like datkciaaer.atlemp
                   ,funmat       like datkciaaer.atlmat
                   ,funnom       like isskfunc.funnom
                end record

 define m_resultado    smallint
       ,m_lixo         char(01)
       ,m_funnom       char(30)

#--------------------------
function ctc10m00_prepare()
#--------------------------

 define l_sql char(500)

 let l_sql = 'select aerciacod, aercianom, cgccpfnumdig, '
            ,'       cgccpford, cgccpfdig, fonnum, '
            ,'       faxnum, enddes, endbrr, '
            ,'       cidcod, aerpsgrsrflg, aerpsgemsflg, '
            ,'       aercmpsit, atldat, atlhor, '
            ,'       atlmat, atlemp '
            ,'  from datkciaaer '
            ,' where aerciacod = ?'

 prepare pctc10m00001 from l_sql
 declare cctc10m00001 cursor for pctc10m00001

 let l_sql = 'insert into datkciaaer '
            ,'(aerciacod, aercianom, cgccpfnumdig, '
            ,' cgccpford, cgccpfdig, fonnum, '
            ,' faxnum, enddes, endbrr, '
            ,' cidcod, aerpsgrsrflg, aerpsgemsflg, '
            ,' aercmpsit, atldat, atlhor, '
            ,' atlusrtip, atlemp, atlmat) '
            ,' values '
            ,' (?,?,?,?,?,?,?,?,?,?,?,?,?,today, current,?,?,?) '

 prepare pctc10m00002 from l_sql

 let l_sql = 'update  datkciaaer '
            ,' set aercianom    = ? '
            ,'    ,cgccpfnumdig = ? '
            ,'    ,cgccpford    = ? '
            ,'    ,cgccpfdig    = ? '
            ,'    ,fonnum       = ? '
            ,'    ,faxnum       = ? '
            ,'    ,enddes       = ? '
            ,'    ,endbrr       = ? '
            ,'    ,cidcod       = ? '
            ,'    ,aerpsgrsrflg = ? '
            ,'    ,aerpsgemsflg = ? '
            ,'    ,aercmpsit    = ? '
            ,'    ,atldat       = today '
            ,'    ,atlhor       = current '
            ,'    ,atlusrtip    = ? '
            ,'    ,atlemp       = ? '
            ,'    ,atlmat       = ? '
            ,' where aerciacod  = ? '

  prepare pctc10m00003 from l_sql

  let l_sql = 'select cidnom, ufdcod '
             ,'  from glakcid '
             ,' where cidcod = ? '

 prepare pctc10m00004 from l_sql
 declare cctc10m00004 cursor for pctc10m00004

  let l_sql = 'select aerciacod, aercianom, cgccpfnumdig, '
             ,'        cgccpford, cgccpfdig, fonnum, '
             ,'        faxnum, enddes, endbrr, '
             ,'        cidcod, aerpsgrsrflg, aerpsgemsflg, '
             ,'        aercmpsit, atldat, atlhor, '
             ,'        atlmat, atlemp '
             ,'   from datkciaaer '
             ,' where aerciacod > ? '
             ,' order by aerciacod '

 prepare pctc10m00005 from l_sql
 declare cctc10m00005 cursor for pctc10m00005

  let l_sql = 'select aerciacod, aercianom, cgccpfnumdig, '
             ,'        cgccpford, cgccpfdig, fonnum, '
             ,'        faxnum, enddes, endbrr, '
             ,'        cidcod, aerpsgrsrflg, aerpsgemsflg, '
             ,'        aercmpsit, atldat, atlhor, '
             ,'        atlmat, atlemp '
             ,'   from datkciaaer '
             ,' where aerciacod < ? '
             ,' order by aerciacod desc '

 prepare pctc10m00006 from l_sql
 declare cctc10m00006 cursor for pctc10m00006

 let l_sql = 'select max(aerciacod) '
            ,'  from datkciaaer '

 prepare pctc10m00007 from l_sql
 declare cctc10m00007 cursor for pctc10m00007

 let m_prep_sql = true

end function

#-------------------
function ctc10m00()
#-------------------

 define l_retorno smallint

 let l_retorno = true

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc10m00_prepare()
 end if

 initialize mr_ctc10m00 to null

 open window w_ctc10m00 at 04,02 with form 'ctc10m00'

 menu 'CiaAereas'

   before menu
      hide option 'Proximo', 'Anterior'

   command key ('I') 'Incluir' 'Inclui um novo registro'
      call ctc10m00_input('I')
      hide option  'Proximo', 'Anterior'

   command key ('S') 'Selecionar' 'Seleciona um registro'
      call ctc10m00_input('S')
      if mr_ctc10m00.aerciacod is null then
         hide option  'Proximo', 'Anterior'
      else
         show option  'Proximo', 'Anterior'
      end if

   command key ('P') 'Proximo' 'Seleciona o proximo registro'
      if mr_ctc10m00.aerciacod is not null then
         call ctc10m00_proximo_anterior('P')
      else
         error 'Selecione um registro '
         next option 'Selecionar'
      end if

   command key ('A') 'Anterior' 'Seleciona o registro anterior'
      if mr_ctc10m00.aerciacod is not null then
         call ctc10m00_proximo_anterior('A')
      else
         error 'Selecione um registro '
         next option 'Selecionar'
      end if

   command key ('M') 'Modificar' 'Altera um registro'
      if mr_ctc10m00.aerciacod is not null then
         call ctc10m00_input('M')

         if mr_ctc10m00.aerciacod is null then
            hide option  'Proximo', 'Anterior'
         end if
      else
         error 'Selecione um registro'
      end if

      next option 'Selecionar'

   command key ('E') 'Encerra' 'Volta ao menu anterior'
      exit menu

 end menu

 let int_flag = false

 close window w_ctc10m00

end function


#-------------------------------
function ctc10m00_input(l_opcao)
#-------------------------------

 define l_opcao   char(001)

 define l_cgccpfdig like datkciaaer.cgccpfdig
       ,l_resultado smallint
       ,l_mensagem  char (080)
       ,l_retorno   smallint
       ,l_sql       char(200)

 let l_cgccpfdig = null
 let l_resultado = null
 let l_mensagem  = null
 let l_retorno   = null
 let l_sql       = null

 if l_opcao = 'S' or
    l_opcao = 'I' then
    initialize mr_ctc10m00 to null
    clear form
 end if

 input by name mr_ctc10m00.aerciacod
              ,mr_ctc10m00.aercianom
              ,mr_ctc10m00.cgccpfnumdig
              ,mr_ctc10m00.cgccpford
              ,mr_ctc10m00.cgccpfdig
              ,mr_ctc10m00.fonnum
              ,mr_ctc10m00.faxnum
              ,mr_ctc10m00.enddes
              ,mr_ctc10m00.endbrr
              ,mr_ctc10m00.cidnom
              ,mr_ctc10m00.ufdcod
              ,mr_ctc10m00.aerpsgrsrflg
              ,mr_ctc10m00.aerpsgemsflg
              ,mr_ctc10m00.aercmpsit    without defaults

    before field aerciacod
       if l_opcao <> 'S' then
          next field aercianom
       end if
       display mr_ctc10m00.aerciacod to aerciacod attribute (reverse)

    after field aerciacod
       display mr_ctc10m00.aerciacod to aerciacod

       if mr_ctc10m00.aerciacod is null then
          let l_sql = 'select aerciacod, aercianom '
                     ,'  from datkciaaer '
                     ,' order by aercianom '

          call ofgrc001_popup(10, 12, 'Cia Aereas', 'Codigo', 'Nome', 'A', l_sql, '', 'D')
               returning l_retorno
                        ,mr_ctc10m00.aerciacod
                        ,mr_ctc10m00.aercianom

          if l_retorno <> 0 then
             next field aerciacod
          end if
       end if

       open cctc10m00001 using mr_ctc10m00.aerciacod

       whenever error continue
       fetch cctc10m00001 into mr_ctc10m00.aerciacod
                              ,mr_ctc10m00.aercianom
                              ,mr_ctc10m00.cgccpfnumdig
                              ,mr_ctc10m00.cgccpford
                              ,mr_ctc10m00.cgccpfdig
                              ,mr_ctc10m00.fonnum
                              ,mr_ctc10m00.faxnum
                              ,mr_ctc10m00.enddes
                              ,mr_ctc10m00.endbrr
                              ,mr_ctc10m00.cidcod
                              ,mr_ctc10m00.aerpsgrsrflg
                              ,mr_ctc10m00.aerpsgemsflg
                              ,mr_ctc10m00.aercmpsit
                              ,mr_ctc10m00.atldat
                              ,mr_ctc10m00.atlhor
                              ,mr_ctc10m00.funmat
                              ,mr_ctc10m00.atlemp
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             error 'Registro nao encontrado ' 
             next field aerciacod
          else
             error 'Erro SELECT cctc10m00001 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] 
             error 'CTC10M00 / ctc10m00_input() / ', mr_ctc10m00.aerciacod 
             let int_flag = true
          end if
       end if

       call cty08g00_nome_func(g_issk.empcod, g_issk.funmat, g_issk.usrtip)
          returning l_retorno
                   ,l_mensagem
                   ,mr_ctc10m00.funnom

       open cctc10m00004 using mr_ctc10m00.cidcod

       whenever error continue
       fetch cctc10m00004 into mr_ctc10m00.cidnom
                              ,mr_ctc10m00.ufdcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
           let mr_ctc10m00.cidnom = null
           let mr_ctc10m00.ufdcod = null
         else
           error 'Erro SELECT cctc10m00004 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] 
           error 'CTC10M00 / ctc10m00_input() / ', mr_ctc10m00.cidcod 
           let int_flag = true
           exit input
         end if
       end if

       call ctc10m00_mostra()

       if l_opcao = 'S' then
          exit input
       end if

    before field aercianom
       display mr_ctc10m00.aercianom to aercianom attribute (reverse)

    after field aercianom
       display mr_ctc10m00.aercianom to aercianom
       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field aerciacod
       end if

       if mr_ctc10m00.aercianom is null or
          mr_ctc10m00.aercianom = ' '   then
          error 'Digite o nome da empresa '
          next field aercianom
       end if

    before field cgccpfnumdig
       display mr_ctc10m00.cgccpfnumdig to cgccpfnumdig attribute (reverse)

    after field cgccpfnumdig
       display mr_ctc10m00.cgccpfnumdig to cgccpfnumdig

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field aercianom
       end if

       if mr_ctc10m00.cgccpfnumdig is null or
          mr_ctc10m00.cgccpfnumdig = 0     then
          error 'Numero do CNPJ deve ser informado '
          next field cgccpfnumdig
       end if

    before field cgccpford
       display mr_ctc10m00.cgccpford  to cgccpford  attribute (reverse)

    after field cgccpford
       display mr_ctc10m00.cgccpford  to cgccpford

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field cgccpfnumdig
       end if

       if mr_ctc10m00.cgccpford is null or
          mr_ctc10m00.cgccpford = 0     then
          error 'Ordem do CNPJ deve ser informada '
          next field cgccpford
       end if

    before field cgccpfdig
       display mr_ctc10m00.cgccpfdig to cgccpfdig  attribute (reverse)

    after field cgccpfdig
       display mr_ctc10m00.cgccpfdig  to cgccpfdig

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field cgccpford
       end if

       if mr_ctc10m00.cgccpfdig is null or
          mr_ctc10m00.cgccpfdig = 0     then
          error 'Digito do CNPJ deve ser informadO '
          next field cgccpfdig
       end if

       let l_cgccpfdig = f_fundigit_digitocgc(mr_ctc10m00.cgccpfnumdig ,mr_ctc10m00.cgccpford )

       if l_cgccpfdig <> mr_ctc10m00.cgccpfdig then
          error 'CNPJ Invalido'
          next field cgccpfnumdig
       end if

    before field fonnum
       display mr_ctc10m00.fonnum to fonnum attribute (reverse)

    after field fonnum
       display mr_ctc10m00.fonnum  to fonnum

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field cgccpfdig
       end if

       if mr_ctc10m00.fonnum is null or
          mr_ctc10m00.fonnum = ' '   then
          error 'Telefone deve ser informado '
          next field fonnum
       end if

    before field faxnum
       display mr_ctc10m00.faxnum to faxnum  attribute (reverse)

    after field faxnum
       display mr_ctc10m00.faxnum to faxnum

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field fonnum
       end if

       if mr_ctc10m00.faxnum is null or
          mr_ctc10m00.faxnum = ' '   then
          error 'Fax deve ser informado '
          next field faxnum
       end if

    before field enddes
       display mr_ctc10m00.enddes to enddes attribute (reverse)

    after field enddes
       display mr_ctc10m00.enddes to enddes

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field faxnum
       end if

       if mr_ctc10m00.enddes is null or
          mr_ctc10m00.enddes = ' '   then
          error 'Endereco deve ser informado '
          next field enddes
       end if

    before field endbrr
       display mr_ctc10m00.endbrr to endbrr  attribute (reverse)

    after field endbrr
       display mr_ctc10m00.endbrr to endbrr

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field enddes
       end if

       if mr_ctc10m00.endbrr is null or
          mr_ctc10m00.endbrr = ' '   then
          error 'Bairro deve ser informado '
          next field endbrr
       end if

    before field cidnom
       display mr_ctc10m00.cidnom to cidnom attribute (reverse)

    after field cidnom
       display mr_ctc10m00.cidnom to cidnom

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field endbrr
       end if

    before field ufdcod
       display mr_ctc10m00.ufdcod to ufdcod attribute (reverse)

    after field ufdcod
       display mr_ctc10m00.ufdcod to ufdcod

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field cidnom
       end if

       if (mr_ctc10m00.ufdcod is not null and mr_ctc10m00.ufdcod <> '  ') and
          (mr_ctc10m00.cidnom is not null and mr_ctc10m00.cidnom <> '  ') then
           call cty10g00_obter_cidcod(mr_ctc10m00.cidnom, mr_ctc10m00.ufdcod)
                returning l_resultado
                         ,l_mensagem
                         ,mr_ctc10m00.cidcod

      end if

      if l_resultado <> 0 or mr_ctc10m00.cidnom is null then

          call cts06g04(mr_ctc10m00.cidnom, mr_ctc10m00.ufdcod )
             returning mr_ctc10m00.cidcod
                      ,mr_ctc10m00.cidnom
                      ,mr_ctc10m00.ufdcod

          if mr_ctc10m00.cidnom is null then
             error 'Cidade deve ser informada '
             next field cidnom
          end if

       end if

    before field aerpsgrsrflg
       display mr_ctc10m00.aerpsgrsrflg to aerpsgrsrflg attribute (reverse)

    after field aerpsgrsrflg
       display mr_ctc10m00.aerpsgrsrflg to aerpsgrsrflg

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field ufdcod
       end if

       if mr_ctc10m00.aerpsgrsrflg is null or
         (mr_ctc10m00.aerpsgrsrflg <> 'N'  and
          mr_ctc10m00.aerpsgrsrflg <> 'S') then
          error 'Digite "S" ou "N" '
          next field aerpsgrsrflg
       end if

    before field aerpsgemsflg
       display mr_ctc10m00.aerpsgemsflg to aerpsgemsflg  attribute (reverse)

    after field aerpsgemsflg
       display mr_ctc10m00.aerpsgemsflg to aerpsgemsflg

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field aerpsgrsrflg
       end if

       if mr_ctc10m00.aerpsgemsflg is null or
         (mr_ctc10m00.aerpsgemsflg <> 'N'  and
          mr_ctc10m00.aerpsgemsflg <> 'S') then
          error 'Digite "S" ou "N" '
          next field aerpsgemsflg
       end if

    before field aercmpsit
       display mr_ctc10m00.aercmpsit to aercmpsit attribute (reverse)

    after field aercmpsit
       display mr_ctc10m00.aercmpsit to aercmpsit

       if fgl_lastkey() = fgl_keyval('left') or
          fgl_lastkey() = fgl_keyval('up' )  then
          next field aerpsgemsflg
       end if

       if mr_ctc10m00.aercmpsit is null or
         (mr_ctc10m00.aercmpsit <> 'A'  and
          mr_ctc10m00.aercmpsit <> 'C') then
          error 'Digite "A" ou "C" '
          next field aercmpsit
       end if

       call cty08g00_nome_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)
            returning m_resultado ,m_lixo , m_funnom  

       let mr_ctc10m00.atldat = today
       let mr_ctc10m00.atlhor  = current
       let m_atlhor  = extend(mr_ctc10m00.atlhor, hour to minute) 

       display by name mr_ctc10m00.atldat
       display by name g_issk.funmat
       display m_funnom to funnom 
       display m_atlhor to atlhor 

       if l_opcao = 'I' then
          let l_retorno = ctc10m00_inclui()
       else
          if l_opcao = 'M' then
             let l_retorno = ctc10m00_modifica()
          end if
       end if

       if l_retorno = false then
          let int_flag = true
          exit input
       end if

    on key (control-c, f17, interrupt)
       exit input

 end input

 if int_flag  then
    initialize mr_ctc10m00 to null
    clear form
    let int_flag = false
 end if

end function

#-------------------------
function ctc10m00_inclui()
#-------------------------
 define l_erro smallint

 let l_erro = true

 open cctc10m00007
 whenever error continue
 fetch cctc10m00007 into mr_ctc10m00.aerciacod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error 'Erro SELECT cctc10m00007 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] 
    error 'CTC10M00 / ctc10m00_inclui() ' 
    let l_erro = false
 else
    if mr_ctc10m00.aerciacod is null then
       let mr_ctc10m00.aerciacod = 0
    end if

    let mr_ctc10m00.aerciacod = mr_ctc10m00.aerciacod + 1

    whenever error continue
    execute pctc10m00002 using mr_ctc10m00.aerciacod
                              ,mr_ctc10m00.aercianom
                              ,mr_ctc10m00.cgccpfnumdig
                              ,mr_ctc10m00.cgccpford
                              ,mr_ctc10m00.cgccpfdig
                              ,mr_ctc10m00.fonnum
                              ,mr_ctc10m00.faxnum
                              ,mr_ctc10m00.enddes
                              ,mr_ctc10m00.endbrr
                              ,mr_ctc10m00.cidcod
                              ,mr_ctc10m00.aerpsgrsrflg
                              ,mr_ctc10m00.aerpsgemsflg
                              ,mr_ctc10m00.aercmpsit
                              ,g_issk.usrtip
                              ,g_issk.empcod
                              ,g_issk.funmat
    whenever error stop
    if sqlca.sqlcode = 0 then
       error 'Inclusao efetuada com sucesso '  
    else
       error 'Erro INSERT pctc10m00002 / ', sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] 
       error 'CTC10M00  / ctc10m00_inclui() / ',mr_ctc10m00.aerciacod,    ' / '
                                               ,mr_ctc10m00.aercianom,    ' / '
                                               ,mr_ctc10m00.cgccpfnumdig, ' / '
                                               ,mr_ctc10m00.cgccpford,    ' / '
                                               ,mr_ctc10m00.cgccpfdig,    ' / '
                                               ,mr_ctc10m00.fonnum,       ' / '
                                               ,mr_ctc10m00.faxnum,       ' / '
                                               ,mr_ctc10m00.enddes,       ' / '
                                               ,mr_ctc10m00.endbrr,       ' / '
                                               ,mr_ctc10m00.cidcod,       ' / '
                                               ,mr_ctc10m00.aerpsgrsrflg, ' / '
                                               ,mr_ctc10m00.aerpsgemsflg, ' / '
                                               ,mr_ctc10m00.aercmpsit,    ' / '
                                               ,g_issk.usrtip,            ' / '
                                               ,g_issk.empcod,            ' / '
                                               ,g_issk.funmat     

       let l_erro = false
    end if
 end if

 return l_erro

end function

#---------------------------
function ctc10m00_modifica()
#---------------------------
 define l_erro smallint

 let l_erro = true

 whenever error continue
 execute pctc10m00003 using mr_ctc10m00.aercianom
                           ,mr_ctc10m00.cgccpfnumdig
                           ,mr_ctc10m00.cgccpford
                           ,mr_ctc10m00.cgccpfdig
                           ,mr_ctc10m00.fonnum
                           ,mr_ctc10m00.faxnum
                           ,mr_ctc10m00.enddes
                           ,mr_ctc10m00.endbrr
                           ,mr_ctc10m00.cidcod
                           ,mr_ctc10m00.aerpsgrsrflg
                           ,mr_ctc10m00.aerpsgemsflg
                           ,mr_ctc10m00.aercmpsit
                           ,g_issk.usrtip
                           ,g_issk.empcod
                           ,g_issk.funmat
                           ,mr_ctc10m00.aerciacod
 whenever error stop
 if sqlca.sqlcode = 0 then
   error 'Modificacao efetuada com sucesso' 
 else
   error 'Erro UPDATA pctc10m00003 / ', sqlca.sqlcode, ' / ',sqlca.sqlerrd[2] 
   error 'CTC10M00  / ctc10m00_modifica() / ', mr_ctc10m00.aerciacod 
   let l_erro = false
 end if

 return l_erro

end function

#------------------------------------------
function ctc10m00_proximo_anterior(l_opcao)
#------------------------------------------
define l_opcao char(001)

define lr_ctc10m00 record
                   aerciacod     like datkciaaer.aerciacod
                  ,aercianom     like datkciaaer.aercianom
                  ,cgccpfnumdig  like datkciaaer.cgccpfnumdig
                  ,cgccpford     like datkciaaer.cgccpford
                  ,cgccpfdig     like datkciaaer.cgccpfdig
                  ,fonnum        like datkciaaer.fonnum
                  ,faxnum        like datkciaaer.faxnum
                  ,enddes        like datkciaaer.enddes
                  ,endbrr        like datkciaaer.endbrr
                  ,cidcod        like datkciaaer.cidcod
                  ,cidnom        like glakcid.cidnom
                  ,ufdcod        like glakcid.ufdcod
                  ,aerpsgrsrflg  like datkciaaer.aerpsgrsrflg
                  ,aerpsgemsflg  like datkciaaer.aerpsgemsflg
                  ,aercmpsit     like datkciaaer.aercmpsit
                  ,atldat        like datkciaaer.atldat
                  ,atlhor        like datkciaaer.atlhor
                  ,atlmat        like datkciaaer.atlmat
                  ,atlemp        like datkciaaer.atlemp
                  ,funnom        like isskfunc.funnom
               end record


 if l_opcao = 'P' then
    open cctc10m00005 using mr_ctc10m00.aerciacod

    whenever error continue
    fetch cctc10m00005 into lr_ctc10m00.aerciacod
                           ,lr_ctc10m00.aercianom
                           ,lr_ctc10m00.cgccpfnumdig
                           ,lr_ctc10m00.cgccpford
                           ,lr_ctc10m00.cgccpfdig
                           ,lr_ctc10m00.fonnum
                           ,lr_ctc10m00.faxnum
                           ,lr_ctc10m00.enddes
                           ,lr_ctc10m00.endbrr
                           ,lr_ctc10m00.cidcod
                           ,lr_ctc10m00.aerpsgrsrflg
                           ,lr_ctc10m00.aerpsgemsflg
                           ,lr_ctc10m00.aercmpsit
                           ,lr_ctc10m00.atldat
                           ,lr_ctc10m00.atlhor
                           ,lr_ctc10m00.atlmat
                           ,lr_ctc10m00.atlemp
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          error 'Nao ha registro posterior'
       else
          error 'Erro SELECT cctc10m00005 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] 
          error 'CTC10M00 / ctc10m00_proximo_anterior() / ', mr_ctc10m00.aerciacod 
       end if
       return
    end if
 else
    open cctc10m00006 using mr_ctc10m00.aerciacod

    whenever error continue
    fetch cctc10m00006 into lr_ctc10m00.aerciacod
                           ,lr_ctc10m00.aercianom
                           ,lr_ctc10m00.cgccpfnumdig
                           ,lr_ctc10m00.cgccpford
                           ,lr_ctc10m00.cgccpfdig
                           ,lr_ctc10m00.fonnum
                           ,lr_ctc10m00.faxnum
                           ,lr_ctc10m00.enddes
                           ,lr_ctc10m00.endbrr
                           ,lr_ctc10m00.cidcod
                           ,lr_ctc10m00.aerpsgrsrflg
                           ,lr_ctc10m00.aerpsgemsflg
                           ,lr_ctc10m00.aercmpsit
                           ,lr_ctc10m00.atldat
                           ,lr_ctc10m00.atlhor
                           ,lr_ctc10m00.atlmat
                           ,lr_ctc10m00.atlemp
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          error 'Nao ha registro anterior'
       else
          error 'Erro SELECT cctc10m00006 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] 
          error 'CTC10M00 / ctc10m00_proximo_anterior() / ', mr_ctc10m00.aerciacod 
       end if
       return
    end if
 end if

 call cty08g00_nome_func(g_issk.empcod, g_issk.funmat, g_issk.usrtip)
    returning m_resultado
             ,m_lixo
             ,lr_ctc10m00.funnom

 open cctc10m00004 using lr_ctc10m00.cidcod

 whenever error continue
 fetch cctc10m00004 into lr_ctc10m00.cidnom
                        ,lr_ctc10m00.ufdcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
   if sqlca.sqlcode = notfound then
     let lr_ctc10m00.cidnom = null
     let lr_ctc10m00.ufdcod = null
   else
     error 'Erro SELECT cctc10m00004 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2] 
     error 'CTC10M00 / ctc10m00_mostra() / ', lr_ctc10m00.cidcod 
     return
   end if
 end if

 let mr_ctc10m00.aerciacod     = lr_ctc10m00.aerciacod
 let mr_ctc10m00.aercianom     = lr_ctc10m00.aercianom
 let mr_ctc10m00.cgccpfnumdig  = lr_ctc10m00.cgccpfnumdig
 let mr_ctc10m00.cgccpford     = lr_ctc10m00.cgccpford
 let mr_ctc10m00.cgccpfdig     = lr_ctc10m00.cgccpfdig
 let mr_ctc10m00.fonnum        = lr_ctc10m00.fonnum
 let mr_ctc10m00.faxnum        = lr_ctc10m00.faxnum
 let mr_ctc10m00.enddes        = lr_ctc10m00.enddes
 let mr_ctc10m00.endbrr        = lr_ctc10m00.endbrr
 let mr_ctc10m00.cidcod        = lr_ctc10m00.cidcod
 let mr_ctc10m00.aerpsgrsrflg  = lr_ctc10m00.aerpsgrsrflg
 let mr_ctc10m00.aerpsgemsflg  = lr_ctc10m00.aerpsgemsflg
 let mr_ctc10m00.aercmpsit     = lr_ctc10m00.aercmpsit
 let mr_ctc10m00.atldat        = lr_ctc10m00.atldat
 let mr_ctc10m00.atlhor        = lr_ctc10m00.atlhor
 let mr_ctc10m00.funmat        = lr_ctc10m00.atlmat
 let mr_ctc10m00.atlemp        = lr_ctc10m00.atlemp
 let mr_ctc10m00.funnom        = lr_ctc10m00.funnom
 let mr_ctc10m00.cidnom        = lr_ctc10m00.cidnom
 let mr_ctc10m00.ufdcod        = lr_ctc10m00.ufdcod

 call ctc10m00_mostra()

end function

#-------------------------
function ctc10m00_mostra()
#-------------------------

 let m_atlhor = extend(mr_ctc10m00.atlhor, hour to minute)

 display by name  mr_ctc10m00.aerciacod
                 ,mr_ctc10m00.aercianom
                 ,mr_ctc10m00.cgccpfnumdig
                 ,mr_ctc10m00.cgccpford
                 ,mr_ctc10m00.cgccpfdig
                 ,mr_ctc10m00.fonnum
                 ,mr_ctc10m00.faxnum
                 ,mr_ctc10m00.enddes
                 ,mr_ctc10m00.endbrr
                 ,mr_ctc10m00.cidnom
                 ,mr_ctc10m00.ufdcod
                 ,mr_ctc10m00.aerpsgrsrflg
                 ,mr_ctc10m00.aerpsgemsflg
                 ,mr_ctc10m00.aercmpsit
                 ,mr_ctc10m00.atldat
                 ,mr_ctc10m00.funmat
                 ,mr_ctc10m00.funnom

 display m_atlhor to atlhor

end function
