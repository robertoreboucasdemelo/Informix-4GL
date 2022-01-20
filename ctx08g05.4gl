#############################################################################
# Nome do Modulo: CTX08G05                                             Akio #
#                                                                      Ruiz #
# Atendimento ao corretor - Funcao de gravacao ligacao x orc. RE   Jul/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

 define g_ctx08g05        char(01)


#-------------------------------------------------------------------------------
 function ctx08g05( p_ctx08g05 )
#-------------------------------------------------------------------------------

   define p_ctx08g05      record
          corlignum       like dacmlig.corlignum      ,
          corligitmseq    like dacmligass.corligitmseq,
          prporg          like dacrligrmeorc.prporg   ,
          prpnumdig       like dacrligrmeorc.prpnumdig
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
  # Grava relacionamento ligacao x orcamento RE
  #-------------------------------------------------------------------------
    insert into dacrligrmeorc( corlignum   ,
                               corligano   ,
                               corligitmseq,
                               prporg      ,
                               prpnumdig    )
                values( p_ctx08g05.corlignum   ,
                        ws.corligano           ,
                        p_ctx08g05.corligitmseq,
                        p_ctx08g05.prporg      ,
                        p_ctx08g05.prpnumdig    )

   if  sqlca.sqlcode = 0  then
       let w_ret = true
   end if

   return w_ret

end function

