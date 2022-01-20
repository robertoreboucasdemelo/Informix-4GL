 ###########################################################################
 # Nome do Modulo: ctc34m01                                        Marcelo #
 #                                                                Gilberto #
 # Cadastro de veiculos do Porto Socorro                          Ago/1998  #
 ########################################################################## #
 # Alteracoes:                                                              #
 #                                                                          #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
 #--------------------------------------------------------------------------#
 # 10/12/1998  PSI 6477-7   Wagner       Inclusao de 4 campos para modulo   #
 #                                       de agendamento de vistoria.:       #
 #                                       vclaqstipcod, vclaqsnom,           #
 #                                       socvstlclcod e socvstlautipcod.    #
 #--------------------------------------------------------------------------#
 # 05/09/2000  PSI 11459-6  Wagner       Gravar "0" no campo socacsflg qdo  #
 #                                       o veiculo for cadastrado.          #
 #--------------------------------------------------------------------------#
 # 18/12/2000  PSI 12023-5  Marcus       Alterar cadastro de viaturas para  #
 #                                       trabalhar com grupo de acionamento #
 #--------------------------------------------------------------------------#
 # 09/01/2001  PSI 12019-7  Wagner       Incluir tratamento novo campo      #
 #                                       numero teletrim.                   #
 #--------------------------------------------------------------------------#
 # 06/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador   #
 #                                       B-Bloqueado.                       #
 #--------------------------------------------------------------------------#
 #                   * * * * A L T E R A C A O * * * *                      #
 #  Analista Resp. : Wagner Agostinho                 OSF : 11444           #
 #  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 08/01/2003      #
 #  Objetivo       : Incluir campo Tipo Equip. Socorro (socvcltip)          #
 #--------------------------------------------------------------------------#
 # 21/11/2006  PSI 205206   Priscila     Incluir campo "Empresa"            #
 #--------------------------------------------------------------------------#
 # 05/08/2008  PSI226300    Diomar,Meta  Incluido gravacao do historico     #
 #--------------------------------------------------------------------------#
 # 09/09/2009  PSI247596    Burini       Restrição no campo DDD/celular     #
 #--------------------------------------------------------------------------#
 # 27/11/2009  PSI247596    Beatriz    Seleciona pelo campo sigla da viatura#
 #--------------------------------------------------------------------------#
 # 30/08/2010  PAS103306    Beatriz    Verifica em um dominio departamentos #
 #                                    que podem alterar o celular da viatura#
 #--------------------------------------------------------------------------#
 # 15/09/2010 PSI201000009EV Beatriz  Obrigar o usuario a incluir um seguro #
 #                                    quando incluir ou alterar um viatura  #
 #                                   que não tenha seguro cadastrado.Incluir#
 #                                    o campo Renavam no cadastro do veiculo#
 #--------------------------------------------------------------------------#
 # 23/10/2015 Chamado 669909 Eliane,Fornax  Erro no input - falta close nos #
 #                                          cursores                        #
 #--------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define vst           record
   ok                 char(1),
   socvstnum          like datmsocvst.socvstnum,
   socvstdat_new      like datmsocvst.socvstdat,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd
 end record

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record

  define atdvclsglS   like datkveiculo.atdvclsgl      # Para a opcao seleciona
 define m_ctc34m01_prep smallint
 define teste       char(1)

#-------------------------#
function ctc34m01_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select celdddcod, ",
                   " celtelnum, ",
                   " socvclcod ",
              " from datkveiculo "

  prepare pctc34m01002 from l_sql
  declare cctc34m01002 cursor for pctc34m01002

  let l_sql = "select cpodes ",
               " from iddkdominio ",
              " where iddkdominio.cponom = ? ",
                " and iddkdominio.cpocod = ? "

  prepare pctc34m01003 from l_sql
  declare cctc34m01003 cursor for pctc34m01003

  let l_sql = "select frtrpnflg ",
               " from dpaksocor ",
              " where pstcoddig = ? "

  prepare pctc34m01004 from l_sql
  declare cctc34m01004 cursor for pctc34m01004  
  
  
  let l_sql ="select cpodes ",                            
              " from iddkdominio ",                     
             " where iddkdominio.cponom = ? ",           
               " and iddkdominio.cpodes = ? " 
                         
  prepare pctc34m01009 from l_sql               
  declare cctc34m01009 cursor for pctc34m01009

  let m_ctc34m01_prep = true

end function

#------------------------------------------------------------
 function ctc34m01()
#------------------------------------------------------------

 define d_ctc34m01    record
   socvclcod          like datkveiculo.socvclcod,
   pstcoddig          like datkveiculo.pstcoddig,
   nomgrr             like dpaksocor.nomgrr,
   vclctfnom          like datkveiculo.vclctfnom,
   socoprsitcod       like datkveiculo.socoprsitcod,
   socoprsitdes       char (09),
   vclaqstipcod       like datkveiculo.vclaqstipcod,
   aqsdes             like iddkdominio.cpodes,
   vclaqsnom          like datkveiculo.vclaqsnom,
   vclcoddig          like datkveiculo.vclcoddig,
   vcldes             char (58),
   socvcltip          like datkveiculo.socvcltip,
   socvcldes          like iddkdominio.cpodes,
   chassi             char (20),
   vcllicnum          like datkveiculo.vcllicnum,
   vclanofbc          like datkveiculo.vclanofbc,
   vclanomdl          like datkveiculo.vclanomdl,
   vclcorcod          like datkveiculo.vclcorcod,
   vclcordes          char (20),
   vclpnttip          like datkveiculo.vclpnttip,
   vclpntdes          char (20),
   vclcmbcod          like datkveiculo.vclcmbcod,
   vclcmbdes          char (20),
   socctrposflg       like datkveiculo.socctrposflg,
   atdvclsgl          like datkveiculo.atdvclsgl,
   vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
   vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
   atdimpcod          like datkveiculo.atdimpcod,
   mdtcod             like datkveiculo.mdtcod,
   gpsacngrpcod       like dattfrotalocal.gpsacngrpcod,
   trxeqpsitdes       char (15),
   pgrnum             like datkveiculo.pgrnum,
   ustnom             like htlrust.ustnom,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd,
   socvstlclcod       like datkveiculo.socvstlclcod,
   socvstlclnom       like datkvstlcl.socvstlclnom,
   socvstlautipcod    like datkveiculo.socvstlautipcod,
   socvstlautipdes    like datkvstlautip.socvstlautipdes,
   caddat             like datkveiculo.caddat,
   cadfunnom          like isskfunc.funnom,
   atldat             like datkveiculo.atldat,
   funnom             like isskfunc.funnom,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum,
   nxtdddcod          like datkveiculo.nxtdddcod,
   nxtide             like datkveiculo.nxtide,
   nxtnum             like datkveiculo.nxtnum,
   frtrpnflg          like dpaksocor.frtrpnflg,
   frtrpndes          char(20),
   rencod             like datkveiculo.rencod,
   vclcadorgcod       like datkveiculo.vclcadorgcod,
   vclcadorgdes       like iddkdominio.cpodes 
 end record

   define l_aux char(30)

   let l_aux = null
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_ctc34m01.*  to  null

 let int_flag = false
 initialize d_ctc34m01.*  to null
 initialize atdvclsglS to null
 call ctc34m01_prepare()

 if not get_niv_mod(g_issk.prgsgl, "ctc34m01") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window ctc34m01 at 4,2 with form "ctc34m01"

 menu "VEICULOS"

  before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona"   , "Proximo"  , "Anterior",
                    "assisteNcias", "seGuro"   , "pesqUisa",
                    "eQuipamentos", "siTuacao", "Backlight", "Display",
                    "problema_Vistoria", "situacao_vistOria", "padRao",
                    "teCnologia"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona"   , "Proximo"  , "Anterior",
                    "Modifica"    , "Inclui"   , "eQuipamentos",
                    "assisteNcias", "seGuro"   , "pesqUisa", "Empresa",
                    "siTuacao", "Backlight", "Display",
                    "problema_Vistoria", "situacao_vistOria", "padRao",
                    "teCnologia"
     end if

     show option "Encerra"
     show option 'Historico'

 command key ("S") "Seleciona"
                   "Pesquisa veiculo conforme criterios"
          call ctc34m01_seleciona(d_ctc34m01.socvclcod)
               returning d_ctc34m01.*
          if d_ctc34m01.socvclcod  is not null  then
             message ""
             next option "Proximo"
          else
             error " Nenhum veiculo selecionado!"
             message ""
             next option "Seleciona"
          end if

 command key ("P") "Proximo"
                   "Mostra proximo veiculo selecionado"
          message ""
          call ctc34m01_proximo(d_ctc34m01.socvclcod)
               returning d_ctc34m01.*

 command key ("A") "Anterior"
                   "Mostra veiculo anterior selecionado"
          message ""
          if d_ctc34m01.socvclcod is not null then
             call ctc34m01_anterior(d_ctc34m01.socvclcod)
                  returning d_ctc34m01.*
          else
             error " Nenhum veiculo nesta direcao!"
             next option "Seleciona"
          end if

 command key ("M") "Modifica"
                   "Modifica veiculo corrente selecionado"
          message ""
          if d_ctc34m01.socvclcod  is not null then
             if d_ctc34m01.socoprsitcod  =  1   then
                call ctc34m01_modifica(d_ctc34m01.socvclcod, d_ctc34m01.*)
                     returning d_ctc34m01.*
             else
                error " Veiculo bloqueado ou cancelado nao deve ser alterado!"
             end if
          else
             error " Nenhum veiculo selecionado!"
          end if
          next option "Seleciona"

 command key ("I") "Inclui"
                   "Inclui veiculo"
          message ""
          call ctc34m01_inclui()
          next option "Seleciona"

 command key ("Q") "eQuipamentos"
                   "Equipamentos do veiculo corrente selecionado"
          message ""
          if d_ctc34m01.socvclcod  is not null then
             call ctc34m08(d_ctc34m01.socvclcod,
                           d_ctc34m01.atdvclsgl,
                           d_ctc34m01.vcldes)
             next option "Seleciona"
          else
             error " Nenhum veiculo selecionado!"
             next option "Seleciona"
          end if

 command key ("N") "assisteNcias"
                   "Tipos de assistencia do veiculo corrente selecionado"
          message ""
          if d_ctc34m01.socvclcod  is not null then
             call ctc34m06(d_ctc34m01.socvclcod,
                           d_ctc34m01.atdvclsgl,
                           d_ctc34m01.vcldes)
             next option "Seleciona"
          else
             error " Nenhum veiculo selecionado!"
             next option "Seleciona"
          end if

 command key ("G") "seGuro"
                   "Apolices de seguro do veiculo corrente selecionado"
          message ""
          if d_ctc34m01.socvclcod  is not null then
             call ctc34m03(d_ctc34m01.socvclcod,
                           d_ctc34m01.atdvclsgl,
                           d_ctc34m01.vcldes)
             next option "Seleciona"
          else
             error " Nenhum veiculo selecionado!"
             next option "Seleciona"
          end if

 command key ("U") "pesqUisa"
                   "Pesquisa veiculo por: placa, sigla, situacao, prestador, equipamento"
          message ""
          initialize d_ctc34m01.*  to null
          initialize atdvclsglS to null
          display by name atdvclsglS
          display by name d_ctc34m01.*

          call ctn38c00()  returning d_ctc34m01.socvclcod
          display by name d_ctc34m01.socvclcod

          next option "Seleciona"

  command key ("E") "Empresa"  "Mantem o cadastro das empresas atendidas pelo veiculo"
           if d_ctc34m01.socvclcod is not null then
              call ctc34m01_empresa(d_ctc34m01.socvclcod)
              next option "Seleciona"
           else
              error " Nenhum registro selecionado!"
              next option "Seleciona"
           end if


 command key ("T") "siTuacao"
                   "Observacoes sobre a situacao veiculo corrente selecionado"
          message ""
          if d_ctc34m01.socvclcod  is not null then
             call ctc34m02(d_ctc34m01.socvclcod,
                           d_ctc34m01.atdvclsgl,
                           d_ctc34m01.vcldes)

             call ctc34m01_ler(d_ctc34m01.socvclcod)
                  returning d_ctc34m01.*
             
             let atdvclsglS = d_ctc34m01.atdvclsgl
             display by name atdvclsglS
             display by name d_ctc34m01.*
             next option "Seleciona"
          else
             error " Nenhum veiculo selecionado!"
             next option "Seleciona"
          end if

 command key ("B") "Backlight" "Cadastro de Backlight do veiculo"

         message ""
         call ctc34m11()

 command key ("D") "Display " "Cadastro de Display do veiculo"

         message ""
         call ctc34m12()

 command key ("V") "problema_Vistoria" "Cadastro de Problema de Vistoria do veiculo"

         message ""
         call ctc34m13()

 command key ("O") "situacao_vistOria" "Cadastro de Situacao de Vistoria do veiculo"

         message ""
         call ctc34m14()

 command key ("R") "padRao" "Cadastro de Padrao do veiculo"

         message ""

         if d_ctc34m01.socvclcod is not null then
            call ctc34m15(d_ctc34m01.socvclcod)
         else
            error " Nenhum veiculo selecionado!"
            next option "Seleciona"
         end if

 command key ("C") "teCnologia" "Cadastro de Tecnologia do veiculo"

         message ""

         if d_ctc34m01.socvclcod is not null then
            call ctc34m16(d_ctc34m01.socvclcod)
         else
            error " Nenhum veiculo selecionado!"
            next option "Seleciona"
         end if

   command key ("H") 'Historico' 'Consulta o historico'
      if d_ctc34m01.socvclcod  is not null  then
         let l_aux = 'Veiculo'
         call ctb85g00(1
                      ,l_aux
                      ,d_ctc34m01.socvclcod
                      ,d_ctc34m01.vcldes)
      else
         error " Nenhum veiculo selecionado!"
         next option "Seleciona"
      end if

 command key (interrupt) "Encerra"
         "Retorna ao menu anterior"
         exit menu

 end menu

 close window ctc34m01

 end function  # ctc34m01

#------------------------------------------------------------
 function ctc34m01_seleciona(param)
#------------------------------------------------------------

 define param         record
   socvclcod          like datkveiculo.socvclcod
 end record

 define d_ctc34m01    record
   socvclcod          like datkveiculo.socvclcod,
   pstcoddig          like datkveiculo.pstcoddig,
   nomgrr             like dpaksocor.nomgrr,
   vclctfnom          like datkveiculo.vclctfnom,
   socoprsitcod       like datkveiculo.socoprsitcod,
   socoprsitdes       char (09),
   vclaqstipcod       like datkveiculo.vclaqstipcod,
   aqsdes             like iddkdominio.cpodes,
   vclaqsnom          like datkveiculo.vclaqsnom,
   vclcoddig          like datkveiculo.vclcoddig,
   vcldes             char (58),
   socvcltip          like datkveiculo.socvcltip,
   socvcldes          like iddkdominio.cpodes,
   chassi             char (20),
   vcllicnum          like datkveiculo.vcllicnum,
   vclanofbc          like datkveiculo.vclanofbc,
   vclanomdl          like datkveiculo.vclanomdl,
   vclcorcod          like datkveiculo.vclcorcod,
   vclcordes          char (20),
   vclpnttip          like datkveiculo.vclpnttip,
   vclpntdes          char (20),
   vclcmbcod          like datkveiculo.vclcmbcod,
   vclcmbdes          char (20),
   socctrposflg       like datkveiculo.socctrposflg,
   atdvclsgl          like datkveiculo.atdvclsgl,
   vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
   vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
   atdimpcod          like datkveiculo.atdimpcod,
   mdtcod             like datkveiculo.mdtcod,
   gpsacngrpcod       like dattfrotalocal.gpsacngrpcod,
   trxeqpsitdes       char (15),
   pgrnum             like datkveiculo.pgrnum,
   ustnom             like htlrust.ustnom,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd,
   socvstlclcod       like datkveiculo.socvstlclcod,
   socvstlclnom       like datkvstlcl.socvstlclnom,
   socvstlautipcod    like datkveiculo.socvstlautipcod,
   socvstlautipdes    like datkvstlautip.socvstlautipdes,
   caddat             like datkveiculo.caddat,
   cadfunnom          like isskfunc.funnom,
   atldat             like datkveiculo.atldat,
   funnom             like isskfunc.funnom,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum,
   nxtdddcod          like datkveiculo.nxtdddcod,
   nxtide             like datkveiculo.nxtide,
   nxtnum             like datkveiculo.nxtnum,
   frtrpnflg          like dpaksocor.frtrpnflg,
   frtrpndes          char(20),
   rencod             like datkveiculo.rencod,
   vclcadorgcod       like datkveiculo.vclcadorgcod,
   vclcadorgdes       like iddkdominio.cpodes
 end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

       initialize  d_ctc34m01.*  to  null
 initialize atdvclsglS to null
 let int_flag = false
 initialize d_ctc34m01.*  to null
 display by name d_ctc34m01.*

 let d_ctc34m01.socvclcod = param.socvclcod
               
 input by name atdvclsglS   without defaults
 before field atdvclsglS
     display by name atdvclsglS attribute (reverse)
 
 after  field atdvclsglS
     display by name atdvclsglS
     if atdvclsglS is null then 
        input by name d_ctc34m01.socvclcod   without defaults
        before field socvclcod
           display by name d_ctc34m01.socvclcod attribute (reverse)
        after  field socvclcod
           display by name d_ctc34m01.socvclcod
 
           select socvclcod
             from datkveiculo
            where datkveiculo.socvclcod = d_ctc34m01.socvclcod
           
           if sqlca.sqlcode  =  notfound   then
              error " Veiculo nao cadastrado!"
              next field socvclcod
           end if
        on key (interrupt)
           initialize atdvclsglS to null
           exit input   
        end input   
     else
        select socvclcod into d_ctc34m01.socvclcod
          from datkveiculo 
         where atdvclsgl = atdvclsglS
         
         if sqlca.sqlcode  =  notfound   then
              error " Sigla nao cadastrada para nenhum veiculo!"
              next field atdvclsglS
           end if
      end if     
 on key (interrupt)
     initialize atdvclsglS to null
     exit input
 end input

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m01.*   to null
    display by name d_ctc34m01.*
    error " Operacao cancelada!"
    return d_ctc34m01.*
 end if

 call ctc34m01_ler(d_ctc34m01.socvclcod)
      returning d_ctc34m01.*

 if d_ctc34m01.socvclcod  is not null   then
    let atdvclsglS = d_ctc34m01.atdvclsgl
    display by name atdvclsglS
    display by name  d_ctc34m01.*
 else
    error " Veiculo nao cadastrado!"
    initialize d_ctc34m01.*    to null
 end if

 return d_ctc34m01.*

 end function  # ctc34m01_seleciona

#------------------------------------------------------------
 function ctc34m01_proximo(param)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkveiculo.socvclcod
 end record

 define d_ctc34m01    record
   socvclcod          like datkveiculo.socvclcod,
   pstcoddig          like datkveiculo.pstcoddig,
   nomgrr             like dpaksocor.nomgrr,
   vclctfnom          like datkveiculo.vclctfnom,
   socoprsitcod       like datkveiculo.socoprsitcod,
   socoprsitdes       char (09),
   vclaqstipcod       like datkveiculo.vclaqstipcod,
   aqsdes             like iddkdominio.cpodes,
   vclaqsnom          like datkveiculo.vclaqsnom,
   vclcoddig          like datkveiculo.vclcoddig,
   vcldes             char (58),
   socvcltip          like datkveiculo.socvcltip,
   socvcldes          like iddkdominio.cpodes,
   chassi             char (20),
   vcllicnum          like datkveiculo.vcllicnum,
   vclanofbc          like datkveiculo.vclanofbc,
   vclanomdl          like datkveiculo.vclanomdl,
   vclcorcod          like datkveiculo.vclcorcod,
   vclcordes          char (20),
   vclpnttip          like datkveiculo.vclpnttip,
   vclpntdes          char (20),
   vclcmbcod          like datkveiculo.vclcmbcod,
   vclcmbdes          char (20),
   socctrposflg       like datkveiculo.socctrposflg,
   atdvclsgl          like datkveiculo.atdvclsgl,
   vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
   vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
   atdimpcod          like datkveiculo.atdimpcod,
   mdtcod             like datkveiculo.mdtcod,
   gpsacngrpcod       like dattfrotalocal.gpsacngrpcod,
   trxeqpsitdes       char (15),
   pgrnum             like datkveiculo.pgrnum,
   ustnom             like htlrust.ustnom,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd,
   socvstlclcod       like datkveiculo.socvstlclcod,
   socvstlclnom       like datkvstlcl.socvstlclnom,
   socvstlautipcod    like datkveiculo.socvstlautipcod,
   socvstlautipdes    like datkvstlautip.socvstlautipdes,
   caddat             like datkveiculo.caddat,
   cadfunnom          like isskfunc.funnom,
   atldat             like datkveiculo.atldat,
   funnom             like isskfunc.funnom,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum,
   nxtdddcod          like datkveiculo.nxtdddcod,
   nxtide             like datkveiculo.nxtide,
   nxtnum             like datkveiculo.nxtnum,
   frtrpnflg          like dpaksocor.frtrpnflg,
   frtrpndes          char(20),
   rencod             like datkveiculo.rencod,
   vclcadorgcod       like datkveiculo.vclcadorgcod,
   vclcadorgdes       like iddkdominio.cpodes  
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_ctc34m01.*  to  null

 let int_flag = false
 initialize d_ctc34m01.*   to null

 if param.socvclcod  is null   then
    let param.socvclcod = 0
 end if

 select min(datkveiculo.socvclcod)
   into d_ctc34m01.socvclcod
   from datkveiculo
  where datkveiculo.socvclcod  >  param.socvclcod

 if d_ctc34m01.socvclcod  is not null   then

    call ctc34m01_ler(d_ctc34m01.socvclcod)
         returning d_ctc34m01.*

    if d_ctc34m01.socvclcod  is not null   then
       let atdvclsglS = d_ctc34m01.atdvclsgl
       display by name atdvclsglS
       display by name d_ctc34m01.*
    else
       error " Nao ha' veiculo nesta direcao!"
       initialize d_ctc34m01.*    to null
    end if
 else
    error " Nao ha' veiculo nesta direcao!"
    initialize d_ctc34m01.*    to null
 end if

 return d_ctc34m01.*

 end function    # ctc34m01_proximo


#------------------------------------------------------------
 function ctc34m01_anterior(param)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkveiculo.socvclcod
 end record

 define d_ctc34m01    record
   socvclcod          like datkveiculo.socvclcod,
   pstcoddig          like datkveiculo.pstcoddig,
   nomgrr             like dpaksocor.nomgrr,
   vclctfnom          like datkveiculo.vclctfnom,
   socoprsitcod       like datkveiculo.socoprsitcod,
   socoprsitdes       char (09),
   vclaqstipcod       like datkveiculo.vclaqstipcod,
   aqsdes             like iddkdominio.cpodes,
   vclaqsnom          like datkveiculo.vclaqsnom,
   vclcoddig          like datkveiculo.vclcoddig,
   vcldes             char (58),
   socvcltip          like datkveiculo.socvcltip,
   socvcldes          like iddkdominio.cpodes,
   chassi             char (20),
   vcllicnum          like datkveiculo.vcllicnum,
   vclanofbc          like datkveiculo.vclanofbc,
   vclanomdl          like datkveiculo.vclanomdl,
   vclcorcod          like datkveiculo.vclcorcod,
   vclcordes          char (20),
   vclpnttip          like datkveiculo.vclpnttip,
   vclpntdes          char (20),
   vclcmbcod          like datkveiculo.vclcmbcod,
   vclcmbdes          char (20),
   socctrposflg       like datkveiculo.socctrposflg,
   atdvclsgl          like datkveiculo.atdvclsgl,
   vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
   vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
   atdimpcod          like datkveiculo.atdimpcod,
   mdtcod             like datkveiculo.mdtcod,
   gpsacngrpcod       like dattfrotalocal.gpsacngrpcod,
   trxeqpsitdes       char (15),
   pgrnum             like datkveiculo.pgrnum,
   ustnom             like htlrust.ustnom,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd,
   socvstlclcod       like datkveiculo.socvstlclcod,
   socvstlclnom       like datkvstlcl.socvstlclnom,
   socvstlautipcod    like datkveiculo.socvstlautipcod,
   socvstlautipdes    like datkvstlautip.socvstlautipdes,
   caddat             like datkveiculo.caddat,
   cadfunnom          like isskfunc.funnom,
   atldat             like datkveiculo.atldat,
   funnom             like isskfunc.funnom,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum,
   nxtdddcod          like datkveiculo.nxtdddcod,
   nxtide             like datkveiculo.nxtide,
   nxtnum             like datkveiculo.nxtnum,
   frtrpnflg          like dpaksocor.frtrpnflg,
   frtrpndes          char(20),
   rencod             like datkveiculo.rencod,
   vclcadorgcod       like datkveiculo.vclcadorgcod,
   vclcadorgdes       like iddkdominio.cpodes 
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_ctc34m01.*  to  null
initialize atdvclsglS to null
 let int_flag = false
 initialize d_ctc34m01.*  to null

 if param.socvclcod  is null   then
    let param.socvclcod = 0
 end if

 select max(datkveiculo.socvclcod)
   into d_ctc34m01.socvclcod
   from datkveiculo
  where datkveiculo.socvclcod  <  param.socvclcod

 if d_ctc34m01.socvclcod  is not null   then

    call ctc34m01_ler(d_ctc34m01.socvclcod)
         returning d_ctc34m01.*

    if d_ctc34m01.socvclcod  is not null   then
       let atdvclsglS = d_ctc34m01.atdvclsgl
       display by name atdvclsglS
       display by name  d_ctc34m01.*
    else
       error " Nao ha' veiculo nesta direcao!"
       initialize d_ctc34m01.*    to null
    end if
 else
    error " Nao ha' veiculo nesta direcao!"
    initialize d_ctc34m01.*    to null
 end if

 return d_ctc34m01.*

 end function    # ctc34m01_anterior


#------------------------------------------------------------
 function ctc34m01_modifica(param, d_ctc34m01)
#------------------------------------------------------------

 define param         record
    socvclcod         like datkveiculo.socvclcod
 end record

 define d_ctc34m01    record
   socvclcod          like datkveiculo.socvclcod,
   pstcoddig          like datkveiculo.pstcoddig,
   nomgrr             like dpaksocor.nomgrr,
   vclctfnom          like datkveiculo.vclctfnom,
   socoprsitcod       like datkveiculo.socoprsitcod,
   socoprsitdes       char (09),
   vclaqstipcod       like datkveiculo.vclaqstipcod,
   aqsdes             like iddkdominio.cpodes,
   vclaqsnom          like datkveiculo.vclaqsnom,
   vclcoddig          like datkveiculo.vclcoddig,
   vcldes             char (58),
   socvcltip          like datkveiculo.socvcltip,
   socvcldes          like iddkdominio.cpodes,
   chassi             char (20),
   vcllicnum          like datkveiculo.vcllicnum,
   vclanofbc          like datkveiculo.vclanofbc,
   vclanomdl          like datkveiculo.vclanomdl,
   vclcorcod          like datkveiculo.vclcorcod,
   vclcordes          char (20),
   vclpnttip          like datkveiculo.vclpnttip,
   vclpntdes          char (20),
   vclcmbcod          like datkveiculo.vclcmbcod,
   vclcmbdes          char (20),
   socctrposflg       like datkveiculo.socctrposflg,
   atdvclsgl          like datkveiculo.atdvclsgl,
   vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
   vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
   atdimpcod          like datkveiculo.atdimpcod,
   mdtcod             like datkveiculo.mdtcod,
   gpsacngrpcod       like dattfrotalocal.gpsacngrpcod,
   trxeqpsitdes       char (15),
   pgrnum             like datkveiculo.pgrnum,
   ustnom             like htlrust.ustnom,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd,
   socvstlclcod       like datkveiculo.socvstlclcod,
   socvstlclnom       like datkvstlcl.socvstlclnom,
   socvstlautipcod    like datkveiculo.socvstlautipcod,
   socvstlautipdes    like datkvstlautip.socvstlautipdes,
   caddat             like datkveiculo.caddat,
   cadfunnom          like isskfunc.funnom,
   atldat             like datkveiculo.atldat,
   funnom             like isskfunc.funnom,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum,
   nxtdddcod          like datkveiculo.nxtdddcod,
   nxtide             like datkveiculo.nxtide,
   nxtnum             like datkveiculo.nxtnum,
   frtrpnflg          like dpaksocor.frtrpnflg,
   frtrpndes          char(20),
   rencod             like datkveiculo.rencod,
   vclcadorgcod       like datkveiculo.vclcadorgcod,
   vclcadorgdes       like iddkdominio.cpodes 
 end record

   define lr_ctc34m01 record
           pstcoddig         like datkveiculo.pstcoddig
          ,vclctfnom         like datkveiculo.vclctfnom
          ,socoprsitcod      like datkveiculo.socoprsitcod
          ,socoprsitdes      char (09)
          ,vclaqstipcod      like datkveiculo.vclaqstipcod
          ,vclaqsnom         like datkveiculo.vclaqsnom
          ,vclcoddig         like datkveiculo.vclcoddig
          ,celdddcod         like datkveiculo.celdddcod
          ,celtelnum         like datkveiculo.celtelnum
          ,nxtdddcod         like datkveiculo.nxtdddcod
          ,nxtide            like datkveiculo.nxtide
          ,nxtnum            like datkveiculo.nxtnum
          ,socvcltip         like datkveiculo.socvcltip
          ,chassi            char(20)
          ,vcllicnum         like datkveiculo.vcllicnum
          ,vclanofbc         like datkveiculo.vclanofbc
          ,vclanomdl         like datkveiculo.vclanomdl
          ,vclcorcod         like datkveiculo.vclcorcod
          ,vclpnttip         like datkveiculo.vclpnttip
          ,vclcmbcod         like datkveiculo.vclcmbcod
          ,socctrposflg      like datkveiculo.socctrposflg
          ,atdvclsgl         like datkveiculo.atdvclsgl
          ,vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
          ,atdimpcod         like datkveiculo.atdimpcod
          ,mdtcod            like datkveiculo.mdtcod
          ,gpsacngrpcod      like dattfrotalocal.gpsacngrpcod
          ,pgrnum            like datkveiculo.pgrnum
          ,socvstdiaqtd      like datkveiculo.socvstdiaqtd
          ,socvstlclcod      like datkveiculo.socvstlclcod
          ,socvstlautipcod   like datkveiculo.socvstlautipcod
          ,rencod            like datkveiculo.rencod
          ,vclcadorgcod      like datkveiculo.vclcadorgcod 
          ,vclcadorgdes      like iddkdominio.cpodes 
   end record

 define ws            record
   vclchsinc          like datkveiculo.vclchsinc,
   vclchsfnl          like datkveiculo.vclchsfnl
 end record

 define l_frtrpnflg   like datkveiculo.frtrpnflg
 define l_hora        datetime hour to minute
 define l_assunto     char(40)
 define l_flg         integer
 define l_mensmail    char(2000)
 define l_stt         smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize  ws.*  to  null

 initialize ws.*  to null
 initialize vst.* to null
 initialize lr_ctc34m01.* to null

 let vst.socvstdiaqtd = d_ctc34m01.socvstdiaqtd

 let lr_ctc34m01.pstcoddig       = d_ctc34m01.pstcoddig
 let lr_ctc34m01.vclctfnom       = d_ctc34m01.vclctfnom
 let lr_ctc34m01.socoprsitcod    = d_ctc34m01.socoprsitcod
 let lr_ctc34m01.socoprsitdes    = d_ctc34m01.socoprsitdes
 let lr_ctc34m01.vclaqstipcod    = d_ctc34m01.vclaqstipcod
 let lr_ctc34m01.vclaqsnom       = d_ctc34m01.vclaqsnom
 let lr_ctc34m01.vclcoddig       = d_ctc34m01.vclcoddig
 let lr_ctc34m01.celdddcod       = d_ctc34m01.celdddcod
 let lr_ctc34m01.celtelnum       = d_ctc34m01.celtelnum
 let lr_ctc34m01.nxtdddcod       = d_ctc34m01.nxtdddcod
 let lr_ctc34m01.nxtide          = d_ctc34m01.nxtide
 let lr_ctc34m01.nxtnum          = d_ctc34m01.nxtnum
 let lr_ctc34m01.socvcltip       = d_ctc34m01.socvcltip
 let lr_ctc34m01.chassi          = d_ctc34m01.chassi
 let lr_ctc34m01.vcllicnum       = d_ctc34m01.vcllicnum
 let lr_ctc34m01.vclanofbc       = d_ctc34m01.vclanofbc
 let lr_ctc34m01.vclanomdl       = d_ctc34m01.vclanomdl
 let lr_ctc34m01.vclcorcod       = d_ctc34m01.vclcorcod
 let lr_ctc34m01.vclpnttip       = d_ctc34m01.vclpnttip
 let lr_ctc34m01.vclcmbcod       = d_ctc34m01.vclcmbcod
 let lr_ctc34m01.socctrposflg    = d_ctc34m01.socctrposflg
 let lr_ctc34m01.atdvclsgl       = d_ctc34m01.atdvclsgl
 let lr_ctc34m01.vcldtbgrpcod    = d_ctc34m01.vcldtbgrpcod
 let lr_ctc34m01.atdimpcod       = d_ctc34m01.atdimpcod
 let lr_ctc34m01.mdtcod          = d_ctc34m01.mdtcod
 let lr_ctc34m01.gpsacngrpcod    = d_ctc34m01.gpsacngrpcod
 let lr_ctc34m01.pgrnum          = d_ctc34m01.pgrnum
 let lr_ctc34m01.socvstdiaqtd    = d_ctc34m01.socvstdiaqtd
 let lr_ctc34m01.socvstlclcod    = d_ctc34m01.socvstlclcod
 let lr_ctc34m01.socvstlautipcod = d_ctc34m01.socvstlautipcod
 let lr_ctc34m01.rencod          = d_ctc34m01.rencod      
 let lr_ctc34m01.vclcadorgcod    = d_ctc34m01.vclcadorgcod
 let lr_ctc34m01.vclcadorgdes    = d_ctc34m01.vclcadorgdes 
 

 call ctc34m01_input("a", d_ctc34m01.*) returning d_ctc34m01.*

 if int_flag  then
    let int_flag = false
    initialize atdvclsglS to null
          display by name atdvclsglS
    initialize d_ctc34m01.*  to null
    display by name d_ctc34m01.*
    error " Operacao cancelada!"
    return d_ctc34m01.*
 end if
 
  


 #------------------------------------------------------------
 # Divide em 2 campos (Chassi inicial/Chassi final)
 #------------------------------------------------------------
 let ws.vclchsinc      = d_ctc34m01.chassi[01,12]
 let ws.vclchsfnl      = d_ctc34m01.chassi[13,20]

 let d_ctc34m01.atldat = today

 #open cctc34m01004 using d_ctc34m01.pstcoddig
 #fetch cctc34m01004 into l_frtrpnflg

 whenever error continue

 begin work
    #-------------------------------------------------------------
    # Atualiza cadastro de veiculos
    #-------------------------------------------------------------
    
    call ctc30m00_remove_caracteres(d_ctc34m01.vclctfnom)
            returning d_ctc34m01.vclctfnom 
   
    call ctc30m00_remove_caracteres(d_ctc34m01.vclaqsnom)
            returning d_ctc34m01.vclaqsnom   
    
    update datkveiculo set  ( pstcoddig,
                              vclctfnom,
                              vclcoddig,
                              vclanofbc,
                              vclanomdl,
                              vcllicnum,
                              vclchsinc,
                              vclchsfnl,
                              vclcorcod,
                              vclpnttip,
                              vclcmbcod,
                              socctrposflg,
                              atdvclsgl,
                              atdimpcod,
                              mdtcod,
                              socvstdiaqtd,
                              socoprsitcod,
                              atldat,
                              atlemp,
                              atlmat,
                              vclaqstipcod,
                              vclaqsnom,
                              socvstlclcod,
                              socvstlautipcod,
                              pgrnum,
                              socvcltip,
                              celdddcod,
                              celtelnum,
                              nxtdddcod,
                              nxtide,
                              nxtnum,
                              rencod,
                              vclcadorgcod)
                            #  frtrpnflg)

                        =  ( d_ctc34m01.pstcoddig,
                             d_ctc34m01.vclctfnom,
                             d_ctc34m01.vclcoddig,
                             d_ctc34m01.vclanofbc,
                             d_ctc34m01.vclanomdl,
                             d_ctc34m01.vcllicnum,
                             ws.vclchsinc,
                             ws.vclchsfnl,
                             d_ctc34m01.vclcorcod,
                             d_ctc34m01.vclpnttip,
                             d_ctc34m01.vclcmbcod,
                             d_ctc34m01.socctrposflg,
                             d_ctc34m01.atdvclsgl,
                             d_ctc34m01.atdimpcod,
                             d_ctc34m01.mdtcod,
                             d_ctc34m01.socvstdiaqtd,
                             d_ctc34m01.socoprsitcod,
                             d_ctc34m01.atldat,
                             g_issk.empcod,
                             g_issk.funmat,
                             d_ctc34m01.vclaqstipcod,
                             d_ctc34m01.vclaqsnom,
                             d_ctc34m01.socvstlclcod,
                             d_ctc34m01.socvstlautipcod,
                             d_ctc34m01.pgrnum,
                             d_ctc34m01.socvcltip,
                             d_ctc34m01.celdddcod,
                             d_ctc34m01.celtelnum,
                             d_ctc34m01.nxtdddcod,
                             d_ctc34m01.nxtide,
                             d_ctc34m01.nxtnum,
                             d_ctc34m01.rencod,
                             d_ctc34m01.vclcadorgcod)
                             #l_frtrpnflg)

           where datkveiculo.socvclcod  =  d_ctc34m01.socvclcod

    if sqlca.sqlcode <>  0  then
       error " Erro (",sqlca.sqlcode,") na alteracao do veiculo!"
       rollback work
       initialize d_ctc34m01.*   to null
       return d_ctc34m01.*
    end if

    #-------------------------------------------------------------
    # grava posicao da frota
    #-------------------------------------------------------------
    if not ctc34m01_gravapos(d_ctc34m01.socvclcod,
                             d_ctc34m01.socctrposflg,
                             d_ctc34m01.vcldtbgrpcod,
                             d_ctc34m01.gpsacngrpcod,
                             "a")   then
       initialize d_ctc34m01.*   to null
       return d_ctc34m01.*
    end if

    #-------------------------------------------------------------
    # grava nova data vistoria
    #-------------------------------------------------------------
    if d_ctc34m01.socvstdiaqtd is not null and
       d_ctc34m01.socvstdiaqtd <> vst.socvstdiaqtd then
       if vst.ok = "S" then
          update datmsocvst set (socvstdat,
                                 socvstorgdat)
                              = (vst.socvstdat_new,
                                 vst.socvstdat_new)
              where socvstnum =  vst.socvstnum

          if sqlca.sqlcode <>  0  then
             error " Erro (",sqlca.sqlcode,") na alteracao da vistoria!"
             rollback work
             initialize d_ctc34m01.*   to null
             return d_ctc34m01.*
          end if
       end if
    end if

    error " Alteracao efetuada com sucesso!"

 commit work

 whenever error stop
 
  # 15/09/2010 PSI201000009EV Beatriz - obrigar cadastro de seguro
#call ctc34m03_obrigaseg(d_ctc34m01.socvclcod,
#                       d_ctc34m01.atdvclsgl,
#                       d_ctc34m01.vcldes,
#                       d_ctc34m01.socvcltip) 


 call ctc34m01_verifica_mod(lr_ctc34m01.*
                             ,d_ctc34m01.*)

 initialize atdvclsglS to null
          display by name atdvclsglS
 initialize d_ctc34m01.*  to null
 display by name d_ctc34m01.*
 message ""
 return d_ctc34m01.*

 end function   #  ctc34m01_modifica


#------------------------------------------------------------
 function ctc34m01_inclui()
#------------------------------------------------------------

 define d_ctc34m01    record
   socvclcod          like datkveiculo.socvclcod,
   pstcoddig          like datkveiculo.pstcoddig,
   nomgrr             like dpaksocor.nomgrr,
   vclctfnom          like datkveiculo.vclctfnom,
   socoprsitcod       like datkveiculo.socoprsitcod,
   socoprsitdes       char (09),
   vclaqstipcod       like datkveiculo.vclaqstipcod,
   aqsdes             like iddkdominio.cpodes,
   vclaqsnom          like datkveiculo.vclaqsnom,
   vclcoddig          like datkveiculo.vclcoddig,
   vcldes             char (58),
   socvcltip          like datkveiculo.socvcltip,
   socvcldes          like iddkdominio.cpodes,
   chassi             char (20),
   vcllicnum          like datkveiculo.vcllicnum,
   vclanofbc          like datkveiculo.vclanofbc,
   vclanomdl          like datkveiculo.vclanomdl,
   vclcorcod          like datkveiculo.vclcorcod,
   vclcordes          char (20),
   vclpnttip          like datkveiculo.vclpnttip,
   vclpntdes          char (20),
   vclcmbcod          like datkveiculo.vclcmbcod,
   vclcmbdes          char (20),
   socctrposflg       like datkveiculo.socctrposflg,
   atdvclsgl          like datkveiculo.atdvclsgl,
   vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
   vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
   atdimpcod          like datkveiculo.atdimpcod,
   mdtcod             like datkveiculo.mdtcod,
   gpsacngrpcod       like datkmdtctr.gpsacngrpcod,
   trxeqpsitdes       char (15),
   pgrnum             like datkveiculo.pgrnum,
   ustnom             like htlrust.ustnom,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd,
   socvstlclcod       like datkveiculo.socvstlclcod,
   socvstlclnom       like datkvstlcl.socvstlclnom,
   socvstlautipcod    like datkveiculo.socvstlautipcod,
   socvstlautipdes    like datkvstlautip.socvstlautipdes,
   caddat             like datkveiculo.caddat,
   cadfunnom          like isskfunc.funnom,
   atldat             like datkveiculo.atldat,
   funnom             like isskfunc.funnom,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum,
   nxtdddcod          like datkveiculo.nxtdddcod,
   nxtide             like datkveiculo.nxtide,
   nxtnum             like datkveiculo.nxtnum,
   frtrpnflg          like dpaksocor.frtrpnflg,
   frtrpndes          char(20),
   rencod             like datkveiculo.rencod,
   vclcadorgcod       like datkveiculo.vclcadorgcod,
   vclcadorgdes       like iddkdominio.cpodes 
 end record

 define ws            record
   vclchsinc          like datkveiculo.vclchsinc,
   vclchsfnl          like datkveiculo.vclchsfnl
 end record

 define  ws_resp       char(01),
         l_frtrpnflg   like datkveiculo.frtrpnflg
        ,l_mensagem    char(60)
        ,l_mensagem2   char(60)
        ,l_stt         smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     ws_resp  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_ctc34m01.*  to  null

        initialize  ws.*  to  null

 initialize d_ctc34m01.*   to null
 initialize ws.*           to null
   let l_mensagem  = null
   let l_mensagem2 = null
   let l_stt       = null

initialize atdvclsglS to null
          display by name atdvclsglS
 display by name d_ctc34m01.*

 call ctc34m01_input("i", d_ctc34m01.*) returning d_ctc34m01.*

 if int_flag  then
    let int_flag = false
    initialize d_ctc34m01.*  to null
    display by name d_ctc34m01.*
    error " Operacao cancelada!"
    return
 end if

 #------------------------------------------------------------
 # Divide em 2 campos (Chassi inicial/Chassi final)
 #------------------------------------------------------------
 let ws.vclchsinc      = d_ctc34m01.chassi[01,12]
 let ws.vclchsfnl      = d_ctc34m01.chassi[13,20]

 let d_ctc34m01.atldat = today
 let d_ctc34m01.caddat = today


 declare cctc34m01001  cursor with hold  for
         select  max(socvclcod)
           from  datkveiculo
          where  datkveiculo.socvclcod > 0

 foreach cctc34m01001  into  d_ctc34m01.socvclcod
     exit foreach
 end foreach
 close cctc34m01001 

 if d_ctc34m01.socvclcod is null   then
    let d_ctc34m01.socvclcod = 0
 end if
 let d_ctc34m01.socvclcod = d_ctc34m01.socvclcod + 1

 open cctc34m01004 using d_ctc34m01.pstcoddig
 fetch cctc34m01004 into l_frtrpnflg
 close cctc34m01004

 whenever error continue

 begin work
   #-------------------------------------------------------------
   # Grava o veiculo no cadastro
   #-------------------------------------------------------------
   call ctc30m00_remove_caracteres(d_ctc34m01.vclctfnom)
            returning d_ctc34m01.vclctfnom 
   
   call ctc30m00_remove_caracteres(d_ctc34m01.vclaqsnom)
            returning d_ctc34m01.vclaqsnom            
    
   
    
    insert into datkveiculo ( socvclcod,
                              pstcoddig,
                              vclctfnom,
                              vclcoddig,
                              vclanofbc,
                              vclanomdl,
                              vcllicnum,
                              vclchsinc,
                              vclchsfnl,
                              vclcorcod,
                              vclpnttip,
                              vclcmbcod,
                              socctrposflg,
                              atdvclsgl,
                              atdimpcod,
                              mdtcod,
                              socvstdiaqtd,
                              socoprsitcod,
                              caddat,
                              cademp,
                              cadmat,
                              atldat,
                              atlemp,
                              atlmat,
                              vclaqstipcod,
                              vclaqsnom,
                              socvstlclcod,
                              socvstlautipcod,
                              socacsflg,
                              pgrnum,
                              socvcltip,
                              celdddcod,
                              celtelnum,
                              nxtdddcod,
                              nxtide,
                              nxtnum,
                              rencod,
                              vclcadorgcod)
                              #frtrpnflg)
                  values
                            ( d_ctc34m01.socvclcod,
                              d_ctc34m01.pstcoddig,
                              d_ctc34m01.vclctfnom,
                              d_ctc34m01.vclcoddig,
                              d_ctc34m01.vclanofbc,
                              d_ctc34m01.vclanomdl,
                              d_ctc34m01.vcllicnum,
                              ws.vclchsinc,
                              ws.vclchsfnl,
                              d_ctc34m01.vclcorcod,
                              d_ctc34m01.vclpnttip,
                              d_ctc34m01.vclcmbcod,
                              d_ctc34m01.socctrposflg,
                              d_ctc34m01.atdvclsgl,
                              d_ctc34m01.atdimpcod,
                              d_ctc34m01.mdtcod,
                              d_ctc34m01.socvstdiaqtd,
                              d_ctc34m01.socoprsitcod,
                              d_ctc34m01.caddat,
                              g_issk.empcod,
                              g_issk.funmat,
                              d_ctc34m01.atldat,
                              g_issk.empcod,
                              g_issk.funmat,
                              d_ctc34m01.vclaqstipcod,
                              d_ctc34m01.vclaqsnom,
                              d_ctc34m01.socvstlclcod,
                              d_ctc34m01.socvstlautipcod,
                              "0",
                              d_ctc34m01.pgrnum,
                              d_ctc34m01.socvcltip,
                              d_ctc34m01.celdddcod,
                              d_ctc34m01.celtelnum,
                              d_ctc34m01.nxtdddcod,
                              d_ctc34m01.nxtide,
                              d_ctc34m01.nxtnum,
                              d_ctc34m01.rencod,
                              d_ctc34m01.vclcadorgcod)
                              #l_frtrpnflg)

    if sqlca.sqlcode <>  0   then
       error " Erro (",sqlca.sqlcode,") na Inclusao do veiculo!"
       rollback work
       return
    end if

    call ctc34m01_empresa(d_ctc34m01.socvclcod)

    #-------------------------------------------------------------
    # Se tiver posicao controlada, grava posicao da frota
    #-------------------------------------------------------------
    if not ctc34m01_gravapos (d_ctc34m01.socvclcod,
                              d_ctc34m01.socctrposflg,
                              d_ctc34m01.vcldtbgrpcod,
                              d_ctc34m01.gpsacngrpcod,
                              "i")   then
       return
    end if

 commit work

 whenever error stop

  # 15/09/2010 PSI201000009EV Beatriz - obrigar cadastro de seguro
#call ctc34m03_obrigaseg(d_ctc34m01.socvclcod,
#                       d_ctc34m01.atdvclsgl,
#                       d_ctc34m01.vcldes,
#                       d_ctc34m01.socvcltip) 


 let l_mensagem  = "Veiculo [",d_ctc34m01.socvclcod,"] incluido "
 let l_mensagem2 = 'Inclusao no cadastro do Veiculo. Codigo : ',
		     d_ctc34m01.socvclcod

 let l_stt = ctc34m01_grava_hist(d_ctc34m01.socvclcod
                                 ,l_mensagem
                                 ,today
                                 ,l_mensagem2,"I")

 call ctc34m01_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m01.cadfunnom

 call ctc34m01_func(g_issk.empcod, g_issk.funmat)
      returning d_ctc34m01.funnom
 
 let atdvclsglS = d_ctc34m01.atdvclsgl
 display by name atdvclsglS           
 display by name  d_ctc34m01.*

 display by name d_ctc34m01.socvclcod attribute (reverse)
 error " Inclusao efetuada com sucesso, tecle ENTER!"
 prompt "" for char ws_resp

 initialize atdvclsglS to null
          display by name atdvclsglS
 initialize d_ctc34m01.*  to null
 display by name d_ctc34m01.*

 end function   #  ctc34m01_inclui


#--------------------------------------------------------------------
 function ctc34m01_input(param, d_ctc34m01)
#--------------------------------------------------------------------

 define param         record
    operacao          char (1)
 end record

 define d_ctc34m01    record
   socvclcod          like datkveiculo.socvclcod,
   pstcoddig          like datkveiculo.pstcoddig,
   nomgrr             like dpaksocor.nomgrr,
   vclctfnom          like datkveiculo.vclctfnom,
   socoprsitcod       like datkveiculo.socoprsitcod,
   socoprsitdes       char (09),
   vclaqstipcod       like datkveiculo.vclaqstipcod,
   aqsdes             like iddkdominio.cpodes,
   vclaqsnom          like datkveiculo.vclaqsnom,
   vclcoddig          like datkveiculo.vclcoddig,
   vcldes             char (58),
   socvcltip          like datkveiculo.socvcltip,
   socvcldes          like iddkdominio.cpodes,
   chassi             char (20),
   vcllicnum          like datkveiculo.vcllicnum,
   vclanofbc          like datkveiculo.vclanofbc,
   vclanomdl          like datkveiculo.vclanomdl,
   vclcorcod          like datkveiculo.vclcorcod,
   vclcordes          char (20),
   vclpnttip          like datkveiculo.vclpnttip,
   vclpntdes          char (20),
   vclcmbcod          like datkveiculo.vclcmbcod,
   vclcmbdes          char (20),
   socctrposflg       like datkveiculo.socctrposflg,
   atdvclsgl          like datkveiculo.atdvclsgl,
   vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
   vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
   atdimpcod          like datkveiculo.atdimpcod,
   mdtcod             like datkveiculo.mdtcod,
   gpsacngrpcod       like datkmdtctr.gpsacngrpcod,
   trxeqpsitdes       char (15),
   pgrnum             like datkveiculo.pgrnum,
   ustnom             like htlrust.ustnom,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd,
   socvstlclcod       like datkveiculo.socvstlclcod,
   socvstlclnom       like datkvstlcl.socvstlclnom,
   socvstlautipcod    like datkveiculo.socvstlautipcod,
   socvstlautipdes    like datkvstlautip.socvstlautipdes,
   caddat             like datkveiculo.caddat,
   cadfunnom          like isskfunc.funnom,
   atldat             like datkveiculo.atldat,
   funnom             like isskfunc.funnom,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum,
   nxtdddcod          like datkveiculo.nxtdddcod,
   nxtide             like datkveiculo.nxtide,
   nxtnum             like datkveiculo.nxtnum,
   frtrpnflg          like dpaksocor.frtrpnflg,
   frtrpndes          char(20),
   rencod             like datkveiculo.rencod,
   vclcadorgcod       like datkveiculo.vclcadorgcod,
   vclcadorgdes       like iddkdominio.cpodes 
 end record

 define ws            record
   pestip             like dpaksocor.pestip,
   cgccpfnum          like dpaksocor.cgccpfnum,
   cgcord             like dpaksocor.cgcord,
   cgccpfdig          like dpaksocor.cgccpfdig,
   prssitcod          like dpaksocor.prssitcod,
   atdimpsit          like datktrximp.atdimpsit,
   mdtstt             like datkmdt.mdtstt,
   socvclcod          like datkveiculo.socvclcod,
   socctrposflgsva    like datkveiculo.socctrposflg,
   pstcoddigsva       like datkveiculo.pstcoddig,
   atdvclsglsva       like datkveiculo.atdvclsgl,
   socvstlclsit       like datkvstlcl.socvstlclsit,
   socvstlautipsit    like datkvstlautip.socvstlautipsit,
   contpos            integer,
   contpos2           integer,
   confirma           char (01),
   ustsit             like htlrust.ustsit,
   gutcod             like htlrust.gutcod,
   erro               smallint,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum    
 end record

 define
   vl_sql             char(500)
  ,vl_result          smallint
  ,l_socvclcod        like datkveiculo.socvclcod
  ,l_msg              char(55)
  ,l_aux              like iddkdominio.cpodes
  ,l_frtrpnflg        like datkveiculo.frtrpnflg
  ,l_sql              char(300)
  ,l_erro             char(200)
  ,l_cont             smallint
  
define ctc34m01_depatl record
   depatlflg          like iddkdominio.cponom,
   depatldes          like iddkdominio.cpodes
end record
 
define lr_retorno     record
       erro    smallint,
       cpocod  integer ,
       cpodes  char(50)
end record 
 
 
 define obrseguro smallint # verificar se eh obrigatorio a invlusao de um seguro
 
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     vl_sql  =  null
        let     vl_result  =  null
        let l_socvclcod = null
        let l_msg = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 let int_flag = false
 initialize ws.*   to null
 initialize vl_sql to null

 let obrseguro = false
 let ws.socctrposflgsva  =  d_ctc34m01.socctrposflg
 let ws.pstcoddigsva     =  d_ctc34m01.pstcoddig
 let ws.atdvclsglsva     =  d_ctc34m01.atdvclsgl
 let ctc34m01_depatl.depatlflg = 'ctc34m01_depatl'

 input by name d_ctc34m01.pstcoddig,
               d_ctc34m01.vclctfnom,
               d_ctc34m01.socoprsitcod,
               d_ctc34m01.vclaqstipcod,
               d_ctc34m01.vclaqsnom,
               d_ctc34m01.vclcoddig,
               d_ctc34m01.rencod,
               d_ctc34m01.vclcadorgcod,
               d_ctc34m01.celdddcod,
               d_ctc34m01.celtelnum,
               d_ctc34m01.nxtdddcod,
               d_ctc34m01.nxtide,
               d_ctc34m01.nxtnum,
               d_ctc34m01.socvcltip,
               d_ctc34m01.chassi,
               d_ctc34m01.vcllicnum,
               d_ctc34m01.vclanofbc,
               d_ctc34m01.vclanomdl,
               d_ctc34m01.vclcorcod,
               d_ctc34m01.vclpnttip,
               d_ctc34m01.vclcmbcod,
               d_ctc34m01.socctrposflg,
               d_ctc34m01.atdvclsgl,
               d_ctc34m01.vcldtbgrpcod,
               d_ctc34m01.atdimpcod,
               d_ctc34m01.mdtcod,
               d_ctc34m01.gpsacngrpcod,
               d_ctc34m01.pgrnum,
               d_ctc34m01.socvstdiaqtd,
               d_ctc34m01.socvstlclcod,
               d_ctc34m01.socvstlautipcod without defaults

    before input
           let l_frtrpnflg  = d_ctc34m01.frtrpnflg       
           
           let ws.celdddcod = d_ctc34m01.celdddcod
           let ws.celtelnum = d_ctc34m01.celtelnum

    before field pstcoddig
           display by name d_ctc34m01.pstcoddig attribute (reverse)

    after  field pstcoddig
           display by name d_ctc34m01.pstcoddig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  pstcoddig
           end if

           if d_ctc34m01.pstcoddig  is null   then
              error " Codigo do prestador deve ser informado!"
              next field pstcoddig
           end if

           if ws.pstcoddigsva       is not null           and
              d_ctc34m01.pstcoddig  <>  ws.pstcoddigsva   then
              call cts08g01("C","S",
                                "ATENCAO",
                                "O CODIGO DO PRESTADOR SERA MODIFICADO !!!",
                                "", "CONFIRMA ?")
                   returning ws.confirma

              if ws.confirma  =  "N"   then
                 let d_ctc34m01.pstcoddig = ws.pstcoddigsva
                 next field pstcoddig
              end if
           end if

           select prssitcod, nomgrr
             into ws.prssitcod, d_ctc34m01.nomgrr
             from dpaksocor
            where dpaksocor.pstcoddig = d_ctc34m01.pstcoddig

           if sqlca.sqlcode  <>  0   then
              error " Prestador nao cadastrado!"
              call ctb12m02("")  returning  d_ctc34m01.pstcoddig,
                                            ws.pestip,
                                            ws.cgccpfnum,
                                            ws.cgcord,
                                            ws.cgccpfdig
              next field pstcoddig
           end if
           display by name d_ctc34m01.nomgrr

           if ws.prssitcod   <>  "A"   then
              case ws.prssitcod
                 when "C"  error " Prestador cancelado!"
                 when "P"  error " Prestador em proposta!"
                 when "B"  error " Prestador bloqueado!"
              end case
              next field pstcoddig
           end if

    before field vclctfnom
           display by name d_ctc34m01.vclctfnom attribute (reverse)

    after  field vclctfnom
           display by name d_ctc34m01.vclctfnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  pstcoddig
           end if

           if d_ctc34m01.vclctfnom  is null   then
              error " Nome do proprietario deve ser informado!"
              next field vclctfnom
           end if

    before field socoprsitcod
           if param.operacao  =  "i"   then
              let d_ctc34m01.socoprsitcod  =  1  #--> Ativo

              #PSI 222020 - Burini
              let l_aux = "socoprsitcod"
              open cctc34m01003 using l_aux,
                                      d_ctc34m01.socoprsitcod
              fetch cctc34m01003 into d_ctc34m01.socoprsitdes
              if sqlca.sqlcode  <>  0   then
                 error " Codigo da situacao nao encontrado, AVISE INFORMATICA!"
                 next field vclctfnom
              end if
	      close cctc34m01003
           end if
           display by name d_ctc34m01.socoprsitcod
           display by name d_ctc34m01.socoprsitdes
           next field vclaqstipcod

    after  field socoprsitcod
           display by name d_ctc34m01.socoprsitcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vclctfnom
           end if

    before field vclaqstipcod
           display by name d_ctc34m01.vclaqstipcod attribute (reverse)

    after  field vclaqstipcod
           display by name d_ctc34m01.vclaqstipcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vclctfnom
           end if

           if d_ctc34m01.vclaqstipcod  is null   then
              error " Codigo de aquisicao deve ser informado!"
              next field vclaqstipcod
           end if

           initialize d_ctc34m01.aqsdes to null

           #PSI 222020 - Burini
           let l_aux = "vclaqstipcod"
           open cctc34m01003 using l_aux,
                                   d_ctc34m01.vclaqstipcod
           fetch cctc34m01003 into d_ctc34m01.aqsdes

           if sqlca.sqlcode  <>  0   then
              error " Codigo da aquisicao nao encontrado!"
              next field vclaqstipcod
           end if
           close cctc34m01003
           display by name d_ctc34m01.aqsdes

           if d_ctc34m01.aqsdes[1,7] = "PROPRIO" then
              initialize d_ctc34m01.vclaqsnom to null
              display by name d_ctc34m01.vclaqsnom
              next field vclcoddig
           end if

    before field vclaqsnom
           display by name d_ctc34m01.vclaqsnom attribute (reverse)

    after  field vclaqsnom
           display by name d_ctc34m01.vclaqsnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field vclaqstipcod
           end if

           if d_ctc34m01.vclaqsnom  is null   then
              error " Nome aquisicao deve ser informado!"
              next field vclaqsnom
           end if

    before field vclcoddig
           display by name d_ctc34m01.vclcoddig attribute (reverse)

    after  field vclcoddig
           display by name d_ctc34m01.vclcoddig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_ctc34m01.aqsdes[1,7] = "PROPRIO" then
                 next field vclaqstipcod
              end if
              next field  vclaqsnom
           end if

           #-------------------------------------------------------
           # Consiste/pesquisa codigo do veiculo
           #-------------------------------------------------------
           if d_ctc34m01.vclcoddig  is not null   then
              select vclcoddig
                from agbkveic
               where agbkveic.vclcoddig  =  d_ctc34m01.vclcoddig

              if sqlca.sqlcode  <>  0   then
                 error " Veiculo nao cadastrado!"
                 call agguvcl()  returning  d_ctc34m01.vclcoddig
                 next field vclcoddig
              else
                 call cts15g00(d_ctc34m01.vclcoddig) returning d_ctc34m01.vcldes
              end if
           else
              error " Codigo para descricao do veiculo deve ser informado!"
              call agguvcl()  returning d_ctc34m01.vclcoddig
              next field vclcoddig
           end if
           display by name d_ctc34m01.vcldes
########################################################################################
    before field rencod
          display by name d_ctc34m01.rencod attribute(reverse)
    
    after field rencod 
           display by name d_ctc34m01.rencod   
           
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vclcoddig
           end if 
           
           if d_ctc34m01.rencod   is null   then
              error " Renavam deve ser informado!"
              next field rencod 
           end if
           
     before field vclcadorgcod
          display by name d_ctc34m01.vclcadorgcod attribute(reverse)
    
    after field vclcadorgcod 
           display by name d_ctc34m01.vclcadorgcod   
           
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  rencod
           end if 
           
          initialize lr_retorno.* to null
          initialize m_dominio.* to null
         
         if d_ctc34m01.vclcadorgcod is null
            then
            error " Informe a origem de aquisicao do veiculo "
            call cty09g00_popup_iddkdominio("ctc34m03_orgcadvcl")
                 returning lr_retorno.erro, d_ctc34m01.vclcadorgcod,
                           d_ctc34m01.vclcadorgdes
         else
            call cty11g00_iddkdominio('ctc34m03_orgcadvcl', d_ctc34m01.vclcadorgcod)
                 returning m_dominio.*
                 
            if m_dominio.erro != 1
               then
               if m_dominio.cpodes is null
                  then
                  error 'Origem do cadastro não encontrada '
               else
                  error m_dominio.mensagem
               end if
               initialize d_ctc34m01.vclcadorgdes to null
               display by name d_ctc34m01.vclcadorgdes
               
               call cty09g00_popup_iddkdominio("ctc34m03_orgcadvcl")
                    returning lr_retorno.erro, d_ctc34m01.vclcadorgcod,
                              d_ctc34m01.vclcadorgdes
            else
               let d_ctc34m01.vclcadorgdes = m_dominio.cpodes
            end if
         end if
         
         if d_ctc34m01.vclcadorgcod is null then
            next field vclcadorgcod
         end if
         
         display by name d_ctc34m01.vclcadorgcod, d_ctc34m01.vclcadorgdes   
                                                          
######################################################################################             
    before field celdddcod

       display by name d_ctc34m01.celdddcod attribute(reverse)

    after field celdddcod
       display by name d_ctc34m01.celdddcod
       
       if  (d_ctc34m01.celdddcod <> ws.celdddcod) or 
           (ws.celdddcod is null and d_ctc34m01.celdddcod is not null) or
           (ws.celdddcod is not null and d_ctc34m01.celdddcod is null) then 
          #30/08/2010 PAS103306-Beatriz
          whenever error continue 
           open cctc34m01009 using ctc34m01_depatl.depatlflg,
                                   g_issk.dptsgl
           fetch cctc34m01009 into ctc34m01_depatl.depatldes      
           if sqlca.sqlcode = notfound then
              error "Somente usuarios dos Departamentos cadastrados podem alterar essa informacao."
              let d_ctc34m01.celdddcod = ws.celdddcod   
                                                        
              display by name d_ctc34m01.celdddcod      
              next field celdddcod  
           end if
           close cctc34m01009
          whenever error stop 
                   
           #if  g_issk.dptsgl <> "psocor" then
           #    error "Somente usuarios do Porto Socorro podem alterar essa informacao."
           #    
           #    let d_ctc34m01.celdddcod = ws.celdddcod
           #    
           #    display by name d_ctc34m01.celdddcod
           #    next field celdddcod
           #    
           #end if
       end if        
       
       if fgl_lastkey() = fgl_keyval ("up")   or
          fgl_lastkey() = fgl_keyval ("left") then
          next field vclcoddig
       end if

    before field celtelnum

       display by name d_ctc34m01.celtelnum attribute(reverse)

    after field celtelnum
       display by name d_ctc34m01.celtelnum  

       if  (d_ctc34m01.celtelnum <> ws.celtelnum) or 
           (ws.celtelnum is null and d_ctc34m01.celtelnum is not null) or
           (ws.celtelnum is not null and d_ctc34m01.celtelnum is null) then           
            #30/08/2010 PAS103306-Beatriz
           whenever error continue 
           open cctc34m01009 using ctc34m01_depatl.depatlflg,
                                   g_issk.dptsgl
           fetch cctc34m01009 into ctc34m01_depatl.depatldes      
           
           if sqlca.sqlcode = notfound then
              error "Somente usuarios dos Departamentos cadastrados podem alterar essa informacao."
              let d_ctc34m01.celdddcod = ws.celdddcod   
                                                        
              display by name d_ctc34m01.celdddcod      
              next field celdddcod  
           end if
            close cctc34m01009
          whenever error stop 
           ##display "g_issk.dptsgl = ", g_issk.dptsgl
           #if  g_issk.dptsgl <> "psocor" then
           #    error "Somente usuarios do Porto Socorro podem alterar essa informacao."
           #    
           #    let d_ctc34m01.celtelnum = ws.celtelnum
           #    
           #    display by name d_ctc34m01.celtelnum
           #    next field celtelnum
           #    
           #end if
       end if       
       
       if fgl_lastkey() = fgl_keyval ("up")   or
          fgl_lastkey() = fgl_keyval ("left") then
          next field celdddcod
       end if

       # -> VERIFICA SE O CELULAR JA ESTA CADASTRADO PARA OUTRO VEICULO
       let l_socvclcod = ctc34m01_pesq_cel_veic(d_ctc34m01.celdddcod,
                                                d_ctc34m01.celtelnum,
                                                d_ctc34m01.socvclcod)

       if l_socvclcod is not null then
          let l_msg = "Este celular ja esta cadastrado para o veiculo: ",
                       l_socvclcod using "<<<&"
          error l_msg
          next field celtelnum
       end if

    before field socvcltip
           display by name d_ctc34m01.socvcltip attribute (reverse)

    after  field socvcltip
           display by name d_ctc34m01.socvcltip
           if fgl_lastkey() = fgl_keyval ("up")   or
              fgl_lastkey() = fgl_keyval ("left") then
              next field nxtnum
           end if

           if d_ctc34m01.socvcltip is null or
              d_ctc34m01.socvcltip  = " "  then
              let vl_sql = " select cpocod, cpodes from iddkdominio "
                          ," where cponom = 'socvcltip' "

              call ofgrc001_popup ( 8
                                   ,12
                                   ,"CONSULTA TIPO VEICULO"
                                   ,"Codigo"
                                   ,"Descricao"
                                   ,"N"
                                   ,vl_sql
                                   ,""
                                   ,"D" )
                   returning vl_result
                            ,d_ctc34m01.socvcltip
                            ,d_ctc34m01.socvcldes

              if vl_result = 1 then
                 error "Nenhum Tipo Equipamento Selecionado!"
                 next field socvcltip
              end if
           else
              #PSI 222020 - Burini
              let l_aux = "socvcltip"
              open cctc34m01003 using l_aux,
                                      d_ctc34m01.socvcltip
              fetch cctc34m01003 into d_ctc34m01.socvcldes

              if sqlca.sqlcode = notfound then
                 error "Tipo de Equipamento nao encontrado!"
                 next field socvcltip
              end if
	      close cctc34m01003
           end if
         
           display by name d_ctc34m01.socvcltip
           display by name d_ctc34m01.socvcldes

    before field chassi
           display by name d_ctc34m01.chassi    attribute (reverse)

    after  field chassi
           display by name d_ctc34m01.chassi

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socvcltip
           end if

           if d_ctc34m01.chassi  is null   then
              error " Numero do chassi deve ser informado!"
              next field chassi
           end if

           let ws.contpos = 20 - length(d_ctc34m01.chassi)

           if ws.contpos  >  12  then
              error " Nao deve ser cadastrado chassi c/ menos de 8 caracteres!"
              next field chassi
           end if

           #-------------------------------------------------------------
           # Alinha numero do chassi a direita
           #-------------------------------------------------------------
           if ws.contpos  >  0   then
              for ws.contpos2 = 1 to ws.contpos
                  let d_ctc34m01.chassi = " ", d_ctc34m01.chassi clipped
              end for
           end if
           display by name d_ctc34m01.chassi

    before field vcllicnum
           display by name d_ctc34m01.vcllicnum attribute (reverse)

    after  field vcllicnum
           display by name d_ctc34m01.vcllicnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field chassi
           end if

           if d_ctc34m01.vcllicnum  is not null   then
              if not srp1415(d_ctc34m01.vcllicnum)  then
                 error " Placa invalida!"
                 next field vcllicnum
              end if

              #----------------------------------------------------
              # Verifica placa ja cadastrada em outro veiculo
              #----------------------------------------------------
              initialize ws.socvclcod  to null
              select max(socvclcod)
                into ws.socvclcod
                from datkveiculo
               where datkveiculo.vcllicnum  =  d_ctc34m01.vcllicnum

              if ws.socvclcod  is not null   then
                 if param.operacao  =  "i"   then
                    error " Placa ja' cadastrada em outro veiculo! --> ",
                          ws.socvclcod
                    call cts08g01("A","N",
                                  "                                        ",
                                  "  PLACA JA CADASTRADA EM OUTRO VEICULO  ",
                                  "                                        ",
                                  "                                        ")
                      returning ws.confirma
                 else
                    if d_ctc34m01.socvclcod  <>  ws.socvclcod   then
                       error " Placa ja' cadastrada em outro veiculo! --> ",
                             ws.socvclcod
                       call cts08g01("A","N",
                                  "                                        ",
                                  "  PLACA JA CADASTRADA EM OUTRO VEICULO  ",
                                  "                                        ",
                                  "                                        ")
                            returning ws.confirma
                    end if
                 end if
              end if

              #-----------------------------------------------------------
              # Verifica bloqueio da placa na Emissao Auto
              #-----------------------------------------------------------
              #if tem_bloqueio_placa (31,"","","","",d_ctc34m01.vcllicnum)  then
              #   error " Placa ", d_ctc34m01.vcllicnum clipped,
              #         " bloqueada na Emissao Auto!"
              #   next field vcllicnum
              #end if

           end if

    before field vclanofbc
           display by name d_ctc34m01.vclanofbc attribute (reverse)

    after  field vclanofbc
           display by name d_ctc34m01.vclanofbc

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field vcllicnum
           end if

           if d_ctc34m01.vclanofbc  is null   then
              error " Ano de fabricacao do veiculo deve ser informado!"
              next field vclanofbc
           end if

           if d_ctc34m01.vclanofbc  <  "1970"   then
              error " Ano de fabricacao nao deve ser anterior a 1970!"
              next field vclanofbc
           end if

           if d_ctc34m01.vclanofbc  >  current year to year  then
              error " Ano de fabricacao nao deve ser superior ao ano atual!"
              next field vclanofbc
           end if

    before field vclanomdl
           display by name d_ctc34m01.vclanomdl attribute (reverse)

    after  field vclanomdl
           display by name d_ctc34m01.vclanomdl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vclanofbc
           end if

           if d_ctc34m01.vclanomdl  is null   then
              error " Ano modelo do veiculo deve ser informado!"
              next field vclanomdl
           end if

           if d_ctc34m01.vclanomdl  <  d_ctc34m01.vclanofbc   then
              error " Ano modelo nao deve ser anterior ao ano de fabricacao!"
              next field vclanomdl
           end if

           if cts15g01(d_ctc34m01.vclcoddig, d_ctc34m01.vclanomdl) = false  then
              error " Veiculo nao consta como fabricado em ", d_ctc34m01.vclanomdl, "!"
              next field vclanomdl
           end if

    before field vclcorcod
           display by name d_ctc34m01.vclcorcod attribute (reverse)

    after  field vclcorcod
           display by name d_ctc34m01.vclcorcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vclanomdl
           end if

           if d_ctc34m01.vclcorcod  is null   then
              error " Cor do veiculo deve ser informada!"
              call ctn36c00("Descricao da cor", "vclcorcod")
                   returning  d_ctc34m01.vclcorcod
              next field vclcorcod
           end if

           #PSI 222020 - Burini
           let l_aux = "vclcorcod"
           open cctc34m01003 using l_aux,
                                   d_ctc34m01.vclcorcod
           fetch cctc34m01003 into d_ctc34m01.vclcordes

           if sqlca.sqlcode  <>  0   then
              error " Cor nao cadastrada!"
              call ctn36c00("Descricao da cor", "vclcorcod")
                   returning  d_ctc34m01.vclcorcod
              next field vclcorcod
           end if
	   close cctc34m01003
           let d_ctc34m01.vclcordes = upshift(d_ctc34m01.vclcordes)
           display by name d_ctc34m01.vclcordes

    before field vclpnttip
           display by name d_ctc34m01.vclpnttip attribute (reverse)

    after  field vclpnttip
           display by name d_ctc34m01.vclpnttip

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vclcorcod
           end if

           if d_ctc34m01.vclpnttip  is null   then
              error " Tipo da pintura do veiculo deve ser informada!"
              call ctn36c00("Descricao do tipo da pintura", "vclpnttip")
                   returning  d_ctc34m01.vclpnttip
              next field vclpnttip
           end if

           #PSI 222020 - Burini
           let l_aux = "vclpnttip"
           open cctc34m01003 using l_aux,
                                   d_ctc34m01.vclpnttip
           fetch cctc34m01003 into d_ctc34m01.vclpntdes

           if sqlca.sqlcode  <>  0   then
              error " Tipo da pintura nao cadastrado!"
              call ctn36c00("Descricao do tipo da pintura", "vclpnttip")
                   returning  d_ctc34m01.vclpnttip
              next field vclpnttip
           end if
	   close cctc34m01003
           let d_ctc34m01.vclpntdes = upshift(d_ctc34m01.vclpntdes)
           display by name d_ctc34m01.vclpntdes

    before field vclcmbcod
           display by name d_ctc34m01.vclcmbcod attribute (reverse)

    after  field vclcmbcod
           display by name d_ctc34m01.vclcmbcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vclpnttip
           end if

           if d_ctc34m01.vclcmbcod  is null   then
              error " Tipo de combustivel do veiculo deve ser informado!"
              call ctn36c00("Descricao do tipo do combustivel", "vclcmbcod")
                   returning  d_ctc34m01.vclcmbcod
              next field vclcmbcod
           end if

           #PSI 222020 - Burini
           let l_aux = "vclcmbcod"
           open cctc34m01003 using l_aux,
                                   d_ctc34m01.vclcmbcod
           fetch cctc34m01003 into d_ctc34m01.vclcmbdes

           if sqlca.sqlcode  <>  0   then
              error " Tipo de combustivel nao cadastrado!"
              call ctn36c00("Descricao do tipo do combustivel", "vclcmbcod")
                   returning  d_ctc34m01.vclcmbcod
              next field vclcmbcod
           end if
	   close cctc34m01003
           let d_ctc34m01.vclcmbdes = upshift(d_ctc34m01.vclcmbdes)
           display by name d_ctc34m01.vclcmbdes

    before field socctrposflg
           display by name d_ctc34m01.socctrposflg  attribute (reverse)

    after  field socctrposflg
           display by name d_ctc34m01.socctrposflg

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vclcmbcod
           end if

           if d_ctc34m01.socctrposflg   is null   or
              (d_ctc34m01.socctrposflg  <>  "S"   and
               d_ctc34m01.socctrposflg  <>  "N")  then
              error " Posicao controlada deve ser: (S)im ou (N)ao!"
              next field socctrposflg
           end if

        ## if d_ctc34m01.pstcoddig  =  1    or     #--> Frota Porto SP
        ##    d_ctc34m01.pstcoddig  =  4    or     #--> Sucursal RJ
        ##    d_ctc34m01.pstcoddig  =  8    then   #--> Sucursal BA
        ##    if d_ctc34m01.socctrposflg  =  "N"   then
        ##       error " Todos os veiculos da Porto Seguro tem posicao controlada!"
        ##       next field socctrposflg
        ##    end if
        ## end if

           let ws.confirma  =  "N"

           if d_ctc34m01.socctrposflg  =  "N"    then

              if ws.socctrposflgsva       is null                  or
                 d_ctc34m01.socctrposflg  <>  ws.socctrposflgsva   then
                 call cts08g01("C","S",
                                   "                                        ",
                                   "VEICULO NAO TERA' SUA POSICAO CONTROLADA",
                                   "   PELO RADIO (POSICAO DA FROTA)        ",
                                   "                                        ")
                      returning ws.confirma

                 if ws.confirma  =  "N"   then
                    next field socctrposflg
                 end if
              end if

              initialize d_ctc34m01.atdvclsgl  to null
              display by name d_ctc34m01.atdvclsgl
              initialize d_ctc34m01.vcldtbgrpcod  to null
              display by name d_ctc34m01.vcldtbgrpcod
              initialize d_ctc34m01.vcldtbgrpdes  to null
              display by name d_ctc34m01.vcldtbgrpdes
              initialize d_ctc34m01.atdimpcod  to null
              display by name d_ctc34m01.atdimpcod
              initialize d_ctc34m01.mdtcod  to null
              display by name d_ctc34m01.mdtcod
              initialize d_ctc34m01.trxeqpsitdes  to null
              display by name d_ctc34m01.trxeqpsitdes
              next field pgrnum
              #next field socvstdiaqtd
           else
              if ws.socctrposflgsva       is null                  or
                 d_ctc34m01.socctrposflg  <>  ws.socctrposflgsva   then
                 call cts08g01("C","S",
                                   "                                        ",
                                   "VEICULO SERA' INCLUIDO AUTOMATICAMENTE, ",
                                   " EM QTP, NA POSICAO DA FROTA (RADIO)    ",
                                   "                                        ")
                      returning ws.confirma

                 if ws.confirma  =  "N"   then
                    next field socctrposflg
                 end if
              end if
           end if

    before field atdvclsgl
           display by name d_ctc34m01.atdvclsgl     attribute (reverse)

    after  field atdvclsgl
           display by name d_ctc34m01.atdvclsgl

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socctrposflg
           end if

           if d_ctc34m01.atdvclsgl  is null   then
              error " Sigla de identificacao do veiculo deve ser informada!"
              next field atdvclsgl
           end if

           if ws.atdvclsglsva       is not null           and
              d_ctc34m01.atdvclsgl  <>  ws.atdvclsglsva   then
              error " Sigla de identificacao nao deve ser alterada!"
              next field atdvclsgl
           end if

           let ws.contpos = length(d_ctc34m01.atdvclsgl)
           if ws.contpos  <  3   then
              error " Sigla de identificacao deve possuir no minimo 3 caracteres !"
              next field atdvclsgl
           end if

           #-----------------------------------------------------
           # Verifica se a sigla ja' foi cadastrada
           #-----------------------------------------------------
           initialize ws.socvclcod  to null
           let l_sql = " select socvclcod               "
                      ," from datkveiculo               "
                      ,"where datkveiculo.atdvclsgl = ? "
                       
           prepare pctc34m01005 from l_sql
           declare cctc34m01005 cursor for pctc34m01005
           let l_erro = ''
           let l_cont = 0
           open cctc34m01005 using d_ctc34m01.atdvclsgl
           foreach cctc34m01005  into  ws.socvclcod  
               if (param.operacao  =  "i") or
                  (d_ctc34m01.socvclcod  <>  ws.socvclcod and param.operacao  <>  "i")   then 
                   let l_erro = ws.socvclcod, ' ',l_erro clipped
                   let l_cont = l_cont + 1
               end if                            
           end foreach                                    
           close cctc34m01005          
           if l_cont <> 0 then    
              if param.operacao  =  "i"   then
                 error " Sigla de identificacao ja' cadastrada em outro",
                       " veiculo! --> ", l_erro
                 next field atdvclsgl
              else
                 if (d_ctc34m01.socvclcod  <>  ws.socvclcod) or l_cont > 0 then
                    error " Sigla de identificacao ja' cadastrada em outro",
                          " veiculo! --> ", l_erro
                    next field atdvclsgl
                 end if
              end if
           end if

    before field vcldtbgrpcod
           display by name d_ctc34m01.vcldtbgrpcod attribute (reverse)

    after  field vcldtbgrpcod
           display by name d_ctc34m01.vcldtbgrpcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  atdvclsgl
           end if

           if d_ctc34m01.vcldtbgrpcod  is null   then
              error " Grupo de distribuicao do veiculo deve ser informado!"
              call ctn39c00()  returning d_ctc34m01.vcldtbgrpcod
              next field vcldtbgrpcod
           end if

           select vcldtbgrpdes
             into d_ctc34m01.vcldtbgrpdes
             from datkvcldtbgrp
            where datkvcldtbgrp.vcldtbgrpcod  =  d_ctc34m01.vcldtbgrpcod

           if sqlca.sqlcode  <>  0   then
              error " Grupo de distribuicao do veiculo nao cadastrado!"
              call ctn39c00()  returning d_ctc34m01.vcldtbgrpcod
              next field vcldtbgrpcod
           end if
           display by name d_ctc34m01.vcldtbgrpdes

    before field atdimpcod
           display by name d_ctc34m01.atdimpcod     attribute (reverse)

    after  field atdimpcod
           display by name d_ctc34m01.atdimpcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  vcldtbgrpcod
           end if

           initialize ws.atdimpsit              to null
           initialize d_ctc34m01.trxeqpsitdes   to null

           if d_ctc34m01.atdimpcod  is not null   then

              select atdimpsit
                into ws.atdimpsit
                from datktrximp
               where datktrximp.atdimpcod  =  d_ctc34m01.atdimpcod

              if sqlca.sqlcode  <>  0    then
                 error " Codigo do pager nao cadastrado!"
                 next field atdimpcod
              end if

              let d_ctc34m01.trxeqpsitdes = "SIT. PAGER NAO CADASTRADO"

              #PSI 222020 - Burini
              let l_aux = "atdimpsit"
              open cctc34m01003 using l_aux,
                                      ws.atdimpsit
              fetch cctc34m01003 into d_ctc34m01.trxeqpsitdes
              close cctc34m01003
               display by name d_ctc34m01.trxeqpsitdes

               initialize ws.socvclcod  to null
               
               let l_sql = " select socvclcod                "           
                          ," from datkveiculo                "
                          ,"where datkveiculo.atdimpcod  = ? "
                                                             
               prepare pctc34m01006 from l_sql               
               declare cctc34m01006 cursor for pctc34m01006  
               let l_erro = ''    
               let l_cont = 0
                                                         
               open cctc34m01006 using d_ctc34m01.atdimpcod 
               foreach cctc34m01006  into  ws.socvclcod  
                   if (param.operacao  =  "i") or
                      (d_ctc34m01.socvclcod  <>  ws.socvclcod and param.operacao  <>  "i")   then 
                       let l_erro = ws.socvclcod, ' ',l_erro clipped
                       let l_cont = l_cont + 1
                   end if                            
               end foreach 
               close cctc34m01006              
                if l_cont <> 0 then     
                  if param.operacao  =  "i"   then
                     error " Codigo de pager ja' cadastrado em outro",
                           " veiculo! --> ", l_erro
                     next field atdimpcod
                  else
                     if (d_ctc34m01.socvclcod  <>  ws.socvclcod) or l_cont > 0 then
                        error " Codigo de pager ja' cadastrado em outro",
                              " veiculo! --> ", l_erro
                        next field atdimpcod
                     end if
                  end if
               end if
           else
              display by name d_ctc34m01.trxeqpsitdes
           end if

           if d_ctc34m01.atdimpcod  is not null   then
              initialize d_ctc34m01.mdtcod  to null
              display by name d_ctc34m01.mdtcod
              next field  socvstdiaqtd
           end if

    before field mdtcod
           display by name d_ctc34m01.mdtcod     attribute (reverse)

    after  field mdtcod
           display by name d_ctc34m01.mdtcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_ctc34m01.mdtcod  is null   then
                 next field  atdimpcod
              end if
              next field  vcldtbgrpcod
           end if

           initialize ws.mdtstt                to null
           initialize d_ctc34m01.trxeqpsitdes  to null

           if d_ctc34m01.mdtcod  is not null   then

	              select mdtstt, gpsacngrpcod
	                into ws.mdtstt, d_ctc34m01.gpsacngrpcod
	                from datkmdt, datkmdtctr
	               where datkmdt.mdtcod  =  d_ctc34m01.mdtcod
	                 and datkmdt.mdtctrcod = datkmdtctr.mdtctrcod

              if sqlca.sqlcode  <>  0    then
                 error " Codigo do MDT nao cadastrado!"
                 next field mdtcod
              end if

              let d_ctc34m01.trxeqpsitdes = "*** ERRO ***"

              #PSI 222020 - Burini
              let l_aux = "mdtstt"
              open cctc34m01003 using l_aux,
                                      ws.mdtstt
              fetch cctc34m01003 into d_ctc34m01.trxeqpsitdes
              close cctc34m01003

               display by name d_ctc34m01.trxeqpsitdes

               initialize ws.socvclcod  to null
               
               let l_sql = " select socvclcod             "           
                          ," from datkveiculo             "
                          ,"where datkveiculo.mdtcod  = ? "
                                                             
               prepare pctc34m01007 from l_sql               
               declare cctc34m01007 cursor for pctc34m01007  
               let l_erro = '' 
               let l_cont = 0
                                                            
               open cctc34m01007 using d_ctc34m01.mdtcod 
               foreach cctc34m01007  into  ws.socvclcod  
                   if (param.operacao  =  "i") or
                      (d_ctc34m01.socvclcod  <>  ws.socvclcod and param.operacao  <>  "i")   then  
                       let l_erro = ws.socvclcod, ' ',l_erro clipped
                       let l_cont = l_cont + 1
                   end if                            
               end foreach
                close cctc34m01007              
                if l_cont <> 0 then    
                  if param.operacao  =  "i"   then
                     error " Codigo de MDT ja' cadastrado em outro",
                           " veiculo! --> ", l_erro
                     next field mdtcod
                  else
                     if (d_ctc34m01.socvclcod  <>  ws.socvclcod) or l_cont > 0 then
                        error " Codigo de MDT ja' cadastrado em outro",
                              " veiculo! --> ", l_erro
                        next field mdtcod
                     end if
                  end if
               end if
           else
              display by name d_ctc34m01.trxeqpsitdes
           end if

    before field pgrnum
           display by name d_ctc34m01.pgrnum     attribute (reverse)

    after  field pgrnum
           display by name d_ctc34m01.pgrnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if d_ctc34m01.socctrposflg  =  "N" then
                   next field socctrposflg
              end if              
              if d_ctc34m01.mdtcod  is not null   then
                 next field  mdtcod
              end if
              next field  atdimpcod
           end if

           initialize d_ctc34m01.ustnom to null

           if d_ctc34m01.pgrnum  is not null   then

              select ustnom, ustsit, gutcod
                into d_ctc34m01.ustnom, ws.ustsit, ws.gutcod
                from htlrust
               where htlrust.pgrnum  =  d_ctc34m01.pgrnum

              if sqlca.sqlcode  <>  0    then
                 error " Nro do teletrim nao cadastrado!"
                 next field pgrnum
              else
                 if ws.ustsit <> "A" then
                    error " Nro do teletrim nao cadastrado!"
                    next field pgrnum
                 else
  ################  if ws.gutcod <> 82  then
  #                    error " Nro do teletrim nao pertence ao grupo da Central 24h!"
  #                    next field pgrnum
  ################  end if
                 end if
              end if

              initialize ws.socvclcod  to null
              
              let l_sql = " select socvclcod              "           
                          ," from datkveiculo             "
                          ,"where datkveiculo.pgrnum  = ? "
                                                             
               prepare pctc34m01008 from l_sql               
               declare cctc34m01008 cursor for pctc34m01008  
               let l_erro = '' 
               let l_cont = 0
                                                            
               open cctc34m01008 using d_ctc34m01.pgrnum 
               foreach cctc34m01008  into  ws.socvclcod  
                   if (param.operacao  =  "i") or
                      (d_ctc34m01.socvclcod  <>  ws.socvclcod and param.operacao  <>  "i")   then 
                       let l_erro = ws.socvclcod, ' ',l_erro clipped
                       let l_cont = l_cont + 1
                   end if                            
               end foreach
             
	       close cctc34m01008
              if l_cont <> 0 then  
                 if param.operacao  =  "i"   then
                    error " Codigo do TELETRIM ja' cadastrado em outro",
                          " veiculo! --> ", l_erro
                    next field pgrnum
                 else
                    if (d_ctc34m01.socvclcod  <>  ws.socvclcod) or l_cont > 0 then
                       error " Codigo do TELETRIM ja' cadastrado em outro",
                             " veiculo! --> ", l_erro
                       next field pgrnum
                    end if
                 end if
              end if
           end if
           display by name d_ctc34m01.ustnom

    before field socvstdiaqtd
           display by name d_ctc34m01.socvstdiaqtd  attribute (reverse)

    after  field socvstdiaqtd
           display by name d_ctc34m01.socvstdiaqtd

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field pgrnum
           end if

           if d_ctc34m01.socvstdiaqtd  is null   then
              initialize d_ctc34m01.socvstlclcod,
                         d_ctc34m01.socvstlclnom,
                         d_ctc34m01.socvstlautipcod,
                         d_ctc34m01.socvstlautipdes to null
              display by name d_ctc34m01.socvstlclcod
              display by name d_ctc34m01.socvstlclnom
              display by name d_ctc34m01.socvstlautipcod
              display by name d_ctc34m01.socvstlautipdes
              exit input
           end if

           if d_ctc34m01.socvstdiaqtd  <  30    or
              d_ctc34m01.socvstdiaqtd  >  365   then
              error " Periodicidade para vistoria deve ser de 30 a 365 dias!"
              next field socvstdiaqtd
           end if

           if d_ctc34m01.socvstdiaqtd  <> vst.socvstdiaqtd then
              call ctc34m10(d_ctc34m01.socvclcod, d_ctc34m01.socvstdiaqtd)
                   returning vst.ok, vst.socvstnum, vst.socvstdat_new
           end if

    before field socvstlclcod
           display by name d_ctc34m01.socvstlclcod   attribute (reverse)
           if d_ctc34m01.socvstdiaqtd  is null   then
              initialize d_ctc34m01.socvstlclcod,
                         d_ctc34m01.socvstlclnom,
                         d_ctc34m01.socvstlautipcod,
                         d_ctc34m01.socvstlautipdes to null
              display by name d_ctc34m01.socvstlclcod
              display by name d_ctc34m01.socvstlclnom
              display by name d_ctc34m01.socvstlautipcod
              display by name d_ctc34m01.socvstlautipdes
              exit input
           end if

    after  field socvstlclcod
           display by name d_ctc34m01.socvstlclcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socvstdiaqtd
           end if

           if d_ctc34m01.socvstlclcod   is null   then
              error " Codigo do local de vistoria deve ser informado!"
              call ctc35m13()  returning d_ctc34m01.socvstlclcod
              next field socvstlclcod
           end if

           select socvstlclnom, socvstlclsit
             into d_ctc34m01.socvstlclnom, ws.socvstlclsit
             from datkvstlcl
            where socvstlclcod = d_ctc34m01.socvstlclcod

           if sqlca.sqlcode = notfound   then
              error " Codigo do local de vistoria nao existe!"
              call ctc35m13()  returning d_ctc34m01.socvstlclcod
              next field socvstlclcod
            else
              if sqlca.sqlcode <> 0   then
                 error " Erro (",sqlca.sqlcode,") na leitura do local vistoria"
                 next field socvstlclcod
               else
                 display by name d_ctc34m01.socvstlclnom
              end if
           end if

           if ws.socvstlclsit <> "A"    then
              error " Local vistoria informado nao esta' ativo!"
              next field socvstlclcod
           end if

    before field socvstlautipcod
           display by name d_ctc34m01.socvstlautipcod attribute (reverse)
           if d_ctc34m01.socvstdiaqtd  is null   then
              initialize d_ctc34m01.socvstlclcod,
                         d_ctc34m01.socvstlclnom,
                         d_ctc34m01.socvstlautipcod,
                         d_ctc34m01.socvstlautipdes to null
              display by name d_ctc34m01.socvstlclcod
              display by name d_ctc34m01.socvstlclnom
              display by name d_ctc34m01.socvstlautipcod
              display by name d_ctc34m01.socvstlautipdes
              exit input
           end if

    after  field socvstlautipcod
           display by name d_ctc34m01.socvstlautipcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field socvstlclcod
           end if

           if d_ctc34m01.socvstlautipcod  is null   then
              error " Codigo do tipo de laudo deve ser informado!"
              call ctc35m09()  returning d_ctc34m01.socvstlautipcod
              next field socvstlautipcod
           end if

           select socvstlautipdes, socvstlautipsit
             into d_ctc34m01.socvstlautipdes, ws.socvstlautipsit
             from datkvstlautip
            where datkvstlautip.socvstlautipcod = d_ctc34m01.socvstlautipcod

           if sqlca.sqlcode = notfound   then
              error " Tipo de laudo nao cadastrado!"
              call ctc35m09()  returning d_ctc34m01.socvstlautipcod
              next field socvstlautipcod
            else
              if sqlca.sqlcode <> 0   then
                 error " Erro (",sqlca.sqlcode,") na leitura do cad.Tipo de laudo"
                 next field socvstlautipcod
               else
                 display by name d_ctc34m01.socvstlautipdes
              end if
           end if

           if ws.socvstlautipsit <> "A"    then
              error " Tipo de laudo informado nao esta' ativo!"
              next field socvstlautipcod
           end if

    # BLOCO SERA DESCOMENATDO QUANDO SOLICITADO POR PORTO SOCORRO

    # before field frtrpnflg
    #     if  d_ctc34m01.frtrpnflg is null or d_ctc34m01.frtrpnflg = " " then
    #         call cty09g00_popup_iddkdominio("frtrpnflg")
    #              returning ws.erro,
    #                        d_ctc34m01.frtrpnflg,
    #                        d_ctc34m01.frtrpndes
    #     end if
    #
    #     display by name d_ctc34m01.frtrpnflg    attribute(reverse)
    #
    # after field frtrpnflg
    #
    #     if  d_ctc34m01.frtrpnflg is null or d_ctc34m01.frtrpnflg = " " then
    #         call cty09g00_popup_iddkdominio("frtrpnflg")
    #              returning ws.erro,
    #                        d_ctc34m01.frtrpnflg,
    #                        d_ctc34m01.frtrpndes
    #     else
    #         #PSI 222020 - Burini
    #         let l_aux = "frtrpnflg"
    #         open cctc34m01003 using l_aux,
    #                                 d_ctc34m01.frtrpnflg
    #         fetch cctc34m01003 into d_ctc34m01.frtrpndes
    #
    #         if  sqlca.sqlcode <> 0 then
    #             error 'Responsavel nao cadastrado.'
    #             let d_ctc34m01.frtrpnflg = ""
    #             let d_ctc34m01.frtrpndes = ""
    #             next field frtrpnflg
    #         end if
    #
    #         if  l_frtrpnflg <> d_ctc34m01.frtrpnflg and
    #             d_ctc34m01.frtrpnflg = 1            and
    #             g_issk.dptsgl <> "psocor"           and
    #             g_issk.dptsgl <> "desenv"           then
    #             error 'Somente usuarios PORTO SOCORRO podem fazer essa operação'
    #             let d_ctc34m01.frtrpnflg = ""
    #             let d_ctc34m01.frtrpndes = ""
    #             next field frtrpnflg
    #         end if
    #     end if
    #
    #     display by name d_ctc34m01.frtrpndes attribute(reverse)
    #     display by name d_ctc34m01.frtrpnflg attribute(reverse)

    on key (interrupt)
       initialize atdvclsglS to null
       exit input     
end input

 if int_flag   then
    initialize atdvclsglS to null
          display by name atdvclsglS
    initialize d_ctc34m01.*  to null
 end if

 return d_ctc34m01.*

 end function   # ctc34m01_input


#---------------------------------------------------------
 function ctc34m01_ler(param)
#---------------------------------------------------------

 define param         record
    socvclcod         like datkveiculo.socvclcod
 end record

 define d_ctc34m01    record
   socvclcod          like datkveiculo.socvclcod,
   pstcoddig          like datkveiculo.pstcoddig,
   nomgrr             like dpaksocor.nomgrr,
   vclctfnom          like datkveiculo.vclctfnom,
   socoprsitcod       like datkveiculo.socoprsitcod,
   socoprsitdes       char (09),
   vclaqstipcod       like datkveiculo.vclaqstipcod,
   aqsdes             like iddkdominio.cpodes,
   vclaqsnom          like datkveiculo.vclaqsnom,
   vclcoddig          like datkveiculo.vclcoddig,
   vcldes             char (58),
   socvcltip          like datkveiculo.socvcltip,
   socvcldes          like iddkdominio.cpodes,
   chassi             char (20),
   vcllicnum          like datkveiculo.vcllicnum,
   vclanofbc          like datkveiculo.vclanofbc,
   vclanomdl          like datkveiculo.vclanomdl,
   vclcorcod          like datkveiculo.vclcorcod,
   vclcordes          char (20),
   vclpnttip          like datkveiculo.vclpnttip,
   vclpntdes          char (20),
   vclcmbcod          like datkveiculo.vclcmbcod,
   vclcmbdes          char (20),
   socctrposflg       like datkveiculo.socctrposflg,
   atdvclsgl          like datkveiculo.atdvclsgl,
   vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
   vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
   atdimpcod          like datkveiculo.atdimpcod,
   mdtcod             like datkveiculo.mdtcod,
   gpsacngrpcod       like dattfrotalocal.gpsacngrpcod,
   trxeqpsitdes       char (15),
   pgrnum             like datkveiculo.pgrnum,
   ustnom             like htlrust.ustnom,
   socvstdiaqtd       like datkveiculo.socvstdiaqtd,
   socvstlclcod       like datkveiculo.socvstlclcod,
   socvstlclnom       like datkvstlcl.socvstlclnom,
   socvstlautipcod    like datkveiculo.socvstlautipcod,
   socvstlautipdes    like datkvstlautip.socvstlautipdes,
   caddat             like datkveiculo.caddat,
   cadfunnom          like isskfunc.funnom,
   atldat             like datkveiculo.atldat,
   funnom             like isskfunc.funnom,
   celdddcod          like datkveiculo.celdddcod,
   celtelnum          like datkveiculo.celtelnum,
   nxtdddcod          like datkveiculo.nxtdddcod,
   nxtide             like datkveiculo.nxtide,
   nxtnum             like datkveiculo.nxtnum,
   frtrpnflg          like dpaksocor.frtrpnflg,
   frtrpndes          char(20),
   rencod             like datkveiculo.rencod,
   vclcadorgcod       like datkveiculo.vclcadorgcod,
   vclcadorgdes       like iddkdominio.cpodes
 end record

 define ws            record
   cont               integer,
   atlemp             like isskfunc.empcod,
   atlmat             like isskfunc.funmat,
   cademp             like isskfunc.empcod,
   cadmat             like isskfunc.funmat,
   vclchsinc          like datkveiculo.vclchsinc,
   vclchsfnl          like datkveiculo.vclchsfnl,
   atdimpsit          like datktrximp.atdimpsit,
   mdtstt             like datkmdt.mdtstt
 end record

 define l_aux   char(50)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  d_ctc34m01.*  to  null

        initialize  ws.*  to  null

 initialize d_ctc34m01.*   to null
 initialize ws.*           to null

 select socvclcod,
        pstcoddig,
        vclctfnom,
        vclcoddig,
        vclanofbc,
        vclanomdl,
        vcllicnum,
        vclchsinc,
        vclchsfnl,
        vclcorcod,
        vclpnttip,
        vclcmbcod,
        socctrposflg,
        atdvclsgl,
        atdimpcod,
        mdtcod,
        socvstdiaqtd,
        socoprsitcod,
        caddat,
        cademp,
        cadmat,
        atldat,
        atlemp,
        atlmat,
        vclaqstipcod,
        vclaqsnom,
        socvstlclcod,
        socvstlautipcod,
        pgrnum,
        socvcltip,
        celdddcod,
        celtelnum,
        nxtdddcod,
        nxtide,
        nxtnum,
        rencod,
        vclcadorgcod
      #  frtrpnflg
   into d_ctc34m01.socvclcod,
        d_ctc34m01.pstcoddig,
        d_ctc34m01.vclctfnom,
        d_ctc34m01.vclcoddig,
        d_ctc34m01.vclanofbc,
        d_ctc34m01.vclanomdl,
        d_ctc34m01.vcllicnum,
        ws.vclchsinc,
        ws.vclchsfnl,
        d_ctc34m01.vclcorcod,
        d_ctc34m01.vclpnttip,
        d_ctc34m01.vclcmbcod,
        d_ctc34m01.socctrposflg,
        d_ctc34m01.atdvclsgl,
        d_ctc34m01.atdimpcod,
        d_ctc34m01.mdtcod,
        d_ctc34m01.socvstdiaqtd,
        d_ctc34m01.socoprsitcod,
        d_ctc34m01.caddat,
        ws.cademp,
        ws.cadmat,
        d_ctc34m01.atldat,
        ws.atlemp,
        ws.atlmat,
        d_ctc34m01.vclaqstipcod,
        d_ctc34m01.vclaqsnom,
        d_ctc34m01.socvstlclcod,
        d_ctc34m01.socvstlautipcod,
        d_ctc34m01.pgrnum,
        d_ctc34m01.socvcltip,
        d_ctc34m01.celdddcod,
        d_ctc34m01.celtelnum,
        d_ctc34m01.nxtdddcod,
        d_ctc34m01.nxtide,
        d_ctc34m01.nxtnum,
        d_ctc34m01.rencod,
        d_ctc34m01.vclcadorgcod
      #  d_ctc34m01.frtrpnflg
   from datkveiculo
  where datkveiculo.socvclcod = param.socvclcod

 if sqlca.sqlcode = notfound   then
    error " Veiculo nao cadastrado!"
    initialize atdvclsglS to null
          display by name atdvclsglS
    initialize d_ctc34m01.*  to null
    return d_ctc34m01.*
 else
     open cctc34m01004 using d_ctc34m01.pstcoddig
     fetch cctc34m01004 into d_ctc34m01.frtrpnflg
     close cctc34m01004

    #---------------------------------------------------------
    # Razao Social do prestador
    #---------------------------------------------------------
    select nomgrr
      into d_ctc34m01.nomgrr
      from dpaksocor
     where dpaksocor.pstcoddig = d_ctc34m01.pstcoddig

    #---------------------------------------------------------
    # Aquisicao do veiculo
    #---------------------------------------------------------
    let d_ctc34m01.aqsdes = "AQUISICAO NAO CADASTRADA!"

    #PSI 222020 - Burini
    let l_aux = "vclaqstipcod"
    open cctc34m01003 using l_aux,
                            d_ctc34m01.vclaqstipcod
    fetch cctc34m01003 into d_ctc34m01.aqsdes
    close cctc34m01003

    #---------------------------------------------------------
    # Descricao do veiculo
    #---------------------------------------------------------
    call cts15g00(d_ctc34m01.vclcoddig)  returning d_ctc34m01.vcldes

    #---------------------------------------------------------
    # Descricao do Tipo Equipamento Socorro
    #---------------------------------------------------------

    #PSI 222020 - Burini
    let l_aux = "socvcltip"
    open cctc34m01003 using l_aux,
                            d_ctc34m01.socvcltip
    fetch cctc34m01003 into d_ctc34m01.socvcldes
    close cctc34m01003

    #---------------------------------------------------------
    # Cor/Acabamento pintura/Combustivel/Chassi veiculo
    #---------------------------------------------------------
    let d_ctc34m01.vclcordes = "COR NAO CADASTRADA"

    #PSI 222020 - Burini
    let l_aux = "vclcorcod"
    open cctc34m01003 using l_aux,
                            d_ctc34m01.vclcorcod
    fetch cctc34m01003 into d_ctc34m01.vclcordes
    close cctc34m01003

    let d_ctc34m01.vclpntdes = "ACABAMENTO NAO CADASTRADO"

    #PSI 222020 - Burini
    let l_aux = "vclpnttip"
    open cctc34m01003 using l_aux,
                            d_ctc34m01.vclpnttip
    fetch cctc34m01003 into d_ctc34m01.vclpntdes
    close cctc34m01003

    let d_ctc34m01.vclcmbdes = "COMBUSTIVEL NAO CADASTRADO"

    #PSI 222020 - Burini
    let l_aux = "vclcmbcod"
    open cctc34m01003 using l_aux,
                            d_ctc34m01.vclcmbcod
    fetch cctc34m01003 into d_ctc34m01.vclcmbdes
    close cctc34m01003

    let d_ctc34m01.vclcordes = upshift(d_ctc34m01.vclcordes)
    let d_ctc34m01.vclpntdes = upshift(d_ctc34m01.vclpntdes)
    let d_ctc34m01.vclcmbdes = upshift(d_ctc34m01.vclcmbdes)


    let d_ctc34m01.chassi = ws.vclchsinc, ws.vclchsfnl
    if ws.vclchsinc  is null   and
       ws.vclchsfnl  is null   then
       initialize d_ctc34m01.chassi  to null
    end if

    #---------------------------------------------------------
    # Situacao pager/MDT
    #---------------------------------------------------------
    if d_ctc34m01.atdimpcod  is not null   then
       select atdimpsit
         into ws.atdimpsit
         from datktrximp
        where datktrximp.atdimpcod  =  d_ctc34m01.atdimpcod

       let d_ctc34m01.trxeqpsitdes = "*** ERRO ***"

       #PSI 222020 - Burini
       let l_aux = "atdimpsit"
       open cctc34m01003 using l_aux,
                               ws.atdimpsit
       fetch cctc34m01003 into d_ctc34m01.trxeqpsitdes
       close cctc34m01003
    end if

    if d_ctc34m01.mdtcod  is not null   then
       select mdtstt
         into ws.mdtstt
         from datkmdt
        where datkmdt.mdtcod  =  d_ctc34m01.mdtcod

       let d_ctc34m01.trxeqpsitdes = "*** ERRO ***"

       #PSI 222020 - Burini
       let l_aux = "mdtstt"
       open cctc34m01003 using l_aux,
                               ws.mdtstt
       fetch cctc34m01003 into d_ctc34m01.trxeqpsitdes
       close cctc34m01003
    end if

    #---------------------------------------------------------
    # Situacao veiculo
    #---------------------------------------------------------
    let d_ctc34m01.socoprsitdes = "SIT. VEICULO NAO CADASTRADO"

    #PSI 222020 - Burini
    let l_aux = "socoprsitcod"
    open cctc34m01003 using l_aux,
                            d_ctc34m01.socoprsitcod
    fetch cctc34m01003 into d_ctc34m01.socoprsitdes
    close cctc34m01003

    #---------------------------------------------------------
    # Grupo de distribuicao do veiculo
    #---------------------------------------------------------
    if d_ctc34m01.socctrposflg  =  "S"   then
       let d_ctc34m01.vcldtbgrpdes = "GRUPO NAO CADASTRADO"
       select vcldtbgrpcod
         into d_ctc34m01.vcldtbgrpcod
         from dattfrotalocal
        where dattfrotalocal.socvclcod  =  param.socvclcod

       if sqlca.sqlcode  =  0   then
          select vcldtbgrpdes
            into d_ctc34m01.vcldtbgrpdes
            from datkvcldtbgrp
           where datkvcldtbgrp.vcldtbgrpcod  =  d_ctc34m01.vcldtbgrpcod
       end if
    end if

    #---------------------------------------------------------
    # Funcionario cadastramento/atualizacao
    #---------------------------------------------------------
    call ctc34m01_func(ws.cademp, ws.cadmat)
         returning d_ctc34m01.cadfunnom

    call ctc34m01_func(ws.atlemp, ws.atlmat)
         returning d_ctc34m01.funnom

    #---------------------------------------------------------
    # Numero/nome Teletrim
    #---------------------------------------------------------
    if d_ctc34m01.pgrnum  is not null   then
       initialize d_ctc34m01.ustnom to null
       select ustnom
         into d_ctc34m01.ustnom
         from htlrust
        where htlrust.pgrnum  =  d_ctc34m01.pgrnum

       if sqlca.sqlcode  = notfound then
          let d_ctc34m01.ustnom  = "TELETRIM NAO CADASTRADO!"
       end if
    end if

    #---------------------------------------------------------
    # Local Vistoria
    #---------------------------------------------------------
    if d_ctc34m01.socvstlclcod  is not null   then
       select socvstlclnom
         into d_ctc34m01.socvstlclnom
         from datkvstlcl
        where datkvstlcl.socvstlclcod = d_ctc34m01.socvstlclcod

       if sqlca.sqlcode  <>  0   then
          let d_ctc34m01.socvstlclnom = "LOCAL NAO CADASTRADO"
       end if
    end if

    #---------------------------------------------------------
    # Tipo de Laudo
    #---------------------------------------------------------
    if d_ctc34m01.socvstlautipcod  is not null   then
       select socvstlautipdes
         into d_ctc34m01.socvstlautipdes
         from datkvstlautip
        where datkvstlautip.socvstlautipcod = d_ctc34m01.socvstlautipcod

       if sqlca.sqlcode  <>  0   then
          let d_ctc34m01.socvstlautipdes = "TIPO LAUDO NAO CADASTRADO"
       end if
    end if

    if  d_ctc34m01.frtrpnflg is not null   then
        let l_aux = 'frtrpnflg'

        open cctc34m01003 using l_aux,
                                d_ctc34m01.frtrpnflg
        fetch cctc34m01003 into d_ctc34m01.frtrpndes
        close cctc34m01003

        display d_ctc34m01.frtrpndes

        display by name d_ctc34m01.frtrpnflg
        display by name d_ctc34m01.frtrpndes
    end if 
    
    #---------------------------------------------------------
    # Tipo de origen do cadastro da viatura
    #---------------------------------------------------------
    if  d_ctc34m01.vclcadorgcod is not null   then
        let l_aux = 'ctc34m03_orgcadvcl'

        open cctc34m01003 using l_aux,
                                d_ctc34m01.vclcadorgcod
        fetch cctc34m01003 into d_ctc34m01.vclcadorgdes
        close cctc34m01003

    end if    

 end if

 return d_ctc34m01.*

 end function   # ctc34m01_ler


#---------------------------------------------------------
 function ctc34m01_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 initialize ws.*    to null

 select funnom
   into ws.funnom
   from isskfunc
  where isskfunc.empcod = param.empcod
    and isskfunc.funmat = param.funmat

 return ws.funnom

 end function   # ctc34m01_func


#---------------------------------------------------------
 function ctc34m01_gravapos(param)
#---------------------------------------------------------

 define param         record
    socvclcod         like datkveiculo.socvclcod,
    socctrposflg      like datkveiculo.socctrposflg,
    vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod,
    gpsacngrpcod      like dattfrotalocal.gpsacngrpcod,
    operacao          char (1)
 end record


 define ws            record
    achoupos          char (1),
    vez               smallint
 end record




#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  ws.*  to  null

 whenever error continue

 let ws.achoupos  =  "N"

 #--------------------------------------------------------
 # Inclusao de veiculo com posicao controlada
 #--------------------------------------------------------
 if param.operacao  =  "i"    then
    if param.socctrposflg  =  "S"    then

       insert into dattfrotalocal
                            ( socvclcod,
                              c24atvcod,
                              atdvclpriflg,
                              vcldtbgrpcod,
                              gpsacngrpcod)
                     values
                            ( param.socvclcod,
                              "QTP",
                              "N",
                              param.vcldtbgrpcod,
                              param.gpsacngrpcod)

       if sqlca.sqlcode <>  0   then
          error " Erro (",sqlca.sqlcode,") na Inclusao dattfrotalocal(1)!"
          rollback work
          return false
       end if

       for ws.vez = 1 to 3
           insert into datmfrtpos
                                ( socvclcod,
                                  socvcllcltip,
                                  atldat,
                                  atlhor )
                         values
                                ( param.socvclcod,
                                  ws.vez,
                                  today,
                                  current hour to minute )

           if sqlca.sqlcode <>  0   then
              error " Erro (",sqlca.sqlcode,") na Inclusao datmfrtpos(2)!"
              rollback work
              return false
           end if
       end for

    end if
 end if

 #--------------------------------------------------------
 # Alteracao de veiculo
 #--------------------------------------------------------
 if param.operacao  =  "a"    then

    select socvclcod
      from dattfrotalocal
     where dattfrotalocal.socvclcod  =  param.socvclcod

    if sqlca.sqlcode  =  0    then
       let ws.achoupos  =  "S"
    end if

    #-----------------------------------------------------
    # Alteracao de veiculo para posicao nao controlada
    #-----------------------------------------------------
    if param.socctrposflg  =  "N"   then
       if ws.achoupos  =  "S"   then
          delete
            from dattfrotalocal
           where dattfrotalocal.socvclcod  =  param.socvclcod

          if sqlca.sqlcode  <>  0   then
             error " Erro (",sqlca.sqlcode,") na Exclusao dattfrotalocal!"
             rollback work
             return false
          end if

          delete
            from datmfrtpos
           where datmfrtpos.socvclcod     =  param.socvclcod
             and datmfrtpos.socvcllcltip  in (1,2,3)

          if sqlca.sqlcode  <>  0   then
             error " Erro (",sqlca.sqlcode,") na Exclusao datmfrtpos!"
             rollback work
             return false
          end if
       end if
    else
       #-----------------------------------------------------
       # Alteracao de grupo de distribuicao
       #-----------------------------------------------------
       if ws.achoupos  =  "S"   then
          update dattfrotalocal  set vcldtbgrpcod = param.vcldtbgrpcod
                 where dattfrotalocal.socvclcod   =  param.socvclcod

          if sqlca.sqlcode <>  0   then
             error " Erro (",sqlca.sqlcode,") na Alteracao da posicao da frota!"
             rollback work
             return false
          end if
       end if

       #-----------------------------------------------------
       # Alteracao para posicao controlada
       #-----------------------------------------------------
       if ws.achoupos  =  "N"   then
          insert into dattfrotalocal
                               ( socvclcod,
                                 c24atvcod,
                                 atdvclpriflg,
                                 vcldtbgrpcod,
                                 gpsacngrpcod)
                        values
                               ( param.socvclcod,
                                 "QTP",
                                 "N",
                                 param.vcldtbgrpcod,
                                 param.gpsacngrpcod)

          if sqlca.sqlcode <>  0   then
             error " Erro (",sqlca.sqlcode,") na Inclusao dattfrotalocal(2)!"
             rollback work
             return false
          end if

          for ws.vez = 1 to 3
              insert into datmfrtpos
                                   ( socvclcod,
                                     socvcllcltip,
                                     atldat,
                                     atlhor )
                            values
                                   ( param.socvclcod,
                                     ws.vez,
                                     today,
                                     current hour to minute )

              if sqlca.sqlcode <>  0   then
                 error " Erro (",sqlca.sqlcode,") na Inclusao datmfrtpos(2)!"
                 rollback work
                 return false
              end if
          end for
       else
         update dattfrotalocal
            set gpsacngrpcod = param.gpsacngrpcod
          where socvclcod = param.socvclcod

          if sqlca.sqlcode <>  0   then
             error " Erro (",sqlca.sqlcode,") na Inclusao dattfrotalocal(3)!"
             rollback work
             return false
          end if

       end if
    end if
 end if

 whenever error stop

 return true

 end function   # ctc34m01_gravapos

#-------------------------------------------#
function ctc34m01_pesq_cel_veic(lr_parametro)
#-------------------------------------------#

  #------------------------------------------------------------
  # FUNCAO RESPONSAVEL POR VERIFICAR SE O CELULAR DO VEICULO JA
  # ESTA CADASTRADO PARA ALGUM OUTRO VEICULO
  #------------------------------------------------------------

  define lr_parametro record
         celdddcod    like datkveiculo.celdddcod,
         celtelnum    like datkveiculo.celtelnum,
         socvclcod    like datkveiculo.socvclcod
  end record

  define l_celdddcod  like datkveiculo.celdddcod,
         l_celtelnum  like datkveiculo.celtelnum,
         l_socvclcod  like datkveiculo.socvclcod,
         l_achou      smallint

  if m_ctc34m01_prep is null or
     m_ctc34m01_prep <> true then
     call ctc34m01_prepare()
  end if

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------
  let l_celdddcod = null
  let l_celtelnum = null
  let l_socvclcod = null
  let l_achou     = false

  # -> BUSCA NO CADASTRO DE VEICULOS
  open cctc34m01002
  foreach cctc34m01002 into l_celdddcod,
                            l_celtelnum,
                            l_socvclcod

     if l_celdddcod is null or
        l_celtelnum is null then
        continue foreach
     end if

     if lr_parametro.celdddcod = l_celdddcod and
        lr_parametro.celtelnum = l_celtelnum then
        if l_socvclcod = lr_parametro.socvclcod then
           continue foreach
        end if

        let l_achou = true
        exit foreach
     end if

  end foreach
  close cctc34m01002

  if l_achou = false then
     let l_socvclcod = null
  end if

  return l_socvclcod

end function


#---------------------------------------------------------
function ctc34m01_empresa(param)
#---------------------------------------------------------
    define param record
         socvclcod      like datkveiculo.socvclcod
    end record

    define a_empresas array[15] of record
        ciaempcod   like gabkemp.empcod
    end record

    define a_empresas_aux array[15] of record
        ciaempcod   like gabkemp.empcod
    end record

    define l_ret        smallint,
           l_mensagem   char(60),
           l_mensagem2  char(100),
           l_aux        smallint,
           l_stt        smallint,
           l_total      smallint,
           x,n          integer,
           l_ctrl       smallint

    initialize a_empresas to null
    initialize a_empresas_aux to null

    let l_ret       = 0
    let l_mensagem  = null
    let l_mensagem2 = null
    let l_aux       = 1
    let l_total     = 0

    call ctd05g00_empresas(1, param.socvclcod )
         returning l_ret,
                   l_mensagem,
                   l_total,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_empresas[15].ciaempcod

    let a_empresas_aux[1].ciaempcod   =  a_empresas[1].ciaempcod
    let a_empresas_aux[2].ciaempcod   =  a_empresas[2].ciaempcod
    let a_empresas_aux[3].ciaempcod   =  a_empresas[3].ciaempcod
    let a_empresas_aux[4].ciaempcod   =  a_empresas[4].ciaempcod
    let a_empresas_aux[5].ciaempcod   =  a_empresas[5].ciaempcod
    let a_empresas_aux[6].ciaempcod   =  a_empresas[6].ciaempcod
    let a_empresas_aux[7].ciaempcod   =  a_empresas[7].ciaempcod
    let a_empresas_aux[8].ciaempcod   =  a_empresas[8].ciaempcod
    let a_empresas_aux[9].ciaempcod   =  a_empresas[9].ciaempcod
    let a_empresas_aux[10].ciaempcod  =  a_empresas[10].ciaempcod
    let a_empresas_aux[11].ciaempcod  =  a_empresas[11].ciaempcod
    let a_empresas_aux[12].ciaempcod  =  a_empresas[12].ciaempcod
    let a_empresas_aux[13].ciaempcod  =  a_empresas[13].ciaempcod
    let a_empresas_aux[14].ciaempcod  =  a_empresas[14].ciaempcod
    let a_empresas_aux[15].ciaempcod  =  a_empresas[15].ciaempcod

    #Abrir janela para atualizacao de empresas para o prestador
    call ctc00m03 (2,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_empresas[15].ciaempcod)
         returning l_ret,
                   l_mensagem,
                   a_empresas[1].ciaempcod,
                   a_empresas[2].ciaempcod,
                   a_empresas[3].ciaempcod,
                   a_empresas[4].ciaempcod,
                   a_empresas[5].ciaempcod,
                   a_empresas[6].ciaempcod,
                   a_empresas[7].ciaempcod,
                   a_empresas[8].ciaempcod,
                   a_empresas[9].ciaempcod,
                   a_empresas[10].ciaempcod,
                   a_empresas[11].ciaempcod,
                   a_empresas[12].ciaempcod,
                   a_empresas[13].ciaempcod,
                   a_empresas[14].ciaempcod,
                   a_emprEsas[15].ciaempcod

    if l_ret = 1 then
       #apagar empresas cadastradas ao prestador
       call ctd05g00_delete_datrvclemp(param.socvclcod)
            returning l_ret,
                      l_mensagem

       #Verificar qual empresa  foi excluida e envia email - psi 226300
       for n = 1 to 15
	   if a_empresas_aux[n].ciaempcod is not null then
	      let l_ctrl = 0
	      for x = 1 to 15
	         if a_empresas[x].ciaempcod is not null then
                    if a_empresas[x].ciaempcod = a_empresas_aux[n].ciaempcod then
                       let l_ctrl = 1
                       exit for
                    end if
                 end if
              end for
              if l_ctrl = 0 then
	         let l_mensagem2 = 'Exclusao de Empresa do Veiculo. Codigo : ',
	                           param.socvclcod
	         let l_mensagem  = "Empresa  [",a_empresas_aux[n].ciaempcod,"] Excluida !"
	         let l_stt = ctc34m01_grava_hist(param.socvclcod
                                                ,l_mensagem
                                                ,today
                                                ,l_mensagem2,"I")
              end if
            else
              exit for
           end if
       end for

       #inserir empresas cadastradas a locadora/veiculo
       if l_ret = 1 then
          #percorrer array de empresas e inserir para o prestador
          while l_aux <= 15    #tamanho do array
                if a_empresas[l_aux].ciaempcod is not null then
                    call ctd05g00_insert_datrvclemp(param.socvclcod,
                                                    a_empresas[l_aux].ciaempcod)
                         returning l_ret,
                                   l_mensagem
                    if l_ret <> 1 then
                       error l_mensagem
                       exit while
                    end if
                    #Verificar qual empresa  foi Incluida ou mantida e envia email - psi 226300
                    let l_ctrl = 0

                    for x = 1 to 15
                      if a_empresas[l_aux].ciaempcod = a_empresas_aux[x].ciaempcod then
                         # Nao eh para enviar email qdo a empresa for mantida
                         let l_mensagem  = "Empresa  [",a_empresas[l_aux].ciaempcod,
			                   "] Mantida !"
			 let l_ctrl = 1
			 exit for
                      end if
                    end for

                    if l_ctrl = 0 then
                       let l_mensagem  = "Empresa  [",a_empresas[l_aux].ciaempcod,
			                 "] Incluida !"
                       let l_mensagem2 =
   		       'Inclusao de Empresa do Veiculo. Codigo : ', param.socvclcod
                       let l_stt = ctc34m01_grava_hist(param.socvclcod
                                                       ,l_mensagem
                                                       ,today
                                                       ,l_mensagem2,"I")
                    end if

                    let l_aux = l_aux + 1
                else
                    #se é nulo mas não chegou no fim do array - continua
                    # pois em ctc00m03 se tentar inserir com f1, mas
                    # não informar ciaempcod e nem excluir a linha
                    let l_aux = l_aux + 1
                end if
          end while
       else
          error l_mensagem
       end if
    else
       error l_mensagem
    end if

    return

end function

#--------------------------------------------------------
function ctc34m01_grava_hist(lr_param,l_mensagem,l_opcao)
#--------------------------------------------------------

   define lr_param record
          socvclcod  like datkveiculo.socvclcod
         ,mensagem   char(3000)
         ,data       date
          end record

   define lr_retorno record
           stt       smallint
          ,msg       char(50)
          end record

   define l_mensagem    char(100)
         ,l_erro        smallint
         ,l_stt         smallint
         ,l_path        char(100)
         ,l_opcao       char(1)
	 ,l_hora        datetime hour to minute
	 ,l_prshstdes2  char(3000)
	 ,l_count
         ,l_iter
         ,l_length
         ,l_length2    smallint

   let l_stt  = true
   let l_path = null
   let l_hora = current hour to minute

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

       call ctb85g01_grava_hist(1
                              ,lr_param.socvclcod
                              ,l_prshstdes2
                              ,lr_param.data
                              ,g_issk.empcod
                              ,g_issk.funmat
                              ,g_issk.usrtip)
          returning lr_retorno.stt
                   ,lr_retorno.msg

   end for

   if l_opcao <>  "A" then
      if lr_retorno.stt =  0 then

        call ctb85g01_mtcorpo_email_html('CTC34M01',
                                         lr_param.data,
                                         l_hora,
                                         g_issk.empcod,
                                         g_issk.usrtip,
                                         g_issk.funmat,
                                         l_mensagem,
                                         lr_param.mensagem)
               returning l_erro

         if l_erro <> 0 then
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
function ctc34m01_verifica_mod(lr_ctc34m01_ant,lr_ctc34m01)
#---------------------------------------------------------

   define lr_ctc34m01_ant record
           pstcoddig         like datkveiculo.pstcoddig
          ,vclctfnom         like datkveiculo.vclctfnom
          ,socoprsitcod      like datkveiculo.socoprsitcod
          ,socoprsitdes      char (09)
          ,vclaqstipcod      like datkveiculo.vclaqstipcod
          ,vclaqsnom         like datkveiculo.vclaqsnom
          ,vclcoddig         like datkveiculo.vclcoddig
          ,celdddcod         like datkveiculo.celdddcod
          ,celtelnum         like datkveiculo.celtelnum
          ,nxtdddcod         like datkveiculo.nxtdddcod
          ,nxtide            like datkveiculo.nxtide
          ,nxtnum            like datkveiculo.nxtnum
          ,socvcltip         like datkveiculo.socvcltip
          ,chassi            char(20)
          ,vcllicnum         like datkveiculo.vcllicnum
          ,vclanofbc         like datkveiculo.vclanofbc
          ,vclanomdl         like datkveiculo.vclanomdl
          ,vclcorcod         like datkveiculo.vclcorcod
          ,vclpnttip         like datkveiculo.vclpnttip
          ,vclcmbcod         like datkveiculo.vclcmbcod
          ,socctrposflg      like datkveiculo.socctrposflg
          ,atdvclsgl         like datkveiculo.atdvclsgl
          ,vcldtbgrpcod      like datkvcldtbgrp.vcldtbgrpcod
          ,atdimpcod         like datkveiculo.atdimpcod
          ,mdtcod            like datkveiculo.mdtcod
          ,gpsacngrpcod      like dattfrotalocal.gpsacngrpcod
          ,pgrnum            like datkveiculo.pgrnum
          ,socvstdiaqtd      like datkveiculo.socvstdiaqtd
          ,socvstlclcod      like datkveiculo.socvstlclcod
          ,socvstlautipcod   like datkveiculo.socvstlautipcod
          ,rencod            like datkveiculo.rencod
          ,vclcadorgcod      like datkveiculo.vclcadorgcod  
          ,vclcadorgdes      like iddkdominio.cpodes        

   end record

   define lr_ctc34m01    record
          socvclcod          like datkveiculo.socvclcod,
          pstcoddig          like datkveiculo.pstcoddig,
          nomgrr             like dpaksocor.nomgrr,
          vclctfnom          like datkveiculo.vclctfnom,
          socoprsitcod       like datkveiculo.socoprsitcod,
          socoprsitdes       char (09),
          vclaqstipcod       like datkveiculo.vclaqstipcod,
          aqsdes             like iddkdominio.cpodes,
          vclaqsnom          like datkveiculo.vclaqsnom,
          vclcoddig          like datkveiculo.vclcoddig,
          vcldes             char (58),
          socvcltip          like datkveiculo.socvcltip,
          socvcldes          like iddkdominio.cpodes,
          chassi             char (20),
          vcllicnum          like datkveiculo.vcllicnum,
          vclanofbc          like datkveiculo.vclanofbc,
          vclanomdl          like datkveiculo.vclanomdl,
          vclcorcod          like datkveiculo.vclcorcod,
          vclcordes          char (20),
          vclpnttip          like datkveiculo.vclpnttip,
          vclpntdes          char (20),
          vclcmbcod          like datkveiculo.vclcmbcod,
          vclcmbdes          char (20),
          socctrposflg       like datkveiculo.socctrposflg,
          atdvclsgl          like datkveiculo.atdvclsgl,
          vcldtbgrpcod       like datkvcldtbgrp.vcldtbgrpcod,
          vcldtbgrpdes       like datkvcldtbgrp.vcldtbgrpdes,
          atdimpcod          like datkveiculo.atdimpcod,
          mdtcod             like datkveiculo.mdtcod,
          gpsacngrpcod       like dattfrotalocal.gpsacngrpcod,
          trxeqpsitdes       char (15),
          pgrnum             like datkveiculo.pgrnum,
          ustnom             like htlrust.ustnom,
          socvstdiaqtd       like datkveiculo.socvstdiaqtd,
          socvstlclcod       like datkveiculo.socvstlclcod,
          socvstlclnom       like datkvstlcl.socvstlclnom,
          socvstlautipcod    like datkveiculo.socvstlautipcod,
          socvstlautipdes    like datkvstlautip.socvstlautipdes,
          caddat             like datkveiculo.caddat,
          cadfunnom          like isskfunc.funnom,
          atldat             like datkveiculo.atldat,
          funnom             like isskfunc.funnom,
          celdddcod          like datkveiculo.celdddcod,
          celtelnum          like datkveiculo.celtelnum,
          nxtdddcod          like datkveiculo.nxtdddcod,
          nxtide             like datkveiculo.nxtide,
          nxtnum             like datkveiculo.nxtnum,
          frtrpnflg          like dpaksocor.frtrpnflg,
          frtrpndes          char(20),
          rencod             like datkveiculo.rencod,
          vclcadorgcod       like datkveiculo.vclcadorgcod,
          vclcadorgdes       like iddkdominio.cpodes         
   end record

   define l_mensagem  char(3000)
         ,l_mensagem2 char(100)
	 ,l_flg      integer
	 ,l_stt      integer
         ,l_cmd      char(100)
         ,l_mensmail char(3000)
	 ,l_hora     datetime hour to minute

   let l_mensagem2 = 'Alteracao no cadastro do Veiculo. Codigo : ' ,
		     lr_ctc34m01.socvclcod
   let l_hora      = current hour to minute

   let l_mensmail = null

   if (lr_ctc34m01_ant.pstcoddig is null     and lr_ctc34m01.pstcoddig is not null) or
      (lr_ctc34m01_ant.pstcoddig is not null and lr_ctc34m01.pstcoddig is null)     or
      (lr_ctc34m01_ant.pstcoddig              <> lr_ctc34m01.pstcoddig)             then
      let l_mensagem = "Codigo do Prestador alterado de [",lr_ctc34m01_ant.pstcoddig clipped,"] para [",lr_ctc34m01.pstcoddig clipped,"]"

      let l_mensmail = l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then
	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vclctfnom is null     and lr_ctc34m01.vclctfnom is not null) or
      (lr_ctc34m01_ant.vclctfnom is not null and lr_ctc34m01.vclctfnom is null)     or
      (lr_ctc34m01_ant.vclctfnom              <> lr_ctc34m01.vclctfnom)             then
      let l_mensagem = "Nome do Proprietario alterado de [",lr_ctc34m01_ant.vclctfnom clipped,"] para [",lr_ctc34m01.vclctfnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then
	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc34m01_ant.socoprsitcod is null     and lr_ctc34m01.socoprsitcod is not null) or
      (lr_ctc34m01_ant.socoprsitcod is not null and lr_ctc34m01.socoprsitcod is null)     or
      (lr_ctc34m01_ant.socoprsitcod              <> lr_ctc34m01.socoprsitcod)             then
      let l_mensagem = "Situacao do Veiculo alterado de [",lr_ctc34m01_ant.socoprsitcod clipped,
          "-",lr_ctc34m01_ant.socoprsitdes clipped,"] para [",lr_ctc34m01.socoprsitcod clipped,"-",
          lr_ctc34m01_ant.socoprsitdes clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
      end if
   end if

   if (lr_ctc34m01_ant.vclaqstipcod is null     and lr_ctc34m01.vclaqstipcod is not null) or
      (lr_ctc34m01_ant.vclaqstipcod is not null and lr_ctc34m01.vclaqstipcod is null)     or
      (lr_ctc34m01_ant.vclaqstipcod              <> lr_ctc34m01.vclaqstipcod)             then
      let l_mensagem = "Tipo de Aquisicao alterado de [",lr_ctc34m01_ant.vclaqstipcod clipped,"] para [",lr_ctc34m01.vclaqstipcod clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vclaqsnom is null     and lr_ctc34m01.vclaqsnom is not null) or
      (lr_ctc34m01_ant.vclaqsnom is not null and lr_ctc34m01.vclaqsnom is null)     or
      (lr_ctc34m01_ant.vclaqsnom              <> lr_ctc34m01.vclaqsnom)             then
      let l_mensagem = "Nome da aquisicao alterado de [",lr_ctc34m01_ant.vclaqsnom clipped,"] para [",lr_ctc34m01.vclaqsnom clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vclcoddig is null     and lr_ctc34m01.vclcoddig is not null) or
      (lr_ctc34m01_ant.vclcoddig is not null and lr_ctc34m01.vclcoddig is null)     or
      (lr_ctc34m01_ant.vclcoddig              <> lr_ctc34m01.vclcoddig)             then
      let l_mensagem = "Descricao do veiculo alterado de [",lr_ctc34m01_ant.vclcoddig clipped,"] para [",lr_ctc34m01.vclcoddig clipped,"]"

      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.celdddcod is null     and lr_ctc34m01.celdddcod is not null) or
      (lr_ctc34m01_ant.celdddcod is not null and lr_ctc34m01.celdddcod is null)     or
      (lr_ctc34m01_ant.celdddcod              <> lr_ctc34m01.celdddcod)             then
      let l_mensagem = "DDD do Celular alterado de [",lr_ctc34m01_ant.celdddcod clipped,"] para [",lr_ctc34m01.celdddcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.celtelnum is null     and lr_ctc34m01.celtelnum is not null) or
      (lr_ctc34m01_ant.celtelnum is not null and lr_ctc34m01.celtelnum is null)     or
      (lr_ctc34m01_ant.celtelnum              <> lr_ctc34m01.celtelnum)             then
      let l_mensagem = "Numero do Celular alterado de [",lr_ctc34m01_ant.celtelnum clipped,"] para [",lr_ctc34m01.celtelnum clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.nxtdddcod is null     and lr_ctc34m01.nxtdddcod is not null) or
      (lr_ctc34m01_ant.nxtdddcod is not null and lr_ctc34m01.nxtdddcod is null)     or
      (lr_ctc34m01_ant.nxtdddcod              <> lr_ctc34m01.nxtdddcod)             then
      let l_mensagem = "DDD Nextel alterado de [",lr_ctc34m01_ant.nxtdddcod clipped,"] para [",lr_ctc34m01.nxtdddcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.nxtide is null     and lr_ctc34m01.nxtide is not null) or
      (lr_ctc34m01_ant.nxtide is not null and lr_ctc34m01.nxtide is null)     or
      (lr_ctc34m01_ant.nxtide              <> lr_ctc34m01.nxtide)             then
      let l_mensagem = "ID Nextel alterado de [",lr_ctc34m01_ant.nxtide clipped,"] para [",lr_ctc34m01.nxtide clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.nxtnum is null     and lr_ctc34m01.nxtnum is not null) or
      (lr_ctc34m01_ant.nxtnum is not null and lr_ctc34m01.nxtnum is null)     or
      (lr_ctc34m01_ant.nxtnum              <> lr_ctc34m01.nxtnum)             then
      let l_mensagem = "Número Nextel alterado de [",lr_ctc34m01_ant.nxtnum clipped,"] para [",lr_ctc34m01.nxtnum clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.socvcltip is null     and lr_ctc34m01.socvcltip is not null) or
      (lr_ctc34m01_ant.socvcltip is not null and lr_ctc34m01.socvcltip is null)     or
      (lr_ctc34m01_ant.socvcltip              <> lr_ctc34m01.socvcltip)             then
      let l_mensagem = "Tipo de Veiculo alterado de [",lr_ctc34m01_ant.socvcltip clipped,"] para [",lr_ctc34m01.socvcltip clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.chassi is null     and lr_ctc34m01.chassi is not null) or
      (lr_ctc34m01_ant.chassi is not null and lr_ctc34m01.chassi is null)     or
      (lr_ctc34m01_ant.chassi              <> lr_ctc34m01.chassi)             then
      let l_mensagem = "Chassi  alterado de [",lr_ctc34m01_ant.chassi clipped,"] para [",lr_ctc34m01.chassi clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vcllicnum is null     and lr_ctc34m01.vcllicnum is not null) or
      (lr_ctc34m01_ant.vcllicnum is not null and lr_ctc34m01.vcllicnum is null)     or
      (lr_ctc34m01_ant.vcllicnum              <> lr_ctc34m01.vcllicnum)             then
      let l_mensagem = "Placa do veiculo alterado de [",lr_ctc34m01_ant.vcllicnum clipped,"] para [",lr_ctc34m01.vcllicnum clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vclanofbc is null     and lr_ctc34m01.vclanofbc is not null) or
      (lr_ctc34m01_ant.vclanofbc is not null and lr_ctc34m01.vclanofbc is null)     or
      (lr_ctc34m01_ant.vclanofbc              <> lr_ctc34m01.vclanofbc)             then
      let l_mensagem = "Ano de Fabricacao alterado de [",lr_ctc34m01_ant.vclanofbc clipped,"] para [",lr_ctc34m01.vclanofbc clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vclanomdl is null     and lr_ctc34m01.vclanomdl is not null) or
      (lr_ctc34m01_ant.vclanomdl is not null and lr_ctc34m01.vclanomdl is null)     or
      (lr_ctc34m01_ant.vclanomdl              <> lr_ctc34m01.vclanomdl)             then
      let l_mensagem = "Ano do Modelo alterado de [",lr_ctc34m01_ant.vclanomdl clipped,"] para [",lr_ctc34m01.vclanomdl clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vclcorcod is null     and lr_ctc34m01.vclcorcod is not null) or
      (lr_ctc34m01_ant.vclcorcod is not null and lr_ctc34m01.vclcorcod is null)     or
      (lr_ctc34m01_ant.vclcorcod              <> lr_ctc34m01.vclcorcod)             then
      let l_mensagem = "Cor do Veiculo alterado de [",lr_ctc34m01_ant.vclcorcod clipped,"] para [",lr_ctc34m01.vclcorcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vclpnttip is null     and lr_ctc34m01.vclpnttip is not null) or
      (lr_ctc34m01_ant.vclpnttip is not null and lr_ctc34m01.vclpnttip is null)     or
      (lr_ctc34m01_ant.vclpnttip              <> lr_ctc34m01.vclpnttip)             then
      let l_mensagem = "Tipo da Pintura alterado de [",lr_ctc34m01_ant.vclpnttip clipped,"] para [",lr_ctc34m01.vclpnttip clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vclcmbcod is null     and lr_ctc34m01.vclcmbcod is not null) or
      (lr_ctc34m01_ant.vclcmbcod is not null and lr_ctc34m01.vclcmbcod is null)     or
      (lr_ctc34m01_ant.vclcmbcod              <> lr_ctc34m01.vclcmbcod)             then
      let l_mensagem = "Tipo do Combustivel alterado de [",lr_ctc34m01_ant.vclcmbcod clipped,"] para [",lr_ctc34m01.vclcmbcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.socctrposflg is null     and lr_ctc34m01.socctrposflg is not null) or
      (lr_ctc34m01_ant.socctrposflg is not null and lr_ctc34m01.socctrposflg is null)     or
      (lr_ctc34m01_ant.socctrposflg              <> lr_ctc34m01.socctrposflg)             then
      let l_mensagem = "Posicao Controlada alterado de [",lr_ctc34m01_ant.socctrposflg clipped,"] para [",lr_ctc34m01.socctrposflg clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.atdvclsgl is null     and lr_ctc34m01.atdvclsgl is not null) or
      (lr_ctc34m01_ant.atdvclsgl is not null and lr_ctc34m01.atdvclsgl is null)     or
      (lr_ctc34m01_ant.atdvclsgl              <> lr_ctc34m01.atdvclsgl)             then
      let l_mensagem = "Identificacao do veiculo alterado de [",lr_ctc34m01_ant.atdvclsgl clipped,"] para [",lr_ctc34m01.atdvclsgl clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.vcldtbgrpcod is null     and lr_ctc34m01.vcldtbgrpcod is not null) or
      (lr_ctc34m01_ant.vcldtbgrpcod is not null and lr_ctc34m01.vcldtbgrpcod is null)     or
      (lr_ctc34m01_ant.vcldtbgrpcod              <> lr_ctc34m01.vcldtbgrpcod)             then
      let l_mensagem = "Grupo de distribuicao alterado de [",lr_ctc34m01_ant.vcldtbgrpcod clipped,"] para [",lr_ctc34m01.vcldtbgrpcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.atdimpcod is null     and lr_ctc34m01.atdimpcod is not null) or
      (lr_ctc34m01_ant.atdimpcod is not null and lr_ctc34m01.atdimpcod is null)     or
      (lr_ctc34m01_ant.atdimpcod              <> lr_ctc34m01.atdimpcod)             then
      let l_mensagem = "Impressao  alterado de [",lr_ctc34m01_ant.atdimpcod clipped,"] para [",lr_ctc34m01.atdimpcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.mdtcod is null     and lr_ctc34m01.mdtcod is not null) or
      (lr_ctc34m01_ant.mdtcod is not null and lr_ctc34m01.mdtcod is null)     or
      (lr_ctc34m01_ant.mdtcod              <> lr_ctc34m01.mdtcod)             then
      let l_mensagem = "MDT  alterado de [",lr_ctc34m01_ant.mdtcod clipped,"] para [",lr_ctc34m01.mdtcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   #if (lr_ctc34m01_ant.gpsacngrpcod is null     and lr_ctc34m01.gpsacngrpcod is not null) or
   #   (lr_ctc34m01_ant.gpsacngrpcod is not null and lr_ctc34m01.gpsacngrpcod is null)     or
   #   (lr_ctc34m01_ant.gpsacngrpcod              <> lr_ctc34m01.gpsacngrpcod)             then
   #   let l_mensagem = "Grupo de Distribuicao alterado de [",lr_ctc34m01_ant.gpsacngrpcod clipped,"] para [",lr_ctc34m01.gpsacngrpcod clipped,"]"
   #   let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
   #   let l_flg = 1
   #
   #   if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
   #                             ,l_mensagem
   #                             ,today
   #                             ,l_mensagem2,"A") then
   #
	# let l_mensagem = "Erro gravacao Historico "
	# let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped
   #
   #   end if
   #end if

   if (lr_ctc34m01_ant.pgrnum is null     and lr_ctc34m01.pgrnum is not null) or
      (lr_ctc34m01_ant.pgrnum is not null and lr_ctc34m01.pgrnum is null)     or
      (lr_ctc34m01_ant.pgrnum              <> lr_ctc34m01.pgrnum)             then
      let l_mensagem = "Numero do Pager alterado de [",lr_ctc34m01_ant.pgrnum clipped,"] para [",lr_ctc34m01.pgrnum clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.socvstdiaqtd is null     and lr_ctc34m01.socvstdiaqtd is not null) or
      (lr_ctc34m01_ant.socvstdiaqtd is not null and lr_ctc34m01.socvstdiaqtd is null)     or
      (lr_ctc34m01_ant.socvstdiaqtd              <> lr_ctc34m01.socvstdiaqtd)             then
      let l_mensagem = "Periodicidade Vistoria alterado de [",lr_ctc34m01_ant.socvstdiaqtd clipped,"] para [",lr_ctc34m01.socvstdiaqtd clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then
	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.socvstlclcod is null     and lr_ctc34m01.socvstlclcod is not null) or
      (lr_ctc34m01_ant.socvstlclcod is not null and lr_ctc34m01.socvstlclcod is null)     or
      (lr_ctc34m01_ant.socvstlclcod              <> lr_ctc34m01.socvstlclcod)             then
      let l_mensagem = "Local da Vistoria alterado de [",lr_ctc34m01_ant.socvstlclcod clipped,"] para [",lr_ctc34m01.socvstlclcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then
	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   if (lr_ctc34m01_ant.socvstlautipcod is null     and lr_ctc34m01.socvstlautipcod is not null) or
      (lr_ctc34m01_ant.socvstlautipcod is not null and lr_ctc34m01.socvstlautipcod is null)     or
      (lr_ctc34m01_ant.socvstlautipcod              <> lr_ctc34m01.socvstlautipcod)             then
      let l_mensagem = "Tipo de Laudo vistoria alterado de [",lr_ctc34m01_ant.socvstlautipcod clipped,"] para [",lr_ctc34m01.socvstlautipcod clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   #=====================================
   # Grava Renavam
   #=====================================
   if (lr_ctc34m01_ant.rencod  is null     and lr_ctc34m01.rencod  is not null) or
      (lr_ctc34m01_ant.rencod  is not null and lr_ctc34m01.rencod  is null)     or
      (lr_ctc34m01_ant.rencod               <> lr_ctc34m01.rencod )             then
      let l_mensagem = "Renavam alterado de [",lr_ctc34m01_ant.rencod  clipped,"] para [",lr_ctc34m01.rencod  clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if

   #=====================================
   # Grava Oriem do cadastro da viatura
   #=====================================
   if (lr_ctc34m01_ant.vclcadorgdes  is null     and lr_ctc34m01.vclcadorgdes  is not null) or
      (lr_ctc34m01_ant.vclcadorgdes  is not null and lr_ctc34m01.vclcadorgdes  is null)     or
      (lr_ctc34m01_ant.vclcadorgdes               <> lr_ctc34m01.vclcadorgdes )             then
      let l_mensagem = "Tipo de cadastro alterado de [",lr_ctc34m01_ant.vclcadorgdes  clipped,"] para [",lr_ctc34m01.vclcadorgdes  clipped,"]"
      let l_mensmail = l_mensmail clipped," ",l_mensagem clipped
      let l_flg = 1

      if not ctc34m01_grava_hist(lr_ctc34m01.socvclcod
                                ,l_mensagem
                                ,today
                                ,l_mensagem2,"A") then

	 let l_mensagem = "Erro gravacao Historico "
	 let l_mensmail = l_mensmail clipped, " ",l_mensagem clipped

      end if
   end if


   if l_mensmail is not null then
      call ctc34m01_envia_email(l_mensagem2,today ,
                             current hour to minute, l_mensmail)
	    returning l_stt
   end if

end function

#------------------------------------------------
function ctc34m01_envia_email(lr_param)
#------------------------------------------------

  define lr_param record
          titulo     char(100)
         ,data       date
         ,hora       datetime hour to minute
         ,mensmail   char(2000)
  end record

  define l_stt       smallint
	,l_path      char(100)
	,l_cmd       char(100)
	,l_mensmail2 like dbsmhstprs.prshstdes
	,l_erro
	,l_count
	,l_iter
	,l_length
	,l_length2    smallint

   let l_stt  = true
   let l_path = null

   call ctb85g01_mtcorpo_email_html('CTC34M01',
                                    lr_param.data,
                                    lr_param.hora,
                                    g_issk.empcod,
                                    g_issk.usrtip,
                                    g_issk.funmat,
                                    lr_param.titulo,
                                    lr_param.mensmail)
               returning l_erro

    if l_erro  <> 0 then
	error 'Erro no envio do e-mail' sleep 2
	let l_stt = false
     else
	let l_stt = true
    end if

    return l_stt

end function

