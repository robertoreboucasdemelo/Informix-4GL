#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty05g02.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 190080                                                     #
#                 Consiste o limite de utilizacao para o Servico Emergencial #
#                 a Residencia                                               #
#............................................................................#
# Desenvolvimento: Meta, Daniel                                              #
# Liberacao      : 24/01/2005                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 21/09/06   Ligia Mattge      PSI 202720 Implementar cartao Saude para      #
#                                         cta02m15_qtd_serv_residencia       #
#----------------------------------------------------------------------------#
# 18/09/2008  Nilo                 221635 Agendamento de Servicos a Residencia#
#                                         Portal do Segurado                 #
#----------------------------------------------------------------------------#
# 13/03/2012 Johnny Alves                 Inclusao da clausula "047" para    #
#            BizTalking                   servico "S60" poder abrir varios   #
#                                         servicos.                          #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------
function cty05g02_envio_socorro(lr_param)
#-------------------------------------------------------

 define lr_param             record
     ramcod                  smallint
    ,succod                  like abbmitem.succod
    ,aplnumdig               like abbmitem.aplnumdig
    ,itmnumdig               like abbmitem.itmnumdig
 end record

 define lr_cty05g01         record
     resultado              char(01)
    ,dctnumseg              decimal(4,0)
    ,vclsitatu              decimal(4,0)
    ,autsitatu              decimal(4,0)
    ,dmtsitatu              decimal(4,0)
    ,dpssitatu              decimal(4,0)
    ,appsitatu              decimal(4,0)
    ,vidsitatu              decimal(4,0)
 end record

 define l_cod_erro          smallint
 define l_data_calculo      date
 define l_clscod            char(05)
 define l_flag_endosso      char(01)

 define l_flag_limite       char(1)
 define l_resultado         integer
 define l_mensagem          char(80)

 define l_vlclicnum         like abbmveic.vcllicnum
 define l_vclchsinc         like abbmveic.vclchsinc
 define l_vclchsfnl         like abbmveic.vclchsfnl
 define l_vclanofbc         like abbmveic.vclanofbc
 define l_anocalc           integer

 define l_qtde_at_ap        integer
 define l_qtde_at_pr        integer
 define l_qtd_atendimento   integer

 define l_prporgpcp         like abamdoc.prporgpcp
 define l_prpnumpcp         like abamdoc.prpnumpcp
 define l_prporg            like datrligprp.prporg
 define l_prpnumdig         like datrligprp.prpnumdig
 define l_vclcoddig         like abbmveic.vclcoddig


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_cod_erro  =  null
	let	l_data_calculo  =  null
	let	l_clscod  =  null
	let	l_flag_endosso  =  null
	let	l_flag_limite  =  null
	let	l_resultado  =  null
	let	l_mensagem  =  null
	let	l_vlclicnum  =  null
	let	l_vclchsinc  =  null
	let	l_vclchsfnl  =  null
	let	l_vclanofbc  =  null
	let	l_anocalc  =  null
	let	l_qtde_at_ap  =  null
	let	l_qtde_at_pr  =  null
	let	l_qtd_atendimento  =  null
	let	l_prporgpcp  =  null
	let	l_prpnumpcp  =  null
	let	l_prporg  =  null
	let	l_prpnumdig  =  null
	let     l_vclcoddig  = null


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  lr_cty05g01.*  to  null

 initialize lr_cty05g01 to null

 let l_cod_erro        = null
 let l_data_calculo    = null
 let l_clscod          = null
 let l_flag_endosso    = null
 let l_flag_limite     = null
 let l_resultado       = null
 let l_mensagem        = null
 let l_vlclicnum       = null
 let l_vclchsinc       = null
 let l_vclchsfnl       = null
 let l_vclanofbc       = null
 let l_anocalc         = null
 let l_qtde_at_ap      = 0
 let l_qtde_at_pr      = 0
 let l_qtd_atendimento = 0
 let l_prporgpcp       = null
 let l_prpnumpcp       = null
 let l_prporg          = null
 let l_prpnumdig       = null

 #Obter data de calculo e clausula 034, 34A   ou 35A
 call faemc144_clausula(lr_param.succod,
                        lr_param.aplnumdig,
                        lr_param.itmnumdig)
              returning l_cod_erro,
                        l_clscod,
                        l_data_calculo,
                        l_flag_endosso
 if l_cod_erro <> 0 then
    let l_flag_limite = "N"
    let l_resultado = 2
    let l_mensagem =  "Erro no acesso a funcao faemc144."
    return l_resultado,l_mensagem,l_flag_limite
 end if

#display "*** apolice = ",lr_param.succod," ",lr_param.aplnumdig," ",lr_param.itmnumdig
#display "*** retorno = ",l_clscod," ",l_data_calculo," ",l_flag_endosso

 # Manter regras para data de calculo anterior a 01/08/04
 if l_data_calculo <  '01/08/2004'  then
    # Obter a ultima situacao da apolice
    call cty05g01_ultsit_apolice(lr_param.succod,
                                 lr_param.aplnumdig,
                                 lr_param.itmnumdig)
       returning lr_cty05g01.*

    if lr_cty05g01.resultado <> "O"  then
       let l_resultado = 2
       let l_mensagem = " Ultima situacao da apolice nao encontrada. AVISE A INFORMATICA!"
       let l_flag_limite = "N"
       return l_resultado,l_mensagem,l_flag_limite
    end if

    #Obter o ano de fabricacao do veiculo
    call cty05g00_dados_veic(lr_param.succod,
                             lr_param.aplnumdig,
                             lr_param.itmnumdig,
                             lr_cty05g01.vclsitatu)
         returning l_resultado,
                   l_mensagem,
                   l_vlclicnum,
                   l_vclchsinc,
                   l_vclchsfnl,
                   l_vclanofbc,
                   l_vclcoddig

    if l_resultado <> 1 or
       l_vclanofbc is null then
       let l_flag_limite = "N"
       return l_resultado,l_mensagem,l_flag_limite
    end if

    # Nao tem limite para veiculos com menos de 5 anos de fabricacao
    let l_anocalc = year(l_data_calculo) - year(l_vclanofbc)
    if l_anocalc < 5 then
       let l_resultado  = 1
       let l_mensagem = null
       let l_flag_limite = "N"
       return l_resultado,l_mensagem,l_flag_limite
    end if
 end if

 # Obter a quantidade de atendimentos de envio de socorro
 let l_qtde_at_ap = cta02m15_qtd_envio_socorro(lr_param.ramcod
                                              ,lr_param.succod
                                              ,lr_param.aplnumdig
                                              ,lr_param.itmnumdig,"",""
                                              ,l_data_calculo)

 # Se nao tem endosso, contar os servicos realizados pela proposta
 if l_flag_endosso = "N" then
    # Obter proposta original atraves da apolice
    call cty05g00_prp_apolice(lr_param.succod,lr_param.aplnumdig, 0)
       returning l_resultado,l_mensagem,l_prporgpcp,l_prpnumpcp

    if l_resultado <> 1 then
       let l_flag_limite = "N"
       return l_resultado,l_mensagem,l_flag_limite
    end if
    let l_qtde_at_pr = cta02m15_qtd_envio_socorro("",
                                                  "",
                                                  "",
                                                  "",
                                                  l_prporgpcp,
                                                  l_prpnumpcp,
                                                  l_data_calculo)
 end if
 let l_qtd_atendimento = l_qtde_at_ap + l_qtde_at_pr
 let l_resultado = 1
 let l_mensagem  = null
 
 # Limitar 5 atendimentos para apolices com clausula 34 ou 34A
 # na tarifa de 01/08/2004
 if l_data_calculo  >= '01/08/2004'  then
    if l_data_calculo < "01/07/2006" then  # circular 310 da susep
       if (l_clscod = '034'       or
           l_clscod = '34A')      and
           l_qtd_atendimento >= 5 then
           let l_flag_limite = "S"  # ultrapassou o limite
       else
           let l_flag_limite = "N"  # sem limite
       end if
    else
       if l_clscod = "034"       and
          l_qtd_atendimento >= 5 then
          let l_flag_limite = "S"   # ultrapassou o limite
       else
          # considerar o limite para clausula 35R - Judite 20/07
          if (l_clscod = "35R" or l_clscod = "33R" ) or 
             (l_clscod = "46R" or l_clscod = "47R" ) and # Tarifa Dazembro/Janeiro
             l_qtd_atendimento >= 3 then
             let l_flag_limite = "S"   # ultrapassou o limite
          else
             let l_flag_limite = "N"   # sem limite
          end if
       end if
    end if
 else
    if l_qtd_atendimento >= 3 then
       let l_flag_limite = "S"  # ultrapassou o limite
    else
       let l_flag_limite = "N"  # sem limite
    end if
 end if

 return l_resultado,l_mensagem,l_flag_limite

end function

#-------------------------------------------------------
function cty05g02_serv_residencia(lr_param)
#-------------------------------------------------------

 define lr_param    record
    ramcod          smallint
   ,succod          like abbmitem.succod
   ,aplnumdig       like abbmitem.aplnumdig
   ,itmnumdig       like abbmitem.itmnumdig
   ,c24astcod       like datmligacao.c24astcod
   ,bnfnum          like datrsrvsau.bnfnum
   ,crtsaunum       like datksegsau.crtsaunum
 end record

 define l_cod_erro          smallint
 define l_data_calculo      date
 define l_clscod            char(03)
 define l_flag_endosso      char(01)
 define l_plncod            like datkplnsau.plncod
 define l_plndes            like datkplnsau.plndes

 define l_flag_limite       char(1)
 define l_flag              char(1)
 define l_resultado         integer
 define l_mensagem          char(80)
 define l_datac             char(10)

 define l_qtd_limite        integer
 define l_qtde_at_ap        integer
 define l_qtde_at_pr        integer
 define l_qtd_atendimento   integer
 define l_nulo              char (1)
 define l_assunto_ant       char (3)

 define l_prporgpcp         like abamdoc.prporgpcp
 define l_prpnumpcp         like abamdoc.prpnumpcp

 define l_prporg            like datrligprp.prporg
 define l_prpnumdig         like datrligprp.prpnumdig

 define l_qtd_bas, l_qtd_bra, l_qtd_re integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_cod_erro  =  null
	let	l_data_calculo  =  null
	let	l_clscod  =  null
	let	l_flag_endosso  =  null
	let	l_plncod  =  null
	let	l_plndes  =  null
	let	l_flag_limite  =  null
	let	l_flag     =  null	
	let	l_resultado  =  null
	let	l_mensagem  =  null
	let	l_datac  =  null
	let	l_qtd_limite  =  null
	let	l_qtde_at_ap  =  null
	let	l_qtde_at_pr  =  null
	let	l_qtd_atendimento  =  null
	let	l_nulo  =  null
	let	l_prporgpcp  =  null
	let	l_prpnumpcp  =  null
	let	l_prporg  =  null
	let	l_prpnumdig  =  null

 let l_cod_erro        = null
 let l_data_calculo    = null
 let l_clscod          = null
 let l_flag_endosso    = "X"
 let l_flag_limite     = null
 let l_resultado       = null
 let l_mensagem        = null
 let l_qtd_limite      = 0
 let l_qtde_at_ap      = 0
 let l_qtde_at_pr      = 0
 let l_qtd_atendimento = 0
 let l_prporgpcp       = null
 let l_prpnumpcp       = null
 let l_prporg          = null
 let l_prpnumdig       = null
 let l_plncod          = null
 let l_plndes          = null
 let l_datac           = null
 let l_nulo            = null
 let l_flag_limite     = "N"
 let l_qtd_bas         = 0
 let l_qtd_bra         = 0
 let l_qtd_re          = 0

 ### PSI 202720
 if lr_param.bnfnum is not null then ##Saude
    ## Obter o plano para contagem dos servicos

    call cta01m15_sel_datksegsau(4, lr_param.crtsaunum, l_nulo,l_nulo,l_nulo)
         returning l_resultado,
                   l_mensagem,
                   l_plncod, l_data_calculo

    let l_datac = '01/01/', year(today) using "####"
    let l_data_calculo = l_datac

    ## obter o limite de utilizacao do plano
    call cta01m16_sel_datkplnsau(l_plncod)
         returning l_resultado, l_mensagem, l_plndes, l_qtd_limite
 else

    # Obter data de calculo e clausula 034, 34A   ou 35A
    
    call faemc144_clausula(lr_param.succod,
                           lr_param.aplnumdig,
                           lr_param.itmnumdig)
         returning l_cod_erro,
                   l_clscod,
                   l_data_calculo,
                   l_flag_endosso

    if l_cod_erro <> 0 then
       let l_flag_limite = "N"
       let l_resultado = 2
       let l_mensagem =  "Erro no acesso a funcao faemc144_cluasula."
       return l_resultado,l_mensagem,l_flag_limite,l_qtd_atendimento,l_qtd_limite
    end if

    if l_clscod = "033" or
       l_clscod = "047" then #Johnny,Biz
        let l_resultado = 1
        let l_mensagem = null
        let l_flag_limite = "N"     -- Inclusão de Clausula

        ---> PSI - 221635
        if g_origem = 'WEB' then
           let l_qtd_atendimento = null
           let l_qtd_limite = null
           return l_resultado,l_mensagem,l_flag_limite, 
                  l_qtd_atendimento,l_qtd_limite
        else
           let l_qtd_atendimento = 0
           let l_qtd_limite = 0
        end if

    end if

    if l_clscod = "033" or l_clscod[1,2] = "33" or
       l_clscod = "047" or l_clscod[1,2] = "47" then
        if lr_param.c24astcod = "S60" or
           lr_param.c24astcod = "S63" then
           return l_resultado,l_mensagem,l_flag_limite, 
                  l_qtd_atendimento,l_qtd_limite
        end if
    end if

    if l_data_calculo < "01/07/2006" then   # circular 310 susep
       if l_clscod <> '34A' and
          l_clscod <> '35A' then
          let l_resultado = 2
          let l_mensagem ="Apolice sem clausula de servico emergencial contratada."
          return l_resultado,
                 l_mensagem,
                 l_flag_limite,
                 l_qtd_atendimento,
                 l_qtd_limite
       end if
    else
       if lr_param.c24astcod = 'S60' then
           if l_clscod <> "033" and 
              l_clscod <> "034" and
              l_clscod <> "035" and
              l_clscod <> "35"  and
              l_clscod <> "35R" and
              l_clscod <> "33R" and 
              l_clscod <> "046" and 
              l_clscod <> "047" and 
              l_clscod <> "46R" and 
              l_clscod <> "47R" then          
              let l_resultado = 2
              let l_mensagem ="Apolice sem clausula de servico emergencial contratada!"
              return l_resultado,
                     l_mensagem,
                     l_flag_limite,
                     l_qtd_atendimento,
                     l_qtd_limite
           end if 
        else 
           if l_clscod <> "033" and 
                 l_clscod <> "034" and
                 l_clscod <> "035" and
                 l_clscod <> "35"  and
                 l_clscod <> "35R" and
                 l_clscod <> "33R" and               
                 l_clscod <> "047" and               
                 l_clscod <> "47R" then          
                 let l_resultado = 2
                 let l_mensagem ="Clausula contratada sem direito a servicos de linha branca"
                 return l_resultado,
                        l_mensagem,
                        l_flag_limite,
                        l_qtd_atendimento,
                        l_qtd_limite
           end if                 
        end if               
    end if
 end if
                               
 if lr_param.c24astcod = "S60" or 
    lr_param.c24astcod = "S63" then
    #Obter a quantidade limite de utilizacao de acord com a tarifa
    if l_data_calculo < '01/07/2003' then
       let l_qtd_limite = 4
    else
       if l_clscod = '046' and 
          lr_param.c24astcod = 'S63' then 
          let l_qtd_limite = 0
       else                                                                     
          let l_qtd_limite = 3
       end if     
    end if
    call framo705_qtd_servicos(l_clscod, 
                               lr_param.succod,
                               lr_param.ramcod, 
                               lr_param.aplnumdig)
         returning l_qtd_bas, l_qtd_bra
    if l_qtd_bas is null then
       let l_qtd_bas = 0
    end if
    if l_qtd_bra is null then
       let l_qtd_bra = 0
    end if
    if lr_param.c24astcod = "S60" then
       let l_qtd_limite = l_qtd_limite +  l_qtd_bas
    end if 
    if lr_param.c24astcod = "S63" then
       let l_qtd_limite = l_qtd_limite +  l_qtd_bra
    end if 
 else
    call cty05g02_qtd_re(l_clscod) returning l_qtd_re
    if lr_param.c24astcod = "S41" or lr_param.c24astcod = "S42" then
       let l_qtd_limite = l_qtd_limite + l_qtd_re
       call framo705_qtd_servicos(l_clscod,          
                                  lr_param.succod,   
                                  lr_param.ramcod,   
                                  lr_param.aplnumdig)
               returning l_qtd_bas, l_qtd_bra           
         if l_qtd_bas is null then
            let l_qtd_bas = 0
    end if
         if l_qtd_bra is null then
            let l_qtd_bra = 0
 end if
         if lr_param.c24astcod = "S41" then                                       
            let l_qtd_limite = l_qtd_limite +  l_qtd_bas  
         end if                                           
         if lr_param.c24astcod = "S42" then               
            let l_qtd_limite = l_qtd_limite +  l_qtd_bra  
         end if                                                  
    end if
 end if
 #Obter a quantidade de atendimentos de servico a residencia
 call cty05g02_qtd_srv_res(lr_param.ramcod     ## ligia - fornax - 03/01/2012
                                                ,lr_param.succod
                                                ,lr_param.aplnumdig
                                                ,lr_param.itmnumdig
                                                ,l_data_calculo
                                                ,lr_param.c24astcod
                          ,lr_param.bnfnum 

                          ,l_flag_endosso)
      returning l_resultado, l_mensagem, l_qtd_atendimento

    if l_resultado <> 1 then
       let l_flag_limite = "N"
       return l_resultado,
              l_mensagem,
              l_flag_limite,
              l_qtd_atendimento,
              l_qtd_limite
    end if
    
 if l_qtd_atendimento >= l_qtd_limite then
    let l_flag_limite = "S"
 end if
 if l_flag_limite = "N" and  
   (lr_param.c24astcod = "S41" or 
    lr_param.c24astcod = "S42" ) then 
      call cty05g02_qtd_servicos(lr_param.ramcod    
                                ,lr_param.succod    
                                ,lr_param.aplnumdig 
                                ,lr_param.itmnumdig 
                                ,l_data_calculo     
                                ,lr_param.c24astcod 
                                ,lr_param.bnfnum    
                                ,l_flag_endosso
                                ,l_qtd_limite)    
             returning l_flag_limite 
 end if 
 return l_resultado,l_mensagem,l_flag_limite,l_qtd_atendimento,l_qtd_limite
end function
#######################################################################3
function cty05g02_qtd_srv_res(lr_param)
 define lr_param       record
        ramcod         smallint
       ,succod         like abbmitem.succod
       ,aplnumdig      like abbmitem.aplnumdig
       ,itmnumdig      like abbmitem.itmnumdig
       ,data_calculo   date
       ,c24astcod      like datmligacao.c24astcod
       ,bnfnum         like datrsrvsau.bnfnum
       ,flag_endosso   char(1)
 end record
 define l_resultado         integer
 define l_mensagem          char(80)
 define l_prporgpcp         like abamdoc.prporgpcp
 define l_prpnumpcp         like abamdoc.prpnumpcp
 define l_qtde_at_ap        integer
 define l_qtde_at_pr        integer
 define l_qtd_atendimento   integer
 let l_qtde_at_ap      = 0
 let l_qtde_at_pr      = 0
 let l_qtd_atendimento = 0
 let l_resultado = 1
 let l_mensagem = null
 let l_prporgpcp = null
 let l_prpnumpcp = null
 let l_qtde_at_ap = cta02m15_qtd_serv_residencia(lr_param.ramcod
                                                ,lr_param.succod
                                                ,lr_param.aplnumdig
                                                ,lr_param.itmnumdig
                                                ,"",""
                                                ,lr_param.data_calculo
                                                ,lr_param.c24astcod
                                                ,lr_param.bnfnum )
 # Se nao tem endosso, contar os servicos realizados pela proposta
 if lr_param.flag_endosso = "N" then
    # Obter proposta original atraves da apolice
    call cty05g00_prp_apolice(lr_param.succod,lr_param.aplnumdig, 0)
         returning l_resultado,
                   l_mensagem,
                   l_prporgpcp,
                   l_prpnumpcp
    if l_resultado <> 1 then
       return l_resultado,
              l_mensagem,
              l_qtd_atendimento
    end if
    let l_qtde_at_pr = cta02m15_qtd_serv_residencia("",
                                                    "",
                                                    "",
                                                    "",
                                                    l_prporgpcp,
                                                    l_prpnumpcp,
                                                    lr_param.data_calculo,
                                                    lr_param.c24astcod, "")
                                                    
 end if

 let l_qtd_atendimento = l_qtde_at_ap + l_qtde_at_pr
 return l_resultado,
        l_mensagem,
        l_qtd_atendimento
end function
## Para assuntos S41 ou S42 de apolices com clausula 33 ou 47, o limite
function cty05g02_qtd_re(lr_param)
   define lr_param record 
          clscod char(03)
   end record        
   define lr_retorno smallint
   let lr_retorno = 0 
   case lr_param.clscod 
      when '033' 
         let lr_retorno = 1 
      when '33' 
         let lr_retorno = 1 
      when '044'
         let lr_retorno = 2 
      when '047'   
         let lr_retorno = 2  
      otherwise    
         let lr_retorno = 1
   end case                  
   return lr_retorno
end function
function cty05g02_qtd_servicos(lr_param)
define lr_param       record
        ramcod         smallint
       ,succod         like abbmitem.succod
       ,aplnumdig      like abbmitem.aplnumdig
       ,itmnumdig      like abbmitem.itmnumdig
       ,data_calculo   date
       ,c24astcod      like datmligacao.c24astcod
       ,bnfnum         like datrsrvsau.bnfnum
       ,flag_endosso   char(1)
       ,qtd_limite   integer
 end record
 define l_c24astcod  like datmligacao.c24astcod
 define l_flag              char(1) 
 define l_resultado         integer 
 define l_mensagem          char(80)                                         
 define l_qtd_atendimento   integer 
 let l_c24astcod         = null 
 let l_flag              = 'N'
 let l_resultado         = null
 let l_mensagem = null

 let l_qtd_atendimento   = 0
 if lr_param.c24astcod = "S41" then 
    let l_c24astcod = "S42" 
 end if
 if lr_param.c24astcod = "S42" then 
    let l_c24astcod = "S41" 
 end if    
  call cty05g02_qtd_srv_res(lr_param.ramcod     ## ligia - fornax - 03/01/2012
                          ,lr_param.succod
                          ,lr_param.aplnumdig
                          ,lr_param.itmnumdig 
                          ,lr_param.data_calculo
                          ,l_c24astcod
                          ,lr_param.bnfnum 
                          ,lr_param.flag_endosso)
      returning l_resultado, l_mensagem, l_qtd_atendimento
 if l_qtd_atendimento >= lr_param.qtd_limite then
    let l_flag = "S"                  
 end if                                   
return l_flag
end function
#######################################################################3
