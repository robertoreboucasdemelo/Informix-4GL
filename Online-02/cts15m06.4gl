###############################################################################
# Nome do Modulo: CTS15M06                                           Marcelo  #
#                                                                    Gilberto #
# Mostra as condicoes para locacao sem documento                     Out/1996 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 11/11/1998  PSI 6471-8   Gilberto     Permitir atendimento para clausula    #
#                                       26D (Carro Extra Deficiente Fisico)   #
#-----------------------------------------------------------------------------#
# 11/11/1998  PSI 7055-6   Gilberto     Permitir atendimento para clausula    #
#                                       80 (Carro Extra Taxi).                #
#-----------------------------------------------------------------------------#
# 16/12/2006  psi 205206   Ruiz         Apresentar clauslas Azul              #
#-----------------------------------------------------------------------------#
# 30/10/2009 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Livre Escolha: 58E-05dias / 58F-10dias#
#                                                      58G-15dias / 58H-30dias#
#-----------------------------------------------------------------------------#
# 15/07/2010 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Referenciada : 58I -  7 dias          #
#                                                      58J - 15 dias          #
#                                                      58K - 30 dias          #
#                                                                             #
#                                       Livre Escolha: 58L -  7 dias          #
#                                                      58M - 15 dias          #
#                                                      58N - 30 dias          #
#-----------------------------------------------------------------------------#


database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts15m06()
#-----------------------------------------------------------

 define a_cts15m06 array[17] of record
    clsdes  char (12),
    clscod  char (03)
 end record

 define scr_aux    smallint
 define arr_aux    smallint


 define w_pf1 integer

 let scr_aux = null
 let arr_aux = null

 for w_pf1 = 1 to 17
     initialize  a_cts15m06[w_pf1].*  to  null
 end for

 open window cts15m06 at 16,54 with form "cts15m06"
                      attribute(form line 1, border)

 let int_flag = false
 initialize  a_cts15m06    to null

 if g_documento.ciaempcod <> 35 then
    let a_cts15m06[01].clscod = "26A"
    let a_cts15m06[02].clscod = "26B"
    let a_cts15m06[03].clscod = "26C"
    let a_cts15m06[04].clscod = "26D"

    let a_cts15m06[05].clscod = "26E" ## psi201154
    let a_cts15m06[06].clscod = "26F" ## psi201154
    let a_cts15m06[07].clscod = "26G" ## psi201154
    let a_cts15m06[08].clscod = "26H"
    let a_cts15m06[09].clscod = "26I"
    let a_cts15m06[10].clscod = "26J"
    let a_cts15m06[11].clscod = "26K"
    let a_cts15m06[12].clscod = "26L"
    let a_cts15m06[13].clscod = "26M"
    let a_cts15m06[14].clscod = "80A"
    let a_cts15m06[15].clscod = "80B"
    let a_cts15m06[16].clscod = "80C"
    let a_cts15m06[17].clscod = "GRT"

    for arr_aux = 01 to 17
       let a_cts15m06[arr_aux].clsdes = "CLAUSULA ", a_cts15m06[arr_aux].clscod
    end for

    let a_cts15m06[17].clsdes = "1a. GRATUITA"

    let arr_aux = 17  ## 08
 end if

 if g_documento.ciaempcod = 35 then
    let a_cts15m06[01].clscod = "58A"
    let a_cts15m06[02].clscod = "58B"
    let a_cts15m06[03].clscod = "58C"
    let a_cts15m06[04].clscod = "58D"
    let a_cts15m06[05].clscod = "58E"
    let a_cts15m06[06].clscod = "58F"
    let a_cts15m06[07].clscod = "58G"
    let a_cts15m06[08].clscod = "58H"
    let a_cts15m06[09].clscod = "58I"
    let a_cts15m06[10].clscod = "58J"
    let a_cts15m06[11].clscod = "58K"
    let a_cts15m06[12].clscod = "58L"
    let a_cts15m06[13].clscod = "58M"
    let a_cts15m06[14].clscod = "58N"

    for arr_aux = 01 to 14
       let a_cts15m06[arr_aux].clsdes = "CLAUSULA ", a_cts15m06[arr_aux].clscod
    end for

    let arr_aux = 14

 end if
 message "(F8)Seleciona"
 call set_count(arr_aux)

 display array a_cts15m06 to s_cts15m06.*

    on key (interrupt,control-c)
       initialize a_cts15m06   to null
       let a_cts15m06[arr_aux].clscod = "GRT"
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       let scr_aux = scr_line()
       exit display

 end display

 close window  cts15m06
 let int_flag = false

 return a_cts15m06[arr_aux].clscod

end function  ###  cts15m06
