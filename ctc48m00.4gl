###########################################################################
# Nome do Modulo: ctc48m00                                           RAJI #
#                                                                         #
# Cadastro de codigos de problemas                               Nov/2000 #
###########################################################################
# Alteracoes:                                                             #
#                                                                         #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                         #
#-------------------------------------------------------------------------#
# 17/08/2008  PSI 221635   Fabio Costa  Adicionar descricao WEB           #
# 28/09/2009  PSI 246174   Fabio Costa  Adicionar código do assunto e flag#
#                                       remoção requerida                 #
#-------------------------------------------------------------------------#
# 02/10/2009  PSI 246174   Beatriz      Adicionar descricao Smart         #
#                           Araujo                                        #
###########################################################################
database porto

globals "/homedsa/projetos/geral/globals/glcte.4gl"

#------------------------------------------------------------
 function ctc48m00()
#------------------------------------------------------------

 define param         record
    c24pbmcod         like datkpbm.c24pbmcod
 end record

 define ctc48m00      record
    c24pbmcod         like datkpbm.c24pbmcod,
    c24pbmdes         like datkpbm.c24pbmdes,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    c24pbmstt         like datkpbm.c24pbmdes,
    c24pbmsttdes      char(15),
    caddat            like datkpbm.caddat,
    cadmat            like datkpbm.cadmat,
    cademp            like datkpbm.cademp,
    cadusrtip         like datkpbm.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbm.atldat,
    atlmat            like datkpbm.atlmat,
    atlemp            like datkpbm.atlemp,
    atlusrtip         like datkpbm.atlusrtip,
    funnom            like isskfunc.funnom,
    sphpbmdes         like datkpbm.sphpbmdes,
    webpbmdes         like datkpbm.webpbmdes,
    c24astcod         like datkpbm.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    remrquflg         like datkpbm.remrquflg
 end record

 #if not get_niv_mod(g_issk.prgsgl, "ctc48m00") then
 #   error "Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 let int_flag = false

 initialize ctc48m00.*  to null
 initialize param.*  to null

 open window ctc48m00 at 04,02 with form "ctc48m00"


 menu "PROBLEMAS"

  before menu
          hide option all
          show option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica" , "Inclui","assunTos"
          end if
          show option "Encerra"

  command key ("S") "Seleciona"
                   "Pesquisa problema conforme criterios"
          call ctc48m00_seleciona()  returning param.*
          if param.c24pbmcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum problema selecionado!"
             message ""
             next option "Seleciona"
          end if

  command key ("P") "Proximo"
                   "Mostra proximo problema selecionado"
          message ""
          call ctc48m00_proximo(param.*)
               returning param.*

  command key ("A") "Anterior"
                   "Mostra problema anterior selecionado"
          message ""
          if param.c24pbmcod    is not null then
             call ctc48m00_anterior(param.c24pbmcod   )
                  returning param.*
          else
             error " Nenhum problema nesta direcao!"
             next option "Seleciona"
          end if

  command key ("M") "Modifica"
                   "Modifica problema corrente selecionado"
          message ""
          if param.c24pbmcod     is not null then
             call ctc48m00_modifica(param.*)
                  returning param.*
             next option "Seleciona"
          else
             error " Nenhum problema selecionado!"
             next option "Seleciona"
          end if

  command key ("I") "Inclui"
                   "Inclui problema"
          message ""
          call ctc48m00_inclui()
          next option "Seleciona"
  
  command key ("T") "assunTos"
                   "Cadastro de Assuntos por empresa"
          message ""
          display "param.c24pbmcod: ",param.c24pbmcod
          if param.c24pbmcod is not null or param.c24pbmcod <> ' ' then  
             call ctc48m06(param.c24pbmcod)    
             next option "Seleciona"              
          else                                     
             error " Nenhum problema selecionado!" 
             next option "Seleciona"               
          end if                                   
   
  command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc48m00

 end function  # ctc48m00


#------------------------------------------------------------
 function ctc48m00_seleciona()
#------------------------------------------------------------

 define param         record
    c24pbmcod         like datkpbm.c24pbmcod
 end record

 define ctc48m00      record
    c24pbmcod         like datkpbm.c24pbmcod,
    c24pbmdes         like datkpbm.c24pbmdes,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    c24pbmstt         like datkpbm.c24pbmdes,
    c24pbmsttdes      char(15),
    asitipcod         like datkasitip.asitipcod,   
    asitipabvdes      like datkasitip.asitipabvdes,
    caddat            like datkpbm.caddat,
    cadmat            like datkpbm.cadmat,
    cademp            like datkpbm.cademp,
    cadusrtip         like datkpbm.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbm.atldat,
    atlmat            like datkpbm.atlmat,
    atlemp            like datkpbm.atlemp,
    atlusrtip         like datkpbm.atlusrtip,
    funnom            like isskfunc.funnom,
    sphpbmdes         like datkpbm.sphpbmdes,
    webpbmdes         like datkpbm.webpbmdes,
    c24astcod         like datkpbm.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    remrquflg         like datkpbm.remrquflg
 end record

 define ws_c24pbmgrpcod like datkpbmgrp.c24pbmgrpcod

 let int_flag = false
 initialize ctc48m00.*  to null
 initialize param.*     to null
 display by name ctc48m00.c24pbmcod
 display by name ctc48m00.c24pbmdes
 display by name ctc48m00.c24pbmgrpcod
 display by name ctc48m00.c24pbmgrpdes
 display by name ctc48m00.c24pbmstt
 display by name ctc48m00.c24pbmsttdes
 display by name ctc48m00.asitipcod    
 display by name ctc48m00.asitipabvdes 
 display by name ctc48m00.caddat
 display by name ctc48m00.cadfunnom
 display by name ctc48m00.atldat
 display by name ctc48m00.funnom
 display by name ctc48m00.sphpbmdes
 display by name ctc48m00.webpbmdes
 display by name ctc48m00.c24astcod
 display by name ctc48m00.c24astdes
 display by name ctc48m00.remrquflg

 input by name ctc48m00.c24pbmcod

    before field c24pbmcod
        display by name ctc48m00.c24pbmcod attribute (reverse)

    after  field c24pbmcod
        display by name ctc48m00.c24pbmcod

        if ctc48m00.c24pbmcod  is null  or
           ctc48m00.c24pbmcod  =  0    
           then
           call ctc48m02("") returning ctc48m00.c24pbmgrpcod,
                                       ctc48m00.c24pbmgrpdes
           if ctc48m00.c24pbmgrpcod  is null  then
              error " Codigo de problema deve ser informado!"
              next field c24pbmcod
           else
              call ctc48m01(ctc48m00.c24pbmgrpcod,"")
                              returning ctc48m00.c24pbmcod,
                                        ctc48m00.c24pbmdes
              if ctc48m00.c24pbmcod is null  then
                 error " Codigo de problema deve ser informado!"
                 next field c24pbmcod
              end if
           end if
        end if
        
        display by name ctc48m00.c24pbmcod
        display by name ctc48m00.c24pbmdes

    on key (interrupt)
        exit input
        
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc48m00.*   to null
    display by name ctc48m00.c24pbmcod
    display by name ctc48m00.c24pbmdes
    display by name ctc48m00.c24pbmgrpcod
    display by name ctc48m00.c24pbmgrpdes
    display by name ctc48m00.c24pbmstt
    display by name ctc48m00.c24pbmsttdes
    display by name ctc48m00.asitipcod   
    display by name ctc48m00.asitipabvdes
    display by name ctc48m00.caddat
    display by name ctc48m00.cadfunnom
    display by name ctc48m00.atldat
    display by name ctc48m00.funnom
    display by name ctc48m00.sphpbmdes
    display by name ctc48m00.webpbmdes
    display by name ctc48m00.c24astcod
    display by name ctc48m00.c24astdes
    display by name ctc48m00.remrquflg
    error " Operacao cancelada!"
    return param.*
 end if

 call ctc48m00_ler(ctc48m00.c24pbmcod)
      returning ctc48m00.*

 if ctc48m00.c24pbmcod  is not null   then
    display by name ctc48m00.c24pbmcod
    display by name ctc48m00.c24pbmdes
    display by name ctc48m00.c24pbmgrpcod
    display by name ctc48m00.c24pbmgrpdes
    display by name ctc48m00.c24pbmstt
    display by name ctc48m00.c24pbmsttdes
    display by name ctc48m00.asitipcod   
    display by name ctc48m00.asitipabvdes
    display by name ctc48m00.asitipcod   
    display by name ctc48m00.asitipabvdes
    display by name ctc48m00.caddat
    display by name ctc48m00.cadfunnom
    display by name ctc48m00.atldat
    display by name ctc48m00.funnom
    display by name ctc48m00.sphpbmdes
    display by name ctc48m00.webpbmdes
    display by name ctc48m00.c24astcod
    display by name ctc48m00.c24astdes
    display by name ctc48m00.remrquflg
 else
    error " problema nao cadastrado!"
    initialize ctc48m00.*    to null
 end if

 let param.c24pbmcod = ctc48m00.c24pbmcod
 return param.*

 end function  # ctc48m00_seleciona

#------------------------------------------------------------
 function ctc48m00_proximo(param)
#------------------------------------------------------------

 define param         record
    c24pbmcod         like datkpbm.c24pbmcod
 end record

 define ctc48m00      record
    c24pbmcod         like datkpbm.c24pbmcod,
    c24pbmdes         like datkpbm.c24pbmdes,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    c24pbmstt         like datkpbm.c24pbmdes,
    c24pbmsttdes      char(15),
    asitipcod         like datkasitip.asitipcod,   
    asitipabvdes      like datkasitip.asitipabvdes,
    caddat            like datkpbm.caddat,
    cadmat            like datkpbm.cadmat,
    cademp            like datkpbm.cademp,
    cadusrtip         like datkpbm.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbm.atldat,
    atlmat            like datkpbm.atlmat,
    atlemp            like datkpbm.atlemp,
    atlusrtip         like datkpbm.atlusrtip,
    funnom            like isskfunc.funnom,
    sphpbmdes         like datkpbm.sphpbmdes,
    webpbmdes         like datkpbm.webpbmdes,
    c24astcod         like datkpbm.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    remrquflg         like datkpbm.remrquflg
 end record

 let int_flag = false
#initialize ctc48m00.*   to null

#if param.c24pbmcod  is null  then
#   let param.c24pbmcod = 0
#end if

 select min(datkpbm.c24pbmcod)
   into ctc48m00.c24pbmcod
   from datkpbm
  where datkpbm.c24pbmcod > param.c24pbmcod

 if ctc48m00.c24pbmcod  is not null   then
    let param.c24pbmcod = ctc48m00.c24pbmcod
    call ctc48m00_ler(ctc48m00.c24pbmcod)
         returning ctc48m00.*

    if ctc48m00.c24pbmcod  is not null   then
       display by name ctc48m00.c24pbmcod
       display by name ctc48m00.c24pbmdes
       display by name ctc48m00.c24pbmgrpcod
       display by name ctc48m00.c24pbmgrpdes
       display by name ctc48m00.c24pbmstt
       display by name ctc48m00.c24pbmsttdes
       display by name ctc48m00.asitipcod   
       display by name ctc48m00.asitipabvdes
       display by name ctc48m00.caddat
       display by name ctc48m00.cadfunnom
       display by name ctc48m00.atldat
       display by name ctc48m00.funnom
       display by name ctc48m00.sphpbmdes
       display by name ctc48m00.webpbmdes
       display by name ctc48m00.c24astcod
       display by name ctc48m00.c24astdes
       display by name ctc48m00.remrquflg
    else
       error " Nao ha' problema nesta direcao!"
     # initialize ctc48m00.*    to null
    end if
 else
    error " Nao ha' problema nesta direcao!"
    #   initialize ctc48m00.*    to null
 end if

 return param.*

 end function    # ctc48m00_proximo


#------------------------------------------------------------
 function ctc48m00_anterior(param)
#------------------------------------------------------------

 define param         record
    c24pbmcod         like datkpbm.c24pbmcod
 end record

 define ctc48m00      record
    c24pbmcod         like datkpbm.c24pbmcod,
    c24pbmdes         like datkpbm.c24pbmdes,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    c24pbmstt         like datkpbm.c24pbmdes,
    c24pbmsttdes      char(15),
    asitipcod         like datkasitip.asitipcod,   
    asitipabvdes      like datkasitip.asitipabvdes,
    caddat            like datkpbm.caddat,
    cadmat            like datkpbm.cadmat,
    cademp            like datkpbm.cademp,
    cadusrtip         like datkpbm.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbm.atldat,
    atlmat            like datkpbm.atlmat,
    atlemp            like datkpbm.atlemp,
    atlusrtip         like datkpbm.atlusrtip,
    funnom            like isskfunc.funnom,
    sphpbmdes         like datkpbm.sphpbmdes,
    webpbmdes         like datkpbm.webpbmdes,
    c24astcod         like datkpbm.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    remrquflg         like datkpbm.remrquflg
 end record

 let int_flag = false
#initialize ctc48m00.*  to null

#if param.c24pbmcod  is null  then
#   let param.c24pbmcod = 0
#end if

 select max(datkpbm.c24pbmcod)
   into ctc48m00.c24pbmcod
   from datkpbm
  where datkpbm.c24pbmcod     < param.c24pbmcod

 if ctc48m00.c24pbmcod  is not null   then
    let param.c24pbmcod = ctc48m00.c24pbmcod
    call ctc48m00_ler(ctc48m00.c24pbmcod)
         returning ctc48m00.*

    if ctc48m00.c24pbmcod  is not null   then
       display by name ctc48m00.c24pbmcod
       display by name ctc48m00.c24pbmdes
       display by name ctc48m00.c24pbmgrpcod
       display by name ctc48m00.c24pbmgrpdes
       display by name ctc48m00.c24pbmstt
       display by name ctc48m00.c24pbmsttdes
       display by name ctc48m00.asitipcod   
       display by name ctc48m00.asitipabvdes
       display by name ctc48m00.caddat
       display by name ctc48m00.cadfunnom
       display by name ctc48m00.atldat
       display by name ctc48m00.funnom
       display by name ctc48m00.sphpbmdes
       display by name ctc48m00.webpbmdes
       display by name ctc48m00.c24astcod
       display by name ctc48m00.c24astdes
       display by name ctc48m00.remrquflg
    else
       error " Nao ha' problema nesta direcao!"
       #      initialize ctc48m00.*    to null
    end if
 else
    error " Nao ha' problema nesta direcao!"
    #   initialize ctc48m00.*    to null
 end if

 return param.*

 end function    # ctc48m00_anterior

#------------------------------------------------------------
 function ctc48m00_modifica(param)
#------------------------------------------------------------

 define param         record
    c24pbmcod         like datkpbm.c24pbmcod
 end record

 define ctc48m00      record
    c24pbmcod         like datkpbm.c24pbmcod,
    c24pbmdes         like datkpbm.c24pbmdes,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    c24pbmstt         like datkpbm.c24pbmdes,
    c24pbmsttdes      char(15),
    asitipcod         like datkasitip.asitipcod,   
    asitipabvdes      like datkasitip.asitipabvdes,
    caddat            like datkpbm.caddat,
    cadmat            like datkpbm.cadmat,
    cademp            like datkpbm.cademp,
    cadusrtip         like datkpbm.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbm.atldat,
    atlmat            like datkpbm.atlmat,
    atlemp            like datkpbm.atlemp,
    atlusrtip         like datkpbm.atlusrtip,
    funnom            like isskfunc.funnom,
    sphpbmdes         like datkpbm.sphpbmdes,
    webpbmdes         like datkpbm.webpbmdes,
    c24astcod         like datkpbm.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    remrquflg         like datkpbm.remrquflg
 end record

 call ctc48m00_ler(param.c24pbmcod)
      returning ctc48m00.*
 if ctc48m00.c24pbmcod is null then
    error " Registro nao localizado "
    return param.*
 end if

 call ctc48m00_input("a", param.*,ctc48m00.*) returning param.*, ctc48m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc48m00.*  to null
    display by name ctc48m00.c24pbmcod
    display by name ctc48m00.c24pbmdes
    display by name ctc48m00.c24pbmgrpcod
    display by name ctc48m00.c24pbmgrpdes
    display by name ctc48m00.c24pbmstt
    display by name ctc48m00.c24pbmsttdes
    display by name ctc48m00.asitipcod   
    display by name ctc48m00.asitipabvdes
    display by name ctc48m00.caddat
    display by name ctc48m00.cadfunnom
    display by name ctc48m00.atldat
    display by name ctc48m00.funnom
    display by name ctc48m00.sphpbmdes
    display by name ctc48m00.webpbmdes
    display by name ctc48m00.c24astcod
    display by name ctc48m00.c24astdes
    display by name ctc48m00.remrquflg
    error " Operacao cancelada!"
    return param.*
 end if

 whenever error continue

 let ctc48m00.atldat = today

 begin work
    update datkpbm     set  ( c24pbmdes,
                              c24pbmgrpcod,
                              c24pbmstt,
                              atldat,
                              atlmat,
                              atlemp,
                              atlusrtip,
                              asitipcod,
                              sphpbmdes,
                              webpbmdes,
                              c24astcod,
                              remrquflg )
                        =   ( ctc48m00.c24pbmdes,
                              ctc48m00.c24pbmgrpcod,
                              ctc48m00.c24pbmstt,
                              ctc48m00.atldat,
                              g_issk.funmat,
                              g_issk.empcod,
                              g_issk.usrtip,
                              ctc48m00.asitipcod,
                              ctc48m00.sphpbmdes,
                              ctc48m00.webpbmdes,
                              ctc48m00.c24astcod,
                              ctc48m00.remrquflg )
           where datkpbm.c24pbmcod  =  param.c24pbmcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do problema!"
       rollback work
       initialize ctc48m00.*   to null
       initialize param.*      to null
       return param.*
    else
       error " Alteracao efetuada com sucesso!"
    end if

 commit work

 whenever error stop

 initialize ctc48m00.*  to null
 display by name ctc48m00.c24pbmcod
 display by name ctc48m00.c24pbmdes
 display by name ctc48m00.c24pbmgrpcod
 display by name ctc48m00.c24pbmgrpdes
 display by name ctc48m00.c24pbmstt
 display by name ctc48m00.c24pbmsttdes
 display by name ctc48m00.asitipcod   
 display by name ctc48m00.asitipabvdes
 display by name ctc48m00.caddat
 display by name ctc48m00.cadfunnom
 display by name ctc48m00.atldat
 display by name ctc48m00.funnom
 display by name ctc48m00.sphpbmdes
 display by name ctc48m00.webpbmdes
 display by name ctc48m00.c24astcod
 display by name ctc48m00.c24astdes
 display by name ctc48m00.remrquflg
 message ""
 return param.*

 end function   #  ctc48m00_modifica


#------------------------------------------------------------
 function ctc48m00_inclui()
#------------------------------------------------------------

 define param         record
    c24pbmcod         like datkpbm.c24pbmcod
 end record

 define ctc48m00      record
    c24pbmcod         like datkpbm.c24pbmcod,
    c24pbmdes         like datkpbm.c24pbmdes,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    c24pbmstt         like datkpbm.c24pbmdes,
    c24pbmsttdes      char(15),
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    caddat            like datkpbm.caddat,
    cadmat            like datkpbm.cadmat,
    cademp            like datkpbm.cademp,
    cadusrtip         like datkpbm.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbm.atldat,
    atlmat            like datkpbm.atlmat,
    atlemp            like datkpbm.atlemp,
    atlusrtip         like datkpbm.atlusrtip,
    funnom            like isskfunc.funnom,
    sphpbmdes         like datkpbm.sphpbmdes,
    webpbmdes         like datkpbm.webpbmdes,
    c24astcod         like datkpbm.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    remrquflg         like datkpbm.remrquflg
 end record

 define  ws_resp       char(01)

 initialize ctc48m00.*, param.*   to null

 display by name ctc48m00.c24pbmcod
 display by name ctc48m00.c24pbmdes
 display by name ctc48m00.c24pbmgrpcod
 display by name ctc48m00.c24pbmgrpdes
 display by name ctc48m00.c24pbmstt
 display by name ctc48m00.c24pbmsttdes
 display by name ctc48m00.asitipcod         
 display by name ctc48m00.asitipabvdes      
 display by name ctc48m00.caddat
 display by name ctc48m00.cadfunnom
 display by name ctc48m00.atldat
 display by name ctc48m00.funnom
 display by name ctc48m00.sphpbmdes
 display by name ctc48m00.webpbmdes
 display by name ctc48m00.c24astcod
 display by name ctc48m00.c24astdes
 display by name ctc48m00.remrquflg

 call ctc48m00_input("i", param.*, ctc48m00.*) returning param.*, ctc48m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc48m00.*  to null
    display by name ctc48m00.c24pbmcod
    display by name ctc48m00.c24pbmdes
    display by name ctc48m00.c24pbmgrpcod
    display by name ctc48m00.c24pbmgrpdes
    display by name ctc48m00.c24pbmstt
    display by name ctc48m00.c24pbmsttdes
    display by name ctc48m00.asitipcod         
    display by name ctc48m00.asitipabvdes     
    display by name ctc48m00.caddat
    display by name ctc48m00.cadfunnom
    display by name ctc48m00.atldat
    display by name ctc48m00.funnom
    display by name ctc48m00.sphpbmdes
    display by name ctc48m00.webpbmdes
    display by name ctc48m00.c24astcod
    display by name ctc48m00.c24astdes
    display by name ctc48m00.remrquflg
    error " Operacao cancelada!"
    return
 end if

 let ctc48m00.atldat = today
 let ctc48m00.caddat = today


 whenever error continue

 begin work
    insert into datkpbm     ( c24pbmcod,
                              c24pbmdes,
                              c24pbmgrpcod,
                              c24pbmstt,
                              caddat,
                              cademp,
                              cadmat,
                              cadusrtip,
                              atldat,
                              atlemp,
                              atlmat,
                              atlusrtip,
                              asitipcod,
                              sphpbmdes,
                              webpbmdes,
                              c24astcod,
                              remrquflg )
                  values
                            ( ctc48m00.c24pbmcod,
                              ctc48m00.c24pbmdes,
                              ctc48m00.c24pbmgrpcod,
                              ctc48m00.c24pbmstt,
                              today,
                              g_issk.empcod,
                              g_issk.funmat,
                              g_issk.usrtip,
                              today,
                              g_issk.empcod,
                              g_issk.funmat,
                              g_issk.usrtip,
                              ctc48m00.asitipcod,
                              ctc48m00.sphpbmdes,
                              ctc48m00.webpbmdes,
                              ctc48m00.c24astcod,
                              ctc48m00.remrquflg )

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do problema!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 call ctc48m00_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
      returning ctc48m00.cadfunnom

 call ctc48m00_func(g_issk.funmat,
                    g_issk.empcod,
                    g_issk.usrtip)
      returning ctc48m00.funnom

 display by name ctc48m00.c24pbmcod
 display by name ctc48m00.c24pbmdes
 display by name ctc48m00.c24pbmgrpcod
 display by name ctc48m00.c24pbmgrpdes
 display by name ctc48m00.c24pbmstt
 display by name ctc48m00.c24pbmsttdes
 display by name ctc48m00.asitipcod   
 display by name ctc48m00.asitipabvdes
 display by name ctc48m00.caddat
 display by name ctc48m00.cadfunnom
 display by name ctc48m00.atldat
 display by name ctc48m00.funnom
 display by name ctc48m00.sphpbmdes
 display by name ctc48m00.webpbmdes
 display by name ctc48m00.c24astcod
 display by name ctc48m00.c24astdes
 display by name ctc48m00.remrquflg

 display by name ctc48m00.c24pbmcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize ctc48m00.*  to null
 display by name ctc48m00.c24pbmcod
 display by name ctc48m00.c24pbmdes
 display by name ctc48m00.c24pbmgrpcod
 display by name ctc48m00.c24pbmgrpdes
 display by name ctc48m00.c24pbmstt
 display by name ctc48m00.c24pbmsttdes
 display by name ctc48m00.asitipcod   
 display by name ctc48m00.asitipabvdes
 display by name ctc48m00.caddat
 display by name ctc48m00.cadfunnom
 display by name ctc48m00.atldat
 display by name ctc48m00.funnom
 display by name ctc48m00.sphpbmdes
 display by name ctc48m00.webpbmdes
 display by name ctc48m00.c24astcod
 display by name ctc48m00.c24astdes
 display by name ctc48m00.remrquflg

end function   #  ctc48m00_inclui


#--------------------------------------------------------------------
 function ctc48m00_input(ws_operacao, param, ctc48m00)
#--------------------------------------------------------------------

 define ws_operacao   char (1),
        l_atdsrvorg   like datkpbmgrp.atdsrvorg

 define param         record
    c24pbmcod         like datkpbm.c24pbmcod
 end record

 define ctc48m00      record
    c24pbmcod         like datkpbm.c24pbmcod,
    c24pbmdes         like datkpbm.c24pbmdes,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    c24pbmstt         like datkpbm.c24pbmdes,
    c24pbmsttdes      char(15),
    asitipcod         like datkasitip.asitipcod,
    asitipabvdes      like datkasitip.asitipabvdes,
    caddat            like datkpbm.caddat,
    cadmat            like datkpbm.cadmat,
    cademp            like datkpbm.cademp,
    cadusrtip         like datkpbm.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbm.atldat,
    atlmat            like datkpbm.atlmat,
    atlemp            like datkpbm.atlemp,
    atlusrtip         like datkpbm.atlusrtip,
    funnom            like isskfunc.funnom,
    sphpbmdes         like datkpbm.sphpbmdes,
    webpbmdes         like datkpbm.webpbmdes,
    c24astcod         like datkpbm.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    remrquflg         like datkpbm.remrquflg
 end record

 define ws            record
    cont              integer
 end record

 define param_popup   record      
   linha1              char (40),  
   linha2              char (40),  
   linha3              char (40),
   linha4              char (40),
   confirma            char (1)  
 end record   
 
 define l_sql  char(200),
        l_res  smallint
 
 initialize l_sql to null
 initialize param_popup.* to null 
 let int_flag = false
 let ws.cont  = 0

 if ws_operacao   = "i"  then
    select max(c24pbmcod)
         into ws.cont
         from datkpbm
    if  ws.cont  is null then
        let ws.cont =  1
    else
        let ws.cont = ws.cont + 1
    end if
 end if

 input by name
               ctc48m00.c24pbmcod,
               ctc48m00.c24pbmdes,
               ctc48m00.c24pbmgrpcod,
               ctc48m00.c24pbmstt,
               ctc48m00.asitipcod,
               ctc48m00.remrquflg, 
               ctc48m00.sphpbmdes,
               ctc48m00.webpbmdes,
               ctc48m00.c24astcod without defaults
               
 
    
       before field c24pbmcod
            if ws_operacao  =  "a"   then
               next field  c24pbmdes
            end if
            let ctc48m00.c24pbmcod = ws.cont
            display by name ctc48m00.c24pbmcod # attribute (reverse)
            next field  c24pbmdes

       after  field c24pbmcod
           display by name ctc48m00.c24pbmcod

           if ctc48m00.c24pbmcod  is null   then
              error " Codigo do problema deve ser informado!"
              next field c24pbmcod
           end if

           select c24pbmcod
             from datkpbm
            where c24pbmcod = ctc48m00.c24pbmcod

           if sqlca.sqlcode  =  0   then
              error " Codigo de problema ja' cadastrado!"
              next field c24pbmcod
           end if

       before field c24pbmdes
           display by name ctc48m00.c24pbmdes #attribute (reverse)

       after  field c24pbmdes
           display by name ctc48m00.c24pbmdes

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ws_operacao  =  "i"   then
                 next field  c24pbmcod
              else
                 next field  c24pbmdes
              end if
           end if

           if ctc48m00.c24pbmdes  is null   then
              error " Descricao do problema deve ser informado!"
              next field c24pbmdes
           end if

       before field c24pbmgrpcod
          display by name ctc48m00.c24pbmgrpcod # attribute(reverse)

       after  field c24pbmgrpcod
          display by name ctc48m00.c24pbmgrpcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24pbmdes
          end if
          if ctc48m00.c24pbmgrpcod is null   then
             call ctc48m02("") returning ctc48m00.c24pbmgrpcod,
                                         ctc48m00.c24pbmgrpdes
             if ctc48m00.c24pbmgrpcod is null  then
                error " Codigo do Agrupamento deve ser informado!"
                next field c24pbmgrpcod
             end if
          end if
          select c24pbmgrpdes
                into ctc48m00.c24pbmgrpdes
                from datkpbmgrp
                where c24pbmgrpcod = ctc48m00.c24pbmgrpcod

          if sqlca.sqlcode = notfound then
             error " Codigo de Agrupamento nao cadastrado"
             next field c24pbmgrpcod
          end if
          display by name ctc48m00.c24pbmgrpcod
          display by name ctc48m00.c24pbmgrpdes

       after  field c24pbmstt
          display by name ctc48m00.c24pbmstt

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24pbmstt
          end if
          if ctc48m00.c24pbmgrpcod is null   then
             error " Situacao do problema deve ser informado!"
             next field c24pbmstt
          end if
          if ctc48m00.c24pbmstt <> 'C' and
             ctc48m00.c24pbmstt <> 'A' then
             error " Informe (A/C) para situacao do problema!"
             next field c24pbmstt
          end if

          if ctc48m00.c24pbmstt = 'C' then
             let ctc48m00.c24pbmsttdes = 'Cancelado'
          else
             let ctc48m00.c24pbmsttdes = 'Ativo'
          end if

          display by name ctc48m00.c24pbmstt
          display by name ctc48m00.c24pbmsttdes
          
       after  field asitipcod

          if  ctc48m00.asitipcod is not null  then
              whenever error continue
                select asitipabvdes
                  into ctc48m00.asitipabvdes
                  from datkasitip
                 where asitipcod = ctc48m00.asitipcod  and
                       asitipstt = "A" 
              whenever error stop

              if  sqlca.sqlcode = notfound or ctc48m00.asitipcod = 0 then
                  let ctc48m00.asitipcod    = ""
                  let ctc48m00.asitipabvdes = ""
                  
                 whenever error continue
                   select atdsrvorg
                     into l_atdsrvorg
                     from datkpbmgrp
                    where c24pbmgrpcod = ctc48m00.c24pbmgrpcod
                 whenever error stop
                 
                 if  sqlca.sqlcode = notfound then
                     error 'Problema na origem do grupo do Problema.'
                     next field asitipcod
                 end if
                   
                  let ctc48m00.asitipcod = ctn25c00(l_atdsrvorg)
                  next field asitipcod
              end if
          end if
          
          display by name ctc48m00.asitipcod
          display by name ctc48m00.asitipabvdes
       
        before field remrquflg
          display by name ctc48m00.remrquflg attribute(reverse)
          
       after field remrquflg
          if ctc48m00.sphpbmdes is not null and ctc48m00.sphpbmdes != ' ' then
             if {ws_operacao = 'a' and }param_popup.confirma is not null then
                if ctc48m00.remrquflg is null or ctc48m00.remrquflg = ' '
                   then
                   error ' Digite a flag remoção requerida '
                   next field remrquflg
                end if
             end if   
          end if
          display by name ctc48m00.remrquflg
          
          if ctc48m00.remrquflg != "S" and ctc48m00.remrquflg != "N"
             then
             error ' Flag remoção requerida digite S ou N '
             initialize ctc48m00.remrquflg to null
             display by name ctc48m00.remrquflg
             next field remrquflg
          end if
      before field sphpbmdes
          display by name ctc48m00.sphpbmdes attribute(reverse)
          
       after field sphpbmdes
          if ctc48m00.sphpbmdes is not null or ctc48m00.sphpbmdes != ' ' then
             if ctc48m00.remrquflg is null or ctc48m00.remrquflg == ' ' then
                let param_popup.linha2 = "Para Descricao SMART e' obrigatorio "
                let param_popup.linha3 = "o preenchimento do campo "
                let param_popup.linha4 = "remocao requerida "
                call cts08g01("A","N",param_popup.linha1,
                                      param_popup.linha2,
                                      param_popup.linha3,
                                      param_popup.linha4)
                            returning param_popup.confirma                  
                next field remrquflg
             end if
          end if      
          display by name ctc48m00.sphpbmdes   
                
       before field webpbmdes
          display by name ctc48m00.webpbmdes attribute(reverse)
          
       after field webpbmdes
          display by name ctc48m00.webpbmdes
       
          
       before field c24astcod
          display by name ctc48m00.c24astcod attribute(reverse)
          
       after field c24astcod
          display by name ctc48m00.c24astcod
          if ctc48m00.sphpbmdes is not null or ctc48m00.sphpbmdes != ' ' then
             if ctc48m00.c24astcod is null or ctc48m00.c24astcod = ' ' then
                initialize param_popup.* to null
                let param_popup.linha2 = "Para Descricao SMART e' obrigatorio "
                let param_popup.linha3 = "o preenchimento do campo "
                let param_popup.linha4 = "codigo do assunto"
                call cts08g01("A","N",param_popup.linha1,
                                      param_popup.linha2,
                                      param_popup.linha3,
                                      param_popup.linha4)
                            returning param_popup.confirma                 
                let l_sql = " select c24astcod, c24astdes from datkassunto ",
                            " where c24aststt = 'A' and c24astcod != '0' ",
                            " order by 1 "
                call ofgrc001_popup(08, 13, 'ESCOLHA O ASSUNTO',
                                 'Codigo', 'Descricao', 'A', l_sql, '', 'D')
                    returning l_res, ctc48m00.c24astcod, ctc48m00.c24astdes
             else
                whenever error continue
                select c24astdes into ctc48m00.c24astdes
                from datkassunto
                where c24astcod = ctc48m00.c24astcod
                whenever error stop
                
                if sqlca.sqlcode != 0
                   then
                   if sqlca.sqlcode = 100
                      then
                      error ' Assunto não localizado, digite novamente '
                   else
                      error ' Erro no acesso a tabela de assunto: ', sqlca.sqlcode
                   end if
                   next field c24astcod
                end if
             end if
             
             display by name ctc48m00.c24astdes
             if ctc48m00.c24astcod is null or ctc48m00.c24astcod = ' '
                then
                error ' Digite o código do assunto '
                sleep 1
                next field c24astcod
             end if
          end if   
           
     on key (interrupt)
       exit input

 end input

 if int_flag   then
    initialize param.*, ctc48m00.*  to null
 end if

 return param.*, ctc48m00.*

 end function   # ctc48m00_input


#---------------------------------------------------------
 function ctc48m00_ler(param)
#---------------------------------------------------------

 define param         record
    c24pbmcod         like datkpbm.c24pbmcod
 end record

 define ctc48m00      record
    c24pbmcod         like datkpbm.c24pbmcod,
    c24pbmdes         like datkpbm.c24pbmdes,
    c24pbmgrpcod      like datkpbmgrp.c24pbmgrpcod,
    c24pbmgrpdes      like datkpbmgrp.c24pbmgrpdes,
    c24pbmstt         like datkpbm.c24pbmdes,
    c24pbmsttdes      char(15),
    asitipcod         like datkasitip.asitipcod,   
    asitipabvdes      like datkasitip.asitipabvdes,
    caddat            like datkpbm.caddat,
    cadmat            like datkpbm.cadmat,
    cademp            like datkpbm.cademp,
    cadusrtip         like datkpbm.cadusrtip,
    cadfunnom         like isskfunc.funnom,
    atldat            like datkpbm.atldat,
    atlmat            like datkpbm.atlmat,
    atlemp            like datkpbm.atlemp,
    atlusrtip         like datkpbm.atlusrtip,
    funnom            like isskfunc.funnom,
    sphpbmdes         like datkpbm.sphpbmdes,
    webpbmdes         like datkpbm.webpbmdes,
    c24astcod         like datkpbm.c24astcod,
    c24astdes         like datkassunto.c24astdes,
    remrquflg         like datkpbm.remrquflg
 end record

 define ws            record
    atlmat            like isskfunc.funmat,
    cadmat            like isskfunc.funmat,
    c24pbmgrpcod      like datkpbm.c24pbmgrpcod
 end record

 initialize ctc48m00.*   to null
 initialize ws.*         to null

 select  c24pbmcod,
         c24pbmdes,
         c24pbmgrpcod,
         c24pbmstt,
         caddat,
         cadmat,
         cademp,
         cadusrtip,
         atldat,
         atlmat,
         atlemp,
         atlusrtip,
         asitipcod,
         sphpbmdes,
         webpbmdes,
         c24astcod,
         remrquflg
   into  ctc48m00.c24pbmcod,
         ctc48m00.c24pbmdes,
         ctc48m00.c24pbmgrpcod,
         ctc48m00.c24pbmstt,
         ctc48m00.caddat,
         ctc48m00.cadmat,
         ctc48m00.cademp,
         ctc48m00.cadusrtip,
         ctc48m00.atldat,
         ctc48m00.atlmat,
         ctc48m00.atlemp,
         ctc48m00.atlusrtip,
         ctc48m00.asitipcod,
         ctc48m00.sphpbmdes,
         ctc48m00.webpbmdes,
         ctc48m00.c24astcod,
         ctc48m00.remrquflg
   from  datkpbm
  where  c24pbmcod = param.c24pbmcod

 if sqlca.sqlcode = notfound   then
    error " Codigo de problema nao cadastrado!"
    initialize ctc48m00.*    to null
    return ctc48m00.*
 else
    call ctc48m00_func(ctc48m00.cadmat,
                       ctc48m00.cademp,
                       ctc48m00.cadusrtip)
         returning ctc48m00.cadfunnom

    call ctc48m00_func(ctc48m00.atlmat,
                       ctc48m00.atlemp,
                       ctc48m00.atlusrtip)
         returning ctc48m00.funnom

    select c24pbmgrpdes
        into ctc48m00.c24pbmgrpdes
        from datkpbmgrp
        where c24pbmgrpcod = ctc48m00.c24pbmgrpcod
                            
    select asitipabvdes
      into ctc48m00.asitipabvdes               
      from datkasitip                                  
     where asitipcod = ctc48m00.asitipcod                      
                            
    if ctc48m00.c24pbmstt = 'C' then
       let ctc48m00.c24pbmsttdes = 'Cancelado'
    else
       let ctc48m00.c24pbmsttdes = 'Ativo'
    end if
 end if

 # buscar descricao do assunto
 whenever error continue
 select c24astdes into ctc48m00.c24astdes
 from datkassunto
 where c24astcod = ctc48m00.c24astcod
 whenever error stop
 
 if sqlca.sqlcode != 0
    then
    initialize ctc48m00.c24astdes to null
 end if
 
 return ctc48m00.*

 end function   # ctc48m00_ler


#---------------------------------------------------------
 function ctc48m00_func(param)
#---------------------------------------------------------

   define param         record
      funmat            like isskfunc.funmat,
      empcod            like isskfunc.empcod,
      usrtip            like isskfunc.usrtip
   end record

   define ws            record
      funnom            like isskfunc.funnom
   end record

   initialize ws.*    to null

   select funnom
     into ws.funnom
     from isskfunc
    where isskfunc.funmat = param.funmat
      and isskfunc.empcod = param.empcod
      and isskfunc.usrtip = param.usrtip

   return ws.funnom

 end function   # ctc48m00_func
