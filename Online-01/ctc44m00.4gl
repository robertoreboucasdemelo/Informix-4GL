 #############################################################################
 # Nome do Modulo: ctc44m00                                          Marcelo #
 #                                                                  Gilberto #
 # Cadastro de Socorristas                                          Jul/1999 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 04/08/1999               Gilberto     Retirar critica que impedia cadas-  #
 #                                       tramento da matricula do funciona-  #
 #                                       rio se o mesmo nao estive cadastra- #
 #                                       do no sistema de seguranca Informix #
 #---------------------------------------------------------------------------#
 # 07/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador    #
 #                                       B-Bloqueado.                        #
 #---------------------------------------------------------------------------#
 # 26/10/2005 PSI 195138 Cristiane Silva Inclus�o de novo item de menu       #
 # 27/11/2006 PSI        Ligia Mattge    Inibir consistencia nome abreviado  #
 #---------------------------------------------------------------------------#
 # 24/04/2008 PSI220710  Fabio,Meta      Incluir campos, itens menu          #
 #---------------------------------------------------------------------------#
 # 25/06/2008 PSI225134  Fabio,Meta      Cadastro do socorrista              #
 #---------------------------------------------------------------------------#
 # 04/08/2008 PSI226300  Diomar,Meta     Incluido gravacao do historico      #
 #---------------------------------------------------------------------------#
 # 16/10/2009 PSI249530  Beatriz Araujo  Adicionar campo para verificar se   #
 #                                       Socorrista tem seguro de vida       #
 #---------------------------------------------------------------------------#
 # 21/10/2009 PSI249530  Beatriz Araujo  Inclus�o de uma popup na data do    #
 #                                       exame medico e no cpf               #
 #---------------------------------------------------------------------------#
 # 29/10/2009 PSI249530  Beatriz Araujo  Opcao no menu para solicitar crach� #
 #---------------------------------------------------------------------------#
 # 05/03/2010 PSI254444  Beatriz Araujo  Altera��o no tamanho da camisa e da #
 #                                       cal�a do Socorrista, e popup para   #
 #                                       mostrar os tamanhos dispon�veis     #
 # 28/05/2010 PSI257206  Robert Lima     Foi impossibilitado a continuidade  #
 #    				         do fluxo se o CPF estiver invalido  #
 # 30/08/2010 CT802999   Robert Lima     Alteracao da funcao do vida         #
 # 17/08/2010            Ueslei / Danilo Alteracao da funcao display,        #
 #                                       verificacao do padrao do Prestador  #
 #---------------------------------------------------------------------------#
 # 01/10/2014 PSI-21950  Fornax, RCP     Tratamento bloqueio/motivo.         #
 # 10/03/2016 CH 922752  Fornax,ElianeK  Campos cnhautctg, cnhmotctg alterado#
 #                                       tamanho para char(01) devido a      #
 #                                       entrada de dados.                   #
 #############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_ctc44m00_prep smallint
 define teste           char(1)

 define m_cabec         record #--> PSI-21950
        srrcoddig       like datksrr.srrcoddig
      , srrnom          like datksrr.srrnom
      , l_qual_srr      char(7)
 end    record

#-------------------------#
function ctc44m00_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select celdddcod, ",
                     " celtelnum, ",
                     " srrcoddig ",
                " from datksrr "

  prepare pctc44m00002 from l_sql
  declare cctc44m00002 cursor for pctc44m00002

  let l_sql = "  select srrcoddig ",
                "  from datksrr ",
                " where cgccpfnum = ? ",
                "   and (cgcord = ? or cgcord is null)",
                "   and cgccpfdig = ? "

  prepare pctc44m00003 from l_sql
  declare cctc44m00003 cursor for pctc44m00003

  let l_sql = 'update datksrr set maides = ?'
             ,' where srrcoddig = ? '

  prepare pctc44m00004 from l_sql

  let l_sql = " select maides "
             ," from datksrr "
             ,' where srrcoddig = ? '

  prepare pctc44m00005 from l_sql
  declare cctc44m00005 cursor for pctc44m00005

  let l_sql = " select pstcoddig, ",
                     " pstvintip ",
                " from datrsrrpst ",
               " where srrcoddig = ? ",
                 " and today between viginc and vigfnl "

  prepare pctc44m00006 from l_sql
  declare cctc44m00006 cursor for pctc44m00006

  let l_sql = "select nomgrr ",
               " from dpaksocor ",
              " where pstcoddig = ? "

  prepare pctd30g00_07 from l_sql
  declare cctd30g00_07 cursor for pctd30g00_07

  let m_ctc44m00_prep = true

end function

#------------------------------------------------------------
 function ctc44m00(lr_param)
#------------------------------------------------------------

 define lr_param      record
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    pstcndnom         like isskfunc.funnom,     --- VERIFICAR SE ESTA CORRETO
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    nscdat            like datksrr.nscdat,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,   --- VERIFICAR SE ESTA CORRETO
    cnhpridat         like datksrr.cnhpridat,
    situacao          like datksrr.rdranlsitcod,
    rdranlultdat      like  datksrr.rdranlultdat
 end record



 define d_ctc44m00    record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
### srrsttdes         char (10),
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,
    cnhmotctg         like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char (1),
    coderro           integer       ## Codigo erro func externas
 end record

 define d_ctc44m00r   record
     srrabvnom  like datksrr.srrabvnom,
     celdddcod  like datksrr.celdddcod,
     celtelnum  like datksrr.celtelnum,
     maides     like datksrr.maides
 end record

 define ws            record
    pstcoddig         like dpaksocor.pstcoddig,
    prssitcod         like dpaksocor.prssitcod
 end record

 define param_popup   record
   linha1              char (40),
   linha2              char (40),
   linha3              char (40),
   linha4              char (40),
   confirma            char (1)
 end record

 let int_flag = false
 initialize ws.*, param_popup.*  to null
 initialize d_ctc44m00.*  to null

 if not get_niv_mod(g_issk.prgsgl, "ctc44m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc44m00 at 04,02 with form "ctc44m00"

 if lr_param.cgccpfnum  is not null then

     message ""
     clear form

     call ctc44m00_sel_srr(lr_param.cgccpfnum, lr_param. cgcord,
                           lr_param.cgccpfdig)
          returning d_ctc44m00.srrcoddig

     if d_ctc44m00.srrcoddig  is null  then
        call ctc44m00_inclui(lr_param.*)
     else
        call ctc44m00_ler(d_ctc44m00.srrcoddig)
             returning d_ctc44m00.*
        call ctc44m00_display(d_ctc44m00.*)
     end if

 end if

 menu "Socorristas"

  before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo"     , "Anterior",
                    "presTador", "assisteNcias", "natuRezas", "pesqUisa",
                    "Historico", 
		    "Bloqueio" #--> PSI-21950
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior"    ,
                    "Modifica" , "Inclui" , "assisteNcias", "Naturezas",
                    "pesqUisa" , "Historico", "emaiL" , "sOlicitar cracha",
		    "Bloqueio" #--> PSI-21950
     end if

     if (g_issk.dptsgl = 'psocor' or g_issk.dptsgl = 'desenv') and
         g_issk.acsnivcod >= g_issk.acsnivatl  then  #PSI 220710
         show option "raDar"
     end if

     show option "Encerra"

 command key ("S") "Seleciona"
                   "Pesquisa socorrista conforme criterios"
          call ctc44m00_seleciona(d_ctc44m00.srrcoddig)  returning d_ctc44m00.*
          if d_ctc44m00.srrcoddig  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum socorrista selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo socorrista selecionado"
          message ""
          call ctc44m00_proximo(d_ctc44m00.srrcoddig)
               returning d_ctc44m00.*

 command key ("A") "Anterior"
                   "Mostra socorrista anterior selecionado"
          message ""
          if d_ctc44m00.srrcoddig is not null then
             call ctc44m00_anterior(d_ctc44m00.srrcoddig)
                  returning d_ctc44m00.*
          else
             error " Nenhum socorrista nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica socorrista corrente selecionado"
          message ""
          initialize ws.pstcoddig  to null
          initialize ws.prssitcod  to null

          if d_ctc44m00.srrcoddig  is not null   then

             declare c_datrsrrpst  cursor for
                select pstcoddig, vigfnl
                  from datrsrrpst
                 where srrcoddig  =  d_ctc44m00.srrcoddig
                 order by vigfnl desc

             open  c_datrsrrpst
             fetch c_datrsrrpst  into  ws.pstcoddig
             close c_datrsrrpst

             if ws.pstcoddig  is not null   then
                select prssitcod
                  into ws.prssitcod
                  from dpaksocor
                 where pstcoddig  =  ws.pstcoddig

                if ws.prssitcod  <>  "A"   then
                   case ws.prssitcod
                      when "C" error " Socorrista possui vinculo com prestador cancelado, nao deve ser alterado!"
                      when "P" error " Socorrista possui vinculo com prestador em proposta, nao deve ser alterado!"
                      when "B" error " Socorrista possui vinculo com prestador bloqueado, nao deve ser alterado!"
                   end case
                   continue menu
                end if
             end if

             call ctc44m00_modifica(d_ctc44m00.srrcoddig, d_ctc44m00.*)
                  returning d_ctc44m00.*
             next option "Seleciona"
          else
             error " Nenhum socorrista selecionado!"
             next option "Seleciona"
          end if
          clear form
          initialize d_ctc44m00.*  to null

 command key ("B") "Bloqueio" #--> PSI-999999
                   "Bloqueio do socorrista selecionado"
          message ""
          initialize ws.pstcoddig  to null
          initialize ws.prssitcod  to null

          if d_ctc44m00.srrcoddig  is not null   then

             declare c_datrsrrpst_2  cursor for
                select pstcoddig, vigfnl
                  from datrsrrpst
                 where srrcoddig  =  d_ctc44m00.srrcoddig
                 order by vigfnl desc

             open  c_datrsrrpst_2
             fetch c_datrsrrpst_2  into  ws.pstcoddig
             close c_datrsrrpst_2

             if ws.pstcoddig  is not null   then
                select prssitcod
                  into ws.prssitcod
                  from dpaksocor
                 where pstcoddig  =  ws.pstcoddig

                if ws.prssitcod  <>  "A"   then
                   case ws.prssitcod
                      when "C" error " Socorrista possui vinculo com prestador cancelado, nao deve ser alterado!"
                      when "P" error " Socorrista possui vinculo com prestador em proposta, nao deve ser alterado!"
                      when "B" error " Socorrista possui vinculo com prestador bloqueado, nao deve ser alterado!"
                   end case
                   continue menu
                end if
             end if

             call ctx37g00_bloqueio(m_cabec.*)

             call ctc44m00_display(d_ctc44m00.*)

             next option "Seleciona"
          else
             error " Nenhum socorrista selecionado!"
             next option "Seleciona"
          end if

 command key ("T") "presTador"
                   "Vinculo entre socorrista e prestador"
          message ""
          if d_ctc44m00.srrcoddig  is not null then
             call ctc44m03(d_ctc44m00.srrcoddig, d_ctc44m00.srrnom)
             next option "Seleciona"
          else
             error " Nenhum socorrista selecionado!"
             next option "Seleciona"
          end if

 command key ("I") "Inclui"
                   "Inclui socorrista"
          message ""
          clear form
          call ctc44m00_inclui('','','','','','','','','','','','','')
          next option "Seleciona"
          initialize d_ctc44m00.*  to null

 command key ("N") "assisteNcias"
                   "Tipo de assistencia do socorrista corrente selecionado"
          message ""
          if d_ctc44m00.srrcoddig  is not null then
             call ctc44m06(d_ctc44m00.srrcoddig, d_ctc44m00.srrnom)
             next option "Seleciona"
          else
             error " Nenhum socorrista selecionado!"
             next option "Seleciona"
          end if

 command key ("R") "natuRezas"
                    "Naturezas do socorrista corrente selecionado"
          message ""
          if d_ctc44m00.srrcoddig is not null then
                call ctc74m00(d_ctc44m00.srrcoddig, d_ctc44m00.srrnom)
                next option "Seleciona"
          end if

 command key ("U") "pesqUisa"
                   "Pesquisa socorrista por: prestador, situacao, parte do nome"
          message ""
          initialize d_ctc44m00.*  to null
          call ctc44m00_display(d_ctc44m00.*)

          call ctc44m05()  returning d_ctc44m00.srrcoddig
          display by name d_ctc44m00.srrcoddig

          next option "Seleciona"

   command key ("D")"raDar"
                    "Acesso ao Sistema Radar"
        call ctc44m00_radar(d_ctc44m00.pestip,
                            d_ctc44m00.cgccpfnum,
                            d_ctc44m00.cgcord,
                            d_ctc44m00.cgccpfdig,
                            d_ctc44m00.srrcoddig)

   command key ("H")"Historico"
                    "Historico dos socorristas"
        if d_ctc44m00.srrcoddig  is not null then
           call ctc44m07(d_ctc44m00.srrcoddig)
           next option "Seleciona"
        else
           error " Nenhum socorrista selecionado!"
           next option "Seleciona"
        end if

   command key ("L")"emaiL"
                    "Cadastro de email"
        if d_ctc44m00.srrcoddig is not null then
           call ctc44m00_cadastro_email(d_ctc44m00.maides ,d_ctc44m00.srrcoddig)
        else
           error " Nenhum socorrista selecionado!"
           next option "Seleciona"
        end if

    command key ("O")"sOlicitar cracha"
                    "Solicitacao de cracha"
        if d_ctc44m00.srrcoddig is not null then

           call ctc44m03_email(d_ctc44m00.srrcoddig,"Menu")
           #let param_popup.linha2 = "ATENCAO: Um novo cracha sera solicitado"
           #let param_popup.linha3 = "      ao fornecedor."
           #call cts08g01("A","F",param_popup.linha1,
           #                      param_popup.linha2,
           #                      param_popup.linha3,
           #                      param_popup.linha4)
           #           returning  param_popup.confirma
           #           if(param_popup.confirma = "N")then
           #                   next option "sOlicitar cracha"
           #           else
           #                   call ctc44m03_email(d_ctc44m00.srrcoddig,"Menu")
           #           end if
           #
        else
           error " Nenhum socorrista selecionado!"
           next option "Seleciona"
        end if

 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctc44m00

 end function  ###  ctc44m00

#------------------------------------------------------------
 function ctc44m00_seleciona(param)
#------------------------------------------------------------

 define param         record
    srrcoddig         like datksrr.srrcoddig
 end record

 define d_ctc44m00    record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
### srrsttdes         char (10),
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,
    cnhmotctg         like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char (1),
    coderro           integer           ## Codigo erro func externas
 end record


 let int_flag = false
 initialize d_ctc44m00.*  to null
 clear form

 let d_ctc44m00.srrcoddig = param.srrcoddig


 input by name d_ctc44m00.srrcoddig   without defaults

    before field srrcoddig
        display by name d_ctc44m00.srrcoddig attribute (reverse)

    after  field srrcoddig
        display by name d_ctc44m00.srrcoddig

        if d_ctc44m00.srrcoddig  is null   then
           error " Socorrista deve ser informado!"
           next field srrcoddig
        end if

        select srrcoddig
          from datksrr
         where datksrr.srrcoddig = d_ctc44m00.srrcoddig

        if sqlca.sqlcode  =  notfound   then
           error " Socorrista nao cadastrado!"
           next field srrcoddig
        end if

    on key (interrupt)
        exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc44m00.*   to null
    call ctc44m00_display(d_ctc44m00.*)
    error " Operacao cancelada!"
    return d_ctc44m00.*
 end if

 call ctc44m00_ler(d_ctc44m00.srrcoddig)
      returning d_ctc44m00.*

 if d_ctc44m00.srrcoddig  is not null   then
    call ctc44m00_display(d_ctc44m00.*)
 else
    error " Socorrista nao cadastrado!"
    initialize d_ctc44m00.*    to null
 end if

 return d_ctc44m00.*

end function  ###  ctc44m00_seleciona


#------------------------------------------------------------
 function ctc44m00_proximo(param)
#------------------------------------------------------------

 define param         record
    srrcoddig         like datksrr.srrcoddig
 end record

 define d_ctc44m00    record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
### srrsttdes         char (10),
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,
    cnhmotctg         like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char (1),
    coderro           integer            ## Codigo erro func externas
 end record


 let int_flag = false
 initialize d_ctc44m00.*   to null

 if param.srrcoddig  is null   then
    let param.srrcoddig = 0
 end if

 select min(datksrr.srrcoddig)
   into d_ctc44m00.srrcoddig
   from datksrr
  where datksrr.srrcoddig  >  param.srrcoddig

 if d_ctc44m00.srrcoddig  is not null   then

    call ctc44m00_ler(d_ctc44m00.srrcoddig)
         returning d_ctc44m00.*

    if d_ctc44m00.srrcoddig  is not null   then
       call ctc44m00_display(d_ctc44m00.*)
    else
       error " Nao ha' socorrista nesta direcao!"
       initialize d_ctc44m00.*    to null
    end if
 else
    error " Nao ha' socorrista nesta direcao!"
    initialize d_ctc44m00.*    to null
 end if

 return d_ctc44m00.*

end function  ###  ctc44m00_proximo


#------------------------------------------------------------
 function ctc44m00_anterior(param)
#------------------------------------------------------------

 define param         record
    srrcoddig         like datksrr.srrcoddig
 end record

 define d_ctc44m00    record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
### srrsttdes         char (10),
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,
    cnhmotctg         like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char (1),
    coderro           integer       ## Codigo erro func externas
 end record


 let int_flag = false
 initialize d_ctc44m00.*  to null

 if param.srrcoddig  is null   then
    let param.srrcoddig = 0
 end if

 select max(datksrr.srrcoddig)
   into d_ctc44m00.srrcoddig
   from datksrr
  where datksrr.srrcoddig  <  param.srrcoddig

 if d_ctc44m00.srrcoddig  is not null   then

    call ctc44m00_ler(d_ctc44m00.srrcoddig)
         returning d_ctc44m00.*

    if d_ctc44m00.srrcoddig  is not null   then
       call ctc44m00_display(d_ctc44m00.*)
    else
       error " Nao ha' socorrista nesta direcao!"
       initialize d_ctc44m00.*    to null
    end if
 else
    error " Nao ha' socorrista nesta direcao!"
    initialize d_ctc44m00.*    to null
 end if

 return d_ctc44m00.*

end function  ###  ctc44m00_anterior


#------------------------------------------------------------
 function ctc44m00_modifica(param, d_ctc44m00)
#------------------------------------------------------------

 define param         record
    srrcoddig         like datksrr.srrcoddig
 end record

 define d_ctc44m00    record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
### srrsttdes         char (10),
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,
    cnhmotctg         like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char (1),
    coderro           integer         ## Codigo erro func externas
 end record

   define lr_ctc44m00_ant record
          srrnom          like datksrr.srrnom
         ,srrabvnom       like datksrr.srrabvnom
         ,srrstt          like datksrr.srrstt
       # ,srrsttdes       char (10)
         ,srrsttdes       char (24) #--> PSI-21950
         ,sexcod          like datksrr.sexcod
         ,nscdat          like datksrr.nscdat
         ,estcvlcod       like datksrr.estcvlcod
         ,pesalt          like datksrr.pesalt
         ,pespso          like datksrr.pespso
         ,srrcmsnum       like datksrr.srrcmsnum
         ,srrclcnum       like datksrr.srrclcnum
         ,srrcldnum       like datksrr.srrcldnum
         ,rgenum          like datksrr.rgenum
         ,rgeufdcod       like datksrr.rgeufdcod
         ,pestip          like datksrr.pestip
         ,cgccpfnum       like datksrr.cgccpfnum
         ,cgcord          like datksrr.cgcord
         ,cgccpfdig       like datksrr.cgccpfdig
         ,cprnum          like datksrr.cprnum
         ,cprsernum       like datksrr.cprsernum
         ,cprufdcod       like datksrr.cprufdcod
         ,cnhnum          like datksrr.cnhnum
         ,cnhautctg       like datksrr.cnhautctg
         ,cnhmotctg       like datksrr.cnhmotctg
         ,cnhpridat       like datksrr.cnhpridat
         ,exmvctdat       like datksrr.exmvctdat
         ,celdddcod       like datksrr.celdddcod
         ,celtelnum       like datksrr.celtelnum
         ,empcod          like datksrr.empcod
         ,funmat          like datksrr.funmat
         ,funmatdig       dec (1,0)
         ,nxtdddcod       like datksrr.nxtdddcod
         ,nxtide          like datksrr.nxtide
         ,nxtnum          like datksrr.nxtnum
         ,srrprnnom       like datksrr.srrprnnom
         ,srrtip          like datksrr.srrtip
         ,socanlsitcod    like datksrr.socanlsitcod
         ,rdranlultdat    like datksrr.rdranlultdat
         ,rdranlsitcod    like datksrr.rdranlsitcod
         ,separador1      char(01)
         ,separador2      char(01)
         ,separador3      char(01)
         ,descsocor       char(20)
         ,descps          char(20)
         ,descradar       char(20)
         ,painom          like datksrr.painom
         ,maenom          like datksrr.maenom
         ,nacdes          like datksrr.nacdes
         ,ufdcod          like datksrr.ufdcod
         ,lgdtip          like datksrrend.lgdtip
         ,lgdnom          like datksrrend.lgdnom
         ,lgdnum          like datksrrend.lgdnum
         ,endlgdcmp       like datksrrend.endlgdcmp
         ,brrnom          like datksrrend.brrnom
         ,cidnom          like datksrrend.cidnom
         ,endufdcod       like datksrrend.ufdcod
         ,endcep          like datksrrend.endcep
         ,endcepcmp       like datksrrend.endcepcmp
         ,lgdrefptodes    like datksrrend.lgdrefptodes
         ,dddcod          like datksrrend.dddcod
         ,telnum          like datksrrend.telnum
         ,srrendobs       like datksrrend.srrendobs
         ,cojnom          like datksrr.cojnom
         ,srrdpdqtd       like datksrr.srrdpdqtd
         ,maides            like datksrr.maides
          end record
  
   define lr_erro record
          coderr integer
         ,codmsg char(100)
         ,usrcod char(10)
         ,resp   char(1)
   end record

   define  l_flg          integer
   define  l_mensmail     char(2000)
   define  l_stt          smallint
   define  l_srrcodtxt    char(6)

   define l_res       smallint
         ,l_msg       char(100)


   initialize lr_ctc44m00_ant,
              l_res,
              l_msg to null

   let lr_ctc44m00_ant.srrnom       = d_ctc44m00.srrnom
   let lr_ctc44m00_ant.srrabvnom    = d_ctc44m00.srrabvnom
   let lr_ctc44m00_ant.srrstt       = d_ctc44m00.srrstt
   let lr_ctc44m00_ant.srrsttdes    = d_ctc44m00.srrsttdes
   let lr_ctc44m00_ant.sexcod       = d_ctc44m00.sexcod
   let lr_ctc44m00_ant.nscdat       = d_ctc44m00.nscdat
   let lr_ctc44m00_ant.estcvlcod    = d_ctc44m00.estcvlcod
   let lr_ctc44m00_ant.pesalt       = d_ctc44m00.pesalt
   let lr_ctc44m00_ant.pespso       = d_ctc44m00.pespso
   let lr_ctc44m00_ant.srrcmsnum    = d_ctc44m00.srrcmsnum
   let lr_ctc44m00_ant.srrclcnum    = d_ctc44m00.srrclcnum
   let lr_ctc44m00_ant.srrcldnum    = d_ctc44m00.srrcldnum
   let lr_ctc44m00_ant.rgenum       = d_ctc44m00.rgenum
   let lr_ctc44m00_ant.rgeufdcod    = d_ctc44m00.rgeufdcod
   let lr_ctc44m00_ant.pestip       = d_ctc44m00.pestip
   let lr_ctc44m00_ant.cgccpfnum    = d_ctc44m00.cgccpfnum
   let lr_ctc44m00_ant.cgcord       = d_ctc44m00.cgcord
   let lr_ctc44m00_ant.cgccpfdig    = d_ctc44m00.cgccpfdig
   let lr_ctc44m00_ant.cprnum       = d_ctc44m00.cprnum
   let lr_ctc44m00_ant.cprsernum    = d_ctc44m00.cprsernum
   let lr_ctc44m00_ant.cprufdcod    = d_ctc44m00.cprufdcod
   let lr_ctc44m00_ant.cnhnum       = d_ctc44m00.cnhnum
   let lr_ctc44m00_ant.cnhautctg    = d_ctc44m00.cnhautctg
   let lr_ctc44m00_ant.cnhmotctg    = d_ctc44m00.cnhmotctg
   let lr_ctc44m00_ant.cnhpridat    = d_ctc44m00.cnhpridat
   let lr_ctc44m00_ant.exmvctdat    = d_ctc44m00.exmvctdat
   let lr_ctc44m00_ant.celdddcod    = d_ctc44m00.celdddcod
   let lr_ctc44m00_ant.celtelnum    = d_ctc44m00.celtelnum
   let lr_ctc44m00_ant.empcod       = d_ctc44m00.empcod
   let lr_ctc44m00_ant.funmat       = d_ctc44m00.funmat
   let lr_ctc44m00_ant.funmatdig    = d_ctc44m00.funmatdig
   let lr_ctc44m00_ant.nxtdddcod    = d_ctc44m00.nxtdddcod
   let lr_ctc44m00_ant.nxtide       = d_ctc44m00.nxtide
   let lr_ctc44m00_ant.nxtnum       = d_ctc44m00.nxtnum
   let lr_ctc44m00_ant.srrprnnom    = d_ctc44m00.srrprnnom
   let lr_ctc44m00_ant.srrtip       = d_ctc44m00.srrtip
   let lr_ctc44m00_ant.socanlsitcod = d_ctc44m00.socanlsitcod
   let lr_ctc44m00_ant.rdranlultdat = d_ctc44m00.rdranlultdat
   let lr_ctc44m00_ant.rdranlsitcod = d_ctc44m00.rdranlsitcod
   let lr_ctc44m00_ant.separador1   = d_ctc44m00.separador1
   let lr_ctc44m00_ant.separador2   = d_ctc44m00.separador2
   let lr_ctc44m00_ant.separador3   = d_ctc44m00.separador3
   let lr_ctc44m00_ant.descsocor    = d_ctc44m00.descsocor
   let lr_ctc44m00_ant.descps       = d_ctc44m00.descps
   let lr_ctc44m00_ant.descradar    = d_ctc44m00.descradar
   let lr_ctc44m00_ant.painom       = d_ctc44m00.painom
   let lr_ctc44m00_ant.maenom       = d_ctc44m00.maenom
   let lr_ctc44m00_ant.nacdes       = d_ctc44m00.nacdes
   let lr_ctc44m00_ant.ufdcod       = d_ctc44m00.ufdcod
   let lr_ctc44m00_ant.lgdtip       = d_ctc44m00.lgdtip
   let lr_ctc44m00_ant.lgdnom       = d_ctc44m00.lgdnom
   let lr_ctc44m00_ant.lgdnum       = d_ctc44m00.lgdnum
   let lr_ctc44m00_ant.endlgdcmp    = d_ctc44m00.endlgdcmp
   let lr_ctc44m00_ant.brrnom       = d_ctc44m00.brrnom
   let lr_ctc44m00_ant.cidnom       = d_ctc44m00.cidnom
   let lr_ctc44m00_ant.endufdcod    = d_ctc44m00.endufdcod
   let lr_ctc44m00_ant.endcep       = d_ctc44m00.endcep
   let lr_ctc44m00_ant.endcepcmp    = d_ctc44m00.endcepcmp
   let lr_ctc44m00_ant.lgdrefptodes = d_ctc44m00.lgdrefptodes
   let lr_ctc44m00_ant.dddcod       = d_ctc44m00.dddcod
   let lr_ctc44m00_ant.telnum       = d_ctc44m00.telnum
   let lr_ctc44m00_ant.srrendobs    = d_ctc44m00.srrendobs
   let lr_ctc44m00_ant.cojnom       = d_ctc44m00.cojnom
   let lr_ctc44m00_ant.srrdpdqtd    = d_ctc44m00.srrdpdqtd
   let lr_ctc44m00_ant.maides       = d_ctc44m00.maides

 call ctc44m00_input("a", d_ctc44m00.*) returning d_ctc44m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc44m00.*  to null
    call ctc44m00_display(d_ctc44m00.*)
    error " Operacao cancelada!" sleep 2
    return d_ctc44m00.*
 end if

 whenever error continue

 let d_ctc44m00.atldat = today

 begin work

 call ctc30m00_remove_caracteres(d_ctc44m00.srrnom)
            returning d_ctc44m00.srrnom

 call ctc30m00_remove_caracteres(d_ctc44m00.srrabvnom)
            returning d_ctc44m00.srrabvnom

 call ctc30m00_remove_caracteres(d_ctc44m00.painom)
            returning d_ctc44m00.painom

 call ctc30m00_remove_caracteres(d_ctc44m00.maenom)
            returning d_ctc44m00.maenom

 call ctc30m00_remove_caracteres(d_ctc44m00.cojnom)
            returning d_ctc44m00.cojnom

 call ctc30m00_remove_caracteres(d_ctc44m00.srrprnnom)
            returning d_ctc44m00.srrprnnom


  if  ctd40g00_permissao_atl(g_issk.funmat) then
      display 'PARAMETROS PARA ATUALIZA��O'
      display 'd_ctc44m00.srrnom      : ',d_ctc44m00.srrnom     clipped
      display 'd_ctc44m00.srrabvnom   : ',d_ctc44m00.srrabvnom  clipped
      display 'd_ctc44m00.srrstt      : ',d_ctc44m00.srrstt
      display 'd_ctc44m00.sexcod      : ',d_ctc44m00.sexcod
      display 'd_ctc44m00.nscdat      : ',d_ctc44m00.nscdat
      display 'd_ctc44m00.painom      : ',d_ctc44m00.painom   clipped
      display 'd_ctc44m00.maenom      : ',d_ctc44m00.maenom   clipped
      display 'd_ctc44m00.nacdes      : ',d_ctc44m00.nacdes
      display 'd_ctc44m00.ufdcod      : ',d_ctc44m00.ufdcod
      display 'd_ctc44m00.estcvlcod   : ',d_ctc44m00.estcvlcod
      display 'd_ctc44m00.cojnom      : ',d_ctc44m00.cojnom
      display 'd_ctc44m00.srrdpdqtd   : ',d_ctc44m00.srrdpdqtd
      display 'd_ctc44m00.pesalt      : ',d_ctc44m00.pesalt
      display 'd_ctc44m00.pespso      : ',d_ctc44m00.pespso
      display 'd_ctc44m00.srrcmsnum   : ',d_ctc44m00.srrcmsnum
      display 'd_ctc44m00.srrclcnum   : ',d_ctc44m00.srrclcnum
      display 'd_ctc44m00.srrcldnum   : ',d_ctc44m00.srrcldnum
      display 'd_ctc44m00.rgenum      : ',d_ctc44m00.rgenum
      display 'd_ctc44m00.rgeufdcod   : ',d_ctc44m00.rgeufdcod
      display 'd_ctc44m00.pestip      : ',d_ctc44m00.pestip
      display 'd_ctc44m00.cgccpfnum   : ',d_ctc44m00.cgccpfnum
      display 'd_ctc44m00.cgcord      : ',d_ctc44m00.cgcord
      display 'd_ctc44m00.cgccpfdig   : ',d_ctc44m00.cgccpfdig
      display 'd_ctc44m00.cprnum      : ',d_ctc44m00.cprnum
      display 'd_ctc44m00.cprsernum   : ',d_ctc44m00.cprsernum
      display 'd_ctc44m00.cprufdcod   : ',d_ctc44m00.cprufdcod
      display 'd_ctc44m00.cnhnum      : ',d_ctc44m00.cnhnum
      display 'd_ctc44m00.cnhautctg   : ',d_ctc44m00.cnhautctg
      display 'd_ctc44m00.cnhmotctg   : ',d_ctc44m00.cnhmotctg
      display 'd_ctc44m00.cnhpridat   : ',d_ctc44m00.cnhpridat
      display 'd_ctc44m00.exmvctdat   : ',d_ctc44m00.exmvctdat
      display 'd_ctc44m00.celdddcod   : ',d_ctc44m00.celdddcod
      display 'd_ctc44m00.celtelnum   : ',d_ctc44m00.celtelnum
      display 'd_ctc44m00.empcod      : ',d_ctc44m00.empcod
      display 'd_ctc44m00.funmat      : ',d_ctc44m00.funmat
      display 'd_ctc44m00.nxtdddcod   : ',d_ctc44m00.nxtdddcod
      display 'd_ctc44m00.nxtide      : ',d_ctc44m00.nxtide
      display 'd_ctc44m00.nxtnum      : ',d_ctc44m00.nxtnum
      display 'd_ctc44m00.srrprnnom   : ',d_ctc44m00.srrprnnom  clipped
      display 'd_ctc44m00.atldat      : ',d_ctc44m00.atldat
      display 'g_issk.empcod          : ',g_issk.empcod
      display 'g_issk.funmat          : ',g_issk.funmat
      display 'd_ctc44m00.srrtip      : ',d_ctc44m00.srrtip
      display 'lr_ctc44m00_ant.socanlsitcod: ',lr_ctc44m00_ant.socanlsitcod
      display 'd_ctc44m00.socanlsitcod: ',d_ctc44m00.socanlsitcod
      display 'd_ctc44m00.rdranlultdat: ',d_ctc44m00.rdranlultdat
      display 'd_ctc44m00.rdranlsitcod: ',d_ctc44m00.rdranlsitcod

  end if

 update datksrr set  ( srrnom      , srrabvnom,
                       srrstt      , sexcod,
                       nscdat      , painom,
                       maenom      , nacdes,
                       ufdcod      , estcvlcod,
                       cojnom      , srrdpdqtd,
                       pesalt      , pespso,
                       srrcmsnum   , srrclcnum,
                       srrcldnum   , rgenum,
                       rgeufdcod   , pestip,
                       cgccpfnum   , cgcord,
                       cgccpfdig   , cprnum,
                       cprsernum   , cprufdcod,
                       cnhnum      , cnhautctg,
                       cnhmotctg   , cnhpridat,
                       exmvctdat   , celdddcod,
                       celtelnum   , empcod   ,
                       funmat      , nxtdddcod,
                       nxtide      , nxtnum   ,
                       srrprnnom   , atldat   ,
                       atlemp      , atlmat   ,
                       srrtip      , socanlsitcod,
                       rdranlultdat, rdranlsitcod)

                     =  ( d_ctc44m00.srrnom      , d_ctc44m00.srrabvnom,
                          d_ctc44m00.srrstt      , d_ctc44m00.sexcod,
                          d_ctc44m00.nscdat      , d_ctc44m00.painom,
                          d_ctc44m00.maenom      , d_ctc44m00.nacdes,
                          d_ctc44m00.ufdcod      , d_ctc44m00.estcvlcod,
                          d_ctc44m00.cojnom      , d_ctc44m00.srrdpdqtd,
                          d_ctc44m00.pesalt      , d_ctc44m00.pespso,
                          d_ctc44m00.srrcmsnum   , d_ctc44m00.srrclcnum,
                          d_ctc44m00.srrcldnum   , d_ctc44m00.rgenum,
                          d_ctc44m00.rgeufdcod   , d_ctc44m00.pestip,
                          d_ctc44m00.cgccpfnum   , d_ctc44m00.cgcord,
                          d_ctc44m00.cgccpfdig   , d_ctc44m00.cprnum,
                          d_ctc44m00.cprsernum   , d_ctc44m00.cprufdcod,
                          d_ctc44m00.cnhnum      , d_ctc44m00.cnhautctg,
                          d_ctc44m00.cnhmotctg   , d_ctc44m00.cnhpridat,
                          d_ctc44m00.exmvctdat   , d_ctc44m00.celdddcod,
                          d_ctc44m00.celtelnum   , d_ctc44m00.empcod   ,
                          d_ctc44m00.funmat      , d_ctc44m00.nxtdddcod   ,
                          d_ctc44m00.nxtide      , d_ctc44m00.nxtnum ,
                          d_ctc44m00.srrprnnom   , d_ctc44m00.atldat ,
                          g_issk.empcod          , g_issk.funmat ,
                          d_ctc44m00.srrtip      , d_ctc44m00.socanlsitcod,
                          d_ctc44m00.rdranlultdat, d_ctc44m00.rdranlsitcod)

        where datksrr.srrcoddig  =  d_ctc44m00.srrcoddig

    if sqlca.sqlcode  <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do socorrista!" sleep 2
       display '*************ERRO NA ATUALIZACAO*************'
       display " Erro (",sqlca.sqlcode,") na alteracao do socorrista!"
       display '*********************************************'
       rollback work
       initialize d_ctc44m00.*   to null
       return d_ctc44m00.*
    else
       if  ctd40g00_permissao_atl(g_issk.funmat) then
          DISPLAY 'update realizado com sucesso'
       end if
    end if

    call ctc30m00_remove_caracteres(d_ctc44m00.lgdnom)
            returning d_ctc44m00.lgdnom

    call ctc30m00_remove_caracteres(d_ctc44m00.brrnom)
               returning d_ctc44m00.brrnom

    call ctc30m00_remove_caracteres(d_ctc44m00.cidnom)
               returning d_ctc44m00.cidnom

    call ctc30m00_remove_caracteres(d_ctc44m00.lgdrefptodes)
               returning d_ctc44m00.lgdrefptodes

    call ctc30m00_remove_caracteres(d_ctc44m00.srrendobs)
               returning d_ctc44m00.srrendobs

    whenever error continue
    select 1 from datksrrend
     where srrcoddig = d_ctc44m00.srrcoddig

    if status = notfound then
       insert into datksrrend ( srrcoddig, srrendtip,
                             lgdtip   , lgdnom,
                             lgdnum   , endlgdcmp,
                             brrnom   , cidnom,
                             ufdcod   , endcep,
                             endcepcmp, lgdrefptodes,
                             dddcod   , telnum,
                             srrendobs, caddat,
                             cademp   , cadmat,
                             atldat   , atlemp,
                             atlmat )
                   values ( d_ctc44m00.srrcoddig, 1,
                            d_ctc44m00.lgdtip   , d_ctc44m00.lgdnom,
                            d_ctc44m00.lgdnum   , d_ctc44m00.endlgdcmp,
                            d_ctc44m00.brrnom   , d_ctc44m00.cidnom,
                            d_ctc44m00.endufdcod, d_ctc44m00.endcep,
                            d_ctc44m00.endcepcmp, d_ctc44m00.lgdrefptodes,
                            d_ctc44m00.dddcod   , d_ctc44m00.telnum,
                            d_ctc44m00.srrendobs, d_ctc44m00.caddat,
                            g_issk.empcod       , g_issk.funmat,
                            d_ctc44m00.atldat   , g_issk.empcod,
                            g_issk.funmat )


    else
    update datksrrend set ( lgdtip   , lgdnom,
                            lgdnum   , endlgdcmp,
                            brrnom   , cidnom,
                            ufdcod   , endcep,
                            endcepcmp, lgdrefptodes,
                            dddcod   , telnum,
                            srrendobs, atldat,
                            atlemp   , atlmat )
                       =  ( d_ctc44m00.lgdtip   , d_ctc44m00.lgdnom,
                            d_ctc44m00.lgdnum   , d_ctc44m00.endlgdcmp,
                            d_ctc44m00.brrnom   , d_ctc44m00.cidnom,
                            d_ctc44m00.endufdcod, d_ctc44m00.endcep,
                            d_ctc44m00.endcepcmp, d_ctc44m00.lgdrefptodes,
                            d_ctc44m00.dddcod   , d_ctc44m00.telnum,
                            d_ctc44m00.srrendobs, d_ctc44m00.atldat,
                            g_issk.empcod       , g_issk.funmat )
          where datksrrend.srrcoddig  =  d_ctc44m00.srrcoddig
            and datksrrend.srrendtip  =  1


    end if
    whenever error stop



    if sqlca.sqlcode  <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do endereco do socorrista!" sleep 2
       display '*************ERRO NA ATUALIZACAO*************'
       display " Erro (",sqlca.sqlcode,") na alteracao do endereco do socorrista!"
       display '*********************************************'
       rollback work
       initialize d_ctc44m00.*   to null
       return d_ctc44m00.*
    else

       error " Alteracao efetuada com sucesso!"
       if  ctd40g00_permissao_atl(g_issk.funmat) then
          display "ENDERECO ALTERADO COM SUCESSO"
       end if
    end if

    let l_srrcodtxt = d_ctc44m00.srrcoddig using "<<<<<<&"
    if d_ctc44m00.srrtip = 3 then  # Alarmes Monitorados
       # Grava na tabela para sincronismo com o sistema de Alarmes Monitorados
       insert into igbkgeral values("QRA", l_srrcodtxt, "00:01", "")
    else
       # Remove da tabela de sincronismo com o sistema de Alarmes Monitorados
       delete from igbkgeral where mducod = 'QRA' and grlchv = l_srrcodtxt
    end if

    #--> PSI-21950 - Inicio 
    if lr_ctc44m00_ant.srrstt <> d_ctc44m00.srrstt then
       call cty38g00_finaliza_bloq_progr (d_ctc44m00.srrcoddig,d_ctc44m00.srrstt)
            returning l_stt, l_msg
       if l_stt <> 0 then
          rollback work
          error l_msg clipped
          initialize d_ctc44m00.* to null
          return d_ctc44m00.*
       end if
    end if
    #--> PSI-21950 - Final

 commit work

 #if  lr_ctc44m00_ant.srrabvnom <> d_ctc44m00.srrabvnom or
 #    lr_ctc44m00_ant.celdddcod <> d_ctc44m00.celdddcod or
 #    lr_ctc44m00_ant.celtelnum <> d_ctc44m00.celtelnum or
 #    lr_ctc44m00_ant.maides    <> d_ctc44m00.maides    then
     if  ctd40g00_permissao_atl(g_issk.funmat) then
        display 'chamada ctd40g00_usrweb_qra("A")', d_ctc44m00.srrcoddig
     end if


 #if  (lr_ctc44m00_ant.socanlsitcod <> d_ctc44m00.socanlsitcod) or
 #    (lr_ctc44m00_ant.srrstt       <> d_ctc44m00.srrstt)       then
 #
 #    display "ENTROU"
 #
 #    #call ctd30g00_busca_qra_cpf("CPF", d_ctc44m00.srrcoddig)
 #    #     returning l_stt,
 #    #               l_msg,
 #    #               l_cgccpfnum

     # DESBLOQUEIA
 #end if

   if lr_ctc44m00_ant.socanlsitcod = 2 and d_ctc44m00.socanlsitcod = 1 then
     call ctd40g00_usrweb_qra("I",
                              d_ctc44m00.srrcoddig,
                              d_ctc44m00.srrabvnom,
                              d_ctc44m00.celdddcod,
                              d_ctc44m00.celtelnum,
                              d_ctc44m00.maides)
          returning lr_erro.coderr,
                    lr_erro.codmsg,
                    lr_erro.usrcod

     if  l_stt = 0 then

             let l_msg = "SOCORRISTA E ", lr_erro.usrcod clipped

             call cts08g01("A","N",
                          "O USUARIO PORTONET PRESTADOR",
                          l_msg,
                          "PARA EFETUAR LOGIN FORAM",
                          "ENVIADOS VIA E-MAIL AO SOCORRISTA")
             returning lr_erro.resp
     end if
	 else       
	        call ctd40g00_usrweb_qra("A",
                              d_ctc44m00.srrcoddig,
                              "",
                              "",
                              "",
                              "")
      returning l_stt,
                l_msg

     if  l_stt = 0 then
         error "Alteragco de usuario internet efetuada com sucesso."
      else
          error "Problema na alteragco do usuario Portonet. ERRO: ", l_stt
     end if

   end if

 whenever error stop

 call ctc44m00_verifica_mod(lr_ctc44m00_ant.*
                           ,d_ctc44m00.*)

 initialize d_ctc44m00.*  to null
 call ctc44m00_display(d_ctc44m00.*)
 message ""
 return d_ctc44m00.*

end function  ###  ctc44m00_modifica


#------------------------------------------------------------
 function ctc44m00_inclui(lr_param)
#------------------------------------------------------------

define lr_param      record
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    pstcndnom         like isskfunc.funnom,     --- VERIFICAR SE ESTA CORRETO
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    nscdat            like datksrr.nscdat,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,   --- VERIFICAR SE ESTA CORRETO
    cnhpridat         like datksrr.cnhpridat,
    situacao          like datksrr.rdranlsitcod,
    rdranlultdat      like  datksrr.rdranlultdat
 end record

 define d_ctc44m00    record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
 ## srrsttdes         char (10),
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,
    cnhmotctg         like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char (1),
    coderro           integer                    ## Codigo erro func externas

 end record

 define ws            record
   grlinf             like igbkgeral.grlinf,
   srrcod             dec(7,0),
   resp               char(01)
 end record

   define l_mensagem   char(60)
         ,l_mesg       char(60)
         ,l_usrcod     char(10)
         ,l_stt        smallint

   define l_res       smallint
         ,l_msg       char(100)

   let l_res = null
   let l_msg = null

   let l_mensagem  = null
   let l_mesg      = null
   let l_stt       = null

 initialize ws.*          to null
 initialize d_ctc44m00.*  to null

 if (lr_param. pestip    is not null or
     lr_param.cgccpfnum  is not null or
     lr_param. cgcord    is not null) then
   let d_ctc44m00.pestip       =  lr_param.pestip
   let d_ctc44m00.cgccpfnum    =  lr_param.cgccpfnum
   let d_ctc44m00.cgcord       =  lr_param.cgcord
   let d_ctc44m00.cgccpfdig    =  lr_param.cgccpfdig
   let d_ctc44m00.srrnom       =  lr_param.pstcndnom
   let d_ctc44m00.rgenum       =  lr_param.rgenum
   let d_ctc44m00.rgeufdcod    =  lr_param.rgeufdcod
   let d_ctc44m00.nscdat       =  lr_param.nscdat
   let d_ctc44m00.cnhnum       =  lr_param.cnhnum
   let d_ctc44m00.cnhautctg    =  lr_param.cnhautctg
   let d_ctc44m00.cnhpridat    =  lr_param.cnhpridat
   let d_ctc44m00.rdranlsitcod =  lr_param.situacao
   let d_ctc44m00.rdranlultdat =  lr_param.rdranlultdat
 end if

 call ctc44m00_display(d_ctc44m00.*)

 call ctc44m00_input("i", d_ctc44m00.*) returning d_ctc44m00.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc44m00.*  to null
    call ctc44m00_display(d_ctc44m00.*)
    error " Operacao cancelada!"
    return
 end if

 let d_ctc44m00.atldat = today
 let d_ctc44m00.caddat = today

#---------------------------------------------------------------
# Gera numero do socorrista com digito (modulo 11)
#---------------------------------------------------------------
 declare c_igbkgeral cursor with hold for
   select grlinf
     from igbkgeral
    where mducod  =  "C24"
      and grlchv  =  "SOCORRISTA"
      for update

 foreach c_igbkgeral into ws.grlinf
     exit foreach
 end foreach

 if ws.grlinf  is null   then
    let ws.grlinf = "0"
    let ws.srrcod =  0

    begin work
      insert into igbkgeral (mducod, grlchv      , grlinf   , atlult)
                   values   ("C24" , "SOCORRISTA", ws.grlinf, today)

      if sqlca.sqlcode  <>  0   then
         error " Erro na criacao do IGBKGERAL. AVISE A INFORMATICA!"
         rollback work
         return
      end if
    commit work

 else
    let ws.srrcod  =  ws.grlinf  using "&&&&&&&"
 end if

 let ws.srrcod  =  ws.srrcod + 1

 call F_FUNDIGIT_DIGITO11(ws.srrcod)
      returning d_ctc44m00.srrcoddig

 if d_ctc44m00.srrcoddig is null  then
    error " Erro no calculo do digito. AVISE A INFORMATICA!"
    return
 end if

 whenever error continue

 begin work
     call ctc30m00_remove_caracteres(d_ctc44m00.srrnom)
            returning d_ctc44m00.srrnom

     call ctc30m00_remove_caracteres(d_ctc44m00.srrabvnom)
                returning d_ctc44m00.srrabvnom

     call ctc30m00_remove_caracteres(d_ctc44m00.painom)
                returning d_ctc44m00.painom

     call ctc30m00_remove_caracteres(d_ctc44m00.maenom)
                returning d_ctc44m00.maenom

     call ctc30m00_remove_caracteres(d_ctc44m00.cojnom)
                returning d_ctc44m00.cojnom

     call ctc30m00_remove_caracteres(d_ctc44m00.srrprnnom)
            returning d_ctc44m00.srrprnnom


     insert into datksrr ( srrcoddig  ,
                          srrnom      , srrabvnom,
                          srrstt      , sexcod,
                          nscdat      , painom,
                          maenom      , nacdes,
                          ufdcod      , estcvlcod,
                          cojnom      , srrdpdqtd,
                          pesalt      , pespso,
                          srrcmsnum   , srrclcnum,
                          srrcldnum   , rgenum,
                          rgeufdcod   , pestip,
                          cgccpfnum   , cgcord,
                          cgccpfdig   , cprnum,
                          cprsernum   , cprufdcod,
                          cnhnum      , cnhautctg,
                          cnhmotctg   ,
                          cnhpridat   , exmvctdat,
                          celdddcod   , celtelnum,
                          empcod      , funmat,
                          nxtdddcod   , nxtide      , nxtnum,
                          srrprnnom   , caddat,
                          cademp      , cadmat,
                          atldat      , atlemp,
                          atlmat      , srrtip,
                          socanlsitcod, rdranlultdat,
                          rdranlsitcod, maides)
                 values ( d_ctc44m00.srrcoddig   ,
                          d_ctc44m00.srrnom      , d_ctc44m00.srrabvnom,
                          d_ctc44m00.srrstt      , d_ctc44m00.sexcod,
                          d_ctc44m00.nscdat      , d_ctc44m00.painom,
                          d_ctc44m00.maenom      , d_ctc44m00.nacdes,
                          d_ctc44m00.ufdcod      , d_ctc44m00.estcvlcod,
                          d_ctc44m00.cojnom      , d_ctc44m00.srrdpdqtd,
                          d_ctc44m00.pesalt      , d_ctc44m00.pespso,
                          d_ctc44m00.srrcmsnum   , d_ctc44m00.srrclcnum,
                          d_ctc44m00.srrcldnum   , d_ctc44m00.rgenum,
                          d_ctc44m00.rgeufdcod   , d_ctc44m00.pestip,
                          d_ctc44m00.cgccpfnum   , d_ctc44m00.cgcord,
                          d_ctc44m00.cgccpfdig   , d_ctc44m00.cprnum,
                          d_ctc44m00.cprsernum   , d_ctc44m00.cprufdcod,
                          d_ctc44m00.cnhnum      , d_ctc44m00.cnhautctg,
                          d_ctc44m00.cnhmotctg   ,
                          d_ctc44m00.cnhpridat   , d_ctc44m00.exmvctdat,
                          d_ctc44m00.celdddcod   , d_ctc44m00.celtelnum,
                          d_ctc44m00.empcod      , d_ctc44m00.funmat,
                          d_ctc44m00.nxtdddcod   ,
                          d_ctc44m00.nxtide      , d_ctc44m00.nxtnum,
                          d_ctc44m00.srrprnnom   , d_ctc44m00.caddat,
                          g_issk.empcod          , g_issk.funmat,
                          d_ctc44m00.atldat      , g_issk.empcod,
                          g_issk.funmat          , d_ctc44m00.srrtip,
                          d_ctc44m00.socanlsitcod, d_ctc44m00.rdranlultdat,
                          d_ctc44m00.rdranlsitcod, d_ctc44m00.maides)

    if sqlca.sqlcode  <>  0   then
       error " Erro (",sqlca.sqlcode,") na inclusao do socorrista!"
       rollback work
       return
    end if

    call ctd18g00_val_candidato(d_ctc44m00.cgccpfnum  # PSI - 239178
                                ,d_ctc44m00.cgcord
                                ,d_ctc44m00.cgccpfdig
                                ,d_ctc44m00.rgenum
                                ,d_ctc44m00.rgeufdcod
                                ,d_ctc44m00.cnhnum
                                ,d_ctc44m00.srrcoddig)
         returning l_res, l_msg

    call ctc30m00_remove_caracteres(d_ctc44m00.lgdnom)
            returning d_ctc44m00.lgdnom

    call ctc30m00_remove_caracteres(d_ctc44m00.brrnom)
               returning d_ctc44m00.brrnom

    call ctc30m00_remove_caracteres(d_ctc44m00.cidnom)
               returning d_ctc44m00.cidnom

    call ctc30m00_remove_caracteres(d_ctc44m00.lgdrefptodes)
               returning d_ctc44m00.lgdrefptodes

    call ctc30m00_remove_caracteres(d_ctc44m00.srrendobs)
               returning d_ctc44m00.srrendobs

    insert into datksrrend ( srrcoddig, srrendtip,
                             lgdtip   , lgdnom,
                             lgdnum   , endlgdcmp,
                             brrnom   , cidnom,
                             ufdcod   , endcep,
                             endcepcmp, lgdrefptodes,
                             dddcod   , telnum,
                             srrendobs, caddat,
                             cademp   , cadmat,
                             atldat   , atlemp,
                             atlmat )
                   values ( d_ctc44m00.srrcoddig, 1,
                            d_ctc44m00.lgdtip   , d_ctc44m00.lgdnom,
                            d_ctc44m00.lgdnum   , d_ctc44m00.endlgdcmp,
                            d_ctc44m00.brrnom   , d_ctc44m00.cidnom,
                            d_ctc44m00.endufdcod, d_ctc44m00.endcep,
                            d_ctc44m00.endcepcmp, d_ctc44m00.lgdrefptodes,
                            d_ctc44m00.dddcod   , d_ctc44m00.telnum,
                            d_ctc44m00.srrendobs, d_ctc44m00.caddat,
                            g_issk.empcod       , g_issk.funmat,
                            d_ctc44m00.atldat   , g_issk.empcod,
                            g_issk.funmat )

    if sqlca.sqlcode  <>  0   then
       error " Erro (",sqlca.sqlcode,") na inclusao do endereco do socorrista!"
       rollback work
       return
    end if

   update igbkgeral  set grlinf = ws.srrcod
    where mducod  =  "C24"
      and grlchv  =  "SOCORRISTA"

    if sqlca.sqlcode  <>  0   then
       error " Erro (",sqlca.sqlcode,") na atualizacao do IGBKGERAL!"
       rollback work
       return
    end if

 commit work

 whenever error stop

 let l_mensagem = 'Inclusao no cadastro do socorrista'
 let l_mesg = "Socorrista incluido [",d_ctc44m00.srrcoddig clipped,"] !"

 let l_stt = ctc44m00_grava_hist(d_ctc44m00.srrcoddig
                                ,l_mesg
                                ,d_ctc44m00.atldat
                                ,l_mensagem,"I")

 { if l_stt = 1  then
    let l_stt = ctc44m00_envia_email(l_mensagem
				   ,d_ctc44m00.atldat
				   ,current hour to minute
				   ,0,l_mesg)
 end if
 }

 call ctc44m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc44m00.cadfunnom

 call ctc44m00_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc44m00.funnom

 call ctc44m00_display(d_ctc44m00.*)

 display by name d_ctc44m00.srrcoddig attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws.resp

#---------------------------------------------------------------
# Cadastra vinculo entre socorrista X prestador
#---------------------------------------------------------------
 call cts08g01("A","S",
                   "PARA CONCLUIR O CADASTRAMENTO,",
                   "DEVE-SE INFORMAR O VINCULO ENTRE",
                   "O SOCORRISTA E O PRESTADOR!",
                   "")
      returning ws.resp

 call ctc44m03(d_ctc44m00.srrcoddig, d_ctc44m00.srrnom)

 if  d_ctc44m00.socanlsitcod = 2 then

     # INCLUI USUARIO PARA PORTONET PRESTADORES
     if  ctd40g00_permissao_atl(g_issk.funmat) then
        display 'chamada ctd40g00_usrweb_qra("I")', d_ctc44m00.srrcoddig
     end if
     call ctd40g00_usrweb_qra("I",
                              d_ctc44m00.srrcoddig,
                              d_ctc44m00.srrabvnom,
                              d_ctc44m00.celdddcod,
                              d_ctc44m00.celtelnum,
                              d_ctc44m00.maides)
          returning l_stt,
                    l_mesg,
                    l_usrcod

     if  l_stt = 0 then

             let l_msg = "SOCORRISTA E ", l_usrcod clipped

             call cts08g01("A","N",
                          "O USUARIO PORTONET PRESTADOR",
                          l_msg,
                          "PARA EFETUAR LOGIN FORAM",
                          "ENVIADOS VIA E-MAIL AO SOCORRISTA")
             returning ws.resp

   #         error "Inclusao de usuario internet efetuada com sucesso."
     else
         if  l_stt = -1 then

             call cts08g01("A","N",
                          "O USUARIO PARA ACESSO A",
                          "PORTONET DOS PRESTADORES NAO SERA CRIADO",
                          "DEVIDO A FALTA DOS DADOS NECESSARIOS.",
                          "")
             returning ws.resp

         else
             error "Problema na cria��o do usuario Portonet. ERRO: ", l_stt
         end if
     end if
 else

     call cts08g01("A","N",
                  "O USUARIO PARA ACESSO A",
                  "PORTONET DOS PRESTADORES NAO SERA CRIADO",
                  "JA QUE O USUARIO AINDA N�O EST� LIBERADO.",
                  "")
     returning ws.resp

 end if

 initialize d_ctc44m00.*  to null
 call ctc44m00_display(d_ctc44m00.*)

end function  ###  ctc44m00_dinclui

#--------------------------------------------------------------------
 function ctc44m00_input(param, d_ctc44m00)
#--------------------------------------------------------------------

 define param         record
    operacao          char (01)
 end record

 define d_ctc44m00    record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
### srrsttdes         char (10), #--> PSI-21950
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         char(01),   #like datksrr.cnhautctg,  #10/03/2016 - Fornax
    cnhmotctg         char(01),   #like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char (1),
    coderro           integer                    ## Codigo erro func externas
 end record

 define ws            record
    srrcoddig         like datksrr.srrcoddig,
    cgccpfdig         like datksrr.cgccpfdig,
    funmatdig         dec (7,0),
    cont              dec (6,0),
    retflg            char (01)
 end record

 define l_srrcoddig  like datksrr.srrcoddig,
        l_srrstt     like datksrr.srrstt, #--> PSI-21950
        l_prompt     char(77),            #--> PSI-21950
        l_resp       char(1),             #--> PSI-21950
        l_msg        char(61),
        minsrrclcnum like datksrr.srrclcnum,
        maxsrrclcnum like datksrr.srrclcnum

 define l_erro      smallint
       ,l_mensagem  char(100)
       ,l_ret_aux   char(100)

define param_popup   record
   linha1              char (40),
   linha2              char (40),
   linha3              char (40),
   linha4              char (40),
   confirma            char (1)
 end record

 let int_flag = false
 initialize ws.*  to null
 initialize param_popup.* to null

 let l_srrcoddig = null
 let l_msg       = null
 let l_erro     = null
 let l_mensagem = null
 let l_ret_aux  = null
 let l_srrstt   = d_ctc44m00.srrstt #--> PSI-21950

 input by name  d_ctc44m00.srrnom,
                d_ctc44m00.srrabvnom,
                d_ctc44m00.srrstt,
                d_ctc44m00.sexcod,
                d_ctc44m00.nscdat,
                d_ctc44m00.estcvlcod,
                d_ctc44m00.pesalt,
                d_ctc44m00.pespso,
                d_ctc44m00.srrcmsnum,
                d_ctc44m00.srrclcnum,
                d_ctc44m00.srrcldnum,
                d_ctc44m00.rgenum,
                d_ctc44m00.rgeufdcod,
                #d_ctc44m00.pestip,
                d_ctc44m00.cgccpfnum,
                d_ctc44m00.cgcord,
                d_ctc44m00.cgccpfdig,
                d_ctc44m00.cprnum,
                d_ctc44m00.cprsernum,
                d_ctc44m00.cprufdcod,
                d_ctc44m00.cnhnum,
                d_ctc44m00.cnhautctg,
                d_ctc44m00.cnhmotctg,
                d_ctc44m00.cnhpridat,
                d_ctc44m00.exmvctdat,
                d_ctc44m00.celdddcod,
                d_ctc44m00.celtelnum,
                d_ctc44m00.empcod,
                d_ctc44m00.funmat,
                d_ctc44m00.funmatdig,
                d_ctc44m00.nxtdddcod,
                d_ctc44m00.nxtide,
                d_ctc44m00.nxtnum,
                d_ctc44m00.srrprnnom,
                d_ctc44m00.srrtip,
                d_ctc44m00.socanlsitcod,
                d_ctc44m00.rdranlultdat,
                d_ctc44m00.rdranlsitcod,
                d_ctc44m00.separador1,
                d_ctc44m00.separador2,
                d_ctc44m00.separador3,
                d_ctc44m00.descsocor,
                d_ctc44m00.descps,
                d_ctc44m00.descradar     without defaults

    before field srrnom
           display by name d_ctc44m00.srrnom attribute (reverse)

    after  field srrnom
           display by name d_ctc44m00.srrnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srrnom
           end if

           if d_ctc44m00.srrnom  is null   then
              error " Nome do socorrista deve ser informado!"
              next field srrnom
           end if

           let ws.cont  =  0
           let ws.cont  = length(d_ctc44m00.srrnom)

           if ws.cont  <  10   then
              error " Nome nao deve conter menos que 10 caracteres!"
              next field srrnom
           end if

           let ws.retflg  =  "N"

         #  if param.operacao = 'a' then
         #  whenever error continue
         #     select lgdtip, lgdnom, lgdnum, brrnom,
         #            cidnom, endufdcod, endcep, endcepcmp,
         #            lgdrefptodes, dddcod, telnum, srrendobs
         #       into d_ctc44m00.lgdtip   , d_ctc44m00.lgdnom,
         #            d_ctc44m00.lgdnum   , d_ctc44m00.endlgdcmp,
         #            d_ctc44m00.brrnom   , d_ctc44m00.cidnom,
         #            d_ctc44m00.endufdcod, d_ctc44m00.endcep,
         #            d_ctc44m00.endcepcmp, d_ctc44m00.lgdrefptodes,
         #            d_ctc44m00.dddcod   , d_ctc44m00.telnum,
         #            d_ctc44m00.srrendobs
         #       from datksrrend
         #      where srrcoddig = d_ctc44m00.srrcoddig
         #  whenever error stop
         #  end if


           call ctc44m04( d_ctc44m00.lgdtip   , d_ctc44m00.lgdnom,
                          d_ctc44m00.lgdnum   , d_ctc44m00.endlgdcmp,
                          d_ctc44m00.brrnom   , d_ctc44m00.cidnom,
                          d_ctc44m00.endufdcod, d_ctc44m00.endcep,
                          d_ctc44m00.endcepcmp, d_ctc44m00.lgdrefptodes,
                          d_ctc44m00.dddcod   , d_ctc44m00.telnum,
                          d_ctc44m00.srrendobs )
               returning  d_ctc44m00.lgdtip   , d_ctc44m00.lgdnom,
                          d_ctc44m00.lgdnum   , d_ctc44m00.endlgdcmp,
                          d_ctc44m00.brrnom   , d_ctc44m00.cidnom,
                          d_ctc44m00.endufdcod, d_ctc44m00.endcep,
                          d_ctc44m00.endcepcmp, d_ctc44m00.lgdrefptodes,
                          d_ctc44m00.dddcod   , d_ctc44m00.telnum,
                          d_ctc44m00.srrendobs, ws.retflg

          call ctc30m00_remove_caracteres(d_ctc44m00.lgdtip)
            returning d_ctc44m00.lgdtip

           call ctc30m00_remove_caracteres(d_ctc44m00.lgdnom)
            returning d_ctc44m00.lgdnom

           call ctc30m00_remove_caracteres(d_ctc44m00.endlgdcmp)
            returning d_ctc44m00.endlgdcmp

           call ctc30m00_remove_caracteres(d_ctc44m00.brrnom)
            returning d_ctc44m00.brrnom

           call ctc30m00_remove_caracteres(d_ctc44m00.endcepcmp)
            returning d_ctc44m00.endcepcmp

           call ctc30m00_remove_caracteres(d_ctc44m00.lgdrefptodes)
            returning d_ctc44m00.lgdrefptodes

           call ctc30m00_remove_caracteres(d_ctc44m00.srrendobs)
            returning d_ctc44m00.srrendobs


          if ws.retflg  =  "N"   then
             error " Dados sobre o endereco incompletos!"
             next field srrnom
          end if

    before field srrabvnom
           display by name d_ctc44m00.srrabvnom attribute (reverse)

    after  field srrabvnom
           display by name d_ctc44m00.srrabvnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srrnom
           end if

           if d_ctc44m00.srrabvnom is null then
              next field  srrabvnom
           end if

           ## inibido por solicitacao do Rubinho 27/11/06 - PSI
           #if d_ctc44m00.srrabvnom  is not null   then
           #   let ws.cont  =  0
           #   let ws.cont  = length(d_ctc44m00.srrabvnom)

            # if ws.cont  <  5   then
            #    error " Nome abreviado nao deve conter menos que 5 caracteres!"
            #    next field srrabvnom
            # end if

            # initialize ws.srrcoddig  to null
            # select srrcoddig
            #   into ws.srrcoddig
            #   from datksrr
            #  where srrabvnom  =   d_ctc44m00.srrabvnom

            # if sqlca.sqlcode  =  0   then
            #    if param.operacao  =  "i"   then
            #       error " Nome abreviado ja' cadastrado --> ", ws.srrcoddig
            #       next field srrabvnom
            #    else
            #       if ws.srrcoddig  <>  d_ctc44m00.srrcoddig   then
            #          error " Nome abreviado ja' cadastrado --> ", ws.srrcoddig
            #          next field srrabvnom
            #       end if
            #    end if
            # end if
           #end if

    before field srrstt
           if param.operacao  =  "i"   then
              let d_ctc44m00.srrstt = 4
           
              select cpodes
                into d_ctc44m00.srrsttdes
                from iddkdominio
               where cponom  =  "srrstt"
                 and cpocod  =  d_ctc44m00.srrstt
           
              display by name d_ctc44m00.srrstt
              display by name d_ctc44m00.srrsttdes
              next field sexcod
           end if
           display by name d_ctc44m00.srrstt attribute (reverse)

    after  field srrstt
           display by name d_ctc44m00.srrstt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srrabvnom
           end if

           if d_ctc44m00.srrstt  is null   then
              error " Situacao do socorrista deve ser informado!"
              call ctn36c00("Situacao do socorrista", "srrstt")
                   returning  d_ctc44m00.srrstt
              next field srrstt
           end if

           #--> PSI-21950 - Inicio
	   if d_ctc44m00.srrstt = 2 then 
	      if d_ctc44m00.srrstt <> l_srrstt then
                 error " Para esta situacao utilize o menu Bloqueio, opcao Bloquear!"
		 let d_ctc44m00.srrstt = l_srrstt
                 next field srrstt
	      end if 
           end if 

	   if l_srrstt = 2 then 
	      if d_ctc44m00.srrstt <> l_srrstt then
                 let l_prompt = "Bloqueio por "
			      , cty38g00_motivo(d_ctc44m00.srrcoddig) clipped
			      , " vigente. Deseja modificar assim mesmo ? (S/N) :"
		 initialize l_resp to null
		 prompt l_prompt for l_resp
		 if l_resp <> "S" and l_resp <> "s" then 
		    let d_ctc44m00.srrstt = l_srrstt
                    next field srrstt
	         end if 
	      end if 
           end if 
           #--> PSI-21950 - Final

           select cpodes
             into d_ctc44m00.srrsttdes
             from iddkdominio
            where cponom  =  "srrstt"
              and cpocod  =  d_ctc44m00.srrstt

           if sqlca.sqlcode  =  notfound   then
              error " Situacao da socorrista nao cadastrado!"
              call ctn36c00("Situacao do socorrista", "srrstt")
                   returning  d_ctc44m00.srrstt
              next field srrstt
           end if
           display by name d_ctc44m00.srrsttdes

           if param.operacao     =  "i"  and
              d_ctc44m00.srrstt  <>  4   then
              error " Na inclusao situacao deve ser CANDIDATO!"
              next field srrstt
           end if

           #--> PSI-21950 - Inicio
	   if d_ctc44m00.srrstt = 2 then 
              let d_ctc44m00.srrsttdes = d_ctc44m00.srrsttdes clipped, "/",
				         cty38g00_motivo(d_ctc44m00.srrcoddig)
              display by name d_ctc44m00.srrsttdes
           end if
           #--> PSI-21950 - Final

    before field sexcod
           display by name d_ctc44m00.sexcod attribute (reverse)

    after  field sexcod
           display by name d_ctc44m00.sexcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.operacao  =  "i"   then
                 next field  srrabvnom
              end if
              next field  srrstt
           end if

           if (d_ctc44m00.sexcod  is null)   or
              (d_ctc44m00.sexcod  <>  "F"    and
               d_ctc44m00.sexcod  <>  "M")   then
              error " Sexo: (F)eminino, (M)asculino!"
              next field sexcod
           end if

    before field nscdat
           display by name d_ctc44m00.nscdat attribute (reverse)

    after  field nscdat
           display by name d_ctc44m00.nscdat

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  sexcod
           end if

           if d_ctc44m00.nscdat  is null   then
              error " Data de nascimento deve ser informada!"
              next field nscdat
           end if

           if d_ctc44m00.nscdat  >  today   then
              error " Data de nascimento nao deve ser maior que data atual!"
              next field nscdat
           end if

           if d_ctc44m00.nscdat  >  today - 18 units year   then
              error " Socorrista nao deve ter menos que 18 anos!"
              next field nscdat
           end if

           if d_ctc44m00.nscdat  <  today - 70 units year   then
              error " Socorrista nao deve ter mais que 55 anos!"
              next field nscdat
           end if

           let ws.retflg  =  "N"

           call ctc44m01( d_ctc44m00.maenom,
                          d_ctc44m00.painom,
                          d_ctc44m00.nacdes,
                          d_ctc44m00.ufdcod )
                returning d_ctc44m00.maenom,
                          d_ctc44m00.painom,
                          d_ctc44m00.nacdes,
                          d_ctc44m00.ufdcod,
                          ws.retflg

           if ws.retflg  =  "N"   then
              error " Dados sobre filiacao incompletos!"
              next field  nscdat
           end if

    before field estcvlcod
           display by name d_ctc44m00.estcvlcod attribute (reverse)

    after  field estcvlcod
           display by name d_ctc44m00.estcvlcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  nscdat
           end if

           if d_ctc44m00.estcvlcod  is null   then
              error " Estado civil deve ser informado!"
              call ctn36c00("Estado civil", "estcvlcod")
                   returning  d_ctc44m00.estcvlcod
              next field estcvlcod
           end if

           select cpodes
             into d_ctc44m00.estcvldes
             from iddkdominio
            where cponom  =  "estcvlcod"
              and cpocod  =  d_ctc44m00.estcvlcod

            if sqlca.sqlcode  =  notfound   then
              error " Estado civil nao cadastrado!"
              call ctn36c00("Estado civil", "estcvlcod")
                   returning  d_ctc44m00.estcvlcod
              next field estcvlcod
            end if
           display by name d_ctc44m00.estcvldes

           let ws.retflg  =  "N"

           call ctc44m02( d_ctc44m00.cojnom,
                          d_ctc44m00.srrdpdqtd )
                returning d_ctc44m00.cojnom,
                          d_ctc44m00.srrdpdqtd,
                          ws.retflg

           if ws.retflg  =  "N"   then
              error " Dados sobre dependentes incompletos!"
              next field  estcvlcod
           end if

    before field pesalt
           display by name d_ctc44m00.pesalt attribute (reverse)

    after  field pesalt
           display by name d_ctc44m00.pesalt

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  estcvlcod
           end if

           if d_ctc44m00.pesalt  is null   then
              error " Altura deve ser informada!"
              next field pesalt
           end if

           if d_ctc44m00.pesalt  <  1.40   then
              error " Altura nao deve ser inferior a 1.40 !"
              next field pesalt
           end if

           if d_ctc44m00.pesalt  >  2.10   then
              error " Altura nao deve ser superior a 2.10 !"
              next field pesalt
           end if

    before field pespso
           display by name d_ctc44m00.pespso attribute (reverse)

    after  field pespso
           display by name d_ctc44m00.pespso

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  pesalt
           end if

           if d_ctc44m00.pespso  is null   then
              error " Peso deve ser informado!"
              next field pespso
           end if

           if d_ctc44m00.pespso  <  40   then
              error " Peso nao deve ser inferior a 40 Kg!"
              next field pespso
           end if

           if d_ctc44m00.pespso  >  130   then
              error " Peso nao deve ser superior a 130 Kg!"
              next field pespso
           end if

    before field srrcmsnum
           display by name d_ctc44m00.srrcmsnum attribute (reverse)

    after  field srrcmsnum
           display by name d_ctc44m00.srrcmsnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  pespso
           end if

           if d_ctc44m00.srrcmsnum is null  then
              error " Numeracao da camisa deve ser informada!"
################ PSI 254444 - Popup para mostar o numero da camisa no dominio - Beatriz Araujo
              call ctn36c00("Numeracao da camisa", "srrcmsnum")
                   returning  d_ctc44m00.srrcmsnum
                   select cpodes
                     into d_ctc44m00.srrcmsnum
                     from iddkdominio
                    where cponom  =  "srrcmsnum"
                      and cpocod  =  d_ctc44m00.srrcmsnum
              next field srrcmsnum
           else
              select cpodes
                     into d_ctc44m00.srrcmsnum
                     from iddkdominio
                    where cponom  =  "srrcmsnum"
                      and cpodes  =  d_ctc44m00.srrcmsnum

               if sqlca.sqlcode  =  notfound then
                  error " Nao existe a numeracao da camisa informada!"
                  next field srrcmsnum
              end if
           end if

           ##if d_ctc44m00.srrcmsnum <> "P"  and
           ##   d_ctc44m00.srrcmsnum <> "M"  and
           ##   d_ctc44m00.srrcmsnum <> "G"  and
           ##   d_ctc44m00.srrcmsnum <> "GG" then
           ##   error " Numeracao da camisa deve ser P,M,G ou GG!"
           ##   next field srrcmsnum
           ##end if

################################################# fim PSI
    before field srrclcnum
           display by name d_ctc44m00.srrclcnum attribute (reverse)

    after  field srrclcnum
           display by name d_ctc44m00.srrclcnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srrcmsnum
           end if

           if d_ctc44m00.srrclcnum  is null   then
              error " Numeracao da calca deve ser informada!"
              next field srrclcnum
           end if
###################################Inicio PSI 254444
            select min(cpocod)
              into minsrrclcnum
              from iddkdominio
             where cponom  =  "srrclcnum"

            select max(cpocod)
              into maxsrrclcnum
              from iddkdominio
             where cponom  =  "srrclcnum"

           if d_ctc44m00.srrclcnum  <  minsrrclcnum or
              d_ctc44m00.srrclcnum  >  maxsrrclcnum then
              error "Digite um tamanho par entre ",minsrrclcnum," e ",maxsrrclcnum," !"
              next field srrclcnum
           else
              select cpocod
                     into d_ctc44m00.srrclcnum
                     from iddkdominio
                    where cponom  =  "srrclcnum"
                      and cpocod  =  d_ctc44m00.srrclcnum

               if sqlca.sqlcode  =  notfound then
                  error " Nao existe a numeracao de calca informada!"
                  next field srrclcnum
              end if
           end if

           ###if d_ctc44m00.srrclcnum  <  30   then
           ###   error " Numeracao da calca nao deve ser inferior a 30!"
           ###   next field srrclcnum
           ###end if
           ###
           ###if d_ctc44m00.srrclcnum  >  58   then
           ###   error " Numeracao da calca nao deve ser superior a 58!"
           ###   next field srrclcnum
           ###end if
#################################### fim do PSI
    before field srrcldnum
           display by name d_ctc44m00.srrcldnum attribute (reverse)

    after  field srrcldnum
           display by name d_ctc44m00.srrcldnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srrclcnum
           end if

           if d_ctc44m00.srrcldnum  is null   then
              error " Numeracao do calcado deve ser informado!"
              next field srrcldnum
           end if

           if d_ctc44m00.srrcldnum  <  32   then
              error " Numeracao do calcado nao deve ser inferior a 32!"
              next field srrcldnum
           end if

           if d_ctc44m00.srrcldnum  >  48   then
              error " Numeracao do calcado nao deve ser superior a 48!"
              next field srrcldnum
           end if

    before field rgenum
           display by name d_ctc44m00.rgenum attribute (reverse)

    after  field rgenum
           display by name d_ctc44m00.rgenum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  srrcldnum
           end if

           if d_ctc44m00.rgenum  is null   then
              error " Numero do RG deve ser informado!"
              next field rgenum
           end if

    before field rgeufdcod
           display by name d_ctc44m00.rgeufdcod attribute (reverse)

    after  field rgeufdcod
           display by name d_ctc44m00.rgeufdcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  rgenum
           end if

           if d_ctc44m00.rgeufdcod  is null   then
              error " Estado emissor do RG deve ser informado!"
              next field rgeufdcod
           end if

           select ufdcod
             from glakest
            where ufdcod  =  d_ctc44m00.rgeufdcod

           if sqlca.sqlcode  =  notfound   then
              error " Estado emissor do RG nao cadastrado!"
              next field rgeufdcod
           end if
           let d_ctc44m00.pestip = 'F'
           initialize d_ctc44m00.cgcord  to null
           display by name d_ctc44m00.cgcord

      #before field pestip
      #       display by name d_ctc44m00.pestip   attribute(reverse)
      #
      #after  field pestip
      #       display by name d_ctc44m00.pestip
      #
      #       if fgl_lastkey() = fgl_keyval ("up")     or
      #          fgl_lastkey() = fgl_keyval ("left")   then
      #          next field rgeufdcod
      #       end if
      #
      #       if d_ctc44m00.pestip  is null   then
      #          initialize d_ctc44m00.cgccpfnum  to null
      #          initialize d_ctc44m00.cgcord     to null
      #          initialize d_ctc44m00.cgccpfdig  to null
      #          display by name d_ctc44m00.cgccpfnum
      #          display by name d_ctc44m00.cgcord
      #          display by name d_ctc44m00.cgccpfdig
      #          next field cprnum
      #       end if
      #
      #       if d_ctc44m00.pestip  is null   or
      #          d_ctc44m00.pestip  <>  "F"   then
      #          error " Tipo de pessoa: (F)isica!"
      #          next field pestip
      #       end if
      #
      #       if d_ctc44m00.pestip  =  "F"   then
      #          initialize d_ctc44m00.cgcord  to null
      #          display by name d_ctc44m00.cgcord
      #       end if

      before field cgccpfnum
             display by name d_ctc44m00.cgccpfnum   attribute(reverse)

      after  field cgccpfnum
             display by name d_ctc44m00.cgccpfnum

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field rgeufdcod
             end if

             if d_ctc44m00.cgccpfnum   is null   or
                d_ctc44m00.cgccpfnum   =  0      then
                error " Numero do Cgc/Cpf deve ser informado!"
                next field cgccpfnum
             end if

             if d_ctc44m00.pestip  =  "F"   then
                next field cgccpfdig
             end if

      before field cgcord
             display by name d_ctc44m00.cgcord   attribute(reverse)

      after  field cgcord
             display by name d_ctc44m00.cgcord

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field cgccpfnum
             end if

             if d_ctc44m00.cgcord   is null   or
                d_ctc44m00.cgcord   =  0      then
                error " Filial do Cgc/Cpf deve ser informada!"
                next field cgcord
             end if

      before field cgccpfdig
             display by name d_ctc44m00.cgccpfdig  attribute(reverse)

      after  field cgccpfdig
             display by name d_ctc44m00.cgccpfdig

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                if d_ctc44m00.pestip  =  "J"  then
                   next field cgcord
                else
                   next field cgccpfnum
                end if
             end if

             if d_ctc44m00.cgccpfdig   is null   then
                error " Digito do Cgc/Cpf deve ser informado!"
                next field cgccpfdig
             end if

             initialize ws.srrcoddig  to null
             let param_popup.linha2 = "CGC/CPF ja' cadastrado"
             let param_popup.linha4 = "Deseja prosseguir?"
             #if g_hostname  <>  "u07"   then

                declare c_cgccpf  cursor for
                  select srrcoddig
                    from datksrr
                   where cgccpfnum  =  d_ctc44m00.cgccpfnum
                open  c_cgccpf
                fetch c_cgccpf  into  ws.srrcoddig
                if ws.srrcoddig  is not null   then
                   if param.operacao  =  "i"   then

                      call cts08g01("A","F",param_popup.linha1,
                                            param_popup.linha2,
                                            param_popup.linha3,
                                            param_popup.linha4)
                                 returning  param_popup.confirma
                      if(param_popup.confirma = "N")then
                              next field cgccpfnum
                      end if
                      #error " CGC/CPF ja' cadastrado --> ", ws.srrcoddig
#WWWX RETIRAR LINHA (20/12/2002)     next field cgccpfnum
                   else
                      if ws.srrcoddig  <>  d_ctc44m00.srrcoddig   then
                         call cts08g01("A","F",param_popup.linha1,
                                            param_popup.linha2,
                                            param_popup.linha3,
                                            param_popup.linha4)
                                 returning  param_popup.confirma
                         if(param_popup.confirma = "N")then
                              next field cgccpfnum
                         end if
                         #error " CGC/CPF ja' cadastrado --> ", ws.srrcoddig
#WWWX RETIRAR LINHA (20/12/2002)     next field cgccpfnum
                      end if
                   end if
                end if

                close c_cgccpf

                if d_ctc44m00.pestip  =  "J"    then
                   call F_FUNDIGIT_DIGITOCGC(d_ctc44m00.cgccpfnum, d_ctc44m00.cgcord)
                        returning ws.cgccpfdig
                else
                   call F_FUNDIGIT_DIGITOCPF(d_ctc44m00.cgccpfnum)
                        returning ws.cgccpfdig
                end if

                if ws.cgccpfdig        is null           or
                   d_ctc44m00.cgccpfdig <> ws.cgccpfdig   then

                   error " Digito do CGC/CPF incorreto!"
                   #Altera��o efetuada retirado comentario da linha de baixo por Robert Lima
	           next field cgccpfnum
                end if

             #end if

    before field cprnum
           display by name d_ctc44m00.cprnum attribute (reverse)

    after  field cprnum
           display by name d_ctc44m00.cprnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_ctc44m00.pestip  is null   then
                 next field pestip
              end if
              next field cgccpfdig
           end if

           if d_ctc44m00.cprnum  is null   then
              initialize d_ctc44m00.cprsernum  to null
              initialize d_ctc44m00.cprufdcod  to null
              display by name d_ctc44m00.cprsernum
              display by name d_ctc44m00.cprufdcod
              next field cnhnum
           end if

    before field cprsernum
           display by name d_ctc44m00.cprsernum attribute (reverse)

    after  field cprsernum
           display by name d_ctc44m00.cprsernum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cprnum
           end if

           if d_ctc44m00.cprsernum  is null   then
              error " Serie da carteira profissional deve ser informada!"
              next field cprsernum
           end if

    before field cprufdcod
           display by name d_ctc44m00.cprufdcod attribute (reverse)

    after  field cprufdcod
           display by name d_ctc44m00.cprufdcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cprsernum
           end if

           if d_ctc44m00.cprufdcod  is null   then
              error " Estado emissor da carteira profissional deve ser informado!"
              next field cprufdcod
           end if

           select ufdcod
             from glakest
            where ufdcod  =  d_ctc44m00.cprufdcod

           if sqlca.sqlcode  =  notfound   then
              error " Estado emissor da carteira profissional nao cadastrado!"
              next field cprufdcod
           end if

    before field cnhnum
           display by name d_ctc44m00.cnhnum attribute (reverse)

    after  field cnhnum
           display by name d_ctc44m00.cnhnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_ctc44m00.cprnum  is not null   then
                 next field  cprufdcod
              end if
              next field  cprnum
           end if

           if d_ctc44m00.cnhnum  is null   then
              error " Numero da CNH deve ser informado!"
              next field cnhnum
           end if

    before field cnhautctg
           display by name d_ctc44m00.cnhautctg attribute (reverse)

    after  field cnhautctg
           display by name d_ctc44m00.cnhautctg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cnhnum
           end if

           if d_ctc44m00.cnhautctg  is null   then
              error " Categoria Automovel da CNH nao informada!"
              next field cnhmotctg
           end if

           if d_ctc44m00.cnhautctg[1,1]  <>  "B"   and
              d_ctc44m00.cnhautctg[1,1]  <>  "C"   and
              d_ctc44m00.cnhautctg[1,1]  <>  "D"   and
              d_ctc44m00.cnhautctg[1,1]  <>  "E"   then
              error " Categoria Automovel da CNH nao cadastrada!"
              next field cnhautctg
           end if

    before field cnhmotctg
           display by name d_ctc44m00.cnhmotctg attribute (reverse)

    after  field cnhmotctg
           display by name d_ctc44m00.cnhmotctg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field cnhautctg
           end if

           if d_ctc44m00.cnhautctg is null  and
              d_ctc44m00.cnhmotctg is null  then
              error " Categoria Automovel ou Moto da CNH deve ser informada!"
              next field cnhautctg
           end if
           
	   # 10/03/2016 - Fornax correcao:: trocado cnhautctg por cnhmotctg
           if d_ctc44m00.cnhmotctg[1,1]  <>  "A"  then 
              error " Categoria Moto da CNH nao cadastrada!"
              next field cnhmotctg
           end if

    before field cnhpridat
           display by name d_ctc44m00.cnhpridat attribute (reverse)

    after  field cnhpridat
           display by name d_ctc44m00.cnhpridat

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field cnhmotctg
           end if

           if d_ctc44m00.cnhpridat  is null   then
              error " Data da primeira habilitacao deve ser informada!"
              next field cnhpridat
           end if

           if d_ctc44m00.cnhpridat  >  today   then
              error " Data da primeira habilitacao nao deve ser maior que data atual!"
              next field cnhpridat
           end if

           if d_ctc44m00.cnhpridat  <  d_ctc44m00.nscdat   then
              error " Data primeira habilitacao nao deve ser anterior a data do nascimento!"
              next field cnhpridat
           end if

           if d_ctc44m00.cnhpridat  <  d_ctc44m00.nscdat + 18 units year   then
              error " Data da primeira habilitacao nao deve ser inferior a 18 anos!"
              next field cnhpridat
           end if

    before field exmvctdat
           display by name d_ctc44m00.exmvctdat attribute (reverse)

    after  field exmvctdat
           display by name d_ctc44m00.exmvctdat

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  cnhpridat
           end if

           if d_ctc44m00.exmvctdat  is null   then
              error " Data da validade do exame medico deve ser informada!"
              next field exmvctdat
           end if
          initialize param_popup.* to null
          let param_popup.linha2 = "Validade do exame medico vencida!"
          let param_popup.linha4 = "Deseja prosseguir mesmo assim? "
           if d_ctc44m00.exmvctdat  <=  today   then
              call cts08g01("A","F",param_popup.linha1,
                            param_popup.linha2,
                            param_popup.linha3,
                            param_popup.linha4)
                 returning  param_popup.confirma
           end if
           if(param_popup.confirma = "N")then
                   next field exmvctdat
           end if
           if d_ctc44m00.exmvctdat  >  today + 10 units year   then
              error " Validade do exame medico nao deve ser superior a 10 anos!"
              next field exmvctdat
           end if

    before field celdddcod
           display by name d_ctc44m00.celdddcod attribute (reverse)

    after  field celdddcod
           display by name d_ctc44m00.celdddcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  exmvctdat
           end if

          if d_ctc44m00.celdddcod is null  then
             initialize d_ctc44m00.celdddcod  to null
             initialize d_ctc44m00.celtelnum  to null
             display by name d_ctc44m00.celdddcod
             display by name d_ctc44m00.celtelnum
             next field empcod
          end if

    before field celtelnum
           display by name d_ctc44m00.celtelnum attribute (reverse)

    after  field celtelnum
           display by name d_ctc44m00.celtelnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  celdddcod
           end if

          if d_ctc44m00.celdddcod is not null  then
             if d_ctc44m00.celtelnum is null  then
                error " Numero do telefone celular deve ser informado!"
                next field celtelnum
             end if
          end if


          # -> VERIFICA SE O CELULAR JA ESTA CADASTRADO PARA OUTRO SOCORRISTA
          let l_srrcoddig = ctc44m00_pesq_cel_soc(d_ctc44m00.celdddcod,
                                                  d_ctc44m00.celtelnum,
                                                  d_ctc44m00.srrcoddig)

          if l_srrcoddig is not null then
             let l_msg = "Este celular ja esta cadastrado para o socorrista: ",
                          l_srrcoddig using "<<<<<<<&"
             error l_msg
             next field celtelnum
          end if

    before field empcod
           display by name d_ctc44m00.empcod attribute (reverse)

    after  field empcod
           display by name d_ctc44m00.empcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  celdddcod
           end if

           if d_ctc44m00.empcod  is null   then
              initialize d_ctc44m00.funmat  to null
              display by name d_ctc44m00.funmat
              next field nxtdddcod
           end if

           select empcod
             from gabkemp
            where empcod  =  d_ctc44m00.empcod

           if sqlca.sqlcode  =  notfound   then
              error " Empresa nao cadastrada!"
              next field  empcod
           end if

    before field funmat
           display by name d_ctc44m00.funmat attribute (reverse)

    after  field funmat
           display by name d_ctc44m00.funmat

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field empcod
           end if

           if d_ctc44m00.funmat is null  then
              error " Matricula do funcionario deve ser informada!"
              next field funmat
           end if

#-------------------------------------------------------------------------
# Matricula nao cadastrada no sistema de seguranca: apenas verifica digito
#-------------------------------------------------------------------------
           select funmat
             from isskfunc
            where empcod  =  d_ctc44m00.empcod
              and funmat  =  d_ctc44m00.funmat

           if sqlca.sqlcode  =  notfound   then
              error " Matricula nao cadastrada! Informe digito para verificacao."
              next field funmatdig
           else
              initialize d_ctc44m00.funmatdig to null
              display by name d_ctc44m00.funmatdig
              next field nxtdddcod
           end if

    before field funmatdig
           display by name d_ctc44m00.funmatdig attribute (reverse)

    after  field funmatdig
           display by name d_ctc44m00.funmatdig

           if d_ctc44m00.funmatdig is null  then
              error " Digito verificador deve ser informado!"
              next field funmatdig
           end if

           let ws.funmatdig = (d_ctc44m00.funmat * 10) + d_ctc44m00.funmatdig

           call F_FUNDIGIT_DIGITOMATR(d_ctc44m00.empcod, ws.funmatdig)
                   returning ws.funmatdig

           if ws.funmatdig is null  then
              error " Matricula do funcionario invalida!"
              next field funmat
           end if

    before field srrprnnom
           display by name d_ctc44m00.srrprnnom attribute (reverse)

    after  field srrprnnom
           display by name d_ctc44m00.srrprnnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field nxtnum
           end if

    before field srrtip
       display by name d_ctc44m00.srrtip attribute (reverse)
       display by name d_ctc44m00.separador1

    after field srrtip
       display by name d_ctc44m00.srrtip
       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field srrprnnom
       end if

       if d_ctc44m00.srrtip    is null   or
          d_ctc44m00.srrtip    =  ' '    then

	  call cty09g00_popup_iddkdominio('srrtip')
                    returning l_erro
                             ,l_mensagem
                             ,l_ret_aux

           if l_erro <> 1 then
              display by name d_ctc44m00.descsocor
              next field srrtip
	   end if
           let d_ctc44m00.descsocor = l_ret_aux
	   let d_ctc44m00.srrtip    = l_mensagem
        else

          call cty11g00_iddkdominio('srrtip',d_ctc44m00.srrtip)
             returning l_erro
                      ,l_mensagem
                      ,l_ret_aux

          if l_erro  <> 1 then
             call cty09g00_popup_iddkdominio('srrtip')
                          returning l_erro
                                   ,l_mensagem
                                   ,l_ret_aux

             if l_erro <> 1 then
                display by name d_ctc44m00.descsocor
                next field srrtip
	     end if
	     let d_ctc44m00.descsocor = l_ret_aux
      	     let d_ctc44m00.srrtip    = l_mensagem
	  end if
          let d_ctc44m00.descsocor    = l_ret_aux
       end if
       display by name d_ctc44m00.descsocor
       display by name d_ctc44m00.srrtip

    before field socanlsitcod
       display by name d_ctc44m00.socanlsitcod attribute (reverse)
       display by name d_ctc44m00.separador2

    after field  socanlsitcod
       display by name d_ctc44m00.socanlsitcod

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field srrtip
       end if

       if d_ctc44m00.socanlsitcod is null  or
          d_ctc44m00.socanlsitcod =  ' '  then

          call cty09g00_popup_iddkdominio('socanlsitcod')
                       returning l_erro
                                ,l_mensagem
                                ,l_ret_aux

          if l_erro <> 1 then
             display by name d_ctc44m00.descps
             next field socanlsitcod
	  end if
          let d_ctc44m00.descps       = l_ret_aux
	  let d_ctc44m00.socanlsitcod = l_mensagem
       else
          call cty11g00_iddkdominio('socanlsitcod',d_ctc44m00.socanlsitcod)
                returning l_erro
                         ,l_mensagem
                         ,l_ret_aux

          if l_erro <> 1 then
             call cty09g00_popup_iddkdominio('socanlsitcod')
                       returning l_erro
                                ,l_mensagem
                                ,l_ret_aux

             if l_erro <> 1 then
                 next field socanlsitcod
	     end if
             let d_ctc44m00.descps       = l_ret_aux
	     let d_ctc44m00.socanlsitcod = l_mensagem
         end if
	 let d_ctc44m00.descps  = l_ret_aux
       end if

       if param.operacao = 'i' then
          call cts08g04 ('Inclusao do email do Socorrista',d_ctc44m00.maides)
             returning d_ctc44m00.maides, l_erro
          if l_erro <> 0 then
             let d_ctc44m00.maides = null
          end if
       end if

       display by name d_ctc44m00.descps
       display by name d_ctc44m00.socanlsitcod

    before field rdranlsitcod

       exit input

       display by name d_ctc44m00.rdranlsitcod attribute (reverse)
       display by name d_ctc44m00.separador3

    after field rdranlsitcod
       display by name d_ctc44m00.rdranlsitcod

       if fgl_lastkey() = fgl_keyval ("up")     or
          fgl_lastkey() = fgl_keyval ("left")   then
          next field socanlsitcod
       end if

       if d_ctc44m00.rdranlsitcod is null   or
          d_ctc44m00.rdranlsitcod =  ' '   then

   	  call cty09g00_popup_iddkdominio('rdranlsitcod')
                       returning l_erro
                                ,l_mensagem
                                ,l_ret_aux

          if l_erro <> 1 then
             next field rdranlsitcod
	  end if
          let d_ctc44m00.descradar   = l_ret_aux
	  let d_ctc44m00.rdranlsitcod = l_mensagem
	else
          call cty11g00_iddkdominio('rdranlsitcod',d_ctc44m00.rdranlsitcod)
             returning l_erro
                      ,l_mensagem
                      ,l_ret_aux

          if l_erro <> 1 then
   	     call cty09g00_popup_iddkdominio('rdranlsitcod')
                       returning l_erro
                                ,l_mensagem
                                ,l_ret_aux

             if l_erro <> 1 then
                display by name d_ctc44m00.descradar
                next field rdranlsitcod
	     end if
             let d_ctc44m00.descradar    = l_ret_aux
	     let d_ctc44m00.rdranlsitcod = l_mensagem
          end if
          let d_ctc44m00.descradar       = l_ret_aux
       end if

       display by name d_ctc44m00.descradar
       display by name d_ctc44m00.rdranlsitcod

    on key (interrupt)
       exit input
 end input

 if int_flag   then
    initialize d_ctc44m00.*  to null
 end if

  return d_ctc44m00.*

end function  ###  ctc44m00_input


#---------------------------------------------------------
 function ctc44m00_ler(param)
#---------------------------------------------------------

 define param         record
    srrcoddig         like datksrr.srrcoddig
 end record

 define d_ctc44m00    record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
### srrsttdes         char (10),
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,
    cnhmotctg         like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char (1),
    coderro           integer                    ## Codigo erro func externas
 end record


define r_criticas record
       critica1 smallint   #novo retorno da funcao do vida para correcao do chamado descrito acima - Robert
       #critica1 smallint, # quando =   7, possuiu Vital #
       #critica2 smallint, # quando =  83, possuiu VG    #
       #critica3 smallint, # quando =   6, possui Vital  #
       #critica4 smallint, # quando =  82, possui VG     ###Retirado devido ao chamado 10087929
       #critica5 smallint, # quando =  85, possuiu API   #  conforme acertado com a equipe do vida
       #critica6 smallint, # quando =  86, possui API    #
       #critica7 smallint  # quando = 321, possui VN     #
end record


 define ws            record
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    cademp            like isskfunc.empcod,
    cadmat            like isskfunc.funmat
 end record

   define l_erro      smallint
        ,l_mensagem  char(100)


 initialize d_ctc44m00.*   to null
 initialize ws.*           to null

   let d_ctc44m00.separador1 = '-'
   let d_ctc44m00.separador2 = '-'
   let d_ctc44m00.separador3 = '-'
   let l_erro     = null
   let l_mensagem = null
   let d_ctc44m00.socvidseg = ""

 select  srrcoddig    ,
         srrnom       , srrabvnom,
         srrstt       , sexcod,
         nscdat       , painom,
         maenom       , nacdes,
         ufdcod       , estcvlcod,
         cojnom       , srrdpdqtd,
         pesalt       , pespso,
         srrcmsnum    , srrclcnum,
         srrcldnum    , rgenum,
         rgeufdcod    , pestip,
         cgccpfnum    , cgcord,
         cgccpfdig    , cprnum,
         cprsernum    , cprufdcod,
         cnhnum       , cnhautctg,
         cnhmotctg    ,
         cnhpridat    , exmvctdat,
         celdddcod    , celtelnum,
         empcod       , funmat,
         nxtdddcod    ,
         nxtide       , nxtnum,
         srrprnnom    , caddat,
         cademp       , cadmat,
         atldat       , atlemp,
         atlmat       , srrtip,
         socanlsitcod , rdranlultdat,
         rdranlsitcod , maides
   into  d_ctc44m00.srrcoddig   ,
         d_ctc44m00.srrnom      , d_ctc44m00.srrabvnom,
         d_ctc44m00.srrstt      , d_ctc44m00.sexcod,
         d_ctc44m00.nscdat      , d_ctc44m00.painom,
         d_ctc44m00.maenom      , d_ctc44m00.nacdes,
         d_ctc44m00.ufdcod      , d_ctc44m00.estcvlcod,
         d_ctc44m00.cojnom      , d_ctc44m00.srrdpdqtd,
         d_ctc44m00.pesalt      , d_ctc44m00.pespso,
         d_ctc44m00.srrcmsnum   , d_ctc44m00.srrclcnum,
         d_ctc44m00.srrcldnum   , d_ctc44m00.rgenum,
         d_ctc44m00.rgeufdcod   , d_ctc44m00.pestip,
         d_ctc44m00.cgccpfnum   , d_ctc44m00.cgcord,
         d_ctc44m00.cgccpfdig   , d_ctc44m00.cprnum,
         d_ctc44m00.cprsernum   , d_ctc44m00.cprufdcod,
         d_ctc44m00.cnhnum      , d_ctc44m00.cnhautctg,
         d_ctc44m00.cnhmotctg   ,
         d_ctc44m00.cnhpridat   , d_ctc44m00.exmvctdat,
         d_ctc44m00.celdddcod   , d_ctc44m00.celtelnum,
         d_ctc44m00.empcod      , d_ctc44m00.funmat,
         d_ctc44m00.nxtdddcod   ,
         d_ctc44m00.nxtide      , d_ctc44m00.nxtnum,
         d_ctc44m00.srrprnnom   , d_ctc44m00.caddat,
         ws.cademp              , ws.cadmat,
         d_ctc44m00.atldat      , ws.atlemp,
         ws.atlmat              , d_ctc44m00.srrtip,
         d_ctc44m00.socanlsitcod,d_ctc44m00.rdranlultdat,
         d_ctc44m00.rdranlsitcod, d_ctc44m00.maides

   from  datksrr
  where  datksrr.srrcoddig = param.srrcoddig

 if sqlca.sqlcode = notfound   then
    error " Socorrista nao cadastrado!"
    initialize d_ctc44m00.*    to null
    return d_ctc44m00.*
 else
    call cty11g00_iddkdominio('srrtip',d_ctc44m00.srrtip)
       returning l_erro
                ,l_mensagem
                ,d_ctc44m00.descsocor

    call cty11g00_iddkdominio('socanlsitcod',d_ctc44m00.socanlsitcod)
       returning l_erro
                ,l_mensagem
                ,d_ctc44m00.descps

    call cty11g00_iddkdominio('rdranlsitcod',d_ctc44m00.rdranlsitcod)
       returning l_erro
                ,l_mensagem
                ,d_ctc44m00.descradar

    call ctc44m00_func(ws.cademp, ws.cadmat)
         returning d_ctc44m00.cadfunnom

    call ctc44m00_func(ws.atlemp, ws.atlmat)
         returning d_ctc44m00.funnom

 #Fun��o do vida que veirifica se o socorrista possui seguro de vida
 # ovgea017 foi alterada para ovgea017a devido ao chamado 10087929
 # conforme foi acertado com a equipe do vida

    call ovgea017a(d_ctc44m00.cgccpfnum,0,d_ctc44m00.cgccpfdig,'F')
        returning r_criticas.critica1
                  #r_criticas.critica2,
                  #r_criticas.critica3,
                  #r_criticas.critica4,
                  #r_criticas.critica5,
                  #r_criticas.critica6,
                  #r_criticas.critica7

    #if r_criticas.critica1 is null and
    #   r_criticas.critica2 is null and
    #   r_criticas.critica3 is null and
    #   r_criticas.critica4 is null and
    #   r_criticas.critica5 is null and
    #   r_criticas.critica6 is null and
    #   r_criticas.critica7 is null then
    if r_criticas.critica1 = 0 then
        let d_ctc44m00.coderro = 4
    else
        let d_ctc44m00.coderro = 0
    end if
 end if

 #---------------------------------------------------------
 # Dados do endereco do socorrista
 #---------------------------------------------------------
 select lgdtip   , lgdnom,
        lgdnum   , endlgdcmp,
        brrnom   , cidnom,
        ufdcod   , endcep,
        endcepcmp, lgdrefptodes,
        dddcod   , telnum,
        srrendobs
   into d_ctc44m00.lgdtip   , d_ctc44m00.lgdnom,
        d_ctc44m00.lgdnum   , d_ctc44m00.endlgdcmp,
        d_ctc44m00.brrnom   , d_ctc44m00.cidnom,
        d_ctc44m00.endufdcod, d_ctc44m00.endcep,
        d_ctc44m00.endcepcmp, d_ctc44m00.lgdrefptodes,
        d_ctc44m00.dddcod   , d_ctc44m00.telnum,
        d_ctc44m00.srrendobs
   from datksrrend
  where datksrrend.srrcoddig  =  d_ctc44m00.srrcoddig
    and datksrrend.srrendtip  =  1

 select cpodes
   into d_ctc44m00.srrsttdes
   from iddkdominio
  where cponom  =  "srrstt"
    and cpocod  =  d_ctc44m00.srrstt

 if d_ctc44m00.srrstt = 2 then #--> PSI-21950
    let d_ctc44m00.srrsttdes =
        d_ctc44m00.srrsttdes clipped, "/",
        cty38g00_motivo(d_ctc44m00.srrcoddig)
 end if 

 select cpodes
   into d_ctc44m00.estcvldes
   from iddkdominio
  where cponom  =  "estcvlcod"
    and cpocod  =  d_ctc44m00.estcvlcod

 return d_ctc44m00.*

end function  ###  ctc44m00_ler


#---------------------------------------------------------
 function ctc44m00_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

end function  ###  ctc44m00_func


#---------------------------------------------------------
 function ctc44m00_display(param)
#---------------------------------------------------------

 define param         record
    srrcoddig         like datksrr.srrcoddig,
    srrnom            like datksrr.srrnom,
    srrabvnom         like datksrr.srrabvnom,
    srrstt            like datksrr.srrstt,
### srrsttdes         char (10),
    srrsttdes         char (24), #--> PSI-21950
    sexcod            like datksrr.sexcod,
    nscdat            like datksrr.nscdat,
    painom            like datksrr.painom,
    maenom            like datksrr.maenom,
    nacdes            like datksrr.nacdes,
    ufdcod            like datksrr.ufdcod,
    estcvlcod         like datksrr.estcvlcod,
    estcvldes         char (20),
    cojnom            like datksrr.cojnom,
    srrdpdqtd         like datksrr.srrdpdqtd,
    pesalt            like datksrr.pesalt,
    pespso            like datksrr.pespso,
    srrcmsnum         like datksrr.srrcmsnum,
    srrclcnum         like datksrr.srrclcnum,
    srrcldnum         like datksrr.srrcldnum,
    rgenum            like datksrr.rgenum,
    rgeufdcod         like datksrr.rgeufdcod,
    pestip            like datksrr.pestip,
    cgccpfnum         like datksrr.cgccpfnum,
    cgcord            like datksrr.cgcord,
    cgccpfdig         like datksrr.cgccpfdig,
    cprnum            like datksrr.cprnum,
    cprsernum         like datksrr.cprsernum,
    cprufdcod         like datksrr.cprufdcod,
    cnhnum            like datksrr.cnhnum,
    cnhautctg         like datksrr.cnhautctg,
    cnhmotctg         like datksrr.cnhmotctg,
    cnhpridat         like datksrr.cnhpridat,
    exmvctdat         like datksrr.exmvctdat,
    celdddcod         like datksrr.celdddcod,
    celtelnum         like datksrr.celtelnum,
    empcod            like datksrr.empcod,
    funmat            like datksrr.funmat,
    funmatdig         dec (1,0),
    nxtdddcod         like datksrr.nxtdddcod,
    nxtide            like datksrr.nxtide,
    nxtnum            like datksrr.nxtnum,
    srrprnnom         like datksrr.srrprnnom,
    caddat            like datksrr.caddat,
    cadfunnom         like isskfunc.funnom,
    atldat            like datksrr.atldat,
    funnom            like isskfunc.funnom,
    lgdtip            like datksrrend.lgdtip,
    lgdnom            like datksrrend.lgdnom,
    lgdnum            like datksrrend.lgdnum,
    endlgdcmp         like datksrrend.endlgdcmp,
    brrnom            like datksrrend.brrnom,
    cidnom            like datksrrend.cidnom,
    endufdcod         like datksrrend.ufdcod,
    endcep            like datksrrend.endcep,
    endcepcmp         like datksrrend.endcepcmp,
    lgdrefptodes      like datksrrend.lgdrefptodes,
    dddcod            like datksrrend.dddcod,
    telnum            like datksrrend.telnum,
    srrendobs         like datksrrend.srrendobs,
    srrtip            like datksrr.srrtip,
    socanlsitcod      like datksrr.socanlsitcod,
    rdranlultdat      like datksrr.rdranlultdat,
    rdranlsitcod      like datksrr.rdranlsitcod,
    separador1        char(01),
    separador2        char(01),
    separador3        char(01),
    descsocor         char(20),
    descps            char(20),
    descradar         char(20),
    maides            like datksrr.maides,
    socvidseg         char(1),
    coderro           integer                    ## Codigo erro func externas
 end record

 define l_qual_srr char(7) ## = a Padrao se codigo de qualidade de servico prest. for 1

 display by name param.srrcoddig
 display by name param.srrnom
 display by name param.srrabvnom
 display by name param.srrstt
 display by name param.srrsttdes
 display by name param.sexcod
 display by name param.nscdat
 display by name param.estcvlcod
 display by name param.estcvldes
 display by name param.pesalt
 display by name param.pespso
 display by name param.srrcmsnum
 display by name param.srrclcnum
 display by name param.srrcldnum
 display by name param.rgenum
 display by name param.rgeufdcod
 #display by name param.pestip
 display by name param.cgccpfnum
 display by name param.cgcord
 display by name param.cgccpfdig
 display by name param.cprnum
 display by name param.cprsernum
 display by name param.cprufdcod
 display by name param.cnhnum
 display by name param.cnhautctg
 display by name param.cnhmotctg
 display by name param.cnhpridat
 display by name param.exmvctdat
 display by name param.celdddcod
 display by name param.celtelnum
 display by name param.empcod
 display by name param.funmat
 display by name param.nxtdddcod
 display by name param.nxtide
 display by name param.nxtnum
 display by name param.srrprnnom
 display by name param.caddat
 display by name param.cadfunnom
 display by name param.atldat
 display by name param.funnom
 display by name param.srrtip
 display by name param.socanlsitcod
 display by name param.rdranlultdat
 display by name param.rdranlsitcod
 display by name param.separador1
 display by name param.separador2
 display by name param.separador3
 display by name param.descsocor
 display by name param.descps
 display by name param.descradar

 if param.srrcoddig is not null and param.srrcoddig <> 0 then

      whenever error continue

      select 1
  	from datrsrrpst a,
       dpaksocor b
      where a.srrcoddig = param.srrcoddig
        and  b.pstcoddig = a.pstcoddig
        and a.vigfnl = (select max(vigfnl)
                          from datrsrrpst d
                         where d.srrcoddig = a.srrcoddig)
        and b.qldgracod = 1

      whenever error stop

      if sqlca.sqlcode  = 0   then
	let l_qual_srr = 'PADRAO'
	display by name  l_qual_srr attribute (reverse)
      else
	let l_qual_srr = ''
	display by name  l_qual_srr
      end if
 end if


 if(param.coderro == 0) then
           let param.socvidseg = "S"
           display by name  param.socvidseg attribute (reverse)
 else
           if(param.coderro == 4) then
                  let param.socvidseg = "N"
                  display by name  param.socvidseg  attribute (reverse)
           else
                  let param.socvidseg = " "
                  display by name  param.socvidseg
           end if
 end if

 #--> PSI-21950 - Inicio
 let m_cabec.srrcoddig = param.srrcoddig
 let m_cabec.srrnom = param.srrnom
 let m_cabec.l_qual_srr = l_qual_srr
 #--> PSI-21950 - Final

end function  ###  ctc44m00_display

#------------------------------------------#
function ctc44m00_pesq_cel_soc(lr_parametro)
#------------------------------------------#

  #---------------------------------------------------------------
  # FUNCAO RESPONSAVEL POR VERIFICAR SE O CELULAR DO SOCORRISTA JA
  # ESTA CADASTRADO PARA ALGUM OUTRO SOCORRISTA
  #---------------------------------------------------------------

  define lr_parametro record
         celdddcod    like datksrr.celdddcod,
         celtelnum    like datksrr.celtelnum,
         srrcoddig    like datksrr.srrcoddig
  end record

  define l_celdddcod  like datksrr.celdddcod,
         l_celtelnum  like datksrr.celtelnum,
         l_srrcoddig  like datksrr.srrcoddig,
         l_achou      smallint

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------
  let l_celdddcod = null
  let l_celtelnum = null
  let l_srrcoddig = null
  let l_achou     = false

  if m_ctc44m00_prep is null or
     m_ctc44m00_prep <> true then
     call ctc44m00_prepare()
  end if

  # -> BUSCA NO CADASTRO DE SOCORRISTAS
  open cctc44m00002
  foreach cctc44m00002 into l_celdddcod,
                            l_celtelnum,
                            l_srrcoddig

     if l_celdddcod is null or
        l_celtelnum is null then
        continue foreach
     end if

     if lr_parametro.celdddcod = l_celdddcod and
        lr_parametro.celtelnum = l_celtelnum then
        if l_srrcoddig = lr_parametro.srrcoddig then
           continue foreach
        end if

        let l_achou = true
        exit foreach
     end if

  end foreach
  close cctc44m00002

  if l_achou = false then
     let l_srrcoddig = null
  end if

  return l_srrcoddig

end function

#----------------------------------------------
function ctc44m00_radar(lr_param)
#----------------------------------------------
   define lr_param    record
          pestip      like datksrr.pestip,
          cgccpfnum   like datksrr.cgccpfnum,
          cgcord      like datksrr.cgcord,
          cgccpfdig   like datksrr.cgccpfdig,
          srrcoddig   like datksrr.srrcoddig
   end record

   define lr_retorno   record
          result        smallint
         ,stats         char(1)
         ,msg           char(80)  ### 'L' -> Liberado / 'S -> Suspenso
         end record

   define l_sit_rd      smallint,
          l_sit_ps      smallint,
          l_situacao    smallint,
          l_data        date,
          l_hora        datetime hour to minute,
          l_cpodes      like iddkdominio.cpodes,
          l_texto       char(70),
          l_conf        char(1),
          l_res         smallint,
          l_msg         char(80)

   initialize lr_retorno.* to null
   let l_sit_rd = null
   let l_sit_ps = null
   let l_situacao = null
   let l_data = null
   let l_hora = null
   let l_res = null
   let l_msg = null
   let l_conf = null
   let l_cpodes = null
   let l_texto = null

   menu "RADAR"

        command key ("A") "Analise" "Realiza analise eventual deste Socorrista"
           call cts08g01("A", "S", "", "",
                        "CONFIRMA A ANALISE DESTE SOCORRISTA ?", "")
               returning l_conf

           if l_conf =  "S" then

              display '----- CHAMADA DA FUN��O ffpta070 TELA CTC44M00 -----'
              display 'lr_param.pestip: ',lr_param.pestip
              display 'lr_param.cgccpfnum: ',lr_param.cgccpfnum
              display 'lr_param.cgcord: ', lr_param.cgcord
              display 'lr_param.cgccpfdig: ', lr_param.cgccpfdig
              display '3, " ", 3'

              call ffpta070(lr_param.pestip, lr_param.cgccpfnum,
                            lr_param.cgcord, lr_param.cgccpfdig, 3,' ',3)
                   returning lr_retorno.*
                   display '----- RETORNO DA FUN��O ffpta070 TELA CTC44M00 -----'
                   display 'lr_retorno.result:', lr_retorno.result
                   display 'lr_retorno.stats :', lr_retorno.stats
                   display 'lr_retorno.msg   :', lr_retorno.msg    clipped

              if lr_retorno.result = 0 then
                 case lr_retorno.stats
                      when "L"
                            let l_sit_rd = 1
                            let l_sit_ps = 2
                      when "S"
                            let l_sit_rd = 2
                            let l_sit_ps = 1
                      when "R"
                            let l_sit_rd = 3
                            let l_sit_ps = 1
                      when "B"
                            let l_sit_rd = 4
                            let l_sit_ps = 1
                 end case

                 call cts40g03_data_hora_banco(2)
                      returning l_data, l_hora

                 call cty11g00_iddkdominio("rdranlsitcod" ,l_sit_rd)
                      returning l_res ,l_msg ,l_cpodes

                 if l_res <> 1 then
                    let l_msg = l_sit_rd, " ", lr_retorno.stats
                 end if

                 let l_texto = 'SITUACAO DO RADAR EM ' ,l_data ,' '
                              ,l_cpodes clipped ,' ' ,l_msg

                 begin work
                 display '----- CHAMADA DA FUN��O ctd18g01_grava_hist -----'
                 display 'lr_param.srrcoddig:', lr_param.srrcoddig
                 display 'l_texto           :', l_texto clipped
                 display 'l_data            :', l_data
                 display 'g_issk.empcod     :', g_issk.empcod
                 display 'g_issk.funmat     :', g_issk.funmat


                 call ctd18g01_grava_hist(lr_param.srrcoddig
                                         ,l_texto
                                         ,l_data
                                         ,g_issk.empcod
                                         ,g_issk.funmat
                                         ,'F')
                      returning l_res ,l_msg

                      display '----- RETORNO DA FUN��O ctd18g01_grava_hist -----'
                      display 'l_res:', l_res
                      display 'l_msg:', l_msg clipped


                 if l_res <> 1 then
                    display l_msg clipped
                    rollback work
                 else

                    display '----- CHAMADA DA FUN��O ctd18g00_update_socorrista -----'
                    display 'l_data            :',l_data
                    display 'l_sit_rd          :',l_sit_rd
                    display 'l_sit_ps          :',l_sit_ps
                    display 'l_data            :',l_data
                    display 'lr_param.srrcoddig:',lr_param.srrcoddig

                    call ctd18g00_update_socorrista(l_data,l_sit_rd, l_sit_ps,
                                                    l_data,lr_param.srrcoddig)
                         returning l_res, l_msg

                    display '----- RETORNO DA FUN��O ctd18g00_update_socorrista -----'
                    display 'l_res:', l_res
                    display 'l_msg:', l_msg clipped


                    if l_res = 1 then
                       commit work
                    else
                       display l_msg clipped
                       rollback work
                    end if

                 end if
              else
                 error lr_retorno.msg
              end if
           end if

        command key ("R") "Radar" "Consulta o sistema do Radar"
           call chama_prog("Radar","ofptm076",'')
                returning l_situacao

           if l_situacao <> 0 then # problemas na execussao
              if  l_situacao < 0 then
                  error "Erro de consistencias da funcao chama_prog"
                else
                  error "Erro de execussao da funcao chama_prog"
              end if
           end if

        command key ("E") "Encerrar" "Volta ao menu anterior"
           exit menu
   end menu

end function

#----------------------------------------------------
function ctc44m00_sel_srr(lr_param)
#----------------------------------------------------

  define lr_param   record
         cgccpfnum  like datksrr.cgccpfnum,
         cgcord     like datksrr.cgcord,
         cgccpfdig  like datksrr.cgccpfdig
         end record

  define l_srrcoddig like datksrr.srrcoddig

  if m_ctc44m00_prep is null or
     m_ctc44m00_prep <> true then
     call ctc44m00_prepare()
  end if

  let l_srrcoddig = null

  open cctc44m00003 using lr_param.cgccpfnum, lr_param.cgcord,
                          lr_param.cgccpfdig
  fetch cctc44m00003 into l_srrcoddig

  close cctc44m00003

  return l_srrcoddig

end function

#-----------------------------------------------------#
function ctc44m00_cadastro_email(lr_param)
#-----------------------------------------------------#
   define lr_param  record
          maides    like datksrr.maides
         ,srrcoddig like datksrr.srrcoddig
   end record

   define lr_maides_ant like datksrr.maides
         ,l_stt       smallint
         ,l_resp      char(01)
         ,l_mesg      char(3000)
         ,l_mensagem  char(100)
         ,l_cgccpfnum like datksrr.cgccpfnum

   if m_ctc44m00_prep is null or
      m_ctc44m00_prep <> true then
      call ctc44m00_prepare()
   end if

   let lr_maides_ant = null
   let lr_maides_ant = lr_param.maides

   open cctc44m00005 using lr_param.srrcoddig
   fetch cctc44m00005 into lr_param.maides
   close cctc44m00005

   let l_stt  = null
   let l_resp = null

   call cts08g04('Manutencao do email do Socorrista',lr_param.maides)
      returning lr_param.maides, l_stt

   if l_stt = 0 then
      whenever error continue
      execute pctc44m00004 using lr_param.maides
                                ,lr_param.srrcoddig
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error 'Erro UPDATE pctc44m00004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
         error 'CTC44M00 / ctc44m00_cadastro_email() / ',lr_param.maides    ,' / '
                                                        ,lr_param.srrcoddig  sleep 2
      else
         prompt 'Alteracao efetuada com sucesso, Tecle ENTER!' for l_resp


         if lr_maides_ant <> lr_param.maides then
            let l_mensagem = 'Alteracao no cadastro do socorrista. Codigo : ' clipped,
		              lr_param.srrcoddig clipped
            let l_mesg = "Email alterado de [",lr_maides_ant clipped,
                         "] para [",lr_param.maides clipped,"]"

            if not ctc44m00_grava_hist(lr_param.srrcoddig
                                ,l_mesg clipped
                                ,today
                                ,l_mensagem,"I") then

                error 'Erro ctc44m00_grava_hist/ '  sleep 2
                error 'CTC44M00 / ctc44m00_cadastro_email() / ',lr_param.maides    ,' / '
                                                        ,lr_param.srrcoddig  sleep 2
            end if
         end if

      end if
   end if

 call ctd40g00_busca_qra_cpf("QRA", lr_param.srrcoddig)
      returning l_stt,
                l_mesg,
                l_cgccpfnum

 if  l_stt = 0 then
     if  ctd40g00_permissao_atl(g_issk.funmat) then
        display 'chamada ctd40g00_usrweb_qra("A")', lr_param.srrcoddig
     end if
     call ctd40g00_usrweb_qra("A",
                              lr_param.srrcoddig,
                              "",
                              "",
                              "",
                              "")
       returning l_stt,
                 l_mesg
 end if

end function

#------------------------------------------------------------
function ctc44m00_grava_hist(lr_param,l_titulo,l_operacao)
#------------------------------------------------------------

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

#---------------------------------------------------------
function ctc44m00_verifica_mod(lr_ctc44m00_ant,lr_ctc44m00)
#---------------------------------------------------------
# Retorno da funcao 0 --> envia email
#                   1 --> nao envia email
#

   define lr_ctc44m00    record
       srrcoddig         like datksrr.srrcoddig,
       srrnom            like datksrr.srrnom,
       srrabvnom         like datksrr.srrabvnom,
       srrstt            like datksrr.srrstt,
   ### srrsttdes         char (10),
       srrsttdes         char (24), #--> PSI-21950
       sexcod            like datksrr.sexcod,
       nscdat            like datksrr.nscdat,
       painom            like datksrr.painom,
       maenom            like datksrr.maenom,
       nacdes            like datksrr.nacdes,
       ufdcod            like datksrr.ufdcod,
       estcvlcod         like datksrr.estcvlcod,
       estcvldes         char (20),
       cojnom            like datksrr.cojnom,
       srrdpdqtd         like datksrr.srrdpdqtd,
       pesalt            like datksrr.pesalt,
       pespso            like datksrr.pespso,
       srrcmsnum         like datksrr.srrcmsnum,
       srrclcnum         like datksrr.srrclcnum,
       srrcldnum         like datksrr.srrcldnum,
       rgenum            like datksrr.rgenum,
       rgeufdcod         like datksrr.rgeufdcod,
       pestip            like datksrr.pestip,
       cgccpfnum         like datksrr.cgccpfnum,
       cgcord            like datksrr.cgcord,
       cgccpfdig         like datksrr.cgccpfdig,
       cprnum            like datksrr.cprnum,
       cprsernum         like datksrr.cprsernum,
       cprufdcod         like datksrr.cprufdcod,
       cnhnum            like datksrr.cnhnum,
       cnhautctg         like datksrr.cnhautctg,
       cnhmotctg         like datksrr.cnhmotctg,
       cnhpridat         like datksrr.cnhpridat,
       exmvctdat         like datksrr.exmvctdat,
       celdddcod         like datksrr.celdddcod,
       celtelnum         like datksrr.celtelnum,
       empcod            like datksrr.empcod,
       funmat            like datksrr.funmat,
       funmatdig         dec (1,0),
       nxtdddcod         like datksrr.nxtdddcod,
       nxtide            like datksrr.nxtide,
       nxtnum            like datksrr.nxtnum,
       srrprnnom         like datksrr.srrprnnom,
       caddat            like datksrr.caddat,
       cadfunnom         like isskfunc.funnom,
       atldat            like datksrr.atldat,
       funnom            like isskfunc.funnom,
       lgdtip            like datksrrend.lgdtip,
       lgdnom            like datksrrend.lgdnom,
       lgdnum            like datksrrend.lgdnum,
       endlgdcmp         like datksrrend.endlgdcmp,
       brrnom            like datksrrend.brrnom,
       cidnom            like datksrrend.cidnom,
       endufdcod         like datksrrend.ufdcod,
       endcep            like datksrrend.endcep,
       endcepcmp         like datksrrend.endcepcmp,
       lgdrefptodes      like datksrrend.lgdrefptodes,
       dddcod            like datksrrend.dddcod,
       telnum            like datksrrend.telnum,
       srrendobs         like datksrrend.srrendobs,
       srrtip            like datksrr.srrtip,
       socanlsitcod      like datksrr.socanlsitcod,
       rdranlultdat      like datksrr.rdranlultdat,
       rdranlsitcod      like datksrr.rdranlsitcod,
       separador1        char(01),
       separador2        char(01),
       separador3        char(01),
       descsocor         char(20),
       descps            char(20),
       descradar         char(20),
       maides            like datksrr.maides,
       socvidseg         char (1),
       coderro           integer                    ## Codigo erro func externas
   end record

   define lr_ctc44m00_ant record
          srrnom          like datksrr.srrnom
         ,srrabvnom       like datksrr.srrabvnom
         ,srrstt          like datksrr.srrstt
     ### ,srrsttdes       char (10)
         ,srrsttdes       char (24) #--> PSI-21950
         ,sexcod          like datksrr.sexcod
         ,nscdat          like datksrr.nscdat
         ,estcvlcod       like datksrr.estcvlcod
         ,pesalt          like datksrr.pesalt
         ,pespso          like datksrr.pespso
         ,srrcmsnum       like datksrr.srrcmsnum
         ,srrclcnum       like datksrr.srrclcnum
         ,srrcldnum       like datksrr.srrcldnum
         ,rgenum          like datksrr.rgenum
         ,rgeufdcod       like datksrr.rgeufdcod
         ,pestip          like datksrr.pestip
         ,cgccpfnum       like datksrr.cgccpfnum
         ,cgcord          like datksrr.cgcord
         ,cgccpfdig       like datksrr.cgccpfdig
         ,cprnum          like datksrr.cprnum
         ,cprsernum       like datksrr.cprsernum
         ,cprufdcod       like datksrr.cprufdcod
         ,cnhnum          like datksrr.cnhnum
         ,cnhautctg       like datksrr.cnhautctg
         ,cnhmotctg       like datksrr.cnhmotctg
         ,cnhpridat       like datksrr.cnhpridat
         ,exmvctdat       like datksrr.exmvctdat
         ,celdddcod       like datksrr.celdddcod
         ,celtelnum       like datksrr.celtelnum
         ,empcod          like datksrr.empcod
         ,funmat          like datksrr.funmat
         ,funmatdig       dec (1,0)
         ,nxtdddcod       like datksrr.nxtdddcod
         ,nxtide          like datksrr.nxtide
         ,nxtnum          like datksrr.nxtnum
         ,srrprnnom       like datksrr.srrprnnom
         ,srrtip          like datksrr.srrtip
         ,socanlsitcod    like datksrr.socanlsitcod
         ,rdranlultdat    like datksrr.rdranlultdat
         ,rdranlsitcod    like datksrr.rdranlsitcod
         ,separador1      char(01)
         ,separador2      char(01)
         ,separador3      char(01)
         ,descsocor       char(20)
         ,descps          char(20)
         ,descradar       char(20)
         ,painom          like datksrr.painom
         ,maenom          like datksrr.maenom
         ,nacdes          like datksrr.nacdes
         ,ufdcod          like datksrr.ufdcod
         ,lgdtip          like datksrrend.lgdtip
         ,lgdnom          like datksrrend.lgdnom
         ,lgdnum          like datksrrend.lgdnum
         ,endlgdcmp       like datksrrend.endlgdcmp
         ,brrnom          like datksrrend.brrnom
         ,cidnom          like datksrrend.cidnom
         ,endufdcod       like datksrrend.ufdcod
         ,endcep          like datksrrend.endcep
         ,endcepcmp       like datksrrend.endcepcmp
         ,lgdrefptodes    like datksrrend.lgdrefptodes
         ,dddcod          like datksrrend.dddcod
         ,telnum          like datksrrend.telnum
         ,srrendobs       like datksrrend.srrendobs
         ,cojnom          like datksrr.cojnom
         ,srrdpdqtd       like datksrr.srrdpdqtd
         ,maides            like datksrr.maides
          end record

   define l_mesg     char(3000)
         ,l_mensagem char(100)
	 ,l_flg      integer
	 ,l_stt      smallint
         ,l_cmd      char(100)
         ,l_mensmail char(3000)

   let l_mensagem = 'Alteracao no cadastro do socorrista. Codigo : ',
		    lr_ctc44m00.srrcoddig
   let l_flg      = 0
   let l_mensmail = null

   if (lr_ctc44m00_ant.srrnom is null     and lr_ctc44m00.srrnom is not null) or
      (lr_ctc44m00_ant.srrnom is not null and lr_ctc44m00.srrnom is null)     or
      (lr_ctc44m00_ant.srrnom              <> lr_ctc44m00.srrnom)             then
      let l_mesg = "Nome do Socorrista alterado de [",lr_ctc44m00_ant.srrnom clipped,
          "] para [",lr_ctc44m00.srrnom clipped,"]"

      let l_mensmail = l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.srrabvnom is null     and lr_ctc44m00.srrabvnom is not null) or
      (lr_ctc44m00_ant.srrabvnom is not null and lr_ctc44m00.srrabvnom is null)     or
      (lr_ctc44m00_ant.srrabvnom              <> lr_ctc44m00.srrabvnom)             then
      let l_mesg = "Nome Abreviado alterado de [",lr_ctc44m00_ant.srrabvnom clipped,
          "] para [",lr_ctc44m00.srrabvnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then
         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.srrstt is null     and lr_ctc44m00.srrstt is not null) or
      (lr_ctc44m00_ant.srrstt is not null and lr_ctc44m00.srrstt is null)     or
      (lr_ctc44m00_ant.srrstt              <> lr_ctc44m00.srrstt)             then
      let l_mesg = "Situacao alterado de [",lr_ctc44m00_ant.srrstt clipped,"-",
          lr_ctc44m00_ant.srrsttdes,"] para [",lr_ctc44m00.srrstt clipped,"-",
          lr_ctc44m00.srrsttdes,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.sexcod is null     and lr_ctc44m00.sexcod is not null) or
      (lr_ctc44m00_ant.sexcod is not null and lr_ctc44m00.sexcod is null)     or
      (lr_ctc44m00_ant.sexcod              <> lr_ctc44m00.sexcod)             then
      let l_mesg = "Sexo alterado de [",lr_ctc44m00_ant.sexcod clipped, "] para [",
                   lr_ctc44m00.sexcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.nscdat is null     and lr_ctc44m00.nscdat is not null) or
      (lr_ctc44m00_ant.nscdat is not null and lr_ctc44m00.nscdat is null)     or
      (lr_ctc44m00_ant.nscdat              <> lr_ctc44m00.nscdat)             then
      let l_mesg = "Data Nascimento alterado de [",lr_ctc44m00_ant.nscdat clipped,
                   "] para [",lr_ctc44m00.nscdat clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.estcvlcod is null     and lr_ctc44m00.estcvlcod is not null) or
      (lr_ctc44m00_ant.estcvlcod is not null and lr_ctc44m00.estcvlcod is null)     or
      (lr_ctc44m00_ant.estcvlcod              <> lr_ctc44m00.estcvlcod)             then
      let l_mesg = "Estado Civil alterado de [",lr_ctc44m00_ant.estcvlcod clipped,
                   "] para [",lr_ctc44m00.estcvlcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig

                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.pesalt is null     and lr_ctc44m00.pesalt is not null) or
      (lr_ctc44m00_ant.pesalt is not null and lr_ctc44m00.pesalt is null)     or
      (lr_ctc44m00_ant.pesalt              <> lr_ctc44m00.pesalt)             then
      let l_mesg = "Altura alterado de [",lr_ctc44m00_ant.pesalt clipped, "] para [",
                   lr_ctc44m00.pesalt clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.pespso is null     and lr_ctc44m00.pespso is not null) or
      (lr_ctc44m00_ant.pespso is not null and lr_ctc44m00.pespso is null)     or
      (lr_ctc44m00_ant.pespso              <> lr_ctc44m00.pespso)             then
      let l_mesg = "peso alterado de [",lr_ctc44m00_ant.pespso clipped, "] para [",
                   lr_ctc44m00.pespso clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.srrcmsnum is null     and lr_ctc44m00.srrcmsnum is not null) or
      (lr_ctc44m00_ant.srrcmsnum is not null and lr_ctc44m00.srrcmsnum is null)     or
      (lr_ctc44m00_ant.srrcmsnum              <> lr_ctc44m00.srrcmsnum)             then
      let l_mesg = "Numero da Camisa alterado de [",lr_ctc44m00_ant.srrcmsnum clipped,
                    "] para [",lr_ctc44m00.srrcmsnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.srrclcnum is null     and lr_ctc44m00.srrclcnum is not null) or
      (lr_ctc44m00_ant.srrclcnum is not null and lr_ctc44m00.srrclcnum is null)     or
      (lr_ctc44m00_ant.srrclcnum              <> lr_ctc44m00.srrclcnum)             then
      let l_mesg = "Numero da Calca alterado de [",lr_ctc44m00_ant.srrclcnum clipped,
                   "] para [",lr_ctc44m00.srrclcnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.srrcldnum is null     and lr_ctc44m00.srrcldnum is not null) or
      (lr_ctc44m00_ant.srrcldnum is not null and lr_ctc44m00.srrcldnum is null)     or
      (lr_ctc44m00_ant.srrcldnum              <> lr_ctc44m00.srrcldnum)             then
      let l_mesg = "numero do calcado alterado de [",lr_ctc44m00_ant.srrcldnum clipped,
                   "] para [",lr_ctc44m00.srrcldnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.rgenum is null     and lr_ctc44m00.rgenum is not null) or
      (lr_ctc44m00_ant.rgenum is not null and lr_ctc44m00.rgenum is null)     or
      (lr_ctc44m00_ant.rgenum             <> lr_ctc44m00.rgenum)              then
      let l_mesg = "Numero do RG alterado de [",lr_ctc44m00_ant.rgenum clipped, "] para [",
                   lr_ctc44m00.rgenum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.rgeufdcod is null     and lr_ctc44m00.rgeufdcod is not null) or
      (lr_ctc44m00_ant.rgeufdcod is not null and lr_ctc44m00.rgeufdcod is null)     or
      (lr_ctc44m00_ant.rgeufdcod              <> lr_ctc44m00.rgeufdcod)             then
      let l_mesg = "Estado Emissor alterado de [",lr_ctc44m00_ant.rgeufdcod clipped,
                   "] para [", lr_ctc44m00.rgeufdcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.pestip is null     and lr_ctc44m00.pestip is not null) or
      (lr_ctc44m00_ant.pestip is not null and lr_ctc44m00.pestip is null)     or
      (lr_ctc44m00_ant.pestip              <> lr_ctc44m00.pestip)             then
      let l_mesg = "Tipo Pessoa alterado de [",lr_ctc44m00_ant.pestip clipped, "] para [",
                   lr_ctc44m00.pestip clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cgccpfnum is null     and lr_ctc44m00.cgccpfnum is not null) or
      (lr_ctc44m00_ant.cgccpfnum is not null and lr_ctc44m00.cgccpfnum is null)     or
      (lr_ctc44m00_ant.cgccpfnum              <> lr_ctc44m00.cgccpfnum)             then
      let l_mesg = "Numero CGC/CPF alterado de [",lr_ctc44m00_ant.cgccpfnum clipped,
                   "] para [",lr_ctc44m00.cgccpfnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cgcord is null     and lr_ctc44m00.cgcord is not null) or
      (lr_ctc44m00_ant.cgcord is not null and lr_ctc44m00.cgcord is null)     or
      (lr_ctc44m00_ant.cgcord              <> lr_ctc44m00.cgcord)             then
      let l_mesg = "Ordem do CGC/CPF  alterado de [",lr_ctc44m00_ant.cgcord clipped,
                   "] para [",lr_ctc44m00.cgcord clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cgccpfdig is null     and lr_ctc44m00.cgccpfdig is not null) or
      (lr_ctc44m00_ant.cgccpfdig is not null and lr_ctc44m00.cgccpfdig is null)     or
      (lr_ctc44m00_ant.cgccpfdig              <> lr_ctc44m00.cgccpfdig)             then
      let l_mesg = "Digito do CGC/CPF alterado de [",lr_ctc44m00_ant.cgccpfdig clipped,
                   "] para [",lr_ctc44m00.cgccpfdig clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cprnum is null     and lr_ctc44m00.cprnum is not null) or
      (lr_ctc44m00_ant.cprnum is not null and lr_ctc44m00.cprnum is null)     or
      (lr_ctc44m00_ant.cprnum              <> lr_ctc44m00.cprnum)             then
      let l_mesg = "Carteira Profissional alterado de [",lr_ctc44m00_ant.cprnum clipped,
                   "] para [",lr_ctc44m00.cprnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cprsernum is null     and lr_ctc44m00.cprsernum is not null) or
      (lr_ctc44m00_ant.cprsernum is not null and lr_ctc44m00.cprsernum is null)     or
      (lr_ctc44m00_ant.cprsernum              <> lr_ctc44m00.cprsernum)             then
      let l_mesg = "Serie da Carteria Profissional alterado de [",lr_ctc44m00_ant.cprsernum clipped,
                   "] para [",lr_ctc44m00.cprsernum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cprufdcod is null     and lr_ctc44m00.cprufdcod is not null) or
      (lr_ctc44m00_ant.cprufdcod is not null and lr_ctc44m00.cprufdcod is null)     or
      (lr_ctc44m00_ant.cprufdcod              <> lr_ctc44m00.cprufdcod)             then
      let l_mesg = "Estado Emissor alterado de [",lr_ctc44m00_ant.cprufdcod clipped, "] para [",
                   lr_ctc44m00.cprufdcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cnhnum is null     and lr_ctc44m00.cnhnum is not null) or
      (lr_ctc44m00_ant.cnhnum is not null and lr_ctc44m00.cnhnum is null)     or
      (lr_ctc44m00_ant.cnhnum              <> lr_ctc44m00.cnhnum)             then
      let l_mesg = "Numero Cnh alterado de [",lr_ctc44m00_ant.cnhnum clipped, "] para [",
                   lr_ctc44m00.cnhnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cnhautctg is null     and lr_ctc44m00.cnhautctg is not null) or
      (lr_ctc44m00_ant.cnhautctg is not null and lr_ctc44m00.cnhautctg is null)     or
      (lr_ctc44m00_ant.cnhautctg              <> lr_ctc44m00.cnhautctg)             then
      let l_mesg = "categoria automovel da CNH alterado de [",lr_ctc44m00_ant.cnhautctg clipped,
                   "] para [",lr_ctc44m00.cnhautctg clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cnhmotctg is null     and lr_ctc44m00.cnhmotctg is not null) or
      (lr_ctc44m00_ant.cnhmotctg is not null and lr_ctc44m00.cnhmotctg is null)     or
      (lr_ctc44m00_ant.cnhmotctg              <> lr_ctc44m00.cnhmotctg)             then
      let l_mesg = "Categoria Moto da CNH alterado de [",lr_ctc44m00_ant.cnhmotctg clipped,
                   "] para [",lr_ctc44m00.cnhmotctg clipped,"]"

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.cnhpridat is null     and lr_ctc44m00.cnhpridat is not null) or
      (lr_ctc44m00_ant.cnhpridat is not null and lr_ctc44m00.cnhpridat is null)     or
      (lr_ctc44m00_ant.cnhpridat              <> lr_ctc44m00.cnhpridat)             then
      let l_mesg = "Data primeira Habilitacao alterado de [",lr_ctc44m00_ant.cnhpridat clipped,
                   "] para [",lr_ctc44m00.cnhpridat clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.exmvctdat is null     and lr_ctc44m00.exmvctdat is not null) or
      (lr_ctc44m00_ant.exmvctdat is not null and lr_ctc44m00.exmvctdat is null)     or
      (lr_ctc44m00_ant.exmvctdat              <> lr_ctc44m00.exmvctdat)             then
      let l_mesg = "Data Vencimento Exame Medico alterado de [",lr_ctc44m00_ant.exmvctdat clipped,
                   "] para [",lr_ctc44m00.exmvctdat clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.celdddcod is null     and lr_ctc44m00.celdddcod is not null) or
      (lr_ctc44m00_ant.celdddcod is not null and lr_ctc44m00.celdddcod is null)     or
      (lr_ctc44m00_ant.celdddcod              <> lr_ctc44m00.celdddcod)             then
      let l_mesg = "DDD Celular alterado de [",lr_ctc44m00_ant.celdddcod clipped, "] para [",
                   lr_ctc44m00.celdddcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.celtelnum is null     and lr_ctc44m00.celtelnum is not null) or
      (lr_ctc44m00_ant.celtelnum is not null and lr_ctc44m00.celtelnum is null)     or
      (lr_ctc44m00_ant.celtelnum              <> lr_ctc44m00.celtelnum)             then
      let l_mesg = "Numero Celular alterado de [",lr_ctc44m00_ant.celtelnum clipped, "] para [",
                   lr_ctc44m00.celtelnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.empcod is null     and lr_ctc44m00.empcod is not null) or
      (lr_ctc44m00_ant.empcod is not null and lr_ctc44m00.empcod is null)     or
      (lr_ctc44m00_ant.empcod              <> lr_ctc44m00.empcod)             then
      let l_mesg = "codigo Empresa alterado de [",lr_ctc44m00_ant.empcod clipped, "] para [",
                   lr_ctc44m00.empcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.funmat is null     and lr_ctc44m00.funmat is not null) or
      (lr_ctc44m00_ant.funmat is not null and lr_ctc44m00.funmat is null)     or
      (lr_ctc44m00_ant.funmat              <> lr_ctc44m00.funmat)             then
      let l_mesg = "Numero da Matricula alterado de [",lr_ctc44m00_ant.funmat clipped,
                   "] para [",lr_ctc44m00.funmat clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.funmatdig is null     and lr_ctc44m00.funmatdig is not null) or
      (lr_ctc44m00_ant.funmatdig is not null and lr_ctc44m00.funmatdig is null)     or
      (lr_ctc44m00_ant.funmatdig              <> lr_ctc44m00.funmatdig)             then
      let l_mesg = "Digito da matricula alterado de [",lr_ctc44m00_ant.funmatdig clipped,
                   "] para [",lr_ctc44m00.funmatdig clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.nxtdddcod is null     and lr_ctc44m00.nxtdddcod is not null) or
      (lr_ctc44m00_ant.nxtdddcod is not null and lr_ctc44m00.nxtdddcod is null)     or
      (lr_ctc44m00_ant.nxtdddcod              <> lr_ctc44m00.nxtdddcod)             then
      let l_mesg = "DDD Nextel alterado de [",lr_ctc44m00_ant.nxtdddcod clipped,
                   "] para [",lr_ctc44m00.nxtdddcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.nxtide is null     and lr_ctc44m00.nxtide is not null) or
      (lr_ctc44m00_ant.nxtide is not null and lr_ctc44m00.nxtide is null)     or
      (lr_ctc44m00_ant.nxtide              <> lr_ctc44m00.nxtide)             then
      let l_mesg = "ID Nextel alterado de [",lr_ctc44m00_ant.nxtide clipped,
                   "] para [",lr_ctc44m00.nxtide clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.nxtnum is null     and lr_ctc44m00.nxtnum is not null) or
      (lr_ctc44m00_ant.nxtnum is not null and lr_ctc44m00.nxtnum is null)     or
      (lr_ctc44m00_ant.nxtnum              <> lr_ctc44m00.nxtnum)             then
      let l_mesg = "N�mero Nextel alterado de [",lr_ctc44m00_ant.nxtnum clipped,
                   "] para [",lr_ctc44m00.nxtnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.srrprnnom is null     and lr_ctc44m00.srrprnnom is not null) or
      (lr_ctc44m00_ant.srrprnnom is not null and lr_ctc44m00.srrprnnom is null)     or
      (lr_ctc44m00_ant.srrprnnom              <> lr_ctc44m00.srrprnnom)             then
      let l_mesg = "Nome do Parente na Porto alterado de [",lr_ctc44m00_ant.srrprnnom clipped,
                    "] para [",lr_ctc44m00.srrprnnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.srrtip is null     and lr_ctc44m00.srrtip is not null) or
      (lr_ctc44m00_ant.srrtip is not null and lr_ctc44m00.srrtip is null)     or
      (lr_ctc44m00_ant.srrtip              <> lr_ctc44m00.srrtip)             then
      let l_mesg = "Tipo socorrista alterado de [",lr_ctc44m00_ant.srrtip clipped, "] para [",
                   lr_ctc44m00.srrtip clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.socanlsitcod is null     and lr_ctc44m00.socanlsitcod is not null) or
      (lr_ctc44m00_ant.socanlsitcod is not null and lr_ctc44m00.socanlsitcod is null)     or
      (lr_ctc44m00_ant.socanlsitcod              <> lr_ctc44m00.socanlsitcod)             then
      let l_mesg = "Analise  alterado de [",lr_ctc44m00_ant.socanlsitcod clipped,
          "-",lr_ctc44m00_ant.descps,"] para [",lr_ctc44m00.socanlsitcod clipped,
          "-",lr_ctc44m00.descps,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.rdranlsitcod is null     and lr_ctc44m00.rdranlsitcod is not null) or
      (lr_ctc44m00_ant.rdranlsitcod is not null and lr_ctc44m00.rdranlsitcod is null)     or
      (lr_ctc44m00_ant.rdranlsitcod              <> lr_ctc44m00.rdranlsitcod)             then
      let l_mesg = "Analise Radar alterado de [",lr_ctc44m00_ant.rdranlsitcod clipped,
          "-",lr_ctc44m00_ant.descradar,"] para [",lr_ctc44m00.rdranlsitcod clipped,
          "-",lr_ctc44m00.descradar,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if


   if (lr_ctc44m00_ant.lgdtip is null     and lr_ctc44m00.lgdtip is not null) or
      (lr_ctc44m00_ant.lgdtip is not null and lr_ctc44m00.lgdtip is null)     or
      (lr_ctc44m00_ant.lgdtip              <> lr_ctc44m00.lgdtip)             then
      let l_mesg = "Tipo Logradouro alterado de [",lr_ctc44m00_ant.lgdtip clipped, "] para [",
                    lr_ctc44m00.lgdtip clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.lgdnom is null     and lr_ctc44m00.lgdnom is not null) or
      (lr_ctc44m00_ant.lgdnom is not null and lr_ctc44m00.lgdnom is null)     or
      (lr_ctc44m00_ant.lgdnom              <> lr_ctc44m00.lgdnom)             then
      let l_mesg = "Logradouro alterado de [",lr_ctc44m00_ant.lgdnom clipped, "] para [",
                   lr_ctc44m00.lgdnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

   if (lr_ctc44m00_ant.lgdnum is null     and lr_ctc44m00.lgdnum is not null) or
      (lr_ctc44m00_ant.lgdnum is not null and lr_ctc44m00.lgdnum is null)     or
      (lr_ctc44m00_ant.lgdnum              <> lr_ctc44m00.lgdnum)             then
      let l_mesg = "Tipo Logradouro alterado de [",lr_ctc44m00_ant.lgdnum clipped, "] para [",
                   lr_ctc44m00.lgdnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if

   end if

  if (lr_ctc44m00_ant.endlgdcmp is null     and lr_ctc44m00.endlgdcmp is not null) or
      (lr_ctc44m00_ant.endlgdcmp is not null and lr_ctc44m00.endlgdcmp is null)     or
      (lr_ctc44m00_ant.endlgdcmp              <> lr_ctc44m00.endlgdcmp)             then
      let l_mesg = "Complemento do Endereco alterado de [",lr_ctc44m00_ant.endlgdcmp clipped,
                   "] para [",lr_ctc44m00.endlgdcmp clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

    if (lr_ctc44m00_ant.brrnom is null     and lr_ctc44m00.brrnom is not null) or
      (lr_ctc44m00_ant.brrnom is not null and lr_ctc44m00.brrnom is null)     or
      (lr_ctc44m00_ant.brrnom              <> lr_ctc44m00.brrnom)             then
      let l_mesg = "Nome do Bairro alterado de [",lr_ctc44m00_ant.brrnom clipped, "] para [",
                   lr_ctc44m00.brrnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.cidnom is null     and lr_ctc44m00.cidnom is not null) or
      (lr_ctc44m00_ant.cidnom is not null and lr_ctc44m00.cidnom is null)     or
      (lr_ctc44m00_ant.cidnom              <> lr_ctc44m00.cidnom)             then
      let l_mesg = "Cidade alterado de [",lr_ctc44m00_ant.cidnom clipped, "] para [",
                   lr_ctc44m00.cidnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

    if (lr_ctc44m00_ant.ufdcod is null     and lr_ctc44m00.ufdcod is not null) or
      (lr_ctc44m00_ant.ufdcod is not null and lr_ctc44m00.ufdcod is null)     or
      (lr_ctc44m00_ant.ufdcod              <> lr_ctc44m00.ufdcod)             then
      let l_mesg = "UF alterado de [",lr_ctc44m00_ant.ufdcod clipped, "] para [",
                   lr_ctc44m00.ufdcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

     if (lr_ctc44m00_ant.endcep is null     and lr_ctc44m00.endcep is not null) or
      (lr_ctc44m00_ant.endcep is not null and lr_ctc44m00.endcep is null)     or
      (lr_ctc44m00_ant.endcep              <> lr_ctc44m00.endcep)             then
      let l_mesg = "CEP alterado de [",lr_ctc44m00_ant.endcep clipped, "] para [",
                   lr_ctc44m00.endcep clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.endcepcmp is null     and lr_ctc44m00.endcepcmp is not null) or
      (lr_ctc44m00_ant.endcepcmp is not null and lr_ctc44m00.endcepcmp is null)     or
      (lr_ctc44m00_ant.endcepcmp              <> lr_ctc44m00.endcepcmp)             then
      let l_mesg = "Complemento CEP alterado de [",lr_ctc44m00_ant.endcepcmp clipped, "] para [",
                   lr_ctc44m00.endcepcmp clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.dddcod is null     and lr_ctc44m00.dddcod is not null) or
      (lr_ctc44m00_ant.dddcod is not null and lr_ctc44m00.dddcod is null)     or
      (lr_ctc44m00_ant.dddcod              <> lr_ctc44m00.dddcod)             then
      let l_mesg = "DDD alterado de [",lr_ctc44m00_ant.dddcod clipped, "] para [",
                   lr_ctc44m00.dddcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.telnum is null     and lr_ctc44m00.telnum is not null) or
      (lr_ctc44m00_ant.telnum is not null and lr_ctc44m00.telnum is null)     or
      (lr_ctc44m00_ant.telnum              <> lr_ctc44m00.telnum)             then
      let l_mesg = "Numero Telefone alterado de [",lr_ctc44m00_ant.telnum clipped, "] para [",
                   lr_ctc44m00.telnum clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.srrendobs is null     and lr_ctc44m00.srrendobs is not null) or
      (lr_ctc44m00_ant.srrendobs is not null and lr_ctc44m00.srrendobs is null)     or
      (lr_ctc44m00_ant.srrendobs              <> lr_ctc44m00.srrendobs)             then
      let l_mesg = "Observacao alterado de [",lr_ctc44m00_ant.srrendobs clipped, "] para [",
                   lr_ctc44m00.srrendobs clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.lgdrefptodes is null     and lr_ctc44m00.lgdrefptodes is not null) or
      (lr_ctc44m00_ant.lgdrefptodes is not null and lr_ctc44m00.lgdrefptodes is null)     or
      (lr_ctc44m00_ant.lgdrefptodes              <> lr_ctc44m00.lgdrefptodes)             then
      let l_mesg = "Ponto de Referencia alterado de [",lr_ctc44m00_ant.lgdrefptodes clipped,
                   "] para [", lr_ctc44m00.lgdrefptodes clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.painom is null     and lr_ctc44m00.painom is not null) or
      (lr_ctc44m00_ant.painom is not null and lr_ctc44m00.painom is null)     or
      (lr_ctc44m00_ant.painom              <> lr_ctc44m00.painom)             then
      let l_mesg = "Nome do Pai alterado de [",lr_ctc44m00_ant.painom clipped, "] para [",
                   lr_ctc44m00.painom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.maenom is null     and lr_ctc44m00.maenom is not null) or
      (lr_ctc44m00_ant.maenom is not null and lr_ctc44m00.maenom is null)     or
      (lr_ctc44m00_ant.maenom              <> lr_ctc44m00.maenom)             then
      let l_mesg = "Nome da mae alterado de [",lr_ctc44m00_ant.maenom clipped, "] para [",
                   lr_ctc44m00.maenom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.nacdes is null     and lr_ctc44m00.nacdes is not null) or
      (lr_ctc44m00_ant.nacdes is not null and lr_ctc44m00.nacdes is null)     or
      (lr_ctc44m00_ant.nacdes              <> lr_ctc44m00.nacdes)             then
      let l_mesg = "Nacionalidade alterado de [",lr_ctc44m00_ant.nacdes clipped, "] para [",
                   lr_ctc44m00.nacdes clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.ufdcod is null     and lr_ctc44m00.ufdcod is not null) or
      (lr_ctc44m00_ant.ufdcod is not null and lr_ctc44m00.ufdcod is null)     or
      (lr_ctc44m00_ant.ufdcod              <> lr_ctc44m00.ufdcod)             then
      let l_mesg = "Naturalidade alterada de [",lr_ctc44m00_ant.ufdcod clipped, "] para [",
                   lr_ctc44m00.ufdcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.cojnom is null     and lr_ctc44m00.cojnom is not null) or
      (lr_ctc44m00_ant.cojnom is not null and lr_ctc44m00.cojnom is null)     or
      (lr_ctc44m00_ant.cojnom              <> lr_ctc44m00.cojnom)             then
      let l_mesg = "Nome do Conjuge alterada de [",lr_ctc44m00_ant.cojnom clipped, "] para [",
                   lr_ctc44m00.cojnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if (lr_ctc44m00_ant.srrdpdqtd is null     and lr_ctc44m00.srrdpdqtd is not null) or
      (lr_ctc44m00_ant.srrdpdqtd is not null and lr_ctc44m00.srrdpdqtd is null)     or
      (lr_ctc44m00_ant.srrdpdqtd              <> lr_ctc44m00.srrdpdqtd)             then
      let l_mesg = "Qtde Depend. alterada de [",lr_ctc44m00_ant.srrdpdqtd clipped, "] para [",
                   lr_ctc44m00.srrdpdqtd clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if


   if (lr_ctc44m00_ant.maides is null     and lr_ctc44m00.maides is not null) or
      (lr_ctc44m00_ant.maides is not null and lr_ctc44m00.maides is null)     or
      (lr_ctc44m00_ant.maides              <> lr_ctc44m00.maides)             then
      let l_mesg = "Endere�o de Email alterado de [",lr_ctc44m00_ant.maides clipped,
                   "] para [", lr_ctc44m00.maides clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mesg clipped
      let l_flg = 1

      if not ctc44m00_grava_hist(lr_ctc44m00.srrcoddig
                                ,l_mesg
                                ,lr_ctc44m00.atldat
                                ,l_mensagem,"A") then

         let l_mesg     = "Erro gravacao Historico "
         let l_mensmail = l_mensmail clipped, " ",l_mesg clipped
      end if
   end if

   if l_flg = 1 then
      call ctc44m00_envia_email(l_mensagem,lr_ctc44m00.atldat ,
				current hour to minute ,l_flg,l_mensmail)
      returning l_stt
   end if

end function

#------------------------------------------------
function ctc44m00_envia_email(lr_param)
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
         ,l_cmd       char(4000)
         ,l_texto     char(3000)
         ,l_mensmail2 like dbsmhstprs.prshstdes
         ,l_count
         ,l_iter
         ,l_erro
         ,l_length
         ,l_length2    smallint

   let l_stt  = true
   let l_path = null

   call ctb85g01_mtcorpo_email_html('CTC44M00',
				    lr_param.data,
                                    lr_param.hora,
                                    g_issk.empcod,
                                    g_issk.usrtip,
                                    g_issk.funmat,
                                    lr_param.titulo,
                                    lr_param.mensmail)
                  returning l_erro

   if l_erro <> 0 then
      error 'Erro(',l_erro,') no envio do e-mail' sleep 2
      let l_stt = false
     else
       let l_stt = true
   end if

   return l_stt

end function

##-----------------------------------#
# function ctd44m00_usrweb_qra(param)
##-----------------------------------#
#
#     define param record
#         srrcoddig like datksrr.srrcoddig,
#         srrabvnom like datksrr.srrabvnom,
#         celdddcod like datksrr.celdddcod,
#         celtelnum like datksrr.celtelnum,
#         maides    like datksrr.maides
#     end record
#
#     define lr_aux record
#         errcod    smallint,
#         errmsg    char(100),
#         pstcoddig like dpaksocor.pstcoddig,
#         perfil    char(50),
#         nomgrr    like dpaksocor.nomgrr
#     end record
#
#     if m_ctc44m00_prep is null or
#        m_ctc44m00_prep <> true then
#        call ctc44m00_prepare()
#     end if
#
#     call ctd30g00_vinculo_info(param.srrcoddig)
#          returning lr_ret.errcod,
#                    lr_ret.errmsg,
#                    lr_ret.pstcoddig
#                    lr_aux.pcpatvdes
#                    lr_aux.pstvindes
#
#     if  lr_aux.errcod <> 0 then
#         display lr_aux.errmsg
#         sleep 2
#         return
#     end if
#
#     let lr_aux.perfil = lr_aux.pcpatvdes clipped, "_", lr_aux.pstvindes
#
#     open cctd30g00_07 using lr_ret.pstcoddig
#     fetch cctd30g00_07 into lr_aux.nomgrr
#
#     if  sqlca.sqlcode <> 0 then
#         #tratar erro
#     end if
#
#     call ctd30g00_inclui_webusr_qra(param.srrabvnom,
#                                     lr_aux.pstvindes,
#                                     param.celdddcod,
#                                     param.celtelnum,
#                                     param.maides,
#                                     lr_ret.pstcoddig,
#                                     lr_aux.nomgrr,
#                                     param.srrcoddig
#                                     lr_aux.perfil)
#          returning lr_ret.errcod,
#                    lr_ret.errmsg
#
# end function
#
#
# function ctc44m00_atualiza_portal
#
