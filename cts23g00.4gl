#######################################################################
#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : cts23g00.4gl                                        #
# Analista Resp.:                                                     #
# OSF/PSI       :                                                     #
#                                                                     #
# Desenvolvedor  : Marcus                                             #
# DATA           : Abr/2001                                           #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 29/08/2006  Priscila       PSI202363 Incluir tipo retorno 4         #
#---------------------------------------------------------------------#

database porto

  define m_cts23g00_prep smallint

#-------------------------#
function cts23g00_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_sql  =  null

  let l_sql = " select mpacidcod, ",
                     " cidnom, ",
                     " ufdcod, ",
                     " caddat, ",
                     " lclltt, ",
                     " lcllgt, ",
                     " mpacrglgdflg, ",
                     " gpsacngrpcod ",
                " from datkmpacid ",
               " where mpacidcod = ? "

  prepare p_cts23g00_001 from l_sql
  declare c_cts23g00_001 cursor for p_cts23g00_001

  let l_sql = " select mpacidcod, ",
                     " cidnom, ",
                     " ufdcod, ",
                     " caddat, ",
                     " lclltt, ",
                     " lcllgt, ",
                     " mpacrglgdflg, ",
                     " gpsacngrpcod ",
                " from datkmpacid ",
               " where cidnom = ? ",
                 " and ufdcod = ? "

  prepare p_cts23g00_002 from l_sql
  declare c_cts23g00_002 cursor for p_cts23g00_002

  let m_cts23g00_prep = true

end function

#---------------------------------#
function cts23g00_inf_cidade(param)
#---------------------------------#

  define param        record
         tipo_ret     smallint,
         mpacidcod    like datkmpacid.mpacidcod,
         cidnom       char(40),
         ufdcod       char(2)
  end record

  define a_cts23g00   record
         mpacidcod    like datkmpacid.mpacidcod,
         cidnom       like datkmpacid.cidnom,
         ufdcod       like datkmpacid.ufdcod,
         caddat       like datkmpacid.caddat,
         lclltt       like datkmpacid.lclltt,
         lcllgt       like datkmpacid.lcllgt,
         mpacrglgdflg like datkmpacid.mpacrglgdflg,
         gpsacngrpcod like datkmpacid.gpsacngrpcod
  end record

  define result integer


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	result  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  a_cts23g00.*  to  null

  if m_cts23g00_prep is null or
     m_cts23g00_prep <> true then
     call cts23g00_prepare()
  end if

  let result = null

  initialize a_cts23g00 to null

  if param.mpacidcod <> " " and
     param.mpacidcod is not null then

     open c_cts23g00_001 using param.mpacidcod
     fetch c_cts23g00_001 into a_cts23g00.mpacidcod,
                             a_cts23g00.cidnom,
                             a_cts23g00.ufdcod,
                             a_cts23g00.caddat,
                             a_cts23g00.lclltt,
                             a_cts23g00.lcllgt,
                             a_cts23g00.mpacrglgdflg,
                             a_cts23g00.gpsacngrpcod
     close c_cts23g00_001

  else
     open c_cts23g00_002 using param.cidnom, param.ufdcod
     fetch c_cts23g00_002 into a_cts23g00.mpacidcod,
                             a_cts23g00.cidnom,
                             a_cts23g00.ufdcod,
                             a_cts23g00.caddat,
                             a_cts23g00.lclltt,
                             a_cts23g00.lcllgt,
                             a_cts23g00.mpacrglgdflg,
                             a_cts23g00.gpsacngrpcod
     close c_cts23g00_002

  end if

 let result = sqlca.sqlcode

 case param.tipo_ret
    when 1
         # Completo
         return result,
                a_cts23g00.mpacidcod,
                a_cts23g00.cidnom,
                a_cts23g00.ufdcod,
                a_cts23g00.caddat,
                a_cts23g00.lclltt,
                a_cts23g00.lcllgt,
                a_cts23g00.mpacrglgdflg,
                a_cts23g00.gpsacngrpcod
    when 2
         # Acionamento
         return result,
                a_cts23g00.mpacidcod,
                a_cts23g00.lclltt,
                a_cts23g00.lcllgt,
                a_cts23g00.mpacrglgdflg,
                a_cts23g00.gpsacngrpcod
    when 3
         # Coordenadas
         return result,
                a_cts23g00.lclltt,
                a_cts23g00.lcllgt
     when 4                         #PSI202363
         # Tipo de acionamento
         return  result,
                 a_cts23g00.gpsacngrpcod
 end case

end function
