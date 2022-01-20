#############################################################################
# Nome do Modulo: CTN18C00                                         Marcelo  #
#                                                                  Gilberto #
# Consulta lojas para locacao de veiculos - CARRO EXTRA            Ago/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 06/10/1998  PSI 7056-4   Gilberto     Incluir parametro CLAUSULA.         #
#                                       Alterar situacao da loja de (A)tiva #
#                                       ou (C)ancelada para codificacao nu- #
#                                       merica: (1)Ativa;     (2)Bloqueada; #
#                                               (3)Cancelada; (4)Desativada #
#---------------------------------------------------------------------------#
# 03/02/1999  PSI 7670-8   Wagner       Permitir visualizar loja com        #
#                                       situacao 2-bloqueada desde que a    #
#                                       mesma nao esteja com periodo vigente#
#---------------------------------------------------------------------------#
# 11/03/1999  PSI 7954-5   Wagner       Permitir visualizar loja com        #
#                                       situacao 2-bloqueada destacando o   #
#                                       periodo do bloqueio.                #
#---------------------------------------------------------------------------#
# 20/07/1999  PSI 8644-4   Wagner       Incluir o campo Cheque caucao no    #
#                                       cadastramento e atualizacao.        #
#---------------------------------------------------------------------------#
# 26/07/1999  PSI 8645-2   Wagner       Incluir o campo Taxa de Seguro no   #
#                                       cadastramento e atualizacao.        #
#---------------------------------------------------------------------------#
# 15/08/2000  PSI 11275-5  Wagner       Mudar acesso campo Ch.caucao da     #
#                                       tabela datklocadora para a tabela   #
#                                       datkavislocal.                      #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 24/11/2003  Paula Romanini      PSI.177911 Qualificação para seleção de   #
#                                 OSF29130   locadora                       #
# 13/01/2004                                 Inclusao da tecla de funcao F5 #
#---------------------------------------------------------------------------#
# 22/06/2004  OSF 37184    Teresinha S. Inibição da locadora Localiza para  #
#                                       motivo particular                   #
#---------------------------------------------------------------------------#
# 20/02/2006  PSI 198390   Priscila     Melhoria Carro extra - inclusao     #
#                                       campo local de entrega. Alteracao   #
#                                       filtro, acrescentar no filtro as    #
#                                       lojas q entregam na cidade          #
#---------------------------------------------------------------------------#
# 28/11/2006 Priscila          PSI205206  Passar empresa para ctn17c00 e    #
#                                        alterar parametros de entrada para #
#                                        receber empresa, input da empresa  #
#---------------------------------------------------------------------------#
# 17/08/2010  PSI-2012-31349EV Burini  Inclusão do relacionamento de        #
#                                      LOJA x EMPRESA                       #
#---------------------------------------------------------------------------#
#############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 database porto

 define g_pesquisa smallint
 define m_referencia char(255)
#------------------------------------------------------------------------
 function ctn18c00(param)
#------------------------------------------------------------------------

 define param      record
    lcvcod         like datklocadora.lcvcod,
    endcep         like glaklgd.lgdcep,
    endcepcmp      like glaklgd.lgdcepcmp,         #PSI 198390
    clscod         like datrclauslocal.clscod,
    diasem         smallint,
    psqtip         smallint,   { 0-Unica Locadora, 1-Todas Locadoras }
  # ofnatdflg      smallint                    -- OSF 37184
    avialgmtv      like datmavisrent.avialgmtv, -- OSF 37184
    ciaempcod      like datravsemp.ciaempcod       #PSI 205206
 end record

 define retorno    record
    lcvcod         like datkavislocal.lcvcod,
    aviestcod      like datkavislocal.aviestcod,
    vclpsqflg      smallint,
    psqflg         smallint
 end record

 initialize retorno to null
 open window w_ctn18c00 at 04,02 with form "ctn18c00"
             attribute(form line first)

 let g_pesquisa = 0

 menu "CARRO EXTRA - LOJAS"


    command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
       if param.endcep is null     then
          error " Nenhum CEP selecionado!"
          next option "Encerra"
       else
          let g_pesquisa = 0
          call pesquisa_ctn18c00(param.*) returning retorno.*

          let param.lcvcod = retorno.lcvcod


          if retorno.psqflg = true  then
             next option "Encerra"
          end if
       end if

       if retorno.aviestcod is not null  then
          exit menu
       end if

    command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
       exit menu
 end menu

 close window w_ctn18c00

 return retorno.lcvcod thru retorno.vclpsqflg

end function  ###  ctn18c00

#------------------------------------------------------------------------
 function pesquisa_ctn18c00(param)
#------------------------------------------------------------------------

 define param      record
    lcvcod         like datklocadora.lcvcod,
    endcep         like glaklgd.lgdcep,
    endcepcmp      like glaklgd.lgdcepcmp,       #PSI 198390
    clscod         like datrclauslocal.clscod,
    diasem         smallint,
    psqtip         smallint,
  # ofnatdflg      smallint                     -- OSF 37184
    avialgmtv      like datmavisrent.avialgmtv,  -- OSF 37184
    ciaempcod      like datravsemp.ciaempcod       #PSI 205206
 end record

 define d_ctn18c00 record
    loccod         like datkavislocal.lcvcod      ,
    locnom         like datklocadora.lcvnom       ,
    ciaempcod      like datravsemp.ciaempcod      ,   #PSI 205206
    empsgl         like gabkemp.empsgl                #PSI 205206
 end record

 define a_ctn18c00 array[1000] of record
    lcvnom         like datklocadora.lcvnom       ,
    lcvextcod      like datkavislocal.lcvextcod   ,
    lojqlfdes      char(12)                       ,
    endlgd         like datkavislocal.endlgd      ,
    endcep         like datkavislocal.endcep      ,
    endcepcmp      like datkavislocal.endcepcmp   ,
    lcvlojtipdes   char (13)                      ,
    endbrr         like datkavislocal.endbrr      ,
    endcid         like datkavislocal.endcid      ,
    entrega        char(1)                        ,  #PSI 198390
    dddcod         like datkavislocal.dddcod      ,
    teltxt         like datkavislocal.teltxt      ,
    facnum         like datkavislocal.facnum      ,
    lcvcod         like datklocadora.lcvcod       ,
    aviestcod      like datkavislocal.aviestcod
 end record

 define a_ctn18c00_aux array[1000] of record
    horario        char(80)
 end record

 define l_ctn18c00 record
    lcvnom         like datklocadora.lcvnom       ,
    lcvextcod      like datkavislocal.lcvextcod   ,
    lojqlfcod      like datkavislocal.lojqlfcod   ,
    endlgd         like datkavislocal.endlgd      ,
    endcep         like datkavislocal.endcep      ,
    endcepcmp      like datkavislocal.endcepcmp   ,
    lcvlojtipdes   char (13)                      ,
    endbrr         like datkavislocal.endbrr      ,
    endcid         like datkavislocal.endcid      ,
    entrega        char(1)                        ,  #PSI 198390
    dddcod         like datkavislocal.dddcod      ,
    teltxt         like datkavislocal.teltxt      ,
    facnum         like datkavislocal.facnum      ,
    lcvcod         like datklocadora.lcvcod       ,
    aviestcod      like datkavislocal.aviestcod   ,
    lojqlfdes      char(12)                       ,
    horario        char(80)
 end record

 define arr_aux    smallint
       ,scr_aux    smallint

 define retorno    record
    lcvcod         like datkavislocal.lcvcod,
    aviestcod      like datkavislocal.aviestcod,
    vclpsqflg      smallint,
    psqflg         smallint
 end record

 define ws         record
    sql            char (1000),
    endufd         like datkavislocal.endufd      ,
    lcvstt         like datklocadora.lcvstt       ,
    vclalglojstt   like datkavislocal.vclalglojstt,
    viginc         like datklcvsit.viginc,
    vigfnl         like datklcvsit.vigfnl,
    endcep         char (05),
    lcvlojtip      like datkavislocal.lcvlojtip
 end record

 define l_faixa2 char(01)
       ,l_curr  smallint  #paula
       ,l_line  smallint  #paula

 define l_avivclcod like datkavisveic.avivclcod

 define  w_pf1   integer

 define  l_aux    smallint,         #PSI 198390
         l_faixa1  char(1) ,
         l_msg     char(100),
         l_cidcod  like glakcid.cidcod,
         l_cidnom  like glakcid.cidnom,
         l_ufdcod  like glakcid.ufdcod
 define l_qtdeveic smallint     #PSI 205206

 let arr_aux     = null
 let l_avivclcod = null

 initialize a_ctn18c00,
            retorno,
            l_ctn18c00,
            d_ctn18c00,
            ws,
            a_ctn18c00_aux to null

 let int_flag = false

 if g_pesquisa = 0  then
    clear form
 end if


 #PSI 198390 - Buscar cidcod, cidnom e ufdcod atraves do cep
 if param.endcepcmp is null then
    let param.endcepcmp = 0
 end if
 call cty10g00_dados_cid(param.endcep, param.endcepcmp)
      returning l_aux, l_msg, l_cidcod, l_cidnom, l_ufdcod
      if l_aux <> 0 then
         error "Erro ao localizar cidcod para ",param.endcep, l_msg
         let l_cidnom = null
         let l_ufdcod = null
         let l_cidcod = null
      end if

 let ws.sql = "select lcvnom, lcvstt",
              "  from datklocadora  ",
              " where lcvcod = ?    "
 prepare sel_datklocadora from ws.sql
 declare c_datklocadora cursor for sel_datklocadora


  #PSI 205206 - permitir alteração (input) do campo empresa
  # apenas quando ciaempcod não veio preenchido
  # exibir empresa assim que abrir tela
  if param.ciaempcod is not null then
     let d_ctn18c00.ciaempcod = param.ciaempcod
     #Buscar descrição da empresa
     call cty14g00_empresa(1, d_ctn18c00.ciaempcod)
                 returning l_aux,
                           l_msg,
                           d_ctn18c00.empsgl
  else
      let d_ctn18c00.empsgl = "TODAS"
  end if
  display by name d_ctn18c00.ciaempcod,
                  d_ctn18c00.empsgl   attribute(reverse)


 input by name d_ctn18c00.loccod,
               d_ctn18c00.ciaempcod without defaults

    before field loccod
       if g_pesquisa > 0  then
          let d_ctn18c00.loccod = param.lcvcod

          if param.psqtip = 1  then
             let d_ctn18c00.locnom = "TODAS LOCADORAS"
          else
             if d_ctn18c00.loccod is null  then
                let d_ctn18c00.locnom = "TODAS LOCADORAS"
             else
                open  c_datklocadora using d_ctn18c00.loccod
                fetch c_datklocadora into  d_ctn18c00.locnom,
                                           ws.lcvstt
                close c_datklocadora
             end if
          end if

          display by name d_ctn18c00.*
          exit input
       end if

       if param.psqtip = 1  then
          let d_ctn18c00.locnom = "TODAS LOCADORAS"
          display by name d_ctn18c00.loccod   #PSI 205206
          display by name d_ctn18c00.locnom   #PSI 205206
          #exit input
          next field ciaempcod                #PSI 205206
       else
          if param.lcvcod is not null then
             let d_ctn18c00.loccod = param.lcvcod

             open  c_datklocadora using d_ctn18c00.loccod
             fetch c_datklocadora into  d_ctn18c00.locnom,
                                        ws.lcvstt
             if sqlca.sqlcode <> 0  then
                error " Locadora nao cadastrada!"
                next field loccod
             else
                if ws.lcvstt <> "A"  then
                   error " Locadora cancelada!"
                   next field loccod
                else
                   display by name d_ctn18c00.*
                end if
             end if
             close c_datklocadora

             exit input
          else
             display by name d_ctn18c00.loccod    attribute (reverse)
          end if
       end if

    after  field loccod
       display by name d_ctn18c00.loccod

       if d_ctn18c00.loccod is null  then
          let d_ctn18c00.locnom = "TODAS LOCADORAS"
          display by name d_ctn18c00.locnom
       else
            if param.avialgmtv = 3 or          -- Motivo Atendimento a Oficina
               param.avialgmtv = 6 then        -- Motivo Atendimento a Oficina
               if l_ctn18c00.lcvcod = 5  then  -- Mega Rent a Car
                  error "Locadora nao permitida para motivo ATENDIMENTO A "
                      , "OFICINA !"
                  next field loccod
               end if
            end if

           # QUEBRAR ESTA CRITICA - ROSANA MINCON - 16/05/06
           #if param.avialgmtv      = 5 then   -- Motivo Particular
           #   if l_ctn18c00.lcvcod = 2 then
           #      error "Locadora nao permitida para motivo PARTICULAR !"
           #      next field loccod
           #   end if
           #end if
           #-- OSF 37184 --

         #end if

          initialize d_ctn18c00.locnom to null

          open  c_datklocadora using d_ctn18c00.loccod
          fetch c_datklocadora into  d_ctn18c00.locnom,
                                     ws.lcvstt

          if sqlca.sqlcode <> 0  then
             error " Locadora nao cadastrada!"
             call ctc30m01() returning d_ctn18c00.loccod
             next field loccod
          else
             if ws.lcvstt <> "A"  then
                error " Locadora cancelada!"
                next field loccod
             else
                display by name d_ctn18c00.locnom
             end if
          end if
          close c_datklocadora
       end if

       let param.lcvcod = d_ctn18c00.loccod

    #PSI 205206
    before field ciaempcod
       if d_ctn18c00.ciaempcod is not null then
          #nao permite alteracao do campo empresa caso veio preenchido
          exit input
       end if
       display by name d_ctn18c00.ciaempcod attribute (reverse)
    after field ciaempcod
       if d_ctn18c00.ciaempcod is not null then
          #caso altere empresa Buscar descricao da empresa
          call cty14g00_empresa(1, d_ctn18c00.ciaempcod)
               returning l_aux,
                         l_msg,
                         d_ctn18c00.empsgl
          if l_aux <> 1 then
             #problemas ao buscar empresa
             error l_msg
             next field ciaempcod
          end if
       else
          let d_ctn18c00.empsgl = "TODAS"
       end if
       display by name d_ctn18c00.ciaempcod,
                       d_ctn18c00.empsgl   attribute(reverse)

    on key (interrupt)
       exit input
 end input

 if int_flag  then
    clear form
    initialize a_ctn18c00, l_ctn18c00, d_ctn18c00, retorno to null
    let retorno.lcvcod = param.lcvcod
    let retorno.psqflg = true
    return retorno.*
 end if

 let ws.endcep = param.endcep

 case g_pesquisa
    when 0  let ws.endcep = param.endcep
    when 1  let ws.endcep[5,5] = "*"
    when 2  let ws.endcep[4,5] = "* "
    when 3  let ws.endcep[3,5] = "*  "
    when 4  let ws.endcep[2,5] = "*   "
    otherwise
       error " Nenhuma loja localizada nesta regiao!"
       initialize param.lcvcod  to null
       initialize retorno to null
       let retorno.lcvcod = param.lcvcod
       let retorno.psqflg = false
       return retorno.*
 end case

 let int_flag = false

 #---------------------------#
 # Criando Tabela Temporaria #
 #---------------------------#
 create temp table temp_ctn18c00 (lcvnom        char(40)   ,
                                  lcvcod        smallint   ,
                                  lcvextcod     char(7)    ,
                                  lojqlfdes     char(12)   ,
                                  endlgd        char(40)   ,
                                  aviestcod     decimal(4,0),
                                  endbrr        char(40)   ,
                                  lcvlojtipdes  char(13)   ,
                                  endcid        char(40)   ,
                                  endcep        char(5)    ,
                                  endcepcmp     char(3)    ,
                                  entrega       char(1)    ,  #PSI 198390
                                  faixa1        char(1)    ,  #PSI 198390
                                  dddcod        char(4)    ,
                                  teltxt        char(40)   ,
                                  facnum        decimal(10,0),
                                  faixa2        char(1)     ,
                                  lojqlfcod     smallint    ,
                                  horario       char(80)) with no log

 let ws.sql = "insert into temp_ctn18c00                       ",
              "(lcvnom, lcvcod   , lcvextcod, lojqlfdes,       ",
              " endlgd, aviestcod, endbrr   , lcvlojtipdes,    ",
              " endcid, endcep   , endcepcmp, entrega, faixa1, ",
              " dddcod, teltxt, facnum   , faixa2   , lojqlfcod   , ",
              " horario)                                       ",
              " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)   "
 prepare ins_temp_ctn18c00 from ws.sql

 let ws.sql = "select lcvnom, lcvcod   , lcvextcod, lojqlfdes,       ",
              "       endlgd, aviestcod, endbrr   , lcvlojtipdes,    ",
              "       endcid, endcep   , endcepcmp, entrega, faixa1, ",
              "       dddcod, teltxt, facnum   , faixa2   , lojqlfcod   , ",
              "       horario                                     ",
              "  from temp_ctn18c00                               ",
              " order by faixa1,faixa2,endcep,lojqlfcod       "
 prepare sel_temp_ctn18c00 from ws.sql
 declare c_temp_ctn18c00 cursor for sel_temp_ctn18c00

 let ws.sql = "select lcvcod      , aviestcod   , ",
              "       lcvextcod   , endlgd      , ",
              "       endbrr      , endcid      , ",
              "       endufd      , endcep      , ",
              "       endcepcmp   , dddcod      , ",
              "       teltxt      , facnum      , ",
              "       vclalglojstt, lcvlojtip   , ",
              "       lojqlfcod,                  ",
              " 'Seg/Sex: ' || horsegsexinc || '-' || horsegsexfnl || ",
              " ' Sabado: ' || horsabinc || '-' || horsabfnl || ",
              " ' Domingo: ' || hordominc || '-' || hordomfnl horario ",
              "  from datkavislocal               "

 if param.psqtip = 2 then
    let ws.sql = ws.sql clipped, "  where lojqlfcod = 5 "
 else
    let ws.sql = ws.sql clipped, "  where lojqlfcod <> 5 "
 end if

 if param.diasem = 0 then ##Domingo
    let ws.sql = ws.sql clipped, " and hordomfnl <> '00:00' "
 else
    if param.diasem = 6 then ##Sabado
       let ws.sql = ws.sql clipped, " and horsabfnl <> '00:00' "
    end if
 end if

 prepare sql_select from ws.sql
 declare c_ctn18c00 cursor for sql_select
 let ws.sql = "select lcvcod        ",
              "  from datrclauslocal",
              " where lcvcod    = ? ",
              "   and aviestcod = ? ",
              "   and ramcod in (31,531) ",
              "   and clscod = ?    "
 prepare sel_datrclauslocal from ws.sql
 declare c_datrclauslocal cursor for sel_datrclauslocal

 let ws.sql = " select cpodes               ",
              "   from iddkdominio          ",
              "  where cponom = 'PSOLOCQLD' ",
              "    and cpocod = ?           "
 prepare sel_iddkdominio from ws.sql
 declare c_iddkdominio cursor for sel_iddkdominio

 #PSI 198390 - Buscar se loja tem local de entrega ativo
 let ws.sql = " select count(*) ",
              "  from datklcletgvclext      ",
              "   where lcvcod =  ?         ",
              "     and aviestcod = ?       ",
              "     and etglclsitflg = 'A'  "
 prepare pctc18n00001 from ws.sql
 declare cctc18n00001 cursor for pctc18n00001

 #PSI 198390 - Buscar se loja entrega na cidade
 let ws.sql = " select count(*)       ",
              "  from datklcletgvclext",
              "   where lcvcod =  ?   ",
              "     and aviestcod = ? ",
              "     and cidcod = ?    "
 prepare pctc18n00002 from ws.sql
 declare cctc18n00002 cursor for pctc18n00002

 while not int_flag
    let arr_aux = 1    

    open c_ctn18c00
    message " Aguarde, pesquisando... ", ws.endcep  attribute (reverse)
    foreach c_ctn18c00  into  l_ctn18c00.lcvcod      ,
                              l_ctn18c00.aviestcod   ,
                              l_ctn18c00.lcvextcod   ,
                              l_ctn18c00.endlgd      ,
                              l_ctn18c00.endbrr      ,
                              l_ctn18c00.endcid      ,
                              ws.endufd              ,
                              l_ctn18c00.endcep      ,
                              l_ctn18c00.endcepcmp   ,
                              l_ctn18c00.dddcod      ,
                              l_ctn18c00.teltxt      ,
                              l_ctn18c00.facnum      ,
                              ws.vclalglojstt        ,
                              ws.lcvlojtip           ,
                              l_ctn18c00.lojqlfcod   ,
                              l_ctn18c00.horario

       whenever error continue
         select 1 
           from datrlcdljaemprlc
          where aviestcod = l_ctn18c00.aviestcod
            and lcvcod    = l_ctn18c00.lcvcod
            and ciaempcod = d_ctn18c00.ciaempcod
       whenever error stop
       
       if  sqlca.sqlcode <> 0 then
           continue foreach
       end if
       
       whenever error continue
       open c_iddkdominio using l_ctn18c00.lojqlfcod
       fetch c_iddkdominio into l_ctn18c00.lojqlfdes
       whenever error stop
        if sqlca.sqlcode < 0 then
           error "Erro ao tentar selecionar dados da tabela iddkdominio",
           "erro = ", sqlca.sqlcode," ",sqlca.sqlerrd[2]
           exit while
        end if
       if d_ctn18c00.loccod is not null  then
          if l_ctn18c00.lcvcod <> d_ctn18c00.loccod  then
             continue foreach
          end if
       else
         if param.avialgmtv      = 3  or     -- Motivo Atendimento a Oficina
            param.avialgmtv      = 6  then   -- Motivo Atendimento a Oficina
            if l_ctn18c00.lcvcod = 5  then   -- Mega Rent a Car
               continue foreach
            end if
         end if

         #QUEBRAR ESTA CRITICA - ROSANA MINCON - 15/05/06
         #if param.avialgmtv      = 5 then    -- Motivo Particular
         #   if l_ctn18c00.lcvcod = 2 then    -- Localiza
         #      continue foreach
         #   end if
         #end if
         #-- OSF 37184 --
       end if

       initialize ws.lcvstt to null

       let l_ctn18c00.lcvnom = "*** NAO CADASTRADA ***"

       open  c_datklocadora using l_ctn18c00.lcvcod
       fetch c_datklocadora into  l_ctn18c00.lcvnom,
                                  ws.lcvstt
       close c_datklocadora

       if ws.lcvstt <> "A"  then
          continue foreach
       end if

       initialize l_ctn18c00.lcvlojtipdes to null
       case ws.lcvlojtip
         when 1 let l_ctn18c00.lcvlojtipdes = "CORPORACAO   "
         when 2 let l_ctn18c00.lcvlojtipdes = "FRANQUIA     "
         when 3 let l_ctn18c00.lcvlojtipdes = "FRANQUIA/REDE"
       end case

       if ws.vclalglojstt <>  1   then
          if ws.vclalglojstt =  2   then  # <-- verifica periodo bloqueio
             select viginc, vigfnl
               into ws.viginc, ws.vigfnl
               from datklcvsit
              where datklcvsit.lcvcod     = l_ctn18c00.lcvcod
                and datklcvsit.aviestcod  = l_ctn18c00.aviestcod
          else
            continue foreach
          end if
       end if

       if param.clscod is not null  then
          open  c_datrclauslocal using l_ctn18c00.lcvcod,
                                       l_ctn18c00.aviestcod,
                                       param.clscod
          fetch c_datrclauslocal

          if sqlca.sqlcode = notfound  then
             continue foreach
          end if

          close c_datrclauslocal
       end if
       #PSI 205206 - Verificar se loja tem veiculos conforme a empresa
       # informada
       let l_aux = 0
       let l_qtdeveic = 0
       if d_ctn18c00.ciaempcod is not null then
          call ctd04g00_conta_veicemp(l_ctn18c00.lcvcod,
                                      d_ctn18c00.ciaempcod)
               returning l_aux,
                         l_msg,
                         l_qtdeveic
    
          if l_aux <> 1 or
             l_qtdeveic <= 0 then
             #se ocorreu algum erro ou
             #se quantidade de veiculos com a empresa para a locadora é
             # menor ou igual a 0 - despreza locadora
             continue foreach
          end if
       end if

       ##PSI 198390 - Buscar se loja tem locais de entrega ativo
       let l_aux = 0
       open cctc18n00001 using l_ctn18c00.lcvcod,
                               l_ctn18c00.aviestcod
       fetch cctc18n00001 into l_aux
       if l_aux > 0 then
          let l_ctn18c00.entrega = 'S'
       else
          let l_ctn18c00.entrega = 'N'
       end if


       #Filtro 1
       #1 - lojas localizadas na cidade e que entregam na mesma
       #2 - lojas localizadas na cidade e que não entregam na mesma
       #3 - lojas não localizadas na cidade mas que entregam na cidade informada
       #4 - lojas não localizadas na cidade e que não entregam na cidade informada
       if l_ctn18c00.endcid = l_cidnom and
          ws.endufd = l_ufdcod then
          #cidade da locadora e a mesma da cidade a ser localizada
          #filtro = 1 ou 2
          if l_ctn18c00.entrega = 'S' then
             #Buscar se loja entrega na cidade
             if l_cidcod is not null then
                let l_aux = 0
                open cctc18n00002 using l_ctn18c00.lcvcod,
                                        l_ctn18c00.aviestcod,
                                        l_cidcod
                fetch cctc18n00002 into l_aux
                if l_aux > 0 then
                   let l_faixa1 = 1
                else
                   let l_faixa1 = 2
                end if
             else
                let l_faixa1 = 2
             end if
          else
             let l_faixa1 = 2
          end if
       else
          #cidade nao e a  mesma q esta sendo pesquisada
          if l_ctn18c00.entrega = 'S' then
             #Buscar se loja entrega na cidade
             if l_cidcod is not null then
                let l_aux = 0
                open cctc18n00002 using l_ctn18c00.lcvcod,
                                        l_ctn18c00.aviestcod,
                                        l_cidcod
                fetch cctc18n00002 into l_aux
                if l_aux > 0 then
                   let l_faixa1 = 3
                else
                   let l_faixa1 = 4
                end if
             else
                let l_faixa1 = 4
             end if
          else
             let l_faixa1 = 4
          end if
       end if

       #Filtro 2
       #ordem de distancia da cidade informada
       if l_ctn18c00.endcep[1] <> param.endcep[1] then
          let l_faixa2 = 5
       end if

       if l_ctn18c00.endcep = param.endcep then
          let l_faixa2 = 0
       else
          if l_ctn18c00.endcep[1,4] = param.endcep[1,4] then
             let l_faixa2 = 1
          else
             if l_ctn18c00.endcep[1,3] = param.endcep[1,3] then
                let l_faixa2 = 2
             else
                if l_ctn18c00.endcep[1,2] = param.endcep[1,2] then
                   let l_faixa2 = 3
                else
                   if l_ctn18c00.endcep[1] =  param.endcep[1] then
                      let l_faixa2 = 4
                   end if
                end if
             end if
          end if
       end if

       let l_ctn18c00.endcid =
           l_ctn18c00.endcid clipped, " - ", ws.endufd
       whenever error continue
       execute ins_temp_ctn18c00 using l_ctn18c00.lcvnom
                                      ,l_ctn18c00.lcvcod
                                      ,l_ctn18c00.lcvextcod
                                      ,l_ctn18c00.lojqlfdes
                                      ,l_ctn18c00.endlgd
                                      ,l_ctn18c00.aviestcod
                                      ,l_ctn18c00.endbrr
                                      ,l_ctn18c00.lcvlojtipdes
                                      ,l_ctn18c00.endcid
                                      ,l_ctn18c00.endcep
                                      ,l_ctn18c00.endcepcmp
                                      ,l_ctn18c00.entrega
                                      ,l_faixa1
                                      ,l_ctn18c00.dddcod
                                      ,l_ctn18c00.teltxt
                                      ,l_ctn18c00.facnum
                                      ,l_faixa2
                                      ,l_ctn18c00.lojqlfcod
                                      ,l_ctn18c00.horario
       whenever error stop
        if sqlca.sqlcode < 0 then
           error "Erro ao tentar gravar dados na tabela temporaria",
           "erro = ", sqlca.sqlcode," ",sqlca.sqlerrd[2]
           exit while
        end if
    end foreach

    open c_temp_ctn18c00
    foreach c_temp_ctn18c00 into a_ctn18c00[arr_aux].lcvnom
                                ,a_ctn18c00[arr_aux].lcvcod
                                ,a_ctn18c00[arr_aux].lcvextcod
                                ,a_ctn18c00[arr_aux].lojqlfdes
                                ,a_ctn18c00[arr_aux].endlgd
                                ,a_ctn18c00[arr_aux].aviestcod
                                ,a_ctn18c00[arr_aux].endbrr
                                ,a_ctn18c00[arr_aux].lcvlojtipdes
                                ,a_ctn18c00[arr_aux].endcid
                                ,a_ctn18c00[arr_aux].endcep
                                ,a_ctn18c00[arr_aux].endcepcmp
                                ,a_ctn18c00[arr_aux].entrega
                                ,l_faixa1
                                ,a_ctn18c00[arr_aux].dddcod
                                ,a_ctn18c00[arr_aux].teltxt
                                ,a_ctn18c00[arr_aux].facnum
                                ,l_faixa2
                                ,l_ctn18c00.lojqlfcod
                                ,a_ctn18c00_aux[arr_aux].horario

       let arr_aux = arr_aux + 1
       if arr_aux >= 1000   then
          error " Limite excedido. Pesquisa com mais de 1000 lojas !"
          exit foreach
       end if

    end foreach

    drop table temp_ctn18c00

    if arr_aux > 1  then
       let retorno.psqflg  =  true

       call set_count(arr_aux - 1)

       input array a_ctn18c00 without defaults from s_ctn18c00.*

          before row
            let arr_aux = arr_curr()

            error "Horario: ", a_ctn18c00_aux[arr_aux].horario

          on key (interrupt)
             initialize a_ctn18c00, retorno to null
             #let retorno.lcvcod = param.lcvcod
             let retorno.lcvcod = null
             let retorno.psqflg = true
             exit input

          on key (F5)
             let arr_aux = arr_curr()
             call ctc18m00_espelho(a_ctn18c00[arr_aux].lcvcod,
                                   a_ctn18c00[arr_aux].lcvextcod,
                                   a_ctn18c00[arr_aux].aviestcod)

          on key (F7)
             if a_ctn18c00[arr_aux].entrega = 'S' then
                let arr_aux = arr_curr()
                call ctn18c01(a_ctn18c00[arr_aux].lcvcod,
                              a_ctn18c00[arr_aux].aviestcod)
             else
                error "Loja nao tem local de entrega cadastrado!"
             end if

          on key (F8)
             let arr_aux = arr_curr()
             let retorno.lcvcod    = a_ctn18c00[arr_aux].lcvcod
             let retorno.aviestcod = a_ctn18c00[arr_aux].aviestcod
             let retorno.vclpsqflg = false
             let int_flag = true
             exit input

          on key (F9)
             let arr_aux = arr_curr()
             let retorno.lcvcod    = a_ctn18c00[arr_aux].lcvcod
             let retorno.aviestcod = a_ctn18c00[arr_aux].aviestcod
             let retorno.vclpsqflg = true
             let int_flag = true

             if g_nova.dctsgmcod = 1 then
             
                 if g_nova.reversao = "N" and
                    param.avialgmtv = 5   then 
                       
                    call ctn17c00 (retorno.lcvcod,
                                   retorno.aviestcod,
                                   "N",
                                   param.ciaempcod,
                                   param.avialgmtv,
                                   "")
                         returning l_avivclcod
                 else
                 
                    call ctn17c00_delivery (retorno.lcvcod,
                                           retorno.aviestcod,
                                           "N",
                                           param.ciaempcod,
                                           param.avialgmtv,
                                           "")
                                   returning l_avivclcod
                 end if  
             else
                 call ctn17c00 (retorno.lcvcod,
                                retorno.aviestcod,
                                "N",
                                param.ciaempcod,
                                param.avialgmtv,
                                "")
                      returning l_avivclcod
             end if

             #exit input
          on key (F10)
             let arr_aux = arr_curr()
             let retorno.aviestcod = a_ctn18c00[arr_aux].aviestcod
             let int_flag = false
             select refptodes
               into m_referencia
               from datkavislocal
               where aviestcod = retorno.aviestcod
             if m_referencia clipped = "" or
                m_referencia is null then
               let m_referencia = "Nao ha ponto de referencia cadastrado ",
                                  "  para esta loja."
             end if
             call cts08g01_6l("I","N",m_referencia[1,40],
                                      m_referencia[41,80],
                                      m_referencia[81,120],
                                      m_referencia[121,160],
                                      m_referencia[161,200],
                                      m_referencia[201,240])
                  returning m_referencia
             let m_referencia = null
             if int_flag = true then
               let int_flag = false
             end if

             #exit input
       end input
    else
       error " Nenhuma loja localizada neste CEP - Tente proxima regiao!"
       let retorno.lcvcod = param.lcvcod
       let retorno.psqflg = false
       let int_flag = true
    end if
 end while

 let int_flag = false

 return retorno.*

end function  ###  pesquisa_ctn18c00


#------------------------------#
function ctn18c00_delivery(par)
#------------------------------#
 define par         record
	  clisgmcod        smallint,
	  dctsgmcod        smallint,
    ufdcod           like datmlcl.ufdcod,
    cidnom           like datmlcl.cidnom,
    brrnom           like datmlcl.brrnom,
    lgdnom           like datmlcl.lgdnom,
    lclltt           like datmlcl.lclltt,
    lcllgt           like datmlcl.lcllgt
 end record

 define retorno    record
    lcvcod         like datkavislocal.lcvcod,
    aviestcod      like datkavislocal.aviestcod,
    vclpsqflg      smallint,
    psqflg         smallint
 end record

 define l_sql      char(5000)            
 define l_count    smallint
 
    #Seleciona locadora especifica na cidade
    let l_sql = "  select aviestcod from datkavislocal                      ",
                "  where lcvcod = 2                                         ",
                "    and aviestcod in (select cpodes from datkdominio       ",
                "                       where cponom = 'LojaLocadoraDeliv') ",
                "     and endufd = ?                                        ",    
                "     and endcid = ?                                        "     

   prepare p_ctn18c00_001 from l_sql
   declare c_ctn18c00_001 cursor for p_ctn18c00_001

    #Verifica se existe locadora especifica na cidade
    let l_sql = "  select count(*) from datkavislocal                          ",
                "   where lcvcod = 2                                           ",
                "     and aviestcod in (select cpodes from datkdominio         ",
                "                          where cponom = 'LojaLocadoraDeliv') ",
                "     and endufd = ?                                           ",
                "     and endcid = ?                                           "
   prepare p_ctn18c00_002 from l_sql
   declare c_ctn18c00_002 cursor for p_ctn18c00_002
   
    #Verifica se existe loja da Localiza na cidade
    let l_sql = "  select count(*)           ",
                " from datkavislocal         ",
                "   where lcvcod = 2         ", #Localiza
                "     and vclalglojstt = 1   ", #LojaAtiva
                "     and endufd = ?         ",
                "     and endcid = ?         "
   prepare p_ctn18c00_003 from l_sql
   declare c_ctn18c00_003 cursor for p_ctn18c00_003
   
   #Seleciona "qualquer" loja Locliza na cidade
    let l_sql = "  select min(aviestcod) from datkavislocal    ",
                "   where lcvcod = 2                           ",
                "     and vclalglojstt = 1                     ",
                "     and endufd = ?                           ",
                "     and endcid = ?                           "
   prepare p_ctn18c00_004 from l_sql
   declare c_ctn18c00_004 cursor for p_ctn18c00_004

   let retorno.lcvcod = 2           #Locadora sempre Localiza
   let retorno.vclpsqflg = false    #Pesquisa Veiculo
   let retorno.psqflg = false       #Pesquisa Loja        
   let l_count = 0
   
   open c_ctn18c00_002 using par.ufdcod, par.cidnom
   whenever error continue
   fetch c_ctn18c00_002 into l_count
   close c_ctn18c00_002
   
   if l_count > 0 then 
      open c_ctn18c00_001  using par.ufdcod, par.cidnom
      fetch c_ctn18c00_001 into retorno.aviestcod    
      close c_ctn18c00_001
      whenever error stop  
   else
      let l_count = 0
      open c_ctn18c00_003 using par.ufdcod, par.cidnom
      whenever error continue
      fetch c_ctn18c00_003  into l_count
      close c_ctn18c00_003
       if l_count > 0 then  
          open c_ctn18c00_004  using par.ufdcod, par.cidnom
          fetch c_ctn18c00_004 into retorno.aviestcod 
          close c_ctn18c00_004  
          whenever error stop
       else
       
             let retorno.aviestcod   = 2376 #REGIAO30
       end if

   end if
 
 return  retorno.lcvcod,
         retorno.aviestcod,
         retorno.vclpsqflg


end function