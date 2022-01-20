#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : ctx20g00a.4gl                                             #
#                  Tela com quantidade de trocas de vidros.                  #
# Analista Resp. : Ruiz / Natal                                              #
# OSF            : 21580 -                                                   #
#............................................................................#
# Desenvolvimento: Fabrica de Software - Ronaldo Marques                     #
# Liberacao      : 12/06/2003                                                #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data        Autor Fabrica  Data   Alteracao                                #
# ----------  -------------  ------ -----------------------------------------#
#----------------------------------------------------------------------------#
database porto
----------------------------------------------------------------------
function ctx20g00a(l_entrada)
----------------------------------------------------------------------
 define l_entrada       record
	qtd_rep		smallint,
	qtd_troca	smallint,
	qtd_retro	smallint,
        vigini          date,
        vigfnl          date,
        vclchsfnl       like adimvdrrpr.vclchsfnl,
        vcllicnum       like adimvdrrpr.vcllicnum
 end    record
 define	l_chr 		char(01)

 open window w_ctx20g00a
      at 6,18
        with form 'ctx20g00a'
             attribute (form line first,
                        prompt line last,
                        border)

 display by name l_entrada.qtd_troca,
                 l_entrada.qtd_retro,
                 l_entrada.qtd_rep

 let int_flag = false
 while not int_flag
       prompt "" for char l_chr
          on key (f8, accept)
             call ctx20g00("T",
                           l_entrada.vigini,
                           l_entrada.vigfnl,
                           l_entrada.vclchsfnl,
                           l_entrada.vcllicnum)
              let int_flag = false

          on key (f17,interrupt)
              let int_flag = true
       end prompt
 end while

 close window w_ctx20g00a

 let int_flag = false

end function
