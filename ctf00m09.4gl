################################################################################
# Sistema  : CTS      - Central 24 Horas                             MAIO/2010 #
# Modulo   : ctf00m09 - Apura Servicos Realizados na Apolice por Seq.Local de  #
#                       Risco/Bloco totalizando por Assunto/Natureza p/ RS - RE#
#                       Sera utilizada tanto p/ Informix quanto p/ Web         #
# Analista : Carla Rampazzo                                                    #
#------------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                             #
#------------------------------------------------------------------------------#
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
################################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'


database porto

define mr_param       record
       prporg         like datrligprp.prporg
      ,prpnumdig      like datrligprp.prpnumdig
      ,succod         like datrservapol.succod
      ,ramcod         like datrservapol.ramcod
      ,aplnumdig      like datrservapol.aplnumdig
      ,origem         char(03) --> IFX - Informix / WEB - Portal
end record


define mr_ret_ifx   record
       coderro      smallint
      ,deserro      char(1000)
      ,qtd_reg      smallint
end record

define mr_ret_web   record
       coderro      smallint
      ,deserro      char(1000)
      ,xml          char(32766)
end record


#-------------------------------------------------------------------------------
function ctf00m09(lr_param)
#-------------------------------------------------------------------------------

   define lr_param       record
          prporg         like datrligprp.prporg
         ,prpnumdig      like datrligprp.prpnumdig
         ,succod         like datrservapol.succod
         ,ramcod         like datrservapol.ramcod
         ,aplnumdig      like datrservapol.aplnumdig
         ,origem         char(03) --> IFX - Informix / WEB - Portal
   end record

   define l_xml          char(32766)
         ,l_coderro      smallint

   initialize mr_ret_ifx.*
             ,mr_ret_web.*        
             ,l_coderro   to null
  
   set isolation to dirty read

   let mr_ret_ifx.coderro = 0
   let mr_ret_web.coderro = 0

   ---> Valida Origem da Chamada
   if (lr_param.origem <> "IFX" and
       lr_param.origem <> "WEB"     ) or 
       lr_param.origem is null        or  
       lr_param.origem =  " "         then

      let mr_ret_ifx.qtd_reg = 0    
      let mr_ret_ifx.coderro = 1   
      let mr_ret_ifx.deserro = "Parametro de Origem Invalido ->",mr_param.origem

      return mr_ret_ifx.coderro
            ,mr_ret_ifx.deserro
            ,mr_ret_ifx.qtd_reg 
   end if

   ---> Atribui parametros para variavel modular
   let mr_param.* = lr_param.*
 

   ---> Cria tabela temporaria 
   call ctf00m09_cria_temporaria()
        returning l_coderro

   if l_coderro <> 0 then

      if mr_param.origem = "WEB" then 

         call ctf00m06_xmlerro ("SERVICOS_ATENDIDOS_DOCUMENTO"
                                ,mr_ret_web.coderro
                                ,mr_ret_web.deserro)
                       returning mr_ret_web.xml
         return mr_ret_web.xml
      else
         return mr_ret_ifx.coderro
               ,mr_ret_ifx.deserro
               ,mr_ret_ifx.qtd_reg 
      end if
   end if


   ---> Monta Prepares
   call ctf00m09_prepare()


   ---> Apura Dados da Consulta 
   call ctf00m09_extrai_dados()     
	returning l_coderro

   if l_coderro <> 0 then

      if mr_param.origem = "WEB" then 

         call ctf00m06_xmlerro ("SERVICOS_ATENDIDOS_DOCUMENTO"
                                ,mr_ret_web.coderro
                                ,mr_ret_web.deserro)
                       returning mr_ret_web.xml
         return mr_ret_web.xml
      else
         return mr_ret_ifx.coderro
               ,mr_ret_ifx.deserro
               ,mr_ret_ifx.qtd_reg 
      end if
   end if


   if mr_param.origem = "WEB" then 
      ---> Gera XML para utilizacao pela Web - Portal do Segurado
      call ctf00m09_gera_xml()
           returning mr_ret_web.xml

      return mr_ret_web.xml
   else

      ---> Carrega Globais com totalizacao dos Assuntos 
      call ctf00m09_carrega_ifx()
	               returning mr_ret_ifx.qtd_reg

      return mr_ret_ifx.coderro
            ,mr_ret_ifx.deserro
            ,mr_ret_ifx.qtd_reg 

   end if

end function

#-------------------------------------------------------------------------------
function ctf00m09_prepare()
#-------------------------------------------------------------------------------

   define l_sql           char(3000)

   initialize l_sql to null

   #--------------------------------------------
   # Verifica se Atendimento ja consta na Tabela
   #--------------------------------------------
   let l_sql = " select atdsrvnum "
                ," from ctf00m09_servicos "
               ," where lclnumseq = ? " 
               ,"   and rmerscseq = ? "
               ,"   and c24astcod = ? "
               ,"   and atdsrvnum = ? "
               ,"   and atdsrvano = ? "
               ,"   and lignum    = ? "
   prepare pctf00m09001 from l_sql 
   declare cctf00m09001 cursor for pctf00m09001

   #-------------------------
   # Ultima Estapa do Servico
   #-------------------------
   let l_sql = "select a.atdetpcod     ",
               "  from datmsrvacp a   ",
               " where a.atdsrvnum = ? ",
               "   and a.atdsrvano = ? ",
               "   and a.atdsrvseq = (select max(b.atdsrvseq) ",
                                   "  from datmsrvacp b    ",
                                   " where b.atdsrvnum = a.atdsrvnum  ",
                                   "   and b.atdsrvano = a.atdsrvano )"
   prepare pctf00m09002 from l_sql
   declare cctf00m09002 cursor for pctf00m09002


   #----------------------
   # Descricao da Natureza
   #----------------------
   let l_sql = "select socntzdes     "
              ,"  from datksocntz    "
              ," where socntzcod = ? "
   prepare pctf00m09003 from l_sql
   declare cctf00m09003 cursor for pctf00m09003


   #----------------------------------
   # Insere Dados em tabela Temporaria
   #----------------------------------
   let l_sql = " insert into ctf00m09_servicos   (lclnumseq "
                                              ," ,rmerscseq "
                                              ," ,c24astcod "
                                              ," ,atdsrvnum "
                                              ," ,atdsrvano "
                                              ," ,lignum    "
                                              ," ,socntzcod "
                                              ," ,socntzdes)"
                                        ," values(?,?,?,?,?,?,?,?)"
   prepare pctf00m09004 from l_sql


end function

#-------------------------------------------------------------------------------
function ctf00m09_extrai_dados()
#-------------------------------------------------------------------------------

   define lr_ctf00m09    record
          atdsrvnum      decimal(10,0)
         ,atdsrvano      decimal(2,0)
         ,socntzcod      like datksocntz.socntzcod
         ,c24pbmcod      smallint
         ,c24pbmdes      char(40)
         ,c24astcod      like datkassunto.c24astcod
         ,lignum         like datmligacao.lignum
         ,lclnumseq      like datmsrvre.lclnumseq 
         ,rmerscseq      like datmsrvre.rmerscseq
         ,atdetpcod      like datmsrvacp.atdetpcod
         ,socntzdes      like datksocntz.socntzdes
   end record

   define l_aux          record
          sql            char (700)
         ,viginc         like abbmdoc.viginc
         ,vigfnl         like abbmdoc.vigfnl
   end record

   initialize  lr_ctf00m09.*  
              ,l_aux.*        to null


   ---> Valida Parametros
   if (mr_param.succod    is null  or
       mr_param.ramcod    is null  or
       mr_param.aplnumdig is null    ) and 
      (mr_param.prporg    is null  or   
       mr_param.prpnumdig is null    ) then  

      if mr_param.origem = "WEB" then
         let mr_ret_web.coderro = 1   
         let mr_ret_web.deserro = "Parametros de entrada invalidos -->"
                                 ," Sucursal: " , mr_param.succod   
                                 ," Ramo: "     , mr_param.ramcod   
                                 ," Apolice: "  , mr_param.aplnumdig 
                                 ," Origem : "  , mr_param.prporg 
                                 ," Proposta:"  , mr_param.prpnumdig 
      else  
         let mr_ret_ifx.coderro = 1   
         let mr_ret_ifx.deserro = "Parametros de entrada invalidos -->"
                                 ," Sucursal: " , mr_param.succod   
                                 ," Ramo: "     , mr_param.ramcod   
                                 ," Apolice: "  , mr_param.aplnumdig 
                                 ," Origem : "  , mr_param.prporg 
                                 ," Proposta:"  , mr_param.prpnumdig 
      end if
      return 999
   end if


   #--------------------------------------
   # Busca Servicos Abertos para a Apolice
   #--------------------------------------
   declare cctf00m09006 cursor with hold for
      select b.atdsrvnum
            ,b.atdsrvano
            ,c.c24astcod
            ,c.lignum
            ,d.lclnumseq
            ,d.rmerscseq
            ,d.socntzcod
        from datrservapol a
            ,datmservico  b
            ,datmligacao  c
            ,datmsrvre    d
       where a.aplnumdig =  mr_param.aplnumdig
         and a.succod    =  mr_param.succod
         and a.ramcod    =  mr_param.ramcod
         and a.itmnumdig =  0                
         and a.atdsrvnum >  0
         and a.atdsrvano >  0
         and a.atdsrvnum =  b.atdsrvnum
         and a.atdsrvano =  b.atdsrvano
         and c.atdsrvnum =  b.atdsrvnum
         and c.atdsrvano =  b.atdsrvano
         and d.atdsrvnum =  b.atdsrvnum
         and d.atdsrvano =  b.atdsrvano
       order by 1,2

   foreach cctf00m09006 into lr_ctf00m09.atdsrvnum
                            ,lr_ctf00m09.atdsrvano
                            ,lr_ctf00m09.c24astcod
                            ,lr_ctf00m09.lignum
                            ,lr_ctf00m09.lclnumseq
                            ,lr_ctf00m09.rmerscseq
                            ,lr_ctf00m09.socntzcod

      #-------------------------
      # Ultima Estapa do Servico
      #-------------------------
      whenever error continue
      open  cctf00m09002 using lr_ctf00m09.atdsrvnum
                              ,lr_ctf00m09.atdsrvano
      fetch cctf00m09002 into  lr_ctf00m09.atdetpcod


      if sqlca.sqlcode <> 0 then
     
         if mr_param.origem = "WEB" then
	  
            let mr_ret_web.coderro = sqlca.sqlcode
            let mr_ret_web.deserro = "Status do Servico: cctf00m09002 "
         else
            let mr_ret_ifx.coderro = sqlca.sqlcode
            let mr_ret_ifx.deserro = "Status do Servico: cctf00m09002 "
         end if
         return 999
      end if

      close cctf00m09002
      whenever error stop

      ---> Considera todos os Servicos, menos os Cancelados
      if lr_ctf00m09.atdetpcod > 4 then  
         initialize lr_ctf00m09.* to null
	 continue foreach
      end if

      initialize lr_ctf00m09.socntzdes to null 


      ---> Descricao da Natureza
      whenever error continue
      open  cctf00m09003 using lr_ctf00m09.socntzcod
      fetch cctf00m09003 into  lr_ctf00m09.socntzdes


      if sqlca.sqlcode <> 0   and   
         sqlca.sqlcode <> 100 then

         if mr_param.origem = "WEB" then
            let mr_ret_web.coderro = sqlca.sqlcode
            let mr_ret_web.deserro = "Descricao da Natureza: cctf00m09003 "
         else
            let mr_ret_ifx.coderro = sqlca.sqlcode
            let mr_ret_ifx.deserro = "Descricao da Natureza: cctf00m09003 "
         end if 
         return 999
      end if 

      close cctf00m09003
      whenever error stop

      ---> Verifica se Registro foi gravado na Temp
      open  cctf00m09001 using lr_ctf00m09.lclnumseq
                              ,lr_ctf00m09.rmerscseq
                              ,lr_ctf00m09.c24astcod
                              ,lr_ctf00m09.atdsrvnum
                              ,lr_ctf00m09.atdsrvano
                              ,lr_ctf00m09.lignum
      fetch cctf00m09001

      if sqlca.sqlcode > 0 then

         ---> Insere dados em Tabela Temporaria
         whenever error continue
         execute pctf00m09004 using lr_ctf00m09.lclnumseq
                                   ,lr_ctf00m09.rmerscseq
                                   ,lr_ctf00m09.c24astcod
                                   ,lr_ctf00m09.atdsrvnum
                                   ,lr_ctf00m09.atdsrvano
                                   ,lr_ctf00m09.lignum
                                   ,lr_ctf00m09.socntzcod
                                   ,lr_ctf00m09.socntzdes 

         if sqlca.sqlcode <> 0 then

            if mr_param.origem = "WEB" then
               let mr_ret_web.coderro = sqlca.sqlcode
               let mr_ret_web.deserro = "Descricao do Problema: pctf00m09004 "
            else    
               let mr_ret_ifx.coderro = sqlca.sqlcode
               let mr_ret_ifx.deserro = "Descricao do Problema: pctf00m09004 "
            end if 
            return 999
         end if 
      end if 

      whenever error stop
   end foreach

   initialize lr_ctf00m09.* to null

   if mr_param.prpnumdig is not null and
      mr_param.prpnumdig <> 0        then

      #---------------------------------------
      # Busca Servicos Abertos para a Proposta
      #---------------------------------------
      declare cctf00m09007 cursor with hold for
         select b.atdsrvnum
               ,b.atdsrvano
               ,c.c24astcod
               ,c.lignum
               ,d.lclnumseq
               ,d.rmerscseq
               ,d.socntzcod
           from datrligprp   a
               ,datmservico  b
               ,datmligacao  c
               ,datmsrvre    d
          where a.prporg    =  mr_param.prporg
            and a.prpnumdig =  mr_param.prpnumdig
            and a.lignum    =  c.lignum
            and c.atdsrvnum =  b.atdsrvnum
            and c.atdsrvano =  b.atdsrvano
            and d.atdsrvnum =  b.atdsrvnum
            and d.atdsrvano =  b.atdsrvano
          order by 1,2

      foreach cctf00m09007 into lr_ctf00m09.atdsrvnum
                               ,lr_ctf00m09.atdsrvano
                               ,lr_ctf00m09.c24astcod
                               ,lr_ctf00m09.lignum
                               ,lr_ctf00m09.lclnumseq
                               ,lr_ctf00m09.rmerscseq
                               ,lr_ctf00m09.socntzcod


         #-------------------------
         # Ultima Estapa do Servico
         #-------------------------
         whenever error continue
         open  cctf00m09002 using lr_ctf00m09.atdsrvnum
                                 ,lr_ctf00m09.atdsrvano
         fetch cctf00m09002 into  lr_ctf00m09.atdetpcod


         if sqlca.sqlcode <> 0 then
     
            if mr_param.origem = "WEB" then
	  
               let mr_ret_web.coderro = sqlca.sqlcode
               let mr_ret_web.deserro = "Status do Servico: cctf00m09002 "
            else
               let mr_ret_ifx.coderro = sqlca.sqlcode
               let mr_ret_ifx.deserro = "Status do Servico: cctf00m09002 "
            end if
            return 999
         end if

         close cctf00m09002
         whenever error stop

         ---> Considera todos os Servicos, menos os Cancelados
         if lr_ctf00m09.atdetpcod > 4 then  
            initialize lr_ctf00m09.* to null
	    continue foreach
         end if

         initialize lr_ctf00m09.socntzdes to null  


         ---> Descricao da Natureza
         whenever error continue
         open  cctf00m09003 using lr_ctf00m09.socntzcod
         fetch cctf00m09003 into  lr_ctf00m09.socntzdes


         if sqlca.sqlcode <> 0   and   
            sqlca.sqlcode <> 100 then

            if mr_param.origem = "WEB" then
               let mr_ret_web.coderro = sqlca.sqlcode
               let mr_ret_web.deserro = "Descricao da Natureza: cctf00m09003 "
            else
               let mr_ret_ifx.coderro = sqlca.sqlcode
               let mr_ret_ifx.deserro = "Descricao da Natureza: cctf00m09003 "
            end if 
            return 999
         end if 

         close cctf00m09003
         whenever error stop

         ---> Verifica se Registro foi gravado na Temp
         open  cctf00m09001 using lr_ctf00m09.lclnumseq
                                 ,lr_ctf00m09.rmerscseq
                                 ,lr_ctf00m09.c24astcod
                                 ,lr_ctf00m09.atdsrvnum
                                 ,lr_ctf00m09.atdsrvano
                                 ,lr_ctf00m09.lignum
         fetch cctf00m09001

         if sqlca.sqlcode > 0 then

            ---> Insere dados em Tabela Temporaria
            whenever error continue
            execute pctf00m09004 using lr_ctf00m09.lclnumseq
                                      ,lr_ctf00m09.rmerscseq
                                      ,lr_ctf00m09.c24astcod
                                      ,lr_ctf00m09.atdsrvnum
                                      ,lr_ctf00m09.atdsrvano
                                      ,lr_ctf00m09.lignum
                                      ,lr_ctf00m09.socntzcod
                                      ,lr_ctf00m09.socntzdes 

            if sqlca.sqlcode <> 0 then

               if mr_param.origem = "WEB" then
                  let mr_ret_web.coderro = sqlca.sqlcode
                  let mr_ret_web.deserro = "Descricao do Problema: pctf00m09004"
               else    
                  let mr_ret_ifx.coderro = sqlca.sqlcode
                  let mr_ret_ifx.deserro = "Descricao do Problema: pctf00m09004"
               end if 
               return 999
            end if 
         end if 

         whenever error stop
      end foreach
   end if 

   set isolation to committed read

   return 0

end function  ###  ctf00m09


#-------------------------------------------------------------------------------
function ctf00m09_gera_xml()
#-------------------------------------------------------------------------------

   define lr_ctf00m09    record
          lclnumseq      like datmsrvre.lclnumseq
         ,rmerscseq      like datmsrvre.rmerscseq
         ,c24astcod      like datkassunto.c24astcod
         ,socntzcod      like datksocntz.socntzcod
         ,socntzdes      like datksocntz.socntzdes
         ,qtd_atd        smallint
   end record

   ---> Vairiaveis com tipo char p/ retirar espacos em branco no xml
   define lr_c_ctf00m09  record
          lclnumseq      char(4) 
         ,rmerscseq      char(5)
         ,socntzcod      char(5)   
         ,qtd_atd        char(5)   
   end record

   define l_alt          record      
          flag smallint     
         ,retcod integer   ---> 0-SIM / <> 0-NAO    
         ,retmsg char(80)
   end record


   define l_ret        record    
          garantia    smallint -->Retorna True qdo Data Servico eh < que 90 dias
         ,complemento smallint -->Retorna True qdo Data Servico eh < que 30 dias
         ,retcod      integer  -->0-SIM / <> 0-NAO    
         ,retmsg      char(80)
   end record


   define l_xml          char(32766)
	 ,l_cont         smallint
	 ,l_qtd1         smallint

   initialize lr_ctf00m09.* 
             ,l_alt.*
             ,l_ret.*
             ,l_cont
	     ,l_xml        to null

   let l_qtd1 = 0
  
   let l_xml= 
       "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
      ,"<SERVICO>SERVICOS_RS_RE</SERVICO>"

   ---> Apura servicos totalizados                 
   let l_xml= l_xml clipped
       ,"<ATENDIMENTOS>"


   #----------------
   # Locais de Risco
   #----------------
   declare pctf00m09009 cursor with hold for

      select lclnumseq
        from ctf00m09_servicos
       group by 1
       order by 1

      foreach pctf00m09009 into lr_ctf00m09.lclnumseq

         ---> Joga dados em variavel char para tirar espacos em branco
         let lr_c_ctf00m09.lclnumseq = lr_ctf00m09.lclnumseq

         let l_xml= l_xml clipped
             ,"<LOCALDERISCO>" 
             ,"<lclnumseq>" , lr_c_ctf00m09.lclnumseq clipped,"</lclnumseq>"
 
 
         #------------------------------
         # Seleciona Bloco do Condominio
         #------------------------------
         declare cctf00m09010 cursor with hold for
 
            select rmerscseq
             from ctf00m09_servicos
             where lclnumseq = lr_ctf00m09.lclnumseq
             group by 1
             order by 1
       
         foreach cctf00m09010  into lr_ctf00m09.rmerscseq  
 
            ---> Joga dados em variavel char para tirar espacos em branco
            let lr_c_ctf00m09.rmerscseq = lr_ctf00m09.rmerscseq
 
            let l_xml= l_xml clipped
                ,"<BLOCOCONDOMINIO>" 
                ,"<rmerscseq>" , lr_c_ctf00m09.rmerscseq clipped,"</rmerscseq>"
 
	 
            #----------------------------
            # Seleciona Codigo do Assunto
            #----------------------------
            declare cctf00m09011 cursor with hold for
 
               select c24astcod
                 from ctf00m09_servicos
                where lclnumseq = lr_ctf00m09.lclnumseq
                  and rmerscseq = lr_ctf00m09.rmerscseq
                group by 1
                order by 1
 
            foreach cctf00m09011  into lr_ctf00m09.c24astcod  
 
               let l_xml= l_xml clipped
                   ,"<CODIGOASSUNTO>" 
                   ,"<c24astcod>" , lr_ctf00m09.c24astcod clipped,"</c24astcod>"
 
 
            #------------------------------------------------------------
            # Seleciona Codigo/Descricao Natureza / Total de Atendimentos
            #------------------------------------------------------------
            declare cctf00m09012 cursor with hold for
 
               select socntzcod
                     ,socntzdes
                     ,count(*)
                 from ctf00m09_servicos
                where lclnumseq = lr_ctf00m09.lclnumseq
                  and rmerscseq = lr_ctf00m09.rmerscseq
                  and c24astcod = lr_ctf00m09.c24astcod
                group by 1,2
                order by 1,2
 
            foreach cctf00m09012  into lr_ctf00m09.socntzcod  
                                      ,lr_ctf00m09.socntzdes
                                      ,lr_ctf00m09.qtd_atd
 
               ---> Joga dados em variavel char para tirar espacos em branco
               let lr_c_ctf00m09.socntzcod = lr_ctf00m09.socntzcod
               let lr_c_ctf00m09.qtd_atd   = lr_ctf00m09.qtd_atd
 
               let l_xml= l_xml clipped
                   ,"<CODIGONATUREZA>" 
                   ,"<socntzcod>" , lr_c_ctf00m09.socntzcod clipped,"</socntzcod>"
                   ,"<socntzdes>" , lr_ctf00m09.socntzdes   clipped,"</socntzdes>"
                   ,"<qtd_atd>"   , lr_c_ctf00m09.qtd_atd   clipped,"</qtd_atd>"
                   ,"</CODIGONATUREZA>" 
 
 
               let l_qtd1 = l_qtd1 + 1
            end foreach

            let l_xml= l_xml clipped
                ,"</CODIGOASSUNTO>" 

         end foreach

         let l_xml= l_xml clipped
             ,"</BLOCOCONDOMINIO>" 
 
      end foreach

      let l_xml= l_xml clipped
         ,"</LOCALDERISCO>" 

   end foreach

   let l_xml= l_xml clipped
       ,"</ATENDIMENTOS>"
       ,"</RESPONSE>"


   --> Nao ha Nenhum Servico para a Apolice / Proposta         
   if l_qtd1 = 0 then

      initialize l_xml to null

      let l_xml= 
        "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
       ,"<SERVICO>SERVICOS_RS_RE</SERVICO>"
         ,"<ATENDIMENTOS>"
           ,"<LOCALDERISCO>"
             ,"<lclnumseq></lclnumseq>"
               ,"<BLOCOCONDOMINIO>"
                 ,"<rmerscseq></rmerscseq>"
                   ,"<CODIGOASSUNTO>"
                     ,"<c24astcod></c24astcod>"
                       ,"<CODIGONATUREZA>"
                         ,"<socntzcod></socntzcod>"
                         ,"<socntzdes></socntzdes>"
                         ,"<qtd_atd></qtd_atd>"
                       ,"</CODIGONATUREZA>"
                   ,"</CODIGOASSUNTO>"
               ,"</BLOCOCONDOMINIO>"
           ,"</LOCALDERISCO>"
         ,"</ATENDIMENTOS>"
       ,"</RESPONSE>"

   end if

   return l_xml

end function


#-------------------------------------------------------------------------------
function ctf00m09_carrega_ifx()
#-------------------------------------------------------------------------------

   define arr_aux smallint

   initialize g_rs_re to null
   initialize arr_aux to null

   let arr_aux = 1

   #---------------------------------------
   # Apura Total de Atendimento por Assunto
   #---------------------------------------
   declare pctf00m09008 cursor with hold for

      select lclnumseq
            ,rmerscseq
            ,c24astcod
            ,socntzcod
            ,socntzdes
            ,count (*)
        from ctf00m09_servicos
       group by 1,2,3,4,5
       order by 1,2,3,4,5

   foreach pctf00m09008 into g_rs_re[arr_aux].lclnumseq
                            ,g_rs_re[arr_aux].rmerscseq
                            ,g_rs_re[arr_aux].c24astcod
                            ,g_rs_re[arr_aux].socntzcod
                            ,g_rs_re[arr_aux].socntzdes
                            ,g_rs_re[arr_aux].qtd_atd

      let arr_aux = arr_aux + 1

      if sqlca.sqlcode <> 0 then

         if mr_param.origem = "WEB" then
            let mr_ret_web.coderro = sqlca.sqlcode
            let mr_ret_web.deserro = "Status do Servico: pctf00m09008 "
         else
            let mr_ret_ifx.coderro = sqlca.sqlcode
            let mr_ret_ifx.deserro = "Status do Servico: pctf00m09008 "
         end if

         return 999
         end if

   end foreach


   let arr_aux = arr_aux - 1 

   return arr_aux

end function

#-------------------------------------------------------------------------------
function ctf00m09_cria_temporaria()
#-------------------------------------------------------------------------------

   define l_sql     char(500)

   initialize l_sql to null
 
   whenever any error continue
      select 1
        from ctf00m09_servicos
       where atdsrvnum = 0
   whenever any error stop

   if sqlca.sqlcode = 0 or sqlca.sqlcode = notfound then
      whenever error continue
      delete from ctf00m09_servicos
      whenever error stop
      return  0
   end if
 
   whenever error continue
      create temp table ctf00m09_servicos(lclnumseq   decimal(4,0)
                                         ,rmerscseq   smallint
                                         ,c24astcod   char(03)
                                         ,atdsrvnum   decimal(10,0)
                                         ,atdsrvano   decimal(2,0)
                                         ,lignum      decimal(10,0)
                                         ,socntzcod   smallint 
                                         ,socntzdes   char(60) ) with no log;
   whenever error stop

   if sqlca.sqlcode <> 0 then

      if mr_param.origem = "IFX" then
         let mr_ret_ifx.coderro  = sqlca.sqlcode
         let mr_ret_ifx.deserro = "Erro na criacao da tabela temporaria."
      else 
         let mr_ret_web.coderro  = sqlca.sqlcode
         let mr_ret_web.deserro = "Erro na criacao da tabela temporaria."
      end if
         return  999    
   end if

   whenever error continue
      delete from ctf00m09_servicos
   whenever error stop

   return 0

end function

