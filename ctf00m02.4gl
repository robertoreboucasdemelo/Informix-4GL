################################################################################
# Sistema  : CTS      - Central 24 Horas                             MAIO/2008 #
# Programa :                                                                   #
# Modulo   : ctf00m02 - Pesquisa Servicos para Web - So Agendados ou Realizados#
# Analista : Carla Rampazzo                                                    #
# PSI      :                                                                   #
# Liberacao:                                                                   #
#------------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                             #
#------------------------------------------------------------------------------#
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
#                           * * * Comentarios * * *                            #
#                                                                              #
# Este modulo possui as mesmas regras do modulo ctf00m02, porem eh utilizado   #
# para gerar um arquivo XML para exibicao dos dados no Portal do Cliente       #
# Obs.: Nao foi utilizado o modulo ctf00m02, devido ao grande numero de modulos#
#       que seriam necessarios incluir na formacao                             #
################################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'


database porto

define mr_param       record
       succod         like datrservapol.succod
      ,ramcod         like datrservapol.ramcod
      ,aplnumdig      like datrservapol.aplnumdig
      ,itmnumdig      like datrservapol.itmnumdig
end record


define mr_retorno   record
       coderro      smallint
      ,deserro      char(1000)
      ,xml          char(32766)
end record

#END MODULARES

#-------------------------------------------------------------------------------
function ctf00m02(lr_param)
#-------------------------------------------------------------------------------

   define lr_param       record
          succod         like datrservapol.succod
         ,ramcod         like datrservapol.ramcod
         ,aplnumdig      like datrservapol.aplnumdig
         ,itmnumdig      like datrservapol.itmnumdig
   end record

   define l_xml          char(32766)
         ,l_coderro      smallint

   initialize mr_retorno.*
             ,l_coderro   to null
  
   set isolation to dirty read

   let mr_retorno.coderro = 0


   ---> Atribui parametros para variavel modular
   let mr_param.* = lr_param.*
 

   ---> Cria tabela temporaria 
   call ctf00m02_cria_temporaria()
        returning l_coderro

   if l_coderro <> 0 then
      call ctf00m06_xmlerro ("SERVICOS_ATENDIDOS_DOCUMENTO"
                             ,mr_retorno.coderro
                             ,mr_retorno.deserro)
           returning mr_retorno.xml
      return mr_retorno.xml
   end if


   ---> Monta Prepares
   call ctf00m02_prepare()


   ---> Apura Dados da Consulta 
   call ctf00m02_extrai_dados()     
	returning l_coderro

   if l_coderro <> 0 then
      call ctf00m06_xmlerro ("SERVICOS_ATENDIDOS_DOCUMENTO"
                             ,mr_retorno.coderro
                             ,mr_retorno.deserro)
           returning mr_retorno.xml
      return mr_retorno.xml
   end if


   ---> Gera XML para utilizacao pela Web - Portal do Segurado
   call ctf00m02_gera_xml()
        returning mr_retorno.xml

   return mr_retorno.xml

end function

#-------------------------------------------------------------------------------
function ctf00m02_prepare()
#-------------------------------------------------------------------------------

   define l_sql           char(3000)

   initialize l_sql to null

   ---> Busca vigencia apolice
   let l_sql = 'select viginc, vigfnl'
              ,'  from abamapol '
              ,' where abamapol.succod    = ? '
              ,'   and abamapol.aplnumdig = ? '
   prepare pctf00m02001 from l_sql
   declare cctf00m02001 cursor for pctf00m02001

   ---> Status do Servico (Web utiliza apenas 1-Agendado ou 3-Realizado)
   let l_sql = "select atdetpcod     ",
               "  from datmsrvacp    ",
               " where atdsrvnum = ? ",
               "   and atdsrvano = ? ",
               "   and atdsrvseq = (select max(atdsrvseq) ",
                                   "  from datmsrvacp     ",
                                   " where atdsrvnum = ?  ",
                                   "   and atdsrvano = ?) "
   prepare pctf00m02002 from l_sql
   declare cctf00m02002 cursor for pctf00m02002

   ---> Localiza Servicos conforme parametro de Pesquisa
   let l_sql = "select datmservico.atddat     ",
               "      ,datmservico.atdhor     ",
               "      ,datmservico.atdhorpvt  ",
               "      ,datmservico.atddatprg  ",
               "      ,datmservico.atdhorprg  ",
               "      ,datmservico.atdsrvnum  ",
               "      ,datmservico.atdsrvano  ",
               "  from datrservapol,datmservico",
               " where datrservapol.succod     = ? ",
               "   and datrservapol.ramcod     = ? ",
               "   and datrservapol.aplnumdig  = ? ",
               "   and datrservapol.itmnumdig  = ? ",
               "   and datrservapol.edsnumref >= 0 ",
               "   and datmservico.atdsrvnum   = datrservapol.atdsrvnum",
               "   and datmservico.atdsrvano   = datrservapol.atdsrvano",
               "   and datmservico.atdsrvorg   = 9 ",
               " order by atddat desc, atdhor asc"
   prepare pctf00m02003  from l_sql
   declare cctf00m02003 cursor for pctf00m02003

   ---> Descricao da Natureza
   let l_sql = "select b.webntzdes "
	      ,"      ,b.webvslflg "
	      ,"      ,b.socntzcod "
              ,"  from datmsrvre  a "
              ,"      ,datksocntz b "
              ," where a.atdsrvnum = ?  "
              ,"   and a.atdsrvano = ?  "
              ,"   and a.socntzcod = b.socntzcod "
   prepare pctf00m02004 from l_sql
   declare cctf00m02004 cursor for pctf00m02004

 
   ---> Codigo/Descricao do Problema 
   let l_sql = " select a.c24pbmcod                  "
               ,"     , a.c24pbmdes                  "
               ,"  from datrsrvpbm a                 "
               ," where a.atdsrvnum    = ?           "
               ,"   and a.atdsrvano    = ?           "
               ,"   and a.c24pbminforg = 1           "
               ,"   and a.c24pbmseq    = 1           "
   prepare pctf00m02007 from l_sql
   declare cctf00m02007 cursor for pctf00m02007


   ---> Insere Dados em tabela Temporaria
   let l_sql = " insert into ctf00m02_servicos   (atdsrvnum "
                                              ," ,atdsrvano "
                                              ," ,socntzcod "
                                              ," ,webntzdes "
                                              ," ,c24pbmcod "
                                              ," ,c24pbmdes "
                                              ," ,atddat    "
                                              ," ,atdhor    "
                                              ," ,atdhorpvt "
                                              ," ,atddatprg "
                                              ," ,atdhorprg "
                                              ," ,atdetpcod)"
                                        ," values(?,?,?,?,?,?,?,?,?,?,?,?)"
   prepare pctf00m02008 from l_sql

   ---> Seleciona Servicos por Status
   let l_sql = " select atdsrvnum    "
                    ," ,atdsrvano    "
                    ," ,atddat    "
                    ," ,atdhor    "
                    ," ,atdhorpvt    "
                    ," ,atddatprg    "
                    ," ,atdhorprg    "
               ,"  from ctf00m02_servicos "
               ," where atdetpcod = ? "
               ," group by atdsrvnum "
               ,"         ,atdsrvano "
               ,"         ,atddat    "
               ,"         ,atdhor    "
               ,"         ,atdhorpvt "
               ,"         ,atddatprg "
               ,"         ,atdhorprg "
               ," order by atdsrvano "
               ,"         ,atdsrvnum "
               ,"         ,atddat    "
               ,"         ,atdhor    "
               ,"         ,atdhorpvt "
               ,"         ,atddatprg "
               ,"         ,atdhorprg "
   prepare pctf00m02009 from l_sql
   declare cctf00m02009 cursor for pctf00m02009


   ---> Seleciona Problemas do Servico 
   let l_sql = " select socntzcod "
                    ," ,webntzdes "
                    ," ,c24pbmcod "
                    ," ,c24pbmdes "
               ,"  from ctf00m02_servicos "
               ," where atdsrvnum = ? "
               ,"   and atdsrvano = ? "
   prepare pctf00m02010 from l_sql
   declare cctf00m02010 cursor for pctf00m02010


   ---> Verifica se Servico eh Filho de algum Multiplo
   let l_sql = " select atdsrvnum "
                    ," ,atdsrvano "
               ,"  from datratdmltsrv "
               ," where atdmltsrvnum = ? "
               ,"   and atdmltsrvano = ? "
   prepare pctf00m02011 from l_sql
   declare cctf00m02011 cursor for pctf00m02011

end function

#-------------------------------------------------------------------------------
function ctf00m02_extrai_dados()
#-------------------------------------------------------------------------------

   define lr_ctf00m02    record
          atdsrvnum      decimal(10,0)
         ,atdsrvano      decimal(2,0)
         ,socntzcod      like datksocntz.socntzcod
         ,webntzdes      like datksocntz.webntzdes
         ,webvslflg      like datksocntz.webvslflg
         ,c24pbmcod      smallint
         ,c24pbmdes      char(40)
         ,atddat         like datmservico.atddat
         ,atdhor         like datmservico.atdhor
         ,atdhorpvt      like datmservico.atdhorpvt
         ,atddatprg      like datmservico.atddatprg
         ,atdhorprg      like datmservico.atdhorprg
         ,atdetpcod      smallint 
         ,atdsrvnum_p    like datratdmltsrv.atdsrvnum
         ,atdsrvano_p    like datratdmltsrv.atdsrvano
   end record

   define l_aux          record
          sql            char (700)
         ,viginc         like abbmdoc.viginc
         ,vigfnl         like abbmdoc.vigfnl
   end record

   initialize  lr_ctf00m02.*  
              ,l_aux.*        to null


   ---> Valida Parametros
   if mr_param.succod    is null  or
      mr_param.ramcod    is null  or
      mr_param.aplnumdig is null  or
      mr_param.itmnumdig is null  then
      let mr_retorno.coderro = 1   
      let mr_retorno.deserro = "Parametros de entrada invalidos -->"
                              ," Sucursal: " , mr_param.succod   
                              ," Ramo: "     , mr_param.ramcod   
                              ," Apolice: "  , mr_param.aplnumdig 
                              ," Item: "     , mr_param.itmnumdig 
      return 999
   end if



   ---> Vigencia da Apolice
   whenever error continue
   open cctf00m02001 using mr_param.succod
                          ,mr_param.aplnumdig
   fetch cctf00m02001 into l_aux.viginc
                          ,l_aux.vigfnl 

   if sqlca.sqlcode <> 0   and
      sqlca.sqlcode <> 100 then
      let mr_retorno.coderro = sqlca.sqlcode
      let mr_retorno.deserro = "Busca vigencia da apolice: cctf00m02001 "
      return 999
   end if

   close cctf00m02001
   whenever error stop

   --->  Ler servicos conforme Parametros
   open cctf00m02003   using mr_param.succod   
                            ,mr_param.ramcod   
                            ,mr_param.aplnumdig
                            ,mr_param.itmnumdig
   foreach cctf00m02003 into lr_ctf00m02.atddat
                            ,lr_ctf00m02.atdhor
                            ,lr_ctf00m02.atdhorpvt
                            ,lr_ctf00m02.atddatprg
                            ,lr_ctf00m02.atdhorprg
                            ,lr_ctf00m02.atdsrvnum
                            ,lr_ctf00m02.atdsrvano


      ---> Despreza Servicos fora da Vigencia da Apolice 
      if lr_ctf00m02.atddat < l_aux.viginc  or
         lr_ctf00m02.atddat > l_aux.vigfnl  then      
         continue foreach
      end if

      ---> Status do Servico
      whenever error continue
      open  cctf00m02002 using lr_ctf00m02.atdsrvnum
                              ,lr_ctf00m02.atdsrvano
                              ,lr_ctf00m02.atdsrvnum
                              ,lr_ctf00m02.atdsrvano
      fetch cctf00m02002 into  lr_ctf00m02.atdetpcod


      if sqlca.sqlcode <> 0 then
         let mr_retorno.coderro = sqlca.sqlcode
         let mr_retorno.deserro = "Status do Servico: cctf00m02002 "
         return 999
      end if

      close cctf00m02002
      whenever error stop

      if lr_ctf00m02.atdetpcod <> 1 and  ---> Servico Agendado
	 lr_ctf00m02.atdetpcod <> 3 then ---> Servico Realizado
	 continue foreach
      end if

      initialize lr_ctf00m02.webntzdes  
                ,lr_ctf00m02.webvslflg        
                ,lr_ctf00m02.socntzcod to null

      ---> Descricao da Natureza
      whenever error continue
      open  cctf00m02004 using lr_ctf00m02.atdsrvnum
                              ,lr_ctf00m02.atdsrvano
      fetch cctf00m02004 into  lr_ctf00m02.webntzdes
			      ,lr_ctf00m02.webvslflg
			      ,lr_ctf00m02.socntzcod


      if sqlca.sqlcode <> 0   and   
         sqlca.sqlcode <> 100 then
         let mr_retorno.coderro = sqlca.sqlcode
         let mr_retorno.deserro = "Descricao da Natureza: cctf00m02004 "
         return 999
      end if 

      close cctf00m02004
      whenever error stop
         

      ---> Mostra somente Naturezas que estao Marcadas p/ Web
      if lr_ctf00m02.webvslflg = "N" then  ---> Servico Agendado
	 continue foreach
      end if
	 

      ---> Codigo/Descricao do Problema
      whenever error continue
      open  cctf00m02007 using lr_ctf00m02.atdsrvnum
                              ,lr_ctf00m02.atdsrvano
      fetch cctf00m02007 into  lr_ctf00m02.c24pbmcod
                              ,lr_ctf00m02.c24pbmdes


      if sqlca.sqlcode <> 0   and 
	 sqlca.sqlcode <> 100 then
         let mr_retorno.coderro = sqlca.sqlcode
         let mr_retorno.deserro = "Cod/Descricao do Problema: cctf00m02007"
         return 999
      end if 

      close cctf00m02007
      whenever error stop


      ---> Quando Servico eh Agendado e Multiplo assume o Servico Pai
      if lr_ctf00m02.atdetpcod = 1 then  ---> Servico Agendado

	 ---> Verifica se o Servico Atual eh Filho de algum Multiplo
         whenever error continue
         open  cctf00m02011 using lr_ctf00m02.atdsrvnum
                                 ,lr_ctf00m02.atdsrvano
         fetch cctf00m02011 into  lr_ctf00m02.atdsrvnum_p
                                 ,lr_ctf00m02.atdsrvano_p


         ---> Assume o Servico Pai
         if sqlca.sqlcode = 0 then 
            let lr_ctf00m02.atdsrvnum = lr_ctf00m02.atdsrvnum_p
            let lr_ctf00m02.atdsrvano = lr_ctf00m02.atdsrvano_p
         end if

         if sqlca.sqlcode <> 0   and 
	    sqlca.sqlcode <> 100 then
            let mr_retorno.coderro = sqlca.sqlcode
            let mr_retorno.deserro = "Cod/Descricao do Problema: cctf00m02011"
            return 999
         end if 

         close cctf00m02011
         whenever error stop
      end if


      ---> Insere dados em Tabela Temporaria
      whenever error continue
      execute pctf00m02008 using lr_ctf00m02.atdsrvnum
                                ,lr_ctf00m02.atdsrvano
                                ,lr_ctf00m02.socntzcod
                                ,lr_ctf00m02.webntzdes
                                ,lr_ctf00m02.c24pbmcod
                                ,lr_ctf00m02.c24pbmdes
                                ,lr_ctf00m02.atddat
                                ,lr_ctf00m02.atdhor
                                ,lr_ctf00m02.atdhorpvt
                                ,lr_ctf00m02.atddatprg
                                ,lr_ctf00m02.atdhorprg
                                ,lr_ctf00m02.atdetpcod

      if sqlca.sqlcode <> 0 then
         let mr_retorno.coderro = sqlca.sqlcode
         let mr_retorno.deserro = "Descricao do Problema: pctf00m02008 "
         return 999
      end if 

      whenever error stop
   end foreach

   set isolation to committed read

   return 0

end function  ###  ctf00m02

#-------------------------------------------------------------------------------
function ctf00m02_gera_xml()
#-------------------------------------------------------------------------------
 
   define lr_ctf00m02        record
          atdsrvnum          decimal(10,0)
         ,atdsrvano          decimal(2,0)
         ,socntzcod          like datksocntz.socntzcod
         ,webntzdes          like datksocntz.webntzdes
         ,c24pbmcod          smallint
         ,c24pbmdes          char(40)
         ,atddat             date
         ,atdhor             datetime hour to minute
         ,atdhorpvt          like datmservico.atdhorpvt
         ,atddatprg          like datmservico.atddatprg
         ,atdhorprg          like datmservico.atdhorprg
         ,atdetpcod          smallint 
	 ,retorno            char(3)
	 ,garantia           char(3)
	 ,complemento        char(3)
         ,alt_can            char(3)
   end record
 

   define lr_c_ctf00m02      record
          atdsrvnum          char(12)
         ,atdsrvano          char(2)      
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
	 ,l_qtd2         smallint
	 ,l_qtd3         smallint

   initialize lr_ctf00m02.* 
             ,l_alt.*
             ,l_ret.*
             ,l_cont
	     ,l_xml        to null


  
   let l_xml= 
       "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
      ,"<SERVICO>SERVICOS_ATENDIDOS_DOCUMENTO</SERVICO>"

   let l_qtd3 = 0

   ---> Apura servicos (Agendados/Realizados)
   for l_cont = 1 to 2


      if l_cont = 1 then
         let lr_ctf00m02.atdetpcod = 3 ---> Realizado 
         let l_xml= l_xml clipped
            ,"<ATENDIMENTOS>"
            ,"<REALIZADOS>"
      else
         let lr_ctf00m02.atdetpcod = 1 ---> Agendado
         let l_xml= l_xml clipped
            ,"<AGENDADOS>"
      end if

      let l_qtd1 = 0

      open    cctf00m02009 using lr_ctf00m02.atdetpcod
      foreach cctf00m02009  into lr_ctf00m02.atdsrvnum  
                                ,lr_ctf00m02.atdsrvano    
                                ,lr_ctf00m02.atddat       
                                ,lr_ctf00m02.atdhor       
                                ,lr_ctf00m02.atdhorpvt       
                                ,lr_ctf00m02.atddatprg       
                                ,lr_ctf00m02.atdhorprg       

         let l_qtd1 = l_qtd1 + 1
         let l_qtd3 = l_qtd3 + 1


	 ---> Carrega data do Agendamento (Imediato)  
         if lr_ctf00m02.atdhorpvt is not null and 
            lr_ctf00m02.atdhorpvt <> " "      then  
            ---> Assume a data/hora do registro do Servico (atddat/atdhor)
            ---> ja selecionado acima        
         else    

	    ---> Carrega data do Agendamento   
            if lr_ctf00m02.atddatprg is not null and 
               lr_ctf00m02.atddatprg <> " "      and 
               lr_ctf00m02.atdhorprg is not null and 
               lr_ctf00m02.atdhorprg <> " "      then 
               let lr_ctf00m02.atddat = lr_ctf00m02.atddatprg 
               let lr_ctf00m02.atdhor = lr_ctf00m02.atdhorprg 
            end if
         end if
         
 
	 ---> Joga dados em variavel char para tirar espacos em branco
         let lr_c_ctf00m02.atdsrvnum = lr_ctf00m02.atdsrvnum
         let lr_c_ctf00m02.atdsrvano = lr_ctf00m02.atdsrvano


         let l_xml= l_xml clipped
            ,"<ATENDIMENTO>"
            ,"<DATA>"  , lr_ctf00m02.atddat clipped, "</DATA>"
            ,"<HORA>"  , lr_ctf00m02.atdhor clipped, "</HORA>"
            ,"<IDENTIFICACAOSERVICO>"
            ,"<ORIGEM>9</ORIGEM>"
            ,"<NUMERO>",lr_c_ctf00m02.atdsrvnum clipped,"</NUMERO>"
            ,"<ANO>"   ,lr_c_ctf00m02.atdsrvano clipped,"</ANO>"
            ,"</IDENTIFICACAOSERVICO>"


	 if lr_ctf00m02.atdsrvnum is null or
	    lr_ctf00m02.atdsrvnum =  0    then
            continue for
         end if

         let l_qtd2 = 0

         ---> Problemas do Servico
         open    cctf00m02010 using lr_ctf00m02.atdsrvnum
                                   ,lr_ctf00m02.atdsrvano    
         foreach cctf00m02010 into  lr_ctf00m02.socntzcod    
                                   ,lr_ctf00m02.webntzdes 
                                   ,lr_ctf00m02.c24pbmcod    
                                   ,lr_ctf00m02.c24pbmdes    

            let l_qtd2 = l_qtd2 + 1

            let l_xml= l_xml clipped
               ,"<TIPOSERVICO>"
               ,"<CODIGO>"   , lr_ctf00m02.socntzcod clipped, "</CODIGO>"
               ,"<NOME>  "   , lr_ctf00m02.webntzdes clipped, "</NOME>"
               ,"<DESCRICAO>", lr_ctf00m02.webntzdes clipped, "</DESCRICAO>"
               ,"<PROBLEMA>"
               ,"<CODIGO>"    , lr_ctf00m02.c24pbmcod clipped, "</CODIGO>"
               ,"<DESCRICAO>" , lr_ctf00m02.c24pbmdes clipped, "</DESCRICAO>"
               ,"</PROBLEMA>"
               ,"</TIPOSERVICO>"


            ---> Verifica se pode alterar e/ou cancelar o Servico
            call ctx32g00_alteracao(lr_ctf00m02.atdsrvnum
                                   ,lr_ctf00m02.atdsrvano)
                 returning l_alt.*

            if l_alt.retcod = 0 then
               let lr_ctf00m02.alt_can = "SIM"
            else 
               let lr_ctf00m02.alt_can = "NAO"
            end if

            initialize l_ret.* to null



            ---> Verifica se ha Garantia e Complemento para o Servico
            call ctx32g00_retorno(lr_ctf00m02.atdsrvnum
                                 ,lr_ctf00m02.atdsrvano)
                 returning l_ret.*

            ---> Garantia - Retorna True qdo Data Servico eh < que 90 dias
            if l_ret.garantia = true then
               let lr_ctf00m02.garantia = "SIM"
            else 
               let lr_ctf00m02.garantia = "NAO"
            end if

            ---> Complemento - Retorna True qdo Data Servico eh < que 30 dias
            if l_ret.complemento = true then
               let lr_ctf00m02.complemento = "SIM"
            else 
               let lr_ctf00m02.complemento = "NAO"
            end if

            if l_cont = 1 then
               let l_xml= l_xml clipped
               ,"<RETORNO>" 
               ,"<COMPLEMENTO>" ,lr_ctf00m02.complemento, "</COMPLEMENTO>"
               ,"<GARANTIA>"    ,lr_ctf00m02.garantia   , "</GARANTIA>"
               ,"</RETORNO>" 
            else
               let l_xml= l_xml clipped
               ,"<ALTERAR>"  ,lr_ctf00m02.alt_can, "</ALTERAR>"
               ,"<CANCELAR>" ,lr_ctf00m02.alt_can, "</CANCELAR>"
            end if

            initialize lr_ctf00m02.socntzcod
                      ,lr_ctf00m02.webntzdes
                      ,lr_ctf00m02.c24pbmcod
                      ,lr_ctf00m02.c24pbmdes   to null

         end foreach

         let l_xml= l_xml clipped
            ,"</ATENDIMENTO>"

         initialize lr_ctf00m02.* to null

      end foreach

      ---> Nao existe nenhum Servico Agendado --> OU <-- Realizado
      if l_qtd1 = 0 then
         let l_xml= l_xml clipped
            ,"<ATENDIMENTO>"
            ,"<DATA></DATA>"
            ,"<HORA></HORA>"
            ,"<IDENTIFICACAOSERVICO>"
            ,"<ORIGEM></ORIGEM>"
            ,"<NUMERO></NUMERO>"
            ,"<ANO></ANO>"
            ,"</IDENTIFICACAOSERVICO>"
            ,"<TIPOSERVICO>"
            ,"<CODIGO></CODIGO>"
            ,"<NOME></NOME>"
            ,"<DESCRICAO></DESCRICAO>"
            ,"<PROBLEMA>"
            ,"<CODIGO></CODIGO>"
            ,"<DESCRICAO></DESCRICAO>"
            ,"</PROBLEMA>"
            ,"</TIPOSERVICO>"
            if l_cont = 1 then
               let l_xml= l_xml clipped
               ,"<RETORNO>"
               ,"<COMPLEMENTO></COMPLEMENTO>"
               ,"<GARANTIA></GARANTIA>"
               ,"</RETORNO>"
            else
               let l_xml= l_xml clipped
               ,"<ALTERAR></ALTERAR>"
               ,"<CANCELAR></CANCELAR>"
            end if
            let l_xml= l_xml clipped
             ,"</ATENDIMENTO>"
      end if


      if l_cont = 1 then
         let l_xml= l_xml clipped
            ,"</REALIZADOS>"
      else
         let l_xml= l_xml clipped
            ,"</AGENDADOS>"
      end if
   end for

   let l_xml= l_xml clipped
      ,"</ATENDIMENTOS>"
      ,"</RESPONSE>"


   --> Nao ha servicos nem Realizados --> E <--  nem Agendados
   if l_qtd3 = 0 then

      initialize l_xml to null

      let l_xml= 
          "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
         ,"<SERVICO>SERVICOS_ATENDIDOS_DOCUMENTO</SERVICO>"
            ,"<ATENDIMENTOS>"
               ,"<REALIZADOS>"
                  ,"<ATENDIMENTO>"
                     ,"<DATA></DATA>"
                     ,"<HORA></HORA>"
                     ,"<IDENTIFICACAOSERVICO>"
                        ,"<ORIGEM></ORIGEM>"
                        ,"<NUMERO></NUMERO>"
                        ,"<ANO></ANO>"
                     ,"</IDENTIFICACAOSERVICO>"
                     ,"<TIPOSERVICO>"
                        ,"<CODIGO></CODIGO>"
                        ,"<NOME></NOME>"
                        ,"<DESCRICAO></DESCRICAO>"
                        ,"<PROBLEMA>"
                           ,"<CODIGO></CODIGO>"
                           ,"<DESCRICAO></DESCRICAO>"
                        ,"</PROBLEMA>"
                     ,"</TIPOSERVICO>"
                     ,"<RETORNO>"
                        ,"<COMPLEMENTO>NAO</COMPLEMENTO>"
                        ,"<GARANTIA>NAO</GARANTIA>"
                     ,"</RETORNO>"
                  ,"</ATENDIMENTO>"
               ,"</REALIZADOS> "
               ,"<AGENDADOS>"
                  ,"<ATENDIMENTO>"
                     ,"<DATA></DATA>"
                     ,"<HORA></HORA>"
                     ,"<IDENTIFICACAOSERVICO>"
                        ,"<ORIGEM></ORIGEM>"
                        ,"<NUMERO></NUMERO>"
                        ,"<ANO></ANO>"
                     ,"</IDENTIFICACAOSERVICO>"
                     ,"<TIPOSERVICO>"
                        ,"<CODIGO></CODIGO>"
                        ,"<NOME></NOME>"
                        ,"<DESCRICAO></DESCRICAO>"
                        ,"<PROBLEMA>"
                           ,"<CODIGO></CODIGO>"
                           ,"<DESCRICAO></DESCRICAO>"
                        ,"</PROBLEMA>"
                     ,"</TIPOSERVICO>"
                     ,"<ALTERAR>NAO</ALTERAR>"
                     ,"<CANCELAR>NAO</CANCELAR>"
                  ,"</ATENDIMENTO>"
               ,"</AGENDADOS>"
            ,"</ATENDIMENTOS>"
         ,"</RESPONSE>"
   end if

   return l_xml

end function

#-------------------------------------------------------------------------------
function ctf00m02_cria_temporaria()
#-------------------------------------------------------------------------------

   define l_sql     char(500)

   initialize l_sql to null
 
   whenever any error continue
      select 1
        from ctf00m02_servicos
       where atdsrvnum = 0
   whenever any error stop

   if sqlca.sqlcode = 0 or sqlca.sqlcode = notfound then
      whenever error continue
      delete from ctf00m02_servicos
      whenever error stop
      return  0
   end if
 
   whenever error continue
      create temp table ctf00m02_servicos(atdsrvnum      decimal(10,0)
                                         ,atdsrvano      decimal(2,0)
                                         ,socntzcod      smallint     
                                         ,webntzdes      char(60)
                                         ,c24pbmcod      smallint
                                         ,c24pbmdes      char(40)
                                         ,atddat         date
                                         ,atdhor         datetime hour to minute
                                         ,atdhorpvt      datetime hour to minute
                                         ,atddatprg      date
                                         ,atdhorprg      datetime hour to minute
                                         ,atdetpcod      smallint )with no log;

   whenever error stop

   if sqlca.sqlcode <> 0 then
      let mr_retorno.coderro  = sqlca.sqlcode
      let mr_retorno.deserro = "Erro na criacao da tabela temporaria."
      return  999    
   end if

   whenever error continue
      delete from ctf00m02_servicos
   whenever error stop

   return 0

end function

