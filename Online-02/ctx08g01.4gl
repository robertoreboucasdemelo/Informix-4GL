#############################################################################
# Nome do Modulo: CTX08G01                                             Akio #
#                                                                      Ruiz #
# Atendimento ao corretor - Funcao de gravacao ligacao x vistoria  Abr/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

 define g_ctx08g01        char(01)


#-------------------------------------------------------------------------------
 function ctx08g01( p_ctx08g01 )
#-------------------------------------------------------------------------------

   define p_ctx08g01      record
          corlignum       like dacmlig.corlignum      ,
          corligitmseq    like dacmligass.corligitmseq,
          atdsrvnum       like dacrligvst.atdsrvnum   ,
          atdsrvano       like dacrligvst.atdsrvano   ,
          vstnumdig       like dacrligvst.vstnumdig
   end record

   define w_ret           smallint

   define ws              record
          corligano       smallint
   end record


	let	w_ret  =  null

	initialize  ws.*  to  null

   let ws.corligano = year(today)
   let w_ret = false

  #-------------------------------------------------------------------------
  # Grava relacionamento ligacao x vistoria
  #-------------------------------------------------------------------------
    insert into dacrligvst( corlignum   ,
                            corligano   ,
                            corligitmseq,
                            atdsrvnum   ,
                            atdsrvano   ,
                            vstnumdig    )
                values( p_ctx08g01.corlignum   ,
                        ws.corligano           ,
                        p_ctx08g01.corligitmseq,
                        p_ctx08g01.atdsrvnum   ,
                        p_ctx08g01.atdsrvano   ,
                        p_ctx08g01.vstnumdig    )

   if  sqlca.sqlcode = 0  then
       let w_ret = true
   end if

   return w_ret

end function

