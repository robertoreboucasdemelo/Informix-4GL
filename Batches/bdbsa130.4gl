#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: BDBSA130                                                   #
# ANALISTA RESP..: SERGIO BURINI                                              #
# PSI/OSF........: RELATORIOS PENDENCIAS JUNTO A VISTORIA                     #
# ........................................................................... #
# DESENVOLVIMENTO: SERGIO BURINI                                              #
# LIBERACAO......: 31/05/2010                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   -------------- ---------- ------------------------------------- #
#01/03/2011  Ueslei Santos             Inclusão de coluna cadeia de gestão   #
#01/03/2011  Ueslei Santos             Alteração da descrição do motivo      #
#01/04/2011  Robert Lima               Chave d bloqueio pela cidade sede     #
#08/07/2011  Celso Yamahaki            Inclusao de campos UF Cidade e Tipo   #
#08/05/2015  Fornax, RCP    FX-080515  Incluir coluna data no relatorio.     #
#07/01/2015  Fornax, ElianeK           Desbloqueio automatico viatura        #
#18/02/2016  Fornax, ElianeK           Inserir historico do Desbloqueio      #
#                                      automatico viatura                    #
#                                      Inserir status da vistoria previa no  #
#                                      log para Desbloqueio autom viatura    #
#08/03/2016 Fornax,ElianeK             Inserir validacao do veiculo para     #
#                                      desbloqueio "NAO CONFORMIDADES NA     #
#                                      VISTORIA DO VEICULO"                  #
#----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_dados record
    socvclcod     like datkveiculo.socvclcod,
    vclchsfnl     like datkveiculo.vclchsfnl,
    vcllicnum     like datkveiculo.vcllicnum,
    atdvclsgl     like datkveiculo.atdvclsgl,
    pstcoddig     like datkveiculo.pstcoddig,
    nomgrr        like dpaksocor.nomgrr,
    endcid        like dpaksocor.endcid,
    endufd        like dpaksocor.endufd,
    socvcltip     like datkveiculo.socvcltip,
    cpodes        like iddkdominio.cpodes,
    socoprsitcod  like datkveiculo.socoprsitcod,
    bloqueado     char(50)
end record

define mr_vistoria record
    vstnumdig like avlmlaudo.vstnumdig,
    vstdat    like avlmlaudo.vstdat,
    vsthor    like avlmlaudo.vsthor
end record

define mr_cad_gestao record
    gstcdicod like dpaksocor.gstcdicod,
    sprnom    like dpakprsgstcdi.sprnom,
    gernom    like dpakprsgstcdi.gernom,
    cdnnom    like dpakprsgstcdi.cdnnom,
    anlnom    like dpakprsgstcdi.anlnom
end record

define m_path       char(200),
       m_path2      char(200),
       m_path_txt   char(200),
       m_motblq     char(001),
       m_motdesbl   char(100)

main

    set isolation to dirty read

    let g_issk.empcod = 1
    let g_issk.funmat = 999999
    let g_issk.usrtip = 'F'

    call bdbsa130_path()
    call cts40g03_exibe_info("I","BDBSA130")

    call bdbsa130_prepare()
    call bdbsa130()

    call cts40g03_exibe_info("F","BDBSA130")

end main

#---------------------------#
 function bdbsa130_prepare()
#---------------------------#

     define l_sql char(5000)

     let l_sql = "select vcl.socvclcod, ",
                       " vcl.vclchsfnl, ",
                       " vcl.vcllicnum, ",
                       " vcl.atdvclsgl, ",
                       " vcl.pstcoddig, ",
                       " vcl.socvcltip, ",
                       " pst.endcid,",
                       " pst.endufd, ",
                       " vcl.socoprsitcod ",
                  " from datkveiculo vcl, ",
                       " dpaksocor   pst ",
                 " where pst.frtrpnflg    = 1 ",      # Responsavel área Porto Socorro
                   " and vcl.socoprsitcod = 1 ",      # Ativos
                   " and pst.pstcoddig    = vcl.pstcoddig ",
                   " and exists (select 1 ",
                                 " from iddkdominio dmn ",
                                " where dmn.cponom = 'VCLVRFINTVST' ", # Deve ter o tipo do veiculo
                                  " and dmn.cpocod  = vcl.socvcltip)"  # cadastrado no parametro.

     prepare pbdbsa130_01 from l_sql
     declare cbdbsa130_01 cursor for pbdbsa130_01


#### Desbloqueio Automatico de Veiculos - 07/01/2015
    let l_sql = " select vcl.socvclcod,         ",
                "        vcl.vclchsfnl,         ",
                "        vcl.vcllicnum,         ",
                "        vcl.atdvclsgl,         ",
	        "        vcl.pstcoddig,         ",
	        "        vcl.socvcltip,         ",
	        "        pst.endcid,            ",
	        "        pst.endufd ,           ",
                "        vcl.socoprsitcod       ",
	        "   from datkveiculo vcl,       ",
	        "        dpaksocor   pst        ",
	     "  where pst.frtrpnflg    = 1   ", # Responsavel area Porto Socorro
	        "    and vcl.socoprsitcod = 2", # Bloqueados
                "     and pst.pstcoddig = vcl.pstcoddig ",
	        "     and exists (select 1 ",
	        " from iddkdominio dmn ",
	    " where dmn.cponom = 'VCLVRFINTVST' ", # Deve ter o tipo do veiculo
	    "   and dmn.cpocod  = vcl.socvcltip)"  # cadastrado no parametro
	       prepare pbdbsa130_20 from l_sql
	       declare cbdbsa130_20 cursor for pbdbsa130_20

     let l_sql = "update  datkveiculo set socoprsitcod   = 1 "
	        ," where vclchsfnl = ?  and "
	        ,"       vcllicnum = ?  and "
	        ,"       socvclcod = ? "
     prepare pbdbsa130_30 from l_sql

     let l_sql = "insert into datmvstsemvcl values (0,?,?,1,?,?,current,?,'','','')"

     prepare pbdbsa130_02 from l_sql

     let l_sql = "select max(evtseq) ",
                  " from datmvstsemvcl ",
                 " where socvclcod = ? "

     prepare pbdbsa130_03 from l_sql
     declare cbdbsa130_03 cursor for pbdbsa130_03

     let l_sql = "select 1 ",
                  " from datmvstsemvcl vst1 ",
                 " where vst1.socvclcod = ? ",
                   " and vst1.evttip    = 1 ",
                   " and vst1.evtseq    = (select max(evtseq) ",
                                           " from datmvstsemvcl vst2 ",
                                          " where vst1.socvclcod = vst2.socvclcod)"

     prepare pbdbsa130_04 from l_sql
     declare cbdbsa130_04 cursor for pbdbsa130_04

     let l_sql = "update datkveiculo ",
                   " set socoprsitcod = 2 ", #Bloqueia viatura.
                 " where socvclcod = ? "

     prepare pbdbsa130_05 from l_sql

     let l_sql = "select nomgrr ",
                  " from dpaksocor ",
                 " where pstcoddig = ? "

     prepare pbdbsa130_06 from l_sql
     declare cbdbsa130_06 cursor for pbdbsa130_06

     let l_sql = "select 1 ",
                  " from datmvstsemvcl vst1 ",
                 " where vst1.vstnum = ? ",
                   " and vst1.socvclcod = ? ",
                   " and vst1.evttip = 2 ",
                   " and vst1.evtseq = (select max(evtseq) ",
                                        " from datmvstsemvcl vst2 ",
                                       " where vst1.socvclcod = vst2.socvclcod) "

     prepare pbdbsa130_07 from l_sql
     declare cbdbsa130_07 cursor for pbdbsa130_07

     let l_sql = "select grlinf ",
                  " from datkgeral ",
                 " where grlchv = ? "

     prepare pbdbsa130_08 from l_sql
     declare cbdbsa130_08 cursor for pbdbsa130_08

     let l_sql = "insert into datkvclsit( socvclcod, ",
                                        " socvclsitdes, ",
                                        " caddat, ",
                                        " cadhor, ",
                                        " cademp, ",
                                        " cadmat, ",
                                        " atldat, ",
                                        " atlemp, ",
                                        " atlmat ) ",
                               " values ( ?,",
                                        "'NAO CONFORMIDADES NA VISTORIA DO VEICULO.',",
                                        "today,",
                                        "current hour to minute,",
                                        "1,",
                                        "999999,",
                                        "today,",
                                        "1,",
                                        "999999)"

     prepare pbdbsa130_09 from l_sql

     let l_sql = "update dattfrotalocal set (mdtmvtdircod, ",
                   " mdtmvtvlc, ",
                   " atdsrvnum, ",
                   " atdsrvano, ",
                   " cttdat, ",
                   " ctthor, ",
                   " srrcoddig, ",
                   " c24atvcod, ",
                   " atdvclpriflg) = ('', ",
                                     "'', ",
                                     "'', ",
                                     "'', ",
                                     "'', ",
                                     "'', ",
                                     "'', ",
                                     "'QTP', ",
                                     "'N') ",
            " where socvclcod = ? "

     prepare pbdbsa130_10 from l_sql

     let l_sql = "update datmfrtpos set ",
                   "(ufdcod, ",
                   " cidnom, ",
                   " brrnom, ",
                   " endzon, ",
                   " lclltt, ",
                   " lcllgt, ",
                   " atldat, ",
                   " atlhor) = ('', ",
                              " '', ",
                              " '', ",
                              " '', ",
                              " '', ",
                              " '', ",
                              " today, ",
                              " current hour to minute) ",
            " where socvclcod =  ? ",
              " and socvcllcltip  in (1,2,3) "

     prepare pbdbsa130_11 from l_sql


     let l_sql = "select gstcdicod ",
                 "  from dpaksocor ",
                 " where pstcoddig = ? "
     prepare pbdbsa130_12 from l_sql
     declare cbdbsa130_12 cursor for pbdbsa130_12

     let l_sql = "select sprnom,   	",
      		 "      gernom,    	",
      		 "      cdnnom,  	",
      		 "      anlnom		",
      		 " from dpakprsgstcdi	",
      		 "where gstcdicod = ?	"
     prepare pbdbsa130_13 from l_sql
     declare cbdbsa130_13 cursor for pbdbsa130_13

     let l_sql = "select cpodes      ",
                 "  from datkdominio ",
                 " where cponom = 'blqcidsedvtr'  ",
                 "   and cpodes = ?  "
     prepare pbdbsa130_14 from l_sql
     declare cbdbsa130_14 cursor for pbdbsa130_14

     let l_sql = "select cidsedcod                   ",
                 "  from datrcidsed                  ",
                 " where cidcod = (select mpacidcod  ",
                 "                   from datkmpacid ",
                 "                  where cidnom = ? ",
                 "                    and ufdcod = ?)"
     prepare pbdbsa130_15 from l_sql
     declare cbdbsa130_15 cursor for pbdbsa130_15

     let l_sql = "select cpodes      ",
                 "  from iddkdominio ",
                 " where cponom = 'socvcltip'  ",
                 "   and cpocod = ?  "
     prepare pbdbsa130_16 from l_sql
     declare cbdbsa130_16 cursor for pbdbsa130_16

    let l_sql = "select vstfld        "
               ,"  from avlmlaudo     "
	             ," where vstnumdig = ? "
    prepare pbdbsa130_17 from l_sql
    declare cbdbsa130_17 cursor for pbdbsa130_17

    let l_sql = " select vstcpodomdes     "
               ,"   from avlkdomcampovst  "
	             ,"  where vstcpocod    = 1 " #Dominio para finalidades relacionadas a VP Porto Socorro
	             ,"    and vstcpodomcod = ? "
    prepare pbdbsa130_18 from l_sql
    declare cbdbsa130_18 cursor for pbdbsa130_18

    let l_sql = " select vststtcod       "
               ,"   from avlmstatus      "
	             ,"  where vststtstt = 'A' "
	             ,"    and vstnumdig = ?   "
    prepare pbdbsa130_19 from l_sql
    declare cbdbsa130_19 cursor for pbdbsa130_19

    let l_sql = "insert into datmcadalthst "
	       ," (hstide, conchv, hstseq, hsttex, caddat, cademp, cadmat, "
	       ,"  cadusrtip ) values ( 1, ?, ?, ?, today, 1, 999999, 'F') "

    prepare pbdbsa130_50 from l_sql

    let l_sql = "select count(hstseq) from datmcadalthst "
	             ," where conchv = ?"
     prepare pbdbsa130_53 from l_sql
	   declare cbdbsa130_53 cursor for pbdbsa130_53

    let l_sql = "select max(hstseq) from datmcadalthst "
	             ," where conchv = ?"
    prepare pbdbsa130_51 from l_sql
    declare cbdbsa130_51 cursor for pbdbsa130_51

    let l_sql = "select vststtdes "
	              ," from   avckstatus where vststtcod = ? "
    prepare pbdbsa130_52 from l_sql
    declare cbdbsa130_52 cursor for pbdbsa130_52

    let l_sql = "select 1 from datkvclsit " 
               ," where                   "
	       ," socvclsitdes like '%NAO CONFORMIDADES NA VISTORIA%' "
	       ," and socvclcod = ? "
    prepare pbdbsa130_60 from l_sql
    declare cbdbsa130_60 cursor for pbdbsa130_60

    let l_sql = "select socvclsitdes from datkvclsit "
               ," where socvclcod = ? "
      prepare pbdbsa130_61 from l_sql
      declare cbdbsa130_61 cursor for pbdbsa130_61

 end function

#-------------------#
 function bdbsa130()
#-------------------#

define l_pend           smallint,
       l_seq            smallint,
       l_status         smallint,
       l_cont           smallint,
       l_retorno        integer,
       l_titulo         char(100),
       l_mensagem       char(500),
       l_cidsedcod      like datrcidsed.cidsedcod,
       l_vstcpodomcod   like avlkdomcampovst.vstcpodomcod,
       l_vstcpodomdes   like avlkdomcampovst.vstcpodomdes,
       l_vststtcod      like avlmstatus.vststtcod,
       l_vststtcod_desc like avckstatus.vststtdes,
       l_max_hstseq     integer,
       l_conchv         char(8),
       l_texto          char(70),
       l_cont_seq       integer,
       l_desc           char(150)


define lr_mail record
   rem char(50),
   des char(250),
   ccp char(250),
   cco char(250),
   ass char(150),
   msg char(32000),
   idr char(20),
   tip char(4)
end record

define lr_retorno record
   cod_erro  integer,
   msg_erro  char(250)
end record

   initialize l_pend
             ,l_seq
             ,l_status
             ,l_cont
             ,l_retorno
             ,l_titulo
             ,l_mensagem
             ,l_cidsedcod
             ,l_vstcpodomcod
             ,l_vstcpodomdes
             ,l_vststtcod
             ,l_vststtcod_desc
             ,l_max_hstseq
             ,l_conchv
             ,l_texto
             ,l_cont_seq
             ,m_motblq
             ,m_motdesbl
	     ,l_desc to null

   initialize  m_motblq
              ,m_motdesbl to null

   initialize lr_mail.*, lr_retorno.* to null

   initialize mr_dados.*
             ,mr_vistoria.*
             ,mr_cad_gestao.* to null

   display "Inicio Analise Bloqueio Automatico"
   display "-------------------------------------------------------"

   let l_cont = 0
    open cbdbsa130_01
   fetch cbdbsa130_01 into mr_dados.socvclcod,
                           mr_dados.vclchsfnl,
                           mr_dados.vcllicnum,
                           mr_dados.atdvclsgl,
                           mr_dados.pstcoddig,
                           mr_dados.socvcltip,
                           mr_dados.endcid,
                           mr_dados.endufd,
                           mr_dados.socoprsitcod


   if  sqlca.sqlcode = 0 then

      foreach cbdbsa130_01 into mr_dados.socvclcod,
                                mr_dados.vclchsfnl,
                                mr_dados.vcllicnum,
                                mr_dados.atdvclsgl,
                                mr_dados.pstcoddig,
                                mr_dados.socvcltip,
                                mr_dados.endcid,
                                mr_dados.endufd

          #Busca o tipo de viatura
          open cbdbsa130_16 using mr_dados.socvcltip
         fetch cbdbsa130_16 into mr_dados.cpodes

             if status = notfound then
                let mr_dados.cpodes = "NAO CADASTRADO"
             end if

         close cbdbsa130_16

          call fvpic070_ultima_vistoria(1,
                                        mr_dados.vclchsfnl,
                                        mr_dados.vcllicnum)
               returning mr_vistoria.vstnumdig,
                         mr_vistoria.vstdat,
                         mr_vistoria.vsthor

          display "----------------[Ativos]--------------------"
          display "Prestador: "         , mr_dados.pstcoddig
          display "Sigla Veiculo: "     , mr_dados.atdvclsgl
          display "Tipo Veiculo: "      , mr_dados.socvcltip," - ",mr_dados.cpodes
          display "Num Vistoria: "      , mr_vistoria.vstnumdig
          display "Data/Hora Vistoria: ", mr_vistoria.vstdat, " ", mr_vistoria.vsthor

          open cbdbsa130_12 using mr_dados.pstcoddig
         fetch cbdbsa130_12 into mr_cad_gestao.gstcdicod

          open cbdbsa130_13 using mr_cad_gestao.gstcdicod
         fetch cbdbsa130_13 into mr_cad_gestao.sprnom,
   			                         mr_cad_gestao.gernom,
   			                         mr_cad_gestao.cdnnom,
   			                         mr_cad_gestao.anlnom

          if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
          	 initialize mr_cad_gestao.* to null
          	 return 0
          end if

          if  mr_vistoria.vstnumdig <> 0 then

              open cbdbsa130_04 using mr_dados.socvclcod
             fetch cbdbsa130_04 into l_status

              if sqlca.sqlcode = notfound then

                 open cbdbsa130_07 using mr_vistoria.vstnumdig,
                                         mr_dados.socvclcod
                fetch cbdbsa130_07 into l_status

                    if sqlca.sqlcode = notfound then
                       if not bdbsa130_verif_sit(5) then
                          if not bdbsa130_verif_sit(7) then
                             if bdbsa130_validade_vst() then
                                display "EM DIA COM A VISTORIA: ", mr_dados.vcllicnum
                                continue foreach
                             else
                                display "Excedido"
                                let m_motblq = "E" #-->Excedido
                             end if
                          else
                             display "Fora de Norma"
                             let m_motblq = "F" #-->Fora da Norma
                          end if
                       else
                          display "Devolvido"
                          let m_motblq = "D" #-->Devolvido
                       end if
                    else
                       display "Veiculo ja Bloqueado, evttip = 2"
                       continue foreach
                    end if
                close cbdbsa130_07

              else
                 display "Veiculo ja Bloqueado, evttip = 1"
                 continue foreach
              end if
             close cbdbsa130_04
          else
              display "N"
              let m_motblq = "N"
          end if

         close cbdbsa130_12
         close cbdbsa130_13

          if l_cont = 0 then
             start report bdbsa130_relat to m_path
             start report bdbsa130_relat_txt to m_path_txt
          end if

          let mr_dados.bloqueado = "NAO BLOQUEADO"

          if bdbsa130_verifica_atl_frt() then

              #Busca a cidade sede

              open cbdbsa130_15 using mr_dados.endcid,
                                      mr_dados.endufd
             fetch cbdbsa130_15 into l_cidsedcod
             close cbdbsa130_15

              display "Cidade/UF ",mr_dados.endcid clipped, "/", mr_dados.endufd
              display "l_cidsedcod     = ",l_cidsedcod

              if bdbsa130_validade_bql(l_cidsedcod) then

                 display "Cidade sede bloqueia"

                 open cbdbsa130_03 using mr_dados.socvclcod
                fetch cbdbsa130_03 into l_seq

                 if l_seq is null or l_seq = " " then
                    let l_seq = 0
                 end if

                 let l_seq = l_seq + 1

                 whenever error continue

                 execute pbdbsa130_02 using mr_dados.socvclcod,
                                            l_seq,
                                            mr_vistoria.vstnumdig,
                                            mr_vistoria.vstdat,
                                            m_motblq

                 if sqlca.sqlcode <> 0 then
                    display "Erro pbdbsa130_02"
                 end if

                 execute pbdbsa130_05 using mr_dados.socvclcod

                 if sqlca.sqlcode <> 0 then
                    display "Erro pbdbsa130_05"
                 end if

                 execute pbdbsa130_09 using mr_dados.socvclcod

                 if sqlca.sqlcode <> 0 then
                    display "Erro pbdbsa130_09"
                 end if

                 execute pbdbsa130_10 using mr_dados.socvclcod

                 if sqlca.sqlcode <> 0 then
                    display "Erro pbdbsa130_10"
                 end if

                 execute pbdbsa130_11 using mr_dados.socvclcod

                 if sqlca.sqlcode <> 0 then
                    display "Erro pbdbsa130_11"
                 end if


                 whenever error stop

                 let l_titulo = 'BLOQUEIO DE VEICULO ', mr_dados.socvclcod using '<<<<&',
                                ' NAO CONFORMIDADE COM A VISTORIA'
                 let l_mensagem = 'O veiculo ', mr_dados.socvclcod using '<<<<&', ' foi bloqueado devido a',
                                ' nao conformidades junto a Vistoria. Para maiores detalhes, consulte o',
                                ' cadastro de Viaturas Bloqueadas.'

                 display "Titulo: ", l_titulo clipped

                 call ctc34m02_grava_hist(mr_dados.socvclcod
                                         ,l_titulo
                                         ,today
                                         ,l_mensagem)
                               returning lr_retorno.cod_erro

                 let mr_dados.bloqueado = "BLOQUEADO"
              close cbdbsa130_03
              else
                 display "PARAMETRO PARA ATUALIZAÇAO DA FROTA DESATIVADO.PARA CIDADE SEDE NAO HAVERA BLOQUEIO"
              end if
          else
              display "PARAMETRO PARA ATUALIZAÇAO DA FROTA DESATIVADO"
          end if

          output to report bdbsa130_relat()
          output to report bdbsa130_relat_txt()

          let l_cont = l_cont + 1

          display "-------------------------------------------------------"

      end foreach

      if l_cont > 0 then
         finish report bdbsa130_relat
         finish report bdbsa130_relat_txt

          call ctx22g00_envia_email("RELVST","Relatorio Vistoria Viaturas Porto Socorro", m_path)
               returning l_retorno
      end if
   else
      display "NENHUM VEICULO LOCALIZADO PARA BLOQUEIO"
   end if

   close cbdbsa130_01

   display ""
   display "Termino Analise Bloqueio Automatico"
   display "-------------------------------------------------------"
   display ""
   display ""
   display "-------------------------------------------------------"
   display "Inicio Analise Desbloqueio Automatico"
   display ""
   
   initialize mr_dados.*
             ,mr_vistoria.* to null

   start report bdbsa130_desbloq_relat to m_path2

   open cbdbsa130_20
   fetch cbdbsa130_20 into mr_dados.socvclcod,
               	           mr_dados.vclchsfnl,
                           mr_dados.vcllicnum,
	                         mr_dados.atdvclsgl,
	                         mr_dados.pstcoddig,
	                         mr_dados.socvcltip,
	                         mr_dados.endcid,
	                         mr_dados.endufd,
                           mr_dados.socoprsitcod

    if sqlca.sqlcode = 0 then
	     foreach cbdbsa130_20 into mr_dados.socvclcod,
                                 mr_dados.vclchsfnl,
	                               mr_dados.vcllicnum,
	                               mr_dados.atdvclsgl,
	                               mr_dados.pstcoddig,
	                               mr_dados.socvcltip,
	                               mr_dados.endcid,
       	                         mr_dados.endufd,
       	                         mr_dados.socoprsitcod

          #Busca nco conformidade na vistoria do veiculo
	         open cbdbsa130_60 using mr_dados.socvclcod
          fetch cbdbsa130_60 
	          let l_desc = null
	         if sqlca.sqlcode =  notfound   then
          
               open cbdbsa130_61 using mr_dados.socvclcod
	            fetch cbdbsa130_61 into l_desc
                    display "----------------[Bloqueado]---------------------"
	                  display "Prestador: ",          mr_dados.pstcoddig
	                  display "Sigla Veiculo: ",      mr_dados.atdvclsgl
                    display "Veiculo: ", mr_dados.socvclcod, " :: ", l_desc clipped
	            close cbdbsa130_60
	            close cbdbsa130_61
	           continue foreach
           end if
          close cbdbsa130_60

          #Busca o tipo de viatura
	        open cbdbsa130_16 using mr_dados.socvcltip
	       fetch cbdbsa130_16  into mr_dados.cpodes

             if sqlca.sqlcode <> 0 then
	              let mr_dados.cpodes = "NAO CADASTRADO"
             end if

         close cbdbsa130_16

           call fvpic070_ultima_vistoria(1,
	               		                     mr_dados.vclchsfnl,
		   		                               mr_dados.vcllicnum)
		      	     returning mr_vistoria.vstnumdig,
	                 	       mr_vistoria.vstdat,
	              		       mr_vistoria.vsthor

	         if mr_vistoria.vstnumdig is null or
	            mr_vistoria.vstnumdig = 0     then
	               display "----------------[Bloqueado]---------------------"
	               display "Nao ha numero de Vistoria para veiculo "
	                       ,mr_dados.socvclcod, " - sigla: ", mr_dados.atdvclsgl
	               continue foreach
	         end if

	          display "----------------[Bloqueado]---------------------"
	          display "Prestador: ",          mr_dados.pstcoddig
            display "Sigla Veiculo: ",      mr_dados.atdvclsgl
            display "Tipo Veiculo: ",       mr_dados.socvcltip, " - "
                                           ,mr_dados.cpodes
            display "Numero Vistoria: ",    mr_vistoria.vstnumdig
            display "Data Hora Vistoria: ", mr_vistoria.vstdat, " ",
		   		                                  mr_vistoria.vsthor

            open cbdbsa130_17 using mr_vistoria.vstnumdig
           fetch cbdbsa130_17  into l_vstcpodomcod

            open cbdbsa130_18 using l_vstcpodomcod
           fetch cbdbsa130_18  into l_vstcpodomdes

	          if sqlca.sqlcode <> 0 then
		           let l_vstcpodomdes = null
            end if

            if l_vstcpodomdes = "PORTO SOCORRO"    or
               l_vstcpodomdes = "VEICULOS SOCORRO" or
               l_vstcpodomdes = "VEICULOS PORTO"   then

	             open cbdbsa130_19 using mr_vistoria.vstnumdig
              fetch cbdbsa130_19  into l_vststtcod

               if sqlca.sqlcode = 0 then
              		 let l_vststtcod_desc = null

                  open cbdbsa130_52 using l_vststtcod
	               fetch cbdbsa130_52  into l_vststtcod_desc

                  display "Status da Vistoria: ", l_vststtcod, " - "
                                                 ,l_vststtcod_desc clipped

                 close cbdbsa130_52

                 if l_vststtcod = 1 then
                     if bdbsa130_validade_desbloqueio_vst() then
                        let m_motdesbl =  "Vistoria Excedida"
                        display m_motdesbl clipped
                     else
	                      let m_motdesbl =  "Vistoria OK: ", l_vststtcod_desc clipped
		   	                display m_motdesbl clipped

	                      #Desbloqueia veiculo
	                      whenever error continue
		   	                execute pbdbsa130_30 using mr_dados.vclchsfnl,
                                                   mr_dados.vcllicnum,
	                                                 mr_dados.socvclcod
	                      whenever error stop

                        if sqlca.sqlcode <> 0 then
                           display "Erro update pbdbsa130_30 Vistoria OK Veiculo : ", mr_dados.atdvclsgl
		   	                   continue foreach
		   	               end if

		   	              # Insere historico de desbloqueio de veiculo
		   	              let l_texto = "BDBSA130 Desbloqueio Automatico: ", l_vststtcod_desc clipped
		   	              let l_conchv = mr_dados.socvclcod clipped

		   	              open cbdbsa130_53 using l_conchv
		   	             fetch cbdbsa130_53  into l_cont_seq

		   	              if l_cont_seq = 0 then
                          let l_max_hstseq = 1
                      else
                          let l_max_hstseq = null
		   	                 open cbdbsa130_51 using l_conchv
		   	                fetch cbdbsa130_51  into l_max_hstseq
		   	                  let l_max_hstseq = l_max_hstseq + 1
		   	                close cbdbsa130_51
                      end if

                       execute pbdbsa130_50 using l_conchv,
		   		             		                       l_max_hstseq,
		   		             		                       l_texto
                       if sqlca.sqlcode <> 0 then
	                        display "Erro insert no historico pbdbsa130_50 Vistoria OK Veiculo : ", mr_dados.atdvclsgl clipped
                       end if

		   	             close cbdbsa130_53

                     end if
                 else
                    let m_motdesbl =  "Vistoria NOK: ", l_vststtcod_desc clipped
                    display m_motdesbl clipped
	               end if
	             else
	                display "Erro cbdbsa130_19: ", sqlca.sqlcode
	             end if
              close cbdbsa130_19
            else
               let m_motdesbl =  "Finalidade: ", l_vstcpodomdes clipped
               display m_motdesbl clipped
            end if

           close cbdbsa130_18
           close cbdbsa130_17

           output to report bdbsa130_desbloq_relat()

           initialize mr_vistoria.*
                     ,m_motdesbl to null

           initialize l_vstcpodomdes
                     ,l_vststtcod
                     ,l_vststtcod_desc
                     ,l_cont_seq
                     ,l_max_hstseq
                     ,l_texto
                     ,l_conchv to null

       end foreach

       finish report bdbsa130_desbloq_relat
       
       call ctx22g00_envia_email("RELVST","Rel Analise Desbloqueio Automativo de Vistoria", m_path2)
            returning l_retorno
       
    else
       display "Nenhum Veiculo Localizado para Desbloqueio"
    end if
 close cbdbsa130_20


end function

#----------------------------------------#
 function bdbsa130_verif_sit(l_vststtcod)
#----------------------------------------#

     define l_vststtcod like avlmstatus.vststtcod

     define lr_retorno record
         vstnumdig like avlmstatus.vstnumdig,
         vststtcod like avlmstatus.vststtcod,
         atlult    like avlmstatus.atlult,
         vststtstt like avlmstatus.vststtstt,
         atldat    like avlmstatus.atldat,
         atlhor    like avlmstatus.atlhor,
         atlemp    like avlmstatus.atlemp,
         atlmat    like avlmstatus.atlmat,
         atlusrtip like avlmstatus.atlusrtip,
         codret    smallint
     end record

     call fvpic290_avlmstatus(lr_retorno.vstnumdig,l_vststtcod)
          returning lr_retorno.vstnumdig,
                    lr_retorno.vststtcod,
                    lr_retorno.atlult,
                    lr_retorno.vststtstt,
                    lr_retorno.atldat,
                    lr_retorno.atlhor,
                    lr_retorno.atlemp,
                    lr_retorno.atlmat,
                    lr_retorno.atlusrtip,
                    lr_retorno.codret

     if  lr_retorno.codret = 0 then
         return true
     end if

     return false

 end function

#-----------------------#
 report bdbsa130_relat()
#-----------------------#

     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    07

     format

         first page header

             print "RELATORIO de VEICULOS BLOQUEADOS COM IRREGULARIDADES NA VISTORIA."
             print ""
             print "VEICULO",           ASCII(09),
                   "SIGLA",             ASCII(09),
                   "PLACA",             ASCII(09),
                   "PRESTADOR",         ASCII(09),
                   "VISTORIA",          ASCII(09),
                   "DATA VISTORIA",     ASCII(09),
                   "MOTIVO BLOQUEIO",   ASCII(09),
                   "CADEIA DE GESTAO",  ASCII(09),
                   "BLOQUEADO",         ASCII(09),
                   "TIPO VIATURA",      ASCII(09),
                   "UF",                ASCII(09),
                   "CIDADE",            ASCII(09),
                   "DATA",              ASCII(09) #--> FX-080515
        on every row

             open cbdbsa130_06 using mr_dados.pstcoddig
             fetch cbdbsa130_06 into mr_dados.nomgrr

             print mr_dados.socvclcod,    ASCII(09),
                   mr_dados.atdvclsgl,    ASCII(09),
                   mr_dados.vcllicnum,    ASCII(09),
                   mr_dados.pstcoddig,    ASCII(09);

             if  mr_vistoria.vstnumdig <> 0 then
                 print mr_vistoria.vstnumdig, ASCII(09),
                       mr_vistoria.vstdat,    ASCII(09);
             else
                 print "NAO CADASTRADO", ASCII(09),
                       ASCII(09);
             end if

             case m_motblq
             	 when "E"
             	 	print "EXCEDIDO";
             	 	exit case
             	 when "F"
             	 	print "FORA DA NORMA";
             	 	exit case
             	 when "D"
             	 	print "DEVOLVIDO";
             	 	exit case
             	 otherwise
             	 	print "SEM VISTORIA";
             	 	exit case

             end case

             print ASCII(09);

             print mr_cad_gestao.sprnom,"/",
             	   mr_cad_gestao.gernom,"/",
             	   mr_cad_gestao.cdnnom,"/",
             	   mr_cad_gestao.anlnom;

             print ASCII(09);

             print mr_dados.bloqueado clipped, ASCII(09);

             print mr_dados.cpodes clipped,ASCII(09);
             print mr_dados.endufd,ASCII(09);
             print mr_dados.endcid clipped,ASCII(09);
	     print today #--> FX-080515
 end report

#-----------------------#
report bdbsa130_desbloq_relat()
#-----------------------#

   output
      left   margin    00
      right  margin    00
      top    margin    00
      bottom margin    00
      page   length    07

   format

      first page header

         print "RELATORIO DE RESUMO DA ANALISE DE VEICULOS DESBLOQUEADOS."
         print ""
         print "VEICULO",           ASCII(09),
               "SIGLA",             ASCII(09),
               "PLACA",             ASCII(09),
               "PRESTADOR",         ASCII(09),
               "VISTORIA",          ASCII(09),
               "DATA VISTORIA",     ASCII(09),
               "MOTIVO",            ASCII(09),
               "DATA"

      on every row

         print mr_dados.socvclcod,    ASCII(09),
               mr_dados.atdvclsgl,    ASCII(09),
               mr_dados.vcllicnum,    ASCII(09),
               mr_dados.pstcoddig,    ASCII(09);

         if  mr_vistoria.vstnumdig <> 0 then
             print mr_vistoria.vstnumdig, ASCII(09),
                   mr_vistoria.vstdat,    ASCII(09);
         else
             print "NAO CADASTRADO", ASCII(09),
                                     ASCII(09);
         end if

         print m_motdesbl clipped , ASCII(09);
         print today
end report

#------------------------#
 function bdbsa130_path()
#------------------------#

   define l_dataarq char(8)
   define l_data    date

   initialize l_dataarq
             ,l_data
             ,m_path_txt
             ,m_path
             ,m_path2 to null

   let l_data = today
   let l_dataarq = extend(l_data, year to year),
                   extend(l_data, month to month),
                   extend(l_data, day to day)

   let m_path = f_path("DBS","RELATO")

   if  m_path is null then
       let m_path = "."
   end if

   let m_path_txt = m_path clipped
   let m_path2 = m_path clipped
   let m_path  = m_path  clipped, "/BDBSA130.xls"
   let m_path2 = m_path2 clipped, "/BDBSA130_2_" clipped, l_dataarq, ".xls"
   let m_path_txt = m_path_txt clipped, "/BDBSA130_" clipped, l_dataarq, ".txt"

   display "m_path_txt: ", m_path_txt
   display "m_path: ",     m_path
   display "m_path2: ",    m_path2

 end function

#------------------------------------#
 function bdbsa130_verifica_atl_frt()
#------------------------------------#

     define l_status char(01),
            l_param  char(25)

     let l_param = 'PSOATLFRTINTVST'

     open cbdbsa130_08 using l_param
     fetch cbdbsa130_08 into l_status

     if  l_status = 'S' then
         return true
     end if

     return false

 end function

#--------------------------------#
 function bdbsa130_validade_vst()
#--------------------------------#

     define l_dias   smallint,
            l_param  char(25),
            l_datmax date

     initialize l_dias,
                l_datmax to null

     let l_param = 'PSOPRZMAXVSTPSO'

     open cbdbsa130_08 using l_param
     fetch cbdbsa130_08 into l_dias

     let l_datmax = mr_vistoria.vstdat + l_dias units day

     if  l_datmax >= today then
         return true
     end if

     return false

 end function

#--------------------------------#
 function bdbsa130_validade_desbloqueio_vst()
#--------------------------------#

     define l_dias   smallint,
            l_param  char(25),
            l_datmax date

     initialize l_dias,
                l_datmax to null

     let l_param = 'PSOPRZMAXVSTPSO'

     open cbdbsa130_08 using l_param
     fetch cbdbsa130_08 into l_dias

     let l_datmax = mr_vistoria.vstdat + l_dias units day

     if  l_datmax >= today then
         return false
     end if

     return true

 end function

#--------------------------------#
 function bdbsa130_validade_bql(l_cidsedcod)
#--------------------------------#

     define l_cpodes like datkdominio.cpodes,
            l_cidsedcod like datrcidsed.cidsedcod

     open cbdbsa130_14 using l_cidsedcod
     fetch cbdbsa130_14 into l_cpodes

     if  sqlca.sqlcode = notfound then
         close cbdbsa130_14
         return true
     end if

     close cbdbsa130_14

     if l_cpodes is null or l_cpodes = '' then
         return true
     end if

     return false

 end function

#-----------------------#
 report bdbsa130_relat_txt()
#-----------------------#

     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    01

     format

         on every row

             open cbdbsa130_06 using mr_dados.pstcoddig
             fetch cbdbsa130_06 into mr_dados.nomgrr

             print mr_dados.socvclcod,    ASCII(09),
                   mr_dados.atdvclsgl,    ASCII(09),
                   mr_dados.vcllicnum,    ASCII(09),
                   mr_dados.pstcoddig,    ASCII(09);

             if  mr_vistoria.vstnumdig <> 0 then
                 print mr_vistoria.vstnumdig, ASCII(09),
                       mr_vistoria.vstdat,    ASCII(09);
             else
                 print "NAO CADASTRADO", ASCII(09),
                       ASCII(09);
             end if

             case m_motblq
             	 when "E"
             	 	print "EXCEDIDO";
             	 	exit case
             	 when "F"
             	 	print "FORA DA NORMA";
             	 	exit case
             	 when "D"
             	 	print "DEVOLVIDO";
             	 	exit case
             	 otherwise
             	 	print "SEM VISTORIA";
             	 	exit case

             end case

             print ASCII(09);

             print mr_cad_gestao.sprnom,"/",
             	   mr_cad_gestao.gernom,"/",
             	   mr_cad_gestao.cdnnom,"/",
             	   mr_cad_gestao.anlnom           ,ASCII(09);
             print mr_dados.bloqueado clipped   ,ASCII(09);
             print mr_dados.cpodes clipped      ,ASCII(09);
             print mr_dados.endufd              ,ASCII(09);
             print mr_dados.endcid clipped      ,ASCII(09);
	           print today #--> FX-080515
 end report
