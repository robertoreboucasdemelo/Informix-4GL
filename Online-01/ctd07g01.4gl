#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: ctd06g01                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: CHAMADO                                                    #
#                  MODULO RESPONSA. PELO ACESSO A TABELA DATMSERVHIST         #
# ........................................................................... #
# DESENVOLVIMENTO: Sergio Burini Jr.                                          #
# LIBERACAO......: 07/01/2007                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

database porto

  define m_prep    smallint

#-------------------------#
function ctd07g01_prepare()
#-------------------------#
  define l_sql char(500)

  let l_sql = "insert into datmservhist ",
              " (atdsrvnum, c24txtseq, atdsrvano, ",
              "  c24funmat, c24srvdsc, ligdat, ",
              "  lighorinc, c24empcod, c24usrtip ) ",
              " values ( ?, ?, ?, ?, ?, ?, ?, ?, ? )"
  prepare pctd07g01001 from l_sql

  let l_sql = "select max(c24txtseq) ",
              "  from datmservhist ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? "
  prepare pctd07g01002 from l_sql
  declare cctd07g01002 cursor for pctd07g01002

  let m_prep = true

end function

#---------------------------------------#
function ctd07g01_ins_datmservhist(param)
#---------------------------------------#

  define param record
                   atdsrvnum like datmservhist.atdsrvnum,
                   atdsrvano like datmservhist.atdsrvano,
                   c24funmat like datmservhist.c24funmat,
                   c24srvdsc like datmservhist.c24srvdsc,
                   ligdat    like datmservhist.ligdat,
                   lighorinc char(8),
                   c24empcod like datmservhist.c24empcod,
                   c24usrtip like datmservhist.c24usrtip
  end record

  define l_c24txtseq like datmservhist.c24txtseq

  define l_ret       smallint,
         l_mensagem  char(50),
         l_collen    integer,
         l_txtaux    char(8),
         l_txthor    char(8),
         l_tamtxt    smallint

  if  m_prep <> true then
      call ctd07g01_prepare()
  end if

  # VERIFICA TAMANHO DO CAMPO DATETIME NA TABELA TEMPORARIO ATE REORG PRODUCAO
  let l_collen = 0
  select collength into l_collen
    from systables tab, 
         syscolumns col
   where tab.tabname = 'datmservhist'
     and col.tabid = tab.tabid
     and col.colname = 'lighorinc'

  let l_tamtxt = length(param.lighorinc)
  if l_tamtxt = 5 then
  	  let l_txtaux = param.lighorinc clipped, ":00"
  else 
  	  let l_txtaux = param.lighorinc
  end if

  if l_collen < 1642 then  # 1642 = HH:MM:SS
  	 let l_txthor = l_txtaux[1,5]
  else
  	 let l_txthor = l_txtaux[1,8]
  end if
  
  #verificar se parametros foram passados corretamente
  if  param.atdsrvnum is null or   #campo nao aceita nulo
      param.c24funmat is null or   #deve vir preenchido ou dará problema
      param.c24usrtip is null or   #  na visualização do histórico
      param.c24empcod is null then
      let l_ret = 3
      let l_mensagem = "ERRO passagem de parametros - ctd07g01_ins_datmservhist"
  else
      #buscar ultima sequencia da ligação
      call ctd07g01_ult_seq_datmservhist(param.atdsrvnum,
                                         param.atdsrvano)
           returning l_ret,
                     l_mensagem,
                     l_c24txtseq

      #se nao ocorreu erro ao buscar sequencia
      if  l_ret <> 3 then
          if  l_ret = 2 then
              let l_c24txtseq = 1
          else
              let l_c24txtseq =  l_c24txtseq + 1
          end if

          #inserir registro em datmservhist
          whenever error continue
          execute pctd07g01001 using param.atdsrvnum,
                                     l_c24txtseq,
                                     param.atdsrvano,
                                     param.c24funmat,
                                     param.c24srvdsc,
                                     param.ligdat,
                                     l_txthor,
                                     param.c24empcod,
                                     param.c24usrtip
          whenever error stop

          if sqlca.sqlcode <> 0 then
             let l_ret = 3
             let l_mensagem = "ERRO ", sqlca.sqlcode, " insert datmservhist"
          else
             call cts00g07_apos_grvhist(param.atdsrvnum,param.atdsrvano,l_c24txtseq,1)
             let l_ret = 1
             let l_mensagem = null
          end if
      end if
  end if

  return l_ret,
         l_mensagem

end function

#------------------------------------------#
function ctd07g01_ult_seq_datmservhist(param)
#------------------------------------------#

  define param record
                   atdsrvnum like datmservhist.atdsrvnum,
                   atdsrvano like datmservhist.atdsrvano
               end record

  define l_ret       smallint,
         l_mensagem  char(50),
         l_c24txtseq like datmservhist.c24txtseq

  let l_ret = 0
  let l_mensagem = null
  let l_c24txtseq = 0

  if m_prep <> true then
     call ctd07g01_prepare()
  end if

  if  param.atdsrvnum is null then
      let l_ret = 3
      let l_mensagem = "ERRO passagem de parametros - ctd07g01_ult_seq_datmservhist."
  else

      open cctd07g01002 using param.atdsrvnum,
                              param.atdsrvano

      fetch cctd07g01002 into l_c24txtseq

      if sqlca.sqlcode <> 0 then  #erro
         if sqlca.sqlcode = 100 then   #not found
            let l_ret = 2
            let l_mensagem = "Notfound em datmservhist"
         else
            let l_ret = 3
            let l_mensagem = "ERRO SQL ", sqlca.sqlcode ," ctd07g01_ult_seq_datmservhist."
         end if
      else
         let l_ret = 1
         let l_mensagem = null
      end if

  end if

  #se nao ocorreu problema na busca, mas nao encontrou nenhum registro
  # isso pode acontecer pq select é com max
  if l_c24txtseq is null and l_ret = 1 then
     let l_ret = 2
     let l_mensagem = "Nao existe registro na tabela de historico servico"
  end if

  return l_ret,
         l_mensagem,
         l_c24txtseq

end function
