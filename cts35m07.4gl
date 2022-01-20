#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts35m07                                                   #
# Analista Resp : JUNIOR (FORNAX)                                            #
#                 Modulo para pesquisa de apolices do Itau                   #
#                 para a contingencia.                                       #
#............................................................................#
# Desenvolvimento: Junior (FORNAX)                                           #
# Liberacao      :   /  /                                                    #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor          Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#
#   /  /                                                                     #
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'
#database porto


define m_cts35m07_prep smallint

#========================================================================
function cts35m07_prepare()
#========================================================================
   define l_sql         char(3000)
   define l_sql_geral   char(2000)
   
   let l_sql_geral = 
   "SELECT FIRST 1 ",
   "       APL.itaciacod, APL.succod, APL.itaramcod, APL.aplnum, ITM.aplitmnum, APL.aplseqnum,    ",
   "       APL.segnom, APL.pestipcod, APL.segcpjcpfnum, APL.cpjordnum, APL.cpjcpfdignum, ", 
   "       APL.suscod, ITM.itmsttcod ",
   "FROM datmresitaapl APL ",
   "INNER JOIN datmresitaaplitm ITM ",
   "   ON APL.itaciacod = ITM.itaciacod ",
   "  AND APL.itaramcod = ITM.itaramcod ",
   "  AND APL.aplnum    = ITM.aplnum    ",
   "  AND APL.aplseqnum = ITM.aplseqnum ",
   "WHERE APL.aplseqnum = (SELECT MAX(S.aplseqnum) ",
   "                       FROM datmresitaapl S ",
   "                       WHERE S.itaciacod = APL.itaciacod  ",
   "                         AND S.itaramcod = APL.itaramcod  ",
   "                         AND S.aplnum    = APL.aplnum)    "


   let l_sql = l_sql_geral,
               "  AND APL.aplnum    = ? ",
               "  AND ITM.aplitmnum = ? ",
               "ORDER BY ITM.itmsttcod DESC, ITM.aplitmnum "
   prepare p_cts35m07_001 from l_sql
   declare c_cts35m07_001 cursor with hold for p_cts35m07_001

   let l_sql = l_sql_geral,
               "  AND APL.aplnum    = ? ",
               "ORDER BY ITM.itmsttcod DESC, ITM.aplitmnum "
   prepare p_cts35m07_002 from l_sql
   declare c_cts35m07_002 cursor with hold for p_cts35m07_002

   let l_sql = l_sql_geral,
               "   AND APL.segcpjcpfnum = ? ",
               "   AND APL.cpjordnum    = ? ",
               "   AND APL.cpjcpfdignum = ? ",
               "ORDER BY ITM.itmsttcod DESC, ITM.aplitmnum "
   prepare p_cts35m07_004 from l_sql
   declare c_cts35m07_004 cursor with hold for p_cts35m07_004

   let l_sql = "SELECT succod, aplnumdig, itmnumdig, vcllicnum, ",
               " segnom, cpfnum, cgcord, cpfdig, ciaempcod ",
               "FROM datmcntsrv  ",
               "WHERE seqreg = ? "
   prepare p_cts35m07_011 from l_sql
   declare c_cts35m07_011 cursor with hold for p_cts35m07_011

   let l_sql = "SELECT cpodes ",
               "FROM  datkdominio ",
               "WHERE cponom = 'ligcvntip' ",
               "  AND cpocod = 0 "
   prepare p_cts35m07_012 from l_sql
   declare c_cts35m07_012 cursor with hold for p_cts35m07_012
   
   let l_sql = "SELECT FIRST 1 C.cornom ",
               "FROM gcaksusep B        ",
               "LEFT JOIN gcakcorr C    ",
               "   ON (B.corsuspcp = C.corsuspcp) ",
               "WHERE B.corsus = ? ",
               "ORDER BY B.corsus  "
   prepare p_cts35m07_013 from l_sql
   declare c_cts35m07_013 cursor with hold for p_cts35m07_013

   let m_cts35m07_prep = true

#========================================================================
end function  # fim da funcao cts35m07_prepare
#========================================================================


#========================================================================
function cts35m07_PesquisaApoliceItau(lr_param)
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
   end record

   
   define lr_apolice record
       itaciacod         like datmresitaapl.itaciacod      
      ,succod            like datmresitaapl.succod      
      ,itaramcod         like datmresitaapl.itaramcod      
      ,aplnum            like datmresitaapl.aplnum      
      ,aplitmnum         like datmresitaaplitm.aplitmnum   
      ,aplseqnum         like datmresitaapl.aplseqnum      
      ,segnom            like datmresitaapl.segnom         
      ,pestipcod         like datmresitaapl.pestipcod      
      ,segcpjcpfnum      like datmresitaapl.segcpjcpfnum   
      ,cpjordnum         like datmresitaapl.cpjordnum   
      ,cpjcpfdignum      like datmresitaapl.cpjcpfdignum   
      ,suscod            like datmresitaapl.suscod         
      ,itmsttcod         like datmresitaaplitm.itmsttcod
   end record

   define l_achou    smallint
   define l_ano      char(4)

   if m_cts35m07_prep is null or
      m_cts35m07_prep = false then
      call cts35m07_prepare()
   end if

   let l_achou = false

   initialize lr_contingencia.* to null    
   initialize lr_apolice.* to null    

   whenever error continue
   open c_cts35m07_011 using lr_param.seqreg
   fetch c_cts35m07_011 into lr_contingencia.succod
                            ,lr_contingencia.aplnumdig
                            ,lr_contingencia.itmnumdig
                            ,lr_contingencia.vcllicnum
                            ,lr_contingencia.segnom
                            ,lr_contingencia.cpfnum
                            ,lr_contingencia.cgcord
                            ,lr_contingencia.cpfdig
                            ,lr_contingencia.ciaempcod
   whenever error stop
   close c_cts35m07_011


   # Busca pelo numero da apolice e item
   if lr_contingencia.aplnumdig is not null and
      lr_contingencia.aplnumdig <> 0 then
      
      initialize lr_apolice.* to null  
      
      if lr_contingencia.itmnumdig is not null and
         lr_contingencia.itmnumdig <> 0 then

         whenever error continue
         open c_cts35m07_001 using lr_contingencia.aplnumdig
                                  ,lr_contingencia.itmnumdig
         fetch c_cts35m07_001 into lr_apolice.*
         whenever error stop
         close c_cts35m07_001
      
      end if
      
      if sqlca.sqlcode = 0 and
         lr_apolice.aplseqnum is not null then
         
         let l_achou = true
         let lr_retorno.mensagem = "Apolice ITAU localizada pelo numero/item."
      end if
               
   end if


   # Busca pelo numero da apolice
   if not l_achou and
      lr_contingencia.aplnumdig is not null and
      lr_contingencia.aplnumdig <> 0 then
      
      initialize lr_apolice.* to null  
      
      whenever error continue
      open c_cts35m07_002 using lr_contingencia.aplnumdig
      fetch c_cts35m07_002 into lr_apolice.*
      whenever error stop
      close c_cts35m07_002
      
      
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
      open c_cts35m07_004 using lr_contingencia.cpfnum
                               ,lr_contingencia.cgcord
                               ,lr_contingencia.cpfdig
      fetch c_cts35m07_004 into lr_apolice.*
      whenever error stop
      close c_cts35m07_004
      
      
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
      
      return lr_retorno.*
   end if

   # Preenchimento das globais - 2
   let g_documento.itaciacod = lr_apolice.itaciacod 
   let g_documento.succod    = lr_apolice.succod
   let g_documento.ramcod    = lr_apolice.itaramcod
   let g_documento.aplnumdig = lr_apolice.aplnum
   let g_documento.itmnumdig = lr_apolice.aplitmnum

   # Preenchimento das variaveis de retorno
   let lr_retorno.segnom = lr_apolice.segnom
   let lr_retorno.corsus = lr_apolice.suscod

   # Busca o nome do corretor
   whenever error continue
   open c_cts35m07_013 using lr_apolice.suscod
   fetch c_cts35m07_013 into lr_retorno.cornom
   whenever error stop
   close c_cts35m07_013

   # Busca o convenio (VERIFICAR)
   whenever error continue
   open c_cts35m07_012
   fetch c_cts35m07_012 into lr_retorno.cvnnom
   whenever error stop
   close c_cts35m07_012

   return lr_retorno.*

#========================================================================
end function  # fim da funcao cts35m07_PesquisaApoliceItau
#========================================================================


{
#========================================================================
function cts35m07_PesquisaApoliceItau_alternativo(lr_contingencia)
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
      ,itmsttcod         like datmitaaplitm.itmsttcod
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

   if m_cts35m07_prep is null or
      m_cts35m07_prep = false then
      call cts35m07_prepare()
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
         open c_cts35m07_001 using lr_contingencia.aplnumdig
                                  ,lr_contingencia.itmnumdig
         fetch c_cts35m07_001 into lr_apolice.*
         whenever error stop
         close c_cts35m07_001
      
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
      open c_cts35m07_003 using lr_contingencia.vcllicnum
      fetch c_cts35m07_003 into lr_apolice.*
      whenever error stop
      close c_cts35m07_003
      
      
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
      open c_cts35m07_002 using lr_contingencia.aplnumdig
      fetch c_cts35m07_002 into lr_apolice.*
      whenever error stop
      close c_cts35m07_002
      
      
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
      open c_cts35m07_004 using lr_contingencia.cpfnum
                               ,lr_contingencia.cgcord
                               ,lr_contingencia.cpfdig
      fetch c_cts35m07_004 into lr_apolice.*
      whenever error stop
      close c_cts35m07_004
      
      
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
   open c_cts35m07_013 using lr_apolice.corsus
   fetch c_cts35m07_013 into lr_retorno.cornom
   whenever error stop
   close c_cts35m07_013

   # Busca o convenio (VERIFICAR)
   whenever error continue
   open c_cts35m07_012
   fetch c_cts35m07_012 into lr_retorno.cvnnom
   whenever error stop
   close c_cts35m07_012

   return lr_retorno.*

#========================================================================
end function  # fim da funcao cts35m07_PesquisaApoliceItau
#========================================================================
}
