#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : CENTRAL 24 HS                                              #
# Modulo        : bdatm003                                                   #
# Analista Resp.: Nilo / Ruiz                                                #
# PSI           : 223689 - Alta Disponibilidade                              #
#                 Interface para o sistema Automóvel - Emissão Diária        #
#                 baemgatu.4gi / fppwa022 - geracao do xml                   #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 30/10/2013  PSI-2013-23297            Alteração da utilização do sendmail  #
##############################################################################
#---> Dados para execucao...
#---> Fila - bdatm003.4gc DAREPLTABELA4GL01R
database porto

globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'
globals '/homedsa/projetos/geral/globals/glct.4gl'

# Projeto separacao do ambientes
globals "/homedsa/projetos/geral/globals/figrc012.4gl"
define m_hostname   like ibpkdbspace.srvnom
define m_upd    smallint
define m_dlt    smallint
define m_ins    smallint

 define m_mens        record
        msg           char(1000)
       ,de            char(50)
       ,subject       char(200)
       ,para          char(100)
       ,cc            char(100)
       ,cmd           char(2000)
 end record

#----------------------------------
function executeService(l_xml)
#----------------------------------

 define l_xml        char(32766)
 define l_temErro    char(100)
 define l_servico    char(100)
       ,l_retorno    char(32766)
       ,l_docHandle  integer

 define param_xml     record
        succod        like datrligapol.succod     ,
        ramcod        like datrservapol.ramcod    ,
        aplnumdig     like datrligapol.aplnumdig  ,
        itmnumdig     like abbmdoc.itmnumdig      ,
        edsnumdig     like abamdoc.edsnumdig      ,
        rmemdlcod     like rsamseguro.rmemdlcod   ,
        grp_natz      char(12)                    ,
        c24astcod     like datmligacao.c24astcod  ,
        cidnom        like glakcid.cidnom         ,
        ufdcod        like glakcid.ufdcod         ,
        socntzcod     like datksocntz.socntzcod   ,
        rgldat        like datmsrvrgl.rgldat      ,
        rglhor        char(5)
 end record

 define la_tabela     array[35] of record
        tabela        char(50)
 end record

 define la_sql        array[550] of record
        tabela        char(50)
       ,operacao      char(10)
       ,sql           char(3500)
 end record

 define lr_chave      record
        succod        like abamapol.succod
       ,aplnumdig     like abamapol.aplnumdig
 end record

 define l_msgerro varchar(80)
       ,l_tree        char(50)
       ,l_cont        smallint
       ,l_cont2       smallint
       ,l_ind         smallint
       ,l_ind2        smallint
       ,l_ind3        smallint
       ,l_ind4        smallint
       ,l_treeparam   char(50)
       ,qtd_colunas   smallint
       ,l_sql         char(255)
       ,w_tamanho     smallint
       ,w_palavra     char(100)
       ,l_erro        smallint
       ,w_tabela_ok   char(01)
       ,w_origem      char(100)
       ,w_destino     char(100)


 initialize la_sql to null
 initialize la_tabela to null
 initialize lr_chave.* to null
 initialize m_mens.* to null

 let l_temErro   = null
 let l_servico   = null
 let l_retorno   = null
 let l_docHandle = null
 let l_RETORNO   = null

 let l_tree      = null
 let l_cont      = null
 let l_cont2     = null
 let l_ind       = null
 let l_ind2      = null
 let l_ind3      = null
 let l_ind4      = null
 let l_treeparam = null
 let qtd_colunas = null
 let l_sql       = null
 let w_tamanho   = null
 let m_upd       = null
 let m_dlt       = null
 let m_ins       = null
 let w_palavra   = null
 let l_erro      = null
 let w_tabela_ok = null
 let w_origem    = null
 let w_destino   = null

 call fun_dba_abre_banco('CT24HS')
   if  not figrc012_sitename("bdatm003","","") then
       exit program(1)
   end if
   let m_hostname = fun_dba_servidor("CT24HS")

 display "m_hostname: ",m_hostname
 set isolation to dirty read

 #---------------------------------
 # Inicializa a operacao de parse
 #---------------------------------
 # call figrc011_inicio_parse()

 #--------------------------
 # Efetua o parse do request
 #--------------------------
 let l_docHandle = figrc011_parse_bigchar()

 let l_servico = figrc011_xpath(l_docHandle,"/mq/SERVICO")

---> psi223689
display 'l_docHandle: ' ,l_docHandle
display 'l_servico  : ' ,l_servico

 call figrc011_debug_bigchar()

 case l_servico

      when "ALTADISPONIBILIDADE"

         let l_treeparam = '/mq/ENDOSSOAUTO/TABELAS/TABELA'

         let l_tree      = "count(", l_treeparam clipped, ")"

         let l_cont      = figrc011_xpath(l_docHandle, l_tree)

         for l_ind = 1 to l_cont

             let l_tree = l_treeparam clipped , "[" , l_ind using "<<<<<&", "]"
             let la_tabela[l_ind].tabela = figrc011_xpath(l_docHandle, l_tree)

display 'TABELA     : ' ,la_tabela[l_ind].tabela

         end for

         let l_treeparam = null
         let l_treeparam = '/mq/ENDOSSOAUTO/CHAVE/SUCURSAL'
         let lr_chave.succod    = figrc011_xpath(l_docHandle,l_treeparam)

         let l_treeparam = null
         let l_treeparam = '/mq/ENDOSSOAUTO/CHAVE/APOLICE'

         let lr_chave.aplnumdig = figrc011_xpath(l_docHandle,l_treeparam)

         let m_dlt = 1
         let m_upd = 1
         let m_ins = 1

         for l_ind = 1 to l_cont

             let l_treeparam = '/mq/ENDOSSOAUTO/' ,la_tabela[l_ind].tabela clipped

             let l_tree      = "count(", l_treeparam clipped, ")"

             let l_cont2 = figrc011_xpath(l_docHandle, l_tree)

             for l_ind2 = 1 to l_cont2

                 let la_sql[l_ind2].tabela   = la_tabela[l_ind].tabela

                 let l_treeparam = null
                 let l_treeparam = '/mq/ENDOSSOAUTO/' ,la_tabela[l_ind].tabela clipped ,'[',l_ind2  using "<<<<&",']/LINHA/OPERACAO'
                 let la_sql[l_ind2].operacao = figrc011_xpath(l_docHandle,l_treeparam)

                 let l_treeparam = null
                 let l_treeparam = '/mq/ENDOSSOAUTO/' ,la_tabela[l_ind].tabela clipped ,'[',l_ind2  using "<<<<&",']/LINHA/SQL'
                 let la_sql[l_ind2].sql = figrc011_xpath(l_docHandle,l_treeparam)

                 let w_tamanho = length(la_sql[l_ind2].sql)

                 let w_palavra   = null
                 let w_tabela_ok = null
                 for l_ind4 = 1 to w_tamanho
                    if la_sql[l_ind2].sql[l_ind4,l_ind4] is not null and
                       la_sql[l_ind2].sql[l_ind4,l_ind4] <> ' '      then
                       let w_palavra = w_palavra clipped ,la_sql[l_ind2].sql[l_ind4,l_ind4]
                    else
                       if upshift(w_palavra) = 'WHERE' or
                          upshift(w_palavra) = 'VALUES' then
                          if w_tabela_ok        = 'S'     and
                             upshift(w_palavra) = 'WHERE' then
                             let w_palavra = null
                             let w_palavra = 'OK_TAB_WHERE'
                             exit for
                          else
                             if w_tabela_ok        = 'S'      and
                                upshift(w_palavra) = 'VALUES' then

                                if upshift(la_sql[l_ind2].operacao) <> 'INSERT' then

                                   initialize m_mens.* to null

                                   let m_mens.msg     = la_sql[l_ind2].operacao clipped ,' - ' ,la_sql[l_ind2].sql
                                   let m_mens.subject = "Carga de Apolices Auto - Diario - COMANDO DIVERGE DA OPERACAO"

                                   let l_retorno = bdatm003_montaxmlerro(lr_chave.succod,lr_chave.aplnumdig,9,'ERRO - COMANDO INSERT DIVERGE DA OPERACAO.')
                                   return l_retorno
                                end if

                                let w_palavra = null
                                exit for
                             else

                                initialize m_mens.* to null

                                let m_mens.msg     = la_sql[l_ind2].sql
                                let m_mens.subject = "Carga de Apolices Auto - Diario - TABELA NAO RELACIONADA"

                                let l_retorno = bdatm003_montaxmlerro(lr_chave.succod,lr_chave.aplnumdig,9,'ERRO - COMANDO INSERT/DELETE OU UPDATE EM UMA TABELA NAO RELACIONADA.')
                                return l_retorno
                             end if
                          end if
                       else
                          if upshift(w_palavra) = 'ABAMAPOL'         or
                             upshift(w_palavra) = 'ABAMCOR'          or
                             upshift(w_palavra) = 'ABAMDOC'          or
                             upshift(w_palavra) = 'ABDMPARC'         or
                             upshift(w_palavra) = 'ABBM0KM'          or
                             upshift(w_palavra) = 'ABBMAPP'          or
                             upshift(w_palavra) = 'ABBMBLI'          or
                             upshift(w_palavra) = 'ABBMCASCO'        or
                             upshift(w_palavra) = 'ABBMCLAUS'        or
                             upshift(w_palavra) = 'ABBMCONDESP'      or
                             upshift(w_palavra) = 'ABBMDM'           or
                             upshift(w_palavra) = 'ABBMDOC'          or
                             upshift(w_palavra) = 'ABBMDP'           or
                             upshift(w_palavra) = 'ABBMITEM'         or
                             upshift(w_palavra) = 'ABCMACES'         or
                             upshift(w_palavra) = 'ABBMQUESTIONARIO' or
                             upshift(w_palavra) = 'ABBMQUESTTXT'     or
                             upshift(w_palavra) = 'ABCMDOC'          or
                             upshift(w_palavra) = 'ABBMVEIC'         or
                             upshift(w_palavra) = 'ABBMVIDA2'        then

                             let w_tabela_ok    = 'S'

                             let w_origem       = null
                             let w_destino      = null

                             let w_origem       = downshift(w_palavra) clipped
                             let w_destino      = downshift(w_palavra) clipped ,'_atd' clipped

                             call figrc005_troca(la_sql[l_ind2].sql
                                                ,w_origem
                                                ,w_destino)
                                       returning la_sql[l_ind2].sql

                             if upshift(la_sql[l_ind2].operacao) = 'INSERT' then
                                exit for
                             end if

                             let w_palavra      = null
                          else
                             let w_palavra = null
                          end if
                       end if
                    end if
                 end for

                 #-> Despreza atualizacoes nessas tabelas, pois foram replicadas
                 if upshift(w_origem) = 'ABAMAPOL'  or
                    upshift(w_origem) = 'ABAMCOR'   or
                    upshift(w_origem) = 'ABAMDOC'   or
                    upshift(w_origem) = 'ABBMCASCO' or
                    upshift(w_origem) = 'ABBMCLAUS' or
                    upshift(w_origem) = 'ABBMDM'    or
                    upshift(w_origem) = 'ABBMDOC'   or
                    upshift(w_origem) = 'ABBMDP'    or
                    upshift(w_origem) = 'ABBMVEIC'  or
                    upshift(w_origem) = 'ABBMITEM'  then
                    continue for
                 end if

                 if (upshift(la_sql[l_ind2].operacao) = 'DELETE'       or
                     upshift(la_sql[l_ind2].operacao) = 'UPDATE')      and
                     w_palavra                        = 'OK_TAB_WHERE' then

                     if upshift(la_sql[l_ind2].operacao) = 'DELETE'    then

                         case m_dlt
                            when 1
                               whenever error continue
                               prepare dlt_bdatm00301 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 2
                            when 2
                               whenever error continue
                               prepare dlt_bdatm00302 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 3
                            when 3
                               whenever error continue
                               prepare dlt_bdatm00303 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 4
                            when 4
                               whenever error continue
                               prepare dlt_bdatm00304 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 5
                            when 5
                               whenever error continue
                               prepare dlt_bdatm00305 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 6
                            when 6
                               whenever error continue
                               prepare dlt_bdatm00306 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 7
                            when 7
                               whenever error continue
                               prepare dlt_bdatm00307 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 8
                            when 8
                               whenever error continue
                               prepare dlt_bdatm00308 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 9
                            when 9
                               whenever error continue
                               prepare dlt_bdatm00309 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 10
                            when 10
                               whenever error continue
                               prepare dlt_bdatm00310 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 11
                            when 11
                               whenever error continue
                               prepare dlt_bdatm00311 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 12
                            when 12
                               whenever error continue
                               prepare dlt_bdatm00312 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 13
                            when 13
                               whenever error continue
                               prepare dlt_bdatm00313 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 14
                            when 14
                               whenever error continue
                               prepare dlt_bdatm00314 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 15
                            when 15
                               whenever error continue
                               prepare dlt_bdatm00315 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 16
                            when 16
                               whenever error continue
                               prepare dlt_bdatm00316 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 17
                            when 17
                               whenever error continue
                               prepare dlt_bdatm00317 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 18
                            when 18
                               whenever error continue
                               prepare dlt_bdatm00318 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 19
                            when 19
                               whenever error continue
                               prepare dlt_bdatm00319 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 20
                            when 20
                               whenever error continue
                               prepare dlt_bdatm00320 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 21
                            when 21
                               whenever error continue
                               prepare dlt_bdatm00321 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 22
                            when 22
                               whenever error continue
                               prepare dlt_bdatm00322 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 23
                            when 23
                               whenever error continue
                               prepare dlt_bdatm00323 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 24
                            when 24
                               whenever error continue
                               prepare dlt_bdatm00324 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 25
                            when 25
                               whenever error continue
                               prepare dlt_bdatm00325 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 26
                            when 26
                               whenever error continue
                               prepare dlt_bdatm00326 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 27
                            when 27
                               whenever error continue
                               prepare dlt_bdatm00327 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 28
                            when 28
                               whenever error continue
                               prepare dlt_bdatm00328 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 29
                            when 29
                               whenever error continue
                               prepare dlt_bdatm00329 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 30
                            when 30
                               whenever error continue
                               prepare dlt_bdatm00330 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('d',la_sql[l_ind2].sql)
                               let m_dlt = 31
                         otherwise
                            initialize m_mens.* to null

                            let m_mens.msg     = la_sql[l_ind2].sql
                            let m_mens.subject = "Carga de Apolices Auto - Diario - ERRO - MAIS LINHAS DE COMANDO DELETE DO QUE PREPARADO"

                            let l_retorno = bdatm003_montaxmlerro(lr_chave.succod,lr_chave.aplnumdig,1,'ERRO - MAIS LINHAS DE COMANDO DELETE DO QUE PREPARADO.')
                            return l_retorno
                         end case
                     else
                         case m_upd
                            when 1
                               whenever error continue
                               prepare upd_bdatm00301 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 2
                            when 2
                               whenever error continue
                               prepare upd_bdatm00302 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 3
                            when 3
                               whenever error continue
                               prepare upd_bdatm00303 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 4
                            when 4
                               whenever error continue
                               prepare upd_bdatm00304 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 5
                            when 5
                               whenever error continue
                               prepare upd_bdatm00305 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 6
                            when 6
                               whenever error continue
                               prepare upd_bdatm00306 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 7
                            when 7
                               whenever error continue
                               prepare upd_bdatm00307 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 8
                            when 8
                               whenever error continue
                               prepare upd_bdatm00308 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 9
                            when 9
                               whenever error continue
                               prepare upd_bdatm00309 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 10
                            when 10
                               whenever error continue
                               prepare upd_bdatm00310 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 11
                            when 11
                               whenever error continue
                               prepare upd_bdatm00311 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 12
                            when 12
                               whenever error continue
                               prepare upd_bdatm00312 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 13
                            when 13
                               whenever error continue
                               prepare upd_bdatm00313 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 14
                            when 14
                               whenever error continue
                               prepare upd_bdatm00314 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 15
                            when 15
                               whenever error continue
                               prepare upd_bdatm00315 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 16
                            when 16
                               whenever error continue
                               prepare upd_bdatm00316 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 17
                            when 17
                               whenever error continue
                               prepare upd_bdatm00317 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 18
                            when 18
                               whenever error continue
                               prepare upd_bdatm00318 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 19
                            when 19
                               whenever error continue
                               prepare upd_bdatm00319 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 20
                            when 20
                               whenever error continue
                               prepare upd_bdatm00320 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 21
                            when 21
                               whenever error continue
                               prepare upd_bdatm00321 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 22
                            when 22
                               whenever error continue
                               prepare upd_bdatm00322 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 23
                            when 23
                               whenever error continue
                               prepare upd_bdatm00323 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 24
                            when 24
                               whenever error continue
                               prepare upd_bdatm00324 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 25
                            when 25
                               whenever error continue
                               prepare upd_bdatm00325 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 26
                            when 26
                               whenever error continue
                               prepare upd_bdatm00326 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 27
                            when 27
                               whenever error continue
                               prepare upd_bdatm00327 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 28
                            when 28
                               whenever error continue
                               prepare upd_bdatm00328 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 29
                            when 29
                               whenever error continue
                               prepare upd_bdatm00329 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 30
                            when 30
                               whenever error continue
                               prepare upd_bdatm00330 from la_sql[l_ind2].sql
                               whenever error stop
                               call bdatm003_showSqlCode('u',la_sql[l_ind2].sql)
                               let m_upd = 31
                         otherwise
                            initialize m_mens.* to null

                            let m_mens.msg     = la_sql[l_ind2].sql
                            let m_mens.subject = "Carga de Apolices Auto - Diario - ERRO - MAIS LINHAS DE COMANDO UPDATE DO QUE PREPARADO."

                            let l_retorno = bdatm003_montaxmlerro(lr_chave.succod,lr_chave.aplnumdig,2,'ERRO - MAIS LINHAS DE COMANDO UPDATE DO QUE PREPARADO.')
                            return l_retorno
                         end case
                     end if
                 else
                    if (upshift(la_sql[l_ind2].operacao) = 'DELETE'       or
                        upshift(la_sql[l_ind2].operacao) = 'UPDATE')      and
                        w_palavra                       <> 'OK_TAB_WHERE' then

                        initialize m_mens.* to null

                        let m_mens.msg     = la_sql[l_ind2].sql
                        let m_mens.subject = "Carga de Apolices Auto - Diario - SEM WHERE"
                        let l_retorno = bdatm003_montaxmlerro(lr_chave.succod,lr_chave.aplnumdig,3,'ERRO - COMANDO DELETE/UPDATE SEM CONDICAO WHERE.')
                        return l_retorno
                    else
                       case m_ins
                          when 1
                             whenever error continue
                             prepare ins_bdatm00301 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 2
                          when 2
                             whenever error continue
                             prepare ins_bdatm00302 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 3
                          when 3
                             whenever error continue
                             prepare ins_bdatm00303 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 4
                          when 4
                             whenever error continue
                             prepare ins_bdatm00304 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 5
                          when 5
                             whenever error continue
                             prepare ins_bdatm00305 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 6
                          when 6
                             whenever error continue
                             prepare ins_bdatm00306 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 7
                          when 7
                             whenever error continue
                             prepare ins_bdatm00307 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 8
                          when 8
                             whenever error continue
                             prepare ins_bdatm00308 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 9
                          when 9
                             whenever error continue
                             prepare ins_bdatm00309 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 10
                          when 10
                             whenever error continue
                             prepare ins_bdatm00310 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 11
                          when 11
                             whenever error continue
                             prepare ins_bdatm00311 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 12
                          when 12
                             whenever error continue
                             prepare ins_bdatm00312 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 13
                          when 13
                             whenever error continue
                             prepare ins_bdatm00313 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 14
                          when 14
                             whenever error continue
                             prepare ins_bdatm00314 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 15
                          when 15
                             whenever error continue
                             prepare ins_bdatm00315 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 16
                          when 16
                             whenever error continue
                             prepare ins_bdatm00316 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 17
                          when 17
                             whenever error continue
                             prepare ins_bdatm00317 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 18
                          when 18
                             whenever error continue
                             prepare ins_bdatm00318 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 19
                          when 19
                             whenever error continue
                             prepare ins_bdatm00319 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 20
                          when 20
                             whenever error continue
                             prepare ins_bdatm00320 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 21
                          when 21
                             whenever error continue
                             prepare ins_bdatm00321 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 22
                          when 22
                             whenever error continue
                             prepare ins_bdatm00322 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 23
                          when 23
                             whenever error continue
                             prepare ins_bdatm00323 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 24
                          when 24
                             whenever error continue
                             prepare ins_bdatm00324 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 25
                          when 25
                             whenever error continue
                             prepare ins_bdatm00325 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 26
                          when 26
                             whenever error continue
                             prepare ins_bdatm00326 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 27
                          when 27
                             whenever error continue
                             prepare ins_bdatm00327 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 28
                          when 28
                             whenever error continue
                             prepare ins_bdatm00328 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 29
                          when 29
                             whenever error continue
                             prepare ins_bdatm00329 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 30
                          when 30
                             whenever error continue
                             prepare ins_bdatm00330 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 31
                          when 31
                             whenever error continue
                             prepare ins_bdatm00331 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 32
                          when 32
                             whenever error continue
                             prepare ins_bdatm00332 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 33
                          when 33
                             whenever error continue
                             prepare ins_bdatm00333 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 34
                          when 34
                             whenever error continue
                             prepare ins_bdatm00334 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 35
                          when 35
                             whenever error continue
                             prepare ins_bdatm00335 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 36
                          when 36
                             whenever error continue
                             prepare ins_bdatm00336 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 37
                          when 37
                             whenever error continue
                             prepare ins_bdatm00337 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 38
                          when 38
                             whenever error continue
                             prepare ins_bdatm00338 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 39
                          when 39
                             whenever error continue
                             prepare ins_bdatm00339 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 40
                          when 40
                             whenever error continue
                             prepare ins_bdatm00340 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 41
                          when 41
                             whenever error continue
                             prepare ins_bdatm00341 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 42
                          when 42
                             whenever error continue
                             prepare ins_bdatm00342 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 43
                          when 43
                             whenever error continue
                             prepare ins_bdatm00343 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 44
                          when 44
                             whenever error continue
                             prepare ins_bdatm00344 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 45
                          when 45
                             whenever error continue
                             prepare ins_bdatm00345 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 46
                          when 46
                             whenever error continue
                             prepare ins_bdatm00346 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 47
                          when 47
                             whenever error continue
                             prepare ins_bdatm00347 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 48
                          when 48
                             whenever error continue
                             prepare ins_bdatm00348 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 49
                          when 49
                             whenever error continue
                             prepare ins_bdatm00349 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 50
                          when 50
                             whenever error continue
                             prepare ins_bdatm00350 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 51
                          when 51
                             whenever error continue
                             prepare ins_bdatm00351 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 52
                          when 52
                             whenever error continue
                             prepare ins_bdatm00352 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 53
                          when 53
                             whenever error continue
                             prepare ins_bdatm00353 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 54
                          when 54
                             whenever error continue
                             prepare ins_bdatm00354 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 55
                          when 55
                             whenever error continue
                             prepare ins_bdatm00355 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 56
                          when 56
                             whenever error continue
                             prepare ins_bdatm00356 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 57
                          when 57
                             whenever error continue
                             prepare ins_bdatm00357 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 58
                          when 58
                             whenever error continue
                             prepare ins_bdatm00358 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 59
                          when 59
                             whenever error continue
                             prepare ins_bdatm00359 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 60
                          when 60
                             whenever error continue
                             prepare ins_bdatm00360 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 61
                          when 61
                             whenever error continue
                             prepare ins_bdatm00361 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 62
                          when 62
                             whenever error continue
                             prepare ins_bdatm00362 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 63
                          when 63
                             whenever error continue
                             prepare ins_bdatm00363 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 64
                          when 64
                             whenever error continue
                             prepare ins_bdatm00364 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 65
                          when 65
                             whenever error continue
                             prepare ins_bdatm00365 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 66
                          when 66
                             whenever error continue
                             prepare ins_bdatm00366 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 67
                          when 67
                             whenever error continue
                             prepare ins_bdatm00367 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 68
                          when 68
                             whenever error continue
                             prepare ins_bdatm00368 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 69
                          when 69
                             whenever error continue
                             prepare ins_bdatm00369 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 70
                          when 70
                             whenever error continue
                             prepare ins_bdatm00370 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 71
                          when 71
                             whenever error continue
                             prepare ins_bdatm00371 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 72
                          when 72
                             whenever error continue
                             prepare ins_bdatm00372 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 73
                          when 73
                             whenever error continue
                             prepare ins_bdatm00373 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 74
                          when 74
                             whenever error continue
                             prepare ins_bdatm00374 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 75
                          when 75
                             whenever error continue
                             prepare ins_bdatm00375 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 76
                          when 76
                             whenever error continue
                             prepare ins_bdatm00376 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 77
                          when 77
                             whenever error continue
                             prepare ins_bdatm00377 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 78
                          when 78
                             whenever error continue
                             prepare ins_bdatm00378 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 79
                          when 79
                             whenever error continue
                             prepare ins_bdatm00379 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 80
                          when 80
                             whenever error continue
                             prepare ins_bdatm00380 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 81
                          when 81
                             whenever error continue
                             prepare ins_bdatm00381 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 82
                          when 82
                             whenever error continue
                             prepare ins_bdatm00382 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 83
                          when 83
                             whenever error continue
                             prepare ins_bdatm00383 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 84
                          when 84
                             whenever error continue
                             prepare ins_bdatm00384 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 85
                          when 85
                             whenever error continue
                             prepare ins_bdatm00385 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 86
                          when 86
                             whenever error continue
                             prepare ins_bdatm00386 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 87
                          when 87
                             whenever error continue
                             prepare ins_bdatm00387 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 88
                          when 88
                             whenever error continue
                             prepare ins_bdatm00388 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 89
                          when 89
                             whenever error continue
                             prepare ins_bdatm00389 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 90
                          when 90
                             whenever error continue
                             prepare ins_bdatm00390 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 91
                          when 91
                             whenever error continue
                             prepare ins_bdatm00391 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 92
                          when 92
                             whenever error continue
                             prepare ins_bdatm00392 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 93
                          when 93
                             whenever error continue
                             prepare ins_bdatm00393 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 94
                          when 94
                             whenever error continue
                             prepare ins_bdatm00394 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 95
                          when 95
                             whenever error continue
                             prepare ins_bdatm00395 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 96
                          when 96
                             whenever error continue
                             prepare ins_bdatm00396 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 97
                          when 97
                             whenever error continue
                             prepare ins_bdatm00397 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 98
                          when 98
                             whenever error continue
                             prepare ins_bdatm00398 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 99
                          when 99
                             whenever error continue
                             prepare ins_bdatm00399 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 100
                          when 100
                             whenever error continue
                             prepare ins_bdatm003100 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                          when 101
                             whenever error continue
                             prepare ins_bdatm003101 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 102
                          when 102
                             whenever error continue
                             prepare ins_bdatm003102 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 103
                          when 103
                             whenever error continue
                             prepare ins_bdatm003103 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 104
                          when 104
                             whenever error continue
                             prepare ins_bdatm003104 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 105
                          when 105
                             whenever error continue
                             prepare ins_bdatm003105 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 106
                          when 106
                             whenever error continue
                             prepare ins_bdatm003106 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 107
                          when 107
                             whenever error continue
                             prepare ins_bdatm003107 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 108
                          when 108
                             whenever error continue
                             prepare ins_bdatm003108 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 109
                          when 109
                             whenever error continue
                             prepare ins_bdatm003109 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 110
                          when 110
                             whenever error continue
                             prepare ins_bdatm003110 from la_sql[l_ind2].sql
                             whenever error stop
                             call bdatm003_showSqlCode('i',la_sql[l_ind2].sql)
                             let m_ins = 111
                       otherwise
                          initialize m_mens.* to null

                          let m_mens.msg     = la_sql[l_ind2].sql
                          let m_mens.subject = "Carga de Apolices Auto - Diario - ERRO - MAIS LINHAS DE COMANDO INSERT DO QUE PREPARADO."

                          let l_retorno = bdatm003_montaxmlerro(lr_chave.succod,lr_chave.aplnumdig,4,'ERRO - MAIS LINHAS DE COMANDO INSERT DO QUE PREPARADO.')
                          return l_retorno
                       end case
                    end if

                 end if

display ''
display '################'
display 'TABELA2 : ' ,la_sql[l_ind2].tabela   clipped
display 'OPERACAO: ' ,la_sql[l_ind2].operacao clipped
display 'SQL     : ' ,la_sql[l_ind2].sql      clipped
display 'm_upd   : ' ,m_upd
display 'm_dlt   : ' ,m_dlt
display 'm_ins   : ' ,m_ins
display '################'

             end for
         end for

         call bdatm003_atualiza()
              returning l_erro

         if l_erro <> 0 then
            rollback work
            initialize m_mens.* to null

            let m_mens.msg     = "ERRO - PROBLEMA NA EXECUCAO DOS COMANDOS SQL. " ,l_erro
            let m_mens.subject = "Carga de Apolices Auto - Diario - ERRO - PROBLEMA NA EXECUCAO DOS COMANDOS SQL."

            let l_retorno = bdatm003_montaxmlerro(lr_chave.succod,lr_chave.aplnumdig,5,'ERRO - PROBLEMA NA EXECUCAO DOS COMANDOS SQL.')

---> Solucao paliativa para nao gerar sobrecarga de log de erro infra.roteador
---> apos reorg feito no guia postal.
---> Conforme tratado com Nilo/Samuel/Chistoni/Salgado - 300609

  let l_retorno = null
  let l_retorno =
   "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",
   "<resposta>",
   "<codigoErro>0</codigoErro>",
   "<mensagemErro>Solucao paliativa para nao gerar sobrecarga de log de erro infra.roteador</mensagemErro>",
   "</resposta>"

            return l_retorno
          else
            commit work
         end if

      otherwise
           let m_mens.msg     = null
           let m_mens.subject = null

           let l_msgerro = "Erro na chamada do servico - ", l_servico clipped

           let m_mens.msg     = l_msgerro
           let m_mens.subject = "Carga de Apolices Auto - Diario."

           #---> Não tratar xml/registro sem referência - Servico nulo. - 21/01/2010 - Nilo
           #return bdatm003_montaxmlerro(0,0,-1,l_msgerro)
           display l_msgerro
 end case

 call figrc011_fim_parse()

 let m_mens.msg     = null
 let m_mens.subject = null
 let m_mens.msg     = 'CARGA PROCESSADA OK!'
 let m_mens.subject = "Carga de Apolices Auto - Diario - OK"

 let l_retorno = bdatm003_montaxmlerro(lr_chave.succod
                                      ,lr_chave.aplnumdig
                                      ,0,'CARGA PROCESSADA OK!')

 return l_retorno

end function
#-----------------------------------------------------------------------------
function bdatm003_montaxmlerro(param)
#-----------------------------------------------------------------------------

  define param      record
         succod     like abamapol.succod
        ,aplnumdig  like abamapol.aplnumdig
        ,erro       dec(1,0)                #---> Atualiza Chave (1,2,3,4,5) - Problema no nome do Serviço (-1)
        ,msgerro    char (1000)
  end record

  define lr_ret     record
         cod_erro   integer
        ,menserro   char(20)
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

  define l_relsgl     char(18)
  define l_relpamseq  dec(5,0)
  define l_relpamtxt  varchar(75,0)
  define l_xml        char(5000)
  define l_erro       dec(3,0)
  define l_i          smallint
  define l_atu_flg    smallint
  define cod_erro     smallint
  define msg_erro     char(500)

  initialize lr_ret.* to null

  let l_xml       = null
  let l_erro      = null
  let l_relsgl    = null
  let l_relpamseq = null
  let l_relpamtxt = null
  let l_i         = null
  let l_atu_flg   = null

  let l_erro = 0

  if param.msgerro is not null and
     param.erro    > 0         then
     let l_erro = 2

     #---> 223689 - Atualiza Chave para Central 24h
     #---> Grava Sucursal e Apolice para start de processo batch,
     #---> partindo da abamapol, buscando a última situação
     #---> e atualizando as tabelas do auto replicadas no banco u18w

     select max(relpamseq)
       into l_relpamseq
      #from porto@u01:igbmparam
       from igbmparam
      where relsgl = 'ct24h_bdatm003'

     if l_relpamseq is null or
        l_relpamseq =  0    then
        let l_relpamseq = 1
     else
        let l_relpamseq = l_relpamseq + 1
     end if

     let l_relpamtxt = null
     let l_relpamtxt = param.succod           using "&&"
                      ,param.aplnumdig        using "&&&&&&&&&"

     let l_atu_flg = null

     begin work

     for l_i = 1 to 10
        whenever error continue

       #insert into porto@u01:igbmparam (relsgl,relpamseq,relpamtip,relpamtxt)
       #                values("ct24h_bdatm003",l_relpamseq, param.erro, l_relpamtxt)
        insert into igbmparam (relsgl,relpamseq,relpamtip,relpamtxt)
                  values("ct24h_bdatm003",l_relpamseq, param.erro, l_relpamtxt)
        whenever error stop

        if sqlca.sqlcode = 0 then
           commit work
           let l_atu_flg = 0
           exit for
        else
           let l_atu_flg = 1
        end if

     end for

     if l_atu_flg = 1 then
        rollback work
     end if

  else
     if param.erro = 0 then
        let l_erro = 0
     else
        let l_erro = 2
     end if
  end if

  let l_xml =
   "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",
   "<resposta>",
   "<codigoErro>"   clipped ,l_erro    clipped using '<<<&',"</codigoErro>",
   "<mensagemErro>" clipped ,param.msgerro clipped,"</mensagemErro>",
   "</resposta>"

  let m_mens.msg     = "ERRO - PROBLEMA NA EXECUCAO DOS COMANDOS SQL. "
  let m_mens.subject = "Carga de Apolices Auto - Diario - ERRO - PROBLEMA NA EXECUCAO DOS COMANDOS SQL."
  let m_mens.msg     = m_mens.msg clipped
                      ,' - CHAVE SUC/APL: ' ,param.succod ,'/' ,param.aplnumdig

 #PSI-2013-23297 - Inicio
  let l_mail.de = "CT24H-bdatm003"
  let l_mail.para = "sistemas.madeira@portoseguro.com.br"
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto = m_mens.subject
  let l_mail.mensagem = m_mens.msg
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "text"
  if param.erro <> 0 then
       call figrc009_mail_send1 (l_mail.*)
          returning cod_erro,msg_erro
  end if
  #PSI-2013-23297 - Fim

  display 'XML RETORNO: ' ,l_xml clipped

  return l_xml

end function
#---------------------------
function bdatm003_atualiza()
#---------------------------

   begin work

   #----------------------------#
   #---> Roda comandos de DELETE
   #----------------------------#
   if m_dlt is not null and
      m_dlt > 1        then
      whenever error continue
      execute dlt_bdatm00301
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 2        then
      whenever error continue
      execute dlt_bdatm00302
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 3        then
      whenever error continue
      execute dlt_bdatm00303
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 4        then
      whenever error continue
      execute dlt_bdatm00304
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 5        then
      whenever error continue
      execute dlt_bdatm00305
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 6        then
      whenever error continue
      execute dlt_bdatm00306
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 7        then
      whenever error continue
      execute dlt_bdatm00307
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 8        then
      whenever error continue
      execute dlt_bdatm00308
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 9        then
      whenever error continue
      execute dlt_bdatm00309
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 10       then
      whenever error continue
      execute dlt_bdatm00310
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 11       then
      whenever error continue
      execute dlt_bdatm00311
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 12       then
      whenever error continue
      execute dlt_bdatm00312
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 13       then
      whenever error continue
      execute dlt_bdatm00313
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 14       then
      whenever error continue
      execute dlt_bdatm00314
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 15       then
      whenever error continue
      execute dlt_bdatm00315
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 16       then
      whenever error continue
      execute dlt_bdatm00316
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 17       then
      whenever error continue
      execute dlt_bdatm00317
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 18       then
      whenever error continue
      execute dlt_bdatm00318
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 19       then
      whenever error continue
      execute dlt_bdatm00319
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 20       then
      whenever error continue
      execute dlt_bdatm00320
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 21       then
      whenever error continue
      execute dlt_bdatm00321
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 22       then
      whenever error continue
      execute dlt_bdatm00322
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 23       then
      whenever error continue
      execute dlt_bdatm00323
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 24       then
      whenever error continue
      execute dlt_bdatm00324
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 25       then
      whenever error continue
      execute dlt_bdatm00325
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 26       then
      whenever error continue
      execute dlt_bdatm00326
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 27       then
      whenever error continue
      execute dlt_bdatm00327
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 28       then
      whenever error continue
      execute dlt_bdatm00328
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt > 29       then
      whenever error continue
      execute dlt_bdatm00329
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_dlt is not null and
      m_dlt >  30       then
      whenever error continue
      execute dlt_bdatm00330
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   #----------------------------#
   #---> Roda comandos de INSERT
   #----------------------------#
   if m_ins is not null and
      m_ins > 1        then
      whenever error continue
      execute ins_bdatm00301
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 2        then
      whenever error continue
      execute ins_bdatm00302
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 3        then
      whenever error continue
      execute ins_bdatm00303
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 4        then
      whenever error continue
      execute ins_bdatm00304
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 5        then
      whenever error continue
      execute ins_bdatm00305
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 6        then
      whenever error continue
      execute ins_bdatm00306
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 7        then
      whenever error continue
      execute ins_bdatm00307
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 8        then
      whenever error continue
      execute ins_bdatm00308
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 9        then
      whenever error continue
      execute ins_bdatm00309
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 10       then
      whenever error continue
      execute ins_bdatm00310
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 11       then
      whenever error continue
      execute ins_bdatm00311
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 12       then
      whenever error continue
      execute ins_bdatm00312
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 13       then
      whenever error continue
      execute ins_bdatm00313
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 14       then
      whenever error continue
      execute ins_bdatm00314
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 15       then
      whenever error continue
      execute ins_bdatm00315
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 16       then
      whenever error continue
      execute ins_bdatm00316
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 17       then
      whenever error continue
      execute ins_bdatm00317
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 18       then
      whenever error continue
      execute ins_bdatm00318
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 19       then
      whenever error continue
      execute ins_bdatm00319
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 20       then
      whenever error continue
      execute ins_bdatm00320
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 21       then
      whenever error continue
      execute ins_bdatm00321
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 22       then
      whenever error continue
      execute ins_bdatm00322
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 23       then
      whenever error continue
      execute ins_bdatm00323
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 24       then
      whenever error continue
      execute ins_bdatm00324
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 25       then
      whenever error continue
      execute ins_bdatm00325
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 26       then
      whenever error continue
      execute ins_bdatm00326
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 27       then
      whenever error continue
      execute ins_bdatm00327
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 28       then
      whenever error continue
      execute ins_bdatm00328
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 29       then
      whenever error continue
      execute ins_bdatm00329
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  30       then
      whenever error continue
      execute ins_bdatm00330
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 31       then
      whenever error continue
      execute ins_bdatm00331
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 32       then
      whenever error continue
      execute ins_bdatm00332
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 33       then
      whenever error continue
      execute ins_bdatm00333
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 34       then
      whenever error continue
      execute ins_bdatm00334
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 35       then
      whenever error continue
      execute ins_bdatm00335
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 36       then
      whenever error continue
      execute ins_bdatm00336
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 37       then
      whenever error continue
      execute ins_bdatm00337
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 38       then
      whenever error continue
      execute ins_bdatm00338
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 39       then
      whenever error continue
      execute ins_bdatm00339
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  40       then
      whenever error continue
      execute ins_bdatm00340
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 41       then
      whenever error continue
      execute ins_bdatm00341
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 42       then
      whenever error continue
      execute ins_bdatm00342
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 43       then
      whenever error continue
      execute ins_bdatm00343
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 44       then
      whenever error continue
      execute ins_bdatm00344
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 45       then
      whenever error continue
      execute ins_bdatm00345
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 46       then
      whenever error continue
      execute ins_bdatm00346
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 47       then
      whenever error continue
      execute ins_bdatm00347
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 48       then
      whenever error continue
      execute ins_bdatm00348
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 49       then
      whenever error continue
      execute ins_bdatm00349
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  50       then
      whenever error continue
      execute ins_bdatm00350
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 51       then
      whenever error continue
      execute ins_bdatm00351
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 52       then
      whenever error continue
      execute ins_bdatm00352
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 53       then
      whenever error continue
      execute ins_bdatm00353
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 54       then
      whenever error continue
      execute ins_bdatm00354
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 55       then
      whenever error continue
      execute ins_bdatm00355
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 56       then
      whenever error continue
      execute ins_bdatm00356
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 57       then
      whenever error continue
      execute ins_bdatm00357
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 58       then
      whenever error continue
      execute ins_bdatm00358
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 59       then
      whenever error continue
      execute ins_bdatm00359
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  60       then
      whenever error continue
      execute ins_bdatm00360
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 61       then
      whenever error continue
      execute ins_bdatm00361
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 62       then
      whenever error continue
      execute ins_bdatm00362
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 63       then
      whenever error continue
      execute ins_bdatm00363
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 64       then
      whenever error continue
      execute ins_bdatm00364
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 65       then
      whenever error continue
      execute ins_bdatm00365
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 66       then
      whenever error continue
      execute ins_bdatm00366
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 67       then
      whenever error continue
      execute ins_bdatm00367
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 68       then
      whenever error continue
      execute ins_bdatm00368
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins > 69       then
      whenever error continue
      execute ins_bdatm00369
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  70       then
      whenever error continue
      execute ins_bdatm00370
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  71       then
      whenever error continue
      execute ins_bdatm00371
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  72       then
      whenever error continue
      execute ins_bdatm00372
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  73       then
      whenever error continue
      execute ins_bdatm00373
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  74       then
      whenever error continue
      execute ins_bdatm00374
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  75       then
      whenever error continue
      execute ins_bdatm00375
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  76       then
      whenever error continue
      execute ins_bdatm00376
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  77       then
      whenever error continue
      execute ins_bdatm00377
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  78       then
      whenever error continue
      execute ins_bdatm00378
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  79       then
      whenever error continue
      execute ins_bdatm00379
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  80       then
      whenever error continue
      execute ins_bdatm00380
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  81       then
      whenever error continue
      execute ins_bdatm00381
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  82       then
      whenever error continue
      execute ins_bdatm00382
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  83       then
      whenever error continue
      execute ins_bdatm00383
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  84       then
      whenever error continue
      execute ins_bdatm00384
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  85       then
      whenever error continue
      execute ins_bdatm00385
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  86       then
      whenever error continue
      execute ins_bdatm00386
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  87       then
      whenever error continue
      execute ins_bdatm00387
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  88       then
      whenever error continue
      execute ins_bdatm00388
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  89       then
      whenever error continue
      execute ins_bdatm00389
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  90       then
      whenever error continue
      execute ins_bdatm00390
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  91       then
      whenever error continue
      execute ins_bdatm00391
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  92       then
      whenever error continue
      execute ins_bdatm00392
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  93       then
      whenever error continue
      execute ins_bdatm00393
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  94       then
      whenever error continue
      execute ins_bdatm00394
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  95       then
      whenever error continue
      execute ins_bdatm00395
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  96       then
      whenever error continue
      execute ins_bdatm00396
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  97       then
      whenever error continue
      execute ins_bdatm00397
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  98       then
      whenever error continue
      execute ins_bdatm00398
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  99       then
      whenever error continue
      execute ins_bdatm00399
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  100      then
      whenever error continue
      execute ins_bdatm003100
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  101      then
      whenever error continue
      execute ins_bdatm003101
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  102      then
      whenever error continue
      execute ins_bdatm003102
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  103      then
      whenever error continue
      execute ins_bdatm003103
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  104      then
      whenever error continue
      execute ins_bdatm003104
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  105      then
      whenever error continue
      execute ins_bdatm003105
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  106      then
      whenever error continue
      execute ins_bdatm003106
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  107      then
      whenever error continue
      execute ins_bdatm003107
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  108      then
      whenever error continue
      execute ins_bdatm003108
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  109      then
      whenever error continue
      execute ins_bdatm003109
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_ins is not null and
      m_ins >  110      then
      whenever error continue
      execute ins_bdatm003110
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   #----------------------------#
   #---> Roda comandos de UPDATE
   #----------------------------#
   if m_upd is not null and
      m_upd > 1        then
      whenever error continue
      execute upd_bdatm00301
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 2        then
      whenever error continue
      execute upd_bdatm00302
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 3        then
      whenever error continue
      execute upd_bdatm00303
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 4        then
      whenever error continue
      execute upd_bdatm00304
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 5        then
      whenever error continue
      execute upd_bdatm00305
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 6        then
      whenever error continue
      execute upd_bdatm00306
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 7        then
      whenever error continue
      execute upd_bdatm00307
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 8        then
      whenever error continue
      execute upd_bdatm00308
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 9        then
      whenever error continue
      execute upd_bdatm00309
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 10       then
      whenever error continue
      execute upd_bdatm00310
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 11       then
      whenever error continue
      execute upd_bdatm00311
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 12       then
      whenever error continue
      execute upd_bdatm00312
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 13       then
      whenever error continue
      execute upd_bdatm00313
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 14       then
      whenever error continue
      execute upd_bdatm00314
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 15       then
      whenever error continue
      execute upd_bdatm00315
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 16       then
      whenever error continue
      execute upd_bdatm00316
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 17       then
      whenever error continue
      execute upd_bdatm00317
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 18       then
      whenever error continue
      execute upd_bdatm00318
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 19       then
      whenever error continue
      execute upd_bdatm00319
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 20       then
      whenever error continue
      execute upd_bdatm00320
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 21       then
      whenever error continue
      execute upd_bdatm00321
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 22       then
      whenever error continue
      execute upd_bdatm00322
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 23       then
      whenever error continue
      execute upd_bdatm00323
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 24       then
      whenever error continue
      execute upd_bdatm00324
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 25       then
      whenever error continue
      execute upd_bdatm00325
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 26       then
      whenever error continue
      execute upd_bdatm00326
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 27       then
      whenever error continue
      execute upd_bdatm00327
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 28       then
      whenever error continue
      execute upd_bdatm00328
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd > 29       then
      whenever error continue
      execute upd_bdatm00329
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   if m_upd is not null and
      m_upd >  30       then
      whenever error continue
      execute upd_bdatm00330
      whenever error stop

      if sqlca.sqlcode <> 0 then
         return sqlca.sqlcode ---> Erro
      end if
   end if

   return 0

end function
function bdatm003_showSqlCode(l_origem,l_sql)
  define l_origem char(1)  ---> Se o prepare eh de um update,delete ou insert
  define l_sql char(1000)
  if sqlca.sqlcode <> 0 then
     if l_origem = 'u' then
        display "ERRO NO PREPARE ", m_upd using "<<<<<<&", " SQL ", l_sql clipped
     end if

     if l_origem = 'd' then
        display "ERRO NO PREPARE ", m_dlt using "<<<<<<&", " SQL ", l_sql clipped
     end if

     if l_origem = 'i' then
        display "ERRO NO PREPARE ", m_ins using "<<<<<<&", " SQL ", l_sql clipped
     end if
  end if
end function

