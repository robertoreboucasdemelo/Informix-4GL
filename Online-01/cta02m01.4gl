#--------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                          #
# .........................................................................#
# Sistema       : Central 24h                                              #
# Modulo        : cta02m01                                                 #
# Analista Resp.: Ligia Mattge                                             #
# PSI           : 188425                                                   #
# Objetivo      : Consistir o nivel de acesso para assunto                 #
#                (cta02m01_nivel_assunto)                                  #
#                 Converte assunto de reclamacao para W00 ou X10           #
#                (cta02m01_reclamacoes)                                    #
#..........................................................................#
# Desenvolvimento: Mariana , META                                          #
# Liberacao      : 28/10/2004                                              #
#..........................................................................#
#                                                                          #
#                  * * * Alteracoes * * *                                  #
#                                                                          #
# Data        Autor Fabrica  Origem    Alteracao                           #
# ----------  -------------- --------- ----------------------------------- #
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto #
#                                      como sendo o agrupamento, buscar cod#
#                                      agrupamento.                        #
#--------------------------------------------------------------------------#
# 14/05/2015 Luiz Fornax   PSI-2014-22747 Acesso nivel 3                   #
#--------------------------------------------------------------------------#
globals '/homedsa/projetos/geral/globals/glct.4gl'


#-----------------------------------------#
function cta02m01_nivel_assunto(lr_param)
#-----------------------------------------#

define lr_param            record
       acsnivcod           like issmnivel.acsnivcod
      ,succod              like abamapol.succod
      ,dptsgl              like isskfunc.dptsgl
      ,c24astcod           like datkassunto.c24astcod
                           end record

define lr_ret              record
       resultado           smallint
      ,mensagem            char(50)
                           end record

define l_c24astagp         like datkassunto.c24astagp


   if lr_param.acsnivcod is null or
      lr_param.succod    is null or
      lr_param.dptsgl    is null or
      lr_param.c24astcod is null then
      error "Parametros invalidos (cta02m01_nivel_assunto())"
      sleep 1
      return lr_ret.*
   end if

   if lr_param.acsnivcod = 2 then
      let lr_ret.resultado = 2
      let lr_ret.mensagem  = 'Nivel de acesso somente para consulta'
      return lr_ret.*
   end if

   #PSI 230650 - inicio
   # Buscar codigo de agrupamento
   select c24astagp into l_c24astagp
         from datkassunto
        where c24astcod = lr_param.c24astcod
   #PSI 230650 - fim

   if lr_param.acsnivcod = 3 then
      if lr_param.succod <> 2 then
         if lr_param.dptsgl = 'cmpnas' then
            #if (lr_param.c24astcod[1] <> 'V')   or
            if (l_c24astagp <> 'V')   or    ##psi230650
               (lr_param.c24astcod     = 'V12') then
               let lr_ret.resultado = 2
               let lr_ret.mensagem  = 'Nivel de acesso nao permite cadastrar esse assunto'
               return lr_ret.*
            end if
         else
            if lr_param.c24astcod <> 'REP' and
               lr_param.c24astcod <> 'GOF' and
               lr_param.c24astcod <> 'RPT' and
               lr_param.c24astcod <> 'K**' and
               lr_param.c24astcod <> 'KA*' and
               lr_param.c24astcod <> 'IA*' and
               l_c24astagp <> '*' then
               let lr_ret.resultado = 2
               let lr_ret.mensagem  = 'Nivel de acesso nao permite cadastrar esse assunto'
               return lr_ret.*
            end if
         end if
      else
      
         if l_c24astagp <> 'S'   and
            l_c24astagp <> 'D'   and
            l_c24astagp <> 'E'   and
            l_c24astagp <> 'I'   and
            l_c24astagp <> 'L'   and
            l_c24astagp <> 'G'   and
            lr_param.c24astcod    <> 'RPT' then
            let lr_ret.resultado = 2
            let lr_ret.mensagem  = 'Nivel de acesso nao permite cadastrar esse assunto'
            return lr_ret.*
         end if
      end if
   end if

   let lr_ret.resultado = 1
   let lr_ret.mensagem  = ' '

   return lr_ret.*

end function

#---------------------------------------------------#
function cta02m01_reclamacoes(l_dptsgl, l_c24astcod)
#---------------------------------------------------#

define l_dptsgl       like isskfunc.dptsgl
      ,l_c24astcod    like datkassunto.c24astcod

define l_c24astagp         like datkassunto.c24astagp
define l_acesso            smallint

    if l_dptsgl    is null or
       l_c24astcod is null then
       error "Parametros incorretos (cta02m01_reclamacoes())"
       sleep 1
       return l_c24astcod
    end if


    if l_c24astcod = 'X50' then
       let l_c24astcod = 'Z00'
       return l_c24astcod
    end if

   #PSI 230650 - inicio
   # Buscar codigo de agrupamento
   select c24astagp into l_c24astagp
         from datkassunto
        where c24astcod = l_c24astcod
   #PSI 230650 - fim

    if l_c24astagp = 'W' or
       l_c24astagp = 'X' then
       
       call cta00m06_acionamento(l_dptsgl)
       returning l_acesso
       
       if l_acesso = true then
          if l_c24astcod <> 'W02' and
             l_c24astcod <> 'W04' and
             l_c24astcod <> 'W05' and
             l_c24astcod <> 'W06' and
             l_c24astcod <> 'W14' then
             let l_c24astcod = 'W00'
             return l_c24astcod
          end if
       else
       
          if l_c24astagp = 'W' then
             let l_c24astcod = 'X10'
          end if
       end if
    end if
    
    if l_c24astagp = 'ISA' then
    
         if l_c24astcod = 'I91' or
            l_c24astcod = 'I92' or   
            l_c24astcod = 'I93' or
            l_c24astcod = 'I94' or 
            l_c24astcod = 'I95' then
            
              let l_c24astcod = "I99" 
         end if
    
    end if
    
    if l_c24astagp = 'IRE' then
    
         if l_c24astcod = 'R93' or
            l_c24astcod = 'R94' or 
            l_c24astcod = 'R95' then            
              let l_c24astcod = "R99" 
         end if    
    end if

    return l_c24astcod
end function
