#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g07                                                   #
# ANALISTA RESP..: Fabio Costa                                                #
# PSI............: 198404                                                     #
# OBJETIVO.......: Modulo responsavel pelo acesso a dados de CLIENTES         #
# DATA...........: 28/04/2009                                                 #
# ........................................................................... #
# Alteracoes                                                                  #
#-----------------------------------------------------------------------------#
database porto

define m_ctd20g07_prep smallint

define m_seg record
       segnom     like gsakseg.segnom   ,
       dddcod     like gsakend.dddcod   ,
       teltxt     like gsakend.teltxt   ,
       endlgdtip  like gsakend.endlgdtip,
       endlgd     like gsakend.endlgd   ,
       endnum     like gsakend.endnum   ,
       endcmp     like gsakend.endcmp   ,
       endcep     like gsakend.endcep   ,
       endcepcmp  like gsakend.endcepcmp,
       endbrr     like gsakend.endbrr   ,
       endcid     like gsakend.endcid   ,
       endufd     like gsakend.endufd
end record

define m_info_seg record
       segnom     like gsakseg.segnom   ,
       cgccpfnum  like gsakseg.cgccpfnum,
       cgcord     like gsakseg.cgcord   ,
       cgccpfdig  like gsakseg.cgccpfdig,
       pestip     like gsakseg.pestip
end record

#----------------------------------------------------------------
function ctd20g07_prepare()
#----------------------------------------------------------------
  define l_sql char(500)
  let l_sql = ' select s.segnom   , e.dddcod   , e.teltxt, ',
              '        e.endlgdtip, e.endlgd   , e.endnum, e.endcmp, ',
              '        e.endcep   , e.endcepcmp, e.endbrr, e.endcid, ',
              '        e.endufd ',
              ' from gsakseg s, gsakend e ',
              ' where s.segnumdig = e.segnumdig ',
              '   and e.endfld    = 1 ',   # endereco cliente
              '   and s.segnumdig = ? '
  prepare p_ender_cli_sel from l_sql
  declare c_ender_cli_sel cursor with hold for p_ender_cli_sel
  let l_sql = ' select s.segnom, s.cgccpfnum, s.cgcord, s.cgccpfdig, s.pestip ',
              ' from gsakseg s ',
              ' where s.segnumdig = ? '
  prepare p_cli_sel from l_sql
  declare c_cli_sel cursor with hold for p_cli_sel

  let m_ctd20g07_prep = true

end function

#----------------------------------------------------------------
function ctd20g07_ender_cli(l_segnumdig)
#----------------------------------------------------------------

  define l_segnumdig decimal(8,0),
         l_errcod    smallint    ,
         l_errmsg    char(60)
  if m_ctd20g07_prep is null or
     m_ctd20g07_prep <> true then
     call ctd20g07_prepare()
  end if
  initialize m_seg.* to null
  initialize m_info_seg.* to null
  initialize l_errcod, l_errmsg to null
  whenever error continue
  open c_ender_cli_sel using l_segnumdig
  fetch c_ender_cli_sel into m_seg.*
  whenever error stop
  let l_errcod = sqlca.sqlcode
  if l_errcod != 0
     then
     let l_errmsg = 'Erro na selecao do segurado: ', sqlca.sqlcode
  end if
  return l_errcod, l_errmsg, m_seg.*

end function

#----------------------------------------------------------------
function ctd20g07_nome_cli(l_segnumdig)
#----------------------------------------------------------------

  define l_segnumdig decimal(8,0),
         l_errcod    smallint    ,
         l_errmsg    char(60)
  initialize m_seg.* to null
  initialize m_info_seg.* to null
  initialize l_errcod, l_errmsg to null
  call ctd20g07_ender_cli(l_segnumdig)
       returning l_errcod, l_errmsg, m_seg.*

  return l_errcod, l_errmsg, m_seg.segnom
end function

#----------------------------------------------------------------
function ctd20g07_dados_cli(l_segnumdig)
#----------------------------------------------------------------

  define l_segnumdig decimal(8,0),
         l_errcod    smallint    ,
         l_errmsg    char(60)
  if m_ctd20g07_prep is null or
     m_ctd20g07_prep <> true then
     call ctd20g07_prepare()
  end if
  initialize m_seg.* to null
  initialize m_info_seg.* to null
  initialize l_errcod, l_errmsg to null
  whenever error continue
  open c_cli_sel using l_segnumdig
  fetch c_cli_sel into m_info_seg.*
  whenever error stop
  let l_errcod = sqlca.sqlcode
  if l_errcod != 0
     then
     let l_errmsg = 'Erro na selecao do segurado: ', sqlca.sqlcode
  end if
  return l_errcod, l_errmsg, m_info_seg.*

end function

