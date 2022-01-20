#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: BDATA124                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 202720 - SAUDE + CASA                                      #
#                  CARGA DO ARQUIVO BENNER PARA A TABELA DATKSEGSAU E         #
#                  DATKPLNSAU.                                                #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 22/09/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 17/08/2007 Saulo, Meta     AS146056   fun_dba_abre_banco movida para o      #
#                                       inicio do modulo                      #
#-----------------------------------------------------------------------------#

database porto

globals
   define g_ismqconn smallint
end globals
define m_arq char(300)
define l_retorno smallint
main

let l_retorno = 0

  # -> CRIA O ARQUIVO DE LOG DO PROGRAMA
  call fun_dba_abre_banco("CT24HS")
  call bdata124_cria_log()
  let m_arq = null
  call bdata124_arquivo_benner()
       returning m_arq

  # -> EXIBE INFORMACOES INICIAIS DE PROCESSAMENTO
  call bdata124_exibe_info("I","","","","","","","")

  # -> CRIA A TABELA AUXILIAR NO BANCO WORK
  call bdata124_cria_tab_work()
     returning l_retorno

   if l_retorno = 0 then
    # -> CARREGA O ARQUIVO SAUDE NA TABELA AUXILIAR DO BANCO WORK
     call bdata124_carga_arq()
         returning l_retorno

    if l_retorno = 0 then
       # -> ABRE O BANCO DE DADOS UTILIZADO PELA CENTRAL 24 HORAS
       close database
       database porto
       call fun_dba_abre_banco("CT24HS")

       set lock mode to wait 10
       set isolation to dirty read

       call bdata124()
    end if
   end if

end main

#-----------------------------#
function bdata124_acesso_work()
#-----------------------------#

  define l_sql  char(400)

  let l_sql = " select succod, ",
                     " ramcod, ",
                     " aplnumdig, ",
                     " crtsaunum, ",
                     " crtstt, ",
                     " plncod, ",
                     " plndes, ",
                     " plnatnlimnum, ",
                     " segnom, ",
                     " cgccpfnum, ",
                     " cgcord, ",
                     " cgccpfdig, ",
                     " empnom, ",
                     " corsus, ",
                     " cornom, ",
                     " cntanvdat, ",
                     " bnfnum ",
               " from work@u18w:tb_saude_casa "

  prepare pbdata124002 from l_sql
  declare cbdata124002 cursor with hold for pbdata124002

  let l_sql = " select count(*) ",
                " from work@u18w:tb_saude_casa "

  prepare pbdata124003 from l_sql
  declare cbdata124003 cursor for pbdata124003

end function

#-------------------------------#
function bdata124_cria_tab_work()
#-------------------------------#

  define l_sql char(800)
  define l_msg char(400)
  define l_retorno1 smallint

  let l_msg = null
  let l_retorno1 = 0
  close database
  database work@u18w

  let l_sql = " create table tb_saude_casa ",
              " (succod       decimal(2,0), ",
               " ramcod       smallint, ",
               " aplnumdig    decimal(9,0), ",
               " crtsaunum    char(18), ",
               " crtstt       char(01), ",
               " plncod       integer, ",
               " plndes       char(50), ",
               " plnatnlimnum integer, ",
               " segnom       char(50), ",
               " cgccpfnum    decimal(12,0), ",
               " cgcord       decimal(4,0), ",
               " cgccpfdig    decimal(2,0), ",
               " empnom       char(40), ",
               " corsus       char(6), ",
               " cornom       char(40), ",
               " cntanvdat    date, ",
               " bnfnum       char(20), ",
               " cpipe        char(1)); "

  prepare pbdata124001 from l_sql

  whenever error continue
  drop table tb_saude_casa
  whenever error continue

  if sqlca.sqlcode <> 0 and
     sqlca.sqlcode <> -206 then
     let l_msg = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
             " ao tentar dropar a tabela tb_saude_casa. (erro na linha 144)"
     call errorlog(l_msg)
     #exit program(1)
     call bdata124_envia_email_erro("AVISO DE ERRO BATCH - bdata124",l_msg)
     let l_retorno1 = 1
     return l_retorno1
  end if

  whenever error continue
  execute pbdata124001
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
             " ao tentar criar a tabela tb_saude_casa. (erro na linha 158) "
     #exit program(1)
     call bdata124_envia_email_erro("AVISO DE ERRO BATCH - bdata124",l_msg)
     let l_retorno1 = 1
     return l_retorno1
  end if

  whenever error continue
  create index tb_saude_casa_ind1 on tb_saude_casa(bnfnum,crtsaunum)
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
             " ao tentar criar o ind1 na tabela tb_saude_casa. (erro na linha 171) "
     #exit program(1)
     call bdata124_envia_email_erro("AVISO DE ERRO BATCH - bdata124",l_msg)
     let l_retorno1 = 1
     return l_retorno1
  end if

  whenever error continue
  create index tb_saude_casa_ind2 on tb_saude_casa(segnom)
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
             " ao tentar criar o ind2 na tabela tb_saude_casa. (erro na linha 184)"
     #exit program(1)
     call bdata124_envia_email_erro("AVISO DE ERRO BATCH - bdata124",l_msg)
     let l_retorno1 = 1
     return l_retorno1
  end if

  whenever error continue
  create index tb_saude_casa_ind3 on tb_saude_casa(cgccpfnum)
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
             " ao tentar criar o ind3 na tabela tb_saude_casa. (erro na linha 197)"
     #exit program(1)
     call bdata124_envia_email_erro("AVISO DE ERRO BATCH - bdata124",l_msg)
     let l_retorno1 = 1
     return l_retorno1
  end if

  return l_retorno1
end function

#---------------------------#
function bdata124_carga_arq()
#---------------------------#

  define l_cmd       char(100),
         l_arq_saude char(80),
         l_hora      datetime hour to second
  define l_msg       char(400)
  define l_retorno1  smallint

  let l_cmd       = null
  let l_arq_saude = null
  let l_hora      = null
  let l_msg       = null
  let l_retorno1  = 0

  # -> BUSCA O PATH DO ARQUIVO BENNER
  let l_arq_saude = m_arq clipped     #bdata124_arquivo_benner()
  let l_hora      = current

  display " "
  display "    --> Inicio do dbload as ", l_hora
  let l_msg = "    --> Inicio do dbload as ", l_hora
  call errorlog(l_msg)
  # -> VERIFICA SE O ARQUIVO DA CARGA EXISTE
  if cts40g03_verifi_log_existe(l_arq_saude) then
     let l_cmd = "dbload -d work@u18w -c bdata124.sh -n 1000 -e 0 -l",
                 " bdata124C.log > bdata124.dbload"
     run l_cmd
  else
     let l_msg = "Nao foi encontrado o arquivo ", l_arq_saude clipped, " !"
     #exit program(1)
     call bdata124_envia_email_erro("AVISO DE ERRO BATCH - bdata124",l_msg)
     let l_retorno1 = 1
     return l_retorno1
  end if
  let l_hora = current
  display "    --> Fim do dbload    as ", l_hora
  display " "
  let l_msg = "    --> Fim do dbload    as ", l_hora
  call errorlog(l_msg)
  return l_retorno1
end function

#--------------------------#
function bdata124_cria_log()
#--------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","LOG")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bdata124.log"

  call startlog(l_path)

end function

#--------------------------------#
function bdata124_arquivo_benner()
#--------------------------------#

  # -> FUNCAO P/BUSCAR O CAMINHO DO ARQUIVO benner

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","ARQUIVO")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/bennerifx.txt"

  return l_path

end function

#-----------------------------#
function bdata124_path_relato()
#-----------------------------#

  # -> FUNCAO P/CRIAR O ARQUIVO DE LOG DO PROGRAMA

  define l_path char(80)

  let l_path = null

  let l_path = f_path("DAT","RELATO")

  if l_path is null or
     l_path = " " then
     let l_path = "."
  end if

  let l_path = l_path clipped, "/naocarga.xls"

  return l_path

end function

#-----------------#
function bdata124()
#-----------------#

  define lr_base_work  record
         succod        decimal(2,0),
         ramcod        smallint,
         aplnumdig     decimal(9,0),
         crtsaunum     char(18),
         crtstt        char(01),
         plncod        integer,
         plndes        char(50),
         plnatnlimnum  integer,
         segnom        char(50),
         cgccpfnum     decimal(12,0),
         cgcord        decimal(4,0),
         cgccpfdig     decimal(2,0),
         empnom        char(40),
         corsus        char(6),
         cornom        char(40),
         cntanvdat     date,
         bnfnum        char(20)
  end record

  define lr_base_nossa record
         succod        like datksegsau.succod,
         ramcod        like datksegsau.ramcod,
         aplnumdig     like datksegsau.aplnumdig,
         crtsaunum     like datksegsau.crtsaunum,
         crtstt        like datksegsau.crtstt,
         plncod        like datksegsau.plncod,
         plndes        like datkplnsau.plndes,
         plnatnlimnum  like datkplnsau.plnatnlimnum,
         segnom        like datksegsau.segnom,
         cgccpfnum     like datksegsau.cgccpfnum,
         cgcord        like datksegsau.cgcord,
         cgccpfdig     like datksegsau.cgccpfdig,
         empnom        like datksegsau.empnom,
         corsus        like datksegsau.corsus,
         cornom        like datksegsau.cornom,
         cntanvdat     like datksegsau.cntanvdat,
         bnfnum        like datksegsau.bnfnum
  end record

  define l_lidos       integer,
         l_desp        integer,
         l_ins_seg     integer,
         l_modi_pln    integer,
         l_modi_seg    integer,
         l_erros       integer,
         l_status      smallint,
         l_total       integer,
         l_paponto     integer,
         l_ins_pln     integer,
         l_lock        smallint,
         l_ret         smallint,
         l_msg         char(200),
         l_aux_plano   char(10),
         l_aux_lim_uti char(10),
         l_path        char(80),
         l_incdat      like datksegsau.incdat,
         l_excdat      like datksegsau.excdat

  # -> PREPARA O CURSOR DE ACESSO A TABELA tb_saude_casa
  call bdata124_acesso_work()

  initialize lr_base_work.* to null
  initialize lr_base_nossa.* to null

  let l_lidos       = 0
  let l_desp        = 0
  let l_ins_seg     = 0
  let l_modi_pln    = 0
  let l_modi_seg    = 0
  let l_total       = 0
  let l_paponto     = 0
  let l_erros       = 0
  let l_lock        = 0
  let l_ins_pln     = 0
  let l_ret         = 0
  let l_path        = null
  let l_status      = 0
  let l_msg         = null
  let l_incdat      = null
  let l_excdat      = null
  let l_aux_plano   = null
  let l_aux_lim_uti = null

  # -> BUSCA O TOTAL DE REGISTROS DA TABELA work:tb_saude_casa
  open cbdata124003
  fetch cbdata124003 into l_total
  close cbdata124003

  if l_total is null then
     let l_total = 0
  end if

  display "    TOTAL DE REGISTROS A SEREM PROCESSADOS: ",
               l_total using "<<<<<<<<&"
  let l_msg = "    TOTAL DE REGISTROS A SEREM PROCESSADOS: ",
               l_total using "<<<<<<<<&"
  call errorlog(l_msg)
  # -> BUSCA O LOCAL ONDE O RELATORIO DE NAO CARREGADOS SERA GERADO
  let l_path = bdata124_path_relato()

  # -> INICIA O RELATORIO
  start report bdata124_relatorio to l_path

  # -> INICIA A TRANSACAO
  begin work

  # -> PERCORRE OS REGISTROS NA TABELA tb_saude_casa DO BANCO WORK
  open cbdata124002
  foreach cbdata124002 into lr_base_work.succod,
                            lr_base_work.ramcod,
                            lr_base_work.aplnumdig,
                            lr_base_work.crtsaunum,
                            lr_base_work.crtstt,
                            lr_base_work.plncod,
                            lr_base_work.plndes,
                            lr_base_work.plnatnlimnum,
                            lr_base_work.segnom,
                            lr_base_work.cgccpfnum,
                            lr_base_work.cgcord,
                            lr_base_work.cgccpfdig,
                            lr_base_work.empnom,
                            lr_base_work.corsus,
                            lr_base_work.cornom,
                            lr_base_work.cntanvdat,
                            lr_base_work.bnfnum

     let l_lidos   = l_lidos   + 1
     let l_paponto = l_paponto + 1

     # -> EXIBE A QUANTIDADE LIDA ATE O MOMENTO
     if l_paponto = 1000 then
        display "       LIDOS ATE O MOMENTO................: ",
                l_lidos using "<<<<<<<<&"
        let l_msg = "       LIDOS ATE O MOMENTO................: ",l_lidos using "<<<<<<<<&"
        call errorlog(l_msg)
        let l_paponto = 0
     end if

     if lr_base_work.crtsaunum    is null or     # -> NUMERO CARTAO
        lr_base_work.plncod       is null or     # -> COD. DO PLANO
        lr_base_work.plnatnlimnum is null or     # -> LIMITE UTILIZACOES
        lr_base_work.bnfnum       is null or     # -> NUMERO BENEFICIO
        lr_base_work.segnom       is null then   # -> NOME DO SEGURADO

        if lr_base_work.crtsaunum    is null then
           let lr_base_work.crtsaunum = "EM BRANCO"
        end if

        if lr_base_work.plncod       is null then
           let l_aux_plano = "EM BRANCO"
        else
           let l_aux_plano = lr_base_work.plncod
        end if

        if lr_base_work.plnatnlimnum is null then
           let l_aux_lim_uti = "EM BRANCO"
        else
           let l_aux_lim_uti = lr_base_work.plnatnlimnum
        end if

        if lr_base_work.bnfnum       is null then
           let lr_base_work.bnfnum = "EM BRANCO"
        end if

        if lr_base_work.segnom       is null then
           let lr_base_work.segnom = "EM BRANCO"
        end if

        # -> ENVIA O REGISTRO PARA O RELATORIO
        output to report bdata124_relatorio(lr_base_work.succod,
                                            lr_base_work.ramcod,
                                            lr_base_work.aplnumdig,
                                            lr_base_work.crtsaunum,
                                            lr_base_work.crtstt,
                                            l_aux_plano,
                                            lr_base_work.plndes,
                                            l_aux_lim_uti,
                                            lr_base_work.segnom,
                                            lr_base_work.cgccpfnum,
                                            lr_base_work.cgcord,
                                            lr_base_work.cgccpfdig,
                                            lr_base_work.empnom,
                                            lr_base_work.corsus,
                                            lr_base_work.cornom,
                                            lr_base_work.cntanvdat,
                                            lr_base_work.bnfnum)
        let l_desp = l_desp + 1
        continue foreach
     end if

     # -> VERIFICA SE JA ATINGIU A QTD. NECESSARIA PARA FINALIZAR A TRANSACAO
     if l_lock >= 500 then
        commit work
        begin work
        let l_lock = 0
     end if

     # -> VERIFICA SE EXISTE REGISTRO NA TABELA datkplnsau
     call cta01m16_sel_datkplnsau(lr_base_work.plncod)
          returning l_status,
                    l_msg,
                    lr_base_nossa.plndes,
                    lr_base_nossa.plnatnlimnum

     if l_status <> 1 then
        if l_status = 2 then # NAO ENCONTROU REGISTRO

           # -> QUANDO EXISTIR NOVOS PLANOS NO SAUDE+CASA REALIZA A INCLUSAO
           #    NAS TABELAS DATRRAMCLS E DATRSOCNTZSRVRE
           call cts40g24_regras(lr_base_work.plncod)

           # -> INSERE NA TABELA datkplnsau
           call cta01m16_ins_datkplnsau(lr_base_work.plncod,
                                        lr_base_work.plndes,
                                        lr_base_work.plnatnlimnum)
                returning l_status,
                          l_msg

           if l_status = 2 then # ERRO
              display "Erro ao chamar a funcao cta01m16_ins_datkplnsau() "
              display l_msg
              let l_erros = l_erros + 1
              continue foreach
           end if

           let l_lock    = l_lock + 24
           let l_ins_pln = l_ins_pln  + 1

        else
           display "Erro ao chamar a funcao cta01m16_sel_datkplnsau()"
           display l_msg
           let l_erros = l_erros + 1
           continue foreach
        end if
     else
        # -> ENCOTROU O REGISTRO NA NOSSA BASE, SENDO ASSIM, VERIFICA SE HOUVE
        # -> ALGUM TIPO DE ALTERACAO

        if lr_base_work.plndes       <> lr_base_nossa.plndes or
           lr_base_work.plnatnlimnum <> lr_base_nossa.plnatnlimnum then

           # -> ATUALIZA A TABELA datkplnsau
           call cta01m16_upd_datkplnsau(lr_base_work.plncod,
                                        lr_base_work.plndes,
                                        lr_base_work.plnatnlimnum)
                returning l_status,
                          l_msg

           if l_status = 2 then # ERRO
              display "Erro ao chamar a funcao cta01m16_upd_datkplnsau() "
              display l_msg
              let l_erros = l_erros + 1
              continue foreach
           end if

           let l_lock     = l_lock + 2
           let l_modi_pln = l_modi_pln + 1

        end if

     end if

     # -> VERIFICA SE EXISTE REGISTRO NA TABELA datksegsau
     initialize lr_base_nossa.* to null
     call cta01m15_nossa_base(lr_base_work.bnfnum,
                              lr_base_work.crtsaunum)
          returning l_status,
                    l_msg,
                    lr_base_nossa.succod,
                    lr_base_nossa.ramcod,
                    lr_base_nossa.aplnumdig,
                    lr_base_nossa.crtsaunum,
                    lr_base_nossa.crtstt,
                    lr_base_nossa.plncod,
                    lr_base_nossa.segnom,
                    lr_base_nossa.cgccpfnum,
                    lr_base_nossa.cgcord,
                    lr_base_nossa.cgccpfdig,
                    lr_base_nossa.empnom,
                    lr_base_nossa.corsus,
                    lr_base_nossa.cornom,
                    lr_base_nossa.cntanvdat

     if l_status <> 1 then
        if l_status = 2 then # NAO ENCONTROU REGISTRO

           let l_incdat = current # DATA E HORA DE INCLUSAO

           let l_msg = 'Insere novo registro de Beneficio'
           call errorlog(l_msg)
           let l_msg = 'Cartao: ',lr_base_work.crtsaunum
           call errorlog(l_msg)
           let l_msg = 'Beneficio: ',lr_base_work.bnfnum
           call errorlog(l_msg)
           # -> INSERE NA TABELA datksegsau
           call cta01m15_ins_datksegsau(lr_base_work.succod,
                                        lr_base_work.ramcod,
                                        lr_base_work.aplnumdig,
                                        lr_base_work.crtsaunum,
                                        lr_base_work.crtstt,
                                        lr_base_work.plncod,
                                        lr_base_work.segnom,
                                        lr_base_work.cgccpfnum,
                                        lr_base_work.cgcord,
                                        lr_base_work.cgccpfdig,
                                        lr_base_work.empnom,
                                        lr_base_work.corsus,
                                        lr_base_work.cornom,
                                        lr_base_work.cntanvdat,
                                        lr_base_work.bnfnum,
                                        l_incdat)
                returning l_status,
                          l_msg

           if l_status = 2 then # ERRO
              display "Erro ao chamar a funcao cta01m15_ins_datksegsau() "
              display l_msg
              let l_erros = l_erros + 1
              continue foreach
           end if

           let l_lock    = l_lock + 5
           let l_ins_seg = l_ins_seg  + 1

        else
           display "Erro ao chamar a funcao cta01m15_nossa_base()"
           display l_msg
           let l_erros = l_erros + 1
           continue foreach
        end if
     else
        # -> ENCOTROU O REGISTRO NA NOSSA BASE, SENDO ASSIM, VERIFICA SE HOUVE
        # -> ALGUM TIPO DE ALTERACAO

        # -> VERIFICA SE O CARTAO MUDOU DE NUMERACAO(base saude x nossa base)
        if lr_base_work.crtsaunum  <> lr_base_nossa.crtsaunum then

           let l_msg = 'Cancela cartao do beneficio: ',lr_base_work.bnfnum
           call errorlog(l_msg)
           let l_excdat = today # DATA DA ATUALIZACAO

           # -> CANCELA O CARTAO DA NOSSA BASE
           call cta01m15_upd_datksegsau(lr_base_work.succod,
                                        lr_base_work.ramcod,
                                        lr_base_work.aplnumdig,
                                        lr_base_nossa.crtsaunum,
                                        "C", # -> CANCELAMENTO
                                        lr_base_work.plncod,
                                        lr_base_work.segnom,
                                        lr_base_work.cgccpfnum,
                                        lr_base_work.cgcord,
                                        lr_base_work.cgccpfdig,
                                        lr_base_work.empnom,
                                        lr_base_work.corsus,
                                        lr_base_work.cornom,
                                        lr_base_work.cntanvdat,
                                        lr_base_work.bnfnum, # NUMERO DO BENEF.
                                        l_excdat)            # NAO MUDA

                returning l_status,
                          l_msg

           if l_status = 2 then # ERRO
              display "Erro ao chamar a funcao cta01m15_upd_datksegsau() "
              display l_msg
              let l_erros = l_erros + 1
              continue foreach
           end if

           let l_lock     = l_lock + 5
           let l_modi_seg = l_modi_seg + 1

           let l_incdat = current # DATA E HORA DE INCLUSAO

           let l_msg = 'Insere um novo cartao no beneficio: ',lr_base_work.bnfnum
           call errorlog(l_msg)
           let l_msg = 'cartao anterior: ',lr_base_nossa.crtsaunum
           call errorlog(l_msg)
           let l_msg = 'Novo cartao: ',lr_base_work.crtsaunum
           call errorlog(l_msg)
           # -> INSERE UM NOVO REGISTRO COM O CARTAO NOVO
           call cta01m15_ins_datksegsau(lr_base_work.succod,
                                        lr_base_work.ramcod,
                                        lr_base_work.aplnumdig,
                                        lr_base_work.crtsaunum,
                                        lr_base_work.crtstt,
                                        lr_base_work.plncod,
                                        lr_base_work.segnom,
                                        lr_base_work.cgccpfnum,
                                        lr_base_work.cgcord,
                                        lr_base_work.cgccpfdig,
                                        lr_base_work.empnom,
                                        lr_base_work.corsus,
                                        lr_base_work.cornom,
                                        lr_base_work.cntanvdat,
                                        lr_base_work.bnfnum,
                                        l_incdat)
                returning l_status,
                          l_msg

           if l_status = 2 then # ERRO
              display "Erro ao chamar a funcao cta01m15_ins_datksegsau() "
              display l_msg
              let l_erros = l_erros + 1
              continue foreach
           end if

           let l_lock    = l_lock + 5
           let l_ins_seg = l_ins_seg  + 1

           # -> BUSCA O PROXIMO REGISTRO
           continue foreach

        end if

        if lr_base_work.succod    <> lr_base_nossa.succod    or
           lr_base_work.ramcod    <> lr_base_nossa.ramcod    or
           lr_base_work.aplnumdig <> lr_base_nossa.aplnumdig or
           lr_base_work.plncod    <> lr_base_nossa.plncod    or
           lr_base_work.crtstt    <> lr_base_nossa.crtstt    or
           lr_base_work.segnom    <> lr_base_nossa.segnom    or
           lr_base_work.cgccpfnum <> lr_base_nossa.cgccpfnum or
           lr_base_work.cgcord    <> lr_base_nossa.cgcord    or
           lr_base_work.cgccpfdig <> lr_base_nossa.cgccpfdig or
           lr_base_work.empnom    <> lr_base_nossa.empnom    or
           lr_base_work.corsus    <> lr_base_nossa.corsus    or
           lr_base_work.cornom    <> lr_base_nossa.cornom    or
           lr_base_work.cntanvdat <> lr_base_nossa.cntanvdat then

           let l_excdat = today # DATA DA ATUALIZACAO

           # -> ATUALIZA A TABELA datksegsau
           let l_msg = 'Atualiza cartao do beneficio: ',lr_base_work.bnfnum
           call errorlog(l_msg)
           let l_msg = 'Cartao   ',lr_base_work.crtsaunum
           call errorlog(l_msg)
           call cta01m15_upd_datksegsau(lr_base_work.succod,
                                        lr_base_work.ramcod,
                                        lr_base_work.aplnumdig,
                                        lr_base_work.crtsaunum,
                                        lr_base_work.crtstt,
                                        lr_base_work.plncod,
                                        lr_base_work.segnom,
                                        lr_base_work.cgccpfnum,
                                        lr_base_work.cgcord,
                                        lr_base_work.cgccpfdig,
                                        lr_base_work.empnom,
                                        lr_base_work.corsus,
                                        lr_base_work.cornom,
                                        lr_base_work.cntanvdat,
                                        lr_base_work.bnfnum,
                                        l_excdat)
                returning l_status,
                          l_msg

            if l_status = 2 then # ERRO
               display "Erro ao chamar a funcao cta01m15_upd_datksegsau() "
               display l_msg
               let l_erros = l_erros + 1
               continue foreach
            end if

            let l_lock     = l_lock + 5
            let l_modi_seg = l_modi_seg + 1

        end if
     end if

  end foreach
  close cbdata124002

  # -> ENCERRA A TRANSACAO
  commit work

  # -> ENCERRA O RELATORIO
  finish report bdata124_relatorio

  # -> ENVIA E-MAIL COM OS DOCUMENTOS NAO CARREGADOS
  let l_ret = ctx22g00_envia_email("BDATA124",
                                   "Registros nao carregados na datksegsau",
                                    bdata124_compacta_arquivo(l_path))

  if l_ret <> 0 then
     if l_ret <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", l_path
     else
        display "Nao existe email cadastrado para o modulo - BDATA124"
     end if
  end if

  # -> EXIBE O RESUMO FINAL DO PROCESSAMENTO
  call bdata124_exibe_info("F",
                           l_lidos,
                           l_desp,
                           l_ins_pln,
                           l_ins_seg,
                           l_modi_pln,
                           l_modi_seg,
                           l_erros)

  # -> MOVE O ARQUIVO
  call bdata124_move_arquivo(bdata124_arquivo_benner())

end function

#----------------------------------------#
function bdata124_exibe_info(lr_parametro)
#----------------------------------------#

  define lr_parametro record
         tipo         char(01),
         lidos        integer,
         desp         integer,
         ins_pln      integer,
         ins_seg      integer,
         modi_pln     integer,
         modi_seg     integer,
         erros        integer
  end record

  define l_data                date,
         l_hora                datetime hour to second,
         l_tipo                char(01), # I - INICIO  F - FIM
         l_tot_datrramcls      integer,
         l_tot_datrsocntzsrvre integer,
         l_tot_ins             integer,
         l_tot_mod             integer

  let l_tot_datrramcls      = (lr_parametro.ins_pln * 5)
  let l_tot_datrsocntzsrvre = (lr_parametro.ins_pln * 15)
  let l_tot_ins             = (l_tot_datrramcls      +
                               l_tot_datrsocntzsrvre +
                               lr_parametro.ins_pln  +
                               lr_parametro.ins_seg)
  let l_tot_mod             = (lr_parametro.modi_pln +
                               lr_parametro.modi_seg)

  let l_data = today
  let l_hora = current

  if lr_parametro.tipo = "I" then # INICIO DO PROCESSAMENTO
     display " "
     display "-----------------------------------------------------"
     display " INICIO BDATA124 - CARGA DO ARQUIVO BENNER P/INFORMIX"
     display "-----------------------------------------------------"
     display " "
     display " INICIO DO PROCESSAMENTO.: ", l_data, " ", l_hora
     display " "
  else # FIM DO PROCESSAMENTO
     display " "
     display "       Registros lidos....................: ",
             lr_parametro.lidos using "<<<<<<<<&"

     display "       Registros desprezados..............: ",
             lr_parametro.desp  using "<<<<<<<<&"

     display "       Registros inseridos................: ", l_tot_ins
                                                             using "<<<<<<<<&"
     display "                 DATKPLNSAU............: ",
                               lr_parametro.ins_pln  using "<<<<<<<<&"
     display "                 DATKSEGSAU............: ",
                               lr_parametro.ins_seg  using "<<<<<<<<&"
     display "                 DATRRAMCLS............: ",
                               l_tot_datrramcls      using "<<<<<<<<&"
     display "                 DATRSOCNTZSRVRE.......: ",
                               l_tot_datrsocntzsrvre using "<<<<<<<<&"

     display "       Registros modificados..............: ", l_tot_mod
                                                             using "<<<<<<<<&"
     display "                 DATKPLNSAU............: ",
                               lr_parametro.modi_seg using "<<<<<<<<&"
     display "                 DATKSEGSAU............: ",
                               lr_parametro.modi_pln using "<<<<<<<<&"

     display "       Registros c/erro...................: ",
             lr_parametro.erros using "<<<<<<<<&"
     display " "
     display " TERMINO DO PROCESSAMENTO: ", l_data, " ", l_hora
     display " "
  end if

end function

#------------------------------------#
function bdata124_move_arquivo(l_path)
#------------------------------------#

  # -> FUNCAO PARA MOVER O ARQUIVO bennerifx.txt
  # -> PARA bennerifxDATAHORA.txt

  define l_path  char(80),
         l_cmd   char(100),
         l_hora  datetime hour to second,
         l_data  date,
         l_path1 char(80)

  let l_cmd    = null
  let l_hora   = current
  let l_data   = today
  let l_path1  = f_path("DAT","ARQUIVO")

  let l_cmd = "cp ",
              l_path clipped,
              " ",
              l_path1 clipped,
              "/bennerifx",
              l_data using "ddmmyy",
              l_hora,
              ".txt"

  run l_cmd

end function

#----------------------------------------#
function bdata124_compacta_arquivo(l_path)
#----------------------------------------#

  define l_path    char(100),
         l_comando char(100)

  let l_comando = null

  # -> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", l_path
  run l_comando
  let l_path = l_path clipped, ".gz"

  return l_path

end function

#-------------------------------------#
report bdata124_relatorio(lr_parametro)
#-------------------------------------#

  define lr_parametro  record
         succod        decimal(2,0),
         ramcod        smallint,
         aplnumdig     decimal(9,0),
         crtsaunum     char(18),
         crtstt        char(01),
         plncod        char(10),
         plndes        char(50),
         plnatnlimnum  char(10),
         segnom        char(50),
         cgccpfnum     decimal(12,0),
         cgcord        decimal(4,0),
         cgccpfdig     decimal(2,0),
         empnom        char(40),
         corsus        char(6),
         cornom        char(40),
         cntanvdat     date,
         bnfnum        char(20)
  end record

  define l_aux_cartao  char(30),
         l_aux_benefi  char(30)

  output

     left   margin  00
     right  margin  00
     top    margin  00
     bottom margin  00
     page   length  02

  format

     first page header

         let l_aux_cartao = null
         let l_aux_benefi = null

         print "SUCURSAL",      ASCII(09), # ---> ASCII(09) = TAB
               "RAMO",          ASCII(09),
               "APOLICE",       ASCII(09),
               "CARTAO",        ASCII(09),
               "SITUACAO",      ASCII(09),
               "COD.PLANO",     ASCII(09),
               "DESC.PLANO",    ASCII(09),
               "LIMIT.PLANO",   ASCII(09),
               "SEGURADO",      ASCII(09),
               "CPF",           ASCII(09),
               "CGCORD",        ASCII(09),
               "DIG.CPF",       ASCII(09),
               "EMPRESA",       ASCII(09),
               "SUSEP",         ASCII(09),
               "CORRETOR",      ASCII(09),
               "DATA CONTRATO", ASCII(09),
               "BENEFICIO"


     on every row

        if length(lr_parametro.crtsaunum) > 10 then
           let l_aux_cartao = "C", lr_parametro.crtsaunum
        else
           let l_aux_cartao = lr_parametro.crtsaunum
        end if

        if length(lr_parametro.bnfnum) > 10 then
           let l_aux_benefi = "B", lr_parametro.bnfnum
        else
           let l_aux_benefi = lr_parametro.bnfnum
        end if

        print lr_parametro.succod          using "&&",           ASCII(09),
              lr_parametro.ramcod          using "&&&&",         ASCII(09),
              lr_parametro.aplnumdig       using "<<<<<<<<&",    ASCII(09),
              l_aux_cartao                 clipped,              ASCII(09),
              lr_parametro.crtstt          clipped,              ASCII(09),
              lr_parametro.plncod          clipped,              ASCII(09),
              lr_parametro.plndes          clipped,              ASCII(09),
              lr_parametro.plnatnlimnum    clipped,              ASCII(09),
              lr_parametro.segnom          clipped,              ASCII(09),
              lr_parametro.cgccpfnum       using "<<<<<<<<<<<&", ASCII(09),
              lr_parametro.cgcord          using "<<<&",         ASCII(09),
              lr_parametro.cgccpfdig       using "&&",           ASCII(09),
              lr_parametro.empnom          clipped,              ASCII(09),
              lr_parametro.corsus          clipped,              ASCII(09),
              lr_parametro.cornom          clipped,              ASCII(09),
              lr_parametro.cntanvdat       using "mm/dd/yyyy",   ASCII(09),
              l_aux_benefi                 clipped

end report
#------------------------------------------------#
function bdata124_envia_email_erro(lr_parametro)
#------------------------------------------------#
  define lr_parametro record
         assunto      char(150),
         msg          char(400)
  end record
  define lr_mail record
          rem     char(50),
          des     char(250),
          ccp     char(250),
          cco     char(250),
          ass     char(150),
          msg     char(32000),
          idr     char(20),
          tip     char(4)
   end record
  define l_cod_erro      integer,
         l_msg_erro      char(20)
 initialize lr_mail.* to null
     let lr_mail.des = "sistemas.madeira@portoseguro.com.br"
     let lr_mail.rem = "ZeladoriaMadeira"
     let lr_mail.ccp = ""
     let lr_mail.cco = ""
     let lr_mail.ass = lr_parametro.assunto
     let lr_mail.idr = "bdata124"
     let lr_mail.tip = "text"
     let lr_mail.msg = lr_parametro.msg
        call figrc009_mail_send1(lr_mail.*)
           returning l_cod_erro, l_msg_erro
  if l_cod_erro = 0  then
    display l_msg_erro
  else
    display l_msg_erro
  end if
end function