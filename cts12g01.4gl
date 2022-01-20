#------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                        #
#........................................................................#
# Sistema        : Central 24h                                           #
# Modulo         : cts12g01                                              #
# Analista.Resp  : Ligia Mattge                                          #
# PSI            : 188239                                                #
# Objetivo       : Obter o grupo do problema                             #
# Desenvolvimento: Mariana, Meta                                         #
# Liberacao      : 30/11/2004                                            #
#........................................................................#
#                    * * * Alteracoes * * *                              #
#                                                                        #
#    Data      Autor Fabrica   Origem  Alteracao                         #
#  ----------  -------------  -------- ----------------------------------#
#------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prepare              smallint

#--------------------------#
function cts12g01_prepare()
#--------------------------#

define l_comando          char(500)

   let l_comando = "select c24pbmgrpcod    "
                  ,"  from datrsocntzsrvre "
                  ," where socntzcod = ?   "
                  ,"   and ramcod    = ?   "
                  ,"   and clscod    = ?   "
                  ,"   and rmemdlcod = ?   "

   prepare p_cts12g01_001 from l_comando
   declare c_cts12g01_001 cursor for p_cts12g01_001

   let l_comando = "select c24pbmgrpcod    "
                  ,"  from datksocntz "
                  ," where socntzcod = ?   "

   prepare p_cts12g01_002 from l_comando
   declare c_cts12g01_002 cursor for p_cts12g01_002


   let m_prepare = true

end function

#----------------------------------------#
function cts12g01_grupo_problema(lr_param)
#----------------------------------------#

define lr_param                 record
       socntzcod                like datmsrvre.socntzcod
      ,ramcod                   like datrservapol.ramcod
      ,clscod                   char(05)
      ,rmemdlcod                like datrsocntzsrvre.rmemdlcod
                                end record

define l_c24pbmgrpcod           like datrsocntzsrvre.c24pbmgrpcod

define l_retorno                smallint
      ,l_mensagem               char(80)
      ,l_padrao	                smallint

      let l_c24pbmgrpcod = null
      let l_padrao = false

      if m_prepare is null or
         m_prepare <> true then
         call cts12g01_prepare()
      end if

      if g_documento.ciaempcod = 40 or
         g_documento.ciaempcod = 43 or # PSI 247936 Empresas 27
         g_documento.ciaempcod = 84 then # Itau

           whenever error continue
           open c_cts12g01_002 using lr_param.socntzcod
           fetch c_cts12g01_002 into l_c24pbmgrpcod
           whenever error stop


            if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode < 0 then
                 let l_mensagem  = "Erro : ", sqlca.sqlcode, '/', sqlca.sqlerrd[2]," -cts12g01_grupo_problema()"
                 let l_retorno = 3
              else
                 let l_mensagem = "Grupo nao cadastrado para este problema !"
                 let l_retorno  = 2
              end if
            else
               let l_retorno  = 1
            end if

            return l_retorno, l_mensagem, l_c24pbmgrpcod
      end if


      if lr_param.clscod is null or
         lr_param.clscod = " "  then
         let lr_param.clscod = null
      end if
      if lr_param.socntzcod is null or
         lr_param.ramcod    is null or
         lr_param.clscod    is null or
         lr_param.rmemdlcod is null then
         #let l_mensagem = "Parametros Incorretos !(cts12g01_grupo_problema())"
         #let l_retorno  = 3
         #return l_retorno, l_mensagem, l_c24pbmgrpcod
         let l_padrao = true
      end if


      #if l_padrao then
          whenever error continue
          open c_cts12g01_002 using lr_param.socntzcod
          fetch c_cts12g01_002 into l_c24pbmgrpcod
          whenever error stop
      #else
      #    whenever error continue
      #    open c_cts12g01_001 using lr_param.*
      #    fetch c_cts12g01_001 into l_c24pbmgrpcod
      #    whenever error stop
      #end if
      if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode < 0 then
           let l_mensagem  = "Erro : ", sqlca.sqlcode, '/', sqlca.sqlerrd[2]," -cts12g01_grupo_problema()"
           let l_retorno = 3
        else
           let l_mensagem = "Grupo nao cadastrado para este problema !"
           let l_retorno  = 2
        end if
      else
         let l_retorno  = 1
      end if

      return l_retorno, l_mensagem, l_c24pbmgrpcod

end function
