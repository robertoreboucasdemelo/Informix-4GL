################################################################################
# Porto Seguro Cia Seguros Gerais                                      Out/2010#
# .............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : cta15m00                                                     #
# Analista Resp.: Carla Rampazzo                                               #
# PSI           :                                                              #
# Objetivo      : Direcionar Fluxo do HDK conforme atendimento                 #
#                 (Telefonico ou Presencial)                                   #
# .............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor Fabrica  Origem    Alteracao                               #
# ----------  -------------- --------- ----------------------------------------#
#                                                                              #
################################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"


define l_ret      smallint
       ,l_mensagem char(50)


#---------------------------------------------------------------------------
function cta15m00_hdk(param)
#---------------------------------------------------------------------------

   define param             record
	  lignum            like datmligacao.lignum
         ,c24solnom         like datmligacao.c24solnom
   end record


   define lr_clausula       record
          erro              smallint
         ,msg               char(300)
         ,clscod            like datrsrvcls.clscod
   end record


   define l_cta15m00        record
          atddat            like datmservico.atddat
         ,atdhor            like datmservico.atdhor
         ,atdsrvnum         like datmservico.atdsrvnum
         ,atdsrvano         like datmservico.atdsrvano
         ,atdlibhor         like datmservico.atdlibhor
         ,atdlibdat         like datmservico.atdlibdat
   end record


   define l_confirma        char(01)
         ,l_data            date
         ,l_hora            datetime hour to minute
         ,l_msg             char(50)
         ,l_tabname         char(20)
         ,l_sqlcode         integer
	 ,l_lignum          like datmligacao.lignum
         ,l_atdsrvnum       like datmservico.atdsrvnum
         ,l_atdsrvano       like datmservico.atdsrvano
         ,l_c24astcod       like datkassunto.c24astcod
         ,l_prompt          char(01)
         ,l_cornom          like gcakcorr.cornom
         ,l_c24pbmcod       like datkpbm.c24pbmcod
         ,l_c24pbmdes       like datkpbm.c24pbmdes
         ,l_ramgrpcod       like gtakram.ramgrpcod
         ,l_conta_corrente  smallint
         ,l_socntzcod       like datksocntz.socntzcod

   initialize lr_clausula.*, l_cta15m00.*  to null

   let l_confirma       = null
   let l_msg            = null
   let l_sqlcode        = null
   let l_tabname        = null
   let l_lignum         = null
   let l_atdsrvano      = null
   let l_atdsrvnum      = null
   let l_c24astcod      = null
   let l_prompt         = null
   let l_cornom         = null
   let l_c24pbmdes      = null
   let l_ramgrpcod      = null
   let l_mensagem       = null
   let l_socntzcod      = null
   let l_ret            = 0
   let l_c24pbmcod      = 415 ---> Especifico p/ S66 e S78
   let l_conta_corrente = false


   #---------------------------------------------------------
   --> Atendimento pode ser tanto Presencial com por Telefone
   #---------------------------------------------------------
   if (g_hdk.pode_s66        = "S"   and
       g_hdk.pode_s67        = "S"        ) or
       g_documento.c24astcod = "S68"        then

      #---------------------------------------
      --> Alerta para Direcionar o Atendimento
      #---------------------------------------
      call cts08g01 ("A","S",""
                    ,"SOLUCIONADO POR TELEFONE?","","")
           returning l_confirma
   end if

   #-----------------------------------------------------------------
   --> Direciona Laudo Conforme Limite ainda disponivel (so para HDK)
   #-----------------------------------------------------------------

   #-----------------------------------
   --> Atendimento somente por Telefone
   #-----------------------------------
   if g_hdk.pode_s66        = "S"   and
      g_hdk.pode_s67        = "N"   and
      g_documento.c24astcod = "HDK" then
      let l_confirma = "S"
   end if


   #-------------------------------------
   --> Atendimento somente por Presencial
   #-------------------------------------
   if g_hdk.pode_s66        = "N"   and
      g_hdk.pode_s67        = "S"   and
      g_documento.c24astcod = "HDK" then
      let l_confirma = "N"
   end if


   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora

   let l_cta15m00.atddat    = l_data
   let l_cta15m00.atdhor    = l_hora
   let l_cta15m00.atdlibhor = l_hora
   let l_cta15m00.atdlibdat = l_data


   #-------------------------
   --> Atendimento Telefonico
   #-------------------------
   if l_confirma = "S" then

      #------------------
      ---> Busca clausula
      #------------------
      if g_documento.ramcod = 531 then

         call cty05g00_clausula_assunto(g_documento.c24astcod)
                              returning lr_clausula.*

      else

         call cty06g00_clausula_assunto(g_documento.c24astcod)
                              returning lr_clausula.*
      end if


      #-------------------
      --->Nome do Corretor
      #-------------------
      whenever error continue
      select cornom
        into l_cornom
        from gcakcorr  a
            ,gcaksusep b
       where b.corsus    = g_documento.corsus
         and a.corsuspcp = b.corsuspcp
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_cornom = "CORRETOR NAO LOCALIZADO"
      end if

      #-------------------------
      ---> Descricao do Problema
      #-------------------------
      whenever error continue
      select c24pbmdes
        into l_c24pbmdes
        from datkpbm
       where c24pbmcod = l_c24pbmcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_c24pbmdes = "PROBLEMA NAO LOCALIZADO"
      end if


      begin work

      if g_documento.c24astcod = "HDK" then
         let l_c24astcod = "S66"
      else
         let l_c24astcod = "S78"
      end if


      #-----------------------------------------------------
      ---> Altera Assunto de HDK para S66 ou de S68 para S78
      #-----------------------------------------------------
      whenever error continue
      update datmligacao
         set c24astcod = l_c24astcod
       where lignum    = param.lignum
         and c24astcod = g_documento.c24astcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error "Problemas na Atualizacao do Codigo HDK ou S68." sleep 3
      end if

      let g_documento.c24astcod =  l_c24astcod


      #---------------------------
      ---> Busca Numero do servico
      #---------------------------
      call cts10g03_numeracao(0,"9")
                    returning l_lignum
                             ,l_atdsrvnum
                             ,l_atdsrvano
                             ,l_sqlcode
                             ,l_msg

      if l_sqlcode = 0 then
         commit work
      else
         let l_msg = "CTA15M00 - ",l_msg

         call ctx13g00(l_sqlcode,"DATKGERAL",l_msg)

         rollback work

         prompt "" for l_prompt

         let l_ret      = l_sqlcode
         let l_mensagem = l_msg
	 return  l_ret, l_mensagem
      end if

      let l_cta15m00.atdsrvnum  = l_atdsrvnum
      let l_cta15m00.atdsrvano  = l_atdsrvano


      #-------------------------------------------------
      ---> Abre Pop-up para Selecao de Natureza/Problema
      #-------------------------------------------------
      call cta15m00_ntz_pbm(lr_clausula.clscod)
                 returning l_c24pbmcod
                          ,l_c24pbmdes
                          ,l_socntzcod


      begin work
      #--------------------------------
      ---> Gera Servico para S66 ou S78
      #--------------------------------
      call cts10g02_grava_servico(l_cta15m00.atdsrvnum       # atdsrvnum
                                 ,l_cta15m00.atdsrvano       # atdsrvano
                                 ,g_documento.soltip         # atdsoltip
                                 ,param.c24solnom            # c24solnom
                                 ,""                         # vclcorcod
                                 ,g_issk.funmat              # funmat
                                 ,"N"                        # atdlibflg
                                 ,l_cta15m00.atdlibhor       # atdlibhor
                                 ,l_cta15m00.atdlibdat       # atdlibdat
                                 ,l_cta15m00.atddat          # atddat
                                 ,l_cta15m00.atdhor          # atdhor
                                 ,""                         # atdlclflg
                                 ,""                         # atdhorpvt
                                 ,""                         # atddatprg
                                 ,""                         # atdhorprg
                                 ,"9"                        # atdtip
                                 ,""                         # atdmotnom
                                 ,""                         # atdvclsgl
                                 ,10573                      # ardprscod
                                 ,""                         # atdcstvlr
                                 ,"S"                        # atdfnlflg
                                 ,l_cta15m00.atdhor          # atdfnlhor
                                 ,"S"                        # atdrsdflg
                                 ,"HELP DESK CASA-TELEFONICO"# atddfttxt
                                 ,""                         # atddoctxt
                                 ,g_issk.funmat              # c24opemat
                                 ,""                         # nom
                                 ,""                         # vcldes
                                 ,""                         # vclanomdl
                                 ,""                         # vcllicnum
                                 ,g_documento.corsus         # corsus
                                 ,l_cornom                   # cornom
                                 ,""                         # cnldat
                                 ,""                         # pgtdat
                                 ,""                         # c24nomctt
                                 ,"N"                        # atdpvtretflg
                                 ,""                         # atdvcltip
                                 ,6   ---> Assitencia Resid  # asitipcod
                                 ,""                         # socvclcod
                                 ,""                         # vclcoddig
                                 ,"N"                        # srvprlflg
                                 ,""                         # srrcoddig
                                 ,2                          # atdprinvlcod
                                 ,9 )                        # atdsrvorg
                        returning l_tabname
                                 ,l_sqlcode

      if l_sqlcode <> 0 then
         let l_msg = "CTA15M00 - ",l_msg

         call ctx13g00(l_sqlcode,"datmservico",l_msg)

         rollback work

         prompt "" for l_prompt

         let l_ret      = l_sqlcode
         let l_mensagem = l_msg
	 return  l_ret, l_mensagem
      end if


      #---------------------------------
      ---> Relaciona Servico com Ligacao
      #---------------------------------
      if l_cta15m00.atdsrvnum is not null and
         l_cta15m00.atdsrvano is not null then

         whenever error continue
         insert into datrligsrv (lignum
                                ,atdsrvnum
                                ,atdsrvano )
                         values (param.lignum
                                ,l_cta15m00.atdsrvnum
                                ,l_cta15m00.atdsrvano )
         whenever error stop

         if sqlca.sqlcode <> 0 then
            let l_msg = "CTA15M00 - ",l_msg

            call ctx13g00(sqlca.sqlcode,"datrligsrv",l_msg)

            rollback work

            prompt "" for l_prompt

            let l_ret      = sqlca.sqlcode
            let l_mensagem = l_msg
	    return  l_ret, l_mensagem
         end if


         #-----------------------------------
         ---> Atualiza Servico na datmligacao
         #-----------------------------------

         whenever error continue
         update datmligacao set (atdsrvnum
                                ,atdsrvano)
                              = (l_cta15m00.atdsrvnum
                                ,l_cta15m00.atdsrvano )
                   where lignum = param.lignum
         whenever error stop

         if sqlca.sqlcode <> 0 then
            let l_msg = "CTA15M00 - ",l_msg

            call ctx13g00(sqlca.sqlcode,"datmligacao",l_msg)

            rollback work

            prompt "" for l_prompt

            let l_ret      = sqlca.sqlcode
            let l_mensagem = l_msg
	    return  l_ret, l_mensagem
         end if
      end if


      #------------------------------
      ---> Insere Clausula X Servicos
      #------------------------------
      if lr_clausula.clscod is not null then

         call cts10g02_grava_servico_clausula(l_cta15m00.atdsrvnum
                                             ,l_cta15m00.atdsrvano
                                             ,g_documento.ramcod
                                             ,lr_clausula.clscod)
                                    returning l_tabname
                                             ,l_sqlcode

         if l_sqlcode <> 0 then
            let l_msg = "CTA15M00 - ",l_msg

            call ctx13g00(l_sqlcode,"datrsrvcls",l_msg)

            rollback work

            prompt "" for l_prompt

            let l_ret      = l_sqlcode
            let l_mensagem = l_msg
	    return  l_ret, l_mensagem
         end if
      end if


      #------------------------------------------------
      ---> Insere Servico X RE (Residencia Emergencial)
      #------------------------------------------------
      whenever error continue
      insert into datmsrvre (atdsrvnum      ,atdsrvano
                            ,lclrsccod      ,orrdat
                            ,orrhor         ,sinntzcod
                            ,socntzcod      ,atdsrvretflg
                            ,atdorgsrvnum   ,atdorgsrvano
                            ,srvretmtvcod   ,sinvstnum
                            ,sinvstano      ,espcod
                            ,retprsmsmflg   ,lclnumseq
                            ,rmerscseq)
                     values (l_cta15m00.atdsrvnum
                            ,l_cta15m00.atdsrvano
                            ,g_rsc_re.lclrsccod
                            ,l_cta15m00.atddat
                            ,l_cta15m00.atdhor
                            ,""
                            ,l_socntzcod  ---> So p/ S66 e S78
                            ,"N"
                            ,"","","","","","",""
                            ,g_documento.lclnumseq
                            ,g_documento.rmerscseq )
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_msg = "CTA15M00 - ",l_msg

         call ctx13g00(sqlca.sqlcode,"datmsrvre",l_msg)

         rollback work

         prompt "" for l_prompt

         let l_ret      = sqlca.sqlcode
         let l_mensagem = l_msg
         return  l_ret, l_mensagem
      end if


      #-----------------------------
      ---> Insere Apolice x Servicos
      #-----------------------------
      if g_documento.aplnumdig is not null and
         g_documento.aplnumdig <> 0        then

         call cts10g02_grava_servico_apolice(l_cta15m00.atdsrvnum
                                            ,l_cta15m00.atdsrvano
                                            ,g_documento.succod
                                            ,g_documento.ramcod
                                            ,g_documento.aplnumdig
                                            ,g_documento.itmnumdig
                                            ,g_documento.edsnumref)
                                   returning l_tabname
                                            ,l_sqlcode

         if l_sqlcode <> 0 then
            let l_msg = "CTA15M00 - ",l_msg

            call ctx13g00(l_sqlcode,"datrsevapol",l_msg)

            rollback work

            prompt "" for l_prompt

            let l_ret      = l_sqlcode
            let l_mensagem = l_msg
            return  l_ret, l_mensagem
         end if
      end if


      #-----------------------------
      ---> Grava Problema do Servico
      #-----------------------------
      call ctx09g02_inclui(l_cta15m00.atdsrvnum
                          ,l_cta15m00.atdsrvano
                          ,1   --->  1-Segurado 2-Pst - c24pbminforg
                          ,l_c24pbmcod
                          ,l_c24pbmdes
                          ,"") --->pstcoddig
                 returning l_sqlcode
                          ,l_tabname

      if l_sqlcode <> 0 then
         let l_msg = "CTA15M00 - ",l_msg

         call ctx13g00(l_sqlcode,"datrsrvpbm",l_msg)

         rollback work

         prompt "" for l_prompt

         let l_ret      = l_sqlcode
         let l_mensagem = l_msg
         return  l_ret, l_mensagem
      end if


      #----------------------------------
      ---> Grava etapas do acompanhamento
      #----------------------------------
      call cts10g04_insere_etapa(l_cta15m00.atdsrvnum
                                ,l_cta15m00.atdsrvano
                                ,"4"  ---> Concluido
                                ,10573
                                ,""
                                ,""
                                ,"")
                       returning l_sqlcode

      if l_sqlcode <> 0 then
         let l_msg = "CTA15M00 - ",l_msg

         call ctx13g00(l_sqlcode,"datmsrvacp",l_msg)

         rollback work

         prompt "" for l_prompt

         let l_ret      = l_sqlcode
         let l_mensagem = l_msg
         return  l_ret, l_mensagem
      end if


      #-----------------------------------------------------
      ---> Replica Historico da Ligacao p/ Historico Servico
      #-----------------------------------------------------
      call cta15m00_hst_lig_srv(param.lignum
                               ,l_cta15m00.atdsrvnum
                               ,l_cta15m00.atdsrvano)

      if l_ret <> 1 then
         let l_msg = "CTA15M00 - ",l_msg

         call ctx13g00(l_sqlcode,"datmservhst",l_msg)

         rollback work

         prompt "" for l_prompt

         let l_ret      = l_sqlcode
         let l_mensagem = l_msg
         return  l_ret, l_mensagem
      end if

      commit work
      # war room
      #--------------------------------------------
      ---> Ponto de Acesso apos a gravacao do Laudo
      #--------------------------------------------
      call cts00g07_apos_grvlaudo(l_cta15m00.atdsrvnum
                                 ,l_cta15m00.atdsrvano)

      call cty10g00_grupo_ramo(g_documento.ciaempcod
                              ,g_documento.ramcod)
                     returning l_ret
                              ,l_mensagem
                              ,l_ramgrpcod


      #---------------------------------------------------------
      ---> Verifica se esta ativo a opcao de Conta Corrente / RE
      #---------------------------------------------------------
      call cta00m06_re_contacorrente()
           returning l_conta_corrente

      if l_ramgrpcod      = 4                   and
         l_conta_corrente = true                and
         (g_documento.aplnumdig is not null or
          g_documento.crtsaunum is not null   ) then

         call cts17m11_agendasrvre(l_cta15m00.atdsrvnum
                                  ,l_cta15m00.atdsrvano
                                  ,l_cta15m00.atddat
                                  ,l_cta15m00.atdhor
                                  ,"N")
      end if


   #--------------------------
   ---> Atendimento Presencial
   #--------------------------
   else


      #-----------------------------------------------------
      ---> Replica Historico da Ligacao p/ Historico Servico
      #-----------------------------------------------------
      call cta15m00_hst_prt_hdk(param.lignum
                               ,l_cta15m00.atddat
                               ,l_cta15m00.atdhor)

      if l_ret <> 1 then
         let l_msg = "CTA15M00 - ",l_msg

         call ctx13g00(l_sqlcode,"datmservhst",l_msg)

         rollback work

         prompt "" for l_prompt

         let l_ret      = l_sqlcode
         let l_mensagem = l_msg
         return  l_ret, l_mensagem
      else
         commit work
         error " O motivo da visita foi gravado no historico. "
      end if


   end if

   return  l_ret, l_mensagem

end function


#--------------------------------------------------------------------
function cta15m00_hst_lig_srv(param)
#--------------------------------------------------------------------

   define param         record
          lignum        like datmligacao.lignum
         ,atdsrvnum     like datmservhist.atdsrvnum
         ,atdsrvano     like datmservhist.atdsrvano
   end record

   define l_cta15m00    record
          c24funmat     like datmlighist.c24funmat
         ,c24ligdsc     like datmlighist.c24ligdsc
         ,ligdat        like datmlighist.ligdat
         ,lighorinc     like datmlighist.lighorinc
         ,c24usrtip     like datmlighist.c24usrtip
         ,c24empcod     like datmlighist.c24empcod
   end record

   define l_tabname     char(20)
         ,l_sqlcode     integer

   let l_tabname  = null
   let l_sqlcode  = null
   let l_ret      = null
   let l_mensagem = null

   initialize l_cta15m00.* to null

   #------------------------------------------------------------------
   ---> Resgata o Historico da Ligacao e Grava no Historico do Servico
   #------------------------------------------------------------------
   whenever error continue
   declare c_cta15m00001 cursor for

      select c24funmat
            ,c24ligdsc
            ,ligdat
            ,lighorinc
            ,c24usrtip
            ,c24empcod
       from datmlighist
      where lignum = param.lignum
      order by c24txtseq

   foreach c_cta15m00001 into l_cta15m00.c24funmat
                             ,l_cta15m00.c24ligdsc
                             ,l_cta15m00.ligdat
                             ,l_cta15m00.lighorinc
                             ,l_cta15m00.c24usrtip
                             ,l_cta15m00.c24empcod

      whenever error stop

      if sqlca.sqlcode <> 0   and
         sqlca.sqlcode <> 100 then
         error " Erro em c_cta15m00001. Avise a informatica."
      end if


      if l_cta15m00.c24ligdsc is not null then


         #-------------------------------------
	 ---> Registra Historico para o Servico
         #-------------------------------------
         call ctd07g01_ins_datmservhist(param.atdsrvnum
                                       ,param.atdsrvano
                                       ,l_cta15m00.c24funmat
                                       ,l_cta15m00.c24ligdsc
                                       ,l_cta15m00.ligdat
                                       ,l_cta15m00.lighorinc
                                       ,l_cta15m00.c24empcod
                                       ,l_cta15m00.c24usrtip )
                              returning l_ret ---> Qdo volta 1 = OK
                                       ,l_mensagem
      end if

      initialize l_cta15m00.* to null

   end foreach

end function

#--------------------------------------------------------------------
function cta15m00_hst_prt_hdk(param)
#--------------------------------------------------------------------
---> Registra Historico da Ligacao c/ Motivo da Visita p/ Prestador
---> Se alterar esta logica revisar os modulos cty20g00 e ctf00m10

   define param         record
	  lignum        like datmligacao.lignum
         ,data          date
         ,hora          datetime hour to minute
   end record


   define l_cta15m00a   record
          texto1        char(70)
         ,texto2        char(70)
   end record

   define l_cont        smallint
         ,l_texto       char(70)

   let l_cont    = null
   let l_texto   = null


   initialize l_cta15m00a.* to null

   open window cta15m00a at 12,05 with form "cta15m00a"
        attribute (form line 1, border)

   input by name l_cta15m00a.texto1
                ,l_cta15m00a.texto2


      before field texto1
         display by name l_cta15m00a.texto1 attribute (reverse)

      after field texto1
         display by name l_cta15m00a.texto1

         if l_cta15m00a.texto1 is null or
            l_cta15m00a.texto1 =  " "  then
            error " Informe o motivo da visita. "
            next field texto1
         end if


      before field texto2
         display by name l_cta15m00a.texto2 attribute (reverse)

      after field texto2
         display by name l_cta15m00a.texto2

      on key (interrupt)

         if l_cta15m00a.texto1 is null or
            l_cta15m00a.texto1 =  " "  then
            error " O motivo da visita deve ser informado. "
            next field texto1
         end if
         exit input
    end input


    begin work
    if g_documento.c24astcod = "HDK" then
       #---------------------------
       ---> Altera Assunto para S67
       #---------------------------
       whenever error continue
       update datmligacao
          set c24astcod = "S67"
        where lignum    = param.lignum
          and c24astcod = g_documento.c24astcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          error "Problemas na Atualizacao do Codigo HDK para S67.", sqlca.sqlcode sleep 3
       end if
       let g_documento.c24astcod = "S67"
    end if
    #--------------------------------------------
    --> Registrar no Historico o Motivo da Visita
    #--------------------------------------------
    for l_cont = 1 to 3

       if l_cont = 1 then
          let l_texto = "Mensagem para Prestador: "
       else
          if l_cont = 2 then
             let l_texto = l_cta15m00a.texto1
          else
             if l_cta15m00a.texto2 is null or
                l_cta15m00a.texto2 =  " "  then
                let l_cta15m00a.texto2 = "."
             end if
             let l_texto = l_cta15m00a.texto2
          end if
       end if

       call ctd06g01_ins_datmlighist(param.lignum
                                    ,g_issk.funmat
                                    ,l_texto
                                    ,param.data
                                    ,param.hora
                                    ,g_issk.usrtip
                                    ,g_issk.empcod)
                          returning l_ret  ---> qdo volta 1 = OK
                                   ,l_mensagem

    end for

   close window cta15m00a

end function

#--------------------------------------------------------------------
function cta15m00_ntz_pbm(param)
#--------------------------------------------------------------------
---> Registra Historico da Ligacao c/ Motivo da Visita p/ Prestador

   define param         record
          clscod        like datrsrvcls.clscod
   end record

   define l_rmemdlcod   like rsamseguro.rmemdlcod
         ,l_clscod      like datrsrvcls.clscod
         ,l_socntzcod   like datksocntz.socntzcod
         ,l_status      smallint
         ,l_mensagem    char(100)
         ,l_c24pbmcod   like datkpbm.c24pbmcod
         ,l_c24pbmdes   like datkpbm.c24pbmdes
         ,l_atddfttxt   like datmservico.atddfttxt
         ,l_cont        smallint
         ,l_confirma    char(01)

   let l_rmemdlcod = null
   let l_clscod    = null
   let l_socntzcod = null
   let l_status    = null
   let l_mensagem  = null
   let l_c24pbmcod = null
   let l_c24pbmdes = null
   let l_atddfttxt = null
   let l_confirma  = null
   let l_cont      = 0


   #--------------------
   --> Define Modalidade
   #--------------------
   if g_documento.ramcod = 31  or
      g_documento.ramcod = 531 then

      let l_rmemdlcod = 0
   end if


   #-------------------------
   --> Define Modalidade - RE
   #-------------------------
   whenever error continue
   select rmemdlcod
     into l_rmemdlcod
     from rsamseguro
    where succod    = g_documento.succod
      and ramcod    = g_documento.ramcod
      and aplnumdig = g_documento.aplnumdig
   whenever error stop

   if sqlca.sqlcode <> 0   and
      sqlca.sqlcode <> 100 then
     error "Erro na localizacao da Modalidade-cta15m00. Avise a informatica. "
   end if

   if l_rmemdlcod is null then
      let l_rmemdlcod = 0
   end if

   let l_cont = 0

   while l_cont = 0

      #-------------------------------------------------------------------
      --> Segue este Fluxo quando for Auto ou
      --> quando Apolice do RE nao Clausula Contratada ou limite e for S78
      --> tiver clausula
      #-------------------------------------------------------------------
      if (g_documento.ramcod = 531                ) or
         ((param.clscod is null              or
           param.clscod =  "   "           ) and
          ( g_documento.c24astcod = "S78"  )     ) then


         #-------------------
         --> Mostra Naturezas
         #-------------------
         call cts17m06_popup_natureza (g_documento.aplnumdig
                                      ,g_documento.c24astcod
                                      ,g_documento.ramcod
                                      ,param.clscod
                                      ,l_rmemdlcod
                                      ,g_documento.prporg
                                      ,g_documento.prpnumdig
                                      ,""     --> socntzgrpcod
                                      ,"")    --> crtsaunum
                             returning l_socntzcod
                                      ,l_clscod
           if l_clscod = '044' and
              l_socntzcod = 206 then
              call cts08g01 ("A","N", ""
                       ,""
                       ,"NATUREZA NÃO PERMITIDA PARA "
                       ,"ATENDIMENTO TELEFONICO")
             returning l_confirma
             continue while
           end if
      else
         call cts12g99(g_documento.succod
                      ,g_documento.ramcod
                      ,g_documento.aplnumdig
                      ,g_documento.prporg
                      ,g_documento.prpnumdig
                      ,g_documento.lclnumseq
                      ,g_documento.rmerscseq
                      ,g_documento.c24astcod
                      ,"")
             returning l_socntzcod
      end if

      if l_socntzcod is not null and
         l_socntzcod <> 0        then


         #-------------------------------
         --> Mostra Problemas da Natureza
         #-------------------------------
         call cts17m07_problema(g_documento.aplnumdig
                               ,g_documento.c24astcod
                               ,9     --> atdsrvorg
                               ,""    --> c24pbmcod
                               ,l_socntzcod
                               ,param.clscod
                               ,param.clscod
                               ,l_rmemdlcod
                               ,g_documento.ramcod
                               ,"")   --> crtsaunum
                      returning l_status
                               ,l_mensagem
                               ,l_c24pbmcod
                               ,l_atddfttxt

      end if

      if l_c24pbmcod is not null and
         l_c24pbmcod <> 0        then

         let l_cont = 1
      else

         #----------------------------------------
         ---> Alerta para Direcionar o Atendimento
         #----------------------------------------
         call cts08g01 ("A","N", ""
                       ,""
                       ,"INFORME A NATUREZA E O PROBLEMA."
                       ,"")
             returning l_confirma

      end if
   end while


   #-------------------------
   ---> Descricao do Problema
   #-------------------------
   whenever error continue
   select c24pbmdes
     into l_c24pbmdes
     from datkpbm
    where c24pbmcod = l_c24pbmcod
   whenever error stop

   if sqlca.sqlcode <> 0 then
     let l_c24pbmdes = "PROBLEMA NAO LOCALIZADO"
   end if


   return l_c24pbmcod
         ,l_c24pbmdes
         ,l_socntzcod


end function
