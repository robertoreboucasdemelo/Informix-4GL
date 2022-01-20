#############################################################################
# Nome do Modulo: cte03m01                                             Raji #
#                                                                           #
# Atendimento ao corretor - Funcao de gravacao ligacao x ura       Set/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------------------
 function cte03m01( p_cte03m01 )
#-------------------------------------------------------------------------------
 define p_cte03m01      record
        corlignum       like dacrligura.corlignum,
        corligano       like dacrligura.corligano,
        c24paxnum       like dacmlig.c24paxnum
 end record

 define d_cte03m01      record
        dddcod          like dacmligurastt.dddcod,
        facnum          like dacmligurastt.facnum
 end record

 define ws              record
        prporgpcp       like dacrligorc.prporgpcp,
        prpnumpcp       like dacrligorc.prpnumpcp,
        dat             like dacmligurastt.atdtrxdat,
        hor             like dacmligurastt.atdtrxhor,
        resp            char (1),
        msg             char (40),
        contador        smallint,
        orcamentos      smallint
 end record

 define sql_comando  char (900)


	let	sql_comando  =  null

	initialize  d_cte03m01.*  to  null

	initialize  ws.*  to  null

 initialize d_cte03m01    to null
 initialize ws.*          to null

 #--------------------------------------------------------------------
 # Cursor para obtencao dos orcamentos/propostas da ligacao
 #--------------------------------------------------------------------
 declare c_cte03m01 cursor for
    select dctorg   ,
           dctnumdig
      from dacrligura
     where corlignum  = p_cte03m01.corlignum
       and corligano  = p_cte03m01.corligano

 open c_cte03m01
 fetch c_cte03m01 into ws.*
 let ws.orcamentos = sqlca.sqlcode
 close c_cte03m01

 if ws.orcamentos = notfound then
    return
 end if

 if cts08g01("A", "S",      "Verifique se o corretor esta falando de",
                            "um  aparelho de fax, para  transmissao",
                            "imediata dos orcamentos?              ","")
   = "S" then
    let ws.msg =  p_cte03m01.corlignum using "########&",
                  " - ",
                  p_cte03m01.c24paxnum using "####"
    call cts08g01("A", "",  "Transfira a ligacao para o ramal 2660",
                            "e digite:                              ",
                            "Numero da ligacao e o Numero sua PA",
                            ws.msg)
         returning ws.resp
 end if
end function

