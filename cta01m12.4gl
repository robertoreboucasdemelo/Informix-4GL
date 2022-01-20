#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta01m12.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 190080                                                     #
# OSF           :                                                            #
#                 Direcionar o espelho da apolice de acordo com o Ramo       #
#............................................................................#
# Desenvolvimento: Meta, Daniel                                              #
# Liberacao      : 24/01/2005                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 11/03/2005 Daniel Meta       PSI191094  Chamar a funcao cta00m06()         #
#----------------------------------------------------------------------------#
# 22/09/2006 ruiz              psi202720  Inclusao apolice Saude             #
# 16/11/2006 Ligia             PSI 205206 ciaempcod                          #
# 27/06/2007 Roberto           PSI 207446 Inclusao do Espelho do Vida        #
# 29/02/2008 Amilton, Meta     Psi219967  Incluir retorno na chamada da      #
#                                            função cta00m16_chama_prog e    #
#                                            validar o retorno               #
# 02/07/2008 Amilton, Meta     Psi 223689 Substituir chamada da função       #
#                                         opacc149 pela chama_prog (cty02g00)#
#----------------------------------------------------------------------------#
# 18/10/2008 Carla Rampazzo  PSI 230650   Passar p/ "ctg18" o campo atdnum   #
#----------------------------------------------------------------------------#
# 29/12/2009 Patricia W.                  Projeto SUCCOD - Smallint          #
#----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo  PSI 219444  .Passar p/ "ctg18" os campos        #
#                                         lclnumseq / rmerscseq (RE)         #
#                                        .Atribui valor se campos = nulo     #
#----------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo    PSI 242853   Implementacao do PSS               #
#----------------------------------------------------------------------------#
# 01/02/2013 Fernando Dias   Chamado      chamar a funcao                    #
#                            130125126    cty22g00_rec_ult_sequencia para    #
#                                         apos a consulta retornar para o    #
#                                         espelho da apolice correto.        #
#----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail  #
##############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------
function cta01m12_espelho(lr_param)
#---------------------------------------------------------

 define lr_param     record
    ramcod           smallint
   ,succod           like datrligapol.succod  #decimal(2,0)  #projeto succod
   ,aplnumdig        decimal(9,0)
   ,itmnumdig        decimal(7,0)
   ,prporg           decimal(2,0)
   ,prpnumdig        decimal(9,0)
   ,fcapacorg        like mfimanalise.fcapacorg
   ,fcapacnum        like mfimanalise.fcapacnum
   ,pcacarnum        like eccmpti.pcapticod
   ,pcaprpitm        like epcmitem.pcaprpitm
   ,cmnnumdig        like pptmcmn.cmnnumdig
   ,crtsaunum        like datksegsau.crtsaunum
   ,bnfnum           like datksegsau.bnfnum
   ,ciaempcod        like datmligacao.ciaempcod
 end record
 define w_retorno    record
        succod       like datksegsau.succod,
        ramcod       like datksegsau.ramcod,
        aplnumdig    like datksegsau.aplnumdig,
        crtsaunum    like datksegsau.crtsaunum,
        bnfnum       like datksegsau.bnfnum
 end record

 define ret record
        aplnumdig  like datrligapol.aplnumdig ,
        prporg     like datrligprp.prporg     ,
        prpnumdig  like datrligprp.prpnumdig  ,
        segnumdig  like gsaksegger.segnumdig  ,
        succod     like datksegsau.succod     ,
        erro       smallint                   ,
        ramcod      like datrservapol.ramcod
 end record

 define ws record
    confirma          char(01),
    txt1              char(60),
    txt2              char(60),
    txt3              char(60),
    txt4              char(60),
    pesnom            char(60)
 end record

 define l_flag       char(1)
 define l_msg       char(100)
 define l_flag_acesso smallint
 define l_doc_handle  integer
 define l_resultado  smallint
 define l_mensagem   char(30)

 ## CT  303208
 ## alberto
   define l_cmd        char(500)

   define l_mens       record
          msg          char(200)
         ,de           char(50)
         ,subject      char(100)
         ,para         char(100)
         ,cc           char(100)
   end record

   define l_today date
   define l_hora  datetime hour to second
   define l_arg_val_fixos char(200)
   define l_status       smallint # PSI219967  Amilton Fim

   ---> VEP - Vida
   define lr_ret_vida01   record
          coderro         smallint
         ,msgerr          char(080)
         ,sgrorg          decimal(2,0)
         ,sgrnumdig       decimal(9,0)
         ,ciaperptc       decimal(8,5)
         ,succod          like datrligapol.succod  #decimal(2,0)  #projeto succod
         ,aplnumdig       decimal(9,0)
         ,rnvsuccod       like datrligapol.succod  #decimal(2,0)  #projeto succod
         ,rnvaplnum       decimal(9,0)
         ,ramcod          smallint
         ,rmemdlcod       decimal(3,0)
         ,subcod          decimal(2,0)
         ,csginfflg       char(001)
         ,empcod          decimal(2,0)
         ,clbctrtip       decimal(2,0)
         ,rnvramcod       smallint
   end record

   define lr_ffpfc073 record
      cgccpfnumdig like fsckprpcrd.cgccpfnumdig ,
      pestipcod    like fsckprpcrd.pestipcod    ,
      crdprpnom    like fsckprpcrd.crdprpnom    ,
      mens         char(50)                     ,
      erro         smallint
   end record

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
   define l_erro  smallint
   define msg_erro char(500)
   initialize  l_cmd           to  null
   initialize  l_today         to  null
   initialize  l_hora          to null
   initialize  w_retorno.*     to null
   initialize  l_doc_handle    to null
   initialize  l_resultado     to null
   initialize  l_mensagem      to null
   initialize  ret.*           to null
   initialize  l_status        to null
   initialize  lr_ret_vida01.* to null   ---> Vida - VEP
   initialize  lr_ffpfc073.*   to null
   initialize  ws.*            to null

   let l_arg_val_fixos = null

 let l_doc_handle  =  null
 let l_flag_acesso = cta00m06(g_issk.dptsgl)

 if l_flag_acesso = 0 then
    return
 end if

 let g_documento.ramcod     = lr_param.ramcod
 let g_documento.succod     = lr_param.succod
 let g_documento.aplnumdig  = lr_param.aplnumdig
 let g_documento.itmnumdig  = lr_param.itmnumdig
 let g_documento.prporg     = lr_param.prporg
 let g_documento.prpnumdig  = lr_param.prpnumdig
 let g_documento.fcapacorg  = lr_param.fcapacorg
 let g_documento.fcapacnum  = lr_param.fcapacnum
 let g_documento.pcacarnum  = lr_param.pcacarnum
 let g_documento.pcaprpitm  = lr_param.pcaprpitm
 let g_documento.crtsaunum  = lr_param.crtsaunum
 let g_documento.bnfnum     = lr_param.bnfnum
 let g_documento.ciaempcod  = lr_param.ciaempcod

 if g_documento.ramgrpcod is null then
      call cty10g00_grupo_ramo(g_documento.ciaempcod ,
                               g_documento.ramcod    )
      returning l_resultado, l_mensagem, g_documento.ramgrpcod
 end if

 ## Empresa Porto Seguro
 if lr_param.ciaempcod = 1  or   ## PSI 205206
    lr_param.ciaempcod = 50 or   ---> Saude
    lr_param.ciaempcod = 14 then ---> Funeral

    if lr_param.prporg is not null and
       lr_param.prpnumdig is not null
       and lr_param.ramcod <> 531 then
       # Visualizar espelho da proposta
       # Ini Psi 223689
       call cty02g00_opacc149(lr_param.prporg,lr_param.prpnumdig)
                        returning l_flag,l_msg
          if l_msg is not null or
             l_msg <> " "  then
           error l_msg
          end if

       # fim Psi 223689

       #let l_flag = cty02g00_opacc149(lr_param.prporg,lr_param.prpnumdig)
    end if

    # Visualizar espelho do Cartao Porto Card
    if lr_param.pcacarnum is not null then
       call cta01m50()
    end if

    ## Flexvision - Pegar hora com segundos
    if g_monitor.horaini is null or
       g_monitor.horaini = " "   then
       let g_monitor.horaini = current
    end if


    let g_monitor.dataini = today
    let g_monitor.horafnl = current
    let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini
    if  g_monitor.intervalo is null or
        g_monitor.intervalo = ""    or
        g_monitor.intervalo = " "   or
        g_monitor.intervalo < "0:00:00.000" then
        let g_monitor.intervalo = "0:00:00.999"
    end if

    ##let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo
    let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                              "|cta01m12->", g_issk.funmat,
                              " ->", g_documento.ciaempcod
    let g_monitor.horaini   = g_monitor.horafnl
    call errorlog (g_monitor.txt)
    let g_monitor.txt = " "

    ## CT  303208 Alberto
    if   g_documento.aplnumdig <>  lr_param.aplnumdig then

          initialize l_mens.* to null
          initialize l_today to null
          initialize l_hora to null

          let l_today =  today
          let l_hora  =  time
          let l_mens.msg = "Suc/Ram/Apol: ", lr_param.succod,"/",lr_param.ramcod
                ,"/",lr_param.aplnumdig," Glob:",g_documento.aplnumdig
                     , "< Data: ", l_today ," : ",l_hora, " > "
                , " Assunto : ",g_documento.c24astcod
                     ," Matricula : "  , g_issk.funmat
                ," Org/prp > ",lr_param.prporg,"/", lr_param.prpnumdig
                ," Parcela: ", lr_param.pcacarnum
          #PSI-2013-23297 - Inicio
          let l_mail.de = "CT24H-cta01m12"
          let l_mail.para = "sistemas.madeira@portoseguro.com.br"
          #let l_mail.para = "Rodrigues_Alberto@correioporto"
          #let l_mail.cc = "Mattge_Ligia@correioporto"
          let l_mail.cco = ""
          let l_mail.assunto = "Apolices Divergentes"
          let l_mail.mensagem = l_mens.msg
          let l_mail.id_remetente = "CT24HS"
          let l_mail.tipo = "text"

          call figrc009_mail_send1 (l_mail.*)
              returning l_erro,msg_erro

          #PSI-2013-23297 - Fim
    end if

    # Visualizar espelho do ramo Automovel
     if lr_param.ramcod = 31 or
       lr_param.ramcod = 531 then

       if lr_param.succod is not null and
          lr_param.aplnumdig is not null then

          ## Flexvision - Pegar hora com segundos
          let g_monitor.horafnl = current
          let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini
          if  g_monitor.intervalo is null or
              g_monitor.intervalo = ""    or
              g_monitor.intervalo = " "   or
              g_monitor.intervalo < "0:00:00.000" then
              let g_monitor.intervalo = "0:00:00.999"
          end if

          let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                    "|CTA00M05-> ", g_issk.funmat,
                                    " ->", g_documento.ciaempcod

          let g_monitor.horaini   = g_monitor.horafnl
          call errorlog (g_monitor.txt)
          let g_monitor.txt = " "

          call cta00m16_chama_prog("ctg18", g_documento.ramcod,
                                            g_documento.succod,
                                            g_documento.aplnumdig,
                                            g_documento.itmnumdig,
                                            g_documento.edsnumref,
                                            g_documento.ligcvntip,
                                            g_documento.prporg,
                                            g_documento.prpnumdig,
                                            g_documento.solnom,
                                            g_documento.ciaempcod,
                                            g_documento.ramgrpcod,
                                            g_documento.c24soltipcod,
                                            g_documento.corsus,
                                            g_documento.atdnum,
                                            g_documento.lclnumseq,
                                            g_documento.rmerscseq,
                                            g_documento.itaciacod)
                                    returning l_status# PSI219967 Amilton inicio
                      if l_status = -1 then
                           error "Espelho da apolice nao disponivel no momento" sleep 2
                      end if   # PSI219967  Amilton Fim
       else
          # inclusao do trecho para abertura do Espelho da Proposta -- Patricia PSI
          if ((g_documento.prporg is not null and g_documento.prporg <> 0) and
             (g_documento.prpnumdig is not null and g_documento.prpnumdig <> 0)) then
             call cta00m16_chama_prog("ctg18", g_documento.ramcod,
                                               g_documento.succod,
                                               g_documento.aplnumdig,
                                               g_documento.itmnumdig,
                                               g_documento.edsnumref,
                                               g_documento.ligcvntip,
                                               g_documento.prporg,
                                               g_documento.prpnumdig,
                                               g_documento.solnom,
                                               g_documento.ciaempcod,
                                               g_documento.ramgrpcod,
                                               g_documento.c24soltipcod,
                                               g_documento.corsus,
                                               g_documento.atdnum,
                                               g_documento.lclnumseq,
                                               g_documento.rmerscseq,
                                               g_documento.itaciacod)
                                       returning l_status
             if l_status = -1 then
                  error "Espelho da proposta nao disponivel no momento" sleep 2
             end if
          else
                error " Espelho so  com documento localizado ! "
          end if
       end if
    else
       # Visualizar espelho do PAC/RE
       if lr_param.fcapacorg is not null and
          lr_param.fcapacnum is not null then

          ##call cty06g02_orflc550(lr_param.fcapacorg, lr_param.fcapacnum)
       else

          ------------[ Espelho do Vida ]----------------
         if (lr_param.ramcod = 991   or
             lr_param.ramcod = 993   or
             lr_param.ramcod = 980   or
             lr_param.ramcod = 981   or
             lr_param.ramcod = 982   or
             lr_param.ramcod = 1391  or
             lr_param.ramcod = 1329) or
             lr_param.ciaempcod = 14 then   ---> Funeral

             #---> Vida - VEP
             call fvnre000_rsamseguro_01(lr_param.succod
                                       , lr_param.ramcod
                                       , lr_param.aplnumdig)
                  returning lr_ret_vida01.*

                  call cta01m32(""    ,
                                ""    ,
                                "" ,
                                lr_ret_vida01.sgrorg    ,
                                lr_ret_vida01.sgrnumdig ,
                                "","",""     )
                  returning  ret.*

                  let lr_param.ramcod = ret.ramcod

                  if ret.erro <> 0 then
                     error "Dados da Apolice nao encontrada"
                  end if
         else

          ------------[ espelho do Saude ]----------------
          if (lr_param.crtsaunum is not null and
              lr_param.crtsaunum <> 0             ) or
              lr_param.ciaempcod = 50               then   ---> Saude

             call cta01m13(lr_param.crtsaunum,"","","")
                      returning w_retorno.succod,
                                w_retorno.ramcod,
                                w_retorno.aplnumdig,
                                w_retorno.crtsaunum,
                                w_retorno.bnfnum     # espelho saude
          else
             # Visualizar espelho do ramo RE
             if (lr_param.succod is not null and
                lr_param.aplnumdig is not null) or
                lr_param.cmnnumdig is not null then

                let g_monitor.horafnl = current
                let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini

                if  g_monitor.intervalo is null or
                    g_monitor.intervalo = ""    or
                    g_monitor.intervalo = " "   or
                    g_monitor.intervalo < "0:00:00.000" then
                    let g_monitor.intervalo = "0:00:00.999"
                end if

                let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                          "|CTA00M05-> ", g_issk.funmat,
                                          " ->", g_documento.ciaempcod

                let g_monitor.horaini   = g_monitor.horafnl
                call errorlog (g_monitor.txt)
                let g_monitor.txt = " "

                call cta00m16_chama_prog("ctg18", g_documento.ramcod,
                                                  g_documento.succod,
                                                  g_documento.aplnumdig,
                                                  g_documento.itmnumdig,
                                                  g_documento.edsnumref,
                                                  g_documento.ligcvntip,
                                                  g_documento.prporg,
                                                  g_documento.prpnumdig,
                                                  g_documento.solnom,
                                                  g_documento.ciaempcod,
                                                  g_documento.ramgrpcod,
                                                  g_documento.c24soltipcod,
                                                  g_documento.corsus,
                                                  g_documento.atdnum,
                                                  g_documento.lclnumseq,
                                                  g_documento.rmerscseq,
                                                  g_documento.itaciacod)
                                            returning l_status
                      if l_status = -1 then
                           error "Espelho da apolice nao disponivel no momento" sleep 2
                      end if
             else
                error " Espelho so com documento localizado! "
             end if
          end if
       end if
     end if
    end if
 else
    ## Visualizar espelho da Empresa Azul
    if lr_param.ciaempcod = 35 then

       if lr_param.aplnumdig is not null or
          lr_param.prpnumdig is not null then
          #call cts42g00_doc_handle(lr_param.succod, lr_param.ramcod,
          #                         lr_param.aplnumdig, lr_param.itmnumdig,
          #                         g_documento.edsnumref)
          #     returning l_resultado, l_mensagem, l_doc_handle
          #call cta01m03(l_doc_handle)

          ## Flexvision - Pegar hora com segundos
          let g_monitor.horafnl = current
          let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini
          if  g_monitor.intervalo is null or
              g_monitor.intervalo = ""    or
              g_monitor.intervalo = " "   or
              g_monitor.intervalo < "0:00:00.000" then
              let g_monitor.intervalo = "0:00:00.999"
          end if

          let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                    "|CTA00M05-> ", g_issk.funmat,
                                    " ->", g_documento.ciaempcod

          let g_monitor.horaini   = g_monitor.horafnl
          call errorlog (g_monitor.txt)
          let g_monitor.txt = " "

          call cta00m16_chama_prog("ctg18", g_documento.ramcod,
                                            g_documento.succod,
                                            g_documento.aplnumdig,
                                            g_documento.itmnumdig,
                                            g_documento.edsnumref,
                                            g_documento.ligcvntip,
                                            g_documento.prporg,
                                            g_documento.prpnumdig,
                                            g_documento.solnom,
                                            g_documento.ciaempcod,
                                            g_documento.ramgrpcod,
                                            g_documento.c24soltipcod,
                                            g_documento.corsus,
                                            g_documento.atdnum,
                                            g_documento.lclnumseq,
                                            g_documento.rmerscseq,
                                            g_documento.itaciacod)
                                         returning l_status
                      if l_status = -1 then
                           error "Espelho da apolice nao disponivel no momento" sleep 2
                      end if
       else
          error " Espelho so com documento localizado! "
       end if
    else
        #PSS
       if lr_param.ciaempcod = 43 or lr_param.ciaempcod = 40 then

          if g_pss.psscntcod is not null then
             call cta00m26_espelho(g_pss.psscntcod)
          else
             if g_documento.cgccpfnum is not null then

                let ws.txt2 = "CARTAO PORTO SEGURO"

                if g_documento.cgcord is null or
                   g_documento.cgcord = 0     then
                   let lr_ffpfc073.pestipcod = "F"
                else
                   let lr_ffpfc073.pestipcod = "J"
                end if

                let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(g_documento.cgccpfnum,
                                                                       g_documento.cgcord   ,
                                                                       g_documento.cgccpfdig)

                call ffpfc073_rec_prop(lr_ffpfc073.cgccpfnumdig,
                                       lr_ffpfc073.pestipcod   )
                returning lr_ffpfc073.mens      ,
                          lr_ffpfc073.erro      ,
                          lr_ffpfc073.crdprpnom

                let ws.txt3 = "PROPONENTE: ", lr_ffpfc073.crdprpnom

                if g_documento.cgcord is null or
                   g_documento.cgcord = 0     then
                   let ws.txt4 = "CPF:", g_documento.cgccpfnum using "&&&&&&&&&", "-" ,g_documento.cgccpfdig using "&&"
                else
                   let ws.txt4 = "CGC:", g_documento.cgccpfnum using "&&&&&&&&&/" ,g_documento.cgcord using "&&&&", "-" ,g_documento.cgccpfdig using "&&"
                end if

                let ws.confirma = cts08g01("A","N", ws.txt1, ws.txt2, ws.txt3, ws.txt4)

             end if

          end if

       else
          if g_documento.ciaempcod = 84 then

           if lr_param.aplnumdig is not null then

             let g_monitor.horafnl = current
             let g_monitor.intervalo = g_monitor.horafnl - g_monitor.horaini
             if  g_monitor.intervalo is null or
                 g_monitor.intervalo = ""    or
                 g_monitor.intervalo = " "   or
                 g_monitor.intervalo < "0:00:00.000" then
                 let g_monitor.intervalo = "0:00:00.999"
             end if

             let g_monitor.txt       = "CONSULTA DE APOLICE |", g_monitor.intervalo,
                                       "|CTA00M05-> ", g_issk.funmat,
                                       " ->", g_documento.ciaempcod

             let g_monitor.horaini   = g_monitor.horafnl
             call errorlog (g_monitor.txt)
             let g_monitor.txt = " "

	     ### Inicio chamado 130125126
             # Reculpera a ultima sequencia da Apolice
             call cty22g00_rec_ult_sequencia(g_documento.itaciacod ,
                                             g_documento.ramcod    ,
                                             g_documento.aplnumdig )
             returning g_documento.edsnumref,
                       l_resultado ,
                       l_mensagem
	     ### Final chamado 130125126
             call cta00m16_chama_prog("ctg18", g_documento.ramcod,
                                               g_documento.succod,
                                               g_documento.aplnumdig,
                                               g_documento.itmnumdig,
                                               g_documento.edsnumref,
                                               g_documento.ligcvntip,
                                               g_documento.prporg,
                                               g_documento.prpnumdig,
                                               g_documento.solnom,
                                               g_documento.ciaempcod,
                                               g_documento.ramgrpcod,
                                               g_documento.c24soltipcod,
                                               g_documento.corsus,
                                               g_documento.atdnum,
                                               g_documento.lclnumseq,
                                               g_documento.rmerscseq,
                                               g_documento.itaciacod)
                                            returning l_status
                         if l_status = -1 then
                              error "Espelho da apolice nao disponivel no momento" sleep 2
                         end if
             else
               error " Espelho so com documento localizado! "
             end if

          else
           error "Empresa nao implementada"
          end if
      end if
    end if
 end if

end function
