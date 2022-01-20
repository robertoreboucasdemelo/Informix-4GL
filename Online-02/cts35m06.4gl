#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts35m06                                                   #
# Analista Resp : Marcos Goes                                                #
#                 Modulo para pesquisa de apolices do Itau                   #
#                 para a contingencia.                                       #
#............................................................................#
# Desenvolvimento: Marcos Goes                                               #
# Liberacao      : 24/05/2011                                                #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor          Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#
# 24/05/2011 Marcos Goes               Versao inicial                        #
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'
#database porto


define m_cts35m06_prep smallint

#========================================================================
function cts35m06_prepare()
#========================================================================
   define l_sql         char(3000)
   define l_sql_geral   char(2000)
   
   let l_sql_geral = 
   "SELECT FIRST 1 ",
   "       APL.itaciacod, APL.succod, APL.itaramcod, APL.itaaplnum, ITM.itaaplitmnum, APL.aplseqnum,    ",
   "       APL.segnom, APL.pestipcod, APL.segcgccpfnum, APL.segcgcordnum, APL.segcgccpfdig, ", 
   "       APL.corsus, ITM.itaaplitmsttcod, ITM.autchsnum, ITM.autplcnum, ITM.autfbrnom,    ",
   "       ITM.autlnhnom, ITM.autmodnom, ITM.autmodano, ITM.porvclcod ",
   "FROM datmitaapl APL ",
   "INNER JOIN datmitaaplitm ITM ",
   "   ON APL.itaciacod = ITM.itaciacod ",
   "  AND APL.itaramcod = ITM.itaramcod ",
   "  AND APL.itaaplnum = ITM.itaaplnum ",
   "  AND APL.aplseqnum = ITM.aplseqnum ",
   "WHERE APL.aplseqnum = (SELECT MAX(S.aplseqnum) ",
   "                       FROM datmitaapl S ",
   "                       WHERE S.itaciacod = APL.itaciacod  ",
   "                         AND S.itaramcod = APL.itaramcod  ",
   "                         AND S.itaaplnum = APL.itaaplnum) "


   let l_sql = l_sql_geral,
               "  AND APL.itaaplnum    = ? ",
               "  AND ITM.itaaplitmnum = ? ",
               "ORDER BY ITM.itaaplitmsttcod DESC, ITM.itaaplitmnum "
   prepare p_cts35m06_001 from l_sql
   declare c_cts35m06_001 cursor with hold for p_cts35m06_001

   let l_sql = l_sql_geral,
               "  AND APL.itaaplnum    = ? ",
               "ORDER BY ITM.itaaplitmsttcod DESC, ITM.itaaplitmnum "
   prepare p_cts35m06_002 from l_sql
   declare c_cts35m06_002 cursor with hold for p_cts35m06_002

   let l_sql = l_sql_geral,
               "  AND ITM.autplcnum = ? ",
               "ORDER BY ITM.itaaplitmsttcod DESC, ITM.itaaplitmnum "
   prepare p_cts35m06_003 from l_sql
   declare c_cts35m06_003 cursor with hold for p_cts35m06_003

   let l_sql = l_sql_geral,
               "   AND APL.segcgccpfnum = ? ",
               "   AND APL.segcgcordnum = ? ",
               "   AND APL.segcgccpfdig = ? ",
               "ORDER BY ITM.itaaplitmsttcod DESC, ITM.itaaplitmnum "
   prepare p_cts35m06_004 from l_sql
   declare c_cts35m06_004 cursor with hold for p_cts35m06_004
   
   

   let l_sql = "SELECT succod, aplnumdig, itmnumdig, vcllicnum, ",
               " segnom, cpfnum, cgcord, cpfdig, ciaempcod ",
               "FROM datmcntsrv  ",
               "WHERE seqreg = ? "
   prepare p_cts35m06_011 from l_sql
   declare c_cts35m06_011 cursor with hold for p_cts35m06_011

   let l_sql = "SELECT cpodes ",
               "FROM  datkdominio ",
               "WHERE cponom = 'ligcvntip' ",
               "  AND cpocod = 0 "
   prepare p_cts35m06_012 from l_sql
   declare c_cts35m06_012 cursor with hold for p_cts35m06_012
   
   let l_sql = "SELECT FIRST 1 C.cornom ",
               "FROM gcaksusep B        ",
               "LEFT JOIN gcakcorr C    ",
               "   ON (B.corsuspcp = C.corsuspcp) ",
               "WHERE B.corsus = ? ",
               "ORDER BY B.corsus  "
   prepare p_cts35m06_013 from l_sql
   declare c_cts35m06_013 cursor with hold for p_cts35m06_013

   let l_sql = "SELECT TRIM(NVL(D.vclmrcnom,'')) || ' ' || ",
               "       TRIM(NVL(C.vcltipnom,'')) || ' ' || ", 
               "       TRIM(NVL(B.vclmdlnom,'')) ",
               "FROM agbkveic B ",
               "INNER JOIN agbktip C ",
               "   ON (B.vcltipcod = C.vcltipcod ",
               "   AND B.vclmrccod = C.vclmrccod) ",
               "INNER JOIN agbkmarca D ",
               "   ON (C.vclmrccod = D.vclmrccod) ",
               "WHERE B.vclcoddig = ? "
   prepare p_cts35m06_014 from l_sql
   declare c_cts35m06_014 cursor with hold for p_cts35m06_014


   let m_cts35m06_prep = true

#========================================================================
end function  # fim da funcao cts35m06_prepare
#========================================================================


#========================================================================
function cts35m06_PesquisaApoliceItau(lr_param)
#========================================================================
   define lr_param record
      seqreg      like datmcntsrv.seqreg
   end record

   define lr_contingencia record
       succod     like datmcntsrv.succod
      ,aplnumdig  like datmcntsrv.aplnumdig
      ,itmnumdig  like datmcntsrv.itmnumdig
      ,vcllicnum  like datmcntsrv.vcllicnum
      ,segnom     like datmcntsrv.segnom
      ,cpfnum     like datmcntsrv.cpfnum
      ,cgcord     like datmcntsrv.cgcord
      ,cpfdig     like datmcntsrv.cpfdig
      ,ciaempcod  like datmcntsrv.ciaempcod
   end record
   
   
   define lr_retorno record
       mensagem   char(300)
      ,resultado  smallint     # 1 - Sucesso
      ,segnom     like gsakseg.segnom
      ,corsus     like datmservico.corsus
      ,cornom     like datmservico.cornom
      ,cvnnom     char(20)
      ,vclcoddig  like datmservico.vclcoddig
      ,vclchsinc  like abbmveic.vclchsinc
      ,vclchsfnl  like abbmveic.vclchsfnl
      ,vcldes     like datmcntsrv.vcldes
      ,vclanomdl  like datmcntsrv.vclanomdl
      ,vcllicnum  like datmcntsrv.vcllicnum
   end record

   
   define lr_apolice record
       itaciacod         like datmitaapl.itaciacod      
      ,succod            like datmitaapl.succod      
      ,itaramcod         like datmitaapl.itaramcod      
      ,itaaplnum         like datmitaapl.itaaplnum      
      ,itaaplitmnum      like datmitaaplitm.itaaplitmnum   
      ,aplseqnum         like datmitaapl.aplseqnum      
      ,segnom            like datmitaapl.segnom         
      ,pestipcod         like datmitaapl.pestipcod      
      ,segcgccpfnum      like datmitaapl.segcgccpfnum   
      ,segcgcordnum      like datmitaapl.segcgcordnum   
      ,segcgccpfdig      like datmitaapl.segcgccpfdig   
      ,corsus            like datmitaapl.corsus         
      ,itaaplitmsttcod   like datmitaaplitm.itaaplitmsttcod
      ,autchsnum         like datmitaaplitm.autchsnum      
      ,autplcnum         like datmitaaplitm.autplcnum      
      ,autfbrnom         like datmitaaplitm.autfbrnom      
      ,autlnhnom         like datmitaaplitm.autlnhnom      
      ,autmodnom         like datmitaaplitm.autmodnom      
      ,autmodano         like datmitaaplitm.autmodano 
      ,porvclcod         like datmitaaplitm.porvclcod      
   end record

   define l_achou    smallint
   define l_ano      char(4)

   if m_cts35m06_prep is null or
      m_cts35m06_prep = false then
      call cts35m06_prepare()
   end if

   let l_achou = false

   initialize lr_contingencia.* to null    
   initialize lr_apolice.* to null    

   whenever error continue
   open c_cts35m06_011 using lr_param.seqreg
   fetch c_cts35m06_011 into lr_contingencia.succod
                            ,lr_contingencia.aplnumdig
                            ,lr_contingencia.itmnumdig
                            ,lr_contingencia.vcllicnum
                            ,lr_contingencia.segnom
                            ,lr_contingencia.cpfnum
                            ,lr_contingencia.cgcord
                            ,lr_contingencia.cpfdig
                            ,lr_contingencia.ciaempcod
   whenever error stop
   close c_cts35m06_011


   # Busca pelo numero da apolice e item
   if lr_contingencia.aplnumdig is not null and
      lr_contingencia.aplnumdig <> 0 then
      
      initialize lr_apolice.* to null  
      
      if lr_contingencia.itmnumdig is not null and
         lr_contingencia.itmnumdig <> 0 then

         whenever error continue
         open c_cts35m06_001 using lr_contingencia.aplnumdig
                                  ,lr_contingencia.itmnumdig
         fetch c_cts35m06_001 into lr_apolice.*
         whenever error stop
         close c_cts35m06_001
      
      end if
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pelo numero/item."
      end if
               
   end if


   # Busca pela placa do veiculo
   if not l_achou and
      lr_contingencia.vcllicnum is not null and
      lr_contingencia.vcllicnum <> " " then
      
      initialize lr_apolice.* to null  
      
      whenever error continue
      open c_cts35m06_003 using lr_contingencia.vcllicnum
      fetch c_cts35m06_003 into lr_apolice.*
      whenever error stop
      close c_cts35m06_003
      
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pela placa do veiculo."
      end if
               
   end if


   # Busca pelo numero da apolice
   if not l_achou and
      lr_contingencia.aplnumdig is not null and
      lr_contingencia.aplnumdig <> 0 then
      
      initialize lr_apolice.* to null  
      
      whenever error continue
      open c_cts35m06_002 using lr_contingencia.aplnumdig
      fetch c_cts35m06_002 into lr_apolice.*
      whenever error stop
      close c_cts35m06_002
      
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pelo numero."
      end if
               
   end if
   

   # Busca pelo CPF/CNPJ
   if not l_achou and
      lr_contingencia.cpfnum is not null and
      lr_contingencia.cpfdig is not null then
      
      if lr_contingencia.cgcord is null then
         let lr_contingencia.cgcord = 0
      end if
      
      
      initialize lr_apolice.* to null  
      
      whenever error continue
      open c_cts35m06_004 using lr_contingencia.cpfnum
                               ,lr_contingencia.cgcord
                               ,lr_contingencia.cpfdig
      fetch c_cts35m06_004 into lr_apolice.*
      whenever error stop
      close c_cts35m06_004
      
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pelo CPF/CNPJ do segurado."
      end if
               
   end if

   # Preenchimento das globais - 1
   let g_documento.edsnumref = 0
   let g_documento.ciaempcod = lr_contingencia.ciaempcod

   # Se nao localizou a apolice, informa o erro e retorna
   if l_achou then
      let lr_retorno.resultado = 1
   else
      initialize lr_retorno.* to null
      let lr_retorno.resultado = 2
      let lr_retorno.mensagem = "Apolice ITAU nao localizada."
      #display "resultado: ", lr_retorno.resultado
      #display "mensagem.: ", lr_retorno.mensagem
      
      let lr_retorno.segnom = lr_contingencia.segnom
      let lr_retorno.vcllicnum = lr_contingencia.vcllicnum
      
      return lr_retorno.*
   end if


   # Preenchimento das globais - 2
   let g_documento.itaciacod = lr_apolice.itaciacod 
   let g_documento.succod    = lr_apolice.succod
   let g_documento.ramcod    = lr_apolice.itaramcod
   let g_documento.aplnumdig = lr_apolice.itaaplnum
   let g_documento.itmnumdig = lr_apolice.itaaplitmnum


   #display "GLOBAIS..."
   #display "g_documento.itaciacod : ", g_documento.itaciacod 
   #display "g_documento.succod    : ", g_documento.succod    
   #display "g_documento.ramcod    : ", g_documento.ramcod    
   #display "g_documento.aplnumdig : ", g_documento.aplnumdig 
   #display "g_documento.itmnumdig : ", g_documento.itmnumdig 
   #display "g_documento.edsnumref : ", g_documento.edsnumref 
   #display "g_documento.ciaempcod : ", g_documento.ciaempcod 


   # Preenchimento das variaveis de retorno
   let lr_retorno.segnom = lr_apolice.segnom
   let lr_retorno.corsus = lr_apolice.corsus

   # Busca o nome do corretor
   whenever error continue
   open c_cts35m06_013 using lr_apolice.corsus
   fetch c_cts35m06_013 into lr_retorno.cornom
   whenever error stop
   close c_cts35m06_013

   # Busca o convenio (VERIFICAR)
   whenever error continue
   open c_cts35m06_012
   fetch c_cts35m06_012 into lr_retorno.cvnnom
   whenever error stop
   close c_cts35m06_012

   # Dados do veiculo
   let lr_retorno.vclcoddig = lr_apolice.porvclcod
   let lr_retorno.vclchsinc = lr_apolice.autchsnum[1,12]
   let lr_retorno.vclchsfnl = lr_apolice.autchsnum[13,20]
             


   # Busca o veiculo
   whenever error continue
   open c_cts35m06_014 using lr_apolice.porvclcod
   fetch c_cts35m06_014 into lr_retorno.vcldes
   whenever error stop
   close c_cts35m06_014

   if sqlca.sqlcode <> 0 or
      lr_apolice.porvclcod is null or
      lr_retorno.vcldes is null or
      lr_retorno.vcldes = " " then
      
      let lr_retorno.vcldes = lr_apolice.autfbrnom clipped, " "
                             ,lr_apolice.autlnhnom clipped, " "
                             ,lr_apolice.autmodnom clipped, " "      
   end if


   let l_ano = lr_apolice.autmodano
   let lr_retorno.vclanomdl = l_ano
   let lr_retorno.vcllicnum = lr_apolice.autplcnum

   #display "resultado: ", lr_retorno.resultado
   #display "mensagem.: ", lr_retorno.mensagem

   return lr_retorno.*

#========================================================================
end function  # fim da funcao cts35m06_PesquisaApoliceItau
#========================================================================


{
#========================================================================
function cts35m06_PesquisaApoliceItau_alternativo(lr_contingencia)
#========================================================================

   define lr_contingencia record
       succod     like datmcntsrv.succod
      ,aplnumdig  like datmcntsrv.aplnumdig
      ,itmnumdig  like datmcntsrv.itmnumdig
      ,vcllicnum  like datmcntsrv.vcllicnum
      ,segnom     like datmcntsrv.segnom
      ,cpfnum     like datmcntsrv.cpfnum
      ,cgcord     like datmcntsrv.cgcord
      ,cpfdig     like datmcntsrv.cpfdig
      ,ciaempcod  like datmcntsrv.ciaempcod
   end record
   
   
   define lr_retorno record
       mensagem   char(300)
      ,resultado  smallint     # 1 - Sucesso
      ,segnom     like gsakseg.segnom
      ,corsus     like datmservico.corsus
      ,cornom     like datmservico.cornom
      ,cvnnom     char(20)
      ,vclcoddig  like datmservico.vclcoddig
      ,vclchsinc  like abbmveic.vclchsinc
      ,vclchsfnl  like abbmveic.vclchsfnl
      ,vcldes     like datmcntsrv.vcldes
      ,vclanomdl  like datmcntsrv.vclanomdl
      ,vcllicnum  like datmcntsrv.vcllicnum
   end record

   
   define lr_apolice record
       itaciacod         like datmitaapl.itaciacod      
      ,succod            like datmitaapl.succod      
      ,itaramcod         like datmitaapl.itaramcod      
      ,itaaplnum         like datmitaapl.itaaplnum      
      ,itaaplitmnum      like datmitaaplitm.itaaplitmnum   
      ,aplseqnum         like datmitaapl.aplseqnum      
      ,segnom            like datmitaapl.segnom         
      ,pestipcod         like datmitaapl.pestipcod      
      ,segcgccpfnum      like datmitaapl.segcgccpfnum   
      ,segcgcordnum      like datmitaapl.segcgcordnum   
      ,segcgccpfdig      like datmitaapl.segcgccpfdig   
      ,corsus            like datmitaapl.corsus         
      ,itaaplitmsttcod   like datmitaaplitm.itaaplitmsttcod
      ,autchsnum         like datmitaaplitm.autchsnum      
      ,autplcnum         like datmitaaplitm.autplcnum      
      ,autfbrnom         like datmitaaplitm.autfbrnom      
      ,autlnhnom         like datmitaaplitm.autlnhnom      
      ,autmodnom         like datmitaaplitm.autmodnom      
      ,autmodano         like datmitaaplitm.autmodano 
      ,porvclcod         like datmitaaplitm.porvclcod      
   end record

   define l_achou    smallint
   define l_ano      char(4)

   if m_cts35m06_prep is null or
      m_cts35m06_prep = false then
      call cts35m06_prepare()
   end if

   let l_achou = false
  
   initialize lr_apolice.* to null    

   # Busca pelo numero da apolice e item
   if lr_contingencia.aplnumdig is not null and
      lr_contingencia.aplnumdig <> 0 then
      
      initialize lr_apolice.* to null  
      
      if lr_contingencia.itmnumdig is not null and
         lr_contingencia.itmnumdig <> 0 then

         whenever error continue
         open c_cts35m06_001 using lr_contingencia.aplnumdig
                                  ,lr_contingencia.itmnumdig
         fetch c_cts35m06_001 into lr_apolice.*
         whenever error stop
         close c_cts35m06_001
      
      end if
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pelo numero/item."
      end if
               
   end if


   # Busca pela placa do veiculo
   if not l_achou and
      lr_contingencia.vcllicnum is not null and
      lr_contingencia.vcllicnum <> " " then
      
      initialize lr_apolice.* to null  
      
      whenever error continue
      open c_cts35m06_003 using lr_contingencia.vcllicnum
      fetch c_cts35m06_003 into lr_apolice.*
      whenever error stop
      close c_cts35m06_003
      
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pela placa do veiculo."
      end if
               
   end if


   # Busca pelo numero da apolice
   if not l_achou and
      lr_contingencia.aplnumdig is not null and
      lr_contingencia.aplnumdig <> 0 then
      
      initialize lr_apolice.* to null  
      
      whenever error continue
      open c_cts35m06_002 using lr_contingencia.aplnumdig
      fetch c_cts35m06_002 into lr_apolice.*
      whenever error stop
      close c_cts35m06_002
      
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pelo numero."
      end if
               
   end if


   # Busca pelo CPF/CNPJ
   if not l_achou and
      lr_contingencia.cpfnum is not null and
      lr_contingencia.cpfdig is not null then
      
      if lr_contingencia.cgcord is null then
         let lr_contingencia.cgcord = 0
      end if
      
      
      initialize lr_apolice.* to null  
      
      whenever error continue
      open c_cts35m06_004 using lr_contingencia.cpfnum
                               ,lr_contingencia.cgcord
                               ,lr_contingencia.cpfdig
      fetch c_cts35m06_004 into lr_apolice.*
      whenever error stop
      close c_cts35m06_004
      
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pelo CPF/CNPJ do segurado."
      end if
               
   end if


   # Se nao localizou a apolice, informa o erro e retorna
   if l_achou then
      let lr_retorno.resultado = 1
   else
      initialize lr_retorno.* to null
      let lr_retorno.resultado = 2
      let lr_retorno.mensagem = "Apolice ITAU nao localizada."
      return lr_retorno.*
   end if


   # Preenchimento das globais
   display "GLOBAIS..."
   display "g_documento.succod    : ", lr_apolice.succod     
   display "g_documento.ramcod    : ", lr_apolice.itaramcod     
   display "g_documento.aplnumdig : ", lr_apolice.itaaplnum     
   display "g_documento.itmnumdig : ", lr_apolice.itaaplitmnum  
   display "g_documento.edsnumref : ", "0"                        
   display "g_documento.ciaempcod : ", lr_contingencia.ciaempcod
   

   ##let g_documento.succod    = lr_apolice.succod
   ##let g_documento.ramcod    = lr_apolice.itaramcod
   ##let g_documento.aplnumdig = lr_apolice.itaaplnum
   ##let g_documento.itmnumdig = lr_apolice.itaaplitmnum
   ##let g_documento.edsnumref = 0
   ##let g_documento.ciaempcod = lr_contingencia.ciaempcod



   # Preenchimento das variaveis de retorno
   let lr_retorno.segnom = lr_apolice.segnom
   let lr_retorno.corsus = lr_apolice.corsus

   # Busca o nome do corretor
   whenever error continue
   open c_cts35m06_013 using lr_apolice.corsus
   fetch c_cts35m06_013 into lr_retorno.cornom
   whenever error stop
   close c_cts35m06_013

   # Busca o convenio (VERIFICAR)
   whenever error continue
   open c_cts35m06_012
   fetch c_cts35m06_012 into lr_retorno.cvnnom
   whenever error stop
   close c_cts35m06_012

   # Dados do veiculo
   let lr_retorno.vclcoddig = lr_apolice.porvclcod
   let lr_retorno.vclchsinc = lr_apolice.autchsnum[1,12]
   let lr_retorno.vclchsfnl = lr_apolice.autchsnum[13,20]
             


   # Busca o veiculo
   whenever error continue
   open c_cts35m06_014 using lr_apolice.porvclcod
   fetch c_cts35m06_014 into lr_retorno.vcldes
   whenever error stop
   close c_cts35m06_014

   if sqlca.sqlcode <> 0 or
      lr_apolice.porvclcod is null or
      lr_retorno.vcldes is null or
      lr_retorno.vcldes = " " then
      
      let lr_retorno.vcldes = lr_apolice.autfbrnom clipped, " "
                             ,lr_apolice.autlnhnom clipped, " "
                             ,lr_apolice.autmodnom clipped, " "      
   end if

   let l_ano = lr_apolice.autmodano
   let lr_retorno.vclanomdl = l_ano
   let lr_retorno.vcllicnum = lr_apolice.autplcnum

   return lr_retorno.*

#========================================================================
end function  # fim da funcao cts35m06_PesquisaApoliceItau
#========================================================================
}