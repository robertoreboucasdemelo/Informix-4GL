#------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                        #
#........................................................................#
# Sistema        : Automovel                                             #
# Modulo         : cts17m07                                              #
# Analista.Resp  : Ligia Mattge                                          #
# PSI            : 188239                                                #
# Objetivo       : consistir o campo problema (c24pbmcod) p/ atendimento #
#                  sem documento informados, assuntos de cortesia para   #
#                  servico emergencial e atendimento normal.             #
#........................................................................#
# Desenvolvimento: Adriana Schneider - Fabrica de Software - Meta        #
# Liberacao      : 24/11/2004                                            #
#........................................................................#
#                    * * * Alteracoes * * *                              #
#                                                                        #
#    Data      Autor Fabrica   Origem  Alteracao                         #
#  ----------  -------------  -------- ----------------------------------#
# 25/09/06   Ligia Mattge  PSI 202720 Implementando grupo/cartao saude   #
#------------------------------------------------------------------------#
# 24/04/2012 Johnny Alves     Ajuste de regra de negocio para a exclusao #
#            Biztalking       do problema 999 para quando digitar codigo #
#                             999 apresentar a mensagem codigo           #
#                             invalido e mostrar os problemas.           #
#------------------------------------------------------------------------#




globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare smallint


function cts17m07_prepare()

define l_comando          char(500)

    let l_comando = "select c24pbmgrpcod "
                   ,"  from datksocntz "
                   ," where socntzcod = ?   "

    prepare p_cts17m07_001 from l_comando
    declare c_cts17m07_001 cursor for p_cts17m07_001

    let l_comando = "select c24pbmgrpcod , c24pbmgrpdes "
                   ,"  from datkpbmgrp "
                   ," where c24pbmgrpcod = ?   "

    prepare p_cts17m07_002 from l_comando
    declare c_cts17m07_002 cursor for p_cts17m07_002

    let m_prepare = true

end function


##----------------------------------------------##
function cts17m07_problema(lr_param)
##----------------------------------------------##
define lr_param record
       aplnumdig       like abamdoc.aplnumdig,
       c24astcod       like datkassunto.c24astcod,
       atdsrvorg       like datksrvtip.atdsrvorg,
       c24pbmcod       like datrsrvpbm.c24pbmcod,
       socntzcod       like datksocntz.socntzcod,
       clscod_natureza like datrsocntzsrvre.clscod,
       clscod_apolice  like datrsocntzsrvre.clscod,
       rmemdlcod       like datrsocntzsrvre.rmemdlcod,
       ramcod          like datrsocntzsrvre.ramcod,
       crtsaunum       like datrligsau.crtnum
end record

define l_c24pbmgrpcod   like datkpbmgrp.c24pbmgrpcod,
       l_c24pbmgrpdes   like datkpbmgrp.c24pbmgrpdes,
       l_c24pbmcod      like datkpbm.c24pbmcod,
       l_atddfttxt      like datkpbm.c24pbmdes,
       l_ret            smallint ,
       l_mens           char(100)

let l_ret       = 1
let l_mens      = null
let l_atddfttxt = null

if m_prepare is null or
   m_prepare <> true then
   call cts17m07_prepare()
end if

if (lr_param.crtsaunum is null  and ## PSI 202720
    lr_param.aplnumdig is null)  or
  (lr_param.c24astcod = "S62" or
   lr_param.c24astcod = "S64"  ) then
   
   if lr_param.c24pbmcod is null or
      lr_param.c24pbmcod = 0     or
      (lr_param.c24pbmcod = 999  and 
       g_documento.ciaempcod <> 84 ) then #Johnny,Biz
      
      if lr_param.c24pbmcod = 999 and 
         g_documento.ciaempcod <> 84 then  #Johnny,Biz
      	 error " Codigo de problema invalido !" sleep 1 
      end if	  
            
      call cts12g01_grupo_problema(lr_param.socntzcod,lr_param.ramcod,
                                   lr_param.clscod_natureza,lr_param.rmemdlcod)
           returning l_ret,l_mens, l_c24pbmgrpcod

      if l_c24pbmgrpcod is null then
         ## Visualizar os problemas de acordo com a origem do servico
         call ctc48m02(lr_param.atdsrvorg)
               returning l_c24pbmgrpcod, l_c24pbmgrpdes

         if l_c24pbmgrpcod is null then
            let l_ret = 2
            let l_mens = "Codigo de problema deve ser informado! "
            return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
         end if
      end if

      call ctc48m01(l_c24pbmgrpcod,"")
            returning l_c24pbmcod,l_atddfttxt

      if l_c24pbmcod is null then
         let l_ret = 2
         let l_mens = "Codigo de problema deve ser informado "
         return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
      end if
   else

    if g_documento.ciaempcod = 40 or
       g_documento.ciaempcod = 43 then # PSI 247936 Empresas 27
       open c_cts17m07_001  using lr_param.socntzcod
       fetch c_cts17m07_001  into l_c24pbmgrpcod

       if l_c24pbmgrpcod is not null then
          open c_cts17m07_002  using l_c24pbmgrpcod
          fetch c_cts17m07_002  into l_c24pbmgrpcod,l_c24pbmgrpdes
       end if

       if l_c24pbmgrpcod is null then
          let l_ret = 2
          let l_mens = "Codigo de problema deve ser informado "
          return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
       else

          call ctc48m01(l_c24pbmgrpcod,"")
               returning l_c24pbmcod,l_atddfttxt

          if l_c24pbmcod is null then
             let l_ret = 2
             let l_mens = "Codigo de problema deve ser informado "
             return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
          end if
       end if
    else
       let l_c24pbmcod = lr_param.c24pbmcod        
        if lr_param.c24pbmcod <> "999" then          #Johnny,Biz
            ## Obter a descricao do problema
          call ctc48m03_descricao_problema(lr_param.c24pbmcod)
               returning l_ret,l_mens,l_atddfttxt

          if l_ret <> 1 then
             error l_mens
             sleep 2
             let l_mens = null

             ## Visualizar os problemas de acordo com a origem do servico
             call ctc48m02(lr_param.atdsrvorg)
                  returning l_c24pbmgrpcod,l_c24pbmgrpdes

             if l_c24pbmgrpcod is null then
                let l_ret = 2
                let l_mens = "Codigo de problema deve ser informado "
                return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
             else

                call ctc48m01(l_c24pbmgrpcod,"")
                     returning l_c24pbmcod,l_atddfttxt

                if l_c24pbmcod is null then
                   let l_ret = 2
                   let l_mens = "Codigo de problema deve ser informado "
                   return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
                end if
             end if
          end if
        end if
       end if                       #Johnny,Biz
   end if
else
    if lr_param.c24pbmcod is null or
       lr_param.c24pbmcod = 0     then
       ##Obter o grupo do problema
              
       call cts12g01_grupo_problema(lr_param.socntzcod,lr_param.ramcod,
                                    lr_param.clscod_natureza,lr_param.rmemdlcod)
            returning l_ret,l_mens, l_c24pbmgrpcod

       if l_ret = 3 then
          return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
       end if

       if l_ret = 2 or l_c24pbmgrpcod is null then
          let l_c24pbmcod = 999
          return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
       end if

       ## Chamar popup de tipos de problemas
       call ctc48m01(l_c24pbmgrpcod,"")
            returning l_c24pbmcod,l_atddfttxt

       if l_c24pbmcod is null then
          let l_ret = 2
          let l_mens = "Codigo de problema deve ser informado "
          return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
       end if
    else
       let l_c24pbmcod = lr_param.c24pbmcod                                   
       
       if lr_param.c24pbmcod <> "999" and 
          lr_param.c24pbmcod <> "9999" and
          g_documento.ciaempcod <> 84 then        #Johnny,Biz          
                    
          ##Obter o grupo do problema          
          call cts12g01_grupo_problema(lr_param.socntzcod,lr_param.ramcod,
                                       lr_param.clscod_apolice,lr_param.rmemdlcod)
               returning l_ret,l_mens, l_c24pbmgrpcod

          if l_ret <> 1 then
             return l_ret, l_mens, l_c24pbmcod, l_atddfttxt
          end if
          
          ## Chamar popup de tipos de problemas
          call ctc48m01(l_c24pbmgrpcod,"")
               returning l_c24pbmcod,l_atddfttxt

          if l_c24pbmcod is null then
             let l_ret = 2
             let l_mens = "Codigo de problema deve ser informado "
          end if
       else                             
           if g_documento.ciaempcod <> 84 then
              
              if (lr_param.c24pbmcod = 999 or                    
                  lr_param.c24pbmcod = 9999 ) then                              
                 error" Codigo de problema invalido !" sleep 1   
              end if                                             
              
              
              ##Obter o grupo do problema                                              
              call cts12g01_grupo_problema(lr_param.socntzcod,lr_param.ramcod,         
                                           lr_param.clscod_apolice,lr_param.rmemdlcod) 
                   returning l_ret,l_mens, l_c24pbmgrpcod                              
                                                                                       
              if l_ret <> 1 then                                                       
                 return l_ret, l_mens, l_c24pbmcod, l_atddfttxt                        
              end if                                                                   
                                                                                       
              ## Chamar popup de tipos de problemas                                    
              call ctc48m01(l_c24pbmgrpcod,"")                                         
                   returning l_c24pbmcod,l_atddfttxt                                   
                                                                                       
              if l_c24pbmcod is null then                                              
                 let l_ret = 2                                                         
                 let l_mens = "Codigo de problema deve ser informado "                 
              end if                                                                   
           else
              ##Obter o grupo do problema                                              
              call cts12g01_grupo_problema(lr_param.socntzcod,lr_param.ramcod,         
                                           lr_param.clscod_apolice,lr_param.rmemdlcod) 
                   returning l_ret,l_mens, l_c24pbmgrpcod                              
                                                                                       
              if l_ret <> 1 then                                                       
                 return l_ret, l_mens, l_c24pbmcod, l_atddfttxt                        
              end if                                                                   
                                                                                       
              ## Chamar popup de tipos de problemas                                    
              call ctc48m01(l_c24pbmgrpcod,"")                                         
                   returning l_c24pbmcod,l_atddfttxt                                   
                                                                                       
              if l_c24pbmcod is null then                                              
                 let l_ret = 2                                                         
                 let l_mens = "Codigo de problema deve ser informado "                 
              end if                                                                                         
           end if   
       
       end if                                    #Johnny,Biz
    end if
end if

return l_ret, l_mens, l_c24pbmcod, l_atddfttxt

end function
                                          