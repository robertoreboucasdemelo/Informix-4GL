#############################################################################
# Nome do Modulo: wdatc029                                           Marcus #
#                                                                           #
# Grava as informacoes quando o Prestador recusa o servico         Ago/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        AUTOR FABRICA   OSF      ALTERACAO                            #
#---------------------------------------------------------------------------#
# 05/05/2003  LUCIANO         18716    Atualizar tabela datmservico         #
# 08/05/2003  LUCIANO         18716    Inclusao de controle de transacao    #
# ......................................................................... #
#                                                                           #
#                           * * * Alteracoes * * *                          #
#                                                                           #
# Data       Autor Fabrica   Origem     Alteracao                           #
# ---------- --------------  ---------- ----------------------------------- #
# 29/04/2005 Adriano, Meta   PSI189790  obter e atualizar os                #
#                                       servicos multiplos                  #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

globals
    define g_ismqconn        smallint,
           g_servicoanterior smallint,
           g_meses           integer,
           w_hostname        char(03),
           g_isbigchar       smallint
end globals

main

 define ws record
    sttsess          dec  (1,0),
    atdetpseq        like datmsrvint.atdetpseq,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    retorno          smallint,
    disp             char (500),
    comando          char (500)
 end record

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10),
    atdsrvnum       like datmsrvint.atdsrvnum,
    atdsrvano       like datmsrvint.atdsrvano,
    etpmtvcod       like datmsrvint.etpmtvcod,
    srvobs          like datmsrvint.srvobs
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

 define al_cts29g00 array[10] of record
    atdmltsrvnum    like datratdmltsrv.atdmltsrvnum
   ,atdmltsrvano    like datratdmltsrv.atdmltsrvano
   ,socntzdes       like datksocntz.socntzdes
   ,espdes          like dbskesp.espdes
   ,atddfttxt       like datmservico.atddfttxt
 end record
 
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

 define l_resultado  smallint
 define l_mensagem   char(100)
 define l_cont       smallint
 define l_sql        char(400)
 define l_atdetpdes like datketapa.atdetpdes
 define l_webprscod like issrusrprs.webprscod

 define l_flg_aciona char(01),
        l_acnsttflg  like datmservico.acnsttflg
  define l_atdetpcod like datmsrvint.atdetpcod


 initialize g_ismqconn        to null
 initialize g_servicoanterior to null
 initialize g_meses           to null
 initialize w_hostname        to null
 initialize g_isbigchar       to null

 initialize ws.*          to null
 initialize param.*       to null
 initialize ws2.*         to null
 initialize mr_retorno.*  to null
 initialize al_cts29g00   to null

 initialize l_resultado  to null
 initialize l_mensagem   to null
 initialize l_cont       to null
 initialize l_sql        to null
 initialize l_atdetpdes to null
 initialize l_webprscod to null
 initialize l_flg_aciona to null
 initialize l_acnsttflg  to null
 initialize l_atdetpcod to null
 
 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.atdsrvnum  = arg_val(5)
 let param.atdsrvano  = arg_val(6)
 let param.etpmtvcod  = arg_val(7)
 let param.srvobs     = arg_val(8)

 #------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read


 let l_sql = 'update datmservico '
              ,' set atdprscod = "" '
                 ,' ,atdvclsgl = "" '
                 ,' ,socvclcod = "" '
                 ,' ,srrcoddig = "" '
                 ,' ,c24nomctt = "" '
                 ,' ,c24opemat = "" '
                 ,' ,atdfnlhor = "" '
                 ,' ,cnldat = "" '
                 ,' ,atdcstvlr = "" '
                 ,' ,atdprvdat = null  '
                 ,' ,atdfnlflg = ? ' # A-> VOLTA PARA ACIONAMENTO AUTOMATICO
                                     # N-> VOLTA P/TELA DO RADIO
             ,' where atdsrvnum = ? '
               ,' and atdsrvano = ? '
 prepare pwdatc029001 from l_sql

 let l_sql = " select acnsttflg ",
               " from datmservico ",
              " where atdsrvnum = ? ",
                " and atdsrvano = ? "

  prepare pwdatc029002 from l_sql
  declare cwdatc029002 cursor for pwdatc029002
  
  let l_sql = "select atdetpdes    ",                
              "  from datksrvintetp ",               
              " where atdetpcod = ?"                 
 prepare pwdatc029003 from l_sql               
 declare cwdatc029003 cursor for pwdatc029003
 
 
 let l_sql = " select webprscod                   ",
             "  from issrusrprs                   ",         
             "   where issrusrprs.usrtip    = ?   ",
             "    and issrusrprs.webusrcod = ?    ",
             "    and  issrusrprs.sissgl  = ?     "
           
  prepare pwdatc029004 from l_sql
  declare cwdatc029004 cursor for pwdatc029004

 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------

  call wdatc002(param.usrtip,
                param.webusrcod,
                param.sesnum,
                param.macsissgl)
      returning ws2.*

  if ws2.statusprc <> 0 then
    display "NOSESS@@Por quesascii(92)5es de seguraascii(92)7a seu tempo de<BR> permanência nesta ascii(92)1gina atingiu o limite ascii(92)1ximo.@@"
     exit program(0)
  end if
  
  #inicio chamado 
  
  ##verifica prestador do Usuario Web corrente 
  
  call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
       returning mr_retorno.atdetpcod
       
  
  whenever error continue
   open  cwdatc029004 using param.usrtip,
                            param.webusrcod,              
                            param.macsissgl
                            
        fetch cwdatc029004 into l_webprscod
   close  cwdatc029004
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
   
   #fim chamado
  

 #whenever error continue
  select max(atdetpseq)
         into ws.atdetpseq
         from datmsrvint
       where atdsrvnum = param.atdsrvnum and
             atdsrvano = param.atdsrvano
 #whenever error stop

  if sqlca.sqlcode <> 0 then
     display "ERRO@@Problema atualizando servascii(92)7o.!@@"
     exit program(0)
  end if

  if ws.atdetpseq is null then
     let ws.atdetpseq = 0
  end if
  
  select atdetpcod                     
    into l_atdetpcod                   
    from datmsrvint                    
  where atdsrvnum = param.atdsrvnum and
        atdsrvano = param.atdsrvano and
        atdetpseq = ws.atdetpseq       
  
  
  let ws.atdetpseq= ws.atdetpseq + 1
  
  begin work
  
 #whenever error continue
  if l_atdetpcod <> 0 then # Adriano
     open  cwdatc029003 using l_atdetpcod                  
        fetch cwdatc029003 into  l_atdetpdes 
        close cwdatc029003         
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
                           "2",
                           "1",
                           ws2.webprscod,
                           param.usrtip,
                           "0",
                           param.webusrcod,
                           current,
                           current,
                           param.etpmtvcod,
                           param.srvobs )
 #whenever error stop
  if sqlca.sqlcode = 0 then
 #   whenever error continue
     update datmsrvintseqult
          set atdetpcod = 2,
              atdetpseq = ws.atdetpseq
        where atdsrvano = param.atdsrvano and
              atdsrvnum = param.atdsrvnum
 #   whenever error stop
     if sqlca.sqlcode <> 0 then
        display "ERRO@@Problema atualizando servascii(92)7o !!@@"
        exit program(0)
     end if
     let g_issk.empcod = 1
     let g_issk.funmat = 999998
     ---------------[ atualiza etapa de recusado para o radio ]---------
     call cts10g04_insere_etapa(param.atdsrvnum,
                                param.atdsrvano,
                                38,"","","","")
             returning ws.retorno
     if ws.retorno  <> 0 then
        display "ERRO@@Problema atualizando servascii(92)7o !!!@@"
        exit program(0)
     end if
     ----------------[ atualiza etapa de liberado para o radio ]-----------
     call cts10g04_insere_etapa(param.atdsrvnum,
                                param.atdsrvano,
                                1,"","","","")
             returning ws.retorno
     if ws.retorno  <> 0 then
        display "ERRO@@Problema atualizando servascii(92)7o !!!!@@"
        exit program(0)
     end if
     --------------------[ atualiza servico ]------------
 #   whenever error continue
  #   update datmservico
  #      set atdprscod = ""          ,
  #          atdvclsgl = ""          ,
  #          socvclcod = ""          ,
  #          srrcoddig = ""          ,
  #          c24nomctt = ""          ,
  #          c24opemat = ""          ,
  #          atdfnlhor = ""          ,
  #          cnldat    = ""          ,
  #          atdcstvlr = ""          ,
  #          atdprvdat = null        ,
  #          atdfnlflg = "N"
  #    where atdsrvnum = param.atdsrvnum
  #      and atdsrvano = param.atdsrvano

 #   whenever error stop

      # --VERIFICA E O SERVICO VEIO DO ACIONAMENTO AUTOMATICO
      open cwdatc029002 using param.atdsrvnum,
                              param.atdsrvano

      fetch cwdatc029002 into l_acnsttflg
      close cwdatc029002

      if l_acnsttflg is null or
         l_acnsttflg = " " then
         let l_flg_aciona = "N" # ENVIA PARA TELA DO RADIO
      else
         if l_acnsttflg = "S" then
            let l_flg_aciona = "A" # ENVIA NOVAMENTE PARA ACIONA. AUTOMATICO
         else
            let l_flg_aciona = "N" # ENVIA PARA TELA DO RADIO
         end if
      end if

      whenever error continue
      execute pwdatc029001 using l_flg_aciona,
                                 param.atdsrvnum,
                                 param.atdsrvano
      whenever error stop

      if sqlca.sqlcode <> 0 then
         display "ERRO@@Problema atualizando servi 347o !!!!!@@"
         exit program(0)
     else
        call cts29g00_obter_multiplo(1,param.atdsrvnum,param.atdsrvano)
        returning l_resultado
                 ,l_mensagem
                 ,al_cts29g00[1].*
                 ,al_cts29g00[2].*
                 ,al_cts29g00[3].*
                 ,al_cts29g00[4].*
                 ,al_cts29g00[5].*
                 ,al_cts29g00[6].*
                 ,al_cts29g00[7].*
                 ,al_cts29g00[8].*
                 ,al_cts29g00[9].*
                 ,al_cts29g00[10].*

        for l_cont = 1 to 10
           if al_cts29g00[l_cont].atdmltsrvnum is not null then
              let ws.retorno = cts10g04_insere_etapa(al_cts29g00[l_cont].atdmltsrvnum, al_cts29g00[l_cont].atdmltsrvano,
                                         38,"","","","")
              if ws.retorno <> 0 then
                 display "ERRO@@Problema atualizando servi 347o !!!@@"
                 exit program(0)
              end if
              ----------------[ atualiza etapa de liberado para o radio ]-----------
              let ws.retorno = cts10g04_insere_etapa(al_cts29g00[l_cont].atdmltsrvnum, al_cts29g00[l_cont].atdmltsrvano,
                                          1,"","","","")
              if ws.retorno <> 0 then
                 display "ERRO@@Problema atualizando servi 347o !!!!@@"
                 exit program(0)
              end if
              --------------------[ atualiza servico ]------------

              # --VERIFICA E O SERVICO VEIO DO ACIONAMENTO AUTOMATICO
              open cwdatc029002 using al_cts29g00[l_cont].atdmltsrvnum,
                                      al_cts29g00[l_cont].atdmltsrvano
              fetch cwdatc029002 into l_acnsttflg
              close cwdatc029002

              if l_acnsttflg is null or
                 l_acnsttflg = " " then
                 let l_flg_aciona = "N" # ENVIA PARA TELA DO RADIO
              else
                 if l_acnsttflg = "S" then
                    let l_flg_aciona = "A" # ENVIA NOVAMENTE PARA ACIONA. AUTOMATICO
                 else
                    let l_flg_aciona = "N" # ENVIA PARA TELA DO RADIO
                 end if
              end if

              whenever error continue
                 execute pwdatc029001 using l_flg_aciona,
                                            al_cts29g00[l_cont].atdmltsrvnum,
                                            al_cts29g00[l_cont].atdmltsrvano
              whenever error stop

              if sqlca.sqlcode <> 0 then
                 display "ERRO@@Problema atualizando servi 347o !!!!!@@"
                 exit program(0)
              end if

           end if
        end for
        commit work
        display "PADRAO@@1@@B@@C@@3@@Serviço recusado. Caso seja necessário, por favor entrar em contato através do telefone (11) 3366 3055@@"
     end if
  else
     display "ERRO@@Problema atualizando servascii(92)7o..!@@"
     exit program(0)
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


 function fonetica2()

 end function
 
 function conqua59()

 end function
