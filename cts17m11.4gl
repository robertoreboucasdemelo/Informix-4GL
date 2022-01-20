#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: cts17m11                                                   #
# ANALISTA RESP..: BEATRIZ ARAUJO                                             #
# PSI/OSF........: 219444                                                     #
#                  NOTIFICAÇÕES DE SERVIÇOS RE AO SISTEMA RE                  #
#                                                                             #
# ........................................................................... #
# DESENVOLVIMENTO: BEATRIZ ARAUJO                                             #
# LIBERACAO......: **********                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto
globals "/homedsa/projetos/geral/globals/glct.4gl"

#para verificar se troca de natureza no servico quando é atendimento HelpDesk
define m_socntzcod     like datmsrvre.socntzcod

# Verifica se é para notificar pagamento
define m_socopgitmvlr like dbsmopgitm.socopgitmvlr


# Verifica se eh a carga dos serviço para saber se ocorreu erro
define m_erro record
       codigo       smallint,
       mensagem     char(5000)
end record

#============================================
function cts17m11_prepare()
#============================================

define l_sql char(6000)

  let l_sql  =  null

  let l_sql = "select succod,       ",
              "       ramcod,       ",
              "       aplnumdig     ",
              "  from datrservapol  ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "

  prepare p_cts17m11_001 from l_sql
  declare c_cts17m11_001 cursor for p_cts17m11_001
  let l_sql = "select ciaempcod,    ",
              "       atdcstvlr     ",
              "  from datmservico   ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "

  prepare pcts17m11_002 from l_sql
  declare ccts17m11_002 cursor for pcts17m11_002
  let l_sql = "select lclnumseq,    ",
              "       rmerscseq,    ",
              "       socntzcod,    ",
              "       sinntzcod,    ",
              "       srvretmtvcod, ",
              "       atdorgsrvnum, ",
              "       atdorgsrvano  ",
              "    from datmsrvre   ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "
  prepare pcts17m11_003 from l_sql
  declare ccts17m11_003 cursor for pcts17m11_003
  let l_sql = "select a.prporg,                       ",
              "       a.prpnumdig                     ",
              "  from datrligprp a                    ",
              "where a.lignum = (select min(lignum)   ",
              "                   from datmligacao    ",
              "                   where atdsrvnum = ? ",
              "                     and atdsrvano = ?)"
  prepare pcts17m11_004 from l_sql
  declare ccts17m11_004 cursor for pcts17m11_004
  let l_sql = "select atddat,    ",
              "       atdhor     ",
              "  from datmservico   ",
              " where atdsrvnum = ? ",
              "   and atdsrvano = ? "

  prepare pcts17m11_005 from l_sql
  declare ccts17m11_005 cursor for pcts17m11_005
  let l_sql = "select max(atdetpcod) ",
              "  from datmsrvacp     ",
              " where atdsrvnum = ?  ",
              "   and atdsrvano = ?  "

  prepare pcts17m11_006 from l_sql
  declare ccts17m11_006 cursor for pcts17m11_006
  let l_sql = "select atdetpdat,   ",
              "       atdetphor    ",
              "  from datmsrvacp   ",
              " where atdetpcod = ?"

  prepare pcts17m11_007 from l_sql
  declare ccts17m11_007 cursor for pcts17m11_007
end function


#Verifica a qual grupo de ramo o serviço pertence
#==========================================
function cts17m11_tiposervico(param)
#==========================================
 define param         record
     atdsrvnum        like datmservico.atdsrvnum,
     atdsrvano        like datmservico.atdsrvano
 end record

 define lr_retorno    record
        resultado     smallint
       ,mensagem      char(60)
       ,ramgrpcod     like gtakram.ramgrpcod
 end record
 define l_cts17m11    record
        succod        like datrservapol.succod,
        ramcod        like gtakram.ramcod,
        aplnumdig     like datrservapol.aplnumdig,
        ciaempcod     like datmservico.ciaempcod,
        atdcstvlr     like datmservico.atdcstvlr,
        lclnumseq     like datmsrvre.lclnumseq,
        rmerscseq     like datmsrvre.rmerscseq,
        socntzcod     like datmsrvre.socntzcod,
        sinntzcod     like datmsrvre.sinntzcod,
        srvretmtvcod  like datmsrvre.srvretmtvcod,
        atdorgsrvnum  like datmsrvre.atdorgsrvnum,
        atdorgsrvano  like datmsrvre.atdorgsrvano,
        prporg        like datrligprp.prporg,
        prpnumdig     like datrligprp.prpnumdig,
        atdcod	      decimal(2,0),#1 – Atendimento dentro do limite da clausula – Paga pelo Produto
                                   #2 – Atendimento em cortesia – Paga pelo Produto
                                   #3 – Atendimento em cortesia – Paga por Centro de Custo diferente do Produto.
                                   #9 - Erro na determinação do tipo de cortesia
        errorcod      smallint,# 0-OK / <>0-erro
        errormsg      char(60)
 end record
          #====================
             call cts17m11_prepare()
          #====================

 initialize lr_retorno.* to null
#===========procura a sucursal, o ramo e o numero da apólice na tabela datrservapol
  whenever error continue
	  open c_cts17m11_001 using param.atdsrvnum,
	                           param.atdsrvano
	  fetch c_cts17m11_001 into l_cts17m11.succod,
	                           l_cts17m11.ramcod,
	                           l_cts17m11.aplnumdig
	  close c_cts17m11_001
	  if sqlca.sqlcode = notfound then
	     #===========porcura Origem da proposta e Numero da proposta na tabela datrligprp
             #=========== mas antes procura na tabela datmligacao o número da ligacao(lignum)
             open ccts17m11_004 using param.atdsrvnum,
                                      param.atdsrvano
             fetch ccts17m11_004 into l_cts17m11.prporg,
                                      l_cts17m11.prpnumdig
             close ccts17m11_004
             if sqlca.sqlcode <> notfound then
                 #display "=== Proposta ==="
                 #display "prporg   :",l_cts17m11.prporg
                 #display "prpnumdig:", l_cts17m11.prpnumdig
                 #display "=== Fim Proposta ==="
             end if
          else
            #display "=== Apolice ==="
            #display "succod   : ",l_cts17m11.succod
            #display "ramcod   : ",l_cts17m11.ramcod
            #display "aplnumdig: ",l_cts17m11.aplnumdig
            #display "=== Fim Apolice ==="
          end if
  whenever error stop
#===========porcura a ciaempcod e o valor do atendimento na tabela datmservico
  whenever error continue
	  open ccts17m11_002 using param.atdsrvnum,
	                           param.atdsrvano
	  fetch ccts17m11_002 into l_cts17m11.ciaempcod,
	                           l_cts17m11.atdcstvlr
	  close ccts17m11_002
  whenever error stop
  #display "=== Cia e valor ==="
  #display "ciaempcod: ",l_cts17m11.ciaempcod
  #display "atdcstvlr: ",l_cts17m11.atdcstvlr
  #display "=== Fim Cia e valor ==="
#===========porcura Seq Local risco,Seq Risco (bloco),natureza, tipo do movimento
#=========== numero original do servico e ano original do servico
#=========== do servico na tabela datmsrvre
  whenever error continue
	  open ccts17m11_003 using param.atdsrvnum,
	                           param.atdsrvano
	  fetch ccts17m11_003 into l_cts17m11.lclnumseq,
	                           l_cts17m11.rmerscseq,
	                           l_cts17m11.socntzcod,
	                           l_cts17m11.sinntzcod,
	                           l_cts17m11.srvretmtvcod,
	                           l_cts17m11.atdorgsrvnum,
	                           l_cts17m11.atdorgsrvano
	  close ccts17m11_003
	  #display "=== Local ==="
	  #display "lclnumseq: ",l_cts17m11.lclnumseq
	  #display "rmerscseq: ",l_cts17m11.rmerscseq
	  #display "=== Fim Local ==="
	  #display "=== Natureza ==="
	  #display "socntzcod   : ",l_cts17m11.socntzcod
	  #display "srvretmtvcod: ",l_cts17m11.srvretmtvcod
	  #display "=== Fim Natureza ==="
  whenever error stop

#===========Verifica o codigo do grupo do ramo

 call cty10g00_grupo_ramo(l_cts17m11.ciaempcod,l_cts17m11.ramcod)
      returning lr_retorno.resultado, # 1- Achou , 2- não encontrou, 3- deu erro
                lr_retorno.mensagem ,
                lr_retorno.ramgrpcod  # 4- RE

#=CHAMA A CENTRAL PARA SABER SE É CORTESIA
 call cta14m00(param.atdsrvnum,
               param.atdsrvano)
     returning l_cts17m11.atdcod,
               l_cts17m11.errorcod,
               l_cts17m11.errormsg
 if  l_cts17m11.errorcod <> 0 then
     error l_cts17m11.errormsg clipped
     error l_cts17m11.errorcod
     let l_cts17m11.errormsg = "Erro no retorno da cortesia e mensagem: ",l_cts17m11.errorcod," - ",l_cts17m11.errormsg  clipped
     display "l_cts17m11.errormsg: ",l_cts17m11.errormsg  clipped
     #call errorlog(l_cts17m11.errormsg)
     error l_cts17m11.errormsg clipped
     sleep 2
     let l_cts17m11.atdcod = 9
 end if
   # verifica se é pra trocar a natureza do serviço,
   # pois o assunto mudou de S67 para S66
   #display " "
   #display "=== Verifica se é para trocar ==="
   #display "m_socntzcod: ",m_socntzcod
   if m_socntzcod is not null  and
      m_socntzcod <> 0 then
      let l_cts17m11.socntzcod = m_socntzcod
      #display "troquei natureza: ", l_cts17m11.socntzcod
   end if
   #display "=== Fim Natureza ==="
   #---------------------------------------------
   # verifica se é pra notificar o pagamento do serviço
   if m_socopgitmvlr is not null and
      m_socopgitmvlr <> 0 then
      let l_cts17m11.atdcstvlr = m_socopgitmvlr
   end if
   #---------------------------------------------
  return lr_retorno.resultado    ,
         lr_retorno.mensagem     ,
         lr_retorno.ramgrpcod    ,
         l_cts17m11.succod       ,
         l_cts17m11.ramcod       ,
         l_cts17m11.aplnumdig    ,
         l_cts17m11.ciaempcod    ,
         l_cts17m11.atdcstvlr    ,
         l_cts17m11.lclnumseq    ,
         l_cts17m11.rmerscseq    ,
         l_cts17m11.socntzcod    ,
         l_cts17m11.sinntzcod    ,
         l_cts17m11.srvretmtvcod ,
         l_cts17m11.atdorgsrvnum ,
         l_cts17m11.atdorgsrvano ,
         l_cts17m11.prporg       ,
         l_cts17m11.prpnumdig    ,
         l_cts17m11.atdcod
end function
#Avisa ao Sistema RE que foi agendado um serviço
#====================================================
function cts17m11_agendasrvre(param)
#====================================================
define param         record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atddat           like datmservico.atddat   ,
    atdhor           like datmservico.atdhor   ,
    tipflag          char(1) # para saber se e a carga dos serviços
                                  # onde 'N' e normal e 'C' eh a carga
end record

define operacao  smallint

initialize m_socopgitmvlr to null

let operacao  = 1
     #Chama o RE para notificar que foi agendado um serviço
     #display "================ Agendar Parametros =================="
     #display "param.atdsrvnum: ",param.atdsrvnum
     #display "param.atdsrvano: ",param.atdsrvano
     #display "param.atddat   : ",param.atddat
     #display "param.atdhor   : ",param.atdhor
     #display "operacao       : ",operacao
 
     call cts17m11_notificar(param.atdsrvnum,
                             param.atdsrvano,
                             param.atddat,
                             param.atdhor,
                             operacao) #foi agendado um serviço
    if param.tipflag = 'C' then
       #display "m_erro.codigo  : ",m_erro.codigo
       #display "m_erro.mensagem: ",m_erro.mensagem
       return m_erro.codigo,
              m_erro.mensagem
    end if
 end function

#Notifica ao RE que foi cancelado um Servico
#======================================================
function cts17m11_cancelasrvre(param)
#======================================================

define param         record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    atdetpdat        like datmsrvacp.atdetpdat ,
    atdetphor        like datmsrvacp.atdetphor ,
    tipflag          char(1) # para saber se e a carga dos serviços
                                  # onde 'N' e normal e 'C' eh a carga
end record

define operacao  smallint
initialize m_socopgitmvlr to null

let operacao  = 2

       #Chama o RE para notificar que foi cancelado um Servico
        #display "================ Cancelar =================="
        #display "cts17m11_cancelasrvre ->param.atdsrvnum: ",param.atdsrvnum
        #display "cts17m11_cancelasrvre ->param.atdsrvano: ",param.atdsrvano
        #display "cts17m11_cancelasrvre ->param.atdetpdat: ",param.atdetpdat
        #display "cts17m11_cancelasrvre ->param.atdetphor: ",param.atdetphor
        #display "cts17m11_cancelasrvre ->operacao       : ",operacao
       call cts17m11_notificar(param.atdsrvnum,
                               param.atdsrvano,
                               param.atdetpdat,
                               param.atdetphor,
                               operacao) #foi cancelado um Servico
    if param.tipflag = 'C' then
       return m_erro.*
    end if
end function



#Notifica ao RE que foi estornado(Cancelado) um Servico
#======================================================
function cts17m11_estornosrvre(param)
#======================================================

define param         record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    datacancela      date                      ,
    horacancela      datetime hour to second
end record

define operacao  smallint


let operacao  = 4
       #Chama o RE para notificar que foi estornado(Cancelado) um Servico
       call cts17m11_notificar(param.atdsrvnum,
                               param.atdsrvano,
                               param.datacancela,
                               param.horacancela,
                               operacao) #foi estornado(Cancelado) um Servico
end function

#Notifica ao RE que foi pago um Servico
#======================================================
function cts17m11_pagosrvre(param)
#======================================================

define param         record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    socfatpgtdat     like dbsmopg.socfatpgtdat ,
    socopgitmvlr     like dbsmopgitm.socopgitmvlr,
    tipflag          char(1) # para saber se e a carga dos serviços
                                  # onde 'N' e normal e 'C' eh a carga
end record

define horapgto      datetime hour to minute

define operacao  smallint

initialize m_socopgitmvlr to null

let operacao  = 3

let m_socopgitmvlr = param.socopgitmvlr

let horapgto = current
       #Chama o RE para notificar que foi pago um Servico
        #display "================ Pagamento =================="
       call cts17m11_notificar(param.atdsrvnum,
                               param.atdsrvano,
                               param.socfatpgtdat,
                               horapgto,
                               operacao) #foi pago um Servico
      if param.tipflag = 'C' then
       return m_erro.*
    end if
end function


# Quando o servico HelpDesk não gerar visita o assunto muda de
# S67 para S66, a natureza também muda, então temos que avisar o RE
# para cancelar o servico com a natureza do S67 e agendar o servico
# com a natureza do S66
#======================================================
function cts17m11_mudanatureza(param)
#======================================================
define param        record
   atdsrvnum        like datmservico.atdsrvnum,
   atdsrvano        like datmservico.atdsrvano,
  ntzcod_old        like datmsrvre.socntzcod,
  ntzcod_new        like datmsrvre.socntzcod
end record

define cts17m11_data record
   atddat            like datmservico.atddat ,
   atdhor            like datmservico.atdhor
end record

initialize m_socntzcod,m_socopgitmvlr,cts17m11_data.* to null

 #display "================ Parametros de troca de Natureza =================="
 #display "atdsrvnum :  ",param.atdsrvnum
 #display "atdsrvano :  ",param.atdsrvano
 #display "ntzcod_old:  ",param.ntzcod_old
 #display "ntzcod_new:  ",param.ntzcod_new
 #display "================ Fim Parametros de troca de Natureza =================="
 whenever error continue
     open ccts17m11_005 using param.atdsrvnum,
                              param.atdsrvano
    fetch ccts17m11_005 into cts17m11_data.atddat,
                             cts17m11_data.atdhor
 whenever error stop
 let m_socntzcod = param.ntzcod_old

 #display "================ Parametros de troca de Natureza Cancela =================="
 #display "atdsrvnum           : ",param.atdsrvnum
 #display "atdsrvano           : ",param.atdsrvano
 #display "cts17m11_data.atddat: ",cts17m11_data.atddat
 #display "cts17m11_data.atdhor: ",cts17m11_data.atdhor
 #display "natureza           : ", m_socntzcod
 #display "================ Fim Parametros de troca de Natureza Cancela=================="
 #Notificar ao RE que não é pra contabilizar esse serviço, pois trocou a natureza
 call cts17m11_cancelasrvre(param.atdsrvnum,
                            param.atdsrvano,
                            cts17m11_data.atddat,
                            cts17m11_data.atdhor,
                            'N')
 let m_socntzcod = param.ntzcod_new
 #display "================ Parametros de troca de Natureza Agenda =================="
 #display "atdsrvnum           : ",param.atdsrvnum
 #display "atdsrvano           : ",param.atdsrvano
 #display "cts17m11_data.atddat: ",cts17m11_data.atddat
 #display "cts17m11_data.atdhor: ",cts17m11_data.atdhor
 #display "natureza            : ", m_socntzcod
 #display "================ Fim Parametros de troca de Natureza Agenda=================="

 #Notificar ao RE que é pra contabilizar esse serviço, com a nova natureza
 call cts17m11_agendasrvre(param.atdsrvnum,
                           param.atdsrvano,
                           cts17m11_data.atddat,
                           cts17m11_data.atdhor,
                           'N')
 initialize m_socntzcod,m_socopgitmvlr,cts17m11_data.* to null
end function

#Verificar se é pra notificar o agendamento ou cancelamento
# do servico feito na contingencia
#======================================================
function cts17m11_notificaContingencia(param)
#======================================================

define param         record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
end record

define l_datahora    record
    atdetpdat        like datmsrvacp.atdetpdat,
    atdetphor        like datmsrvacp.atdetphor
end record

define operacao  smallint

  whenever error continue
    open ccts17m11_006 using param.atdsrvnum,
                             param.atdsrvano
    fetch ccts17m11_006 into operacao
     if sqlca.sqlcode = 0 then
        whenever error continue
           open ccts17m11_007 using operacao
           fetch ccts17m11_007 into l_datahora.atdetpdat,
                                    l_datahora.atdetphor
        whenever error stop
     end if
  whenever error stop
    #display "==================Contingencia========================"
    #display "operacao            : ",operacao
    #display "l_datahora.atdetpdat: ",l_datahora.atdetpdat
    #display "l_datahora.atdetphor: ",l_datahora.atdetphor
    if operacao = 5 then
       #Chama o RE para notificar que foi cancelado um Servico
       let operacao = 2
        #display "================ Cancelar Contingencia=================="
        call cts17m11_notificar(param.atdsrvnum,
                                param.atdsrvano,
                                l_datahora.atdetpdat,
                                l_datahora.atdetphor,
                                operacao) #foi cancelado um Servico
    else
      if  operacao = 1 or
          operacao = 2 then
          let operacao = 1
          #Chama o RE para notificar que foi agendado um serviço
          #display "================ Agendar Contingencia =================="
          call cts17m11_notificar(param.atdsrvnum,
                                  param.atdsrvano,
                                  l_datahora.atdetpdat,
                                  l_datahora.atdetphor,
                                  operacao) #foi agendado um serviço
      end if
    end if
end function


#Busca a desrição da cláusula do RE
#======================================================
function cts17m11_descricaoclaure(lr_par_in)
#======================================================

    define lr_par_in   record
           ramcod      like rgfkclaus2.ramcod,    	# Ramo
           rmemdlcod   like rsamseguro.rmemdlcod, 	# Modalidade
           clscod      like rgfkclaus2.clscod     	# Cod da Clausula
    end record
    define lr_par_out  record
           result    smallint,   	# Resultado: 0-Ok 1-Erro banco
           msgerr    char(100)          # Mensagem de erro
    end record
    define l_clsdes    like rgfkclaus2.clsdes     # Descr. Clausula
      #display "lr_par_in.ramcod,   : ",lr_par_in.ramcod
      #display "lr_par_in.rmemdlcod,: ",lr_par_in.rmemdlcod
      #display "lr_par_in.clscod)   : ",lr_par_in.clscod
      call framo240_desc_claus(lr_par_in.ramcod,lr_par_in.rmemdlcod,lr_par_in.clscod)
           returning lr_par_out.result,
                     lr_par_out.msgerr,
                     l_clsdes
      #display "lr_par_out.result,: ",lr_par_out.result
      #display "lr_par_out.msgerr,: ",lr_par_out.msgerr
      #display "l_clsdes          : ",l_clsdes
      #display "----------------------------------------------------------"
      if lr_par_out.result <> 0 then
           let l_clsdes = lr_par_out.msgerr
      end if
    return l_clsdes
end function


#Notifica RE conforme o codigo passado como parametro
#======================================================
function cts17m11_notificar(param)
#======================================================

define param         record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    mvtdat           like datmservico.atddat   ,
    mvthor           like datmservico.atdhor   ,
    mvtip            smallint
end record


define lr_retorno    record
        resultado     smallint,
        mensagem      char(60),
        ramgrpcod     like gtakram.ramgrpcod,
        succod        like datrservapol.succod,
        ramcod        like gtakram.ramcod,
        aplnumdig     like datrservapol.aplnumdig,
        ciaempcod     like datmservico.ciaempcod,
        atdcstvlr     like datmservico.atdcstvlr,
        lclnumseq     like datmsrvre.lclnumseq,
        rmerscseq     like datmsrvre.rmerscseq,
        socntzcod     like datmsrvre.socntzcod,
        sinntzcod     like datmsrvre.sinntzcod,
        srvretmtvcod  like datmsrvre.srvretmtvcod,
        atdorgsrvnum  like datmsrvre.atdorgsrvnum,
        atdorgsrvano  like datmsrvre.atdorgsrvano,
        prporg        like datrligprp.prporg,
        prpnumdig     like datrligprp.prpnumdig,
        atdcod	      decimal(2,0),#1 – Atendimento dentro do limite da clausula – Paga pelo Produto
                                   #2 – Atendimento em cortesia – Paga pelo Produto
                                   #3 – Atendimento em cortesia – Paga por Centro de Custo diferente do Produto.
                                   #9 - Erro na determinação do tipo de cortesia
        result        smallint,    # 0- OK 1 - Erro (Função framo241_atu_hstultsrvemr )
        msgerr        char(100)

 end record
 define trace smallint
 
 define dt_mvthor datetime hour to second # CT 14029508
 define d_nulo    like datmservico.atddat # CT 14029508 
 initialize dt_mvthor, d_nulo to null     # CT 14029508 

 initialize lr_retorno.* to null
#display "=== Parametros de entrada ==="
#display "param.atdsrvnum",param.atdsrvnum
#display "param.atdsrvano",param.atdsrvano
#display "param.mvtdat   ",param.mvtdat
#display "param.mvthor   ",param.mvthor
#display "param.mvtip    ",param.mvtip
#display "=== Fim Parametros de entrada ==="
 call cts40g03_data_hora_banco(1) returning d_nulo, dt_mvthor # CT 14029508 
 sleep 1 # aguardar 1 segundo pois é indice na entidade rgfmhstemrsrvutl
   #===========verifica de qual grupo de ramo é o servico
 call cts17m11_tiposervico(param.atdsrvnum,
                           param.atdsrvano)
      returning lr_retorno.resultado   , # 1- Achou , 2- não encontrou, 3- deu erro
                lr_retorno.mensagem    ,
                lr_retorno.ramgrpcod   ,  # 4- RE
                lr_retorno.succod      ,
                lr_retorno.ramcod      ,
                lr_retorno.aplnumdig   ,
                lr_retorno.ciaempcod   ,
                lr_retorno.atdcstvlr   ,
                lr_retorno.lclnumseq   ,
                lr_retorno.rmerscseq   ,
                lr_retorno.socntzcod   ,
                lr_retorno.sinntzcod   ,
                lr_retorno.srvretmtvcod,
                lr_retorno.atdorgsrvnum,
                lr_retorno.atdorgsrvano,
                lr_retorno.prporg      ,
                lr_retorno.prpnumdig   ,
                lr_retorno.atdcod
        #display "=== Parametros de retorno ==="
        #display "lr_retorno.atdcstvlr   : ",lr_retorno.atdcstvlr
        #display "lr_retorno.lclnumseq   : ",lr_retorno.lclnumseq
        #display "lr_retorno.rmerscseq   : ",lr_retorno.rmerscseq
        #display "lr_retorno.socntzcod   : ",lr_retorno.socntzcod
        #display "lr_retorno.srvretmtvcod: ",lr_retorno.srvretmtvcod
        #display "lr_retorno.atdcod      : ",lr_retorno.atdcod
        #display "lr_retorno.ramgrpcod   : ",lr_retorno.ramgrpcod
        #display "=== Fim parametros de rotorno ==="
  if lr_retorno.resultado = 1 and
     lr_retorno.ramgrpcod = 4 then
       if lr_retorno.atdorgsrvnum is null or
          lr_retorno.atdorgsrvano is null then
             let lr_retorno.atdorgsrvnum = param.atdsrvnum
             let lr_retorno.atdorgsrvano = param.atdsrvano
       end if
       if lr_retorno.srvretmtvcod = 1 then
           let param.mvtip = 5
       else
         if lr_retorno.srvretmtvcod = 2 then
           let param.mvtip = 6
         end if
       end if
       # Chama o RE para notificar
       let trace = false
       # Verifica se o servico eh de SINISTRO RE, esse tipo de servico nao contabiliza
       if lr_retorno.sinntzcod is null then

          call framo241_atu_hstutlsrvemr(trace                  ,
                                         lr_retorno.succod      ,
                                         lr_retorno.ramcod      ,
                                         lr_retorno.aplnumdig   ,
                                         lr_retorno.prporg      ,
                                         lr_retorno.prpnumdig   ,
                                         lr_retorno.lclnumseq   ,
                                         lr_retorno.rmerscseq   ,
                                         lr_retorno.socntzcod   ,
                                         param.mvtdat           ,
                                         dt_mvthor              , # para efetivar inclusao na funcao tem q passar HH:MM:SS
                                        #param.mvthor           ,
                                         param.mvtip            ,
                                         lr_retorno.atdcod      ,
                                         lr_retorno.atdcstvlr   ,
                                         param.atdsrvnum        ,
                                         param.atdsrvano        ,
                                         lr_retorno.atdorgsrvnum,
                                         lr_retorno.atdorgsrvano )
                               returning lr_retorno.result,
                                         lr_retorno.msgerr
          if lr_retorno.result <> 0 then
             let lr_retorno.msgerr = "Erro ao notificar RE: ",param.atdsrvnum,"/",param.atdsrvano,
                                        " Mensagem: ",lr_retorno.msgerr
                                        display "lr_retorno.mensagem: ",lr_retorno.mensagem
              #call errorlog(lr_retorno.msgerr)
             let m_erro.codigo = lr_retorno.result
             let m_erro.mensagem = lr_retorno.msgerr
             let lr_retorno.mensagem  = lr_retorno.msgerr
          else
             let m_erro.codigo = lr_retorno.result
             let m_erro.mensagem = lr_retorno.msgerr
             let lr_retorno.mensagem  = lr_retorno.msgerr
          end if
       end if
   else
      if lr_retorno.resultado = 2 or
         lr_retorno.resultado = 3 then
           let lr_retorno.mensagem = "Servico: ",param.atdsrvnum,"/",param.atdsrvano,
                                     " Mensagem: ",lr_retorno.mensagem
                                     display "lr_retorno.mensagem: ",lr_retorno.mensagem
           #call errorlog(lr_retorno.mensagem)
           let m_erro.codigo = lr_retorno.result
           let m_erro.mensagem = lr_retorno.msgerr
      else
           #===========não é apólice RE
            let lr_retorno.mensagem = "Serico não RE: ",param.atdsrvnum,"/",param.atdsrvano,
                                     " Mensagem: ",lr_retorno.mensagem
             #display "lr_retorno.mensagem: ",lr_retorno.mensagem
           #call errorlog(lr_retorno.mensagem)
           let m_erro.codigo = 0
           let m_erro.mensagem = lr_retorno.mensagem
      end if
   end if
   #display "=== Retorno RE ==="
   #display "lr_retorno.result:  ",lr_retorno.result
   #display "lr_retorno.msgerr:  ",lr_retorno.msgerr
   #display "lr_retorno.mensagem:",lr_retorno.mensagem
   #display "===Fim Retorno RE ==="
end function
