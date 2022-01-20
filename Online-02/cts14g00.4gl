###############################################################################
# Nome do Modulo: cts14g00                                           Almeida  #
#                                                                             #
# Funcao dos procedimentos a serem tomados pelos atendentes          Mai/1998 #
# sera chamado por qualquer modulo, passando                                  #
# grupo,assunto,ramo,sucursal,apolice,item,endosso                            #
#                                                                             #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 15/07/1999  PSI 8533-2   Wagner       Incluir checagem das mensagens para   #
#                                       Cidade e UF.                          #
#-----------------------------------------------------------------------------#
# 15/01/2002  MIRIAN       Raji         Incluir checagem das mensagens para   #
#                                       Clausulas de RE.                      #
#-----------------------------------------------------------------------------#
# 25/10/2002  Arnaldo      Raji         Incluir checagem das mensagens para   #
#                                       SUSEP.                                #
#-----------------------------------------------------------------------------#
# 08/05/2003  PSI.168920  Aguinaldo     Resolucao 86                          #
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- --------  -----------------------------------------#
# 20/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.               #
#-----------------------------------------------------------------------------#
# 11/05/09   Amilton, Meta CT        Alteração para tratamento de clausula    #
#                                    dupla 34 e 71                            #
#-----------------------------------------------------------------------------#


globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define a_datmprtprc array[50] of record
   prtprcnum      like datmprtprc.prtprcnum
 end record
 
 define m_sql smallint

 define w_arr        integer
 define l_empcod     like datrprcemp.empcod
 define l_status_emp  smallint
# main
#   call cts14g00 ("S60",31,1,19060110,19,"","","S","2002-10-25 18:00")
#   call cts14g00 ("S10","","","","","SAO PAULO","SP","S","1999-07-21 16:28")
# end main
#-------------------------------------------------------------------------
 function cts14g00_prepare()
#-------------------------------------------------------------------------

define l_sql char(5000)

let l_sql = ' select empcod             '    
          , '   from datrprcemp         '
          , '  where prtcpointcod = ?   '
prepare p_cts14g00_005 from l_sql
declare c_cts14g00_005 cursor with hold for p_cts14g00_005

let l_sql = '  select itaaplvigincdat   '
          , '       , itaaplvigfnldat   '
          , '    from datmitaapl        '
          , '   where itaaplnum  =  ?   '
          , '     and itaciacod  =  ?   '
          , '     and itaramcod  =  ?   '
          , '     and aplseqnum  =  ?   '
prepare p_cts14g00_009 from l_sql
declare c_cts14g00_009 cursor for p_cts14g00_009

let l_sql = '  select corsus   '
          , '    from datmitaapl        '
          , '   where itaaplnum  =  ?   '
          , '     and itaciacod  =  ?   '
          , '     and itaramcod  =  ?   '
          , '     and aplseqnum  =  ?   '
prepare p_cts14g00_010 from l_sql
declare c_cts14g00_010 cursor for p_cts14g00_010

let m_sql = 1

end function

#-----------------------------------------------------------------------
 function cts14g00(param)
#-----------------------------------------------------------------------

 define param     record                        
   c24astcod      like datkassunto.c24astcod,   
   ramcod         like gtakram.ramcod,          
   succod         like abamdoc.succod,          
   aplnumdig      like abamdoc.aplnumdig,       
   itmnumdig      like abbmitem.itmnumdig,      
   cidnom         like datmlcl.cidnom,          
   ufdcod         like datmlcl.ufdcod,          
   smlflg         char(01),                     
   dt_hoje        datetime year to minute       
 end record

 define a_datmprctxt array[100] of record
   prctxtseq      like datmprctxt.prctxtseq,
   prctxt         like datmprctxt.prctxt,
   prtprcnum      like datmprctxt.prtprcnum
 end record

 define ws        record
   cvnnum         like abamapol.cvnnum,
   corsus         like abamcor.corsus,
   c24astagp      like datkassunto.c24astagp,
   ctgtrfcod      like abbmcasco.ctgtrfcod,
   cbtcod         like abbmcasco.cbtcod,
   clalclcod      like abbmdoc.clalclcod,
   prtprcnum      like datmprtprc.prtprcnum,
   prtcpointnom   like dattprt.prtcpointnom,
   clscod         like abbmclaus.clscod,
   clscodant      like abbmclaus.clscod,
   comando        char(650),
   alfa           char(20),
   entrada        char(10),
   saida          char(16),
   cabtxt         char(70),
   primeiro       char(01),
   hoje           datetime year to minute,
   sgrorg         like rsdmdocto.sgrorg,
   sgrnumdig      like rsdmdocto.sgrnumdig,
   prporg         like rsdmlocal.prporg,
   prpnumdig      like rsdmlocal.prpnumdig
 end record

	define	w_pf1	integer

 define w_arr_1      integer
 define w_arr_prctxt integer
 define w_arr_prtprc integer

 let m_sql = 0

 if m_sql <> 1 or
    m_sql is null then
    call cts14g00_prepare()
 end if

 #----------------------------------------------------------------------
 # Inicializa variaveis
 #----------------------------------------------------------------------
#	define	w_pf1	integer
   let l_status_emp = 0
	let	w_arr_1  =  null
	let	w_arr_prctxt  =  null
	let	w_arr_prtprc  =  null

	for	w_pf1  =  1  to  100
		initialize  a_datmprctxt[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_datmprctxt  to null
 initialize ws.*          to null

 let ws.entrada  =  today
 let ws.saida    =  ws.entrada[7,10], "-",
                    ws.entrada[4,5],  "-",
                    ws.entrada[1,2],  " ",
                    time
 let ws.hoje    =  ws.saida

 if param.smlflg  =  "S"   then
    let ws.hoje  =  param.dt_hoje
 end if

 let w_arr  =  1

 if param.smlflg  =  "S"  then
    let ws.comando = " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes <> ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod in ('A','P') ",
                         "and datmprtprc.prtprcexcflg  = 'E' ",
                     " union ",
                     " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes  = ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod in ('A','P') ",
                         "and datmprtprc.prtprcexcflg  = 'R' "
 end if

 if param.smlflg  <> "S"  then
    let ws.comando = " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes <> ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod  = 'A' ",
                         "and datmprtprc.prtprcexcflg  = 'E' ",
                     " union ",
                     " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes  = ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod  = 'A' ",
                         "and datmprtprc.prtprcexcflg  = 'R' "
 end if

 prepare  p_cts14g00_001 from ws.comando
 declare  c_cts14g00_001 cursor for p_cts14g00_001

 #----------------------------------------------------------------------
 # Cria tabela temporaria atender os agrupamentos
 #----------------------------------------------------------------------
 whenever error continue
 create temp table cts14g00 (prtprcnum smallint)  with no log
 if sqlca.sqlcode = -310 or
    sqlca.sqlcode = -958 then
    delete from cts14g00
 end if

 #----------------------------------------------------------------------
 # Cria indice para a tabela temporaria
 #----------------------------------------------------------------------
 create index cts14g00_idx on cts14g00(prtprcnum)
 whenever error stop

 #----------------------------------------------------------------------
 # Procedimentos para o Agrupamento do Assunto
 #----------------------------------------------------------------------
 let l_status_emp = 0
 let ws.prtcpointnom = "c24astagp"

 select c24astagp
   into ws.c24astagp
   from datkassunto
  where c24astcod = param.c24astcod

 open c_cts14g00_001 using ws.prtcpointnom,
                           ws.c24astagp,
                           ws.hoje,
                           ws.hoje,
                           ws.prtcpointnom,
                           ws.c24astagp,
                           ws.hoje,
                           ws.hoje
 
 foreach c_cts14g00_001 into ws.prtprcnum
  
    open c_cts14g00_005 using ws.prtprcnum
    foreach c_cts14g00_005 into l_empcod

        let l_status_emp = 1    #flag = entrou no foreach
      
        if g_documento.ciaempcod = l_empcod then
           call cts14g00_monta_tabela(ws.prtprcnum,
                                   ws.cvnnum,
                                   ws.corsus,
                                   param.ramcod,
                                   param.succod,
                                   ws.clalclcod,
                                   ws.c24astagp,
                                   ws.ctgtrfcod,
                                   ws.cbtcod,
                                   param.c24astcod,
                                   "  ",
                                   param.cidnom,
                                   param.ufdcod,
                                   param.smlflg,
                                   ws.hoje        )        
        else
          continue foreach
        end if 
   
    end foreach
    
    if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)

       call cts14g00_monta_tabela(ws.prtprcnum,
                                   ws.cvnnum,
                                   ws.corsus,
                                   param.ramcod,
                                   param.succod,
                                   ws.clalclcod,
                                   ws.c24astagp,
                                   ws.ctgtrfcod,
                                   ws.cbtcod,
                                   param.c24astcod,
                                   "  ",
                                   param.cidnom,
                                   param.ufdcod,
                                   param.smlflg,
                                   ws.hoje        )    
    else
        let l_status_emp = 0 
    end if
 end foreach

 #----------------------------------------------------------------------
 # Procedimentos para o Assunto
 #----------------------------------------------------------------------
 let ws.prtcpointnom = "c24astcod"
 let l_status_emp = 0
 
 open c_cts14g00_001 using ws.prtcpointnom,
                           param.c24astcod,
                           ws.hoje,
                           ws.hoje,
                           ws.prtcpointnom,
                           param.c24astcod,
                           ws.hoje,
                           ws.hoje

 foreach c_cts14g00_001 into ws.prtprcnum

    open c_cts14g00_005 using ws.prtprcnum
    foreach c_cts14g00_005 into l_empcod

        let l_status_emp = 1    #flag = entrou no foreach
      
        if g_documento.ciaempcod = l_empcod then
           call cts14g00_monta_tabela(ws.prtprcnum,
                                      ws.cvnnum,
                                      ws.corsus,
                                      param.ramcod,
                                      param.succod,
                                      ws.clalclcod,
                                      ws.c24astagp,
                                      ws.ctgtrfcod,
                                      ws.cbtcod,
                                      param.c24astcod,
                                      "  ",
                                      param.cidnom,
                                      param.ufdcod,
                                      param.smlflg,
                                      ws.hoje)       
        else
          continue foreach
        end if 
   
    end foreach
    
    if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
 
         call cts14g00_monta_tabela(ws.prtprcnum,
                                    ws.cvnnum,
                                    ws.corsus,
                                    param.ramcod,
                                    param.succod,
                                    ws.clalclcod,
                                    ws.c24astagp,
                                    ws.ctgtrfcod,
                                    ws.cbtcod,
                                    param.c24astcod,
                                    "  ",
                                    param.cidnom,
                                    param.ufdcod,
                                    param.smlflg,
                                    ws.hoje)   
    else
        let l_status_emp = 0 
    end if

 end foreach

 if param.cidnom is  null and
    param.ufdcod is  null then

    #----------------------------------------------------------------------
    # Procedimentos para o Ramo
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "ramcod"
    let ws.alfa          =  param.ramcod

    open c_cts14g00_001 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_001 into ws.prtprcnum

  
       open c_cts14g00_005 using ws.prtprcnum
       foreach c_cts14g00_005 into l_empcod
     
           let l_status_emp = 1    #flag = entrou no foreach
         
           if g_documento.ciaempcod = l_empcod then
           call cts14g00_monta_tabela(ws.prtprcnum,
                                     ws.cvnnum,
                                     ws.corsus,
                                     param.ramcod,
                                     param.succod,
                                     ws.clalclcod,
                                     ws.c24astagp,
                                     ws.ctgtrfcod,
                                     ws.cbtcod,
                                     param.c24astcod,
                                     "  ",
                                     param.cidnom,
                                     param.ufdcod,
                                     param.smlflg,
                                     ws.hoje)       
           else
             continue foreach
           end if 
      
       end foreach
       
       if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
   
          call cts14g00_monta_tabela(ws.prtprcnum,
                                     ws.cvnnum,
                                     ws.corsus,
                                     param.ramcod,
                                     param.succod,
                                     ws.clalclcod,
                                     ws.c24astagp,
                                     ws.ctgtrfcod,
                                     ws.cbtcod,
                                     param.c24astcod,
                                     "  ",
                                     param.cidnom,
                                     param.ufdcod,
                                     param.smlflg,
                                     ws.hoje)   
       else
           let l_status_emp = 0 
       end if

    end foreach

    #----------------------------------------------------------------------
    # Procedimentos para a Sucursal
    #----------------------------------------------------------------------
    let l_status_emp = 0
    let ws.prtcpointnom  =  "succod"
    let ws.alfa          =  param.succod

    open c_cts14g00_001 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_001 into ws.prtprcnum

        open c_cts14g00_005 using ws.prtprcnum
        foreach c_cts14g00_005 into l_empcod
      
            let l_status_emp = 1    #flag = entrou no foreach
          
            if g_documento.ciaempcod = l_empcod then
               call cts14g00_monta_tabela(ws.prtprcnum,
                                          ws.cvnnum,
                                          ws.corsus,
                                          param.ramcod,
                                          param.succod,
                                          ws.clalclcod,
                                          ws.c24astagp,
                                          ws.ctgtrfcod,
                                          ws.cbtcod,
                                          param.c24astcod,
                                          "  ",
                                          param.cidnom,
                                          param.ufdcod,
                                          param.smlflg,
                                          ws.hoje)      
            else
              continue foreach
            end if 
       
        end foreach
        
        if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
     
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         ws.cvnnum,
                                         ws.corsus,
                                         param.ramcod,
                                         param.succod,
                                         ws.clalclcod,
                                         ws.c24astagp,
                                         ws.ctgtrfcod,
                                         ws.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)  
        else
            let l_status_emp = 0 
        end if
      
    end foreach

    #---------------------------------------------------------------------
    # Procedimentos especificos para apolices de automovel
    #---------------------------------------------------------------------
    if param.ramcod  =  31    or
       param.ramcod  =  531   then

       call f_funapol_ultima_situacao
            (param.succod, param.aplnumdig, param.itmnumdig)
             returning  g_funapol.*

       select cvnnum
         into ws.cvnnum
         from abamapol
        where succod    =  param.succod
          and aplnumdig =  param.aplnumdig

       select corsus
         into ws.corsus
         from abamcor
        where succod     = param.succod
          and aplnumdig  = param.aplnumdig
          and corlidflg  = 'S'

       select clalclcod
         into ws.clalclcod
         from abbmdoc
        where succod     =  param.succod
          and aplnumdig  =  param.aplnumdig
          and itmnumdig  =  param.itmnumdig
          and dctnumseq  =  g_funapol.dctnumseq

       select cbtcod, ctgtrfcod
         into ws.cbtcod, ws.ctgtrfcod
         from abbmcasco
        where succod     =  param.succod
          and aplnumdig  =  param.aplnumdig
          and itmnumdig  =  param.itmnumdig
          and dctnumseq  =  g_funapol.autsitatu

       #------------------------------------------------------------------
       # Procedimentos para o SUSEP
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "corsus"
       let ws.alfa          =  ws.corsus

       open c_cts14g00_001 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_001 into ws.prtprcnum


           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                 call cts14g00_monta_tabela(ws.prtprcnum,
                                            ws.cvnnum,
                                            ws.corsus,
                                            param.ramcod,
                                            param.succod,
                                            ws.clalclcod,
                                            ws.c24astagp,
                                            ws.ctgtrfcod,
                                            ws.cbtcod,
                                            param.c24astcod,
                                            "  ",
                                            param.cidnom,
                                            param.ufdcod,
                                            param.smlflg,
                                            ws.hoje)     
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
                call cts14g00_monta_tabela(ws.prtprcnum,
                                           ws.cvnnum,
                                           ws.corsus,
                                           param.ramcod,
                                           param.succod,
                                           ws.clalclcod,
                                           ws.c24astagp,
                                           ws.ctgtrfcod,
                                           ws.cbtcod,
                                           param.c24astcod,
                                           "  ",
                                           param.cidnom,
                                           param.ufdcod,
                                           param.smlflg,
                                           ws.hoje) 
           else
                let l_status_emp = 0
           end if
         
       end foreach

       #------------------------------------------------------------------
       # Procedimentos para o Convenio
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "cvnnum"
       let ws.alfa          =  ws.cvnnum

       open c_cts14g00_001 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_001 into ws.prtprcnum


           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             ws.cvnnum,
                                             ws.corsus,
                                             param.ramcod,
                                             param.succod,
                                             ws.clalclcod,
                                             ws.c24astagp,
                                             ws.ctgtrfcod,
                                             ws.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)     
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
                 call cts14g00_monta_tabela(ws.prtprcnum,
                                            ws.cvnnum,
                                            ws.corsus,
                                            param.ramcod,
                                            param.succod,
                                            ws.clalclcod,
                                            ws.c24astagp,
                                            ws.ctgtrfcod,
                                            ws.cbtcod,
                                            param.c24astcod,
                                            "  ",
                                            param.cidnom,
                                            param.ufdcod,
                                            param.smlflg,
                                            ws.hoje) 
           else
               let l_status_emp = 0 
           end if
         

         
       end foreach

       #------------------------------------------------------------------
       # Procedimentos para a Classe de localizacao
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "clalclcod"
       let ws.alfa          =  ws.clalclcod

       open c_cts14g00_001 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_001 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             ws.cvnnum,
                                             ws.corsus,
                                             param.ramcod,
                                             param.succod,
                                             ws.clalclcod,
                                             ws.c24astagp,
                                             ws.ctgtrfcod,
                                             ws.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)     
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
                 call cts14g00_monta_tabela(ws.prtprcnum,
                                            ws.cvnnum,
                                            ws.corsus,
                                            param.ramcod,
                                            param.succod,
                                            ws.clalclcod,
                                            ws.c24astagp,
                                            ws.ctgtrfcod,
                                            ws.cbtcod,
                                            param.c24astcod,
                                            "  ",
                                            param.cidnom,
                                            param.ufdcod,
                                            param.smlflg,
                                            ws.hoje) 
           else
                let l_status_emp = 0
           end if
          
       end foreach

       #------------------------------------------------------------------
       # Procedimentos para a Categoria Tarifaria Casco
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "ctgtrfcod"
       let ws.alfa          =  ws.ctgtrfcod

       open c_cts14g00_001 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_001 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             ws.cvnnum,
                                             ws.corsus,
                                             param.ramcod,
                                             param.succod,
                                             ws.clalclcod,
                                             ws.c24astagp,
                                             ws.ctgtrfcod,
                                             ws.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)     
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
                 call cts14g00_monta_tabela(ws.prtprcnum,
                                            ws.cvnnum,
                                            ws.corsus,
                                            param.ramcod,
                                            param.succod,
                                            ws.clalclcod,
                                            ws.c24astagp,
                                            ws.ctgtrfcod,
                                            ws.cbtcod,
                                            param.c24astcod,
                                            "  ",
                                            param.cidnom,
                                            param.ufdcod,
                                            param.smlflg,
                                            ws.hoje) 
           else
                let l_status_emp = 0
           end if

          
       end foreach

       #------------------------------------------------------------------
       # Procedimentos para a Cobertura Casco
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "cbtcod"
       let ws.alfa          =  ws.cbtcod

       open c_cts14g00_001 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_001 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             ws.cvnnum,
                                             ws.corsus,
                                             param.ramcod,
                                             param.succod,
                                             ws.clalclcod,
                                             ws.c24astagp,
                                             ws.ctgtrfcod,
                                             ws.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)     
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         ws.cvnnum,
                                         ws.corsus,
                                         param.ramcod,
                                         param.succod,
                                         ws.clalclcod,
                                         ws.c24astagp,
                                         ws.ctgtrfcod,
                                         ws.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if
          
       end foreach

       #------------------------------------------------------------------
       # Procedimentos para Clausulas
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "clscod"
       declare c_abbmclaus cursor for
         select clscod
           from abbmclaus
          where succod     =  param.succod
            and aplnumdig  =  param.aplnumdig
            and itmnumdig  =  param.itmnumdig
            and dctnumseq  =  g_funapol.dctnumseq

       foreach c_abbmclaus into ws.clscod
          if ws.clscod <> "034" and
             ws.clscod <> "071" then
              let ws.clscodant = ws.clscod
            end if
          if ws.clscod = "034" or
             ws.clscod = "071" or
             ws.clscod = "077" then # PSI 239.399 Clausula 077
           if cta13m00_verifica_clausula(param.succod        ,
                                         param.aplnumdig     ,
                                         param.itmnumdig     ,
                                         g_funapol.dctnumseq ,
                                         ws.clscod           ) then
              let ws.clscod = ws.clscodant
              continue foreach
           end if
          end if
         open c_cts14g00_001 using ws.prtcpointnom,
                                ws.clscod,
                                ws.hoje,
                                ws.hoje,
                                ws.prtcpointnom,
                                ws.clscod,
                                ws.hoje,
                                ws.hoje

         foreach c_cts14g00_001 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                 call cts14g00_monta_tabela(ws.prtprcnum,
                                            ws.cvnnum,
                                            ws.corsus,
                                            param.ramcod,
                                            param.succod,
                                            ws.clalclcod,
                                            ws.c24astagp,
                                            ws.ctgtrfcod,
                                            ws.cbtcod,
                                            param.c24astcod,
                                            ws.clscod,
                                            param.cidnom,
                                            param.ufdcod,
                                            param.smlflg,
                                            ws.hoje)    
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         ws.cvnnum,
                                         ws.corsus,
                                         param.ramcod,
                                         param.succod,
                                         ws.clalclcod,
                                         ws.c24astagp,
                                         ws.ctgtrfcod,
                                         ws.cbtcod,
                                         param.c24astcod,
                                         ws.clscod,
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if


         end foreach
       end foreach

    else
      
       select  sgrorg   , sgrnumdig
         into  ws.sgrorg   , ws.sgrnumdig
         from  rsamseguro
         where succod    = g_documento.succod
           and ramcod    = g_documento.ramcod
           and aplnumdig = g_documento.aplnumdig

       select  prporg   , prpnumdig
         into  ws.prporg   , ws.prpnumdig
         from  rsdmdocto
         where sgrorg    = ws.sgrorg
           and sgrnumdig = ws.sgrnumdig
           and dctnumseq = (select max(dctnumseq)
                              from  rsdmdocto
                               where sgrorg     = ws.sgrorg
                                 and sgrnumdig  = ws.sgrnumdig
                                 and prpstt     in (19,65,66,88))

       if g_documento.lclnumseq is null then
          let g_documento.lclnumseq = 1
       end if

       select corsus
        into ws.corsus
        from rsampcorre
        where sgrorg    = ws.prporg
          and sgrnumdig = ws.prpnumdig
          and corlidflg = 'S'

       #------------------------------------------------------------------
       # Procedimentos para o SUSEP
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "corsus"
       let ws.alfa          =  ws.corsus

       open c_cts14g00_001 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_001 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                 call cts14g00_monta_tabela(ws.prtprcnum,
                                            ws.cvnnum,
                                            ws.corsus,
                                            param.ramcod,
                                            param.succod,
                                            ws.clalclcod,
                                            ws.c24astagp,
                                            ws.ctgtrfcod,
                                            ws.cbtcod,
                                            param.c24astcod,
                                            "  ",
                                            param.cidnom,
                                            param.ufdcod,
                                            param.smlflg,
                                            ws.hoje)    
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         ws.cvnnum,
                                         ws.corsus,
                                         param.ramcod,
                                         param.succod,
                                         ws.clalclcod,
                                         ws.c24astagp,
                                         ws.ctgtrfcod,
                                         ws.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

       end foreach


       #------------------------------------------------------------------
       # Procedimentos para Clausulas
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "clscod"

       declare c_rsdmclaus cursor for
       select clscod
         from rsdmclaus
        where prporg    = ws.prporg
          and prpnumdig = ws.prpnumdig
          and lclnumseq = g_documento.lclnumseq
          and clsstt    = "A"

       foreach c_rsdmclaus into ws.clscod

         open c_cts14g00_001 using ws.prtcpointnom,
                                ws.clscod,
                                ws.hoje,
                                ws.hoje,
                                ws.prtcpointnom,
                                ws.clscod,
                                ws.hoje,
                                ws.hoje

         foreach c_cts14g00_001 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             ws.cvnnum,
                                             ws.corsus,
                                             param.ramcod,
                                             param.succod,
                                             ws.clalclcod,
                                             ws.c24astagp,
                                             ws.ctgtrfcod,
                                             ws.cbtcod,
                                             param.c24astcod,
                                             ws.clscod,
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)    
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         ws.cvnnum,
                                         ws.corsus,
                                         param.ramcod,
                                         param.succod,
                                         ws.clalclcod,
                                         ws.c24astagp,
                                         ws.ctgtrfcod,
                                         ws.cbtcod,
                                         param.c24astcod,
                                         ws.clscod,
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

         end foreach
       end foreach

    end if

 else

    #----------------------------------------------------------------------
    # Procedimentos para a Cidade
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "cidnom"
    let ws.alfa          =  param.cidnom

    open c_cts14g00_001 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_001 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                 call cts14g00_monta_tabela(ws.prtprcnum,
                                            ws.cvnnum,
                                            ws.corsus,
                                            param.ramcod,
                                            param.succod,
                                            ws.clalclcod,
                                            ws.c24astagp,
                                            ws.ctgtrfcod,
                                            ws.cbtcod,
                                            param.c24astcod,
                                            "  ",
                                            param.cidnom,
                                            param.ufdcod,
                                            param.smlflg,
                                            ws.hoje)   
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         ws.cvnnum,
                                         ws.corsus,
                                         param.ramcod,
                                         param.succod,
                                         ws.clalclcod,
                                         ws.c24astagp,
                                         ws.ctgtrfcod,
                                         ws.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if



    end foreach

    #----------------------------------------------------------------------
    # Procedimentos para a UF
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "ufdcod"
    let ws.alfa          =  param.ufdcod

    open c_cts14g00_001 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_001 into ws.prtprcnum


           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             ws.cvnnum,
                                             ws.corsus,
                                             param.ramcod,
                                             param.succod,
                                             ws.clalclcod,
                                             ws.c24astagp,
                                             ws.ctgtrfcod,
                                             ws.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)   
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         ws.cvnnum,
                                         ws.corsus,
                                         param.ramcod,
                                         param.succod,
                                         ws.clalclcod,
                                         ws.c24astagp,
                                         ws.ctgtrfcod,
                                         ws.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

    end foreach
 end if

 if w_arr = 1 then
    return
 end if

 open window w_cts14g00 at 3,5 with form "cts14g00"
      attribute (border,form line 1, message line last)

 let ws.cabtxt = "            ATENCAO - PROCEDIMENTOS PARA ESTE ATENDIMENTO"
 display  ws.cabtxt  to  cabtxt
 message " (F17)Abandona, (F8)Conferencia"

 let w_arr         =  w_arr - 1
 let w_arr_prctxt  =  1

 for i = 1  to  w_arr

    if i > 1 then
       let a_datmprctxt[w_arr_prctxt].prctxt =
           "-----------------------------------------------------------------------------------"
       let w_arr_prctxt = w_arr_prctxt + 1
    end if

    declare c_datmprctxt cursor for
      select prctxtseq, prctxt, prtprcnum
        from datmprctxt
       where prtprcnum = a_datmprtprc[i].prtprcnum

    let ws.primeiro = "S"

    foreach c_datmprctxt into a_datmprctxt[w_arr_prctxt].*

      if ws.primeiro = "S" then
         let ws.primeiro = "N"
      else
         let a_datmprctxt[w_arr_prctxt].prtprcnum = "   "
      end if

      let w_arr_prctxt = w_arr_prctxt + 1
      if w_arr_prctxt  >  100   then
         error " Limite excedido. Atendimento c/ mais de 100 linhas de procedimento!"
         exit foreach
      end if

    end foreach

 end for

 call set_count(w_arr_prctxt - 1)

 display array a_datmprctxt to s_cts14g00.*

   on key (f8)
      let w_arr_1 = arr_curr()
      if a_datmprctxt[w_arr_1].prtprcnum   is null   or
         a_datmprctxt[w_arr_1].prtprcnum   = "  "    then
         error " Conferencia disponivel apenas na primeira linha do texto!"
      else
         call cts14g01(a_datmprctxt[w_arr_1].prtprcnum)
      end if

   on key (interrupt)
      exit display

 end display

 let int_flag = false
 close window w_cts14g00

end function    ###--- cts14g00


#---------------------------------------------------------------------
 function cts14g00_monta_tabela(param)
#---------------------------------------------------------------------

 define param     record
   prtprcnum      like datmprtprc.prtprcnum,
   cvnnum         like abamapol.cvnnum,
   corsus         like abamcor.corsus,
   ramcod         like gtakram.ramcod,
   succod         like abamapol.succod,
   clalclcod      like apbmitem.clalclcod,
   c24astagp      like datkassunto.c24astagp,
   ctgtrfcod      like apbmcasco.ctgtrfcod,
   cbtcod         like apbmcasco.cbtcod,
   c24astcod      like datkassunto.c24astcod,
   clscod         like abbmclaus.clscod,
   cidnom         like datmlcl.cidnom,
   ufdcod         like datmlcl.ufdcod,
   smlflg         char(01),
   dt_hoje        datetime year to minute
 end record

 define w_count   smallint

 if m_sql <> 1 or
    m_sql is null then
    call cts14g00_prepare()
 end if

 #--------------------------------------------------------------------
 # Verifica se ja' atendeu a um campo anterior (ja' inserida)
 #--------------------------------------------------------------------

	let	w_count  =  null

 let w_count = 0

#select count(*)
#  into w_count
#  from cts14g00
# where prtprcnum = param.prtprcnum

#if w_count > 0 then
#   return
#end if

 #--------------------------------------------------------------------
 # Verifica se existe condicao apenas para um campo
 #--------------------------------------------------------------------
 let w_count = 0

 select count(*)
   into w_count
   from datmprtprc
  where prtprcnum  =  param.prtprcnum

 if w_count  >  1   then
    call cts14g00_valida_agrupamento(param.prtprcnum,
                                     param.cvnnum,
                                     param.corsus,
                                     param.ramcod,
                                     param.succod,
                                     param.clalclcod,
                                     param.c24astagp,
                                     param.ctgtrfcod,
                                     param.cbtcod,
                                     param.c24astcod,
                                     param.clscod,
                                     param.cidnom,
                                     param.ufdcod,
                                     param.smlflg,
                                     param.dt_hoje)
 else
    let a_datmprtprc[w_arr].prtprcnum  = param.prtprcnum
    let w_arr = w_arr + 1
 end if

end function    ###--- cts14g00_monta_tabela


#---------------------------------------------------------------------
 function cts14g00_valida_agrupamento (param)
#---------------------------------------------------------------------

 define param     record
   prtprcnum      like datmprtprc.prtprcnum,
   cvnnum         like abamapol.cvnnum,
   corsus         like abamcor.corsus,
   ramcod         like gtakram.ramcod,
   succod         like abamapol.succod,
   clalclcod      like apbmitem.clalclcod,
   c24astagp      like datkassunto.c24astagp,
   ctgtrfcod      like apbmcasco.ctgtrfcod,
   cbtcod         like apbmcasco.cbtcod,
   c24astcod      like datkassunto.c24astcod,
   clscod         like abbmclaus.clscod,
   cidnom         like datmlcl.cidnom,
   ufdcod         like datmlcl.ufdcod,
   smlflg         char(01),
   dt_hoje        datetime year to minute
 end record

 define ws        record
   prtcpointnom   like dattprt.prtcpointnom,
   alfa           char(20)
 end record

 define
    l_count       smallint

	initialize  ws.*  to  null

 initialize  ws.*   to null
 let l_count = 0

 declare c_cts14g00_002 cursor for
   select dattprt.prtcpointnom
     from datmprtprc, dattprt
    where datmprtprc.prtprcnum     =  param.prtprcnum
      and datmprtprc.prtcpointcod  =  dattprt.prtcpointcod

 if m_sql <> 1 or
    m_sql is null then
    call cts14g00_prepare()
 end if

 foreach c_cts14g00_002 into ws.prtcpointnom

    case ws.prtcpointnom
       when  "cvnnum"       let ws.alfa  =  param.cvnnum
       when  "corsus"       let ws.alfa  =  param.corsus
       when  "ramcod"       let ws.alfa  =  param.ramcod
       when  "succod"       let ws.alfa  =  param.succod
       when  "clscod"       let ws.alfa  =  param.clscod
       when  "clalclcod"    let ws.alfa  =  param.clalclcod
       when  "c24astagp"    let ws.alfa  =  param.c24astagp
       when  "ctgtrfcod"    let ws.alfa  =  param.ctgtrfcod
       when  "cbtcod"       let ws.alfa  =  param.cbtcod
       when  "c24astcod"    let ws.alfa  =  param.c24astcod
       when  "cidnom"       let ws.alfa  =  param.cidnom
       when  "ufdcod"       let ws.alfa  =  param.ufdcod
       otherwise            let ws.alfa  =  "      "
    end case

    if param.smlflg  =  "S"   then

      select count(*)
        into l_count
        from datmprtprc, dattprt
       where datmprtprc.prtprcnum     =  param.prtprcnum
         and dattprt.prtcpointnom     =  ws.prtcpointnom
         and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
         and datmprtprc.prtprccntdes  =  ws.alfa
         and viginchordat            <=  param.dt_hoje
         and vigfnlhordat            >=  param.dt_hoje
         and datmprtprc.prtprcsitcod in  ("A","P")
         and datmprtprc.prtprcexcflg  =  "R"

      if l_count = 0  then
           select count(*)
             into l_count
             from datmprtprc, dattprt
            where datmprtprc.prtprcnum    =   param.prtprcnum
              and dattprt.prtcpointnom    =   ws.prtcpointnom
              and dattprt.prtcpointcod    =   datmprtprc.prtcpointcod
              and datmprtprc.prtprccntdes <>  ws.alfa
              and viginchordat            <=  param.dt_hoje
              and vigfnlhordat            >=  param.dt_hoje
              and datmprtprc.prtprcsitcod in  ("A","P")
              and datmprtprc.prtprcexcflg  =  "E"

         if l_count = 0 then
            return
         else
            let l_count = 0
            select count(*)
              into l_count
              from datmprtprc, dattprt
             where datmprtprc.prtprcnum     =  param.prtprcnum
               and dattprt.prtcpointnom     =  ws.prtcpointnom
               and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
               and datmprtprc.prtprccntdes  =  ws.alfa
               and viginchordat            <=  param.dt_hoje
               and vigfnlhordat            >=  param.dt_hoje
               and datmprtprc.prtprcsitcod in  ("A","P")
               and datmprtprc.prtprcexcflg  =  "E"

             if l_count <> 0 then
                return
             end if
          end if
      end if
    else
      select count(*)
        into l_count
        from datmprtprc, dattprt
       where datmprtprc.prtprcnum     =  param.prtprcnum
         and dattprt.prtcpointnom     =  ws.prtcpointnom
         and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
         and datmprtprc.prtprccntdes  =  ws.alfa
         and viginchordat            <=  param.dt_hoje
         and vigfnlhordat            >=  param.dt_hoje
         and datmprtprc.prtprcsitcod  =  "A"
         and datmprtprc.prtprcexcflg  =  "R"

      if l_count = 0 then
         select count(*)
           into l_count
           from datmprtprc,dattprt
          where datmprtprc.prtprcnum     =  param.prtprcnum
            and dattprt.prtcpointnom     =  ws.prtcpointnom
            and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
            and datmprtprc.prtprccntdes  <> ws.alfa
            and viginchordat             <= param.dt_hoje
            and vigfnlhordat             >= param.dt_hoje
            and datmprtprc.prtprcsitcod  =  "A"
            and datmprtprc.prtprcexcflg  =  "E"

         if l_count = 0 then
            return
         else
           select count(*)
             into l_count
             from datmprtprc, dattprt
            where datmprtprc.prtprcnum     =  param.prtprcnum
              and dattprt.prtcpointnom     =  ws.prtcpointnom
              and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
              and datmprtprc.prtprccntdes  =  ws.alfa
              and viginchordat             <= param.dt_hoje
              and vigfnlhordat             >= param.dt_hoje
              and datmprtprc.prtprcsitcod  =  "A"
              and datmprtprc.prtprcexcflg  =  "E"

           if l_count <> 0 then
              return
           end if
         end if
      end if
   end if

 end foreach

 #--------------------------------------------------------------------
 # Insere na tabela para exibir o texto
 #--------------------------------------------------------------------
 let a_datmprtprc[w_arr].prtprcnum  =  param.prtprcnum
 let w_arr = w_arr + 1
 insert into cts14g00(prtprcnum) values (param.prtprcnum)

 end function   ###--- cts14g00_valida_agrupamento

#-----------------------------------------------------------------------
 function cts14g00_proposta(param)
#-----------------------------------------------------------------------

 define param     record
   c24astcod      like datkassunto.c24astcod,
   ramcod         like gtakram.ramcod,
   prporgpcp      like apamcapa.prporgpcp,
   prpnumpcp      like apamcapa.prpnumpcp,
   cidnom         like datmlcl.cidnom,
   ufdcod         like datmlcl.ufdcod,
   smlflg         char(01),
   dt_hoje        datetime year to minute
 end record

 define a_datmprctxt array[100] of record
   prctxtseq      like datmprctxt.prctxtseq,
   prctxt         like datmprctxt.prctxt,
   prtprcnum      like datmprctxt.prtprcnum
 end record

 define ws        record
   cvnnum         like abamapol.cvnnum,
   corsus         like abamcor.corsus,
   c24astagp      like datkassunto.c24astagp,
   ctgtrfcod      like abbmcasco.ctgtrfcod,
   cbtcod         like abbmcasco.cbtcod,
   clalclcod      like abbmdoc.clalclcod,
   prtprcnum      like datmprtprc.prtprcnum,
   prtcpointnom   like dattprt.prtcpointnom,
   clscod         like abbmclaus.clscod,
   clscodant      like abbmclaus.clscod,
   comando        char(650),
   alfa           char(20),
   entrada        char(10),
   saida          char(16),
   cabtxt         char(70),
   primeiro       char(01),
   hoje           datetime year to minute,
   sgrorg         like rsdmdocto.sgrorg,
   sgrnumdig      like rsdmdocto.sgrnumdig,
   prporg         like rsdmlocal.prporg,
   prpnumdig      like rsdmlocal.prpnumdig
 end record
 
 define l_retorno_capa record
        viginc like apamcapa.viginc, 
        vigfnl like apamcapa.vigfnl, 
        succod like apamcapa.succod, 
        prpstt like apamcapa.prpstt,
        sucnom like gabksuc.sucnom,
        aplnumdig like apamcapa.aplnumdig,
        dscstt like iddkdominio.cpodes,
        cvnnum like apamcapa.cvnnum,
        prpqtditm like apamcapa.prpqtditm
 end record
 
 define l_retorno_corr record
          corsus like apamcor.corsus,
          cornom like gcakcorr.cornom
 end record
 
 define l_retorno_cattrf record
          ctgtrfcod like apbmcasco.ctgtrfcod,
          cbtcod    like apbmcasco.cbtcod,
          clcdat    like apbmcasco.clcdat,  
          frqclacod like apbmcasco.frqclacod,
          imsvlr    like apbmcasco.imsvlr   
 end record
 
 
 

 define w_arr_1      integer
 define w_arr_prctxt integer
 define w_arr_prtprc integer


 #----------------------------------------------------------------------
 # Inicializa variaveis
 #----------------------------------------------------------------------

	define	w_pf1	integer

  if m_sql <> 1 or
     m_sql is null then
     call cts14g00_prepare()
  end if

  let l_status_emp = 0
	let	w_arr_1  =  null
	let	w_arr_prctxt  =  null
	let	w_arr_prtprc  =  null

	for	w_pf1  =  1  to  100
		initialize  a_datmprctxt[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_datmprctxt  to null
 initialize ws.*          to null

 let ws.entrada  =  today
 let ws.saida    =  ws.entrada[7,10], "-",
                    ws.entrada[4,5],  "-",
                    ws.entrada[1,2],  " ",
                    time
 let ws.hoje    =  ws.saida

 if param.smlflg  =  "S"   then
    let ws.hoje  =  param.dt_hoje
 end if

 let w_arr  =  1

 if param.smlflg  =  "S"  then
    let ws.comando = " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes <> ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod in ('A','P') ",
                         "and datmprtprc.prtprcexcflg  = 'E' ",
                     " union ",
                     " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes  = ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod in ('A','P') ",
                         "and datmprtprc.prtprcexcflg  = 'R' "
 end if

 if param.smlflg  <> "S"  then
    let ws.comando = " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes <> ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod  = 'A' ",
                         "and datmprtprc.prtprcexcflg  = 'E' ",
                     " union ",
                     " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes  = ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod  = 'A' ",
                         "and datmprtprc.prtprcexcflg  = 'R' "
 end if

 prepare  p_cts14g00_002 from ws.comando
 declare  c_cts14g00_003 cursor for p_cts14g00_002

 #----------------------------------------------------------------------
 # Cria tabela temporaria atender os agrupamentos
 #----------------------------------------------------------------------
 whenever error continue
 create temp table cts14g00 (prtprcnum smallint)  with no log
 if sqlca.sqlcode = -310 or
    sqlca.sqlcode = -958 then
    delete from cts14g00
 end if

 #----------------------------------------------------------------------
 # Cria indice para a tabela temporaria
 #----------------------------------------------------------------------
 create index cts14g00_idx on cts14g00(prtprcnum)
 whenever error stop
 
 if param.cidnom is  null and
    param.ufdcod is  null then
    #----------------------------------------------------------------------
    # Procedimentos para o Ramo
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "ramcod"
    let ws.alfa          =  param.ramcod
         
             
    open c_cts14g00_003 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_003 into ws.prtprcnum
           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)  
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

    end foreach

    #---------------------------------------------------------------------
    # Procedimentos especificos para apolices de automovel
    #---------------------------------------------------------------------
    if param.ramcod  =  31    or
       param.ramcod  =  531   then

       
       call faemc916_capa_proposta(param.prporgpcp, param.prpnumpcp)
          returning l_retorno_capa.*                        
       
       call faemc916_corretor(param.prporgpcp, param.prpnumpcp)  
           returning l_retorno_corr.*                     
       
       call faemc916_categ_tarif(param.prporgpcp, param.prpnumpcp)
       returning l_retorno_cattrf.*    
       
       
       
       #------------------------------------------------------------------
       # Procedimentos para o SUSEP
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "corsus"
       let ws.alfa          =  l_retorno_corr.corsus

       open c_cts14g00_003 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_003 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje) 
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

       end foreach

       #------------------------------------------------------------------
       # Procedimentos para o Convenio
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "cvnnum"
       let ws.alfa          =  l_retorno_capa.cvnnum

       open c_cts14g00_003 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_003 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje) 
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if


       end foreach

       #------------------------------------------------------------------
       # Procedimentos para a Classe de localizacao
       #------------------------------------------------------------------
       #let ws.prtcpointnom  =  "clalclcod"
       #let ws.alfa          =  ws.clalclcod
       #
       #open c_cts14g00_001 using ws.prtcpointnom,
       #                          ws.alfa,
       #                          ws.hoje,
       #                          ws.hoje,
       #                          ws.prtcpointnom,
       #                          ws.alfa,
       #                          ws.hoje,
       #                          ws.hoje
       #
       #foreach c_cts14g00_001 into ws.prtprcnum
       #
       #   call cts14g00_monta_tabela(ws.prtprcnum,
       #                              ws.cvnnum,
       #                              ws.corsus,
       #                              param.ramcod,
       #                              param.succod,
       #                              ws.clalclcod,
       #                              ws.c24astagp,
       #                              ws.ctgtrfcod,
       #                              ws.cbtcod,
       #                              param.c24astcod,
       #                              "  ",
       #                              param.cidnom,
       #                              param.ufdcod,
       #                              param.smlflg,
       #                              ws.hoje)
       #end foreach

       #------------------------------------------------------------------
       # Procedimentos para a Categoria Tarifaria Casco
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "ctgtrfcod"
       let ws.alfa          =  l_retorno_cattrf.ctgtrfcod                                                

       open c_cts14g00_003 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_003 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
              let l_status_emp = 0  
           end if


       end foreach

       #------------------------------------------------------------------
       # Procedimentos para a Cobertura Casco
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "cbtcod"
       let ws.alfa          =  l_retorno_cattrf.cbtcod

       open c_cts14g00_003 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_003 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

       end foreach

       #------------------------------------------------------------------
       # Procedimentos para Clausulas
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "clscod"
       declare c_apbmclaus cursor for
         select clscod 
           from apbmclaus 
          where prporgpcp = param.prporgpcp 
                and prpnumpcp = param.prpnumpcp 
                        
       whenever error continue
       foreach c_apbmclaus into ws.clscod          
         open c_cts14g00_003 using ws.prtcpointnom,
                                ws.clscod,
                                ws.hoje,
                                ws.hoje,
                                ws.prtcpointnom,
                                ws.clscod,
                                ws.hoje,
                                ws.hoje

         foreach c_cts14g00_003 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                            l_retorno_capa.cvnnum,
                                            l_retorno_corr.corsus,  
                                            param.ramcod,
                                            l_retorno_capa.succod,
                                            "",
                                            ws.c24astagp,
                                            l_retorno_cattrf.ctgtrfcod,
                                            l_retorno_cattrf.cbtcod,
                                            param.c24astcod,
                                            "  ",
                                            param.cidnom,
                                            param.ufdcod,
                                            param.smlflg,
                                            ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                        l_retorno_capa.cvnnum,
                                        l_retorno_corr.corsus,  
                                        param.ramcod,
                                        l_retorno_capa.succod,
                                        "",
                                        ws.c24astagp,
                                        l_retorno_cattrf.ctgtrfcod,
                                        l_retorno_cattrf.cbtcod,
                                        param.c24astcod,
                                        "  ",
                                        param.cidnom,
                                        param.ufdcod,
                                        param.smlflg,
                                        ws.hoje)
           else
               let l_status_emp = 0 
           end if


         end foreach
       end foreach    
     whenever error stop  
    end if

 else

    #----------------------------------------------------------------------
    # Procedimentos para a Cidade
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "cidnom"
    let ws.alfa          =  param.cidnom

    open c_cts14g00_003 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_003 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
              let l_status_emp = 0  
           end if


    end foreach

    #----------------------------------------------------------------------
    # Procedimentos para a UF
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "ufdcod"
    let ws.alfa          =  param.ufdcod

    open c_cts14g00_003 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_003 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

    end foreach
 end if

 if w_arr = 1 then
    return
 end if

 open window w_cts14g00 at 3,5 with form "cts14g00"
      attribute (border,form line 1, message line last)

 let ws.cabtxt = "            ATENCAO - PROCEDIMENTOS PARA ESTE ATENDIMENTO"
 display  ws.cabtxt  to  cabtxt
 message " (F17)Abandona, (F8)Conferencia"

 let w_arr         =  w_arr - 1
 let w_arr_prctxt  =  1

 for i = 1  to  w_arr

    if i > 1 then
       let a_datmprctxt[w_arr_prctxt].prctxt =
           "-----------------------------------------------------------------------------------"
       let w_arr_prctxt = w_arr_prctxt + 1
    end if

    declare c_datmprctxt_002 cursor for
      select prctxtseq, prctxt, prtprcnum
        from datmprctxt
       where prtprcnum = a_datmprtprc[i].prtprcnum

    let ws.primeiro = "S"

    foreach c_datmprctxt_002 into a_datmprctxt[w_arr_prctxt].*

      if ws.primeiro = "S" then
         let ws.primeiro = "N"
      else
         let a_datmprctxt[w_arr_prctxt].prtprcnum = "   "
      end if

      let w_arr_prctxt = w_arr_prctxt + 1
      if w_arr_prctxt  >  100   then
         error " Limite excedido. Atendimento c/ mais de 100 linhas de procedimento!"
         exit foreach
      end if

    end foreach

 end for

 call set_count(w_arr_prctxt - 1)

 display array a_datmprctxt to s_cts14g00.*

   on key (f8)
      let w_arr_1 = arr_curr()
      if a_datmprctxt[w_arr_1].prtprcnum   is null   or
         a_datmprctxt[w_arr_1].prtprcnum   = "  "    then
         error " Conferencia disponivel apenas na primeira linha do texto!"
      else
         call cts14g01(a_datmprctxt[w_arr_1].prtprcnum)
      end if

   on key (interrupt)
      exit display

 end display

 let int_flag = false
 close window w_cts14g00

end function    ###--- cts14g00

#-----------------------------------------------------------------------
 function cts14g00_azul(param)
#-----------------------------------------------------------------------
 
define param     record                        
  c24astcod      like datkassunto.c24astcod,   
  ramcod         like gtakram.ramcod,          
  succod         like abamdoc.succod,          
  aplnumdig      like abamdoc.aplnumdig,       
  itmnumdig      like abbmitem.itmnumdig,      
  cidnom         like datmlcl.cidnom,          
  ufdcod         like datmlcl.ufdcod,          
  smlflg         char(01),                     
  dt_hoje        datetime year to minute       
end record                                     


 define a_datmprctxt array[100] of record
   prctxtseq      like datmprctxt.prctxtseq,
   prctxt         like datmprctxt.prctxt,
   prtprcnum      like datmprctxt.prtprcnum
 end record

 define ws        record
   cvnnum         like abamapol.cvnnum,
   corsus         like abamcor.corsus,
   c24astagp      like datkassunto.c24astagp,
   ctgtrfcod      like abbmcasco.ctgtrfcod,
   cbtcod         like abbmcasco.cbtcod,
   clalclcod      like abbmdoc.clalclcod,
   prtprcnum      like datmprtprc.prtprcnum,
   prtcpointnom   like dattprt.prtcpointnom,
   clscod         like abbmclaus.clscod,
   clscodant      like abbmclaus.clscod,
   comando        char(5000),
   alfa           char(20),
   entrada        char(10),
   saida          char(16),
   cabtxt         char(70),
   primeiro       char(01),
   hoje           datetime year to minute,
   sgrorg         like rsdmdocto.sgrorg,
   sgrnumdig      like rsdmdocto.sgrnumdig,
   prporg         like rsdmlocal.prporg,
   prpnumdig      like rsdmlocal.prpnumdig
 end record
 
 define l_retorno_capa record
        viginc like apamcapa.viginc, 
        vigfnl like apamcapa.vigfnl, 
        succod like apamcapa.succod, 
        prpstt like apamcapa.prpstt,
        sucnom like gabksuc.sucnom,
        aplnumdig like apamcapa.aplnumdig,
        dscstt like iddkdominio.cpodes,
        cvnnum like apamcapa.cvnnum,
        prpqtditm like apamcapa.prpqtditm
 end record
 
 define l_retorno_corr record
          corsus like apamcor.corsus,
          cornom like gcakcorr.cornom
 end record
 
 define l_retorno_cattrf record
          ctgtrfcod like apbmcasco.ctgtrfcod,
          cbtcod    like apbmcasco.cbtcod,
          clcdat    like apbmcasco.clcdat,  
          frqclacod like apbmcasco.frqclacod,
          imsvlr    like apbmcasco.imsvlr   
 end record   

 define w_arr_1      integer
 define w_arr_prctxt integer
 define w_arr_prtprc integer
 
 define l_cornom     like gcakcorr.cornom
 define l_corsus     like gcaksusep.corsus
 define l_corteltxt  like gcakfilial.teltxt

 define l_clalclcod      like abbmdoc.clalclcod

 define l_resultado  smallint,
        l_mensagem   char(30),
        l_doc_handle integer

 define l_origem  char(5)
 define l_desc    char(30)
 
 define l_retorno_capacvnnum integer
 
 define l_qtd_end    smallint,
        l_ind        smallint,
        l_aux_char   char(100)
        
 #----------------------------------------------------------------------
 # Inicializa variaveis
 #----------------------------------------------------------------------

	define	w_pf1	integer

  if m_sql <> 1 or
     m_sql is null then
     call cts14g00_prepare()
  end if

  let l_status_emp = 0
	let	w_arr_1  =  null
	let	w_arr_prctxt  =  null
	let	w_arr_prtprc  =  null

	for	w_pf1  =  1  to  100
		initialize  a_datmprctxt[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_datmprctxt  to null
 initialize ws.*          to null
 initialize l_retorno_capacvnnum to null
 
 let ws.entrada  =  today
 let ws.saida    =  ws.entrada[7,10], "-",
                    ws.entrada[4,5],  "-",
                    ws.entrada[1,2],  " ",
                    time
 let ws.hoje    =  ws.saida

 if param.smlflg  =  "S"   then
    let ws.hoje  =  param.dt_hoje
 end if

 let w_arr  =  1

 if param.smlflg  =  "S"  then
    let ws.comando = " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes <> ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod in ('A','P') ",
                         "and datmprtprc.prtprcexcflg  = 'E' ",
                     " union ",
                     " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes  = ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod in ('A','P') ",
                         "and datmprtprc.prtprcexcflg  = 'R' "
 end if

 if param.smlflg  <> "S"  then
    let ws.comando = " select prtprcnum                                       ",
                     "   from datmprtprc, dattprt                             ",
                     "  where dattprt.prtcpointnom     = ?                    ",
                     "    and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                     "    and datmprtprc.prtprccntdes <> ?                    ",
                     "    and viginchordat            <= ?                    ",
                     "    and vigfnlhordat            >= ?                    ",
                     "    and datmprtprc.prtprcsitcod  = 'A'                  ",
                     "    and datmprtprc.prtprcexcflg  = 'E'                  ",
                     " union                                                  ",
                     " select prtprcnum                                       ",
                     "   from datmprtprc, dattprt                             ",
                     "  where dattprt.prtcpointnom     = ?                    ",
                     "    and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                     "    and datmprtprc.prtprccntdes  = ?                    ",
                     "    and viginchordat            <= ?                    ",
                     "    and vigfnlhordat            >= ?                    ",
                     "    and datmprtprc.prtprcsitcod  = 'A'                  ",
                     "    and datmprtprc.prtprcexcflg  = 'R'                  "
 end if

 prepare  p_cts14g00_004 from ws.comando
 declare  c_cts14g00_004 cursor for p_cts14g00_004

 #----------------------------------------------------------------------
 # Cria tabela temporaria atender os agrupamentos
 #----------------------------------------------------------------------
 whenever error continue
 create temp table cts14g00 (prtprcnum smallint)  with no log
 if sqlca.sqlcode = -310 or
    sqlca.sqlcode = -958 then
    delete from cts14g00
 end if

 #----------------------------------------------------------------------
 # Cria indice para a tabela temporaria
 #----------------------------------------------------------------------
 create index cts14g00_idx on cts14g00(prtprcnum)
 whenever error stop
 
 if param.cidnom is  null and
    param.ufdcod is  null then
    

    #---------------------------------------------------------------------
    # Procedimentos especificos para apolices de automovel
    #---------------------------------------------------------------------
    if param.ramcod  =  31    or
       param.ramcod  =  531   then

        call cts42g00_doc_handle(g_documento.succod,
                                  g_documento.ramcod,
                                  g_documento.aplnumdig,
                                  g_documento.itmnumdig,
                                  g_documento.edsnumref)
        returning l_resultado, l_mensagem, l_doc_handle
      
         call cts38m00_extrai_vigencia(l_doc_handle)
          returning l_retorno_capa.viginc,
                    l_retorno_capa.vigfnl
       
       call cts40g02_extraiDoXML(l_doc_handle,
                               'SUCURSAL')
         returning l_retorno_capa.succod,
                   l_retorno_capa.sucnom
                   
       call cts38m00_extrai_origemcalculo(l_doc_handle)                    
          returning l_origem,l_desc                   
          
       if l_origem = '02' then 
          let l_retorno_capacvnnum = 105
       end if     
       
       #353    #corsus
       call cts38m00_extrai_dados_corr(l_doc_handle)
           returning  l_cornom    ## nao usado
                   ,  l_corsus
                   ,  l_corteltxt ## nao usado
       let ws.corsus = l_corsus
       
       #360   #clalclcod
       call cts38m00_extrai_classe_localizacao(l_doc_handle)
           returning l_clalclcod
       
       let ws.clalclcod = l_clalclcod
              
       #368 #cbtcod, ctgtrfcod 
       call cts38m00_extrai_categoria(l_doc_handle)
            returning l_retorno_cattrf.ctgtrfcod
  

    #----------------------------------------------------------------------
    # Procedimentos para o Ramo
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "ramcod"
    let ws.alfa          =  param.ramcod
            
    open c_cts14g00_004 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_004 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               #else
               #  continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
              let l_status_emp = 0  
           end if

    end foreach

       
       #------------------------------------------------------------------
       # Procedimentos para o SUSEP
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "corsus"
       let ws.alfa          =  ws.corsus

       open c_cts14g00_004 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_004 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capacvnnum,
                                             ws.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capacvnnum,
                                         ws.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

       end foreach

       #------------------------------------------------------------------
       # Procedimentos para o Convenio
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "cvnnum"
       let ws.alfa          =  l_retorno_capacvnnum

       open c_cts14g00_004 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_004 into ws.prtprcnum


           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capacvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capacvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

       end foreach

       #------------------------------------------------------------------
       # Procedimentos para a Classe de localizacao
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "clalclcod"
       let ws.alfa          =  ws.clalclcod

       open c_cts14g00_004 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje
       
       foreach c_cts14g00_004 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capacvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capacvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if

       end foreach

       #------------------------------------------------------------------
       # Procedimentos para a Categoria Tarifaria Casco
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "ctgtrfcod"
       let ws.alfa          =  l_retorno_cattrf.ctgtrfcod                                                

       open c_cts14g00_004 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_004 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capacvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capacvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if
       end foreach

#       #------------------------------------------------------------------
#       # Procedimentos para a Cobertura Casco
#       #------------------------------------------------------------------
#       let ws.prtcpointnom  =  "cbtcod"
#       let ws.alfa          =  l_retorno_cattrf.cbtcod
#
#       open c_cts14g00_004 using ws.prtcpointnom,
#                                 ws.alfa,
#                                 ws.hoje,
#                                 ws.hoje,
#                                 ws.prtcpointnom,
#                                 ws.alfa,
#                                 ws.hoje,
#                                 ws.hoje
#
#       foreach c_cts14g00_004 into ws.prtprcnum
#
#          call cts14g00_monta_tabela(ws.prtprcnum,
#                                     l_retorno_capa.cvnnum,
#                                     l_retorno_corr.corsus,  
#                                     param.ramcod,
#                                     l_retorno_capa.succod,
#                                     "",
#                                     ws.c24astagp,
#                                     l_retorno_cattrf.ctgtrfcod,
#                                     l_retorno_cattrf.cbtcod,
#                                     param.c24astcod,
#                                     "  ",
#                                     param.cidnom,
#                                     param.ufdcod,
#                                     param.smlflg,
#                                     ws.hoje)
#       end foreach

       #------------------------------------------------------------------
       # Procedimentos para Clausulas
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "clscod"
       
      let l_qtd_end = figrc011_xpath(l_doc_handle,"count(/APOLICE/CLAUSULAS/CLAUSULA)")

      for l_ind = 1 to l_qtd_end

         let l_aux_char = "/APOLICE/CLAUSULAS/CLAUSULA[", l_ind using "<<<<&","]/CODIGO"
         let ws.clscod = figrc011_xpath(l_doc_handle,l_aux_char)

         open c_cts14g00_004 using ws.prtcpointnom,
                                ws.clscod,
                                ws.hoje,
                                ws.hoje,
                                ws.prtcpointnom,
                                ws.clscod,
                                ws.hoje,
                                ws.hoje

         foreach c_cts14g00_004 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capacvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capacvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if
         end foreach
       end for   
    end if

 else

    #----------------------------------------------------------------------
    # Procedimentos para a Cidade
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "cidnom"
    let ws.alfa          =  param.cidnom

    open c_cts14g00_004 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_004 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capacvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capacvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
               let l_status_emp = 0 
           end if
    end foreach

    #----------------------------------------------------------------------
    # Procedimentos para a UF
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "ufdcod"
    let ws.alfa          =  param.ufdcod

    open c_cts14g00_004 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_004 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             l_retorno_capacvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             l_retorno_cattrf.ctgtrfcod,
                                             l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         l_retorno_capacvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         l_retorno_cattrf.ctgtrfcod,
                                         l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
              let l_status_emp = 0  
           end if
    end foreach
 end if

 if w_arr = 1 then
    return
 end if

 open window w_cts14g00 at 3,5 with form "cts14g00"
      attribute (border,form line 1, message line last)

 let ws.cabtxt = "            ATENCAO - PROCEDIMENTOS PARA ESTE ATENDIMENTO"
 display  ws.cabtxt  to  cabtxt
 message " (F17)Abandona, (F8)Conferencia"

 let w_arr         =  w_arr - 1
 let w_arr_prctxt  =  1

 for i = 1  to  w_arr

    if i > 1 then
       let a_datmprctxt[w_arr_prctxt].prctxt =
           "-----------------------------------------------------------------------------------"
       let w_arr_prctxt = w_arr_prctxt + 1
    end if

    declare c_datmprctxt_004 cursor for
      select prctxtseq, prctxt, prtprcnum
        from datmprctxt
       where prtprcnum = a_datmprtprc[i].prtprcnum

    let ws.primeiro = "S"

    foreach c_datmprctxt_004 into a_datmprctxt[w_arr_prctxt].*

      if ws.primeiro = "S" then
         let ws.primeiro = "N"
      else
         let a_datmprctxt[w_arr_prctxt].prtprcnum = "   "
      end if

      let w_arr_prctxt = w_arr_prctxt + 1
      if w_arr_prctxt  >  100   then
         error " Limite excedido. Atendimento c/ mais de 100 linhas de procedimento!"
         exit foreach
      end if  

    end foreach

 end for 

 call set_count(w_arr_prctxt - 1)

 display array a_datmprctxt to s_cts14g00.*

   on key (f8)
      let w_arr_1 = arr_curr()
      if a_datmprctxt[w_arr_1].prtprcnum   is null   or
         a_datmprctxt[w_arr_1].prtprcnum   = "  "    then
         error " Conferencia disponivel apenas na primeira linha do texto!"
      else
         call cts14g01(a_datmprctxt[w_arr_1].prtprcnum)
      end if

   on key (interrupt)
      exit display

 end display

 let int_flag = false
 close window w_cts14g00

end function    ###--- cts14g00

#-----------------------------------------------------------------------
 function cts14g00_itau(param) 
#-----------------------------------------------------------------------
 
define param     record                        
  c24astcod      like datkassunto.c24astcod,   
  ramcod         like gtakram.ramcod,          
  succod         like abamdoc.succod,          
  aplnumdig      like abamdoc.aplnumdig,       
  itmnumdig      like abbmitem.itmnumdig,      
  cidnom         like datmlcl.cidnom,          
  ufdcod         like datmlcl.ufdcod,          
  smlflg         char(01),                     
  dt_hoje        datetime year to minute       
end record                                     


 define a_datmprctxt array[100] of record
   prctxtseq      like datmprctxt.prctxtseq,
   prctxt         like datmprctxt.prctxt,
   prtprcnum      like datmprctxt.prtprcnum
 end record

 define ws        record
   cvnnum         like abamapol.cvnnum,
   corsus         like abamcor.corsus,
   c24astagp      like datkassunto.c24astagp,
   ctgtrfcod      like abbmcasco.ctgtrfcod,
   cbtcod         like abbmcasco.cbtcod,
   clalclcod      like abbmdoc.clalclcod,
   prtprcnum      like datmprtprc.prtprcnum,
   prtcpointnom   like dattprt.prtcpointnom,
   clscod         like abbmclaus.clscod,
   clscodant      like abbmclaus.clscod,
   comando        char(5000),
   alfa           char(20),
   entrada        char(10),
   saida          char(16),
   cabtxt         char(70),
   primeiro       char(01),
   hoje           datetime year to minute,
   sgrorg         like rsdmdocto.sgrorg,
   sgrnumdig      like rsdmdocto.sgrnumdig,
   prporg         like rsdmlocal.prporg,
   prpnumdig      like rsdmlocal.prpnumdig
 end record
 
 define l_retorno_capa record
        viginc like apamcapa.viginc, 
        vigfnl like apamcapa.vigfnl, 
        succod like apamcapa.succod, 
        prpstt like apamcapa.prpstt,
        sucnom like gabksuc.sucnom,
        aplnumdig like apamcapa.aplnumdig,
        dscstt like iddkdominio.cpodes,
        cvnnum like apamcapa.cvnnum,
        prpqtditm like apamcapa.prpqtditm
 end record
 
 define l_retorno_corr record
          corsus like apamcor.corsus,
          cornom like gcakcorr.cornom
 end record
 
 define l_retorno_cattrf record
          ctgtrfcod like apbmcasco.ctgtrfcod,
          cbtcod    like apbmcasco.cbtcod,
          clcdat    like apbmcasco.clcdat,  
          frqclacod like apbmcasco.frqclacod,
          imsvlr    like apbmcasco.imsvlr   
 end record   

 define w_arr_1      integer
 define w_arr_prctxt integer
 define w_arr_prtprc integer
 
 define l_cornom     like gcakcorr.cornom
 define l_corsus     like gcaksusep.corsus
 define l_corteltxt  like gcakfilial.teltxt

 define l_clalclcod      like abbmdoc.clalclcod

 define l_resultado  smallint,
        l_mensagem   char(30),
        l_doc_handle integer

 define l_origem  char(5)
 define l_desc    char(30)
 
 define l_retorno_capacvnnum integer
 
 define l_qtd_end    smallint,
        l_ind        smallint,
        l_aux_char   char(100)
        
 #----------------------------------------------------------------------
 # Inicializa variaveis
 #----------------------------------------------------------------------

	define	w_pf1	integer

  if m_sql <> 1 or
     m_sql is null then
     call cts14g00_prepare()
  end if

  let l_status_emp = 0
	let	w_arr_1  =  null
	let	w_arr_prctxt  =  null
	let	w_arr_prtprc  =  null

	for	w_pf1  =  1  to  100
		initialize  a_datmprctxt[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_datmprctxt  to null
 initialize ws.*          to null
 initialize l_retorno_capacvnnum to null
 
 let ws.entrada  =  today
 let ws.saida    =  ws.entrada[7,10], "-",
                    ws.entrada[4,5],  "-",
                    ws.entrada[1,2],  " ",
                    time
 let ws.hoje    =  ws.saida

 if param.smlflg  =  "S"   then
    let ws.hoje  =  param.dt_hoje
 end if

 let w_arr  =  1

 if param.smlflg  =  "S"  then
    let ws.comando = " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes <> ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod in ('A','P') ",
                         "and datmprtprc.prtprcexcflg  = 'E' ",
                     " union ",
                     " select prtprcnum ",
                       " from datmprtprc, dattprt ",
                       "where dattprt.prtcpointnom     = ? ",
                         "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                         "and datmprtprc.prtprccntdes  = ? ",
                         "and viginchordat            <= ? ",
                         "and vigfnlhordat            >= ? ",
                         "and datmprtprc.prtprcsitcod in ('A','P') ",
                         "and datmprtprc.prtprcexcflg  = 'R' "
 end if

 if param.smlflg  <> "S"  then
    let ws.comando = " select prtprcnum                                       ",
                     "   from datmprtprc, dattprt                             ",
                     "  where dattprt.prtcpointnom     = ?                    ",
                     "    and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                     "    and datmprtprc.prtprccntdes <> ?                    ",
                     "    and viginchordat            <= ?                    ",
                     "    and vigfnlhordat            >= ?                    ",
                     "    and datmprtprc.prtprcsitcod  = 'A'                  ",
                     "    and datmprtprc.prtprcexcflg  = 'E'                  ",
                     " union                                                  ",
                     " select prtprcnum                                       ",
                     "   from datmprtprc, dattprt                             ",
                     "  where dattprt.prtcpointnom     = ?                    ",
                     "    and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                     "    and datmprtprc.prtprccntdes  = ?                    ",
                     "    and viginchordat            <= ?                    ",
                     "    and vigfnlhordat            >= ?                    ",
                     "    and datmprtprc.prtprcsitcod  = 'A'                  ",
                     "    and datmprtprc.prtprcexcflg  = 'R'                  "
 end if

 prepare  p_cts14g00_006 from ws.comando
 declare  c_cts14g00_006 cursor for p_cts14g00_006

 #----------------------------------------------------------------------
 # Cria tabela temporaria atender os agrupamentos
 #----------------------------------------------------------------------
 whenever error continue
 create temp table cts14g00 (prtprcnum smallint)  with no log
 if sqlca.sqlcode = -310 or
    sqlca.sqlcode = -958 then
    delete from cts14g00
 end if

 #----------------------------------------------------------------------
 # Cria indice para a tabela temporaria
 #----------------------------------------------------------------------
 create index cts14g00_idx on cts14g00(prtprcnum)
 whenever error stop
 
 if param.cidnom is  null and
    param.ufdcod is  null then
    

    #---------------------------------------------------------------------
    # Procedimentos especificos para apolices de automovel
    #---------------------------------------------------------------------
    if param.ramcod  =  31 then



#define param     record                        
#  c24astcod      like datkassunto.c24astcod,   
#  ramcod         like gtakram.ramcod,          
#  succod         like abamdoc.succod,          
#  aplnumdig      like abamdoc.aplnumdig,       
#  itmnumdig      like abbmitem.itmnumdig,      
#  cidnom         like datmlcl.cidnom,          
#  ufdcod         like datmlcl.ufdcod,          
#  smlflg         char(01),                     
#  dt_hoje        datetime year to minute       
#end record                                     


     # Vigencia  
        whenever error continue
          open c_cts14g00_009 using g_documento.aplnumdig 
                                  , g_documento.itaciacod   
                                  , g_documento.ramcod   
                                  , g_documento.itmnumdig   
          fetch c_cts14g00_009 into l_retorno_capa.viginc
                                  , l_retorno_capa.vigfnl
        whenever error stop

     # Sucursal 
            let l_retorno_capa.succod = g_documento.succod
           #l_retorno_capa.sucnom
                    
     # Corsus    
        whenever error continue
          open c_cts14g00_010 using g_documento.aplnumdig 
                                  , g_documento.itaciacod   
                                  , g_documento.ramcod   
                                  , g_documento.itmnumdig   
          fetch c_cts14g00_010 into ws.corsus
        whenever error stop
        let l_retorno_corr.corsus = ws.corsus
       
     # Categoria Tarifada
#          call cts38m00_extrai_categoria(l_doc_handle)
#            returning l_retorno_cattrf.ctgtrfcod              
       
    #----------------------------------------------------------------------
    # Procedimentos para o Ramo
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "ramcod"
    let ws.alfa          =  param.ramcod
            
    open c_cts14g00_006 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_006 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             "",  #l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             "", #l_retorno_cattrf.ctgtrfcod,
                                             "", #l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               end if 
          
           end foreach
           
           if l_status_emp = 0   then    # flag = nao entrou no foreach (nao existe registro)
              call cts14g00_monta_tabela(ws.prtprcnum,
                                         "",  #l_retorno_capa.cvnnum,
                                         l_retorno_corr.corsus,  
                                         param.ramcod,
                                         l_retorno_capa.succod,
                                         "",
                                         ws.c24astagp,
                                         "", #l_retorno_cattrf.ctgtrfcod,
                                         "", #l_retorno_cattrf.cbtcod,
                                         param.c24astcod,
                                         "  ",
                                         param.cidnom,
                                         param.ufdcod,
                                         param.smlflg,
                                         ws.hoje)
           else
              let l_status_emp = 0  
           end if

    end foreach

       
       #------------------------------------------------------------------
       # Procedimentos para o SUSEP
       #------------------------------------------------------------------
       let ws.prtcpointnom  =  "corsus"
       let ws.alfa          =  ws.corsus

       open c_cts14g00_006 using ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje,
                                 ws.prtcpointnom,
                                 ws.alfa,
                                 ws.hoje,
                                 ws.hoje

       foreach c_cts14g00_006 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             "",  #l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             "", #l_retorno_cattrf.ctgtrfcod,
                                             "", #l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             "",  #l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             "", #l_retorno_cattrf.ctgtrfcod,
                                             "", #l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
           else
               let l_status_emp = 0 
           end if

       end foreach

    end if

 else

    #----------------------------------------------------------------------
    # Procedimentos para a Cidade
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "cidnom"
    let ws.alfa          =  param.cidnom

    open c_cts14g00_006 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_006 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             "",  #l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             "", #l_retorno_cattrf.ctgtrfcod,
                                             "", #l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
        
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             "",  #l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             "", #l_retorno_cattrf.ctgtrfcod,
                                             "", #l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
           else
               let l_status_emp = 0 
           end if
    end foreach

    #----------------------------------------------------------------------
    # Procedimentos para a UF
    #----------------------------------------------------------------------
    let ws.prtcpointnom  =  "ufdcod"
    let ws.alfa          =  param.ufdcod

    open c_cts14g00_006 using ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje,
                              ws.prtcpointnom,
                              ws.alfa,
                              ws.hoje,
                              ws.hoje

    foreach c_cts14g00_006 into ws.prtprcnum

           open c_cts14g00_005 using ws.prtprcnum
           foreach c_cts14g00_005 into l_empcod
         
               let l_status_emp = 1    #flag = entrou no foreach
             
               if g_documento.ciaempcod = l_empcod then
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             "",  #l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             "", #l_retorno_cattrf.ctgtrfcod,
                                             "", #l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
               else
                 continue foreach
               end if 
          
           end foreach
           
           if l_status_emp = 0           then  # flag = nao entrou no foreach (nao existe registro)
       
                  call cts14g00_monta_tabela(ws.prtprcnum,
                                             "",  #l_retorno_capa.cvnnum,
                                             l_retorno_corr.corsus,  
                                             param.ramcod,
                                             l_retorno_capa.succod,
                                             "",
                                             ws.c24astagp,
                                             "", #l_retorno_cattrf.ctgtrfcod,
                                             "", #l_retorno_cattrf.cbtcod,
                                             param.c24astcod,
                                             "  ",
                                             param.cidnom,
                                             param.ufdcod,
                                             param.smlflg,
                                             ws.hoje)
           else
               let l_status_emp = 0 
           end if
    end foreach
 end if

 if w_arr = 1 then
    return
 end if

 open window w_cts14g00 at 3,5 with form "cts14g00"
      attribute (border,form line 1, message line last)

 let ws.cabtxt = "            ATENCAO - PROCEDIMENTOS PARA ESTE ATENDIMENTO"
 display  ws.cabtxt  to  cabtxt
 message " (F17)Abandona, (F8)Conferencia"

 let w_arr         =  w_arr - 1
 let w_arr_prctxt  =  1

 for i = 1  to  w_arr

    if i > 1 then
       let a_datmprctxt[w_arr_prctxt].prctxt =
           "-----------------------------------------------------------------------------------"
       let w_arr_prctxt = w_arr_prctxt + 1
    end if

    declare c_datmprctxt_005 cursor for
      select prctxtseq, prctxt, prtprcnum
        from datmprctxt
       where prtprcnum = a_datmprtprc[i].prtprcnum

    let ws.primeiro = "S"

    foreach c_datmprctxt_005 into a_datmprctxt[w_arr_prctxt].*

      if ws.primeiro = "S" then
         let ws.primeiro = "N"
      else
         let a_datmprctxt[w_arr_prctxt].prtprcnum = "   "
      end if

      let w_arr_prctxt = w_arr_prctxt + 1
      if w_arr_prctxt  >  100   then
         error " Limite excedido. Atendimento c/ mais de 100 linhas de procedimento!"
         exit foreach
      end if  

    end foreach

 end for

 call set_count(w_arr_prctxt - 1)

 display array a_datmprctxt to s_cts14g00.*

   on key (f8)
      let w_arr_1 = arr_curr()
      if a_datmprctxt[w_arr_1].prtprcnum   is null   or
         a_datmprctxt[w_arr_1].prtprcnum   = "  "    then
         error " Conferencia disponivel apenas na primeira linha do texto!"
      else
         call cts14g01(a_datmprctxt[w_arr_1].prtprcnum)
      end if

   on key (interrupt)
      exit display

 end display

 let int_flag = false
 close window w_cts14g00
 
 end function 	




