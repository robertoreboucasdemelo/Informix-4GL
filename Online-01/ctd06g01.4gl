#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd06g01                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: CHAMADO                                                    #
#                  MODULO RESPONSA. PELO ACESSO A TABELA DATMLIGHIST          #
# ........................................................................... #
# DESENVOLVIMENTO: Priscila Staingel                                          #
# LIBERACAO......: 21/12/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

  define m_prep    smallint
  
#-------------------------#
function ctd06g01_prepare()
#-------------------------#
  define l_sql char(500)

  let l_sql = "insert into datmlighist ",
              " (lignum, c24txtseq, c24funmat, ",
              "  c24ligdsc, ligdat, lighorinc, ",
              "  c24usrtip, c24empcod ) ",
              " values ( ?, ?, ?, ?, ?, ?, ?, ? )"
  prepare pctd06g01001 from l_sql
  
  let l_sql = "select max(c24txtseq) ",
              "  from datmlighist ",
              "  where lignum = ? "
 prepare pctd06g01002 from l_sql
 declare cctd06g01002 cursor for pctd06g01002  
  
  let m_prep = true

end function

#-------------------------#
function ctd06g01_ins_datmlighist(param)
#-------------------------#
  define param record
      lignum    like datmlighist.lignum   ,
      c24funmat like datmlighist.c24funmat,
      c24ligdsc like datmlighist.c24ligdsc,
      ligdat    like datmlighist.ligdat   ,
      lighorinc like datmlighist.lighorinc,
      c24usrtip like datmlighist.c24usrtip,
      c24empcod like datmlighist.c24empcod 
  end record
             
  define l_c24txtseq like datmlighist.c24txtseq          
             
  define l_ret       smallint,
         l_mensagem  char(50)           
             
  if m_prep <> true then
     call ctd06g01_prepare()
  end if          
     
  #verificar se parametros foram passados corretamente           
  if param.lignum    is null or   #campo nao aceita nulo
     param.c24funmat is null or   #deve vir preenchido ou dará problema
     param.c24usrtip is null or   #  na visualização do histórico
     param.c24empcod is null then    
     let l_ret = 3
     let l_mensagem = "ERRO passagem de parametros - ctd06g01_ins_datmlighist" 
  else
     #buscar ultima sequencia da ligação   
     call ctd06g01_ult_seq_datmlighist(param.lignum)
          returning l_ret,
                    l_mensagem,
                    l_c24txtseq
     #se nao ocorreu erro ao buscar sequencia
     if l_ret <> 3 then
        if l_ret = 2 then
           let l_c24txtseq = 1
        else
           let l_c24txtseq =  l_c24txtseq + 1
        end if
        #inserir registro em datmlighist
        whenever error continue
        execute pctd06g01001 using param.lignum,
                                   l_c24txtseq,
                                   param.c24funmat,
                                   param.c24ligdsc,
                                   param.ligdat,   
                                   param.lighorinc,
                                   param.c24usrtip,
                                   param.c24empcod
        whenever error stop
        if sqlca.sqlcode <> 0 then
           let l_ret = 3
           let l_mensagem = "ERRO ", sqlca.sqlcode, " insert datmlighist"
        else
           let l_ret = 1
           let l_mensagem = null
        end if
     end if               
  end if        
  
  return l_ret,
         l_mensagem   
  
end function

#-------------------------#
function ctd06g01_ult_seq_datmlighist(param)
#-------------------------#
  define param record
      lignum like datmlighist.lignum
  end record
    
  define l_ret       smallint,
         l_mensagem  char(50),
         l_c24txtseq like datmlighist.c24txtseq   
    
  let l_ret = 0
  let l_mensagem = null
  let l_c24txtseq = 0  
    
  if m_prep <> true then
     call ctd06g01_prepare()
  end if      
    
  if param.lignum is null then
     let l_ret = 3
     let l_mensagem = "ERRO passagem de parametros - ctd06g01_ult_seq_datmlighist"      
  else
     open cctd06g01002 using param.lignum
     fetch cctd06g01002 into l_c24txtseq
     if sqlca.sqlcode <> 0 then  #erro
        if sqlca.sqlcode = 100 then   #not found
           let l_ret = 2
           let l_mensagem = "Notfound em datmlighist"     
        else
           let l_ret = 3
           let l_mensagem = "ERRO SQL ", sqlca.sqlcode ," ctd06g01_ult_seq_datmlighist"                        
        end if
     else   
        let l_ret = 1
        let l_mensagem = null
     end if
  end if  
  
  #se nao ocorreu problema na busca, mas nao encontrou nenhum registro
  # isso pode acontecer pq select é com max
  if l_c24txtseq is null and l_ret = 1 then 
     let l_ret = 2                                                         
     let l_mensagem = "Nao existe registro na tabela de historico ligacao" 
  end if
    
  return l_ret,
         l_mensagem,
         l_c24txtseq  
 
end function
