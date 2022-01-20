#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: cts06m12                                                   #
# ANALISTA RESP..: Geraldo Souza                                              #
# PSI/OSF........: PAS 100676                                                 #
#                  MODULO RESPONSA. PELO ACESSO A TABELA DATMBLQMSG           #
# ........................................................................... #
# DESENVOLVIMENTO: Geraldo Souza                                              #
# LIBERACAO......: 29/07/2010                                                 #
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
function cts06m12_prepare()
#-------------------------#
  define l_sql char(500)

  let l_sql = "insert into datmblqmsg ",
              " (atdsrvnum, atdsrvano, c24txtseq, blqmsgdes ) ",
              " values ( ?, ?, ?, ? )"
  prepare pcts06m12001 from l_sql
  let l_sql = "select max(c24txtseq) ",
              "  from datmblqmsg ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? "
  prepare pcts06m12002 from l_sql
  declare ccts06m12002 cursor for pcts06m12002

  let l_sql = "select c24txtseq      ",
              "      ,blqmsgdes      ",
              "  from datmblqmsg     ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? ",
              "order by c24txtseq    "
  prepare pcts06m12003 from l_sql
  declare ccts06m12003 cursor with hold for pcts06m12003
  let m_prep = true

end function

#------------------------------------------------------------------------------
function cts06m12_ins_datmblqmsg(param)
#------------------------------------------------------------------------------
  define param record
                   atdsrvnum like datmblqmsg.atdsrvnum,
                   atdsrvano like datmblqmsg.atdsrvano,
                   blqmsgdes like datmblqmsg.blqmsgdes
  end record
  define l_c24txtseq like datmblqmsg.c24txtseq
  define l_ret       smallint,
         l_mensagem  char(50)
  if  m_prep <> true then
      call cts06m12_prepare()
  end if

  #verificar se parametros foram passados corretamente
  if  param.atdsrvnum is null or   #campo nao aceita nulo
      param.atdsrvano is null then
      let l_ret = 3
      let l_mensagem = "ERRO passagem de parametros - cts06m12_ins_datmblqmsg"
  else
      #buscar ultima sequencia da mensagem bloqueio
      call cts06m12_ult_seq_datmblqmsg(param.atdsrvnum,
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

          #inserir registro em datmblqmsg
          whenever error continue
          execute pcts06m12001 using param.atdsrvnum,
                                     param.atdsrvano,
                                     l_c24txtseq,
                                     param.blqmsgdes
          whenever error stop

          if sqlca.sqlcode <> 0 then
             let l_ret = 3
             let l_mensagem = "ERRO ", sqlca.sqlcode, " insert datmblqmsg"
          else
             let l_ret = 1
             let l_mensagem = null
          end if
      end if
  end if
  return l_ret,
         l_mensagem
end function
#-------------------------------------------------------------------------------
function cts06m12_ult_seq_datmblqmsg(param)
#-------------------------------------------------------------------------------
  define param record
                   atdsrvnum like datmblqmsg.atdsrvnum,
                   atdsrvano like datmblqmsg.atdsrvano
               end record
  define l_ret       smallint,
         l_mensagem  char(50),
         l_c24txtseq like datmblqmsg.c24txtseq
  let l_ret = 0
  let l_mensagem = null
  let l_c24txtseq = 0
  if m_prep <> true then
     call cts06m12_prepare()
  end if
  if  param.atdsrvnum is null then
      let l_ret = 3
      let l_mensagem = "ERRO passagem de parametros - cts06m12_ult_seq_datmblqmsg."
  else
      open ccts06m12002 using param.atdsrvnum,
                              param.atdsrvano
      fetch ccts06m12002 into l_c24txtseq
      if sqlca.sqlcode <> 0 then  #erro
         if sqlca.sqlcode = 100 then   #not found
            let l_ret = 2
            let l_mensagem = "Notfound em datmblqmsg"
         else
            let l_ret = 3
            let l_mensagem = "ERRO SQL ", sqlca.sqlcode ," cts06m12_ult_seq_datmblqmsg."
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
     let l_mensagem = "Nao existe registro na tabela de mensgem de bloqueio"
  end if
  return l_ret,
         l_mensagem,
         l_c24txtseq
end function

#---------------------------------------------------------------
 function cts06m12_cons_datmblqmsg(k_cts06m12)
#---------------------------------------------------------------

 define a_cts06m12 array[500] of record
    blqmsgdes      like datmblqmsg.blqmsgdes
 end record

 define k_cts06m12  record
    atdsrvnum       like datmblqmsg.atdsrvnum,
    atdsrvano       like datmblqmsg.atdsrvano
 end record

 define ws          record
    c24txtseq       like datmblqmsg.c24txtseq ,
    blqmsgdes       like datmblqmsg.blqmsgdes ,
    privez          smallint,
    prpflg          char(1)
 end record

 define arr_aux    smallint
 define scr_aux    smallint
 define w_pf1      integer
 define i          smallint
 let arr_aux  =  null
 let scr_aux  =  null

 for w_pf1  =  1 to 5
    initialize  a_cts06m12[w_pf1].*  to  null
 end for

 initialize ws.* to null

 if m_prep <> true then
    call cts06m12_prepare()
 end if

    initialize ws.* to null

    let arr_aux      = 0
    initialize a_cts06m12 to null
    open ccts06m12003 using k_cts06m12.atdsrvnum
                           ,k_cts06m12.atdsrvano
    foreach ccts06m12003 into ws.c24txtseq
                             ,ws.blqmsgdes
       if arr_aux > 4  then
          error " Limite excedido, bloqueio com mais de 4 linhas. AVISE A INFORMATICA!"
          sleep 5
          exit foreach
       end if
       let arr_aux = arr_aux + 1
       let a_cts06m12[arr_aux].blqmsgdes = ws.blqmsgdes
    end foreach
    close ccts06m12003

    if arr_aux  >  1  then
       for i = 1 to 4
          display a_cts06m12[i].*  to  s_cts10m00_a[i].*
       end for
    end if
end function

