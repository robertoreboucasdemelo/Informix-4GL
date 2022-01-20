#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR039                                                   #
# ANALISTA RESP..: RAFAEL MOREIRA GOMES                                       #
# PSI/OSF........: - EXTRACAO SOCORRISTAS                                     #
#                  - EXTRACAO PRESTADORES                                     #
#                  - EXTRACAO VIATURAS                                        #
# ........................................................................... #
# DESENVOLVIMENTO: FORNAX TECNOLOGIA, RCP                                     #
# LIBERACAO......: 19/05/2015                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             # 
# 05/11/2015 Eliane,Fornax   ch 686637  Inclusao da Natureza do tipo de       #
#                                       Assistencia a Residencia - RE         # 
#-----------------------------------------------------------------------------#
# 17/11/2015 Eliane, Fornax  ch 686637  Incluir Assistencia + Natureza em     #
#                                       ESPECIALIDADE                         #
#-----------------------------------------------------------------------------#
 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_path        char(100)
      , m_path_a      char(100)
      , m_path_b      char(100)
      , m_path_c      char(100)
      , m_data        date

 define mr_socorrista record
        srrcoddig     like datksrr.srrcoddig 
      , srrnom        like datksrr.srrnom
      , asitipcod     like datrsrrasi.asitipcod
      , natureza      like datksocntz.socntzcod
      , desc_natureza like datksocntz.socntzdes
      , espcod        like dbskesp.espcod
      , desc_espec    like dbskesp.espdes
      , caddat        like datrsrrasi.caddat    
      , cademp        like datrsrrasi.cademp    
      , cadmat        like datrsrrasi.cadmat    
 end record

 define mr_prestador  record
        pstcoddig     like dpaksocor.pstcoddig
      , nomrazsoc     like dpaksocor.nomrazsoc
      , asitipcod     like datrassprs.asitipcod 
      , natureza      like datksocntz.socntzcod
      , desc_natureza like datksocntz.socntzdes
      , caddat        like datrassprs.caddat    
      , cademp        like datrassprs.cademp    
      , cadmat        like datrassprs.cadmat    
 end record

 define mr_veiculo    record
        socvclcod     like datkveiculo.socvclcod
      , atdvclsgl     like datkveiculo.atdvclsgl
      , soceqpcod     like datreqpvcl.soceqpcod  
      , caddat        like datreqpvcl.caddat    
      , cademp        like datreqpvcl.cademp    
      , cadmat        like datreqpvcl.cadmat    
 end record

 define mr_descricao  record
	      descricao     char(200) 
       ,desc_report   char(100)
 end record
 
 define l_descricao   like datkasitip.asitipdes 

 define mr_isskfunc   record
        funnom        like isskfunc.funnom
 end record

 main

    call fun_dba_abre_banco("CT24HS")
   
    call bdbsr039_busca_path()

    call bdbsr039_prepare()

    call cts40g03_exibe_info("I","BDBSR039")

    set isolation to dirty read
    
    call bdbsr039_socorristas()

    call bdbsr039_prestadores()

    call bdbsr039_viaturas()
    
    call bdbsr039_envia_email()
    
    call cts40g03_exibe_info("F","BDBSR039")

 end main

#------------------------------#
 function bdbsr039_busca_path()
#------------------------------#
    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr039.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
        let m_path = "."
    end if
    
    let m_path_a = m_path clipped, "/BDBSR039A.xls"
    let m_path_b = m_path clipped, "/BDBSR039B.xls"
    let m_path_c = m_path clipped, "/BDBSR039C.xls"
    
 end function

#---------------------------#
 function bdbsr039_prepare()
#---------------------------#
   define l_sql char(1000)
   define l_data_atual date,
          l_hora_atual datetime hour to minute

   initialize m_data to null

   let m_data = arg_val(1)
   
   # ---> OBTER A DATA E HORA DO BANCO
   if m_data is null then
      call cts40g03_data_hora_banco(2)
           returning l_data_atual,
                     l_hora_atual
                     
      let m_data = l_data_atual - 1

   end if                
   
   display "m_data: ", m_data


   let l_sql = " select soc.srrcoddig                 "
              ,"      , soc.srrnom                    "
              ,"      , esp.asitipcod                 "
              ,"      , esp.caddat                    "
              ,"      , esp.cademp                    "
              ,"      , esp.cadmat                    "
              ,"   from datksrr    soc                "
              ,"      , datrsrrasi esp                "
              ,"  where soc.srrcoddig = esp.srrcoddig "
   prepare pbdbsr039001a from l_sql            
   declare cbdbsr039001a cursor for pbdbsr039001a  

   let l_sql = " select a.socntzcod,              ",
               "        c.socntzdes,              ",
               "        a.espcod,                 ",
               "        b.espdes                  ",
   	           "   from dbsrntzpstesp a,          ",
   	           "        dbskesp b,                ",
   	           "        datksocntz c              ",
   	           "  where a.srrcoddig = ?           ",
   	           "    and a.socntzcod = c.socntzcod ",
   	           "    and a.espcod = b.espcod       ",
   	           "    and c.socntzstt = 'A'         ",
   	           "  order by a.socntzcod            "
        prepare pbdbsr039001a_n from l_sql
        declare cbdbsr039001a_n cursor for pbdbsr039001a_n 

    let l_sql = " select pst.pstcoddig                 "
               ,"      , pst.nomrazsoc                 "
               ,"      , esp.asitipcod                 "
               ,"      , esp.caddat                    "
               ,"      , esp.cademp                    "
               ,"      , esp.cadmat                    "
               ,"   from dpaksocor  pst                "
               ,"      , datrassprs esp                "
               ,"  where pst.pstcoddig = esp.pstcoddig "
    prepare pbdbsr039001b from l_sql            
    declare cbdbsr039001b cursor for pbdbsr039001b  

    let l_sql = " select a.socntzcod,               ",
		            " b.socntzdes                       ",
                " from dparpstntz   a, datksocntz b ",   
                " where a.pstcoddig = ?             ",
		            "   and a.socntzcod = b.socntzcod   ",
	              " order by a.socntzcod              "
    prepare pbdbsr039001b_n from l_sql
    declare cbdbsr039001b_n cursor for pbdbsr039001b_n

    let l_sql = " select vei.socvclcod   "
               ,"      , vei.atdvclsgl   "
               ,"      , eqp.soceqpcod   "
               ,"      , eqp.caddat      "
               ,"      , eqp.cademp      "
               ,"      , eqp.cadmat      "
               ,"   from datkveiculo vei "
               ,"      , datreqpvcl  eqp "
               ,"  where vei.socvclcod = eqp.socvclcod "
    prepare pbdbsr039001c from l_sql            
    declare cbdbsr039001c cursor for pbdbsr039001c  

    let l_sql = " select asitipdes     "
               ,"   from datkasitip    "
               ,"  where asitipcod = ? "
    prepare pbdbsr039002 from l_sql            
    declare cbdbsr039002 cursor for pbdbsr039002 
   
    let l_sql = " select soceqpdes     "
               ,"   from datkvcleqp    "
               ,"  where soceqpcod = ? "
    prepare pbdbsr039003 from l_sql            
    declare cbdbsr039003 cursor for pbdbsr039003 
   
    let l_sql = " select funnom             "
               ,"   from isskfunc           "
               ,"  where funmat = ?         "
               ,"    and empcod = ?         "
               ,"    and rhmfunsitcod = 'A' "
    prepare pbdbsr039004 from l_sql            
    declare cbdbsr039004 cursor for pbdbsr039004 
   
end  function

#-------------------------------#
 function bdbsr039_socorristas()
#-------------------------------#

   initialize mr_socorrista.*
             ,mr_isskfunc.*
             ,mr_descricao.* 
              to null

   start report bdbsr039_rel_soc to m_path_a

   open cbdbsr039001a
   foreach cbdbsr039001a into mr_socorrista.srrcoddig
                             ,mr_socorrista.srrnom
                             ,mr_socorrista.asitipcod 
                             ,mr_socorrista.caddat
                             ,mr_socorrista.cademp
                             ,mr_socorrista.cadmat

      open cbdbsr039002 using mr_socorrista.asitipcod    
      fetch cbdbsr039002 into mr_descricao.descricao
      
      if sqlca.sqlcode <> 0 then
	       let mr_descricao.descricao = "ESPECIALIDADE NAO ENCONTRADA : "
				                             , mr_socorrista.asitipcod using "<<<<<<<&"
      end if 
      close cbdbsr039002

    if ( mr_socorrista.asitipcod = 6 ) then  # ASSIST. A RESIDENCIA
    
       let l_descricao = mr_descricao.desc_report clipped
       
       open cbdbsr039001a_n using mr_socorrista.srrcoddig
       foreach cbdbsr039001a_n into mr_socorrista.natureza, mr_socorrista.desc_natureza, 
                                    mr_socorrista.espcod, mr_socorrista.desc_espec
           
           open cbdbsr039004 using mr_socorrista.cadmat
                                  ,mr_socorrista.cademp
           fetch cbdbsr039004 into mr_isskfunc.funnom
        
           if sqlca.sqlcode <> 0 then
	             let mr_isskfunc.funnom = "FUNCIONARIO NAO LOCALIDADO : "
			                                 , mr_socorrista.cadmat using "<<<<<<<&"
           end if 
           close cbdbsr039004

	   let mr_socorrista.asitipcod = mr_socorrista.natureza clipped 
	   let mr_descricao.descricao = mr_socorrista.desc_natureza clipped,
                                        " - ",
					mr_socorrista.desc_espec clipped
           output to report bdbsr039_rel_soc()
       end foreach
       close cbdbsr039001a_n
    else
       
       let mr_socorrista.natureza = ' '
       let mr_socorrista.desc_natureza = ' '

       open cbdbsr039004 using mr_socorrista.cadmat
                              ,mr_socorrista.cademp
       fetch cbdbsr039004 into mr_isskfunc.funnom
       
       if sqlca.sqlcode <> 0 then
                let mr_isskfunc.funnom = "FUNCIONARIO NAO LOCALIDADO : "
                                        , mr_socorrista.cadmat using "<<<<<<<&"
       end if
       close cbdbsr039004
       
       output to report bdbsr039_rel_soc()

    end if

    initialize mr_socorrista.* 
              ,mr_descricao.*
              ,mr_isskfunc.*  
               to null                 
                                          
   end foreach                            
                                          
   finish report bdbsr039_rel_soc
                                          
 end function                             
                                          
#-------------------------------#
 function bdbsr039_prestadores()
#-------------------------------#

   initialize mr_prestador.*
             ,mr_isskfunc.*
             ,mr_descricao.* 
              to null

   start report bdbsr039_rel_pst to m_path_b

   open cbdbsr039001b
   foreach cbdbsr039001b into mr_prestador.pstcoddig
                             ,mr_prestador.nomrazsoc
                             ,mr_prestador.asitipcod 
                             ,mr_prestador.caddat
                             ,mr_prestador.cademp
                             ,mr_prestador.cadmat

      open cbdbsr039002 using mr_prestador.asitipcod    
      fetch cbdbsr039002 into mr_descricao.descricao
      
      if sqlca.sqlcode <> 0 then
	       let mr_descricao.descricao = "ESPECIALIDADE NAO ENCONTRADA : "
				                             , mr_prestador.asitipcod using "<<<<<<<&"
      end if 
      close cbdbsr039002

     if ( mr_prestador.asitipcod = 6 ) then

        let l_descricao = mr_descricao.desc_report
        open cbdbsr039001b_n    using mr_prestador.pstcoddig 
        foreach cbdbsr039001b_n into  mr_prestador.natureza,
                                      mr_prestador.desc_natureza
        
        open cbdbsr039004 using mr_prestador.cadmat
                               ,mr_prestador.cademp
        fetch cbdbsr039004 into mr_isskfunc.funnom
            
        if sqlca.sqlcode <> 0 then
             let mr_isskfunc.funnom = "FUNCIONARIO NAO LOCALIDADO : "
                                      , mr_prestador.cadmat using "<<<<<<<&"
        end if 

         let mr_prestador.asitipcod = mr_prestador.natureza clipped
         let mr_descricao.descricao = mr_prestador.desc_natureza clipped
         close cbdbsr039004
            
         output to report bdbsr039_rel_pst()
         end foreach    
         close cbdbsr039001b_n
     
     else
           
      let  mr_prestador.natureza = ' '
      let  mr_prestador.desc_natureza = ' '
        
      open cbdbsr039004 using mr_prestador.cadmat
                             ,mr_prestador.cademp
      fetch cbdbsr039004 into mr_isskfunc.funnom
        
      if sqlca.sqlcode <> 0 then
              let mr_isskfunc.funnom = "FUNCIONARIO NAO LOCALIDADO : "
                        	       , mr_prestador.cadmat using "<<<<<<<&"
      end if
	      
      close cbdbsr039004
        
      output to report bdbsr039_rel_pst()

     end if

     initialize mr_prestador.* 
               ,mr_descricao.*
               ,mr_isskfunc.*  
                to null                 
                                         
   end foreach                            
                                          
   finish report bdbsr039_rel_pst
                                          
 end function                             
                                          
#----------------------------#
 function bdbsr039_viaturas()
#----------------------------#

   initialize mr_veiculo.*
             ,mr_isskfunc.*
             ,mr_descricao.* 
              to null

   start report bdbsr039_rel_vei to m_path_c

   open cbdbsr039001c
   foreach cbdbsr039001c into mr_veiculo.socvclcod
                             ,mr_veiculo.atdvclsgl
                             ,mr_veiculo.soceqpcod 
                             ,mr_veiculo.caddat
                             ,mr_veiculo.cademp
                             ,mr_veiculo.cadmat

      open cbdbsr039003 using mr_veiculo.soceqpcod
      fetch cbdbsr039003 into mr_descricao.descricao
      
      if sqlca.sqlcode <> 0 then
	       let mr_descricao.descricao = "EQUIPAMENTO NAO ENCONTRADO:"
				                             , mr_veiculo.soceqpcod using "<<<<<<<&"
      end if 
      close cbdbsr039003
      
      open cbdbsr039004 using mr_veiculo.cadmat
                             ,mr_veiculo.cademp
      fetch cbdbsr039004 into mr_isskfunc.funnom
      
      if sqlca.sqlcode <> 0 then
	       let mr_isskfunc.funnom = "FUNCIONARIO NAO LOCALIDADO : "
			                           , mr_veiculo.cadmat using "<<<<<<<&"
      end if 
      close cbdbsr039004
      
      output to report bdbsr039_rel_vei()
                                          
      initialize mr_veiculo.* 
                ,mr_descricao.*
                ,mr_isskfunc.*  
                 to null                 
        
   end foreach                            
                                          
   finish report bdbsr039_rel_vei
                                          
 end function                             
                                          
#-------------------------------#
 function bdbsr039_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_anexo       char(200),
          l_erro_envio  integer

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null

   # ---> ENVIA RELATORIO SOCORRISTAS
   let l_assunto = "Relatorio Especialidade Socorristas - ", m_data, " - BDBSR039A"

   let l_comando = "gzip -f ", m_path_a
   run l_comando
   let m_path_a = m_path_a clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR039", l_assunto, m_path_a)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR039A"
       end if
   end if

   # ---> ENVIA RELATORIO PRESTADORES 
   let l_assunto = "Relatorio Especialidade Prestadores - ", m_data, " - BDBSR039B"

   let l_comando = "gzip -f ", m_path_b
   run l_comando
   let m_path_b = m_path_b clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR039", l_assunto, m_path_b)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path_b clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR039B"
       end if
   end if

   # ---> ENVIA RELATORIO VEICULOS
   let l_assunto = "Relatorio Especialidade Veiculos - ", m_data, " - BDBSR039C"

   let l_comando = "gzip -f ", m_path_c
   run l_comando
   let m_path_c = m_path_c clipped, ".gz"

   let l_erro_envio = ctx22g00_envia_email("BDBSR039", l_assunto, m_path_c)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path_c clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR039C"
       end if
   end if

   whenever error stop

end function

#-------------------------#
 report bdbsr039_rel_soc()
#-------------------------#

   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 02

   format
       first page header
             print "CODIGO",                          ASCII(09),
                   "NOME SOCORRISTA",                 ASCII(09),
                   "CODIGO ESPECIALIDADE",            ASCII(09), 
                   "DESCRICAO ESPECIALIDADE",         ASCII(09),
                   "DATA DE INCLUSAO DO EQUIPAMENTO", ASCII(09),
                   "RESPONSAVEL",                     ASCII(09)

   on every row
      print mr_socorrista.srrcoddig,      ASCII(09), 
            mr_socorrista.srrnom,         ASCII(09),
            mr_socorrista.asitipcod,      ASCII(09),
            mr_descricao.descricao,       ASCII(09),
            mr_socorrista.caddat,         ASCII(09),
            mr_isskfunc.funnom,           ASCII(09)
        
 end report

#-------------------------#
 report bdbsr039_rel_pst()
#-------------------------#

   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 02

   format
       first page header
             print "CODIGO",                          ASCII(09),
                   "NOME BASE",                       ASCII(09),
		               "CODIGO ESPECIALIDADE",            ASCII(09),
                   "DESCRICAO ESPECIALIDADE",         ASCII(09),
                   "DATA DE INCLUSAO DO EQUIPAMENTO", ASCII(09),
                   "RESPONSAVEL",                     ASCII(09)

   on every row
      print mr_prestador.pstcoddig,         ASCII(09), 
            mr_prestador.nomrazsoc,         ASCII(09), 
            mr_prestador.asitipcod,         ASCII(09),
	          mr_descricao.descricao,         ASCII(09),
            mr_prestador.caddat,            ASCII(09),
            mr_isskfunc.funnom,      ASCII(09)
        
 end report

#-------------------------#
 report bdbsr039_rel_vei()
#-------------------------#

   output
       left   margin 00
       right  margin 00
       top    margin 00
       bottom margin 00
       page   length 02

   format
       first page header
             print "CODIGO VEICULO",                  ASCII(09),
                   "SIGLA",                           ASCII(09),
                   "CODIGO EQUIPAMENTO",              ASCII(09),
                   "EQUIPAMENTO",                     ASCII(09),
                   "DATA DE INCLUSAO DO EQUIPAMENTO", ASCII(09),
                   "RESPONSAVEL",                     ASCII(09)

   on every row
      print mr_veiculo.socvclcod,       ASCII(09), 
            mr_veiculo.atdvclsgl,       ASCII(09),  
            mr_veiculo.soceqpcod,       ASCII(09), 
            mr_descricao.descricao,     ASCII(09),     
            mr_veiculo.caddat,          ASCII(09),
            mr_isskfunc.funnom,         ASCII(09)
        
 end report
