 #############################################################################
 # Nome do Modulo: cts00m22                                         Wagner   #
 #                                                                           #
 # Conclusao do Servico ja' executados                              Abr/2000 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 16/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
 #                                       atdsrvnum de 6 p/ 10.               #
 #                                       Troca do campo atdtip p/ atdsrvorg. #
 #---------------------------------------------------------------------------#
 # 27/09/2000  PSI 10475-2  Wagner       Mudanca no paramantro de acesso ao  #
 #                                       modulo cts01n00.                    #
 #---------------------------------------------------------------------------#
 # 07/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador    #
 #                                       B-Bloqueado.                        #
 #############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
 function cts00m22(param)
#--------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define d_cts00m22   record
    cnldat           like datmservico.cnldat,
    atdfnlhor        char (05),
    operador         like isskfunc.funnom,
    atdetpcod        like datmsrvacp.atdetpcod,
    atdetpdes        like datketapa.atdetpdes,
    atdprscod        like dpaksocor.pstcoddig,
    nomgrr           like dpaksocor.nomgrr,
    cidufdprs        char (48),
    dddcod           like dpaksocor.dddcod,
    teltxt           like dpaksocor.teltxt,
    c24nomctt        like datmservico.c24nomctt,
    socvclcod        like datmservico.socvclcod,
    srrcoddig        like datmservico.srrcoddig,
    pasasivcldes     like datmtrptaxi.pasasivcldes
 end record

 define salva        record
    atdetpcod        like datmsrvacp.atdetpcod,
    atdetptipcod     like datketapa.atdetptipcod,
    atdprscod        like dpaksocor.pstcoddig
 end record

 define ws           record
    endcidprs        like dpaksocor.endcid,
    endufdprs        like dpaksocor.endufd,
    prssitcod        like dpaksocor.prssitcod,
    c24opemat        like datmservico.c24opemat,
    atdfnlhor        like datmservico.atdfnlhor,
    atdfnlflg        like datmservico.atdfnlflg,
    atdlibflg        like datmservico.atdlibflg,
    atdsrvorg        like datmservico.atdsrvorg,
    atdpvtretflg     like datmservico.atdpvtretflg,
    atdsrvretflg     like datmsrvre.atdsrvretflg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    socopgnum        like dbsmopg.socopgnum,
    pstcoddig        like dpaksocor.pstcoddig,
    atdsrvseq        like datmsrvacp.atdsrvseq,
    atdetptipcod     like datketapa.atdetptipcod,
    atdetppndflg     like datketapa.atdetppndflg,
    vclcoddig        like datkveiculo.vclcoddig,
    grvetpflg        smallint,
    dataatu          date,
    confirma         char (01),
    horaatu          char (05)
 end record

 define arr_aux      smallint
 define prompt_key   char (01)
 define w_retorno    smallint


 open window cts00m22 at 13,08 with form "cts00m22"
             attribute (form line 1, border, comment line last - 1)

 message " (F7)Psq.Prest"

 initialize d_cts00m22.*  to null
 initialize ws.*          to null
 initialize salva.*       to null

 let int_flag        = false
 let ws.dataatu      = today
 let ws.horaatu      = current hour to minute

 if param.atdsrvnum  is null   or
    param.atdsrvano  is null   then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    close window cts00m22
    return
 end if

 #--------------------------------------------------------------------
 # Verifica se servico ja' foi concluido
 #--------------------------------------------------------------------
 select atdprscod , atdfnlflg , c24opemat , atdlibflg   ,
        cnldat    , atdfnlhor , c24nomctt , atdpvtretflg,
        atdsrvorg , socvclcod , srrcoddig
   into d_cts00m22.atdprscod  , ws.atdfnlflg           ,
        ws.c24opemat          , ws.atdlibflg           ,
        d_cts00m22.cnldat     , d_cts00m22.atdfnlhor   ,
        d_cts00m22.c24nomctt  , ws.atdpvtretflg        ,
        ws.atdsrvorg          , d_cts00m22.socvclcod   ,
        d_cts00m22.srrcoddig
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum       =  param.atdsrvnum
    and datmservico.atdsrvano       =  param.atdsrvano
    and datmservicocmp.atdsrvnum    =  datmservico.atdsrvnum
    and datmservicocmp.atdsrvano    =  datmservico.atdsrvano

 if sqlca.sqlcode  =  notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    close window cts00m22
    return
 end if

 if ws.atdlibflg         = "N"  then
    error " Servico nao liberado nao pode ser alterado neste modulo!"
    close window cts00m22
    return
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
   into d_cts00m22.atdetpcod
   from datmsrvacp
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and atdsrvseq = ws.atdsrvseq

 if sqlca.sqlcode = 0 then
    let d_cts00m22.atdetpdes = "NAO CADASTRADA"

    select atdetpdes,
           atdetptipcod,
           atdetppndflg
      into d_cts00m22.atdetpdes,
           ws.atdetptipcod,
           ws.atdetppndflg
      from datketapa
     where atdetpcod = d_cts00m22.atdetpcod

    if ws.atdetppndflg = "S"  then
       let ws.atdfnlflg = "N"
    else
       let ws.atdfnlflg = "S"
    end if
 end if

 if  d_cts00m22.atdetpcod <> 4  and
     d_cts00m22.atdetpcod <> 6  then
     error " Etapa do servico NAO PERMITE alteracao neste modulo!"
     close window cts00m22
     return
 end if


 #--------------------------------------------------------------------
 # Informacoes do operador
 #--------------------------------------------------------------------
 if ws.c24opemat is not null  then
    let d_cts00m22.operador = "**NAO CADASTRADO**"

    select funnom
      into d_cts00m22.operador
      from isskfunc
     where empcod = 01
       and funmat = ws.c24opemat

    let d_cts00m22.operador = upshift(d_cts00m22.operador)
 end if


 #--------------------------------------------------------------------
 # Informacoes do prestador
 #--------------------------------------------------------------------
 select nomgrr, dddcod, teltxt, endcid, endufd
   into d_cts00m22.nomgrr, d_cts00m22.dddcod, d_cts00m22.teltxt,
        ws.endcidprs     , ws.endufdprs
   from dpaksocor
  where pstcoddig = d_cts00m22.atdprscod

 let d_cts00m22.cidufdprs = ws.endcidprs clipped, " - ", ws.endufdprs

 #--------------------------------------------------------------------
 # Salva conteudo dos campos
 #--------------------------------------------------------------------
 let salva.atdetpcod     =  d_cts00m22.atdetpcod
 let salva.atdetptipcod  =  ws.atdetptipcod
 let salva.atdprscod     =  d_cts00m22.atdprscod

 display by name d_cts00m22.cnldat thru d_cts00m22.c24nomctt


 #--------------------------------------------------------------------
 # Digita dados para conclusao
 #--------------------------------------------------------------------
 while true
    input by name d_cts00m22.atdetpcod,
                  d_cts00m22.atdprscod  without defaults

      before field atdetpcod
         display by name d_cts00m22.atdetpcod attribute (reverse)

      after field atdetpcod
         display by name d_cts00m22.atdetpcod

         select dbsmopg.socopgnum
           into ws.socopgnum
           from dbsmopgitm, dbsmopg
          where dbsmopgitm.atdsrvnum = param.atdsrvnum  and
                dbsmopgitm.atdsrvano = param.atdsrvano  and
                dbsmopg.socopgnum    = dbsmopgitm.socopgnum   and
                dbsmopg.socopgsitcod <> 8

         if sqlca.sqlcode = 0  then
            error " Servico nao deve ser alterado! Servico pago pela OP ",
                    ws.socopgnum using "<<<<<<<<<&", "!"
            let d_cts00m22.atdetpcod = salva.atdetpcod
            next field atdetpcod
         end if

         if d_cts00m22.atdetpcod is null   then
            error " Etapa deve ser informada!"
            let d_cts00m22.atdetpcod = salva.atdetpcod
            next field atdetpcod
         else
            if (salva.atdetpcod  = 4 and  d_cts00m22.atdetpcod = 4) or
                salva.atdetpcod  = 6 and (d_cts00m22.atdetpcod = 4  or
                                          d_cts00m22.atdetpcod = 6) then
            else
               error " Esta etapa NAO PODE ser informada neste modulo!"
               let d_cts00m22.atdetpcod = salva.atdetpcod
               next field atdetpcod
            end if

            select atdetpdes,
                   atdetptipcod,
                   atdetppndflg
              into d_cts00m22.atdetpdes,
                   ws.atdetptipcod,
                   ws.atdetppndflg
              from datketapa
             where atdetpcod = d_cts00m22.atdetpcod
               and atdetpstt = "A"

            if sqlca.sqlcode = notfound  then
               error " Etapa nao cadastrada! Informe novamente."
               let d_cts00m22.atdetpcod = salva.atdetpcod
               next field atdetpcod
            end if

            if ws.atdetppndflg = "S"  then
               let ws.atdfnlflg = "N"
            else
               let ws.atdfnlflg = "S"
            end if

            select atdetpcod
              from datrsrvetp
             where atdsrvorg = ws.atdsrvorg
               and atdetpcod = d_cts00m22.atdetpcod
               and atdsrvetpstt = "A"

            if sqlca.sqlcode = notfound  then
               error " Etapa nao pertence a este tipo de servico!"
               let d_cts00m22.atdetpcod = salva.atdetpcod
               next field atdetpcod
            end if
         end if

         display by name d_cts00m22.atdetpdes


      before field atdprscod
         display by name d_cts00m22.atdprscod attribute (reverse)

      after field atdprscod
         display by name d_cts00m22.atdprscod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdetpcod
         end if

         if d_cts00m22.atdprscod is null  then
            error " Codigo do prestador deve ser informado!"
            let d_cts00m22.atdprscod = salva.atdprscod
            next field atdprscod
         end if

         if salva.atdprscod <> d_cts00m22.atdprscod           then
            if salva.atdprscod >= 5 and salva.atdprscod <= 6  then
            else
               error " Codigo do prestador NAO PODE ser alterado neste modulo!"
               let d_cts00m22.atdprscod = salva.atdprscod
               next field atdprscod
            end if
         end if

         #--------------------------------------------------------------------
         # Busca/verifica situacao do cadastro de prestadores
         #--------------------------------------------------------------------
         select dpaksocor.nomgrr , dpaksocor.dddcod , dpaksocor.teltxt,
                dpaksocor.endcid , dpaksocor.endufd , dpaksocor.prssitcod
           into d_cts00m22.nomgrr, d_cts00m22.dddcod, d_cts00m22.teltxt,
                ws.endcidprs     , ws.endufdprs     , ws.prssitcod
           from dpaksocor
          where pstcoddig = d_cts00m22.atdprscod

         if sqlca.sqlcode  =  notfound   then
            error " Prestador nao cadastrado!"
            let d_cts00m22.atdprscod = salva.atdprscod
            next field atdprscod
         end if

         let d_cts00m22.cidufdprs = ws.endcidprs clipped, " - ", ws.endufdprs

         display d_cts00m22.nomgrr     to  nomgrr
         display d_cts00m22.cidufdprs  to  cidufdprs
         display d_cts00m22.dddcod     to  dddcod
         display d_cts00m22.teltxt     to  teltxt

         if ws.prssitcod  =  "C"   then
            error " Prestador com cadastro cancelado!"
            let d_cts00m22.atdprscod = salva.atdprscod
            next field atdprscod
         end if
         if ws.prssitcod  =  "B"   then
            error " Prestador com cadastro bloqueado!"
            let d_cts00m22.atdprscod = salva.atdprscod
            next field atdprscod
         end if
         if ws.prssitcod  =  "P"   then
            error " Prestador com cadastro em proposta!"
            let d_cts00m22.atdprscod = salva.atdprscod
            next field atdprscod
         end if


      on key (interrupt)
         exit input

      #--------------------------------------------------------------------
      # Pesquisa Prestador
      #--------------------------------------------------------------------
      on key (F7)
         call ctn01n01(" "," "," "," "," "," ") returning d_cts00m22.atdprscod
         next field atdetpcod

    end input

    if int_flag   then
       exit while
    else
       let ws.grvetpflg = false

       ### Verifica se SITUACAO foi alterada
       if salva.atdetpcod <> d_cts00m22.atdetpcod  then
          let ws.grvetpflg = true
       end if

       ### Verifica se PRESTADOR foi alterado
       if salva.atdprscod <> d_cts00m22.atdprscod  then
          let ws.grvetpflg = true
       end if

       if ws.grvetpflg = true  then
          call cts08g01("C","S","","DADOS CORRETOS ?",
                                    "","")
              returning ws.confirma

          if ws.confirma = "S"  then
             whenever error continue
             begin work

                update datmservico
                   set atdprscod = d_cts00m22.atdprscod
                 where atdsrvnum = param.atdsrvnum   and
                       atdsrvano = param.atdsrvano

                if sqlca.sqlcode <> 0  then
                   error " Erro (", sqlca.sqlcode, ") na conclusao do servico. AVISE A INFORMATICA!"
                   rollback work
                   prompt "" for char prompt_key
                   exit while
                end if

                call cts10g04_insere_etapa(param.atdsrvnum,
                                           param.atdsrvano,
                                           d_cts00m22.atdetpcod,
                                           d_cts00m22.atdprscod,
                                           d_cts00m22.c24nomctt,
                                           d_cts00m22.socvclcod,
                                           d_cts00m22.srrcoddig) returning w_retorno

                if w_retorno <> 0  then
                   error " Erro (", sqlca.sqlcode, ") na gravacao da etapa de acompanhamento. AVISE A INFORMATICA!"
                   rollback work
                   prompt "" for char prompt_key
                   exit while
                end if

             error " Alteracao efetuada com sucesso!"
         
             commit work
             # War Room.
             # Ponto de acesso apos a gravacao do laudo
             call cts00g07_apos_grvlaudo(param.atdsrvnum,
                                         param.atdsrvano)
             whenever error stop
             exit while
          end if
       else
          exit while
       end if
    end if

 end while

 close window cts00m22

 let int_flag = false

end function  ###--  cts00m22

