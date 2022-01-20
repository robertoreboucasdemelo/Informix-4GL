#############################################################################
# Nome do Modulo: CTC14M01                                          Marcelo #
#                                                                  Gilberto #
# Cadastro de codigos de assunto                                   Mar/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL    DESCRICAO                         #
#---------------------------------------------------------------------------#
# 04/06/1999  PSI 6962-0   Wagner         Permitir a digitacao do texto     #
#                                         livre adicional para pager.       #
#---------------------------------------------------------------------------#
# 12/02/2001  PSI 11254-2  Ruiz           Inclusao da flag para condutor.   #
#---------------------------------------------------------------------------#
#                      * * * Alteracoes * * *                               #
#                                                                           #
# Data        Autor Fabrica Origem     Alteracao                            #
# ----------  ------------- ---------- ------------------------------------ #
# 12/12/2003  Paulo, Meta   PSI180475  1) Incluir o campo Obriga Motivo     #
#                           OSF 30228  2) Inserir o campo rcuccsmtvobrflg   #
#                                         no "insert", "update" e "select"  #
#                                         da tabela "datkassunto".          #
#---------------------------------------------------------------------------#
# 05/01/2004  OSF 30554 - Leandro(FSW) Atualizar telefone/email do segurado #
#                                      conforme o cadastro de assuntos.     #
#---------------------------------------------------------------------------#
# 13/01/2004 Ivone, Meta   PSI180475   Corrigir a navegacao entre os campos #
#                          OSF 30228   da tela                              #
#---------------------------------------------------------------------------#
# 25/05/2004 Teresinha S.  PSI1844667  Inclusao do campo MSg e-mail         #
#                          OSF 35998                                        #
#---------------------------------------------------------------------------#
# 15/03/2005 Adriana, Meta PSI188751   Inclusao do campo RIS (risprcflg)    #
#                                      no "insert", "update" e "select"     #
#                                      da tabela "datkassunto".             #
#---------------------------------------------------------------------------#
# 23/01/2006 Andrei, Meta  PSI196541   Incluir campo webrlzflg na funcao    #
#                                      ctc14m01_input().                    #
#---------------------------------------------------------------------------#
# 12/04/2006 Priscila      PSI 198714  Incluir campo atmacnflg              #
#---------------------------------------------------------------------------#
# 25/09/2006 Priscila      PSI202290   Remover verificacao nivel de acesso  #
#---------------------------------------------------------------------------#
# 13/06/2013 Fornax        PSI-2013-06224/PR                                #
#            Tecnologia                Identificacao no Acionamento do Laudo#
#                                      SAPS (Inclusao do campo MensagemMDT).#
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc012.4gl"


   define m_prep_sql      smallint

#------------------------------------------------------------
 function ctc14m01_prepara()
#------------------------------------------------------------
 define l_sql      char(5000)

 let l_sql = ' update datkassunto set (c24astdes, c24astexbflg,             ',
             '                         c24asttltflg,c24astatdflg,           ',
             '                         cndslcflg,prgcod,c24atrflg,          ',
             '                         c24jstflg, c24aststt, c24astpgrtxt,  ',
             '                         atldat, atlmat, rcuccsmtvobrflg,     ',
             '                         telmaiatlflg,maimsgenvflg,risprcflg, ',
             '                         webrlzflg, atmacnflg, itaasstipcod)  ',
             '         = ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?)',
             'where c24astcod = ? '
 prepare pctc14m01001 from l_sql

 let l_sql = ' update datmmdtmsg24h ' #--> PSI-2013-06224/PR
           , '    set mdtmsgtxt = ? '
           , '  where c24astcod = ? '
 prepare pctc14m01001b from l_sql

 let l_sql = ' delete from datmmdtmsg24h ' #--> PSI-2013-06224/PR
           , '  where c24astcod = ?      '
 prepare pctc14m01001c from l_sql

 let l_sql = ' insert into datkassunto '
           , ' ( c24astagp   , c24astcod   , c24astdes, c24astexbflg '
           , ' , c24asttltflg, c24astatdflg, cndslcflg, prgcod       '
           , ' , c24atrflg   , c24jstflg   , c24aststt, c24astsincod '
           , ' , c24astpgrtxt, caddat      , cadmat   , atldat       '
           , ' , atlmat      , rcuccsmtvobrflg, telmaiatlflg,maimsgenvflg '
           , ' , risprcflg, webrlzflg, atmacnflg, itaasstipcod)           '
           , 'values (?,?,?,?,?,?,?,?,?,?,?,1,?,?,?,?,?,?,?,?,?, ?,?,?)   '
 prepare pctc14m01002 from l_sql

 let l_sql = ' insert into datmmdtmsg24h ' #--> PSI-2013-06224/PR
           , ' ( c24astcod , mdtmsgtxt ) '
           , ' values ( ? , ? )          '
 prepare pctc14m01002b from l_sql

 let l_sql = ' select c24astcod, c24astdes, c24astexbflg, c24asttltflg, ',
             '        c24astatdflg,cndslcflg,prgcod,c24atrflg,c24jstflg,',
             '        c24aststt, c24astpgrtxt,caddat,cadmat,atldat,atlmat,',
             '        rcuccsmtvobrflg, telmaiatlflg , ',
             '        maimsgenvflg ,', -- OSF 35998
             '        risprcflg, webrlzflg, atmacnflg , itaasstipcod '
             ,'  from  datkassunto '
             ,' where  c24astcod = ? '
             ,'   and  c24astagp = ? '
 prepare pctc14m01003 from l_sql
 declare cctc14m01003 cursor for pctc14m01003

 let l_sql = ' select mdtmsgtxt     ' #--> PSI-2013-06224/PR
           , '   from datmmdtmsg24h '
           , '  where c24astcod = ? '
 prepare pctc14m01003b from l_sql
 declare cctc14m01003b cursor for pctc14m01003b

 let l_sql =  '  SELECT itaasiplntipcod       '
             ,'       , itaasiplntipdes       '
             ,'    FROM datkasttip      '
             ,'  WHERE itaasiplntipcod IN (1,2,3,4,9)' # Apenas INFORMACAO, SERVICO, CORTESIA e RECLAMACAO/ELOGIO
             ,'  ORDER BY itaasiplntipcod     '
 prepare pctc14m01004 from l_sql
 declare cctc14m01004 cursor for pctc14m01004

 let l_sql =  '  SELECT itaasiplntipdes     '
             ,'    FROM datkasttip          '
             ,'  WHERE itaasiplntipcod = ?  '
 prepare pctc14m01005 from l_sql
 declare cctc14m01005 cursor for pctc14m01005

 end function

#------------------------------------------------------------
 function ctc14m01(param)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkastagp.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes
 end record

 define ctc14m01      record
    c24astcod         like datkassunto.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24astexbflg      like datkassunto.c24astexbflg,
    c24asttltflg      like datkassunto.c24asttltflg,
    c24astatdflg      like datkassunto.c24astatdflg,
    cndslcflg         like datkassunto.cndslcflg,
    prgcod            like datkassunto.prgcod,
    prgdes            char (100),
    c24atrflg         like datkassunto.c24atrflg,
    c24jstflg         like datkassunto.c24jstflg,
    rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,                 ### PSI180475 - Paulo
    telmaiatlflg      like datkassunto.telmaiatlflg,
    c24aststt         like datkassunto.c24aststt,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    funnom            like isskfunc.funnom,
    restricao         char (40),
    txtdes            char (18),
    maimsgenvflg      char(01), -- OSF 35998
    risprcflg         like datkassunto.risprcflg,
    webrlzflg         like datkassunto.webrlzflg,
    atmacnflg         like datkassunto.atmacnflg,
    tip_c24ast        like datkassunto.itaasstipcod,
    mdtmsgtxt         like datmmdtmsg24h.mdtmsgtxt, #--> PSI-2013-06224/PR
    c24astpgrtxt      char (200)
 end record

## PSI 180475 - Inicio

 if m_prep_sql is null or m_prep_sql <> true then
    call ctc14m01_prepara()
 end if

## PSI 180475 - Final

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc14m01") then
 #   error "Modulo sem nivel de consulta e atualizacao"
 #   return
 #end if

 let int_flag = false

 initialize ctc14m01.*  to null

 open window ctc14m01 at 04,02 with form "ctc14m01"

 display by name param.c24astagp     attribute(reverse)
 display by name param.c24astagpdes  attribute(reverse)


 menu "ASSUNTOS"

 before menu
          hide option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior"
          #end if

          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica" , "Inclui", "TeXto"
          #end if
          #if  g_issk.acsnivcod >= 8                 then
              show option "Ramos", "maTriculas","Clausulas"
          #end if

          show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa assunto conforme criterios"
          call ctc14m01_seleciona(param.c24astagp)  returning ctc14m01.*
          if ctc14m01.c24astcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum assunto selecionado"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo assunto selecionado"
          message ""
          call ctc14m01_proximo(param.c24astagp, ctc14m01.c24astcod)
               returning ctc14m01.*

 command key ("A") "Anterior"
                   "Mostra assunto anterior selecionado"
          message ""
          if ctc14m01.c24astcod is not null then
             call ctc14m01_anterior(param.c24astagp, ctc14m01.c24astcod)
                  returning ctc14m01.*
          else
             error " Nenhum assunto nesta direcao"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica assunto corrente selecionado"
          message ""
          if ctc14m01.c24astcod  is not null then
             call ctc14m01_modifica(param.c24astagp, ctc14m01.*)
                  returning ctc14m01.*
             next option "Seleciona"
          else
             error " Nenhum assunto selecionado"
             next option "Seleciona"
          end if

 command key ("R") "Ramos"
                   "Ramos aceitos ou nao para assunto selecionado"
          message ""
          if ctc14m01.c24astcod is not null then
             call ctc14m04(ctc14m01.c24astcod,
                           param.c24astagpdes,
                           ctc14m01.c24astdes)

             call ctc14m01_ler(param.c24astagp, ctc14m01.c24astcod)
                  returning ctc14m01.*

             display by name ctc14m01.c24astcod thru ctc14m01.webrlzflg

          else
             error " Nenhum assunto nesta selecionado"
             next option "Seleciona"
          end if

 command key ("T") "maTriculas"
                   "Matriculas com permissao para liberar assunto selecionado"
          message ""
          if ctc14m01.c24astcod is not null then
             call ctc14m05(ctc14m01.c24astcod,
                           param.c24astagpdes,
                           ctc14m01.c24astdes,
                           g_issk.sissgl)

             call ctc14m01_ler(param.c24astagp, ctc14m01.c24astcod)
                  returning ctc14m01.*

             display by name ctc14m01.c24astcod thru ctc14m01.webrlzflg

          else
             error " Nenhum assunto nesta selecionado"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui assunto"
          message ""
          call ctc14m01_inclui(param.c24astagp,
                               param.c24astagpdes)
          next option "Seleciona"

 command key ("X") "TeXto"
                   "Texto para assunto"
          message ""
          if ctc14m01.c24astcod is not null then
             call ctc58m00(ctc14m01.c24astcod)

             call ctc14m01_ler(param.c24astagp, ctc14m01.c24astcod)
                  returning ctc14m01.*

             display by name ctc14m01.c24astcod thru ctc14m01.webrlzflg

          else
             error " Nenhum assunto nesta selecionado"
             next option "Seleciona"
          end if
          next option "Seleciona"

 command key ("C") "Clausulas"
                   "Clausulas para assunto"
          message ""

       if ctc14m01.c24astcod is not null then
          call ctc14m07(ctc14m01.c24astcod,
                        param.c24astagpdes,
                        ctc14m01.c24astdes)

          call ctc14m01_ler(param.c24astagp, ctc14m01.c24astcod)
               returning ctc14m01.*
          display by name ctc14m01.c24astcod thru ctc14m01.webrlzflg

       else
          error " Nenhum assunto nesta selecionado"
          next option "Seleciona"
       end if


 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc14m01

 end function  # ctc14m01


#------------------------------------------------------------
 function ctc14m01_seleciona(param)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkassunto.c24astagp
 end record

 define ctc14m01      record
    c24astcod         like datkassunto.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24astexbflg      like datkassunto.c24astexbflg,
    c24asttltflg      like datkassunto.c24asttltflg,
    c24astatdflg      like datkassunto.c24astatdflg,
    cndslcflg         like datkassunto.cndslcflg,
    prgcod            like datkassunto.prgcod,
    prgdes            char (100),
    c24atrflg         like datkassunto.c24atrflg,
    c24jstflg         like datkassunto.c24jstflg,
    rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,                 ### PSI180475 - Paulo
    telmaiatlflg      like datkassunto.telmaiatlflg   ,
    c24aststt         like datkassunto.c24aststt,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    funnom            like isskfunc.funnom,
    restricao         char (40),
    txtdes            char (18),
    maimsgenvflg      char(01), -- OSF 35998
    risprcflg         like datkassunto.risprcflg,
    webrlzflg         like datkassunto.webrlzflg,
    atmacnflg         like datkassunto.atmacnflg,
    tip_c24ast        like datkassunto.itaasstipcod,
    mdtmsgtxt         like datmmdtmsg24h.mdtmsgtxt, #--> PSI-2013-06224/PR
    c24astpgrtxt      char (200)
 end record

 define ws            record
    c24astagp         like datkassunto.c24astagp
 end record

 define tip_c24astdes     like datkasttip.itaasiplntipdes

 let tip_c24astdes = ''
 let int_flag = false
 initialize ctc14m01.*  to null
 initialize ws.*        to null

 display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

 whenever error continue
  open cctc14m01005 using ctc14m01.tip_c24ast
  fetch cctc14m01005 into tip_c24astdes
 whenever error stop

 display by name  tip_c24astdes

 input by name ctc14m01.c24astcod

    before field c24astcod
        display by name ctc14m01.c24astcod attribute (reverse)

    after  field c24astcod
        display by name ctc14m01.c24astcod

        if ctc14m01.c24astcod  is null  then
           error " Codigo de assunto deve ser informado"
           next field c24astcod
        end if

        select datkassunto.c24astagp
          into ws.c24astagp
          from datkassunto
         where datkassunto.c24astcod = ctc14m01.c24astcod

        if sqlca.sqlcode  =  notfound   then
           error " Codigo de assunto nao cadastrado"
           next field c24astcod
        end if

        if param.c24astagp  <>  ws.c24astagp   then
           error " Codigo de assunto nao pertence a este agrupamento"
           next field c24astcod
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc14m01.*   to null

    display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

    whenever error continue
      open cctc14m01005 using ctc14m01.tip_c24ast
      fetch cctc14m01005 into tip_c24astdes
    whenever error stop

    display by name  tip_c24astdes
    error " Operacao cancelada"
    return ctc14m01.*
 end if

 call ctc14m01_ler(param.c24astagp, ctc14m01.c24astcod)
      returning ctc14m01.*

 if ctc14m01.c24astcod  is not null   then

    display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

    whenever error continue
      open cctc14m01005 using ctc14m01.tip_c24ast
      fetch cctc14m01005 into tip_c24astdes
    whenever error stop

    display by name  tip_c24astdes
 else
    error " Assunto nao cadastrado"
    initialize ctc14m01.*    to null
 end if

 return ctc14m01.*

 end function  # ctc14m01_seleciona


#------------------------------------------------------------
 function ctc14m01_proximo(param)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkassunto.c24astagp,
    c24astcod         like datkassunto.c24astcod
 end record

 define ctc14m01      record
    c24astcod         like datkassunto.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24astexbflg      like datkassunto.c24astexbflg,
    c24asttltflg      like datkassunto.c24asttltflg,
    c24astatdflg      like datkassunto.c24astatdflg,
    cndslcflg         like datkassunto.cndslcflg,
    prgcod            like datkassunto.prgcod,
    prgdes            char (100),
    c24atrflg         like datkassunto.c24atrflg,
    c24jstflg         like datkassunto.c24jstflg,
    rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,          ### PSI180475 - Paulo
    telmaiatlflg      like datkassunto.telmaiatlflg   ,
    c24aststt         like datkassunto.c24aststt,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    funnom            like isskfunc.funnom,
    restricao         char (40),
    txtdes            char (18),
    maimsgenvflg      char(01), -- OSF 35998
    risprcflg         like datkassunto.risprcflg,
    webrlzflg         like datkassunto.webrlzflg,
    atmacnflg         like datkassunto.atmacnflg,
    tip_c24ast        like datkassunto.itaasstipcod,
    mdtmsgtxt         like datmmdtmsg24h.mdtmsgtxt, #--> PSI-2013-06224/PR
    c24astpgrtxt      char (200)
 end record

 define tip_c24astdes     like datkasttip.itaasiplntipdes

 let tip_c24astdes = ''
 let int_flag = false
 initialize ctc14m01.*   to null

 if param.c24astcod  is null  then
    let param.c24astcod = " "
 end if

 select min(datkassunto.c24astcod)
   into ctc14m01.c24astcod
   from datkassunto
  where datkassunto.c24astcod > param.c24astcod
    and datkassunto.c24astagp = param.c24astagp

 if ctc14m01.c24astcod  is not null   then

    call ctc14m01_ler(param.c24astagp, ctc14m01.c24astcod)
         returning ctc14m01.*

    if ctc14m01.c24astcod  is not null   then

       display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

       whenever error continue
         open cctc14m01005 using ctc14m01.tip_c24ast
         fetch cctc14m01005 into tip_c24astdes
       whenever error stop

       display by name  tip_c24astdes
    else
       error " Nao ha' assunto nesta direcao"
       initialize ctc14m01.*    to null
    end if
 else
    error " Nao ha' assunto nesta direcao"
    initialize ctc14m01.*    to null
 end if

 return ctc14m01.*

 end function    # ctc14m01_proximo


#------------------------------------------------------------
 function ctc14m01_anterior(param)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkassunto.c24astagp,
    c24astcod         like datkassunto.c24astcod
 end record

 define ctc14m01      record
    c24astcod         like datkassunto.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24astexbflg      like datkassunto.c24astexbflg,
    c24asttltflg      like datkassunto.c24asttltflg,
    c24astatdflg      like datkassunto.c24astatdflg,
    cndslcflg         like datkassunto.cndslcflg,
    prgcod            like datkassunto.prgcod,
    prgdes            char (100),
    c24atrflg         like datkassunto.c24atrflg,
    c24jstflg         like datkassunto.c24jstflg,
    rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,          ### PSI180475 - Paulo
    telmaiatlflg      like datkassunto.telmaiatlflg   ,
    c24aststt         like datkassunto.c24aststt,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    funnom            like isskfunc.funnom,
    restricao         char (40),
    txtdes            char (18),
    maimsgenvflg      char(01),-- OSF 35998
    risprcflg         like datkassunto.risprcflg,
    webrlzflg         like datkassunto.webrlzflg,
    atmacnflg         like datkassunto.atmacnflg,
    tip_c24ast        like datkassunto.itaasstipcod,
    mdtmsgtxt         like datmmdtmsg24h.mdtmsgtxt, #--> PSI-2013-06224/PR
    c24astpgrtxt      char (200)
 end record

 define tip_c24astdes     like datkasttip.itaasiplntipdes

 let tip_c24astdes = ''

 let int_flag = false
 initialize ctc14m01.*  to null

 if param.c24astcod  is null  then
    let param.c24astcod = " "
 end if

 select max(datkassunto.c24astcod)
   into ctc14m01.c24astcod
   from datkassunto
  where datkassunto.c24astcod < param.c24astcod
    and datkassunto.c24astagp = param.c24astagp

 if ctc14m01.c24astcod  is not null   then

    call ctc14m01_ler(param.c24astagp, ctc14m01.c24astcod)
         returning ctc14m01.*

    if ctc14m01.c24astcod  is not null   then

       display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

       whenever error continue
         open cctc14m01005 using ctc14m01.tip_c24ast
         fetch cctc14m01005 into tip_c24astdes
       whenever error stop

       display by name  tip_c24astdes

    else
       error " Nao ha' assunto nesta direcao"
       initialize ctc14m01.*    to null
    end if
 else
    error " Nao ha' assunto nesta direcao"
    initialize ctc14m01.*    to null
 end if

 return ctc14m01.*

 end function    # ctc14m01_anterior


#------------------------------------------------------------
 function ctc14m01_modifica(param, ctc14m01)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkassunto.c24astagp
 end record

 define l_Ok integer

 define ctc14m01      record
    c24astcod         like datkassunto.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24astexbflg      like datkassunto.c24astexbflg,
    c24asttltflg      like datkassunto.c24asttltflg,
    c24astatdflg      like datkassunto.c24astatdflg,
    cndslcflg         like datkassunto.cndslcflg,
    prgcod            like datkassunto.prgcod,
    prgdes            char (100),
    c24atrflg         like datkassunto.c24atrflg,
    c24jstflg         like datkassunto.c24jstflg,
    rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,                 ### PSI180475 - Paulo
    telmaiatlflg      like datkassunto.telmaiatlflg   ,
    c24aststt         like datkassunto.c24aststt,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    funnom            like isskfunc.funnom,
    restricao         char (40),
    txtdes            char (18),
    maimsgenvflg      char(01),-- OSF 35998
    risprcflg         like datkassunto.risprcflg,
    webrlzflg         like datkassunto.webrlzflg,
    atmacnflg         like datkassunto.atmacnflg,
    tip_c24ast        like datkassunto.itaasstipcod,
    mdtmsgtxt         like datmmdtmsg24h.mdtmsgtxt, #--> PSI-2013-06224/PR
    c24astpgrtxt      char (200)
 end record

 define l_webrlzflg     like datkassunto.webrlzflg
 define l_webrlzflg_ant like datkassunto.webrlzflg
 define l_assunto       like datkassunto.c24astcod
 define tip_c24astdes     like datkasttip.itaasiplntipdes

 let tip_c24astdes = ''

 select webrlzflg
   into l_webrlzflg_ant
   from datkassunto
  where c24astcod = ctc14m01.c24astcod


 initialize l_Ok to null

 call ctc14m01_input("a", param.c24astagp, ctc14m01.*) returning ctc14m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc14m01.*  to null

    display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

    whenever error continue
      open cctc14m01005 using ctc14m01.tip_c24ast
      fetch cctc14m01005 into tip_c24astdes
    whenever error stop

    display by name  tip_c24astdes
    error " Operacao cancelada"
    return ctc14m01.*
 end if

 let ctc14m01.atldat = today
 if ctc14m01.c24asttltflg = "N" then
    initialize ctc14m01.c24astpgrtxt to null
 end if

 ###
 ### Inicio PSI180475 - Paulo
 ###
 whenever error continue
 execute pctc14m01001 using ctc14m01.c24astdes
                           ,ctc14m01.c24astexbflg
                           ,ctc14m01.c24asttltflg
                           ,ctc14m01.c24astatdflg
                           ,ctc14m01.cndslcflg
                           ,ctc14m01.prgcod
                           ,ctc14m01.c24atrflg
                           ,ctc14m01.c24jstflg
                           ,ctc14m01.c24aststt
                           ,ctc14m01.c24astpgrtxt
                           ,ctc14m01.atldat
                           ,g_issk.funmat
                           ,ctc14m01.rcuccsmtvobrflg
                           ,ctc14m01.telmaiatlflg
                           ,ctc14m01.maimsgenvflg -- OSF 35998
                           ,ctc14m01.risprcflg
                           ,ctc14m01.webrlzflg
                           ,ctc14m01.atmacnflg
                           ,ctc14m01.tip_c24ast
                           ,ctc14m01.c24astcod


 whenever error stop

 if sqlca.sqlcode <>  0 then
    error 'Erro UPDATE pctc14m01001: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]   sleep 2
    error 'CTC14M01 / ctc14m01_modifica() / ',ctc14m01.c24astdes       ,' / '
                                             ,ctc14m01.c24astexbflg    ,' / '
                                             ,ctc14m01.c24asttltflg    ,' / '
                                             ,ctc14m01.c24astatdflg    ,' / '
                                             ,ctc14m01.cndslcflg       ,' / '
                                             ,ctc14m01.prgcod          ,' / '
                                             ,ctc14m01.c24atrflg       ,' / '
                                             ,ctc14m01.c24jstflg       ,' / '
                                             ,ctc14m01.c24aststt       ,' / '
                                             ,ctc14m01.c24astpgrtxt    ,' / '
                                             ,ctc14m01.atldat          ,' / '
                                             ,g_issk.funmat            ,' / '
                                             ,ctc14m01.rcuccsmtvobrflg ,' / '
                                             ,ctc14m01.telmaiatlflg    ,' / '
                                             ,ctc14m01.c24astcod              sleep 2

    initialize ctc14m01.*   to null
    return ctc14m01.*
 else

    #--> PSI-2013-06224/PR (inicio)

    if ctc14m01.mdtmsgtxt is not null and ctc14m01.mdtmsgtxt <> " " then
       whenever error continue
       execute pctc14m01001b using ctc14m01.mdtmsgtxt
                                  ,ctc14m01.c24astcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error 'Erro UPDATE pctc14m01001b: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[3]
          sleep 2
          error 'CTC14M01 / ctc14m01_modifica() / ',ctc14m01.c24astcod
                                             ,' / ',ctc14m01.mdtmsgtxt clipped
          sleep 2
          initialize ctc14m01.* to null
          return ctc14m01.*
       else
          if sqlca.sqlerrd[3] = 0 then
             whenever error continue
             execute pctc14m01002b using ctc14m01.c24astcod
                                        ,ctc14m01.mdtmsgtxt
             whenever error stop
             if sqlca.sqlcode <>  0 then
                error 'Erro INSERT pctc14m01002b: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
                sleep 2
                error 'CTC14M01 / ctc14m01_modifica() / ', ctc14m01.c24astcod
                                                   ,' / ', ctc14m01.mdtmsgtxt clipped
                sleep 2
                initialize ctc14m01.* to null
                return ctc14m01.*
             end if
          end if
       end if
    else
       whenever error continue
       execute pctc14m01001c using ctc14m01.c24astcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error 'Erro DELETE pctc14m01001c: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          sleep 2
          error 'CTC14M01 / ctc14m01_modifica() / ',ctc14m01.c24astcod
          sleep 2
          initialize ctc14m01.* to null
          return ctc14m01.*
       end if
    end if

    #--> PSI-2013-06224/PR (final)

    if not figrc012_sitename("ctc14m01","","") then
       display "ERRO NO ACESSO SITENAME DA DUAL!"
       exit program(1)
    end if

    #if g_outFigrc012.Is_Produc then

       let l_webrlzflg = ctc14m01.webrlzflg
       let l_assunto   = ctc14m01.c24astcod

       if l_assunto = "N10" or
          l_assunto = "N11" or
          l_assunto = "F10" or
          l_assunto = "U10" or
          l_assunto = "SIN" then
          if l_webrlzflg_ant <> l_webrlzflg then
             call ctc14m01_envia_email(l_webrlzflg, l_assunto)
             call ctc14m01_gera_arquivo(l_webrlzflg,l_assunto)
          end if

          let l_Ok = 0

          if l_assunto = "SIN" then
             call ctc14m01_ast_guincho(ctc14m01.c24aststt)
                  returning l_Ok
             if l_Ok = 0 then
                error " Erro na Chave N10/N11. Avise a Infiormatica! " sleep 3
             end if
          end if
       end if
    #end if

    error " Alteracao efetuada com sucesso"

 end if
 ###
 ### Final PSI180475 - Paulo
 ###

 initialize ctc14m01.*  to null

 display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

 whenever error continue
   open cctc14m01005 using ctc14m01.tip_c24ast
   fetch cctc14m01005 into tip_c24astdes
 whenever error stop

 display by name  tip_c24astdes

 message ""
 return ctc14m01.*

 end function   #  ctc14m01_modifica

 #---------------------------------------------------#
 function ctc14m01_gera_arquivo(l_webrlzflg,l_assunto)
 #---------------------------------------------------#

   define l_webrlzflg     like datkassunto.webrlzflg
   define l_assunto       like datkassunto.c24astcod
   define l_codigo        char(02)
   define l_arquivo       char(100)
   define l_diretorio     char(50)
   define l_cmd           char(200)
   define l_path          char(60)

   #let l_diretorio = 'u28:/projetos/saofrancisco/D0105050/pacp/'
   #let l_diretorio = 'u147:/home1/produc/geral/logs/'
   #let l_diretorio = 'u146:/home1/produc/geral/logs/'

   if not g_outFigrc012.Is_Teste then
      let l_diretorio = 'u147:/logs/asinistro/'
   else
     let l_diretorio = 'u28:/projetos/usuar/logs/'
   end if

   case l_assunto

      when "N10"

         if l_webrlzflg = "S" then
            let l_codigo = "00"
         else
            let l_codigo = "01"
         end if

         let l_arquivo = "ctc14m01.monitoramento.chavecentral.N10.cfg"

         # Remove o arquivo existente
         let l_cmd = 'rm -f ', l_arquivo
         run l_cmd

         start report chctlN10 to "ctc14m01.monitoramento.chavecentral.N10.cfg"

         output to report chctlN10(l_codigo)

         finish report chctlN10

         #Permissao
         let l_cmd = "chmod 777 ", l_arquivo clipped, ";" , l_arquivo clipped, ";"
         run l_cmd

         # Copia para a máquina definida no l_diretorio - FlexVision
         let l_cmd = 'rcp ', l_arquivo clipped, " ",l_diretorio  clipped,'.'
         run l_cmd


      when "N11"

         if l_webrlzflg = "S" then
            let l_codigo = "00"
         else
            let l_codigo = "01"
         end if

         let l_arquivo = "ctc14m01.monitoramento.chavecentral.N11.cfg"
         let l_cmd = 'rm -f ', l_arquivo
         run l_cmd

         start report chctlN11 to "ctc14m01.monitoramento.chavecentral.N11.cfg"

         output to report chctlN11(l_codigo)

         finish report chctlN11

         #Permissao
         let l_cmd = "chmod 777 ", l_arquivo clipped, ";" , l_arquivo clipped, ";"
         run l_cmd

         # Copia para a máquina definida no l_diretorio - FlexVision
         let l_cmd = 'rcp ', l_arquivo clipped, " ",l_diretorio  clipped,'.'
         run l_cmd

      when "F10"

         if l_webrlzflg = "S" then
            let l_codigo = "00"
         else
            let l_codigo = "01"
         end if

         let l_arquivo = "ctc14m01.monitoramento.chavecentral.F10.cfg"
         let l_cmd = 'rm -f ', l_arquivo
         run l_cmd

         start report chctlF10 to "ctc14m01.monitoramento.chavecentral.F10.cfg"

         output to report chctlF10(l_codigo)

         finish report chctlF10

         #Permissao
         let l_cmd = "chmod 777 ", l_arquivo clipped, ";" , l_arquivo clipped, ";"
         run l_cmd

         # Copia para a máquina definida no l_diretorio - FlexVision
         let l_cmd = 'rcp ', l_arquivo clipped, " ",l_diretorio  clipped,'.'
         run l_cmd
      when "U10"

         if l_webrlzflg = "S" then
            let l_codigo = "00"
         else
            let l_codigo = "01"
         end if

         let l_arquivo = "ctc14m01.monitoramento.chavecentral.U10.cfg"

         let l_cmd = 'rm -f ', l_arquivo
         run l_cmd

         start report chctlU10 to "ctc14m01.monitoramento.chavecentral.U10.cfg"

         output to report chctlU10(l_codigo)

         finish report chctlU10

         #Permissao
         let l_cmd = "chmod 777 ", l_arquivo clipped, ";" , l_arquivo clipped, ";"
         run l_cmd

         # Copia para a máquina definida no l_diretorio - FlexVision
         let l_cmd = 'rcp ', l_arquivo clipped, " ",l_diretorio  clipped,'.'
         run l_cmd

   end case


 end function

 #-------------------------#
 report chctlN10(l_codigo)
 #-------------------------#

   define l_codigo char(02)
   define l_data date
   define l_hora datetime hour to minute


  output
      page length    066
      left margin    000
      top  margin    000
      bottom margin  000
   format

   on every row
      print column 00,l_codigo
      #,"|"
      #,l_hora,"|"
      #,l_ok

 end report

 #-------------------------#
 report chctlN11(l_codigo)
 #-------------------------#

   define l_codigo char(02)
   define l_data date
   define l_hora datetime hour to minute


  output
      page length    066
      left margin    000
      top  margin    000
      bottom margin  000
   format

   on every row
      print column 00,l_codigo
      #,"|"
      #,l_hora,"|"
      #,l_ok

 end report

 #-------------------------#
 report chctlF10(l_codigo)
 #-------------------------#

   define l_codigo char(02)
   define l_data date
   define l_hora datetime hour to minute


  output
      page length    066
      left margin    000
      top  margin    000
      bottom margin  000
   format

   on every row
      print column 00,l_codigo
      #,"|"
      #,l_hora,"|"
      #,l_ok

 end report

 #-------------------------#
 report chctlU10(l_codigo)
 #-------------------------#

   define l_codigo char(02)
   define l_data date
   define l_hora datetime hour to minute


  output
      page length    066
      left margin    000
      top  margin    000
      bottom margin  000
   format

   on every row
      print column 00,l_codigo
      #,"|"
      #,l_hora,"|"
      #,l_ok

 end report

 #-----------------------------------------------#
 function ctc14m01_envia_email(l_chave,l_assunto)
 #-----------------------------------------------#

   define l_remetente, l_para, l_titulo, l_arquivo char(2000)
   define l_email    char(1000)
   define l_ret      smallint
   define l_mensagem char (500)
   define l_hora     datetime hour to minute
   define l_chave    char(01)
   define l_data     date
   define l_nome     like isskfunc.funnom
   define l_assunto  like datkassunto.c24astcod
   define l_descflg  char(22)

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
   initialize l_descflg to null

   let l_hora = current
   let l_data = current

   select funnom
     into l_nome
     from isskfunc
    where funmat = g_issk.funmat
      and empcod = g_issk.empcod
      and usrtip = "F"

   if l_chave = "N" then
      let l_descflg = "Nao transfere para Web"
   else
      let l_descflg = "Transfere para Web"
   end if

   let l_remetente ="Info.Sistemas@correioporto"
   let l_para ="chaveweb.central@correioporto"
   #let l_para = "jair.vargas@correioporto"
   if not g_outFigrc012.Is_Teste then
      let l_titulo ="ALERTA: Mudança de CHAVE na central 24h"
   else
     let l_titulo ="<< AMBIENTE DE TESTE(U28) >>ALERTA: Mudança de CHAVE na central 24h"
   end if


   let l_mensagem = "<html><body><font face = Calibri>",
                    "Esta &eacute; uma mensagem gerada automaticamente pelo sistema da central 24h.<br>",
                    "ALERTA: Houve uma altera&ccedil;&atilde;o na CHAVE de controle da migra&ccedil;&atilde;o do atendimento da central 24h para o sinistro.<br>",
                    "<br>",
                    "Data e hora: ",l_data ," - ",l_hora ,"<br>",
                    "Respons&aacute;vel pela altera&ccedil;&atilde;o: ", g_issk.funmat," - ",l_nome, "<br>",
	                  "Assunto alterado: ", l_assunto , "<br>",
	                  "Nova situa&ccedil;&atilde;o da flag: ", l_chave," - ",l_descflg

   #---[ Envia E-mail ]---#

   #PSI-2013-23297 - Inicio

    let l_mail.de = l_remetente
    #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
    let l_mail.para = l_para
    let l_mail.cc = ""
    let l_mail.cco = ""
    let l_mail.assunto = l_titulo
    let l_mail.mensagem = l_mensagem
    let l_mail.id_remetente = "CT24HS"
    let l_mail.tipo = "html"

    call figrc009_mail_send1 (l_mail.*)
      returning l_coderro,msg_erro

    #PSI-2013-23297 - Fim
   if l_coderro <> 0 then
      display "Erro no envio do email!"
   end if

 end function


#------------------------------------------------------------
 function ctc14m01_inclui(param)
#------------------------------------------------------------

 define param         record
    c24astagp         like datkassunto.c24astagp,
    c24astagpdes      like datkastagp.c24astagpdes
 end record

 define ctc14m01      record
    c24astcod         like datkassunto.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24astexbflg      like datkassunto.c24astexbflg,
    c24asttltflg      like datkassunto.c24asttltflg,
    c24astatdflg      like datkassunto.c24astatdflg,
    cndslcflg         like datkassunto.cndslcflg,
    prgcod            like datkassunto.prgcod,
    prgdes            char (100),
    c24atrflg         like datkassunto.c24atrflg,
    c24jstflg         like datkassunto.c24jstflg,
    rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,              ### PSI180475 - Paulo
    telmaiatlflg      like datkassunto.telmaiatlflg   ,
    c24aststt         like datkassunto.c24aststt,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    funnom            like isskfunc.funnom,
    restricao         char (40),
    txtdes            char (18),
    maimsgenvflg      char(01),-- OSF 35998
    risprcflg         like datkassunto.risprcflg,
    webrlzflg         like datkassunto.webrlzflg,
    atmacnflg         like datkassunto.atmacnflg,
    tip_c24ast        like datkassunto.itaasstipcod,
    mdtmsgtxt         like datmmdtmsg24h.mdtmsgtxt, #--> PSI-2013-06224/PR
    c24astpgrtxt      char (200)
 end record

 define  ws_resp       char(01)

 define tip_c24astdes     like datkasttip.itaasiplntipdes

 let tip_c24astdes = ''

 initialize ctc14m01.*   to null

 display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

 whenever error continue
   open cctc14m01005 using ctc14m01.tip_c24ast
   fetch cctc14m01005 into tip_c24astdes
 whenever error stop

 display by name  tip_c24astdes

 call ctc14m01_input("i", param.c24astagp, ctc14m01.*) returning ctc14m01.*

 if int_flag  then
    let int_flag = false
    initialize ctc14m01.*  to null

    display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

    whenever error continue
      open cctc14m01005 using ctc14m01.tip_c24ast
      fetch cctc14m01005 into tip_c24astdes
    whenever error stop

    display by name  tip_c24astdes
    error " Operacao cancelada"
    return
 end if

 let ctc14m01.atldat = today
 let ctc14m01.caddat = today
 if ctc14m01.c24asttltflg = "N" then
    initialize ctc14m01.c24astpgrtxt to null
 end if

 ###
 ### Inicio PSI180475 - Paulo
 ###
 whenever error continue
 execute pctc14m01002 using param.c24astagp
                           ,ctc14m01.c24astcod
                           ,ctc14m01.c24astdes
                           ,ctc14m01.c24astexbflg
                           ,ctc14m01.c24asttltflg
                           ,ctc14m01.c24astatdflg
                           ,ctc14m01.cndslcflg
                           ,ctc14m01.prgcod
                           ,ctc14m01.c24atrflg
                           ,ctc14m01.c24jstflg
                           ,ctc14m01.c24aststt
                           ,ctc14m01.c24astpgrtxt
                           ,ctc14m01.caddat
                           ,g_issk.funmat
                           ,ctc14m01.atldat
                           ,g_issk.funmat
                           ,ctc14m01.rcuccsmtvobrflg
                           ,ctc14m01.telmaiatlflg
                           ,ctc14m01.maimsgenvflg -- OSF 35998
                           ,ctc14m01.risprcflg
                           ,ctc14m01.webrlzflg
                           ,ctc14m01.atmacnflg
                           ,ctc14m01.tip_c24ast

 whenever error stop
 if sqlca.sqlcode <>  0 then
    error 'Erro SELECT pctc14m01002: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]   sleep 2
    error 'CTC14M01 / ctc14m01_inclui() / ',param.c24astagp          ,' / '
                                           ,ctc14m01.c24astcod       ,' / '
                                           ,ctc14m01.c24astdes       ,' / '
                                           ,ctc14m01.c24astexbflg    ,' / '
                                           ,ctc14m01.c24asttltflg    ,' / '
                                           ,ctc14m01.c24astatdflg    ,' / '
                                           ,ctc14m01.cndslcflg       ,' / '
                                           ,ctc14m01.prgcod          ,' / '
                                           ,ctc14m01.c24atrflg       ,' / '
                                           ,ctc14m01.c24jstflg       ,' / '
                                           ,ctc14m01.c24aststt       ,' / '
                                           ,ctc14m01.c24astpgrtxt    ,' / '
                                           ,ctc14m01.caddat          ,' / '
                                           ,g_issk.funmat            ,' / '
                                           ,ctc14m01.atldat          ,' / '
                                           ,g_issk.funmat            ,' / '
                                           ,ctc14m01.rcuccsmtvobrflg
                                           ,ctc14m01.telmaiatlflg    sleep 2
    return
 end if
 ###
 ### Inicio PSI180475 - Paulo
 ###

 if ctc14m01.mdtmsgtxt is not null and ctc14m01.mdtmsgtxt <> " " then #--> PSI-2013-06224/PR
    whenever error continue
    execute pctc14m01002b using ctc14m01.c24astcod, ctc14m01.mdtmsgtxt
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = -268 then
          whenever error continue
          execute pctc14m01001b using ctc14m01.mdtmsgtxt
                                     ,ctc14m01.c24astcod
          whenever error stop
          if sqlca.sqlcode <> 0 then
             error 'Erro UPDATE pctc14m01001b: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
             sleep 2
             error 'CTC14M01 / ctc14m01_inclui () / ',ctc14m01.c24astcod
                                               ,' / ',ctc14m01.mdtmsgtxt clipped
             sleep 2
             initialize ctc14m01.* to null
             return ctc14m01.*
          end if
       else
          error 'Erro INSERT pctc14m01002b: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
          sleep 2
          error 'CTC14M01 / ctc14m01_inclui() / ', ctc14m01.c24astcod
                                           ,' / ', ctc14m01.mdtmsgtxt clipped
          sleep 2
          return
       end if
    end if
 else
    whenever error continue
    execute pctc14m01001c using ctc14m01.c24astcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       error 'Erro DELETE pctc14m01001c: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       error 'CTC14M01 / ctc14m01_inclui() / ',ctc14m01.c24astcod sleep 2
       initialize ctc14m01.* to null
       return ctc14m01.*
    end if
 end if

 call ctc14m01_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
      returning ctc14m01.cadfunnom

 let ctc14m01.funnom = ctc14m01.cadfunnom

 display by name  ctc14m01.c24astcod thru ctc14m01.txtdes
 display by name  ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR

 whenever error continue
   open cctc14m01005 using ctc14m01.tip_c24ast
   fetch cctc14m01005 into tip_c24astdes
 whenever error stop

 display by name  tip_c24astdes

 display by name ctc14m01.c24astcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER"
 prompt "" for char ws_resp

 error " Cadastre os ramos aceitos ou nao para o assunto incluido"
 call ctc14m04(ctc14m01.c24astcod,
               param.c24astagpdes,
               ctc14m01.c24astdes)

 error " Cadastre as matriculas com permissao de liberar o assunto incluido"
 call ctc14m05(ctc14m01.c24astcod,
               param.c24astagpdes,
               ctc14m01.c24astdes,
               g_issk.sissgl)

 initialize ctc14m01.*  to null

 display by name ctc14m01.c24astcod thru ctc14m01.mdtmsgtxt # ctc14m01.tip_c24ast #--> PSI-2013-06224/PR
 whenever error continue
   open cctc14m01005 using ctc14m01.tip_c24ast
   fetch cctc14m01005 into tip_c24astdes
 whenever error stop

 display by name  tip_c24astdes

 end function   #  ctc14m01_inclui


#--------------------------------------------------------------------
 function ctc14m01_input(param, ctc14m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1),
    c24astagp         like datkassunto.c24astagp
 end record

 define ctc14m01      record
    c24astcod         like datkassunto.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24astexbflg      like datkassunto.c24astexbflg,
    c24asttltflg      like datkassunto.c24asttltflg,
    c24astatdflg      like datkassunto.c24astatdflg,
    cndslcflg         like datkassunto.cndslcflg,
    prgcod            like datkassunto.prgcod,
    prgdes            char (100),
    c24atrflg         like datkassunto.c24atrflg,
    c24jstflg         like datkassunto.c24jstflg,
    rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,                 ### PSI180475 - Paulo
    telmaiatlflg      like datkassunto.telmaiatlflg,
    c24aststt         like datkassunto.c24aststt,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    funnom            like isskfunc.funnom,
    restricao         char (40),
    txtdes            char (18),
    maimsgenvflg      char(01),
    risprcflg         like datkassunto.risprcflg,
    webrlzflg         like datkassunto.webrlzflg,
    atmacnflg         like datkassunto.atmacnflg,
    tip_c24ast        like datkassunto.itaasstipcod,
    mdtmsgtxt         like datmmdtmsg24h.mdtmsgtxt, #--> PSI-2013-06224/PR
    c24astpgrtxt      char (200)
 end record

 define ws            record
    cont              integer
 end record

 define     tip_c24astdes     like datkasttip.itaasiplntipdes

 let tip_c24astdes = ''
 let int_flag = false
 initialize ws.*    to null

 input by name ctc14m01.c24astcod,
               ctc14m01.c24astdes,
               ctc14m01.c24astexbflg,
               ctc14m01.c24asttltflg,
               ctc14m01.c24astatdflg,
               ctc14m01.cndslcflg,
               ctc14m01.prgcod,
               ctc14m01.c24atrflg,
               ctc14m01.c24jstflg,
               ctc14m01.rcuccsmtvobrflg,            ### PSI180475 - Paulo
               ctc14m01.telmaiatlflg,
               ctc14m01.maimsgenvflg,  -- OSF 35998
               ctc14m01.risprcflg,
               ctc14m01.webrlzflg,
               ctc14m01.c24aststt,
               ctc14m01.atmacnflg,
               ctc14m01.tip_c24ast,
               ctc14m01.mdtmsgtxt without defaults #--> PSI-2013-06224/PR

    before field c24astcod
            if param.operacao  =  "a"   then
               next field  c24astdes
            end if
           display by name ctc14m01.c24astcod attribute (reverse)

    after  field c24astcod
           display by name ctc14m01.c24astcod

           if ctc14m01.c24astcod  is null   then
              error " Codigo do assunto deve ser informado"
              next field c24astcod
           end if

           select c24astcod
             from datkassunto
            where c24astcod = ctc14m01.c24astcod

           if sqlca.sqlcode  =  0   then
              error " Codigo de assunto ja cadastrado"
              next field c24astcod
           end if

         # if ctc14m01.c24astcod[1,1]  <>  param.c24astagp   then
         #    error " Primeira letra do codigo deve ser igual ao agrupamento"
         #    next field c24astcod
         # end if

           let ws.cont = length(ctc14m01.c24astcod)
           if ws.cont  <  3   then
              error " Codigo de assunto deve ter no minimo 3 caracteres"
              next field c24astcod
           end if

    before field c24astdes
           display by name ctc14m01.c24astdes attribute (reverse)

    after  field c24astdes
           display by name ctc14m01.c24astdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "i"   then
                 next field  c24astcod
              else
                 next field  c24astdes
              end if
           end if

           if ctc14m01.c24astdes  is null   then
              error " Descricao do assunto deve ser informada"
              next field c24astdes
           end if

       before field c24astexbflg
          display by name ctc14m01.c24astexbflg  attribute(reverse)

       after field c24astexbflg
          display by name ctc14m01.c24astexbflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24astdes
          end if

          if ((ctc14m01.c24astexbflg  is null)   or
               ctc14m01.c24astexbflg  <>  "S"    and
               ctc14m01.c24astexbflg  <>  "N")   then
               error " Exibe sem restricao de nivel de acesso: (S)im ou (N)ao"
               next field c24astexbflg
          end if

       before field c24asttltflg
          display by name ctc14m01.c24asttltflg  attribute(reverse)

       after field c24asttltflg
          display by name ctc14m01.c24asttltflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24astexbflg
          end if

          if ((ctc14m01.c24asttltflg  is null)   or
               ctc14m01.c24asttltflg  <>  "S"    and
               ctc14m01.c24asttltflg  <>  "N")   then
               error " Notifica corretor via pager: (S)im ou (N)ao"
               next field c24asttltflg
          end if

          initialize ctc14m01.txtdes to null
          if ctc14m01.c24asttltflg   = "S"  then
             call ctc14m06(ctc14m01.c24astpgrtxt)
                  returning ctc14m01.c24astpgrtxt
             let ctc14m01.c24astpgrtxt = ctc14m01.c24astpgrtxt clipped,""
             if ctc14m01.c24astpgrtxt is not null then
                let ctc14m01.txtdes = "CONTEM TEXTO LIVRE"
             end if
          end if
          display by name ctc14m01.txtdes

       before field c24astatdflg
          display by name ctc14m01.c24astatdflg  attribute(reverse)

       after field c24astatdflg
          display by name ctc14m01.c24astatdflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24asttltflg
          end if

          if ((ctc14m01.c24astatdflg  is null)   or
               ctc14m01.c24astatdflg  <>  "S"    and
               ctc14m01.c24astatdflg  <>  "N")   then
               error " Exibe advertencia para o atendente: (S)im ou (N)ao"
               next field c24astatdflg
          end if

          if ctc14m01.c24astexbflg  =  "N"   and
             ctc14m01.c24astatdflg  =  "S"   then
               error " Para este assunto, existe restricao de exibicao"
               next field c24astatdflg
          end if

       before field cndslcflg
          display by name ctc14m01.cndslcflg     attribute(reverse)

       after field cndslcflg
          display by name ctc14m01.cndslcflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field cndslcflg
          end if

          if ((ctc14m01.cndslcflg     is null)   or
               ctc14m01.cndslcflg     <>  "S"    and
               ctc14m01.cndslcflg     <>  "N")   then
               error " Obrigatorio: (S)im ou (N)ao"
               next field cndslcflg
          end if


       before field prgcod
          display by name ctc14m01.prgcod  attribute(reverse)

       after  field prgcod
          display by name ctc14m01.prgcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field cndslcflg
          end if

          if ctc14m01.prgcod is null  then
             error " Acao a ser tomada deve ser informada"
             call ctc14m02() returning ctc14m01.prgcod,
                                       ctc14m01.prgdes
             next field prgcod
          end if

          select cpodes
            into ctc14m01.prgdes
            from iddkdominio
           where cponom = "prgcod"  and
                 cpocod = ctc14m01.prgcod

          if sqlca.sqlcode = notfound  then
             error " Acao a ser tomada nao cadastrada"
             call ctc14m02() returning ctc14m01.prgcod,
                                       ctc14m01.prgdes
             next field prgcod
          end if

          display by name ctc14m01.prgdes

    before field c24atrflg
          display by name ctc14m01.c24atrflg attribute(reverse)

    after  field c24atrflg
          display by name ctc14m01.c24atrflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field prgcod
          end if
          if ((ctc14m01.c24atrflg     is null)   or
               ctc14m01.c24atrflg     <>  "S"    and
               ctc14m01.c24atrflg     <>  "N")   then
               error " Obrigatorio: (S)im ou (N)ao"
               next field c24atrflg
          end if

    before field c24jstflg
          display by name ctc14m01.c24jstflg attribute(reverse)

    after  field c24jstflg
          display by name ctc14m01.c24jstflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24atrflg
          end if
          if ((ctc14m01.c24jstflg     is null)   or
               ctc14m01.c24jstflg     <>  "S"    and
               ctc14m01.c24jstflg     <>  "N")   then
               error " Obrigatorio: (S)im ou (N)ao"
               next field c24jstflg
          end if

    before field rcuccsmtvobrflg
          display by name ctc14m01.rcuccsmtvobrflg attribute(reverse)

    after field rcuccsmtvobrflg
          display by name ctc14m01.rcuccsmtvobrflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24jstflg                    #psi180475 ivone
          end if
          if ctc14m01.rcuccsmtvobrflg is null  or
             (ctc14m01.rcuccsmtvobrflg <> "S"  and
              ctc14m01.rcuccsmtvobrflg <> "N") then
             error ' Opcao invalida. Informe (S)im ou (N)ao'
             next field rcuccsmtvobrflg
          end if

    before field telmaiatlflg
          display by name ctc14m01.telmaiatlflg    attribute(reverse)

    after field telmaiatlflg
          display by name ctc14m01.telmaiatlflg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field rcuccsmtvobrflg
          end if
          if ctc14m01.telmaiatlflg is null  or
            (ctc14m01.telmaiatlflg <> "S"  and
             ctc14m01.telmaiatlflg <> "N") then
             error ' Opcao invalida. Informe (S)im ou (N)ao'
             next field telmaiatlflg
          end if


     -- OSF 35998
     before field maimsgenvflg
          #if ctc14m01.maimsgenvflg is not null then
          #   next field c24aststt
          #else
          #   error 'Notifica corretor via e-mail: (S)im ou (N)ão'
          #end if
           display by name  ctc14m01.maimsgenvflg attribute (reverse)

     after field maimsgenvflg
           if ctc14m01.maimsgenvflg is null then
              error 'Informe Msg Email'
              next field maimsgenvflg
           end if

           if upshift(ctc14m01.maimsgenvflg) <> 'S' and
              upshift(ctc14m01.maimsgenvflg) <> 'N' then
              error 'Notifica corretor via e-mail: (S)im ou (N)ao'
              next field maimsgenvflg
           end if
           display by name  ctc14m01.maimsgenvflg

     before field risprcflg
           display by name ctc14m01.risprcflg attribute (reverse)

     after field risprcflg
           display by name  ctc14m01.risprcflg

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field maimsgenvflg
           end if

           if ctc14m01.risprcflg is null or
             (ctc14m01.risprcflg <> 'S'  and
              ctc14m01.risprcflg <> 'N') then
              error 'Opcao invalida. Informe (S)im ou (N)ao'
              next field risprcflg
           end if

    before field webrlzflg
       display by name ctc14m01.webrlzflg attribute (reverse)

    after field webrlzflg
       display by name ctc14m01.webrlzflg

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field risprcflg
       end if

       if ctc14m01.webrlzflg is null or
         (ctc14m01.webrlzflg <> 'S'  and
          ctc14m01.webrlzflg <> 'N') then
          error 'Opcao invalida. Informe (S)im ou (N)ao'
          next field webrlzflg
       end if


    before field c24aststt
           if param.operacao  =  "i"   then
              let ctc14m01.c24aststt = "A"
           end if
           display by name ctc14m01.c24aststt attribute (reverse)

    after  field c24aststt
           display by name ctc14m01.c24aststt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  webrlzflg
           end if

           if ctc14m01.c24aststt  is null   or
             (ctc14m01.c24aststt  <> "A"    and
              ctc14m01.c24aststt  <> "C")   then
              error " Situacao assunto deve ser: (A)tivo ou (C)ancelado"
              next field c24aststt
           end if

           if param.operacao      = "i"   and
              ctc14m01.c24aststt  = "C"   then
              error " Nao deve ser incluido assunto c/situacao (C)ancelado"
              next field c24aststt
           end if

    before field atmacnflg
       display by name ctc14m01.atmacnflg attribute (reverse)

    after field atmacnflg
       display by name ctc14m01.atmacnflg

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field c24aststt
       end if

       if ctc14m01.atmacnflg is null or
         (ctc14m01.atmacnflg <> 'S'  and
          ctc14m01.atmacnflg <> 'N') then
          error 'Opcao invalida. Informe (S)im ou (N)ao'
          next field atmacnflg
       end if

    before field tip_c24ast  #helder 08/06/2011
      display by name ctc14m01.tip_c24ast attribute(reverse)

    after field tip_c24ast
      display by name ctc14m01.tip_c24ast

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field atmacnflg
      end if

      if ctc14m01.tip_c24ast is null then
         call ctc14m01_popup()
            returning ctc14m01.tip_c24ast
                    , tip_c24astdes

         display by name ctc14m01.tip_c24ast
                       , tip_c24astdes
      else
         whenever error continue
           open cctc14m01005 using ctc14m01.tip_c24ast
           fetch cctc14m01005 into tip_c24astdes
         whenever error stop

         display by name ctc14m01.tip_c24ast
                       , tip_c24astdes
      end if

    #--> PSI-2013-06224/PR (inicio)

    before field mdtmsgtxt
       display by name ctc14m01.mdtmsgtxt attribute (reverse)
       if param.c24astagp != "PSA" and param.c24astagp != "PSL"
          then
          exit input
       end if

    after field mdtmsgtxt
       display by name ctc14m01.mdtmsgtxt

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field tip_c24ast
       end if

       if ctc14m01.mdtmsgtxt is null or
          ctc14m01.mdtmsgtxt = " "   then
          error " Mensagem MDT deve ser informada para os agrupamentos PSA e PSL "
          next field mdtmsgtxt
       end if

    #--> PSI-2013-06224/PR (fim)

    on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize ctc14m01.*  to null
    let tip_c24astdes = ''
    display by name tip_c24astdes
 end if

 return ctc14m01.*

 end function   # ctc14m01_input


#---------------------------------------------------------
 function ctc14m01_ler(param)
#---------------------------------------------------------

 define param         record
    c24astagp         like datkassunto.c24astagp,
    c24astcod         like datkassunto.c24astcod
 end record

 define ctc14m01      record
    c24astcod         like datkassunto.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    c24astexbflg      like datkassunto.c24astexbflg,
    c24asttltflg      like datkassunto.c24asttltflg,
    c24astatdflg      like datkassunto.c24astatdflg,
    cndslcflg         like datkassunto.cndslcflg,
    prgcod            like datkassunto.prgcod,
    prgdes            char (100),
    c24atrflg         like datkassunto.c24atrflg,
    c24jstflg         like datkassunto.c24jstflg,
    rcuccsmtvobrflg   like datkassunto.rcuccsmtvobrflg,          ### PSI180475 - Paulo
    telmaiatlflg      like datkassunto.telmaiatlflg,
    c24aststt         like datkassunto.c24aststt,
    caddat            like datkassunto.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkassunto.atldat,
    funnom            like isskfunc.funnom,
    restricao         char (40),
    txtdes            char (18),
    maimsgenvflg      char(01), -- OSF 35998
    risprcflg         like datkassunto.risprcflg,
    webrlzflg         like datkassunto.webrlzflg,
    atmacnflg         like datkassunto.atmacnflg,
    tip_c24ast        like datkassunto.itaasstipcod,
    mdtmsgtxt         like datmmdtmsg24h.mdtmsgtxt, #--> PSI-2013-06224/PR
    c24astpgrtxt      char (200)
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    cadmat            like isskfunc.funmat
 end record


 initialize ctc14m01.*   to null
 initialize ws.*         to null

 ###
 ### Inicio PSI180475 - Paulo
 ###
 open cctc14m01003 using param.c24astcod
                        ,param.c24astagp

 whenever error continue
 fetch cctc14m01003 into ctc14m01.c24astcod
                        ,ctc14m01.c24astdes
                        ,ctc14m01.c24astexbflg
                        ,ctc14m01.c24asttltflg
                        ,ctc14m01.c24astatdflg
                        ,ctc14m01.cndslcflg
                        ,ctc14m01.prgcod
                        ,ctc14m01.c24atrflg
                        ,ctc14m01.c24jstflg
                        ,ctc14m01.c24aststt
                        ,ctc14m01.c24astpgrtxt
                        ,ctc14m01.caddat
                        ,ws.cadmat
                        ,ctc14m01.atldat
                        ,ws.atlmat
                        ,ctc14m01.rcuccsmtvobrflg
                        ,ctc14m01.telmaiatlflg
                        ,ctc14m01.maimsgenvflg
                        ,ctc14m01.risprcflg
                        ,ctc14m01.webrlzflg
                        ,ctc14m01.atmacnflg
                        ,ctc14m01.tip_c24ast

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       error " Codigo de assunto nao cadastrado"
    else
       error 'Erro SELECT cctc14m01003: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]    sleep 2
       error 'CTC14M01 / ctc14m01_ler() / ',param.c24astcod,' / ',param.c24astagp sleep 2
    end if
    initialize ctc14m01.*    to null
    return ctc14m01.*
 end if
 ###
 ### Final PSI180475 - Paulo
 ###

 open cctc14m01003b using param.c24astcod #--> PSI-2013-06224/PR
 whenever error continue
 fetch cctc14m01003b into ctc14m01.mdtmsgtxt
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let ctc14m01.mdtmsgtxt = ""
    else
       error 'Erro SELECT cctc14m01003b: ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2] sleep 2
       error 'CTC14M01 / ctc14m01_ler() / ',param.c24astcod sleep 2
       initialize ctc14m01.*    to null
       return ctc14m01.*
    end if
 end if

 call ctc14m01_func(ws.cadmat,
                    1,
                    "F")
      returning ctc14m01.cadfunnom

 call ctc14m01_func(ws.atlmat,
                    1,
                    "F")
      returning ctc14m01.funnom

 select cpodes
   into ctc14m01.prgdes
   from iddkdominio
  where cponom = "prgcod"  and
        cpocod = ctc14m01.prgcod

 declare c_ctc14m01r  cursor for
    select ramcod from datrclassassunto
     where c24astcod  =  param.c24astcod

 open  c_ctc14m01r
 fetch c_ctc14m01r

 if sqlca.sqlcode <> notfound   then
    let ctc14m01.restricao = "RAMOS"
 end if

 declare c_ctc14m01f  cursor for
    select funmat from datrastfun
     where c24astcod  =  param.c24astcod

 open  c_ctc14m01f
 fetch c_ctc14m01f

 if sqlca.sqlcode <> notfound   then
    let ctc14m01.restricao = ctc14m01.restricao clipped, " MATRICULAS"
 end if

 initialize ctc14m01.txtdes to null
 if ctc14m01.c24astpgrtxt is not null then
    let ctc14m01.txtdes = "CONTEM TEXTO LIVRE"
 end if

 return ctc14m01.*

 end function   # ctc14m01_ler


#---------------------------------------------------------
 function ctc14m01_func(param)
#---------------------------------------------------------

 define param         record
    funmat            like isskfunc.funmat,
    empcod            like isskfunc.empcod,
    usrtip            like isskfunc.usrtip
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where funmat = param.funmat
    and empcod = param.empcod
    and usrtip = param.usrtip

 return ws.funnom

 end function   # ctc14m01_func


#--------------------------------------------------------------------------------
 function ctc14m01_ast_guincho(l_param)
#--------------------------------------------------------------------------------

 define l_param like datkassunto.c24aststt

 define l_tabela      char(11)
 define l_chave       char(13)
 define l_errflg      char(01)
 define l_ast_dominio char(30)
 define l_sql         char(600)
 define l_cont        integer
 define l_atlult      like datkdominio.atlult

 define prompt_key    char (01)

 initialize l_tabela, l_chave, l_errflg, l_ast_dominio, l_sql, l_cont, l_atlult to null

 let l_chave = "guincho_aviso"

 call ctc40m00_busca_datk(l_chave)
      returning l_tabela

 let l_sql = "insert into ",l_tabela ,
              "(cponom, cpocod, cpodes, atlult) values (?,?,?,?)"

 prepare ins_iddkdominio from l_sql

 let l_sql = "delete from ",l_tabela ,
    " where cponom = ? "

 prepare del_iddkdominio from l_sql

 let l_errflg = "N"

 let l_atlult = f_fungeral_atlult()

  begin work

     whenever error continue

     for l_cont = 1 to 2
         if l_cont = 1 then
            if l_param = "A" then
               let l_ast_dominio = "SIN - Aviso de Sinistro"
            else
               let l_ast_dominio = "N10 - Segurado"
            end if

            execute del_iddkdominio using l_chave

            whenever error stop

            if sqlca.sqlcode <> 0  then
               error " Erro (", sqlca.sqlcode, ") na remocao do dominio, avise a INFORMATICA!" sleep 3
               exit for
            end if
         else
            let l_ast_dominio = "N11 - Terceiro"
         end if

         whenever error continue

         execute ins_iddkdominio using l_chave,
                                       l_cont,
                                       l_ast_dominio,
                                       l_atlult
         whenever error stop
         if sqlca.sqlcode <> 0  then
            error " Erro (", sqlca.sqlcode, ") na insercao do dominio!"
            prompt "" for char prompt_key
            let l_errflg = "S"
         end if

         if l_errflg <> "N"  then
            rollback work
            return 0
         end if

         if l_param ="A" then
            exit for
         end if

     end for

    if l_errflg= "N"  then
       commit work
    end if

 return 1

end function

#========================================================================
 function ctc14m01_popup() #tipo_assunto
#========================================================================
 define a_ctc92m05a array[500] of record
        itaasiplntipcod     like datkasttip.itaasiplntipcod
       ,itaasiplntipdes     like datkasttip.itaasiplntipdes
 end record

 define l_pi    smallint
 define arr_pop smallint

 initialize a_ctc92m05a to null
 let l_pi = 1
   whenever error continue
     open cctc14m01004
   whenever error stop

   foreach cctc14m01004 into a_ctc92m05a[l_pi].itaasiplntipcod
                           , a_ctc92m05a[l_pi].itaasiplntipdes
     let l_pi = l_pi + 1
   end foreach

  open window w_ctc92m05a at 9,17 with form "ctc92m05a" attribute(form line first, border)

  call set_count(l_pi - 1)
  display array a_ctc92m05a to s_ctc92m05a.*

        #-----------------------------
          on key (F8)
        #-----------------------------
             let arr_pop = arr_curr()
             exit display

        #-----------------------------
         on key (interrupt)
        #-----------------------------
             error 'Tecle F8 para escolher o tipo de Assunto'

  end display

  close window w_ctc92m05a

  return a_ctc92m05a[arr_pop].itaasiplntipcod
       , a_ctc92m05a[arr_pop].itaasiplntipdes

#========================================================================
 end function  # Fim da funcao ctc92m05_popup
#========================================================================
