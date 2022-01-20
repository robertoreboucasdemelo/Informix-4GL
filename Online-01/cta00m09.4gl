###############################################################################
# Nome do Modulo: CTA00m09                                   Danilo - F011099 #
# Registro de atendimento Central de Operações 24h                   Jun/2010 #
# PSI 257664                                                                  #
###############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_cta00m09_prep smallint

#-------------------------------------------------------------------------------
function cta00m09_acesso()
 define ws_aux          char(10)
 define retorno         char(5)
 define l_matricula     char(10)
 define l_tam_matricula integer

 let retorno = "false"

 let l_matricula = g_issk.funmat
 let l_tam_matricula = length(l_matricula)
  if l_tam_matricula<=5 then
    let ws_aux = g_issk.usrtip
                ,g_issk.empcod using "&&"
                ,g_issk.funmat using "&&&&&"
  else
    let ws_aux = g_issk.usrtip
              ,"0"
              ,g_issk.funmat using "&&&&&&"
  end if
  whenever error continue
   select cponom
   from datkdominio
   where cponom="psocor_AcessoReg"
   and cpodes = ws_aux
  whenever error stop

  if sqlca.sqlcode <> 100 then
   let retorno = "true"
  end if
  return retorno
end function

#-------------------------------------------------------------------------------
function cta00m09_prepare()
#-------------------------------------------------------------------------------

  define l_sql  char(2000)
  #--Seleciona o tipo de empresa
    let l_sql = "select empsgl "
                ,"from gabkemp "
                ,"where  empcod =?"
    prepare pcta00m09001 from l_sql
    declare ccta00m09001 cursor for pcta00m09001
  #--Seleciona valores dos campos prestador e o socorrista do serviço
    let l_sql =  "select atdprscod"
                ,", srrcoddig "
                ,"from datmservico "
                ,"where atdsrvnum =? "
                ,"and   atdsrvano =?"
    prepare pcta00m09002 from l_sql
    declare ccta00m09002 cursor for pcta00m09002
  #--Seleciona valor do campo locadora do serviço
    let l_sql =  "select lcvcod "
                ,"from datmavisrent "
                ,"where  atdsrvnum =? "
                ,"and    atdsrvano =?"
    prepare pcta00m09003 from l_sql
    declare ccta00m09003 cursor for pcta00m09003
  #--seleciona descrição do tipo de cliente padrao
    let l_sql =  "select cpodes "
                ,",cpocod "
                ,"from datkdominio "
                ,"where  cpocod =?"
                ,"and cponom = 'psocor_TpCliente'"
    prepare pcta00m09004 from l_sql
    declare ccta00m09004 cursor for pcta00m09004

  #--seleciona o assunto da ligação
    let l_sql =  "select c24soltip "
                  ,"from   datmligacao "
                  ,"where  lignum =  (select min(lignum) "
                                    ,"from   datrligsrv "
                                    ,"where  atdsrvnum = ? "
                                    ,"and    atdsrvano = ?)"
    prepare pcta00m09005 from l_sql
    declare ccta00m09005 cursor for pcta00m09005
  #--seleciona codigo e descrição da tabela de dominios
    let l_sql =  "select  cpocod "
                        ,",cpodes "
                ,"from datkdominio "
                ,"where cponom = ? "
                ,"and cpocod = ?"
    prepare pcta00m09006 from l_sql
    declare ccta00m09006 cursor for pcta00m09006
  #--Verifica se possui dados de identificação no serviço retornando prestador
    let l_sql =  "select pstcoddig "
                       ,",nomgrr "
                 ,"from   dpaksocor "
                       ,",datmservico "
                 ,"where  pstcoddig = atdprscod "
                 ,"and    atdsrvnum = ? "
                 ,"and    atdsrvano = ? "
    prepare pcta00m09007 from l_sql
    declare ccta00m09007 cursor for pcta00m09007
  #--Verifica se possui dados de identificação no serviço retornando locadora
    let l_sql =  "select a.lcvcod "
                       ,",a.lcvnom "
                 ,"from   datklocadora a "
                       ,",datmservico b "
                       ,",datmavisrent c "
                 ,"where  b.atdsrvnum = c.atdsrvnum "
                 ,"and    b.atdsrvano = c.atdsrvano "
                 ,"and    c.lcvcod    = a.lcvcod "
                 ,"and    b.atdsrvnum = ? "
                 ,"and   b.atdsrvano  = ?"
    prepare pcta00m09008 from l_sql
    declare ccta00m09008 cursor for pcta00m09008
  #--Verifica se possui dados de identificação no serviço retornando socorrista
    let l_sql =   "select a.srrcoddig "
                        ,",a.srrnom "
                  ,"from   datksrr a "
                        ,",datmservico b "
                  ,"where  a.srrcoddig = b.srrcoddig "
                  ,"and    atdsrvnum   = ? "
                  ,"and    atdsrvano   = ? "
    prepare pcta00m09009 from l_sql
    declare ccta00m09009 cursor for pcta00m09009

  #--Seleciona nome de guerra do prestador / clinicas veterinarias
    let l_sql =      "select nomgrr "
                    ,"from   dpaksocor "
                    ,"where  pstcoddig = ?"
    prepare pcta00m09010 from l_sql
    declare ccta00m09010 cursor for pcta00m09010
  #--Seleciona dados do funcionarios central24h
    let l_sql =      "select funmat "
                          ,",empcod "
                          ,",usrtip "
                          ,",funnom "
                     ,"from  isskfunc "
                     ,"where funmat       = ? "
                     ,"and   rhmfunsitcod = 'A'"
    prepare pcta00m09011 from l_sql
    declare ccta00m09011 cursor for pcta00m09011
  #--Seleciona nome da locadora
    let l_sql =     "select lcvnom "
                   ,"from   datklocadora "
                   ,"where  lcvcod = ?"
    prepare pcta00m09012 from l_sql
    declare ccta00m09012 cursor for pcta00m09012

  #--Seleciona nome do socorrista
    let l_sql =      "select srrnom "
                    ,"from   datksrr "
                    ,"where  srrcoddig = ? "
    prepare pcta00m09013 from l_sql
    declare ccta00m09013 cursor for pcta00m09013
  #--Seleciona descrição do assunto
    let l_sql =    "select c24astdes "
                  ,"from   datkassunto "
                  ,"where  c24astagp = 'CO' "
                  ,"and    c24astcod = ?"
    prepare pcta00m09014 from l_sql
    declare ccta00m09014 cursor for pcta00m09014
  #--Verifica se assunto selecionado possui subassunto
    let l_sql =    "select distinct(c24astcod) "
                  ,"from datkrcuccsmtv "
                  ,"where c24astcod = ? "
    prepare pcta00m09015 from l_sql
    declare ccta00m09015 cursor for pcta00m09015
 #--Seleciona descrição do subassunto
    let l_sql =    "select   rcuccsmtvcod "
                          ,",rcuccsmtvdes "
                   ,"from    datkrcuccsmtv "
                   ,"where   c24astcod    = ? "
                   ,"and     rcuccsmtvcod = ? "
    prepare pcta00m09016 from l_sql
    declare ccta00m09016 cursor for pcta00m09016
 #--Seleciona o ultimo numero de registro
    let l_sql = "Select grlinf "
               ," from datkgeral "
               ," where grlchv = 'numregatend' "
               ," for update of grlinf "
    prepare pcta00m09017 from l_sql
    declare ccta00m09017 cursor with hold for pcta00m09017

  #--Atualiza numero de registro.
    let l_sql = "update datkgeral set(grlinf"
                                   ,",atldat"
                                   ,",atlhor"
                                   ,",atlemp"
                                   ,",atlmat) = (?,?,?,?,?) "
              ,"where grlchv = 'numregatend' "
    prepare pcta00m09018 from l_sql
   #--Insere registro de atendimento
    let l_sql =  "insert into dpamatdreg(socatdregcod"
                                      ,",atdsrvano"
                                      ,",atdsrvnum"
                                      ,",oprctrctttip"
                                      ,",oprctrclitip"
                                      ,",pstcoddig"
                                      ,",srrcoddig"
                                      ,",lcvcod"
                                      ,",clifunempcod"
                                      ,",cliusrtip"
                                      ,",clifunmat"
                                      ,",c24astcod"
                                      ,",rcuccsmtvcod"
                                      ,",atdincdat"
                                      ,",atdinchor"
                                      ,",atdfnldat"
                                      ,",atdfnlhor"
                                      ,",atdfunempcod"
                                      ,",atdusrtip"
                                      ,",atdfunmat) "
                 ,"values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    prepare pcta00m09019 from l_sql
    let l_sql = 'select max(socatdregcod) from dpamatdreg '
    prepare pcta00m09020 from l_sql
    declare ccta00m09020 cursor for pcta00m09020
    let l_sql =   "select envtipcod ",
                     "from datmsrvacp ",
                     "where atdsrvnum = ? ",
                     "and   atdsrvano = ? ",
                     "and atdsrvseq = ( select max(atdsrvseq) ",
                     "from datmsrvacp ",
                     "where atdsrvnum = ? ",
                     "and atdsrvano = ?)  "
    prepare pcta00m09021 from l_sql
    declare ccta00m09021 cursor for pcta00m09021
    let l_sql = " select atdsrvorg       ",
                " from datmservico where ",
                " atdsrvnum = ?          ",
                " and atdsrvano = ?      "
    prepare pcta00m09022 from l_sql
    declare ccta00m09022 cursor for pcta00m09022
    let l_sql = " select asitipcod       ",
                " from datmservico where ",
                " atdsrvnum = ?          ",
                " and atdsrvano = ?      "
    prepare pcta00m09023 from l_sql
    declare ccta00m09023 cursor for pcta00m09023
    let l_sql = " select socntzcod       ",
                " from datmsrvre where ",
                " atdsrvnum = ?          ",
                " and atdsrvano = ?      "
    prepare pcta00m09024 from l_sql
    declare ccta00m09024 cursor for pcta00m09024
    let l_sql = " select socntzdes       ",
                " from datksocntz where ",
                " socntzcod = ?          "
    prepare pcta00m09025 from l_sql
    declare ccta00m09025 cursor for pcta00m09025
    let l_sql = " select asitipdes       ",
                " from datkasitip where  ",
                " asitipcod = ?          "
    prepare pcta00m09026 from l_sql
    declare ccta00m09026 cursor for pcta00m09026
      let l_sql = " select atdsrvorg    ",
                " from datmservico      ",
                " where atdsrvnum = ?   ",
                " and atdsrvano = ?     "
    prepare pcta00m09027 from l_sql
    declare ccta00m09027 cursor for pcta00m09027
  let m_cta00m09_prep = true
end function
--------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
function cta00m09(servico)
#-------------------------------------------------------------------------------
  #-----------------------Declaração de variaveis-------------------------------
  define servico record
    atdsrvnum    like datmservico.atdsrvnum,               # Numero Servico
    atdsrvano    like datmservico.atdsrvano                # Ano Servico
  end record
  define atendentecentral24h record
   funmat        like isskfunc.funmat,                    # Matricula
   empcod        like isskfunc.empcod,                    # Empresa
   usrtip        like isskfunc.usrtip                     # Tipo
  end record
  define ws_servico          char(20)                     #Num serv concatenado
  define dtfinal             char(10)                     #Data final
  define hrfinal             char(8)                      #Hora final
  define ciaempcod           char(20)                     #Tipo de empresa
  define flagcdidentificacao char(1)                      #Flag Ativo/Inativo
  define flagdsidentificacao char(1)                      #Flag Ativo/Inativo
  define flagsubassunto      char(1)                      #Flag Ativo/Inativo
  define aux_cdcliente       like datkdominio.cpocod      #Copia cod tp Cliente
  define filtro              char(100)                    #filtro SQL
  define ws_atdprscod        like datmservico.atdprscod   #Código do prestador
  define ws_srrcoddig        like datmservico.srrcoddig   #Código do socorrista
  define ws_lcvcod           like datmavisrent.lcvcod     #Código da locadora
  define ws_c24astcod        like datmligacao.c24astcod   #Assunto Cadastrado
  define flaggravar          char(1)                      #Flag gravar
  define ws_aux              char(20)                     #variavel Auxiliar
  define t_cta00m09         record
           cdcontato        like datkdominio.cpocod       #Cód. contato
          ,dscontato        like datkdominio.cpodes       #Desc. contato
          ,cdcliente        like datkdominio.cpocod       #Cód. cliente
          ,dscliente        like datkdominio.cpodes       #Desc. cliente
          ,ident            char(18)                      #Label Identificação
          ,cdidentificacao  dec(8,0)                      #Cod. identificação
          ,dsidentificacao  char(40)                      #Desc. identificação
          ,cdassunto        like datkassunto.c24astcod    #Cód. do assunto
          ,dsassunto        like datkassunto.c24astdes    #Desc. do assunto
          ,sub              char(18)                      #Label SubAssunto
          ,cdsubassunto     like datkrcuccsmtv.rcuccsmtvcod  #Cód.do subassunto
          ,subassunto       like datkrcuccsmtv.rcuccsmtvdes  #Desc.do subassunto
          ,confirma         char(1)
  end record
  define l_cont             dec(2,0)
  define socatdregcod       like datmatd6523.atdnum        #Numero registro
  define l_sqlcod           smallint
  define l_mensagem         char(60)
  define retorno            char(5)
  define l_envtipcod        dec  (1,0)
  define l_status           smallint
  define l_atdsrvorg like datmservico.atdsrvorg
  call cta00m09_acesso()
  returning retorno
  if retorno = "true" then
  #-------------------------Inicializa variaveis--------------------------------
  initialize atendentecentral24h.* to null
  initialize  ciaempcod
             ,aux_cdcliente
             ,filtro
             ,ws_atdprscod
             ,ws_srrcoddig
             ,ws_lcvcod
             ,ws_c24astcod
             ,ws_aux
             ,socatdregcod  to null
  Initialize flaggravar to null
  let dtfinal = "  /  /    "
  let hrfinal = "  :  :  "
  let flagcdidentificacao = "I"
  let flagdsidentificacao = "I"
  let flagsubassunto  = "I"
  let l_status = false
  let l_atdsrvorg = null
  let ws_servico = servico.atdsrvnum using         "&&&&&&&", "-",
                   servico.atdsrvano using          "&&"
  if m_cta00m09_prep is null or
      m_cta00m09_prep <> true then
      call cta00m09_prepare()
   end if
  #----------------------- Tratamento do tipo de empresa------------------------
  open ccta00m09001 using g_documento.ciaempcod
  whenever error continue
   fetch ccta00m09001 into ciaempcod
  whenever error continue
  if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
      let ciaempcod = "S EMP"
  else
    if ciaempcod = "PORTOSEG S/A" then
       let ciaempcod = "CARTAO"
    end if

    if ciaempcod = "PORTO SERVICOS" then
       let ciaempcod = "PPS"
    end if
  end if
  #=====================================================
  # Busca Origem do Servico
  #=====================================================
    whenever error continue
    open ccta00m09027 using servico.atdsrvnum
                           ,servico.atdsrvano
    fetch ccta00m09027 into l_atdsrvorg
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_mensagem = "Erro < ",sqlca.sqlcode clipped ," > ao buscar origem do servico"
       call errorlog(l_mensagem)
    end if
  #=====================================================
  # Verifica tipo de acionamento
  #=====================================================
    whenever error continue
    open ccta00m09021 using servico.atdsrvnum
                           ,servico.atdsrvano
                           ,servico.atdsrvnum
                           ,servico.atdsrvano
    fetch ccta00m09021 into l_envtipcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let l_mensagem = "Erro < ",sqlca.sqlcode clipped ," > ao buscar tipo de envio"
       call errorlog(l_mensagem)
    end if

  #-----------------Abre formulario e atualiza dados fixos----------------------
  open window cta00m09 at 4,2 with form "cta00m09"
  attribute(form line 1)
  display  ciaempcod
           ,ws_servico
           ,g_documento.atdnum
           ,g_dadosregatendctop.dtinicial
           ,g_dadosregatendctop.hrinicial
           ,dtfinal
           ,hrfinal
           ,g_issk.funmat
           ,g_issk.funnom
  TO       cliente
           ,servico
           ,atdnum
           ,dtinicial
           ,hrinicial
           ,dtfinal
           ,hrfinal
           ,funmat
           ,funnom
  #---------------------------------Inicio do Input-----------------------------
  input by name t_cta00m09.*
        #-----------------------before-input------------------------------------
        before input
         let t_cta00m09.ident = " "
         let t_cta00m09.sub = " "
         display by name t_cta00m09.ident, t_cta00m09.sub
        #-----------------------before-cdcontato--------------------------------
        before field cdcontato
          if g_documento.reg_acionamento = true then
             case l_envtipcod
             when 0
               let t_cta00m09.cdcontato = 1
             when 1
                let t_cta00m09.cdcontato = 3
             when 2
                let t_cta00m09.cdcontato = 4
             when 3
                let t_cta00m09.cdcontato = 6
             otherwise
                if l_atdsrvorg = 8 then
                    let t_cta00m09.cdcontato = 6
                else
                     let t_cta00m09.cdcontato = null
                end if
             end case
             display by name t_cta00m09.cdcontato attribute(reverse)
             if t_cta00m09.cdcontato is not null and
                g_documento.reg_acionamento = true then
                call cta00m09_preenche_automatico(t_cta00m09.cdcontato,
                                                  servico.atdsrvnum,
                                                  servico.atdsrvano)
                     returning l_status,t_cta00m09.cdcontato
                                       ,t_cta00m09.dscontato
                                       ,t_cta00m09.cdcliente
                                       ,t_cta00m09.dscliente
                                       ,t_cta00m09.ident
                                       ,t_cta00m09.cdidentificacao
                                       ,t_cta00m09.dsidentificacao
                                       ,t_cta00m09.cdassunto
                                       ,t_cta00m09.dsassunto
                                       ,t_cta00m09.cdsubassunto
                                       ,t_cta00m09.subassunto
                if l_status = true then
                   next field confirma
                end if
             end if
          else
             display by name t_cta00m09.cdcontato attribute(reverse)
          end if
        #-----------------------after-cdcontato---------------------------------
        after field cdcontato
          display by name t_cta00m09.cdcontato
          #--Se o campo for nulo trate
          if t_cta00m09.cdcontato is null then
            call cto00m09(1,"","","","")
            returning t_cta00m09.dscontato
                      ,t_cta00m09.cdcontato
            display by name t_cta00m09.cdcontato
            display by name t_cta00m09.dscontato
            if t_cta00m09.cdcontato is null then
               next field cdcontato
            end if
          end if
          #--Consulta no banco valor digitado
          let ws_aux = "psocor_TpContato"
          Open ccta00m09006 using ws_aux
                           ,t_cta00m09.cdcontato
          whenever error continue
            fetch ccta00m09006 into t_cta00m09.cdcontato
                                   ,t_cta00m09.dscontato
          whenever error stop
          #--Se não achar abra pop-up de opções
          if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
             error "Código do contato inválido!"
             call cto00m09(1,"","","","")
             returning t_cta00m09.dscontato
                      ,t_cta00m09.cdcontato
             display by name t_cta00m09.dscontato
             next field cdcontato
          end if
          display by name t_cta00m09.dscontato
        #-----------------------before-cdcliente--------------------------------
        before field cdcliente
         display by name t_cta00m09.cdcliente attribute(reverse)

        #-----------------------after-cdcliente---------------------------------
        after field cdcliente
          display by name t_cta00m09.cdcliente
          #--Se usuario descer o controle
          if fgl_lastkey() = fgl_keyval("down")
          or fgl_lastkey() = fgl_keyval("right")
          or fgl_lastkey() = fgl_keyval("return")
          or fgl_lastkey() = fgl_keyval("tab")    then
            #--Se o campo for nulo trate
            if t_cta00m09.cdcliente is null then
               call cto00m09(2,"","","","")
               returning t_cta00m09.dscliente
                        ,t_cta00m09.cdcliente
               display by name t_cta00m09.dscliente
               next field cdcliente
            end if
            #--Consulta no banco valor digitado
            let ws_aux = "psocor_TpCliente"
            Open ccta00m09006 using ws_aux
                             ,t_cta00m09.cdcliente
            whenever error continue
              fetch ccta00m09006 into t_cta00m09.cdcliente
                                     ,t_cta00m09.dscliente
            whenever error stop

            #--Se não achar abra pop-up de opções
            if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
              error "Código do cliente inválido!"
              call cto00m09(2,"","","","")
              returning  t_cta00m09.dscliente
                        ,t_cta00m09.cdcliente
              display by name t_cta00m09.dscliente
              next field cdcliente
            end if
          end if
          display by name t_cta00m09.dscliente
          #--Trata a habilitação dos campos cdidentificacao e dsidentificacao
          #--de acordo com cada cliente
          case
              when (t_cta00m09.cdcliente = 1 or   #Agencia de Turismo
                    t_cta00m09.cdcliente = 3 or   #Clinica Veterinaria
                    t_cta00m09.cdcliente = 8)     #Prestador
                  let flagcdidentificacao = "A"
                  let t_cta00m09.ident = "Identificação.:"
                  display by name t_cta00m09.ident
                  if t_cta00m09.cdidentificacao is null then
                    Open ccta00m09007 using servico.atdsrvnum
                                             ,servico.atdsrvano
                    whenever error continue
                       fetch ccta00m09007 into t_cta00m09.cdidentificacao
                                              ,t_cta00m09.dsidentificacao
                    whenever error stop
                  end if

                  let aux_cdcliente = t_cta00m09.cdcliente
                  let ws_atdprscod = t_cta00m09.cdidentificacao
                  Initialize ws_srrcoddig
                            ,ws_lcvcod to null
                  display by name  t_cta00m09.cdidentificacao
                  display by name  t_cta00m09.dsidentificacao

                  exit case


              when (t_cta00m09.cdcliente = 12) #Socorrista
                  let flagcdidentificacao = "A"
                  let t_cta00m09.ident = "Identificação.:"
                  display by name t_cta00m09.ident
                  if t_cta00m09.cdidentificacao is null then
                    Open ccta00m09009 using servico.atdsrvnum
                                             ,servico.atdsrvano
                    whenever error continue
                      fetch ccta00m09009 into t_cta00m09.cdidentificacao
                                             ,t_cta00m09.dsidentificacao
                    whenever error stop
                  end if
                  let aux_cdcliente = t_cta00m09.cdcliente
                  let ws_srrcoddig = t_cta00m09.cdidentificacao
                  Initialize ws_atdprscod
                            ,ws_lcvcod to null
                  display by name  t_cta00m09.cdidentificacao
                  display by name  t_cta00m09.dsidentificacao

                  exit case


              when (t_cta00m09.cdcliente = 6) #Locadora
                  let flagcdidentificacao = "A"
                  let t_cta00m09.ident = "Identificação.:"
                  display by name t_cta00m09.ident
                  if t_cta00m09.cdidentificacao is null then
                    Open ccta00m09008 using servico.atdsrvnum
                                             ,servico.atdsrvano
                    whenever error continue
                      fetch ccta00m09008 into t_cta00m09.cdidentificacao
                                               ,t_cta00m09.dsidentificacao
                    whenever error stop
                  end if

                  let aux_cdcliente = t_cta00m09.cdcliente
                  let ws_lcvcod = t_cta00m09.cdidentificacao
                  Initialize ws_atdprscod
                            ,ws_srrcoddig to null
                  display by name  t_cta00m09.cdidentificacao
                  display by name  t_cta00m09.dsidentificacao
                  exit case


              when (t_cta00m09.cdcliente = 4 or    #CT24HS
                    t_cta00m09.cdcliente = 5 or    #Help Desk Casa
                    t_cta00m09.cdcliente = 17)     #Operador CO
                  let flagcdidentificacao = "A"
                  let t_cta00m09.ident = "Identificação.:"
                  display by name t_cta00m09.ident
                  Initialize ws_atdprscod
                            ,ws_srrcoddig
                            ,ws_lcvcod to null
                  exit case


              otherwise
                  #--Qualquer outra opção trate desta forma
                  let flagcdidentificacao = "I"
                  let aux_cdcliente = t_cta00m09.cdcliente
                  initialize t_cta00m09.cdidentificacao to null
                  initialize t_cta00m09.dsidentificacao to null
                  Initialize ws_atdprscod
                            ,ws_srrcoddig
                            ,ws_lcvcod to null
                  let t_cta00m09.ident = " "
                  display by name t_cta00m09.ident
           end case
          #--Verificar se variavel aux. mudou seu valor e seta campos
          if aux_cdcliente <> t_cta00m09.cdcliente then
                initialize t_cta00m09.cdidentificacao to null
                initialize t_cta00m09.dsidentificacao to null
          end if
           #--Se usuario subir o controle
           if  fgl_lastkey() = fgl_keyval("up")
           or  fgl_lastkey() = fgl_keyval("left") then
              next field cdcontato
           end if
           #--Se usuario descer o controle e o campo cdidentificacao Inativo
           if (fgl_lastkey() = fgl_keyval("down")
           or  fgl_lastkey() = fgl_keyval("right")
           or  fgl_lastkey() = fgl_keyval("return")
           or  fgl_lastkey() = fgl_keyval("tab"))
              and flagcdidentificacao = "I" then
              display by name t_cta00m09.cdidentificacao
              display by name t_cta00m09.dsidentificacao
              next field cdassunto
           end if
           #--Se usuario descer o controle e o campo cdidentificacao Ativo
           if (fgl_lastkey() = fgl_keyval("down")
           or  fgl_lastkey() = fgl_keyval("right")
           or  fgl_lastkey() = fgl_keyval("return")
           or  fgl_lastkey() = fgl_keyval("tab"))
           and flagcdidentificacao = "A" then
              display by name t_cta00m09.cdidentificacao
              display by name t_cta00m09.dsidentificacao
              next field cdidentificacao
           end if
          #-----------------------before-cdidentificacao------------------------
          before field cdidentificacao
              display by name t_cta00m09.cdidentificacao attribute(reverse)
          #-----------------------after-cdidentificacao-------------------------
          after field cdidentificacao
              display by name t_cta00m09.cdidentificacao
              let aux_cdcliente = t_cta00m09.cdcliente
              let flagdsidentificacao = "A"
              #--Se usuario descer o controle
              if fgl_lastkey() = fgl_keyval("down")
              or fgl_lastkey() = fgl_keyval("right")
              or fgl_lastkey() = fgl_keyval("return")
              or fgl_lastkey() = fgl_keyval("tab")  then
                #--Consulta pelo campo cdcdidentificacao
                case  t_cta00m09.cdcliente
                #-----------------------------caso 1------------------------------
                when 1
                    #--Entra somente se o campo nao estiver vazio
                    if t_cta00m09.cdidentificacao is not null then
                        #--Consulta no banco valor digitado
                        open ccta00m09010 using t_cta00m09.cdidentificacao
                        whenever error continue
                          fetch ccta00m09010 into t_cta00m09.dsidentificacao
                        whenever error stop
                        #--Se não achar informar ao usuario
                        if  sqlca.sqlcode=100 or sqlca.sqlcode < 0 then
                          initialize t_cta00m09.cdidentificacao to null
                          initialize t_cta00m09.dsidentificacao to null
                          display by name t_cta00m09.dsidentificacao
                          error "Código de indentificação não localizado!"
                          next field cdidentificacao
                        end if
                        #Se achar atualiza tela
                        if  sqlca.sqlcode=0 then
                          let flagdsidentificacao = "I"
                          let ws_atdprscod = t_cta00m09.cdidentificacao
                          Initialize ws_srrcoddig
                                    ,ws_lcvcod to null
                          display by name t_cta00m09.dsidentificacao
                        end if
                      end if
                    exit case
                #-----------------------------caso 3------------------------------
                when 3
                    #--Entra somente se o campo nao estiver vazio
                    if t_cta00m09.cdidentificacao is not null then
                        #--Consulta no banco valor digitado
                        open ccta00m09010 using t_cta00m09.cdidentificacao
                        whenever error continue
                          fetch ccta00m09010 into t_cta00m09.dsidentificacao
                        whenever error stop
                        #--Se não achar informar ao usuario
                        if  sqlca.sqlcode=100 or sqlca.sqlcode < 0 then
                          initialize t_cta00m09.cdidentificacao to null
                          initialize t_cta00m09.dsidentificacao to null
                          display by name t_cta00m09.dsidentificacao
                          error "Código de indentificação não localizado!"
                          next field cdidentificacao
                        end if
                        #Se achar atualiza tela
                        if  sqlca.sqlcode=0 then
                          let flagdsidentificacao = "I"
                          let ws_atdprscod = t_cta00m09.cdidentificacao
                          Initialize ws_srrcoddig
                                    ,ws_lcvcod to null
                          display by name t_cta00m09.dsidentificacao
                        end if
                      end if
                    exit case
                #-----------------------------caso 4----------------------------
                when 4
                   let flagdsidentificacao = "I"
                   #--Se campo vazio informar ao usuario
                   if t_cta00m09.cdidentificacao is null then
                     error "Informe a matricula do colaborador CT24H."
                     next field cdidentificacao
                   end if
                   #--Consulta no banco valor digitado
                   open ccta00m09011 using t_cta00m09.cdidentificacao
                   whenever error continue
                     fetch ccta00m09011 into atendentecentral24h.funmat
                                 ,atendentecentral24h.empcod
                                 ,atendentecentral24h.usrtip
                                 ,t_cta00m09.dsidentificacao
                   whenever error stop
                   #--se tiver mais de um registro abrir pop-up
                   if SQLCA.SQLERRD[3] > 1 then
                     call cto00m09(5,"",t_cta00m09.cdidentificacao,"","")
                     returning  t_cta00m09.dsidentificacao
                               ,t_cta00m09.cdidentificacao
                               ,atendentecentral24h.empcod
                               ,atendentecentral24h.usrtip
                     let atendentecentral24h.funmat = t_cta00m09.cdidentificacao
                     display by name  t_cta00m09.dsidentificacao
                                     ,t_cta00m09.cdidentificacao
                     next field cdassunto
                   end if
                   #--Qualquer erro informe o usuario
                   if  sqlca.sqlcode =  100
                   or (sqlca.sqlcode <  0
                   and sqlca.sqlcode <> -284 )then
                     error "Matricula inválida!"
                     next field cdidentificacao
                   end if
                   let t_cta00m09.cdidentificacao = atendentecentral24h.funmat
                   display by name t_cta00m09.dsidentificacao
                   exit case

                #-----------------------------caso 5----------------------------
                when 5
                   let flagdsidentificacao = "I"
                   #--Se campo vazio informar ao usuario
                   if t_cta00m09.cdidentificacao is null then
                     error "Informe a matricula do colaborador CT24H."
                     next field cdidentificacao
                   end if
                   #--Consulta no banco valor digitado
                   open ccta00m09011 using t_cta00m09.cdidentificacao
                   whenever error continue
                     fetch ccta00m09011 into atendentecentral24h.funmat
                                 ,atendentecentral24h.empcod
                                 ,atendentecentral24h.usrtip
                                 ,t_cta00m09.dsidentificacao
                   whenever error stop
                   #--se tiver mais de um registro abrir pop-up
                   if SQLCA.SQLERRD[3] > 1 then
                     call cto00m09(5,"",t_cta00m09.cdidentificacao,"","")
                     returning  t_cta00m09.dsidentificacao
                               ,t_cta00m09.cdidentificacao
                               ,atendentecentral24h.empcod
                               ,atendentecentral24h.usrtip
                     let atendentecentral24h.funmat = t_cta00m09.cdidentificacao
                     display by name  t_cta00m09.dsidentificacao
                                     ,t_cta00m09.cdidentificacao
                     next field cdassunto
                   end if
                   #--Qualquer erro informe o usuario
                   if  sqlca.sqlcode =  100
                   or (sqlca.sqlcode <  0
                   and sqlca.sqlcode <> -284 )then
                     error "Matricula inválida!"
                     next field cdidentificacao
                   end if
                   let t_cta00m09.cdidentificacao = atendentecentral24h.funmat
                   display by name t_cta00m09.dsidentificacao
                   exit case

                #-----------------------------caso 6----------------------------
                when 6
                    #--Entra somente se o campo nao estiver vazio
                    if t_cta00m09.cdidentificacao is not null then
                        #--Consulta no banco valor digitado
                        open ccta00m09012 using t_cta00m09.cdidentificacao
                        whenever error continue
                          fetch ccta00m09012 into t_cta00m09.dsidentificacao
                        whenever error stop
                        #--Se não achar informar ao usuario
                        if  sqlca.sqlcode=100 or sqlca.sqlcode < 0 then
                          initialize t_cta00m09.cdidentificacao to null
                          initialize t_cta00m09.dsidentificacao to null
                          display by name t_cta00m09.dsidentificacao
                          error "Código de indentificação não localizado!"
                          next field cdidentificacao
                        end if
                        #--Se achar atualizar tela
                        if  sqlca.sqlcode=0 then
                          let flagdsidentificacao = "I"
                          let ws_lcvcod = t_cta00m09.cdidentificacao
                          Initialize ws_atdprscod
                                    ,ws_srrcoddig to null
                          display by name t_cta00m09.dsidentificacao
                        end if
                      end if
                    exit case
                #-----------------------------caso 8----------------------------
                when 8
                    #--Entra somente se o campo nao estiver vazio
                    if t_cta00m09.cdidentificacao is not null then
                        #--Consulta no banco valor digitado
                        open ccta00m09010 using t_cta00m09.cdidentificacao
                        whenever error continue
                          fetch ccta00m09010 into t_cta00m09.dsidentificacao
                        whenever error stop
                        #--Se não achar informar ao usuario
                        if  sqlca.sqlcode=100 or sqlca.sqlcode < 0 then
                          initialize t_cta00m09.cdidentificacao to null
                          initialize t_cta00m09.dsidentificacao to null
                          display by name t_cta00m09.dsidentificacao
                          error "Código de indentificação não localizado!"
                          next field cdidentificacao
                        end if
                        #--Se achar atualizar tela
                        if  sqlca.sqlcode=0 then
                          let flagdsidentificacao = "I"
                          let ws_atdprscod = t_cta00m09.cdidentificacao
                          Initialize ws_srrcoddig
                                    ,ws_lcvcod to null
                          display by name t_cta00m09.dsidentificacao
                        end if
                      end if
                    exit case
                #-----------------------------caso 12---------------------------
                when 12
                    #--Entra somente se o campo nao estiver vazio
                    if t_cta00m09.cdidentificacao is not null then
                        --Consulta no banco valor digitado
                        Open ccta00m09013 using t_cta00m09.cdidentificacao
                        whenever error continue
                          fetch ccta00m09013 into t_cta00m09.dsidentificacao
                        whenever error stop
                        #--Se não achar informar ao usuario
                        if  sqlca.sqlcode=100 or sqlca.sqlcode < 0 then
                          initialize t_cta00m09.cdidentificacao to null
                          initialize t_cta00m09.dsidentificacao to null
                          display by name t_cta00m09.dsidentificacao
                          error "Código de indentificação não localizado!"
                          next field cdidentificacao
                        end if
                        #--Se achar atualizar tela
                        if  sqlca.sqlcode=0 then
                          let flagdsidentificacao = "I"
                          let ws_srrcoddig = t_cta00m09.cdidentificacao
                          Initialize ws_atdprscod
                                    ,ws_lcvcod to null
                          display by name t_cta00m09.dsidentificacao
                        end if
                      end if
                    exit case
                #-----------------------------caso 17----------------------------
                when 17
                   let flagdsidentificacao = "I"
                   #--Se campo vazio informar ao usuario
                   if t_cta00m09.cdidentificacao is null then
                     error "Informe a matricula do colaborador CT24H."
                     next field cdidentificacao
                   end if
                   #--Consulta no banco valor digitado
                   open ccta00m09011 using t_cta00m09.cdidentificacao
                   whenever error continue
                     fetch ccta00m09011 into atendentecentral24h.funmat
                                 ,atendentecentral24h.empcod
                                 ,atendentecentral24h.usrtip
                                 ,t_cta00m09.dsidentificacao
                   whenever error stop
                   #--se tiver mais de um registro abrir pop-up
                   if SQLCA.SQLERRD[3] > 1 then
                     call cto00m09(5,"",t_cta00m09.cdidentificacao,"","")
                     returning  t_cta00m09.dsidentificacao
                               ,t_cta00m09.cdidentificacao
                               ,atendentecentral24h.empcod
                               ,atendentecentral24h.usrtip
                     let atendentecentral24h.funmat = t_cta00m09.cdidentificacao
                     display by name  t_cta00m09.dsidentificacao
                                     ,t_cta00m09.cdidentificacao
                     next field cdassunto
                   end if
                   #--Qualquer erro informe o usuario
                   if  sqlca.sqlcode =  100
                   or (sqlca.sqlcode <  0
                   and sqlca.sqlcode <> -284 )then
                     error "Matricula inválida!"
                     next field cdidentificacao
                   end if
                   let t_cta00m09.cdidentificacao = atendentecentral24h.funmat
                   display by name t_cta00m09.dsidentificacao
                   exit case
                end case
              end if
              #--Se usuario descer o controle e campo dsidentificacao inativo
              if (fgl_lastkey() = fgl_keyval("down")
              or  fgl_lastkey() = fgl_keyval("right")
              or  fgl_lastkey() = fgl_keyval("return")
              or  fgl_lastkey() = fgl_keyval("tab"))
              and flagdsidentificacao ="I"  then
                  next field cdassunto
              end if
              #--Se usuario descer o controle e campo dsidentificacao Ativo
              if (fgl_lastkey() = fgl_keyval("down")
              or  fgl_lastkey() = fgl_keyval("right")
              or  fgl_lastkey() = fgl_keyval("return")
              or  fgl_lastkey() = fgl_keyval("tab"))
              and flagdsidentificacao ="A"  then
                  initialize t_cta00m09.dsidentificacao to null
                  next field dsidentificacao
              end if
          #-----------------------before-dsidentificacao------------------------
          before field dsidentificacao
               display by name t_cta00m09.dsidentificacao attribute(reverse)

          #-----------------------after-dsidentificacao-------------------------
          after field dsidentificacao
              display by name t_cta00m09.dsidentificacao
              #--Se usuario descer o controle
              if fgl_lastkey() = fgl_keyval("down")
              or fgl_lastkey() = fgl_keyval("right")
              or fgl_lastkey() = fgl_keyval("return")
              or fgl_lastkey() = fgl_keyval("tab")  then
                case  t_cta00m09.cdcliente
                #-----------------------------caso 1----------------------------
                when 1
                    #--Se tamanho digitado no campo for maior que 3 faça
                    if length(t_cta00m09.dsidentificacao)>2 then
                      #--Chama pop-up passando a filtro
                      let filtro = t_cta00m09.dsidentificacao clipped
                      call cto00m09(6,"","",filtro,3)
                      returning t_cta00m09.dsidentificacao
                               ,t_cta00m09.cdidentificacao
                      #--atualizar tela
                      display by name t_cta00m09.dsidentificacao
                                     ,t_cta00m09.cdidentificacao
                      next field cdidentificacao
                    else
                      #--Se der erro informar usuario
                      Error "Verifique os critérios de pesquisa."
                      next field dsidentificacao
                    end if
                    exit case
                #-----------------------------caso 3----------------------------
                when 3
                    #--Se tamanho digitado no campo for maior que 3 faça
                    if length(t_cta00m09.dsidentificacao)>2 then
                      #--Chama pop-up passando a filtro
                      let filtro = t_cta00m09.dsidentificacao clipped
                      call cto00m09(6,"","",filtro,3)
                      returning t_cta00m09.dsidentificacao
                               ,t_cta00m09.cdidentificacao
                      #--atualizar tela
                      display by name t_cta00m09.dsidentificacao
                                     ,t_cta00m09.cdidentificacao
                      next field cdidentificacao
                    else
                      #--Se der erro informar usuario
                      Error "Verifique os critérios de pesquisa."
                      next field dsidentificacao
                    end if
                    exit case
                #-----------------------------caso 6----------------------------
                when 6
                    #--Se tamanho digitado no campo for maior que 3 faça
                    if length(t_cta00m09.dsidentificacao)>2 then
                      #--Chama pop-up passando a filtro
                      let filtro = t_cta00m09.dsidentificacao clipped
                      call cto00m09(6,"","",filtro,6)
                      returning t_cta00m09.dsidentificacao
                               ,t_cta00m09.cdidentificacao
                       #--atualizar tela
                      display by name t_cta00m09.dsidentificacao
                                     ,t_cta00m09.cdidentificacao
                      next field cdidentificacao
                    else
                      #--Se der erro informar usuario
                      Error "Verifique os critérios de pesquisa."
                      next field dsidentificacao
                    end if
                    exit case
                #-----------------------------caso 8----------------------------
                when 8
                    #--Se tamanho digitado no campo for maior que 3 faça
                    if length(t_cta00m09.dsidentificacao)>2 then
                      #--Chama pop-up passando a filtro
                      let filtro = t_cta00m09.dsidentificacao clipped
                      call cto00m09(6,"","",filtro,8)
                      returning t_cta00m09.dsidentificacao
                               ,t_cta00m09.cdidentificacao
                      #--atualizar tela
                      display by name t_cta00m09.dsidentificacao
                                     ,t_cta00m09.cdidentificacao
                      next field cdidentificacao
                    else
                      #--Se der erro informar usuario
                      Error "Verifique os critérios de pesquisa."
                      next field dsidentificacao
                    end if
                    exit case
                #-----------------------------caso 12---------------------------
                when 12
                    #--Se tamanho digitado no campo for maior que 3 faça
                    if length(t_cta00m09.dsidentificacao)>2 then

                      #--Chama pop-up passando a filtro
                      let filtro = t_cta00m09.dsidentificacao clipped
                      call cto00m09(6,"","",filtro,12)
                      returning t_cta00m09.dsidentificacao
                               ,t_cta00m09.cdidentificacao
                      #--atualizar tela
                      display by name t_cta00m09.dsidentificacao
                                     ,t_cta00m09.cdidentificacao
                      next field cdidentificacao
                    else
                      #--Se der erro informar usuario
                      Error "Verifique os critérios de pesquisa."
                      next field dsidentificacao
                    end if
                    exit case
                end case
              end if
          #-----------------------before-cdassunto------------------------------
          before field cdassunto
            display by name t_cta00m09.cdassunto attribute(reverse)

          #-----------------------after-cdassunto-------------------------------
          after field cdassunto
            display by name t_cta00m09.cdassunto

            if fgl_lastkey() = fgl_keyval("down")
            or fgl_lastkey() = fgl_keyval("right")
            or fgl_lastkey() = fgl_keyval("return")
            or fgl_lastkey() = fgl_keyval("tab")  then
                #--se o campo estiver vazio chama pop-up com opções
                if t_cta00m09.cdassunto is null then
                  call cto00m09(3,"","","","")
                  returning t_cta00m09.dsassunto
                           ,t_cta00m09.cdassunto
                  display by name t_cta00m09.dsassunto
                  next field cdassunto
                end if
                #--Consulta no banco valor digitado
                open ccta00m09014 using t_cta00m09.cdassunto
                whenever error continue
                  fetch ccta00m09014 into t_cta00m09.dsassunto
                whenever error stop
                #--Se nao encontrar valor digitado chama pop-up com opções
                if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
                  error "Código do assunto inválido!"
                  call cto00m09(3,"","","","")
                  returning t_cta00m09.dsassunto
                           ,t_cta00m09.cdassunto
                  display by name t_cta00m09.dsassunto
                  next field cdassunto
                end if
             end if
             display by name t_cta00m09.dsassunto
             #--Verifica se assunto selecionado possui subassunto
             Open ccta00m09015 using t_cta00m09.cdassunto
             whenever error continue
               fetch ccta00m09015
             whenever error stop
             #--Se possuir habilita campo de subassunto, senão desabilita
             if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
              let flagsubassunto = "I"
             else
              let flagsubassunto = "A"
             end if
            #--Se usuario subir o controle e cdidentificacao inativo
            if (fgl_lastkey() = fgl_keyval("up")
            or  fgl_lastkey() = fgl_keyval("left"))
            and flagcdidentificacao = "I" then
              next field cdcliente
            end if
            #--Se usuario subir o controle e cdidentificacao ativo
            #--e sidentificacao inativo
            if (fgl_lastkey() = fgl_keyval("up")
            or  fgl_lastkey() = fgl_keyval("left"))
            and flagcdidentificacao = "A"
            and flagdsidentificacao = "I" then
              next field cdidentificacao
            end if
            #--Se usuario subir o controle e cdidentificacao ativo
            #--e sidentificacao ativo
            if (fgl_lastkey() = fgl_keyval("up")
            or  fgl_lastkey() = fgl_keyval("left"))
            and flagcdidentificacao = "A"
            and flagcdidentificacao = "A" then
              next field dsidentificacao
            end if
            #--Se usuario descer o controle e subassunto inativo
            if (fgl_lastkey() = fgl_keyval("down")
            or  fgl_lastkey() = fgl_keyval("right")
            or  fgl_lastkey() = fgl_keyval("return")
            or  fgl_lastkey() = fgl_keyval("tab"))
            and flagsubassunto = "I" then
              let t_cta00m09.sub = " "
              display by name t_cta00m09.sub
              initialize t_cta00m09.cdsubassunto to null
              initialize t_cta00m09.subassunto to null
              display by name t_cta00m09.cdsubassunto
              display by name t_cta00m09.subassunto
              next field confirma
            end if
            #--Se usuario descer o controle e subassunto ativo
            if (fgl_lastkey() = fgl_keyval("down")
            or  fgl_lastkey() = fgl_keyval("right")
            or  fgl_lastkey() = fgl_keyval("return")
            or  fgl_lastkey() = fgl_keyval("tab"))
            and flagsubassunto = "A" then
              let t_cta00m09.sub = "SubAssunto....:"
              display by name t_cta00m09.sub
              next field cdsubassunto
            end if
          #-----------------------before-cdsubassunto-------------------------------
          before field cdsubassunto
           display by name t_cta00m09.cdsubassunto attribute(reverse)
          #-----------------------after-cdsubassunto--------------------------------
          after field cdsubassunto
            display by name t_cta00m09.cdsubassunto
            #--Se usuario descer o controle
            if fgl_lastkey() = fgl_keyval("down")
            or fgl_lastkey() = fgl_keyval("right")
            or fgl_lastkey() = fgl_keyval("return")
            or fgl_lastkey() = fgl_keyval("tab")  then
            #--Verifica se o campo esta vazio e chama pop-up de opções
            if t_cta00m09.cdsubassunto is null then
              call cto00m09(4,t_cta00m09.cdassunto,"","","")
              returning t_cta00m09.subassunto
                       ,t_cta00m09.cdsubassunto
              display by name t_cta00m09.subassunto
              next field cdsubassunto
            end if
            #--Verifica se valor digitado esta correto
            open ccta00m09016 using t_cta00m09.cdassunto
                                   ,t_cta00m09.cdsubassunto
            whenever error continue
              fetch ccta00m09016 into t_cta00m09.cdsubassunto
                                     ,t_cta00m09.subassunto
            whenever error stop
            #--se nao encontrar chamar pop-up de opções
            if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
              error "Código do subassunto inválido!"
              call cto00m09(4,t_cta00m09.cdassunto,"","","")
              returning t_cta00m09.subassunto
                       ,t_cta00m09.cdsubassunto
              display by name t_cta00m09.subassunto
              next field cdsubassunto
            end if
          end if
          display by name t_cta00m09.subassunto
          #-----------------------before-confirma-------------------------------
          before field confirma
            display by name t_cta00m09.confirma attribute(reverse)

          #-----------------------after-confirma--------------------------------
          after field confirma
            display by name t_cta00m09.confirma
            if t_cta00m09.confirma = "S" then
                  let flaggravar = "S"
                  if t_cta00m09.cdcontato is null then
                      error "É necessário informar o tipo de contato."
                      let flaggravar = "N"
                      next field cdcontato
                  end if
                  if t_cta00m09.cdcliente is null then
                      error "É necessário informar o tipo de cliente."
                      let flaggravar = "N"
                      next field cdcliente
                  end if

                  if t_cta00m09.cdassunto is null then
                      error "É necessário informar um assunto."
                      let flaggravar = "N"
                      next field cdassunto
                  end if
                  if flaggravar = "S" then
                     whenever error continue
                     set lock mode to not wait
                     while true
                      let l_cont = l_cont + 1
                      call cta00m09_gerar_numero_registro()
                           returning socatdregcod
                                    ,l_sqlcod
                                    ,l_mensagem
                      if l_sqlcod <> 0  then
                              if l_sqlcod = -243 or
                                 l_sqlcod = -244 or
                                 l_sqlcod = -245 or
                                 l_sqlcod = -246 then
                                 if l_cont < 11  then
                                    sleep 1
                                    continue while
                                 else
                                    error " Numero do Atendimento travado! Avise a Informatica" sleep 2
                                 end if
                              else
                                 error l_mensagem sleep 1
                                 exit input
                              end if
                       end if
                       exit while
                      end while
                      set lock mode to wait
                      whenever error stop

                     Call cta00m09_gravar_registro(socatdregcod
                                                  ,servico.atdsrvano
                                                  ,servico.atdsrvnum
                                                  ,t_cta00m09.cdcontato
                                                  ,t_cta00m09.cdcliente
                                                  ,ws_atdprscod
                                                  ,ws_srrcoddig
                                                  ,ws_lcvcod
                                                  ,atendentecentral24h.empcod
                                                  ,atendentecentral24h.usrtip
                                                  ,atendentecentral24h.funmat
                                                  ,t_cta00m09.cdassunto
                                                  ,t_cta00m09.cdsubassunto
                                                  ,g_dadosregatendctop.dtinicial
                                                  ,g_dadosregatendctop.hrinicial
                                                  ,today
                                                  ,current hour to second
                                                  ,g_issk.empcod
                                                  ,g_issk.usrtip
                                                  ,g_issk.funmat)
                   end if
                  exit input
            else
              if t_cta00m09.confirma = "N" then
                next field cdcontato
              else
                error "Opção Inválida."
                next field confirma
              end if
            end if
            if (fgl_lastkey() = fgl_keyval("up")
                or fgl_lastkey() = fgl_keyval("left"))
                and flagsubassunto = "I" then
                let t_cta00m09.sub = " "
                display by name t_cta00m09.sub
                next field cdassunto
            end if
            if (fgl_lastkey() = fgl_keyval("up")
                or fgl_lastkey() = fgl_keyval("left"))
                and flagsubassunto = "A" then
                let t_cta00m09.sub = "SubAssunto....:"
                display by name t_cta00m09.sub
                next field subassunto
            end if
            if fgl_lastkey() = fgl_keyval("down")
                or fgl_lastkey() = fgl_keyval("right")
                or fgl_lastkey() = fgl_keyval("return")
                or fgl_lastkey() = fgl_keyval("tab") then
                next field cdcontato
            end if
            on key (interrupt,control-c)
              error "Comando invalido, utilize a opção confirmar."
              next field cdcontato
     end input
    close window cta00m09
    end if
end function


#-------------------------------------------------------------------------------
function cta00m09_gerar_numero_registro()
#-------------------------------------------------------------------------------
  #---------------------------Define variaveis----------------------------------
  define altdata            date                          #Dt alt num registro
  define althora            datetime hour to second       #hr alt num registro
  define lr_retorno       record
          socatdregcod     like datmatd6523.atdnum        #Numero registro
         ,sqlcod           smallint
         ,mensagem         char(60)
  end record
  define lr_datkgeral record
         grlchv   like datkgeral.grlchv,
         grlinf   like datkgeral.grlinf
  end record
  #---------------Recupera e atualiza numero de registro na datkgeral-----------
    let lr_datkgeral.grlchv = 'numregatend'
    let altdata = today
    let althora = current hour to second
    open ccta00m09017
    whenever error continue
      fetch ccta00m09017 into lr_retorno.socatdregcod
    whenever error stop
   if sqlca.sqlcode <> 0  then
      if sqlca.sqlcode = 100 then
         open ccta00m09020
         whenever error continue
         fetch ccta00m09020 into lr_datkgeral.grlinf
         whenever error stop
         if sqlca.sqlcode = 100 or
            lr_datkgeral.grlinf is null then
            let lr_datkgeral.grlinf = '0'
         end if
         call cta12m00_inclui_datkgeral(lr_datkgeral.grlchv,
                                        lr_datkgeral.grlinf,
                                        altdata,
                                        althora,
                                        g_issk.empcod,
                                        g_issk.funmat)
              returning lr_retorno.sqlcod,lr_retorno.mensagem
              if lr_retorno.sqlcod = 1 then
                 let lr_retorno.sqlcod = 0
              end if
      let lr_retorno.socatdregcod = lr_datkgeral.grlinf
      else
        let lr_retorno.sqlcod   = sqlca.sqlcode
        let lr_retorno.mensagem = " Erro <",lr_retorno.sqlcod, "> na busca do numero de registro! "
        let lr_retorno.socatdregcod   = null
        error lr_retorno.mensagem
        call errorlog(lr_retorno.mensagem)
        close  ccta00m09017
      return lr_retorno.*
      end if
   end if
   let lr_retorno.socatdregcod = lr_retorno.socatdregcod+1
   let altdata = today
   let althora = current hour to second
   whenever error continue
   execute pcta00m09018 using lr_retorno.socatdregcod
                             ,altdata
                             ,althora
                             ,g_issk.empcod
                             ,g_issk.funmat
   whenever error stop
   if sqlca.sqlcode <> 0  then
      let lr_retorno.sqlcod   = sqlca.sqlcode
      let lr_retorno.mensagem = " Erro <",lr_retorno.sqlcod ,">na atualizacao do Nro. de registro! "
      error lr_retorno.mensagem
      let lr_retorno.socatdregcod   = null
      call errorlog(lr_retorno.mensagem)
   end if
   whenever error continue
   close  ccta00m09017
   whenever error stop

   return lr_retorno.*

end function


#-------------------------------------------------------------------------------
function cta00m09_gravar_registro(param)
#-------------------------------------------------------------------------------
  define param              record
         socatdregcod       like dpamatdreg.socatdregcod  #Numero registro
        ,atdsrvano          like dpamatdreg.atdsrvano     #Ano Servico
        ,atdsrvnum          like dpamatdreg.atdsrvnum     #Num Servico
        ,oprctrctttip       like dpamatdreg.oprctrctttip  #Tp Contato
        ,oprctrclitip       like dpamatdreg.oprctrclitip  #Tp Cliente
        ,pstcoddig          like dpamatdreg.pstcoddig     #Cod Prestador
        ,srrcoddig          like dpamatdreg.srrcoddig     #Cod Socorrista
        ,lcvcod             like dpamatdreg.lcvcod        #Cod Locadora
        ,clifunempcod       like dpamatdreg.clifunempcod  #Cliente func emmpcod
        ,cliusrtip          like dpamatdreg.cliusrtip     #Cliente func tipo
        ,clifunmat          like dpamatdreg.clifunmat     #cliente func matric.
        ,c24astcod          like dpamatdreg.c24astcod     #Código assunto
        ,rcuccsmtvcod       like dpamatdreg.rcuccsmtvcod  #código Subassunto
        ,atdincdat          like dpamatdreg.atdincdat     #Data inicial
        ,atdinchor          like dpamatdreg.atdinchor     #Hora inicial
        ,atdfnldat          like dpamatdreg.atdfnldat     #Data fim
        ,atdfnlhor          like dpamatdreg.atdfnlhor     #Hora fim
        ,atdfunempcod       like dpamatdreg.atdfunempcod  #Atendente Empcod
        ,atdusrtip          like dpamatdreg.atdusrtip     #Atendente Tipo
        ,atdfunmat          like dpamatdreg.atdfunmat     #Atendente Matricula
  end record
  define lr_retorno record
         sqlcode   smallint,
         mens      char(300)
  end record
   whenever error continue
    execute pcta00m09019 using param.socatdregcod
                              ,param.atdsrvano
                              ,param.atdsrvnum
                              ,param.oprctrctttip
                              ,param.oprctrclitip
                              ,param.pstcoddig
                              ,param.srrcoddig
                              ,param.lcvcod
                              ,param.clifunempcod
                              ,param.cliusrtip
                              ,param.clifunmat
                              ,param.c24astcod
                              ,param.rcuccsmtvcod
                              ,param.atdincdat
                              ,param.atdinchor
                              ,param.atdfnldat
                              ,param.atdfnlhor
                              ,param.atdfunempcod
                              ,param.atdusrtip
                              ,param.atdfunmat
   whenever error stop
   if sqlca.sqlcode <> 0  then
      let lr_retorno.sqlcode = sqlca.sqlcode
      let lr_retorno.mens = 'Erro <', lr_retorno.sqlcode ,'> ao registrar atendimento !'
      error lr_retorno.mens sleep 1
   else
      error "Atendimento registrado com sucesso!"  sleep 1
   end if

end function

function cta00m09_preenche_automatico(cdcontato,lr_servico)

    define cdcontato like datkdominio.cpodes       #Cod. contato
    define lr_servico record
           atdsrvnum like datmservico.atdsrvnum
          ,atdsrvano like datmservico.atdsrvano
    end record
    define lr_param record
           dscontato        like datkdominio.cpodes       #Desc. contato
          ,cdcliente        like datkdominio.cpocod       #C¢d. cliente
          ,dscliente        like datkdominio.cpodes       #Desc. cliente
          ,ident            char(18)                      #Label Identifica‡Æo
          ,cdidentificacao  dec(8,0)                      #Cod. identifica‡Æo
          ,dsidentificacao  char(40)                      #Desc. identifica‡Æo
          ,cdassunto        like datkassunto.c24astcod    #C¢d. do assunto
          ,dsassunto        like datkassunto.c24astdes    #Desc. do assunto
          ,sub              char(18)                      #Label SubAssunto
          ,cdsubassunto     like datkrcuccsmtv.rcuccsmtvcod  #C¢d.do subassunto
          ,subassunto       like datkrcuccsmtv.rcuccsmtvdes  #Desc.do subassunto
          ,ws_aux          char(20)
    end record

    define atendentecentral24h record
           funmat  like isskfunc.funmat,   # Matricula
           empcod  like isskfunc.empcod,   # Empresa
           usrtip  like isskfunc.usrtip    # Tipo
    end record
     initialize lr_param.* to null
     initialize atendentecentral24h.* to null
    #=============================================
    # Busca Descri‡Æo do Contato
    #=============================================
      let lr_param.ws_aux = "psocor_TpContato"
      open ccta00m09006 using lr_param.ws_aux
                       ,cdcontato
      whenever error continue
        fetch ccta00m09006 into cdcontato
                               ,lr_param.dscontato
      whenever error stop
      #--Se nÆo achar abra pop-up de op‡äes
      if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
         error "Codigo do contato invalido!"
         call cto00m09(1,"","","","")
         returning lr_param.dscontato
                  ,cdcontato
         display by name lr_param.dscontato
      end if
      display by name lr_param.dscontato
     #=============================================
     # Busca Tipo de cliente
     #=============================================
         let lr_param.cdcliente = 17
         display by name lr_param.cdcliente attribute(reverse)
            let lr_param.ws_aux = "psocor_TpCliente"
            open ccta00m09006 using lr_param.ws_aux
                             ,lr_param.cdcliente
            whenever error continue
              fetch ccta00m09006 into lr_param.cdcliente
                                     ,lr_param.dscliente
            whenever error stop
            #--Se nÆo achar abra pop-up de op‡äes
            if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
              error "Codigo do cliente invalido!"
              call cto00m09(2,"","","","")
              returning  lr_param.dscliente
                        ,lr_param.cdcliente
              display by name lr_param.dscliente
            end if
            display by name lr_param.dscliente
           let lr_param.ident = "Identificacao.:"
           display by name lr_param.ident
     #=============================================
     # Busca identifica‡Æo
     #=============================================
           let lr_param.cdidentificacao = g_issk.funmat
           #--Consulta no banco valor digitado
           open ccta00m09011 using lr_param.cdidentificacao
           whenever error continue
             fetch ccta00m09011 into atendentecentral24h.funmat
                                    ,atendentecentral24h.empcod
                                    ,atendentecentral24h.usrtip
                                    ,lr_param.dsidentificacao
           whenever error stop
           #--se tiver mais de um registro abrir pop-up
           if SQLCA.SQLERRD[3] > 1 then
             call cto00m09(5,"",lr_param.cdidentificacao,"","")
             returning  lr_param.dsidentificacao
                       ,lr_param.cdidentificacao
                       ,atendentecentral24h.empcod
                       ,atendentecentral24h.usrtip
             let atendentecentral24h.funmat = lr_param.cdidentificacao
             display by name  lr_param.dsidentificacao
                             ,lr_param.cdidentificacao
           end if
           let lr_param.cdidentificacao = atendentecentral24h.funmat
           display by name lr_param.cdidentificacao
           display by name lr_param.dsidentificacao
     #=============================================
     # Busca Assunto
     #=============================================
     let lr_param.cdassunto = "CO0"
     display by name lr_param.cdassunto attribute(reverse)
     #--Consulta no banco valor digitado
     open ccta00m09014 using lr_param.cdassunto
     whenever error continue
       fetch ccta00m09014 into lr_param.dsassunto
     whenever error stop
     #--Se nao encontrar valor digitado chama pop-up com op‡äes
     if sqlca.sqlcode = 100 or sqlca.sqlcode < 0 then
       error "Codigo do assunto invalido!"
       call cto00m09(3,"","","","")
       returning lr_param.dsassunto
                ,lr_param.cdassunto
       display by name lr_param.dsassunto
     end if
     display by name lr_param.dsassunto
     #===================================================
     # Busca do Sub Assunto
     #===================================================
     call cta00m09_assistencia_natureza(lr_servico.*)
          returning lr_param.cdsubassunto,
                    lr_param.subassunto
      if  lr_param.cdsubassunto is not null then
          let lr_param.sub = "SubAssunto....:"
          display by name lr_param.sub
          display by name lr_param.cdsubassunto attribute(reverse)
          display by name lr_param.subassunto
      end if
     call cta00m09_registro_acionamento("",2)
 return true
       ,cdcontato
       ,lr_param.dscontato
       ,lr_param.cdcliente
       ,lr_param.dscliente
       ,lr_param.ident
       ,lr_param.cdidentificacao
       ,lr_param.dsidentificacao
       ,lr_param.cdassunto
       ,lr_param.dsassunto
       ,lr_param.cdsubassunto
       ,lr_param.subassunto
end function
function cta00m09_assistencia_natureza(lr_param)
     define lr_param record
            atdsrvnum like datmservico.atdsrvnum
           ,atdsrvano like datmservico.atdsrvano
     end record
     define l_atdsrvorg like datmservico.atdsrvorg
     define lr_retorno record
            asitipcod   like datkasitip.asitipcod
           ,asitipdes   like datkasitip.asitipdes
           ,socntzcod   like datksocntz.socntzcod
           ,socntzdes   like datksocntz.socntzdes
     end record
     define lr_erro record
            coderro smallint ,
            mens    char(300)
     end record
     let l_atdsrvorg = null
     initialize lr_retorno.* to null
     initialize lr_erro.* to null
     whenever error continue
     open ccta00m09022 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
     fetch ccta00m09022 into l_atdsrvorg
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let lr_erro.mens = "Erro < ",sqlca.sqlcode clipped," > ao buscar a origem do servico"
        call errorlog(lr_erro.mens)
     else
         if l_atdsrvorg <> 9 then
            whenever error continue
            open ccta00m09023 using lr_param.atdsrvnum,
                                    lr_param.atdsrvano
            fetch ccta00m09023 into lr_retorno.asitipcod
            whenever error stop
            if sqlca.sqlcode <> 0 then
               let lr_erro.mens = "Erro < ",sqlca.sqlcode clipped," > ao buscar a tipo de Assistencia"
               call errorlog(lr_erro.mens)
            end if
            close ccta00m09023
          else
              whenever error continue
              open ccta00m09024 using lr_param.atdsrvnum,
                                      lr_param.atdsrvano
              fetch ccta00m09024 into lr_retorno.socntzcod
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 let lr_erro.mens = "Erro < ",sqlca.sqlcode clipped," > ao buscar a tipo de Natureza"
                 call errorlog(lr_erro.mens)
              end if
              close ccta00m09024
          end if
     end if
     close ccta00m09022
     #=============================================
     # Busca grupo de naturezas
     #=============================================
     if lr_retorno.socntzcod is not null then
        whenever error continue
        open ccta00m09025 using lr_retorno.socntzcod
        fetch ccta00m09025 into lr_retorno.socntzdes
        whenever error stop
        if sqlca.sqlcode <> 0 then
           let lr_erro.mens = "Erro < ",sqlca.sqlcode clipped , " > ao buscar a descricao da natureza !"
           call errorlog(lr_erro.mens)
        end if
        close ccta00m09025
        return lr_retorno.socntzcod,
               lr_retorno.socntzdes
     end if
     if lr_retorno.asitipcod is not null then
        whenever error continue
        open ccta00m09026 using lr_retorno.asitipcod
        fetch ccta00m09026 into lr_retorno.asitipdes
        whenever error stop
        if sqlca.sqlcode <> 0 then
           let lr_erro.mens = "Erro < ",sqlca.sqlcode clipped , " > ao buscar a descricao do tipo de assistencia !"
           call errorlog(lr_erro.mens)
        end if
        close ccta00m09026
       return lr_retorno.asitipcod,
              lr_retorno.asitipdes
     end if
    return lr_retorno.asitipcod,
           lr_retorno.asitipdes

end function
function cta00m09_registro_acionamento(lr_param)

  define lr_param record
         atdetpcod    like datmsrvacp.atdetpcod,
         flag smallint
  end record
  if lr_param.flag = 1 then
     if lr_param.atdetpcod = 3 or
        lr_param.atdetpcod = 4 or
        lr_param.atdetpcod = 7 or
        lr_param.atdetpcod = 10 then
        let g_documento.reg_acionamento = true
     end if
  else
     let g_documento.reg_acionamento = false
  end if
end function


