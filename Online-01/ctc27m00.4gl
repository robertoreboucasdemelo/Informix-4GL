#############################################################################
# Nome do Modulo: ctc27M00                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao no Cadastro de Aeroportos                             Jun/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso  #
#############################################################################

 database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc27m00()
#------------------------------------------------------------

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 #PSI 202290
 #if not get_niv_mod(g_issk.prgsgl, "ctc27m00") then
 #   error " Modulo sem nivel de consulta e atualizacao!"
 #   return
 #end if

 open window ctc27m00 at 04,02 with form "ctc27m00"

 let int_flag = false

 initialize ctc27m00.*   to  null
 initialize k_ctc27m00.* to  null

 menu "AEROPORTOS"
      before menu
         hide option all
         #PSI 202290
         #if g_issk.acsnivcod >= g_issk.acsnivcns  then
         #   show option "Seleciona", "Proximo", "Anterior"
         #end if
         #if g_issk.acsnivcod >= g_issk.acsnivatl  then
            show option "Seleciona", "Proximo", "Anterior", "Modifica", "Inclui"
         #end if

         show option "Encerra"

      command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
            call seleciona_ctc27m00() returning k_ctc27m00.*
            if k_ctc27m00.arpcod is not null  then
               next option "Proximo"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

      command key ("P") "Proximo" "Mostra proximo registro selecionado"
            if k_ctc27m00.arpcod is not null  then
               call proximo_ctc27m00(k_ctc27m00.*)
                    returning k_ctc27m00.*
            else
               error " Nao ha' mais registros nesta direcao!"
               next option "Seleciona"
            end if

      command key ("A") "Anterior" "Mostra registro anterior selecionado"
            if k_ctc27m00.arpcod is not null  then
               call anterior_ctc27m00(k_ctc27m00.*)
                    returning k_ctc27m00.*
            else
               error " Nao ha' mais registros nesta direcao!"
               next option "Seleciona"
            end if

      command key ("M") "Modifica" "Modifica registro corrente selecionado"
            if k_ctc27m00.arpcod is not null  then
               call modifica_ctc27m00(k_ctc27m00.*)
                    returning k_ctc27m00.*
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

      command key ("R") "Remove" "Remove registro corrente selecionado"
            if k_ctc27m00.arpcod is not null  then
               call remove_ctc27m00(k_ctc27m00.*)
                    returning k_ctc27m00.*
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

      command key ("I") "Inclui" "Inclui registro na tabela"
            call inclui_ctc27m00()
            next option "Seleciona"

      command key (interrupt,"E") "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc27m00

end function  ###  ctc27m00

#------------------------------------------------------------
 function seleciona_ctc27m00()
#------------------------------------------------------------

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 clear form

 let int_flag = false

 input by name k_ctc27m00.arpcod

      before field arpcod
         display by name k_ctc27m00.arpcod    attribute (reverse)

      after  field arpcod
         display by name k_ctc27m00.arpcod

         if k_ctc27m00.arpcod is null then
            select min(arpcod)
              into k_ctc27m00.arpcod
              from datkaeroporto

            if k_ctc27m00.arpcod is null  then
               error " Nao ha' nenhum aeroporto cadastrado! "
               sleep 2
               let int_flag = true
               exit input
            end if
         end if

      on key (interrupt)
         exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize ctc27m00.*   to null
    error " Operacao cancelada!"
    clear form
    return k_ctc27m00.*
 end if

 call sel_ctc27m00 (k_ctc27m00.*) returning ctc27m00.*

 if ctc27m00.arpcod is not null  then
    display by name ctc27m00.arpcod,
                    ctc27m00.arpnom,
                    ctc27m00.arpend,
                    ctc27m00.brrnom,
                    ctc27m00.cidnom,
                    ctc27m00.ufdcod,
                    ctc27m00.lclrefptotxt,
                    ctc27m00.lgdcep,
                    ctc27m00.lgdcepcmp,
                    ctc27m00.dddcod,
                    ctc27m00.lcltelnum,
                    ctc27m00.hor24h,
                    ctc27m00.horsegsexinc,
                    ctc27m00.horsegsexfnl,
                    ctc27m00.horsabinc,
                    ctc27m00.horsabfnl,
                    ctc27m00.hordominc,
                    ctc27m00.hordomfnl,
                    ctc27m00.arpsitcod,
                    ctc27m00.arpsitdes,
                    ctc27m00.caddat,
                    ctc27m00.cademp,
                    ctc27m00.cadmat,
                    ctc27m00.cadnom,
                    ctc27m00.atldat,
                    ctc27m00.atlemp,
                    ctc27m00.atlmat,
                    ctc27m00.atlnom,
                    ctc27m00.arpobs
 else
    error " Aeroporto nao cadastrado!"
    initialize ctc27m00.*    to null
    initialize k_ctc27m00.*  to null
 end if

 let k_ctc27m00.arpcod = ctc27m00.arpcod
 return k_ctc27m00.*

end function  ###  seleciona_ctc27m00

#------------------------------------------------------------
 function proximo_ctc27m00(k_ctc27m00)
#------------------------------------------------------------

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 let int_flag = false

 select min (arpcod)
   into ctc27m00.arpcod
   from datkaeroporto
  where arpcod    > k_ctc27m00.arpcod

 if ctc27m00.arpcod is null  then
    error " Nao ha' mais registros nesta direcao!"
 else
    let k_ctc27m00.arpcod = ctc27m00.arpcod

    call sel_ctc27m00 (k_ctc27m00.*) returning ctc27m00.*

    if ctc27m00.arpcod is not null  then
       let k_ctc27m00.arpcod = ctc27m00.arpcod
       display by name ctc27m00.arpcod,
                       ctc27m00.arpnom,
                       ctc27m00.arpend,
                       ctc27m00.brrnom,
                       ctc27m00.cidnom,
                       ctc27m00.ufdcod,
                       ctc27m00.lclrefptotxt,
                       ctc27m00.lgdcep,
                       ctc27m00.lgdcepcmp,
                       ctc27m00.dddcod,
                       ctc27m00.lcltelnum,
                       ctc27m00.hor24h,
                       ctc27m00.horsegsexinc,
                       ctc27m00.horsegsexfnl,
                       ctc27m00.horsabinc,
                       ctc27m00.horsabfnl,
                       ctc27m00.hordominc,
                       ctc27m00.hordomfnl,
                       ctc27m00.arpsitcod,
                       ctc27m00.arpsitdes,
                       ctc27m00.caddat,
                       ctc27m00.cademp,
                       ctc27m00.cadmat,
                       ctc27m00.cadnom,
                       ctc27m00.atldat,
                       ctc27m00.atlemp,
                       ctc27m00.atlmat,
                       ctc27m00.atlnom,
                       ctc27m00.arpobs
    else
       initialize ctc27m00.*    to null
    end if
 end if

 return k_ctc27m00.*

end function  ###  proximo_ctc27m00

#------------------------------------------------------------
 function anterior_ctc27m00(k_ctc27m00)
#------------------------------------------------------------

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 let int_flag = false

 select max (arpcod)
   into ctc27m00.arpcod
   from datkaeroporto
  where arpcod < k_ctc27m00.arpcod

 if ctc27m00.arpcod is null  then
    error " Nao ha' mais registros nesta direcao!"
 else
    let k_ctc27m00.arpcod = ctc27m00.arpcod

    call sel_ctc27m00 (k_ctc27m00.*) returning ctc27m00.*

    if ctc27m00.arpcod is not null  then
       let k_ctc27m00.arpcod    = ctc27m00.arpcod
       display by name ctc27m00.arpcod,
                       ctc27m00.arpnom,
                       ctc27m00.arpend,
                       ctc27m00.brrnom,
                       ctc27m00.cidnom,
                       ctc27m00.ufdcod,
                       ctc27m00.lclrefptotxt,
                       ctc27m00.lgdcep,
                       ctc27m00.lgdcepcmp,
                       ctc27m00.dddcod,
                       ctc27m00.lcltelnum,
                       ctc27m00.hor24h,
                       ctc27m00.horsegsexinc,
                       ctc27m00.horsegsexfnl,
                       ctc27m00.horsabinc,
                       ctc27m00.horsabfnl,
                       ctc27m00.hordominc,
                       ctc27m00.hordomfnl,
                       ctc27m00.arpsitcod,
                       ctc27m00.arpsitdes,
                       ctc27m00.caddat,
                       ctc27m00.cademp,
                       ctc27m00.cadmat,
                       ctc27m00.cadnom,
                       ctc27m00.atldat,
                       ctc27m00.atlemp,
                       ctc27m00.atlmat,
                       ctc27m00.atlnom,
                       ctc27m00.arpobs
    else
       initialize ctc27m00.*    to null
    end if
 end if

 return k_ctc27m00.*

end function  ###  anterior_ctc27m00

#------------------------------------------------------------
 function modifica_ctc27m00(k_ctc27m00)
#------------------------------------------------------------

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 call sel_ctc27m00 (k_ctc27m00.*) returning ctc27m00.*

 if ctc27m00.arpcod is not null  then
    display by name ctc27m00.arpcod,
                    ctc27m00.arpnom,
                    ctc27m00.arpend,
                    ctc27m00.brrnom,
                    ctc27m00.cidnom,
                    ctc27m00.ufdcod,
                    ctc27m00.lclrefptotxt,
                    ctc27m00.lgdcep,
                    ctc27m00.lgdcepcmp,
                    ctc27m00.dddcod,
                    ctc27m00.lcltelnum,
                    ctc27m00.hor24h,
                    ctc27m00.horsegsexinc,
                    ctc27m00.horsegsexfnl,
                    ctc27m00.horsabinc,
                    ctc27m00.horsabfnl,
                    ctc27m00.hordominc,
                    ctc27m00.hordomfnl,
                    ctc27m00.arpsitcod,
                    ctc27m00.arpsitdes,
                    ctc27m00.caddat,
                    ctc27m00.cademp,
                    ctc27m00.cadmat,
                    ctc27m00.cadnom,
                    ctc27m00.atldat,
                    ctc27m00.atlemp,
                    ctc27m00.atlmat,
                    ctc27m00.atlnom,
                    ctc27m00.arpobs

    call input_ctc27m00("a", k_ctc27m00.*, ctc27m00.*)
         returning ctc27m00.*, k_ctc27m00.*

    if int_flag  then
       let int_flag = false
       initialize ctc27m00.*  to null
       error " Operacao cancelada!"
       clear form
       return k_ctc27m00.*
    end if

    update datkaeroporto set ( arpnom      , lgdtip      ,
                               lgdnom      , lgdnum      ,
                               brrnom      , cidnom      ,
                               ufdcod      , lclrefptotxt,
                               lgdcep      , lgdcepcmp   ,
                               dddcod      , lcltelnum   ,
                               horsegsexinc, horsegsexfnl,
                               horsabinc   , horsabfnl   ,
                               hordominc   , hordomfnl   ,
                               atldat      , atlemp      ,
                               atlmat      , arpsitcod   ,
                               arpobs      ) =
                             ( ctc27m00.arpnom      ,
                               ctc27m00.lgdtip      ,
                               ctc27m00.lgdnom      ,
                               ctc27m00.lgdnum      ,
                               ctc27m00.lgdnom      ,
                               ctc27m00.cidnom      ,
                               ctc27m00.ufdcod      ,
                               ctc27m00.lclrefptotxt,
                               ctc27m00.lgdcep      ,
                               ctc27m00.lgdcepcmp   ,
                               ctc27m00.dddcod      ,
                               ctc27m00.lcltelnum   ,
                               ctc27m00.horsegsexinc,
                               ctc27m00.horsegsexfnl,
                               ctc27m00.horsabinc   ,
                               ctc27m00.horsabfnl   ,
                               ctc27m00.hordominc   ,
                               ctc27m00.hordomfnl   ,
                               today                ,
                               g_issk.empcod        ,
                               g_issk.funmat        ,
                               ctc27m00.arpsitcod   ,
                               ctc27m00.arpobs      )
                         where arpcod    = k_ctc27m00.arpcod

    if sqlca.sqlcode <>  0  then
       error " Erro (", sqlca.sqlcode, ") na alteracao do aeroporto. AVISE A INFORMATICA!"
       initialize ctc27m00.*   to null
       initialize k_ctc27m00.* to null
       return k_ctc27m00.*
    end if

    error " Alteracao efetuada com sucesso!"
    clear form
 else
    error " Registro nao localizado!"
 end if

 return k_ctc27m00.*

end function  ###  modifica_ctc27m00

#--------------------------------------------------------------------
 function remove_ctc27m00(k_ctc27m00)
#--------------------------------------------------------------------

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do registro."
              clear form
              initialize ctc27m00.*   to null
              initialize k_ctc27m00.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_ctc27m00(k_ctc27m00.*) returning ctc27m00.*

              if ctc27m00.arpcod is null  then
                 initialize ctc27m00.*   to null
                 initialize k_ctc27m00.* to null
                 error " Registro nao localizado!"
              else
                 delete from datkaeroporto
                  where arpcod = k_ctc27m00.arpcod

                 if sqlca.sqlcode <> 0  then
                    error " Erro (",sqlca.sqlcode,") na exclusao da loja. AVISE A INFORMATICA!"
                    initialize ctc27m00.*   to null
                    initialize k_ctc27m00.* to null
                    return k_ctc27m00.*
                 end if

                 initialize ctc27m00.*   to null
                 initialize k_ctc27m00.* to null
                 error " Registro excluido!"
                 clear form
              end if
              exit menu
   end menu

   return k_ctc27m00.*

end function  ###  remove_ctc27m00

#------------------------------------------------------------
 function inclui_ctc27m00()
#------------------------------------------------------------

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 clear form

 initialize ctc27m00.*   to null
 initialize k_ctc27m00.* to null

 call input_ctc27m00("i",k_ctc27m00.*, ctc27m00.*)
      returning ctc27m00.*, k_ctc27m00.*

 if int_flag  then
    let int_flag = false
    initialize ctc27m00.*  to null
    error " Operacao cancelada!"
    clear form
    return
 end if

 insert into datkaeroporto ( arpcod      , arpnom      ,
                             lgdtip      , lgdnom      ,
                             lgdnum      , brrnom      ,
                             cidnom      , ufdcod      ,
                             lclrefptotxt, lgdcep      ,
                             lgdcepcmp   , dddcod      ,
                             lcltelnum   ,
                             horsegsexinc, horsegsexfnl,
                             horsabinc   , horsabfnl   ,
                             hordominc   , hordomfnl   ,
                             cademp      , cadmat      ,
                             caddat      , atlemp      ,
                             atlmat      , atldat      ,
                             arpsitcod   , arpobs      )
                    values ( ctc27m00.arpcod      ,
                             ctc27m00.arpnom      ,
                             ctc27m00.lgdtip      ,
                             ctc27m00.lgdnom      ,
                             ctc27m00.lgdnum      ,
                             ctc27m00.brrnom      ,
                             ctc27m00.cidnom      ,
                             ctc27m00.ufdcod      ,
                             ctc27m00.lclrefptotxt,
                             ctc27m00.lgdcep      ,
                             ctc27m00.lgdcepcmp   ,
                             ctc27m00.dddcod      ,
                             ctc27m00.lcltelnum   ,
                             ctc27m00.horsegsexinc,
                             ctc27m00.horsegsexfnl,
                             ctc27m00.horsabinc   ,
                             ctc27m00.horsabfnl   ,
                             ctc27m00.hordominc   ,
                             ctc27m00.hordomfnl   ,
                             g_issk.empcod        ,
                             g_issk.funmat        ,
                             today                ,
                             g_issk.empcod        ,
                             g_issk.funmat        ,
                             today                ,
                             ctc27m00.arpsitcod   ,
                             ctc27m00.arpobs      )

 if sqlca.sqlcode <>  0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao do aeroporto. AVISE A INFORMATICA!"
    initialize ctc27m00.*   to null
    initialize k_ctc27m00.* to null
    return k_ctc27m00.*
 end if

 error " Inclusao efetuada com sucesso!"

 clear form

end function  ###  inclui_ctc27m00

#--------------------------------------------------------------------
 function input_ctc27m00(operacao, k_ctc27m00, ctc27m00)
#--------------------------------------------------------------------

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 define operacao   char (01)

 define ws         record
    retflg         char (01),
    hor24h 	   char (01)
 end record

   let int_flag = false

   input by name ctc27m00.arpnom      ,
                 ctc27m00.hor24h      ,
                 ctc27m00.horsegsexinc,
                 ctc27m00.horsegsexfnl,
                 ctc27m00.horsabinc   ,
                 ctc27m00.horsabfnl   ,
                 ctc27m00.hordominc   ,
                 ctc27m00.hordomfnl   ,
                 ctc27m00.arpsitcod   ,
                 ctc27m00.arpobs        without defaults

   before field arpnom
      display by name ctc27m00.arpnom attribute (reverse)

   after  field arpnom
      display by name ctc27m00.arpnom

      if ctc27m00.arpnom is null or
         ctc27m00.arpnom =  "  " then
         error " Nome do aeroporto deve ser informado!"
         next field arpnom
      end if

      call ctc00g00(1,  ### Tipo Endereco = AEROPORTO
                    ctc27m00.cidnom,
                    ctc27m00.ufdcod,
                    ctc27m00.brrnom,
                    ctc27m00.lgdtip,
                    ctc27m00.lgdnom,
                    ctc27m00.lgdnum,
                    ctc27m00.lgdcep,
                    ctc27m00.lgdcepcmp,
                    ctc27m00.lclrefptotxt,
                    ctc27m00.dddcod,
                    ctc27m00.lcltelnum)
          returning ctc27m00.cidnom,
                    ctc27m00.ufdcod,
                    ctc27m00.brrnom,
                    ctc27m00.lgdtip,
                    ctc27m00.lgdnom,
                    ctc27m00.lgdnum,
                    ctc27m00.lgdcep,
                    ctc27m00.lgdcepcmp,
                    ctc27m00.lclrefptotxt,
                    ctc27m00.dddcod,
                    ctc27m00.lcltelnum,
                    ws.retflg

      let ctc27m00.arpend = ctc27m00.lgdtip clipped, " ",
                            ctc27m00.lgdnom clipped, " ",
                            ctc27m00.lgdnum using "<<<<#"

      display by name ctc27m00.arpend
      display by name ctc27m00.brrnom
      display by name ctc27m00.cidnom
      display by name ctc27m00.ufdcod
      display by name ctc27m00.lclrefptotxt
      display by name ctc27m00.lgdcep
      display by name ctc27m00.lgdcepcmp
      display by name ctc27m00.dddcod
      display by name ctc27m00.lcltelnum

      if ws.retflg = "N"  then
         error " Endereco incorreto ou nao padronizado! "
#        next field arpnom
      end if

   before field hor24h
      display by name ctc27m00.hor24h attribute (reverse)

   after  field hor24h
      display by name ctc27m00.hor24h

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if ctc27m00.hor24h is null  then
            error " Funcionamento 24 horas deve ser informado!"
            next field hor24h
         end if

         if ctc27m00.hor24h = "S"  then
            let ctc27m00.horsegsexinc = "00:00"
            let ctc27m00.horsegsexfnl = "23:59"
            let ctc27m00.horsabinc    = "00:00"
            let ctc27m00.horsabfnl    = "23:59"
            let ctc27m00.hordominc    = "00:00"
            let ctc27m00.hordomfnl    = "23:59"

            display by name ctc27m00.hor24h thru ctc27m00.hordomfnl
            next field arpsitcod
         end if

         if ctc27m00.hor24h = "N"  then
         else
            error " Funcionamento 24 horas deve ser (S)im ou (N)ao! "
            next field hor24h
         end if
      end if

   before field horsegsexinc
      display by name ctc27m00.horsegsexinc attribute (reverse)

   after  field horsegsexinc
      display by name ctc27m00.horsegsexinc

   before field horsegsexfnl
      display by name ctc27m00.horsegsexfnl attribute (reverse)

   after  field horsegsexfnl
      display by name ctc27m00.horsegsexfnl

      if ctc27m00.horsegsexinc is null      and
         ctc27m00.horsegsexfnl is not null  then
         error " Horario de funcionamento invalido!"
         next field horsegsexinc
      end if

      if ctc27m00.horsegsexinc is not null  and
         ctc27m00.horsegsexfnl is null      then
         error " Horario de funcionamento invalido!"
         next field horsegsexfnl
      end if

      if ctc27m00.horsegsexinc is not null  and
         ctc27m00.horsegsexfnl is not null  and
         ctc27m00.horsegsexfnl <= ctc27m00.horsegsexinc then
         error " Horario de funcionamento incorreto!"
         next field horsegsexinc
      end if

      if ctc27m00.horsegsexinc <> "00:00"   and
         ctc27m00.horsegsexinc is not null  and
         ctc27m00.horsegsexfnl =  "00:00"   then
         error " Horario de funcionamento incorreto!"
         next field horsegsexinc
      end if

   before field horsabinc
      display by name ctc27m00.horsabinc  attribute (reverse)

   after  field horsabinc
      display by name ctc27m00.horsabinc

   before field horsabfnl
      display by name ctc27m00.horsabfnl  attribute (reverse)

   after  field horsabfnl
      display by name ctc27m00.horsabfnl

      if ctc27m00.horsabinc is null      and
         ctc27m00.horsabfnl is not null  then
         error " Horario de funcionamento invalido!"
         next field horsabinc
      end if

      if ctc27m00.horsabinc is not null  and
         ctc27m00.horsabfnl is null      then
         error " Horario de funcionamento invalido!"
         next field horsabfnl
      end if

      if ctc27m00.horsabinc is not null  and
         ctc27m00.horsabfnl is not null  and
         ctc27m00.horsabfnl <= ctc27m00.horsabinc then
         error " Horario de funcionamento incorreto!"
         next field horsabinc
      end if

      if ctc27m00.horsabinc <> "00:00"   and
         ctc27m00.horsabinc is not null  and
         ctc27m00.horsabfnl =  "00:00"   then
         error " Horario de funcionamento incorreto!"
         next field horsabinc
      end if

   before field hordominc
      display by name ctc27m00.hordominc  attribute (reverse)

   after  field hordominc
      display by name ctc27m00.hordominc

   before field hordomfnl
      display by name ctc27m00.hordomfnl  attribute (reverse)

   after  field hordomfnl
      display by name ctc27m00.hordomfnl

      if ctc27m00.hordominc is null      and
         ctc27m00.hordomfnl is not null  then
         error " Horario de funcionamento invalido!"
         next field hordominc
      end if

      if ctc27m00.hordominc is not null  and
         ctc27m00.hordomfnl is null      then
         error " Horario de funcionamento invalido!"
         next field hordomfnl
      end if

      if ctc27m00.hordominc is not null  and
         ctc27m00.hordomfnl is not null  and
         ctc27m00.hordomfnl <= ctc27m00.hordominc then
         error " Horario de funcionamento incorreto!"
         next field hordominc
      end if

      if ctc27m00.hordominc <> "00:00"   and
         ctc27m00.hordominc is not null  and
         ctc27m00.hordomfnl =  "00:00"   then
         error " Horario de funcionamento incorreto!"
         next field hordominc
      end if

      display by name ctc27m00.arpsitcod  attribute (reverse)

   before field arpsitcod
      if operacao = "i"  then
         let ctc27m00.arpsitcod = 1
         let ctc27m00.arpsitdes = "ATIVO"
         display by name ctc27m00.arpsitcod
         display by name ctc27m00.arpsitdes
         next field arpobs
      else
         display by name ctc27m00.arpsitcod  attribute (reverse)
      end if

   after  field arpsitcod
      display by name ctc27m00.arpsitcod

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         if ctc27m00.hor24h = "S"  then
            next field hor24h
         else
            next field hordomfnl
         end if
      else
         if ctc27m00.arpsitcod is null  then
            error " Situacao deve ser informada!"
            next field arpsitcod
         end if

         case ctc27m00.arpsitcod
            when  1   let ctc27m00.arpsitdes = "ATIVO"
            when  2   let ctc27m00.arpsitdes = "CANCELADO"
            when  3   let ctc27m00.arpsitdes = "INTERDITADO"
            otherwise error " Situacao deve ser: (1)Ativo, (2)Cancelado ou (3)Interditado!"
                      next field arpsitcod
         end case

         display by name ctc27m00.arpsitdes
      end if

   before field arpobs
      if operacao = "i"  then
         let ctc27m00.caddat = today
         let ctc27m00.cademp = g_issk.empcod
         let ctc27m00.cadmat = g_issk.funmat

         call ctc27m00_func(ctc27m00.cademp, ctc27m00.cadmat)
              returning ctc27m00.cadnom
      end if

      let ctc27m00.atldat = today
      let ctc27m00.atlemp = g_issk.empcod
      let ctc27m00.atlmat = g_issk.funmat

      call ctc27m00_func(ctc27m00.atlemp, ctc27m00.atlmat)
           returning ctc27m00.atlnom

      display by name ctc27m00.caddat,
                      ctc27m00.cademp,
                      ctc27m00.cadmat,
                      ctc27m00.cadnom,
                      ctc27m00.atldat,
                      ctc27m00.atlemp,
                      ctc27m00.atlmat,
                      ctc27m00.atlnom

      display by name ctc27m00.arpobs    attribute (reverse)

   after  field arpobs
      display by name ctc27m00.arpobs

      if operacao = "i"  then
         select max(arpcod)
           into ctc27m00.arpcod
           from datkaeroporto

         if ctc27m00.arpcod is null then
            let ctc27m00.arpcod = 0
         end if

         let ctc27m00.arpcod = ctc27m00.arpcod + 1
         display by name ctc27m00.arpcod
      end if

      let k_ctc27m00.arpcod = ctc27m00.arpcod

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc27m00.* , k_ctc27m00.* to null
   end if

   return ctc27m00.* , k_ctc27m00.*

end function  ###  input_ctc27m00

#---------------------------------------------------------
 function sel_ctc27m00(k_ctc27m00)
#---------------------------------------------------------

 define ctc27m00   record
    arpcod         like datkaeroporto.arpcod      ,
    arpnom         like datkaeroporto.arpnom      ,
    arpend         char (65)                      ,
    lgdtip         like datkaeroporto.lgdtip      ,
    lgdnom         like datkaeroporto.lgdnom      ,
    lgdnum         like datkaeroporto.lgdnum      ,
    brrnom         like datkaeroporto.brrnom      ,
    cidnom         like datkaeroporto.cidnom      ,
    ufdcod         like datkaeroporto.ufdcod      ,
    lclrefptotxt   like datkaeroporto.lclrefptotxt,
    lgdcep         like datkaeroporto.lgdcep      ,
    lgdcepcmp      like datkaeroporto.lgdcepcmp   ,
    dddcod         like datkaeroporto.dddcod      ,
    lcltelnum      like datkaeroporto.lcltelnum   ,
    hor24h         char (01)                      ,
    horsegsexinc   like datkaeroporto.horsegsexinc,
    horsegsexfnl   like datkaeroporto.horsegsexfnl,
    horsabinc      like datkaeroporto.horsabinc   ,
    horsabfnl      like datkaeroporto.horsabfnl   ,
    hordominc      like datkaeroporto.hordominc   ,
    hordomfnl      like datkaeroporto.hordomfnl   ,
    arpsitcod      like datkaeroporto.arpsitcod   ,
    arpsitdes      char (12)                      ,
    caddat  	   like datkaeroporto.caddat      ,
    cademp  	   like datkaeroporto.cademp      ,
    cadmat  	   like datkaeroporto.cadmat      ,
    cadnom  	   like isskfunc.funnom           ,
    atldat  	   like datkaeroporto.atldat      ,
    atlemp    	   like datkaeroporto.atlemp      ,
    atlmat     	   like datkaeroporto.atlmat      ,
    atlnom  	   like isskfunc.funnom           ,
    arpobs         like datkaeroporto.arpobs
 end record

 define k_ctc27m00 record
    arpcod         like datkaeroporto.arpcod
 end record

 initialize ctc27m00.*  to null

 select arpcod,
        arpnom,
        lgdtip,
        lgdnom,
        lgdnum,
        brrnom,
        cidnom,
        ufdcod,
        lclrefptotxt,
        lgdcep,
        lgdcepcmp,
        dddcod,
        lcltelnum,
        horsegsexinc,
        horsegsexfnl,
        horsabinc,
        horsabfnl,
        hordominc,
        hordomfnl,
        arpsitcod,
        caddat,
        cademp,
        cadmat,
        atldat,
        atlemp,
        atlmat,
        arpobs
   into ctc27m00.arpcod,
        ctc27m00.arpnom,
        ctc27m00.lgdtip,
        ctc27m00.lgdnom,
        ctc27m00.lgdnum,
        ctc27m00.brrnom,
        ctc27m00.cidnom,
        ctc27m00.ufdcod,
        ctc27m00.lclrefptotxt,
        ctc27m00.lgdcep,
        ctc27m00.lgdcepcmp,
        ctc27m00.dddcod,
        ctc27m00.lcltelnum,
        ctc27m00.horsegsexinc,
        ctc27m00.horsegsexfnl,
        ctc27m00.horsabinc,
        ctc27m00.horsabfnl,
        ctc27m00.hordominc,
        ctc27m00.hordomfnl,
        ctc27m00.arpsitcod,
        ctc27m00.caddat,
        ctc27m00.cademp,
        ctc27m00.cadmat,
        ctc27m00.atldat,
        ctc27m00.atlemp,
        ctc27m00.atlmat,
        ctc27m00.arpobs
   from datkaeroporto
  where arpcod = k_ctc27m00.arpcod

 if sqlca.sqlcode <> 0  then
    initialize k_ctc27m00.*  to null
    initialize ctc27m00.*    to null
 else
    if ctc27m00.horsegsexinc = "00:00"  and
       ctc27m00.horsegsexfnl = "23:59"  and
       ctc27m00.horsabinc    = "00:00"  and
       ctc27m00.horsabfnl    = "23:59"  and
       ctc27m00.hordominc    = "00:00"  and
       ctc27m00.hordomfnl    = "23:59"  then
       let ctc27m00.hor24h = "S"
    else
       let ctc27m00.hor24h = "N"
    end if

    if ctc27m00.arpsitcod = 1  then
       let ctc27m00.arpsitdes = "ATIVO"
    else
       if ctc27m00.arpsitcod = 2  then
          let ctc27m00.arpsitdes = "CANCELADO"
       else
          let ctc27m00.arpsitdes = "INTERDITADO"
       end if
    end if

    let ctc27m00.arpend = ctc27m00.lgdtip clipped, " ",
                          ctc27m00.lgdnom clipped, " ",
                          ctc27m00.lgdnum using "<<<<#"

    call ctc27m00_func(ctc27m00.cademp, ctc27m00.cadmat)
         returning ctc27m00.cadnom

    call ctc27m00_func(ctc27m00.atlemp, ctc27m00.atlmat)
         returning ctc27m00.atlnom
 end if

 return ctc27m00.*

end function  ###  sel_ctc27m00

#---------------------------------------------------------
 function ctc27m00_func(k_ctc27m00)
#---------------------------------------------------------

 define k_ctc27m00 record
    empcod         like isskfunc.empcod ,
    funmat         like isskfunc.funmat
 end record

 define ws         record
    funnom         like isskfunc.funnom
 end record

 let ws.funnom = "NAO CADASTRADO!"

 select funnom
   into ws.funnom
   from isskfunc
  where empcod = k_ctc27m00.empcod  and
        funmat = k_ctc27m00.funmat

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  ctc27m00_func
