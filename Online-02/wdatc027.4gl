#############################################################################
# Nome do Modulo: wdatc027                                           Marcus #
#                                                                           #
# Grava as informacoes quando o Prestador aceita o servico         Ago/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#############################################################################
#---------------------------------------------------------------------------#
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 11/04/2005 Pietro - Meta     PSI189790  Rotina para obter e atualizar os  #
#                                         Servicos Multiplos                #
#                                                                           #
# 17/02/2006 JUNIOR (Meta)     PSI.196878 Assistencia passageiro e carro    #
#                                         extra                             #
#                                                                           #
#                                                                           #
# 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca             #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

main

 define ws record
    pstcoddig        like dpaksocor.pstcoddig,
    time             char (08),
    horaatu          datetime hour to second ,
    data             datetime year to day ,
    linha            char (700),
    tempod           dec  (3,0),
    sttsess          dec  (1,0),
    comando          char (500),
    atdetpcod        dec  (1,0),
    servico          char (13),
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    atdetpseq        like datmsrvint.atdetpseq,
    espera           char (06),
    atdhorpvt        like datmservico.atdhorpvt
 end record

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10),
    atdsrvnum       like datmsrvint.atdsrvnum,
    atdsrvano       like datmsrvint.atdsrvano,
    atdprvdat       like datmservico.atdprvdat,
    srvobs          like datmsrvint.srvobs,
    valor_taxi_estimado  like datmassistpassag.txivlr,
    hsphotnom       like datmhosped.hsphotnom,
    hsphotend       like datmhosped.hsphotend,
    hsphotbrr       like datmhosped.hsphotbrr,
    hsphotuf        like datmhosped.hsphotuf,
    hsphotcid       like datmhosped.hsphotcid,
    hsphottelnum    like datmhosped.hsphottelnum,
    hsphotcttnom    like datmhosped.hsphotcttnom,
    hsphotdiavlr    like datmhosped.hsphotdiavlr,
    hsphotacmtip    like datmhosped.hsphotacmtip,
    obsdes          like datmhosped.obsdes,
    hpdqrtqtd       like datmhosped.hpdqrtqtd,
    hsphotrefpnt    like datmhosped.hsphotrefpnt,
    acao            char(20),
    aerciacod       like datmtrppsgaer.aerciacod,
    trpaervoonum    like datmtrppsgaer.trpaervoonum,
    trpaerptanum    like datmtrppsgaer.trpaerptanum,
    trpaerlzdnum    like datmtrppsgaer.trpaerlzdnum,
    adlpsgvlr       like datmtrppsgaer.adlpsgvlr,
    crnpsgvlr       like datmtrppsgaer.crnpsgvlr,
    totpsgvlr       like datmtrppsgaer.totpsgvlr,
    arpembcod       like datmtrppsgaer.arpembcod,
    trpaersaidat    like datmtrppsgaer.trpaersaidat,
    trpaersaihor    like datmtrppsgaer.trpaersaihor,
    arpchecod       like datmtrppsgaer.arpchecod,
    trpaerchedat    like datmtrppsgaer.trpaerchedat,
    trpaerchehor    like datmtrppsgaer.trpaerchehor,
    vooopc          like datmtrppsgaer.vooopc,
    voocnxseq       like datmtrppsgaer.voocnxseq
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

 define al_saida array[10] of record
    atdmltsrvnum like datratdmltsrv.atdmltsrvnum
   ,atdmltsrvano like datratdmltsrv.atdmltsrvano
   ,socntzdes    like datksocntz.socntzdes
   ,espdes       like dbskesp.espdes
   ,atddfttxt    like datmservico.atddfttxt
 end record

 define l_resultado smallint
 define l_mensagem  char(30)
 define l_i         smallint
 define l_sql       char(400)
 define l_atdprvdat char(5)
 define l_txivlr    char(10)
 define l_ciaempcod like datmservico.ciaempcod
 define l_atdetpcod like datmsrvint.atdetpcod
 define l_atdetpdes like datketapa.atdetpdes
 define l_webprscod like issrusrprs.webprscod
 define l_enviamsg  smallint 


 define mr_retorno        record
  resultado              smallint
 ,mensagem               char(80)
 ,atdsrvorg              like datmservico.atdsrvorg
 ,asitipcod              like datmservico.asitipcod
 ,atdetpcod              like datmsrvacp.atdetpcod
 ,pstcoddig              like datmsrvacp.pstcoddig
 ,srrcoddig              like datmsrvacp.srrcoddig
 ,socvclcod              like datmsrvacp.socvclcod
 ,atdsrvseq              like datmsrvacp.atdsrvseq
 end record
 
 define lr_cts29g00 record                                
    atdsrvnum    like datratdmltsrv.atdsrvnum,           
    atdsrvano    like datratdmltsrv.atdsrvano,           
    resultado    smallint,                               
    mensagem     char(100)                               
 end record  
 
 define lr_ctb85g02 record
          codigo  smallint, # 0 -> OK, 1 -> Nao enviado sms, 2 -> Erro de banco
          mensagem  char(100)
 end record                                             


 initialize al_saida      to null
 initialize ws.*          to null
 initialize param.*       to null
 initialize ws2.*         to null
 initialize lr_cts29g00.* to null
 initialize lr_ctb85g02.* to null
 initialize mr_retorno.* to null

 initialize l_resultado to null
 initialize l_mensagem  to null
 initialize l_atdprvdat to null
 initialize l_webprscod to null
 initialize l_i         to null
 initialize l_sql       to null
 initialize l_txivlr    to null
 initialize l_ciaempcod to null
 initialize l_atdetpcod to null
 initialize l_atdetpdes to null
 initialize l_enviamsg  to null

 let l_i         = 1
 let l_txivlr = "0"

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.atdsrvnum  = arg_val(5)
 let param.atdsrvano  = arg_val(6)
 let param.acao       = arg_val(7)
 let l_atdprvdat  = arg_val(8)
 let param.atdprvdat  = l_atdprvdat
 let param.srvobs     = upshift(arg_val(9))
 let l_txivlr         = arg_val(10)
 let param.valor_taxi_estimado  = l_txivlr
 let l_enviamsg       = true 

 #------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read


 let l_sql = ' update datmservico '
               ,' set atdprvdat = ? '
             ,' where atdsrvano = ? '
               ,' and atdsrvnum = ? '
 prepare pwdatc027001 from l_sql

 let l_sql = ' update datmassistpassag '
               ,' set txivlr = ? '
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
 prepare pwdatc027002 from l_sql

 let l_sql = ' update datmhosped '
               ,' set hsphotnom    = ? '
               ,'    ,hsphotend    = ? '
               ,'    ,hsphotbrr    = ? '
               ,'    ,hsphotuf     = ? '
               ,'    ,hsphotcid    = ? '
               ,'    ,hsphottelnum = ? '
               ,'    ,hsphotcttnom = ? '
               ,'    ,hsphotdiavlr = ? '
               ,'    ,hsphotacmtip = ? '
               ,'    ,obsdes       = ? '
               ,'    ,hsphotrefpnt = ? '
               ,'    ,hpdqrtqtd = ? '
             ,' where atdsrvnum    = ? '
               ,' and atdsrvano    = ? '
 prepare pwdatc027003 from l_sql

 let l_sql = ' update datmhosped '
               ,' set hsphotdiavlr    = ? '
             ,' where atdsrvnum    = ? '
               ,' and atdsrvano    = ? '
 prepare pwdatc027004 from l_sql

 let l_sql = "select atdetpdes    ",
              "  from datksrvintetp ",
              " where atdetpcod = ?"
 prepare pwdatc027005 from l_sql
 declare cwdatc027005 cursor for pwdatc027005
 
 
 let l_sql = " select webprscod                   ",
             "  from issrusrprs                   ",         
             "   where issrusrprs.usrtip    = ?   ",
             "    and issrusrprs.webusrcod = ?    ",
             "    and  issrusrprs.sissgl  = ?     "
           
  prepare pwdatc027006 from l_sql
  declare cwdatc027006 cursor for pwdatc027006

 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------

call wdatc002(param.usrtip,
              param.webusrcod,
              param.sesnum,
              param.macsissgl)
    returning ws2.*

  call cts10g06_dados_servicos (6, param.atdsrvnum, param.atdsrvano)
       returning mr_retorno.resultado, mr_retorno.mensagem,
                 ws.atdhorpvt , mr_retorno.atdsrvorg,
                 mr_retorno.asitipcod

{
  if mr_retorno.asitipcod = 5 and param.valor_taxi_estimado > 1000 then #Taxi
     display "PADRAO@@1@@B@@C@@3@@Valor informado superior a cobertura da apólice, entre em contato através do telefone (11) 3366 3055@@"
     call wdatc003(param.usrtip,
                   param.webusrcod,
                   param.sesnum,
                   param.macsissgl,
                   ws2.*)
          returning ws.sttsess
     exit program
  end if
} #ligia em 26/04

  if mr_retorno.atdsrvorg = 3 then ## Hospedagem
     let param.hsphotnom     = upshift(arg_val(11))
     let param.hsphotuf      = upshift(arg_val(12))
     let param.hsphotcid     = upshift(arg_val(13))
     let param.hsphotbrr     = upshift(arg_val(14))
     let param.hsphotend     = upshift(arg_val(15))
     let param.hsphotrefpnt  = upshift(arg_val(16))
     let param.hsphotcttnom  = upshift(arg_val(17))
     let param.hsphottelnum  = upshift(arg_val(18))
     let param.hsphotdiavlr  = arg_val(19)
     let param.hsphotacmtip  = upshift(arg_val(20))
     let param.obsdes        = upshift(arg_val(21))
     let param.hpdqrtqtd     = upshift(arg_val(22))
  end if

  if mr_retorno.atdsrvorg = 2 then   ## Assist.Passageiro
     if mr_retorno.asitipcod = 10 then ## Aviao

        let param.aerciacod     = arg_val(11)
        let param.trpaervoonum  = arg_val(12)
        let param.trpaerptanum  = arg_val(13)
        let param.trpaerlzdnum  = arg_val(14)
        let param.adlpsgvlr     = arg_val(15)
        let param.crnpsgvlr     = arg_val(16)
        let param.totpsgvlr     = arg_val(17)
        let param.arpembcod     = arg_val(18)
        let param.trpaersaidat  = arg_val(19)
        let param.trpaersaihor  = arg_val(20)
        let param.arpchecod     = arg_val(21)
        let param.trpaerchedat  = arg_val(22)
        let param.trpaerchehor  = arg_val(23)
        let param.vooopc        = arg_val(24)
        let param.voocnxseq     = arg_val(25)

        if param.vooopc is null then
           let param.vooopc = 1
        end if

        if param.voocnxseq is null then
           let param.voocnxseq = 1
        end if

     end if
  end if

  call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
       returning mr_retorno.atdetpcod
       
  ##verifica prestador do Usuario Web corrente
  whenever error continue
   open  cwdatc027006 using param.usrtip,
                            param.webusrcod,              
                            param.macsissgl
                            
        fetch cwdatc027006 into l_webprscod
   close  cwdatc027006
   whenever error stop
   
   ##verifica ultimo prestador acionado serviço 
   call cts10g04_max_seq(param.atdsrvnum, param.atdsrvano,mr_retorno.atdetpcod)
       returning mr_retorno.resultado, mr_retorno.mensagem, mr_retorno.atdsrvseq
       
   if mr_retorno.resultado = 1 then
   
   call cts10g04_ultimo_pst(param.atdsrvnum, param.atdsrvano,mr_retorno.atdsrvseq)
       returning mr_retorno.resultado, mr_retorno.mensagem,mr_retorno.atdetpcod 
                 ,mr_retorno.pstcoddig,mr_retorno.srrcoddig, mr_retorno.socvclcod
                 
   end if
   
   if mr_retorno.resultado = 1 then
   	if mr_retorno.pstcoddig <> l_webprscod then   	  
            display "ERRO@@Serviço já está em atendimento com outro prestador!@@"
            exit program(0)
   	end if
   end if
   
   
   #PSI 208264 - Busca o codigo da CIA e da o               
   #display para informar qual logo deve ser utilizado     
   select ciaempcod into l_ciaempcod                       
     from datmservico                                      
    where atdsrvnum = param.atdsrvnum                      
      and atdsrvano = param.atdsrvano                      
   if  sqlca.sqlcode <> 0 then                             
       let l_ciaempcod = 999                               
   end if                                                  
   display "PADRAO@@12@@", l_ciaempcod, "@@"               
   #PSI 208264                                             
	
   
   
   ## Liberado/Enviado/Em cotacao
   if mr_retorno.atdetpcod = 1 or mr_retorno.atdetpcod = 43 or
      mr_retorno.atdetpcod = 4 or mr_retorno.atdetpcod = 3 or
      mr_retorno.atdetpcod =  10 or mr_retorno.atdetpcod = 7 then
   
     select max(atdetpseq)
            into ws.atdetpseq
            from datmsrvint
          where atdsrvnum = param.atdsrvnum and
                atdsrvano = param.atdsrvano

     select atdetpcod
       into l_atdetpcod
       from datmsrvint
     where atdsrvnum = param.atdsrvnum and
           atdsrvano = param.atdsrvano and
           atdetpseq = ws.atdetpseq



     let ws.atdetpseq = ws.atdetpseq + 1

     if l_atdetpcod <> 0 then # Adriano
        open  cwdatc027005 using l_atdetpcod
        fetch cwdatc027005 into  l_atdetpdes
        close cwdatc027005
        display "ERRO@@Serviço já está ", l_atdetpdes," !@@"
        exit program(0)
     end if
     insert into datmsrvint ( atdsrvano,
                              atdsrvnum,
                              atdetpseq,
                              atdetpcod,
                              cadorg,
                              pstcoddig,
                              cadusrtip,
                              cademp,
                              cadmat,
                              caddat,
                              cadhor,
                              etpmtvcod,
                              srvobs )
                      values( param.atdsrvano,
                              param.atdsrvnum,
                              ws.atdetpseq,
                              "1",
                              "1",
                              ws2.webprscod,
                              param.usrtip,
                              "0",
                              param.webusrcod,
                              current,
                              current,
                              0,
                              param.srvobs )

     if sqlca.sqlcode = 0 then

        update datmsrvintseqult
            set atdetpcod = 1 ,
                atdetpseq = ws.atdetpseq
          where atdsrvano = param.atdsrvano and
                atdsrvnum = param.atdsrvnum

        update datmservico
           set atdprvdat = param.atdprvdat
         where atdsrvano = param.atdsrvano and
               atdsrvnum = param.atdsrvnum

        call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)

        if mr_retorno.atdsrvorg = 9 then
           ## Obter servicos multiplos
           call cts29g00_obter_multiplo(1, param.atdsrvnum, param.atdsrvano)
              returning l_resultado
                       ,l_mensagem
                       ,al_saida[1].*
                       ,al_saida[2].*
                       ,al_saida[3].*
                       ,al_saida[4].*
                       ,al_saida[5].*
                       ,al_saida[6].*
                       ,al_saida[7].*
                       ,al_saida[8].*
                       ,al_saida[9].*
                       ,al_saida[10].*

           ## Atualizar os servicos multiplos
           for l_i = 1 to 10
              if al_saida[l_i].atdmltsrvnum is not null then
                 whenever error continue
                    execute pwdatc027001 using param.atdprvdat
                                           ,al_saida[l_i].atdmltsrvano
                                           ,al_saida[l_i].atdmltsrvnum
                 whenever error stop
           
                 if sqlca.sqlcode <> 0 then
                    exit for
                 else
                   call cts00g07_apos_grvlaudo(al_saida[l_i].atdmltsrvnum,al_saida[l_i].atdmltsrvano)
                 end if
              end if
           end for

           if sqlca.sqlcode = 0 then
             if mr_retorno.atdsrvorg <> 2 and mr_retorno.atdsrvorg <> 3 then
                display "PADRAO@@1@@B@@C@@3@@Serviço aceito. Caso seja necessario, por favor entrar em contato através do telefone (11) 3366 3055@@"
                
                #envia SMS para cliente RE                
                   if mr_retorno.atdsrvorg = 9 or mr_retorno.atdsrvorg = 13 then
                      
                      call cts29g00_consistir_multiplo(param.atdsrvnum,             
                                            param.atdsrvano)             
                       returning lr_cts29g00.resultado,                          
                                 lr_cts29g00.mensagem,            
                                 lr_cts29g00.atdsrvnum,                          
                                 lr_cts29g00.atdsrvano                        
                                 
                      if lr_cts29g00.resultado <> 1 then #só envia msg para o serviço original
                          call ctb85g02_envia_msg(2,
                                              param.atdsrvnum,             
                                              param.atdsrvano)                                   
                             returning lr_ctb85g02.codigo,
                                       lr_ctb85g02.mensagem                             
                      end if            
                   end if 
             end if
           else
              display "ERRO@@Problema atualizando serviço !@@"
           end if
        end if

     else
        display "ERRO@@Problema atualizando serviço !@@"
     end if

   end if
  
  if ws2.statusprc <> 0 then
     display "NOSESS@@Por questões de segurança seu tempo de<BR> permanência nesta página atingiu o limite máximo.@@"
     exit program(0)
  end if

  if mr_retorno.atdsrvorg = 2 then   ## Assistencia Passageiro
     if mr_retorno.atdetpcod = 4 then   ## Acionado
        if mr_retorno.asitipcod = 5 then    ##Taxi

           whenever error continue
           execute pwdatc027002 using param.valor_taxi_estimado
                                     ,param.atdsrvnum
                                     ,param.atdsrvano
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode < 0 then
                 display "ERRO@@Erro no UPDATE pwdatc027002. ",sqlca.sqlcode
                        ,"/",sqlca.sqlerrd[2]
                 exit program(1)
              end if
           end if
           let mr_retorno.atdetpcod = 0  ##

        end if

     end if

     if mr_retorno.asitipcod = 10 then ##Aviao
        call ctc11g00_aviao
             (param.atdsrvnum, param.atdsrvano, param.acao,
              param.aerciacod, param.trpaervoonum, param.trpaerptanum,
              param.trpaerlzdnum, param.adlpsgvlr, param.crnpsgvlr,
              param.totpsgvlr, param.arpembcod, param.trpaersaidat,
              param.trpaersaihor, param.arpchecod, param.trpaerchedat,
              param.trpaerchehor, mr_retorno.atdetpcod,
              param.vooopc, param.voocnxseq)
             returning mr_retorno.atdetpcod
     else
        if mr_retorno.asitipcod <> 5 then    ##Outros
           let mr_retorno.atdetpcod = 4  ## Acionado
        end if
     end if

     if mr_retorno.atdetpcod = 4  then
        update datmservico
           set atdfnlflg = "S"
         where atdsrvano = param.atdsrvano and
               atdsrvnum = param.atdsrvnum

       call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)

     end if

  end if

  if mr_retorno.atdsrvorg = 3 then   ## Hospedagem
     if mr_retorno.atdetpcod = 43 then
        let mr_retorno.atdetpcod = 13
     else
        if  mr_retorno.atdetpcod = 13 then
            whenever error continue

            if param.hsphotnom  is not null then

               execute pwdatc027003 using param.hsphotnom
                                         ,param.hsphotend
                                         ,param.hsphotbrr
                                         ,param.hsphotuf
                                         ,param.hsphotcid
                                         ,param.hsphottelnum
                                         ,param.hsphotcttnom
                                         ,param.hsphotdiavlr
                                         ,param.hsphotacmtip
                                         ,param.obsdes
                                         ,param.hsphotrefpnt
                                         ,param.hpdqrtqtd
                                         ,param.atdsrvnum
                                         ,param.atdsrvano
            else
               if param.hsphotdiavlr is not null then
                   execute pwdatc027004 using param.hsphotdiavlr
                                             ,param.atdsrvnum
                                             ,param.atdsrvano
               end if
            end if

            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode < 0 then
                  display "ERRO@@Erro no UPDATE pwdatc027003. ",sqlca.sqlcode
                         ,"/",sqlca.sqlerrd[2]
                  exit program(1)
               end if
            end if
            let mr_retorno.atdetpcod = 47
        else
            if mr_retorno.atdetpcod = 44 then
               let mr_retorno.atdetpcod = 46
            end if
            if mr_retorno.atdetpcod = 45 then
               let mr_retorno.atdetpcod = 47
            end if
        end if
     end if
  end if

  if mr_retorno.atdsrvorg = 8 then   ## Carro Extra
     let mr_retorno.atdetpcod = 4
     update datmservico
        set atdfnlflg = "S"
      where atdsrvano = param.atdsrvano and
            atdsrvnum = param.atdsrvnum

     call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)
  end if

  if mr_retorno.atdsrvorg = 2 or mr_retorno.atdsrvorg = 3 or
     mr_retorno.atdsrvorg = 8 then

     if mr_retorno.atdetpcod <> 0 then

        let g_issk.empcod = 1
        let g_issk.funmat = 999998 ## Prestador Internet

        call cts10g04_insere_etapa (param.atdsrvnum, param.atdsrvano,
                                    mr_retorno.atdetpcod, ws2.webprscod,"", "", "")
             returning mr_retorno.resultado
     end if
  end if
  
  ##PSI 208264 - Busca o codigo da CIA e da o                   
  # #display para informar qual logo deve ser utilizado          
  # select ciaempcod into l_ciaempcod                            
  #   from datmservico                                           
  #  where atdsrvnum = param.atdsrvnum                           
  #    and atdsrvano = param.atdsrvano                           
  # if  sqlca.sqlcode <> 0 then                                  
  #     let l_ciaempcod = 999                                    
  # end if                                                       
  # display "PADRAO@@12@@", l_ciaempcod, "@@"                    
  # #PSI 208264                                                  

  
  if mr_retorno.atdetpcod = 0 or mr_retorno.atdetpcod = 4 or
     mr_retorno.atdetpcod = 13 or mr_retorno.atdetpcod = 39 then
  
     display "PADRAO@@1@@B@@C@@3@@Serviço aceito. Caso seja necessário, por favor entrar em contato através do telefone (11) 3366 3055@@"    
     #envia SMS para cliente AUTO     
        call ctb85g02_envia_msg(3,
                          param.atdsrvnum,             
                          param.atdsrvano)                                   
         returning lr_ctb85g02.codigo,
                   lr_ctb85g02.mensagem 
                   
         
  end if

  if mr_retorno.atdetpcod = 14 then
     display "PADRAO@@1@@B@@C@@3@@Serviço cotado. Caso seja necessario, por favor entrar em contato através do telefone (11) 3366 3055@@"
  end if

  if mr_retorno.atdetpcod = 46 then
     display "PADRAO@@1@@B@@C@@3@@Emissão efetuada. Caso seja necessário, por favor entrar em contato através do telefone (11) 3366 3055@@"
  end if

  if mr_retorno.atdetpcod = 47 then
     display "PADRAO@@1@@B@@C@@3@@Reserva efetuada. Caso seja necessário, por favor entrar em contato através do telefone (11) 3366 3055@@"
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

end main
