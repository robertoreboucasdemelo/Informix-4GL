#############################################################################
# Nome do Modulo: CTB02M01                                         Wagner   #
#                                                                           #
# Ordem de pagamento - Carro-extra                                 Out/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 12/04/2005  PSI 191167   Helio (Meta) Unificacao do acesso as tabelas de  #
#                                       centro de custos                    #
# 20/07/2006 Cristiane Silva PSI197858 Chamada de tela de Descontos via menu# 
#                                      e retirada do tipo e valor de des-   #
#                                      conto da tela.                       #
#---------------------------------------------------------------------------#
# 12/12/2006 Priscila Staingel PSI205206 Exibir se a OP é da Azul ou Porto  #
#                                        sendo q todos os itens da OP devem #
#                                        ser da mesma empresa               #
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel  #
#---------------------------------------------------------------------------#
# 27/05/2008  Chamado: 80511944         Implementado regra de bloqueio de   #
#             Andre Oliveira            cancelamento apos data de Pagamento #
# 24/06/2008  PSI 198404 Ligia Mattge   Retirado o Centro de custo incluido #
#                                       a sucursal                          #
# 26/01/2009             Raji           Tratativa NFE                       #
# 27/05/2009  PSI198404  Fabio Costa  Impedir edicao de OP com status 10 e  #
#                                     11, digitar NF e gravar nos itens,    #
#                                     cancelamento de OP People             #
# 29/07/2009  PSI198404  Fabio Costa  Permitir digitacao de sucursal para   #
#                                     OP de reembolso                       #
# 08/02/2010  PSI198404  Fabio Costa  Validacoes do relatorio bdbsr116 na OP#
#                                     Azul antes de status "Ok para emissao"#
# 26/04/2010  PSI198404  Fabio Costa  Tratar reembolso segurado Azul, tipo  #
#                                     favorecido, NFS na OP, verific. NFS   #
# 30/05/2012  PSI-11-19199PR Jose Kurihara Incluir campo Optante Simples e  #
#                                          aliquota do ISS                  #
#                                          registrar mudanca ISS historico  #
#############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_opg record
       lcvcod     like datkavislocal.lcvcod   ,
       aviestcod  like datkavislocal.aviestcod,
       soctip     like dbsmopg.soctip
end record

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record

define mr_retSAP record                                       
        stt    integer                                     
       ,msg    char(100)                                   
end record 

#------------------------------------------------------------
function ctb02m01()
#------------------------------------------------------------

 define ctb02m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab1       char (14),
    favtipcod1       char (08),
    favtipnom1       char (40),
    favtipcab2       char (14),
    favtipcod2       char (08),
    favtipnom2       char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#PSI197858 - inicio
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (10),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
#PSI197858 - fim
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    opgpestip        like dbsmopg.pestip   ,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    ciaempcod        like datmservico.ciaempcod, 
    corsus           like dbsmopg.corsus,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define k_ctb02m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

#if not get_niv_mod(g_issk.prgsgl, "ctb02m01") then
#   error " Modulo sem nivel de consulta e atualizacao!"
#   return
#end if

 let int_flag = false
 
 initialize m_opg.* to null
 initialize ctb02m01.*   to  null
 initialize k_ctb02m01.* to  null

 open window ctb02m01 at 04,02 with form "ctb02m01"

 menu "O.P."

    before menu
       hide option all
#      if g_issk.acsnivcod >= g_issk.acsnivcns  then          # NIVEL 1
#         show option "Seleciona", "Proximo", "Anterior", "Fases"
#      end if
#      if g_issk.acsnivcod  =  3   then                       # NIVEL 3
#         show option "Seleciona", "Proximo", "Anterior",
#                     "Itens", "Fases"
#      end if
#      if g_issk.acsnivcod >=  5   then                       # NIVEL 5
          show option "Seleciona", "Proximo", "Anterior", "Modifica",
                      "Itens", "Descontos", "Fases", "Obs", "Totais", "contaBil"
#      end if
#      if g_issk.acsnivcod  =  8   then                       # NIVEL 8
          show option "Cancela"
#      end if
#      if g_issk.acsnivcod  =  8   then                       # NIVEL 8
#         show option "Remove"
#      end if
       show option "Encerra"

   command key ("S") "Seleciona"
                     "Pesquisa ordem de pagamento conforme criterios"
       call seleciona_ctb02m01() returning k_ctb02m01.*, ctb02m01.*
       if k_ctb02m01.socopgnum is not null  then
          message ""
          next option "Proximo"
       else
          error " Nenhuma ordem de pagamento selecionada!"
          message ""
          next option "Seleciona"
       end if

   command key ("P") "Proximo"
                     "Mostra proxima ordem de pagamento"
       message ""
       if k_ctb02m01.socopgnum is not null then
          call proximo_ctb02m01(k_ctb02m01.*)
               returning k_ctb02m01.*, ctb02m01.*
       else
          error " Nenhuma ordem de pagamento nesta direcao!"
          next option "Seleciona"
       end if

   command key ("A") "Anterior"
                     "Mostra ordem de pagamento anterior"
       message ""
       if k_ctb02m01.socopgnum is not null then
          call anterior_ctb02m01(k_ctb02m01.*)
               returning k_ctb02m01.*, ctb02m01.*
       else
          error " Nenhuma ordem de pagamento nesta direcao!"
          next option "Seleciona"
       end if

   command key ("M") "Modifica"
                     "Modifica ordem de pagamento selecionada"
       message ""
       if k_ctb02m01.socopgnum is not null
          then
          case ctb02m01.socopgsitcod
             when 7
                error " Ordem de pagamento emitida nao deve ser alterada!" 
             when 8
                error " Ordem de pagamento cancelada nao deve ser alterada!"
             when 10
                error " Ordem de pagamento nao deve ser alterada, aguardando emissão PEOPLE! "
             when 11
                error " Ordem de pagamento nao deve ser alterada, aguardando cancelamento PEOPLE! "
             otherwise
                call modifica_ctb02m01(k_ctb02m01.*, ctb02m01.*)
                     returning k_ctb02m01.*
                initialize ctb02m01.*     to null
                initialize k_ctb02m01.*   to null
                clear form
                next option "Seleciona"
          end case
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if
       
   command key ("I") "Itens"
                     "Itens da ordem de pagamento selecionada"
       message ""
       if k_ctb02m01.socopgnum is not null then
          if ctb02m01.socopgsitcod  >  1 then
             if ctb02m01.socopgsitcod  <>  7  and
                ctb02m01.socopgsitcod  <>  8  and
                ctb02m01.socopgsitcod  <>  10
                then
                if dias_uteis(ctb02m01.socfatpgtdat, 0, "", "S", "S") = ctb02m01.socfatpgtdat  
                   then
                else
                   if ctb02m01.socfatpgtdat  <>  "18/10/1999"  
                      then
                      error " Pagamento nao deve ser programado para FERIADO!"
                      initialize ctb02m01.*     to null
                      initialize k_ctb02m01.*   to null
                      next option "Seleciona"
                   end if
                end if

                if dias_entre_datas (today, ctb02m01.socfatpgtdat, "", "S", "S") <= 2  then
                   error " Pagamento deve ser programado c/ 2 DIAS DE ANTECEDENCIA!"
                   initialize ctb02m01.*     to null
                   initialize k_ctb02m01.*   to null
                   next option "Seleciona"
                else
                   call ctb02m06(k_ctb02m01.*)  #-> Manut.itens
                   initialize ctb02m01.*     to null
                   initialize k_ctb02m01.*   to null
                   next option "Seleciona"
                end if
             else
                call ctb02m10(k_ctb02m01.*,"","","","")   #-> Consulta itens
             end if
          else
             error " Ordem de pagamento nao analisada!"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if
       
   #PSI197858 - inicio
   command key ("D") "Descontos"
                     "Descontos da ordem de pagamento selecionada"
       message ""
       if k_ctb02m01.socopgnum is not null then
          call ctc81m00(k_ctb02m01.*)
          next option "Seleciona"
       else
          error "Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if
   #PSI197858 - fim
  
   command key ("O") "Obs"
                     "Observacoes da ordem de pagamento selecionada"
       message ""
       if k_ctb02m01.socopgnum is not null then
          call ctb11m03(k_ctb02m01.*)
          next option "Seleciona"
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("F") "Fases"
                     "Fases da ordem de pagamento selecionada"
       message ""
       if k_ctb02m01.socopgnum is not null then
          call ctb11m02(k_ctb02m01.*)
          next option "Seleciona"
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("T") "Totais"
                     "Totaliza itens da ordem de pagamento selecionada por tipo de servico"
       message ""
       if k_ctb02m01.socopgnum is not null then
          if ctb02m01.socopgsitcod  =  7  or
             ctb02m01.socopgsitcod  =  8  
             then
             if ctb02m01.socfatpgtdat < (today - 365 units day) and
                g_issk.funmat <> 7574 
                then
                error " Consulta nao disponivel para O.P. emitida a mais de 365 dias"
                next option "Seleciona"
             else
                call ctb02m11(k_ctb02m01.*)
                next option "Seleciona"
             end if
          else
             call ctb02m11(k_ctb02m01.*)
             next option "Seleciona"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("B") "contaBil"
                     "Contabilizacao da ordem de pagamento selecionada"
       message ""
       if k_ctb02m01.socopgnum is not null then
          if ctb02m01.socfatpgtdat  >  "04/01/1998"   then
             if ctb02m01.socopgsitcod  =  7   then
                call ctb11m14(k_ctb02m01.*)
                next option "Seleciona"
             else
                error " Ordem de pagamento nao emitida!"
                next option "Seleciona"
             end if
          else
             error " Ordem de pagamento contabilizada pelo micro!"
             next option "Seleciona"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

   command key ("C") "Cancela"
                     "Cancela ordem de pagamento selecionada"
       message ""
       if k_ctb02m01.socopgnum is not null then
          if ctb02m01.socopgsitcod  <>  8  then
             call cancela_ctb02m01(k_ctb02m01.*)
                  returning k_ctb02m01.*
             next option "Seleciona"
          else
             error " Ordem de pagamento ja' cancelada!"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if

#  command key ("R") "Remove"
#                    "Remove ordem de pagamento selecionada"
#      message ""
#      if k_ctb02m01.socopgnum is not null then
#         if ctb02m01.socopgsitcod  <>  7  then
#            call remove_ctb02m01(k_ctb02m01.*)
#                 returning k_ctb02m01.*
#            next option "Seleciona"
#         else
#            error " Ordem de pagamento ja' emitida nao deve ser removida!"
#         end if
#      else
#         error " Nenhuma ordem de pagamento selecionada!"
#         next option "Seleciona"
#      end if

   command key (interrupt,"E") "Encerra" "Retorna ao menu anterior"
       exit menu
 end menu

 close window ctb02m01

end function  ###  ctb02m01

#------------------------------------------------------------
function seleciona_ctb02m01()
#------------------------------------------------------------

 define ctb02m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab1       char (14),
    favtipcod1       char (08),
    favtipnom1       char (40),
    favtipcab2       char (14),
    favtipcod2       char (08),
    favtipnom2       char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    opgpestip        like dbsmopg.pestip   ,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    ciaempcod        like datmservico.ciaempcod,     
    corsus           like dbsmopg.corsus,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define k_ctb02m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   clear form
   let int_flag = false
   initialize  ctb02m01.*  to null

   input by name k_ctb02m01.socopgnum

      before field socopgnum
          display by name k_ctb02m01.socopgnum attribute (reverse)

          if k_ctb02m01.socopgnum is null then
             let k_ctb02m01.socopgnum = 0
          end if

      after  field socopgnum
          display by name k_ctb02m01.socopgnum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb02m01.*   to null
      initialize k_ctb02m01.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb02m01.*, ctb02m01.*
   end if

   if k_ctb02m01.socopgnum  =  0   then
      select min (socopgnum)
        into k_ctb02m01.socopgnum
        from dbsmopg
       where socopgnum > k_ctb02m01.socopgnum
         and soctip    = 2

      display by name k_ctb02m01.socopgnum
   end if

   call ler_ctb02m01(k_ctb02m01.*)  returning  ctb02m01.*
   #PSI197858 - inicio
   if ctb02m01.socopgnum  is not null    then
      display by name ctb02m01.socopgnum,
                      ctb02m01.socopgsitcod ,
                      ctb02m01.socopgsitdes ,
                      ctb02m01.favtipcab1   ,
                      ctb02m01.favtipcod1   ,
                      ctb02m01.favtipnom1   ,
                      ctb02m01.favtipcab2   ,
                      ctb02m01.favtipcod2   ,
                      ctb02m01.favtipnom2   ,
                      ctb02m01.socfatentdat ,
                      ctb02m01.socfatpgtdat ,
                      ctb02m01.socfatrelqtd ,
                      ctb02m01.socfatitmqtd ,
                      ctb02m01.socfattotvlr ,
                      ctb02m01.soctrfcod    ,
                      ctb02m01.socpgtdoctip ,
                      ctb02m01.socpgtdocdes ,
                      ctb02m01.succod       ,
                      ctb02m01.sucnom       ,
                      ctb02m01.socemsnfsdat ,
                      ctb02m01.socpgtopccod ,
                      ctb02m01.socpgtopcdes ,
                      ctb02m01.pgtdstcod    ,
                      ctb02m01.pgtdstdes    ,
                      ctb02m01.socopgfavnom ,
                      ctb02m01.pestip       ,
                      ctb02m01.cgccpfnum    ,
                      ctb02m01.cgcord       ,
                      ctb02m01.cgccpfdig    ,
                      ctb02m01.bcoctatip    ,
                      ctb02m01.bcoctatipdes ,
                      ctb02m01.bcocod       ,
                      ctb02m01.bcosgl       ,
                      ctb02m01.bcoagnnum    ,
                      ctb02m01.bcoagndig    ,
                      ctb02m01.bcoagnnom    ,
                      ctb02m01.bcoctanum    ,
                      ctb02m01.bcoctadig    ,
                      ctb02m01.socopgdscvlr ,
                      ctb02m01.nfsnum       ,
                      ctb02m01.fisnotsrenum ,  #Fornax - Quantum
                      ctb02m01.infissalqvlr        # PSI-11-19199PR

      display by name ctb02m01.empresa attribute (reverse)      #PSI 205206
   else
      error " Ordem de pagamento nao cadastrada!"
      initialize ctb02m01.*    to null
      initialize k_ctb02m01.*  to null
   end if
   #PSI197858 - fim
   return k_ctb02m01.*, ctb02m01.*

end function  ###  seleciona_ctb02m01

#------------------------------------------------------------
function proximo_ctb02m01(k_ctb02m01)
#------------------------------------------------------------

 define ctb02m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab1       char (14),
    favtipcod1       char (08),
    favtipnom1       char (40),
    favtipcab2       char (14),
    favtipcod2       char (08),
    favtipnom2       char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#PSI197858 - inicio
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (10),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
#PSI197858 - fim
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    opgpestip        like dbsmopg.pestip   ,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    ciaempcod        like datmservico.ciaempcod,   
    corsus           like dbsmopg.corsus,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define k_ctb02m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   initialize ctb02m01.*   to null

   select min (socopgnum)
     into ctb02m01.socopgnum
     from dbsmopg
    where socopgnum > k_ctb02m01.socopgnum
      and soctip    = 2

   if ctb02m01.socopgnum  is not null   then
      let k_ctb02m01.socopgnum = ctb02m01.socopgnum
      call ler_ctb02m01(k_ctb02m01.*)  returning  ctb02m01.*
      if ctb02m01.socopgnum  is not null    then
         display by name ctb02m01.socopgnum,
                      ctb02m01.socopgsitcod ,
                      ctb02m01.socopgsitdes ,
                      ctb02m01.favtipcab1   ,
                      ctb02m01.favtipcod1   ,
                      ctb02m01.favtipnom1   ,
                      ctb02m01.favtipcab2   ,
                      ctb02m01.favtipcod2   ,
                      ctb02m01.favtipnom2   ,
                      ctb02m01.socfatentdat ,
                      ctb02m01.socfatpgtdat ,
                      ctb02m01.socfatrelqtd ,
                      ctb02m01.socfatitmqtd ,
                      ctb02m01.socfattotvlr ,
                      ctb02m01.soctrfcod    ,
                      ctb02m01.socpgtdoctip ,
                      ctb02m01.socpgtdocdes ,
                      ctb02m01.succod       ,
                      ctb02m01.sucnom       ,
                      ctb02m01.socemsnfsdat ,
                      ctb02m01.socpgtopccod ,
                      ctb02m01.socpgtopcdes ,
                      ctb02m01.pgtdstcod    ,
                      ctb02m01.pgtdstdes    ,
                      ctb02m01.socopgfavnom ,
                      ctb02m01.pestip       ,
                      ctb02m01.cgccpfnum    ,
                      ctb02m01.cgcord       ,
                      ctb02m01.cgccpfdig    ,
                      ctb02m01.bcoctatip    ,
                      ctb02m01.bcoctatipdes ,
                      ctb02m01.bcocod       ,
                      ctb02m01.bcosgl       ,
                      ctb02m01.bcoagnnum    ,
                      ctb02m01.bcoagndig    ,
                      ctb02m01.bcoagnnom    ,
                      ctb02m01.bcoctanum    ,
                      ctb02m01.bcoctadig    ,
                      ctb02m01.socopgdscvlr ,
                      ctb02m01.nfsnum       ,
                      ctb02m01.fisnotsrenum ,  #Fornax - Quantum
                      ctb02m01.infissalqvlr         # PSI-11-19199PR

         display by name ctb02m01.empresa attribute (reverse)      #PSI 205206
      else
         error " Nao ha' ordem de pagamento nesta direcao!"
         initialize ctb02m01.*    to null
         initialize k_ctb02m01.*  to null
      end if
   else
      error " Nao ha' ordem de pagamento nesta direcao!"
      initialize ctb02m01.*    to null
      initialize k_ctb02m01.*  to null
   end if
   return k_ctb02m01.*, ctb02m01.*

end function  ###  proximo_ctb02m01

#------------------------------------------------------------
function anterior_ctb02m01(k_ctb02m01)
#------------------------------------------------------------

 define ctb02m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab1       char (14),
    favtipcod1       char (08),
    favtipnom1       char (40),
    favtipcab2       char (14),
    favtipcod2       char (08),
    favtipnom2       char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (10),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    opgpestip        like dbsmopg.pestip   ,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    ciaempcod        like datmservico.ciaempcod,    
    corsus           like dbsmopg.corsus,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define k_ctb02m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   let int_flag = false
   initialize ctb02m01.*  to null

   select max (socopgnum)
     into ctb02m01.socopgnum
     from dbsmopg
    where socopgnum < k_ctb02m01.socopgnum
      and soctip    = 2

   if ctb02m01.socopgnum  is  not  null  then
      let k_ctb02m01.socopgnum = ctb02m01.socopgnum
      call ler_ctb02m01(k_ctb02m01.*)  returning  ctb02m01.*

      if ctb02m01.socopgnum  is not null    then
         display by name ctb02m01.socopgnum,
                      ctb02m01.socopgsitcod ,
                      ctb02m01.socopgsitdes ,
                      ctb02m01.favtipcab1   ,
                      ctb02m01.favtipcod1   ,
                      ctb02m01.favtipnom1   ,
                      ctb02m01.favtipcab2   ,
                      ctb02m01.favtipcod2   ,
                      ctb02m01.favtipnom2   ,
                      ctb02m01.socfatentdat ,
                      ctb02m01.socfatpgtdat ,
                      ctb02m01.socfatrelqtd ,
                      ctb02m01.socfatitmqtd ,
                      ctb02m01.socfattotvlr ,
                      ctb02m01.soctrfcod    ,
                      ctb02m01.socpgtdoctip ,
                      ctb02m01.socpgtdocdes ,
                      ctb02m01.succod       ,
                      ctb02m01.sucnom       ,
                      ctb02m01.socemsnfsdat ,
                      ctb02m01.socpgtopccod ,
                      ctb02m01.socpgtopcdes ,
                      ctb02m01.pgtdstcod    ,
                      ctb02m01.pgtdstdes    ,
                      ctb02m01.socopgfavnom ,
                      ctb02m01.pestip       ,
                      ctb02m01.cgccpfnum    ,
                      ctb02m01.cgcord       ,
                      ctb02m01.cgccpfdig    ,
                      ctb02m01.bcoctatip    ,
                      ctb02m01.bcoctatipdes ,
                      ctb02m01.bcocod       ,
                      ctb02m01.bcosgl       ,
                      ctb02m01.bcoagnnum    ,
                      ctb02m01.bcoagndig    ,
                      ctb02m01.bcoagnnom    ,
                      ctb02m01.bcoctanum    ,
                      ctb02m01.bcoctadig    ,
                      ctb02m01.socopgdscvlr ,
                      ctb02m01.nfsnum       ,
                      ctb02m01.fisnotsrenum ,  #Fornax - Quantum
                      ctb02m01.infissalqvlr       # PSI-11-19199PR

         display by name ctb02m01.empresa attribute (reverse)      #PSI 205206
      else
         error " Nao ha' ordem de pagamento nesta direcao!"
         initialize ctb02m01.*    to null
         initialize k_ctb02m01.*  to null
      end if
   else
      error " Nao ha' ordem de pagamento nesta direcao!"
      initialize ctb02m01.*    to null
      initialize k_ctb02m01.*  to null
   end if

   return k_ctb02m01.*, ctb02m01.*

end function  ###  anterior_ctb02m01

#------------------------------------------------------------
function modifica_ctb02m01(k_ctb02m01, ctb02m01)
#------------------------------------------------------------

 define ctb02m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab1       char (14),
    favtipcod1       char (08),
    favtipnom1       char (40),
    favtipcab2       char (14),
    favtipcod2       char (08),
    favtipnom2       char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (10),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    opgpestip        like dbsmopg.pestip   ,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    ciaempcod        like datmservico.ciaempcod,  
    corsus           like dbsmopg.corsus,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define k_ctb02m01   record
   socopgnum        like dbsmopg.socopgnum
 end record
 
 define ws           record
    achfavflg        char (01),
    achtrbflg        char (01),
    retorno          smallint,
    mensagem         char(60),
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record
 
 define lr_retorno record
        retorno   smallint,      
        mensagem  char(60)         
 end record
 
 define l_sqlca   integer , 
        l_sqlerr    integer,
        l_historico char(300),
        l_codaux    smallint

   let l_historico     = null
   let l_codaux        = null
   let ws.infissalqvlr = ctb02m01.infissalqvlr          # PSI-11-19199PR

   call input_ctb02m01("a", k_ctb02m01.* , ctb02m01.*) returning ctb02m01.*

   if int_flag  then
      let int_flag = false
      initialize k_ctb02m01.*  to null
      initialize ctb02m01.*    to null
      error " Operacao cancelada!"
      clear form
      return k_ctb02m01.*
   end if

   let ws.achfavflg = "N"
   let ws.achtrbflg = "N"

   select socopgnum from dbsmopgfav
    where socopgnum = k_ctb02m01.socopgnum

   if sqlca.sqlcode = 0  then
      let ws.achfavflg = "S"
   end if

#  select socopgnum from dbsmopgtrb
#   where socopgnum = k_ctb02m01.socopgnum

   if sqlca.sqlcode = 0  then
      let ws.achtrbflg = "S"
   end if

   if ws.achfavflg = "N"  then
      let ctb02m01.socopgsitcod = 2
   end if
   
   whenever error continue
   
   begin work
   
      # empcod retirado do update, empresa da OP deve ser definida no protocolo
      # ou na geracao automatica
      update dbsmopg  set (empcod,
                           succod,
                           cctcod,
                           socemsnfsdat,
                           socpgtdoctip,
                           pgtdstcod,
                           socopgsitcod,
                           atldat,
                           funmat,
                           nfsnum,
                           fisnotsrenum, #Fornax - Quantum
                           favtip,
                           infissalqvlr)
                       =  (ctb02m01.empcod,
                           ctb02m01.succod,
                           12243,
                           ctb02m01.socemsnfsdat,
                           ctb02m01.socpgtdoctip,
                           ctb02m01.pgtdstcod,
                           ctb02m01.socopgsitcod,
                           today,
                           g_issk.funmat,
                           ctb02m01.nfsnum,
                           ctb02m01.fisnotsrenum,  #Fornax - Quantum
                           ctb02m01.favtip,
                           ctb02m01.infissalqvlr)      # PSI-11-19199PR
      where dbsmopg.socopgnum  =  k_ctb02m01.socopgnum

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao da ordem de pagamento!"
         rollback work
         initialize ctb02m01.*   to null
         initialize k_ctb02m01.* to null
         return k_ctb02m01.*
      end if
      
      if ws.achfavflg = "S"  then
         update dbsmopgfav  set (socopgfavnom,
                                 socpgtopccod,
                                 pestip,
                                 cgccpfnum,
                                 cgcord,
                                 cgccpfdig,
                                 bcoctatip,
                                 bcocod,
                                 bcoagnnum,
                                 bcoagndig,
                                 bcoctanum,
                                 bcoctadig)
                             =  (ctb02m01.socopgfavnom,
                                 ctb02m01.socpgtopccod,
                                 ctb02m01.pestip,
                                 ctb02m01.cgccpfnum,
                                 ctb02m01.cgcord,
                                 ctb02m01.cgccpfdig,
                                 ctb02m01.bcoctatip,
                                 ctb02m01.bcocod,
                                 ctb02m01.bcoagnnum,
                                 ctb02m01.bcoagndig,
                                 ctb02m01.bcoctanum,
                                 ctb02m01.bcoctadig)
            where dbsmopgfav.socopgnum  =  k_ctb02m01.socopgnum

         if sqlca.sqlcode <>  0  then
            error " Erro (",sqlca.sqlcode,") na alteracao do favorecido!"
            rollback work
            initialize ctb02m01.*   to null
            initialize k_ctb02m01.* to null
            return k_ctb02m01.*
         end if
      else
         insert into dbsmopgfav (socopgnum,
                                 socopgfavnom,
                                 socpgtopccod,
                                 pestip,
                                 cgccpfnum,
                                 cgcord,
                                 cgccpfdig,
                                 bcoctatip,
                                 bcocod,
                                 bcoagnnum,
                                 bcoagndig,
                                 bcoctanum,
                                 bcoctadig)
                        values  (ctb02m01.socopgnum,
                                 ctb02m01.socopgfavnom,
                                 ctb02m01.socpgtopccod,
                                 ctb02m01.pestip,
                                 ctb02m01.cgccpfnum,
                                 ctb02m01.cgcord,
                                 ctb02m01.cgccpfdig,
                                 ctb02m01.bcoctatip,
                                 ctb02m01.bcocod,
                                 ctb02m01.bcoagnnum,
                                 ctb02m01.bcoagndig,
                                 ctb02m01.bcoctanum,
                                 ctb02m01.bcoctadig)

         if sqlca.sqlcode <>  0  then
            error " Erro (",sqlca.sqlcode,") na inclusao do favorecido!"
            rollback work
            initialize ctb02m01.*   to null
            initialize k_ctb02m01.* to null
            return k_ctb02m01.*
         end if

         # PSI 211074 - BURINI
         call cts50g00_insere_etapa(ctb02m01.socopgnum, 2, g_issk.funmat)
              returning ws.retorno,
                        ws.mensagem

         if ws.retorno <>  1   then
            error " Erro (",sqlca.sqlcode,") na inclusao da fase!"
            rollback work
            initialize ctb02m01.*   to null
            initialize k_ctb02m01.* to null
            return k_ctb02m01.*
         end if
      end if
      
      # update NFSNUM nos itens das OP
      if ctb02m01.nfsnum is not null and
         ctb02m01.nfsnum > 0
         then
         
         call ctd20g01_upd_nfs_opgitm(k_ctb02m01.socopgnum, 
                                      ctb02m01.socopgsitcod,
                                      ctb02m01.nfsnum)
              returning l_sqlca, l_sqlerr
              
         if l_sqlca != 0
            then
            if l_sqlca != 100
               then
               if l_sqlca = 99
                  then
                  error " Não permitido alterar Documento Fiscal nesta OP "
                  sleep 2
               else
                  error " Erro na atualização da Nota Fiscal: ", l_sqlca
                  rollback work
                  initialize ctb02m01.*   to null
                  initialize k_ctb02m01.* to null
                  return k_ctb02m01.*
               end if
            end if
         else
            if sqlca.sqlerrd[3] = 0
               then
               error " OP ainda não possui itens, Documento Fiscal não gravado "
               sleep 1
            else
               error " Atualização do Documento Fiscal ok em ", l_sqlerr, " itens"
               sleep 1
               
               # num de NF gravado nos itens, atualiza etapa para "Digitada"
               call cts50g00_atualiza_etapa(k_ctb02m01.socopgnum, 3, 
                                            g_issk.funmat)
                                  returning lr_retorno.retorno,
                                            lr_retorno.mensagem
                                            
               if lr_retorno.retorno != 1
                  then
                  error lr_retorno.mensagem
                  sleep 2
                  rollback work
                  initialize ctb02m01.*   to null
                  initialize k_ctb02m01.* to null
                  return k_ctb02m01.*
               end if
            end if
            
         end if
      end if
      
      #--> ini PSI-11-19199PR Registrar historico alteracao aliquota ISS
      #
      if (ws.infissalqvlr is null and ctb02m01.infissalqvlr is not null) then
#########let l_historico = "nao gravar"     # conf. Sergio Burini
      else
         if (ws.infissalqvlr is not null and ctb02m01.infissalqvlr is null) then
            let l_historico = "Alteração aliquota ISS de ", ws.infissalqvlr using "-<<<<<<<<&.&&", " para 0.00"
         else
            if ws.infissalqvlr <> ctb02m01.infissalqvlr then
               let l_historico = "Alteração aliquota ISS de ", ws.infissalqvlr using "-<<<<<<<<&.&&", " para ", ctb02m01.infissalqvlr using "-<<<<<<<<&.&&"
            end if
         end if
      end if

      if l_historico is not null then
         call ctc00m24_logarHistoricoOrdPg( k_ctb02m01.socopgnum
                                          , l_historico
                                          , g_issk.empcod
                                          , g_issk.usrtip
                                          , g_issk.funmat
                                          , g_issk.funnom        )
            returning lr_retorno.retorno
                    , lr_retorno.mensagem
                    , l_codaux

         if lr_retorno.mensagem is not null then
            error lr_retorno.mensagem; sleep 2
            rollback work
            initialize ctb02m01.*   to null
            initialize k_ctb02m01.* to null
            return k_ctb02m01.*
         end if
      end if #--> fim PSI-11-19199PR

      error " Alteracao efetuada com sucesso!"
      sleep 1

   commit work
   
   call ctb02m09(ctb02m01.socopgnum, m_opg.lcvcod, m_opg.aviestcod, ctb02m01.segnumdig)
   
   whenever error stop

   return k_ctb02m01.*

end function  ###  modifica_ctb02m01

#--------------------------------------------------------------------
function input_ctb02m01(operacao_aux, k_ctb02m01, ctb02m01)
#--------------------------------------------------------------------

 define operacao_aux char (01)

 define k_ctb02m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

 define ctb02m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab1       char (14),
    favtipcod1       char (08),
    favtipnom1       char (40),
    favtipcab2       char (14),
    favtipcod2       char (08),
    favtipnom2       char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (10),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    opgpestip        like dbsmopg.pestip   ,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    ciaempcod        like datmservico.ciaempcod,   
    corsus           like dbsmopg.corsus,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define ws           record
    confirma         char (01),
    bcoagnnum        like gcdkbancoage.bcoagnnum,
    bcoagndig        like gcdkbancoage.bcoagndig,
    cgccpfdig        like dbsmopg.cgccpfdig,
    pstsrvtip        like dpatserv.pstsrvtip,
    psttaxflg        smallint,
    pestip           like dpaksocor.pestip,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socfavnomcad     like dpaksocorfav.socfavnom,
    pestipcad        like dpaksocorfav.pestip,
    cgccpfnumcad     like dpaksocorfav.cgccpfnum,
    cgcordcad        like dpaksocorfav.cgcord,
    cgccpfdigcad     like dpaksocorfav.cgccpfdig,
    confirma2        char (01),
    prscootipcod     like dpaksocor.prscootipcod,
    socpgtopccod_svl like dbsmopgfav.socpgtopccod,
    soctip           like dbsmopg.soctip,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define lr_param     record     #PSI 191167
    empcod           like ctgklcl.empcod       #Empresa
   ,succod           like ctgklcl.succod       #Sucursal
   ,cctlclcod        like ctgklcl.cctlclcod    #Local
   ,cctdptcod        like ctgrlcldpt.cctdptcod #Departamento
 end record

 define lr_ret       record     #PSI 191167
    erro             smallint                     # 0-Ok, 1-erro
   ,mens             char(40)
   ,cctlclnom        like ctgklcl.cctlclnom       #Nome do local
   ,cctdptnom        like ctgkdpt.cctdptnom       #Nome do dep.(antigo cctnom)
   ,cctdptrspnom     like ctgrlcldpt.cctdptrspnom #Responsavel pelo departamento
   ,cctdptlclsit     like ctgrlcldpt.cctdptlclsit #Sit do dep (A)tivo,(I)nativo
   ,cctdpttip        like ctgkdpt.cctdpttip       #Tipo de departamento
 end record

 define sql_select  char (200),
        l_res       smallint  ,
        l_msg       char(70)  ,
        l_ret       char(1)   ,
        l_sql       char(200) ,
        l_vlr       char(10)  ,
        l_codaux    smallint
 
 define lr_opsap    integer #Fornax-Quantum 

 let l_res = null
 let l_msg = null 
 let l_vlr = null 
 let l_codaux = null 

 let int_flag = false
 initialize ws.*   to null

 if operacao_aux = "a"
    then
    if dias_uteis(ctb02m01.socfatpgtdat,0,"","S","S") = ctb02m01.socfatpgtdat
       then
    else
       if ctb02m01.socfatpgtdat  <>  "18/10/1999"
          then
          call cts08g01("A","N","","DATA DE PAGAMENTO NAO","PODE SER FERIADO!","")
               returning ws.confirma2
          let int_flag = true
          initialize ctb02m01.*  to null
          return ctb02m01.*
       end if
    end if
    
    # if dias_entre_datas (today, ctb02m01.socfatpgtdat, "", "S", "S") < 4  then
    #    call cts08g01("A", "N", "",
    #                  "PAGAMENTO DEVE SER PROGRAMADO COM",
    #                  "PELO MENOS QUATRO DIAS DE ANTECEDENCIA!","")
    #         returning ws.confirma2
    # 
    #    let int_flag = true
    #    initialize ctb02m01.*  to null
    #    return ctb02m01.*
    # end if
 end if

 input by name #ctb02m01.socopgnum,
               # ctb02m01.socopgsitcod,
               ctb02m01.infissalqvlr,               # PSI-11-19199PR
               ctb02m01.socpgtdoctip,
               ctb02m01.nfsnum,
               ctb02m01.fisnotsrenum,  #Fornax - Quantum
               ctb02m01.socemsnfsdat,
               ctb02m01.succod,
               ctb02m01.socpgtopccod,
               ctb02m01.pgtdstcod,
               ctb02m01.socopgfavnom,
               ctb02m01.pestip,
               ctb02m01.cgccpfnum,
               ctb02m01.cgcord,
               ctb02m01.cgccpfdig,
               ctb02m01.bcoctatip,
               ctb02m01.bcocod,
               ctb02m01.bcoagnnum,
               ctb02m01.bcoagndig,
               ctb02m01.bcoctanum,
               ctb02m01.bcoctadig   without defaults
              # ctb02m01.socpgtdsctip,
              # ctb02m01.socopgdscvlr

    # before field socopgnum
    #        # let ctb02m01.empcod = 01  # empresa devera ser a do 1o servico
    #        # let ctb02m01.succod = 01  # sucursal devera ser a do prestador
    #        
    #        # ligia 21/08/08 - psi 198404
    #        # #PSI 191167
    #        # let lr_param.empcod    = ctb02m01.empcod
    #        # # let lr_param.succod    = 01
    #        # let lr_param.succod    = ctb02m01.succod
    #        # let lr_param.cctlclcod = ( 12243 / 10000)
    #        # let lr_param.cctdptcod = ( 12243 mod 10000)
    #        # 
    #        # call fctgc102_vld_dep(lr_param.*) returning lr_ret.*
    #        # 
    #        # if lr_ret.erro <>  0   then
    #        #    error "Erro",lr_ret.erro," na leitura do centro de custo!"
    #        #    sleep 3
    #        #    error lr_ret.mens
    #        # end if
    #        
    #        display by name ctb02m01.socopgnum   attribute(reverse)
    
    # after  field socopgnum
    #        display by name ctb02m01.socopgnum

    # before field socopgsitcod
    #        display by name ctb02m01.socopgsitcod  attribute(reverse)
    
    # after  field socopgsitcod
    #        display by name ctb02m01.socopgsitcod

    before field infissalqvlr                           # ini PSI-11-19199PR
           let ws.infissalqvlr = ctb02m01.infissalqvlr
           display by name ctb02m01.infissalqvlr attribute(reverse)

    after  field infissalqvlr
           display by name ctb02m01.infissalqvlr

           if ctb02m01.infissalqvlr is not null then
              let l_vlr = ctb02m01.infissalqvlr using "<<&.&&"
              call ctc00m24_obterCodIddkDominio( "psoaliquotasiss" # cponom
                                               , l_vlr           ) # cpodes
                   returning l_res
                           , l_msg
                           , l_codaux

              if l_res <> 0 then
                 if l_res = 2 then
                    error " Aliquota de ISS invalida para Optante pelo Simples!"
                 else
                    error l_msg
                 end if
                 next field infissalqvlr
              end if
           end if                                       # fim PSI-11-19199PR

    before field socpgtdoctip
           let ws.socpgtdoctip = ctb02m01.socpgtdoctip
           display by name ctb02m01.socpgtdoctip attribute(reverse)

    after  field socpgtdoctip
           display by name ctb02m01.socpgtdoctip

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field infissalqvlr
           end if
           
           if ctb02m01.socpgtdoctip is null
              then
              error " Tipo de documento deve ser informado!"
              next field socpgtdoctip
           end if
           
           if ctb02m01.socpgtdoctip <> 1 and
              ctb02m01.socpgtdoctip <> 2 and
              ctb02m01.socpgtdoctip <> 3 and
              ctb02m01.socpgtdoctip <> 4 
              then
              error " Informe o Tipo de Docto: 1-Nota Fiscal, 2-Recibo, 3-R.P.A., 4-NF Eletrônica"
              next field socpgtdoctip
           end if
           
           if ctb02m01.socpgtdoctip is not null and
              ctb02m01.socpgtdoctip > 0
              then
              initialize m_dominio.* to null
              
              call cty11g00_iddkdominio('socpgtdoctip', ctb02m01.socpgtdoctip)
                   returning m_dominio.*
                   
              if m_dominio.erro = 1
                 then
                 let ctb02m01.socpgtdocdes = m_dominio.cpodes clipped
              else
                 initialize ctb02m01.socpgtdocdes to null
                 error "Tipo documento fiscal: ", m_dominio.mensagem
              end if
           end if
           
           display by name ctb02m01.socpgtdoctip, ctb02m01.socpgtdocdes
           
           if operacao_aux = "a"         and
              ctb02m01.socpgtdoctip = 1  and  # NOTA FISCAL
              ws.socpgtdoctip <> ctb02m01.socpgtdoctip
              then
              declare c_ctb02m01nfs cursor for
                 select nfsnum from dbsmopgitm
                  where socopgnum = ctb02m01.socopgnum
                  
              open  c_ctb02m01nfs
              fetch c_ctb02m01nfs
              
              if sqlca.sqlcode = 0  then
                 let ctb02m01.socpgtdoctip = ws.socpgtdoctip
                 display by name ctb02m01.socpgtdoctip
                 error " Nao e' possivel alterar tipo de documento! Ja' existem itens digitados!"
                 next field socpgtdoctip
              end if
              
              close c_ctb02m01nfs
           end if
           
           # nao é preciso selecionar novamente, dados vem da funcao LER
           # initialize ws.lcvcod, ws.aviestcod to null

           # select cgccpfnum,
           #        cgcord   , cgccpfdig,
           #        pestip   , lcvcod   ,
           #        aviestcod, soctip
           #   into ctb02m01.opgcgccpfnum,
           #        ctb02m01.opgcgcord,
           #        ctb02m01.opgcgccpfdig,
           #        ws.pestip,
           #        ws.lcvcod,
           #        ws.aviestcod,
           #        m_opg.soctip
           # from dbsmopg
           # where socopgnum = ctb02m01.socopgnum
            
            
    before field nfsnum
           display by name ctb02m01.nfsnum attribute (reverse)
           
    after field nfsnum
    
           # Retirado a pedido do PS em 22/06/2009
           # if ctb02m01.socpgtdoctip = 1  or  # NF
           #    ctb02m01.socpgtdoctip = 4      # NFE
           #    then
           #    if ctb02m01.nfsnum is null or
           #       ctb02m01.nfsnum <= 0
           #       then
           #       error " Numero da nota fiscal deve ser informado!"
           #       next field nfsnum
           #    end if
           # end if
           
           if ctb02m01.nfsnum is not null and
              ctb02m01.nfsnum > 0
              then
              let l_ret = null
              
              call ctb00g01_vernfs(m_opg.soctip          ,
                                   ctb02m01.pestip       ,
                                   ctb02m01.cgccpfnum    ,
                                   ctb02m01.cgcord       ,
                                   ctb02m01.cgccpfdig    ,
                                   ctb02m01.socopgnum    ,
                                   ctb02m01.socpgtdoctip ,
                                   ctb02m01.nfsnum )
                         returning l_ret
                 
              if l_ret = "S" then
                 error " Documento já informado para o prestador, verifique "
                 next field nfsnum
              end if
           end if
           
           display by name ctb02m01.nfsnum
           
    #Fornax - Quantum - inicio
    before field fisnotsrenum
           display by name ctb02m01.fisnotsrenum attribute (reverse)

    after  field fisnotsrenum
           display by name ctb02m01.fisnotsrenum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field nfsnum
           end if
    #Fornax - Quantum - final  
    
    before field socemsnfsdat
           display by name ctb02m01.socemsnfsdat attribute (reverse)

    after  field socemsnfsdat
           display by name ctb02m01.socemsnfsdat

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
             #next field nfsnum  #Fornax - Quantum
              next field fisnotsrenum
           end if

           if ctb02m01.socemsnfsdat is null  then
              error " Data de emissao da nota fiscal deve ser informada!"
              next field socemsnfsdat
           end if

           if ctb02m01.socemsnfsdat > today  then
              error " Data de emissao da nota fiscal nao pode ser maior que a data atual!"
              next field socemsnfsdat
           end if

           if ctb02m01.socemsnfsdat < today - 90 units day  and
              g_issk.acsnivcod      < 8                     then
              error " Data de emissao da nota fiscal nao pode ser anterior a noventa dias!"
              next field socemsnfsdat
           end if
           
           if ctb02m01.socemsnfsdat < today - 1 units year  then
              error " Data de emissao da nota fiscal nao pode ser anterior a um ano!"
              next field socemsnfsdat
           end if
           
           if ctb02m01.socemsnfsdat > today + 1 units year  then
              error " Data de emissao da nota fiscal nao pode ser posterior a um ano!"
              next field socemsnfsdat
           end if
           

    before field succod
           if ctb02m01.favtip = 4  # Locadora
              then
              if ctb02m01.succod is null
                 then
                 call ctd19g00_dados_loja(1, m_opg.lcvcod, m_opg.aviestcod)
                      returning l_res, l_msg, ctb02m01.succod
              end if
              
              if ctb02m01.succod is not null
                 then
                 call cty10g00_nome_sucursal(ctb02m01.succod)
                      returning l_res, l_msg, ctb02m01.sucnom
              end if
              
              display by name ctb02m01.succod, ctb02m01.sucnom
              next field socpgtopccod
           end if
           
    after field succod
           if ctb02m01.favtip = 3  # Segurado
              then
              if ctb02m01.succod is null or
                 ctb02m01.succod <= 0
                 then
                 let l_sql = " select succod, sucnom from gabksuc ",
                             " order by 2 "                       
                 call ofgrc001_popup(08, 13, 'SUCURSAL DE REEMBOLSO',
                                     'Codigo', 'Descricao', 'N', l_sql, '', 'D')
                      returning l_res, ctb02m01.succod, ctb02m01.sucnom
                 next field succod
              end if
              
              if ctb02m01.succod is not null
                 then
                 call cty10g00_nome_sucursal(ctb02m01.succod)
                      returning l_res, l_msg, ctb02m01.sucnom
     
                 if l_res != 1 then
                    error l_msg
                    next field succod
                 end if
              end if
              display by name ctb02m01.succod, ctb02m01.sucnom
           else
              next field socpgtopccod
           end if
           
    before field socpgtopccod
           display by name ctb02m01.socpgtopccod attribute (reverse)

    after  field socpgtopccod
           display by name ctb02m01.socpgtopccod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socemsnfsdat
           end if
           
           #Fornax - Quantum - inicio
           #Informar o numero da OP SAP, qdo pagto cheque
           if ctb02m01.socpgtopccod = 2 then
           
              #Verifica se a OP e People ou SAP  Inicio  #Fornax-Quantum  
              call ffpgc377_verificarIntegracaoAtivaEmpresaRamo("038PTSOCTRIB",today,ctb02m01.empcod, 0)  
                   returning  mr_retSAP.stt                                                                 
                             ,mr_retSAP.msg     
                     
              display "mr_retSAP.stt ", mr_retSAP.stt
              display "mr_retSAP.msg ", mr_retSAP.msg                                                             
              
              if mr_retSAP.stt <> 0 then    
                 call ctb11m01a(ctb02m01.socopgnum)
                returning lr_opsap          
                                            
                if lr_opsap = 0 then        
                   next field socpgtopccod  
                end if
              end if
              
           end if
           #Fornax - Quantum - final

           #------------------------------------------------------------------
           # Pagamento a prestadores sem cadastro e Reembolsos
           #------------------------------------------------------------------
           if ctb02m01.socpgtopccod   is null   then
              error " Opcao de pagamento deve ser informada!"
              next field socpgtopccod
           end if
           
           initialize m_dominio.* to null
           
           call cty11g00_iddkdominio('socpgtopccod', ctb02m01.socpgtopccod)
                returning m_dominio.*
                
           if m_dominio.erro = 1
              then
              let ctb02m01.socpgtopcdes = m_dominio.cpodes clipped
           else
              initialize ctb02m01.socpgtopcdes to null
              error " Opcao de pagamento nao cadastrada!"
           end if
           
           display by name ctb02m01.socpgtopcdes
           
           if ctb02m01.socpgtopccod  =  2    then
              initialize ctb02m01.bcoctatip,
                         ctb02m01.bcoctatipdes,
                         ctb02m01.bcocod,
                         ctb02m01.bcosgl,
                         ctb02m01.bcoagnnum,
                         ctb02m01.bcoagndig,
                         ctb02m01.bcoagnnom,
                         ctb02m01.bcoctanum,
                         ctb02m01.bcoctadig  to null

              display by name ctb02m01.bcoctatip,
                              ctb02m01.bcoctatipdes,
                              ctb02m01.bcocod,
                              ctb02m01.bcosgl,
                              ctb02m01.bcoagnnum,
                              ctb02m01.bcoagndig,
                              ctb02m01.bcoagnnom,
                              ctb02m01.bcoctanum,
                              ctb02m01.bcoctadig
           end if
           
           let ws.socpgtopccod_svl = ctb02m01.socpgtopccod

           #------------------------------------------------------------
           # Dia do securitario so' pagto com boleto bancario
           #------------------------------------------------------------
           if ctb02m01.socfatpgtdat  =  "18/10/1999"   then
              if ctb02m01.socpgtopccod  <>  3          then
                 error " Nesta data somente pagamentos com boleto bancario!"
                 next field socpgtopccod
              end if
           end if

           #-----------------------------------------------------------------
           # Nos casos de pagamento a prestadores cadastrados, os dados para
           # pagamento devem ser iguais ao cadastro
           #-----------------------------------------------------------------
           if ctb02m01.favtip = 4  # Locadora
              then
              initialize ws.pestipcad   , ws.cgccpfnumcad, ws.cgcordcad,
                         ws.cgccpfdigcad, ws.socfavnomcad  to null
   
              select pestip   , cgccpfnum,
                     cgcord   , cgccpfdig,
                     favnom
                into ws.pestipcad   , ws.cgccpfnumcad,
                     ws.cgcordcad   , ws.cgccpfdigcad,
                     ws.socfavnomcad
                from datklcvfav
               where lcvcod    = m_opg.lcvcod
                 and aviestcod = m_opg.aviestcod
   
              if sqlca.sqlcode  <>  0   then
                 error "Erro (",sqlca.sqlcode,") na leitura do cadastro de favorecidos!"
                 next field socpgtopccod
              end if
   
              error " Confirme dados para pagamento com o cadastro! "
              call ctb02m05(m_opg.lcvcod, m_opg.aviestcod)
                  returning ctb02m01.pestip      , ctb02m01.cgccpfnum,
                            ctb02m01.cgcord      , ctb02m01.cgccpfdig,
                            ctb02m01.socopgfavnom, ctb02m01.bcocod,
                            ctb02m01.bcosgl      , ctb02m01.bcoagnnum,
                            ctb02m01.bcoagndig   , ctb02m01.bcoagnnom,
                            ctb02m01.bcoctanum   , ctb02m01.bcoctadig,
                            ctb02m01.socpgtopccod, ctb02m01.socpgtopcdes,
                            ctb02m01.bcoctatip   , ctb02m01.bcoctatipdes,
                            ws.confirma
   
              if ws.confirma  is null    or
                 ws.confirma  = "N"      then
                 error " Informacoes do cadastro nao foram confirmadas!"
                 next field socpgtopccod
              end if
              
              if ctb02m01.pestip     is null    or
                 ctb02m01.cgccpfnum  is null    or
                 ctb02m01.cgccpfdig  is null    then
                 error " Favorecido nao possui Cgc/Cpf favorecido cadastrado!"
                 next field socpgtopccod
              end if
   
              if ctb02m01.socopgfavnom  is null    then
                 error " Favorecido nao possui nome do favorecido cadastrado!"
                 next field socpgtopccod
              end if
           else
              # Nao sugerir dados para o reembolso, devem vir do protocolo da OP
              # Revisao reembolso, Abril/2010
              # if ctb02m01.favtip = 3   and   # Segurado
              #    ctb02m01.socopgsitcod = 1   # Nao analisada
              #    then
              #    call ctd20g07_dados_cli(ctb02m01.segnumdig)
              #         returning l_res, l_msg,  
              #                   ctb02m01.socopgfavnom, 
              #                   ctb02m01.cgccpfnum   ,
              #                   ctb02m01.cgcord      , 
              #                   ctb02m01.cgccpfdig   ,
              #                   ctb02m01.pestip
              #    
              #    display by name ctb02m01.socopgfavnom, ctb02m01.cgccpfnum,
              #                    ctb02m01.cgcord      , ctb02m01.cgccpfdig,
              #                    ctb02m01.pestip
              #                    
              #    error ' Foram sugeridos os dados do cliente para favorecido da OP'
              #    sleep 1
              # end if
           end if
           
           if ws.socpgtopccod_svl = 2 then  # CHEQUE
              initialize ctb02m01.bcocod      , ctb02m01.bcosgl      ,
                         ctb02m01.bcoagnnum   , ctb02m01.bcoagndig   ,
                         ctb02m01.bcoagnnom   , ctb02m01.bcoctanum   ,
                         ctb02m01.bcoctadig   , ctb02m01.bcoctatip   ,
                         ctb02m01.bcoctatipdes to null
              let ctb02m01.socpgtopccod  =  ws.socpgtopccod_svl
              
              initialize m_dominio.* to null
              
              call cty11g00_iddkdominio('socpgtopccod', ctb02m01.socpgtopccod)
                   returning m_dominio.*
                   
              if m_dominio.erro = 1
                 then
                 let ctb02m01.socpgtopcdes = m_dominio.cpodes clipped
              else
                 initialize ctb02m01.socpgtopcdes to null
                 error " Opcao de pagamento nao cadastrada!"
              end if
           end if

           display by name ctb02m01.pestip      , ctb02m01.cgccpfnum,
                           ctb02m01.cgcord      , ctb02m01.cgccpfdig,
                           ctb02m01.socopgfavnom, ctb02m01.bcocod,
                           ctb02m01.bcosgl      , ctb02m01.bcoagnnum,
                           ctb02m01.bcoagndig   , ctb02m01.bcoagnnom,
                           ctb02m01.bcoctanum   , ctb02m01.bcoctadig,
                           ctb02m01.socpgtopccod, ctb02m01.socpgtopcdes,
                           ctb02m01.bcoctatip   , ctb02m01.bcoctatipdes
           
           if ctb02m01.socpgtopccod  =  2  # CHEQUE
              then
              next field pgtdstcod
           else
              next field socopgfavnom
           end if
           
    before field pgtdstcod
           if ctb02m01.socpgtopccod  =  1   or    #--> Deposito em conta
              ctb02m01.socpgtopccod  =  3   then  #--> Boleto bancario
              initialize ctb02m01.pgtdstcod, ctb02m01.pgtdstdes   to null
              display by name ctb02m01.pgtdstcod, ctb02m01.pgtdstdes
              next field socopgfavnom
           end if
           display by name ctb02m01.pgtdstcod   attribute(reverse)

    after  field pgtdstcod
           display by name ctb02m01.pgtdstcod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socpgtopccod
           end if

           if ctb02m01.pgtdstcod   is null   then
              error " Destino deve ser informado!"
              call ctb11m04() returning  ctb02m01.pgtdstcod
              next field pgtdstcod
           end if

           select pgtdstdes
             into ctb02m01.pgtdstdes
             from fpgkpgtdst
            where fpgkpgtdst.pgtdstcod = ctb02m01.pgtdstcod

           if sqlca.sqlcode <> 0    then
              error " Destino nao cadastrado!"
              call ctb11m04() returning  ctb02m01.pgtdstcod
              next field pgtdstcod
           else
              display by name ctb02m01.pgtdstdes
           end if

    before field socopgfavnom
           display by name ctb02m01.socopgfavnom   attribute(reverse)

    after  field socopgfavnom
           display by name ctb02m01.socopgfavnom

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ctb02m01.socpgtopccod  =  1   or    #--> Deposito em conta
                 ctb02m01.socpgtopccod  =  3   then  #--> Boleto bancario
                 next field socpgtopccod
              end if
              next field  pgtdstcod
           end if

           if ctb02m01.socopgfavnom   is null   then
              error " Nome do favorecido deve ser informado!"
              next field socopgfavnom
           end if

    before field pestip
           display by name ctb02m01.pestip   attribute(reverse)

    after  field pestip
           display by name ctb02m01.pestip

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  socopgfavnom
           end if

           if ctb02m01.pestip   is null   then
              error " Tipo de pessoa deve ser informado!"
              next field pestip
           end if

           if ctb02m01.pestip  <>  "F"   and
              ctb02m01.pestip  <>  "J"   then
              error " Tipo de pessoa invalido!"
              next field pestip
           end if

           if ctb02m01.pestip  =  "F"   then
              initialize ctb02m01.cgcord  to null
              display by name ctb02m01.cgcord
           end if

    before field cgccpfnum
           display by name ctb02m01.cgccpfnum   attribute(reverse)

    after  field cgccpfnum
           display by name ctb02m01.cgccpfnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field pestip
           end if

           if ctb02m01.cgccpfnum   is null   or
              ctb02m01.cgccpfnum   =  0      then
              error " Numero do Cgc/Cpf deve ser informado!"
              next field cgccpfnum
           end if

           if ctb02m01.pestip  =  "F"   then
              next field cgccpfdig
           end if

    before field cgcord
           display by name ctb02m01.cgcord   attribute(reverse)

    after  field cgcord
           display by name ctb02m01.cgcord

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field cgccpfnum
           end if

           if ctb02m01.cgcord   is null   or
              ctb02m01.cgcord   =  0      then
              error " Filial do Cgc/Cpf deve ser informada!"
              next field cgcord
           end if

    before field cgccpfdig
           display by name ctb02m01.cgccpfdig  attribute(reverse)

    after  field cgccpfdig
           display by name ctb02m01.cgccpfdig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if ctb02m01.pestip  =  "J"  then
                 next field cgcord
              else
                 next field cgccpfnum
              end if
           end if

           if ctb02m01.cgccpfdig   is null   then
              error " Digito do Cgc/Cpf deve ser informado!"
              next field cgccpfdig
           end if

           if ctb02m01.pestip  =  "J"    then
              call F_FUNDIGIT_DIGITOCGC(ctb02m01.cgccpfnum, ctb02m01.cgcord)
                   returning ws.cgccpfdig
           else
              call F_FUNDIGIT_DIGITOCPF(ctb02m01.cgccpfnum)
                   returning ws.cgccpfdig
           end if

           if ws.cgccpfdig is null or
              ctb02m01.cgccpfdig <> ws.cgccpfdig 
              then
              error "Digito Cgc/Cpf incorreto!"
              next field cgccpfdig
           end if

           # se digitado novo favorecido, verificar NF em duplicidade
           if ctb02m01.opgcgccpfnum != ctb02m01.cgccpfnum or
              ctb02m01.opgcgcord    != ctb02m01.cgcord    or
              ctb02m01.opgcgccpfdig != ctb02m01.cgccpfdig
              then
              if ctb02m01.nfsnum is not null and
                 ctb02m01.nfsnum > 0
                 then
                 let l_ret = null
                 
                 call ctb00g01_vernfs(m_opg.soctip          ,
                                      ctb02m01.pestip       ,
                                      ctb02m01.cgccpfnum    ,
                                      ctb02m01.cgcord       ,
                                      ctb02m01.cgccpfdig    ,
                                      ctb02m01.socopgnum    ,
                                      ctb02m01.socpgtdoctip ,
                                      ctb02m01.nfsnum )
                            returning l_ret
                    
                 if l_ret = "S" then
                    error " Documento ", ctb02m01.nfsnum ," já informado para o prestador, verifique "
                    next field cgccpfdig
                 end if
              end if
           end if
           
           if ctb02m01.socpgtopccod = 2
              then
              exit input
           end if

    before field bcoctatip
       display by name ctb02m01.bcoctatip attribute (reverse)

    after  field bcoctatip
       display by name ctb02m01.bcoctatip

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field cgccpfdig
         end if

         if ctb02m01.bcoctatip  is null   then
            error " Tipo de conta deve ser informado!"
            next field bcoctatip
         end if

         case ctb02m01.bcoctatip
            when  1   let ctb02m01.bcoctatipdes = "C.CORRENTE"
            when  2   let ctb02m01.bcoctatipdes = "POUPANCA"
            otherwise error " Tipo Conta: 1-Conta Corrente, 2-Poupanca!"
                      next field bcoctatip
         end case
         display by name ctb02m01.bcoctatipdes

    before field bcocod
           display by name ctb02m01.bcocod   attribute(reverse)

    after  field bcocod
           display by name ctb02m01.bcocod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoctatip
           end if

           if ctb02m01.bcocod   is null   then
              error " Codigo do banco deve ser informado!"
              next field bcocod
           end if

           select bcosgl
             into ctb02m01.bcosgl
             from gcdkbanco
            where gcdkbanco.bcocod = ctb02m01.bcocod

           if sqlca.sqlcode <> 0    then
              error " Banco nao cadastrado!"
              next field bcocod
           else
              display by name ctb02m01.bcosgl
           end if

    before field bcoagnnum
           display by name ctb02m01.bcoagnnum   attribute(reverse)

    after  field bcoagnnum
           display by name ctb02m01.bcoagnnum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcocod
           end if

           if ctb02m01.bcoagnnum   is null   then
              error " Codigo da agencia deve ser informada!"
              next field bcoagnnum
           end if

           initialize ws.bcoagndig        to null
           initialize ctb02m01.bcoagnnom  to null
           display by name ctb02m01.bcoagnnom

           let ws.bcoagnnum = ctb02m01.bcoagnnum

           select bcoagnnom, bcoagndig
             into ctb02m01.bcoagnnom, ws.bcoagndig
             from gcdkbancoage
            where gcdkbancoage.bcocod    = ctb02m01.bcocod      and
                  gcdkbancoage.bcoagnnum = ws.bcoagnnum

           if sqlca.sqlcode  =  0   then
              display by name ctb02m01.bcoagnnom
           end if

    before field bcoagndig
           display by name ctb02m01.bcoagndig   attribute(reverse)

    after  field bcoagndig
           display by name ctb02m01.bcoagndig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoagnnum
           end if

           # inibir conforme LuisFernando P.Socorro 19/09/2001
           # if ctb02m01.bcocod  <>  424   and    #-> Noroeste
           #    ctb02m01.bcocod  <>  399   and    #-> Bamerindus
           #    ctb02m01.bcocod  <>  320   and    #-> Bicbanco
           #    ctb02m01.bcocod  <>  409   and    #-> Unibanco
           #    ctb02m01.bcocod  <>  231   and    #-> Boa Vista
           #    ctb02m01.bcocod  <>  347   and    #-> Sudameris
           #    ctb02m01.bcocod  <>  8     and    #-> Meridional
           #    ctb02m01.bcocod  <>  33    and    #-> Banespa
           #    ctb02m01.bcocod  <>  388   and    #-> B.M.D.
           #    ctb02m01.bcocod  <>  21    and    #-> Banco do Espirito Santo
           #    ctb02m01.bcocod  <>  230   and    #-> Bandeirantes
           #    ctb02m01.bcocod  <>  31    and    #-> Banco do Estado de Goias
           #    ctb02m01.bcocod  <>  479   and    #-> Banco de Boston
           #    ctb02m01.bcocod  <>  745   then   #-> Citibank
           #    if g_issk.acsnivcod  <  8         and
           #       ctb02m01.bcoagndig   is null   then
           #       error " Digito da agencia deve ser informado!"
           #       next field bcoagndig
           #    end if
           # end if

    before field bcoctanum
           display by name ctb02m01.bcoctanum   attribute(reverse)

    after  field bcoctanum
           display by name ctb02m01.bcoctanum

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoagndig
           end if

           if ctb02m01.bcoctanum   is null   or
              ctb02m01.bcoctanum   =  0      then
              error " Numero da conta corrente deve ser informado!"
              next field bcoctanum
           end if
           
           if ctb02m01.socpgtopccod  =  1      or
              ctb02m01.socpgtopccod  =  3      then
              if ctb02m01.bcocod     is null   or
                 ctb02m01.bcoagnnum  is null   or
                 ctb02m01.bcoctanum  is null   then
                 error " Dados para pagamento em conta incompletos!"
                 next field socpgtopccod
              end if
           else
              if ctb02m01.bcocod     is not null   or
                 ctb02m01.bcoagnnum  is not null   or
                 ctb02m01.bcoagndig  is not null   or
                 ctb02m01.bcoctanum  is not null   or
                 ctb02m01.bcoctadig  is not null   then
                 error " Dados nao conferem com opcao de pagamento!"
                 next field socpgtopccod
              end if
           end if
           
    before field bcoctadig
           display by name ctb02m01.bcoctadig   attribute(reverse)

    after  field bcoctadig
           display by name ctb02m01.bcoctadig

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field  bcoctanum
           end if

# ------->  inibir conforme LuisFernando P.Socorro 19/09/2001
#           if ctb02m01.bcoctadig   is null   then
#              error " Digito da conta corrente deve ser informado!"
#              next field bcoctadig
#           end if

#      before field socpgtdsctip
#             display by name ctb02m01.socpgtdsctip   attribute(reverse)

#      after  field socpgtdsctip
#             display by name ctb02m01.socpgtdsctip

#             if fgl_lastkey() = fgl_keyval ("up")     or
#                fgl_lastkey() = fgl_keyval ("left")   then
#                if ctb02m01.socpgtopccod  =  2   then
#                   next field socopgfavnom
#                end if
#                next field bcoctadig
#             end if

#             initialize ctb02m01.socpgtdscdes   to null

#             if ctb02m01.socpgtdsctip  is not null   then
#                case ctb02m01.socpgtdsctip
 #WWW              when  3
 #WWW                    let ctb02m01.socpgtdscdes = "REC.EVENT."
#                     when  4
#                           let ctb02m01.socpgtdscdes = "AC.CONTAB."
#                     when  5
#                           let ctb02m01.socpgtdscdes = "DESCONTO  "
#                     otherwise
#                           error "Tipo Desconto: 4-ACERTO CONTABIL 5-DESCONTO"
#                           next field socpgtdsctip
#                end case
#             end if
#             display by name ctb02m01.socpgtdscdes

#             if ctb02m01.socpgtdsctip  is null   then
#                initialize ctb02m01.socopgdscvlr   to null
#                display by name ctb02m01.socopgdscvlr
#                exit input
#             end if

#      before field socopgdscvlr
#             if ctb02m01.socpgtdsctip  = 4  then
#                let ctb02m01.socopgdscvlr = ctb02m01.socfattotvlr
#             end if
#             display by name ctb02m01.socopgdscvlr   attribute(reverse)

#      after  field socopgdscvlr
#             display by name ctb02m01.socopgdscvlr

#             if fgl_lastkey() = fgl_keyval ("up")     or
#                fgl_lastkey() = fgl_keyval ("left")   then
#                next field socpgtdsctip
#             end if

#             if ctb02m01.socopgdscvlr  is not null   and
#                ctb02m01.socpgtdsctip  is null       then
#                error " Tipo do desconto deve ser informado!"
#                next field socopgdscvlr
#             end if

#             if ctb02m01.socopgdscvlr  is null       and
#                ctb02m01.socpgtdsctip  is not null   then
#                error " Valor do desconto deve ser informado!"
#                next field socopgdscvlr
#             end if

#             if ctb02m01.socopgdscvlr   =  0      then
#                error " Valor de desconto nao deve ser zero!"
#                next field socopgdscvlr
#             end if

#             if ctb02m01.socpgtdsctip  = 5  then
#                if ctb02m01.socopgdscvlr  >=  ctb02m01.socfattotvlr   then
#                   error " Valor DESCONTO nao deve ser maior ou igual ao valor total da O.P.!"
#                   next field socopgdscvlr
#                end if
#             else
#                if ctb02m01.socpgtdsctip  = 4  then
#                   if ctb02m01.socopgdscvlr <> ctb02m01.socfattotvlr   then
#                      error " Valor ACERTO CONTABIL deve ser igual ao valor total da O.P.!"
#                      next field socopgdscvlr
#                   end if
#                end if
#             end if

    on key (interrupt)
       exit input

 end input
 
 if int_flag
    then
    initialize ctb02m01.*  to null
    return ctb02m01.*
 end if

 return ctb02m01.*

end function  ###  input_ctb02m01

#--------------------------------------------------------------------
function cancela_ctb02m01(k_ctb02m01)
#--------------------------------------------------------------------

  define ctb02m01     record
     socopgnum        like dbsmopg.socopgnum,
     socopgsitcod     like dbsmopg.socopgsitcod,
     socopgsitdes     char (30),
     empresa          char (5),      #PSI 205206
     favtip           smallint,
     favtipcab1       char (14),
     favtipcod1       char (08),
     favtipnom1       char (40),
     favtipcab2       char (14),
     favtipcod2       char (08),
     favtipnom2       char (40),
     socfatentdat     like dbsmopg.socfatentdat,
     socfatpgtdat     like dbsmopg.socfatpgtdat,
     socfatrelqtd     like dbsmopg.socfatrelqtd,
     socfatitmqtd     like dbsmopg.socfatitmqtd,
     socfattotvlr     like dbsmopg.socfattotvlr,
     soctrfcod        like dbsmopg.soctrfcod,
     socpgtdoctip     like dbsmopg.socpgtdoctip,
     socpgtdocdes     char (15),
     empcod           like dbsmopg.empcod,
     succod           like dbsmopg.succod,
     sucnom           like gabksuc.sucnom,
     socemsnfsdat     like dbsmopg.socemsnfsdat,
     socpgtopccod     like dbsmopgfav.socpgtopccod,
     socpgtopcdes     char (10),
     pgtdstcod        like dbsmopg.pgtdstcod,
     pgtdstdes        like fpgkpgtdst.pgtdstdes,
     socopgfavnom     like dbsmopgfav.socopgfavnom,
     pestip           like dbsmopgfav.pestip,
     cgccpfnum        like dbsmopgfav.cgccpfnum,
     cgcord           like dbsmopgfav.cgcord,
     cgccpfdig        like dbsmopgfav.cgccpfdig,
     bcoctatip        like dbsmopgfav.bcoctatip,
     bcoctatipdes     char (10),
     bcocod           like dbsmopgfav.bcocod,
     bcosgl           like gcdkbanco.bcosgl,
     bcoagnnum        like dbsmopgfav.bcoagnnum,
     bcoagndig        like dbsmopgfav.bcoagndig,
     bcoagnnom        like gcdkbancoage.bcoagnnom,
     bcoctanum        like dbsmopgfav.bcoctanum,
     bcoctadig        like dbsmopgfav.bcoctadig,
     #    socpgtdsctip     like dbsmopg.socpgtdsctip,
     #    socpgtdscdes     char (10),
     socopgdscvlr     like dbsmopg.socopgdscvlr,
     opgcgccpfnum     like dbsmopg.cgccpfnum,
     opgcgcord        like dbsmopg.cgcord,
     opgcgccpfdig     like dbsmopg.cgccpfdig,
     opgpestip        like dbsmopg.pestip   ,
     trbempcod        like dbsmopgtrb.empcod,
     trbsuccod        like dbsmopgtrb.succod,
     trbprstip        like dbsmopgtrb.prstip,
     nfsnum           like dbsmopgitm.nfsnum,
     fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
     ciaempcod        like datmservico.ciaempcod,    
     corsus           like dbsmopg.corsus,
     segnumdig        like dbsmopg.segnumdig,
     infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
  end record
 
  define k_ctb02m01   record
     socopgnum        like dbsmopg.socopgnum
  end record
 
  define ws           record
     atdsrvnum        like dbsmopgitm.atdsrvnum,
     atdsrvano        like dbsmopgitm.atdsrvano,
     atdcstvlr        like datmservico.atdcstvlr,
     errcod           smallint ,
     pgtautprpdat     like fpgmpgtaut.pgtautprpdat,
     pgtdat           like fpgmpgt.pgtdat,
     pgtfrmcod        like fpgmpgt.pgtfrmcod,
     pgtbcocod        like fpgmpgt.pgtbcocod,
     pgtbcoagnnum     like fpgmpgt.pgtbcoagnnum,
     bcoctanum        dec  (12,0),
     bcoctadig        char (02),
     pgtdocnum        like fpgmpgt.pgtdocnum,
     pgtautvlr        like fpgmpgtaut.pgtautvlr,
     errdsc           char (50),
     confirma         char (01),
     flgok            smallint,
     msg              char (75)
  end record
 
  define a_bfpga_err  array[10] of record
     errcod           smallint
  end record
  
  define l_res  smallint,
         l_msg  char (80)
         
  define arr_aux      smallint
 
  define sql_comando  char (200)
 
  initialize a_bfpga_err  to null
  initialize ws.*         to null
 
  #Carrega o record ctb02m01 antes de entrar no menu para poder testar
  # a data de pagamento, e nao ter que carregar novamente se a data para
  # cancelamento for valida.
  call ler_ctb02m01(k_ctb02m01.*) returning ctb02m01.*
 
  if ctb02m01.socfatpgtdat < today 
     then
     clear form
     initialize ctb02m01.*   to null
     initialize k_ctb02m01.* to null
     error "Não foi possivel cancelar OP, data de pagamento menor que data atual!"
  else
  
     menu "Confirma cancelamento ?"
     
        command "Nao" "Nao cancela ordem de pagamento"
              clear form
              initialize ctb02m01.*   to null
              initialize k_ctb02m01.* to null
              error " Operacao cancelada!"
              exit menu
              
        command "Sim" "Cancela ordem de pagamento"
        
           if ctb02m01.socopgnum is null
              then
              initialize ctb02m01.*   to null
              initialize k_ctb02m01.* to null
              error " Ordem de pagamento nao localizada!"
           else
              message " Aguarde, processando cancelamento... " attribute (reverse)
              
              call ctx07g00(k_ctb02m01.socopgnum, ctb02m01.socopgsitcod,
                            ctb02m01.ciaempcod, g_issk.funmat, g_issk.empcod)
                  returning l_res, l_msg
                  
              if l_res != 0
                then
                let l_msg = ' Erro:', l_msg clipped
                message "Erro no canelamento!" attribute (reverse)
                error l_msg
              else
                 initialize ctb02m01.*   to null
                 initialize k_ctb02m01.* to null
                 message "Cancelamento efetuado com sucesso!" attribute (reverse)
                 #clear form
              end if
           end if
           
           exit menu
           
     end menu
    
  end if
  
  return k_ctb02m01.*

end function  ###  cancela_ctb02m01

#--------------------------------------------------------------------
function remove_ctb02m01(k_ctb02m01)
#--------------------------------------------------------------------

 define ctb02m01     record
    socopgnum        like dbsmopg.socopgnum,
    socopgsitcod     like dbsmopg.socopgsitcod,
    socopgsitdes     char (30),
    empresa          char (5),      #PSI 205206
    favtip           smallint,
    favtipcab1       char (14),
    favtipcod1       char (08),
    favtipnom1       char (40),
    favtipcab2       char (14),
    favtipcod2       char (08),
    favtipnom2       char (40),
    socfatentdat     like dbsmopg.socfatentdat,
    socfatpgtdat     like dbsmopg.socfatpgtdat,
    socfatrelqtd     like dbsmopg.socfatrelqtd,
    socfatitmqtd     like dbsmopg.socfatitmqtd,
    socfattotvlr     like dbsmopg.socfattotvlr,
    soctrfcod        like dbsmopg.soctrfcod,
    socpgtdoctip     like dbsmopg.socpgtdoctip,
    socpgtdocdes     char (15),
    empcod           like dbsmopg.empcod,
    succod           like dbsmopg.succod,
    sucnom           like gabksuc.sucnom,
    socemsnfsdat     like dbsmopg.socemsnfsdat,
    socpgtopccod     like dbsmopgfav.socpgtopccod,
    socpgtopcdes     char (10),
    pgtdstcod        like dbsmopg.pgtdstcod,
    pgtdstdes        like fpgkpgtdst.pgtdstdes,
    socopgfavnom     like dbsmopgfav.socopgfavnom,
    pestip           like dbsmopgfav.pestip,
    cgccpfnum        like dbsmopgfav.cgccpfnum,
    cgcord           like dbsmopgfav.cgcord,
    cgccpfdig        like dbsmopgfav.cgccpfdig,
    bcoctatip        like dbsmopgfav.bcoctatip,
    bcoctatipdes     char (10),
    bcocod           like dbsmopgfav.bcocod,
    bcosgl           like gcdkbanco.bcosgl,
    bcoagnnum        like dbsmopgfav.bcoagnnum,
    bcoagndig        like dbsmopgfav.bcoagndig,
    bcoagnnom        like gcdkbancoage.bcoagnnom,
    bcoctanum        like dbsmopgfav.bcoctanum,
    bcoctadig        like dbsmopgfav.bcoctadig,
#    socpgtdsctip     like dbsmopg.socpgtdsctip,
#    socpgtdscdes     char (10),
    socopgdscvlr     like dbsmopg.socopgdscvlr,
    opgcgccpfnum     like dbsmopg.cgccpfnum,
    opgcgcord        like dbsmopg.cgcord,
    opgcgccpfdig     like dbsmopg.cgccpfdig,
    opgpestip        like dbsmopg.pestip   ,
    trbempcod        like dbsmopgtrb.empcod,
    trbsuccod        like dbsmopgtrb.succod,
    trbprstip        like dbsmopgtrb.prstip,
    retorno          smallint,
    mensagem         char(60),
    nfsnum           like dbsmopgitm.nfsnum,
    fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
    ciaempcod        like datmservico.ciaempcod,    
    corsus           like dbsmopg.corsus,
    segnumdig        like dbsmopg.segnumdig,
    infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
 end record

 define k_ctb02m01   record
    socopgnum        like dbsmopg.socopgnum
 end record

   menu "Confirma exclusao ?"

      command "Nao" "Nao exclui ordem de pagamento"
              clear form
              initialize ctb02m01.*   to null
              initialize k_ctb02m01.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui ordem de pagamento"
              call ler_ctb02m01(k_ctb02m01.*) returning ctb02m01.*

              if ctb02m01.socopgnum  is null   then
                 initialize ctb02m01.*   to null
                 initialize k_ctb02m01.* to null
                 error " Ordem de pagamento nao localizada!"
              else

                 begin work

                    delete from dbsmopg
                     where socopgnum = k_ctb02m01.socopgnum

                    # PSI 211074 - BURINI
                    call cts50g00_delete_etapa(k_ctb02m01.socopgnum)
                         returning ctb02m01.retorno,
                                   ctb02m01.mensagem

                    delete from dbsmopgobs
                     where socopgnum = k_ctb02m01.socopgnum

                    delete from dbsmopgfav
                     where socopgnum = k_ctb02m01.socopgnum

                    delete from dbsmopgitm
                     where socopgnum = k_ctb02m01.socopgnum

                    delete from dbsmopgcst
                     where socopgnum = k_ctb02m01.socopgnum

                    delete from dbsropgdsc
                     where socopgnum = k_ctb02m01.socopgnum

                  # delete from dbsmopgtrb
                  #  where socopgnum = k_ctb02m01.socopgnum

                 commit work

                 if sqlca.sqlcode <> 0   then
                    initialize ctb02m01.*   to null
                    initialize k_ctb02m01.* to null
                    error " Erro (",sqlca.sqlcode,") na exlusao da ordem de pagamento!"
                 else
                    initialize ctb02m01.*   to null
                    initialize k_ctb02m01.* to null
                    error   " Ordem de pagamento excluida!"
                    message ""
                    clear form
                 end if
              end if

              exit menu
   end menu

   return k_ctb02m01.*

end function  ###  remove_ctb02m01

#---------------------------------------------------------
function ler_ctb02m01(k_ctb02m01)
#---------------------------------------------------------

  define ctb02m01     record
     socopgnum        like dbsmopg.socopgnum,
     socopgsitcod     like dbsmopg.socopgsitcod,
     socopgsitdes     char (30),
     empresa          char (5),      #PSI 205206
     favtip           smallint,
     favtipcab1       char (14),
     favtipcod1       char (08),
     favtipnom1       char (40),
     favtipcab2       char (14),
     favtipcod2       char (08),
     favtipnom2       char (40),
     socfatentdat     like dbsmopg.socfatentdat,
     socfatpgtdat     like dbsmopg.socfatpgtdat,
     socfatrelqtd     like dbsmopg.socfatrelqtd,
     socfatitmqtd     like dbsmopg.socfatitmqtd,
     socfattotvlr     like dbsmopg.socfattotvlr,
     soctrfcod        like dbsmopg.soctrfcod,
     socpgtdoctip     like dbsmopg.socpgtdoctip,
     socpgtdocdes     char (15),
     empcod           like dbsmopg.empcod,
     succod           like dbsmopg.succod,
     sucnom           like gabksuc.sucnom,
     socemsnfsdat     like dbsmopg.socemsnfsdat,
     socpgtopccod     like dbsmopgfav.socpgtopccod,
     socpgtopcdes     char (10),
     pgtdstcod        like dbsmopg.pgtdstcod,
     pgtdstdes        like fpgkpgtdst.pgtdstdes,
     socopgfavnom     like dbsmopgfav.socopgfavnom,
     pestip           like dbsmopgfav.pestip,
     cgccpfnum        like dbsmopgfav.cgccpfnum,
     cgcord           like dbsmopgfav.cgcord,
     cgccpfdig        like dbsmopgfav.cgccpfdig,
     bcoctatip        like dbsmopgfav.bcoctatip,
     bcoctatipdes     char (10),
     bcocod           like dbsmopgfav.bcocod,
     bcosgl           like gcdkbanco.bcosgl,
     bcoagnnum        like dbsmopgfav.bcoagnnum,
     bcoagndig        like dbsmopgfav.bcoagndig,
     bcoagnnom        like gcdkbancoage.bcoagnnom,
     bcoctanum        like dbsmopgfav.bcoctanum,
     bcoctadig        like dbsmopgfav.bcoctadig,
     # socpgtdsctip     like dbsmopg.socpgtdsctip,
     # socpgtdscdes     char (10),
     socopgdscvlr     like dbsmopg.socopgdscvlr,
     opgcgccpfnum     like dbsmopg.cgccpfnum,
     opgcgcord        like dbsmopg.cgcord,
     opgcgccpfdig     like dbsmopg.cgccpfdig,
     opgpestip        like dbsmopg.pestip   ,
     trbempcod        like dbsmopgtrb.empcod,
     trbsuccod        like dbsmopgtrb.succod,
     trbprstip        like dbsmopgtrb.prstip,
     nfsnum           like dbsmopgitm.nfsnum,
     fisnotsrenum     like dbsmopg.fisnotsrenum,  #Fornax - Quantum
     ciaempcod        like datmservico.ciaempcod,    
     corsus           like dbsmopg.corsus,
     segnumdig        like dbsmopg.segnumdig,
     infissalqvlr     like dbsmopg.infissalqvlr     # PSI-11-19199PR
  end record
 
  define k_ctb02m01   record
     socopgnum        like dbsmopg.socopgnum
  end record
 
  define ws           record
     bcoagnnum        like gcdkbancoage.bcoagnnum,
     lcvextcod        like datkavislocal.lcvextcod,
     desconto	     decimal(15,5)
  end record
 
  define lr_param     record     #PSI 191167
     empcod           like ctgklcl.empcod       #Empresa
    ,succod           like ctgklcl.succod       #Sucursal
    ,cctlclcod        like ctgklcl.cctlclcod    #Local
    ,cctdptcod        like ctgrlcldpt.cctdptcod #Departamento
  end record
 
  define lr_ret       record     #PSI 191167
     erro             smallint                     #0-Ok,1-erro
    ,mens             char(40)
    ,cctlclnom        like ctgklcl.cctlclnom       #Nome do local
    ,cctdptnom        like ctgkdpt.cctdptnom       #Nome do dep.(antigo cctnom)
    ,cctdptrspnom     like ctgrlcldpt.cctdptrspnom #Responsavel pelo departamento
    ,cctdptlclsit     like ctgrlcldpt.cctdptlclsit #Sit do dep (A)tivo,(I)nativo
    ,cctdpttip        like ctgkdpt.cctdpttip       #Tipo de departamento
  end record
  
  define l_fav record
         errcod     smallint ,
         msg        char(80)
  end record
  
  define l_ciaempcod   like datmservico.ciaempcod,      #PSI 205206
         l_ciaempcodOP like datmservico.ciaempcod,
         l_nfsnum      like dbsmopg.nfsnum
 
  define l_res smallint,
         l_msg char(70)

  let l_res = null
  let l_msg = null 

  initialize ctb02m01.*   to null
  initialize ws.*         to null
  initialize lr_param.*   to null
  initialize lr_ret.*     to null
  initialize l_fav.* to null
  initialize m_opg.* to null
  
  initialize l_nfsnum, l_ciaempcod, l_ciaempcodOP to null

  #--------------------------------------------------------------------
  # Obtem dados da O.P.
  #--------------------------------------------------------------------
  select socopgnum,
         socopgsitcod,
         corsus,
         cgccpfnum,
         cgcord,
         cgccpfdig,
         pestip,
         socfatentdat,
         socfatpgtdat,
         socfatitmqtd,
         socfattotvlr,
         soctrfcod,
         socfatrelqtd,
         socpgtdoctip,
         socemsnfsdat,
         empcod,
         succod,
         pgtdstcod,
         socopgdscvlr,
         lcvcod,
         aviestcod,
         soctip,
         segnumdig,
         favtip,
         nfsnum,
         fisnotsrenum,  #Fornax - Quantum
         infissalqvlr
    into ctb02m01.socopgnum,
         ctb02m01.socopgsitcod,
         ctb02m01.corsus,
         ctb02m01.opgcgccpfnum,
         ctb02m01.opgcgcord,
         ctb02m01.opgcgccpfdig,
         ctb02m01.opgpestip,
         ctb02m01.socfatentdat,
         ctb02m01.socfatpgtdat,
         ctb02m01.socfatitmqtd,
         ctb02m01.socfattotvlr,
         ctb02m01.soctrfcod,
         ctb02m01.socfatrelqtd,
         ctb02m01.socpgtdoctip,
         ctb02m01.socemsnfsdat,
         ctb02m01.empcod,
         ctb02m01.succod,
         ctb02m01.pgtdstcod,
         ctb02m01.socopgdscvlr,
         m_opg.lcvcod,
         m_opg.aviestcod,
         m_opg.soctip,
         ctb02m01.segnumdig,
         ctb02m01.favtip,
         ctb02m01.nfsnum,
         ctb02m01.fisnotsrenum,  #Fornax - Quantum
         ctb02m01.infissalqvlr                 # PSI-11-19199PR
    from dbsmopg
   where socopgnum = k_ctb02m01.socopgnum

  if sqlca.sqlcode = notfound   then
     error " Ordem de pagamento nao cadastrada!"
     goto fim_erro
  end if
  
  # somente OP carra extra
  if m_opg.soctip != 2
     then
     error " Este numero de OP nao pertence ao Carro-Extra!"
     goto fim_erro
  end if
  
  call cty10g00_nome_sucursal(ctb02m01.succod)
       returning l_res, l_msg, ctb02m01.sucnom

  display by name ctb02m01.sucnom 
  
  #PSI197858 - inicio
  select sum(dscvlr) into ws.desconto
  from dbsropgdsc
  where socopgnum = k_ctb02m01.socopgnum
  
  # if ws.desconto <> 0 and ws.desconto is not null then
  # 	let ctb02m01.socfattotvlr = ctb02m01.socfattotvlr - ws.desconto
  # else
  # 	if ctb02m01.socopgdscvlr is not null and ctb02m01.socopgdscvlr > 0.00 then
  # 		let ctb02m01.socfattotvlr = ctb02m01.socfattotvlr - ctb02m01.socopgdscvlr
  # 	end if
  # end if
  
  if ctb02m01.socopgdscvlr is null or ctb02m01.socopgdscvlr = 0.00 
     then
     if ws.desconto is not null or ws.desconto > 0.00 
        then
        let ctb02m01.socopgdscvlr = ws.desconto
     else
        let ctb02m01.socopgdscvlr = 0.00
     end if
  end if
  #PSI197858 - fim
  
  initialize m_dominio.* to null
  
  call cty11g00_iddkdominio('socopgsitcod', ctb02m01.socopgsitcod)
       returning m_dominio.*
       
  if m_dominio.erro = 1
     then
     let ctb02m01.socopgsitdes = m_dominio.cpodes clipped
  else
     initialize ctb02m01.socopgsitdes to null
     error "Situacao da OP: ", m_dominio.mensagem
     goto fim_erro
  end if
  
  if ctb02m01.socopgsitcod  <>  1   then   #--->  Nao analisada
  
     # ligia 21/08/08 - psi 198404
     # #if ctb02m01.cctcod is not null
     # #   then
     # #PSI 191167
     # let lr_param.empcod    = ctb02m01.empcod
     # # let lr_param.succod    = 01  # sucursal devera ser a do prestador
     # let lr_param.succod    = ctb02m01.succod
     # let lr_param.cctlclcod = ( 12243 / 10000)
     # let lr_param.cctdptcod = ( 12243 mod 10000)
     # 
     # call fctgc102_vld_dep(lr_param.*) returning lr_ret.*
     # 
     # if lr_ret.erro <>  0 
     #    then
     #    error "Erro (",lr_ret.erro,") na leitura do centro de custo!"
     #    sleep 3
     #    error lr_ret.mens
     #    goto fim_erro
     # end if
     # #end if
     
     if ctb02m01.pgtdstcod is not null  then
        select pgtdstdes
          into ctb02m01.pgtdstdes
          from fpgkpgtdst
         where pgtdstcod = ctb02m01.pgtdstcod

        if sqlca.sqlcode  <>  0   then
           error " Erro (",sqlca.sqlcode,") na leitura do destino!"
           goto fim_erro
        end if
     end if
     
     #--------------------------------------------------------------------
     # Obtem dados do favorecido
     #--------------------------------------------------------------------
     select socopgfavnom,
            socpgtopccod,
            pestip,
            cgccpfnum,
            cgcord,
            cgccpfdig,
            bcoctatip,
            bcocod,
            bcoagnnum,
            bcoagndig,
            bcoctanum,
            bcoctadig
       into ctb02m01.socopgfavnom,
            ctb02m01.socpgtopccod,
            ctb02m01.pestip,
            ctb02m01.cgccpfnum,
            ctb02m01.cgcord,
            ctb02m01.cgccpfdig,
            ctb02m01.bcoctatip,
            ctb02m01.bcocod,
            ctb02m01.bcoagnnum,
            ctb02m01.bcoagndig,
            ctb02m01.bcoctanum,
            ctb02m01.bcoctadig
       from dbsmopgfav
      where socopgnum  =  k_ctb02m01.socopgnum
      
     if ctb02m01.socopgsitcod  <>  8   and    #--->  Cancelada
        sqlca.sqlcode          <>  0   then
        error " Erro (",sqlca.sqlcode,") na leitura do favorecido!"
        goto fim_erro
     end if

     #--------------------------------------------------------------------
     # Descricao da opcao de pagamento
     #--------------------------------------------------------------------
     if ctb02m01.socpgtopccod is not null and
        ctb02m01.socpgtopccod > 0
        then
        initialize m_dominio.* to null
        
        call cty11g00_iddkdominio('socpgtopccod', ctb02m01.socpgtopccod)
             returning m_dominio.*
             
        if m_dominio.erro = 1
           then
           let ctb02m01.socpgtopcdes = m_dominio.cpodes clipped
        else
           initialize ctb02m01.socpgtopcdes to null
           error "Opção de pagamento: ", m_dominio.mensagem
           goto fim_erro
        end if
     end if
     
     if ctb02m01.socpgtopccod  is not null  and
        ctb02m01.socpgtopccod  <>  2        then  #--> Opcao pagto cheque

        case ctb02m01.bcoctatip
           when 1  let ctb02m01.bcoctatipdes = "C.CORRENTE"
           when 2  let ctb02m01.bcoctatipdes = "POUPANCA"
        end case

        select bcosgl
          into ctb02m01.bcosgl
          from gcdkbanco
         where gcdkbanco.bcocod = ctb02m01.bcocod

        if sqlca.sqlcode  <>  0   then
           error " Erro (",sqlca.sqlcode,") na leitura do nome do banco!"
           goto fim_erro
        end if

        let ws.bcoagnnum = ctb02m01.bcoagnnum

        select bcoagnnom
          into ctb02m01.bcoagnnom
          from gcdkbancoage
         where gcdkbancoage.bcocod    = ctb02m01.bcocod     and
               gcdkbancoage.bcoagnnum = ws.bcoagnnum

        if sqlca.sqlcode  <>  0     and
           sqlca.sqlcode  <>  100   then
           error " Erro (",sqlca.sqlcode,") na leitura do nome da agencia!"
           goto fim_erro
        end if
     end if
  else
     # fase 'Nao analisada' ainda nao possui favorecido, sugerir valores da protocolo
     let ctb02m01.cgccpfnum = ctb02m01.opgcgccpfnum
     let ctb02m01.cgcord    = ctb02m01.opgcgcord
     let ctb02m01.cgccpfdig = ctb02m01.opgcgccpfdig
     let ctb02m01.pestip    = ctb02m01.opgpestip
  end if

  #PSI 205206
  #verificar qual a empresa dos itens da OP - caso exista
  declare cctb02m01001 cursor for
     select b.ciaempcod, a.nfsnum
     from dbsmopgitm a, outer datmservico b
     where a.socopgnum = k_ctb02m01.socopgnum
       and a.atdsrvnum = b.atdsrvnum
       and a.atdsrvano = b.atdsrvano
       
  foreach cctb02m01001 into l_ciaempcod, l_nfsnum
  
      #se empresa da OP é nula
      if l_ciaempcodOP is null  # primeiro servico
         then
         let ctb02m01.ciaempcod = l_ciaempcod
         
         #empresa da OP recebe empresa do item
         let l_ciaempcodOP = l_ciaempcod
         
         #busca descricao da empresa
         # call cty14g00_empresa(1, l_ciaempcodOP)
         #      returning lr_ret.erro,
         #                lr_ret.mens,
         #                ctb02m01.empresa
               
      else
         #verificar se empresa da OP e empresa do item são iguais
         if l_ciaempcodOP <> l_ciaempcod then
            error "Itens da OP com empresas diferentes!"
         end if
      end if
  end foreach
  
  # atribuir numero da NFS do item quando nao estiver na OP
  if ctb02m01.nfsnum is null and l_nfsnum is not null
     then
     let ctb02m01.nfsnum = l_nfsnum
  end if
  
  # empresa nao gravada na OP ou gravada errada na OP automatica, corrige no modifica
  if (ctb02m01.empcod is null and l_ciaempcodOP is not null) or
     (ctb02m01.empcod != l_ciaempcodOP)
     then
     let ctb02m01.empcod = l_ciaempcodOP
  end if
  
  # obter dados do favorecido com CPF/CNPJ gravado na tab favorecido
  call ctb00g01_dados_favtip(2, '', ctb02m01.segnumdig, m_opg.lcvcod,
                             m_opg.aviestcod, 
                             ctb02m01.corsus,
                             ctb02m01.empcod,
                             ctb02m01.cgccpfnum,
                             ctb02m01.cgcord,
                             ctb02m01.cgccpfdig,
                             ctb02m01.favtip)
                   returning l_fav.errcod,
                             l_fav.msg,
                             ctb02m01.favtip,
                             ctb02m01.favtipcod1,
                             ctb02m01.favtipcab1,
                             ctb02m01.favtipnom1,
                             ctb02m01.favtipcod2,
                             ctb02m01.favtipcab2,
                             ctb02m01.favtipnom2
  
  if l_fav.errcod != 0
     then
     error l_fav.msg
     sleep 1
     goto fim_erro
  end if
  
  # sugerir nome do CPF da OP no favorecido antes da analise
  if ctb02m01.socopgsitcod = 1  #  Nao analisada
     then
     if ctb02m01.favtip = 3
        then
        let ctb02m01.socopgfavnom = ctb02m01.favtipnom1
     else
        let ctb02m01.socopgfavnom = ctb02m01.favtipnom2
     end if
  end if
  
  #   case ctb02m01.socpgtdsctip
  #      when 3  let ctb02m01.socpgtdscdes = "REC.EVENT."
  #      when 4  let ctb02m01.socpgtdscdes = "AC.CONTAB."
  #      when 5  let ctb02m01.socpgtdscdes = "DESCONTO  "
  #   end case
   
  if ctb02m01.socpgtdoctip is not null and
     ctb02m01.socpgtdoctip > 0
     then
     initialize m_dominio.* to null
     
     call cty11g00_iddkdominio('socpgtdoctip', ctb02m01.socpgtdoctip)
          returning m_dominio.*
          
     if m_dominio.erro = 1
        then
        let ctb02m01.socpgtdocdes = m_dominio.cpodes clipped
     else
        initialize ctb02m01.socpgtdocdes to null
        error "Tipo documento fiscal: ", m_dominio.mensagem
     end if
  end if
  
  # busca descricao da empresa, se nao houver itens mostra N/D
  call cty14g00_empresa_abv(ctb02m01.empcod)
       returning lr_ret.erro, lr_ret.mens, ctb02m01.empresa
       
  return ctb02m01.*
  
  #--------------------------------------------------------------------
  label fim_erro :
  #--------------------------------------------------------------------
  sleep 4
  initialize ctb02m01.*    to null
  initialize k_ctb02m01.*  to null
  return ctb02m01.*

end function  ###  ler_ctb02m01

