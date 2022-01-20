#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: ctd32g00                                                        #
# Objetivo.: Modulo responsavel pelo acesso a tabela DATMVCLRSVITF           #
#            Interface de reserva de veiculo                                 #
# Analista.: Fabio Costa                                                     #
# PSI      : 260142 - Integracao Carro Extra                                 #
# Liberacao: 30/03/2011                                                      #
#............................................................................#
# Observacoes                                                                #
#                                                                            #
#............................................................................#
# Alteracoes                                                                 #
#                                                                            #
#----------------------------------------------------------------------------#
database porto

define m_ctd32g00_prep smallint

#---------------------------#
function ctd32g00_prepare()
#---------------------------#
  define l_sql  char(300)

  let l_sql = ' insert into datmvclrsvitf(atdsrvnum, atdsrvano   , itftipcod '
            , '                         , itfsttcod, itfgrvhordat, intsttcrides)'
            , ' values(?,?,?,?,?,?)'
  prepare p_interface_ins from l_sql

  let l_sql = ' select atdsrvnum, atdsrvano   , itftipcod '
            , '      , itfsttcod, itfgrvhordat, intsttcrides '
            , ' from datmvclrsvitf '
            , ' where atdsrvnum = ? '
            , '   and atdsrvano = ? '
  prepare p_interface_sel from l_sql
  declare c_interface_sel cursor with hold for p_interface_sel

  let m_ctd32g00_prep = true

end function


# Incluir solicitacao de reserva de veiculo com dados de detalhes
#----------------------------------------------------------------
function ctd32g00_ins_interface(l_datmvclrsvitf)
#----------------------------------------------------------------

  define l_datmvclrsvitf record
         atdsrvnum     like datmvclrsvitf.atdsrvnum ,
         atdsrvano     like datmvclrsvitf.atdsrvano ,
         itftipcod     like datmvclrsvitf.itftipcod ,
         itfsttcod     like datmvclrsvitf.itfsttcod ,
         intsttcrides  like datmvclrsvitf.intsttcrides
  end record

  define l_hora datetime year to second

  initialize l_hora to null

  if m_ctd32g00_prep is null or
     m_ctd32g00_prep != true
     then
     call ctd32g00_prepare()
  end if

  let l_hora = current

  whenever error continue
  execute p_interface_ins using l_datmvclrsvitf.atdsrvnum ,   # Servico                             NN
                                l_datmvclrsvitf.atdsrvano ,   # Ano                                 NN
                                l_datmvclrsvitf.itftipcod ,   # Tipo da interface                   NN
                                l_datmvclrsvitf.itfsttcod ,   # Status interface                    NN
                                l_hora                    ,   # Data hora da gravacao da interface  NN
                                l_datmvclrsvitf.intsttcrides  # Mensagem de erro da interface
  whenever error stop

  return sqlca.sqlcode

end function
