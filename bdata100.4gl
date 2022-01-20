################################################################################
# Nome do Modulo: BDATA100                                         Alberto     #
#                                                                  Alberto     #
# Qtde de ligacoes para os respectivos assunto cada 2 minutos      Mar/1997    #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
# 30/04/2008  DVP 51578    Alberto      Painel Flexvision com as ligacoes dos  #
#                                       assuntos principais(S10,S60,S63,N10 e  #
#                                       G99                                    #
#------------------------------------------------------------------------------#
################################################################################

database porto

define wa          record
   assunto         char(80),
   c24astcod       like datmligacao.c24astcod,
   c24astagpdes    like datkastagp.c24astagpdes,
   c24astdes       like datkassunto.c24astdes,
   qtde            decimal(10,0)
end record

define n_total     decimal(7,0)

main

   let n_total = 0

   call fun_dba_abre_banco('CT24HS')

   set isolation to dirty read


   ##select   a.c24astcod ,c.c24astagpdes, b.c24astdes  DESCRICAO,
   ##         count(*) QTDE_LIGACAO
   ##from    datmligacao a, datkassunto b, datkastagp c
   ##where   a.ligdat   = today
   ##and     (a.c24astcod In ("S10", "S60", "S63", "N10" ) or
   ##         a.c24astcod matches("G%") )
   ##and      a.c24astcod = b.c24astcod
   ##and      b.c24astagp = c.c24astagp
   ##group by a.c24astcod, b.c24astdes, c.c24astagpdes

   select  "999"  c24astcod ,
           "OUTRAS LIGACOES" descricao,
           count(*) qtde_ligacao
   from    datmligacao a
   where   a.ligdat   = today
   ##and     (a.c24astcod In ("S10", "S60", "S63", "N10" ) or
   ##         a.c24astcod matches("G%") )
   ##order by c24astcod
   into temp central with no log ;

   ##select c24astcod, descricao, qtde_ligacao
   ##from   central
   ##where  c24astcod is null
   ##into temp ligct24 with no log


   ##declare cur001 cursor for
   ##select c24astcod, c24astagpdes, DESCRICAO , QTDE_LIGACAO
   ##from   central
   ##
   ##foreach cur001 into wa.c24astcod    , wa.c24astagpdes,
   ##                    wa.c24astdes    , wa.qtde
   ##
   ##let wa.assunto =  wa.c24astagpdes clipped," - ", wa.c24astdes
   ##
   ##insert into ligct24( c24astcod,    c24astagpdes,    DESCRICAO,  qtde_ligacao )
   ##             values( wa.c24astcod, wa.c24astagpdes, wa.assunto, wa.qtde      )
   ##
   ##end foreach

   ##select  "999"  c24astcod ,
   ##        "OUTRAS LIGACOES " descricao,
   ##        count(*) qtde_ligacao
   ##from    datmligacao a
   ##where   a.ligdat   = today
   ##and     (a.c24astcod not In ("S10", "S60", "S63", "N10" ) or
   ##         a.c24astcod matches("G%") )
   ##order by c24astcod
   ##into temp central1 with no log ;


   ##select  count(*)
   ##into    n_total
   ##from    datmligacao a, datkassunto b, datkastagp c
   ##where   a.ligdat   = today
   ##and     (a.c24astcod not In ("S10", "S60", "S63", "N10" ) or
   ##         a.c24astcod[1,1] <> "G%" )
   ##and      a.c24astcod = b.c24astcod
   ##and      b.c24astagp = c.c24astagp
   ##
   ##
   ##insert into ligct24( c24astcod,    c24astagpdes,    DESCRICAO,           qtde_ligacao )
   ##             values( "999",        " ",             "OUTRAS LIGACOES ",  n_total      )

   #insert into central
   #select * from central1

   unload to "../adat/LIGCT24.TXT"
   select c24astcod,DESCRICAO, qtde_ligacao
   from   central
   #from   ligct24
   order by c24astcod

end main 