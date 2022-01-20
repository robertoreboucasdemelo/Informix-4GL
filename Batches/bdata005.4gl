#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Central Itau                                               #
# Modulo.........: bdata005                                                   #
# Objetivo.......: Batch Para Carregar os Enderecos Indexados do Itau (RE)    #
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

   define l_path char(200)

   let m_path_log = null
   let m_path_log = f_path("DAT","LOG")

   if m_path_log is null or
      m_path_log = " " then
      let m_path_log = "."
   end if

  
   display 'DIRETORIO DE LOG: ',m_path_log

   let m_path_log = m_path_log clipped, "/bdata005.log"

   call startlog(m_path_log)


   call cts55m00()

#========================================================================
end main
#========================================================================



function fonetica2(a)
define a char(50)
let a = null

return a
end function
