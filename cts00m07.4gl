#############################################################################
# Nome do Modulo: CTS00M07                                         Marcelo  #
#                                                                  Gilberto #
# Servicos que estao sendo acionados pelos operadores de radio     Mar/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 01/02/2000               Gilberto     Confirmacao para desbloqueio da OS. #
#---------------------------------------------------------------------------#
# 14/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 30/08/2000  PSI 11459-6  Marcus       Conclusao de Servico pelo Atendente #
#---------------------------------------------------------------------------#
# 07/04/2010  CT 769673    Beatriz      Gravar no histórico o desbloqueio   #
#                                       do serviço(quem desbloqueou)        #
#############################################################################

 database porto
#globals  "glct.4gl"
globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts00m07()
#-----------------------------------------------------------

 define a_cts00m07 array[1000] of record
    srvnum       char (13)                   ,
    srvtipabvdes like datksrvtip.srvtipabvdes,
    funnom       like isskfunc.funnom,
    atdvclsgl    like datkveiculo.atdvclsgl,
    socvclcod    like datkveiculo.socvclcod,
    c24opemat    like datmservico.c24opemat
 end record

 define ws       record
    sql          char (300)                 ,
    atdsrvnum    like datmservico.atdsrvnum ,
    atdsrvano    like datmservico.atdsrvano ,
    atdsrvorg    like datmservico.atdsrvorg ,
    c24opemat    like datmservico.c24opemat ,
    c24opeempcod like datmservico.c24opeempcod ,
    socvclcod    like datmservico.socvclcod ,
    srrcoddig    like datmservico.srrcoddig ,
    horatu       datetime hour to second    ,
    acionados    smallint                   ,
    cabec        char (64)                  ,
    resp         char (1)
 end record

 define arr_aux     smallint
 define scr_aux     smallint
 define l_etapa     like datmsrvacp.atdetpcod
 # Para saber quem desbloqueou o serviço
 define desblo_data      date
 define desblo_hora      datetime hour to minute
 define histerr          smallint
 define msg_desbloqueio1 char(100)
 define msg_desbloqueio2 char(100)
#-----------------------------------------------------------
# Preparacao dos comandos SQL
#-----------------------------------------------------------


        define  w_pf1   integer

        let     arr_aux  =  null
        let     scr_aux  =  null
        for     w_pf1  =  1  to  1000
                initialize  a_cts00m07[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

 let l_etapa = null
 let ws.sql = "select srvtipabvdes",
              "  from datksrvtip  ",
              " where atdsrvorg = ?  "

 prepare sel_datksrvtip from ws.sql
 declare c_datksrvtip cursor for sel_datksrvtip

 let ws.sql = "select funnom    ",
              "  from isskfunc  ",
              " where funmat = ?",
              " and   empcod = ?"

 prepare sel_isskfunc   from ws.sql
 declare c_isskfunc   cursor for sel_isskfunc

 let ws.sql = "select datkveiculo.atdvclsgl from datkveiculo, datmservico",
              " where datmservico.atdsrvorg= ? ",
              " AND datmservico.atdsrvnum=? ",
              " AND datmservico.atdsrvano=? ",
              " AND datmservico.socvclcod=datkveiculo.socvclcod"

 prepare sel_atdvclsgl from ws.sql
 declare c_atdvclsgl   cursor for sel_atdvclsgl

 open window cts00m07 at 03,02 with form "cts00m07"
                      attribute(form line 1)

 while TRUE

    initialize a_cts00m07  to null
    initialize ws.*        to null
    let ws.acionados  =  000
    let int_flag      =  false
    let ws.horatu     =  current hour to second
    display by name ws.horatu

    declare c_cts00m07 cursor for
       select atdsrvnum, atdsrvano,
              atdsrvorg   , c24opemat  ,c24opeempcod
              socvclcod   , srrcoddig
         from datmservico
        where atdlibflg in ("S","N")  and
              atdfnlflg in ("N","A")  and
              c24opemat is not null   and
              atdsrvorg <> 10             # NAO LISTAR SERVICOS DA VP

    let arr_aux = 1

    foreach c_cts00m07 into ws.atdsrvnum     ,
                            ws.atdsrvano     ,
                            ws.atdsrvorg     ,
                            ws.c24opemat     ,
                            ws.c24opeempcod  ,
                            ws.socvclcod     ,
                            ws.srrcoddig

       let l_etapa = cts10g04_ultima_etapa(ws.atdsrvnum,
                                           ws.atdsrvnum)
       if l_etapa = 3 or
          l_etapa = 4 then
          # -> DESPREZA OS SERVICOS ACIONADOS
          continue foreach
       end if

       let a_cts00m07[arr_aux].srvnum =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                                    "/", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                                    "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)

       let a_cts00m07[arr_aux].srvtipabvdes = "NAO PREV."

       open  c_datksrvtip using ws.atdsrvorg
       fetch c_datksrvtip into  a_cts00m07[arr_aux].srvtipabvdes
       close c_datksrvtip


       let a_cts00m07[arr_aux].c24opemat = ws.c24opemat
       let a_cts00m07[arr_aux].funnom = "NAO CADASTRADO"

       if ws.c24opeempcod is null or
          ws.c24opeempcod = "" then
          let ws.c24opeempcod = 1
       end if
       open  c_isskfunc   using ws.c24opemat,ws.c24opeempcod
       fetch c_isskfunc   into  a_cts00m07[arr_aux].funnom
       close c_isskfunc

       let a_cts00m07[arr_aux].funnom = upshift(a_cts00m07[arr_aux].funnom)

       open  c_atdvclsgl   using ws.atdsrvorg, ws.atdsrvnum, ws.atdsrvano
       fetch c_atdvclsgl   into a_cts00m07[arr_aux].atdvclsgl
       close c_atdvclsgl
       let a_cts00m07[arr_aux].atdvclsgl = null

       let a_cts00m07[arr_aux].socvclcod = ws.socvclcod

       let ws.acionados = ws.acionados + 1
       let arr_aux = arr_aux + 1
       if arr_aux  >  1000   then
          error "Limite excedido,tabela de operadores com mais de 1000 servicos!"
          exit foreach
       end if

    end foreach

    let ws.cabec = "Servicos sendo acionados: ", ws.acionados  using "&&&"
    display ws.cabec  to  cabec

    if arr_aux = 1   then
       error " Nao existem servicos sendo acionados !"
    end if

    call set_count(arr_aux-1)
    message " (F17)Abandona, (F8)Desbloqueia"

    display array a_cts00m07 to s_cts00m07.*

       on key (interrupt,control-c)
          let int_flag = true
          exit display

       #-----------------------------------------------------------
       # Desbloqueia servico
       #-----------------------------------------------------------
       on key (F8)
          let arr_aux = arr_curr()
          if g_issk.funmat    = a_cts00m07[arr_aux].c24opemat or
             g_issk.acsnivcod > 6                             then
             if cts08g01("C","S","","DESBLOQUEIA SERVICO","SENDO ACIONADO?","") = "N"  then
                exit display
             end if
       ##### 07/04/2010 - Beatriz Araujo- Gravar no histórico o desbloqueio do serviço
             let desblo_data = today
             let desblo_hora = current
             let ws.atdsrvnum = a_cts00m07[arr_aux].srvnum[04,10]
             let ws.atdsrvano = a_cts00m07[arr_aux].srvnum[12,13]
             initialize ws.c24opemat  to null
             let msg_desbloqueio1 = "ESTE SERVIÇO ESTAVA COM ",a_cts00m07[arr_aux].funnom
             let msg_desbloqueio2 = "E FOI DESBLOQUEADO COM SUCESSO POR ",g_issk.funnom
             call cts10g02_historico(ws.atdsrvnum, ws.atdsrvano,
                                     desblo_data , desblo_hora ,
                                     g_issk.funmat           ,
                                     msg_desbloqueio1,msg_desbloqueio2,"","","")
                        returning histerr

             if histerr <> 0  then
               error "Erro (",histerr,") na inclusao do historico DO DESBLOQUEIO."
             end if
             begin work
       ### Fim
             update datkveiculo  set socacsflg = "0"
              where socvclcod = a_cts00m07[arr_aux].socvclcod

             if sqlca.sqlcode <> 0   then
                display "Erro (", sqlca.sqlcode, ") no Desbloqueio da Viatura!"
                rollback work
             else
                initialize ws.socvclcod   to null
                initialize ws.srrcoddig   to null

                update datmservico  set c24opemat = ws.c24opemat,
                socvclcod = ws.socvclcod , srrcoddig = ws.srrcoddig
                 where atdsrvnum  =  ws.atdsrvnum   and
                  atdsrvano  =  ws.atdsrvano

                if sqlca.sqlcode <> 0   then
                   display "Erro (", sqlca.sqlcode, ") no Desbloqueio do Servico!"
                   rollback work
                else

                   commit work

                   # Ponto de acesso apos a gravacao do laudo
                   call cts00g07_apos_servdesbloqueia(ws.atdsrvnum,
                                                      ws.atdsrvano)
                end if
             end if
             exit display
          else
             call cts08g01("A",
                           "",
                           "VOCE NAO POSSUI ACESSO PARA LIBERAR",
                           "ACIONAMENTO  DE OUTROS  OPERADORES!",
                           "CONTATE SEU COORDENADOR.",
                           "")
             returning ws.resp
          end if

    end display

    if int_flag   then
       exit while
    end if

 end while

 close window cts00m07
 let int_flag = false

end function  ###  cts00m07
