#############################################################################
# Nome do Modulo: wdatc015                                           Marcus #
#                                                                           #
# Modulo principal de recebimento de Servicos pela Internet        Ago/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA     SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
# 05/05/03 ch- guilherme             alterado o tempo de 3 para 7 minutos   #
# 10/07/03 ch- oriente  Zyon         alterado o tempo de 6 para 8 minutos   #
#---------------------------------------------------------------------------#
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
#                                                                           #
# 20/02/2006 JUNIOR (Meta)     PSI.196878 Assistencia passageiro e carro    #
#                                         extra                             #
#                                                                           #
#---------------------------------------------------------------------------#
# 23/08/2007 Saulo, Meta       AS146056   Palavras reservadas substituidas  #
#                                         fun_dba_abre_banco movida para o  #
#                                         inicio do modulo                  #
#---------------------------------------------------------------------------#

database porto

globals
    define g_ismqconn        smallint,
           g_servicoanterior smallint,
           g_meses           integer,
           w_hostname        char(03),
           g_isbigchar       smallint
end globals

main

 define ws record
    pstcoddig        like dpaksocor.pstcoddig,
    hora             char (08),
    horaatu          datetime hour to second ,
    data             char(10),
    linha            char (700),
    tempod           dec  (3,0),
    sttsess          dec  (1,0),
    comando          char (1000),
    atdetpcod        like datmsrvacp.atdetpcod,
    servico          char (13),
    atdsrvorg        like datmservico.atdsrvorg,
    asitipcod        like datmservico.asitipcod,
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    espera           char (06)
 end record

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10)
 end record

 define ws2         record
   statusprc        dec  (1,0),
   sestblvardes1    char (256),
   sestblvardes2    char (256),
   sestblvardes3    char (256),
   sestblvardes4    char (256),
   sespcsprcnom     char (256),
   prgsgl           char (256),
   acsnivcod        dec  (1,0),
   webprscod        dec  (16,0)
 end record

 define d_wdatc015_a  record
   atdsrvnum           char (08),
   atdsrvano           char (02),   
   atdetpseq           like datmsrvint.atdetpseq,
   caddat              like datmsrvint.caddat,
   cadhor              like datmsrvint.cadhor,
   srvobs              like datmsrvint.srvobs,
   atdetpcod           like datmsrvintseqult.atdetpcod
 end record

 define d_wdatc015_b  record

 atdsrvnum             char (08),
 atdsrvano             char (02),
 caddat                like datmsrvintcmp.caddat,
 cadhor                like datmsrvintcmp.cadhor,
 srvcmptxt             like datmsrvintcmp.srvcmptxt
 end record

 define l_passou smallint
 define l_resultado smallint
 define l_atdetpdes like datketapa.atdetpdes



 initialize ws.*          to null
 initialize param.*       to null
 initialize ws2.*         to null  
 initialize d_wdatc015_b to null
 initialize d_wdatc015_a to null

 initialize g_ismqconn        to null
 initialize g_servicoanterior to null
 initialize g_meses           to null
 initialize w_hostname        to null
 initialize g_isbigchar       to null

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)

 let ws.horaatu    = time
 let ws.data       = today
 let l_passou = false

 #------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read

 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------

 call wdatc002(param.*)
      returning ws2.*

   if ws2.statusprc <> 0 then
      display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> permanência nesta p\341gina atingiu o limite m\341ximo.@@"
      exit program(0)
   end if            

 #----------------------------------------------
 #  Prepara comandos SQL
 #----------------------------------------------
if param.macsissgl = 'PSRONLINE' then

   let ws.comando = "select datmsrvintseqult.atdsrvano,",
                    "       datmsrvintseqult.atdsrvnum,",
                    "       datmsrvint.atdetpseq,",
                    "       datmsrvint.caddat,",
                    "       datmsrvint.cadhor,",
                    "       datmsrvint.srvobs, datmsrvint.atdetpcod ",
                    "  from datmsrvintseqult, datmsrvint ",
                    " where datmsrvintseqult.atdetpcod in (0) ",
                    "   and datmsrvint.pstcoddig = ? ",
                    "   and datmsrvint.cadhor >= current - 9 units minute ",
                    "  and datmsrvintseqult. atdsrvano = datmsrvint.atdsrvano ",
                    "  and datmsrvintseqult.atdsrvnum  = datmsrvint.atdsrvnum ",
                    "  and datmsrvintseqult.atdetpseq  = datmsrvint.atdetpseq " 
else

   let ws.comando = "select datmsrvintseqult.atdsrvano,",
                    "       datmsrvintseqult.atdsrvnum,",
                    "       datmsrvint.atdetpseq,",
                    "       datmsrvint.caddat,",
                    "       datmsrvint.cadhor,",
                    "       datmsrvint.srvobs, datmsrvint.atdetpcod ",
                    "  from datmsrvintseqult, datmsrvint ",
                    " where datmsrvintseqult.atdetpcod in (0,1) ",
                    "   and datmsrvint.pstcoddig = ? ",
                    "   and datmsrvint.caddat >= current - 1 units day ",
                    "   and datmsrvint.cadhor >= current - 60 units minute ",
                    "  and datmsrvintseqult. atdsrvano = datmsrvint.atdsrvano ",
                    "  and datmsrvintseqult.atdsrvnum  = datmsrvint.atdsrvnum ",
                    "  and datmsrvintseqult.atdetpseq  = datmsrvint.atdetpseq " 

end if
 
 prepare sel_servicos from ws.comando
 declare c_servicos cursor for sel_servicos

 let ws.comando = "select datmsrvintseqult.atdsrvano,",
                 "       datmsrvintseqult.atdsrvnum,",
                 "       datmsrvint.atdetpseq,",
                 "       datmsrvint.caddat,",
                 "       datmsrvint.cadhor,",
                 "       datmsrvint.srvobs",
                 "  from datmsrvintseqult, datmsrvint ",
                 " where datmsrvintseqult.atdetpcod in (3,4) ",
                 "   and datmsrvint.pstcoddig = ? ",
                 "   and atldat is NULL ",
                 "   and atlhor is NULL ",
                 "   and datmsrvintseqult. atdsrvano = datmsrvint.atdsrvano ",
                 "   and datmsrvintseqult.atdsrvnum  = datmsrvint.atdsrvnum ",
                 "   and datmsrvintseqult.atdetpseq  = datmsrvint.atdetpseq "

prepare sel_serv_canc from ws.comando
declare c_cancelados cursor for sel_serv_canc


 let ws.comando = "select  datmsrvintcmp.atdsrvnum, ",
                  "        datmsrvintcmp.atdsrvano, ",
                  "        datmsrvintcmp.caddat, ",
                  "        datmsrvintcmp.cadhor ",
                  "  from  datmsrvintcmp",
                  "  where datmsrvintcmp.cadorg = 0 and ",
                  "        datmsrvintcmp.atldat is NULL and ",
                  "        datmsrvintcmp. atlhor is NULL and ",
                  "        pstcoddig = ? "
#                 "        order by datmsrvintcmp.caddat , datmsrvintcmp.cadhor"

 prepare sel_complementos from ws.comando
 declare c_complementos cursor for sel_complementos

 let ws.pstcoddig = ws2.webprscod
                  
 #-----------------------------------------------
 #  Pesquisa servicos acionados
 #-----------------------------------------------
 
 
 display "PADRAO@@1@@B@@C@@0@@Última atualização  - ", ws.data, " - ", ws.horaatu,"@@"
 display "PADRAO@@1@@B@@C@@3@@@@"
 
 display "PADRAO@@1@@B@@C@@0@@Serviços pendentes@@"

 open c_servicos using ws.pstcoddig
 fetch c_servicos into d_wdatc015_a.atdsrvano
 if sqlca.sqlcode <> NOTFOUND THEN

 foreach c_servicos into d_wdatc015_a.atdsrvano,
                         d_wdatc015_a.atdsrvnum,
                         d_wdatc015_a.atdetpseq,
                         d_wdatc015_a.caddat,
                         d_wdatc015_a.cadhor,
                         d_wdatc015_a.srvobs,
                         d_wdatc015_a.atdetpcod
 

    let ws.servico =       F_FUNDIGIT_INTTOSTR(d_wdatc015_a.atdsrvnum,7),
                      "/", F_FUNDIGIT_INTTOSTR(d_wdatc015_a.atdsrvano,2)

    select atdsrvorg, asitipcod
             into ws.atdsrvorg, ws.asitipcod
             from datmservico
           where atdsrvano = d_wdatc015_a.atdsrvano
             and atdsrvnum = d_wdatc015_a.atdsrvnum   
 
       let ws.atdetpcod = null
       call cts10g04_ultima_etapa (d_wdatc015_a.atdsrvnum
                                  ,d_wdatc015_a.atdsrvano)
                    returning ws.atdetpcod

       if ws.asitipcod = 5 then  ## Taxi
          if ws.atdetpcod <> 4 then
             continue foreach
          end if
    
       else

       if ((ws.atdsrvorg = 2 or ws.atdsrvorg = 3) and 
           (ws.atdetpcod = 14 or ws.atdetpcod = 39 or ws.atdetpcod = 46 or
            ws.atdetpcod = 47 or ws.atdetpcod =  5 or ws.atdetpcod = 1 or
            ws.atdetpcod = 4)) or
          (d_wdatc015_a.atdetpcod = 1 and ws.atdetpcod = 4) then 
          continue foreach
       end if

       end if
                   
       call cts10g05_desc_etapa (3, ws.atdetpcod) 
                    returning l_resultado, l_atdetpdes
    

    if l_passou = false then
       if ws.atdsrvorg = 2 or ws.atdsrvorg = 3 then  
          display "PADRAO@@6@@5@@B@@C@@0@@2@@15%@@Serviço@@@@B@@C@@0@@2@@10%@@Tipo@@@@B@@C@@0@@2@@15%@@Situacao@@@@B@@C@@0@@2@@20%@@Data@@@@B@@C@@0@@2@@20%@@Hora@@@@B@@C@@0@@2@@20%@@Espera@@@@"
          display "SOM@@@@"
          let l_passou = true
       else
          display "PADRAO@@6@@5@@B@@C@@0@@2@@20%@@Serviço@@@@B@@C@@0@@2@@20%@@Tipo@@@@B@@C@@0@@2@@20%@@Data@@@@B@@C@@0@@2@@20%@@Hora@@@@B@@C@@0@@2@@20%@@Espera@@@@"
          display "SOM@@@@"
          let l_passou = true
       end if
    end if

    select srvtipabvdes
             into ws.srvtipabvdes
             from datksrvtip
           where atdsrvorg = ws.atdsrvorg
                   
    call wdatc015_espera(d_wdatc015_a.caddat,d_wdatc015_a.cadhor)
               returning ws.espera

       #if d_wdatc015_a.cadhor < current - 9 units minute then  
       #   continue foreach  
       #end if

       if ws.atdsrvorg = 2 or ws.atdsrvorg = 3 then

          display "PADRAO@@6@@5@@N@@C@@1@@1@@15%@@",ws.servico,
                  "@@wdatc016.pl?usrtip=",param.usrtip,"&webusrcod=",
                  param.webusrcod clipped,"&sesnum=",param.sesnum clipped,
                  "&macsissgl=",param.macsissgl clipped,"&atdsrvnum=",
                  d_wdatc015_a.atdsrvnum clipped,"&atdsrvano=",
                  d_wdatc015_a.atdsrvano clipped,"&acao=1",
                  "@@N@@C@@1@@1@@10%@@", ws.srvtipabvdes,
                  "@@@@N@@C@@1@@1@@15%@@",l_atdetpdes,
                  "@@@@N@@C@@1@@1@@20%@@",d_wdatc015_a.caddat,
                  "@@@@N@@C@@1@@1@@20%@@",d_wdatc015_a.cadhor,
                  "@@@@N@@C@@1@@1@@20%@@",ws.espera,"@@@@" 

       else
          display "PADRAO@@6@@5@@N@@C@@1@@1@@20%@@",ws.servico,
                  "@@wdatc016.pl?usrtip=",param.usrtip,"&webusrcod=",
                  param.webusrcod clipped,"&sesnum=",param.sesnum clipped,
                  "&macsissgl=",param.macsissgl clipped,"&atdsrvnum=",
                  d_wdatc015_a.atdsrvnum clipped,"&atdsrvano=",
                  d_wdatc015_a.atdsrvano clipped,"&acao=1",
                  "@@N@@C@@1@@1@@20%@@", ws.srvtipabvdes,
                  "@@@@N@@C@@1@@1@@20%@@",d_wdatc015_a.caddat,
                  "@@@@N@@C@@1@@1@@20%@@",d_wdatc015_a.cadhor,
                  "@@@@N@@C@@1@@1@@20%@@",ws.espera,"@@@@" 
       
       end if


 end foreach

 else

    display "PADRAO@@1@@N@@C@@1@@Nenhum serviço pendente@@"
 end if

#let ws.atdetpcod = 3
 
 display "PADRAO@@1@@B@@C@@3@@@@"
 display "PADRAO@@1@@B@@C@@0@@Serviços cancelados@@"

 open c_cancelados using ws.pstcoddig
 fetch c_cancelados into d_wdatc015_a.atdsrvano
 if sqlca.sqlcode <> NOTFOUND THEN

 display "PADRAO@@6@@5@@B@@C@@0@@2@@20%@@Serviço@@@@B@@C@@0@@2@@20%@@Tipo@@@@B@@C@@0@@2@@20%@@Data@@@@B@@C@@0@@2@@20%@@Hora@@@@B@@C@@0@@2@@20%@@Espera@@@@"

 display "SOM@@@@"

 foreach c_cancelados into d_wdatc015_a.atdsrvano,
                           d_wdatc015_a.atdsrvnum,
                           d_wdatc015_a.atdetpseq,
                           d_wdatc015_a.caddat,
                           d_wdatc015_a.cadhor,
                           d_wdatc015_a.srvobs


   let ws.servico =       F_FUNDIGIT_INTTOSTR(d_wdatc015_a.atdsrvnum,7),
                     "/", F_FUNDIGIT_INTTOSTR(d_wdatc015_a.atdsrvano,2)

   select atdsrvorg
            into ws.atdsrvorg
            from datmservico
          where atdsrvano = d_wdatc015_a.atdsrvano
            and atdsrvnum = d_wdatc015_a.atdsrvnum

   select srvtipabvdes
            into ws.srvtipabvdes
            from datksrvtip
          where atdsrvorg = ws.atdsrvorg

   call wdatc015_espera(d_wdatc015_a.caddat,d_wdatc015_a.cadhor)
               returning ws.espera

   display "PADRAO@@6@@5@@N@@C@@1@@1@@20%@@",ws.servico,"@@wdatc018.pl?usrtip=",param.usrtip,"&webusrcod=",param.webusrcod clipped,"&sesnum=",param.sesnum clipped,"&macsissgl=",param.macsissgl clipped,"&atdsrvnum=",d_wdatc015_a.atdsrvnum clipped,"&atdsrvano=",d_wdatc015_a.atdsrvano clipped,"&atdetpseq=",d_wdatc015_a.atdetpseq clipped,"@@N@@C@@1@@1@@20%@@",ws.srvtipabvdes,"@@@@N@@C@@1@@1@@20%@@",d_wdatc015_a.caddat,"@@@@N@@C@@1@@1@@20%@@",d_wdatc015_a.cadhor,"@@@@N@@C@@1@@1@@20%@@",ws.espera,"@@@@"

 end foreach

 else
 
    display "PADRAO@@1@@N@@C@@1@@Nenhum serviço cancelado@@"

 end if

 display "PADRAO@@1@@B@@C@@3@@@@"
 display "PADRAO@@1@@B@@C@@0@@Complementos de serviço@@"

 open c_complementos using ws.pstcoddig
 fetch c_complementos into d_wdatc015_b.atdsrvnum
 if sqlca.sqlcode <> NOTFOUND then 

     display "PADRAO@@6@@5@@B@@C@@0@@2@@20%@@Serviço@@@@B@@C@@0@@2@@20%@@Tipo@@@@B@@C@@0@@2@@20%@@Data@@@@B@@C@@0@@2@@20%@@Hora@@@@B@@C@@0@@2@@20%@@Espera@@@@"

    display "SOM@@@@"
 
    foreach c_complementos into d_wdatc015_b.atdsrvnum,
                                d_wdatc015_b.atdsrvano,
                                d_wdatc015_b.caddat,
                                d_wdatc015_b.cadhor

    let ws.servico =  F_FUNDIGIT_INTTOSTR(d_wdatc015_b.atdsrvnum,7),
                 "/", F_FUNDIGIT_INTTOSTR(d_wdatc015_b.atdsrvano,2)

   select atdsrvorg
            into ws.atdsrvorg
            from datmservico
          where atdsrvano = d_wdatc015_b.atdsrvano
            and atdsrvnum = d_wdatc015_b.atdsrvnum

   select srvtipabvdes
            into ws.srvtipabvdes
            from datksrvtip
          where atdsrvorg = ws.atdsrvorg

   call wdatc015_espera(d_wdatc015_b.caddat,d_wdatc015_b.cadhor)
               returning ws.espera

   display "PADRAO@@6@@5@@N@@C@@1@@1@@20%@@",ws.servico,
        "@@wdatc020.pl?usrtip=",param.usrtip,"&webusrcod=",
        param.webusrcod clipped,"&sesnum=",param.sesnum clipped,
        "&macsissgl=",param.macsissgl clipped,"&atdsrvnum=",
        d_wdatc015_b.atdsrvnum clipped,"&atdsrvano=",
        d_wdatc015_b.atdsrvano clipped,"&caddat=",
        d_wdatc015_b.caddat clipped,
        "&cadhor=",d_wdatc015_b.cadhor clipped,
        "&acao=1",
        "@@N@@C@@1@@1@@20%@@",
        ws.srvtipabvdes,"@@@@N@@C@@1@@1@@20%@@",d_wdatc015_b.caddat,
        "@@@@N@@C@@1@@1@@20%@@",d_wdatc015_b.cadhor,
        "@@@@N@@C@@1@@1@@20%@@",ws.espera,"@@@@"

 end foreach

 else
   display "PADRAO@@1@@N@@C@@1@@Nenhum complemento de serviço@@"
 end if  
   

 #------------------------------------
 # ATUALIZA TEMPO DE SESSAO DO USUARIO
 #------------------------------------

  call wdatc003(param.*,ws2.*)
       returning ws.sttsess
 #     display "PADRAO@@1@@B@@C@@0@@",ws.sttsess,"@@"  

end main

#--------------------------------------------------------------------------
 function wdatc015_espera(param)
#--------------------------------------------------------------------------

 define param       record
    data            date,
    hora            datetime hour to minute
 end record

 define hora        record
    atual           datetime hour to second,
    h24             datetime hour to second,
    espera          char (09)
 end record


 initialize hora.*  to null
 let hora.atual = time

 if param.data  =  today  then
    let hora.espera = hora.atual - param.hora
 else
    let hora.h24    = "23:59:59"
    let hora.espera = hora.h24 - param.hora
    let hora.h24    = "00:00:00"
    let hora.espera = hora.espera + (hora.atual - hora.h24) + "00:00:01"
 end if

 return hora.espera

 end function   ###

 function fonetica2()

 end function
 
 function conqua59()

 end function

