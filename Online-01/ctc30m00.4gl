#############################################################################
# Nome do Modulo: CTC30M00                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao no Cadastro de Locadoras de Veiculos                  Ago/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/11/1998  PSI 7056-4   Gilberto     Gravar informacoes referentes ao    #
#                                       cadastramento e atualizacao.        #
#---------------------------------------------------------------------------#
# 20/07/1999  PSI 8644-4   Wagner       Incluir o campo Cheque caucao no    #
#                                       cadastramento e atualizacao.        #
#---------------------------------------------------------------------------#
# 26/07/1999  PSI 8645-2   Wagner       Incluir o campo Taxa de Seguro no   #
#                                       cadastramento e atualizacao.        #
#---------------------------------------------------------------------------#
# 15/08/2000  PSI 11275-5  Wagner       Inibir manutencao no campo cauchqflg#
#                                       Cheque caucao.                      #
#---------------------------------------------------------------------------#
# 13/02/2006  PSI 198390   Priscila     Incluir campo Taxa 2Condutor        #
#---------------------------------------------------------------------------#
# 02/03/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
#############################################################################
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 22/06/2006 Andrei, Meta  PSI196878 Incluir campos email e tipo de acionamen#
#                                    to                                      #
#----------------------------------------------------------------------------#
# 05/08/2008 Diomar,Meta   PSI226300 Incluido gravacao do historico          #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctc30m00()
#------------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
    lcvextcod    like datkavislocal.lcvextcod  ,
    aviestnom    like datkavislocal.aviestnom  ,
    pgtcrncod    like datklocadora.pgtcrncod   ,
    crnpgtdes    like dbsmcrnpgt.crnpgtdes
 end record

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

   define l_aux char(19)

   let l_aux = null

 if not get_niv_mod(g_issk.prgsgl, "ctc30m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc30m00 at 04,02 with form "ctc30m00"

   let int_flag = false

   initialize ctc30m00.*   to  null
   initialize k_ctc30m00.* to  null

   menu "LOCADORAS"
       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then
                show option "Seleciona", "Proximo", "Anterior"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Inclui"
          end if

          show option "Encerra"
          show option 'Historico'

   command "Seleciona" "Pesquisa tabela conforme criterios"
            call seleciona_ctc30m00() returning k_ctc30m00.*
            if k_ctc30m00.lcvcod is not null  then
               next option "Proximo"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proximo registro selecionado"
            if k_ctc30m00.lcvcod is not null then
               call proximo_ctc30m00(k_ctc30m00.*) returning k_ctc30m00.*
            else
               error " Nao ha' mais registros nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra registro anterior selecionado"
            if k_ctc30m00.lcvcod is not null then
               call anterior_ctc30m00(k_ctc30m00.*) returning k_ctc30m00.*
            else
               error " Nao ha' mais registros nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica registro corrente selecionado"
            if k_ctc30m00.lcvcod is not null then
               call modifica_ctc30m00(k_ctc30m00.*) returning k_ctc30m00.*
               next option "Seleciona"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

 # command "Remove" "Remove registro corrente selecionado"
 #          message ""
 #          if k_ctc30m00.aviestcod is not null then
 #             call remove_ctc30m00(k_ctc30m00.*)
 #                  returning k_ctc30m00.*
 #             next option "Seleciona"
 #          else
 #             error " Nenhum registro selecionado!"
 #             next option "Seleciona"
 #          end if

   command "Inclui" "Inclui registro na tabela"
            message ""
            call inclui_ctc30m00()
            next option "Seleciona"

   command 'Historico' 'Consulta o historico'
      if k_ctc30m00.lcvcod is not null then
         let l_aux = 'Locadora de Veiculo'

	 select datklocadora.lcvnom
	    into ctc30m00.lcvnom
	  from datklocadora
	  where datklocadora.lcvcod = k_ctc30m00.lcvcod

         call ctb85g00(2
                      ,l_aux
                      ,k_ctc30m00.lcvcod
                      ,ctc30m00.lcvnom)
      else
         error " Nenhum registro selecionado!"
         next option "Seleciona"
      end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctc30m00

end function  ###  ctc30m00

#------------------------------------------------------------
 function seleciona_ctc30m00()
#------------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
    lcvextcod    like datkavislocal.lcvextcod  ,
    aviestnom    like datkavislocal.aviestnom  ,
    pgtcrncod    like datklocadora.pgtcrncod   ,
    crnpgtdes    like dbsmcrnpgt.crnpgtdes
 end record

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

   clear form

   let int_flag = false

   input by name k_ctc30m00.lcvcod

      before field lcvcod
          display by name k_ctc30m00.lcvcod attribute (reverse)

      after  field lcvcod
          display by name k_ctc30m00.lcvcod

          if k_ctc30m00.lcvcod is null  or
             k_ctc30m00.lcvcod     = 0  then
             let k_ctc30m00.lcvcod = 0
          else
             call sel_ctc30m00 (k_ctc30m00.*) returning ctc30m00.*

             if ctc30m00.lcvcod is null  then
                error " Locadora nao cadastrada!"
                call ctc30m01() returning k_ctc30m00.lcvcod
                next field lcvcod
             end if
          end if

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctc30m00.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctc30m00.*
   end if

   if k_ctc30m00.lcvcod = 0 then
      select min (datklocadora.lcvcod)
        into k_ctc30m00.lcvcod
        from datklocadora
       where datklocadora.lcvcod > 0

      call sel_ctc30m00 (k_ctc30m00.*) returning ctc30m00.*
   end if

   call ctc30m00_func(ctc30m00.cademp, ctc30m00.cadmat)
        returning ctc30m00.cadnom

   call ctc30m00_func(ctc30m00.atlemp, ctc30m00.atlmat)
        returning ctc30m00.atlnom

   display by name ctc30m00.lcvcod ,
                   ctc30m00.lcvnom ,
                   ctc30m00.lgdnom ,
                   ctc30m00.brrnom ,
                   ctc30m00.cidnom ,
                   ctc30m00.endufd ,
                   ctc30m00.dddcod ,
                   ctc30m00.teltxt ,
                   ctc30m00.facnum ,
                   ctc30m00.cgccpfnum ,
                   ctc30m00.cgcord    ,
                   ctc30m00.cgccpfdig ,
                   ctc30m00.lcvresenvcod ,
                   ctc30m00.envdsc       ,
                   ctc30m00.lcvstt       ,
                   ctc30m00.lcvsttdes ,
                   ctc30m00.acntip,
                   ctc30m00.acndes,
                   ctc30m00.maides,
                   ctc30m00.caddat    ,
                   ctc30m00.cademp    ,
                   ctc30m00.cadmat    ,
                   ctc30m00.cadnom    ,
                   ctc30m00.atldat    ,
                   ctc30m00.atlemp    ,
                   ctc30m00.atlmat    ,
                   ctc30m00.atlnom    ,
                   ctc30m00.adcsgrtaxvlr,
                   ctc30m00.cdtsegtaxvlr,
                   ctc30m00.lcvextcod,
                   ctc30m00.aviestnom,
                   ctc30m00.pgtcrncod,
                   ctc30m00.crnpgtdes

   return k_ctc30m00.*

end function  ###  seleciona_ctc30m00

#------------------------------------------------------------
 function proximo_ctc30m00(k_ctc30m00)
#------------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
    lcvextcod    like datkavislocal.lcvextcod  ,
    aviestnom    like datkavislocal.aviestnom  ,
    pgtcrncod    like datklocadora.pgtcrncod   ,
    crnpgtdes    like dbsmcrnpgt.crnpgtdes
 end record

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

 let int_flag = false

 select min (datklocadora.lcvcod)
   into ctc30m00.lcvcod
   from datklocadora
  where datklocadora.lcvcod > k_ctc30m00.lcvcod

 if ctc30m00.lcvcod is null  then
    error " Nao ha' mais registros nesta direcao!"
 else
    let k_ctc30m00.lcvcod = ctc30m00.lcvcod

    call sel_ctc30m00 (k_ctc30m00.*) returning ctc30m00.*

    if ctc30m00.lcvcod is not null  then
       call ctc30m00_func(ctc30m00.cademp, ctc30m00.cadmat)
            returning ctc30m00.cadnom

       call ctc30m00_func(ctc30m00.atlemp, ctc30m00.atlmat)
            returning ctc30m00.atlnom

       display by name ctc30m00.lcvcod ,
                       ctc30m00.lcvnom ,
                       ctc30m00.lgdnom ,
                       ctc30m00.brrnom ,
                       ctc30m00.cidnom ,
                       ctc30m00.endufd ,
                       ctc30m00.dddcod ,
                       ctc30m00.teltxt ,
                       ctc30m00.facnum ,
                       ctc30m00.cgccpfnum ,
                       ctc30m00.cgcord    ,
                       ctc30m00.cgccpfdig ,
                       ctc30m00.lcvresenvcod ,
                       ctc30m00.envdsc       ,
                       ctc30m00.lcvstt       ,
                       ctc30m00.lcvsttdes ,
                       ctc30m00.acntip    ,
                       ctc30m00.acndes    ,
                       ctc30m00.maides    ,
                       ctc30m00.caddat    ,
                       ctc30m00.cademp    ,
                       ctc30m00.cadmat    ,
                       ctc30m00.cadnom    ,
                       ctc30m00.atldat    ,
                       ctc30m00.atlemp    ,
                       ctc30m00.atlmat    ,
                       ctc30m00.atlnom    ,
                       ctc30m00.adcsgrtaxvlr,
                       ctc30m00.cdtsegtaxvlr,
                       ctc30m00.lcvextcod,
                       ctc30m00.aviestnom,
                       ctc30m00.pgtcrncod,
                       ctc30m00.crnpgtdes
    else
       initialize ctc30m00.*    to null
    end if
 end if

 return k_ctc30m00.*

end function  ###  proximo_ctc30m00

#------------------------------------------------------------
 function anterior_ctc30m00(k_ctc30m00)
#------------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
    lcvextcod    like datkavislocal.lcvextcod  ,
    aviestnom    like datkavislocal.aviestnom  ,
    pgtcrncod    like datklocadora.pgtcrncod   ,
    crnpgtdes    like dbsmcrnpgt.crnpgtdes
 end record

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

 let int_flag = false

 select max (datklocadora.lcvcod)
   into ctc30m00.lcvcod
   from datklocadora
  where datklocadora.lcvcod < k_ctc30m00.lcvcod

 if ctc30m00.lcvcod is null  then
    error " Nao ha' mais registros nesta direcao!"
 else
    let k_ctc30m00.lcvcod = ctc30m00.lcvcod

    call sel_ctc30m00 (k_ctc30m00.*) returning ctc30m00.*

    if ctc30m00.lcvcod is not null  then
       call ctc30m00_func(ctc30m00.cademp, ctc30m00.cadmat)
            returning ctc30m00.cadnom

       call ctc30m00_func(ctc30m00.atlemp, ctc30m00.atlmat)
            returning ctc30m00.atlnom

       display by name ctc30m00.lcvcod ,
                       ctc30m00.lcvnom ,
                       ctc30m00.lgdnom ,
                       ctc30m00.brrnom ,
                       ctc30m00.cidnom ,
                       ctc30m00.endufd ,
                       ctc30m00.dddcod ,
                       ctc30m00.teltxt ,
                       ctc30m00.facnum ,
                       ctc30m00.cgccpfnum ,
                       ctc30m00.cgcord    ,
                       ctc30m00.cgccpfdig ,
                       ctc30m00.lcvresenvcod ,
                       ctc30m00.envdsc    ,
                       ctc30m00.lcvstt    ,
                       ctc30m00.lcvsttdes ,
                       ctc30m00.acntip    ,
                       ctc30m00.acndes    ,
                       ctc30m00.maides    ,
                       ctc30m00.caddat    ,
                       ctc30m00.cademp    ,
                       ctc30m00.cadmat    ,
                       ctc30m00.cadnom    ,
                       ctc30m00.atldat    ,
                       ctc30m00.atlemp    ,
                       ctc30m00.atlmat    ,
                       ctc30m00.atlnom    ,
                       ctc30m00.adcsgrtaxvlr,
                       ctc30m00.cdtsegtaxvlr,
                       ctc30m00.lcvextcod,
                       ctc30m00.aviestnom,
                       ctc30m00.pgtcrncod,
                       ctc30m00.crnpgtdes
    else
       initialize ctc30m00.*    to null
    end if
 end if

 return k_ctc30m00.*

end function  ###  anterior_ctc30m00

#------------------------------------------------------------
 function modifica_ctc30m00(k_ctc30m00)
#------------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
    lcvextcod    like datkavislocal.lcvextcod  ,
    aviestnom    like datkavislocal.aviestnom  ,
    pgtcrncod    like datklocadora.pgtcrncod   ,
    crnpgtdes    like dbsmcrnpgt.crnpgtdes
 end record

 define lr_ctc30m00_ant record
    lcvnom         like datklocadora.lcvnom
   ,lgdnom         like datklocadora.lgdnom
   ,brrnom         like datklocadora.brrnom
   ,cidnom         like datklocadora.cidnom
   ,endufd         like datklocadora.endufd
   ,dddcod         like datklocadora.dddcod
   ,teltxt         like datklocadora.teltxt
   ,facnum         like datklocadora.facnum
   ,cgccpfnum      like datklocadora.cgccpfnum
   ,cgcord         like datklocadora.cgcord
   ,cgccpfdig      like datklocadora.cgccpfdig
   ,lcvstt         like datklocadora.lcvstt
   ,lcvsttdes      char (10)
   ,lcvresenvcod   like datklocadora.lcvresenvcod
   ,atldat         like datklocadora.atldat
   ,atlemp         like datklocadora.atlemp
   ,atlmat         like datklocadora.atlmat
   ,adcsgrtaxvlr   like datklocadora.adcsgrtaxvlr
   ,cdtsegtaxvlr   like datklocadora.cdtsegtaxvlr
   ,acntip         like datklocadora.acntip
   ,maides         like datklocadora.maides
   ,lcvextcod      like datkavislocal.lcvextcod
   ,pgtcrncod      like datklocadora.pgtcrncod
 end record

 define l_salva_lcvstt like datklocadora.lcvstt

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

 define l_ant_lcvsttdes char(20),
        l_lcvsttdes     char(20),
        l_msg           char(1000)
       ,l_mensagem      char(60)
       ,l_mensagem2     char(60)

 define l_data    date,
        l_hora2   datetime hour to minute

 call sel_ctc30m00 (k_ctc30m00.*) returning ctc30m00.*

 let l_ant_lcvsttdes = null
 let l_lcvsttdes     = null
 let l_salva_lcvstt  = null
 let l_msg           = null
 let l_mensagem      = null
 let l_mensagem2     = null

 initialize lr_ctc30m00_ant to null

 let lr_ctc30m00_ant.lcvnom       = ctc30m00.lcvnom
 let lr_ctc30m00_ant.lgdnom       = ctc30m00.lgdnom
 let lr_ctc30m00_ant.brrnom       = ctc30m00.brrnom
 let lr_ctc30m00_ant.cidnom       = ctc30m00.cidnom
 let lr_ctc30m00_ant.endufd       = ctc30m00.endufd
 let lr_ctc30m00_ant.dddcod       = ctc30m00.dddcod
 let lr_ctc30m00_ant.teltxt       = ctc30m00.teltxt
 let lr_ctc30m00_ant.facnum       = ctc30m00.facnum
 let lr_ctc30m00_ant.cgccpfnum    = ctc30m00.cgccpfnum
 let lr_ctc30m00_ant.cgcord       = ctc30m00.cgcord
 let lr_ctc30m00_ant.cgccpfdig    = ctc30m00.cgccpfdig
 let lr_ctc30m00_ant.lcvstt       = ctc30m00.lcvstt
 let lr_ctc30m00_ant.lcvsttdes     = ctc30m00.lcvsttdes
 let lr_ctc30m00_ant.lcvresenvcod = ctc30m00.lcvresenvcod
 let lr_ctc30m00_ant.atldat       = ctc30m00.atldat
 let lr_ctc30m00_ant.atlemp       = ctc30m00.atlemp
 let lr_ctc30m00_ant.atlmat       = ctc30m00.atlmat
 let lr_ctc30m00_ant.adcsgrtaxvlr = ctc30m00.adcsgrtaxvlr
 let lr_ctc30m00_ant.cdtsegtaxvlr = ctc30m00.cdtsegtaxvlr
 let lr_ctc30m00_ant.acntip       = ctc30m00.acntip
 let lr_ctc30m00_ant.maides       = ctc30m00.maides
 let lr_ctc30m00_ant.lcvextcod    = ctc30m00.lcvextcod
 let lr_ctc30m00_ant.pgtcrncod    = ctc30m00.pgtcrncod


 if ctc30m00.lcvcod is not null  then

    #----------------------------------
    # SALVA A SITUACAO DA LOCADORA
    #----------------------------------
    let l_salva_lcvstt = ctc30m00.lcvstt

    call input_ctc30m00("a", k_ctc30m00.* , ctc30m00.*) returning ctc30m00.*  ,
                                                                 k_ctc30m00.*

    if int_flag  then
       let int_flag = false
       initialize ctc30m00.*  to null
       error " Operacao cancelada!"
       clear form
       return k_ctc30m00.*
    end if

    call cts40g03_data_hora_banco(2)
         returning l_data, l_hora2

    #Remove caracteres especiais

    call ctc30m00_remove_caracteres(ctc30m00.lcvnom)
         returning ctc30m00.lcvnom

    call ctc30m00_remove_caracteres(ctc30m00.lgdnom)
         returning ctc30m00.lgdnom

    call ctc30m00_remove_caracteres(ctc30m00.brrnom)
         returning ctc30m00.brrnom

    call ctc30m00_remove_caracteres(ctc30m00.cidnom)
         returning ctc30m00.cidnom


    update datklocadora set ( lcvnom, lgdnom, brrnom,
                              cidnom, endufd, dddcod,
                              teltxt, facnum, cgccpfnum,
                              cgcord, cgccpfdig, lcvstt,
                              lcvresenvcod, atldat, atlemp,
                              atlmat, adcsgrtaxvlr, cdtsegtaxvlr,acntip ,
                              maides,fvrlojcod,pgtcrncod )
                          = ( ctc30m00.lcvnom,
                              ctc30m00.lgdnom,
                              ctc30m00.brrnom,
                              ctc30m00.cidnom,
                              ctc30m00.endufd,
                              ctc30m00.dddcod,
                              ctc30m00.teltxt,
                              ctc30m00.facnum,
                              ctc30m00.cgccpfnum,
                              ctc30m00.cgcord,
                              ctc30m00.cgccpfdig,
                              ctc30m00.lcvstt,
                              ctc30m00.lcvresenvcod,
                              l_data,
                              g_issk.empcod,
                              g_issk.funmat,
                              ctc30m00.adcsgrtaxvlr,
                              ctc30m00.cdtsegtaxvlr,
                              ctc30m00.acntip,
                              ctc30m00.maides,
                              ctc30m00.lcvextcod,
                              ctc30m00.pgtcrncod)
                        where lcvcod = k_ctc30m00.lcvcod

    if sqlca.sqlcode <>  0  then
       error " Erro (", sqlca.sqlcode, ") na alteracao do registro. AVISE A INFORMATICA!"
       initialize ctc30m00.*   to null
       initialize k_ctc30m00.* to null
       return k_ctc30m00.*
    else
       #-------------------------------------------------------------
       # SE O DEPARTAMENTO FOR CT24HS ENVIA E-MAIL PARA PORTO SOCORRO
       #-------------------------------------------------------------
       if g_issk.dptsgl = "ct24hs" or
          g_issk.dptsgl = "dsvatd" or
          g_issk.dptsgl = "tlprod" then
          if l_salva_lcvstt <> ctc30m00.lcvstt then

             case l_salva_lcvstt
                when "A" let l_ant_lcvsttdes = "ATIVA"
                when "C" let l_ant_lcvsttdes = "CANCELADA"
             end case

             case ctc30m00.lcvstt
                when "A" let l_lcvsttdes     = "ATIVA"
                when "C" let l_lcvsttdes     = "CANCELADA"
             end case

             let l_msg = "Locadora.........: ",
                         k_ctc30m00.lcvcod using "<<<<&" , " - ",
                         ctc30m00.lcvnom clipped, ascii(13),
                        "Situacao anterior: ", l_ant_lcvsttdes clipped, ascii(13),
                        "Mudou para.......: ", l_lcvsttdes

             call cts20g08("LOCADORAS",   # NOME DO CADASTRO
                           "Modificacao",   # TIPO DA OPERACAO
                           "CTC30M00",    # NOME DO 4GL
                           g_issk.empcod,
                           g_issk.usrtip,
                           g_issk.funmat,
                           l_msg)
          end if
       end if

       error " Alteracao efetuada com sucesso!"

       call ctc30m00_verifica_mod(lr_ctc30m00_ant.*
                                 ,ctc30m00.*)

    end if
 else
    error " Registro nao localizado!"
 end if

 initialize k_ctc30m00 to null
 clear form
 return k_ctc30m00.*

end function  ###  modifica_ctc30m00

#--------------------------------------------------------------------
 function remove_ctc30m00(k_ctc30m00)
#--------------------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr
 end record

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

 define l_mensagem  char(100)
       ,l_mensagem2 char(100)
       ,l_stt       smallint

   let l_stt = null


   menu "Confirma Exclusao ?"

      command "Nao" "Cancela exclusao do registro."
              clear form
              initialize ctc30m00.*   to null
              initialize k_ctc30m00.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_ctc30m00(k_ctc30m00.*) returning ctc30m00.*

              if ctc30m00.lcvcod is null  then
                 initialize ctc30m00.*   to null
                 initialize k_ctc30m00.* to null
                 error " Registro nao localizado!"
              else
                 delete from datklocadora
                  where lcvcod = k_ctc30m00.lcvcod

                 if sqlca.sqlcode <> 0 then
                    error " Erro (", sqlca.sqlcode, ") na exclusao do registro. AVISE A INFORMATICA!"
                    initialize ctc30m00.*   to null
                    initialize k_ctc30m00.* to null
                    return k_ctc30m00.*
                 end if

                 initialize ctc30m00.*   to null
                 initialize k_ctc30m00.* to null
                 error " Registro excluido!"
                 clear form

                 let l_mensagem  = "Locadora do veiculo [",k_ctc30m00.lcvcod,"] Excluido !"
                 let l_mensagem2 = 'Delecao no cadastro de locadora veiculos'

                 let l_stt = ctc30m00_grava_hist(k_ctc30m00.lcvcod
                                                ,l_mensagem
                                                ,ctc30m00.caddat
                                                ,l_mensagem2,"I")
              end if
              exit menu
   end menu

   return k_ctc30m00.*

end function  ###  remove_ctc30m00

#------------------------------------------------------------
 function inclui_ctc30m00()
#------------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
    lcvextcod    like datkavislocal.lcvextcod  ,
    aviestnom    like datkavislocal.aviestnom  ,
    pgtcrncod    like datklocadora.pgtcrncod   ,
    crnpgtdes    like dbsmcrnpgt.crnpgtdes
 end record

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

 define l_data      date,
        l_hora2     datetime hour to minute
       ,l_mensagem  char(100)
       ,l_mensagem2 char(100)
       ,l_stt       smallint

   clear form

   let l_stt = null

   initialize ctc30m00.*   to null
   initialize k_ctc30m00.* to null

   call input_ctc30m00("i",k_ctc30m00.*, ctc30m00.*) returning ctc30m00.* ,
                                                               k_ctc30m00.*

   if int_flag  then
      let int_flag = false
      initialize ctc30m00.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora2

   #Remove os caracteres especiais antes de cadastrar
   call ctc30m00_remove_caracteres(ctc30m00.lcvnom)
         returning ctc30m00.lcvnom

   call ctc30m00_remove_caracteres(ctc30m00.lgdnom)
         returning ctc30m00.lgdnom

   call ctc30m00_remove_caracteres(ctc30m00.cidnom)
         returning ctc30m00.cidnom

   call ctc30m00_remove_caracteres(ctc30m00.brrnom)
         returning ctc30m00.brrnom


   insert into datklocadora ( lcvcod,    lcvnom,
                              lgdnom,    brrnom,
                              cidnom,    endufd,
                              dddcod,    teltxt,
                              facnum,    cgccpfnum,
                              cgcord,    cgccpfdig,
                              lcvstt,    lcvresenvcod,
                              caddat,    cademp,
                              cadmat,    atldat,
                              atlemp,    atlmat,
                              adcsgrtaxvlr, cdtsegtaxvlr, acntip,
                              maides,fvrlojcod,pgtcrncod)
                     values ( ctc30m00.lcvcod ,
                              ctc30m00.lcvnom ,
                              ctc30m00.lgdnom ,
                              ctc30m00.brrnom ,
                              ctc30m00.cidnom ,
                              ctc30m00.endufd ,
                              ctc30m00.dddcod ,
                              ctc30m00.teltxt ,
                              ctc30m00.facnum ,
                              ctc30m00.cgccpfnum ,
                              ctc30m00.cgcord    ,
                              ctc30m00.cgccpfdig ,
                              ctc30m00.lcvstt    ,
                              ctc30m00.lcvresenvcod,
                              l_data, g_issk.empcod, g_issk.funmat,
                              l_data, g_issk.empcod, g_issk.funmat,
                              ctc30m00.adcsgrtaxvlr,
                              ctc30m00.cdtsegtaxvlr,
                              ctc30m00.acntip,
                              ctc30m00.maides,ctc30m00.lcvextcod,ctc30m00.pgtcrncod)

   if sqlca.sqlcode <>  0  then
      error " Erro (", sqlca.sqlcode, ") na inclusao do registro. AVISE A INFORMATICA!"
      return
   end if

   error " Inclusao efetuada com sucesso!"


   let l_mensagem  = "locadora do veiculo [",ctc30m00.lcvcod, "] Incluido !"
   let l_mensagem2 = 'Inclusao no cadastro de locadora veiculos'

   let l_stt = ctc30m00_grava_hist(ctc30m00.lcvcod
                                  ,l_mensagem
                                  ,l_data
                                  ,l_mensagem2,"I")
   clear form

end function  ###  inclui_ctc30m00

#--------------------------------------------------------------------
 function input_ctc30m00(operacao, k_ctc30m00, ctc30m00)
#--------------------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
    lcvextcod    like datkavislocal.lcvextcod  ,
    aviestnom    like datkavislocal.aviestnom  ,
    pgtcrncod    like datklocadora.pgtcrncod   ,
    crnpgtdes    like dbsmcrnpgt.crnpgtdes
 end record

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

 define cgc_digit dec(2,0)
 define operacao  char(01)
 define l_achou   smallint

   let int_flag = false
   let l_achou = 0

   input by name ctc30m00.lcvnom ,
                 ctc30m00.lgdnom ,
                 ctc30m00.brrnom ,
                 ctc30m00.cidnom ,
                 ctc30m00.endufd ,
                 ctc30m00.dddcod ,
                 ctc30m00.teltxt ,
                 ctc30m00.facnum ,
                 ctc30m00.adcsgrtaxvlr,
                 ctc30m00.cdtsegtaxvlr,
                 ctc30m00.cgccpfnum ,
                 ctc30m00.cgcord    ,
                 ctc30m00.cgccpfdig ,
                 ctc30m00.lcvresenvcod,
                 ctc30m00.lcvstt,
                 ctc30m00.acntip,
                 ctc30m00.maides,
                 ctc30m00.lcvextcod,
                 ctc30m00.pgtcrncod        without defaults

   before field lcvnom
       if operacao = "i" then
          select max(lcvcod)
            into k_ctc30m00.lcvcod
            from datklocadora

          if k_ctc30m00.lcvcod is null then
             let k_ctc30m00.lcvcod = 0
          end if

         let k_ctc30m00.lcvcod = k_ctc30m00.lcvcod + 1
         let ctc30m00.lcvcod = k_ctc30m00.lcvcod
      end if

      display by name ctc30m00.lcvcod
      display by name ctc30m00.lcvnom attribute (reverse)

   after  field lcvnom
      display by name ctc30m00.lcvnom

      if ctc30m00.lcvnom is null or
         ctc30m00.lcvnom =  "  " then
         error " Razao Social da locadora deve ser informado!"
         next field lcvnom
      end if

   before field lgdnom
       display by name ctc30m00.lgdnom attribute (reverse)

   after  field lgdnom
       display by name ctc30m00.lgdnom

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.lgdnom is null or
             ctc30m00.lgdnom =  "  " then
             error " Endereco da locadora deve ser informado!"
             next field lgdnom
          end if
       end if

   before field brrnom
       display by name ctc30m00.brrnom attribute (reverse)

   after  field brrnom
       display by name ctc30m00.brrnom

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.brrnom is null or
             ctc30m00.brrnom =  "  " then
             error " Bairro deve ser informado!"
             next field brrnom
          end if
       end if

   before field cidnom
       display by name ctc30m00.cidnom attribute (reverse)

   after  field cidnom
       display by name ctc30m00.cidnom

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.cidnom is null or
             ctc30m00.cidnom =  "  " then
             error " Cidade deve ser informado!"
             next field cidnom
          end if
       end if

   before field endufd
       display by name ctc30m00.endufd attribute (reverse)

   after  field endufd
       display by name ctc30m00.endufd

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then

          if ctc30m00.endufd is null  then
             error " Unidade Federativa deve ser informada!"
             next field endufd
          end if

          select ufdcod
            from glakest
           where glakest.ufdcod = ctc30m00.endufd

          if sqlca.sqlcode = NOTFOUND  then
             error " Unidade Federativa nao cadastrada!"
             next field endufd
          end if
       end if

   before field dddcod
       display by name ctc30m00.dddcod attribute (reverse)

   after  field dddcod
       display by name ctc30m00.dddcod

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.dddcod is null or
             ctc30m00.dddcod =  "  " then
             error " Codigo do DDD deve ser informado!"
             next field dddcod
          end if
       end if

   before field teltxt
       display by name ctc30m00.teltxt attribute (reverse)

   after  field teltxt
       display by name ctc30m00.teltxt

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.teltxt is null or
             ctc30m00.teltxt =  "  " then
             error " Telefone deve ser informado!"
             next field teltxt
          end if
       end if

   before field facnum
       display by name ctc30m00.facnum attribute (reverse)

   after  field facnum
       display by name ctc30m00.facnum

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.facnum is null or
             ctc30m00.facnum =  0    then
             error " Numero do Fax deve ser informado!"
             next field facnum
          end if
       end if

   before field adcsgrtaxvlr
       display by name ctc30m00.adcsgrtaxvlr attribute (reverse)

   after  field adcsgrtaxvlr
       display by name ctc30m00.adcsgrtaxvlr

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.adcsgrtaxvlr is null then
             error " Taxa seguro optativo para locacao deve ser informado!"
             next field adcsgrtaxvlr
          end if
       end if

   before field cdtsegtaxvlr
       display by name ctc30m00.cdtsegtaxvlr attribute (reverse)

   after  field cdtsegtaxvlr
       display by name ctc30m00.cdtsegtaxvlr

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.cdtsegtaxvlr is null then
             error " Taxa segundo condutor para locacao deve ser informado!"
             next field cdtsegtaxvlr
          end if
       end if

   before field cgccpfnum
       display by name ctc30m00.cgccpfnum attribute (reverse)

   after  field cgccpfnum
       display by name ctc30m00.cgccpfnum

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.cgccpfnum is null or
             ctc30m00.cgccpfnum =  0    then
             error " Numero do CGC deve ser informado!"
             next field cgccpfnum
          end if
       end if

   before field cgcord
       display by name ctc30m00.cgcord    attribute (reverse)

   after  field cgcord
       display by name ctc30m00.cgcord

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.cgcord    is null or
             ctc30m00.cgcord    =  0    then
             error " Ordem do CGC deve ser informado!"
             next field cgcord
          end if
       end if

   before field cgccpfdig
       display by name ctc30m00.cgccpfdig attribute (reverse)

   after  field cgccpfdig
       display by name ctc30m00.cgccpfdig

       if ctc30m00.cgccpfdig is null  then
          error " Digito do CGC deve ser informado!"
          next field cgccpfdig
       end if

       call F_FUNDIGIT_DIGITOCGC(ctc30m00.cgccpfnum, ctc30m00.cgcord)
            returning cgc_digit

       if cgc_digit          is null      or
          ctc30m00.cgccpfdig <> cgc_digit then
          error " Digito incorreto!"
          next field cgccpfnum
       end if

   before field lcvresenvcod
       display by name ctc30m00.lcvresenvcod attribute (reverse)

   after  field lcvresenvcod
       display by name ctc30m00.lcvresenvcod

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.lcvresenvcod is null then
             error " Informe (1)Central de Reservas ou (2)Loja !"
             next field lcvresenvcod
          else
             case ctc30m00.lcvresenvcod
                when 1 let ctc30m00.envdsc = "Central Reservas"
                when 2 let ctc30m00.envdsc = "Loja"
                otherwise
                   error " Informe (1)Central de Reservas ou (2)Loja !"
                   next field lcvresenvcod
             end case
             display by name ctc30m00.envdsc
          end if
       end if

   before field lcvstt
       if operacao = "i"  then
          let ctc30m00.lcvstt = "A"
          exit input
       else
          display by name ctc30m00.lcvstt attribute (reverse)
       end if

   after  field lcvstt
       display by name ctc30m00.lcvstt

       if fgl_lastkey() <> fgl_keyval("up")   and
          fgl_lastkey() <> fgl_keyval("left") then
          if ctc30m00.lcvstt is null  then
             error " Informe a situacao: (A)tiva ou (C)ancelada!"
             next field lcvstt
          else
             case ctc30m00.lcvstt
                when "A" let ctc30m00.lcvsttdes = "ATIVA"
                when "C" let ctc30m00.lcvsttdes = "CANCELADA"
                otherwise
                   error " Informe a situacao: (A)tiva ou (C)ancelada!"
                   next field lcvstt
             end case
             display by name ctc30m00.lcvsttdes
          end if
       end if

    before field acntip
       display by name ctc30m00.acntip attribute (reverse)

    after field acntip
       display by name ctc30m00.acntip
       if fgl_lastkey() = fgl_keyval("up")   and
          fgl_lastkey() = fgl_keyval("left") then
          next field lcvstt
       end if

       if ctc30m00.acntip is not null and
          ctc30m00.acntip <> 1        and
          ctc30m00.acntip <> 2        and 
          ctc30m00.acntip <> 3        then
          error 'Valor deve se 1, 2, 3 ou nulo'
       end if

       if ctc30m00.acntip = 1 then
          let ctc30m00.acndes = 'Internet'
       else
          if ctc30m00.acntip = 2 then
             let ctc30m00.acndes = 'Fax'
          else
             if ctc30m00.acntip = 3 then
                let ctc30m00.acndes = 'Online'
             end if
          end if
       end if

       display by name ctc30m00.acndes


    before field maides
       display by name ctc30m00.maides attribute (reverse)

    after field maides
       display by name ctc30m00.acntip
       if fgl_lastkey() = fgl_keyval("up")   and
          fgl_lastkey() = fgl_keyval("left") then
          next field acntip
       end if

       if not ctc30m00_checkemail(ctc30m00.maides) then
          error " EMAIL INVALIDO"
          next field maides
       end if

    before field lcvextcod
       display by name ctc30m00.lcvextcod attribute (reverse)
       if ctc30m00.lcvextcod is null then
          display "" to aviestnom
       end if

    after field lcvextcod
       display by name ctc30m00.lcvextcod
       if fgl_lastkey() = fgl_keyval("up")   and
          fgl_lastkey() = fgl_keyval("left") then
          next field maides
       end if

       if operacao = "a"  then
          whenever error continue
             select aviestnom
               into ctc30m00.aviestnom
               from datkavislocal
              where lcvextcod = ctc30m00.lcvextcod

             if sqlca.sqlcode = notfound then
                let ctc30m00.aviestnom = null
                let ctc30m00.lcvextcod = null
             end if
          whenever error stop

          if ctc30m00.lcvextcod is null or ctc30m00.lcvextcod = "" then
             call ctc30m00_favorecido_popup(ctc30m00.lcvcod)
                 returning l_achou, ctc30m00.lcvextcod, ctc30m00.aviestnom

             display by name ctc30m00.aviestnom

             next field lcvextcod
          end if
       end if

    before field pgtcrncod

       if not ctc30m00_checkemail(ctc30m00.maides) then
          error "PARA FORMA DE PAGAMENTO 1 OBROGATORIO EMAIL VALIDO"
          next field maides
       end if

       display by name ctc30m00.pgtcrncod attribute (reverse)

    after field pgtcrncod
       display by name ctc30m00.pgtcrncod
       if fgl_lastkey() = fgl_keyval("up")   and
          fgl_lastkey() = fgl_keyval("left") then
          next field lcvextcod
       end if

       if ctc30m00.pgtcrncod is null or ctc30m00.pgtcrncod = "" then
          call ctc30m00_popup()
               returning l_achou, ctc30m00.pgtcrncod, ctc30m00.crnpgtdes

          if l_achou <> 0 then
             next field pgtcrncod
          end if
       else
          whenever error continue
             select crnpgtdes
               into ctc30m00.crnpgtdes
               from dbsmcrnpgt
              where crnpgtcod = ctc30m00.pgtcrncod

             if sqlca.sqlcode = notfound then
                let ctc30m00.crnpgtdes = null
                display by name ctc30m00.crnpgtdes
                error " CRONOGRAMA INVALIDO"
                call ctc30m00_popup()
                     returning l_achou, ctc30m00.pgtcrncod, ctc30m00.crnpgtdes

                if l_achou <> 0 then
                   next field pgtcrncod
                end if
                next field pgtcrncod
             end if

          whenever error stop
       end if

       display by name ctc30m00.crnpgtdes

   on key (interrupt)
      exit input

   end input

   if int_flag   then
      initialize ctc30m00.*, k_ctc30m00.* to null
   end if

   return ctc30m00.*, k_ctc30m00.*

end function  ###  input_ctc30m00

#---------------------------------------------------------
 function sel_ctc30m00(k_ctc30m00)
#---------------------------------------------------------

 define ctc30m00 record
    lcvcod       like datklocadora.lcvcod      ,
    lcvnom       like datklocadora.lcvnom      ,
    lgdnom       like datklocadora.lgdnom      ,
    brrnom       like datklocadora.brrnom      ,
    cidnom       like datklocadora.cidnom      ,
    endufd       like datklocadora.endufd      ,
    dddcod       like datklocadora.dddcod      ,
    teltxt       like datklocadora.teltxt      ,
    facnum       like datklocadora.facnum      ,
    cgccpfnum    like datklocadora.cgccpfnum   ,
    cgcord       like datklocadora.cgcord      ,
    cgccpfdig    like datklocadora.cgccpfdig   ,
    lcvresenvcod like datklocadora.lcvresenvcod,
    envdsc       char (15)                     ,
    lcvstt       like datklocadora.lcvstt      ,
    lcvsttdes    char (10)                     ,
    acntip       like datklocadora.acntip      ,
    acndes       char(010)                     ,
    maides       like datklocadora.maides      ,
    caddat       like datklocadora.caddat      ,
    cademp       like datklocadora.cademp      ,
    cadmat       like datklocadora.cadmat      ,
    cadnom       like isskfunc.funnom          ,
    atldat       like datklocadora.atldat      ,
    atlemp       like datklocadora.atlemp      ,
    atlmat       like datklocadora.atlmat      ,
    atlnom       like isskfunc.funnom          ,
    adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
    cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
    lcvextcod    like datkavislocal.lcvextcod  ,
    aviestnom    like datkavislocal.aviestnom  ,
    pgtcrncod    like datklocadora.pgtcrncod   ,
    crnpgtdes    like dbsmcrnpgt.crnpgtdes
 end record

 define k_ctc30m00 record
    lcvcod       like datklocadora.lcvcod
 end record

 initialize ctc30m00.*  to null

 select lcvcod,    lcvnom   ,
        lgdnom,    brrnom   ,
        cidnom,    endufd   ,
        dddcod,    teltxt   ,
        facnum,    cgccpfnum,
        cgcord,    cgccpfdig,
        lcvstt,    lcvresenvcod,
        caddat,    cademp,
        cadmat,    atldat,
        atlemp,    atlmat,
        adcsgrtaxvlr,
        cdtsegtaxvlr, acntip, maides,
        fvrlojcod,pgtcrncod
   into ctc30m00.lcvcod ,
        ctc30m00.lcvnom ,
        ctc30m00.lgdnom ,
        ctc30m00.brrnom ,
        ctc30m00.cidnom ,
        ctc30m00.endufd ,
        ctc30m00.dddcod ,
        ctc30m00.teltxt ,
        ctc30m00.facnum ,
        ctc30m00.cgccpfnum ,
        ctc30m00.cgcord    ,
        ctc30m00.cgccpfdig ,
        ctc30m00.lcvstt    ,
        ctc30m00.lcvresenvcod ,
        ctc30m00.caddat ,
        ctc30m00.cademp ,
        ctc30m00.cadmat ,
        ctc30m00.atldat ,
        ctc30m00.atlemp ,
        ctc30m00.atlmat ,
        ctc30m00.adcsgrtaxvlr,
        ctc30m00.cdtsegtaxvlr,
        ctc30m00.acntip,
        ctc30m00.maides,
        ctc30m00.lcvextcod,
        ctc30m00.pgtcrncod
   from datklocadora
  where lcvcod = k_ctc30m00.lcvcod

 case ctc30m00.lcvresenvcod
    when 1 let ctc30m00.envdsc = "Central Reservas"
    when 2 let ctc30m00.envdsc = "Loja"
 end case

 case ctc30m00.lcvstt
    when "A" let ctc30m00.lcvsttdes = "ATIVA"
    when "C" let ctc30m00.lcvsttdes = "CANCELADA"
 end case

 if ctc30m00.acntip = 1 then
    let ctc30m00.acndes = 'Internet'
 else
    if ctc30m00.acntip = 2 then
       let ctc30m00.acndes = 'Fax'
    else
       if ctc30m00.acntip = 3 then
          let ctc30m00.acndes = 'Online'
       end if
    end if
 end if

 whenever error continue
    select aviestnom
      into ctc30m00.aviestnom
      from datkavislocal
     where lcvcod    = ctc30m00.lcvcod
       and lcvextcod = ctc30m00.lcvextcod

    if sqlca.sqlcode = notfound then
       let ctc30m00.aviestnom = null
    end if
 whenever error stop

 whenever error continue
    select crnpgtdes
      into ctc30m00.crnpgtdes
      from dbsmcrnpgt
     where crnpgtcod = ctc30m00.pgtcrncod

    if sqlca.sqlcode = notfound then
       let ctc30m00.crnpgtdes = null
    end if
 whenever error stop

 call ctc30m00_func(ctc30m00.cademp, ctc30m00.cadmat)
      returning ctc30m00.cadnom

 call ctc30m00_func(ctc30m00.atlemp, ctc30m00.atlmat)
      returning ctc30m00.atlnom

 return ctc30m00.*

end function  ###  sel_ctc30m00

#---------------------------------------------------------
 function ctc30m00_func(k_ctc30m00)
#---------------------------------------------------------

 define k_ctc30m00 record
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
  where empcod = k_ctc30m00.empcod  and
        funmat = k_ctc30m00.funmat

 let ws.funnom = upshift(ws.funnom)

 return ws.funnom

end function  ###  ctc30m00_func

#-----------------------------------------------------------
function ctc30m00_grava_hist(lr_param,l_mensagem,l_operacao)
#-----------------------------------------------------------

   define lr_param record
          lcvcod       like datklocadora.lcvcod
         ,mensagem   char(100)
         ,data       date
          end record

   define lr_retorno record
                     stt smallint
                    ,msg char(50)
          end record

   define l_mensagem    char(3000)
         ,l_stt         smallint
         ,l_erro        smallint
         ,l_path        char(100)
         ,l_operacao    char(1)
	 ,l_data        date
	 ,l_hora        datetime hour to minute
	 ,l_prshstdes2  char(3000)
	 ,l_count
         ,l_iter
         ,l_length
         ,l_length2     smallint
         ,l_opcao       char(1)

   let l_stt  = true
   let l_path = null

    call cts40g03_data_hora_banco(2)
	    returning l_data, l_hora

   initialize lr_retorno to null

   let l_length = length(l_mensagem clipped)
   if  l_length mod 70 = 0 then
       let l_iter = l_length / 70
   else
       let l_iter = l_length / 70 + 1
   end if

   let l_length2     = 0
   let l_erro        = 0

   for l_count = 1 to l_iter
       if  l_count = l_iter then
           let l_prshstdes2 = l_mensagem[l_length2 + 1, l_length]
       else
           let l_length2 = l_length2 + 70
           let l_prshstdes2 = l_mensagem[l_length2 - 69, l_length2]
       end if

       call ctb85g01_grava_hist(2
                               ,lr_param.lcvcod
                               ,l_prshstdes2
                               ,lr_param.data
                               ,g_issk.empcod
                               ,g_issk.funmat
                               ,g_issk.usrtip)
            returning lr_retorno.stt
                     ,lr_retorno.msg
   end for

   if l_operacao = "I" then
      if lr_retorno.stt = 0 then

         call ctb85g01_mtcorpo_email_html('CTC30M00',
	      	                          lr_param.data,
		                          l_hora,
		                          g_issk.empcod,
		                          g_issk.usrtip,
		                          g_issk.funmat,
		                          lr_param.mensagem,
		                          l_mensagem)
		returning l_erro

         if l_erro  <> 0 then
            error 'Erro no envio do e-mail' sleep 2
            let l_stt = false
         else
            let l_stt = true
         end if

      else
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
      end if
    else
      if lr_retorno.stt <> 0 then
         error 'Erro na gravacao do historico' sleep 2
         let l_stt = false
      end if
  end if

   return l_stt

end function

#---------------------------------------------------------
function ctc30m00_verifica_mod(lr_ctc30m00_ant,lr_ctc30m00)
#---------------------------------------------------------

   define lr_ctc30m00_ant record
      lcvnom         like datklocadora.lcvnom
     ,lgdnom         like datklocadora.lgdnom
     ,brrnom         like datklocadora.brrnom
     ,cidnom         like datklocadora.cidnom
     ,endufd         like datklocadora.endufd
     ,dddcod         like datklocadora.dddcod
     ,teltxt         like datklocadora.teltxt
     ,facnum         like datklocadora.facnum
     ,cgccpfnum      like datklocadora.cgccpfnum
     ,cgcord         like datklocadora.cgcord
     ,cgccpfdig      like datklocadora.cgccpfdig
     ,lcvstt         like datklocadora.lcvstt
     ,lcvsttdes      char (10)
     ,lcvresenvcod   like datklocadora.lcvresenvcod
     ,atldat         like datklocadora.atldat
     ,atlemp         like datklocadora.atlemp
     ,atlmat         like datklocadora.atlmat
     ,adcsgrtaxvlr   like datklocadora.adcsgrtaxvlr
     ,cdtsegtaxvlr   like datklocadora.cdtsegtaxvlr
     ,acntip         like datklocadora.acntip
     ,maides         like datklocadora.maides
     ,lcvextcod      like datkavislocal.lcvextcod
     ,pgtcrncod      like datklocadora.pgtcrncod
   end record

   define lr_ctc30m00 record
      lcvcod       like datklocadora.lcvcod      ,
      lcvnom       like datklocadora.lcvnom      ,
      lgdnom       like datklocadora.lgdnom      ,
      brrnom       like datklocadora.brrnom      ,
      cidnom       like datklocadora.cidnom      ,
      endufd       like datklocadora.endufd      ,
      dddcod       like datklocadora.dddcod      ,
      teltxt       like datklocadora.teltxt      ,
      facnum       like datklocadora.facnum      ,
      cgccpfnum    like datklocadora.cgccpfnum   ,
      cgcord       like datklocadora.cgcord      ,
      cgccpfdig    like datklocadora.cgccpfdig   ,
      lcvresenvcod like datklocadora.lcvresenvcod,
      envdsc       char (15)                     ,
      lcvstt       like datklocadora.lcvstt      ,
      lcvsttdes    char (10)                     ,
      acntip       like datklocadora.acntip      ,
      acndes       char(010)                     ,
      maides       like datklocadora.maides      ,
      caddat       like datklocadora.caddat      ,
      cademp       like datklocadora.cademp      ,
      cadmat       like datklocadora.cadmat      ,
      cadnom       like isskfunc.funnom          ,
      atldat       like datklocadora.atldat      ,
      atlemp       like datklocadora.atlemp      ,
      atlmat       like datklocadora.atlmat      ,
      atlnom       like isskfunc.funnom          ,
      adcsgrtaxvlr like datklocadora.adcsgrtaxvlr,
      cdtsegtaxvlr like datklocadora.cdtsegtaxvlr,
      lcvextcod    like datkavislocal.lcvextcod  ,
      aviestnom    like datkavislocal.aviestnom  ,
      pgtcrncod    like datklocadora.pgtcrncod   ,
      crnpgtdes    like dbsmcrnpgt.crnpgtdes
   end record

   define l_mensagem  char(3000)
         ,l_mensagem2 char(100)
	 ,l_flg      integer
	 ,l_cmd      char(100)
	 ,l_mensmail char(3000)
	 ,l_hora     datetime hour to minute
	 ,l_stt      smallint
	 ,teste      char(1)

   let l_hora    = current hour to minute
   let l_mensmail = null
   let l_mensagem2 = 'Alteracao no cadastro de Locadoras de Veiculos. Loja = ',
		     lr_ctc30m00.lcvcod

   if (lr_ctc30m00_ant.lcvnom is null     and lr_ctc30m00.lcvnom is not null) or
      (lr_ctc30m00_ant.lcvnom is not null and lr_ctc30m00.lcvnom is null)     or
      (lr_ctc30m00_ant.lcvnom              <> lr_ctc30m00.lcvnom)             then
      let l_mensagem = "Razao Social alterado de [",lr_ctc30m00_ant.lcvnom clipped,"] para [",lr_ctc30m00.lcvnom clipped,"]"

      let l_mensmail = l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.lgdnom is null     and lr_ctc30m00.lgdnom is not null) or
      (lr_ctc30m00_ant.lgdnom is not null and lr_ctc30m00.lgdnom is null)     or
      (lr_ctc30m00_ant.lgdnom              <> lr_ctc30m00.lgdnom)             then

      let l_mensagem = "Endereco alterado de [",lr_ctc30m00_ant.lgdnom clipped,
          "] para [",lr_ctc30m00.lgdnom clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.brrnom is null     and lr_ctc30m00.brrnom is not null) or
      (lr_ctc30m00_ant.brrnom is not null and lr_ctc30m00.brrnom is null)     or
      (lr_ctc30m00_ant.brrnom              <> lr_ctc30m00.brrnom)             then

      let l_mensagem = "Bairro  alterado de [",lr_ctc30m00_ant.brrnom clipped,
           "] para [",lr_ctc30m00.brrnom clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.cidnom is null     and lr_ctc30m00.cidnom is not null) or
      (lr_ctc30m00_ant.cidnom is not null and lr_ctc30m00.cidnom is null)     or
      (lr_ctc30m00_ant.cidnom              <> lr_ctc30m00.cidnom)             then

      let l_mensagem = "Cidade alterado de [",lr_ctc30m00_ant.cidnom clipped,
           "] para [",lr_ctc30m00.cidnom clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.endufd is null     and lr_ctc30m00.endufd is not null) or
      (lr_ctc30m00_ant.endufd is not null and lr_ctc30m00.endufd is null)     or
      (lr_ctc30m00_ant.endufd              <> lr_ctc30m00.endufd)             then
      let l_mensagem = "Sigla da Unidade Federativa alterado de [",
           lr_ctc30m00_ant.endufd clipped,"] para [",lr_ctc30m00.endufd clipped,"]"
      let l_mensmail = l_mensmail clipped clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.dddcod is null     and lr_ctc30m00.dddcod is not null) or
      (lr_ctc30m00_ant.dddcod is not null and lr_ctc30m00.dddcod is null)     or
      (lr_ctc30m00_ant.dddcod              <> lr_ctc30m00.dddcod)             then
      let l_mensagem = "DDD alterado de [",lr_ctc30m00_ant.dddcod clipped,
           "] para [",lr_ctc30m00.dddcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.teltxt is null     and lr_ctc30m00.teltxt is not null) or
      (lr_ctc30m00_ant.teltxt is not null and lr_ctc30m00.teltxt is null)     or
      (lr_ctc30m00_ant.teltxt              <> lr_ctc30m00.teltxt)             then
      let l_mensagem = "Telefone alterado de [",lr_ctc30m00_ant.teltxt clipped,
           "] para [",lr_ctc30m00.teltxt clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then
         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.facnum is null     and lr_ctc30m00.facnum is not null) or
      (lr_ctc30m00_ant.facnum is not null and lr_ctc30m00.facnum is null)     or
      (lr_ctc30m00_ant.facnum              <> lr_ctc30m00.facnum)             then
      let l_mensagem = "Fax da Central alterado de [",lr_ctc30m00_ant.facnum clipped,
                       "] para [",lr_ctc30m00.facnum clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.cgccpfnum is null     and lr_ctc30m00.cgccpfnum is not null) or
      (lr_ctc30m00_ant.cgccpfnum is not null and lr_ctc30m00.cgccpfnum is null)     or
      (lr_ctc30m00_ant.cgccpfnum              <> lr_ctc30m00.cgccpfnum)             then
      let l_mensagem = "CGC/CPF alterado de [",lr_ctc30m00_ant.cgccpfnum clipped,
          "] para [",lr_ctc30m00.cgccpfnum clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.cgcord is null     and lr_ctc30m00.cgcord is not null) or
      (lr_ctc30m00_ant.cgcord is not null and lr_ctc30m00.cgcord is null)     or
      (lr_ctc30m00_ant.cgcord              <> lr_ctc30m00.cgcord)             then
      let l_mensagem = "ORDEM CGC alterado de [",lr_ctc30m00_ant.cgcord clipped,
          "] para [",lr_ctc30m00.cgcord clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.cgccpfdig is null     and lr_ctc30m00.cgccpfdig is not null) or
      (lr_ctc30m00_ant.cgccpfdig is not null and lr_ctc30m00.cgccpfdig is null)     or
      (lr_ctc30m00_ant.cgccpfdig              <> lr_ctc30m00.cgccpfdig)             then
      let l_mensagem = "DIGITO CGC/CPF alterado de [",lr_ctc30m00_ant.cgccpfdig clipped,
           "] para [",lr_ctc30m00.cgccpfdig clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.lcvresenvcod is null     and lr_ctc30m00.lcvresenvcod is not null) or
      (lr_ctc30m00_ant.lcvresenvcod is not null and lr_ctc30m00.lcvresenvcod is null)     or
      (lr_ctc30m00_ant.lcvresenvcod              <> lr_ctc30m00.lcvresenvcod)             then
      let l_mensagem = "Envio de Fax  alterado de [",lr_ctc30m00_ant.lcvresenvcod clipped,
           "] para [",lr_ctc30m00.lcvresenvcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.lcvstt is null     and lr_ctc30m00.lcvstt is not null) or
      (lr_ctc30m00_ant.lcvstt is not null and lr_ctc30m00.lcvstt is null)     or
      (lr_ctc30m00_ant.lcvstt              <> lr_ctc30m00.lcvstt)             then
      let l_mensagem = "Situacao alterado de [",lr_ctc30m00_ant.lcvstt clipped,"-",
          lr_ctc30m00_ant.lcvsttdes,"] para [",lr_ctc30m00.lcvstt clipped,"-",
          lr_ctc30m00.lcvsttdes,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.adcsgrtaxvlr is null     and lr_ctc30m00.adcsgrtaxvlr is not null) or
      (lr_ctc30m00_ant.adcsgrtaxvlr is not null and lr_ctc30m00.adcsgrtaxvlr is null)     or
      (lr_ctc30m00_ant.adcsgrtaxvlr              <> lr_ctc30m00.adcsgrtaxvlr)             then
      let l_mensagem = "Taxa de Seguro para Locacao alterado de [",
          lr_ctc30m00_ant.adcsgrtaxvlr clipped,"] para [",lr_ctc30m00.adcsgrtaxvlr clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.cdtsegtaxvlr is null     and lr_ctc30m00.cdtsegtaxvlr is not null) or
      (lr_ctc30m00_ant.cdtsegtaxvlr is not null and lr_ctc30m00.cdtsegtaxvlr is null)     or
      (lr_ctc30m00_ant.cdtsegtaxvlr              <> lr_ctc30m00.cdtsegtaxvlr)             then
      let l_mensagem = "Taxa de Segundo Condutor alterado de [",
          lr_ctc30m00_ant.cdtsegtaxvlr clipped,"] para [",lr_ctc30m00.cdtsegtaxvlr clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.acntip is null     and lr_ctc30m00.acntip is not null) or
      (lr_ctc30m00_ant.acntip is not null and lr_ctc30m00.acntip is null)     or
      (lr_ctc30m00_ant.acntip              <> lr_ctc30m00.acntip)             then
      let l_mensagem = "Tipo de Acionamento alterado de [",lr_ctc30m00_ant.acntip clipped,
                       "] para [",lr_ctc30m00.acntip clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.maides is null     and lr_ctc30m00.maides is not null) or
      (lr_ctc30m00_ant.maides is not null and lr_ctc30m00.maides is null)     or
      (lr_ctc30m00_ant.maides              <> lr_ctc30m00.maides)             then
      let l_mensagem = "Email alterado de [",lr_ctc30m00_ant.maides clipped,
                       "] para [",lr_ctc30m00.maides clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.lcvextcod is null     and lr_ctc30m00.lcvextcod is not null) or
      (lr_ctc30m00_ant.lcvextcod is not null and lr_ctc30m00.lcvextcod is null)     or
      (lr_ctc30m00_ant.lcvextcod              <> lr_ctc30m00.lcvextcod)             then
      let l_mensagem = "Favarecido alterado de [",lr_ctc30m00_ant.lcvextcod clipped,
                       "] para [",lr_ctc30m00.lcvextcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc30m00_ant.pgtcrncod is null     and lr_ctc30m00.pgtcrncod is not null) or
      (lr_ctc30m00_ant.pgtcrncod is not null and lr_ctc30m00.pgtcrncod is null)     or
      (lr_ctc30m00_ant.pgtcrncod              <> lr_ctc30m00.pgtcrncod)             then
      let l_mensagem = "Cronograma alterado de [",lr_ctc30m00_ant.pgtcrncod clipped,
                       "] para [",lr_ctc30m00.pgtcrncod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc30m00_grava_hist(lr_ctc30m00.lcvcod
                                ,l_mensagem2
                                ,lr_ctc30m00.atldat
                                ,l_mensagem,"A") then

         let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   call ctc30m00_envia_email(l_mensagem2 ,lr_ctc30m00.atldat ,l_hora,
			     l_flg,l_mensmail)
         returning l_stt

end function

#------------------------------------------------
function ctc30m00_envia_email(lr_param)
#------------------------------------------------

  define lr_param record
        titulo     char(100)
        ,data       date
        ,hora       datetime hour to minute
        ,flag       smallint
        ,mensmail   char(3000)
  end record

 define l_stt       smallint
       ,l_path      char(100)
       ,l_cmd       char(100)

       ,l_erro
       ,l_iter
       ,l_length
       ,l_length2    smallint

define teste char(1)
   let l_stt  = true
   let l_path = null


   call ctb85g01_mtcorpo_email_html('CTC30M00',
		                    lr_param.data,
		                    lr_param.hora,
		                    g_issk.empcod,
		                    g_issk.usrtip,
		                    g_issk.funmat,
		                    lr_param.titulo,
		                    lr_param.mensmail)
		returning l_erro

    if l_erro <> 0 then
       error 'Erro no envio do e-mail' sleep 2
       let l_stt = false
     else
      let l_stt = true
    end if

    return l_stt
end function

#-----------------------------------------------------------------------------
function ctc30m00_popup()
#-----------------------------------------------------------------------------

 define l_dpt_pop    record
    lin              smallint,
    col              smallint,
    title            char(054),
    col_tit_1        char(012),
    col_tit_2        char(040),
    tipcod           char(001),
    cmd_sql          char(600),
    comp_sql         char(200),
    tipo             char(001)
 end record

 define l_pgtcrncod    like datklocadora.pgtcrncod,
        l_crnpgtdes    like dbsmcrnpgt.crnpgtdes  ,
        l_achou        smallint

 initialize l_dpt_pop     to null

 let l_achou               = 0
 let l_dpt_pop.lin         = 6
 let l_dpt_pop.col         = 2
 let l_dpt_pop.title       = 'Cronograma de Pagamentos'
 let l_dpt_pop.col_tit_1   = 'Codigo'
 let l_dpt_pop.col_tit_2   = 'Descricao'
 let l_dpt_pop.tipcod      = 'N'
 let l_dpt_pop.tipo        = 'D'

 let l_dpt_pop.cmd_sql  = 'select crnpgtcod, crnpgtdes',
                          '  from dbsmcrnpgt          ',
                          ' where crnpgtstt = "A"'

 call ofgrc001_popup(l_dpt_pop.*) returning l_achou,
	                                    l_pgtcrncod,
	                                    l_crnpgtdes

 return l_achou, l_pgtcrncod, l_crnpgtdes

#-----------------------------------------------------------------------------
end function
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
 function ctc30m00_checkemail(param)
#-----------------------------------------------------------------------------

 define param         record
    webusrmaides      like isskwebusr.webusrmaides
 end record

 define ws            record
    tamanho           integer,
    arrobaflg         char (01),
    pontoflg          char (01)
 end record

 define index         integer


 initialize ws.*  to null

 let ws.arrobaflg  =  "N"
 let ws.pontoflg   =  "N"
 let ws.tamanho    = length(param.webusrmaides)

 for index = 1 to ws.tamanho

     if param.webusrmaides[index] = "@"  then
        let ws.arrobaflg  =  "S"
     end if

     if ws.arrobaflg  =  "S"   then
        if param.webusrmaides[index] = "."  then
           let ws.pontoflg  =  "S"
           exit for
        end if
     end if

 end for

 if ws.arrobaflg  =  "S"   and
    ws.pontoflg   =  "S"   then
    return true
 end if

 return false

#-----------------------------------------------------------------------------
 end function
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
function ctc30m00_favorecido_popup(l_lcvcod)
#-----------------------------------------------------------------------------

 define l_lcvcod like datklocadora.lcvcod

 define l_dpt_pop    record
    lin              smallint,
    col              smallint,
    title            char(054),
    col_tit_1        char(012),
    col_tit_2        char(040),
    tipcod           char(001),
    cmd_sql          char(600),
    comp_sql         char(200),
    tipo             char(001)
 end record

 define l_lcvextcod    like datkavislocal.lcvextcod,
        l_aviestnom    like datkavislocal.aviestnom  ,
        l_achou        smallint

 initialize l_dpt_pop     to null

 let l_achou               = 0
 let l_dpt_pop.lin         = 6
 let l_dpt_pop.col         = 2
 let l_dpt_pop.title       = 'Lojas'
 let l_dpt_pop.col_tit_1   = 'Codigo'
 let l_dpt_pop.col_tit_2   = 'Descricao'
 let l_dpt_pop.tipcod      = 'A'
 let l_dpt_pop.tipo        = 'D'

 let l_dpt_pop.cmd_sql  = 'select lcvextcod, aviestnom',
                          '  from datkavislocal       ',
                          ' where lcvcod = ',l_lcvcod ,
                          '   and vclalglojstt = 1'

 call ofgrc001_popup(l_dpt_pop.*) returning l_achou,
	                                    l_lcvextcod,
	                                    l_aviestnom

 return l_achou, l_lcvextcod, l_aviestnom

#-----------------------------------------------------------------------------
end function
#-----------------------------------------------------------------------------

function ctc30m00_remove_caracteres(texto)

   define texto char(250)

   define l_i, l_j, l_texto, l_acento integer
   define l_caracter char(1)
   define l_especiais,l_limpa,l_textoLimpo  char(200)

   let l_especiais = "¥`^~®#¨$%&*'()_{}:;[]<>=?!™∫ß¢£@ƒ≈¡¬¿√‰·‚‡„… À»ÈÍÎËÕŒœÃÌÓÔÏ÷”‘“’ˆÛÙÚı‹⁄€¸˙˚˘«Á—Ò",'"'
   let l_limpa     = "                                AAAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUuuuuCcNn",' '
   let l_texto = length (texto)
   let l_acento = length (l_especiais)
   let l_textoLimpo = texto
   #display "texto: ", texto
   #display "l_texto: ",l_texto

    for l_i = 1 to l_texto
      let l_caracter = texto[l_i]

      for l_j = 1 to l_acento
         if l_caracter = l_especiais[l_j] then
            let l_textoLimpo[l_i] = l_limpa[l_j]
         end if
      end for

   end for
   return l_textoLimpo clipped

end function