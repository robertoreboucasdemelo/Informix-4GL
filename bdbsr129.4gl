#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: bdbsr129                                                   #
# ANALISTA RESP..: ADRIANO SANTOS                                             #
# PSI/OSF........: 249912                                                     #
#                  AVISO DE VENCIMENTO DA VIGENCIA DO PRESTADOR E BLOQUEIO    #
#                  PARA VIGENCIA VENCIDA                                      #
# ........................................................................... #
# DESENVOLVIMENTO: ADRIANO SAONTS                                             #
# LIBERACAO......: 23/11/2009                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 03/08/2010 Beatriz Araujo  CT 800838  Mudanca do SQL para trazer a maxima   #
#                                       Vigencia do prestador e verifique se  #
#                                       esta eh a vencida                     #
#-----------------------------------------------------------------------------#
# 08/06/2015 RCP, Fornax     RELTXT     Criar versao .txt dos relatorios.     #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define mr_bdbsr129      record
         pstcoddig          like dpaksocor.pstcoddig,          # Codigo do Prestador
         nomgrr             like dpaksocor.nomgrr,             # Nome de Guerra
         prssitcod          like dpaksocor.nomgrr,             # Codigo da situacao
         prssitdes          char(09),                          # Descricao da situacao
         cntvigincdat       like dpakprscntvigctr.cntvigincdat,# Inicio da vigencia
         cntvigfnldat       like dpakprscntvigctr.cntvigfnldat,# Fim da vigencia
         atldat             like dpakprscntvigctr.atldat,      # Data de atualizacao
         atlemp             like dpakprscntvigctr.atlemp,      # Empresa do usuario
         atlusrtip          like dpakprscntvigctr.atlusrtip,   # Tipo do usuario
         atlmat             like dpakprscntvigctr.atlmat,      # Matricula do usuario
         funnom             like isskfunc.funnom               # Nome do usuario
  end record

  define m_data_ini_aviso date,
         m_data_fim_aviso date,
         m_data_ini_venc  date,
         m_data_fim_venc  date,
         l_data_atual     date,
         l_hora_atual     datetime hour to minute,
         m_mes_int        smallint,
         m_mes_nom        char(10)

  define m_path           char(1000)
  define m_path_txt       char(1000) #--> RELTXT
  define m_path2          char(1000)
  define m_path2_txt      char(1000) #--> RELTXT

main

       initialize mr_bdbsr129.*,
                  m_path,
                  m_path_txt,  #--> RELTXT
                  m_path2,
                  m_path2_txt, #--> RELTXT
                  m_data_ini_aviso,
                  m_data_fim_aviso,
                  m_data_ini_venc,
                  m_data_ini_venc,
                  l_data_atual,
                  l_hora_atual  to null


       #Calculo do mes para execução ou recebido como parametro
       #caso não seja executado no ultima dia do mes
       let l_data_atual = arg_val(1)

       if l_data_atual is null or l_data_atual = " " then
           # ---> OBTER A DATA E HORA DO BANCO
           call cts40g03_data_hora_banco(2)
           returning l_data_atual,
                     l_hora_atual
       end if

       display 'l_data_atual = ', l_data_atual

       # ---> DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
       if  month(l_data_atual) = 01 then
           let m_data_ini_aviso = mdy(3,01,year(l_data_atual))
           let m_data_fim_aviso = mdy(3,31,year(l_data_atual))

           let m_data_ini_venc = mdy(11,01,year(l_data_atual) - 1)
           let m_data_fim_venc = mdy(11,30,year(l_data_atual) - 1)
       else
           let m_data_ini_aviso = mdy(month(l_data_atual) + 1,01,year(l_data_atual))
           let m_data_ini_aviso = m_data_ini_aviso + 1 units month
           let m_data_fim_aviso = m_data_ini_aviso + 1 units month
           let m_data_fim_aviso = m_data_fim_aviso - 1 units day

           let m_data_ini_venc = mdy(month(l_data_atual) - 1,01,year(l_data_atual))
           let m_data_ini_venc = mdy(month(m_data_ini_venc) - 1,01,year(m_data_ini_venc))
           let m_data_fim_venc = m_data_ini_venc + 1 units month
           let m_data_fim_venc = m_data_fim_venc - 1 units day
           #let m_data_fim_venc = mdy(month(l_data_atual),01,year(l_data_atual)) - 1 units day
       end if

       display 'm_data_ini_aviso = ', m_data_ini_aviso
       display 'm_data_fim_aviso = ', m_data_fim_aviso
       display 'm_data_ini_venc  = ', m_data_ini_venc
       display 'm_data_fim_venc  = ', m_data_fim_venc

       call fun_dba_abre_banco("CT24HS")
       call bdbsr129_busca_path()
       call cts40g03_exibe_info("I","BDBSR129")
       call bdbsr129_prepare()
       call bdbsr129_vencimento()
       call cts40g03_exibe_info("F","BDBSR129")

end main


#---------------------------#
 function bdbsr129_prepare()
#---------------------------#

        define l_sql   char(5000)

        # Para buscar as vigencias mais recentes dos prestadores
        # 03/08/2010 Beatriz Araujo - CT 800838
         let l_sql = "select p.pstcoddig,         ",
                            "p.nomgrr,            ",
                            "p.prssitcod,         ",
                            "max(v.cntvigincdat), ",
                            "max(v.cntvigfnldat), ",
                            "v.atldat,            ",
                            "v.atlemp,            ",
                            "v.atlusrtip,         ",
                            "v.atlmat             ",
                       "from dpaksocor p, dpakprscntvigctr v ",
                      "where p.pstcoddig = v.pstcoddig ",
                        "and p.qldgracod = 1 ",
                        "group by p.pstcoddig,p.nomgrr,p.prssitcod,",
                        "v.atldat,v.atlemp,v.atlusrtip,v.atlmat "

        prepare pbdbsr129_01 from l_sql
        declare cbdbsr129_01 cursor for pbdbsr129_01

        let l_sql = " update dpaksocor                  ",
                    "  set (atldat, funmat, prssitcod)  ",
                    "    = (today, 999999, 'B')              ",
                    " where pstcoddig = ?               "
        prepare cbdbsr129_02 from l_sql

        let l_sql = " insert into dbsmhstprs (pstcoddig, dbsseqcod, prshstdes,"
                   ,"                         caddat   , cademp   , cadusrtip, cadmat)"
                   ," values(?,?,?,?,1,'F',999999) "
        prepare cbdbsr129_03 from l_sql

end function
#-----------------------------#
 function bdbsr129_busca_path()
#-----------------------------#

  define l_dataarq char(8)
  define l_data    date

  let l_data = today
  display "l_data: ", l_data
  let l_dataarq = extend(l_data, year to year),
                  extend(l_data, month to month),
                  extend(l_data, day to day)
  display "l_dataarq: ", l_dataarq

  let m_path = null
  let m_path = f_path("DBS","LOG")
  if  m_path is null then
     let m_path = "."
  end if

  let m_path = m_path clipped,"/bdbsr129.log"
  call startlog(m_path)

  let m_path = f_path("DBS", "RELATO")
  if  m_path is null then
     let m_path = "."
  end if

  # ---> Cria o relatorio dos prestadores que estao com as
  #      vigencias para vencer(bdbsr1291.xls) e as vencidas (bdbsr1292.xls)
  let m_path2_txt = m_path clipped, "/bdbsr1292_", l_dataarq, ".txt"
  let m_path2     = m_path clipped, "/bdbsr1292.xls"
  let m_path_txt  = m_path clipped, "/bdbsr1291_", l_dataarq, ".txt"
  let m_path      = m_path clipped, "/bdbsr1291.xls"

 end function

#---------------------------------#
 function bdbsr129_vencimento()
#---------------------------------#


define l_erro_envio  integer,
       l_assunto     char(100),
       l_comando     char(100)

########### Esse report será o relatório enviado para os e-mail's cadastrados no BDBSR129
start report rep_bdbsr129_1 to m_path
start report rep_bdbsr129_1_txt to m_path_txt #--> RELTXT

# 03/08/2010 Beatriz Araujo - CT 800838
# Vigencias que irão vencer -  onde primeiro verifica-se
# a vigência mais recente e depois se ela ira vencer
open cbdbsr129_01 #using m_data_ini_aviso,
                  #      m_data_fim_aviso

foreach cbdbsr129_01 into mr_bdbsr129.pstcoddig   ,
                          mr_bdbsr129.nomgrr      ,
                          mr_bdbsr129.prssitcod   ,
                          mr_bdbsr129.cntvigincdat,
                          mr_bdbsr129.cntvigfnldat,
                          mr_bdbsr129.atldat      ,
                          mr_bdbsr129.atlemp      ,
                          mr_bdbsr129.atlusrtip   ,
                          mr_bdbsr129.atlmat

         case sqlca.sqlcode

             when 0
                   if mr_bdbsr129.cntvigfnldat >= m_data_ini_aviso and
                      mr_bdbsr129.cntvigfnldat <= m_data_fim_aviso then
                       display "Entrei no if do irao vencer com data: ", mr_bdbsr129.cntvigfnldat
                      output to report rep_bdbsr129_1()
                      output to report rep_bdbsr129_1_txt() #--> RELTXT
                   end if
             end case
end foreach

finish report rep_bdbsr129_1
finish report rep_bdbsr129_1_txt #--> RELTXT

# Assunto
let l_assunto = "Aviso de contratos vencendo no mês "
                , month(m_data_ini_aviso),"/",year(m_data_ini_aviso)
# COMPACTA O ARQUIVO DO RELATORIO
let l_comando = "gzip -f ", m_path
run l_comando
let m_path = m_path  clipped, ".gz "

let l_erro_envio = ctx22g00_envia_email("BDBSR129", l_assunto, m_path)
if  l_erro_envio <> 0 then
         display "Erro no envio do email no ctx22g00: ",
                 l_erro_envio using "<<<<<<&", " - "
end if

########### Esse report será o relatório enviado para os e-mail's cadastrados no BDBSR129
start report rep_bdbsr129_2 to m_path2
start report rep_bdbsr129_2_txt to m_path2_txt #--> RELTXT

# 03/08/2010 Beatriz Araujo - CT 800838
# Vigencias que estão vencidas -  onde primeiro verifica-se
# a vigência mais recente e depois se ela ja esta vencida
open cbdbsr129_01 #using m_data_ini_venc,
                  #      m_data_fim_venc

foreach cbdbsr129_01 into mr_bdbsr129.pstcoddig   ,
                          mr_bdbsr129.nomgrr      ,
                          mr_bdbsr129.prssitcod   ,
                          mr_bdbsr129.cntvigincdat,
                          mr_bdbsr129.cntvigfnldat,
                          mr_bdbsr129.atldat      ,
                          mr_bdbsr129.atlemp      ,
                          mr_bdbsr129.atlusrtip   ,
                          mr_bdbsr129.atlmat

         case sqlca.sqlcode

             when 0
                   if mr_bdbsr129.cntvigfnldat >= m_data_ini_venc and
                      mr_bdbsr129.cntvigfnldat <= m_data_fim_venc then
                      display "Entrei no if do vencidas com data: ",mr_bdbsr129.cntvigfnldat
                      output to report rep_bdbsr129_2()
                      output to report rep_bdbsr129_2_txt() #--> RELTXT
                   end if

             end case
end foreach
finish report rep_bdbsr129_2
finish report rep_bdbsr129_2_txt #--> RELTXT

let l_assunto = "PRESTADORES BLOQUEADOS - Contratos vencidos em "
                , month(m_data_ini_venc),"/",year(m_data_ini_venc)
# COMPACTA O ARQUIVO DO RELATORIO
let l_comando = "gzip -f ", m_path2
run l_comando
let m_path2 = m_path2  clipped, ".gz "

let l_erro_envio = ctx22g00_envia_email("BDBSR129", l_assunto, m_path2)
if  l_erro_envio <> 0 then
         display "Erro no envio do email no ctx22g00: ",
                 l_erro_envio using "<<<<<<&", " - "
end if
end function

#-----------------------#
 report rep_bdbsr129_1()
#-----------------------#

        define lr_cty08g00     record
               erro           smallint,
               mensagem       char(60),
               funnom         like isskfunc.funnom
        end record

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "RELATORIO DE AVISO DE VENCIMENTO DE VIGENCIA DO PRESTADOR."

                print ""

                print "CODIGO PRESTADOR",   ASCII(09),
                      "NOME GUERRA",        ASCII(09),
                      "SITUAÇÃO",           ASCII(09),
                      "INICIO DA VIGENCIA", ASCII(09),
                      "FIM DA VIGENCIA",    ASCII(09),
                      "ATUALIZADO EM",      ASCII(09),
                      "POR",                ASCII(09),
                      "DATA",               ASCII(09) #--> FX-080515

            on every row

                call bdbsr129_historico(mr_bdbsr129.pstcoddig, 'A')

                case mr_bdbsr129.prssitcod
                   when "A"  let mr_bdbsr129.prssitdes = "ATIVO"
                   when "C"  let mr_bdbsr129.prssitdes = "CANCELADO"
                   when "P"  let mr_bdbsr129.prssitdes = "PROPOSTA"
                   when "B"  let mr_bdbsr129.prssitdes = "BLOQUEADO"
                   otherwise let mr_bdbsr129.prssitdes = "NAO CADASTRADO"
                end case

                call cty08g00_nome_func(mr_bdbsr129.atlemp,mr_bdbsr129.atlmat,"F")
                     returning lr_cty08g00.*
                let mr_bdbsr129.funnom = lr_cty08g00.funnom

                print mr_bdbsr129.pstcoddig    clipped   ,ASCII(09);
                print mr_bdbsr129.nomgrr       clipped   ,ASCII(09);
                print mr_bdbsr129.prssitdes    clipped   ,ASCII(09);
                print mr_bdbsr129.cntvigincdat           ,ASCII(09);
                print mr_bdbsr129.cntvigfnldat clipped   ,ASCII(09);
                print mr_bdbsr129.atldat                 ,ASCII(09);
                print mr_bdbsr129.funnom       clipped   ,ASCII(09);
		            print today

end report

#---------------------------------------#
 report rep_bdbsr129_1_txt() #--> RELTXT
#---------------------------------------#

        define lr_cty08g00     record
               erro           smallint,
               mensagem       char(60),
               funnom         like isskfunc.funnom
        end record

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    01

        format

            on every row

                call bdbsr129_historico(mr_bdbsr129.pstcoddig, 'A')

                case mr_bdbsr129.prssitcod
                   when "A"  let mr_bdbsr129.prssitdes = "ATIVO"
                   when "C"  let mr_bdbsr129.prssitdes = "CANCELADO"
                   when "P"  let mr_bdbsr129.prssitdes = "PROPOSTA"
                   when "B"  let mr_bdbsr129.prssitdes = "BLOQUEADO"
                   otherwise let mr_bdbsr129.prssitdes = "NAO CADASTRADO"
                end case

                call cty08g00_nome_func(mr_bdbsr129.atlemp,mr_bdbsr129.atlmat,"F")
                     returning lr_cty08g00.*
                let mr_bdbsr129.funnom = lr_cty08g00.funnom

                print mr_bdbsr129.pstcoddig    clipped,ASCII(09);
                print mr_bdbsr129.nomgrr       clipped,ASCII(09);
                print mr_bdbsr129.prssitdes    clipped,ASCII(09);
                print mr_bdbsr129.cntvigincdat,        ASCII(09);
                print mr_bdbsr129.cntvigfnldat clipped,ASCII(09);
                print mr_bdbsr129.atldat,              ASCII(09);
                print mr_bdbsr129.funnom       clipped,ASCII(09);
                print today

end report

#-----------------------#
 report rep_bdbsr129_2()
#-----------------------#

        define lr_cty08g00     record
               erro           smallint,
               mensagem       char(60),
               funnom         like isskfunc.funnom
        end record

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    07

        format

            first page header

                print "RELATORIO DE PRESTADORES BLOQUEADOS EM FUNÇÃO DO VENCIMENTO DA VIGENCIA DO CONTRATO."

                print ""

                print "CODIGO PRESTADOR",   ASCII(09),
                      "NOME GUERRA",        ASCII(09),
                      "SITUAÇÃO",           ASCII(09),
                      "INICIO DA VIGENCIA", ASCII(09),
                      "FIM DA VIGENCIA",    ASCII(09),
                      "ATUALIZADO EM",      ASCII(09),
                      "POR",                ASCII(09),
                      "DATA",               ASCII(09) #--> FX-080515

            on every row

                call bdbsr129_historico(mr_bdbsr129.pstcoddig, 'B')

                case mr_bdbsr129.prssitcod
                   when "A"  let mr_bdbsr129.prssitdes = "ATIVO"
                   when "C"  let mr_bdbsr129.prssitdes = "CANCELADO"
                   when "P"  let mr_bdbsr129.prssitdes = "PROPOSTA"
                   when "B"  let mr_bdbsr129.prssitdes = "BLOQUEADO"
                   otherwise let mr_bdbsr129.prssitdes = "NAO CADASTRADO"
                end case

                call cty08g00_nome_func(mr_bdbsr129.atlemp,mr_bdbsr129.atlmat,"F")
                     returning lr_cty08g00.*
                let mr_bdbsr129.funnom = lr_cty08g00.funnom

                print mr_bdbsr129.pstcoddig   clipped,ASCII(09);
                print mr_bdbsr129.nomgrr      clipped,ASCII(09);
                print "BLOQUEADO"                    ,ASCII(09);
                print mr_bdbsr129.cntvigincdat,       ASCII(09);
                print mr_bdbsr129.cntvigfnldat clipped,ASCII(09);
                print mr_bdbsr129.atldat,             ASCII(09);
                print mr_bdbsr129.funnom      clipped,ASCII(09);
                print today,                          ASCII(09) #--> FX-080515
end report

#---------------------------------------#
 report rep_bdbsr129_2_txt() #--> RELTXT
#---------------------------------------#

        define lr_cty08g00    record
               erro           smallint,
               mensagem       char(60),
               funnom         like isskfunc.funnom
        end record

        output
            left   margin    00
            right  margin    00
            top    margin    00
            bottom margin    00
            page   length    01

        format

            on every row

                call bdbsr129_historico(mr_bdbsr129.pstcoddig, 'B')

                case mr_bdbsr129.prssitcod
                   when "A"  let mr_bdbsr129.prssitdes = "ATIVO"
                   when "C"  let mr_bdbsr129.prssitdes = "CANCELADO"
                   when "P"  let mr_bdbsr129.prssitdes = "PROPOSTA"
                   when "B"  let mr_bdbsr129.prssitdes = "BLOQUEADO"
                   otherwise let mr_bdbsr129.prssitdes = "NAO CADASTRADO"
                end case

                call cty08g00_nome_func(mr_bdbsr129.atlemp,mr_bdbsr129.atlmat,"F")
                     returning lr_cty08g00.*
                let mr_bdbsr129.funnom = lr_cty08g00.funnom

                print mr_bdbsr129.pstcoddig    clipped  ,ASCII(09);
                print mr_bdbsr129.nomgrr       clipped  ,ASCII(09);
                print "BLOQUEADO"                       ,ASCII(09);
                print mr_bdbsr129.cntvigincdat          ,ASCII(09);
                print mr_bdbsr129.cntvigfnldat clipped  ,ASCII(09);
                print mr_bdbsr129.atldat                ,ASCII(09);
                print mr_bdbsr129.funnom       clipped  ,ASCII(09);
                print today
end report

#------------------------------------------------------------
function bdbsr129_historico(lr_param)
#------------------------------------------------------------

  define lr_param      record
     pstcoddig      like dpaksocor.pstcoddig,
     tipo           char(1)
  end record

  define l_prshstdes char(2000)

    define lr_ret record
         texto1  char(70)
        ,texto2  char(70)
        ,texto3  char(70)
        ,texto4  char(70)
        ,texto5  char(70)
        ,texto6  char(70)
        ,texto7  char(70)
        ,texto8  char(70)
        ,texto9  char(70)
        ,texto10 char(70)
  end record

  define l_stt       smallint
        ,l_path      char(100)
        ,l_cmd2      char(4000)
        ,l_texto2    char(3000)

  define l_dbsseqcod  like dbsmhstprs.dbsseqcod,
         l_prshstdes2 like dbsmhstprs.prshstdes,
         l_texto      like dbsmhstprs.prshstdes,
         l_cmtnom     like isskfunc.funnom,
         l_data       date,
         l_hora       datetime hour to minute,
         l_count,
         l_iter,
         l_length,
         l_length2    smallint,
         l_msg        char(50),
         l_erro       smallint,
         l_cmd        char(100),
         l_corpo_email char(1000),
         teste         char(1)

  let l_msg = null

  if lr_param.tipo = 'B' then
      execute cbdbsr129_02 using lr_param.pstcoddig

      if sqlca.sqlcode = 0 then
          let l_prshstdes = " AVISO DO SISTEMA: RESPONSÁVEIS NOTIFICADOS NESSA DATA SOBRE O BLOQUEIO",
                            " DESTE PRESTADOR EM RAZAO DE CONTRATO VENCIDO EM ",mr_bdbsr129.cntvigfnldat," E NAO RENOVADO. "
      end if
  else
      let l_prshstdes = " AVISO DO SISTEMA: RESPONSÁVEIS NOTIFICADOS NESSA DATA SOBRE A PROXIMIDADE",
                        " DO VENCIMENTO DO CONTRATO DESTE PRESTADOR ",mr_bdbsr129.cntvigfnldat,". "
  end if

  #Buscar ultimo item de historico cadastrado para o prestador
  let l_dbsseqcod = 0
  select max(dbsseqcod) into l_dbsseqcod
    from dbsmhstprs
   where pstcoddig = lr_param.pstcoddig

  if l_dbsseqcod is null or l_dbsseqcod = 0 then
     let l_dbsseqcod = 1
  else
     let l_dbsseqcod = l_dbsseqcod + 1
  end if

  #Busca data e hora do banco
  call cts40g03_data_hora_banco(2) returning l_data, l_hora

  let l_length = length(l_prshstdes clipped)
  if  l_length mod 70 = 0 then
      let l_iter = l_length / 70
  else
      let l_iter = l_length / 70 + 1
  end if

  let l_corpo_email = null
  let l_length2     = 0
  let l_erro        = 0

  for l_count = 1 to l_iter
      if  l_count = l_iter then
          let l_prshstdes2 = l_prshstdes[l_length2 + 1, l_length]
      else
          let l_length2 = l_length2 + 70
          let l_prshstdes2 = l_prshstdes[l_length2 - 69, l_length2]
      end if

      #Grava historico para o prestador
      execute cbdbsr129_03 using lr_param.pstcoddig,
                                 l_dbsseqcod,
                                 l_prshstdes2,
                                 l_data

      if sqlca.sqlcode <> 0  then
          error "Erro (", sqlca.sqlcode, ") na inclusao do historico (dbsmhstprs). "
          let l_erro = sqlca.sqlcode
      end if

      if l_erro <> 0 then
         exit for
      end if

      let l_dbsseqcod  = l_dbsseqcod + 1

  end for

  if l_erro = 0 then
     #Envia Email para o prestador

     let l_msg = 'Alteracao no Cadastro do Prestador: Codigo  ',
                  lr_param.pstcoddig

     initialize l_cmtnom   to null

     select funnom  into  l_cmtnom
     from isskfunc
     where funmat = g_issk.funmat
      and empcod  = g_issk.empcod

     call ctb85g01_mtcorpo_email_html("CTC00M02",
                                      l_data,
                                      l_hora,
                                      1,
                                      'F',
                                      999999,
                                      l_msg,
                                      l_prshstdes clipped)
                            returning l_erro

     if l_erro <> 0 then
        error "Erro Envio do Email ", l_erro
     end if
  end if

end function
