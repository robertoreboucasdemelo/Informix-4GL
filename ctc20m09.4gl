#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : ctc20m09                                                       #
# Programa   : ctc20m09 - Consulta Valor Bonificacao                          #
#-----------------------------------------------------------------------------#
# Analista Resp. : Jorge Modena                                               #
# PSI            :                                                            #
#                                                                             #
# Desenvolvedor  : Jorge Modena                                               #
# DATA           : 10/2013                                                    #
#.............................................................................#
# Data        Autor      Alteracao                                            #
# ----------  ---------  -----------------------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

define m_prepare     smallint
define m_etapas      like datkgeral.grlinf


#---------------------------#
 function ctc20m09_prepare()
#---------------------------#

define l_sql      char(3000),
       l_condicao char(100)

initialize l_sql, l_condicao to null

###  CURSOR PRINCIPAL ###
let l_sql = " select  datmsrvacp.pstcoddig,  "
            ,"        datmservico.atdsrvorg, "
            ,"        datmservico.asitipcod, "
            ,"        datmsrvacp.envtipcod,  "
            ,"        datmsrvacp.atdetpdat,  "
            ,"        datmsrvacp.socvclcod,  "
            ,"        datmsrvacp.srrcoddig,  "
            ,"        datmsrvacp.atdetpcod   "
	          ,"   from datmservico, "
	          ,"        datmsrvacp   "
	          ,"  where datmsrvacp.atdsrvseq = datmservico.atdsrvseq "
	          ,"    and datmservico.atdsrvnum = ? "
	          ,"    and datmservico.atdsrvano = ? "
	          ,"    and datmservico.atdsrvnum = datmsrvacp.atdsrvnum "
	          ,"    and datmservico.atdsrvano = datmsrvacp.atdsrvano "
	          ,"    and datmsrvacp.atdetpcod in (", m_etapas," )"
prepare pctc20m09001  from l_sql
declare c_ctc20m09001  cursor for pctc20m09001

## verifica valor bonificacao
let l_sql  = " select pstprmvlr        "
            ,"   from dpampstprm       "
            ,"  where vlrrefdat = ?    "
            ,"    and pstcoddig = ?    "
            ,"    and prtbnfgrpcod = ? "
prepare pctc20m09002 from l_sql
declare c_ctc20m09002 cursor for pctc20m09002

let l_sql = " select atosgrflg     "
           ,"   from datmsrrsgrhst "
           ,"  where sgrrefdat = ? "
           ,"    and prscod = ?    "
           ,"    and srrcoddig = ? "
prepare pctc20m09004 from l_sql
declare c_ctc20m09004 cursor for pctc20m09004

let l_sql =   " select atosgrflg        "
             ,"   from datmvclsgrhst    "
             ,"  where vclsgrrefdat = ? "
             ,"    and prscod = ?       "
             ,"    and socvclcod = ?    "
prepare pctc20m09005 from l_sql
declare c_ctc20m09005 cursor for pctc20m09005

let l_sql =  "  select 1                    "
            ,"    from dpamprsbnsple        "
            ,"   where pstcoddig  = ?       "
            ,"     and prtbnfprccod = ?     "
            ,"     and bnspleviginidat <= ? "
            ,"     and bnsplevigfnldat >= ? "
prepare pctc20m09006 from l_sql
declare c_ctc20m09006 cursor for pctc20m09006

let l_sql =     " select grlinf    "
               ,"  from datkgeral  "
               ," where grlchv = ? "
prepare pctc20m09007 from l_sql
declare c_ctc20m09007 cursor for pctc20m09007

let l_sql =    "select socvcltip     "
              ,"  from datkveiculo   "
              ," where socvclcod = ? "
prepare pctc20m09008 from l_sql
declare c_ctc20m09008 cursor for pctc20m09008

## verifica se prestador participa de bonificacao
let l_sql = "select 1                "
           ,"  from dparbnfprt       "
           ," where pstcoddig    = ? "
           ,"   and prtbnfprccod = ? "
prepare pctc20m09009 from l_sql
declare c_ctc20m09009 cursor for pctc20m09009

let m_prepare = true

end function


#-----------------------------------------------------------------------------#
function ctc20m09_valor_bonificacao(lr_param)
#-----------------------------------------------------------------------------#
 define lr_param        record
        atdsrvnum       like datmservico.atdsrvnum,
        atdsrvano       like datmservico.atdsrvano
 end record

 define lr_retorno      record
        coderro         integer                         ## Cod.erro ret.0= Bonificacao OK/1=Bonificacao NOK/2=Outros
       ,msgerro         char(100)                       ## Mensagem erro retorno
       ,pstprmvlr       like dpampstprm.pstprmvlr
 end record

 define lr_aux         record
        atdprscod      like datmservico.atdprscod,
        asitipcod      like datmservico.asitipcod,
        socvcltip      like datkveiculo.socvcltip,
        socntzcod      like datmsrvre.socntzcod,
        atdsrvorg      like datmservico.atdsrvorg,
        atdetpdat      like datmsrvacp.atdetpdat,
        envtipcod      like datmsrvacp.envtipcod,
        socvclcod      like datmsrvacp.socvclcod,
        srrcoddig      like datmsrvacp.srrcoddig,
        atdetpcod      like datmsrvacp.atdetpcod
 end record

 define l_auto_re     smallint
 define l_dataref     date
 define l_dataaux     char(10)
 define l_dia         char(02)
 define l_mes         char(02)
 define l_ano         char(04)
 define l_atosgrflg   char(01)

define lr_ctd27g03  record
        ret          smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg          char(100),
        prtbnfgrpcod like dpakbnfgrppar.prtbnfgrpcod
 end record

 define lr_ctd07g04  record
        resultado    smallint,
        mensagem     char(60),
        socntzcod    like datmsrvre.socntzcod
 end record

 define lr_ctd27g04  record
        ret          smallint, # (1) = Ok  (2) = Not Found  (3) = Erro de acesso
        msg          char(100),
        credencia    char(1)
 end record

 define l_bnfcrtcod    smallint
 define l_prtbnfprccod smallint
 define l_chave        like datkgeral.grlchv
 define l_parametro    like datkgeral.grlinf

 initialize lr_retorno.*  to null
 initialize lr_aux.*      to null
 initialize lr_ctd27g03.* to null
 initialize lr_ctd07g04.* to null
 initialize lr_ctd27g04.* to null
 initialize l_auto_re     to null
 initialize l_dataref     to null
 initialize l_dataaux     to null
 initialize l_parametro   to null
 initialize l_chave       to null
 initialize l_dia         to null
 initialize l_mes         to null
 initialize l_ano         to null
 initialize l_atosgrflg   to null
 let l_bnfcrtcod   =  0
 let l_prtbnfprccod = 0
 initialize m_etapas, m_prepare to null

 whenever error continue
   select grlinf into m_etapas
    from datkgeral
     where grlchv = 'PSOBONIFICETAPA'
 whenever error stop

 if sqlca.sqlcode <> 0 then
    ## NAO CONSIDERAR PREMIO QUANDO NAO EXISTIR PARAMETRO ENCONTRADO
    let lr_retorno.coderro = 2
    let lr_retorno.msgerro =  "Etapas para bonificacao nao cadastrada"
    return lr_retorno.*
 end if

 let m_etapas =  m_etapas clipped

 if m_prepare is null or m_prepare <> true then
    call ctc20m09_prepare()
 end if

 display "Iniciando pesquisa Bonificacao Servico ", lr_param.atdsrvnum, " - ",lr_param.atdsrvano

 let l_chave = "PSOBONIFICACAO2"
 ##verifica se bonificacao nova ja esta ATIVA
  open c_ctc20m09007 using l_chave
 fetch c_ctc20m09007 into l_parametro

 if sqlca.sqlcode = notfound then
    ## NAO CONSIDERAR PREMIO QUANDO NAO EXISTIR PARAMETRO ENCONTRADO
    let lr_retorno.coderro = 2
    let lr_retorno.msgerro =  "Parametro de nova bonificacao nao cadastrado"
    close c_ctc20m09007
    return lr_retorno.*
 end if

 close c_ctc20m09007

 let l_parametro =  l_parametro clipped

 if l_parametro = "ATIVO" then

     open c_ctc20m09001 using lr_param.atdsrvnum, lr_param.atdsrvano
    fetch c_ctc20m09001 into lr_aux.atdprscod,
                             lr_aux.atdsrvorg,
                             lr_aux.asitipcod,
                             lr_aux.envtipcod,
                             lr_aux.atdetpdat,
                             lr_aux.socvclcod,
                             lr_aux.srrcoddig,
                             lr_aux.atdetpcod

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             let lr_retorno.coderro = 2
             let lr_retorno.msgerro =  "Etapa de Servico nao recebe bonificacao"
             close c_ctc20m09001
             return lr_retorno.*
          else
             let lr_retorno.coderro = 2
             let lr_retorno.msgerro =  "Erro: ", sqlca.sqlcode, "  Consulta Etapa do Servico ", lr_param.atdsrvnum
             close c_ctc20m09001
             return lr_retorno.*
          end if
       end if

    close c_ctc20m09001

    ##VERIFICA SE SERVICO FOI ACIONADO VIA GPS
    if lr_aux.envtipcod <> 1 then
       let lr_retorno.coderro = 2
       let lr_retorno.msgerro =  "Servico nao foi acionado via GPS"
       return lr_retorno.*
    end if

    if lr_aux.atdsrvorg = 9 or lr_aux.atdsrvorg = 13 then
       let l_auto_re = 2  ## RE
       let l_prtbnfprccod = 2
    else
       let l_auto_re = 1
       let l_prtbnfprccod = 1
    end if

    ##VERIFICA SE PRESTADOR PARTICIPA DA BONIFICACAO

     open c_ctc20m09009 using lr_aux.atdprscod,l_auto_re
    fetch c_ctc20m09009

    if  sqlca.sqlcode <> 0 then
       let lr_retorno.coderro = 2
       let lr_retorno.msgerro =  "Prestador nao bonificavel"
       return lr_retorno.*
    end if

    close c_ctc20m09009

    ##VERIFICA TIPO DE VEICULO
     open c_ctc20m09008 using lr_aux.socvclcod
    fetch c_ctc20m09008 into lr_aux.socvcltip

    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.coderro = 2
          let lr_retorno.msgerro =  "Tipo de veiculo nao localizado"
          close c_ctc20m09008
          return lr_retorno.*
       else
          let lr_retorno.coderro = 2
          let lr_retorno.msgerro =  "Erro: ", sqlca.sqlcode, " Consulta Tipo de Veiculo"
          close c_ctc20m09008
          return lr_retorno.*
       end if
    end if

    close c_ctc20m09008

    ##NAO CONSIDERA A BONIFICACAO PARA OS TIPOS DE VEICULOS ABAIXO
    if lr_aux.socvcltip = 10 or lr_aux.socvcltip = 11 or
       lr_aux.socvcltip = 12 or lr_aux.socvcltip = 13 then
       let lr_retorno.coderro = 2
       let lr_retorno.msgerro =  "Tipo de veiculo nao bonificavel"
       return lr_retorno.*
    end if

    ##VERIFICA SE MOTO, SCOOTER e BIKE PODE SER BONIFICADA
    if lr_aux.socvcltip =  6
       or lr_aux.socvcltip = 8
       or lr_aux.socvcltip = 14 then

          let l_chave = "PSOBONBIKEMOTO"
          ##verifica se bonificacao nova ja esta ATIVA
           open c_ctc20m09007 using l_chave
          fetch c_ctc20m09007 into l_parametro

          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = notfound then
                ## NAO CONSIDERAR PREMIO QUANDO NAO EXISTIR PARAMETRO ENCONTRADO
                let lr_retorno.coderro = 2
                let lr_retorno.msgerro =  "Tipo de veiculo nao bonificavel"
                close c_ctc20m09007
                return lr_retorno.*
             else
                let lr_retorno.coderro = 2
                let lr_retorno.msgerro =  "Erro : ",sqlca.sqlcode,  " Tipo de veiculo nao bonificavel"
                close c_ctc20m09007
                return lr_retorno.*
             end if
          end if

          if l_parametro <> "SIM" then
             let lr_retorno.coderro = 2
             let lr_retorno.msgerro =  "Tipo de veiculo nao bonificavel"
             close c_ctc20m09007
             return lr_retorno.*
          end if

          close c_ctc20m09007

    end if

    let lr_aux.socntzcod = 0

    # BUSCA NATUREZA DO SERVIÇO
    if lr_aux.atdsrvorg = 9 or lr_aux.atdsrvorg = 13 then

       call ctd07g04_sel_re(1,lr_param.atdsrvnum,lr_param.atdsrvano)
            returning lr_ctd07g04.*
       let lr_aux.socntzcod = lr_ctd07g04.socntzcod

    end if

    # BUSCA O CODIGO DO GRUPO DO SERVICO
    call ctd27g03_grp_srv(lr_aux.atdsrvorg,
                          lr_aux.asitipcod,
                          lr_aux.socntzcod)
         returning lr_ctd27g03.*

    display "Natureza/Assistencia/prtbnfgrpcod: "
           ,lr_aux.socntzcod, "/", lr_aux.asitipcod, "/", lr_ctd27g03.prtbnfgrpcod
    display "lr_ctd27g03.ret/msg: ", lr_ctd27g03.ret, "/", lr_ctd27g03.msg clipped

    if lr_ctd27g03.ret <> 1 then
       let lr_retorno.coderro = 2
       let lr_retorno.msgerro =  lr_ctd27g03.msg clipped
       return lr_retorno.*
    end if

    ## CALCULA DATA PARA PESQUISA DO VALOR DA BONIFICACAO
    let l_dataaux  = lr_aux.atdetpdat
    let l_dia       = "01"
    let l_mes       = l_dataaux[4,5]
    let l_ano       = l_dataaux[7,10]
    let l_dataref   = mdy(l_mes,l_dia,l_ano)

    ## pega sempre o dia 01 do mes anterior , data da avaliacao da bonificacao corrente
    let l_dataref = l_dataref - 1 units month
    display "Data referencia pesquisa bonificacao ", l_dataref

    ## VERIFICA SE GRUPO DE BONIFICACAO DO SERVICO AVALIA SEGURO
    let l_bnfcrtcod = 1  ## Criterio Seguro Vida
    call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod, l_bnfcrtcod)
         returning lr_ctd27g04.*

     if lr_ctd27g04.ret = 1 then
        open c_ctc20m09004 using l_dataref,
                                lr_aux.atdprscod,
                                lr_aux.srrcoddig

       fetch c_ctc20m09004 into l_atosgrflg
       close c_ctc20m09004

       if l_atosgrflg = "N" then
          let lr_retorno.coderro = 1
          let lr_retorno.msgerro =  "Socorrista esta com seguro de vida irregular"
          let lr_retorno.pstprmvlr = 0
          return lr_retorno.*
       end if
    end if

    ## verifica se grupo de serviço avalia seguro veiculo
    let l_bnfcrtcod = 2  ## Criterio Seguro VEICULO
    call ctd27g04_val_crit_grp(lr_ctd27g03.prtbnfgrpcod, l_bnfcrtcod)
         returning lr_ctd27g04.*

    if lr_ctd27g04.ret = 1 then
        open c_ctc20m09005 using l_dataref
                               ,lr_aux.atdprscod
                               ,lr_aux.socvclcod

       fetch c_ctc20m09005 into l_atosgrflg
       close c_ctc20m09005

       if l_atosgrflg = "N" then
          let lr_retorno.coderro = 1
          let lr_retorno.msgerro =  "Veiculo esta com seguro irregular"
          let lr_retorno.pstprmvlr = 0
          return lr_retorno.*
       end if
    end if

    ## verifica se possui penalidade para prestador na data que serviço foi atendido
    open c_ctc20m09006 using lr_aux.atdprscod
                            ,l_prtbnfprccod
                            ,lr_aux.atdetpdat
                            ,lr_aux.atdetpdat

     whenever error continue
     fetch c_ctc20m09006
     whenever error stop

     if sqlca.sqlcode = 0 then
        let lr_retorno.coderro = 1
        let lr_retorno.msgerro =  "Prestador possui penalidade cadastrada para data: ", lr_aux.atdetpdat
        let lr_retorno.pstprmvlr = 0
        return lr_retorno.*
     end if

    ## SE TUDO ESTA CORRETO VERIFICA VALOR BONIFICACAO
     open c_ctc20m09002 using l_dataref, lr_aux.atdprscod, lr_ctd27g03.prtbnfgrpcod
    fetch c_ctc20m09002 into  lr_retorno.pstprmvlr

    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.coderro = 2
          let lr_retorno.msgerro = "Nao encontrou valor Bonificacao para Prestador " clipped
                                   ,lr_aux.atdprscod, " e grupo de servico "
                                   ,lr_ctd27g03.prtbnfgrpcod
       else
          let lr_retorno.coderro = 2
          let lr_retorno.msgerro = "Erro em ctc20m09_valor_bonificacao ", sqlca.sqlcode
       end if
       close c_ctc20m09002
       return lr_retorno.*
    end if

    close c_ctc20m09002

 else
    let lr_retorno.coderro = 2
    let lr_retorno.msgerro =  "Nova bonificacao esta inativo"
    return lr_retorno.*
 end if

 let lr_retorno.coderro = 0

 return lr_retorno.*

end function