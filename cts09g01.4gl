###############################################################################
# Nome do Modulo: CTS09G01                                           Pedro    #
#                                                                    Marcelo  #
# Atualiza fax do corretor                                           Out/1995 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 07/10/1999  PSI 9424-2   Wagner       Inclusao do modulo cts08g01 para      #
#                                       decisao da gravacao do Nr.Fax.        #
#-----------------------------------------------------------------------------#
# 27/12/2000  correio      Ruiz         Inibir atualizacao do numero do fax   #
#                                       na tabela gcakfilial.                 #
#-----------------------------------------------------------------------------#
# 21/09/2005  AS87408      Priscila     Correcao para retornar dados para     #
#                                       a funcao solicitante e caminho globals#
###############################################################################
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Renato Zattar                    OSF : 4774             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 15/08/2002       #
#  Objetivo       : Alterar programa para comportar Endereco Eletronico     #
#---------------------------------------------------------------------------#
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# --------   ------------- --------  ---------------------------------------#
# 20/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.             #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"


   define
      vm_maides      like gcakfilial.maides

#-----------------------------------------------------------
 function cts09g01(param)
#-----------------------------------------------------------

 define param        record
    corsus           like gcaksusep.corsus,
    atualiza         char(01)
 end record

 define d_cts09g01   record
   txt               char (35),
   corsus            like gcaksusep.corsus  ,
   cornom            like gcakcorr.cornom   ,
   dddcod            like gcakfilial.dddcod ,
   factxt            like gcakfilial.factxt ,
   maides            like gcakfilial.maides
 end record

 define ws           record
   corsuspcp         like gcaksusep.corsuspcp ,
   corfilnum         like gcaksusep.corfilnum ,
   dddcod            like gcakfilial.dddcod   ,
   factxt            like gcakfilial.factxt   ,
   maides            like gcakfilial.maides   ,
   confirma          char (01),
   prompt_key        char (01)
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
   ,situacao          smallint
 end record



	initialize  d_cts09g01.*  to  null

	initialize  ws.*  to  null

	initialize  vl_gcakfilial.*  to  null
 if param.corsus  is null  then
    error " SUSEP nao informada. AVISE A INFORMATICA!"
    return d_cts09g01.dddcod
           ,d_cts09g01.factxt
	   ,d_cts09g01.maides
 end if

 let int_flag  =  false
 initialize d_cts09g01.*    to null
 initialize vl_gcakfilial.* to null
 initialize ws.*            to null

 # -- busca nome corretor -- #
   select corsus, cornom
     into d_cts09g01.corsus
         ,d_cts09g01.cornom
     from gcaksusep, gcakcorr
    where gcaksusep.corsus     = param.corsus    and
          gcakcorr.corsuspcp   = gcaksusep.corsuspcp

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
               ,vl_gcakfilial.situacao

 ##whenever error continue
 ##select gcaksusep.corsus   , gcakcorr.cornom  ,
 ##       gcakfilial.dddcod  , gcakfilial.factxt, gcakfilial.maides,
 ##       gcaksusep.corsuspcp, gcaksusep.corfilnum
 ##  into d_cts09g01.corsus, d_cts09g01.cornom,
 ##       ws.dddcod        , ws.factxt        , ws.maides ,
 ##       ws.corsuspcp     , ws.corfilnum
 ##  from gcaksusep, gcakcorr, gcakfilial
 ## where gcaksusep.corsus     = param.corsus         and
 ##       gcakcorr.corsuspcp   = gcaksusep.corsuspcp  and
 ##       gcakfilial.corsuspcp = gcaksusep.corsuspcp  and
 ##       gcakfilial.corfilnum = gcaksusep.corfilnum

 if vl_gcakfilial.situacao = 1 or
    vl_gcakfilial.situacao = 2 then
    error " Erro (", sqlca.sqlcode, ") na localizacao dos dados do corretor. AVISE A INFORMATICA !"
     return d_cts09g01.dddcod
	    ,d_cts09g01.factxt
   	    ,d_cts09g01.maides
 end if

 let ws.dddcod = vl_gcakfilial.dddfax
 let ws.factxt = vl_gcakfilial.factxt
 let ws.maides = vl_gcakfilial.maides

 if ws.dddcod  is null   then
    let ws.dddcod = "    "
 end if
 if ws.factxt  is null   then
    let ws.factxt = "    "
 end if
 if ws.maides  is null   then
    let ws.maides = "    "
 end if

 let d_cts09g01.dddcod = ws.dddcod
 let d_cts09g01.factxt = ws.factxt
 let d_cts09g01.maides = ws.maides

 if param.atualiza = "S"  then
    let d_cts09g01.txt = "Atualize Numero do Fax e E-Mail do Corretor"
 else
    let d_cts09g01.txt = "     Numero do Fax/E-Mail Corretor    "
 end if

 open window cts09g01 at 12,18 with form "cts09g01"
                         attribute (border, form line 1)

 display by name d_cts09g01.*

 input by name d_cts09g01.dddcod,
               d_cts09g01.factxt,
               d_cts09g01.maides  without defaults

   before field dddcod
      if param.atualiza = "N" then
         prompt "Confirme com <Enter> " for char ws.prompt_key
         exit input
      end if
      display by name d_cts09g01.dddcod    attribute (reverse)

   after  field dddcod
      display by name d_cts09g01.dddcod

      if d_cts09g01.dddcod  = " "     or
         d_cts09g01.dddcod  = "9999"  then
         initialize d_cts09g01.dddcod to null
      end if

   before field factxt
      display by name d_cts09g01.factxt    attribute (reverse)

   after  field factxt
      display by name d_cts09g01.factxt

      if fgl_lastkey()  =  fgl_keyval("up")   or
         fgl_lastkey()  =  fgl_keyval("left") then
         next field dddcod
      end if

      if d_cts09g01.factxt = " "        then
         initialize d_cts09g01.factxt to null
      end if

      if d_cts09g01.dddcod is not null  and
         d_cts09g01.factxt is     null  then
         error " Numero do FAX nao informado!"
         next field factxt
      end if

      if d_cts09g01.dddcod is     null  and
         d_cts09g01.factxt is not null  then
         error " Codigo de DDD nao informado!"
         next field dddcod
      end if

      if d_cts09g01.dddcod  is null   and
         d_cts09g01.factxt  is null   then
         let d_cts09g01.dddcod = "    "
         let d_cts09g01.factxt = "    "
      end if

   # -- OSF 4774 - Fabrica de Software, Katiucia -- #
   before field maides
      display by name d_cts09g01.maides    attribute (reverse)

   after  field maides
      display by name d_cts09g01.maides

      if fgl_lastkey()  =  fgl_keyval("up")   or
         fgl_lastkey()  =  fgl_keyval("left") then
         next field faxtxt
      end if

   on key (interrupt)
      initialize d_cts09g01.*  to null
      exit input

 end input

 # -- OSF 4774 - Fabrica de Software, Katiucia -- #
 if ws.dddcod <> d_cts09g01.dddcod  or
    ws.factxt <> d_cts09g01.factxt  or
    ws.maides <> d_cts09g01.maides  then
    call cts08g01("A"
                 ,"N"
                 ,"PARA ALTERACAO OU CORRECAO DO CORRETOR"
                 ,"ORIENTE O MESMO A CONTACTAR O "
                 ,"DEPARTAMENTO DE COMISSOES"
                 ,"SETOR CADASTRO DE CORRETORES")
         returning ws.confirma
 end if

#-----------------------------------------------
# Atualiza numero do fax do corretor
#-----------------------------------------------
{
 if ws.dddcod <> d_cts09g01.dddcod  or
    ws.factxt <> d_cts09g01.factxt  or
    ws.maides <> d_cts09g01.maides  then
    call cts08g01("A","S","NUMERO DO FAX/E-MAIL DO CORRETOR",
                          "SERA ALTERADO NO CADASTRO",
                          "",
                          "CONFIRMA?")
        returning ws.confirma

    if ws.confirma  =  "S"   then
      #if g_hostname = "u07"  then   # inibir esta atualizacao conforme
                                     # correio do Arnaldo 20/12/00.
         #update porto@u07:gcakfilial
         #   set (dddcod, factxt) = (d_cts09g01.dddcod,
         #                           d_cts09g01.factxt)
         # where corsuspcp = ws.corsuspcp  and
         #       corfilnum = ws.corfilnum
      #else
         #update porto@u25:gcakfilial
         #   set (dddcod, factxt) = (d_cts09g01.dddcod,
         #                           d_cts09g01.factxt)
         # where corsuspcp = ws.corsuspcp  and
         #       corfilnum = ws.corfilnum
      #end if

      #if sqlca.sqlcode  <>  0  then
      #   error " Erro (",sqlca.sqlcode,") na atualizacao do numero do FAX. AVISE A INFORMATICA !"
      #end if
    end if
 end if

 whenever error stop
}
 let int_flag = false

 close window cts09g01
 return d_cts09g01.dddcod
       ,d_cts09g01.factxt
       ,d_cts09g01.maides

end function  ###  cts09g01
