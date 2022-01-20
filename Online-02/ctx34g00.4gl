#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: ctx34g00                                                   #
# ANALISTA RESP..: Beatriz Araujo                                             #
# PSI/OSF........: PSI-2011-0258628/PR                                        #
# DATA...........: 15/07/2011                                                 #
# OBJETIVO.......: Criar uma inferface unica de atualizacao das etapas na     #
#                  base do Oracle do Novo Acionamento                         #
# Observacoes:                                                                #
# ........................................................................... #
#                        * * * Alteracoes * * *                               #
#                                                                             #
#    Data      Autor Fabrica    Origem      Alteracao                         #
#  ----------  -------------    ---------   --------------------------------  #
#                                                                             #
# 20-06-2013   Kelly Lima      PSI 11843   Programa Pomar - Inclusão do fluxo #
#                                          de chamar de integração do Siebel  #
#                                          quando a etapa for de cancelamento #
#-----------------------------------------------------------------------------#

database porto

define m_ctx34g00_prep smallint

#------------------------------------------#
function ctx34g00_prepare()
#------------------------------------------#

define l_sql char(6000)

 let l_sql = "select a.atdsrvnum ,",
               " a.atdsrvano ,",
               " a.atdsrvseq ,",
               " a.atdetpcod ,",
               " a.atdetpdat ,",
               " a.atdetphor ,",
               " a.empcod    ,",
               " a.funmat    ,",
               " a.pstcoddig ,",
               " a.atdmotnom ,",
               " a.atdvclsgl ,",
               " a.c24nomctt ,",
               " a.socvclcod ,",
               " a.srrcoddig ,",
               " a.envtipcod ,",
               " a.srvrcumtvcod,",
               " a.acntmpqtd,",
               " a.dstqtd,   ",
               " a.canmtvcod, ", #PSI 2013-11843 - Pomar (Carga)
               " s.atdsrvorg  ",
          " from datmsrvacp a ",
          "     ,datmservico s ",
         " where a.atdsrvnum = ?",
           " and a.atdsrvano = ?",
           " and s.atdsrvnum = a.atdsrvnum ",
           " and s.atdsrvano = a.atdsrvano ",
           " and a.atdsrvseq = (select max(b.atdsrvseq) ",
                                " from datmsrvacp b",
                               " where b.atdsrvnum = ?",
                                 " and b.atdsrvano = ?)"
   prepare p_ctx34g00_001 from l_sql
   declare c_ctx34g00_001 cursor for p_ctx34g00_001

   let l_sql = " select atdsrvorg",
             " from datmservico",
            " where atdsrvnum = ?",
              " and atdsrvano = ?"
   prepare p_ctx34g00_002 from l_sql
   declare c_ctx34g00_002 cursor for p_ctx34g00_002

   let l_sql = "select a.atdsrvnum ,",
               " a.atdsrvano ,",
               " a.atdsrvseq ,",
               " a.atdetpcod ,",
               " a.atdetpdat ,",
               " a.atdetphor ,",
               " a.empcod    ,",
               " a.funmat    ,",
               " a.pstcoddig ,",
               " a.atdmotnom ,",
               " a.atdvclsgl ,",
               " a.c24nomctt ,",
               " a.socvclcod ,",
               " a.srrcoddig ,",
               " a.envtipcod ,",
               " a.srvrcumtvcod,",
               " a.acntmpqtd,",
               " a.dstqtd ",
          " from datmsrvacp a ",
         " where a.atdsrvnum = ?",
           " and a.atdsrvano = ?",
           " and a.atdsrvseq = ?"
   prepare p_ctx34g00_003 from l_sql
   declare c_ctx34g00_003 cursor for p_ctx34g00_003

   let l_sql = " select grlinf",
                " from datkgeral",
               " where grlchv = 'ACIONAMENTO'"
   prepare p_ctx34g00_004 from l_sql
   declare c_ctx34g00_004 cursor for p_ctx34g00_004

   #PSI 2013-11843 - Pomar (Cancelamento) - Inicio
   #Consultar para buscar o Código do Siebel de um serviço
   let l_sql  =  "SELECT sblintcod",
                 "  FROM datmservico",
                 " WHERE atdsrvnum = ?",
                 "   AND atdsrvano = ?"
   prepare p_ctx34g00_005 from l_sql
   declare c_ctx34g00_005 cursor for p_ctx34g00_005

   #Verifica se o serviço já está na tabela de controle
   #Removido conforme email do Raji
   #let l_sql = "SELECT rpcttvqtd ",
   #            "  FROM datmpcmctr ",
   #            " WHERE atdsrvnum = ? ",
   #            "   AND atdsrvano = ? ",
	#          "   AND intcod = ? ",
	#          "   AND rpcicldat = ? "
   #prepare p_ctx34g00_007 from l_sql
   #declare c_ctx34g00_007 cursor for p_ctx34g00_007

   #Insere registro na tabela de controle
   #let l_sql = "INSERT INTO datmpcmctr (atdsrvnum, ",
   #            "                        atdsrvano, ",
   #            "                        atdsrvseq, ",
   #            "                        c24txtseq, ",
   #            "                        rpcicldat, ",
   #            "                        intcod,    ",
   #            "                        rpcttvqtd, ",
   #            "                        errdes)    ",
   #            "            VALUES(?,?,?,?,today,?,?,?)"
   #
   #prepare p_ctx34g00_008 from l_sql

   #Removido conforme email do Raji
   ##Deletar registro da tabela de controle
   #let l_sql = "DELETE FROM datmpcmctr  ",
   #            "      WHERE atdsrvnum = ? ",
   #            "       AND atdsrvano = ? ",
	#          "       AND intcod = ? "
   #
   #prepare p_ctx34g00_009 from l_sql

   #Buscar descrição do motivo de cancelamento
   let l_sql = " SELECT cpodes               "
             , "   FROM iddkdominio          "
             , "  WHERE cponom = 'mtocansrv' "
             , "    AND cpocod = ?"

   prepare p_ctx34g00_010 from l_sql
   declare c_ctx34g00_010 cursor for p_ctx34g00_010

   #Removido conforme email do Raji
   #Atualiza quantidade tentativas
   #let l_sql = " update datmpcmctr          ",
   #            " set rpcttvqtd = ?          ",
   #            " WHERE atdsrvnum = ?        ",
   #            " AND atdsrvano = ?          ",
	#          " AND intcod = ?             "
   #
   #prepare p_ctx34g00_011 from l_sql

   #Busca etapa
   let l_sql = " select a.atdetpcod, b.atdetpdes, a.atdsrvseq ",
               " from datmsrvacp a,datketapa b                ",
               " where a.atdsrvnum = ?                        ",
               " and atdsrvano= ?                             ",
	          " and  a.atdsrvseq = (SELECT max(c.atdsrvseq)  ",
               "     FROM datmsrvacp c                        ",
               "     WHERE c.atdsrvnum = ?                    ",
               "     AND c.atdsrvano = ?)                     "
   prepare p_ctx34g00_013 from l_sql
   declare c_ctx34g00_013 cursor for p_ctx34g00_013

   #Busca informações acionamento
   let l_sql = "select a.envtipcod, a.empcod, a.funmat, b.funnom,   ",
               "       a.pstcoddig, a.socvclcod, a.srrcoddig,       ",
               "       c.nomgrr, c.endcid, c.endufd, c.teltxt       ",
               "from datmsrvacp a, isskfunc b, dpaksocor c          ",
               "     where a.empcod = b.empcod                      ",
               "     and a.funmat = b.funmat                        ",
               "     and a.pstcoddig = c.pstcoddig                  ",
               "     and a.atdsrvnum =?                             ",
               "     and a.atdsrvano = ?                            ",
               " and  a.atdsrvseq = (SELECT max(c.atdsrvseq)        ",
               "     FROM datmsrvacp c                              ",
               "     WHERE c.atdsrvnum = ?                          ",
               "     AND c.atdsrvano = ?)                           "
   prepare p_ctx34g00_014 from l_sql
   declare c_ctx34g00_014 cursor for p_ctx34g00_014

   let l_sql ="select srrcoddig, srrnom, celdddcod, celtelnum   ",
              "from datksrr                                     ",
              "where srrcoddig = ?                              "
   prepare p_ctx34g00_015 from l_sql
   declare c_ctx34g00_015 cursor for p_ctx34g00_015

   let l_sql ="select a.atdvclsgl, b.cpodes      ",
              "from datkveiculo a, iddkdominio b ",
              "where b.cponom ='socvcltip'       ",
              "and a.socvcltip = b.cpocod        ",
              "and a.socvclcod = ?               "
   prepare p_ctx34g00_016 from l_sql
   declare c_ctx34g00_016 cursor for p_ctx34g00_016

   #PSI 2013-11843 - Pomar (Cancelamento) - Fim

   let l_sql = "select a.atdsrvseq ,",
                     " a.atdetpcod ,",
                     " a.atdetpdat ,",
                     " a.atdetphor ,",
                     " a.empcod    ,",
                     " a.funmat    ,",
                     " a.pstcoddig ,",
                     " a.atdmotnom ,",
                     " a.atdvclsgl ,",
                     " a.c24nomctt ,",
                     " a.socvclcod ,",
                     " a.srrcoddig ,",
                     " a.envtipcod ,",
                     " a.srvrcumtvcod,",
                     " a.acntmpqtd,",
                     " a.dstqtd,",
                     " a.canmtvcod, ", #PSI 2013-11843 - Pomar (Carga)
                     " s.atdsrvorg  ",
                " from datmsrvacp a ",
                "     ,datmservico s ",
               " where a.atdsrvnum = ?",
                 " and a.atdsrvano = ?",
                 " and s.atdsrvnum = a.atdsrvnum ",
                 " and s.atdsrvano = a.atdsrvano ",
               " order by a.atdsrvseq"
   prepare p_ctx34g00_017 from l_sql
   declare c_ctx34g00_017 cursor for p_ctx34g00_017

   let l_sql = "insert into igbmparam ",
              " values ('CTX34G00', ",
                     " (select NVL(max(relpamseq),0)+1",
                            " from igbmparam param",
                           " where relsgl = 'CTX34G00'), ",
                      " ?, ",
                      " ? )"
   prepare p_ctx34g00_018 from l_sql

   let l_sql = "select relpamtip ,",
                     " relpamtxt ,",
                     " relpamseq ",
                " from igbmparam ",
               " where relsgl = 'CTX34G00'",
               " order by relpamseq"
   prepare p_ctx34g00_019 from l_sql
   declare c_ctx34g00_019 cursor for p_ctx34g00_019

   let l_sql = "delete ",
                " from igbmparam ",
               " where relsgl = 'CTX34G00'",
                 " and relpamseq = ? "
   prepare p_ctx34g00_020 from l_sql

   let l_sql = "select relpamseq ",
                " from igbmparam ",
               " where relsgl = 'CTX34G00'",
                 " and relpamtip = ? ",
                 " and relpamtxt = ? "
   prepare p_ctx34g00_021 from l_sql
   declare c_ctx34g00_021 cursor for p_ctx34g00_021

   let m_ctx34g00_prep = true

end function

#------------------------------------------#
function ctx34g00_apos_grvetapa(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   atdsrvseq like datmservico.atdsrvseq,
   tipoEnvio smallint # 1- insert da ultima sequencia  2- update da sequencia
end record

 define l_xml record
    response char(32766),
    request  char(32766)
 end record

 define lr_retorno record
    cod_erro  smallint,
    mensagem  char(100)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint
 define l_relpamtxt  like igbmparam.relpamtxt

 #PSI 2013-11843 - Pomar (Cancelamento) - Inicio
 define ctx34g00_etapa record
   atdsrvnum    like datmsrvacp.atdsrvnum   ,
   atdsrvano    like datmsrvacp.atdsrvano   ,
   atdsrvseq    like datmsrvacp.atdsrvseq   ,
   atdetpcod    like datmsrvacp.atdetpcod   ,
   atdetpdat    like datmsrvacp.atdetpdat   ,
   atdetphor    like datmsrvacp.atdetphor   ,
   empcod       like datmsrvacp.empcod      ,
   funmat       like datmsrvacp.funmat      ,
   pstcoddig    like datmsrvacp.pstcoddig   ,
   atdmotnom    like datmsrvacp.atdmotnom   ,
   atdvclsgl    like datmsrvacp.atdvclsgl   ,
   c24nomctt    like datmsrvacp.c24nomctt   ,
   socvclcod    like datmsrvacp.socvclcod   ,
   srrcoddig    like datmsrvacp.srrcoddig   ,
   envtipcod    like datmsrvacp.envtipcod   ,
   srvrcumtvcod like datmsrvacp.srvrcumtvcod,
   acntmpqtd    like datmsrvacp.acntmpqtd   ,
   dstqtd       like datmsrvacp.dstqtd      ,
   canmtvcod    like datmsrvacp.canmtvcod
 end record

 define l_sblintcod       like datmservico.sblintcod

  #PSI 2013-11843 - Pomar (Cancelamento) - Fim

 initialize l_xml.* to null

 if not m_ctx34g00_prep then
    call ctx34g00_prepare()
 end if

 #PSI 2013-11843 - Pomar (Cancelamento) - Inicio
 whenever error continue
 open c_ctx34g00_005 using param.atdsrvnum,
                           param.atdsrvano
 fetch c_ctx34g00_005 into l_sblintcod
 whenever error stop

 #Verifica se o serviço está no Siebel
 # REMOVIDO conforme alinhamento com a Kelly e o Robert
 #if l_sblintcod is not null or l_sblintcod <> "" then
 #    display "É Siebel!"
 #
 #    open c_ctx34g00_001 using param.atdsrvnum,
 #                              param.atdsrvano,
 #                              param.atdsrvnum,
 #                              param.atdsrvano
 #    fetch c_ctx34g00_001 into ctx34g00_etapa.atdsrvnum,
 #                              ctx34g00_etapa.atdsrvano,
 #                              ctx34g00_etapa.atdsrvseq,
 #                              ctx34g00_etapa.atdetpcod,
 #                              ctx34g00_etapa.atdetpdat,
 #                              ctx34g00_etapa.atdetphor,
 #                              ctx34g00_etapa.empcod,
 #                              ctx34g00_etapa.funmat,
 #                              ctx34g00_etapa.pstcoddig,
 #                              ctx34g00_etapa.atdmotnom,
 #                              ctx34g00_etapa.atdvclsgl,
 #                              ctx34g00_etapa.c24nomctt,
 #                              ctx34g00_etapa.socvclcod,
 #                              ctx34g00_etapa.srrcoddig,
 #                              ctx34g00_etapa.envtipcod,
 #                              ctx34g00_etapa.srvrcumtvcod,
 #                              ctx34g00_etapa.acntmpqtd,
 #                              ctx34g00_etapa.dstqtd,
 #                              ctx34g00_etapa.canmtvcod
 #
 #    if ctx34g00_etapa.atdetpcod = 5 then
 #       call ctx34g00_Sbl_Cancel(ctx34g00_etapa.atdsrvnum,
 #                                       ctx34g00_etapa.atdsrvano,
 #                                       ctx34g00_etapa.atdsrvseq,
 #                                       ctx34g00_etapa.atdetpcod,
 #                                       ctx34g00_etapa.atdetpdat,
 #                                       ctx34g00_etapa.atdetphor,
 #                                       ctx34g00_etapa.empcod,
 #                                       ctx34g00_etapa.funmat,
 #                                       ctx34g00_etapa.canmtvcod,
 #                                       l_sblintcod)
 #    else
 #       call ctx34g00_Sbl_AtualizaEtapa(param.atdsrvnum,
 #                                       param.atdsrvano,
 #                                       l_sblintcod)
 #    end if
 #
 #end if
 ##PSI 2013-11843 - Pomar (Cancelamento) - Fim

 if ctx34g00_NovoAcionamento() and
    ctx34g00_origem(param.atdsrvnum,param.atdsrvano) and
    param.atdsrvnum > 0 and
    param.atdsrvnum is not null then

    #---------------------------------------------
    # Verifica se eh alteracao ou inclusao
    #---------------------------------------------

    case param.tipoEnvio
       when 1
          let l_xml.request = ctx34g00_novaEtapa(param.atdsrvnum,param.atdsrvano)
       when 2
          let l_xml.request = ctx34g00_altEtapa(param.atdsrvnum,param.atdsrvano,param.atdsrvseq)
    end case

    let l_xml.request  = l_xml.request clipped

    if l_xml.request is not null and l_xml.request <> ' ' then

         call ctx34g00_enviar_mq_AW(l_xml.request clipped)
                          returning l_status,
                                    l_msg,
                                    l_xml.response

         if l_status <> 0 then
            call ctx34g02_email_erro(l_xml.request,
                                     l_xml.response,
                                     "ERRO NO MQ - ctx34g02_apos_grvetapa",
                                     l_msg)

            # Grava informacao para reprocessamento batch
            let l_relpamtxt = param.atdsrvnum using "#######", "|", param.atdsrvano using "##", "|", param.atdsrvseq using "#####", "|", param.tipoEnvio using "#"
            call ctx34g00_grava_mq_AW_batch(2, l_relpamtxt)

         else
            if l_xml.response like "%<retorno><codigo>1</codigo>%" then
               if not l_xml.response like "%Servico %nao existe%" then
                  call ctx34g02_email_erro(l_xml.request,
                                           l_xml.response,
                                           "ERRO NO SERVICO - ctx34g02_apos_grvetapa",
                                           "")

                 # Grava informacao para reprocessamento batch
                 let l_relpamtxt = param.atdsrvnum using "#######", "|", param.atdsrvano using "##", "|", param.atdsrvseq using "#####", "|", param.tipoEnvio using "#"
                 call ctx34g00_grava_mq_AW_batch(2, l_relpamtxt)

               end if
            end if
         end if
    end if

 end if

end function


#------------------------------------------#
function ctx34g00_origem(param)
#------------------------------------------#

define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record


 define l_atdsrvorg like datmservico.atdsrvorg

 if not m_ctx34g00_prep then
    call ctx34g00_prepare()
 end if

 whenever error continue
  open c_ctx34g00_002 using param.atdsrvnum,param.atdsrvano

  fetch c_ctx34g00_002 into l_atdsrvorg

  if sqlca.sqlcode = 0 then

     select 1
      from iddkdominio
     where cponom = 'srvorg_aciona'
       and cpocod = l_atdsrvorg

     if sqlca.sqlcode = 0 then
        return true
     else
        if sqlca.sqlcode = notfound then
           return false
        end if
     end if
  end if
 whenever error stop

return true

end function

#------------------------------------------#
function ctx34g00_NovoAcionamento()
#------------------------------------------#

 define grlinf like datkgeral.grlinf

 if not m_ctx34g00_prep then
    call ctx34g00_prepare()
 end if


 whenever error continue
  open c_ctx34g00_004
  fetch c_ctx34g00_004 into grlinf

  if sqlca.sqlcode = 0 then
     if grlinf = 1 then
        return true
     else
        return false
     end if
   end if
 whenever error stop

return false

end function

#-----------------------------------------------#
function ctx34g00_ver_acionamentoWEB(l_nivel_msg)
#-----------------------------------------------#

define l_nivel_msg      smallint,  # 1-OnLine(mensagem usuario), 2-Batch
       l_acionamentoWEB smallint,
       l_conf           smallint

let l_acionamentoWEB = ctx34g00_NovoAcionamento()

if l_acionamentoWEB and l_nivel_msg = 1 then
         call cts08g01( "A","N",  "",
                       "AcionamentoWEB Ativo.",
                       "Esta operacao deve ser realizada","no AcionamentoWEB!")
              returning l_conf
end if

return l_acionamentoWEB

end function


# busca todos os dados para realizar a inclusao e monta o XML
#------------------------------------------#
function ctx34g00_novaEtapa(param)
#------------------------------------------#

 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g00_etapa record
    atdsrvnum    like datmsrvacp.atdsrvnum   ,
    atdsrvano    like datmsrvacp.atdsrvano   ,
    atdsrvseq    like datmsrvacp.atdsrvseq   ,
    atdetpcod    like datmsrvacp.atdetpcod   ,
    atdetpdat    like datmsrvacp.atdetpdat   ,
    atdetphor    like datmsrvacp.atdetphor   ,
    empcod       like datmsrvacp.empcod      ,
    funmat       like datmsrvacp.funmat      ,
    pstcoddig    like datmsrvacp.pstcoddig   ,
    atdmotnom    like datmsrvacp.atdmotnom   ,
    atdvclsgl    like datmsrvacp.atdvclsgl   ,
    c24nomctt    like datmsrvacp.c24nomctt   ,
    socvclcod    like datmsrvacp.socvclcod   ,
    srrcoddig    like datmsrvacp.srrcoddig   ,
    envtipcod    like datmsrvacp.envtipcod   ,
    srvrcumtvcod like datmsrvacp.srvrcumtvcod,
    acntmpqtd    like datmsrvacp.acntmpqtd   ,
    dstqtd       like datmsrvacp.dstqtd      ,
    canmtvcod    like datmsrvacp.canmtvcod   ,#PSI 2013-11843 - Pomar (Carga)
    atdsrvorg    like datmservico.atdsrvorg  ,
    lcvcod       like datklocadora.lcvcod    ,
    aviestcod    like datmavisrent.aviestcod
 end record

 define l_xml record
    request char(32766)
 end record

 define l_acntmpqtdmin like datmsrvacp.acntmpqtd
 define l_acntmpqtdmax like datmsrvacp.acntmpqtd

 initialize ctx34g00_etapa.* to null
 initialize l_xml.* to null
 let l_acntmpqtdmin = '  0:00:00'
 let l_acntmpqtdmax = ' 23:59:59'

whenever error continue
  open c_ctx34g00_001 using param.atdsrvnum,
                            param.atdsrvano,
                            param.atdsrvnum,
                            param.atdsrvano

  fetch c_ctx34g00_001  into  ctx34g00_etapa.atdsrvnum   ,
                              ctx34g00_etapa.atdsrvano   ,
                              ctx34g00_etapa.atdsrvseq   ,
                              ctx34g00_etapa.atdetpcod   ,
                              ctx34g00_etapa.atdetpdat   ,
                              ctx34g00_etapa.atdetphor   ,
                              ctx34g00_etapa.empcod      ,
                              ctx34g00_etapa.funmat      ,
                              ctx34g00_etapa.pstcoddig   ,
                              ctx34g00_etapa.atdmotnom   ,
                              ctx34g00_etapa.atdvclsgl   ,
                              ctx34g00_etapa.c24nomctt   ,
                              ctx34g00_etapa.socvclcod   ,
                              ctx34g00_etapa.srrcoddig   ,
                              ctx34g00_etapa.envtipcod   ,
                              ctx34g00_etapa.srvrcumtvcod,
                              ctx34g00_etapa.acntmpqtd   ,
                              ctx34g00_etapa.dstqtd      ,
                              ctx34g00_etapa.canmtvcod   , #PSI 2013-11843 - Pomar (Carga)
                              ctx34g00_etapa.atdsrvorg
 whenever error stop

  # Zerar previsoes negativa
  if ctx34g00_etapa.acntmpqtd < l_acntmpqtdmin then
     let ctx34g00_etapa.acntmpqtd = l_acntmpqtdmin
  end if

  # Limitar previsoes em 24h
  if ctx34g00_etapa.acntmpqtd > l_acntmpqtdmax then
     let ctx34g00_etapa.acntmpqtd = l_acntmpqtdmax
  end if

  if ctx34g00_etapa.atdsrvorg = 8 then
     let ctx34g00_etapa.lcvcod = ctx34g00_etapa.pstcoddig
     let ctx34g00_etapa.aviestcod = ctx34g00_etapa.srrcoddig
     let ctx34g00_etapa.pstcoddig = null
     let ctx34g00_etapa.srrcoddig = null
  end if

  let l_xml.request = ctx34g00_geraXML(ctx34g00_etapa.atdsrvnum   ,
                                       ctx34g00_etapa.atdsrvano   ,
                                       ctx34g00_etapa.atdsrvseq   ,
                                       ctx34g00_etapa.atdetpcod   ,
                                       ctx34g00_etapa.atdetpdat   ,
                                       ctx34g00_etapa.atdetphor   ,
                                       ctx34g00_etapa.empcod      ,
                                       ctx34g00_etapa.funmat      ,
                                       ctx34g00_etapa.pstcoddig   ,
                                       ctx34g00_etapa.atdmotnom   ,
                                       ctx34g00_etapa.atdvclsgl   ,
                                       ctx34g00_etapa.c24nomctt   ,
                                       ctx34g00_etapa.socvclcod   ,
                                       ctx34g00_etapa.srrcoddig   ,
                                       ctx34g00_etapa.envtipcod   ,
                                       ctx34g00_etapa.srvrcumtvcod,
                                       ctx34g00_etapa.acntmpqtd   ,
                                       ctx34g00_etapa.dstqtd      ,
                                       "S"                        ,
                                       ctx34g00_etapa.canmtvcod   , #PSI 2013-11843 - Pomar (Carga)
                                       ctx34g00_etapa.lcvcod      ,
                                       ctx34g00_etapa.aviestcod   )

  return l_xml.request
end function

# busca todos os dados para realizar a alteracao e monta o XML
#------------------------------------------#
function ctx34g00_altEtapa(param)
#------------------------------------------#

 define param record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   atdsrvseq like datmservico.atdsrvseq
 end record

 define ctx34g00_etapa record
   atdsrvnum    like datmsrvacp.atdsrvnum   ,
   atdsrvano    like datmsrvacp.atdsrvano   ,
   atdsrvseq    like datmsrvacp.atdsrvseq   ,
   atdetpcod    like datmsrvacp.atdetpcod   ,
   atdetpdat    like datmsrvacp.atdetpdat   ,
   atdetphor    like datmsrvacp.atdetphor   ,
   empcod       like datmsrvacp.empcod      ,
   funmat       like datmsrvacp.funmat      ,
   pstcoddig    like datmsrvacp.pstcoddig   ,
   atdmotnom    like datmsrvacp.atdmotnom   ,
   atdvclsgl    like datmsrvacp.atdvclsgl   ,
   c24nomctt    like datmsrvacp.c24nomctt   ,
   socvclcod    like datmsrvacp.socvclcod   ,
   srrcoddig    like datmsrvacp.srrcoddig   ,
   envtipcod    like datmsrvacp.envtipcod   ,
   srvrcumtvcod like datmsrvacp.srvrcumtvcod,
   acntmpqtd    like datmsrvacp.acntmpqtd   ,
   dstqtd       like datmsrvacp.dstqtd      ,
   canmtvcod    like datmsrvacp.canmtvcod   ,#PSI 2013-11843 - Pomar (Carga)
   atdsrvorg    like datmservico.atdsrvorg  ,
   lcvcod       like datklocadora.lcvcod    ,
   aviestcod    like datmavisrent.aviestcod
 end record

 define l_xml record
    request char(32766)
 end record

 define l_acntmpqtdmin like datmsrvacp.acntmpqtd
 define l_acntmpqtdmax like datmsrvacp.acntmpqtd

 initialize ctx34g00_etapa.* to null
 initialize l_xml.* to null
 let l_acntmpqtdmin = '  0:00:00'
 let l_acntmpqtdmax = ' 23:59:59'

whenever error continue
  open c_ctx34g00_003 using param.atdsrvnum,
                            param.atdsrvano,
                            param.atdsrvseq

  fetch c_ctx34g00_003  into  ctx34g00_etapa.atdsrvnum   ,
                              ctx34g00_etapa.atdsrvano   ,
                              ctx34g00_etapa.atdsrvseq   ,
                              ctx34g00_etapa.atdetpcod   ,
                              ctx34g00_etapa.atdetpdat   ,
                              ctx34g00_etapa.atdetphor   ,
                              ctx34g00_etapa.empcod      ,
                              ctx34g00_etapa.funmat      ,
                              ctx34g00_etapa.pstcoddig   ,
                              ctx34g00_etapa.atdmotnom   ,
                              ctx34g00_etapa.atdvclsgl   ,
                              ctx34g00_etapa.c24nomctt   ,
                              ctx34g00_etapa.socvclcod   ,
                              ctx34g00_etapa.srrcoddig   ,
                              ctx34g00_etapa.envtipcod   ,
                              ctx34g00_etapa.srvrcumtvcod,
                              ctx34g00_etapa.acntmpqtd   ,
                              ctx34g00_etapa.dstqtd      ,
                              ctx34g00_etapa.canmtvcod   ,#PSI 2013-11843 - Pomar (Carga)
                              ctx34g00_etapa.atdsrvorg

  # Zerar previsoes negativa
  if ctx34g00_etapa.acntmpqtd < l_acntmpqtdmin then
     let ctx34g00_etapa.acntmpqtd = l_acntmpqtdmin
  end if

  # Limitar previsoes em 24h
  if ctx34g00_etapa.acntmpqtd > l_acntmpqtdmax then
     let ctx34g00_etapa.acntmpqtd = l_acntmpqtdmax
  end if

  if ctx34g00_etapa.atdsrvorg = 8 then
     let ctx34g00_etapa.lcvcod = ctx34g00_etapa.pstcoddig
     let ctx34g00_etapa.aviestcod = ctx34g00_etapa.srrcoddig
     let ctx34g00_etapa.pstcoddig = null
     let ctx34g00_etapa.srrcoddig = null
  end if

 whenever error stop
   let l_xml.request = ctx34g00_geraXML(ctx34g00_etapa.atdsrvnum   ,
                                        ctx34g00_etapa.atdsrvano   ,
                                        ctx34g00_etapa.atdsrvseq   ,
                                        ctx34g00_etapa.atdetpcod   ,
                                        ctx34g00_etapa.atdetpdat   ,
                                        ctx34g00_etapa.atdetphor   ,
                                        ctx34g00_etapa.empcod      ,
                                        ctx34g00_etapa.funmat      ,
                                        ctx34g00_etapa.pstcoddig   ,
                                        ctx34g00_etapa.atdmotnom   ,
                                        ctx34g00_etapa.atdvclsgl   ,
                                        ctx34g00_etapa.c24nomctt   ,
                                        ctx34g00_etapa.socvclcod   ,
                                        ctx34g00_etapa.srrcoddig   ,
                                        ctx34g00_etapa.envtipcod   ,
                                        ctx34g00_etapa.srvrcumtvcod,
                                        ctx34g00_etapa.acntmpqtd   ,
                                        ctx34g00_etapa.dstqtd      ,
					                              "S"                        ,
                                        ctx34g00_etapa.canmtvcod   ,  #PSI 2013-11843 - Pomar (Carga)
                                        ctx34g00_etapa.lcvcod      ,
                                        ctx34g00_etapa.aviestcod   )
  return l_xml.request

end function

#------------------------------------------#
function ctx34g00_geraXML(param)
#------------------------------------------#

define param record
   atdsrvnum    like datmsrvacp.atdsrvnum   ,
   atdsrvano    like datmsrvacp.atdsrvano   ,
   atdsrvseq    like datmsrvacp.atdsrvseq   ,
   atdetpcod    like datmsrvacp.atdetpcod   ,
   atdetpdat    like datmsrvacp.atdetpdat   ,
   atdetphor    like datmsrvacp.atdetphor   ,
   empcod       like datmsrvacp.empcod      ,
   funmat       like datmsrvacp.funmat      ,
   pstcoddig    like datmsrvacp.pstcoddig   ,
   atdmotnom    like datmsrvacp.atdmotnom   ,
   atdvclsgl    like datmsrvacp.atdvclsgl   ,
   c24nomctt    like datmsrvacp.c24nomctt   ,
   socvclcod    like datmsrvacp.socvclcod   ,
   srrcoddig    like datmsrvacp.srrcoddig   ,
   envtipcod    like datmsrvacp.envtipcod   ,
   srvrcumtvcod like datmsrvacp.srvrcumtvcod,
   acntmpqtd    like datmsrvacp.acntmpqtd   ,
   dstqtd       like datmsrvacp.dstqtd      ,
   flgxmlcmp    char(1)                     , # flag para gerar xml completo
   canmtvcod    like datmsrvacp.canmtvcod   ,#PSI 2013-11843 - Pomar (Carga)
   lcvcod       like datklocadora.lcvcod    ,
   aviestcod    like datmavisrent.aviestcod
  end record

define l_xml record
    request char(6000)
 end record

define dstqtd_metros integer

#Mantis 38852 POMAR LAUDO WEB
define codCanFormatado integer

initialize codCanFormatado to null

let codCanFormatado = param.canmtvcod

#FIM Mantis 38852 POMAR LAUDO WEB



# Converte distancia de KM(ifx) para Metros (aw)
let dstqtd_metros = 0
if param.dstqtd > 0 then
   let dstqtd_metros = param.dstqtd * 1000
end if

 let  l_xml.request = '<ServicoEtapa>',
                          '<SequenciaEtapaServico>',param.atdsrvseq using "<<<&", '</SequenciaEtapaServico>',
                          '<EtapaAcompanhamento>',
                             '<CodigoEtapa>',param.atdetpcod using "<<&", '</CodigoEtapa>',
                          '</EtapaAcompanhamento>'

 if param.pstcoddig is not null and param.pstcoddig <> 0 then
    let  l_xml.request = l_xml.request clipped,
                          '<QuantidadeDistanciaMetrosAtendimentoCalculada>', dstqtd_metros using "<<<<<<<<<&", '</QuantidadeDistanciaMetrosAtendimentoCalculada>',
                          '<DataPrevisaoAtendimentoCalculada>',param.acntmpqtd clipped,'</DataPrevisaoAtendimentoCalculada>',
                          '<RecursoAtendimento>',
                            '<Prestador>',
                               '<CodigoPrestador>',param.pstcoddig using "<<<<<<&", '</CodigoPrestador>',
                            '</Prestador>'

                            if param.srrcoddig is not null and param.srrcoddig <> 0 then
                               let  l_xml.request = l_xml.request clipped,
                                                   '<Socorrista>',
                                                       '<CodigoSocorrista>',param.srrcoddig using "<<<<<<&", '</CodigoSocorrista>',
                                                   '</Socorrista>'
                            end if

                            if param.socvclcod is not null and param.socvclcod <> 0 then
                               let  l_xml.request = l_xml.request clipped,
                                                   '<VeiculoSocorro>',
                                                       '<CodigoVeiculo>',param.socvclcod using "<<<<<<&", '</CodigoVeiculo>',
                                                   '</VeiculoSocorro>'
                            end if

                            let  l_xml.request = l_xml.request clipped,
                                                '</RecursoAtendimento>'

 else
    if param.lcvcod is not null and param.lcvcod <> 0 then

        let  l_xml.request = l_xml.request clipped,
                             '<QuantidadeDistanciaMetrosAtendimentoCalculada>', dstqtd_metros using "<<<<<<<<<&", '</QuantidadeDistanciaMetrosAtendimentoCalculada>',
                             '<DataPrevisaoAtendimentoCalculada>',param.acntmpqtd clipped,'</DataPrevisaoAtendimentoCalculada>',
                             '<RecursoAtendimento>',
                               '<Locadora>',
                                  '<CodigoLocadora>', param.lcvcod, '</CodigoLocadora>',
                               '</Locadora>',
                               '<LojaLocadora>',
                                  '<CodigoLojaLocadora>', param.aviestcod, '</CodigoLojaLocadora>',
                               '</LojaLocadora>',
                             '</RecursoAtendimento>'
    end if
 end if

 let  l_xml.request = l_xml.request clipped,
                          '<DataAtualizacao>',param.atdetpdat clipped,' ',param.atdetphor clipped,'</DataAtualizacao>',
                          '<UsuarioAtualizacao>',
                              '<Empresa>',param.empcod using "<<&",'</Empresa>',
                              '<Matricula>',param.funmat using "<<<<<&", '</Matricula>',
                              '<TipoUsuario>F</TipoUsuario>',
                          '</UsuarioAtualizacao>',
                          '<CodigoMotivoCancelamento>',codCanFormatado clipped, '</CodigoMotivoCancelamento>', #PSI 2013-11843 - Pomar (Carga)
                      '</ServicoEtapa>'


 if param.flgxmlcmp == 'S' then
    let l_xml.request = '<?xml version="1.0" encoding="UTF-8" ?>',
                        '<REQUEST>',
                        '<SERVICO>ATUALIZACAO_ETAPA</SERVICO>',
                        '<OBJETOS>',
                           '<ServicoCentral>',
                               '<CodigoOrigemServico/>',
                               '<NumeroServicoAtendimento>',param.atdsrvnum using "<<<<<<&", '</NumeroServicoAtendimento>',
                               '<AnoServicoAtendimento>',param.atdsrvano using "<&", '</AnoServicoAtendimento>',
                               '<CodigoAssuntoCentral/>',
                           '</ServicoCentral>',
                           '<Etapas>', l_xml.request clipped, '</Etapas>',
                        '</OBJETOS>',
                        '</REQUEST>'
 end if

 return l_xml.request
end function


# busca todos os dados para realizar a inclusao e monta o XML
#------------------------------------------#
function ctx34g00_xmlEtapas(param)
#------------------------------------------#
 define param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
 end record

 define ctx34g00_etapa record
    atdsrvseq    like datmsrvacp.atdsrvseq   ,
    atdetpcod    like datmsrvacp.atdetpcod   ,
    atdetpdat    like datmsrvacp.atdetpdat   ,
    atdetphor    like datmsrvacp.atdetphor   ,
    empcod       like datmsrvacp.empcod      ,
    funmat       like datmsrvacp.funmat      ,
    pstcoddig    like datmsrvacp.pstcoddig   ,
    atdmotnom    like datmsrvacp.atdmotnom   ,
    atdvclsgl    like datmsrvacp.atdvclsgl   ,
    c24nomctt    like datmsrvacp.c24nomctt   ,
    socvclcod    like datmsrvacp.socvclcod   ,
    srrcoddig    like datmsrvacp.srrcoddig   ,
    envtipcod    like datmsrvacp.envtipcod   ,
    srvrcumtvcod like datmsrvacp.srvrcumtvcod,
    acntmpqtd    like datmsrvacp.acntmpqtd   ,
    dstqtd       like datmsrvacp.dstqtd      ,
    canmtvcod    like datmsrvacp.canmtvcod   , #PSI 2013-11843 - Pomar (Carga)
    atdsrvorg    like datmservico.atdsrvorg  ,
    lcvcod       like datklocadora.lcvcod    ,
    aviestcod    like datmavisrent.aviestcod
 end record

 define l_xml record
    request char(15000)
 end record

 define l_acntmpqtdmin like datmsrvacp.acntmpqtd
 define l_acntmpqtdmax like datmsrvacp.acntmpqtd

 initialize ctx34g00_etapa.* to null
 initialize l_xml.* to null
 let l_acntmpqtdmin = '  0:00:00'
 let l_acntmpqtdmax = ' 23:59:59'

 whenever error continue

 open c_ctx34g00_017 using param.atdsrvnum,
                           param.atdsrvano

 foreach c_ctx34g00_017  into  ctx34g00_etapa.atdsrvseq   ,
                               ctx34g00_etapa.atdetpcod   ,
                               ctx34g00_etapa.atdetpdat   ,
                               ctx34g00_etapa.atdetphor   ,
                               ctx34g00_etapa.empcod      ,
                               ctx34g00_etapa.funmat      ,
                               ctx34g00_etapa.pstcoddig   ,
                               ctx34g00_etapa.atdmotnom   ,
                               ctx34g00_etapa.atdvclsgl   ,
                               ctx34g00_etapa.c24nomctt   ,
                               ctx34g00_etapa.socvclcod   ,
                               ctx34g00_etapa.srrcoddig   ,
                               ctx34g00_etapa.envtipcod   ,
                               ctx34g00_etapa.srvrcumtvcod,
                               ctx34g00_etapa.acntmpqtd   ,
                               ctx34g00_etapa.dstqtd      ,
                               ctx34g00_etapa.canmtvcod   ,#PSI 2013-11843 - Pomar (Carga)
                               ctx34g00_etapa.atdsrvorg

    #Zerar previsoes negativa
    if ctx34g00_etapa.acntmpqtd  < l_acntmpqtdmin then
      let ctx34g00_etapa.acntmpqtd = l_acntmpqtdmin
    end  if

    # Limitar previsoes em 24h
    if ctx34g00_etapa.acntmpqtd > l_acntmpqtdmax then
       let ctx34g00_etapa.acntmpqtd = l_acntmpqtdmax
    end if

    if ctx34g00_etapa.atdsrvorg = 8 then
       let ctx34g00_etapa.lcvcod = ctx34g00_etapa.pstcoddig
       let ctx34g00_etapa.aviestcod = ctx34g00_etapa.srrcoddig
       let ctx34g00_etapa.pstcoddig = null
       let ctx34g00_etapa.srrcoddig = null
    end if

    let  l_xml.request = l_xml.request clipped,
                         ctx34g00_geraXML(param.atdsrvnum            ,
                                          param.atdsrvano            ,
                                          ctx34g00_etapa.atdsrvseq   ,
                                          ctx34g00_etapa.atdetpcod   ,
                                          ctx34g00_etapa.atdetpdat   ,
                                          ctx34g00_etapa.atdetphor   ,
                                          ctx34g00_etapa.empcod      ,
                                          ctx34g00_etapa.funmat      ,
                                          ctx34g00_etapa.pstcoddig   ,
                                          ctx34g00_etapa.atdmotnom   ,
                                          ctx34g00_etapa.atdvclsgl   ,
                                          ctx34g00_etapa.c24nomctt   ,
                                          ctx34g00_etapa.socvclcod   ,
                                          ctx34g00_etapa.srrcoddig   ,
                                          ctx34g00_etapa.envtipcod   ,
                                          ctx34g00_etapa.srvrcumtvcod,
                                          ctx34g00_etapa.acntmpqtd   ,
                                          ctx34g00_etapa.dstqtd      ,
                                          'N'                        ,
                                          ctx34g00_etapa.canmtvcod   , #PSI 2013-11843 - Pomar (Carga))
                                          ctx34g00_etapa.lcvcod      ,
                                          ctx34g00_etapa.aviestcod   )
 end foreach

 whenever error stop

 return l_xml.request
end function

# Padroniza o envio de MQ para o AW
#------------------------------------------#
function ctx34g00_enviar_mq_AW(param)
#------------------------------------------#
 define param record
    request  char(32766)
 end record

 define l_xml record
    response char(32766)
 end record

 define l_status integer
 define l_msg    char(500)
 define l_online smallint
 define l_tentativas smallint

 let l_tentativas = 1
 while true
    let l_online = online()
    call figrc006_enviar_pseudo_mq("DPCNVACIONAJAVA01R",
                                   param.request clipped,
                                   l_online)
            returning l_status,
                      l_msg,
                      l_xml.response

    if l_status = 0 or l_tentativas >= 1 then
    	 exit while
    end if
    let l_tentativas = l_tentativas + 1
 end while

 return l_status,
        l_msg,
        l_xml.response

end function


# Grava dados para envio ao AW em processo Batch
#----------------------------------------------#
function ctx34g00_grava_mq_AW_batch(param)
#----------------------------------------------#
 define param record
 	  relpamtip  like igbmparam.relpamtip, # 1=APOS GRAVA SERVICO, 2=APOS GRAVA ETAPA e 3=APOS GRAVA HISTORICO
    relpamtxt  like igbmparam.relpamtxt
 end record

 define l_cont smallint,
        l_relpamseq like igbmparam.relpamseq

 initialize l_cont, l_relpamseq to null

 if not m_ctx34g00_prep then
    call ctx34g00_prepare()
 end if

 open c_ctx34g00_021 using param.relpamtip,
                           param.relpamtxt

 fetch c_ctx34g00_021 into l_relpamseq

 if sqlca.sqlcode = 100 then

 	  whenever error continue
    set lock mode to not wait

    let l_cont = 0
    while true
       let l_cont = l_cont + 1

       execute p_ctx34g00_018 using param.relpamtip,
                                    param.relpamtxt
       if sqlca.sqlcode = -243 or
          sqlca.sqlcode = -244 or
          sqlca.sqlcode = -245 or
          sqlca.sqlcode = -246 then
          if l_cont < 11  then
             sleep 1
             continue while
          end if
       end if
       exit while
    end while

    set lock mode to wait
    whenever error stop

 end if

 close c_ctx34g00_021

 return
end function


# Processa envio ao AW Gravados em processo Batch
#-----------------------------------------------#
function ctx34g00_processa_mq_AW()
#-----------------------------------------------#
 define ws record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,

   atdsrvseq like datmservico.atdsrvseq,
   c24txtseq like datmservhist.c24txtseq,
   tipoEnvio smallint, # 1- insert da ultima sequencia  2- update da sequencia

   relpamseq  like igbmparam.relpamseq,
   relpamtip  like igbmparam.relpamtip, # 1=APOS GRAVA SERVICO, 2=APOS GRAVA ETAPA e 3=APOS GRAVA HISTORICO
   relpamtxt  like igbmparam.relpamtxt

 end record

 define l_datahora  datetime year to fraction,
        l_cont smallint,
        temptxt char(10)

 initialize ws.*, l_datahora, l_cont  to null

 if not m_ctx34g00_prep then
    call ctx34g00_prepare()
 end if

 let l_datahora = current
 display l_datahora, " - INICIO DO PROCESSO DE REENVIO AW"

 let l_cont = 0
 foreach c_ctx34g00_019 into ws.relpamtip,
                             ws.relpamtxt,
                             ws.relpamseq
    case ws.relpamtip
       when 1 # APOS GRAVA SERVICO
          let ws.atdsrvnum = ws.relpamtxt[1,7]
          let ws.atdsrvano = ws.relpamtxt[9,10]

          call ctx34g02_apos_grvservico(ws.atdsrvnum, ws.atdsrvano)

       when 2 # APOS GRAVA ETAPA
          let ws.atdsrvnum = ws.relpamtxt[1,7]
          let ws.atdsrvano = ws.relpamtxt[9,10]
          let ws.c24txtseq = ws.relpamtxt[12,15]
          let ws.tipoEnvio = ws.relpamtxt[17,17]

          call ctx34g00_apos_grvetapa(ws.atdsrvnum, ws.atdsrvano, ws.c24txtseq, ws.tipoEnvio)

       when 3 # APOS GRAVA HISTORICO
          let ws.atdsrvnum = ws.relpamtxt[1,7]
          let ws.atdsrvano = ws.relpamtxt[9,10]
          let ws.c24txtseq = ws.relpamtxt[12,15]
          let ws.tipoEnvio = ws.relpamtxt[17,17]

          call ctx34g01_apos_grvhistorico(ws.atdsrvnum, ws.atdsrvano, ws.c24txtseq, ws.tipoEnvio)
    end case

    let l_datahora = current
    display l_datahora, "-Srv:", ws.atdsrvnum using "&&&&&&&", "-", ws.atdsrvano using "&&", " operacao:", ws.relpamtip, " SEQ:", ws.c24txtseq, " TIP:" , ws.tipoEnvio

    # APAGA REGISTRO APOS PROCESSAMENTO
    execute p_ctx34g00_020 using ws.relpamseq

    # Espera 1 segunda a cada 4 requisição para nao sobrecarregar WS do AW
    let l_cont = l_cont + 1
    if l_cont >= 4 then
       sleep 1
       let l_cont = 0
    end if

 end foreach

 let l_datahora = current
 display l_datahora, " - FIM DO PROCESSO DE REENVIO AW"

end function

#PSI 2013-11843 - Pomar (Cancelamento) - Inicio
#------------------------------------------#
function ctx34g00_SiebelCanc_geraXML(lr_param)
#------------------------------------------#

 define lr_param record
   sblintcod    like datmservico.sblintcod ,
   atdsrvnum    like datmsrvacp.atdsrvnum  ,
   atdsrvano    like datmsrvacp.atdsrvano  ,
   atdetpcod    like datmsrvacp.atdetpcod  ,
   atdetpdat    like datmsrvacp.atdetpdat  ,
   atdetphor    like datmsrvacp.atdetphor  ,
   canmtvcod    like datmsrvacp.canmtvcod  ,
   empcod       like datmservico.empcod    ,
   funmat       like datmservico.funmat    ,
   usrtip       like datmservico.usrtip
 end record

  define l_xml record
      request char(32766)
   end record

  define l_canmtvdsc  char(40)
  define l_aux_data   char(20)

  define codCanFormatado integer


 initialize l_xml.* to null

 #Converte para o formato w3C
 let l_aux_data = lr_param.atdetpdat using "yyyy-MM-dd"

 #Buscar descriçao do motivo de cancelamento
 whenever error continue
 open c_ctx34g00_010 using lr_param.canmtvcod
 fetch c_ctx34g00_010 into l_canmtvdsc
 whenever error stop

 #Formata o codigo
 let codCanFormatado = lr_param.canmtvcod

 #Xml de envio ao SOA
 let l_xml.request = '<v1:adicionarCancelamentoServicoSiebelRequest' clipped,
                     'xmlns:v1="http://www.portoseguro.com.br/corporativo/integration/' clipped,
                     'DadosAtendimentoSocorristaIntegrationServiceABCS/V1_0/"' clipped,
                     'xmlns:v11="http://www.portoseguro.com.br/ebo/DadosAtendimentoSocorrista/V1_0">',
                     '<v1:adicionarCancelamentoServicoSiebelRequest>',
                        '<v11:codigoServicoSiebel>' clipped,lr_param.sblintcod clipped,'</v11:codigoServicoSiebel>',
                        '<v11:codigoCancelamento>',codCanFormatado clipped,'</v11:codigoCancelamento>',
                        '<v11:descricaoMotivo>',l_canmtvdsc clipped, '</v11:descricaoMotivo>',
                        '<v11:dataHora>',l_aux_data clipped, 'T',lr_param.atdetphor clipped,':00','</v11:dataHora>',
                        '<v11:tipoUsuario>',lr_param.usrtip clipped,'</v11:tipoUsuario>',
                        '<v11:matricula>',lr_param.funmat clipped,'</v11:matricula>',
                        '<v11:codigoEmpresa>',lr_param.empcod clipped, '</v11:codigoEmpresa>',
                    '</v1:adicionarCancelamentoServicoSiebelRequest>'

 return l_xml.request

end function

#------------------------------------------#
function ctx34g00_SiebelEtapa_geraXML(lr_param)
#------------------------------------------#

  define lr_param record
   sblintcod   like datmservico.sblintcod,
   atdetpcod   like datmsrvacp.atdetpcod,
   atdetpdes   like datketapa.atdetpdes,
   envtipcod   like datmsrvacp.envtipcod,
   envtipdes   char(20),
   empcod      like datmsrvacp.empcod,
   funmat      like datmsrvacp.funmat,
   funnom      like isskfunc.funnom,
   pstcoddig   like datmsrvacp.pstcoddig,
   nomgrr      like dpaksocor.nomgrr,
   endcid      like dpaksocor.endcid,
   endufd      like dpaksocor.endufd,
   dddcod      like dpaksocor.dddcod,
   teltxt      like dpaksocor.teltxt,
   srrcoddig   like datksrr.srrcoddig,
   srrnom      like datksrr.srrnom,
   celdddcod   like datksrr.celdddcod,
   celtelnum   like datksrr.celtelnum,
   atdvclsgl   like datkveiculo.atdvclsgl,
   vcltipdes   like iddkdominio.cpodes
  end record

  define l_xml record
      request char(32766)
  end record


  return l_xml.request
end function

# Removido conforme email do Raji
#------------------------------------------#
#function ctx34g00_Sbl_CtrErro(lr_param)
#------------------------------------------#
#
#define lr_param record
#   atdsrvnum         like datmservico.atdsrvnum,
#   atdsrvano         like datmservico.atdsrvano,
#   codIntegracao     integer
#end record
#
#define l_qtdTentativas   integer
#define l_retorno         smallint
#
#let l_qtdTentativas = 0
#
#     #Verifica se o serviço já está na tabela de controle
#     whenever error continue
#     open c_ctx34g00_007 using lr_param.atdsrvnum,
#                               lr_param.atdsrvano,
#                               lr_param.codIntegracao
#     fetch c_ctx34g00_007 into l_qtdTentativas
#     whenever error stop
#
#     if sqlca.sqlcode = 0 then
#          let l_retorno = 0
#     else
#          let l_retorno = 1
#     end if
#
#     return l_retorno,
#            l_qtdTentativas
#
#end function

##------------------------------------------#
#function ctx34g00_Sbl_Cancel(lr_param)
##------------------------------------------#
#
# define lr_param record
#   atdsrvnum    like datmservico.atdsrvnum,
#   atdsrvano    like datmservico.atdsrvano,
#   atdsrvseq    like datmsrvacp.atdsrvseq,
#   atdetpcod    like datmsrvacp.atdetpcod,
#   atdetpdat    like datmsrvacp.atdetpdat,
#   atdetphor    like datmsrvacp.atdetphor,
#   empcod       like datmservico.empcod,
#   funmat       like datmservico.funmat,
#   canmtvcod    like datmsrvacp.canmtvcod,
#   sblintcod    like datmservico.sblintcod
# end record
#
#
# define lr_xml record
#   request      char(32766),
#   response     char(32766)
# end record
#
# define lr_retornoMQ record
#     status      integer,
#     mensagem    char(500)
# end record
#
# define l_fila            char(23)
# define l_codIntegracao   integer
# define l_possuiErro      smallint
# define l_qtdTentativas   smallint
# define l_c24txtseq       smallint
# define l_atdetpcod       like datmsrvacp.atdetpcod   #Kelly
#
# initialize lr_xml.* to null
#
# let l_codIntegracao = 2 #CANCELAMENTO
# let l_fila = "PSOACCANSIEBSOA01R"
# let l_c24txtseq = 1 #INCLUIDO PARA TESTE, NECESSÁRIO AJUSTE NA TABELA
#
#
# #Verifica se o serviço já está na tabela de controle
# #call ctx34g00_Sbl_CtrErro(lr_param.atdsrvnum,
# #                          lr_param.atdsrvano,
# #                          l_codIntegracao)
# #    returning l_possuiErro,
# #              l_qtdTentativas
#
# #Gera XML de integração
#
# let lr_xml.request = ctx34g00_SiebelCanc_geraXML(lr_param.sblintcod,
#                                                 lr_param.atdsrvnum,
#                                                 lr_param.atdsrvano,
#                                                 lr_param.atdetpcod,
#                                                 lr_param.atdetpdat,
#                                                 lr_param.atdetphor,
#                                                 lr_param.canmtvcod,
#                                                 lr_param.empcod,
#                                                 lr_param.funmat,
#                                                 "F")
# display "XML gerado:", lr_xml.request clipped
# sleep 1
#
# if lr_xml.request is not null and lr_xml.request <> " "  then
#      #Envia requisiação para fila MQ
#      call ctx34g00_Sbl_EnviarReq(l_fila, lr_xml.request)
#           returning lr_retornoMQ.status,
#                     lr_retornoMQ.mensagem,
#                     lr_xml.response
#
#      display "ERRO BRUNNO MQ: ",lr_retornoMQ.status
#
#      #Removido conforme email RAJI
#      #if lr_retornoMQ.status = 0 then
#      #   #Incluir tratamento erro
#      #   if l_qtdTentativas is not null and l_qtdTentativas <> " "  then
#      #      #Deleta registros do tipo de integração CANCELAMENTO
#      #      whenever error continue
#      #      execute p_ctx34g00_009 using lr_param.atdsrvnum,
#      #                                   lr_param.atdsrvano,
#      #                                   l_codIntegracao
#      #      whenever error stop
#      #   end if
#      ##else Removido conforme email RAJI
#      #     #if l_possuiErro = 0 then
#      #     #    #Atualiza quantidade de tentativas
#      #     #    let l_qtdTentativas = l_qtdTentativas + 1
#      #     #
#      #     #    whenever error continue
#      #     #    execute p_ctx34g00_008 using lr_param.atdsrvnum,
#      #     #                                 lr_param.atdsrvano,
#      #     #                                 lr_param.atdsrvseq,
#      #     #                                 l_c24txtseq,
#      #     #                                 l_codIntegracao,
#      #     #                                 l_qtdTentativas,
#      #     #                                 lr_retornoMQ.mensagem
#      #     #    whenever error stop
#      #     #else
#      #     #    #Grava registro da tabela de controle para futuro reprocessamento
#      #     #    display "Vou gravar na tabela de controle"
#      #     #    sleep 2
#      #     #
#      #     #    whenever error continue
#      #     #    execute p_ctx34g00_008 using lr_param.atdsrvnum,
#      #     #                                 lr_param.atdsrvano,
#      #     #                                 lr_param.atdsrvseq,
#      #     #                                 l_c24txtseq,
#      #     #                                 l_codIntegracao,
#      #     #                                 l_qtdTentativas,
#      #     #                                 lr_retornoMQ.mensagem
#      #     #    whenever error stop
#      #     #
#      #     #    display "Erro na gravação da tabela de controle"
#      #     #    sleep 2
#      #     #
#      #     #    if sqlca.sqlcode <> 0 then
#      #     #       display "Erro ao gravar tabela de controle. sqlcode: ", sqlca.sqlcode
#      #     #    end if
#      #     #end if
#      #end if
# else
#   #manda email
# end if
#
#end function

#Removido conforme alinhamento com a Kelly e o Robert
##------------------------------------------#
#function ctx34g00_Sbl_AtualizaEtapa(lr_param)
##------------------------------------------#
#  define lr_param record
#   atdsrvnum like datmsrvacp.atdsrvnum,
#   atdsrvano like datmsrvacp.atdsrvano,
#   sblintcod like datmservico.sblintcod
# end record
#
# define ctx34g00_etapa record
#   atdetpcod like datmsrvacp.atdetpcod,
#   atdetpdes like datketapa.atdetpdes,
#   atdsrvseq like datmsrvacp.atdsrvseq
# end record
#
# define ctx34g00_acionamento record
#   envtipcod   like datmsrvacp.envtipcod,
#   envtipdes   char(20),
#   empcod      like datmsrvacp.empcod,
#   funmat      like datmsrvacp.funmat,
#   funnom      like isskfunc.funnom,
#   pstcoddig   like datmsrvacp.pstcoddig,
#   socvclcod   like datmsrvacp.socvclcod,
#   srrcoddig   like datmsrvacp.srrcoddig,
#   nomgrr      like dpaksocor.nomgrr,
#   endcid      like dpaksocor.endcid,
#   endufd      like dpaksocor.endufd,
#   dddcod      like dpaksocor.dddcod,
#   teltxt      like dpaksocor.teltxt
# end record
#
# define ctx34g00_socorrista record
#   srrcoddig   like datksrr.srrcoddig,
#   srrnom      like datksrr.srrnom,
#   celdddcod   like datksrr.celdddcod,
#   celtelnum   like datksrr.celtelnum
# end record
#
# define ctx34g00_veiculo record
#   atdvclsgl   like datkveiculo.atdvclsgl,
#   vcltipdes   like iddkdominio.cpodes
# end record
#
# define lr_xml record
#   request      char(32766),
#   response     char(32766)
# end record
#
# define lr_retornoMQ record
#     status      integer,
#     mensagem    char(500)
# end record
#
# define l_fila            char(23)
# define l_codIntegracao   integer
# define l_possuiErro      smallint
# define l_qtdTentativas   smallint
# define l_c24txtseq       smallint
#
# initialize ctx34g00_etapa.* to null
# initialize ctx34g00_acionamento.* to null
# initialize ctx34g00_socorrista.* to null
#
# initialize lr_xml.* to null
#
# let l_codIntegracao = 3  #ETAPA
# let l_fila = "NOME DA FILA"
# let l_c24txtseq = 1 #INCLUIDO PARA TESTE, NECESSÁRIO AJUSTE NA TABELA
#
# #Busca informações de etapa
# whenever error continue
# open c_ctx34g00_013 using lr_param.atdsrvnum,
#                           lr_param.atdsrvano,
#                           lr_param.atdsrvnum,
#                           lr_param.atdsrvano
# fetch c_ctx34g00_013 into ctx34g00_etapa.atdetpcod,
#                           ctx34g00_etapa.atdetpdes,
#                           ctx34g00_etapa.atdsrvseq
# whenever error stop
#
# if ctx34g00_etapa.atdetpcod = 3 or
#    ctx34g00_etapa.atdetpcod = 4 or
#    ctx34g00_etapa.atdetpcod = 10 then
#
#      #Busca informações acionamento
#      whenever error continue
#      open c_ctx34g00_014 using lr_param.atdsrvnum,
#                                lr_param.atdsrvano,
#                                lr_param.atdsrvnum,
#                                lr_param.atdsrvano
#      fetch c_ctx34g00_014 into ctx34g00_acionamento.envtipcod,
#                                ctx34g00_acionamento.empcod,
#                                ctx34g00_acionamento.funmat,
#                                ctx34g00_acionamento.funnom,
#                                ctx34g00_acionamento.pstcoddig,
#                                ctx34g00_acionamento.socvclcod,
#                                ctx34g00_acionamento.srrcoddig,
#                                ctx34g00_acionamento.nomgrr,
#                                ctx34g00_acionamento.endcid,
#                                ctx34g00_acionamento.endufd,
#                                ctx34g00_acionamento.dddcod,
#                                ctx34g00_acionamento.teltxt
#      whenever error stop
#
#      #Seta descrição tipo envio
#      case ctx34g00_acionamento.envtipcod
#          when 0
#             let ctx34g00_acionamento.envtipdes = "Telefone"
#          when 1
#             let ctx34g00_acionamento.envtipdes = "GPS"
#          when 2
#             let ctx34g00_acionamento.envtipdes = "Internet"
#          when 3
#             let ctx34g00_acionamento.envtipdes = "Fax"
#      end case
#
#      if ctx34g00_acionamento.srrcoddig is null then
#           #Busca informações socorrista
#           whenever error continue
#           open c_ctx34g00_015 using ctx34g00_acionamento.srrcoddig
#           fetch c_ctx34g00_015 into ctx34g00_socorrista.srrcoddig,
#                                     ctx34g00_socorrista.srrnom,
#                                     ctx34g00_socorrista.celdddcod,
#                                     ctx34g00_socorrista.celtelnum
#           whenever error stop
#      end if
#
#      if ctx34g00_acionamento.socvclcod is null then
#           #Busca informações veiculo
#           whenever error continue
#           open c_ctx34g00_015 using ctx34g00_acionamento.socvclcod
#           fetch c_ctx34g00_015 into ctx34g00_veiculo.atdvclsgl,
#                                     ctx34g00_veiculo.vcltipdes
#           whenever error stop
#      end if
# end if
#
# #Verifica se o serviço já está na tabela de controle
# #Removido conforme email RAJI
# #call ctx34g00_Sbl_CtrErro(lr_param.atdsrvnum,
# #                          lr_param.atdsrvano,
# #                          l_codIntegracao)
# #returning l_possuiErro,
# #          l_qtdTentativas
#
# #Gera XML de integração
# let lr_xml.request =
#     ctx34g00_SiebelEtapa_geraXML(lr_param.sblintcod,
#                                  ctx34g00_etapa.atdetpcod,
#                                  ctx34g00_etapa.atdetpdes,
#                                  ctx34g00_acionamento.envtipcod,
#                                  ctx34g00_acionamento.envtipdes,
#                                  ctx34g00_acionamento.empcod,
#                                  ctx34g00_acionamento.funmat,
#                                  ctx34g00_acionamento.funnom,
#                                  ctx34g00_acionamento.pstcoddig,
#                                  ctx34g00_acionamento.nomgrr,
#                                  ctx34g00_acionamento.endcid,
#                                  ctx34g00_acionamento.endufd,
#                                  ctx34g00_acionamento.dddcod,
#                                  ctx34g00_acionamento.teltxt,
#                                  ctx34g00_socorrista.srrcoddig,
#                                  ctx34g00_socorrista.srrnom,
#                                  ctx34g00_socorrista.celdddcod,
#                                  ctx34g00_socorrista.celtelnum,
#                                  ctx34g00_veiculo.atdvclsgl,
#                                  ctx34g00_veiculo.vcltipdes)
#
# if lr_xml.request is not null and lr_xml.request <> " "  then
#      #Envia requisiação para fila MQ
#      call ctx34g00_Sbl_EnviarReq(l_fila, lr_xml.request)
#           returning lr_retornoMQ.status,
#                     lr_retornoMQ.mensagem,
#                     lr_xml.response
#
#      #Removido conforme email Raji
#      #if lr_retornoMQ.status = 0 then
#      #   #Incluir tratamento erro
#      #   if l_qtdTentativas is not null and l_qtdTentativas <> " "  then
#      #      #Deleta registros do tipo de integração ETAPA
#      #      whenever error continue
#      #      execute p_ctx34g00_009 using lr_param.atdsrvnum,
#      #                                   lr_param.atdsrvano,
#      #                                   l_codIntegracao
#      #      whenever error stop
#      #   end if
#      ##else Removido conforme email Raji
#      #     #if l_possuiErro = 0 then
#      #     #    #Atualiza quantidade de tentativas
#      #     #    let l_qtdTentativas = l_qtdTentativas + 1
#      #     #
#      #     #    whenever error continue
#      #     #    execute p_ctx34g00_008 using lr_param.atdsrvnum,
#      #     #                                 lr_param.atdsrvano,
#      #     #                                 ctx34g00_etapa.atdsrvseq,
#      #     #                                 l_c24txtseq,
#      #     #                                 l_codIntegracao,
#      #     #                                 l_qtdTentativas,
#      #     #                                 lr_retornoMQ.mensagem
#      #     #    whenever error stop
#      #     #else
#      #     #    #Grava registro da tabela de controle para futuro reprocessamento
#      #     #    display "Vou gravar na tabela de controle"
#      #     #    sleep 2
#      #     #
#      #     #    whenever error continue
#      #     #    execute p_ctx34g00_008 using lr_param.atdsrvnum,
#      #     #                                 lr_param.atdsrvano,
#      #     #                                 ctx34g00_etapa.atdsrvseq,
#      #     #                                 l_c24txtseq,
#      #     #                                 l_codIntegracao,
#      #     #                                 l_qtdTentativas,
#      #     #                                 lr_retornoMQ.mensagem
#      #     #    whenever error stop
#      #     #
#      #     #    display "Erro na gravação da tabela de controle"
#      #     #    sleep 2
#      #     #
#      #     #    if sqlca.sqlcode <> 0 then
#      #     #       display "Erro ao gravar tabela de controle. sqlcode: ", sqlca.sqlcode
#      #     #    end if
#      #     #end if
#      #end if
# else
#   #manda email
# end if
#
#end function

#------------------------------------------#
function ctx34g00_Sbl_EnviarReq(lr_param)
#------------------------------------------#
 define lr_param record
     fila      char(23),
     request   char(32766)
 end record

 define lr_retorno record
     status      integer,
     mensagem    char(500),
     response    char(32766)
 end record

 define l_online smallint

 let l_online = online()

 #Chama fila MQ
 call figrc006_enviar_pseudo_mq(lr_param.fila clipped,
                                lr_param.request clipped,
                                l_online)
                     returning lr_retorno.status,
                               lr_retorno.mensagem,
                               lr_retorno.response
  return lr_retorno.status,
         lr_retorno.mensagem,
         lr_retorno.response

end function
#PSI 2013-11843 - Pomar (Cancelamento) - Fim
