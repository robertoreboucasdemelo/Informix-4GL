#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........:                                                           #
# ANALISTA RESP..: SERGIO BURINI                                             #
# PSI/OSF........:                                                           #
# OBJETIVO.......: BUSCA O VALOR, A QUANTIDADE DE DIARIAS SOLICITADAS, UTILI-#
#                  ZADAS E PAGAS NO SERVICO DE CARRO EXTRA                   #
#............................................................................#
# DESENVOLVIMENTO: CELSO YAMAHAKI                                            #
# LIBERACAO......:   /  /                                                    #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
#                                                                            #
# -------------------------------------------------------------------------- #

database porto

define mr_cty24g00      record
       atzdianum         like datmrsvvcl.atzdianum,         # Dias Autorizados
       vcleftretdat      like datmrsvvcl.vcleftretdat,      # Data Efetiva de Retirada, campo ainda nao existe em producao
       vcleftdvldat      like datmrsvvcl.vcleftdvldat,      # Data Efetiva de Devolucao-campo ainda nao existe em producao
       vclrethordat      like datmrsvvcl.vclrethordat,      # Data da retirada
       vcldvlhordat      like datmrsvvcl.vcldvlhordat,      # Data da devolucao
       lcvvcldiavlr      like datklocaldiaria.lcvvcldiavlr, # Valor da diaria
       lcvvclsgrvlr      like datklocaldiaria.lcvvclsgrvlr, # Valor do seguro
       prtsgrvlr         like datklocaldiaria.prtsgrvlr,    # valor seguro porto
       diafxovlr         like datklocaldiaria.diafxovlr,    # valor fixo
       prtaertaxvlr      like datkavislocal.prtaertaxvlr,   # Valor da taxa aero portuaria
       aviretdat         like datmavisrent.aviretdat,       # Data da Retirada do Veiculo
       aviestcod         like datmavisrent.aviestcod,       # Codigo da estacao avis
       avivclcod         like datmavisrent.avivclcod,       # Codigo do Veiculo
       lcvcod            like datmavisrent.lcvcod,          # Codigo da Locadora
       aviprvent         like datmavisrent.aviprvent,       # Previsao de Entrega
       avialgmtv         like datmavisrent.avialgmtv,       # Motivo do aluguel
       avivclvlr         like datmavisrent.avivclvlr,       # Valor Monetario
       avioccdat         like datmavisrent.avioccdat        # data ocorrencia aluguel (avis)
end record

define m_prepare smallint,
       m_path    char(250)


#---------------------------
function cty24g00_prepare()
#---------------------------

  define l_sql char(1500)
  
  # Busca as datas de retirada, devolucao e dias autorizados
  let l_sql = " select atzdianum ,    ",
              "        vcleftretdat, ", # campo ainda nao existe em producao
              "        vcleftdvldat, ", # campo ainda nao existe em producao
              "        vclrethordat, ",
              "        vcldvlhordat  ",
              "   from datmrsvvcl    ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? " 
    
    prepare pcty24g00_01 from l_sql
    declare ccty24g00_01 cursor for pcty24g00_01
  
  # Busca o motivo e valor da locacao    
  let l_sql = " select avialgmtv,    ",
              "        avivclvlr,    ",
              "        lcvcod,       ",
              "        aviretdat,    ",
              "        aviestcod,    ",
              "        avivclcod,    ",
              "        aviprvent     ",
              "   from datmavisrent  ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? " 
    prepare pcty24g00_02 from l_sql
    declare ccty24g00_02 cursor for pcty24g00_02
  
  # Busca das prorrogacoes, com centro de custo
  let l_sql = " select sum(aviprodiaqtd)       ", 
              "   from datmprorrog             ", 
              "   where atdsrvnum = ?          ",
              "     and atdsrvano = ?          ",
              "     and cctcod    is not null  ", 
              "     and aviprostt = 'A'        " 
    prepare pcty24g00_03 from l_sql              
    declare ccty24g00_03 cursor for pcty24g00_03
    
  # Busca das prorrogacoes, sem centro de custo
  let l_sql = " select sum(aviprodiaqtd)       ",
              "   from datmprorrog             ",
              "   where atdsrvnum = ?          ",
              "     and atdsrvano = ?          ",
              "     and aviprostt = 'A'        " 
  
    prepare pcty24g00_04 from l_sql 
    declare ccty24g00_04 cursor for pcty24g00_04 
  
  #Busca os valores da diaria
  let l_sql = " select a.lcvvcldiavlr,                   ", 
              "        a.lcvvclsgrvlr,                   ", 
              "        a.prtsgrvlr,                      ", 
              "        a.diafxovlr,                      ", 
              "        b.prtaertaxvlr                    ", 
              "   from datklocaldiaria a,                ", 
              "        datkavislocal b                   ", 
              "  where b.lcvcod       =  ?               ", 
              "    and b.aviestcod    =  ?               ", 
              "    and a.lcvlojtip    =  b.lcvlojtip     ", 
              "    and a.lcvregprccod =  b.lcvregprccod  ", 
              "    and a.avivclcod    =  ?               ", 
              "    and a.lcvcod       =  b.lcvcod        ", 
              "    and ?  between a.viginc and a.vigfnl  ", 
              "    and ?  between a.fxainc and a.fxafnl  " 
    prepare pcty24g00_05 from l_sql 
    declare ccty24g00_05 cursor for pcty24g00_05  
  
  #Busca os servicos de uma determinada OP / Usada para testes
  let l_sql = " select atdsrvnum, atdsrvano ", 
              " from   dbsmopgitm           ", 
              " where  socopgnum = ?        "
    prepare pcty24g00_06 from l_sql  
    declare ccty24g00_06 cursor for pcty24g00_06
  
  #Busca os dados para enviar e-mail para a locadora
  let l_sql = " select aviestnom, lcvcod, lcvlojtip ",
              " from datkavislocal                  ",
              " where aviestcod = (select aviestcod ",
              "                 from dbsmopg        ",
              "                 where socopgnum = ?)" 
              
    prepare pcty24g00_07 from l_sql             
    declare ccty24g00_07 cursor for pcty24g00_07
  
  #Busca o email da matriz  
  let l_sql = "select lcvnom,     ",
              "       maides      ",
              "from datklocadora  ",
              "where lcvcod = ?   "  
  prepare pcty24g00_08 from l_sql 
  declare ccty24g00_08 cursor for pcty24g00_08 
  
  #Busca dados do servico
  let l_sql = "select atddat,       ",
              "       atdhor        ",
              "from   datmservico   ", 
              "where  atdsrvnum = ? ",
              "and    atdsrvano = ? "
    prepare pcty24g00_09 from l_sql  
    declare ccty24g00_09 cursor for pcty24g00_09
    
  let l_sql = " select relpamtxt "                  
             ,"   from igbmparam "                  
             ,"  where relsgl = 'BDBSA106' "                 
  prepare pcty24g00_10 from l_sql               
  declare ccty24g00_10 cursor for pcty24g00_10     

  let m_prepare = true
  
end function  

#VERIFICA SE O SERVICO FOI FEITO POR INTEGRACAO
#---------------------------
function cty24g00_chk_int(l_param)
#---------------------------  
  
  define l_param record                          
         atdsrvnum    like dbsmopgitm.atdsrvnum, 
         atdsrvano    like dbsmopgitm.atdsrvano,
         tipo         char(01)
  end record
  
  define l_erro         char(15),
         l_rsvlclcod    like datmrsvvcl.rsvlclcod,
         l_vcleftretdat like datmrsvvcl.vcleftretdat,
         l_vcleftdvldat like datmrsvvcl.vcleftdvldat
    
  initialize l_rsvlclcod,   
             l_vcleftretdat,
             l_vcleftdvldat to null
  
  select rsvlclcod,
         vcleftretdat,
         vcleftdvldat
    into l_rsvlclcod,
         l_vcleftretdat,
         l_vcleftdvldat
    from datmrsvvcl    
   where atdsrvnum = l_param.atdsrvnum
     and atdsrvano = l_param.atdsrvano
  
  display "SERVICO: ", l_param.atdsrvnum,
                       l_param.atdsrvano
  
  #if l_rsvlclcod is null or l_rsvlclcod = " "  then     
  #   let l_erro = null         
  #else                         
     if  l_param.tipo = "C" then #COMPLETA
         if  (l_vcleftretdat is null or l_vcleftretdat = " ") or 
             (l_vcleftdvldat is null or l_vcleftdvldat = " ") then
             display "SERVICO FORA DA INTEGRACAO"
             let l_erro = null
         else
             display "SERVICO dENTRO INTEGRACAO"
             let l_erro = "Integracao" 
         end if
     else
         if l_rsvlclcod is null or l_rsvlclcod = " "  then
            let l_erro = null                             
         else                                             
            display "SERVICO dENTRO INTEGRACAO"
            let l_erro = "Integracao" 
         end if
     end if
  #end if                      
  
  return l_erro
         
end function

#funcao principal
#---------------------------
function cty24g00(l_param)
#---------------------------

  define l_param record 
         atdsrvnum    like dbsmopgitm.atdsrvnum, 
         atdsrvano    like dbsmopgitm.atdsrvano  
  end record
  
  define l_erro    char (15),
         l_flag    smallint    
  
  #Record usada para calculos
  define lr_calculo record
         retirada     date,
         devolucao    date,
         previsao     date,
         hrprev       interval hour(6) to minute,
         hreftv       interval hour(6) to minute,
         diferenca    interval hour(6) to minute,
         acrescimo    like datmavisrent.avivclvlr,
         total        like datmavisrent.avivclvlr,
         solicitadas  smallint,
         pagas        smallint,
         utilizadas   smallint, #dias utilizados
         prorrog      integer,  #dias de prorrogacao
         prorrog_aux  integer   #auxiliar dos calculos
         
  end record
  
  initialize mr_cty24g00.*, lr_calculo.* to null
  
  let lr_calculo.pagas = 0
  let lr_calculo.prorrog = 0  
  let lr_calculo.solicitadas = 0 
  
  if m_prepare is null or
     m_prepare <> true then
     call cty24g00_prepare()
  end if
  
  call cty24g00_chk_int(l_param.atdsrvnum, l_param.atdsrvano,"C")
      returning l_erro 
  
  display "VERIFICA INTEGRACAO."
  display "l_erro = ", l_erro 
                              
  open ccty24g00_01  using l_param.atdsrvnum, 
                           l_param.atdsrvano  
                              
  fetch ccty24g00_01 into mr_cty24g00.atzdianum,   
                          mr_cty24g00.vcleftretdat, # campo ainda nao existe em producao
                          mr_cty24g00.vcleftdvldat, # campo ainda nao existe em producao
                          mr_cty24g00.vclrethordat,
                          mr_cty24g00.vcldvlhordat 
                              
  display "RETORNO DO PARAMETRO DE CALCULO"
  display "mr_cty24g00.atzdianum   : ",mr_cty24g00.atzdianum 
  display "mr_cty24g00.vcleftretdat: ",mr_cty24g00.vcleftretdat
  display "mr_cty24g00.vcleftdvldat: ",mr_cty24g00.vcleftdvldat
  display "mr_cty24g00.vclrethordat: ",mr_cty24g00.vclrethordat
  display "mr_cty24g00.vcldvlhordat: ",mr_cty24g00.vcldvlhordat
                              
  close ccty24g00_01          
                              
  open ccty24g00_02 using l_param.atdsrvnum,
                          l_param.atdsrvano 
  fetch  ccty24g00_02 into mr_cty24g00.avialgmtv,
                           mr_cty24g00.avivclvlr,
                           mr_cty24g00.lcvcod,
                           mr_cty24g00.aviretdat,
                           mr_cty24g00.aviestcod,
                           mr_cty24g00.avivclcod,
                           mr_cty24g00.aviprvent
                              
  display "RETORNO DOS DADOS DA RESERVA"
  display "mr_cty24g00.avialgmtv: ",mr_cty24g00.avialgmtv
  display "mr_cty24g00.avivclvlr: ",mr_cty24g00.avivclvlr
  display "mr_cty24g00.lcvcod,  : ",mr_cty24g00.lcvcod 
  display "mr_cty24g00.aviretdat: ",mr_cty24g00.aviretdat
  display "mr_cty24g00.aviestcod: ",mr_cty24g00.aviestcod
  display "mr_cty24g00.avivclcod: ",mr_cty24g00.avivclcod
  display "mr_cty24g00.aviprvent: ",mr_cty24g00.aviprvent
                              
  close ccty24g00_02          
                              
  
  
  open ccty24g00_05 using mr_cty24g00.lcvcod,
                          mr_cty24g00.aviestcod,
                          mr_cty24g00.avivclcod,
                          mr_cty24g00.aviretdat,
                          mr_cty24g00.atzdianum
                              
  fetch ccty24g00_05 into mr_cty24g00.lcvvcldiavlr,
                          mr_cty24g00.lcvvclsgrvlr,
                          mr_cty24g00.prtsgrvlr,   
                          mr_cty24g00.diafxovlr,   
                          mr_cty24g00.prtaertaxvlr
                              
  display "RETORNO DOS VALORES DAS DIARIAS."                        
  display "mr_cty24g00.lcvvcldiavlr = ", mr_cty24g00.lcvvcldiavlr                        
  display "mr_cty24g00.lcvvclsgrvlr = ", mr_cty24g00.lcvvclsgrvlr                       
  display "mr_cty24g00.prtsgrvlr    = ", mr_cty24g00.prtsgrvlr                          
  display "mr_cty24g00.diafxovlr    = ", mr_cty24g00.diafxovlr                          
  display "mr_cty24g00.prtaertaxvlr = ", mr_cty24g00.prtaertaxvlr                        
                              
  close ccty24g00_05          
                              
  if  mr_cty24g00.vcleftretdat < today - 1 units year then
      let l_erro = ""         
  end if                      
                              
  if l_erro is null then      
    let l_flag = false        
                              
    display "SERVIÇO NÃO É VIA INTEGRAÇÃO"
                              
    let lr_calculo.utilizadas = mr_cty24g00.aviprvent
    let lr_calculo.pagas      = mr_cty24g00.aviprvent
    
    # Se nao for por integracao, retorna valores nulos
    #initialize lr_calculo.utilizadas,
    #           lr_calculo.pagas,
    #           lr_calculo.total to null
                              
  else                        
                              
    display "SERVIÇO É VIA INTEGRAÇÃO"
                              
    let l_flag = true         
    #Busca os valores da diaria
                              
                              
                              
    let lr_calculo.total = 0  
                              
    let lr_calculo.previsao = mr_cty24g00.vcleftretdat + mr_cty24g00.aviprvent units day
    let lr_calculo.hrprev = time(lr_calculo.previsao)
                              
    #Calculo dos dias utilizados
    if mr_cty24g00.vcleftretdat is not null and
       mr_cty24g00.vcleftdvldat is not null then
                              
       display "TEMOS RETIRADA E DEVOLUCAO LOCALIZA."  
                              
       let lr_calculo.retirada = mdy(month(mr_cty24g00.vcleftretdat),
                                       day(mr_cty24g00.vcleftretdat),
                                       year(mr_cty24g00.vcleftretdat))
                              
       let lr_calculo.devolucao = mdy(month(mr_cty24g00.vcleftdvldat),
                                        day(mr_cty24g00.vcleftdvldat),
                                        year(mr_cty24g00.vcleftdvldat))
                              
       let lr_calculo.utilizadas = lr_calculo.devolucao - lr_calculo.retirada
                              
       display "CALCULANDO OS DIAS UTILIZADOS VIA INTEGRAÇÃO"
       display "lr_calculo.retirada   = ", lr_calculo.retirada  
       display "lr_calculo.devolucao  = ", lr_calculo.devolucao 
       display "lr_calculo.utilizadas = ", lr_calculo.utilizadas 
                              
    else                      
      display "UTILIZA DIARIAS AUTORIZADAS."
      let lr_calculo.utilizadas = mr_cty24g00.atzdianum
    end if                    
                              
    display "DIAS UTILIZADOS: ", lr_calculo.utilizadas
                              
    #calculo dos dias pagos   
    if lr_calculo.utilizadas < mr_cty24g00.atzdianum then
      display "DIAS AUTORIZADOS MAIOR QUE O DIA UTILIZADO"
      let lr_calculo.pagas = lr_calculo.utilizadas
    else                      
      display "DIAS AUTORIZADOS MENOR QUE O DIA UTILIZADO"
      let lr_calculo.pagas = mr_cty24g00.atzdianum
    end if                    
                              
    display "DIAS PAGOS: ", lr_calculo.pagas
                              
  end if                      
                              
  #Calculo dos Valores        
  if mr_cty24g00.diafxovlr > 0 then
    let lr_calculo.total = mr_cty24g00.diafxovlr + mr_cty24g00.lcvvclsgrvlr
  else                        
    if mr_cty24g00.diafxovlr <= 0 then
      let lr_calculo.total = (mr_cty24g00.prtsgrvlr + mr_cty24g00.lcvvclsgrvlr)   *    
                          lr_calculo.pagas        
    end if                    
  end if                      
                              
  if mr_cty24g00.prtaertaxvlr  <>  0  then
    let lr_calculo.total = ((lr_calculo.total * mr_cty24g00.prtaertaxvlr) 
          / 100 ) + lr_calculo.total  
  end if                      
                              
  display "mr_cty24g00.prtaertaxvlr = ", mr_cty24g00.prtaertaxvlr
                              
                              
    #Calculo dos acrescimos.  
    {                         
       Atraso Entrega Veículo 
                              
       01 minutos  a 59 minutos - não é cobrado taxa adicional
       01h00 a 01h59 - cobrado 20% do valor da diaria
       02h00 a 02h59 - cobrado 40% do valor da diária
       03h00 a 03h59 - cobrado 60% do valor da diária
       04h00 a 04h59 - cobrado 80% do valor da diária
       A partir de 05h00 - cobrado 100% do valor da diária
    }                         
                              
  let lr_calculo.acrescimo = 0
                              
  #if  l_erro is not null then
  #                           
  #  let lr_calculo.hreftv = time(mr_cty24g00.vcleftdvldat)
  #  let lr_calculo.diferenca = lr_calculo.hreftv - lr_calculo.hrprev
  #                           
  #  if lr_calculo.diferenca > "5:00" then
  #     let lr_calculo.acrescimo = mr_cty24g00.lcvvcldiavlr
  #  else                     
  #    if lr_calculo.diferenca > "4:00" then
  #      let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.8)
  #    else                   
  #      if lr_calculo.diferenca > "3:00" then
  #        let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.6)
  #      else                 
  #        if lr_calculo.diferenca > "2:00" then
  #          let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.4)
  #        else               
  #          if lr_calculo.diferenca > "1:00" then
  #            let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.2)  
  #          else             
              let lr_calculo.acrescimo = 0
  #          end if           
  #        end if             
  #      end if               
  #    end if                 
  #  end if                   
                              
    display "ACRESCIMO: ", lr_calculo.acrescimo
                              
    let lr_calculo.total = lr_calculo.total + lr_calculo.acrescimo
                              
  #end if                     
                              
  return l_flag,              
         mr_cty24g00.atzdianum,
         lr_calculo.utilizadas,
         lr_calculo.pagas,    
         lr_calculo.total     
                                     
end function                  
                              
#-------------------------------------------
function cty24g00_enviar_op(l_param,l_path)
#-------------------------------------------
                              
  define l_param record       
         socopgnum    like dbsmopgitm.socopgnum
                              
  end record                  
  define l_path         char(250) 
  define lr_mail record       
         rem char(50),        
         des char(250),       
         ccp char(250),       
         cco char(250),       
         ass char(500),       
         msg char(32000),     
         idr char(20),        
         tip char(4)          
  end record                  
                              
  define l_cod_erro        integer, 
         l_msg_erro        char(20), 
         l_data            date,     
         l_hora            datetime hour to second,
         l_empresa_paga    char(30),
         l_empresa_recebe  like datklocadora.lcvnom,
         l_qtd_reservas    integer,
         l_qtd_diarias     dec(20,0),
         l_total           decimal(15,2),
         l_aviestnom       like datkavislocal.aviestnom, 
         l_lcvcod          like datkavislocal.lcvcod,   
         l_lcvlojtip       like datkavislocal.lcvlojtip,
         l_empcod          like dbsmopg.empcod,        
         l_tipoemp         char(15),
         l_mail            char(200)
                              
  let l_qtd_reservas = 0      
  let l_qtd_diarias  = 0      
  let l_total        = 0      
  let l_aviestnom    = null   
  let l_lcvcod       = null   
  let l_lcvlojtip    = null   
  let l_empcod       = null   
  let l_mail         = null   
                              
  initialize lr_mail.* to null
                              
  #if l_path is null then     
  call cty24g00_totaliza_op(l_param.socopgnum, l_path)
     returning l_qtd_reservas,
               l_qtd_diarias, 
               l_total        
  #end if                     
                              
  if m_prepare is null or     
     m_prepare <> true then   
     call cty24g00_prepare()  
  end if                      
                              
  open ccty24g00_07 using l_param.socopgnum
    fetch ccty24g00_07 into l_aviestnom,
                            l_lcvcod   ,
                            l_lcvlojtip
  close ccty24g00_07          
                              
  case l_lcvcod               
    when 1                    
       let l_tipoemp = "CORPORACAO"
    when 2                    
       let l_tipoemp = "FRANQUIA"
    when 3                    
       let l_tipoemp = "FRANQUIA"
  end case                    
                              
  open ccty24g00_08 using l_lcvcod
    fetch ccty24g00_08 into l_empresa_recebe,
                            lr_mail.des
  close ccty24g00_08          
                              
  #MONTANDO GRUPO DE E-MAILS A SEREM ENVIADOS
  open ccty24g00_10           
  foreach ccty24g00_10 into l_mail
     let lr_mail.des = lr_mail.des clipped, l_mail clipped, ","
  end foreach                 
                              
  display "ENVIANDO E-MAIL PARA: ", lr_mail.des
                              
  select empcod               
  into   l_empcod             
  from   dbsmopg
  where  socopgnum = l_param.socopgnum
  
  case l_empcod
    when 1
      let l_empresa_paga = "PORTO SEGURO"
    when 35
      let l_empresa_paga = "AZUL SEGUROS"
    when 84
      let l_empresa_paga = "ITAU SEGUROS AUTO E RESIDENCIA" 
  end case
  
  #let lr_mail.des = "sergio.burini@portoseguro.com.br,karolynne.marin@portoseguro.com.br"
  

  let lr_mail.rem = "porto.socorro@portoseguro.com.br" 
  let lr_mail.ccp = ""
  let lr_mail.cco = ""
  
  let lr_mail.ass = "Ordem de Pagamento ", l_aviestnom clipped, " - ",
                                           l_empresa_paga clipped, " - ",
                                           l_tipoemp clipped
  
  let lr_mail.idr = "F0112408" 
  let lr_mail.tip = "html" 
       
  
  let lr_mail.msg = "<html>", 
                    "<body>",
                    "<br>", 
                    "<table border=0 cellspacing=0 cellpadding=2 width=100% bgcolor=darkblue align=center>", 
                      "<tr>",
                        "<td>",
                          "<font size=2 face=Verdana color=white>",
                            "<center>",
                              "<b>",
                                l_empresa_paga clipped, "-", l_empresa_recebe clipped, 
                              "</b>",
                            "</center>",
                          "</font>",
                        "</td>",
                      "</tr>",
                    "</table>",  
                    "<br>",      
                    "<font size =2 face = Verdana>",
                      "Segue anexo a OP ", l_param.socopgnum clipped , " que contem ", l_qtd_reservas using "#&&&",
                      " reservas com ", l_qtd_diarias using "#&&&"," diarias autorizadas totalizando R$ ",
                      l_total using "########&.&&",
                      "<br>",        
                      "Em caso de divergencia envie e-mail ao Porto Socorro para os devidos ajustes.",
                      "<br><br>",
                      "Atentamente,",   
                      "<br>", 
                      "<b>PORTO SOCORRO </b>",
                    "</font>",
                      "<br><br>", 
                    "</body>",
                    "</html>" 
  
  let lr_mail.msg = lr_mail.msg clipped
  display lr_mail.msg clipped
  if l_path is null then
    let m_path = cty24g00_busca_path(l_path,
                                     l_param.socopgnum,
                                     l_lcvcod,   
                                     l_lcvlojtip, 
                                     l_empcod    )
  else
    let m_path = l_path
  end if
  
  call figrc009_attach_file(m_path)
  
  call figrc009_mail_send1(lr_mail.*)   
       returning l_cod_erro, l_msg_erro 
       
  display "RETORNO DO E-MAIL: ", l_cod_erro, l_msg_erro     

  if  l_cod_erro <> 0 then 
      display "Erro no envio do email: ",
              l_cod_erro using "<<<<<<&", " - ", 
              l_msg_erro clipped 
  end if   

end function

#-------------------------------------------------
function cty24g00_totaliza_op(l_param, l_path)
#-------------------------------------------------
  define l_param record  
         socopgnum    like dbsmopgitm.socopgnum
  end record
  define l_path         char(250)
  
  define lr_retorno   record
         reservas     integer,
         diarias      dec(20,0),
         valor_total  decimal(15,2)  
  end record
  
  define lr_servico record
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   like datmservico.atdsrvano,
         atddat      like datmservico.atddat,
         atdhor      like datmservico.atdhor
  end record
  
  define lr_calculo record
         flag         smallint,
         retirada     date,
         devolucao    date,
         total        like datmavisrent.avivclvlr,
         solicitadas  smallint,
         pagas        smallint,
         utilizadas   smallint, #dias utilizados
         prorrog      integer,  #dias de prorrogacao
         prorrog_aux  integer   #auxiliar dos calculos
  end record
  
  define l_contador     integer,
         l_char         char(20),
         l_aviestnom    like datkavislocal.aviestnom, 
         l_lcvcod       like datkavislocal.lcvcod,   
         l_lcvlojtip    like datkavislocal.lcvlojtip,
         l_empcod       like dbsmopg.empcod,
         l_tipoemp      char(15),
         l_socfattotvlr like dbsmopg.socfattotvlr
  
  let lr_retorno.reservas = 0
  let lr_retorno.diarias  = 0
  let lr_retorno.valor_total = 0
  let l_socfattotvlr = 0
  let l_aviestnom    = null
  let l_lcvcod       = null
  let l_lcvlojtip    = null
  let l_empcod       = null  
    
  if m_prepare is null or
     m_prepare <> true then
     call cty24g00_prepare()
  end if
  open ccty24g00_07 using l_param.socopgnum
    fetch ccty24g00_07 into l_aviestnom,
                            l_lcvcod   ,
                            l_lcvlojtip
  close ccty24g00_07
  
  select empcod
  into   l_empcod
  from   dbsmopg
  where  socopgnum = l_param.socopgnum
  
  if l_path is null then
    let lr_calculo.flag = true
    let m_path = cty24g00_busca_path(l_path,
                                     l_param.socopgnum,
                                     l_lcvcod,   
                                     l_lcvlojtip, 
                                     l_empcod    )
    #Para confrontar os valores finais. Somente para OP manual
    select socfattotvlr
    into   l_socfattotvlr
    from   dbsmopg
    where  socopgnum = l_param.socopgnum
  
  
  start report cty24g00_relatorio_op to m_path
  
  call cty24g00_calcular_op(l_param.socopgnum,lr_calculo.flag)
     returning lr_retorno.reservas   ,
               lr_retorno.diarias    ,
               lr_retorno.valor_total
  
  finish report cty24g00_relatorio_op
  else
    let lr_calculo.flag = false
    let m_path = l_path
    call cty24g00_calcular_op(l_param.socopgnum,lr_calculo.flag)
     returning lr_retorno.reservas   ,
               lr_retorno.diarias    ,
               lr_retorno.valor_total
  end if  
    return lr_retorno.reservas   ,
           lr_retorno.diarias    ,
           lr_retorno.valor_total
    
end function

#-------------------------------------
function cty24g00_calcular_op(l_param)
#-------------------------------------
  define l_param record 
         socopgnum    like dbsmopgitm.socopgnum,
         flag         smallint
  end record
  
  define lr_calculo record
         flag         smallint,
         retirada     date,
         devolucao    date,
         total        like datmavisrent.avivclvlr,
         solicitadas  smallint,
         pagas        smallint,
         utilizadas   smallint, #dias utilizados
         prorrog      integer,  #dias de prorrogacao
         prorrog_aux  integer   #auxiliar dos calculos
  end record
  
  define lr_servico record
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   like datmservico.atdsrvano,
         atddat      like datmservico.atddat,
         atdhor      like datmservico.atdhor
  end record
  
  define lr_confirma   record
         linha1        char (40), 
         linha2        char (40), 
         linha3        char (40), 
         linha4        char (40),
         confirma      char (01)
  end record
  
  define lr_retorno   record
         reservas     integer,
         diarias      integer,
         valor_total  decimal(15,2)  
  end record 
  define l_contador        integer,
         l_char            char(50),
         l_aviestnom       like datkavislocal.aviestnom,  
         l_lcvcod          like datkavislocal.lcvcod,   
         l_lcvlojtip       like datkavislocal.lcvlojtip,
         l_empcod          like dbsmopg.empcod,        
         l_tipoemp         char(15),
         l_socfattotvlr    like dbsmopg.socfattotvlr,
         l_cabecalho       char(200),
         l_empresa_paga    char(30),
         l_empresa_recebe  like datklocadora.lcvnom,
         l_data            date
  
  let lr_retorno.reservas = 0
  let lr_retorno.diarias  = 0
  let lr_retorno.valor_total = 0
  let l_socfattotvlr = 0
  let l_aviestnom    = null
  let l_lcvcod       = null
  let l_lcvlojtip    = null
  let l_empcod       = null
  let lr_confirma.linha1 = ""
  let lr_confirma.linha2 = ""
  let lr_confirma.linha3 = ""
  let lr_confirma.linha4 = ""
  
  if m_prepare is null or
     m_prepare <> true then
     call cty24g00_prepare()
  end if
  open ccty24g00_07 using l_param.socopgnum
    fetch ccty24g00_07 into l_aviestnom,
                            l_lcvcod   ,
                            l_lcvlojtip
  close ccty24g00_07
  
  case l_lcvcod
    when 1
       let l_tipoemp = "CORPORACAO"
    when 2
       let l_tipoemp = "FRANQUIA"
    when 3
       let l_tipoemp = "FRANQUIA"
  end case
  
  open ccty24g00_08 using l_lcvcod
    fetch ccty24g00_08 into l_empresa_recebe,
                            l_char
  close ccty24g00_08
  
  select empcod
  into   l_empcod
  from   dbsmopg
  where  socopgnum = l_param.socopgnum
  
  case l_empcod
    when 1
      let l_empresa_paga = "PORTO SEGURO"
    when 35
      let l_empresa_paga = "AZUL SEGUROS"
    when 84
      let l_empresa_paga = "ITAU SEGUROS AUTO E RESIDENCIA" 
  end case
  let l_data = today  
  
  open ccty24g00_06 using l_param.socopgnum
    let l_contador = 0
    foreach ccty24g00_06 into lr_servico.atdsrvnum,
                              lr_servico.atdsrvano
      
      open ccty24g00_09 using lr_servico.atdsrvnum,
                              lr_servico.atdsrvano
           fetch ccty24g00_09 into lr_servico.atddat, 
                                   lr_servico.atdhor 
      close ccty24g00_09 
      
      
      call cty24g00(lr_servico.atdsrvnum,
                    lr_servico.atdsrvano)
      returning lr_calculo.flag,  
                lr_calculo.solicitadas,
                lr_calculo.utilizadas, 
                lr_calculo.pagas, 
                lr_calculo.total  
      
      if lr_calculo.solicitadas is null then
        let lr_calculo.solicitadas = 0 
      end if  

      if lr_calculo.utilizadas is null then
        let lr_calculo.utilizadas = 0
      end if
      
      if lr_calculo.pagas is null then
        let lr_calculo.pagas = 0      
      end if 
      
      if lr_calculo.total is null then
        let lr_calculo.total = 0      
      end if 

      let lr_retorno.reservas    = lr_retorno.reservas + 1
      let lr_retorno.diarias     = lr_retorno.diarias + lr_calculo.solicitadas 
      let lr_retorno.valor_total = lr_retorno.valor_total + lr_calculo.total
      let l_contador = l_contador + 1 
      if l_param.flag = true then        
        let l_cabecalho = "OP LOCADORA ", l_lcvcod using "&&&",
                          " - ", l_aviestnom clipped, " - ", l_tipoemp clipped,
                          " de ", l_data
        output to report cty24g00_relatorio_op(l_param.socopgnum      ,   # 1 
                                               lr_calculo.flag        ,   # 2 
                                               lr_calculo.total       ,   # 3 
                                               lr_calculo.solicitadas ,   # 4 
                                               lr_calculo.pagas       ,   # 5 
                                               lr_calculo.utilizadas  ,   # 6 
                                               lr_servico.atdsrvnum   ,   # 7 
                                               lr_servico.atdsrvano   ,   # 8 
                                               lr_servico.atddat      ,   # 9 
                                               lr_servico.atdhor      ,   # 10
                                               l_contador             ,   # 11
                                               l_cabecalho            )   # 11
      end if 
      initialize lr_servico.* to null
      let lr_calculo.total = 0
      let lr_calculo.pagas = 0     
      let lr_calculo.solicitadas = 0 
      let lr_calculo.utilizadas = 0
    
    end foreach
    #display "l_socfattotvlr", l_socfattotvlr
    #display "m_path", m_path
    if l_socfattotvlr <> 0 then #OP Manual
      if l_socfattotvlr <> lr_retorno.valor_total then #valor diverge
         display "valor divergente!!!"
         let lr_confirma.linha1 = "VALORES DIGITADOS ESTAO DIVERGENTES"
         let lr_confirma.linha2 = "DO VALOR ARMAZENADO NA TABELA!!!"
         let lr_confirma.linha3 = "Digitado: ", lr_retorno.valor_total using "######.##"
         let lr_confirma.linha3 = lr_confirma.linha3 clipped, "Historico: ", l_socfattotvlr using "######.##"
         let lr_confirma.linha4 = "OS DADOS ESTAO CORRETOS???" 
         
         {call cts08g01_confirma("A", "F",
                                lr_confirma.linha1,
                                lr_confirma.linha2,
                                lr_confirma.linha3,
                                lr_confirma.linha4)
            returning lr_confirma.confirma}
         display "LINHA 01", lr_confirma.linha1 clipped
         display "LINHA 02", lr_confirma.linha2 clipped
         display "LINHA 03", lr_confirma.linha3 clipped
         display "LINHA 04", lr_confirma.linha4 clipped
         
      end if
      display "valor igual"
    end if
    return lr_retorno.reservas   ,
           lr_retorno.diarias    ,
           lr_retorno.valor_total
    
end function


#--------------------------
function cty24g00_busca_path(l_param)
#--------------------------
    
  define l_param record
         path       char (250),
         socopgnum  like dbsmopg.socopgnum,
         lcvcod     like datkavislocal.lcvcod,   
         lcvlojtip  like datkavislocal.lcvlojtip,
         empcod     like dbsmopg.empcod
  end record
  
  define l_path char(250)
  
  if l_param.path is null then
     let l_path = "."   
     if l_param.lcvlojtip = 1 then
          let l_path = l_path clipped, l_param.path clipped,"/OPRE",l_param.lcvcod using "&&&" ,l_param.empcod using "&&", l_param.socopgnum using "<<<<<<<#",".xls"          
       else
          let l_path = l_path clipped, l_param.path clipped,"/OPREFRN",l_param.lcvcod using "&&&" ,l_param.empcod using "&&", l_param.socopgnum using "<<<<<<<#",".xls"
       end if
  else 
     let l_path = l_param.path
  end if 
  
  display "path: ", l_path clipped
  
  return l_path
end function

#---------------------------
function cty24g00_recalculo(l_param)
#---------------------------

  define l_param record 
         atdsrvnum    like dbsmopgitm.atdsrvnum, 
         atdsrvano    like dbsmopgitm.atdsrvano,
         c24utidiaqtd like dbsmopgitm.c24utidiaqtd,
         c24pagdiaqtd like dbsmopgitm.c24pagdiaqtd,
         qtd_sol      like dbsmopgitm.c24pagdiaqtd
  end record
  
  define l_erro    char (15),
         l_flag    smallint,
         l_vlrrec  smallint    
  
  #Record usada para calculos
  define lr_calculo record
         retirada     date,
         devolucao    date,
         previsao     date,
         hrprev       interval hour(6) to minute,
         hreftv       interval hour(6) to minute,
         diferenca    interval hour(6) to minute,
         acrescimo    like datmavisrent.avivclvlr,
         total        like datmavisrent.avivclvlr,
         solicitadas  smallint,
         pagas        smallint,
         utilizadas   smallint, #dias utilizados
         prorrog      integer,  #dias de prorrogacao
         prorrog_aux  integer   #auxiliar dos calculos
  end record
  
  initialize mr_cty24g00.*, lr_calculo.* to null
  
  let lr_calculo.pagas       = 0
  let lr_calculo.prorrog     = 0  
  let lr_calculo.solicitadas = 0 
  let lr_calculo.acrescimo   = 0 
  let lr_calculo.total = 0 
  let mr_cty24g00.prtaertaxvlr     = 0
  let l_flag = true
  let l_vlrrec = false
  
  if m_prepare is null or
     m_prepare <> true then
     call cty24g00_prepare()
  end if
  
  if  l_param.c24utidiaqtd is not null and l_param.c24utidiaqtd <> " " then
      let l_vlrrec = true
  end if
  
  if  not l_vlrrec then
      
      call cty24g00_chk_int(l_param.atdsrvnum, l_param.atdsrvano,"C")
           returning l_erro 
      
      display "VERIFICA INTEGRACAO."
      display "l_erro = ", l_erro 
                                  
      open ccty24g00_01  using l_param.atdsrvnum, 
                               l_param.atdsrvano  
                                  
      fetch ccty24g00_01 into mr_cty24g00.atzdianum,   
                              mr_cty24g00.vcleftretdat, # campo ainda nao existe em producao
                              mr_cty24g00.vcleftdvldat, # campo ainda nao existe em producao
                              mr_cty24g00.vclrethordat,
                              mr_cty24g00.vcldvlhordat 
                        
      close ccty24g00_01          
                                  
      open ccty24g00_02 using l_param.atdsrvnum,
                              l_param.atdsrvano 
      fetch  ccty24g00_02 into mr_cty24g00.avialgmtv,
                               mr_cty24g00.avivclvlr,
                               mr_cty24g00.lcvcod,
                               mr_cty24g00.aviretdat,
                               mr_cty24g00.aviestcod,
                               mr_cty24g00.avivclcod,
                               mr_cty24g00.aviprvent
                                  
      display "RETORNO DOS DADOS DA RESERVA"
      display "mr_cty24g00.avialgmtv: ",mr_cty24g00.avialgmtv
      display "mr_cty24g00.avivclvlr: ",mr_cty24g00.avivclvlr
      display "mr_cty24g00.lcvcod,  : ",mr_cty24g00.lcvcod 
      display "mr_cty24g00.aviretdat: ",mr_cty24g00.aviretdat
      display "mr_cty24g00.aviestcod: ",mr_cty24g00.aviestcod
      display "mr_cty24g00.avivclcod: ",mr_cty24g00.avivclcod
      display "mr_cty24g00.aviprvent: ",mr_cty24g00.aviprvent
                                  
      close ccty24g00_02          
                                  
      if  l_erro is null then
      
          open ccty24g00_05 using mr_cty24g00.lcvcod,
                                  mr_cty24g00.aviestcod,
                                  mr_cty24g00.avivclcod,
                                  mr_cty24g00.aviretdat,
                                  mr_cty24g00.aviprvent
                                      
          fetch ccty24g00_05 into mr_cty24g00.lcvvcldiavlr,
                                  mr_cty24g00.lcvvclsgrvlr,
                                  mr_cty24g00.prtsgrvlr,   
                                  mr_cty24g00.diafxovlr,   
                                  mr_cty24g00.prtaertaxvlr
      else
          # INTEGRACAO
          open ccty24g00_05 using mr_cty24g00.lcvcod,
                                  mr_cty24g00.aviestcod,
                                  mr_cty24g00.avivclcod,
                                  mr_cty24g00.aviretdat,
                                  mr_cty24g00.atzdianum
                                      
          fetch ccty24g00_05 into mr_cty24g00.lcvvcldiavlr,
                                  mr_cty24g00.lcvvclsgrvlr,
                                  mr_cty24g00.prtsgrvlr,   
                                  mr_cty24g00.diafxovlr,   
                                  mr_cty24g00.prtaertaxvlr      

      end if
                                  
      display "RETORNO DOS VALORES DAS DIARIAS."                        
      display "mr_cty24g00.lcvvcldiavlr = ", mr_cty24g00.lcvvcldiavlr                        
      display "mr_cty24g00.lcvvclsgrvlr = ", mr_cty24g00.lcvvclsgrvlr                       
      display "mr_cty24g00.prtsgrvlr    = ", mr_cty24g00.prtsgrvlr                          
      display "mr_cty24g00.diafxovlr    = ", mr_cty24g00.diafxovlr                          
      display "mr_cty24g00.prtaertaxvlr = ", mr_cty24g00.prtaertaxvlr                        
                                  
      close ccty24g00_05          
                                  
      if  mr_cty24g00.vcleftretdat < today - 1 units year then
          let l_erro = ""         
      end if                      
                                  
      if l_erro is null then      
        let l_flag = false        
                                  
        display "SERVIÇO NÃO É VIA INTEGRAÇÃO"
                                  
        let lr_calculo.utilizadas = mr_cty24g00.aviprvent
        let lr_calculo.pagas      = mr_cty24g00.aviprvent
        
        display "BURINI VERIFICAÇÂO:"
        display mr_cty24g00.aviprvent 
        display mr_cty24g00.aviprvent
    
      else                        
                                  
        display "SERVIÇO É VIA INTEGRAÇÃO"
                                  
        let l_flag = true         
                 
         
                                  
        let lr_calculo.previsao = mr_cty24g00.vcleftretdat + mr_cty24g00.aviprvent units day
        let lr_calculo.hrprev = time(lr_calculo.previsao)
                                  
        #Calculo dos dias utilizados
        if mr_cty24g00.vcleftretdat is not null and
           mr_cty24g00.vcleftdvldat is not null then
                                  
           display "TEMOS RETIRADA E DEVOLUCAO LOCALIZA."  
                                  
           let lr_calculo.retirada = mdy(month(mr_cty24g00.vcleftretdat),
                                           day(mr_cty24g00.vcleftretdat),
                                           year(mr_cty24g00.vcleftretdat))
                                  
           let lr_calculo.devolucao = mdy(month(mr_cty24g00.vcleftdvldat),
                                            day(mr_cty24g00.vcleftdvldat),
                                            year(mr_cty24g00.vcleftdvldat))
                                  
           let lr_calculo.utilizadas = lr_calculo.devolucao - lr_calculo.retirada
                                  
           display "CALCULANDO OS DIAS UTILIZADOS VIA INTEGRAÇÃO"
           display "lr_calculo.retirada   = ", lr_calculo.retirada  
           display "lr_calculo.devolucao  = ", lr_calculo.devolucao 
           display "lr_calculo.utilizadas = ", lr_calculo.utilizadas 
                                  
        else                      
          display "UTILIZA DIARIAS AUTORIZADAS."
          let lr_calculo.utilizadas = mr_cty24g00.atzdianum
        end if                    
                                  
        display "DIAS UTILIZADOS: ", lr_calculo.utilizadas
                                  
        #calculo dos dias pagos   
        if lr_calculo.utilizadas < mr_cty24g00.atzdianum then
          display "DIAS AUTORIZADOS MAIOR QUE O DIA UTILIZADO"
          let lr_calculo.pagas = lr_calculo.utilizadas
        else                      
          display "DIAS AUTORIZADOS MENOR QUE O DIA UTILIZADO"
          let lr_calculo.pagas = mr_cty24g00.atzdianum
        end if                    
                                  
        display "DIAS PAGOS: ", lr_calculo.pagas
                                  
      end if
       
  else
      display "VALOR RECEBIDO POR PARAMENTRO"
      let lr_calculo.utilizadas =  l_param.c24utidiaqtd
      let lr_calculo.pagas      =  l_param.c24pagdiaqtd
      
      open ccty24g00_02 using l_param.atdsrvnum,
                              l_param.atdsrvano 
      fetch  ccty24g00_02 into mr_cty24g00.avialgmtv,
                               mr_cty24g00.avivclvlr,
                               mr_cty24g00.lcvcod,
                               mr_cty24g00.aviretdat,
                               mr_cty24g00.aviestcod,
                               mr_cty24g00.avivclcod,
                               mr_cty24g00.aviprvent
                                  
      display "RETORNO DOS DADOS DA RESERVA"
      display "mr_cty24g00.avialgmtv: ",mr_cty24g00.avialgmtv
      display "mr_cty24g00.avivclvlr: ",mr_cty24g00.avivclvlr
      display "mr_cty24g00.lcvcod,  : ",mr_cty24g00.lcvcod 
      display "mr_cty24g00.aviretdat: ",mr_cty24g00.aviretdat
      display "mr_cty24g00.aviestcod: ",mr_cty24g00.aviestcod
      display "mr_cty24g00.avivclcod: ",mr_cty24g00.avivclcod
      display "mr_cty24g00.aviprvent: ",mr_cty24g00.aviprvent
                                  
      close ccty24g00_02          
                                  
      #if  l_erro is null then
      
          open ccty24g00_05 using mr_cty24g00.lcvcod,
                                  mr_cty24g00.aviestcod,
                                  mr_cty24g00.avivclcod,
                                  mr_cty24g00.aviretdat,
                                  mr_cty24g00.aviprvent
                                      
          fetch ccty24g00_05 into mr_cty24g00.lcvvcldiavlr,
                                  mr_cty24g00.lcvvclsgrvlr,
                                  mr_cty24g00.prtsgrvlr,   
                                  mr_cty24g00.diafxovlr,   
                                  mr_cty24g00.prtaertaxvlr
      #else
      #    # INTEGRACAO
      #    open ccty24g00_05 using mr_cty24g00.lcvcod,
      #                            mr_cty24g00.aviestcod,
      #                            mr_cty24g00.avivclcod,
      #                            mr_cty24g00.aviretdat,
      #                            mr_cty24g00.atzdianum
      #                                
      #    fetch ccty24g00_05 into mr_cty24g00.lcvvcldiavlr,
      #                            mr_cty24g00.lcvvclsgrvlr,
      #                            mr_cty24g00.prtsgrvlr,   
      #                            mr_cty24g00.diafxovlr,   
      #                            mr_cty24g00.prtaertaxvlr      
      #
      #end if
                                  
      display "RETORNO DOS VALORES DAS DIARIAS."                        
      display "mr_cty24g00.lcvvcldiavlr = ", mr_cty24g00.lcvvcldiavlr                        
      display "mr_cty24g00.lcvvclsgrvlr = ", mr_cty24g00.lcvvclsgrvlr                       
      display "mr_cty24g00.prtsgrvlr    = ", mr_cty24g00.prtsgrvlr                          
      display "mr_cty24g00.diafxovlr    = ", mr_cty24g00.diafxovlr                          
      display "mr_cty24g00.prtaertaxvlr = ", mr_cty24g00.prtaertaxvlr          
      
      
  end if
  
  display "mr_cty24g00.diafxovlr    : ", mr_cty24g00.diafxovlr
  display "mr_cty24g00.prtsgrvlr    : ", mr_cty24g00.prtsgrvlr   
  display "mr_cty24g00.lcvvclsgrvlr : ", mr_cty24g00.lcvvclsgrvlr   
  display "lr_calculo.pagas         : ", lr_calculo.pagas        
  
  
  #Calculo dos Valores        
  if mr_cty24g00.diafxovlr > 0 then
    let lr_calculo.total = mr_cty24g00.diafxovlr + mr_cty24g00.lcvvclsgrvlr
  else                        
    if mr_cty24g00.diafxovlr <= 0 then
      let lr_calculo.total = (mr_cty24g00.prtsgrvlr + mr_cty24g00.lcvvclsgrvlr)   *    
                          lr_calculo.pagas        
    end if                    
  end if 
  
  display "lr_calculo.total         = ", lr_calculo.total        
  display "mr_cty24g00.prtsgrvlr    = ", mr_cty24g00.prtsgrvlr   
  display "mr_cty24g00.lcvvclsgrvlr = ", mr_cty24g00.lcvvclsgrvlr   
  display "lr_calculo.pagas         = ", lr_calculo.pagas        
                  
  if mr_cty24g00.prtaertaxvlr  <>  0  then
    let lr_calculo.total = ((lr_calculo.total * mr_cty24g00.prtaertaxvlr) 
          / 100 ) + lr_calculo.total  
  end if                      
                              
  display "mr_cty24g00.prtaertaxvlr = ", mr_cty24g00.prtaertaxvlr
                              
                              
    #Calculo dos acrescimos.  
    {                         
       Atraso Entrega Veículo 
                              
       01 minutos  a 59 minutos - não é cobrado taxa adicional
       01h00 a 01h59 - cobrado 20% do valor da diaria
       02h00 a 02h59 - cobrado 40% do valor da diária
       03h00 a 03h59 - cobrado 60% do valor da diária
       04h00 a 04h59 - cobrado 80% do valor da diária
       A partir de 05h00 - cobrado 100% do valor da diária
    }                         
                              
  let lr_calculo.acrescimo = 0
                              
  #if  l_erro is not null then
  #                           
  #  let lr_calculo.hreftv = time(mr_cty24g00.vcleftdvldat)
  #  let lr_calculo.diferenca = lr_calculo.hreftv - lr_calculo.hrprev
  #                           
  #  if lr_calculo.diferenca > "5:00" then
  #     let lr_calculo.acrescimo = mr_cty24g00.lcvvcldiavlr
  #  else                     
  #    if lr_calculo.diferenca > "4:00" then
  #      let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.8)
  #    else                   
  #      if lr_calculo.diferenca > "3:00" then
  #        let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.6)
  #      else                 
  #        if lr_calculo.diferenca > "2:00" then
  #          let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.4)
  #        else               
  #          if lr_calculo.diferenca > "1:00" then
  #            let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.2)  
  #          else             
              let lr_calculo.acrescimo = 0
  #          end if           
  #        end if             
  #      end if               
  #    end if                 
  #  end if                   
                              
    display "ACRESCIMO: ", lr_calculo.acrescimo
                              
    display "lr_calculo.total     = ", lr_calculo.total    
    display "lr_calculo.acrescimo = ", lr_calculo.acrescimo
    
    let lr_calculo.total = lr_calculo.total + lr_calculo.acrescimo
                              
  #end if                     
                              
  #select sum(aviprodiaqtd)
  #  into a_ctb02m06[arr_aux].qtd_solic
  #  from datmprorrog
  # where atdsrvnum = a_ctb02m06[arr_aux].atdsrvnum
  #   and atdsrvano = a_ctb02m06[arr_aux].atdsrvano
  #   and aviprostt = "A"
  #   and vclretdat between ws.rsrincdat and ws.rsrfnldat  
  
  
 # if  l_erro is null then  
 #     return l_flag,                           
 #            mr_cty24g00.qtd_sol,           
 #            lr_calculo.utilizadas,           
 #            lr_calculo.pagas,                
 #            lr_calculo.total  
 # else
      return l_flag,                           
             l_param.qtd_sol,           
             lr_calculo.utilizadas,           
             lr_calculo.pagas,                
             lr_calculo.total      
 # end if               

  #BURINI open ccty24g00_01  using l_param.atdsrvnum, 
  #BURINI                          l_param.atdsrvano  
  #BURINI fetch ccty24g00_01 into mr_cty24g00.atzdianum,   
  #BURINI                         mr_cty24g00.vcleftretdat, # campo ainda nao existe em producao
  #BURINI                         mr_cty24g00.vcleftdvldat, # campo ainda nao existe em producao
  #BURINI                         mr_cty24g00.vclrethordat,
  #BURINI                         mr_cty24g00.vcldvlhordat  
  #BURINI 
  #BURINI display "RETORNO DOS DADOS DA RESERRVA"
  #BURINI display "mr_cty24g00.atzdianum   : ",mr_cty24g00.atzdianum 
  #BURINI display "mr_cty24g00.vcleftretdat: ",mr_cty24g00.vcleftretdat
  #BURINI display "mr_cty24g00.vcleftdvldat: ",mr_cty24g00.vcleftdvldat
  #BURINI display "mr_cty24g00.vclrethordat: ",mr_cty24g00.vclrethordat
  #BURINI display "mr_cty24g00.vcldvlhordat: ",mr_cty24g00.vcldvlhordat
  #BURINI 
  #BURINI close ccty24g00_01                                             
  #BURINI                                                                
  #BURINI open ccty24g00_02 using l_param.atdsrvnum,                     
  #BURINI                         l_param.atdsrvano                      
  #BURINI fetch ccty24g00_02 into mr_cty24g00.avialgmtv,                 
  #BURINI                         mr_cty24g00.avivclvlr,                 
  #BURINI                         mr_cty24g00.lcvcod,                    
  #BURINI                         mr_cty24g00.aviretdat,                 
  #BURINI                         mr_cty24g00.aviestcod,                 
  #BURINI                         mr_cty24g00.avivclcod,                 
  #BURINI                         mr_cty24g00.aviprvent                  
  #BURINI                                                                
  #BURINI display "RETORNA VALORES DOS CUSTOS DA RESERVA"                
  #BURINI display "mr_cty24g00.avialgmtv: ",mr_cty24g00.avialgmtv        
  #BURINI display "mr_cty24g00.avivclvlr: ",mr_cty24g00.avivclvlr        
  #BURINI display "mr_cty24g00.lcvcod,  : ",mr_cty24g00.lcvcod           
  #BURINI display "mr_cty24g00.aviretdat: ",mr_cty24g00.aviretdat        
  #BURINI display "mr_cty24g00.aviestcod: ",mr_cty24g00.aviestcod        
  #BURINI display "mr_cty24g00.avivclcod: ",mr_cty24g00.avivclcod        
  #BURINI display "mr_cty24g00.aviprvent: ",mr_cty24g00.aviprvent        
  #BURINI                                                                
  #BURINI close ccty24g00_02                                             
  #BURINI                                                                
  #BURINI display "ANTES NEW"                                            
  #BURINI display "mr_cty24g00.lcvcod    = ", mr_cty24g00.lcvcod         
  #BURINI display "mr_cty24g00.aviestcod = ", mr_cty24g00.aviestcod      
  #BURINI display "mr_cty24g00.avivclcod = ", mr_cty24g00.avivclcod      
  #BURINI display "mr_cty24g00.aviretdat = ", mr_cty24g00.aviretdat      
  #BURINI display "mr_cty24g00.atzdianum = ", mr_cty24g00.atzdianum      
  #BURINI                                                                
  #BURINI open ccty24g00_05 using mr_cty24g00.lcvcod,                    
  #BURINI                         mr_cty24g00.aviestcod,                 
  #BURINI                         mr_cty24g00.avivclcod,                 
  #BURINI                         mr_cty24g00.aviretdat,
  #BURINI                         mr_cty24g00.atzdianum                  
  #BURINI                                                                
  #BURINI fetch ccty24g00_05 into mr_cty24g00.lcvvcldiavlr,              
  #BURINI                         mr_cty24g00.lcvvclsgrvlr,              
  #BURINI                         mr_cty24g00.prtsgrvlr,                 
  #BURINI                         mr_cty24g00.diafxovlr,                 
  #BURINI                         mr_cty24g00.prtaertaxvlr               
  #BURINI                                                                
  #BURINI close ccty24g00_05                                             
  #BURINI                                                                
  #BURINI display "SQLCA.sqlcode = ", sqlca.sqlcode                      
  #BURINI                                                                
  #BURINI display "NEW"                                                  
  #BURINI display "mr_cty24g00.lcvvcldiavlr = ", mr_cty24g00.lcvvcldiavlr
  #BURINI display "mr_cty24g00.lcvvclsgrvlr = ", mr_cty24g00.lcvvclsgrvlr
  #BURINI display "mr_cty24g00.prtsgrvlr    = ", mr_cty24g00.prtsgrvlr   
  #BURINI display "mr_cty24g00.diafxovlr    = ", mr_cty24g00.diafxovlr   
  #BURINI display "mr_cty24g00.prtaertaxvlr = ", mr_cty24g00.prtaertaxvlr  
  #BURINI 
  #BURINI if  not l_vlrrec then
  #BURINI 
  #BURINI     call cty24g00_chk_int(l_param.atdsrvnum, l_param.atdsrvano,"C")
  #BURINI         returning l_erro 
  #BURINI         
  #BURINI     if mr_cty24g00.vcleftretdat is not null and
  #BURINI        mr_cty24g00.vcleftdvldat is not null then
  #BURINI          
  #BURINI          let lr_calculo.retirada = mdy(month(mr_cty24g00.vcleftretdat),
  #BURINI                                          day(mr_cty24g00.vcleftretdat),
  #BURINI                                          year(mr_cty24g00.vcleftretdat))
  #BURINI          
  #BURINI          let lr_calculo.devolucao = mdy(month(mr_cty24g00.vcleftdvldat),
  #BURINI                                           day(mr_cty24g00.vcleftdvldat),
  #BURINI                                            year(mr_cty24g00.vcleftdvldat))
  #BURINI         
  #BURINI         let lr_calculo.utilizadas = lr_calculo.devolucao - lr_calculo.retirada
  #BURINI         
  #BURINI         #calculo dos dias pagos
  #BURINI         if lr_calculo.utilizadas < mr_cty24g00.atzdianum then
  #BURINI           display "DIAS AUTORIZADOS MAIOR QUE O DIA UTILIZADO"
  #BURINI           display "UTILIZA OS DIAS UTILIZADOS"
  #BURINI           let lr_calculo.pagas = lr_calculo.utilizadas
  #BURINI         else
  #BURINI           display "DIAS AUTORIZADOS MENOR QUE O DIA UTILIZADO"
  #BURINI           display "UTILIZA OS DIAS AUTORIZADOS"
  #BURINI           let lr_calculo.pagas = mr_cty24g00.atzdianum
  #BURINI           let l_flag = true
  #BURINI         end if      
  #BURINI     else
  #BURINI       let lr_calculo.utilizadas = mr_cty24g00.atzdianum
  #BURINI     end if          
  #BURINI else  
  #BURINI     let lr_calculo.utilizadas = l_param.c24utidiaqtd    
  #BURINI     let lr_calculo.pagas      = l_param.c24pagdiaqtd  
  #BURINI     display "NAO EH VIA INTEGRAÇÂO: " 
  #BURINI     display "lr_calculo.utilizadas = ", lr_calculo.utilizadas
  #BURINI     display "lr_calculo.pagas      = ", lr_calculo.pagas     
  #BURINI end if
  #BURINI 
  #BURINI 
  #BURINI #if l_erro is null then
  #BURINI 
  #BURINI #  
  #BURINI #  display "SERVICO NAO EH VIA INTEGRACAO"
  #BURINI   
  #BURINI #  
  #BURINI #  # Se nao for por integracao, retorna valores nulos
  #BURINI #  #initialize lr_calculo.utilizadas,
  #BURINI #  #           lr_calculo.pagas,
  #BURINI #  #           lr_calculo.total to null
  #BURINI #
  #BURINI #else
  #BURINI #  
  #BURINI #  display "SERVICO EH VIA INTEGRACAO"
  #BURINI #  
  #BURINI #  let l_flag = true
  #BURINI #  #Busca os valores da diaria
  #BURINI #
  #BURINI #  let lr_calculo.total = 0
  #BURINI #  
  #BURINI #  let lr_calculo.previsao = mr_cty24g00.vcleftretdat + mr_cty24g00.aviprvent units day
  #BURINI #  let lr_calculo.hrprev = time(lr_calculo.previsao)
  #BURINI #  #Calculo dos dias utilizados
  #BURINI 
  #BURINI     
  #BURINI     #  
  #BURINI     #  #dias utilizados
  #BURINI     #  let lr_calculo.utilizadas = l_param.c24utidiaqtd
  #BURINI     #  
  #BURINI     #  #dias pagos
  #BURINI     #  
  #BURINI     #  display "VALORES"
  #BURINI     #  display "lr_calculo.utilizadas = ", lr_calculo.utilizadas
  #BURINI     #  display "lr_calculo.pagas      = ", lr_calculo.pagas     
  #BURINI     #  
  #BURINI     #end if  
  #BURINI   
  #BURINI   #Calculo dos Valores
  #BURINI   if mr_cty24g00.diafxovlr > 0 then
  #BURINI     let lr_calculo.total = mr_cty24g00.diafxovlr + mr_cty24g00.lcvvclsgrvlr
  #BURINI   else 
  #BURINI     if mr_cty24g00.diafxovlr <= 0 then
  #BURINI       let lr_calculo.total = (mr_cty24g00.prtsgrvlr + mr_cty24g00.lcvvclsgrvlr)   *    
  #BURINI                           lr_calculo.pagas        
  #BURINI     end if
  #BURINI   end if
  #BURINI 
  #BURINI   if mr_cty24g00.prtaertaxvlr  <>  0  then
  #BURINI     let lr_calculo.total = ((lr_calculo.total * mr_cty24g00.prtaertaxvlr) 
  #BURINI           / 100 ) + lr_calculo.total  
  #BURINI   end if
  #BURINI   
  #BURINI   display "VALORES PARA CALCULO DA DIARIA"
  #BURINI   display "mr_cty24g00.prtsgrvlr    = ", mr_cty24g00.prtsgrvlr   
  #BURINI   display "mr_cty24g00.lcvvclsgrvlr = ", mr_cty24g00.lcvvclsgrvlr
  #BURINI   display "lr_calculo.pagas         = ", lr_calculo.pagas        
  #BURINI   display "lr_calculo.total         = ", lr_calculo.total        
  #BURINI   
  #BURINI   
  #BURINI   
  #BURINI   
  #BURINI   display "mr_cty24g00.prtaertaxvlr = ", mr_cty24g00.prtaertaxvlr
  #BURINI 
  #BURINI 
  #BURINI   #Calculo dos acrescimos.
  #BURINI   {
  #BURINI      Atraso Entrega Veículo
  #BURINI 
  #BURINI      01 minutos  a 59 minutos - não é cobrado taxa adicional
  #BURINI      01h00 a 01h59 - cobrado 20% do valor da diaria
  #BURINI      02h00 a 02h59 - cobrado 40% do valor da diária
  #BURINI      03h00 a 03h59 - cobrado 60% do valor da diária
  #BURINI      04h00 a 04h59 - cobrado 80% do valor da diária
  #BURINI      A partir de 05h00 - cobrado 100% do valor da diária
  #BURINI   }
  #BURINI   
  #BURINI   #let lr_calculo.acrescimo = 0
  #BURINI   #
  #BURINI   #display "VALOR DO SERVICO:"
  #BURINI   #display "lr_calculo.total = ", lr_calculo.total
  #BURINI   #
  #BURINI   #if l_erro is not null then
  #BURINI   #
  #BURINI   #let lr_calculo.hreftv = time(mr_cty24g00.vcleftdvldat)
  #BURINI   #let lr_calculo.diferenca = lr_calculo.hreftv - lr_calculo.hrprev
  #BURINI   #
  #BURINI   #if lr_calculo.diferenca > "5:00" then
  #BURINI   #   let lr_calculo.acrescimo = mr_cty24g00.lcvvcldiavlr
  #BURINI   #else
  #BURINI   #  if lr_calculo.diferenca > "4:00" then
  #BURINI   #    let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.8)
  #BURINI   #  else
  #BURINI   #    if lr_calculo.diferenca > "3:00" then
  #BURINI   #      let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.6)
  #BURINI   #    else
  #BURINI   #      if lr_calculo.diferenca > "2:00" then
  #BURINI   #        let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.4)
  #BURINI   #      else
  #BURINI   #        if lr_calculo.diferenca > "1:00" then
  #BURINI   #          let lr_calculo.acrescimo = (mr_cty24g00.lcvvcldiavlr * 0.2)  
  #BURINI   #        else
  #BURINI   #          let lr_calculo.acrescimo = 0
  #BURINI   #        end if
  #BURINI   #      end if
  #BURINI   #    end if
  #BURINI   #  end if
  #BURINI   #end if
  #BURINI  #end if
  #BURINI   
  #BURINI   display "TOTAL ACRESCIMO"
  #BURINI   display "lr_calculo.acrescimo = ", lr_calculo.acrescimo
  #BURINI   
  #BURINI   let lr_calculo.total = lr_calculo.total + lr_calculo.acrescimo
  #BURINI   
  #BURINI   display "TOTAL 2: ", lr_calculo.total
  #BURINI 
  #BURINI display "l_flag                = ", l_flag                              
  #BURINI display "mr_cty24g00.atzdianum = ", mr_cty24g00.atzdianum
  #BURINI display "lr_calculo.utilizadas = ", lr_calculo.utilizadas
  #BURINI display "lr_calculo.pagas      = ", lr_calculo.pagas     
  #BURINI display "lr_calculo.total      = ", lr_calculo.total     
  #BURINI 
  #BURINI 
  #BURINI return l_flag,
  #BURINI        mr_cty24g00.atzdianum,
  #BURINI        lr_calculo.utilizadas,
  #BURINI        lr_calculo.pagas,
  #BURINI        lr_calculo.total

end function


#----------------------
report cty24g00_relatorio_op(l_param)
#----------------------
  
  define l_param record
         socopgnum    like dbsmopgitm.socopgnum,   # 1
         flag         smallint,                    # 2
         total        like datmavisrent.avivclvlr, # 3
         solicitadas  smallint,                    # 4
         pagas        smallint,                    # 5
         utilizadas   smallint, #dias utilizados   # 6     
         atdsrvnum    like datmservico.atdsrvnum,  # 7
         atdsrvano    like datmservico.atdsrvano,  # 8
         atddat       like datmservico.atddat,     # 9
         atdhor       like datmservico.atdhor,     # 10
         contador     integer,
         cabecalho    char(200)
  end record
  
  output 

     left   margin    00 
     right  margin    00 
     top    margin    00 
     bottom margin    00 
     page   length    04 

  format

     first page header
        print l_param.cabecalho
        print "" 
        print "Numero OP"         , ASCII(09),
              "Item OP"           , ASCII(09),
              "Numero do Servico" , ASCII(09),
              "Ano do Servico"    , ASCII(09),
              "Data do Servico"   , ASCII(09),
              "Hora do Servico"   , ASCII(09),
              "Dias Solicitados"  , ASCII(09),
              "Dias Utilizados"   , ASCII(09),
              "Dias Pagos"        , ASCII(09),
              "Valor Total"       , ASCII(09)
            
  on every row
        
        print l_param.socopgnum   , ASCII(09);
        print l_param.contador    , ASCII(09);
        print l_param.atdsrvnum   , ASCII(09);
        print l_param.atdsrvano   , ASCII(09);
        print l_param.atddat      , ASCII(09);
        print l_param.atdhor      , ASCII(09);
        print l_param.solicitadas , ASCII(09);
        print l_param.utilizadas  , ASCII(09);
        print l_param.pagas       , ASCII(09);
        print l_param.total using "######.##"  
       
end report