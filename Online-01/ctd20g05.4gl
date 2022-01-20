#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g05                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DBSMOPGSIN         #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd20g05_prep smallint

#---------------------------#
function ctd20g05_prepare()
#---------------------------#
   define l_sql  char(500)
   
   let l_sql = " insert into dbsmopgsin (socopgnum   , ",   # nn
                            "            socopgitmnum, ",   # nn
                            "            ramcod      , ",   # nn
                            "            sinnum      , ",   # nn
                            "            sinano      ) ",   # nn
                            "    values (?, ?, ?, ?, ?)"  

   prepare pctd20g05001 from l_sql
   
   let m_ctd20g05_prep = true

end function

#-------------------------------------------------------#
function ctd20g05_ins_opgsin(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          socopgnum        like dbsmopgsin.socopgnum
         ,socopgitmnum     like dbsmopgsin.socopgitmnum
         ,ramcod           like dbsmopgsin.ramcod    
         ,sinnum           like dbsmopgsin.sinnum    
         ,sinano           like dbsmopgsin.sinano    
   end record

   define l_mensagem    char(60)

   if m_ctd20g05_prep is null or
      m_ctd20g05_prep <> true then
      call ctd20g05_prepare()
   end if  
   
   let l_mensagem  = null
   
   whenever error continue
   execute pctd20g05001 using lr_param.*
   whenever error stop
   
   if sqlca.sqlcode != 0
      then
      let l_mensagem = "Erro em dbsmopgsin ", sqlca.sqlcode
   end if
   
   return sqlca.sqlcode, l_mensagem 

end function
