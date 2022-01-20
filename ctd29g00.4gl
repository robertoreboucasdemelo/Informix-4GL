#-----------------------------------------------------------------------------#
# Porto Seguro Seguradora                                                     #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctd29g00                                                    #
# Analista Resp.: Sergio Burini                                               #
# PSI...........: 240591                                                      #
# Objetivo......: HISTORICO DE INDEXAÇÕES ATRAVES DO DAF                      #
#.............................................................................#
# Desenvolvimento: Sergio Burini                                              #
# Liberacao......:                                                            #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#

 database porto

 define m_prepare smallint

#---------------------------#
 function ctd29g00_prepare()
#---------------------------#

 define l_sql char(2000)

 let l_sql = "insert into dpcmdafidxsrvhst values (?,?,?,?,?,?,?,?,?,?,?,?,?)"

 prepare p_ctd29g00_001 from l_sql
 declare c_ctd29g00_001 cursor for p_ctd29g00_001

 let l_sql = "select max(srvhstseq) ",
              " from dpcmdafidxsrvhst ",
             " where atdsrvnum = ? ",
               " and atdsrvano = ? "

 prepare p_ctd29g00_002 from l_sql
 declare c_ctd29g00_002 cursor for p_ctd29g00_002

 if  m_prepare is null or
     m_prepare = false then
     let m_prepare = true
 end if

 end function

#-----------------------------------------#
 function ctd29g00_insere_historico(param)
#-----------------------------------------#

 define param record
     tipend    smallint,
     atdsrvnum like dpcmdafidxsrvhst.atdsrvnum,
     atdsrvano like dpcmdafidxsrvhst.atdsrvano,
     endlgdtip like dpcmdafidxsrvhst.endlgdtip,
     endlgd    like dpcmdafidxsrvhst.endlgd,
     endlgdnum like dpcmdafidxsrvhst.endlgdnum,
     endbrrnom like dpcmdafidxsrvhst.endbrrnom,
     ciddes    like dpcmdafidxsrvhst.ciddes,
     ufdcod    like dpcmdafidxsrvhst.ufdcod,
     lclltt    like dpcmdafidxsrvhst.lclltt,
     lcllgt    like dpcmdafidxsrvhst.lcllgt,
     atldat    like dpcmdafidxsrvhst.atldat,
     funmat    like dpcmdafidxsrvhst.funmat
 end record
 define lr_retorno record
     errcod smallint,
     errmsg char(50)
 end record

 define l_srvhstseq like dpcmdafidxsrvhst.srvhstseq

 if  not m_prepare then
     call ctd29g00_prepare()
 end if

 call ctd29g00_seleciona_max_seq(param.atdsrvnum,
                                 param.atdsrvano)
      returning l_srvhstseq

 let l_srvhstseq = l_srvhstseq + 1

 if  param.endlgdtip is null or param.endlgdtip = " " then
     let param.endlgdtip = 'NAO CONSTA'
 end if

 if  param.endlgd is null or param.endlgd = " " then
     let param.endlgd = 'NAO CONSTA'
 end if

 if  param.endlgdnum is null or param.endlgdnum = " " then
     let param.endlgdnum = '0'
 end if
 if  param.endbrrnom is null or param.endbrrnom = " " then
     let param.endbrrnom = 'NAO CONSTA'
 end if
 if  param.ciddes is null or param.ciddes = " " then
     let param.ciddes = 'NAO CONSTA'
 end if
 if  param.ufdcod is null or param.ufdcod = " " then
     let param.ufdcod = 'NAO CONSTA'
 end if

 whenever error continue
 execute c_ctd29g00_001 using param.atdsrvnum,
                             param.atdsrvano,
                             param.endlgdtip,
                             param.endlgd,
                             param.endlgdnum,
                             param.endbrrnom,
                             param.ciddes,
                             param.ufdcod,
                             param.lclltt,
                             param.lcllgt,
                             param.atldat,
                             param.funmat
 whenever error stop
 let lr_retorno.errcod = sqlca.sqlcode
 if  sqlca.sqlcode <> 0 then
     let lr_retorno.errmsg = 'ERRO na inclusão do historico. c_ctd29g00_001 ', sqlca.sqlcode
 else
     let lr_retorno.errmsg = 'Inclusão de historico efetuada com sucesso.'
 end if
 return lr_retorno.errcod,
        lr_retorno.errmsg

 end function

#------------------------------------------#
 function ctd29g00_seleciona_max_seq(param)
#------------------------------------------#
 define param record
     atdsrvnum like dpcmdafidxsrvhst.atdsrvnum,
     atdsrvano like dpcmdafidxsrvhst.atdsrvano
 end record
 define l_srvhstseq like dpcmdafidxsrvhst.srvhstseq
 if  not m_prepare then
     call ctd29g00_prepare()
 end if
 open c_ctd29g00_002 using param.atdsrvnum,
                          param.atdsrvano
 fetch c_ctd29g00_002 into l_srvhstseq
 if  sqlca.sqlcode <> 0 then
     if  sqlca.sqlcode <> 100 then
         display 'ERRO ao buscar sequencia de historico. c_ctd29g00_002 ', sqlca.sqlcode
     end if
     let l_srvhstseq = 0
 end if
 return l_srvhstseq
 end function
