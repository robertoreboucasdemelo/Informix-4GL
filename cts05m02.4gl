#############################################################################
# Nome do Modulo: CTS05M02                                         Pedro    #
#                                                                  Marcelo  #
# Direciona e imprime aviso de furto para corretor                          #
# Direciona e imprime aviso para acionamento de alarme a distancia Set/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 26/10/1998  PSI 6966-3   Gilberto     Incluir configuracoes para envio de #
#                                       fax atraves do servidor VSI-Fax.    #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 23/01/2001  Paradigm     Wagner       Correcao no flag da funcao fufaxcel #
#             116747                    para captar tel/nome nao convenio.  #
#---------------------------------------------------------------------------#
# 28/03/2002  PSI          Ruiz         Envio de fax para ITURAN.           #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Renato Zattar                    OSF : 4774             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 10/07/2002       #
#  Objetivo       : Alterar programa para comportar Endereco Eletronico     #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86               #
# 22/05/2003  Aguinaldo Costa     PSI.174050     Rastreador Tracker         #
#---------------------------------------------------------------------------#
# 03/03/2006  Zeladoria   Priscila      Buscar data e hora do banco de dados#
# 13/08/2009  Sergio Burini       PSI 244236     Inclusão do Sub-Dairro     #
#---------------------------------------------------------------------------#
# 04/01/2010  Amilton                   Projeto sucursal smallint           #
#---------------------------------------------------------------------------#
# 27/09/2012  Raul Biztalking         Retirar empresa 1 fixa p/ funcionario #
#---------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail #
#############################################################################
globals "/homedsa/projetos/geral/globals/figrc012.4gl" #Saymon ambnovo
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define g_pipe     char (80)
 define g_traco    char (80)
 define g_fax      char (03)
 define l_docHandle  integer                    #RightFax

 #RightFax - Inicio
 define l_itens   array[50] of record
        label_esquerda  char(30)
       ,valor_esquerda  dec (14,2)
       ,label_direita   char(30)
       ,valor_direita   dec (14,2)
 end record
 #RightFax - Fim

#--------------------------------------------------------------
 function cts05m02(param)
#--------------------------------------------------------------

 define param      record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    enviar         char(01),
    reenvflg       char(01),
    dddcod         like gcakfilial.dddcod,
    factxt         like gcakfilial.factxt,
    maides         like gcakfilial.maides
 end record

 define d_cts05m02 record
    enviar         char (01),
    envdes         char (10),
    dddcod         like datklocadora.dddcod,
    facnum         like datklocadora.facnum,
    maides         like gcakfilial.maides
 end record

 define ws           record
    vicsnh           like datmservicocmp.vicsnh,  ## Senha alarme a distancia
    faxcor           char (15)                 ,  ## Numero fax corretor
    corsus           like gcaksusep.corsus     ,
    dddcod           like gcakfilial.dddcod    ,
    factxt           like gcakfilial.factxt    ,
    maides           like gcakfilial.maides    ,
    impnom           char (08)                 ,
    confirma         char (01)                 ,
    ok               smallint                  ,
    vcllicnum        like abbmveic.vcllicnum   ,
    vclchsinc        like abbmveic.vclchsinc   ,
    vclchsfnl        like abbmveic.vclchsfnl   ,
    ituran           smallint                  ,
    tracker          smallint                  ,
    chassi           char (20)                 ,
    vclcoddig        like abbmveic.vclcoddig   ,
    orrdat           like adbmbaixa.orrdat     ,
    qtd_dispo_ativo  integer    ## Projeto Instalacao de 2 DAF's em caminhoes - Jorge Modena
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
   ,status            smallint
 end record

 define
   vl_faxch1           like gfxmfax.faxch1        ,
   vl_faxch2           like gfxmfax.faxch2        ,
   vl_faxchx           char (10)                  ,
   vl_lignum           like datrligsrv.lignum     ,
   vl_comando          char(100)

 define l_data        date,
        l_hora1       datetime hour to second
  define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
  end  record
  define l_coderro  smallint
  define msg_erro char(500)

        let     vl_faxch1  =  null
        let     vl_faxch2  =  null
        let     vl_faxchx  =  null
        let     vl_lignum  =  null
        let     vl_comando  =  null

        initialize  d_cts05m02.*  to  null

        initialize  ws.*  to  null

        initialize  vl_gcakfilial.*  to  null

 initialize d_cts05m02.*  to null
 initialize ws.*          to null
 let int_flag             =  false
 let d_cts05m02.enviar    =  param.enviar
 let g_fax                =  "VSI"

 #---------------------------------------------------------
 # Verifica qual(is) fax(s) devem ser enviados
 #---------------------------------------------------------
 select vicsnh, corsus
   into ws.vicsnh, ws.corsus
   from datmservico, datmservicocmp
  where datmservico.atdsrvnum    = param.atdsrvnum          and
        datmservico.atdsrvano    = param.atdsrvano          and
        datmservicocmp.atdsrvnum = datmservico.atdsrvnum    and
        datmservicocmp.atdsrvano = datmservico.atdsrvano

 if sqlca.sqlcode = notfound   then
    error " Servico nao encontrado. AVISE A INFORMATICA !"
    return
 end if

 if param.reenvflg  =  "N"   then

    if ws.corsus  is not null    and
       ws.corsus  <> "  "        then

       # -- OSF 4774 - Fabrica de Softeware, Katiucia -- #
       call fgckc811 ( ws.corsus )
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
                     ,vl_gcakfilial.status

    ## select dddcod, factxt, maides
    ##   into ws.dddcod, ws.factxt, ws.maides
    ##   from gcaksusep, gcakcorr, gcakfilial
    ##  where gcaksusep.corsus     = ws.corsus            and
    ##        gcakcorr.corsuspcp   = gcaksusep.corsuspcp  and
    ##        gcakfilial.corsuspcp = gcaksusep.corsuspcp  and
    ##        gcakfilial.corfilnum = gcaksusep.corfilnum

        if vl_gcakfilial.status = 1 or
           vl_gcakfilial.status = 2 then
           error " Corretor nao encontrado. AVISE A INFORMATICA!"
           return
        end if

        let ws.dddcod = vl_gcakfilial.dddfax
        let ws.factxt = vl_gcakfilial.factxt
        let ws.maides = vl_gcakfilial.maides

        call cts09g02(ws.dddcod, ws.factxt)
            returning ws.dddcod, ws.factxt
        let ws.faxcor = ws.dddcod clipped, ws.factxt clipped
    end if

    if ws.vicsnh is null  and
       ws.faxcor is null  and
       ws.maides is null  then
       error " Nenhum FAX/E-MAIL deve ser enviado!"
       return
    end if
 end if

 # -- OSF 4774 - Fabrica de Software, Katiucia --#
 ##if param.factxt is null and
 ##   param.maides is null then
 ##   let d_cts05m02.dddcod = ws.dddcod
 ##   let d_cts05m02.facnum = ws.factxt
 ##   let d_cts05m02.maides = ws.maides
 ##else
 ##   let d_cts05m02.dddcod = param.dddcod
 ##   let d_cts05m02.facnum = param.factxt
 ##   let d_cts05m02.maides = param.maides
 ##end if

 open window cts05m02 at 10,2 with form "cts05m02"
             attribute (form line 1, border)

 let d_cts05m02.enviar = "E"   # arnaldo, 26/09
 input by name d_cts05m02.*   without defaults

   before field enviar
          display by name d_cts05m02.enviar    attribute (reverse)

   after  field enviar
          display by name d_cts05m02.enviar

          if d_cts05m02.enviar is null or
             d_cts05m02.enviar  = " "  then
             error " Enviar fax para (I)mpressora,(F)ax,(E)Mail ou (A)Fax/Email"
             next field enviar
          else
             if d_cts05m02.enviar <> "F" and
                d_cts05m02.enviar <> "I" and
                d_cts05m02.enviar <> "A" and
                d_cts05m02.enviar <> "E" then
              error "Enviar fax para (I)mpressora,(F)ax,(E)Mail ou (A)Fax/Email"
                next field enviar
             end if
             case d_cts05m02.enviar
                when "F"    let d_cts05m02.envdes = "FAX"
                when "I"    let d_cts05m02.envdes = "IMPRESSORA"
                when "E"    let d_cts05m02.envdes = "E-MAIL"
                when "A"    let d_cts05m02.envdes = "FAX/E-MAIL"
             end case
          end if
          display by name d_cts05m02.envdes

          initialize  g_pipe, ws.impnom, ws.ok   to null

          if d_cts05m02.enviar = "I"   then
             call fun_print_seleciona (g_issk.dptsgl, "")
                  returning  ws.ok, ws.impnom
             let int_flag = false
             if ws.ok  =  0   then
                error " Departamento/Impressora nao cadastrada!"
                next field enviar
             end if
             if ws.impnom   is null   then
                error " Uma impressora deve ser selecionada!"
                next field enviar
             end if
          else
             if not d_cts05m02.enviar = "F" then
                if d_cts05m02.enviar = "E" then
                   let d_cts05m02.dddcod = null
                   let d_cts05m02.facnum = null
                   next field maides
                end if
             end if
          end if

       #  if param.reenvflg  =  "N"   then
       #     exit input
       #  end if
          next field dddcod

   before field dddcod
          display by name d_cts05m02.dddcod    attribute (reverse)

   after  field dddcod
          display by name d_cts05m02.dddcod
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field enviar
          end if

          # -- OSF 4774 - Fabrica de Software, Katiucia -- #
          if d_cts05m02.enviar = "E" then
             if d_cts05m02.dddcod is null  or
                d_cts05m02.dddcod  = "  "  then
                initialize d_cts05m02.facnum to null
                display by name d_cts05m02.facnum
                next field maides
             end if
          else
             if d_cts05m02.dddcod   is null    or
                d_cts05m02.dddcod   = "  "     then
                error " Codigo do DDD deve ser informado!"
                next field dddcod
             end if
             if d_cts05m02.dddcod   = "0   "   or
                d_cts05m02.dddcod   = "00  "   or
                d_cts05m02.dddcod   = "000 "   or
                d_cts05m02.dddcod   = "0000"   then
                error " Codigo do DDD invalido!"
                next field dddcod
             end if
          end if

   before field facnum
          display by name d_cts05m02.facnum    attribute (reverse)

   after  field facnum
          display by name d_cts05m02.facnum
          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field dddcod
          end if

          if d_cts05m02.facnum is null  or
             d_cts05m02.facnum =  000   then
             error " Numero do fax deve ser informado!"
             next field facnum
          else
             if d_cts05m02.facnum > 99999   then
             else
                error " Numero do fax invalido!"
                next field facnum
             end if
          end if

          if g_fax = "GSF"  then
             if d_cts05m02.facnum is null then
                let ws.faxcor = param.dddcod  clipped,
                                param.factxt  using "<<<<<<<<<"
             else
                let ws.faxcor = d_cts05m02.dddcod  clipped,
                                d_cts05m02.facnum  using "<<<<<<<<<"
             end if
          else
             if d_cts05m02.facnum is not null then
                call cts02g01_fax(d_cts05m02.dddcod, d_cts05m02.facnum)
                        returning ws.faxcor
             else
                call cts02g01_fax(param.dddcod, param.factxt)
                        returning ws.faxcor
             end if
          end if

   # -- OSF 4774 - Fabrica de Software, Katiucia -- #
   before field maides
       display by name d_cts05m02.maides    attribute (reverse)

   after  field maides
       display by name d_cts05m02.maides

       if fgl_lastkey() = fgl_keyval("up")     or
          fgl_lastkey() = fgl_keyval("left")   then
          if d_cts05m02.enviar = "E" or
             d_cts05m02.enviar = "A" then
             next field enviar
          else
             next field facnum
          end if
       end if

       if d_cts05m02.enviar = "E" then
          if d_cts05m02.maides is null or
             d_cts05m02.maides  = " "  then
           # error "E-Mail deve ser informado!"
           # next field maides
          end if
       end if

       if param.atdsrvnum is not null  and
          param.atdsrvano is not null  then
          let vl_faxchx = param.atdsrvnum  using "&&&&&&&&",
                          param.atdsrvano  using "&&"
       else
          let vl_lignum = cts20g00_servico(param.atdsrvnum
                                          ,param.atdsrvano)
          if vl_lignum is not null  then
             let vl_faxchx = vl_lignum  using "&&&&&&&&&&"
          else
              error " Servico nao informado. AVISE INFORMATICA!"
             next field maides
          end if
       end if

       let vl_faxch1 = vl_faxchx

       select max(faxch2)
         into vl_faxch2
         from datmfax
        where faxsiscod = "CT"  and
              faxsubcod = "AS"  and
              faxch1    = vl_faxch1

       if sqlca.sqlcode = notfound then
          ###error "Dados nao gravados em DATMFAX! Chave nao encontrada"
          let int_flag = false
          close window cts05m02
          return
       end if

       if vl_faxch2 is null then
          let vl_faxch2 = 0
       end if

       let vl_faxch2 = vl_faxch2 + 1

       call cts40g03_data_hora_banco(1)
            returning l_data, l_hora1
       # ----------------------- #
       # GRAVAR DADOS EM DATMFAX #
       # ----------------------- #
       whenever error continue
       insert into datmfax ( faxsiscod
                            ,faxsubcod
                            ,faxch1
                            ,faxch2
                            ,faxenvdat
                            ,faxenvhor
                            ,funmat
                            ,faxenvsit )
                    values ( "CT"
                            ,"AS"
                            ,vl_faxch1
                            ,vl_faxch2
                            ,l_data
                            ,l_hora1
                            ,g_issk.funmat
                            ,1)
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Erro: ", sqlca.sqlcode
               ,", Problemas ao gravar dados em DATMFAX!"
          next field maides
       end if

   on key (interrupt,control-c,f17)
      let int_flag = true
      exit input

 end input

 if int_flag  then
    # -- OSF 4774 - Fabrica de Software, Katiucia -- #
    if param.dddcod is null and
       param.factxt is null and
       param.maides is null then
       error " ATENCAO !!! FAX/E-MAIL NAO SERA' ENVIADO!"

       call cts08g01("A","N","FAX/E-MAIL DO AVISO DE FURTO/ROUBO TOTAL",
                             "E/OU ACIONAMENTO DE ALARME", "",
                             "*** NAO SERA' ENVIADO ***")
            returning ws.confirma
       let int_flag = false
       close window cts05m02
       return
    end if

    if param.maides is not null and
       d_cts05m02.enviar = "E" then
       if param.atdsrvnum is not null  and
          param.atdsrvano is not null  then
          let vl_faxchx = param.atdsrvnum  using "&&&&&&&&",
                          param.atdsrvano  using "&&"
       else
          let vl_lignum = cts20g00_servico(param.atdsrvnum
                                          ,param.atdsrvano)
          if vl_lignum is not null  then
             let vl_faxchx = vl_lignum  using "&&&&&&&&&&"
          else
             error " Servico nao informado. AVISE INFORMATICA!"
             let int_flag = false
             close window cts05m02
             return
          end if
       end if

       let vl_faxch1 = vl_faxchx

       select max(faxch2)
         into vl_faxch2
         from datmfax
        where faxsiscod = "CT"  and
              faxsubcod = "AS"  and
              faxch1    = vl_faxch1

       if sqlca.sqlcode = notfound then
          ###error "Dados nao gravados em DATMFAX! Chave nao encontrada"
          let int_flag = false
          close window cts05m02
          return
       end if

       if vl_faxch2 is null then
          let vl_faxch2 = 0
       end if

       let vl_faxch2 = vl_faxch2 + 1

       call cts40g03_data_hora_banco(1)
            returning l_data, l_hora1

       # ----------------------- #
       # GRAVAR DADOS EM DATMFAX #
       # ----------------------- #
       whenever error continue
       insert into datmfax ( faxsiscod
                            ,faxsubcod
                            ,faxch1
                            ,faxch2
                            ,faxenvdat
                            ,faxenvhor
                            ,funmat
                            ,faxenvsit )
                    values ( "CT"
                            ,"AS"
                            ,vl_faxch1
                            ,vl_faxch2
                            ,l_data
                            ,l_hora1
                            ,g_issk.funmat
                            ,1)
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Erro: ", sqlca.sqlcode
               ,", Problemas ao gravar dados em DATMFAX!"
          let int_flag = false
          close window cts05m02
          return
       else
          let d_cts05m02.enviar = "E"
          let g_pipe = "rcts05m0201"
       end if

    else
    #  let d_cts05m02.enviar = "F"


       if g_fax = "GSF"  then
          let ws.faxcor = param.dddcod  clipped,
                          param.factxt  using "<<<<<<<<<"
       else
          call cts02g01_fax(param.dddcod, param.factxt)
               returning ws.faxcor
       end if
    end if
 else
    if d_cts05m02.facnum is not null and
       d_cts05m02.dddcod is not null then
       #let ws.faxcor = d_cts05m02.dddcod clipped,
       #                d_cts05m02.facnum using "<<<<<<<<"


       call cts02g01_fax(d_cts05m02.dddcod, d_cts05m02.facnum)
            returning ws.faxcor
    end if
 end if

 if  g_documento.succod    is not null  and
     g_documento.ramcod    is not null  and
     g_documento.aplnumdig is not null  then
     select vcllicnum,
            vclchsinc,
            vclchsfnl,
            vclcoddig
        into ws.vcllicnum,
             ws.vclchsinc,
             ws.vclchsfnl,
             ws.vclcoddig
        from abbmveic
       where abbmveic.succod    = g_documento.succod     and
             abbmveic.aplnumdig = g_documento.aplnumdig  and
             abbmveic.itmnumdig = g_documento.itmnumdig  and
             abbmveic.dctnumseq = g_funapol.vclsitatu
     let ws.chassi = ws.vclchsinc clipped,ws.vclchsfnl

     call fadic005_existe_dispo(ws.vclchsinc ,
                                ws.vclchsfnl ,
                                ws.vcllicnum ,
                                ws.vclcoddig ,
                                1333)    # ITURAN
     returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo
     if ws.ituran = false then
         call fadic005_existe_dispo(ws.vclchsinc ,
                                    ws.vclchsfnl ,
                                    ws.vcllicnum ,
                                    ws.vclcoddig ,
                                    9099)    # ITURAN
         returning ws.ituran, ws.orrdat, ws.qtd_dispo_ativo
     end if
     call fadic005_existe_dispo(ws.vclchsinc ,
                                ws.vclchsfnl ,
                                ws.vcllicnum ,
                                ws.vclcoddig ,
                                1546)     # TRACKER
     returning ws.tracker  , ws.orrdat , ws.qtd_dispo_ativo
 end if

 if ws.vicsnh  is not null    and
    ws.vicsnh  <> "   "       then
    call cts05m02_alarme(param.atdsrvnum, param.atdsrvano, d_cts05m02.enviar,
                         ws.impnom,"T","")
    call cts08g01("A","N","","A SUPERVISAO DEVE SER INFORMADA DO",
                             "ACIONAMENTO DO ALARME; CONFIRME O",
                             "RECEBIMENTO DO FAX PELA POLLUS!")
        returning ws.confirma
 else
    if ws.ituran = true then
       call cts05m02_alarme(param.atdsrvnum,param.atdsrvano,
                            d_cts05m02.enviar,ws.impnom,"I",ws.chassi)
    else
       if ws.tracker = true then
          call cts05m02_alarme(param.atdsrvnum,param.atdsrvano,
                               d_cts05m02.enviar,ws.impnom,"L",ws.chassi)
       end if
    end if
 end if

 if ws.faxcor  is not null or
    d_cts05m02.enviar is not null then
    call cts05m02_furto(param.atdsrvnum, param.atdsrvano,
                        d_cts05m02.enviar, ws.faxcor, ws.impnom)
 end if

 # -- OSF 4774 - Fabrica de Software, Katiucia -- #
 if d_cts05m02.enviar = "E" or
    d_cts05m02.enviar = "A" then
    if d_cts05m02.maides is null or
       d_cts05m02.maides  = " "  then
       let d_cts05m02.maides = param.maides
    end if

    #PSI-2013-23297 - Inicio
    let l_mail.de = ""
    #let l_mail.para = "humbertobenedito.santos@portoseguro.com.br"
    let l_mail.para = d_cts05m02.maides
    let l_mail.cc = ""
    let l_mail.cco = ""
    let l_mail.assunto = "Aviso de Sinistro"
    let l_mail.mensagem = ""
    let l_mail.id_remetente = "CT24H"
    let l_mail.tipo = "text"
    #display "Arquivo: ",g_pipe
    call figrc009_attach_file(g_pipe)

    #display "Arquivo anexado com sucesso"
    call figrc009_mail_send1 (l_mail.*)
     returning l_coderro,msg_erro
    #PSI-2013-23297 - Fim

    let vl_comando = " rm ", g_pipe clipped
    run vl_comando
 end if

 let int_flag = false
 close window cts05m02

end function  ###  cts05m02


#---------------------------------------------------------------
 function cts05m02_alarme(param)
#---------------------------------------------------------------

 define param      record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    enviar         char (01),
    impnom         char (08),
    empresa        char (01),
    chassi         char (20)
 end record

 define d_cts05m02  record
    atdsrvorg       like datmservico.atdsrvorg,
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    nom             like datmservico.nom,
    vcldes          like datmservico.vcldes,
    vcllicnum       like datmservico.vcllicnum,
    vclanomdl       like datmservico.vclanomdl,
    lgdtxt          char (65),
    lclbrrnom       like datmlcl.lclbrrnom,
    cidnom          like datmlcl.cidnom,
    ufdcod          like datmlcl.ufdcod,
    atddat          like datmservico.atddat,
    atdhor          like datmservico.atdhor,
    vicsnh          like datmservicocmp.vicsnh,
    sindat          like datmservicocmp.sindat,
    sinhor          like datmservicocmp.sinhor,
    c24sintip       like datmservicocmp.c24sintip
 end record

 define ws          record
    faxch1          like datmfax.faxch1,
    faxch2          like datmfax.faxch2,
    dddcod          char (04),
    telnum          dec  (10,0),
    faxtxt          char (12),
    envflg          dec(1,0),
    confirma        char (01),
    lclidttxt       like datmlcl.lclidttxt,
    endzon          like datmlcl.endzon,
    lclrefptotxt    like datmlcl.lclrefptotxt,
    lcldddcod       like datmlcl.dddcod,
    lcltelnum       like datmlcl.lcltelnum,
    lclcttnom       like datmlcl.lclcttnom,
    sqlcode         integer
 end record

 #RightFax - inicio
 define lr_param         record
        service            char(15)
       ,serviceType        char(15)
       ,typeOfConnection   char(3)
       ,fileSystem         char(100)
       ,jasperFileName     char(50)
       ,outFileName        char(100)
       ,outFileType        char(3)
       ,recordPath         char(100)
       ,aplicacao          char(30)
       ,outbox             char(100)
       ,generatorTIFF      smallint
 end record

 define l_hora            datetime hour to second
 define l_nomexml         char(200)
 define w_conta           smallint

 define lr_param_out      record
          codigo            smallint
        , mensagem          char(200)
 end    record

 define lr_fax             record
          ddd                char(3)
         ,telefone           char(16)
         ,destinatario 	     char(30)
         ,notas              char(30)
         ,caminhoarq         char(100)
         ,sistema            char(100)
         ,geratif            smallint
 end record
 initialize lr_param.* ,lr_param_out.*, l_hora to null
 #RightFax - Fim

        initialize  d_cts05m02.*  to  null

        initialize  ws.*  to  null

 initialize d_cts05m02.*  to null
 let ws.envflg = false


 #---------------------------------------------------------
 # Numero do fax da empresa POLLUS
 #---------------------------------------------------------
 if param.empresa = "L" then  # TRACKER DO BRASIL
    let ws.dddcod = "0011"
    let ws.telnum = 62212356
 end if
 if param.empresa = "T" then  # TELEBLOC
    let ws.dddcod = "0011"
    let ws.telnum = 5460303
    if g_issk.funmat = 601566 then
       let ws.telnum = 33665001
    end if
 else
    if param.empresa = "I" then  # ITURAN
       let ws.dddcod = "0011"
       let ws.telnum = 34712411
       if g_issk.funmat = 601566 then
          let ws.telnum = 33665001
       end if
    end if
 end if

 declare c_cts05m02_001   cursor for
   select datmservico.atdsrvnum , datmservico.atdsrvano   ,
          datmservico.atddat    , datmservico.atdhor      ,
          datmservico.nom       , datmservico.vcldes      ,
          datmservico.vcllicnum , datmservico.vclanomdl   ,
          datmservicocmp.sindat , datmservicocmp.sinhor   ,
          datmservicocmp.vicsnh , datmservico.atdsrvorg   ,
          datmservicocmp.c24sintip
     from datmservico, outer datmservicocmp
    where datmservico.atdsrvnum  = param.atdsrvnum
      and datmservico.atdsrvano  = param.atdsrvano

      and datmservico.atdsrvnum  = datmservicocmp.atdsrvnum
      and datmservico.atdsrvano  = datmservicocmp.atdsrvano

   #------------------------------------------------------------------
   # Busca endereco do local de ocorrencia
   #------------------------------------------------------------------
   call ctx04g00_local_reduzido (param.atdsrvnum, param.atdsrvano, 1)
        returning  ws.lclidttxt,
                   d_cts05m02.lgdtxt,
                   d_cts05m02.lclbrrnom,
                   ws.endzon,
                   d_cts05m02.cidnom,
                   d_cts05m02.ufdcod,
                   ws.lclrefptotxt,
                   ws.lcldddcod,
                   ws.lcltelnum,
                   ws.lclcttnom,
                   ws.sqlcode

   if param.enviar  = "F" or
      param.enviar  = "A" then

      call cts10g01_enviofax(param.atdsrvnum, param.atdsrvano,
                             "", "FU", g_issk.funmat)
                   returning ws.envflg, ws.faxch1, ws.faxch2

      if g_fax = "GSF"  then
         if g_outFigrc012.Is_Teste then #ambnovo
            let param.impnom = "tstclfax"
         else
            let param.impnom = "furtofax"
         end if
         let g_pipe = "lp -sd ", param.impnom
      else
         call cts02g01_fax(ws.dddcod, ws.telnum)
                 returning ws.faxtxt

         {if param.empresa = "T" then
            let g_pipe = "vfxCTFU ", ws.faxtxt clipped, " "
                                   , ascii 34, "POLLUS TELEBLOC"
                                   , ascii 34, " "
                                   , ws.faxch1 using "&&&&&&&&&&", " "
                                   , ws.faxch2 using "&&&&&&&&&&"
         else
            if param.empresa = "I" then
               let g_pipe = "vfxCTFU ", ws.faxtxt clipped, " "
                            , ascii 34, "ITURAN", ascii 34, " "
                            , ws.faxch1 using "&&&&&&&&&&", " "
                            , ws.faxch2 using "&&&&&&&&&&"
            end if
            if param.empresa = "L" then
               let g_pipe = "vfxCTFU ", ws.faxtxt clipped, " "
                            , ascii 34, "LOJACK", ascii 34, " "
                            , ws.faxch1 using "&&&&&&&&&&", " "
                            , ws.faxch2 using "&&&&&&&&&&"
            end if

         end if}
         let g_pipe = "rcts05m0201"
      end if
   else
      let ws.envflg = true
      if param.enviar = "I" then
         let g_pipe = "lp -sd ", param.impnom
      else
         call cts10g01_enviofax(param.atdsrvnum, param.atdsrvano,
                             "", "FU", g_issk.funmat)
                   returning ws.envflg, ws.faxch1, ws.faxch2

         let g_pipe = "rcts05m0201"
      end if
   end if
   if ws.envflg = true  then
     if param.enviar = "A" then
      let param.enviar = "F"
      #RightFax - Inicio
      #start report  rep_alarme to pipe g_pipe
      let lr_param.service          = 'cts05m02.4gl'
      let lr_param.serviceType      = 'GENERATOR'
      let lr_param.typeOfConnection = 'xml'
      let lr_param.fileSystem       = '\\\\nt112\\jasper3\\atendimento_rightfax\\jaspers\\'
      let lr_param.jasperFileName   = 'cts_alarme.jasper'
      let l_hora                    =  current
      let lr_param.outFileName      = 'alarme'
      let lr_param.outFileType      = 'pdf'
      let lr_param.recordPath       = '/report/data/file/cts_alarme'
      let lr_param.aplicacao        = 'cts05m02.4gl'
      let lr_param.outbox           = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\'
      let lr_param.generatorTIFF    = false
      let l_nomexml                 = 'cts05m02'
      call cty35g00_monta_estrutura_jasper(lr_param.*,l_nomexml)
          returning l_docHandle
      #RightFax - Fim


      start report  rep_alarme to pipe g_pipe

      foreach c_cts05m02_001  into  d_cts05m02.atdsrvnum ,
                                       d_cts05m02.atdsrvano ,
                                       d_cts05m02.atddat    ,
                                       d_cts05m02.atdhor    ,
                                       d_cts05m02.nom       ,
                                       d_cts05m02.vcldes    ,
                                       d_cts05m02.vcllicnum ,
                                       d_cts05m02.vclanomdl ,
                                       d_cts05m02.sindat    ,
                                       d_cts05m02.sinhor    ,
                                       d_cts05m02.vicsnh    ,
                                       d_cts05m02.atdsrvorg ,
                                       d_cts05m02.c24sintip

         output to report rep_alarme (d_cts05m02.*, param.enviar,
                                      ws.faxch1   , ws.faxch2   ,
                                      ws.dddcod   , ws.telnum   ,
                                      param.empresa, param.chassi)

         call cts05m02_rep_alarme(d_cts05m02.*,
                                  param.enviar,
                                  ws.faxch1   ,
                                  ws.faxch2   ,
                                  ws.dddcod   ,
                                  ws.telnum   ,
                                  param.empresa,
                                  param.chassi,
                                  l_docHandle)
         returning lr_param_out.codigo, lr_param_out.mensagem

      end foreach

      finish report  rep_alarme
      let param.enviar = "E"
      let g_pipe = "rcts05m0201"
      start report  rep_alarme to g_pipe

      foreach c_cts05m02_001  into  d_cts05m02.atdsrvnum ,
                                       d_cts05m02.atdsrvano ,
                                       d_cts05m02.atddat    ,
                                       d_cts05m02.atdhor    ,
                                       d_cts05m02.nom       ,
                                       d_cts05m02.vcldes    ,
                                       d_cts05m02.vcllicnum ,
                                       d_cts05m02.vclanomdl ,
                                       d_cts05m02.sindat    ,
                                       d_cts05m02.sinhor    ,
                                       d_cts05m02.vicsnh    ,
                                       d_cts05m02.atdsrvorg ,
                                       d_cts05m02.c24sintip

         output to report rep_alarme (d_cts05m02.*, param.enviar,
                                      ws.faxch1   , ws.faxch2   ,
                                      ws.dddcod   , ws.telnum   ,
                                      param.empresa, param.chassi)

      end foreach

      finish report  rep_alarme

      #RightFax - Inicio
      if lr_param_out.codigo = 0 then
         case param.empresa
          when "T"
            let lr_fax.destinatario  = 'POLLUS TELEBLOC'
          when "I"
            let lr_fax.destinatario  = 'ITURAN'
          when "L"
            let lr_fax.destinatario  = 'TRACKER DO BRASIL'
          otherwise
            let lr_fax.destinatario  = ''
         end case

         let lr_fax.ddd           = ws.dddcod
         let lr_fax.telefone      = ws.telnum
         let lr_fax.notas         = ''
         let lr_fax.caminhoarq    = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\',lr_param.outFileName ,'.pdf'
         let lr_fax.sistema       = 'lmd681'
         let lr_fax.geratif       = false

         call cty35g00_envia_fax(l_docHandle,lr_fax.*)
         returning lr_param_out.codigo, lr_param_out.mensagem

         if lr_param_out.codigo = 0 then
            display "Fax enviado com sucesso"
         end if
      end if
      #RightFax - Fim

     else

      if param.enviar = "F" then
           initialize l_docHandle to null

           #RightFax - Inicio
           #start report  rep_alarme to pipe g_pipe
           let lr_param.service          = 'cts05m02.4gl'
           let lr_param.serviceType      = 'GENERATOR'
           let lr_param.typeOfConnection = 'xml'
           let lr_param.fileSystem       = '\\\\nt112\\jasper3\\atendimento_rightfax\\jaspers\\'
           let lr_param.jasperFileName   = 'cts_alarme.jasper'
           let l_hora                    =  current
           let lr_param.outFileName      = 'alarme'
           let lr_param.outFileType      = 'pdf'
           let lr_param.recordPath       = '/report/data/file/cts_alarme'
           let lr_param.aplicacao        = 'cts05m02.4gl'
           let lr_param.outbox           = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\'
           let lr_param.generatorTIFF    = false
           let l_nomexml                 = 'cts05m02'
           call cty35g00_monta_estrutura_jasper(lr_param.*,l_nomexml)
               returning l_docHandle
           #RightFax - Fim
      end if

      if param.enviar = "E" then
         start report rep_alarme to g_pipe
      else
         start report  rep_alarme to pipe g_pipe
      end if

      foreach c_cts05m02_001  into  d_cts05m02.atdsrvnum ,
                                       d_cts05m02.atdsrvano ,
                                       d_cts05m02.atddat    ,
                                       d_cts05m02.atdhor    ,
                                       d_cts05m02.nom       ,
                                       d_cts05m02.vcldes    ,
                                       d_cts05m02.vcllicnum ,
                                       d_cts05m02.vclanomdl ,
                                       d_cts05m02.sindat    ,
                                       d_cts05m02.sinhor    ,
                                       d_cts05m02.vicsnh    ,
                                       d_cts05m02.atdsrvorg ,
                                       d_cts05m02.c24sintip

         output to report rep_alarme (d_cts05m02.*, param.enviar,
                                      ws.faxch1   , ws.faxch2   ,
                                      ws.dddcod   , ws.telnum   ,
                                      param.empresa, param.chassi)

         if param.enviar = "F" then
              call cts05m02_rep_alarme(d_cts05m02.*,
                                       param.enviar,
                                       ws.faxch1   ,
                                       ws.faxch2   ,
                                       ws.dddcod   ,
                                       ws.telnum   ,
                                       param.empresa,
                                       param.chassi,
                                       l_docHandle)
              returning lr_param_out.codigo, lr_param_out.mensagem
         end if

      end foreach

     if param.enviar = "F" then
          #RightFax - Inicio
           if lr_param_out.codigo = 0 then
              case param.empresa
               when "T"
                 let lr_fax.destinatario  = 'POLLUS TELEBLOC'
               when "I"
                 let lr_fax.destinatario  = 'ITURAN'
               when "L"
                 let lr_fax.destinatario  = 'TRACKER DO BRASIL'
               otherwise
                 let lr_fax.destinatario  = ''
              end case

              let lr_fax.ddd           = ws.dddcod
              let lr_fax.telefone      = ws.telnum
              let lr_fax.notas         = ''
              let lr_fax.caminhoarq    = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\',lr_param.outFileName ,'.pdf'
              let lr_fax.sistema       = 'lmd681'
              let lr_fax.geratif       = false

              call cty35g00_envia_fax(l_docHandle,lr_fax.*)
              returning lr_param_out.codigo, lr_param_out.mensagem

              if lr_param_out.codigo = 0 then
                 display "Fax enviado com sucesso"
              end if
           end if
           #RightFax - Fim
      end if

      finish report  rep_alarme
     end if
   else
      call cts08g01 ("A", "S", "OCORREU UM PROBLEMA NO ENVIO",
                               "DO FAX", "",
                               "*** TENTE NOVAMENTE ***")
           returning ws.confirma
   end if

end function  ###  cts05m02_alarme


#---------------------------------------------------------------------------
 report rep_alarme(r_cts05m02, param)    ### FAX P/ ACIONAMENTO DE ALARME
#---------------------------------------------------------------------------

 define r_cts05m02  record
    atdsrvorg       like datmservico.atdsrvorg,
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    nom             like datmservico.nom,
    vcldes          like datmservico.vcldes,
    vcllicnum       like datmservico.vcllicnum,
    vclanomdl       like datmservico.vclanomdl,
    lgdtxt          char (65),
    lclbrrnom       like datmlcl.lclbrrnom,
    cidnom          like datmlcl.cidnom,
    ufdcod          like datmlcl.ufdcod,
    atddat          like datmservico.atddat,
    atdhor          like datmservico.atdhor,
    vicsnh          like datmservicocmp.vicsnh,
    sindat          like datmservicocmp.sindat,
    sinhor          like datmservicocmp.sinhor,
    c24sintip       like datmservicocmp.c24sintip
 end record

 define param       record
    enviar          char (01),
    faxch1          like datmfax.faxch1,
    faxch2          like datmfax.faxch2,
    dddcod          char (04),
    telnum          dec  (10,0),
    empresa         char (01),
    chassi          char (20)
 end record
 define ws  record
    empresa         char (24),
    sintipdes       char (05)
 end record

 output report to printer
   left   margin  00
   right  margin  80
   top    margin  00
   bottom margin  00
   page   length  58

 format
   on every row

        if param.enviar = "F"   then
           if g_fax = "GSF"  then
              if param.dddcod     > "0099" then
                 print column 001, param.dddcod using "&&&&"; #
              else                                            # Codigo do DDD
                 print column 001, param.dddcod using "&&&";  #
              end if
              if param.telnum > 99999999  then
                 print param.telnum using "&&&&&&&&&";      #
              else                                          #
                 if param.telnum > 9999999  then            # Numero do fax
                    print param.telnum using "&&&&&&&&";    #
                 else                                       #
                    print param.telnum using "&&&&&&&";     #
                 end if
              end if
              if param.empresa = "T" then
                 let ws.empresa = "POLLUS TELEBLOC         "
              else
                if param.empresa  = "I" then
                   let ws.empresa = "ITURAN                "
                end if
                if param.empresa  = "L" then
                   let ws.empresa = "TRACKER DO BRASIL"
                end if
              end if
              print column 001                        ,
              "@"                                     ,  #---> Delimitador
              ws.empresa                              ,  #---> Destinatario Cx pos
              "*CTFU"                                 ,  #---> Sistema/Subsistema
              param.faxch1    using "####&&&&&&"      ,  #---> Numero & Ano Servico
              param.faxch2    using "########&&"      ,  #---> Sequencia
              "@"                                     ,  #---> Delimitador
              ws.empresa                              ,  #---> Destinat.(Informix)
              "@"                                     ,  #---> Delimitador
              "CENTRAL 24 HORAS"                      ,  #---> Quem esta enviando
              "@"                                     ,  #---> Delimitador
              "PORTO.TIF"                             ,  #---> Arquivo Logotipo
              "@"                                     ,  #---> Delimitador
              "semcapa"                                  #---> Nao tem cover page
           end if

           if g_fax = "VSI"  then
              print column 001, "@+IMAGE[porto.tif]"
              skip 7 lines
           end if
        else
           if param.empresa = "T" then
              print column 001, "Enviar para: POLLUS (TELEBLOC) -  Fax: (", param.dddcod clipped, ")", param.telnum using "<<<<<<<&"
           else
              if param.empresa = "I" then
                 print column 001, "Enviar para: ITURAN - Fax: (", param.dddcod clipped, ")", param.telnum using "<<<<<<<&"
              else
                 if param.empresa = "L" then
                    print column 001, "Enviar para: TRACKER DO BRASIL - Fax: ("
                                    , param.dddcod clipped, ")"
                                    , param.telnum using "<<<<<<<<&"
                 end if
              end if
           end if
           skip 2 lines
        end if

        if param.empresa = "T" then
           print column 012, "ACIONAMENTO DE ALARME A DISTANCIA - TELEBLOC"
        else
           if param.empresa = "I" then
              print column 012, "ACIONAMENTO DE ALARME A DISTANCIA - ITURAN"
           else
              if param.empresa = "L" then
                 print column 012, "ACIONAMENTO DE ALARME A DISTANCIA - TRACKER DO BRASIL"
              end if
           end if
        end if
        print column 012, "============================================"
        skip 2 lines

        print column 001, "Placa........: ", r_cts05m02.vcllicnum
        skip 1 line
        if param.empresa = "T" then
           print column 001, "Senha........: ", r_cts05m02.vicsnh
        else
           print column 001, "Chassi.......: ", param.chassi
        end if
        skip 1 lines

        print column 001, "_________________________  DADOS DO FURTO/ROUBO  _________________________"
        skip 1 line
        print column 001, "Numero.......: ",
                                        r_cts05m02.atdsrvorg using "&&",
                                   " ", r_cts05m02.atdsrvnum using "&&&&&&&",
                                   "-", r_cts05m02.atdsrvano using "&&"
        skip 1 lines
        if r_cts05m02.c24sintip is not null then
           if r_cts05m02.c24sintip  = "R" then
              let ws.sintipdes = "ROUBO"
           else
              let ws.sintipdes = "FURTO"
           end if
        end if
        print column 001, "TIPO.........: ", ws.sintipdes
        skip 1 line
        print column 001, "Segurado.....: ", r_cts05m02.nom
        skip 1 line
        print column 001, "Veiculo......: ", r_cts05m02.vcldes
        skip 1 line
        print column 001, "Ano Modelo...: ", r_cts05m02.vclanomdl
        skip 2 lines

        print column 001, "Local Ocorr..: ", r_cts05m02.lgdtxt
        skip 1 line
        print column 001, "Bairro.......: ", r_cts05m02.lclbrrnom
        skip 1 line
        print column 001, "Cidade.......: ", r_cts05m02.cidnom clipped, " - ",
                                             r_cts05m02.ufdcod
        skip 1 line
        print column 001, "Horario Aprox: ", r_cts05m02.sindat;

        if r_cts05m02.sinhor  <>  "00:00"   then
           print column 021, "  as  ",
                 column 027, r_cts05m02.sinhor
        end if
        print column 001, " "

        skip 5 lines
        print column 001, "===> ", r_cts05m02.atddat, " as ", r_cts05m02.atdhor, "  -  CENTRAL 24 HORAS  - (11)3366-3155"

        if param.enviar <> "F" then
           print ascii(12)
        end if

end report  ###  rep_alarme

#RightFax - Inicio
function cts05m02_rep_alarme(r_cts05m02, param, l_docHandle)

 define r_cts05m02  record
    atdsrvorg       like datmservico.atdsrvorg,
    atdsrvnum       like datmservico.atdsrvnum,
    atdsrvano       like datmservico.atdsrvano,
    nom             like datmservico.nom,
    vcldes          like datmservico.vcldes,
    vcllicnum       like datmservico.vcllicnum,
    vclanomdl       like datmservico.vclanomdl,
    lgdtxt          char (65),
    lclbrrnom       like datmlcl.lclbrrnom,
    cidnom          like datmlcl.cidnom,
    ufdcod          like datmlcl.ufdcod,
    atddat          like datmservico.atddat,
    atdhor          like datmservico.atdhor,
    vicsnh          like datmservicocmp.vicsnh,
    sindat          like datmservicocmp.sindat,
    sinhor          like datmservicocmp.sinhor,
    c24sintip       like datmservicocmp.c24sintip
 end record

 define param       record
    enviar          char (01),
    faxch1          like datmfax.faxch1,
    faxch2          like datmfax.faxch2,
    dddcod          char (04),
    telnum          dec  (10,0),
    empresa         char (01),
    chassi          char (20)
 end record
 define ws  record
    empresa         char (24),
    sintipdes       char (05)
 end record

 define l_path               char(500)
       ,l_path2              char(500)
       ,l_path_item          char(500)
       ,l_caminho            char(500)
       ,l_i                  smallint
       ,l_ind                smallint
       ,l_logo               char(200)
       ,l_docHandle          integer
       ,l_cidade_ocorrencia  char(100)

 let l_path = "/report/data/file/cts_alarme"

 let l_caminho = l_path clipped ,"/ddd_fax" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.dddcod clipped)

 let l_caminho = l_path clipped ,"/numero_fax" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.telnum clipped)

 let l_caminho = l_path clipped ,"/nome_empresa" clipped
 if param.empresa = "T" then
    let ws.empresa = "POLLUS TELEBLOC         "
 else
   if param.empresa  = "I" then
      let ws.empresa = "ITURAN                "
   end if
   if param.empresa  = "L" then
      let ws.empresa = "TRACKER DO BRASIL"
   end if
 end if
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws.empresa clipped)

 let l_caminho = l_path clipped ,"/numero_servico_cabecalho" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.faxch1 clipped)

 let l_caminho = l_path clipped ,"/ano_servico_cabecalho" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.faxch2 clipped)

 let l_caminho = l_path clipped ,"/endereco_imagem_logo" clipped
 let l_logo = '\\\\nt112\\jasper3\\atendimento_rightfax\\logo.jpg'
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,l_logo clipped)

 let l_caminho = l_path clipped ,"/placa" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.vcllicnum clipped)

 let l_caminho = l_path clipped ,"/chassi" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.chassi clipped)

 let l_caminho = l_path clipped ,"/origem_servico" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atdsrvorg clipped)

 let l_caminho = l_path clipped ,"/numero_servico_furto_roubo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atdsrvnum clipped)

 let l_caminho = l_path clipped ,"/ano_servico_furto_roubo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atdsrvano clipped)

 let l_caminho = l_path clipped ,"/tipo_sinistro" clipped
 if r_cts05m02.c24sintip is not null then
    if r_cts05m02.c24sintip  = "R" then
       let ws.sintipdes = "ROUBO"
    else
       let ws.sintipdes = "FURTO"
    end if
 end if
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,ws.sintipdes clipped)

 let l_caminho = l_path clipped ,"/nome_segurado" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.nom clipped)

 let l_caminho = l_path clipped ,"/modelo_veiculo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.vcldes clipped)

 let l_caminho = l_path clipped ,"/ano_veiculo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.vclanomdl clipped)

 let l_caminho = l_path clipped ,"/local_ocorrencia" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.lgdtxt clipped)

 let l_caminho = l_path clipped ,"/bairro_ocorrencia" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.lclbrrnom clipped)

 let l_caminho = l_path clipped ,"/cidade_ocorrencia" clipped

 let l_cidade_ocorrencia = r_cts05m02.cidnom clipped, " - ",r_cts05m02.ufdcod clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,l_cidade_ocorrencia clipped)
 let l_caminho = l_path clipped ,"/horario_aproximado" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.sindat clipped)

 end function
 #RightFax - Fim


#--------------------------------------------------------------------------
 function cts05m02_furto(param)
#--------------------------------------------------------------------------

 define param      record
    atdsrvnum      like datmservico.atdsrvnum ,
    atdsrvano      like datmservico.atdsrvano ,
    enviar         char (01)                  ,
    faxcor         char (12)                  ,
    impnom         char (08)
 end record

 define l_dddcod   smallint
       ,l_factxt   dec(10,0)

 define d_cts05m02 record
    cvnnum         like abamapol.cvnnum       ,
    sinvstnum      like datrsrvvstsin.sinvstnum,
    sinvstano      like datrsrvvstsin.sinvstano,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    srvtipdes         like datksrvtip.srvtipdes    ,
    c24solnom         like datmligacao.c24solnom   ,
    c24soltipdes      like datksoltip.c24soltipdes ,
    c24astcod         like datmligacao.c24astcod   ,
    c24astdes         char (60)                    ,
    ligcvntip         like datmligacao.ligcvntip   ,
    ligcvnnom         char (20)                    ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    nom               like datmservico.nom         ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    vcldes            like datmservico.vcldes      ,
    vclcordes         char (15)                    ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcamdes         char (08)                    ,
    vclcrcdsc         like datmservicocmp.vclcrcdsc,
    vclcrgpso         like datmservicocmp.vclcrgpso,
    orrlclidttxt      like datmlcl.lclidttxt       ,
    orrlgdtxt         char (80)                    ,
    orrlclbrrnom      like datmlcl.lclbrrnom       ,
    orrbrrnom         like datmlcl.brrnom          ,
    orrcidnom         like datmlcl.cidnom          ,
    orrufdcod         like datmlcl.ufdcod          ,
    orrlclrefptotxt   like datmlcl.lclrefptotxt    ,
    orrendzon         like datmlcl.endzon          ,
    orrdddcod         like datmlcl.dddcod          ,
    orrlcltelnum      like datmlcl.lcltelnum       ,
    orrlclcttnom      like datmlcl.lclcttnom       ,
    atdrsdtxt         char (03)                    ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    atddfttxt         like datmservico.atddfttxt   ,
    ntzdes            like datksocntz.socntzdes    ,
    boctxt            char (03)                    ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    sinvittxt         char (03)                    ,
    rmcacptxt         char (03)                    ,
    roddantxt         like datmservicocmp.roddantxt,
    asimtvdes         like datkasimtv.asimtvdes    ,
    imdsrvtxt         char (03)                    ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atdlibflg         like datmservico.atdlibflg   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdfunmat         like datmservico.funmat      ,
    atdfunnom         like isskfunc.funnom         ,
    atddptsgl         like isskfunc.dptsgl         ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    cnlfunmat         like datmservico.c24opemat   ,
    cnlfunnom         like isskfunc.funnom         ,
    cnldptsgl         like isskfunc.dptsgl         ,
    atdprscod         like datmservico.atdprscod   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdmotnom         like datmservico.atdmotnom   ,
    srrcoddig         like datmservico.srrcoddig   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    socvclcod         like datmservico.socvclcod   ,
    pgtdat            like datmservico.pgtdat      ,
    atdcstvlr         like datmservico.atdcstvlr   ,
    avsfurtxt         char (30)                    ,
    atddocflg         char (03)                    ,
    atddoctxt         like datmservico.atddoctxt   ,
    atddmccidnom      like datmassistpassag.atddmccidnom,
    atddmcufdcod      like datmassistpassag.atddmcufdcod,
    srvprlflg         like datmservico.srvprlflg
 end record

 define ws          record
    cornom          like gcakcorr.cornom      ,
    destin          char (24)                 ,
    faxch1          like datmfax.faxch1       ,
    faxch2          like datmfax.faxch2       ,
    envflg          dec (1,0),
    impflg            smallint                       ,
    impnom            char (08)                      ,
    lignum            like datrligsrv.lignum         ,
    c24soltipcod      like datmligacao.c24soltipcod  ,
    vclcorcod         like datmservico.vclcorcod     ,
    atdrsdflg         like datmservico.atdrsdflg     ,
    asitipcod         like datmservico.asitipcod     ,
    vclcamtip         like datmservicocmp.vclcamtip  ,
    bocflg            like datmservicocmp.bocflg     ,
    sinvitflg         like datmservicocmp.sinvitflg  ,
    rmcacpflg         like datmservicocmp.rmcacpflg  ,
    atdlclflg         like datmservico.atdlclflg     ,
    socntzcod         like datmsrvre.socntzcod       ,
    sinntzcod         like datmsrvre.sinntzcod       ,
    c24sintip         like datmservicocmp.c24sintip  ,
    c24sinhor         like datmservicocmp.c24sinhor  ,
    lgdtip            like datmlcl.lgdtip            ,
    lgdnom            like datmlcl.lgdnom            ,
    lgdnum            like datmlcl.lgdnum            ,
    lgdcep            like datmlcl.lgdcep            ,
    lgdcepcmp         like datmlcl.lgdcepcmp         ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod      ,
    sqlcode           integer                        ,
    endcmp            like datmlcl.endcmp
 end record

 #RightFax - inicio
 define lr_param         record
        service            char(10)
       ,serviceType        char(10)
       ,typeOfConnection   char(3)
       ,fileSystem         char(100)
       ,jasperFileName     char(50)
       ,outFileName        char(100)
       ,outFileType        char(3)
       ,recordPath         char(100)
       ,aplicacao          char(30)
       ,outbox             char(100)
       ,generatorTIFF      smallint
 end record

 define l_hora            datetime hour to second
 define l_nomexml         char(200)
 define w_conta           smallint
 define l_tamanhoFax        smallint

 define lr_param_out      record
          codigo            smallint
        , mensagem          char(200)
 end    record

 define lr_fax             record
          ddd                char(3)
         ,telefone           char(16)
         ,destinatario 	     char(30)
         ,notas              char(30)
         ,caminhoarq         char(100)
         ,sistema            char(100)
         ,geratif            smallint
 end record

 #RightFax - Fim

 #---------------------------------------------------------------
 # Inicializacao das variaveis
 #---------------------------------------------------------------


        initialize  d_cts05m02.*  to  null

        initialize  ws.*  to  null

 initialize d_cts05m02.*  to null
 let ws.envflg = false
 let g_traco = "--------------------------------------------------------------------------------"

 #--------------------------------------------------------------------
 # Informacoes do servico
 #--------------------------------------------------------------------
 select datmservico.atdsrvnum   , datmservico.atdsrvano   ,
        datmservico.atdsrvorg   ,
        datmservico.nom         , datmservico.corsus      ,
        datmservico.cornom      , datmservico.vcldes      ,
        datmservico.vclcorcod   , datmservico.vcllicnum   ,
        datmservico.vclanomdl   , datmservicocmp.vclcamtip,
        datmservicocmp.vclcrcdsc, datmservicocmp.vclcrgpso,
        datmservico.atdrsdflg   , datmservico.asitipcod   ,
        datmservico.atddfttxt   , datmservicocmp.bocflg   ,
        datmservicocmp.bocnum   , datmservicocmp.bocemi   ,
        datmservicocmp.sindat   , datmservicocmp.sinhor   ,
        datmservicocmp.sinvitflg, datmservicocmp.rmcacpflg,
        datmservicocmp.roddantxt, datmservico.atdhorpvt   ,
        datmservico.atddatprg   , datmservico.atdhorprg   ,
        datmservico.atdlibdat   , datmservico.atdlibhor   ,
        datmservico.atdlibflg   , datmservico.atddat      ,
        datmservico.atdhor      , datmservico.funmat      ,
        datmservico.cnldat      , datmservico.atdfnlhor   ,
        datmservico.c24opemat   , datmservico.atdprscod   ,
        datmservico.c24nomctt   , datmservico.atdmotnom   ,
        datmservico.atdvclsgl   , datmservico.socvclcod   ,
        datmservico.pgtdat      , datmservico.atdcstvlr   ,
        datmservico.atddoctxt   , datmservicocmp.c24sintip,
        datmservicocmp.c24sinhor, datmservico.atdlclflg   ,
        datmservico.srvprlflg   , datmservico.srrcoddig
   into d_cts05m02.atdsrvnum    , d_cts05m02.atdsrvano    ,
        d_cts05m02.atdsrvorg    ,
        d_cts05m02.nom          , d_cts05m02.corsus       ,
        d_cts05m02.cornom       , d_cts05m02.vcldes       ,
        ws.vclcorcod            , d_cts05m02.vcllicnum    ,
        d_cts05m02.vclanomdl    , ws.vclcamtip            ,
        d_cts05m02.vclcrcdsc    , d_cts05m02.vclcrgpso    ,
        ws.atdrsdflg            , ws.asitipcod            ,
        d_cts05m02.atddfttxt    , ws.bocflg               ,
        d_cts05m02.bocnum       , d_cts05m02.bocemi       ,
        d_cts05m02.sindat       , d_cts05m02.sinhor       ,
        ws.sinvitflg            , ws.rmcacpflg            ,
        d_cts05m02.roddantxt    , d_cts05m02.atdhorpvt    ,
        d_cts05m02.atddatprg    , d_cts05m02.atdhorprg    ,
        d_cts05m02.atdlibdat    , d_cts05m02.atdlibhor    ,
        d_cts05m02.atdlibflg    , d_cts05m02.atddat       ,
        d_cts05m02.atdhor       , d_cts05m02.atdfunmat    ,
        d_cts05m02.cnldat       , d_cts05m02.atdfnlhor    ,
        d_cts05m02.cnlfunmat    , d_cts05m02.atdprscod    ,
        d_cts05m02.c24nomctt    , d_cts05m02.atdmotnom    ,
        d_cts05m02.atdvclsgl    , d_cts05m02.socvclcod    ,
        d_cts05m02.pgtdat       , d_cts05m02.atdcstvlr    ,
        d_cts05m02.atddoctxt    , ws.c24sintip            ,
        ws.c24sinhor            , ws.atdlclflg            ,
        d_cts05m02.srvprlflg    , d_cts05m02.srrcoddig
   from datmservico, outer datmservicocmp
  where datmservico.atdsrvnum    = param.atdsrvnum
    and datmservico.atdsrvano    = param.atdsrvano
    and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
    and datmservicocmp.atdsrvano = datmservico.atdsrvano

 #--------------------------------------------------------------------
 # Informacoes do local da ocorrencia
 #--------------------------------------------------------------------
 call ctx04g00_local_completo(param.atdsrvnum,
                              param.atdsrvano,
                              1)
                    returning d_cts05m02.orrlclidttxt   ,
                              ws.lgdtip                 ,
                              ws.lgdnom                 ,
                              ws.lgdnum                 ,
                              d_cts05m02.orrlclbrrnom   ,
                              d_cts05m02.orrbrrnom      ,
                              d_cts05m02.orrcidnom      ,
                              d_cts05m02.orrufdcod      ,
                              d_cts05m02.orrlclrefptotxt,
                              d_cts05m02.orrendzon      ,
                              ws.lgdcep                 ,
                              ws.lgdcepcmp              ,
                              d_cts05m02.orrdddcod      ,
                              d_cts05m02.orrlcltelnum   ,
                              d_cts05m02.orrlclcttnom   ,
                              ws.c24lclpdrcod           ,
                              ws.sqlcode                ,
                              ws.endcmp
 # PSI 244589 - Inclusão de Sub-Bairro - Burini
 call cts06g10_monta_brr_subbrr(d_cts05m02.orrbrrnom,
                                d_cts05m02.orrlclbrrnom)
      returning d_cts05m02.orrlclbrrnom

 let d_cts05m02.orrlgdtxt = ws.lgdtip clipped, " ",
                            ws.lgdnom clipped, " ",
                            ws.lgdnum using "<<<<#", " ",
                            ws.endcmp clipped

 #---------------------------------------------------------------
 # Documento de referencia
 #---------------------------------------------------------------
 select ramcod   , succod   ,
        aplnumdig, itmnumdig
   into d_cts05m02.ramcod   ,
        d_cts05m02.succod   ,
        d_cts05m02.aplnumdig,
        d_cts05m02.itmnumdig
   from datrservapol
  where atdsrvnum = d_cts05m02.atdsrvnum  and
        atdsrvano = d_cts05m02.atdsrvano

 #---------------------------------------------------------------
 # Dados da ligacao
 #---------------------------------------------------------------
 let ws.lignum = cts20g00_servico(d_cts05m02.atdsrvnum, d_cts05m02.atdsrvano)

 select c24solnom, c24soltipcod,
        c24astcod, ligcvntip
   into d_cts05m02.c24solnom,
        ws.c24soltipcod     ,
        d_cts05m02.c24astcod,
        d_cts05m02.ligcvntip
   from datmligacao
  where lignum = ws.lignum

 call c24geral8(d_cts05m02.c24astcod)
      returning d_cts05m02.c24astdes

 let d_cts05m02.ligcvnnom = "** NAO CADASTRADO **"

 select cpodes
   into d_cts05m02.ligcvnnom
   from datkdominio
  where cponom = "ligcvntip"  and
        cpocod = d_cts05m02.ligcvntip

 select c24soltipdes
   into d_cts05m02.c24soltipdes
   from datksoltip
        where c24soltipcod = ws.c24soltipcod

 #---------------------------------------------------------------
 # Telefone do segurado
 #---------------------------------------------------------------
 call cts09g00(d_cts05m02.ramcod,
               d_cts05m02.succod,
               d_cts05m02.aplnumdig,
               d_cts05m02.itmnumdig,
               false)
     returning d_cts05m02.dddcod,
               d_cts05m02.teltxt

 #---------------------------------------------------------------
 # Cor do veiculo
 #---------------------------------------------------------------
 select cpodes
   into d_cts05m02.vclcordes
   from iddkdominio
  where cponom = "vclcorcod"  and
        cpocod = ws.vclcorcod

 let d_cts05m02.vclcordes = upshift(d_cts05m02.vclcordes)

 if ws.atdrsdflg is not null  then
   if ws.atdrsdflg = "S"  then
      let d_cts05m02.atdrsdtxt = "SIM"
   else
      let d_cts05m02.atdrsdtxt = "NAO"
   end if
 end if

 #---------------------------------------------------------------
 # Tipo do atendimento
 #---------------------------------------------------------------
 select srvtipdes
   into d_cts05m02.srvtipdes
   from datksrvtip
  where atdsrvorg = d_cts05m02.atdsrvorg

 select asitipabvdes
   into d_cts05m02.asitipabvdes
   from datkasitip
  where asitipcod = ws.asitipcod

 if ws.bocflg is not null  then
    if ws.bocflg = "S"  then
       let d_cts05m02.boctxt = "SIM"
    else
       let d_cts05m02.boctxt = "NAO"
    end if
 end if

 if ws.sinvitflg is not null  then
    if ws.sinvitflg = "S"  then
       let d_cts05m02.sinvittxt = "SIM"
    else
       let d_cts05m02.sinvittxt = "NAO"
    end if
 end if

 if ws.rmcacpflg is not null  then
    if ws.rmcacpflg = "S"  then
       let d_cts05m02.rmcacptxt = "SIM"
    else
       let d_cts05m02.rmcacptxt = "NAO"
    end if
 end if

 case ws.vclcamtip
    when 1  let d_cts05m02.vclcamdes = "TRUCK"
    when 2  let d_cts05m02.vclcamdes = "TOCO"
    when 3  let d_cts05m02.vclcamdes = "CARRETA"
 end case

 case ws.c24sintip
    when "F"  let d_cts05m02.avsfurtxt  = "FURTO"
    when "R"  let d_cts05m02.avsfurtxt  = "ROUBO"
 end case

 let d_cts05m02.avsfurtxt = d_cts05m02.avsfurtxt clipped, " OCORRIDO"

 case ws.c24sinhor
    when "D"  let d_cts05m02.avsfurtxt = d_cts05m02.avsfurtxt clipped,
                                         " DURANTE O DIA"
    when "N"  let d_cts05m02.avsfurtxt = d_cts05m02.avsfurtxt clipped,
                                         " DURANTE A NOITE"
    otherwise let d_cts05m02.avsfurtxt = d_cts05m02.avsfurtxt clipped,
                                         " AS ", d_cts05m02.sinhor
 end case

 if d_cts05m02.atdhorpvt is not null  or
    d_cts05m02.atdhorpvt  = "00:00"   then
    let d_cts05m02.imdsrvtxt = "SIM"
 end if

 if d_cts05m02.atddatprg is not null  then
    let d_cts05m02.imdsrvtxt = "NAO"
 end if

 if ws.atdlclflg = "S"  then
    let d_cts05m02.atddocflg = "SIM"
 else
    let d_cts05m02.atddocflg = "NAO"
 end if


######################

    select cvnnum into d_cts05m02.cvnnum
      from abamapol
     where succod    = d_cts05m02.succod
       and aplnumdig = d_cts05m02.aplnumdig

    if d_cts05m02.cvnnum  is null   then
       let d_cts05m02.cvnnum  =  0
    end if

    select sinvstnum,
           sinvstano
      into d_cts05m02.sinvstnum,
           d_cts05m02.sinvstano
      from DATRSRVVSTSIN
           where atdsrvnum = param.atdsrvnum
             and atdsrvano = param.atdsrvano

    if  sqlca.sqlcode <> 0  then
        initialize d_cts05m02.sinvstnum to null
        initialize d_cts05m02.sinvstano to null
    end if


 initialize d_cts05m02.cornom   to null

 select cornom into d_cts05m02.cornom
   from gcaksusep, gcakcorr
  where gcaksusep.corsus   = d_cts05m02.corsus  and
        gcakcorr.corsuspcp = gcaksusep.corsuspcp

 let ws.destin = d_cts05m02.cornom clipped

 if param.enviar  =  "F" or
    param.enviar  =  "A"  then
    call cts10g01_enviofax(param.atdsrvnum, param.atdsrvano,
                           "", "FU", g_issk.funmat)
                 returning ws.envflg, ws.faxch1, ws.faxch2

    if g_fax = "GSF"  then
       if g_outFigrc012.Is_Teste then #ambnovo
          let param.impnom = "tstclfax"
       else
          let param.impnom = "furtofax"
       end if
       let g_pipe = "lp -sd ", param.impnom
    else
       let g_pipe ="rcts05m0201"
       #let g_pipe = "vfxCTFU ", param.faxcor clipped, " ", ascii 34, ws.destin clipped, ascii 34, " ", ws.faxch1 using "&&&&&&&&&&", " ", ws.faxch2 using "&&&&&&&&&&"
    end if
 else
    if param.enviar = "I" then
       let ws.envflg = true
       let g_pipe = "lp -sd ", param.impnom
    else
       if param.enviar = "E" then
          call cts10g01_enviofax(param.atdsrvnum, param.atdsrvano,
                              "", "FU", g_issk.funmat)
                    returning ws.envflg, ws.faxch1, ws.faxch2

          let ws.envflg = true
          let g_pipe = "rcts05m0201"
       end if
    end if
 end if

 if ws.envflg = true  then
   if param.enviar = "A" then
      let param.enviar = "F"

      #RightFax - Inicio
      let lr_param.service          = 'cts05m02.4gl'
      let lr_param.serviceType      = 'GENERATOR'
      let lr_param.typeOfConnection = 'xml'
      let lr_param.fileSystem       = '\\\\nt112\\jasper3\\atendimento_rightfax\\jaspers\\'
      let lr_param.jasperFileName   = 'cts_furto.jasper'
      let l_hora                    =  current
      let lr_param.outFileName      = 'furto'
      let lr_param.outFileType      = 'pdf'
      let lr_param.recordPath       = '/report/data/file/cts_furto'
      let lr_param.aplicacao        = 'cts05m02.4gl'
      let lr_param.outbox           = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\'
      let lr_param.generatorTIFF    = false
      let l_nomexml                 = 'cts05m02'
      call cty35g00_monta_estrutura_jasper(lr_param.*,l_nomexml)
          returning l_docHandle

      call cts05m02_rep_furto(d_cts05m02.*
                            , param.enviar
                            , ws.faxch1
                            , ws.faxch2
                            , param.faxcor
                            , ws.destin
                            , l_docHandle)

         let l_tamanhoFax = length(param.faxcor)
         if l_tamanhoFax > 8 then
             let l_dddcod = param.faxcor[1,3]
             let l_factxt = param.faxcor[4,11]
         else
             let l_dddcod = 011
             let l_factxt = param.faxcor
         end if

         let lr_fax.ddd           = l_dddcod
         let lr_fax.telefone      = l_factxt
         let lr_fax.notas         = ''
         let lr_fax.caminhoarq    = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\',lr_param.outFileName,'.pdf'
         let lr_fax.sistema       = 'lmd681'
         let lr_fax.geratif       = false

         call cty35g00_envia_fax(l_docHandle,lr_fax.*)
         returning lr_param_out.codigo, lr_param_out.mensagem

         if lr_param_out.codigo = 0 then
            display "Fax enviado com sucesso"
         end if

      #RightFax - Fim

      start report rep_furto to pipe g_pipe
      output to report rep_furto(d_cts05m02.*, param.enviar,
                                 ws.faxch1   , ws.faxch2,
                                 param.faxcor, ws.destin)

      finish report  rep_furto
      let param.enviar = "E"
      let g_pipe = "./rcts05m0201"
      start report rep_furto to g_pipe
      output to report rep_furto(d_cts05m02.*, param.enviar,
                                 ws.faxch1   , ws.faxch2,
                                 param.faxcor, ws.destin)

      finish report  rep_furto
   else
    if param.enviar = "F" then
 #RightFax - Inicio
      let lr_param.service          = 'cts05m02.4gl'
      let lr_param.serviceType      = 'GENERATOR'
      let lr_param.typeOfConnection = 'xml'
      let lr_param.fileSystem       = '\\\\nt112\\jasper3\\atendimento_rightfax\\jaspers\\'
      let lr_param.jasperFileName   = 'cts_furto.jasper'
      let l_hora                    =  current
      let lr_param.outFileName      = 'furto'
      let lr_param.outFileType      = 'pdf'
      let lr_param.recordPath       = '/report/data/file/cts_furto'
      let lr_param.aplicacao        = 'cts05m02.4gl'
      let lr_param.outbox           = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\'
      let lr_param.generatorTIFF    = false
      let l_nomexml                 = 'cts05m02'
      call cty35g00_monta_estrutura_jasper(lr_param.*,l_nomexml)
          returning l_docHandle

      call cts05m02_rep_furto(d_cts05m02.*
                            , param.enviar
                            , ws.faxch1
                            , ws.faxch2
                            , param.faxcor
                            , ws.destin
                            , l_docHandle)

         let l_tamanhoFax = length(param.faxcor)
         if l_tamanhoFax > 8 then
             let l_dddcod = param.faxcor[1,3]
             let l_factxt = param.faxcor[4,11]
         else
             let l_dddcod = 011
             let l_factxt = param.faxcor
         end if

         let lr_fax.ddd           = l_dddcod
         let lr_fax.telefone      = l_factxt
         let lr_fax.notas         = ''
         let lr_fax.caminhoarq    = '\\\\nt112\\jasper3\\atendimento_rightfax\\pdf\\',lr_param.outFileName,'.pdf'
         let lr_fax.sistema       = 'lmd681'
         let lr_fax.geratif       = false

         call cty35g00_envia_fax(l_docHandle,lr_fax.*)
         returning lr_param_out.codigo, lr_param_out.mensagem

         if lr_param_out.codigo = 0 then
            display "Fax enviado com sucesso"
         end if


      #RightFax - Fim
    end if

    if param.enviar = "E" then
       start report rep_furto to g_pipe
    else
       start report rep_furto to g_pipe
    end if

    output to report rep_furto(d_cts05m02.*, param.enviar,
                               ws.faxch1   , ws.faxch2,
                               param.faxcor, ws.destin)

    finish report  rep_furto
   end if
 end if

end function  ###  cts05m02_furto


#---------------------------------------------------------------------------
 report rep_furto(r_cts05m02, param)  ### FAX PARA CORRETOR
#---------------------------------------------------------------------------

 define r_cts05m02 record
    cvnnum         like abamapol.cvnnum       ,
    sinvstnum      like datrsrvvstsin.sinvstnum,
    sinvstano      like datrsrvvstsin.sinvstano,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    srvtipdes         like datksrvtip.srvtipdes    ,
    c24solnom         like datmligacao.c24solnom   ,
    c24soltipdes      like datksoltip.c24soltipdes ,
    c24astcod         like datmligacao.c24astcod   ,
    c24astdes         char (60)                    ,
    ligcvntip         like datmligacao.ligcvntip   ,
    ligcvnnom         char (20)                    ,
    ramcod            like datrservapol.ramcod     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    nom               like datmservico.nom         ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    corsus            like datmservico.corsus      ,
    cornom            like datmservico.cornom      ,
    vcldes            like datmservico.vcldes      ,
    vclcordes         char (15)                    ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcamdes         char (08)                    ,
    vclcrcdsc         like datmservicocmp.vclcrcdsc,
    vclcrgpso         like datmservicocmp.vclcrgpso,
    orrlclidttxt      like datmlcl.lclidttxt       ,
    orrlgdtxt         char (65)                    ,
    orrlclbrrnom      like datmlcl.lclbrrnom       ,
    orrbrrnom         like datmlcl.brrnom          ,
    orrcidnom         like datmlcl.cidnom          ,
    orrufdcod         like datmlcl.ufdcod          ,
    orrlclrefptotxt   like datmlcl.lclrefptotxt    ,
    orrendzon         like datmlcl.endzon          ,
    orrdddcod         like datmlcl.dddcod          ,
    orrlcltelnum      like datmlcl.lcltelnum       ,
    orrlclcttnom      like datmlcl.lclcttnom       ,
    atdrsdtxt         char (03)                    ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    atddfttxt         like datmservico.atddfttxt   ,
    ntzdes            like datksocntz.socntzdes    ,
    boctxt            char (03)                    ,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    sindat            like datmservicocmp.sindat   ,
    sinhor            like datmservicocmp.sinhor   ,
    sinvittxt         char (03)                    ,
    rmcacptxt         char (03)                    ,
    roddantxt         like datmservicocmp.roddantxt,
    asimtvdes         like datkasimtv.asimtvdes    ,
    imdsrvtxt         char (03)                    ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    atdlibdat         like datmservico.atdlibdat   ,
    atdlibhor         like datmservico.atdlibhor   ,
    atdlibflg         like datmservico.atdlibflg   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    atdfunmat         like datmservico.funmat      ,
    atdfunnom         like isskfunc.funnom         ,
    atddptsgl         like isskfunc.dptsgl         ,
    cnldat            like datmservico.cnldat      ,
    atdfnlhor         like datmservico.atdfnlhor   ,
    cnlfunmat         like datmservico.c24opemat   ,
    cnlfunnom         like isskfunc.funnom         ,
    cnldptsgl         like isskfunc.dptsgl         ,
    atdprscod         like datmservico.atdprscod   ,
    c24nomctt         like datmservico.c24nomctt   ,
    atdmotnom         like datmservico.atdmotnom   ,
    srrcoddig         like datmservico.srrcoddig   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    socvclcod         like datmservico.socvclcod   ,
    pgtdat            like datmservico.pgtdat      ,
    atdcstvlr         like datmservico.atdcstvlr   ,
    avsfurtxt         char (30)                    ,
    atddocflg         char (03)                    ,
    atddoctxt         like datmservico.atddoctxt   ,
    atddmccidnom      like datmassistpassag.atddmccidnom,
    atddmcufdcod      like datmassistpassag.atddmcufdcod,
    srvprlflg         like datmservico.srvprlflg
 end record

 define param         record
    enviar            char (01)                  ,
    faxch1            like datmfax.faxch1        ,
    faxch2            like datmfax.faxch2        ,
    faxcor            char (15)                  ,
    destin            char (24)
 end record

 define h_ctr03m02  record
    ligdat          like datmservhist.ligdat     ,
    lighorinc       like datmservhist.lighorinc  ,
    c24funmat       like datmservhist.c24funmat  ,
    c24srvdsc       like datmservhist.c24srvdsc  ,
    c24empcod       like datmservhist.c24empcod                       #Raul, Biz
 end record

 define ws          record
    logotipo          char (13)                 ,
    dddcod            like sgkkarea.dddcod      ,
    faxnum            like sgkkarea.faxnum      ,
    faxresnom         like sgkkarea.faxresnom   ,
    sinvstnumchar     char (06)                 ,
    cvnflg            char (01),
    funnom          like isskfunc.funnom         ,
    lintxt          like datmservhist.c24srvdsc  ,
    pasnom          like datmpassageiro.pasnom   ,
    pasidd          like datmpassageiro.pasidd   ,
    avlitmcod       like datrpesqaval.avlitmcod  ,
    avlpsqnot       like datrpesqaval.avlpsqnot  ,
    ligdatant       like datmservhist.ligdat     ,
    lighorant       like datmservhist.lighorinc  ,
    vclcoddig       like datkveiculo.vclcoddig   ,
    srrabvnom       like datksrr.srrabvnom       ,
    vcldes          char (58)
 end record

# renato
define i            smallint
define w_pgtrsptrmtxt   like ssakpgtrsptrm.pgtrsptrmtxt
define l_mnscod         like ssatprcanlmns.mnscod
define l_mnsdes         like ssatprcanlmns.mnsdes
define l_sindcttip      like ssakprcanldct.sindcttip
define l_sindctcod      like ssakprcanldct.sindctcod
define l_sindcttxt1     like sgakdoc.sindcttxt1
define l_sindcttxt2     like sgakdoc.sindcttxt2

define pr_perfil  record
       avsrbfsegvitflg     char(01),
       rbfsegult24mesflg   char(01),
       avsrbfsegqtd        smallint,
       avsgrgveisegrsdflg  char(01),
       avsgrgveisegtrbflg  char(01),
       avsgrgveisegcfgflg  char(01),
       avsrbfnaotrbflg     char(01),
       avsrbfnaocfgflg     char(01),
       avsnaoinfflg        char(01),
       avsrbfvitantinf     char(01),
       avsrbfvitqtd        smallint

end record
define w_vclsitatu     like        abbmitem.autsitatu,
       w_autsitatu     like        abbmitem.autsitatu,
       w_dmtsitatu     like        abbmitem.autsitatu,
       w_dpssitatu     like        abbmitem.autsitatu,
       w_appsitatu     like        abbmitem.autsitatu,
       w_vidsitatu     like        abbmitem.autsitatu,
       sdstatus        integer,
       sddctnumseq     like abbmcasco.dctnumseq,
       w_result        char(01)
define w_dctnumseq     like        abbmitem.autsitatu
define w_edsnumref     like        ssamsin.edsnumref

 output report to printer
   left   margin  00
   right  margin  80
   top    margin  00
   bottom margin  00
   page   length  58

 format
   on every row
      #-----------------------------------------------------------
      # Seleciona logotipo conforme convenio da apolice
      #-----------------------------------------------------------
      initialize ws.dddcod     to null
      initialize ws.faxnum     to null
      initialize ws.faxresnom  to null
      initialize ws.logotipo   to null
      let ws.cvnflg            =  "S"
      let ws.sinvstnumchar = r_cts05m02.sinvstnum  using "&&&&&&"

      case r_cts05m02.cvnnum
         when  2    let ws.logotipo = "RURAL.TIF"
         when  3    let ws.logotipo = "SAFRA.TIF"
         when  5    let ws.logotipo = "BCOBRAS.TIF"
         when  7    let ws.logotipo = "BCN.TIF"
         when  8    let ws.logotipo = "MALUCELI.TIF"
         when  9    let ws.logotipo = "BMC.TIF"
         when 10    let ws.logotipo = "ITACOLOMI.TIF"
         when 13    let ws.logotipo = "CENTAURO.TIF"
         when 14    let ws.logotipo = "CITIAUTO.TIF"
         when 15    let ws.logotipo = "BANESPA.TIF"
         when 21    let ws.logotipo = "ROMA.TIF"
         when 22    let ws.logotipo = "GBOEX.TIF"
         when 23    let ws.logotipo = "UNITED.TIF"
         when 24    let ws.logotipo = "SAOEX.TIF"
         when 26    let ws.logotipo = "BBV.TIF"
         when 27    let ws.logotipo = "AUTOVR.TIF"
         when 28    let ws.logotipo = "MARTINEL.TIF"
         when 29    let ws.logotipo = "BBC.TIF"
         when 31    let ws.logotipo = "MERION.TIF"
         when 32    let ws.logotipo = "BMART.TIF"
         when 33    let ws.logotipo = "GOLDEN.TIF"
         when 37    let ws.logotipo = "PHENIX.TIF"
         when 43    let ws.logotipo = "CITROEN.TIF"
         when 44    let ws.logotipo = "ZOGBI.TIF"
         when 45    let ws.logotipo = "INTERATLA.TIF"
         when 48    let ws.logotipo = "PACTUAL.TIF"
         when 54    let ws.logotipo = "BIC.TIF"
         when 58    let ws.logotipo = "BOAVISTA.TIF"
         when 61    let ws.logotipo = "SANTANDER.TIF"

         otherwise  let ws.logotipo = "PORTO.TIF"
                    let ws.cvnflg = "N"
      end case

#     call funfaxcel(1, ws.sinvstnumchar[6,6], ws.cvnflg)
#          returning ws.dddcod, ws.faxnum, ws.faxresnom

      if ws.faxnum  is null or
         ws.faxnum   = 0    then
         let ws.dddcod = "011"
         let ws.faxnum = 33665669
      end if

      if param.enviar = "F"   then
         if g_fax = "GSF"  then
            #------------------------------------------------------
            # Checa caracteres invalidos para o GSFAX
            #------------------------------------------------------
            call cts02g00(param.destin)  returning param.destin

               if param.faxcor[1,1] = "0"  and
                  param.faxcor[2,2] = "0"  then
                  let param.faxcor = param.faxcor[2,15]
               end if

               print column 001, param.faxcor clipped;

               print "@"                             , #---> Delimitador
               param.destin                          , #---> Destin. Cx. Postal
               "*CTFU"                               , #---> Sistema/Subsistema
               param.faxch1   using "&&&&&&&&&&"     , #---> Numero Servico
               param.faxch2   using "&&&&&&&&&&"     , #---> Ano Servico
               "@"                                   , #---> Delimitador
               param.destin                          , #---> Destinat.(Informix)
               "@"                                   , #---> Delimitador
               "CENTRAL 24 HORAS"                    , #---> Quem esta enviando
               "@"                                   , #---> Delimitador
               ws.logotipo  clipped                  , #---> Arquivo Logotipo
               "@"                                   , #---> Delimitador
               "semcapa"                               #---> Nao tem cover page
         end if

         if g_fax = "VSI"  then
            print column 001, ascii 27, "&l00E";       #--> Logo no topo
            print "@+IMAGE[", downshift(ws.logotipo) clipped, ";x=0cm;y=0cm]"
            skip 5 lines
         end if
      else
         print column 001, "Enviar para: ", param.destin clipped, " - FAX: ", param.faxcor
         skip 2 lines
      end if

      print column 015, "AVISO DE FURTO OU ROUBO","  EM ",
                        r_cts05m02.atddat, " AS ", r_cts05m02.atdhor
      print column 015, "-----------------------------------------------"
      skip 2 lines
      print column 001, "A ", r_cts05m02.cornom clipped, " - ", r_cts05m02.corsus
      skip 1 lines
      print column 001, "Segurado.: ", r_cts05m02.nom
      print column 001, "Veiculo..: ", r_cts05m02.vcldes
      print column 001, "Placa....: ", r_cts05m02.vcllicnum
      print column 001, "Documento: ", r_cts05m02.succod    using "<<<&&",#"&&"      , projeto succod
                                  "/", r_cts05m02.ramcod    using "##&&"    ,
                                  "/", r_cts05m02.aplnumdig using "<<<<<<<& &",
                                  "/", r_cts05m02.itmnumdig using "<<<<<& &"
      print column 001, "Vistoria.: ", r_cts05m02.sinvstnum using "###&&&",
                                  "-", r_cts05m02.sinvstano
      skip 2 line

#######################################################################LAUDO
       print column 001, "SERVICO..: ", r_cts05m02.atdsrvorg using "&&",
                                   "/", r_cts05m02.atdsrvnum using "&&&&&&&",
                                   "-", r_cts05m02.atdsrvano using "&&";

       if r_cts05m02.srvprlflg = "S"  then
          print column 025, "(PARTICULAR)";
       end if
       print column 041, "TIPO....: " , r_cts05m02.srvtipdes
       print column 001, "ASSUNTO..: ", r_cts05m02.c24astcod,
                          " - "       , r_cts05m02.c24astdes
       print column 001, "CONVENIO.: ", r_cts05m02.ligcvntip using "##&",
                         " - "        , r_cts05m02.ligcvnnom
       print column 001, g_traco

       print column 001, "DOCUMENTO: ";
       if r_cts05m02.ramcod    is null  or
          r_cts05m02.succod    is null  or
          r_cts05m02.aplnumdig is null  then
          print "*** NAO INFORMADO ***"
       else
          print r_cts05m02.succod    using "<<<&&"     , "/", #"&&"        , "/", projeto succod
                r_cts05m02.ramcod    using "##&&"      , "/",
                r_cts05m02.aplnumdig using "<<<<<<<& &";
          if r_cts05m02.itmnumdig <> 0  then
             print "/", r_cts05m02.itmnumdig using "<<<<<<& &"
          else
             print ""
          end if
       end if
       print column 001, "SOLICIT..: ", r_cts05m02.c24solnom,
             column 059, "TIPO..: "   , r_cts05m02.c24soltipdes
       print column 001, "SEGURADO.: ", r_cts05m02.nom
       print column 001, "TELEFONE.: ", "(", r_cts05m02.dddcod, ") ", r_cts05m02.teltxt
       print column 001, "CORRETOR.: ", r_cts05m02.corsus, " - ",
                                        r_cts05m02.cornom
       print column 001, g_traco

       if r_cts05m02.vcldes is not null  then
          print column 001, "VEICULO..: ", r_cts05m02.vcldes,
                column 059, "COR...: ",    r_cts05m02.vclcordes

          if r_cts05m02.vclcamdes is not null  then
             print column 001, "TIPO.....: ", r_cts05m02.vclcamdes;

             if r_cts05m02.vclcrcdsc is not null  then
                print column 021, "CARROCERIA: ", r_cts05m02.vclcrcdsc;
             end if

             if r_cts05m02.vclcrgpso is not null  then
                print column 053, "PESO..: ", r_cts05m02.vclcrgpso using "###,###", " KG"
             else
                print ""
             end if
          end if

          print column 001, "ANO MOD..: ", r_cts05m02.vclanomdl,
                column 059, "PLACA.: "   , r_cts05m02.vcllicnum
          print column 001, g_traco
       end if

       #---------------------------------------------------------------
       # Impressao dos dados referentes ao local da ocorrencia
       #---------------------------------------------------------------
       if r_cts05m02.orrlclidttxt  is not null  then
          print column 001, "LOCAL....: " , r_cts05m02.orrlclidttxt
       end if

       print column 001, "ENDERECO.: ", r_cts05m02.orrlgdtxt
       print column 001, "BAIRRO...: ", r_cts05m02.orrlclbrrnom
       print column 001, "CIDADE...: ", r_cts05m02.orrcidnom,
             column 059, "UF....: "   , r_cts05m02.orrufdcod
       print column 001, "REFERENC.: ", r_cts05m02.orrlclrefptotxt[1,40],
             column 059, "ZONA..: "   , r_cts05m02.orrendzon
       print column 001, "TELEFONE.: ", "(", r_cts05m02.orrdddcod, ") ",
                                        r_cts05m02.orrlcltelnum
       print column 001, "RESPONS..: ", r_cts05m02.orrlclcttnom

       #---------------------------------------------------------------
       # Impressao de dados especificos de ROUBO/FURTO
       #---------------------------------------------------------------
       if r_cts05m02.atdsrvorg = 11  then
          if r_cts05m02.boctxt is not null  then
             print column 001, "B.O.? ...: " , r_cts05m02.boctxt,
                   column 025, "B.O. No...: ", r_cts05m02.bocnum using "<<<<&",
                   column 059, "ORGAO.: "    , r_cts05m02.bocemi
          end if

          print column 001, "OCORRENC.: ", r_cts05m02.avsfurtxt
          skip 1 lines

          print column 001, "CHASSI/PLACA CONFEREM ?: ", r_cts05m02.atdrsdtxt,
                column 053, "OBS...: "                 , r_cts05m02.atddfttxt
          print column 001, "DOCTOS FORAM ROUBADOS ?: ", r_cts05m02.atddocflg,
                column 053, "QUAIS.: "                 , r_cts05m02.atddoctxt
          skip 2 lines
       end if

#### PSI 106739

 ### verifica se apolice possui contrato de PERFIL ####

     call findeds(r_cts05m02.succod,
                  r_cts05m02.aplnumdig,
                  r_cts05m02.itmnumdig,
                  r_cts05m02.atddat)
          returning    sddctnumseq,
                       sdstatus

     select edsnumdig into w_edsnumref from abamdoc
      where abamdoc.succod    =  r_cts05m02.succod    and
            abamdoc.aplnumdig =  r_cts05m02.aplnumdig and
            abamdoc.dctnumseq =  sddctnumseq


     #
     #  Acha DCTNUMSEQ de cada cobertura
     #

     call F_FUNAPOL_AUTO (r_cts05m02.succod,
                          r_cts05m02.aplnumdig,
                          r_cts05m02.itmnumdig,
                          w_edsnumref)

          returning  w_result,
                     w_dctnumseq,
                     w_vclsitatu,
                     w_autsitatu,
                     w_dmtsitatu,
                     w_dpssitatu,
                     w_appsitatu,
                     w_vidsitatu

   # Pesquisa se segurado tem clausula 018 (PERFIL)

  {--- retirado conforme PSI 195090 -   Terezinha - 21/09/2005
    ###select *
       ###from abbmclaus
      ###where succod     = r_cts05m02.succod
        ###and aplnumdig  = r_cts05m02.aplnumdig
        ###and itmnumdig  = r_cts05m02.itmnumdig
        ###and dctnumseq  = w_dctnumseq
        ###and clscod     = "018"

    ###if sqlca.sqlcode = 0 then

      ###select avsrbfsegvitflg,
             ###rbfsegult24mesflg,
             ###avsrbfsegqtd,
             ###avsgrgveisegrsdflg,
             ###avsgrgveisegtrbflg,
             ###avsgrgveisegcfgflg,
             ###avsrbfnaotrbflg,
             ###avsrbfnaocfginf,
             ###avsnaoinfflg,
             ###avsrbfvitantinf,
             ###avsrbfvitqtd
        ###into pr_perfil.*
        ###from ssamavsrbf
       ###where sinavsnum = r_cts05m02.sinvstnum
         ###and sinavsano = r_cts05m02.sinvstano
      ###if sqlca.sqlcode <> 0 then
         ###initialize pr_perfil.* to null
      ###end if

         #need 22 lines

         need 1 lines


         ###print column 16, "DADOS COMPLEMENTARES FURTO/ROUBO DE VEICULOS"
         ###print column 01, "-----------------------------------------------------------------------------"
         ###print
         ###print column 01, "A vitima e o proprio segurado?";
         ###if pr_perfil.avsrbfsegvitflg = "S" then
            ###print column 32, "SIM"
         ###else
            ###if pr_perfil.avsrbfsegvitflg = "N" then
               ###print column 32, "NAO"
            ###end if
         ###end if

         ###print
         ###print column 01, "Segurado sofreu furto/roubo de veiculo nos ultimos 24 meses?";
         ###if pr_perfil.rbfsegult24mesflg = "S" then
            ###print column 62, "SIM"
         ###else
            ###if pr_perfil.rbfsegult24mesflg = "N" then
               ###print column 62, "NAO"
            ###else
               ###print column 62, "NAO SOUBE INFORMAR"
            ###end if
         ###end if

         ###print column 01, "Quantos? ",
               ###column 10, pr_perfil.avsrbfsegqtd using "##"

         ###print
         ###print column 01, "Possui garagem/estacionamento fechado e exclusivo p/ o veiculo segurado"
         ###print
         ###print column 01, "Na Residencia?";
         ###if pr_perfil.avsgrgveisegrsdflg = "S" then
            ###print column 16, "SIM"
         ###else
            ###if pr_perfil.avsgrgveisegrsdflg = "N" then
               ###print column 16, "NAO"
            ###else
               ###print column 16, "NAO SOUBE INFORMAR"
            ###end if
         ###end if

         ###print column 01, "No Trabalho?";
         ###if pr_perfil.avsgrgveisegtrbflg = "S" then
            ###print column 14, "SIM"
         ###else
            ###if pr_perfil.avsgrgveisegtrbflg = "N" then
               ###print column 14, "NAO"
            ###else
               ###print column 14, "NAO SOUBE INFORMAR"
            ###end if
         ###end if

         ###print column 01, "No colegio/faculdade/graduacao?";
         ###if pr_perfil.avsgrgveisegcfgflg = "S" then
            ###print column 33, "SIM"
         ###else
            ###if pr_perfil.avsgrgveisegcfgflg = "N" then
               ###print column 33, "NAO"
            ###else
               ###print column 33, "NAO SOUBE INFORMAR"
            ###end if
         ###end if


         ###print
         ###print column 01, "Nao trabalha, ou o veiculo nao e utilizado para o trabalho?";
         ###if pr_perfil.avsrbfnaotrbflg = "V" then
            ###print column 61, "VERDADEIRO"
         ###else
            ###if pr_perfil.avsrbfnaotrbflg = "F" then
               ###print column 61, "FALSO"
            ###else
               ###print column 61, "NAO SOUBE INFORMAR"
            ###end if
         ###end if

         ###print
         ###print column 01, "Nao estuda ou veiculo nao utilizado para colegio/facul./graduacao?";
         ###if pr_perfil.avsrbfnaocfgflg = "V" then
            ###print column 68, "VERDADEIRO"
         ###else
            ###if pr_perfil.avsrbfnaocfgflg = "F" then
               ###print column 68, "FALSO"
            ###else
               ###print column 68, "NAO SOUBE INFOMAR"
            ###end if
         ###end if

         ###print
         ###print column 01, "Motorista(vitima) sofreu furto/roubo de veiculo anteriormente?";
         ###if pr_perfil.avsrbfvitantinf = "S" then
            ###print column 64, "SIM"
         ###else
            ###if pr_perfil.avsrbfvitantinf = "N" then
               ###print column 64, "NAO"
            ###else
               ###if pr_perfil.avsrbfvitantinf = "I" then
                  ###print column 64, "NAO SABE INFORMAR"
               ###else
                  ###print
               ###end if
            ###end if
         ###end if

         ###print
         ###print column 01, "Quantos?",
               ###column 10, pr_perfil.avsrbfvitqtd   using"##"

       ###end if

       -----  PSI  195090--------------}

       let ws.ligdatant = "31/12/1899"
       let ws.lighorant = "00:00"

       print column 020, "*****  HISTORICO DO AVISO  *****"
       #---------------------------------------------------------------
       # Linhas do HISTORICO do servico
       #---------------------------------------------------------------
       declare c_cts05m02_002 cursor for
          select ligdat   ,
                 lighorinc,
                 c24funmat,
                 c24srvdsc,
                 c24empcod                                            #Raul, Biz
            from datmservhist
           where atdsrvnum = r_cts05m02.atdsrvnum  and
                 atdsrvano = r_cts05m02.atdsrvano

       foreach c_cts05m02_002 into h_ctr03m02.ligdat    ,
                                h_ctr03m02.lighorinc ,
                                h_ctr03m02.c24funmat ,
                                h_ctr03m02.c24srvdsc,
                                h_ctr03m02.c24empcod                  #Raul, Biz

          if ws.ligdatant <> h_ctr03m02.ligdat     or
             ws.lighorant <> h_ctr03m02.lighorinc  then

             select funnom into ws.funnom
               from isskfunc
              where empcod = h_ctr03m02.c24empcod                     #Raul, Biz
                and funmat = h_ctr03m02.c24funmat

             let ws.lintxt =  "EM: "   , h_ctr03m02.ligdat    clipped,
                             "  AS: " , h_ctr03m02.lighorinc clipped,
                             "  POR: ", ws.funnom            clipped
             let ws.ligdatant = h_ctr03m02.ligdat
             let ws.lighorant = h_ctr03m02.lighorinc

             skip 1 line

             print column 005,  ws.lintxt
          end if

          print column 005, h_ctr03m02.c24srvdsc
       end foreach
#######################################################################LAUDO

#-------------------------------------------------------------------------------
      if param.enviar = "F"    and
         g_fax        = "GSF"  then
         skip to top of page
      else
         print ascii(012)
      end if
#-------------------------------------------------------------------------------

  #   call ssarel210(r_cts05m02.sindat)

      declare c_cts05m02_003 cursor for
         select mnscod
               ,mnsdes
           from ssatprcanlmns
          where datviginc   <= r_cts05m02.sindat
            and datvigfnl   >= r_cts05m02.sindat
         order by mnscod
      foreach c_cts05m02_003 into l_mnscod,
                                l_mnsdes
         if l_mnsdes[1,74] is null or
            l_mnsdes[1,74] = " " then
           #continue foreach
         else
            print column 003, l_mnsdes[001,074]
         end if
         if l_mnsdes[74,148] is null or
            l_mnsdes[74,148] = " " then
           #continue foreach
         else
            print column 003, l_mnsdes[075,148]
         end if
         if l_mnsdes[149,222] is null or
            l_mnsdes[149,222] = " " then
           #continue foreach
         else
            print column 003, l_mnsdes[149,222]
         end if
      end foreach

      skip 1 lines
      print column 001, "FAX  (", ws.dddcod, ") ",
                        ws.faxnum  using "<<<<<<<<<", "  ",
                        "(A/C: ", ws.faxresnom  clipped, ")"
      skip 2 line

      for i = 1 to 2

         if i = 1 then
            let l_sindcttip = "B"
            ##print column 003, "DOCUMENTACAO BASICA PARA VEICULOS LICENCIADOS NO MUNICIPIO DE SAO PAULO"
            print column 003, "DOCUMENTACAO BASICA."
         else
            let l_sindcttip = "C"
            ##print column 003, "COMPL. DE DOCUMENTACAO PARA VEICULO EMPLACADO FORA DO MUNICIPIO DE SAO PAULO"
            print column 003, " "
         end if

         declare c_cts05m02_004 cursor for
           select sindctcod
            from ssakprcanldct
            where sindcttip  = l_sindcttip
              and datviginc <= r_cts05m02.sindat
              and datvigfnl >= r_cts05m02.sindat

         foreach c_cts05m02_004 into l_sindctcod
            select sindcttxt1
                  ,sindcttxt2
             into l_sindcttxt1,
                  l_sindcttxt2
             from sgakdoc
             where sinramgrp = 1
               and sindctcod = l_sindctcod
            if sqlca.sqlcode = 0 then
               print column 003, "- ",l_sindcttxt1
               if l_sindcttxt2 is not null or
                  l_sindcttxt2 <> " " then
                  print column 003, "  ",l_sindcttxt2
               end if
            end if
         end foreach
         skip 1 lines
      end for

  {   print column 001,
"PARA ANALISE INICIAL DO PROCESSO TRANSMITIR IMEDIATAMENTE COPIA DO B.O. "
      print column 001, "UTILIZANDO FAX  (", ws.dddcod, ") ",
                        ws.faxnum  using "<<<<<<<<", "  ",
                        "(A/C: ", ws.faxresnom  clipped, ")"
      skip 2 line
      print column 001,
"DOCUMENTACAO BASICA PARA VEICULOS LICENCIADOS NO MUNICIPIO DE SAO PAULO"
      skip 1 line
      print column 001, "- Boletim de Ocorrencia Policial original"
      print column 001,
"- IPVA deste ano e do ano passado quitado original ou microfilme a ser  obtido"
      print column 001,
"  junto a Secretaria da Fazenda (em caso de extravio e/ou Debito do IPVA fazer"
      print column 001,
"  a solicitacao ou pagamento na Secretaria da Fazenda)"
      print column 001,
"- Certificado de Propriedade do Veiculo e Seguro Obrigatorio (Original)"
      print column 001,
"- Certificado de Transferencia assinado e com firma reconhecida  (sob carimbo,"
      print column 001,
"  se Pessoa Juridica)"
      print column 001,
"- Termo de Responsabilidade por Multas com firma reconhecida (modelo fornecido"
      print column 001,
"  pela Companhia)"
      print column 001,
"- Xerox do Contrato Social e ultima alteracao (se Pessoa Juridica)"
      print column 001, "- Chaves do Veiculo"
      print column 001,
"- Liberacao da Financeira com firma reconhecida (se o Veiculo estiver alienado)"
      print column 001, "- Multas ou Extrato de Multas quitado"
      print column 001,
"- Quitacao da Apolice (carta autorizando deposito de cheques em custodia e  se"
      print column 001,
"  parcelado, Autorizacao para deducao da indenizacao ou quitacao)"
      print column 001,
"- Autorizacao para pagamento ao proprietario legal (se o Veiculo  nao  estiver"
      print column 001,
"  em nome do Segurado)"

      skip 1 line
      print column 001,
"COMPLEMENTACAO DE DOCUMENTACAO PARA VEICULO EMPLACADO FORA DO MUNICIPIO DE SAO"
      print column 001, "PAULO"
      skip 1 line
      print column 001,
"- Certidao de Prontuario do Veiculo a ser obtida junto ao DETRAN e/ou CIRETRAN"
      print column 001,
"- Certidao Negativa de Multas a ser obtida junto ao DETRAN e/ou CIRETRAN"
      print column 001,
"- Isencao ou Baixa do IPVA, a ser obtida junto a Secretaria da Fazenda"
      print column 001,
"- Certidao de nao Localizacao do Veiculo, a ser obtida junto ao DEPATRI (anti-"
      print column 001,
"  go DEIC)"
}
#-------------------------------------------------------------------------------
      if param.enviar = "F"    and
         g_fax        = "GSF"  then
         skip to top of page
      else
         print ascii(012)
      end if
#-------------------------------------------------------------------------------

      #skip 5 lines

      skip 1 lines

  #   call ssarel200(r_cts05m02.sindat)
     print column 017, "TERMO DE RESPONSABILIDADE E AUTORIZACAO DE PAGAMENTO DE"
  ##    print column 027, " DE MULTAS DE TRANSITO E I.P.V.A."
     print column 019, "MULTAS DE TRANSITO/SEGURO OBRIGATORIO E/OU I.P.V.A."

      skip 2 line

      for i = 1 to 3
         declare c_cts05m02_005 cursor for
            select pgtrsptrmtxt
              from ssakpgtrsptrm
             where pgtrsptrmcod = i
               and datviginc   <= r_cts05m02.sindat
               and datvigfnl   >= r_cts05m02.sindat
         foreach c_cts05m02_005 into w_pgtrsptrmtxt

            print column 003, w_pgtrsptrmtxt

         end foreach

         if i = 1 then
            skip 1 line
            print column 003, "PLACA  :___________________ MARCA  :___________________ MODELO:____________"
            skip 1 line
            print column 003, "ANO FAB:___________________ ANO MOD:___________________ COR   :____________"
            skip 1 line
            print column 003, "CHASSIS:___________________"
            skip 1 line
         end if

         if i = 2 then
            skip 1 line
            print column 003, "                              SAO PAULO, ____ DE ______________ DE 20______"
            skip 2 line
            print column 003, "NOME      :________________________________________________________________"
            skip 1 line
            print column 003, "ENDERECO  :________________________________________________________________"
            skip 1 line
            print column 003, "CEP       :___________________BAIRRO:______________________________________"
            skip 1 line
            print column 003, "CIDADE    :_______________________________________ ESTADO:_________________"
            skip 1 line
            print column 003, "TELEFONE  :____________________ CIC/CNPJ:__________________________________"
            skip 3 line
            print column 003, "ASSINATURA:________________________________________________________________"
            skip 2 line
         end if

      end for

  {   print column 014,
           "TERMO DE RESPONSABILIDADE E AUTORIZACAO DE PAGAMENTO"
      print column 25,
                      "DE MULTAS DE TRANSITO E I.P.V.A."
      skip 1 line
      print column 001,
"Pela presente e na melhor forma de direito, declaro que assumo integral respon"
      print column 001,
"sabilidade pelas multas de transito e debitos de I.P.V.A, que forem, ou venham"
      print column 001,
"a ser lancados pelas reparticoes, referente ao veiculo: "
      skip 1 line
      print column 001,
"PLACA:_____________ MARCA:______________________ MODELO:______________________"
      skip 1 line
      print column 001,
"ANO FAB:_________________ ANO MOD:______________ COR:_________________________"
      skip 1 line
      print column 001,
"CHASSI:__________________________________________ "
      skip 1 line
      print column 001,
"Nesta conformidade, autorizo a PORTO SEGURO COMPANHIA DE SEGUROS GERAIS, C.G.C"
      print column 001,
"No.61.198.164/0001-60, localizada nesta capital, a Av. Rio Branco, 1489, a efe"
      print column 001,
"tivar de imediato, sem necessidade de previa defesa, quaisquer pagamentos  por"
      print column 001,
"eventuais penalidades de transito aplicadas ao supra identificado ate a presen"
      print column 001,
"te data, ainda na hipotese de virem a ser apuradas apos a expedicao  da  Certi"
      print column 001,
"dao  Negativa de Multas  anteriormente  obtida  junto  ao  DETRAN, bem  como a"
      print column 001,
"debitos apurados junto  a  SECRETARIA DA FAZENDA DO ESTADO, ressalto  apenas o"
      print column 001,
"meu direito de requerer, administrativa ou judicialmente, contra a referida re"
      print column 001,
"particao, de multa paga ou recolhimento de I.P.V.A e por mim reembolsada."
      skip 1 line
      print column 001,
"Autorizo, ainda, a PORTO SEGURO COMPANHIA DE SEGUROS GERAIS,  a  sacar  contra"
      print column 001,
"minha pessoa uma letra de cambio a vista do valor  correspondente as  multas e"
      print column 001,
"recolhimento  do  I.P.V.A.  porventura  pagas em  meu nome, cambial  essa como"
      print column 001,
"titulo de credito que podera  ser protestada  pela sacadora  no momento em que"
      print column 001,
"deixar de ressarcir pela integralidade dos recolhimentos de que se trata, quan"
      print column 001,
"do a  apresentacao dos  respectivos  comprovantes,  independente  de  qualquer"
      print column 001,
"notificacao judicial."
      skip 2 lines
      print column 001,
"                                 SAO PAULO, ____ DE ______________ DE 200_____"
      skip 2 lines
      print column 001,
"NOME    :_____________________________________________________________________"
      skip 1 line
      print column 001,
"ENDERECO:_____________________________________________________________________"
      skip 1 line
      print column 001,
"CEP:____________________ BAIRRO:______________________________________________"
      skip 1 line
      print column 001,
"CIDADE:______________________________________________ ESTADO:_________________"
      skip 1 line
      print column 001,
"TEL:____________________ CIC/CNPJ:____________________________________________"
      skip 1 line
      print column 001,
"ASSINATURA:___________________________________________________________________"

      skip 3 line
      print column 001, "*Reconhecer firma por semelhanca"
      print column 001, "*Nao aceitamos este documento em papel de fax"
 }

      if param.enviar <> "F"   then
         print ascii(12)
      end if

end report  ###  rep_furto

function cts05m02_rep_furto(r_cts05m02, param, l_docHandle)

 define r_cts05m02 record
    cvnnum         like abamapol.cvnnum       ,
    sinvstnum      like datrsrvvstsin.sinvstnum,
    sinvstano      like datrsrvvstsin.sinvstano,
    atdsrvnum      like datmservico.atdsrvnum   ,
    atdsrvano      like datmservico.atdsrvano   ,
    atdsrvorg      like datmservico.atdsrvorg   ,
    srvtipdes      like datksrvtip.srvtipdes    ,
    c24solnom      like datmligacao.c24solnom   ,
    c24soltipdes   like datksoltip.c24soltipdes ,
    c24astcod      like datmligacao.c24astcod   ,
    c24astdes      char (60)                    ,
    ligcvntip      like datmligacao.ligcvntip   ,
    ligcvnnom      char (20)                    ,
    ramcod         like datrservapol.ramcod     ,
    succod         like datrservapol.succod     ,
    aplnumdig      like datrservapol.aplnumdig  ,
    itmnumdig      like datrservapol.itmnumdig  ,
    nom            like datmservico.nom         ,
    dddcod         like gsakend.dddcod          ,
    teltxt         like gsakend.teltxt          ,
    corsus         like datmservico.corsus      ,
    cornom         like datmservico.cornom      ,
    vcldes         like datmservico.vcldes      ,
    vclcordes      char (15)                    ,
    vclanomdl      like datmservico.vclanomdl   ,
    vcllicnum      like datmservico.vcllicnum   ,
    vclcamdes      char (08)                    ,
    vclcrcdsc      like datmservicocmp.vclcrcdsc,
    vclcrgpso      like datmservicocmp.vclcrgpso,
    orrlclidttxt   like datmlcl.lclidttxt       ,
    orrlgdtxt      char (65)                    ,
    orrlclbrrnom   like datmlcl.lclbrrnom       ,
    orrbrrnom      like datmlcl.brrnom          ,
    orrcidnom      like datmlcl.cidnom          ,
    orrufdcod      like datmlcl.ufdcod          ,
    orrlclrefptotxt like datmlcl.lclrefptotxt   ,
    orrendzon      like datmlcl.endzon          ,
    orrdddcod      like datmlcl.dddcod          ,
    orrlcltelnum   like datmlcl.lcltelnum       ,
    orrlclcttnom   like datmlcl.lclcttnom       ,
    atdrsdtxt      char (03)                    ,
    asitipabvdes   like datkasitip.asitipabvdes ,
    atddfttxt      like datmservico.atddfttxt   ,
    ntzdes         like datksocntz.socntzdes    ,
    boctxt         char (03)                    ,
    bocnum         like datmservicocmp.bocnum   ,
    bocemi         like datmservicocmp.bocemi   ,
    sindat         like datmservicocmp.sindat   ,
    sinhor         like datmservicocmp.sinhor   ,
    sinvittxt      char (03)                    ,
    rmcacptxt      char (03)                    ,
    roddantxt      like datmservicocmp.roddantxt,
    asimtvdes      like datkasimtv.asimtvdes    ,
    imdsrvtxt      char (03)                    ,
    atdhorpvt      like datmservico.atdhorpvt   ,
    atddatprg      like datmservico.atddatprg   ,
    atdhorprg      like datmservico.atdhorprg   ,
    atdlibdat      like datmservico.atdlibdat   ,
    atdlibhor      like datmservico.atdlibhor   ,
    atdlibflg      like datmservico.atdlibflg   ,
    atddat         like datmservico.atddat      ,
    atdhor         like datmservico.atdhor      ,
    atdfunmat      like datmservico.funmat      ,
    atdfunnom      like isskfunc.funnom         ,
    atddptsgl      like isskfunc.dptsgl         ,
    cnldat         like datmservico.cnldat      ,
    atdfnlhor      like datmservico.atdfnlhor   ,
    cnlfunmat      like datmservico.c24opemat   ,
    cnlfunnom      like isskfunc.funnom         ,
    cnldptsgl      like isskfunc.dptsgl         ,
    atdprscod      like datmservico.atdprscod   ,
    c24nomctt      like datmservico.c24nomctt   ,
    atdmotnom      like datmservico.atdmotnom   ,
    srrcoddig      like datmservico.srrcoddig   ,
    atdvclsgl      like datmservico.atdvclsgl   ,
    socvclcod      like datmservico.socvclcod   ,
    pgtdat         like datmservico.pgtdat      ,
    atdcstvlr      like datmservico.atdcstvlr   ,
    avsfurtxt      char (30)                    ,
    atddocflg      char (03)                    ,
    atddoctxt      like datmservico.atddoctxt   ,
    atddmccidnom   like datmassistpassag.atddmccidnom,
    atddmcufdcod   like datmassistpassag.atddmcufdcod,
    srvprlflg      like datmservico.srvprlflg
 end record

 define param         record
    enviar            char (01)                  ,
    faxch1            like datmfax.faxch1        ,
    faxch2            like datmfax.faxch2        ,
    faxcor            char (15)                  ,
    destin            char (24)
 end record

 define h_ctr03m02  record
    ligdat          like datmservhist.ligdat     ,
    lighorinc       like datmservhist.lighorinc  ,
    c24funmat       like datmservhist.c24funmat  ,
    c24srvdsc       like datmservhist.c24srvdsc  ,
    c24empcod       like datmservhist.c24empcod
 end record

 define ws          record
    logotipo          char (13)                 ,
    dddcod            like sgkkarea.dddcod      ,
    faxnum            like sgkkarea.faxnum      ,
    faxresnom         like sgkkarea.faxresnom   ,
    sinvstnumchar     char (06)                 ,
    cvnflg            char (01),
    funnom          like isskfunc.funnom         ,
    lintxt          like datmservhist.c24srvdsc  ,
    pasnom          like datmpassageiro.pasnom   ,
    pasidd          like datmpassageiro.pasidd   ,
    avlitmcod       like datrpesqaval.avlitmcod  ,
    avlpsqnot       like datrpesqaval.avlpsqnot  ,
    ligdatant       like datmservhist.ligdat     ,
    lighorant       like datmservhist.lighorinc  ,
    vclcoddig       like datkveiculo.vclcoddig   ,
    srrabvnom       like datksrr.srrabvnom       ,
    vcldes          char (58)
 end record

 define i            smallint
 define w_pgtrsptrmtxt   like ssakpgtrsptrm.pgtrsptrmtxt
 define l_mnscod         like ssatprcanlmns.mnscod
 define l_mnsdes         like ssatprcanlmns.mnsdes
 define l_sindcttip      like ssakprcanldct.sindcttip
 define l_sindctcod      like ssakprcanldct.sindctcod
 define l_sindcttxt1     like sgakdoc.sindcttxt1
 define l_sindcttxt2     like sgakdoc.sindcttxt2

 define pr_perfil  record
        avsrbfsegvitflg     char(01),
        rbfsegult24mesflg   char(01),
        avsrbfsegqtd        smallint,
        avsgrgveisegrsdflg  char(01),
        avsgrgveisegtrbflg  char(01),
        avsgrgveisegcfgflg  char(01),
        avsrbfnaotrbflg     char(01),
        avsrbfnaocfgflg     char(01),
        avsnaoinfflg        char(01),
        avsrbfvitantinf     char(01),
        avsrbfvitqtd        smallint

 end record
 define w_vclsitatu     like        abbmitem.autsitatu,
        w_autsitatu     like        abbmitem.autsitatu,
        w_dmtsitatu     like        abbmitem.autsitatu,
        w_dpssitatu     like        abbmitem.autsitatu,
        w_appsitatu     like        abbmitem.autsitatu,
        w_vidsitatu     like        abbmitem.autsitatu,
        sdstatus        integer,
        sddctnumseq     like abbmcasco.dctnumseq,
        w_result        char(01)
 define w_dctnumseq     like        abbmitem.autsitatu
 define w_edsnumref     like        ssamsin.edsnumref

 define l_path         char(500)
       ,l_path2        char(500)
       ,l_path_item    char(500)
       ,l_caminho      char(500)
       ,l_caminho1     char(500)
       ,l_i            smallint
       ,l_ind          smallint
       ,l_logo         char(200)
       ,l_docHandle    integer

 let l_path = "/report/data/file/cts_furto"

 let l_caminho = l_path clipped ,"/ddd_fax" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.faxcor[1,2] clipped)

 let l_caminho = l_path clipped ,"/numero_fax" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.faxcor[3,10] clipped)

 let l_caminho = l_path clipped ,"/nome_destinatario" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.destin clipped)

 let l_caminho = l_path clipped ,"/numero_servico_central" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.faxch1 clipped)

 let l_caminho = l_path clipped ,"/ano_servico_central" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,param.faxch2 clipped)

 let l_caminho = l_path clipped ,"/endereco_imagem_logo" clipped
 let l_logo = '\\\\nt112\\jasper3\\atendimento_rightfax\\logo.jpg'
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,l_logo clipped)

 let l_caminho = l_path clipped ,"/data_roubo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atddat clipped)

 let l_caminho = l_path clipped ,"/hora_roubo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atdhor clipped)

 let l_caminho = l_path clipped ,"/nome_corretora" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.cornom clipped)

 let l_caminho = l_path clipped ,"/susep_corretora" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.corsus clipped)

 let l_caminho = l_path clipped ,"/nome_segurado" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.nom clipped)

 let l_caminho = l_path clipped ,"/veiculo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.vcldes clipped)

 let l_caminho = l_path clipped ,"/placa" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.vcllicnum clipped)

 let l_caminho = l_path clipped ,"/sucursal" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.succod clipped)

 let l_caminho = l_path clipped ,"/ramo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.ramcod clipped)

 let l_caminho = l_path clipped ,"/apolice" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.aplnumdig clipped)

 let l_caminho = l_path clipped ,"/item_apolice" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.itmnumdig clipped)

 let l_caminho = l_path clipped ,"/numero_vistoria" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.sinvstnum clipped)

 let l_caminho = l_path clipped ,"/ano_vistoria" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.sinvstano clipped)

 let l_caminho1 = "/grupos/atendimento"
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/origem_servico" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atdsrvorg clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/numero_servico" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atdsrvnum clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/ano_servico" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atdsrvano clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/particularidade" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.srvprlflg clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/tipo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.srvtipdes clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/codigo_assunto" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.c24astcod clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/descricao_assunto" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.c24astdes clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/tipo_convenio" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.ligcvntip clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/nome_convenio" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.ligcvnnom clipped)

 let l_caminho1 = "/grupos/documento"
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/sucursal" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.succod clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/ramo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.ramcod clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/apolice" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.aplnumdig clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/item_apolice" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.itmnumdig clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/nome_solicitante" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.c24solnom clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/tipo_solicitante" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.c24soltipdes clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/nome_segurado" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.nom clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/ddd" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.dddcod clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/telefone" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.teltxt clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/susep_corretor" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.corsus clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/nome_corretor" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.cornom clipped)

 let l_i   = 0
 let l_ind = 0
 let l_caminho1 = "/grupos/veiculo"
 if r_cts05m02.vcldes is not null  then
    let l_i = l_i + 1
    let l_ind = l_i - 1
    let l_path_item = l_path clipped ,l_caminho1 clipped,"/item_veiculo[",l_ind using"<<<<","]"
    let l_caminho = l_path_item clipped ,"/label_esquerda" clipped
    let l_itens[l_i].label_esquerda = "VEICULO..:"
    call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].label_esquerda clipped)
    let l_caminho = l_path_item clipped ,"/valor_esquerda" clipped
    let l_itens[l_i].valor_esquerda = r_cts05m02.vcldes
    call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].valor_esquerda clipped)
    let l_caminho = l_path_item clipped ,"/label_direita" clipped
    let l_itens[l_i].label_direita = "COR...:"
    call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].label_direita clipped)
    let l_caminho = l_path_item clipped ,"/valor_direita" clipped
    let l_itens[l_i].valor_direita = r_cts05m02.vclcordes
    call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].valor_direita clipped)

    if r_cts05m02.vclcamdes is not null  then
       let l_i = l_i + 1
       let l_ind = l_i - 1
       let l_path_item = l_path clipped ,l_caminho1 clipped,"/item_veiculo[",l_ind using"<<<<","]"
       let l_caminho = l_path_item clipped ,"/label_esquerda" clipped
       let l_itens[l_i].label_esquerda = "TIPO.....:"
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].label_esquerda clipped)
       let l_caminho = l_path_item clipped ,"/valor_esquerda" clipped
       let l_itens[l_i].valor_esquerda = r_cts05m02.vclcamdes
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].valor_esquerda clipped)
       let l_caminho = l_path_item clipped ,"/label_direita" clipped
       let l_itens[l_i].label_direita = "CARROCERIA:"
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].label_direita clipped)
       let l_caminho = l_path_item clipped ,"/valor_direita" clipped
       let l_itens[l_i].valor_direita = r_cts05m02.vclcrcdsc
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].valor_direita clipped)
    end if

    if r_cts05m02.vclanomdl is not null  then
       let l_i = l_i + 1
       let l_ind = l_i - 1
       let l_path_item = l_path clipped ,l_caminho1 clipped,"/item_veiculo[",l_ind using"<<<<","]"
       let l_caminho = l_path_item clipped ,"/label_esquerda" clipped
       let l_itens[l_i].label_esquerda = "ANO MOD..:"
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].label_esquerda clipped)
       let l_caminho = l_path_item clipped ,"/valor_esquerda" clipped
       let l_itens[l_i].valor_esquerda = r_cts05m02.vclanomdl
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].valor_esquerda clipped)
       let l_caminho = l_path_item clipped ,"/label_direita" clipped
       let l_itens[l_i].label_direita = "PLACA.:"
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].label_direita clipped)
       let l_caminho = l_path_item clipped ,"/valor_direita" clipped
       let l_itens[l_i].valor_direita = r_cts05m02.vcllicnum
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,l_itens[l_i].valor_direita clipped)
    end if

 end if

 let l_caminho1 = "/grupos/endereco"
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/logradouro" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrlgdtxt clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/bairro" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrlclbrrnom clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/cidade" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrcidnom clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/uf" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrufdcod clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/referencia" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrlclrefptotxt[1,40] clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/zona" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrendzon clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/ddd" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrdddcod clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/telefone" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrlcltelnum clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/contato" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.orrlclcttnom clipped)

 let l_caminho1 = "/grupos/bo"
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/bo" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.boctxt clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/numero" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.bocnum clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/orgao" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.bocemi clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/ocorrencia" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.avsfurtxt clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/chassi_placa_confere" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atdrsdtxt clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/obs" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atddfttxt clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/documentos_roubados" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atddocflg clipped)
 let l_caminho = l_path clipped ,l_caminho1 clipped, "/quais_documentos_roubados" clipped
 call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped,r_cts05m02.atddoctxt clipped)

 let l_ind = 0
 declare c_cts05m02_002_n cursor for
    select ligdat   ,
           lighorinc,
           c24funmat,
           c24srvdsc,
           c24empcod
      from datmservhist
     where atdsrvnum = r_cts05m02.atdsrvnum
       and atdsrvano = r_cts05m02.atdsrvano

 foreach c_cts05m02_002_n into h_ctr03m02.ligdat    ,
                             h_ctr03m02.lighorinc ,
                             h_ctr03m02.c24funmat ,
                             h_ctr03m02.c24srvdsc,
                             h_ctr03m02.c24empcod

    if ws.ligdatant <> h_ctr03m02.ligdat     or
       ws.lighorant <> h_ctr03m02.lighorinc  then

       select funnom into ws.funnom
         from isskfunc
        where empcod = h_ctr03m02.c24empcod
          and funmat = h_ctr03m02.c24funmat

       let ws.lintxt =  "EM: "   , h_ctr03m02.ligdat    clipped,
                        "  AS: " , h_ctr03m02.lighorinc clipped,
                        "  POR: ", ws.funnom            clipped
       let ws.ligdatant = h_ctr03m02.ligdat
       let ws.lighorant = h_ctr03m02.lighorinc


       let l_path_item = l_path clipped ,"/historicos/historico[",l_ind using"<<<<","]"

       let l_caminho = l_path_item clipped ,"/informacoes_ligacao" clipped
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,ws.lintxt clipped)

       let l_caminho = l_path_item clipped ,"/descricao_servico_central" clipped
       call figrc011RF_atualiza_xml(l_docHandle,l_caminho clipped ,h_ctr03m02.c24srvdsc clipped)

       let l_ind = l_ind + 1

    end if


 end foreach

end function
#RightFax - Fim

