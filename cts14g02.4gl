###############################################################################
# Nome do Modulo: cts14g02                                           Marcus   #
#                                                                             #
# Funcao dos procedimentos mostrados na abertura de tela             Abr/2002 #
#                                                                             #
###############################################################################
#-----------------------------------------------------------------------------#
#                                                                             #
#                      * * * * * Altecacoes * * * * *                         #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- -------------------------------------  #
# 09/09/2003  Meta,Bruno     PSI175269 Mostrar na tela os dados referente     #
#                            OSF25780  ao departamento do atendente.          #
#-----------------------------------------------------------------------------#
# 26/07/2006 Andrei, Meta              Migracao de versao do 4gl              #
#-----------------------------------------------------------------------------#
# 17/10/2008 Amilton, Meta             Alterado o array de tela devido a      #
#                                      estouro                                #
#-----------------------------------------------------------------------------#

###############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"


 define w_arr        integer

#-----------------------------------------------------------------------
 function cts14g02(param)
#-----------------------------------------------------------------------
 define param     record
   smlflg         char(01),
   telnom         like datktel.telnom
 end record

 define a_datktelprc array[50] of record
   telprccod         like datktelprc.telprccod
 end record

 define a_datkprctxt array[100] of record
   telprcseq      like datkprctxt.telprcseq,
   telprctxt      like datkprctxt.telprctxt,
   telprccod      like datkprctxt.telprccod
 end record

 define ws        record
   comando        char(650),
   alfa           char(20),
   entrada        char(10),
   saida          char(16),
   cabtxt         char(70),
   primeiro       char(01),
   hoje           datetime year to minute,
   telprccod       like datktelprc.telprccod,
   funnom         like isskfunc.funnom
 end record

 define w_arr_1         integer
 define w_arr_telprctxt integer
 define w_arr_prtprc    integer
 define i               integer
 define l_linha         char(1)

	define	w_pf1	integer

	let	w_arr_1  =  null
	let	w_arr_telprctxt  =  null
	let	w_arr_prtprc  =  null
	let	i  =  null
	for	w_pf1  =  1  to  50
		initialize  a_datktelprc[w_pf1].*  to  null
	end	for
	for	w_pf1  =  1  to  100
		initialize  a_datkprctxt[w_pf1].*  to  null
	end	for
	initialize  ws.*  to  null

# PSI 175269 - Inicio
# if g_issk.dptsgl <> "ct24hs" and
#    g_issk.dptsgl <> "psocor" and
#    g_issk.dptsgl <> "drtria" and
#    g_issk.dptsgl <> "desenv" then
#       return
# end if
# PSI 175269 - Final

 #----------------------------------------------------------------------
 # Inicializa variaveis
 #----------------------------------------------------------------------
 initialize a_datkprctxt  to null
 initialize ws.*             to null
 let ws.entrada  =  today
 let ws.saida    =  ws.entrada[7,10], "-",
                    ws.entrada[4,5],  "-",
                    ws.entrada[1,2],  " ",
                    time
 let ws.hoje    =  ws.saida

 if param.smlflg  =  "S"   then
    let ws.hoje  =  today
 end if
 select funnom
   into ws.funnom
   from isskfunc
  where empcod = g_issk.empcod
   and  funmat = g_issk.funmat

 if param.smlflg  =  "S"  then
    let ws.comando = " select telprccod, dptsgl ",
                       " from datktel, datktelprc ",
                       "where datktel.telnom     = ? ",
                         "and datktel.telcod = datktelprc.telcod ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datktelprc.prcsitcod in ('A','P') "
## PSI 175269 - Inicio
    if g_issk.dptsgl is not null then
       if g_issk.dptsgl[4,6] = 'hum' then
          let ws.comando = ws.comando clipped, "and dptsgl matches '*hum'"
       else
          let ws.comando = ws.comando clipped, "and (dptsgl = '",
                           g_issk.dptsgl,"' or dptsgl is null)"
       end if
    else
       let ws.comando = ws.comando clipped, "and dptsgl is null"
    end if
    let ws.comando = ws.comando clipped,
## PSI 175269 - Final
                         "order by 1 desc "
 end if
 if param.smlflg  <> "S"  then
    let ws.comando = " select telprccod, dptsgl ",
                       " from datktel, datktelprc ",
                       "where datktel.telnom     = ? ",
                         "and datktel.telcod = datktelprc.telcod ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datktelprc.prcsitcod = 'A' "
## PSI 175269 - Inicio
    if g_issk.dptsgl is not null then
       if g_issk.dptsgl[4,6] = 'hum' then
          let ws.comando = ws.comando clipped, "and dptsgl matches '*hum'"
       else
          let ws.comando = ws.comando clipped, "and (dptsgl = '",
                           g_issk.dptsgl,"' or dptsgl is null)"
       end if
    else
       let ws.comando = ws.comando clipped, "and dptsgl is null"
    end if
    let ws.comando = ws.comando clipped,
## PSI 175269 - Final
                         "order by 1 desc "
 end if
 prepare  p_cts14g02_001 from ws.comando
 declare  c_cts14g02_001 cursor for p_cts14g02_001

 open c_cts14g02_001 using  param.telnom,
                            ws.hoje,
                            ws.hoje
 fetch c_cts14g02_001 into ws.telprccod
 if sqlca.sqlcode <> NOTFOUND  then
    let w_arr = 1

    foreach c_cts14g02_001 into a_datktelprc[w_arr].telprccod
       let w_arr = w_arr + 1
    end foreach

    open window w_cts14g02 at 3,5 with form "cts14g02"
        attribute (border,form line 1, message line last)

    let ws.cabtxt = "                            NOTICIAS DO DIA"
    display  ws.cabtxt  to  cabtxt
    message " (F17)Abandona"

    let w_arr            =  w_arr - 1
    let w_arr_telprctxt  =  1

    let a_datkprctxt[w_arr_telprctxt].telprctxt = ws.funnom
    let w_arr_telprctxt = w_arr_telprctxt + 1
    let a_datkprctxt[w_arr_telprctxt].telprccod = "   "
    let w_arr_telprctxt = w_arr_telprctxt + 1
    let l_linha = 'N'
     # Colocado o teste de estouro array devido ao problema ocorrido em 16/10
     # O erro "coredump" ocorreu nas maquinas U39,U70,U74,U87, O que não ocorre nas outras 4 maquinas.
     # Foi retirado o If da linha 189 e colocado o teste if w_arr_telprctxt <= 100 then para sair do
     # do for caso o array estoure.
     for i = 1  to  w_arr
       #if i > 1 then
       if w_arr_telprctxt <= 100 then # Amilton
          if l_linha = 'N'  then
             let a_datkprctxt[w_arr_telprctxt].telprctxt  =   "-----------------------------------------------------------------------------------"
             let w_arr_telprctxt = w_arr_telprctxt + 1
             let l_linha = 'S'
          end if
       else
          exit for
       end if
       declare c_datkprctxt cursor for
         select telprcseq, telprctxt, telprccod
           from datkprctxt
          where telprccod = a_datktelprc[i].telprccod

       let ws.primeiro = "S"

      foreach c_datkprctxt into a_datkprctxt[w_arr_telprctxt].*
        if ws.primeiro = "S" then
           let ws.primeiro = "N"
        else
           let a_datkprctxt[w_arr_telprctxt].telprccod = "   "
        end if
        let w_arr_telprctxt = w_arr_telprctxt + 1
        let l_linha = 'N'
        if w_arr_telprctxt  >  100   then
           error " Limite excedido. Atendimento c/ mais de 100 linhas de procedimento!"
           exit foreach
        end if
      end foreach
    end for

   call set_count(w_arr_telprctxt - 1)
   display array a_datkprctxt to s_cts14g02.*

      on key (f8)
         let w_arr_1 = arr_curr()
         if a_datkprctxt[w_arr_1].telprccod   is null   or
            a_datkprctxt[w_arr_1].telprccod   = "  "    then
            error " Conferencia disponivel apenas na primeira linha do texto!"
         else
           # Chamada para outra funcao
         end if

      on key (interrupt)
         exit display
    end display
    let int_flag = false
    close window w_cts14g02
else
   ### Nao achou nada
end if
end function
