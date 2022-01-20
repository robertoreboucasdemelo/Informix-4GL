###############################################################################
# Programa.: ctx30g00.4gl                                                     #
###############################################################################
#  Analista Resp. : Monica D'Errico Moya                                      #
#  Por            : Monica D'Errico Moya     	Data: 23/01/2008              #
#  Objetivo       : Retornar informacoes de Laudos de Atendimentos Porto      # 
#                   Socorro                                                   #
###############################################################################
#-----------------------------------------------------------------------------#
#                                                                             #
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#-----------------------------------------------------------------------------#
database porto

define m_ctx30g00_prepare char(01)
#-----------------------------------------------------------------------------#
function ctx30g00_prepare() 
#-----------------------------------------------------------------------------#

   define l_sql  char(1000)

   let l_sql = ""

   ## Retorna os serviços/atendimentos efetuados pela Porto Socorro
   let l_sql =  " select atdsrvnum, atdsrvano " 
   		," from datrservapol "
		," where succod=? and ramcod=? " 
		," and aplnumdig=? and itmnumdig=? " 
		," and edsnumref=? "
   prepare pctx30g00001 from l_sql
   declare cctx30g00001 cursor for pctx30g00001

   ## Retorna data de pagamento do serviço se houver
   let l_sql =   " select socfatpgtdat " 
   		," from dbsmopg a, dbsmopgitm b, datmservico c "
		," where socopgsitcod = 7 "
		," and a.socopgnum = b.socopgnum "
		," and c.atdsrvnum = b.atdsrvnum "
		," and c.atdsrvano = b.atdsrvano "
		," and c.atdsrvnum = ? "
		," and c.atdsrvano = ? "
		," group by socfatpgtdat "
   prepare pctx30g00002 from l_sql
   declare cctx30g00002 cursor for pctx30g00002
   
   ## Retorna data de abertura do laudo
   let l_sql =   " select ligdat "
   		," from datmligacao " 
		," where atdsrvnum = ? "
		," and atdsrvano = ? "
   prepare pctx30g00003 from l_sql
   declare cctx30g00003 cursor for pctx30g00003

end function
#----------------------------------------------------------------------------
function ctx30g00(l_param)
#----------------------------------------------------------------------------
   
   define l_param record
   		succod     like rsamseguro.succod,       ## Sucursal
		ramcod     like datrservapol.ramcod,	 ## Ramo
   		aplnumdig  like rsamseguro.aplnumdig,    ## Apolice
		itmnumdig  like datrservapol.itmnumdig,  ## Item ou zeros
		edsnumdig  like rsdmdocto.edsnumdig	 ## Endosso ou zeros
   end record
   
   define l_serv record
   		atdsrvnum  like datrservapol.atdsrvnum,
		atdsrvano  like datrservapol.atdsrvano
   end record
   
   define l_pgto           like dbsmopg.socfatpgtdat
   define l_laudo	   like datmligacao.ligdat
   
   define l_param_saida record
   		atdsrvnum    like datrservapol.atdsrvnum,
		atdsrvano    like datrservapol.atdsrvano,
		socopgsitcod like dbsmopg.socopgsitcod,
		ligdat       like datmligacao.ligdat		
   end record
   
   #-- Inicializa as variaveis
   initialize l_param.* 	to null
   initialize l_serv.*  	to null
   initialize l_param_saida.* 	to null
   let l_pgto            	= null
   let l_laudo          	= null  
   
   if m_ctx30g00_prepare then
   else
      call ctx30g00_prepare()
      let m_ctx30g00_prepare = true
   end if

   open cctx30g00001 using 	l_param.succod,
   				l_param.ramcod,
				l_param.aplnumdig,
				l_param.itmnumdig,  		
				l_param.edsnumdig 
   
   fetch cctx30g00001 into 	l_serv.atdsrvnum,
   				l_serv.atdsrvano				
			  
   open cctx30g00002 using  	l_serv.atdsrvnum,
   				l_serv.atdsrvano
				
   fetch cctx30g00002 into 	l_pgto
   
   open cctx30g00003 using  	l_serv.atdsrvnum,
   				l_serv.atdsrvano
				
   fetch cctx30g00003 into 	l_laudo			

   let l_param_saida.atdsrvnum    = l_serv.atdsrvnum
   let l_param_saida.atdsrvano    = l_serv.atdsrvano
   let l_param_saida.socopgsitcod = l_pgto
   let l_param_saida.ligdat       = l_laudo

   close cctx30g00001
   close cctx30g00002
   close cctx30g00003

   return l_param_saida.*

end function  

#-----------------------------------------------------------------------------#

