#############################################################################
# Nome do Modulo: CTX08G04                                             Akio #
#                                                                      Ruiz #
# Atendimento ao corretor - Funcao de gravacao ligacao x pac       Jul/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

 define g_ctx08g04        char(01)


#-------------------------------------------------------------------------------
 function ctx08g04( p_ctx08g04 )
#-------------------------------------------------------------------------------

   define p_ctx08g04      record
          corlignum       like dacmlig.corlignum      ,
          corligitmseq    like dacmligass.corligitmseq,
          fcapacorg       like mfimanalise.fcapacorg  ,
          fcapacnum       like mfimanalise.fcapacnum
   end record

   define w_ret           smallint

   define w_com           char(1000)

   define ws              record
          corligano       smallint
   end record


	let	w_ret  =  null

	initialize  ws.*  to  null

   let ws.corligano = year(today)
   let w_ret = false

  let w_com = "select * from dacrligpac ",
              " where corlignum    = ? ",
              "   and corligano    = ? ",
              "   and corligitmseq = ? "
  prepare p_ctx08g04_001 from w_com
  declare c_ctx08g04_001 cursor for p_ctx08g04_001
  #-------------------------------------------------------------------------
  # Grava relacionamento ligacao x pac
  #-------------------------------------------------------------------------


  open c_ctx08g04_001 using p_ctx08g04.corlignum   ,
                          ws.corligano           ,
                          p_ctx08g04.corligitmseq
  fetch c_ctx08g04_001

  if status = notfound then

     insert into dacrligpac( corlignum   ,
                             corligano   ,
                             corligitmseq,
                             fcapacorg   ,
                             fcapacnum    )
                 values( p_ctx08g04.corlignum   ,
                         ws.corligano           ,
                         p_ctx08g04.corligitmseq,
                         p_ctx08g04.fcapacorg   ,
                         p_ctx08g04.fcapacnum    )

     if sqlca.sqlcode = 0  then
        let w_ret = true
     end if

  else
     let w_ret = true
  end if

  return w_ret

end function

