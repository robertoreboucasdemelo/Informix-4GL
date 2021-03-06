#-----------------------------------------------------------------------------#
#                       PORTO SEGURO CIA SEGUROS GERAIS                       #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTX25G05                                                   #
# ANALISTA RESP..: RAJI JAHCHAN                                               #
# PSI/OSF........: PSI 198434 - ROTERIZACAO E INTEGRACAO DE MAPAS.            #
#                  PESQUISA PADRAO DE LOGRADOURO E MAPAS - ROTERIZADO.        #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 20/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 08/08/2007 Burini                     Altera��o destinatario de envio de    #
#                                       e-mail de erro                        #
# 13/08/2009 Sergio Burini  PSI 244236  Inclus�o do Sub-Dairro                #
# 29/12/2009 Fabio Costa    PSI 198404  Tratar fim de linha windows Ctrl+M    #
# 02/03/2010 Adriano Santos PSI252891   Inclusao do padrao idx 4 e 5          #
#-----------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctx25g05_prep smallint

  define am_enderecos array[200] of record
         tipendtxt    char(73)           ,
         brrnom       char(65)           ,
         lclbrrnom    char(65)           ,
         cep          char(08)           ,
         codigo       integer,
         tipoend      char(50)           ,
         lgdtip       char(20)           ,
         lgdnom       char(60)           ,
         lclltt       like datmlcl.lclltt ,
         lcllgt       like datmlcl.lcllgt ,
         latlontxt    char(30)
  end record

  define am_exibicao  array[200] of record
         tipendtxt    char(73),
         brrnom       char(65),
         cep          char(08),
         codigo       integer,
         tipoend      char(50),
         lgdtip       char(20),
         lgdnom       char(60),
         latlontxt    char(30)
  end record

  define am_exibicao_auto  array[200] of record
         tipendtxt    char(73),
         brrnom       char(65),
         lclbrrnom    char(65),
         cep          char(08),
         codigo       integer,
         tipoend      char(50),
         lgdtip       char(20),
         lgdnom       char(60)
  end record

  define m_qtd_end    smallint,
         m_lcllttref  like datmlcl.lclltt,
         m_lcllgtref  like datmlcl.lcllgt,
         m_flgref     smallint,
         m_tipidx     smallint,
         m_flgsemidx  smallint

#-------------------------#
function ctx25g05_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_sql  =  null

  let l_sql = " select 1",
                " from glakest ",
               " where ufdcod = ? "
  prepare pctx25g05001 from l_sql
  declare cctx25g05001 cursor for pctx25g05001

  let l_sql = " select 1 ",
                " from glakcid ",
               " where cidnom = ? ",
                 " and ufdcod = ? "
  prepare pctx25g05002 from l_sql
  declare cctx25g05002 cursor for pctx25g05002

  let l_sql = " select 1 ",
                " from datkmpacid ",
               " where cidnom = ? ",
                 " and ufdcod = ? "
  prepare pctx25g05003 from l_sql
  declare cctx25g05003 cursor for pctx25g05003

  let l_sql = " select grlinf ",
                " from datkgeral ",
               " where grlchv = ? "
  prepare pctx25g05004 from l_sql
  declare cctx25g05004 cursor for pctx25g05004

  let l_sql = " select lclltt, ",
                     " lcllgt ",
                " from datkmpacid ",
               " where ufdcod = ? ",
                 " and cidnom = ? "
  prepare pctx25g05005 from l_sql
  declare cctx25g05005 cursor for pctx25g05005

  let l_sql = " update datkgeral ",
                " set (grlinf,atldat,atlhor) = (?,today,current) ",
               " where grlchv = ? "
  prepare pctx25g05006 from l_sql

  let l_sql = " select relpamtxt ",
                " from igbmparam ",
               " where relsgl    = ? ",
                 " and relpamtip = ? "
  prepare pctx25g05010 from l_sql
  declare cctx25g05010 cursor for pctx25g05010


  let m_ctx25g05_prep = true

end function

#---------------------------#
function ctx25g05_cria_temp()
#---------------------------#

  define l_sql char(300)

  let l_sql = null

  whenever error continue
  drop table tmp_endereco
  whenever error stop
   
  whenever error continue
  create temp table tmp_endereco
  (tipendtxt char(73),
   brrnom    char(65),
   lclbrrnom char(65),
   cep       char(08),
   codigo    integer,
   tipoend   char(50),
   lgdtip    char(20),
   lgdnom    char(60),
   prioridade char(10),
   latlontxt  char(30) )with no log
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro: ", sqlca.sqlcode, " na criacao da tabela tmp_endereco"
           sleep 3
     return
  end if

  #whenever error continue
  #create index idx_endereco on tmp_endereco(lgdnom,tipendtxt,brrnom)
  #whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro: ", sqlca.sqlcode, " na criacao do indice idx_endereco"
           sleep 3
     return
  end if

  let l_sql = " select tipendtxt ",
                   " , brrnom    ",
                   " , lclbrrnom ",
                   " , cep       ",
                   " , codigo    ",
                   " , tipoend   ",
                   " , lgdtip    ",
                   " , lgdnom    ",
                   " , latlontxt ",
              " from tmp_endereco "
  prepare pctx25g05007 from l_sql
  declare cctx25g05007 cursor for pctx25g05007

  let l_sql = " delete from tmp_endereco "

  prepare pctx25g05008 from l_sql

  let l_sql = " insert into tmp_endereco ",
                        "  (tipendtxt  ",
                        " , brrnom     ",
                        " , lclbrrnom  ",
                        " , cep        ",
                        " , codigo     ",
                        " , tipoend    ",
                        " , lgdtip     ",
                        " , lgdnom     ",
                        " , prioridade ",
                        " , latlontxt )",
                   " values(?,?,?,?,?,?,?,?,?,?) "

  prepare pctx25g05009 from l_sql

end function

#------------------------------------#
 function ctx25g05_prox(lr_parametro)
#------------------------------------#

  define lr_parametro   record
         ufdcod         like datkmpacid.ufdcod,
         cidnom         like datkmpacid.cidnom,
         lgdtip         like datkmpalgd.lgdtip,
         lgdnom         like datkmpalgd.lgdnom,
         lgdnum         like datmlcl.lgdnum,
         brrnom         char(65),
         lclbrrnom      char(65),
         lgdcep         like datmlcl.lgdcep,
         lgdcepcmp      like datmlcl.lgdcepcmp,
         lclltt         like datmlcl.lclltt,
         lcllgt         like datmlcl.lcllgt,
         c24lclpdrcod   like datmlcl.c24lclpdrcod,
         lcllttref      like datmlcl.lclltt,
         lcllgtref      like datmlcl.lcllgt
  end record

  initialize m_lcllttref,
             m_lcllgtref to null

  let m_flgref    = false
  let m_flgsemidx = false
  let m_tipidx = 3

  let m_lcllttref = lr_parametro.lcllttref
  let m_lcllgtref = lr_parametro.lcllgtref

   if  (m_lcllgtref is not null and m_lcllgtref <> " ") and
       (m_lcllttref is not null and m_lcllttref <> " ") then
       let m_flgref = true
   end if

  call ctx25g05("C", # -> INPUT COMPLETO
                "                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO",
                lr_parametro.ufdcod,
                lr_parametro.cidnom,
                lr_parametro.lgdtip,
                lr_parametro.lgdnom,
                lr_parametro.lgdnum,
                lr_parametro.brrnom,
                lr_parametro.lclbrrnom,
                lr_parametro.lgdcep,
                lr_parametro.lgdcepcmp,
                lr_parametro.lclltt,
                lr_parametro.lcllgt,
                lr_parametro.c24lclpdrcod)
      returning lr_parametro.lgdtip,
                lr_parametro.lgdnom,
                lr_parametro.lgdnum,
                lr_parametro.brrnom,
                lr_parametro.lclbrrnom,
                lr_parametro.lgdcep,
                lr_parametro.lgdcepcmp,
                lr_parametro.lclltt,
                lr_parametro.lcllgt,
                lr_parametro.c24lclpdrcod,
                lr_parametro.ufdcod,
                lr_parametro.cidnom

  let m_tipidx = null

    return lr_parametro.lgdtip,
           lr_parametro.lgdnom,
           lr_parametro.lgdnum,
           lr_parametro.brrnom,
           lr_parametro.lclbrrnom,
           lr_parametro.lgdcep,
           lr_parametro.lgdcepcmp,
           lr_parametro.lclltt,
           lr_parametro.lcllgt,
           lr_parametro.c24lclpdrcod,
           lr_parametro.ufdcod,
           lr_parametro.cidnom,
           m_flgsemidx

end function

#-----------------------------#
function ctx25g05(lr_parametro)
#-----------------------------#

  define lr_parametro   record
         tipo_input     char(01),
         titulo_janela  char(74),
         ufdcod         like datkmpacid.ufdcod,
         cidnom         like datkmpacid.cidnom,
         lgdtip         like datkmpalgd.lgdtip,
         lgdnom         like datkmpalgd.lgdnom,
         lgdnum         like datmlcl.lgdnum,
         brrnom         char(65),
         lclbrrnom      char(65),
         lgdcep         like datmlcl.lgdcep,
         lgdcepcmp      like datmlcl.lgdcepcmp,
         lclltt         like datmlcl.lclltt,
         lcllgt         like datmlcl.lcllgt,
         c24lclpdrcod   like datmlcl.c24lclpdrcod
  end record

  define lr_retorno   record
         lgdtip       like datkmpalgd.lgdtip,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         brrnom       char(65),
         lclbrrnom    char(65),
         lgdcep       like datmlcl.lgdcep,
         lgdcepcmp    like datmlcl.lgdcepcmp,
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         c24lclpdrcod like datmlcl.c24lclpdrcod,
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom
  end record

  define lr_input     record
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum
  end record

  define l_status     integer,
         l_msg        char(80),
         l_cep        char(08),
         l_prim_vez   smallint,
         l_i          smallint,
         l_sede       smallint,
         l_notindexed smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_status    = null
  let l_msg       = null
  let l_cep       = null
  let l_i         = null
  let m_qtd_end   = 0
  let l_prim_vez  = true
  let l_sede      = false
  let l_notindexed = false

  if  not m_flgref then
      let m_lcllttref = null
      let m_lcllgtref = null
  end if


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  # -> CRIA A TABELA TEMPORARIA PARA ORDENACAO DOS LOGRADOUROS
  call ctx25g05_cria_temp()

  for l_i = 1 to 200
      let am_exibicao[l_i].tipendtxt = null
      let am_exibicao[l_i].brrnom    = null
      let am_exibicao[l_i].cep       = null
      let am_exibicao[l_i].codigo    = null
      let am_exibicao[l_i].tipoend   = null
      let am_exibicao[l_i].lgdtip    = null
      let am_exibicao[l_i].lgdnom    = null
      let am_exibicao[l_i].codigo    = null
      let am_exibicao[l_i].latlontxt = null
      let am_enderecos[l_i].tipendtxt = null
      let am_enderecos[l_i].brrnom    = null
      let am_enderecos[l_i].lclbrrnom = null
      let am_enderecos[l_i].cep       = null
      let am_enderecos[l_i].codigo    = null
      let am_enderecos[l_i].tipoend   = null
      let am_enderecos[l_i].lgdtip    = null
      let am_enderecos[l_i].lgdnom    = null
      let am_enderecos[l_i].latlontxt = null
  end for

  initialize  lr_retorno.*  to  null
  initialize  lr_input.*  to  null

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let lr_retorno.c24lclpdrcod  = 01  # -->  01 - Fora do padrao
  let lr_retorno.lgdtip        = lr_parametro.lgdtip
  let lr_retorno.lgdnom        = lr_parametro.lgdnom
  let lr_retorno.brrnom        = lr_parametro.brrnom
  let lr_retorno.lclbrrnom     = lr_parametro.lclbrrnom
  let lr_input.lgdnom          = lr_parametro.lgdnom
  let lr_input.lgdnum          = lr_parametro.lgdnum
  let lr_input.ufdcod          = lr_parametro.ufdcod
  let lr_input.cidnom          = lr_parametro.cidnom

  if lr_input.lgdnom = "AC"  or
     lr_input.lgdnom = "A C" or
     lr_input.lgdnom = "A/C" then
     let lr_input.lgdnom = "A COMBINAR"
  end if

  if lr_input.lgdnum = 0 then
     let lr_input.lgdnum = null
  end if

  if  m_tipidx is null or m_tipidx = " " then
      let m_tipidx = 5
  end if

  open window w_ctx25g05 at 06,02 with form "ctx25g05"
     attribute(form line first, border)

  display by name lr_parametro.titulo_janela

  display lr_parametro.lgdtip to lgdtip_input
  display lr_parametro.lgdnum to lgdnum_input
  display lr_parametro.brrnom to brrnom_input

  while true

     input lr_input.ufdcod,
           lr_input.cidnom,
           lr_input.lgdnom,
           lr_input.lgdnum without defaults from ufdcod_input,
                                                 cidnom_input,
                                                 lgdnom_input,
                                                 lgdnum_input
        # -> UF
        before field ufdcod_input

           if lr_parametro.tipo_input = "P" then # -> PARCIAL(apenas logradouro e numeracao)
              next field lgdnom_input
           end if

           # -> SE FOR A PRIMEIRA PESQUISA E OS CAMPOS ESTIVEREM PREENCHIDOS
           # -> PESQUISA DIRETO, CASO CONTRARIO, PERMITE ALTERACAO
           if l_prim_vez and
              lr_input.ufdcod is not null and
              lr_input.cidnom is not null and
              lr_input.lgdnom is not null then
              let l_prim_vez = false
              exit input
           end if

           let l_prim_vez = false

           display lr_input.ufdcod to ufdcod_input attribute(reverse)

        after field ufdcod_input
           display lr_input.ufdcod to ufdcod_input

           if lr_input.ufdcod is null or
              lr_input.ufdcod = " " then
              let lr_input.ufdcod = "SP"
              display lr_input.ufdcod to ufdcod_input
           end if

           # -> VALIDA UF
           if not ctx25g05_existe_uf(lr_input.ufdcod) then
              error " Codigo de UF nao cadastrado!"
              next field ufdcod_input
           end if

        # -> CIDADE
        before field cidnom_input
           display lr_input.cidnom to cidnom_input attribute(reverse)

        after field cidnom_input
           display lr_input.cidnom to cidnom_input

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field ufdcod_input
           end if

           if lr_input.cidnom is null or
              lr_input.cidnom = " " then
              let lr_input.cidnom = "SAO PAULO"
              display lr_input.cidnom to cidnom_input
           end if

           # -> VALIDA CIDADE NO GUIA POSTAL
           if not ctx25g05_existe_cid(1, # GUIA POSTAL
                                      lr_input.ufdcod,
                                      lr_input.cidnom) then
              error " Cidade nao cadastrada!"

              call cts06g04(lr_input.cidnom,
                            lr_input.ufdcod)

                   returning l_status,
                             lr_input.cidnom,
                             lr_input.ufdcod

              display lr_input.cidnom to cidnom_input
              display lr_input.ufdcod to ufdcod_input
           end if

           # -> VALIDA CIDADE NO CADASTRO DE MAPAS
           if not ctx25g05_existe_cid(2, # CADASTRO DE MAPAS
                                      lr_input.ufdcod,
                                      lr_input.cidnom) then
              error " Cidade nao cadastrada na base de mapas!"
              next field cidnom_input
           end if

        # -> LOGRADOURO
        before field lgdnom_input
           display lr_input.lgdnom to lgdnom_input  attribute(reverse)

        after field lgdnom_input
           display lr_input.lgdnom to lgdnom_input

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              if lr_parametro.tipo_input = "P" then # -> PARCIAL(apenas logradouro e numeracao)
                 next field lgdnom_input
              else
                 next field cidnom_input
              end if
           end if

           if lr_input.lgdnom is null or
              lr_input.lgdnom = " " then
              error " Logradouro deve ser informado!"
              next field lgdnom_input
           end if

           if lr_input.lgdnom = "AC"  or
              lr_input.lgdnom = "A C" or
              lr_input.lgdnom = "A/C" then
              let lr_input.lgdnom = "A COMBINAR"
              display lr_input.lgdnom to lgdnom_input
           end if

           if lr_input.lgdnom = "CENTRO" then
              if cts08g01("A","S","DESEJA UTILIZAR O PONTO CENTRAL",
                          "DA CIDADE INFORMADA ?","","") = "S" then
                 let l_sede = true
                 exit input
              end if
           end if

        # -> NUMERO DO LOGRADOURO
        before field lgdnum_input
           display lr_input.lgdnum to lgdnum_input attribute(reverse)

        after field lgdnum_input
           display lr_input.lgdnum to lgdnum_input

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field lgdnom_input
           end if

           if lr_input.lgdnum = 0 then
              let lr_input.lgdnum = null
           end if

        on key (f17, control-c, interrupt)
           if lr_parametro.c24lclpdrcod = 3 or
              lr_parametro.c24lclpdrcod = 4 or # PSI 252891
              lr_parametro.c24lclpdrcod = 5 then # End recebido ja indexado por rua
              if cts08g01("A","S","MANTER INDEXACAO ANTERIOR?",
                                  "","","") = "S" then
                 let int_flag = true
                 exit input
              else
                 let int_flag = false
                 if cts08g01("A","S","","MANTER SEM INDEXACAO?",
                                     "","") = "S" then

                    if  m_flgref then
                        let lr_retorno.c24lclpdrcod = 3
                        let lr_retorno.lclltt = m_lcllttref
                        let lr_retorno.lcllgt = m_lcllgtref
                        let m_flgsemidx = true
                    else
                        let l_notindexed = true
                        let lr_retorno.c24lclpdrcod = 1
                        open cctx25g05005 using lr_input.ufdcod,
                                                lr_input.cidnom
                        fetch cctx25g05005 into lr_retorno.lclltt,
                                                lr_retorno.lcllgt
                        close cctx25g05005
                    end if

                    let lr_retorno.ufdcod = lr_input.ufdcod
                    let lr_retorno.cidnom = lr_input.cidnom
                    let lr_retorno.lgdtip = lr_parametro.lgdtip
                    let lr_retorno.lgdnom = lr_input.lgdnom
                    let lr_retorno.lgdnum = lr_input.lgdnum
                    let lr_retorno.brrnom = lr_parametro.brrnom

                    exit input
                 else
                    next field ufdcod_input
                 end if
              end if
           else
              if  m_flgref then
                  let lr_retorno.c24lclpdrcod = 3
                  let lr_retorno.lclltt = m_lcllttref
                  let lr_retorno.lcllgt = m_lcllgtref
                  let m_flgsemidx = true
                  exit input
              else
                  if  cts08g01("A","S","LOGRADOURO NAO INDEXADO",
                              "O ACIONAMENTO DESTE ",
                              "NAO SERA AUTOMATICO",
                              "CONFIRMA ?") = "S" then
                      let int_flag = true
                      exit input
                  else
                      let int_flag = false
                      next field ufdcod_input
                  end if
              end if
           end if

     end input

     if int_flag or l_notindexed then
        exit while
     end if

     if l_sede = true then
        if  not m_flgref then
            open cctx25g05005 using lr_input.ufdcod,
                                    lr_input.cidnom
            fetch cctx25g05005 into lr_retorno.lclltt,
                                    lr_retorno.lcllgt
            close cctx25g05005

            let lr_retorno.c24lclpdrcod = 3
            let lr_retorno.lgdtip       = "SEDE"
            let lr_retorno.lgdnom       = "CENTRO"
            let lr_retorno.brrnom       = "CENTRO"
            let lr_retorno.lclbrrnom    = null
        end if

        exit while
     else
           call cty22g02_retira_acentos(lr_parametro.lgdtip)
                returning lr_parametro.lgdtip
           call cty22g02_retira_acentos(lr_input.lgdnom)
                returning lr_input.lgdnom
           call cty22g02_retira_acentos(lr_parametro.brrnom)
                returning lr_parametro.brrnom
           call cty22g02_retira_acentos(lr_input.ufdcod)
                returning lr_input.ufdcod
           call cty22g02_retira_acentos(lr_input.cidnom)
                returning lr_input.cidnom

        call ctx25g05_pesquisa(lr_parametro.lgdtip,
                               lr_input.lgdnom,
                               lr_input.lgdnum,
                               lr_parametro.brrnom,
                               lr_input.ufdcod,
                               lr_input.cidnom)

             returning l_status,
                       lr_retorno.lclltt,
                       lr_retorno.lcllgt,
                       lr_retorno.lgdtip,
                       lr_retorno.lgdnom,
                       lr_retorno.brrnom,
                       lr_retorno.lclbrrnom,
                       lr_retorno.lgdcep,
                       lr_retorno.c24lclpdrcod

        if l_status <> 0 then
           error "Erro ao chamar a funcao ctx25g05_pesquisa() " sleep 2
        end if

        if lr_retorno.c24lclpdrcod = 3 then # -> USUARIO ESCOLHEU UM ENDERECO
           exit while
        end if
     end if
  end while

  close window w_ctx25g05

  if int_flag then
     if  m_flgref then
         let lr_retorno.lgdtip       = lr_parametro.lgdtip
         let lr_retorno.ufdcod       = lr_input.ufdcod
         let lr_retorno.cidnom       = lr_input.cidnom
         let lr_retorno.lgdnom       = lr_input.lgdnom
         let lr_retorno.lgdnum       = lr_input.lgdnum
         let lr_retorno.lclltt       = m_lcllttref
         let lr_retorno.lcllgt       = m_lcllgtref
         let lr_retorno.c24lclpdrcod = 3
         let m_flgsemidx = true
     else
         # SE USUARIO CANCELAR TELA, MANTER A INFORMACAO DOS PARAMETROS
         let lr_retorno.ufdcod       = lr_parametro.ufdcod
         let lr_retorno.cidnom       = lr_parametro.cidnom
         let lr_retorno.lgdtip       = lr_parametro.lgdtip
         let lr_retorno.lgdnom       = lr_parametro.lgdnom
         let lr_retorno.lgdnum       = lr_parametro.lgdnum
         let lr_retorno.brrnom       = lr_parametro.brrnom
         let lr_retorno.lclbrrnom    = lr_parametro.lclbrrnom
         let lr_retorno.lgdcep       = lr_parametro.lgdcep
         let lr_retorno.lgdcepcmp    = lr_parametro.lgdcepcmp
         let lr_retorno.lclltt       = lr_parametro.lclltt
         let lr_retorno.lcllgt       = lr_parametro.lcllgt
         let lr_retorno.c24lclpdrcod = lr_parametro.c24lclpdrcod

         if lr_retorno.c24lclpdrcod is null then
            let lr_retorno.c24lclpdrcod = 1
         end if
     end if
  else
     # -> NUMERO DO LOGRADOURO, UF E CIDADE
     let lr_retorno.lgdnum       = lr_input.lgdnum
     let lr_retorno.ufdcod       = lr_input.ufdcod
     let lr_retorno.cidnom       = lr_input.cidnom

     # -> SE O BAIRRO DO MAPA NAO EXISTIR, MANTEM O BAIRRO RECEBIDO NO PARAMETRO
     if lr_retorno.brrnom is null or
        lr_parametro.brrnom =  " " then
        let lr_retorno.brrnom = lr_parametro.brrnom
     end if

  end if

  let int_flag = false

  # -> APAGA A TABELA TEMPORARIA
  call ctx25g05_drop_temp()

  return lr_retorno.lgdtip,
         lr_retorno.lgdnom,
         lr_retorno.lgdnum,
         lr_retorno.brrnom,
         lr_retorno.lclbrrnom,
         lr_retorno.lgdcep,
         lr_retorno.lgdcepcmp,
         lr_retorno.lclltt,
         lr_retorno.lcllgt,
         lr_retorno.c24lclpdrcod,
         lr_retorno.ufdcod,
         lr_retorno.cidnom

end function

#--------------------------------------#
function ctx25g05_pesquisa(lr_parametro)
#--------------------------------------#

  define lr_parametro  record
         lgdtip        like datkmpalgd.lgdtip,
         lgdnom        like datkmpalgd.lgdnom,
         lgdnum        like datmlcl.lgdnum,
         brrnom        char(65),
         ufdcod        like datkmpacid.ufdcod,
         cidnom        like datkmpacid.cidnom
  end record

  define lr_fonetica   record
         prifoncod     char(50),
         segfoncod     char(50),
         terfoncod     char(50)
  end record

  define l_lclltt          like datmlcl.lclltt,
         l_lcllgt          like datmlcl.lcllgt,
         l_servico         char(01),
         l_msg             char(80),
         l_status          integer, # 0 -> OK     <> 0 -> ERRO
         l_doc_handle      integer,
         l_codigo          integer,
         l_tipend          char(50),
         l_qtd_end         smallint,
         l_online          smallint,
         l_xml_request     char(3000),
         l_xml_response    char(32000),
         l_lgdtip          char(20),
         l_lgdnom          char(60),
         l_brrnom          char(65),
         l_lclbrrnom       char(65),
         l_lgdcep          char(08),
         l_tem_aster       smallint,
         l_c24lclpdrcod    smallint,
         l_ind             smallint,
         l_dstqtd          decimal(8,4),
         l_tolerancia      decimal(8,4),
         l_resultado       smallint,
         l_mensagem        char(60),
         l_txtfilagis      char(20)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_ind = null
  let l_lclltt  =  null
  let l_lcllgt  =  null
  let l_msg  =  null
  let l_status  = 0
  let l_doc_handle  =  null
  let l_codigo  =  null
  let l_tipend  =  null
  let l_qtd_end  =  null
  let l_online  =  null
  let l_xml_request  =  null
  let l_xml_response  =  null
  let l_lgdtip  =  null
  let l_lgdnom  =  null
  let l_brrnom  =  null
  let l_lclbrrnom = null
  let l_lgdcep  =  null
  let l_c24lclpdrcod  =  null
  let l_tem_aster     = null
  let m_qtd_end = 0
  let l_txtfilagis = null

  for l_ind = 1 to 200
     let am_enderecos[l_ind].tipendtxt = null
     let am_enderecos[l_ind].brrnom    = null
     let am_enderecos[l_ind].cep       = null
     let am_enderecos[l_ind].codigo    = null
     let am_enderecos[l_ind].tipoend   = null
     let am_enderecos[l_ind].lgdtip    = null
     let am_enderecos[l_ind].lgdnom    = null
     let am_enderecos[l_ind].latlontxt = null
     let am_exibicao[l_ind].tipendtxt  = null
     let am_exibicao[l_ind].brrnom     = null
     let am_exibicao[l_ind].cep        = null
     let am_exibicao[l_ind].codigo     = null
     let am_exibicao[l_ind].tipoend    = null
     let am_exibicao[l_ind].lgdtip     = null
     let am_exibicao[l_ind].lgdnom     = null
     let am_exibicao[l_ind].latlontxt  = null
  end for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  lr_fonetica.*  to  null

  # -> APAGA OS REGISTROS DA TABELA TEMPORARIA
  execute pctx25g05008

  message " Favor aguardar, pesquisando..." attribute(reverse)

  # VALIDA SE A UF E CIDADE FORAM PREENCHIDOS
  if lr_parametro.ufdcod = " "   or
     lr_parametro.ufdcod is null or
     lr_parametro.cidnom = " "   or
     lr_parametro.cidnom is null then
     error "Problema a UF e a Cidade nao informada. AVISE A INFORMATICA!" sleep 6
     let l_status = 1
     return l_status,
            l_lclltt,
            l_lcllgt,
            l_lgdtip,
            l_lgdnom,
            l_brrnom,
            l_lclbrrnom,
            l_lgdcep,
            l_c24lclpdrcod
  end if

  # -> SUBSTITUI O CORINGA(*) do INFORMIX, PELO CORINGA(%) DO ORACLE
  call ctx25g05_sub_asterisco(lr_parametro.lgdnom)
       returning l_tem_aster,
                 lr_parametro.lgdnom

  if l_tem_aster then
     # -> SE EXISTIR CORINGA NA PESQUISA, NAO GERAR CODIGO FONETICO
     let lr_fonetica.prifoncod = "***************"
     let lr_fonetica.segfoncod = "***************"
     let lr_fonetica.terfoncod = "***************"
  else
     # --> GERA O CODIGO FONETICO A PARTIR DO ENDERECO DIGITADO
     call ctx25g05_gera_codfon(lr_parametro.lgdnom)
          returning l_status,
                    lr_fonetica.prifoncod,
                    lr_fonetica.segfoncod,
                    lr_fonetica.terfoncod
  end if

  if l_status <> 0 then
     error "Problema na geracao do codigo fonetico. AVISE A INFORMATICA!" sleep 6
  else
     while true

        let l_servico = "I"

        if  m_flgref then
            let l_servico = "O"  #OrdenarCoordenada
        end if


        # --> GERA O XML DE REQUEST P/IDENTIFICAR O ENDERECO
        if l_servico <> 'O' then

           let lr_parametro.lgdnom = lr_parametro.lgdtip clipped, " ",
                                     lr_parametro.lgdnom

           call cty22g02_retira_acentos(lr_parametro.lgdtip)
                returning lr_parametro.lgdtip
           call cty22g02_retira_acentos(lr_parametro.lgdnom)
                returning lr_parametro.lgdnom
           call cty22g02_retira_acentos(lr_parametro.brrnom)
                returning lr_parametro.brrnom
           call cty22g02_retira_acentos(lr_parametro.ufdcod)
                returning lr_parametro.ufdcod
           call cty22g02_retira_acentos(lr_parametro.cidnom)
                returning lr_parametro.cidnom

           let l_xml_request = ctx25g05_xml_request(l_servico, # -> IdentificarEndereco
                                                    lr_parametro.lgdnom, # lougradouro
                                                    lr_parametro.lgdnum, # Numero lougradouro
                                                    lr_parametro.cidnom, # Cidade
                                                    lr_parametro.ufdcod, # Estado
                                                    "", # Tipo de Lougradouro
                                                    "", # Bairro
                                                    "", # fonetica 1
                                                    "", # fonetica 2
                                                    "") # fonetica 3

        else
           let l_xml_request = ctx25g05_xml_request(l_servico, # -> IdentificarEndereco
                                                    lr_parametro.lgdnom,    # lougradouro
                                                    lr_parametro.lgdnum,    # Numero lougradouro
                                                    lr_parametro.cidnom,    # Cidade
                                                    lr_parametro.ufdcod,    # Estado
                                                    lr_parametro.lgdtip,    # Tipo de Lougradouro
                                                    lr_parametro.brrnom,    # Bairro
                                                    lr_fonetica.prifoncod, # fonetica 1
                                                    lr_fonetica.segfoncod, # fonetica 2
                                                    lr_fonetica.terfoncod) # fonetica 3

       end if

        # --> CHAMA A FUNCAO P/RETORNAR O XML DE RESPONSE A PARTIR
        # --> DO XML DE REQUEST
        let l_online = online()

        call ctx25g05_fila_mq()
             returning l_txtfilagis
        
        call figrc006_enviar_pseudo_mq(l_txtfilagis,
                                       l_xml_request,
                                       l_online)
              returning l_status,
                        l_msg,
                        l_xml_response

        if l_status <> 0 then
           let l_msg = l_msg clipped, " Erro: ", l_status using "<<<<<<<<&"

           if l_status = 2080 then # -> RETORNO MUITO LONGO
              error "Endereco informado insuficiente, favor complemente !" sleep 5
           else
              # -> DESATIVA A ROTERIZACAO
              call ctx25g05_desativa_rota()
              call ctx25g05_email_erro(l_xml_request,
                                       l_xml_response,
                                       "ERRO NO MQ - CTX25G05",
                                       l_msg)
              error "Erro ao chamar a funcao figrc006_enviar_pseudo_mq()" sleep 2
              error l_msg sleep 2
           end if

           exit while
        else

           call figrc011_fim_parse()
           call figrc011_inicio_parse()
           let l_doc_handle = figrc011_parse(l_xml_response)

           # -> VERIFICA A MENSAGEM DE ERRO
           let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERRO")

           if (l_msg is not null and l_msg <> " ") and
               l_msg[1,13] <> "Nenhum endere"      and 
               l_msg not like "%Insufficient number of valid locations%"  and 
               l_msg not like "%No solution found%" then

              # -> DESATIVA A ROTERIZACAO
              call ctx25g05_desativa_rota()

              call ctx25g05_email_erro(l_xml_request,
                                       l_xml_response,
                                       "ERRO NO AMBIENTE MAPA - CTX25G05",
                                       l_msg)
           end if

           # -> VERIFICA A MENSAGEM DE ERRO
           let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERROR")

           if l_msg is not null and l_msg <> " " then

              # -> DESATIVA A ROTERIZACAO
              call ctx25g05_desativa_rota()

              call ctx25g05_email_erro(l_xml_request,
                                       l_xml_response,
                                       "ERRO NO AMBIENTE MAPA - CTX25G05",
                                       l_msg)
           end if

           # --> BUSCA A QUANTIDADE DE ENDERECOS RETORNADA NO XML DE RESPONSE
           let l_qtd_end = figrc011_xpath(l_doc_handle,
                                          "count(/RESPONSE/LISTA/ENDERECO)")

           # --> CARREGA O ARRAY C/OS ENDERECOS ENCONTRADOS
           call ctx25g05_carga_array_end(l_qtd_end,
                                         l_doc_handle,
                                         lr_parametro.lgdnom,  # Envia logradouro pesquisado para priorizar apresentacao
                                         lr_parametro.brrnom,  # Envia logradouro pesquisado para priorizar apresentacao
                                         lr_parametro.lgdtip)  # Envia logradouro pesquisado para priorizar apresentacao

           call figrc011_fim_parse()

           # --> REALIZA BUSCA COM NOME DE LOGRADOURO PARCIAL
           message "REALIZANDO PESQUISA PARCIAL..."
           call ctx25g05_adiciona_parcial(lr_parametro.lgdnom ,
                                          lr_parametro.lgdnum ,
                                          lr_parametro.ufdcod ,
                                          lr_parametro.cidnom )
           message " "

           if m_qtd_end > 0 then
              # --> EXIBE O ARRAY P/O USUARIO ESCOLHER UM ENDERECO
              call ctx25g05_exibe_array(m_qtd_end)
                   returning l_codigo,
                             l_tipend,
                             l_lgdtip,
                             l_lgdnom,
                             l_brrnom,
                             l_lclbrrnom,
                             l_lgdcep,
                             l_c24lclpdrcod,
                             l_lcllgt,
                             l_lclltt


                 call cts18g00(l_lclltt, l_lcllgt, m_lcllttref, m_lcllgtref)
                   returning l_dstqtd

                 call cta12m00_seleciona_datkgeral("PSOTOLDSPDAFPSO")
                      returning  l_resultado
                                ,l_mensagem
                                ,l_tolerancia

                 if  l_tolerancia < l_dstqtd and
                     m_lcllttref is not null and
                     m_lcllgtref is not null then
                     let l_lclltt = m_lcllttref
                     let l_lcllgt = m_lcllgtref
                     let m_tipidx = 4
                 end if

                 message " "

                 if ( m_tipidx = 3 or m_tipidx = 4) then
                     call cts06g03_inclui_temp_hstidx(m_tipidx,
                                                      l_lgdtip,
                                                      l_lgdnom,
                                                      "",
                                                      l_brrnom,
                                                      lr_parametro.cidnom,
                                                      lr_parametro.ufdcod,
                                                      l_lclltt,
                                                      l_lcllgt)
                 end if
              exit while

           else
              error "Nenhum endereco localizado como o nome e o numero informado!" sleep 2
              exit while
           end if

        end if

     end while

  end if

  return l_status,
         l_lclltt,
         l_lcllgt,
         l_lgdtip,
         l_lgdnom,
         l_brrnom,
         l_lclbrrnom,
         l_lgdcep,
         l_c24lclpdrcod

end function

#--------------------------------------#
function ctx25g05_pesq_auto(lr_parametro)
#--------------------------------------#

  define lr_parametro  record
         lgdtip        like datkmpalgd.lgdtip,
         lgdnom        like datkmpalgd.lgdnom,
         lgdnum        like datmlcl.lgdnum,
         brrnom        char(65),
         lclbrrnom        char(65),
         ufdcod        like datkmpacid.ufdcod,
         cidnom        like datkmpacid.cidnom
  end record

  define lr_fonetica   record
         prifoncod     char(50),
         segfoncod     char(50),
         terfoncod     char(50)
  end record

  define l_lclltt          like datmlcl.lclltt,
         l_lcllgt          like datmlcl.lcllgt,
         l_msg             char(80),
         l_status          integer, # 0 -> OK     <> 0 -> ERRO
         l_doc_handle      integer,
         l_codigo          integer,
         l_tipend          char(50),
         l_qtd_end         smallint,
         l_online          smallint,
         l_xml_request     char(3000),
         l_xml_response    char(32000),
         l_lgdtip          char(20),
         l_lgdnom          char(60),
         l_brrnom          char(65),
         l_lclbrrnom       char(65),
         l_lgdcep          char(08),
         l_tem_aster       smallint,
         l_c24lclpdrcod    smallint,
         l_ind             smallint,
         l_txtfilagis      char(20)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_ind = null
  let l_lclltt  =  null
  let l_lcllgt  =  null
  let l_msg  =  null
  let l_status  = 0
  let l_doc_handle  =  null
  let l_codigo  =  null
  let l_tipend  =  null
  let l_qtd_end  =  null
  let l_online  =  null
  let l_xml_request  =  null
  let l_xml_response  =  null
  let l_lgdtip  =  null
  let l_lgdnom  =  null
  let l_brrnom  =  null
  let l_lclbrrnom = null
  let l_lgdcep  =  null
  let l_c24lclpdrcod  =  null
  let l_tem_aster     = null
  let m_qtd_end = 0
  let l_txtfilagis = null

  for l_ind = 1 to 200
     let am_enderecos[l_ind].tipendtxt = null
     let am_enderecos[l_ind].brrnom    = null
     let am_enderecos[l_ind].cep       = null
     let am_enderecos[l_ind].tipoend   = null
     let am_enderecos[l_ind].lgdtip    = null
     let am_enderecos[l_ind].lgdnom    = null
     let am_enderecos[l_ind].codigo    = null
     let am_enderecos[l_ind].latlontxt = null
     let am_exibicao[l_ind].tipendtxt = null
     let am_exibicao[l_ind].brrnom    = null
     let am_exibicao[l_ind].cep       = null
     let am_exibicao[l_ind].tipoend   = null
     let am_exibicao[l_ind].lgdtip    = null
     let am_exibicao[l_ind].lgdnom    = null
     let am_exibicao[l_ind].codigo    = null
     let am_exibicao[l_ind].latlontxt = null
  end for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  lr_fonetica.*  to  null

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  call ctx25g05_cria_temp()

  # -> APAGA OS REGISTROS DA TABELA TEMPORARIA
  execute pctx25g05008

  message " Favor aguardar, pesquisando..." attribute(reverse)

  # -> SUBSTITUI O CORINGA(*) do INFORMIX, PELO CORINGA(%) DO ORACLE
  #call ctx25g05_sub_asterisco(lr_parametro.lgdnom)
  #     returning l_tem_aster,
  #               lr_parametro.lgdnom
  #
  #if l_tem_aster then
  #   # -> SE EXISTIR CORINGA NA PESQUISA, NAO GERAR CODIGO FONETICO
  #   let lr_fonetica.prifoncod = "***************"
  #   let lr_fonetica.segfoncod = "***************"
  #   let lr_fonetica.terfoncod = "***************"
  #else
  #   # --> GERA O CODIGO FONETICO A PARTIR DO ENDERECO DIGITADO
  #   call ctx25g05_gera_codfon(lr_parametro.lgdnom)
  #        returning l_status,
  #                  lr_fonetica.prifoncod,
  #                  lr_fonetica.segfoncod,
  #                  lr_fonetica.terfoncod
  #end if

 call cty22g02_retira_acentos(lr_parametro.lgdtip)
      returning lr_parametro.lgdtip
 call cty22g02_retira_acentos(lr_parametro.lgdnom)
      returning lr_parametro.lgdnom
 call cty22g02_retira_acentos(lr_parametro.brrnom)
      returning lr_parametro.brrnom
 call cty22g02_retira_acentos(lr_parametro.ufdcod)
      returning lr_parametro.ufdcod
 call cty22g02_retira_acentos(lr_parametro.cidnom)
      returning lr_parametro.cidnom
 call cty22g02_retira_acentos(lr_parametro.lclbrrnom)
      returning lr_parametro.lclbrrnom

  if l_status <> 0 then
     #error "Problema na geracao do codigo fonetico. AVISE A INFORMATICA!" sleep 6
  else
     while true

        # --> GERA O XML DE REQUEST P/IDENTIFICAR O ENDERECO
        let l_xml_request = ctx25g05_xml_request("I", # -> IdentificarEndereco
                                                 lr_parametro.lgdnom,
                                                 lr_parametro.lgdnum,
                                                 lr_parametro.cidnom,
                                                 lr_parametro.ufdcod,
                                                 "", # Tipo de Lougradouro
                                                 "", # Bairro
                                                 "", # fonetica 1
                                                 "", # fonetica 2
                                                 "") # fonetica 3


        # --> CHAMA A FUNCAO P/RETORNAR O XML DE RESPONSE A PARTIR
        # --> DO XML DE REQUEST
        let l_online = online()

        call ctx25g05_fila_mq()
             returning l_txtfilagis
        
        call figrc006_enviar_pseudo_mq(l_txtfilagis,
                                       l_xml_request,
                                       l_online)
              returning l_status,
                        l_msg,
                        l_xml_response


        if l_status <> 0 then
           let l_msg = l_msg clipped, " Erro: ", l_status using "<<<<<<<<&"

           if l_status <> 2080 then # -> RETORNO MUITO LONGO
              # -> DESATIVA A ROTERIZACAO
              call ctx25g05_desativa_rota()
              call ctx25g05_email_erro(l_xml_request,
                                       l_xml_response,
                                       "ERRO NO MQ - CTX25G05",
                                       l_msg)
              #error "Erro ao chamar a funcao figrc006_enviar_pseudo_mq()" sleep 2
              #error l_msg sleep 2
           end if

           exit while
        else

           call figrc011_fim_parse()
           call figrc011_inicio_parse()
           let l_doc_handle = figrc011_parse(l_xml_response)

           # -> VERIFICA A MENSAGEM DE ERRO
           let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERRO")

           if (l_msg is not null and l_msg <> " ") and
               l_msg[1,13] <> "Nenhum endere"      and 
               l_msg not like "%Insufficient number of valid locations%"  and 
               l_msg not like "%No solution found%" then

              # -> DESATIVA A ROTERIZACAO
              call ctx25g05_desativa_rota()

              call ctx25g05_email_erro(l_xml_request,
                                       l_xml_response,
                                       "ERRO NO AMBIENTE MAPA - CTX25G05",
                                       l_msg)
           end if

           # -> VERIFICA A MENSAGEM DE ERRO
           let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERROR")

           if l_msg is not null and l_msg <> " " then

              # -> DESATIVA A ROTERIZACAO
              call ctx25g05_desativa_rota()

              call ctx25g05_email_erro(l_xml_request,
                                       l_xml_response,
                                       "ERRO NO AMBIENTE MAPA - CTX25G05",
                                       l_msg)
           end if

           # --> BUSCA A QUANTIDADE DE ENDERECOS RETORNADA NO XML DE RESPONSE
           let l_qtd_end = figrc011_xpath(l_doc_handle,
                                          "count(/RESPONSE/LISTA/ENDERECO)")

           # --> CARREGA O ARRAY C/OS ENDERECOS ENCONTRADOS
           call ctx25g05_carga_array_end(l_qtd_end,
                                         l_doc_handle,
                                         lr_parametro.lgdnom,  # Envia logradouro pesquisado para priorizar apresentacao
                                         lr_parametro.brrnom,  # Envia logradouro pesquisado para priorizar apresentacao
                                         lr_parametro.lgdtip)  # Envia logradouro pesquisado para priorizar apresentacao

           call figrc011_fim_parse()
           
           # --> REALIZA BUSCA COM NOME DE LOGRADOURO PARCIAL
           message "REALIZANDO PESQUISA PARCIAL..."
           call ctx25g05_adiciona_parcial(lr_parametro.lgdnom ,
                                          lr_parametro.lgdnum ,
                                          lr_parametro.ufdcod ,
                                          lr_parametro.cidnom )
           message " "

           if m_qtd_end > 0 then
              # --> EXIBE O ARRAY P/O USUARIO ESCOLHER UM ENDERECO

              call ctx25g05_escolhe_auto(m_qtd_end              ,
                                         lr_parametro.lgdtip    ,
                                         lr_parametro.lgdnom    ,
                                         lr_parametro.lgdnum    ,
                                         lr_parametro.brrnom    ,
                                         lr_parametro.lclbrrnom ,
                                         lr_parametro.ufdcod    ,
                                         lr_parametro.cidnom    )
                   returning l_codigo,
                             l_tipend,
                             l_lgdtip,
                             l_lgdnom,
                             l_brrnom,
                             l_lclbrrnom,
                             l_lgdcep,
                             l_c24lclpdrcod,
                             l_lclltt,
                             l_lcllgt



           end if

           exit while

        end if

        exit while

     end while

  end if

  let int_flag = false

  # -> APAGA A TABELA TEMPORARIA
  call ctx25g05_drop_temp()


  return l_status,
         l_lclltt,
         l_lcllgt,
         l_lgdtip,
         l_lgdnom,
         l_brrnom,
         l_lclbrrnom,
         l_lgdcep,
         l_c24lclpdrcod

end function

#-------------------------------------#
function ctx25g05_gera_codfon(l_lgdnom)
#-------------------------------------#

  # -> FUNCAO P/GERAR OS CODIGOS FONETICOS P/PESQUISA

  define l_lgdnom like datkmpalgd.lgdnom

  define lr_fonetica record
         prifoncod   char(50),
         segfoncod   char(50),
         terfoncod   char(50)
  end record

  define l_entfon     char(100),
         l_saifon     char(100),
         l_status     smallint # 0 -> OK    <> 0 -> ERRO

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_entfon  =  null
  let l_saifon  =  null
  let l_status  =  0

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize  lr_fonetica.*  to  null

  let l_entfon = null
  let l_saifon = null
  let l_status = 0

  let l_entfon = "3" clipped, l_lgdnom
  let l_saifon = fonetica2(l_entfon)

  if l_saifon[1,3] = "100" then
     let l_status = 1
     initialize lr_fonetica to null
  else
     let lr_fonetica.prifoncod = l_saifon[01,15]
     let lr_fonetica.segfoncod = l_saifon[17,31]
     let lr_fonetica.terfoncod = l_saifon[33,47]

     if lr_fonetica.prifoncod is null or
        lr_fonetica.prifoncod     = " "  then
        let lr_fonetica.prifoncod = l_lgdnom[01,15]
     end if

     if lr_fonetica.segfoncod is null or
        lr_fonetica.segfoncod     = " "  then
        let lr_fonetica.segfoncod = lr_fonetica.prifoncod
     end if

     if lr_fonetica.terfoncod is null or
        lr_fonetica.terfoncod     = " " then
        let lr_fonetica.terfoncod = lr_fonetica.prifoncod
     end if
  end if


   # -> REMOVE CARACTERES ESPECIAIS XML
   let lr_fonetica.prifoncod = ctx25g05_carac_fon(lr_fonetica.prifoncod)
   let lr_fonetica.segfoncod = ctx25g05_carac_fon(lr_fonetica.segfoncod)
   let lr_fonetica.terfoncod = ctx25g05_carac_fon(lr_fonetica.terfoncod)

  return l_status,
         lr_fonetica.prifoncod,
         lr_fonetica.segfoncod,
         lr_fonetica.terfoncod

end function
#------------------------------------------------#
function ctx25g05_adiciona_parcial(lr_parametro)
#------------------------------------------------#
 define lr_parametro record
    lgdnom       like datkmpalgd.lgdnom,
    lgdnum       like datkmpalgdsgm.mpalgdincnum,
    ufdcod       like datkmpacid.ufdcod,
    cidnom       like datkmpacid.cidnom
 end record

 define l_mpacidcod like datkmpacid.mpacidcod
 define l_lgdtip    like datkmpalgd.lgdtip
 define l_lgdnom    like datkmpalgd.lgdnom
 define l_brrnom    char(65)
 define l_cepcod    like datkmpalgdsgm.cepcod
 define l_lclltt    like datkmpalgdsgm.lclltt
 define l_lcllgt    like datkmpalgdsgm.lcllgt
 define l_prioriza  smallint
 define l_nompsq    like datkmpalgd.lgdnom
 define l_tipendtxt char(73)
 define l_length    smallint
 define i smallint

 define l_cont      smallint
 define l_end_cont  smallint

 initialize l_mpacidcod, l_lgdtip, l_lgdnom, l_brrnom, l_cepcod, l_lclltt, l_lcllgt to null

 let l_nompsq = '%'
 let l_length = length(lr_parametro.lgdnom)
 for i=1 to l_length
    if lr_parametro.lgdnom[i] = ' ' then
       let l_nompsq = l_nompsq clipped, '% %'
    else
       let l_nompsq = l_nompsq clipped, lr_parametro.lgdnom[i]
    end if
 end for
 let l_nompsq = l_nompsq clipped, '%'

 open cctx25g05003 using lr_parametro.cidnom,
                         lr_parametro.ufdcod
 fetch cctx25g05003 into l_mpacidcod

 if sqlca.sqlcode = notfound then
    return
 end if

 close cctx25g05003

 if lr_parametro.lgdnum is null then
    let lr_parametro.lgdnum = 0
 end if

 declare cctx25g05011 cursor for
    select lgd.lgdtip,
           lgd.lgdnom,
           brr.brrnom,
           sgm.cepcod,
           sgm.lclltt,
           sgm.lcllgt,
           0 prioriza
      from datkmpalgd lgd,
           datkmpalgdsgm sgm,
           outer datkmpabrr brr
     where lgd.mpacidcod = l_mpacidcod
       and lgd.lgdnom like l_nompsq
       and (sgm.mpalgdincnum <= lr_parametro.lgdnum and sgm.mpalgdfnlnum >= lr_parametro.lgdnum)
       and sgm.mpalgdcod = lgd.mpalgdcod
       and brr.mpabrrcod = sgm.mpabrrcod
   union
   select lgd.lgdtip,
           lgd.lgdnom,
           brr.brrnom,
           sgm.cepcod,
           sgm.lclltt,
           sgm.lcllgt,
           1 prioriza
      from datkmpalgd lgd,
           datkmpalgdsgm sgm,
           outer datkmpabrr brr
     where lgd.mpacidcod = l_mpacidcod
       and lgd.lgdnom like l_nompsq
       and not (sgm.mpalgdincnum <= lr_parametro.lgdnum and sgm.mpalgdfnlnum >= lr_parametro.lgdnum)
       and sgm.mpalgdcod = lgd.mpalgdcod
       and brr.mpabrrcod = sgm.mpabrrcod
    order by prioriza, lgdnom, lgdtip

 foreach cctx25g05011 into l_lgdtip,
                           l_lgdnom,
                           l_brrnom,
                           l_cepcod,
                           l_lclltt,
                           l_lcllgt,
                           l_prioriza

     let l_tipendtxt = l_lgdtip clipped, " ", l_lgdnom clipped

     if m_qtd_end > 199 then
        error "A quantiade de enderecos, superou o limite do array!" sleep 3
        exit foreach
     end if

     # Verifica se o endere�o ja esta na lista
     for l_cont = 1 to m_qtd_end
        if am_enderecos[l_cont].tipendtxt = l_tipendtxt and
               (am_enderecos[l_cont].brrnom    = l_brrnom
                or (
                         (am_enderecos[l_cont].brrnom = " " or am_enderecos[l_cont].brrnom is null)
                     and (l_brrnom = " " or l_brrnom is null)
                   )
                )    then
           continue foreach
        end if

        #display '------------------------'
        #if am_enderecos[l_cont].tipendtxt <> l_tipendtxt then
        #     display am_enderecos[l_cont].tipendtxt clipped , "<>", l_tipendtxt clipped
        #end if
        #if am_enderecos[l_cont].brrnom    <>	 l_brrnom    then
        #     display am_enderecos[l_cont].brrnom clipped , "<>", l_brrnom clipped
        #end if
     end for

     # Adiciona a lista de enderecos
     let l_end_cont = (m_qtd_end + 1)

     # -> TIPO LOGRADOURO
     let am_enderecos[l_end_cont].lgdtip = l_lgdtip

     # -> NOME LOGRADOURO
     let am_enderecos[l_end_cont].lgdnom = l_lgdnom

     # -> MONTA O ENDERECO: TIPO + NOME DO LOGRADOURO
     let am_enderecos[l_end_cont].tipendtxt = l_tipendtxt

     # -> TIPO DO ENDERECO
     let am_enderecos[l_end_cont].tipoend = 'LOGRADOURO'

     # -> NOME DO BAIRRO
     let am_enderecos[l_end_cont].brrnom = l_brrnom

     # -> NOME DO SUBBAIRRO
     let am_enderecos[l_end_cont].lclbrrnom = ""

     # -> CEP
     let am_enderecos[l_end_cont].cep = l_cepcod

     # -> LATITUDE - Y
     let am_enderecos[l_end_cont].lclltt = l_lclltt

     # -> LONGITUDE - X
     let am_enderecos[l_end_cont].lcllgt = l_lcllgt

     #Codigo
     let am_enderecos[l_end_cont].codigo = l_end_cont

     # -> CARREGA NO ARRAY DE EXIBICAO
     call ctx25g05_carga_array_exb(am_enderecos[l_end_cont].tipendtxt,
                                   am_enderecos[l_end_cont].brrnom,
                                   am_enderecos[l_end_cont].lclbrrnom,
                                   am_enderecos[l_end_cont].cep,
                                   am_enderecos[l_end_cont].codigo,
                                   am_enderecos[l_end_cont].tipoend,
                                   am_enderecos[l_end_cont].lgdtip,
                                   am_enderecos[l_end_cont].lgdnom,
                                   5,
                                   am_enderecos[l_end_cont].latlontxt)

 end foreach

 return

end function # ctx25g05_adicionapsqparcial


#---------------------------------------------#
function ctx25g05_carga_array_exb(lr_parametro)
#---------------------------------------------#

  define lr_parametro record
         tipendtxt    char(73),
         brrnom       char(65),
         lclbrrnom    char(65),
         cep          char(08),
         codigo       integer,
         tipoend      char(50),
         lgdtip       char(20),
         lgdnom       char(60),
         prioridade   char(10),
         latlontxt    char(30)
  end record

  define l_i          smallint

  let l_i = null

  #if m_qtd_end <> 0 then
  #   for l_i = 1 to m_qtd_end
  #      if lr_parametro.codigo = am_exibicao[l_i].codigo and
  #         lr_parametro.lgdnom = am_exibicao[l_i].lgdnom then
  #
  #         # -> O LGDNOM E TESTADO POIS EXISTEM ENDERECOS ALTERNATIVOS EM QUE O
  #         # -> O CODIGO E IGUAL MAIS O LGDNOM E DIFERENTE
  #
  #         # -> ENCONTROU ENDERECO SEMELHANTE, DESPREZA
  #         return
  #      end if
  #   end for
  #end if

  let m_qtd_end = (m_qtd_end + 1)

  let am_exibicao[m_qtd_end].tipendtxt = lr_parametro.tipendtxt
  let am_exibicao[m_qtd_end].brrnom    = lr_parametro.brrnom
  let am_exibicao[m_qtd_end].cep       = lr_parametro.cep
  let am_exibicao[m_qtd_end].codigo    = lr_parametro.codigo
  let am_exibicao[m_qtd_end].tipoend   = lr_parametro.tipoend
  let am_exibicao[m_qtd_end].lgdtip    = lr_parametro.lgdtip
  let am_exibicao[m_qtd_end].lgdnom    = lr_parametro.lgdnom
  let am_exibicao[m_qtd_end].latlontxt = lr_parametro.latlontxt

  # -> INSERE O REGISTRO NA TABELA TEMPORARIA DE ENDERECOS
  execute pctx25g05009 using am_exibicao[m_qtd_end].tipendtxt,
                             am_exibicao[m_qtd_end].brrnom,
                             lr_parametro.lclbrrnom,
                             am_exibicao[m_qtd_end].cep,
                             am_exibicao[m_qtd_end].codigo,
                             am_exibicao[m_qtd_end].tipoend,
                             am_exibicao[m_qtd_end].lgdtip,
                             am_exibicao[m_qtd_end].lgdnom,
                             lr_parametro.prioridade,
                             am_exibicao[m_qtd_end].latlontxt



end function

#---------------------------------------------#
function ctx25g05_carga_array_end(lr_parametro)
#---------------------------------------------#

  define lr_parametro record
        qtd_end      smallint,
        doc_handle   integer,
        lgdnom       like datkmpalgd.lgdnom,
        brrnom       char(65),
        lgdtip       like datmlcl.lgdtip
  end record

  define l_ind        smallint,
         l_end_cont   smallint,
         l_aux_char   char(100),
         l_endereco   char(70),
         l_end_tipo   char(20),
         l_tipo_alt   char(100),
         l_subbairro  char(050)

  define lr_auxiliar  record
         tipendtxt    char(73),
         brrnom       char(65),
         cep          char(08),
         codigo       integer,
         tipoend      char(50),
         prioridade   char(10)
  end record

  define l_dstref char(10)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_ind       = null
  let l_aux_char  = null
  let l_endereco  = null
  let l_end_tipo  = null
  let l_tipo_alt  = null
  let l_dstref = 0

  let l_ind = null

  initialize lr_auxiliar.* to null

  # --> ARMAZENA OS ENDERECOS ENCONTRADOS
  let l_end_cont = 0

  for l_ind = 1 to lr_parametro.qtd_end

     let l_end_cont = (l_end_cont + 1)

     if l_end_cont > 199 then
        #error "A quantiade de enderecos, superou o limite do array!" sleep 3
        exit for
     end if

     # -> NOME DO LOGRADOURO
     let l_endereco = null
     let l_aux_char = "/RESPONSE/LISTA/ENDERECO[", l_ind using "<<<<&", "]/LOGRADOURO"
     let l_endereco = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)
     let am_enderecos[l_end_cont].lgdnom = l_endereco

     let am_enderecos[l_end_cont].tipendtxt = l_endereco

     # -> TIPO DO ENDERECO
     let l_aux_char = "/RESPONSE/LISTA/ENDERECO[", l_ind using "<<<<&", "]/TIPOEND"
     let am_enderecos[l_end_cont].tipoend = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)

     # -> NOME DO BAIRRO + SUBBAIRRO - BURINI
     let l_aux_char = "/RESPONSE/LISTA/ENDERECO[", l_ind using "<<<<&", "]/BAIRRO"
     let am_enderecos[l_end_cont].brrnom = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)

     # -> NOME DO SUBBAIRRO
     let l_aux_char = "/RESPONSE/LISTA/ENDERECO[", l_ind using "<<<<&", "]/SUBBAIRRO"
     let am_enderecos[l_end_cont].lclbrrnom = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)

     # -> CEP
     let l_aux_char = "/RESPONSE/LISTA/ENDERECO[", l_ind using "<<<<&", "]/CEP"
     let am_enderecos[l_end_cont].cep = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)

     # -> LATITUDE - Y
     let l_aux_char = "/RESPONSE/LISTA/ENDERECO[", l_ind using "<<<<&", "]/LATITUDE"
     let am_enderecos[l_end_cont].lclltt = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)

     # -> LONGITUDE - X
     let l_aux_char = "/RESPONSE/LISTA/ENDERECO[", l_ind using "<<<<&", "]/LONGITUDE"
     let am_enderecos[l_end_cont].lcllgt = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)

     #Codigo
     let am_enderecos[l_end_cont].codigo = l_end_cont

     # texto Lat/Lon
     let am_enderecos[l_end_cont].latlontxt = 'LAT/LON: ', am_enderecos[l_end_cont].lclltt, ','
                                             , am_enderecos[l_end_cont].lcllgt

     if  not m_flgref then
         # -> Define prioridade para endereco exato
         if am_enderecos[l_end_cont].lgdnom = lr_parametro.lgdnom then
                let lr_auxiliar.prioridade = 4

            # -> Define prioridade para bairro exato
            if am_enderecos[l_end_cont].brrnom = lr_parametro.brrnom then
                let lr_auxiliar.prioridade = lr_auxiliar.prioridade - 1
            end if
         #
         #   ## -> Define prioridade para tipo exato
         #   #if am_enderecos[l_end_cont].lgdtip = lr_parametro.lgdtip then
         #   #    let lr_auxiliar.prioridade = lr_auxiliar.prioridade - 2
         #   #end if
         #
         else
                let lr_auxiliar.prioridade = 5
         end if
     else
         # -> DISTANCIA
         let l_aux_char = "/RESPONSE/LISTA/ENDERECO[", l_ind using "<<<<&", "]/DISTANCIA"
         let l_dstref = figrc011_xpath(lr_parametro.doc_handle, l_aux_char)
         let lr_auxiliar.prioridade = l_dstref
     end if

     # -> CARREGA NO ARRAY DE EXIBICAO
     call ctx25g05_carga_array_exb(am_enderecos[l_end_cont].tipendtxt,
                                   am_enderecos[l_end_cont].brrnom,
                                   am_enderecos[l_end_cont].lclbrrnom,
                                   am_enderecos[l_end_cont].cep,
                                   am_enderecos[l_end_cont].codigo,
                                   am_enderecos[l_end_cont].tipoend,
                                   am_enderecos[l_end_cont].lgdtip,
                                   am_enderecos[l_end_cont].lgdnom,
                                   lr_auxiliar.prioridade,
                                   am_enderecos[l_end_cont].latlontxt)

  end for

end function

#--------------------------------------#
function ctx25g05_exibe_array(l_qtd_reg)
#--------------------------------------#

  define l_qtd_reg      smallint,
         l_posicao      smallint,
         l_codigo       integer,
         l_lgdtip       char(20),
         l_lgdnom       char(60),
         l_brrnom       char(65),
         l_lclbrrnom    char(65),
         l_cep          char(08),
         l_c24lclpdrcod smallint,
         l_tipend       char(50),
         l_lclltt       decimal(8,6),
         l_lcllgt       decimal(9,6)

  define l_comando char(100)



  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_posicao       = null
  let l_codigo        = null
  let l_lgdtip        = null
  let l_lgdnom        = null
  let l_brrnom        = null
  let l_lclbrrnom     = null
  let l_cep           = null
  let l_c24lclpdrcod  = 1
  let l_tipend        = null
  let l_lclltt        = null
  let l_lcllgt        = null


  message " (F8)Seleciona  (F17)Abandona"

  # -> ORDENA O ARRAY ANTES DA EXIBICAO
  call ctx25g05_ordena_array()

  call set_count(l_qtd_reg)

  display array am_exibicao to s_ctx25g05.*

     on key (f8)
        let l_posicao      = arr_curr()
        let l_codigo       = am_exibicao[l_posicao].codigo
        let l_tipend       = am_exibicao[l_posicao].tipoend
        let l_lgdtip       = am_exibicao[l_posicao].lgdtip
        let l_lgdnom       = am_exibicao[l_posicao].lgdnom
        let l_brrnom       = am_exibicao[l_posicao].brrnom
        let l_cep          = am_exibicao[l_posicao].cep
        let l_lclltt       = am_enderecos[l_posicao].lclltt
        let l_lcllgt       = am_enderecos[l_posicao].lcllgt

        let l_c24lclpdrcod = 3

        select distinct lclbrrnom,
               brrnom
          into l_lclbrrnom,
               l_brrnom
          from tmp_endereco
         where codigo  = l_codigo

        exit display

     on key (f17, control-c, interrupt)
        exit display

  end display

  if int_flag = true then
     let int_flag = false
  end if

  message " "


  return l_codigo,
         l_tipend,
         l_lgdtip,
         l_lgdnom,
         l_brrnom,
         l_lclbrrnom,
         l_cep,
         l_c24lclpdrcod,
         l_lcllgt,
         l_lclltt





end function

#--------------------------------------#
function ctx25g05_escolhe_auto(l_qtd_reg, lr_parametro)
#--------------------------------------#

  define lr_parametro  record
         lgdtip        like datkmpalgd.lgdtip,
         lgdnom        like datkmpalgd.lgdnom,
         lgdnum        like datmlcl.lgdnum,
         brrnom        char(65),
         lclbrrnom        char(65),
         ufdcod        like datkmpacid.ufdcod,
         cidnom        like datkmpacid.cidnom
  end record

  define la_bairro array[200] of record
        posicao smallint
    end record

  define l_qtd_reg      smallint,
         l_posicao      smallint,
         l_seq1         smallint,
         l_seq2         smallint,
         l_codigo       integer,
         l_lgdtip       char(20),
         l_lgdnom       char(60),
         l_brrnom       char(65),
         l_lclbrrnom    char(65),
         l_cep          char(08),
         l_c24lclpdrcod smallint,
         l_tipend       char(50),
         l_lclltt       decimal(8,6),
         l_lcllgt       decimal(9,6)

  define l_comando char(100)



  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_posicao       = null
  let l_seq1           = 0
  let l_seq2           = 0
  let l_codigo        = null
  let l_lgdtip        = null
  let l_lgdnom        = null
  let l_brrnom        = null
  let l_lclbrrnom     = null
  let l_cep           = null
  let l_c24lclpdrcod  = 1
  let l_tipend        = null

  call ctx25g05_ordena_array_auto()

  call set_count(l_qtd_reg)

  for l_posicao = 1 to l_qtd_reg

      if (am_exibicao_auto[l_posicao].lgdnom  is not null and
          am_exibicao_auto[l_posicao].brrnom  is not null and
          am_exibicao_auto[l_posicao].lgdnom  <> " "      and
          am_exibicao_auto[l_posicao].brrnom  <> " "    ) then

           if (lr_parametro.lgdnom clipped = am_exibicao_auto[l_posicao].lgdnom clipped)         and
             ((lr_parametro.brrnom clipped = am_exibicao_auto[l_posicao].brrnom clipped)         or
              (lr_parametro.lclbrrnom clipped = am_exibicao_auto[l_posicao].lclbrrnom clipped)   or
              (lr_parametro.brrnom clipped = am_exibicao_auto[l_posicao].lclbrrnom clipped)      or
              (lr_parametro.lclbrrnom clipped = am_exibicao_auto[l_posicao].brrnom clipped))   then

              let l_c24lclpdrcod = 3

              select distinct lclbrrnom,
                     brrnom
                into l_lclbrrnom,
                     l_brrnom
                from tmp_endereco
               where codigo  = am_exibicao_auto[l_posicao].codigo




              let l_codigo = am_exibicao_auto[l_posicao].codigo
              let l_tipend = am_exibicao_auto[l_posicao].tipoend
              let l_lgdtip = am_exibicao_auto[l_posicao].lgdtip
              let l_lgdnom = am_exibicao_auto[l_posicao].lgdnom
              let l_cep    = am_exibicao_auto[l_posicao].cep
              let l_lclltt = am_enderecos[l_posicao].lclltt
              let l_lcllgt = am_enderecos[l_posicao].lcllgt

              return l_codigo ,
                     l_tipend,
                     l_lgdtip ,
                     l_lgdnom ,
                     l_brrnom,
                     l_lclbrrnom,
                     l_cep,
                     l_c24lclpdrcod,
                     l_lclltt,
                     l_lcllgt

          end if
      end if
  end for

  for l_posicao = 1 to l_qtd_reg

      if (am_exibicao_auto[l_posicao].codigo  is not null and
          am_exibicao_auto[l_posicao].lgdtip  is not null and
          am_exibicao_auto[l_posicao].lgdnom  is not null and
          am_exibicao_auto[l_posicao].brrnom  is not null and
          am_exibicao_auto[l_posicao].codigo  <> " "      and
          am_exibicao_auto[l_posicao].lgdtip  <> " "      and
          am_exibicao_auto[l_posicao].lgdnom  <> " "      and
          am_exibicao_auto[l_posicao].brrnom  <> " "    ) then

          if (lr_parametro.lgdtip clipped = am_exibicao_auto[l_posicao].lgdtip clipped)  and
             (lr_parametro.lgdnom clipped = am_exibicao_auto[l_posicao].lgdnom clipped) then

              let l_c24lclpdrcod = 3

              select distinct lclbrrnom,
                     brrnom
                into l_lclbrrnom,
                     l_brrnom
                from tmp_endereco
               where codigo  = am_exibicao_auto[l_posicao].codigo
                 # tipoend = am_exibicao_auto[l_posicao].tipoend
                 #and lgdtip  = am_exibicao_auto[l_posicao].lgdtip
                 #and lgdnom  = am_exibicao_auto[l_posicao].lgdnom

              let l_codigo = am_exibicao_auto[l_posicao].codigo
              let l_tipend = am_exibicao_auto[l_posicao].tipoend
              let l_lgdtip = am_exibicao_auto[l_posicao].lgdtip
              let l_lgdnom = am_exibicao_auto[l_posicao].lgdnom
              let l_cep    = am_exibicao_auto[l_posicao].cep
              let l_lclltt = am_enderecos[l_posicao].lclltt
              let l_lcllgt = am_enderecos[l_posicao].lcllgt


              return l_codigo ,
                     l_tipend,
                     l_lgdtip ,
                     l_lgdnom ,
                     l_brrnom,
                     l_lclbrrnom,
                     l_cep,
                     l_c24lclpdrcod,
                     l_lclltt,
                     l_lcllgt
          end if
      end if
  end for

  return l_codigo,
         l_tipend,
         l_lgdtip,
         l_lgdnom,
         l_brrnom,
         l_lclbrrnom,
         l_cep,
         l_c24lclpdrcod,
         l_lclltt,
         l_lcllgt

end function

#-----------------------------------------#
function ctx25g05_xml_request(lr_parametro)
#-----------------------------------------#

  # -> FUNCAO PARA GERAR O XML DE ENVIO PARA A FUNCAO DE PESQUISA

  define lr_parametro record
         tipo         char(01), # I -> IdentificarEndereco
                                # O -> OrdenarCoordenada
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         cidnom       like datmlcl.cidnom,
         ufdcod       like datmlcl.ufdcod,
         lgdtip       like datmlcl.lgdtip,
         lclbrrnom    like datmlcl.lclbrrnom,
         prifoncod     char(50),
         segfoncod     char(50),
         terfoncod     char(50)

  end record

  define l_xml_request char(3000),
         l_aux_num     char(10)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_aux_num     = lr_parametro.lgdnum
  let l_xml_request = null

  call cty22g02_retira_acentos(lr_parametro.lgdtip)
       returning lr_parametro.lgdtip
  call cty22g02_retira_acentos(lr_parametro.lgdnom)
       returning lr_parametro.lgdnom
  call cty22g02_retira_acentos(lr_parametro.lclbrrnom)
       returning lr_parametro.lclbrrnom
  call cty22g02_retira_acentos(lr_parametro.cidnom)
       returning lr_parametro.cidnom
  call cty22g02_retira_acentos(lr_parametro.ufdcod)
       returning lr_parametro.ufdcod


  case lr_parametro.tipo
     when("I") # IdentificarEndereco

        let lr_parametro.lgdnom = ctx25g05_carac_fon(lr_parametro.lgdnom)

        let l_xml_request = '<?xml version="1.0" encoding="UTF-8" ?>',
                            '<REQUEST>',
                            '<AppID>PS_CT24H_CTG2</AppID>',
                            #'<AppID>PORTO_MAPTP</AppID>',
                               '<SERVICO>IdentificarEndereco</SERVICO>',
                               '<LISTA>',
                                  '<ENDERECO>',
                                     '<UF>',
                                     lr_parametro.ufdcod clipped,
                                      '</UF>',
                                     '<CIDADE>',
                                     lr_parametro.cidnom clipped,
                                     '</CIDADE>',
                                     '<LOGRADOURO>',
                                     lr_parametro.lgdnom clipped,
                                     '</LOGRADOURO>',
                                     '<NUMERO>',
                                     l_aux_num clipped,
                                     '</NUMERO>',
                                  '</ENDERECO>',
                               '</LISTA>',
                            '</REQUEST>'

     when ("O") # OrdenarCoordenada

        let lr_parametro.lgdnom = ctx25g05_carac_fon(lr_parametro.lgdnom)

        let l_xml_request = '<?xml version="1.0" encoding="UTF-8" ?>',
                            '<REQUEST>',
                               '<SERVICO>OrdenarCoordenada</SERVICO>',
                               #'<AppID>PORTO_MAPTP</AppID>',
                               '<AppID>PS_CT24H_CTG2</AppID>',
                               '<LISTA>',
                                  '<ENDERECO>',
                                     '<UF>',
                                     lr_parametro.ufdcod clipped,
                                      '</UF>',
                                     '<CIDADE>',
                                     lr_parametro.cidnom clipped,
                                     '</CIDADE>',
                                     '<TIPO>',
                                     lr_parametro.lgdtip clipped,
                                     '</TIPO>',
                                     '<LOGRADOURO>',
                                     lr_parametro.lgdnom clipped,
                                     '</LOGRADOURO>',
                                     '<NUMERO>',
                                     l_aux_num clipped,
                                     '</NUMERO>',
                                     '<BAIRRO>',
                                     lr_parametro.lclbrrnom clipped,
                                     '</BAIRRO>',
                                     '<CEP></CEP>',
                                     '<CODIGO></CODIGO>',
                                     '<FONETICA1>',
                                     lr_parametro.prifoncod clipped,
                                     '</FONETICA1>',
                                     '<FONETICA2>',
                                     lr_parametro.segfoncod clipped,
                                     '</FONETICA2>',
                                     '<FONETICA3>',
                                     lr_parametro.terfoncod clipped,
                                     '</FONETICA3>',
                                  '</ENDERECO>',
                               '</LISTA>',
                               '<POSICAO>',
                                  '<COORDENADAS>',
                                    '<TIPO>WGS84</TIPO>',
                                    '<X>', m_lcllgtref clipped, '</X>',
                                    '<Y>', m_lcllttref clipped, '</Y>',
                                  '</COORDENADAS>',
                               '</POSICAO>',
                            '</REQUEST>'


  end case

  return l_xml_request

end function

#-----------------------------------#
function ctx25g05_existe_uf(l_ufdcod)
#-----------------------------------#

  define l_ufdcod like glakest.ufdcod,
         l_existe smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_existe = true

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  open cctx25g05001 using l_ufdcod
  fetch cctx25g05001

  if sqlca.sqlcode = notfound then
    let l_existe = false
  end if

  close cctx25g05001

  return l_existe

end function

#----------------------------------------#
function ctx25g05_existe_cid(lr_parametro)
#----------------------------------------#

  define lr_parametro   record
         tipo_pesquisa  smallint, # 1 - GUIA POSTAL   2 - BASE MAPAS
         ufdcod         like datkmpacid.ufdcod,
         cidnom         like datkmpacid.cidnom
  end record

  define l_existe       smallint

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_existe = true

  case lr_parametro.tipo_pesquisa

     when(1) # -> PESQUISA NO GUIA POSTAL

        open cctx25g05002 using lr_parametro.cidnom,
                                lr_parametro.ufdcod
        fetch cctx25g05002

        if sqlca.sqlcode = notfound then
           let l_existe = false
        end if

        close cctx25g05002

     when(2) # -> PESQUISA NA BASE MAPAS

        open cctx25g05003 using lr_parametro.cidnom,
                                lr_parametro.ufdcod
        fetch cctx25g05003

        if sqlca.sqlcode = notfound then
           let l_existe = false
        end if

        close cctx25g05003

  end case

  return l_existe

end function

#----------------------------#
function ctx25g05_rota_ativa()
#----------------------------#

  # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA

  define l_grlchv like datkgeral.grlchv,
         l_grlinf like datkgeral.grlinf,
         l_ativa  smallint

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_grlchv = "PSOROTAATIVA" # -> CHAVE DA DATKGERAL
  let l_grlinf = null
  let l_ativa  = null

  open cctx25g05004 using l_grlchv
  fetch cctx25g05004 into l_grlinf

  if sqlca.sqlcode = notfound then
     let l_grlinf = "0"
  end if

  close cctx25g05004

  let l_ativa = l_grlinf

  return l_ativa

end function

#----------------------------------#
function ctx25g05_distancia_maxima()
#----------------------------------#

  # -> RETORNA A DISTANCIA MAXIMA P/ACIONAMENTO VIA GPS

  define l_grlchv like datkgeral.grlchv,
         l_grlinf like datkgeral.grlinf

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_grlchv = "PSOACNDSTMAX" # -> CHAVE DA DATKGERAL
  let l_grlinf = null

  open cctx25g05004 using l_grlchv
  fetch cctx25g05004 into l_grlinf

  if sqlca.sqlcode = notfound then
     let l_grlinf = null
  end if

  close cctx25g05004

  return l_grlinf

end function

#----------------------------#
function ctx25g05_qtde_rotas()
#----------------------------#

  # -> RETORNA A QUANTIDADE DE VEICULOS QUE SERAO ROTERIZADOS

  define l_grlchv like datkgeral.grlchv,
         l_grlinf like datkgeral.grlinf

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_grlchv = "PSOACNQTDROTA" # -> CHAVE DA DATKGERAL
  let l_grlinf = null

  open cctx25g05004 using l_grlchv
  fetch cctx25g05004 into l_grlinf

  if sqlca.sqlcode = notfound then
     let l_grlinf = null
  end if

  close cctx25g05004

  return l_grlinf

end function

#---------------------------#
function ctx25g05_tipo_rota()
#---------------------------#

  # -> RETORNA O TIPO DE ROTA PADRAO

  define l_grlchv like datkgeral.grlchv,
         l_grlinf like datkgeral.grlinf

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_grlchv = "PSOTIPOROTA" # -> CHAVE DA DATKGERAL
  let l_grlinf = null

  open cctx25g05004 using l_grlchv
  fetch cctx25g05004 into l_grlinf

  if sqlca.sqlcode = notfound then
     let l_grlinf = null
  end if

  close cctx25g05004

  return l_grlinf

end function

#----------------------------------#
function ctx25g05_carac_fon(l_texto)
#----------------------------------#

  define l_texto          char(50),
         l_texto_final    char(50)
         ,l_cont           smallint

  let l_texto_final = ""
  let l_cont        = null

  for l_cont = 1 to length(l_texto)

     case l_texto[l_cont]

        when("&")
           let l_texto_final = l_texto_final clipped, "&amp;"

        when("<")
           let l_texto_final = l_texto_final clipped, "&lt;"

        when(">")
           let l_texto_final = l_texto_final clipped, "&gt;"

        otherwise
           if  l_cont >= 2 then
               if  l_texto[l_cont - 1] = " " then
                   let l_texto_final = l_texto_final clipped, " ", l_texto[l_cont]
               else
                   let l_texto_final = l_texto_final clipped, l_texto[l_cont]
               end if
           else
               let l_texto_final = l_texto[l_cont]
           end if

     end case

  end for

  return l_texto_final

end function

#---------------------------------------#
function ctx25g05_sub_asterisco(l_lgdnom)
#---------------------------------------#

  # -> FUNCAO PARA SUBSTITUIR O * POR %

  define  l_lgdnom     char(60),
          l_i          smallint,
          l_tem        smallint

  let l_tem = false

  for l_i = 1 to length(l_lgdnom)
     if l_lgdnom[l_i] = "*" then
        let l_lgdnom[l_i] = "%"
        let l_tem         = true
     end if
  end for

  return l_tem,
         l_lgdnom

end function

#-------------------------------#
function ctx25g05_qtde_rotas_ac()
#-------------------------------#

  # -> RETORNA A QTD. DE ROTAS DE P/ACIONAMENTO AUTOMATICO

  define l_grlchv like datkgeral.grlchv,
         l_grlinf like datkgeral.grlinf

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_grlchv = "PSOACNQTDROTAUT" # -> CHAVE DA DATKGERAL
  let l_grlinf = null

  open cctx25g05004 using l_grlchv
  fetch cctx25g05004 into l_grlinf

  if sqlca.sqlcode = notfound then
     let l_grlinf = null
  end if

  close cctx25g05004

  return l_grlinf

end function

#----------------------------------------#
function ctx25g05_email_erro(lr_parametro)
#----------------------------------------#

  define lr_parametro   record
         xml_request    char(32000),
         xml_response   char(32000),
         assunto        char(100),
         msg_erro       char(100)
  end record

  define l_destinatario char(300),
         l_modulo       char(10),
         l_comando      char(2000),
         l_arquivo      char(20),
         l_relsgl       like igbmparam.relsgl,
         l_relpamtip    like igbmparam.relpamtip,
         l_relpamtxt    like igbmparam.relpamtxt
         
  ### RODOLFO MASSINI - INICIO 
  #---> Variaves para:
  #     remover (comentar) forma de envio de e-mails anterior e inserir
  #     novo componente para envio de e-mails.
  #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
  define lr_mail record       
         rem char(50),        
         des char(250),       
         ccp char(250),       
         cco char(250),       
         ass char(500),       
         msg char(32000),     
         idr char(20),        
         tip char(4)          
  end record 
 
  define l_anexo    char (300)
        ,l_retorno  smallint
        ,l_servidor char(30)

  initialize lr_mail
            ,l_anexo
            ,l_retorno
  to null
  
  let l_servidor  = fgl_getenv("APLSERVERNAME")
 
  ### RODOLFO MASSINI - FIM 

  let l_destinatario = null
  let l_comando      = null
  let l_modulo       = "CTX25G05"
  let l_arquivo      = "./rota_mail.txt"
  let l_relsgl       = null
  let l_relpamtip    = null
  let l_relpamtxt    = null

  start report ctx25g05_rel_erro to l_arquivo
  output to report ctx25g05_rel_erro(lr_parametro.xml_request,
                                     lr_parametro.xml_response,
                                     lr_parametro.msg_erro)
  finish report ctx25g05_rel_erro

  #Se o servico estiver indisponivel dispara e-mail para acionar plantao
  if  lr_parametro.msg_erro like "%Service not found%" then

      # CARREGA DESTINATARIOS PARA RECEBER EMAIL
      let l_relsgl = "CTX25G05"
      let l_relpamtip = 1  # REINICIAR SERVICO
      let l_destinatario = null
      open cctx25g05010 using l_relsgl,
                              l_relpamtip
      foreach cctx25g05010 into l_relpamtxt
         if l_destinatario is null then
            let l_destinatario = l_relpamtxt
         else
            let l_destinatario = l_destinatario clipped, ",", l_relpamtxt
         end if
      end foreach

      if l_destinatario is not null and l_destinatario <> " "  then
         let lr_parametro.assunto = "REINICIAR SERVICOS NOS SERVIDORES DE ROTERIZACAO"
      
         ### RODOLFO MASSINI - INICIO 
         #---> remover (comentar) forma de envio de e-mails anterior e inserir
         #     novo componente para envio de e-mails.
         #---> feito por Rodolfo Massini (F0113761) em maio/2013

         #let l_comando = 'send_email.sh',
         #                ' -a ',l_destinatario        clipped,
         #                ' -s "',lr_parametro.assunto clipped, '"',
         #                ' -f ',l_arquivo             clipped
         #run l_comando
  
         let lr_mail.ass = lr_parametro.assunto clipped
         let lr_mail.des = l_destinatario clipped
         let lr_mail.tip = "text"
         let l_anexo = l_arquivo clipped
 
         call ctx22g00_envia_email_overload(lr_mail.*
                                           ,l_anexo)
         returning l_retorno                                        
                                                
         ### RODOLFO MASSINI - FIM       
            
      end if

      let l_comando = "rm -f ", l_arquivo
      run l_comando

      return
  end if

  #Se ocorreu erro no MQ dispara e-mail para acionar plantao
  if  lr_parametro.msg_erro like "%MQCONN%" then

      # CARREGA DESTINATARIOS PARA RECEBER EMAIL
      let l_relsgl = "CTX25G05"
      let l_relpamtip = 2  # ERRO MQ
      let l_destinatario = null
      open cctx25g05010 using l_relsgl,
                              l_relpamtip
      foreach cctx25g05010 into l_relpamtxt
         if l_destinatario is null then
            let l_destinatario = l_relpamtxt
         else
            let l_destinatario = l_destinatario clipped, ",", l_relpamtxt
         end if
      end foreach

      if l_destinatario is not null and l_destinatario <> " " then
         let lr_parametro.assunto = "ERRO NO MQ INFRA.MAP EXECUTADO NA ", l_servidor clipped
        
         ### RODOLFO MASSINI - INICIO 
         #---> remover (comentar) forma de envio de e-mails anterior e inserir
         #     novo componente para envio de e-mails.
         #---> feito por Rodolfo Massini (F0113761) em maio/2013

         #let l_comando = 'send_email.sh',
         #                ' -a ',l_destinatario        clipped,
         #                ' -s "',lr_parametro.assunto clipped, '"',
         #                ' -f ',l_arquivo             clipped
         #run l_comando
           
         let lr_mail.ass = lr_parametro.assunto clipped   
         let lr_mail.des = l_destinatario clipped
         let lr_mail.tip = "text"
         let l_anexo = l_arquivo clipped
  
         call ctx22g00_envia_email_overload(lr_mail.*
                                           ,l_anexo)
         returning l_retorno                                        
                                                 
         ### RODOLFO MASSINI - FIM 
     
      end if

      let l_comando = "rm -f ", l_arquivo
      run l_comando

      return
  end if

  #Caso nao tenha sido enviado nenhum dos e-mails anteriores envia o e-mail padrao
  # CARREGA DESTINATARIOS PARA RECEBER EMAIL
  let l_relsgl = "CTX25G05"
  let l_relpamtip = 3  # ERRO GENERICO
  let l_destinatario = null
  open cctx25g05010 using l_relsgl,
                          l_relpamtip
  foreach cctx25g05010 into l_relpamtxt
     if l_destinatario is null then
        let l_destinatario = l_relpamtxt
     else
        let l_destinatario = l_destinatario clipped, ",", l_relpamtxt
     end if
  end foreach

  if l_destinatario is not null and l_destinatario <> " "  then
  
     ### RODOLFO MASSINI - INICIO 
     #---> remover (comentar) forma de envio de e-mails anterior e inserir
     #     novo componente para envio de e-mails.
     #---> feito por Rodolfo Massini (F0113761) em maio/2013

     #let l_comando = 'send_email.sh',
     #                ' -a ',l_destinatario        clipped,
     #                ' -s "',lr_parametro.assunto clipped, ' `uname -n` ', lr_parametro.msg_erro clipped, '"',
     #                ' -f ',l_arquivo             clipped
     #run l_comando
       
     let lr_mail.ass = lr_parametro.assunto clipped, l_servidor clipped, lr_parametro.msg_erro clipped     
     let lr_mail.des = l_destinatario clipped
     let lr_mail.tip = "text"
     let l_anexo = l_arquivo clipped
 
     call ctx22g00_envia_email_overload(lr_mail.*
                                       ,l_anexo)
     returning l_retorno                                        
                                                
     ### RODOLFO MASSINI - FIM  
    
  end if

  let l_comando = "rm -f ", l_arquivo
  run l_comando

end function

#------------------------------------#
report ctx25g05_rel_erro(lr_parametro)
#------------------------------------#

  define lr_parametro  record
         xml_request   char(32000),
         xml_response  char(32000),
         msg_erro      char(100)
  end record

  define l_data        date,
         l_hora        datetime hour to minute

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        let l_data = today
        let l_hora = current

     on every row

        print "DATA/HORA...: ", l_data, "/", l_hora

        skip 1 line

        print "SERVICO.....: INFRA.MAP "

        skip 1 line

        print "ERRO........: ", lr_parametro.msg_erro clipped

        skip 2 lines

        print "XML REQUEST.: ", lr_parametro.xml_request  clipped

        skip 2 lines

        print "XML RESPONSE: ", lr_parametro.xml_response clipped

end report

#------------------------------#
function ctx25g05_fator_desvio()
#------------------------------#

  # -> RETORNA O FATOR MAXIMO DE DESVIO DA DISTANCIA EM LINHA RETA
  #    PARA ROTERIZADA, NO ACIONAMENTO AUTOMATICO

  define l_grlchv like datkgeral.grlchv,
         l_grlinf like datkgeral.grlinf,
         l_fator  decimal(4,2)

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_grlchv = "PSOACNROTDIF" # -> CHAVE DA DATKGERAL
  let l_grlinf = null
  let l_fator  = null

  open cctx25g05004 using l_grlchv
  fetch cctx25g05004 into l_grlinf

  if sqlca.sqlcode = notfound then
     let l_grlinf = null
  end if

  close cctx25g05004

  if l_grlinf is null or
     l_grlinf =  " " then
     let l_grlinf = 0
  end if

  #-> CALCULA O FATOR
  let l_fator = (l_grlinf/100 + 1)

  return l_fator

end function

#-------------------------------#
function ctx25g05_desativa_rota()
#-------------------------------#

  # -> FUNCAO PARA DESATIVAR A ROTERIZACAO

  define l_grlinf like datkgeral.grlinf,
         l_grlchv like datkgeral.grlchv

  let l_grlinf = "0"            # -> DESATIVA ROTA
  let l_grlchv = "PSOROTAATIVA" # -> CHAVE DA DATKGERAL

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  if ctx25g05_rota_ativa() then
     execute pctx25g05006 using l_grlinf, l_grlchv

     call ctx25g05_email_erro("",
                              "",
                              "A ROTERIZACAO FOI DESATIVADA !",
                              "")
  end if

end function

#-------------------------------#
function ctx25g05_ativacao_rota()
#-------------------------------#

  # -> FUNCAO PARA ATIVAR A ROTERIZACAO

  define l_grlinf like datkgeral.grlinf,
         l_grlchv like datkgeral.grlchv

  let l_grlinf = "1"            # -> ATIVA ROTA
  let l_grlchv = "PSOROTAATIVA" # -> CHAVE DA DATKGERAL

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  execute pctx25g05006 using l_grlinf, l_grlchv

  call ctx25g05_email_erro("",
                           "",
                           "A ROTERIZACAO FOI ATIVADA !",
                           "")

end function

#--------------------------------#
function ctx25g05_testa_amb_rota()
#--------------------------------#

  # -> FUNCAO P/REALIZAR OS TESTES NECESSARIOS PARA
  # -> VERIFICAR SE O AMBIENTE DE ROTERIZACAO ESTA OK

  define l_online        smallint,
         l_status        integer,
         l_msg           char(1),
         l_xml_response  char(10000),
         l_doc_handle    integer,
         l_i             smallint,
         l_xml_request   char(1000),
         l_txtfilagis    char(20)

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_online       = null
  let l_status       = null
  let l_msg          = null
  let l_doc_handle   = null
  let l_online       = online()
  let l_xml_response = null
  let l_txtfilagis   = null

  display "---------------------------------------------------------------------"
  display "Teste Ambiente Naviteq"

  for l_i = 1 to 4

     case l_i

        when(1)
           display "TESTE DO SERVICO IdentificarEndereco"
           let l_xml_request =
           '<?xml version="1.0" encoding="ISO-8859-1"?>',
           '<REQUEST>',
           '<AppID>PS_CT24H_CTG2</AppID>',
           '<SERVICO>IdentificarEndereco</SERVICO>',
           '<LISTA><ENDERECO>',
           '<UF>SP</UF>',
           '<CIDADE>SAO PAULO</CIDADE>',
           '<LOGRADOURO>RIO BRANCO</LOGRADOURO>',
           '<NUMERO>1489</NUMERO>',
           '</ENDERECO>',
           '</LISTA>',
           '</REQUEST>'

        when(2)
           display "TESTE DO SERVICO IdentificarPosicao"
           let l_xml_request =
           '<?xml version="1.0" encoding="ISO-8859-1"?>',
           '<REQUEST>',
           '<AppID>PS_CT24H_CTG2</AppID>',
           '<SERVICO>IdentificarPosicao</SERVICO>',
           '<POSICAO>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-46.64626503</X>',
           '<Y>-23.53129089</Y>',
           '</COORDENADAS>',
           '</POSICAO>',
           '</REQUEST>'

        when(3)
           display "TESTE DO SERVICO SelecionarVeiculo"
           let l_xml_request =
           '<?xml version="1.0" encoding="ISO-8859-1" ?>',
           '<REQUEST>',
           '<SERVICO>SelecionarVeiculo</SERVICO>',
           '<AppID>PS_CT24H_CTG2</AppID>',
           '<CHAMADO>',
           '<ENDERECO>',
           '<DESCRICAO>TESTE</DESCRICAO>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-46.596557</X>',
           '<Y>-23.520375</Y>',
           '</COORDENADAS>',
           '</ENDERECO>',
           '<VEICULOS>',
           '<VEICULO>',
           '<ID>0</ID>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-48.646130</X>',
           '<Y>-23.531433</Y>',
           '</COORDENADAS>',
           '</VEICULO>',
           '<VEICULO>',
           '<ID>1</ID>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-52.646130</X>',
           '<Y>-20.531433</Y>',
           '</COORDENADAS>',
           '</VEICULO>',
           '<VEICULO>',
           '<ID>3</ID>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-45.646130</X>',
           '<Y>-23.531433</Y>',
           '</COORDENADAS>',
           '</VEICULO>',
           '</VEICULOS>',
           '<TIPOROTA>CURTA</TIPOROTA>',
           '</CHAMADO>',
           '</REQUEST>'

        when(4)
           display "TESTE DO SERVICO ORDENARCOORDENADA"
           let l_xml_request =
           '<?xml version="1.0" encoding="UTF-8" ?>',
           '<REQUEST>',
           '<SERVICO>OrdenarCoordenada</SERVICO>',
           '<AppID>PS_CT24H_CTG2</AppID>',
           '<LISTA>',
           '<ENDERECO>',
           '<UF>SP</UF>',
           '<CIDADE>SAO PAULO</CIDADE>',
           '<TIPO>R</TIPO>',
           '<LOGRADOURO>CAMBURIU</LOGRADOURO>',
           '<NUMERO></NUMERO>',
           '<BAIRRO>VILA IPOJUCA</BAIRRO>',
           '<CEP></CEP>',
           '<CODIGO></CODIGO>',
           '<FONETICA1>J{-SAE!!!!!!!!!</FONETICA1>',
           '<FONETICA2>J{-SAE!!!!!!!!!</FONETICA2>',
           '<FONETICA3>J{-SAE!!!!!!!!!</FONETICA3>',
           '</ENDERECO>',
           '</LISTA>',
           '<POSICAO>',
           '<COORDENADAS>',
           '<TIPO>WGS84</TIPO>',
           '<X>-46.596557</X>',
           '<Y>-23.520375</Y>',
           '</COORDENADAS>',
           '</POSICAO>',
           '</REQUEST>'

     end case

     call ctx25g05_fila_mq()
          returning l_txtfilagis

     call figrc006_enviar_pseudo_mq(l_txtfilagis,
                                    l_xml_request,
                                    l_online)
           returning l_status,
                     l_msg,
                     l_xml_response

     if l_status <> 0 then
        display "l_xml_request: ", l_xml_request clipped
        display "l_status: ", l_status clipped
        display "l_msg: ", l_msg clipped
        display "l_xml_response: ", l_xml_response clipped
        display "---------------------------------------------------------------------"
       return false
     else
        call figrc011_fim_parse()
        call figrc011_inicio_parse()
        let l_doc_handle = figrc011_parse(l_xml_response)

        # -> VERIFICA A MENSAGEM DE ERRO
        let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERRO")

        if (l_msg is not null and l_msg <> " ") then
            display "l_xml_request: ", l_xml_request clipped
            display "l_status: ", l_status clipped
            display "l_msg: ", l_msg clipped
            display "l_xml_response: ", l_xml_response clipped

            call figrc011_fim_parse()
            display "---------------------------------------------------------------------"
            return false
        end if

        # -> VERIFICA A MENSAGEM DE ERRO
        let l_msg = figrc011_xpath(l_doc_handle, "/RESPONSE/ERROR")

        if l_msg is not null and l_msg <> " " then
           display "l_xml_request: ", l_xml_request clipped
           display "l_status: ", l_status clipped
           display "l_msg: ", l_msg clipped
           display "l_xml_response: ", l_xml_response clipped

           call figrc011_fim_parse()
           display "---------------------------------------------------------------------"
           return false
        end if

        call figrc011_fim_parse()
     end if

  end for
  display "---------------------------------------------------------------------"

  return true

end function

#---------------------------#
function ctx25g05_drop_temp()
#---------------------------#

   whenever error continue
   drop table tmp_endereco
   whenever error stop

   if sqlca.sqlcode <> 0 then
      error "Erro: ", sqlca.sqlcode, " no drop da tabela tmp_endereco"
            sleep 3
   end if

end function

#------------------------------#
function ctx25g05_ordena_array()
#------------------------------#

  define l_i smallint,
         l_lclbrrnom char(65)

  let l_i = null

  for l_i = 1 to 200
     let am_exibicao[l_i].tipendtxt = null
     let am_exibicao[l_i].brrnom    = null
     let am_exibicao[l_i].cep       = null
     let am_exibicao[l_i].codigo    = null
     let am_exibicao[l_i].tipoend   = null
     let am_exibicao[l_i].lgdtip    = null
     let am_exibicao[l_i].lgdnom    = null
     let am_exibicao[l_i].latlontxt = null
  end for

  let l_i = 1

  # -> CARREGA OS REGISTROS ORDENADOS NO ARRAY
  open cctx25g05007
  foreach cctx25g05007 into am_exibicao[l_i].tipendtxt,
                            am_exibicao[l_i].brrnom,
                            l_lclbrrnom,
                            am_exibicao[l_i].cep,
                            am_exibicao[l_i].codigo,
                            am_exibicao[l_i].tipoend,
                            am_exibicao[l_i].lgdtip,
                            am_exibicao[l_i].lgdnom,
                            am_exibicao[l_i].latlontxt
                            
    
     
     
     if  l_lclbrrnom is not null and l_lclbrrnom <> " " then

         let l_lclbrrnom = am_exibicao[l_i].brrnom clipped, " - ",
                           l_lclbrrnom clipped

         let am_exibicao[l_i].brrnom    = l_lclbrrnom clipped
     end if

     let l_i = (l_i + 1)

     if l_i > 200 then
        error "Limite do array superado. ctx25g05_ordena_array() " sleep 2
        exit foreach
     end if

  end foreach
  close cctx25g05007

end function

#------------------------------#
function ctx25g05_ordena_array_auto()
#------------------------------#

  define l_i smallint

  let l_i = null

  for l_i = 1 to 200
     let am_exibicao_auto[l_i].tipendtxt = null
     let am_exibicao_auto[l_i].brrnom    = null
     let am_exibicao_auto[l_i].lclbrrnom = null
     let am_exibicao_auto[l_i].cep       = null
     let am_exibicao_auto[l_i].codigo    = null
     let am_exibicao_auto[l_i].tipoend   = null
     let am_exibicao_auto[l_i].lgdtip    = null
     let am_exibicao_auto[l_i].lgdnom    = null
  end for

  let l_i = 1

  # -> CARREGA OS REGISTROS ORDENADOS NO ARRAY
  open cctx25g05007
  foreach cctx25g05007 into am_exibicao_auto[l_i].tipendtxt,
                            am_exibicao_auto[l_i].brrnom,
                            am_exibicao_auto[l_i].lclbrrnom,
                            am_exibicao_auto[l_i].cep,
                            am_exibicao_auto[l_i].codigo,
                            am_exibicao_auto[l_i].tipoend,
                            am_exibicao_auto[l_i].lgdtip,
                            am_exibicao_auto[l_i].lgdnom

     #if  l_lclbrrnom is not null and l_lclbrrnom <> " " then
     #
     #    let l_lclbrrnom = am_exibicao_auto[l_i].brrnom clipped, " - ",
     #                      l_lclbrrnom clipped
     #
     #    let am_exibicao_auto[l_i].brrnom    = l_lclbrrnom clipped
     #end if

     let l_i = (l_i + 1)

     if l_i > 200 then
        error "Limite do array superado. ctx25g05_ordena_array() " sleep 2
        exit foreach
     end if

  end foreach
  close cctx25g05007

end function

#----------------------------#
function ctx25g05_fila_mq()
#----------------------------#

  # -> RETORNA NOME DA FILA DO SERVICO GIS

  define l_grlchv like datkgeral.grlchv,
         l_grlinf like datkgeral.grlinf

  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if

  let l_grlchv = "PSOFILAGIS" # -> CHAVE DA DATKGERAL
  let l_grlinf = null

  open cctx25g05004 using l_grlchv
  fetch cctx25g05004 into l_grlinf

  if sqlca.sqlcode = notfound then
     let l_grlinf = "CRGISJAVA01R"
  end if

  close cctx25g05004

  return l_grlinf

end function
