#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g08                                                   #
# ANALISTA RESP..: Fabio Costa                                                #
# PSI/OSF........: 246174 - iPhone                                            #
# Objetivo.......: Modulo responsavel pelo acesso a tabela DATRSERVAPOL       #
#                  (relacionamento servico X apolice)                         #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd20g08_prep smallint

#---------------------------#
function ctd20g08_prepare()
#---------------------------#
   define l_sql char(400)
   
   let l_sql = ' select succod,  ramcod, aplnumdig,  itmnumdig, edsnumref ',
               ' from datrservapol ',
               ' where atdsrvnum = ? ',
               '   and atdsrvano = ? '
   prepare p_servapol_sel from l_sql
   declare c_servapol_sel cursor with hold for p_servapol_sel
   
   let l_sql = ' insert into datrservapol(succod   , ',  # NN
               '                          ramcod   , ',  # NN
               '                          aplnumdig, ',  # NN
               '                          itmnumdig, ',  # NN
               '                          edsnumref, ',  # NN
               '                          atdsrvnum, ',  # NN
               '                          atdsrvano) ',  # NN
               ' values (?,?,?,?,?,?,?)'
   prepare p_datrservapol_ins from l_sql

   let m_ctd20g08_prep = true

end function

#----------------------------------------------------------------
function ctd20g08_servapol_sel(lr_param)
#----------------------------------------------------------------

   define lr_param record
          nivel_retorno  smallint ,
          atdsrvnum      like  datrservapol.atdsrvnum ,
          atdsrvano      like  datrservapol.atdsrvano
   end record
   
   define l_retorno record
          succod     like  datrservapol.succod    ,
          ramcod     like  datrservapol.ramcod    ,
          aplnumdig  like  datrservapol.aplnumdig ,
          itmnumdig  like  datrservapol.itmnumdig ,
          edsnumref  like  datrservapol.edsnumref
   end record
   
   define l_err  integer ,
          l_msg  char(50)
          
   if m_ctd20g08_prep is null or
      m_ctd20g08_prep <> true then
      call ctd20g08_prepare()
   end if
   
   initialize l_retorno.* to null
   
   whenever error continue
   open  c_servapol_sel using lr_param.atdsrvnum, lr_param.atdsrvano 
   fetch c_servapol_sel into l_retorno.succod   ,
                             l_retorno.ramcod   ,
                             l_retorno.aplnumdig,
                             l_retorno.itmnumdig,
                             l_retorno.edsnumref 
   whenever error stop               
   
   let l_err = sqlca.sqlcode
   
   if lr_param.nivel_retorno = 1
      then
      return l_err,
             l_retorno.succod   ,
             l_retorno.ramcod   ,
             l_retorno.aplnumdig,
             l_retorno.itmnumdig,
             l_retorno.edsnumref 
   end if
   
end function

#----------------------------------------------------------------
function ctd20g08_servapol_ins(l_param)
#----------------------------------------------------------------

   define l_param record
          succod     like  datrservapol.succod    ,
          ramcod     like  datrservapol.ramcod    ,
          aplnumdig  like  datrservapol.aplnumdig ,
          itmnumdig  like  datrservapol.itmnumdig ,
          edsnumref  like  datrservapol.edsnumref ,
          atdsrvnum  like  datrservapol.atdsrvnum ,
          atdsrvano  like  datrservapol.atdsrvano
   end record
   
   if m_ctd20g08_prep is null or
      m_ctd20g08_prep <> true then
      call ctd20g08_prepare()
   end if  
   
   whenever error continue
   execute p_datrservapol_ins using l_param.succod   ,
                                    l_param.ramcod   ,
                                    l_param.aplnumdig,
                                    l_param.itmnumdig,
                                    l_param.edsnumref,
                                    l_param.atdsrvnum,
                                    l_param.atdsrvano
   whenever error stop
   
   return sqlca.sqlcode

end function

