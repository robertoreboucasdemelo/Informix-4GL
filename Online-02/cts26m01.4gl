###############################################################################
# Nome do Modulo: cts26m01                                              Raji  #
#                                                                             #
# Laudo - JIT (Dados Ref. a Caminhao)                                Jun/2001 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts26m01(param, d_cts26m01)
#-----------------------------------------------------------

 define param       record
    ctgtrfcod       like abbmcasco.ctgtrfcod,
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano
 end record

 define d_cts26m01  record
    vclcrgflg       like datmservicocmp.vclcrgflg,
    vclcrgpso       like datmservicocmp.vclcrgpso,
    vclcamtip       like datmservicocmp.vclcamtip,
    vclcrcdsc       like datmservicocmp.vclcrcdsc
 end record

 define ws          record
    vcltip          dec(1,0)
 end record




	initialize  ws.*  to  null

 let int_flag  = false
 initialize ws.*   to null

 let ws.vcltip = 1  #-> Caminhoes
# if param.ctgtrfcod = 14  or  param.ctgtrfcod = 15  or
#    param.ctgtrfcod = 20  or  param.ctgtrfcod = 21  or
#    param.ctgtrfcod = 22  or  param.ctgtrfcod = 23  then
#    let ws.vcltip = 2  #-> Pick-ups/Utilitarios
# end if


 open window cts26m01 at 11,16 with form "cts26m01"
                      attribute(border,form line 1,comment line last - 1)

 message " (F17)Abandona"

 input by name d_cts26m01.vclcrgflg,
               d_cts26m01.vclcrgpso,
               d_cts26m01.vclcamtip,
               d_cts26m01.vclcrcdsc   without defaults

   before field vclcrgflg
          display by name d_cts26m01.vclcrgflg attribute (reverse)

   after  field vclcrgflg
          display by name d_cts26m01.vclcrgflg

          if ((d_cts26m01.vclcrgflg  is null)    or
              (d_cts26m01.vclcrgflg  <>  "S"     and
               d_cts26m01.vclcrgflg  <>  "N"))   then
             error " Veiculo carregado: (S)im ou (N)ao!"
             next field vclcrgflg
          end if

          if d_cts26m01.vclcrgflg = "N"   then
             initialize d_cts26m01.vclcrgpso to null
             display by name d_cts26m01.vclcrgpso
             if ws.vcltip  =  2   then
                exit input
             end if
             next field vclcamtip
          end if

   before field vclcrgpso
          display by name d_cts26m01.vclcrgpso attribute (reverse)

   after  field vclcrgpso
          display by name d_cts26m01.vclcrgpso

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field vclcrgflg
          end if

          if d_cts26m01.vclcrgpso  is null    then
             error " Peso da carga deve ser informado!"
             next field vclcrgpso
          end if

          if ws.vcltip  =  2   then
             exit input
          end if

   before field vclcamtip
          display by name d_cts26m01.vclcamtip attribute (reverse)

   after  field vclcamtip
          display by name d_cts26m01.vclcamtip

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field vclcrgpso
          end if

          if ((d_cts26m01.vclcamtip  is null)   or
              (d_cts26m01.vclcamtip  <>  "1"    and
               d_cts26m01.vclcamtip  <>  "2"    and
               d_cts26m01.vclcamtip  <>  "3"))  then
             error " Tipo de caminhao invalido!"
             next field vclcamtip
          end if

   before field vclcrcdsc
          display by name d_cts26m01.vclcrcdsc attribute (reverse)

   after  field vclcrcdsc
          display by name d_cts26m01.vclcrcdsc

   on key (interrupt)
      exit input

 end input

 close window cts26m01
 let int_flag = false

 return d_cts26m01.*

end function ##-- cts26m01


#-----------------------------------------------------------
 function cts26m01_caminhao(param)
#-----------------------------------------------------------

 define param       record
    succod          like abbmcasco.succod,
    aplnumdig       like abbmcasco.aplnumdig,
    itmnumdig       like abbmcasco.itmnumdig,
    autsitatu       like abbmitem.autsitatu
 end record

 define ws2         record
    ctgtrfcod       like abbmcasco.ctgtrfcod,
    caminhaoflg     char(01)
 end record




	initialize  ws2.*  to  null

 initialize ws2.*   to null

 if param.succod     is not null   and
    param.aplnumdig  is not null   and
    param.itmnumdig  is not null   and
    param.autsitatu  is not null   then

    select ctgtrfcod
      into ws2.ctgtrfcod
      from abbmcasco
     where succod    = param.succod     and
           aplnumdig = param.aplnumdig  and
           itmnumdig = param.itmnumdig  and
           dctnumseq = param.autsitatu

#   if ws2.ctgtrfcod = 14  or  ws2.ctgtrfcod = 15  or
#      ws2.ctgtrfcod = 20  or  ws2.ctgtrfcod = 21  or
#      ws2.ctgtrfcod = 22  or  ws2.ctgtrfcod = 23  or

    call cts02m01_ctgtrfcod(ws2.ctgtrfcod)
        returning ws2.caminhaoflg
    {if ws2.ctgtrfcod = 40  or  ws2.ctgtrfcod = 41  or
       ws2.ctgtrfcod = 42  or  ws2.ctgtrfcod = 43  or
       ws2.ctgtrfcod = 50  or  ws2.ctgtrfcod = 51  or
       ws2.ctgtrfcod = 52  or  ws2.ctgtrfcod = 53  then
       let ws2.caminhaoflg = "S"
    else
       let ws2.caminhaoflg = "N"
    end if}
 end if

 return ws2.caminhaoflg, ws2.ctgtrfcod

end function ##-- cts26m01_caminhao
