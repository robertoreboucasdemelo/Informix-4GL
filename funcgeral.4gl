#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Central 24hs                                                #
# Modulo........: ctc96m00                                                    #
# Analista Resp.: Amilton Pinto                                               #
# PSI...........: PSI-2012-15987                                              #
# Objetivo......: Funcoes gerais                                              #
#.............................................................................#
# Desenvolvimento: Amilton Pinto                                              #
# Liberacao......: 29/06/2012                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
database porto 

define m_fungeral_prep smallint

#============================
function fungeral_prepare()
#============================
 define l_sql char(500)

 let l_sql =  '    select funnom          '
             ,'      from isskfunc        '
             ,'     where empcod = ?      '
             ,'       and funmat = ?      '

 prepare pctc91m00001 from l_sql
 declare cctc91m00001 cursor for pctc91m00001

 let m_fungeral_prep = 1

end function


#================================
function fungeral_trim(l_string)
#================================
 define l_string     char(200)
 define l_tamanho    smallint
 define i            smallint
 define l_aux        char(200)

 let l_string = l_string clipped
 let l_tamanho = length(l_string)

 for i = 1 to l_tamanho
     if l_string[i] <> " " then
        let l_aux = l_string[i,l_tamanho] clipped
        exit for
     else
       continue for
     end if
 end for
 return l_aux

end function

#==============================================
 function fungeral_func(l_empcod, l_funmat)
#==============================================

 define  l_empcod      smallint
 define  l_funmat      smallint
 define  l_funnom      char(80)

 if m_fungeral_prep <> 1 then
    call fungeral_prepare()
 end if
 
 whenever error continue
 open cctc91m00001 using l_empcod,
                         l_funmat
 
 fetch cctc91m00001 into l_funnom
 whenever error stop
 
  if sqlca.sqlcode = notfound then
    let l_funnom = '    '
  else
    if sqlca.sqlcode <> 0 then
       error 'Erro (',sqlca.sqlcode,') na Busca do nome do funcionario. Avise a Informatica!'
    end if
  end if
 
 close cctc91m00001
 
 let l_funnom = upshift(l_funnom)
 #let l_funnom = 'Amilton'
 
 return l_funnom

end function
