#############################################################################
# Nome do Modulo: CTE01M02                                             Akio #
#                                                                      Ruiz #
# Atendimento ao corretor - Chamada de programas externos          Abr/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/08/2000   as 21660    Arnaldo      passar o codigo da agencia para a   #
#                                       tela do orcamento.                  #
#---------------------------------------------------------------------------#
# 21/08/2000   psi 112461  Arnaldo      consulta ao ACPROPOSTA              #
#---------------------------------------------------------------------------#
# 20/09/2000   psi 113212  Arnaldo      consulta ao sistema de R.E          #
#---------------------------------------------------------------------------#
# 11/10/2000   psi                      chamada pgm "Mensagem de RE" - orca #
#---------------------------------------------------------------------------#
# 29/10/2001   PIS 140988  Ruiz         consulta ao agendamento de VP.      #
#---------------------------------------------------------------------------#
# 21/05/2002   PSI 154202  Ruiz         carregar a susep para tela de VP.   #
#---------------------------------------------------------------------------#
# 18/09/2002   PSI         Henrique     carregar o nr da solicitacao de CVN #
#---------------------------------------------------------------------------#
# 18/09/2002   Psi 161667  Ruiz         consulta ao PAC.                    #
#---------------------------------------------------------------------------#
# 30/12/2002   Psi 164208  Ruiz         Pendencia de orcamento              #
#---------------------------------------------------------------------------#
#...........................................................................#
#                                                                           #
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica  Origem     Alteracao                           #
# ----------  -------------- ---------- ------------------------------------#
# 22/09/2003  Alexson, Meta  PSI 173282 Verificar se o codigo do programa eh#
#                            OSF 26.573 (26,27,29,30)chamar o correspondente#
#---------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32        #
#                                                                           #
#############################################################################

globals "/homedsa/projetos/geral/globals/glcte.4gl" 

 define g_cte01m02        char(01)

#-------------------------------------------------------------------------------
 function cte01m02( p_cte01m02 )
#-------------------------------------------------------------------------------

   define p_cte01m02      record
          prgextcod       like dackass.prgextcod      ,
          corlignum       like dacmlig.corlignum      ,
          corligano       like dacmlig.corligano      ,
          corligitmseq    like dacmligass.corligitmseq,
          cvncptagnnum    like akckagn.cvncptagnnum   ,
          corsus          like dacrligsus.corsus
   end record

   define ws              record
          param           char(100)                 ,
          prgextdes       like dackprgext.prgextdes,
          prgsgl          like dackprgext.prgsgl   ,
          prgtip          like ibpkprog.prgtip     ,
          prgrnrsgl       like ibpkprog.prgrnrsgl  ,
          sissgl          like ibpmsistprog.sissgl ,
          var             array[14] of char(30)    ,
          ret             integer                  ,
          atdsrvnum       like dacrligvst.atdsrvnum  ,
          atdsrvano       like dacrligvst.atdsrvano  ,
          c24txtseq       like datmservhist.c24txtseq,
          ligdat          like datmservhist.ligdat   ,
          lighorinc       like datmservhist.lighorinc,
          c24srvdsc       like datmservhist.c24srvdsc,
          promptq         char (01),
          data            char (10),
          hora            char (05),
          acsnivcod       like issmnivnovo.acsnivcod
   end record
   define i               smallint
   define w_ret           smallint
   define w_comando       char(600)
   define l_comando       char(600)

 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------

   initialize ws.*      ,
              i         ,
              w_ret     ,
              w_comando ,
              l_comando   to null

 #------------------------------------------------------------------------------
 # Preparacao dos comandos SQL
 #------------------------------------------------------------------------------
   if  g_cte01m02 is null  then
       let g_cte01m02 = "N"

       let w_comando = "select prgextdes, "         ,
                              "prgsgl "             ,
                         "from DACKPRGEXT "         ,
                              "where prgextcod= ? "

       prepare s_dackprgext from   w_comando
       declare c_dackprgext cursor with hold for s_dackprgext

       let w_comando = "select prgtip, "           ,
                              "prgrnrsgl "         ,
                         "from IBPKPROG "          ,
                              "where prgsgl = ? "

       prepare s_ibpkprog  from   w_comando
       declare c_ibpkprog  cursor with hold for s_ibpkprog

       let w_comando = "select sissgl "           ,
                         "from IBPMSISTPROG "     ,
                              "where prgsgl = ? "

       prepare s_ibpmsistprog  from   w_comando
       declare c_ibpmsistprog  cursor with hold for s_ibpmsistprog

       let w_comando = "select corlignum, "            ,
                              "corligano "             ,
                         "from DACRLIGORC "            ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligorc  from   w_comando
       declare c_dacrligorc  cursor with hold for s_dacrligorc

       let w_comando = "select corlignum "             ,
                              "atdsrvano "             ,
                         "from DACRLIGPAC "            ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligpac  from   w_comando
       declare c_dacrligpac  cursor with hold for s_dacrligpac

       let w_comando = "select corlignum "             ,
                              "atdsrvano "             ,
                         "from DACRLIGRMEORC "            ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligrmeorc from   w_comando
       declare c_dacrligrmeorc cursor with hold for s_dacrligrmeorc

       let w_comando = "select corlignum "             ,
                              "atdsrvano "             ,
                         "from DACRLIGPNDCVN "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligpndcvn from   w_comando
       declare c_dacrligpndcvn  cursor with hold for s_dacrligpndcvn

       let w_comando = "select atdsrvnum, "            ,
                              "atdsrvano "             ,
                         "from DACRLIGVST "            ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligvst  from   w_comando
       declare c_dacrligvst  cursor with hold for s_dacrligvst

       let w_comando = "select corlignum "             ,
                              "atdsrvano "             ,
                         "from DACRLIGSMPRNV "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligsmprnv  from   w_comando
       declare c_dacrligsmprnv  cursor with hold for s_dacrligsmprnv

       let w_comando = "select corlignum "             ,
                              "atdsrvano "             ,
                         "from DACRLIGAGNVST "         ,
                              "where corlignum = ? "   ,
                                "and corligano = ? "   ,
                                "and corligitmseq = ? "

       prepare s_dacrligagnvst  from   w_comando
       declare c_dacrligagnvst  cursor with hold for s_dacrligagnvst


       let w_comando = "select c24txtseq, "            ,
                              "ligdat   , "            ,
                              "lighorinc, "            ,
                              "c24srvdsc "             ,
                         "from DATMSERVHIST "          ,
                              "where atdsrvnum = ? "   ,
                                "and atdsrvano = ? "

       prepare s_datmservhist   from   w_comando
       declare c_datmservhist   cursor with hold for s_datmservhist

       let w_comando = "insert into DACMLIGASSHST( corlignum, "    ,
                                                  "corligano, "    ,
                                                  "corligitmseq, " ,
                                                  "c24txtseq   , " ,
                                                  "c24ligdsc   , " ,
                                                  "cademp      , " ,
                                                  "cadmat      , " ,
                                                  "caddat      , " ,
                                                  "cadhor       ) ",
                                   "values( ?,?,?,?,?,?,?,?,? ) "

       prepare i_dacmligasshst  from   w_comando
   end if


 #------------------------------------------------------------------------------
 # Seleciona os programas a serem executados
 #------------------------------------------------------------------------------

   let w_ret = false

   while true

      open  c_dackprgext using p_cte01m02.prgextcod
      fetch c_dackprgext into  ws.prgextdes,
                               ws.prgsgl
        if  sqlca.sqlcode <> 0  then
            error " Erro (", sqlca.sqlcode, ") durante ",
                  "a chamada do pgm externo n. ",
                  p_cte01m02.prgextcod using "#&",
                  ". AVISE A INFORMATICA!"
            exit while
        end if

      open  c_ibpkprog using ws.prgsgl
      fetch c_ibpkprog into  ws.prgtip   ,
                             ws.prgrnrsgl
        if  sqlca.sqlcode <> 0  then
            error " Erro (", sqlca.sqlcode, ") durante ",
                  "a pesquisa do programa ", ws.prgsgl clipped,
                  ". AVISE A INFORMATICA!"
            exit while
        end if
       
    #---------------------------------------------------------------------------
    # Alteracao conforme PSI 173282 OSF 26.573
    #---------------------------------------------------------------------------
      if p_cte01m02.prgextcod = 26 or p_cte01m02.prgextcod = 27 or
         p_cte01m02.prgextcod = 29 or p_cte01m02.prgextcod = 30 then
         let l_comando = ""              ,
                         g_issk.succod   , " ",   #-> Sucursal
                         g_issk.funmat   , " ",   #-> Matricula do funcionario
                         "'",g_issk.funnom,"'"," ", #-> Nome do funcionario
                         g_issk.dptsgl   , " ",   #-> Sigla do departamento
                         g_issk.dpttip   , " ",   #-> Tipo do departamento
                         g_issk.dptcod   , " ",   #-> Codigo do departamento
                         g_issk.sissgl   , " ",   #-> Sigla sistema
                         g_issk.acsnivcod, " ",   #-> Nivel de acesso                 
                         ws.prgsgl       , " ",   #-> Sigla programa - "Consultas"
                         g_issk.usrtip   , " ",   #-> Tipo de usuario
                         g_issk.empcod   , " ",   #-> Codigo da empresa
                         g_issk.iptcod   , " ",   
                         g_issk.usrcod   , " ",   #-> Codigo do usuario
                         g_issk.maqsgl   , " "    #-> Sigla da maquina
                
         call roda_prog(ws.prgsgl,l_comando,1)
              returning ws.ret
         if  ws.ret <> 0  then
             error " Erro durante a execucao do programa ", ws.prgsgl clipped,
                   ". AVISE A INFORMATICA!"
             let ws.ret = false
             exit while
         end if
      end if

    #---------------------------------------------------------------------------
    # Monta parametros para execucao dos programas externos
    #---------------------------------------------------------------------------
      initialize ws.param to null
      let ws.param[01,05] = "ctg12"
      let ws.param[06,10] = p_cte01m02.cvncptagnnum using "&&&&&"
      let ws.param[11,20] = p_cte01m02.corlignum using "&&&&&&&&&&"
      let ws.param[21,25] = p_cte01m02.corligitmseq using "&&&&&"

    #---------------------------------------------------------------------------
    # Monta comando do programa externo
    #---------------------------------------------------------------------------
     #if  p_cte01m02.prgextcod = 7  or # o pgm ocvic001 nao esta cadastrado
                                       # no sistema de seguranca. ruiz 270600.
        # p_cte01m02.prgextcod = 11 or # o pgm orflc390 nao esta cadastrado
                                       # no sistema de seguranca.
        # p_cte01m02.prgextcod = 13 or
        # p_cte01m02.prgextcod = 14 or
        # p_cte01m02.prgextcod = 15 or
        # p_cte01m02.prgextcod = 16 or
        # p_cte01m02.prgextcod = 17 or

     #if  p_cte01m02.prgextcod = 20 or
      if  p_cte01m02.prgextcod = 18 then # o pgm oaoca077 nao esta cadastrado
                                         # no sistema de seguranca.         
          case  p_cte01m02.prgextcod
             when 13                   # ears.4gi - frara062 - fax.Rs.RE
                let ws.param[26,30] = "RSFAX"
             when 14                   # ears.4gi - orarc222 - con.Rs.RE
                let ws.param[26,30] = "RSCON"
             when 15                   # eroc.4gi - orama413 - fax.RE
                let ws.param[26,30] = "ORFAX"
             when 16                   # ears.4gl - orara221 - 2.o via Rs.RE
                let ws.param[26,30] = "RSSEG"
             when 17                   # eroc.4gi - orama400 - orc.RE
                let ws.param[26,30] = "ORORC"
             when 20
               #let ws.param = arg_val(15),"' '",arg_val(16),"' 'vago' 'vago",
               #               "' 'vago' 'vago' 'SIM' '"
                let ws.param = " ","' '",arg_val(16),"' 'vago' 'vago",
                               "' 'vago' 'vago' 'SIM' '"
          end case

          if  ws.prgtip <> "4GC"  then
              let w_comando = ws.prgrnrsgl clipped,
                              " ", ws.prgsgl clipped
          else
              let w_comando = ws.prgsgl clipped, ".4gc "
          end if

          if g_hostname = "u07" and p_cte01m02.prgextcod = 3  then
            let ws.prgsgl = "oaocp_c"
            let w_comando = "oaocp_c "
          end if

          for i = 1 to 14
              let ws.var[i] = arg_val(i)
              if  ws.var[i] is null  then
                  let ws.var[i] = "0"
              end if
          end for

          let w_comando = w_comando clipped,
                  " '",ws.var[01],"' '",ws.var[02],"' '",ws.var[03],"' ",
                   "'",ws.var[04],"' '",ws.var[05],"' '",ws.var[06],"' ",
                   "'",ws.var[07],"' '",ws.var[08],"' '",ws.prgsgl clipped,"' ",
                   "'",ws.var[10],"' '",ws.var[11],"' '",ws.var[12],"' ",
                   "'",ws.var[13],"' '",ws.var[14],"' '",ws.param  clipped,"' "

          if g_issk.funmat = 601566 then
             display "w_comando-",w_comando,"/",g_issk.acsnivcod,"/",g_issk.funmat
            #prompt "" for char ws.promptq
          end if
          run w_comando returning ws.ret

          if  ws.ret = 0      or
              ws.ret = 65535  then  # OK
              let w_ret = true
          end if
      else   
         if p_cte01m02.prgextcod <> 26 and p_cte01m02.prgextcod <> 27 and
            p_cte01m02.prgextcod <> 29 and p_cte01m02.prgextcod <> 30 then
            open  c_ibpmsistprog using ws.prgsgl
            fetch c_ibpmsistprog into  ws.sissgl
            if  sqlca.sqlcode <> 0  then
                error " Erro (", sqlca.sqlcode, ") durante ",
                      "a chamada do programa ", ws.prgsgl clipped,
                      ". AVISE A INFORMATICA!"
                exit while
            end if
            case  p_cte01m02.prgextcod
                when 1  # Marcacao de VP    | Codigo de inclusao
                  let ws.param[26,30] = "I"
                  let ws.param[31,36] = p_cte01m02.corsus
                  let ws.param[37,51] = g_c24solnom
  
                when 2  # Alteracao de VP   | Codigo de alteracao
                  let ws.param[26,30] = "A"
  
                when 3  # Orcamento         | Numero da PA
                  let ws.param[26,30]= g_c24paxnum
                  let ws.param[31,34] = p_cte01m02.corligano
                  let ws.sissgl      = "Orc_ct24h2" #isto esta fixo porque existe
                                                    # 4 sistemas chamando o mesmo
                                                    # programa(oaocp).ruiz 230600.
                when 4  # Proposta          | Numero da PA
                  let ws.param[26,30] = g_c24paxnum
                  let ws.param[31,34] = p_cte01m02.corligano
                when 9  ### Con_Auto
                  initialize ws.param to null
                  let ws.sissgl      = "Auto_ct24h" #isto esta fixo porque existe
                                                    # mais de 1 sistema chamando o mesmo
                                                    # programa(abs). Denis 23/10/2008.
                when 13                   # ears.4gi - frara062 - fax.Rs.RE
                  let ws.param[26,30] = "RSFAX"
                when 14                   # ears.4gi - orarc222 - con.Rs.RE
                  let ws.param[26,30] = "RSCON"
                when 15                   # eroc.4gi - orama413 - fax.RE
                  let ws.param[26,30] = "ORFAX"
                when 16                   # ears.4gl - orara221 - 2.o via Rs.RE
                  let ws.param[26,30] = "RSSEG"
                when 17                   # eroc.4gi - orama400 - orc.RE
                  let ws.param[26,30] = "ORORC"
                when 20
                 #let ws.param = arg_val(15),"' '",arg_val(16),"' 'vago' 'vago",
                 #               "' 'vago' 'vago' 'SIM' '"
                  let ws.param = " ","' '",arg_val(16),"' 'vago' 'vago",
                                 "' 'vago' 'vago' 'SIM' '"
                when 21         # agendamento
                  let ws.data         =  today
                  let ws.hora         =  current hour to minute
                  initialize ws.param to null
                  let ws.param[01,01] = "C"       # ct24hs
                  let ws.param[02,11] = p_cte01m02.corlignum using "&&&&&&&&&&"
                  let ws.param[42,51] = ws.data
                  let ws.param[52,56] = ws.hora
                  let ws.param[57,62] = g_issk.funmat
                  let ws.param[67,67] = "2"       # agendamento de VP
                  let ws.param[68,68] = "A"  # agendar
                  let ws.param[69,73] = "CTG12"
                  let ws.param[74,78] =  p_cte01m02.corligitmseq using "&&&&&"
                  let ws.param[79,79] = "1"       # sequencia do historico
                  let ws.param[80,85] = p_cte01m02.corsus
  
  # Henrique      let ws.param[65,65] = "2"       # agendamento de VP
  # Chamado 306670let ws.param[66,66] = "A"  # agendar
  # 03/07/2003    let ws.param[67,71] = "CTG12"
  #               let ws.param[72,76] =  p_cte01m02.corligitmseq using "&&&&&"
  #               let ws.param[77,77] = "1"       # sequencia do historico
  #               let ws.param[78,83] = p_cte01m02.corsus
                when 22         # cancelamento
                  let ws.data         =  today
                  let ws.hora         =  current hour to minute
                  initialize ws.param to null
                  let ws.param[01,01] = "C"       # ct24hs
                  let ws.param[02,11] = p_cte01m02.corlignum using "&&&&&&&&&&"
                  let ws.param[42,51] = ws.data
                  let ws.param[52,56] = ws.hora
                  let ws.param[57,62] = g_issk.funmat
                  let ws.param[67,67] = "2"       # agendamento de VP
                  let ws.param[68,68] = "C"  # cancelar
                  let ws.param[69,73] = "CTG12"
                  let ws.param[74,78] =  p_cte01m02.corligitmseq using "&&&&&"
                  let ws.param[79,79] = "1"       # sequencia do historico
                  let ws.param[80,85] = p_cte01m02.corsus
  
  #               let ws.param[65,65] = "2"       # agendamento de VP
  #               let ws.param[66,66] = "C"  # cancelar
  #               let ws.param[67,71] = "CTG12"
  #               let ws.param[72,76] =  p_cte01m02.corligitmseq using "&&&&&"
  #               let ws.param[77,77] = "1"       # sequencia do historico
  #               let ws.param[78,83] = p_cte01m02.corsus
                when 25  # Estudo aceitacao
                  let ws.sissgl      = "Estudo_ac2" #isto esta fixo porque existe
                                                    # 3 sistemas chamando o mesmo
                                                    # programa(oaacm100)raji 0902
            end case
  
           #-------------------------------------------------------------------
           # Chama funcao do suporte para execucao dos programas externos
           #-------------------------------------------------------------------
  
           #error  "chama_prog - ", ws.sissgl,"/",ws.prgsgl,"/",ws.param
           #prompt "" for char ws.promptq
  
            if g_hostname = "u07" and p_cte01m02.prgextcod = 3  then
              let ws.prgsgl = "oaocp_c"
            end if
  
            if g_issk.funmat = 601566 then
               display "ws.sissgl = ", ws.sissgl
               display "ws.prgsgl = ", ws.prgsgl
               display "ws.param  = ", ws.param
            end if
            if p_cte01m02.prgextcod = 07 or   
               p_cte01m02.prgextcod = 11 or
               p_cte01m02.prgextcod = 13 or   
               p_cte01m02.prgextcod = 14 or   
               p_cte01m02.prgextcod = 15 or    
               p_cte01m02.prgextcod = 16 or   
               p_cte01m02.prgextcod = 17 or   
             # p_cte01m02.prgextcod = 18 or   
               p_cte01m02.prgextcod = 20 or   
               p_cte01m02.prgextcod = 21 or
               p_cte01m02.prgextcod = 22 or
               p_cte01m02.prgextcod = 23 then
              #select acsnivcod
              #   into ws.acsnivcod
              #   from issmnivnovo
              #  where usrcod = g_issk.usrcod
              #    and sissgl = ws.sissgl  
   
               let w_comando = ""
                    ,g_issk.succod     , " "    #-> Sucursal
                    ,g_issk.funmat     , " "    #-> Matricula do funcionario
                ,"'",g_issk.funnom,"'" , " "    #-> Nome do funcionario
                    ,g_issk.dptsgl     , " "    #-> Sigla do departamento
                    ,g_issk.dpttip     , " "    #-> Tipo do departamento
                    ,g_issk.dptcod     , " "    #-> Codigo do departamento
                    ,g_issk.sissgl     , " "    #-> Sigla sistema
                    ,0                 , " "    #-> Nivel de acesso
                   #,1                 , " "    #-> Nivel de acesso
                   #,ws.acsnivcod      , " "
                    ,ws.sissgl         , " "    #-> Sigla programa - "Consultas"
                    ,g_issk.usrtip     , " "    #-> Tipo de usuario
                    ,g_issk.empcod     , " "    #-> Codigo da empresa
                    ,g_issk.iptcod     , " "
                    ,g_issk.usrcod     , " "    #-> Codigo do usuario
                    ,g_issk.maqsgl     , " "    #-> Sigla da maquina
                    ,"'",ws.param      , "'"
               if g_issk.funmat = 601566 then
                  display "roda_prog,w_comando = ", w_comando
               end if
               call roda_prog(ws.prgsgl,w_comando,1)
                    returning ws.ret
               if  ws.ret <> 0  then
                   error " Erro durante ",
                      "a execucao do programa ", ws.prgsgl clipped,
                      ". AVISE A INFORMATICA!"
               end if
            else
               if g_issk.funmat = 601566 then
                  display "chama_prog,w_comando = ", w_comando
               end if
               call chama_prog( ws.sissgl,
                                ws.prgsgl,
                                ws.param  )
                      returning ws.ret
            end if
            if  ws.ret <> 0  then
                error ws.ret," Erro durante ",
                      "a execucao do programa ", ws.prgsgl clipped,
                      ". AVISE A INFORMATICA!"
            end if
         end if
      end if
    #---------------------------------------------------------------------------
    # Verifica gravacao do relacionamento ligacao - documento
    #---------------------------------------------------------------------------
      case p_cte01m02.prgextcod

        when 0                        # REGISTRO GENERICO
             let w_ret = true

        when 1                        # MARCACAO DE VIST. PREVIA DOMICILIAR
             open  c_dacrligvst using  p_cte01m02.corlignum   ,
                                       p_cte01m02.corligano   ,
                                       p_cte01m02.corligitmseq
             fetch c_dacrligvst into   ws.atdsrvnum,
                                       ws.atdsrvano
                if  sqlca.sqlcode = 0  then
                  #-------------------------------------------------------------
                  # Replica historico do servico na ligacao - apenas para VP
                  #-------------------------------------------------------------
                    begin work
                    open  c_datmservhist using ws.atdsrvnum,
                                               ws.atdsrvano
                    foreach c_datmservhist into ws.c24txtseq,
                                                ws.ligdat   ,
                                                ws.lighorinc,
                                                ws.c24srvdsc
                        execute i_dacmligasshst using p_cte01m02.corlignum   ,
                                                      p_cte01m02.corligano   ,
                                                      p_cte01m02.corligitmseq,
                                                      ws.c24txtseq           ,
                                                      ws.c24srvdsc           ,
                                                      g_issk.empcod          ,
                                                      g_issk.funmat          ,
                                                      ws.ligdat              ,
                                                      ws.lighorinc
                    end foreach
                    commit work
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 2                         # ALTERACAO MARCACAO VIST. PREVIA
             open  c_dacrligvst using  p_cte01m02.corlignum   ,
                                       p_cte01m02.corligano   ,
                                       p_cte01m02.corligitmseq
             fetch c_dacrligvst into   ws.atdsrvnum,
                                       ws.atdsrvano
                if  sqlca.sqlcode = 0  then
                  #-------------------------------------------------------------
                  # Replica historico do servico na ligacao - apenas para VP
                  #-------------------------------------------------------------
                    begin work
                    open  c_datmservhist using ws.atdsrvnum,
                                               ws.atdsrvano
                    foreach c_datmservhist into ws.c24txtseq,
                                                ws.ligdat   ,
                                                ws.lighorinc,
                                                ws.c24srvdsc
                        execute i_dacmligasshst using p_cte01m02.corlignum   ,
                                                      p_cte01m02.corligano   ,
                                                      p_cte01m02.corligitmseq,
                                                      ws.c24txtseq           ,
                                                      ws.c24srvdsc           ,
                                                      g_issk.empcod          ,
                                                      g_issk.funmat          ,
                                                      ws.ligdat              ,
                                                      ws.lighorinc
                    end foreach
                    commit work
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 3                         # ORCAMENTO DE AUTOMOVEL
             open  c_dacrligorc using  p_cte01m02.corlignum   ,
                                       p_cte01m02.corligano   ,
                                       p_cte01m02.corligitmseq
             fetch c_dacrligorc
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 4                         # MANUTENCAO DE PROPOSTAS
             open  c_dacrligsmprnv using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligsmprnv
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 5                         # CONSULTA GENERICAS
             let w_ret = true

        when 6                         # NAO ESTA FUNCIONADO (CONVENIO)
             open  c_dacrligpndcvn using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligpndcvn
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 7                         # ENVIO DE FAX
             let w_ret = true

        when 8                         # CONS. VALOR MERCADO
             let w_ret = true

        when 9                         # CONSULTA DE DOCUMENTOS
             let w_ret = true

        when 10                        # CONSULTA R.S
             let w_ret = true

        when 11                        # CONSULTA AO PAC
             open  c_dacrligpac using  p_cte01m02.corlignum   ,
                                       p_cte01m02.corligano   ,
                                       p_cte01m02.corligitmseq
             fetch c_dacrligpac
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 12   # CONSULTA AO ACPROPOSTA
             let w_ret = true

        when 13   # fax.RS.RE
             open  c_dacrligrmeorc using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligrmeorc
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 14   # consulta.Rs.R.E
             open  c_dacrligrmeorc using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligrmeorc
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 15   # fax R.E
             open  c_dacrligrmeorc using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligrmeorc
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 16   # 2.o via Rs. R.E
             open  c_dacrligrmeorc using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligrmeorc
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 17   # Orcamento   R.E
             open  c_dacrligrmeorc using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligrmeorc
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 18                        # MENSAGEM DE RE
             let w_ret = true

        when 19                        # CONSULTA VISTORIA PREVIA
             let w_ret = true

        when 20                        # CONSULTA APOL. RE
             let w_ret = true

        when 21
             open  c_dacrligagnvst using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligagnvst
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 22
             open  c_dacrligagnvst using  p_cte01m02.corlignum   ,
                                          p_cte01m02.corligano   ,
                                          p_cte01m02.corligitmseq
             fetch c_dacrligagnvst
                if  sqlca.sqlcode = 0  then
                    let w_ret = true
                else
                    let w_ret = false
                end if

        when 23                        # CONSULTA DE CONENIOS
             let w_ret = true

        when 24                        # CADASTRO DE ORCAMENTO
             let w_ret = true

        when 25                        # ESTUDO ACEITACAO
             let w_ret = true
        
        when 26                        # Alteracao conforme PSI 173282
             let w_ret = true
        
        when 27                        # Alteracao conforme PSI 173282
             let w_ret = true
        
        when 29                        # Alteracao conforme PSI 173282
             let w_ret = true
        
        when 30                        # Alteracao conforme PSI 173282
             let w_ret = true

        otherwise
             let w_ret = true ###false

      end case
      exit while

   end while

   return w_ret

end function

