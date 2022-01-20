#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g02                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DBSMOPGFAS         #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd20g02_prep smallint

#---------------------------#
function ctd20g02_prepare()
#---------------------------#
   define l_sql  char(300)
   
   let l_sql = " select funmat from dbsmopgfas",
               " where socopgfascod = ?   and",
               "       socopgnum    = ?      "   
                         
   prepare pctd20g02001 from l_sql
   declare cctd20g02001 cursor with hold for pctd20g02001

   let l_sql = " insert into dbsmopgfas (socopgnum, socopgfascod, ",
               "                         socopgfasdat, socopgfashor, funmat) ",
               "                 values (?,?,?,?,?) "
                         
   prepare pctd20g02002 from l_sql
   
   let m_ctd20g02_prep = true

end function

#-------------------------------------------------------#
function ctd20g02_inf_faseop(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,socopgnum        like dbsmopgfas.socopgnum
         ,socopgfascod     like dbsmopgfas.socopgfascod
   end record

   define lr_retorno       record
          funmat           like dbsmopgfas.funmat
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_ctd20g02_prep is null or
      m_ctd20g02_prep <> true then
      call ctd20g02_prepare()
   end if  

   let l_resultado = 0
   let l_mensagem  = null
   initialize lr_retorno.* to null

   whenever error continue
   
   open  cctd20g02001 using lr_param.socopgfascod, lr_param.socopgnum
   fetch cctd20g02001 into  lr_retorno.funmat

   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em dbsmopgfas "
      else
         let l_resultado = 3
         let l_mensagem = "Erro na selecao de dbsmopgfas ", sqlca.sqlcode
      end if
   end if

   close cctd20g02001

   if lr_param.nivel_retorno = 1 then
      return l_resultado, l_mensagem, lr_retorno.funmat
   end if

end function

#-------------------------------------------------------#
function ctd20g02_insere_faseop(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          socopgnum        like dbsmopgfas.socopgnum
         ,socopgfascod     like dbsmopgfas.socopgfascod
         ,socopgfasdat     like dbsmopgfas.socopgfasdat
         ,socopgfashor     like dbsmopgfas.socopgfashor
         ,funmat           like dbsmopgfas.funmat
   end record

   if m_ctd20g02_prep is null or
      m_ctd20g02_prep <> true then
      call ctd20g02_prepare()
   end if  
   
   whenever error continue
   execute pctd20g02002 using lr_param.socopgnum, lr_param.socopgfascod,
                              lr_param.socopgfasdat, lr_param.socopgfashor, 
                              lr_param.funmat
   whenever error stop
   
   return sqlca.sqlcode

end function

