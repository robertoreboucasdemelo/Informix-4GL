#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: Central 24hs                                               #
# Modulo.........: bdatm006.4gl                                               #
# Analista Resp..: Amilton Lourenco                                           #
# PSI............: PSI-2012-22101                                             #
# Objetivo.......: Interface entre PA Caixa - Painel (Donet) e Central 24hs   #
# ........................................................................... #
# Desenvolvimento: Kleiton Nascimento                                         #
# Liberacao......: 04/01/2013                                                 #
#=============================================================================#
#                 * * * A L T E R A C A O * * *                               #
#.............................................................................#
#  Data        Autor Fabrica  Alteracao                                       #
#-----------------------------------------------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

#XML Teste 
#<mq><servico>PagamentoServicoAvulso</servico><numeroAtendimento>000100602413</numeroAtendimento><valorServico>100</valorServico><valorPrestador>50</valorPrestador><quantidadeParcelas>2</quantidadeParcelas></mq>
#bdatm006.4gc atd.saps.4gl.01R.RQ "PagamentoServicoAvulso" 100 50 2 0
database porto

globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'
globals '/homedsa/projetos/geral/globals/glct.4gl'
globals '/homedsa/projetos/geral/globals/figrc072.4gl'
globals '/homedsa/projetos/geral/globals/figrc012.4gl'

 define m_qtdChamadasListener   dec(15,0)
 define m_qtdChamadasServicos   array[8] of dec(15,0)

--------------------------------------------------------------------------------
function executeservice(l_servicename)
--------------------------------------------------------------------------------
define l_servicename     char(50)

define aux_atdsrvnum char(20)

define lr_entrada record
     atdsrvnum   like datmservico.atdsrvnum,
     atdsrvano   like datmservico.atdsrvano,
     cbrvlr      like datmefutrn.cbrvlr,
     prsvlr      like datmefutrn.prsvlr,
     cbrparqtd   like datmefutrn.cbrparqtd
end record

define lr_retorno record
     codigo      smallint,
     mensagem    char(300)
end record        

if g_outFigrc012.Is_Teste then
     call bdatm006_debug(l_servicename)
end if
 display "<56> bdatm006-> l_servicename >> ", l_servicename
case l_servicename 
        
    when "PagamentoServicoAvulso" 

       let aux_atdsrvnum = g_paramval[1]
       
       let lr_entrada.atdsrvnum = aux_atdsrvnum[1,10]
       let lr_entrada.atdsrvano = aux_atdsrvnum[11,12]
       let lr_entrada.cbrvlr    = g_paramval[2]
       let lr_entrada.prsvlr    = g_paramval[3]
       let lr_entrada.cbrparqtd = g_paramval[4]


       display "<70> batm006-> lr_entrada.atdsrvnum >> ", lr_entrada.atdsrvnum 
       display "<71> batm006-> lr_entrada.atdsrvano >> ", lr_entrada.atdsrvano 
       display "<72> batm006-> lr_entrada.cbrvlr    >> ", lr_entrada.cbrvlr    
       display "<73> batm006-> lr_entrada.prsvlr    >> ", lr_entrada.prsvlr    
       display "<74> batm006-> lr_entrada.cbrparqtd >> ", lr_entrada.cbrparqtd 
       
       call cty27g01(lr_entrada.*)
           returning lr_retorno.*
      
   otherwise
       display "<80> bdatm006-> l_servicename >> ", l_servicename
       let lr_retorno.codigo = 1 using '&'
       let lr_retorno.mensagem = "Parametros nao recebidos ou invalidos"
end case
 display "<84> bdatm006-> Chamando bdatm006_xml_resp ....................... ", lr_retorno.*
return bdatm006_xml_resp(lr_retorno.*)

end function
--------------------------------------------------------------------------------
function bdatm006_xml_resp(lr_retorno)
--------------------------------------------------------------------------------
   define lr_retorno record
       codigo      smallint,
       mensagem    char(300)
   end record        

   define l_xml    char(5000)

   let lr_retorno.codigo = lr_retorno.codigo using '&'
  
   display "<100> bdatm006-> Dentro de bdatm006_xml_resp ....................... <",lr_retorno.codigo,">"
   #let l_xml = "<?xml version='1.0' encoding='ISO-8859-1'?>", 
   #            "<retorno> ",
   let l_xml = "<?xml version='1.0' encoding='UTF-8' ?>",
               "<retorno xmlns='http://www.portoseguro.com.br/ebo/Common/V1_0'>",
               "<codigo>",lr_retorno.codigo using '&' clipped, "</codigo>",
               "<mensagem>",lr_retorno.mensagem clipped, "</mensagem>",
               "</retorno> "

   return l_xml
end function



#--------------------------------------#
function bdatm006_debug(l_servicename)
#--------------------------------------#
    define l_servicename      char(50),
           l_ind              smallint

    let m_qtdChamadasListener = m_qtdChamadasListener + 1

    if m_qtdChamadasListener = 999999999999999.00 then
        display "--> Limite de chamadas do listener atingido (999999999999999)."
        display "--> O contador do listener sera re-iniciado."
        let m_qtdChamadasListener = 1
    end if

    display "Qtd. chamadas ao listener.: ", m_qtdChamadasListener
            using "<<<<<<<<<<<<<<<"

    case l_servicename
        when "PagamentoServicoAvulso"
            let l_ind = 1
        otherwise
            let l_ind = 0
    end case

    if l_ind > 0 then

        if m_qtdChamadasServicos[l_ind] = 999999999999999.00 then
            display "--> Limite de chamadas do servico atingido ",
                    "(999999999999999)."
            display "--> O contador do servico sera re-iniciado."
            let m_qtdChamadasServicos[l_ind] = 1
        end if

        let m_qtdChamadasServicos[l_ind] = m_qtdChamadasServicos[l_ind] + 1
        display "Qtd. chamadas ao servico..: ", m_qtdChamadasServicos[l_ind]
                using "<<<<<<<<<<<<<<<"
    end if

    display "Servico recebido..........: ", l_servicename clipped

    for l_ind = 1 to 400
        if g_paramval[l_ind] is null then
            exit for
        end if
        display "Parametro [", l_ind using "<<<<<<<&", "] = ",
                g_paramval[l_ind] clipped
    end for

end function
