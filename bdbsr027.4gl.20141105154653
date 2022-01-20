#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SEGURO FAZ                                           #
# MODULO.........: BDBSR027                                                   #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                      #
# PSI/OSF........: PSI-2014-24276/EV                                          #
#                  RELATÓRIO DE PRESTADORES, SOCORRISTAS E ESPECIALIDADES.    #
# ........................................................................... #
# DESENVOLVIMENTO: JOSIANE APARECIDA DE ALMEIDA                               #
# LIBERACAO......: 29/10/2014                                                 #
#-----------------------------------------------------------------------------#

database porto

define m_path       char(300)

define mr_pst       record
       pstcoddig    like datrsrrpst.pstcoddig
      ,nomrazsoc    like dpaksocor.nomrazsoc
      ,rspnom       like dpaksocor.rspnom
      ,srrcoddig    like datrsrrpst.srrcoddig
      ,srrnom       like datksrr.srrnom
      ,dddcod       like dpaksocor.dddcod
      ,teltxt       like dpaksocor.teltxt
      ,viginc       like datrsrrpst.viginc
      ,vigfnl       like datrsrrpst.vigfnl
      ,socntzcod    like dbsrntzpstesp.socntzcod
      ,socntzdes    like datksocntz.socntzdes
      ,espcod       like dbskesp.espcod
      ,espdes       like dbskesp.espdes
      ,aux          char(2)
      ,endufd       like dpaksocor.endufd
      ,qldgracod    like dpaksocor.qldgracod
      ,qldgrades    char(200)
      ,endcid       like dpaksocor.endcid
      ,pstobs       like dpaksocor.pstobs
      ,prssitcod    like dpaksocor.prssitcod
      ,prssitdes    char(200)
      ,pcpatvcod    like dpaksocor.pcpatvcod
      ,pcpatvdes    char(200)
      ,lgdtip       like dpaksocor.lgdtip
      ,endlgd       like dpaksocor.endlgd
      ,endcmp       like dpaksocor.endcmp
      ,lgdnum       like dpaksocor.lgdnum
      ,atldat       like dbskesp.atldat
      ,nomgrr       like dpaksocor.nomgrr
      ,cgccpfnum    like dpaksocor.cgccpfnum
      ,cgccpfdig    like dpaksocor.cgccpfdig
      ,cgcord       like dpaksocor.cgcord
      ,caddat       like datksocntz.caddat
      ,ntzatldat    like datksocntz.atldat

end record

define l_data_atual        date,
       l_hora_atual        datetime hour to minute,
       cont                float
       
 
       
#-----------------------------------------#
main
#-----------------------------------------#
   define l_path     char(100),
          l_sql      char(1500),
          l_param    char(100)
   				
   define l_comando  char(700)
         ,l_retorno  smallint
        
   define lr_aux    record
          param     char(025)
   end record


  # -> ABRE O BANCO UTILIZADO PELA CENTRAL 24 HORAS
    call fun_dba_abre_banco("CT24HS")  
  
   let l_data_atual = arg_val(1)
   
    if l_data_atual is null or
       l_data_atual = " " then
    # ---> OBTER A DATA E HORA DO BANCO
   
       call cts40g03_data_hora_banco(2)
         returning l_data_atual,
                   l_hora_atual
    end if
    
    
    call bdbsr027_busca_path()
   
    call bdbsr027_prepare()
   
    set isolation to dirty read
   
    call bdbsr027()

end main 

#-----------------------------------------#
function bdbsr027_busca_path()
#-----------------------------------------#
    define l_dia char(02),
           l_mes char(02),
           l_ano char(04)
   
    # ---> INICIALIZACAO DAS VARIAVEIS
     let m_path = null
     let l_dia  = null
     let l_mes  = null
     let l_ano  = null
   
    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("SAPS","LOG")
   
    if m_path is null then
       let m_path = "."
    end if
   
    let m_path = m_path clipped,"/bdbsr027.log"
   
    call startlog(m_path)
   
    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("SAPS", "RELATO")
   
    if m_path is null then
       let m_path = "."
    end if
    
    let l_dia = day(l_data_atual)
    let l_mes = month(l_data_atual)clipped
    let l_ano = year(l_data_atual)
   
    if l_mes < 10 then 
        let l_mes = "0",l_mes
    end if
     
    let m_path = m_path clipped , '/' 
    
    let m_path = m_path clipped, l_dia clipped, l_mes clipped , l_ano ,"BDBSR027.xls"
   
    display 'm_path: ', m_path clipped

end function    

#-----------------------------------------#
function bdbsr027_prepare()
#-----------------------------------------#
      define l_sql char(9000)       
      

		  let l_sql = 'select  p.srrcoddig, c.nomrazsoc, s.srrnom,         '
		  					 ,'        p.pstcoddig, c.rspnom, e.socntzcod,         '
		  					 ,'        n.socntzdes, e.espcod, k.espdes, p.viginc,  '
		  					 ,'        p.vigfnl, c.endcid, c.endufd, c.qldgracod,  '
		  					 ,'        c.dddcod, c.teltxt, c.pstobs, c.prssitcod,  '
		  					 ,'        c.pcpatvcod, c.lgdtip, c.endlgd, c.endcmp,  '
		  					 ,'        c.lgdnum, k.atldat, c.nomgrr, c.cgccpfnum,  '
		  					 ,'        c.cgccpfdig, c.cgcord, n.caddat, n.atldat   '
                 ,'   from datrsrrpst p,                               '
                 ,'        datksrr s,                                  '       
                 ,'        dpaksocor c,                                '
                 ,'        dbsrntzpstesp e,                            '             
                 ,'        datksocntz n,                               '
                 ,'        dbskesp k,                                  '
                 ,'        DPARPSTEMP emp,                             '
                 ,'        dpakcnd    can                              '            
                 ,' where p.srrcoddig   = s.srrcoddig                  '                     
                 ,'   and p.srrcoddig   = e.srrcoddig                  '                      
                 ,'   and e.socntzcod   = n.socntzcod                  '                       
                 ,"   and n.socntzstt   = 'A'                          "
                 ,"   and c.prssitcod   = 'A'                          "
                 ,'   and emp.ciaempcod = 43                           '
                 ,'   and s.srrstt      = 1                            '
                 ,'   and emp.pstcoddig = c.pstcoddig                  '
                 ,'   and s.srrcoddig = can.srrcoddig                  '
                 ,'   and can.pstcndsitcod = 2                         '
                 ,'   and c.pstcoddig = p.pstcoddig                    '                      
                 ,'   and k.espcod = e.espcod                          '                      
                 ,'   and p.viginc = (select max(n.viginc)             '
                 ,'                     from datrsrrpst n              '       
                 ,'                    where n.pstcoddig = p.pstcoddig '
                 ,'                      and n.srrcoddig = p.srrcoddig)' 

                   prepare p_ps_01 from l_sql
                   declare c_ps_01 cursor for p_ps_01
                   
                   
                   
       let l_sql =    'select cpodes                            '
                     ,' from iddkdominio                       '
                     ," where iddkdominio.cponom = 'qldgracod' "
                     ,'   and iddkdominio.cpocod = ?           ' 
                   
                   prepare p_ps_02 from l_sql
                   declare c_ps_02 cursor for p_ps_02
                   
                   
                   
      let l_sql = 'select cpodes                             '
                     ,' from iddkdominio                       '
                     ," where iddkdominio.cponom = 'pcpatvcod' "
                     ,'   and iddkdominio.cpocod = ?           '
                     
                   prepare p_ps_03 from l_sql
                   declare c_ps_03 cursor for p_ps_03
                   
end function

#-----------------------------------------#
function bdbsr027()
#-----------------------------------------#
	   display " "
     display "******Extraindo relatório de prestadores, socorristas e especialidades******"
     display " "
  
     initialize mr_pst.* to null
     let cont = 0
     let mr_pst.aux = 'A'
     start report bdbsr027_relatorio to m_path
 
     
     open c_ps_01 
		 foreach c_ps_01 into mr_pst.srrcoddig, 
		                      mr_pst.nomrazsoc,
		                      mr_pst.srrnom, 
		                      mr_pst.pstcoddig, 
		                      mr_pst.rspnom,
		                      mr_pst.socntzcod,
		                      mr_pst.socntzdes,
		                      mr_pst.espcod,
		                      mr_pst.espdes,
		                      mr_pst.viginc,
		                      mr_pst.vigfnl,
		                      mr_pst.endcid,
		                      mr_pst.endufd,
		                      mr_pst.qldgracod,
		                      mr_pst.dddcod,
		                      mr_pst.teltxt,
		                      mr_pst.pstobs,
		                      mr_pst.prssitcod,
		                      mr_pst.pcpatvcod,
		                      mr_pst.lgdtip,
                          mr_pst.endlgd,
                          mr_pst.endcmp,
                          mr_pst.lgdnum,
                          mr_pst.atldat,
                          mr_pst.nomgrr,
                          mr_pst.cgccpfnum,
                          mr_pst.cgccpfdig,
                          mr_pst.cgcord,
                          mr_pst.caddat,
                          mr_pst.ntzatldat

   
		    case mr_pst.prssitcod
             when "A"  let mr_pst.prssitdes = "ATIVO"
             when "C"  let mr_pst.prssitdes = "CANCELADO"
             when "P"  let mr_pst.prssitdes = "PROPOSTA"
             when "B"  let mr_pst.prssitdes = "BLOQUEADO"
        end case
     
			  let cont = cont + 1
        
        open c_ps_02 using mr_pst.qldgracod   
        fetch c_ps_02 into mr_pst.qldgrades      
     		                        
        if sqlca.sqlcode <> 0 then
     		   if sqlca.sqlcode <> notfound then
     		      display "Erro SELECT c_ps_02 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     		      exit program(1)
     		   end if
        end if 
        
        open c_ps_03 using mr_pst.pcpatvcod   
        fetch c_ps_03 into mr_pst.pcpatvdes      
     		                        
        if sqlca.sqlcode <> 0 then
     		   if sqlca.sqlcode <> notfound then
     		      display "Erro SELECT c_ps_03 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
     		      exit program(1)
     		   end if
        end if 
        
																		
        	output to report bdbsr027_relatorio()
        	initialize mr_pst.* to null

     end foreach
     
     close c_ps_01
		 close c_ps_02
		 close c_ps_03
     
     finish report bdbsr027_relatorio
     
     call bdbsr027_envia_email()

     display "Relatório extraído!"

end function     
     
#-----------------------------------------#
function bdbsr027_envia_email()
#-----------------------------------------#

     define l_assunto     char(100),
            l_erro_envio  integer,
            l_comando     char(200)

     # ---> INICIALIZACAO DAS VARIAVEIS
     let l_comando    = null
     let l_erro_envio = null
     let l_assunto    = "Relatorio prestador e socorrista"

     # ---> COMPACTA O ARQUIVO DO RELATORIO
     let l_comando = "gzip -f ", m_path

     run l_comando
     let m_path = m_path clipped, ".gz"

     let l_erro_envio = ctx22g00_envia_email("BDBSR027", l_assunto, m_path)

     if l_erro_envio <> 0 then
       if l_erro_envio <> 99 then
          display "Erro ao enviar email(ctx22g00) - ", m_path
       else
          display "Nao existe email cadastrado para o modulo - BDBSR027"
       end if
     end if

end function

#-------------------------------------#
report bdbsr027_relatorio()
#-------------------------------------#

  output
     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

  first page header


   print "COD PRESTADOR",                  ASCII(09), 
         "NOME DE GUERRA",                 ASCII(09),
         "RAZÃO SOCIAL PRESTADOR",         ASCII(09),
         "RESPONSÁVEL",                    ASCII(09), 
         "COD SOCORRISTA",                 ASCII(09), 
         "NOME SOCORRISTA",                ASCII(09), 
         "DDD",                            ASCII(09),
         "TELEFONE",                       ASCII(09),
         "TIPO LOGRADOURO",                ASCII(09),
         "ENDEREÇO LOGRADOURO",            ASCII(09),
         "COMPLEMENTO LOGRADOURO",         ASCII(09),
         "NÚMERO LOGRADOURO",              ASCII(09),
         "MUNICÍPIO",                      ASCII(09),
         "UF",                             ASCII(09),
         "NÚMERO CGC/CPF",                 ASCII(09),
         "ORDEM CGC",                      ASCII(09),
         "DÍGITO CGC/CPF",                 ASCII(09),
         "VIGENCIA INICIAL",               ASCII(09),      
         "VIGENCIA FINAL",                 ASCII(09),
         "COD ATIVIDADE PRINCIPAL",        ASCII(09), 
         "DESCRIÇÃO ATIVIDADE PRINCIPAL",  ASCII(09), 
         "COD NATUREZA",                   ASCII(09), 
         "DESCRIÇÃO NATUREZA",             ASCII(09), 
         "DATA CADASTRO NATUREZA",         ASCII(09),
         "DATA ATUALIZAÇÃO NATUREZA",      ASCII(09),
         "PADRÃO QUALIDADE",               ASCII(09),
         "COD ESPECIALIDADE",              ASCII(09), 
         "DESCRIÇÃO ESPECIALIDADE",        ASCII(09),
         "SITUAÇÃO",                       ASCII(09),
         "OBSERVAÇÕES",                    ASCII(09),
         "DATA ATUALIZAÇÃO ESPECIALIDADE"  

     on every row


     print mr_pst.pstcoddig        , ascii(09);
     print mr_pst.nomgrr           , ascii(09);
     print mr_pst.nomrazsoc        , ascii(09);
     print mr_pst.rspnom           , ascii(09);
     print mr_pst.srrcoddig        , ascii(09);
     print mr_pst.srrnom           , ascii(09);
     print mr_pst.dddcod           , ascii(09);
     print mr_pst.teltxt           , ascii(09);
     print mr_pst.lgdtip           , ascii(09);
     print mr_pst.endlgd           , ascii(09);
     print mr_pst.endcmp           , ascii(09);
     print mr_pst.lgdnum           , ascii(09);
     print mr_pst.endcid           , ascii(09);
     print mr_pst.endufd           , ascii(09);
     print mr_pst.cgccpfnum        , ascii(09);
     print mr_pst.cgcord           , ascii(09);
     print mr_pst.cgccpfdig        , ascii(09);
     print mr_pst.viginc           , ascii(09);
     print mr_pst.vigfnl           , ascii(09);
     print mr_pst.pcpatvcod        , ascii(09);
     print mr_pst.pcpatvdes        , ascii(09);
     print mr_pst.socntzcod        , ascii(09);
     print mr_pst.socntzdes        , ascii(09);
     print mr_pst.caddat           , ascii(09);
     print mr_pst.ntzatldat        , ascii(09);
     print mr_pst.qldgrades        , ascii(09);
     print mr_pst.espcod           , ascii(09);
     print mr_pst.espdes           , ascii(09);
     print mr_pst.prssitdes        , ascii(09);
     print mr_pst.pstobs           , ascii(09);
     print mr_pst.atldat

end report