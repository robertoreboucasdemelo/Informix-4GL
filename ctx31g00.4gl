###############################################################################
# Programa.: ctx31g00.4gl                                                     #
###############################################################################
#  Analista Resp. : Kevellin Olivatti                                         #
#  Por            : Kevellin Olivatti     	Data: 12/05/2008                  #
#  Objetivo       : Verifica se um CPF é de um prestador ativo do             #
#                   Porto Socorro.                                            #
###############################################################################
#-----------------------------------------------------------------------------#
#                                                                             #
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#-----------------------------------------------------------------------------#
database porto
#-----------------------------------------------------------------------------#
function ctx31g00_prepare()
#-----------------------------------------------------------------------------#

   define l_sql  char(1000)

   let l_sql = ""

   ## Verifica se um CPF é de um prestador ativo do Porto Socorro
   let l_sql =  " select cgccpfnum, cgccpfdig, socanlsitcod "
   		       ," from datksrr "
		       ," where cgccpfnum = ? and cgccpfdig = ? "
   prepare pctx31g00001 from l_sql
   declare cctx31g00001 cursor for pctx31g00001

end function
#----------------------------------------------------------------------------
function ctx31g00(l_param)

   define l_param record
   		cpfnum  like datksrr.cgccpfnum,    ## cpfnum
		cpfdig  like datksrr.cgccpfdig     ## cpfdig
   end record

   define l_auxiliar record
   		cpfnum  like datksrr.cgccpfnum,    ## cpfnum
		cpfdig  like datksrr.cgccpfdig,    ## cpfdig
		sit     like datksrr.socanlsitcod  ## situação
   end record

   define l_param_saida record
   		l_codigo    smallint,  ## Código
		l_mensagem  char(60)   ## Mensagem
   end record

   display "l_param.cpfnum >>>", l_param.cpfnum
   display "l_param.cpfdig >>>", l_param.cpfdig

   #initialize l_param.* 	to null
   #initialize l_param_saida.* 	to null

   call ctx31g00_prepare()

   open cctx31g00001 using 	l_param.cpfnum,
   				            l_param.cpfdig

   fetch cctx31g00001 into 	l_auxiliar.cpfnum,
   				            l_auxiliar.cpfdig,
   				            l_auxiliar.sit
   if sqlca.sqlcode <> 0 then
      let l_param_saida.l_codigo   = 99
      let l_param_saida.l_mensagem = "ERRO NA FUNCAO ctx31g00"
   end if

   display "cpfnum ", l_auxiliar.cpfnum
   display "cpfdig ", l_auxiliar.cpfdig
   display "situacao ", l_auxiliar.sit

   if l_auxiliar.cpfnum is null or l_auxiliar.cpfnum == "" then

       let l_param_saida.l_codigo   = 100
       let l_param_saida.l_mensagem = "CPF NAO ENCONTRADO NA BASE DE SOCORRISTAS"

   else

       if l_auxiliar.sit = 1 then

           let l_param_saida.l_codigo = 1
           let l_param_saida.l_mensagem = "CPF ENCONTRADO NA BASE DE SOCORRISTAS"

       else

           let l_param_saida.l_codigo = 0
           let l_param_saida.l_mensagem = "CPF ENCONTRADO NA BASE DE SOCORRISTAS MAS NAO ATIVO"

       end if

   end if

   return l_param_saida.*

end function