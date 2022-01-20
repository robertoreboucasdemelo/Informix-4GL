#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g03                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DBSMOPGCST         #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd20g03_prep smallint

#---------------------------#
function ctd20g03_prepare()
#---------------------------#
   define l_sql  char(1000)
   
   let l_sql = "select sum(socopgitmcst)",
               "  from dbsmopgcst       ",
               " where socopgnum    = ? ",
               "   and socopgitmnum = ? "     
                         
   prepare pctd20g03001 from l_sql
   declare cctd20g03001 cursor with hold for pctd20g03001
   
   let m_ctd20g03_prep = true

end function

#-------------------------------------------------------#
function ctd20g03_custo_item(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          socopgnum        like dbsmopgcst.socopgnum
         ,socopgitmnum     like dbsmopgcst.socopgitmnum
   end record

   define lr_retorno       record
          socopgitmcst     like dbsmopgcst.socopgitmcst
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_ctd20g03_prep is null or
      m_ctd20g03_prep <> true then
      call ctd20g03_prepare()
   end if  

   let l_resultado = 0
   let l_mensagem  = null
   initialize lr_retorno.* to null

   whenever error continue
   
   open  cctd20g03001 using lr_param.socopgnum, lr_param.socopgitmnum
   fetch cctd20g03001 into  lr_retorno.socopgitmcst

   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em dbsmopgcst "
      else
         let l_resultado = 3
         let l_mensagem = "Erro na selecao de dbsmopgcst ", sqlca.sqlcode
      end if
   end if

   close cctd20g03001

   return l_resultado, l_mensagem, lr_retorno.socopgitmcst

end function
