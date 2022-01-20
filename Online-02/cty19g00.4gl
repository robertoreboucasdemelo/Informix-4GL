###############################################################################
# Nome do Modulo: CTY19G00                                      Carla Rampazzo#
#                                                                             #
# Funcao que Calcula o Total de Atendimentos por Assunto              NOV/2009#
###############################################################################
# Alteracoes:                                                                 #
#-----------------------------------------------------------------------------#
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

#----------------------------------------------------------------------------#
 function cty19g00(param)
#----------------------------------------------------------------------------#

   define param          record
          prporg         like datrligprp.prporg
         ,prpnumdig      like datrligprp.prpnumdig
         ,succod         like datrligapol.succod
         ,ramcod         like datrligapol.aplnumdig
         ,aplnumdig      like datrligapol.aplnumdig
         ,itmnumdig      like datrligapol.itmnumdig
   end record

   define l_cty19g00     record
          atdsrvnum      like datmservico.atdsrvnum
         ,atdsrvano      like datmservico.atdsrvano
         ,c24astcod      like datkassunto.c24astcod
         ,lignum         like datmligacao.lignum
   end record

   define retorno        array[20] of record
          c24astcod      like datkassunto.c24astcod  
         ,c24astdes      like datkassunto.c24astdes
         ,qtd_utilizado  smallint
   end record


   define ws             record
          comando        char (400) 
         ,status         integer
         ,cont           smallint
         ,atdetpcod      like datmsrvacp.atdetpcod
   end record

   define arr_aux        smallint


   initialize  l_cty19g00.* ,retorno, ws.*  to  null

   let ws.status  = 0
   let arr_aux    = 1

   set isolation to dirty read


   #-----------------------
   # Cria Tabela Temporaria
   #-----------------------
   call cty19g00_temp_table(1) 
        returning ws.status


   #---------------------
   # Descricao do Assunto
   #---------------------
   let ws.comando  = "select c24astdes     "
                    ,"  from datkassunto   "
                    ," where c24astcod = ? "
   prepare pcty19g00003 from ws.comando
   declare ccty19g00003 cursor for pcty19g00003


   #--------------------------------------------
   # verifica se Atendimento ja consta na Tabela
   #--------------------------------------------
   let ws.comando = " select atdsrvnum "
                     ," from tmp_atendimento "
                    ," where atdsrvnum = ? "
                    ,"   and atdsrvano = ? "
                    ,"   and c24astcod = ? "
                    ,"   and lignum    = ? "
   prepare pcty19g00004 from ws.comando
   declare ccty19g00004 cursor for pcty19g00004


   #----------------------------------------
   # Inclui Atendimento na Tabela Temporaria 
   #----------------------------------------
   let ws.comando = " insert into tmp_atendimento "
                          ," (atdsrvnum "
                          ," ,atdsrvano "
                          ," ,c24astcod "
                          ," ,lignum ) "
                   ," values (?,?,?,?) "
   prepare pcty19g00005 from ws.comando


   #-------------------------
   # Ultima Estapa do Servico 
   #-------------------------
   let ws.comando  = "select a.atdetpcod  ",
                     "  from datmsrvacp a",
                     " where a.atdsrvnum = ? ",
                     "   and a.atdsrvano = ? ",
                     "   and a.atdsrvseq = (select max(b.atdsrvseq)",
                                           "  from datmsrvacp b    ",
                                           " where b.atdsrvnum = a.atdsrvnum ",
                                           "   and b.atdsrvano = a.atdsrvano )"
   prepare pcty19g00006 from ws.comando
   declare ccty19g00006 cursor for pcty19g00006


   ---> Limpa tabela temporaria
   delete from tmp_atendimento
    where c24astcod is not null

   #--------------------------------------
   # Busca Servicos Abertos para a Apolice
   #--------------------------------------
   declare pcty19g00001 cursor with hold for
      select b.atdsrvnum 
            ,b.atdsrvano 
            ,c.c24astcod 
            ,c.lignum 
        from datrservapol a 
            ,datmservico  b 
            ,datmligacao  c 
       where a.aplnumdig =  param.aplnumdig 
         and a.succod    =  param.succod 
         and a.ramcod    =  param.ramcod  
         and a.itmnumdig =  param.itmnumdig  
         and a.atdsrvnum >  0 
         and a.atdsrvano >= 0 
         and a.atdsrvnum =  b.atdsrvnum 
         and a.atdsrvano =  b.atdsrvano 
         and c.atdsrvnum =  b.atdsrvnum 
         and c.atdsrvano =  b.atdsrvano 
       order by 1,2 

   foreach pcty19g00001 into l_cty19g00.atdsrvnum
                            ,l_cty19g00.atdsrvano
                            ,l_cty19g00.c24astcod
                            ,l_cty19g00.lignum

      ---> Verifica etapa dos servicos
      open  ccty19g00006 using l_cty19g00.atdsrvnum
                              ,l_cty19g00.atdsrvano
      fetch ccty19g00006 into ws.atdetpcod

      ---> Considera todos os Servicos, menos os Cancelados
      if ws.atdetpcod > 4  then  
         initialize  l_cty19g00.*, ws.* to null 
         continue foreach
      end if
  
  
      ---> Verifica se Registro foi gravado na Temp
      open  ccty19g00004 using l_cty19g00.atdsrvnum
                              ,l_cty19g00.atdsrvano
                              ,l_cty19g00.c24astcod
                              ,l_cty19g00.lignum
      fetch ccty19g00004 

      if sqlca.sqlcode > 0 then

      ---> Grava Atendimento na Tabela Temporaria 
      execute pcty19g00005 using l_cty19g00.atdsrvnum
                                ,l_cty19g00.atdsrvano
                                ,l_cty19g00.c24astcod
                                ,l_cty19g00.lignum

      if sqlca.sqlcode <> 0 then
         error "Erro INSERT pcty19g00005/",sqlca.sqlcode,"/",sqlca.sqlerrd[2] sleep 5
         exit foreach
      end if
      end if

      initialize  l_cty19g00.*, ws.* to null 

   end foreach


   initialize  l_cty19g00.*, ws.* to null 

   if param.prpnumdig is not null and 
      param.prpnumdig <> 0        then

      #---------------------------------------
      # Busca Servicos Abertos para a Proposta
      #---------------------------------------
      declare pcty19g00002 cursor with hold for
         select b.atdsrvnum 
               ,b.atdsrvano 
               ,c.c24astcod 
               ,c.lignum 
           from datrligprp  a 
               ,datmservico b 
               ,datmligacao c 
          where a.prporg    = param.prporg 
            and a.prpnumdig = param.prpnumdig
            and a.lignum    = c.lignum 
            and c.atdsrvnum = b.atdsrvnum 
            and c.atdsrvano = b.atdsrvano 
          order by 1,2 


      foreach pcty19g00002 into l_cty19g00.atdsrvnum
                               ,l_cty19g00.atdsrvano
                               ,l_cty19g00.c24astcod
                               ,l_cty19g00.lignum
   
         ---> Verifica etapa dos servicos
         open  ccty19g00006 using l_cty19g00.atdsrvnum
                                 ,l_cty19g00.atdsrvano
         fetch ccty19g00006 into ws.atdetpcod
   
         ---> Considera todos os Servicos, menos os Cancelados
         if ws.atdetpcod > 4      then  
             continue foreach
         end if
   

         ---> Verifica se Registro foi gravado na Temp
         open  ccty19g00004 using l_cty19g00.atdsrvnum
                                 ,l_cty19g00.atdsrvano
                                 ,l_cty19g00.c24astcod
                                 ,l_cty19g00.lignum
         fetch ccty19g00004 

         if sqlca.sqlcode = 0 then
            continue foreach
         end if


         ---> Grava Atendimento na Tabela Temporaria 
         execute pcty19g00005 using l_cty19g00.atdsrvnum
                                   ,l_cty19g00.atdsrvano
                                   ,l_cty19g00.c24astcod
                                   ,l_cty19g00.lignum
   
         if sqlca.sqlcode <> 0 then
            error "Erro INSERT pcty19g00005/",sqlca.sqlcode,"/",sqlca.sqlerrd[2] sleep 5
            exit foreach
         end if

         initialize  l_cty19g00.*, ws.* to null 

      end foreach
   end if


   #---------------------------------------
   # Apura Total de Atendimento por Assunto
   #---------------------------------------
   declare pcty19g00007 cursor with hold for
      select count(*)  
            ,c24astcod 
        from tmp_atendimento 
       group by 2 
       order by 2 

   foreach pcty19g00007 into retorno[arr_aux].qtd_utilizado
                            ,retorno[arr_aux].c24astcod

      ---> Descricao do Assunto
      open  ccty19g00003 using retorno[arr_aux].c24astcod
      fetch ccty19g00003 into  retorno[arr_aux].c24astdes

      let arr_aux = arr_aux + 1

   end foreach

  
   #------------------------
   # Dropa Tabela Temporaria
   #------------------------
   call cty19g00_temp_table(2)
        returning ws.status
  

   return retorno[1].*
         ,retorno[2].*
         ,retorno[3].*
         ,retorno[4].*
         ,retorno[5].*
         ,retorno[6].*
         ,retorno[7].*
         ,retorno[8].*
         ,retorno[9].*
         ,retorno[10].*
         ,retorno[11].*
         ,retorno[12].*
         ,retorno[13].*
         ,retorno[14].*
         ,retorno[15].*
         ,retorno[16].*
         ,retorno[17].*
         ,retorno[18].*
         ,retorno[19].*
         ,retorno[20].*

end function


#----------------------------------------------------------------------------#
function cty19g00_temp_table(l_operacao)
#----------------------------------------------------------------------------#

  define l_operacao smallint, --->  1-CRIA TEMPORARIA  2-APAGA TEMPORARIA
         l_status   integer 

  let l_status = null

  if l_operacao = 1 then
     whenever error continue
     create temp table tmp_atendimento
      (atdsrvnum  decimal(10,0)
      ,atdsrvano  decimal(2,0)
      ,c24astcod  char(03)
      ,lignum     decimal(10,0)) with no log
     whenever error stop

     whenever error continue
     create index idx_atd on tmp_atendimento(atdsrvnum,atdsrvano,c24astcod,lignum)
     whenever error stop

     let l_status = sqlca.sqlcode
  else
     whenever error continue
     drop index idx_atd
     drop table tmp_atendimento
     whenever error stop

     let l_status = sqlca.sqlcode

  end if

  return l_status

end function
