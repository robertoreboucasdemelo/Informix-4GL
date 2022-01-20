#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsr122                                                       #
# Analista Resp.: Raji Duenhas Jahchan                                        #
# Desenvolvimento: Raji Duenhas Jahchan                                       #
# PSI......:  - Relatorio Resolução GPS                                       #
# --------------------------------------------------------------------------- #
# Liberacao...:                                                               #
# --------------------------------------------------------------------------- #
#                               * Alteracoes *                                #
# --------------------------------------------------------------------------- #
# Data       Autor           Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 02/03/2010 Adriano Santos   PSI 252891    Inclusao do padrao idx 4 e 5      #
# 05/08/2011 Celso Yamahaki              Inclusao de todos os botoes          #
#-----------------------------------------------------------------------------#
# 12/03/2013 Celso Yamahaki   PSI0493    Melhoria no relatorio                #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_path       char(100)
define m_path_txt   char(100)
define m_rel1       char(100)

define m_data_inicio date
      ,m_data_fim    date

define mr_bdbsr122 record
    caddat        like datmmdtmvt.caddat
   ,cadhor        like datmmdtmvt.cadhor
   ,ciaempcod     like datmservico.ciaempcod
   ,atdsrvnum     like datmmdtmvt.atdsrvnum
   ,atdsrvano     like datmmdtmvt.atdsrvano
   ,mdtbotprgseq  like datmmdtmvt.mdtbotprgseq
   ,mdtmvtdigcnt  like datmmdtmvt.mdtmvtdigcnt
   ,mdtufdcod     like datmmdtmvt.ufdcod
   ,mdtcidnom     like datmmdtmvt.cidnom
   ,mdtlclltt     like datmmdtmvt.lclltt
   ,mdtlcllgt     like datmmdtmvt.lcllgt
   ,mdtcod        like datmmdtmvt.mdtcod
   ,ocrufdcod     like datmlcl.ufdcod
   ,ocrcidnom     like datmlcl.cidnom
   ,ocrlclltt     like datmlcl.lclltt
   ,ocrlcllgt     like datmlcl.lcllgt
   ,ocrbrrnom     like datmlcl.brrnom
   ,ocrlgdnom     like datmlcl.lgdnom
   ,ocrlgdnum     like datmlcl.lgdnum
   ,dstufdcod     like datmlcl.ufdcod
   ,dstcidnom     like datmlcl.cidnom
   ,dstlclltt     like datmlcl.lclltt
   ,dstlcllgt     like datmlcl.lcllgt
   ,dstbrrnom     like datmlcl.brrnom
   ,dstlgdnom     like datmlcl.lgdnom
   ,dstlgdnum     like datmlcl.lgdnum
   ,soceqpdes     like datkvcleqp.soceqpdes
   ,soceqpcod     like datreqpvcl.soceqpcod
   ,cidsedcod     like datrcidsed.cidsedcod
   ,cidcod        like datrcidsed.cidcod
   ,cidsednom     like glakcid.cidnom
   ,srrcoddig     like datksrr.srrcoddig
   ,srrabvnom     like datksrr.srrabvnom
   ,vcllicnum     like datmservico.vcllicnum
   ,asitipcod     like datmservico.asitipcod
   ,atddfttxt     like datmservico.atddfttxt
   ,atdvclsgl     like datkveiculo.atdvclsgl
   ,socvclcod     like datkveiculo.socvclcod
   ,asitipdes     like datkasitip.asitipdes
   ,vclanomdl     like datmservico.vclanomdl
   ,vcldes        like datmservico.vcldes
   ,atdsrvorg     like datmservico.atdsrvorg
   ,pstcoddig     like dpaksocor.pstcoddig
   ,nomgrr        like dpaksocor.nomgrr
   ,diasemana     char (01)
   ,mensagem      char (100)
end record

define mr_equipamentos record
    codigo     char(50)
   ,descricao  char (1000)
end record

define mr_tipo_local record
     ocorrencia  like datmlcl.c24endtip
    ,destino     like datmlcl.c24endtip
end record

main

    call fun_dba_abre_banco("CT24HS")

    initialize m_path
              ,m_path_txt
              ,m_rel1
              ,m_data_inicio
              ,m_data_fim
              ,mr_bdbsr122.*
              ,mr_equipamentos.*
              ,mr_tipo_local.* to null

    #--------------------------------------------------------------------
    # Deficao da data de processamento
    #--------------------------------------------------------------------
    let m_data_inicio = arg_val(1)
    let mr_tipo_local.ocorrencia = 1
    let mr_tipo_local.destino = 2

    if m_data_inicio is null       or
       m_data_inicio =  "  "       then
       let m_data_inicio = today
       let m_data_inicio = m_data_inicio - 1 units day
    else
       if m_data_inicio > today then
          display "*** ERRO NO PARAMETRO: DATA INVALIDA! ***: ", m_data_inicio
          exit program
       end if
    end if

    call bdbsr122_busca_path()

    set isolation to dirty read

    call bdbsr122_prepare()

    call bdbsr122_novo()

    call bdbsr122_envia_email()

end main

#------------------------------
function bdbsr122_prepare()
#------------------------------

   define l_sql char (2000)

   initialize l_sql to null

   let l_sql = ' select unique mdt.caddat, mdt.cadhor, mdt.atdsrvnum, mdt.atdsrvano'
              ,'       ,mdt.mdtbotprgseq, mdt.mdtmvtdigcnt, mdt.ufdcod'
              ,'       ,mdt.cidnom, mdt.lclltt, mdt.lcllgt '
              ,'       ,mdt.mdtcod, weekday(mdt.caddat) '
              ,'   from datmmdtmvt mdt    '
              ,'  where mdtmvttipcod = 2  '
              ,'    and mdtbotprgseq != 4 '
              ,'    and caddat = ?  '
   prepare p_bdbsr122_01 from l_sql
   declare c_bdbsr122_01 cursor for p_bdbsr122_01

   let l_sql = 'select lcl.ufdcod, lcl.cidnom, lcl.brrnom '
              ,'      ,lcl.lgdnom, lcl.lgdnum '
              ,'   from datmlcl lcl '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'    and c24endtip = ? '
   prepare p_bdbsr122_02 from l_sql
   declare c_bdbsr122_02 cursor for p_bdbsr122_02

   let l_sql = 'select cidcod '
              ,'   from glakcid '
              ,'  where cidnom = ? '
              ,'    and ufdcod = ? '

   prepare p_bdbsr122_03 from l_sql
   declare c_bdbsr122_03 cursor for p_bdbsr122_03

   let l_sql = 'select cidsedcod '
              ,'  from datrcidsed '
              ,' where cidcod = ? '
   prepare p_bdbsr122_04 from l_sql
   declare c_bdbsr122_04 cursor for p_bdbsr122_04

   let l_sql = 'select soceqpdes '
              ,'   from datkvcleqp '
              ,'  where soceqpcod = ?'
   prepare p_bdbsr122_05 from l_sql
   declare c_bdbsr122_05 cursor for p_bdbsr122_05

   let l_sql = 'select soceqpcod '
              ,'  from datreqpvcl '
              ,' where socvclcod = ?'
   prepare p_bdbsr122_06 from l_sql
   declare c_bdbsr122_06 cursor for p_bdbsr122_06

   let l_sql = 'select cidnom  '
              ,'  from glakcid '
              ,' where cidcod = ? '
   prepare p_bdbsr122_07 from l_sql
   declare c_bdbsr122_07 cursor for p_bdbsr122_07

   let l_sql = 'select vcllicnum, asitipcod, atddfttxt '
              ,'      ,vclanomdl, vcldes, atdsrvorg   '
              ,'      ,ciaempcod '
              ,'  from datmservico   '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '
   prepare p_bdbsr122_08 from l_sql
   declare c_bdbsr122_08 cursor for p_bdbsr122_08

   let l_sql = 'select srr.srrabvnom, srr.srrcoddig '
              ,'  from datksrr srr, dattfrotalocal lcl '
              ,' where srr.srrcoddig = lcl.srrcoddig '
              ,'   and lcl.socvclcod = ? '
   prepare p_bdbsr122_09 from l_sql
   declare c_bdbsr122_09 cursor for p_bdbsr122_09

   let l_sql = ' select socvclcod, atdvclsgl '
              ,'   from datkveiculo '
              ,'  where mdtcod = ? '
   prepare p_bdbsr122_10 from l_sql
   declare c_bdbsr122_10 cursor for p_bdbsr122_10

   let l_sql = ' select asitipdes '
              ,'   from datkasitip '
              ,'  where asitipcod = ? '
   prepare p_bdbsr122_11 from l_sql
   declare c_bdbsr122_11 cursor for p_bdbsr122_11

   let l_sql = ' select pstcoddig '
              ,'   from datrsrrpst '
              ,'  where srrcoddig = ? '
              ,' order by vigfnl desc'
   prepare p_bdbsr122_12 from l_sql
   declare c_bdbsr122_12 cursor for p_bdbsr122_12

   let l_sql = ' select nomgrr '
              ,'   from dpaksocor '
              ,'  where pstcoddig = ?'
   prepare p_bdbsr122_13 from l_sql
   declare c_bdbsr122_13 cursor for p_bdbsr122_13

end function

#------------------------------#
function bdbsr122_busca_path()
#------------------------------#

    define l_dataarq char(8)
    define l_data    date

    initialize l_dataarq, l_data to null

    let l_data = today
    display "l_data: ", l_data
    let l_dataarq = extend(l_data, year to year),
                    extend(l_data, month to month),
                    extend(l_data, day to day)
    display "l_dataarq: ", l_dataarq

    # Chama a funcao para buscar o caminho do arquivo de log
    let m_path = f_path("DBS", "LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr122.log"

    call startlog(m_path)

    # Chama a funcao para buscar o caminho do arquivo de relatorio
    let m_path = f_path("DBS", "RELATO")

    if m_path is null then
        let m_path = "."
    end if
    let m_path_txt = m_path clipped,
                 "/Resolucao_QRU_FIM_", day(m_data_inicio) using "&&",
                                        month(m_data_inicio) using "&&",
                                        year(m_data_inicio) using "&&&&" ,".txt"
    let m_rel1 = m_path clipped,
                 "/Resolucao_QRU-FIM_", day(m_data_inicio) using "&&",
                                        month(m_data_inicio) using "&&",
                                        year(m_data_inicio) using "&&&&" ,".xls"

end function

#------------------------------
function bdbsr122_novo()
#------------------------------


   start report rel_bdbsr122_novo to m_rel1
   start report rel_bdbsr122_novo_txt to m_path_txt

   open c_bdbsr122_01  using m_data_inicio
   foreach c_bdbsr122_01 into mr_bdbsr122.caddat
                             ,mr_bdbsr122.cadhor
                             ,mr_bdbsr122.atdsrvnum
                             ,mr_bdbsr122.atdsrvano
                             ,mr_bdbsr122.mdtbotprgseq
                             ,mr_bdbsr122.mdtmvtdigcnt
                             ,mr_bdbsr122.mdtufdcod
                             ,mr_bdbsr122.mdtcidnom
                             ,mr_bdbsr122.mdtlclltt
                             ,mr_bdbsr122.mdtlcllgt
                             ,mr_bdbsr122.mdtcod
                             ,mr_bdbsr122.diasemana

      #Busca dados do Veículo
      open c_bdbsr122_10 using mr_bdbsr122.mdtcod
      fetch c_bdbsr122_10 into mr_bdbsr122.socvclcod
                              ,mr_bdbsr122.atdvclsgl
      if sqlca.sqlcode = 100 then
         let mr_bdbsr122.mensagem = 'NÃO FORAM ENCONTRADOS DADOS PARA O MDT: ', mr_bdbsr122.mdtcod
         display mr_bdbsr122.mensagem clipped
         call bdbsr122_limpa_record(1)
         output to report rel_bdbsr122_novo()
         output to report rel_bdbsr122_novo_txt()
         initialize mr_bdbsr122.* to null
         continue foreach
      end if
      close c_bdbsr122_10

      #Busca dados do Socorrista
      open c_bdbsr122_09 using mr_bdbsr122.socvclcod
      fetch c_bdbsr122_09 into mr_bdbsr122.srrabvnom
                              ,mr_bdbsr122.srrcoddig
      if sqlca.sqlcode = 100 then
         let mr_bdbsr122.srrabvnom = 'NAO ENCONTRADO'
      end if
      close c_bdbsr122_09

      #Busca dados do prestador
      open c_bdbsr122_12 using mr_bdbsr122.srrcoddig
      fetch c_bdbsr122_12 into mr_bdbsr122.pstcoddig
      close c_bdbsr122_12
      open c_bdbsr122_13 using mr_bdbsr122.pstcoddig
      fetch c_bdbsr122_13 into mr_bdbsr122.nomgrr
      if sqlca.sqlcode = 100 then
         let mr_bdbsr122.nomgrr = 'NAO ENCONTRADO'
      end if
      close c_bdbsr122_13

      #Busca equipamentos do veículo
      initialize mr_equipamentos.* to null
      open c_bdbsr122_06 using mr_bdbsr122.socvclcod
      foreach c_bdbsr122_06 into mr_bdbsr122.soceqpcod
         let mr_equipamentos.codigo = mr_equipamentos.codigo clipped
                                     ,mr_bdbsr122.soceqpcod, ';'

         #Busca Descricao do codigo
         open c_bdbsr122_05 using mr_bdbsr122.soceqpcod
         fetch c_bdbsr122_05 into mr_bdbsr122.soceqpdes
         if sqlca.sqlcode = 100 then
            let mr_bdbsr122.soceqpdes = 'NAO CADASTRADO'
         end if
         close c_bdbsr122_05
         let mr_equipamentos.descricao = mr_equipamentos.descricao clipped
                                        ,mr_bdbsr122.soceqpdes clipped, ';'

      end foreach

      #Somente fará as buscas se o sinal tiver serviço vinculado

      if mr_bdbsr122.atdsrvnum is not null and
         mr_bdbsr122.atdsrvano is not null then
         #Busca dados do Serviço
         open c_bdbsr122_08 using mr_bdbsr122.atdsrvnum
                                 ,mr_bdbsr122.atdsrvano
         fetch c_bdbsr122_08 into mr_bdbsr122.vcllicnum
                                 ,mr_bdbsr122.asitipcod
                                 ,mr_bdbsr122.atddfttxt
                                 ,mr_bdbsr122.vclanomdl
                                 ,mr_bdbsr122.vcldes
                                 ,mr_bdbsr122.atdsrvorg
                                 ,mr_bdbsr122.ciaempcod
         close c_bdbsr122_08

         #Busca descricao da Assistencia
         open c_bdbsr122_11 using mr_bdbsr122.asitipcod
         fetch c_bdbsr122_11 into mr_bdbsr122.asitipdes
         if sqlca.sqlcode = 100 then
            let mr_bdbsr122.asitipdes = 'ASSISTENCIA NAO CADASTRADA'
         end if
         close c_bdbsr122_11

         #Busca dados da ocorrencia
         open c_bdbsr122_02 using mr_bdbsr122.atdsrvnum
                                 ,mr_bdbsr122.atdsrvano
                                 ,mr_tipo_local.ocorrencia
         fetch c_bdbsr122_02 into mr_bdbsr122.ocrufdcod
                                 ,mr_bdbsr122.ocrcidnom
                                 ,mr_bdbsr122.ocrbrrnom
                                 ,mr_bdbsr122.ocrlgdnom
                                 ,mr_bdbsr122.ocrlgdnum
         close c_bdbsr122_02

         #Busca codigo da Cidade
         open c_bdbsr122_03 using mr_bdbsr122.ocrcidnom
                                 ,mr_bdbsr122.ocrufdcod
         fetch c_bdbsr122_03 into mr_bdbsr122.cidcod

         #Busca cidade Sede da Ocorrencia
         if mr_bdbsr122.cidcod is not null then
            open c_bdbsr122_04 using mr_bdbsr122.cidcod
            fetch c_bdbsr122_04 into mr_bdbsr122.cidsedcod
            close c_bdbsr122_04

            if mr_bdbsr122.cidsedcod is not null then
               open c_bdbsr122_07 using mr_bdbsr122.cidsedcod
               fetch c_bdbsr122_07 into mr_bdbsr122.cidsednom
               close c_bdbsr122_07
            else
               let mr_bdbsr122.cidsednom = 'CIDADE SEDE NAO CADASTRADA'
            end if
         end if

         #Busca dados do destino, somente para origem AUTO
         if mr_bdbsr122.atdsrvorg = 9 or
            mr_bdbsr122.atdsrvorg = 13 then
            let mr_bdbsr122.mensagem = 'SERVICO DE ORIGEM RE'
            call bdbsr122_limpa_record(3)
            output to report rel_bdbsr122_novo()
            output to report rel_bdbsr122_novo_txt()
            initialize mr_bdbsr122.* to null
            continue foreach
         else
            open c_bdbsr122_02 using mr_bdbsr122.atdsrvnum
                                 ,mr_bdbsr122.atdsrvano
                                 ,mr_tipo_local.destino
            fetch c_bdbsr122_02 into mr_bdbsr122.dstufdcod
                                    ,mr_bdbsr122.dstcidnom
                                    ,mr_bdbsr122.dstbrrnom
                                    ,mr_bdbsr122.dstlgdnom
                                    ,mr_bdbsr122.dstlgdnum
            close c_bdbsr122_02
         end if
      else
         let mr_bdbsr122.mensagem = 'BOTÃO SEM SERVIÇO VINCULADO'
         call bdbsr122_limpa_record(2)

         output to report rel_bdbsr122_novo()
         output to report rel_bdbsr122_novo_txt()
         initialize mr_bdbsr122.* to null
         continue foreach
      end if
      output to report rel_bdbsr122_novo()
      output to report rel_bdbsr122_novo_txt()

      initialize mr_bdbsr122.* to null
   end foreach
   finish report rel_bdbsr122_novo
   finish report rel_bdbsr122_novo_txt
end function

#---------------------------------------
function bdbsr122_limpa_record(l_op)
#---------------------------------------

   define l_op smallint # Dependendo do ponto do relatório, limpará somente os campos necessários
   case l_op
      when 1
              initialize mr_bdbsr122.ciaempcod ,mr_bdbsr122.ocrufdcod
                        ,mr_bdbsr122.ocrcidnom ,mr_bdbsr122.ocrlclltt
                        ,mr_bdbsr122.ocrlcllgt ,mr_bdbsr122.ocrbrrnom
                        ,mr_bdbsr122.ocrlgdnom ,mr_bdbsr122.ocrlgdnum
                        ,mr_bdbsr122.dstufdcod ,mr_bdbsr122.dstcidnom
                        ,mr_bdbsr122.dstlclltt ,mr_bdbsr122.dstlcllgt
                        ,mr_bdbsr122.dstbrrnom ,mr_bdbsr122.dstlgdnom
                        ,mr_bdbsr122.dstlgdnum ,mr_bdbsr122.soceqpdes
                        ,mr_bdbsr122.soceqpcod ,mr_bdbsr122.cidsedcod
                        ,mr_bdbsr122.cidcod    ,mr_bdbsr122.cidsednom
                        ,mr_bdbsr122.srrcoddig ,mr_bdbsr122.srrabvnom
                        ,mr_bdbsr122.vcllicnum ,mr_bdbsr122.asitipcod
                        ,mr_bdbsr122.atddfttxt ,mr_bdbsr122.atdvclsgl
                        ,mr_bdbsr122.socvclcod ,mr_bdbsr122.asitipdes
                        ,mr_bdbsr122.vclanomdl ,mr_bdbsr122.vcldes
                        ,mr_bdbsr122.atdsrvorg ,mr_bdbsr122.pstcoddig
                        ,mr_equipamentos.*     ,mr_bdbsr122.nomgrr    to null

      when 2
              initialize mr_bdbsr122.ocrufdcod ,mr_bdbsr122.ocrcidnom
                        ,mr_bdbsr122.ocrlclltt ,mr_bdbsr122.ocrlcllgt
                        ,mr_bdbsr122.ocrbrrnom ,mr_bdbsr122.ocrlgdnom
                        ,mr_bdbsr122.ocrlgdnum ,mr_bdbsr122.dstufdcod
                        ,mr_bdbsr122.dstcidnom ,mr_bdbsr122.dstlclltt
                        ,mr_bdbsr122.dstlcllgt ,mr_bdbsr122.dstbrrnom
                        ,mr_bdbsr122.dstlgdnom ,mr_bdbsr122.dstlgdnum
                        ,mr_bdbsr122.soceqpdes ,mr_bdbsr122.soceqpcod
                        ,mr_bdbsr122.cidsedcod ,mr_bdbsr122.cidcod
                        ,mr_bdbsr122.cidsednom ,mr_bdbsr122.vcllicnum
                        ,mr_bdbsr122.asitipcod ,mr_bdbsr122.atddfttxt
                        ,mr_bdbsr122.asitipdes
                        ,mr_bdbsr122.vclanomdl ,mr_bdbsr122.vcldes
                        ,mr_bdbsr122.atdsrvorg ,mr_bdbsr122.ciaempcod to null
      when 3
             initialize  mr_bdbsr122.dstufdcod, mr_bdbsr122.dstcidnom
                        ,mr_bdbsr122.dstbrrnom, mr_bdbsr122.dstlgdnom
                        ,mr_bdbsr122.dstlgdnum to null

   end case

end function

#--------------------------------------------
report rel_bdbsr122_novo()
#--------------------------------------------
  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "EMPRESA"                ,ASCII(09),
              "ORIGEM"                 ,ASCII(09),
              "SERVICO"                ,ASCII(09),
              "ANO"                    ,ASCII(09),
              "PRESTADOR"              ,ASCII(09),
              "NOME_GUERRA"            ,ASCII(09),
              "DATA_SINAL"             ,ASCII(09),
              "HORA_SINAL"             ,ASCII(09),
              "DIA_SEMANA"             ,ASCII(09),
              "BOTAO"                  ,ASCII(09),
              "BOTAO2"                 ,ASCII(09),
              "SIGLA"                  ,ASCII(09),
              "QRA"                    ,ASCII(09),
              "NOME_SOCORRISTA"        ,ASCII(09),
              "CODIGO_EQUIPAMENTOS"    ,ASCII(09),
              "DESC_EQUIPAMENTOS"      ,ASCII(09),
              "DEFEITO"                ,ASCII(09),
              "TIPO_ASSIST"            ,ASCII(09),
              "DESC_TIPO_ASSIST"       ,ASCII(09),
              "VEICULO"                ,ASCII(09),
              "ANO_VEICULO"            ,ASCII(09),
              "PLACA"                  ,ASCII(09),
              "UF_BOTAO"               ,ASCII(09),
              "CIDADE_BOTAO"           ,ASCII(09),
              "LATITUDE_BOTAO"         ,ASCII(09),
              "LONGITUDE_BOTAO"        ,ASCII(09),
              "UF_OCORRENCIA"          ,ASCII(09),
              "CIDADE_OCORRENCIA"      ,ASCII(09),
              "LOGRADOURO_OCORRENCIA"  ,ASCII(09),
              "CIDADE_SEDE_OCORRENCIA" ,ASCII(09),
              "UF_DESTINO"             ,ASCII(09),
              "CIDADE_DESTINO"         ,ASCII(09),
              "LOGRADOURO_DESTINO"     ,ASCII(09),
              "OBSERVACAO"

  on every row


     print mr_bdbsr122.ciaempcod            ,  ASCII(09);
     print mr_bdbsr122.atdsrvorg            ,  ASCII(09);
     print mr_bdbsr122.atdsrvnum            ,  ASCII(09);
     print mr_bdbsr122.atdsrvano            ,  ASCII(09);
     print mr_bdbsr122.pstcoddig            ,  ASCII(09);
     print mr_bdbsr122.nomgrr        clipped,  ASCII(09);
     print mr_bdbsr122.caddat               ,  ASCII(09);
     print mr_bdbsr122.cadhor               ,  ASCII(09);
     print mr_bdbsr122.diasemana            ,  ASCII(09);
     print mr_bdbsr122.mdtbotprgseq         ,  ASCII(09);
     print mr_bdbsr122.mdtmvtdigcnt         ,  ASCII(09);
     print mr_bdbsr122.atdvclsgl     clipped,  ASCII(09);
     print mr_bdbsr122.srrcoddig            ,  ASCII(09);
     print mr_bdbsr122.srrabvnom     clipped,  ASCII(09);
     print mr_equipamentos.codigo    clipped,  ASCII(09);
     print mr_equipamentos.descricao clipped,  ASCII(09);
     print mr_bdbsr122.atddfttxt     clipped,  ASCII(09);
     print mr_bdbsr122.asitipcod            ,  ASCII(09);
     print mr_bdbsr122.asitipdes     clipped,  ASCII(09);
     print mr_bdbsr122.vcldes        clipped,  ASCII(09);
     print mr_bdbsr122.vclanomdl            ,  ASCII(09);
     print mr_bdbsr122.vcllicnum            ,  ASCII(09);
     print mr_bdbsr122.mdtufdcod            ,  ASCII(09);
     print mr_bdbsr122.mdtcidnom     clipped,  ASCII(09);
     print mr_bdbsr122.mdtlclltt            ,  ASCII(09);
     print mr_bdbsr122.mdtlcllgt            ,  ASCII(09);
     print mr_bdbsr122.ocrufdcod            ,  ASCII(09);
     print mr_bdbsr122.ocrcidnom     clipped,  ASCII(09);
     print mr_bdbsr122.ocrlgdnom     clipped,  ASCII(09);
     print mr_bdbsr122.cidsednom            ,  ASCII(09);
     print mr_bdbsr122.dstufdcod            ,  ASCII(09);
     print mr_bdbsr122.dstcidnom     clipped,  ASCII(09);
     print mr_bdbsr122.dstlgdnom     clipped,  ASCII(09);
     print mr_bdbsr122.mensagem      clipped


end report



#-------------------------------#
function bdbsr122_envia_email()
#-------------------------------#

   define l_assunto     char(200),
          l_comando     char(200),
          l_erro_envio  integer,
          l_arquivos    char(300)

   # Inicializacao das variaveis
   initialize l_comando    to null
   initialize l_erro_envio to null
   initialize l_arquivos   to null
   initialize l_assunto    to null

   let l_assunto = "Relatorio de Resolucao GPS (", m_data_inicio, ")"

   # Compacta arquivos
   let l_comando = "gzip -f ", m_rel1 clipped
   run l_comando

   let m_rel1 = m_rel1 clipped, ".gz"

   let l_arquivos = m_rel1 clipped

   let l_erro_envio = ctx22g00_envia_email("BDBSR122", l_assunto clipped, l_arquivos clipped)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email (ctx22g00) - ", l_assunto, " ",l_arquivos
       else
           display "Nao existe email cadastrado para o modulo - bdbsr122"
       end if
   end if

end function

#--------------------------------------------
report rel_bdbsr122_novo_txt()
#--------------------------------------------
  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

  format


  on every row


     print mr_bdbsr122.ciaempcod            ,  ASCII(09);
     print mr_bdbsr122.atdsrvorg            ,  ASCII(09);
     print mr_bdbsr122.atdsrvnum            ,  ASCII(09);
     print mr_bdbsr122.atdsrvano            ,  ASCII(09);
     print mr_bdbsr122.pstcoddig            ,  ASCII(09);
     print mr_bdbsr122.nomgrr        clipped,  ASCII(09);
     print mr_bdbsr122.caddat               ,  ASCII(09);
     print mr_bdbsr122.cadhor               ,  ASCII(09);
     print mr_bdbsr122.diasemana            ,  ASCII(09);
     print mr_bdbsr122.mdtbotprgseq         ,  ASCII(09);
     print mr_bdbsr122.mdtmvtdigcnt         ,  ASCII(09);
     print mr_bdbsr122.atdvclsgl     clipped,  ASCII(09);
     print mr_bdbsr122.srrcoddig            ,  ASCII(09);
     print mr_bdbsr122.srrabvnom     clipped,  ASCII(09);
     print mr_equipamentos.codigo    clipped,  ASCII(09);
     print mr_equipamentos.descricao clipped,  ASCII(09);
     print mr_bdbsr122.atddfttxt     clipped,  ASCII(09);
     print mr_bdbsr122.asitipcod            ,  ASCII(09);
     print mr_bdbsr122.asitipdes     clipped,  ASCII(09);
     print mr_bdbsr122.vcldes        clipped,  ASCII(09);
     print mr_bdbsr122.vclanomdl            ,  ASCII(09);
     print mr_bdbsr122.vcllicnum            ,  ASCII(09);
     print mr_bdbsr122.mdtufdcod            ,  ASCII(09);
     print mr_bdbsr122.mdtcidnom     clipped,  ASCII(09);
     print mr_bdbsr122.mdtlclltt            ,  ASCII(09);
     print mr_bdbsr122.mdtlcllgt            ,  ASCII(09);
     print mr_bdbsr122.ocrufdcod            ,  ASCII(09);
     print mr_bdbsr122.ocrcidnom     clipped,  ASCII(09);
     print mr_bdbsr122.ocrlgdnom     clipped,  ASCII(09);
     print mr_bdbsr122.cidsednom            ,  ASCII(09);
     print mr_bdbsr122.dstufdcod            ,  ASCII(09);
     print mr_bdbsr122.dstcidnom     clipped,  ASCII(09);
     print mr_bdbsr122.dstlgdnom     clipped,  ASCII(09);
     print mr_bdbsr122.mensagem      clipped


end report