#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
#.............................................................................#
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR037                                                   #
# ANALISTA RESP..: RAFAEL MOREIRA GOMES                                       #
# PSI/OSF........: Extracao TelaOP                                            #
#.............................................................................#
# DESENVOLVIMENTO: FORNAX TECNOLOGIA, RCP                                     #
# LIBERACAO......: 08/05/2015                                                 #
#.............................................................................#
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 08/06/2015 RCP, Fornax     RELTXT     Criar versao .txt dos relatorios.     #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_path       char(100),
       m_path_txt   char(100), #--> RELTXT
       m_mes_int    smallint,
       mr_dthor     datetime year to second,
       m_totfor     smallint,
       m_indice     smallint,
       m_contreg    smallint

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
    dsctipcod       like dbsropgdsc.dsctipcod     #codigo tipo desconto
   ,dscvlr          like dbsropgdsc.dscvlr        #valor desconto
   ,dscvlrobs       like dbsropgdsc.dscvlrobs     #observacao do valor de desconto
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

define mr_dados_digitacao record
    socopgfasdat    like dbsmopgfas.socopgfasdat
   ,socopgfashor    like dbsmopgfas.socopgfashor
   ,funmat          like dbsmopgfas.funmat      
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
   
main

    call fun_dba_abre_banco("CT24HS")
   
    call bdbsr037_busca_path()

    let mr_dthor = current
    display "Inicio Prepare : ", mr_dthor
    call bdbsr037_prepare()
    let mr_dthor = current     
    display "Termino Prepare : ", mr_dthor  

    call cts40g03_exibe_info("I","BDBSR037")

    set isolation to dirty read
 
    let mr_dthor = current
    display "Inicio telaOP : ", mr_dthor   
    whenever error continue 
    call bdbsr037_telaOP()
    whenever error stop
    let mr_dthor = current     
    display "Termino telaOP : ", mr_dthor 
    
    call bdbsr037_envia_email()
    
    call cts40g03_exibe_info("F","BDBSR037")

end main

#------------------------------#
 function bdbsr037_busca_path()
#------------------------------#

     define l_dataarq char(8)
     define l_data    date
     
     let l_data = today
     display "l_data: ", l_data
     let l_dataarq = extend(l_data, year to year),
                     extend(l_data, month to month),
                     extend(l_data, day to day)
     display "l_dataarq: ", l_dataarq

    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null
    let m_path_txt = null #--> RELTXT

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr037.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if
    
    let m_path_txt = m_path clipped, "/BDBSR037_", l_dataarq, ".txt"
    let m_path     = m_path clipped, "/BDBSR037.xls"
    
 end function

#---------------------------#
 function bdbsr037_prepare()
#---------------------------#
  define l_sql char(1000)
  define l_data_inicio, l_data_fim date
  define l_data_atual date,
         l_hora_atual datetime hour to minute

  let l_data_atual = arg_val(1)
   
  # ---> OBTER A DATA E HORA DO BANCO
  if l_data_atual is null then
     call cts40g03_data_hora_banco(2)
          returning l_data_atual,
                    l_hora_atual
  end if                
  display "l_data_atual: ",l_data_atual
    
  # ---> DATA DE EXTRACAO DAS INFORMACOES MES ANTERIOR
  if  month(l_data_atual) = 01 then
      let l_data_inicio = mdy(12,01,year(l_data_atual) - 1)
      let l_data_fim    = mdy(12,31,year(l_data_atual) - 1)
  else
      #let l_data_inicio = mdy(month(l_data_atual),01,year(l_data_atual))
      let l_data_inicio = mdy(month(l_data_atual) - 1,01,year(l_data_atual))
      let l_data_fim    = mdy(month(l_data_atual),01,year(l_data_atual)) - 1 units day
      #let l_data_fim = l_data_atual
  end if
  display "l_data_inicio: ",l_data_inicio 
  display "l_data_fim: ",l_data_fim
  
  # ---> OBTEM O MES DE GERACAO DO RELATORIO
  let m_mes_int = month(l_data_inicio)
    
  # ---> OBTEM DADOS PARA O RELATORIO
  let l_sql = " select opg.socopgnum     "
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
             ,"  from dbsmopg opg        "
             ," where socfatpgtdat between'", l_data_inicio, "' and '", l_data_fim, "'" 
  prepare pbdbsr037001 from l_sql            
  declare cbdbsr037001 cursor for pbdbsr037001    
                  
  let l_sql = " select fav.socopgfavnom   "
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
  prepare pbdbsr037002 from l_sql            
  declare cbdbsr037002 cursor for pbdbsr037002    
   
                  
  let l_sql = " select simoptpstflg   "
             ,"   from dpaksocor      "
             ,"  where pstcoddig = ?  "  
  prepare pbdbsr037003 from l_sql            
  declare cbdbsr037003 cursor for pbdbsr037003    
                  
  let l_sql = " select cpodes                  "
             ,"   from iddkdominio             "
             ,"  where cponom = 'socopgsitcod' "
             ,"    and cpocod = ?              "  
  prepare pbdbsr037004 from l_sql            
  declare cbdbsr037004 cursor for pbdbsr037004   
                    
  let l_sql = " select cpodes                    "
             ,"    from iddkdominio              "
             ,"   where cponom = 'socpgtdoctip'  "
             ,"     and cpocod = ?               "
  prepare pbdbsr037005 from l_sql            
  declare cbdbsr037005 cursor for pbdbsr037005    
                    
  let l_sql = " select sucnom       "
             ,"    from gabksuc     "
             ,"   where succod = ?  " 
  prepare pbdbsr037006 from l_sql            
  declare cbdbsr037006 cursor for pbdbsr037006    
                 
  let l_sql = " select bcoagnnom      "
            ,"    from gcdkbancoage   "
            ,"   where bcocod = ?     "
            ,"     and bcoagnnum = ?  "  
  prepare pbdbsr037008 from l_sql            
  declare cbdbsr037008 cursor for pbdbsr037008    
                   
  let l_sql = " select pgtdstdes      "                
             ,"   from fpgkpgtdst     "
             ,"  where pgtdstcod = ?  "  
  prepare pbdbsr037009 from l_sql            
  declare cbdbsr037009 cursor for pbdbsr037009    
                                                                                     
  let l_sql = " select bcosgl       "    
             ,"    from gcdkbanco   "                                                
             ,"   where bcocod = ?  "                                                                                                                                      
  prepare pbdbsr037007 from l_sql                                                         
  declare cbdbsr037007 cursor for pbdbsr037007       
    
  let l_sql = " select dsctipcod "
             ,"       ,dscvlr    "
             ,"       ,dscvlrobs "
             ,"    from dbsropgdsc   "                                                
             ,"   where socopgnum = ?  "                                                                                                                                     
  prepare pbdbsr037011 from l_sql                                                         
  declare cbdbsr037011 cursor for pbdbsr037011  
   
  let l_sql = " select sum(dscvlr)    "    
             ,"    from dbsropgdsc   "     
             ,"   where socopgnum = ?  "                                            
  prepare pbdbsr037010 from l_sql            
  declare cbdbsr037010 cursor for pbdbsr037010  
  
  let l_sql = " select dsctipcod "
             ,"       ,dsctipdes "
             ,"    from dbsktipdsc   "                                                
             ,"   where dsctipcod = ?  "                                                                                                                                    
  prepare pbdbsr037012 from l_sql                                                         
  declare cbdbsr037012 cursor for pbdbsr037012    
   
  let l_sql = " select socopgfasdat     "
             ,"       ,socopgfashor     "
             ,"       ,funmat           "
             ,"  from dbsmopgfas        "
             ," where socopgnum = ?     "
             ,"   and socopgfascod = 3  "           
  prepare pbdbsr037013 from l_sql            
  declare cbdbsr037013 cursor for pbdbsr037013 
  
end  function

#--------------------------#
 function bdbsr037_telaOP()
#--------------------------#

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
             ,mr_dados_digitacao.*
             ,m_contreg
             ,m_indice to null
   
   start report bdbsr037_relatorio to m_path
   start report bdbsr037_relatorio_txt to m_path_txt #--> RELTXT

   display "m_contreg_1: ", m_contreg

   open cbdbsr037001
   foreach cbdbsr037001 into  mr_dados_dbsmopg.socopgnum   
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
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037001 ', sqlca.sqlcode 
         end if  
                        
      open cbdbsr037002 using  mr_dados_dbsmopg.socopgnum
      fetch cbdbsr037002 into  mr_dados_dbsmopgfav.socopgfavnom 
                              ,mr_dados_dbsmopgfav.socpgtopccod 
                              ,mr_dados_dbsmopgfav.pestip       
                              ,mr_dados_dbsmopgfav.cgccpfnum    
                              ,mr_dados_dbsmopgfav.cgcord       
                              ,mr_dados_dbsmopgfav.cgccpfdig    
                              ,mr_dados_dbsmopgfav.bcoctatip    
                              ,mr_dados_dbsmopgfav.bcocod       
                              ,mr_dados_dbsmopgfav.bcoagnnum    
                              ,mr_dados_dbsmopgfav.bcoagndig    
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037002 ', sqlca.sqlcode 
         end if  
      close cbdbsr037002
      
      open cbdbsr037003 using  mr_dados_dbsmopg.pstcoddig 
      fetch cbdbsr037003 into  mr_dados_dpaksocor.simoptpstflg  
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037003 ', sqlca.sqlcode 
         end if        
      close cbdbsr037003

      open cbdbsr037004 using  mr_dados_dbsmopg.socopgsitcod
      fetch cbdbsr037004 into  mr_dados_iddkdominio.socopgsitdes              
         if sqlca.sqlcode <> 0 then
            # display 'Erro cbdbsr037004 ', sqlca.sqlcode 
         end if  
      close cbdbsr037004

      open cbdbsr037005 using  mr_dados_dbsmopg.socpgtdoctip                  
      fetch cbdbsr037005 into  mr_dados_iddkdominio.socpgtdocdes
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037005 ', sqlca.sqlcode 
         end if               
      close cbdbsr037005

      open cbdbsr037006 using  mr_dados_dbsmopg.succod
      fetch cbdbsr037006 into  mr_dados_gabksuc.sucnom
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037006 ', sqlca.sqlcode 
         end if                
      close cbdbsr037006
      
      open cbdbsr037007 using  mr_dados_dbsmopgfav.bcocod  
      fetch cbdbsr037007 into  mr_dados_gcdkbanco.bcosgl
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037007 ', sqlca.sqlcode 
         end if   
      close cbdbsr037007

      open cbdbsr037008 using  mr_dados_dbsmopgfav.bcocod    
                              ,mr_dados_dbsmopgfav.bcoagnnum  
      fetch cbdbsr037008 into  mr_dados_gcdkbancoage.bcoagnnom
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037008 ', sqlca.sqlcode 
         end if                  
      close cbdbsr037008
      
      open cbdbsr037009 using  mr_dados_dbsmopg.pgtdstcod                    
      fetch cbdbsr037009 into  mr_dados_fpgkpgtdst.pgtdstdes
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037009 ', sqlca.sqlcode 
         end if               
      close cbdbsr037009
      
      if mr_dados_dbsmopgfav.socpgtopccod = 1 then
         let mr_dados_dbsmopgfav.socpgtopcdes = 'Conta Corrente'
      else
         if mr_dados_dbsmopgfav.socpgtopccod = 2 then 
            let mr_dados_dbsmopgfav.socpgtopcdes = 'Poupanca'
         end if
      end if
   
      open cbdbsr037013 using  mr_dados_dbsmopg.socopgnum                  
      fetch cbdbsr037013 into  mr_dados_digitacao.socopgfasdat
                              ,mr_dados_digitacao.socopgfashor
                              ,mr_dados_digitacao.funmat
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037013 ', sqlca.sqlcode 
         end if               
      close cbdbsr037013
      
      open cbdbsr037010 using  mr_dados_dbsmopg.socopgnum 
      fetch cbdbsr037010 into  mr_dados_dbsropgdsctt.dscvlrtotal
         if sqlca.sqlcode <> 0 then
            display 'Erro cbdbsr037010 ', sqlca.sqlcode 
         end if     
      close cbdbsr037010
      
      let m_indice = 0
      let m_totfor = 0
      
      select count(*)
      into m_totfor
      from dbsropgdsc
      where socopgnum = mr_dados_dbsmopg.socopgnum
      display "m_totfor : ", m_totfor
      
          display "m_contreg_2: ", m_contreg
          let m_contreg = 1 
          display "m_contreg_3: ", m_contreg 
      
          if m_totfor > 0 then
                
            open cbdbsr037011 using mr_dados_dbsmopg.socopgnum
               display "OP : ", mr_dados_dbsmopg.socopgnum   
            close cbdbsr037011  
                                  
            foreach cbdbsr037011 into mr_dados_dbsropgdsc.dsctipcod   
                                     ,mr_dados_dbsropgdsc.dscvlr   
                                     ,mr_dados_dbsropgdsc.dscvlrobs
             
                  if sqlca.sqlcode <> 0 then
                     display 'Erro cbdbsr037011 ', sqlca.sqlcode 
                  end if  
                  
                  select count(*)
                    into m_indice
                    from dbsktipdsc
                   where dsctipcod = mr_dados_dbsropgdsc.dsctipcod
                   
                  if m_indice > 0 then
                     
                     open cbdbsr037012 using mr_dados_dbsropgdsc.dsctipcod
                     fetch cbdbsr037012 into mr_dados_dbsktipdsc.dsctipcod
                                            ,mr_dados_dbsktipdsc.dsctipdes
                        
                        if sqlca.sqlcode <> 0 then
                           display 'Erro cbdbsr037012 ', sqlca.sqlcode 
                        end if  
                     close cbdbsr037012

                     if mr_dados_dbsktipdsc.dsctipcod is not null then
                        display "m_contreg_4: ", m_contreg
                        output to report bdbsr037_relatorio() 
                        output to report bdbsr037_relatorio_txt() #--> RELTXT
                     else
                        display "m_contreg_5: ", m_contreg
                        exit foreach
                     end if
                  else
                     display "m_contreg_6: ", m_contreg
                     output to report bdbsr037_relatorio() 
                     output to report bdbsr037_relatorio_txt() #--> RELTXT
                  end if
                 
                  initialize mr_dados_dbsktipdsc.*
                            ,mr_dados_dbsropgdsc.* to null
                            
                  let m_contreg = m_contreg + 1
                 
            end foreach
            
          else
             output to report bdbsr037_relatorio()                   
             output to report bdbsr037_relatorio_txt() #--> RELTXT   
          end if
                   
             display "initialize to null ", mr_dados_dbsmopg.socopgnum, " - contador ", m_contreg
                       
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
             ,mr_dados_digitacao.*
             ,m_indice
             ,m_contreg to null
             
             display "initialize to null ", mr_dados_dbsmopg.socopgnum, " - contador ", m_contreg
    
   end foreach

   finish report bdbsr037_relatorio       
   finish report bdbsr037_relatorio_txt #--> RELTXT       
                                          
 end function                             

#-------------------------------#
 function bdbsr037_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_anexo       char(200),
          l_mes_extenso char(010),
          l_erro_envio  integer

   case m_mes_int
      when 01 let l_mes_extenso = 'Janeiro'
      when 02 let l_mes_extenso = 'Fevereiro'
      when 03 let l_mes_extenso = 'Marco'
      when 04 let l_mes_extenso = 'Abril'
      when 05 let l_mes_extenso = 'Maio'
      when 06 let l_mes_extenso = 'Junho'
      when 07 let l_mes_extenso = 'Julho'
      when 08 let l_mes_extenso = 'Agosto'
      when 09 let l_mes_extenso = 'Setembro'
      when 10 let l_mes_extenso = 'Outubro'
      when 11 let l_mes_extenso = 'Novembro'
      when 12 let l_mes_extenso = 'Dezembro'
   end case

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null
   let l_assunto    = "Relatorio Tela O.P. - ", l_mes_extenso clipped, " - BDBSR037"

   # Colocamos o whenever para que o programa nao aborte quando ocorrer erro no envio de email
   # pois a nova funcao nao retorna o erro, ela aborta o programa
   whenever error continue
    
   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path
   run l_comando
   let m_path = m_path clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR037", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR037"
       end if
   end if

   whenever error stop

end function

#---------------------------#
 report bdbsr037_relatorio()
#---------------------------#

  output

  left   margin 00
  right  margin 00
  top    margin 00
  bottom margin 00
  page   length 02

  format

  first page header

  print "Numero da Ordem de Pagamento"               , ASCII(09), #Numero da OP
        "Codigo da situacao da O.P"                  , ASCII(09), #Situação 
        "Codigo da Empresa"                          , ASCII(09),     
        "codigo e digito de posto"                   , ASCII(09), #Prestador
        "Data da entrega da fatura"                  , ASCII(09), #Data Entrega    
        "Data do pagamento"                          , ASCII(09), #Data de Pagamento
        "codigo tarifa porto socorro"                , ASCII(09), #Tarifa    
        "Quantidade de itens da fatura"              , ASCII(09), #Quantidade
        "Valor Total do itens da fatura"             , ASCII(09), #Valor total
        "Quantidade de relacoes"                     , ASCII(09), #Relacoes
        "valor da aliquota de iss informada"         , ASCII(09), #Aliquota
        "Tipo do documento de pagto Porto Socorro"   , ASCII(09), #Tipo Documento
        "número da nota fiscal"                      , ASCII(09), #Numero Documento
        "fisnotsrenum            "                   , ASCII(09), #Serie NF
        "data emissao nota fiscal"                   , ASCII(09), #Data emissao
        "Sucursal - Codigo"                          , ASCII(09), #Sucursal
        "Codigo do destino do pagamento"             , ASCII(09), #Destino
        "Valor do desconto da O.P"                   , ASCII(09), #Valor Desconto
        "Nome do favorecido"                         , ASCII(09), #Favorecido
        "Codigo da opcao de pagamento"               , ASCII(09), #Opcao Pagamento
        "Tipo de pessoa para a Receita Federal"      , ASCII(09), #Tipo Pessoa
        "Numero do CGC ou CPF"                       , ASCII(09), #CGC
        "Ordem do CGC"                               , ASCII(09), #CGC
        "Digito do CGC ou CPF"                       , ASCII(09), #CGC
        "Data da Digitacao"                          , ASCII(09), #DataDigitacao 
        "Hora da Digitacao"                          , ASCII(09), #HoraDigitacao 
        "Responsavel Digitacao"                      , ASCII(09), #ResponsavelDigitacao 
        "Tipo da Conta bancaria"                     , ASCII(09), #Tipo de conta
        "Codigo do Banco"                            , ASCII(09), #Banco
        "Numero da conta bancaria de pagamento"      , ASCII(09), #Conta
        "Digito de Controle do Numero da Agencia"    , ASCII(09), #Agencia
        "Numero da agencia de pagamento"             , ASCII(09), #Agencia
        "Flag prestador optante pelo simples"        , ASCII(09), #Optante simples
        "Situacao da OP"                             , ASCII(09), #Situacao
        "Tipo Docto"                                 , ASCII(09), #Tipo Documento
        "Nome Sucursal"                              , ASCII(09), #Sucursal
        "Sigla do Banco"                             , ASCII(09), #Banco
        "Nome de agencia bancaria"                   , ASCII(09), #Agencia
        "Destino"                                    , ASCII(09), #Destino
        "Opcao Pagto"                                , ASCII(09), #Opcao Pagamento
        "codigo tipo desconto"                       , ASCII(09),
        "valor desconto"                             , ASCII(09),
        "observacao do valor de desconto"            , ASCII(09),
        "descricao tipo desconto "                   , ASCII(09)
        
  on every row

  print mr_dados_dbsmopg.socopgnum                              , ASCII(09), 
        mr_dados_dbsmopg.socopgsitcod                           , ASCII(09),  
        mr_dados_dbsmopg.empcod                                 , ASCII(09),     
        mr_dados_dbsmopg.pstcoddig                              , ASCII(09), 
        mr_dados_dbsmopg.socfatentdat                           , ASCII(09),     
        mr_dados_dbsmopg.socfatpgtdat                           , ASCII(09), 
        mr_dados_dbsmopg.soctrfcod                              , ASCII(09),     
        mr_dados_dbsmopg.socfatitmqtd                           , ASCII(09),
        mr_dados_dbsmopg.socfattotvlr using "###,##&.&&"        , ASCII(09),
        mr_dados_dbsmopg.socfatrelqtd                           , ASCII(09),
        mr_dados_dbsmopg.infissalqvlr                           , ASCII(09),
        mr_dados_dbsmopg.socpgtdoctip                           , ASCII(09),
        mr_dados_dbsmopg.nfsnum                                 , ASCII(09),
        mr_dados_dbsmopg.fisnotsrenum                           , ASCII(09),
        mr_dados_dbsmopg.socemsnfsdat                           , ASCII(09),
        mr_dados_dbsmopg.succod                                 , ASCII(09),
        mr_dados_dbsmopg.pgtdstcod                              , ASCII(09),
        mr_dados_dbsropgdsctt.dscvlrtotal using "###,##&.&&"    , ASCII(09),
        mr_dados_dbsmopgfav.socopgfavnom                        , ASCII(09),
        mr_dados_dbsmopgfav.socpgtopccod                        , ASCII(09),
        mr_dados_dbsmopgfav.pestip                              , ASCII(09),
        mr_dados_dbsmopgfav.cgccpfnum                           , ASCII(09),
        mr_dados_dbsmopgfav.cgcord                              , ASCII(09),
        mr_dados_dbsmopgfav.cgccpfdig                           , ASCII(09), 
        mr_dados_digitacao.socopgfasdat                         , ASCII(09),
        mr_dados_digitacao.socopgfashor                         , ASCII(09),
        mr_dados_digitacao.funmat                               , ASCII(09),  
        mr_dados_dbsmopgfav.bcoctatip                           , ASCII(09),
        mr_dados_dbsmopgfav.bcocod                              , ASCII(09),
        mr_dados_dbsmopgfav.bcoagnnum                           , ASCII(09),
        mr_dados_dbsmopgfav.bcoagndig                           , ASCII(09),
        mr_dados_dbsmopgfav.bcoctanum                           , ASCII(09),
        mr_dados_dpaksocor.simoptpstflg                         , ASCII(09),
        mr_dados_iddkdominio.socopgsitdes                       , ASCII(09),
        mr_dados_iddkdominio.socpgtdocdes                       , ASCII(09),
        mr_dados_gabksuc.sucnom                                 , ASCII(09),
        mr_dados_gcdkbanco.bcosgl                               , ASCII(09),
        mr_dados_gcdkbancoage.bcoagnnom                         , ASCII(09),
        mr_dados_fpgkpgtdst.pgtdstdes                           , ASCII(09),
        mr_dados_dbsmopgfav.socpgtopcdes                        , ASCII(09),
        mr_dados_dbsropgdsc.dsctipcod                           , ASCII(09),
        mr_dados_dbsropgdsc.dscvlr using "###,##&.&&"           , ASCII(09),
        mr_dados_dbsropgdsc.dscvlrobs                           , ASCII(09),
        mr_dados_dbsktipdsc.dsctipdes                           , ASCII(09) 
        
 end report

#--------------------------------#
 report bdbsr037_relatorio_txt() #--> RELTXT
#--------------------------------#

  output

  left   margin 00
  right  margin 00
  top    margin 00
  bottom margin 00
  page   length 01

  format

  on every row

  print mr_dados_dbsmopg.socopgnum                              , ASCII(09), 
        mr_dados_dbsmopg.socopgsitcod                           , ASCII(09),  
        mr_dados_dbsmopg.empcod                                 , ASCII(09),     
        mr_dados_dbsmopg.pstcoddig                              , ASCII(09), 
        mr_dados_dbsmopg.socfatentdat                           , ASCII(09),     
        mr_dados_dbsmopg.socfatpgtdat                           , ASCII(09), 
        mr_dados_dbsmopg.soctrfcod                              , ASCII(09),     
        mr_dados_dbsmopg.socfatitmqtd                           , ASCII(09),
        mr_dados_dbsmopg.socfattotvlr using "###,##&.&&"        , ASCII(09),
        mr_dados_dbsmopg.socfatrelqtd                           , ASCII(09),
        mr_dados_dbsmopg.infissalqvlr                           , ASCII(09),
        mr_dados_dbsmopg.socpgtdoctip                           , ASCII(09),
        mr_dados_dbsmopg.nfsnum                                 , ASCII(09),
        mr_dados_dbsmopg.fisnotsrenum                           , ASCII(09),
        mr_dados_dbsmopg.socemsnfsdat                           , ASCII(09),
        mr_dados_dbsmopg.succod                                 , ASCII(09),
        mr_dados_dbsmopg.pgtdstcod                              , ASCII(09),
        mr_dados_dbsropgdsctt.dscvlrtotal using "###,##&.&&"    , ASCII(09),
        mr_dados_dbsmopgfav.socopgfavnom                        , ASCII(09),
        mr_dados_dbsmopgfav.socpgtopccod                        , ASCII(09),
        mr_dados_dbsmopgfav.pestip                              , ASCII(09),
        mr_dados_dbsmopgfav.cgccpfnum                           , ASCII(09),
        mr_dados_dbsmopgfav.cgcord                              , ASCII(09),
        mr_dados_dbsmopgfav.cgccpfdig                           , ASCII(09), 
        mr_dados_digitacao.socopgfasdat                         , ASCII(09),
        mr_dados_digitacao.socopgfashor                         , ASCII(09),
        mr_dados_digitacao.funmat                               , ASCII(09),  
        mr_dados_dbsmopgfav.bcoctatip                           , ASCII(09),
        mr_dados_dbsmopgfav.bcocod                              , ASCII(09),
        mr_dados_dbsmopgfav.bcoagnnum                           , ASCII(09),
        mr_dados_dbsmopgfav.bcoagndig                           , ASCII(09),
        mr_dados_dbsmopgfav.bcoctanum                           , ASCII(09),
        mr_dados_dpaksocor.simoptpstflg                         , ASCII(09),
        mr_dados_iddkdominio.socopgsitdes                       , ASCII(09),
        mr_dados_iddkdominio.socpgtdocdes                       , ASCII(09),
        mr_dados_gabksuc.sucnom                                 , ASCII(09),
        mr_dados_gcdkbanco.bcosgl                               , ASCII(09),
        mr_dados_gcdkbancoage.bcoagnnom                         , ASCII(09),
        m_contreg                                               , ASCII(09),
        mr_dados_fpgkpgtdst.pgtdstdes                           , ASCII(09),
        mr_dados_dbsmopgfav.socpgtopcdes                        , ASCII(09),
        mr_dados_dbsropgdsc.dsctipcod                           , ASCII(09),
        mr_dados_dbsropgdsc.dscvlr using "###,##&.&&"           , ASCII(09),
        mr_dados_dbsropgdsc.dscvlrobs                           , ASCII(09),
        mr_dados_dbsktipdsc.dsctipdes 
        
 end report
