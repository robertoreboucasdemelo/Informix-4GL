#---------------------------------------------------------------------    #
# Porto Seguro Cia Seguros Gerais                                         #
# ....................................................................    #
# Sistema       : Central 24h                                             #
# Modulo        : cts17m03                                                #
# Analista Resp.: Ligia Mattge                                            #
# PSI           : 188239                                                  #
# Objetivo      : Abertura de Laudo Multiplo                              #
#.....................................................................    #
# Desenvolvimento: Mariana , META                                         #
# Liberacao      : 30/11/2004                                             #
#.....................................................................    #
#                                                                         #
#                  * * * Alteracoes * * *                                 #
#                                                                         #
# Data        Autor Fabrica  Origem    Alteracao                          #
# ----------  -------------- --------- ------------------------------     #
# 24/01/2005  Robson, Meta   PSI190080 Alterar  a  chamada  da  funcao    #
#                                      cts17m05_qtd_servicos() para       #
#                                      cty05g02_serv_residencia().        #
# ----------  -------------- --------- ------------------------------     #
# 21/10/2005  Priscila       PSI195138 Inclusao de especialidade no       #
#                                      laudo  multiplo                    #
# 25/09/06   Ligia Mattge  PSI 202720 Implementando grupo/cartao saude    #
#                                                                         #
# 01/10/2008 Amilton,Meta   PSI 223689  Incluir tratamento de erro com    #
#                                       global ( Isolamento U01 )         #
#-------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853      Implementacao do PSS          #
#-------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/framg001.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689


define m_prepare            smallint
     , m_ind                smallint

define m_atdmltsrvnum     like datratdmltsrv.atdmltsrvnum
      ,m_atdmltsrvano     like datratdmltsrv.atdmltsrvano

#-------------------------#
function cts17m03_prepare()
#-------------------------#

define l_comando          char(500)

   let l_comando = "select c24funmat, c24srvdsc, ligdat, "
                  ,"       lighorinc, c24empcod, c24usrtip,c24txtseq  "
                  ,"  from datmservhist  "
                  ," where atdsrvnum = ? "
                  ,"   and atdsrvano = ? "
                  ," order by c24txtseq  "

   prepare p_cts17m03_001 from l_comando
   declare c_cts17m03_001 cursor for p_cts17m03_001
   let l_comando = "select atdmltsrvnum, atdmltsrvano "
                  ,"  from datratdmltsrv  "
                  ," where atdsrvnum  = ? "
                  ,"   and atdsrvano  = ? "

   prepare pcts17m03002 from l_comando
   declare ccts17m03002 cursor with hold for pcts17m03002


   let m_prepare = true
end function

#----------------------------------------------------#
function cts17m03_laudo_multiplo(lr_param, lr_array)
#----------------------------------------------------#
define lr_param                   record
       ramcod                     like datrservapol.ramcod
      ,succod                     like datrservapol.succod
      ,aplnumdig                  like datrservapol.aplnumdig
      ,itmnumdig                  like datrservapol.itmnumdig
      ,c24astcod                  like datmligacao.c24astcod
      ,cls_natureza               char(03)
      ,cls_apolice                char(03)
      ,rmemdlcod                  like datrsocntzsrvre.rmemdlcod
      ,prporg                     like datrligprp.prporg
      ,prpnumdig                  like datrligprp.prpnumdig
      ,socntzcod                  like datmsrvre.socntzcod
      ,socntzgrpcod               like datksocntz.socntzgrpcod
      ,bnfnum                     like datrligsau.crtnum
      ,crtsaunum                  like datksegsau.crtsaunum
                                  end record
define lr_array                   record              #--> Array recebido como parametro
       socntzcod_1                like datmsrvre.socntzcod
      ,socntzdes_1                like datksocntz.socntzdes
      ,espcod_1                   like datmsrvre.espcod    #PSI 195138
      ,espdes_1                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_1                like datkpbm.c24pbmcod
      ,atddfttxt_1                like datmservico.atddfttxt
      ,socntzcod_2                like datmsrvre.socntzcod
      ,socntzdes_2                like datksocntz.socntzdes
      ,espcod_2                   like datmsrvre.espcod    #PSI 195138
      ,espdes_2                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_2                like datkpbm.c24pbmcod
      ,atddfttxt_2                like datmservico.atddfttxt
      ,socntzcod_3                like datmsrvre.socntzcod
      ,socntzdes_3                like datksocntz.socntzdes
      ,espcod_3                   like datmsrvre.espcod    #PSI 195138
      ,espdes_3                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_3                like datkpbm.c24pbmcod
      ,atddfttxt_3                like datmservico.atddfttxt
      ,socntzcod_4                like datmsrvre.socntzcod
      ,socntzdes_4                like datksocntz.socntzdes
      ,espcod_4                   like datmsrvre.espcod    #PSI 195138
      ,espdes_4                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_4                like datkpbm.c24pbmcod
      ,atddfttxt_4                like datmservico.atddfttxt
      ,socntzcod_5                like datmsrvre.socntzcod
      ,socntzdes_5                like datksocntz.socntzdes
      ,espcod_5                   like datmsrvre.espcod    #PSI 195138
      ,espdes_5                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_5                like datkpbm.c24pbmcod
      ,atddfttxt_5                like datmservico.atddfttxt
      ,socntzcod_6                like datmsrvre.socntzcod
      ,socntzdes_6                like datksocntz.socntzdes
      ,espcod_6                   like datmsrvre.espcod    #PSI 195138
      ,espdes_6                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_6                like datkpbm.c24pbmcod
      ,atddfttxt_6                like datmservico.atddfttxt
      ,socntzcod_7                like datmsrvre.socntzcod
      ,socntzdes_7                like datksocntz.socntzdes
      ,espcod_7                   like datmsrvre.espcod    #PSI 195138
      ,espdes_7                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_7                like datkpbm.c24pbmcod
      ,atddfttxt_7                like datmservico.atddfttxt
      ,socntzcod_8                like datmsrvre.socntzcod
      ,socntzdes_8                like datksocntz.socntzdes
      ,espcod_8                   like datmsrvre.espcod    #PSI 195138
      ,espdes_8                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_8                like datkpbm.c24pbmcod
      ,atddfttxt_8                like datmservico.atddfttxt
      ,socntzcod_9                like datmsrvre.socntzcod
      ,socntzdes_9                like datksocntz.socntzdes
      ,espcod_9                   like datmsrvre.espcod    #PSI 195138
      ,espdes_9                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_9                like datkpbm.c24pbmcod
      ,atddfttxt_9                like datmservico.atddfttxt
      ,socntzcod_10               like datmsrvre.socntzcod
      ,socntzdes_10               like datksocntz.socntzdes
      ,espcod_10                  like datmsrvre.espcod    #PSI 195138
      ,espdes_10                  like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_10               like datkpbm.c24pbmcod
      ,atddfttxt_10               like datmservico.atddfttxt
                                  end record
define al_cts17m03                array[10] of record          #---> Array de Tela
       socntzcod                  like datmsrvre.socntzcod
      ,socntzdes                  like datksocntz.socntzdes
      ,espcod                     like datmsrvre.espcod    #PSI 195138
      ,espdes                     like dbskesp.espdes      #PSI 195138
      ,c24pbmcod                  like datkpbm.c24pbmcod
      ,atddfttxt                  like datmservico.atddfttxt
      ,ghost                      char(01)
                                  end record

define al_param                   array[10] of record          #---> Array de retorno
       socntzcod                  like datmsrvre.socntzcod
      ,socntzdes                  like datksocntz.socntzdes
      ,espcod                     like datmsrvre.espcod    #PSI 195138
      ,espdes                     like dbskesp.espdes      #PSI 195138
      ,c24pbmcod                  like datkpbm.c24pbmcod
      ,atddfttxt                  like datmservico.atddfttxt
                                  end record

define l_socntzgrpcod             like datmsrvre.socntzcod
     , l_linha                    char(01)

define l_resultado                smallint
      ,l_mensagem                 char(80)
      ,l_retorno                  char(01)
      ,l_quantidade               integer
      ,l_data_calc                date
      ,l_saldo                    integer
      ,l_clscod                   char(05)
      ,l_scr                      smallint
      ,l_linha_acima              smallint
      ,l_calcula                  char(01)
      ,l_tem                      char(01)
      ,l_for                      smallint
      ,l_cont                     smallint
      ,l_arr                      smallint
      ,l_sai                      smallint
      ,l_qtd_util                 integer
      ,l_atddfttxt                like datmservico.atddfttxt
      ,l_socntzcod                like datmsrvre.socntzcod
      ,l_flag_limite              char(01)
      ,l_erro                     smallint
      ,l_consiste_pss             smallint
      ,l_cortesia                 smallint
      ,l_conta_corrente           smallint
      ,l_idx                      integer
      ,l_idx2                     integer
      ,l_socntzcod_atu            like datmsrvre.socntzcod
 define lr_ramo record
        resultado  integer,
        mensagem   char(500),
        ramgrpcod  like gtakram.ramgrpcod
 end record
 define l_index integer,
	l_flag  char(01),
	l_cls4448 smallint,
	l_passou  smallint     #CT853801
	
   let l_passou      = false
   let int_flag      = false
   let l_linha_acima = false
   let l_cls4448 = false
   let l_saldo = 0
   let l_erro  = null
   let l_consiste_pss = false
   let l_index = 0
   let l_conta_corrente = false
   let l_cortesia = false

   let l_flag_limite = null

   for l_idx  =  0  to  10
       initialize  al_cts17m03[l_idx].* to  null
   end for
   initialize lr_ramo.* to null
   if (lr_param.aplnumdig is not null                   and
      (lr_param.ramcod =  31 or lr_param.ramcod =  531)) or
      lr_param.bnfnum is not null then  ## PSI 202720

      call cty26g00_srv_caca(lr_param.ramcod
                            ,lr_param.succod
                            ,lr_param.aplnumdig
                            ,lr_param.itmnumdig
                            ,lr_param.c24astcod
                            ,lr_param.bnfnum
                            ,lr_param.crtsaunum
                            ,al_cts17m03[m_ind].socntzcod
                            , l_saldo)
                             returning l_flag_limite ,l_saldo, l_quantidade ,l_qtd_util ,l_cls4448

	    let l_saldo = l_qtd_util - l_quantidade #- 1
      if l_cls4448 = false then
           if cty31g00_nova_regra_clausula(lr_param.c24astcod) then
             if al_cts17m03[m_ind].socntzcod is null or
             	  al_cts17m03[m_ind].socntzcod = 0     then
             	   call cty31g00_valida_envio_residencia(lr_param.ramcod   ,
                                                       lr_param.succod    ,
                                                       lr_param.aplnumdig ,
                                                       lr_param.itmnumdig ,
                                                       lr_param.c24astcod ,
                                                       lr_param.bnfnum    ,
                                                       lr_param.crtsaunum ,
                                                       lr_param.socntzcod)
                returning  l_resultado
                          ,l_mensagem
                          ,l_flag_limite
                          ,l_quantidade
                          ,l_qtd_util
             else
             	  call cty31g00_valida_envio_residencia(lr_param.ramcod    ,
                                                      lr_param.succod    ,
                                                      lr_param.aplnumdig ,
                                                      lr_param.itmnumdig ,
                                                      lr_param.c24astcod ,
                                                      lr_param.bnfnum    ,
                                                      lr_param.crtsaunum ,
                                                      al_cts17m03[m_ind].socntzcod)
                returning  l_resultado
                          ,l_mensagem
                          ,l_flag_limite
                          ,l_quantidade
                          ,l_qtd_util
             end if
             let l_saldo = l_qtd_util - l_quantidade - 1
           else
           	 if cty34g00_valida_clausula(lr_param.cls_apolice) then
           	    if al_cts17m03[m_ind].socntzcod is null or
           	    	 al_cts17m03[m_ind].socntzcod = 0     then
                	   call cty34g00_valida_envio_residencia(lr_param.ramcod   ,
                                                          lr_param.succod    ,
                                                          lr_param.aplnumdig ,
                                                          lr_param.itmnumdig ,
                                                          lr_param.c24astcod ,
                                                          lr_param.bnfnum    ,
                                                          lr_param.crtsaunum ,
                                                          lr_param.socntzcod)
                     returning  l_resultado
                               ,l_mensagem
                               ,l_flag_limite
                               ,l_quantidade
                               ,l_qtd_util
                else
                	  call cty34g00_valida_envio_residencia(lr_param.ramcod    ,
                                                         lr_param.succod    ,
                                                         lr_param.aplnumdig ,
                                                         lr_param.itmnumdig ,
                                                         lr_param.c24astcod ,
                                                         lr_param.bnfnum    ,
                                                         lr_param.crtsaunum ,
                                                         al_cts17m03[m_ind].socntzcod)
                    returning  l_resultado
                              ,l_mensagem
                              ,l_flag_limite
                              ,l_quantidade
                              ,l_qtd_util
                end if
                let l_saldo = l_qtd_util - l_quantidade - 1
             else
                call cty05g02_serv_residencia(lr_param.ramcod
                                              ,lr_param.succod
                                              ,lr_param.aplnumdig
                                              ,lr_param.itmnumdig
                                              ,lr_param.c24astcod
                                              ,lr_param.bnfnum
                                              ,lr_param.crtsaunum)
                      returning l_resultado
                               ,l_mensagem
                               ,l_flag_limite
                               ,l_quantidade
                               ,l_qtd_util
                if l_resultado <> 1 then
                   error l_mensagem
                   initialize al_param to null
                   return al_param[1].*
                         ,al_param[2].*
                         ,al_param[3].*
                         ,al_param[4].*
                         ,al_param[5].*
                         ,al_param[6].*
                         ,al_param[7].*
                         ,al_param[8].*
                         ,al_param[9].*
                         ,al_param[10].*
                end if
                let l_saldo = l_qtd_util - l_quantidade - 1
             end if
           end if
      end if

      if l_saldo = 0 then
         let l_retorno = cts08g01("A","N","LIMITE EXCEDIDO" ,"CONSULTA A COORDENACAO"
                                 ,"PARA ENVIO DE ATENDIMENTO",'')
         initialize al_param to null
         return al_param[1].*
               ,al_param[2].*
               ,al_param[3].*
               ,al_param[4].*
               ,al_param[5].*
               ,al_param[6].*
               ,al_param[7].*
               ,al_param[8].*
               ,al_param[9].*
               ,al_param[10].*
     end if
   else
      if g_documento.ciaempcod = 43 and # PSS
         g_pss.psscntcod is not null then
         call cta00m26_verifica_saldo(lr_param.c24astcod)
         returning l_saldo     ,
                   l_resultado ,
                   l_erro
         if l_saldo is not null then
             if l_saldo = 0 then
                let l_retorno = cts08g01("A","N","LIMITE EXCEDIDO" ,"CONSULTA A COORDENACAO"
                                        ,"PARA ENVIO DE ATENDIMENTO",'')
                initialize al_param to null
                return al_param[1].*
                      ,al_param[2].*
                      ,al_param[3].*
                      ,al_param[4].*
                      ,al_param[5].*
                      ,al_param[6].*
                      ,al_param[7].*
                      ,al_param[8].*
                      ,al_param[9].*
                      ,al_param[10].*
             else
                let l_saldo = l_saldo - 1
                let l_consiste_pss = true
             end if
         else
            let l_saldo = 9999 # Nao tem limite
         end if
      else
         let l_saldo = 9999 ## RE nao tem limite
      end if
   end if
   if g_documento.ciaempcod = 84  then
       if g_documento.ramcod = 31 then
           if cts12g08_valida_data_vigencia(g_doc_itau[1].itaasiplncod   ,
           	                                g_doc_itau[1].itaclisgmcod   ,
                                            g_doc_itau[1].itaaplvigincdat) then
                call cts12g11_verifica_saldo(g_doc_itau[1].itaasiplncod   ,
                                             g_doc_itau[1].itaclisgmcod   ,
                                             g_doc_itau[1].itaaplvigincdat)
                returning l_saldo
                let l_saldo = l_saldo - 1
                if l_saldo = 0 then
                   let l_retorno = cts08g01("A","N","LIMITE EXCEDIDO" ,"CONSULTA A COORDENACAO"
                                           ,"PARA ENVIO DE ATENDIMENTO",'')
                   initialize al_param to null
                   return al_param[1].*
                         ,al_param[2].*
                         ,al_param[3].*
                         ,al_param[4].*
                         ,al_param[5].*
                         ,al_param[6].*
                         ,al_param[7].*
                         ,al_param[8].*
                         ,al_param[9].*
                         ,al_param[10].*
                end if
           else
           	    call cts12g04_recupera_saldo(g_doc_itau[1].itaasiplncod)
           	    returning l_saldo
           	    let l_saldo = l_saldo - 1
           	    if l_saldo = 0 then
           	       let l_retorno = cts08g01("A","N","LIMITE EXCEDIDO" ,"CONSULTA A COORDENACAO"
           	                               ,"PARA ENVIO DE ATENDIMENTO",'')
           	       initialize al_param to null
           	       return al_param[1].*
           	             ,al_param[2].*
           	             ,al_param[3].*
           	             ,al_param[4].*
           	             ,al_param[5].*
           	             ,al_param[6].*
           	             ,al_param[7].*
           	             ,al_param[8].*
           	             ,al_param[9].*
           	             ,al_param[10].*
           	    end if
           end if
      end if
   end if
   open window w_cts17m03 at 6,2 with form "cts17m03"
      attribute (message line last,form line 1, border)
      call cts17m03_verifica(lr_array.*)
           returning lr_array.*
      let al_cts17m03[1].socntzcod  = lr_array.socntzcod_1
      let al_cts17m03[2].socntzcod  = lr_array.socntzcod_2
      let al_cts17m03[3].socntzcod  = lr_array.socntzcod_3
      let al_cts17m03[4].socntzcod  = lr_array.socntzcod_4
      let al_cts17m03[5].socntzcod  = lr_array.socntzcod_5
      let al_cts17m03[6].socntzcod  = lr_array.socntzcod_6
      let al_cts17m03[7].socntzcod  = lr_array.socntzcod_7
      let al_cts17m03[8].socntzcod  = lr_array.socntzcod_8
      let al_cts17m03[9].socntzcod  = lr_array.socntzcod_9
      let al_cts17m03[10].socntzcod = lr_array.socntzcod_10
      let al_cts17m03[1].socntzdes  = lr_array.socntzdes_1
      let al_cts17m03[2].socntzdes  = lr_array.socntzdes_2
      let al_cts17m03[3].socntzdes  = lr_array.socntzdes_3
      let al_cts17m03[4].socntzdes  = lr_array.socntzdes_4
      let al_cts17m03[5].socntzdes  = lr_array.socntzdes_5
      let al_cts17m03[6].socntzdes  = lr_array.socntzdes_6
      let al_cts17m03[7].socntzdes  = lr_array.socntzdes_7
      let al_cts17m03[8].socntzdes  = lr_array.socntzdes_8
      let al_cts17m03[9].socntzdes  = lr_array.socntzdes_9
      let al_cts17m03[10].socntzdes = lr_array.socntzdes_10
      let al_cts17m03[1].espcod     = lr_array.espcod_1
      let al_cts17m03[2].espcod     = lr_array.espcod_2
      let al_cts17m03[3].espcod     = lr_array.espcod_3
      let al_cts17m03[4].espcod     = lr_array.espcod_4
      let al_cts17m03[5].espcod     = lr_array.espcod_5
      let al_cts17m03[6].espcod     = lr_array.espcod_6
      let al_cts17m03[7].espcod     = lr_array.espcod_7
      let al_cts17m03[8].espcod     = lr_array.espcod_8
      let al_cts17m03[9].espcod     = lr_array.espcod_9
      let al_cts17m03[10].espcod    = lr_array.espcod_10
      let al_cts17m03[1].espdes     = lr_array.espdes_1
      let al_cts17m03[2].espdes     = lr_array.espdes_2
      let al_cts17m03[3].espdes     = lr_array.espdes_3
      let al_cts17m03[4].espdes     = lr_array.espdes_4
      let al_cts17m03[5].espdes     = lr_array.espdes_5
      let al_cts17m03[6].espdes     = lr_array.espdes_6
      let al_cts17m03[7].espdes     = lr_array.espdes_7
      let al_cts17m03[8].espdes     = lr_array.espdes_8
      let al_cts17m03[9].espdes     = lr_array.espdes_9
      let al_cts17m03[10].espdes    = lr_array.espdes_10
      let al_cts17m03[1].c24pbmcod  = lr_array.c24pbmcod_1
      let al_cts17m03[2].c24pbmcod  = lr_array.c24pbmcod_2
      let al_cts17m03[3].c24pbmcod  = lr_array.c24pbmcod_3
      let al_cts17m03[4].c24pbmcod  = lr_array.c24pbmcod_4
      let al_cts17m03[5].c24pbmcod  = lr_array.c24pbmcod_5
      let al_cts17m03[6].c24pbmcod  = lr_array.c24pbmcod_6
      let al_cts17m03[7].c24pbmcod  = lr_array.c24pbmcod_7
      let al_cts17m03[8].c24pbmcod  = lr_array.c24pbmcod_8
      let al_cts17m03[9].c24pbmcod  = lr_array.c24pbmcod_9
      let al_cts17m03[10].c24pbmcod = lr_array.c24pbmcod_10
      let al_cts17m03[1].atddfttxt  = lr_array.atddfttxt_1
      let al_cts17m03[2].atddfttxt  = lr_array.atddfttxt_2
      let al_cts17m03[3].atddfttxt  = lr_array.atddfttxt_3
      let al_cts17m03[4].atddfttxt  = lr_array.atddfttxt_4
      let al_cts17m03[5].atddfttxt  = lr_array.atddfttxt_5
      let al_cts17m03[6].atddfttxt  = lr_array.atddfttxt_6
      let al_cts17m03[7].atddfttxt  = lr_array.atddfttxt_7
      let al_cts17m03[8].atddfttxt  = lr_array.atddfttxt_8
      let al_cts17m03[9].atddfttxt  = lr_array.atddfttxt_9
      let al_cts17m03[10].atddfttxt = lr_array.atddfttxt_10
      for l_for = 1 to 10
          if al_cts17m03[l_for].socntzcod  is not null and
             al_cts17m03[l_for].c24pbmcod  is not null then
             let l_saldo = l_saldo - 1
          end if
      end for

     display l_saldo to saldo
     let l_sai = 0

     options delete key f2

     while true
      call set_count(10)
      let l_calcula = "S"
      input array al_cts17m03 without defaults from s_cts17m03.*
         before row
           let m_ind     = arr_curr()
           let l_scr     = scr_line()

        before delete
           let m_ind     = arr_curr()
           if al_cts17m03[m_ind].socntzcod is null or
              al_cts17m03[m_ind].c24pbmcod is null then

              next field socntzcod
           else
              ## PSI 202720
              if (lr_param.ramcod = 31  or lr_param.ramcod = 531) or
                 (lr_param.bnfnum is not null)                    or
                 (l_consiste_pss  = true)                         then
                 let l_saldo = l_saldo + 1
                 display l_saldo to saldo
                 next field socntzcod
              end if
               if al_cts17m03[m_ind].socntzcod is not null then
                for l_index = 1 to g_naturezas_re.qtd_eve
                 if ga_framg001_serv[l_index].socntzcod = al_cts17m03[m_ind].socntzcod then
                    if ga_framg001_serv[l_index].atdqtd > 0 then
                       let ga_framg001_serv[l_index].ageatdqtd = ga_framg001_serv[l_index].ageatdqtd - 1
                       exit for
                    else
                       let g_saldo_re.saldo = g_saldo_re.saldo + g_saldo_re.utiliz
                       exit for
                    end if
                 end if
                end for
               end if
           end if
          after delete
                let l_calcula = "N"
          after row
              if fgl_lastkey() = fgl_keyval("up") or
                 fgl_lastkey() = fgl_keyval("left") then
                 let l_calcula = "N"
              else
                 let l_calcula = "S"
              end if

         before field socntzcod
           if al_cts17m03[m_ind].socntzcod is not null then
              let l_linha = 'P'
           else
              let l_linha = 'N'
           end if
           let l_socntzcod = al_cts17m03[m_ind].socntzcod
           display al_cts17m03[m_ind].socntzcod to s_cts17m03[m_ind].socntzcod
                   attribute(reverse)
         after field socntzcod
            display al_cts17m03[m_ind].socntzcod to s_cts17m03[m_ind].socntzcod
            if l_socntzcod is not null and
                  al_cts17m03[m_ind].socntzcod is null and
                  l_saldo = 0 then
                  let al_cts17m03[m_ind].c24pbmcod = null
                  let al_cts17m03[m_ind].atddfttxt  = null
                  let al_cts17m03[m_ind].socntzdes  = null
                  display al_cts17m03[m_ind].* to s_cts17m03[m_ind].*
                  let l_saldo = l_saldo + 1
                  let l_calcula = "S"
                  display l_saldo to saldo
               end if
               if g_documento.ciaempcod = 84  then
               	  if g_documento.ramcod = 31 then
               	  	  let l_socntzcod_atu = al_cts17m03[m_ind].socntzcod
               	      for l_idx2  =  0  to  10
                           if m_ind <> l_idx2 then
                           	  if l_socntzcod_atu = al_cts17m03[l_idx2].socntzcod then
                           	      error "Natureza ja Selecionada!"
                           	      next field socntzcod
                            	end if
                           end if
                      end for
               	      let l_saldo = l_saldo
               	       if l_saldo = 0 then
               	           let l_flag_limite = 'S'
               	       else
               	       	   let l_flag_limite = 'N'
               	       end if
               	  end if
               else

                  if cty31g00_nova_regra_clausula(lr_param.c24astcod) then
                     if l_saldo = 0 then
                         let l_flag_limite = 'S'
                     end if
                  else
                    if cty34g00_valida_clausula(lr_param.cls_apolice) then
                        if l_saldo = 0 then
                            let l_flag_limite = 'S'
                        end if
                    else
                        call cty26g00_srv_caca(lr_param.ramcod
		                              ,lr_param.succod
				                          ,lr_param.aplnumdig
				                          ,lr_param.itmnumdig
				                          ,lr_param.c24astcod
				                          ,lr_param.bnfnum
				                          ,lr_param.crtsaunum
				                          ,al_cts17m03[m_ind].socntzcod
				                          , l_saldo)
                             returning l_flag_limite ,l_saldo, l_quantidade ,l_qtd_util
		                                  ,l_cls4448
	                         let l_saldo = l_qtd_util - l_quantidade #- 1
	                  end if
	                end if
	             end if
            if fgl_lastkey() <> fgl_keyval("left") and
               fgl_lastkey() <> fgl_keyval("down") and
               fgl_lastkey() <> fgl_keyval("up") then

               if l_flag_limite = 'S' then

                  if (lr_param.ramcod = 31 or lr_param.ramcod = 531) or
                      (lr_param.bnfnum is not null)                  or
                      (l_consiste_pss  = true)                       then  ##PSI 202720

                     let l_retorno = cts08g01("A","N", "LIMITE EXCEDIDO"
                                      ,"CONSULTA A COORDENACAO"
                                      ,"PARA ENVIO DE ATENDIMENTO"
                                       ," " )
                     if al_cts17m03[m_ind].socntzcod is not null then
                        if l_linha <> 'P' then
                           let al_cts17m03[m_ind].socntzcod = null
                           display al_cts17m03[m_ind].socntzcod to s_cts17m03[m_ind].socntzcod
                        end if
                     end if
                     next field socntzcod
                  end if
               end if

               if al_cts17m03[m_ind].socntzcod is null then
                  if fgl_lastkey() <> fgl_keyval("up") and
                     fgl_lastkey() <> fgl_keyval("left") then

                     if g_documento.ciaempcod = 43 and # PSS - Condominio
                        g_documento.ligcvntip = 1  then

                         call cto00m08_natureza_pss(2,lr_param.c24astcod,
                                                      lr_param.socntzcod)
                         returning al_cts17m03[m_ind].socntzcod
                     else

                          if g_documento.ciaempcod = 84 then
	                       if g_documento.ramcod = 31 then
                                call cts61m00_assunto_cortesia()
                                      returning l_cortesia
                             else
                                call cts65m00_assunto_cortesia()
                                      returning l_cortesia
                             end if
                          end if

                          if g_documento.ciaempcod = 84 and
                               l_cortesia = false then
	                         if g_documento.ramcod = 31 then
                                  if cts12g08_valida_data_vigencia(g_doc_itau[1].itaasiplncod   ,
                                  	                               g_doc_itau[1].itaclisgmcod   ,
                                                                   g_doc_itau[1].itaaplvigincdat) then
                                       call cts12g11(g_doc_itau[1].itaasiplncod   ,
                                                     g_doc_itau[1].itaclisgmcod   ,
                                                     g_doc_itau[1].itaaplvigincdat)
                                       returning al_cts17m03[m_ind].socntzcod
                                       if lr_param.socntzcod = al_cts17m03[m_ind].socntzcod then
                                          error "Natureza ja Selecionada no Original!"
                                          next field socntzcod
                                       end if
                                  else
                                       call cts12g04(g_doc_itau[1].itaasiplncod)
                                            returning al_cts17m03[m_ind].socntzcod
                                       if lr_param.socntzcod = al_cts17m03[m_ind].socntzcod then
                                          error "Natureza ja Selecionada no Original!"
                                          next field socntzcod
                                       end if
                                  end if
                               else
                                  call cts12g05(g_doc_itau[1].itaasisrvcod,'S',lr_param.socntzcod)
                                       returning al_cts17m03[m_ind].socntzcod
                               end if
                          else
                              # Desvio para o conta corrente RE
                              let l_cortesia = false
                              call cta00m06_assunto_cort(g_documento.c24astcod)
                                   returning l_cortesia
                              call cty10g00_grupo_ramo(g_documento.ciaempcod
                                                      ,g_documento.ramcod)
                                    returning lr_ramo.*
                              call cta00m06_re_contacorrente()
                                   returning l_conta_corrente
                              if lr_ramo.ramgrpcod = 4               and
                                 l_cortesia = false                  and
                                 l_conta_corrente  = true            and
                                ( g_documento.aplnumdig is not null   or
                                 g_documento.crtsaunum is not null ) then
                                  let l_passou = false
                                  call cts12g99(g_documento.succod,
                                                g_documento.ramcod,
                                                g_documento.aplnumdig,
                                                g_documento.prporg,
                                                g_documento.prpnumdig,
                                                g_documento.lclnumseq,
                                                g_documento.rmerscseq,
                                                g_documento.c24astcod,
                                                lr_param.socntzgrpcod)
                                  returning al_cts17m03[m_ind].socntzcod
                                  
                                  #CT853801
                                  if al_cts17m03[m_ind].socntzcod is not null then
                                     let l_passou = true
                                  end if

                              else
                                  call cts17m06_popup_natureza(lr_param.aplnumdig, lr_param.c24astcod
                                                         ,lr_param.ramcod   , lr_param.cls_natureza
                                                         ,lr_param.rmemdlcod, lr_param.prporg
                                                         ,lr_param.prpnumdig, lr_param.socntzgrpcod , lr_param.crtsaunum)
                                  returning al_cts17m03[m_ind].socntzcod, l_clscod
                              end if
                          end if
                      end if
                      #CT853801
                      if l_passou = false then
                         next field socntzcod
                      end if
                      let l_passou = false
                  else
                     let l_calcula = "N"
                     continue input
                  end if
               else
                  #CT853801
                  if fgl_lastkey() <> fgl_keyval("up") and
                     fgl_lastkey() <> fgl_keyval("left") then
                     if g_documento.ciaempcod = 43 and # PSS - Condominio
                        g_documento.ligcvntip = 1  then
                     else
                        if g_documento.ciaempcod = 84 then
                        else
                           # Desvio para o conta corrente RE
                           let l_cortesia = false
                           call cta00m06_assunto_cort(g_documento.c24astcod)
                                returning l_cortesia
                           call cty10g00_grupo_ramo(g_documento.ciaempcod
                                                   ,g_documento.ramcod)
                                 returning lr_ramo.*
                           call cta00m06_re_contacorrente()
                                returning l_conta_corrente
                           if lr_ramo.ramgrpcod = 4               and
                              l_cortesia = false                  and
                              l_conta_corrente  = true            and
                             ( g_documento.aplnumdig is not null   or
                              g_documento.crtsaunum is not null ) then
                               let al_cts17m03[m_ind].socntzcod = null
                               call cts12g99(g_documento.succod,
                                             g_documento.ramcod,
                                             g_documento.aplnumdig,
                                             g_documento.prporg,
                                             g_documento.prpnumdig,
                                             g_documento.lclnumseq,
                                             g_documento.rmerscseq,
                                             g_documento.c24astcod,
                                             lr_param.socntzgrpcod)
                               returning al_cts17m03[m_ind].socntzcod
                           
                           end if
                           
                        end if
                     end if
                  end if
               end if

               if g_documento.ciaempcod = 84 and
                  l_cortesia = false         then
                   if g_documento.ramcod = 31 then
                         if lr_param.socntzcod = al_cts17m03[m_ind].socntzcod then
                            error "Natureza ja Selecionada no Original!"
                            next field socntzcod
                         end if
                   end if
               end if
               if g_documento.ciaempcod = 43 and # PSS - Condominio
                  g_documento.ligcvntip = 1  then
                  call cto00m08_inf_natureza(2,al_cts17m03[m_ind].socntzcod,'A',
                                             lr_param.socntzcod)
                  returning l_resultado , l_mensagem
                            ,al_cts17m03[m_ind].socntzdes, l_socntzgrpcod
               else
                  call ctc16m03_inf_natureza(al_cts17m03[m_ind].socntzcod, 'A')
                       returning l_resultado , l_mensagem
                                ,al_cts17m03[m_ind].socntzdes, l_socntzgrpcod
               end if
               if l_resultado <> 1 then
                  error l_mensagem
                  next field socntzcod
               end if
               display al_cts17m03[m_ind].* to s_cts17m03[m_ind].*
                         #if al_cts17m03[m_ind].socntzcod = lr_param.socntzcod then
                         #   error 'Natureza ja solicitada !'
                         #   next field socntzcod
                         #else
                            let l_arr = arr_curr()
                            let l_cont = arr_count()
                         #   let l_tem = 'N'
                         #   for l_for = 1 to l_cont
                         #       if l_for <> l_arr then
                         #          if al_cts17m03[m_ind].socntzcod = al_cts17m03[l_for].socntzcod then
                         #             error 'Natureza ja solicitada !'
                         #             let l_tem = 'S'
                         #          end if
                         #       end if
                         #   end for
                         #   if l_tem = 'S' then
                         #      next field socntzcod
                         #   end if
                         #end if

               if l_socntzgrpcod <> lr_param.socntzgrpcod then
                  error "Laudo Multiplo permitido somente para naturezas do mesmo grupo"
                  next field socntzcod
               end if
               let l_resultado = cts17m06_assunto_natureza(lr_param.c24astcod
                                                          ,al_cts17m03[m_ind].socntzcod)
               if l_resultado = 1 then
                  next field socntzcod
               end if
            else
               if al_cts17m03[m_ind].socntzcod is null and
                  al_cts17m03[m_ind].c24pbmcod is not null  then
                  next field socntzcod
               else
                  let l_calcula = "N"
                  continue input
               end if
            end if

# PSI 195138 - acionamento automatico - selecionar especialidade do servico
    before field espcod
        #so acionar especialidade qdo for grupo 1 - linha branca
        if l_socntzgrpcod <> 1 then
           next field c24pbmcod
        end if
        call cts31g00_qtde_especialidade("A")
          returning l_resultado
        if  l_resultado <> 0 then
           #E obrigatorio ter 1 especialidade cadastrada(1 - GERAL)
           # que deve ser a padrao, se nao tiver teremos problemas com
           # cadastro de socorrista. Para selecionar qq outra especialidade
           # informar branco no codigo que ira abrir a tela de pop up, caso
           # tenha mais de um registro
           let al_cts17m03[m_ind].espcod = 1
           display al_cts17m03[m_ind].espcod to s_cts17m03[m_ind].espcod
                   attribute(reverse)
        else
            #caso nao tenha registro na tabela - pular campo especialidade
            let al_cts17m03[m_ind].espcod = null
            let al_cts17m03[m_ind].espdes = null
            next field c24pbmcod
        end if

    after field espcod
           display al_cts17m03[m_ind].espcod to s_cts17m03[m_ind].espcod

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field socntzcod
          end if

          #espcod nao � obrigatorio entao apenas exibir
          #a lista de especialidade
          if al_cts17m03[m_ind].espcod is null then
             call cts31g00_lista_especialidade()
                  returning l_resultado,
                            al_cts17m03[m_ind].espcod,
                            al_cts17m03[m_ind].espdes
             if l_resultado = 3 then
                 error "Problemas ao listar especialidades"
             end if
          else
             #caso digite um codigo cadastrado, mas inativo
             #call cts31g00_situacao(al_cts17m03[m_ind].espcod)
                  #returning l_retorno
             #if l_retorno <> 'A' then
                 #error "Codigo de especialidade inativo"
                 #next field espcod
             #end if
             #
             #Apenas � permitido inserir uma especialidade ativa
             call cts31g00_descricao_esp(al_cts17m03[m_ind].espcod, "A")
                  returning al_cts17m03[m_ind].espdes
             if al_cts17m03[m_ind].espdes is null then
               #codigo especialidade invalido
                error "Codigo especialidade invalido."
                next field espcod
             end if
          end if
          display al_cts17m03[m_ind].espcod to s_cts17m03[m_ind].espcod
          display al_cts17m03[m_ind].espdes to s_cts17m03[m_ind].espdes


         before field c24pbmcod
           if al_cts17m03[m_ind].c24pbmcod is not null then
              let l_calcula = "N"
           end if

           display al_cts17m03[m_ind].c24pbmcod to s_cts17m03[m_ind].c24pbmcod attribute(reverse)

         after field c24pbmcod

           display al_cts17m03[m_ind].c24pbmcod to s_cts17m03[m_ind].c24pbmcod
           if fgl_lastkey() <> fgl_keyval("left") and
              fgl_lastkey() <> fgl_keyval("up")   then
              call cts17m07_problema(lr_param.aplnumdig          , lr_param.c24astcod, 9
                                    ,al_cts17m03[m_ind].c24pbmcod, al_cts17m03[m_ind].socntzcod
                                    ,lr_param.cls_natureza       , lr_param.cls_apolice
                                    ,lr_param.rmemdlcod          , lr_param.ramcod, lr_param.crtsaunum)
                   returning l_resultado, l_mensagem, al_cts17m03[m_ind].c24pbmcod
                             ,l_atddfttxt
              if l_resultado <> 1 then
                 error l_mensagem
                 next field c24pbmcod
              end if

              display al_cts17m03[m_ind].* to s_cts17m03[m_ind].*
              if al_cts17m03[m_ind].c24pbmcod = 999 then
                 next field atddfttxt
              else
                 let al_cts17m03[m_ind].atddfttxt  = l_atddfttxt
              end if
              display al_cts17m03[m_ind].* to s_cts17m03[m_ind].*
              if (lr_param.ramcod = 31 or lr_param.ramcod = 531) or
                 (lr_param.bnfnum is not null)                   or
                 (l_consiste_pss  = true)                        then  ## PSI 202720
                 if l_calcula = "S" then
                    let l_saldo = l_saldo - 1
                 end if
              end if
              display l_saldo to saldo

                for l_index = 1 to g_naturezas_re.qtd_eve
                 if ga_framg001_serv[l_index].socntzcod = al_cts17m03[m_ind].socntzcod then
                    if ga_framg001_serv[l_index].atdqtd > 0 then
                       let ga_framg001_serv[l_index].ageatdqtd = ga_framg001_serv[l_index].ageatdqtd + 1
                       exit for
                    else
                       let g_saldo_re.saldo = g_saldo_re.saldo - g_saldo_re.utiliz
                       exit for
                    end if
                 end if
                end for
              next field ghost
          end if

         before field atddfttxt
           display al_cts17m03[m_ind].atddfttxt to s_cts17m03[m_ind].atddfttxt
                   attribute(reverse)
           if al_cts17m03[m_ind].c24pbmcod <> 999 then
              display al_cts17m03[m_ind].atddfttxt to s_cts17m03[m_ind].atddfttxt
                for l_index = 1 to g_naturezas_re.qtd_eve
                 if ga_framg001_serv[l_index].socntzcod = al_cts17m03[m_ind].socntzcod and
                    ga_framg001_serv[l_index].atdqtd > 0 then
                    let ga_framg001_serv[l_index].ageatdqtd = ga_framg001_serv[l_index].ageatdqtd + 1
                    exit for
                 else
                    let g_saldo_re.saldo = g_saldo_re.saldo - g_saldo_re.utiliz
                    exit for
                 end if
                end for
              continue input
           end if
         after field atddfttxt
            display al_cts17m03[m_ind].atddfttxt to s_cts17m03[m_ind].atddfttxt

            if fgl_lastkey() <> fgl_keyval("left") and
               fgl_lastkey() <> fgl_keyval("up")   then
               if al_cts17m03[m_ind].atddfttxt is null or
                  al_cts17m03[m_ind].atddfttxt = ' ' then
                  error 'Por favor especifique o problema !'
                  next field atddfttxt
               end if
               if al_cts17m03[m_ind].c24pbmcod = 999 then
                     if (lr_param.ramcod = 31 or lr_param.ramcod = 531) or
                        (lr_param.bnfnum is not null)                   or
                        (l_consiste_pss  = true)                        then  ##PSI 202720
                        if l_calcula = "S" then
                           let l_saldo = l_saldo - 1
                        end if
                     end if
               end if
               display l_saldo to saldo
                for l_index = 1 to g_naturezas_re.qtd_eve
                 if ga_framg001_serv[l_index].socntzcod = al_cts17m03[m_ind].socntzcod and
                    ga_framg001_serv[l_index].atdqtd > 0 then
                    let ga_framg001_serv[l_index].ageatdqtd = ga_framg001_serv[l_index].ageatdqtd + 1
                    exit for
                 else
                    let g_saldo_re.saldo = g_saldo_re.saldo - g_saldo_re.utiliz
                    exit for
                 end if
                end for
               continue input
           end if
         on key(control-c, interrupt, f17)

         if m_ind > 1 and
               (al_cts17m03[m_ind].socntzcod is not null and
                al_cts17m03[m_ind].c24pbmcod is null) or
               (al_cts17m03[m_ind].socntzcod is null and
                al_cts17m03[m_ind].c24pbmcod is not null) then
               error  'Falta digitar natureza ou problema '
         else
            if m_ind = 1 and al_cts17m03[m_ind].socntzcod is not null and
                 al_cts17m03[m_ind].c24pbmcod is null then
                 let al_cts17m03[m_ind].socntzcod = null
           end if

               for m_ind = 1 to 10
                   if al_cts17m03[m_ind].socntzcod is not null then
                      let al_param[m_ind].socntzcod = al_cts17m03[m_ind].socntzcod
                      let al_param[m_ind].socntzdes = al_cts17m03[m_ind].socntzdes
                      let al_param[m_ind].espcod = al_cts17m03[m_ind].espcod
                      let al_param[m_ind].espdes = al_cts17m03[m_ind].espdes
                      let al_param[m_ind].c24pbmcod = al_cts17m03[m_ind].c24pbmcod
                      let al_param[m_ind].atddfttxt = al_cts17m03[m_ind].atddfttxt
                   else
                      initialize al_param[m_ind].* to null
                     initialize al_cts17m03[m_ind].* to null
                   end if
              end for
              let l_sai = 2
              exit input
         end if
      end input
      if l_sai <> 0 then
         exit while
      end if
      end while
  if l_sai = 1 then
     initialize al_param to null
  end if
  let int_flag = false
  close window w_cts17m03
  return al_param[1].*
        ,al_param[2].*
        ,al_param[3].*
        ,al_param[4].*
        ,al_param[5].*
        ,al_param[6].*
        ,al_param[7].*
        ,al_param[8].*
        ,al_param[9].*
        ,al_param[10].*
end function

#-------------------------------------------------------#
function cts17m03_incluir_hist(l_atdsrvnum, l_atdsrvano)
#-------------------------------------------------------#

define l_atdsrvnum        like datratdmltsrv.atdsrvnum
      ,l_atdsrvano        like datratdmltsrv.atdsrvano
define al_cts17m03_hist   array[200] of record
       c24funmat          like datmservhist.c24funmat
      ,c24srvdsc          like datmservhist.c24srvdsc
      ,ligdat             like datmservhist.ligdat
      ,lighorinc          like datmservhist.lighorinc
      ,c24empcod          like datmservhist.c24empcod
      ,c24usrtip          like datmservhist.c24usrtip
                          end record

define l_status            smallint
      ,l_mensagem          char(50)
      ,l_resultado         smallint
      ,l_nulo              like datmservhist.c24srvdsc
      if m_prepare is null or
         m_prepare <> true then
         call cts17m03_prepare()
      end if
      let l_nulo      = null
      let l_mensagem  = null
      let l_resultado = 1
      let m_ind  = 1
      open c_cts17m03_001 using l_atdsrvnum
                             ,l_atdsrvano
      foreach c_cts17m03_001 into al_cts17m03_hist[m_ind].*
         open ccts17m03002 using l_atdsrvnum
                                ,l_atdsrvano
         foreach ccts17m03002 into m_atdmltsrvnum
                                  ,m_atdmltsrvano
            let l_status = cts10g02_historico(m_atdmltsrvnum
                                            , m_atdmltsrvano
                                            , al_cts17m03_hist[m_ind].ligdat
                                            , al_cts17m03_hist[m_ind].lighorinc
                                            , al_cts17m03_hist[m_ind].c24funmat
                                            , al_cts17m03_hist[m_ind].c24srvdsc
                                            , l_nulo ,l_nulo ,l_nulo,l_nulo)
            if l_status <> 0 then
               let l_resultado = 2
               let l_mensagem  = "Erro :",l_status , " Na Inclusao do Historico! (cts17m03_inclui_hist()) "
               exit foreach
            end if
         end foreach
         if l_status <> 0 then
            exit foreach
         end if
         let m_ind = m_ind + 1
         if m_ind > 200 then
            error "Limite de Array Estourado, Avise a Informatica !"
            exit foreach
         end if
      end foreach

      return l_resultado, l_mensagem
end function

#-------------------------------------#
function cts17m03_envio_email(lr_param)
#-------------------------------------#
define lr_param                   record
       ramcod                     like datrservapol.ramcod
      ,c24astcod                  like datmligacao.c24astcod
      ,ligcvntip                  like datmligacao.ligcvntip
      ,succod                     like datrservapol.succod
      ,aplnumdig                  like datrservapol.aplnumdig
      ,itmnumdig                  like datrservapol.itmnumdig
      ,lignum                     like datmligacao.lignum
      ,atdsrvnum                  like datratdmltsrv.atdsrvnum
      ,atdsrvano                  like datratdmltsrv.atdsrvano
      ,prporg                     like datrligprp.prporg
      ,prpnumdig                  like datrligprp.prpnumdig
      ,solnom                     like datmservico.c24solnom
                                  end record
define l_lignum                   like datmligacao.lignum
      ,l_resultado                smallint

    if m_prepare is null or
       m_prepare <> true then
       call cts17m03_prepare()
    end if

    open ccts17m03002 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
    foreach ccts17m03002 into m_atdmltsrvnum
                             ,m_atdmltsrvano
       let l_lignum = cts20g00_servico(m_atdmltsrvnum, m_atdmltsrvano)

       if l_lignum is null then
          continue foreach
       end if
       call figrc072_setTratarIsolamento() -- > psi 223689
       call cts30m00(lr_param.ramcod   , lr_param.c24astcod
                                 ,lr_param.ligcvntip, lr_param.succod
                                 ,lr_param.aplnumdig, lr_param.itmnumdig
                                 ,l_lignum          , m_atdmltsrvnum
                                 ,m_atdmltsrvano    , lr_param.prporg
                                 ,lr_param.prpnumdig, lr_param.solnom)
                    returning  l_resultado
          if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
             error "Fun��o cts30m00 insdisponivel no momento ! Avise a Informatica !" sleep 2
             return
          end if        -- > 223689
       {let l_resultado = cts30m00(lr_param.ramcod   , lr_param.c24astcod
                                 ,lr_param.ligcvntip, lr_param.succod
                                 ,lr_param.aplnumdig, lr_param.itmnumdig
                                 ,l_lignum          , m_atdmltsrvnum
                                 ,m_atdmltsrvano    , lr_param.prporg
                                 ,lr_param.prpnumdig, lr_param.solnom)              }
      end foreach
end function

#================================================
 function cts17m03_verifica(lr_param)
#================================================

 define lr_param  record
       socntzcod_1                like datmsrvre.socntzcod
      ,socntzdes_1                like datksocntz.socntzdes
      ,espcod_1                   like datmsrvre.espcod    #PSI 195138
      ,espdes_1                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_1                like datkpbm.c24pbmcod
      ,atddfttxt_1                like datmservico.atddfttxt
      ,socntzcod_2                like datmsrvre.socntzcod
      ,socntzdes_2                like datksocntz.socntzdes
      ,espcod_2                   like datmsrvre.espcod    #PSI 195138
      ,espdes_2                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_2                like datkpbm.c24pbmcod
      ,atddfttxt_2                like datmservico.atddfttxt
      ,socntzcod_3                like datmsrvre.socntzcod
      ,socntzdes_3                like datksocntz.socntzdes
      ,espcod_3                   like datmsrvre.espcod    #PSI 195138
      ,espdes_3                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_3                like datkpbm.c24pbmcod
      ,atddfttxt_3                like datmservico.atddfttxt
      ,socntzcod_4                like datmsrvre.socntzcod
      ,socntzdes_4                like datksocntz.socntzdes
      ,espcod_4                   like datmsrvre.espcod    #PSI 195138
      ,espdes_4                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_4                like datkpbm.c24pbmcod
      ,atddfttxt_4                like datmservico.atddfttxt
      ,socntzcod_5                like datmsrvre.socntzcod
      ,socntzdes_5                like datksocntz.socntzdes
      ,espcod_5                   like datmsrvre.espcod    #PSI 195138
      ,espdes_5                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_5                like datkpbm.c24pbmcod
      ,atddfttxt_5                like datmservico.atddfttxt
      ,socntzcod_6                like datmsrvre.socntzcod
      ,socntzdes_6                like datksocntz.socntzdes
      ,espcod_6                   like datmsrvre.espcod    #PSI 195138
      ,espdes_6                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_6                like datkpbm.c24pbmcod
      ,atddfttxt_6                like datmservico.atddfttxt
      ,socntzcod_7                like datmsrvre.socntzcod
      ,socntzdes_7                like datksocntz.socntzdes
      ,espcod_7                   like datmsrvre.espcod    #PSI 195138
      ,espdes_7                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_7                like datkpbm.c24pbmcod
      ,atddfttxt_7                like datmservico.atddfttxt
      ,socntzcod_8                like datmsrvre.socntzcod
      ,socntzdes_8                like datksocntz.socntzdes
      ,espcod_8                   like datmsrvre.espcod    #PSI 195138
      ,espdes_8                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_8                like datkpbm.c24pbmcod
      ,atddfttxt_8                like datmservico.atddfttxt
      ,socntzcod_9                like datmsrvre.socntzcod
      ,socntzdes_9                like datksocntz.socntzdes
      ,espcod_9                   like datmsrvre.espcod    #PSI 195138
      ,espdes_9                   like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_9                like datkpbm.c24pbmcod
      ,atddfttxt_9                like datmservico.atddfttxt
      ,socntzcod_10               like datmsrvre.socntzcod
      ,socntzdes_10               like datksocntz.socntzdes
      ,espcod_10                  like datmsrvre.espcod    #PSI 195138
      ,espdes_10                  like dbskesp.espdes      #PSI 195138
      ,c24pbmcod_10               like datkpbm.c24pbmcod
      ,atddfttxt_10               like datmservico.atddfttxt
 end record

 if lr_param.socntzcod_1 = 0  then
    let lr_param.socntzcod_1 = null
    let lr_param.socntzdes_1 = null
    let lr_param.espcod_1 = null
    let lr_param.espdes_1 = null
    let lr_param.c24pbmcod_1 = null
    let lr_param.atddfttxt_1 = null
 end if
 if lr_param.socntzcod_2 = 0  then
    let lr_param.socntzcod_2 = null
    let lr_param.socntzdes_2 = null
    let lr_param.espcod_2 = null
    let lr_param.espdes_2 = null
    let lr_param.c24pbmcod_2 = null
    let lr_param.atddfttxt_2 = null
 end if
 if lr_param.socntzcod_3 = 0  then
    let lr_param.socntzcod_3 = null
    let lr_param.socntzdes_3 = null
    let lr_param.espcod_3 = null
    let lr_param.espdes_3 = null
    let lr_param.c24pbmcod_3 = null
    let lr_param.atddfttxt_3 = null
 end if
 if lr_param.socntzcod_4 = 0  then
    let lr_param.socntzcod_4 = null
    let lr_param.socntzdes_4 = null
    let lr_param.espcod_4 = null
    let lr_param.espdes_4 = null
    let lr_param.c24pbmcod_4 = null
    let lr_param.atddfttxt_4 = null
 end if
 if lr_param.socntzcod_5 = 0  then
    let lr_param.socntzcod_5 = null
    let lr_param.socntzdes_5 = null
    let lr_param.espcod_5 = null
    let lr_param.espdes_5 = null
    let lr_param.c24pbmcod_5 = null
    let lr_param.atddfttxt_5 = null
 end if
 if lr_param.socntzcod_6 = 0  then
    let lr_param.socntzcod_6 = null
    let lr_param.socntzdes_6 = null
    let lr_param.espcod_6 = null
    let lr_param.espdes_6 = null
    let lr_param.c24pbmcod_6 = null
    let lr_param.atddfttxt_6 = null
 end if
 if lr_param.socntzcod_7 = 0  then
    let lr_param.socntzcod_7 = null
    let lr_param.socntzdes_7 = null
    let lr_param.espcod_7 = null
    let lr_param.espdes_7 = null
    let lr_param.c24pbmcod_7 = null
    let lr_param.atddfttxt_7 = null
 end if
 if lr_param.socntzcod_8 = 0  then
    let lr_param.socntzcod_8 = null
    let lr_param.socntzdes_8 = null
    let lr_param.espcod_8 = null
    let lr_param.espdes_8 = null
    let lr_param.c24pbmcod_8 = null
    let lr_param.atddfttxt_8 = null
 end if
 if lr_param.socntzcod_9 = 0  then
    let lr_param.socntzcod_9 = null
    let lr_param.socntzdes_9 = null
    let lr_param.espcod_9 = null
    let lr_param.espdes_9 = null
    let lr_param.c24pbmcod_9 = null
    let lr_param.atddfttxt_9 = null
 end if
 if lr_param.socntzcod_10 = 0  then
    let lr_param.socntzcod_10 = null
    let lr_param.socntzdes_10 = null
    let lr_param.espcod_10 = null
    let lr_param.espdes_10 = null
    let lr_param.c24pbmcod_10 = null
    let lr_param.atddfttxt_10 = null
 end if
 return lr_param.*

 end function
