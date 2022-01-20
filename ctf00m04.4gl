###############################################################################a
# Sistea  r CTS      - Central 24 Horas                            JULHO/2008 #
# Programa :                                                                   #
# Modulo   : ctf00m04 - Registrar Servicos                                     #
# Analista : Carla Rampazzo                                                    #
# PSI      :                                                                   #
# Liberacao:                                                                   #
#------------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                             #
#------------------------------------------------------------------------------#
# DATA       RESPONSAVEL     PSI     DESCRICAO                                 #
#------------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo  219444  Tratar inclusao em datmsrvre dos campos   #
#                                    (lclnumseq / rmerscseq)                   #
#------------------------------------------------------------------------------#
#                           * * * Comentarios * * *                            #
#                                                                              #
# Toda alteracao na funcao cts17m00_grava_dados implica em tambem alterar este #
# modulo que e utilizado para o Portal do Segurado                             #
################################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_param_mult      array[10] of record
       socntzcod         like datmsrvre.socntzcod
      ,espcod            like datmsrvre.espcod
      ,c24pbmcod         like datkpbm.c24pbmcod
end record 

#-----------------------------------------------------------------------------
function ctf00m04_prepara()
#-----------------------------------------------------------------------------

   define l_sql   char(500)

   let l_sql = ' update datksegsau '
               ,'   set (lgdtip    '
                     ,' ,lgdnom    '
                     ,' ,lgdnum    '
                     ,' ,lclbrrnom '
                     ,' ,brrnom    '
                     ,' ,cidnom    '
                     ,' ,ufdcod    '
                     ,' ,lclrefptotxt '
                     ,' ,endzon    '
                     ,' ,lgdcep    '
                     ,' ,lgdcepcmp '
                     ,' ,lclltt    '
                     ,' ,lcllgt    '
                     ,' ,dddcod    '
                     ,' ,lcltelnum '
                     ,' ,lclcttnom '
                     ,' ,c24lclpdrcod) = '
                     ,' (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) '
                     ,' where crtsaunum  =  ? '
   prepare pctf00m04001 from l_sql


   let l_sql = ' insert into datmsrvre '
                    ,'(atdsrvnum    '
		    ,',atdsrvano    '
                    ,',lclrsccod    '
		    ,',orrdat       '
                    ,',orrhor       '
		    ,',socntzcod    '
                    ,',atdsrvretflg '
		    ,',atdorgsrvnum '
                    ,',atdorgsrvano '
		    ,',srvretmtvcod '
                    ,',retprsmsmflg '
		    ,',lclnumseq    '       
		    ,',rmerscseq    '       
		    ,',espcod)      '       
                    ,' values (?,?,?,?,"00:00",?,"N",?,?,?,?,?,?,?) '
   prepare pctf00m04002 from l_sql

   let l_sql = ' insert into datmsrvretexc '
                           ,'(atdsrvnum '
                           ,',atdsrvano '
                           ,',srvretexcdes '
                           ,',caddat '
                           ,',cademp '
                           ,',cadmat '
                           ,',cadusrtip) '
                           ,'values (?,?,?,?,?,?,?) '
   prepare pctf00m04003 from l_sql

   let l_sql = ' insert into datrservapol '
                          ,'(atdsrvnum '
                          ,',atdsrvano '
                          ,',succod '
                          ,',ramcod '
                          ,',aplnumdig '
                          ,',itmnumdig '
                          ,',edsnumref ) '
                          ,' values (?,?,?,?,?,?,?) '
   prepare pctf00m04004 from l_sql

   let l_sql = ' insert into datratdmltsrv '
                          ,'(atdsrvnum '
                          ,',atdsrvano '
                          ,',atdmltsrvnum '
                          ,',atdmltsrvano ) '
                          ,' values (?,?,?,?) '
   prepare pctf00m04005 from l_sql

   let l_sql = ' select c24pbmdes '
              ,'   from datkpbm ' 
              ,'  where c24pbmcod = ?'
   prepare pctf00m04006 from l_sql
   declare cctf00m04006 cursor with hold for pctf00m04006

   let l_sql = ' select max(atdsrvseq) '
              ,'   from datmsrvacp '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
   prepare pctf00m04007 from l_sql
   declare cctf00m04007 cursor for pctf00m04007

   let l_sql = " select grlinf ",
                    " from datkgeral ",
                    " where grlchv = 'PSOAGENDAWATIVA' "
   prepare pctf00m04008 from l_sql
   declare cctf00m04008 cursor for pctf00m04008

end function 


#-----------------------------------------------------------------------------
function ctf00m04_grava_dados(l_param,l_param_multiplos)
#-----------------------------------------------------------------------------

   define l_param           record
          c24astcod         like datmligacao.c24astcod
         ,data              date
         ,hora              datetime hour to minute
         ,lgdtip            char(10)
         ,lgdnom            char(50)
         ,lgdnum            integer
         ,brrnom            char(50)
         ,cidnom            like glakcid.cidnom         
         ,ufdcod            like glakcid.ufdcod         
         ,lclrefptotxt      like datmlcl.lclrefptotxt    
         ,endzon            like datmlcl.endzon          
         ,lgdcep            like datmlcl.lgdcep          
         ,lgdcepcmp         like datmlcl.lgdcepcmp       
         ,lclcttnom         like datmlcl.lclcttnom       
         ,dddcod            like datmlcl.dddcod          
         ,lcltelnum         like datmlcl.lcltelnum     
         ,endcmp            like datmlcl.endcmp             #P283688
         ,srvrglcod         like datmsrvrgl.srvrglcod
         ,atdsrvnum         like datmservico.atdsrvnum
         ,atdsrvano         like datmservico.atdsrvano
	 ,acao              char (03)
         ,srvretmtvcod      like datksrvret.srvretmtvcod
         ,srvretmtvdes      like datksrvret.srvretmtvdes 
         ,retprsmsmflg      like datmsrvre.retprsmsmflg
         ,orrdat            like datmsrvre.orrdat        
   end record


   define l_param_multiplos record
          socntzcod_01      like datmsrvre.socntzcod
         ,espcod_01         like datmsrvre.espcod
         ,c24pbmcod_01      like datkpbm.c24pbmcod

         ,socntzcod_02      like datmsrvre.socntzcod
         ,espcod_02         like datmsrvre.espcod
         ,c24pbmcod_02      like datkpbm.c24pbmcod

         ,socntzcod_03      like datmsrvre.socntzcod
         ,espcod_03         like datmsrvre.espcod
         ,c24pbmcod_03      like datkpbm.c24pbmcod

         ,socntzcod_04      like datmsrvre.socntzcod
         ,espcod_04         like datmsrvre.espcod
         ,c24pbmcod_04      like datkpbm.c24pbmcod

         ,socntzcod_05      like datmsrvre.socntzcod
         ,espcod_05         like datmsrvre.espcod
         ,c24pbmcod_05      like datkpbm.c24pbmcod

         ,socntzcod_06      like datmsrvre.socntzcod
         ,espcod_06         like datmsrvre.espcod
         ,c24pbmcod_06      like datkpbm.c24pbmcod

         ,socntzcod_07      like datmsrvre.socntzcod
         ,espcod_07         like datmsrvre.espcod
         ,c24pbmcod_07      like datkpbm.c24pbmcod

         ,socntzcod_08      like datmsrvre.socntzcod
         ,espcod_08         like datmsrvre.espcod
         ,c24pbmcod_08      like datkpbm.c24pbmcod

         ,socntzcod_09      like datmsrvre.socntzcod
         ,espcod_09         like datmsrvre.espcod
         ,c24pbmcod_09      like datkpbm.c24pbmcod

         ,socntzcod_10      like datmsrvre.socntzcod
         ,espcod_10         like datmsrvre.espcod
         ,c24pbmcod_10      like datkpbm.c24pbmcod
   end record


   define l_ctf00m04        record
          data              date
         ,hora              datetime hour to minute
         ,atdsrvnum         like datmservico.atdsrvnum
         ,atdsrvano         like datmservico.atdsrvano
         ,atdsrvnum_org     like datmservico.atdsrvnum
         ,atdsrvano_org     like datmservico.atdsrvano
         ,lignum            like datmligacao.lignum
         ,atdlibflg         like datmservico.atdlibflg
         ,ltdhorpvt         like datmservico.atdhorpvt
         ,atdprscod         like datmservico.atdprscod
         ,atdfnlflg         like datmservico.atdfnlflg
         ,caddat            like datmligfrm.caddat
         ,cadhor            like datmligfrm.cadhor
         ,cademp            like datmligfrm.cademp
         ,cadmat            like datmligfrm.cadmat
         ,atdhorpvt         like datmservico.atdhorpvt
         ,nom               like datmservico.nom
         ,corsus            like datmservico.corsus
         ,cornom            like datmservico.cornom     
         ,cvnnom            char (20)
         ,viginc            like rsdmdocto.viginc        
         ,vigfnl            like rsdmdocto.vigfnl        
         ,vclcoddig         like datmservico.vclcoddig
         ,vcldes            like datmservico.vcldes
         ,vclanomdl         like datmservico.vclanomdl
         ,vcllicnum         like datmservico.vcllicnum
         ,vclchsinc         like abbmveic.vclchsinc
         ,vclchsfnl         like abbmveic.vclchsfnl
         ,vclcordes         char (11)
         ,cnldat            like datmservico.cnldat
         ,c24nomctt         like datmservico.c24nomctt
         ,atdpvtretflg      like datmservico.atdpvtretflg
         ,asitipcod         like datmservico.asitipcod
         ,atdprinvlcod      like datmservico.atdprinvlcod
         ,prslocflg         char (01)
         ,atddfttxt         like datmservico.atddfttxt
         ,operacao          char (01)
         ,lclidttxt         like datmlcl.lclidttxt
         ,lclltt            like datmlcl.lclltt
         ,lcllgt            like datmlcl.lcllgt
         ,c24lclpdrcod      like datmlcl.c24lclpdrcod
         ,ofnnumdig         like sgokofi.ofnnumdig
         ,emeviacod         like datmlcl.emeviacod
         ,retflg            char (01)
         ,atdsrvseq         like datmsrvacp.atdsrvseq
         ,atdetpcod         like datmsrvacp.atdetpcod 
         ,lclrsccod         like datmsrvre.lclrsccod
         ,veiculo_aciona    like datkveiculo.socvclcod
	 ,frmflg            char(01)
         ,histerr           smallint
         ,hist1             like datmservhist.c24srvdsc
         ,hist2             like datmservhist.c24srvdsc
         ,hist3             like datmservhist.c24srvdsc
         ,hist4             like datmservhist.c24srvdsc
         ,hist5             like datmservhist.c24srvdsc
         ,atdrsdflg         like datmservico.atdrsdflg    
   end record

   define l_sqlcode         smallint
         ,l_msg             char(100)
         ,l_for             smallint
         ,l_tabname         like systables.tabname 
         ,l_servico         char(200) 
         ,l_agendaw         smallint
         ,l_natureza        like datmsrvre.socntzcod
         ,l_data_char       char(10)
         ,l_srvhordat       char(19)  # Data e hora do servico
         ,l_num_reg         int
         ,l_rsrchv          char(25) # Chave de reserva
         ,l_lista_horarios  char (30000)


   define l_ret             record
          retorno           smallint
         ,mensagem          char(500)
         ,xml               char(5000)
   end record


   initialize l_ret.* , l_servico
	     ,l_ctf00m04.* to null
   

   let l_ret.retorno           = 0    ---> Registro Incluido / <> 0 Problema
   let l_for                   = 0
   let l_ctf00m04.atdlibflg    = "S" 
   let l_ctf00m04.atdfnlflg    = "N" 
   let l_ctf00m04.asitipcod    = 6   
   let l_ctf00m04.atdprinvlcod = 2    ---> Normal   
   let l_ctf00m04.prslocflg    = 'N'  ---> Prestador no Local  
   let l_ctf00m04.operacao     = 'I'    
   let l_ctf00m04.frmflg       = 'N'  ---> Entrada via Formulario  
   let l_ctf00m04.hist1        = 'ATENDIMENTO VIA PORTAL DO SEGURADO' 
   let l_ctf00m04.atdpvtretflg = 'N'

   ## -- Atendimento inicializa como NAO LIBERADO para o SISTEMA PET -- ##
   
   if  l_param.c24astcod = 'PE1' or
       l_param.c24astcod = 'PE2' then
       let l_ctf00m04.atdlibflg    = "N" 
   end if


   #----------------------
   # Trata Nome do Servico
   #----------------------
   if l_param.acao = "RET" then
      let l_servico = "REGISTRAR_RETORNO_SERVICO"
   else
      let l_servico = "REGISTRAR_SERVICOS"
   end if


   #-----------------------------
   # Valida Parametros de Entrada
   #-----------------------------
   if l_param.acao <> "RET" then
      call ctf00m04_valida_param(l_param.*
                                ,l_param_multiplos.socntzcod_01
                                ,l_param_multiplos.espcod_01
                                ,l_param_multiplos.c24pbmcod_01 )
           returning l_ret.*
   end if


   #-----------------
   # Gera xml de Erro
   #-----------------
   if l_ret.retorno <> 0 then

       call ctf00m06_xmlerro (l_servico             
                             ,l_ret.retorno
                             ,l_ret.mensagem)
            returning l_ret.xml  

       return l_ret.xml
   end if


   #-----------------
   # Prepara Comandos
   #-----------------
   call ctf00m04_prepara()


   #--------------------------
   # Carrega Servicos no Array 
   #--------------------------
   call ctf00m04_carrega_servico(l_param_multiplos.*)


   #-----------------------------------
   # Carrega Susep/Nome e Nome Segurado
   #-----------------------------------
   if g_documento.ramcod = 31   or
      g_documento.ramcod = 531  then

      call cts05g00 (g_documento.succod   
                    ,g_documento.ramcod   
                    ,g_documento.aplnumdig
                    ,g_documento.itmnumdig)
           returning l_ctf00m04.nom      
                    ,l_ctf00m04.corsus  
                    ,l_ctf00m04.cornom   
                    ,l_ctf00m04.cvnnom   
                    ,l_ctf00m04.vclcoddig        
                    ,l_ctf00m04.vcldes           
                    ,l_ctf00m04.vclanomdl        
                    ,l_ctf00m04.vcllicnum        
                    ,l_ctf00m04.vclchsinc        
                    ,l_ctf00m04.vclchsfnl        
                    ,l_ctf00m04.vclcordes

   else

      call cts05g01 (g_documento.succod   
                    ,g_documento.ramcod   
                    ,g_documento.aplnumdig)
           returning l_ctf00m04.nom
                    ,l_ctf00m04.cornom
                    ,l_ctf00m04.corsus
                    ,l_ctf00m04.cvnnom
                    ,l_ctf00m04.viginc
                    ,l_ctf00m04.vigfnl
   end if

   #------------
   # Data / Hora
   #------------
   call cts40g03_data_hora_banco(2) 
        returning l_ctf00m04.data
                 ,l_ctf00m04.hora

 
   #-----------------------------------
   # Carrega Coordenadas de Localizacao
   #-----------------------------------
   call ctx32g00_buscaCoordenadas(l_param.lgdtip
                                 ,l_param.lgdnom
                                 ,l_param.lgdnum
                                 ,l_param.brrnom
                                 ,l_param.cidnom
                                 ,l_param.ufdcod )
        returning l_ctf00m04.lcllgt
                 ,l_ctf00m04.lclltt
                 ,l_ctf00m04.c24lclpdrcod

   ## -- Servico PET nao precisa de agendamento -- ##

   if  l_param.c24astcod <> 'PE1' and
       l_param.c24astcod <> 'PE2' then

       #---------------------------------------------------
       # Verifica se Data/Horario de Agenda esta Disponivel 
       # Caso esteja disponivel ja abate a Cota 
       # Trata Somente Servicos Agendados
       #---------------------------------------------------
       if l_param.data is not null and 
          l_param.data <> " "      and
          l_param.hora is not null and
          l_param.hora <> " "      then

          # PSI-2013-00440PR
          let l_agendaw = false
          
          whenever error continue
          open cctf00m04008
          fetch cctf00m04008 into l_agendaw
          
          if sqlca.sqlcode != 0
             then
             let l_agendaw = false
          end if
          close cctf00m04008
          whenever error stop
          # PSI-2013-00440PR
       
          begin work
       
          if l_agendaw then

             if l_param.srvrglcod = 1 then #LINHA BRANCA
                let l_natureza = 12 # GELADEIRA
             else
             	 let l_natureza = 1 # HIDRAULICA
             end if

             let l_data_char = l_param.data
             let l_srvhordat = l_data_char[7,10] clipped
                                                ,"-" clipped
                                                ,l_data_char[4,5] clipped
                                                ,"-" clipped
                                                ,l_data_char[1,2] clipped
                                                ,"T" clipped
                                                ,l_param.hora clipped
                                                ,":00" clipped
                                           
             call cts02m08_obtem_agenda(l_srvhordat,
                                        l_param.cidnom,
                                        l_param.ufdcod,
                                        "",
                                        "",
                                        "",
                                        "N",
                                        0,
                                        0,
                                        0,
                                        1,
                                        9, # atdsrvorg
                                        0,
                                        l_natureza,
                                        0)
                  returning l_num_reg, l_lista_horarios, l_rsrchv
             
             if l_num_reg = 1 then
             	
               display 'ctf00m04_grava_dados antes baixa - l_rsrchv: ', l_rsrchv
               call ctd41g00_baixar_agenda(l_rsrchv
                                         , l_param.atdsrvano
                                         , l_param.atdsrvnum)
                    returning l_sqlcode, l_ret.mensagem
             
             end if	 
          else
             call ctc59m03_reserva(l_param.cidnom
                                  ,l_param.ufdcod
                                  ,g_documento.atdsrvorg
                                  ,l_param.srvrglcod
                                  ,l_param.data  
                                  ,l_param.hora)  
                  returning l_sqlcode
          end if
          
          if l_sqlcode = 0 then
             commit work
          else
             rollback work
       
             if l_sqlcode = 100 then
                let l_ret.retorno  = 9999
                let l_ret.mensagem = " Data/Hora nao estao mais disponiveis! "
             else
                let l_ret.retorno  = 15
                let l_ret.mensagem = " Erro (",l_sqlcode,") na Reserva de Cotas ",
                                     ". AVISE A INFORMATICA!"
             end if
       
             ---> Monta Xml de Erro
             call ctf00m06_xmlerro (l_servico             
                                   ,l_ret.retorno
                                   ,l_ret.mensagem)
                  returning l_ret.xml  
       
             return l_ret.xml
          end if
       end if
   end if


   #-------------------------
   # Inicia Gravacao dos Dados 
   #-------------------------

   for l_for = 1 to 10
    
      if m_param_mult[l_for].socntzcod is null then
         exit for
      end if


      #----------------------
      # Descricao do Problema
      #----------------------
      open  cctf00m04006 using m_param_mult[l_for].c24pbmcod
      fetch cctf00m04006 into  l_ctf00m04.atddfttxt


      #------------
      # Data / Hora
      #------------
      call cts40g03_data_hora_banco(2) 
           returning l_ctf00m04.data
                    ,l_ctf00m04.hora

      #------------------------------------------------------------------------------ 
      # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia                  
      #------------------------------------------------------------------------------ 
                                                                                      
      if g_documento.lclocodesres = "S" then                                          
         let l_ctf00m04.atdrsdflg = "S"                                               
      else                                                                            
         let l_ctf00m04.atdrsdflg = "N"                                               
      end if                                                                          
      
      
      begin work

      #----------------------------------
      # Busca numeracao ligacao / servico
      #----------------------------------
      call cts10g03_numeracao(2,"9")
           returning l_ctf00m04.lignum
                    ,l_ctf00m04.atdsrvnum
                    ,l_ctf00m04.atdsrvano
                    ,l_sqlcode
                    ,l_msg


      if l_sqlcode = 0  then
         commit work
      else
         rollback work

         let l_ret.retorno  = 01
         let l_ret.mensagem = " Erro (",l_sqlcode,") ",l_msg clipped,". AVISE A INFORMATICA!"

         exit for          
      end if

      let g_documento.lignum    = l_ctf00m04.lignum

      #-----------------------------------------
      # Guarda o Servico Original (1o. problema)
      # Utilizado quando ha Servicos Multiplos
      #-----------------------------------------
      if l_for = 1 then
         let l_ctf00m04.atdsrvnum_org = l_ctf00m04.atdsrvnum
         let l_ctf00m04.atdsrvano_org = l_ctf00m04.atdsrvano
      end if


      #-----------------------
      # Grava dados da ligacao 
      #-----------------------
      begin work

      call cts10g00_ligacao ( g_documento.lignum      
                             ,l_ctf00m04.data       
                             ,l_ctf00m04.hora       
                             ,g_documento.c24soltipcod
                             ,g_documento.solnom     
                             ,l_param.c24astcod     
                             ,g_issk.funmat
                             ,g_documento.ligcvntip   
                             ,g_c24paxnum             
                             ,l_ctf00m04.atdsrvnum      
                             ,l_ctf00m04.atdsrvano      
                             ,"","","",""             
                             ,g_documento.succod      
                             ,g_documento.ramcod      
                             ,g_documento.aplnumdig   
                             ,g_documento.itmnumdig   
                             ,g_documento.edsnumref   
                             ,g_documento.prporg      
                             ,g_documento.prpnumdig   
                             ,g_documento.fcapacorg   
                             ,g_documento.fcapacnum   
                             ,"","","",""             
                             ,l_ctf00m04.caddat
                             ,l_ctf00m04.cadhor   
                             ,l_ctf00m04.cademp
                             ,l_ctf00m04.cadmat   )
           returning l_tabname, l_sqlcode

      if l_sqlcode <> 0 then
         let l_ret.mensagem = " Erro (",l_sqlcode,") na gravacao da",
                               " tabela ",l_tabname clipped,". AVISE A INFORMATICA!"
         let l_ret.retorno = 02
         rollback work

         exit for        
      end if

      #-----------------
      # Servico Imediato
      #-----------------
      if (l_param.data is null or 
          l_param.data =  " "      ) and
         (l_param.hora is null or
          l_param.hora =  " "      ) then
        let l_ctf00m04.atdhorpvt = "2:00" 
      else
        let l_ctf00m04.atdhorpvt = null    
      end if


      #-----------------------
      # Grava dados do servico 
      #-----------------------
      call cts10g02_grava_servico( l_ctf00m04.atdsrvnum
                                  ,l_ctf00m04.atdsrvano
                                  ,g_documento.soltip        # atdsoltip
                                  ,g_documento.solnom        # c24solnom
                                  ," "                       # vclcorcod
                                  ,g_issk.funmat
                                  ,l_ctf00m04.atdlibflg  
                                  ,l_ctf00m04.hora           # atdlibhor
                                  ,l_ctf00m04.data           # atdlibdat
                                  ,l_ctf00m04.data           # atddat
                                  ,l_ctf00m04.hora           # atdhor
                                  ,""                        # atdlclflg
                                  ,l_ctf00m04.atdhorpvt    
                                  ,l_param.data              # atddatprg
                                  ,l_param.hora              # atdhorprg
                                  ,"9"                       # atdtip
                                  ,""                        # atdmotnom
                                  ,""                        # atdvclsgl
                                  ,l_ctf00m04.atdprscod
                                  ,""                        # atdcstvlr
                                  ,l_ctf00m04.atdfnlflg
                                  ,l_ctf00m04.hora           # atdfnlhor
                                  ,l_ctf00m04.atdrsdflg
                                  ,l_ctf00m04.atddfttxt
                                  ,""                        # atddoctxt
                                  ," "                       # c24opemat
                                  ,l_ctf00m04.nom      
                                  ,""                        # vcldes
                                  ,""                        # vclanomdl
                                  ,""                        # vcllicnum
                                  ,l_ctf00m04.corsus   
                                  ,l_ctf00m04.cornom   
                                  ,l_ctf00m04.cnldat   
                                  ,""                        # pgtdat
                                  ,l_ctf00m04.c24nomctt
                                  ,l_ctf00m04.atdpvtretflg
                                  ,""                        # atdvcltip
                                  ,l_ctf00m04.asitipcod
                                  ,""                        # socvclcod
                                  ,""                        # vclcoddig
                                  ,"N"                       # srvprlflg
                                  ,""                        # srrcoddig
                                  ,l_ctf00m04.atdprinvlcod
                                  ,g_documento.atdsrvorg   ) # ATDSRVORG
           returning l_tabname, l_sqlcode

      if l_sqlcode <> 0 then
         let l_ret.mensagem = " Erro (",l_sqlcode,") na gravacao da",
                               " tabela ",l_tabname clipped,". AVISE A INFORMATICA!"
         let l_ret.retorno = 03
         rollback work

         exit for        
      end if


      #---------------------------
      # Grava problemas do servico
      #---------------------------
      call ctx09g02_inclui(l_ctf00m04.atdsrvnum
                          ,l_ctf00m04.atdsrvano
                          ,1                     # Org.Inf -> 1-Segurado 2-Pst
                          ,m_param_mult[l_for].c24pbmcod
                          ,l_ctf00m04.atddfttxt
                          ,"" )                  # Codigo prestador
           returning l_sqlcode, l_tabname

      if l_sqlcode <> 0 then
         let l_ret.mensagem = " Erro (",l_sqlcode,") na gravacao de",
                               " problemas do servico. AVISE A INFORMATICA!"
         let l_ret.retorno = 04
         rollback work

         exit for        
      end if


      #---------------------------
      # Grava locais de ocorrencia
      #---------------------------
      let l_sqlcode = cts06g07_local( l_ctf00m04.operacao    
                                     ,l_ctf00m04.atdsrvnum      
                                     ,l_ctf00m04.atdsrvano     
                                     ,1                         
                                     ,l_ctf00m04.lclidttxt   
                                     ,l_param.lgdtip      
                                     ,l_param.lgdnom      
                                     ,l_param.lgdnum     
                                     ,l_param.brrnom      # lclbrrnom
                                     ,l_param.brrnom      
                                     ,l_param.cidnom      
                                     ,l_param.ufdcod      
                                     ,l_param.lclrefptotxt
                                     ,l_param.endzon      
                                     ,l_param.lgdcep      
                                     ,l_param.lgdcepcmp   
                                     ,l_ctf00m04.lclltt      
                                     ,l_ctf00m04.lcllgt      
                                     ,l_param.dddcod      
                                     ,l_param.lcltelnum   
                                     ,l_param.lclcttnom   
                                     ,l_ctf00m04.c24lclpdrcod
                                     ,l_ctf00m04.ofnnumdig
                                     ,l_ctf00m04.emeviacod
                                     ,""  # celteldddcod,
                                     ,""  # celtelnum )   
                                     ,l_param.endcmp) # Complemento     #P283688
      if l_sqlcode <> 0    or  
         l_sqlcode is null then
         let l_ret.mensagem = " Erro (",l_sqlcode,") na gravacao do",
                               " local de ocorrencia. AVISE A INFORMATICA!"
         let l_ret.retorno = 05
         rollback work

         exit for        
      end if
      

      execute pctf00m04001 using  l_param.lgdtip
                                 ,l_param.lgdnom
                                 ,l_param.lgdnum
                                 ,l_param.brrnom
                                 ,l_param.brrnom
                                 ,l_param.cidnom
                                 ,l_param.ufdcod
                                 ,l_param.lclrefptotxt
                                 ,l_param.endzon
                                 ,l_param.lgdcep
                                 ,l_param.lgdcepcmp
                                 ,l_ctf00m04.lclltt
                                 ,l_ctf00m04.lcllgt
                                 ,l_param.dddcod
                                 ,l_param.lcltelnum
                                 ,l_param.lclcttnom
                                 ,l_ctf00m04.c24lclpdrcod
                                 ,g_documento.crtsaunum
   
      if sqlca.sqlcode <> 0 then
          let l_ret.mensagem = " Erro (",sqlca.sqlcode,") na gravacao do",
                                " endereco datksegsau. AVISE A INFORMATICA!"
          let l_ret.retorno = 06
          rollback work
    
          exit for        
      end if


      #-------------------------------
      # Grava etapas do acompanhamento
      #-------------------------------
      open  cctf00m04007 using l_ctf00m04.atdsrvnum
                              ,l_ctf00m04.atdsrvano
      whenever error continue
      fetch cctf00m04007 into l_ctf00m04.atdsrvseq
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_ret.mensagem = " Erro (",sqlca.sqlcode,") na selecao da",
                               " tabela datmsrvacp. AVISE A INFORMATICA!"
         let l_ret.retorno = 07
         rollback work

         exit for 
      end if

      if l_ctf00m04.atdsrvseq is null then
         let l_ctf00m04.atdsrvseq = 0
      end if


      if l_ctf00m04.atdetpcod is null then

         if l_ctf00m04.atdlibflg = "S" then
            let l_ctf00m04.atdetpcod = 1
         else
            let l_ctf00m04.atdetpcod = 2
         end if
      else

         call cts10g04_insere_etapa(l_ctf00m04.atdsrvnum
                                   ,l_ctf00m04.atdsrvano
                                   ,1
                                   ,""
                                   ,""
                                   ,""
                                   ,"")
              returning l_sqlcode

         whenever error stop

         if l_sqlcode <> 0 then
            let l_ret.mensagem = " Erro (", l_sqlcode, ") na gravacao da",
                                  " etapa de acompanhamento (1)"
            let l_ret.retorno = 08
            rollback work

            exit for
         end if
      end if


      call cts10g04_insere_etapa(l_ctf00m04.atdsrvnum
                                ,l_ctf00m04.atdsrvano
                                ,l_ctf00m04.atdetpcod
                                ,l_ctf00m04.atdprscod
                                ,l_ctf00m04.c24nomctt
                                ,""
                                ,"")
           returning l_sqlcode

      if l_sqlcode <>  0 then
         let l_ret.mensagem = " Erro (", l_sqlcode, ") na gravacao da",
                               " etapa de acompanhamento (2). AVISE A INFORMATICA!"
         let l_ret.retorno = 09 
         rollback work

         exit for
      end if

      if l_ctf00m04.prslocflg = "N" then
         let l_ctf00m04.atdetpcod = null
      end if


      #-----------------
      # Grava servico RE
      #-----------------
      if l_param.acao is null  or 
         l_param.acao =  " "   or 
         l_param.acao <> "RET" then
         let l_param.atdsrvnum    = null
         let l_param.atdsrvano    = null
         let l_param.srvretmtvcod = null
         let l_param.retprsmsmflg = null
         let l_param.orrdat       = l_ctf00m04.data
      end if


      whenever error continue
      execute pctf00m04002 using l_ctf00m04.atdsrvnum
                                ,l_ctf00m04.atdsrvano
                                ,l_ctf00m04.lclrsccod
                                ,l_param.orrdat
                                ,m_param_mult[l_for].socntzcod
                                ,l_param.atdsrvnum
                                ,l_param.atdsrvano
                                ,l_param.srvretmtvcod
                                ,l_param.retprsmsmflg 
                                ,g_documento.lclnumseq 
                                ,g_documento.rmerscseq 
                                ,m_param_mult[l_for].espcod

      whenever error stop
      if sqlca.sqlcode <>  0 then
         let l_ret.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao do",
                               " servico RE. AVISE A INFORMATICA!"
         let l_ret.retorno = 10
         rollback work

         exit for
      end if


      if l_param.srvretmtvcod is not null and
         l_param.srvretmtvcod =  999      then
         whenever error continue


         execute pctf00m04003 using l_ctf00m04.atdsrvnum
                                   ,l_ctf00m04.atdsrvano
                                   ,l_param.srvretmtvdes
                                   ,l_ctf00m04.data
                                   ,g_issk.empcod
                                   ,g_issk.funmat
                                   ,g_issk.usrtip

         whenever error stop
         if sqlca.sqlcode <>  0 then
            let l_ret.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao do",
                                  " Mto.Retorno RE. AVISE A INFORMATICA!"
            let l_ret.retorno = 11
            rollback work

	    exit for
         end if
      end if


      #---------------------------------------
      # Grava relacionamento servico / apolice
      #---------------------------------------
      if g_documento.succod    is not null and
         g_documento.ramcod    is not null and
         g_documento.aplnumdig is not null and   
         g_documento.crtsaunum is null     then

         if g_documento.edsnumref is null then
            let g_documento.edsnumref = 0
         end if


         whenever error continue
         execute pctf00m04004 using l_ctf00m04.atdsrvnum
                                   ,l_ctf00m04.atdsrvano
                                   ,g_documento.succod
                                   ,g_documento.ramcod
                                   ,g_documento.aplnumdig
                                   ,g_documento.itmnumdig
                                   ,g_documento.edsnumref

         whenever error stop
         if sqlca.sqlcode <>  0 then
            let l_ret.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao do",
                                  " relacionamento servico x apolice"
            let l_ret.retorno = 12
            rollback work

	    exit for 
         end if
      end if


      #-------------------------------
      # Aciona Servico automaticamente
      #-------------------------------
      # servico nao sera acionado automaticamente
      if (l_param.acao         = "RET" and 
	  l_param.retprsmsmflg = 'N'            ) or
          l_ctf00m04.veiculo_aciona is not null   then
      else
         #chamar funcao que verifica se acionamento pode ser feito
         # verifica se servico para cidade e internet ou GPS e se esta ativo
         #retorna true para acionamento e false para nao acionamento

         if cts34g00_acion_auto (g_documento.atdsrvorg
                                ,l_param.cidnom
                                ,l_param.ufdcod) then

            if not cts40g12_regras_aciona_auto (g_documento.atdsrvorg
                                               ,l_param.c24astcod
                                               ,""
                                               ,l_ctf00m04.lclltt
                                               ,l_ctf00m04.lcllgt
                                               ,l_ctf00m04.prslocflg
                                               ,l_ctf00m04.frmflg
                                               ,l_ctf00m04.atdsrvnum
                                               ,l_ctf00m04.atdsrvano
                                               ,l_param.acao
                                               ,""
                                               ,"") then
            end if
         end if
      end if


      commit work


      #---------------------------
      # Grava HISTORICO do servico
      #---------------------------
      let l_ctf00m04.histerr = cts10g02_historico( l_ctf00m04.atdsrvnum
                                                  ,l_ctf00m04.atdsrvano
                                                  ,l_ctf00m04.data
                                                  ,l_ctf00m04.hora
                                                  ,g_issk.funmat
                                                  ,l_ctf00m04.hist1   
                                                  ,l_ctf00m04.hist2   
                                                  ,l_ctf00m04.hist3   
                                                  ,l_ctf00m04.hist4   
                                                  ,l_ctf00m04.hist5   )


      #---------------------------------------------------------------------
      # Gravar relacionamento do servico principal com os servicos multiplos
      #---------------------------------------------------------------------
      if l_for > 1 then 

         whenever error continue

         execute pctf00m04005 using l_ctf00m04.atdsrvnum_org
                                   ,l_ctf00m04.atdsrvano_org
                                   ,l_ctf00m04.atdsrvnum
                                   ,l_ctf00m04.atdsrvano
   
         whenever error stop

         if sqlca.sqlcode <>  0 then
            let l_ret.mensagem = " Erro (", sqlca.sqlcode, ") na gravacao da",
                                  " tabela datratdmltsrv. AVISE A INFORMATICA!"
            let l_ret.retorno = 13
            rollback work

            exit for
         end if
      end if
   end for

   --->  Ponto de acesso apos a gravacao do laudo
   call cts00g07_apos_grvlaudo(l_ctf00m04.atdsrvnum,
                               l_ctf00m04.atdsrvano)

   ---> Gera XMl de Erro
   if l_ret.retorno <> 0 then
       
       ## -- Se Assunto for PET mensagem de Retorno devera ser Padrao -- ##
       
       call errorlog(l_ret.mensagem)
       
       if l_param.c24astcod = 'PE1' or
          l_param.c24astcod = 'PE2' then
          if l_ret.retorno <> 14 then
             let l_ret.mensagem = "Sistema indisponivel no momento por favor tente mais tarde"
          end if
       end if 
        
       call ctf00m06_xmlerro (l_servico             
                             ,l_ret.retorno
                             ,l_ret.mensagem)
            returning l_ret.xml  

      return l_ret.xml
   end if
   
   if  l_param.c24astcod == 'PE1' or
       l_param.c24astcod == 'PE2' then
       
       let l_ret.xml =
       "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
      ,"<SERVICO>" ,l_servico clipped, "</SERVICO>"
      ,"<NUMERO_SERVICO>",l_ctf00m04.atdsrvnum clipped,"</NUMERO_SERVICO>"
      ,"<ANO_SERVICO>",l_ctf00m04.atdsrvano  clipped,"</ANO_SERVICO>"
      ,"<LIGACAO>",l_ctf00m04.lignum clipped,"</LIGACAO>"
      ,"<RETORNO>SIM</RETORNO>"
      ,"</RESPONSE>"
      
   else
       
       let l_ret.xml =
           "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
          ,"<SERVICO>" ,l_servico clipped, "</SERVICO>"
          ,"<RETORNO>SIM</RETORNO>"
          ,"</RESPONSE>"
   end if
   
   return l_ret.xml

end function

#-----------------------------------------------------------------------------
function ctf00m04_carrega_servico(l_param)
#-----------------------------------------------------------------------------

   define l_param           record
          socntzcod_01      like datmsrvre.socntzcod
         ,espcod_01         like datmsrvre.espcod
         ,c24pbmcod_01      like datkpbm.c24pbmcod
         ,socntzcod_02      like datmsrvre.socntzcod
         ,espcod_02         like datmsrvre.espcod
         ,c24pbmcod_02      like datkpbm.c24pbmcod
         ,socntzcod_03      like datmsrvre.socntzcod
         ,espcod_03         like datmsrvre.espcod
         ,c24pbmcod_03      like datkpbm.c24pbmcod
         ,socntzcod_04      like datmsrvre.socntzcod
         ,espcod_04         like datmsrvre.espcod
         ,c24pbmcod_04      like datkpbm.c24pbmcod
         ,socntzcod_05      like datmsrvre.socntzcod
         ,espcod_05         like datmsrvre.espcod
         ,c24pbmcod_05      like datkpbm.c24pbmcod
         ,socntzcod_06      like datmsrvre.socntzcod
         ,espcod_06         like datmsrvre.espcod
         ,c24pbmcod_06      like datkpbm.c24pbmcod
         ,socntzcod_07      like datmsrvre.socntzcod
         ,espcod_07         like datmsrvre.espcod
         ,c24pbmcod_07      like datkpbm.c24pbmcod
         ,socntzcod_08      like datmsrvre.socntzcod
         ,espcod_08         like datmsrvre.espcod
         ,c24pbmcod_08      like datkpbm.c24pbmcod
         ,socntzcod_09      like datmsrvre.socntzcod
         ,espcod_09         like datmsrvre.espcod
         ,c24pbmcod_09      like datkpbm.c24pbmcod
         ,socntzcod_10      like datmsrvre.socntzcod
         ,espcod_10         like datmsrvre.espcod
         ,c24pbmcod_10      like datkpbm.c24pbmcod
   end record


   let m_param_mult[1].socntzcod  = l_param.socntzcod_01
   let m_param_mult[1].espcod     = l_param.espcod_01
   let m_param_mult[1].c24pbmcod  = l_param.c24pbmcod_01

   let m_param_mult[2].socntzcod  = l_param.socntzcod_02
   let m_param_mult[2].espcod     = l_param.espcod_02
   let m_param_mult[2].c24pbmcod  = l_param.c24pbmcod_02

   let m_param_mult[3].socntzcod  = l_param.socntzcod_03
   let m_param_mult[3].espcod     = l_param.espcod_03
   let m_param_mult[3].c24pbmcod  = l_param.c24pbmcod_03

   let m_param_mult[4].socntzcod  = l_param.socntzcod_04
   let m_param_mult[4].espcod     = l_param.espcod_04
   let m_param_mult[4].c24pbmcod  = l_param.c24pbmcod_04

   let m_param_mult[5].socntzcod  = l_param.socntzcod_05
   let m_param_mult[5].espcod     = l_param.espcod_05
   let m_param_mult[5].c24pbmcod  = l_param.c24pbmcod_05

   let m_param_mult[6].socntzcod  = l_param.socntzcod_06
   let m_param_mult[6].espcod     = l_param.espcod_06
   let m_param_mult[6].c24pbmcod  = l_param.c24pbmcod_06

   let m_param_mult[7].socntzcod  = l_param.socntzcod_07
   let m_param_mult[7].espcod     = l_param.espcod_07
   let m_param_mult[7].c24pbmcod  = l_param.c24pbmcod_07

   let m_param_mult[8].socntzcod  = l_param.socntzcod_08
   let m_param_mult[8].espcod     = l_param.espcod_08
   let m_param_mult[8].c24pbmcod  = l_param.c24pbmcod_08

   let m_param_mult[9].socntzcod  = l_param.socntzcod_09
   let m_param_mult[9].espcod     = l_param.espcod_09
   let m_param_mult[9].c24pbmcod  = l_param.c24pbmcod_09

   let m_param_mult[10].socntzcod = l_param.socntzcod_10
   let m_param_mult[10].espcod    = l_param.espcod_10
   let m_param_mult[10].c24pbmcod = l_param.c24pbmcod_10

   return

end function

#-----------------------------------------------------------------------------
function ctf00m04_valida_param(l_param)
#-----------------------------------------------------------------------------


   define l_param           record
          c24astcod         like datmligacao.c24astcod
         ,data              date
         ,hora              datetime hour to minute
         ,lgdtip            char(10)
         ,lgdnom            char(50)
         ,lgdnum            integer
         ,brrnom            char(50)
         ,cidnom            like glakcid.cidnom         
         ,ufdcod            like glakcid.ufdcod         
         ,lclrefptotxt      like datmlcl.lclrefptotxt    
         ,endzon            like datmlcl.endzon          
         ,lgdcep            like datmlcl.lgdcep          
         ,lgdcepcmp         like datmlcl.lgdcepcmp       
         ,lclcttnom         like datmlcl.lclcttnom       
         ,dddcod            like datmlcl.dddcod          
         ,lcltelnum         like datmlcl.lcltelnum       
         ,endcmp            like datmlcl.endcmp            #P283688
         ,srvrglcod         like datmsrvrgl.srvrglcod
         ,atdsrvnum         like datmservico.atdsrvnum
         ,atdsrvano         like datmservico.atdsrvano
	 ,acao              char (03)
         ,srvretmtvcod      like datksrvret.srvretmtvcod
         ,srvretmtvdes      like datksrvret.srvretmtvdes 
         ,retprsmsmflg      like datmsrvre.retprsmsmflg
         ,orrdat            like datmsrvre.orrdat        
         ,socntzcod         like datmsrvre.socntzcod
         ,espcod            like datmsrvre.espcod
         ,c24pbmcod         like datkpbm.c24pbmcod
   end record

   define l_ret             record
          retorno           smallint
         ,mensagem          char(500)
         ,xml               char(5000)
   end record

   define l_msg2            char(2800)

   initialize l_ret.*, l_msg2 to null

   let l_ret.retorno = 0

   if g_documento.succod is null or
      g_documento.succod =  0    then
      let l_msg2        = l_msg2 clipped, " SUCURSAL - "
      let l_ret.retorno = 14 
   end if

   if g_documento.ramcod is null or
      g_documento.ramcod =  0    then
      let l_msg2        = l_msg2 clipped, " RAMO - "
      let l_ret.retorno = 14 
   end if

   if g_documento.aplnumdig is null or
      g_documento.aplnumdig =  0    then
      let l_msg2        = l_msg2 clipped, " APOLICE - "
      let l_ret.retorno = 14 
   end if

   if g_documento.itmnumdig is null then
      let l_msg2        = l_msg2 clipped, " ITEM - "
      let l_ret.retorno = 14 
   end if

   if g_documento.edsnumref is null then
      let l_msg2        = l_msg2 clipped, " ENDOSSO - "
      let l_ret.retorno = 14 
   end if

   if l_param.c24astcod is null or
      l_param.c24astcod =  " "  then
      let l_msg2        = l_msg2 clipped, " GRUPO TIPO SERVICO - "
      let l_ret.retorno = 14 
   end if

   if l_param.lgdtip is null or
      l_param.lgdtip =  " "  then
      let l_msg2        = l_msg2 clipped, " TIPO DE LOUGRADOURO - "
      let l_ret.retorno = 14 
   end if

   if l_param.lgdnom is null or
      l_param.lgdnom =  " "  then
      let l_msg2        = l_msg2 clipped, " NOME DO LOUGRADOURO - "
      let l_ret.retorno = 14 
   end if

   if l_param.cidnom is null or
      l_param.cidnom =  " "  then
      let l_msg2        = l_msg2 clipped, " CIDADE - "
      let l_ret.retorno = 14 
   end if

   if l_param.ufdcod is null or
      l_param.ufdcod =  " "  then
      let l_msg2        = l_msg2 clipped, " UF - "
      let l_ret.retorno = 14 
   end if

   if l_param.lgdcep is null or
      l_param.lgdcep =  0    then
      let l_msg2        = l_msg2 clipped, " CEP - "
      let l_ret.retorno = 14 
   end if

   if l_param.lgdcepcmp is null then
      let l_msg2        = l_msg2 clipped, " COMPLEMENTO DE CEP - "
      let l_ret.retorno = 14 
   end if

   if l_param.socntzcod is null or
      l_param.socntzcod =  0    then
      let l_msg2        = l_msg2 clipped, " NATUREZA DO PROBLEMA - "
      let l_ret.retorno = 14 
   end if

   if l_param.c24pbmcod is null or
      l_param.c24pbmcod =  0    then
      let l_msg2        = l_msg2 clipped, " CODIGO DO PROBLEMA - "
      let l_ret.retorno = 14 
   end if

   #-----------------
   # Gera XML de Erro
   #-----------------
   if l_ret.retorno = 14 then
       let l_ret.mensagem = " NAO FORAM INFORMADOS OS SEGUINTES PARAMETROS: " 
                            , l_msg2
   end if

   return l_ret.*   

end function

