#############################################################################
# Nome do Modulo: wdatc019                                           Marcus #
#                                                                           #
# Mostra o motivo do cancelamento e atualiza o Status da etapa     Ago/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#############################################################################

#-----------------------------------------------------------------------------#
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 20/07/2005 Coutelle, Meta  PSI189790  Obter laudos multiplos e concatenar   #
#                                       no servico para exibicao.             #
#-----------------------------------------------------------------------------#

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
    comando          char (500),
    atdetpseq        like datmsrvintseqult.atdetpseq,
    atdetpdes        like datksrvintetp.atdetpdes,
    etpmtvdes        like datksrvintmtv.etpmtvdes,
    servico          char (45),
    atdsrvorg        like datmservico.atdsrvorg,
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    espera           char (06)
 end record

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10),
    atdsrvnum       like datmsrvint.atdsrvnum,
    atdsrvano       like datmsrvint.atdsrvano,
    atdetpseq       like datmsrvint.atdetpseq
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

 define d_wdatc019_a   record

 atdsrvnum             like datmsrvint.atdsrvnum,
 atdsrvano             like datmsrvint.atdsrvano,
 atdetpcod             like datmsrvint.atdetpcod,
 caddat                like datmsrvint.caddat,
 cadhor                like datmsrvint.cadhor,
 etpmtvcod             like datmsrvint.etpmtvcod,
 srvobs                like datmsrvint.srvobs
 
 end record
 
 define al_ret_obter_multiplo array[10] of record
        atdmltsrvnum   like datratdmltsrv.atdmltsrvnum 
       ,atdmltsrvano   like datratdmltsrv.atdmltsrvano
       ,socntzdes      like datksocntz.socntzdes
       ,espdes         like dbskesp.espdes
       ,atddfttxt      like datmservico.atddfttxt  
 end record   

 define l_resultado    smallint
       ,l_mensagem     char(100)
       ,l_i            smallint 

 initialize ws.*          to null
 initialize param.*       to null
 initialize ws2.*         to null  
 initialize d_wdatc019_a  to null
 initialize al_ret_obter_multiplo to null

 initialize l_resultado to null
 initialize l_mensagem to null
 initialize l_i to null

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.atdsrvnum  = arg_val(5)
 let param.atdsrvano  = arg_val(6)
 let param.atdetpseq  = arg_val(7)

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
 #  Seleciona servico 
 #----------------------------------------------

 select atdetpseq     
   into ws.atdetpseq 
   from datmsrvintseqult
  where atdsrvano = param.atdsrvano and
        atdsrvnum = param.atdsrvnum

 select atdsrvnum,
        atdsrvano,
        atdetpcod,        
        caddat,
        cadhor,
        etpmtvcod,
        srvobs
  into  d_wdatc019_a.atdsrvnum,
        d_wdatc019_a.atdsrvano,
        d_wdatc019_a.atdetpcod,
        d_wdatc019_a.caddat,
        d_wdatc019_a.cadhor,
        d_wdatc019_a.etpmtvcod,
        d_wdatc019_a.srvobs
  from  datmsrvint
  where atdsrvnum = param.atdsrvnum and
        atdsrvano = param.atdsrvano and
        atdetpseq = ws.atdetpseq

 if sqlca.sqlcode <> 0 then

 else
   let ws.servico = param.atdsrvnum, "/", param.atdsrvano 
   
   call cts29g00_obter_multiplo(1
                               ,param.atdsrvnum
                               ,param.atdsrvano)
      returning l_resultado
               ,l_mensagem 
               ,al_ret_obter_multiplo[01].* 
               ,al_ret_obter_multiplo[02].* 
               ,al_ret_obter_multiplo[03].*   
               ,al_ret_obter_multiplo[04].*    
               ,al_ret_obter_multiplo[05].* 
               ,al_ret_obter_multiplo[06].* 
               ,al_ret_obter_multiplo[07].*   
               ,al_ret_obter_multiplo[08].*    
               ,al_ret_obter_multiplo[09].* 
               ,al_ret_obter_multiplo[10].* 
               
   for l_i = 1 to 10 
      if al_ret_obter_multiplo[l_i].atdmltsrvnum is not null then
         let ws.servico = ws.servico clipped, ' '
                         ,al_ret_obter_multiplo[l_i].atdmltsrvnum using '&&&&&&&' ,'/'
                         ,al_ret_obter_multiplo[l_i].atdmltsrvano using '&&'
      end if
   end for

   select atdetpdes into ws.atdetpdes
     from datksrvintetp
    where atdetpcod    = d_wdatc019_a.atdetpcod

   select etpmtvdes 
     into ws.etpmtvdes
     from datksrvintmtv
    where atdetpcod = d_wdatc019_a.atdetpcod and
          etpmtvcod = d_wdatc019_a.etpmtvcod

   display "PADRAO@@1@@B@@C@@0@@Informação sobre serviço cancelado@@"
   display "PADRAO@@8@@Serviço@@",ws.servico clipped,"@@"
   display "PADRAO@@8@@Data@@",d_wdatc019_a.caddat,"@@"
   display "PADRAO@@8@@Hora@@",d_wdatc019_a.cadhor,"@@"
   display "PADRAO@@8@@Status@@",ws.atdetpdes,"@@"
   display "PADRAO@@8@@Motivo@@",ws.etpmtvdes,"@@"
   display "PADRAO@@8@@Observação@@",d_wdatc019_a.srvobs,"@@"
 end if

 update datmsrvint
    set atlemp      = 0,
        atlmat      = param.webusrcod,
        atlusrtip   = param.usrtip,
        atldat      = current ,
        atlhor      = current
    where atdsrvnum = param.atdsrvnum and
          atdsrvano = param.atdsrvano and
          atdetpseq = param.atdetpseq

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

