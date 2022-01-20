#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Central Azul                                               #
# Modulo.........: bdata003                                                   #
# Objetivo.......: Batch Para Carregar os Enderecos Indexados da Azul         #
# Analista Resp. : Carlos Ruiz                                                #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: R.Fornax                                                   #
# Liberacao      : 27/09/2014                                                 #
#.............................................................................#

database porto
define m_path_log        char(100)

globals
   define g_ismqconn smallint
end globals


#========================================================================
main
#========================================================================

  #call bdata003_cria_log()

   define l_path char(200)

   let m_path_log = null
   let m_path_log = f_path("DAT","LOG")

   if m_path_log is null or
      m_path_log = " " then
      let m_path_log = "."
   end if

  
   display 'DIRETORIO DE LOG: ',m_path_log

   let m_path_log = m_path_log clipped, "/bdata003.log"

   call startlog(m_path_log)

  call cts53m00()

#========================================================================
end main
#========================================================================

{#========================================================================
function bdata003_cria_log()
#========================================================================

   define l_path char(200)

   let l_path = null
   let l_path = f_path("DAT","LOG")

   if l_path is null or
      l_path = " " then
      let l_path = "."
   end if

   let l_path = m_path_log clipped, "bdata003.log"

   call startlog(l_path)

#========================================================================
end function
#========================================================================}



function fonetica2(a)
define a char(50)
let a = null

return a
end function
