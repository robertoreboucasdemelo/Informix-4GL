#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g06                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DBSROPGDSC         #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd20g06_prep smallint

#---------------------------#
function ctd20g06_prepare()
#---------------------------#
   define l_sql  char(200)
   
   let l_sql = " select sum(dscvlr) ",
               " from dbsropgdsc ",
               " where socopgnum = ? "
   prepare pctd20g06001 from l_sql
   declare cctd20g06001 cursor with hold for pctd20g06001
   
   let m_ctd20g06_prep = true

end function

#-------------------------------------------------------#
function ctd20g06_tot_desc(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          socopgnum        like dbsropgdsc.socopgnum
   end record

   define lr_retorno       record
          dscvlr           like dbsropgdsc.dscvlr
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_ctd20g06_prep is null or
      m_ctd20g06_prep <> true then
      call ctd20g06_prepare()
   end if  

   let l_resultado = 0
   let l_mensagem  = null
   initialize lr_retorno.* to null

   whenever error continue
   
   open  cctd20g06001 using lr_param.socopgnum
   fetch cctd20g06001 into  lr_retorno.*

   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em dbsropgdsc "
      else
         let l_resultado = 3
         let l_mensagem = "Erro na selecao de dbsropgdsc ", sqlca.sqlcode
      end if
   end if

   close cctd20g06001

   return l_resultado, l_mensagem, lr_retorno.dscvlr

end function

