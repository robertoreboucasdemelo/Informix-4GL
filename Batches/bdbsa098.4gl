#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: bdbsa098.4gl                                              #
# Analista Resp..: Federice                                                  #
# PAS............: 35327                                                     #
#                  Gera Quantidade de servicos imediatos e programados       #
# ...........................................................................#
# Desenvolvimento: Norton Nery, Meta                                         #
# Liberacao......: 24/03/2008                                                #
# ...........................................................................#
#                                                                            #
#                           * * * Alteracoes * * *                           #
#                                                                            #
# Data       Autor Fabrica    Origem    Alteracao                            #
# ---------- --------------   --------- -------------------------------------#
# 22/04/2008 Norton - Meta              Inclusao da da Tabela datmmdtmvt     #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

 define m_log        char(80)

main

  call bdbsa098_prepare()

  call bdbsa098()

end main

#-------------------------#
function bdbsa098_prepare()
#-------------------------#
 
   define l_sql char(900)
 
  initialize l_sql to null

  #--------  Servicos Imediatos Auto
 
  let l_sql = ' select count(*) '
             ,' from datmservico '
             ,' where atdfnlflg in ("N","A") '
             ,' and   atdlibflg = "S" '
             ,' and   atdsrvorg in (1,2,3,4,5,6,7,12) '
             ,' and   (atddatprg is null and atdhorprg is null) '

  prepare pbdbsa098001 from l_sql
  declare cbdbsa098001 cursor for pbdbsa098001

  #--------  Servicos Imediatos Outros

   let l_sql = ' select count(*) '
              ,' from datmservico '
              ,' where atdfnlflg in ("N","A") '
              ,' and   atdlibflg = "S" '
              ,' and   atdsrvorg in (9,13) '
              ,' and   (atddatprg is null and atdhorprg is null) '

  prepare pbdbsa098002 from l_sql
  declare cbdbsa098002 cursor for pbdbsa098002
 
  let l_sql = ' select count(*) '
              ,' from datmservico '
              ,' where atdfnlflg in ("N","A") '
              ,' and   atdlibflg = "S" '
              ,' and   atdsrvorg not in (8,10,15) '
              ,' and   (atddatprg = ? and atdhorprg >= ? ) '
              ,' and   (atddatprg = ? and atdhorprg <= ? ) '
 
  #--------  Servicos Programados Auto

  let l_sql = ' select count(*) '
             ,' from datmservico '
             ,' where atdfnlflg in ("N","A") '
             ,' and   atdlibflg = "S" '
             ,' and   atdsrvorg in (1,2,3,4,5,6,7,12) '
             ,' and   srvprsacnhordat < ? '

  prepare pbdbsa098003 from l_sql
  declare cbdbsa098003 cursor for pbdbsa098003

  #--------  Servicos Programados Outros

  let l_sql = ' select count(*) '
             ,' from datmservico '
             ,' where atdfnlflg in ("N","A") '
             ,' and   atdlibflg = "S" '
             ,' and   atdsrvorg in (9,13) '
             ,' and   srvprsacnhordat < ? '

  prepare pbdbsa098004 from l_sql
  declare cbdbsa098004 cursor for pbdbsa098004

  #--------  Sinais GPS
 
  let l_sql = ' select count(*) '
              ,' from datmmdtmvt '
              ,' where mdtmvtstt = 1 '
 
  prepare pbdbsa098005 from l_sql
  declare cbdbsa098005 cursor for pbdbsa098005

end function

#----------------------------------------------------------------------
function  bdbsa098()
#----------------------------------------------------------------------

  define l_data_ini         date,
         l_data_fim         date,
         l_hora             datetime hour to second,
         l_cur              datetime hour to second,
         l_hora_fim         datetime hour to minute, 
	 l_hora_ini         datetime hour to minute,
	 l_data_ini_aux     datetime year to minute,
	 l_data_fim_aux     datetime year to second,
	 l_qtde_imed_auto   integer,
	 l_qtde_imed_outros integer,
	 l_qtde_prog_auto   integer,
	 l_qtde_prog_outros integer,
	 l_qtde_gps         integer,
	 teste              char(1)

  let m_log   = null

  let m_log = f_path('DBS','LOG')

  if m_log is null or
    m_log = ' '   then
    let m_log = '.'
  end if

  let m_log = m_log clipped, "/ldbsa098.log"

  call startlog(m_log)

  set lock mode to wait 30
  set isolation to dirty read

  while true

    let l_qtde_imed_auto    = 0
    let l_qtde_imed_outros  = 0
    let l_qtde_prog_auto    = 0
    let l_qtde_prog_outros  = 0
    let l_qtde_gps          = 0

    start report  arq_log  to  m_log             
    
  #-------- Servicos Imediatos Auto

    open cbdbsa098001  

    whenever error continue
       fetch cbdbsa098001 into l_qtde_imed_auto
    whenever error stop

  #-------- Servicos Imediatos Outros

    open cbdbsa098002  

    whenever error continue
       fetch cbdbsa098002 into l_qtde_imed_outros 
    whenever error stop

    let l_data_ini_aux = null
    let l_data_fim_aux = null
    let l_data_ini     = null
    let l_data_fim     = null
    let l_hora_ini     = null
    let l_hora_fim     = null

    let l_data_ini_aux = current 
    let l_data_fim_aux = l_data_ini_aux + 2 units hour

    let l_data_ini     = date(l_data_ini_aux)
    let l_data_fim     = date(l_data_fim_aux)
    let l_hora_ini     = extend(l_data_ini_aux,hour to second)
    let l_hora_fim     = extend(l_data_fim_aux,hour to second)
    
  #--------  Servicos Programados Auto

    open cbdbsa098003  using l_data_fim_aux 

    whenever error continue
      fetch cbdbsa098003 into l_qtde_prog_auto
    whenever error stop

  #--------  Servicos Programados Outros

    open cbdbsa098004  using  l_data_fim_aux

    whenever error continue
      fetch cbdbsa098004  into l_qtde_prog_outros
    whenever error stop

  #--------  Qtde de GPS nao processados

    open cbdbsa098005  

    whenever error continue
      fetch cbdbsa098005  into l_qtde_gps 
    whenever error stop

  #--------  Grava no arquivo de log as quantidades dos servicos

    output to report arq_log(l_qtde_imed_auto, l_qtde_imed_outros,
                             l_qtde_prog_auto, l_qtde_prog_outros, l_qtde_gps)

    finish report  arq_log   

  #--------  Aguarda 60 segundos para novo processamento

    sleep 60

  end while

end function  ###--- bdbsa098

#---------------------------------------------------------------------------
 report arq_log (r_qtde_imed_auto,r_qtde_imed_outros,r_qtde_prog_auto,
		 r_qtde_prog_outros,r_qtde_gps)
#---------------------------------------------------------------------------

 define r_qtde_imed_auto   char(12),
        r_qtde_imed_outros char(12),
	r_qtde_prog_auto   char(12),
	r_qtde_prog_outros char(12),
	r_qtde_gps         char(12)

output
  left   margin  00
  right  margin  00
  top    margin  00
  bottom margin  00
  page   length  01

format

on every row
  print column 001, r_qtde_imed_auto   clipped, "|",
		    r_qtde_imed_outros clipped, "|",
		    r_qtde_prog_auto   clipped, "|",
		    r_qtde_prog_outros clipped, "|",
                    r_qtde_gps         clipped 

end report



