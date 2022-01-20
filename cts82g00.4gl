#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24 Horas/Porto Socorro                            #
# Modulo.........: cts82g00                                                  #
# Objetivo.......: Funcoes Genericas Permissoes do Cartao                    #
# Analista Resp. : Roberto Melo                                              #
# PSI            : 211982                                                    #
#............................................................................#
# Desenvolvimento: Roberto                                                   #
# Liberacao      : 30/10/2007                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_cts82g00 smallint

#---------------------------#
 function cts82g00_prepare()
#---------------------------#


define l_sql  char(500)

let l_sql = " select count(*) "
           ,"   from datkcarpms a ,"
           ,"        glakcid    b "
           ,"  where a.cidcod = b.cidcod "
           ,"  and   b.cidnom    = ? "
           ,"    and b.ufdcod    = ? "
           ,"    and a.c24astcod = ? "
           ,"    and a.empcod    = ? "
           ,"    and a.atvstt    = 'A' "

prepare p_cts82g00_001 from l_sql
declare c_cts82g00_001 cursor for p_cts82g00_001

let l_sql = " select count(*)    "
           ," from datkcarpms    "
           ," where atvstt = 'A' "
           ," and   c24astcod = ?"

prepare p_cts82g00_002 from l_sql
declare c_cts82g00_002 cursor for p_cts82g00_002

let m_prep_cts82g00 = true

end function

#-------------------------------#
 function cts82g00_permite(lr_param)
#-------------------------------#

define lr_param record
       cidnom    like glakcid.cidnom         ,
       ufdcod    like glakcid.ufdcod         ,
       c24astcod like datkassunto.c24astcod  ,
       empcod    like gabkemp.empcod
end record

define lr_retorno record
       mens char(50) ,
       erro smallint ,
       qtd  integer
end record

initialize lr_retorno.* to null

if m_prep_cts82g00 is null or
   m_prep_cts82g00 <> true then
    call cts82g00_prepare()
end if

   whenever error continue
   open c_cts82g00_001  using lr_param.*

   fetch c_cts82g00_001  into lr_retorno.qtd

   whenever error stop

   if sqlca.sqlcode <> 0 then
         let lr_retorno.mens  = "Erro : ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," no acesso a tabela datkcarpms"
         let lr_retorno.erro = 1
   else
       if lr_retorno.qtd = 0 then
            let lr_retorno.mens = "Assunto não Permitido para esta Cidade"
            let lr_retorno.erro = 1
       else
            let lr_retorno.erro = 0
       end if
   end if

   return lr_retorno.*

end function

#-------------------------------#
 function cts82g00_acessa(lr_param)
#-------------------------------#

define lr_param record
       c24astcod like datkassunto.c24astcod
end record

define lr_retorno record
       mens char(50) ,
       erro smallint ,
       qtd  integer
end record

initialize lr_retorno.* to null

if m_prep_cts82g00 is null or
   m_prep_cts82g00 <> true then
    call cts82g00_prepare()
end if

   whenever error continue
   open c_cts82g00_002 using lr_param.c24astcod

   fetch c_cts82g00_002  into lr_retorno.qtd

   whenever error stop

   if sqlca.sqlcode <> 0 then
         let lr_retorno.mens  = "Erro : ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," no acesso a tabela datkcarpms"
         let lr_retorno.erro = 1
   else
         let lr_retorno.erro = 0
   end if

   return lr_retorno.*

end function
