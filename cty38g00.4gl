#------------------------------------------------------------------------------#           
# Porto Seguro Cia Seguros Gerais                                              #           
#..............................................................................#           
# Sistema........: Central 24 Horas                                            #           
# Modulo.........: cty38g00                                                    #           
# Objetivo.......: Funcoes para tratamento do motivo do bloqueio do socorrista.#           
# Analista Resp. : Beatriz Araujo                                              #           
# PSI            : 21950                                                       #           
#..............................................................................#           
# Desenvolvimento: Fornax Tecnologia                                           #           
# Liberacao      : 01/10/2014                                                  #           
#..............................................................................#           
                                                                                           
globals "/homedsa/projetos/geral/globals/glct.4gl"                                        
globals "/homedsa/projetos/geral/globals/figrc072.4gl"
                                                           
database porto                                                                             
                                                                                           
define m_hostname   char(12)                                
define m_server     like ibpkdbspace.srvnom
define m_prepare    smallint    

#------------------------------------------------------------------------------#
function cty38g00_prepare()                        
#------------------------------------------------------------------------------#
                                                    
define l_sql char(500)                            
                                                    
let m_server = fun_dba_servidor("CT24HS")

let m_hostname = "porto@", m_server clipped, ":"

let l_sql = "select *             "
          , "  from datksrr       "
          , " where srrcoddig = ? "
          , "   and srrstt    = 2 "
prepare pcty38g00001 from l_sql                  
declare ccty38g00001 cursor for pcty38g00001 

let l_sql = "select blqmtvcod        "
          , "  from datmsrratmblqpgm "
          , " where srrdigcod    = ? "
          , "   and blqpgmsitcod = 2 "
          , " order by blqpgmseqnum desc "
prepare pcty38g00002 from l_sql                  
declare ccty38g00002 cursor for pcty38g00002 

let l_sql = "select cpodes "
          , "  from ", m_hostname clipped, "datkdominio"
          , " where cponom = ? "
          , "   and cpocod = ? "
prepare pcty38g00003 from l_sql                  
declare ccty38g00003 cursor for pcty38g00003 
 
let l_sql = "select cpodes, cpocod"
          , "  from ", m_hostname clipped, "datkdominio"
          , " where cponom  = ? "
          , " order by cpodes"
prepare pcty38g00004 from l_sql 
declare ccty38g00004 cursor for pcty38g00004

let l_sql = "select blqpgmseqnum, blqpgmsitcod "
          , "  from datmsrratmblqpgm  "
          , " where srrdigcod     = ? "
          , "   and blqpgmsitcod <> 3 "  
          , " order by blqpgmseqnum   "
prepare pcty38g00005 from l_sql                  
declare ccty38g00005 cursor with hold for pcty38g00005 

let l_sql = "update datmsrratmblqpgm    "
	  , "   set blqpgmsitcod    = ? "
	  , "     , regatldat       = ? "
	  , "     , regatlusrempcod = ? "
	  , "     , regatlusrmatnum = ? "
	  , "     , regatlusrtipcod = ? "
          , " where srrdigcod    = ? "
	  , "   and blqpgmseqnum = ? "
prepare pcty38g00006 from l_sql                  

let l_sql = "update datksrr       "
          , "   set srrstt    = ? "
          , " where srrcoddig = ? "
prepare pcty38g00007 from l_sql                  

let l_sql = "select srrnom        "
          , "  from datksrr       "
          , " where srrcoddig = ? "
prepare pcty38g00008 from l_sql                  
declare ccty38g00008 cursor for pcty38g00008 

let l_sql = "select b.maides, a.pstcoddig     "
          , "  from datrsrrpst a, dpaksocor b "
          , " where a.srrcoddig = ?           "
          , "   and a.viginc   <= ?           "
          , "   and b.pstcoddig = a.pstcoddig "
          , " order by a.viginc desc          "
prepare pcty38g00009 from l_sql                  
declare ccty38g00009 cursor for pcty38g00009 

let l_sql = "select blqpgmseqnum "
          , "  from datmsrratmblqpgm  "
          , " where srrdigcod     = ? "
          , "   and blqpgmseqnum <> ? "  
          , "   and blqpgmsitcod <> 3 "  
          , "   and blqincdat    <= ? "  
          , "   and blqfnldat    >= ? "  
          , " order by blqpgmseqnum   "
prepare pcty38g00010 from l_sql                  
declare ccty38g00010 cursor for pcty38g00010 

let l_sql = "select blqpgmobstxt     "
          , "  from datmsrratmblqpgm "
          , " where srrdigcod    = ? "
          , "   and blqpgmseqnum = ? "
prepare pcty38g00011 from l_sql
declare ccty38g00011 cursor for pcty38g00011

let m_prepare = true          
                                
end function 

#------------------------------------------------------------------------------#
function cty38g00_atualiza_bloq_progr(lr_par_in)
#------------------------------------------------------------------------------#

define lr_par_in    record                         
       srrcoddig    like datksrr.srrcoddig
     , srrstt       like datksrr.srrstt      
     , blqpgmseqnum like datmsrratmblqpgm.blqpgmseqnum
     , blqpgmsitcod like datmsrratmblqpgm.blqpgmsitcod
     , blqmtvcod    like datmsrratmblqpgm.blqmtvcod
     , blqincdat    like datmsrratmblqpgm.blqincdat
     , blqfnldat    like datmsrratmblqpgm.blqfnldat 
     , current      datetime year to minute
end    record

define lr_retorno   record
       status       smallint
     , mensagem     char(100)
end    record

define lr_auxiliar  record                         
       data         date
     , current      datetime year to minute
     , status       smallint 
     , mensagem     char(500) 
     , blqmtvdes    char(500)
     , blqdat       char(16)
     , blqpgmobstxt like datmsrratmblqpgm.blqpgmobstxt
end    record

#--> Inicializa 

if m_prepare is null or m_prepare <> true then
   call cty38g00_prepare()
end if
   
initialize lr_retorno.*, lr_auxiliar.* to null

call cty38g00_datkdominio('blqmtvcod',lr_par_in.blqmtvcod) 
     returning lr_auxiliar.status
	     , lr_auxiliar.mensagem 
	     , lr_auxiliar.blqmtvdes

let lr_retorno.status   = 0 
let lr_retorno.mensagem = ""

let g_issk.empcod = 1 
let g_issk.funmat = 999999
let g_issk.usrtip = "F"

#--> Atualiza a situacao no cadastro do socorrista

whenever error continue 
execute pcty38g00007 using lr_par_in.srrstt
			 , lr_par_in.srrcoddig
whenever error stop
if sqlca.sqlcode  <>  0   then
   let lr_retorno.status = 1
   let lr_retorno.mensagem = "Problema na atualizacao do cadastro do socorrista "
			   , "(pcty38g00007) : "
			   , sqlca.sqlcode using "-<<<<&"
   return lr_retorno.*
end if

#--> Atualiza a programacao de bloqueio automatico

execute pcty38g00006 using lr_par_in.blqpgmsitcod
			 , lr_par_in.current 
		         , g_issk.empcod
		         , g_issk.funmat
		         , g_issk.usrtip
		         , lr_par_in.srrcoddig
		         , lr_par_in.blqpgmseqnum
whenever error stop
if sqlca.sqlcode <> 0 then
   let lr_retorno.status = 1 
   let lr_retorno.mensagem = "Problema na atualizazao da programacao do bloqueio "
			   , "(pcty38g00006) : "
			   , sqlca.sqlcode using "-<<<<&"
   return lr_retorno.*
end if

#--> Atualiza historico do socorrista

open ccty38g00011 using lr_par_in.srrcoddig
                      , lr_par_in.blqpgmseqnum
whenever error continue
fetch ccty38g00011 into lr_auxiliar.blqpgmobstxt
whenever error stop
if sqlca.sqlcode <> 0 then
   let lr_auxiliar.blqpgmobstxt = ""
end if

if lr_par_in.srrstt = 2 then
   let lr_auxiliar.blqdat   = lr_par_in.blqincdat
   let lr_auxiliar.mensagem = "BLOQUEIO AUTOMATICO ("
                            , lr_auxiliar.blqmtvdes clipped
                            , ") "
else
   let lr_auxiliar.blqdat   = lr_par_in.blqfnldat
   let lr_auxiliar.mensagem = "DESBLOQUEIO AUTOMATICO ("
                            , lr_auxiliar.blqmtvdes clipped
                            , ") "
end if 

let lr_auxiliar.mensagem = lr_auxiliar.mensagem clipped, " "
                         , lr_auxiliar.blqdat[09,10], "/"
                         , lr_auxiliar.blqdat[06,07], "/"
                         , lr_auxiliar.blqdat[01,04], " "
                         , lr_auxiliar.blqdat[12,16], " "

if lr_auxiliar.blqpgmobstxt is not null and
   lr_auxiliar.blqpgmobstxt <> " "      then
   let lr_auxiliar.mensagem = lr_auxiliar.mensagem clipped, " - "
                            , lr_auxiliar.blqpgmobstxt clipped
end if

call cty38g00_grava_hist(lr_par_in.srrcoddig
                        ,lr_auxiliar.mensagem
                        ,lr_par_in.current 
                        ,""
                        ,"X")
     returning lr_auxiliar.status
if lr_auxiliar.status <> 1 then 
   let lr_retorno.status = 1 
   let lr_retorno.mensagem = "Problema na atualizacao do historico do socorrista "
			   , "(Erro:"
                           , sqlca.sqlcode using "-<<<<<<&"
                           , ")"
   return lr_retorno.*
end if 

#--> Envia e-mail para base do socorrista

call cty38g00_email_base (lr_par_in.srrcoddig
                         ,lr_par_in.srrstt
                         ,lr_auxiliar.blqmtvdes
                         ,lr_par_in.current) 
     returning lr_auxiliar.status 
             , lr_auxiliar.mensagem
if lr_auxiliar.status <> 0 then 
   let lr_retorno.status = 1 
   let lr_retorno.mensagem = lr_auxiliar.mensagem clipped
end if

#--> Atualiza acesso ao Portal via Seguranca da Informacao

call ctd40g00_verifica_bloqueio(lr_par_in.srrcoddig)
     returning lr_auxiliar.status
             , lr_auxiliar.mensagem
if lr_auxiliar.status <> 0 then
   let lr_retorno.status = 0 #--> Forca Ok pq a funcionalidade esta com problema ...
   let lr_retorno.mensagem = lr_auxiliar.mensagem clipped
end if

#--> Retorno

return lr_retorno.*

end function 

#------------------------------------------------------------------------------#
function cty38g00_finaliza_bloq_progr (lr_par_in)
#------------------------------------------------------------------------------#

define lr_par_in    record                         
       srrcoddig    like datksrr.srrcoddig
     , srrstt       like datksrr.srrstt
end    record 

define lr_auxiliar  record                         
       blqpgmseqnum like datmsrratmblqpgm.blqpgmseqnum
     , blqpgmsitcod like datmsrratmblqpgm.blqpgmsitcod
     , data         date
     , current      datetime year to minute
     , mensagem     char(1000)
     , status       smallint 
     , count        integer  
end    record

define lr_retorno   record                         
       status       smallint
     , mensagem     char(80)
end    record

#--> Inicializa 

if m_prepare is null or m_prepare <> true then
   call cty38g00_prepare()
end if
   
initialize lr_auxiliar.*, lr_retorno.* to null

let lr_retorno.status   = 0 
let lr_auxiliar.count   = 0 
let lr_auxiliar.current = current 
let lr_auxiliar.data    = lr_auxiliar.current

#--> Somente finaliza bloqueio se for uma reativacao ou cancelamento de socorrista

if lr_par_in.srrstt <> 1 and 
   lr_par_in.srrstt <> 3 then
   return lr_retorno.* 
end if 

#--> Busca o registro de bloqueio do socorrista

open ccty38g00005 using lr_par_in.srrcoddig 

foreach ccty38g00005 into lr_auxiliar.blqpgmseqnum
                        , lr_auxiliar.blqpgmsitcod

   #--> Se for uma "ativacao" do socorrista finaliza apenas o bloqueio em curso (efetivado)

   if lr_par_in.srrstt = 1 then
      if lr_auxiliar.blqpgmsitcod <> 2 then 
	 continue foreach
      end if
   end if 

   #--> Finaliza a programacao de bloqueio

   let lr_auxiliar.blqpgmsitcod = 3

   execute pcty38g00006 using lr_auxiliar.blqpgmsitcod
			    , lr_auxiliar.data
			    , g_issk.empcod
			    , g_issk.funmat
			    , g_issk.usrtip
			    , lr_par_in.srrcoddig
			    , lr_auxiliar.blqpgmseqnum
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let lr_retorno.status = 1 
      let lr_retorno.mensagem = " Problema na atualizacao da programacao do bloqueio (Erro:"
			      , sqlca.sqlcode using "-<<<<<<&"
                              , ") !"
      return lr_retorno.*
   end if

   let lr_auxiliar.count = lr_auxiliar.count + 1 
   
end foreach 

if lr_auxiliar.count > 0 then 

   #--> Atualiza historico do socorrista

   if lr_auxiliar.count > 1 then 
      let lr_auxiliar.mensagem = 
	  "Finalizadas as programacoes de bloqueios automaticos "
   else
      let lr_auxiliar.mensagem = 
	  "Finalizada a programacao de bloqueio automatico "
   end if 

   call cty38g00_grava_hist(lr_par_in.srrcoddig
                           ,lr_auxiliar.mensagem
                           ,lr_auxiliar.data
                           ,""
                           ,"X")
        returning lr_auxiliar.status
   if lr_auxiliar.status <> 1 then 
      let lr_retorno.status = 1 
      let lr_retorno.mensagem = " Problema na atualizacao do historico do socorrista (Erro:"
			      , sqlca.sqlcode using "-<<<<<<&"
                              , ") !"
      return lr_retorno.*
   end if 
end if 

return lr_retorno.*

end function

#------------------------------------------------------------------------------#
function cty38g00_conflito_bloqueio (lr_par_in)
#------------------------------------------------------------------------------#

define lr_par_in    record                         
       srrcoddig    like datksrr.srrcoddig
     , blqpgmseqnum like datmsrratmblqpgm.blqpgmseqnum
     , data         datetime year to minute
end    record 

define lr_retorno   record                         
       status       smallint
end    record

#--> Inicializa 

if m_prepare is null or m_prepare <> true then
   call cty38g00_prepare()
end if
   
initialize lr_retorno.* to null

#--> Busca bloqueio ja cadastrado com periodo conflitante 

open ccty38g00010 using lr_par_in.srrcoddig 
                      , lr_par_in.blqpgmseqnum
		      , lr_par_in.data
		      , lr_par_in.data
whenever error continue
fetch ccty38g00010
whenever error stop
if sqlca.sqlcode = 0 then
   let lr_retorno.status = true 
else
   let lr_retorno.status = false
end if

return lr_retorno.*

end function

#------------------------------------------------------------------------------#
function cty38g00_email_base(lr_par_in)
#------------------------------------------------------------------------------#

define lr_par_in    record                         
       srrcoddig    like datksrr.srrcoddig
     , srrstt       like datksrr.srrstt
     , blqmtvdes    char(500)
     , current      datetime year to minute
end    record 

define lr_email     record
       remetente    char(50)
     , destino      char(10000)
     , ccp          char(10000)
     , cco          char(10000)
     , assunto      char(500)
     , corpo        char(32000)
     , idr          char(20)
     , tipo         char(4)
     , anexo        char(10000)
end    record

define lr_auxiliar  record
       status       smallint
     , mensagem     char(500)
     , srrsttdes    char(500)
     , srrnom       like datksrr.srrnom 
end    record

#--> Inicializa 

initialize lr_auxiliar to null

call cty11g00_iddkdominio('srrstt',lr_par_in.srrstt)
     returning lr_auxiliar.status
             , lr_auxiliar.mensagem
             , lr_auxiliar.srrsttdes

if lr_par_in.srrstt = 2 then 
   let lr_auxiliar.srrsttdes = lr_auxiliar.srrsttdes clipped
                             , "/"
                             , lr_par_in.blqmtvdes clipped
end if  

#--> Busca nome do socorrista

whenever error continue 
open  ccty38g00008 using lr_par_in.srrcoddig
fetch ccty38g00008 into  lr_auxiliar.srrnom
whenever error stop
if sqlca.sqlcode = 0 then
   let lr_auxiliar.srrnom = lr_par_in.srrcoddig using "<<<<<<<&"
                          , "-"
                          , lr_auxiliar.srrnom clipped
else
   let lr_auxiliar.srrnom = lr_par_in.srrcoddig using "<<<<<<<&"
end if

#--> Busca destino do e-mail 

whenever error continue 
open  ccty38g00009 using lr_par_in.srrcoddig
                       , lr_par_in.current
fetch ccty38g00009 into  lr_email.destino
whenever error stop
if sqlca.sqlcode <> 0 then
   let lr_email.destino = "analiseqra.portosocorro@portoseguro.com.br"
end if

#--> Monta e-mail

let lr_email.remetente = "analiseqra.portosocorro@portoseguro.com.br"
let lr_email.ccp       = ""
let lr_email.cco       = ""
let lr_email.assunto   = "Alteracao status QRA "
                       , lr_auxiliar.srrnom clipped
let lr_email.idr       = ""
let lr_email.tipo      = "html"
let lr_email.anexo     = ""

let lr_email.corpo     =
    "<html>",
       "<body>",
          "<table width=100% border=0 cellpadding='0'cellspacing='5'>",
             "<tr bgcolor=red>",
                "<td>",
                   "<font face=arial size=2 color=white>",
                   "<center><b>ALTERACAO DE STATUS QRA</b></center>",
                   "</font>",
                "</td>",
             "</tr>",
             "<tr>",
                "<td>",
                   "<font face=arial size=2>",
                      "<br>",
                      "Caro Gestor.",
                      "<br><br>",
                      "Informamos que o QRA ", lr_auxiliar.srrnom clipped,
                      " foi alterado para situacao ", lr_auxiliar.srrsttdes, ".",
                      "<br><br>",
                      "Em caso de duvidas entrar em contato com o Desenvolvimento ",
                      "da Rede de Prestadores.",
                      "<br><br>",
                      "analiseqra.portosocorro@portoseguro.com.br",
                   "</font>",
                "</td>",
             "</tr>",
          "</table>",
       "</body>",
    "</html>"

#--> Envia e-mail

call ctx22g00_envia_email_overload (lr_email.*)
     returning lr_auxiliar.status 
if lr_auxiliar.status <> 0 then 
   let lr_auxiliar.status = 1 
   let lr_auxiliar.mensagem = "Problema no envio do email para base do socorrista "
			   , "(Erro:"
                           , lr_auxiliar.status using "-<<<<<<&"
                           , ")"
else
   let lr_auxiliar.status = 0 
   let lr_auxiliar.mensagem = ""
end if

return lr_auxiliar.status, lr_auxiliar.mensagem

end function

#------------------------------------------------------------------------------#
function cty38g00_motivo(lr_par_in)
#------------------------------------------------------------------------------#

define lr_par_in    record                         
       srrcoddig    like datksrr.srrcoddig
end    record 

define lr_auxiliar  record                         
       dominio      char(20)
     , srrblqmtv    like datmsrratmblqpgm.blqmtvcod
end    record

define lr_retorno   record                         
       motivo       char(14)
end    record

if m_prepare is null or m_prepare <> true then
   call cty38g00_prepare()
end if
   
initialize lr_auxiliar.*, lr_retorno.* to null

let lr_auxiliar.dominio = "blqmtvcod" 

open ccty38g00001 using lr_par_in.srrcoddig 
whenever error continue
fetch ccty38g00001
whenever error stop

if sqlca.sqlcode = 0 then

   open ccty38g00002 using lr_par_in.srrcoddig 
   whenever error continue
   fetch ccty38g00002 into lr_auxiliar.srrblqmtv
   whenever error stop

   if sqlca.sqlcode = 0 then

      open ccty38g00003 using lr_auxiliar.dominio
			    , lr_auxiliar.srrblqmtv
      whenever error continue
      fetch ccty38g00003 into lr_retorno.motivo
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let lr_retorno.motivo = "MTV.BLQ.INVAL."
      end if
   end if
end if

return lr_retorno.*

end function

#------------------------------------------------------------------------------#
function cty38g00_popup_datkdominio(param)
#------------------------------------------------------------------------------#

define param      record
       cabec      char(40) 
     , cponom     like datkdominio.cponom
end    record

define a_cty38g00 array[50] of record
       cpodes     like datkdominio.cpodes
     , cpocod     like datkdominio.cpocod
end    record

define l_cpocod   like datkdominio.cpocod

define arr_aux    smallint
define l_sql      char(200)
define w_pf1	  integer

if m_prepare is null or m_prepare <> true then
   call cty38g00_prepare()
end if

for w_pf1 = 1 to 50
    initialize a_cty38g00[w_pf1].* to null
end for

initialize arr_aux, l_sql, w_pf1, arr_aux, a_cty38g00 to null 

let int_flag = false
let arr_aux  = 1

open    ccty38g00004 using param.cponom
foreach ccty38g00004 into a_cty38g00[arr_aux].cpodes
                        , a_cty38g00[arr_aux].cpocod
    let arr_aux = arr_aux + 1
    if arr_aux > 50  then
       error " Limite excedido. Existem mais de 50 registros cadastrados!"
       exit foreach
    end if
end foreach

if arr_aux > 1  then
   open window cty38g00 at 10,20 with form "cty37g00"
        attribute(form line 1, border)

   display by name param.cabec
   message " (F17)Abandona, (F8)Seleciona"
   call set_count(arr_aux-1)

   display array a_cty38g00 to s_cty38g00.*

       on key (interrupt,control-c)
          initialize a_cty38g00 to null
          initialize l_cpocod   to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let l_cpocod = a_cty38g00[arr_aux].cpocod
          exit display

    end display

    let int_flag = false
    close window cty38g00
else
    initialize l_cpocod to null
    error " Nao existem registros cadastrados!"
end if

return l_cpocod

end function 

#------------------------------------------------------------------------------#
function cty38g00_datkdominio(lr_param)
#------------------------------------------------------------------------------#

define lr_param   record
       cponom     like datkdominio.cponom
     , cpocod     like datkdominio.cpocod
end    record

define lr_retorno record
       erro       smallint
     , mensagem   char(100)
     , cpodes     like datkdominio.cpodes
end    record

if m_prepare is null or m_prepare <> true then
   call cty38g00_prepare()
end if

initialize lr_retorno to null

open ccty38g00003 using lr_param.cponom
                       ,lr_param.cpocod
whenever error continue
fetch ccty38g00003 into lr_retorno.cpodes
whenever error stop

if sqlca.sqlcode <> 0 then
   if sqlca.sqlcode = notfound then
      let lr_retorno.erro = 2
      let lr_retorno.mensagem = 'Dominio nao encontrado '
   else
      let lr_retorno.erro = 3
      let lr_retorno.mensagem = 'Erro ccty38g00003 : ', sqlca.sqlcode
   end if
else
   let lr_retorno.erro = 1
end if

close ccty38g00003

return lr_retorno.*

end function

#------------------------------------------------------------------------------#
function cty38g00_tempo(l_inicio,l_final)
#------------------------------------------------------------------------------#

define l_inicio datetime year to minute
define l_final  datetime year to minute

define l_data_inicial date
define l_data_final   date
define l_dias         smallint

define l_hora_inicial datetime hour to minute 
define l_hora_final   datetime hour to minute 
define l_horas        datetime hour to minute
define l_hora         smallint
define l_minuto       smallint

define l_diff         interval hour to minute
define l_diff1        datetime hour to minute
define l_diff2        char(6) 

define l_retorno      char(50)

let l_data_inicial = l_inicio
let l_data_final   = l_final
let l_hora_inicial = l_inicio
let l_hora_final   = l_final

let l_diff   = "00:00"
let l_horas  = "00:00"
let l_hora   = 0 
let l_minuto = 0 

if l_data_final = "31/12/9999" then
   let l_retorno = "Bloqueio por prazo indeterminado"
   return l_retorno
end if 

let l_dias = l_data_final - l_data_inicial

if l_dias > 0 then
   if l_hora_final < l_hora_inicial then
      let l_dias   = l_dias - 1
      let l_diff1  = "23:00"
      let l_diff   = l_diff1 - l_hora_inicial + 1 units hour
      let l_diff2  = l_diff
      let l_hora   = l_diff2[2,3]
      let l_minuto = l_diff2[5,6]
      let l_horas  = l_hora_final + l_hora units hour + l_minuto units minute
      let l_diff2  = l_horas
   else
      let l_diff   = l_hora_final - l_hora_inicial
      let l_diff2  = l_diff
      let l_horas  = l_diff2
   end if 
else
   let l_diff   = l_hora_final - l_hora_inicial
   let l_diff2  = l_diff
   let l_horas  = l_diff2
end if 

let l_retorno = " "

if l_dias > 0 then 
   let l_retorno = l_dias using "<<<<<&"," dia(s)" 
end if

if l_diff2[2,3] is not null and l_diff2[2,3] <> "00" and l_diff2[2,3] <> " 0" then 
   if l_retorno is not null and l_retorno <> " " then
      let l_retorno = l_retorno clipped, ","
   end if
   let l_retorno = l_retorno clipped, l_diff2[2,3], " hora(s)"
end if 

if l_diff2[5,6] is not null and l_diff2[5,6] <> "00" then 
   if l_retorno is not null and l_retorno <> " " then
      let l_retorno = l_retorno clipped, ","
   end if
   let l_retorno = l_retorno clipped, l_diff2[5,6], " minuto(s)"
end if 

return l_retorno

end function

#------------------------------------------------------------------------------#
function cty38g00_grava_hist(lr_param,l_titulo,l_operacao)
#------------------------------------------------------------------------------#
# Esta funcao foi replicada do modulo ctc44m00 porque o mesmo ja possuia um "main"

   define lr_param record
          srrcoddig  like datksrr.srrcoddig
         ,mensagem   char(3000)
         ,data       date
          end record

   define lr_retorno record
                     stt smallint
                    ,msg char(50)
          end record

   define l_titulo      char(100)
         ,l_stt         smallint
         ,l_path        char(100)
         ,l_operacao    char(1)
         ,l_fimtxt      char(15)
	 ,l_cmd         char(200)
	 ,l_erro        smallint
         ,l_prshstdes2  char(3000)
	 ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint

   let l_stt  = true
   let l_path = null

   initialize lr_retorno to null

   let l_length = length(lr_param.mensagem clipped)
   if  l_length mod 70 = 0 then
       let l_iter = l_length / 70
   else
       let l_iter = l_length / 70 + 1
   end if

   let l_length2     = 0
   let l_erro        = 0

   for l_count = 1 to l_iter
       if  l_count = l_iter then
           let l_prshstdes2 = lr_param.mensagem[l_length2 + 1, l_length]
       else
           let l_length2 = l_length2 + 70
           let l_prshstdes2 = lr_param.mensagem[l_length2 - 69, l_length2]
       end if

       if  ctd40g00_permissao_atl(g_issk.funmat) then
          display '--- Parametros para Gravacao do Historico ---'
          display 'lr_param.srrcoddig:',lr_param.srrcoddig
          display 'l_prshstdes2      :',l_prshstdes2   clipped
          display 'lr_param.data     :',lr_param.data
          display 'g_issk.empcod     :',g_issk.empcod
          display 'g_issk.funmat     :',g_issk.funmat
       end if

       call ctd18g01_grava_hist(lr_param.srrcoddig
                               ,l_prshstdes2
                               ,lr_param.data
                               ,g_issk.empcod
                               ,g_issk.funmat
                               ,'F')
            returning lr_retorno.stt
                     ,lr_retorno.msg
        if  ctd40g00_permissao_atl(g_issk.funmat) then
           display '--- Retorno da Gravacao do Historico ---'
           display 'lr_retorno.stt:',lr_retorno.stt
           display 'lr_retorno.msg:',lr_retorno.msg clipped
        end if

  end for

   if l_operacao = "I" then
      if lr_retorno.stt  = 1 then

         call ctb85g01_mtcorpo_email_html('CTC44M00',
	                            lr_param.data,
                                     current hour to minute,
	   		             g_issk.empcod,
                                     g_issk.usrtip,
                                     g_issk.funmat,
				     l_titulo,
	   		             lr_param.mensagem)
                 returning l_erro

      else
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
      end if
     else
      if lr_retorno.stt <> 1 then
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
       end if
   end if

   return l_stt

end function

#------------------------------------------------------------------------------#
