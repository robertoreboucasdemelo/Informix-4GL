#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cts20g12                                                   #
# Analista Resp.: Carlos Ruiz                                                #
# PSI           : 202720                                                     #
#                 Obter os dados da tabela datrligppt                        #
#............................................................................#
# Desenvolvimento: Priscila Staingel                                         #
# Liberacao      : 22/09/2006                                                #
#............................................................................#
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#----------------------------------------------------------------------------# 

 database porto

#----------------------------------------------------------------------------
 function cts20g12_prepare()
#----------------------------------------------------------------------------

 define l_sql char (900)

 let l_sql =  " select cmnnumdig ",
              "  from datrligppt ",
              " where lignum = ? "
 prepare pcts20g12001 from l_sql
 declare ccts20g12001 cursor with hold for pcts20g12001

end function  ###  cts20g12_prepare

#----------------------------------------------------------------------------
function cts20g12_contrato(l_lignum)
#----------------------------------------------------------------------------

   define l_lignum     like datrligppt.lignum

   define l_retorno    record
      resultado           smallint,
      mensagem            char(80),
      cmnnumdig           like datrligppt.cmnnumdig
   end record

   initialize l_retorno.* to null
  
   whenever error continue
   open ccts20g12001 using l_lignum
   if status <> 0 then
      call cts20g12_prepare()
      open ccts20g12001 using l_lignum  
   end if
   whenever error stop
  
   fetch ccts20g12001 into l_retorno.cmnnumdig
   if sqlca.sqlcode = 0 then
      #encontrou registro
      let l_retorno.resultado = 1
   else
      if sqlca.sqlcode = notfound then
          #caso nao encontre registro
          let l_retorno.resultado = 2
          let l_retorno.mensagem = "Nao encontrada apolice para o servico"
      else
          let l_retorno.resultado = 3
          let l_retorno.mensagem = "Erro SELECT ccts20g12001 /", sqlca.sqlcode, 
                           "/", sqlca.sqlerrd[2]
      end if
   end if
   close ccts20g12001 
  
   return l_retorno.resultado,
          l_retorno.mensagem,
          l_retorno.cmnnumdig 
  
end function

