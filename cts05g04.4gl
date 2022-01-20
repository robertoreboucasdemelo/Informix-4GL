#############################################################################
# Nome do Modulo: CTS05G04                                         Ruiz     #
# Monta cabecalho padrao dos laudos de servico para PROPOSTA       Jun/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        RESPONSAVEL      SOLICITACAO DESCRICAO                        #
#                                                                           #
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

# globals "/homedsa/projetos/ct24h/producao/glct.4gl" RGLOBALS By Robi
#globals  "glct.4gl"

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

define m_hostname   char(12)
define m_server     like ibpkdbspace.srvnom #Saymon ambnovo

#----------------------------------------------------------------------------
 function cts05g04(param)
#----------------------------------------------------------------------------

 define param        record
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig
 end record

 define d_cts05g04   record
    segnom           like gsakseg.segnom       ,
    corsus           like datmservico.corsus   ,
    cornom           like datmservico.cornom   ,
    cvnnom           char (20)                 ,
    vclcoddig        like datmservico.vclcoddig,
    vcldes           like datmservico.vcldes   ,
    vclanomdl        like datmservico.vclanomdl,
    vcllicnum        like datmservico.vcllicnum,
    vclcordes        char (12)
 end record

 define ws           record
    prporgidv        like apbmitem.prporgidv,
    prpnumidv        like apbmitem.prpnumidv,
    segnumdig        like gsakseg.segnumdig,
    vclcorcod        like datmservico.vclcorcod
 end record
 define l_cmd  char(100)
 define l_host like ibpkdbspace.srvnom #Saymon ambnovo
 define l_sql  char(500) #Saymon ambnovo


	initialize  d_cts05g04.*  to  null

	initialize  ws.*  to  null

 initialize d_cts05g04.*  to null
 initialize ws.*          to null
 let l_cmd = null

#---------------------------------------------------------------
# Nome do convenio
#---------------------------------------------------------------

 select cpodes
   into d_cts05g04.cvnnom
   from datkdominio
  where cponom = "ligcvntip"     and
        cpocod = g_documento.ligcvntip

 if param.prpnumdig is null then
    return d_cts05g04.*
 end if

 call figrc072_setTratarIsolamento()        --> 223689
 call cts18m08 (param.prporg, param.prpnumdig)
      returning ws.prporgidv, ws.prpnumidv

 if g_isoAuto.sqlCodErr <> 0 then --> 223689
    error "Problemas na função cts18m08 ! Avise a Informatica !" sleep 2
    return d_cts05g04.*
 end if    --> 223689


call figrc072_initGlbIsolamento() --> 223689

if ws.prporgidv is null  or
   ws.prpnumidv is null  then
   return d_cts05g04.*
else
     #------------Saymon---------------------#
     # Carrega host do banco de dados        #
     #---------------------------------------#
      if param.prporg  = 15  then
         let l_host = fun_dba_servidor("ORCAMAUTO")
      else
         let l_host = fun_dba_servidor("EMISAUTO")
      end if
      let l_sql  = 'select segnumdig      '
                  ,'  from porto@',l_host clipped,':apbmitem'
                  ,' where prporgpcp =  ? '
                  ,'   and prpnumpcp =  ? '
                  ,'   and prporgidv =  ? '
                  ,'   and prpnumidv =  ? '

      prepare p_cts05g04_01 from l_sql
      declare c_cts05g04_01 cursor with hold for p_cts05g04_01
      if figrc072_checkGlbIsolamento(sqlca.sqlcode,
                       "cts05g04"   ,
                       "cts05g04"   ,
                       ""           ,
                       "","","","","","")  then
        return d_cts05g04.*
      end if  --> 223689


      open c_cts05g04_01 using param.prporg
                              ,param.prpnumdig
                              ,ws.prporgidv
                              ,ws.prpnumidv
      whenever error continue
      fetch c_cts05g04_01   into ws.segnumdig
      whenever error stop
end if
#--------------------------------------------------------------------
# Dados do veiculo da proposta
#--------------------------------------------------------------------

       select vclcoddig,
              vcllicnum,
              vclanomdl
         into d_cts05g04.vclcoddig,
              d_cts05g04.vcllicnum,
              d_cts05g04.vclanomdl
         from apbmveic
        where prporgpcp = param.prporg      and
              prpnumpcp = param.prpnumdig   and
              prporgidv = ws.prporgidv      and
              prpnumidv = ws.prpnumidv

#--------------------------------------------------------------------
# Dados do corretor da proposta
#--------------------------------------------------------------------

       --> 223689
       let m_server   = fun_dba_servidor("EMISAUTO")
       let m_hostname = "porto@", m_server clipped , ":"

       let l_cmd = "select corsus ",
                   "from ",m_hostname clipped,"apamcor ",#ambnovo
                   "where prporgpcp = ?  and ",
                   "prpnumpcp = ?  and ",
                   "corlidflg = 'S' "
       prepare pcts05g04001  from l_cmd
       declare ccts05g04001  cursor for pcts05g04001
      open ccts05g04001 using param.prporg,param.prpnumdig
      whenever error continue
        fetch ccts05g04001 into d_cts05g04.corsus
      whenever error stop

#-----------------------------------------------------------------
# Dados do Segurado
#-----------------------------------------------------------------

 let d_cts05g04.segnom =  "*** NAO CADASTRADO! ***"
 select segnom
   into d_cts05g04.segnom
   from gsakseg
  where segnumdig = ws.segnumdig

#--------------------------------------------------------------------
# Dados do corretor
#--------------------------------------------------------------------

 select gcakcorr.cornom
   into d_cts05g04.cornom
   from gcaksusep, gcakcorr
  where gcaksusep.corsus     = d_cts05g04.corsus    and
        gcakcorr.corsuspcp   = gcaksusep.corsuspcp

#---------------------------------------------------------------
# Dados do veiculo
#---------------------------------------------------------------
 if d_cts05g04.vclcoddig is not null  then
    call cts15g00(d_cts05g04.vclcoddig)
        returning d_cts05g04.vcldes
 end if

#---------------------------------------------------------------
# Cor do veiculo
#---------------------------------------------------------------

#if ws.vclcorcod is not null  then
#   select cpodes
#     into d_cts05g04.vclcordes
#     from iddkdominio
#    where cponom = "vclcorcod"  and
#          cpocod = ws.vclcorcod
#end if

 return d_cts05g04.*

end function  ###  cts05g04
