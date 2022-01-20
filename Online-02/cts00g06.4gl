#-----------------------------------------------------------------------------#
#                      PORTO SEGURO CIA DE SEGUROS GERAIS                     #
#.............................................................................#
#                                                                             #
#  Modulo              : cts00g06                                             #
#  Analista Responsavel: Ligia Mattge                                         #
#  PSI/OSF             :                                                      #
#                                                                             #
#.............................................................................#
#                                                                             #
#  Desenvolvimento     :                                                      #
#  Data                : 21/12/2006                                           #
#-----------------------------------------------------------------------------#
# Raji Jahchan  04/01/2010  CT 10010232  Selecionar registro MDT pela sequencia
#-----------------------------------------------------------------------------#

database porto

define m_comando    char(1500)
      ,m_prep       char(01)

#----------------------------------------------
function cts00g06_prepare()
#----------------------------------------------

  let m_comando = null

  let m_comando = " select mvt.caddat "
                 ,"   from datmmdtmvt mvt "
                 ,"  where mvt.mdtmvtseq = ( select max(ult.mdtmvtseq) "
                 ,"                            from datmmdtmvt ult "
                 ,"                           where ult.mdtcod = ?  )"
                 ,"    and mvt.caddat = ? "
  prepare pcts00g06001 from m_comando
  declare ccts00g06001 cursor for pcts00g06001

end function

#--------------------------------------
function cts00g06_checa_sinal(l_param)
#--------------------------------------
  define l_param      record
         mdtcod       like datmmdtmvt.mdtcod
        ,caddat       like datmmdtmvt.caddat
  end record

  define l_hostname   char(3)

  let l_hostname = null
  select unique sitename into l_hostname from dual

  ## nao tem sinais na base testes
  if l_hostname = "u07" then
     return "S"
  end if

  if m_prep is null then
     call cts00g06_prepare()
     let m_prep = "S"
  end if

  whenever error continue
  open  ccts00g06001 using l_param.mdtcod
                          ,l_param.caddat

  fetch ccts00g06001
  whenever error stop

  if sqlca.sqlcode = notfound then
     close ccts00g06001
     return "N"
  else
     if sqlca.sqlcode <> 0 then
        call errorlog("Erro na procura dos sinais do MDT")
        return "N"
     else
        close ccts00g06001
        return "S"
     end if
  end if

end function
