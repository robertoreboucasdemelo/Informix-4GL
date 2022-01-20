#############################################################################
# Nome do Modulo: ctx09g02                                             Raji #
#                                                                           #
# Funcao de gravacao problemas para servicos                       Dez/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################
# ......................................................................... #
#                                                                           #
#                           * * * ALTERACOES * * *                          #
#                                                                           #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                           #
# ---------- --------------  ---------- ------------------------------------#
# 19/09/2007 Luciano, Meta   psi211982  Inclusao da funcao                  #
#                                       ctx09g02_seleciona()                #
#                                       alteracao caminho globals           #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_ctx09g02_prep smallint

#---------------------------#
function ctx09g02_prepare()
#---------------------------#
   define l_sql_stmt  char(500)

   let l_sql_stmt = " select c24pbmcod, c24pbmdes "
                   ,"   from datrsrvpbm           "
                   ,"  where atdsrvnum = ?        "
                   ,"    and atdsrvano = ?        "
                   ,"    and c24pbmseq = 1        "
   prepare pctx09g02001 from l_sql_stmt
   declare cctx09g02001 cursor for pctx09g02001
   let m_ctx09g02_prep = true
end function

#-------------------------------------#
function ctx09g02_seleciona(lr_param)
#-------------------------------------#
   define lr_param      record
          nivel_retorno smallint
         ,atdsrvnum     like datrsrvpbm.atdsrvnum
         ,atdsrvano     like datrsrvpbm.atdsrvano
   end record

   define lr_retorno    record
          resultado     smallint
         ,mensagem      char(60)
         ,c24pbmcod     like datrsrvpbm.c24pbmcod
         ,c24pbmdes     like datrsrvpbm.c24pbmdes
   end record
   if m_ctx09g02_prep is null or
      m_ctx09g02_prep <> true then
      call ctx09g02_prepare()
   end if
   initialize lr_retorno to null
   let lr_retorno.resultado = 1
   open cctx09g02001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
   whenever error continue
   fetch cctx09g02001 into lr_retorno.c24pbmcod
                          ,lr_retorno.c24pbmdes
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem = "Nao achou o problema do servico: ", lr_param.atdsrvnum, " / ", lr_param.atdsrvano
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem = "Erro no acesso a tabela datrsrvpbm: ", sqlca.sqlcode
      end if
   end if

   case lr_param.nivel_retorno
        when 1
             return lr_retorno.resultado
                   ,lr_retorno.mensagem
                   ,lr_retorno.c24pbmcod
                   ,lr_retorno.c24pbmdes
   end case
end function

#-------------------------------------------------------------------------------
 function ctx09g02_inclui( p_ctx09g02 )
#-------------------------------------------------------------------------------
   define p_ctx09g02      record
          atdsrvnum       like datmservico.atdsrvnum,
          atdsrvano       like datmservico.atdsrvano,
          c24pbminforg    like datrsrvpbm.c24pbminforg,
          c24pbmcod       like datkpbm.c24pbmcod,
          c24pbmdes       like datkpbm.c24pbmdes,
          pstcoddig       like datrsrvpbm.pstcoddig
   end record

   define ws              record
          c24pbmseq       like datrsrvpbm.c24pbmseq
   end record

   define w_ret           record
          cod             smallint,
          msg             char(70)
   end record



	initialize  ws.*  to  null

	initialize  w_ret.*  to  null

   let w_ret.cod = 0
   let w_ret.msg = "TABELA GRAVADA COM SUCESSO"

   if  p_ctx09g02.atdsrvnum    is null  or
       p_ctx09g02.atdsrvano    is null  or
       p_ctx09g02.c24pbminforg is null  or
       p_ctx09g02.c24pbmcod    is null  or
       p_ctx09g02.c24pbmdes    is null  or
       (p_ctx09g02.pstcoddig   is null  and
        p_ctx09g02.c24pbminforg = 2 ) then
       let w_ret.cod = 1
       let w_ret.msg = "PARAMETRO INVALIDO"
       return w_ret.*
   end if

   if p_ctx09g02.c24pbminforg = 1 then
      let p_ctx09g02.pstcoddig = g_issk.funmat
   end if

   #-------------------------------------------------------------------------
   # Grava problemas do servico
   #-------------------------------------------------------------------------
   select max(c24pbmseq) into ws.c24pbmseq
     from datrsrvpbm
    where atdsrvnum    = p_ctx09g02.atdsrvnum
      and atdsrvano    = p_ctx09g02.atdsrvano
      and c24pbminforg = p_ctx09g02.c24pbminforg

   if ws.c24pbmseq is null then
      let ws.c24pbmseq = 1
   else
      let ws.c24pbmseq = ws.c24pbmseq + 1
   end if

   #whenever error continue
   insert into datrsrvpbm( atdsrvnum,
                           atdsrvano,
                           c24pbmseq,
                           c24pbminforg,
                           c24pbmcod,
                           c24pbmdes,
                           caddat,
                           cadmat,
                           cademp,
                           cadusrtip,
                           pstcoddig)
                   values( p_ctx09g02.atdsrvnum,
                           p_ctx09g02.atdsrvano,
                           ws.c24pbmseq,
                           p_ctx09g02.c24pbminforg,
                           p_ctx09g02.c24pbmcod,
                           p_ctx09g02.c24pbmdes,
                           today,
                           g_issk.funmat,
                           g_issk.empcod,
                           g_issk.usrtip,
                           p_ctx09g02.pstcoddig)


   if  sqlca.sqlcode <> 0  then
       let w_ret.cod = 99
       let w_ret.msg = "ERRO ", sqlca.sqlcode, " NA GRAVACAO DA ",
                       "TABELA DATRSRVPBM. AVISE A INFORMATICA. "
   end if
   #whenever error stop

   return w_ret.*
end function


#-------------------------------------------------------------------------------
 function ctx09g02_altera( p_ctx09g02 )
#-------------------------------------------------------------------------------
   define p_ctx09g02      record
          atdsrvnum       like datmservico.atdsrvnum,
          atdsrvano       like datmservico.atdsrvano,
          c24pbmseq       like datrsrvpbm.c24pbmseq,
          c24pbminforg    like datrsrvpbm.c24pbminforg,
          c24pbmcod       like datkpbm.c24pbmcod,
          c24pbmdes       like datkpbm.c24pbmdes,
          pstcoddig       like datrsrvpbm.pstcoddig
   end record

   define ws              record
          c24pbmseq       like datrsrvpbm.c24pbmseq
   end record

   define w_ret           record
          cod             smallint,
          msg             char(70)
   end record



	initialize  ws.*  to  null

	initialize  w_ret.*  to  null

   let w_ret.cod = 0
   let w_ret.msg = "TABELA GRAVADA COM SUCESSO"

   if  p_ctx09g02.atdsrvnum    is null  or
       p_ctx09g02.atdsrvano    is null  or
       p_ctx09g02.c24pbminforg is null  or
       p_ctx09g02.c24pbmcod    is null  or
       p_ctx09g02.c24pbmdes    is null  or
       (p_ctx09g02.pstcoddig   is null  and
        p_ctx09g02.c24pbminforg = 2 ) then
       let w_ret.cod = 1
       let w_ret.msg = "PARAMETRO INVALIDO"
       return w_ret.*
   end if

   if p_ctx09g02.c24pbminforg = 1 then
      let p_ctx09g02.pstcoddig = g_issk.funmat
   end if

   #-------------------------------------------------------------------------
   # Altera tabela problemas x servico
   #-------------------------------------------------------------------------
   #whenever error continue
   update datrsrvpbm set ( c24pbmcod,
                          c24pbmdes)
                       = ( p_ctx09g02.c24pbmcod,
                           p_ctx09g02.c24pbmdes)
    where atdsrvnum    = p_ctx09g02.atdsrvnum
      and atdsrvano    = p_ctx09g02.atdsrvano
      and c24pbmseq    = p_ctx09g02.c24pbmseq
      and c24pbminforg = p_ctx09g02.c24pbminforg


   if  sqlca.sqlcode <> 0  then
       let w_ret.cod = 99
       let w_ret.msg = "ERRO ", sqlca.sqlcode, " NA GRAVACAO DA ",
                       "TABELA DATRSRVPBM. AVISE A INFORMATICA. "
   end if
   #whenever error stop

   return w_ret.*
end function

