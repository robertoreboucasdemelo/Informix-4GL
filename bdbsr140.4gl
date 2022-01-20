#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: BDBSR140                                                   #
# ANALISTA RESP..: SERGIO BURINI                                              #
# PSI/OSF........: RELATORIOS HISTORICO DE INDEXACAO                          #
# ........................................................................... #
# DESENVOLVIMENTO: RAMON CUEVAS                                               #
# LIBERACAO......: 16/11/2011                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
#16/11/2011  Ramon Cuevas               Versao Inicial                        #
#22/11/2011  Sergio Burini              Inclusão da Indexação DAF             #
#16/01/2015  Fernando Farias            Execucao Diaria do Relatorio          #
#-----------------------------------------------------------------------------#

database porto	

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_path      char(200)
define m_path_txt  char(200)
define m_data      date

main

    call fun_dba_abre_banco("CT24HS")
    
    let m_data = arg_val(1)
    
    if m_data is null or m_data = " " then
        let m_data = today
    else
        if m_data > today then
            display "*** ERRO NO PARAMETRO: DATA INVALIDA! ***"
            exit program
        end if
    end if         

    let m_data = m_data - 1 units day

    call bdbsr140_path()
    
    call cts40g03_exibe_info("I","BDBSR140")

    call bdbsr140_prepare() 
    
    set isolation to dirty read
    
    call bdbsr140()

    call cts40g03_exibe_info("F","BDBSR140")

end main

#---------------------------#
 function bdbsr140_prepare()
#---------------------------#

     define l_sql char(5000)
     
       let l_sql = "select a.atdsrvnum                                    ",
                  "       , a.atdsrvano                                    ",
                  "       , a.atdetpcod                                    ",
                  "       , a.atdsrvorg                                    ",
                  "       , a.asitipcod                                    ",
                  "       , a.ciaempcod                                    ",
                  "       , a.atddat                                       ",
                  "       , a.atdhor                                       ",
                  "       , b.funmat                                       ",
                  "       , b.empcod                                       ",
                  "       , b.usrtip                                       ",
                  "       , b.srvidxseq                                    ",
                  "       , d.cpodes                                       ",
                  "       , b.lgdtip                                       ",
                  "       , b.lgdnom                                       ",
                  "       , b.lgdnum                                       ",
                  "       , b.brrnom                                       ",
                  "       , b.cidnom                                       ",
                  "       , b.ufdcod                                       ",
                  "   from datmservico   a                                 ",
                  "      , datmsrvidxhst b                                 ",
                  "      , iddkdominio   d                                 ",
                  "  where a.atdsrvnum = b.atdsrvnum                       ",
                  "    and a.atdsrvano = b.atdsrvano                       ",
                  "    and d.cponom    = 'c24lclpdrcod'                    ",
                  "    and d.cpocod    = b.c24lclpdrcod                    ",
                  "    and a.atddat = ?                                    ",
                  "    and a.atdsrvorg in (select cpocod                   ",
                  "                          from iddkdominio              ",
                  "                         where cponom = 'orgrelidxpso') "
           prepare pbdbsr140_04 from l_sql
           declare cbdbsr140_04 cursor for pbdbsr140_04

      ##let l_sql = "select grlinf                     ",
      ##            "  from datkgeral                  ",
      ##            " where grlchv = 'PSOEXERELIDXSMN' "
      ##
      ##   prepare pbdbsr140_01 from l_sql
      ##   declare cbdbsr140_01 cursor for pbdbsr140_01
      ##
      ##let l_sql = "select grlinf                     ",
      ##            "  from datkgeral                  ",
      ##            " where grlchv = 'PSOEXERELIDXMEN' "
      ##
      ##   prepare pbdbsr140_02 from l_sql
      ##   declare cbdbsr140_02 cursor for pbdbsr140_02
      ##
      ##let l_sql = "select cpocod                  ",
      ##            "  from iddkdominio             ",
      ##            " where cponom = 'orgrelidxpso' "
      ##
      ##   prepare pbdbsr140_03 from l_sql
      ##   declare cbdbsr140_03 cursor for pbdbsr140_03
      ##
      ##let l_sql = "select grlinf    ",
      ##            "from datkgeral    ",
      ##		 " where grlchv = 'PSOEXERELIDXDIA' "
      ##
      ##   prepare pbdbsr140_05 from l_sql
      ##   declare cbdbsr140_05 cursor for pbdbsr140_05
      
    #let l_sql = " select lclltt, lcllgt, lclrefptotxt, endcmp                       ", 
     let l_sql = " select lclltt, lcllgt,                                            ",
                 "        replace(replace(replace(lclrefptotxt, chr(13), ''), chr(10), ''), chr(09), ' '),  ",
                 "        replace(replace(replace(endcmp, chr(13), ''), chr(10), ''), chr(09), ' ')         ",
                 "   from datmlcl                                                    ",
     		         "  where atdsrvnum = ?                                              ",
     		         "    and atdsrvano = ?                                              ",
     		         "    and c24endtip = 1                                              "
     prepare pbdbsr140_06 from l_sql
     declare cbdbsr140_06 cursor for pbdbsr140_06
     

 end function
     
#-------------------#
 function bdbsr140()
#-------------------#

   define lr_historico record
       atdsrvnum    like datmservico.atdsrvnum
     , atdsrvano    like datmservico.atdsrvano
     , atdetpcod    like datmservico.atdetpcod
     , atdsrvorg    like datmservico.atdsrvorg
     , asitipcod    like datmservico.asitipcod
     , ciaempcod    like datmservico.ciaempcod
     , atddat       like datmservico.atddat
     , atdhor       like datmservico.atdhor
     , funmat       like datmservico.funmat
     , empcod       like datmservico.empcod
     , usrtip       like datmservico.usrtip
     , srvidxseq    like datmsrvidxhst.srvidxseq
     , c24lclpdrdes char(30)
     , lgdtip       like datmsrvidxhst.lgdtip
     , lgdnom       like datmsrvidxhst.lgdnom
     , lgdnum       like datmsrvidxhst.lgdnum
     , brrnom       like datmsrvidxhst.brrnom
     , cidnom       like datmsrvidxhst.cidnom
     , ufdcod       like datmsrvidxhst.ufdcod
     , idxdaf       char(01)
     , idxdafcmp    char(30)
     , lclltt       like datmlcl.lclltt
     , lcllgt       like datmlcl.lcllgt
     , lclrefptotxt like datmlcl.lclrefptotxt
     , endcmp       like datmlcl.endcmp
   end record

   initialize lr_historico to null

   start report bdbsr140_report to m_path    
   start report bdbsr140_report_txt to m_path_txt
                                                                      
   display 'Consultando historico de ', m_data

   open cbdbsr140_04  using m_data
   foreach cbdbsr140_04 into lr_historico.atdsrvnum
                           , lr_historico.atdsrvano
                           , lr_historico.atdetpcod
                           , lr_historico.atdsrvorg
                           , lr_historico.asitipcod
                           , lr_historico.ciaempcod
                           , lr_historico.atddat
                           , lr_historico.atdhor
                           , lr_historico.funmat
                           , lr_historico.empcod
                           , lr_historico.usrtip
                           , lr_historico.srvidxseq
                           , lr_historico.c24lclpdrdes
                           , lr_historico.lgdtip
                           , lr_historico.lgdnom
                           , lr_historico.lgdnum
                           , lr_historico.brrnom
                           , lr_historico.cidnom
                           , lr_historico.ufdcod
                           
          open cbdbsr140_06 using lr_historico.atdsrvnum
                                , lr_historico.atdsrvano 
          fetch cbdbsr140_06 into lr_historico.lclltt
                                ,lr_historico.lcllgt      
                                ,lr_historico.lclrefptotxt
                                ,lr_historico.endcmp      
                             
                             
       output to report bdbsr140_report(lr_historico.atdsrvnum
                                      , lr_historico.atdsrvano
                                      , lr_historico.atdetpcod
                                      , lr_historico.atdsrvorg
                                      , lr_historico.asitipcod
                                      , lr_historico.ciaempcod
                                      , lr_historico.atddat
                                      , lr_historico.atdhor
                                      , lr_historico.funmat
                                      , lr_historico.empcod
                                      , lr_historico.usrtip
                                      , lr_historico.srvidxseq
                                      , lr_historico.c24lclpdrdes
                                      , lr_historico.lgdtip
                                      , lr_historico.lgdnom
                                      , lr_historico.lgdnum
                                      , lr_historico.brrnom
                                      , lr_historico.cidnom
                                      , lr_historico.ufdcod
                                      , lr_historico.idxdaf   
                                      , lr_historico.idxdafcmp
                                      , lr_historico.lclltt
                                      , lr_historico.lcllgt
                                      , lr_historico.lclrefptotxt
                                      , lr_historico.endcmp)
                                      
       output to report bdbsr140_report_txt(lr_historico.atdsrvnum
                                      , lr_historico.atdsrvano
                                      , lr_historico.atdetpcod
                                      , lr_historico.atdsrvorg
                                      , lr_historico.asitipcod
                                      , lr_historico.ciaempcod
                                      , lr_historico.atddat
                                      , lr_historico.atdhor
                                      , lr_historico.funmat
                                      , lr_historico.empcod
                                      , lr_historico.usrtip
                                      , lr_historico.srvidxseq
                                      , lr_historico.c24lclpdrdes
                                      , lr_historico.lgdtip
                                      , lr_historico.lgdnom
                                      , lr_historico.lgdnum
                                      , lr_historico.brrnom
                                      , lr_historico.cidnom
                                      , lr_historico.ufdcod
                                      , lr_historico.idxdaf   
                                      , lr_historico.idxdafcmp
                                      , lr_historico.lclltt
                                      , lr_historico.lcllgt
                                      , lr_historico.lclrefptotxt
                                      , lr_historico.endcmp)
                                      
                                      
   end foreach
   close cbdbsr140_04

   finish report bdbsr140_report
   finish report bdbsr140_report_txt
   
   call bdbsr140_envia_email()
      
   end function
   
   
 #----------------------------------#    
 function bdbsr140_envia_email()
 #----------------------------------#   
 
 define l_retorno smallint 
 define l_assunto char(200)
 define l_comando char(100)
 
 let l_assunto = null
 let l_comando = null
 let l_retorno = null       

  display 'Compactando arquivo...'
 
 let l_assunto = 'Relatorio de historico de indexacao: ', m_data

 let l_comando = "gzip -f ", m_path 
 run l_comando  
 
 let m_path = m_path clipped, ".gz"
 display "m_path: ", m_path

 display 'Enviando e-mail...'

 let l_retorno = ctx22g00_envia_email("BDBSR140", l_assunto, m_path)
 
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro ao enviar email(ctx22g00) - ", m_path
       else
          display "Nao existe email cadastrado para o modulo - BDBSR140"
       end if
    end if

end function

#------------------------#
 function bdbsr140_path()
#------------------------#

  define l_dataarq char(8)
  
  let l_dataarq = extend(m_data, year to year),
                  extend(m_data, month to month),
                  extend(m_data, day to day)

  let m_path = f_path("DBS","RELATO")

  if  m_path is null then
       let m_path = "."
  end if
  
  display "m_path: ", m_path
 
  let m_path_txt = m_path clipped
  let m_path  = m_path clipped, "/BDBSR140", l_dataarq, ".xls"   
  let m_path_txt = m_path_txt clipped, "/BDBSR140", l_dataarq, ".txt"   

 end function

#------------------------------------#
 report bdbsr140_report(lr_historico)
#------------------------------------#

   define lr_historico record
       atdsrvnum    like datmservico.atdsrvnum
     , atdsrvano    like datmservico.atdsrvano
     , atdetpcod    like datmservico.atdetpcod
     , atdsrvorg    like datmservico.atdsrvorg
     , asitipcod    like datmservico.asitipcod
     , ciaempcod    like datmservico.ciaempcod
     , atddat       like datmservico.atddat
     , atdhor       like datmservico.atdhor
     , funmat       like datmservico.funmat
     , empcod       like datmservico.empcod
     , usrtip       like datmservico.usrtip
     , srvidxseq    like datmsrvidxhst.srvidxseq
     , c24lclpdrdes char(30)
     , lgdtip       like datmsrvidxhst.lgdtip
     , lgdnom       like datmsrvidxhst.lgdnom
     , lgdnum       like datmsrvidxhst.lgdnum
     , brrnom       like datmsrvidxhst.brrnom
     , cidnom       like datmsrvidxhst.cidnom
     , ufdcod       like datmsrvidxhst.ufdcod
     , idxdaf       char(01)
     , idxdafcmp    char(30)  
     , lclltt       like datmlcl.lclltt
     , lcllgt       like datmlcl.lcllgt
     , lclrefptotxt like datmlcl.lclrefptotxt   
     , endcmp       like datmlcl.endcmp    
   end record

   output
       left margin 0
       right margin 0
       top margin 0
       bottom margin 0

   format
       first page header
           print
               'Numero_do_servico',                  ASCII(09),
               'Ano_do_servico',                     ASCII(09),
               'Ultima_etapa_do_servico',            ASCII(09),
               'Origem_do_servico',                  ASCII(09),
               'Tipo_assistencia_do_servico',        ASCII(09),
               'Empresa_do_servico',                 ASCII(09),
               'Data_de_atendimento_do_servico',     ASCII(09),
               'Hora_atendimento_do_servico',        ASCII(09),
               'Matricula_do_agente_do_servico',     ASCII(09),
               'Empresa_do_agente_do_servico',       ASCII(09),
               'Tipo_do_agente_do_servico',          ASCII(09),
               'Sequencia_da_alteracao_do_endereco', ASCII(09),
               'Tipo_de_indexacao_do_servico',       ASCII(09),
               'Daf_veiculo_atendido',               ASCII(09),
               'Tipo_indexacao_daf',                 ASCII(09),
               'Tipo_do_logradouro_do_servico',      ASCII(09),
               'Logradouro_do_servico' ,             ASCII(09),
               'Numero_do_logradouro',               ASCII(09),
               'Bairro_do_logradouro',               ASCII(09),
               'Cidade_do_logradouro',               ASCII(09),
               'UF_do_logradouro',                   ASCII(09),
               'Latitude',                           ASCII(09),
               'Longitude',                          ASCII(09),
               'Referencia',                         ASCII(09),
               'Complemento',                        ASCII(09)
       on every row
           print
               lr_historico.atdsrvnum clipped,    ASCII(09),
               lr_historico.atdsrvano clipped,    ASCII(09),
               lr_historico.atdetpcod clipped,    ASCII(09),
               lr_historico.atdsrvorg clipped,    ASCII(09),
               lr_historico.asitipcod clipped,    ASCII(09),
               lr_historico.ciaempcod clipped,    ASCII(09),
               lr_historico.atddat clipped,       ASCII(09),
               lr_historico.atdhor clipped,       ASCII(09),
               lr_historico.funmat clipped,       ASCII(09),
               lr_historico.empcod clipped,       ASCII(09),
               lr_historico.usrtip clipped,       ASCII(09),
               lr_historico.srvidxseq clipped,    ASCII(09),
               lr_historico.c24lclpdrdes clipped, ASCII(09);
          
          let lr_historico.idxdafcmp = 'NAO SE APLICA'
          
          whenever error continue   
            select 1 
              from dpcmdafidxsrvhst 
             where atdsrvnum = lr_historico.atdsrvnum 
               and atdsrvano = lr_historico.atdsrvano 
               and srvhstseq = 1
          whenever error stop

          if  sqlca.sqlcode = 0 then   
              
              let lr_historico.idxdaf = 'S'
              
              whenever error continue
                select dom.cpodes                    
                  into lr_historico.idxdafcmp
                  from dpcmdafidxsrvhst hst,         
                       iddkdominio      dom          
                 where hst.atdsrvnum = lr_historico.atdsrvnum      
                   and hst.atdsrvano = lr_historico.atdsrvano      
                   and hst.srvhstseq <> 1            
                   and dom.cponom    = 'srvhstseqdaf'
                   and hst.srvhstseq = dom.cpocod    
              whenever error stop
              
          else    
              let lr_historico.idxdaf = 'N'
          end if
              
              
          print lr_historico.idxdaf         clipped,       ASCII(09),         
                lr_historico.idxdafcmp      clipped,       ASCII(09),
                lr_historico.lgdtip         clipped,       ASCII(09),
                lr_historico.lgdnom         clipped,       ASCII(09),
                lr_historico.lgdnum         clipped,       ASCII(09),
                lr_historico.brrnom         clipped,       ASCII(09),
                lr_historico.cidnom         clipped,       ASCII(09),
                lr_historico.ufdcod         clipped,       ASCII(09),
                lr_historico.lclltt         clipped,       ASCII(09),
                lr_historico.lcllgt         clipped,       ASCII(09),
                lr_historico.lclrefptotxt   clipped,       ASCII(09),
                lr_historico.endcmp         clipped,       ASCII(13)

       
 end report

#------------------------------------#
 report bdbsr140_report_txt(lr_historico)
#------------------------------------#

   define lr_historico record
       atdsrvnum    like datmservico.atdsrvnum
     , atdsrvano    like datmservico.atdsrvano
     , atdetpcod    like datmservico.atdetpcod
     , atdsrvorg    like datmservico.atdsrvorg
     , asitipcod    like datmservico.asitipcod
     , ciaempcod    like datmservico.ciaempcod
     , atddat       like datmservico.atddat
     , atdhor       like datmservico.atdhor
     , funmat       like datmservico.funmat
     , empcod       like datmservico.empcod
     , usrtip       like datmservico.usrtip
     , srvidxseq    like datmsrvidxhst.srvidxseq
     , c24lclpdrdes char(30)
     , lgdtip       like datmsrvidxhst.lgdtip
     , lgdnom       like datmsrvidxhst.lgdnom
     , lgdnum       like datmsrvidxhst.lgdnum
     , brrnom       like datmsrvidxhst.brrnom
     , cidnom       like datmsrvidxhst.cidnom
     , ufdcod       like datmsrvidxhst.ufdcod
     , idxdaf       char(01)
     , idxdafcmp    char(30)  
     , lclltt       like datmlcl.lclltt
     , lcllgt       like datmlcl.lcllgt
     , lclrefptotxt like datmlcl.lclrefptotxt   
     , endcmp       like datmlcl.endcmp    
   end record

  output
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00
    page length    01 

  format

       on every row
           print
               lr_historico.atdsrvnum clipped,    ASCII(09),
               lr_historico.atdsrvano clipped,    ASCII(09),
               lr_historico.atdetpcod clipped,    ASCII(09),
               lr_historico.atdsrvorg clipped,    ASCII(09),
               lr_historico.asitipcod clipped,    ASCII(09),
               lr_historico.ciaempcod clipped,    ASCII(09),
               lr_historico.atddat clipped,       ASCII(09),
               lr_historico.atdhor clipped,       ASCII(09),
               lr_historico.funmat clipped,       ASCII(09),
               lr_historico.empcod clipped,       ASCII(09),
               lr_historico.usrtip clipped,       ASCII(09),
               lr_historico.srvidxseq clipped,    ASCII(09),
               lr_historico.c24lclpdrdes clipped, ASCII(09);
          
          let lr_historico.idxdafcmp = 'NAO SE APLICA'
          
          whenever error continue   
            select 1 
              from dpcmdafidxsrvhst 
             where atdsrvnum = lr_historico.atdsrvnum 
               and atdsrvano = lr_historico.atdsrvano 
               and srvhstseq = 1
          whenever error stop

          if  sqlca.sqlcode = 0 then   
              
              let lr_historico.idxdaf = 'S'
              
              whenever error continue
                select dom.cpodes                    
                  into lr_historico.idxdafcmp
                  from dpcmdafidxsrvhst hst,         
                       iddkdominio      dom          
                 where hst.atdsrvnum = lr_historico.atdsrvnum      
                   and hst.atdsrvano = lr_historico.atdsrvano      
                   and hst.srvhstseq <> 1            
                   and dom.cponom    = 'srvhstseqdaf'
                   and hst.srvhstseq = dom.cpocod    
              whenever error stop
              
          else    
              let lr_historico.idxdaf = 'N'
          end if
              
              
          print lr_historico.idxdaf         clipped,       ASCII(09),         
                lr_historico.idxdafcmp      clipped,       ASCII(09),
                lr_historico.lgdtip         clipped,       ASCII(09),
                lr_historico.lgdnom         clipped,       ASCII(09),
                lr_historico.lgdnum         clipped,       ASCII(09),
                lr_historico.brrnom         clipped,       ASCII(09),
                lr_historico.cidnom         clipped,       ASCII(09),
                lr_historico.ufdcod         clipped,       ASCII(09),
                lr_historico.lclltt         clipped,       ASCII(09),
                lr_historico.lcllgt         clipped,       ASCII(09),
                lr_historico.lclrefptotxt   clipped,       ASCII(09),
                lr_historico.endcmp         clipped 

       
 end report