#############################################################################
# Nome do Modulo: CTS11M01                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao no cadastro de passageiros                            Nov/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Gravar campo SRVPRLFLG = "N" na ta- #
#                                       bela DATMSERVICO.                   #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 29/03/1999  PSI 5591-3   Gilberto     Transformar a tela em entrada de    #
#                                       dados, retirando as atualizacoes na #
#                                       base de dados.                      #
#---------------------------------------------------------------------------#
# 10/06/1999  PSI 7547-7   Gilberto     Retirar situacao do passageiro.     #
#############################################################################

database porto


#---------------------------------------------------------------
 function cts11m11(passag01,passag02,passag03,passag04,passag05)
#---------------------------------------------------------------

 define passag01     record
    pasnom           like datmpassageiro.pasnom,
    pasidd           like datmpassageiro.pasidd
 end record

 define passag02     record
    pasnom           like datmpassageiro.pasnom,
    pasidd           like datmpassageiro.pasidd
 end record

 define passag03     record
    pasnom           like datmpassageiro.pasnom,
    pasidd           like datmpassageiro.pasidd
 end record

 define passag04     record
    pasnom           like datmpassageiro.pasnom,
    pasidd           like datmpassageiro.pasidd
 end record

 define passag05     record
    pasnom           like datmpassageiro.pasnom,
    pasidd           like datmpassageiro.pasidd
 end record

 define a_cts11m11   array[16] of record
    pasnom           like datmpassageiro.pasnom,
    pasidd           like datmpassageiro.pasidd
 end record

 define ws           record
    arrqtd           smallint,
    privez           char (01),
    operacao         char (01),
    confirma         char (01)
 end record

 define arr_aux      smallint
 define scr_aux      smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  16
		initialize  a_cts11m11[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let a_cts11m11[01].pasnom = passag01.pasnom
 let a_cts11m11[01].pasidd = passag01.pasidd

 let a_cts11m11[02].pasnom = passag02.pasnom
 let a_cts11m11[02].pasidd = passag02.pasidd

 let a_cts11m11[03].pasnom = passag03.pasnom
 let a_cts11m11[03].pasidd = passag03.pasidd

 let a_cts11m11[04].pasnom = passag04.pasnom
 let a_cts11m11[04].pasidd = passag04.pasidd

 let a_cts11m11[05].pasnom = passag05.pasnom
 let a_cts11m11[05].pasidd = passag05.pasidd

 let ws.privez = "S"

 open window w_cts11m11 at 09,17 with form "cts11m11"
                        attribute(form line first, border, comment line last-1)

 options insert key F40

 message " (F17)Abandona "

 while true
#---------------------------------------------------------------
# Inicializacao do indexador do array
#---------------------------------------------------------------
 for arr_aux = 1 to 5
    if ws.privez = "N"  then
       if arr_aux > ws.arrqtd  then
          initialize a_cts11m11[arr_aux].*  to null
       end if
    end if

    if a_cts11m11[arr_aux].pasnom is null  and
       a_cts11m11[arr_aux].pasidd is null  then
       exit for
    end if
 end for

 let ws.privez = "N"

 call set_count(arr_aux-1)

 let int_flag = false

 input array a_cts11m11 without defaults from s_cts11m01.*
    before row
       let arr_aux = arr_curr()
       let scr_aux = scr_line()
       if arr_aux <= arr_count()  then
          let ws.operacao = "a"
       end if

       if arr_aux > 5  then
          call cts08g01("A","N","","LIMITE DE 5 PASSAGEIROS","OU HOSPEDES ATINGIDO!","") returning ws.confirma
          let int_flag = true
          exit input
       end if

    before insert
       let ws.operacao = "i"
       initialize a_cts11m11[arr_aux].* to null
       display    a_cts11m11[arr_aux].* to s_cts11m01[scr_aux].*

    after  delete
       error " Passageiro excluido! "
       let ws.arrqtd = arr_count()
       exit input

    before field pasnom
       if ws.operacao = "a"  then
          if a_cts11m11[arr_aux].pasnom is null  then
             let ws.operacao = "i"
             display a_cts11m11[arr_aux].pasnom to
                     s_cts11m01[scr_aux].pasnom attribute (reverse)
          else
             display a_cts11m11[arr_aux].pasnom to
                     s_cts11m01[scr_aux].pasnom attribute (reverse)
          end if
       else
          display a_cts11m11[arr_aux].pasnom  to
                  s_cts11m01[scr_aux].pasnom  attribute (reverse)
       end if

     after  field pasnom
        display a_cts11m11[arr_aux].pasnom to
                s_cts11m01[scr_aux].pasnom

        if fgl_lastkey() = fgl_keyval("up")   and
           a_cts11m11[arr_aux].pasnom is null then
           initialize a_cts11m11[arr_aux].* to null
           initialize ws.operacao to null
           display a_cts11m11[arr_aux].* to s_cts11m01[scr_aux].*
        else
           if a_cts11m11[arr_aux].pasnom is null  then
              error " Nome do passageiro deve ser informado!"
              next field pasnom
           end if
        end if

        if fgl_lastkey() = fgl_keyval("down")   then
           if a_cts11m11[arr_aux + 1].pasnom  is null   then
              error " Nao existem linhas nesta direcao!"
              next field pasnom
           end if

           if a_cts11m11[arr_aux].pasnom is null  then
              error " Nome do passageiro deve ser informado!"
              next field pasnom
           end if

           if a_cts11m11[arr_aux].pasidd is null  then
              error " Idade do passageiro deve ser informada!"
              next field pasidd
           end if
        end if

     before field pasidd
        display a_cts11m11[arr_aux].pasidd to
                s_cts11m01[scr_aux].pasidd attribute (reverse)

     after  field pasidd
        display a_cts11m11[arr_aux].pasidd to
                s_cts11m01[scr_aux].pasidd

        if fgl_lastkey() = fgl_keyval("down")   then
           if a_cts11m11[arr_aux + 1].pasnom  is null   then
              error " Nao existem linhas nesta direcao!"
              next field pasnom
           end if

           if a_cts11m11[arr_aux].pasnom is null  then
              error " Nome do passageiro deve ser informado!"
              next field pasnom
           end if

           if a_cts11m11[arr_aux].pasidd is null  then
              error " Idade do passageiro deve ser informada!"
              next field pasidd
           end if

           if a_cts11m11[arr_aux].pasidd > 130  then
              error " Idade incorreta! "
              next field pasidd
           end if
        end if

        if fgl_lastkey() = fgl_keyval("up")   and
           a_cts11m11[arr_aux].pasidd is null then
           initialize a_cts11m11[arr_aux].* to null
           initialize ws.operacao to null
           display a_cts11m11[arr_aux].* to s_cts11m01[scr_aux].*
        else
           if a_cts11m11[arr_aux].pasidd is null  then
              error " Idade do passageiro deve ser informada!"
              next field pasidd
           end if
        end if

     on key (interrupt)
        exit input

 end input

 if int_flag  then
    let int_flag = false
    exit while
 end if

 end while

 options insert key F1

 close window w_cts11m11

 let int_flag = false

 return a_cts11m11[01].pasnom, a_cts11m11[01].pasidd,
        a_cts11m11[02].pasnom, a_cts11m11[02].pasidd,
        a_cts11m11[03].pasnom, a_cts11m11[03].pasidd,
        a_cts11m11[04].pasnom, a_cts11m11[04].pasidd,
        a_cts11m11[05].pasnom, a_cts11m11[05].pasidd

end function  ###  cts11m01
