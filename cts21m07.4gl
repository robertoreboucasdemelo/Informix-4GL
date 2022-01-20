###########################################################################  #
# Menu de Modulo: CTS21M07                                        Marcelo    #
#                                                                 Gilberto   #
# Envio de laudos de vistoria de sinistro de R.E. via SMS         Jun/1997   #
###########################################################################  #
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#--------------------------------------------------------------------------  #
# 27/04/1999  PSI 7915-4   Gilberto     Substituir porcao do codigo onde e'  #
#                                       realizada a gravacao das tabelas     #
#                                       por funcao de interface Teletrim.    #
#--------------------------------------------------------------------------  #
# 25/10/1999  PSI 9118-9   Gilberto     Alterar acesso as tabelas de liga-   #
#                                       coes, com a utilizacao de funcoes.   #
#--------------------------------------------------------------------------  #
# 04/06/2001  PSI 13228-4  Ruiz         Alterar lay-out da msg enviada aos   #
#                                       reguladores.                         #
#--------------------------------------------------------------------------  #
# 13/06/2001  Correio      Ruiz         Incluir hora do sinistro na msg.     #
#--------------------------------------------------------------------------  #
# 19/12/2001  PSI 130257   Ruiz         Alteracao no acionamento dos         #
#                                       reguladores.                         #
#----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                #
#----------------------------------------------------------------------------#
# 19/06/2006  Priscila Staingel   PSI 200140  Laudo permite que escolha mais #
#                                             de uma cobertura/natureza      #
##############################################################################
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# ---------- ------------- --------- ----------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087  Migracao para a versao 7.32             #
#--------------------------------------------------------------------------- #
# 05/01/2010  Amilton                   Projeto sucursal smallint            #
#----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function cts21m07(param)
#---------------------------------------------------------------

 define param      record
    sinvstnum      like datmpedvist.sinvstnum,
    sinvstano      like datmpedvist.sinvstano,
    sinpricod      like datmpedvist.sinpricod,
    antpricod      like datmpedvist.sinpricod,
    dtplantao      char (10)                 ,
    motivo         char (50)                 ,
    data           like sgkmpdoperplt.atldat ,
    hora           like sgkmpdoperplt.atlhor ,
    ddd_sms        char(04)                  , ## Anatel
    tel_sms        char(10)                    ## Anatel
 end record

 define d_cts21m07 record
    sinpricod      like sgkmpdoperplt.sinpricod   ,
    ustcod         like htlrust.ustcod            ,
    pgrctl         like htlrust.pgrctl            ,
    tel_comp_sms   char(14)                       , ## Anatel char(10)  ,
    ustsit         like htlrust.ustsit
 end record

 define ws         record
    saiflg         smallint        ,
    pltdat         date            ,
    msgtxt         char (143)      ,
    errcod         smallint        ,
    sqlcod         integer         ,
    confirma       char (01)       ,
    prompt_key     char (01)       ,
    msg            char (300)      ,
    msg1           char (600)      ,
    email          char (1000)
 end record

 define w_run      char(500)

 define l_mens     char(300)

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

	let     l_mens = null
  initialize  d_cts21m07.*  to  null
  initialize  ws.*  to  null

 initialize d_cts21m07.* to null
 initialize ws.*         to null
 initialize w_run        to null

 if time > "17:30"  and  time <= "23:59"  then
    let ws.pltdat = today
 else
    let ws.pltdat = today - 1 units day
 end if

#---------------------------------------------------------------
# Monta a mensagem para transmissao
#---------------------------------------------------------------

 error " Aguarde, acionando regulador via SMS..."

 whenever error continue

 call cts21m07_msg(param.sinvstnum, param.sinvstano)
      returning ws.msgtxt

#---------------------------------------------------------------
# Seleciona o regulador de plantao a ser acionado
#---------------------------------------------------------------


 if param.antpricod is not null  then   # laudo - cts21m03
    call fsrea200_seleciona_regulador(param.dtplantao,
                                      param.sinpricod)
                            returning d_cts21m07.sinpricod,
                                      d_cts21m07.tel_comp_sms

    let param.ddd_sms = d_cts21m07.tel_comp_sms[1,4]  ## Anatel -- [1,2]
    let param.tel_sms = d_cts21m07.tel_comp_sms[5,14] ## Anatel -- [3,10]
 else
    let d_cts21m07.sinpricod = param.sinpricod
 end if

  #---------------------------------------------------------------
  # Atualiza tabela de acionamentos de reguladores de plantao
  #---------------------------------------------------------------

  begin work

  if param.antpricod is null  then

     call fsrea200_Atualiza_Plantao(param.dtplantao,
                                    d_cts21m07.sinpricod,
                                    param.sinvstnum,
                                    param.sinvstano)
             returning ws.errcod

     if ws.errcod = 1  then
        error "Erro na fsrea200_atualiza_plantao, ",
              "acionamento do regulador. AVISE A INFORMATICA!"
        prompt "" for char ws.prompt_key
          let l_mens = "Erro na fsrea200_atualiza_plantao, acionamento do regulador. AVISE A INFORMATICA!"
          call errorlog(l_mens)
        rollback work

        return false
     end if
     #---------------------------------------------------------------
     # Grava codigo do regulador acionado para vistoria de R.E.
     #---------------------------------------------------------------
     update datmpedvist set
            sinpricod = d_cts21m07.sinpricod
      where sinvstnum = param.sinvstnum  and
            sinvstano = param.sinvstano

     if sqlca.sqlcode <> 0  then
        error "Erro (", sqlca.sqlcode, ") na gravacao do regulador ",
              "acionado. AVISE A INFORMATICA!"
        prompt "" for char ws.prompt_key
        rollback work

        return false
     end if
  else
     if param.sinpricod <> param.antpricod then  # alterando regulador
        call fsrea200_altera_regulador(param.dtplantao,
                                       param.antpricod,  # regulador antigo
                                       param.sinpricod,  # regulador novo
                                       param.sinvstnum,
                                       param.sinvstano,
                                       param.motivo)
             returning ws.errcod
        if ws.errcod = 1  then
           error "Erro na fsrea200_altera_plantao, ",
                 "acionamento do regulador. AVISE A INFORMATICA!"

           prompt "" for char ws.prompt_key
           rollback work
           return false
        end if
        #---------------------------------------------------------------
        # Grava codigo do regulador acionado para vistoria de R.E.
        #---------------------------------------------------------------
        update datmpedvist set
               sinpricod = d_cts21m07.sinpricod
         where sinvstnum = param.sinvstnum  and
               sinvstano = param.sinvstano

        if sqlca.sqlcode <> 0  then
           error "Erro (", sqlca.sqlcode, ") na gravacao do regulador ",
                 "acionado. AVISE A INFORMATICA!"

           prompt "" for char ws.prompt_key
           rollback work
           return false
        end if
     end if
  end if


  #---------------------------------------------------------------
  # Envia Dados por SMS
  #---------------------------------------------------------------
   { --- robson ---} #alterar essa função para receber o novo telefone
   call figrc007_sms_send1(param.ddd_sms      # ddd
                          ,param.tel_sms      # celular comum
                          ,ws.msgtxt          # primeira sms
                          ,"SinRECli"         # remetente
                          ,9                  # prioridade alta
                          ,172800)            # expiracao 48H
   returning ws.errcod
            ,ws.msg


   if ws.errcod <> 0 then

       call cts08g01("A","N","","NAO FOI POSSIVEL ACIONAR NENHUM",
                     "REGULADOR DE PLANTAO VIA SMS!","") returning ws.confirma
       rollback work
       return false

   else
       commit work

       whenever error stop
       error " Acionamento efetuado!"
       return true
   end if



end function  ###  cts21m07

#--------------------------------------------------------------
 function cts21m07_msg(param)
#--------------------------------------------------------------

 define param   record
    sinvstnum   like datmpedvist.sinvstnum,
    sinvstano   like datmpedvist.sinvstano
 end record

 define ws       record
    succod       like datrligapol.succod    ,
    ramcod       like datrligapol.ramcod    ,
    aplnumdig    like datrligapol.aplnumdig ,
    segnom       char(20)                   ,
    lclendflg    like datmpedvist.lclendflg ,
    lclrsccod    like datmpedvist.lclrsccod ,
    lgdtip       like datmpedvist.lgdtip    ,
    lgdnom       like datmpedvist.lgdnom    ,
    lgdnum       like datmpedvist.lgdnum    ,
    lgdnomcmp    like datmpedvist.lgdnomcmp ,
    endbrr       char(15)                   ,
    endcid       like datmpedvist.endcid    ,
    endufd       like datmpedvist.endufd    ,
    endddd       like datmpedvist.endddd    ,  ## Anatel -- char(02)                   ,
    teldes       like datmpedvist.teldes    ,  ## Anatel
    lclcttnom    like datmpedvist.lclcttnom ,
    sinntzcod    like datmpedvist.sinntzcod ,
    sinntzdes    like sgaknatur.sinntzdes   ,
    sindat       like datmpedvist.sindat    ,
    sinhor       like datmpedvist.sinhor    ,
    orcvlr       like datmpedvist.orcvlr    ,
    sinobs       char(80)                   ,
    sinhst       like datmpedvist.sinhst    ,
    lignum       like datmligacao.lignum
 end record

 #PSI 200140
 define am_cts21m07  array[50] of record
        cbttip     like datrpedvistnatcob.cbttip,   #codigo da cobertura
        cbttipnom  like rgpktipcob.cbttipnom,       #descricao da cobertura
        sinntzcod  like datrpedvistnatcob.sinntzcod,#codigo da natureza
        sinntzdes  like sgaknatur.sinntzdes,        #descricao da natureza
        orcvlr     like datrpedvistnatcob.orcvlr    #valor
 end record

 define l_count   smallint
 define l_aux     smallint

 define msgtxt   char (143)


	let	msgtxt  =  null

	initialize  ws.*  to  null

 initialize ws.*    to null
 initialize am_cts21m07 to null
 initialize msgtxt  to null

 let l_count = 1

 select datmpedvist.segnom   , datmpedvist.lclendflg,
        datmpedvist.lclrsccod, datmpedvist.lgdtip   ,
        datmpedvist.lgdnom   , datmpedvist.lgdnum   ,
        datmpedvist.lgdnomcmp, datmpedvist.endbrr   ,
        datmpedvist.endcid   , datmpedvist.endufd   ,
        datmpedvist.endddd   , datmpedvist.teldes   ,
        datmpedvist.lclcttnom, datmpedvist.sinntzcod,
        datmpedvist.sindat   , datmpedvist.sinhor   ,
        datmpedvist.orcvlr   , datmpedvist.sinobs   ,
        datmpedvist.sinhst
   into ws.segnom   , ws.lclendflg,
        ws.lclrsccod, ws.lgdtip   ,
        ws.lgdnom   , ws.lgdnum   ,
        ws.lgdnomcmp, ws.endbrr   ,
        ws.endcid   , ws.endufd   ,
        ws.endddd   , ws.teldes   ,
        ws.lclcttnom, ws.sinntzcod,
        ws.sindat   , ws.sinhor   ,
        ws.orcvlr   , ws.sinobs   ,
        ws.sinhst
   from datmpedvist
  where datmpedvist.sinvstnum = param.sinvstnum
    and datmpedvist.sinvstano = param.sinvstano

 if sqlca.sqlcode = notfound  then
    return msgtxt
 end if

  let ws.lignum = cts20g00_sinvst(param.sinvstnum, param.sinvstano, 2)

 if ws.lignum is not null  then
    select datrligapol.succod   ,
           datrligapol.ramcod   ,
           datrligapol.aplnumdig
      into ws.succod   ,
           ws.ramcod   ,
           ws.aplnumdig
      from datrligapol
     where lignum = ws.lignum
 end if

 if ws.lclendflg = "S"  then
    select endlgdtip, endlgdnom,
           endnum   , endcmp   ,
           endbrr   , endcid   ,
           ufdcod
      into ws.lgdtip    ,
           ws.lgdnom    ,
           ws.lgdnum    ,
           ws.lgdnomcmp ,
           ws.endbrr    ,
           ws.endcid    ,
           ws.endufd
      from rlaklocal
     where lclrsccod = ws.lclrsccod
 end if

 let ws.sinntzdes = "*** NAO CADASTRADO ***"

 select sinntzdes into ws.sinntzdes
   from sgaknatur
  where sinramgrp = "4"  and
        sinntzcod = ws.sinntzcod

 #PSI 200140
 #Buscar cobertura/natureza/valor da tabela datrpedvistnatcob
 declare ccts21m07001 cursor for
 select cbttip, sinntzcod, orcvlr
  from datrpedvistnatcob
  where sinvstnum = param.sinvstnum
    and sinvstano = param.sinvstano

 foreach ccts21m07001 into am_cts21m07[l_count].cbttip,
                           am_cts21m07[l_count].sinntzcod,
                           am_cts21m07[l_count].orcvlr
          #buscar descricao cobertura
          call fsrec780_retornar_descricao(am_cts21m07[l_count].cbttip,
                                           "cobertura" )
               returning am_cts21m07[l_count].cbttipnom

          #buscar descricao natureza
          call fsrec780_retornar_descricao(am_cts21m07[l_count].sinntzcod,
                                           "natureza" )
               returning am_cts21m07[l_count].sinntzdes
          let l_count = l_count + 1
 end foreach


 #Montagem da mensagem

 let msgtxt =param.sinvstnum using "&&&&##" clipped, "\n",                     # numero vistoria
             ws.segnom clipped, "\n",                                          # segurado
             ws.endbrr clipped, "\n",                                          # bairro
             ws.endufd clipped, "\n",                                          # uf
             ws.endddd using "&&&&", ws.teldes using "#########", "\n",        # telefone   # Anatel
             ws.sindat, "\n",                                                  # data do sinistro
             ws.sinhst clipped                                                 # Historico
             #ws.sinobs clipped                                                # observacao



 return msgtxt

end function # cts21m07_msg
