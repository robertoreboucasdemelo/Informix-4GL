#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta01m10.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 186.376                                                    #
# OSF           : 038.105                                                    #
#                 Funcoes F1 para Auto.                                      #
#............................................................................#
# Desenvolvimento: Meta, Gustavo L. Spadari                                  #
# Liberacao      : 27/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 24/01/2005 Daniel, Meta      PSI190080  Inclusao da funcao cta01m10_funcoes#
# 09/10/06   Ligia Mattge      PSI 202720 Implementar cartao Saude           #
# 27/06/2007 Roberto           PSI 207446 Inclusao da funcao cta01m10_vida   #
# 29/12/2009 Patricia W.                  Projeto SUCCOD - Smallint          #
#----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo    PSI 219444 Passar p/ "cta00m16_chama_prog" os #
#                                         campos lclnumseq / rmerscseq (RE)  #
#----------------------------------------------------------------------------#
# 22/10/2010 Patricia W.       PSI 260479 Remover Opções do F1 quando tela de#
#                                         origem for Espelho da Proposta     #
#----------------------------------------------------------------------------#


globals  '/homedsa/projetos/geral/globals/glct.4gl'
globals  "/homedsa/projetos/geral/globals/figrc072.4gl"

#---------------------------------#
 function cta01m10_auto(lr_param)
#---------------------------------#
 define lr_param    record
        ramcod      smallint,
        succod      like datrligapol.succod,  #decimal(2,0), #projeto succod
        aplnumdig   decimal(9,0),
        itmnumdig   decimal(7,0),
        dctnumseq   decimal(4,0),
        prporg      decimal(2,0),
        prpnumdig   decimal(9,0),
        cvnnum      smallint,
        tpchamada   smallint
 end record

 define l_popup           char(200)
       ,l_par1            char(10)
       ,l_par2            char(09)
       ,l_par3            char(04)
       ,l_par4            char(01)
       ,l_opcao           smallint
       ,l_descricao       char(20)
       ,l_nulo            smallint
       ,l_flag            smallint
       ,l_zero            smallint
       ,l_resultado       smallint
       ,l_mensagem        char(60)
       ,l_segnumdig       like abbmdoc.segnumdig
       ,l_nomseg          like gsakseg.segnom
       ,l_pestip          like gsakseg.pestip
       ,l_cgccpfnum       like gsakseg.cgccpfnum
       ,l_cgcord          like gsakseg.cgcord
       ,l_cgccpfdig       like gsakseg.cgccpfdig
       ,l_unfclisegcod    like gsakdocngcseg.unfclisegcod
       ,w_ret             integer
       
  
 ###  Montar popup com as opcoes
 # retirar a opcao "Procedimentos" para Azul Seguros e Itau

 if g_documento.ciaempcod = 35 or
    g_documento.ciaempcod = 84 then
    let l_popup  = "Clientes|Auto_ct|Con_ct|Procedimentos|Carta_Transf_Corretagem|Sistemas"

 else

    if lr_param.tpchamada = 1 then
       let l_popup  = "Clientes|Auto_ct|Con_ct|Procedimentos|Carta_Transf_Corretagem|Sistemas|Notas_Sinistros|Vantagens"
    else if lr_param.tpchamada = 0 then
            let l_popup  = "Clientes|Auto_ct|Con_ct|Procedimentos|Carta_Transf_Corretagem|Sistemas|Vantagens"
         else                  
            # tpchamada = 2 - Espelho da Proposta # PSI260479
            let l_popup  = "Clientes|Auto_ct|Con_ct|Procedimentos|Sistemas"
         end if
    end if
 end if


 let l_par1   = "FUNCOES"
 let l_par2   = "Con_ct24h"
 let l_par3   = "ctg3"
 let l_par4   = ""
 let l_nulo   = null
 
 while true
    
    ### Montar a popup na tela  para a escolha da opcao
    call ctx14g01(l_par1, l_popup)
         returning l_opcao, l_descricao

    if l_opcao = 0 then
       exit while
    end if

    ### Tratamento para cada opcao
    if l_opcao = 1 then    # Clientes
       ### Pesquisar o codigo do segurado atraves da apolice
       
       call figrc072_setTratarIsolamento()
       
       call cty05g00_segnumdig(lr_param.succod,
                               lr_param.aplnumdig,
                               lr_param.itmnumdig,
                               lr_param.dctnumseq,
                               lr_param.prporg,
                               lr_param.prpnumdig)
            returning l_resultado, l_mensagem, l_segnumdig
       
       if g_isoAuto.sqlCodErr <> 0 then                                    
          let l_resultado = g_isoAuto.sqlCodErr                            
          let l_mensagem  = "Pesquisa do Codigo do Segurado Indisponivel! Erro: " 
                ,g_isoAuto.sqlCodErr                                       
       end if                                                              
      
       if l_resultado <> 1 then
          error l_mensagem sleep 2
       end if

       ### Obter o codigo geral do segurado  atraves do codigo do segurado
       call cty15g00_obter_codgeral(l_segnumdig, l_nulo, l_nulo, l_nulo)
            returning l_resultado, l_mensagem, l_unfclisegcod, l_nomseg

       ### Obter nome e cgc/cpf do segurado
       call cty03g00_dados_segurado(l_segnumdig)
            returning l_resultado, l_mensagem, l_nomseg,
                      l_pestip, l_cgccpfnum, l_cgcord, l_cgccpfdig
       if l_resultado <> 1 then
          error l_mensagem
       end if

       if l_unfclisegcod is null then
          ### Obter o codigo geral do segurado  atraves do cgc/cpf
          call cty15g00_obter_codgeral(l_nulo,l_cgccpfnum,l_cgcord,l_cgccpfdig)
               returning l_resultado, l_mensagem, l_unfclisegcod, l_nomseg
       end if

       ### Pesquisar Negocios dos clientes
       call cta01m10_neg_clientes(l_unfclisegcod,
                                  l_nomseg,
                                  l_pestip,
                                  l_cgccpfnum,
                                  l_cgcord,
                                  l_cgccpfdig)
    end if

    if l_opcao =  2 then  # Auto_ct
       call ctn49c00()
    end if

    if l_opcao =  3 then  # Con_ct
       let l_flag = chama_prog(l_par2, l_par3, l_par4)
       if l_flag = -1 then
          error " Modulo Con_ct24h nao disponivel no momento!"
       end if
    end if

    if g_documento.ciaempcod = 35 or
       g_documento.ciaempcod = 84 then
                            
       if l_opcao = 4 then # Procedimentos   
          call ctn13c00(lr_param.cvnnum)  
       end if                             
       
       if l_opcao = 5 then # Carta_Transf_Corretagem 
          call ctc09m00(l_zero,l_zero)               
       end if                                        

       if l_opcao = 6 then # Sistemas
          call ctx27g00()
       end if

       if l_opcao = 7 then # Notas Sinistro
           call cta01m10_lig_sinis()  
       end if
       
    else
       if l_opcao = 4 then # Procedimentos
          call ctn13c00(lr_param.cvnnum)                                   
       end if

       if lr_param.tpchamada = 1 then
          if l_opcao = 5 then # Carta_Transf_Corretagem
             call ctc09m00(l_zero,l_zero)
          end if
   
          if l_opcao = 6 then # Sistemas
             call ctx27g00()
          end if
          if l_opcao = 7 then # Notas Sinistro
              call cta01m10_lig_sinis() 
          end if
          if l_opcao = 8 then # Vantagens
              call cty05g04_vantagens()    
          end if                                     
       else
          if lr_param.tpchamada = 0 then
             if l_opcao = 5 then # Carta_Transf_Corretagem
                call ctc09m00(l_zero,l_zero)
             end if
      
             if l_opcao = 6 then # Sistemas
                call ctx27g00()
             end if
             if l_opcao = 7 then # Vantagens      
                 call cty05g04_vantagens() 
             end if
          else 
             if l_opcao = 5 then # Sistemas
                call ctx27g00()
             end if
          end if   
       end if
    end if
 end while

end function

#--------------------------------------#
 function cta01m10_re_transp(lr_param)
#--------------------------------------#
 define lr_param    record
        ramcod      smallint,
        succod      like datrligapol.succod,  #decimal(2,0), #projeto succod
        aplnumdig   decimal(9,0),
        prporg      decimal(2,0),
        prpnumdig   decimal(9,0),
        cvnnum      smallint
 end record

 define l_popup           char(200)
       ,l_par1            char(10)
       ,l_par2            char(09)
       ,l_par3            char(04)
       ,l_par4            char(01)
       ,l_opcao           smallint
       ,l_descricao       char(20)
       ,l_nulo            smallint
       ,l_flag            smallint
       ,l_resultado       smallint
       ,l_mensagem        char(60)
       ,l_sgrorg          like rsamseguro.sgrorg
       ,l_sgrnumdig       like rsamseguro.sgrnumdig
       ,l_segnumdig       like abbmdoc.segnumdig
       ,l_nomseg          like gsakseg.segnom
       ,l_pestip          like gsakseg.pestip
       ,l_cgccpfnum       like gsakseg.cgccpfnum
       ,l_cgcord          like gsakseg.cgcord
       ,l_cgccpfdig       like gsakseg.cgccpfdig
       ,l_unfclisegcod    like gsakdocngcseg.unfclisegcod

 ### Montar popup com as opcoes
 let l_popup  = "Clientes|Con_ct|Procedimentos|Carta_Transf_Corretagem|Sistemas"
 let l_par1   = "FUNCOES"
 let l_par2   = "Con_ct24h"
 let l_par3   = "ctg3"
 let l_par4   = ""
 let l_nulo   = null

 ### Obter nr. do seguro
 call cty06g00_obter_seguro(lr_param.ramcod,lr_param.succod,lr_param.aplnumdig)
      returning l_resultado, l_mensagem, l_sgrorg, l_sgrnumdig
 if l_resultado <> 1 then
    error l_mensagem
 end if

 while true

    ### Montar a popup na tela  para a escolha da opcao
    call ctx14g01(l_par1, l_popup)
         returning l_opcao, l_descricao

    if l_opcao = 0 then
       exit while
    end if

    ### Tratamento para cada opcao
    if l_opcao = 1 then
       ### Pesquisar o codigo do segurado atraves do nr. do seguro
       call cty06g00_segnumdig(l_sgrorg,
                               l_sgrnumdig,
                               lr_param.prporg,
                               lr_param.prpnumdig)
            returning l_resultado, l_mensagem, l_segnumdig
       if l_resultado <> 1 then
          error l_mensagem
       end if

       ### Obter o codigo geral do segurado  atraves do codigo do segurado
       call cty15g00_obter_codgeral(l_segnumdig, l_nulo, l_nulo, l_nulo)
            returning l_resultado, l_mensagem, l_unfclisegcod, l_nomseg

       ### Obter nome e cgc/cpf do segurado
       call cty03g00_dados_segurado(l_segnumdig)
            returning l_resultado, l_mensagem, l_nomseg,
                      l_pestip, l_cgccpfnum, l_cgcord, l_cgccpfdig
       if l_resultado <> 1 then
          error l_mensagem
       end if

       if l_unfclisegcod is null then
          ### Obter o codigo geral do segurado atraves do cgc/cpf
          call cty15g00_obter_codgeral(l_nulo,l_cgccpfnum,l_cgcord,l_cgccpfdig)
               returning l_resultado, l_mensagem, l_unfclisegcod, l_nomseg
       end if

       ### Pesquisar Negocios dos clientes
       call cta01m10_neg_clientes(l_unfclisegcod, l_nomseg, l_pestip,
                                  l_cgccpfnum, l_cgcord, l_cgccpfdig)
    end if

    if l_opcao = 2 then
       let l_flag = chama_prog(l_par2, l_par3, l_par4)
       if l_flag = -1 then
          error " Modulo Con_ct24h nao disponivel no momento!"
       end if
    end if

    if l_opcao = 3 then
       call ctn13c00(lr_param.cvnnum)  ### Procedimentos Operacionais
    end if

    if l_opcao = 4 then
       call ctc09m00(l_sgrorg, l_sgrnumdig)
    end if
    if l_opcao = 5 then
       call ctx27g00()
    end if

 end while

end function

#--------------------------------------#
 function cta01m10_propat(lr_param)
#--------------------------------------#
 define lr_param    record
        segnumdig   decimal(9,0),
        cvnnum      smallint
 end record

 define l_popup           char(200)
       ,l_par1            char(10)
       ,l_par2            char(09)
       ,l_par3            char(04)
       ,l_par4            char(01)
       ,l_opcao           smallint
       ,l_descricao       char(20)
       ,l_nulo            smallint
       ,l_flag            smallint
       ,l_resultado       smallint
       ,l_mensagem        char(60)
       ,l_segnumdig       like abbmdoc.segnumdig
       ,l_nomseg          like gsakseg.segnom
       ,l_pestip          like gsakseg.pestip
       ,l_cgccpfnum       like gsakseg.cgccpfnum
       ,l_cgcord          like gsakseg.cgcord
       ,l_cgccpfdig       like gsakseg.cgccpfdig
       ,l_unfclisegcod    like gsakdocngcseg.unfclisegcod

 ### Montar popup com as opcoes
 let l_popup  = "Clientes|Con_ct|Procedimentos|Sistemas"
 let l_par1   = "FUNCOES"
 let l_par2   = "Con_ct24h"
 let l_par3   = "ctg3"
 let l_par4   = ""
 let l_nulo   = null


 while true

   ### Montar a popup na tela para a escolha da opcao
   call ctx14g01(l_par1
                ,l_popup)
   returning l_opcao
            ,l_descricao

   if l_opcao = 0 then
      exit while
   end if

   ### Tratamento para cada opcao
   if l_opcao = 1 then

      ### Obter o codigo geral do segurado atraves do codigo
      call cty15g00_obter_codgeral(lr_param.segnumdig
                                  ,l_nulo
                                  ,l_nulo
                                  ,l_nulo)
           returning l_resultado
                    ,l_mensagem
                    ,l_unfclisegcod
                    ,l_nomseg

      ### Obter nome e cgc/cpf do segurado
      call cty03g00_dados_segurado(lr_param.segnumdig)
      returning l_resultado
               ,l_mensagem
               ,l_nomseg
               ,l_pestip
               ,l_cgccpfnum
               ,l_cgcord
               ,l_cgccpfdig
      if l_resultado <> 1 then
         error l_mensagem
      end if

      if l_unfclisegcod is null then
         ### Obter o codigo geral do segurado atraves do cgc/cpf
         call cty15g00_obter_codgeral(l_nulo
                                     ,l_cgccpfnum
                                     ,l_cgcord
                                     ,l_cgccpfdig)
         returning l_resultado
                  ,l_mensagem
                  ,l_unfclisegcod
                  ,l_nomseg
      end if

      ### Pesquisar Negocios dos clientes
      call cta01m10_neg_clientes(l_unfclisegcod
                                ,l_nomseg
                                ,l_pestip
                                ,l_cgccpfnum
                                ,l_cgcord
                                ,l_cgccpfdig)
   end if

   if l_opcao = 2 then
      let l_flag = chama_prog(l_par2, l_par3, l_par4)
      if l_flag = -1 then
         error " Modulo Con_ct24h nao disponivel no momento!"
      end if
   end if

   if l_opcao = 3 then
      call ctn13c00(lr_param.cvnnum)  ### Procedimentos Operacionais
   end if

   if l_opcao = 4 then
      call ctx27g00()
   end if

 end while

end function

#--------------------------------------#
 function cta01m10_sem_docto(lr_param)
#--------------------------------------#
 define lr_param    record
        pestip      like gsakseg.pestip,
        cgccpfnum   like gsakseg.cgccpfnum,
        cgcord      like gsakseg.cgcord,
        cgccpfdig   like gsakseg.cgccpfdig,
        cvnnum      smallint
 end record

 define l_popup           char(200)
       ,l_par1            char(10)
       ,l_par2            char(09)
       ,l_par3            char(04)
       ,l_par4            char(01)
       ,l_opcao           smallint
       ,l_descricao       char(20)
       ,l_nulo            smallint
       ,l_flag            smallint
       ,l_resultado       smallint
       ,l_mensagem        char(60)
       ,l_nomseg          like gsakseg.segnom
       ,l_unfclisegcod    like gsakdocngcseg.unfclisegcod

 ### Montar popup com as opcoes
 let l_popup  = "Clientes|Auto_ct|Con_ct|Procedimentos|Sistemas"
 let l_par1   = "FUNCOES"
 let l_par2   = "Con_ct24h"
 let l_par3   = "ctg3"
 let l_par4   = ""
 let l_nulo   = null


 while true

   ### Montar a popup na tela para escolhar da opcao
   call ctx14g01(l_par1, l_popup)
        returning l_opcao, l_descricao

   if l_opcao = 0 then
      exit while
   end if

   ### Tratamento para cada opcao
   if l_opcao = 1 then

      ### Obter codigo geral e nome do segurado
          call cty15g00_obter_codgeral(l_nulo
                                      ,lr_param.cgccpfnum
                                      ,lr_param.cgcord
                                      ,lr_param.cgccpfdig)
               returning l_resultado, l_mensagem, l_unfclisegcod, l_nomseg

      ### Pesquisar Negocios dos clientes
      call cta01m10_neg_clientes(l_unfclisegcod,
                                 l_nomseg,
                                 lr_param.pestip,
                                 lr_param.cgccpfnum,
                                 lr_param.cgcord,
                                 lr_param.cgccpfdig)
   end if

   if l_opcao = 2 then
      call ctn49c00()   ## Auto Ct24h
   end if

   if l_opcao = 3 then
      let l_flag = chama_prog(l_par2, l_par3, l_par4)
      if l_flag = -1 then
         error " Modulo Con_ct24h nao disponivel no momento!"
      end if
   end if

   if l_opcao = 4 then
      call ctn13c00(lr_param.cvnnum)   ### Procedimentos Operacionais
   end if
   if l_opcao = 5 then
      call ctx27g00()
   end if

 end while

end function

#-----------------------------------------#
 function cta01m10_neg_clientes(lr_param)
#-----------------------------------------#
 define lr_param        record
        seggernumdig    like gsakdocngcseg.unfclisegcod,
        segnom          like gsakseg.segnom,
        pestip          like gsakseg.pestip,
        cgccpfnum       like gsakseg.cgccpfnum,
        cgcord          like gsakseg.cgcord,
        cgccpfdig       like gsakseg.cgccpfdig
 end record

 define l_par1       char(10)
       ,l_par2       char(35)
       ,l_par3       char(05)
       ,l_opcao      smallint
       ,l_descricao  char(50)
       ,l_comando    char(500)
       ,l_status     smallint
       ,l_um         smallint
       
 let l_par3 = 'ctg17' 
 let l_um   = 1
 


  let l_comando = "' ", g_issk.succod         using "<<<<<<<&",     "'  ",
                  " '", g_issk.funmat         using "<<<<<<<&",     " ' ",
                  "' ", g_issk.funnom         clipped,              "  '",
                  " '", g_issk.dptsgl         clipped,              " ' ",
                  " '", g_issk.dpttip         clipped,              " ' ",
                  " '", g_issk.dptcod         using "<<<<<<&",      " ' ",
                  " '", g_issk.sissgl         clipped,              " ' ",
                  " '", g_issk.acsnivcod      using "<<<<<&",       " ' ",
                  " '", "Central24h",                               " '",
                  " '", g_issk.usrtip         clipped,              " ' ",
                  " '", g_issk.empcod         using "<<<<<<&",      " ' ",
                  " '", g_issk.iptcod         using "<<<<<<&",      " ' ",
                  " '", g_issk.usrcod         clipped,              " ' ",
                  " '", g_issk.maqsgl         clipped,              " ' ",
                  " '", l_opcao               using "<<<<<&",       " ' ",
                  " '", lr_param.seggernumdig using "<<<<<<<&",     " ' ",
                  " ' ",lr_param.segnom       clipped,               " ' ",
                  " '", lr_param.pestip       clipped,              " ' ",
                  " '", lr_param.cgccpfnum    using "<<<<<<<<<<<&", " ' ",
                  " '", lr_param.cgcord       using "<<<<<&&&&",    " ' ",
                  " '", lr_param.cgccpfdig    using "<<<<&&",       "' "

  let l_status = roda_prog(l_par3, l_comando, l_um)

  if l_status = -1 then
     error "Sistema nao disponivel no momento."
  end if

end function

#-----------------------------------------------------
function cta01m10_funcoes(lr_param)
#-----------------------------------------------------

 define lr_param     record
    ramcod           smallint
   ,succod           like datrligapol.succod  #decimal(2,0) #projeto succod
   ,aplnumdig        decimal(9,0)
   ,itmnumdig        decimal(7,0)
   ,prporg           decimal(2,0)
   ,prpnumdig        decimal(9,0)
   ,cmnnumdig        like pptmcmn.cmnnumdig
   ,segnumdig        like abbmdoc.segnumdig
   ,cgccpfnum        like gsakseg.cgccpfnum
   ,cgcord           like gsakseg.cgcord
   ,cgccpfdig        like gsakseg.cgccpfdig
   ,ligcvntip        smallint      
   ,dctnumseq        decimal(4,0)
   ,crtsaunum        like datksegsau.crtsaunum
 end record

 define l_resultado  smallint
 define l_mensagem   char(60)
 define l_cvnnum     like abamapol.cvnnum
 define l_pestip     like gsakseg.pestip
       ,l_unfclisegcod    like gsakdocngcseg.unfclisegcod
       ,l_nomseg          like gsakseg.segnom
       ,l_nomseg2         like gsakseg.segnom
       

 if lr_param.cgcord is null or
    lr_param.cgcord = 0 then
    let l_pestip =  "F"
 else
    let l_pestip = "J"
 end if

 # Se o ramo for de Auto com apolice ou proposta informada

 if (lr_param.ramcod = 31 or
    lr_param.ramcod = 531) and
    (lr_param.aplnumdig is not null or
    lr_param.prpnumdig is not null) then

    
    call figrc072_setTratarIsolamento()
    
    # Obter o convenio
    call cty05g00_convenio(lr_param.succod,lr_param.aplnumdig
                          ,lr_param.prporg,lr_param.prpnumdig)
       returning l_resultado,l_mensagem,l_cvnnum

    if g_isoAuto.sqlCodErr <> 0 then                 
       let l_resultado = g_isoAuto.sqlCodErr
       let l_mensagem  = "Recuperacao do Convenio Indisponivel! Erro: "  
             ,g_isoAuto.sqlCodErr                    
    end if                                           
    
    if l_resultado <> 1 then
       error l_mensagem
       return
    end if

    # Exibe as funcoes para ramo Auto
    call cta01m10_auto(lr_param.ramcod
                      ,lr_param.succod
                      ,lr_param.aplnumdig
                      ,lr_param.itmnumdig
                      ,lr_param.dctnumseq
                      ,lr_param.prporg
                      ,lr_param.prpnumdig
                      ,l_cvnnum
                      ,1)        
 else
    if lr_param.cmnnumdig is not null then
       # Exibe as funcoes para o Alarmes Monitorados
       call cta01m10_propat(lr_param.segnumdig,0)
    else
       # Exibe as funcoes para o Saude ## PSI 202720
       if lr_param.crtsaunum is not null then

          ## Obter o cgccpf do segurado Saude
          call cta01m15_sel_datksegsau(8, lr_param.crtsaunum, "","","")
               returning l_resultado,
                         l_mensagem,
                         l_nomseg, lr_param.cgccpfnum,
                         lr_param.cgcord, lr_param.cgccpfdig

          if lr_param.cgcord is null or
             lr_param.cgcord = 0 then
             let l_pestip =  "F"
          else
             let l_pestip = "J"
          end if

          ### Obter o codigo geral do segurado  atraves do cgc/cpf
          call cty15g00_obter_codgeral("", lr_param.cgccpfnum,
                                       lr_param.cgcord, lr_param.cgccpfdig)
               returning l_resultado, l_mensagem, l_unfclisegcod, l_nomseg2

          ### Pesquisar Negocios dos clientes
          call cta01m10_neg_clientes(l_unfclisegcod, l_nomseg,
                                     l_pestip,
                                     lr_param.cgccpfnum,
                                     lr_param.cgcord,
                                     lr_param.cgccpfdig)

       else

        if lr_param.ramcod = 991  or 
           lr_param.ramcod = 1391 then

              # Obter o convenio do Vida
              call cty06g00_convenio(lr_param.ramcod
                                    ,lr_param.succod
                                    ,lr_param.aplnumdig
                                    ,lr_param.prporg
                                    ,lr_param.prpnumdig)
                 returning l_resultado,l_mensagem,l_cvnnum

                 # Exibe as funcoes para o Vida
                 call cta01m10_vida(lr_param.ramcod
                                   ,lr_param.succod
                                   ,lr_param.aplnumdig
                                   ,lr_param.prporg
                                   ,lr_param.prpnumdig
                                   ,l_cvnnum)

        else


          # Exibe as funcoes para ramo  RE
          if (lr_param.aplnumdig is not null or
              lr_param.prpnumdig is not null) then

              # Obter o convenio do RE
              call cty06g00_convenio(lr_param.ramcod
                                    ,lr_param.succod
                                    ,lr_param.aplnumdig
                                    ,lr_param.prporg
                                    ,lr_param.prpnumdig)
                 returning l_resultado,l_mensagem,l_cvnnum

              # Exibe as funcoes para o Re
              call cta01m10_re_transp(lr_param.ramcod
                                     ,lr_param.succod
                                     ,lr_param.aplnumdig
                                     ,lr_param.prporg
                                     ,lr_param.prpnumdig
                                     ,l_cvnnum)
          else
              # Exibe as funcoes para atendimento sem documento informado
              call cta01m10_sem_docto(l_pestip
                                     ,lr_param.cgccpfnum
                                     ,lr_param.cgcord
                                     ,lr_param.cgccpfdig
                                     ,lr_param.ligcvntip)
          end if
       end if
    end if
   end if
 end if

end function

#--------------------------------------#
 function cta01m10_vida(lr_param)
#--------------------------------------#
 define lr_param    record
        ramcod      smallint,
        succod      like datrligapol.succod,  #decimal(2,0),  #projeto succod
        aplnumdig   decimal(9,0),
        prporg      decimal(2,0),
        prpnumdig   decimal(9,0),
        cvnnum      smallint
 end record

 define l_popup           char(200)
       ,l_par1            char(10)
       ,l_par2            char(09)
       ,l_par3            char(04)
       ,l_par4            char(01)
       ,l_opcao           smallint
       ,l_descricao       char(20)
       ,l_nulo            smallint
       ,l_flag            smallint
       ,l_resultado       smallint
       ,l_mensagem        char(60)
       ,l_sgrorg          like rsamseguro.sgrorg
       ,l_sgrnumdig       like rsamseguro.sgrnumdig
       ,l_segnumdig       like abbmdoc.segnumdig
       ,l_nomseg          like gsakseg.segnom
       ,l_pestip          like gsakseg.pestip
       ,l_cgccpfnum       like gsakseg.cgccpfnum
       ,l_cgcord          like gsakseg.cgcord
       ,l_cgccpfdig       like gsakseg.cgccpfdig
       ,l_unfclisegcod    like gsakdocngcseg.unfclisegcod

 ### Montar popup com as opcoes
 let l_popup  = "Clientes|Con_ct"
 let l_par1   = "FUNCOES"
 let l_par2   = "Con_ct24h"
 let l_par3   = "ctg3"
 let l_par4   = ""
 let l_nulo   = null

 ### Obter nr. do seguro
 call cty06g00_obter_seguro(lr_param.ramcod,lr_param.succod,lr_param.aplnumdig)
      returning l_resultado, l_mensagem, l_sgrorg, l_sgrnumdig
 if l_resultado <> 1 then
    error l_mensagem
 end if

 while true

    ### Montar a popup na tela  para a escolha da opcao
    call ctx14g01(l_par1, l_popup)
         returning l_opcao, l_descricao

    if l_opcao = 0 then
       exit while
    end if

    ### Tratamento para cada opcao
    if l_opcao = 1 then
       ### Pesquisar o codigo do segurado atraves do nr. do seguro
       call cty06g00_segnumdig(l_sgrorg,
                               l_sgrnumdig,
                               lr_param.prporg,
                               lr_param.prpnumdig)
            returning l_resultado, l_mensagem, l_segnumdig
       if l_resultado <> 1 then
          error l_mensagem
       end if

       ### Obter o codigo geral do segurado  atraves do codigo do segurado
       call cty15g00_obter_codgeral(l_segnumdig, l_nulo, l_nulo, l_nulo)
            returning l_resultado, l_mensagem, l_unfclisegcod, l_nomseg

       ### Obter nome e cgc/cpf do segurado
       call cty03g00_dados_segurado(l_segnumdig)
            returning l_resultado, l_mensagem, l_nomseg,
                      l_pestip, l_cgccpfnum, l_cgcord, l_cgccpfdig
       if l_resultado <> 1 then
          error l_mensagem
       end if

       if l_unfclisegcod is null then
          ### Obter o codigo geral do segurado atraves do cgc/cpf
          call cty15g00_obter_codgeral(l_nulo,l_cgccpfnum,l_cgcord,l_cgccpfdig)
               returning l_resultado, l_mensagem, l_unfclisegcod, l_nomseg
       end if

       ### Pesquisar Negocios dos clientes
       call cta01m10_neg_clientes(l_unfclisegcod, l_nomseg, l_pestip,
                                  l_cgccpfnum, l_cgcord, l_cgccpfdig)
    end if

    if l_opcao = 2 then
       let l_flag = chama_prog(l_par2, l_par3, l_par4)
       if l_flag = -1 then
          error " Modulo Con_ct24h nao disponivel no momento!"
       end if
    end if

 end while

end function                                                                                    
#---------------------------------------------------------------------------#
function cta01m10_lig_sinis()
#---------------------------------------------------------------------------#
#-- Chama opcao de Notas de Sinistro 

   define lr_retorno    record
          resultado     smallint
         ,mensagem      char(60)
         ,cvnnum        like abamapol.cvnnum
   end record

   define w_empcod    char(02)
         ,w_funmat    char(06)
         ,w_grlchv    like datkgeral.grlchv
         ,w_ct24      char(04)
         ,w_grlinf    like datkgeral.grlinf
         ,w_hora1     datetime hour to second
         ,w_data      date
         ,w_status    smallint
         ,w_prep_sql  smallint
         ,w_sql       char(300)


   let w_sql = " select grlinf ",
        "   from datkgeral ",
             "  where grlchv = ? "
   prepare p_cta01m10_001 from w_sql
   declare c_cta01m10_001 cursor for p_cta01m10_001

   call cts40g03_data_hora_banco(1)
        returning w_data
                 ,w_hora1

   let w_empcod       = g_issk.empcod
   let w_funmat       = g_issk.funmat using "&&&&&&"
   let w_grlchv[1,6]  = w_funmat
   let w_grlchv[7,14] = w_hora1
   let w_ct24         = "ct24h"
   let w_grlinf       = null

   initialize lr_retorno to null

   ##-- Selecionar datkgeral --##
   call cta12m00_seleciona_datkgeral(w_grlchv)
        returning lr_retorno.resultado
                 ,lr_retorno.mensagem
                 ,w_grlinf

   if lr_retorno.resultado = 1 then

      ##-- Remove de datkgeral --##
      call cta12m00_remove_datkgeral(w_grlchv)
           returning lr_retorno.resultado
                    ,lr_retorno.mensagem

      if lr_retorno.resultado <> 1 then
         error lr_retorno.mensagem
         return
      else
         call cta12m00_inclui_datkgeral(w_grlchv,
                                        w_ct24,
                                        w_data,
                                        w_hora1,
                                        w_empcod,
                                        w_funmat)
               returning lr_retorno.resultado
                        ,lr_retorno.mensagem

         if lr_retorno.resultado <> 1 then
            error lr_retorno.mensagem
            return
         end if
      end if
   else

      call cta12m00_inclui_datkgeral(w_grlchv,
                                     w_ct24,
                                     w_data,
                                     w_hora1,
                                     w_empcod,
                                     w_funmat)
           returning lr_retorno.resultado
                    ,lr_retorno.mensagem

      if lr_retorno.resultado <> 1 then
         error lr_retorno.mensagem
         return
      end if
   end if

   call cta00m16_chama_prog("cta02m00u11"
                           ,g_documento.ramcod
                           ,g_documento.succod
                           ,g_documento.aplnumdig
                           ,g_documento.itmnumdig
                           ,0
                           ,0
                           ,g_documento.prporg
                           ,g_documento.prpnumdig
                           ,w_grlchv,"","","",""
                           ,g_documento.atdnum 
                           ,g_documento.lclnumseq 
                           ,g_documento.rmerscseq
                           ,g_documento.itaciacod )
        returning w_status

   if w_status = 0 then

      open c_cta01m10_001 using w_grlchv

      whenever error continue
         fetch c_cta01m10_001 into w_grlinf
      whenever error stop

      if sqlca.sqlcode = 0 then

         let g_documento.sinramcod = w_grlinf[7,9]
         let g_documento.sinano    = w_grlinf[10,13]
         let g_documento.sinnum    = w_grlinf[14,19]
         let g_documento.sinitmseq = w_grlinf[20,21]

         call cta12m00_remove_datkgeral(w_grlchv)
              returning lr_retorno.resultado
                       ,lr_retorno.mensagem

         if lr_retorno.resultado <> 1 then
            error lr_retorno.mensagem
            return
         end if
      else

         if sqlca.sqlcode = notfound  then
            error " Nenhum registro selecionado."
                  , sqlca.sqlcode,"|",sqlca.sqlerrd[2]
            return
         else
            error " Problema SELECT na tabela datkgeral"
                  , sqlca.sqlcode,"|",sqlca.sqlerrd[2]
            return
         end if
      end if

      close c_cta01m10_001
   else
      error "Erro ao acessar tela de notas do sinistro."
      return
   end if

end function                                                                                    
