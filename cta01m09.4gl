###############################################################################
# Nome do Modulo: CTA01M09                                           Marcelo  #
#                                                                    Gilberto #
# Consulta ligacoes para advertencia ao atendente                    Jan/1998 #
###############################################################################
# 23/09/2006  Ruiz           psi202720 Consultar ligacoes de apolices        #
#                                      do Saude(Saude+Casa).                 #
##############################################################################
 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cta01m09(param)
#-----------------------------------------------------------

 define param       record
    succod          like datrligapol.succod,
    ramcod          like datrligapol.ramcod,
    aplnumdig       like datrligapol.aplnumdig,
    itmnumdig       like datrligapol.itmnumdig
 end record

 define a_cta01m09 array[200]  of record
    c24astagpdes    char(40)
 end record

 define ws          record
    c24astagp       like datkassunto.c24astagp,
    c24astcod       like datkassunto.c24astcod,
    cabec           char(54)
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 define w_comando   char(1000)


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	w_comando  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cta01m09[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 if (param.succod     is null  or
    param.ramcod      is null  or
    param.aplnumdig   is null  or
    param.itmnumdig   is null   )and
    g_ppt.cmnnumdig   is null    and
    g_documento.crtsaunum is null then
    error " Nenhum parametro informado para pesquisa, AVISE INFORMTICA!"
    return
 end if

 initialize ws.*     to null
 let int_flag = false
 let arr_aux  = 1
 let ws.cabec = "                    A T E N C A O"

 #------------------------------------------------------------------
 # Procura ligacoes com codigo de assunto marcados para advertencia
 #------------------------------------------------------------------
 if g_ppt.cmnnumdig       is null and
    g_documento.crtsaunum is null then
    
    if g_documento.ciaempcod = 84 then # Itau
        let w_comando = " select datkassunto.c24astagp, ",                            
                        "        datkassunto.c24astcod  ",                            
                          " from datrligapol, datmligacao, datrligitaaplitm, outer datkassunto ",       
                         " where datrligapol.succod       = "  ,param.succod,           
                           " and datrligapol.ramcod       = "  ,param.ramcod,           
                           " and datrligapol.aplnumdig    = "  ,param.aplnumdig,        
                           " and datrligapol.itmnumdig    = "  ,param.itmnumdig,
                           " and datrligitaaplitm.itaciacod = ",g_documento.itaciacod,         
                           " and datmligacao.lignum       = datrligapol.lignum ",     
                           " and datrligitaaplitm.lignum  = datrligapol.lignum ",
                           " and datkassunto.c24astcod    = datmligacao.c24astcod ",  
                           " and datkassunto.c24aststt    = 'A'",                     
                           " and datkassunto.c24astatdflg = 'S'",                     
                         " group by datkassunto.c24astagp, ",                         
                         "          datkassunto.c24astcod  "                          
    else
    
        let w_comando = " select datkassunto.c24astagp, ",
                        "        datkassunto.c24astcod  ",
                          " from datrligapol, datmligacao, outer datkassunto ",
                         " where datrligapol.succod       = ",param.succod,
                           " and datrligapol.ramcod       = ",param.ramcod,
                           " and datrligapol.aplnumdig    = ",param.aplnumdig,
                           " and datrligapol.itmnumdig    = ",param.itmnumdig,
                           " and datmligacao.lignum       = datrligapol.lignum ",
                           " and datkassunto.c24astcod    = datmligacao.c24astcod ",
                           " and datkassunto.c24aststt    = 'A'",
                           " and datkassunto.c24astatdflg = 'S'",
                         " group by datkassunto.c24astagp, ",
                         "          datkassunto.c24astcod  "
    end if
 else
    if g_ppt.cmnnumdig is not null then
       let w_comando = " select datkassunto.c24astagp, ",
                       "        datkassunto.c24astcod  ",
                         " from datrligppt, datmligacao, outer datkassunto ",
                        " where datrligppt.cmnnumdig  = ",g_ppt.cmnnumdig,
                          " and datmligacao.lignum    = datrligppt.lignum ",
                          " and datkassunto.c24astcod = datmligacao.c24astcod ",
                          " and datkassunto.c24aststt = 'A'",
                          " and datkassunto.c24astatdflg = 'S'",
                        " group by datkassunto.c24astagp, ",
                        "          datkassunto.c24astcod  "
    else
       if g_documento.crtsaunum is not null then
          let w_comando = " select datkassunto.c24astagp, ",
                          "        datkassunto.c24astcod  ",
                         " from datrligsau, datmligacao, outer datkassunto ",
                        " where datrligsau.crtnum     = ",g_documento.crtsaunum,
                          " and datmligacao.lignum    = datrligsau.lignum ",
                          " and datkassunto.c24astcod = datmligacao.c24astcod ",
                          " and datkassunto.c24aststt = 'A'",
                          " and datkassunto.c24astatdflg = 'S'",
                        " group by datkassunto.c24astagp, ",
                        "          datkassunto.c24astcod  "
       end if
    end if
 end if
 prepare s_cta01m09 from w_comando
 declare  c_cta01m09  cursor for s_cta01m09

#open c_cta01m09
 foreach  c_cta01m09  into  ws.c24astagp, ws.c24astcod
    if ws.c24astagp  is null    then
       continue foreach
    end if
    --[ qdo for Azul ou Itau lista os assuntos ]----
    if g_documento.ciaempcod = 35 or
       g_documento.ciaempcod = 84 then 
       select c24astdes
          into a_cta01m09[arr_aux].c24astagpdes
          from datkassunto
         where c24astcod = ws.c24astcod
    else
       ----[ qdo for Porto, lista os agrupamentos ]---
       select c24astagpdes
         into a_cta01m09[arr_aux].c24astagpdes
         from datkastagp
        where c24astagp = ws.c24astagp
    end if

    let arr_aux = arr_aux + 1
    if arr_aux > 200 then
       error " Limite excedido. Pesquisa com mais de 200 assuntos!"
       exit foreach
    end if
 end foreach

 if arr_aux  > 1   then
    open window cta01m09 at 08,13 with form "cta01m09"
                attribute (form line first, border)

    display by name  ws.cabec   attribute(reverse)

    message " (F17)Abandona"
    call set_count(arr_aux-1)

    display array  a_cta01m09 to s_cta01m09.*
       on key(interrupt)
          exit display
    end display

    close window cta01m09
 end if

 close c_cta01m09
 let int_flag = false

end function   ##  cta01m09
