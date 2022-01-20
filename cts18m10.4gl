##############################################################################
# Nome do Modulo: cts18m10                                          Marcelo  #
#                                                                   Gilberto #
# Direciona e imprime aviso de sinistro                             Ago/1997 #
##############################################################################
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Renato Zattar                    OSF : 4774             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 08/07/2002       #
#  Objetivo       : Alterar programa para comportar Endereco Eletronico     #
#---------------------------------------------------------------------------#
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 08/08/2006 Andrei, Meta  AS112372  Migracao de versao do 4GL               #
#----------------------------------------------------------------------------#

# globals "/homedsa/projetos/ct24h/producao/glct.4gl" RGLOBALS By Robi
globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function cts18m10(param)
#--------------------------------------------------------------
 define param        record
    corsus           like gcaksusep.corsus
 end record

 # -- OSF 4774 - Fabrica de Software, Katiucia -- #
 define d_cts18m10   record
    enviar           char (01),
    envdes           char (10),
    dddcod           char (04),
    faxnum           char (09),
    maides           like gcakfilial.maides
 end record

 define ws           record
    lrpipe           char (20),
    impnom           char (08),
    imp_ok           smallint,
    confirma         char (01),
    dddcod           char (04),
    faxnum           char (09),
    maides           like gcakfilial.maides
 end record

 define vl_gcakfilial record
    endlgd            like gcakfilial.endlgd
   ,endnum            like gcakfilial.endnum
   ,endcmp            like gcakfilial.endcmp
   ,endbrr            like gcakfilial.endbrr
   ,endcid            like gcakfilial.endcid
   ,endcep            like gcakfilial.endcep
   ,endcepcmp         like gcakfilial.endcepcmp
   ,endufd            like gcakfilial.endufd
   ,dddcod            like gcakfilial.dddcod
   ,teltxt            like gcakfilial.teltxt
   ,dddfax            like gcakfilial.dddfax
   ,factxt            like gcakfilial.factxt
   ,maides            like gcakfilial.maides
   ,crrdstcod         like gcaksusep.crrdstcod
   ,crrdstnum         like gcaksusep.crrdstnum
   ,crrdstsuc         like gcaksusep.crrdstsuc
   ,stt               smallint
 end record



	initialize  d_cts18m10.*  to  null

	initialize  ws.*  to  null

	initialize  vl_gcakfilial.*  to  null

 initialize d_cts18m10.*  to null
 initialize ws.*          to null

 let int_flag  =  false

 # -- OSF 4774 - Fabrica de Softeware, Katiucia -- #
 call fgckc811 ( param.corsus )
      returning vl_gcakfilial.endlgd
               ,vl_gcakfilial.endnum
               ,vl_gcakfilial.endcmp
               ,vl_gcakfilial.endbrr
               ,vl_gcakfilial.endcid
               ,vl_gcakfilial.endcep
               ,vl_gcakfilial.endcepcmp
               ,vl_gcakfilial.endufd
               ,vl_gcakfilial.dddcod
               ,vl_gcakfilial.teltxt
               ,vl_gcakfilial.dddfax
               ,vl_gcakfilial.factxt
               ,vl_gcakfilial.maides
               ,vl_gcakfilial.crrdstcod
               ,vl_gcakfilial.crrdstnum
               ,vl_gcakfilial.crrdstsuc
               ,vl_gcakfilial.stt

## select gcakfilial.dddcod, gcakfilial.factxt, gcakfilial.maides
###into d_cts18m10.dddcod, d_cts18m10.faxnum, d_cts18m10.maides
##   into ws.dddcod, ws.faxnum, ws.maides
##   from gcaksusep, gcakcorr, gcakfilial
##  where gcaksusep.corsus     = param.corsus         and
##        gcakcorr.corsuspcp   = gcaksusep.corsuspcp  and
##        gcakfilial.corsuspcp = gcaksusep.corsuspcp  and
##        gcakfilial.corfilnum = gcaksusep.corfilnum

 if vl_gcakfilial.stt = 1 or
    vl_gcakfilial.stt = 2 then
    error "Corretor nao encontrado. AVISE A INFORMATICA !"
    return d_cts18m10.enviar, d_cts18m10.dddcod, d_cts18m10.faxnum, ws.lrpipe
 end if

 let ws.dddcod = vl_gcakfilial.dddfax
 let ws.faxnum = vl_gcakfilial.factxt
 let ws.maides = vl_gcakfilial.maides

 if ws.dddcod is null then
    let ws.dddcod = "    "
 end if

 if ws.faxnum is null then
    let ws.faxnum = "    "
 end if

 if ws.maides is null then
    let ws.maides = "    "
 end if

 let d_cts18m10.dddcod = ws.dddcod
 let d_cts18m10.faxnum = ws.faxnum
 let d_cts18m10.maides = ws.maides

 open window cts18m10 at 10,2 with form "cts18m10"
             attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona"

 let d_cts18m10.enviar = "E"   # arnaldo, 26/09
 display by name d_cts18m10.*

 # -- OSF 4774 - Fabrica de Software, Katiucia -- #
 input by name d_cts18m10.enviar ,
               d_cts18m10.dddcod ,
               d_cts18m10.faxnum ,
               d_cts18m10.maides without defaults

    before field enviar
       display by name d_cts18m10.enviar    attribute (reverse)

    after  field enviar
       display by name d_cts18m10.enviar

       if d_cts18m10.enviar is null  then
          error " Enviar para (I)mpressora, (F)ax ou (E)Mail!"
          next field enviar
       else
          case d_cts18m10.enviar
             when "F"    let d_cts18m10.envdes = "FAX"
             when "I"    let d_cts18m10.envdes = "IMPRESSORA"
             when "E"    let d_cts18m10.envdes = "E-MAIL"
             when "A"    let d_cts18m10.envdes = "FAX/E-MAIL"
             otherwise   error " Enviar para (I)mpressora, (F)ax, (E)Mail ou (A)Fax/Email"
                         next field enviar
          end case
       end if

       display by name d_cts18m10.envdes

       initialize  ws.lrpipe, ws.imp_ok, ws.impnom to null

       if d_cts18m10.enviar = "I"  then
          call fun_print_seleciona (g_issk.dptsgl,"")
               returning  ws.imp_ok, ws.impnom

          if ws.imp_ok = 0  then
             error " Departamento/Impressora nao cadastrada!"
             next field enviar
          end if

          if ws.impnom is null  then
             error " Uma impressora deve ser selecionada!"
             next field enviar
          end if
          let ws.lrpipe = "lp -sd ", ws.impnom clipped
          exit input

       else
          if d_cts18m10.enviar = "F" or
             d_cts18m10.enviar = "A" then
             if g_hostname = "u07"  then
             ## error " Fax so' pode ser enviado no ambiente de producao !!!"
             ## next field enviar
                let ws.impnom = "avsinfax"
             ## let ws.impnom = "tstclfax"
             else
                let ws.impnom = "avsinfax"
             end if
             let ws.lrpipe = "lp -sd ", ws.impnom clipped
          else
             next field maides
          end if
       end if

    before field dddcod
       display by name d_cts18m10.dddcod    attribute (reverse)

    after  field dddcod
       display by name d_cts18m10.dddcod

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field enviar
       end if

       if (d_cts18m10.dddcod is null  or
           d_cts18m10.dddcod  = "  ") and
           d_cts18m10.enviar = "F"  then
          error " Codigo do DDD deve ser informado!"
          next field dddcod
       end if

       if d_cts18m10.dddcod   = "0   "   or
          d_cts18m10.dddcod   = "00  "   or
          d_cts18m10.dddcod   = "000 "   or
          d_cts18m10.dddcod   = "0000"   then
          error " Codigo do DDD invalido!"
          next field dddcod
       end if

    before field faxnum
       display by name d_cts18m10.faxnum    attribute (reverse)

    after  field faxnum
       display by name d_cts18m10.faxnum

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field dddcod
       end if

       if (d_cts18m10.faxnum is null  or
           d_cts18m10.faxnum =  000) and
           d_cts18m10.dddcod is not null then
          error " Numero do fax deve ser informado!"
          next field faxnum
       else
          if d_cts18m10.faxnum is not null then
             if d_cts18m10.faxnum > 99999  then
             else
                error " Numero do fax invalido!"
                next field faxnum
             end if
          end if
       end if

    # -- OSF 4774 - Fabrica de Software, Katiucia -- #
    before field maides
       display by name d_cts18m10.maides    attribute (reverse)

    after  field maides
       display by name d_cts18m10.maides

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          next field maides
       end if

       if (d_cts18m10.maides is null or
          d_cts18m10.maides  = " ") and
          d_cts18m10.enviar = "E" then
          error "E-Mail deve ser informado!"
          next field maides
       end if

       if d_cts18m10.enviar = "E" then
          let ws.lrpipe = "rcts18m1001"
       end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    error " ATENCAO !!! FAX/E-MAIL NAO SERA' ENVIADO!"

    call cts08g01("A","N", "", "FAX/E-MAIL DO AVISO DE SINISTRO (FONADO)", "",
                      "*** NAO SERA' ENVIADO ***")
         returning ws.confirma

    initialize d_cts18m10.dddcod, d_cts18m10.faxnum, d_cts18m10.maides to null
    initialize ws.lrpipe to null
 end if

 # -- OSF 4774 - Fabrica de Software, Katiucia -- #
 if ws.dddcod <> d_cts18m10.dddcod  or
    ws.faxnum <> d_cts18m10.faxnum  or
    ws.maides <> d_cts18m10.maides  then
    call cts08g01("A"
                 ,"N"
                 ,"PARA ALTERACAO OU CORRECAO DO CORRETOR"
                 ,"ORIENTE O MESMO A CONTACTAR O "
                 ,"DEPARTAMENTO DE COMISSOES"
                 ,"SETOR CADASTRO DE CORRETORES")
         returning ws.confirma
 end if

 let int_flag = false
 close window cts18m10

 return d_cts18m10.enviar, d_cts18m10.dddcod
      , d_cts18m10.faxnum, ws.lrpipe, d_cts18m10.maides

end function  ###  cts18m10
