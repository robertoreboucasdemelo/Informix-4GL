# Sistema.......: Porto Socorro                                               #
# Modulo........: ctd22g00                                                    #
# Analista Resp.: Kevellin Olivatti                                           #
# PSI...........: 227587                                                      #
# Objetivo......: Buscar informacoes sobre número de passageiros para         #
#                 serviços de táxi                                            #
#.............................................................................#
# Desenvolvimento: Kevellin Olivatti                                          #
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

   define m_prep_sql smallint

#---------------------------
function ctd22g00_prepare()
#---------------------------

   define l_sql char(400)

    let l_sql = 'select atdsrvnum, ',
                    ' atdsrvano, ',
                    ' passeq, ',
                    ' pasnom, ',
                    ' pasidd ',
               ' from datmpassageiro ',
              ' where atdsrvnum = ? ',
              '   and atdsrvano = ? '

   prepare p_ctd22g00_001 from l_sql
   declare c_ctd22g00_001 cursor for p_ctd22g00_001

   let l_sql = 'select max(passeq) ',
                ' from datmpassageiro ',
               ' where atdsrvnum = ? ',
               '   and atdsrvano = ? '

   prepare p_ctd22g00_002 from l_sql
   declare c_ctd22g00_002 cursor for p_ctd22g00_002

   let m_prep_sql = true

end function

#-------------------------------------------
function ctd22g00_inf_numpassageiros(l_atdsrvnum, l_atdsrvano)
#-------------------------------------------

   define l_atdsrvnum  like datmservico.atdsrvnum,
          l_atdsrvano  like datmservico.atdsrvano,
          l_msg        char(200)

   define lr_retorno record
          erro           smallint                   ,
          mensagem       char(100)                  ,
          numpassageiros like datmpassageiro.passeq
   end record

   initialize lr_retorno to null
   let m_prep_sql = false

   if l_atdsrvnum is null or l_atdsrvano is null then
      let lr_retorno.erro = 3
      let lr_retorno.mensagem = 'Parametro nulo'
      return lr_retorno.*
   end if

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd22g00_prepare()
   end if

   open c_ctd22g00_002 using l_atdsrvnum,
                           l_atdsrvano
   whenever error continue

   fetch c_ctd22g00_002 into lr_retorno.numpassageiros

   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.erro = 2
         let lr_retorno.mensagem = 'Numero de passageiro(s) para o servico ' + l_atdsrvnum + ' nao encontrado'
      else
         let lr_retorno.erro = 3
         let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em datmpassageiro'
      end if
   else
      let lr_retorno.mensagem = ""
      let lr_retorno.erro = 1
   end if

   return lr_retorno.*

end function
