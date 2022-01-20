#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: CTB31M00                                                   #
# ANALISTA RESP..: CELSO YAMAHAKI                                             #
# PSI/OSF........: EXTRACAO EXPONTANEA DE RELATORIOS                          #
#                                                                             #
# ........................................................................... #
# DESENVOLVIMENTO: CELSO YAMAHAKI                                             #
# LIBERACAO......:   /  /                                                     #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 26/05/14   Rodolfo Massini            Alteracao na forma de envio de        #
#                                       e-mail (SENDMAIL para FIGRC009)       # 
#-----------------------------------------------------------------------------#
# 28/10/14   Franzon, Biz    PSI        Incluir relatorio carro extra itau    #
# 28/10/14   Franzon, Biz    PSI        Incluir relatorio sem documento       #
# 28/10/14   Franzon, Biz    PSI        Incluir relatorio telefone            #
#-----------------------------------------------------------------------------#
database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define mr_ire record
       lignum               like datmligacao.lignum
      ,segnom               like datmitaapl.segnom
      ,segcgccpfnum         like datmitaapl.segcgccpfnum
      ,segcgcordnum         like datmitaapl.segcgcordnum
      ,segcgccpfdig         like datmitaapl.segcgccpfdig
      ,semdoctocgccpfnum    like datmatd6523.semdoctocgccpfnum
      ,semdoctocgcord       like datmatd6523.semdoctocgcord
      ,semdoctocgccpfdig    like datmatd6523.semdoctocgccpfdig
      ,segcidnom            like datmitaapl.segcidnom
      ,segufdsgl            like datmitaapl.segufdsgl
      ,ligdat               like datmligacao.ligdat
      ,c24solnom            like datmligacao.c24solnom
      ,itaramcod            like datrligitaaplitm.itaramcod
      ,itaaplnum            like datrligitaaplitm.itaaplnum
      ,aplseqnum            like datrligitaaplitm.aplseqnum
      ,itaciacod            like datrligitaaplitm.itaciacod
end record

define mr_saps record
    cgccpfnum         like datmatd6523.cgccpfnum
   ,cgcord            like datmatd6523.cgcord
   ,cgccpfdig         like datmatd6523.cgccpfdig
   ,semdoctocgccpfnum like datmatd6523.semdoctocgccpfnum
   ,semdoctocgcord    like datmatd6523.semdoctocgcord
   ,semdoctocgccpfdig like datmatd6523.semdoctocgccpfdig
   ,atdsrvnum         like datmservico.atdsrvnum
   ,atdsrvano         like datmservico.atdsrvano
   ,atddat            like datmservico.atddat
   ,corsus            like datmservico.corsus
   ,cornom            like datmservico.cornom
   ,nom               like datmservico.nom
   ,lignum            like datratdlig.lignum
   ,atdnum            like datratdlig.atdnum
   ,c24pbmcod         like datkpbm.c24pbmcod
   ,c24pbmdes         like datkpbm.c24pbmdes
   ,socntzcod         like datksocntz.socntzcod
   ,socntzdes         like datksocntz.socntzdes
   ,cpf               char(25)
   ,cpf2              char(25)
end record

define mr_etapa record
    atdsrvnum like datmservico.atdsrvnum
   ,atdsrvano like datmservico.atdsrvano
   ,envtipcod like datmsrvacp.envtipcod
   ,envtipdes like iddkdominio.cpodes
   ,atdetpcod like datmsrvacp.atdetpcod
   ,atdetpdes like datketapa.atdetpdes
   ,atdsrvseq like datmsrvacp.atdsrvseq
   ,pstcoddig like datmsrvacp.pstcoddig
   ,srrcoddig like datmsrvacp.srrcoddig
   ,atdetpdat like datmsrvacp.atdetpdat
   ,atdetphor like datmsrvacp.atdetphor
   ,acnnaomtv like datmservico.acnnaomtv
   ,nomgrr    like dpaksocor.nomgrr
   ,atdvclsgl like datkveiculo.atdvclsgl
   ,empcod    like datmsrvacp.empcod
   ,funmat    like datmservico.funmat
   ,acn_auto  char(1)
   ,socvclcod like datmsrvacp.socvclcod

end record

define ma_iddkdominio array[20] of record
    cpocod like iddkdominio.cpocod
   ,cpodes like iddkdominio.cpodes
end record

define ma_datketapa array[100] of record
    atdetpcod like datketapa.atdetpcod
   ,atdetpdes like datketapa.atdetpdes
end record

#Franzon
define mr_cX_itau_pg record
    atdsrvano       like datrvcllocrsrcmp.atdsrvano    # ano
   ,atdsrvnum       like datrvcllocrsrcmp.atdsrvnum    # reserva
   ,itarsrcaomtvcod like datrvcllocrsrcmp.itarsrcaomtvcod # cod motivo
   ,aviprvent       like datmavisrent.aviprvent        # Prev util 
   ,locprgflg       like datrvcllocrsrcmp.locprgflg
   ,lcvcod          like datklocadora.lcvcod           # cod locadora
   ,lcvnom          like datklocadora.lcvnom           # Nome locadora
   ,empsgl          like gabkemp.empsgl                # empresa
   ,succod          like dbsmopg.succod                # sucursal
   ,socfatpgtdat    like dbsmopg.socfatpgtdat          # Data de Pagamento
   ,rsrprvdiaqtd    like datrvcllocrsrcmp.rsrprvdiaqtd
   ,mesanopgto      char(14)
   ,mespagto        char(04)
   ,socopgnum       like dbsmopg.socopgnum             # nr op
   ,aplnumdig       like datrservapol.aplnumdig
   ,itmnumdig       like datrservapol.itmnumdig
   ,edsnumref       like datrservapol.edsnumref
   ,ramcod          like datrservapol.ramcod
   ,itaaplnum       like datrligitaaplitm.itaaplnum    # apolice
   ,itaaplitmnum    like datrligitaaplitm.itaaplitmnum # item
   ,lcvregprcdes    char(14)                           # desc tarifa
   ,atddat          like datmservico.atddat            # data
   ,segnom          like datmitaapl.segnom             # usuario
   ,socopgitmvlr    like dbsmopgitm.socopgitmvlr       # valor
   ,atdetpcod       like datmsrvacp.atdetpcod          # Etapa
   ,atdetpdes       like datketapa.atdetpdes           # Descricao etapa
   ,codlocCodloj    char(10)                           # Cod locadora+cod loja
   ,aviprodiaqtd    like datmprorrog.aviprodiaqtd      # soma prorrog
   ,avivclcod       like datkavisveic.avivclcod
   ,avivclgrp       like datkavisveic.avivclgrp        # Grupo
   ,lcvregprccod    like datkavislocal.lcvregprccod    # cod tarifa
   ,lcvextcod       like datkavislocal.lcvextcod
   ,endufd          like datkavislocal.endufd          # UF
   ,endcid          like datkavislocal.endcid          # cidade
   ,aviestcod       like datkavislocal.aviestcod       # cod. loja
   ,aviestnom       like datkavislocal.aviestnom       # Nome loja
   ,c24utidiaqtd    like dbsmopgitm.c24utidiaqtd       # DiarUtl
   ,c24pagdiaqtd    like dbsmopgitm.c24pagdiaqtd       # DiarPag
   ,mot01           like datrvcllocrsrcmp.rsrprvdiaqtd # CORRENTISTA
   ,mot02           like datrvcllocrsrcmp.rsrprvdiaqtd # COBERTURA CONTRATADA PP
   ,mot03           like datrvcllocrsrcmp.rsrprvdiaqtd # COBERTURA CONTRATADA II
   ,mot04           like datrvcllocrsrcmp.rsrprvdiaqtd # BENEFICIO CAR/OFIC
   ,mot05           like datrvcllocrsrcmp.rsrprvdiaqtd # CENTRO DE CUSTO
   ,mot06           like datrvcllocrsrcmp.rsrprvdiaqtd # REVERSIVEL
   ,mot07           like datrvcllocrsrcmp.rsrprvdiaqtd # COBERTURA CONTRATADA
   ,mot08           like datrvcllocrsrcmp.rsrprvdiaqtd # LIVRE UTILIZACAO
   ,motout          like datrvcllocrsrcmp.rsrprvdiaqtd # Outros motivos
end record


define mr_sem_docto  record
       atdsrvnum         like datmservico.atdsrvnum   # Nr servico
      ,atdsrvano         like datmservico.atdsrvano   # Ano servico
      ,atdetpcod         like datmservico.atdetpcod
      ,asitipcod         like datkasitip.asitipcod    # tipo servico
      ,atddat            like datmservico.atddat
      ,pgtdat            like datmservico.pgtdat
      ,srvtipabvdes      like datksrvtip.srvtipabvdes # Desc Abrev Tipo Serv  
      ,asitipdes         like datkasitip.asitipdes    
      ,asitipabvdes      like datkasitip.asitipabvdes # Desc Tipo Assist Abrev 
      ,sinntzcod         like sgaknatur.sinntzcod
      ,sinntzdes         like sgaknatur.sinntzdes
      ,socntzcod         like datksocntz.socntzcod    # Natureza ocorr
      ,socntzdes         like datksocntz.socntzdes    # Desc Natureza da Ocorr 
      ,c24pbmcod         like datkpbm.c24pbmcod       # Cod Problema
      ,c24pbmdes         like datkpbm.c24pbmdes       # desc Problema  
      ,atdetpdes         like datketapa.atdetpdes     # Descr Etapa Servico 
      ,socopgitmvlr      like dbsmopgitm.socopgitmvlr # Custo Servico (REAL)  
      ,mespagto          smallint                     # mes pagto
      ,anopagto          smallint                     # ano pagto
      ,c24astcod         like datkassunto.c24astcod       # Codigo Assunto   
      ,c24astdes         like datkassunto.c24astdes   # Descr Assunto  
      ,atdsrvorg         like datmservico.atdsrvorg   # Cod Origem servico
      ,empciacod         smallint                     # empresa
      ,ramcod            like datmitaapl.itaramcod      # Ramo 
      ,cgccpfnum         like datmatd6523.cgccpfnum   # Num CPF 
      ,cgcord            like datmatd6523.cgcord   # Ordem CPF 
      ,cgccpfdig         like datmatd6523.cgccpfdig      # Digito CPF 
      ,vcllicnum         like datmservico.vcllicnum   # Placa
end record

define mr_telefone record 
       atddat            like datmservico.atddat                              
      ,atdsrvnum         like datmservico.atdsrvnum
      ,atdsrvano         like datmservico.atdsrvano                     
      ,dddcod            like datmlcl.dddcod                      
      ,lcltelnum         like datmlcl.lcltelnum                     
      ,celteldddcod      like datmlcl.celteldddcod  
      ,celtelnum         like datmlcl.celtelnum
      ,lclrefptotxt      like datmlcl.lclrefptotxt
end record

define mr_dados_dbsmopg record
       socopgnum       like dbsmopg.socopgnum    
      ,socopgsitcod    like dbsmopg.socopgsitcod 
      ,empcod          like dbsmopg.empcod       
      ,pstcoddig       like dbsmopg.pstcoddig    
      ,socfatentdat    like dbsmopg.socfatentdat 
      ,socfatpgtdat    like dbsmopg.socfatpgtdat 
      ,soctrfcod       like dbsmopg.soctrfcod    
      ,socfatitmqtd    like dbsmopg.socfatitmqtd 
      ,socfattotvlr    like dbsmopg.socfattotvlr 
      ,socfatrelqtd    like dbsmopg.socfatrelqtd 
      ,infissalqvlr    like dbsmopg.infissalqvlr 
      ,socpgtdoctip    like dbsmopg.socpgtdoctip 
      ,nfsnum          like dbsmopg.nfsnum       
      ,fisnotsrenum    like dbsmopg.fisnotsrenum 
      ,socemsnfsdat    like dbsmopg.socemsnfsdat 
      ,succod          like dbsmopg.succod       
      ,pgtdstcod       like dbsmopg.pgtdstcod    
      ,socopgdscvlr    like dbsmopg.socopgdscvlr 
end record
define mr_dados_dbsropgdsc record
       dsctipcod       like dbsropgdsc.dsctipcod #codigo tipo desconto
      ,dscvlr          like dbsropgdsc.dscvlr    #valor desconto
      ,dscvlrobs       like dbsropgdsc.dscvlrobs #observ do valor de desconto
      ,dscvlrtotal     like dbsropgdsc.dscvlr 
end record

define mr_dados_dbsropgdsctt record
    dscvlrtotal     like dbsropgdsc.dscvlr 
end record

define mr_dados_dbsktipdsc record
    dsctipcod       like dbsktipdsc.dsctipcod     #dsctipcod
   ,dsctipdes       like dbsktipdsc.dsctipdes     #descricao tipo desconto
end record

define mr_dados_dbsmopgfav record
    socopgfavnom    like dbsmopgfav.socopgfavnom
   ,socpgtopccod    like dbsmopgfav.socpgtopccod
   ,socpgtopcdes    char(20)
   ,pestip          like dbsmopgfav.pestip      
   ,cgccpfnum       like dbsmopgfav.cgccpfnum   
   ,cgcord          like dbsmopgfav.cgcord      
   ,cgccpfdig       like dbsmopgfav.cgccpfdig   
   ,bcoctatip       like dbsmopgfav.bcoctatip   
   ,bcocod          like gcdkbancoage.bcocod      
   ,bcoagnnum       like gcdkbancoage.bcoagnnum   
   ,bcoagndig       like dbsmopgfav.bcoagndig   
   ,bcoctanum       like dbsmopgfav.bcoctanum   
end record

define mr_dados_dpaksocor record
   simoptpstflg     like dpaksocor.simoptpstflg
end record

define mr_dados_iddkdominio record
    socopgsitdes    like iddkdominio.cpodes
   ,socpgtdocdes    like iddkdominio.cpodes
end record
       
define mr_dados_gabksuc record
   sucnom           like gabksuc.sucnom              
end record

define mr_dados_gcdkbanco record
   bcosgl           like gcdkbanco.bcosgl
end record
define mr_dados_gcdkbancoage record
   bcoagnnom       like gcdkbancoage.bcoagnnom 
end record

define mr_dados_fpgkpgtdst record
   pgtdstdes       like fpgkpgtdst.pgtdstdes      
end record

define mr_dthor      datetime year to second
define m_datainc     date
define m_datfnl      date
define m_tmpcrs      datetime year to second
define m_indice      smallint      
define m_totfor      smallint 



#Franzon FIm
#--------------------------------------
function ctb31m00(relatorio)
#--------------------------------------


   define texto1   date
   define texto2   date
   define email    char(45)
   define titulo   char(25)

   define limite smallint

   define relatorio char(06)

   let titulo = "Relatorio ", relatorio clipped

   let limite = 15
   
   if relatorio = 'cX_ita' or
      relatorio = 'sem_dO' or
      relatorio = 'tele' then
      let limite = 31
   end if
   	
   if relatorio = 'Etapa' then
      let limite = 1
   end if
   if relatorio = 'NF' or relatorio = 'HorCom' then
      let limite = 31
   end if

   if relatorio = 'Agenda' or relatorio = "SMS" then
      let limite = 7
   end if

   open window w_ctb31m00 at 7,10 with form "ctb31m00"
        attribute(border)

   display by name titulo attribute (reverse)

   input by name texto1, texto2, email

      before field texto1
           display by name texto1 attribute (reverse)
      after  field texto1
           display by name texto1
           if texto1 is null then
              error "campo obrigatorio"
              next field texto1
           end if
      before field texto2
           display by name texto2 attribute (reverse)
      after  field texto2
           display by name texto2
           if texto1 is null then
              error "campo obrigatorio"
              next field texto2
           end if

           if texto2 < texto1 then
              error "Data final menor que inicial!!"
              next field texto2
           end if

           if texto2 - texto1 > limite then
              error "periodo de extracao deve ser de ", limite, " dias!!!"
              next field texto2
           end if

      before field email
           display by name email attribute(reverse)
      after  field email
           display by name email
           if email is null then
              error "campo obrigatorio"
              next field email
           end if
   on key (f1)
      initialize email to null
      let email = 'luisfernando.melo@portoseguro.com.br'
      display by name email

   on key (f2)
      initialize email to null
      let email = 'kelly.emocija@portoseguro.com.br'
      display by name email

   on key (f3)
      initialize email to null
      let email = 'everton.lima@portoseguro.com.br'
      display by name email
   on key (f4)
      initialize email to null
      let email = 'ronald.santos@portoseguro.com.br'
      display by name email
   on key (f5)
      initialize email to null
      let email = 'renato.bastos@portoseguro.com.br'
      display by name email
   on key (f6)
      initialize email to null
      let email = 'yuri.silva@portoseguro.com.br'
      display by name email
   on key (f7)
      initialize email to null
      let email = 'celso.yamahaki@portoseguro.com.br'
      display by name email
   on key (control-c)
      error "Operacao Cancelada"
      return
   on key (f17)
      error "Operacao Cancelada"
      return

   end input

   close window w_ctb31m00
   error "Por favor aguarde, Pesquisando..."

   if relatorio = "CidSed" then
      call ctb31m00_cidsed(texto1, texto2, email)
      error "Extracao concluida!!!"
   end if

   if relatorio = "HorCom" then
      call ctb31m00_horaComb(texto1, texto2, email)
      error "Extracao concluida!!!"
   end if

   if relatorio = "IRE" then
     call ctb31m00_ire(texto1, texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = "SAPS" then
     call ctb31m00_saps(texto1, texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = 'Etapa' then
     call ctb31m00_etapa(texto1,texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = 'NF' then
     call ctb31m00_nota_fiscal(texto1,texto2, email)
     #call ctb31m00_nf(texto1,texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = 'Retor' then
     call ctb31m00_retorno(texto1,texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = 'Agenda' then
     call ctb31m00_agenda(texto1,texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = 'SMS' then
     call ctb31m00_sms(texto1,texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = 'cX_ita' then
     call ctb31m00_cX_itau_pg(texto1,texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = 'sem_dO' then
     call ctb31m00_sEm_documento(texto1,texto2, email)
     error "Extracao concluida!!!"
   end if

   if relatorio = 'tele' then
     call ctb31m00_teleFone(texto1,texto2, email)
     error "Extracao concluida!!!"
   end if

end function

#--------------------------------------
function ctb31m00_saps(param)
#--------------------------------------

   define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
   end record

   define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint

   define l_path char(300),
          l_sql  char(3000)
          
   ### RODOLFO MASSINI - INICIO 
   #---> Variaves para:
   #     remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
  
   define lr_mail record       
          rem char(50),        
          des char(250),       
          ccp char(250),       
          cco char(250),       
          ass char(500),       
          msg char(32000),     
          idr char(20),        
          tip char(4)          
   end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null
 
   ### RODOLFO MASSINI - FIM 

   let l_sql = 'select srv.atdsrvnum, srv.atdsrvano, srv.atddat '
              ,'      ,srv.corsus   , srv.cornom, srv.nom       '
              ,'      ,sre.socntzcod                            '
              ,'  from datmservico srv ,                        '
              ,'       outer datmsrvre sre                      '
              ,' where srv.atdsrvnum = sre.atdsrvnum            '
              ,'   and srv.atdsrvano = sre.atdsrvano            '
              ,'   and atddat between ? and ?                   '
              ,'   and ciaempcod = 43                           '
   prepare p_saps00 from l_sql
   declare c_saps00 cursor for p_saps00


   let l_sql = 'select min(lignum) '
              ,'  from datmligacao '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '
   prepare p_saps01 from l_sql
   declare c_saps01 cursor for p_saps01

   let l_sql = 'select cgccpfnum            '
              ,'      ,cgcord               '
              ,'      ,cgccpfdig            '
              ,'      ,semdoctocgccpfnum    '
              ,'      ,semdoctocgcord       '
              ,'      ,semdoctocgccpfdig    '
              ,'  from datmatd6523          '
              ,' where atdnum = ?           '
   prepare p_saps02 from l_sql
   declare c_saps02 cursor for p_saps02

   let l_sql = 'select atdnum '
              ,'  from datratdlig '
              ,' where lignum = ?'
   prepare p_saps03 from l_sql
   declare c_saps03 cursor for p_saps03

   let l_sql = 'select c24astcod '
              ,'  from datmligacao '
              ,' where lignum = ? '
   prepare p_saps04 from l_sql
   declare c_saps04 cursor for p_saps04

   let l_sql = 'select socntzdes '
              ,'  from datksocntz '
              ,' where socntzcod = ? '
   prepare p_saps05 from l_sql
   declare c_saps05 cursor for p_saps05

   let l_sql = 'select c24astcod '
              ,'  from datmligacao '
              ,' where lignum = ? '
   prepare p_saps06 from l_sql
   declare c_saps06 cursor for p_saps06

   let l_path = './saps.xls'
   start report report_saps to l_path

   open c_saps00 using param.data_ini
                      ,param.data_fim

   foreach c_saps00 into mr_saps.atdsrvnum
                        ,mr_saps.atdsrvano
                        ,mr_saps.atddat
                        ,mr_saps.corsus
                        ,mr_saps.cornom
                        ,mr_saps.nom
                        ,mr_saps.socntzcod



      open c_saps01 using  mr_saps.atdsrvnum
                          ,mr_saps.atdsrvano
      fetch c_saps01 into mr_saps.lignum
      close c_saps01

      if mr_saps.lignum is null then
         let mr_saps.cpf = 'SEM LIGACAO'
         output to report report_saps()
         initialize mr_saps.* to null
         continue foreach
      end if

      open c_saps03 using mr_saps.lignum
      fetch c_saps03 into mr_saps.atdnum
      close c_saps03

      open c_saps02 using mr_saps.atdnum
      fetch c_saps02 into  mr_saps.cgccpfnum
                          ,mr_saps.cgcord
                          ,mr_saps.cgccpfdig
                          ,mr_saps.semdoctocgccpfnum
                          ,mr_saps.semdoctocgcord
                          ,mr_saps.semdoctocgccpfdig
      close c_saps02

      let mr_saps.cpf = mr_saps.cgccpfnum, '/',
                        mr_saps.cgcord , '-', mr_saps.cgccpfdig

      let mr_saps.cpf2 = mr_saps.semdoctocgccpfnum
                         ,'/', mr_saps.semdoctocgcord
                         ,'-', mr_saps.semdoctocgccpfdig

      if mr_saps.socntzcod is not null then
         open c_saps05 using mr_saps.socntzcod
         fetch c_saps05 into mr_saps.socntzdes
         close c_saps05
      end if

      output to report report_saps()
      initialize mr_saps.* to null

   end foreach
   finish report report_saps


   whenever error continue
      let l_comando = "gzip -f ", l_path

      run l_comando
      let l_path = l_path clipped, ".gz"

      



      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
      
      #let l_comando = ' echo "','SERVICOS AVULSOS' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','SERVICOS AVULSOS ', param.data_ini, '-', param.data_fim, '" ',
      #                ' -f    ',l_path clipped

      #run l_comando returning l_retorno
  
      let lr_mail.ass = "SERVICOS AVULSOS ", param.data_ini, "-", param.data_fim
      let lr_mail.msg = "SERVICOS AVULSOS"     
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = l_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                
      ### RODOLFO MASSINI - FIM 

      let l_comando = "rm ", l_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function

#--------------------------------------
function ctb31m00_ire(param)
#--------------------------------------

define param record
    data_ini date
   ,data_fim date
   ,email    char(35)
end record

   define l_now datetime year to second,
          l_path char(100),
          l_query char(500),
          l_count integer

   define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint
         
   ### RODOLFO MASSINI - INICIO 
   #---> Variaves para:
   #     remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
   define lr_mail record       
          rem char(50),        
          des char(250),       
          ccp char(250),       
          cco char(250),       
          ass char(500),       
          msg char(32000),     
          idr char(20),        
          tip char(4)          
   end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null
 
   ### RODOLFO MASSINI - FIM 

   set isolation to dirty read
   initialize mr_ire.* to null
   let l_count = 0

   let l_path = './itau_IRE.xls'

   let l_query = ' select segnom, segcgccpfnum, '
                ,' segcgcordnum, segcgccpfdig   '
                ,'   from datmitaapl            '
                ,'  where itaramcod = ?         '
                ,'    and itaaplnum = ?         '
                ,'    and aplseqnum = ?         '
                ,'    and itaciacod = ?         '

   prepare p_ire_02 from l_query
   declare c_ire_02 cursor for p_ire_02

   let l_query = 'select itaramcod, itaaplnum, aplseqnum, itaciacod'
                ,'  from datrligitaaplitm '
                ,' where lignum = ? '
   prepare p_ire_03 from l_query
   declare c_ire_03 cursor  for p_ire_03

   let l_query = ' select semdoctocgccpfnum, '
                ,'        semdoctocgcord,    '
                ,'        semdoctocgccpfdig  '
                ,'   from datmatd6523 atd, datratdlig rel'
                ,'  where atd.atdnum = rel.atdnum '
                ,'    and rel.lignum = ? '
   prepare p_ire_04 from l_query
   declare c_ire_04 cursor  for p_ire_04

   let l_query = ' select semdoctocgccpfnum, '
                ,'        semdoctocgcord,    '
                ,'        semdoctocgccpfdig  '
                ,'   from datmatd6523 atd, datratdlig rel '
                ,'       ,datmligacao liga '
                ,'  where atd.atdnum = rel.atdnum '
                ,'    and atd.ciaempcod = 84'
                ,'    and liga.lignum = rel.lignum'
                ,'    and liga.lignum = ? '
   prepare p_ire_05 from l_query
   declare c_ire_05 cursor  for p_ire_05

   let l_query = ' select segnom, segcpjcpfnum,   '
                ,'        cpjordnum, cpjcpfdignum,'
                ,'        segcidnom, estsgl       '
                ,'   from datmresitaapl           '
                ,'  where itaramcod = ?           '
                ,'    and aplnum = ?              '
              # ,'  #--and aplseqnum = 01         '
                ,'    and itaciacod = ?           '
   prepare p_ire_06 from l_query
   declare c_ire_06 cursor for p_ire_06

   declare c_ire_01 cursor for

    select lignum, ligdat, c24solnom
     from datmligacao lig
         ,datkassunto ast
    where lig.c24astcod = ast.c24astcod
      and ast.c24astagp = 'IRE'
      and lig.ligdat between param.data_ini and param.data_fim

   start report report_ire to l_path

   let l_now = current

   open c_ire_01
   foreach c_ire_01 into mr_ire.lignum
                        ,mr_ire.ligdat
                        ,mr_ire.c24solnom

      open c_ire_03 using mr_ire.lignum

      fetch c_ire_03 into mr_ire.itaramcod
                         ,mr_ire.itaaplnum
                         ,mr_ire.aplseqnum
                         ,mr_ire.itaciacod


      if mr_ire.itaramcod is not null then
         open c_ire_02 using mr_ire.itaramcod
                            ,mr_ire.itaaplnum
                            ,mr_ire.aplseqnum
                            ,mr_ire.itaciacod

         fetch c_ire_02 into mr_ire.segnom
                            ,mr_ire.segcgccpfnum
                            ,mr_ire.segcgcordnum
                            ,mr_ire.segcgccpfdig



         if mr_ire.segnom is null then
             open c_ire_05 using mr_ire.lignum

             fetch c_ire_05 into mr_ire.semdoctocgccpfnum
                                ,mr_ire.semdoctocgcord
                                ,mr_ire.semdoctocgccpfdig

         end if
         if mr_ire.semdoctocgccpfnum is null then
            open c_ire_06 using mr_ire.itaramcod
                               ,mr_ire.itaaplnum
                               ,mr_ire.itaciacod
            fetch c_ire_06 into mr_ire.segnom
                               ,mr_ire.segcgccpfnum
                               ,mr_ire.segcgcordnum
                               ,mr_ire.segcgccpfdig
                               ,mr_ire.segcidnom
                               ,mr_ire.segufdsgl

         end if
      end if
      output to report report_ire()
      initialize mr_ire.* to null


   end foreach

   close c_ire_02
   close c_ire_03
   close c_ire_05

   finish report report_ire

   let l_now = current


   whenever error continue
      let l_comando = "gzip -f ", l_path


      run l_comando
      let l_path = l_path clipped, ".gz"
      
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
  
      #let l_comando = ' echo "','SERVICOS ASSUNTO IRE' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','SERVICOS ASSUNTO IRE ', param.data_ini, '-', param.data_fim, '" ',
      #                ' -f    ',l_path clipped

      #run l_comando returning l_retorno
      
      let lr_mail.ass = "SERVICOS ASSUNTO IRE ", param.data_ini, "-", param.data_fim
      let lr_mail.msg = "SERVICOS ASSUNTO IRE"     
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = l_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                
      ### RODOLFO MASSINI - FIM 

      #call ctb31m00_mail(param.email, l_path, "Servicos Assunto IRE")

      let l_comando = "rm ", l_path clipped
      run l_comando returning l_retorno
   whenever error stop


end function

#--------------------------------------
function ctb31m00_mail(param)
#--------------------------------------

define param record
   destinatario   char(250)
  ,caminho        char(200)
  ,assunto        char(150)
end record


define lr_mail record
    rem char(50),
    des char(250),
    ccp char(250),
    cco char(250),
    ass char(150),
    msg char(32000),
    idr char(20),
    tip char(4)
 end record

define l_retorno   smallint,
       l_comando   char(1000),
       l_email     like igbmparam.relpamtxt,
       l_destino   char(800),
       l_cod_erro  integer,
       l_msg_erro  char(20)

let lr_mail.rem = param.destinatario
let lr_mail.ccp = ""
let lr_mail.cco = ""
let lr_mail.des = param.destinatario clipped
let lr_mail.ass = param.assunto clipped
let lr_mail.tip = "text"
let lr_mail.idr = "P0603000"


display '----- Anexando Arquivo -----'
display 'param.caminho: ', param.caminho clipped
call figrc009_attach_file(param.caminho)
call figrc009_mail_send1(lr_mail.*)
  returning l_cod_erro, l_msg_erro
display '----- Envio Email -----'
display 'lr_mail.rem: ', lr_mail.rem clipped
display 'lr_mail.ccp: ', lr_mail.ccp clipped
display 'lr_mail.cco: ', lr_mail.cco clipped
display 'lr_mail.des: ', lr_mail.des clipped
display 'lr_mail.ass: ', lr_mail.ass clipped
display 'lr_mail.tip: ', lr_mail.tip clipped
display 'lr_mail.idr: ', lr_mail.idr clipped

display '------ Retorno Envio ------'
display 'l_cod_erro: ', l_cod_erro
display 'l_msg_erro: ', l_msg_erro clipped

end function


#-------------------------------------#
report report_ire()
#-------------------------------------#


  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

   print "LIGACAO        ", ASCII(09),
         "SOLICITANTE    ", ASCII(09),
         "DATA           ", ASCII(09),
         "NOME           ", ASCII(09),
         "CIDADE         ", ASCII(09),
         "UF             ", ASCII(09),
         "CPF/CGC        ", ASCII(09),
         "ORDEM          ", ASCII(09),
         "DIGITO         ", ASCII(09),
         "RAMO           ", ASCII(09),
         "APOLICE        ", ASCII(09),
         "SEQUENCIA      ", ASCII(09),
         "CPF_SEM_DOCT   ", ASCII(09),
         "ORDEM          ", ASCII(09),
         "DIGITO_CPF_CNPJ"

     on every row

        print mr_ire.lignum            , ascii(09);
        print mr_ire.c24solnom         , ascii(09);
        print mr_ire.ligdat            , ascii(09);
        print mr_ire.segnom            , ascii(09);
        print mr_ire.segcidnom         , ascii(09);
        print mr_ire.segufdsgl         , ascii(09);
        print mr_ire.segcgccpfnum      , ascii(09);
        print mr_ire.segcgcordnum      , ascii(09);
        print mr_ire.segcgccpfdig      , ascii(09);
        print mr_ire.itaramcod         , ascii(09);
        print mr_ire.itaaplnum         , ascii(09);
        print mr_ire.aplseqnum         , ascii(09);
        print mr_ire.semdoctocgccpfnum , ascii(09);
        print mr_ire.semdoctocgcord    , ascii(09);
        print mr_ire.semdoctocgccpfdig

end report



#-------------------------------------#
report report_saps()
#-------------------------------------#


  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

   print "SERVICO", ASCII(09),
         "ANO", ASCII(09),
         "DATA", ASCII(09),
         "SUSEP", ASCII(09),
         "CORRETOR", ASCII(09),
         "NOME", ASCII(09),
         "CPF", ASCII(09),
         "CPF_SEM_DOCT", ASCII(09),
         "NATUREZA", ASCII(09),
         "PROBLEMA"

     on every row

        print mr_saps.atdsrvnum , ascii(09);
        print mr_saps.atdsrvano , ascii(09);
        print mr_saps.atddat , ascii(09);
        print mr_saps.corsus , ascii(09);
        print mr_saps.cornom , ascii(09);
        print mr_saps.nom , ascii(09);
        print mr_saps.cpf , ascii(09);
        print mr_saps.cpf2, ascii(09);
        print mr_saps.socntzdes , ascii(09);
        print mr_saps.c24pbmdes

end report


#------------------------------------
function ctb31m00_etapa(param)
#------------------------------------
define param record
    data_ini date
   ,data_fim date
   ,email    char(35)
end record

define m_path         char (500)
      ,m_data         date
      ,m_data_inicio  date
      ,m_data_fim     date
      ,m_hora         datetime hour to minute
      ,m_current      datetime hour to second

define l_query char(1500)

 define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint
         
### RODOLFO MASSINI - INICIO 
#---> Variaves para:
#     remover (comentar) forma de envio de e-mails anterior e inserir
#     novo componente para envio de e-mails.
#---> feito por Rodolfo Massini (F0113761) em maio/2013
 
define lr_mail record       
       rem char(50),        
       des char(250),       
       ccp char(250),       
       cco char(250),       
       ass char(500),       
       msg char(32000),     
       idr char(20),        
       tip char(4)          
end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null
 
### RODOLFO MASSINI - FIM 



   # Query principal - Todos os Serviços do período
   let l_query = 'select srv.atdsrvnum, srv.atdsrvano,   '
                ,'       acp.envtipcod, acp.atdetpcod,   '
                ,'       acp.atdsrvseq, acp.pstcoddig,   '
                ,'       acp.srrcoddig, srv.acnnaomtv,   '
                ,'       acp.atdetpdat, acp.atdetphor,   '
                ,'       acp.socvclcod, acp.empcod, acp.funmat ' #130918851
                ,'  from datmservico srv, datmsrvacp acp '
                ,' where srv.atdsrvnum = acp.atdsrvnum   '
                ,'   and srv.atdsrvano = acp.atdsrvano   '
                ,'   and srv.atdsrvorg in (1,2,3,4,5,6,7,8,9,13)'
                ,'   and srv.atddat between ? and ?      '
   prepare p_bdbsr014_01 from l_query
   declare c_bdbsr014_01 cursor for p_bdbsr014_01

   # Query para localizar a descricao dos campos
   let l_query = 'select cpocod, cpodes      '
                ,'  from iddkdominio         '
                ," where cponom ='envtipcod' "
   prepare p_bdbsr014_02 from l_query
   declare c_bdbsr014_02 cursor for p_bdbsr014_02

   # Query para localizar dados do prestador
   let l_query = 'select nomgrr       '
                ,'  from dpaksocor    '
                ,' where pstcoddig = ?'
   prepare p_bdbsr014_03 from l_query
   declare c_bdbsr014_03 cursor for p_bdbsr014_03

   # Query para localizar dados do veículo
   let l_query = 'select atdvclsgl    '
                ,'  from datkveiculo  '
                ,' where socvclcod = ?'
   prepare p_bdbsr014_04 from l_query
   declare c_bdbsr014_04 cursor for p_bdbsr014_04

   # Query para as descricoes das etapas
   let l_query = 'select atdetpcod, atdetpdes '
                ,'  from datketapa            '
                ," where atdetpstt = 'A'      "
   prepare p_bdbsr014_05 from l_query
   declare c_bdbsr014_05 cursor for p_bdbsr014_05

   initialize m_path
             ,mr_etapa.* to null

   let m_path = './Etapa.csv'
   let m_current = current


   let m_data_fim = param.data_ini
   let m_data_inicio = param.data_fim


   set isolation to dirty read

   call ctb31m00_carga_array()

   open c_bdbsr014_01 using m_data_inicio
                           ,m_data_fim

   start report report_etapa to m_path

   foreach c_bdbsr014_01 into mr_etapa.atdsrvnum, mr_etapa.atdsrvano
                             ,mr_etapa.envtipcod, mr_etapa.atdetpcod
                             ,mr_etapa.atdsrvseq, mr_etapa.pstcoddig
                             ,mr_etapa.srrcoddig, mr_etapa.acnnaomtv
                             ,mr_etapa.atdetpdat, mr_etapa.atdetphor
                             ,mr_etapa.socvclcod
                             ,mr_etapa.empcod   , mr_etapa.funmat #130918851

      #Verifica se foi acionamento automático
      if mr_etapa.funmat = 999999  and
         mr_etapa.acnnaomtv is null then
         let mr_etapa.acn_auto = "S"
      else
         let mr_etapa.acn_auto = "N"
      end if

      call ctb31m00_qlEtapa(mr_etapa.atdetpcod)
         returning mr_etapa.atdetpdes

      if mr_etapa.envtipcod is not null then
         call ctb31m00_dominio(mr_etapa.envtipcod)
            returning mr_etapa.envtipdes
      end if

      if mr_etapa.pstcoddig is not null then
         open c_bdbsr014_03 using mr_etapa.pstcoddig
         fetch c_bdbsr014_03 into mr_etapa.nomgrr
         close c_bdbsr014_03
      end if

      if mr_etapa.socvclcod is not null then
         open c_bdbsr014_04 using mr_etapa.socvclcod
         fetch c_bdbsr014_04 into mr_etapa.atdvclsgl
      end if

      output to report report_etapa()
      initialize mr_etapa.* to null

   end foreach
   finish report report_etapa
   whenever error continue
      let l_comando = "gzip -f ", m_path


      run l_comando
      let m_path = m_path clipped, ".gz"

      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
      #let l_comando = ' echo "','ETAPAS DE ACIONAMENTO' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','ETAPAS DE ACIONAMENTO DO DIA ', param.data_ini, ' " ',
      #                ' -f    ',m_path clipped
      #
      #run l_comando returning l_retorno
       
      let lr_mail.ass = "ETAPAS DE ACIONAMENTO DO DIA ", param.data_ini     
      let lr_mail.msg = "ETAPAS DE ACIONAMENTO"   
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = m_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                
      ### RODOLFO MASSINI - FIM 

      #call ctb31m00_mail(param.email, l_path, "Servicos Assunto IRE")

      let l_comando = "rm ", m_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function


#------------------------------------------------
function ctb31m00_qlEtapa(l_param)
#------------------------------------------------

   define l_param record
       atdetpcod   like datmsrvacp.atdetpcod
   end record

   define lr_retorno record
       atdetpdes   like iddkdominio.cpodes
   end record

   define l_i smallint

   initialize lr_retorno.* to null

   for l_i = 1 to 100

      if ma_datketapa[l_i].atdetpcod is null then
         let lr_retorno.atdetpdes = "N CADASTRADO"
         exit for
      end if

      if l_param.atdetpcod = ma_datketapa[l_i].atdetpcod then
         let lr_retorno.atdetpdes = ma_datketapa[l_i].atdetpdes
         exit for
      end if

   end for

   return lr_retorno.atdetpdes

end function

#------------------------------------------------
function ctb31m00_dominio(l_param)
#------------------------------------------------

   define l_param record
       cpocod   like iddkdominio.cpocod
   end record

   define lr_retorno record
       cpodes   like iddkdominio.cpodes
   end record

   define l_i smallint

   initialize lr_retorno.* to null


   for l_i = 1 to 20

      if ma_iddkdominio[l_i].cpocod is null then
         let lr_retorno.cpodes = "N CADASTRADO"
         exit for
      end if

      if l_param.cpocod = ma_iddkdominio[l_i].cpocod then
         let lr_retorno.cpodes = ma_iddkdominio[l_i].cpodes
         exit for
      end if

   end for

   return lr_retorno.cpodes

end function


#------------------------------------------------
function ctb31m00_carga_array()
#------------------------------------------------
   define l_i smallint

   open c_bdbsr014_02
   let l_i = 1
   foreach c_bdbsr014_02 into ma_iddkdominio[l_i].cpocod
                             ,ma_iddkdominio[l_i].cpodes
      let l_i = l_i + 1
   end foreach

   open c_bdbsr014_05

   let l_i = 1
   foreach c_bdbsr014_05 into ma_datketapa[l_i].atdetpcod
                             ,ma_datketapa[l_i].atdetpdes
      let l_i = l_i + 1
   end foreach

end function



#-------------------------------------#
report report_etapa()
#-------------------------------------#

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "SERVICO"          ,'|',
              "ANO"              ,'|',
              "COD_TP_ENV"       ,'|',
              "DESC_TP_ENV"      ,'|',
              "SEQ_ETAPA"        ,'|',
              "DATA_ETAPA"       ,'|',
              "HORA_ETAPA"       ,'|',
              "COD_ETAPA"        ,'|',
              "DESC_ETAPA"       ,'|',
              "ACN_AUTO(S/N)"    ,'|',
              "MOVITO_NAO_ACN"   ,'|',
              "CDO_PRESTADOR"    ,'|',
              "NOME_GUERRA"      ,'|',
              "COD_VEICULO"      ,'|',
              "SIGLA_VEICULO"    ,'|',
              "COD_SOCORRISTA"   ,'|',
              "EMPRESA_FUN"      ,'|',
              "MATRICULA"

  on every row

     print mr_etapa.atdsrvnum          ,'|';
     print mr_etapa.atdsrvano          ,'|';
     print mr_etapa.envtipcod          ,'|';
     print mr_etapa.envtipdes clipped  ,'|';
     print mr_etapa.atdsrvseq          ,'|';
     print mr_etapa.atdetpdat          ,'|';
     print mr_etapa.atdetphor          ,'|';
     print mr_etapa.atdetpcod          ,'|';
     print mr_etapa.atdetpdes clipped  ,'|';
     print mr_etapa.acn_auto           ,'|';
     print mr_etapa.acnnaomtv clipped  ,'|';
     print mr_etapa.pstcoddig          ,'|';
     print mr_etapa.nomgrr    clipped  ,'|';
     print mr_etapa.socvclcod          ,'|';
     print mr_etapa.atdvclsgl          ,'|';
     print mr_etapa.srrcoddig          ,'|';
     print mr_etapa.empcod             ,'|';
     print mr_etapa.funmat

end report

#-------------------------------------#
function ctb31m00_nf(param)
#-------------------------------------#


   define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
   end record

   define m_path         char (500)
         ,m_data         date
         ,m_data_inicio  date
         ,m_data_fim     date
         ,m_hora         datetime hour to minute
         ,m_current      datetime hour to second

   define l_query char(1500)

   define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint

   ### RODOLFO MASSINI - INICIO 
   #---> Variaves para:
   #     remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
   define lr_mail record       
          rem char(50),        
          des char(250),       
          ccp char(250),       
          cco char(250),       
          ass char(500),       
          msg char(32000),     
          idr char(20),        
          tip char(4)          
   end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null
 
   ### RODOLFO MASSINI - FIM 
  
   let m_path = './nfemp43.csv'
   unload to m_path
   select op.socopgnum
         ,itm.atdsrvnum, itm.atdsrvano
         ,itm.nfsnum, op.socemsnfsdat
     from dbsmopg op, dbsmopgitm itm
    where op.socopgnum = itm.socopgnum
      and op.nfsnum    = itm.nfsnum
      and op.empcod = 43
      and op.socemsnfsdat between param.data_ini and param.data_fim
   order by op.socemsnfsdat

   whenever error continue
      let l_comando = "gzip -f ", m_path


      run l_comando
      let m_path = m_path clipped, ".gz"
      
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
      
      #let l_comando = ' echo "','NOTAS FISCAIS EMP43' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','NOTAS FISCAIS EMP43 ', param.data_ini, ' " ',
      #                ' -f    ',m_path clipped

      #run l_comando returning l_retorno
  
      let lr_mail.ass = "NOTAS FISCAIS EMP43 ", param.data_ini      
      let lr_mail.msg = "NOTAS FISCAIS EMP43" 
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = m_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                   
      ### RODOLFO MASSINI - FIM 

      #call ctb31m00_mail(param.email, l_path, "Servicos Assunto IRE")

      let l_comando = "rm ", m_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function


#-------------------------------------#
function ctb31m00_cidsed(param)
#-------------------------------------#


   define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
   end record

   define m_path         char (500)
         ,m_data         date
         ,m_data_inicio  date
         ,m_data_fim     date
         ,m_hora         datetime hour to minute
         ,m_current      datetime hour to second

   define l_query char(1500)

   define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint
         
   ### RODOLFO MASSINI - INICIO 
   #---> Variaves para:
   #     remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
   define lr_mail record       
          rem char(50),        
          des char(250),       
          ccp char(250),       
          cco char(250),       
          ass char(500),       
          msg char(32000),     
          idr char(20),        
          tip char(4)          
   end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null
 
   ### RODOLFO MASSINI - FIM 

   let m_path = './cidsed.csv'
   unload to m_path
   select cid2.mpacidcod,
          cid2.cidnom,
          cid2.ufdcod,
          cid1.mpacidcod,
          cid1.cidnom,
          cid1.ufdcod
     from datrcidsed cidxsed,
          datkmpacid cid1,
          datkmpacid cid2
    where cidxsed.cidcod    = cid1.mpacidcod
      and cidxsed.cidsedcod = cid2.mpacidcod
     order by 1,2

   whenever error continue
      let l_comando = "gzip -f ", m_path

      let param.data_ini = today
      run l_comando
      let m_path = m_path clipped, ".gz"
     
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
      
      #let l_comando = ' echo "','Cidades Sede' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','Cidades Sede extraido em: ', param.data_ini, ' " ',
      #                ' -f    ',m_path clipped
      #run l_comando returning l_retorno
  
      let lr_mail.ass = "Cidades Sede extraido em: ", param.data_ini     
      let lr_mail.msg = "Cidades Sede"   
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = m_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                
      ### RODOLFO MASSINI - FIM 

      #call ctb31m00_mail(param.email, l_path, "Servicos Assunto IRE")

      let l_comando = "rm ", m_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function

#-------------------------------------#
function ctb31m00_retorno(param)
#-------------------------------------#


   define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
   end record

   define m_path         char (500)
         ,m_data         date
         ,m_data_inicio  date
         ,m_data_fim     date
         ,m_hora         datetime hour to minute
         ,m_current      datetime hour to second

   define l_query char(1500)

   define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint
         
  ### RODOLFO MASSINI - INICIO 
  #---> Variaves para:
  #     remover (comentar) forma de envio de e-mails anterior e inserir
  #     novo componente para envio de e-mails.
  #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
  define lr_mail record       
         rem char(50),        
         des char(250),       
         ccp char(250),       
         cco char(250),       
         ass char(500),       
         msg char(32000),     
         idr char(20),        
         tip char(4)          
  end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null
 
  ### RODOLFO MASSINI - FIM 

   let m_path = './retorno.csv'
   unload to m_path
   select srv.ciaempcod, srv.atdsrvnum, srv.atdsrvano
      ,srv.atdetpcod, etp.atdetpdes,
       ret.atdorgsrvnum, ret.atdorgsrvano, ret.srvretmtvcod,
       mtv.srvretmtvdes, srv.atddat, srv.atddatprg, srv.atdhorprg
  from datmservico srv, datmsrvre ret, datksrvret mtv, datketapa etp
 where srv.atdsrvnum = ret.atdsrvnum
   and srv.atdsrvano = ret.atdsrvano
   and mtv.srvretmtvcod = ret.srvretmtvcod
   and srv.atdetpcod = etp.atdetpcod
   and srv.atdsrvorg = 9
   and srv.atddat between param.data_ini and param.data_fim

   whenever error continue
      let l_comando = "gzip -f ", m_path

      let param.data_ini = today
      run l_comando
      let m_path = m_path clipped, ".gz"
     
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
      
      #let l_comando = ' echo "','Servicos de Retorno' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','Servicos de Retorno ', param.data_ini, '-', param.data_fim, ' " ',
      #                ' -f    ',m_path clipped

      #run l_comando returning l_retorno
        
      let lr_mail.ass = "Servicos de Retorno ", param.data_ini, "-", param.data_fim     
      let lr_mail.msg = "Servicos de Retorno" 
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = m_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                
      ### RODOLFO MASSINI - FIM       

      #call ctb31m00_mail(param.email, l_path, "Servicos Assunto IRE")

      let l_comando = "rm ", m_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function
#-------------------------------------#
function ctb31m00_agenda(param)
#-------------------------------------#


   define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
   end record

   define m_path         char (500)
         ,m_data         date
         ,m_data_inicio  date
         ,m_data_fim     date
         ,m_hora         datetime hour to minute
         ,m_current      datetime hour to second

   define l_query char(1500)

   define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint
         
   ### RODOLFO MASSINI - INICIO 
   #---> Variaves para:
   #     remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
   define lr_mail record       
          rem char(50),        
          des char(250),       
          ccp char(250),       
          cco char(250),       
          ass char(500),       
          msg char(32000),     
          idr char(20),        
          tip char(4)          
   end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null
 
   ### RODOLFO MASSINI - FIM 

   let m_path = './agenda.csv'
   unload to m_path
   select reg.rgldat, reg.rglhor,reg.cidcod, cid.cidnom, cid.ufdcod
        ,reg.atdsrvorg, reg.srvrglcod, grp.socntzgrpdes
        ,reg.cotqtd, reg.utlqtd
    from datmsrvrgl reg, glakcid cid, datksocntzgrp grp
   where reg.cidcod = cid.cidcod
     and grp.socntzgrpcod = reg.srvrglcod
     and reg.rgldat between param.data_ini and param.data_fim
  order by reg.cidcod,  reg.atdsrvorg, reg.srvrglcod, reg.rgldat, reg.rglhor

   whenever error continue
      let l_comando = "gzip -f ", m_path

      let param.data_ini = today
      run l_comando
      let m_path = m_path clipped, ".gz"
    
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
            
      #let l_comando = ' echo "','Agenda' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','Agenda do dia ',  param.data_ini, '-', param.data_fim,  ' " ',
      #                ' -f    ',m_path clipped
      
      #run l_comando returning l_retorno     
  
      let lr_mail.ass = "Agenda do dia ",  param.data_ini, "-", param.data_fim     
      let lr_mail.msg = "Agenda"   
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = m_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                   
      ### RODOLFO MASSINI - FIM 

      #call ctb31m00_mail(param.email, l_path, "Servicos Assunto IRE")

      let l_comando = "rm ", m_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function

#-------------------------------------#
function ctb31m00_sms(param)
#-------------------------------------#


   define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
   end record

   define m_path         char (500)
         ,m_data         date
         ,m_data_inicio  date
         ,m_data_fim     date
         ,m_hora         datetime hour to minute
         ,m_current      datetime hour to second

   define l_query char(1500)

   define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint
         ,l_dtinicial char(19)
         ,l_dtfinal char(19)

   define l_data record
          dia char(2)
         ,mes char(2)
         ,ano char(4)
   end record
         
   ### RODOLFO MASSINI - INICIO 
   #---> Variaves para:
   #     remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
  
   define lr_mail record       
          rem char(50),        
          des char(250),       
          ccp char(250),       
          cco char(250),       
          ass char(500),       
          msg char(32000),     
          idr char(20),        
          tip char(4)          
   end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null

 let l_data.ano = year(param.data_ini) 
 let l_data.mes = month(param.data_ini) 
 let l_data.dia = day(param.data_ini) 
 let l_dtinicial = l_data.ano clipped, '-',
                   l_data.mes clipped, '-',
                   l_data.dia clipped, ' 00:00:00'

  initialize l_data to null

 let l_data.ano = year(param.data_fim)
 let l_data.mes = month(param.data_fim)
 let l_data.dia = day(param.data_fim)
 let l_dtfinal = l_data.ano clipped, '-',
                 l_data.mes clipped, '-',
                 l_data.dia clipped, ' 23:59:59'
 
   ### RODOLFO MASSINI - FIM 

   let m_path = './sms.csv'
   unload to m_path

   select smsenvcod, msgtxt, envdat
   from dbsmenvmsgsms
   where envdat between l_dtinicial and l_dtfinal

   whenever error continue
      let l_comando = "gzip -f ", m_path

      let param.data_ini = today
      run l_comando
      let m_path = m_path clipped, ".gz"
      
      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
      
      #let l_comando = ' echo "','SMS' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','SMS Enviados ',  param.data_ini, '-', param.data_fim,  ' " ',
      #                ' -f    ',m_path clipped

      #run l_comando returning l_retorno
  
      let lr_mail.ass = "SMS Enviados ",  param.data_ini, "-", param.data_fim      
      let lr_mail.msg = "SMS"  
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = m_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                
      ### RODOLFO MASSINI - FIM

      #call ctb31m00_mail(param.email, l_path, "Servicos Assunto IRE")

      let l_comando = "rm ", m_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function


#-------------------------------------#
function ctb31m00_horaComb(param)
#-------------------------------------#


   define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
   end record

   define m_path         char (500)
         ,m_data         date
         ,m_data_inicio  date
         ,m_data_fim     date
         ,m_hora         datetime hour to minute
         ,m_current      datetime hour to second

   define l_query char(1500)

   define l_data_ini date
         ,l_data_fim date
         ,l_comando  char(700)
         ,l_retorno  smallint
         ,l_retorno_email smallint
         
   ### RODOLFO MASSINI - INICIO 
   #---> Variaves para:
   #     remover (comentar) forma de envio de e-mails anterior e inserir
   #     novo componente para envio de e-mails.
   #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
   define lr_mail record       
          rem char(50),        
          des char(250),       
          ccp char(250),       
          cco char(250),       
          ass char(500),       
          msg char(32000),     
          idr char(20),        
          tip char(4)          
   end record 
 
  define lr_anexo record
         anexo1  char (300),
         anexo2  char (300),
         anexo3  char (300)
  end record
           
  initialize lr_mail
            ,lr_anexo
            ,l_retorno_email
  to null
 
   ### RODOLFO MASSINI - FIM 
  
   let m_path = './hrcombinada.csv'
   unload to m_path

      select acp.atdsrvnum, acp.atdsrvano, acp.atdetpcod, acp.envtipcod
            ,srv.srvcbnhor, srv.prslocflg, sre.socntzcod, ntz.socntzdes
            ,lcl.dddcod, lcl.lcltelnum, lcl.celteldddcod, lcl.celtelnum 
        from datmsrvacp acp, datmservico srv
            ,datmsrvre  sre, datmlcl     lcl
            ,datksocntz ntz
       where acp.atdsrvnum = srv.atdsrvnum
         and acp.atdsrvano = srv.atdsrvano
         and srv.atdsrvnum = sre.atdsrvnum
         and srv.atdsrvano = sre.atdsrvano
         and srv.atdsrvnum = lcl.atdsrvnum
         and srv.atdsrvano = lcl.atdsrvano
         and sre.socntzcod = ntz.socntzcod
         and lcl.c24endtip = 1
         and acp.atdetpcod = 3
         and srv.atdsrvorg = 9
         and acp.atdsrvseq = srv.atdsrvseq
         and acp.atdetpdat between param.data_ini and param.data_fim

   whenever error continue
      let l_comando = "gzip -f ", m_path

      let param.data_ini = today
      run l_comando
      let m_path = m_path clipped, ".gz"

      ### RODOLFO MASSINI - INICIO 
      #---> remover (comentar) forma de envio de e-mails anterior e inserir
      #     novo componente para envio de e-mails.
      #---> feito por Rodolfo Massini (F0113761) em maio/2013
      
      #let l_comando = ' echo "','DATA E HORA COMBINADA' clipped, '" | send_email.sh ',
      #                ' -a    ',param.email clipped,
      #                ' -s   "','DATA E HORA COMBINADA ',  param.data_ini, '-', param.data_fim,  ' " ',
      #                ' -f    ',m_path clipped

      #run l_comando returning l_retorno
  
      let lr_mail.ass = "DATA E HORA COMBINADA ",  param.data_ini, "-", param.data_fim    
      let lr_mail.msg = "DATA E HORA COMBINADA"   
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = m_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                 
      ### RODOLFO MASSINI - FIM 

      #call ctb31m00_mail(param.email, l_path, "Servicos Assunto IRE")

      let l_comando = "rm ", m_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function



#Franzon

#-------------------------------------#
function ctb31m00_cX_itau_pg(param)
#-------------------------------------#

define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
end record

define l_now datetime year to second,
       l_path char(100),
       l_query char(500),
       l_count integer

define l_data_ini date
      ,l_data_fim date
      ,l_comando  char(700)
      ,l_retorno  smallint
      ,l_retorno_email smallint
      
define lr_mail record       
       rem char(50),        
       des char(250),       
       ccp char(250),       
       cco char(250),       
       ass char(500),       
       msg char(32000),     
       idr char(20),        
       tip char(4)          
end record 
 
define lr_anexo record
       anexo1  char (300),
       anexo2  char (300),
       anexo3  char (300)
end record
           
   initialize lr_mail
             ,lr_anexo
             ,l_retorno_email
   to null
 

   set isolation to dirty read
   initialize mr_cX_itau_pg.* to null
   let l_count = 0

   let l_path = './cX_itau_pg.xls'
   
# -- selecao principal

   let l_query = "select cpm.atdsrvnum "
                ,"      ,cpm.atdsrvano "
                ,"      ,cpm.locprgflg "
                ,"      ,opg.socopgnum "
                ,"      ,opg.socfatpgtdat "
                ,"      ,itm.c24utidiaqtd "
                ,"      ,itm.c24pagdiaqtd "
                ,"      ,itm.socopgitmvlr "
                ,"  from  "
                ,"       datrvcllocrsrcmp cpm  "    
                ,"      ,dbsmopg opg  "                
                ,"      ,dbsmopgitm itm  "            
                ," where cpm.atdsrvnum = itm.atdsrvnum "
                ," and   cpm.atdsrvano = itm.atdsrvano "
                ," and   itm.socopgnum = opg.socopgnum "
                ," and   opg.socfatpgtdat between ? and ? "
                ," and   socopgsitcod  = 7 "

   prepare p_cX_itau_pg01 from l_query
   declare c_cX_itau_pg01 cursor for p_cX_itau_pg01
   
#-- selecao dos motivos
   let l_query  =  " select itarsrcaomtvcod  "
                  ,"       ,rsrprvdiaqtd "
                  ,"   from datrvcllocrsrcmp " 
                  ,"  where atdsrvnum  = ? "
                  ,"    and atdsrvano  = ? "
   prepare p_cX_itau_pg02 from l_query
   declare c_cX_itau_pg02 cursor for p_cX_itau_pg02

# -- movimento de alugueis
   let l_query  =  " select lcvcod , aviestcod , avivclcod ,aviprvent "
                  ,"   from datmavisrent " 
                  ,"  where atdsrvnum = ? "
                  ,"    and atdsrvano = ? "
   prepare p_cX_itau_pg03 from l_query
   declare c_cX_itau_pg03 cursor for p_cX_itau_pg03


# -- cod locadora e nome locadora
   let l_query   = " select lcvnom       ",
                   "   from datklocadora ",
                   "  where lcvcod = ?   "
   prepare p_cX_itau_pg04   from l_query
   declare c_cX_itau_pg04 cursor for  p_cX_itau_pg04

# -- cod loja e nome loja
   let l_query = " select lcvregprccod , endufd , endcid "
                ,"       ,lcvextcod    , aviestnom       "
                ,"   from datkavislocal        "
                ,"  where lcvcod = ? "
                ,"    and aviestcod = ?"
   prepare p_cX_itau_pg05   from l_query
   declare c_cX_itau_pg05 cursor for  p_cX_itau_pg05

# -- dados da apolice
   let l_query = " select datrservapol.succod   , datrservapol.aplnumdig "
                ,"       ,datrservapol.itmnumdig, datrservapol.edsnumref "
                ,"       ,datrservapol.ramcod "
                ,"   from datrservapol "
                ,"  where atdsrvnum = ? "
                ,"    and atdsrvano = ? "
   prepare p_cX_itau_pg06   from l_query
   declare c_cX_itau_pg06 cursor for  p_cX_itau_pg06

# -- dados data de servico
   let l_query = " select atddat "
                ,"   from datmservico"
                ,"  where atdsrvnum = ? "
                ,"    and atdsrvano = ? "
   prepare p_cX_itau_pg07   from l_query
   declare c_cX_itau_pg07 cursor for  p_cX_itau_pg07

# -- Dados do usuario (segurado)
    let l_query = " select segnom "
                 ,"   from datmitaapl "
                 ,"  where itaciacod = 33 "
                 ,"    and itaramcod = ? "
                 ,"    and itaaplnum = ? "
                 ,"    and aplseqnum = ? "
   prepare p_cX_itau_pg08   from l_query
   declare c_cX_itau_pg08 cursor for  p_cX_itau_pg08

# -- dados do grupo do veiculo
    let l_query = " select avivclgrp "
                 ,"   from datkavisveic "
                 ,"  where lcvcod = ? "
                 ,"    and avivclcod = ? "
   prepare p_cX_itau_pg09   from l_query
   declare c_cX_itau_pg09 cursor for  p_cX_itau_pg09

# --  etapa 
    let l_query = " select a.atdetpcod  , atdetpdes c "
                 ,"   from datmsrvacp a , datketapa c "
                 ,"  where atdsrvnum = ? "
                 ,"    and atdsrvano = ? "
                 ,"    and atdsrvseq = (select max(atdsrvseq) "
                 ,"                       from datmsrvacp b  "
                 ,"                      where b.atdsrvnum = a.atdsrvnum "
                 ,"                        and b.atdsrvano = a.atdsrvano )"
                 ,"    and c.atdetpcod = a.atdetpcod "
                 
   prepare p_cX_itau_pg10   from l_query
   declare c_cX_itau_pg10 cursor for  p_cX_itau_pg10

   let l_query  = "select empsgl    ",
                  "  from datmservico a, ",
                  "       gabkemp b",
                  " where a.atdsrvnum = ? ",
                  "   and a.atdsrvano = ? ",
                  "   and a.ciaempcod = b.empcod"
   prepare p_cX_itau_pg11   from l_query
   declare c_cX_itau_pg11 cursor for  p_cX_itau_pg11

   let l_query = " select sum(aviprodiaqtd) ",
                 "   from datmprorrog       ",
                 "  where atdsrvnum = ?     ",
                 "    and atdsrvano = ?     ",
                 "    and aviprostt = 'A'   "
   prepare p_cX_itau_pg12   from l_query
   declare c_cX_itau_pg12 cursor for  p_cX_itau_pg12


   start report report_cx_itau_pg to l_path

   let l_now = current

   open c_cX_itau_pg01 using param.data_ini  
                            ,param.data_fim
   #---------------------------------------------------------------
   # Cursor principal CARRO EXTRA PAGO ITAU
   #---------------------------------------------------------------

   foreach c_cX_itau_pg01 into mr_cX_itau_pg.atdsrvnum  
                              ,mr_cX_itau_pg.atdsrvano  
                              ,mr_cX_itau_pg.locprgflg  
                              ,mr_cX_itau_pg.socopgnum  
                              ,mr_cX_itau_pg.socfatpgtdat   
                              ,mr_cX_itau_pg.c24utidiaqtd
                              ,mr_cX_itau_pg.c24pagdiaqtd
                              ,mr_cX_itau_pg.socopgitmvlr

         open c_cX_itau_pg03 using mr_cX_itau_pg.atdsrvnum
                                  ,mr_cX_itau_pg.atdsrvano

         fetch c_cX_itau_pg03 into mr_cx_itau_pg.lcvcod
                                  ,mr_cx_itau_pg.aviestcod
                                  ,mr_cx_itau_pg.avivclcod
                                  ,mr_cx_itau_pg.aviprvent
         close c_cX_itau_pg03
         
         open c_cX_itau_pg04 using mr_cx_itau_pg.lcvcod

         fetch c_cX_itau_pg04 into mr_cx_itau_pg.lcvnom

         close c_cX_itau_pg04


         open c_cX_itau_pg05 using mr_cx_itau_pg.lcvcod
                                  ,mr_cx_itau_pg.aviestcod

         fetch c_cX_itau_pg05 into mr_cx_itau_pg.lcvregprccod
                                  ,mr_cx_itau_pg.endufd
                                  ,mr_cx_itau_pg.endcid
                                  ,mr_cx_itau_pg.lcvextcod
                                  ,mr_cx_itau_pg.aviestnom
               case mr_cx_itau_pg.lcvregprccod
                    when 1    let mr_cx_itau_pg.lcvregprcdes = "PADRAO     "
                    when 2    let mr_cx_itau_pg.lcvregprcdes = "REGIAO II  "
                    when 3    let mr_cx_itau_pg.lcvregprcdes = "** LIVRE **"
                    otherwise let mr_cx_itau_pg.lcvregprcdes = "NAO CADASTRADA"
               end case
         close c_cX_itau_pg05


         open c_cX_itau_pg06 using mr_cX_itau_pg.atdsrvnum
                                  ,mr_cX_itau_pg.atdsrvano  
         fetch c_cX_itau_pg06 into mr_cX_itau_pg.succod
                                  ,mr_cX_itau_pg.aplnumdig
                                  ,mr_cX_itau_pg.itmnumdig
                                  ,mr_cX_itau_pg.edsnumref
                                  ,mr_cX_itau_pg.ramcod    
         close c_cX_itau_pg06

 
         open c_cX_itau_pg07 using mr_cX_itau_pg.atdsrvnum
                                  ,mr_cX_itau_pg.atdsrvano
         fetch c_cX_itau_pg07 into mr_cX_itau_pg.atddat
         close c_cX_itau_pg07

     
         open c_cX_itau_pg08 using mr_cX_itau_pg.ramcod
                                  ,mr_cX_itau_pg.aplnumdig
                                  ,mr_cX_itau_pg.itmnumdig
         fetch c_cX_itau_pg08 into mr_cX_itau_pg.segnom
         close c_cX_itau_pg08

         open c_cX_itau_pg09 using mr_cX_itau_pg.lcvcod
                                  ,mr_cX_itau_pg.avivclcod
         fetch c_cX_itau_pg09 into mr_cX_itau_pg.avivclgrp
         close c_cX_itau_pg09


         open c_cX_itau_pg10 using mr_cX_itau_pg.atdsrvnum
                                  ,mr_cX_itau_pg.atdsrvano
         
         fetch c_cX_itau_pg10 into mr_cx_itau_pg.atdetpcod
                                  ,mr_cx_itau_pg.atdetpdes 
         close c_cX_itau_pg10

         #--------------------------------------------------------
         # Dados Empresa
         #--------------------------------------------------------
         open c_cX_itau_pg11 using mr_cX_itau_pg.atdsrvnum 
                                  ,mr_cX_itau_pg.atdsrvano
         fetch c_cX_itau_pg11 into mr_cX_itau_pg.empsgl
               if sqlca.sqlcode = notfound  then
                  let mr_cX_itau_pg.empsgl = "-"
               end if
         close c_cX_itau_pg11

         #--------------------------------------------------------
         # Quantidade de prorrogacoes / somatoria das reservas
         #--------------------------------------------------------
  
         let mr_cX_itau_pg.aviprodiaqtd = 0 

         open c_cX_itau_pg12 using mr_cX_itau_pg.atdsrvnum
                                  ,mr_cX_itau_pg.atdsrvano
         fetch c_cX_itau_pg12 into mr_cX_itau_pg.aviprodiaqtd
         close c_cX_itau_pg12

         if mr_cX_itau_pg.aviprodiaqtd is not null  then
            let mr_cX_itau_pg.aviprvent = mr_cX_itau_pg.aviprvent + 
                                          mr_cX_itau_pg.aviprodiaqtd
         end if

         #--------------------------------------------------------
         # Identificacao de motivos 
         #--------------------------------------------------------

         open c_cX_itau_pg02 using mr_cX_itau_pg.atdsrvnum
                                  ,mr_cX_itau_pg.atdsrvano
         foreach c_cX_itau_pg02 into mr_cX_itau_pg.itarsrcaomtvcod
                                    ,mr_cX_itau_pg.rsrprvdiaqtd
                 case mr_cX_itau_pg.itarsrcaomtvcod
                     when 1 let mr_cX_itau_pg.mot01 = mr_cX_itau_pg.rsrprvdiaqtd
                     when 2 let mr_cX_itau_pg.mot02 = mr_cX_itau_pg.rsrprvdiaqtd
                     when 3 let mr_cX_itau_pg.mot03 = mr_cX_itau_pg.rsrprvdiaqtd
                     when 4 let mr_cX_itau_pg.mot04 = mr_cX_itau_pg.rsrprvdiaqtd
                     when 5 let mr_cX_itau_pg.mot05 = mr_cX_itau_pg.rsrprvdiaqtd
                     when 6 let mr_cX_itau_pg.mot06 = mr_cX_itau_pg.rsrprvdiaqtd
                     when 7 let mr_cX_itau_pg.mot07 = mr_cX_itau_pg.rsrprvdiaqtd
                     when 8 let mr_cX_itau_pg.mot08 = mr_cX_itau_pg.rsrprvdiaqtd
                     otherwise let mr_cX_itau_pg.motout = mr_cX_itau_pg.rsrprvdiaqtd
                 end case
         end foreach


         #--------------------------------------------------------
         # monta codlocadora + caoloja
         #--------------------------------------------------------

         let  mr_cx_itau_pg.codlocCodloj = mr_cx_itau_pg.lcvcod , '-'
                                          ,mr_cx_itau_pg.lcvextcod

         #--------------------------------------------------------
         # monta mes-ano pagamento
         #--------------------------------------------------------

         case month(mr_cx_itau_pg.socfatpgtdat)
              when 01 let mr_cx_itau_pg.mespagto = 'Jan-'  
              when 02 let mr_cx_itau_pg.mespagto = 'Fev-'
              when 03 let mr_cx_itau_pg.mespagto = 'Mar-'
              when 04 let mr_cx_itau_pg.mespagto = 'Abr-'
              when 05 let mr_cx_itau_pg.mespagto = 'Mai-'
              when 06 let mr_cx_itau_pg.mespagto = 'Jun-'
              when 07 let mr_cx_itau_pg.mespagto = 'Jul-'
              when 08 let mr_cx_itau_pg.mespagto = 'Ago-'
              when 09 let mr_cx_itau_pg.mespagto = 'Set-'
              when 10 let mr_cx_itau_pg.mespagto = 'Out-'
              when 11 let mr_cx_itau_pg.mespagto = 'Nov-'
              when 12 let mr_cx_itau_pg.mespagto = 'Dez-'
         end case   
             
         let mr_cx_itau_pg.mesanopgto = mr_cx_itau_pg.mespagto clipped
                                       ,year(mr_cx_itau_pg.socfatpgtdat)

         output to report report_cx_itau_pg()
         initialize mr_cx_itau_pg.* to null


   end foreach

   finish report report_cx_itau_pg

   let l_now = current


   whenever error continue
      let l_comando = "gzip -f ", l_path


      run l_comando
      let l_path = l_path clipped, ".gz"
      
      
      let lr_mail.ass = "CARRO EXTRA ITAU PAGO", param.data_ini, "-", param.data_fim
      let lr_mail.msg = "CARRO EXTRA ITAU PAGO"     
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = l_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                

      let l_comando = "rm ", l_path clipped
      run l_comando returning l_retorno
   whenever error stop

      
end function

#
#-------------------------------------#
report report_cx_itau_pg()
#-------------------------------------#
output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "ANO_N_RESERVA"           ,ascii(09),
              "COD_LOCADORA"            ,ascii(09),
              "NOME_LOCADORA"           ,ascii(09),
              "COD_LOJA"                ,ascii(09),
              "NOME_LOJA"               ,ascii(09),
              "EMPRESA"                 ,ascii(09),
              "SUCURSAL"                ,ascii(09),
              "APOLICE"                 ,ascii(09),
              "ITEM"                    ,ascii(09),
              "DATA"                    ,ascii(09),
              "USUARIO"                 ,ascii(09),
              "GRUPO"                   ,ascii(09),
              "PREV_UTIL"               ,ascii(09),
              "SOMA_PRORROG"            ,ascii(09),
              "DIAR_UTL"                ,ascii(09),
              "DIAR_PAG"                ,ascii(09),
              "VALOR"                   ,ascii(09),
              "ETAPA"                   ,ascii(09),
              "DATA_PAGAMENTO"          ,ascii(09),
              "COD_LOC+COD_LOJA"        ,ascii(09),
              "TARIFA"                  ,ascii(09),
              "UF"                      ,ascii(09),
              "CIDADE"                  ,ascii(09),
              "CORRENTISTA"             ,ascii(09),
              "COBERTURA_CONTRATADA_PP" ,ascii(09),
              "COBERTURA_CONTRATADA_II" ,ascii(09),
              "BENEFICIO-CAR/OFIC"      ,ascii(09),
              "CENTRO_DE_CUSTO"         ,ascii(09),
              "REVERSIVEL"              ,ascii(09),
              "COBERTURA_CONTRATADA"    ,ascii(09),
              "LIVRE_UTILIZACAO"        ,ascii(09),
              "OUTROS_MOTIVOS"

     on every row
        print mr_cx_itau_pg.atdsrvano clipped  ,"-" 
             ,mr_cx_itau_pg.atdsrvnum clipped  ,ascii(09) 
             ,mr_cx_itau_pg.lcvcod      ,ascii(09)
             ,mr_cx_itau_pg.lcvnom      ,ascii(09)
             ,mr_cx_itau_pg.lcvextcod   ,ascii(09)
             ,mr_cx_itau_pg.aviestnom   ,ascii(09)
             ,mr_cx_itau_pg.empsgl      ,ascii(09)
             ,mr_cx_itau_pg.succod      ,ascii(09)
             ,mr_cx_itau_pg.aplnumdig   ,ascii(09)
             ,mr_cx_itau_pg.itmnumdig   ,ascii(09)
             ,mr_cx_itau_pg.atddat      ,ascii(09)
             ,mr_cx_itau_pg.segnom      ,ascii(09)
             ,mr_cx_itau_pg.avivclgrp   ,ascii(09)
             ,mr_cx_itau_pg.aviprvent   ,ascii(09)
             ,mr_cx_itau_pg.rsrprvdiaqtd,ascii(09)
             ,mr_cx_itau_pg.c24utidiaqtd,ascii(09)
             ,mr_cx_itau_pg.c24pagdiaqtd,ascii(09)
             ,mr_cx_itau_pg.socopgitmvlr,ascii(09)
             ,mr_cx_itau_pg.atdetpdes   ,ascii(09)
             ,mr_cx_itau_pg.mesanopgto  ,ascii(09)
             ,mr_cx_itau_pg.codlocCodloj,ascii(09)
             ,mr_cx_itau_pg.lcvregprcdes,ascii(09)
             ,mr_cx_itau_pg.endufd      ,ascii(09)
             ,mr_cx_itau_pg.endcid      ,ascii(09)
             ,mr_cx_itau_pg.mot01       ,ascii(09)
             ,mr_cx_itau_pg.mot02       ,ascii(09)
             ,mr_cx_itau_pg.mot03       ,ascii(09)
             ,mr_cx_itau_pg.mot04       ,ascii(09)
             ,mr_cx_itau_pg.mot05       ,ascii(09)
             ,mr_cx_itau_pg.mot06       ,ascii(09)
             ,mr_cx_itau_pg.mot07       ,ascii(09)
             ,mr_cx_itau_pg.mot08       ,ascii(09)
             ,mr_cx_itau_pg.motout 

end report

#-----------------------------------
function ctb31m00_sEm_documento(param)
#-----------------------------------

define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
end record

define l_now datetime year to second,
       l_path char(100),
       l_query char(1500),
       l_count integer

define l_data_ini date
      ,l_data_fim date
      ,l_comando  char(700)
      ,l_retorno  smallint
      ,l_retorno_email smallint
      
define lr_mail record       
       rem char(50),        
       des char(250),       
       ccp char(250),       
       cco char(250),       
       ass char(500),       
       msg char(32000),     
       idr char(20),        
       tip char(4)          
end record 
 
define lr_anexo record
       anexo1  char (300),
       anexo2  char (300),
       anexo3  char (300)
end record
           
   initialize lr_mail
             ,lr_anexo
             ,l_retorno_email
   to null
 

   set isolation to dirty read
   initialize mr_sem_docto.* to null
   let l_count = 0

   let l_path = './sEm_documento.xls'

   let l_query = " select srv.atdsrvorg  "   
                ,"       ,srv.atdsrvnum  "
                ,"       ,srv.atdsrvano  "                    
                ,"       ,srv.atdetpcod  "
                ,"       ,srv.atddat     "
                ,"       ,srv.pgtdat     "                           
                ,"       ,srv.asitipcod  "
                ,"       ,srv.vcllicnum  "
                ,"       ,lig.c24astcod  "
                ,"       ,atd.ramcod     "
                ,"       ,atd.cgccpfnum  "
                ,"       ,atd.cgcord     "
                ,"       ,atd.cgccpfdig  "                                  
                ,"   from datmservico srv"
                ,"       ,datmligacao lig"
                ,"       ,datmatd6523 atd"
                ,"       ,datratdlig rel "
                ,"  where srv.atdsrvnum = lig.atdsrvnum      "   
                ,"    and srv.atdsrvano = lig.atdsrvano      "             
                ,"    and rel.lignum    = lig.lignum         "
                ,"    and rel.atdnum    = atd.atdnum         "   
                ,"    and lig.lignum    = (select min(lignum)"
                                         ,"  from datmligacao li      "
                                         ," where li.atdsrvnum = srv.atdsrvnum "
                                         ,"   and li.atdsrvano = srv.atdsrvano "
                                         ,"   and atd.semdcto = 'S'            "
                                         ,"   and srv.ciaempcod = 84           "
                                         ,"   and lig.ligdat  between ? and ? )"
   prepare p_sem_docto01   from l_query
   declare c_sem_docto01 cursor for  p_sem_docto01
   
#-- tipo de servico - desc abv tipo servico


    let l_query = " select srvtipabvdes  "
                 ,"   from datksrvtip      "
                 ,"  where atdsrvorg =  ? "
   prepare p_sem_docto02   from l_query
   declare c_sem_docto02 cursor for  p_sem_docto02

   # des tipo assistencia abv 

    let l_query = " select asitipabvdes "
                 ,"   from datkasitip     "
                 ,"  where asitipcod =  ?"
   prepare p_sem_docto03   from l_query
   declare c_sem_docto03 cursor for  p_sem_docto03

 # natureza da ocorrencia 

   let l_query = " select datmsrvre.sinntzcod  "
                ,"       ,datmsrvre.socntzcod  "
                ,"   from datmsrvre            "
                ,"  where datmsrvre.atdsrvnum =  ? "
                ,"    and datmsrvre.atdsrvano =  ? "
   prepare p_sem_docto04   from l_query
   declare c_sem_docto04 cursor for  p_sem_docto04

   let l_query  = " select sinntzdes  "
                 ,"   from sgaknatur  "
                 ,"  where sinramgrp = '4'  "
                 ,"    and sinntzcod =  ? "
   prepare p_sem_docto05   from l_query
   declare c_sem_docto05 cursor for  p_sem_docto05


   let l_query = " select socntzdes      "
                ,"   from datksocntz     "
                ,"  where socntzcod =  ? "
   prepare p_sem_docto06   from l_query
   declare c_sem_docto06 cursor for  p_sem_docto05

# -- problema 

   let l_query = " select a.c24pbmcod, b.c24pbmdes "
                ,"   from datrsrvpbm a,datkpbm b "
                ,"  where a.c24pbmcod = b.c24pbmcod "
                ,"    and a.atdsrvnum = ? "
                ,"    and a.atdsrvano = ? "
   prepare p_sem_docto07   from l_query
   declare c_sem_docto07 cursor for  p_sem_docto07

# -- etapa 
   let l_query = " select atdetpdes "
                ,"   from datketapa  "
                ,"  where atdetpcod = ? "
   prepare p_sem_docto08 from l_query
   declare c_sem_docto08 cursor for p_sem_docto08

# -- custo servico real  mes / ano pagamanto
   let l_query = " select b.socopgitmvlr , month(c.socfatpgtdat) "
                ,"       ,year(c.socfatpgtdat)"
                ,"   from datmservico a,dbsmopgitm b , dbsmopg c"
                ,"  where a.atdsrvnum = b.atdsrvnum "
                ,"    and a.atdsrvano = b.atdsrvano "
                ,"    and a.atdsrvnum = ?           "
                ,"    and a.atdsrvano = ?           "
                ,"    and b.socopgnum = c.socopgnum "
   prepare p_sem_docto09 from l_query
   declare c_sem_docto09 cursor for p_sem_docto09


#-- assunto 

   let l_query = " select c24astdes "
                ,"   from datkassunto "
                ,"  where c24astcod = ? " 
   prepare p_sem_docto10 from l_query
   declare c_sem_docto10 cursor for p_sem_docto10

   start report report_sem_docto to l_path

   let l_now = current

   open c_sem_docto01 using param.data_ini
                            ,param.data_fim
   #---------------------------------------------------------------
   # Cursor principal  Sem documento 
   #---------------------------------------------------------------

   foreach c_sem_docto01 into mr_sem_docto.atdsrvorg     
                             ,mr_sem_docto.atdsrvnum     
                             ,mr_sem_docto.atdsrvano    
                             ,mr_sem_docto.atdetpcod     
                             ,mr_sem_docto.atddat         
                             ,mr_sem_docto.pgtdat       
                             ,mr_sem_docto.asitipcod    
                             ,mr_sem_docto.vcllicnum     
                             ,mr_sem_docto.c24astcod     
                             ,mr_sem_docto.ramcod       
                             ,mr_sem_docto.cgccpfnum     
                             ,mr_sem_docto.cgcord         
                             ,mr_sem_docto.cgccpfdig   

       open c_sem_docto02 using mr_sem_docto.atdsrvorg
       fetch c_sem_docto02 into mr_sem_docto.srvtipabvdes
       close c_sem_docto02
                              
       open c_sem_docto03 using mr_sem_docto.asitipcod
       fetch c_sem_docto03 into mr_sem_docto.asitipabvdes
       close c_sem_docto03

       open c_sem_docto04 using mr_sem_docto.atdsrvnum
                               ,mr_sem_docto.atdsrvano
       fetch c_sem_docto04 into mr_sem_docto.sinntzcod
                               ,mr_sem_docto.socntzcod
       close c_sem_docto04
   
       open c_sem_docto05 using mr_sem_docto.sinntzcod
       fetch c_sem_docto05 into mr_sem_docto.sinntzdes
       close c_sem_docto05

       open c_sem_docto06  using mr_sem_docto.socntzcod
       fetch c_sem_docto06 into mr_sem_docto.socntzdes
       close c_sem_docto06

       open c_sem_docto07 using mr_sem_docto.atdsrvnum
                               ,mr_sem_docto.atdsrvano
       fetch c_sem_docto07 into mr_sem_docto.c24pbmcod
                               ,mr_sem_docto.c24pbmdes 
       close c_sem_docto07


       open c_sem_docto08 using mr_sem_docto.atdetpcod
       fetch c_sem_docto08 into mr_sem_docto.atdetpdes 
       close c_sem_docto08


       open c_sem_docto09 using mr_sem_docto.atdsrvnum
                               ,mr_sem_docto.atdsrvano
       fetch c_sem_docto09 into mr_sem_docto.socopgitmvlr
                               ,mr_sem_docto.mespagto 
                               ,mr_sem_docto.anopagto 
       
       open c_sem_docto10 using mr_sem_docto.c24astcod
       fetch c_sem_docto10 into mr_sem_docto.c24astdes
       close c_sem_docto10
       
       output to report report_sem_docto()
       initialize mr_sem_docto.* to null

   end foreach

   finish report report_sem_docto

   let l_now = current


   whenever error continue
      let l_comando = "gzip -f ", l_path


      run l_comando
      let l_path = l_path clipped, ".gz"
      
      
      let lr_mail.ass = "SEM DOCUMENTO", param.data_ini, "-", param.data_fim
      let lr_mail.msg = "SEM DOCUMENTO"             
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = l_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                

      let l_comando = "rm ", l_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function
#-------------------------------------#
report report_sem_docto()
#-------------------------------------#
output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "NUMERO_DO_SERVICO"        ,ascii(09),
              "DES_ABV_TIPO_SERVICO"     ,ascii(09),
              "DES_TIPO_ASSISTENCIA_ABV" ,ascii(09),
              "NATUREZA"                 ,ascii(09),
              "NATUREZA_DA_OCORRENCIA"   ,ascii(09),
              "PROBLEMA_APRESENTADO"     ,ascii(09),
              "DES_ETAPA_SERVICO"        ,ascii(09),
              "CUSTO_SERVICO(REAL)"      ,ascii(09),
              "MES_DO_PAGAMENTO"         ,ascii(09),
              "ANO_DO_PAGAMENTO"         ,ascii(09),
              "COD_ASSUNTO"              ,ascii(09),
              "DES_ASSUNTO"              ,ascii(09),
              "COD_ORIGEM_SERVICO"       ,ascii(09),
              "EMPRESA"                  ,ascii(09),
              "RAMO"                     ,ascii(09),
              "NUM_CPF"                  ,ascii(09),
              "ORDEM_CPF"                ,ascii(09),
              "DIGITO_CPF"               ,ascii(09),
              "PLACA"                        

     on every row
        print  mr_sem_docto.atdsrvnum clipped , ' -' 
              ,mr_sem_docto.atdsrvano   , ascii(9)  
              ,mr_sem_docto.srvtipabvdes, ascii(9)
              ,mr_sem_docto.asitipabvdes, ascii(9)
              ,mr_sem_docto.sinntzdes   , ascii(9)
              ,mr_sem_docto.socntzdes   , ascii(9)
              ,mr_sem_docto.c24pbmdes   , ascii(9)
              ,mr_sem_docto.atdetpdes   , ascii(9)
              ,mr_sem_docto.socopgitmvlr, ascii(9)
              ,mr_sem_docto.mespagto    , ascii(9)
              ,mr_sem_docto.anopagto    , ascii(9)
              ,mr_sem_docto.c24astcod   , ascii(9)
              ,mr_sem_docto.c24astdes   , ascii(9)
              ,mr_sem_docto.atdsrvorg   , ascii(9)
              ,mr_sem_docto.empciacod   , ascii(9)
              ,mr_sem_docto.ramcod      , ascii(9)
              ,mr_sem_docto.cgccpfnum   , ascii(9)
              ,mr_sem_docto.cgcord      , ascii(9)
              ,mr_sem_docto.cgccpfdig   , ascii(9)
              ,mr_sem_docto.vcllicnum   
end report

#-----------------------------------
function ctb31m00_teleFone(param)
#-----------------------------------

define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
end record

define l_now datetime year to second,
       l_path char(100),
       l_query char(500),
       l_count integer

define l_data_ini date
      ,l_data_fim date
      ,l_comando  char(700)
      ,l_retorno  smallint
      ,l_retorno_email smallint
      
define lr_mail record       
       rem char(50),        
       des char(250),       
       ccp char(250),       
       cco char(250),       
       ass char(500),       
       msg char(32000),     
       idr char(20),        
       tip char(4)          
end record 
 
define lr_anexo record
       anexo1  char (300),
       anexo2  char (300),
       anexo3  char (300)
end record
           
   initialize lr_mail
             ,lr_anexo
             ,l_retorno_email
   to null
 

   set isolation to dirty read
   initialize mr_sem_docto.* to null
   let l_count = 0

   let l_path = './telefone.xls'
   
   start report report_telefone to l_path

   let l_query = " select srv.atddat       "                               
                ,"       ,srv.atdsrvnum    "                             
                ,"       ,srv.atdsrvano    "                             
                ,"       ,lcl.dddcod       "                            
                ,"       ,lcl.lcltelnum    "                            
                ,"       ,lcl.celteldddcod "                          
                ,"       ,lcl.celtelnum    "                        
                ,"       ,lcl.lclrefptotxt "                          
                ,"   from datmservico srv, datmlcl lcl  "             
                ,"  where srv.atdsrvnum = lcl.atdsrvnum "            
                ,"    and srv.atdsrvano = lcl.atdsrvano "           
                ,"    and lcl.c24endtip = 1             " # - End de ocorrencia 
                ,"    and srv.atddat between ? and ?    "
   prepare p_telenone01 from l_query
   declare c_telenone01 cursor for p_telenone01

   open c_telenone01 using param.data_ini
                          ,param.data_fim

   foreach c_telenone01 into  mr_telefone.atddat 
                             ,mr_telefone.atdsrvnum    
                             ,mr_telefone.atdsrvano    
                             ,mr_telefone.dddcod       
                             ,mr_telefone.lcltelnum    
                             ,mr_telefone.celteldddcod 
                             ,mr_telefone.celtelnum    
                             ,mr_telefone.lclrefptotxt 

         output to report report_telefone()
         initialize mr_telefone.* to null

   end foreach

   finish report report_telefone

   let l_now = current


   whenever error continue
      let l_comando = "gzip -f ", l_path


      run l_comando
      let l_path = l_path clipped, ".gz"
      
      
      let lr_mail.ass = "TELEFONE", param.data_ini, "-", param.data_fim
      let lr_mail.msg = "TELEFONE"             
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = l_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                        ,lr_anexo.*)
      returning l_retorno_email                                        
                                                

      let l_comando = "rm ", l_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function
#-------------------------------------#
report report_telefone()
#-------------------------------------#
output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "SERVICO"          ,ascii(9),
              "ANO"              ,ascii(9),
              "DDD"              ,ascii(9),
              "TELEFONE"         ,ascii(9),
              "DDD"              ,ascii(9),
              "CELULAR"          ,ascii(9),
              "PONTO_REFERENCIA" 

     on every row
        print  mr_telefone.atdsrvnum    ,ascii(9)
              ,mr_telefone.atdsrvano    ,ascii(9)
              ,mr_telefone.dddcod       ,ascii(9)
              ,mr_telefone.lcltelnum    ,ascii(9)
              ,mr_telefone.celteldddcod ,ascii(9)
              ,mr_telefone.celtelnum    ,ascii(9)
              ,mr_telefone.lclrefptotxt 

end report

 #-----------------------------------#
  function ctb31m00_nota_fiscal(param)
 #-----------------------------------#
   
   define param record
       data_ini date
      ,data_fim date
      ,email    char(35)
   end record

   define l_now   datetime year to second
         ,l_path  char(100)
         ,l_query char(1000)
         ,l_count integer

   define l_data_ini      date
         ,l_data_fim      date
         ,l_comando       char(700)
         ,l_retorno       smallint
         ,l_retorno_email smallint
      
   define lr_mail record       
       rem char(50),        
       des char(250),       
       ccp char(250),       
       cco char(250),       
       ass char(500),       
       msg char(32000),     
       idr char(20),        
       tip char(4)          
   end record 
 
   define lr_anexo record
       anexo1  char (300),
       anexo2  char (300),
       anexo3  char (300)
   end record
           
   initialize lr_mail
             ,lr_anexo
             ,l_retorno_email to null
             
   initialize mr_dados_dbsmopg.*
             ,mr_dados_dbsmopgfav.*
             ,mr_dados_dpaksocor.*
             ,mr_dados_iddkdominio.* 
             ,mr_dados_dbsropgdsc
             ,mr_dados_dbsktipdsc    
             ,mr_dados_gabksuc.*   
             ,mr_dados_gcdkbanco.*
             ,mr_dados_gcdkbancoage.*
             ,mr_dados_fpgkpgtdst.* 
             ,mr_sem_docto.* to null          
 
   set isolation to dirty read

   let l_count  = 0
   let m_tmpcrs = current
   let l_path   = './nota_fiscal.xls'
   
   start report report_notafiscal to l_path

   let l_query = " select opg.socopgnum     "
                ,"       ,opg.socopgsitcod  "
                ,"       ,opg.empcod        "
                ,"       ,opg.pstcoddig     "
                ,"       ,opg.socfatentdat  "
                ,"       ,opg.socfatpgtdat  "
                ,"       ,opg.soctrfcod     "
                ,"       ,opg.socfatitmqtd  "
                ,"       ,opg.socfattotvlr  "
                ,"       ,opg.socfatrelqtd  "
                ,"       ,opg.infissalqvlr  "
                ,"       ,opg.socpgtdoctip  "                       
                ,"       ,opg.nfsnum        "
                ,"       ,opg.fisnotsrenum  "
                ,"       ,opg.socemsnfsdat  "
                ,"       ,opg.succod        "
                ,"       ,opg.pgtdstcod     "
                ,"       ,opg.socopgdscvlr  "
                ,"  from dbsmopg opg                   "
                ," where socfatpgtdat between ? and ?  "
   prepare p_dados01 from l_query            
   declare c_dados01 cursor for p_dados01    
 
   let l_query = " select fav.socopgfavnom   "
                ,"       ,fav.socpgtopccod   "
                ,"       ,fav.pestip         "
                ,"       ,fav.cgccpfnum      "
                ,"       ,fav.cgcord         "
                ,"       ,fav.cgccpfdig      "
                ,"       ,fav.bcoctatip      "
                ,"       ,fav.bcocod         "
                ,"       ,fav.bcoagnnum      "
                ,"       ,fav.bcoagndig      "
                ,"       ,fav.bcoctanum      "
                ,"  from dbsmopgfav fav      "
                ," where fav.socopgnum = ?   "
   prepare p_dados02 from l_query            
   declare c_dados02 cursor for p_dados02    

   let l_query = " select simoptpstflg   "
                ,"   from dpaksocor      "
                ,"  where pstcoddig = ?  "
   prepare p_dados03 from l_query            
   declare c_dados03 cursor for p_dados03    
                  
   let l_query = " select cpodes                  "
                ,"   from iddkdominio             "
                ,"  where cponom = 'socopgsitcod' "
                ,"    and cpocod = ?              "
   prepare p_dados04 from l_query            
   declare c_dados04 cursor for p_dados04   
   
   let l_query = " select cpodes                    "
                ,"    from iddkdominio              "
                ,"   where cponom = 'socpgtdoctip'  "
                ,"     and cpocod = ?               "
   prepare p_dados05 from l_query            
   declare c_dados05 cursor for p_dados05    
   
   let l_query = " select sucnom       "
                ,"    from gabksuc     "
                ,"   where succod = ?  "
   prepare p_dados06 from l_query            
   declare c_dados06 cursor for p_dados06    
   
   let l_query = " select bcoagnnom       "
                ,"    from gcdkbancoage   "
                ,"   where bcocod    = ?  "
                ,"     and bcoagnnum = ?  "
   prepare p_dados08 from l_query            
   declare c_dados08 cursor for p_dados08    
   
   let l_query = " select pgtdstdes      "                
                ,"   from fpgkpgtdst     "
                ,"  where pgtdstcod = ?  "
   prepare p_dados09 from l_query            
   declare c_dados09 cursor for p_dados09    
                                           
   let l_query = " select bcosgl       "    
                ,"    from gcdkbanco   "                                                
                ,"   where bcocod = ?  "                                                   
   prepare p_dados07 from l_query                                                         
   declare c_dados07 cursor for p_dados07       
   
   let l_query = " select dsctipcod "
                ,"       ,dscvlr    "
                ,"       ,dscvlrobs "
                ,"    from dbsropgdsc    "
                ,"   where socopgnum = ? "
   prepare p_dados11 from l_query                                                         
   declare c_dados11 cursor for p_dados11  
   
   let l_query = " select sum(dscvlr)    "
                ,"    from dbsropgdsc    "
                ,"   where socopgnum = ? "
   prepare p_dados10 from l_query            
   declare c_dados10 cursor for p_dados10  
  
   let l_query = " select dsctipcod      "
                ,"       ,dsctipdes      "
                ,"    from dbsktipdsc    "                                                
                ,"   where dsctipcod = ? "                                                
   prepare p_dados12 from l_query                                                         
   declare c_dados12 cursor for p_dados12                                              
                                            
   open c_dados01 using param.data_ini
                       ,param.data_fim
   
   whenever error continue
   foreach c_dados01 into  mr_dados_dbsmopg.socopgnum   
                          ,mr_dados_dbsmopg.socopgsitcod
                          ,mr_dados_dbsmopg.empcod      
                          ,mr_dados_dbsmopg.pstcoddig   
                          ,mr_dados_dbsmopg.socfatentdat
                          ,mr_dados_dbsmopg.socfatpgtdat
                          ,mr_dados_dbsmopg.soctrfcod   
                          ,mr_dados_dbsmopg.socfatitmqtd
                          ,mr_dados_dbsmopg.socfattotvlr
                          ,mr_dados_dbsmopg.socfatrelqtd
                          ,mr_dados_dbsmopg.infissalqvlr
                          ,mr_dados_dbsmopg.socpgtdoctip
                          ,mr_dados_dbsmopg.nfsnum      
                          ,mr_dados_dbsmopg.fisnotsrenum
                          ,mr_dados_dbsmopg.socemsnfsdat
                          ,mr_dados_dbsmopg.succod      
                          ,mr_dados_dbsmopg.pgtdstcod   
                          ,mr_dados_dbsmopg.socopgdscvlr
   whenever error stop
   if sqlca.sqlcode < 0 then
      display 'Erro ao acessar a tabela dbsktipdsc ', sqlca.sqlcode 
   end if  

      open c_dados02 using  mr_dados_dbsmopg.socopgnum
      
         whenever error continue
         fetch c_dados02 into  mr_dados_dbsmopgfav.socopgfavnom 
                              ,mr_dados_dbsmopgfav.socpgtopccod 
                              ,mr_dados_dbsmopgfav.pestip       
                              ,mr_dados_dbsmopgfav.cgccpfnum    
                              ,mr_dados_dbsmopgfav.cgcord       
                              ,mr_dados_dbsmopgfav.cgccpfdig    
                              ,mr_dados_dbsmopgfav.bcoctatip    
                              ,mr_dados_dbsmopgfav.bcocod       
                              ,mr_dados_dbsmopgfav.bcoagnnum    
                              ,mr_dados_dbsmopgfav.bcoagndig    
         whenever error stop                     
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela dbsmopgfav ', sqlca.sqlcode 
         end if 
      
      close c_dados02
      
      open c_dados03 using  mr_dados_dbsmopg.pstcoddig 
      
         whenever error continue
         fetch c_dados03 into  mr_dados_dpaksocor.simoptpstflg  
         whenever error stop
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela dpaksocor ', sqlca.sqlcode 
         end if        
      
      close c_dados03

      open c_dados04 using  mr_dados_dbsmopg.socopgsitcod
      
         whenever error continue
         fetch c_dados04 into  mr_dados_iddkdominio.socopgsitdes              
         whenever error stop
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela iddkdominio 1 - ', sqlca.sqlcode 
         end if  
      
      close c_dados04

      open c_dados05 using  mr_dados_dbsmopg.socpgtdoctip                  
      
         whenever error continue
         fetch c_dados05 into  mr_dados_iddkdominio.socpgtdocdes
         whenever error stop
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela iddkdominio 2 - ', sqlca.sqlcode 
         end if               
      
      close c_dados05

      open c_dados06 using  mr_dados_dbsmopg.succod
      
         whenever error continue
         fetch c_dados06 into  mr_dados_gabksuc.sucnom
         whenever error stop
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela gabksuc ', sqlca.sqlcode 
         end if                
      
      close c_dados06
      
      open c_dados07 using  mr_dados_dbsmopgfav.bcocod  
      
         whenever error continue
         fetch c_dados07 into  mr_dados_gcdkbanco.bcosgl
         whenever error stop
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela gcdkbanco ', sqlca.sqlcode 
         end if   
      
      close c_dados07
      
      open c_dados08 using  mr_dados_dbsmopgfav.bcocod    
                           ,mr_dados_dbsmopgfav.bcoagnnum  
         
         whenever error continue
         fetch c_dados08 into  mr_dados_gcdkbancoage.bcoagnnom
         whenever error stop
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela gcdkbancoage ', sqlca.sqlcode 
         end if                  

      close c_dados08
      
      open c_dados09 using  mr_dados_dbsmopg.pgtdstcod                    
      
         whenever error continue
         fetch c_dados09 into  mr_dados_fpgkpgtdst.pgtdstdes
         whenever error stop
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela fpgkpgtdst ', sqlca.sqlcode 
         end if               
      
      close c_dados09

      if mr_dados_dbsmopgfav.socpgtopccod = 1 then
         let mr_dados_dbsmopgfav.socpgtopcdes = 'Conta Corrente'
      else
         if mr_dados_dbsmopgfav.socpgtopccod = 2 then 
            let mr_dados_dbsmopgfav.socpgtopcdes = 'Poupanca'
         end if
      end if
   
      open c_dados10 using  mr_dados_dbsmopg.socopgnum 
      
         whenever error continue
         fetch c_dados10 into  mr_dados_dbsropgdsctt.dscvlrtotal
         whenever error stop
         if sqlca.sqlcode < 0 then
            display 'Erro ao acessar a tabela dbsropgdsc ', sqlca.sqlcode 
         end if     
      
      close c_dados10
      
      let m_indice = 0
      let m_totfor = 0
      
      whenever error continue
      select count(*)
        into m_totfor
        from dbsropgdsc
       where socopgnum = mr_dados_dbsmopg.socopgnum
      whenever error stop
      
      if m_totfor > 0 then
                
         open c_dados11 using mr_dados_dbsmopg.socopgnum
         
            whenever error continue
            foreach c_dados11 into mr_dados_dbsropgdsc.dsctipcod   
                                  ,mr_dados_dbsropgdsc.dscvlr   
                                  ,mr_dados_dbsropgdsc.dscvlrobs
            whenever error stop                      
            if sqlca.sqlcode < 0 then
               display 'Erro ao acessar a tabela dbsropgdsc ', sqlca.sqlcode 
            end if  
               
               open c_dados12 using mr_dados_dbsropgdsc.dsctipcod
                  
                  whenever error continue
                  fetch c_dados12 into mr_dados_dbsktipdsc.dsctipcod
                                      ,mr_dados_dbsktipdsc.dsctipdes
                  whenever error stop   
                  if sqlca.sqlcode <> 0 then
                     display 'Erro ao acessar a tabela dbsktipdsc ', sqlca.sqlcode 
                  end if  
                  
               close c_dados12
                  
               if m_indice > 0 then
                  if mr_dados_dbsktipdsc.dsctipcod is not null then
                     output to report report_notafiscal() 
                  else
                     exit foreach
                  end if
               else
                  output to report report_notafiscal() 
               end if
                    
               initialize mr_dados_dbsktipdsc.*
                         ,mr_dados_dbsropgdsc.* to null
                 
            end foreach
      else
         output to report report_notafiscal() 
      end if
                       
      initialize mr_dados_dbsmopg.*
                ,mr_dados_dbsmopgfav.*
                ,mr_dados_dpaksocor.*
                ,mr_dados_iddkdominio.* 
                ,mr_dados_dbsropgdsc
                ,mr_dados_dbsktipdsc
                ,mr_dados_gabksuc.*   
                ,mr_dados_gcdkbanco.*
                ,mr_dados_gcdkbancoage.*
                ,mr_dados_fpgkpgtdst.*
                ,m_indice to null
    
   end foreach

   finish report report_notafiscal
   
   let l_now = current
   
   whenever error continue
      let l_comando = "gzip -f ", l_path

      run l_comando
      let l_path = l_path clipped, ".gz"
      
      let lr_mail.ass = "NOTAFISCAL", param.data_ini, "-", param.data_fim
      let lr_mail.msg = "NOTAFISCAL"             
      let lr_mail.des = param.email clipped
      let lr_mail.tip = "text"
      let lr_anexo.anexo1 = l_path clipped
 
      call ctx22g00_envia_email_anexos(lr_mail.*
                                      ,lr_anexo.*)
      returning l_retorno_email                                        

      let l_comando = "rm ", l_path clipped
      run l_comando returning l_retorno
   whenever error stop

end function

 #---------------------------------#
 report report_notafiscal()
 #---------------------------------#

  output

  left   margin 00
  right  margin 00
  top    margin 00
  bottom margin 00
  page   length 02

  format

  first page header

  print "Numero da OP"                    , ascii(09), #Numero da OP
        "Código Situacao da OP"           , ascii(09), #Situacao 
        "Situacao da OP"                  , ascii(09), #Situacao
        "Empresa"                         , ascii(09), #Empresa    
        "Posto"                           , ascii(09), #Prestador
        "Dt. Entrega Fatura"              , ascii(09), #Data Entrega    
        "Dt. Pagamento"                   , ascii(09), #Data de Pagamento
        "Tarifa Porto Socorro"            , ascii(09), #Tarifa    
        "Qtde Itens Fatura"               , ascii(09), #Quantidade
        "Vlr Total Itens Fatura"          , ascii(09), #Valor total
        "Qtd Relacoes"                    , ascii(09), #Relacoes
        "Vlr Aliquota ISS"                , ascii(09), #Aliquota
        "Tipo Docto Pagto Porto Socorro"  , ascii(09), #Tipo Documento
        "Nota Fiscal"                     , ascii(09), #Numero Documento
        "Serie      "                     , ascii(09), #Serie NF
        "Data Emis Nota Fiscal"           , ascii(09), #Data emissao
        "Sucursal"                        , ascii(09), #Sucursal
        "Destino do Pagamento"            , ascii(09), #Destino
        "Vlr Desconto da O.P"             , ascii(09), #Valor Desconto
        "Favorecido"                      , ascii(09), #Favorecido
        "Opcao de Pagamento"              , ascii(09), #Opcao Pagamento
        "Tipo de Pessoa"                  , ascii(09), #Tipo Pessoa
        "CGC/CPF"                         , ascii(09), #CGC
        "Ordem"                           , ascii(09), #CGC
        "Digito"                          , ascii(09), #CGC
        "Tipo da Conta Bancaria"          , ascii(09), #Tipo de conta
        "Codigo do Banco"                 , ascii(09), #Banco
        "Conta bancaria"                  , ascii(09), #Conta
        "Agencia"                         , ascii(09), #Agencia
        "Agencia de pagamento"            , ascii(09), #Agencia
        "Optante pelo simples"            , ascii(09), #Optante simples
        "Tipo Docto"                      , ascii(09), #Tipo Documento
        "Nome Sucursal"                   , ascii(09), #Sucursal
        "Sigla do Banco"                  , ascii(09), #Banco
        "Nome de agencia bancaria"        , ascii(09), #Agencia
        "Destino"                         , ascii(09), #Destino
        "Opcao Pagto"                     , ascii(09), #Opcao Pagamento
        "Tipo Desconto"                   , ascii(09),
        "valor desconto"                  , ascii(09),
        "OBS Valor Desconto"              , ascii(09),
        "Descricao tipo desconto "        , ascii(09)
        
  on every row

  print mr_dados_dbsmopg.socopgnum             , ascii(09), 
        mr_dados_dbsmopg.socopgsitcod          , ascii(09),  
        mr_dados_iddkdominio.socopgsitdes      , ascii(09),
        mr_dados_dbsmopg.empcod                , ascii(09),     
        mr_dados_dbsmopg.pstcoddig             , ascii(09), 
        mr_dados_dbsmopg.socfatentdat          , ascii(09),     
        mr_dados_dbsmopg.socfatpgtdat          , ascii(09), 
        mr_dados_dbsmopg.soctrfcod             , ascii(09),     
        mr_dados_dbsmopg.socfatitmqtd          , ascii(09),
        mr_dados_dbsmopg.socfattotvlr          , ascii(09),
        mr_dados_dbsmopg.socfatrelqtd          , ascii(09),
        mr_dados_dbsmopg.infissalqvlr          , ascii(09),
        mr_dados_dbsmopg.socpgtdoctip          , ascii(09),
        mr_dados_dbsmopg.nfsnum                , ascii(09),
        mr_dados_dbsmopg.fisnotsrenum          , ascii(09),
        mr_dados_dbsmopg.socemsnfsdat          , ascii(09),
        mr_dados_dbsmopg.succod                , ascii(09),
        mr_dados_dbsmopg.pgtdstcod             , ascii(09),
        mr_dados_dbsropgdsctt.dscvlrtotal      , ascii(09),
        mr_dados_dbsmopgfav.socopgfavnom       , ascii(09),
        mr_dados_dbsmopgfav.socpgtopccod       , ascii(09),
        mr_dados_dbsmopgfav.pestip             , ascii(09),
        mr_dados_dbsmopgfav.cgccpfnum          , ascii(09),
        mr_dados_dbsmopgfav.cgcord             , ascii(09),
        mr_dados_dbsmopgfav.cgccpfdig          , ascii(09),
        mr_dados_dbsmopgfav.bcoctatip          , ascii(09),
        mr_dados_dbsmopgfav.bcocod             , ascii(09),
        mr_dados_dbsmopgfav.bcoagnnum          , ascii(09),
        mr_dados_dbsmopgfav.bcoagndig          , ascii(09),
        mr_dados_dbsmopgfav.bcoctanum          , ascii(09),
        mr_dados_dpaksocor.simoptpstflg        , ascii(09),
        mr_dados_iddkdominio.socpgtdocdes      , ascii(09),
        mr_dados_gabksuc.sucnom                , ascii(09),
        mr_dados_gcdkbanco.bcosgl              , ascii(09),
        mr_dados_gcdkbancoage.bcoagnnom        , ascii(09),
        mr_dados_fpgkpgtdst.pgtdstdes          , ascii(09),
        mr_dados_dbsmopgfav.socpgtopcdes       , ascii(09),
        mr_dados_dbsropgdsc.dsctipcod          , ascii(09),
        mr_dados_dbsropgdsc.dscvlr             , ascii(09),
        mr_dados_dbsropgdsc.dscvlrobs          , ascii(09),
        mr_dados_dbsktipdsc.dsctipdes          , ascii(09) 

end report
