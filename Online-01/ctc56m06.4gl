###########################################################################
# Nome do Modulo: CTC56M00                                           Raji #
#                                                                         #
# Manutencao no Cadastro de textos para clausulas                Fev/2002 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONS. DESCRICAO                             #
# 16/011/2006 Ligia        PSI 205206 ciaempcod                           #
#-------------------------------------------------------------------------#
# 20/08/2007  Alinne, Meta PSI211915 Inclusao de Union na entidade        #
#                                    rgfkmrsapccls                        #
#-------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl" 

define m_ctc56m06_prep smallint

#-------------------------#
function ctc56m06_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select distinct clsdes ",
                " from aackcls ",
               " where ramcod = ? ",
                 " and clscod = ? "

  prepare pctc56m06001 from l_sql
  declare cctc56m06001 cursor for pctc56m06001

  let m_ctc56m06_prep = true

end function

function ctc56m06_clsdes(l_ciaempcod, l_ramgrpcod, l_ramcod, 
			 l_clscod, l_rmemdlcod)

   define l_ciaempcod like datkclstxt.ciaempcod,
          l_ramgrpcod like gtakram.ramgrpcod,
          l_ramcod    like gtakram.ramcod,
          l_rmemdlcod like rgfkclaus2.rmemdlcod,
          l_clscod    like datkclstxt.clscod,
          l_clsdes    like aackcls.clsdes,
          l_status    smallint,
          l_msg       char(20), 
          l_grlchv    like datkgeral.grlchv,
          l_plnatnlimnum smallint

    if m_ctc56m06_prep is null or
      m_ctc56m06_prep <> true then
      call ctc56m06_prepare()
   end if 

   ## Empresa Porto
   if l_ciaempcod = 1  or   ## psi 205206
      l_ciaempcod = 50 then ## ---> Saude 
 
      if l_ramgrpcod = 1 then ## Auto
   
         # -> BUSCA A DESCRICAO DA CLAUSULA
         open cctc56m06001 using l_ramcod, l_clscod
         let l_clsdes = null
         fetch cctc56m06001 into l_clsdes
         close cctc56m06001
   
      else
         if l_ramgrpcod = 5 then ## Saude
            let l_clsdes = null
            let l_plnatnlimnum = null
   
            call cta01m16_sel_datkplnsau(l_clscod )
                 returning l_status, l_msg, l_clsdes, l_plnatnlimnum 
         else
            let l_clsdes = null
            declare c_rgfkclaus2 cursor for
               select distinct clsdes
                 into l_clsdes
                 from rgfkclaus2
                where clscod = l_clscod
                  and ramcod = l_ramcod
                  and rmemdlcod = l_rmemdlcod
               union
               select distinct clsdes
                 from rgfkmrsapccls
                where clscod    = l_clscod
                  and ramcod    = l_ramcod
                  and rmemdlcod = l_rmemdlcod
   
            open  c_rgfkclaus2
            fetch c_rgfkclaus2 into l_clsdes
            close c_rgfkclaus2
         end if
      end if
   
   else
      if l_ciaempcod = 35 then #Empresa Azul
         ## obter descricao da clausula da azul 
         let l_grlchv =  "CLS.AZUL.", l_clscod
         select grlinf  into l_clsdes
          from datkgeral
         where grlchv = l_grlchv
      end if
   end if

   return l_clsdes
  
end function
