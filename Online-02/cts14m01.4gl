###############################################################################
# Nome do Modulo: CTS14M01                                              Pedro #
#                                                                     Marcelo #
# Alteracao/Consulta/Cancelamento de Vistoria de Sinistro            Jun/1995 #
###############################################################################
#                           A  T  E  N  C  A  O                               #
###############################################################################
# Este modulo possui uma versao de consulta no sistema de sinistro(ssatc101)  #
#-----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
###############################################################################
#---------------------------------------------------------------------------#
#                                                                           #
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor  Fabrica  Origem    Alteracao                            #
# ---------- ------ -------  -------   -------------------------------------#
# 21/10/2004 Daniel, Meta    PSI188514 Nas chamadas da funcao cto00m00      #
#                                      passar como parametro o numero 1     #
#---------------------------------------------------------------------------#
# 03/03/2006 Priscila        Zeladoria Buscar data e hora do banco de dados #
#---------------------------------------------------------------------------#
# 04/01/2010 Amilton                   Projeto sucursal smallint            #
#---------------------------------------------------------------------------#
# 28/09/2012  Raul Biztalking          Retirar empresa 1 fixa p/ funcionario#
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define d_cts14m01    record
    sinvstnum         like datmvstsin.sinvstnum,
    sinvstano         like datmvstsin.sinvstano,
    vstsolnom         like datmvstsin.vstsolnom,
    segnom            like datmvstsin.segnom   ,
    doctxt            char (06)                ,
    docnum            char (25)                ,
    cornom            like datmvstsin.cornom   ,
    corsus            like datmvstsin.corsus   ,
    cvnnom            char (19)                ,
    vcldes            like datmvstsin.vcldes   ,
    vclanomdl         like datmvstsin.vclanomdl,
    vcllicnum         like datmvstsin.vcllicnum,
    vclchsinc         like datmvstsin.vclchsinc, ## psi191965
    vclchsfnl         like datmvstsin.vclchsfnl,
    sinvstrgi         like datmvstsin.sinvstrgi,
    descricao         char (22)                ,
    sindat            like datmvstsin.sindat   ,
    sinavs            like datmvstsin.sinavs   ,
    avisocom          char (09)                ,
    orcvlr            like datmvstsin.orcvlr   ,
    nomrazsoc         like gkpkpos.nomrazsoc   ,
    ofnnumdig         like datmvstsin.ofnnumdig,
    endlgd            like gkpkpos.endlgd      ,
    endbrr            like gkpkpos.endbrr      ,
    endcid            like gkpkpos.endcid      ,
    endufd            like gkpkpos.endufd      ,
    dddcodofi         like gkpkpos.dddcod      ,
    telnumofi         like gkpkpos.telnum1     ,
    vstdat            like datmvstsin.vstdat   ,
    dddcodctt         char (04)                ,
    telnumctt         char (20)                ,
    vstretdat         like datmvstsin.vstretdat,
    registro          char (45)
 end record

 define w_cts14m01    record
    data              char (10)                ,
    hora              char (05)                ,
    vstretflg         like datmvstsin.vstretflg,
    canflg            char (01)
 end record

#--------------------------------------------------------------------
 function cts14m01(par_sinvstnum, par_sinvstano)
#--------------------------------------------------------------------

 define  par_sinvstnum like datmvstsin.sinvstnum
 define  par_sinvstano like datmvstsin.sinvstano

 define l_data      date,
        l_hora2     datetime hour to minute

 initialize d_cts14m01.*  to null
 initialize w_cts14m01.*  to null

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 let w_cts14m01.data      = l_data
 let w_cts14m01.hora      = l_hora2
 let w_cts14m01.vstretflg = "N"

 let int_flag = false

 open window cts14m01 at  4,2 with form "cts14m01"

 menu "VIST_SINISTRO"

   command key ("S") "Seleciona" "Seleciona vistoria de sinistro"
            call seleciona_cts14m01(par_sinvstnum, par_sinvstano)
            if w_cts14m01.canflg <> "S" then
               next option "Retorno"
            end if

   command key ("H") "Historico" "Historico da vistoria de sinistro"
            if d_cTS14M01.sinvstnum is not null then
               call cts14m10(d_cts14m01.sinvstnum, d_cts14m01.sinvstano,
                             g_issk.funmat       , w_cts14m01.data     ,
                             w_cts14m01.hora)
               initialize d_cts14m01.* to null
               next option "Encerra"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("R") "Retorno"  "Marca retorno da vistoria de sinistro"
            if d_cts14m01.sinvstnum is not null then
               if w_cts14m01.canflg =  "S" then
                  error " Vistoria cancelada!"
                  next option "Encerra"
               else
                  call modifica_cts14m01(d_cts14m01.sinvstnum,
                                         d_cts14m01.sinvstano)
                  initialize d_cts14m01.* to null
                  next option "Encerra"
               end if
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key ("C") "Cancela"  "Cancela vistoria de sinistro"
            if d_cts14m01.sinvstnum is not null then
               call cancela_cts14m01(d_cts14m01.sinvstnum, d_cts14m01.sinvstano)
               initialize d_cts14m01.* to null
               next option "Encerra"
            else
               error " Nenhum registro selecionado!"
               next option "Seleciona"
            end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            if d_cts14m01.sinvstnum is not null then
               call cts14m10(d_cts14m01.sinvstnum, d_cts14m01.sinvstano,
                             g_issk.funmat       , w_cts14m01.data     ,
                             w_cts14m01.hora)
               initialize d_cts14m01.* to null
            end if
            exit menu
 end menu

 close window cts14m01

end function  ###  cts14m01

#--------------------------------------------------------------------
 function seleciona_cts14m01(param)
#--------------------------------------------------------------------

 define param         record
    sinvstnum         like datmvstsin.sinvstnum,
    sinvstano         like datmvstsin.sinvstano
 end record

 define ws            record
    atddat            like datmvstsin.atddat    ,
    atdhor            like datmvstsin.atdhor    ,
    funmat            like datmvstsin.funmat    ,
    lignum            like datmligacao.lignum   ,
    ligcvntip         like datmligacao.ligcvntip,
    ramcod            like datmvstsin.ramcod    ,
    succod            like datrligapol.succod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    prporg            like papmhist.prporg      ,
    prpnumdig         like papmhist.prpnumdig   ,
    empcod            like datmvstsin.empcod                          #Raul, Biz
 end record

 define l_chassi      char(40)

	initialize  ws.*  to  null

 initialize d_cts14m01.*  to null
 initialize l_chassi to null
 initialize ws.*          to null

 let ws.atddat = w_cts14m01.data
 let ws.atdhor = w_cts14m01.hora
 let w_cts14m01.canflg = "N"

 let int_flag = false

 let d_cts14m01.sinvstnum = param.sinvstnum
 let d_cts14m01.sinvstano = param.sinvstano

#----------- DADOS DA VISTORIA DE SINISTRO -----------

 select vstsolnom,
        segnom   ,
        succod   ,
        aplnumdig,
        itmnumdig,
        dddcod   ,
        teltxt   ,
        cornom   ,
        corsus   ,
        vcldes   ,
        vclanomdl,
        vcllicnum,
        vclchsinc, ## psi191965
        vclchsfnl,
        sinvstrgi,
        sindat   ,
        sinavs   ,
        orcvlr   ,
        ofnnumdig,
        vstdat   ,
        vstretdat,
        funmat   ,
        atddat   ,
        atdhor   ,
        ramcod   ,
        vstretflg,
        prporg   ,
        prpnumdig,
        empcod                                                        #Raul, Biz
   into d_cts14m01.vstsolnom,
        d_cts14m01.segnom   ,
        ws.succod           ,
        ws.aplnumdig        ,
        ws.itmnumdig        ,
        d_cts14m01.dddcodctt,
        d_cts14m01.telnumctt,
        d_cts14m01.cornom   ,
        d_cts14m01.corsus   ,
        d_cts14m01.vcldes   ,
        d_cts14m01.vclanomdl,
        d_cts14m01.vcllicnum,
        d_cts14m01.vclchsinc, ## psi191965
        d_cts14m01.vclchsfnl,
        d_cts14m01.sinvstrgi,
        d_cts14m01.sindat   ,
        d_cts14m01.sinavs   ,
        d_cts14m01.orcvlr   ,
        d_cts14m01.ofnnumdig,
        d_cts14m01.vstdat   ,
        d_cts14m01.vstretdat,
        ws.funmat           ,
        ws.atddat           ,
        ws.atdhor           ,
        ws.ramcod           ,
        w_cts14m01.vstretflg,
        ws.prporg           ,
        ws.prpnumdig        ,
        ws.empcod                                                     #Raul, Biz
   from datmvstsin
  where sinvstnum = d_cts14m01.sinvstnum  and
        sinvstano = d_cts14m01.sinvstano

 if sqlca.sqlcode = notfound  then
    error " Vistoria nao encontrada. AVISE A INFORMATICA!"
    return
 end if

 let ws.lignum = cts20g00_sinvst(d_cts14m01.sinvstnum, d_cts14m01.sinvstano, 1)

 if ws.succod    is not null  and
    ws.aplnumdig is not null  then
    let d_cts14m01.doctxt = "Apol.:"
    let d_cts14m01.docnum = ws.succod using "<<<&&",#"&&", " ", projeto succod
                            ws.aplnumdig using "<<<<<<<& &", " ", ws.itmnumdig using "<<<<<<& &"
 else
    if ws.prporg    is not null  and
       ws.prpnumdig is not null  then
       let d_cts14m01.doctxt = "Prop.:"
       let d_cts14m01.docnum = ws.prporg using "&&", " ", ws.prpnumdig using "&&&&&&&&"
     end if
 end if

 if ws.ramcod = 53      or
    ws.ramcod = 553   then
    display "TERCEIRO" to sinvsttip
 else
    display "SEGURADO" to sinvsttip
 end if

 if d_cts14m01.vstdat = d_cts14m01.vstretdat   then
    if  w_cts14m01.vstretflg = "N"  or
        w_cts14m01.vstretflg = "P"  or    ### vistoria pateo
        w_cts14m01.vstretflg = "R"  then  ### vistoria furto/roubo
        initialize d_cts14m01.vstretdat to null
    end if
 end if

 #----------- VERIFICA SE VISTORIA DE SINISTRO ESTA' CANCELADA -----------

 select sinvstnum
   from datmvstsincanc
  where sinvstnum = d_cts14m01.sinvstnum  and
        sinvstano = d_cts14m01.sinvstano

 if sqlca.sqlcode <> notfound then
    let w_cts14m01.canflg = "S"
    error " Nao e' possivel alterar uma vistoria de sinistro cancelada!"
 end if

 #----------- LOCALIZA A LIGACAO DA MARCACAO DE VISTORIA DE SINISTRO ----------

 select ligcvntip
   into ws.ligcvntip
   from datmligacao
  where lignum = ws.lignum

 case d_cts14m01.sinavs
    when "C"  let d_cts14m01.avisocom = "Corretor"
    when "O"  let d_cts14m01.avisocom = "Oficina"
    when "I"  let d_cts14m01.avisocom = "Cia"
 end case

 case d_cts14m01.sinvstrgi
    when "S"  let d_cts14m01.descricao = "Capital e Grande S.P."
    when "N"  let d_cts14m01.descricao = "Interior"
 end case

 select cpodes
   into d_cts14m01.cvnnom
   from datkdominio
  where cponom = "ligcvntip" and
        cpocod = ws.ligcvntip

 call funcionario_cts14m01(ws.funmat, ws.atddat, ws.atdhor, ws.empcod)
                 returning d_cts14m01.registro

 select nomrazsoc,
        endlgd   ,
        endbrr   ,
        endcid   ,
        endufd   ,
        dddcod   ,
        telnum1
   into d_cts14m01.nomrazsoc,
        d_cts14m01.endlgd   ,
        d_cts14m01.endbrr   ,
        d_cts14m01.endcid   ,
        d_cts14m01.endufd   ,
        d_cts14m01.dddcodofi,
        d_cts14m01.telnumofi
   from gkpkpos
  where pstcoddig  =  d_cts14m01.ofnnumdig

 if sqlca.sqlcode = notfound then
    error " Dados da oficina nao encontrado!"
 end if
 let l_chassi = d_cts14m01.vclchsinc clipped, d_cts14m01.vclchsfnl clipped
 ## psi191965 display by name d_cts14m01.*
 display by name d_cts14m01.sinvstnum
 display by name d_cts14m01.sinvstano
 ##display by name d_cts14m01.vstsolnom
 display by name d_cts14m01.segnom
 display by name d_cts14m01.doctxt
 display by name d_cts14m01.docnum
 display by name d_cts14m01.cornom
 display by name d_cts14m01.corsus
 ##display by name d_cts14m01.cvnnom
 display by name d_cts14m01.vcldes
 display by name d_cts14m01.vclanomdl
 display by name d_cts14m01.vcllicnum
 display l_chassi to chassi
 ##display by name l_chassi
 display by name d_cts14m01.sinvstrgi
 display by name d_cts14m01.descricao
 display by name d_cts14m01.sindat
 display by name d_cts14m01.sinavs
 display by name d_cts14m01.avisocom
 display by name d_cts14m01.orcvlr
 display by name d_cts14m01.nomrazsoc
 display by name d_cts14m01.ofnnumdig
 display by name d_cts14m01.endlgd
 display by name d_cts14m01.endbrr
 display by name d_cts14m01.endcid
 display by name d_cts14m01.endufd
 display by name d_cts14m01.dddcodofi
 display by name d_cts14m01.telnumofi
 display by name d_cts14m01.vstdat
 display by name d_cts14m01.dddcodctt
 display by name d_cts14m01.telnumctt
 display by name d_cts14m01.vstretdat
 display by name d_cts14m01.registro

 display by name d_cts14m01.vstsolnom attribute (reverse)
 display by name d_cts14m01.cvnnom    attribute (reverse)

end function  ###  seleciona_cts14m01

#------------------------------------------------------------------------------#
function modifica_cts14m01 (param)
#------------------------------------------------------------------------------#
   define param record
      sinvstnum like datmvstsin.sinvstnum,
      sinvstano like datmvstsin.sinvstano
   end record

   call input_cts14m01 (param.*)

   if (int_flag) then
      let int_flag = false
      error " Operacao cancelada!"
      initialize d_cts14m01.* to null
      initialize w_cts14m01.* to null
      clear form

      return
   end if

   update datmvstsin
   set (vstretdat, vstretflg, sinvstsolsit) =
       (d_cts14m01.vstretdat, w_cts14m01.vstretflg, "S")
   where sinvstnum = param.sinvstnum and sinvstano = param.sinvstano

   if sqlca.sqlcode <> 0 then
      error " Erro (", sqlca.sqlcode, ") no retorno da vistoria. AVISE A INFORMATICA!"
   else
      error " Retorno efetuado com sucesso!"
      clear form
   end if
end function  ###  modifica_cts14m01

#--------------------------------------------------------------------
 function input_cts14m01(param)
#--------------------------------------------------------------------

 define param         record
    sinvstnum         like datmvstsin.sinvstnum,
    sinvstano         like datmvstsin.sinvstano
 end record

 define ws            record
    vstsegflg         like gkpkregi.vstsegflg   ,
    vstterflg         like gkpkregi.vstterflg   ,
    vstquaflg         like gkpkregi.vstquaflg   ,
    vstquiflg         like gkpkregi.vstquiflg   ,
    vstsexflg         like gkpkregi.vstsexflg   ,
    vstdattxt         char (40)                 ,
    succod            like sgokofi.succod       ,
    ofnrgicod         like gkpkbairro.ofnrgicod ,
    utldat            date
 end record

 define  l_data      date,
         l_hora2     datetime hour to minute

   # LH - Inicio 30/06/2009
   define l_mens char(80)
   # LH - Fim 30/06/2009

	initialize  ws.*  to  null

 initialize ws.*  to null

 input by name d_cts14m01.vstretdat   without defaults

   before field vstretdat
          display by name d_cts14m01.vstretdat attribute (reverse)

   after  field vstretdat
          display by name d_cts14m01.vstretdat

          select ofnrgicod, succod
            into ws.ofnrgicod, ws.succod
            from sgokofi
           where ofnnumdig = d_cts14m01.ofnnumdig

          if ws.succod is null  then
             let ws.succod = 1
          end if

          if d_cts14m01.vstretdat is null then
             error " Opcoes de data de retorno para esta cidade!"

             call cts14m04 (ws.succod, ws.ofnrgicod, w_cts14m01.vstretflg)
                  returning d_cts14m01.vstretdat

             next field vstretdat
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          if d_cts14m01.vstretdat <= l_data  then
             error " Data do retorno invalida!"
             next field vstretdat
          end if

          if d_cts14m01.vstretdat <= d_cts14m01.vstdat or
             d_cts14m01.vstretdat is null then
             error " Data do retorno nao pode ser menor ou igual a data da vistoria!"
             next field vstretdat
          end if

          if d_cts14m01.vstretdat  > l_data + 30 units day  then
             error " Data do retorno excede 1 mes!"
             next field vstretdat
          end if

          if weekday(d_cts14m01.vstretdat) = 0 or
             weekday(d_cts14m01.vstretdat) = 6 then
             error " Nao fazemos retornos nos finais de semana!"
             next field vstretdat
          end if

          if time > "18:00:00"             and
             d_cts14m01.vstretdat = l_data + 1 units day  then
             error " Apos as 18:00 retorno em 48 horas uteis!"
             next field vstretdat
          end if

          if weekday(l_data)  =  0   then    ### Marcando vistoria no domingo
             if d_cts14m01.vstretdat < l_data + 2 units day  then
                error " Retorno em 24 horas uteis!"
                next field vstretdat
             end if
          end if

          if weekday(l_data)  =  6   then    ### Marcando vistoria no sabado
             if d_cts14m01.vstretdat < l_data + 3 units day  then
                error " Retorno em 24 horas uteis!"
                next field vstretdat
             end if
          end if

          if weekday(l_data)  =  5   then    ### Marcando retorno na sexta
             if d_cts14m01.vstretdat < l_data + 4 units day and
                time > "18:00:00"                          then
                error " Retorno em 24 horas uteis!"
                next field vstretdat
             end if
          end if

          call dias_uteis(d_cts14m01.vstretdat, 0, "", "N", "N")
                returning ws.utldat

          if ws.utldat is not null              and
             d_cts14m01.vstretdat <> ws.utldat  then
             error " Nao fazemos vistorias em feriados!"
             next field vstretdat
          end if

          select vstsegflg,
                 vstterflg,
                 vstquaflg,
                 vstquiflg,
                 vstsexflg
            into ws.vstsegflg,
                 ws.vstterflg,
                 ws.vstquaflg,
                 ws.vstquiflg,
                 ws.vstsexflg
            from gkpkregi
           where succod    = ws.succod  and
                 ofnrgicod = ws.ofnrgicod

          if weekday(d_cts14m01.vstretdat) = 1  then
             if ws.vstsegflg is null or
                ws.vstsegflg =  "N"  then
                error " Esta regiao nao faz vistoria as segundas-feiras!"
                next field vstretdat
             end if
          end if

          if weekday(d_cts14m01.vstretdat) = 2  then
             if ws.vstterflg is null or
                ws.vstterflg =  "N"  then
                error " Esta regiao nao faz vistoria as tercas-feiras!"
                next field vstretdat
             end if
          end if

          if weekday(d_cts14m01.vstretdat) = 3  then
             if ws.vstquaflg is null or
                ws.vstquaflg =  "N"  then
                error " Esta regiao nao faz vistoria as quartas-feiras!"
                next field vstretdat
             end if
          end if

          if weekday(d_cts14m01.vstretdat) = 4  then
             if ws.vstquiflg is null or
                ws.vstquiflg =  "N"  then
                error " Esta regiao nao faz vistoria as quintas-feiras!"
                next field vstretdat
             end if
          end if

          if weekday(d_cts14m01.vstretdat) = 5  then
             if ws.vstsexflg is null or
                ws.vstsexflg =  "N"  then
                error " Esta regiao nao faz vistoria as sextas-feiras!"
                next field vstretdat
             end if
          end if

          let ws.vstdattxt = "MARCADO PARA ", d_cts14m01.vstretdat
          if cts08g01("C", "S", "", "RETORNO DA VISTORIA DE SINISTRO", ws.vstdattxt, "") = "N"  then
             next field vstretdat
          end if

          # LH - Inicio - 30/06/2009
          let l_mens = null
          call roteiriza (param.sinvstnum, param.sinvstano) returning l_mens
          if (l_mens is not null) then
             error l_mens
             sleep 2
             let d_cts14m01.vstretdat = null
             next field vstretdat
          end if
          # LH - Fim - 30/06/2009

          let w_cts14m01.vstretflg = "S"
          error " REGISTRE O MOTIVO DO RETORNO!"
          call cts14m10(param.sinvstnum, param.sinvstano, g_issk.funmat  ,
                        w_cts14m01.data, w_cts14m01.hora)

   on key (interrupt)
      exit input

 end input

 if int_flag  then
    error " Operacao cancelada!"
 end if

end function  ###  input_cts14m01

#--------------------------------------------------------------------
 function cancela_cts14m01(param)
#--------------------------------------------------------------------

 define param         record
    sinvstnum         like datmvstsin.sinvstnum,
    sinvstano         like datmvstsin.sinvstano
 end record

 define d_cts14m01c record
    c24solnom       like datmvstsincanc.solnom,
    c24soltipcod    like datmvstsincanc.vstsoltipcod,
    c24soltipdes    like datksoltip.c24soltipdes,
    canmtvdes       like datmvstsincanc.canmtvdes,
    cabec           char (09),
    registro        char (45)
 end record

 define ws          record
    funmat          like isskfunc.funmat        ,
    atddat          like datmvstsin.atddat      ,
    atdhor          like datmvstsin.atdhor      ,
    sinvstsit       like datmvstsin.sinvstsolsit,
    operacao        char (01),
    soltip          like datmvstsincanc.soltip,
    empcod          like datmvstsincanc.empcod                        #Raul, Biz
 end record




	initialize  d_cts14m01c.*  to  null

	initialize  ws.*  to  null

 initialize d_cts14m01c.*  to null
 initialize ws.*           to null

 open window w_cts14m01c at 12,16 with form "cts06m01"
                         attribute(border, form line 1)

#--------------------------------------
# VERIFICA SE JA' EXISTE O CANCELAMENTO
#--------------------------------------
 select canmtvdes, solnom, vstsoltipcod,
        atdhor   , atddat, funmat,
        empcod                                                        #Raul, Biz
   into d_cts14m01c.canmtvdes, d_cts14m01c.c24solnom,
        d_cts14m01c.c24soltipcod, ws.atdhor            ,
        ws.atddat            , ws.funmat,
        ws.empcod                                                     #Raul, Biz
   from datmvstsincanc
  where sinvstnum = param.sinvstnum    and
        sinvstano = param.sinvstano

 if sqlca.sqlcode = notfound   then
    let ws.operacao = "I"
    let ws.atddat   = w_cts14m01.data
    let ws.atdhor   = w_cts14m01.hora
 else
    let ws.operacao = "M"

    let d_cts14m01c.cabec = "Atualiz.:"

    call funcionario_cts14m01(ws.funmat, ws.atddat, ws.atdhor, ws.empcod)
         returning d_cts14m01c.registro

    select c24soltipdes
      into d_cts14m01c.c24soltipdes
      from datksoltip
           where c24soltipcod = d_cts14m01c.c24soltipcod

 end if

 input by name d_cts14m01c.*   without defaults

    before field c24solnom
           display by name d_cts14m01c.c24solnom attribute (reverse)

    after  field c24solnom
           display by name d_cts14m01c.c24solnom

           if d_cts14m01c.c24solnom  is null   then
              error " Informe o nome do solicitante!"
              next field c24solnom
           end if

    before field c24soltipcod
           display by name d_cts14m01c.c24soltipcod attribute (reverse)

    after  field c24soltipcod
           display by name d_cts14m01c.c24soltipcod

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field c24solnom
           end if

           if  d_cts14m01c.c24soltipcod  is null   then
               error " Tipo do solicitante deve ser informado!"
               let d_cts14m01c.c24soltipcod = cto00m00(1)
               next field c24soltipcod
           end if

           select c24soltipdes
             into d_cts14m01c.c24soltipdes
             from datksoltip
                  where c24soltipcod = d_cts14m01c.c24soltipcod

           if  sqlca.sqlcode = notfound  then
               error " Tipo de solicitante nao cadastrado!"
               let d_cts14m01c.c24soltipcod = cto00m00(1)
               next field c24soltipcod
           end if

           if  d_cts14m01c.c24soltipcod < 3 then
               let ws.soltip = d_cts14m01c.c24soltipdes[1,1]
           else
               let ws.soltip = "O"
           end if
           display by name d_cts14m01c.c24soltipdes

    before field canmtvdes
           display by name d_cts14m01c.canmtvdes    attribute (reverse)

    after  field canmtvdes
           display by name d_cts14m01c.canmtvdes

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field c24soltipcod
           end if

           if d_cts14m01c.canmtvdes  is null   then
              error " Motivo do cancelamento deve ser informado!"
              next field canmtvdes
           end if


           #-------------------------------------------------------
           #   INCLUSAO/ALTERACAO DO CANCELAMENTO
           #-------------------------------------------------------
           if ws.operacao  =  "I"   then
              begin work
              insert into datmvstsincanc
                        (sinvstnum, sinvstano, canmtvdes,
                         solnom   , soltip, vstsoltipcod, atdhor   ,
                         atddat   , funmat)
                 values (param.sinvstnum      , param.sinvstano      ,
                         d_cts14m01c.canmtvdes, d_cts14m01c.c24solnom,
                         ws.soltip ,
                         d_cts14m01c.c24soltipcod, ws.atdhor, ws.atddat ,
                         g_issk.funmat)

              if sqlca.sqlcode <> 0  then
                 error " Erro (", sqlca.sqlcode, ") na inclusao do cancelamento. AVISE A INFORMATICA!"
                 rollback work
                 exit input
              end if

              select sinvstsolsit
                into ws.sinvstsit
                from datmvstsin
               where sinvstnum = param.sinvstnum and
                     sinvstano = param.sinvstano

              if ws.sinvstsit = "S"   then  ### SE LAUDO JA IMPRESSO
                 let ws.sinvstsit = "N"     ### REATIVA NA TELA DO SINISTRO
              else
                 let ws.sinvstsit = "S"     ### SE LAUDO NAO FOI IMPRESSO
              end if                        ### DESATIVA NA TELA DO SINISTRO

              update datmvstsin set
                     sinvstsolsit = ws.sinvstsit
               where sinvstnum = param.sinvstnum and
                     sinvstano = param.sinvstano

              if sqlca.sqlcode <> 0  then
                 error " Erro (", sqlca.sqlcode, ") no flag de cancelamento. AVISE A INFORMATICA!"
                 rollback work
                 exit input
              end if

              commit work
           end if

           if ws.operacao  =  "M"   then
              update datmvstsincanc set
                    (canmtvdes, solnom   , soltip, vstsoltipcod   ,
                     atdhor   , atddat   , funmat   )
                  = (d_cts14m01c.canmtvdes, d_cts14m01c.c24solnom,
                     ws.soltip ,
                     d_cts14m01c.c24soltipcod, ws.atdhor, ws.atddat ,
                     g_issk.funmat)
               where sinvstnum = param.sinvstnum    and
                     sinvstano = param.sinvstano

              if sqlca.sqlcode <> 0  then
                 error " Erro (", sqlca.sqlcode, ") na alteracao do cancelamento. AVISE A INFORMATICA!"
                 exit input
              end if
           end if

      on key (interrupt)
         exit input

 end input

 let int_flag = false

 close window  w_cts14m01c

end function  ###  cancela_cts14m01

#--------------------------------------------------------------------
 function funcionario_cts14m01(param)
#--------------------------------------------------------------------

 define param     record
    funmat        like isskfunc.funmat      ,
    atddat        like datmvstsin.atddat    ,
    atdhor        like datmvstsin.atdhor    ,
    empcod        like datmvstsin.empcod                              #Raul, Biz
 end record

 define ws        record
    funnom        like isskfunc.funnom      ,
    dptsgl        like isskfunc.dptsgl      ,
    atltxt        char (45)
 end record



	initialize  ws.*  to  null

 initialize ws.*  to null

 let ws.funnom = "** NAO CADASTRADO **"
 let ws.dptsgl = "N/CAD"
 if param.funmat = 0 then
    let ws.funnom = "PORTAL"
 else
    select funnom, dptsgl
      into ws.funnom,
           ws.dptsgl
      from isskfunc
     where empcod = param.empcod                                      #Raul, Biz
       and funmat = param.funmat
 end if

 let ws.atltxt = param.atddat," as ", param.atdhor, " ",
                 upshift(ws.dptsgl) , " ", upshift(ws.funnom)

 return ws.atltxt

end function  ###  funcionario_cts14m01

function roteiriza (param)
   define param record
      sinvstnum like datmvstsin.sinvstnum,
      sinvstano like datmvstsin.sinvstano
   end record

   define w_null like sgakvstmot.sinvstmtvcod
   define l_mens char (80)
   define l_succod like ssamsin.succod
   define l_ofncod like ssamvalores.ofnnumdig
   define l_ramo like ssamsin.ramcod
   define l_placa like datmvstsin.vcllicnum
   define l_chassi_inicial like datmvstsin.vclchsinc
   define l_chassi_final like datmvstsin.vclchsfnl
   define l_chassi_completo char (20)
   define l_ano_sinistro like ssamsin.sinano
   define l_numero_sinistro like ssamsin.sinnum
   define l_item like ssamitem.sinitmseq
   define l_sinvstorgnum like datmvstsin.sinvstorgnum
   define l_sinvstorgano like datmvstsin.sinvstorgano
   define l_numero_vistoria like datmvstsin.sinvstnum
   define l_ano_vistoria like datmvstsin.sinvstano
   define l_sindat like datmvstsin.sindat
   let w_null = null
   let l_mens = null
   let l_ramo = null
   let l_placa = null
   let l_chassi_inicial = null
   let l_chassi_final = null
   let l_chassi_completo = null
   let l_ano_sinistro = null
   let l_numero_sinistro = null
   let l_item = null
   let l_sinvstorgnum = null
   let l_sinvstorgano =  null
   let l_numero_vistoria = null
   let l_ano_vistoria = null
   let l_sindat = null

   whenever error continue

   select ramcod, vcllicnum, vclchsinc, vclchsfnl, sinvstorgano, sinvstorgnum,
          sindat
   into l_ramo, l_placa, l_chassi_inicial, l_chassi_final, l_sinvstorgano,
        l_sinvstorgnum, l_sindat
   from datmvstsin
   where sinvstano = param.sinvstano and sinvstnum = param.sinvstnum
   whenever error stop

   if (sqlca.sqlcode = 100) then
      let l_mens = "Vistoria nao encontrada na tabela 'datmvstsin'."
      return l_mens
   end if

   if (l_sinvstorgnum is null and l_sinvstorgano is null) then
      let l_numero_vistoria = param.sinvstnum
      let l_ano_vistoria = param.sinvstano
   else
      let l_numero_vistoria = l_sinvstorgnum
      let l_ano_vistoria = l_sinvstorgano
   end if

   if (l_ramo = 531 or l_ramo = 31) then
      whenever error continue

      select a.sinano, a.sinnum, b.sinitmseq
      into l_ano_sinistro, l_numero_sinistro, l_item
      from ssamsin a, ssamitem b
      where a.ramcod = b.ramcod and a.sinano = b.sinano and a.sinnum = b.sinnum and
            a.sinvstnum = l_numero_vistoria and a.sinvstano = l_ano_vistoria and
            a.ramcod = l_ramo
   else
      if (l_ramo = 553 or l_ramo = 53) then
         whenever error continue

         select a.sinano, a.sinnum, b.sinitmseq
         into l_ano_sinistro, l_numero_sinistro, l_item
         from ssamsin a, ssamitem b, ssamterc c
         where a.ramcod = b.ramcod and a.ramcod = c.ramcod and
               a.sinano = b.sinano and a.sinano = c.sinano and
               a.sinnum = b.sinnum and a.sinnum = c.sinnum and
               b.sinitmseq = c.sinitmseq and
               a.sinvstnum = l_numero_vistoria and a.sinvstano = l_ano_vistoria and
               (c.vcllicnum = d_cts14m01.vcllicnum or
               (c.vclchsinc = d_cts14m01.vclchsinc and
               c.vclchsfnl = d_cts14m01.vclchsfnl)) and
               a.ramcod = l_ramo

         if (sqlca.sqlcode = 100) then
            select a.sinano, a.sinnum, b.sinitmseq
            into l_ano_sinistro, l_numero_sinistro, l_item
            from ssamsin a, ssamitem b, ssamterc c
            where a.ramcod = b.ramcod and a.ramcod = c.ramcod and
                  a.sinano = b.sinano and a.sinano = c.sinano and
                  a.sinnum = b.sinnum and a.sinnum = c.sinnum and
                  b.sinitmseq = c.sinitmseq and
                  (c.vcllicnum = d_cts14m01.vcllicnum or
                  (c.vclchsinc = d_cts14m01.vclchsinc and
                  c.vclchsfnl = d_cts14m01.vclchsfnl)) and
                  a.ramcod = l_ramo and a.orrdat = l_sindat
         end if
      else
         let l_mens = "Ramo diferente de 531 (31) e de 553 (53): ", l_ramo clipped
         return l_mens
      end if
   end if

   whenever error stop

   if (sqlca.sqlcode = 0) then
      let l_ofncod = null
      let l_succod = null

      whenever error continue

      select ofnnumdig
      into l_ofncod
      from ssamvalores
      where ssamvalores.ramcod = l_ramo and
            ssamvalores.sinano = l_ano_sinistro and
            ssamvalores.sinnum = l_numero_sinistro and
            ssamvalores.sinitmseq = l_item

      whenever error stop

      whenever error continue

      select succod
      into l_succod
      from sgokofi
      where sgokofi.ofnnumdig = l_ofncod

      whenever error stop

      {display "l_ramo: ", l_ramo clipped
      display "l_ano_sinistro: ", l_ano_sinistro clipped
      display "l_numero_sinistro: ", l_numero_sinistro clipped
      display "l_item: ", l_item clipped
      display "l_ofncod: ", l_ofncod clipped
      display "l_succod: ", l_succod clipped
      display "g_issk.funmat: ", g_issk.funmat clipped
      display "d_cts14m01.vstretdat: ", d_cts14m01.vstretda}

      let l_mens = ssata609_roteiriza (l_ramo, l_ano_sinistro, l_numero_sinistro,
                                       l_item, today, 50, l_ofncod, l_succod,
                                       g_issk.funmat, d_cts14m01.vstretdat,
                                       "RETORNO", "N", 10 )

      #display "l_mens: ", l_mens clipped

      if (l_mens is not null) then
         return l_mens
      end if
   else
      if (sqlca.sqlcode = 100) then
         let l_mens = "Roteirizacao nao realizada. Sinistro nao encontrado."
      else
         let l_mens = "Roteirizacao nao realizada. Erro: ", sqlca.sqlcode clipped
      end if
   end if

   return l_mens
end function
