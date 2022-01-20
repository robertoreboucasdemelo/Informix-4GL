#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Porto Socorro                                       #
# Modulo        : ctn18c01.4gl                                        #
# Analista Resp.: Priscila Staingel                                   #
# OSF/PSI       : 198390                                              #
#                Lista dos locais de entrega de uma loja para         #
#                CARRO EXTA                                           #
#                                                                     #
# Desenvolvedor  : Priscila Staingel                                  #
# DATA           : 22/02/2006                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#---------------------------------------------------------------------#

database porto

define m_prepara_sql  smallint

#------------------------#
function ctn18c01_prep()
#------------------------#
  define l_sql_stmt  char(1500)

  #Buscar nome da locadora
  let l_sql_stmt = "select lcvnom     "
                  ,"from datklocadora "
                  ,"where lcvcod = ?  "
  prepare p_ctn18c01_001  from l_sql_stmt
  declare c_ctn18c01_001 cursor for p_ctn18c01_001

  #Buscar nome da loja pelo aviestcod (codigo da loja)
  let l_sql_stmt = "select lcvextcod, aviestnom   "
                   ,"from datkavislocal "
                   ,"where lcvcod = ?   "
                   ," and aviestcod = ? "
  prepare p_ctn18c01_002  from l_sql_stmt
  declare c_ctn18c01_002 cursor for p_ctn18c01_002

  #Buscar locais de entrega de uma loja
  let l_sql_stmt = "select cidcod, etgtaxvlr   "
                  ," from datklcletgvclext     "
                  ," where lcvcod = ?          "
                  ,"   and aviestcod = ?       "
                  ,"   and etglclsitflg = 'A'  "
  prepare p_ctn18c01_003  from l_sql_stmt
  declare c_ctn18c01_003 cursor for p_ctn18c01_003

  let m_prepara_sql = true
end function


#---------------------------------------------------------------
 function ctn18c01(param)
#---------------------------------------------------------------

define param record
  lcvcod       like datklcletgvclext.lcvcod,
  aviestcod    like datklcletgvclext.aviestcod
end record

define m_ctn18c01 record
  lcvextcod    like datkavislocal.lcvextcod,
  lcvnom       like datklocadora.lcvnom,
  aviestnom    like datkavislocal.aviestnom
end record

define a_ctn18c01 array[100] of record
  cidnom     like glakcid.cidnom,
  ufdcod     like glakcid.ufdcod,
  etgtaxvlr  like datklcletgvclext.etgtaxvlr
end record

define a_ctn18c0102 array[100] of record
  cidcod     like datklcletgvclext.cidcod
end record

define arr_aux    smallint,
       l_ret      smallint,
       l_msg      char(60)

initialize a_ctn18c01 to null
let arr_aux = null
  if m_prepara_sql is null or
     m_prepara_sql <> true then
     call ctn18c01_prep()
  end if

  open window w_ctn18c01 at 8,12 with form "ctn18c01"
      attribute(form line first, border)

  message "(F17)Abandona"
  #Buscar nome da locadora e da loja
  open c_ctn18c01_001 using param.lcvcod
  whenever error continue
  fetch c_ctn18c01_001 into m_ctn18c01.lcvnom
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = 100 then
        error "Locadora nao encontrada."
     else
        error "Problemas ao buscar nome da locadora!!"
     end if
     return
  end if

  open c_ctn18c01_002 using param.lcvcod,
                          param.aviestcod
  whenever error continue
  fetch c_ctn18c01_002 into m_ctn18c01.lcvextcod,
                          m_ctn18c01.aviestnom
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = 100 then
        error "Loja nao encontrada para a locadora."
     else
        error "Problemas ao buscar nome da loja!!"
     end if
     return
  end if

  #Exibir na tela
  display by name param.lcvcod
  display by name m_ctn18c01.lcvnom
  display by name m_ctn18c01.lcvextcod
  display by name m_ctn18c01.aviestnom

  #Buscar cidades e taxas de entrega
  let arr_aux = 1
  open c_ctn18c01_003 using param.lcvcod,
                          param.aviestcod
  foreach c_ctn18c01_003 into a_ctn18c0102[arr_aux].cidcod,
                            a_ctn18c01[arr_aux].etgtaxvlr
    #Pegar cidade e estado do cidcod
    call cty10g00_cidade_uf(a_ctn18c0102[arr_aux].cidcod)
        returning l_ret,
                  l_msg,
                  a_ctn18c01[arr_aux].cidnom,
                  a_ctn18c01[arr_aux].ufdcod
    if l_ret <> 1 then
        #nao encontrou descricao para cidcod
        continue foreach
    end if
    let arr_aux = arr_aux + 1
  end foreach

  #Exibir array na tela
  display array a_ctn18c01 to s_ctn18c01.*
     on key (f17, control-c, interrupt)
             initialize a_ctn18c01 to null
             exit display
  end display

  close window w_ctn18c01

end function


