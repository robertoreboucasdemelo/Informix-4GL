#############################################################################
# Nome do Modulo: cts06g09                                         Gilberto #
#                                                                   Marcelo #
# Funcoes Genericas - Pesquisa padrao logradouro Mapas             Nov/1999 #
#---------------------------------------------------------------------------#
# 13/09/2002  CORREIO EDU  Raji         Ordenar por lgd e bairro            #
#############################################################################
# 13/04/2004  Mariana, Fsw   OSF 34347  Inclusao do CEP                     #
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# --------   ------------- --------  ---------------------------------------#
# 19/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.             #
# 19/02/2014 Fabio, Fornax PSI-2014-03931IN Melhorias indexacao Fase 01     #
#---------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"   #PSI 195138

 define retorno         record
    lgdtip              like datkmpalgd.lgdtip,
    lgdnom              like datkmpalgd.lgdnom,
    lgdnum              like datmlcl.lgdnum,
    brrnom              like datmlcl.brrnom,
    lgdcep              like datmlcl.lgdcep,
    lgdcepcmp           like datmlcl.lgdcepcmp,
    lclltt              like datmlcl.lclltt,
    lcllgt              like datmlcl.lcllgt,
    mpacidcod           like datkmpacid.mpacidcod,
    c24lclpdrcod        like datmlcl.c24lclpdrcod,
    qtd                 smallint #PSI 195138
 end record

 define d_cts06g09      record
    lgdnompsq           like datkmpalgd.lgdnom,
    tippsq              char (01)
 end record

 define a_cts06g09      array[500]  of  record
    lgdnomtxt           char (71),
    lgdtip              like datkmpalgd.lgdtip,
    brrnom              like datkmpabrr.brrnom,
    mpalgdincnum        like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum        like datkmpalgdsgm.mpalgdfnlnum,
    lgdcep              like datmlcl.lgdcep,
    lgdcepcmp           like datmlcl.lgdcepcmp,
    lcllgt              like datkmpalgdsgm.lcllgt,
    lgdnom              like datkmpalgd.lgdnom,
    lclltt              like datkmpalgdsgm.lclltt,
    latlontxt           char(30)
 end record

 define a_cts06g09n     array[500]  of  record
    lgdnomtxt           char (71),
    lgdtip              like datkmpalgd.lgdtip,
    brrnom              like datkmpabrr.brrnom,
    mpalgdincnum        like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum        like datkmpalgdsgm.mpalgdfnlnum,
    lgdcep              like datmlcl.lgdcep,
    lgdcepcmp           like datmlcl.lgdcepcmp,
    lcllgt              like datkmpalgdsgm.lcllgt,
    lgdnom              like datkmpalgd.lgdnom,
    lclltt              like datkmpalgdsgm.lclltt,
    latlontxt           char(30)
 end record

 define ws              record
    prifoncod           like datkmpalgd.prifoncod,
    segfoncod           like datkmpalgd.segfoncod,
    terfoncod           like datkmpalgd.terfoncod,
    lgdnompsq           char (062),
    entfon              char (051),
    saifon              char (100),
    sql                 char (1200),
    prep                char (600),
    condicao            char (600),
    cont                dec  (6,0)
 end record

 define m_cepcod        dec(08,0)
 define m_cepcod_char   char(08)
 define arr_aux         smallint
 define arr_aux2        smallint

 define l_cep           dec(5,0)
 define  w_pf1 integer

#------------------------------------------------------------ ##PSI 195138
function cts06g09(param)
#------------------------------------------------------------
 define param           record
    lgdtippsq           like datkmpalgd.lgdtip,
    lgdnompsq           like datkmpalgd.lgdnom,
    lgdnumpsq           like datmlcl.lgdnum,
    brrnompsq           like datmlcl.brrnom,
    mpacidcod           like datkmpacid.mpacidcod
 end record

 let  arr_aux  =  null
 let  arr_aux2  =  null
 for  w_pf1  =  1  to  500
    initialize  a_cts06g09[w_pf1].*  to  null
 end  for
 for  w_pf1  =  1  to  500
    initialize  a_cts06g09n[w_pf1].*  to  null
 end  for
 initialize retorno.*  to  null
 initialize d_cts06g09.*  to  null
 initialize ws.*  to  null
 initialize a_cts06g09   to null #PSI 195138
 initialize a_cts06g09n  to null

 let retorno.c24lclpdrcod  =  01  ###  01 - Fora do padrao
 let retorno.lgdtip        =  param.lgdtippsq
 let retorno.lgdnom        =  param.lgdnompsq
 let retorno.brrnom        =  param.brrnompsq

 let d_cts06g09.lgdnompsq  =  param.lgdnompsq
 let d_cts06g09.tippsq = "F"
 let int_flag = false

 set isolation to dirty read

 if g_documento.atdsrvorg = 9 then

    call cts06g09_pesquisa(1, param.*)  #PSI 195138
         returning retorno.lgdtip, retorno.lgdnom, retorno.brrnom,
                   retorno.lgdcep, retorno.lgdcepcmp, retorno.lclltt,
                   retorno.lcllgt, retorno.c24lclpdrcod, retorno.qtd

     if retorno.qtd = 1 then #PSI 195138
        let retorno.c24lclpdrcod  =  03  ###  03 - Padrao mapas
        set isolation to committed read
        return retorno.lgdtip, retorno.lgdnom, retorno.brrnom,
               retorno.lgdcep, retorno.lgdcepcmp, retorno.lclltt,
               retorno.lcllgt, retorno.c24lclpdrcod
     end if

 end if

 open window w_cts06g09 at  05,03 with form "cts06g09"
             attribute(form line first, border)
 display  "                    Localiza logradouro - Mapas" to cabtxt

 display by name param.lgdtippsq
 display by name param.lgdnumpsq
 display by name param.brrnompsq

 while not int_flag

    initialize a_cts06g09   to null
    initialize a_cts06g09n  to null
    initialize ws.*         to null
    let int_flag  =  false
    let arr_aux   =  1
    let arr_aux2  =  1

    message " (F17)Abandona"

    input by name d_cts06g09.lgdnompsq,
                  d_cts06g09.tippsq     without defaults

       before field lgdnompsq
             display by name d_cts06g09.lgdnompsq  attribute(reverse)

       after field lgdnompsq
             display by name d_cts06g09.lgdnompsq

             if d_cts06g09.lgdnompsq  is null   then
                error " Logradouro deve ser informado!"
                next field lgdnompsq
             end if

       before field tippsq
             let d_cts06g09.tippsq  =  "F"
             display by name d_cts06g09.tippsq  attribute(reverse)

       after field tippsq
             display by name d_cts06g09.tippsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field lgdnompsq
             end if

             if ((d_cts06g09.tippsq  is null)    or
                 (d_cts06g09.tippsq  <>  "F"     and
                  d_cts06g09.tippsq  <>  "P"))   then
                error " Pesquisa deve ser: (F)onetica, (P)arcial!"
                next field tippsq
             end if

             if d_cts06g09.tippsq  =  "F"   then
                exit input
             end if

             let ws.cont  =  0
             let ws.cont  =  length(d_cts06g09.lgdnompsq)
             if ws.cont  <  5   then
                error " Logradouro nao deve conter menos que 5 caracteres!"
                next field lgdnompsq
             end if
             let ws.lgdnompsq = "*", d_cts06g09.lgdnompsq clipped, "*"

       on key (interrupt)
            if cts08g01("A","S","LOGRADOURO NAO LOCALIZADO NA ",
                        "BASE DE DADOS DE ENDERECOS","","ABANDONA ?") = "S" then
               let int_flag = true
               exit input
            else
               let int_flag = false
               next field lgdnompsq
            end if

    end input

    if int_flag   then
       exit while
    end if

    call cts06g09_pesquisa(2, param.*)
         returning retorno.lgdtip, retorno.lgdnom, retorno.brrnom,
                   retorno.lgdcep, retorno.lgdcepcmp, retorno.lclltt,
                   retorno.lcllgt, retorno.c24lclpdrcod, retorno.qtd

    if int_flag   then
       exit while
    end if

 end while

 close window  w_cts06g09

 set isolation to committed read
 
 return retorno.lgdtip, retorno.lgdnom, retorno.brrnom,
        retorno.lgdcep, retorno.lgdcepcmp, retorno.lclltt,
        retorno.lcllgt, retorno.c24lclpdrcod

end function

#--------------------------------------------------------------------------
function cts06g09_pesquisa(param)
#--------------------------------------------------------------------------
    define param           record
       flag                smallint, #PSI 195138
       lgdtippsq           like datkmpalgd.lgdtip,
       lgdnompsq           like datkmpalgd.lgdnom,
       lgdnumpsq           like datmlcl.lgdnum,
       brrnompsq           like datmlcl.brrnom,
       mpacidcod           like datkmpacid.mpacidcod
    end record

    define l_cont integer
    let l_cont = null

    if param.flag = 2 then
       message " Aguarde, pesquisando..."  attribute (reverse)
    end if

    let arr_aux   =  1
    let arr_aux2  =  1

    let ws.prep = " select datkmpalgd.lgdtip, ",
                    "       datkmpalgd.lgdnom, ",
                    "       datkmpabrr.brrnom, ",
                    "       datkmpalgdsgm.mpalgdincnum, ",
                    "       datkmpalgdsgm.mpalgdfnlnum, ",
                    "       datkmpalgdsgm.lclltt, ",
                    "       datkmpalgdsgm.lcllgt, ",
                    "       datkmpalgdsgm.cepcod  ",
                    "  from datkmpalgd, datkmpalgdsgm, outer datkmpabrr "

    #-----------------------------------------------------------
    # Pesquisa por parte do nome do logradouro
    #-----------------------------------------------------------
    if d_cts06g09.tippsq  =  "P"  then

       let ws.condicao = ' where datkmpalgd.lgdnom matches "', ws.lgdnompsq, '"',
                         ' and datkmpalgd.mpacidcod = ? ',
                         ' and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod ',
                         ' and datkmpabrr.mpacidcod = datkmpalgdsgm.mpacidcod ',
                         ' and datkmpabrr.mpabrrcod = datkmpalgdsgm.mpabrrcod ',
                         ' order by 1,2,3,4 '

       let ws.sql = ws.prep clipped, ws.condicao
       prepare s_datkmpalgd_1  from        ws.sql
       declare c_datkmpalgd_1  cursor for  s_datkmpalgd_1

       open    c_datkmpalgd_1 using  param.mpacidcod
       foreach c_datkmpalgd_1 into   a_cts06g09[arr_aux].lgdtip,
                                     a_cts06g09[arr_aux].lgdnom,
                                     a_cts06g09[arr_aux].brrnom,
                                     a_cts06g09[arr_aux].mpalgdincnum,
                                     a_cts06g09[arr_aux].mpalgdfnlnum,
                                     a_cts06g09[arr_aux].lclltt,
                                     a_cts06g09[arr_aux].lcllgt,
                                     m_cepcod

          let a_cts06g09[arr_aux].latlontxt = 'LAT/LON: ', a_cts06g09[arr_aux].lclltt, ',',  a_cts06g09[arr_aux].lcllgt

          let m_cepcod_char = m_cepcod using "&&&&&&&&"

          let a_cts06g09[arr_aux].lgdnomtxt = a_cts06g09[arr_aux].lgdtip
                                              clipped, " ",
                                              a_cts06g09[arr_aux].lgdnom

          let a_cts06g09[arr_aux].lgdcep    = m_cepcod_char[1,5]
          let a_cts06g09[arr_aux].lgdcepcmp = m_cepcod_char[6,8]

          if param.lgdnumpsq is not null   then
             if a_cts06g09[arr_aux].mpalgdincnum  <=  param.lgdnumpsq   and
                a_cts06g09[arr_aux].mpalgdfnlnum  >=  param.lgdnumpsq   then
                let a_cts06g09n[arr_aux2].* = a_cts06g09[arr_aux].*
                let arr_aux2  =  arr_aux2 + 1
             end if
          end if

          let arr_aux = arr_aux + 1

          if arr_aux > 500  then
             error " Limite excedido! Encontrados mais de 500 logradouros (1)!"
             exit foreach
          end if
       end foreach

       if arr_aux > 1  then
          goto exibe_array
       else
          error " Nao foi encontrado nenhum logradouro para pesquisa!"
          
          let arr_aux2 = 0
          
          return retorno.lgdtip, retorno.lgdnom, #PSI 195138
                 retorno.brrnom, retorno.lgdcep,
                 retorno.lgdcepcmp, retorno.lclltt,
                 retorno.lcllgt, retorno.c24lclpdrcod, arr_aux2
       end if
    end if

    #-----------------------------------------------------------
    # Gera codigos foneticos para pesquisa
    #-----------------------------------------------------------
    let ws.entfon = "3", d_cts06g09.lgdnompsq clipped

    call fonetica2(ws.entfon) returning ws.saifon

    if ws.saifon[1,3] = "100"  then
       error " Problema na geracao do codigo fonetico. AVISE A INFORMATICA!"
       let arr_aux2=0
       return retorno.lgdtip, retorno.lgdnom, #PSI 195138
              retorno.brrnom, retorno.lgdcep,
              retorno.lgdcepcmp, retorno.lclltt,
              retorno.lcllgt, retorno.c24lclpdrcod, arr_aux2
    end if

    let ws.prifoncod = ws.saifon[01,15]
    let ws.segfoncod = ws.saifon[17,31]
    let ws.terfoncod = ws.saifon[33,47]

    if ws.prifoncod is null  or
       ws.prifoncod  =  " "  then
       let ws.prifoncod  =  d_cts06g09.lgdnompsq[01,15]
    end if

    if ws.segfoncod is null  or
       ws.segfoncod  =  " "  then
       let ws.segfoncod = ws.prifoncod
    end if

    if ws.terfoncod is null  or
       ws.terfoncod  =  " "  then
       let ws.terfoncod = ws.prifoncod
    end if

    #-----------------------------------------------------------
    # Pesquisa pelo primeiro codigo fonetico
    #-----------------------------------------------------------
    let ws.condicao = " where datkmpalgd.prifoncod    = ? ",
                      "   and datkmpalgd.mpacidcod    = ? ",
                      "   and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod ",
                      "   and datkmpabrr.mpacidcod  = datkmpalgdsgm.mpacidcod",
                      "   and datkmpabrr.mpabrrcod  = datkmpalgdsgm.mpabrrcod",
                      " order by 1,2,3,4"

    let ws.sql = ws.prep clipped, ws.condicao

    prepare s_datkmpalgd_2  from        ws.sql
    declare c_datkmpalgd_2  cursor for  s_datkmpalgd_2

    open    c_datkmpalgd_2 using  ws.prifoncod,
                                  param.mpacidcod
    foreach c_datkmpalgd_2 into   a_cts06g09[arr_aux].lgdtip,
                                  a_cts06g09[arr_aux].lgdnom,
                                  a_cts06g09[arr_aux].brrnom,
                                  a_cts06g09[arr_aux].mpalgdincnum,
                                  a_cts06g09[arr_aux].mpalgdfnlnum,
                                  a_cts06g09[arr_aux].lclltt,
                                  a_cts06g09[arr_aux].lcllgt,
                                  m_cepcod

       let a_cts06g09[arr_aux].latlontxt = 'LAT/LON: ', a_cts06g09[arr_aux].lclltt, ',',  a_cts06g09[arr_aux].lcllgt
       
       let m_cepcod_char = m_cepcod using "&&&&&&&&"

       let a_cts06g09[arr_aux].lgdnomtxt = a_cts06g09[arr_aux].lgdtip
                                           clipped, " ",
                                           a_cts06g09[arr_aux].lgdnom


       let a_cts06g09[arr_aux].lgdcep    = m_cepcod_char[1,5]
       let a_cts06g09[arr_aux].lgdcepcmp = m_cepcod_char[6,8]

       if param.lgdnumpsq is not null   then
          if a_cts06g09[arr_aux].mpalgdincnum  <=  param.lgdnumpsq   and
             a_cts06g09[arr_aux].mpalgdfnlnum  >=  param.lgdnumpsq   then
             let a_cts06g09n[arr_aux2].* = a_cts06g09[arr_aux].*
             let arr_aux2  =  arr_aux2 + 1
          end if
       end if

       let arr_aux = arr_aux + 1

       if arr_aux > 500  then
          error " Limite excedido! Encontrados mais de 500 logradouros (2)!"
          exit foreach
       end if
    end foreach

    if arr_aux > 1  then
       goto exibe_array
    end if

    #-----------------------------------------------------------
    # Pesquisa pelo segundo codigo fonetico
    #-----------------------------------------------------------
    let ws.condicao = " where datkmpalgd.segfoncod    = ? ",
                      "   and datkmpalgd.mpacidcod    = ? ",
                      "   and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod ",
                      "   and datkmpabrr.mpacidcod  = datkmpalgdsgm.mpacidcod",
                      "   and datkmpabrr.mpabrrcod  = datkmpalgdsgm.mpabrrcod",
                      " order by 1,2,3,4"

    let ws.sql = ws.prep clipped, ws.condicao

    prepare s_datkmpalgd_3  from        ws.sql
    declare c_datkmpalgd_3  cursor for  s_datkmpalgd_3

    open    c_datkmpalgd_3 using  ws.segfoncod,
                                  param.mpacidcod
    foreach c_datkmpalgd_3 into   a_cts06g09[arr_aux].lgdtip,
                                  a_cts06g09[arr_aux].lgdnom,
                                  a_cts06g09[arr_aux].brrnom,
                                  a_cts06g09[arr_aux].mpalgdincnum,
                                  a_cts06g09[arr_aux].mpalgdfnlnum,
                                  a_cts06g09[arr_aux].lclltt,
                                  a_cts06g09[arr_aux].lcllgt,
                                  m_cepcod

       let a_cts06g09[arr_aux].latlontxt = 'LAT/LON: ', a_cts06g09[arr_aux].lclltt, ',',  a_cts06g09[arr_aux].lcllgt
       
       let m_cepcod_char = m_cepcod using "&&&&&&&&"

       let a_cts06g09[arr_aux].lgdnomtxt = a_cts06g09[arr_aux].lgdtip
                                           clipped, " ",
                                           a_cts06g09[arr_aux].lgdnom


       let a_cts06g09[arr_aux].lgdcep    = m_cepcod_char[1,5]
       let a_cts06g09[arr_aux].lgdcepcmp = m_cepcod_char[6,8]

       if param.lgdnumpsq is not null   then
          if a_cts06g09[arr_aux].mpalgdincnum  <=  param.lgdnumpsq   and
             a_cts06g09[arr_aux].mpalgdfnlnum  >=  param.lgdnumpsq   then
             let a_cts06g09n[arr_aux2].* = a_cts06g09[arr_aux].*
             let arr_aux2  =  arr_aux2 + 1
          end if
       end if

       let arr_aux = arr_aux + 1

       if arr_aux > 500  then
          error " Limite excedido! Encontrados mais de 500 logradouros!"
          exit foreach
       end if
    end foreach

    if arr_aux > 1  then
       goto exibe_array
    end if

    #-----------------------------------------------------------
    # Pesquisa pelo terceiro codigo fonetico
    #-----------------------------------------------------------
    let ws.condicao = " where datkmpalgd.terfoncod    = ? ",
                      "   and datkmpalgd.mpacidcod    = ? ",
                      "   and datkmpalgdsgm.mpalgdcod = datkmpalgd.mpalgdcod ",
                      "   and datkmpabrr.mpacidcod  = datkmpalgdsgm.mpacidcod",
                      "   and datkmpabrr.mpabrrcod  = datkmpalgdsgm.mpabrrcod",
                      " order by 1,2,3,4"

    let ws.sql = ws.prep clipped, ws.condicao

    prepare s_datkmpalgd_4  from        ws.sql
    declare c_datkmpalgd_4  cursor for  s_datkmpalgd_4

    open    c_datkmpalgd_4 using  ws.terfoncod,
                                  param.mpacidcod
    foreach c_datkmpalgd_4 into   a_cts06g09[arr_aux].lgdtip,
                                  a_cts06g09[arr_aux].lgdnom,
                                  a_cts06g09[arr_aux].brrnom,
                                  a_cts06g09[arr_aux].mpalgdincnum,
                                  a_cts06g09[arr_aux].mpalgdfnlnum,
                                  a_cts06g09[arr_aux].lclltt,
                                  a_cts06g09[arr_aux].lcllgt,
                                  m_cepcod

       let a_cts06g09[arr_aux].latlontxt = 'LAT/LON: ', a_cts06g09[arr_aux].lclltt, ',',  a_cts06g09[arr_aux].lcllgt
       
       let m_cepcod_char = m_cepcod using "&&&&&&&&"

       let a_cts06g09[arr_aux].lgdnomtxt = a_cts06g09[arr_aux].lgdtip
                                           clipped, " ",
                                           a_cts06g09[arr_aux].lgdnom

       let a_cts06g09[arr_aux].lgdcep    = m_cepcod_char[1,5]
       let a_cts06g09[arr_aux].lgdcepcmp = m_cepcod_char[6,8]

       if param.lgdnumpsq is not null   then
          if a_cts06g09[arr_aux].mpalgdincnum  <=  param.lgdnumpsq   and
             a_cts06g09[arr_aux].mpalgdfnlnum  >=  param.lgdnumpsq   then
             let a_cts06g09n[arr_aux2].* = a_cts06g09[arr_aux].*
             let arr_aux2  =  arr_aux2 + 1
          end if
       end if

       let arr_aux = arr_aux + 1

       if arr_aux > 500  then
          error " Limite excedido! Encontrados mais de 500 logradouros (3)!"
          exit foreach
       end if
    end foreach

    if arr_aux > 1  then
       goto exibe_array
    else
       error " Nao foi encontrado nenhum logradouro para pesquisa!"
       let arr_aux2=0
       return retorno.lgdtip, retorno.lgdnom, #PSI 195138
              retorno.brrnom, retorno.lgdcep,
              retorno.lgdcepcmp, retorno.lclltt,
              retorno.lcllgt, retorno.c24lclpdrcod, arr_aux2
    end if

    #-----------------------------------------------------------
    # Exibe logradouros encontrados na pesquisa
    #-----------------------------------------------------------
    label exibe_array:


       #-------------------------------------------------------------
       # Se encontrar numeracao informada, troca conteudo dos arrays
       #-------------------------------------------------------------
       let l_cont = 0
       if arr_aux2  >  1   then
          initialize a_cts06g09  to null

          for arr_aux = 1 to arr_aux2 - 1
             let a_cts06g09[arr_aux].*  =  a_cts06g09n[arr_aux].*
             let l_cont = l_cont + 1
          end for
       end if

       if param.flag = 1 then
          let retorno.c24lclpdrcod  =  03  ###  03 - Padrao mapas
          let retorno.lgdtip        =  a_cts06g09[1].lgdtip
          let retorno.lgdnom        =  a_cts06g09[1].lgdnom
          let retorno.brrnom        =  a_cts06g09[1].brrnom
          let retorno.lgdcep        =  a_cts06g09[1].lgdcep
          let retorno.lgdcepcmp     =  a_cts06g09[1].lgdcepcmp using "&&&"
          let retorno.lclltt        =  a_cts06g09[1].lclltt
          let retorno.lcllgt        =  a_cts06g09[1].lcllgt

          return retorno.lgdtip, retorno.lgdnom, #PSI 195138
                 retorno.brrnom, retorno.lgdcep,
                 retorno.lgdcepcmp, retorno.lclltt,
                 retorno.lcllgt, retorno.c24lclpdrcod, l_cont
       end if


       message " (F17)Abandona, (F8)Seleciona"

       call set_count(arr_aux-1)

       display array a_cts06g09 to s_cts06g09.*
       
          on key (interrupt,control-c)
             let int_flag = false
             initialize a_cts06g09    to null
             initialize a_cts06g09n   to null
             let retorno.c24lclpdrcod  =  01  ###  01 - Fora do padrao
             let retorno.lgdtip        =  param.lgdtippsq
             let retorno.lgdnom        =  param.lgdnompsq
             let retorno.brrnom        =  param.brrnompsq
             let retorno.lgdcep        =  null
             let retorno.lgdcepcmp     =  null
             let retorno.lclltt        =  null
             let retorno.lcllgt        =  null
             exit display

          on key (F8)
             let int_flag = true
             let arr_aux  = arr_curr()
            #let l_cep = a_cts06g09[arr_aux].lgdcep
            #let l_cep = l_cep using "&&&&&"

             let retorno.c24lclpdrcod  =  03  ###  03 - Padrao mapas
             let retorno.lgdtip        =  a_cts06g09[arr_aux].lgdtip
             let retorno.lgdnom        =  a_cts06g09[arr_aux].lgdnom
             let retorno.brrnom        =  a_cts06g09[arr_aux].brrnom
             let retorno.lgdcep        =  a_cts06g09[arr_aux].lgdcep
             let retorno.lgdcepcmp     =  a_cts06g09[arr_aux].lgdcepcmp
                                          using "&&&"
             let retorno.lclltt        =  a_cts06g09[arr_aux].lclltt
             let retorno.lcllgt        =  a_cts06g09[arr_aux].lcllgt

             exit display
       end display

 # set isolation to committed read

 return retorno.lgdtip,
        retorno.lgdnom,
        retorno.brrnom,
        retorno.lgdcep,
        retorno.lgdcepcmp,
        retorno.lclltt,
        retorno.lcllgt,
        retorno.c24lclpdrcod, arr_aux

 end function   ###  cts06g09
