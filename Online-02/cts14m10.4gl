###############################################################################
# Nome do Modulo: CTS14M10                                              Pedro #
#                                                                     Marcelo #
# Menu de Historico da Vistoria de Sinistro                          Jul/1995 #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# ---------- ------------- --------- ----------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada #
#                                          por ctd25g00                      #
# ---------------------------------------------------------------------------#
# 20/02/2009 Nilo           Psi234311  Danos Eletricos                       #
# ---------------------------------------------------------------------------#
##############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------
function cts14m10(k_cts14m10)
#------------------------------------

   define k_cts14m10  record
     sinvstnum  like  datmvstsin.sinvstnum,
     sinvstano  like  datmvstsin.sinvstano,
     funmat     like  datmvstsin.funmat,
     data       like  datmvstsin.atddat,
     hora       like  datmvstsin.atdhor
   end record

   define ws_vistoria char(11)
       ,l_erro        smallint   ---> Decreto - 6523
       ,l_msg         char(50)   ---> Decreto - 6523
       ,w_erro_P10    smallint   ---> Danos Eletricos


	let	ws_vistoria  =  null
        let     l_erro       =  null
        let     l_msg        =  null
        let     w_erro_P10   =  null

   open window w_cts14m10 at 4,2 with form "cts14m11"

   let ws_vistoria =  k_cts14m10.sinvstnum using "######",
                 "-", k_cts14m10.sinvstano

   display ws_vistoria  to  vistoria

   display g_documento.atdnum to atdnum attribute (reverse)

   let int_flag = false

   menu "HISTORICO"
      command key ("I")           "Implementa"
                                  "Implementa dados no historico"
        call cts14m11(k_cts14m10.*)
        clear form
        let ws_vistoria =  k_cts14m10.sinvstnum using "######",
                      "-", k_cts14m10.sinvstano
        display ws_vistoria  to  vistoria
        display g_documento.atdnum to atdnum attribute (reverse)
        next option "Encerra"

      command key ("C")           "Consulta"
                                  "Consulta historico ja' cadastrado"
        call cts14m12(k_cts14m10.sinvstnum, k_cts14m10.sinvstano)
        clear form
        let ws_vistoria =  k_cts14m10.sinvstnum using "######",
                      "-", k_cts14m10.sinvstano
        display ws_vistoria  to  vistoria
        display g_documento.atdnum to atdnum attribute (reverse)
        next option "Encerra"

      command key (interrupt,E)   "Encerra"    "Retorna ao menu anterior"
        if g_documento.acao is not null then
           if g_documento.acao = "INC"  then
              error " Motivo do retorno deve ser informado no historico !!"
              next option "Implementa"
           else
              error " Obrigatorio registrar algo no historico!"
              next option "Implementa"
           end if
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
                    error l_msg sleep 3
                    rollback work
                 end if
              end for

              ---> Danos Eletricos
              if g_documento.c24astcod = 'V12' then
                 let w_erro_P10 = cts14m10_relaciona_v12()
              end if

           end if

           exit menu
        end if
   end menu

   let int_flag = false

   close window w_cts14m10

end function # cts14m10

 ---> Danos Eletricos
#--------------------------------
function cts14m10_relaciona_v12()
#--------------------------------

 define l_P10_lignum   like datmligacao.lignum
       ,l_erro         smallint   ---> Decreto - 6523
       ,l_msg          char(50)   ---> Decreto - 6523
       ,l_count        smallint

 let l_erro       =  null
 let l_msg        =  null
 let l_P10_lignum = null
 let l_count      = null

 whenever error continue

 select count(*)
   into l_count
   from datmsrvre   a
       ,datmligacao b
  where a.sinvstnum = g_documento.sinvstnum
    and a.sinvstano = g_documento.sinvstano
    and b.atdsrvnum = a.atdsrvnum
    and b.atdsrvano = a.atdsrvano

 whenever error stop

 if l_count > 0 then
    declare c_cts14m10_001 cursor with hold for
    select b.lignum
     from datmsrvre   a
         ,datmligacao b
    where a.sinvstnum = g_documento.sinvstnum
      and a.sinvstano = g_documento.sinvstano
      and b.atdsrvnum = a.atdsrvnum
      and b.atdsrvano = a.atdsrvano
      and b.lignum   <> g_documento.lignum

    begin work
    foreach c_cts14m10_001 into l_P10_lignum

       let l_erro       =  null
       let l_msg        =  null

       call ctd25g00_insere_atendimento(g_documento.atdnum
                                       ,l_P10_lignum)
                              returning l_erro
                                       ,l_msg
       if l_erro <> 0 then
          if l_erro <> -268 and l_erro <> -239 then
             rollback work
             error "Erro na geracao do Relacto. Ligacao X Atendimento para o(s) assunto(s) de P10." ,l_erro
             return 1
          end if
       end if

    end foreach

    let l_P10_lignum = null

    declare c_cts14m10_002 cursor with hold for
    select a.lignum
      from datrligsinvst a
     where a.sinvstnum = g_documento.sinvstnum
       and a.sinvstano = g_documento.sinvstano

    foreach c_cts14m10_002 into l_P10_lignum

       let l_erro       =  null
       let l_msg        =  null

       call ctd25g00_insere_atendimento(g_documento.atdnum
                                       ,l_P10_lignum)
                              returning l_erro
                                       ,l_msg
       if l_erro <> 0 then
          if l_erro <> -268 and l_erro <> -239 then
             rollback work
             error "Erro na geracao do Relacto. Ligacao X Atendimento para o assunto de V12." ,l_erro
             return 1
          end if
       end if

    end foreach

    commit work

 end if

 return 0

end function
