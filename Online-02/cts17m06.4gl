#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : cts17m06                                            #
# Analista Resp.: Ligia Mattge                                        #
# PSI           : 188239                                              #
# Objetivo      : - Popup de naturezas                                #
#                 - Consistir natureza informada no assunto           #
#.....................................................................#
# Desenvolvimento: Mariana , META                                     #
# Liberacao      : 30/11/2004                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 25/09/06   Ligia Mattge  PSI 202720 Implementando grupo/cartao saude#
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------#
function cts17m06_popup_natureza(lr_param)
#-------------------------------------------#

define lr_param                  record
       aplnumdig                 like datrservapol.aplnumdig
      ,c24astcod                 like datmligacao.c24astcod
      ,ramcod                    like datrservapol.ramcod
      ,clscod                    char(05)
      ,rmemdlcod                 like datrsocntzsrvre.rmemdlcod
      ,prporg                    like datrligprp.prporg
      ,prpnumdig                 like datrligprp.prpnumdig
      ,socntzgrpcod              like datksocntz.socntzgrpcod
      ,crtsaunum                 like datrligsau.crtnum
                                 end record
define l_socntzcod               like datksocntz.socntzcod
      ,l_clscod                  char(05)
define l_nulo                    smallint

    let l_nulo = null

    
    if g_documento.ciaempcod = 84 then
       if lr_param.c24astcod = "I62" or lr_param.c24astcod = "R10" then 
          let lr_param.c24astcod = "S62" 
       end if 
       
       if lr_param.c24astcod = "I64" then    
             let lr_param.c24astcod = "S64"  
       end if                             
    end if    
    
    
    if (lr_param.crtsaunum is null and  ## PSI 202720
        lr_param.aplnumdig is null) or
       (lr_param.c24astcod = "S62" or
        lr_param.c24astcod = "S64") then
       call cts12g00(1, lr_param.c24astcod, l_nulo, l_nulo
                      , l_nulo, l_nulo, l_nulo, l_nulo)
            returning l_socntzcod, l_clscod
    else
       call cts12g00(1,lr_param.c24astcod, lr_param.ramcod, lr_param.clscod
                      ,lr_param.rmemdlcod, lr_param.prporg, lr_param.prpnumdig,
                       lr_param.socntzgrpcod)
            returning l_socntzcod, l_clscod
    end if
    return l_socntzcod, l_clscod
end function

#----------------------------------------------------------#
function cts17m06_assunto_natureza(l_c24astcod, l_socntzcod)
#----------------------------------------------------------#

define l_c24astcod           like datmligacao.c24astcod
      ,l_socntzcod           like datksocntz.socntzcod
define l_resultado           smallint
      ,l_nulo                smallint
      ,l_confirma            char(01)
      ,l_socntzgrpcod        like datksocntz.socntzgrpcod
     let l_nulo      = null
     let l_resultado = 0
     let l_socntzgrpcod = null
     select socntzgrpcod
         into l_socntzgrpcod
         from datksocntz
        where socntzcod = l_socntzcod
     if sqlca.sqlcode <> 0 then
        error "Codigo da Natureza invalido = ", l_socntzcod
        let l_resultado = 1
        return l_resultado
     end if

    #if  l_socntzcod = 11 or l_socntzcod = 12 or
    #    l_socntzcod = 13 or l_socntzcod = 14 or
    #    l_socntzcod = 15 or l_socntzcod = 16 or
    #    l_socntzcod = 17 or l_socntzcod = 19 then

    # quando for natureza 11(telefonia) nao aparecer para linha basica(S60)
    # porque o prestador que faz o servico e de linha branca(S63).
    if l_socntzcod =  11  then   # Telefonia
       let l_socntzgrpcod = 1 # linha branca
    end if
    if l_socntzgrpcod = 1 then # Grupo de Linha Branca
       if l_c24astcod = "S60" then
          let l_confirma = cts08g01("A", "N", l_nulo,
                                    "UTILIZE ASSUNTO S63 PARA SERVICOS",
                                    "DA NATUREZA LINHA BRANCA!" ,l_nulo)
          let l_resultado = 1
       end if
    else
       if l_c24astcod = "S63" then
          let l_confirma = cts08g01("A", "N" , l_nulo,
                                    "ASSUNTO S63 RESERVADO PARA SERVICOS DA"
                                   ,"LINHA BRANCA, UTILIZE O ASSUNTO S60!" ,
                                     l_nulo)
          let l_resultado = 1
       end if
    end if

    return l_resultado
end function
