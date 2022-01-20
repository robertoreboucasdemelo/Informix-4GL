################################################################################
# Porto Seguro Cia Seguros Gerais                                      Nov/2010#
# .............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : cty05g07                                                     #
# Analista Resp.: Carla Rampazzo                                               #
# PSI           :                                                              #
# Objetivo      : Define e da Alertas sobre os Limites/Utilizacoes do HDK      #
# .............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor Fabrica  Origem    Alteracao                               #
# ----------  -------------- --------- ----------------------------------------#
#                                                                              #
################################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

database porto

 define m_viginc    like abbmdoc.viginc
 define m_vigfnl    like abbmdoc.vigfnl
 define m_data_calc like abbmdoc.vigfnl
 define m_clscod    char(03)
 define m_qtd_unica     integer
 define l_flg_lmt_unico smallint
#-----------------------------------------------------------------------------
function cty05g07_s66_s67(lr_param)
#-----------------------------------------------------------------------------

   define lr_param     record
          ramcod       like rsamseguro.ramcod
         ,succod       like abamapol.succod
         ,aplnumdig    like abamapol.aplnumdig
         ,itmnumdig    like abbmdoc.itmnumdig
         ,c24astcod    like datmligacao.c24astcod
   end record

   --> Controles de Atendimento - Help Desk
   define l_hdk        record
          re_s66       char(01) -- "S"/"N"--> Se tem direito ou nao (RE com LMI)
         ,re_s67       char(01) -- "S"/"N"--> Se tem direito ou nao (RE com LMI)
         ,sld_re_s66   char(01) -- "S"/"N"--> Se tem saldo (RE com LMI)
         ,sld_re_s67   char(01) -- "S"/"N"--> Se tem saldo (RE com LMI)
         ,qtd_lmt_s66  smallint           --> Limite Total (Auto/RE)
         ,qtd_lmt_s67  smallint           --> Limite Total (Auto/RE)
         ,qtd_lmt_s67_206  smallint           --> Limite Total (Auto/RE)
         ,qtd_utz_s66  smallint           --> Quantidade Utilizada (Auto/RE)
         ,qtd_utz_s67  smallint           --> Quantidade Utilizada (Auto/RE)
         ,qtd_utz_s67_206  smallint           --> Quantidade Utilizada (Auto/RE)
   end record

   define l_ret        record
          codigo       smallint
         ,mensagem     char(60)
   end record

   define l_flg_HDK smallint

   define l_cont       smallint
         ,l_qtd_lmt    smallint  --> Limite Total (Auto/RE)
         ,l_qtd_utz    smallint  --> Quantidade Utilizada (Auto/RE)
         ,l_qtd_lmt_206    smallint  --> Limite Total Conectividade
         ,l_qtd_utz_206    smallint  --> Quantidade Utilizada Conectividade
         ,l_sld_re     char(01)  --> Se tem Saldo (RE com LMI)
         ,l_usa_re     char(01)  --> Se Re Contratou Servico (RE com LMI)
         ,l_atende     char(01)  --> Se atende ou nao


   let m_qtd_unica = 0
   let l_cont    = null
   let l_qtd_lmt = null
   let l_qtd_utz = null
   let l_qtd_lmt_206 = null
   let l_qtd_utz_206 = null
   let l_sld_re  = null
   let l_usa_re  = null
   let l_atende  = null
   let l_flg_lmt_unico = 0
   let l_flg_HDK = 0

   initialize l_ret.*, l_hdk.*  to null

   #-----------------------------------------------------------
   --> Inicializar Variaveis Globais para controle do Help Desk
   #-----------------------------------------------------------
   initialize g_hdk.* to null

   let g_hdk.pode_s66 = "N" ---> Sera usada para direcionar o Fluxo do HDK
   let g_hdk.pode_s67 = "N" ---> Sera usada para direcionar o Fluxo do HDK
   let l_atende       = 2   ---> Bloqueia Atendimento

  if lr_param.c24astcod = 'HDK' then
     let l_flg_HDK = 1
  end if

  #-------------------------------------------------------
  --> Pega vigencia da Apolice
  #-------------------------------------------------------
      call cty05g07_pega_vigencia_apolice()
           returning m_viginc
                   , m_vigfnl
                   , m_data_calc
                   , m_clscod

   #----------------------------------------------------
   --> Verifica Limites e Utilizacoes para o S66 e o S67
   #----------------------------------------------------
   for l_cont  = 1 to 2

      if l_cont = 1 then
         let lr_param.c24astcod = "S66"
      else
         let lr_param.c24astcod = "S67"
      end if

      call cty05g06_limite_hdk(lr_param.ramcod
                              ,lr_param.succod
                              ,lr_param.aplnumdig
                              ,lr_param.itmnumdig
                              ,lr_param.c24astcod
                              ,m_viginc
                              ,l_flg_HDK)

      returning l_qtd_lmt
               ,l_qtd_utz
               ,l_qtd_lmt_206
               ,l_qtd_utz_206
               ,l_sld_re
               ,l_usa_re
               ,l_ret.codigo
               ,l_ret.mensagem

      if l_ret.codigo <> 0 then
         error l_ret.mensagem
         exit for
      end if

      if l_qtd_lmt is null then
         let l_qtd_lmt = 0
      end if

      if l_qtd_utz is null then
         let l_qtd_utz = 0
      end if
      if m_clscod <> '044' then
         let l_qtd_lmt_206 = null
      end if
      if l_qtd_lmt_206 is null and m_clscod = '044' then
         let l_qtd_lmt_206 = 0
      end if
      if l_qtd_utz_206 is null and m_clscod = '044' then
         let l_qtd_utz_206 = 0
      end if

      if l_sld_re is null or
         l_sld_re =  " "  then
         let l_sld_re = "N"
      end if

      if l_usa_re is null or
         l_usa_re =  " "  then
         let l_usa_re = "N"
      end if


    #--------------------------------------------------------------
     --> Para apolices a partir de 02/2011 o limite e verificado
     --> de forma unica tanto para ligacao como para visita.
    #--------------------------------------------------------------
      if  m_viginc >= '01/02/2011' and
          lr_param.ramcod = 531  and
	  m_clscod <> '044' and
	  m_clscod <> '44R' then
         let l_flg_lmt_unico = 1

         if lr_param.c24astcod = 'S66' then
            let l_hdk.qtd_lmt_s66 = l_qtd_lmt
            let l_hdk.qtd_utz_s66 = l_qtd_utz

            let m_qtd_unica = m_qtd_unica + l_hdk.qtd_utz_s66
        else
            let l_hdk.qtd_lmt_s67 = l_qtd_lmt
            let l_hdk.qtd_utz_s67 = l_qtd_utz
            let l_hdk.qtd_utz_s67 = l_qtd_utz
            let l_hdk.qtd_lmt_s67_206 = l_qtd_lmt_206  ##fornax set/2012
            let l_hdk.qtd_utz_s67_206 = l_qtd_utz_206  ##conectividade

            let m_qtd_unica = m_qtd_unica + l_hdk.qtd_utz_s67
        end if

        if m_qtd_unica < l_qtd_lmt or
	   l_hdk.qtd_utz_s67_206 < l_hdk.qtd_lmt_s67_206 then
            let g_hdk.pode_s66 = "S"
            let g_hdk.pode_s67 = "S"
            let l_atende = 1 ---> Libera Atendimento
        else
            let g_hdk.pode_s66 = "N"
            let g_hdk.pode_s67 = "N"
            let l_atende = 2 ---> Bloqueia Atendimento
        end if

      else
          #-----------------------------------------------
          --> Carrega Variaveis para Controle do Help Desk
          #-----------------------------------------------
          if lr_param.c24astcod = "S66" then

             let l_hdk.qtd_lmt_s66 = l_qtd_lmt
             let l_hdk.qtd_utz_s66 = l_qtd_utz
             let l_hdk.sld_re_s66  = l_sld_re
             let l_hdk.re_s66      = l_usa_re

             if (l_hdk.qtd_lmt_s66 > 0                 and
                 l_hdk.qtd_utz_s66 < l_hdk.qtd_lmt_s66     ) or
                (l_hdk.re_s66      = "S"               and
                 l_hdk.sld_re_s66  = "S"                   ) then

                let g_hdk.pode_s66 = "S"
                let l_atende = 1 ---> Libera Atendimento
             end if
          else

             let l_hdk.qtd_lmt_s67 = l_qtd_lmt
             let l_hdk.qtd_utz_s67 = l_qtd_utz
             let l_hdk.sld_re_s67  = l_sld_re
             let l_hdk.re_s67      = l_usa_re
             let l_hdk.qtd_lmt_s67_206 = l_qtd_lmt_206  ##fornax set/2012
             let l_hdk.qtd_utz_s67_206 = l_qtd_utz_206  ##conectividade

             if (l_hdk.qtd_lmt_s67 > 0                 and
                 l_hdk.qtd_utz_s67 < l_hdk.qtd_lmt_s67     ) or
                (l_hdk.re_s67      = "S"               and
                 l_hdk.sld_re_s67  = "S"                   ) then

                let g_hdk.pode_s67 = "S"
                let l_atende = 1 ---> Libera Atendimento
             end if
             if l_hdk.qtd_lmt_s67_206 > 0                 and  #fornax set/12
                l_hdk.qtd_utz_s67_206 < l_hdk.qtd_lmt_s67_206  then
                let g_hdk.pode_s67 = "S"
                let l_atende = 1 ---> Libera Atendimento
             end if
          end if

      end if

   end for

   #----------------------------------------------------
   --> Se ocorreu algum problema na apuracao dos Limites
   #----------------------------------------------------
   if l_ret.codigo <> 0 then

      let l_atende = 2 ---> Bloqueia Atendimento

      #-----------------------
      ---> Chamada pelo Portal
      #-----------------------
      if g_origem = 'WEB' then

         #------------------
         --> Limpa variaveis
         #------------------
         let l_hdk.qtd_lmt_s66 = 0
         let l_hdk.qtd_utz_s66 = 0
         let l_hdk.sld_re_s66  = "N"
         let l_hdk.re_s66      = "N"
         let g_hdk.pode_s66    = "N"

         let l_hdk.qtd_lmt_s67 = 0
         let l_hdk.qtd_utz_s67 = 0
         let l_hdk.qtd_lmt_s67_206 = 0
         let l_hdk.qtd_utz_s67_206 = 0
         let l_hdk.sld_re_s67  = "N"
         let l_hdk.re_s67      = "N"
         let g_hdk.pode_s67    = "N"

         return l_hdk.qtd_lmt_s66
	       ,l_hdk.qtd_utz_s66
	       ,l_hdk.qtd_lmt_s67
	       ,l_hdk.qtd_utz_s67
	       ,l_hdk.qtd_lmt_s67_206
	       ,l_hdk.qtd_utz_s67_206
	       ,g_hdk.pode_s67
	       ,g_hdk.pode_s66

      else
         let l_atende = 2 ---> Bloqueia Atendimento
         return l_atende
      end if
   else
      #-----------------------------------------
      --> Conseguiu apurar Limites e Utilizacoes
      #-----------------------------------------

      if g_origem = 'WEB' then

         return l_hdk.qtd_lmt_s66
	       ,l_hdk.qtd_utz_s66
	       ,l_hdk.qtd_lmt_s67
	       ,l_hdk.qtd_utz_s67
	       ,l_hdk.qtd_lmt_s67_206
	       ,l_hdk.qtd_utz_s67_206
	       ,g_hdk.pode_s67
	       ,g_hdk.pode_s66
      else
         #--------------------------------
         --> Mostra Alertas para Atendente
         #--------------------------------
         if l_flg_lmt_unico = 1 then
            call cty05g07_alerta_limite_unico(l_qtd_lmt
                                             ,l_hdk.qtd_utz_s66
                                             ,l_hdk.qtd_utz_s67
                                             ,l_hdk.qtd_lmt_s67_206
                                             ,l_hdk.qtd_utz_s67_206
                                             ,l_flg_HDK)
         else
            call cty05g07_alerta_hdk(l_hdk.*)
         end if

         return l_atende

      end if
   end if

end function

#-----------------------------------------------------------------------------
function cty05g07_alerta_limite_unico(l_qtd_lmt, l_qtd_utz_s66, l_qtd_utz_s67,
				      l_qtd_lmt_s67_206, l_qtd_utz_s67_206,
				      l_flg_HDK)
#-----------------------------------------------------------------------------
 define l_qtd_lmt  smallint
 define l_qtd_utz_s66 smallint
 define l_qtd_utz_s67 smallint
 define l_qtd_lmt_s67_206 smallint
 define l_qtd_utz_s67_206 smallint
 define l_flg_HDK  smallint

   define l_hdk        record
          re_s66       char(01) -- "S"/"N"--> Se tem direito ou nao (RE com LMI)
         ,re_s67       char(01) -- "S"/"N"--> Se tem direito ou nao (RE com LMI)
         ,sld_re_s66   char(01) -- "S"/"N"--> Se tem saldo (RE com LMI)
         ,sld_re_s67   char(01) -- "S"/"N"--> Se tem saldo (RE com LMI)
         ,qtd_lmt_s66  smallint           --> Limite Total (Auto/RE)
         ,qtd_lmt_s67  smallint           --> Limite Total (Auto/RE)
         ,qtd_lmt_s67_206  smallint           --> Limite Total (Auto/RE)
         ,qtd_utz_s66  smallint           --> Quantidade Utilizada (Auto/RE)
         ,qtd_utz_s67  smallint           --> Quantidade Utilizada (Auto/RE)
         ,qtd_utz_s67_206  smallint           --> Quantidade Utilizada (Auto/RE)
   end record

   define l_msg       record
          linha1      char(40)
         ,linha2      char(40)
         ,linha3      char(40)
         ,linha4      char(40)
         ,confirma    char(01)
         ,alerta      char(60)
   end record

   let l_hdk.re_s66       = ''
   let l_hdk.re_s67       = ''
   let l_hdk.sld_re_s66   = ''
   let l_hdk.sld_re_s67   = ''
   let l_hdk.qtd_lmt_s66  = l_qtd_lmt
   let l_hdk.qtd_lmt_s67  = ''
   let l_hdk.qtd_utz_s66  = l_qtd_utz_s66
   let l_hdk.qtd_utz_s67  = l_qtd_utz_s67
   let l_hdk.qtd_lmt_s67_206  = l_qtd_lmt_s67_206
   let l_hdk.qtd_utz_s67_206  = l_qtd_utz_s67_206

   let l_msg.linha1   = ''
   let l_msg.linha2   = ''
   let l_msg.linha3   = ''
   let l_msg.linha4   = ''
   let l_msg.confirma = ''
   let l_msg.alerta   = ''

   #-------------------------------------------
   --> Apolice Nao tem Direito a Help Desk Casa
   #-------------------------------------------
   if l_qtd_lmt = 0 then

      let l_msg.linha2  = "NAO E POSSIVEL REALIZAR O ATENDIMENTO."
      let l_msg.linha3  = "APOLICE SEM COBERTURA PARA ESTE SERVICO."

      call cts08g01 ("A","N"
                    ,l_msg.linha1 ,l_msg.linha2
                    ,l_msg.linha3 ,l_msg.linha4)
           returning l_msg.confirma

      return
   end if

   #----------------------------------------------------------
   --> Ja utilizou todos os Atendimentos (Telefonico e Visita)
   #----------------------------------------------------------
   ---> Apolice do Auto
   if m_qtd_unica >= l_qtd_lmt then

      let l_msg.alerta = "               LIMITES ESGOTADOS                "

      call cty05g07_hdk_input(l_hdk.*,l_msg.alerta)

      return
   end if

   #-------------------------------------------------------------
   --> Se Apolice tem disponiveis Atendimento Telefonico e Visita
   #-------------------------------------------------------------
   ---> Apolice do Auto que utiliza quantidade
    if m_qtd_unica < l_qtd_lmt or
       l_hdk.qtd_utz_s67_206 < l_hdk.qtd_lmt_s67_206 then

      let l_msg.alerta = "              LIMITES DISPONIVEIS                "

      call cty05g07_hdk_input(l_hdk.*,l_msg.alerta)

      return
   end if


end function

#-----------------------------------------------------------------------------
function cty05g07_alerta_hdk(l_hdk)
#-----------------------------------------------------------------------------

   --> Controles de Atendimento - Help Desk
   define l_hdk        record
          re_s66       char(01) -- "S"/"N"--> Se tem direito ou nao (RE com LMI)
         ,re_s67       char(01) -- "S"/"N"--> Se tem direito ou nao (RE com LMI)
         ,sld_re_s66   char(01) -- "S"/"N"--> Se tem saldo (RE com LMI)
         ,sld_re_s67   char(01) -- "S"/"N"--> Se tem saldo (RE com LMI)
         ,qtd_lmt_s66  smallint           --> Limite Total (Auto/RE)
         ,qtd_lmt_s67  smallint           --> Limite Total (Auto/RE)
         ,qtd_lmt_s67_206  smallint           --> Limite Total (Auto/RE)
         ,qtd_utz_s66  smallint           --> Quantidade Utilizada (Auto/RE)
         ,qtd_utz_s67  smallint           --> Quantidade Utilizada (Auto/RE)
         ,qtd_utz_s67_206  smallint           --> Quantidade Utilizada (Auto/RE)
   end record

   define l_msg       record
          linha1      char(40)
         ,linha2      char(40)
         ,linha3      char(40)
         ,linha4      char(40)
         ,confirma    char(01)
         ,alerta      char(60)
   end record


   initialize l_msg.* to null

   #-------------------------------------------
   --> Apolice Nao tem Direito a Help Desk Casa
   #-------------------------------------------
   if l_hdk.qtd_lmt_s66 = 0   and
      l_hdk.qtd_lmt_s67 = 0   and
      l_hdk.re_s66      = "N" and
      l_hdk.re_s67      = "N" then

      let l_msg.linha2  = "NAO E POSSIVEL REALIZAR O ATENDIMENTO."
      let l_msg.linha3  = "APOLICE SEM COBERTURA PARA ESTE SERVICO."

      call cts08g01 ("A","N"
                    ,l_msg.linha1 ,l_msg.linha2
                    ,l_msg.linha3 ,l_msg.linha4)
           returning l_msg.confirma

      return
   end if


   #----------------------------------------------------------
   --> Ja utilizou todos os Atendimentos (Telefonico e Visita)
   #----------------------------------------------------------
   ---> Apolice do Auto ou RE sem LMI
   if (l_hdk.qtd_lmt_s66 > 0                  or
       l_hdk.qtd_lmt_s67 > 0                      ) and
      (l_hdk.qtd_lmt_s66 <= l_hdk.qtd_utz_s66 and
       l_hdk.qtd_lmt_s67 <= l_hdk.qtd_utz_s67 and
       l_hdk.qtd_lmt_s67_206 <= l_hdk.qtd_utz_s67_206 ) then

      let l_msg.alerta = "               LIMITES ESGOTADOS                "

      call cty05g07_hdk_input(l_hdk.*,l_msg.alerta)

      return
   end if

   ---> Apolice de RE com LMI
   if (l_hdk.re_s66     = "S"  or
       l_hdk.re_s67     = "S"      )    and
      (l_hdk.sld_re_s66 = "N"  and
       l_hdk.sld_re_s67 = "N"      )    then


      let l_msg.linha2 = "APOLICE NAO POSSUI MAIS SALDO (LMI)"
      let l_msg.linha3 = "PARA ABERTURA DESTE SERVICO."

      call cts08g01 ("A","N"
                    ,l_msg.linha1 ,l_msg.linha2
                    ,l_msg.linha3 ,l_msg.linha4)
           returning l_msg.confirma

      return
   end if


   #-------------------------------------------------------
   --> Apolice tem Direito apenas ao Atendimento Presencial
   #-------------------------------------------------------
   if g_hdk.pode_s66 = "N" and
      g_hdk.pode_s67 = "S" and
      l_hdk.qtd_lmt_s67_206 = 0 then

      ---> Apolice do Auto ou RE sem LMI
      if l_hdk.qtd_lmt_s67 > 0 then

         let l_msg.alerta = "         SOMENTE ATENDIMENTO PRESENCIAL          "

         call cty05g07_hdk_input(l_hdk.*,l_msg.alerta)

         return
      end if

      ---> Apolice de RE com LMI
      if l_hdk.re_s66 = "N" then

         let l_msg.linha2 = "APOLICE NAO TEM DIREITO AO SERVICO"
         let l_msg.linha3 = "DE ATENDIMENTO TELEFONICO."

         call cts08g01 ("A","N"
                       ,l_msg.linha1 ,l_msg.linha2
                       ,l_msg.linha3 ,l_msg.linha4)
              returning l_msg.confirma

         return
      end if
   end if


   #-------------------------------------------------------
   --> Apolice tem Direito apenas ao Atendimento Telefonico
   #-------------------------------------------------------
   if g_hdk.pode_s66 = "S" and
      g_hdk.pode_s67 = "N" then


      ---> Apolice do Auto ou RE sem LMI
      if l_hdk.qtd_lmt_s66 > 0 then

         let l_msg.alerta = "         SOMENTE ATENDIMENTO TELEFONICO          "

         call cty05g07_hdk_input(l_hdk.*,l_msg.alerta)

         return
      end if

      ---> Apolice de RE com LMI
      if l_hdk.re_s67 = "N" then

         let l_msg.linha2 = "APOLICE NAO TEM DIREITO AO SERVICO"
         let l_msg.linha3 = "DE ATENDIMENTO PRESENCIAL."

         call cts08g01 ("A","N"
                       ,l_msg.linha1 ,l_msg.linha2
                       ,l_msg.linha3 ,l_msg.linha4)
              returning l_msg.confirma

         return
      end if
   end if

   #------------------------------------------------------- #fornax set/2012
   --> Apolice tem Direito apenas a Conectividade
   #-------------------------------------------------------
   if g_hdk.pode_s66 = "N" and
      g_hdk.pode_s67 = "S" and
      l_hdk.qtd_lmt_s67_206 > 0 then

      let l_msg.alerta = "         SOMENTE CONECTIVIDADE                   "
      call cty05g07_hdk_input(l_hdk.*,l_msg.alerta)
      return
   end if
   #-------------------------------------------------------------
   --> Se Apolice tem disponiveis Atendimento Telefonico e Visita
   #-------------------------------------------------------------
   ---> Apolice do Auto ou RE que utiliza quantidade
   if l_hdk.qtd_lmt_s66 > 0 or
      l_hdk.qtd_lmt_s67 > 0 or
      l_hdk.qtd_lmt_s67_206 > 0 then

      let l_msg.alerta = "              LIMITES DISPONIVEIS                "

      call cty05g07_hdk_input(l_hdk.*,l_msg.alerta)

      return
   end if

   ---> Apolice de RE com LMI
   if l_hdk.re_s66     = "S" and
      l_hdk.re_s67     = "S" and
      l_hdk.sld_re_s66 = "S" and
      l_hdk.sld_re_s67 = "S" then

      let l_msg.linha2 = "APOLICE CONTRATOU SERVICO DE"
      let l_msg.linha3 = "ATENDIMENTO PRESENCIAL E TELEFONICO."

      call cts08g01 ("A","N"
                    ,l_msg.linha1 ,l_msg.linha2
                    ,l_msg.linha3 ,l_msg.linha4)
           returning l_msg.confirma

      return
   end if

end function

#-----------------------------------------------------------------------------
function cty05g07_hdk_input(l_hdk)
#-----------------------------------------------------------------------------

   --> Controles de Atendimento - Help Desk
   define l_hdk        record
          re_s66       char(01) -- "S"/"N"--> Se tem direito ou nao (RE com LMI)
         ,re_s67       char(01) -- "S"/"N"--> Se tem direito ou nao (RE com LMI)
         ,sld_re_s66   char(01) -- "S"/"N"--> Se tem saldo (RE com LMI)
         ,sld_re_s67   char(01) -- "S"/"N"--> Se tem saldo (RE com LMI)
         ,qtd_lmt_s66  smallint           --> Limite Total (Auto/RE)
         ,qtd_lmt_s67  smallint           --> Limite Total (Auto/RE)
         ,qtd_lmt_s67_206  smallint           --> Limite Total (Auto/RE)
         ,qtd_utz_s66  smallint           --> Quantidade Utilizada (Auto/RE)
         ,qtd_utz_s67  smallint           --> Quantidade Utilizada (Auto/RE)
         ,qtd_utz_s67_206  smallint           --> Quantidade Utilizada (Auto/RE)
         ,texto        char(60)
   end record

   define l_msg record
          limite_msg       char(6)
        , limite_msg_conect char(13)
        , limite_unico_msg char(25)
        , limite_unico_qtd smallint
   end record


   define l_descanso   smallint

   initialize l_msg.* to null
   let l_descanso = null
   let l_msg.limite_msg = 'Limite'
   let l_msg.limite_unico_qtd = ''

   open window cty05g07 at 07,17 with form "cty05g07"
	attribute (form line 1, border)

  if l_flg_lmt_unico = 1 then
     let l_msg.limite_msg = ''
     let l_msg.limite_unico_msg = 'LIMITE UNICO PARA AMBOS '
     let l_msg.limite_unico_qtd = l_hdk.qtd_lmt_s66
     let l_hdk.qtd_lmt_s66 = ''
  end if

  if l_hdk.qtd_lmt_s67_206 > 0 then
     let l_msg.limite_msg = 'Limite'
     let l_msg.limite_msg_conect = 'CONECTIVIDADE'
  else
     let l_hdk.qtd_utz_s67_206 = null
  end if
   display by name l_hdk.qtd_utz_s66
                  ,l_hdk.qtd_lmt_s66
                  ,l_hdk.qtd_utz_s67
                  ,l_hdk.qtd_lmt_s67
                  ,l_msg.limite_msg
                  ,l_msg.limite_unico_msg
                  ,l_msg.limite_unico_qtd
                  ,l_msg.limite_msg_conect
                  ,l_hdk.qtd_utz_s67_206
                  ,l_hdk.qtd_lmt_s67_206
   display by name l_hdk.texto        attribute (reverse)


   input by name l_descanso

   before field l_descanso
      display by name l_descanso


   after  field l_descanso
      display by name l_descanso


      on key (interrupt,control-c)
         exit input

   end input

   let int_flag = false

   close window cty05g07


end function


#===============================================================================
function cty05g07_pega_vigencia_apolice()
#===============================================================================
define l_viginc    like abbmdoc.viginc
define l_vigfnl    like abbmdoc.vigfnl
define l_codigo    smallint
define l_clscod_doc char(03)
define l_data_calculo date
define l_flag_endosso char(1)

let l_codigo    = 0
let l_clscod_doc = ''
let l_data_calculo = ''
let l_flag_endosso = 'N'
 let l_viginc = today
 let l_vigfnl = today

 select viginc, vigfnl
   into l_viginc, l_vigfnl
   from abamapol
  where abamapol.succod    = g_documento.succod
    and abamapol.aplnumdig = g_documento.aplnumdig

 ## obter data de calculo
 call faemc144_clausula(g_documento.succod
		       ,g_documento.aplnumdig
		       ,g_documento.itmnumdig)
      returning l_codigo ,l_clscod_doc
               ,l_data_calculo ,l_flag_endosso
 if l_clscod_doc is null then
    call cty26g01_clausula(g_documento.succod
		       ,g_documento.aplnumdig
		       ,g_documento.itmnumdig)
      returning l_codigo ,l_clscod_doc
               ,l_data_calculo ,l_flag_endosso
 end if
 return l_viginc
      , l_vigfnl
      , l_data_calculo
      , l_clscod_doc

end function