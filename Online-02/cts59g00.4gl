#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: cts59g00                                                        #
# Objetivo.: Funcoes genericas para o SAPS (Porto Seguro Servicos Avulsos)   #
# Analista.: Fabio Costa, Fornax Tecnologia                                  #
# PSI      : 2013-06224/PR                                                   #
# Liberacao: 22/08/2013                                                      #
#............................................................................#
# Observacoes                                                                #
#............................................................................#
# Alteracoes                                                                 #
# Ajustes de ^M                                                              #
#----------------------------------------------------------------------------#
database porto

define m_cts59g00_prep smallint

#--------------------------------------------------------------------------
function cts59g00_prepare()
#--------------------------------------------------------------------------
  define l_sql  char(500)

  initialize l_sql to null

  let l_sql = " select a.mdtmsgtxt "
            , "  from datmmdtmsg24h a, datmligacao b, datkassunto c "
            , " where a.c24astcod = b.c24astcod "
            , "   and a.c24astcod = c.c24astcod "
            , "   and c.c24astagp in ('PSA', 'PSL') "
            , "   and b.lignum = (select min(lignum) "
            , "                     from datmligacao d "
            , "                    where d.atdsrvnum = ? "
            , "                      and d.atdsrvano = ?) "
  prepare p_cts59g00_id_srv from l_sql
  declare c_cts59g00_id_srv cursor with hold for p_cts59g00_id_srv

  let m_cts59g00_prep = true

end function

#--------------------------------------------------------------------------
function cts59g00_idt_srv_saps(l_param)
#--------------------------------------------------------------------------
  define l_param record
         nivel_saida   smallint
       , atdsrvnum     decimal (10,0)
       , atdsrvano     decimal (2,0)
  end record

  define l_errcod     integer
       , l_mdtmsgtxt  char(45)

  initialize l_errcod, l_mdtmsgtxt to null

  if m_cts59g00_prep is null or
     m_cts59g00_prep != true
     then
     call cts59g00_prepare()
  end if

  whenever error continue
  open  c_cts59g00_id_srv using l_param.atdsrvnum, l_param.atdsrvano
  fetch c_cts59g00_id_srv into l_mdtmsgtxt
  whenever error stop

  let l_errcod = sqlca.sqlcode
  close c_cts59g00_id_srv

  if l_param.nivel_saida = 1
     then
     return l_errcod
  end if

  if l_param.nivel_saida = 2
     then
     return l_errcod, l_mdtmsgtxt
  end if

end function

