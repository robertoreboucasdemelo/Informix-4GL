#############################################################################
# Nome do Modulo: CTS12M01                                            Pedro #
#                                                                   Marcelo #
# Remocao de Perda Total - Emissao da Carta                        Mar/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA           SOLICITACAO  RESPONSAVEL  DESCRICAO                        #
# --------------------------------------------------------------------------#
# 11/12/2000     PSI 11155-4  Ruiz         Incluir msg de alerta na carta.  #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
# 13/08/2009  Sergio Burini       PSI 244236     Inclusão do Sub-Dairro     #
#---------------------------------------------------------------------------#
# 04/01/2010  Amilton                            Projeto sucursal smallint  #
#############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define wsg_pipe     char(20)

#---------------------------------------------------------------------------
 function cts12m01(param)
#---------------------------------------------------------------------------

 define param        record
    atdsrvorg        like datmservico.atdsrvorg   ,
    atdsrvnum        like datmservico.atdsrvnum   ,
    atdsrvano        like datmservico.atdsrvano   ,
    nom              like datmservico.nom         ,
    succod           like datrservapol.succod     ,
    ramcod           like datrservapol.ramcod     ,
    aplnumdig        like datrservapol.aplnumdig  ,
    itmnumdig        like datrservapol.itmnumdig  ,
    vcldes           like datmservico.vcldes      ,
    vclanomdl        like datmservico.vclanomdl   ,
    vcllicnum        like datmservico.vcllicnum   ,
    vclchsinc        like abbmveic.vclchsinc      ,
    vclchsfnl        like abbmveic.vclchsfnl      ,
    orrlclidttxt     like datmlcl.lclidttxt       ,
    orrlgdtxt        char (65)                    ,
    orrbrrnom        like datmlcl.brrnom          ,
    orrlclbrrnom     like datmlcl.lclbrrnom       ,
    orrcidnom        like datmlcl.cidnom          ,
    orrufdcod        like datmlcl.ufdcod          ,
    orrdddcod        like datmlcl.dddcod          ,
    orrlcltelnum     like datmlcl.lcltelnum       ,
    orrlclcttnom     like datmlcl.lclcttnom       ,
    dstlclidttxt     like datmlcl.lclidttxt       ,
    dstlgdtxt        char (65)                    ,
    dstcidnom        like datmlcl.cidnom          ,
    dstbrrnom        like datmlcl.brrnom          ,
    dstlclbrrnom     like datmlcl.lclbrrnom       ,
    dstufdcod        like datmlcl.ufdcod
 end record

 define d_cts12m01   record
    rclnom           like gsakseg.segnom          ,
    vcldes           char (40)                    ,
    vcllicnum        like abbmveic.vcllicnum      ,
    vclchsfnl        like abbmveic.vclchsfnl      ,
    vclanofbc        like abbmveic.vclanofbc      ,
    vclanomdl        like abbmveic.vclanomdl      ,
    vstnum           dec  (6,0)                   ,
    vstano           like abbmveic.vclanofbc      ,
    prpnom           like gsakseg.segnom
 end record

 define ws           record
    emitecarta       char(01),
    ok               integer ,
    impr             char(08),
    cont             integer
 end record




	initialize  d_cts12m01.*  to  null

	initialize  ws.*  to  null

 initialize d_cts12m01.*   to null
 initialize ws.*           to null
 let ws.emitecarta      = "S"
 let d_cts12m01.prpnom  = param.nom

 open window cts12m01 at 11,18 with form "cts12m01"
                         attribute (border, form line 1)

 display by name d_cts12m01.*

 input by name d_cts12m01.rclnom   ,
               d_cts12m01.vcldes   ,
               d_cts12m01.vcllicnum,
               d_cts12m01.vclchsfnl,
               d_cts12m01.vclanofbc,
               d_cts12m01.vclanomdl,
               d_cts12m01.prpnom   ,
               d_cts12m01.vstnum   ,
               d_cts12m01.vstano   without defaults

   before field rclnom
          display by name d_cts12m01.rclnom attribute (reverse)

   after  field rclnom
          display by name d_cts12m01.rclnom

          if d_cts12m01.rclnom is null or
             d_cts12m01.rclnom =  "  " then
             next field prpnom
          end if

   before field vcldes
          display by name d_cts12m01.vcldes attribute (reverse)

   after  field vcldes
          display by name d_cts12m01.vcldes

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts12m01.vcldes is null  then
                error " Descricao do veiculo deve ser informada!"
                next field vcldes
             end if
          end if

   before field vcllicnum
          display by name d_cts12m01.vcllicnum   attribute (reverse)

   after  field vcllicnum
          display by name d_cts12m01.vcllicnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts12m01.vcllicnum   is null or
                d_cts12m01.vcllicnum   =  "  " then
                error " Placa do veiculo deve ser informada!"
                next field vcllicnum
             end if
          end if

   before field vclchsfnl
          display by name d_cts12m01.vclchsfnl   attribute (reverse)

   after  field vclchsfnl
          display by name d_cts12m01.vclchsfnl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts12m01.vclchsfnl   is null or
                d_cts12m01.vclchsfnl   =  "  " then
                error " Chassi do veiculo deve ser informado!"
                next field vclchsfnl
             end if
          end if

   before field vclanofbc
          display by name d_cts12m01.vclanofbc   attribute (reverse)

   after  field vclanofbc
          display by name d_cts12m01.vclanofbc

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts12m01.vclanofbc is null  then
                error " Ano de fabricacao deve ser informado!"
                next field vclanofbc
             end if
          end if

   before field vclanomdl
          display by name d_cts12m01.vclanomdl   attribute (reverse)

   after  field vclanomdl
          display by name d_cts12m01.vclanomdl

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts12m01.vclanomdl is null  then
                error " Ano modelo deve ser informado!"
                next field vclanomdl
             end if
          end if

   before field prpnom
          display by name d_cts12m01.prpnom     attribute (reverse)

   after  field prpnom
          display by name d_cts12m01.prpnom

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts12m01.prpnom     is null   or
                d_cts12m01.prpnom     =  "  "   then
                error " Nome do proprietario deve ser informado!"
                next field prpnom
             end if
          end if

   before field vstnum
          display by name d_cts12m01.vstnum    attribute (reverse)

   after  field vstnum
          display by name d_cts12m01.vstnum

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts12m01.vstnum is null  then
                error " Numero da vistoria deve ser informado!"
                next field vstnum
             end if
          end if

   before field vstano
          display by name d_cts12m01.vstano    attribute (reverse)

   after  field vstano
          display by name d_cts12m01.vstano

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts12m01.vstano is null  then
                error " Ano da vistoria deve ser informado!"
                next field vstano
             end if
          end if

   on key (interrupt)
      exit input

 end input

 if int_flag then
    let ws.emitecarta = "N"
 else
    call fun_print_seleciona (g_issk.dptsgl, "")
                   returning  ws.ok, ws.impr

    if ws.ok     =  0      or
       ws.impr   is null   then
       let ws.emitecarta = "N"
       error " Nenhuma impressora foi selecionada!"
       sleep 2
    else
       let wsg_pipe = "lp -sd ", ws.impr
       error " Aguarde, imprimindo carta de autorizacao de RPT..."

       start report  rep_cartarpt

       for ws.cont = 1 to 4
           output to report rep_cartarpt(param.*, d_cts12m01.*)
       end for

       finish report  rep_cartarpt
       error ""
    end if
 end if

 close window cts12m01
 return ws.emitecarta

end function  ###  cts12m01


#---------------------------------------------------------------------------
 report rep_cartarpt(param, r_cts12m01)
#---------------------------------------------------------------------------

 define param        record
    atdsrvorg        like datmservico.atdsrvorg   ,
    atdsrvnum        like datmservico.atdsrvnum   ,
    atdsrvano        like datmservico.atdsrvano   ,
    nom              like datmservico.nom         ,
    succod           like datrservapol.succod     ,
    ramcod           like datrservapol.ramcod     ,
    aplnumdig        like datrservapol.aplnumdig  ,
    itmnumdig        like datrservapol.itmnumdig  ,
    vcldes           like datmservico.vcldes      ,
    vclanomdl        like datmservico.vclanomdl   ,
    vcllicnum        like datmservico.vcllicnum   ,
    vclchsinc        like abbmveic.vclchsinc      ,
    vclchsfnl        like abbmveic.vclchsfnl      ,
    orrlclidttxt     like datmlcl.lclidttxt       ,
    orrlgdtxt        char (65)                    ,
    orrbrrnom        like datmlcl.lclbrrnom       ,
    orrlclbrrnom     like datmlcl.lclbrrnom       ,
    orrcidnom        like datmlcl.cidnom          ,
    orrufdcod        like datmlcl.ufdcod          ,
    orrdddcod        like datmlcl.dddcod          ,
    orrlcltelnum     like datmlcl.lcltelnum       ,
    orrlclcttnom     like datmlcl.lclcttnom       ,
    dstlclidttxt     like datmlcl.lclidttxt       ,
    dstlgdtxt        char (65)                    ,
    dstcidnom        like datmlcl.cidnom          ,
    dstbrrnom        like datmlcl.lclbrrnom       ,
    dstlclbrrnom     like datmlcl.lclbrrnom       ,
    dstufdcod        like datmlcl.ufdcod
 end record

 define r_cts12m01   record
    rclnom           like gsakseg.segnom          ,
    vcldes           char (40)                    ,
    vcllicnum        like abbmveic.vcllicnum      ,
    vclchsfnl        like abbmveic.vclchsfnl      ,
    vclanofbc        like abbmveic.vclanofbc      ,
    vclanomdl        like abbmveic.vclanomdl      ,
    vstnum           dec  (6,0)                   ,
    vstano           like abbmveic.vclanofbc      ,
    prpnom           like gsakseg.segnom
 end record

output report to pipe wsg_pipe
   page   length  66
   left   margin  00
   top    margin  00
   bottom margin  01

format

   on every row
        print ascii(027), ascii(018)
        skip  2 lines
        print column 002, "Sao Paulo, " , today
        skip  2 lines
        print column 002, "No. O.S...: ", param.atdsrvorg using "&&",
                          "/"           , param.atdsrvnum using "&&&&&&&",
                          "-"           , param.atdsrvano using "&&"
        skip  2 lines
        print column 002, "Oficina...: ", param.orrlclidttxt clipped
        skip  1 line
        print column 002, "Endereco..: ", param.orrlgdtxt    clipped
        skip  1 line
        if  param.orrlclbrrnom is not null and
            param.orrlclbrrnom <> " "      and
            param.orrlclbrrnom <> "."      then
            let param.orrbrrnom = param.orrbrrnom clipped, " - ",
                                  param.orrlclbrrnom
        end if

        print column 002, "Bairro....: ", param.orrbrrnom clipped
        skip  1 line
        print column 002, "Cidade....: ", param.orrcidnom    clipped, " - ",
                                          param.orrufdcod
        skip  1 line
        print column 002, "Telefone..: ", param.orrdddcod    clipped, " ",
                                          param.orrlcltelnum clipped
        skip  1 line
        print column 002, "Contato...: ", param.orrlclcttnom clipped
        skip  1 line
        print column 002, "Observacao: P.T."
        skip  2 lines

        if r_cts12m01.rclnom is not null then
           print column 002, "Reclamante: ", r_cts12m01.rclnom clipped
           skip 1 line
           print column 002, "Apolice...: ", param.succod    using "<<<&&",#"&&"  , projeto succod
                                        "/", param.ramcod    using "##&&"  ,
                                        "/", param.aplnumdig using "<<<<<<<& &",
                                        "/", param.itmnumdig using "<<<<<& &"
           skip  1 line
           print column 002, "Ref. Vist.: ", r_cts12m01.vstnum using "&&&&&&",
                 column 020, "/"           , r_cts12m01.vstano
           skip  1 line
           print column 002, "Veiculo...: ", r_cts12m01.vcldes      clipped,
                 column 055, "Ano F/M:  ",   r_cts12m01.vclanofbc   clipped,
                             "/" clipped   , r_cts12m01.vclanomdl
           skip  1 line
           print column 002, "Chassi....: ", r_cts12m01.vclchsfnl   clipped,
                 column 055, "Placa..: "   , r_cts12m01.vcllicnum
        else
           print column 002, "Segurado..: ", param.nom        clipped
           skip 1 line
           print column 002, "Apolice...: ", param.succod    using "<<<&&",#"&&"  , projeto succod
                                        "/", param.ramcod    using "##&&"  ,
                                        "/", param.aplnumdig using "<<<<<<<& &",
                                        "/", param.itmnumdig using "<<<<<& &"
           skip  1 line
           print column 002, "Ref. Vist.: ", r_cts12m01.vstnum using "&&&&&&",
                 column 020, "/"           , r_cts12m01.vstano
           skip  1 line
           print column 002, "Veiculo...: ", param.vcldes      clipped,
                 column 055, "Ano F/M: ",    param.vclanomdl          ,
                             "/" clipped   , param.vclanomdl
           skip  1 line
           print column 002, "Chassi....: ", param.vclchsinc   clipped,
                                             param.vclchsfnl,
                 column 055, "Placa..: "   , param.vcllicnum
        end if
        skip  2 lines

        if param.orrufdcod <> "SP" then
           print column 002, "*** ATENCAO:",
                 column 014,
           "Para recebimento deste servico,favor enviar a sucursal Porto"
           print column 014,
           "Seguro em 24hrs,copia ou fax do laudo de remocao  totalmente"
           print column 014, "preenchido e assinado pela recepcao do patio."
        end if

        skip 2 lines
        print column 002,
        "Autorizamos a  remocao do  veiculo acima discriminado  de propriedade do"
        print column 002,
        "Sr(a) ", r_cts12m01.prpnom[01,40], " que encontra-se  estacio-"

        print column 002,
        "nado impossibilitado de se locomover por meios proprios e leva-lo para o"

        print column 002, param.dstlclidttxt clipped, " ",
                          param.dstlgdtxt    clipped, "."

        if  param.dstlclbrrnom is not null and
            param.dstlclbrrnom <> " "      and
            param.dstlclbrrnom <> "."      then
            let param.dstbrrnom = param.dstbrrnom clipped, " - ",
                                  param.dstlclbrrnom
        end if

        print column 002, param.dstlclbrrnom clipped, " / ",
                          param.dstcidnom    clipped, "/"  ,
                          param.dstufdcod, "."
        skip  4 lines
        print column 002, "Desde ja' agradecemos pelas urgentes providencias."
        skip  5 lines
        print column 002, "Atentamente,"

        skip to top of page

end report
