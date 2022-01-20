###############################################################################
# Nome do Modulo: CTS02M01                                              Pedro #
#                                                                     Marcelo #
# Laudo - Remocoes (Dados Ref. a Caminhao)                           Dez/1994 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 26/03/1999  PSI 8112-4   Wagner       Permitir questionamento de veiculo    #
#                                       carregado apenas para as categorias:  #
#                                       40-41/42-43/50-51/52-53.              #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep smallint
define m_mens char(100)

function cts02m01_prepare()

  define l_sql char(300)
  let l_sql = null
  let l_sql = "select count(*) from datkdominio ",
              " where cponom = ? ",
              " and   cpocod = ? "
  prepare pcts02m01001 from l_sql
  declare ccts02m01001 cursor with hold for pcts02m01001
  let m_prep = true

end function

#-----------------------------------------------------------
 function cts02m01(param, d_cts02m01)
#-----------------------------------------------------------

 define param       record
    ctgtrfcod       like abbmcasco.ctgtrfcod,
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano
 end record

 define d_cts02m01  record
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


 open window cts02m01 at 11,16 with form "cts02m01"
                      attribute(border,form line 1,comment line last - 1)

 message " (F17)Abandona"

 input by name d_cts02m01.vclcrgflg,
               d_cts02m01.vclcrgpso,
               d_cts02m01.vclcamtip,
               d_cts02m01.vclcrcdsc   without defaults

   before field vclcrgflg
          display by name d_cts02m01.vclcrgflg attribute (reverse)

   after  field vclcrgflg
          display by name d_cts02m01.vclcrgflg

          if ((d_cts02m01.vclcrgflg  is null)    or
              (d_cts02m01.vclcrgflg  <>  "S"     and
               d_cts02m01.vclcrgflg  <>  "N"))   then
             error " Veiculo carregado: (S)im ou (N)ao!"
             next field vclcrgflg
          end if

          if d_cts02m01.vclcrgflg = "N"   then
             initialize d_cts02m01.vclcrgpso to null
             display by name d_cts02m01.vclcrgpso
             if ws.vcltip  =  2   then
                exit input
             end if
             next field vclcamtip
          end if

   before field vclcrgpso
          display by name d_cts02m01.vclcrgpso attribute (reverse)

   after  field vclcrgpso
          display by name d_cts02m01.vclcrgpso

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field vclcrgflg
          end if

          if d_cts02m01.vclcrgpso  is null    then
             error " Peso da carga deve ser informado!"
             next field vclcrgpso
          end if

          if ws.vcltip  =  2   then
             exit input
          end if

   before field vclcamtip
          display by name d_cts02m01.vclcamtip attribute (reverse)

   after  field vclcamtip
          display by name d_cts02m01.vclcamtip

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field vclcrgpso
          end if

          if ((d_cts02m01.vclcamtip  is null)   or
              (d_cts02m01.vclcamtip  <>  "1"    and
               d_cts02m01.vclcamtip  <>  "2"    and
               d_cts02m01.vclcamtip  <>  "3"))  then
             error " Tipo de caminhao invalido!"
             next field vclcamtip
          end if

   before field vclcrcdsc
          display by name d_cts02m01.vclcrcdsc attribute (reverse)

   after  field vclcrcdsc
          display by name d_cts02m01.vclcrcdsc

   on key (interrupt)
      exit input

 end input

 close window cts02m01
 let int_flag = false

 return d_cts02m01.*

end function ##-- cts02m01


#-----------------------------------------------------------
 function cts02m01_caminhao(param)
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

end function ##-- cts02m01_caminhao

function cts02m01_ctgtrfcod(l_param_caminhao)

   define l_param_caminhao like abbmcasco.ctgtrfcod
   define l_flag_caminhao  smallint
   define l_chave          char(20)
   define l_caminhao       char(1)
   let l_flag_caminhao = 0
   let l_chave = 'caminhao'
   let l_caminhao = "N"
   if m_prep = false or
      m_prep is null then
      call cts02m01_prepare()
   end if
   whenever error continue
   open  ccts02m01001 using l_chave,l_param_caminhao
   fetch ccts02m01001 into l_flag_caminhao
   whenever error stop
   if sqlca.sqlcode <> 0 then
      let m_mens = "ERRO (",sqlca.sqlcode clipped, ") AO SELECIONAR CHAVE NA DATKDOMINIO "
      call errorlog(m_mens)
      error m_mens
   end if
   if l_flag_caminhao = true then
      let l_caminhao = "S"
   end if
   return l_caminhao
end function

