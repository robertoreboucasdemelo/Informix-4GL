############################################################################
# Menu de Modulo: CTA04M00                                        Marcelo  #
#                                                                 Gilberto #
# Funcao para interface com o sistema Teletrim                    Dez/1996 #
############################################################################
# Alteracoes:                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 30/03/1999  PSI 8110-8   Wagner       Direcionar todas as mensagens da   #
#                                       susep Clara Rosemblatt para o pager#
#                                       da Silmara Rodrigues.              #
#--------------------------------------------------------------------------#
# 07/04/1999  ** ERRO **   Gilberto     Obter susep para documentos de     #
#                                       ramos diferentes do Automovel.     #
#--------------------------------------------------------------------------#
# 27/04/1999  PSI 7915-4   Gilberto     Substituir porcao do codigo onde e'#
#                                       realizada a gravacao das tabelas   #
#                                       por funcao de interface Teletrim.  #
#--------------------------------------------------------------------------#
# 07/06/1999  PSI 6962-0   Wagner       Permitir o envio do texto adicional#
#                                       pager.                             #
#--------------------------------------------------------------------------#
# 21/09/1999  PSI 9369-6   Wagner       Alteracao no nr.telefone na mensa- #
#                                       gem do pager para 3366-5155.       #
#--------------------------------------------------------------------------#
# 24/02/2000  ** ERRO **   Gilberto     Corrigido verificacao de erros no  #
#                                       retorno da funcao de interface.    #
#--------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de     #
#                                       solicitante.                       #
#--------------------------------------------------------------------------#
# 30/03/2000  Correio      Akio         Alteracao no nr.telefone na mensa- #
#                                       gem do pager para 3366-3155.       #
#--------------------------------------------------------------------------#
# 18/12/2000  Correio      Ruiz         Incluir pager's conforme Silmara   #
#--------------------------------------------------------------------------#
# 21/12/2000  PSI 12036-7  Ruiz         Montar msg para pager's e e-mail   #
#                                       para assunto E10/E12 (infochuva).  #
#--------------------------------------------------------------------------#
# 06/02/2001  PSI 11767-6  Wagner       Adaptacao tamanho referencia ender.#
#                                       referencia.                        #
#--------------------------------------------------------------------------#
# 21/12/2000  PSI 12463-0  Raji         Criterio de data/hora sinistro ass #
#                                       E12 p/ infochuva.                  #
#--------------------------------------------------------------------------#
# 22/10/2001  Correio      Ruiz         inclusao do bip 4362282(Silmara).  #
#--------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86              #
############################################################################
#                                                                          #
#                      * * * Alteracoes * * *                              #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ----------------------------------- #
# 18/09/2003  Meta,Bruno     PSI175552 Substituir funcoes , inibir linhas  #
#                            OSF26077  e implementar if.                   #
# ------------------------------------------------------------------------ #
# 13/02/2004  Paula Romanini OSF32344 Substituir a funcao fptla025_corretor#
#                                      por fptla025_msg_corsus.            #
# ------------------------------------------------------------------------ #
# 01/04/2004  Paula Romanini CT192023  Substituir o Pager do Milton        #
# 25/05/2004  Teresinha S.   OSF 35998 Inclusao da flag flagemail_param    #
#                            na funcao cta04m00                            #
#--------------------------------------------------------------------------#
# 25/10/2004  Meta, James    PSI188514 Acrescentar tipo de solicitacao = 8 #
#--------------------------------------------------------------------------#
# 21/01/2005  Meta, Robson   PSI188638 Inibir chamada da funcao            #
#                                      fptla025_msg_corsus e chamar funcao #
#                                      fpcca001 acrescentando nova mensagem#
#--------------------------------------------------------------------------#
# 28/02/2005  Carlos, Meta   PSI190098 Obter a descricao do problema pelo  #
#                                      numero do servico e incluir no corpo#
#                                      da mensagem.                        #
#--------------------------------------------------------------------------#
# 07/10/2005 Andrei, Meta    PSI195642 Definir cursores cta04m00002/003    #
#                                      Incluir novas informacoes na mensa  #
#                                      gem gerada na funcao cta04m00_msg() #
#--------------------------------------------------------------------------#
# 21/09/2006 Ligia           PSI 202720 Implementar ramo/tabela p/o Saude: #
#                                       ramgrpcod e crtsaunum              #
#--------------------------------------------------------------------------#
# 14/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32       #
#                                                                          #
# 01/10/2008 Amilton,Meta   PSI 223689  Incluir tratamento de erro com     #
#                                       global ( Isolamento U01 )          #
#--------------------------------------------------------------------------#
# 27/11/2008 Nilo Costa     PSI 228028  VEP - Viva Este Presente - Vida    #
#                                       Envio de SMS/Email - Produto VIDA  #
#--------------------------------------------------------------------------#
# 14/07/2009 Roberto Melo   PSI 243990  Inclusao das Funcoes:              #
#                                       cta04m00_monta_cabecalho           #
#                                       cta04m00_monta_mensagem            #
#                                       cta04m00_monta_mensagem_sms        #
#--------------------------------------------------------------------------#
# 16/07/2009 Roberto Melo   PSI 244460  Inclusao da Funcao:                #
#                                       cta04m00_envia_email               #
# 13/08/2009 Sergio Burini  PSI 244236  Inclusão do Sub-Dairro             #
#--------------------------------------------------------------------------#
# 29/12/2009 Patricia W.                Projeto SUCCOD - Smallint          #
# 08/03/2010 Adriano Santos CT10029839  Retirar emails com padrao antigo   #
#--------------------------------------------------------------------------#
# 30/09/2010 Carla Rampazzo             Tratamento diferenciado para docto #
#                                       Convenio Itau                      #
#--------------------------------------------------------------------------#
# 19/04/2012 Silvia, Meta PSI 2012-07408 Projeto Anatel - DDD/Telefone     #
#--------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail#
############################################################################
# vide exemplo no final do pgm.

globals '/homedsa/projetos/geral/globals/glct.4gl'
globals "/homedsa/projetos/geral/globals/figrc072.4gl"  --> 223689
globals '/homedsa/projetos/geral/globals/gpvia021.4gl'  --> VEP - Vida

define m_prep         smallint
define m_segnumdig    dec(8,0) --> VEP
define m_segnom       char(50) --> VEP
define m_cvnnum_itau  smallint

#--------------------------#
function cta04m00_prepare()
#--------------------------#
 define l_sql   char(500)

 let l_sql = ' select c24pbmdes '
              ,' from datrsrvpbm '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
               ,' and c24pbminforg = 1 '
               ,' and c24pbmseq = 1 '
 prepare p_cta04m00_001 from l_sql
 declare c_cta04m00_001 cursor for p_cta04m00_001

 let l_sql = 'select lgdtip, lgdnom, lgdnum, cidnom     '
            ,'      ,lclcttnom, dddcod, lcltelnum 	    '
            ,'      ,lclidttxt, celteldddcod, celtelnum '
            ,'  from datmlcl '
            ,' where atdsrvnum = ? '
            ,'   and atdsrvano = ? '
            ,'   and c24endtip = ? '

 prepare p_cta04m00_002 from l_sql
 declare c_cta04m00_002 cursor for p_cta04m00_002

 let l_sql = ' select a.asitipabvdes '
            ,'   from datkasitip a, datmservico b '
            ,'  where b.atdsrvnum = ? '
            ,'    and b.atdsrvano = ? '
            ,'    and b.asitipcod = a.asitipcod '

 prepare p_cta04m00_003 from l_sql
 declare c_cta04m00_003 cursor for p_cta04m00_003
 let l_sql = ' select cpodes '
            ,'   from datkdominio '
            ,'  where cponom = ? '
            ,'  order by cpocod '
 prepare pcta04m00005 from l_sql
 declare ccta04m00005 cursor for pcta04m00005
 let l_sql = " select cvnnum      ",
             " from abamapol     ",
             " where succod = ?  ",
             " and aplnumdig = ? "
 prepare pcta04m00006 from l_sql
 declare ccta04m00006 cursor for pcta04m00006

 let m_prep = true

end function

#--------------------------------------------------------------
 function cta04m00(param)
#--------------------------------------------------------------

# esta funcao tambem e chamada pelo modulo ctx19g00.4gl 02/08/07

 define param    record
    ramcod       like datrservapol.ramcod   ,
    succod       like datrservapol.succod   ,
    aplnumdig    like datrservapol.aplnumdig,
    itmnumdig    like datrservapol.itmnumdig,
    lignum       like datmligacao.lignum,
    flagemail    char(01) -- OSF 35998
 end record

 define d_cta04m00 record
    c24astcod      like datmligacao.c24astcod ,
    c24astagp      like datkassunto.c24astagp ,
    c24soltipcod   like datmligacao.c24soltipcod ,
    ligdat         like datmligacao.ligdat    ,
    lighorinc      like datmligacao.lighorinc ,
    msgtxt         char (620)                 ,
    corsus         like gcaksusep.corsus      ,
    ustcod         like htlrust.ustcod        ,
    c24astpgrtxt   char(200)
 end record

 define lr_ret_vida01 record
        coderro       smallint
       ,msgerr        char(080)
       ,sgrorg        decimal(2,0)
       ,sgrnumdig     decimal(9,0)
       ,ciaperptc     decimal(8,5)
       ,succod        like datrligapol.succod  #decimal(2,0)  #projeto succod
       ,aplnumdig     decimal(9,0)
       ,rnvsuccod     like datrligapol.succod  #decimal(2,0)  #projeto succod
       ,rnvaplnum     decimal(9,0)
       ,ramcod        smallint
       ,rmemdlcod     decimal(3,0)
       ,subcod        decimal(2,0)
       ,csginfflg     char(001)
       ,empcod        decimal(2,0)
       ,clbctrtip     decimal(2,0)
       ,rnvramcod     smallint
 end record

  define lr_ret_vida02 record
         coderro       smallint
        ,msgerr        char(80)
        ,sgrorg        decimal(2,0)
        ,sgrnumdig     decimal(9,0)
        ,corsus        char(6)
        ,corlidflg     char(1)
        ,corperptc     decimal(5,2)
 end record

 define lr_ret_vida03 record
        coderro       smallint
       ,msgerr        char(080)
       ,vigfnl        date
       ,edsnumdig     decimal(9,0)
       ,segnumdig     decimal(8,0)
       ,prporg        decimal(2,0)
       ,prpnumdig     decimal(8,0)
 end record

 define l_ret_prev01    record
        coderro         integer,
        menserro        char(30),
        qtdlinhas       integer
 end record

 define ws       record
    sql          char (500)                 ,
    c24astcod    like datmligacao.c24astcod ,
    c24astagp    like datkassunto.c24astagp ,
    lignum       like datmligacao.lignum    ,
    ligdat       like datmligacao.ligdat    ,
    lighorinc    like datmligacao.lighorinc ,
    sgrorg       like rsamseguro.sgrorg     ,
    sgrnumdig    like rsamseguro.sgrnumdig  ,
    mstnum       like htlmmst.mstnum        ,
    mstastdes    like htlmmst.mstastdes     ,
    errcod       smallint                   ,
    sqlcod       integer                    ,
    atdsrvnum    like datmligacao.atdsrvnum ,
    atdsrvano    like datmligacao.atdsrvano ,
    ok           char (01),
    msg          char (300),
    c24funmat    like datmligacao.c24funmat ,
    msgm         char (01),
    c24solnom    like datmligacao.c24solnom
 end record

 define a_cta04m00 array[15] of record
        ustcod     like htlrust.ustcod
 end record
 define lr_retorno record
     resultado  smallint                 ,
     mensagem   char(60)                 ,
     doc_handle integer                  ,
     cornom     like gcakcorr.cornom     ,
     corteltxt  like gcakfilial.teltxt
 end record
 define arr_aux   integer

 define	w_pf1	integer

## PSI 175552 - Inicio

 define l_flag         smallint ## PSI 175552 eduardo - meta
 define l_achou        smallint
 define l_retorno      smallint
       ,l_msgtxtsms    char(143)
       ,l_status       smallint
       ,l_msg          char(20)
       ,l_cornom       char(50)
       ,l_crtsaunum    char(25)
       ,l_ret          smallint

 let l_achou       = false
 let l_msgtxtsms   = null
 let l_crtsaunum   = null
 let m_segnumdig   = null  --> VEP
 let m_segnom      = null  --> VEP
 let l_ret         = false
 let m_cvnnum_itau = false
 let l_retorno     = 0

## PSI 175552 - Final

	let	arr_aux  =  null

	for	w_pf1  =  1  to  15
		initialize  a_cta04m00[w_pf1].*  to  null
	end	for

	initialize  d_cta04m00.*  to  null

	initialize  ws.*, lr_retorno.*  to  null

 initialize d_cta04m00.*    to null
 initialize ws.*            to null
 initialize lr_ret_vida01.* to null   ---> Vida - VEP
 initialize l_ret_prev01.*  to null   ---> Vida - VEP
 let arr_aux = 0

 if m_prep is null or
    m_prep <> true then
    call cta04m00_prepare()
 end if

 call cts10g13_grava_rastreamento(param.lignum                  ,
                                  '2'                           ,
                                  'cta04m00'                    ,
                                  '1'                           ,
                                  '1- Validando Regras de Envio',
                                  ' '                            )




 if g_documento.ramgrpcod <> 5  then #PSI 202720
    if param.succod    is null  or
       param.ramcod    is null  or
       param.aplnumdig is null  or
       param.itmnumdig is null  then

       call cts10g13_grava_rastreamento(param.lignum                  ,
                                        '2'                           ,
                                        'cta04m00'                    ,
                                        '1'                           ,
                                        '2- Apolice Nao Informada'    ,
                                        ' '                            )

       return l_retorno
    end if
 end if


 select c24astcod, c24soltipcod,
        ligdat   , lighorinc   ,
        atdsrvnum, atdsrvano   ,
        c24solnom, c24funmat
   into d_cta04m00.c24astcod,
        d_cta04m00.c24soltipcod,
        d_cta04m00.ligdat   ,
        d_cta04m00.lighorinc,
        ws.atdsrvnum        ,
        ws.atdsrvano        ,
        ws.c24solnom        ,
        ws.c24funmat
   from datmligacao
  where lignum = param.lignum
  if ws.c24funmat = 999999 then
     let ws.mstastdes = "PORTAL DO CLIENTE INFORMA"
  else
     let ws.mstastdes = "CENTRAL 24 HORAS INFORMA"
  end if

 let l_retorno = 0

 if sqlca.sqlcode = notfound  then

     call cts10g13_grava_rastreamento(param.lignum                  ,
                                      '2'                           ,
                                      'cta04m00'                    ,
                                      '1'                           ,
                                      '3- Ligacao Nao Encontrada'   ,
                                      ' '                            )

    return l_retorno
 else
    if d_cta04m00.c24astcod = "E10"  or
       d_cta04m00.c24astcod = "E12"  then

       # PSI 175552 - Inicio
       let l_retorno = 1
       if g_documento.lignum is not null then
       call figrc072_setTratarIsolamento() -- > psi 223689
          call cts30m00(g_documento.ramcod   , g_documento.c24astcod,
                        g_documento.ligcvntip, g_documento.succod,
                        g_documento.aplnumdig, g_documento.itmnumdig,
                        g_documento.lignum   , ws.atdsrvnum,
                        ws.atdsrvano         , g_documento.prporg,
                        g_documento.prpnumdig, g_documento.solnom)
              returning l_flag
              if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
                 error "Problemas na função cts30m00 ! Avise a Informatica !" sleep 2

                 call cts10g13_grava_rastreamento(param.lignum                  ,
                                                  '2'                           ,
                                                  'cta04m00'                    ,
                                                  '1'                           ,
                                                  '4- Erro no Envio da Mensagem',
                                                  ' '                            )

                 return
              end if        -- > 223689
       end if
    end if

    if d_cta04m00.ligdat    < today    and
       d_cta04m00.lighorinc < "22:00"  then

       call cts10g13_grava_rastreamento(param.lignum                            ,
                                        '2'                                     ,
                                        'cta04m00'                              ,
                                        '1'                                     ,
                                        '5- Horario Fora do Envio da Mensagem ' ,
                                        ' '                                     )

       return l_retorno
    end if

    if d_cta04m00.c24soltipcod = 2  or
       d_cta04m00.c24soltipcod = 8  then

       call cts10g13_grava_rastreamento(param.lignum                             ,
                                        '2'                                      ,
                                        'cta04m00'                               ,
                                        '1'                                      ,
                                        '6- Tipo de Solicitante Sem Permissao'   ,
                                        ' '                                      )

       return l_retorno
    end if

   select c24astagp, c24astpgrtxt
     into d_cta04m00.c24astagp, d_cta04m00.c24astpgrtxt
     from datkassunto
    where c24astcod = d_cta04m00.c24astcod

   if sqlca.sqlcode = notfound  then

      call cts10g13_grava_rastreamento(param.lignum                             ,
                                       '2'                                      ,
                                       'cta04m00'                               ,
                                       '1'                                      ,
                                       '7- Assunto Nao Encontrado'              ,
                                       ' '                                      )


      return l_retorno
   end if
 end if

 if g_documento.ciaempcod = 84 then
      let ws.sql = ' select datmligacao.lignum   , ',
                   '        datmligacao.c24astcod, ',
                   '        datmligacao.ligdat   , ',
                   '        datmligacao.lighorinc ',
                   '   from datrligapol, datmligacao, datrligitaaplitm ',
                   '  where datrligapol.succod         = ? ',
                   '    and datrligapol.ramcod         = ? ',
                   '    and datrligapol.aplnumdig      = ? ',
                   '    and datrligapol.itmnumdig      = ? ',
                   '    and datrligitaaplitm.itaciacod = ? ',
                   '    and datmligacao.lignum = datrligapol.lignum     ',
                   '    and datrligapol.lignum = datrligitaaplitm.lignum '
 else
      if g_documento.ramgrpcod = 5 then ## PSI 202720
         let ws.sql = ' select datmligacao.lignum   , ',
                     '        datmligacao.c24astcod, ',
                     '        datmligacao.ligdat   , ',
                     '        datmligacao.lighorinc ',
                     '   from datrligsau, datmligacao ',
                     '  where datrligsau.crtnum  = ? ',
                     '    and datmligacao.lignum = datrligsau.lignum '
      else
         if g_documento.ramgrpcod <> 3 then ## PSI 202720
            let ws.sql = ' select datmligacao.lignum   , ',
                         '        datmligacao.c24astcod, ',
                         '        datmligacao.ligdat   , ',
                         '        datmligacao.lighorinc ',
                         '   from datrligapol, datmligacao ',
                         '  where datrligapol.succod    = ? ',
                         '    and datrligapol.ramcod    = ? ',
                         '    and datrligapol.aplnumdig = ? ',
                         '    and datrligapol.itmnumdig = ? ',
                         '    and datmligacao.lignum    = datrligapol.lignum '
         else
            #---> ramgrpcod = 3 ---> Vida - VEP
            let ws.sql = ' select datmligacao.lignum   , ',
                         '        datmligacao.c24astcod, ',
                         '        datmligacao.ligdat   , ',
                         '        datmligacao.lighorinc ',
                         '   from datrligapol, datmligacao ',
                         '  where datrligapol.succod    = ? ',
                         '    and datrligapol.ramcod    = ? ',
                         '    and datrligapol.aplnumdig = ? ',
                         '    and datmligacao.lignum    = datrligapol.lignum '
         end if
      end if
   end if


 prepare pcta04m00004 from ws.sql
 declare ccta04m00004 cursor for pcta04m00004

 if g_documento.ciaempcod = 84 then
    open ccta04m00004 using param.succod,
                            param.ramcod,
                            param.aplnumdig,
                            param.itmnumdig,
                            g_documento.itaciacod
 else
    if g_documento.ramgrpcod = 5 then ##PSI 202720
       let l_crtsaunum = '"', g_documento.crtsaunum  clipped, '"'
       open ccta04m00004 using l_crtsaunum
    else
       #---> ramgrpcod = 3 ---> Vida - VEP
       if g_documento.ramgrpcod <> 3 then
          open ccta04m00004 using param.succod, param.ramcod, param.aplnumdig,
                                  param.itmnumdig
       else
          open ccta04m00004 using param.succod, param.ramcod, param.aplnumdig
       end if
    end if
 end if

 foreach ccta04m00004 into ws.lignum, ws.c24astcod, ws.ligdat, ws.lighorinc

    if ws.lignum = param.lignum  then
       continue foreach
    end if

    if g_documento.ciaempcod <> 84 then
        ---> Verifica se e Convenio Itau
        call cta04m00_verifica_convenio_itau()
           returning m_cvnnum_itau
    end if

    ---> So faz filtro se nao for do Itau, caso seja deve enviar email de
    ---> todos os assuntos
    if m_cvnnum_itau = false then

       select c24astagp into ws.c24astagp
         from datkassunto
        where c24astcod = ws.c24astcod
       if ws.c24astagp = d_cta04m00.c24astagp  then
          if ws.ligdat = d_cta04m00.ligdat  then

             call cts10g13_grava_rastreamento(param.lignum                               ,
                                              '2'                                        ,
                                              'cta04m00'                                 ,
                                              '1'                                        ,
                                              '8- Existem Ligacoes para a Mesma Data'    ,
                                              ' '                                        )


             return l_retorno
          else
             if ws.ligdat    = d_cta04m00.ligdat - 1 units day  and
                ws.lighorinc > "22:00"                          then

                call cts10g13_grava_rastreamento(param.lignum                                ,
                                                 '2'                                         ,
                                                 'cta04m00'                                  ,
                                                 '1'                                         ,
                                                 '9- Existem Ligacoes Ontem Acima das 22:00' ,
                                                 ' '                                         )


                return l_retorno
             end if
          end if
       end if
    end if

 end foreach

 if g_documento.ciaempcod <> 35 then
    if g_documento.ramgrpcod = 1 then ## Auto
       select corsus into d_cta04m00.corsus
         from abamcor
        where succod    = param.succod      and
              aplnumdig = param.aplnumdig   and
              corlidflg = "S"

       if sqlca.sqlcode <> 0  then
          error " Susep da apolice nao encontrada. AVISE A INFORMATICA"

          call cts10g13_grava_rastreamento(param.lignum                      ,
                                           '2'                               ,
                                           'cta04m00'                        ,
                                           '1'                               ,
                                           '10- Susep Auto Nao Encontrada'   ,
                                           ' '                               )

          return l_retorno
       end if

    end if

    if g_documento.ramgrpcod = 2 or
       g_documento.ramgrpcod = 4 or
       g_documento.ramgrpcod = 6 then ## RE

       select sgrorg, sgrnumdig
         into ws.sgrorg, ws.sgrnumdig
         from rsamseguro
        where succod    = param.succod     and
              ramcod    = param.ramcod     and
           aplnumdig = param.aplnumdig

       if sqlca.sqlcode <> 0  then

           call cts10g13_grava_rastreamento(param.lignum                     ,
                                            '2'                              ,
                                            'cta04m00'                       ,
                                            '1'                              ,
                                            '11- Apolice RE Nao Encontrada'  ,
                                            ' '                              )
          return l_retorno
       end if

       select corsus
         into d_cta04m00.corsus
         from rsampcorre
        where sgrorg    = ws.sgrorg     and
              sgrnumdig = ws.sgrnumdig  and
              corlidflg = "S"

       if sqlca.sqlcode <> 0  then
          error " Susep da apolice nao encontrada. AVISE A INFORMATICA."

          call cts10g13_grava_rastreamento(param.lignum                   ,
                                           '2'                            ,
                                           'cta04m00'                     ,
                                           '1'                            ,
                                           '12- Susep RE Nao Encontrada'  ,
                                           ' '                            )
          return l_retorno
       end if
    end if
end if

 if g_documento.ramgrpcod = 5 then ## Saude
    ## obter o codigo do corretor
    call cta01m15_sel_datksegsau(2, g_documento.crtsaunum, '','','')
         returning l_status, l_msg, d_cta04m00.corsus, l_cornom
 end if

 if g_documento.ramgrpcod = 3 then ## Vida
    #---> Vida - VEP
    call fvnre000_rsamseguro_01(param.succod, param.ramcod, param.aplnumdig)
         returning lr_ret_vida01.*

    if lr_ret_vida01.coderro <> 0 then

       let m_segnom = null

       call fpvia21_pesquisa_dados_segurado(param.succod
                                           ,991
                                           ,param.aplnumdig)
            returning l_ret_prev01.coderro
                     ,l_ret_prev01.menserro
                     ,l_ret_prev01.qtdlinhas
                     # ---> Carrega array g_a_psqdadseg

            let d_cta04m00.corsus = g_a_psqdadseg[1].corsus
            let m_segnom          = g_a_psqdadseg[1].segnom
    else

       let m_segnumdig = null

       call fvnre000_rsampcorre_05(lr_ret_vida01.sgrorg
                                  ,lr_ret_vida01.sgrnumdig)
            returning lr_ret_vida02.*

       let d_cta04m00.corsus = lr_ret_vida02.corsus

       call fvnre000_rsdmdocto_06(lr_ret_vida01.sgrorg
                                 ,lr_ret_vida01.sgrnumdig)
            returning lr_ret_vida03.*

       if lr_ret_vida03.coderro = 0 then
          let m_segnumdig = lr_ret_vida03.segnumdig
       end if
    end if
 end if

 if g_documento.ciaempcod = 84 then
   let d_cta04m00.corsus =  g_doc_itau[1].corsus
 end if

 if g_documento.ciaempcod = 35 then
 	  call cts42g00_doc_handle(g_documento.succod,
 	                           g_documento.ramcod,
 	                           g_documento.aplnumdig,
 	                           g_documento.itmnumdig,
 	                           g_documento.edsnumref)
 	  returning lr_retorno.resultado  ,
 	            lr_retorno.mensagem   ,
 	            lr_retorno.doc_handle
    call cts38m00_extrai_dados_corr(lr_retorno.doc_handle)
         returning lr_retorno.cornom ,
                   d_cta04m00.corsus ,
                   lr_retorno.corteltxt
  end if

 if d_cta04m00.corsus is null  then
    error " Susep da apolice nao encontrada. AVISE A INFORMATICA!"

    call cts10g13_grava_rastreamento(param.lignum               ,
                                     '2'                        ,
                                     'cta04m00'                 ,
                                     '1'                        ,
                                     '13- Susep Nao Encontrada' ,
                                     ' '                        )
    return l_retorno
 end if

## PSI 175552 - Inicio
call cta04m00_msg(param.ramcod   ,
                  param.succod   ,
                  param.aplnumdig,
                  param.itmnumdig,
                  d_cta04m00.c24astcod,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.c24solnom,
                  ws.c24funmat)
        returning d_cta04m00.msgtxt, l_msgtxtsms

 if d_cta04m00.msgtxt is null  then

    call cts10g13_grava_rastreamento(param.lignum                 ,
                                     '2'                          ,
                                     'cta04m00'                   ,
                                     '1'                          ,
                                     '14- Mensagem Nao Elaborada' ,
                                     ' '                          )

    return l_retorno
 end if

 whenever error continue

 if g_documento.ciaempcod = 84 then

    # Se o Segurado Itau e VIP Envia E-mail para os Coordenadores

    if g_doc_itau[1].vipsegflg    = "S" then

       # Envia E-mail para os Coordenadores da Central 24H
       let ws.mstastdes = ws.mstastdes clipped, " SUSEP ", d_cta04m00.corsus clipped

       # Quando o Assunto For I01 não enviar o Email
       if d_cta04m00.c24astcod <> "I01"  then

          call cta04m00_envia_email(ws.mstastdes       ,
                                    d_cta04m00.msgtxt  )

       end if
    end if

    call cts11g00_verifica_formulario(g_documento.lignum)
         returning l_ret

    if l_ret = false then
        call fpcca001_msg_corsus(d_cta04m00.corsus
                                 ,ws.mstastdes
                                 ,d_cta04m00.msgtxt
                                 ,g_issk.funmat
                                 ,g_issk.empcod
                                 ,false     ###  Nao controla transacoes
                                 ,param.flagemail
                                 ,"O"       ###  Online
                                 ,"M"       ###  Mailtrim
                                 ,""        ###  Data Transmissao
                                 ,""        ###  Hora Transmissao
                                 ,g_issk.maqsgl
                                 ,g_issk.sissgl
                                 ,g_issk.usrtip   ###  Maquina de aplicacao
                                 ,l_msgtxtsms
                                 ,1)
                     returning ws.errcod,
                               ws.sqlcod,
                               ws.mstnum

        if ws.errcod >= 5  then
           error "Erro(",ws.sqlcod,ws.errcod,") no Teletrim ",
                 "CTA04M00-corretor. AVISE A INFORMATICA!"
           rollback work

           -- susep sem pager
           if ws.errcod <> 10 and
              ws.errcod <> 11  then -- OSF 35998
              let ws.msg =
              "CTA04m00-PROBL.ROTINA CORRETOR-fptla025_msg_corsus",
               ascii(10),
              "errcod=",ws.errcod," sqlcod=",ws.sqlcod," corsus=",d_cta04m00.corsus,
               ascii(10),
              "-----------------------------------------------------------------"
              call errorlog(ws.msg)
           end if

           call cts10g13_grava_rastreamento(param.lignum                 ,
                                            '2'                          ,
                                            'cta04m00'                   ,
                                            ws.errcod                    ,
                                            '15- Mensagem Nao Enviada'   ,
                                            ' '                          )

           prompt "" for char ws.msgm
           return l_retorno

        else
          call cts10g13_grava_rastreamento(param.lignum                 ,
                                           '2'                          ,
                                           'cta04m00'                   ,
                                           '0'                          ,
                                           '16- Mensagem Enviada'       ,
                                           d_cta04m00.corsus            )

           insert into datrligmens (lignum, mstnum) # relacionamento
                  values  (param.lignum, ws.mstnum) # ligacao x mensagem
           commit work
        end if
    end if


 else
       call cta04m00_verifica_convenio_itau()
       returning m_cvnnum_itau

       if d_cta04m00.corsus = "P5005J"  or      ###  Se for susep utilizada pela
          d_cta04m00.corsus = "I5005J"  or      ###  Clara Rosemblatt
          d_cta04m00.corsus = "M5005J"  or      ###  para seguro a funcionarios,
          d_cta04m00.corsus = "G5005J"  or
          m_cvnnum_itau = true          then    ###  direcionar para

          # Envia E-mail para os Coordenadores da Central 24H
          let ws.mstastdes = ws.mstastdes clipped, " SUSEP ", d_cta04m00.corsus clipped

          # Quando o Assunto For B01 Vindo do portal não enviar o Email
          if (d_cta04m00.c24astcod <> "B01" ) or
             (m_cvnnum_itau = true          ) then    ###  direcionar para
             call cta04m00_envia_email(ws.mstastdes       ,
                                       d_cta04m00.msgtxt  )
          end if
       else
          begin work
          call cta04m00_msg(param.ramcod   ,
                            param.succod   ,
                            param.aplnumdig,
                            param.itmnumdig,
                            d_cta04m00.c24astcod,
                            ws.atdsrvnum,
                            ws.atdsrvano,
                            ws.c24solnom,
                            ws.c24funmat)
                  returning d_cta04m00.msgtxt, l_msgtxtsms

          if d_cta04m00.msgtxt is null  then

             rollback work

             call cts10g13_grava_rastreamento(param.lignum                 ,
                                              '2'                          ,
                                              'cta04m00'                   ,
                                              '1'                          ,
                                              '17- Mensagem Nao Elaborada' ,
                                              ' '                          )




             return l_retorno
          end if

          call cts11g00_verifica_formulario(g_documento.lignum)
               returning l_ret

          if l_ret = false then
              call fpcca001_msg_corsus(d_cta04m00.corsus
                                       ,ws.mstastdes
                                       ,d_cta04m00.msgtxt
                                       ,g_issk.funmat
                                       ,g_issk.empcod
                                       ,false     ###  Nao controla transacoes
                                       ,param.flagemail
                                       ,"O"       ###  Online
                                       ,"M"       ###  Mailtrim
                                       ,""        ###  Data Transmissao
                                       ,""        ###  Hora Transmissao
                                       ,g_issk.maqsgl
                                       ,g_issk.sissgl
                                       ,g_issk.usrtip   ###  Maquina de aplicacao
                                       ,l_msgtxtsms
                                       ,1)
                           returning ws.errcod,
                                     ws.sqlcod,
                                     ws.mstnum
              if ws.errcod >= 5  then
                 error "Erro(",ws.sqlcod,ws.errcod,") no Teletrim ",
                       "CTA04M00-corretor. AVISE A INFORMATICA!"
                 rollback work
                 -- susep sem pager
                 if ws.errcod <> 10 and
                    ws.errcod <> 11  then -- OSF 35998
                    let ws.msg =
                    "CTA04m00-PROBL.ROTINA CORRETOR-fptla025_msg_corsus",
                     ascii(10),
                    "errcod=",ws.errcod," sqlcod=",ws.sqlcod," corsus=",d_cta04m00.corsus,
                     ascii(10),
                    "-----------------------------------------------------------------"
                    call errorlog(ws.msg)
                 end if

                 call cts10g13_grava_rastreamento(param.lignum                 ,
                                                  '2'                          ,
                                                  'cta04m00'                   ,
                                                  ws.errcod                    ,
                                                  '18- Mensagem Nao Enviada'   ,
                                                  ' '                          )


                 prompt "" for char ws.msgm
                 return l_retorno
              else

                 call cts10g13_grava_rastreamento(param.lignum                 ,
                                                  'cta04m00'                   ,
                                                  '2'                          ,
                                                  '0'                          ,
                                                  '19- Mensagem Enviada'       ,
                                                  d_cta04m00.corsus            )

                 insert into datrligmens (lignum, mstnum) # relacionamento
                        values  (param.lignum, ws.mstnum) # ligacao x mensagem
                 commit work
              end if
          end if
       end if
 end if
 whenever error stop

#-----------------------------------------------------------------------
# Verifica texto adicional para pager
#-----------------------------------------------------------------------
 if d_cta04m00.c24astpgrtxt is not null then
    for arr_aux = 1 to 15
        initialize a_cta04m00[arr_aux].* to null
    end for
    let arr_aux = 0
    initialize d_cta04m00.msgtxt to null

    ###PSI 202720
    if g_documento.ramgrpcod = 5 then #Saude
       let d_cta04m00.msgtxt =
           "PORTO SEGURO CT24H INFORMA-Complemento: Cartao Saude: ",
                             g_documento.crtsaunum clipped, " ",
                             d_cta04m00.c24astpgrtxt clipped
    else
       let d_cta04m00.msgtxt =
           "PORTO SEGURO CT24H INFORMA-Complemento: Apolice: ",
                             param.succod using "<<<&&", "/",  #"&&", "/",  #projeto succod
                             param.ramcod using "##&&", "/",
                             param.aplnumdig using "<<<<<<<&&", "/",
                             param.itmnumdig using "<<<<<&&", " ",
                             d_cta04m00.c24astpgrtxt clipped
    end if

    whenever error continue

    if d_cta04m00.corsus = "P5005J"  or      ###  Se for susep utilizada pela
       d_cta04m00.corsus = "I5005J"  or      ###  Clara Rosemblatt
       d_cta04m00.corsus = "M5005J"  or      ###  para seguro a funcionarios,
       d_cta04m00.corsus = "G5005J"  or
       m_cvnnum_itau     = true      then    ###  direcionar para

       # Envia E-mail para os Coordenadores da Central 24H
       let ws.mstastdes = ws.mstastdes clipped, " SUSEP ", d_cta04m00.corsus clipped

       call cta04m00_envia_email(ws.mstastdes       ,
                                 d_cta04m00.msgtxt  )
    else
       begin work

       ## PSI 202720
       if g_documento.ramgrpcod = 5 then ## Saude
          let l_msgtxtsms = 'PORTO SEGURO Compl: Cartao Saude ',
                            g_documento.crtsaunum clipped,' ',
                            d_cta04m00.c24astpgrtxt[1,96]
       else
          let l_msgtxtsms = 'PORTO SEGURO Compl:Apolice '
                              ,param.succod using '<<<&&'  #'&&'  #projeto succod
                           ,'/'
                           ,param.ramcod using '##&'
                           ,'/'
                           ,param.aplnumdig using '<<<<<<<&&'
                           ,'/'
                           ,param.itmnumdig using '<&'
                           ,' '
                           ,d_cta04m00.c24astpgrtxt[1,96]
       end if

       call cts11g00_verifica_formulario(g_documento.lignum)
            returning l_ret
       if l_ret = false then
           call fpcca001_msg_corsus(d_cta04m00.corsus
                                   ,ws.mstastdes
                                   ,d_cta04m00.msgtxt
                                   ,g_issk.funmat
                                   ,g_issk.empcod
                                   ,false     ###  Nao controla transacoes
                                   ,param.flagemail
                                   ,"O"       ###  Online
                                   ,"M"       ###  Mailtrim
                                   ,""        ###  Data Transmissao
                                   ,""        ###  Hora Transmissao
                                   ,g_issk.maqsgl
                                   ,g_issk.sissgl
                                   ,g_issk.usrtip   ###  Maquina de aplicacao
                                   ,l_msgtxtsms
                                   ,1)
           returning ws.errcod,
                     ws.sqlcod,
                     ws.mstnum
           if ws.errcod >= 5  then
              error "Erro(",ws.sqlcod,ws.errcod,") no Teletrim ",
                    "CTA04M00-complmsg.AVISE A INFORMATICA!"
              rollback work
              -- susep sem pager
              if ws.errcod <> 10 and
                 ws.errcod <> 11 then -- CT 35998
                 let ws.msg =
                 "CTA04m00-PROBL.ROTINA COMPLMSG-fptla025_msg_corsus",
                  ascii(10),
                 "errcod=",ws.errcod," sqlcod=",ws.sqlcod," corsus=",
                           d_cta04m00.corsus,
                  ascii(10),
                 "-----------------------------------------------------------------"
                 call errorlog(ws.msg)
              end if

              call cts10g13_grava_rastreamento(param.lignum                 ,
                                               '2'                          ,
                                               'cta04m00'                   ,
                                               ws.errcod                    ,
                                               '20- Mensagem Nao Enviada'   ,
                                               ' '                          )


              prompt "" for ws.msgm
              return l_retorno
           else

              call cts10g13_grava_rastreamento(param.lignum                 ,
                                               '2'                          ,
                                               'cta04m00'                   ,
                                               '0'                          ,
                                               '21- Mensagem Enviada'       ,
                                               d_cta04m00.corsus            )
              insert into datrligmens (lignum, mstnum) # relacionamento
                     values  (param.lignum, ws.mstnum) # ligacao x mensagem
              commit work
           end if
       end if
    end if
    whenever error stop
 end if

 return l_retorno

end function  ###  cta04m00

#-----------------------------------------------------------------------
 function cta04m00_msg(param)
#-----------------------------------------------------------------------

 define param     record
       ramcod     like datrservapol.ramcod   ,
       succod     like datrservapol.succod   ,
       aplnumdig  like datrservapol.aplnumdig,
       itmnumdig  like datrservapol.itmnumdig,
       c24astcod  like datkassunto.c24astcod,
       atdsrvnum  like datmligacao.atdsrvnum,
       atdsrvano  like datmligacao.atdsrvano,
       c24solnom  like datmligacao.c24solnom,
       c24funmat  like datmligacao.c24funmat
 end record

 define ws           record
        sgrorg       like rsamseguro.sgrorg    ,
        sgrnumdig    like rsamseguro.sgrnumdig ,
        segnumdig    like gsakseg.segnumdig    ,
        segnom       char (40)                 ,
        c24astdes    char (72)                 ,
        dddcod       like gsakend.dddcod       ,
        teltxt       char (26)                 ,
        c24pbmdes    like datrsrvpbm.c24pbmdes,
        lgdtip	     like datmlcl.lgdtip,
        lgdnom	     like datmlcl.lgdnom,
        lgdnum	     like datmlcl.lgdnum,
        cidnom	     like datmlcl.cidnom,
        lclcttnom	   like datmlcl.lclcttnom,
        dddcod2	     like datmlcl.dddcod,
        lcltelnum	   like datmlcl.lcltelnum,
        asitipabvdes like datkasitip.asitipabvdes,
        lgdtip2	     like datmlcl.lgdtip,
        lgdnom2 	   like datmlcl.lgdnom,
        lgdnum2	     like datmlcl.lgdnum,
        lclidttxt	   like datmlcl.lclidttxt,
        vcllicnum    char(08)              ,
        c24solnom    like datmligacao.c24solnom,
        celteldddcod like datmlcl.celteldddcod ,
        celtelnum    like datmlcl.celtelnum
 end record

 define lr_lx      record
        cidnom     like datmlcl.cidnom
       ,lclcttnom  like datmlcl.lclcttnom
       ,dddcod     like datmlcl.dddcod
       ,lcltelnum  like datmlcl.lcltelnum
       ,lclidttxt  like datmlcl.lclidttxt
 end record

 define l_c24endtip smallint,
        l_apl       char(100),
        l_status    smallint,
        l_msg       char(20)

 define retorno   record
        msgtxt    char (620)
       ,msgtxtsms char(143)
 end record
 define lr_retorno record
     resultado  smallint                 ,
     mensagem   char(60)                 ,
     doc_handle integer                  ,
     vclmrcnom  like agbkmarca.vclmrcnom ,
     vcltipnom  like agbktip.vcltipnom   ,
     vclmdlnom  like agbkveic.vclmdlnom  ,
     vclchs     char(20)                 ,
     vclanofbc  like abbmveic.vclanofbc  ,
     vclanomdl  like abbmveic.vclanomdl
 end record

 initialize retorno.*, lr_retorno.*  to null
 initialize ws.*       to null
 let l_apl  = null

 call c24geral8(param.c24astcod) returning ws.c24astdes

#-----------------------------------------------------------------------
# Localiza numero do segurado conforme ramo
#-----------------------------------------------------------------------
  if g_documento.ciaempcod <> 35 then
     if g_documento.ramgrpcod = 1 then ## Auto
        if param.succod    is not null  and
           param.aplnumdig is not null  and
           param.itmnumdig is not null  then
           call f_funapol_ultima_situacao (param.succod   ,
                                           param.aplnumdig,
                                           param.itmnumdig)
                                 returning g_funapol.*

           select segnumdig
             into ws.segnumdig
             from abbmdoc
            where succod    = param.succod     and
                  aplnumdig = param.aplnumdig  and
                  itmnumdig = param.itmnumdig  and
                  dctnumseq = g_funapol.dctnumseq

           if sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") na localizacao do documento",
                    " (AUTOMOVEL). AVISE A INFORMATICA!"
              initialize retorno.*  to null
              return retorno.*
           end if

           --------------[ obter placa ]------------
           initialize ws.vcllicnum to null
           select vcllicnum
              into ws.vcllicnum
              from abbmveic
             where succod     = param.succod
               and aplnumdig  = param.aplnumdig
               and itmnumdig  = param.itmnumdig
               and dctnumseq  = g_funapol.vclsitatu
           if sqlca.sqlcode = notfound  then
              select vcllicnum
                into ws.vcllicnum
                from abbmveic
               where succod    = param.succod       and
                     aplnumdig = param.aplnumdig    and
                     itmnumdig = param.itmnumdig    and
                     dctnumseq = (select max(dctnumseq)
                                    from abbmveic
                                   where succod    = param.succod     and
                                         aplnumdig = param.aplnumdig  and
                                         itmnumdig = param.itmnumdig)
           end if
           if ws.vcllicnum is null then
              let ws.vcllicnum = "SEMPLACA"
           end if
        end if
     end if

     if g_documento.ramgrpcod = 2 or
        g_documento.ramgrpcod = 4 or
        g_documento.ramgrpcod = 6 then  ##RE

        if param.ramcod    is not null  and
           param.succod    is not null  and
           param.aplnumdig is not null  then
           select sgrorg, sgrnumdig
             into ws.sgrorg, ws.sgrnumdig
             from rsamseguro
            where succod    =  param.succod     and
                  ramcod    =  param.ramcod     and
                  aplnumdig =  param.aplnumdig

           if sqlca.sqlcode <> 0  then
              error "Erro (", sqlca.sqlcode, ") na localizacao do seguro ",
                    "(RAMOS ELEMENTARES). AVISE A INFORMATICA!"
              initialize retorno.*  to null
              return retorno.*
           end if

           select segnumdig
             into ws.segnumdig
             from rsdmdocto
            where prporg    = ws.sgrorg     and
                  prpnumdig = ws.sgrnumdig

           if sqlca.sqlcode <> 0  then
              error " Erro (", sqlca.sqlcode, ") na localizacao do documento",
                    " (RAMOS ELEMENTARES). AVISE A INFORMATICA!"
              initialize retorno.*  to null
              return retorno.*
           end if
        end if
     end if

     if g_documento.ramgrpcod = 1 or    ## Auto
        g_documento.ramgrpcod = 2 or
        g_documento.ramgrpcod = 4 or
        g_documento.ramgrpcod = 6 then  ##RE

        select segnom into ws.segnom from gsakseg
               where segnumdig = ws.segnumdig

        select dddcod, teltxt into ws.dddcod, ws.teltxt from gsakend
               where segnumdig = ws.segnumdig
                and endfld    = "1"
   end if
 end if

 if g_documento.ramgrpcod = 5 then ## Saude
    ## obter o nome, ddd e telefone do segurado
    call cta01m15_sel_datksegsau(3, g_documento.crtsaunum, '','','')
         returning l_status, l_msg, ws.segnom, ws.dddcod, ws.teltxt

 end if

 if g_documento.ramgrpcod = 3 then ## Vida - VEP

    if (m_segnom is not null and
        m_segnom <> '')      and
       (m_segnumdig is null  or
        m_segnumdig = 0    ) then
        let ws.segnom = m_segnom
    else
       if m_segnumdig is not null and
          m_segnumdig > 0         then

          select segnom into ws.segnom from gsakseg
           where segnumdig = m_segnumdig

          select dddcod, teltxt into ws.dddcod, ws.teltxt from gsakend
           where segnumdig = m_segnumdig
             and endfld    = "1"

       end if
    end if

 end if

 if g_documento.ciaempcod = 84 then
    let ws.dddcod    = g_doc_itau[1].segresteldddnum
    let ws.teltxt    = g_doc_itau[1].segrestelnum
    let ws.vcllicnum = g_doc_itau[1].autplcnum
    let ws.segnom    = g_doc_itau[1].segnom
 end if

 if g_documento.ciaempcod = 35 then
 	  call cts42g00_doc_handle(g_documento.succod,
 	                           g_documento.ramcod,
 	                           g_documento.aplnumdig,
 	                           g_documento.itmnumdig,
 	                           g_documento.edsnumref)
 	  returning lr_retorno.resultado  ,
 	            lr_retorno.mensagem   ,
 	            lr_retorno.doc_handle
 	  call cts38m00_extrai_dados_seg(lr_retorno.doc_handle)
 	  returning ws.segnom ,
 	            ws.teltxt
 	  call cts38m00_extrai_dados_veicul(lr_retorno.doc_handle)
 	      returning lr_retorno.vclmrcnom,
 	                lr_retorno.vcltipnom,
 	                lr_retorno.vclmdlnom,
 	                lr_retorno.vclchs   ,
 	                ws.vcllicnum        ,
                  lr_retorno.vclanofbc,
                  lr_retorno.vclanomdl

 end if
 open c_cta04m00_001 using param.atdsrvnum
                          ,param.atdsrvano
 whenever error continue
 fetch c_cta04m00_001 into ws.c24pbmdes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let ws.c24pbmdes = null
    else
       error 'Erro SELECT c_cta04m00_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
       error 'cta04m00_msg() ',param.atdsrvnum,'/'
                              ,param.atdsrvano sleep 2
       initialize retorno to null
       return retorno.*
    end if
 end if

 if ws.teltxt     = " "     or
    ws.teltxt     is null   then
    initialize ws.dddcod  to null
    let ws.teltxt = "NAO INFORMADO NA APOLICE"
 end if

 let l_c24endtip = 1
 open c_cta04m00_002 using param.atdsrvnum
                          ,param.atdsrvano
                          ,l_c24endtip

 whenever error continue
 fetch c_cta04m00_002 into ws.lgdtip
                          ,ws.lgdnom
                          ,ws.lgdnum
                          ,ws.cidnom
                          ,ws.lclcttnom
                          ,ws.dddcod2
                          ,ws.lcltelnum
                          ,lr_lx.lclidttxt
                          ,ws.celteldddcod
                          ,ws.celtelnum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let ws.lgdtip       = null
       let ws.lgdnom       = null
       let ws.lgdnum       = null
       let ws.cidnom       = null
       let ws.lclcttnom    = null
       let ws.dddcod       = null
       let ws.lcltelnum    = null
    else
       error 'Erro SELECT c_cta04m00_002 /', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2]  sleep 2
       error 'CTA04M00 /cta04m00_msg() /', param.atdsrvnum, ' / '
                                         , param.atdsrvano, ' / '
                                         , l_c24endtip     sleep 2
       initialize retorno to null
       return retorno.*
    end if
 end if

 open c_cta04m00_003 using param.atdsrvnum
                          ,param.atdsrvano

 whenever error continue
 fetch c_cta04m00_003 into ws.asitipabvdes
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let ws.asitipabvdes = null
    else
       error 'Erro SELECT c_cta04m00_003 /', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2]  sleep 2
       error 'CTA04M00 /cta04m00_msg() /', param.atdsrvnum, ' / ', param.atdsrvano sleep 2
       initialize retorno to null
       return retorno.*
    end if
 end if

 let l_c24endtip = 2
 open c_cta04m00_002 using param.atdsrvnum
                          ,param.atdsrvano
                          ,l_c24endtip
 whenever error continue
 fetch c_cta04m00_002 into ws.lgdtip2
                          ,ws.lgdnom2
                          ,ws.lgdnum2
                          ,lr_lx.cidnom
                          ,lr_lx.lclcttnom
                          ,lr_lx.dddcod
                          ,lr_lx.lcltelnum
                          ,ws.lclidttxt
                          ,ws.celteldddcod
                          ,ws.celtelnum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let ws.lgdtip2      = null
       let ws.lgdnom2      = null
       let ws.lgdnum2      = null
       let ws.lclidttxt    = null
    else
       error 'Erro SELECT c_cta04m00_002 /', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2]  sleep 2
       error 'CTA04M00 /cta04m00_msg() /', param.atdsrvnum, ' / '
                                         , param.atdsrvano, ' / '
                                         , l_c24endtip     sleep 2
       initialize retorno to null
       return retorno.*
    end if
 end if
 ### PSI 202720
 # Monta o Cabecalho da Mensagem
 call cta04m00_monta_cabecalho(param.c24funmat       ,
                               param.c24astcod       ,
                               param.ramcod          ,
                               param.succod          ,
                               param.aplnumdig       ,
                               param.itmnumdig       )
 returning l_apl
   if g_terceiro.terceiro = 'S' then
      call cta04m00_monta_mensagem_terceiro(l_apl   ,
                                            g_terceiro.nom,
                                            param.c24solnom,
                                            g_terceiro.vcllicnum,
                                            ws.dddcod       ,
                                            ws.teltxt       ,
                                            ws.c24astdes    ,
                                            ws.c24pbmdes    ,
                                            ws.lgdtip       ,
                                            ws.lgdnom       ,
                                            ws.lgdnum       ,
                                            ws.cidnom       ,
                                            ws.lclcttnom    ,
                                            ws.dddcod2      ,
                                            ws.lcltelnum    ,
                                            ws.asitipabvdes ,
                                            ws.lclidttxt    ,
                                            ws.lgdtip2      ,
                                            ws.lgdnom2      ,
                                            ws.lgdnum2)
         returning retorno.msgtxt
   else
       # Monta o Corpo da Mensagem
      call cta04m00_monta_mensagem(l_apl           ,
                                   ws.segnom       ,
                                   param.c24solnom ,
                                   ws.vcllicnum    ,
                                   ws.dddcod       ,
                                   ws.teltxt       ,
                                   ws.c24astdes    ,
                                   ws.c24pbmdes    ,
                                   ws.lgdtip       ,
                                   ws.lgdnom       ,
                                   ws.lgdnum       ,
                                   ws.cidnom       ,
                                   ws.lclcttnom    ,
                                   ws.dddcod2      ,
                                   ws.lcltelnum    ,
                                   ws.asitipabvdes ,
                                   ws.lclidttxt    ,
                                   ws.lgdtip2      ,
                                   ws.lgdnom2      ,
                                   ws.lgdnum2      )
       returning retorno.msgtxt
       call cta04m00_telefone(ws.dddcod        ,
                              ws.teltxt        ,
                              ws.dddcod2       ,
                              ws.lcltelnum     ,
                              ws.celteldddcod  ,
                              ws.celtelnum     )
       returning ws.dddcod,
                 ws.teltxt
       # Monta as Mensagens para SMS
       call cta04m00_monta_mensagem_sms(param.succod     ,
                                        param.ramcod     ,
                                        param.aplnumdig  ,
                                        param.itmnumdig  ,
                                        ws.segnom        ,
                                        ws.dddcod        ,
                                        ws.teltxt        ,
                                        ws.c24astdes     )
       returning retorno.msgtxtsms
  end if
    return retorno.*

end function  ###  cta04m00_msg

#------------------------------------------------------------------------------
 function cta04m00_infochuva(param)
#------------------------------------------------------------------------------

   define param record
      atdsrvnum    like datmligacao.atdsrvnum,
      atdsrvano    like datmligacao.atdsrvano,
      ligdat       like datmligacao.ligdat,
      lighorinc    like datmligacao.lighorinc,
      c24astcod    like datkassunto.c24astcod,
      lignum       like datmligacao.lignum
   end record
   define ws    record
      lgdtip       like datmlcl.lgdtip,
      lgdnom       like datmlcl.lgdnom,
      lgdnum       like datmlcl.lgdnum,
      lclbrrnom    like datmlcl.lclbrrnom,
      brrnom       like datmlcl.brrnom,
      cidnom       like datmlcl.cidnom,
      ufdcod       like datmlcl.ufdcod,
      endzon       like datmlcl.endzon,
      lclrefptotxt like datmlcl.lclrefptotxt,
      errcod       smallint,
      sqlcod       integer ,
      mstnum       like htlmmst.mstnum,
      ligdat       like datmligacao.ligdat,
      lighorinc    like datmligacao.lighorinc,
      resdat       integer,
      reshor       interval hour(06) to minute,
      chrhor       char (07),
      endereco     char (360),
      mstastdes    like htlmmst.mstastdes ,
      sindat       like datmservicocmp.sindat,
      sinhor       like datmservicocmp.sinhor,
      ok           char(01),
      email        char(800),
      assunto      char(20) ,
      c24astdes    like datkassunto.c24astdes,
      msg          char (300),
      msgm       char (01),
      ext          char (04),
      c24trxnum    like dammtrx.c24trxnum,
      lintxt       like dammtrxtxt.c24trxtxt
    end record
    define a_cta04m00 array[15] of record
           ustcod       like htlrust.ustcod
    end record
    define arr_aux   integer


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  15
		initialize  a_cta04m00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

    initialize ws.* to null
    let ws.ok   =  "S"
    let arr_aux =   0

    select lgdtip,
           lgdnom,
           lgdnum,
           lclbrrnom,
           brrnom,
           cidnom,
           ufdcod,
           endzon,
           lclrefptotxt
        into
           ws.lgdtip,
           ws.lgdnom,
           ws.lgdnum,
           ws.lclbrrnom,
           ws.brrnom,
           ws.cidnom,
           ws.ufdcod,
           ws.endzon,
           ws.lclrefptotxt
        from datmlcl
       where atdsrvnum = param.atdsrvnum
         and atdsrvano = param.atdsrvano
         and c24endtip = 1
    if sqlca.sqlcode <> 0  then
       let ws.lgdnom = "PROB. NO ACESSO (datmlcl), AVISE INFORMATICA "
       return
    end if
    if ws.ufdcod  <> "SP"   then
       return
    end if
    select sindat,sinhor
         into ws.sindat,
              ws.sinhor
         from datmservicocmp
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
    if sqlca.sqlcode <> 0  then
       error "PROB. NO ACESSO (datmservicocmp), AVISE INFORMATICA"
       return
    end if
    let ws.resdat = (param.ligdat    - ws.sindat) * 24
    let ws.reshor = (param.lighorinc - ws.sinhor)
    let ws.chrhor = ws.resdat using "###&" , ":00"
    let ws.reshor = ws.reshor + ws.chrhor
    if  ws.reshor >  "2:00" then # passou para 2hr conforme eduardo oriente
        return                   # 10/01/2001.
    end if
    select c24astdes
       into ws.c24astdes
       from datkassunto
      where c24astcod = param.c24astcod

    #--------------------- gera arquivo para e-email/pager ------------------
    let ws.mstastdes= "INFO CHUVA"
    let ws.endereco = "CENTRAL 24HRS INFORMA - ALAGAMENTO...",
                      param.ligdat    clipped, " ",
                      param.lighorinc clipped, " ",
                      ws.lgdtip  clipped, " ",
                      ws.lgdnom  clipped, ",",
                      ws.lgdnum  using "<<<<", " - ",
                      ws.brrnom  clipped, " - ",
                      ws.lclbrrnom clipped, " - ",
                      ws.cidnom  clipped, " / ",
                      ws.ufdcod  clipped, "  ZONA:",
                      ws.endzon  clipped, "  REF:",
                      ws.lclrefptotxt[1,90] clipped, "  CODIGO:",
                      param.c24astcod clipped, "-",
                      ws.c24astdes clipped, "  SERVICO:",
                      param.atdsrvnum using "&&&&&&&","-",
                      param.atdsrvano using "&&","."
    call ctx14g00_msg(1              , # codigo da msg
                      param.lignum   , # ligacao
                      param.atdsrvnum, # servico
                      param.atdsrvano, # ano do servico
                      ws.mstastdes   ) # titulo
          returning ws.c24trxnum
    let ws.lintxt   = "CENTRAL 24HRS INFORMA - ALAGAMENTO...",
                      param.ligdat clipped, " ",
                      param.lighorinc clipped, " ",
                      ws.lgdtip  clipped, " "
    call ctx14g00_msgtxt(ws.c24trxnum,ws.lintxt)
    let ws.lintxt   = ws.lgdnom  clipped, ",",
                      ws.lgdnum  using "<<<<", " - "
    call ctx14g00_msgtxt(ws.c24trxnum,ws.lintxt)
    let ws.lintxt   = ws.brrnom  clipped, " - ",
                      ws.lclbrrnom clipped, " - "
    call ctx14g00_msgtxt(ws.c24trxnum,ws.lintxt)
    let ws.lintxt   = ws.cidnom  clipped, " / ",
                      ws.ufdcod  clipped, "  ZONA:",
                      ws.endzon  clipped
    call ctx14g00_msgtxt(ws.c24trxnum,ws.lintxt)
    let ws.lintxt   = "REF: ",ws.lclrefptotxt[1,75] clipped
    call ctx14g00_msgtxt(ws.c24trxnum,ws.lintxt)
    let ws.lintxt   = ws.lclrefptotxt[76,90] clipped," CODIGO:",
                      param.c24astcod clipped, "-",
                      ws.c24astdes clipped
    call ctx14g00_msgtxt(ws.c24trxnum,ws.lintxt)
    let ws.lintxt   = "SERVICO: ",
                      param.atdsrvnum using "&&&&&&&","-",
                      param.atdsrvano using "&&","."
    call ctx14g00_msgtxt(ws.c24trxnum,ws.lintxt)

   #let ws.ext = ".doc"
    let ws.ext = null
    let ws.email = "echo '",ws.endereco clipped,"', > ",
                    ws.c24trxnum using "&&&&&&&&",ws.ext
    run ws.email    # gera arquivo

{   #===== inibir estes end. conforme Willians da Somar - 09/08/02 - Ruiz ======
   call ctx14g00_msgdst(ws.c24trxnum,
                        "somar@somar.met.com.br",
                        "cta04m00",1) # 1-email
   call ctx14g00_msgdst(ws.c24trxnum,
                        "somar.meteorologia@globo.com",
                        "cta04m00",1) # 1-email
   #===========================================================================
   call ctx14g00_msgdst(ws.c24trxnum,
                        "ruiz_carlos/spaulo_info_sistemas@u55",
                        "cta04m00",1) # 1-email}
    call ctx14g00_msgdst(ws.c24trxnum,
                         "somar@somarmeteorologia.com.br",
                         "cta04m00",1) # 1-email
    call ctx14g00_msgdst(ws.c24trxnum,
                         "infochuva@met.com.br",
                         "cta04m00",1) # 1-email
    call ctx14g00_msgdst(ws.c24trxnum,
                         "infochuva@weather.com.br",
                         "cta04m00",1) # 1-email
{    call ctx14g00_msgdst(ws.c24trxnum,
                         "Oliveira_milton/spaulo_psocorro_controles@u23",
                         "cta04m00",1) # 1-email
    call ctx14g00_msgdst(ws.c24trxnum,
                         "Oriente_Eduardo/spaulo_psocorro_controles@u23",
                         "cta04m00",1) # 1-email
    call ctx14g00_msgdst(ws.c24trxnum,
                         "Anselmo_Miriam/spaulo_ct24hs_teleatendimento@u55",
                         "cta04m00",1) # 1-email
    call ctx14g00_msgdst(ws.c24trxnum,
                         "ct24hs_Julio/spaulo_ct24hs_teleatendimento@u55",
                         "cta04m00",1) # 1-email
    call ctx14g00_msgdst(ws.c24trxnum,
                         "ct24hs_Guilherme/spaulo_ct24hs_teleatendimento@u55",
                         "cta04m00",1) # 1-email}
    update dammtrx
         set c24msgtrxstt = 9   # STATUS DE ENVIO
    where c24trxnum = ws.c24trxnum

 ## call ctx14g00_msgok(ws.c24trxnum)
    call ctx14g00_envia(ws.c24trxnum,ws.ext)

    #--------------------- envio de pager ---------------------------------
    for arr_aux = 1 to 15
        initialize a_cta04m00[arr_aux].* to null
    end for
    let arr_aux = 0
    let a_cta04m00[01].ustcod  =  2048  # 4033530 silmara
    let a_cta04m00[02].ustcod  =  5149  # 4179015 eduardo oriente
    let a_cta04m00[03].ustcod  =  5531  # 4359464
    let a_cta04m00[03].ustcod  =  5981  # 4362363 milton
    let a_cta04m00[04].ustcod  =  5994  # 4362331 milton
    let a_cta04m00[06].ustcod  =  5996  # 4362365 milton
    let a_cta04m00[07].ustcod  =  6003  # 4362378 milton
    let a_cta04m00[08].ustcod  =  6006  # 4362281 milton
    let a_cta04m00[09].ustcod  =  6013  # 4362285 milton
    let a_cta04m00[10].ustcod  =  6014  # 4362295 milton
#   let a_cta04m00[11].ustcod  =  7317  # 4384018 milton
    let a_cta04m00[11].ustcod  =  9999
    whenever error continue
    while true
      let arr_aux = arr_aux + 1
      if a_cta04m00[arr_aux].ustcod  = 9999  then
         exit while
      end if
      begin work
      call fptla025_usuario(a_cta04m00[arr_aux].ustcod,
                            ws.mstastdes   ,
                            ws.endereco    ,
                            g_issk.funmat  ,
                            g_issk.empcod  ,
                            false,       ###  Nao controla transacoes
                            "O",         ###  Online
                            "M",         ###  Mailtrim
                            "",          ###  Data Transmissao
                            "",          ###  Hora Transmissao
                            g_issk.maqsgl)  ###  Maquina de aplicacao
                returning ws.errcod,
                          ws.sqlcod,
                          ws.mstnum
      if ws.errcod >= 5  then
         error "Erro(",ws.sqlcod,") no Teletrim",
               " CTA04M00-infochuva.AVISE A INFORMATICA!"
         rollback work
         let ws.msg = "CTA04m00-PROBL.ROTINA INFOCHUVA-fptla025_usuario",
                      ascii(10),
                      "errcod=",ws.errcod," sqlcod=",ws.sqlcod,
                      " ustcod=",a_cta04m00[arr_aux].ustcod,
                      ascii(10),
                      "---------------------------------------------"
         call errorlog(ws.msg)
         prompt "" for char ws.msgm
      else
         commit work
        {let ws.msg = "-------- CTA04M00-infochuva msg ok -------------------",
                      ascii(10),
                     " pager n.o    ",a_cta04m00[arr_aux].ustcod,
                      ascii(10),
                     " mensagem n.o ",ws.mstnum,
                      ascii(10),
                     " errcod =",ws.errcod," sqlcod =",ws.sqlcod,
                      ascii(10),
                     "------------------------------------------------------"
        call errorlog(ws.msg)}

      end if
    end while
    whenever error stop
    return
end function

# exemplo:
#PAGER  - PORTO SEGURO CT24H INFORMA: Apolice: 01/ 531/19214134/19 Segurado: JOH
#ANES BAYER Solicitante: RUIZZZZZZZZZ Placa  : ALE2006 Telefone: 11 33666541 Oco
#rrencia: PORTO SOCORRO ENVIO DE SOCORRO Tipo do problema:LOCAL DE DIFICIL ACESS
#O Local da Ocorrencia: R CAMPOS DE MESQUITA    93 Cidade: SAO PAULO Contato: RU
#IZ Fone no Local: 11    33666541 Tipo de Assistencia: CHAVAUTO Destino:
#  Informacoes: ligue (11) 3366-3155
#
# SMS - PORTO SEGURO INF: Apl: 01/ 531/01/19214134/19 Seg:JOHANES BAYER
#       Tel:11   33666541 Ocorr:PORTO SOCORRO ENVIO DE SOCORRO

#-------------------------------------------------
function cta04m00_monta_cabecalho(lr_param)
#-------------------------------------------------

define lr_param record
    c24funmat   like datmligacao.c24funmat   ,
    c24astcod   like datkassunto.c24astcod   ,
    ramcod      like datrservapol.ramcod     ,
    succod      like datrservapol.succod     ,
    aplnumdig   like datrservapol.aplnumdig  ,
    itmnumdig   like datrservapol.itmnumdig
end record

define lr_retorno record
    cabecalho char(100)
end record

initialize lr_retorno.*  to null

   if g_documento.ciaempcod = 84 then

      let lr_retorno.cabecalho = "ITAU SEGUROS CT24H INFORMA: Apolice: "

      let lr_retorno.cabecalho = lr_retorno.cabecalho clipped                  ,
                                 g_documento.itaciacod using "&&"        , "/" ,
                                 lr_param.succod       using "<<<&&"     , "/" ,
                                 lr_param.ramcod       using "<<&&"      , "/" ,
                                 lr_param.aplnumdig    using "<<<<<<<&&" , "/" ,
                                 lr_param.itmnumdig    using "<<<<<&&"
   else
      if g_documento.ciaempcod = 35 then
         let lr_retorno.cabecalho = "AZUL SEGUROS CT24H INFORMA: Apolice: "
         let lr_retorno.cabecalho = lr_retorno.cabecalho clipped                  ,
                                    lr_param.succod       using "<<<&&"     , "/" ,
                                    lr_param.ramcod       using "<<&&"      , "/" ,
                                    lr_param.aplnumdig    using "<<<<<<<&&" , "/" ,
                                    lr_param.itmnumdig    using "<<<<<&&"
      else

          if g_documento.ramgrpcod = 5 then # Saude
             let lr_retorno.cabecalho = "PORTO SEGURO CT24H INFORMA: Cartao Saude: ",
                                        g_documento.crtsaunum clipped
          else
             if lr_param.c24funmat = 999999 and  # Ligacao Via Portal do Segurado
               (lr_param.c24astcod = "B01"  or   # Assunto do Portal do Segurado
                lr_param.c24astcod = "B12"  or
                lr_param.c24astcod = "B21" )then
                   let lr_retorno.cabecalho = "PORTAL DO CLIENTE INFORMA: Apolice: "
             else
                   let lr_retorno.cabecalho = "PORTO SEGURO CT24H INFORMA: Apolice: "
             end if
             let lr_retorno.cabecalho = lr_retorno.cabecalho clipped           ,
                                        lr_param.succod using "<<<&&", "/"           , #"&&", "/" , #projeto succod
                                        lr_param.ramcod using "##&&", "/"         ,
                                        lr_param.aplnumdig using "<<<<<<<&&", "/"
             # Se for diferente de RE incluo o Item da Apolice
             if g_documento.ramgrpcod <>  2 and
                g_documento.ramgrpcod <>  4 and
                g_documento.ramgrpcod <>  6 then # RE
                   let lr_retorno.cabecalho = lr_retorno.cabecalho clipped  ,
                                              lr_param.itmnumdig using "<<<<<&&"
             end if
          end if
      end if
   end if

   return lr_retorno.cabecalho

end function

#-------------------------------------------------
function cta04m00_monta_mensagem(lr_param)
#-------------------------------------------------

define lr_param record
        cabecalho    char(100)                    ,
        segnom       char (40)                    ,
        c24solnom    like datmligacao.c24solnom   ,
        vcllicnum    char(08)                     ,
        dddcod       like gsakend.dddcod          ,
        teltxt       char (26)                    ,
        c24astdes    char (72)                    ,
        c24pbmdes    like datrsrvpbm.c24pbmdes    ,
        lgdtip	     like datmlcl.lgdtip          ,
        lgdnom	     like datmlcl.lgdnom          ,
        lgdnum	     like datmlcl.lgdnum          ,
        cidnom	     like datmlcl.cidnom          ,
        lclcttnom    like datmlcl.lclcttnom       ,
        dddcod2	     like datmlcl.dddcod          ,
        lcltelnum    like datmlcl.lcltelnum       ,
        asitipabvdes like datkasitip.asitipabvdes ,
        lclidttxt    like datmlcl.lclidttxt       ,
        lgdtip2	     like datmlcl.lgdtip          ,
        lgdnom2      like datmlcl.lgdnom          ,
        lgdnum2	     like datmlcl.lgdnum
end record

define lr_retorno record
    mensagem char (620)
end record
initialize lr_retorno.*  to null
    let lr_retorno.mensagem =                  lr_param.cabecalho clipped, "<br>",
                              "Segurado: "   , lr_param.segnom    clipped, "<br>",
                              "Solicitante: ", lr_param.c24solnom clipped, "<br>"
    if lr_param.vcllicnum is not null and
       lr_param.vcllicnum <> " "      then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Placa   : ", lr_param.vcllicnum  clipped, "<br>"
    end if
    if lr_param.teltxt is not null and
       lr_param.teltxt <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Telefone: "   , lr_param.dddcod    clipped, " ",
                                                  lr_param.teltxt    clipped, "<br>"
    end if
    if lr_param.c24astdes is not null and
       lr_param.c24astdes <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Ocorrencia: " , lr_param.c24astdes clipped, "<br>"
    end if
    if lr_param.c24pbmdes is not null and
       lr_param.c24pbmdes <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Tipo do Problema: ", lr_param.c24pbmdes clipped, "<br>"
    end if
    if lr_param.lgdnom is not null and
       lr_param.lgdnom <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Local da Ocorrencia: ", lr_param.lgdtip clipped, " " ,
                                                          lr_param.lgdnom clipped, " " ,
                                                          lr_param.lgdnum clipped, "<br>"
    end if
    if lr_param.cidnom is not null and
       lr_param.cidnom <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Cidade: ", lr_param.cidnom clipped, "<br>"
    end if
    if lr_param.lclcttnom is not null and
       lr_param.lclcttnom <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Contato: ", lr_param.lclcttnom clipped, "<br>"
    end if
    if lr_param.lcltelnum is not null and
       lr_param.lcltelnum <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Fone no Local: ", lr_param.dddcod2
                                                  , lr_param.lcltelnum clipped, "<br>"
    end if

     {Retirado a pedido do vinicius henrique 23/07/2012( Email do Sr. mendonça)
    if lr_param.asitipabvdes is not null and
       lr_param.asitipabvdes <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Tipo de Assistencia: ", lr_param.asitipabvdes clipped, "<br>"
    end if}
    if lr_param.lgdnom2 is not null and
       lr_param.lgdnom2 <> " "       then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Destino: ", lr_param.lclidttxt clipped, " "
                                            , lr_param.lgdtip2   clipped, " "
                                            , lr_param.lgdnom2   clipped, " "
                                            , lr_param.lgdnum2   clipped, "<br>"
    end if
    if g_documento.ciaempcod = 84 then
       let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                 "Informacoes: ligue (11) 3003-1010" clipped
    else
    	 if g_documento.ciaempcod = 35 then
    	 	  let lr_retorno.mensagem = lr_retorno.mensagem clipped,
    	 	                            "Informacoes ligue 0300 123 2985 ou 4004 3700" clipped
    	 else
          let lr_retorno.mensagem = lr_retorno.mensagem clipped,
                                    "Informacoes: ligue (11) 3366-3155" clipped
       end if
    end if
    return   lr_retorno.mensagem
end function

#-------------------------------------------------
function cta04m00_monta_mensagem_sms(lr_param)
#-------------------------------------------------

define lr_param record
    succod      like datrservapol.succod     ,
    ramcod      like datrservapol.ramcod     ,
    aplnumdig   like datrservapol.aplnumdig  ,
    itmnumdig   like datrservapol.itmnumdig  ,
    segnom      char (40)                    ,
    dddcod      like gsakend.dddcod          ,
    teltxt      char (26)                    ,
    c24astdes   char (72)
end record

define lr_retorno record
    mensagem char (143)
end record

initialize lr_retorno.*  to null

      if g_documento.ciaempcod = 84 then

          let lr_retorno.mensagem = "ITAU SEGUROS INF: Apl: ",
                                    g_documento.itaciacod using "&&",     "/",
                                    lr_param.ramcod using "##&&",         "/",
                                    lr_param.aplnumdig using "<<<<<<<&&", "/",
                                    lr_param.itmnumdig using "<<<<<&&"
      else
         if g_documento.ciaempcod = 35 then
            let lr_retorno.mensagem =  "AZUL SEGUROS INF: Apl: ",
                                       lr_param.succod       using "<<<&&"     , "/" ,
                                       lr_param.ramcod       using "<<&&"      , "/" ,
                                       lr_param.aplnumdig    using "<<<<<<<&&" , "/" ,
                                       lr_param.itmnumdig    using "<<<<<&&"
         else
            let lr_retorno.mensagem = "PORTO SEGURO INF: Apl: ",
                                      lr_param.succod using "<<<&&", "/",  #"&&", "/",   #projeto succod
                                      lr_param.ramcod using "##&&", "/",
                                      lr_param.aplnumdig using "<<<<<<<&&", "/"

            # Se for diferente de RE incluo o Item da Apolice
            if g_documento.ramgrpcod <>  2 and
               g_documento.ramgrpcod <>  4 and
               g_documento.ramgrpcod <>  6 then # RE
                  let lr_retorno.mensagem = lr_retorno.mensagem clipped  ,
                                            lr_param.itmnumdig using "<<<<<&&"
            end if
         end if
      end if

      let lr_retorno.mensagem = lr_retorno.mensagem clipped          ,
                                 " Seg:", lr_param.segnom[1,29]       ,
                                 " Tel:", lr_param.dddcod[1,4], " "   ,
                                 lr_param.teltxt[1,9],  ## Anatel - [1,8]                 ,
                                 " Ocorr:", lr_param.c24astdes[1,38]

      return  lr_retorno.mensagem

end function

#-----------------------------------------#
function cta04m00_envia_email(lr_param)
#-----------------------------------------#

   define lr_param  record
          assunto      char(100),
          msg          char(10000)
   end record

   define lr_cta04m00 record
          erro        smallint                     ,
          comando     char(15000)                  ,
          chave       like datkdominio.cponom      ,
          email       like datkdominio.cpodes      ,
          funmat      like isskfunc.funmat         ,
          codigo      char(200)                    ,
          remetentes  char(5000)                   ,
          email_itau  like datkdominio.cpodes      ,
          emaendnom   like datmmsgenvrst.emaendnom
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
   define l_erro  smallint
   define msg_erro char(500)

   initialize lr_cta04m00.* to null

   if g_documento.ciaempcod = 84 then
      let lr_cta04m00.chave = "email_itau_vip"
   else
      if m_cvnnum_itau = true          then
         let lr_cta04m00.chave = "email_susep_itau"
      else
         let lr_cta04m00.chave = "email_susep_func"
      end if
   end if

   if m_prep is null or
      m_prep <> true then
      call cta04m00_prepare()
   end if

   if m_cvnnum_itau = true or
      g_documento.ciaempcod = 84 then

       #--------------------------------------
       # BUSCA OS E-MAILS DO ITAU
       #--------------------------------------
       open ccta04m00005 using lr_cta04m00.chave
       foreach ccta04m00005 into lr_cta04m00.email_itau

          if lr_cta04m00.email_itau is null then  ## Nao achou email no RH, despreza
             continue foreach
          end if
          if lr_cta04m00.remetentes is null then
             let lr_cta04m00.remetentes = lr_cta04m00.email_itau
          else
             let lr_cta04m00.remetentes = lr_cta04m00.remetentes clipped, ",", lr_cta04m00.email_itau
          end if

       end foreach

       close ccta04m00005

       let lr_cta04m00.emaendnom = lr_cta04m00.email_itau

   else
      #--------------------------------------
      # BUSCA AS MATRICULAS P/ENVIO DE E-MAIL
      #--------------------------------------
      open ccta04m00005 using lr_cta04m00.chave
      foreach ccta04m00005 into lr_cta04m00.email

         if lr_cta04m00.remetentes is null then
            let lr_cta04m00.remetentes = lr_cta04m00.email
         else
            let lr_cta04m00.remetentes = lr_cta04m00.remetentes clipped, ",", lr_cta04m00.email
         end if
      end foreach
      close ccta04m00005

      let lr_cta04m00.emaendnom = lr_cta04m00.email

   end if

  #PSI-2013-23297 - Inicio
  let l_mail.de = "CT24HS"
  #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
  let l_mail.para = lr_cta04m00.remetentes
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = lr_param.assunto
  let l_mail.mensagem = lr_param.msg
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "html"
  call figrc009_mail_send1 (l_mail.*)
      returning l_erro,msg_erro
  #PSI-2013-23297 - Fim

   if g_documento.lignum is not null then

      call cts10g13_grava_rastreamento(g_documento.lignum     ,
                                       '1'                    ,
                                       'cta04m00'             ,
                                       '0'                    ,
                                       '22- Mensagem Enviada' ,
                                       lr_cta04m00.emaendnom   ) # Grava Somente o Ultimo E-mail

   end if

end function

#-----------------------------------------#
function cta04m00_verifica_convenio_itau()
#-----------------------------------------#

   define l_cvnnum  like abamapol.cvnnum
   let l_cvnnum = null
   if m_prep is null or
      m_prep = " " then
      call cta04m00_prepare()
   end if
   whenever error continue
   open ccta04m00006 using g_documento.succod,
                           g_documento.aplnumdig
   fetch ccta04m00006 into l_cvnnum
   whenever error stop
   close ccta04m00006
   # Verifica se o Convenio e do Itau
   if l_cvnnum = 105 then
      return true
   end if
   return false

end function

#---------------------------------------------------
function cta04m00_monta_mensagem_terceiro(lr_param)
#---------------------------------------------------
define lr_param record
        cabecalho    char(100)                    ,
        terceiro     char (40)                    ,
        c24solnom    like datmligacao.c24solnom   ,
        vcllicnum    char(08)                     ,
        dddcod       like gsakend.dddcod          ,
        teltxt       char (26)                    ,
        c24astdes    char (72)                    ,
        c24pbmdes    like datrsrvpbm.c24pbmdes    ,
        lgdtip	     like datmlcl.lgdtip          ,
        lgdnom	     like datmlcl.lgdnom          ,
        lgdnum	     like datmlcl.lgdnum          ,
        cidnom	     like datmlcl.cidnom          ,
        lclcttnom    like datmlcl.lclcttnom       ,
        dddcod2	     like datmlcl.dddcod          ,
        lcltelnum    like datmlcl.lcltelnum       ,
        asitipabvdes like datkasitip.asitipabvdes ,
        lclidttxt    like datmlcl.lclidttxt       ,
        lgdtip2	     like datmlcl.lgdtip          ,
        lgdnom2      like datmlcl.lgdnom          ,
        lgdnum2	     like datmlcl.lgdnum
end record
define lr_retorno1 record
       mensagem char (620)
end record
initialize lr_retorno1.*  to null
    let lr_retorno1.mensagem =                  lr_param.cabecalho clipped, "<br>",
                              "Terceiro: "   , lr_param.terceiro    clipped, "<br>",
                              "Solicitante: ", lr_param.c24solnom clipped, "<br>"
    if lr_param.vcllicnum is not null and
       lr_param.vcllicnum <> " "      then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Placa   : ", lr_param.vcllicnum  clipped, "<br>"
    end if
    {if lr_param.teltxt is not null and
       lr_param.teltxt <> " "       then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Telefone: "   , lr_param.dddcod    clipped, "-",
                                                  lr_param.teltxt    clipped, "<br>"
    end if}
    if lr_param.c24astdes is not null and
       lr_param.c24astdes <> " "       then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Ocorrencia: " , lr_param.c24astdes clipped, "<br>"
    end if
    if lr_param.c24pbmdes is not null and
       lr_param.c24pbmdes <> " "       then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Tipo do Problema: ", lr_param.c24pbmdes clipped, "<br>"
    end if
    if lr_param.lgdnom is not null and
       lr_param.lgdnom <> " "       then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Local da Ocorrencia: ", lr_param.lgdtip clipped, " " ,
                                                          lr_param.lgdnom clipped, " " ,
                                                          lr_param.lgdnum clipped, "<br>"
    end if
    if lr_param.cidnom is not null and
       lr_param.cidnom <> " "       then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Cidade: ", lr_param.cidnom clipped, "<br>"
    end if
    if lr_param.lclcttnom is not null and
       lr_param.lclcttnom <> " "       then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Contato: ", lr_param.lclcttnom clipped, "<br>"
    end if
    if lr_param.lcltelnum is not null and
       lr_param.lcltelnum <> " "       then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Fone no Local: ", lr_param.dddcod2
                                                  , lr_param.lcltelnum clipped, "<br>"
    end if
    if lr_param.lgdnom2 is not null and
       lr_param.lgdnom2 <> " "       then
       let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                 "Destino: ", lr_param.lclidttxt clipped, " "
                                            , lr_param.lgdtip2   clipped, " "
                                            , lr_param.lgdnom2   clipped, " "
                                            , lr_param.lgdnum2   clipped, "<br>"
    end if
       if g_documento.ciaempcod = 84 then
          let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                    "Informacoes: ligue (11) 3003-1010" clipped
       else
       	  if g_documento.ciaempcod = 35 then
       	  	  let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
       	  	                             "Informacoes ligue 0300 123 2985 ou 4004 3700" clipped
       	  else
              let lr_retorno1.mensagem = lr_retorno1.mensagem clipped,
                                        "Informacoes: ligue (11) 3366-3155" clipped
          end if
       end if
    return   lr_retorno1.mensagem
end function
#========================================================================
 function cta04m00_telefone(lr_param)
#========================================================================
define lr_param record
	ddd 	       like datmlcl.dddcod       ,
	telnum	     like datmlcl.lcltelnum    ,
	dddcod 	     like datmlcl.dddcod       ,
  lcltelnum	   like datmlcl.lcltelnum    ,
  celteldddcod like datmlcl.celteldddcod ,
  celtelnum    like datmlcl.celtelnum
end record
define lr_retorno record
	  dddcod      like gsakend.dddcod      ,
    teltxt      char (26)
end record
initialize lr_retorno.* to null
    let lr_retorno.dddcod = lr_param.ddd
    let lr_retorno.teltxt = lr_param.telnum
    if lr_param.celteldddcod is not null and
    	 lr_param.celtelnum    is not null then
         let lr_retorno.dddcod = lr_param.celteldddcod
         let lr_retorno.teltxt = lr_param.celtelnum
    else
       if lr_param.dddcod     is not null and
       	  lr_param.lcltelnum	is not null then
          let lr_retorno.dddcod = lr_param.dddcod
          let lr_retorno.teltxt = lr_param.lcltelnum
       end if
    end if
    return lr_retorno.dddcod,
           lr_retorno.teltxt
#========================================================================
end function
#========================================================================