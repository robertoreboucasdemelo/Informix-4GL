#############################################################################
# Nome do Modulo: ctx08g06                                             Raji #
#                                                                           #
# Atendimento ao corretor - Funcao de gravacao ligacao x ura       Set/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

#-------------------------------------------------------------------------------
 function ctx08g06( p_ctx08g06 )
#-------------------------------------------------------------------------------

   define p_ctx08g06      record
          corlignum       like dacrligura.corlignum,
          corligitmseq    like dacrligura.corligitmseq,
          dctorg          like dacrligura.dctorg,
          dctnumdig       like dacrligura.dctnumdig,
          c24paxnum       like dacrligura.c24paxnum,
          cvnnum          like dacrligura.cvnnum,
          coruraacscod    like dacrligura.coruraacscod
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

   if  p_ctx08g06.corlignum    is null  or
       p_ctx08g06.corligitmseq is null  then
       let w_ret.cod = 1
       let w_ret.msg = "PARAMETRO INVALIDO - NUMERO DA LIGACAO"
       exit while
   end if

   if  p_ctx08g06.dctorg    is null  or
       p_ctx08g06.dctnumdig is null  then
           let w_ret.cod = 1
           let w_ret.msg = "PARAMETRO INVALIDO - PROPOSTA ORCAMENTO"
       exit while
   end if


      #-------------------------------------------------------------------------
      # Grava relacionamento ligacao x ura
      #-------------------------------------------------------------------------
           insert into dacrligura( corlignum,
                                   corligano,
                                   corligitmseq,
                                   dctorg,
                                   dctnumdig,
                                   c24paxnum,
                                   cvnnum,
                                   faxtrxgerflg,
                                   coruraacscod)
                               values( p_ctx08g06.corlignum   ,
                                       ws.corligano           ,
                                       p_ctx08g06.corligitmseq,
                                       p_ctx08g06.dctorg      ,
                                       p_ctx08g06.dctnumdig   ,
                                       p_ctx08g06.c24paxnum   ,
                                       p_ctx08g06.cvnnum      ,
                                       "N",
                                       p_ctx08g06.coruraacscod)


   if  sqlca.sqlcode = 0  then
       exit while
   else
    if  sqlca.sqlcode = -268  then
            let w_ret.cod = 2
            let w_ret.msg = "ORCAMENTO JA GRAVADO PARA ESTE ITEM DA LIG/URA. ",
                            "INCLUA NOVO ASSUNTO."
            exit while
    else
            let w_ret.cod = 99
            let w_ret.msg = "ERRO ", sqlca.sqlcode, " NA GRAVACAO DA ",
                            "TABELA DACRLIGURA. AVISE A INFORMATICA. "
            exit while
    end if
   end if

   end while

   whenever error stop

   return w_ret.*

end function

