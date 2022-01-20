#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty34g00                                                    #
# Objetivo.......: Tarifa de Dezembro 2013 - Controlador de Limites Clausulas  #
# Analista Resp. : Moises Gabel                                                #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 05/03/2014                                                  #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint
define m_acesso  smallint

#----------------------------------------------#
 function cty34g00_prepare()
#----------------------------------------------#

  define l_sql char(500)

  let l_sql = "select c24pbmgrpcod   ",
              " from datkpbm         ",
              " where c24pbmcod  = ? "
  prepare pcty34g00001  from l_sql
  declare ccty34g00001  cursor for pcty34g00001

  let l_sql = " select c.socntzcod            "
             ," from datmservico a            "
             ,"    , datmligacao b            "
             ,"    , datmsrvre   c            "
             ," where a.atdsrvnum = ?         "
             ," and a.atdsrvano = ?           "
             ," and b.c24astcod = ?           "
             ," and a.atdsrvnum = b.atdsrvnum "
             ," and a.atdsrvano = b.atdsrvano "
             ," and a.atdsrvnum = c.atdsrvnum "
             ," and a.atdsrvano = c.atdsrvano "
  prepare pcty34g00002 from l_sql
  declare ccty34g00002 cursor for pcty34g00002
  let l_sql = "select atdsrvnum  "
             ,"      ,atdsrvano  "
             ," from datrsrvsau  "
             ," where bnfnum = ? "
  prepare pcty34g00003 from l_sql
  declare ccty34g00003 cursor for pcty34g00003
  let l_sql = " select atdsrvnum    "
             ,"       ,atdsrvano    "
             ," from datrservapol   "
             ," where ramcod    = ? "
             ," and succod      = ? "
             ," and aplnumdig   = ? "
             ," and itmnumdig   = ? "
  prepare pcty34g00004 from l_sql
  declare ccty34g00004 cursor for pcty34g00004
  let l_sql = " select atdsrvnum           "
             ,"       ,atdsrvano           "
             ," from datmligacao a         "
             ,"     ,datrligprp b          "
             ," where a.lignum  = b.lignum "
             ," and b.prporg    = ?        "
             ," and b.prpnumdig = ?        "
             ," and a.c24astcod = ?        "
  prepare pcty34g00005 from l_sql
  declare ccty34g00005 cursor for pcty34g00005
  let m_prepare = true

end function

#----------------------------------------------#
 function cty34g00_restringe_natureza(lr_param)
#----------------------------------------------#

define lr_param record
	  c24astcod  like datkassunto.c24astcod,
    socntzcod  like datksocntz.socntzcod
end record

   if cty36g00_acesso() then
   	 if cty36g00_restringe_natureza(lr_param.c24astcod,lr_param.socntzcod) then
   	      return true
      else
          return false
      end if
   end if
   case lr_param.c24astcod
      when "S60"
          if cty34g00_restringe_natureza_S60(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S41"
          if cty34g00_restringe_natureza_S41(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S42"
          if cty34g00_restringe_natureza_S42(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      otherwise
          return false

   end case

end function

#---------------------------------------------------#
 function cty34g00_restringe_natureza_S60(lr_param)
#---------------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record


    case lr_param.socntzcod
       when 295  # Celular ou SmartPhone
          return true
       when 128  # Help Desk
       	  return true
       when 155  # Manutencao Apple
          return true
       when 110  # Manutencao Micro Residencia
          return true
       when 45   # Manutencao Micro Residencia
       	  return true
       when 293  # Smart Tv
          return true
       when 294  # Tablet
       	  return true
       when 292  # Video Game
       	  return true
       when 206  # Conectividade
          return true
       when 41   # Kit 1
          return true
       when 42   # Kit 2
          return true
       when 207  # Mudanca de Mobiliario
          return true
       otherwise
          return false
    end case


end function

#---------------------------------------------------#
 function cty34g00_restringe_natureza_S41(lr_param)
#---------------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record


    case lr_param.socntzcod
       when 28    # Ar Condicionado
          return true
       when 104   # Ar Condicionado
       	  return true
       when 295   # Celular ou SmartPhone
          return true
       when 13    # Fogao
          return true
       when 148   # Fogao
       	  return true
       when 16    # Freezer
          return true
       when 12    # Geladeira
       	  return true
       when 149   # Geladeira
       	  return true
       when 128   # Help Desk
          return true
       when 15    # Lava Louca
       	  return true
       when 14    # Lavadoura de Roupas
          return true
       when 155   # Manutencao Apple
          return true
       when 110   # Manutencao Micro Residencia
          return true
       when 45    # Manutencao Micro Residencia
       	  return true
       when 19    # Microondas
       	  return true
       when 47    # Reversao de Fogao
       	  return true
       when 17    # Secadora de Roupas
          return true
       when 293  # Smart Tv
          return true
       when 294  # Tablet
       	  return true
       when 11   # Telefonia
       	  return true
       when 292  # Video Game
       	  return true
       otherwise
          return false
    end case


end function

#---------------------------------------------------#
 function cty34g00_restringe_natureza_S42(lr_param)
#---------------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record


    case lr_param.socntzcod
       when 43    # Calhas e Rufos
          return true
       when 126   # Calhas e Rufos
       	  return true
       when 05    # Chaveiro
          return true
       when 141   # Chaveiro Tetra
          return true
       when 02    # Desentupimento
       	  return true
       when 288   # Desentupimento Area Externa
          return true
       when 10    # Eletrica
       	  return true
       when 146   # Eletrica
       	  return true
       when 128   # Help Desk
          return true
       when 01    # Hidraulica
       	  return true
       when 147   # Hidraulica
          return true
       when 41    # Kit1
       	  return true
       when 42    # Kit2
          return true
       when 155   # Manutencao Apple
          return true
       when 110   # Manutencao Micro Residencia
          return true
       when 45    # Manutencao Micro Residencia
       	  return true
       when 03    # Substituicao de Telhas
       	  return true
       when 125   # Substituicao de Telhas
       	  return true
       when 287   # Troca de Lampada
          return true
       when 258   # Troca de Lampadas
          return true
       when 293   # Smart Tv
          return true
       when 294   # Tablet
       	  return true
       when 295   # Celular e SmartPhone
       	  return true
       when 206   # Conectividade
       	  return true
       when 23    # Particular
       	  return true
       when 292   # Video Game
       	  return true
       otherwise
          return false
    end case


end function

#--------------------------------------------------#
 function cty34g00_valida_problema(lr_param)
#--------------------------------------------------#

define lr_param record
	  c24astcod     like datkassunto.c24astcod,
    c24pbmcod     like datkpbm.c24pbmcod
end record

define lr_retorno record
    c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
end record

initialize lr_retorno.* to null

if m_prepare is null or
   m_prepare <> true then
   call cty34g00_prepare()
end if


      #-----------------------------------------------------------
      # Recupera o Grupo de Problema
      #-----------------------------------------------------------

      open ccty34g00001 using lr_param.c24pbmcod

      whenever error continue
      fetch ccty34g00001 into lr_retorno.c24pbmgrpcod
      whenever error stop

      close ccty34g00001

      if cty34g00_valida_grupo_problema(lr_param.c24astcod     ,
      	                                lr_retorno.c24pbmgrpcod) then
      	 return true
      else
      	 return false
      end if

end function

#--------------------------------------------------#
 function cty34g00_valida_grupo_problema(lr_param)
#--------------------------------------------------#

define lr_param record
	  c24astcod     like datkassunto.c24astcod,
    c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
end record

   if cty36g00_acesso() then
   	    if lr_param.c24astcod = "S54" then
   	        if cty36g00_valida_grupo_problema(g_nova.perfil       ,
   	        	                                lr_param.c24astcod  ,
                                              lr_param.c24pbmgrpcod) then
               return true
   	        else
   	           return false
   	        end if
   	    else
   	        return true
   	    end if
   end if
   case lr_param.c24astcod
      when "S54"
          if cty34g00_valida_grupo_problema_S54(lr_param.c24pbmgrpcod) then
          	 return true
          else
          	 return false
          end if
      otherwise
          return true

   end case

end function

#----------------------------------------------------#
 function cty34g00_valida_grupo_problema_S54(lr_param)
#----------------------------------------------------#

define lr_param record
    c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
end record


    case lr_param.c24pbmgrpcod
       when 90   # Lei Seca
          return true
       otherwise
          return false
    end case


end function

#----------------------------------------------#
 function cty34g00_valida_limite(lr_param)
#----------------------------------------------#

define lr_param record
  c24astcod   like datkassunto.c24astcod  ,
  clscod      like abbmclaus.clscod       ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null
      if cty36g00_acesso() then
   	    call cty36g00_valida_limite(lr_param.c24astcod  ,
                                    lr_param.clscod     ,
                                    g_nova.perfil       ,
                                    lr_param.socntzcod  )
        returning lr_retorno.limite
   	    return lr_retorno.limite
      end if


     case lr_param.c24astcod
        when "S60"
        	  call  cty34g00_recupera_limite_S60(lr_param.clscod, lr_param.socntzcod)
        	  returning lr_retorno.limite
        when "S63"
        	  call  cty34g00_recupera_limite_S63(lr_param.clscod, lr_param.socntzcod)
        	  returning lr_retorno.limite
        when "S41"
        	  call  cty34g00_recupera_limite_S41(lr_param.clscod, lr_param.socntzcod)
        	  returning lr_retorno.limite
        when "S42"
        	  call  cty34g00_recupera_limite_S42(lr_param.clscod, lr_param.socntzcod)
        	  returning lr_retorno.limite
     end case

     return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty34g00_recupera_limite_S60(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     if lr_param.clscod = "047" then

         if lr_param.socntzcod = 1   or   # Hidraulica
     	   	  lr_param.socntzcod = 2   or   # Desentupimento
     	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
     	   	  lr_param.socntzcod = 5   or   # Chaveiro
     	   	  lr_param.socntzcod = 141 or   # Chave Tetra
     	   	  lr_param.socntzcod = 10  or   # Eletrica
     	   	  lr_param.socntzcod = 41  or   # Kit1
     	   	  lr_param.socntzcod = 42  or   # Kit2
     	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
     	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
     	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
            lr_param.socntzcod = 288 or   # Desentupimento Area Externa
     	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
     	   	  lr_param.socntzcod = 258 then # Troca de Lampadas
               let lr_retorno.limite  = 999
          end if
     end if

     if lr_param.clscod = "47R" then
         if lr_param.socntzcod = 1   or   # Hidraulica
     	   	  lr_param.socntzcod = 2   or   # Desentupimento
     	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
     	   	  lr_param.socntzcod = 5   or   # Chaveiro
     	   	  lr_param.socntzcod = 141 or   # Chave Tetra
     	   	  lr_param.socntzcod = 10  or   # Eletrica
     	   	  lr_param.socntzcod = 41  or   # Kit1
     	   	  lr_param.socntzcod = 42  or   # Kit2
     	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
     	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
     	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
            lr_param.socntzcod = 288 or   # Desentupimento Area Externa
     	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
     	   	  lr_param.socntzcod = 258 then # Troca de Lampadas
               let lr_retorno.limite  = 3
          end if
     end if
     return  lr_retorno.limite
end function

#----------------------------------------------#
 function cty34g00_recupera_limite_S63(lr_param)
#----------------------------------------------#
define lr_param record
  clscod      like abbmclaus.clscod      ,
  socntzcod   like datksocntz.socntzcod
end record
define lr_retorno record
  limite      integer
end record
initialize lr_retorno.* to null
     let lr_retorno.limite     = 0
     if lr_param.clscod = "047" then
         if lr_param.socntzcod = 11  or   # Telefonia
     	   	  lr_param.socntzcod = 12  or   # Geladeira
     	   	  lr_param.socntzcod = 13  or   # Fogao
     	   	  lr_param.socntzcod = 14  or   # Lavadoura
     	   	  lr_param.socntzcod = 15  or   # Lava Louca
     	   	  lr_param.socntzcod = 16  or   # Freezer
     	   	  lr_param.socntzcod = 17  or   # Secadora
     	   	  lr_param.socntzcod = 19  or   # Microondas
     	   	  lr_param.socntzcod = 28  or   # Ar Condicionado
     	   	  lr_param.socntzcod = 47  or   # Reversao de Fogao
     	   	  lr_param.socntzcod = 243 or   # Tanquinho
     	   	  lr_param.socntzcod = 300 or   # Geladeira Side by Side
     	   	  lr_param.socntzcod = 301 or   # Ar Condicionado Split
     	   	  lr_param.socntzcod = 302 then # Lava Roupas (Lava e Seca)
               let lr_retorno.limite  = 999
          end if
     end if
     if lr_param.clscod = "47R" then
         if lr_param.socntzcod = 11  or   # Telefonia
     	   	  lr_param.socntzcod = 12  or   # Geladeira
     	   	  lr_param.socntzcod = 13  or   # Fogao
     	   	  lr_param.socntzcod = 14  or   # Lavadoura
     	   	  lr_param.socntzcod = 15  or   # Lava Louca
     	   	  lr_param.socntzcod = 16  or   # Freezer
     	   	  lr_param.socntzcod = 17  or   # Secadora
     	   	  lr_param.socntzcod = 19  or   # Microondas
     	   	  lr_param.socntzcod = 28  or   # Ar Condicionado
     	   	  lr_param.socntzcod = 47  or   # Reversao de Fogao
            lr_param.socntzcod = 243 or   # Tanquinho
            lr_param.socntzcod = 300 or   # Geladeira Side by Side
            lr_param.socntzcod = 301 or   # Ar Condicionado Split
            lr_param.socntzcod = 302 then # Lava Roupas (Lava e Seca)
               let lr_retorno.limite  = 3
          end if
     end if
     return  lr_retorno.limite
end function

#----------------------------------------------#
 function cty34g00_recupera_limite_S41(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     if lr_param.clscod = "047" then

         if lr_param.socntzcod = 1   or   # Hidraulica
     	   	  lr_param.socntzcod = 2   or   # Desentupimento
     	   	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
     	   	  lr_param.socntzcod = 10  or   # Eletrica
     	   	  lr_param.socntzcod = 43  or   # Calhas e Rufos
     	   	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
     	   	  lr_param.socntzcod = 126 or   # Calhas e Rufos
            lr_param.socntzcod = 288 or   # Desentupimento Area Externa
     	   	  lr_param.socntzcod = 287 or   # Troca de Lampada
     	   	  lr_param.socntzcod = 258 or   # Troca de Lampadas
     	   	  lr_param.socntzcod = 12  or   # Geladeira
     	   	  lr_param.socntzcod = 11  or   # Telefonia
     	   	  lr_param.socntzcod = 13  or   # Fogao
     	   	  lr_param.socntzcod = 14  or   # Lavadoura
     	   	  lr_param.socntzcod = 15  or   # Lava Louca
     	   	  lr_param.socntzcod = 16  or   # Freezer
     	   	  lr_param.socntzcod = 17  or   # Secadora
     	   	  lr_param.socntzcod = 19  or   # Microondas
     	   	  lr_param.socntzcod = 47  or   # Reversao de Fogao
     	   	  lr_param.socntzcod = 243 then # Tanquinho
               let lr_retorno.limite  = 2
          end if
     end if

     if lr_param.clscod = "47R" then
           if lr_param.socntzcod = 1   or   # Hidraulica
	        	  lr_param.socntzcod = 2   or   # Desentupimento
	        	  lr_param.socntzcod = 3   or   # Substituicao de Telhas
	        	  lr_param.socntzcod = 10  or   # Eletrica
	        	  lr_param.socntzcod = 43  or   # Calhas e Rufos
	        	  lr_param.socntzcod = 125 or   # Substituicao de Telhas
	        	  lr_param.socntzcod = 126 or   # Calhas e Rufos
              lr_param.socntzcod = 288 or   # Desentupimento Area Externa
	        	  lr_param.socntzcod = 287 or   # Troca de Lampada
	        	  lr_param.socntzcod = 258 or   # Troca de Lampadas
	        	  lr_param.socntzcod = 12  or   # Geladeira
	        	  lr_param.socntzcod = 11  or   # Telefonia
	        	  lr_param.socntzcod = 13  or   # Fogao
	        	  lr_param.socntzcod = 14  or   # Lavadoura
	        	  lr_param.socntzcod = 15  or   # Lava Louca
	        	  lr_param.socntzcod = 16  or   # Freezer
	        	  lr_param.socntzcod = 17  or   # Secadora
	        	  lr_param.socntzcod = 19  or   # Microondas
	        	  lr_param.socntzcod = 47  or   # Reversao de Fogao
	        	  lr_param.socntzcod = 243 then # Tanquinho
               let lr_retorno.limite  = 2
          end if
     end if
     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty34g00_recupera_limite_S42(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod      ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer
end record

initialize lr_retorno.* to null

     let lr_retorno.limite     = 0

     if lr_param.clscod = "047" then

         if lr_param.socntzcod = 12  or   # Geladeira
         	  lr_param.socntzcod = 11  or   # Telefonia
           	lr_param.socntzcod = 13  or   # Fogao
           	lr_param.socntzcod = 14  or   # Lavadoura
           	lr_param.socntzcod = 15  or   # Lava Louca
           	lr_param.socntzcod = 16  or   # Freezer
           	lr_param.socntzcod = 17  or   # Secadora
           	lr_param.socntzcod = 28  or   # Ar condicionado
           	lr_param.socntzcod = 19  or   # Microondas
           	lr_param.socntzcod = 47  or   # Reversao de Fogao
            lr_param.socntzcod = 243 or   # Tanquinho
            lr_param.socntzcod = 1   or   # Hidraulica
            lr_param.socntzcod = 2   or   # Desentupimento
            lr_param.socntzcod = 3   or   # Substituicao de Telhas
            lr_param.socntzcod = 10  or   # Eletrica
            lr_param.socntzcod = 43  or   # Calhas e Rufos
            lr_param.socntzcod = 125 or   # Substituicao de Telhas
            lr_param.socntzcod = 126 or   # Calhas e Rufos
            lr_param.socntzcod = 288 or   # Desentupimento Area Externa
            lr_param.socntzcod = 287 or   # Troca de Lampada
            lr_param.socntzcod = 258 then   # Troca de Lampadas
               let lr_retorno.limite  = 2
         end if
     end if
     if lr_param.clscod = "47R" then

         if lr_param.socntzcod = 12  or   # Geladeira
         	  lr_param.socntzcod = 11  or   # Telefonia
           	lr_param.socntzcod = 13  or   # Fogao
           	lr_param.socntzcod = 14  or   # Lavadoura
           	lr_param.socntzcod = 15  or   # Lava Louca
           	lr_param.socntzcod = 16  or   # Freezer
           	lr_param.socntzcod = 17  or   # Secadora
           	lr_param.socntzcod = 19  or   # Microondas
           	lr_param.socntzcod = 28  or   # Ar Condicionado
           	lr_param.socntzcod = 47  or   # Reversao de Fogao
            lr_param.socntzcod = 243 or   # Tanquinho
            lr_param.socntzcod = 1   or   # Hidraulica
            lr_param.socntzcod = 2   or   # Desentupimento
            lr_param.socntzcod = 3   or   # Substituicao de Telhas
            lr_param.socntzcod = 10  or   # Eletrica
            lr_param.socntzcod = 43  or   # Calhas e Rufos
            lr_param.socntzcod = 125 or   # Substituicao de Telhas
            lr_param.socntzcod = 126 or   # Calhas e Rufos
            lr_param.socntzcod = 288 or   # Desentupimento Area Externa
            lr_param.socntzcod = 287 or   # Troca de Lampada
            lr_param.socntzcod = 258 then   # Troca de Lampadas
               let lr_retorno.limite  = 2
         end if
     end if
     return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty34g00_valida_natureza(lr_param)
#----------------------------------------------#

define lr_param record
	  c24astcod  like datkassunto.c24astcod,
    socntzcod  like datksocntz.socntzcod
end record

   if cty36g00_acesso() then
   	 if cty36g00_valida_natureza(lr_param.c24astcod,lr_param.socntzcod) then
   	      return true
      else
           return false
      end if
   end if
   case lr_param.c24astcod
      when "S60"
          if cty34g00_valida_natureza_S60(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S63"
          if cty34g00_valida_natureza_S63(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S78"
          if cty34g00_valida_natureza_S78(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S66"
          if cty34g00_valida_natureza_S66(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S67"
          if cty34g00_valida_natureza_S67(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S41"
          if cty34g00_valida_natureza_S41(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      when "S42"
          if cty34g00_valida_natureza_S42(lr_param.socntzcod) then
          	 return true
          else
          	 return false
          end if
      otherwise
          return true

   end case

end function

#----------------------------------------------#
 function cty34g00_valida_natureza_S60(lr_param)
#----------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record

    case lr_param.socntzcod
       when 1   # Hidraulica
          return true
       when 2   # Desentupimento
       	  return true
       when 3   # Substituicao de Telhas
          return true
       when 10  # Eletrica
          return true
       when 43  # Calhas e Rufos
       	  return true
       when 125 # Substituicao de Telhas
          return true
       when 126 # Calhas e Rufos
       	  return true
       when 5   # Chaveiro
          return true
       when 141 # Chave Tetra
       	  return true
       when 41  # Kit1
          return true
       when 42  # Kit2
          return true
       when 288 # Desentupimento Area Externa
       	  return true
       when 287 # Troca de Lampada
          return true
       when 258 # Troca de Lampadas
       	  return true
       otherwise
          return false
    end case
end function

#----------------------------------------------#
 function cty34g00_valida_natureza_S63(lr_param)
#----------------------------------------------#
define lr_param record
    socntzcod  like datksocntz.socntzcod
end record
    case lr_param.socntzcod
       when 12  # Geladeira
          return true
       when 11  # Telefonia
       	  return true
       when 13  # Fogao
          return true
       when 14  # Lavadoura
          return true
       when 15  # Lava Louca
       	  return true
       when 16  # Freezer
          return true
       when 17  # Secadora
       	  return true
       when 19  # Microondas
       	  return true
       when 28  # Ar condicionado
          return true
       when 47  # Reversao de Fogao
          return true
       when 243 # Tanquinho
       	  return true
       when 300 # Geladeira Side by Side
       	  return true
       when 301 # Ar Condicionado Split
          return true
       when 302 # Lava Roupas (Lava e Seca)
       	  return true
       otherwise
          return false
    end case
end function

#----------------------------------------------#
 function cty34g00_valida_natureza_S67(lr_param)
#----------------------------------------------#
define lr_param record
    socntzcod  like datksocntz.socntzcod
end record
    case lr_param.socntzcod
       when 45    # Manutencao Micro
       	 return true
       when 155   # Manutencao Micro
          return true
       when 292   # Video Game
          return true
       when 293   # Smart TV
       	 return true
       when 294   # Tablet
          return true
       when 295   # Smart e Celular
          return true
       when 64    # Checkup
       	 return true
       otherwise
         return false
    end case
end function
#----------------------------------------------#
 function cty34g00_valida_natureza_S78(lr_param)
#----------------------------------------------#
define lr_param record
    socntzcod  like datksocntz.socntzcod
end record
    case lr_param.socntzcod
      { when 128   # Help Desk
          return true}
       when 45    # Manutencao Micro
       	 return true
       when 155   # Manutencao Micro
          return true
      { when 206   # Conectividade
       	 return true}
       when 292   # Video Game
          return true
       when 293   # Smart TV
       	 return true
       when 294   # Tablet
          return true
       when 295   # Smart e Celular
          return true
       when 64    # Checkup
       	 return true
       otherwise
         return false
    end case
end function
#----------------------------------------------#
 function cty34g00_valida_natureza_S66(lr_param)
#----------------------------------------------#
define lr_param record
    socntzcod  like datksocntz.socntzcod
end record
    case lr_param.socntzcod
       when 45    # Manutencao Micro
       	 return true
       when 155   # Manutencao Micro
       	 return true
       when 292   # Video Game
          return true
       when 293   # Smart TV
       	 return true
       when 294   # Tablet
          return true
       when 295   # Smart e Celular
          return true
       when 64    # Checkup
       	 return true
       otherwise
         return false
    end case
end function
#----------------------------------------------#
 function cty34g00_valida_natureza_S41(lr_param)
#----------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record

    case lr_param.socntzcod
       when 1   # Hidraulica
          return true
       when 2   # Desentupimento
       	  return true
       when 3   # Substituicao de Telhas
          return true
       when 10  # Eletrica
          return true
       when 43  # Calhas e Rufos
       	  return true
       when 125 # Substituicao de Telhas
          return true
       when 126 # Calhas e Rufos
       	  return true
       when 288 # Desentupimento Area Externa
       	  return true
       when 287 # Troca de Lampada
          return true
       when 258 # Troca de Lampadas
       	  return true
       otherwise
          return false
    end case

end function

#----------------------------------------------#
 function cty34g00_valida_natureza_S42(lr_param)
#----------------------------------------------#

define lr_param record
    socntzcod  like datksocntz.socntzcod
end record

    case lr_param.socntzcod
       when 12  # Geladeira
          return true
       when 11  # Telefonia
       	  return true
       when 13  # Fogao
          return true
       when 14  # Lavadoura
          return true
       when 15  # Lava Louca
       	  return true
       when 16  # Freezer
          return true
       when 17  # Secadora
       	  return true
       when 19  # Microondas
       	  return true
       when 28  # Ar condicionado
          return true
       when 47  # Reversao de Fogao
          return true
       when 243 # Tanquinho
       	  return true
       otherwise
          return false
    end case

end function

#----------------------------------------------#
 function cty34g00_valida_clausula(lr_param)
#----------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod
end record


    if cty36g00_acesso() then
   	 if cty36g00_valida_clausula_fluxo2(lr_param.clscod) then
   	       let g_nova.perfil = 0
   	       return true
      else
           return false
      end if
   end if
   if lr_param.clscod = "047"  or
  	  lr_param.clscod = "47R"  then
  	  let g_nova.perfil = 0
      return true
   else
   	  return false
   end if

end function
#-------------------------------------------------------
function cty34g00_valida_envio_residencia(lr_param)
#-------------------------------------------------------
 define lr_param record
     ramcod      smallint
    ,succod      like abbmitem.succod
    ,aplnumdig   like abbmitem.aplnumdig
    ,itmnumdig   like abbmitem.itmnumdig
    ,c24astcod   like datkassunto.c24astcod
    ,bnfnum      like datrsrvsau.bnfnum
    ,crtsaunum   like datksegsau.crtsaunum
    ,socntzcod   like datksocntz.socntzcod
 end record
 define lr_retorno           record
     erro                    smallint
    ,data_calculo            date
    ,clscod                  char(05)
    ,flag_endosso            char(01)
    ,flag_limite             char(1)
    ,resultado               integer
    ,mensagem                char(80)
    ,qtd_ap                  integer
    ,qtd_pr                  integer
    ,qtd_at                  integer
    ,qtd_re                  integer
    ,qtd_bas                 integer
    ,qtd_bra                 integer
    ,qtd_ag                  integer
    ,prporgpcp               like abamdoc.prporgpcp
    ,prpnumpcp               like abamdoc.prpnumpcp
    ,limite                  integer
    ,limite_km               integer
    ,plncod                  like datkplnsau.plncod
    ,plndes                  like datkplnsau.plndes
    ,datac                   char(10)
 end record
 initialize  lr_retorno.*  to  null
 let lr_retorno.qtd_ap  = 0
 let lr_retorno.qtd_pr  = 0
 let lr_retorno.qtd_at  = 0
 let lr_retorno.qtd_re  = 0
 let lr_retorno.qtd_bas = 0
 let lr_retorno.qtd_bra = 0
 let lr_retorno.qtd_ag  = 0
 if lr_param.bnfnum is not null then
    #-----------------------------------------------------------
    # Obter o Plano Para Contagem dos Servicos - Saude
    #-----------------------------------------------------------
    call cta01m15_sel_datksegsau(4, lr_param.crtsaunum, "","","")
    returning lr_retorno.resultado    ,
              lr_retorno.mensagem     ,
              lr_retorno.plncod       ,
              lr_retorno.data_calculo
    let lr_retorno.datac = '01/01/', year(today) using "####"
    let lr_retorno.data_calculo = lr_retorno.datac
    #-----------------------------------------------------------
    # Obter o Limite de Utilizacao do Plano - Saude
    #-----------------------------------------------------------
    call cta01m16_sel_datkplnsau(lr_retorno.plncod )
    returning lr_retorno.resultado  ,
              lr_retorno.mensagem   ,
              lr_retorno.plndes     ,
              lr_retorno.limite
  else
    #-----------------------------------------------------------
    # Obter a Data de Calculo
    #-----------------------------------------------------------
    call faemc144_clausula(lr_param.succod         ,
                           lr_param.aplnumdig      ,
                           lr_param.itmnumdig)
                 returning lr_retorno.erro         ,
                           lr_retorno.clscod       ,
                           lr_retorno.data_calculo ,
                           lr_retorno.flag_endosso
    if lr_retorno.erro  <> 0 then
       let lr_retorno.flag_limite = "N"
       let lr_retorno.resultado   = 2
       let lr_retorno.mensagem    =  "Erro no Acesso a Funcao Faemc144."
       return lr_retorno.resultado
             ,lr_retorno.mensagem
             ,lr_retorno.flag_limite
             ,lr_retorno.qtd_at
             ,lr_retorno.limite
    end if
  end if
   #-----------------------------------------------------------
   # Recupera o Limite
   #-----------------------------------------------------------
   call cty34g00_valida_limite(lr_param.c24astcod   ,
                               lr_retorno.clscod    ,
                               lr_param.socntzcod   )
   returning lr_retorno.limite
   if lr_param.c24astcod = "S60" or
      lr_param.c24astcod = "S63" then
       call framo705_qtd_servicos(lr_retorno.clscod,
                                  lr_param.succod  ,
                                  lr_param.ramcod  ,
                                  lr_param.aplnumdig)
       returning lr_retorno.qtd_bas,
                 lr_retorno.qtd_bra
       if lr_retorno.qtd_bas is null then
          let lr_retorno.qtd_bas = 0
       end if
       if lr_retorno.qtd_bra is null then
          let lr_retorno.qtd_bra = 0
       end if
       if lr_param.c24astcod = "S60" then
          let lr_retorno.limite = lr_retorno.limite +  lr_retorno.qtd_bas
       end if
       if lr_param.c24astcod = "S63" then
          let lr_retorno.limite = lr_retorno.limite +  lr_retorno.qtd_bra
       end if
   else
   	  if lr_param.c24astcod = "S41" or
   	  	 lr_param.c24astcod = "S42" then
   	     call framo705_qtd_servicos(lr_retorno.clscod ,
                                    lr_param.succod   ,
                                    lr_param.ramcod   ,
                                    lr_param.aplnumdig)
   	     returning lr_retorno.qtd_bas,
   	               lr_retorno.qtd_bra
   	     if lr_retorno.qtd_bas is null then
   	        let lr_retorno.qtd_bas = 0
   	     end if
   	     if lr_retorno.qtd_bra is null then
            let lr_retorno.qtd_bra = 0
         end if
         if lr_param.c24astcod = "S41" then
            let lr_retorno.limite = lr_retorno.limite +  lr_retorno.qtd_bas
         end if
   	     if lr_param.c24astcod = "S42" then
            let lr_retorno.limite = lr_retorno.limite +  lr_retorno.qtd_bra
         end if
   	  end if
   end if
   #-----------------------------------------------------------
   # Obter a Quantidade de Atendimentos de Envio de Residencia
   #-----------------------------------------------------------
   if lr_param.c24astcod = "S60" or
   	  lr_param.c24astcod = "S63" then
      call cty31g00_quantidade_residencia(lr_param.ramcod
                                         ,lr_param.succod
                                         ,lr_param.aplnumdig
                                         ,lr_param.itmnumdig
                                         ,lr_retorno.data_calculo
                                         ,lr_param.c24astcod
                                         ,lr_param.bnfnum
                                         ,lr_retorno.flag_endosso
                                         ,lr_param.socntzcod)
      returning lr_retorno.resultado,
                lr_retorno.mensagem ,
                lr_retorno.qtd_at
    else
    	call cty05g02_qtd_srv_res(lr_param.ramcod
                               ,lr_param.succod
                               ,lr_param.aplnumdig
                               ,lr_param.itmnumdig
                               ,lr_retorno.data_calculo
                               ,lr_param.c24astcod
                               ,lr_param.bnfnum
                               ,lr_retorno.flag_endosso)
      returning lr_retorno.resultado,
                lr_retorno.mensagem ,
                lr_retorno.qtd_at
      #-----------------------------------------------------------
      # Obter a Quantidade de Atendimentos Agregados
      #-----------------------------------------------------------
      let lr_retorno.qtd_ag = cty31g00_calcula_agregacao(lr_param.ramcod         ,
                                                         lr_param.succod         ,
                                                         lr_param.aplnumdig      ,
                                                         lr_param.itmnumdig      ,
                                                         lr_param.c24astcod      ,
                                                         lr_retorno.data_calculo )
      let lr_retorno.qtd_at = lr_retorno.qtd_at + lr_retorno.qtd_ag
    end if
   if lr_retorno.resultado <> 1 then
      let lr_retorno.flag_limite = "N"
      return lr_retorno.resultado       ,
             lr_retorno.mensagem        ,
             lr_retorno.flag_limite     ,
             lr_retorno.qtd_at          ,
             lr_retorno.limite
   end if
   let lr_retorno.resultado = 1
   let lr_retorno.mensagem  = null
   if lr_retorno.qtd_at >= lr_retorno.limite then
        let lr_retorno.flag_limite = "S"
   else
   	    let lr_retorno.flag_limite = "N"
   end if
   if lr_retorno.flag_limite = "N" then
     if lr_param.c24astcod = "S41" or
        lr_param.c24astcod = "S42" then
        call cty05g02_qtd_servicos(lr_param.ramcod
                                  ,lr_param.succod
                                  ,lr_param.aplnumdig
                                  ,lr_param.itmnumdig
                                  ,lr_retorno.data_calculo
                                  ,lr_param.c24astcod
                                  ,lr_param.bnfnum
                                  ,lr_retorno.flag_endosso
                                  ,lr_retorno.limite)
        returning lr_retorno.flag_limite
     end if
   end if
   return  lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.flag_limite
          ,lr_retorno.qtd_at
          ,lr_retorno.limite
end function
#-------------------------------------------------#
function cty34g00_quantidade_residencia(lr_param)
#-------------------------------------------------#
define lr_param       record
       ramcod         smallint
      ,succod         like abbmitem.succod
      ,aplnumdig      like abbmitem.aplnumdig
      ,itmnumdig      like abbmitem.itmnumdig
      ,data_calculo   date
      ,c24astcod      like datmligacao.c24astcod
      ,bnfnum         like datrsrvsau.bnfnum
      ,flag_endosso   char(1)
      ,socntzcod      like datksocntz.socntzcod
end record
define lr_retorno record
	resultado         integer                  ,
  mensagem          char(80)                 ,
  prporgpcp         like abamdoc.prporgpcp   ,
  prpnumpcp         like abamdoc.prpnumpcp   ,
  qtde_at_ap        integer                  ,
  qtde_at_pr        integer                  ,
  qtd_atendimento   integer
end record
 initialize lr_retorno.* to null
 let lr_retorno.qtde_at_ap      = 0
 let lr_retorno.qtde_at_pr      = 0
 let lr_retorno.qtd_atendimento = 0
 let lr_retorno.resultado       = 1
 let lr_retorno.qtde_at_ap = cty34g00_quantidade_servico(lr_param.ramcod
                                                        ,lr_param.succod
                                                        ,lr_param.aplnumdig
                                                        ,lr_param.itmnumdig
                                                        ,"",""
                                                        ,lr_param.data_calculo
                                                        ,lr_param.c24astcod
                                                        ,lr_param.bnfnum
                                                        ,lr_param.socntzcod )
 #-----------------------------------------------------------------#
 # Se Nao Tem Endosso, Contar os Servicos Realizados pela Proposta
 #-----------------------------------------------------------------#
 if lr_param.flag_endosso = "N" then
    #-----------------------------------------------------------------#
    # Obter Proposta Original Atraves da Apolice
    #-----------------------------------------------------------------#
    call cty05g00_prp_apolice(lr_param.succod,lr_param.aplnumdig, 0)
    returning lr_retorno.resultado ,
              lr_retorno.mensagem  ,
              lr_retorno.prporgpcp ,
              lr_retorno.prpnumpcp
    if lr_retorno.resultado <> 1 then
       return lr_retorno.resultado       ,
              lr_retorno.mensagem        ,
              lr_retorno.qtd_atendimento
    end if
    let lr_retorno.qtde_at_pr = cty34g00_quantidade_servico(""                     ,
                                                            ""                     ,
                                                            ""                     ,
                                                            ""                     ,
                                                            lr_retorno.prporgpcp   ,
                                                            lr_retorno.prpnumpcp   ,
                                                            lr_param.data_calculo  ,
                                                            lr_param.c24astcod     ,
                                                            ""                     ,
                                                            lr_param.socntzcod)
 end if
 let lr_retorno.qtd_atendimento = lr_retorno.qtde_at_ap + lr_retorno.qtde_at_pr
 return lr_retorno.resultado,
        lr_retorno.mensagem ,
        lr_retorno.qtd_atendimento
end function
#----------------------------------------------#
function cty34g00_quantidade_servico(lr_param)
#----------------------------------------------#
define lr_param record
   ramcod    like datrservapol.ramcod
  ,succod    like datrservapol.succod
  ,aplnumdig like datrservapol.aplnumdig
  ,itmnumdig like datrservapol.itmnumdig
  ,prporgpcp like datrligprp.prporg
  ,prpnumpcp like datrligprp.prpnumdig
  ,clcdat    like datmservico.atddat
  ,c24astcod like datmligacao.c24astcod
  ,bnfnum    like datrligsau.bnfnum
  ,socntzcod like datksocntz.socntzcod
end record
define lr_servico record
   atdsrvnum like datrservapol.atdsrvnum
  ,atdsrvano like datrservapol.atdsrvano
end record
define lr_retorno record
	qtd integer          ,
	resultado smallint   ,
  mensagem  char(60)
end record
if m_prepare is null or
   m_prepare <> true then
   call cty34g00_prepare()
end if
 initialize lr_servico.*, lr_retorno.* to null
 let lr_retorno.qtd   = 0
 #----------------------------------------------------------------------------#
 # Obter a Quantidade de Servicos Realizados de Acordo com o Assunto Recebido
 #----------------------------------------------------------------------------#
 #----------------------------------------------------------------------------#
 # Obter os Servicos dos Atendimentos Realizados pelo Cartao Saude
 #----------------------------------------------------------------------------#
 if lr_param.bnfnum is not null then
    open ccty34g00003 using lr_param.bnfnum
    foreach ccty34g00003 into lr_servico.*
       #----------------------------------------------------------#
       # Consiste o Servico para Considera-lo na Contagem
       #----------------------------------------------------------#
       call cty34g00_consiste_servico(lr_servico.atdsrvnum
                                     ,lr_servico.atdsrvano
                                     ,lr_param.c24astcod
                                     ,lr_param.clcdat
                                     ,lr_param.socntzcod)
       returning lr_retorno.resultado, lr_retorno.mensagem
       if lr_retorno.resultado = 1 then
          let lr_retorno.qtd  = lr_retorno.qtd + 1
       else
          if lr_retorno.resultado = 3 then
             error lr_retorno.mensagem
             exit foreach
          end if
       end if
    end foreach
    close ccty34g00003
 else
    #-----------------------------------------------------------------#
    # Obter os Servicos dos Atendimentos Realizados pela Apolice
    #-----------------------------------------------------------------#
    if lr_param.aplnumdig is not null then
       open ccty34g00004 using lr_param.ramcod
                              ,lr_param.succod
                              ,lr_param.aplnumdig
                              ,lr_param.itmnumdig
       foreach ccty34g00004 into lr_servico.*
          #-----------------------------------------------------------------#
          # Consiste o Servico para Considera-lo na Contagem
          #-----------------------------------------------------------------#
          call cty34g00_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_param.c24astcod
                                        ,lr_param.clcdat
                                        ,lr_param.socntzcod)
          returning lr_retorno.resultado, lr_retorno.mensagem
          if lr_retorno.resultado = 1 then
             let lr_retorno.qtd  = lr_retorno.qtd + 1
          else
             if lr_retorno.resultado = 3 then
                error lr_retorno.mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close ccty34g00004
    end if
    #-----------------------------------------------------------------#
    # Obter os Servicos dos Atendimentos Realizados pela Proposta
    #-----------------------------------------------------------------#
    if lr_param.prpnumpcp is not null then
       open ccty34g00005 using lr_param.prporgpcp
                              ,lr_param.prpnumpcp
                              ,lr_param.c24astcod
       foreach ccty34g00005 into lr_servico.atdsrvnum
                                ,lr_servico.atdsrvano
          #-------------------------------------------------------#
          # Consiste o Servico para Considera-lo na Contagem
          #-------------------------------------------------------#
          call cty34g00_consiste_servico(lr_servico.atdsrvnum
                                        ,lr_servico.atdsrvano
                                        ,lr_param.c24astcod
                                        ,lr_param.clcdat
                                        ,lr_param.socntzcod)
          returning lr_retorno.resultado, lr_retorno.mensagem
          if lr_retorno.resultado = 1 then
             let lr_retorno.qtd  = lr_retorno.qtd + 1
          else
             if lr_retorno.resultado = 3 then
                error lr_retorno.mensagem sleep 2
                exit foreach
             end if
          end if
       end foreach
       close ccty34g00005
    end if
 end if
 return lr_retorno.qtd
end function
#---------------------------------------------#
function cty34g00_consiste_servico(lr_param)
#---------------------------------------------#
define lr_param record
   atdsrvnum like datmservico.atdsrvnum
  ,atdsrvano like datmservico.atdsrvano
  ,c24astcod like datmligacao.c24astcod
  ,clcdat    like datmservico.atddat
  ,socntzcod like datksocntz.socntzcod
end record
define lr_retorno record
	 resultado smallint
	,mensagem  char(60)
  ,atdetpcod like datmsrvacp.atdetpcod
  ,socntzcod like datksocntz.socntzcod
end record
initialize lr_retorno.* to  null
if m_prepare is null or
   m_prepare <> true then
   call cty34g00_prepare()
end if
 #-----------------------------------------------------------------------------#
 # Consistir Regras para Considerar o Servico na Contagem de Atendimento.
 #
 # 1 - Consistiu Servico de Acordo com a Etapa Testada, Ok.
 # 2 - Não Achou Servico ou Etapa não Está de Acordo com Etapa Testada, Ok.
 # 3 - Erro de Banco.
 #-----------------------------------------------------------------------------#
 #-----------------------------------------------------------------------------#
 # Verifica se o  Atendimento foi Realizado
 #-----------------------------------------------------------------------------#
 open ccty34g00002 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano
                        ,lr_param.c24astcod
 whenever error continue
 fetch ccty34g00002 into lr_retorno.socntzcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.resultado = 2
    else
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = 'Erro', sqlca.sqlcode, ' em datmservico '
    end if
 else
    case lr_param.c24astcod
       when "S60"
          if not cty34g00_valida_bloco_S60(lr_param.socntzcod  ,
          	                               lr_retorno.socntzcod) then
              let lr_retorno.resultado = 2
              return lr_retorno.resultado
                   , lr_retorno.mensagem
          end if
       when "S63"
          if not cty34g00_valida_bloco_S63(lr_param.socntzcod  ,
          	                               lr_retorno.socntzcod) then
              let lr_retorno.resultado = 2
              return lr_retorno.resultado
                   , lr_retorno.mensagem
          end if
       when "S41"
          if not cty34g00_valida_bloco_S41(lr_param.socntzcod  ,
                                           lr_retorno.socntzcod) then
              let lr_retorno.resultado = 2
              return lr_retorno.resultado
                   , lr_retorno.mensagem
          end if
       when "S42"
          if not cty34g00_valida_bloco_S42(lr_param.socntzcod  ,
                                           lr_retorno.socntzcod) then
              let lr_retorno.resultado = 2
              return lr_retorno.resultado
                   , lr_retorno.mensagem
          end if
    end case
    #------------------------------------------------#
    # Obtem a Ultima Etapa do Servico
    #------------------------------------------------#
    let lr_retorno.atdetpcod = cts10g04_ultima_etapa(lr_param.atdsrvnum
                                                    ,lr_param.atdsrvano)
    #-----------------------------------------------------------------------------#
    # Para Servico a Residencia, Conta Servicos Liberados(1) e Acionados(3)
    #-----------------------------------------------------------------------------#
    if lr_param.c24astcod = 'S60' or
       lr_param.c24astcod = 'S63' or
       lr_param.c24astcod = 'S66' or
       lr_param.c24astcod = 'S67' or
       lr_param.c24astcod = 'S41' or
       lr_param.c24astcod = 'S42' then
       if (lr_param.c24astcod = 'S66'  or
           lr_param.c24astcod = 'S67') then
           if (lr_param.c24astcod    = 'S66'  ) and
              (lr_retorno.atdetpcod  = 1   or
               lr_retorno.atdetpcod  = 2   or
               lr_retorno.atdetpcod  = 3   or
               lr_retorno.atdetpcod  = 4      ) then
              let lr_retorno.resultado = 1
           else
              if lr_retorno.atdetpcod = 1 or
                 lr_retorno.atdetpcod = 3 then
                 let lr_retorno.resultado = 1
              else
                 let lr_retorno.resultado = 2
              end if
           end if
       else
           if lr_retorno.atdetpcod = 1 or
              lr_retorno.atdetpcod = 3 then
              let lr_retorno.resultado = 1
           else
              let lr_retorno.resultado = 2
           end if
       end if
    end if
 end if
 close ccty34g00002
 return lr_retorno.resultado
      , lr_retorno.mensagem
end function
#----------------------------------------------#
 function cty34g00_valida_bloco_S41(lr_param)
#----------------------------------------------#
define lr_param record
  socntzcod1  like datksocntz.socntzcod  ,
  socntzcod2  like datksocntz.socntzcod
end record
   if lr_param.socntzcod1 = 1   or   # Hidraulica
   	  lr_param.socntzcod1 = 2   or   # Desentupimento
   	  lr_param.socntzcod1 = 3   or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 10  or   # Eletrica
   	  lr_param.socntzcod1 = 43  or   # Calhas e Rufos
   	  lr_param.socntzcod1 = 125 or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 126 or   # Calhas e Rufos
      lr_param.socntzcod1 = 288 or   # Desentupimento Area Externa
      lr_param.socntzcod1 = 287 or   # Troca de Lampada
      lr_param.socntzcod1 = 258 or   # Troca de Lampadas
      lr_param.socntzcod1 = 11  or   # Telefonia
   	  lr_param.socntzcod1 = 12  or   # Geladeira
   	  lr_param.socntzcod1 = 13  or   # Fogao
   	  lr_param.socntzcod1 = 14  or   # Lavadoura
   	  lr_param.socntzcod1 = 15  or   # Lava Louca
   	  lr_param.socntzcod1 = 16  or   # Freezer
   	  lr_param.socntzcod1 = 17  or   # Secadora
   	  lr_param.socntzcod1 = 19  or   # Microondas
   	  lr_param.socntzcod1 = 47  or   # Reversao de Fogao
      lr_param.socntzcod1 = 243 then # Tanquinho
         if lr_param.socntzcod2 = 1   or   # Hidraulica
         	  lr_param.socntzcod2 = 2   or   # Desentupimento
         	  lr_param.socntzcod2 = 3   or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 10  or   # Eletrica
         	  lr_param.socntzcod2 = 43  or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 125 or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 126 or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 288 or   # Desentupimento Area Externa
         	  lr_param.socntzcod2 = 287 or   # Troca de Lampada
         	  lr_param.socntzcod2 = 258 or   # Troca de Lampadas
         	  lr_param.socntzcod2 = 11  or   # Telefonia
         	  lr_param.socntzcod2 = 12  or   # Geladeira
         	  lr_param.socntzcod2 = 13  or   # Fogao
         	  lr_param.socntzcod2 = 14  or   # Lavadoura
         	  lr_param.socntzcod2 = 15  or   # Lava Louca
            lr_param.socntzcod2 = 16  or   # Freezer
         	  lr_param.socntzcod2 = 17  or   # Secadora
         	  lr_param.socntzcod2 = 19  or   # Microondas
         	  lr_param.socntzcod2 = 47  or   # Reversao de Fogao
         	  lr_param.socntzcod2 = 243 then # Tanquinho
               return true
          end if
    end if
    return false
end function
#----------------------------------------------#
 function cty34g00_valida_bloco_S42(lr_param)
#----------------------------------------------#
define lr_param record
  socntzcod1  like datksocntz.socntzcod  ,
  socntzcod2  like datksocntz.socntzcod
end record
   if lr_param.socntzcod1 = 1   or   # Hidraulica
   	  lr_param.socntzcod1 = 2   or   # Desentupimento
   	  lr_param.socntzcod1 = 3   or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 10  or   # Eletrica
   	  lr_param.socntzcod1 = 43  or   # Calhas e Rufos
   	  lr_param.socntzcod1 = 125 or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 126 or   # Calhas e Rufos
      lr_param.socntzcod1 = 288 or   # Desentupimento Area Externa
      lr_param.socntzcod1 = 287 or   # Troca de Lampada
      lr_param.socntzcod1 = 258 or   # Troca de Lampadas
      lr_param.socntzcod1 = 11  or   # Telefonia
   	  lr_param.socntzcod1 = 12  or   # Geladeira
   	  lr_param.socntzcod1 = 13  or   # Fogao
   	  lr_param.socntzcod1 = 14  or   # Lavadoura
   	  lr_param.socntzcod1 = 15  or   # Lava Louca
   	  lr_param.socntzcod1 = 16  or   # Freezer
   	  lr_param.socntzcod1 = 17  or   # Secadora
   	  lr_param.socntzcod1 = 19  or   # Microondas
   	  lr_param.socntzcod1 = 28  or   # Ar condicionado
   	  lr_param.socntzcod1 = 47  or   # Reversao de Fogao
      lr_param.socntzcod1 = 243 then # Tanquinho
         if lr_param.socntzcod2 = 1   or   # Hidraulica
         	  lr_param.socntzcod2 = 2   or   # Desentupimento
         	  lr_param.socntzcod2 = 3   or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 10  or   # Eletrica
         	  lr_param.socntzcod2 = 43  or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 125 or   # Substituicao de Telhas
         	  lr_param.socntzcod2 = 126 or   # Calhas e Rufos
         	  lr_param.socntzcod2 = 288 or   # Desentupimento Area Externa
         	  lr_param.socntzcod2 = 287 or   # Troca de Lampada
         	  lr_param.socntzcod2 = 258 or   # Troca de Lampadas
         	  lr_param.socntzcod2 = 11  or   # Telefonia
         	  lr_param.socntzcod2 = 12  or   # Geladeira
         	  lr_param.socntzcod2 = 13  or   # Fogao
         	  lr_param.socntzcod2 = 14  or   # Lavadoura
         	  lr_param.socntzcod2 = 15  or   # Lava Louca
            lr_param.socntzcod2 = 16  or   # Freezer
         	  lr_param.socntzcod2 = 17  or   # Secadora
         	  lr_param.socntzcod2 = 19  or   # Microondas
         	  lr_param.socntzcod2 = 28  or   # Ar condicionado
         	  lr_param.socntzcod2 = 47  or   # Reversao de Fogao
         	  lr_param.socntzcod2 = 243 then # Tanquinho
               return true
          end if
    end if
    return false
end function
#----------------------------------------------#
 function cty34g00_valida_bloco_S60(lr_param)
#----------------------------------------------#
define lr_param record
  socntzcod1  like datksocntz.socntzcod  ,
  socntzcod2  like datksocntz.socntzcod
end record
   if lr_param.socntzcod1 = 1   or   # Hidraulica
   	  lr_param.socntzcod1 = 2   or   # Desentupimento
   	  lr_param.socntzcod1 = 3   or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 10  or   # Eletrica
   	  lr_param.socntzcod1 = 43  or   # Calhas e Rufos
   	  lr_param.socntzcod1 = 125 or   # Substituicao de Telhas
   	  lr_param.socntzcod1 = 126 or   # Calhas e Rufos
      lr_param.socntzcod1 = 288 or   # Desentupimento Area Externa
      lr_param.socntzcod1 = 287 or   # Troca de Lampada
      lr_param.socntzcod1 = 258 or   # Troca de Lampadas
      lr_param.socntzcod1 = 5   or   # Chaveiro
   	  lr_param.socntzcod1 = 141 or   # Chave Tetra
   	  lr_param.socntzcod1 = 41  or   # Kit1
   	  lr_param.socntzcod1 = 42  then # Kit2
         if lr_param.socntzcod2 = 1   or   # Hidraulica
   	        lr_param.socntzcod2 = 2   or   # Desentupimento
   	        lr_param.socntzcod2 = 3   or   # Substituicao de Telhas
   	        lr_param.socntzcod2 = 10  or   # Eletrica
   	        lr_param.socntzcod2 = 43  or   # Calhas e Rufos
   	        lr_param.socntzcod2 = 125 or   # Substituicao de Telhas
   	        lr_param.socntzcod2 = 126 or   # Calhas e Rufos
            lr_param.socntzcod2 = 288 or   # Desentupimento Area Externa
            lr_param.socntzcod2 = 287 or   # Troca de Lampada
            lr_param.socntzcod2 = 258 or   # Troca de Lampadas
            lr_param.socntzcod2 = 5   or   # Chaveiro
   	        lr_param.socntzcod2 = 141 or   # Chave Tetra
   	        lr_param.socntzcod2 = 41  or   # Kit1
   	        lr_param.socntzcod2 = 42  then # Kit2
               return true
          end if
    end if
    return false
end function
#----------------------------------------------#
 function cty34g00_valida_bloco_S63(lr_param)
#----------------------------------------------#
define lr_param record
  socntzcod1  like datksocntz.socntzcod  ,
  socntzcod2  like datksocntz.socntzcod
end record
    if  lr_param.socntzcod1 = 11  or   # Telefonia
    	  lr_param.socntzcod1 = 12  or   # Geladeira
    	  lr_param.socntzcod1 = 13  or   # Fogao
    	  lr_param.socntzcod1 = 14  or   # Lavadoura
    	  lr_param.socntzcod1 = 15  or   # Lava Louca
    	  lr_param.socntzcod1 = 16  or   # Freezer
    	  lr_param.socntzcod1 = 17  or   # Secadora
    	  lr_param.socntzcod1 = 19  or   # Microondas
    	  lr_param.socntzcod1 = 28  or   # Ar condicionado
    	  lr_param.socntzcod1 = 47  or   # Reversao de Fogao
    	  lr_param.socntzcod1 = 243 or   # Tanquinho
    	  lr_param.socntzcod1 = 300 or   # Geladeira Side by Side
    	  lr_param.socntzcod1 = 301 or   # Ar Condicionado Split
    	  lr_param.socntzcod1 = 302 then # Lava Roupas (Lava e Seca)
         if  lr_param.socntzcod2 = 11  or   # Telefonia
    	       lr_param.socntzcod2 = 12  or   # Geladeira
    	       lr_param.socntzcod2 = 13  or   # Fogao
    	       lr_param.socntzcod2 = 14  or   # Lavadoura
    	       lr_param.socntzcod2 = 15  or   # Lava Louca
    	       lr_param.socntzcod2 = 16  or   # Freezer
    	       lr_param.socntzcod2 = 17  or   # Secadora
    	       lr_param.socntzcod2 = 19  or   # Microondas
    	       lr_param.socntzcod2 = 28  or   # Ar condicionado
    	       lr_param.socntzcod2 = 47  or   # Reversao de Fogao
    	       lr_param.socntzcod2 = 243 or   # Tanquinho
    	       lr_param.socntzcod2 = 300 or   # Geladeira Side by Side
    	       lr_param.socntzcod2 = 301 or   # Ar Condicionado Split
    	       lr_param.socntzcod2 = 302 then # Lava Roupas (Lava e Seca)
               return true
          end if
    end if
    return false
end function
#--------------------------------------------------------#
function cty34g00_valida_envio_guincho(lr_param)
#--------------------------------------------------------#
define lr_param record
    ramcod      smallint
   ,succod      like abbmitem.succod
   ,aplnumdig   like abbmitem.aplnumdig
   ,itmnumdig   like abbmitem.itmnumdig
   ,c24astcod   like datkassunto.c24astcod
   ,socntzcod   like datksocntz.socntzcod
end record
define lr_retorno           record
    erro                    smallint
   ,data_calculo            date
   ,clscod                  char(05)
   ,flag_endosso            char(01)
   ,flag_limite             char(1)
   ,resultado               integer
   ,mensagem                char(80)
   ,qtd_ap                  integer
   ,qtd_ag                  integer
   ,qtd_at                  integer
   ,prporgpcp               like abamdoc.prporgpcp
   ,prpnumpcp               like abamdoc.prpnumpcp
   ,limite                  integer
   ,limite_km               integer
end record
initialize lr_retorno.* to null
   let lr_retorno.qtd_ap  = 0
   let lr_retorno.qtd_ag  = 0
   let lr_retorno.qtd_at  = 0
   #-----------------------------------------------------------
   # Obter a Data de Calculo
   #-----------------------------------------------------------
   call faemc144_clausula(lr_param.succod    ,
           	              lr_param.aplnumdig ,
           	              lr_param.itmnumdig )
   returning lr_retorno.erro         ,
             lr_retorno.clscod       ,
             lr_retorno.data_calculo ,
             lr_retorno.flag_endosso

   #-----------------------------------------------------------
   # Obter a Quantidade de Atendimentos de Envio de Socorro
   #-----------------------------------------------------------
   if lr_param.c24astcod = "S41" or
   	  lr_param.c24astcod = "S42" then
   	  call cty34g00_quantidade_servico(lr_param.ramcod         ,
                                       lr_param.succod         ,
                                       lr_param.aplnumdig      ,
                                       lr_param.itmnumdig      ,
                                       ""                      ,
                                       ""                      ,
                                       lr_retorno.data_calculo ,
                                       lr_param.c24astcod      ,
                                       ''                      ,
                                       lr_param.socntzcod      )
      returning lr_retorno.qtd_ap
   else
      call cta02m15_qtd_servico(lr_param.ramcod         ,
                                lr_param.succod         ,
                                lr_param.aplnumdig      ,
                                lr_param.itmnumdig      ,
                                ""                      ,
                                ""                      ,
                                lr_retorno.data_calculo ,
                                lr_param.c24astcod      ,
                                '' )
      returning lr_retorno.qtd_ap
   end if
   #-----------------------------------------------------------
   # Obter a Quantidade de Atendimentos Agregados
   #-----------------------------------------------------------
   let lr_retorno.qtd_ag = cty31g00_calcula_agregacao(lr_param.ramcod         ,
                                                      lr_param.succod         ,
                                                      lr_param.aplnumdig      ,
                                                      lr_param.itmnumdig      ,
                                                      lr_param.c24astcod      ,
                                                      lr_retorno.data_calculo )
   let lr_retorno.qtd_at = lr_retorno.qtd_ap + lr_retorno.qtd_ag
   let lr_retorno.resultado = 1
   let lr_retorno.mensagem  = null
   call cty34g00_valida_limite(lr_param.c24astcod,
                               lr_retorno.clscod ,
                               lr_param.socntzcod)
   returning lr_retorno.limite

   if lr_retorno.qtd_at >= lr_retorno.limite then
        let lr_retorno.flag_limite = "S"
   else
   	    let lr_retorno.flag_limite = "N"
   end if
   return  lr_retorno.resultado
          ,lr_retorno.mensagem
          ,lr_retorno.flag_limite
          ,lr_retorno.qtd_at
          ,lr_retorno.limite
end function