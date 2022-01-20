#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : ctx01g11.4gl                                              #
#                  Retorna se a placa enviada e de um prestador esta ativo   #
# Analista Resp. : Robert Lima                                               #
# PSI            :                                                           #
#............................................................................#
# Liberacao      : 06/01/2011                                                #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data        Autor Fabrica  Data   Alteracao                                #
# ----------  -------------  ------ -----------------------------------------#
#----------------------------------------------------------------------------#

database porto

#---------------------------------------------------------------------------
function ctx01g11_veic_pst(l_vcllicnum)
#---------------------------------------------------------------------------

  define l_vcllicnum  like datkveiculo.vcllicnum
  define l_retorno    smallint,
         l_msg        char(100),
         l_sql        char(500)
         
  define ctx01g11 record
      socoprsitcod like datkveiculo.socoprsitcod, 
      prssitcod    like dpaksocor.prssitcod, 
      vcllicnum    like datkveiculo.vcllicnum   
  end record

  let l_sql = "select vcl.socoprsitcod, pst.prssitcod, vcl.vcllicnum",
              "  from datkveiculo vcl,                  ",
              "       dpaksocor pst                     ",
              " where vcl.pstcoddig = pst.pstcoddig     ",
              "   and vcl.vcllicnum = ?                 ",
              "   and prssitcod = 'A'                   ",
              "   and socoprsitcod = 1                  "
  prepare pctx01g11001 from l_sql             
  declare cctx01g11001 cursor for pctx01g11001
  
  let l_retorno = true
  let l_msg = null
  initialize ctx01g11.* to null 
  
  if l_vcllicnum is null then
     let l_retorno = false;
     let l_msg = "PARAMETRO NULO, NAO EFETUADA CONSULTA"
     return l_retorno,l_msg
  end if
  
  whenever error continue
  open cctx01g11001 using l_vcllicnum
  fetch cctx01g11001 into ctx01g11.socoprsitcod,
                          ctx01g11.prssitcod,
                          ctx01g11.vcllicnum
  whenever error stop
    
  if sqlca.sqlcode <> 0 then
     let l_retorno = false;                             
     let l_msg = "PLACA NÃO ENCONTRADA"
     return l_retorno,l_msg
  end if

  close cctx01g11001
  return l_retorno,l_msg
              
end function   
               