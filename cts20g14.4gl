#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24h                                                #
# Modulo        : cts20g14                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : PSI187550                                                  #
#                 Obter Motivo de concessao atraves da ligacao.              #
#............................................................................#
# Desenvolvimento: Marcio, META                                              #
# Liberacao      : 10/09/2004                                                #
#............................................................................#
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 20/06/2007 Ligia Mattge      PSI 210030 Carregar o g_hist c/o historico    #
#............................................................................#
#                                                                            #
# 06/03/2009 Carla Rampazzo    PSI 236560 Nova Funcao para Buscar Motivo de  #
#                                         Recusa na Indicacao do Posto CAPS  #
#----------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint

#--------------------------#
function cts20g14_prepare()
#--------------------------#
 define l_sql char(200)
 
 let l_sql = " select rcuccsmtvcod, c24astcod "
            ,"   from datrligrcuccsmtv "
            ,"  where lignum = ? "
	    ,"  order by 1 asc "
 prepare pcts20g14001 from l_sql
 declare ccts20g14001 cursor for pcts20g14001
 
 let l_sql = " select rcuccsmtvdes "
            ,"   from datkrcuccsmtv "
            ,"  where rcuccsmtvcod = ? "
            ,"    and c24astcod    = ? "
 prepare pcts20g14002 from l_sql
 declare ccts20g14002 cursor for pcts20g14002

 let l_sql = " select hstdsc, hstseq "
            ,"   from datmhstligrcuccsmt "
            ,"  where lignum = ? "
            ,"  order by hstseq "
 prepare pcts20g14003 from l_sql
 declare ccts20g14003 cursor for pcts20g14003

 let l_sql = "insert into datmhstligrcuccsmt ",
             " (lignum, hstseq, hstdsc) ",
             " values ( ?, ?, ?)"
 prepare pcts20g14004 from l_sql
 
 let l_sql = "select max(hstseq) ",
             "  from datmhstligrcuccsmt ",
             "  where lignum = ? "
 
 prepare pcts20g14005 from l_sql
 declare ccts20g14005 cursor for pcts20g14005

 let l_sql = " select rcuccsmtvcod, c24astcod "
            ,"   from datrligrcuccsmtv "
            ,"  where lignum = ? "
	    ,"  order by 1 desc "
 prepare pcts20g14006 from l_sql
 declare ccts20g14006 cursor for pcts20g14006 
 
 let l_sql = " select rcuccsmtvsubcod  "   
            ,"   from datrligrcuccsmtv "          
            ,"  where lignum = ?       "                
            ,"  and   rcuccsmtvcod = ? "                        
 prepare pcts20g14007 from l_sql                  
 declare ccts20g14007 cursor for pcts20g14007   
 
 let l_sql = " select rcuccsmtvsubdes      "           
            ,"   from datkrcuccsmtvsub     "          
            ,"  where rcuccsmtvcod   = ?   " 
            ,"  and rcuccsmtvsubcod  = ?   "  
            ,"  and c24astcod        = ?   "          
 prepare pcts20g14008 from l_sql                 
 declare ccts20g14008 cursor for pcts20g14008  
 
  
 let m_prep_sql = true

end function

#-------------------------------------#
function cts20g14_motivo_con(lr_param)
#-------------------------------------#
 
 define lr_param       record
        lignum         like datrligrcuccsmtv.lignum
 end record
 
 define lr_retorno     record
        resultado      smallint,
        mensagem       char(80),
        rcuccsmtvcod   like datrligrcuccsmtv.rcuccsmtvcod,
        c24astcod      like datrligrcuccsmtv.c24astcod
 end record

 define  l_msg      char(80)
 
 initialize lr_retorno.* to null
 
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts20g14_prepare()
 end if
 
 if lr_param.lignum is not null then
    
    open ccts20g14001 using lr_param.lignum
    whenever error continue
    fetch ccts20g14001 into lr_retorno.rcuccsmtvcod,
                            lr_retorno.c24astcod

    whenever error stop
    
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Nao existe motivo cadastrado para esta ligacao'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datrligrcuccsmtv'
          let l_msg = ' Erro  SELECT ccts20g14001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(l_msg)
          let l_msg = ' cts20g14_motivo_con() ',lr_param.lignum
          call errorlog(l_msg)
       end if
    else
       let lr_retorno.resultado = 1
    end if
 
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if
 
 return lr_retorno.*

end function

#-------------------------------------#
function cts20g14_motivo_con2(lr_param)
#-------------------------------------#
 
 define lr_param       record
        lignum         like datrligrcuccsmtv.lignum
 end record
 
 define lr_retorno     record
        resultado      smallint,
        mensagem       char(80),
        rcuccsmtvcod   like datrligrcuccsmtv.rcuccsmtvcod,
        c24astcod      like datrligrcuccsmtv.c24astcod
 end record

 define  l_msg      char(80)
 initialize lr_retorno.* to null
 
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts20g14_prepare()
 end if
 
 if lr_param.lignum is not null then
    
    open ccts20g14006 using lr_param.lignum
    whenever error continue
    fetch ccts20g14006 into lr_retorno.rcuccsmtvcod,
                            lr_retorno.c24astcod

    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Nao existe motivo cadastrado para esta ligacao'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datrligrcuccsmtv'
          let l_msg = ' Erro  SELECT ccts20g14006 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(l_msg)
          let l_msg = ' cts20g14_motivo_con() ',lr_param.lignum
          call errorlog(l_msg)
       end if
    else
       let lr_retorno.resultado = 1
    end if
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if
 
 return lr_retorno.*

end function

#-----------------------------------------#
function cts20g14_desc_motivo(lr_param)
#-----------------------------------------#
 define lr_param       record
        rcuccsmtvcod   like datkrcuccsmtv.rcuccsmtvcod,
        c24astcod      like datkrcuccsmtv.c24astcod
 end record
 
 define lr_retorno     record
        resultado      smallint,
        mensagem       char(80),
        rcuccsmtvdes   like datkrcuccsmtv.rcuccsmtvdes
 end record

 define  l_msg      char(80)
 
 initialize lr_retorno.* to null
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts20g14_prepare()
 end if
 
 if lr_param.rcuccsmtvcod is not null and
    lr_param.c24astcod    is not null then
    
    open ccts20g14002 using lr_param.*
    whenever error continue
    fetch ccts20g14002 into lr_retorno.rcuccsmtvdes
    whenever error stop
    
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Motivo Invalido'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datkrcuccsmtv'
          let l_msg = ' Erro SELECT ccts20g14002', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(l_msg)
          let l_msg = ' cts20g14_desc_motivo()',lr_param.rcuccsmtvcod,'/',lr_param.c24astcod
          call errorlog(l_msg)
       end if
    else
       let lr_retorno.resultado = 1
    end if
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if
 
 return lr_retorno.*

end function

#-----------------------------------------#
function cts20g14_historico(lr_param)
#-----------------------------------------#

 define lr_param       record
        lignum         like datrligrcuccsmtv.lignum
 end record
 
 define lr_retorno     record
        resultado      smallint,
        mensagem       char(80)
 end record

 define  l_indice smallint
 
 initialize lr_retorno.* to null
 
 initialize g_hist to null
 
 let l_indice = 1
 
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts20g14_prepare()
 end if
 
 if lr_param.lignum is not null then
    open ccts20g14003 using lr_param.lignum
    whenever error continue

    foreach ccts20g14003 into g_hist[l_indice].historico
            let l_indice = l_indice + 1
    end foreach

    let l_indice = l_indice - 1

    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Nao existe historico para esta ligacao'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem =
                         'Erro em cts20g14_historico: ',lr_param.lignum
       end if
    else
       let lr_retorno.resultado = 1
    end if
 else
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem  = 'Parametros Nulos'
 end if
 
 return lr_retorno.*, l_indice

end function

#---------------------------------------#
function cts20g14_grava_hist(param)
#---------------------------------------#
  define param record
         lignum    like datmhstligrcuccsmt.lignum,
         hstdsc    like datmhstligrcuccsmt.hstdsc
  end record
  
  define l_hstseq like datmhstligrcuccsmt.hstseq
  
  define l_ret       smallint,
         l_mensagem  char(50)
  
  if  m_prep_sql <> true then
      call cts20g14_prepare()
  end if

  #verificar se parametros foram passados corretamente
 
  if  param.lignum is null or   #campo nao aceita nulo
      param.hstdsc is null then   #deve vir preenchido ou dará problema
      let l_ret = 3
      let l_mensagem = "ERRO passagem de parametros - cts20g14_insere"
  else
      #buscar ultima sequencia da ligação
      call cts20g14_ult_seq(param.lignum)
           returning l_ret,
                     l_mensagem,
                     l_hstseq
      #se nao ocorreu erro ao buscar sequencia
      if  l_ret <> 3 then
          if  l_ret = 2 then
              let l_hstseq = 1
          else
              let l_hstseq =  l_hstseq + 1
          end if

          #inserir registro em datmhstligrcuccsmt
          whenever error continue
          execute pcts20g14004 using param.lignum,
                                     l_hstseq,
                                     param.hstdsc
          whenever error stop

          if sqlca.sqlcode <> 0 then
             let l_ret = 3
             let l_mensagem = "ERRO ", sqlca.sqlcode, " em datmhstligrcuccsmt"
          else
             let l_ret = 1
             let l_mensagem = null
          end if
      end if
  end if
 
  return l_ret,
         l_mensagem

end function

#------------------------------------------#
function cts20g14_ult_seq(param)
#------------------------------------------#

  define param record
         lignum    like datmhstligrcuccsmt.lignum
  end record
  
  define l_ret       smallint,
         l_mensagem  char(50),
         l_hstseq like datmhstligrcuccsmt.hstseq
  
  let l_ret = 0
  let l_mensagem = null
  let l_hstseq = 0
  
  if m_prep_sql <> true then
     call cts20g14_prepare()
  end if
  
  if  param.lignum is null then
      let l_ret = 3
      let l_mensagem = "ERRO de parametros - cts20g14_ult_seq"
  else
      open ccts20g14005 using param.lignum
      fetch ccts20g14005 into l_hstseq
      if sqlca.sqlcode <> 0 then  #erro
         if sqlca.sqlcode = 100 then   #not found
            let l_ret = 2
            let l_mensagem = "Notfound em datmhstligrcuccsmt"
         else
            let l_ret = 3
            let l_mensagem = "ERRO SQL ", sqlca.sqlcode ," cts20g14_ult_seq"
         end if
      else
         let l_ret = 1
         let l_mensagem = null
      end if
  end if
  
  #se nao ocorreu problema na busca, mas nao encontrou nenhum registro
  # isso pode acontecer pq select é com max
  if l_hstseq is null and l_ret = 1 then
     let l_ret = 2
     let l_mensagem = "Nao existe registro na tabela de historico servico"
  end if
  
  return l_ret,
         l_mensagem,
         l_hstseq

end function

#----------------------------------------#                                                     
function cts20g14_submotivo_con(lr_param)                                                      
#----------------------------------------#                                                     
                                                                                            
 define lr_param       record                                                               
        lignum         like datrligrcuccsmtv.lignum        ,
        rcuccsmtvcod   like datrligrcuccsmtv.rcuccsmtvcod                                       
 end record                                                                                 
                                                                                            
 define lr_retorno  record                                                               
        resultado          smallint                             ,                                                            
        mensagem           char(80)                             ,                                                            
        rcuccsmtvsubcod    like datrligrcuccsmtv.rcuccsmtvsubcod                             
 end record                                                                                 
                                                                                            
 define  l_msg      char(80)                                                                
                                                                                            
 initialize lr_retorno.* to null                                                            
                                                                                            
 if m_prep_sql is null or                                                                   
    m_prep_sql <> true then                                                                 
    call cts20g14_prepare()                                                                 
 end if                                                                                     
                                                                                            
 if lr_param.lignum is not null then                                                        
                                                                                            
    open ccts20g14007 using lr_param.lignum       ,
                            lr_param.rcuccsmtvcod                                                  
    
    whenever error continue                                                                 
    fetch ccts20g14007 into lr_retorno.rcuccsmtvsubcod                                                                     
                                                                                            
    whenever error stop                                                                     
                                                                                            
    if sqlca.sqlcode <> 0 then                                                              
       if sqlca.sqlcode = notfound then                                                     
          let lr_retorno.resultado = 2                                                      
          let lr_retorno.mensagem  = 'Nao existe submotivo cadastrado para esta ligacao'       
       else                                                                                 
          let lr_retorno.resultado = 3                                                      
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datrligrcuccsmtv'         
          let l_msg = ' Erro  SELECT ccts20g14007 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]     
          call errorlog(l_msg)                                                              
          let l_msg = ' cts20g14_submotivo_con() ',lr_param.lignum                             
          call errorlog(l_msg)                                                              
       end if                                                                               
    else                                                                                    
       let lr_retorno.resultado = 1                                                         
    end if                                                                                  
                                                                                            
 else                                                                                       
    let lr_retorno.resultado = 3                                                            
    let lr_retorno.mensagem  = 'Parametros Nulos'                                           
 end if                                                                                     
                                                                                            
 return lr_retorno.*                                                                        
                                                                                            
end function

#-----------------------------------------#                                                                                                                                    
function cts20g14_desc_submotivo(lr_param)                                                        
#-----------------------------------------#                                                    
 
 define lr_param       record     
       c24astcod       like datkrcuccsmtvsub.c24astcod       ,
       rcuccsmtvcod    like datkrcuccsmtvsub.rcuccsmtvcod    ,                                                              
       rcuccsmtvsubcod like datkrcuccsmtvsub.rcuccsmtvsubcod                                                                                 
 end record                                                                                    
                                                                                               
 define lr_retorno     record                                                                  
        resultado       smallint,                                                               
        mensagem        char(80),                                                               
        rcuccsmtvsubdes like datkrcuccsmtvsub.rcuccsmtvsubdes                                      
 end record                                                                                    
                                                                                               
 define  l_msg      char(80)                                                                   
                                                                                               
 initialize lr_retorno.* to null                                                               
 
 if m_prep_sql is null or                                                                      
    m_prep_sql <> true then                                                                    
    call cts20g14_prepare()                                                                    
 end if                                                                                        
                                                                                               
 if lr_param.rcuccsmtvsubcod is not null then                                                                                                       
                                                                                               
    open ccts20g14008 using  lr_param.rcuccsmtvcod    ,
                             lr_param.rcuccsmtvsubcod ,
                             lr_param.c24astcod                                                      
    
    whenever error continue                                                                    
    fetch ccts20g14008 into lr_retorno.rcuccsmtvsubdes                                           
    whenever error stop                                                                        
                                                                                               
    if sqlca.sqlcode <> 0 then                                                                 
       if sqlca.sqlcode = notfound then                                                        
          let lr_retorno.resultado = 2                                                         
          let lr_retorno.mensagem  = 'Motivo Invalido'                                         
       else                                                                                    
          let lr_retorno.resultado = 3                                                         
          let lr_retorno.mensagem  = 'Erro ', sqlca.sqlcode, ' em datkrcuccsmtvsub'               
          let l_msg = ' Erro SELECT ccts20g14008', sqlca.sqlcode,'/',sqlca.sqlerrd[2]          
          call errorlog(l_msg)                                                                 
          let l_msg = ' cts20g14_desc_submotivo()',lr_param.rcuccsmtvsubcod
          call errorlog(l_msg)                                                                 
       end if                                                                                  
    else                                                                                       
       let lr_retorno.resultado = 1                                                            
    end if                                                                                     
 else                                                                                          
    let lr_retorno.resultado = 3                                                               
    let lr_retorno.mensagem  = 'Parametros Nulos'                                              
 end if                                                                                        
                                                                                               
 return lr_retorno.*                                                                           
                                                                                               
end function                                                                                   