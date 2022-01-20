#------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                        #
#........................................................................#
# Sistema        : Central 24h                                           #
# Modulo         : ctc48m03                                              #
# Analista.Resp  : Ligia Mattge                                          #
# PSI            : 188239                                                #
# Objetivo       : Obter a descricao do problema                         #
# Desenvolvimento: Mariana, Meta                                         #
# Liberacao      : 25/11/2004                                            #
#........................................................................#
#                    * * * Alteracoes * * *                              #
#                                                                        #
#    Data      Autor Fabrica   Origem  Alteracao                         #
#  ----------  -------------  -------- ----------------------------------#
#------------------------------------------------------------------------#	

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare           smallint

#---------------------------#
function ctc48m03_prepare()
#---------------------------#

define l_comando         char(500)


   let l_comando = "select c24pbmdes     "
                  ,"  from datkpbm       "
                  ," where c24pbmcod = ? "
                  
   prepare pctc48m03001 from l_comando
   declare cctc48m03001 cursor for pctc48m03001
   
   let m_prepare = true
   
end function 

#----------------------------------------------#
function ctc48m03_descricao_problema(l_c24pbmcod)                  
#----------------------------------------------#

define l_c24pbmcod          like datkpbm.c24pbmcod 
      ,l_c24pbmdes          like datkpbm.c24pbmdes
      
define l_status            smallint 
      ,l_mensagem          char(80)
      
    
    let l_c24pbmdes = null
    let l_mensagem  = null
    
    if l_c24pbmcod is null then
       let l_mensagem = "Parametro Invalido ! (ctc48m03_descricao_problema())"
       let l_status = 2
       return l_status, l_mensagem, l_c24pbmdes 
    end if 
    
    if m_prepare is null or 
       m_prepare <> true then
       call ctc48m03_prepare()
    end if 
   
    whenever error continue 
    open cctc48m03001 using l_c24pbmcod
    fetch cctc48m03001 into l_c24pbmdes
    whenever error stop 
    
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode < 0 then
          let l_mensagem = "Erro cctc48m03001: ", sqlca.sqlcode, '/', sqlca.sqlerrd[2]
                         , "ctc48m03_descricao_problema()"
          let l_status = 3
       else 
          let l_mensagem = "Problema Nao Cadastrado !"
          let l_status   = 2
       end if 
    else
       let l_status = 1
    end if 
    
    return l_status, l_mensagem, l_c24pbmdes
    
end function         

