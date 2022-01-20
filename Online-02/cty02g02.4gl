#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty02g02.4gl                                               #
# Analista Resp : Roberto Melo                                               #
# PSI           : 223689                                                     #
#                 Chamar os metodos oaaca152,oaaca151,oaacc220,oaaca150.     #
#............................................................................#
# Desenvolvimento: Meta, Amilton                                             #
# Liberacao      : 20/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 17/12/2009 Ricardo, Meta     PSI 244597 Inclusão rotina da nova tela de    #
#                                         parâmetros/condições da Aceitação. #
#----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


function cty02g02_prepare()  
 
 define l_sql char(500)
 
 let l_sql = " select grlinf ",
             "   from datkgeral ",
             "  where grlchv = ? "

 prepare p_cty02g02001 from l_sql
 declare c_cty02g02001 cursor for p_cty02g02001
 

end function

#-----------------------------------------#
function cty02g02_oaaca152(lr_param)
#-----------------------------------------#
  
  
  define lr_param        record
         tipacao         char(01),
         aacdptatdcod    like aacmatd.aacdptatdcod,
         aacatdnum       like aacmatd.aacatdnum,
         aacatdano       like aacmatd.aacatdano,
         aacatdasscod    like aacmatd.aacatdasscod
  end record
    
  define l_msg   char(100)
  define l_status   smallint
 
  let l_msg = null  
  let l_status = null  
    
   call cta00m19_chama_prog("oaacm200",
                            "oaaca152",    
                            " ",
                            lr_param.tipacao,
                            lr_param.aacdptatdcod,
                            lr_param.aacatdnum,
                            lr_param.aacatdano,
                            lr_param.aacatdasscod,
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ")
               returning l_status       
       if l_status <> 0 then          
         let l_msg = "Sistema indisponivel no momento !"
             return l_msg                                    
       end if

  return l_msg

end function

#-----------------------------------------#   
function cty02g02_oaaca151(lr_param)
#-----------------------------------------#   

 define lr_param       record
        aacdptatdcod   like aacmatd.aacdptatdcod,
        aacatdnum      like aacmatd.aacatdnum,
        aacatdano      like aacmatd.aacatdano,
        aacatdasscod   like aacmatd.aacatdasscod
 end record
 
 define l_msg   char(100)
 define l_status   smallint
 
  let l_msg = null  
  let l_status = null  

   call cta00m19_chama_prog("oaacm200",
                            "oaaca151",    
                            " ",
                            " ",
                            lr_param.aacdptatdcod,
                            lr_param.aacatdnum,
                            lr_param.aacatdano,
                            lr_param.aacatdasscod,
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ")
               returning l_status       
       if l_status <> 0 then          
         let l_msg = "Sistema indisponivel no momento !"
             return l_msg                                    
       end if

  return l_msg

end function

#-----------------------------------------#   
function cty02g02_oaacc220(lr_param)
#-----------------------------------------#   

  define lr_param record         
         aacdptatdcod like aacmatd.aacdptatdcod,         
         aacatdnum    like aacmatd.aacatdnum,                  
         aacatdano    like aacmatd.aacatdano,         
         tipcns       char(01),
         prporgpcp    LIKE apametd.prporgpcp,
         prpnumpcp    LIKE apametd.prpnumpcp
  end record
  
  define l_msg   char(100)
  define l_status   smallint
  
  let l_msg = null  
  let l_status = null  
      
   call cta00m19_chama_prog("oaacm200",
                            "oaacc220",    
                            " ",
                            " ",
                            lr_param.aacdptatdcod,
                            lr_param.aacatdnum,
                            lr_param.aacatdano,
                            " ",
                            lr_param.tipcns,
                            " ",
                            lr_param.prporgpcp,  #PSI 244597
                            lr_param.prpnumpcp,
                            " ",
                            " ")
               returning l_status       
       if l_status <> 0 then          
         let l_msg = "Sistema indisponivel no momento !"
             return l_msg                                    
       end if

  return l_msg

end function 

#-----------------------------------------#   
function cty02g02_oaaca150(lr_param)
#-----------------------------------------#   

   define lr_param       record
          aacdptatdcod     like aackdptatd.aacdptatdcod,
          aacatdano        like aackdptatd.aacatdano   ,
          aacatdnum        like aackdptatd.aacatdnum,
          saida            smallint,
          prporgpcp        like apametd.prporgpcp, 
          prpnumpcp        like apametd.prpnumpcp            
   end record
   
   define l_retsitcod  like aacmatd.aacatdsitcod   
   
   define l_hora1     datetime hour to second,
          l_data      date,
          w_ct24      char(04),
          w_grlchv    like datkgeral.grlchv,       
          w_grlinf    like datkgeral.grlinf,
          w_empcod    char(02),
          w_funmat    char(06),
          l_msg       char(100),
          l_status    smallint, 
          m_prep_sql  smallint
          
   define lr_retorno  record
          resultado   smallint
         ,mensagem    char(60)         
   end record
   
   define l_grlchv   like datkgeral.grlchv,               
          l_grlinf   like datkgeral.grlinf
          
    
  let l_hora1     = null
  let l_data      = null
  let w_ct24      = null
  let w_grlchv    = null
  let w_grlinf    = null
  let w_empcod    = null
  let w_funmat    = null
  let l_msg       = null   
  let l_grlinf    = null    
  let l_retsitcod = null
   
   call cts40g03_data_hora_banco(1)
       returning l_data, l_hora1
    let w_empcod = g_issk.empcod
    let w_funmat = g_issk.funmat using "&&&&&&"
    let w_grlchv[1,6]  = w_funmat
    let w_grlchv[7,14] = l_hora1
    let w_ct24   = "ct24h"    
    initialize lr_retorno to null
    
     ##-- Selecionar datkgeral --##
     call cta12m00_seleciona_datkgeral(w_grlchv)
         returning lr_retorno.resultado
                  ,lr_retorno.mensagem
                  ,l_grlinf
        if lr_retorno.resultado = 1 then
         ##-- Remove de datkgeral --##
           call cta12m00_remove_datkgeral(w_grlchv)
                returning lr_retorno.resultado
                         ,lr_retorno.mensagem
                if lr_retorno.resultado <> 1 then           
                   let l_msg = lr_retorno.mensagem
                   return l_retsitcod,l_msg
                else
                  ##-- inclui na datkgeral 
                  call cta12m00_inclui_datkgeral(w_grlchv,
                                                 w_ct24,
                                                 l_data,
                                                 l_hora1,
                                                 w_empcod,
                                                 w_funmat)
                  returning lr_retorno.resultado
                           ,lr_retorno.mensagem
                  if lr_retorno.resultado <> 1 then
                     let l_msg = lr_retorno.mensagem                     
                     return l_retsitcod,l_msg
                  end if                  
           end if
        else    
           ##-- inclui na datkgeral
         call cta12m00_inclui_datkgeral(w_grlchv,
                                        w_ct24,
                                        l_data,
                                        l_hora1,
                                        w_empcod,
                                        w_funmat)
              returning lr_retorno.resultado
                       ,lr_retorno.mensagem
              if lr_retorno.resultado <> 1 then         
                    let l_msg = lr_retorno.mensagem                    
                    return l_retsitcod,l_msg
              end if                           
        end if                        
        call cta00m19_chama_prog("oaacm200",
                                  "oaaca150",
                                  w_grlchv,
                                  " ", 
                                  lr_param.aacdptatdcod,
                                  lr_param.aacatdnum,
                                  lr_param.aacatdano,
                                  " ",
                                  " ",
                                  lr_param.saida,
                                  lr_param.prporgpcp,
                                  lr_param.prpnumpcp,
                                  " ",
                                  " ")
                returning l_status       
        if l_status = 0 then          
           if m_prep_sql <> true or
              m_prep_sql is null then
              call cty02g02_prepare()
           end if          
           open c_cty02g02001 using w_grlchv
           whenever error continue
            fetch c_cty02g02001 into l_grlinf
           whenever error stop
           if sqlca.sqlcode = 0 then            
             let  l_retsitcod    = l_grlinf[7,9]            
             ## -- remove da datkgeral
             call cta12m00_remove_datkgeral(w_grlchv)
                  returning lr_retorno.resultado
                           ,lr_retorno.mensagem
                  if lr_retorno.resultado = 1 then
                     let l_msg = lr_retorno.mensagem                    
                     return l_retsitcod,l_msg                      
                  else
                     let l_msg = " Problema ao deletar na tabela datkgeral", sqlca.sqlcode,"|",sqlca.sqlerrd[2]                                                   
                     return l_retsitcod,l_msg                                                                     
                  end if
           else
             if sqlca.sqlcode = notfound  then                                                                        
               let l_msg = " Nenhum registro selecionado.", sqlca.sqlcode,"|",sqlca.sqlerrd[2]              
               return l_retsitcod,l_msg
             else
               let l_msg = " Problema SELECT na tabela datkgeral", sqlca.sqlcode,"|",sqlca.sqlerrd[2]                                                   
               return l_retsitcod,l_msg
             end if
           end if
          close c_cty02g02001
        else                  
          let l_msg = "Sistema indisponivel no momento !"
              return l_retsitcod,l_msg
        end if   

   return l_retsitcod,l_msg        
        
end function

#------------------------------------------------#   
function cty02g02_oaacc190(w_succod,w_aplnumdig)
#------------------------------------------------#     

  define w_succod    like abamdoc.succod
  define w_aplnumdig like abamdoc.aplnumdig
  
  
  define l_msg   char(100)
  define l_status   smallint
 
  let l_msg = null  
  let l_status = null  
    
   call cta00m19_chama_prog("oaacm200",
                            "oaacc190",    
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ")
               returning l_status       
       if l_status <> 0 then                   
         let l_msg = "Sistema indisponivel no momento !"
             return l_msg                                    
       end if

  return l_msg

end function 

#-----------------------------------------#   
function cty02g02_oaaca154()
#-----------------------------------------#   

  define l_msg   char(100)
  define l_status   smallint
 
  let l_msg = null  
  let l_status = null  
    
   call cta00m19_chama_prog("oaacm200",
                            "oaaca154",    
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ",
                            " ")
               returning l_status       
       if l_status <> 0 then          
         let l_msg = "Sistema indisponivel no momento !"
             return l_msg                                    
       end if

  return l_msg

end function 

#-----------------------------------------#   
function cty02g02_gpgtaler(lr_param)
#-----------------------------------------#   

define lr_param record
  corsus like dacrligsus.corsus
end record

define l_msg   char(100)    
define l_status   smallint  
                            
let l_msg = null            
let l_status = null

  call cta00m19_chama_prog("oaacm200",                             
                           "gpgtaler",                    
                           lr_param.corsus,                           
                           " ",                           
                           " ",                           
                           " ",                           
                           " ",                           
                           " ",                           
                           " ",                           
                           " ",                           
                           " ",                           
                           " ",                           
                           " ",                           
                           " ")                           
              returning l_status                          
      if l_status <> 0 then                               
        let l_msg = "Sistema indisponivel no momento !"   
            return l_msg                                  
      end if                                              
                                                          
 return l_msg              
 
end function                               
