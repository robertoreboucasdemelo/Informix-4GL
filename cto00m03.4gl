###############################################################################
# Nome do Modulo: CTO00M03                                           Ruiz     #
#                                                                    Akio     #
# Mostra o cadastro de agrupamentos                                  Abr/2000 #
###############################################################################
#                                                                             #
#                   * * * Alteracoes * * *                                    #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 19/09/2003 robson            PSI175250  Mostrar os agrupamentos referente ao#
#                              OSF25565   departamento do atendente e os agru-#
#                                         pamentos validos para todos os de-  #
#                                         partamentos , com excessao do RH.   #
#                                         Caso seja RH, mostrar somente os a- #
#                                         grupamentos deste.                  #
###############################################################################

#globals "/homedsa/fontes/ct24h/producao/glcte.4gl"
globals "/homedsa/projetos/geral/globals/glcte.4gl"

define m_cto00m03_prep smallint                           # PSI175250

#------------------------#
 function cto00m03_prep()                                 # PSI175250 - inicio
#------------------------#

 define l_sql_stmt  char(300)

 let l_sql_stmt = " select corassagpcod, ",
                         " corassagpdes, ",
                         " dptsgl, ",
                         " dptassagputztip ",
                    " from dackassagp ",
                   " order by corassagpdes "

 prepare pcto00m03001 from l_sql_stmt
 declare ccto00m03001 cursor for pcto00m03001

 let m_cto00m03_prep = true

end function                                              # PSI175250 - fim

#-----------------------------------------------------------
 function cto00m03()
#-----------------------------------------------------------

 define a_cto00m03 array[100] of record
    corassagpcod   like dackassagp.corassagpcod,
    corassagpdes   like dackassagp.corassagpdes
 end record

 define arr_aux    smallint

 define l_dptsgl          like dackassagp.dptsgl               # PSI175250
 define l_dptassagputztip like dackassagp.dptassagputztip      # PSI175250
 define l_achou    smallint     # PSI175250

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_cto00m03[w_pf1].*  to  null
	end	for

   initialize a_cto00m03,
              arr_aux      to null

 if m_cto00m03_prep is null or                          # PSI175250
    m_cto00m03_prep <> true then                        # PSI175250
    call cto00m03_prep()                                # PSI175250
 end if                                                 # PSI175250

 open window cto00m03 at 10,30 with form "cto00m03"
                     attribute(form line 1, border)

 let int_flag = false
 initialize a_cto00m03  to null

 let arr_aux = 1
 let l_achou = true

 open ccto00m03001                                        # PSI175250 - inicio
 foreach ccto00m03001  into  a_cto00m03[arr_aux].corassagpcod,
                             a_cto00m03[arr_aux].corassagpdes,
                             l_dptsgl,
                             l_dptassagputztip
    
    let l_achou = true

    if g_issk.acsnivcod < 8  then
       if g_issk.dptsgl[4,6] = "hum" then
          if l_dptsgl is null or 
            (l_dptsgl <> g_issk.dptsgl and l_dptsgl[4,6] <> "hum") then
             let l_achou = false
          end if
       else
          if l_dptsgl is null or (l_dptsgl = g_issk.dptsgl and
             l_dptassagputztip = "E") then
             let l_achou = true
          else
             let l_achou = false
          end if
       end if
    end if                                                # PSI175250 - fim

    if l_achou then
       let arr_aux = arr_aux + 1
    end if

 end foreach

 message "  (F17)Abandona, (F8)Seleciona"
 call set_count(arr_aux - 1)

 display array a_cto00m03 to s_cto00m03.*

    on key (interrupt,control-c)
       initialize a_cto00m03   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       exit display

   end display

   let int_flag = false

   close window  cto00m03

   return a_cto00m03[arr_aux].corassagpcod,
          a_cto00m03[arr_aux].corassagpdes

end function  ###  cto00m03
