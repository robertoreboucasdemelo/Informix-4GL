###############################################################################
# Nome do Modulo: CTS10N00                                              Pedro #
#                                                                     Marcelo #
# Menu de Historico do Servico                                       Jan/1995 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 05/07/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts10n00(k_cts10n00)
#-----------------------------------------------------------

 define k_cts10n00  record
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    funmat          like datmservico.funmat,
    data            like datmservico.atddat,
    hora            like datmservico.atdhor
 end record

 define ws_atdsrvorg  like datmservico.atdsrvorg
 define ws_servico    char(13)
       ,l_erro   smallint   ---> Decreto - 6523
       ,l_msg    char(50)   ---> Decreto - 6523

 define l_msg_pri  char(100)

	let	ws_atdsrvorg  =  null
	let	ws_servico  =  null
 let l_erro = null
 let l_msg  = null

 open window w_cts10n00 at 04,02 with form "cts10m00"


 select atdsrvorg
   into ws_atdsrvorg
   from datmservico
  where atdsrvnum = k_cts10n00.atdsrvnum
    and atdsrvano = k_cts10n00.atdsrvano

 let ws_servico = ws_atdsrvorg         using "&&",      "/",
                  k_cts10n00.atdsrvnum using "&&&&&&&", "-",
                  k_cts10n00.atdsrvano using "&&"

 display ws_servico         to servico
 display g_documento.atdnum to atdnum attribute (reverse)

 let int_flag = false

 menu "HISTORICO"
    command key ("I")           "Implementa"
                                "Implementa dados no historico"
       call cts10m00(k_cts10n00.*)
       clear form
       display ws_servico         to  servico
       display g_documento.atdnum to atdnum attribute (reverse)
       next option "Encerra"

    command key ("C")           "Consulta"
                                "Consulta historico ja' cadastrado"
       call cts10m01(k_cts10n00.atdsrvnum, k_cts10n00.atdsrvano)
       clear form
       display ws_servico  to  servico
       next option "Encerra"

    command key (interrupt,"E")   "Encerra"    "Retorna ao menu anterior"
       if g_documento.acao is not null and g_documento.acao <> "RAD" then
          error " Obrigatorio registrar algo no historico!"
          next option "Implementa"
       else
          ---> Decreto - 6523
          if ((g_documento.lignum is not null and
               g_documento.lignum <> 0)       or
              (g_lignum_dcr       is not null and
               g_lignum_dcr       <> 0))      and
             g_documento.atdnum is not null and
             g_documento.atdnum <> 0        then
             for i = 1 to 3

                let l_erro = null
                let l_msg  = null

                begin work

                if (g_documento.lignum is not null and
                    g_documento.lignum <> 0)       then
                    if (g_documento.atdnum is not null and
                        g_documento.atdnum <> 0 ) then

                       let l_msg_pri = "PRI - cts10n00 1 - chamando ctd25g00"
                       call errorlog(l_msg_pri)

                        call ctd25g00_insere_atendimento(g_documento.atdnum
                                                        ,g_documento.lignum)
                             returning l_erro
                                      ,l_msg
                    end if
                else
                    if (g_documento.atdnum is not null and
                        g_documento.atdnum <> 0 )      and
                       (g_lignum_dcr is not null       and
                        g_lignum_dcr <>       0)       then

                       let l_msg_pri = "PRI - cts10n00 2 - chamando ctd25g00"
                       call errorlog(l_msg_pri)

                        call ctd25g00_insere_atendimento(g_documento.atdnum
                                                        ,g_lignum_dcr)
                             returning l_erro
                                      ,l_msg
                    end if
                end if

                if l_erro = 0 then
                   commit work
                   exit for
                else
                   rollback work
                end if
             end for
          end if
          exit menu
       end if
 end menu

 let int_flag = false

 close window w_cts10n00

end function  ###  cts10n00
