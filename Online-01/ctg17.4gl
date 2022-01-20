#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central24h                                                 #
# Modulo         : ctg17.4gl                                                 #
#                  Tela consulta negocios do cliente.                        #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 173894 -                                                  #
# OPF            : 23787  -                                                  #
#............................................................................#
# Desenvolvimento: Fabrica de Software - Ronaldo Marques                     #
# Liberacao      : 22/07/2003                                                #
#----------------------------------------------------------------------------#
#                       * * * Alteracoes * * *                               #
#                                                                            #
# Data       Autor  Fabrica   Origem     Alteracao                           #
# ---------- ---------------- ---------- ------------------------------------#
# 23/07/2004 Marcio Meta      PSI186376  Incluir nova chamada da funcao      #
#                             OSF038105  osgtc505_com().                     #
# 22/01/2008 Roberto          8014966    Alteracao do programa de clientes   #
#                                        para osgtc550                       #
#                                                                            #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl" 
define  w_log     char(60)   

MAIN                                               

   define w_data date

   call fun_dba_abre_banco("CT24HS")
   
   
   let w_log = f_path("ONLTEL","LOG")
   if w_log is null then
      let w_log = "."
   end if
   let w_log = w_log clipped,"/dat_ctg17.log"

   call startlog(w_log)

   #------------------------------------------
   #  ABRE BANCO   (TESTE ou PRODUCAO)
   #------------------------------------------

   
   
   whenever error continue                                  # Marcio Meta PSI186376
    select sitename 
      into g_hostname
      from dual
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode <> notfound then
         display " Erro select dual ",sqlca.sqlcode,'/',sqlca.sqlerrd[2]
         display " ctg17/main "
      else
         display " sitename nao encontrado " 
      end if 
      exit program(1)
   end if                                                   # Marcio Meta PSI186376

   let g_hostname = g_hostname[1,3]

   defer interrupt
   set lock mode to wait

   options
      prompt  line last,
      comment line last,
      message line last,
      accept  key  F40

   whenever error continue

   open window WIN_CAB at 2,2 with 22 rows,78 columns
        attribute (border)

   let w_data = today
   display "CENTRAL 24 HS" at 01,01
   display "P O R T O   S E G U R O  -  S E G U R O S" AT 1,20
   display w_data       at 01,69

   open window WIN_MENU at 04,02 with 20 rows, 78 columns
   call p_reg_logo()
   call get_param()

   display "---------------------------------------------------------------",
           "--------ctg17--" at 03,01

   call ctg17()

   close window win_cab
   close window win_menu

END MAIN

#----------------------------------------------------------
function p_reg_logo()
#----------------------------------------------------------
     define ba char(01)


	let	ba  =  null

     open form reg from "apelogo2"
     display form reg
     let ba = ascii(92)
     display ba at 15,23
     display ba at 14,22
     display "PORTO SEGURO" AT 16,52
     display "                                  Seguros" at 17,23
             attribute (reverse)


end function

--------------------------------------------------------------------------------
function ctg17()
--------------------------------------------------------------------------------
 define	l_parIn		record
	opcao		char(01),
	segnumdig	like gsakseg.segnumdig,
	segnom		like gsakseg.segnom,
	pestip		like gsakseg.pestip,
	cgccpfnum	like gsakseg.cgccpfnum,
	cgcord		like gsakseg.cgcord,
	cgccpfdig	like gsakseg.cgccpfdig
 end	record

 define	l_ret505_com	record
	texto		char(03),
	cgccpf		char(20),
	restricoes	char(24)
 end	record

 define	l_ret505_doc	record
	flag		char(01)
 end	record
 define	i		smallint
 define	l_chrTmp	char(50)

 let l_parIn.opcao        = arg_val(15)
 let l_parIn.segnumdig    = arg_val(16)
 let l_parIn.segnom       = arg_val(17)
 let l_parIn.pestip       = arg_val(18)
 let l_parIn.cgccpfnum    = arg_val(19)
 let l_parIn.cgcord       = arg_val(20)
 let l_parIn.cgccpfdig    = arg_val(21)
 

 if l_parIn.pestip    is null or
    l_parIn.cgccpfnum is null then
      let g_issparam = null
 else
      let g_issparam = l_parIn.pestip clipped, l_parIn.cgccpfnum using '<<<&&&&&&' 
 end if 
 
 call osgtc550("")   
 
end function



