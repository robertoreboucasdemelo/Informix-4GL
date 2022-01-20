#############################################################################
# Nome do Modulo: CTS04G00                                            Pedro #
#                                                                   Marcelo #
# Chamada para Laudos de Servico                                   Abr/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/10/1998  PSI 6895-0   Gilberto     Alterar a selecao do laudo a ser    #
#                                       chamado, substituindo a faixa de    #
#                                       numeracao pelo tipo de servico.     #
#---------------------------------------------------------------------------#
# 15/04/1999  PSI 7547-7   Gilberto     Incluir a chamada para laudos de    #
#                                       assistencia passageiros hospedagem. #
#---------------------------------------------------------------------------#
# 11/02/2000               Gilberto     Bloquear os laudos de servico para  #
#                                       evitar acionamentos simultaneos.    #
#---------------------------------------------------------------------------#
# 27/04/2000  PSI-9125-0   Akio         Adaptacao do modulo cts06m00 para   #
#                                       chamdas externas                    #
#---------------------------------------------------------------------------#
# 20/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 02/05/2001  PSI 13042-7  Ruiz         Chamar laudos Carglass ou Abravauto #
#---------------------------------------------------------------------------#
# 26/08/2002  PSI 14179-8  Ruiz         chamar laudo sinistro transportes.  #
#---------------------------------------------------------------------------#
# 16/05/2003  OSF 19445    Leandro      Registrar justificativa ao abandonar#
#---------------------------------------------------------------------------#
# 21/11/2006  psi 205206   Ruiz         chamar laudo da Azul.               #
#---------------------------------------------------------------------------#
# 25/06/2010  PSI 257664   Danilo        Armazena data e hora do inicio     #
#                          F0111099      de registro de atendimento.        #
#                                        (Central de Operações) e no final  #
#                                        de tudo chama tela de registro     #
#                                        de atendimento                     #
#---------------------------------------------------------------------------#
# 03/11/2010  PSI 000762   Carla         Tratamento para direcionamento de  #
#                          Rampazzo      Help Desk Casa                     #
#---------------------------------------------------------------------------#
# 15/05/2012 Alberto   PSI-2012-22101  SAPS Implementado ciaempcod para efe-#
#                                      tuar a chamada ao Laudo correto.     #
#############################################################################


globals  "/homedsa/projetos/geral/globals/glct.4gl"

define w_cts04g00_privez dec(1,0)

#-----------------------------------------------------------------------------
 function cts04g00_prepare()
#-----------------------------------------------------------------------------

 define ws       record
    sql          char (400)
 end record

 initialize  ws.*  to  null

 let ws.sql = "update datmservico    ",
              "   set c24opemat =  ? ",
              "   ,c24opeempcod =   ? ",
              " where atdsrvnum =  ? ",
              "   and atdsrvano =  ? ",
              "   and atdfnlflg in ('N', 'A') "
 prepare p_cts04g00_001 from ws.sql

 let ws.sql = "select c24opemat, atdsrvorg,",
              "       atdfnlflg,c24opeempcod ",
              "  from datmservico       ",
              " where atdsrvnum = ?     ",
              "   and atdsrvano = ?     ",
              "   for update            "
 prepare p_cts04g00_002 from ws.sql
 declare c_cts04g00_001 cursor with hold for p_cts04g00_002

 let ws.sql = "select funnom      ",
              "  from isskfunc    ",
              "  where empcod = ? ",
              "    and funmat = ? "
 prepare p_cts04g00_003 from ws.sql
 declare c_cts04g00_002 cursor for p_cts04g00_003

 let ws.sql = "select srvacsblqhordat   ",
              "  from datmservico                 ",
              " where atdsrvnum = ?               ",
              "   and atdsrvano = ?               "
 prepare p_cts04g00_004 from ws.sql
 declare c_cts04g00_003 cursor for p_cts04g00_004


end function  ###  cts04g00_prepare

#-----------------------------------------------------------------------------
 function cts04g00(param)
#-----------------------------------------------------------------------------

 define param    record
    prgorg       char (08)   ###  Programa de origem
 end record

 define ws          record
    atdfnlflg       like datmservico.atdfnlflg,
    c24opemat       like datmservico.c24opemat,
    c24openom       like isskfunc.funnom,
    atdsrvorg       like datmservico.atdsrvorg,
    ciaempcod       like datmservico.ciaempcod,
    ligcvntip       like datmligacao.ligcvntip,
    c24astcod       like datmligacao.c24astcod,
    lignum          like datmligacao.lignum   ,
    c24opeempcod    like datmservico.c24opeempcod,
    srvacsblqhordat like datmservico.srvacsblqhordat
 end record

 define  l_documento record
    ramcod         like gtakram.ramcod,
    succod         like abamdoc.succod,
    aplnumdig      like abamdoc.aplnumdig,
    itmnumdig      like abbmitem.itmnumdig,
    prporg         like rsdmdocto.prporg,
    prpnumdig      like rsdmdocto.prpnumdig
 end record

 define ws_acaoorigem        char (03) #PSI 257664

 define lr_retorno       record
          resultado        smallint
         ,mensagem         char(60)
         ,empcod           like datmsrvacp.empcod
         ,funmat           like datmsrvacp.funmat
         ,atdetpcod        like datmsrvacp.atdetpcod
   end record

 define l_qtdtempobloqueio interval hour to second
 define l_tempoaux         char(10)

 initialize ws.*  to null
 initialize lr_retorno.*  to null
 let l_qtdtempobloqueio = null
 let l_tempoaux = null


 if g_documento.atdsrvnum is null  or
    g_documento.atdsrvano is null  then
    error " Servico ", g_documento.atdsrvnum using "&&&&&&&", "-",
                       g_documento.atdsrvano using "&&",
          " nao informado. AVISE A INFORMATICA!"
    return false
 end if

 call cts20g01_ciaempcod_docto("",g_documento.atdsrvnum,g_documento.atdsrvano)
           returning ws.ciaempcod
#let g_documento.ciaempcod = ws.ciaempcod

  if ws.ciaempcod = 84 then
     call cts20g00_servico(g_documento.atdsrvnum,
                           g_documento.atdsrvano)
          returning ws.lignum

     call cts20g01_docto(ws.lignum)
          returning g_documento.succod,
                    g_documento.ramcod,
                    g_documento.aplnumdig,
                    g_documento.itmnumdig,
                    g_documento.edsnumref,
                    g_documento.prporg,
                    g_documento.prpnumdig,
                    g_documento.fcapacorg,
                    g_documento.fcapacnum ,
                    g_documento.itaciacod
 end if

 begin work

 whenever error continue
    open  c_cts04g00_001 using g_documento.atdsrvnum,
                              g_documento.atdsrvano
    if status <> 0 then
       call cts04g00_prepare()
       open  c_cts04g00_001 using g_documento.atdsrvnum,
                                 g_documento.atdsrvano
    end if
 whenever error stop

 fetch c_cts04g00_001 into  ws.c24opemat,
                           ws.atdsrvorg,
                           ws.atdfnlflg,
                           ws.c24opeempcod

 if sqlca.sqlcode = notfound  then
    error " Servico ", g_documento.atdsrvnum using "&&&&&&&", "-",
                       g_documento.atdsrvano using "&&",
          " nao encontrado. AVISE A INFORMATICA!"
    rollback work
    return false
 end if

 close c_cts04g00_001

 #Evolutiva Tempo que operador permanece no laudo
 if ws.c24opemat is not null then
	 whenever error continue
	    open  c_cts04g00_003 using g_documento.atdsrvnum,
	                              g_documento.atdsrvano

	    fetch c_cts04g00_003 into ws.srvacsblqhordat

	    if sqlca.sqlcode = notfound  then
	       let l_qtdtempobloqueio = null
	    else
	        let l_qtdtempobloqueio = current - ws.srvacsblqhordat

	        let l_tempoaux =  l_qtdtempobloqueio
	        let l_tempoaux = trim(l_tempoaux)

	        if length(l_tempoaux) < 8 then
	            let l_tempoaux = "0", l_tempoaux
	        end if

	    end if

	    close c_cts04g00_003
	 whenever error stop
 end if

 ---> Danos Eletricos
 if param.prgorg = 'cts21m03'  then
    let g_documento.acao = "CON"
 end if

 if ws.atdfnlflg = "S"   then
    rollback work
    if param.prgorg = 'cts00m00'  then
       if ws.c24opemat is null then   ###ligia
          let ws.c24openom = 'PROCESSO AUTOMATICO'
       else
          open  c_cts04g00_002 using ws.c24opeempcod,ws.c24opemat
          fetch c_cts04g00_002 into  ws.c24openom
          close c_cts04g00_002
          let ws.c24openom = upshift(ws.c24openom)
       end if
       if l_qtdtempobloqueio is null then
           error " Servico sendo acionado/implementado por: ", ws.c24openom clipped
       else
           error " Servico sendo acionado/implementado por: ", ws.c24openom clipped, " há ", l_tempoaux
       end if
       return false
    else
       if param.prgorg = 'cts00m06' and
          ws.atdsrvorg = 18         then
          let g_documento.acao = "ALT"   ## Funeral
       end if
    end if
 else
    if param.prgorg = 'cts00m06' or
       param.prgorg = 'cts00m00' and
       ws.atdsrvorg = 18         then
       let g_documento.acao = "ALT" ## Funeral
    end if
    if ws.c24opemat is not null  and ws.c24opemat <> 999999 then
       rollback work

       #if ws.c24opemat = 999999 then   ###ligia
       #   let ws.c24openom = 'PROCESSO AUTOMATICO'
       #else

          open  c_cts04g00_002 using ws.c24opeempcod,ws.c24opemat
          fetch c_cts04g00_002 into  ws.c24openom
          close c_cts04g00_002
          let ws.c24openom = upshift(ws.c24openom)

       #end if
       if l_qtdtempobloqueio is null then
           error " Servico sendo acionado/implementado por: ", ws.c24openom clipped
       else
           error " Servico sendo acionado/implementado por: ", ws.c24openom clipped, " há ", l_tempoaux
       end if
       return false

    else
       #----------------------------------------------------------------
       # Bloqueia servico com matricula do operador
       #----------------------------------------------------------------
       whenever error continue

       execute p_cts04g00_001 using g_issk.funmat        ,
                                     g_issk.empcod,
                                     g_documento.atdsrvnum,
                                     g_documento.atdsrvano

       whenever error stop

       #----------------------------------------------------------------
       # Se houver duas tentativas de 'update' ao mesmo tempo...
       #----------------------------------------------------------------
       if sqlca.sqlcode = 0  then
          commit work
          call cts00g07_apos_servbloqueia(g_documento.atdsrvnum,g_documento.atdsrvano)
       else
          if sqlca.sqlcode = -243  or
             sqlca.sqlcode = -245  or
             sqlca.sqlcode = -246  then
             error " Nao foi possivel consultar, tente novamente!"
          end if
          rollback work
          return false
       end if
    end if
 end if

 ## CT 308102
 ##let l_documento.ramcod    =  g_documento.ramcod
 ##let l_documento.succod    =  g_documento.succod
 ##let l_documento.aplnumdig =  g_documento.aplnumdig
 ##let l_documento.itmnumdig =  g_documento.itmnumdig
 ##let l_documento.prporg    =  g_documento.prporg
 ##let l_documento.prpnumdig =  g_documento.prpnumdig

#display "* cts04g00 * "
#display "g_documento.atdsrvnum = ",g_documento.atdsrvnum
#display "g_documento.atdsrvano = ",g_documento.atdsrvano
#display "ws.ciaempcod          = ",ws.ciaempcod
#display "ws.c24opemat          = ",ws.c24opemat
#display "ws.atdsrvorg          = ",ws.atdsrvorg
#display "ws.atdfnlflg          = ",ws.atdfnlflg

 if ws.ciaempcod = 35 then  # Porto Socorro empresa Azul
    call cts20g00_servico(g_documento.atdsrvnum,
                          g_documento.atdsrvano)
         returning ws.lignum
    select ligcvntip,
           c24astcod
      into ws.ligcvntip,
           ws.c24astcod
      from datmligacao
     where lignum = ws.lignum
 end if

 #-------------------------------------------------------------------
 #Criado por Danilo Sgrott F0111099 - Armazena data e hora do inicio
 #de atendimento da central de operações PSI-257664
 #-------------------------------------------------------------------
  let g_dadosregatendctop.dtinicial =  today
  let g_dadosregatendctop.hrinicial =  current hour to second

  let ws_acaoorigem = g_documento.acao

 case ws.atdsrvorg
    when  1 ### Porto Socorr
            if ws.ciaempcod = 35 then  # Porto Socorro empresa Azul
               call cts02m07(g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             ws.ligcvntip,
                             "", # g_documento.succod,
                             "", # g_documento.ramcod,
                             "", # g_documento.aplnumdig,
                             "", # g_documento.itmnumdig,
                             "", # g_documento.acao,
                             "", # g_documento.prporg,
                             "", # g_documento.prpnumdig,
                             ws.c24astcod, # g_documento.c24astcod,
                             "", # g_documento.solnom,
                             "", # g_documento.atdsrvorg,
                             "", # g_documento.edsnumref,
                             "", # g_documento.fcapacorg,
                             "", # g_documento.fcapacnum,
                             "", # g_documento.lignum,
                             "", # g_documento.soltip,
                             "", # g_documento.c24soltipcod,
                             "") # g_documento.lclocodesres)
            else
               if ws.ciaempcod = 84 then
                  call cts60m00()
               else
                 if ws.ciaempcod = 43 then
                    call cts70m00()
                 else
                    call cts03m00()     ###  Porto Socorro
                 end if
               end if
            end if
            call cts04g00_historico()

    when  2 ###  Assistencia a Passageiros Transportes
            if ws.ciaempcod = 35 then
               call cts11m10(g_documento.succod,
                             g_documento.ramcod,
                             g_documento.aplnumdig,
                             g_documento.itmnumdig,
                             g_documento.edsnumref,
                             g_documento.prporg,
                             g_documento.prpnumdig,
                             ws.ligcvntip )  #g_documento.ligcvntip)
            else
                if ws.ciaempcod = 84 then
                   if g_documento.ramcod = 14 then
                      call cts66m00()
                   else
                      call cts62m00()
                end if
                else
                   if ws.ciaempcod = 43 then
                       call cts72m00()
                   else
                       call cts11m00()
                   end if
                end if
            end if
            call cts04g00_historico()

    when  3 ###  Assistencia a Passageiros Hospedagem
            if ws.ciaempcod = 35 then
               call cts22m02(g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             ws.ligcvntip         , #g_documento.ligcvntip,
                             "", # g_documento.succod,
                             "", # g_documento.ramcod,
                             "", # g_documento.aplnumdig,
                             "", # g_documento.itmnumdig,
                             "", # g_documento.acao,
                             "", # g_documento.prporg,
                             "", # g_documento.prpnumdig,
                             ws.c24astcod         , #g_documento.c24astcod,
                             "", # g_documento.solnom,
                             "", # g_documento.atdsrvorg,
                             "", # g_documento.edsnumref,
                             "", # g_documento.fcapacorg,
                             "", # g_documento.fcapacnum,
                             "", # g_documento.lignum,
                             "", # g_documento.soltip,
                             "", # g_documento.c24soltipcod,
                             "") # g_documento.lclocodesres)
            else
               if ws.ciaempcod = 84 then
                  call cts63m00()
               else
                  if ws.ciaempcod = 43 then
                     call cts73m00()
                  else
                     call cts22m00()     ###  Assistencia a Passageiros Hospedagem
                  end if
               end if
            end if
            call cts04g00_historico()

    when  4 ### Remocao Sinistro
            if ws.ciaempcod = 35 then  # Porto Socorro empresa Azul
               call cts02m07(g_documento.atdsrvnum,
                             g_documento.atdsrvano,
                             ws.ligcvntip,
                             "", # g_documento.succod,
                             "", # g_documento.ramcod,
                             "", # g_documento.aplnumdig,
                             "", # g_documento.itmnumdig,
                             "", # g_documento.acao,
                             "", # g_documento.prporg,
                             "", # g_documento.prpnumdig,
                             ws.c24astcod, # g_documento.c24astcod,
                             "", # g_documento.solnom,
                             "", # g_documento.atdsrvorg,
                             "", # g_documento.edsnumref,
                             "", # g_documento.fcapacorg,
                             "", # g_documento.fcapacnum,
                             "", # g_documento.lignum,
                             "", # g_documento.soltip,
                             "", # g_documento.c24soltipcod,
                             "") # g_documento.lclocodesres)
            else
                if ws.ciaempcod  = 84 then #itau
                   call cts60m00()   ###  Remocao Sinistro
                else
                   if ws.ciaempcod = 43 then
                      call cts70m00()
                   else
                      call cts02m00()   ###  Remocao Sinistro
                   end if
                end if
            end if
            call cts04g00_historico()

    when  5   call cts12m00()     ###  R.P.T.
              call cts04g00_historico()

    when  6
              if ws.ciaempcod = 43 then
                 call cts70m00()
              else
                 call cts03m00()     ###  D.A.F.
              end if
              call cts04g00_historico()

    when  7   call cts09m00()     ###  Replace
              call cts04g00_historico()

    when  8 ###  Reserva Carro Extra

            initialize lr_retorno.* to null
            call ctd07g05_ult_etp (1,g_documento.atdsrvnum,
                                     g_documento.atdsrvano)
                 returning lr_retorno.*

            if (g_documento.acao = "ALT" or g_documento.acao = "CAN") and
                lr_retorno.atdetpcod = 5 then
                error 'Serviço está CANCELADO' sleep 2
            else

               if ws.ciaempcod = 35 then  # Azul Seguros
                  call cts15m15(g_documento.atdsrvnum,
                                g_documento.atdsrvano,
                                ws.ligcvntip,
                                "", # g_documento.succod,
                                "", # g_documento.ramcod,
                                "", # g_documento.aplnumdig,
                                "", # g_documento.itmnumdig,
                                "", # g_documento.acao,
                                "", # g_documento.prporg,
                                "", # g_documento.prpnumdig,
                                ws.c24astcod, # g_documento.c24astcod,
                                "", # g_documento.solnom,
                                "", # g_documento.atdsrvorg,
                                "", # g_documento.edsnumref,
                                "", # g_documento.fcapacorg,
                                "", # g_documento.fcapacnum,
                                "", # g_documento.lignum,
                                "", # g_documento.soltip,
                                "", # g_documento.c24soltipcod,
                                "") # g_documento.lclocodesres)
                else
                 if ws.ciaempcod = 84 then
                    call cts64m00()
                 else
                    if ws.ciaempcod = 43 then
                       call cts74m00()
                    else
                    call cts15m00()  ### Porto Seguro
                    end if
                 end if
                end if
                call cts04g00_historico()
             end if

    when  9

             call cts20g00_servico(g_documento.atdsrvnum
                                  ,g_documento.atdsrvano)
                  returning ws.lignum

             select c24astcod
               into ws.c24astcod
               from datmligacao
              where lignum = ws.lignum

             if g_documento.c24astcod = 'PE3' then
                # Verifica item do PE1 consultado
                call cts04g00_dados_servico()
                call cts17m00()     ###  Socorro R.E.
             else

                ---> Porto S66-HDK-Telefonico / S78-HDK Cortesia-Telefonico 
                ---> Itau  R66-HDK-Telefonico / R78-HDK Cortesia-Telefonico  
                if ws.c24astcod = "S66" or
                   ws.c24astcod = "S78" or
                   ws.c24astcod = "R66" or
                   ws.c24astcod = "R78" then 
              

                   call cts04g00_historico()
                else
                   if ws.ciaempcod = 84 then
		                 if g_documento.ramcod = 31 then
                                    call cts61m00()
		                 else
                                    call cts65m00()
		                 end if

                   else
                      if ws.ciaempcod = 43 then
                         call cts71m00()
                      else
                         call cts17m00()     ###  Socorro R.E.
                      end if
                   end if
                   call cts04g00_historico()
                end if
             end if

    when 10   call cts04g00_vp()  ###  Vistoria Previa
              call cts04g00_historico()

    when 11   call cts05m00()     ###  Furto/Roubo Total
              call cts04g00_historico()
    when 12                       ###  Apoio
              call cts04g00_historico()

    when 13   call cts04m00()     ###  Sinistro R.E.
              call cts04g00_historico()

    when 14   call cts19m06()     ###  Carglass/Abravauto
              call cts04g00_historico()

    when 15   call cts26m00()     ###  JIT
              call cts04g00_historico()

    when 16   call cts28m00()     ###  Sinistro Transportes
              call cts04g00_historico()

    when 17   call cts09m00()     ###  Replace Congenere
              call cts04g00_historico()

   when  18   let g_documento.atdsrvorg = ws.atdsrvorg
              call cts31m00()     ###  SAF - Servico Apoio Familiar
              call cts04g00_historico()
   otherwise error " Tipo de servico (", ws.atdsrvorg, ") nao possui acao definida! AVISE A INFORMATICA!"
 end case

## CT 308102
##   let g_documento.ramcod    =  l_documento.ramcod
##   let g_documento.succod    =  l_documento.succod
##   let g_documento.aplnumdig =  l_documento.aplnumdig
##   let g_documento.itmnumdig =  l_documento.itmnumdig
##   let g_documento.prporg    =  l_documento.prporg
##   let g_documento.prpnumdig =  l_documento.prpnumdig



#----------------------------------------------------------------
# Desbloqueia servico
#----------------------------------------------------------------
 whenever error continue

 initialize ws.c24opemat to null
 initialize ws.c24opeempcod to null

 execute p_cts04g00_001 using ws.c24opemat         ,
                               ws.c24opeempcod,
                               g_documento.atdsrvnum,
                               g_documento.atdsrvano

 whenever error stop

 call cts00g07_apos_servdesbloqueia(g_documento.atdsrvnum,g_documento.atdsrvano)

 #----------------------------------------------------------------------------
 #Criado por Danilo Sgrott F0111099 -  Chama tela de registro de atendimento
 #PSI-257664
 #----------------------------------------------------------------------------
 if ws_acaoorigem is null or
    ws_acaoorigem <> "RET" then
    call cta00m09(g_documento.atdsrvnum
                 ,g_documento.atdsrvano)
 end if

 return true

end function  ###  cts04g00

#-----------------------------------------------------------------------------
 function cts04g00_vp()
#-----------------------------------------------------------------------------

 define ws       record
    vstnumdig    like datmvistoria.vstnumdig
 end record

 define salva    record
    atdsrvnum    like datmservico.atdsrvnum,
    atdsrvano    like datmservico.atdsrvano,
    atdetpcod    like datmsrvacp.atdetpcod
 end record

 initialize  ws.*  to  null
 initialize  salva.*  to  null

 initialize ws.*  to null

 select vstnumdig
   into ws.vstnumdig
   from datmvistoria
  where atdsrvnum = g_documento.atdsrvnum  and
        atdsrvano = g_documento.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Vistoria nao encontrada. AVISE A INFORMATICA!"
 else
    let salva.atdsrvnum = g_documento.atdsrvnum
    let salva.atdsrvano = g_documento.atdsrvano
    error " Selecione e tecle ENTER!"

    call cts06m00("N",ws.vstnumdig,"","")

    select atdetpcod
      into salva.atdetpcod
      from datmsrvacp
     where atdsrvnum = salva.atdsrvnum
       and atdsrvano = salva.atdsrvano
       and atdsrvseq = (select max(atdsrvseq)
                          from datmsrvacp
                         where atdsrvnum = salva.atdsrvnum
                           and atdsrvano = salva.atdsrvano)

     if salva.atdetpcod = 1  then
        let g_documento.atdsrvnum = salva.atdsrvnum
        let g_documento.atdsrvano = salva.atdsrvano
     end if

 end if

end function  ###  cts04g00_vp

#-----------------------------------------------------------------------------
 function cts04g00_historico()
#-----------------------------------------------------------------------------

define l_etapa  smallint,
       l_data   date,
       l_hora   datetime hour to minute

 if g_documento.atdsrvnum is not null  or
    g_documento.atdsrvnum <> ""        then
    call cts10g04_ultima_etapa( g_documento.atdsrvnum,
                                g_documento.atdsrvano )
    returning l_etapa


    # Alterado a pedido de Judite Esteves e Cesar Castro (CT 100919782 )
    #if l_etapa <> 3 and
    #   l_etapa <> 4 then
    # Colocando o devio para não chamar o historico caso o departamento seja
    # Porto Socorro a pedido de Luis Fernando Melo - Porto Socorro
    if g_issk.dptsgl <> 'psocor' then

       let g_documento.acao = "AAA"
       let l_data = today
       let l_hora = current hour to minute

       if g_rec_his <> true then
          call cts10n00( g_documento.atdsrvnum,
                         g_documento.atdsrvano,
                         g_issk.funmat,
                         l_data,
                         l_hora )
       else
           let g_rec_his = false
       end if
    end if

 end if

end function  ###  cts04g00_historico

function cts04g00_dados_servico()

 define lr_aux record
    succod          like datrligapol.succod,        # Codigo Sucursal
    ramcod          like datrligapol.ramcod,
    aplnumdig       like datrligapol.aplnumdig,     # Numero Apolice
    itmnumdig       like datrligapol.itmnumdig,     # Numero do Item
    edsnumref       like datrligapol.edsnumref,     # Numero do Endosso
    prporg          like datrligprp.prporg,         # Origem da Proposta
    prpnumdig       like datrligprp.prpnumdig,      # Numero da Proposta
    fcapacorg       like datrligpac.fcapacorg,      # Origem PAC
    fcapacnum       like datrligpac.fcapacnum,      # Numero PAC
    itaciacod       like datrligitaaplitm.itaciacod # Companhia Itau
 end record

 define l_lignum like datmligacao.lignum,
        l_confirma char(1)

 define lr_msg record
       linha1 char(40),
       linha2 char(40),
       linha3 char(40),
       linha4 char(40)
 end record

 define l_itmnumdig char(5)

 initialize lr_aux.* to null
 initialize lr_msg.* to null
 let l_lignum = null
 let l_itmnumdig = null


 let l_lignum = cts20g00_servico(g_documento.atdsrvnum, g_documento.atdsrvano)

 call cts20g01_docto(l_lignum)
      returning lr_aux.succod,
                lr_aux.ramcod,
                lr_aux.aplnumdig,
                lr_aux.itmnumdig,
                lr_aux.edsnumref,
                lr_aux.prporg,
                lr_aux.prpnumdig,
                lr_aux.fcapacorg,
                lr_aux.fcapacnum,
                lr_aux.itaciacod


  let l_itmnumdig = lr_aux.itmnumdig

  let lr_msg.linha1 = "LAUDO ABERTO NO ITEM ",l_itmnumdig clipped
  let lr_msg.linha2 = "O BENEFICIO PET TEM O LIMITE DE CONSULTA"
  let lr_msg.linha3 = " VETERINÁRIA POR VIGENCIA DA APOLICE "
  let lr_msg.linha4 = "INDEPENDENTE DA QUANTIDADE DE ITEM."


  if g_documento.itmnumdig <> lr_aux.itmnumdig then
     call cts08g01("A","N",lr_msg.linha1,
                          lr_msg.linha2,
                          lr_msg.linha3,
                          lr_msg.linha4)
         returning l_confirma
  end if

end function
