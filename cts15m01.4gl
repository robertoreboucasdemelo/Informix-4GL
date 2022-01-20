#---------------------------------------------------------------------------#
# Nome do Modulo: CTS15M01                                         Pedro    #
#                                                                  Marcelo  #
# Conclusao da reserva apos confirmacao e retorno ao segurado      Ago/1995 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 10/07/2000  PSI 10865-0  Ruiz         Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 16/08/2000  PSI 11243-7  Wagner       Tamanho lcvextcod de char(050 p/(07)#
# 03/02/2004  OSF 31682    Mariana,Fsw  Incluir funcao cta11m00 p/ etapa 38 #
#                                       (recusado)                          #
#---------------------------------------------------------------------------#
# 16/03/2004  OSF 33367    Teresinha S. Inclusao do motivo 6                #
# --------------------------------------------------------------------------#
#                                                                           #
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# 01/09/2004 Robson, Meta    PSI186406  Alterada chamada a cts10g04_max_seq #
#---------------------------------------------------------------------------#
# 26/10/2004 Katiucia        CT 255556  Incluir retorno/problm. c/transacao #
#---------------------------------------------------------------------------#
# 21/12/2004 Carlos, Meta    PSI187887  Acertar flag para sinistro de acordo#
#                                       com o motivo.                       #
#############################################################################
# 08/01/2005 Daniel, Meta    PSI187887  Foi retirado o motivo 6             #
#                                       Chamar ctx01g06_excluir()           #
#                                                                           #
#---------------------------------------------------------------------------#
# 02/03/2006 Priscila        Zeladoria  Buscar data e hora do banco de dados#
#---------------------------------------------------------------------------#
# 16/12/2006 Ruiz            psi205206  Incluir motivo 3(beneficio) p Azul  #
#---------------------------------------------------------------------------#
# 01/12/2011 Celso Yamahaki  CT11-23431 Alterar status da reserva Localiza  #
#                                       Após acionamento                    #
#############################################################################

globals  '/homedsa/projetos/geral/globals/glct.4gl' #PSI186406 -Robson

#--------------------------------------------------------------------
 function cts15m01(param)
#--------------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum ,
    atdsrvano         like datmservico.atdsrvano ,
    lcvcod            like datmavisrent.lcvcod   ,
    aviestcod         like datmavisrent.aviestcod,
    avialgmtv         like datmavisrent.avialgmtv
 end record

 define d_cts15m01    record
    cnldat            like datmservico.cnldat         ,
    atdfnlhor         like datmservico.atdfnlhor      ,
    c24openom         like isskfunc.funnom            ,
    atdetpcod         like datmsrvacp.atdetpcod       ,
    atdetpdes         like datketapa.atdetpdes        ,
    lcvextcod         like datkavislocal.lcvextcod    ,
    aviestnom         like datkavislocal.aviestnom    ,
    aviestcod         like datkavislocal.aviestcod    ,
    endlgd            like datkavislocal.endlgd       ,
    endbrr            like datkavislocal.endbrr       ,
    endcid            like datkavislocal.endcid       ,
    endufd            like datkavislocal.endufd       ,
    dddcod            like datkavislocal.dddcod       ,
    teltxt            like datkavislocal.teltxt       ,
    horsegsexinc      like datkavislocal.horsegsexinc ,
    horsegsexfnl      like datkavislocal.horsegsexfnl ,
    horsabinc         like datkavislocal.horsabinc    ,
    horsabfnl         like datkavislocal.horsabfnl    ,
    hordominc         like datkavislocal.hordominc    ,
    hordomfnl         like datkavislocal.hordomfnl
 end record

 define ws            record
    datatu            date,
    horatu            datetime hour to minute,
    atdfnlflg         like datmservico.atdfnlflg ,
    atdsrvseq         like datmsrvacp.atdsrvseq  ,
    c24opemat         like datmservico.c24opemat ,
    nfspgtdat         like dblmpagto.nfspgtdat   ,
    atdetptipcod      like datketapa.atdetptipcod,
    atdetppndflg      like datketapa.atdetppndflg,
    prporg            like datmavisrent.prporg   ,
    prpnumdig         like datmavisrent.prpnumdig,
    avioccdat         like datmavisrent.avioccdat,
    sqlcode           integer                    ,
    tabname           char (30),
    etpmtvcod         like datksrvintmtv.etpmtvcod,
    etpmtvdes         like datksrvintmtv.etpmtvdes
 end record

 define salva         record
    cnldat            like datmservico.cnldat,
    atdetpcod         like datmsrvacp.atdetpcod,
    atdetptipcod      like datketapa.atdetptipcod
 end record

 define l_atdsrvorg    like datmservico.atdsrvorg
 define l_srvrcumtvcod like datksrvrcumtv.srvrcumtvcod
 define l_seq          like datmsrvacp.atdsrvseq
 define l_ciaempcod    like datmservico.ciaempcod

 define prompt_key    char (01)
 define w_retorno     smallint
 define l_nullo       smallint #PSI186406 -Robson
       ,l_resultado   smallint #PSI186406 -Robson
       ,l_mensagem    char(60) #PSI186406 -Robson
       ,l_flag        char(01)
       ,l_etapa       like datmsrvint.atdetpcod


 define l_data         date,
        l_hora2        datetime hour to minute,
        l_rsvsttcod    like datmrsvvcl.rsvsttcod

        let     prompt_key  =  null
        let     w_retorno  =  null
        let     l_etapa = null

        initialize  d_cts15m01.*  to  null

        initialize  ws.*  to  null

        initialize  salva.*  to  null

 initialize d_cts15m01.*  to null
 initialize ws.*          to null

 let l_nullo     = null #PSI186406 -Robson
 let l_resultado = null #PSI186406 -Robson
 let l_mensagem  = null #PSI186406 -Robson
 let l_ciaempcod = null
 let l_rsvsttcod = null

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 let ws.datatu = l_data
 let ws.horatu = l_hora2
 let l_flag = null

 let int_flag  =  false

 if param.atdsrvnum  is null  or
    param.atdsrvano  is null  then
    error " Servico nao informado. AVISE A INFORMATICA!"
    return
 end if

#------------------------------#
# Verifica Origem de Servico
#------------------------------#

 select atdsrvorg, ciaempcod
   into l_atdsrvorg, l_ciaempcod
   from datmservico
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

#--------------------------------------------------------------------
# Verifica se servico ja' foi concluido
#--------------------------------------------------------------------

 select atdfnlflg, c24opemat,
        cnldat   , atdfnlhor
   into ws.atdfnlflg,
        ws.c24opemat,
        d_cts15m01.cnldat,
        d_cts15m01.atdfnlhor
   from datmservico
  where atdsrvnum  =  param.atdsrvnum    and
        atdsrvano  =  param.atdsrvano

 if sqlca.sqlcode = notfound   then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 if ws.c24opemat is not null  then
    let d_cts15m01.c24openom = "**NAO CADASTRADO**"

    select funnom
      into d_cts15m01.c24openom
      from isskfunc
     where empcod = 1
       and funmat = ws.c24opemat

    let d_cts15m01.c24openom = upshift(d_cts15m01.c24openom)
 end if

#--------------------------------------------------------------------
# Informacoes etapa
#--------------------------------------------------------------------
 initialize ws.atdsrvseq to null

 select max(atdsrvseq)
   into ws.atdsrvseq
   from datmsrvacp
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 select atdetpcod
   into d_cts15m01.atdetpcod
   from datmsrvacp
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and atdsrvseq = ws.atdsrvseq

 if sqlca.sqlcode = 0 then
    let d_cts15m01.atdetpdes = "NAO CADASTRADA"

    select atdetpdes,
           atdetptipcod,
           atdetppndflg
      into d_cts15m01.atdetpdes,
           ws.atdetptipcod,
           ws.atdetppndflg
      from datketapa
     where atdetpcod = d_cts15m01.atdetpcod

    if ws.atdetppndflg = "S"  then
       let ws.atdfnlflg = "N"
    else
       let ws.atdfnlflg = "S"
    end if
 end if

#--------------------------------------------------------------------
# Dados da loja para retirada
#--------------------------------------------------------------------

 select aviestcod,
        aviestnom,
        lcvextcod,
        endlgd,
        endbrr,
        endcid,
        endufd,
        dddcod,
        teltxt,
        horsegsexinc,
        horsegsexfnl,
        horsabinc,
        horsabfnl,
        hordominc,
        hordomfnl
   into d_cts15m01.aviestcod   ,
        d_cts15m01.aviestnom   ,
        d_cts15m01.lcvextcod   ,
        d_cts15m01.endlgd      ,
        d_cts15m01.endbrr      ,
        d_cts15m01.endcid      ,
        d_cts15m01.endufd      ,
        d_cts15m01.dddcod      ,
        d_cts15m01.teltxt      ,
        d_cts15m01.horsegsexinc,
        d_cts15m01.horsegsexfnl,
        d_cts15m01.horsabinc   ,
        d_cts15m01.horsabfnl   ,
        d_cts15m01.hordominc   ,
        d_cts15m01.hordomfnl
   from datkavislocal
  where lcvcod    = param.lcvcod     and
        aviestcod = param.aviestcod

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na localizacacao da loja para retirada. AVISE A INFORMATICA!"
    return
 end if

 let salva.cnldat       = d_cts15m01.cnldat
 let salva.atdetpcod    = d_cts15m01.atdetpcod
 let salva.atdetptipcod = ws.atdetptipcod

 open window cts15m01 at 11,09 with form "cts15m01"
                      attribute (form line 1, border)

 display "(F6) Etapas " at 09,02

 display by name d_cts15m01.*

 input by name d_cts15m01.atdetpcod  without defaults

   before field atdetpcod
      display by name d_cts15m01.atdetpcod attribute (reverse)

   after field atdetpcod
      display by name d_cts15m01.atdetpcod

      ## nao deixar alterar etapa do servico cancelado
      #if l_atdsrvorg = 8 and salva.atdetpcod = 5 then
      #   let d_cts15m01.atdetpcod = salva.atdetpcod
      #   display by name d_cts15m01.atdetpcod
      #   next field atdetpcod
      #end if

      select nfspgtdat
        into ws.nfspgtdat
        from dblmpagto
       where atdsrvnum = param.atdsrvnum  and
             atdsrvano = param.atdsrvano

      if sqlca.sqlcode = 0  then
         error " Servico nao deve ser alterado! Servico pago em ", ws.nfspgtdat, "!"
         let d_cts15m01.atdetpcod = salva.atdetpcod
         next field atdetpcod
      end if

      if d_cts15m01.atdetpcod is null   then
         error " Etapa deve ser informada!"
         call ctn26c00("R") returning d_cts15m01.atdetpcod
         next field atdetpcod
      else
         if d_cts15m01.atdetpcod = 2  then
            error " Etapa nao pode ser informada na conclusao!"
            next field atdetpcod
         end if

         if d_cts15m01.atdetpcod = 5  then
            let l_etapa = "3"
            call cts00m28() returning ws.etpmtvcod,  # pop_up motivos
                                      ws.etpmtvdes
         else
            let l_etapa = "0"
         end if

         select atdetpdes,
                atdetptipcod,
                atdetppndflg
           into d_cts15m01.atdetpdes,
                ws.atdetptipcod,
                ws.atdetppndflg
           from datketapa
          where atdetpcod = d_cts15m01.atdetpcod
            and atdetpstt = "A"

         if sqlca.sqlcode = notfound  then
            error " Etapa nao cadastrada! Informe novamente."
            call ctn26c00("R") returning d_cts15m01.atdetpcod
            next field atdetpcod
         end if

         if ws.atdetppndflg = "S"  then
            let ws.atdfnlflg = "N"
         else
            let ws.atdfnlflg = "S"
         end if

         select atdetpcod
           from datrsrvetp
          where atdsrvorg =  8
            and atdetpcod = d_cts15m01.atdetpcod
            and atdsrvetpstt = "A"

         if sqlca.sqlcode = notfound  then
            error " Etapa nao pertence a este tipo de servico!"
            call ctn26c00(8) returning d_cts15m01.atdetpcod
            next field atdetpcod
         end if
      end if

      if d_cts15m01.atdetpcod = 38 then      #---> Recusado
         call cta11m00(l_atdsrvorg, param.atdsrvnum, param.atdsrvano
                      ,'','N') returning l_srvrcumtvcod
      end if
      whenever error continue
      if d_cts15m01.atdetpcod = 4  then

         select rsvsttcod
           into l_rsvsttcod
           from datmrsvvcl
          where atdsrvnum = param.atdsrvnum
            and atdsrvano = param.atdsrvano
            and rsvsttcod = 9
         display "sqlca.sqlcode: ", sqlca.sqlcode
         if sqlca.sqlcode = 0 then
           update datmrsvvcl
              set rsvsttcod = 2
            where atdsrvnum = param.atdsrvnum
              and atdsrvano = param.atdsrvano
         end if

      whenever error stop
      end if

      display by name d_cts15m01.atdetpdes


   on key (F6)
      call cts00m11(param.atdsrvnum, param.atdsrvano)

   on key (interrupt)
      exit input

 end input

 if not int_flag  then
    if ws.atdetptipcod = 1  then
       initialize d_cts15m01.cnldat  to null
    else
       if d_cts15m01.atdetpcod = salva.atdetpcod  then
          let d_cts15m01.cnldat = salva.cnldat
       else
          let d_cts15m01.cnldat = ws.datatu
       end if
    end if

    whenever error continue
    begin work

    #--------------------------------------------------------------------
    # Nao ha' alteracao de etapa ou alteracao por etapa do mesmo grupo
    #--------------------------------------------------------------------
       if ws.atdetptipcod  =  salva.atdetptipcod  then
          update datmservico
             set atdfnlflg = ws.atdfnlflg
           where atdsrvnum = param.atdsrvnum   and
                 atdsrvano = param.atdsrvano
       else
    #--------------------------------------------------------------------
    # Alteracao de etapa devido a acionamento
    #--------------------------------------------------------------------
          if salva.atdetptipcod < ws.atdetptipcod  then
             update datmservico
                set atdfnlhor = ws.horatu             ,
                    c24opemat = g_issk.funmat         ,
                    cnldat    = ws.datatu             ,
                    atdfnlflg = ws.atdfnlflg
              where atdsrvnum = param.atdsrvnum   and
                    atdsrvano = param.atdsrvano
          else
    #--------------------------------------------------------------------
    # Alteracao de etapa devido a re-liberacao (desconcluindo)
    #--------------------------------------------------------------------
             update datmservico
                set atdfnlhor = ""                  ,
                    c24opemat = ""                  ,
                    cnldat    = ""                  ,
                    atdfnlflg = ws.atdfnlflg
              where atdsrvnum = param.atdsrvnum   and
                    atdsrvano = param.atdsrvano
          end if
       end if

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na conclusao do servico. AVISE A INFORMATICA!"
          rollback work
          prompt "" for char prompt_key
          close window cts15m01
          return
       end if

       call cts00g07_apos_servbloqueia(param.atdsrvnum, param.atdsrvano)

      #--------------------------------------------------------------------
      # Grava nova etapa de acompanhamento, se etapa foi alterada
      #--------------------------------------------------------------------
       if salva.atdetpcod <> d_cts15m01.atdetpcod  then

          if g_documento.acao <> "CAN" or
             g_documento.acao is null  then # qdo vem pela tela radio.
             call cts10g04_insere_etapa(param.atdsrvnum,
                                        param.atdsrvano,
                                        d_cts15m01.atdetpcod,
                                        param.lcvcod,
                                        " ",
                                        " ",
                                        param.aviestcod)returning w_retorno
             if w_retorno <> 0  then
                error " Erro (", sqlca.sqlcode, ") na gravacao da etapa de acompanhamento. AVISE A INFORMATICA!"
                rollback work
                prompt "" for char prompt_key
                close window cts15m01
                return
             end if

          end if

          if d_cts15m01.atdetpcod = 38 and
             l_srvrcumtvcod is not null then
             #PSI186406 -Robson -Inicio
             call cts10g04_max_seq(param.atdsrvnum
                                  ,param.atdsrvano
                                  ,l_nullo)
                returning l_resultado
                         ,l_mensagem
                         ,l_seq
             if l_resultado <> 1 then
                error l_mensagem sleep 2
                rollback work
                prompt "" for char prompt_key
                close window cts15m01
                return
             end if
             #PSI186406 -Robson -Fim

             whenever error continue

             update datmsrvacp
               set  srvrcumtvcod = l_srvrcumtvcod
              where atdsrvnum    = param.atdsrvnum
                and atdsrvano    = param.atdsrvano
                and atdsrvseq    = l_seq

             whenever error stop

             if sqlca.sqlcode <> 0 then
                error " Erro (", sqlca.sqlcode, ") na atualizacao da etapa de acompanhamento.   . AVISE A INFORMATICA!"
                rollback work
                prompt "" for char prompt_key
                close window cts15m01
                return
             else
                call ctx34g00_apos_grvetapa(param.atdsrvnum,
                                            param.atdsrvano,
                                            l_seq,2)
             end if
          end if
#--------------------------------------------------------------------
# Interface com SINISTRO para cancelamento da reserva (Motivo = 3)
#--------------------------------------------------------------------

          if (d_cts15m01.atdetpcod = 5   or
              d_cts15m01.atdetpcod = 38) then

             select prporg, prpnumdig, avioccdat
               into ws.prporg   ,
                    ws.prpnumdig,
                    ws.avioccdat
               from datmavisrent
              where atdsrvnum = param.atdsrvnum  and
                    atdsrvano = param.atdsrvano

             if param.avialgmtv  = 3 and
                l_ciaempcod     <> 35 then
                #-- Acertar flag para sinistro de acordo com o motivo
                # if param.avialgmtv = 6 then
                #    let l_flag = "N"
                # else
                #    let l_flag = "S"
                # end if
                if sqlca.sqlcode = 0  then
                   call sinitfopc ("", "",
                                   g_documento.succod,
                                   g_documento.aplnumdig,
                                   g_documento.itmnumdig,
                                   ws.prporg,
                                   ws.prpnumdig,
                                   ws.avioccdat, "",
                                   "F",
                                   g_issk.funmat,
                                   "S")  # l_flag
                         returning ws.sqlcode, ws.tabname
                end if

                if ws.sqlcode <> 0  then
                   error "Katiu :",  ws.tabname
                   error " Erro (", ws.sqlcode, ") na interface com sinistro. AVISE A INFORMATICA! "
                   rollback work
                   prompt "" for char prompt_key
                   close window cts15m01
                   # -- CT 255556 - Katiucia -- #
                   return
                end if
             end if
             #Desmarcar para o beneficio carro extra
             call ctx01g06_excluir(param.atdsrvnum,param.atdsrvano, 'N')
                returning l_resultado, l_mensagem

             if l_resultado <> 1 then
                error l_mensagem sleep 2
                rollback work
                prompt "" for char prompt_key
                close window cts15m01
                return
             end if
          end if
       end if

    commit work
    call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)

    if d_cts15m01.atdetpcod = 43 or d_cts15m01.atdetpcod = 5 then
       if g_documento.ciaempcod = 1 then
          call cts15m00_acionamento (param.atdsrvnum, param.atdsrvano
                                     ,param.lcvcod, param.aviestcod
                                     ,l_etapa, ws.etpmtvcod, "C")

       else
          if  g_documento.ciaempcod = 35 then
              call cts15m15_acionamento (param.atdsrvnum, param.atdsrvano
                                        ,param.lcvcod, param.aviestcod
                                        ,l_etapa, ws.etpmtvcod,"C")
          end if
       end if
    end if

 end if

 let int_flag = false

 close window cts15m01

end function  ###  cts15m01
