#------------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                              #
# ...........................................................................  #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                            #
# MODULO.........: BDBSA701                                                    #
# ANALISTA RESP..: BEATRIZ ARAUJO                                              #
# PSI/OSF........: PSI-2014-21950/PR                                           #
# DESCRICAO......: BLOQUEIO E DESBLOQUEIO AUTOMATICO DE SOCORRISTAS CONFORME   #
#                  PROGRAMACAO CADASTRADA.                                     #
# ...........................................................................  #
# DESENVOLVIMENTO: FORNAX TECNOLOGIA (RCP)                                     #
# LIBERACAO......: 01/10/2014                                                  #
# ...........................................................................  #
#                                                                              #
#                           * * * ALTERACOES * * *                             #
#                                                                              #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                              #
# --------   --------------  ---------- -------------------------------------  #
#                                                                              #
#------------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_current datetime year to fraction

main

   initialize m_current to null

   call cts40g03_exibe_info("I", "BDBSA701")

   call bdbsa701_prepare()

   let m_current = current
   display ""
   display "BDBSA701 - Inicio do BLOQUEIO automatico :", m_current

   call bdbsa701_bloqueio()

   let m_current = current
   display ""
   display "BDBSA701 - Final do BLOQUEIO automatico :", m_current

   let m_current = current
   display ""
   display "BDBSA701 - Inicio do DESBLOQUEIO automatico :", m_current

   call bdbsa701_desbloqueio()

   let m_current = current
   display ""
   display "BDBSA701 - Final do DESBLOQUEIO automatico :", m_current
   display ""

   call cts40g03_exibe_info("F", "BDBSA701")

end main

#------------------------------------------------------------------------------#
function bdbsa701_prepare()                        
#------------------------------------------------------------------------------#
                                                    
define l_sql char(500)                            
                                                    
#--> Bloqueios agendados que ainda nao foram efetivados

let l_sql = "select * "
          , "  from datmsrratmblqpgm "
          , " where blqpgmsitcod = 1 "
          , "   and blqincdat   <= ? "
          , " order by blqincdat, srrdigcod "
prepare pbdbsa701001 from l_sql                  
declare cbdbsa701001 cursor with hold for pbdbsa701001 

#--> Bloqueios efetivados que ainda nao foram finalizados

let l_sql = "select * "
          , "  from datmsrratmblqpgm "
          , " where blqpgmsitcod = 2 "
          , "   and blqfnldat   <= ? "
          , " order by blqfnldat, srrdigcod "
prepare pbdbsa701002 from l_sql                  
declare cbdbsa701002 cursor with hold for pbdbsa701002 

end function 

#------------------------------------------------------------------------------#
function bdbsa701_bloqueio()
#------------------------------------------------------------------------------#

define lr_datmsrratmblqpgm record like datmsrratmblqpgm.* 

define lr_retorno record                         
       status     smallint
     , mensagem   char(80)
end    record

initialize lr_datmsrratmblqpgm.*, lr_retorno.* to null

let m_current = current 

open cbdbsa701001 using m_current

foreach cbdbsa701001 into lr_datmsrratmblqpgm.*

   begin work

   display ""
   display "---------------------------------------------------------------------------"
   display ""
   display " Bloqueio automatico do socorrista : ", lr_datmsrratmblqpgm.srrdigcod
   display ""

   call cty38g00_atualiza_bloq_progr (lr_datmsrratmblqpgm.srrdigcod
                                     ,2  #--> Bloquear socorrista
                                     ,lr_datmsrratmblqpgm.blqpgmseqnum
                                     ,2  #--> Efetivar programacao agendada
                                     ,lr_datmsrratmblqpgm.blqmtvcod
                                     ,lr_datmsrratmblqpgm.blqincdat
                                     ,lr_datmsrratmblqpgm.blqfnldat
                                     ,m_current)
        returning lr_retorno.status
		, lr_retorno.mensagem

   if lr_retorno.status = 0 then
      display ""
      display "Bloqueio efetivado com sucesso" 
	    , "|Mensagem:",        lr_retorno.mensagem clipped
	    , "|Socorrista:",      lr_datmsrratmblqpgm.srrdigcod    using "<<<<<<<&"
	    , "|Seq.bloqueio:",    lr_datmsrratmblqpgm.blqpgmseqnum using "<<<<<<<&"
	    , "|Inicio bloqueio:", lr_datmsrratmblqpgm.blqincdat
      commit work
   else
      display ""
      display "Bloqueio nao efetivado" 
	    , "|Mensagem:",        lr_retorno.mensagem clipped
	    , "|Socorrista:",      lr_datmsrratmblqpgm.srrdigcod    using "<<<<<<<&"
	    , "|Seq.bloqueio:",    lr_datmsrratmblqpgm.blqpgmseqnum using "<<<<<<<&"
	    , "|Inicio bloqueio:", lr_datmsrratmblqpgm.blqincdat
      rollback work
   end if 

end foreach 

end function

#------------------------------------------------------------------------------#
function bdbsa701_desbloqueio()
#------------------------------------------------------------------------------#

define lr_datmsrratmblqpgm record like datmsrratmblqpgm.* 

define lr_retorno record                         
       status     smallint
     , mensagem   char(80)
end    record

initialize lr_datmsrratmblqpgm.*, lr_retorno.* to null

let m_current = current 

open cbdbsa701002 using m_current

foreach cbdbsa701002 into lr_datmsrratmblqpgm.*

   begin work

   display ""
   display "---------------------------------------------------------------------------"
   display ""
   display " Bloqueio automatico do socorrista : ", lr_datmsrratmblqpgm.srrdigcod
   display ""

   call cty38g00_atualiza_bloq_progr (lr_datmsrratmblqpgm.srrdigcod
                                     ,1  #--> Desbloquear o socorrista
                                     ,lr_datmsrratmblqpgm.blqpgmseqnum
                                     ,3  #--> Finalizar programacao efetivada
                                     ,lr_datmsrratmblqpgm.blqmtvcod
                                     ,lr_datmsrratmblqpgm.blqincdat
                                     ,lr_datmsrratmblqpgm.blqfnldat
                                     ,m_current)
        returning lr_retorno.status
		, lr_retorno.mensagem

   if lr_retorno.status = 0 then
      display ""
      display "Bloqueio finalizado com sucesso" 
	    , "|Mensagem:",       lr_retorno.mensagem clipped
	    , "|Socorrista:",     lr_datmsrratmblqpgm.srrdigcod    using "<<<<<<<&"
	    , "|Seq.bloqueio:",   lr_datmsrratmblqpgm.blqpgmseqnum using "<<<<<<<&"
	    , "|Final bloqueio:", lr_datmsrratmblqpgm.blqfnldat
      commit work
   else
      display ""
      display "Bloqueio nao finalizado" 
	    , "|Mensagem:",       lr_retorno.mensagem clipped
	    , "|Socorrista:",     lr_datmsrratmblqpgm.srrdigcod    using "<<<<<<<&"
	    , "|Seq.bloqueio:",   lr_datmsrratmblqpgm.blqpgmseqnum using "<<<<<<<&"
	    , "|Final bloqueio:", lr_datmsrratmblqpgm.blqfnldat
      rollback work
   end if 

end foreach 

end function

#------------------------------------------------------------------------------#
