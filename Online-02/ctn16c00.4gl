#############################################################################
# Nome do Modulo: CTN16C00                                            Pedro #
#                                                                   Marcelo #
# Consulta saldo de diarias de clausulas - Carro Extra             Ago/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/10/1998               Gilberto     Incluir mensagem de espera durante  #
#                                       calculo do saldo de diarias.        #
#---------------------------------------------------------------------------#
# 20/10/1999               Gilberto     Alterar acesso ao cadastro de clau- #
#                                       sulas (ramo 31).                    #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function ctn16c00()
#------------------------------------------------------------

 define k_ctn16c00    record
    succod            like abbmclaus.succod   ,
    aplnumdig         like abbmclaus.aplnumdig,
    itmnumdig         like abbmclaus.itmnumdig,
    clcdat            date                    ,
    viginc            like abbmclaus.viginc   ,
    vigfnl            like abbmclaus.vigfnl
 end record

 define ws            record
    privez            smallint
 end record

 let int_flag  = false
 let ws.privez = true

 initialize k_ctn16c00.* to  null

 open window ctn16c00 at 04,02 with form "ctn16c00"

 menu "SALDO"

 command "Seleciona" "Seleciona documento para consulta"
          call ctn16c00_seleciona(ws.privez) returning k_ctn16c00.*

          if k_ctn16c00.succod    is not null  and
             k_ctn16c00.aplnumdig is not null  and
             k_ctn16c00.itmnumdig is not null  then
             if ws.privez = true  then
                let ws.privez = false
             end if

             next option "Reservas"
          else
             error " Nenhum documento selecionado!"
             next option "Seleciona"
          end if

 command "Reservas" "Consulta reservas solicitadas e confirmadas"
          if k_ctn16c00.succod    is not null  and
             k_ctn16c00.aplnumdig is not null  and
             k_ctn16c00.itmnumdig is not null  then
             call ctn16c01(k_ctn16c00.*)
          else
             error " Nenhum documento selecionado!"
             next option "Seleciona"
          end if

 command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
          exit menu
 end menu

 close window ctn16c00

end function  ###  ctn16c00

#------------------------------------------------------------
 function ctn16c00_seleciona(param)
#------------------------------------------------------------

 define param        record
    privez           smallint
 end record

 define d_ctn16c00   record
    succod           like abbmclaus.succod   ,
    aplnumdig        like abbmclaus.aplnumdig,
    itmnumdig        like abbmclaus.itmnumdig,
    clcdat           date                   ,
    segnom           like gsakseg.segnom    ,
    vcldes           char (40)              ,
    vcllicnum        like abbmveic.vcllicnum,
    viginc           like abamapol.viginc   ,
    vigfnl           like abamapol.vigfnl   ,
    clscod           like abbmclaus.clscod  ,
    clsdes           char (40)              ,
    sldqtd           smallint
 end record

 define ws           record
    itmqtd           smallint,
    tabnum           like itatvig.tabnum     ,
    sucnom           like gabksuc.sucnom     ,
    segnumdig        like gsakseg.segnumdig  ,
    vclmrccod        like agbkmarca.vclmrccod,
    vcltipcod        like agbktip.vcltipcod  ,
    vclcoddig        like agbkveic.vclcoddig ,
    vclmrcnom        like agbkmarca.vclmrcnom,
    vcltipnom        like agbktip.vcltipnom  ,
    vclmdlnom        like agbkveic.vclmdlnom
 end record

 clear form
 initialize d_ctn16c00.*, ws.*, g_funapol.*  to null

 input by name d_ctn16c00.succod   ,
               d_ctn16c00.aplnumdig,
               d_ctn16c00.itmnumdig,
               d_ctn16c00.clcdat

    before field succod
       display by name d_ctn16c00.succod attribute (reverse)

    after  field succod
       display by name d_ctn16c00.succod

       if d_ctn16c00.succod  is null  then
          error " Sucursal deve ser informada!"
          next field succod
       end if

       select succod from gabksuc
        where succod = d_ctn16c00.succod

       if sqlca.sqlcode = notfound  then
          error " Sucursal nao cadastrada!"
          call c24geral11() returning d_ctn16c00.succod, ws.sucnom
          next field succod
       end if

    before field aplnumdig
       display by name d_ctn16c00.aplnumdig  attribute (reverse)

    after  field aplnumdig
       display by name d_ctn16c00.aplnumdig

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field succod
       end if

       if d_ctn16c00.aplnumdig  is null  then
          error " Apolice deve ser informada!"
          next field aplnumdig
       end if

       call F_FUNDIGIT_DIGAPOL (d_ctn16c00.succod, 31, d_ctn16c00.aplnumdig)
                      returning d_ctn16c00.aplnumdig

       if d_ctn16c00.aplnumdig is null  then
          call F_FUNDIGIT_DIGAPOL (d_ctn16c00.succod, 531, d_ctn16c00.aplnumdig)
                      returning d_ctn16c00.aplnumdig

          if d_ctn16c00.aplnumdig is null  then
             error " Problemas no digito da apolice. AVISE A INFORMATICA!"
             next field aplnumdig
          end if
       end if

       initialize d_ctn16c00.viginc, d_ctn16c00.vigfnl  to null

       select viginc, vigfnl
         into d_ctn16c00.viginc,
              d_ctn16c00.vigfnl
         from abamapol
        where succod    = d_ctn16c00.succod     and
              aplnumdig = d_ctn16c00.aplnumdig

       if sqlca.sqlcode = notfound   then
          error " Apolice nao cadastrada!"
          next field aplnumdig
       end if

    before field itmnumdig
       display by name d_ctn16c00.itmnumdig  attribute (reverse)

    after  field itmnumdig
       display by name d_ctn16c00.itmnumdig

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field aplnumdig
       end if

       if d_ctn16c00.itmnumdig  is null  then
          error " Item deve ser informado !!"
          next field itmnumdig
       end if

       call F_FUNDIGIT_DIGITO11 (d_ctn16c00.itmnumdig)
                       returning d_ctn16c00.itmnumdig

       if d_ctn16c00.itmnumdig  is null   then
          error " Problemas no digito do item. AVISE A INFORMATICA!"
          next field itmnumdig
       end if

       let ws.itmqtd = 0

       select count(distinct itmnumdig) into ws.itmqtd
         from abbmitem
        where succod    = d_ctn16c00.succod    and
              aplnumdig = d_ctn16c00.aplnumdig    and
              itmnumdig = d_ctn16c00.itmnumdig

       if ws.itmqtd = 0  then
          error " Item nao existe neste documento!"
          next field itmnumdig
       end if

     before field clcdat
        let d_ctn16c00.clcdat = today

        display by name d_ctn16c00.clcdat  attribute (reverse)

     after  field clcdat
        if d_ctn16c00.clcdat is null  then
           error " Data para calculo do saldo deve ser informada!"
           next field clcdat
        end if

        if d_ctn16c00.clcdat < d_ctn16c00.viginc  then
           error " Data para calculo nao deve ser menor que inicio de vigencia da apolice!"
           next field clcdat
        end if

        if d_ctn16c00.clcdat > d_ctn16c00.vigfnl  then
           error " Data para calculo nao deve ser maior que final de vigencia da apolice!"
           next field clcdat
        end if

        display by name d_ctn16c00.clcdat  attribute (reverse)

        message " Aguarde, calculando saldo de diarias..." attribute (reverse)

#------------------------------------------------------------
# Ultima situacao da apolice
#------------------------------------------------------------

        call f_funapol_ultima_situacao
             (d_ctn16c00.succod, d_ctn16c00.aplnumdig, d_ctn16c00.itmnumdig)
              returning  g_funapol.*

#------------------------------------------------------------
# Saldo da clausula
#------------------------------------------------------------

        call ctx01g00_saldo (d_ctn16c00.succod   , d_ctn16c00.aplnumdig,
                             d_ctn16c00.itmnumdig, "", "",
                             d_ctn16c00.clcdat, 1, param.privez,1)
                   returning d_ctn16c00.sldqtd

        if d_ctn16c00.sldqtd is null  then
           let d_ctn16c00.sldqtd = 0
        end if

        if param.privez = true  then
           let param.privez = false
        end if

#------------------------------------------------------------
# Vigencia da clausula
#------------------------------------------------------------

        call ctx01g01_claus (d_ctn16c00.succod   , d_ctn16c00.aplnumdig,
                             d_ctn16c00.itmnumdig, d_ctn16c00.clcdat   ,
                             param.privez)
                   returning d_ctn16c00.clscod,
                             d_ctn16c00.viginc,
                             d_ctn16c00.vigfnl

        if d_ctn16c00.clscod is not null  then
           let ws.tabnum = F_FUNGERAL_TABNUM("aackcls", d_ctn16c00.viginc)

           select clsdes into d_ctn16c00.clsdes
             from aackcls
            where tabnum = ws.tabnum
              and ramcod = 531
              and clscod = d_ctn16c00.clscod
        end if

#------------------------------------------------------------
# Dados do segurado
#------------------------------------------------------------

        select segnumdig
          into ws.segnumdig
          from abbmdoc
         where succod    = d_ctn16c00.succod      and
               aplnumdig = d_ctn16c00.aplnumdig   and
               itmnumdig = d_ctn16c00.itmnumdig   and
               dctnumseq = g_funapol.dctnumseq

        if sqlca.sqlcode  <>  notfound   then
           let d_ctn16c00.segnom = "SEGURADO NAO CADASTRADO!"

           select segnom
             into d_ctn16c00.segnom
             from gsakseg
            where segnumdig = ws.segnumdig
        end if

#------------------------------------------------------------
# Dados do veiculo
#------------------------------------------------------------

        select vclcoddig   , vcllicnum
          into ws.vclcoddig, d_ctn16c00.vcllicnum
          from abbmveic
         where succod     = d_ctn16c00.succod     and
               aplnumdig  = d_ctn16c00.aplnumdig  and
               itmnumdig  = d_ctn16c00.itmnumdig  and
               dctnumseq  = g_funapol.vclsitatu

        if sqlca.sqlcode  <>  notfound   then
           select vclmrccod, vcltipcod, vclmdlnom
             into ws.vclmrccod, ws.vcltipcod, ws.vclmdlnom
             from agbkveic
            where vclcoddig = ws.vclcoddig

           select vclmrcnom
             into ws.vclmrcnom
             from agbkmarca
            where vclmrccod = ws.vclmrccod

           select vcltipnom
             into ws.vcltipnom
             from agbktip
            where vclmrccod = ws.vclmrccod    and
                  vcltipcod = ws.vcltipcod

           let d_ctn16c00.vcldes = ws.vclmrcnom  clipped, " ",
                                   ws.vcltipnom  clipped, " ",
                                   ws.vclmdlnom
        else
           error "Dados do veiculo nao encontrado!"
        end if

        message ""

        display by name d_ctn16c00.*

     on key (interrupt)
            exit input

  end input

 if int_flag  then
    initialize d_ctn16c00.*  to null
    clear form
    error " Operacao cancelada!"
 end if

 let int_flag = false

 return d_ctn16c00.succod, d_ctn16c00.aplnumdig, d_ctn16c00.itmnumdig,
        d_ctn16c00.clcdat, d_ctn16c00.viginc   , d_ctn16c00.vigfnl

end function  ###  ctn16c00_seleciona
