#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : wdatc065.4gl                                              #
#                  Disponibilizar informacoes sobre servicos bloqueados no   #
#                  Portal de Negocios - Prestador On-Line                    #
# Analista Resp. : Carlos Zyon                                               #
# PSI            : 177890 -                                                  #
# OSF            : 29521   -                                                 #
#............................................................................#
# Desenvolvimento: Fabrica de Software - Alexandre Figueiredo                #
# Liberacao      :                                                           #
#............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco. #
###############################################################################
database porto

globals
    define g_ismqconn        smallint,
           g_servicoanterior smallint,
           g_meses           integer,
           w_hostname        char(03),
           g_isbigchar       smallint
end globals

main
    call fun_dba_abre_banco("CT24HS")
    call wdatc065()
end main
-------------------------------------------------------------------------------
function wdatc065()
-------------------------------------------------------------------------------
 define l_param       record
	atdsrvnum		like datmservico.atdsrvnum,
	atdsrvano		like datmservico.atdsrvano,
	acao	 		char(1)	
 end record

 define	l_adicionais		record
	soccstdes		like dbskcustosocorro.soccstdes,
	socadccstqtd		like dbsmopgcst.cstqtd,
	socadccstvlr		like dbsmopgcst.socopgitmcst,
	totvlr			dec(20,5)	
 end	record

 define	l_totalGeral		dec(25,5)

 -- [ Sessao ja eh verificada e atualiza no wdatc017 ] --


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize l_totalGeral  to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  l_param.*  to  null

	initialize  l_adicionais.*  to  null

 initialize l_param.* to null
 initialize l_adicionais.* to null

 initialize g_ismqconn        to null
 initialize g_servicoanterior to null
 initialize g_meses           to null
 initialize w_hostname        to null
 initialize g_isbigchar       to null

 let l_param.atdsrvnum = arg_val(5)
 let l_param.atdsrvano = arg_val(6)
 let l_param.acao      = arg_val(7)

 let l_totalGeral   = 0

 set isolation to dirty read

 declare cwdatc065001 cursor for
 select b.soccstdes, a.socadccstqtd, a.socadccstvlr
  from dbsmsrvcst a, dbskcustosocorro b
 where a.atdsrvnum = l_param.atdsrvnum
   and a.atdsrvano = l_param.atdsrvano
   and b.soccstcod = a.soccstcod

     -- [ Impressao ] --
     -- [ Esta com height 2 para acompanhar o ] --
     -- [ outro programa q gera o laudo 017   ] --
 display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Adicionais@@@@"

# OSF 20370
{
 display "PADRAO@@10@@4@@2@@0@@B@@C@@M@@4@@3@@2@@25%@@Custo@@@@",
                               "B@@C@@M@@4@@3@@1@@25%@@Quantidade@@@@",
                               "B@@C@@M@@4@@3@@1@@25%@@Valor unitário@@@@",
                               "B@@C@@M@@4@@3@@1@@25%@@Valor total@@@@"
}

 display "PADRAO@@10@@3@@2@@0@@B@@C@@M@@4@@3@@2@@34%@@Custo@@@@",
                               "B@@C@@M@@4@@3@@2@@33%@@Quantidade@@@@",
                               "B@@C@@M@@4@@3@@2@@33%@@Valor total@@@@"

 display "PADRAO@@1@@B@@C@@0@@Adicionais@@"

 # OSF 20370
 #display "PADRAO@@6@@4@@B@@C@@0@@2@@25%@@Custo@@@@B@@C@@0@@2@@25%@@Quantidade@@@@B@@C@@0@@2@@25%@@Valor unitário@@@@B@@C@@0@@2@@25%@@Valor total@@@@"

 display "PADRAO@@6@@3@@N@@C@@0@@1@@34%@@Custo@@@@N@@C@@0@@1@@33%@@Quantidade@@@@N@@C@@0@@1@@33%@@Valor total@@@@"

 foreach cwdatc065001 into l_adicionais.*
     display "PADRAO@@6",
             "@@3@@N@@L@@1@@1@@34%@@", l_adicionais.soccstdes clipped,
             "@@@@N@@C@@1@@1@@33%@@",  l_adicionais.socadccstqtd
                                       using "<<<<<<<<<<&",
             "@@@@N@@C@@1@@1@@33%@@",  l_adicionais.socadccstvlr
                                       using "<<<<<<<<<<<<&.&&"

     -- [ Impressao ] --
     display "PADRAO@@10@@3@@2@@0@@",
             "N@@C@@M@@4@@3@@1@@34%@@", l_adicionais.soccstdes clipped, "@@@@",
             "N@@C@@M@@4@@3@@1@@33%@@", l_adicionais.socadccstqtd
                                        using "<<<<<<<<<<&", "@@@@",
             "N@@C@@M@@4@@3@@1@@33%@@", l_adicionais.socadccstvlr
                                        using "<<<<<<<<<<<<&.&&", "@@@@"

     let l_totalGeral = l_totalGeral + l_adicionais.socadccstvlr
 end foreach

 display "PADRAO@@6@@3"
        ,"@@N@@L@@1@@1@@34%@@@@"
        ,"@@N@@C@@1@@1@@33%@@Total@@"
        ,"@@N@@C@@1@@1@@33%@@", l_totalGeral using "<<<<<<<<<<<<<<<<<<&.&&"
        ,"@@"

     -- [ Impressao ] --
 display "PADRAO@@10@@3@@2@@0@@N@@C@@M@@4@@3@@1@@34%@@&nbsp;@@@@",
                              "N@@C@@M@@4@@3@@1@@33%@@Total@@@@",
                              "N@@C@@M@@4@@3@@1@@33%@@", l_totalGeral
                                       using "<<<<<<<<<<<<<<<<<<&.&&" , "@@@@"

end function


 function fonetica2()

 end function
 
 function conqua59()

 end function
