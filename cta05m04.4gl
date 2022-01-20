 ##############################################################################
 # Nome do Modulo: cta05m04                                         Gilberto  #
 #                                                                   Marcelo  #
 # Mostra todas as funcoes das reclamacoes                          Dez/1997  #
 ##############################################################################
 # Alteracoes:                                                                #
 #                                                                            #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
 #----------------------------------------------------------------------------#
 # 29/03/2000  PSI 10428-0  Wagner       Incluir func para consulta do histo -#
 #                                       rico do servico                      #
 #----------------------------------------------------------------------------#
 # 30/11/2000  PSI 11149-0  Ruiz         permitir ct24h gravar w02,w04,w06.   #
 #             PSI 11250-0  Ruiz         permitir w00 para proposta.          #
 #             PSI 12039-1  Ruiz         permitir gravar "X" qdo <> de ct24h  #
 #----------------------------------------------------------------------------#
 # 27/03/2001  PSI 12768-0  Wagner       Incluir envio do nr do servico para  #
 #                                       a chamada da funcao ctb12m03.        #
 #----------------------------------------------------------------------------#
 # 22/04/2003  Aguinaldo Cost PSI.168920 Resolucao 86                         #
 #----------------------------------------------------------------------------#
 # 22/09/06    Ligia Mattge   PSI 202720 Implementacao do cartao Saude        #
 #----------------------------------------------------------------------------#
 # 16/11/06    Ligia Mattge   PSI 205206 ciaempcod                            #
 #----------------------------------------------------------------------------#
 # 11/10/2010  Carla Rampazzo PSI 260606 Tratar Fluxo de Reclamacao p/PSS(107)#
 #----------------------------------------------------------------------------#
 # 14/02/2011  Carla Rampazzo PSI        Fluxo de Reclamacao p/ PortoSeg(518) #
 #----------------------------------------------------------------------------#
 ##############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cta05m04(param)
#-----------------------------------------------------------

 define param      record
    lignum         like datmligacao.lignum,
    histflg        smallint       #----->>   # 1-Hist.ligacao(datmlighist)
 end record                                  # 2-Hist.servico(datmsrvhist)

 define a_cta05m04 array[06] of record
    fundes         char(16),
    funcod         dec(2,0)
 end record

 define scr_aux    smallint
 define arr_aux    smallint


 if param.lignum   is null   then
    error " Numero de ligacao nao informado, AVISE INFORMATICA!"
    return
 end if

 open window cta05m04 at 11,59 with form "cta05m04"
                      attribute(form line 1, border)

 let int_flag = false
 initialize a_cta05m04     to null
 initialize g_documento.*  to null

 let a_cta05m04[01].fundes = "HISTORICO"
 let a_cta05m04[01].funcod = 01
 let a_cta05m04[02].fundes = "ESPELHO"
 let a_cta05m04[02].funcod = 02
 let a_cta05m04[03].fundes = "LIGACOES"
 let a_cta05m04[03].funcod = 03
 let a_cta05m04[04].fundes = "SERVICOS"
 let a_cta05m04[04].funcod = 04
 let a_cta05m04[05].fundes = "ETAPAS"
 let a_cta05m04[05].funcod = 05
 let arr_aux = 05
 if param.histflg = 1 then
    let a_cta05m04[06].fundes = "FAX"
    let a_cta05m04[06].funcod = 06
    let arr_aux = 06
 end if

 message "(F8)Seleciona"
 call set_count(arr_aux)

 display array a_cta05m04 to s_cta05m04.*

    on key (interrupt,control-c)
       initialize a_cta05m04   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       let scr_aux = scr_line()
       initialize g_documento.*  to null
       call cta05m04_chamada(param.lignum, param.histflg,
                             a_cta05m04[arr_aux].funcod)
       initialize g_documento.*  to null

 end display

 close window  cta05m04
 let int_flag = false
 initialize g_documento.*  to null

end function  #--  cta05m04


#-----------------------------------------------------------
 function cta05m04_chamada(param2)
#-----------------------------------------------------------

 define param2     record
    lignum         like datmligacao.lignum,
    histflg        smallint,
    funcod         dec(2,0)
 end record

 define ws         record
    atdsrvnum      like datmligacao.atdsrvnum,
    atdsrvano      like datmligacao.atdsrvano,
    ciaempcod      like datmligacao.ciaempcod,
    pula           char(01)
 end record


 #----------------------------------------------------------
 # Verifica documento relacionado com a reclamacao
 #----------------------------------------------------------
 call cts20g01_docto(param2.lignum)
      returning g_documento.succod,
                g_documento.ramcod,
                g_documento.aplnumdig,
                g_documento.itmnumdig,
                g_documento.edsnumref,
                g_documento.prporg,
                g_documento.prpnumdig,
                g_documento.fcapacorg,
                g_documento.fcapacnum,
                g_documento.itaciacod

 call cts20g09_docto(1,param2.lignum) returning g_documento.crtsaunum

 ---> Verifica se a Ligacao e de documento do PSS
 select max (psscntcod)
   into g_pss.psscntcod
   from datrcntlig
  where lignum = param2.lignum


 ---> Verifica se a Ligacao e de documento do PortoSeg
 select cgccpfnum
       ,cgcord
       ,cgccpfdig
   into g_documento.cgccpfnum
       ,g_documento.cgcord
       ,g_documento.cgccpfdig
   from datrligcgccpf
  where lignum = param2.lignum


 #----------------------------------------------------------
 # Verificacao do servico relacionado com a ligacao
 #----------------------------------------------------------
 initialize ws.* to null
 select atdsrvnum, atdsrvano, ciaempcod
   into ws.atdsrvnum, ws.atdsrvano, g_documento.ciaempcod
   from datmligacao
  where lignum = param2.lignum


 #----------------------------------------------------------
 # Aciona telas para funcao selecionada
 #----------------------------------------------------------
 case param2.funcod
    when  01
          if param2.histflg = 1 then
             call cta03n00(param2.lignum, g_issk.funmat, today, current)
          else
             if ws.atdsrvnum is not null and
                ws.atdsrvano is not null then
                call cts10n00(ws.atdsrvnum, ws.atdsrvano,
                              g_issk.funmat, today, current)
             else
                error " Nao existe servico relacionado a esta ligacao !"
             end if
          end if

    when  02

          call cta01m12_espelho(g_documento.ramcod
                               ,g_documento.succod
                               ,g_documento.aplnumdig
                               ,g_documento.itmnumdig
                               ,g_documento.prporg
                               ,g_documento.prpnumdig
                               ,g_documento.fcapacorg
                               ,g_documento.fcapacnum
                               ,g_documento.pcacarnum
                               ,g_documento.pcaprpitm
                               ,g_ppt.cmnnumdig
                               ,g_documento.crtsaunum
                               ,g_documento.bnfnum
                               ,g_documento.ciaempcod) #psi 205206

    when  03
          if (g_documento.succod    is not null   and
              g_documento.ramcod    is not null   and
              g_documento.aplnumdig is not null       ) or
             (g_documento.cgccpfnum is not null   and
              g_documento.cgccpfdig is not null       ) or
             (g_documento.prporg    is not null   and
              g_documento.prpnumdig is not null       ) or
             (g_documento.fcapacorg is not null   and
              g_documento.fcapacnum is not null       ) or
              g_documento.crtsaunum is not null         or 
              g_pss.psscntcod       is not null         then

              call ctp01m01(g_documento.succod   , g_documento.ramcod   ,
                            g_documento.aplnumdig, g_documento.itmnumdig,
                            g_documento.prporg   , g_documento.prpnumdig,
                            g_documento.fcapacorg, g_documento.fcapacnum,
                            g_documento.crtsaunum) ### PSI202720
          else
             if param2.histflg = 1 then
                error " Ligacao sem documento informado!"
             else
                error " Servico sem documento informado!"
             end if
             return
          end if

    when  04
          select atdsrvnum, atdsrvano
            into ws.atdsrvnum, ws.atdsrvano
            from datmreclam
           where lignum = param2.lignum

          call ctb12m03(ws.atdsrvnum, ws.atdsrvano)

    when  05
          if param2.histflg = 1 then
             call cta05m02(param2.lignum)
          else
             if ws.atdsrvnum is not null and
                ws.atdsrvano is not null then
                call cts00m22(ws.atdsrvnum, ws.atdsrvano)
             else
                error " Nao existe servico relacionado a esta ligacao !"
             end if
          end if

    when  06
          if param2.histflg = 1 then
             call cta05m03(param2.lignum, g_documento.ciaempcod)
          end if

 end case

 let int_flag = false

end function  #--  cta05m04_chamada


