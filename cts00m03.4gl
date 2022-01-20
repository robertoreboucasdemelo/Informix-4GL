#############################################################################
# Nome do Modulo: CTS00M03                                            Pedro #
#                                                                   Marcelo #
# Manutencao da posicao da frota(guincho/tecnico)                  Abr/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 01/02/2000  PSI 10204-0  Wagner       Incluir filtro Tp.assistencia do    #
#                                       socorrista na pesquisa.             #
#---------------------------------------------------------------------------#
# 13/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#---------------------------------------------------------------------------#
# 07/08/2000  PSI 111384   Marcus       Tratar QRU-REC, QRU-INI e QRU-FIM   #
#---------------------------------------------------------------------------#
# 22/08/2000  Correio      Marcus       Tempo de Atividade por Viatura      #
#---------------------------------------------------------------------------#
# 06/09/2000  PSI 114596   Ruiz         Conclusao de Servico pelo atendente #
#---------------------------------------------------------------------------#
# 19/01/2001  PSI 12339-0  Marcus      Incluir link com Posicao da Frota    #
#---------------------------------------------------------------------------#
# 22/05/2001  PSI .......  Wagner      Incluir acesso ao modulo de envio    #
#                                      de mensagens via pager por tecla(F7) #
#---------------------------------------------------------------------------#
# 25/10/2001  PSI 132438   Paula       Incluir tecla(F10) para chamar pop_up#
#             Fab. Software            que verifica ultima atividade por    #
#                                      viatura                              #
#---------------------------------------------------------------------------#
# 10/09/2002  PSI 15918-2  Wagner      Tratamento para RET servicos RE.     #
#---------------------------------------------------------------------------#
# 04/02/2003  CT 276126    Wagner      Acerto default grupo de distribuicao #
#---------------------------------------------------------------------------#
#                       * * * A L T E R A C A O * * *                       #
#.......................................................................... #
# Data        Autor Fabrica  OSF/PSI      Alteracao                         #
# ----------  ------------- ------------- ----------------------------------#
# 27/01/2004  Sonia Sasaki  31631/177903  Inclusao F6 e execucao da funcao  #
#                                         cta11m00 (Motivos de recusa).     #
#                                                                           #
#---------------------------------------------------------------------------#
# 15/12/2004  Lucas, Meta   PSI189715     Remocao de criterios especiais das#
#                                         viaturas em situacao QTP.         #
#---------------------------------------------------------------------------#
# 08/04/2005  Robson, Meta  PSI189715     Atualizar o prestador no servico. #
#                                         Obter os servicos multiplos do    #
#                                         Original.                         #
#                                         Atualizar o prestador no servico  #
#                                         multiplo.                         #
#---------------------------------------------------------------------------#
# 24/08/2005 James, Meta     PSI 192015 Chamar funcao para Locais Condicoes #
#                                       do veiculo (ctc61m02)               #
#---------------------------------------------------------------------------#
# 27/04/2006 Priscila        PSI 198714 Validar se prestador escolhido      #
#                                       atende natureza ou assistencia do   #
#                                       servico                             #
#---------------------------------------------------------------------------#
# 17/11/2006 Ligia Mattge    PSI 205206 ciaempcod                           #
#---------------------------------------------------------------------------#
# 01/03/2007 Zyon            PSI 206261 Consulta produtividade por inspetor #
#---------------------------------------------------------------------------#
# 05/06/2008                 PSI 224782 Criacao metodo busca_assistencia    #
# 28/01/2009 Adriano Santos  PSI 235849 Considerar serviço SINISTRO RE      #
#---------------------------------------------------------------------------#
# 09/12/2011 Jose Kurihara   PSI-2011-21009 PR Incluir novos filtros:       #
#                                          geral de Grupo e Tipo de Servico #
#                                          Apresentar contagem geral ativid #
#---------------------------------------------------------------------------#
# 20/01/2012 Jose Kurihara   SM-2012-00756 novo filtro Tipo SRV=orgatdtodos #
#                                         e ativar rodape funcao operacao=2 #
#---------------------------------------------------------------------------#
database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

  define m_cts00m03_prep smallint
  define m_cts00m03_tempo char(15)
  define m_cts00m03_pop   smallint                    # PSI-2011-21009

  define ma_tipgrp  array[200] of record              # PSI-2011-21009
         cponom     like datkdominio.cponom
        ,cpodes     like datkdominio.cpodes
  end record

#-------------------------#
function cts00m03_prepare()
#-------------------------#

  define l_sql char(700)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = "select socvcltip ",
               " from datkveiculo ",
              " where socvclcod = ? "
  prepare pcts00m03001  from l_sql
  declare ccts00m03001   cursor for pcts00m03001

  let l_sql = " select soceqpabv ",
                    "   from datreqpvcl, outer datkvcleqp",
                    "  where datreqpvcl.socvclcod = ? ",
                    "    and datkvcleqp.soceqpcod = datreqpvcl.soceqpcod "

  prepare pcts00m03002    from l_sql
  declare ccts00m03002  cursor for pcts00m03002

  let l_sql = " select ufdcod, cidnom,",
                    "        brrnom, endzon,",
                    "        lclltt, lcllgt,",
                    "        socvcllcltip   ",
                    "   from datmfrtpos",
                    "  where datmfrtpos.socvclcod = ? "

  prepare pcts00m03003    from l_sql
  declare ccts00m03003  cursor for pcts00m03003

  let l_sql = "select pstcoddig, vigfnl",
                    "  from datrsrrpst ",
                    " where srrcoddig = ? ",
                    " order by vigfnl desc"

  prepare pcts00m03004   from  l_sql
  declare ccts00m03004   cursor for pcts00m03004

  let l_sql = "select srrabvnom",
                    "  from datksrr ",
                    " where srrcoddig = ? "

  prepare pcts00m03005 from  l_sql
  declare ccts00m03005 cursor for pcts00m03005

  let l_sql = " select asitipabvdes ",
                    "   from datrsrrasi, outer datkasitip",
                    "  where datrsrrasi.srrcoddig = ? ",
                    "    and datkasitip.asitipcod = datrsrrasi.asitipcod "

  prepare pcts00m03006    from l_sql
  declare ccts00m03006  cursor for pcts00m03006

  let l_sql = " select asitipcod  ",
                   "   from datrsrrasi ",
                   "  where datrsrrasi.srrcoddig = ? ",
                   "    and datrsrrasi.asitipcod = ? "

  prepare pcts00m03007    from l_sql
  declare ccts00m03007  cursor for pcts00m03007

  let l_sql = " select asitipcod  ",
                   "   from datrvclasi ",
                   "  where datrvclasi.socvclcod = ? ",
                   "    and datrvclasi.asitipcod = ? "

  prepare pcts00m03008    from l_sql
  declare ccts00m03008  cursor for pcts00m03008

  let l_sql = " select socntzcod, ",
                     " espcod ",
                " from dbsrntzpstesp ",
               " where srrcoddig = ? "

  prepare pcts00m03009 from l_sql
  declare ccts00m03009 cursor for pcts00m03009

  let l_sql = " select socntzdes ",
                " from datksocntz ",
               " where socntzcod = ? ",
               "   and socntzstt = 'A' "

  prepare pcts00m03010 from l_sql
  declare ccts00m03010 cursor for pcts00m03010

  let l_sql = " select socntzdes ",
                " from datksocntz ",
               " where socntzcod = ? "

  prepare pcts00m03011 from l_sql
  declare ccts00m03011 cursor for pcts00m03011

  let l_sql = " select atdsrvorg, asitipcod  ",    #PSI198714
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pcts00m03012 from l_sql
  declare ccts00m03012 cursor for pcts00m03012

  #PSI198714
  let l_sql = " select socntzcod , espcod "
             ," from datmsrvre            "
             ," where atdsrvnum =  ?      "
             ,"   and atdsrvano = ?       "
  prepare pcts00m03016 from l_sql
  declare ccts00m03016 cursor for pcts00m03016

  let l_sql = " select celdddcod, ",
                     " celtelnum ",
                " from datksrr ",
               " where srrcoddig = ? "

  prepare pcts00m03018 from l_sql
  declare ccts00m03018 cursor for pcts00m03018

  let l_sql = " select celdddcod, ",
                     " celtelnum, ",
                     " mdtcod     ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare pcts00m03019 from l_sql
  declare ccts00m03019 cursor for pcts00m03019

  let l_sql = " select d.asitipdes ",
              "   from datrsrrasi a, ",
              "        dattfrotalocal b, ",
              "        datkveiculo c, ",
              "        datkasitip d, ",
              "        datrvclasi e ",
              "  where a.srrcoddig  = ? ",
              "    and c.socvclcod  = ? ",
              "    and a.srrcoddig  = b.srrcoddig ",
              "    and b.socvclcod  = c.socvclcod ",
              "    and c.socvclcod  = e.socvclcod ",
              "    and a.asitipcod  = d.asitipcod ",
              "    and a.asitipcod  = e.asitipcod ",
              #"    and b.c24atvcod <> 'QTP' ",
              "    and d.asitipstt  = 'A' "
  prepare pcts00m03021  from l_sql
  declare ccts00m03021  cursor for pcts00m03021

  let l_sql = " select nxtnum, nxtide ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare pcts00m03022 from l_sql
  declare ccts00m03022 cursor for pcts00m03022

  let l_sql = " select nxtnum, nxtide ",
                " from datksrr ",
               " where srrcoddig = ? "

  prepare pcts00m03023 from l_sql
  declare ccts00m03023 cursor for pcts00m03023
  let l_sql = " select cpodes from iddkdominio ",
               " where cponom = ? ",
                 " and cpocod = ? "
  prepare pcts00m03024 from l_sql
  declare ccts00m03024 cursor for pcts00m03024

  let l_sql = " select caddat, ",
                     " cadhor, ",
                     " mdtmvtdigcnt ",
                " from datmmdtmvt mvt ",
               " where mdtmvtseq = ( select max(mdtmvtseq) ",
                                     " from datmmdtmvt ultseq ",
                                    " where ultseq.mdtcod       = ? ",
                                      " and ultseq.mdtmvttipcod = 2 ",
                                      " and ultseq.mdtbotprgseq = ? ",
                                      " and ultseq.mdtmvtstt    = 2 ",
                                      " and ultseq.caddat >= today - 1 units day)"
  prepare pcts00m03025 from l_sql
  declare ccts00m03025 cursor for pcts00m03025

  #--> preparar pesquisa tabela de dominio: cponom e cpodes
  let l_sql = " select cpocod "
               ," from datkdominio "
              ," where cponom = ? "
                ," and cpodes = ? "
  prepare pcts00m03026 from l_sql
  declare ccts00m03026 cursor for pcts00m03026

  #--> preparar pesquisa tabela de dominio: listar codigos de dominios
  let l_sql = " select cpocod "
                  ,"  ,cpodes "
               ," from datkdominio "
              ," where cponom = ? "
  prepare pcts00m03027 from l_sql
  declare ccts00m03027 cursor for pcts00m03027

  let l_sql = " select cpodes from datkdominio ",
               " where cponom = ? ",
                 " and cpocod = ? "
  prepare pcts00m03028 from l_sql
  declare ccts00m03028 cursor for pcts00m03028
  	
  let l_sql = "select dpaksocor.frtrpnflg ",
               " from datkveiculo, dpaksocor ",
              " where datkveiculo.pstcoddig = dpaksocor.pstcoddig ",
                " and datkveiculo.socvclcod = ? "
  prepare pcts00m03029 from l_sql
  declare ccts00m03029 cursor for pcts00m03029
  	

  let m_cts00m03_prep = true
end function
#----------------------------------------#
function cts00m03_cel_veiculo(l_socvclcod)
#----------------------------------------#

  #---------------------------------------------------
  # FUNCAO RESPONSAVEL POR BUSCAR O CELULAR DO VEICULO
  #---------------------------------------------------

  define l_socvclcod like datkveiculo.socvclcod,
         l_celdddcod like datkveiculo.celdddcod,
         l_celtelnum like datkveiculo.celtelnum,
         l_mdtcod    like datkveiculo.mdtcod

  if m_cts00m03_prep is null or
     m_cts00m03_prep <> true then
     call cts00m03_prepare()
  end if

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------
  let l_celdddcod = null
  let l_celtelnum = null
  let l_mdtcod    = null

  open ccts00m03019 using l_socvclcod
  whenever error continue
  fetch ccts00m03019 into l_celdddcod, l_celtelnum, l_mdtcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_celdddcod = null
        let l_celtelnum = null
     else
        error "Erro SELECT ccts00m03019 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
        error "cts00m03_cel_veiculo() / ", l_socvclcod sleep 4
     end if
  end if

  close ccts00m03019

  return l_celdddcod, l_celtelnum, l_mdtcod

end function

#---------------------------------------#
function cts00m03_cel_socorr(l_srrcoddig)
#---------------------------------------#

  #------------------------------------------------------
  # FUNCAO RESPONSAVEL POR BUSCAR O CELULAR DO SOCORRISTA
  #------------------------------------------------------

  define l_srrcoddig like datksrr.srrcoddig,
         l_celdddcod like datksrr.celdddcod,
         l_celtelnum like datksrr.celtelnum

  if m_cts00m03_prep is null or
     m_cts00m03_prep <> true then
     call cts00m03_prepare()
  end if

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------
  let l_celdddcod = null
  let l_celtelnum = null

  open ccts00m03018 using l_srrcoddig
  whenever error continue
  fetch ccts00m03018 into l_celdddcod, l_celtelnum
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_celdddcod = null
        let l_celtelnum = null
     else
        error "Erro SELECT ccts00m03018 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
        error "cts00m03_cel_socorr() / ", l_srrcoddig sleep 4
     end if
  end if

  close ccts00m03018

  return l_celdddcod, l_celtelnum

end function

#----------------------------------------#
function cts00m03_id_nextel(l_socvclcod, l_srrcoddig)
#----------------------------------------#

  #---------------------------------------------------
  # FUNCAO RESPONSAVEL POR BUSCAR O ID NEXTEL
  #---------------------------------------------------

  define l_socvclcod like datkveiculo.socvclcod,
         l_srrcoddig like datksrr.srrcoddig,
         l_nxtnum    like datkveiculo.nxtnum,
         l_nxtide    like datkveiculo.nxtide

  if m_cts00m03_prep is null or
     m_cts00m03_prep <> true then
     call cts00m03_prepare()
  end if

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------
  let l_nxtnum = null
  let l_nxtide = null

  #BUSCA O ID NEXTEL DO VEÍCULO
  open ccts00m03022 using l_socvclcod
  whenever error continue
  fetch ccts00m03022 into l_nxtnum, l_nxtide
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_nxtnum = null
        let l_nxtide = null
     else
        error "Erro SELECT ccts00m03022 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
        error "cts00m03_id_nextel() / ", l_socvclcod sleep 4
     end if
  end if
  close ccts00m03022

  if l_nxtide is null then

      #SE NÃO EXISTIR ID NEXTEL NA TABELA DO VEÍCULO, BUSCA O ID NEXTEL NA TABELA DO SOCORRISTA
      open ccts00m03023 using l_srrcoddig
      whenever error continue
      fetch ccts00m03023 into l_nxtnum, l_nxtide
      whenever error stop
      if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
              let l_nxtnum = null
              let l_nxtide = null
          else
              error "Erro SELECT ccts00m0323 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
              error "cts00m03_id_nextel() / ", l_srrcoddig sleep 4
          end if
      end if
      close ccts00m03023

  end if

  return l_nxtnum, l_nxtide

end function

#---------------------------------------------#
function cts00m03_exibe_natz_atend(l_pstcoddig,l_socvclcod)
#---------------------------------------------#

  define l_pstcoddig  like dbsrntzpstesp.srrcoddig
  define l_socvclcod  like datkveiculo.socvclcod

  define al_naturezas array[100] of record
         socntzdes    like datksocntz.socntzdes,
         traco        char(01),
         espdes       like dbskesp.espdes
  end record

  define l_socntzcod  like dbsrntzpstesp.socntzcod,
         l_espcod     like dbsrntzpstesp.espcod,
         l_contador   smallint


        define  w_pf1   integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_socntzcod  =  null
        let     l_espcod  =  null
        let     l_contador  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  100
                initialize  al_naturezas[w_pf1].*  to  null
        end     for

  if m_cts00m03_prep is null or
     m_cts00m03_prep <> true then
     call cts00m03_prepare()
  end if

  let l_socntzcod = null
  let l_espcod    = null
  let l_contador  = 1

  initialize al_naturezas to null

  open ccts00m03009 using l_pstcoddig

  foreach ccts00m03009 into l_socntzcod, l_espcod

     open ccts00m03011 using l_socntzcod

     whenever error continue
     fetch ccts00m03011 into al_naturezas[l_contador].socntzdes
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           error "Erro SELECT ccts00m03011 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "CTS00M03/cts00m03_exibe_natz_atend() ", l_socntzcod sleep 3
           exit foreach
        end if
     end if

     close ccts00m03011

     let al_naturezas[l_contador].traco = "-"

     # --BUSCA A DESCRICAO DA ESPECIALIDADE
     let al_naturezas[l_contador].espdes = cts31g00_descricao_esp(l_espcod, "")

     let l_contador = l_contador + 1

     if l_contador > 100 then
        error "A quantidade de registros superou o limite do array. AVISE A INFORMATICA !" sleep 2
        exit foreach
     end if

  end foreach

  close ccts00m03009

  ##Busca as assistencias do socorrista
  #PSI 224782
  open ccts00m03021 using l_pstcoddig, l_socvclcod

  foreach ccts00m03021  into   al_naturezas[l_contador].socntzdes
          let l_contador = l_contador + 1
  end foreach

  close ccts00m03006

  let l_contador = l_contador - 1
  if l_contador = 0 then
     error "Nenhum registro encontrado !" sleep 2
  else

     open window w_cts01m03 at 10,4 with form "cts01m03"
        attribute(border, form line 1)

     call set_count(l_contador)

     display array al_naturezas to s_cts01m03.*

        on key(f17, control-c, interrupt)
           initialize al_naturezas to null
           exit display

     end display

     close window w_cts01m03

     let int_flag = false

  end if

end function

#----------------------------------------------#
function cts00m03_busca_natureza(l_pstcoddig)
#----------------------------------------------#

  define l_pstcoddig  like dbsrntzpstesp.srrcoddig,
         l_socntzdes  like datksocntz.socntzdes,
         l_socntzcod  like datksocntz.socntzcod,
         l_espcod     like dbsrntzpstesp.espcod,
         l_desc_final char(50)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_socntzdes  =  null
        let     l_socntzcod  =  null
        let     l_espcod  =  null
        let     l_desc_final  =  null

  if m_cts00m03_prep is null or
     m_cts00m03_prep <> true then
     call cts00m03_prepare()
  end if

  let l_socntzdes  = null
  let l_socntzcod  = null
  let l_desc_final = null
  let l_espcod     = null

  # --BUSCA OS CODIGOS DA NATUREZA DE DETERMINADO PRESTADOR
  open ccts00m03009 using l_pstcoddig

  foreach ccts00m03009 into l_socntzcod, l_espcod

     # --BUSCA A DESCRICAO DA NATUREZA
     open ccts00m03010 using l_socntzcod
     whenever error continue
     fetch ccts00m03010 into l_socntzdes
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           error "Erro SELECT ccts00m03010 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "CTS00M03/cts00m03_busca_natureza() ", l_socntzcod sleep 3
           let l_desc_final = null
           exit foreach
        end if
     end if

     let l_desc_final = l_desc_final clipped, l_socntzdes[1,6] clipped, "/"

     close ccts00m03010

  end foreach

  close ccts00m03009

  # --RETORNA UMA LINHA COM AS NATUREZAS DO PRESTADOR
  return l_desc_final

end function

#----------------------------------------------#
function cts00m03_busca_assistencia(l_pstcoddig, l_socvclcod)
#----------------------------------------------#

  define l_pstcoddig    like dbsrntzpstesp.srrcoddig,
         l_socvclcod   like datkveiculo.socvclcod,
         l_asitipabvdes like datkasitip.asitipabvdes,
         l_cont         smallint,
         l_desc_final char(100)

        #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
        let l_asitipabvdes = null
        let l_desc_final   = null

  if m_cts00m03_prep is null or
     m_cts00m03_prep <> true then
     call cts00m03_prepare()
  end if

  # --BUSCA OS CODIGOS DA ASSISTENCIA DE DETERMINADO PRESTADOR
  open ccts00m03021 using l_pstcoddig, l_socvclcod

      whenever error continue
      foreach ccts00m03021 into l_asitipabvdes
      whenever error stop

          if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode <> notfound then
               error "Erro SELECT ccts00m03020 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
               error "CTS00M03/cts00m03_busca_assistencia() ", l_asitipabvdes sleep 3
               let l_desc_final = null
               exit foreach
            end if
          end if

          if l_desc_final is not null or l_desc_final <> " " then
            let l_desc_final = l_desc_final clipped, "/", l_asitipabvdes clipped
          else
            let l_desc_final = l_desc_final clipped, l_asitipabvdes clipped
          end if

      end foreach

  close ccts00m03021

  # --RETORNA UMA LINHA COM AS NATUREZAS DO PRESTADOR
  return l_desc_final

end function

#---------------------------------------------------------------------
 function cts00m03(param)
#---------------------------------------------------------------------

 define param        record
    operacao         smallint,      #--> (1)Display array, (2)Input array
    vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod,
    c24atvcod        like dattfrotalocal.c24atvcod,
    pstcoddig        like datkveiculo.pstcoddig,
    atdvclsgl        like datkveiculo.atdvclsgl,
    srrcoddig        like dattfrotalocal.srrcoddig,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define d_cts00m03   record
    vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod,
    vcldtbgrpdes     like datkvcldtbgrp.vcldtbgrpdes,
    c24atvpsq        like dattfrotalocal.c24atvcod,
    asitipcod        like datmservico.asitipcod,
    asitipabvdes     like datkasitip.asitipabvdes,
    endzonpsq        like datmfrtpos.endzon,
    atdvclpsq        like datkveiculo.atdvclsgl,
    soceqpcodpsq     like datkvcleqp.soceqpcod,
    soceqpabvpsq     like datkvcleqp.soceqpabv,
    pstcodpsq        like datkveiculo.pstcoddig,
    nomgrrpsq        like dpaksocor.nomgrr,
    ciaempcod        like gabkemp.empcod,
    empnom           like gabkemp.empnom,
    srvorgtipcod     smallint,                       # 09.12.11 PSI-2011-21009
    srvorgtip        char(15)
 end record

 define ws1          record
    atdvclpriflg     like dattfrotalocal.atdvclpriflg,
    socoprsitcod     like datkveiculo.socoprsitcod,
    socctrposflg     like datkveiculo.socctrposflg,
    vcldtbgrpstt     like datkvcldtbgrp.vcldtbgrpstt,
    horaatu          datetime hour to minute,
    pstcoddig        like datkveiculo.pstcoddig,
    atdvclsgl        like datkveiculo.atdvclsgl,
    socvclcod        like datkveiculo.socvclcod,
    srrcoddig        like dattfrotalocal.srrcoddig,
    comando          char (700),
    asitipstt        like datkasitip.asitipstt,
    flag_cts00m02    dec(01,0),
    c24opemat        like datkveiculo.c24opemat,
    c24opeempcod     like datkveiculo.c24opeempcod,
    c24opeusrtip     like datkveiculo.c24opeusrtip,
    socacsflg        like datkveiculo.socacsflg,
    funnom           like isskfunc.funnom,
    srvorgtipcod     smallint                        # 20.01.12 SM-2012-00756
 end record

 define l_tmp_flg    smallint,
        l_resultado  smallint,
        l_mensagem   char(40),
        l_opratvflg  char(01),
        l_lixonum    smallint,
        l_caddat     date


 #------------------------------------------------------------------
 # Verifica parametros do servico informados
 #------------------------------------------------------------------
#if param.atdsrvnum  is not null   and
#   param.atdsrvano  is not null   then
#   select asitipcod
#     into d_cts00m03.asitipcod
#     from datmservico
#    where atdsrvnum  =  param.atdsrvnum
#      and atdsrvano  =  param.atdsrvano
#else
#   initialize d_cts00m03.asitipcod to null
#end if


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_tmp_flg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_cts00m03.*  to  null

        initialize  ws1.*  to  null

 let l_opratvflg = null
 let l_lixonum   = null

 if m_cts00m03_prep is null or
    m_cts00m03_prep <> true then
    call cts00m03_prepare()
 end if

 initialize  d_cts00m03.*  to  null

 initialize  ws1.*  to  null

 #------------------------------------------------------------------
 # Inibir teclas F1(incluir), F2(Excluir)
 #------------------------------------------------------------------
 whenever error continue

    open window w_cts00m03 at 02,02 with form "cts00m03"
         attribute(form line first, comment line last-1)

    if status  =  -1143    then   #--> Window ja' aberta
       error " Funcao nao disponivel. Voce ja' esta consultando a posicao da frota!"
       whenever error stop
       return  param.pstcoddig,
               param.atdvclsgl,
               param.srrcoddig,
               "",0
    end if

 whenever error stop

 display " " to s_cts00m03[01].tipposcab
 display " " to s_cts00m03[02].tipposcab

 options
    insert key F35,
    delete key F36

 while true

    initialize d_cts00m03.c24atvpsq     to null
    initialize d_cts00m03.endzonpsq     to null
    initialize d_cts00m03.atdvclpsq     to null
    initialize d_cts00m03.soceqpcodpsq  to null
    initialize d_cts00m03.soceqpabvpsq  to null
    initialize d_cts00m03.pstcodpsq     to null
    initialize d_cts00m03.nomgrrpsq     to null

    initialize ws1.*  to null
    call cts40g03_data_hora_banco(2) returning l_caddat, ws1.horaatu
    display ws1.horaatu  to horaatu
    display "  "         to nomgrrpsq
    display by name d_cts00m03.soceqpabvpsq

    call ctc61m02(param.atdsrvnum,param.atdsrvano,"A")

    let l_tmp_flg = ctc61m02_criatmp(2,
                                     param.atdsrvnum,
                                     param.atdsrvano)

    if l_tmp_flg = 1 then
       error "Problemas com temporaria ! <Avise a Informatica>."
    end if

    if param.atdsrvnum is not null then
       call cts10g06_dados_servicos(10, param.atdsrvnum,
                                        param.atdsrvano)
            returning l_resultado, l_mensagem, d_cts00m03.ciaempcod

       call cty14g00_empresa(1, d_cts00m03.ciaempcod)
            returning l_resultado, l_mensagem,  d_cts00m03.empnom

       display by name d_cts00m03.ciaempcod attribute (reverse)
       display by name d_cts00m03.empnom attribute (reverse)

    end if

    let d_cts00m03.srvorgtipcod = 01           # Todos  30.12.11 PSI-2011-21009

    call cts00m03_obterCpodes("srvorgtipcod", d_cts00m03.srvorgtipcod)
         returning d_cts00m03.srvorgtip
    display by name d_cts00m03.srvorgtip

    input by name d_cts00m03.vcldtbgrpcod,
                  d_cts00m03.c24atvpsq,
 ###              d_cts00m03.asitipcod,
                  d_cts00m03.endzonpsq,
                  d_cts00m03.atdvclpsq,
                  d_cts00m03.soceqpcodpsq,
                  d_cts00m03.pstcodpsq,
                  d_cts00m03.ciaempcod,
                  d_cts00m03.srvorgtipcod without defaults   # PSI-2011-21009

       before field vcldtbgrpcod
              display by name d_cts00m03.vcldtbgrpcod  attribute (reverse)

              #-----------------------------------------------------------
              # Carrega grupo conforme parametro
              #-----------------------------------------------------------
              display ""  to  cabec1
              display ""  to  cabec2
              let d_cts00m03.c24atvpsq    = param.c24atvcod
              let d_cts00m03.vcldtbgrpcod = param.vcldtbgrpcod
              let d_cts00m03.atdvclpsq    = param.atdvclsgl
              let d_cts00m03.pstcodpsq    = param.pstcoddig

              if d_cts00m03.vcldtbgrpcod = 00  then         # 09.12.11
                 let d_cts00m03.vcldtbgrpdes = "Todos"      # PSI-2011-21009
              else
                 select vcldtbgrpdes
                   into d_cts00m03.vcldtbgrpdes
                   from datkvcldtbgrp
                  where datkvcldtbgrp.vcldtbgrpcod = d_cts00m03.vcldtbgrpcod
              end if

              display by name d_cts00m03.c24atvpsq
              display by name d_cts00m03.vcldtbgrpcod
              display by name d_cts00m03.vcldtbgrpdes
              display by name d_cts00m03.asitipcod
              display by name d_cts00m03.asitipabvdes
              display by name d_cts00m03.atdvclpsq
              display by name d_cts00m03.pstcodpsq

       after  field vcldtbgrpcod
              display by name d_cts00m03.vcldtbgrpcod

              if d_cts00m03.vcldtbgrpcod  is null   then
                 error " Grupo de distribuicao deve ser informado!"
                 call ctn39c00_putOnOffTodos( 1 )
                 call ctn39c00()  returning d_cts00m03.vcldtbgrpcod
                 call ctn39c00_putOnOffTodos( 0 )
                 if d_cts00m03.vcldtbgrpcod is not null then
                    let param.vcldtbgrpcod = d_cts00m03.vcldtbgrpcod
                 end if
                 next field vcldtbgrpcod
              end if

              if d_cts00m03.vcldtbgrpcod = 00  then         # 09.12.11
                 let d_cts00m03.vcldtbgrpdes = "Todos"      # PSI-2011-21009
              else
                 select vcldtbgrpstt,
                        vcldtbgrpdes
                   into ws1.vcldtbgrpstt,
                        d_cts00m03.vcldtbgrpdes
                   from datkvcldtbgrp
                  where datkvcldtbgrp.vcldtbgrpcod = d_cts00m03.vcldtbgrpcod

                 if ws1.vcldtbgrpstt  <>  "A"   then
                    error " Grupo de distribuicao cancelado!"
                    next field vcldtbgrpcod
                 end if

                 if sqlca.sqlcode  <>  0   then
                    error " Grupo de distribuicao nao cadastrado!"
                    call ctn39c00_putOnOffTodos( 1 )
                    call ctn39c00()  returning d_cts00m03.vcldtbgrpcod
                    call ctn39c00_putOnOffTodos( 0 )
                    if d_cts00m03.vcldtbgrpcod is not null then
                       let param.vcldtbgrpcod = d_cts00m03.vcldtbgrpcod
                    end if
                    next field vcldtbgrpcod
                 end if
              end if
              display by name d_cts00m03.vcldtbgrpdes

              call cts00m03_contadores(d_cts00m03.vcldtbgrpcod)

       before field c24atvpsq
              display by name d_cts00m03.c24atvpsq attribute (reverse)

       after  field c24atvpsq
              display by name d_cts00m03.c24atvpsq
              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 initialize d_cts00m03.c24atvpsq  to null
                 display by name d_cts00m03.c24atvpsq
                 if d_cts00m03.vcldtbgrpcod is not null then
                    let param.vcldtbgrpcod = d_cts00m03.vcldtbgrpcod
                 end if
                 next field vcldtbgrpcod
              end if

             if d_cts00m03.c24atvpsq  is not null   then
                if d_cts00m03.c24atvpsq  <> "QTP"   and
                   d_cts00m03.c24atvpsq  <> "QRX"   and
                   d_cts00m03.c24atvpsq  <> "QRV"   and
                   d_cts00m03.c24atvpsq  <> "QRA"   and
                   d_cts00m03.c24atvpsq  <> "QRU"   and
                   d_cts00m03.c24atvpsq  <> "REC"   and
                   d_cts00m03.c24atvpsq  <> "INI"   and
                   d_cts00m03.c24atvpsq  <> "REM"   and
                   d_cts00m03.c24atvpsq  <> "FIM"   and
                   d_cts00m03.c24atvpsq  <> "NIL"   and
                   d_cts00m03.c24atvpsq  <> "RET"   and
                   d_cts00m03.c24atvpsq  <> "ROD"   then
                   error " Codigo da atividade invalido!"
                   next field c24atvpsq
                end if
             else
                if d_cts00m03.vcldtbgrpcod = 00  then         # 09.12.11
                   error " Codigo da atividade obrigatorio!"
                   next field c24atvpsq
                end if
             end if

             #-> Indicar flag Atividade faz parte operacao  09.12.11
             if d_cts00m03.c24atvpsq is null then
                let l_opratvflg = " "
             else
                call cts00m03_obterAtivIsOperac( d_cts00m03.c24atvpsq )
                     returning l_opratvflg
             end if

#      before field asitipcod
#            display by name d_cts00m03.asitipcod  attribute (reverse)
#            display by name d_cts00m03.asitipabvdes
#
#      after  field asitipcod
#            display by name d_cts00m03.asitipcod
#
#            if fgl_lastkey() = fgl_keyval("up")   or
#               fgl_lastkey() = fgl_keyval("left") then
#               next field c24atvpsq
#            end if
#
#            if d_cts00m03.asitipcod  is null    then
#               let d_cts00m03.asitipabvdes  =  "TODOS"
#            else
#               select asitipabvdes, asitipstt
#                 into d_cts00m03.asitipabvdes,
#                      ws1.asitipstt
#                 from datkasitip
#                where datkasitip.asitipcod = d_cts00m03.asitipcod
#
#               if sqlca.sqlcode  <>  0   then
#                  error " Tipo de assistencia nao cadastrada!"
#                  call ctn25c00("")  returning d_cts00m03.asitipcod
#                  next field asitipcod
#               else
#                  if ws1.asitipstt <> "A" then
#                     error " Tipo de assistencia nao esta ativa!"
#                     call ctn25c00("")  returning d_cts00m03.asitipcod
#                     next field asitipcod
#                  end if
#               end if
#            end if
#
#            display by name d_cts00m03.asitipabvdes

       before field endzonpsq
              display by name d_cts00m03.endzonpsq   attribute (reverse)

       after  field endzonpsq
              display by name d_cts00m03.endzonpsq
              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 initialize d_cts00m03.endzonpsq  to null
                 display by name d_cts00m03.endzonpsq
#                next field asitipcod
                 next field c24atvpsq
              end if

             if d_cts00m03.endzonpsq  is not null   then
                 if d_cts00m03.endzonpsq  <>  "CE"    and
                    d_cts00m03.endzonpsq  <>  "NO"    and
                    d_cts00m03.endzonpsq  <>  "SU"    and
                    d_cts00m03.endzonpsq  <>  "LE"    and
                    d_cts00m03.endzonpsq  <>  "OE"    then
                    error " Codigo da zona invalido!"
                    next field endzonpsq
                 end if
              end if

       before field atdvclpsq
              display by name d_cts00m03.atdvclpsq attribute (reverse)

        after  field atdvclpsq
             display by name d_cts00m03.atdvclpsq

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 initialize d_cts00m03.atdvclpsq  to null
                 display by name d_cts00m03.atdvclpsq

                 next field endzonpsq
              end if

              if d_cts00m03.atdvclpsq  is not null   then

                 initialize d_cts00m03.c24atvpsq  to null
                 initialize d_cts00m03.endzonpsq  to null
                 display by name d_cts00m03.c24atvpsq
                 display by name d_cts00m03.endzonpsq

                 select socoprsitcod,
                        socctrposflg,
                        socacsflg,
                        c24opemat,
                        c24opeempcod,
                        c24opeusrtip
                   into ws1.socoprsitcod,
                        ws1.socctrposflg,
                        ws1.socacsflg,
                        ws1.c24opemat,
                        ws1.c24opeempcod,
                        ws1.c24opeusrtip
                   from datkveiculo
                  where datkveiculo.atdvclsgl = d_cts00m03.atdvclpsq

                 if sqlca.sqlcode  <>  0   then
                    error " Veiculo nao cadastrado!"
                    next field atdvclpsq
                 else
                    if ws1.socacsflg  =  "1" then
                       select funnom into ws1.funnom
                           from isskfunc
                          where funmat = ws1.c24opemat
                            and empcod = ws1.c24opeempcod
                            and usrtip = ws1.c24opeusrtip
                       if sqlca.sqlcode = 0 then
                          error "Veiculo sendo acionado por ",ws1.funnom clipped
                          next field atdvclpsq
                       end if
                    end if
                 end if

                 if ws1.socctrposflg  =  "N"   then
                    error " Veiculo nao possui posicao controlada pelo radio!"
                    next field atdvclpsq
                 end if

                 if ws1.socoprsitcod  <>  1   then
                    error " Veiculo esta bloqueado ou cancelado!"
                    call ctn40c00(d_cts00m03.atdvclpsq)
                    next field atdvclpsq
                 end if

              end if

              if d_cts00m03.atdvclpsq     is not null   then
                 let d_cts00m03.srvorgtipcod = 01            # PSI-2011-21009
                 call cts00m03_obterCpodes("srvorgtipcod"
                                          , d_cts00m03.srvorgtipcod)
                      returning d_cts00m03.srvorgtip
                 display by name d_cts00m03.srvorgtipcod
                 display by name d_cts00m03.srvorgtip
                 exit input
              end if

       before field soceqpcodpsq
              display by name d_cts00m03.soceqpcodpsq attribute (reverse)

       after  field soceqpcodpsq
              display by name d_cts00m03.soceqpcodpsq

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                  initialize d_cts00m03.soceqpcodpsq  to null
                  initialize d_cts00m03.soceqpabvpsq  to null
                  display by name d_cts00m03.soceqpcodpsq
                  display by name d_cts00m03.soceqpabvpsq

                  next field atdvclpsq
              end if

              if d_cts00m03.soceqpcodpsq  is not null   then
                 select soceqpabv
                   into d_cts00m03.soceqpabvpsq
                   from datkvcleqp
                  where datkvcleqp.soceqpcod  =  d_cts00m03.soceqpcodpsq

                 if sqlca.sqlcode  <>  0    then
                    error " Codigo equipamento nao cadastrado!"
                    call ctn37c00()  returning d_cts00m03.soceqpcodpsq
                    next field soceqpcodpsq
                 end if
              else
                 initialize d_cts00m03.soceqpabvpsq  to null
              end if
              display by name d_cts00m03.soceqpabvpsq

       before field pstcodpsq
              display by name d_cts00m03.pstcodpsq attribute (reverse)

       after  field pstcodpsq
              display by name d_cts00m03.pstcodpsq

              if fgl_lastkey() = fgl_keyval("up")   or
                 fgl_lastkey() = fgl_keyval("left") then
                 initialize d_cts00m03.pstcodpsq  to null
                 initialize d_cts00m03.nomgrrpsq  to null
                 display by name d_cts00m03.pstcodpsq
                 display by name d_cts00m03.nomgrrpsq

                 next field soceqpcodpsq
              end if

              if d_cts00m03.pstcodpsq  is not null   then

                 initialize d_cts00m03.c24atvpsq     to null
                 initialize d_cts00m03.endzonpsq     to null
                 initialize d_cts00m03.soceqpcodpsq  to null
                 initialize d_cts00m03.soceqpabvpsq  to null
                 display by name d_cts00m03.c24atvpsq
                 display by name d_cts00m03.endzonpsq
                 display by name d_cts00m03.soceqpcodpsq
                 display by name d_cts00m03.soceqpabvpsq

                 select dpaksocor.nomgrr
                   into d_cts00m03.nomgrrpsq
                   from dpaksocor
                  where dpaksocor.pstcoddig = d_cts00m03.pstcodpsq

                 if sqlca.sqlcode  <>  0   then
                    error " Prestador nao cadastrado!"
                    call ctn23c00()  returning d_cts00m03.pstcodpsq
                    next field pstcodpsq
                 end if
                 display by name d_cts00m03.nomgrrpsq

                 declare c_cts00m03_001  cursor for
                    select socvclcod
                      from datkveiculo
                     where datkveiculo.pstcoddig     =  d_cts00m03.pstcodpsq
                       and datkveiculo.socoprsitcod  =  1
                       and datkveiculo.socctrposflg  = "S"

                 open  c_cts00m03_001
                 fetch c_cts00m03_001

                 if sqlca.sqlcode <> 0   then
                    error " Prestador nao possui veiculo ATIVO e/ou CONTROLADO PELO RADIO!"
                    call ctn23c00()  returning  d_cts00m03.pstcodpsq
                    next field pstcodpsq
                 end if
              else

                 initialize d_cts00m03.nomgrrpsq  to null
                 display by name d_cts00m03.nomgrrpsq
              end if

     before field ciaempcod
            if param.atdsrvnum is not null then
               call cts10g06_dados_servicos(10, param.atdsrvnum,
                                                param.atdsrvano)
                    returning l_resultado, l_mensagem, d_cts00m03.ciaempcod

               call cty14g00_empresa(1, d_cts00m03.ciaempcod)
                    returning l_resultado, l_mensagem,  d_cts00m03.empnom

               display by name d_cts00m03.ciaempcod attribute (reverse)
               display by name d_cts00m03.empnom attribute (reverse)

            end if

     after  field ciaempcod
            display by name d_cts00m03.ciaempcod attribute (reverse)

            if d_cts00m03.ciaempcod is null then
               call cty14g00_popup_empresa()
                    returning l_resultado, d_cts00m03.ciaempcod,
                              d_cts00m03.empnom
            else

               #if d_cts00m03.ciaempcod <> 1 and
               #   d_cts00m03.ciaempcod <> 35 and
               #   d_cts00m03.ciaempcod <> 40 then
               #   error "Informe a empresa: 1-Porto, 35-Azul ou 40-PortoSeg"
               #   next field ciaempcod
               #end if

               call cty14g00_empresa(1, d_cts00m03.ciaempcod)
                    returning l_resultado, l_mensagem,  d_cts00m03.empnom

               if l_resultado <> 1 then
                  error l_mensagem
                  next field ciaempcod
               end if
            end if

            display by name d_cts00m03.empnom attribute (reverse)

     before field srvorgtipcod            # 09.12.11 PSI-2011-21009
            if d_cts00m03.vcldtbgrpcod > 0 then # 09.12.11 com grupo, pesquisa
               let d_cts00m03.srvorgtipcod = 01
               call cts00m03_obterCpodes("srvorgtipcod",d_cts00m03.srvorgtipcod)
                    returning d_cts00m03.srvorgtip
               display by name d_cts00m03.srvorgtipcod
               display by name d_cts00m03.srvorgtip
               exit input
            end if
            if l_opratvflg <> "S" then     # 09.12.11 nao faz parte operacao
               let d_cts00m03.srvorgtipcod = 01
               call cts00m03_obterCpodes("srvorgtipcod",d_cts00m03.srvorgtipcod)
                    returning d_cts00m03.srvorgtip
               display by name d_cts00m03.srvorgtipcod
               display by name d_cts00m03.srvorgtip
               exit input
            end if
            display by name d_cts00m03.srvorgtipcod attribute (reverse)

     after  field srvorgtipcod            # 09.12.11 PSI-2011-21009
            display by name d_cts00m03.srvorgtipcod

            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
               let d_cts00m03.srvorgtipcod = 01
               call cts00m03_obterCpodes("srvorgtipcod",d_cts00m03.srvorgtipcod)
                    returning d_cts00m03.srvorgtip
               display by name d_cts00m03.srvorgtipcod
               display by name d_cts00m03.srvorgtip
               next field ciaempcod
            end if

            if d_cts00m03.srvorgtipcod is null or
               d_cts00m03.srvorgtip     < 1    then
               error " Tipo de servico invalido !"
               let d_cts00m03.srvorgtip = " "
               display by name d_cts00m03.srvorgtip
               call cts00m03_popupTipoServ()
                    returning d_cts00m03.srvorgtip, d_cts00m03.srvorgtipcod
               display by name d_cts00m03.srvorgtipcod
               display by name d_cts00m03.srvorgtip
               next field srvorgtipcod
            end if
            call cts00m03_obterCpodes("srvorgtipcod", d_cts00m03.srvorgtipcod)
                 returning d_cts00m03.srvorgtip
            if d_cts00m03.srvorgtip is null  then
               error " Tipo servico invalido!"
               next field srvorgtipcod
            end if
            display by name d_cts00m03.srvorgtipcod
            display by name d_cts00m03.srvorgtip
            let ws1.srvorgtipcod = d_cts00m03.srvorgtipcod

       on key (interrupt)
          exit input

    end input

    if int_flag   then
       exit while
    end if

   call cts00m03_posicao(param.operacao,
                         d_cts00m03.c24atvpsq,
                         d_cts00m03.endzonpsq,
                         d_cts00m03.atdvclpsq,
                         d_cts00m03.soceqpcodpsq,
                         d_cts00m03.pstcodpsq,
                         ws1.horaatu         ,
                         d_cts00m03.vcldtbgrpcod,
                         d_cts00m03.asitipcod,
                         param.atdsrvnum     ,
                         param.atdsrvano,
                         d_cts00m03.ciaempcod,
                         ws1.srvorgtipcod)     # 09.12.11 PSI-2011-21009
        returning ws1.pstcoddig,
                  ws1.atdvclsgl,
                  ws1.srrcoddig,
                  ws1.socvclcod,
                  ws1.flag_cts00m02

   if ws1.pstcoddig  is not null   and
      ws1.atdvclsgl  is not null   and
      ws1.srrcoddig  is not null   then
      exit while
   end if

   call cts00m03_contadores(d_cts00m03.vcldtbgrpcod)

 end while

 #------------------------------------------------------------------
 # Retorna teclas F1(incluir), F2(Excluir)
 #------------------------------------------------------------------
 options
    insert key F1,
    delete key F2

 let int_flag = false
 close window w_cts00m03

 if ws1.pstcoddig  is not null   then     #--> Veiculo foi selecionado
    return  ws1.pstcoddig,
            ws1.atdvclsgl,
            ws1.srrcoddig,
            ws1.socvclcod,
            ws1.flag_cts00m02
 else
    return  param.pstcoddig,
            param.atdvclsgl,
            param.srrcoddig,
            ws1.socvclcod,
            ws1.flag_cts00m02
 end if

end function    ###-- cts00m03


#---------------------------------------------------------------------
 function cts00m03_posicao(par2)   ## Atualiza posicao da frota
#---------------------------------------------------------------------

 define par2         record
    operacao         smallint,      #--> (1)Display array, (2)Input array
    c24atvpsq        like dattfrotalocal.c24atvcod,
    endzonpsq        like datmfrtpos.endzon,
    atdvclpsq        like datkveiculo.atdvclsgl,
    soceqpcodpsq     like datkvcleqp.soceqpcod,
    pstcodpsq        like dpaksocor.pstcoddig,
    horaatu          datetime hour to minute,
    vcldtbgrpcod     like dattfrotalocal.vcldtbgrpcod,
    asitipcod        like datkasitip.asitipcod,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    ciaempcod        like datmservico.ciaempcod,
    srvorgtipcod     smallint                        # 09.12.11 PSI-2011-21009
 end record

 define a_cts00m03   array[300] of record
    atdvclsgl        like datkveiculo.atdvclsgl,
    c24atvcod        like dattfrotalocal.c24atvcod,
    c24atvcmp        char(15),
    socvclcod        like dattfrotalocal.socvclcod,
    socvcltipdes     char (50),
    vcleqpdes        char (15),
    srrcoddig        like dattfrotalocal.srrcoddig,
    srrabvnom        like datksrr.srrabvnom,
    srrasides        char (50),
    tipposcab        char (08),
    ufdcod_gps       like datmfrtpos.ufdcod,
    cidnom_gps       like datmfrtpos.cidnom,
    brrnom_gps       like datmfrtpos.brrnom,
    endzon_gps       like datmfrtpos.endzon,
    ufdcod_qth       like datmfrtpos.ufdcod,
    cidnom_qth       like datmfrtpos.cidnom,
    brrnom_qth       like datmfrtpos.brrnom,
    endzon_qth       like datmfrtpos.endzon,
    ufdcod_qti       like datmfrtpos.ufdcod,
    cidnom_qti       like datmfrtpos.cidnom,
    brrnom_qti       like datmfrtpos.brrnom,
    endzon_qti       like datmfrtpos.endzon,
    obspostxt        like dattfrotalocal.obspostxt,
    celdddcod        like datkveiculo.celdddcod,
    celtelnum        like datkveiculo.celtelnum,
    celular          char (13),
    nxtnum           like datkveiculo.nxtnum,
    nxtide           like datkveiculo.nxtide,
    tempo            char (06),
    atdsrvorg        like datmservico.atdsrvorg,
    atdsrvnum        like dattfrotalocal.atdsrvnum,
    atdsrvano        like dattfrotalocal.atdsrvano,
    pstcoddig        like datkveiculo.pstcoddig
 end record

 define a_cts00m03b  array[300] of record
    lclltt_gps       like datmfrtpos.lclltt,
    lcllgt_gps       like datmfrtpos.lcllgt,
    lclltt_qth       like datmfrtpos.lclltt,
    lcllgt_qth       like datmfrtpos.lcllgt,
    lclltt_qti       like datmfrtpos.lclltt,
    lcllgt_qti       like datmfrtpos.lcllgt,
    asitipcod        like datmservico.asitipcod          #PSI198714
 end record

 define ws2          record
    null             char (01),
    data             char (10),
    socvclcod        like datkveiculo.socvclcod,
    atdvclsgl        like datkveiculo.atdvclsgl,
    celdddcod        like datksrr.celdddcod,
    celtelnum        like datksrr.celtelnum,
    nxtnum           like datkveiculo.nxtnum,
    nxtide           like datkveiculo.nxtide,
    srrstt           like datksrr.srrstt,
    srrcoddig        like dattfrotalocal.srrcoddig,
    c24atvcod        like dattfrotalocal.c24atvcod,
    atdvclpriflg     like dattfrotalocal.atdvclpriflg,
    obspostxt        like dattfrotalocal.obspostxt,
    ufdcod           like datmfrtpos.ufdcod,
    cidnom           like datmfrtpos.cidnom,
    brrnom           like datmfrtpos.brrnom,
    endzon           like datmfrtpos.endzon,
    lclltt           like datmfrtpos.lclltt,
    lcllgt           like datmfrtpos.lcllgt,
    atdsrvorg        like datmservico.atdsrvorg,
    ufdcod_gps       like datmfrtpos.ufdcod,
    cidnom_gps       like datmfrtpos.cidnom,
    brrnom_gps       like datmfrtpos.brrnom,
    endzon_gps       like datmfrtpos.endzon,
    ufdcod_qth       like datmfrtpos.ufdcod,
    cidnom_qth       like datmfrtpos.cidnom,
    brrnom_qth       like datmfrtpos.brrnom,
    endzon_qth       like datmfrtpos.endzon,
    ufdcod_qti       like datmfrtpos.ufdcod,
    cidnom_qti       like datmfrtpos.cidnom,
    brrnom_qti       like datmfrtpos.brrnom,
    endzon_qti       like datmfrtpos.endzon,
    socvcllcltip     like datmfrtpos.socvcllcltip,
    soceqpabv        like datkvcleqp.soceqpabv,
    asitipabvdes     like datkasitip.asitipabvdes,
    vclcoddig        like agbkveic.vclcoddig,
    vclmrcnom        like agbkmarca.vclmrcnom,
    vcltipnom        like agbktip.vcltipnom,
    vclmdlnom        like agbkveic.vclmdlnom,
    pstcoddig        like datrsrrpst.pstcoddig,
    comando1         char (1000),
    comando2         char (700),
    opcao            dec  (1,0),
    operacao         char (01),
    tempod           dec  (3,0),
    asitipcod        like datkasitip.asitipcod,
    socacsflg        like datkveiculo.socacsflg,
    flag_cts00m02    dec(01,0),
    f8flg            char(01),
    cponom           like iddkdominio.cponom,
    cpocod           like iddkdominio.cpocod,
    cpodes           like iddkdominio.cpodes,
    erro             integer,
    qrxmincor        interval minute(6) to minute,
    qrxmincortxt     char(20),
    qrxmincorval     smallint,
    qrxtmpprg        smallint,
    mdtcod           like datmmdtmvt.mdtcod,
    mdtbotprgseq     like datmmdtmvt.mdtbotprgseq,
    mvtcaddat        like datmmdtmvt.caddat,
    mvtcadhor        like datmmdtmvt.cadhor,
    mdtmvtdigcnt     like datmmdtmvt.mdtmvtdigcnt
 end record
 define ws1          record
    c24opemat        like datkveiculo.c24opemat,
    c24opeempcod     like datkveiculo.c24opeempcod,
    c24opeusrtip     like datkveiculo.c24opeusrtip,
    funnom           like isskfunc.funnom
 end record

 define prompt_key        char(01)
 define arr_aux           smallint
 define scr_aux           smallint
 define l_srvrcumtvcod    like datmsrvacp.srvrcumtvcod
       ,l_atdsrvorg       like datmservico.atdsrvorg
 define l_aux             smallint
 define l_resultado       smallint
       ,l_mensagem        char(60)
       ,l_msg1            char(40)
       ,l_msg2            char(40)

 define al_cts29g00 array[10] of record
    atdmltsrvnum like datratdmltsrv.atdmltsrvnum
   ,atdmltsrvano like datratdmltsrv.atdmltsrvano
   ,socntzdes    like datksocntz.socntzdes
   ,espdes       like dbskesp.espdes
   ,atddfttxt    like datmservico.atddfttxt
 end record

 define a_mdtcod array[300] of like datkveiculo.mdtcod

 define l_posicao smallint

 define l_tmp_flg     smallint
 define l_retorno     smallint

 define  w_pf1   integer,
         l_hora  datetime hour to minute

 #PSI198714
 define l_socntzcod   like datmsrvre.socntzcod,
        l_espcod      like datmsrvre.espcod,
        l_sql         char(600),
        l_confirma    char(1),
        l_c24atvcod_slv like dattfrotalocal.c24atvcod,
        l_mdtbotcod     like datkmdtbot.mdtbotcod,
        l_desc_ast  char(100),
        l_desc_ntz  char(100),    #PSI 224782
        l_socvcltip char(300),
        l_socvclcod like datkveiculo.socvclcod,
        l_vcldtbgrpcod like dattfrotalocal.vcldtbgrpcod,  # PSI-2011-21009
        l_refresh      smallint,
        l_newhoraatu   datetime hour to minute,
        l_caddat       date,
        l_cttdat    like dattfrotalocal.cttdat,
        l_ctthor    like dattfrotalocal.ctthor,
        l_atdsrvnum like datmservico.atdsrvnum,
        l_atdsrvano like datmservico.atdsrvano,
        l_frtrpnflg like dpaksocor.frtrpnflg

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     prompt_key      = null
        let     arr_aux         = null
        let     scr_aux         = null
        let     l_srvrcumtvcod  = null
        let     l_atdsrvorg     = null
        let     l_aux           = null
        let     l_resultado     = null
        let     l_mensagem      = null
        let     l_posicao       = null
        let     l_tmp_flg       = null
        let     w_pf1           = null
        let     l_hora          = null
        let     l_c24atvcod_slv = null
        let     l_msg1          = null
        let     l_msg2          = null
        let     l_mdtbotcod     = null
        let     l_cttdat        = null
        let     l_ctthor        = null
        let     l_atdsrvnum     = null
        let     l_atdsrvano     = null
        let     l_frtrpnflg     = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf1  =  1  to  300
                initialize  a_cts00m03[w_pf1].*  to  null
                initialize  a_mdtcod[w_pf1]  to  null
        end     for

        for     w_pf1  =  1  to  300
                initialize  a_cts00m03b[w_pf1].*  to  null
        end     for

        for     w_pf1  =  1  to  10
                initialize  al_cts29g00[w_pf1].*  to  null
        end     for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws2.*  to  null

        initialize  ws1.*  to  null

 let     prompt_key  =  null
 let     arr_aux  =  null
 let     scr_aux  =  null

 let l_aux       = null
 let l_resultado = null
 let l_mensagem  = null
 initialize al_cts29g00 to null


 initialize  ws2.*  to  null

 let l_posicao = null
 let l_vcldtbgrpcod = null
 let l_refresh      = null
 let l_newhoraatu   = null

 let l_newhoraatu = par2.horaatu

 while true

 initialize a_cts00m03   to null
 initialize a_cts00m03b  to null
 initialize ws2.*        to null
 let ws2.f8flg   =  "N"
 let arr_aux  =  1
 if par2.vcldtbgrpcod = 0  then                  # PSI-2011-21009
    let l_vcldtbgrpcod = null
 else
    let l_vcldtbgrpcod = par2.vcldtbgrpcod
 end if
 let l_refresh    = false                        # SM-2012-00756

 #------------------------------------------------------------------
 # Prepara pesquisa por sigla do veiculo
 #------------------------------------------------------------------
 if par2.atdvclpsq  is not null   then
    let ws2.opcao    = 1
    let ws2.comando2 = "  from datkveiculo, dattfrotalocal",
                       " where datkveiculo.atdvclsgl = ? ",
                       "  and datkveiculo.socacsflg  = '0'",
                       "  and dattfrotalocal.socvclcod = datkveiculo.socvclcod"
 end if

 #------------------------------------------------------------------
 # Prepara pesquisa por codigo do prestador
 #------------------------------------------------------------------
 if ws2.opcao       is null       and
    par2.pstcodpsq  is not null   then
    let ws2.opcao    = 2
    let ws2.comando2 = "  from datkveiculo, dattfrotalocal",
                       " where datkveiculo.pstcoddig    = ?",
                       "   and datkveiculo.socctrposflg = 'S'",
                       "   and datkveiculo.socoprsitcod = '1'",
                       "   and datkveiculo.socacsflg    = '0'",
                       "   and dattfrotalocal.socvclcod =datkveiculo.socvclcod",
                       " order by atdvclpriflg   desc,",
                       "          c24atvcod[3,3] desc,",
                       "          cttdat         asc ,",
                       "          ctthor         asc ,",
                       "          atdvclsgl      asc  "
 end if

 #------------------------------------------------------------------
 # Prepara pesquisa por grupo de distribuicao
 #------------------------------------------------------------------
 if ws2.opcao          is null   and
    par2.c24atvpsq     is null   and
    par2.endzonpsq     is null   and
    par2.soceqpcodpsq  is null   and
    l_vcldtbgrpcod     is not null then                   # PSI-2011-21009
    let ws2.opcao    = 3
    let ws2.comando2 = "  from dattfrotalocal, datkveiculo",
                       " where dattfrotalocal.vcldtbgrpcod = ? ",
                       "   and datkveiculo.socvclcod =dattfrotalocal.socvclcod",
                       "   and datkveiculo.socacsflg = '0'     ",
                       "   and datkveiculo.socoprsitcod = '1'",
                       " order by atdvclpriflg   desc,",
                       "          c24atvcod[3,3] desc,",
                       "          cttdat         asc ,",
                       "          ctthor         asc  "
 end if

 #------------------------------------------------------------------
 # Prepara pesquisa por codigo de atividade
 #------------------------------------------------------------------
 if ws2.opcao          is null       and
    par2.c24atvpsq     is not null   and
    par2.endzonpsq     is null       and
    par2.soceqpcodpsq  is null       and 
    l_vcldtbgrpcod     is not null   then                 # PSI-2011-21009
    let ws2.opcao    = 4
    let ws2.comando2 = " from dattfrotalocal, datkveiculo",
                       " where dattfrotalocal.vcldtbgrpcod = ? ",
                       "   and datkveiculo.socvclcod =dattfrotalocal.socvclcod",
                       "   and datkveiculo.socacsflg    = '0'",
                       "   and datkveiculo.socoprsitcod = '1'",
                       " order by atdvclpriflg   desc,",
                       "          c24atvcod[3,3] desc,",
                       "          cttdat         asc ,",
                       "          ctthor         asc  "
 end if

 #------------------------------------------------------------------
 # Prepara pesquisa por Atividade / Zona
 #------------------------------------------------------------------
 if ws2.opcao          is null       and
    par2.endzonpsq     is not null   and
    par2.soceqpcodpsq  is null       and
    l_vcldtbgrpcod     is not null   then                 # PSI-2011-21009
    let ws2.opcao    = 5
    let ws2.comando2 = " from datmfrtpos, dattfrotalocal, datkveiculo",
                       " where datmfrtpos.endzon = ?",
                       "   and datmfrtpos.socvcllcltip = '1'",
                       "   and dattfrotalocal.socvclcod = datmfrtpos.socvclcod",
                       "   and dattfrotalocal.vcldtbgrpcod = ?",
                       "   and datkveiculo.socvclcod =dattfrotalocal.socvclcod",
                       "   and datkveiculo.socacsflg    = '0'",
                       "   and datkveiculo.socoprsitcod = '1'",
                       " order by atdvclpriflg   desc,",
                       "          c24atvcod[3,3] desc,",
                       "          cttdat         asc ,",
                       "          ctthor         asc  "
 end if

 #------------------------------------------------------------------
 # Prepara pesquisa por Zona / Atividade / Equipamento
 #------------------------------------------------------------------
 if ws2.opcao          is null       and
    par2.endzonpsq     is not null   and
    par2.soceqpcodpsq  is not null   and
    l_vcldtbgrpcod     is not null   then                 # PSI-2011-21009
    let ws2.opcao    = 6
    let ws2.comando2 = "  from datmfrtpos, dattfrotalocal, datkveiculo, datreqpvcl",
                       " where datmfrtpos.endzon = ?",
                       "   and datmfrtpos.socvcllcltip = '1'",
                       "   and dattfrotalocal.socvclcod = datmfrtpos.socvclcod",
                       "   and dattfrotalocal.vcldtbgrpcod = ?",
                       "   and datkveiculo.socvclcod =dattfrotalocal.socvclcod",
                       "   and datkveiculo.socacsflg    = '0'",
                       "   and datkveiculo.socoprsitcod = '1'",
                       "   and datreqpvcl.socvclcod  = datkveiculo.socvclcod",
                       "   and datreqpvcl.soceqpcod  = ? ",
                       " order by atdvclpriflg   desc,",
                       "          c24atvcod[3,3] desc,",
                       "          cttdat         asc ,",
                       "          ctthor         asc  "
 end if

 #------------------------------------------------------------------
 # Prepara pesquisa por Codigo de Equipamento
 #------------------------------------------------------------------
 if ws2.opcao          is null       and
    par2.soceqpcodpsq  is not null   and
    l_vcldtbgrpcod     is not null   then                 # PSI-2011-21009
    let ws2.opcao    = 7
    let ws2.comando2 = "  from dattfrotalocal, datkveiculo, datreqpvcl",
                       " where dattfrotalocal.vcldtbgrpcod = ?",
                       "   and datkveiculo.socvclcod =dattfrotalocal.socvclcod",
                       "   and datkveiculo.socoprsitcod = '1'",
                       "   and datkveiculo.socacsflg    = '0'",
                       "   and datreqpvcl.socvclcod  = datkveiculo.socvclcod",
                       "   and datreqpvcl.soceqpcod  = ? ",
                       " order by atdvclpriflg   desc,",
                       "          c24atvcod[3,3] desc,",
                       "          cttdat         asc ,",
                       "          ctthor         asc  "
 end if

 #------------------------------------------------------------------
 # Prepara pesquisa por Atividade sem grupo  PSI-2011-21009 12.12.11
 #------------------------------------------------------------------
 if ws2.opcao          is null     and
    par2.c24atvpsq     is not null and
    l_vcldtbgrpcod     is null     then
    let ws2.opcao    = 8
    let ws2.comando2 = "  from dattfrotalocal, datkveiculo ",
                       " where dattfrotalocal.c24atvcod = ?",
                       "   and datkveiculo.socvclcod =dattfrotalocal.socvclcod",
                       "   and datkveiculo.socoprsitcod = '1'",
                       "   and datkveiculo.socacsflg    = '0'",
                       " order by atdvclpriflg   desc,",
                       "          c24atvcod[3,3] desc,",
                       "          cttdat         asc ,",
                       "          ctthor         asc  "
 end if

 if ws2.opcao  is null   then
    error " Nao foi possivel montar chave para pesquisa, AVISE INFORMATICA!"
    return ws2.pstcoddig,
           ws2.atdvclsgl,
           ws2.srrcoddig,
           "",0
 end if

 let ws2.comando1= "select dattfrotalocal.srrcoddig,",
                   "       dattfrotalocal.cttdat,",
                   "       dattfrotalocal.ctthor,",
                   "       dattfrotalocal.c24atvcod,",
                   "       dattfrotalocal.atdsrvnum,",
                   "       dattfrotalocal.atdsrvano,",
                   "       dattfrotalocal.atdvclpriflg,",
                   "       dattfrotalocal.obspostxt,",
                   "       datkveiculo.socvclcod,",
                   "       datkveiculo.atdvclsgl,",
                   "       datkveiculo.pstcoddig,",
                   "       datkveiculo.vclcoddig ",

                           ws2.comando2  clipped
 prepare pcts00m03013 from ws2.comando1
 declare ccts00m03014  cursor with hold for pcts00m03013

 #------------------------------------------------------------------
 # Passa parametros para leitura dos veiculos
 #------------------------------------------------------------------
 case  ws2.opcao
       when 01
            open ccts00m03014  using par2.atdvclpsq
       when 02
            open ccts00m03014  using par2.pstcodpsq
       when 03
            open ccts00m03014  using par2.vcldtbgrpcod
       when 04
            open ccts00m03014  using par2.vcldtbgrpcod
       when 05
            open ccts00m03014  using par2.endzonpsq,
                                   par2.vcldtbgrpcod
       when 06
            open ccts00m03014  using par2.endzonpsq,
                                   par2.vcldtbgrpcod,
                                   par2.soceqpcodpsq
       when 07
            open ccts00m03014  using par2.vcldtbgrpcod,
                                   par2.soceqpcodpsq
       when 08
            open ccts00m03014  using par2.c24atvpsq
 end case

 message " Aguarde, pesquisando..."  attribute(reverse)

 foreach ccts00m03014 into  a_cts00m03[arr_aux].srrcoddig,
                          ws2.data,
                          l_hora,
                          a_cts00m03[arr_aux].c24atvcod,
                          a_cts00m03[arr_aux].atdsrvnum,
                          a_cts00m03[arr_aux].atdsrvano,
                          ws2.atdvclpriflg,
                          a_cts00m03[arr_aux].obspostxt,
                          a_cts00m03[arr_aux].socvclcod,
                          a_cts00m03[arr_aux].atdvclsgl,
                          a_cts00m03[arr_aux].pstcoddig,
                          ws2.vclcoddig

    if par2.ciaempcod is not null then
       call ctd05g00_valida_empveic(par2.ciaempcod,
                                    a_cts00m03[arr_aux].socvclcod)
            returning l_resultado, l_mensagem

       if l_resultado <> 1 then
          continue foreach
       end if
    end if

    #------------------------------------------------------------------
    # Verifica tipo de assistencia do socorrista
    #------------------------------------------------------------------
#   if par2.asitipcod  is not null    then
#      open  ccts00m03007  using  a_cts00m03[arr_aux].srrcoddig,
#                                 par2.asitipcod
#      fetch ccts00m03007  into   ws2.asitipcod
#         if sqlca.sqlcode = notfound then
#            initialize a_cts00m03[arr_aux].*  to null
#            initialize a_cts00m03b[arr_aux].* to null
#            continue foreach
#         end if
#      close ccts00m03007
#   end if

    #------------------------------------------------------------------
    # Calcula tempo de espera
    #------------------------------------------------------------------
    let ws2.tempod = 000
    initialize  a_cts00m03[arr_aux].tempo   to null
    let m_cts00m03_tempo = null

    if a_cts00m03[arr_aux].c24atvcod  is not null then
        call ctx01g07_dif_tempo(today,l_newhoraatu,ws2.data,l_hora)
       returning m_cts00m03_tempo

        let a_cts00m03[arr_aux].tempo = m_cts00m03_tempo[5,10]
        let ws2.tempod = m_cts00m03_tempo[5,7]

#       call cts00m03_calcula(l_hora,    #substituido - chamado 7044206
#                             ws2.data,
#                             par2.horaatu)
#            returning  a_cts00m03[arr_aux].tempo, ws2.tempod
    end if

    #-------------------------------------------------------------
    #  "QRU" com mais de 2:00h e' considerado como possivel "QRV"
    #-------------------------------------------------------------
   #if par2.c24atvpsq  =  "QRV"   then
   #   if a_cts00m03[arr_aux].c24atvcod  <>  "QRV"   and
   #      a_cts00m03[arr_aux].c24atvcod  <>  "QRU"   then
   #      initialize a_cts00m03[arr_aux].*  to null
   #      initialize a_cts00m03b[arr_aux].* to null
   #      continue foreach
   #   end if
   #   if a_cts00m03[arr_aux].c24atvcod  =  "QRU"  then
   #      if ws2.tempod                  <   2     then
   #         initialize a_cts00m03[arr_aux].*  to null
   #         initialize a_cts00m03b[arr_aux].* to null
   #         continue foreach
   #      end if
   #   end if
   #else
       if a_cts00m03[arr_aux].c24atvcod  <>  par2.c24atvpsq   then
          initialize a_cts00m03[arr_aux].*  to null
          initialize a_cts00m03b[arr_aux].* to null
          continue foreach
       end if
   #end if

    #------------------------------------------------------------------
    # Busca origem do servico
    #------------------------------------------------------------------
    if a_cts00m03[arr_aux].atdsrvnum is not null then

       open ccts00m03012 using a_cts00m03[arr_aux].atdsrvnum,
                               a_cts00m03[arr_aux].atdsrvano
       whenever error continue
       fetch ccts00m03012 into a_cts00m03[arr_aux].atdsrvorg,
                               a_cts00m03b[arr_aux].asitipcod   #PSI198714
       whenever error stop

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             error "Erro SELECT ccts00m03012 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
             error "CTS00M03/cts00m03_posicao() ", a_cts00m03[arr_aux].atdsrvnum, "/",
                                                   a_cts00m03[arr_aux].atdsrvano sleep 3
             exit foreach
          end if
       end if

    else

       open ccts00m03012 using par2.atdsrvnum,
                               par2.atdsrvano
       whenever error continue
       fetch ccts00m03012 into a_cts00m03[arr_aux].atdsrvorg,
                               a_cts00m03b[arr_aux].asitipcod   #PSI198714
       whenever error stop

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             error "Erro SELECT ccts00m03012 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
             error "CTS00M03/cts00m03_posicao() ", par2.atdsrvnum, "/",
                                                   par2.atdsrvano sleep 3
             exit foreach
          end if
       end if

    end if

    close ccts00m03012

    #--> Ativar filtro: Tipo de Servico x Grupo    # PSI-2011-21009 12.12.11
    if par2.srvorgtipcod is not null then
       if not cts00m03_checarListaGrpTipo( par2.srvorgtipcod
                                         , a_cts00m03[arr_aux].atdsrvorg) then
          continue foreach
       end if
    end if

    let a_cts00m03[arr_aux].celdddcod = null
    let a_cts00m03[arr_aux].celtelnum = null

    # BUSCA O CELULAR DO VEICULO
    call cts00m03_cel_veiculo(a_cts00m03[arr_aux].socvclcod)
         returning a_cts00m03[arr_aux].celdddcod,
                   a_cts00m03[arr_aux].celtelnum,
                   a_mdtcod[arr_aux]

    #------------------------------------------------------------------
    # Busca dados do socorrista
    #------------------------------------------------------------------
    let a_cts00m03[arr_aux].celular   = null
    let a_cts00m03[arr_aux].srrabvnom = null
    let ws2.celdddcod                 = null
    let ws2.celtelnum                 = null

    if a_cts00m03[arr_aux].srrcoddig  is not null   then

       open  ccts00m03005  using  a_cts00m03[arr_aux].srrcoddig
       fetch ccts00m03005  into   a_cts00m03[arr_aux].srrabvnom
       close ccts00m03005

       # BUSCA O CELULAR DO SOCORRISTA
       call cts00m03_cel_socorr(a_cts00m03[arr_aux].srrcoddig)
            returning ws2.celdddcod, ws2.celtelnum

       #let a_cts00m03[arr_aux].celular = ws2.celdddcod  clipped, " ", ws2.celtelnum
       let a_cts00m03[arr_aux].celular = ws2.celtelnum

    end if

    #BUSCA O ID NEXTEL DO VEÍCULO, DEPOIS DO SOCORRISTA
    call cts00m03_id_nextel(a_cts00m03[arr_aux].socvclcod, a_cts00m03[arr_aux].srrcoddig)
            returning ws2.nxtnum, ws2.nxtide

    let a_cts00m03[arr_aux].nxtnum = ws2.nxtnum
    let a_cts00m03[arr_aux].nxtide = ws2.nxtide

    #------------------------------------------------------------------
    # Busca assistencias do socorrista
    #------------------------------------------------------------------

    # --> VERIFICA O GRUPO DO SERVICO
    if par2.vcldtbgrpcod = 3 or
       par2.vcldtbgrpcod = 4 or
       par2.vcldtbgrpcod = 6 or
       par2.vcldtbgrpcod = 8 then

       #PSI 224782
       let l_desc_ast = null
       let l_desc_ntz = null
       let l_desc_ast = cts00m03_busca_assistencia(a_cts00m03[arr_aux].srrcoddig, a_cts00m03[arr_aux].socvclcod)
       let l_desc_ntz = cts00m03_busca_natureza(a_cts00m03[arr_aux].srrcoddig)
       let a_cts00m03[arr_aux].srrasides = l_desc_ast clipped,"/", l_desc_ntz

       if a_cts00m03[arr_aux].srrasides is null or
          a_cts00m03[arr_aux].srrasides = " " then

          #PSI 224782
          let l_desc_ast = null
          let l_desc_ntz = null
          let l_desc_ast = cts00m03_busca_assistencia(a_cts00m03[arr_aux].srrcoddig, a_cts00m03[arr_aux].socvclcod)
          let l_desc_ntz = cts00m03_busca_natureza(a_cts00m03[arr_aux].srrcoddig)
          let a_cts00m03[arr_aux].srrasides = l_desc_ast clipped,"/", l_desc_ntz

       end if

    else

       #PSI 224782
       let l_desc_ast = null
       let l_desc_ntz = null
       let l_desc_ast = cts00m03_busca_assistencia(a_cts00m03[arr_aux].srrcoddig, a_cts00m03[arr_aux].socvclcod)
       let l_desc_ntz = cts00m03_busca_natureza(a_cts00m03[arr_aux].srrcoddig)
       let a_cts00m03[arr_aux].srrasides = l_desc_ast clipped,"/", l_desc_ntz

    end if

    #------------------------------------------------------------------
    # Busca descrição do tipo de equipamento
    #------------------------------------------------------------------
    initialize a_cts00m03[arr_aux].socvcltipdes  to null

    open  ccts00m03001 using a_cts00m03[arr_aux].socvclcod
    fetch ccts00m03001 into l_socvcltip
    close ccts00m03001
    let ws2.cponom = 'socvcltip'
    open ccts00m03024 using ws2.cponom,
                            l_socvcltip
    fetch ccts00m03024 into a_cts00m03[arr_aux].socvcltipdes
    #------------------------------------------------------------------
    # Busca equipamentos do veiculo
    #------------------------------------------------------------------
    initialize  a_cts00m03[arr_aux].vcleqpdes  to null

    open    ccts00m03002  using  a_cts00m03[arr_aux].socvclcod
    foreach ccts00m03002  into   ws2.soceqpabv
       let a_cts00m03[arr_aux].vcleqpdes =
           a_cts00m03[arr_aux].vcleqpdes clipped, ws2.soceqpabv clipped, "/"
    end foreach
    close ccts00m03002

    #------------------------------------------------------------------
    # Busca localizacao do veiculo
    #------------------------------------------------------------------
    let a_cts00m03[arr_aux].ufdcod_gps  = null
    let a_cts00m03[arr_aux].cidnom_gps  = null
    let a_cts00m03[arr_aux].brrnom_gps  = null
    let a_cts00m03[arr_aux].endzon_gps  = null
    let a_cts00m03[arr_aux].tipposcab   = null
    let a_cts00m03b[arr_aux].lclltt_gps = null
    let a_cts00m03b[arr_aux].lcllgt_gps = null

    let a_cts00m03[arr_aux].ufdcod_qth  = null
    let a_cts00m03[arr_aux].cidnom_qth  = null
    let a_cts00m03[arr_aux].brrnom_qth  = null
    let a_cts00m03[arr_aux].endzon_qth  = null
    let a_cts00m03b[arr_aux].lclltt_qth = null
    let a_cts00m03b[arr_aux].lcllgt_qth = null

    let a_cts00m03[arr_aux].ufdcod_qti  = null
    let a_cts00m03[arr_aux].cidnom_qti  = null
    let a_cts00m03[arr_aux].brrnom_qti  = null
    let a_cts00m03[arr_aux].endzon_qti  = null
    let a_cts00m03b[arr_aux].lclltt_qti = null
    let a_cts00m03b[arr_aux].lcllgt_qti = null

    open    ccts00m03003  using  a_cts00m03[arr_aux].socvclcod

    foreach ccts00m03003  into   ws2.ufdcod,
                                 ws2.cidnom,
                                 ws2.brrnom,
                                 ws2.endzon,
                                 ws2.lclltt,
                                 ws2.lcllgt,
                                 ws2.socvcllcltip

       if ws2.socvcllcltip  =  1   then
          let a_cts00m03[arr_aux].ufdcod_gps  =  ws2.ufdcod
          let a_cts00m03[arr_aux].cidnom_gps  =  ws2.cidnom
          let a_cts00m03[arr_aux].brrnom_gps  =  ws2.brrnom
          let a_cts00m03[arr_aux].endzon_gps  =  ws2.endzon
          let a_cts00m03b[arr_aux].lclltt_gps =  ws2.lclltt
          let a_cts00m03b[arr_aux].lcllgt_gps =  ws2.lcllgt

          if a_cts00m03b[arr_aux].lclltt_gps  is not null   and
             a_cts00m03b[arr_aux].lcllgt_gps  is not null   then
             let a_cts00m03[arr_aux].tipposcab = "#"
          else
             let a_cts00m03[arr_aux].tipposcab = " "
          end if
       else
          if ws2.socvcllcltip  =  2   then
             let a_cts00m03[arr_aux].ufdcod_qth  =  ws2.ufdcod
             let a_cts00m03[arr_aux].cidnom_qth  =  ws2.cidnom
             let a_cts00m03[arr_aux].brrnom_qth  =  ws2.brrnom
             let a_cts00m03[arr_aux].endzon_qth  =  ws2.endzon
             let a_cts00m03b[arr_aux].lclltt_qth =  ws2.lclltt
             let a_cts00m03b[arr_aux].lcllgt_qth =  ws2.lcllgt
          else
             let a_cts00m03[arr_aux].ufdcod_qti  =  ws2.ufdcod
             let a_cts00m03[arr_aux].cidnom_qti  =  ws2.cidnom
             let a_cts00m03[arr_aux].brrnom_qti  =  ws2.brrnom
             let a_cts00m03[arr_aux].endzon_qti  =  ws2.endzon
             let a_cts00m03b[arr_aux].lclltt_qti =  ws2.lclltt
             let a_cts00m03b[arr_aux].lcllgt_qti =  ws2.lcllgt
          end if
       end if

    end foreach
    close ccts00m03003

    ####################################################
    # Obtem o complemnto da atividade
    ####################################################
    if a_cts00m03[arr_aux].c24atvcod = "REM" or
       a_cts00m03[arr_aux].c24atvcod = "ROD" or
       a_cts00m03[arr_aux].c24atvcod = "RET" or
       a_cts00m03[arr_aux].c24atvcod = "QRX" then
       case a_cts00m03[arr_aux].c24atvcod
            when "REM"
               let ws2.mdtbotprgseq = 14
            when "ROD"
               let ws2.mdtbotprgseq = 18
            when "RET"
               let ws2.mdtbotprgseq = 15
            when "QRX"
               let ws2.mdtbotprgseq = 10
       end case
       open  ccts00m03025  using  a_mdtcod[arr_aux],
                                  ws2.mdtbotprgseq
       fetch ccts00m03025  into   ws2.mvtcaddat,
                                  ws2.mvtcadhor,
                                  ws2.mdtmvtdigcnt
       close ccts00m03025
       if a_cts00m03[arr_aux].c24atvcod = "QRX" then
          if ws2.mdtmvtdigcnt is null or ws2.mdtmvtdigcnt = " " then
             let a_cts00m03[arr_aux].c24atvcmp = ""
          else # QRX TEMPORIZADO
             let ws2.qrxtmpprg = ws2.mdtmvtdigcnt

             let ws2.qrxmincor = ctx01g07_espera (ws2.mvtcaddat, ws2.mvtcadhor)
             let ws2.qrxmincortxt = ws2.qrxmincor
             let ws2.qrxmincorval = ws2.qrxmincortxt
             if ws2.qrxmincorval < ws2.qrxtmpprg then
                let a_cts00m03[arr_aux].c24atvcmp = "QRV em ", (ws2.qrxtmpprg - ws2.qrxmincorval) using "<<&", " MIN"
             else
                let a_cts00m03[arr_aux].c24atvcmp = "QRV em Processo"
             end if
          end if
       else
          if ws2.mdtbotprgseq = 15 then # RETORNO apresentar numero do servico no complemento da atividade
             let a_cts00m03[arr_aux].c24atvcmp = ws2.mdtmvtdigcnt
          else
             let ws2.cponom = "mdtbotprgseq_", ws2.mdtbotprgseq using "<<<&"
             open ccts00m03024 using ws2.cponom,
                                     ws2.mdtmvtdigcnt
             fetch ccts00m03024 into a_cts00m03[arr_aux].c24atvcmp
             close ccts00m03024
          end if
       end if
    else
       let a_cts00m03[arr_aux].c24atvcmp = ""
    end if

    let arr_aux = arr_aux + 1
    if arr_aux  >  300   then
       error " Limite excedido! Posicao da frota com mais de 300 veiculos!"
       exit foreach
    end if

 end foreach

 if arr_aux  =  1   then
    error " Nao existem veiculos para pesquisa solicitada!"
    return ws2.pstcoddig,
           ws2.atdvclsgl,
           ws2.srrcoddig,
           a_cts00m03[arr_aux].socvclcod,
           0
 end if

 #------------------------------------------------------------------
 #  Monta tela - Display array
 #------------------------------------------------------------------
 message ""
 call set_count(arr_aux-1)


 if par2.operacao  =  1   then

    options
       delete key control-x

    #-------------------------------------------------
    # PSI 206261 - Consulta produtividade por inspetor
    #-------------------------------------------------
    #display " F2-Serv. F5-C.Veic. F6-Rec. F7-MsgPager F8-Sel. F9-MsgMDT F10-MaisInfor." at 21,01
    if par2.vcldtbgrpcod = 10 then
        if get_niv_mod(g_issk.prgsgl, 'oavpc019') then
            if g_issk.acsnivcod >= g_issk.acsnivcns then
                display "Ctrl+P-Prod|F2-SRV|F5-C.Veic|F6-Rec|F7-MsgPager|F8-Sel|F9-Sinais GPS|F10-Prest" at 22,01
            else
                display "F2-SRV Soc F5-C.Veic F6-Rec F7-MsgPager F8-Sel F9-Sinais GPS F10-Prest/Atl VTR" at 22,01
            end if
        else
            display "F2-SRV Soc F5-C.Veic F6-Rec F7-MsgPager F8-Sel F9-Sinais GPS F10-Prest/Atl VTR" at 22,01
        end if
    else
        display "F2-SRV Soc F5-C.Veic F6-Rec F7-MsgPager F8-Sel F9-Sinais GPS F10-Prest/Atl VTR" at 22,01
    end if

    display array a_cts00m03 to s_cts00m03.*
       on key(interrupt)
          initialize a_cts00m03  to null
          exit display

        #-------------------------------------------------
        # PSI 206261 - Consulta produtividade por inspetor
        #-------------------------------------------------
        on key (CONTROL-p,CONTROL-P)
            if par2.vcldtbgrpcod = 10 then
                if get_niv_mod(g_issk.prgsgl, 'oavpc019') then
                    if g_issk.acsnivcod >= g_issk.acsnivcns then
                        let l_posicao = arr_curr()
                        call oavpc019(today,today,a_cts00m03[l_posicao].atdvclsgl,0)
                    end if
                end if
            end if

        #---------------------------------------------------------#
        # Consulta e exibe as Naturezas atendidas pelos prestadores
        #---------------------------------------------------------#
        on key (f2)

           let l_posicao = arr_curr()

           call cts00m03_exibe_natz_atend(a_cts00m03[l_posicao].srrcoddig, a_cts00m03[l_posicao].socvclcod)

       ## Implementar Consulta de Locais e Condicoes do Veiculo
       on key (f5)
          let arr_aux = arr_curr()
          call ctc61m02(par2.atdsrvnum,par2.atdsrvano,"A")
          let l_tmp_flg = ctc61m02_criatmp(2,
                                           par2.atdsrvnum,
                                           par2.atdsrvano)
          if l_tmp_flg = 1 then
             error "Problemas com temporaria ! <Avise a Informatica>."
          end if

       on key(F6)
          let arr_aux = arr_curr()

          whenever error continue
             select atdsrvorg into l_atdsrvorg
               from datmservico
              where atdsrvnum = par2.atdsrvnum
                and atdsrvano = par2.atdsrvano
          whenever error stop

          if sqlca.sqlcode = 0 then
             call cta11m00 ( l_atdsrvorg
                            ,par2.atdsrvnum
                            ,par2.atdsrvano
                            ,a_cts00m03[arr_aux].pstcoddig
                            ,"S" )
                  returning l_srvrcumtvcod
          else
             if sqlca.sqlcode < 0 then
                 error "Erro ", sqlca.sqlcode using "<<<<<&",
                       " na selecao da tabela datmservico."
             end if
          end if

       on key(F7)
          call cts24m00()

       #------------------------------------------------------------
       # Seleciona veiculo
       #------------------------------------------------------------
       on key(F8)
          let arr_aux = arr_curr()
          let ws2.f8flg = "S"

          #PSI198714 - Validar se socorrista atende assistencia/natureza do servico
          if a_cts00m03[arr_aux].atdsrvorg = 9 or
             a_cts00m03[arr_aux].atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009
            #Se origem servico = 9 ou 13 validar se socorrista atende natureza do servico
            #buscar natureza e especialidade do servico re ou sinistro re
            open ccts00m03016 using  par2.atdsrvnum
                                    ,par2.atdsrvano
            fetch ccts00m03016 into l_socntzcod,
                                    l_espcod
            if l_socntzcod is not null then
               let l_sql= "select socntzcod     "
                         ," from dbsrntzpstesp  "
                         ," where srrcoddig = ", a_cts00m03[arr_aux].srrcoddig
                         ,"   and socntzcod = ", l_socntzcod
               if l_espcod is not null then
                  #servico tem especialidade verificar se socorrista atende natireza e especialidade
                  let l_sql = l_sql clipped, " and espcod = ", l_espcod
               end if
               prepare pcts00m03017 from l_sql
               declare ccts00m03017  cursor for pcts00m03017
               open ccts00m03017
               fetch ccts00m03017 into l_socntzcod
               if sqlca.sqlcode = notfound then
                   call cts08g01("A", "N", "",
                                  "SOCORRISTA NAO ATENDE NATUREZA / ",
                                  "ESPECIALIDADE DO SERVICO", "")
                   returning l_confirma
                   let ws2.f8flg = "N"
               else
                   #socorrista atende natureza/especialidade
                   let ws2.f8flg = "S"
               end if
            else
               let ws2.f8flg = "S"
            end if
          end if
          if a_cts00m03[arr_aux].atdsrvorg = 1 or
             a_cts00m03[arr_aux].atdsrvorg = 2 or
             a_cts00m03[arr_aux].atdsrvorg = 3 or
             a_cts00m03[arr_aux].atdsrvorg = 4 or
             a_cts00m03[arr_aux].atdsrvorg = 5 or
             a_cts00m03[arr_aux].atdsrvorg = 6 or
             a_cts00m03[arr_aux].atdsrvorg = 7 or
             a_cts00m03[arr_aux].atdsrvorg = 17 then
            #Qualquer outra origem de servico validar se socorrista atende tipo assistencia
            let l_sql = "select a.srrcoddig  ",
                        "   from datrsrrasi a",
                        "  where a.srrcoddig = ",a_cts00m03[arr_aux].srrcoddig
            case a_cts00m03b[arr_aux].asitipcod   #quando tipo de assistencia do servico e:
                when 1                            #GUINCHO podemos enviar socorrista que atende
                   let l_sql = l_sql clipped,     #GUINCHO e GUINCHO/TECNICO
                       " and a.asitipcod in (1, 3)"
                when 2                            #TECNICO podemos enviar socorrista que atende
                   let l_sql = l_sql clipped,     #TECNICO - GUINCHO/TECNICO - CHAVEIRO/TECNICO
                       " and a.asitipcod in (2,3,9)"
                when 3                            #GUI/TEC podemos enviar socorrista que atende
                   let l_sql = l_sql clipped,     #GUI/TEC ou GUINCHO e TECNICO juntos
                       " and (a.asitipcod = 3 or "
                      ,"      (a.asitipcod = 1 and    "
                      ,"        exists (select b.asitipcod               "
                      ,"                 from datrsrrasi b               "
                      ,"                 where b.srrcoddig = a.srrcoddig "
                      ,"                 and b.asitipcod = 2) ) )        "
                when 4                            #CHAVEIRO podemos enviar socorrista que atende
                   let l_sql = l_sql clipped,     #CHAVEIRO - CHAVEIRO TECNICO - CHAVAUTO
                       " and a.asitipcod in (4,9,40)"
                when 9                            #CHAVEIRO TECNICO podemos enviar socorrista que atende
                   let l_sql = l_sql clipped,     #CHAVEIRO TECNICO OU TECNICO e Chaveiro ou Chavauto juntos
                       " and (a.asitipcod = 9 or   "
                      ,"      (a.asitipcod = 2 and "
                      ,"        exists (select b.asitipcod                "
                      ,"                  from datrsrrasi b               "
                      ,"                  where b.srrcoddig = a.srrcoddig "
                      ,"                  and (b.asitipcod = 4 or         "
                      ,"                        b.asitipcod = 40) ) ) )   "
                when 40                           #CHAVAUTO podemos enviar socorrista que atende
                   let l_sql = l_sql clipped,     #CHAVEIRO - CHAVEIRO TECNICO - CHAVAUTO
                       " and a.asitipcod in (4,9,40)"

                otherwise
                   let l_sql = l_sql clipped, " and asitipcod in (",
                                              a_cts00m03b[arr_aux].asitipcod,")"
            end case
            #OBS.: Hoje estamos fazendo essas conversoes de tipo de assitencia do
            # socorrista porque o cadastro deles não está integro.
            # Os códigos 3, 9 e 40 nao deveriam mais existir
            # exemplo: os socorristas que atendem assistencia 3 deveriam atender
            # assistencia 1 e 2.
            #Quando o cadastro de assistencia dos socorristas estiver correto,
            # podemos retirar essas conversoes
            prepare pcts00m03020 from l_sql
            declare ccts00m03020  cursor for pcts00m03020
            open ccts00m03020
            fetch ccts00m03020  into   ws2.srrcoddig

            if sqlca.sqlcode = notfound then
               call cts08g01("A", "N", "", "SOCORRISTA NAO ATENDE TIPO ",
                                  "DE ASSISTENCIA DO SERVICO", "")
                    returning l_confirma
                   let ws2.f8flg = "N"
            else
               #socorrista atende assistencia
               let ws2.f8flg = "S"
            end if
            close ccts00m03020
          end if

          if ws2.f8flg = "S" then
             call cts00m20_verif_auto( par2.atdsrvnum,par2.atdsrvano,
                       par2.ciaempcod,a_cts00m03b[arr_aux].asitipcod,
                       a_cts00m03[arr_aux].socvclcod, 9999,
                       a_cts00m03[arr_aux].srrcoddig)
                   returning l_retorno
             if l_retorno = 0 then
	            let ws2.f8flg = "N"
	         end if
	      end if

          if ws2.f8flg = "S" then
             let ws2.f8flg = "N"
             if a_cts00m03[arr_aux].c24atvcod  =  "QRV"   then
                if a_cts00m03[arr_aux].srrcoddig  is null   then
                   error " Veiculo sem socorrista informado, nao deve ser selecionado!"
                else
                   let ws2.f8flg = "S"
                   exit display
                end if
             else
                if  a_cts00m03[arr_aux].c24atvcod =  "QRU"  then
                    select atdsrvorg
                       into ws2.atdsrvorg
                       from datmservico
                       where atdsrvnum = par2.atdsrvnum
                         and atdsrvano = par2.atdsrvano
                    if ws2.atdsrvorg  =  10 then
                       let ws2.f8flg = "S"
                       exit display
                    end if
                else
                    error " Veiculo nao esta' em QRV, nao deve ser selecionado!"
                end if
             end if
          end if

       #---------------------------------------------------------------
       # Consulta mensagens recebidas dos MDTs
       #---------------------------------------------------------------
       on key (F9)
          let arr_aux = arr_curr()
          call ctn44c00(2, a_cts00m03[arr_aux].atdvclsgl,"")

       #---------------------------------------------------------------
       # Verifica ultima atividade por viatura
       #---------------------------------------------------------------
       on key (F10)
          let arr_aux = arr_curr()
          call cts00m32(a_cts00m03[arr_aux].socvclcod)

    end display

    options
       delete key f2

 end if

 if int_flag then
    let int_flag = false
    exit while
 end if

 #------------------------------------------------------------------
 #  Monta tela - Input array
 #------------------------------------------------------------------
 if par2.operacao  =  2   then

     options
        delete key control-x

    display " F2-SRV Socorrista F6-Atualiza F8-Laudo F9-Sinais GPS F10-Prest/Atl VTR."  at 22,01

    input array a_cts00m03 without defaults from s_cts00m03.*

    before row
       let arr_aux = arr_curr()
       let scr_aux = scr_line()
       if arr_aux <= arr_count()  then
          let ws2.operacao    = "a"
          let ws2.c24atvcod   =  a_cts00m03[arr_aux].c24atvcod
          let ws2.srrcoddig   =  a_cts00m03[arr_aux].srrcoddig
          let ws2.obspostxt   =  a_cts00m03[arr_aux].obspostxt
          let ws2.ufdcod_gps  =  a_cts00m03[arr_aux].ufdcod_gps
          let ws2.cidnom_gps  =  a_cts00m03[arr_aux].cidnom_gps
          let ws2.brrnom_gps  =  a_cts00m03[arr_aux].brrnom_gps
          let ws2.endzon_gps  =  a_cts00m03[arr_aux].endzon_gps
          let ws2.ufdcod_qth  =  a_cts00m03[arr_aux].ufdcod_qth
          let ws2.cidnom_qth  =  a_cts00m03[arr_aux].cidnom_qth
          let ws2.brrnom_qth  =  a_cts00m03[arr_aux].brrnom_qth
          let ws2.endzon_qth  =  a_cts00m03[arr_aux].endzon_qth
          let ws2.ufdcod_qti  =  a_cts00m03[arr_aux].ufdcod_qti
          let ws2.cidnom_qti  =  a_cts00m03[arr_aux].cidnom_qti
          let ws2.brrnom_qti  =  a_cts00m03[arr_aux].brrnom_qti
          let ws2.endzon_qti  =  a_cts00m03[arr_aux].endzon_qti
       end if

    before field c24atvcod
       let l_c24atvcod_slv = a_cts00m03[arr_aux].c24atvcod
       display a_cts00m03[arr_aux].c24atvcod  to
               s_cts00m03[scr_aux].c24atvcod  attribute (reverse)

    after field c24atvcod
       display a_cts00m03[arr_aux].c24atvcod  to
               s_cts00m03[scr_aux].c24atvcod

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field c24atvcod
          end if
       end if

       if a_cts00m03[arr_aux].c24atvcod  is null  then
          error " Codigo da atividade deve ser informado!"
          next field c24atvcod
       end if

       if a_cts00m03[arr_aux].c24atvcod  <>  "QTP" and
          a_cts00m03[arr_aux].c24atvcod  <>  "QRX" and
          a_cts00m03[arr_aux].c24atvcod  <>  "QRA" and
          a_cts00m03[arr_aux].c24atvcod  <>  "QRV" and
          a_cts00m03[arr_aux].c24atvcod  <>  "QRU" and
          a_cts00m03[arr_aux].c24atvcod  <>  "REC" and
          a_cts00m03[arr_aux].c24atvcod  <>  "INI" and
          a_cts00m03[arr_aux].c24atvcod  <>  "REM" and
          a_cts00m03[arr_aux].c24atvcod  <>  "FIM" and
          a_cts00m03[arr_aux].c24atvcod  <>  "NIL" and
          a_cts00m03[arr_aux].c24atvcod  <>  "RET" and
          a_cts00m03[arr_aux].c24atvcod  <>  "ROD" then
          let a_cts00m03[arr_aux].c24atvcod = l_c24atvcod_slv
          error " Codigo da atividade invalido!"
          next field c24atvcod
       end if

       if a_cts00m03[arr_aux].c24atvcod  =  "QRA"   then
          error " Codigo de atividade utilizada apenas para logon via MDT!"
          next field c24atvcod
       end if

       #----------------------------------------------------------------
       #  Quando mudar para QRV ou QTP limpa campos da tela
       #----------------------------------------------------------------
       if (a_cts00m03[arr_aux].c24atvcod  <>  ws2.c24atvcod)   and
          (a_cts00m03[arr_aux].c24atvcod  =  "QRV"             or
           a_cts00m03[arr_aux].c24atvcod  =  "QTP")            then

          let a_cts00m03[arr_aux].ufdcod_qth  =  "  "
          let a_cts00m03[arr_aux].cidnom_qth  =  "  "
          let a_cts00m03[arr_aux].brrnom_qth  =  "  "
          let a_cts00m03[arr_aux].endzon_qth  =  "  "
          initialize a_cts00m03b[arr_aux].lclltt_qth  to null
          initialize a_cts00m03b[arr_aux].lcllgt_qth  to null

          let a_cts00m03[arr_aux].ufdcod_qti  =  "  "
          let a_cts00m03[arr_aux].cidnom_qti  =  "  "
          let a_cts00m03[arr_aux].brrnom_qti  =  "  "
          let a_cts00m03[arr_aux].endzon_qti  =  "  "
          initialize a_cts00m03b[arr_aux].lclltt_qti  to null
          initialize a_cts00m03b[arr_aux].lcllgt_qti  to null

          display a_cts00m03[arr_aux].ufdcod_qth to
                  s_cts00m03[scr_aux].ufdcod_qth
          display a_cts00m03[arr_aux].cidnom_qth to
                  s_cts00m03[scr_aux].cidnom_qth
          display a_cts00m03[arr_aux].brrnom_qth to
                  s_cts00m03[scr_aux].brrnom_qth
          display a_cts00m03[arr_aux].endzon_qth to
                  s_cts00m03[scr_aux].endzon_qth

          display a_cts00m03[arr_aux].ufdcod_qti to
                  s_cts00m03[scr_aux].ufdcod_qti
          display a_cts00m03[arr_aux].cidnom_qti to
                  s_cts00m03[scr_aux].cidnom_qti
          display a_cts00m03[arr_aux].brrnom_qti to
                  s_cts00m03[scr_aux].brrnom_qti
          display a_cts00m03[arr_aux].endzon_qti to
                  s_cts00m03[scr_aux].endzon_qti

       end if

       ##### PSI 214566 - ligia - 13/12/07 - testar a seq do botao ###########
       if l_c24atvcod_slv <> a_cts00m03[arr_aux].c24atvcod then

          let l_msg1 = null
          let l_msg2 = null

          ##inibido a pedido do Cesar em 20/02/08.
          #call cts00m03_ver_botao(l_c24atvcod_slv,
          #                        a_cts00m03[arr_aux].c24atvcod)
          #     returning l_msg1, l_msg2

          #if l_msg2 is not null then

          #    if l_msg1  = l_msg2 then
          #       let l_msg1 = null
          #    end if

          #    call cts08g01("A", "N", "", l_msg1, l_msg2, "")
          #         returning l_confirma

          #    let a_cts00m03[arr_aux].c24atvcod = l_c24atvcod_slv
          #    next field c24atvcod
          #else
             ## obter codigo do botao
             let l_mdtbotcod = null
             call ctd16g00_dados_botao(1,a_cts00m03[arr_aux].c24atvcod)
                  returning l_resultado, l_mensagem, l_mdtbotcod

             if l_resultado <> 1 then
                error l_mensagem
                next field c24atvcod
             end if

             let ws2.mdtmvtdigcnt = a_cts00m03[arr_aux].srrcoddig

             case a_cts00m03[arr_aux].c24atvcod
                when "QRX"
                     let ws2.mdtbotprgseq = null
                     call ctd17g00_dados_botao(1, a_mdtcod[arr_aux], l_mdtbotcod)
                          returning ws2.erro, l_msg1, ws2.mdtbotprgseq
                     let ws2.cponom = "mdtbotprgseq_", ws2.mdtbotprgseq using "<<<&"
                     call cty09g00_popup_iddkdominio(ws2.cponom)
                          returning ws2.erro,
                                    ws2.cpocod,
                                    ws2.cpodes
                     if ws2.cpocod > 0 then
                        let ws2.mdtmvtdigcnt = ws2.cpocod
                        let a_cts00m03[arr_aux].c24atvcmp = ws2.cpodes
                     else
                        let ws2.mdtmvtdigcnt = null
                        let a_cts00m03[arr_aux].c24atvcmp = ""
                     end if
                when "ROD"
                     let ws2.mdtbotprgseq = null
                     call ctd17g00_dados_botao(1,a_mdtcod[arr_aux], l_mdtbotcod)
                          returning ws2.erro, l_msg1, ws2.mdtbotprgseq
                     let ws2.cponom = "mdtbotprgseq_", ws2.mdtbotprgseq using "<<<&"
                     call cty09g00_popup_iddkdominio(ws2.cponom)
                          returning ws2.erro,
                                    ws2.cpocod,
                                    ws2.cpodes
                     if ws2.cpocod > 0 then
                        let ws2.mdtmvtdigcnt = ws2.cpocod
                        let a_cts00m03[arr_aux].c24atvcmp = ws2.cpodes
                     else
                        let ws2.mdtmvtdigcnt = null
                        let a_cts00m03[arr_aux].c24atvcmp = ""
                     end if
                when "REM"
                     let ws2.mdtbotprgseq = null
                     call ctd17g00_dados_botao(1,a_mdtcod[arr_aux], l_mdtbotcod)
                          returning ws2.erro, l_msg1, ws2.mdtbotprgseq
                     let ws2.cponom = "mdtbotprgseq_", ws2.mdtbotprgseq using "<<<&"
                     call cty09g00_popup_iddkdominio(ws2.cponom)
                          returning ws2.erro,
                                    ws2.cpocod,
                                    ws2.cpodes
                     if ws2.cpocod > 0 then
                        let ws2.mdtmvtdigcnt = ws2.cpocod
                        let a_cts00m03[arr_aux].c24atvcmp = ws2.cpodes
                     else
                        let ws2.mdtmvtdigcnt = null
                        let a_cts00m03[arr_aux].c24atvcmp = ""
                     end if
                otherwise
                     let a_cts00m03[arr_aux].c24atvcmp = ""
             end case
             display a_cts00m03[arr_aux].c24atvcmp to s_cts00m03[scr_aux].c24atvcmp

             ## inserir botao em datmmdtmvt
             call cts00m03_insere_botao(a_mdtcod[arr_aux],
                                        l_mdtbotcod,
                                        ws2.mdtmvtdigcnt,
                                        a_cts00m03[arr_aux].ufdcod_gps,
                                        a_cts00m03[arr_aux].cidnom_gps,
                                        a_cts00m03[arr_aux].brrnom_gps,
                                        a_cts00m03b[arr_aux].lclltt_gps,
                                        a_cts00m03b[arr_aux].lcllgt_gps,
                                        a_cts00m03[arr_aux].endzon_gps,
                                        par2.atdsrvnum,
                                        par2.atdsrvano)
          #end if
       #######################################################################

       end if

    before field srrcoddig
       display a_cts00m03[arr_aux].srrcoddig to
               s_cts00m03[scr_aux].srrcoddig attribute (reverse)

    after field srrcoddig
       display a_cts00m03[arr_aux].srrcoddig to
               s_cts00m03[scr_aux].srrcoddig

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field c24atvcod
       else
          if fgl_lastkey() = fgl_keyval("down")   then
             if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
                error " Nao existem linhas nesta direcao!"
                next field srrcoddig
             end if
          end if
       end if

       if a_cts00m03[arr_aux].srrcoddig  is null   then
             initialize a_cts00m03[arr_aux].srrabvnom  to null
             display a_cts00m03[arr_aux].srrabvnom  to
                     s_cts00m03[scr_aux].srrabvnom
             next field srrabvnom
          initialize a_cts00m03[arr_aux].srrabvnom  to null
          display a_cts00m03[arr_aux].srrabvnom  to
                  s_cts00m03[scr_aux].srrabvnom
          next field srrabvnom
       end if

       if a_cts00m03[arr_aux].srrcoddig  is not null   then

          initialize ws2.atdvclsgl  to null
          initialize ws2.socvclcod  to null
          initialize ws2.pstcoddig  to null

          select srrabvnom,
                 srrstt
            into a_cts00m03[arr_aux].srrabvnom,
                 ws2.srrstt
            from datksrr
           where srrcoddig = a_cts00m03[arr_aux].srrcoddig

          if sqlca.sqlcode  =  notfound   then
             error " Socorrista nao cadastrado!"
             call ctn45c00(a_cts00m03[arr_aux].pstcoddig, "")
                  returning a_cts00m03[arr_aux].srrcoddig
             next field srrcoddig
          end if

          display a_cts00m03[arr_aux].srrabvnom to
                  s_cts00m03[scr_aux].srrabvnom

          if ws2.srrstt  <>  1   then
             error " Socorrista esta bloqueado ou cancelado!"
             next field srrcoddig
          end if

          select max(socvclcod)
            into ws2.socvclcod
            from dattfrotalocal
           where srrcoddig =  a_cts00m03[arr_aux].srrcoddig
             and socvclcod <> a_cts00m03[arr_aux].socvclcod
             and c24atvcod not in ('QTP', 'NIL')

          if ws2.socvclcod  is not null   then
             select atdvclsgl
               into ws2.atdvclsgl
               from datkveiculo
              where socvclcod  =  ws2.socvclcod

             error " Socorrista cadastrado em outro veiculo --> ", ws2.atdvclsgl
             next field srrcoddig
          end if

          open  ccts00m03004  using a_cts00m03[arr_aux].srrcoddig
          fetch ccts00m03004  into  ws2.pstcoddig
          close ccts00m03004

          if ws2.pstcoddig  is null   then
             error " Socorrista nao possui prestador informado!"
             next field srrcoddig
          end if

          if ws2.pstcoddig  <>  a_cts00m03[arr_aux].pstcoddig   then
             error " Veiculo/Socorrista cadastrados com prestadores diferentes!"
             next field srrcoddig
          end if

          initialize a_cts00m03[arr_aux].srrasides  to null

          #PSI 224782
          let l_desc_ast = null
          let l_desc_ntz = null
          let l_desc_ast = cts00m03_busca_assistencia(a_cts00m03[arr_aux].srrcoddig, a_cts00m03[arr_aux].socvclcod)
          let l_desc_ntz = cts00m03_busca_natureza(a_cts00m03[arr_aux].srrcoddig)
          let a_cts00m03[arr_aux].srrasides = l_desc_ast clipped,"/", l_desc_ntz

          if a_cts00m03[arr_aux].srrasides is null or
             a_cts00m03[arr_aux].srrasides = " " then

             #PSI 224782
             let l_desc_ast = null
             let l_desc_ntz = null
             let l_desc_ast = cts00m03_busca_assistencia(a_cts00m03[arr_aux].srrcoddig, a_cts00m03[arr_aux].socvclcod)
             let l_desc_ntz = cts00m03_busca_natureza(a_cts00m03[arr_aux].srrcoddig)
             let a_cts00m03[arr_aux].srrasides = l_desc_ast clipped,"/", l_desc_ntz

          end if

          #display "srrcoddig ", a_cts00m03[arr_aux].srrcoddig
          #display "l_desc_ast >>>>> ", l_desc_ast

          display a_cts00m03[arr_aux].srrasides to s_cts00m03[scr_aux].srrasides

       end if

       next field ufdcod_gps

    before field srrabvnom
       display a_cts00m03[arr_aux].srrabvnom  to
               s_cts00m03[scr_aux].srrabvnom  attribute (reverse)

    after field srrabvnom
       display a_cts00m03[arr_aux].srrabvnom  to
               s_cts00m03[scr_aux].srrabvnom

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field srrcoddig
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field srrabvnom
          end if
       end if

       initialize a_cts00m03[arr_aux].srrcoddig  to null

       call ctn45c00(a_cts00m03[arr_aux].pstcoddig,
                     a_cts00m03[arr_aux].srrabvnom)
           returning a_cts00m03[arr_aux].srrcoddig

       if a_cts00m03[arr_aux].srrcoddig  is not null   then
          next field srrcoddig
       else
          error " Codigo ou nome abreviado do socorrista deve ser informado!"
          next field srrabvnom
       end if

    before field ufdcod_gps
         display a_cts00m03[arr_aux].ufdcod_gps  to
                 s_cts00m03[scr_aux].ufdcod_gps  attribute (reverse)

    after field ufdcod_gps
       display a_cts00m03[arr_aux].ufdcod_gps  to
               s_cts00m03[scr_aux].ufdcod_gps

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field srrcoddig
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field ufdcod_gps
          end if
       end if

       if a_cts00m03[arr_aux].ufdcod_gps  is null   and
          a_cts00m03[arr_aux].c24atvcod   =  "QTP"  then
          let a_cts00m03[arr_aux].ufdcod_gps  =  "  "
          let a_cts00m03[arr_aux].cidnom_gps  =  "  "
          let a_cts00m03[arr_aux].brrnom_gps  =  "  "
          let a_cts00m03[arr_aux].endzon_gps  =  "  "
          initialize a_cts00m03b[arr_aux].lclltt_gps  to null
          initialize a_cts00m03b[arr_aux].lcllgt_gps  to null
          display a_cts00m03[arr_aux].ufdcod_gps to
                  s_cts00m03[scr_aux].ufdcod_gps
          display a_cts00m03[arr_aux].cidnom_gps to
                  s_cts00m03[scr_aux].cidnom_gps
          display a_cts00m03[arr_aux].brrnom_gps to
                  s_cts00m03[scr_aux].brrnom_gps
          display a_cts00m03[arr_aux].endzon_gps to
                  s_cts00m03[scr_aux].endzon_gps
          next field endzon_gps
       end if

       if a_cts00m03[arr_aux].ufdcod_gps  is null   then
          let a_cts00m03[arr_aux].ufdcod_gps  = "    "
       end if

       if a_cts00m03[arr_aux].c24atvcod  <>  "QTP" or
          a_cts00m03[arr_aux].c24atvcod  <>  "NIL" then
          if a_cts00m03[arr_aux].ufdcod_gps  =  "  "   then
             error " Unidade federativa deve ser informada!"
             next field ufdcod_gps
          end if
       end if

       if a_cts00m03[arr_aux].ufdcod_gps  is not null   and
          a_cts00m03[arr_aux].ufdcod_gps  <>  "  "      then
          select ufdcod
            from glakest
           where ufdcod  =  a_cts00m03[arr_aux].ufdcod_gps

          if sqlca.sqlcode  =  notfound   then
             error " Unidade federativa nao cadastrada!"
             next field ufdcod_gps
          end if
       end if

       if a_cts00m03[arr_aux].ufdcod_gps  <>  ws2.ufdcod_gps   then
          initialize a_cts00m03b[arr_aux].lclltt_gps  to null
          initialize a_cts00m03b[arr_aux].lcllgt_gps  to null
       end if

    before field cidnom_gps
         display a_cts00m03[arr_aux].cidnom_gps  to
                 s_cts00m03[scr_aux].cidnom_gps  attribute (reverse)

    after field cidnom_gps
       display a_cts00m03[arr_aux].cidnom_gps  to
               s_cts00m03[scr_aux].cidnom_gps

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field ufdcod_gps
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field cidnom_gps
          end if
       end if

       if a_cts00m03[arr_aux].cidnom_gps  is null   then
          let a_cts00m03[arr_aux].cidnom_gps  = "    "
       end if

       if a_cts00m03[arr_aux].cidnom_gps    =  "    "   then
          if a_cts00m03[arr_aux].c24atvcod  <> "QTP" or
             a_cts00m03[arr_aux].c24atvcod  <> "NIL" then
             error " Cidade deve ser informada!"
             next field cidnom_gps
          end if
       end if

       if a_cts00m03[arr_aux].ufdcod_gps  <> "  "     and
          a_cts00m03[arr_aux].cidnom_gps  =  "    "   then
          error " Cidade deve ser informada!"
          next field cidnom_gps
       end if

       if a_cts00m03[arr_aux].ufdcod_gps  =  "  "     and
          a_cts00m03[arr_aux].cidnom_gps  <> "    "   then
          error " Unidade federativa deve ser informada!"
          next field cidnom_gps
       end if

       if a_cts00m03[arr_aux].cidnom_gps  <>  ws2.cidnom_gps   then
          initialize a_cts00m03b[arr_aux].lclltt_gps  to null
          initialize a_cts00m03b[arr_aux].lcllgt_gps  to null
       end if

    before field brrnom_gps
       display a_cts00m03[arr_aux].brrnom_gps  to
               s_cts00m03[scr_aux].brrnom_gps  attribute (reverse)

    after field brrnom_gps
       display a_cts00m03[arr_aux].brrnom_gps  to
               s_cts00m03[scr_aux].brrnom_gps

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field cidnom_gps
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field brrnom_gps
          end if
       end if

       if a_cts00m03[arr_aux].brrnom_gps  is null   then
          let a_cts00m03[arr_aux].brrnom_gps  =  "    "
       end if

       if a_cts00m03[arr_aux].brrnom_gps  =  "    "   then
          if a_cts00m03[arr_aux].c24atvcod  <> "QTP" or
             a_cts00m03[arr_aux].c24atvcod  <> "NIL" then
             error " Bairro deve ser informado!"
             next field brrnom_gps
          end if
       end if

       if a_cts00m03[arr_aux].cidnom_gps  <> "  "     and
          a_cts00m03[arr_aux].brrnom_gps  =  "    "   then
          error " Bairro deve ser informado!"
          next field brrnom_gps
       end if

       if a_cts00m03[arr_aux].cidnom_gps  =  "  "     and
          a_cts00m03[arr_aux].brrnom_gps  <> "    "   then
          error " Cidade deve ser informada!"
          next field brrnom_gps
       end if

       if a_cts00m03[arr_aux].brrnom_gps  <>  ws2.brrnom_gps   then
          initialize a_cts00m03b[arr_aux].lclltt_gps  to null
          initialize a_cts00m03b[arr_aux].lcllgt_gps  to null
       end if

    before field endzon_gps
         display a_cts00m03[arr_aux].endzon_gps  to
                 s_cts00m03[scr_aux].endzon_gps  attribute (reverse)

    after field endzon_gps
       display a_cts00m03[arr_aux].endzon_gps  to
               s_cts00m03[scr_aux].endzon_gps

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field brrnom_gps
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field endzon_gps
          end if
       end if

       if a_cts00m03[arr_aux].endzon_gps  is null   then
          let a_cts00m03[arr_aux].endzon_gps  =  "    "
       end if

       if a_cts00m03[arr_aux].endzon_gps  is not null   and
          a_cts00m03[arr_aux].endzon_gps  <>  "  "      then

          if a_cts00m03[arr_aux].endzon_gps  <>  "NO"   and
             a_cts00m03[arr_aux].endzon_gps  <>  "SU"   and
             a_cts00m03[arr_aux].endzon_gps  <>  "LE"   and
             a_cts00m03[arr_aux].endzon_gps  <>  "OE"   and
             a_cts00m03[arr_aux].endzon_gps  <>  "CE"   then
             error " Codigo da zona invalido!"
             next field endzon_gps
          end if

       end if

    before field ufdcod_qth
         display a_cts00m03[arr_aux].ufdcod_qth  to
                 s_cts00m03[scr_aux].ufdcod_qth  attribute (reverse)

    after field ufdcod_qth
       display a_cts00m03[arr_aux].ufdcod_qth  to
               s_cts00m03[scr_aux].ufdcod_qth

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field endzon_gps
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field ufdcod_qth
          end if
       end if

       if a_cts00m03[arr_aux].ufdcod_qth  is null   then
          let a_cts00m03[arr_aux].ufdcod_qth  =  "  "
          let a_cts00m03[arr_aux].cidnom_qth  =  "  "
          let a_cts00m03[arr_aux].brrnom_qth  =  "  "
          let a_cts00m03[arr_aux].endzon_qth  =  "  "
          initialize a_cts00m03b[arr_aux].lclltt_qth  to null
          initialize a_cts00m03b[arr_aux].lcllgt_qth  to null
          display a_cts00m03[arr_aux].ufdcod_qth to
                  s_cts00m03[scr_aux].ufdcod_qth
          display a_cts00m03[arr_aux].cidnom_qth to
                  s_cts00m03[scr_aux].cidnom_qth
          display a_cts00m03[arr_aux].brrnom_qth to
                  s_cts00m03[scr_aux].brrnom_qth
          display a_cts00m03[arr_aux].endzon_qth to
                  s_cts00m03[scr_aux].endzon_qth
          next field endzon_qth
       end if

       if a_cts00m03[arr_aux].ufdcod_qth  is not null   and
          a_cts00m03[arr_aux].ufdcod_qth  <>  "  "      then
          select ufdcod
            from glakest
           where ufdcod  =  a_cts00m03[arr_aux].ufdcod_qth

          if sqlca.sqlcode  =  notfound   then
             error " Unidade federativa nao cadastrada!"
             next field ufdcod_qth
          end if
       end if

       if a_cts00m03[arr_aux].ufdcod_qth  <>  ws2.ufdcod_qth   then
          initialize a_cts00m03b[arr_aux].lclltt_qth  to null
          initialize a_cts00m03b[arr_aux].lcllgt_qth  to null
       end if

    before field cidnom_qth
         display a_cts00m03[arr_aux].cidnom_qth  to
                 s_cts00m03[scr_aux].cidnom_qth  attribute (reverse)

    after field cidnom_qth
       display a_cts00m03[arr_aux].cidnom_qth  to
               s_cts00m03[scr_aux].cidnom_qth

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field ufdcod_qth
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field cidnom_qth
          end if
       end if

       if a_cts00m03[arr_aux].cidnom_qth  is null   then
          let a_cts00m03[arr_aux].cidnom_qth  =  "    "
       end if

       if a_cts00m03[arr_aux].ufdcod_qth  <> "  "     and
          a_cts00m03[arr_aux].cidnom_qth  =  "    "   then
          error " Cidade deve ser informada!"
          next field cidnom_qth
       end if

       if a_cts00m03[arr_aux].ufdcod_qth  =  "  "     and
          a_cts00m03[arr_aux].cidnom_qth  <> "    "   then
          error " Unidade federativa deve ser informada!"
          next field cidnom_qth
       end if

       if a_cts00m03[arr_aux].cidnom_qth  <>  ws2.cidnom_qth   then
          initialize a_cts00m03b[arr_aux].lclltt_qth  to null
          initialize a_cts00m03b[arr_aux].lcllgt_qth  to null
       end if

    before field brrnom_qth
       display a_cts00m03[arr_aux].brrnom_qth  to
               s_cts00m03[scr_aux].brrnom_qth  attribute (reverse)

    after field brrnom_qth
       display a_cts00m03[arr_aux].brrnom_qth  to
               s_cts00m03[scr_aux].brrnom_qth

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field cidnom_qth
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field brrnom_qth
          end if
       end if

       if a_cts00m03[arr_aux].brrnom_qth  is null   then
          let a_cts00m03[arr_aux].brrnom_qth  =  "    "
       end if

       if a_cts00m03[arr_aux].cidnom_qth  <> "   "   and
          a_cts00m03[arr_aux].brrnom_qth  =  "   "   then
          error " Bairro deve ser informado!"
          next field brrnom_qth
       end if

       if a_cts00m03[arr_aux].cidnom_qth  =  "   "   and
          a_cts00m03[arr_aux].brrnom_qth  <> "   "   then
          error " Cidade deve ser informada!"
          next field brrnom_qth
       end if

       if a_cts00m03[arr_aux].brrnom_qth  <>  ws2.brrnom_qth   then
          initialize a_cts00m03b[arr_aux].lclltt_qth  to null
          initialize a_cts00m03b[arr_aux].lcllgt_qth  to null
       end if

    before field endzon_qth
         display a_cts00m03[arr_aux].endzon_qth  to
                 s_cts00m03[scr_aux].endzon_qth  attribute (reverse)

    after field endzon_qth
       display a_cts00m03[arr_aux].endzon_qth  to
               s_cts00m03[scr_aux].endzon_qth

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field brrnom_qth
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field endzon_qth
          end if
       end if

       if a_cts00m03[arr_aux].endzon_qth  is null   then
          let a_cts00m03[arr_aux].endzon_qth  = "    "
       end if

       if a_cts00m03[arr_aux].endzon_qth  is not null   and
          a_cts00m03[arr_aux].endzon_qth  <>  "  "      then

          if a_cts00m03[arr_aux].endzon_qth  <>  "NO"   and
             a_cts00m03[arr_aux].endzon_qth  <>  "SU"   and
             a_cts00m03[arr_aux].endzon_qth  <>  "LE"   and
             a_cts00m03[arr_aux].endzon_qth  <>  "OE"   and
             a_cts00m03[arr_aux].endzon_qth  <>  "CE"   then
             error " Codigo da zona invalido!"
             next field endzon_qth
          end if

       end if

    before field ufdcod_qti
         display a_cts00m03[arr_aux].ufdcod_qti  to
                 s_cts00m03[scr_aux].ufdcod_qti  attribute (reverse)

    after field ufdcod_qti
       display a_cts00m03[arr_aux].ufdcod_qti  to
               s_cts00m03[scr_aux].ufdcod_qti

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field endzon_qth
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field ufdcod_qti
          end if
       end if

       if a_cts00m03[arr_aux].ufdcod_qti  is null   then
          let a_cts00m03[arr_aux].ufdcod_qti  =  "  "
          let a_cts00m03[arr_aux].cidnom_qti  =  "  "
          let a_cts00m03[arr_aux].brrnom_qti  =  "  "
          let a_cts00m03[arr_aux].endzon_qti  =  "  "
          display a_cts00m03[arr_aux].ufdcod_qti to
                  s_cts00m03[scr_aux].ufdcod_qti
          display a_cts00m03[arr_aux].cidnom_qti to
                  s_cts00m03[scr_aux].cidnom_qti
          display a_cts00m03[arr_aux].brrnom_qti to
                  s_cts00m03[scr_aux].brrnom_qti
          display a_cts00m03[arr_aux].endzon_qti to
                  s_cts00m03[scr_aux].endzon_qti
          next field endzon_qti
       end if

       if a_cts00m03[arr_aux].ufdcod_qti  is not null   and
          a_cts00m03[arr_aux].ufdcod_qti  <>  "  "      then
          select ufdcod
            from glakest
           where ufdcod  =  a_cts00m03[arr_aux].ufdcod_qti

          if sqlca.sqlcode  =  notfound   then
             error " Unidade federativa nao cadastrada!"
             next field ufdcod_qti
          end if
       end if

    before field cidnom_qti
         display a_cts00m03[arr_aux].cidnom_qti  to
                 s_cts00m03[scr_aux].cidnom_qti  attribute (reverse)

    after field cidnom_qti
       display a_cts00m03[arr_aux].cidnom_qti  to
               s_cts00m03[scr_aux].cidnom_qti

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field ufdcod_qti
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field cidnom_qti
          end if
       end if

       if a_cts00m03[arr_aux].cidnom_qti  is null   then
          let a_cts00m03[arr_aux].cidnom_qti  = "    "
       end if

       if a_cts00m03[arr_aux].ufdcod_qti  <> "  "     and
          a_cts00m03[arr_aux].cidnom_qti  =  "    "   then
          error " Cidade deve ser informada!"
          next field cidnom_qti
       end if

       if a_cts00m03[arr_aux].ufdcod_qti  =  "  "     and
          a_cts00m03[arr_aux].cidnom_qti  <> "    "   then
          error " Unidade federativa deve ser informada!"
          next field cidnom_qti
       end if

       if a_cts00m03[arr_aux].cidnom_qti  <>  ws2.cidnom_qti   then
          initialize a_cts00m03b[arr_aux].lclltt_qti  to null
          initialize a_cts00m03b[arr_aux].lcllgt_qti  to null
       end if

    before field brrnom_qti
       display a_cts00m03[arr_aux].brrnom_qti  to
               s_cts00m03[scr_aux].brrnom_qti  attribute (reverse)

    after field brrnom_qti
       display a_cts00m03[arr_aux].brrnom_qti  to
               s_cts00m03[scr_aux].brrnom_qti

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field cidnom_qti
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field brrnom_qti
          end if
       end if

       if a_cts00m03[arr_aux].brrnom_qti  is null   then
          let a_cts00m03[arr_aux].brrnom_qti  =  "    "
       end if

       if a_cts00m03[arr_aux].cidnom_qti  <> "  "    and
          a_cts00m03[arr_aux].brrnom_qti  =  "   "   then
          error " Bairro deve ser informado!"
          next field brrnom_qti
       end if

       if a_cts00m03[arr_aux].cidnom_qti  =  "  "    and
          a_cts00m03[arr_aux].brrnom_qti  <> "   "   then
          error " Cidade deve ser informada!"
          next field brrnom_qti
       end if

       if a_cts00m03[arr_aux].brrnom_qti  <>  ws2.brrnom_qti   then
          initialize a_cts00m03b[arr_aux].lclltt_qti  to null
          initialize a_cts00m03b[arr_aux].lcllgt_qti  to null
       end if

    before field endzon_qti
         display a_cts00m03[arr_aux].endzon_qti  to
                 s_cts00m03[scr_aux].endzon_qti  attribute (reverse)

    after field endzon_qti
       display a_cts00m03[arr_aux].endzon_qti  to
               s_cts00m03[scr_aux].endzon_qti

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field brrnom_qti
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field endzon_qti
          end if
       end if

       if a_cts00m03[arr_aux].endzon_qti  is null   then
          let a_cts00m03[arr_aux].endzon_qti  = "    "
       end if

       if a_cts00m03[arr_aux].endzon_qti  is not null   and
          a_cts00m03[arr_aux].endzon_qti  <>  "  "      then

          if a_cts00m03[arr_aux].endzon_qti  <>  "NO"   and
             a_cts00m03[arr_aux].endzon_qti  <>  "SU"   and
             a_cts00m03[arr_aux].endzon_qti  <>  "LE"   and
             a_cts00m03[arr_aux].endzon_qti  <>  "OE"   and
             a_cts00m03[arr_aux].endzon_qti  <>  "CE"   then
             error " Codigo da zona invalido!"
             next field endzon_qti
          end if

       end if

    before field obspostxt
         display a_cts00m03[arr_aux].obspostxt  to
                 s_cts00m03[scr_aux].obspostxt  attribute (reverse)

    after field obspostxt
       display a_cts00m03[arr_aux].obspostxt  to
               s_cts00m03[scr_aux].obspostxt

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field endzon_qti
       end if

       if fgl_lastkey() = fgl_keyval("down")   then
          if a_cts00m03[arr_aux + 1].atdvclsgl  is null   then
             error " Nao existem linhas nesta direcao!"
             next field obspostxt
          end if
       end if

       if a_cts00m03[arr_aux].obspostxt  is null   then
          let a_cts00m03[arr_aux].obspostxt  =  "    "
       end if

    on key (interrupt)
       exit input

    on key (f6)   #--> F6-Atualiza        # 20.01.12 SM-2012-00756
       let l_refresh = true
       call cts40g03_data_hora_banco(2) returning l_caddat, l_newhoraatu
       display l_newhoraatu  to horaatu
       exit input

    on key (F7)
       call cts24m00()

    #---------------------------------------------------------#
    # Consulta e exibe as Naturezas atendidas pelos prestadores
    #---------------------------------------------------------#
    on key (f2)

       let l_posicao = arr_curr()

       call cts00m03_exibe_natz_atend(a_cts00m03[l_posicao].srrcoddig, a_cts00m03[l_posicao].socvclcod)

    #---------------------------------------------------------------
    # Chamada das telas de laudo de servicos
    #---------------------------------------------------------------
    on key (F8)
       let arr_aux = arr_curr()
       if a_cts00m03[arr_aux].atdsrvnum  is null   then
          error " Veiculo nao possui servico vinculado!"
          continue input
       else
          let g_documento.atdsrvnum = a_cts00m03[arr_aux].atdsrvnum
          let g_documento.atdsrvano = a_cts00m03[arr_aux].atdsrvano
          if cts04g00('cts00m03') = true  then
             error ""
          end if
          initialize g_documento.atdsrvnum  to null
          initialize g_documento.atdsrvano  to null
          let int_flag = false
          continue input
       end if

    #---------------------------------------------------------------
    # Consulta mensagens recebidas dos MDTs
    #---------------------------------------------------------------
    on key (F9)
       let arr_aux = arr_curr()
       call ctn44c00(2, a_cts00m03[arr_aux].atdvclsgl,"")
       continue input

    #---------------------------------------------------------------
    # Verifica ultima atividade por viatura
    #---------------------------------------------------------------
    on key (F10)
       let arr_aux = arr_curr()
       call cts00m32(a_cts00m03[arr_aux].socvclcod)

      after row
         case ws2.operacao
            when "a"
               if a_cts00m03[arr_aux].c24atvcod  = ws2.c24atvcod   and
                  a_cts00m03[arr_aux].srrcoddig  = ws2.srrcoddig   and
                  a_cts00m03[arr_aux].obspostxt  = ws2.obspostxt   and
                  a_cts00m03[arr_aux].ufdcod_gps = ws2.ufdcod_gps  and
                  a_cts00m03[arr_aux].cidnom_gps = ws2.cidnom_gps  and
                  a_cts00m03[arr_aux].brrnom_gps = ws2.brrnom_gps  and
                  a_cts00m03[arr_aux].endzon_gps = ws2.endzon_gps  and
                  a_cts00m03[arr_aux].ufdcod_qth = ws2.ufdcod_qth  and
                  a_cts00m03[arr_aux].cidnom_qth = ws2.cidnom_qth  and
                  a_cts00m03[arr_aux].brrnom_qth = ws2.brrnom_qth  and
                  a_cts00m03[arr_aux].endzon_qth = ws2.endzon_qth  and
                  a_cts00m03[arr_aux].ufdcod_qti = ws2.ufdcod_qti  and
                  a_cts00m03[arr_aux].cidnom_qti = ws2.cidnom_qti  and
                  a_cts00m03[arr_aux].brrnom_qti = ws2.brrnom_qti  and
                  a_cts00m03[arr_aux].endzon_qti = ws2.endzon_qti  then
                  continue input
               end if
               
               if fgl_lastkey() = fgl_keyval("up")   or
                  fgl_lastkey() = fgl_keyval("left") then
                  continue input
               end if

               # Veirifca se o AcionamentoWeb esta ativo e o veiculo e controlado pelo portosocorro
               open ccts00m03029  using a_cts00m03[arr_aux].socvclcod
               whenever error continue
                  fetch ccts00m03029 into l_frtrpnflg
               whenever error stop
               if sqlca.sqlcode <> 0  then
                  let l_frtrpnflg = 1
               end if
               close ccts00m03029               
               
               if ctx34g00_ver_acionamentoWEB(2) and (l_frtrpnflg = 1 or l_frtrpnflg = 3) then
 
                  select cttdat, ctthor, atdsrvnum, atdsrvano
                         into l_cttdat, l_ctthor, l_atdsrvnum, l_atdsrvano
                    from dattfrotalocal
                   where socvclcod = a_cts00m03[arr_aux].socvclcod
                   
                  if a_cts00m03[arr_aux].c24atvcod  <>  ws2.c24atvcod   then
                     select today, current
                            into l_cttdat, l_ctthor
                       from dual
                  end if
                    
                  call ctx34g02_atualizacao_recurso(a_cts00m03[arr_aux].pstcoddig,
                                                    a_cts00m03[arr_aux].socvclcod,
                                                    a_cts00m03[arr_aux].srrcoddig,
                                                    a_cts00m03[arr_aux].c24atvcod,
                                                    l_cttdat, 
                                                    l_ctthor,
                                                    l_atdsrvnum,
                                                    l_atdsrvano,
                                                    a_cts00m03[arr_aux].ufdcod_gps,
                                                    a_cts00m03[arr_aux].cidnom_gps,
                                                    a_cts00m03[arr_aux].brrnom_gps,
                                                    a_cts00m03[arr_aux].obspostxt,
                                                    g_issk.usrtip,
                                                    g_issk.empcod,
                                                    g_issk.funmat)
                       returning l_resultado,
                                 l_mensagem
               else
                  begin work
                  
                    if a_cts00m03[arr_aux].c24atvcod  =  ws2.c24atvcod   then
                       update dattfrotalocal set
                              atlemp    = g_issk.empcod,
                              atlmat    = g_issk.funmat,
                              srrcoddig = a_cts00m03[arr_aux].srrcoddig,
                              obspostxt = a_cts00m03[arr_aux].obspostxt
                        where
                              socvclcod = a_cts00m03[arr_aux].socvclcod
                  
                    else
                  
                          if a_cts00m03[arr_aux].c24atvcod  =  "REC" OR
                             a_cts00m03[arr_aux].c24atvcod  =  "INI" OR
                             a_cts00m03[arr_aux].c24atvcod  =  "FIM" THEN
                             update dattfrotalocal set
                                    atlemp       = g_issk.empcod,
                                    atlmat       = g_issk.funmat,
                                    srrcoddig    = a_cts00m03[arr_aux].srrcoddig,
                                    obspostxt    = a_cts00m03[arr_aux].obspostxt,
                                    #atdsrvnum    = ws2.null,
                                    #atdsrvano    = ws2.null,
                                    #mdtmvtvlc    = ws2.null,
                                    #mdtmvtdircod = ws2.null,
                                    cttdat       = today,
                                    ctthor       = par2.horaatu,
                                    c24atvcod = a_cts00m03[arr_aux].c24atvcod
                              where
                                    socvclcod = a_cts00m03[arr_aux].socvclcod
                          else
                             update dattfrotalocal set
                                    atlemp       = g_issk.empcod,
                                    atlmat       = g_issk.funmat,
                                    srrcoddig    = a_cts00m03[arr_aux].srrcoddig,
                                    obspostxt    = a_cts00m03[arr_aux].obspostxt,
                                    atdsrvnum    = ws2.null,
                                    atdsrvano    = ws2.null,
                                    mdtmvtvlc    = ws2.null,
                                    mdtmvtdircod = ws2.null,
                                    cttdat       = today,
                                    ctthor       = par2.horaatu,
                                    c24atvcod = a_cts00m03[arr_aux].c24atvcod
                              where
                                    socvclcod = a_cts00m03[arr_aux].socvclcod
                          end if
                  
                  
                    end if
                  
                    update datmfrtpos set
                           ufdcod = a_cts00m03[arr_aux].ufdcod_gps,
                           cidnom = a_cts00m03[arr_aux].cidnom_gps,
                           brrnom = a_cts00m03[arr_aux].brrnom_gps,
                           endzon = a_cts00m03[arr_aux].endzon_gps,
                           lclltt = a_cts00m03b[arr_aux].lclltt_gps,
                           lcllgt = a_cts00m03b[arr_aux].lcllgt_gps,
                           atldat = today,
                           atlhor = current hour to second
                     where
                           socvclcod    = a_cts00m03[arr_aux].socvclcod
                       and socvcllcltip = 1
                  
                    update datmfrtpos set
                           ufdcod = a_cts00m03[arr_aux].ufdcod_qth,
                           cidnom = a_cts00m03[arr_aux].cidnom_qth,
                           brrnom = a_cts00m03[arr_aux].brrnom_qth,
                           endzon = a_cts00m03[arr_aux].endzon_qth,
                           lclltt = a_cts00m03b[arr_aux].lclltt_qth,
                           lcllgt = a_cts00m03b[arr_aux].lcllgt_qth,
                           atldat = today,
                           atlhor = current hour to second
                     where
                           socvclcod    = a_cts00m03[arr_aux].socvclcod
                       and socvcllcltip = 2
                  
                    update datmfrtpos set
                           ufdcod = a_cts00m03[arr_aux].ufdcod_qti,
                           cidnom = a_cts00m03[arr_aux].cidnom_qti,
                           brrnom = a_cts00m03[arr_aux].brrnom_qti,
                           endzon = a_cts00m03[arr_aux].endzon_qti,
                           lclltt = a_cts00m03b[arr_aux].lclltt_qti,
                           lcllgt = a_cts00m03b[arr_aux].lcllgt_qti,
                           atldat = today,
                           atlhor = current hour to second
                     where
                           socvclcod    = a_cts00m03[arr_aux].socvclcod
                       and socvcllcltip = 3
                  
                  commit work
               
               end if
            
         end case

         let ws2.operacao = " "
   end input

   options
      delete key f2

   if l_refresh then               # 20.01.12 SM-2012-00756
      for arr_aux = 1 to 2
         clear s_cts00m03[arr_aux].*
         display " " to s_cts00m03[arr_aux].tipposcab
      end for
      continue while
   end if
 end if


 #----------------------------------------------------------
 # Limpa tela (array)
 #----------------------------------------------------------
 if ws2.f8flg  =  "S"  then
       whenever error continue
       set lock mode to not wait
       begin work
          update datkveiculo
             set   socacsflg = "1",
                   c24opemat = g_issk.funmat,
                   c24opeempcod = g_issk.empcod,
                   c24opeusrtip = g_issk.usrtip
             where socvclcod = a_cts00m03[arr_aux].socvclcod
               and socacsflg = "0"

          if sqlca.sqlcode <> 0  then
             if sqlca.sqlcode = -243 or
                sqlca.sqlcode = -245 or
                sqlca.sqlcode = -246 then
                error " Veiculo em acionamento !"
             else
                error " Erro (", sqlca.sqlcode, ")",
                      " na atz. do veiculo. AVISE A INFORMATICA!"
             end if
             rollback work
             prompt "" for char prompt_key
             exit while
          else
             if sqlca.sqlerrd[3] = 0 then
                rollback work

                 select c24opemat,
                        c24opeempcod,
                        c24opeusrtip
                   into ws1.c24opemat,
                        ws1.c24opeempcod,
                        ws1.c24opeusrtip
                   from datkveiculo
                  where datkveiculo.atdvclsgl = a_cts00m03[arr_aux].atdvclsgl

                 if sqlca.sqlcode  <>  0   then
                    if sqlca.sqlcode = -243 or
                       sqlca.sqlcode = -245 or
                       sqlca.sqlcode = -246 then
                       error " Veiculo em acionamento!"
                    else
                       error " Veiculo nao cadastrado!"
                    end if
                 else
                    select funnom into ws1.funnom
                      from isskfunc
                     where funmat = ws1.c24opemat
                       and empcod = ws1.c24opeempcod
                       and usrtip = ws1.c24opeusrtip
                    if sqlca.sqlcode = 0 then
                       error "Veiculo sendo acionado por: ",ws1.funnom clipped
                    end if
                 end if

                prompt "" for char prompt_key
                continue while
             end if
          end if

      #Atualizar o prestador no servico
      call cts10g09_registrar_prestador(1, par2.atdsrvnum
                                       ,par2.atdsrvano
                                       ,a_cts00m03[arr_aux].socvclcod
                                       ,a_cts00m03[arr_aux].srrcoddig
                                       ,a_cts00m03b[arr_aux].lclltt_gps
                                       ,a_cts00m03b[arr_aux].lcllgt_gps, "")
         returning l_resultado, l_mensagem

      if l_resultado <> 1 then
         error l_mensagem
         rollback work
         prompt "" for char prompt_key
         exit while
      end if

      #Obter os servicos multiplos do original.
      call cts29g00_obter_multiplo(2, par2.atdsrvnum, par2.atdsrvano)
         returning l_resultado
                  ,l_mensagem
                  ,al_cts29g00[1].*
                  ,al_cts29g00[2].*
                  ,al_cts29g00[3].*
                  ,al_cts29g00[4].*
                  ,al_cts29g00[5].*
                  ,al_cts29g00[6].*
                  ,al_cts29g00[7].*
                  ,al_cts29g00[8].*
                  ,al_cts29g00[9].*
                  ,al_cts29g00[10].*

      if l_resultado = 3 then
         error l_mensagem
         rollback work
         prompt "" for char prompt_key
         exit while
      end if

      if l_resultado = 1 then

         #Atualizar o prestador no servico multiplo
         for l_aux = 1 to 10
            if al_cts29g00[l_aux].atdmltsrvnum is not null then
               call cts10g09_registrar_prestador(1,
                                                 al_cts29g00[l_aux].atdmltsrvnum
                                                ,al_cts29g00[l_aux].atdmltsrvano
                                                ,a_cts00m03[arr_aux].socvclcod
                                                ,a_cts00m03[arr_aux].srrcoddig
                                                ,a_cts00m03b[arr_aux].lclltt_gps
                                                ,a_cts00m03b[arr_aux].lcllgt_gps, "")
                  returning l_resultado, l_mensagem

               if l_resultado <> 1 then
                  exit for
               end if
            end if
         end for

         if l_resultado <> 1 then
            error l_mensagem
            rollback work
            prompt "" for char prompt_key
            exit while
         end if

      end if

       commit work
       set lock mode to wait
       whenever error stop
       let ws2.flag_cts00m02 = 1

    let ws2.pstcoddig = a_cts00m03[arr_aux].pstcoddig
    let ws2.atdvclsgl = a_cts00m03[arr_aux].atdvclsgl
    let ws2.srrcoddig = a_cts00m03[arr_aux].srrcoddig
    exit while
 else
    for arr_aux = 1 to 2
       clear s_cts00m03[arr_aux].*
       display " " to s_cts00m03[arr_aux].tipposcab
    end for
    exit while
 end if
 if ws2.operacao = 2 then
    exit while
 end if

 END WHILE

 let int_flag = false
 close ccts00m03014

 return ws2.pstcoddig,
        ws2.atdvclsgl,
        ws2.srrcoddig,
        a_cts00m03[arr_aux].socvclcod,
        ws2.flag_cts00m02

end function  ###--  cts00m03_posicao

##---------------------------------------------------------------------
# function cts00m03_calcula(lr_parametro)   ## Calcula tempo na atividade #substituido - chamado 7044206
##---------------------------------------------------------------------
#
# define  lr_parametro  record
#    horafim      datetime hour to minute, ##hora de inicio
#    datafim      char(10),                ##da de inicio
#    horaini      datetime hour to minute  ##hora atual
# end record
#
# define lr_dados      record
#         resdat       integer,
#         reshor       interval hour(5) to minute,
#         chrhor       char(10),
#         dataini      date,
#         tempo        char(10),
#         tempod       dec(3,0)
# end record
#
# initialize lr_dados to null
# let lr_dados.dataini = today
#
#  let lr_dados.resdat = (lr_parametro.datafim - lr_dados.dataini) * 24
#  let lr_dados.reshor = (lr_parametro.horaini - lr_parametro.horafim)
#
#  let lr_dados.chrhor = lr_dados.resdat using "###&" , ":00"
#  let lr_dados.reshor = (lr_dados.reshor + lr_dados.chrhor)
#
#  let lr_dados.tempo = lr_dados.reshor
#  let lr_dados.tempo = lr_dados.tempo[4,10]
#  let lr_dados.tempod =  lr_dados.tempo[1,3]  using  "&&&"
#
#  return lr_dados.tempo, lr_dados.tempod
#
#end function  ###-- cts00m03_calcula


###---------------------------------------------------------------------
## function cts00m03_calcula(par3)   ## Calcula tempo na atividade
###---------------------------------------------------------------------
##
## define  par3    record
##    hora         datetime hour to minute,
##    data         char(10),
##    horaatu      datetime hour to minute
## end record
##
## define  ws_h24     datetime hour to minute
## define  ret_tempo  char(06)
## define  ret_tempod dec(3,0)
##
## display "Hora passada para a função --> ", par3.hora
## display "Data passada para a função --> ", par3.data
## display "Hora atual passada para o programa --> ", par3.horaatu
##
##
##
###@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
##
##        let     ws_h24  =  null
##        let     ret_tempo  =  null
##        let     ret_tempod  =  null
##
##        let     ws_h24  =  null
##        let     ret_tempo  =  null
##        let     ret_tempod  =  null
##
## if par3.data  is not null  and
##    par3.data    <=  today   then
##    if par3.data  =  today   then
##       let ret_tempo  =  par3.horaatu - par3.hora
##       let ret_tempod =  ret_tempo[1,3]  using  "&&&"
##    else
##       let ws_h24     =  "23:59"
##       let ret_tempo  =  ws_h24 - par3.hora
##       let ws_h24     =  "00:00"
##       let ret_tempo  =  ret_tempo + (par3.horaatu - ws_h24) + "00:01"
##       let ret_tempod =  ret_tempo[1,3]  using  "&&&"
##    end if
## end if
##
## return ret_tempo, ret_tempod
##
##end function  ###-- cts00m03_calcula


#---------------------------------------------------------------------
 function cts00m03_contadores(par4)   ## Contadores por atividade
#---------------------------------------------------------------------

 define  par4    record
    vcldtbgrpcod like dattfrotalocal.vcldtbgrpcod
 end record

 define ws4      record
    qru          dec  (4,0),
    qrv          dec  (4,0),
    qrx          dec  (4,0),
    qrxt         dec  (4,0),
    qtp          dec  (4,0),
    rec          dec  (4,0),
    ini          dec  (4,0),
    rem          dec  (4,0),
    fim          dec  (4,0),
    ret          dec  (4,0),
    rod          dec  (4,0),
    nil          dec  (4,0),
    count        dec  (4,0),
    cabec1       char (70),
    cabec2       char (70),
    c24atvcod    like dattfrotalocal.c24atvcod
 end record

 define l_sql    char(500)
 define l_filtro char(200)




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws4.*  to  null

        initialize  ws4.*  to  null

 initialize ws4.*  to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#
 let l_sql    = null
 let l_filtro = null

 let ws4.qru  = 0
 let ws4.qrv  = 0
 let ws4.qrx  = 0
 let ws4.qrxt = 0
 let ws4.qtp  = 0
 let ws4.rec  = 0
 let ws4.ini  = 0
 let ws4.rem  = 0
 let ws4.fim  = 0
 let ws4.ret  = 0
 let ws4.rod  = 0
 let ws4.nil  = 0

 ## CT 307300
{
 declare c_cts00m03_002 cursor for
    select dattfrotalocal.c24atvcod,
           count(*)
      from dattfrotalocal
     where dattfrotalocal.vcldtbgrpcod  =  par4.vcldtbgrpcod
     group by c24atvcod
}
 #--> preparar contagem por Grupo ou Todos os Grupos PSI-2011-21009 13.12.11
 if par4.vcldtbgrpcod is null  or
    par4.vcldtbgrpcod  = 0     then
    let l_filtro = "in (select vcldtbgrpcod "
                       ," from datkvcldtbgrp "
                      ," where vcldtbgrpstt = 'A' )"
 else
    let l_filtro = "= ", par4.vcldtbgrpcod
 end if

 let l_sql = "select t.c24atvcod, count(*) "
             ," from datkveiculo v, dattfrotalocal t, dpaksocor s "
             ," where v.socvclcod    = t.socvclcod "
               ," and v.pstcoddig    = s.pstcoddig "
               ," and t.vcldtbgrpcod ", l_filtro clipped
               ," and v.socacsflg    = '0' "
               ," and v.socoprsitcod = '1' "
               ," and s.frtrpnflg   != '2' "
             ," group by t.c24atvcod "

 prepare p_cts00m03_002 from l_sql
 declare c_cts00m03_002 cursor for p_cts00m03_002
 foreach c_cts00m03_002  into  ws4.c24atvcod,
                            ws4.count
    case ws4.c24atvcod
         when "QRV"
              let ws4.qrv = ws4.count
         when "QRU"
              let ws4.qru = ws4.count
         when "QRX"
#              if ???
              let ws4.qrx = ws4.count
#              else
#              let ws4.qrxt = ws4.count
#              end if
         when "QTP"
              let ws4.qtp = ws4.count
         when "REC"
              let ws4.rec = ws4.count
         when "INI"
              let ws4.ini = ws4.count
         when "REM"
              let ws4.rem = ws4.count
         when "FIM"
              let ws4.fim = ws4.count
         when "RET"
              let ws4.ret = ws4.count
         when "ROD"
              let ws4.rod = ws4.count
         when "NIL"
              let ws4.nil = ws4.count
    end case
 end foreach

 let ws4.cabec1 = "QRU:",  ws4.qru   using "##&",
               "   REC:",  ws4.rec   using "##&",
               "   INI:",  ws4.ini   using "###&",
               "   REM:",  ws4.rem   using "##&",
               "   FIM:",  ws4.fim   using "##&",
               "   RET:",  ws4.ret   using "##&",
               "   ROD:",  ws4.rod   using "##&"

 let ws4.cabec2 = "QRV:",    ws4.qrv   using "##&",
#              "   QRXTMP:", ws4.qrx2  using "##&",
               "   QRX:",    ws4.qrx   using "##&",
               "   QTP:",    ws4.qtp   using "###&",
               "   NIL:",    ws4.nil   using "##&"

 display ws4.cabec1  to  cabec1
 display ws4.cabec2  to  cabec2

end function  ###-- cts00m03_contadores

##### PSI 214566 - ligia - 13/12/07 - testar a seq do botao ###########
function cts00m03_insere_botao(lr_param)

   define lr_param      record
          mdtcod        like datkveiculo.mdtcod,
          mdtbotcod     like datkmdtbot.mdtbotcod,
          srrcoddig     like dattfrotalocal.srrcoddig,
          ufdcod        like datmfrtpos.ufdcod,
          cidnom        like datmfrtpos.cidnom,
          brrnom        like datmfrtpos.brrnom,
          lclltt        like datmfrtpos.lclltt,
          lcllgt        like datmfrtpos.lcllgt,
          endzon        like datmfrtpos.endzon,
          atdsrvnum     like datmservico.atdsrvnum,
          atdsrvano     like datmservico.atdsrvano
          end record

   define l_caddat      date,
          l_cadhor      datetime hour to minute,
          l_res         smallint,
          l_msg         char(80),
          l_mdtbotprgseq like datrmdtbotprg.mdtbotprgseq

   let     l_caddat        = null
   let     l_cadhor        = null
   let     l_res           = null
   let     l_msg           = null
   let     l_mdtbotprgseq  = null

   call cts40g03_data_hora_banco(2) returning l_caddat, l_cadhor

   let l_mdtbotprgseq = null
   call ctd17g00_dados_botao(1,lr_param.mdtcod, lr_param.mdtbotcod)
        returning l_res, l_msg, l_mdtbotprgseq

   if l_res <> 1 then
      error l_msg sleep 1
      return
   end if

   call ctd15g00_ins_datmmdtmvt(l_caddat, l_cadhor,
                                lr_param.mdtcod, 2,
                                l_mdtbotprgseq, lr_param.srrcoddig,
                                lr_param.ufdcod, lr_param.cidnom,
                                lr_param.brrnom, lr_param.lclltt,
                                lr_param.lcllgt, "",
                                "", 2,
                                lr_param.endzon, "S", 0 ,
                                lr_param.atdsrvnum, lr_param.atdsrvano,
                                g_issk.empcod, g_issk.funmat, g_issk.usrtip)
        returning l_res, l_msg

   if l_res > 1 then
      error l_msg sleep 1
   end if

end function

function cts00m03_ver_botao(l_botao_ant, l_botao_atu)

   define l_botao_ant   like dattfrotalocal.c24atvcod,
          l_botao_atu   like dattfrotalocal.c24atvcod,
          l_msg1        char(40),
          l_msg2        char(40)

   let l_msg1 = null
   let l_msg2 = null

   let l_msg1 = "VIATURA EM ", l_botao_ant

   if l_botao_ant = "QRU" then
      case l_botao_atu
           when "REC"
                ## BOTAO OK
           when "INI"
                let l_msg2 = "ENVIE O REC E DEPOIS O INI"
           when "REM"
                let l_msg2 = "ENVIE O REC, O INI E DEPOIS O REM"
           when "FIM"
                let l_msg2 = "ENVIE O REC, O INI E DEPOIS O FIM"
           when "QRV"
                let l_msg2 = "ENVIE O REC, INI, FIM E DEPOIS O QRV"
           when "QRX"
                let l_msg2 = "ENVIE O REC, INI, FIM E DEPOIS O QRX"
           when "QTP"
                let l_msg2 = "ENVIE O REC, INI, FIM E DEPOIS O QTP"
           when "RET"
                let l_msg2 = "ENVIE O REC, INI, FIM E DEPOIS O RET"
           when "ROD"
                let l_msg2 = "ENVIE O REC, INI, FIM E DEPOIS O ROD"
      end case
   end if

   if l_botao_ant = "REC" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "INI"
                ## BOTAO OK
           when "REM"
                let l_msg2 = "ENVIE O INI E DEPOIS O REM"
           when "FIM"
                let l_msg2 = "ENVIE O INI E DEPOIS O FIM"
           when "QRA"
                let l_msg2 = "ENVIE O INI, FIM, QTP E DEPOIS O QRA"
           when "QRV"
                let l_msg2 = "ENVIE O INI, FIM E DEPOIS O QRV"
           when "QRX"
                let l_msg2 = "ENVIE O INI, FIM E DEPOIS O QRX"
           when "QTP"
                let l_msg2 = "ENVIE O INI, FIM E DEPOIS O QTP"
           when "RET"
                let l_msg2 = "ENVIE O INI, FIM E DEPOIS O RET"
           when "ROD"
                let l_msg2 = "ENVIE O INI, FIM E DEPOIS O ROD"
      end case
   end if

   if l_botao_ant = "INI" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REC"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REM"
                ## BOTAO OK
           when "FIM"
                ## BOTAO OK
           when "QRA"
                let l_msg2 = "ENVIE O FIM, QTP E DEPOIS O QRA"
           when "QRV"
                let l_msg2 = "ENVIE O FIM E DEPOIS O QRV"
           when "QRX"
                let l_msg2 = "ENVIE O FIM E DEPOIS O QRX"
           when "QTP"
                let l_msg2 = "ENVIE O FIM E DEPOIS O QTP"
           when "RET"
                let l_msg2 = "ENVIE O FIM E DEPOIS O RET"
           when "ROD"
                let l_msg2 = "ENVIE O FIM E DEPOIS O ROD"
      end case
   end if

   if l_botao_ant = "REM" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REC"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "INI"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "FIM"
                ## BOTAO OK
           when "QRA"
                let l_msg2 = "ENVIE O FIM, QTP E DEPOIS O QRA"
           when "QRV"
                let l_msg2 = "ENVIE O FIM E DEPOIS O QRV"
           when "QRX"
                let l_msg2 = "ENVIE O FIM E DEPOIS O QRX"
           when "QTP"
                let l_msg2 = "ENVIE O FIM E DEPOIS O QTP"
           when "RET"
                let l_msg2 = "ENVIE O FIM E DEPOIS O RET"
           when "ROD"
                let l_msg2 = "ENVIE O FIM E DEPOIS O ROD"
      end case
   end if

   if l_botao_ant = "FIM" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REC"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "INI"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REM"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "QRA"
                let l_msg2 = "ENVIE O QTP E DEPOIS O QRA"
           when "QRV"
                ## BOTAO OK
           when "QRX"
                ## BOTAO OK
           when "QTP"
                ## BOTAO OK
           when "RET"
                ## BOTAO OK
           when "ROD"
                ## BOTAO OK
      end case
   end if

   if l_botao_ant = "QRA" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REC"
                let l_msg2 = "ENVIE O QRV E DEPOIS O REC"
           when "INI"
                let l_msg2 = "ENVIE O QRV, O REC E DEPOIS O INI"
           when "REM"
                let l_msg2 = "ENVIE O QRV, O REC, O INI E DEPOIS O REM"
           when "FIM"
                let l_msg2 = "ENVIE O QRV PARA LIBERAR A VIATURA"
           when "QRV"
                ## BOTAO OK
           when "QRX"
                ## BOTAO OK
           when "QTP"
                ## BOTAO OK
           when "RET"
                ## BOTAO OK
           when "ROD"
                ## BOTAO OK
      end case
   end if

   if l_botao_ant = "QRV" then
      case l_botao_atu
           when "QRU"
                ## BOTAO OK
           when "REC"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "INI"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REM"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "FIM"
                ## BOTAO OK
           when "QRA"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "QRX"
                ## BOTAO OK
           when "QTP"
                ## BOTAO OK
           when "RET"
                ## BOTAO OK
           when "ROD"
                ## BOTAO OK
      end case
   end if

   if l_botao_ant = "QRX" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REC"
                let l_msg2 = "ENVIE O QRV E DEPOIS O REC"
           when "INI"
                let l_msg2 = "ENVIE O QRV, O REC E DEPOIS O INI"
           when "REM"
                let l_msg2 = "ENVIE O QRV, REC, INI E DEPOIS O REM"
           when "FIM"
                let l_msg2 = "ENVIE O QRV, REC, INI E DEPOIS O FIM"
           when "QRA"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "QRV"
                ## BOTAO OK
           when "QTP"
                ## BOTAO OK
           when "RET"
                ## BOTAO OK
           when "ROD"
                ## BOTAO OK
      end case
   end if

   if l_botao_ant = "QTP" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REC"
                let l_msg2 = "ENVIE O QRA, QRV E DEPOIS O REC"
           when "INI"
                let l_msg2 = "ENVIE O QRA, QRV, REC E DEPOIS O INI"
           when "REM"
                let l_msg2 = "ENVIE O QRA, QRV, REC, INI E DEPOIS O REM"
           when "FIM"
                let l_msg2 = "ENVIE O QRA, DEPOIS O QRV PARA LIBERAR A VIATURA"
           when "QRA"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "QRV"
                let l_msg2 = "ENVIE O QRA, DEPOIS O QRV PARA LIBERAR A VIATURA"
           when "QTX"
                let l_msg2 = "ENVIE O QRA E DEPOIS O QRX"
           when "RET"
                let l_msg2 = "ENVIE O QRA E DEPOIS O RET"
           when "ROD"
                let l_msg2 = "ENVIE O QRA E DEPOIS O ROD"
      end case
   end if

   if l_botao_ant = "ROD" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REC"
                let l_msg2 = "ENVIE O QRV E DEPOIS O REC"
           when "INI"
                let l_msg2 = "ENVIE O QRV, O REC E DEPOIS O INI"
           when "REM"
                let l_msg2 = "ENVIE O QRV, REC, INI E DEPOIS O REM"
           when "FIM"
                let l_msg2 = "ENVIE O QRV, REC, INI E DEPOIS O FIM"
           when "QRA"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "QRV"
                ## BOTAO OK
           when "QTP"
                ## BOTAO OK
           when "QRX"
                ## BOTAO OK
           when "RET"
                let l_msg2 = "VIATURA EM ", l_botao_ant
      end case
   end if

   if l_botao_ant = "RET" then
      case l_botao_atu
           when "QRU"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "REC"
                let l_msg2 = "ENVIE O QRV E DEPOIS O REC"
           when "INI"
                let l_msg2 = "ENVIE O QRV, O REC E DEPOIS O INI"
           when "REM"
                let l_msg2 = "ENVIE O QRV, REC, INI E DEPOIS O REM"
           when "FIM"
                let l_msg2 = "ENVIE O QRV, REC, INI E DEPOIS O FIM"
           when "QRA"
                let l_msg2 = "VIATURA EM ", l_botao_ant
           when "QRV"
                ## BOTAO OK
           when "QTP"
                ## BOTAO OK
           when "QRX"
                ## BOTAO OK
           when "ROD"
                let l_msg2 = "VIATURA EM ", l_botao_ant
      end case
   end if

   return l_msg1, l_msg2

end function

# Objetivo: obter se Atividade faz parte da Operacao  09.12.11 PSI-2011-21009
#-------------------------------------------------
function cts00m03_obterAtivIsOperac( l_c24atvpsq )

  define l_c24atvpsq  like dattfrotalocal.c24atvcod
  define l_opratvflg  char(01)
  define l_cpocod     like datkdominio.cpocod
  define l_cponom     like datkdominio.cponom

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_opratvflg = null
  let l_cpocod    = null
  let l_cponom    = null

  let l_cponom = "indatvopr"          # atividade faz parte operacao

  open ccts00m03026  using l_cponom
                         , l_c24atvpsq     # cpodes
  whenever error continue
     fetch ccts00m03026 into l_cpocod
  whenever error stop
  if sqlca.sqlcode = 0  then
     let l_opratvflg = "S"
  else
     let l_opratvflg = "N"
  end if
  close ccts00m03026

  return l_opratvflg
end function  #--> cts00m03_obterAtivIsOperac()

# Objetivo: checar lista de grupos do tipo servico  09.12.11 PSI-2011-21009
#--------------------------------------------------
function cts00m03_checarListaGrpTipo( l_srvorgtipcod, l_atdsrvorg )

  define l_srvorgtipcod smallint
  define l_atdsrvorg    like datksrvtip.atdsrvorg

  define l_result       smallint
  define l_cpocod       like datkdominio.cpocod
  define l_cponom       like datkdominio.cponom
  define l_cpodes       like datkdominio.cpodes
  define l_oco          smallint
  define l_idx          smallint
  define l_srvorgaux    like datksrvtip.atdsrvorg

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_result    = null
  let l_cpocod    = null
  let l_cponom    = null
  let l_cpodes    = null
  let l_oco       = null
  let l_idx       = null
  let l_srvorgaux = null

  if l_atdsrvorg is null then
     return false
  end if

  #--> Primeira chamada, popular lista de grupo servicos
  if m_cts00m03_pop is null  or
     m_cts00m03_pop  = 0     then
  
     initialize ma_tipgrp to null
     let l_idx    = 0

     for l_oco = 1 to 3

        case
           when l_oco = 1 let l_cponom = "orgatdtodos" # 20.01.12 SM-2012-00756
           when l_oco = 2 let l_cponom = "orgatdauto"
           when l_oco = 3 let l_cponom = "orgatdre"
        end case

        open ccts00m03027  using l_cponom
        whenever error continue
        foreach ccts00m03027 into l_cpocod
                                 ,l_cpodes
           let l_idx = l_idx + 1
           let ma_tipgrp[l_idx].cponom = l_cponom
           let ma_tipgrp[l_idx].cpodes = l_cpodes
        end foreach  #--> ccts00m03027

        whenever error stop

     end for

     let m_cts00m03_pop = 1
  end if

  #--> Verificar se para o Tipo de Servico, o Grupo eh valido
  case
     when l_srvorgtipcod = 1  let l_cponom = "orgatdtodos"
     when l_srvorgtipcod = 2  let l_cponom = "orgatdauto"  # Automotivo
     when l_srvorgtipcod = 3  let l_cponom = "orgatdre"    # Residencial
  end case

  let l_result = false

  for l_idx = 1 to 200
     if ma_tipgrp[l_idx].cponom is null then
        exit for
     end if
     if ma_tipgrp[l_idx].cponom = l_cponom then
        let l_srvorgaux = ma_tipgrp[l_idx].cpodes
        if l_atdsrvorg = l_srvorgaux  then
           let l_result = true
           exit for
        end if
     end if
  end for

  return l_result
end function  #--> cts00m03_checarListaGrpTipo()


# Objetivo: Apresentar lista de tipos de servico    27.12.11 PSI-2011-21009
#-----------------------------------------------
function cts00m03_popupTipoServ()

 define la_cts00m03a array[5] of record
    srvorgtipcod     smallint
   ,srvorgtip        char(15)
 end record

 define arr_aux      smallint
 define w_pf1        smallint
 define l_cponom     like datkdominio.cponom
 define l_cpocod     like datkdominio.cpocod
 define l_cpodes     like datkdominio.cpodes

 let arr_aux  = null
 let l_cponom = null
 let l_cpocod = null
 let l_cpodes = null

 for w_pf1 = 1 to 5
    initialize la_cts00m03a[w_pf1].* to null
 end for
   
 let int_flag = false
 let arr_aux  = 1

 #--> Popular lista de Tipos de Servico
 let l_cponom = "srvorgtipcod"
 open ccts00m03027  using l_cponom

 foreach ccts00m03027 into l_cpocod
                         , l_cpodes
    let la_cts00m03a[arr_aux].srvorgtip    = l_cpodes
    let la_cts00m03a[arr_aux].srvorgtipcod = l_cpocod
    let arr_aux = arr_aux + 1
    if arr_aux > 5 then
       error " Limite excedido. Existem mais de 5 Tipo Servico cadastrados!"
       exit foreach
    end if
 end foreach  #--> ccts00m03027
 
 open window cts00m03_pop at 10,45 with form "cts00m03a"
      attribute(form line 1, border)

 message " (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux-1)

 display array la_cts00m03a to s_cts00m03a.*

    on key (interrupt,control-c)
       let arr_aux = arr_curr()
       initialize la_cts00m03a[arr_aux] to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

 end display

 let int_flag = false
 close window cts00m03_pop

 return la_cts00m03a[arr_aux].srvorgtip, la_cts00m03a[arr_aux].srvorgtipcod

end function  #--> cts00m03_popupTipoServ()


# Objetivo: obter descricao de dominio                30.12.11 PSI-2011-21009
#-------------------------------------------------
function cts00m03_obterCpodes( l_cponom, l_cpocod )

  define l_cpocod     like datkdominio.cpocod
  define l_cponom     like datkdominio.cponom
  define l_cpodes     like datkdominio.cpodes

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_cpodes = null

  open ccts00m03028  using l_cponom
                         , l_cpocod
  whenever error continue
     fetch ccts00m03028 into l_cpodes
  whenever error stop
  if sqlca.sqlcode <> 0  then
     let l_cpodes = null
  end if
  close ccts00m03028

  return l_cpodes
end function  #--> cts00m03_obterCpodes()

##############################################################################
