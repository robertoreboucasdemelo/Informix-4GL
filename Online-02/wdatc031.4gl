#############################################################################
# Nome do Modulo: wdatc031                                           Marcus #
#                                                                           #
#                                                                  Set/2001 #
# Tela de consulta de servicos recebidos pela Internet                      #
#############################################################################
# Alteracoes:                                                Rodrigo Santos #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 23/05/2003  OSF 19690    R. Santos    Fornecer novas informações ao       #
#                                       prestador.                          #
#############################################################################

database porto

main

 define ws record
    pstcoddig        like dpaksocor.pstcoddig,
    time             char (08),
    horaatu          datetime hour to second ,
    data             datetime year to day ,
    linha            char (700),
    tempod           dec  (3,0),
    sttsess          dec  (1,0),
    comando          char (1000),
    atdetpseq        like datmsrvint.atdetpseq,
    atdetpcod        dec  (1,0),
    atdetpdes        like datksrvintetp.atdetpdes,
    etpmtvdes        like datksrvintmtv.etpmtvdes,
    servico          char (13),
    atdsrvorg        like datmservico.atdsrvorg,
    orgcmpdes        char(10),
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    espera           char (06),
    qtd_param        dec (1,0),
    selecionado      dec(1,0)
 end record

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10),
    data_ini        like datmsrvint.caddat,
    data_fim        like datmsrvint.caddat,
    atdsrvorg       like datmservico.atdsrvorg,
    atdetpcod       like datmsrvint.atdetpcod
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

 define d_wdatc031_a   record
   atdsrvnum           char (08),
   atdsrvano           char (02),   
   atdetpseq           like datmsrvint.atdetpseq,
   atdetpcod           like datmsrvint.atdetpcod,
   caddat              like datmsrvint.caddat,
   cadhor              like datmsrvint.cadhor,
   etpmtvcod           like datmsrvint.etpmtvcod
 end record

 define d_wdatc031_b   record

 atdsrvnum             char (08),
 atdsrvano             char (02),
 caddat                like datmsrvintcmp.caddat,
 cadhor                like datmsrvintcmp.cadhor,
 srvcmptxt             like datmsrvintcmp.srvcmptxt,
 cadorg                like datmsrvintcmp.cadorg    
 
 end record

 define padrao         char(2000)

 initialize ws.*          to null
 initialize param.*       to null
 initialize ws2.*         to null  
 initialize d_wdatc031_b  to null
 initialize d_wdatc031_a  to null
 initialize padrao        to null

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.data_ini   = arg_val(5)
 let param.data_fim   = arg_val(6)
 let param.atdsrvorg  = arg_val(7)
 let param.atdetpcod  = arg_val(8)

 let ws.horaatu    = time
 let ws.data       = current

 #------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read

 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------

 call wdatc002(param.usrtip,
               param.webusrcod,
               param.sesnum,
               param.macsissgl)
     returning ws2.*

   if ws2.statusprc <> 0 then
      display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> permanência nesta p\341gina atingiu o limite m\341ximo.@@"
      exit program(0)
   end if            

 #----------------------------------------------
 #  Prepara comandos SQL
 #----------------------------------------------

 let ws.qtd_param = 0

 let ws.comando = "select  distinct datmsrvint.atdsrvnum, ",
                  "        datmsrvint.atdsrvano  ",
                  "   from datmsrvint, datmsrvintseqult, datmservico ",
                  "   where pstcoddig = ? and "

 if param.atdetpcod is not null then
    let ws.comando = ws.comando clipped , 
                   " datmsrvintseqult.atdetpcod = ", param.atdetpcod 
    let ws.qtd_param = ws.qtd_param + 1
 end if

 if param.atdsrvorg is not null then
    if ws.qtd_param > 0 then
       let ws.comando = ws.comando clipped, " and "
    end if    
    let ws.comando = ws.comando clipped, 
                   " atdsrvorg = " , param.atdsrvorg
    let ws.qtd_param = ws.qtd_param + 1
 end if

 if (param.data_ini is not null and param.data_fim is not null) then
    if ws.qtd_param > 0 then
       let ws.comando = ws.comando clipped, " and "
    end if
    let ws.comando = ws.comando clipped,
                   " caddat between '",  param.data_ini , "' and '", param.data_fim, "'" 
    let ws.qtd_param = ws.qtd_param + 1
 else
    if ws.qtd_param = 0 then
      let param.data_ini = ws.data - 1 units day
      let param.data_fim = ws.data
    else
      let param.data_ini = ws.data - 15 units day
      let param.data_fim = ws.data                    
      let ws.comando = ws.comando clipped, " and "
    end if
    let ws.comando = ws.comando clipped,
                   " caddat between '", param.data_ini , "' and '", param.data_fim, "'"
 end if   

 let ws.comando = ws.comando clipped,
                "  and datmsrvint.atdsrvnum = datmsrvintseqult.atdsrvnum ",
                "  and datmsrvint.atdsrvano = datmsrvintseqult.atdsrvano ",
                "  and datmsrvint.atdsrvnum = datmservico.atdsrvnum ",
                "  and datmsrvint.atdsrvano = datmservico.atdsrvano ",
                "  and datmsrvint.atdetpcod = datmsrvintseqult.atdetpcod ",
                "  and datmsrvintseqult.atdetpcod <> 1 " # OSF 19690

#TESTE ZYON display "PADRAO@@1@@B@@C@@0@@", ws.comando, "@@"
                                                            
 prepare sel_servicos from ws.comando
 declare c_servicos cursor for sel_servicos

 let ws.comando = "select  atdsrvnum, ",
                  "        atdsrvano, ",
                  "        caddat, ",
                  "        cadhor, ",
                  "        cadorg ",
                  "  from  datmsrvintcmp ",
                  "  where cadorg in(0,1) and ",
                  "        pstcoddig = ?  and ",   # OSF
                  "        caddat between ? and ?", # 19690
                  "        order by 3,4"

 prepare sel_complementos from ws.comando
 declare c_complementos cursor for sel_complementos

#display "PADRAO@@1@@B@@C@@1@@Entrei no 31!@@"
#exit program(0)

 let ws.pstcoddig = ws2.webprscod
#TESTE ZYON display "PADRAO@@1@@B@@C@@0@@PSTCODING=", ws.pstcoddig, "@@"
                  
 #----------------------------------------------
 #  Pesquisa servicos acionados
 #----------------------------------------------

 display "PADRAO@@5@@De@@0@@@@(dd/mm/aaaa)@@10@@10@@text@@de@@",param.data_ini,"@@@@"
 display "PADRAO@@5@@Até@@0@@@@(dd/mm/aaaa)@@10@@10@@text@@ate@@",param.data_fim,"@@@@"

 declare c_datksrvtip cursor for
         select atdsrvorg, srvtipabvdes 
           from datksrvtip

 let padrao = "PADRAO@@2@@atdsrvorg@@Origem do Serviço@@0@@0@@" clipped
 
 let ws.selecionado = 0
 if param.atdsrvorg is null then
    let ws.selecionado = 1
 end if
 let padrao = padrao clipped,"@@", ws.selecionado, "@@@@" clipped
 
 if param.atdsrvorg is null then
    foreach c_datksrvtip into ws.atdsrvorg, ws.srvtipabvdes
      let padrao = padrao clipped, ws.srvtipabvdes clipped ,"@@0@@", ws.atdsrvorg clipped , "@@" clipped
    end foreach
 else
   foreach c_datksrvtip into ws.atdsrvorg, ws.srvtipabvdes
     let ws.selecionado = 0
     if ws.atdsrvorg = param.atdsrvorg then
        let ws.selecionado = 1
     end if
     let padrao = padrao clipped, ws.srvtipabvdes clipped ,"@@",  ws.selecionado, "@@", ws.atdsrvorg clipped , "@@" clipped
    end foreach          
 end if

 display padrao
  
 declare c_datksrvintetp cursor for
         select atdetpdes, atdetpcod
           from datksrvintetp
          where atdetpcod <> 1 ## OSF 19690

 let padrao = ""
 let padrao = "PADRAO@@2@@atdetpcod@@Situação@@0@@0@@" clipped

 let ws.selecionado = 0
 if param.atdetpcod is null then
    let ws.selecionado = 1
 end if
 
 let padrao = padrao clipped,"@@", ws.selecionado, "@@@@" clipped

 if param.atdetpcod is null then 
    foreach c_datksrvintetp into ws.atdetpdes, ws.atdetpcod
      let padrao = padrao clipped, ws.atdetpdes clipped ,"@@0@@", ws.atdetpcod clipped , "@@" clipped 
    end foreach  
 else
   foreach c_datksrvintetp into ws.atdetpdes, ws.atdetpcod
      let ws.selecionado = 0
      if ws.atdetpcod = param.atdetpcod then
         let ws.selecionado = 1
      end if
      let padrao = padrao clipped, ws.atdetpdes clipped ,"@@", ws.selecionado, "@@", ws.atdetpcod clipped , "@@" clipped
    end foreach
 end if   

 display padrao clipped
 display "PADRAO@@1@@B@@C@@3@@@@"

 display "PADRAO@@1@@B@@C@@0@@Serviços recebidos@@"
 
 open c_servicos using ws.pstcoddig

 fetch c_servicos into d_wdatc031_a.atdsrvano
 if sqlca.sqlcode <> NOTFOUND THEN

     display "PADRAO@@6@@6@@B@@C@@0@@2@@15%@@Serviço@@@@B@@C@@0@@2@@15%@@Tipo@@@@B@@C@@0@@2@@15%@@Data@@@@B@@C@@0@@2@@10%@@Hora@@@@B@@C@@0@@2@@15%@@Situação@@@@B@@C@@0@@2@@30%@@Motivo@@@@"

 foreach c_servicos into d_wdatc031_a.atdsrvnum,
                         d_wdatc031_a.atdsrvano
 
    select max(atdetpseq)
      into ws.atdetpseq 
      from datmsrvint
     where atdsrvnum = d_wdatc031_a.atdsrvnum and
           atdsrvano = d_wdatc031_a.atdsrvano and
           pstcoddig = ws.pstcoddig

    select atdetpcod,
           caddat,
           cadhor,
           etpmtvcod
      into d_wdatc031_a.atdetpcod,
           d_wdatc031_a.caddat,
           d_wdatc031_a.cadhor,
           d_wdatc031_a.etpmtvcod
      from datmsrvint
     where atdsrvnum = d_wdatc031_a.atdsrvnum and
           atdsrvano = d_wdatc031_a.atdsrvano and
           atdetpseq = ws.atdetpseq

    let ws.servico =       F_FUNDIGIT_INTTOSTR(d_wdatc031_a.atdsrvnum,7),
                      "/", F_FUNDIGIT_INTTOSTR(d_wdatc031_a.atdsrvano,2)

    select atdsrvorg     
             into ws.atdsrvorg
             from datmservico
           where atdsrvano = d_wdatc031_a.atdsrvano
             and atdsrvnum = d_wdatc031_a.atdsrvnum   
 
    select srvtipabvdes
             into ws.srvtipabvdes
             from datksrvtip
           where atdsrvorg = ws.atdsrvorg
                   
    select atdetpdes into ws.atdetpdes
      from datksrvintetp
     where atdetpcod = d_wdatc031_a.atdetpcod

    if d_wdatc031_a.atdetpcod <> 0 then
       select etpmtvdes into ws.etpmtvdes
         from datksrvintmtv
        where etpmtvcod = d_wdatc031_a.etpmtvcod
    else 
       let ws.etpmtvdes = " - "
    end if

   display "PADRAO@@6@@6@@N@@C@@1@@1@@15%@@",ws.servico,
           "@@wdatc016.pl?usrtip=",param.usrtip,"&webusrcod=",
           param.webusrcod clipped,"&sesnum=",param.sesnum clipped,
           "&macsissgl=",param.macsissgl clipped,"&atdsrvnum=",
           d_wdatc031_a.atdsrvnum clipped,"&atdsrvano=",
           d_wdatc031_a.atdsrvano clipped,"&acao=0@@N@@C@@1@@1@@15%@@",
           ws.srvtipabvdes,"@@@@N@@C@@1@@1@@15%@@",d_wdatc031_a.caddat,
           "@@@@N@@C@@1@@1@@10%@@",d_wdatc031_a.cadhor,
           "@@@@N@@C@@1@@1@@15%@@",ws.atdetpdes,
           "@@@@N@@C@@1@@1@@30%@@",ws.etpmtvdes,"@@@@"

   let ws.etpmtvdes = NULL

 end foreach

 else

    display "PADRAO@@1@@B@@C@@1@@Nenhum serviço recebido@@"
 end if

 display "PADRAO@@1@@B@@C@@3@@@@"
 display "PADRAO@@1@@B@@C@@0@@Complementos de serviço@@"

 open c_complementos using ws.pstcoddig, param.data_ini, param.data_fim
 fetch c_complementos into d_wdatc031_b.atdsrvnum
 if sqlca.sqlcode <> NOTFOUND then 

     display "PADRAO@@6@@5@@B@@C@@0@@2@@20%@@Serviço@@@@B@@C@@0@@2@@20%@@Tipo@@@@B@@C@@0@@2@@20%@@Data@@@@B@@C@@0@@2@@20%@@Hora@@@@B@@C@@0@@2@@20%@@Origem@@@@"

    foreach c_complementos into d_wdatc031_b.atdsrvnum,
                                d_wdatc031_b.atdsrvano,
                                d_wdatc031_b.caddat,
                                d_wdatc031_b.cadhor,
                                d_wdatc031_b.cadorg

    let ws.servico =  F_FUNDIGIT_INTTOSTR(d_wdatc031_b.atdsrvnum,7),
                 "/", F_FUNDIGIT_INTTOSTR(d_wdatc031_b.atdsrvano,2)

   select atdsrvorg
            into ws.atdsrvorg
            from datmservico
          where atdsrvano = d_wdatc031_b.atdsrvano
            and atdsrvnum = d_wdatc031_b.atdsrvnum

   select srvtipabvdes
            into ws.srvtipabvdes
            from datksrvtip
          where atdsrvorg = ws.atdsrvorg

   if d_wdatc031_b.cadorg = 0 then
      let ws.orgcmpdes = "PORTO"
   else
      let ws.orgcmpdes = "PRESTADOR"
   end if

   display "PADRAO@@6@@5@@N@@C@@1@@1@@20%@@",ws.servico,
        "@@wdatc020.pl?usrtip=",param.usrtip,"&webusrcod=",
        param.webusrcod clipped,"&sesnum=",param.sesnum clipped,
        "&macsissgl=",param.macsissgl clipped,"&atdsrvnum=",
        d_wdatc031_b.atdsrvnum clipped,"&atdsrvano=",
        d_wdatc031_b.atdsrvano clipped,"&caddat=",
        d_wdatc031_b.caddat clipped,
        "&cadhor=",d_wdatc031_b.cadhor clipped,
        "@@N@@C@@1@@1@@20%@@",
        ws.srvtipabvdes,"@@@@N@@C@@1@@1@@20%@@",d_wdatc031_b.caddat,
        "@@@@N@@C@@1@@1@@20%@@",d_wdatc031_b.cadhor,
        "@@@@N@@C@@1@@1@@20%@@",ws.orgcmpdes clipped,"@@@@"

 end foreach

 else
   display "PADRAO@@1@@B@@C@@1@@Nenhum complemento recebido@@"
 end if  
   

 #------------------------------------
 # ATUALIZA TEMPO DE SESSAO DO USUARIO
 #------------------------------------

  call wdatc003(param.usrtip,
                param.webusrcod,
                param.sesnum,
                param.macsissgl,
                ws2.*)
      returning ws.sttsess
#     display "PADRAO@@1@@B@@C@@0@@",ws.sttsess,"@@"

end main
