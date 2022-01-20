#############################################################################
# Nome do Modulo: CTX08G03                                             Ruiz #
#                                                                      Akio #
# Atendimento ao corretor - Funcao de gravacao ligacao x convenio  Jun/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 09/09/2002               Henrique     Atualiza consulta convenio          #
#############################################################################

 database porto


 define g_ctx08g03        char(01)


#-------------------------------------------------------------------------------
 function ctx08g03( p_ctx08g03 )
#-------------------------------------------------------------------------------

   define p_ctx08g03      record
          corlignum       like dacmlig.corlignum      ,
          corligitmseq    like dacmligass.corligitmseq,
          cvnslcnum       like dacrligpndcvn.cvnslcnum
   end record

   define w_ret           record
          cod             smallint,
          msg             char(70)
   end record

   define ws              record
          corligano       smallint
   end record



	initialize  w_ret.*  to  null

	initialize  ws.*  to  null

   whenever error continue

   let ws.corligano = year(today)
   let w_ret.cod = 0
   let w_ret.msg = "TABELA DE RELACIONAMENTO GRAVADA COM SUCESSO"

   while true

   if  p_ctx08g03.corlignum    is null  or
       p_ctx08g03.corligitmseq is null  then
       let w_ret.cod = 1
       let w_ret.msg = "PARAMETRO INVALIDO - NUMERO DA LIGACAO"
       exit while
   end if

   if  p_ctx08g03.cvnslcnum is null  then
       let w_ret.cod = 1
       let w_ret.msg = "PARAMETRO INVALIDO - NUMERO DA SOLICITACAO"
       exit while
   end if

   #-------------------------------------------------------------------------
   # Grava relacionamento ligacao x pendencia convenio
   #-------------------------------------------------------------------------
     insert into dacrligpndcvn( corlignum,
                                corligano,
                                corligitmseq,
                                cvnslcnum    )
                        values( p_ctx08g03.corlignum   ,
                                ws.corligano           ,
                                p_ctx08g03.corligitmseq,
                                p_ctx08g03.cvnslcnum    )


   if  sqlca.sqlcode = 0  then
       exit while
   else
      if  sqlca.sqlcode = 268  then
          let w_ret.cod = 2
          let w_ret.msg = "SOLICITACAO JA GRAVADO PARA ESTE ITEM DA LIGACAO. ",
                          "INCLUA NOVO ASSUNTO."
          exit while
      else
          let w_ret.cod = 99
          let w_ret.msg = "ERRO ", sqlca.sqlcode, " NA GRAVACAO DA ",
                          "TABELA DACRLIGPNDCVN. AVISE A INFORMATICA. "
          exit while
      end if
   end if

   end while

   whenever error stop

   return w_ret.*

end function

