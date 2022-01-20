#############################################################################
# Nome do Modulo: wdatc025                                           Marcus #
#                                                                           #
# Tela de Aceitacao do Servico                                     Ago/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#17/02/2006   PSI.196878   JUNIOR (Meta) Assistencia passageiro e carro     #
#                                        extra                              #
#                                                                           #
#############################################################################
#-----------------------------------------------------------------------------#
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 23/08/2007 Saulo, Meta     AS146056   Substituicao de palavras reservadas   #
#                                       fun_dba movida para o inicio do modulo#
#-----------------------------------------------------------------------------#

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
    data             datetime year to day ,
    linha            char (700),
    tempod           dec  (3,0),
    sttsess          dec  (1,0),
    comando          char (500),
    padrao           char (2000),
    atdetpcod        dec  (1,0),
    servico          char (13),
    atdsrvorg        like datmservico.atdsrvorg,
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    atdhorpvt        like datmservico.atdhorpvt,
    espera           char (06),
    ciaempcod        like datmservico.ciaempcod
 end record

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10),
    atdsrvnum       like datmsrvint.atdsrvnum,
    atdsrvano       like datmsrvint.atdsrvano,
    acao            char (07)
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

 define d_wdatc025_a        record
   etpmtvcod                like datksrvintmtv.etpmtvcod,
   etpmtvdes                like datksrvintmtv.etpmtvdes
 end record

 define mr_retorno        record
   resultado              smallint
  ,mensagem               char(80)
  ,atdsrvorg              like datmservico.atdsrvorg
  ,asitipcod              like datmservico.asitipcod
  ,atdetpcod              like datmsrvacp.atdetpcod
 end record

 define m_valor_estimado  dec(10,2),
        l_atdhorpvt       char(5),
        l_texto           char(150),
        l_msg             char(150),
        l_valor           dec(10,2),
        l_asimtvcod       like datmassistpassag.asimtvcod

 #-------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #-------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read

 initialize ws.*          to null
 initialize param.*       to null
 initialize ws2.*         to null
 initialize d_wdatc025_a  to null
 initialize mr_retorno.*  to null

 initialize m_valor_estimado  to null
 initialize l_atdhorpvt       to null
 initialize l_texto           to null
 initialize l_msg             to null
 initialize l_valor           to null
 initialize l_asimtvcod       to null

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.atdsrvnum  = arg_val(5)
 let param.atdsrvano  = arg_val(6)
 let param.acao       = arg_val(7) clipped

 let ws.horaatu    = time
 let ws.data       = current


 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------

call wdatc002(param.usrtip,
              param.webusrcod,
              param.sesnum,
              param.macsissgl)
    returning ws2.*

##select atdhorpvt into ws.atdhorpvt
##   from datmservico
##  where atdsrvnum = param.atdsrvnum and
##        atdsrvano = param.atdsrvano

call cts10g06_dados_servicos (11, param.atdsrvnum, param.atdsrvano)
           returning  mr_retorno.resultado, mr_retorno.mensagem,
                      ws.atdhorpvt, mr_retorno.atdsrvorg, mr_retorno.asitipcod,
                      ws.ciaempcod

display 'DATA@@<input type="hidden" name="asitipcod" value=', mr_retorno.asitipcod , '>@@'

## Hospedagem/CarroExtra
if mr_retorno.atdsrvorg = 3 or mr_retorno.atdsrvorg = 8 then
   let l_texto = 'Informe no campo "estimativa" a previsão para conclusão da reserva. Caso seja necessário incluir uma observação, utilize o campo "observações".';
else

   ## Aviao
   if mr_retorno.atdsrvorg = 2 then
      let l_texto = 'Informe no campo "estimativa" a previsão para conclusão da cotação. Caso seja necessário incluir uma observação, utilize o campo "observações".';
   else

      ## Taxi, guincho, RE
      let l_texto = 'Informe no campo "estimativa" a previsão de chegada ao local de ocorrência. Caso seja necessário incluir uma observação, utilize o campo "observações".';
   end if

end if

display 'TEXTO@@', l_texto , '@@'

if param.acao = "Aceitar" then

    let l_atdhorpvt = ws.atdhorpvt
    let l_atdhorpvt = l_atdhorpvt[1,2], l_atdhorpvt[4,5]
    display 'DATA@@<input type="hidden" name="atdhorpvt" value=', l_atdhorpvt , '>@@'
    if mr_retorno.atdsrvorg <> 8 then
       display "PADRAO@@8@@Previsão@@",ws.atdhorpvt clipped,"@@"
    end if

    display "PADRAO@@5@@Estimativa@@0@@@@@@4@@5@@text@@atdprvdat@@@@return func_atdprvdat()@@"

    if mr_retorno.atdsrvorg = 2 and
       mr_retorno.asitipcod = 5 then
       call cts10g04_ultima_etapa (param.atdsrvnum, param.atdsrvano)
                  returning  mr_retorno.atdetpcod

       let l_valor = ''

       if ws.ciaempcod = 1 then

          let l_asimtvcod = null
          select asimtvcod into l_asimtvcod
             from datmassistpassag
            where atdsrvnum = param.atdsrvnum and
                  atdsrvano = param.atdsrvano

          if l_asimtvcod = 3 then
             let l_msg = "'LIMITE DE COBERTURA RESTRITO AO VALOR DE UMA ",
                         "PASSAGEM AÉREA NA CLASSE ECONÔMICA'"
          else
             call cts45g00_limites_cob(1,param.atdsrvnum, param.atdsrvano,
                                         "","","", 5 , "",l_asimtvcod, 1,0)
                   returning l_valor

             if l_valor > 0 then
                let l_msg = "'LIMITE DE COBERTURA RESTRITO AO VALOR MAXIMO DE R$ ",
                            l_valor, "'"
             else
                let l_msg = "0"
             end if
          end if

          display 'PADRAO2@@<table cellpadding="0" width="550" cellspacing="1" ',
                  'border="0"> <tr> <td width="29%" align="left" height="23" ',
                  'bgcolor="#A8CDEC"><font size="1" face="ARIAL,HELVETICA,',
                  'VERDANA">Valor do Taxi</font> </td> <td width="71%" ',
                  'align="left" height="23" bgcolor="#D7E7F1"> <input type="text"',
                  'name="txivlr"  size="8" maxlength="10" type="text" ',
                  'onBlur="return func_txivlr(', l_msg clipped, ')"> </td> '

       else
          display "PADRAO@@5@@Valor do Taxi@@0@@@@@@8@@10@@text@@txivlr@@@@return func_txivlr(0)@@"
       end if
    end if

    display "PADRAO@@5@@Observações@@0@@@@@@50@@80@@text@@srvobs@@@@"
else
   if param.acao = "Recusar" then
      let ws.padrao = "PADRAO@@2@@etpmtvcod@@Motivo@@0@@@@"

      declare c_motivos cursor for
              select etpmtvcod,
                     etpmtvdes
              from datksrvintmtv
               where etpmtvstt = "A" and
                     atdetpcod = 2

      foreach c_motivos into d_wdatc025_a.etpmtvcod,
                             d_wdatc025_a.etpmtvdes

              let ws.padrao = ws.padrao clipped, d_wdatc025_a.etpmtvdes clipped, "@@0@@", d_wdatc025_a.etpmtvcod, "@@" clipped

      end foreach
      display ws.padrao
      display "PADRAO@@5@@Observações@@0@@@@@@50@@80@@text@@srvobs@@@@"
  end if

end if

if ws2.statusprc <> 0 then
    display "NOSESS@@Por questões de segurança seu tempo de<BR> permanência nesta página atingiu o limite máximo.@@"
     exit program(0)
end if

  #PSI 208264 - display para informar qual logo deve ser utilizado
  display "PADRAO@@12@@", ws.ciaempcod, "@@"
  #PSI 208264

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

 function fonetica2()

 end function
 
 function conqua59()

 end function
