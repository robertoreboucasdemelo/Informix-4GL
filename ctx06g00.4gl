#############################################################################
# Nome do Modulo: ctx06g00                                         Marcelo  #
#                                                                  Gilberto #
# Chama programa externos a serem executados                       Jul/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 21/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 14/04/2000  Correio      Akio         Alteracao na chamada da pesquisa    #
#                                       clausula 18 - pgm oaeia035          #
#---------------------------------------------------------------------------#
# 07/02/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
#---------------------------------------------------------------------------#
# 19/07/2006               Andrei, Meta Migracao de versao do 4gl           #
#############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------------------------
 function ctx06g00(param)
#-------------------------------------------------------------------------------

 define param           record
        runner          char (10),
        prgnom          char (50)
 end record

 define ws              record
        entrada         char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlerro         integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        comando         char (900),
        data            date,
        hora            datetime hour to minute,
        sissgl          like ibpmsistprog.sissgl,
        prgsgl          like ibpmsistprog.prgsgl,
        ret             smallint ,
        param           char (100)
 end record

 define var             array[14] of char(50)

 define l_data      date,
        l_hora2     datetime hour to minute



	initialize  ws.*  to  null
        initialize var  to null

 while true
   initialize ws.*  to null
   initialize var  to null

   message " Aguarde, executando ", param.prgnom clipped, "... "
           attribute (reverse)

   if  param.runner = "4GC"  then
       let ws.comando = param.prgnom clipped,".4gc"
   else
       let ws.comando = param.runner clipped , " ", param.prgnom clipped
   end if
   if  param.prgnom = "oaeia035"  then
       if  g_documento.succod     is null   or
           g_documento.ramcod     is null   or
           g_documento.aplnumdig  is null   or
           g_documento.itmnumdig  is null   then
           error " Parametros nao informados. AVISE A INFORMATICA!"
           prompt "" for char ws.entrada
           exit while
       end if
      {
       for i = 1 to 14
           let var[i] = arg_val(i)
           if  var[i] is null  then
               let var[i] = "0"
           end if
       end for
       let ws.comando = ws.comando clipped   , " ",
                    "'",var[01],"' ","'",var[02],"' ","'",var[03],"' ",
                    "'",var[04],"' ","'",var[05],"' ","'",var[06],"' ",
                    "'",var[07],"' ","'",var[08],"' ","'oaeia035' ",
                    "'",var[10],"' ","'",var[11],"' ","'",var[12],"' ",
                    "'",var[13],"' ","'",var[14],"' ",
                     g_documento.succod   , " ",   #-> Sucursal
                     g_documento.aplnumdig, " ",   #-> Apolice
                     g_documento.itmnumdig         #-> Item
       }
            #select sissgl
            #    into ws.sissgl
            #    from ibpmsistprog
            #   where prgsgl = "oaeia035"
             let ws.sissgl  = "018"
             let ws.param   = g_documento.succod using "<&" , " ", #-> Sucursal
                              g_documento.aplnumdig using "<<<<<<<<&", " ",  #-> Apolice
                              g_documento.itmnumdig using "<<<<<<<&"  #-> Item

             let ws.comando = ""
                  ,g_issk.succod     , " "    #-> Sucursal
                  ,g_issk.funmat     , " "    #-> Matricula do funcionario
              ,"'",g_issk.funnom,"'" , " "    #-> Nome do funcionario
                  ,g_issk.dptsgl     , " "    #-> Sigla do departamento
                  ,g_issk.dpttip     , " "    #-> Tipo do departamento
                  ,g_issk.dptcod     , " "    #-> Codigo do departamento
                  ,g_issk.sissgl     , " "    #-> Sigla sistema
                  ,0                 , " "    #-> Nivel de acesso
                  ,ws.sissgl         , " "    #-> Sigla programa - "Consultas"
                  ,g_issk.usrtip     , " "    #-> Tipo de usuario
                  ,g_issk.empcod     , " "    #-> Codigo da empresa
                  ,g_issk.iptcod     , " "
                  ,g_issk.usrcod     , " "    #-> Codigo do usuario
                  ,g_issk.maqsgl     , " "    #-> Sigla da maquina
                  ,ws.param
             call roda_prog("oaeia035",ws.comando,1)
                  returning ws.ret
             if  ws.ret <> 0  then
                 error " Erro durante ",
                    "a execucao do programa ", ws.prgsgl clipped,
                    ". AVISE A INFORMATICA!"
             end if
   end if

 # run ws.comando

   call cts40g03_data_hora_banco(2)
       returning l_data, l_hora2
   let ws.data = l_data
   let ws.hora = l_hora2

 #------------------------------------------------------------------------------
 # Busca numeracao ligacao
 #------------------------------------------------------------------------------
   begin work

   call cts10g03_numeracao( 1, "" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.sqlerro  ,
                  ws.msg

   ---> Decreto - 6523
   let g_lignum_dcr = ws.lignum

   if  ws.sqlerro <> 0  then
       let ws.msg = "CTX06G00 - ",ws.msg
       call ctx13g00(ws.sqlerro,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.entrada
       let ws.retorno = false
       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava dados da ligacao
 #------------------------------------------------------------------------------
   call cts10g00_ligacao ( ws.lignum               ,
                           ws.data                 ,
                           ws.hora                 ,
                           g_documento.c24soltipcod,
                           g_documento.solnom      ,
                           g_documento.c24astcod   ,
                           g_issk.funmat           ,
                           g_documento.ligcvntip   ,
                           g_c24paxnum             ,
                           "","", "","", "",""     ,
                           g_documento.succod      ,
                           g_documento.ramcod      ,
                           g_documento.aplnumdig   ,
                           g_documento.itmnumdig   ,
                           g_documento.edsnumref   ,
                           g_documento.prporg      ,
                           g_documento.prpnumdig   ,
                           g_documento.fcapacorg   ,
                           g_documento.fcapacnum   ,
                           "","","",""             ,
                           "", "", "", ""           )
        returning ws.tabname,
                  ws.sqlerro

   if  ws.sqlerro  <>  0  then
       error " Erro (", ws.sqlerro, ") na gravacao da",
             " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
       rollback work
       prompt "" for char ws.entrada
       let ws.retorno = false
       exit while
   end if

   commit work

   error " Registre as informacoes no historico!"
   call cta03n00(ws.lignum, g_issk.funmat, ws.data, ws.hora)

   exit while
 end while

end function  ###  ctx06g00
