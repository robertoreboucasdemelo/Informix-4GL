#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: cts41m00                                                  #
# Objetivo.......: Realizar o acompanhamento do servico do cliente cartao    #
#                  Portoseg.                                                 #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 211982                                                    #
#............................................................................#
# Desenvolvimento: Saulo Correa, META                                        #
# Liberacao      : 20/09/2007                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica  PSI     Alteracao                                #
# --------   -------------  ------  -----------------------------------------#
# 13/08/2009 Sergio Burini  244236  Inclusão do Sub-Dairro                   #
#----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo 219444  Passar para "ctd07g04_insere_srvre" novos#
#                                   parametros (lclnumseq / rmerscseq)       #
#----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

Define mr_tela record
   nom          char(33)
  ,cgccpf       char(18)
  ,endereco     char(65)
  ,brrnom       char(20)
  ,cidnom       char(20)
  ,ufdcod       char(02)
  ,lclrefptotxt char(55)
  ,endzon       char(02)
  ,dddcod       char(04)
  ,lcltelnum    char(10)
  ,lclcttnom    char(30)
  ,asitipabvdes like datkasitip.asitipabvdes
  ,atdlibflg    char(01)
  ,prslocflg    char(01)
  ,atendlib     char(65)
  ,orcvlrtot    decimal(10,2)
end record

define am_tela array[11] of record
   servico   char(10)
  ,socntzcod smallint
  ,socntzdes char(14)
  ,c24pbmcod smallint
  ,c24pbmdes char(15)
  ,atdetpcod smallint
  ,atdetpdes char(13)
  ,orcvlr    decimal(9,2)

end record

define a_servico array[11] of record
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
end record

define mr_aux record
   cgccpfnum    like datrligcgccpf.cgccpfnum
  ,cgcord       like datrligcgccpf.cgcord
  ,cgccpfdig    like datrligcgccpf.cgccpfdig
end record

define mr_ctx04g00   record
   lclidttxt    like datmlcl.lclidttxt
  ,lgdtip       like datmlcl.lgdtip
  ,lgdnom       like datmlcl.lgdnom
  ,lgdnum       like datmlcl.lgdnum
  ,lclbrrnom    like datmlcl.lclbrrnom
  ,brrnom       like datmlcl.brrnom
  ,cidnom       like datmlcl.cidnom
  ,ufdcod       like datmlcl.ufdcod
  ,lclrefptotxt like datmlcl.lclrefptotxt
  ,endzon       like datmlcl.endzon
  ,lgdcep       like datmlcl.lgdcep
  ,lgdcepcmp    like datmlcl.lgdcepcmp
  ,lclltt       like datmlcl.lclltt
  ,lcllgt       like datmlcl.lcllgt
  ,dddcod       like datmlcl.dddcod
  ,lcltelnum    like datmlcl.lcltelnum
  ,lclcttnom    like datmlcl.lclcttnom
  ,c24lclpdrcod like datmlcl.c24lclpdrcod
  ,coderro      integer
  ,emeviacod    like datmlcl.emeviacod
  ,celteldddcod like datmlcl.celteldddcod
  ,celtelnum    like datmlcl.celtelnum
  ,endcmp       like datmlcl.endcmp
end record

define m_nro_reg  smallint
      ,m_data         date
      ,m_hora         datetime hour to minute
      ,m_socntzgrpcod like datksocntz.socntzgrpcod

define mr_cts10g06 record
       c24solnom like datmservico.c24solnom
      ,nom       like datmservico.nom
      ,asitipcod like datmservico.asitipcod
      ,atdlibflg like datmservico.atdlibflg
      ,prslocflg like datmservico.prslocflg
      ,atdfnlflg      like datmservico.atdfnlflg
      ,atdhorpvt      like datmservico.atdhorpvt
      ,atddatprg      like datmservico.atddatprg
      ,atdhorprg      like datmservico.atdhorprg
      ,atdpvtretflg   like datmservico.atdpvtretflg
      ,atdrsdflg      like datmservico.atdrsdflg
      end record


define mr_ctd06g00 record
       ciaempcod    like datmligacao.ciaempcod
      ,ligcvntip    like datmligacao.ligcvntip
      ,c24astcod    like datmligacao.c24astcod
      ,c24soltipcod like datmligacao.c24soltipcod
      ,c24solnom    like datmligacao.c24solnom
      ,c24soltip    like datmligacao.c24soltip
end record

define m_atdsrvnum like datmservico.atdsrvnum
      ,m_atdsrvano like datmservico.atdsrvano

define m_subbairro array[03] of record
       lclbrrnom   like datmlcl.lclbrrnom
end record
define m_atdsrvorg   like datmservico.atdsrvorg,
       m_acesso_ind  smallint

#-------------------------#
function cts41m00(lr_param)
#-------------------------#
   define lr_param record
      atdsrvnum like datmservico.atdsrvnum
     ,atdsrvano like datmservico.atdsrvano
   end record

   options
     insert key f1,
     delete key f36

   initialize m_subbairro to null

   let m_nro_reg = 0
   let m_data = null
   let m_hora = null
   let m_socntzgrpcod = null

   let m_atdsrvnum  = lr_param.atdsrvnum
   let m_atdsrvano  = lr_param.atdsrvano

   initialize mr_cts10g06, mr_tela, a_servico, am_tela to null
   let g_documento.acao = "ORC"

   open window w_cts41m00 at 04,02 with form "cts41m00"
      attribute (form line 1)

   call cts41m00_seleciona(lr_param.atdsrvnum
                          ,lr_param.atdsrvano)

   call cts41m00_input(lr_param.atdsrvnum
                      ,lr_param.atdsrvano
                      ,mr_ctd06g00.ligcvntip
                      ,m_data
                      ,m_hora)

   close window w_cts41m00

   let int_flag = false

end function

#----------------------------------------
function cts41m00_seleciona(lr_param)
#----------------------------------------
   define lr_param record
      atdsrvnum like datmservico.atdsrvnum
     ,atdsrvano like datmservico.atdsrvano
   end record

   define al_retorno array[10] of record
      atdmltsrvnum like datratdmltsrv.atdmltsrvnum
     ,atdmltsrvano like datratdmltsrv.atdmltsrvano
     ,socntzdes    like datksocntz.socntzdes
     ,espdes       like dbskesp.espdes
     ,atddfttxt    like datmservico.atddfttxt
   end record

   define l_lignum       like datrligsrv.lignum
         ,l_atdsrvnum    like datmservico.atdsrvnum
         ,l_atdsrvano    like datmservico.atdsrvano
         ,l_i            smallint

   define l_coderro      smallint
         ,l_msgerro      char(60)

   initialize mr_cts10g06, mr_ctx04g00, mr_ctd06g00, al_retorno, mr_tela to null

   let l_lignum       = null
   let l_atdsrvnum    = null
   let l_atdsrvano    = null
   let l_i            = null
   let l_coderro      = 0
   let l_msgerro      = null

   call cts10g06_dados_servicos(12
                               ,lr_param.atdsrvnum
                               ,lr_param.atdsrvano)
      returning l_coderro
               ,l_msgerro
               ,mr_cts10g06.c24solnom
               ,mr_cts10g06.nom
               ,mr_cts10g06.asitipcod
               ,mr_cts10g06.atdlibflg
               ,mr_cts10g06.prslocflg

   let mr_tela.nom       = mr_cts10g06.nom
   let mr_tela.atdlibflg = mr_cts10g06.atdlibflg
   let mr_tela.prslocflg = mr_cts10g06.prslocflg

   call ctx04g00_local_gps(lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,1)
      returning mr_ctx04g00.lclidttxt
               ,mr_ctx04g00.lgdtip
               ,mr_ctx04g00.lgdnom
               ,mr_ctx04g00.lgdnum
               ,mr_ctx04g00.lclbrrnom
               ,mr_ctx04g00.brrnom
               ,mr_ctx04g00.cidnom
               ,mr_ctx04g00.ufdcod
               ,mr_ctx04g00.lclrefptotxt
               ,mr_ctx04g00.endzon
               ,mr_ctx04g00.lgdcep
               ,mr_ctx04g00.lgdcepcmp
               ,mr_ctx04g00.lclltt
               ,mr_ctx04g00.lcllgt
               ,mr_ctx04g00.dddcod
               ,mr_ctx04g00.lcltelnum
               ,mr_ctx04g00.lclcttnom
               ,mr_ctx04g00.c24lclpdrcod
               ,mr_ctx04g00.celteldddcod
               ,mr_ctx04g00.celtelnum
               ,mr_ctx04g00.endcmp
               ,mr_ctx04g00.coderro
               ,mr_ctx04g00.emeviacod

   # PSI 244589 - Inclusão de Sub-Bairro - Burini
   let m_subbairro[1].lclbrrnom = mr_ctx04g00.lclbrrnom

   call cts06g10_monta_brr_subbrr(mr_ctx04g00.brrnom,
                                  mr_ctx04g00.lclbrrnom)
        returning mr_ctx04g00.lclbrrnom

   let mr_tela.brrnom       = mr_ctx04g00.brrnom
   let mr_tela.cidnom       = mr_ctx04g00.cidnom
   let mr_tela.ufdcod       = mr_ctx04g00.ufdcod
   let mr_tela.lclrefptotxt = mr_ctx04g00.lclrefptotxt
   let mr_tela.endzon       = mr_ctx04g00.endzon
   let mr_tela.dddcod       = mr_ctx04g00.dddcod
   let mr_tela.lcltelnum    = mr_ctx04g00.lcltelnum
   let mr_tela.lclcttnom    = mr_ctx04g00.lclcttnom

   let mr_tela.endereco = mr_ctx04g00.lgdtip clipped, ' '
                         ,mr_ctx04g00.lgdnom clipped, ' '
                         ,mr_ctx04g00.lgdnum


   call ctd08g00_dados_assist(1, mr_cts10g06.asitipcod)
      returning l_coderro
               ,l_msgerro
               ,mr_tela.asitipabvdes

   call cts10g11_atend_lib(1
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano)
      returning l_coderro
               ,l_msgerro
               ,mr_tela.atendlib

   let l_lignum = cts20g00_servico(lr_param.atdsrvnum
                                  ,lr_param.atdsrvano)

   call ctd06g00_ligacao_emp(2
                            ,l_lignum)
      returning l_coderro
               ,l_msgerro
               ,mr_ctd06g00.ciaempcod
               ,mr_ctd06g00.ligcvntip
               ,mr_ctd06g00.c24astcod
               ,mr_ctd06g00.c24soltipcod
               ,mr_ctd06g00.c24solnom
               ,mr_ctd06g00.c24soltip

   let g_documento.c24astcod = mr_ctd06g00.c24astcod
   let g_documento.ciaempcod = mr_ctd06g00.ciaempcod

   call ctd06g02_ligacao_cgccpf(l_lignum)
      returning l_coderro
               ,l_msgerro
               ,mr_aux.cgccpfnum
               ,mr_aux.cgcord
               ,mr_aux.cgccpfdig

   if mr_aux.cgcord is null or
      mr_aux.cgcord = 0    then
      let mr_tela.cgccpf = mr_aux.cgccpfnum  using '&&&,&&&,&&&'
                          ,'-'
                          ,mr_aux.cgccpfdig  using '&&'

      let mr_tela.cgccpf[4] = '.'
      let mr_tela.cgccpf[8] = '.'
   else
      let mr_tela.cgccpf = mr_aux.cgccpfnum  using '&&,&&&,&&&'
                          ,'/'
                          ,mr_aux.cgcord     using '&&&&'
                          ,'-'
                          ,mr_aux.cgccpfdig  using '&&'

      let mr_tela.cgccpf[3] = '.'
      let mr_tela.cgccpf[7] = '.'
   end if

   call cts40g03_data_hora_banco(2)
      returning m_data ,m_hora

   let m_nro_reg = 0

   call cts10g06_dados_servicos(13
                               ,lr_param.atdsrvnum
                               ,lr_param.atdsrvano)
      returning l_coderro
               ,l_msgerro
               ,mr_cts10g06.atdfnlflg
               ,mr_cts10g06.atdhorpvt
               ,mr_cts10g06.atddatprg
               ,mr_cts10g06.atdhorprg
               ,mr_cts10g06.atdpvtretflg

   call cts41m00_array(lr_param.atdsrvnum
                      ,lr_param.atdsrvano)

   call cts29g00_obter_multiplo(1
                               ,lr_param.atdsrvnum
                               ,lr_param.atdsrvano)
      returning l_coderro
               ,l_msgerro
               ,al_retorno[1].*
               ,al_retorno[2].*
               ,al_retorno[3].*
               ,al_retorno[4].*
               ,al_retorno[5].*
               ,al_retorno[6].*
               ,al_retorno[7].*
               ,al_retorno[8].*
               ,al_retorno[9].*
               ,al_retorno[10].*

   for l_i = 1 to 10

      if al_retorno[l_i].atdmltsrvnum is not null and
      	 al_retorno[l_i].atdmltsrvano is not null then
         call cts41m00_array(al_retorno[l_i].atdmltsrvnum
                            ,al_retorno[l_i].atdmltsrvano)
      else
         exit for
      end if

   end for

   call cts41m00_mostra()

end function

#-------------------------------#
function cts41m00_input(lr_param)
#-------------------------------#
   define lr_param record
      atdsrvnum    like datmservico.atdsrvnum
     ,atdsrvano    like datmservico.atdsrvano
     ,ligcvntip    like datmligacao.ligcvntip
     ,data         date
     ,hora         datetime hour to minute
   end record

   define l_coderro     smallint
         ,l_msgerro     char(040)

   define l_flgret char(01)
         ,l_cidnom like datmlcl.cidnom
         ,l_lgdnom like datmlcl.lgdnom
         ,l_lixo   char(10)
         ,l_coderr smallint
         ,l_erro   smallint

   let l_flgret = null
   let l_cidnom = null
   let l_lgdnom = null
   let l_lixo   = null
   let l_coderr = null
   let l_erro   = 0

   let l_cidnom = mr_ctx04g00.cidnom
   let l_lgdnom = mr_ctx04g00.lgdnom

   display by name mr_tela.nom attribute(reverse)

   input by name mr_tela.nom
                ,mr_tela.atdlibflg
                ,mr_tela.prslocflg without defaults

      before field nom
         display by name mr_tela.nom attribute(reverse)

      after field nom
         display by name mr_tela.nom

         let mr_ctx04g00.lclbrrnom = m_subbairro[1].lclbrrnom

         let m_acesso_ind = false
         let m_atdsrvorg = 9
         call cta00m06_acesso_indexacao_aut(m_atdsrvorg)
              returning m_acesso_ind

         if m_acesso_ind = false then
            call cts06g03(1
                         ,m_atdsrvorg
                         ,lr_param.ligcvntip
                         ,lr_param.data
                         ,lr_param.hora
                         ,mr_ctx04g00.lclidttxt
                         ,mr_ctx04g00.cidnom
                         ,mr_ctx04g00.ufdcod
                         ,mr_ctx04g00.brrnom
                         ,mr_ctx04g00.lclbrrnom
                         ,mr_ctx04g00.endzon
                         ,mr_ctx04g00.lgdtip
                         ,mr_ctx04g00.lgdnom
                         ,mr_ctx04g00.lgdnum
                         ,mr_ctx04g00.lgdcep
                         ,mr_ctx04g00.lgdcepcmp
                         ,mr_ctx04g00.lclltt
                         ,mr_ctx04g00.lcllgt
                         ,mr_ctx04g00.lclrefptotxt
                         ,mr_ctx04g00.lclcttnom
                         ,mr_ctx04g00.dddcod
                         ,mr_ctx04g00.lcltelnum
                         ,mr_ctx04g00.c24lclpdrcod
                         ,''
                         ,mr_ctx04g00.celteldddcod
                         ,mr_ctx04g00.celtelnum
                         ,mr_ctx04g00.endcmp
                         ,'','', '', '', '', '')
               returning mr_ctx04g00.lclidttxt
                        ,mr_ctx04g00.cidnom
                        ,mr_ctx04g00.ufdcod
                        ,mr_ctx04g00.brrnom
                        ,mr_ctx04g00.lclbrrnom
                        ,mr_ctx04g00.endzon
                        ,mr_ctx04g00.lgdtip
                        ,mr_ctx04g00.lgdnom
                        ,mr_ctx04g00.lgdnum
                        ,mr_ctx04g00.lgdcep
                        ,mr_ctx04g00.lgdcepcmp
                        ,mr_ctx04g00.lclltt
                        ,mr_ctx04g00.lcllgt
                        ,mr_ctx04g00.lclrefptotxt
                        ,mr_ctx04g00.lclcttnom
                        ,mr_ctx04g00.dddcod
                        ,mr_ctx04g00.lcltelnum
                        ,mr_ctx04g00.c24lclpdrcod
                        ,l_lixo
                        ,mr_ctx04g00.celteldddcod
                        ,mr_ctx04g00.celtelnum
                        ,mr_ctx04g00.endcmp
                        ,l_flgret
                        ,l_lixo
                        ,l_lixo
                        ,l_lixo
                        ,l_lixo
                        ,l_lixo
                        ,l_lixo
         else
            call cts06g11(1
                         ,m_atdsrvorg
                         ,lr_param.ligcvntip
                         ,lr_param.data
                         ,lr_param.hora
                         ,mr_ctx04g00.lclidttxt
                         ,mr_ctx04g00.cidnom
                         ,mr_ctx04g00.ufdcod
                         ,mr_ctx04g00.brrnom
                         ,mr_ctx04g00.lclbrrnom
                         ,mr_ctx04g00.endzon
                         ,mr_ctx04g00.lgdtip
                         ,mr_ctx04g00.lgdnom
                         ,mr_ctx04g00.lgdnum
                         ,mr_ctx04g00.lgdcep
                         ,mr_ctx04g00.lgdcepcmp
                         ,mr_ctx04g00.lclltt
                         ,mr_ctx04g00.lcllgt
                         ,mr_ctx04g00.lclrefptotxt
                         ,mr_ctx04g00.lclcttnom
                         ,mr_ctx04g00.dddcod
                         ,mr_ctx04g00.lcltelnum
                         ,mr_ctx04g00.c24lclpdrcod
                         ,''
                         ,mr_ctx04g00.celteldddcod
                         ,mr_ctx04g00.celtelnum
                         ,mr_ctx04g00.endcmp
                         ,'','', '', '', '', '')
               returning mr_ctx04g00.lclidttxt
                        ,mr_ctx04g00.cidnom
                        ,mr_ctx04g00.ufdcod
                        ,mr_ctx04g00.brrnom
                        ,mr_ctx04g00.lclbrrnom
                        ,mr_ctx04g00.endzon
                        ,mr_ctx04g00.lgdtip
                        ,mr_ctx04g00.lgdnom
                        ,mr_ctx04g00.lgdnum
                        ,mr_ctx04g00.lgdcep
                        ,mr_ctx04g00.lgdcepcmp
                        ,mr_ctx04g00.lclltt
                        ,mr_ctx04g00.lcllgt
                        ,mr_ctx04g00.lclrefptotxt
                        ,mr_ctx04g00.lclcttnom
                        ,mr_ctx04g00.dddcod
                        ,mr_ctx04g00.lcltelnum
                        ,mr_ctx04g00.c24lclpdrcod
                        ,l_lixo
                        ,mr_ctx04g00.celteldddcod
                        ,mr_ctx04g00.celtelnum
                        ,mr_ctx04g00.endcmp
                        ,l_flgret
                        ,l_lixo
                        ,l_lixo
                        ,l_lixo
                        ,l_lixo
                        ,l_lixo
                        ,l_lixo
         end if


         # PSI 244589 - Inclusão de Sub-Bairro - Burini
         let m_subbairro[1].lclbrrnom = mr_ctx04g00.lclbrrnom

         call cts06g10_monta_brr_subbrr(mr_ctx04g00.brrnom,
                                        mr_ctx04g00.lclbrrnom)
              returning mr_ctx04g00.lclbrrnom

         let mr_tela.endereco = mr_ctx04g00.lgdtip clipped, ' '
                               ,mr_ctx04g00.lgdnom clipped, ' '
                               ,mr_ctx04g00.lgdnum

         let mr_tela.brrnom       = mr_ctx04g00.brrnom
         let mr_tela.cidnom       = mr_ctx04g00.cidnom
         let mr_tela.ufdcod       = mr_ctx04g00.ufdcod
         let mr_tela.lclrefptotxt = mr_ctx04g00.lclrefptotxt
         let mr_tela.endzon       = mr_ctx04g00.endzon
         let mr_tela.dddcod       = mr_ctx04g00.dddcod
         let mr_tela.lcltelnum    = mr_ctx04g00.lcltelnum
         let mr_tela.lclcttnom    = mr_ctx04g00.lclcttnom

         display by name mr_tela.*

      before field atdlibflg
         display by name mr_tela.atdlibflg attribute(reverse)

      after field atdlibflg
         display by name mr_tela.atdlibflg

         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left") then
            next field nom
         end if

         if mr_tela.atdlibflg is null or
           (mr_tela.atdlibflg <> 'S'  and
            mr_tela.atdlibflg <> 'N') then
            error 'Informe <S> Sim ou <N> Nao'
            next field atdlibflg
         end if

      before field prslocflg
         display by name mr_tela.prslocflg attribute(reverse)

      after field prslocflg
         display by name mr_tela.prslocflg

         if fgl_lastkey() = fgl_keyval("up") or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdlibflg
         end if

         if mr_tela.prslocflg is null or
           (mr_tela.prslocflg <> 'S'  and
            mr_tela.prslocflg <> 'N') then
            error 'Informe <S> Sim ou <N> Nao'
            next field prslocflg
         end if

         if l_cidnom <> mr_ctx04g00.cidnom or
            l_lgdnom <> mr_ctx04g00.lgdnom then

            let mr_ctx04g00.lclbrrnom = m_subbairro[1].lclbrrnom

            let l_coderro = cts06g07_local('M'
                                          ,lr_param.atdsrvnum
                                          ,lr_param.atdsrvano
                                          ,1
                                          ,mr_ctx04g00.lclidttxt
                                          ,mr_ctx04g00.lgdtip
                                          ,mr_ctx04g00.lgdnom
                                          ,mr_ctx04g00.lgdnum
                                          ,mr_ctx04g00.lclbrrnom
                                          ,mr_ctx04g00.brrnom
                                          ,mr_ctx04g00.cidnom
                                          ,mr_ctx04g00.ufdcod
                                          ,mr_ctx04g00.lclrefptotxt
                                          ,mr_ctx04g00.endzon
                                          ,mr_ctx04g00.lgdcep
                                          ,mr_ctx04g00.lgdcepcmp
                                          ,mr_ctx04g00.lclltt
                                          ,mr_ctx04g00.lcllgt
                                          ,mr_ctx04g00.dddcod
                                          ,mr_ctx04g00.lcltelnum
                                          ,mr_ctx04g00.lclcttnom
                                          ,mr_ctx04g00.c24lclpdrcod
                                          ,''
                                          ,mr_ctx04g00.emeviacod
                                          ,mr_ctx04g00.celteldddcod
                                          ,mr_ctx04g00.celtelnum
                                          ,mr_ctx04g00.endcmp)
            if l_coderro <> 0 then
               error 'Erro ', l_coderro, ' na alteracao do local de ocorrencia' sleep 2
               let l_coderro = 0
               next field prslocflg
            end if

            call ctd07g00_alt_srv(lr_param.atdsrvnum
                                 ,lr_param.atdsrvano
                                 ,mr_tela.nom
                                 ,mr_tela.atdlibflg
                                 ,mr_tela.prslocflg)
                 returning l_coderro
                          ,l_msgerro
         end if

      on key(interrupt, control-c, control-o, f17)
         let int_flag = false
         exit input

   end input

   while true
      call cts41m00_input_array(lr_param.atdsrvnum
                               ,lr_param.atdsrvano
                               ,lr_param.data
                               ,lr_param.hora)
      if int_flag then
         let int_flag = false
         exit while
      end if

      call cts41m00_seleciona(lr_param.atdsrvnum
                             ,lr_param.atdsrvano)
   end while

end function

#------------------------------------------
function cts41m00_input_array(lr_param)
#------------------------------------------
   define lr_param record
      atdsrvnum    like datmservico.atdsrvnum
     ,atdsrvano    like datmservico.atdsrvano
     ,data         date
     ,hora         datetime hour to minute
   end record

   define l_msg       char(100),
          l_etapa_ant like datmsrvacp.atdetpcod,
          l_orcvlr_ant like datmsrvorc.orcvlr

   define lr_aux record
      socntzcod    smallint
     ,clscod       like rsdmclaus.clscod
     ,socntzdes    like datksocntz.socntzdes
     ,socntzgrpcod like datksocntz.socntzgrpcod
     ,ret          smallint
     ,mens         char(100)
     ,c24pbmcod    like datkpbm.c24pbmcod
     ,atddfttxt    like datkpbm.c24pbmdes
     ,atdetpcod    smallint
     ,atdetpdes    char(13)
     ,data         date
     ,hora         datetime hour to minute
   end record

   define l_aux_atdetpcod smallint
         ,l_aux_atdetpdes char(13)
         ,l_orcvlr        like datmsrvorc.orcvlr
         ,l_c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
         ,l_codigo        like datksocntz.socntzgrpcod
         ,l_c24pbmdes     like datkpbm.c24pbmdes

   define l_arr       smallint
         ,l_tela      smallint
         ,l_i         smallint
         ,l_insere    smallint
         ,l_coderro   smallint
         ,l_msgerro   char(40)
         ,l_count     integer
         ,l_scr       smallint
         ,l_scrline   smallint
         ,l_mensagem  char(100)
         ,l_status    smallint
         ,l_erro      smallint

   let l_msg           = null
   let l_insere        = null
   let l_arr           = null
   let l_tela          = null
   let l_i             = null
   let l_insere        = false
   let l_coderro       = 0
   let l_msgerro       = null
   let l_aux_atdetpcod = null
   let l_aux_atdetpdes = null
   let l_count         = null
   let l_orcvlr = 0
   let l_etapa_ant     = null
   let l_orcvlr_ant    = null
   let l_c24pbmgrpcod  = null
   let l_c24pbmdes     = null

   initialize lr_aux to null

   options
     insert key f1,
     delete key f36

   let g_documento.atdsrvnum = lr_param.atdsrvnum
   let g_documento.atdsrvano = lr_param.atdsrvano

   call set_count(m_nro_reg)

   let mr_tela.orcvlrtot = 0
   for l_i = 1 to arr_count()
      if am_tela[l_i].orcvlr is not null then
         let mr_tela.orcvlrtot = mr_tela.orcvlrtot + am_tela[l_i].orcvlr
      end if
   end for

   let l_i = l_i -1

   if mr_tela.orcvlrtot = 0 then
      let mr_tela.orcvlrtot = null
   end if
   display mr_tela.orcvlrtot   to orcvlrtot

   input array am_tela without defaults from s_cts41m00.*

      before row
         let l_arr = arr_curr()
         let l_tela = scr_line()

      after row
         let l_arr = arr_curr()
         let l_tela = scr_line()

      before insert
         let l_insere = true
         next field socntzcod

      before field socntzcod
         if not l_insere then
            next field atdetpcod
         end if
         display am_tela[l_arr].socntzcod to s_cts41m00[l_tela].socntzcod attribute(reverse)

      after field socntzcod
         display am_tela[l_arr].socntzcod to s_cts41m00[l_tela].socntzcod

         if fgl_lastkey() <> fgl_keyval("up") and
            fgl_lastkey() <> fgl_keyval("left") then

            initialize lr_aux to null

            if am_tela[l_arr].socntzcod is null then

                call cts17m06_popup_natureza
                     ("", g_documento.c24astcod, "", "", "", "", "", "", "")
                     returning am_tela[l_arr].socntzcod
                              ,lr_aux.clscod
                   next field  socntzcod
            end if

            call ctc16m03_inf_natureza(am_tela[l_arr].socntzcod,'A')
                 returning l_status, l_mensagem,
                           am_tela[l_arr].socntzdes, l_codigo

            if l_status <> 1 then
               initialize am_tela[l_arr].socntzcod to null
               error "Codigo de natureza invalido!"
               next field socntzcod
            else
               display am_tela[l_arr].socntzdes to s_cts41m00[l_tela].socntzdes
            end if

            if am_tela[l_arr].socntzcod is null then
               let am_tela[l_arr].socntzdes = null
               display am_tela[l_arr].socntzdes to s_cts41m00[l_tela].socntzdes

               next field socntzcod
            end if

           if lr_aux.socntzgrpcod <> m_socntzgrpcod then
              let am_tela[l_arr].socntzdes = null
              display am_tela[l_arr].socntzdes to s_cts41m00[l_tela].socntzdes

              error 'Informe somente naturezas do mesmo grupo'
              next field socntzcod
           end if

           display am_tela[l_arr].socntzcod to s_cts41m00[l_tela].socntzcod
           display am_tela[l_arr].socntzdes to s_cts41m00[l_tela].socntzdes
        end if

      before field c24pbmcod
         if not l_insere then
            next field atdetpcod
         end if
         display am_tela[l_arr].c24pbmcod to s_cts41m00[l_tela].c24pbmcod attribute(reverse)

      after field c24pbmcod
         display am_tela[l_arr].c24pbmcod to s_cts41m00[l_tela].c24pbmcod

         if fgl_lastkey() <> fgl_keyval("up") and
            fgl_lastkey() <> fgl_keyval("left") then

            call cts17m07_problema
                 ("", "",9, "", am_tela[l_arr].socntzcod, "","","", "","" )
                 returning l_status, l_mensagem, am_tela[l_arr].c24pbmcod,
                           l_c24pbmdes

            if l_status <> 1 then
               error l_mensagem
               next field c24pbmcod
            end if

            let l_c24pbmgrpcod  = null
            call cts12g01_grupo_problema
                 (am_tela[l_arr].socntzcod, "","","")
                 returning l_coderro, l_msgerro,
                           l_c24pbmgrpcod

            if l_coderro <> 1 then
               error l_msgerro
               next field c24pbmcod
            end if

            if  am_tela[l_arr].c24pbmcod <> 999  then
                call ctc48m01(l_c24pbmgrpcod,"ctg7")
                     returning am_tela[l_arr].c24pbmcod,
                               lr_aux.atddfttxt

                let am_tela[l_arr].c24pbmdes = lr_aux.atddfttxt
            end if

            if am_tela[l_arr].c24pbmcod is null then
               error 'Informe o codigo do problema'
               next field c24pbmcod
            else
               display am_tela[l_arr].c24pbmcod to s_cts41m00[l_tela].c24pbmcod
               display am_tela[l_arr].c24pbmdes to s_cts41m00[l_tela].c24pbmdes
            end if

         end if

      before field c24pbmdes
         if not l_insere then
            next field atdetpcod
         end if

         display am_tela[l_arr].c24pbmdes to s_cts41m00[l_tela].c24pbmdes attribute(reverse)

      after field c24pbmdes
         display am_tela[l_arr].c24pbmdes to s_cts41m00[l_tela].c24pbmdes

         if fgl_lastkey() <> fgl_keyval("up") and
            fgl_lastkey() <> fgl_keyval("left") then

            if am_tela[l_arr].c24pbmdes is null or
               am_tela[l_arr].c24pbmdes = ' '   then
               error 'Infome a descricao do problema'
               next field c24pbmdes
            end if

            if l_insere then

               call cts41m00_incluir(l_arr)
                    returning l_msg
                             ,a_servico[l_arr].atdsrvnum
                             ,a_servico[l_arr].atdsrvano
                             ,am_tela[l_arr].atdetpcod
                             ,am_tela[l_arr].atdetpdes

                if l_msg is not null then
                   error l_msg
                   next field socntzcod
                end if

                let am_tela[l_arr].servico = a_servico[l_arr].atdsrvnum
                                          using "#######","-",
                                          a_servico[l_arr].atdsrvano using "&&"

                display am_tela[l_arr].servico to s_cts41m00[l_tela].servico

                let l_insere = false
                next field atdetpcod
            end if
         end if

      before field atdetpcod
         let l_etapa_ant = am_tela[l_arr].atdetpcod

         call cts10g05_desc_etapa(3, am_tela[l_arr].atdetpcod)
              returning l_coderro
                       ,am_tela[l_arr].atdetpdes

         display am_tela[l_arr].atdetpcod  to s_cts41m00[l_tela].atdetpcod  attribute(reverse)
         display am_tela[l_arr].atdetpdes  to s_cts41m00[l_tela].atdetpdes

      after field atdetpcod
         display am_tela[l_arr].atdetpcod  to s_cts41m00[l_tela].atdetpcod

         if fgl_lastkey() <> fgl_keyval("up") and
            fgl_lastkey() <> fgl_keyval("left") then

            if  am_tela[l_arr].atdetpcod <> l_etapa_ant or
                am_tela[l_arr].atdetpcod is null or
                am_tela[l_arr].atdetpcod = ' ' then

                call cts41m00_acionar(a_servico[l_arr].atdsrvnum
                                     ,a_servico[l_arr].atdsrvano
                                     ,l_arr, 1)

                call cts10g04_ultima_etapa(a_servico[l_arr].atdsrvnum,
                                           a_servico[l_arr].atdsrvano)
                     returning am_tela[l_arr].atdetpcod

                call cts10g05_desc_etapa(3, am_tela[l_arr].atdetpcod)
                     returning l_erro
                              ,am_tela[l_arr].atdetpdes

                if fgl_lastkey() <> fgl_keyval('insert') then
                   if l_arr = arr_count() then
                      next field orcvlr
                   end if
                end if

            end if

            display am_tela[l_arr].atdetpdes to s_cts41m00[l_tela].atdetpdes
            display am_tela[l_arr].atdetpcod to s_cts41m00[l_tela].atdetpcod

         end if

      before field orcvlr
         if am_tela[l_arr].orcvlr is null then
            let am_tela[l_arr].orcvlr = 0
         end if

         let l_orcvlr_ant = am_tela[l_arr].orcvlr
         display am_tela[l_arr].orcvlr  to
                 s_cts41m00[l_tela].orcvlr  attribute(reverse)

      after field orcvlr
         display am_tela[l_arr].orcvlr  to s_cts41m00[l_tela].orcvlr

         if fgl_lastkey() <> fgl_keyval("up") and
            fgl_lastkey() <> fgl_keyval("left") then

            if l_insere = false then

               if  am_tela[l_arr].atdetpcod <> 1 then

                   if am_tela[l_arr].orcvlr is null or
                      am_tela[l_arr].orcvlr < 0     then
                      error 'Valor Invalido'
                      next field orcvlr
                   end if

                   call ctd09g00_sel_orc(1
                                        ,a_servico[l_arr].atdsrvnum
                                        ,a_servico[l_arr].atdsrvano)
                      returning l_coderro
                               ,l_msgerro
                               ,l_orcvlr

                   if l_coderro = 1 then
                      call ctd09g00_alt_orc(1
                                           ,a_servico[l_arr].atdsrvnum
                                           ,a_servico[l_arr].atdsrvano
                                           ,am_tela[l_arr].orcvlr, 0
                                           ,today, today)
                         returning l_coderro ,l_msgerro
                   else
                      if l_coderro = 2 then

                         call ctd09g00_inc_orc(a_servico[l_arr].atdsrvnum
                                              ,a_servico[l_arr].atdsrvano
                                              ,am_tela[l_arr].socntzcod
                                              ,lr_param.data
                                              ,am_tela[l_arr].orcvlr
                                              ,lr_param.data
                                              ,0)
                              returning l_coderro ,l_msgerro

                      end if
                   end if

                   if l_coderro <> 1 then
                      error l_msgerro
                      next field orcvlr
                   end if

                   if am_tela[l_arr].orcvlr > 0 and
                      am_tela[l_arr].atdetpcod = 7 then

                      let am_tela[l_arr].atdetpcod = 48

                      call cts10g04_insere_etapa(a_servico[l_arr].atdsrvnum
                                                ,a_servico[l_arr].atdsrvano
                                                ,am_tela[l_arr].atdetpcod
                                                ,'','','','')
                           returning l_coderro

                      call cts10g05_desc_etapa(3, am_tela[l_arr].atdetpcod)
                           returning l_coderro
                                    ,am_tela[l_arr].atdetpdes

                      display am_tela[l_arr].atdetpcod to
                              s_cts41m00[l_tela].atdetpcod

                      display am_tela[l_arr].atdetpdes to
                              s_cts41m00[l_tela].atdetpdes
                  end if
               else
                   if am_tela[l_arr].orcvlr > 0 then
                      let am_tela[l_arr].orcvlr = 0
                      display am_tela[l_arr].orcvlr to s_cts41m00[l_tela].orcvlr
                      error 'Valor deve ser preenchido apenas para etapas superior a 1(LIBERADO)'
                      next field atdetpcod
                   end if
               end if

               display am_tela[l_arr].orcvlr  to s_cts41m00[l_tela].orcvlr

            end if

            let mr_tela.orcvlrtot = 0
            for l_i = 1 to arr_count()
               if am_tela[l_i].orcvlr is not null then
                 let mr_tela.orcvlrtot = mr_tela.orcvlrtot + am_tela[l_i].orcvlr
               end if
            end for
            display mr_tela.orcvlrtot   to orcvlrtot

            if fgl_lastkey() = fgl_keyval("up") or
               fgl_lastkey() = fgl_keyval("left") then
               if l_insere then
                  next field c24pbmcod
               end if
            end if

            if am_tela[l_arr+1].orcvlr is null then
               next field orcvlr
            end if
         end if

      on key (f2)
         let l_arr  = arr_curr()
         let l_tela = scr_line()

         #if am_tela[l_arr].atdetpcod = 01 then

            let a_servico[l_arr].atdsrvnum = am_tela[l_arr].servico[1,7]
            let a_servico[l_arr].atdsrvano = am_tela[l_arr].servico[9,10]

            call cts41m00_canc(a_servico[l_arr].atdsrvnum
                              ,a_servico[l_arr].atdsrvano
                              ,am_tela[l_arr].atdetpcod)
               returning am_tela[l_arr].atdetpcod
                        ,am_tela[l_arr].atdetpdes

            if am_tela[l_arr].atdetpcod is not null then
               display am_tela[l_arr].atdetpcod to s_cts41m00[l_tela].atdetpcod
               display am_tela[l_arr].atdetpdes to s_cts41m00[l_tela].atdetpdes
            end if

      on key (f5)
         let l_arr  = arr_curr()
         call ctd09g00_con_nr_atz(a_servico[l_arr].atdsrvnum
                                 ,a_servico[l_arr].atdsrvano)

      on key (f6)
         let l_arr  = arr_curr()
         call cts40g03_data_hora_banco(2)
            returning m_data
                     ,m_hora

         call cts10n00(a_servico[l_arr].atdsrvnum
                      ,a_servico[l_arr].atdsrvano
                      ,g_issk.funmat
                      ,m_data
                      ,m_hora)

      on key (f7)
         let l_arr  = arr_curr()
         call ctr03m02(a_servico[l_arr].atdsrvnum
                      ,a_servico[l_arr].atdsrvano)

      on key (f8)
         let l_arr  = arr_curr()
         call cts41m00_agendar(a_servico[l_arr].atdsrvnum
                              ,a_servico[l_arr].atdsrvano)

      on key (f9)
         let l_arr   = arr_curr()
         let l_count = arr_count()
         let l_scr   = scr_line()

         call cts41m00_acionar(a_servico[l_arr].atdsrvnum
                              ,a_servico[l_arr].atdsrvano
                              ,l_arr, l_count)

         next field atdetpcod

      on key (f10)
         let l_arr = arr_curr()
         let l_count = arr_count()

         open window w_cts41m00a at 04,02 with 04 rows, 78 columns

         call cts00m11(a_servico[l_arr].atdsrvnum
                      ,a_servico[l_arr].atdsrvano)

         close window w_cts41m00a
         let int_flag = false

      on key (control-c, f17, interrupt)
         call cts40g03_data_hora_banco(2) returning m_data ,m_hora

         call cts10n00(lr_param.atdsrvnum
                      ,lr_param.atdsrvano
                      ,g_issk.funmat ,m_data ,m_hora)
         let int_flag = true
         exit input

   end input

end function

#------------------------------#
function cts41m00_incluir(l_pos)
#------------------------------#
   define l_pos smallint

   define lr_aux record
      lignum    like datmligacao.lignum
     ,atdsrvnum like datmservico.atdsrvnum
     ,atdsrvano like datmservico.atdsrvano
     ,cod       integer
     ,data      date
     ,hora      datetime hour to minute
     ,nmetab    char(30)
   end record

   define lr_retorno record
      msg       char(100)
     ,atdsrvnum like datmservico.atdsrvnum
     ,atdsrvano like datmservico.atdsrvano
     ,cod       smallint
     ,atdetpdes like datketapa.atdetpdes
   end record

   define l_ok  smallint

   let l_ok = true

   initialize lr_retorno.*, lr_aux.* to null

   #------------------------------------------------------------------------------
   # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia
   #------------------------------------------------------------------------------

   if g_documento.lclocodesres = "S" then
      let mr_cts10g06.atdrsdflg = "S"
   else
      let mr_cts10g06.atdrsdflg = "N"
   end if


   begin work

   call cts10g03_numeracao(2,9)
      returning lr_aux.lignum
               ,lr_aux.atdsrvnum
               ,lr_aux.atdsrvano
               ,lr_aux.cod
               ,lr_retorno.msg

   if lr_aux.cod <> 0 then
      let lr_retorno.msg = 'cts41m00 - ', lr_retorno.msg
      call ctx13g00(lr_aux.cod, 'DATKGERAL', lr_retorno.msg)
      let l_ok = false
   end if

   if l_ok then
      ## Gravar ligacao

      call cts40g03_data_hora_banco(2)
         returning lr_aux.data
                  ,lr_aux.hora

      let g_documento.cgccpfnum = mr_aux.cgccpfnum
      let g_documento.cgcord    = mr_aux.cgcord
      let g_documento.cgccpfdig = mr_aux.cgccpfdig

      call cts10g00_ligacao(lr_aux.lignum
                           ,lr_aux.data
                           ,lr_aux.hora
                           ,mr_ctd06g00.c24soltipcod
                           ,mr_ctd06g00.c24solnom
                           ,mr_ctd06g00.c24astcod
                           ,g_issk.funmat
                           ,mr_ctd06g00.ligcvntip
                           ,0
                           ,lr_aux.atdsrvnum
                           ,lr_aux.atdsrvano
                           ,'','','','',''
                           ,'','','','',''
                           ,'','','','',''
                           ,'','','','',''
                           ,'')
         returning lr_aux.nmetab
                  ,lr_aux.cod

      if lr_aux.cod <> 0 then
         let lr_retorno.msg = 'Erro ', lr_aux.cod ,' na tabela ', lr_aux.nmetab clipped, ' AVISE A INFORMATICA.'
         let l_ok = false
      end if
   end if

   if l_ok then
      ## Gravar servico

      call cts10g02_grava_servico(lr_aux.atdsrvnum
                                 ,lr_aux.atdsrvano
                                 ,mr_ctd06g00.c24soltip
                                 ,mr_ctd06g00.c24solnom
                                 ,''
                                 ,g_issk.funmat
                                 ,'S'
                                 ,lr_aux.data
                                 ,lr_aux.hora
                                 ,lr_aux.data
                                 ,lr_aux.hora
                                 ,''
                                 ,mr_cts10g06.atdhorpvt
                                 ,mr_cts10g06.atddatprg
                                 ,mr_cts10g06.atdhorprg
                                 ,9
                                 ,'','','',''
                                 ,'N'
                                 ,lr_aux.hora
                                 ,mr_cts10g06.atdrsdflg
                                 ,am_tela[l_pos].c24pbmdes
                                 ,''
                                 ,g_issk.funmat
                                 ,mr_tela.nom
                                 ,'','','','','','','',''
                                 ,'N'
                                 ,''
                                 ,mr_cts10g06.asitipcod
                                 ,'',''
                                 ,'N'
                                 ,''
                                 ,1
                                 ,9)
         returning lr_aux.nmetab
                  ,lr_aux.cod

      if lr_aux.cod <> 0 then
         let lr_retorno.msg = 'Erro ', lr_aux.cod ,' na tabela ', lr_aux.nmetab clipped, ' AVISE A INFORMATICA.'
         let l_ok = false
      end if
   end if

   if l_ok then
      ## Gravar o problema

      call ctx09g02_inclui(lr_aux.atdsrvnum
                          ,lr_aux.atdsrvano
                          ,1
                          ,am_tela[l_pos].c24pbmcod
                          ,am_tela[l_pos].c24pbmdes
                          ,'')
         returning lr_aux.nmetab
                  ,lr_aux.cod

      if lr_aux.cod <> 0 then
         let lr_retorno.msg = 'Erro ', lr_aux.cod ,' na tabela ', lr_aux.nmetab clipped, ' AVISE A INFORMATICA.'
         let l_ok = false
      end if
   end if

   if l_ok then
      ## Gravar o local (endereco)

      let mr_ctx04g00.lclbrrnom = m_subbairro[1].lclbrrnom

      let lr_aux.cod = cts06g07_local('I'
                                     ,lr_aux.atdsrvnum
                                     ,lr_aux.atdsrvano
                                     ,1
                                     ,mr_ctx04g00.lclidttxt
                                     ,mr_ctx04g00.lgdtip
                                     ,mr_ctx04g00.lgdnom
                                     ,mr_ctx04g00.lgdnum
                                     ,mr_ctx04g00.lclbrrnom
                                     ,mr_ctx04g00.brrnom
                                     ,mr_ctx04g00.cidnom
                                     ,mr_ctx04g00.ufdcod
                                     ,mr_ctx04g00.lclrefptotxt
                                     ,mr_ctx04g00.endzon
                                     ,mr_ctx04g00.lgdcep
                                     ,mr_ctx04g00.lgdcepcmp
                                     ,mr_ctx04g00.lclltt
                                     ,mr_ctx04g00.lcllgt
                                     ,mr_ctx04g00.dddcod
                                     ,mr_ctx04g00.lcltelnum
                                     ,mr_ctx04g00.lclcttnom
                                     ,mr_ctx04g00.c24lclpdrcod
                                     ,''
                                     ,mr_ctx04g00.emeviacod
                                     ,mr_ctx04g00.celteldddcod
                                     ,mr_ctx04g00.celtelnum
                                     ,mr_ctx04g00.endcmp)

      if lr_aux.cod <> 0 then
         let lr_retorno.msg = "Erro ", lr_aux.cod, " na inclusao do local"
         let l_ok = false
      end if
   end if

   if l_ok then
      ## Gravar etapa do servico

      let lr_aux.cod = cts10g04_insere_etapa(lr_aux.atdsrvnum
                                            ,lr_aux.atdsrvano
                                            ,1
                                            ,''
                                            ,''
                                            ,''
                                            ,'')

      if lr_aux.cod <> 0 then
         let lr_retorno.msg = 'Erro ', lr_aux.cod ,' na tabela gravacao da etapa. AVISE A INFORMATICA.'
         let l_ok = false
      end if
   end if

   if l_ok then
      ## Gravar servico de RE

      call ctd07g04_insere_srvre(lr_aux.atdsrvnum
                                ,lr_aux.atdsrvano, ''
                                ,lr_aux.data ,lr_aux.hora
                                ,''
                                ,am_tela[l_pos].socntzcod
                                ,'N' ,'','','','','',''
                                ,'' ---> lclnumseq
                                ,'')---> rmerscseq
         returning lr_aux.cod
                  ,lr_retorno.msg

      if lr_aux.cod <> 1 then
         let l_ok = false
      end if
   end if

   if l_ok then
      ## Gravar servico multiplo

      call ctd07g06_insere_mlt(m_atdsrvnum
                              ,m_atdsrvano
                              ,lr_aux.atdsrvnum
                              ,lr_aux.atdsrvano)
           returning lr_aux.cod
                    ,lr_retorno.msg

      if lr_aux.cod <> 1 then
         let l_ok = false
      end if
   end if

   if l_ok then
      #call cts10n00(lr_aux.atdsrvnum
      #             ,lr_aux.atdsrvano
      #             ,g_issk.funmat
      #             ,lr_aux.data
      #             ,lr_aux.hora)

      call cts10g05_desc_etapa(3,1)
         returning lr_aux.cod
                  ,lr_retorno.atdetpdes

      let lr_retorno.msg = null
      let lr_retorno.atdsrvnum = lr_aux.atdsrvnum
      let lr_retorno.atdsrvano = lr_aux.atdsrvano

      commit work
      # Ponto de acesso apos a gravacao do laudo
      call cts00g07_apos_grvlaudo(lr_aux.atdsrvnum,
                                  lr_aux.atdsrvano)

   else
      let lr_retorno.atdsrvnum = null
      let lr_retorno.atdsrvano = null
      let lr_retorno.atdetpdes = null

      rollback work
   end if

   return lr_retorno.msg
         ,lr_retorno.atdsrvnum
         ,lr_retorno.atdsrvano
         ,1
         ,lr_retorno.atdetpdes

end function

#-----------------------------------------
function cts41m00_canc(lr_param)
#-----------------------------------------
   define lr_param record
      atdsrvnum like datmservico.atdsrvnum
     ,atdsrvano like datmservico.atdsrvano
     ,atdetpcod like datketapa.atdetpcod
   end record

   define l_erro      smallint
         ,l_msg       char(40)
         ,l_atdetpdes like datketapa.atdetpdes

   let l_erro      = null
   let l_msg       = null
   let l_atdetpdes = null

   if lr_param.atdetpcod = 1 then
      let l_erro = cts10g04_insere_etapa(lr_param.atdsrvnum
                                        ,lr_param.atdsrvano
                                        ,5 ,'', '', '', '')

      if l_erro <> 0 then
         error 'Erro no cancelamento do servico'
      else

         call cts29g00_remover_multiplo (lr_param.atdsrvnum
                                        ,lr_param.atdsrvano)
              returning l_erro ,l_msg

         call cts10g09_finaliza_srv(lr_param.atdsrvnum
                                   ,lr_param.atdsrvano, "S")
              returning l_erro ,l_msg

         call cts10g05_desc_etapa(3, 5)
              returning l_erro ,l_atdetpdes
      end if
   else
      error 'Servico acionado, cancele com F9'
   end if

   return 5
         ,l_atdetpdes

end function

#---------------------------------#
function cts41m00_agendar(lr_param)
#---------------------------------#
   define lr_param record
          atdsrvnum like datmservico.atdsrvnum
         ,atdsrvano like datmservico.atdsrvano
   end record

   define l_coderro    smallint
         ,l_msgerro    char(40)
         ,l_imdflg     char(1)

   define lr_cts02m03 record
       atdhorpvt      like datmservico.atdhorpvt
      ,atddatprg      like datmservico.atddatprg
      ,atdhorprg      like datmservico.atdhorprg
      ,atdpvtretflg   like datmservico.atdpvtretflg
   end record

   initialize lr_cts02m03  to null

   let l_coderro = 0
   let l_msgerro = null
   let l_imdflg = null

   call cts10g06_dados_servicos(13
                               ,lr_param.atdsrvnum
                               ,lr_param.atdsrvano)
      returning l_coderro
               ,l_msgerro
               ,mr_cts10g06.atdfnlflg
               ,mr_cts10g06.atdhorpvt
               ,mr_cts10g06.atddatprg
               ,mr_cts10g06.atdhorprg
               ,mr_cts10g06.atdpvtretflg

   let l_imdflg = "S"
   if mr_cts10g06.atddatprg is not null then
      let l_imdflg = "N"
   end if

   call cts02m03(mr_cts10g06.atdfnlflg
                ,l_imdflg
                ,mr_cts10g06.atdhorpvt
                ,mr_cts10g06.atddatprg
                ,mr_cts10g06.atdhorprg
                ,mr_cts10g06.atdpvtretflg)
      returning lr_cts02m03.atdhorpvt
               ,lr_cts02m03.atddatprg
               ,lr_cts02m03.atdhorprg
               ,lr_cts02m03.atdpvtretflg

   if mr_cts10g06.atdfnlflg <> 'S' then
      call ctd07g00_alt_agend(lr_param.atdsrvnum
                             ,lr_param.atdsrvano
                             ,lr_cts02m03.atdhorpvt
                             ,lr_cts02m03.atddatprg
                             ,lr_cts02m03.atdhorprg
                             ,lr_cts02m03.atdpvtretflg)
         returning l_coderro
                  ,l_msgerro

      if l_coderro <> 1 then
         error l_msgerro
      end if
   end if

end function

#--------------------------------------------
function cts41m00_acionar(lr_param, l_pos, l_count)
#--------------------------------------------
   define lr_param record
      atdsrvnum     like datmservico.atdsrvnum
     ,atdsrvano     like datmservico.atdsrvano
   end record

   define l_resp      char(1)
         ,l_pos       smallint
         ,l_erro      smallint
         ,l_count     smallint
         ,l_i         smallint

   let l_resp = null
   let l_erro = null

   call cts00m02(lr_param.atdsrvnum ,lr_param.atdsrvano ,0)

   for l_pos = 1 to 11

       if a_servico[l_pos].atdsrvnum is not null then

          let am_tela[l_pos].atdetpcod =
              cts10g04_ultima_etapa(a_servico[l_pos].atdsrvnum
                                   ,a_servico[l_pos].atdsrvano)

          call cts10g05_desc_etapa(3, am_tela[l_pos].atdetpcod)
             returning l_erro
                      ,am_tela[l_pos].atdetpdes

          if l_pos <= 4 then
             display am_tela[l_pos].atdetpcod to s_cts41m00[l_pos].atdetpcod
             display am_tela[l_pos].atdetpdes to s_cts41m00[l_pos].atdetpdes
          end if

       end if

   end for

end function

#-------------------------------------#
function cts41m00_array(lr_param)
#-------------------------------------#
   define lr_param record
      atdsrvnum like datmservico.atdsrvnum
     ,atdsrvano like datmservico.atdsrvano
   end record

   define l_coderro  smallint
         ,l_msgerro  char(100)

   define l_espcod       like datmsrvre.espcod
         ,l_socntzdes    like datksocntz.socntzdes
         ,l_c24pbmcod    like datrsrvpbm.c24pbmcod
         ,l_c24pbmdes    like datrsrvpbm.c24pbmdes
         ,l_orcvlr       like datmsrvorc.orcvlr
         ,l_atdetpcod    like datmsrvacp.atdetpcod
         ,l_atdetpdes    like datketapa.atdetpdes

   let l_espcod       = null
   let l_socntzdes    = null
   let l_c24pbmcod    = null
   let l_c24pbmdes    = null
   let l_orcvlr       = null
   let l_atdetpcod    = null
   let l_atdetpdes    = null
   let l_coderro      = 0
   let l_msgerro      = null

   let m_nro_reg = m_nro_reg + 1

   let am_tela[m_nro_reg].servico = lr_param.atdsrvnum using "#######","-",
                                    lr_param.atdsrvano using "&&"

   let a_servico[m_nro_reg].atdsrvnum = lr_param.atdsrvnum
   let a_servico[m_nro_reg].atdsrvano = lr_param.atdsrvano

   call cts26g00_obter_natureza(lr_param.atdsrvnum
                               ,lr_param.atdsrvano)
      returning l_coderro, l_msgerro,
                am_tela[m_nro_reg].socntzcod ,l_espcod

   call ctc16m03_inf_natureza(am_tela[m_nro_reg].socntzcod, 'A')
      returning l_coderro, l_msgerro,
                am_tela[m_nro_reg].socntzdes ,m_socntzgrpcod

   call ctx09g02_seleciona(1
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano)
      returning l_coderro
               ,l_msgerro
               ,am_tela[m_nro_reg].c24pbmcod
               ,am_tela[m_nro_reg].c24pbmdes

   call ctd09g00_sel_orc(1
                        ,lr_param.atdsrvnum
                        ,lr_param.atdsrvano)
      returning l_coderro
               ,l_msgerro
               ,am_tela[m_nro_reg].orcvlr

   if am_tela[m_nro_reg].orcvlr is null then
      let am_tela[m_nro_reg].orcvlr = 0
   end if

   let am_tela[m_nro_reg].atdetpcod = cts10g04_ultima_etapa(lr_param.atdsrvnum
                                                           ,lr_param.atdsrvano)

   call cts10g05_desc_etapa(3, am_tela[m_nro_reg].atdetpcod)
      returning l_coderro
               ,am_tela[m_nro_reg].atdetpdes

end function

#------------------------#
function cts41m00_mostra()
#------------------------#
   define l_i smallint

   let mr_tela.orcvlrtot = 0

   display by name mr_cts10g06.c24solnom
   display m_hora to hora
   display by name mr_tela.nom
   display by name mr_tela.cgccpf
   display by name mr_tela.endereco
   display by name mr_tela.brrnom
   display by name mr_tela.cidnom
   display by name mr_tela.ufdcod
   display by name mr_tela.lclrefptotxt
   display by name mr_tela.endzon
   display by name mr_tela.dddcod
   display by name mr_tela.lcltelnum
   display by name mr_tela.lclcttnom
   display by name mr_tela.asitipabvdes
   display by name mr_tela.atdlibflg
   display by name mr_tela.prslocflg
   display by name mr_tela.atendlib

   for l_i = 1 to 11
      if l_i <= 4 then
         display am_tela[l_i].* to s_cts41m00[l_i].*
      end if

      if am_tela[l_i].orcvlr is not null then
         let mr_tela.orcvlrtot = mr_tela.orcvlrtot + am_tela[l_i].orcvlr
      end if
   end for

   if mr_tela.orcvlrtot = 0 then
      let mr_tela.orcvlrtot = null
   end if

   display by name mr_tela.orcvlrtot

end function
