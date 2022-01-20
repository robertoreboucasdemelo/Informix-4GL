#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: CENTRAL 24H                                                #
# Modulo.........: cts40g15                                                   #
# Analista Resp..: Priscila Staingel                                          #
# PSI/OSF........: 198714                                                     #
#                  Modulo para envio de mensagem SMS ao segurado              #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 02/12/2006 Ligia Mattge    PSI205206  ciaempcod - Azul Seguros              #
# 04/12/2007 Sergio Burini   PSI215868  Envio de SMS ao segurado.             #
#                                                                             #
# 15/07/2013 Jorge Modena   PSI201315767 Mecanismo de Seguranca               #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define  m_cts40g15_prep    smallint

#------------------------------#
 function cts40g15_prepare()
#------------------------------#
 define l_sql  char(800)

 #Buscar telefone do segurado - cadastrado para o servico
 let l_sql = "select celteldddcod, celtelnum from datmlcl "
            ," where atdsrvnum = ? "
            ,"   and atdsrvano = ? "
 prepare pcts40g15001 from l_sql
 declare ccts40g15001 cursor for pcts40g15001

 #Buscar veiculo do servico
 let l_sql = "select socvclcod, ciaempcod, c24solnom from datmservico "
            ," where atdsrvnum = ? "
            ,"   and atdsrvano = ? "

 prepare pcts40g15002 from l_sql
 declare ccts40g15002 cursor for pcts40g15002

 #Buscar bairro onde o veiculo esta
 let l_sql = "select cidnom, ",
                   " brrnom ",
              " from datmfrtpos "
            ," where socvclcod = ? "
            ," and   socvcllcltip = 1 "

 prepare pcts40g15003 from l_sql
 declare ccts40g15003 cursor for pcts40g15003

 let l_sql = "insert into dbsmenvmsgsms (smsenvcod,",
                                       " dddcel, ",
                                       " celnum, ",
                                       " msgtxt, ",
                                       " incdat, ",
                                       " envstt) ",
                               " values (?,?,?,?,?,?)"
 prepare pcts40g15004 from l_sql

 let l_sql = " select 1 ",
               " from dbsmenvmsgsms ",
              " where smsenvcod = ? "

 prepare pcts40g15005 from l_sql
 declare ccts40g15005 cursor for pcts40g15005
  
 let m_cts40g15_prep = true
end function
 
 
#---------------------------#
 function cts40g15(param)
#---------------------------#

 define param record
   atdsrvnum        like datmservico.atdsrvnum,
   atdsrvano        like datmservico.atdsrvano
 end record

 define l_ddd        like datmlcl.dddcod,
        l_telefone   like datmlcl.lcltelnum,
        l_brrnom     like datmfrtpos.brrnom,
        l_cidnom     like datmfrtpos.cidnom,
        l_socvclcod  like datmservico.socvclcod

 define lr_saida       record
      result             smallint             # 1=Ok 2=Notfound 3-Erro Sql
     ,oprcod             like pcckceltelopr.oprcod
     ,oprnom             like pcckceltelopr.oprnom
     ,opratvflg          like pcckceltelopr.opratvflg
     ,msgerr             char(80)
 end record

 define lr_rotsms      record
    errcod             integer,
    msgerr             char(20)
 end record
 
 define lr_cty28g00 record 
        coderro  smallint,
        msgerro  char(40),
        senha    char(04)
 end record

 define l_mensagem     char(143)
 define l_mensagem2    char(143)
 define l_aux          smallint
 define l_ciaempcod    like datmservico.ciaempcod
 define l_empresa      char(12)
 define l_c24solnom    like datmservico.c24solnom
 define l_erro         char(160)
 define l_smsenvcod    like dbsmenvmsgsms.smsenvcod
 define l_cur          like dbsmenvmsgsms.incdat
 define l_nome         like datksrr.srrabvnom

  
 if m_cts40g15_prep is null or
    m_cts40g15_prep <> true then
    call cts40g15_prepare()
 end if

 let l_ciaempcod = null
 let l_empresa = null
 let l_c24solnom = null
 let l_erro = null

 let l_mensagem2 = null

 open ccts40g15001 using param.atdsrvnum,
                         param.atdsrvano
 whenever error continue
 fetch ccts40g15001 into l_ddd, l_telefone
 whenever error stop

 if sqlca.sqlcode <> 0 then
    #ERROR "LOCAL DO SERVICO NAO ENCONTRADO"
    return
 else
    if l_ddd is null or
       l_telefone is null then
       #ERROR "SERVICO NAO POSSUI DDD/CELULAR CADASTRADO" SLEEP 1
       return
    end if
 end if

 whenever error continue
   select srrabvnom
     into l_nome
     from datmservico a,
          datksrr b
    where a.srrcoddig = b.srrcoddig
      and atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano
 whenever error stop

 #VERIFICAR SE SMS PODE SER ENVIADO PARA O CELULAR SELECIONADO
 call fpccc016_obterOperadora(l_ddd, l_telefone)
     returning lr_saida.*

 let  lr_saida.result   = 2

-- if lr_saida.result <> 1 then
--    ERROR LR_SAIDA.MSGERR SLEEP 2
#    return
# end if
# if lr_saida.result = 1 and lr_saida.opratvflg = "N" then
#    ERROR "O SERVIÇO SMS DA CIA NÃO ENCAMINHA MENSAGEM PARA ESTA OPERADORA " SLEEP 2
#    return
# end if

 let l_socvclcod = null
 let l_brrnom = null

 open ccts40g15002 using param.atdsrvnum, param.atdsrvano
 fetch ccts40g15002 into l_socvclcod, l_ciaempcod, l_c24solnom
 close ccts40g15002

 if l_ciaempcod is null or l_ciaempcod = 1 then
    let l_empresa = "PORTO SEGURO"
 else
     return
 end if

 open  ccts40g15003 using l_socvclcod
 fetch ccts40g15003 into l_cidnom, l_brrnom
 close ccts40g15003
 
 
 #MONTAR MENSAGEM A SER ENVIADA VIA SMS
 let l_mensagem = l_empresa, " inf: ", l_c24solnom clipped,
                  ", o socorrista " , l_nome

 if  l_brrnom is not null then
     let l_mensagem = l_mensagem clipped, " saiu de ", l_brrnom

     if  l_cidnom <> l_brrnom and l_cidnom is not null then
         let l_mensagem = l_mensagem clipped, ", ", l_cidnom
     end if
 end if

 #let l_mensagem = l_mensagem clipped, " e chegara dentro da previsao informada. "
 #                                   , " Servico "
 #                                   , param.atdsrvnum using "<<<<<<<<<&", "-"
 #                                   , param.atdsrvano using "<&", "."
 
 
 if cty28g00_controla_mecanismo_seguranca(param.atdsrvnum , param.atdsrvano, l_ciaempcod) then 
    ##verifica senha de seguranca   
    call cty28g00_consulta_senha(param.atdsrvnum, param.atdsrvano)
     returning  lr_cty28g00.senha   ,
                lr_cty28g00.coderro ,
                lr_cty28g00.msgerro 
             
    if  lr_cty28g00.coderro <> 0 then 
        let l_mensagem = l_mensagem clipped, " e chegara dentro da previsao informada. "
                                    , " Senha de seguranca "
                                    , lr_cty28g00.senha clipped
    else
        display lr_cty28g00.msgerro clipped
    end if
 else
    let l_mensagem = l_mensagem clipped, " e chegara dentro da previsao informada. "                                     
 end if
 
 let l_smsenvcod = "S" clipped, param.atdsrvnum using "<<<<<<<<<&", param.atdsrvano using "<<<&&"
 let l_cur = current

 open ccts40g15005 using l_smsenvcod
 fetch ccts40g15005 into l_aux


 if  sqlca.sqlcode = notfound then

     whenever error continue
     execute pcts40g15004 using l_smsenvcod,
                                l_ddd,
                                l_telefone,
                                l_mensagem,
                                l_cur,
                                "A"

     if  sqlca.sqlcode <> 0 then
         display 'Erro : ', sqlca.sqlcode clipped, " Tabela de Envio de SMS"
         display "l_smsenvcod: ", l_smsenvcod
         display "l_ddd      : ", l_ddd
         display "l_telefone : ", l_telefone
         display "l_mensagem : ", l_mensagem
         display "l_cur      : ", l_cur
     end if
     whenever error stop
 end if

end function
