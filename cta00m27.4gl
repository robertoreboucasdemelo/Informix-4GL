#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                  #
# Modulo.........: cta00m27                                                  #
# Objetivo.......: Atendimento Itau Seguros                                  #
# Analista Resp. : Roberto Melo                                              #
# PSI            :                                                           #
#............................................................................#
# Desenvolvimento: Roberto Melo                                              #
# Liberacao      : 15/01/2010                                                #
#............................................................................#
# Objetivo.......: Alerta Bandeira                                           #
# Analista Resp. : Humberto Santos                                           #
# PSI            : PSI-2012-23721/EV                                         #
#............................................................................#
# Desenvolvimento: Humberto Santos                                           #
# Liberacao      : 31/05/2013                                                #
#............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_documento  record
    solnom        char (15),                        # Solicitante
    soltip        char (01),                        # Tipo Solicitante
    c24soltipcod  like datmligacao.c24soltipcod    ,# Tipo do Solicitante
    ligcvntip     like datmligacao.ligcvntip       ,# Convenio Operacional
    itaciacod     like datkitacia.itaciacod        ,# Conpanhia Itau
    succod        like datmitaapl.succod           ,# Codigo da Sucursal
    itaramcod     like datmitaapl.itaramcod        ,# Ramo da Apolice
    itaaplnum     like datmitaapl.itaaplnum        ,# Numero da Apolice
    itaaplitmnum  like datmitaaplitm.itaaplitmnum  ,# Item da Apolice
    aplseqnum     like datmitaapl.aplseqnum        ,# Sequencia da Apolice
    empcodatd     like datmligatd.apoemp           ,# Empresa do atendente
    funmatatd     like datmligatd.apomat           ,# Matricula do atendente
    usrtipatd     like datmligatd.apotip           ,# Tipo do atendente
    corsus        char(06)                         ,# Susep da Apolice
    dddcod        char(04)                         ,# Codigo da area de discagem
    ctttel        char(20)                         ,# Numero do telefone
    funmat        decimal(6,0)                     ,# Matricula do funcionario
    cgccpfnum     decimal(12,0)                    ,# Numero do CGC(CNPJ)
    cgcord        decimal(4,0)                     ,# Filial do CGC(CNPJ)
    cgccpfdig     decimal(2,0)                     ,# Digito do CGC(CNPJ) ou CPF
    c24paxnum     like datmligacao.c24paxnum       ,# Numero da P.A.
    semdocto      char(01)                          # Sem Documento
end record

define mr_tela record
    atdnum        like datmatd6523.atdnum
   ,solnom        like datmligacao.c24solnom
   ,c24soltipcod  like datmligacao.c24soltipcod
   ,c24soltipdes  char (40)
   ,itaciacod     like datkitacia.itaciacod
   ,itaciades     like datkitacia.itaciades
   ,itaramcod     like datmitaapl.itaramcod
   ,ramnom        char (40)
   ,itaaplnum     like datmitaapl.itaaplnum
   ,itaaplitmnum  like datmitaaplitm.itaaplitmnum
   ,autplcnum     like datmitaaplitm.autplcnum
   ,segnom        like datmitaapl.segnom
   ,pestipcod     like datmitaapl.pestipcod
   ,pesnom        char (08)
   ,segcgccpfnum  like datmitaapl.segcgccpfnum
   ,segcgcordnum  like datmitaapl.segcgcordnum
   ,segcgccpfdig  like datmitaapl.segcgccpfdig
   ,itaprpnum     like datmitaapl.itaprpnum
   ,autchsnum     like datmitaaplitm.autchsnum
   ,semdocto      char(01)
end record

define mr_atd record
     cgccpfnum          like gsakpes.cgccpfnum
    ,cgcord             like gsakpes.cgcord
    ,cgccpfdig          like gsakpes.cgccpfdig
    ,pestip             like gsakpes.pestip
    ,pesnom             like gsakpes.pesnom
    ,semdocto           char(1)
    ,semdoctoempcodatd  like datmatd6523.semdoctoempcodatd
    ,semdoctopestip     like datmatd6523.semdoctopestip
    ,semdoctocgccpfnum  like datmatd6523.semdoctocgccpfnum
    ,semdoctocgcord     like datmatd6523.semdoctocgcord
    ,semdoctocgccpfdig  like datmatd6523.semdoctocgccpfdig
    ,semdoctocorsus     like datmatd6523.semdoctocorsus
    ,semdoctofunmat     like datmatd6523.semdoctofunmat
    ,semdoctoempcod     like datmatd6523.semdoctoempcod
    ,semdoctodddcod     like datmatd6523.semdoctodddcod
    ,semdoctoctttel     like datmatd6523.semdoctoctttel
    ,aplnumdig          char(09)
    ,gera               char(01)
    ,novo_nroatd        like datmatd6523.atdnum
    ,controle           smallint
end record

define m_retorno smallint
#----------------------------------#
 function cta00m27(lr_param)
#----------------------------------#

define lr_param  record
       apoio     char(01),
       empcodatd like isskfunc.empcod,
       funmatatd like isskfunc.funmat,
       usrtipatd like issmnivnovo.usrtip,
       c24paxnum integer
end record

   ------[ verifica procedimentos para tela ]------
   call cts14g02("N", "cta00m27")

   open window cta00m27 at 3,2 with form "cta00m27"
      attributes(menu line 1)


   call cta00m27_input(lr_param.apoio      ,
                       lr_param.empcodatd  ,
                       lr_param.funmatatd  ,
                       lr_param.usrtipatd  ,
                       lr_param.c24paxnum  )

   close window cta00m27

   case mr_documento.semdocto
     when "S"
        let mr_documento.semdocto = true
     when "N"
        let mr_documento.semdocto = false
   end case

   let int_flag = false

   return mr_documento.*


end function

#----------------------------------------------#
 function cta00m27_input(lr_param)
#----------------------------------------------#

define lr_param  record
       apoio     char(01),
       empcodatd like isskfunc.empcod,
       funmatatd like isskfunc.funmat,
       usrtipatd like issmnivnovo.usrtip,
       c24paxnum integer
end record

define lr_aux record
       resultado  smallint                  ,
       mensagem   char(60)                  ,
       acsnivcod  like issmnivnovo.acsnivcod,
       c24paxtxt  char(12)                  ,
       ciaempcod  like datmatd6523.ciaempcod,
       confirma  char(01)
end record

define lr_retorno record
       qtd          integer                       ,
       itaciacod    like datkitacia.itaciacod     ,
       itaramcod    like datmitaapl.itaramcod     ,
       aplseqnum    like datmitaapl.aplseqnum     ,
       erro         integer                       ,
       mensagem     char(50)                      ,
       asterisco    char(01)                      ,
       tamanho      smallint                      ,
       succod       like datmitaapl.succod        ,
       segcgccpfdig like datmitaapl.segcgccpfdig
end record

define l_cont     smallint


while true

 initialize mr_atd.*       ,
            mr_tela.*      ,
            mr_documento.* ,
            lr_aux.*       ,
            lr_retorno.*   ,
            l_cont         to null

 for  l_cont  =  1  to  500
    initialize  g_doc_itau[l_cont].* to  null
 end  for

 let mr_documento.ligcvntip = 0
 let mr_documento.semdocto  = "N"
 let mr_atd.controle        = false
 let mr_atd.gera            = "N"   ---> Nao gera atendimento por esta tela
 let g_gera_atd             = "S"   ---> Controla se gera ou nao Atendimento na tela de Assunto
 let l_cont                 = null

 let m_retorno = 0

   input by name mr_tela.* without defaults

#--------------------------------------------------------------------------------------
# BEFORE ATDNUM
#--------------------------------------------------------------------------------------

      before field atdnum
         display by name mr_tela.atdnum attribute (reverse)

#--------------------------------------------------------------------------------------
# AFTER ATDNUM
#--------------------------------------------------------------------------------------

      after field atdnum
         display by name mr_tela.atdnum

         if mr_tela.atdnum = 0 then
            error " Nro.Atendimento invalido. "
            next field atdnum
         end if

            # Se informou Nro.Atendimento

         if mr_tela.atdnum is not null and
            mr_tela.atdnum <> 0        then

            # Verifica se eh valido e se eh da Porto/Azul/PSS/Itau

            call ctd24g00_valida_atd(mr_tela.atdnum
                                    ,g_documento.ciaempcod
                                    ,5 ) --> valida a empresa e nro do Atendimento
                 returning lr_aux.resultado
                          ,lr_aux.mensagem
                          ,lr_aux.ciaempcod

            if lr_aux.resultado <> 1 then
               error lr_aux.mensagem
               next field atdnum
            else

               # Carrega dados do Atendimento para Itau

               call ctd24g00_valida_atd(mr_tela.atdnum
                                       ,g_documento.ciaempcod
                                       ,7 ) --> Dados do Atendimento p/ Itau
                    returning lr_aux.resultado
                             ,lr_aux.mensagem
                             ,g_documento.ciaempcod
                             ,mr_tela.solnom
                             ,mr_tela.c24soltipcod
                             ,mr_tela.itaramcod
                             ,lr_retorno.succod
                             ,mr_tela.itaaplnum
                             ,mr_tela.itaaplitmnum
                             ,mr_tela.itaciacod
                             ,mr_atd.semdocto
                             ,mr_atd.semdoctoempcodatd
                             ,mr_atd.semdoctopestip
                             ,mr_atd.semdoctocgccpfnum
                             ,mr_atd.semdoctocgcord
                             ,mr_atd.semdoctocgccpfdig
                             ,mr_atd.semdoctocorsus
                             ,mr_atd.semdoctofunmat
                             ,mr_atd.semdoctoempcod
                             ,mr_atd.semdoctodddcod
                             ,mr_atd.semdoctoctttel


               if lr_aux.resultado = 2 then

                   error lr_aux.mensagem
                   initialize mr_tela.* , mr_atd.* to null
                   let g_documento.ciaempcod = 84
                   next field atdnum

               end if


               # Busca a Descrição do Tipo do Solicitante
               call cto00m00_nome_solicitante(mr_tela.c24soltipcod, 1)
                    returning lr_aux.resultado
                             ,lr_aux.mensagem
                             ,mr_tela.c24soltipdes

               display by name mr_tela.solnom attribute (reverse)
               display by name mr_tela.c24soltipcod
                              ,mr_tela.c24soltipdes
                              ,mr_tela.c24soltipdes
                              ,mr_tela.itaramcod
                              ,mr_tela.itaaplnum
                              ,mr_tela.itaaplitmnum
                              ,mr_tela.itaciacod

               let mr_documento.empcodatd    = lr_param.empcodatd
               let mr_documento.funmatatd    = lr_param.funmatatd
               let mr_documento.usrtipatd    = lr_param.usrtipatd
               let mr_documento.c24soltipcod = mr_tela.c24soltipcod
               let mr_documento.solnom       = mr_tela.solnom
               let mr_documento.c24paxnum    = lr_param.c24paxnum

               if mr_tela.c24soltipcod < 3 then
                  let mr_documento.soltip = mr_tela.c24soltipdes[1,1]
               else
                  let mr_documento.soltip = "O"
               end if

            end if
         end if

         let g_documento.semdocto  = mr_atd.semdocto
         let mr_documento.semdocto = mr_atd.semdocto
         let mr_tela.semdocto      = mr_atd.semdocto

#--------------------------------------------------------------------------------------
# BEFORE SOLNOM
#--------------------------------------------------------------------------------------

      before field solnom

         let mr_documento.empcodatd = lr_param.empcodatd
         let mr_documento.funmatatd = lr_param.funmatatd
         let mr_documento.usrtipatd = lr_param.usrtipatd

         if lr_param.apoio = "S" then

            call cty08g00_nome_func(lr_param.empcodatd
                                   ,lr_param.funmatatd
                                   ,lr_param.usrtipatd)
               returning lr_aux.resultado
                        ,lr_aux.mensagem
                        ,mr_tela.solnom

          if lr_aux.resultado = 3 then

               call errorlog(lr_aux.mensagem)

               exit input
            else
             if lr_aux.resultado = 2 then

                  call errorlog(lr_aux.mensagem)
               end if
            end if

            let mr_tela.c24soltipcod      = 6
            let mr_tela.c24soltipdes      = "APOIO"
            let mr_documento.c24soltipcod = mr_tela.c24soltipcod
            let mr_documento.solnom       = mr_tela.solnom

            display by name mr_tela.c24soltipcod
            display by name mr_tela.c24soltipdes
            display by name mr_tela.solnom

            next field pestipcod
         end if

         display by name mr_tela.solnom  attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER SOLNOM
#--------------------------------------------------------------------------------------

      after field solnom
         display by name mr_tela.solnom


       if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdnum
         end if


         if mr_tela.solnom is null then
            error 'Nome do solicitante deve ser informado!'
            next field solnom
         end if

         let mr_documento.solnom = mr_tela.solnom

#--------------------------------------------------------------------------------------
# BEFORE C24SOLTIPCOD
#--------------------------------------------------------------------------------------

      before field c24soltipcod
          display by name mr_tela.c24soltipcod attribute (reverse)

#--------------------------------------------------------------------------------------
# AFTER C24SOLTIPCOD
#--------------------------------------------------------------------------------------

      after field c24soltipcod

         display by name mr_tela.c24soltipcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field solnom
         end if

         #-- Exibe popup dos tipos de solicitante --#
         if mr_tela.c24soltipcod is null then
            error "Tipo do solicitante deve ser informado!"

            let mr_tela.c24soltipcod = cto00m00(1)

            display by name mr_tela.c24soltipcod
         end if

         #-- Busca a Descrição do Tipo do Solicitante --#
         call cto00m00_nome_solicitante(mr_tela.c24soltipcod, 1)
              returning lr_aux.resultado
                       ,lr_aux.mensagem
                       ,mr_tela.c24soltipdes

         if lr_aux.resultado <> 1 then
            error lr_aux.mensagem
            next field c24soltipcod
         else
            display by name mr_tela.c24soltipdes

            if mr_tela.c24soltipcod < 3 then
               let mr_documento.soltip = mr_tela.c24soltipdes[1,1]
            else
               let mr_documento.soltip = "O"
            end if
         end if

         let mr_documento.c24soltipcod = mr_tela.c24soltipcod

         if lr_param.c24paxnum is null and g_issk.acsnivcod = 6 then

            #Obter nivel do funcionario
            call cty08g00_nivel_func(g_issk.usrtip
                                    ,g_issk.empcod
                                    ,g_issk.usrcod
                                    ,'pso_ct24h')
                 returning lr_aux.resultado
                          ,lr_aux.mensagem
                          ,lr_aux.acsnivcod

            if lr_aux.acsnivcod is null then

                while lr_param.c24paxnum is null

                   # Obter nr. do pax
                   let lr_param.c24paxnum = cta02m09()

                end while
            end if
         end if

         if lr_param.c24paxnum is not null  and
            lr_param.c24paxnum <> 0 then

            let lr_aux.c24paxtxt = "P.A.: ", lr_param.c24paxnum using "######"
            display by name lr_aux.c24paxtxt  attribute (reverse)

         else
            let lr_param.c24paxnum = 0
         end if

         let mr_documento.c24paxnum = lr_param.c24paxnum

         # Se carregou dados pelo Nro Atendimento sai do Input
         # apos entrar na tela de sem Doctos, pois ja confirmou nela

         if mr_tela.semdocto = "S" then

              let g_documento.atdnum = mr_tela.atdnum

              call cta00m27_carrega_global()
              call cta10m00_entrada_dados()
              call cta00m27_carrega_modular()

              if mr_documento.corsus    is null and
                 mr_documento.dddcod    is null and
                 mr_documento.ctttel    is null and
                 mr_documento.funmat    is null and
                 mr_documento.cgccpfnum is null and
                 mr_documento.cgcord    is null and
                 mr_documento.cgccpfdig is null then
                 error 'Faltam informacoes para registrar Ligacao sem Docto.'sleep 2
                 next field atdnum
              else
                 let mr_documento.semdocto = "S"
                 exit while
              end if

          end if



#--------------------------------------------------------------------------------------
# BEFORE ITACIACOD
#--------------------------------------------------------------------------------------
      before field itaciacod
         display by name mr_tela.itaciacod   attribute (reverse)

         if mr_tela.itaciacod is null then

             let mr_tela.itaciacod = 33

             call cto00m10_recupera_descricao(1,mr_tela.itaciacod)
             returning mr_tela.itaciades

             display by name mr_tela.itaciades

         end if

#--------------------------------------------------------------------------------------
# AFTER ITACIACOD
#--------------------------------------------------------------------------------------
      after field itaciacod
         display by name mr_tela.itaciacod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24soltipcod
          end if


          if mr_tela.itaciacod is null then
             call cto00m10_popup(1)
             returning mr_tela.itaciacod, mr_tela.itaciades
          else
             call cto00m10_recupera_descricao(1,mr_tela.itaciacod)
             returning mr_tela.itaciades
          end if

          if mr_tela.itaciades is null then
             next field itaciacod
          end if

          display by name mr_tela.itaciacod
          display by name mr_tela.itaciades


#--------------------------------------------------------------------------------------
# BEFORE ITARAMCOD
#--------------------------------------------------------------------------------------
      before field itaramcod
         display by name mr_tela.itaramcod   attribute (reverse)

         if mr_tela.itaramcod is null then

             let mr_tela.itaramcod = 31

             call cto00m10_recupera_descricao(10,mr_tela.itaramcod)
             returning mr_tela.ramnom

             display by name mr_tela.ramnom

         end if




#--------------------------------------------------------------------------------------
# AFTER ITARAMCOD
#--------------------------------------------------------------------------------------
     after field itaramcod
        display by name mr_tela.itaramcod

        if fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field itaciacod
        end if


        if mr_tela.itaramcod is null then
           call cto00m10_popup(10)
           returning mr_tela.itaramcod, mr_tela.ramnom
        else
           call cto00m10_recupera_descricao(10,mr_tela.itaramcod)
           returning mr_tela.ramnom
        end if

        if mr_tela.ramnom is null then
           next field itaramcod
        end if

        let lr_retorno.itaciacod = mr_tela.itaciacod
        let lr_retorno.itaramcod = mr_tela.itaramcod

        display by name mr_tela.itaramcod
        display by name mr_tela.ramnom



#--------------------------------------------------------------------------------------
# BEFORE ITAAPLNUM
#--------------------------------------------------------------------------------------
      before field itaaplnum
         display by name mr_tela.itaaplnum    attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER ITAAPLNUM
#--------------------------------------------------------------------------------------
      after field itaaplnum
         display by name mr_tela.itaaplnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field itaramcod
         end if

	 if mr_tela.itaaplnum is null and
	    mr_tela.itaramcod = 14 then
	    next field segnom
	 end if

         if mr_tela.itaciacod is not null and
            mr_tela.itaramcod is not null and
            mr_tela.itaaplnum is not null then


               # Verifica se Apolice Existe

            if mr_tela.itaramcod = 14 then   ### JUNIOR FORNAX
	             call cty25g00_qtd_apolice(mr_tela.itaciacod,
					                               mr_tela.itaramcod,
					                               mr_tela.itaaplnum)

                     returning lr_retorno.qtd

               if lr_retorno.qtd = 0 then
		              error "Apolice Nao Encontrada!"
		              next field itaaplnum
	             end if

               call cty25g00_rec_ult_sequencia(mr_tela.itaciacod,
	                                             mr_tela.itaramcod,
		                                           mr_tela.itaaplnum)

                  returning lr_retorno.aplseqnum,
                            lr_retorno.erro     ,
                            lr_retorno.mensagem

                  if lr_retorno.erro <> 0 then
                     error lr_retorno.mensagem clipped
                     next field itaaplnum
                  end if
            else
               call cty22g00_qtd_apolice(mr_tela.itaciacod,
                                         mr_tela.itaramcod,
                                         mr_tela.itaaplnum)
               returning lr_retorno.qtd

               if lr_retorno.qtd = 0 then
                  error "Apolice Nao Encontrada!"
                  next field itaaplnum
               end if


               call cty22g00_rec_ult_sequencia(mr_tela.itaciacod,
                                               mr_tela.itaramcod,
                                               mr_tela.itaaplnum)
               returning lr_retorno.aplseqnum,
                         lr_retorno.erro     ,
                         lr_retorno.mensagem

               if lr_retorno.erro <> 0 then
                  error lr_retorno.mensagem clipped
                  next field itaaplnum
               end if
            end if
         else
            next field autplcnum
         end if
#--------------------------------------------------------------------------------------
# BEFORE ITAAPLITMNUM
#--------------------------------------------------------------------------------------
      before field itaaplitmnum
         display by name mr_tela.itaaplitmnum     attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER ITAAPLITMNUM
#--------------------------------------------------------------------------------------
      after field itaaplitmnum
         display by name mr_tela.itaaplitmnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field itaaplnum
         end if

         # Recupera o Item da Apolice

	 if mr_tela.itaramcod = 14 then  ### JUNIOR (FORNAX)
	    call cty25g00_itm_apolice(mr_tela.itaciacod    ,
	                              mr_tela.itaramcod    ,
	                              mr_tela.itaaplnum    ,
	                              lr_retorno.aplseqnum ,
	                              mr_tela.itaaplitmnum )
            returning mr_tela.itaaplitmnum,
                      lr_retorno.succod   ,
                      lr_retorno.erro     ,
                      lr_retorno.mensagem

         else

            call cta00m29(mr_tela.itaciacod    ,
                          mr_tela.itaramcod    ,
                          mr_tela.itaaplnum    ,
                          lr_retorno.aplseqnum ,
                          mr_tela.itaaplitmnum )
            returning mr_tela.itaaplitmnum,
                      lr_retorno.succod   ,
                      lr_retorno.erro     ,
                      lr_retorno.mensagem
         end if

            if lr_retorno.erro <> 0 then
               error lr_retorno.mensagem clipped
               next field itaaplitmnum
            else
               display by name mr_tela.itaaplitmnum
               exit input
            end if

            display by name mr_tela.itaaplitmnum
#--------------------------------------------------------------------------------------
# BEFORE AUTPLCNUM
#--------------------------------------------------------------------------------------
      before field autplcnum
	 if mr_tela.itaramcod = 14 then
            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
	       next field itaaplnum
            else
	       next field segnom
            end if
         end if

         display by name mr_tela.autplcnum     attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER AUTPLCNUM
#--------------------------------------------------------------------------------------
      after field autplcnum
         display by name mr_tela.autplcnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then

            if mr_tela.itaaplitmnum is null then
               next field itaaplnum
            else
               next field itaaplitmnum
            end if

         end if

         if mr_tela.autplcnum is not null then

             # Pesquisa Apolice por Placa

             call cta00m28_rec_apolice_por_placa(mr_tela.autplcnum)
             returning mr_tela.itaciacod     ,
                       mr_tela.itaramcod     ,
                       mr_tela.itaaplnum     ,
                       lr_retorno.aplseqnum  ,
                       mr_tela.itaaplitmnum  ,
                       lr_retorno.succod     ,
                       lr_retorno.erro       ,
                       lr_retorno.mensagem


             if lr_retorno.erro <> 0 then

                call cts75m00_rec_placa_azul (mr_tela.autplcnum, "")
                    returning m_retorno
                if m_retorno = 1 then
                   call cts08g01 ("A","N","ENCONTRADO DOCUMENTO VIGENTE NA AZUL ",
                                  "INFORME O NUMERO 4004-3700 ",
                                  "E TRANSFIRA O CONTATO PARA 20103","")
                    returning lr_aux.confirma
                else
                   call cts75m00_rec_placa_porto (mr_tela.autplcnum)
                      returning m_retorno
                   if m_retorno = 1 then
                   		call cts08g01 ("A","N","ENCONTRADO DOCUMENTO VIGENTE NA PORTO ",
                   		               "INFORME O NUMERO 3337-6786 ",
                   		               "E TRANSFIRA O CONTATO PARA 20102 ","")
                   		 returning lr_aux.confirma
                   else
                    let mr_tela.itaciacod = lr_retorno.itaciacod
                    let mr_tela.itaramcod = lr_retorno.itaramcod
                    error lr_retorno.mensagem clipped
                   end if
                 end if
                  next field autplcnum
             else
                exit input
             end if


         end if

#--------------------------------------------------------------------------------------
# BEFORE SEGNOM
#--------------------------------------------------------------------------------------
      before field segnom
         display by name mr_tela.segnom     attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER SEGNOM
#--------------------------------------------------------------------------------------
      after field segnom
         display by name mr_tela.segnom

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field autplcnum
         end if


         if mr_tela.segnom is not null and
            mr_tela.segnom <> " "      then

            let lr_retorno.tamanho = (length (mr_tela.segnom))

            # Verifica o Tamanho do que foi Digitado

            if lr_retorno.tamanho < 10  then
               error " Complemente o nome do segurado (minimo 10 caracteres)!"
               next field segnom
            end if

           # Verifica se Existe * na String

            for l_cont  = 1 to lr_retorno.tamanho

               let lr_retorno.asterisco = mr_tela.segnom[l_cont ,l_cont ]

               if lr_retorno.asterisco = " " then
                  continue for
               end if

               if lr_retorno.asterisco  matches "[*]" then
                  error "Nome do Segurado nao pode Começar com(*)!" sleep 2
                  next field segnom
               end if

               exit for
            end for

            # Pesquisa Apolice por Nome

	    if mr_tela.itaramcod = 14 then  ### JUNIOR (FORNAX)
               call cty25g01_rec_apolice_por_nome(mr_tela.segnom)
                    returning lr_retorno.itaciacod    ,
                              lr_retorno.itaramcod    ,
                              mr_tela.itaaplnum    ,
                              lr_retorno.aplseqnum ,
                              mr_tela.itaaplitmnum ,
                              lr_retorno.succod    ,
                              lr_retorno.erro      ,
                              lr_retorno.mensagem

            else
              call cta00m28_rec_apolice_por_nome(mr_tela.segnom)
              returning lr_retorno.itaciacod    ,
                        lr_retorno.itaramcod    ,
                        mr_tela.itaaplnum    ,
                        lr_retorno.aplseqnum ,
                        mr_tela.itaaplitmnum ,
                        lr_retorno.succod    ,
                        lr_retorno.erro      ,
                        lr_retorno.mensagem
	    end if

            if lr_retorno.erro <> 0 then

               # Pesquisa Apolice por Nome Cliente VIP

               call cta00m28_rec_apolice_por_nome_vip(mr_tela.segnom)
               returning mr_atd.semdoctocgccpfnum ,
                         mr_atd.semdoctocgcord    ,
                         mr_atd.semdoctocgccpfdig ,
                         lr_retorno.erro          ,
                         lr_retorno.mensagem

               if lr_retorno.erro <> 0 then

                  error lr_retorno.mensagem clipped
                  next field segnom
               else

                  call cts08g01 ("A","S","","CLIENTE VIP SEM APOLICE",
                                 "DESEJA ABRIR SEM DOCUMENTO ? ","")
                       returning lr_aux.confirma

                  if lr_aux.confirma = "N" then

                     let mr_tela.itaciacod = lr_retorno.itaciacod
                     let mr_tela.itaramcod = lr_retorno.itaramcod

                     error lr_retorno.mensagem clipped
                     next field segnom
                  else
                      call cta00m27_carrega_global()
                      let mr_tela.semdocto = "S"
                      next field semdocto
                  end if

               end if

            else
               exit input
            end if

         end if



#--------------------------------------------------------------------------------------
# BEFORE PESTIPCOD
#--------------------------------------------------------------------------------------
      before field pestipcod
         display by name mr_tela.pestipcod       attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER PESTIPCOD
#--------------------------------------------------------------------------------------
      after field pestipcod
         display by name mr_tela.pestipcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field segnom
          end if


         if mr_tela.pestipcod is null  then
	    next field itaprpnum
         end if

         if mr_tela.pestipcod is not null  and
            mr_tela.pestipcod <>  " "      and
            mr_tela.pestipcod <>  "F"      and
            mr_tela.pestipcod <>  "J"      then
            error " Tipo de Pessoa Invalido!"
            next field pestipcod
         else
            case mr_tela.pestipcod
               when "F"
                  let mr_tela.pesnom = "FISICA"
               when "J"
                  let mr_tela.pesnom = "JURIDICA"
            end case

            display by name mr_tela.pesnom
         end if



#--------------------------------------------------------------------------------------
# BEFORE SEGCGCCPFNUM
#--------------------------------------------------------------------------------------
      before field segcgccpfnum
         display by name mr_tela.segcgccpfnum        attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER SEGCGCCPFNUM
#--------------------------------------------------------------------------------------
      after field segcgccpfnum
         display by name mr_tela.segcgccpfnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field pestipcod
         end if


         if mr_tela.pestipcod is not null and
            mr_tela.pestipcod <> " "      then

            if mr_tela.segcgccpfnum    is null   or
               mr_tela.segcgccpfnum    =  0      then
               error " Numero do CGC/CPF deve ser Informado!"
               next field segcgccpfnum
            end if
         else
            if mr_tela.segcgccpfnum   is not null   then
               error " Tipo de Pessoa deve ser Informada!"
               next field pestipcod
            else
               initialize mr_tela.segcgcordnum  to null
               initialize mr_tela.segcgccpfdig  to null

               display by name mr_tela.segcgcordnum
               display by name mr_tela.segcgccpfdig

               if fgl_lastkey() = fgl_keyval ("up")     or
                  fgl_lastkey() = fgl_keyval ("left")   then
                  next field pestipcod
               else
                  next field itaprpnum
               end if
            end if
         end if

         if mr_tela.pestipcod =  "F"   then
            next field segcgccpfdig
         else
            next field segcgcordnum
         end if



#--------------------------------------------------------------------------------------
# BEFORE SEGCGCORDNUM
#--------------------------------------------------------------------------------------
      before field segcgcordnum
         display by name mr_tela.segcgcordnum        attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER SEGCGCORDNUM
#--------------------------------------------------------------------------------------
      after field segcgcordnum
         display by name mr_tela.segcgcordnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field segcgccpfnum
         end if

          if mr_tela.segcgcordnum    is null   or
             mr_tela.segcgcordnum    =  0      then
             error " Filial do CGC deve ser Informada!"
             next field segcgcordnum
          end if



#--------------------------------------------------------------------------------------
# BEFORE SEGCGCCPFDIG
#--------------------------------------------------------------------------------------
      before field segcgccpfdig
         display by name mr_tela.segcgccpfdig        attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER SEGCGCCPFDIG
#--------------------------------------------------------------------------------------
      after field segcgccpfdig
         display by name mr_tela.segcgccpfdig

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then

           if mr_tela.segcgcordnum is null then
               next field segcgccpfnum
           else
               next field segcgcordnum
           end if
         end if

         if mr_tela.segcgccpfdig is null then
            error " Digito do CGC/CPF deve ser Informado!"
            next field segcgccpfdig
         end if

         if mr_tela.pestipcod =  "J" then
            call F_FUNDIGIT_DIGITOCGC(mr_tela.segcgccpfnum  ,
                                      mr_tela.segcgcordnum)
                 returning lr_retorno.segcgccpfdig
         else
            call F_FUNDIGIT_DIGITOCPF(mr_tela.segcgccpfnum)
                 returning lr_retorno.segcgccpfdig
         end if

         if lr_retorno.segcgccpfdig  is null or
            mr_tela.segcgccpfdig  <> lr_retorno.segcgccpfdig   then
            error " Digito do CGC/CPF Incorreto!"
            next field segcgccpfdig
         end if

         # Recupera Cliente por CGC/CPF

	 if mr_tela.itaramcod = 14  then
            call cty25g01_rec_apolice_por_cgccpf(mr_tela.pestipcod    ,
                                                 mr_tela.segcgccpfnum ,
                                                 mr_tela.segcgcordnum ,
                                                 mr_tela.segcgccpfdig )
            returning lr_retorno.itaciacod    ,
                      lr_retorno.itaramcod    ,
                      mr_tela.itaaplnum    ,
                      lr_retorno.aplseqnum ,
                      mr_tela.itaaplitmnum ,
                      lr_retorno.succod    ,
                      lr_retorno.erro      ,
                      lr_retorno.mensagem


	 else

            call cta00m28_rec_apolice_por_cgccpf(mr_tela.pestipcod    ,
                                                 mr_tela.segcgccpfnum ,
                                                 mr_tela.segcgcordnum ,
                                                 mr_tela.segcgccpfdig )
            returning lr_retorno.itaciacod    ,
                      lr_retorno.itaramcod    ,
                      mr_tela.itaaplnum    ,
                      lr_retorno.aplseqnum ,
                      mr_tela.itaaplitmnum ,
                      lr_retorno.succod    ,
                      lr_retorno.erro      ,
                      lr_retorno.mensagem

         end if

         if lr_retorno.erro <> 0 then

            # Recupera Cliente por CGC/CPF VIP

            call cta00m28_rec_apolice_por_cgccpf_vip(mr_tela.segcgccpfnum ,
                                                     mr_tela.segcgcordnum ,
                                                     mr_tela.segcgccpfdig ,
                                                     mr_tela.pestipcod    )
            returning mr_atd.semdoctocgccpfnum ,
                      mr_atd.semdoctocgcord    ,
                      mr_atd.semdoctocgccpfdig ,
                      lr_retorno.erro          ,
                      lr_retorno.mensagem

               if lr_retorno.erro <> 0 then
                  call cts75m00_rec_cpfcgc_azul (mr_tela.pestipcod,
                                                 mr_tela.segcgccpfnum ,
                                                 mr_tela.segcgcordnum ,
                                                 mr_tela.segcgccpfdig,
                                                 mr_tela.itaramcod)
                     returning m_retorno
                  if m_retorno = 1 then
                     call cts08g01 ("A","N","ENCONTRADO DOCUMENTO VIGENTE NA AZUL ",
                                    "INFORME O NUMERO 4004-3700 ",
                                    "E TRANSFIRA O CONTATO PARA 20103","")
                    returning lr_aux.confirma
                  else
                      call cts75m00_rec_cgccpf_porto (mr_tela.segcgccpfnum ,
                                                      mr_tela.segcgcordnum ,
                                                      mr_tela.segcgccpfdig ,
                                                      mr_tela.pestipcod,
                                                      mr_tela.itaramcod)
                        returning m_retorno

                      if m_retorno = 1 then
                         call cts08g01 ("A","N","ENCONTRADO DOCUMENTO VIGENTE NA PORTO ",
                   		                  "INFORME O NUMERO 3337-6786 ",
                   		                  "E TRANSFIRA O CONTATO PARA 20102 ","")
                   		   returning lr_aux.confirma
                      else
                        let mr_tela.itaciacod = lr_retorno.itaciacod
                        let mr_tela.itaramcod = lr_retorno.itaramcod
                        error lr_retorno.mensagem clipped
                      end if
                   end if
                  next field segcgccpfnum
               else

                  call cts08g01 ("A","S","","CLIENTE VIP SEM APOLICE",
                                 "DESEJA ABRIR SEM DOCUMENTO ? ","")
                       returning lr_aux.confirma

                     let mr_tela.itaciacod = lr_retorno.itaciacod
                     let mr_tela.itaramcod = lr_retorno.itaramcod

                  if lr_aux.confirma = "N" then

                     error lr_retorno.mensagem clipped
                     next field segcgccpfdig
                  else
                      call cta00m27_carrega_global()
                      let mr_tela.semdocto = "S"
                      next field semdocto
                  end if

               end if
         else
            exit input
         end if


#--------------------------------------------------------------------------------------
# BEFORE ITAPRPNUM
#--------------------------------------------------------------------------------------
      before field itaprpnum
         display by name mr_tela.itaprpnum          attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER ITAPRPNUM
#--------------------------------------------------------------------------------------
      after field itaprpnum
         display by name mr_tela.itaprpnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
	    if mr_tela.segcgccpfdig is not null then
               next field segcgccpfdig
            else
               next field pestipcod
            end if
         end if

         if mr_tela.itaprpnum is not null then
	   if mr_tela.itaramcod = 14 then   ###  JUNIOR (FORNAX)
              call cty25g00_rec_apolice_por_proposta(mr_tela.itaprpnum)
              returning mr_tela.itaciacod    ,
                        mr_tela.itaramcod    ,
                        mr_tela.itaaplnum    ,
                        lr_retorno.aplseqnum ,
                        lr_retorno.succod    ,
                        lr_retorno.erro      ,
                        lr_retorno.mensagem

              if lr_retorno.erro <> 0 then

                 let mr_tela.itaciacod = lr_retorno.itaciacod
                 let mr_tela.itaramcod = lr_retorno.itaramcod

                 error lr_retorno.mensagem clipped
                 next field itaprpnum
              else
                 call cty25g02(mr_tela.itaciacod    ,
                               mr_tela.itaramcod    ,
                               mr_tela.itaaplnum    ,
                               lr_retorno.aplseqnum ,
                               mr_tela.itaaplitmnum )
                 returning mr_tela.itaaplitmnum,
                           lr_retorno.succod   ,
                           lr_retorno.erro     ,
                           lr_retorno.mensagem

                 if lr_retorno.erro <> 0 then
                    error lr_retorno.mensagem clipped
                    next field itaprpnum
                 else
                    exit input
                 end if
              end if
	   else
		       #mr_tela.itaprpnum
              call cty22g00_rec_apolice_por_proposta(mr_tela.itaprpnum)
              returning lr_retorno.itaciacod    ,
                        lr_retorno.itaramcod    ,
                        mr_tela.itaaplnum    ,
                        lr_retorno.aplseqnum ,
                        lr_retorno.succod    ,
                        lr_retorno.erro      ,
                        lr_retorno.mensagem

              if lr_retorno.erro <> 0 then

                 let mr_tela.itaciacod = lr_retorno.itaciacod
                 let mr_tela.itaramcod = lr_retorno.itaramcod

                 error lr_retorno.mensagem clipped
                 next field itaprpnum
              else
                 call cta00m29(mr_tela.itaciacod    ,
                               mr_tela.itaramcod    ,
                               mr_tela.itaaplnum    ,
                               lr_retorno.aplseqnum ,
                               mr_tela.itaaplitmnum )
                 returning mr_tela.itaaplitmnum,
                           lr_retorno.succod   ,
                           lr_retorno.erro     ,
                           lr_retorno.mensagem

                 if lr_retorno.erro <> 0 then
                    error lr_retorno.mensagem clipped
                    next field itaprpnum
                 else
                    exit input
                 end if
              end if
            end if
         end if
#--------------------------------------------------------------------------------------
# BEFORE AUTCHSNUM
#--------------------------------------------------------------------------------------
      before field autchsnum
	 if mr_tela.itaramcod = 14 then
            if fgl_lastkey() = fgl_keyval("up")   or
               fgl_lastkey() = fgl_keyval("left") then
	       next field itaprpnum
            else
	       next field semdocto
            end if
         end if

         display by name mr_tela.autchsnum          attribute (reverse)



#--------------------------------------------------------------------------------------
# AFTER AUTCHSNUM
#--------------------------------------------------------------------------------------
      after field autchsnum
         display by name mr_tela.autchsnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field itaprpnum
         end if

         if mr_tela.autchsnum  is not null then
	    if mr_tela.itaramcod <> 14 then
               call cty22g00_rec_apolice_por_chassi(mr_tela.autchsnum)
               returning mr_tela.itaciacod     ,
                         mr_tela.itaramcod     ,
                         mr_tela.itaaplnum     ,
                         lr_retorno.aplseqnum  ,
                         mr_tela.itaaplitmnum  ,
                         lr_retorno.succod     ,
                         lr_retorno.erro       ,
                         lr_retorno.mensagem


               if lr_retorno.erro <> 0 then

                  let mr_tela.itaciacod = lr_retorno.itaciacod
                  let mr_tela.itaramcod = lr_retorno.itaramcod

                  error lr_retorno.mensagem clipped
                  next field autchsnum
               else
                  exit input
               end if
            end if
         end if


#--------------------------------------------------------------------------------------
# BEFORE SEMDOCTO
#--------------------------------------------------------------------------------------

      before field semdocto
         display by name mr_tela.semdocto  attribute (reverse)


#--------------------------------------------------------------------------------------
# AFTER SEMDOCTO
#--------------------------------------------------------------------------------------

      after field semdocto
         display by name mr_tela.semdocto

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field autchsnum
       end if


       if mr_tela.semdocto is null then
          next field semdocto
       else
          if mr_tela.semdocto <> "S" then
             error 'Opcao invalida, digite "S" para ligacao Sem Docto.' sleep 2
             next field semdocto
          else
             call cta10m00_entrada_dados()

             call cta00m27_carrega_modular()

             if mr_documento.corsus    is null and
                mr_documento.dddcod    is null and
                mr_documento.ctttel    is null and
                mr_documento.funmat    is null and
                mr_documento.cgccpfnum is null and
                mr_documento.cgcord    is null and
                mr_documento.cgccpfdig is null then
                error 'Faltam informacoes para registrar Ligacao sem Docto.'sleep 2
                next field semdocto
             else
                let mr_documento.semdocto = "S"
                exit while
             end if
           end if
        end if

       on key(control-c,f17,interrupt)
          clear form
          initialize mr_tela.*, mr_documento.* to null
          let mr_atd.controle = true
          exit while

   end input

   if mr_tela.itaciacod     is not null and
      mr_tela.itaramcod     is not null and
      mr_tela.itaaplnum     is not null and
      mr_tela.itaaplitmnum  is not null and
      lr_retorno.aplseqnum  is not null then

        if mr_tela.itaramcod = 14 then   ### JUNIOR (FORNAX)

         if not cty25g00_status_apolice(mr_tela.itaciacod  ,
                                        mr_tela.itaramcod  ,
                                        mr_tela.itaaplnum  ,
                                        mr_tela.itaaplitmnum,
                                        lr_retorno.aplseqnum ) then
            continue while
         else
           if not cty25g00_ver_vigencia_apolice(mr_tela.itaciacod  ,
	                                              mr_tela.itaramcod  ,
	                                              mr_tela.itaaplnum  ,
	                                              lr_retorno.aplseqnum ) then
              continue while
           else
              let mr_documento.itaciacod       = mr_tela.itaciacod
              let mr_documento.itaramcod       = mr_tela.itaramcod
              let mr_documento.itaaplnum       = mr_tela.itaaplnum
              let mr_documento.itaaplitmnum    = mr_tela.itaaplitmnum
              let mr_documento.aplseqnum       = lr_retorno.aplseqnum
              let mr_documento.succod          = lr_retorno.succod
              exit while
           end if
         end if
        else
           if not cty22g00_ver_vigencia_apolice(mr_tela.itaciacod  ,
                                                mr_tela.itaramcod  ,
                                                mr_tela.itaaplnum  ,
                                                lr_retorno.aplseqnum ) then
              continue while
           else
              let mr_documento.itaciacod       = mr_tela.itaciacod
              let mr_documento.itaramcod       = mr_tela.itaramcod
              let mr_documento.itaaplnum       = mr_tela.itaaplnum
              let mr_documento.itaaplitmnum    = mr_tela.itaaplitmnum
              let mr_documento.aplseqnum       = lr_retorno.aplseqnum
              let mr_documento.succod          = lr_retorno.succod
              exit while

           end if
         end if
   end if

end while


    call cta00m27_guarda_globais()
    call cta00m27_gera_atendimento()


end function

#-----------------------------------------------------------------------------
function cta00m27_carrega_modular()
#-----------------------------------------------------------------------------

  let mr_documento.corsus      = g_documento.corsus
  let mr_documento.dddcod      = g_documento.dddcod
  let mr_documento.ctttel      = g_documento.ctttel
  let mr_documento.funmat      = g_documento.funmat
  let mr_documento.cgccpfnum   = g_documento.cgccpfnum
  let mr_documento.cgcord      = g_documento.cgcord
  let mr_documento.cgccpfdig   = g_documento.cgccpfdig

  let mr_atd.semdoctocorsus    = g_documento.corsus
  let mr_atd.semdoctodddcod    = g_documento.dddcod
  let mr_atd.semdoctoctttel    = g_documento.ctttel
  let mr_atd.semdoctofunmat    = g_documento.funmat
  let mr_atd.semdoctocgccpfnum = g_documento.cgccpfnum
  let mr_atd.semdoctocgcord    = g_documento.cgcord
  let mr_atd.semdoctocgccpfdig = g_documento.cgccpfdig
  let mr_atd.semdoctofunmat    = g_documento.funmat
  let mr_atd.semdoctoempcod    = g_documento.empcodmat
  let mr_atd.semdoctoempcodatd = g_documento.empcodatd

end function

#-----------------------------------------------------------------------------
function cta00m27_carrega_global()
#-----------------------------------------------------------------------------

  let g_documento.atdnum     = mr_tela.atdnum
  let g_documento.empcodmat  = mr_atd.semdoctoempcodatd
  let g_documento.corsus     = mr_atd.semdoctocorsus
  let g_documento.dddcod     = mr_atd.semdoctodddcod
  let g_documento.ctttel     = mr_atd.semdoctoctttel
  let g_documento.funmat     = mr_atd.semdoctofunmat
  let g_documento.cgccpfnum  = mr_atd.semdoctocgccpfnum
  let g_documento.cgcord     = mr_atd.semdoctocgcord
  let g_documento.cgccpfdig  = mr_atd.semdoctocgccpfdig

end function

#-----------------------------------------------------------------------------
function cta00m27_guarda_globais()
#-----------------------------------------------------------------------------

   initialize g_documento.solnom       ,
              g_documento.atdnum       ,
              g_documento.c24soltipcod ,
              g_documento.soltip       ,
              g_documento.itaciacod    ,
              g_documento.ramcod       ,
              g_documento.succod       ,
              g_documento.aplnumdig    ,
              g_documento.edsnumref    ,
              g_documento.itmnumdig    ,
              g_documento.empcodatd    ,
              g_documento.funmatatd    ,
              g_documento.usrtipatd    ,
              g_documento.corsus       ,
              g_documento.dddcod       ,
              g_documento.ctttel       ,
              g_documento.funmat       ,
              g_documento.cgccpfnum    ,
              g_documento.cgcord       ,
              g_documento.cgccpfdig    to null


let mr_documento.itaramcod = mr_tela.itaramcod

   let g_c24paxnum              = mr_documento.c24paxnum
   let g_documento.solnom       = mr_documento.solnom
   let g_documento.atdnum       = mr_tela.atdnum
   let g_documento.c24soltipcod = mr_documento.c24soltipcod
   let g_documento.soltip       = mr_documento.soltip
   let g_documento.itaciacod    = mr_documento.itaciacod
   let g_documento.ramcod       = mr_documento.itaramcod
   let g_documento.succod       = mr_documento.succod
   let g_documento.aplnumdig    = mr_documento.itaaplnum
   let g_documento.edsnumref    = mr_documento.aplseqnum
   let g_documento.itmnumdig    = mr_documento.itaaplitmnum
   let g_documento.empcodatd    = mr_documento.empcodatd
   let g_documento.funmatatd    = mr_documento.funmatatd
   let g_documento.usrtipatd    = mr_documento.usrtipatd
   let g_documento.ligcvntip    = mr_documento.ligcvntip
   let g_documento.corsus       = mr_documento.corsus
   let g_documento.dddcod       = mr_documento.dddcod
   let g_documento.ctttel       = mr_documento.ctttel
   let g_documento.funmat       = mr_documento.funmat
   let g_documento.cgccpfnum    = mr_documento.cgccpfnum
   let g_documento.cgcord       = mr_documento.cgcord
   let g_documento.cgccpfdig    = mr_documento.cgccpfdig
   let g_documento.semdocto     = mr_documento.semdocto


end function

#-----------------------------------------------------------------------------
function cta00m27_gera_atendimento()
#-----------------------------------------------------------------------------

define lr_aux record
   confirma  char(01) ,
   resultado smallint ,
   mensagem  char(70) ,
   linha1    char(40) ,
   linha2    char(40) ,
   linha3    char(40) ,
   atdnum    like datmatd6523.atdnum
end record

initialize lr_aux.* to null

   ---> Se nao localizou Apolice entao abre Atendimento por aqui, se nao
   ---> gera o Atendimento na tela do Assunto

   if g_documento.aplnumdig is null or
      g_documento.aplnumdig =  0    then
       let mr_atd.gera = "S" ---> Gera novo Atendimento
   end if



   ---> Apoio pode ter a opcao de nao Gerar o Atendimento
   # Gera atendimento para todos os níveis
   if not mr_atd.controle then

       { if g_issk.acsnivcod >= 7   and
           mr_atd.gera       = "S" then

           call cts08g01 ("A","S","",
                          "DESEJA GERAR UM NOVO ATENDIMENTO ? ","","")
                returning lr_aux.confirma

           if lr_aux.confirma = "N" then

              let mr_atd.gera   = "N" ---> Nao quer gerar novo Atendimento
              let g_gera_atd = "N"

              initialize g_documento.atdnum  to null
           end if

        end if}

        ---> Gera Numero de Atendimento
        if mr_atd.gera = "S" then

           ---> Se nao ha docto trata variaveis p/ nao gravar em campos indevidos


           begin work
           call ctd24g00_ins_atd(""                      ---> atdnum
                                ,g_documento.ciaempcod
                                ,g_documento.solnom
                                ,""
                                ,g_documento.c24soltipcod
                                ,g_documento.ramcod
                                ,""
                                ,""
                                ,""
                                ,g_documento.succod
                                ,g_documento.aplnumdig
                                ,g_documento.itmnumdig
                                ,g_documento.itaciacod
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,g_documento.semdocto
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,""
                                ,mr_atd.semdoctoempcodatd
                                ,mr_atd.semdoctopestip
                                ,mr_atd.semdoctocgccpfnum
                                ,mr_atd.semdoctocgcord
                                ,mr_atd.semdoctocgccpfdig
                                ,mr_atd.semdoctocorsus
                                ,mr_atd.semdoctofunmat
                                ,mr_atd.semdoctoempcod
                                ,mr_atd.semdoctodddcod
                                ,mr_atd.semdoctoctttel
                                ,g_issk.funmat
                                ,g_issk.empcod
                                ,g_issk.usrtip
                                ,g_documento.ligcvntip)
                returning lr_aux.atdnum
                         ,lr_aux.resultado
                         ,lr_aux.mensagem

           if lr_aux.resultado <> 0 then

              error  lr_aux.mensagem sleep 3

              let g_documento.ligcvntip = null
              let g_documento.atdnum    = null
              let g_documento.succod    = null
              let g_documento.ramcod    = null
              let g_documento.itmnumdig = null
              let g_documento.aplnumdig = null
              let g_documento.edsnumref = null
              let g_documento.corsus    = null
              let g_documento.dddcod    = null
              let g_documento.ctttel    = null
              let g_documento.funmat    = null
              let g_documento.cgccpfnum = null
              let g_documento.cgcord    = null
              let g_documento.cgccpfdig = null

              rollback work
           else

              let mr_tela.atdnum = lr_aux.atdnum

              commit work

              initialize lr_aux.confirma
                        ,lr_aux.linha1
                        ,lr_aux.linha2
                        ,lr_aux.linha3 to null


              while lr_aux.confirma is null or lr_aux.confirma = "N"

                 let lr_aux.linha1 = "INFORME AO CLIENTE O"
                 let lr_aux.linha2 = "NUMERO DE ATENDIMENTO : "
                 let lr_aux.linha3 = "< " , lr_aux.atdnum using "<<<<<<<&&&", " >"

                 call cts08g01 ("A","N","",lr_aux.linha1, lr_aux.linha2 , lr_aux.linha3)
                      returning lr_aux.confirma

                 initialize lr_aux.linha1
                           ,lr_aux.linha2
                           ,lr_aux.linha3 to null

                 let lr_aux.linha1 = "NUMERO DE ATENDIMENTO < "
                                  ,lr_aux.atdnum using "<<<<<<<&&&" ," >"


                 let lr_aux.linha2 = "FOI INFORMADO AO CLIENTE?"

                 call cts08g01 ("A","S","",lr_aux.linha1, lr_aux.linha2, "")
                      returning lr_aux.confirma
              end while


              ---> Atribui O Novo Numero de Atendimento a Global
              let g_documento.atdnum = lr_aux.atdnum

              ---> Se gerou Atendimento aqui nao gera na tela do Assunto
              let g_gera_atd = "N"

              ---> Se nao ha docto volta valor para variaveis

              let g_documento.cgccpfnum = mr_atd.semdoctocgccpfnum
              let g_documento.cgcord    = mr_atd.semdoctocgcord
              let g_documento.cgccpfdig = mr_atd.semdoctocgccpfdig
              let g_documento.corsus    = mr_atd.semdoctocorsus


           end if
         else
             initialize g_documento.atdnum to null
        end if
   end if

end function
