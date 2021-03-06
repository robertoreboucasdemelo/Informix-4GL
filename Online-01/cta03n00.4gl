###############################################################################
# Nome do Modulo: CTA03N00                                              Pedro #
#                                                                     Marcelo #
# Menu de Historico da Ligacao                                       Jan/1995 #
###############################################################################
#.............................................................................#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor   Fabrica     Origem    Alteracao                          #
# ---------- ----------------- ----------  -----------------------------------#
# 18/03/2005 James, Meta       PSI 191094  Chamar a funcao cta00m06()         #
#-----------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada  #
#                                          por ctd25g00                       #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------
 function cta03n00(param)
#-------------------------------------------------------

 define param    record
    lignum       like datmlighist.lignum,
    funmat       like datmlighist.c24funmat,
    data         like datmlighist.ligdat,
    hora         like datmlighist.lighorinc
 end record

 define w_cabec  char (34)
       ,l_erro   smallint   ---> Decreto - 6523
       ,l_msg    char(50)   ---> Decreto - 6523

 define l_msg_pri char(100)

 let	w_cabec  =  null
 let l_erro = null
 let l_msg  = null



 let int_flag = false

 open window w_cta03n00 at 04,02 with form "cta03m00"

 display by name param.lignum
                ,g_documento.atdnum attribute (reverse)

 if cta00m06(g_issk.dptsgl) = 1 then
    display "(F1)Help  (F5)Espelho" at 19,2
 end if

 menu "HISTORICO"
    command key ("I")             "Implementa"
                                  "Implementa dados no historico"
       display by name param.lignum
                      ,g_documento.atdnum attribute (reverse)
       if g_documento.atdnum is not null then
          call ctd25g00_con_num_atend(param.lignum, g_documento.atdnum)
               returning l_erro
          if l_erro = 1 then
             call ctd25g00_insere_atendimento(g_documento.atdnum
                                             ,g_documento.lignum)
                  returning l_erro
                           ,l_msg
          end if
       end if

       call cta03m00(param.*)
       next option "Encerra"

    command key ("C")             "Consulta"
                                  "Consulta historico ja' cadastrado"

       display by name param.lignum
                      ,g_documento.atdnum attribute (reverse)

       call cta03m01(param.lignum)
       next option "Encerra"

    command key ("E", interrupt)  "Encerra"
                                  "Retorna ao menu anterior"

       display by name param.lignum
                      ,g_documento.atdnum attribute (reverse)

       if g_documento.acao is not null  then
          error " Obrigatorio registrar algo no historico!"
          next option "Implementa"
       else
          ---> Decreto - 6523
          if g_documento.assuntob16 = 1 then
             for i = 1 to 3
                let l_erro = null
                let l_msg  = null

                begin work

                call ctd26g00_insere_tranferencia(g_documento.atdnum
                                                 ,g_documento.lignum
                                                 ,g_documento.lignum_b16
                                                 ,g_c24paxnum
                                                 ,g_issk.dptsgl
                                                 ,g_issk.funmat
                                                 ,g_issk.usrtip
                                                 ,g_issk.empcod)
                      returning l_erro
                               ,l_msg

                if l_erro = 0 then
                   commit work
                   exit for
                else
                   rollback work
                end if
             end for
             let g_documento.assuntob16 = null
             let g_documento.lignum_b16 = null
          end if

          if ((g_documento.lignum is not null and
               g_documento.lignum <> 0)       or
              (g_lignum_dcr       is not null and
               g_lignum_dcr       <> 0))      and
             g_documento.atdnum is not null and
             g_documento.atdnum <> 0        then

                let l_erro = null
                let l_msg  = null

             ---> S51 - Quando S68 - Laudo eh abandonado, nao preciso gerar
             ---> atendimentop porque ja gerou antes
             if g_documento.c24astcod <> "S51" then
                begin work


                if (g_documento.lignum is not null and
                    g_documento.lignum <> 0)       then
                    if (g_documento.atdnum is not null and
                        g_documento.atdnum <> 0 ) then

                       let l_msg_pri = "PRI - cta03n00 1 - chamando ctd25g00"
                       call errorlog(l_msg_pri)

                       call ctd25g00_insere_atendimento(g_documento.atdnum
                                                       ,g_documento.lignum)
                            returning l_erro
                                     ,l_msg
                    end if
                else
                    if (g_documento.atdnum is not null and
                        g_documento.atdnum <> 0)       and
                       (g_lignum_dcr is not null       and
                        g_lignum_dcr <>       0)       then

                       let l_msg_pri = "PRI - cta03n00 2 - chamando ctd25g00"
                       call errorlog(l_msg_pri)

                        call ctd25g00_insere_atendimento(g_documento.atdnum
                                                         ,g_lignum_dcr)
                             returning l_erro
                                       ,l_msg
                    end if
                end if

                if l_erro = 0 then
                   commit work
                else
                   error l_msg sleep 3
                   rollback work
                end if
             end if
          end if

          exit menu
       end if
 end menu

 let int_flag = false

 close window w_cta03n00

end function  ###  cta03n00
