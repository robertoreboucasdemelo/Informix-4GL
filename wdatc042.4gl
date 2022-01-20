#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : wdatc042.4gl                                              #
#                  Valida e atualiza sessao                                  #
# Analista Resp. : Carlos Pessoto                                            #
# PSI            : 163759 -                                                  #
# OSF            : 5289   -                                                  #
#............................................................................#
# Desenvolvimento: Fabrica de Software - Ronaldo Marques                     #
# Liberacao      : 26/06/2003                                                #
#............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Incluida funcao fun_dba_abre_banco. #
###############################################################################

database porto

main
    call fun_dba_abre_banco("CT24HS")
    call wdatc042()
end main
-------------------------------------------------------------------------------
function wdatc042()
-------------------------------------------------------------------------------
 define l_param       record
	atdsrvnum		like datmservico.atdsrvnum,
	atdsrvano		like datmservico.atdsrvano,
	acao	 		char(1)
 end record

 define	l_adicionais		record
	soccstdes		like dbskcustosocorro.soccstdes,
	socadccstqtd	like dbsmopgcst.cstqtd,
	socadccstvlr	like dbsmopgcst.socopgitmcst,
	totvlr			dec(20,5)
 end	record

 define	l_totalGeral		dec(25,5)
 define l_ciaempcod like datmservico.ciaempcod

 -- [ Sessao ja eh verificada e atualiza no wdatc017 ] --

 initialize l_param.* to null
 initialize l_adicionais.* to null
 initialize l_totalGeral to null
 initialize l_ciaempcod  to null

 let l_param.atdsrvnum = arg_val(5)
 let l_param.atdsrvano = arg_val(6)
 let l_param.acao      = arg_val(7)

 let l_totalGeral   = 0

 set isolation to dirty read

 declare cwdatc042001 cursor for
 select c.soccstdes, a.cstqtd, a.socopgitmcst, (a.cstqtd * a.socopgitmcst)
  from dbsmopgcst a, dbsmopgitm b, dbskcustosocorro c
 where b.atdsrvnum    = l_param.atdsrvnum
   and b.atdsrvano    = l_param.atdsrvano
   and b.socopgnum    = a.socopgnum
   and b.socopgitmnum = a.socopgitmnum
   and c.soccstcod    = a.soccstcod

     -- [ Impressao ] --
     -- [ Esta com height 2 para acompanhar o ] --
     -- [ outro programa q gera o laudo 017   ] --
 display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Adicionais@@@@"

# OSF 20370
{
 display "PADRAO@@10@@4@@2@@0@@B@@C@@M@@4@@3@@2@@25%@@Custo@@@@",
                               "B@@C@@M@@4@@3@@2@@25%@@Quantidade@@@@",
                               "B@@C@@M@@4@@3@@2@@25%@@Valor unitário@@@@",
                               "B@@C@@M@@4@@3@@2@@25%@@Valor total@@@@"
}

 display "PADRAO@@10@@3@@2@@0@@B@@C@@M@@4@@3@@2@@34%@@Custo@@@@",
                               "B@@C@@M@@4@@3@@2@@33%@@Quantidade@@@@",
                               "B@@C@@M@@4@@3@@2@@33%@@Valor total@@@@"

 display "PADRAO@@1@@B@@C@@0@@Adicionais@@"

 # OSF 20370
 #display "PADRAO@@6@@4@@B@@C@@0@@2@@25%@@Custo@@@@B@@C@@0@@2@@25%@@Quantidade@@@@B@@C@@0@@2@@25%@@Valor unitário@@@@B@@C@@0@@2@@25%@@Valor total@@@@"

 display "PADRAO@@6@@3@@B@@C@@0@@2@@34%@@Custo@@@@B@@C@@0@@2@@33%@@Quantidade@@@@B@@C@@0@@2@@33%@@Valor total@@@@"

 foreach cwdatc042001 into l_adicionais.*
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

 #PSI 208264 - Busca o codigo da CIA e da o
 #display para informar qual logo deve ser utilizado
 select ciaempcod into l_ciaempcod
   from datmservico
  where atdsrvnum = l_param.atdsrvnum
    and atdsrvano = l_param.atdsrvano
 if  sqlca.sqlcode <> 0 then
     let l_ciaempcod = 999
 end if
 display "PADRAO@@12@@", l_ciaempcod, "@@"
 #PSI 208264

end function
