#############################################################################
# Nome do Modulo: wdatc007                                           Marcus #
#                                                                      Raji #
# Posicionamento de frota - Informacoes Viatura                    Jan/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
# 05/12/2002  PSI 150550   Zyon         Implementa‡Æo versÆo de impressÆo   #
# 19/12/2002  PSI 150550   Zyon         Passa a mostrar os endere‡os do     #
#                                       laudo para QTH e QTI e Ordem Serv.  #
# 29/05/2003  PSI 173436   R. Santos    Informar dados do veículo.          #
# 23/02/2010               Burini       Inicialização de variáveis          #
#                                                                           #
# 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca             #
#---------------------------------------------------------------------------#
database porto

main
   define param       record
      usrtip          char (1),
      webusrcod       char (06),
      sesnum          dec  (10,0),
      macsissgl       char (10),
      atdvclsgl       like datkveiculo.atdvclsgl,
      acao            char (01)
   end record

   define ws1         record
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

   define wdatc007     record
      atdvclsgl        like datkveiculo.atdvclsgl,
      c24atvcod        like dattfrotalocal.c24atvcod,
      socvclcod        like dattfrotalocal.socvclcod,
      vcldes           char (50),
      vcleqpdes        char (15),
      srrcoddig        like dattfrotalocal.srrcoddig,
      srrabvnom        like datksrr.srrabvnom,
      srrasides        char (50),
      tipposcab        char (08),
      ufdcod_gps       like datmfrtpos.ufdcod,
      cidnom_gps       like datmfrtpos.cidnom,
      brrnom_gps       like datmfrtpos.brrnom,
      endzon_gps       like datmfrtpos.endzon,
      ufdcod_qth       like datmfrtpos.ufdcod,
      cidnom_qth       like datmfrtpos.cidnom,
      brrnom_qth       like datmfrtpos.brrnom,
      endzon_qth       like datmfrtpos.endzon,
      ufdcod_qti       like datmfrtpos.ufdcod,
      cidnom_qti       like datmfrtpos.cidnom,
      brrnom_qti       like datmfrtpos.brrnom,
      endzon_qti       like datmfrtpos.endzon,
      obspostxt        like dattfrotalocal.obspostxt,
      celular          char (13),
      hora             datetime hour to minute,
      tempo            char (06),
      atdsrvorg        like datmservico.atdsrvorg,
      atdsrvnum        like dattfrotalocal.atdsrvnum,
      atdsrvano        like dattfrotalocal.atdsrvano,
      pstcoddig        like datkveiculo.pstcoddig,
      atdprvdat        like datmservico.atdprvdat,
      vclanomdl        like datmservico.vclanomdl, # OSF19690
      vcllicnum        like datmservico.vcllicnum, #
      cpodes           like iddkdominio.cpodes,    #
      vclcorcod        like datmservico.vclcorcod, #     
      ciaempcod        like datmservico.ciaempcod
   end record

   define wdatc007b    record
      lclltt_gps       like datmfrtpos.lclltt,
      lcllgt_gps       like datmfrtpos.lcllgt,
      lclltt_qth       like datmfrtpos.lclltt,
      lcllgt_qth       like datmfrtpos.lcllgt,
      lclltt_qti       like datmfrtpos.lclltt,
      lcllgt_qti       like datmfrtpos.lcllgt
   end record

   define ws           record
      null             char (01),
      data             char (10),
      socvclcod        like datkveiculo.socvclcod,
      atdvclsgl        like datkveiculo.atdvclsgl,
      celdddcod        like datksrr.celdddcod,
      celtelnum        like datksrr.celtelnum,
      srrstt           like datksrr.srrstt,
      srrcoddig        like dattfrotalocal.srrcoddig,
      c24atvcod        like dattfrotalocal.c24atvcod,
      atdvclpriflg     like dattfrotalocal.atdvclpriflg,
      obspostxt        like dattfrotalocal.obspostxt,
      ufdcod           like datmfrtpos.ufdcod,
      cidnom           like datmfrtpos.cidnom,
      brrnom           like datmfrtpos.brrnom,
      endzon           like datmfrtpos.endzon,
      lclltt           like datmfrtpos.lclltt,
      lcllgt           like datmfrtpos.lcllgt,
      atdsrvorg        like datmservico.atdsrvorg,
      ufdcod_gps       like datmfrtpos.ufdcod,
      cidnom_gps       like datmfrtpos.cidnom,
      brrnom_gps       like datmfrtpos.brrnom,
      endzon_gps       like datmfrtpos.endzon,
      ufdcod_qth       like datmfrtpos.ufdcod,
      cidnom_qth       like datmfrtpos.cidnom,
      brrnom_qth       like datmfrtpos.brrnom,
      endzon_qth       like datmfrtpos.endzon,
      ufdcod_qti       like datmfrtpos.ufdcod,
      cidnom_qti       like datmfrtpos.cidnom,
      brrnom_qti       like datmfrtpos.brrnom,
      endzon_qti       like datmfrtpos.endzon,
      socvcllcltip     like datmfrtpos.socvcllcltip,
      soceqpabv        like datkvcleqp.soceqpabv,
      asitipabvdes     like datkasitip.asitipabvdes,
      vclcoddig        like agbkveic.vclcoddig,
      vclmrcnom        like agbkmarca.vclmrcnom,
      vcltipnom        like agbktip.vcltipnom,
      vclmdlnom        like agbkveic.vclmdlnom,
      pstcoddig        like datrsrrpst.pstcoddig,
      comando          char (700),
      opcao            dec  (1,0),
      operacao         char (01),
      tempod           dec  (3,0),
      asitipcod        like datkasitip.asitipcod,
      socacsflg        like datkveiculo.socacsflg,
      flag_cts00m02    dec(01,0),
      horaatu          datetime hour to minute,
      f8flg            char(01),
      sttsess          dec (1,0),
      sqlcode          integer
   end record

#---> Zyon 19/12/2002
    define a_rrw          array[2] of record
        lclidttxt         like datmlcl.lclidttxt,
        lgdtxt            char (80),
        lgdtip            like datmlcl.lgdtip,
        lgdnom            like datmlcl.lgdnom,
        lgdnum            like datmlcl.lgdnum,
        brrnom            like datmlcl.brrnom,
        lclbrrnom         like datmlcl.lclbrrnom,
        endzon            like datmlcl.endzon,
        cidnom            like datmlcl.cidnom,
        ufdcod            like datmlcl.ufdcod,
        lgdcep            like datmlcl.lgdcep,
        lgdcepcmp         like datmlcl.lgdcepcmp,
        dddcod            like datmlcl.dddcod,
        lcltelnum         like datmlcl.lcltelnum,
        lclcttnom         like datmlcl.lclcttnom,
        lclrefptotxt      like datmlcl.lclrefptotxt,
        c24lclpdrcod      like datmlcl.c24lclpdrcod,
        endcmp            like datmlcl.endcmp 
    end record
    
    define  m_lgdnum_aux     char(06)    
          

           
    initialize  a_rrw  to null
#<-- Zyon 19/12/2002

   initialize ws.*,
              ws1.*,
              param.*,
              wdatc007.*,
              wdatc007b.* to null

   initialize m_lgdnum_aux to null

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------
   call fun_dba_abre_banco("CT24HS")
   set isolation to dirty read

   let param.usrtip    = arg_val(1)
   let param.webusrcod = arg_val(2)
   let param.sesnum    = arg_val(3)
   let param.macsissgl = arg_val(4)
   let param.atdvclsgl = arg_val(5)
   let param.acao      = arg_val(6)  
  
   
   #---------------------------------------------
   #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
   #---------------------------------------------
   call wdatc002(param.usrtip, 
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl)
        returning ws1.*

   if ws1.statusprc <> 0 then
      display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> perman\352ncia nesta p\341gina atingiu o limite m\341ximo.@@" 
      exit program(0)
   end if
 
    #------------------------------------------------------------------
    # Testa se a viatura pertence ao Prestador.
    #------------------------------------------------------------------
    select 1
      from datkveiculo
     where pstcoddig = ws1.webprscod
       and atdvclsgl = param.atdvclsgl
    
    if sqlca.sqlcode <> 0 then
        display "NOSESS@@Esta viatura n&atilde;o pertence a este prestador.@@" 
        exit program(0)
    end if
      
   #------------------------------------------------------------------
   # Prepara comandos SQL
   #------------------------------------------------------------------
{
   let ws.comando = " select vclmrcnom,",
                    "        vcltipnom,",
                    "        vclmdlnom ",
                    "   from agbkveic, outer agbkmarca, outer agbktip ",
                    "  where agbkveic.vclcoddig  = ? ",
                    "    and agbkmarca.vclmrccod = agbkveic.vclmrccod ",
                    "    and agbktip.vclmrccod   = agbkveic.vclmrccod ",
                    "    and agbktip.vcltipcod   = agbkveic.vcltipcod "
   prepare sel_aux1 from ws.comando
   declare c_veiculo cursor for sel_aux1
}

   let ws.comando = " select soceqpabv ",
                    "   from datreqpvcl, outer datkvcleqp",
                    "  where datreqpvcl.socvclcod = ? ",
                    "    and datkvcleqp.soceqpcod = datreqpvcl.soceqpcod "
   prepare sel_aux2 from ws.comando
   declare c_datreqpvcl cursor for sel_aux2

   let ws.comando = " select ufdcod, cidnom,",
                    "        brrnom, endzon,",
                    "        lclltt, lcllgt,",
                    "        socvcllcltip   ",
                    "   from datmfrtpos",
                    "  where datmfrtpos.socvclcod = ? "
   prepare sel_aux3 from ws.comando
   declare c_datmfrtpos cursor for sel_aux3

   let ws.comando = "select pstcoddig, vigfnl",
                    "  from datrsrrpst ",
                    " where srrcoddig = ? ",
                    " order by vigfnl desc"
   prepare sel_aux4 from  ws.comando
   declare c_datrsrrpst cursor for sel_aux4

   let ws.comando = "select srrabvnom, celdddcod, celtelnum",
                    "  from datksrr ",
                    " where srrcoddig = ? "
   prepare sel_aux5 from  ws.comando
   declare c_datksrr cursor for sel_aux5

   let ws.comando = " select asitipabvdes ",
                    "   from datrsrrasi, outer datkasitip",
                    "  where datrsrrasi.srrcoddig = ? ",
                    "    and datkasitip.asitipcod = datrsrrasi.asitipcod "
   prepare sel_aux6 from ws.comando
   declare c_datrasitip cursor for sel_aux6

   let ws.comando = " select asitipcod  ",
                    "   from datrsrrasi ",
                    "  where datrsrrasi.srrcoddig = ? ",
                    "    and datrsrrasi.asitipcod = ? "
   prepare sel_aux7 from ws.comando
   declare c_datrsrrasi cursor for sel_aux7

   let ws.comando = " select asitipcod  ",
                    "   from datrvclasi ",
                    "  where datrvclasi.socvclcod = ? ",
                    "    and datrvclasi.asitipcod = ? "
   prepare sel_aux8 from ws.comando
   declare c_datrvclasi cursor for sel_aux8

   let ws.comando= "select dattfrotalocal.srrcoddig,",
                   "       dattfrotalocal.cttdat,",
                   "       dattfrotalocal.ctthor,",
                   "       dattfrotalocal.c24atvcod,",
                   "       dattfrotalocal.atdsrvnum,",
                   "       dattfrotalocal.atdsrvano,",
                   "       dattfrotalocal.atdvclpriflg,",
                   "       dattfrotalocal.obspostxt,",
                   "       datkveiculo.socvclcod,",
                   "       datkveiculo.atdvclsgl,",
                   "       datkveiculo.pstcoddig,",
                   "       datkveiculo.vclcoddig ",
                   "  from datkveiculo, dattfrotalocal",
                   " where datkveiculo.atdvclsgl = ? ",
                   "  and datkveiculo.socacsflg  = '0'",
                   "  and dattfrotalocal.socvclcod = datkveiculo.socvclcod"
   prepare sel_aux9 from ws.comando
   declare c_wdatc007 cursor with hold for sel_aux9


   open  c_wdatc007  using param.atdvclsgl
   foreach c_wdatc007 into wdatc007.srrcoddig,
                            ws.data,
                            wdatc007.hora,
                            wdatc007.c24atvcod,
                            wdatc007.atdsrvnum,
                            wdatc007.atdsrvano,
                            ws.atdvclpriflg,
                            wdatc007.obspostxt,
                            wdatc007.socvclcod,
                            wdatc007.atdvclsgl,
                            wdatc007.pstcoddig,
                            ws.vclcoddig
   
     
      
      
      #------------------------------------------------------------------
      # Calcula tempo de espera
      #------------------------------------------------------------------
      let ws.tempod = 000
      initialize  wdatc007.tempo   to null

      if wdatc007.c24atvcod  is not null   and
         wdatc007.c24atvcod  <>  "QTP"     then
         call wdatc007_calcula(wdatc007.hora,
                                ws.data,
                                ws.horaatu)
              returning  wdatc007.tempo, ws.tempod
      end if

      #------------------------------------------------------------------
      # Busca origem do servico e dados do veiculo
      #------------------------------------------------------------------
      select atdsrvorg,
             atdprvdat,
             ciaempcod
        into wdatc007.atdsrvorg,
             wdatc007.atdprvdat,
             wdatc007.ciaempcod
        from datmservico
       where atdsrvnum =  wdatc007.atdsrvnum
         and atdsrvano =  wdatc007.atdsrvano

      #------------------------------------------------------------------
      # Busca dados do socorrista
      #------------------------------------------------------------------
      initialize wdatc007.celular    to null
      initialize wdatc007.srrabvnom  to null
      initialize ws.celdddcod         to null
      initialize ws.celtelnum         to null

      if wdatc007.srrcoddig  is not null   then
         open  c_datksrr  using  wdatc007.srrcoddig
         fetch c_datksrr  into   wdatc007.srrabvnom,
                                 ws.celdddcod,
                                 ws.celtelnum
         close c_datksrr
         let wdatc007.celular = ws.celdddcod  clipped, " ",
                                 ws.celtelnum
      end if

      #------------------------------------------------------------------
      # Busca assistencias do socorrista
      #------------------------------------------------------------------
      initialize  wdatc007.srrasides  to null

      open    c_datrasitip  using  wdatc007.srrcoddig
      foreach c_datrasitip  into   ws.asitipabvdes
         let wdatc007.srrasides =
             wdatc007.srrasides clipped, ws.asitipabvdes clipped, "/"
      end foreach
      close c_datrasitip
                                                                                
      #------------------------------------------------------------------
      # Busca descricao do veiculo
      #------------------------------------------------------------------
      {
      initialize wdatc007.vcldes  to null
      initialize ws.vclmrcnom      to null
      initialize ws.vcltipnom      to null
      initialize ws.vclmdlnom      to null
                                                                                
      open  c_veiculo  using  ws.vclcoddig
      fetch c_veiculo  into   ws.vclmrcnom,
                              ws.vcltipnom,
                              ws.vclmdlnom
      close c_veiculo

      let wdatc007.vcldes = ws.vclmrcnom clipped, " ",
                             ws.vcltipnom clipped, " ",
                             ws.vclmdlnom
      }

      #------------------------------------------------------------------
      # Busca equipamentos do veiculo
      #------------------------------------------------------------------
      initialize  wdatc007.vcleqpdes  to null

      open    c_datreqpvcl  using  wdatc007.socvclcod
      foreach c_datreqpvcl  into   ws.soceqpabv
         let wdatc007.vcleqpdes =
             wdatc007.vcleqpdes clipped, ws.soceqpabv clipped, "/"
      end foreach
      close c_datreqpvcl

      #------------------------------------------------------------------
      # Busca localizacao do veiculo
      #------------------------------------------------------------------
      initialize wdatc007.ufdcod_gps  to null
      initialize wdatc007.cidnom_gps  to null
      initialize wdatc007.brrnom_gps  to null                          
      initialize wdatc007.endzon_gps  to null
      initialize wdatc007.tipposcab   to null
      initialize wdatc007b.lclltt_gps to null
      initialize wdatc007b.lcllgt_gps to null

      initialize wdatc007.ufdcod_qth  to null
      initialize wdatc007.cidnom_qth  to null
      initialize wdatc007.brrnom_qth  to null
      initialize wdatc007.endzon_qth  to null
      initialize wdatc007b.lclltt_qth to null
      initialize wdatc007b.lcllgt_qth to null

      initialize wdatc007.ufdcod_qti  to null
      initialize wdatc007.cidnom_qti  to null
      initialize wdatc007.brrnom_qti  to null
      initialize wdatc007.endzon_qti  to null
      initialize wdatc007b.lclltt_qti to null
      initialize wdatc007b.lcllgt_qti to null

      open    c_datmfrtpos  using  wdatc007.socvclcod

      foreach c_datmfrtpos  into   ws.ufdcod,
                                   ws.cidnom,
                                   ws.brrnom,
                                   ws.endzon,
                                   ws.lclltt,
                                   ws.lcllgt,
                                   ws.socvcllcltip

         if ws.socvcllcltip  =  1   then
            let wdatc007.ufdcod_gps  =  ws.ufdcod
            let wdatc007.cidnom_gps  =  ws.cidnom
            let wdatc007.brrnom_gps  =  ws.brrnom
            let wdatc007.endzon_gps  =  ws.endzon
            let wdatc007b.lclltt_gps =  ws.lclltt
            let wdatc007b.lcllgt_gps =  ws.lcllgt

            if wdatc007b.lclltt_gps  is not null   and
               wdatc007b.lcllgt_gps  is not null   then
               let wdatc007.tipposcab = "G.P.S. #"
            else
               let wdatc007.tipposcab = "G.P.S.  "
            end if
         else
            if ws.socvcllcltip  =  2   then
               let wdatc007.ufdcod_qth  =  ws.ufdcod
               let wdatc007.cidnom_qth  =  ws.cidnom
               let wdatc007.brrnom_qth  =  ws.brrnom
               let wdatc007.endzon_qth  =  ws.endzon
               let wdatc007b.lclltt_qth =  ws.lclltt
               let wdatc007b.lcllgt_qth =  ws.lcllgt
            else
               let wdatc007.ufdcod_qti  =  ws.ufdcod
               let wdatc007.cidnom_qti  =  ws.cidnom
               let wdatc007.brrnom_qti  =  ws.brrnom
               let wdatc007.endzon_qti  =  ws.endzon
               let wdatc007b.lclltt_qti =  ws.lclltt
               let wdatc007b.lcllgt_qti =  ws.lcllgt
            end if
           end if

      end foreach
      close c_datmfrtpos

#--> Zyon 19/12/2002
        #--------------------------------------------------------------
        # Busca informacoes do local da ocorrencia
        #--------------------------------------------------------------
        call ctx04g00_local_completo(wdatc007.atdsrvnum,
                                     wdatc007.atdsrvano,
                                     1)
                           returning a_rrw[1].lclidttxt   ,
                                     a_rrw[1].lgdtip      ,
                                     a_rrw[1].lgdnom      ,
                                     a_rrw[1].lgdnum      ,
                                     a_rrw[1].lclbrrnom   ,
                                     a_rrw[1].brrnom      ,
                                     a_rrw[1].cidnom      ,
                                     a_rrw[1].ufdcod      ,
                                     a_rrw[1].lclrefptotxt,
                                     a_rrw[1].endzon      ,
                                     a_rrw[1].lgdcep      ,
                                     a_rrw[1].lgdcepcmp   ,
                                     a_rrw[1].dddcod      ,
                                     a_rrw[1].lcltelnum   ,
                                     a_rrw[1].lclcttnom   ,
                                     a_rrw[1].c24lclpdrcod,
                                     ws.sqlcode,
                                     a_rrw[1].endcmp     
                                     
        # PSI 244589 - Inclusão de Sub-Bairro - Burini
        call cts06g10_monta_brr_subbrr(a_rrw[1].brrnom,
                                       a_rrw[1].lclbrrnom)
             returning a_rrw[1].lclbrrnom                                      

        if ws.sqlcode <> 0  then
           #error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura",
           #      " local de ocorrencia. AVISE A INFORMATICA!"
           #exit program
        end if
        
        let m_lgdnum_aux = a_rrw[1].lgdnum using "<<<<#"   
        
        ##verifica se servico possui mecanismo de seguranca                                                   
        if cty28g00_controla_mecanismo_seguranca(wdatc007.atdsrvnum,wdatc007.atdsrvano, wdatc007.ciaempcod) then  
           if a_rrw[1].lgdnum is not null then                                    
              #ocultar numero logradouro para seguranca do segurado       
              if not cty28g00_exibe_endereco_senha(wdatc007.atdsrvnum,wdatc007.atdsrvano) then       
              	  if a_rrw[1].lgdnum >= 1000  then
              	     let m_lgdnum_aux = m_lgdnum_aux[1,2] clipped, "XX"
              	  else 
              	    if a_rrw[1].lgdnum >= 100 then
              	        let m_lgdnum_aux = m_lgdnum_aux[1,1] clipped, "XX"  	  
              	    else  	     
              	       let m_lgdnum_aux = "XX"    	     	
              	    end if
              	  end if    
              end if
           end if          
        end if
        
        let a_rrw[1].lgdtxt = a_rrw[1].lgdtip clipped, " ",
                              a_rrw[1].lgdnom clipped, " ",
                              m_lgdnum_aux clipped, " ",
                              a_rrw[1].endcmp clipped 

        #--------------------------------------------------------------
        # Busca informacoes do local de destino
        #--------------------------------------------------------------
        call ctx04g00_local_completo(wdatc007.atdsrvnum,
                                     wdatc007.atdsrvano,
                                     2)
                           returning a_rrw[2].lclidttxt   ,
                                     a_rrw[2].lgdtip      ,
                                     a_rrw[2].lgdnom      ,
                                     a_rrw[2].lgdnum      ,
                                     a_rrw[2].lclbrrnom   ,
                                     a_rrw[2].brrnom      ,
                                     a_rrw[2].cidnom      ,
                                     a_rrw[2].ufdcod      ,
                                     a_rrw[2].lclrefptotxt,
                                     a_rrw[2].endzon      ,
                                     a_rrw[2].lgdcep      ,
                                     a_rrw[2].lgdcepcmp   ,
                                     a_rrw[2].dddcod      ,
                                     a_rrw[2].lcltelnum   ,
                                     a_rrw[2].lclcttnom   ,
                                     a_rrw[2].c24lclpdrcod,
                                     ws.sqlcode,
                                     a_rrw[2].endcmp 
                                     
        # PSI 244589 - Inclusão de Sub-Bairro - Burini
        call cts06g10_monta_brr_subbrr(a_rrw[2].brrnom,
                                       a_rrw[2].lclbrrnom)
             returning a_rrw[2].lclbrrnom                                      

        if ws.sqlcode = notfound   then
        else
           if ws.sqlcode = 0   then
              let a_rrw[2].lgdtxt = a_rrw[2].lgdtip clipped, " ",
                                    a_rrw[2].lgdnom clipped, " ",
                                    a_rrw[2].lgdnum using "<<<<#", " ",
                                    a_rrw[2].endcmp clipped 
           else
           #   error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura",
           #         " local de destino. AVISE A INFORMATICA!"
           #   exit program
           end if
        end if
#<-- Zyon 19/12/2002
      
    if param.acao <> '2' then
      display "PADRAO@@1@@B@@C@@0@@Identifica&ccedil;&atilde;o@@"
      display "PADRAO@@8@@Ve¡culo@@", param.atdvclsgl,"@@"      
      display "PADRAO@@8@@Socorrista@@", wdatc007.srrcoddig,"-", wdatc007.srrabvnom,"@@"
      display "PADRAO@@8@@Servi&ccedilos@@",wdatc007.srrasides,"@@"
      display "PADRAO@@8@@Situa&ccedil&atilde;o@@",wdatc007.c24atvcod,"@@"
#--> Zyon 19/12/2002

      if wdatc007.atdsrvnum is not null then
          display "PADRAO@@8@@Ordem servi&ccedil;o@@",wdatc007.atdsrvorg using "&&", "/",
                                                      wdatc007.atdsrvnum using "&&&&&&&" , "-",
                                                      wdatc007.atdsrvano using "&&","@@"

         #OSF 19690
         #-------------------------------------#
         # Seleciona dados do veiculo atendido #
         #-------------------------------------#
         select vcldes
               ,vclanomdl 
               ,vcllicnum
               ,vclcorcod
           into wdatc007.vcldes
               ,wdatc007.vclanomdl
               ,wdatc007.vcllicnum
               ,wdatc007.vclcorcod
           from datmservico
          where atdsrvnum =  wdatc007.atdsrvnum
            and atdsrvano =  wdatc007.atdsrvano

          #----------------------------#
          # Seleciona a cor do ve¡culo #
          #----------------------------#
          select cpodes
            into wdatc007.cpodes
            from iddkdominio
           where cponom = "vclcorcod"
             and cpocod = wdatc007.vclcorcod

          display "PADRAO@@1@@B@@C@@0@@Ve¡culo@@"
          display "PADRAO@@8@@Modelo@@", wdatc007.vcldes, "@@"
          display "PADRAO@@8@@Ano@@", wdatc007.vclanomdl, "@@"
          display "PADRAO@@8@@Placa@@", wdatc007.vcllicnum, "@@"
          display "PADRAO@@8@@Cor@@", wdatc007.cpodes, "@@"
      end if

#<-- Zyon 19/12/2002
      display "PADRAO@@1@@B@@C@@0@@",wdatc007.tipposcab,"@@"
      display "PADRAO@@8@@Cidade@@",wdatc007.cidnom_gps clipped," - ", wdatc007.ufdcod_gps,"@@"
      display "PADRAO@@8@@Bairro@@",wdatc007.brrnom_gps clipped," - ", wdatc007.endzon_gps,"@@"
      display "PADRAO@@1@@B@@C@@0@@Q.T.H.@@"
#--> Zyon 19/12/2002
      display "PADRAO@@8@@Endere&ccedil;o@@", a_rrw[1].lgdtxt, "@@"
      display "PADRAO@@8@@Cidade@@", a_rrw[1].cidnom    clipped, " - ", a_rrw[1].ufdcod, "@@"
      display "PADRAO@@8@@Bairro@@", a_rrw[1].lclbrrnom clipped, " - ", a_rrw[1].endzon, "@@"
#<-- Zyon 19/12/2002
      display "PADRAO@@1@@B@@C@@0@@Q.T.I.@@"
#--> Zyon 19/12/2002
      display "PADRAO@@8@@Endere&ccedil;o@@", a_rrw[2].lgdtxt, "@@"
      display "PADRAO@@8@@Cidade@@", a_rrw[2].cidnom    clipped, " - ", a_rrw[2].ufdcod, "@@"
      display "PADRAO@@8@@Bairro@@", a_rrw[2].lclbrrnom clipped, " - ", a_rrw[2].endzon, "@@"
#<-- Zyon 19/12/2002
      if wdatc007.c24atvcod = "QRU" or
         wdatc007.c24atvcod = "REC" or
         wdatc007.c24atvcod = "INI" or
         wdatc007.c24atvcod = "FIM" then 
         display "PADRAO@@1@@B@@C@@0@@PrevisÆo calculada@@"
         display "PADRAO@@8@@PrevisÆo@@",wdatc007.atdprvdat clipped,"@@"
      end if
      display "PADRAO@@1@@B@@C@@0@@Dados complementares@@"
      display "PADRAO@@8@@Observa‡Æo@@",wdatc007.obspostxt,"@@"
      display "PADRAO@@8@@Telefone do socorrista@@",wdatc007.celular,"@@"

    else
#--> Zyon 05/12/2002
      display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Identifica&ccedil;&atilde;o@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ve¡culo@@@@N@@L@@M@@4@@3@@1@@075%@@", param.atdvclsgl, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Socorrista@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.srrcoddig, "-", wdatc007.srrabvnom, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Servi&ccedil;os@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.srrasides, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Situa&ccedil;&atilde;o@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.c24atvcod, "@@@@"
#--> Zyon 19/12/2002
      if wdatc007.atdsrvnum is not null then
          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ordem servi&ccedil;o@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.atdsrvorg using "&&", "/",
                                                                                                                   wdatc007.atdsrvnum using "&&&&&&&" , "-",
                                                                                                                   wdatc007.atdsrvano using "&&","@@@@"

         #OSF 19690
         #-------------------------------------#
         # Seleciona dados do veiculo atendido #
         #-------------------------------------#
         select vcldes
               ,vclanomdl 
               ,vcllicnum
               ,vclcorcod
           into wdatc007.vcldes
               ,wdatc007.vclanomdl
               ,wdatc007.vcllicnum
               ,wdatc007.vclcorcod
           from datmservico
          where atdsrvnum =  wdatc007.atdsrvnum
            and atdsrvano =  wdatc007.atdsrvano

          #----------------------------#
          # Seleciona a cor do ve¡culo #
          #----------------------------#
          select cpodes
            into wdatc007.cpodes
            from iddkdominio
           where cponom = "vclcorcod"
             and cpocod = wdatc007.vclcorcod

          display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Ve¡culo@@@@"

          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Modelo@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.vcldes clipped, "@@@@"

          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ano@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.vclanomdl clipped, "@@@@"

          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Placa@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.vcllicnum clipped, "@@@@"

          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cor@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.cpodes clipped, "@@@@"
      end if

#<-- Zyon 19/12/2002
      display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@", wdatc007.tipposcab, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cidade@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.cidnom_gps clipped," - ",wdatc007.ufdcod_gps, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Bairro@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.brrnom_gps clipped," - ",wdatc007.endzon_gps, "@@@@"
      display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Q.T.H.@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Endere‡o@@@@N@@L@@M@@4@@3@@1@@075%@@", a_rrw[1].lgdtxt, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cidade@@@@N@@L@@M@@4@@3@@1@@075%@@", a_rrw[1].cidnom    clipped, " - ", a_rrw[1].ufdcod, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Bairro@@@@N@@L@@M@@4@@3@@1@@075%@@", a_rrw[1].lclbrrnom clipped, " - ", a_rrw[1].endzon, "@@@@"
    display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Q.T.I.@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Endere‡o@@@@N@@L@@M@@4@@3@@1@@075%@@", a_rrw[2].lgdtxt, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Cidade@@@@N@@L@@M@@4@@3@@1@@075%@@", a_rrw[2].cidnom    clipped, " - ", a_rrw[2].ufdcod, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Bairro@@@@N@@L@@M@@4@@3@@1@@075%@@", a_rrw[2].lclbrrnom clipped, " - ", a_rrw[2].endzon, "@@@@"
      if wdatc007.c24atvcod = "QRU" or
         wdatc007.c24atvcod = "REC" or
         wdatc007.c24atvcod = "INI" or
         wdatc007.c24atvcod = "FIM" then 
         display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Previs&atilde;o calculada@@@@"
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Previs&atilde;o@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.atdprvdat clipped, "@@@@"
      end if
      display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Dados complementares@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Observa&ccedil;&atilde;o@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.obspostxt, "@@@@"
      display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Telefone do socorrista@@@@N@@L@@M@@4@@3@@1@@075%@@", wdatc007.celular, "@@@@"
#<-- Zyon 05/12/2002
    
    end if
    
   end foreach
   
   #------------------------------------
   # ATUALIZA TEMPO DE SESSAO DO USUARIO
   #------------------------------------
   call wdatc003(param.usrtip,
                  param.webusrcod,
                  param.sesnum,
                  param.macsissgl,
                  ws1.*)
        returning ws.sttsess

end main


#---------------------------------------------------------------------
 function wdatc007_calcula(par)   ## Calcula tempo na atividade
#---------------------------------------------------------------------

 define  par     record
    hora         datetime hour to minute,
    data         char(10),
    horaatu      datetime hour to minute
 end record

 define  ws_h24     datetime hour to minute
 define  ret_tempo  char(06)
 define  ret_tempod dec(3,0)

 initialize ws_h24 to null
 initialize ret_tempo to null
 initialize ret_tempod to null


 if par.data  is not null  and
    par.data    <=  today   then
    if par.data  =  today   then
       let ret_tempo  =  par.horaatu - par.hora
       let ret_tempod =  ret_tempo[1,3]  using  "&&&"
    else
       let ws_h24     =  "23:59"
       let ret_tempo  =  ws_h24 - par.hora
       let ws_h24     =  "00:00"
       let ret_tempo  =  ret_tempo + (par.horaatu - ws_h24) + "00:01"
       let ret_tempod =  ret_tempo[1,3]  using  "&&&"
    end if
 end if

 return ret_tempo, ret_tempod

end function  ###-- wdatc007_calcula
