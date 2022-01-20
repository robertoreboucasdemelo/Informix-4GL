#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: ctd33g00                                                        #
# Objetivo.: Gerenciamento de prorrogacoes de veiculo, tabela                #
#            datmrsrsrvrsm                                                   #
# Analista.: Fabio Costa                                                     #
# PSI      : Carro Extra - fase II                                           #
# Liberacao: 26/05/2011                                                      #
#............................................................................#
# Observacoes                                                                #
#............................................................................#
# Alteracoes                                                                 #
#                                                                            #
#----------------------------------------------------------------------------#
database porto

define m_ctd33g00_prep smallint

#---------------------------#
function ctd33g00_prepare()
#---------------------------#
  define l_sql  char(1500)

  let l_sql = ' insert into datmrsrsrvrsm( '
            , '        atdsrvnum   , atdsrvano   , aviproseq   , atdsrvseq,    '
            , '        retdat, dvldat, diaqtd, empcod )'
            , ' values(?,?,?,?,?,?,?,?)'
  prepare p_ctd33g00_ins from l_sql

  let l_sql = ' delete from datmrsrsrvrsm '
            , '        where atdsrvnum  = ? '
            , '          and atdsrvano  = ? '
            , '          and aviproseq  = ? '
  prepare p_ctd33g00_del from l_sql

  let l_sql = ' select max(atdsrvseq) from datmrsrsrvrsm '
            , '        where atdsrvnum  = ? '
            , '          and atdsrvano  = ? '
            , '          and aviproseq  = ? '
  prepare p_ctd33g01_sel from l_sql
  declare c_ctd33g00_01 cursor for p_ctd33g01_sel

  let l_sql = ' select * from datmrsrsrvrsm '
            , '        where atdsrvnum  = ? '
            , '          and atdsrvano  = ? '
            , '          and aviproseq  = ? '
  prepare p_ctd33g02_sel from l_sql
  declare c_ctd33g00_02 cursor for p_ctd33g02_sel

  let l_sql = ' select sum(diaqtd) from datmrsrsrvrsm ',
             ' where atdsrvnum = ? ',
             ' and atdsrvano =  ? ',
             ' and empcod > 0 ',
             ' and aviproseq in (select max(aviproseq) from datmprorrog',
                                ' where atdsrvnum = ? ',
                                ' and atdsrvano = ? ',
                                ' and aviprostt = "A") '
  prepare p_ctd33g03_sel from l_sql
  declare c_ctd33g00_03 cursor for p_ctd33g03_sel

  let m_ctd33g00_prep = true

end function


# Incluir solicitacao de reserva de veiculo com dados de detalhes
#----------------------------------------------------------------
function ctd33g00_ins_resumo(l_resumo)
#----------------------------------------------------------------

  define l_resumo record
         atdsrvnum        like datmrsrsrvrsm.atdsrvnum    ,
         atdsrvano        like datmrsrsrvrsm.atdsrvano    ,
         aviproseq        like datmrsrsrvrsm.aviproseq    ,
         vclretdat        like datmprorrog.vclretdat,
         vclrethor        like datmprorrog.vclrethor,
         devdat           like datmprorrog.vclretdat,
         diaqtd           like datmrsrsrvrsm.diaqtd,
         empcod           like datmrsrsrvrsm.empcod
  end record

  define l_msg     char(80)
  define l_datac   char(20)
  define l_retdat  like datmrsrsrvrsm.retdat
  define l_devdat  like datmrsrsrvrsm.dvldat
  define l_atdsrvseq  like datmrsrsrvrsm.atdsrvseq
  
  if m_ctd33g00_prep is null or
     m_ctd33g00_prep != true
     then
     call ctd33g00_prepare()
  end if

  let l_msg = null
  let l_datac = null
  let l_retdat = null
  let l_devdat = null
  let l_atdsrvseq = null

  let l_datac = year(l_resumo.vclretdat) using '&&&&', '-',
                month(l_resumo.vclretdat) using '&&','-',
                day(l_resumo.vclretdat) using '&&', ' ', 
                l_resumo.vclrethor,":00"
  let l_retdat = l_datac

  let l_datac = year(l_resumo.devdat) using '&&&&','-',
                month(l_resumo.devdat) using '&&','-',
                day(l_resumo.devdat) using '&&', ' ', 
                l_resumo.vclrethor,":00"
  let l_devdat = l_datac

  open c_ctd33g00_01 using l_resumo.atdsrvnum, l_resumo.atdsrvano,
                           l_resumo.aviproseq
  fetch c_ctd33g00_01 into l_atdsrvseq
  close c_ctd33g00_01

  if l_atdsrvseq is null then
     let l_atdsrvseq = 0
  end if

  let l_atdsrvseq = l_atdsrvseq + 1
  
  #whenever error continue
  execute p_ctd33g00_ins using l_resumo.atdsrvnum,
                               l_resumo.atdsrvano,
                               l_resumo.aviproseq,
                               l_atdsrvseq,
                               l_retdat,
                               l_devdat,
                               l_resumo.diaqtd,
                               l_resumo.empcod
  #whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro ", sqlca.sqlcode, " em p_ctd33g00_ins"
  end if

  return l_msg

end function

# Remove solicitacao de reserva de veiculo com dados de detalhes
#----------------------------------------------------------------
function ctd33g00_del_resumo(l_resumo)
#----------------------------------------------------------------

  define l_resumo record
         atdsrvnum        like datmrsrsrvrsm.atdsrvnum    ,
         atdsrvano        like datmrsrsrvrsm.atdsrvano    ,
         aviproseq        like datmrsrsrvrsm.aviproseq
  end record

  define l_msg     char(80)
  
  if m_ctd33g00_prep is null or
     m_ctd33g00_prep != true
     then
     call ctd33g00_prepare()
  end if

  let l_msg = null

  open c_ctd33g00_02 using l_resumo.atdsrvnum, l_resumo.atdsrvano,
                           l_resumo.aviproseq
  fetch c_ctd33g00_02

  if sqlca.sqlcode <> notfound then
     execute p_ctd33g00_del using l_resumo.atdsrvnum,
                                  l_resumo.atdsrvano,
                                  l_resumo.aviproseq

     if sqlca.sqlcode <> 0 then
        let l_msg = "Erro ", sqlca.sqlcode, " em p_ctd33g00_del"
     end if
   
     close c_ctd33g00_02
  end if

  return l_msg

end function

#----------------------------------------------------------------
function ctd33g00_tot_resumo(l_resumo)
#----------------------------------------------------------------

  define l_resumo record
         atdsrvnum        like datmrsrsrvrsm.atdsrvnum    ,
         atdsrvano        like datmrsrsrvrsm.atdsrvano
  end record

  define l_tot integer
  
  if m_ctd33g00_prep is null or
     m_ctd33g00_prep != true
     then
     call ctd33g00_prepare()
  end if

  let l_tot = 0
  open c_ctd33g00_03 using l_resumo.atdsrvnum, l_resumo.atdsrvano,
                           l_resumo.atdsrvnum, l_resumo.atdsrvano
  fetch c_ctd33g00_03 into l_tot
  close c_ctd33g00_03
  return l_tot

end function

