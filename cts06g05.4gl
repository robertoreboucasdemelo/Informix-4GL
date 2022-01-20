#############################################################################
# Nome do Modulo: CTS06G05                                         Marcelo  #
#                                                                  Gilberto #
# Pesquisa padrao de logradouros Guia Postal                       Mar/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/02/2001  AS-2339-6     Marcus      Nova estrutura do Guia Postal       #
#---------------------------------------------------------------------------#
# 21/03/2001  PSI 12751-5   Raji        Tipo de Pesquisa (Parcial/Fonetica) #
#############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts06g05(param)
#-----------------------------------------------------------

 define param      record
    diglgdtip      like glaklgd.lgdtip,
    diglgdnom      like glaklgd.lgdnom,
    diglgdnum      like datmlcl.lgdnum,
    digbrrnom      like glakbrr.brrnom,
    digcidcod      like glakcid.cidcod,
    digufdcod      like glakest.ufdcod
 end record

 define d_cts06g05 record
    diglgdnom      like glaklgd.lgdnom,
    lgdtip         like glaklgd.lgdtip,
    lgdnom         like glaklgd.lgdnom,
    brrnom         like glakbrr.brrnom,
    lgdcep         like glaklgd.lgdcep,
    lgdcepcmp      like glaklgd.lgdcepcmp,
    c24lclpdrcod   like datmlcl.c24lclpdrcod,
    tippsq         char (01)
 end record

 define a_cts06g05 array[1000] of record
    lgdtxt         char (72),
    brrnom         like glakbrr.brrnom,
    lgdcep         like glaklgd.lgdcep,
    lgdcepcmp      like glaklgd.lgdcepcmp,
    lgdtip         like glaklgd.lgdtip,
    lgdnom         like glaklgd.lgdnom,
    lgdnomcmp      like glaklgd.lgdnomcmp
 end record

 define ws         record
    diglgdnom      like glaklgd.lgdnom,
    sql            char (900),
    selection      char (600),
    condition      char (300),
    entfon         char (051),
    saifon         char (100),
    prifoncod      like glaklgd.prifoncod,
    segfoncod      like glaklgd.segfoncod,
    terfoncod      like glaklgd.terfoncod,
    cidcod         like glakcid.cidcod,
    brrcod         like glaklgd.brrcod,
    lgdtmp         char (100)
 end record

 define arr_aux    smallint



	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  1000
		initialize  a_cts06g05[w_pf1].*  to  null
	end	for

	initialize  d_cts06g05.*  to  null

	initialize  ws.*  to  null

 initialize d_cts06g05.*  to null
 initialize ws.*          to null

 let d_cts06g05.diglgdnom     =  param.diglgdnom
 let d_cts06g05.lgdtip        =  param.diglgdtip
 let d_cts06g05.lgdnom        =  param.diglgdnom
 let d_cts06g05.brrnom        =  param.digbrrnom

 let d_cts06g05.c24lclpdrcod  =  01    ### 01 - Fora do padrao


 open window cts06g05 at 05,03 with form "cts06g05"
      attribute(border, form line 1, message line last, comment line last - 1)

 display  "                 Localiza logradouro - Guia Postal" to cabtxt


 while not int_flag

    let int_flag = false
    message " (F17)Abandona"

    display by name param.diglgdtip,
                    param.diglgdnom,
                    param.diglgdnum,
                    param.digbrrnom,
                    param.digcidcod
    # Padrao Fonetica
    let d_cts06g05.tippsq = "F"

    input by name d_cts06g05.diglgdnom,
                  d_cts06g05.tippsq  without defaults

      before field diglgdnom
             display by name d_cts06g05.diglgdnom attribute (reverse)

      after  field diglgdnom
             display by name d_cts06g05.diglgdnom

             if fgl_lastkey() <> fgl_keyval("up")    and
                fgl_lastkey() <> fgl_keyval("left")  then
                 if d_cts06g05.diglgdnom is null  then
                    error " Logradouro deve ser informado!"
                    next field diglgdnom
                 end if
                 let param.diglgdnom  =  d_cts06g05.diglgdnom
             end if

       after field tippsq
             display by name d_cts06g05.tippsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field diglgdnom
             end if

             if ((d_cts06g05.tippsq  is null)    or
                 (d_cts06g05.tippsq  <>  "F"     and
                  d_cts06g05.tippsq  <>  "P"))   then
                error " Pesquisa deve ser: (F)onetica, (P)arcial!"
                next field tippsq
             end if

             if d_cts06g05.tippsq  =  "F"   then
                exit input
             end if

             if length(d_cts06g05.diglgdnom)  <  5   then
                error " Logradouro nao deve conter menos que 5 caracteres!"
                next field diglgdnom
             end if
             let ws.diglgdnom = d_cts06g05.diglgdnom clipped, "*"

      on key (interrupt)
         if cts08g01("A","S","LOGRADOURO NAO LOCALIZADO NA ",
                     "BASE DE DADOS DE ENDERECOS","","ABANDONA ?") = "S"  then
            let int_flag = true
            exit input
         else
            let int_flag = false
            next field diglgdnom
         end if

    end input

    if int_flag  then
       exit while
    end if

    message " Aguarde, pesquisando..."  attribute (reverse)

    let arr_aux = 1

    if d_cts06g05.tippsq = 'F' then
       let ws.selection = "select glaklgd.lgdtip   ,",
                          "       glaklgd.lgdnom   ,",
                          "       glaklgd.lgdnomcmp,",
                          "       glakbrr.brrnom   ,",
                          "       glaklgd.cidcod   ,",
                          "       glaklgd.lgdcep   ,",
                          "       glaklgd.lgdcepcmp ",
                          "  from glaklgd, glakbrr  "

       let ws.entfon = "3", d_cts06g05.diglgdnom clipped

       call fonetica2(ws.entfon) returning ws.saifon

       if ws.saifon[1,3] = "100"  then
          error " Problema na pesquisa fonetica. AVISE A INFORMATICA!"
          sleep 2
          close window cts06g05
          return param.diglgdtip,
                 param.diglgdnom,
                 param.digbrrnom,
                 "", "",
                 d_cts06g05.c24lclpdrcod
       end if

       let ws.prifoncod = ws.saifon[01,15]
       let ws.segfoncod = ws.saifon[17,31]
       let ws.terfoncod = ws.saifon[33,47]

       if ws.prifoncod is null  or
          ws.prifoncod  =  " "  then
          error " Nao foi possivel realizar pesquisa fonetica. AVISE A INFORMATICA!"
          sleep 2
          close window cts06g05
          return param.diglgdtip,
                 param.diglgdnom,
                 param.digbrrnom,
                 "", "",
                 d_cts06g05.c24lclpdrcod
       end if

       if ws.segfoncod is null  or
          ws.segfoncod  =  " "  then
          let ws.segfoncod = ws.prifoncod
       end if

       if ws.terfoncod is null  or
          ws.terfoncod  =  " "  then
          let ws.terfoncod = ws.prifoncod
       end if

       let ws.condition = " where glaklgd.prifoncod = ? ",
                          "   and glakbrr.cidcod    = glaklgd.cidcod ",
                          "   and glakbrr.brrcod    = glaklgd.brrcod "

       let ws.sql = ws.selection clipped, ws.condition

       prepare p_cts06g05_001 from ws.sql
       declare c_cts06g05_001 cursor for p_cts06g05_001

       open    c_cts06g05_001 using ws.prifoncod
       foreach c_cts06g05_001 into  a_cts06g05[arr_aux].lgdtip,
                                a_cts06g05[arr_aux].lgdnom,
                                a_cts06g05[arr_aux].lgdnomcmp,
                                a_cts06g05[arr_aux].brrnom,
                                ws.cidcod,
                                a_cts06g05[arr_aux].lgdcep,
                                a_cts06g05[arr_aux].lgdcepcmp

          if ws.cidcod <> param.digcidcod  then
             continue foreach
          end if

          let a_cts06g05[arr_aux].lgdtxt = a_cts06g05[arr_aux].lgdtip clipped,
                                      " ", a_cts06g05[arr_aux].lgdnom clipped,
                                      " ", a_cts06g05[arr_aux].lgdnomcmp

          let arr_aux = arr_aux + 1

          if arr_aux > 1000  then
             error " Limite excedido! Foram encontrados mais de 1000 logradouros para a pesquisa!"
             exit foreach
          end if
       end foreach

       if arr_aux > 1  then
          goto disp_array
       end if

       let ws.condition = " where glaklgd.segfoncod = ? ",
                          "   and glakbrr.cidcod    = glaklgd.cidcod ",
                          "   and glakbrr.brrcod    = glaklgd.brrcod "

       let ws.sql = ws.selection clipped, ws.condition

       prepare p_cts06g05_002 from ws.sql
       declare c_cts06g05_002 cursor for p_cts06g05_002

       open    c_cts06g05_002 using ws.segfoncod
       foreach c_cts06g05_002 into  a_cts06g05[arr_aux].lgdtip,
                                a_cts06g05[arr_aux].lgdnom,
                                a_cts06g05[arr_aux].lgdnomcmp,
                                a_cts06g05[arr_aux].brrnom,
                                ws.cidcod,
                                a_cts06g05[arr_aux].lgdcep,
                                a_cts06g05[arr_aux].lgdcepcmp

          if ws.cidcod <> param.digcidcod  then
             continue foreach
          end if

          let a_cts06g05[arr_aux].lgdtxt = a_cts06g05[arr_aux].lgdtip clipped,
                                      " ", a_cts06g05[arr_aux].lgdnom clipped,
                                      " ", a_cts06g05[arr_aux].lgdnomcmp

          let arr_aux = arr_aux + 1

          if arr_aux > 1000  then
             error " Limite excedido! Foram encontrados mais de 1000 logradouros para a pesquisa!"
             exit foreach
          end if
       end foreach

       if arr_aux > 1  then
          goto disp_array
       end if

       let ws.condition = " where glaklgd.terfoncod = ? ",
                          "   and glakbrr.cidcod    = glaklgd.cidcod ",
                          "   and glakbrr.brrcod    = glaklgd.brrcod "

       let ws.sql = ws.selection clipped, ws.condition

       prepare p_cts06g05_003 from ws.sql
       declare c_cts06g05_003 cursor for p_cts06g05_003

       open    c_cts06g05_003 using ws.terfoncod
       foreach c_cts06g05_003 into  a_cts06g05[arr_aux].lgdtip,
                                a_cts06g05[arr_aux].lgdnom,
                                a_cts06g05[arr_aux].lgdnomcmp,
                                a_cts06g05[arr_aux].brrnom,
                                ws.cidcod,
                                a_cts06g05[arr_aux].lgdcep,
                                a_cts06g05[arr_aux].lgdcepcmp

          if ws.cidcod <> param.digcidcod  then
             continue foreach
          end if

          let a_cts06g05[arr_aux].lgdtxt = a_cts06g05[arr_aux].lgdtip clipped,
                                      " ", a_cts06g05[arr_aux].lgdnom clipped,
                                      " ", a_cts06g05[arr_aux].lgdnomcmp

          let arr_aux = arr_aux + 1

          if arr_aux > 1000  then
             error " Limite excedido! Foram encontrados mais de 1000 logradouros para a pesquisa!"
             exit foreach
          end if
       end foreach

       if arr_aux > 1  then
          goto disp_array
       else
          error " Nao foi encontrado nenhum logradouro para pesquisa!"
          continue while
       end if

    else   ### PARCIAL ###
       let ws.selection = "select glaklgd.lgdtip   ,",
                          "       glaklgd.lgdnom   ,",
                          "       glaklgd.lgdnomcmp,",
                          "       glaklgd.cidcod   ,",
                          "       glaklgd.lgdcep   ,",
                          "       glaklgd.lgdcepcmp,",
                          "       glaklgd.brrcod    ",
                          "  from glaklgd "
       let ws.condition = " where glaklgd.lgdnom matches '",ws.diglgdnom,"'",
                          "   and glaklgd.cidcod    = ",param.digcidcod

       let ws.sql = ws.selection clipped, ws.condition

       prepare p_cts06g05_004 from ws.sql
       declare c_cts06g05_004 cursor for p_cts06g05_004

     ##open    c_cts06g05_004 using ws.diglgdnom
       foreach c_cts06g05_004 into  a_cts06g05[arr_aux].lgdtip,
                               a_cts06g05[arr_aux].lgdnom,
                               a_cts06g05[arr_aux].lgdnomcmp,
                               ws.cidcod,
                               a_cts06g05[arr_aux].lgdcep,
                               a_cts06g05[arr_aux].lgdcepcmp,
                               ws.brrcod

          if ws.cidcod <> param.digcidcod  then
             continue foreach
          end if

          select brrnom
                 into a_cts06g05[arr_aux].brrnom
            from glakbrr
           where brrcod  = ws.brrcod
             and cidcod  = ws.cidcod

          let a_cts06g05[arr_aux].lgdtxt = a_cts06g05[arr_aux].lgdtip clipped,
                                      " ", a_cts06g05[arr_aux].lgdnom clipped,
                                      " ", a_cts06g05[arr_aux].lgdnomcmp

          let arr_aux = arr_aux + 1

          if arr_aux > 1000  then
             error " Limite excedido! Foram encontrados mais de 1000 logradouros para a pesquisa!"
             exit foreach
          end if
       end foreach

    end if

    #-----------------------------------------------------------
    # Exibe logradouros encontrados na pesquisa
    #-----------------------------------------------------------
    label disp_array:

       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cts06g05 to s_cts06g05.*
          on key (interrupt,control-c)
             let int_flag = false
             initialize d_cts06g05.* to null

             let d_cts06g05.c24lclpdrcod = 01  ###  01 - Fora do padrao
             let d_cts06g05.diglgdnom    = param.diglgdnom
             let d_cts06g05.lgdtip       = param.diglgdtip
             let d_cts06g05.lgdnom       = param.diglgdnom
             let d_cts06g05.brrnom       = param.digbrrnom
             let d_cts06g05.lgdcep       = ""
             let d_cts06g05.lgdcepcmp    = ""
             exit display

          on key (F8)
             let int_flag = true
             let arr_aux = arr_curr()

             let d_cts06g05.c24lclpdrcod = 02  ###  02 - Padrao Guia Postal
             let d_cts06g05.lgdtip       = a_cts06g05[arr_aux].lgdtip
#            let d_cts06g05.lgdnom       = a_cts06g05[arr_aux].lgdnom clipped, " ", a_cts06g05[arr_aux].lgdnomcmp clipped
             let d_cts06g05.lgdnom       = a_cts06g05[arr_aux].lgdnom
             let d_cts06g05.brrnom       = a_cts06g05[arr_aux].brrnom
             let d_cts06g05.lgdcep       = a_cts06g05[arr_aux].lgdcep
             let d_cts06g05.lgdcepcmp    = a_cts06g05[arr_aux].lgdcepcmp
             exit display
       end display
 end while

 close window cts06g05

 let int_flag = false

 return d_cts06g05.lgdtip,
        d_cts06g05.lgdnom,
        d_cts06g05.brrnom,
        d_cts06g05.lgdcep,
        d_cts06g05.lgdcepcmp,
        d_cts06g05.c24lclpdrcod

end function  ###  cts06g05
