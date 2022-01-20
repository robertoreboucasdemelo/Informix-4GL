############################################################################
# Nome do Modulo: BDATA098                                        Raji     #
#                                                                          #
# Limpeza ATD CORRETOR  ( 1 ANO )                                 Nov/2000 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ------------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance            #
#--------------------------------------------------------------------------#
# 09/08/2006  Ligia Mattge   Zeladoria Rodar anualmente removendo os       #
#                                      dados de 2 anos atras.              #
#--------------------------------------------------------------------------#
# 10/03/2009  PSI 235580 Carla Rampazzo Auto Jovem-Curso Direcao Defensiva #
#                                       Inlcuir dacrdrscrsagdlig na limpeza#
#--------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail#
############################################################################

 database porto
globals
   define g_ismqconn smallint
end globals

 main

    call fun_dba_abre_banco('CT24HS')

    #set explain on
    set lock mode to wait
    call startlog("/ldat/ldata098")

    call bdata098()
    #set explain off
 end main

#--------------------------------------------------------------------------
 function bdata098()
#--------------------------------------------------------------------------

 define d_bdata098  record
    corlignum       like dacmlig.corlignum   ,
    corligano       like dacmlig.corligano
 end record

 define ws          record
    sql             char (500),
    srvexcflg       smallint  ,
    qtddct          smallint
 end record

 define a_bdata098  array[15] of record
    tabnom          char (20),
    qtdexc          integer
 end record

 define l_mens  record
        msg     char(1000)
       ,de      char(700)
       ,subject char(100)
       ,para    char(100)
       ,cc      char(100)
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

 define l_cmd   char(1200),
        l_erro  smallint,
        l_msg   char(50)

 define arr_aux     smallint

 define l_ano    smallint,
        l_mes    smallint,
        l_dia    smallint,
        l_datac  char(10),
        l_datai  date,
        l_dataf  date,
        msg_erro char(500)

#--------------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------------

 initialize l_mens.*  to null
 initialize d_bdata098.*  to null
 initialize ws.*          to null

 let a_bdata098[01].tabnom = "dacrligura"
 let a_bdata098[02].tabnom = "dacmligass"
 let a_bdata098[03].tabnom = "dacmligasshst"
 let a_bdata098[04].tabnom = "dacmpndret"
 let a_bdata098[05].tabnom = "dacrligvst"
 let a_bdata098[06].tabnom = "dacrligagnvst"
 let a_bdata098[07].tabnom = "dacrligfun"
 let a_bdata098[08].tabnom = "dacrligorc"
 let a_bdata098[09].tabnom = "dacrligpac"
 let a_bdata098[10].tabnom = "dacrligpndcvn"
 let a_bdata098[11].tabnom = "dacrligrmeorc"
 let a_bdata098[12].tabnom = "dacrligsmprnv"
 let a_bdata098[13].tabnom = "dacrligsus"
 let a_bdata098[14].tabnom = "dacmlig"
 let a_bdata098[15].tabnom = "dacrdrscrsagdlig"

 for arr_aux = 1 to 15
    let a_bdata098[arr_aux].qtdexc = 0
 end for

#--------------------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------------------
 let ws.sql = "delete from dacmlig where corlignum = ? and corligano = ?"
 prepare del_dacmlig from ws.sql

 let ws.sql = "delete from dacmligass where corlignum = ? and corligano = ?"
 prepare del_dacmligass from ws.sql

 let ws.sql = "delete from dacmligasshst where corlignum = ? and corligano = ?"
 prepare del_dacmligasshst from ws.sql

 let ws.sql = "delete from dacmpndret where corlignum = ? and corligano = ?"
 prepare del_dacmpndret from ws.sql

 let ws.sql = "delete from dacrligvst where corlignum = ? and corligano = ?"
 prepare del_dacrligvst from ws.sql

 let ws.sql = "delete from dacrligagnvst where corlignum = ? and corligano = ?"
 prepare del_dacrligagnvst from ws.sql

 let ws.sql = "delete from dacrligfun where corlignum = ? and corligano = ?"
 prepare del_dacrligfun from ws.sql

 let ws.sql = "delete from dacrligorc where corlignum = ? and corligano = ?"
 prepare del_dacrligorc from ws.sql

 let ws.sql = "delete from dacrligpac where corlignum = ? and corligano = ?"
 prepare del_dacrligpac from ws.sql

 let ws.sql = "delete from dacrligpndcvn where corlignum = ? and corligano = ?"
 prepare del_dacrligpndcvn from ws.sql

 let ws.sql = "delete from dacrligrmeorc where corlignum = ? and corligano = ?"
 prepare del_dacrligrmeorc from ws.sql

 let ws.sql = "delete from dacrligsmprnv where corlignum = ? and corligano = ?"
 prepare del_dacrligsmprnv from ws.sql

 let ws.sql = "delete from dacrligsus where corlignum = ? and corligano = ?"
 prepare del_dacrligsus from ws.sql

 let ws.sql = "delete from dacrligura where corlignum = ? and corligano = ?"
 prepare del_dacrligura from ws.sql

 let ws.sql = "delete from dacrdrscrsagdlig where corlignum=? and corligano=?"
 prepare del_dacrdrscrsagdlig from ws.sql

#--------------------------------------------------------------------------
# Obter a data inicial de final do ano que será removido
#--------------------------------------------------------------------------

 let l_ano = arg_val(1)

 if l_ano is null then

    let l_ano = year(today) - 1  ## ano anterior
    let l_mes = month(today) - 1 ## mes anterior

    let l_dia = 30

    if l_mes = 2 then
       let l_dia = 28
    end if

    if l_mes =  1 or l_mes =  3 or l_mes = 5 or l_mes = 7 or l_mes = 8 or
       l_mes = 10 or l_mes = 12 then
       let l_dia = 31
    end if

    let l_datac = '01/', l_mes using "&&",'/', l_ano using "####"
    let l_datai = l_datac

    let l_datac = l_dia using "&&", '/', l_mes using "&&",'/',
                  l_ano using "####"
    let l_dataf = l_datac

 else

    let l_datac = '01/01/', l_ano using "####"
    let l_datai = l_datac

    let l_datac = '31/12/', l_ano using "####"
    let l_dataf = l_datac

 end if

#--------------------------------------------------------------------------
# Le o arquivo DACMLIG para remover os dados gerados para ura ate 5 dias
#--------------------------------------------------------------------------

 declare c_bdata098 cursor with hold for
    select dacmlig.corlignum,
           dacmlig.corligano
      from dacmlig
     where dacmlig.ligdat >=  l_datai
     and   dacmlig.ligdat <=  l_dataf

 foreach c_bdata098 into d_bdata098.corlignum,
                         d_bdata098.corligano

    for arr_aux = 1 to 15
       case arr_aux
          when 1
             execute del_dacrligura using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 2
             execute del_dacmligass using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 3
             execute del_dacmligasshst using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 4
             execute del_dacmpndret using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 5
             execute del_dacrligvst using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 6
             execute del_dacrligagnvst using d_bdata098.corlignum,
                                             d_bdata098.corligano
          when 7
             execute del_dacrligfun using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 8
             execute del_dacrligorc using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 9
             execute del_dacrligpac using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 10
             execute del_dacrligpndcvn using d_bdata098.corlignum,
                                             d_bdata098.corligano
          when 11
             execute del_dacrligrmeorc using d_bdata098.corlignum,
                                             d_bdata098.corligano
          when 12
             execute del_dacrligsmprnv using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 13
             execute del_dacrligsus using d_bdata098.corlignum,
                                          d_bdata098.corligano
          when 14
             execute del_dacmlig using d_bdata098.corlignum,
                                       d_bdata098.corligano
          when 15
             execute del_dacrdrscrsagdlig using d_bdata098.corlignum,
                                                d_bdata098.corligano
       end case

       if sqlca.sqlcode  <>  0  then
          display "Erro (", sqlca.sqlcode,
                  ") na delecao da tabela ",
                  a_bdata098[arr_aux].tabnom clipped, " !"
          exit program (1)
       end if
       let a_bdata098[arr_aux].qtdexc =
           a_bdata098[arr_aux].qtdexc + sqlca.sqlerrd[3]
    end for

 end foreach

#----------------------------------------------------------
# Atualiza STATISTICS
#----------------------------------------------------------
# update statistics for table  dacrligura
# update statistics for table  dacmligurastt
# update statistics for table  aoimurafax

#--------------------------------------------------------------------------
# Exibe total de registros removidos por tabela
#--------------------------------------------------------------------------

 display "                                 "
 display " <<< RESUMO DO PROCESSAMENTO ", l_datai, " ate ", l_dataf, " >>> "
 display "                                 "
 display " TABELA               QUANTIDADE "
 display " ------------------------------- "

let l_mens.msg = "<html><body><font face=courier new><<< RESUMO DO PROCESSAMENTO ", l_datai, " at&eacute; ",
                 l_dataf, " >>> ", '<br>',
                 "  TABELA               QUANTIDADE ",'<br>',
                 " ------------------------------- ", '<br>'

 for arr_aux = 1 to 15
    display " ", a_bdata098[arr_aux].tabnom, " ",
                 a_bdata098[arr_aux].qtdexc using "##,###,##&"

    let l_mens.msg = l_mens.msg  clipped,
                     " ", a_bdata098[arr_aux].tabnom, " ",
                     a_bdata098[arr_aux].qtdexc using "##,###,##&" , '<br>'
 end for

 display " -----------------------fim----- "
 display " "

 let l_mens.msg = l_mens.msg  clipped,  " -----------------------fim----- </font></body></html>"

 ## Busca os destinatarios que receberao o resumo acima
 call cty11g00_iddkdominio("bdata098", 01)
      returning l_erro, l_msg, l_mens.para

 call cty11g00_iddkdominio("bdata098", 02)
      returning l_erro, l_msg, l_mens.cc

 if l_mens.para is null then
    return
 end if

  #PSI-2013-23297 - Inicio
  let l_mail.de = "CT24H-BDATA098"
  let l_mail.para = l_mens.para
  let l_mail.cc = l_mens.cc
  let l_mail.cco = " "
  let l_mail.assunto = "Limpeza das tabelas do Atd_cor"
  let l_mail.mensagem = l_mens.msg
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "html"

  call figrc009_mail_send1 (l_mail.*)
     returning l_erro,msg_erro

  #PSI-2013-23297 - Fim
 if l_erro = 0 then
    display 'Email enviado com sucesso'
 else
    display 'Email NAO enviado'
 end if

end function
