###############################################################################
# Nome do Modulo: CTA02M06                                           Gilberto #
#                                                                     Marcelo #
# Checa permissao de utilizacao do codigo de assunto                 Fev/1996 #
###############################################################################

database porto

#-------------------------------------------------------------------------
function  cta02m06(par_ramcod, par_c24astcod)
#-------------------------------------------------------------------------
define par_ramcod     like datrclassassunto.ramcod
define par_c24astcod  like datrclassassunto.c24astcod

define d_cta02m06     record
   permite            char(01)                       ,
   ramcod             like datrclassassunto.ramcod   ,
   astrgrcod          like datrclassassunto.astrgrcod
end record



	initialize  d_cta02m06.*  to  null

if par_ramcod     is null   or
   par_c24astcod  is null   then
   return "s"
end if

declare c_cta02m06_001   cursor for
   select ramcod, astrgrcod
     from datrclassassunto
    where c24astcod = par_c24astcod

let d_cta02m06.astrgrcod = 0
let d_cta02m06.permite   = " "

foreach c_cta02m06_001  into  d_cta02m06.ramcod, d_cta02m06.astrgrcod
   if d_cta02m06.ramcod  =  par_ramcod   then
      if d_cta02m06.astrgrcod  =  2    then     ####  ramo e' excecao
         let d_cta02m06.permite = "n"
         exit foreach
      else
         if d_cta02m06.astrgrcod  =  1    then  ####  ramo e' regra
            let d_cta02m06.permite = "s"
            exit foreach
         end if
      end if
   end if
end foreach

if d_cta02m06.permite = " "   then
   if d_cta02m06.astrgrcod  <>  0    then    #-->  possui regra ou excecao
      if d_cta02m06.astrgrcod  =  1   then   #-->  outros ramos sao regras
         let d_cta02m06.permite = "n"
      else
         let d_cta02m06.permite = "s"        #-->  outros ramos sao excecao
      end if
   else
      let d_cta02m06.permite = "s"           #-->  nao possui restricao
   end if
end if

return d_cta02m06.permite

end function   ###----- cta02m06
