#############################################################################
# Nome do Modulo: CTS09G00                                         Pedro    #
#                                                                  Marcelo  #
# Atualizacao do telefone do segurado                              Abr/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 18/08/1999  PSI 5591-3   Gilberto     Parametrizar a atualizacao.         #
#---------------------------------------------------------------------------#
# 12/07/2001               Ruiz         Incluir funcao para atualizar o     #
#                                       telefone do segurado.               #
#---------------------------------------------------------------------------#
# 27/12/2001  PSI 14451-7  Ruiz         Incluir funcao para atualizar o     #
#                                       e-mail do segurado.                 #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
#---------------------------------------------------------------------------#
# 16/10/2008  PSI 223689  Roberto                                           #
#                                                                           #
#                                         Inclusao da funcao figrc072():    #
#                                         essa funcao evita que o programa  #
#                                         caia devido ha uma queda da       #
#                                         instancia da tabela de origem para#
#                                         a tabela de replica               #
#                                                                           #
#############################################################################


globals '/homedsa/projetos/geral/globals/glct.4gl'
globals "/homedsa/projetos/geral/globals/figrc072.4gl"

#-----------------------------------------------------------
 function cts09g00(param)
#-----------------------------------------------------------

 define param      record
    ramcod         like datrservapol.ramcod   ,
    succod         like datrservapol.succod   ,
    aplnumdig      like datrservapol.aplnumdig,
    itmnumdig      like datrservapol.itmnumdig,
    updflg         smallint
 end record

 define d_cts09g00 record
   dddcod          like gsakend.dddcod,
   teltxt          like gsakend.teltxt
 end record

 define ws         record
   segnumdig       like gsakseg.segnumdig,
   sgrorg          like rsamseguro.sgrorg,
   sgrnumdig       like rsamseguro.sgrnumdig,
   dddcod          like gsakend.dddcod,
   teltxt          like gsakend.teltxt,
   erro            smallint
 end record



	initialize  d_cts09g00.*  to  null

	initialize  ws.*  to  null

 let int_flag  =  false
 initialize d_cts09g00.*  to null
 initialize ws.*          to null

 if param.ramcod    is null  or
    param.succod    is null  or
    param.aplnumdig is null  then
    return d_cts09g00.dddcod,
           d_cts09g00.teltxt
 end if

 whenever error continue

 #-----------------------------------------------------------
 # Localiza numero do segurado conforme ramo
 #-----------------------------------------------------------
 if param.ramcod = 31  or
    param.ramcod = 531 then
    if param.succod    is not null  and
       param.aplnumdig is not null  and
       param.itmnumdig is not null  then
       if g_funapol.dctnumseq is null  then
          call f_funapol_ultima_situacao (param.succod,
                                          param.aplnumdig,
                                          param.itmnumdig)
               returning g_funapol.*
       end if

       select segnumdig
         into ws.segnumdig
         from abbmdoc
        where succod    = param.succod     and
              aplnumdig = param.aplnumdig  and
              itmnumdig = param.itmnumdig  and
              dctnumseq = g_funapol.dctnumseq

       if sqlca.sqlcode <> 0  then
#         error " Erro (", sqlca.sqlcode, ") na localizacao do documento (AUTOMOVEL). AVISE A INFORMATICA!"
          return d_cts09g00.dddcod,
                 d_cts09g00.teltxt
       end if
    end if
 else
    if param.ramcod    is not null  and
       param.succod    is not null  and
       param.aplnumdig is not null  then
       select sgrorg, sgrnumdig
         into ws.sgrorg, ws.sgrnumdig
         from rsamseguro
        where succod    =  param.succod     and
              ramcod    =  param.ramcod     and
              aplnumdig =  param.aplnumdig

       if sqlca.sqlcode <> 0  then
#         error "Erro (", sqlca.sqlcode, ") na localizacao do seguro (RAMOS ELEMENTARES). AVISE A INFORMATICA!"
          return d_cts09g00.dddcod,
                 d_cts09g00.teltxt
       end if

       select segnumdig
         into ws.segnumdig
         from rsdmdocto
        where prporg    = ws.sgrorg     and
              prpnumdig = ws.sgrnumdig

       if sqlca.sqlcode <> 0  then
#         error " Erro (", sqlca.sqlcode, ") na localizacao do documento (RAMOS ELEMENTARES). AVISE A INFORMATICA!"
          return d_cts09g00.dddcod,
                 d_cts09g00.teltxt
       end if
    end if
 end if

 #-----------------------------------------------------------
 # Atualiza telefone do segurado
 #-----------------------------------------------------------
 select dddcod, teltxt
   into ws.dddcod, ws.teltxt
   from gsakend
  where segnumdig  =  ws.segnumdig  and
        endfld     =  "1"

 if sqlca.sqlcode <> 0  then
#   error " Erro (", sqlca.sqlcode, ") na localizacao do telefone. AVISE A INFORMATICA!"
    return d_cts09g00.dddcod, d_cts09g00.teltxt
 end if

 let d_cts09g00.dddcod = ws.dddcod
 let d_cts09g00.teltxt = ws.teltxt

 if param.updflg = false  then
    return d_cts09g00.dddcod, d_cts09g00.teltxt
 end if

 if ws.dddcod  is null   then
    let ws.dddcod = "   "
 end if

 if ws.teltxt  is null   then
    let ws.teltxt = "   "
 end if

 call figrc072_setTratarIsolamento()

 call cty17g00_ssgtemail(ws.segnumdig,g_documento.c24soltipcod) ## psi201987
 if g_isoAuto.sqlCodErr <> 0 then
    error "Atualizacao do E-mail Temporariamente Indisponivel! Erro: "
          ,g_isoAuto.sqlCodErr
 end if
 call figrc072_setTratarIsolamento()
 call cty17g00_ssgttel (1,ws.segnumdig,g_documento.c24soltipcod)    # altera telefone do segurado ## psi201987
      returning ws.dddcod,ws.teltxt
 if g_isoAuto.sqlCodErr <> 0 then
    error "Atualizacao de Telefone Temporariamente Indisponivel! Erro: "
          ,g_isoAuto.sqlCodErr
 end if
 return ws.dddcod,
        ws.teltxt

{   # substituido pela funcao ssgttel
 open window cts09g00 at 12,29 with form "cts09g00"
                         attribute (border, form line 1)

 display by name d_cts09g00.dddcod, d_cts09g00.teltxt


 input by name d_cts09g00.dddcod,
               d_cts09g00.teltxt   without defaults

   before field dddcod
      display by name d_cts09g00.dddcod    attribute (reverse)

   after  field dddcod
      display by name d_cts09g00.dddcod

      if d_cts09g00.dddcod  = " "     or
         d_cts09g00.dddcod  = "9999"  then
         initialize d_cts09g00.dddcod to null
      end if

   before field teltxt
      display by name d_cts09g00.teltxt    attribute (reverse)

   after  field teltxt
      display by name d_cts09g00.teltxt

      if fgl_lastkey()  =  fgl_keyval("up")   or
         fgl_lastkey()  =  fgl_keyval("left") then
         next field dddcod
      end if

      if d_cts09g00.teltxt = " "  then
         initialize d_cts09g00.teltxt to null
      end if

      if d_cts09g00.dddcod is not null  and
         d_cts09g00.teltxt is     null  then
         error " Numero de telefone nao informado!"
         next field dddcod
      end if

      if ws.dddcod <> d_cts09g00.dddcod  or
         ws.teltxt <> d_cts09g00.teltxt  then
         update gsakend set (dddcod, teltxt)
                         =  (d_cts09g00.dddcod,
                             d_cts09g00.teltxt)
          where segnumdig = ws.segnumdig
            and endfld    = '1'

         if sqlca.sqlcode <> 0  then
            error " Erro (", sqlca.sqlcode, ") na atualizacao do",
                  " telefone do segurado. AVISE A INFORMATICA!"
         end if
      end if

   on key (interrupt)
      exit input

 end input

 if int_flag then
    let d_cts09g00.dddcod = ws.dddcod
    let d_cts09g00.teltxt = ws.teltxt
 end if

 let int_flag = false

 close window cts09g00

 whenever error stop

 return d_cts09g00.dddcod,
        d_cts09g00.teltxt
}
end function  ###  cts09g00
