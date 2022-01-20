###############################################################################a
# Sistea  r CTS      - Central 24 Horas                            JULHO/2008 #
# Programa :                                                                   #
# Modulo   : cty05g10 - Registrar Servicos                                     #
# Analista : Amilton Pinto                                                    #
# PSI      :                                                                   #
# Liberacao:                                                                   #
#------------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                             #
#------------------------------------------------------------------------------#
# DATA       RESPONSAVEL     PSI     DESCRICAO                                 #
#------------------------------------------------------------------------------#
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
function cty05g10_prepara()
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
   prepare pcty05g10001 from l_sql


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
   prepare pcty05g10002 from l_sql

   let l_sql = ' insert into datmsrvretexc '
                           ,'(atdsrvnum '
                           ,',atdsrvano '
                           ,',srvretexcdes '
                           ,',caddat '
                           ,',cademp '
                           ,',cadmat '
                           ,',cadusrtip) '
                           ,'values (?,?,?,?,?,?,?) '
   prepare pcty05g10003 from l_sql

   let l_sql = ' insert into datrservapol '
                          ,'(atdsrvnum '
                          ,',atdsrvano '
                          ,',succod '
                          ,',ramcod '
                          ,',aplnumdig '
                          ,',itmnumdig '
                          ,',edsnumref ) '
                          ,' values (?,?,?,?,?,?,?) '
   prepare pcty05g10004 from l_sql

   let l_sql = ' insert into datratdmltsrv '
                          ,'(atdsrvnum '
                          ,',atdsrvano '
                          ,',atdmltsrvnum '
                          ,',atdmltsrvano ) '
                          ,' values (?,?,?,?) '
   prepare pcty05g10005 from l_sql

   let l_sql = ' select c24pbmdes '
              ,'   from datkpbm ' 
              ,'  where c24pbmcod = ?'
   prepare pcty05g10006 from l_sql
   declare ccty05g10006 cursor with hold for pcty05g10006

   let l_sql = ' select max(atdsrvseq) '
              ,'   from datmsrvacp '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
   prepare pcty05g10007 from l_sql
   declare ccty05g10007 cursor  with hold for pcty05g10007
   
   let l_sql = ' select atddfttxt '
              ,'   from datmservico '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
   prepare pcty05g10008 from l_sql
   declare ccty05g10008 cursor  with hold for pcty05g10008  
   
   let l_sql = " select lclnumseq, "
              ," rmerscseq "
              ," from datmrsclcllig "
              ," where lignum = ? "
   prepare pcty05g10009 from l_sql
   declare ccty05g10009 cursor  with hold for pcty05g10009   
    

end function 


#-----------------------------------------------------------------------------
function cty05g10_grava_dados(l_param,l_param_multiplos)
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


   define l_cty05g10        record
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

   define l_ret             record
          retorno           smallint
         ,mensagem          char(500)
         ,xml               char(5000)
   end record
   
   define l_lignum like datmligacao.lignum 


   initialize l_ret.* , l_servico
	     ,l_cty05g10.* to null
	 #initialize l_param_multiplos.* to null    
	     
   

   let l_ret.retorno           = 0    ---> Registro Incluido / <> 0 Problema
   let l_for                   = 0
   let l_cty05g10.atdlibflg    = "S" 
   let l_cty05g10.atdfnlflg    = "N" 
   let l_cty05g10.asitipcod    = 6   
   let l_cty05g10.atdprinvlcod = 2    ---> Normal   
   let l_cty05g10.prslocflg    = 'N'  ---> Prestador no Local  
   let l_cty05g10.operacao     = 'I'    
   let l_cty05g10.frmflg       = 'N'  ---> Entrada via Formulario  
   let l_cty05g10.hist1        = 'ATENDIMENTO VIA PORTAL DE VOZ' 
   let l_cty05g10.atdpvtretflg = 'N'

   ## -- Atendimento inicializa como NAO LIBERADO para o SISTEMA PET -- ##
   
   if  l_param.c24astcod = 'PE1' or
       l_param.c24astcod = 'PE2' then
       let l_cty05g10.atdlibflg    = "N" 
   end if
   
   #-----------------
   # Prepara Comandos
   #-----------------
   call cty05g10_prepara()            
   
   let l_lignum = cts20g00_servico(l_param.atdsrvnum
                                  ,l_param.atdsrvano)
                                          
      
      display "g_documento.lclnumseq = ",g_documento.lclnumseq
      display "g_documento.rmerscseq = ",g_documento.rmerscseq
      display "l_lignum = ",l_lignum
                            
      
      whenever error continue 
      open ccty05g10009 using l_lignum 
      fetch ccty05g10009 into g_documento.lclnumseq,
                              g_documento.rmerscseq
      whenever error stop                                     
      
      display "sqlca.sqlcode = ",sqlca.sqlcode
      if sqlca.sqlcode <> 0 then 
         let g_documento.lclnumseq = null 
         let g_documento.rmerscseq = null 
      end if  
      
    display "339 - g_documento.lclnumseq = ",g_documento.lclnumseq   
    display "340 - g_documento.rmerscseq = ",g_documento.rmerscseq 
                                             
   #----------------------
   # Trata Nome do Servico
   #----------------------
   display "l_param.acao = ",l_param.acao
   if l_param.acao = "RET" then
      let l_servico = "REGISTRAR_RETORNO_SERVICO"
   else
      let l_servico = "REGISTRAR_SERVICOS"
   end if


   #-----------------------------
   # Valida Parametros de Entrada
   #-----------------------------
   if l_param.acao <> "RET" then
      call cty05g10_valida_param(l_param.*
                                ,l_param_multiplos.socntzcod_01
                                ,l_param_multiplos.espcod_01
                                ,l_param_multiplos.c24pbmcod_01 )
           returning l_ret.*
   end if
   
   display "l_ret.retorno = ",l_ret.retorno                                                
   
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


 


   #--------------------------
   # Carrega Servicos no Array 
   #--------------------------
   call cty05g10_carrega_servico(l_param_multiplos.*)


   #-----------------------------------
   # Carrega Susep/Nome e Nome Segurado
   #-----------------------------------
   if g_documento.ramcod = 31   or
      g_documento.ramcod = 531  then

      call cts05g00 (g_documento.succod   
                    ,g_documento.ramcod   
                    ,g_documento.aplnumdig
                    ,g_documento.itmnumdig)
           returning l_cty05g10.nom      
                    ,l_cty05g10.corsus  
                    ,l_cty05g10.cornom   
                    ,l_cty05g10.cvnnom   
                    ,l_cty05g10.vclcoddig        
                    ,l_cty05g10.vcldes           
                    ,l_cty05g10.vclanomdl        
                    ,l_cty05g10.vcllicnum        
                    ,l_cty05g10.vclchsinc        
                    ,l_cty05g10.vclchsfnl        
                    ,l_cty05g10.vclcordes

   else

      call cts05g01 (g_documento.succod   
                    ,g_documento.ramcod   
                    ,g_documento.aplnumdig)
           returning l_cty05g10.nom
                    ,l_cty05g10.cornom
                    ,l_cty05g10.corsus
                    ,l_cty05g10.cvnnom
                    ,l_cty05g10.viginc
                    ,l_cty05g10.vigfnl
   end if

   #------------
   # Data / Hora
   #------------
   call cts40g03_data_hora_banco(2) 
        returning l_cty05g10.data
                 ,l_cty05g10.hora

 
   #-----------------------------------
   # Carrega Coordenadas de Localizacao
   #-----------------------------------
   call ctx32g00_buscaCoordenadas(l_param.lgdtip
                                 ,l_param.lgdnom
                                 ,l_param.lgdnum
                                 ,l_param.brrnom
                                 ,l_param.cidnom
                                 ,l_param.ufdcod )
        returning l_cty05g10.lcllgt
                 ,l_cty05g10.lclltt
                 ,l_cty05g10.c24lclpdrcod

   ## -- Servico PET nao precisa de agendamento -- ##

   display "l_cty05g10.lcllgt = ",l_cty05g10.lcllgt
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
       
          begin work
       
          display "ctc59m03 = ",l_param.cidnom       
          display "ctc59m03 = ",l_param.ufdcod       
          display "ctc59m03 = ",g_documento.atdsrvorg
          display "ctc59m03 = ",l_param.srvrglcod    
          display "ctc59m03 = ",l_param.data         
          display "ctc59m03 = ",l_param.hora        
                    
          call ctc59m03_reserva(l_param.cidnom
                               ,l_param.ufdcod
                               ,g_documento.atdsrvorg
                               ,l_param.srvrglcod
                               ,l_param.data  
                               ,l_param.hora)  
               returning l_sqlcode
       
          display "l_sqlcode = ",l_sqlcode
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
   display "grava dados"
   for l_for = 1 to 10
    
      display " m_param_mult[l_for].socntzcod = ",m_param_mult[l_for].socntzcod
      if m_param_mult[l_for].socntzcod is null then         
         exit for
      end if

      #----------------------
      # Descricao do Problema
      #----------------------
      open  ccty05g10006 using m_param_mult[l_for].c24pbmcod
      fetch ccty05g10006 into  l_cty05g10.atddfttxt
                  

      display "484 - l_cty05g10.atddfttxt = ",l_cty05g10.atddfttxt
      
      if l_cty05g10.atddfttxt is null and  
         l_cty05g10.atddfttxt = " " then
         open ccty05g10008 using l_param.atdsrvnum,
                                 l_param.atdsrvano 
         fetch ccty05g10008 into l_cty05g10.atddfttxt
      end if    
      
      
      display "493 - l_cty05g10.atddfttxt = ",l_cty05g10.atddfttxt
      
      #------------
      # Data / Hora
      #------------
      call cts40g03_data_hora_banco(2) 
           returning l_cty05g10.data
                    ,l_cty05g10.hora
            
      #------------------------------------------------------------------------------ 
      # Verifica Se o Endereco de Ocorrencia e o Mesmo de Residencia                  
      #------------------------------------------------------------------------------ 
                                                                                      
      if g_documento.lclocodesres = "S" then                                          
         let l_cty05g10.atdrsdflg = "S"                                               
      else                                                                            
         let l_cty05g10.atdrsdflg = "N"                                               
      end if
                  
      begin work

      #----------------------------------
      # Busca numeracao ligacao / servico
      #----------------------------------
      call cts10g03_numeracao(2,"9")
           returning l_cty05g10.lignum
                    ,l_cty05g10.atdsrvnum
                    ,l_cty05g10.atdsrvano
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
            

      let g_documento.lignum    = l_cty05g10.lignum
            
      #-----------------------------------------
      # Guarda o Servico Original (1o. problema)
      # Utilizado quando ha Servicos Multiplos
      #-----------------------------------------
      if l_for = 1 then
         let l_cty05g10.atdsrvnum_org = l_cty05g10.atdsrvnum
         let l_cty05g10.atdsrvano_org = l_cty05g10.atdsrvano
      end if
      
      let g_documento.solnom       = "PORTAL VOZ"

      #-----------------------
      # Grava dados da ligacao 
      #-----------------------
      begin work

      call cts10g00_ligacao ( g_documento.lignum      
                             ,l_cty05g10.data       
                             ,l_cty05g10.hora       
                             ,g_documento.c24soltipcod
                             ,g_documento.solnom     
                             ,l_param.c24astcod     
                             ,g_issk.funmat
                             ,g_documento.ligcvntip   
                             ,g_c24paxnum             
                             ,l_cty05g10.atdsrvnum      
                             ,l_cty05g10.atdsrvano      
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
                             ,l_cty05g10.caddat
                             ,l_cty05g10.cadhor   
                             ,l_cty05g10.cademp
                             ,l_cty05g10.cadmat   )
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
        let l_cty05g10.atdhorpvt = "2:00" 
      else
        let l_cty05g10.atdhorpvt = null    
      end if


      #-----------------------
      # Grava dados do servico 
      #-----------------------
      call cts10g02_grava_servico( l_cty05g10.atdsrvnum
                                  ,l_cty05g10.atdsrvano
                                  ,g_documento.soltip        # atdsoltip
                                  ,g_documento.solnom        # c24solnom
                                  ," "                       # vclcorcod
                                  ,g_issk.funmat
                                  ,l_cty05g10.atdlibflg  
                                  ,l_cty05g10.hora           # atdlibhor
                                  ,l_cty05g10.data           # atdlibdat
                                  ,l_cty05g10.data           # atddat
                                  ,l_cty05g10.hora           # atdhor
                                  ,""                        # atdlclflg
                                  ,l_cty05g10.atdhorpvt    
                                  ,l_param.data              # atddatprg
                                  ,l_param.hora              # atdhorprg
                                  ,"9"                       # atdtip
                                  ,""                        # atdmotnom
                                  ,""                        # atdvclsgl
                                  ,l_cty05g10.atdprscod
                                  ,""                        # atdcstvlr
                                  ,l_cty05g10.atdfnlflg
                                  ,l_cty05g10.hora           # atdfnlhor
                                  ,l_cty05g10.atdrsdflg
                                  ,l_cty05g10.atddfttxt
                                  ,""                        # atddoctxt
                                  ," "                       # c24opemat
                                  ,l_cty05g10.nom      
                                  ,""                        # vcldes
                                  ,""                        # vclanomdl
                                  ,""                        # vcllicnum
                                  ,l_cty05g10.corsus   
                                  ,l_cty05g10.cornom   
                                  ,l_cty05g10.cnldat   
                                  ,""                        # pgtdat
                                  ,l_cty05g10.c24nomctt
                                  ,l_cty05g10.atdpvtretflg
                                  ,""                        # atdvcltip
                                  ,l_cty05g10.asitipcod
                                  ,""                        # socvclcod
                                  ,""                        # vclcoddig
                                  ,"N"                       # srvprlflg
                                  ,""                        # srrcoddig
                                  ,l_cty05g10.atdprinvlcod
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
      
       display "l_cty05g10.atdsrvnum =  ",         l_cty05g10.atdsrvnum
       display "l_cty05g10.atdsrvano =  ",         l_cty05g10.atdsrvano
       display "m_param_mult[l_for].c24pbmcod = ", m_param_mult[l_for].c24pbmcod
       display "707 - l_cty05g10.atddfttxt  = " ,        l_cty05g10.atddfttxt
       
       if m_param_mult[l_for].c24pbmcod = 999 then
         open ccty05g10008 using l_param.atdsrvnum,
                                 l_param.atdsrvano 
         fetch ccty05g10008 into l_cty05g10.atddfttxt
      end if    
      display "714 - l_cty05g10.atddfttxt  = " ,        l_cty05g10.atddfttxt
            
      call ctx09g02_inclui(l_cty05g10.atdsrvnum
                          ,l_cty05g10.atdsrvano
                          ,1                     # Org.Inf -> 1-Segurado 2-Pst
                          ,m_param_mult[l_for].c24pbmcod
                          ,l_cty05g10.atddfttxt
                          ,"" )                  # Codigo prestador
           returning l_sqlcode, l_tabname      
      if l_sqlcode <> 0 then
         let l_ret.mensagem = " Erro (",l_sqlcode,") na gravacao de",
                               " problemas do servico. AVISE A INFORMATICA!"
         display "l_tabname = ",l_tabname
         
         let l_ret.retorno = 04
         rollback work

         exit for        
      end if
      
      #---------------------------
      # Grava locais de ocorrencia
      #---------------------------
      let l_sqlcode = cts06g07_local( l_cty05g10.operacao    
                                     ,l_cty05g10.atdsrvnum      
                                     ,l_cty05g10.atdsrvano     
                                     ,1                         
                                     ,l_cty05g10.lclidttxt   
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
                                     ,l_cty05g10.lclltt      
                                     ,l_cty05g10.lcllgt      
                                     ,l_param.dddcod      
                                     ,l_param.lcltelnum   
                                     ,l_param.lclcttnom   
                                     ,l_cty05g10.c24lclpdrcod
                                     ,l_cty05g10.ofnnumdig
                                     ,l_cty05g10.emeviacod
                                     ,""  # celteldddcod,
                                     ,""  # celtelnum )   
                                     ,"") # Complemento 
      if l_sqlcode <> 0    or  
         l_sqlcode is null then
         let l_ret.mensagem = " Erro (",l_sqlcode,") na gravacao do",
                               " local de ocorrencia. AVISE A INFORMATICA!"
         let l_ret.retorno = 05
         rollback work

         exit for        
      end if
      

      execute pcty05g10001 using  l_param.lgdtip
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
                                 ,l_cty05g10.lclltt
                                 ,l_cty05g10.lcllgt
                                 ,l_param.dddcod
                                 ,l_param.lcltelnum
                                 ,l_param.lclcttnom
                                 ,l_cty05g10.c24lclpdrcod
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
      open  ccty05g10007 using l_cty05g10.atdsrvnum
                              ,l_cty05g10.atdsrvano
      whenever error continue
      fetch ccty05g10007 into l_cty05g10.atdsrvseq
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
         let l_ret.mensagem = " Erro (",sqlca.sqlcode,") na selecao da",
                               " tabela datmsrvacp. AVISE A INFORMATICA!"
         let l_ret.retorno = 07
         rollback work

         exit for 
      end if

      if l_cty05g10.atdsrvseq is null then
         let l_cty05g10.atdsrvseq = 0
      end if


      if l_cty05g10.atdetpcod is null then

         if l_cty05g10.atdlibflg = "S" then
            let l_cty05g10.atdetpcod = 1
         else
            let l_cty05g10.atdetpcod = 2
         end if
      else
         
         call cts10g04_insere_etapa(l_cty05g10.atdsrvnum
                                   ,l_cty05g10.atdsrvano
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


      call cts10g04_insere_etapa(l_cty05g10.atdsrvnum
                                ,l_cty05g10.atdsrvano
                                ,l_cty05g10.atdetpcod
                                ,l_cty05g10.atdprscod
                                ,l_cty05g10.c24nomctt
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

      if l_cty05g10.prslocflg = "N" then
         let l_cty05g10.atdetpcod = null
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
         let l_param.orrdat       = l_cty05g10.data
      end if

      
      whenever error continue
      execute pcty05g10002 using l_cty05g10.atdsrvnum
                                ,l_cty05g10.atdsrvano
                                ,l_cty05g10.lclrsccod
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

      
         execute pcty05g10003 using l_cty05g10.atdsrvnum
                                   ,l_cty05g10.atdsrvano
                                   ,l_param.srvretmtvdes
                                   ,l_cty05g10.data
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
         execute pcty05g10004 using l_cty05g10.atdsrvnum
                                   ,l_cty05g10.atdsrvano
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
          l_cty05g10.veiculo_aciona is not null   then
          
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
                                               ,l_cty05g10.lclltt
                                               ,l_cty05g10.lcllgt
                                               ,l_cty05g10.prslocflg
                                               ,l_cty05g10.frmflg
                                               ,l_cty05g10.atdsrvnum
                                               ,l_cty05g10.atdsrvano
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
      
      let l_cty05g10.histerr = cts10g02_historico( l_cty05g10.atdsrvnum
                                                  ,l_cty05g10.atdsrvano
                                                  ,l_cty05g10.data
                                                  ,l_cty05g10.hora
                                                  ,g_issk.funmat
                                                  ,l_cty05g10.hist1   
                                                  ,l_cty05g10.hist2   
                                                  ,l_cty05g10.hist3   
                                                  ,l_cty05g10.hist4   
                                                  ,l_cty05g10.hist5   )


      
      #---------------------------------------------------------------------
      # Gravar relacionamento do servico principal com os servicos multiplos
      #---------------------------------------------------------------------
      if l_for > 1 then 

         whenever error continue

         execute pcty05g10005 using l_cty05g10.atdsrvnum_org
                                   ,l_cty05g10.atdsrvano_org
                                   ,l_cty05g10.atdsrvnum
                                   ,l_cty05g10.atdsrvano
   
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
   call cts00g07_apos_grvlaudo(l_cty05g10.atdsrvnum,
                               l_cty05g10.atdsrvano)

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
      ,"<NUMERO_SERVICO>",l_cty05g10.atdsrvnum clipped,"</NUMERO_SERVICO>"
      ,"<ANO_SERVICO>",l_cty05g10.atdsrvano  clipped,"</ANO_SERVICO>"
      ,"<LIGACAO>",l_cty05g10.lignum clipped,"</LIGACAO>"
      ,"<RETORNO>SIM</RETORNO>"
      ,"</RESPONSE>"
      
   else
       
       let l_ret.xml =
           "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?><RESPONSE>"
          ,"<SERVICO>",l_servico clipped, "</SERVICO>"
          ,"<NUMERO_SERVICO>",l_cty05g10.atdsrvnum clipped,"</NUMERO_SERVICO>"
          ,"<ANO_SERVICO>",l_cty05g10.atdsrvano  clipped,"</ANO_SERVICO>"                    
          ,"<RETORNO>SIM</RETORNO>"
          ,"</RESPONSE>"
   end if
   
   return l_ret.xml

end function

#-----------------------------------------------------------------------------
function cty05g10_carrega_servico(l_param)
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
function cty05g10_valida_param(l_param)
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

