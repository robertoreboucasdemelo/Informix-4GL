#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta14m00.4gl                                               #
# Analista Resp : Carla Rampazzo                                             #
# PSI           : 219444                                                     #
#                 Verificar se ha cortesia em um servico.                    #
# Desenvolvimento: Patricia Wissinievski                                     #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 22/03/2010 Patricia W.       PSI 219444 Criacao do modulo                  #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql smallint

#-----------------------------------------------------------------------------
function cta14m00_prepare()
#-----------------------------------------------------------------------------
   define l_sql char(500)
   
   let l_sql = "select c24astcod from datmligacao ",
               " where atdsrvano = ? ",
                 " and atdsrvnum = ?"
   prepare pcta14m00001 from l_sql                        
   declare ccta14m00001 cursor for pcta14m00001


   let l_sql = "select 1 from iddkdominio ",
               " where cponom = 'c24astcod_cort'",
                 " and cpodes = ?"
   prepare pcta14m00002 from l_sql                        
   declare ccta14m00002 cursor for pcta14m00002


   let l_sql = "select pgttipcodps from dbscadtippgt ",
               " where anosrv = ? ",
                 " and nrosrv = ?"
   prepare pcta14m00003 from l_sql                        
   declare ccta14m00003 cursor for pcta14m00003
   
   let m_prep_sql = null 
   
end function

#-----------------------------------------------------------------------------
function cta14m00(p_servico,p_ano)
#-----------------------------------------------------------------------------
# Tipos de atendimento (tipoatd) possiveis:
# 1 – Atendimento dentro do limite da clausula – Paga pelo Produto
# 2 – Atendimento em cortesia – Paga pelo Produto
# 3 – Atendimento em cortesia – Paga por Centro de Custo diferente do Produto

   define p_ano          like datmservico.atdsrvano,
          p_servico      like datmservico.atdsrvnum,
          l_assunto      like datmligacao.c24astcod,
          l_pgttipcodps  like dbscadtippgt.pgttipcodps,
          l_cortesia     integer,
          l_tipo         integer,
          l_status       integer

   define l_retorno      record 
          tipoatd        decimal(2),
          codigo_erro    smallint,
          mensagem_erro  char(60)
   end record      
   
   initialize l_assunto to null
   
   if m_prep_sql = false or  
      m_prep_sql is null then 
      call cta14m00_prepare()   
   end if 
   
   let l_status                = 0
   let l_retorno.tipoatd       = 1 --> Atdto dentro do limite da clausula  
   let l_retorno.codigo_erro   = 0
   let l_retorno.mensagem_erro = ""
   
   #verifica assuntos do servico
   open ccta14m00001 using p_ano,p_servico
      foreach ccta14m00001 into l_assunto

         if sqlca.sqlcode < 0  then
            let l_retorno.codigo_erro   = sqlca.sqlcode
            let l_retorno.tipoatd       = 0
            let l_retorno.mensagem_erro = "cta14m00: Erro na leitura da tabela  DATMLIGACAO."
            return l_retorno.tipoatd, 
                   L_retorno.codigo_erro, 
                   l_retorno.mensagem_erro
         end if
         
         let l_status   = 1
         let l_cortesia = 0
            
         #verifica se assunto esta informado como cortesia - iddk
         open ccta14m00002 using l_assunto
         fetch ccta14m00002 into l_cortesia
         close ccta14m00002 
         
         if sqlca.sqlcode < 0  then
            let l_retorno.codigo_erro   = sqlca.sqlcode
            let l_retorno.tipoatd       = 0
            let l_retorno.mensagem_erro = "cta14m00: Erro na leitura da tabela  IDDKDOMINIO."
            return l_retorno.tipoatd, 
                   l_retorno.codigo_erro, 
                   l_retorno.mensagem_erro
         end if
         

         if l_cortesia = 1 then
            let l_pgttipcodps = 0
            
            #verifica se assunto cortesia esta na tabela dbscadtippgt
            open ccta14m00003 using p_ano, p_servico
            fetch ccta14m00003 into l_pgttipcodps

            if sqlca.sqlcode < 0  then
               let l_retorno.codigo_erro   = sqlca.sqlcode
               let l_retorno.tipoatd       = 0
               let l_retorno.mensagem_erro = "cta14m00: Erro na leitura da tabela  DBSCADTIPPGT."
               return l_retorno.tipoatd, 
                      l_retorno.codigo_erro, 
                      l_retorno.mensagem_erro
            end if
            
            close ccta14m00003
            
            if l_pgttipcodps <> 0 then
               let l_retorno.tipoatd = 3
            else
               let l_retorno.tipoatd = 2
            end if
            exit foreach
         else
            let l_retorno.tipoatd = 1   
         end if 
      end foreach
   close ccta14m00001 
   
   #nao encontrou nenhum assunto
   if (l_status = 0) then 
      let l_retorno.codigo_erro = 1
      let l_retorno.mensagem_erro = "Nenhum assunto encontrado para Ano e Servico informados"
   end if   

   return l_retorno.tipoatd, 
          l_retorno.codigo_erro, 
          l_retorno.mensagem_erro

end function
