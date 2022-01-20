#------------------------------------------------------------------------------#   
# Porto Seguro Cia Seguros Gerais                                              #   
#..............................................................................#   
# Sistema........: Auto e RE - Itau Seguros                                    #   
# Modulo.........: cts66m01                                                    #   
# Objetivo.......: Lista de Serviços Originais do Itau - Residencia            #   
# Analista Resp. : Ligia - Fornax                                              #   
# PSI            :                                                             #   
#..............................................................................#   
# Desenvolvimento: Hamilton - Fornax                                           #   
# Liberacao      : 31/07/2012                                                  #   
#------------------------------------------------------------------------------#
database porto                                                                   
                                                                                 
globals "/homedsa/projetos/geral/globals/glct.4gl"                              
                                                                                 
define m_prepare  smallint    

define mr_retorno array[500] of record               
       c24astcod  like  datmligacao.c24astcod ,
       atdsrvnum  like  datmservico.atdsrvnum ,
       atdsrvano  like  datmservico.atdsrvano ,
       atddat     like  datmservico.atddat    ,
       atdhor     like  datmservico.atdhor    ,
       c24solnom  like  datmservico.c24solnom ,
       atdsrvorg  like  datmservico.atdsrvorg 
end record                                           
#------------------------------------------------------------------------------#
function cts66m01_prepare()                                                      

   define l_sql char(10000) 
   
   let l_sql = "select b.c24astcod,       " ,
               "       a.atdsrvnum,       " ,
               "       a.atdsrvano,       " ,
               "       a.atddat,          " ,
               "       a.atdhor,          " ,   
               "       a.c24solnom,        " ,
               "       a.atdsrvorg        " , 
               " from datmservico a,      " ,         
               "      datmligacao b,      " ,         
               "      datritaasiplnast c, " ,         
               "      datrligitaaplitm d  " ,         
               " where a.atdsrvnum = b.atdsrvnum " ,  
               " and a.atdsrvano = b.atdsrvano   " ,  
               " and b.c24astcod = c.astcod      " ,  
               " and b.lignum    = d.lignum      " ,  
               " and a.atddat between ? and ?    " ,  
               " and c.itaasiplncod = ?          " ,  
               " and c.itaasiplntipcod in (5,7)  " ,                                           " and d.itaciacod = ?             " ,  
               " and d.itaramcod = ?             " ,  
               " and d.itaaplnum = ?             " ,  
               " and d.itaaplitmnum = ?          "    
   prepare p_cts66m01_001  from l_sql                 
   declare c_cts66m01_001  cursor for p_cts66m01_001  

end function   
#------------------------------------------------------------------------------#
function cts66m01_rec_servico_original(lr_param)                                         
                                                                                 
   define lr_param record                                                           
          itaasiplncod     like datkitaasipln.itaasiplncod     ,   
          itaaplvigincdat  like datmitaapl.itaaplvigincdat     ,   
          itaaplvigfnldat  like datmitaapl.itaaplvigfnldat     , 
          itaciacod        like datmitaapl.itaciacod           ,   
          itaramcod        like datmitaapl.itaramcod           ,  
          itaaplnum        like datmitaapl.itaaplnum           ,   
          itaaplitmnum     like datmitaaplitm.itaaplitmnum                                       
   end record                                                                       
                                                                                    
   define l_index integer                                                           
                                                     
   initialize  mr_retorno to  null                                    
                                                        
   if m_prepare is null or                                                          
      m_prepare <> true then                                                        
      call cts66m01_prepare()                                                       
   end if                                                                           
                                                                                 
   let l_index = 1                                                               
                                                                                 
   open c_cts66m01_001 using lr_param.itaaplvigincdat , 
                             lr_param.itaaplvigfnldat ,
                             lr_param.itaasiplncod    , 
                             lr_param.itaciacod       ,
                             lr_param.itaramcod       ,
                             lr_param.itaaplnum       ,
                             lr_param.itaaplitmnum        
   
   foreach c_cts66m01_001 into mr_retorno[l_index].c24astcod  ,                
                               mr_retorno[l_index].atdsrvnum  ,                
                               mr_retorno[l_index].atdsrvano  ,                
                               mr_retorno[l_index].atddat     ,
                               mr_retorno[l_index].atdhor     ,
                               mr_retorno[l_index].c24solnom  ,
                               mr_retorno[l_index].atdsrvorg  
   
      let l_index = l_index + 1                                                     
                                                                                 
   end foreach                                                                   
                                                                                 
   return l_index                                                                
                                                                                 
end function                                
#------------------------------------------------------------------------------#
function cts66m01(lr_param)      

   define lr_param record                                                                                        
          itaasiplncod     like datkitaasipln.itaasiplncod     ,                        
          itaaplvigincdat  like datmitaapl.itaaplvigincdat     ,                        
          itaaplvigfnldat  like datmitaapl.itaaplvigfnldat     ,                        
          itaciacod        like datmitaapl.itaciacod           ,                        
          itaramcod        like datmitaapl.itaramcod           ,                        
          itaaplnum        like datmitaapl.itaaplnum           ,                        
          itaaplitmnum     like datmitaaplitm.itaaplitmnum                              
   end record                                                                       
   
   
   define lr_retorno  record
          atdsrvorg         char (02)  ,
          atdsrvnum         char (07)  ,
          atdsrvano         char (02)  ,
          acesso            smallint
   end record
   
   define a_cts66m01    array[500] of record
          assunto           char(3)                    ,
          servico           char (13)                  ,
          atddat            like datmservico.atddat    ,
          atdhor            like  datmservico.atdhor   ,   
          c24solnom         like datmservico.c24solnom     
   end record
    
   define l_index     integer  ,
          l_qtde      smallint ,
          arr_aux     integer  ,
          l_confirma  char(1)  ,
          l_resultado integer  ,
          l_mensagem  char(50)
      
    
   initialize lr_retorno.* to null  
   let l_index           = 0 
   let l_qtde            = 0 
   let arr_aux           = 0
   
   let l_confirma        = null
   let lr_retorno.acesso = 0
   let l_resultado       = null
   let l_mensagem        = null
   
   # inicializando array tela servicos
     for l_index  =  1  to  500
         initialize  a_cts66m01[l_index].* to  null       
     end for 
   
     call cts66m01_rec_servico_original(lr_param.itaasiplncod   ,
                                        lr_param.itaaplvigincdat,
                                        lr_param.itaaplvigfnldat,
                                        lr_param.itaciacod      ,
                                        lr_param.itaramcod      ,
                                        lr_param.itaaplnum      ,
                                        lr_param.itaaplitmnum)
    returning l_qtde
   
   
   let l_qtde = l_qtde - 1                                         
   
   if l_qtde = 0 then 
      return lr_retorno.*
   end if    
      
    for l_index = 1 to l_qtde 
       
       let a_cts66m01[l_index].assunto = mr_retorno[l_index].c24astcod
       let a_cts66m01[l_index].servico = mr_retorno[l_index].atdsrvorg using "&&",
                                         "/", mr_retorno[l_index].atdsrvnum using "&&&&&&&",
                                         "-", mr_retorno[l_index].atdsrvano using "&&"
       let a_cts66m01[l_index].atdhor     = mr_retorno[l_index].atdhor
       let a_cts66m01[l_index].atddat     = mr_retorno[l_index].atddat
       let a_cts66m01[l_index].c24solnom  = mr_retorno[l_index].c24solnom         
     
    end for  
    
    let arr_aux = l_index                                
    
    if arr_aux  =  0   then
       error " Nao existe nenhuma solicitacao de servico para esta apolice!" sleep 2
    else
       open window w_cts66m01 at 11,10  with form  "cts11m13"
             attribute(form line first, border)
   
       message " (F17)Abandona, (F8)Seleciona"
   
       call set_count(arr_aux)
   
       display array a_cts66m01 to s_cts66m01.*
          on key(interrupt)
          
	  {
             initialize lr_retorno.*  to null  
             
             call cty22g00_conta_corrente_itau(g_documento.c24astcod         ,     
                                               g_doc_itau[1].itaasiplncod    ,     
                                               g_doc_itau[1].itaaplvigincdat ,     
                                               g_doc_itau[1].itaaplvigfnldat ,     
                                               lr_param.itaciacod            ,     
                                               lr_param.itaramcod            ,     
                                               lr_param.itaaplnum            ,     
                                               lr_param.itaaplitmnum         ,
                                               2                             )  
             returning l_resultado,                                                
                       l_mensagem                                                  
                                                                                   
                                                                                   
             if not l_resultado then                                               
                error l_mensagem sleep 2                                           
                let lr_retorno.acesso = 1                                          
             end if                                                                
	     }
                 
             exit display
   
          on key(F8)
             let arr_aux = arr_curr()
             let lr_retorno.atdsrvorg = a_cts66m01[arr_aux].servico[01,02]
             let lr_retorno.atdsrvnum = a_cts66m01[arr_aux].servico[04,10]
             let lr_retorno.atdsrvano = a_cts66m01[arr_aux].servico[12,13]
                    
             if a_cts66m01[arr_aux].assunto = g_documento.c24astcod then 
                call cts08g01("A","S",
                              "VOCE ESCOLHEU O UM SERVICO COM A MESMA ",
                              "ORIGEM DO LAUDO DE ABERTURA !" ,
                              "CONFIRMA ? ",
                              "")
                returning l_confirma              
                
                if l_confirma = "S" then 
                   exit display
                end if 
             
             else 
                exit display 
             end if                                             
       end display
   
       close window  w_cts66m01
    end if
   
    let int_flag = false
    return lr_retorno.*  

end function 
#------------------------------------------------------------------------------#
