#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: BDBSR141                                                   #
# ANALISTA RESP..: SERGIO BURINI                                              #
# PSI/OSF........: RELATORIOS DIVERGENCIAS DE ENDERECO INDEXADO X DAF         #
# ........................................................................... #
# DESENVOLVIMENTO: RAMON CUEVAS                                               #
# LIBERACAO......: 18/11/2011                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
#18/11/2011  Ramon Cuevas               Versao Inicial                        #
#-----------------------------------------------------------------------------#

database porto	

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_path char(200)

main

    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read
    
    call bdbsr141_path()
    call cts40g03_exibe_info("I","BDBSR141")

    call bdbsr141_prepare()
    call bdbsr141()

    call cts40g03_exibe_info("F","BDBSR141")

end main

#---------------------------#
 function bdbsr141_prepare()
#---------------------------#

     define l_sql char(5000)

     let l_sql = "select grlinf                     ",
                 "  from datkgeral                  ",
                 " where grlchv = 'PSOEXERELDAFSMN' "

     prepare pbdbsr141_01 from l_sql
     declare cbdbsr141_01 cursor for pbdbsr141_01

     let l_sql = "select grlinf                  ",
                 "  from datkgeral               ",
                 " where grlchv = 'PSODSTSRVDAF' "

     prepare pbdbsr141_02 from l_sql
     declare cbdbsr141_02 cursor for pbdbsr141_02

     let l_sql = "select a.atdsrvnum               ",
                 "     , a.atdsrvano               ",
                 "     , a.vcllicnum               ",
                 "     , a.atddat                  ",
                 "     , a.atdhor                  ",
                 "     , b.succod                  ",
                 "     , b.aplnumdig               ",
                 "     , b.itmnumdig               ",
                 "     , c.endlgdtip               ",
                 "     , c.endlgd                  ",
                 "     , c.endlgdnum               ",
                 "     , c.endbrrnom               ",
                 "     , c.ciddes                  ",
                 "     , c.ufdcod                  ",
                 "     , c.lclltt                  ",
                 "     , c.lcllgt                  ",
                 "  from datmservico a             ",
                 "     , datrservapol b            ",
                 "     , dpcmdafidxsrvhst c        ",
                 " where a.atdsrvnum = b.atdsrvnum ",
                 "   and a.atdsrvano = b.atdsrvano ",
                 "   and a.atdsrvnum = c.atdsrvnum ",
                 "   and a.atdsrvano = c.atdsrvano ",
                 "   and c.srvhstseq = 1           ",
                 "   and a.atddat between ? and ?  "

     prepare pbdbsr141_03 from l_sql
     declare cbdbsr141_03 cursor for pbdbsr141_03

     let l_sql = "select vclchsinc     ",
                 "     , vclchsfnl     ",
                 "  from abbmveic      ",
                 " where succod = ?    ",
                 "   and aplnumdig = ? ",
                 "   and itmnumdig = ? "

     prepare pbdbsr141_04 from l_sql
     declare cbdbsr141_04 cursor for pbdbsr141_04

     let l_sql = "select endlgdtip               ",
                 "     , endlgd                  ",
                 "     , endlgdnum               ",
                 "     , endbrrnom               ",
                 "     , ciddes                  ",
                 "     , ufdcod                  ",
                 "     , lclltt                  ",
                 "     , lcllgt                  ",
                 "  from dpcmdafidxsrvhst        ",
                 " where srvhstseq <> 1          ",
                 "   and atdsrvnum = ?           ",
                 "   and atdsrvano = ?           "

     prepare pbdbsr141_05 from l_sql
     declare cbdbsr141_05 cursor for pbdbsr141_05

 end function
     
#-------------------#
 function bdbsr141()
#-------------------#
     
   define l_sqlcode integer

   define l_dia like datkgeral.grlinf
   define l_tolerancia like datkgeral.grlinf
   define l_date    date
   define l_retorno smallint
   define l_assunto char(200)
   define l_comando char(100)
   define l_zip char(200)

   define l_datinc date
   define l_datfnl date

   define l_itmnumdig like datrservapol.itmnumdig
   define l_vclchsinc like abbmveic.vclchsinc
   define l_vclchsfnl like abbmveic.vclchsfnl
   define l_lcllttdaf like dpcmdafidxsrvhst.lclltt
   define l_lcllgtdaf like dpcmdafidxsrvhst.lcllgt
   define l_lclltt like dpcmdafidxsrvhst.lclltt
   define l_lcllgt like dpcmdafidxsrvhst.lcllgt
   define l_distancia decimal(8,4)

   define lr_historico record
       atdsrvnum    like datmservico.atdsrvnum
     , atdsrvano    like datmservico.atdsrvano
     , vcllicnum    like datmservico.vcllicnum
     , vclchs       char(20)
     , succod       like datrservapol.succod
     , aplnumdig    like datrservapol.aplnumdig
     , atddat       like datmservico.atddat
     , atdhor       like datmservico.atdhor
     , endlgdtip    like dpcmdafidxsrvhst.endlgdtip
     , endlgd       like dpcmdafidxsrvhst.endlgd
     , endlgdnum    like dpcmdafidxsrvhst.endlgdnum
     , endbrrnom    like dpcmdafidxsrvhst.endbrrnom
     , ciddes       like dpcmdafidxsrvhst.ciddes
     , ufdcod       like dpcmdafidxsrvhst.ufdcod
     , endlgdtipdaf like dpcmdafidxsrvhst.endlgdtip
     , endlgddaf    like dpcmdafidxsrvhst.endlgd
     , endlgdnumdaf like dpcmdafidxsrvhst.endlgdnum
     , endbrrnomdaf like dpcmdafidxsrvhst.endbrrnom
     , ciddesdaf    like dpcmdafidxsrvhst.ciddes
     , ufdcoddaf    like dpcmdafidxsrvhst.ufdcod
     , distancia    decimal(8,1)
   end record

   initialize lr_historico to null

   let l_datinc = null
   let l_datfnl = null
   let l_dia = null
   let l_tolerancia = null
   let l_retorno = null
   let l_assunto = null
   let l_comando = null
   let l_zip = null
   let l_itmnumdig = null
   let l_lcllttdaf = null
   let l_lcllgtdaf = null
   let l_vclchsinc = null
   let l_vclchsfnl = null
   let l_distancia = null
   let l_sqlcode = null
   let l_date = null

   let l_date = arg_val(1)

   if l_date is null or l_date = "  " then
       let l_date = today
   else
       if l_date > today then
           display "*** ERRO NO PARAMETRO: DATA INVALIDA! ***"
           exit program
       end if
   end if

   display 'Consultando dia da semana...'

   open cbdbsr141_01

   whenever error continue
   fetch cbdbsr141_01 into l_dia
   whenever error stop

   if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
       display 'Erro ao acessar datkgeral'
       exit program 1      
   end if

   close cbdbsr141_01

   if l_dia = weekday(l_date) then
       display 'Execucao semanal iniciada.'
       let l_datinc = l_date - 7 units day
       let l_datfnl = l_date - 1 units day
   end if

   if l_datinc is not null and l_datfnl is not null then

       start report bdbsr141_report to m_path

       display 'Consultando tolerancia...'

       open cbdbsr141_02

       whenever error continue
       fetch cbdbsr141_02 into l_tolerancia
       whenever error stop

       if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
           display 'Erro ao acessar datkgeral'
           exit program 1      
       end if
       let l_sqlcode = SQLCA.SQLCODE

       close cbdbsr141_02

       if l_sqlcode = notfound then
           display 'Nenhuma tolerancia encontrada.'
           let l_assunto = 'Relatorio de divergencias de endereco indexado x DAF: Parametro de distancia para calculo nao cadastrado'
       else
           display 'Consultando historico de ', l_datinc, ' a ', l_datfnl, '...'

           open cbdbsr141_03 using l_datinc
                                 , l_datfnl
           foreach cbdbsr141_03 into lr_historico.atdsrvnum
                                   , lr_historico.atdsrvano
                                   , lr_historico.vcllicnum
                                   , lr_historico.atddat
                                   , lr_historico.atdhor
                                   , lr_historico.succod
                                   , lr_historico.aplnumdig
                                   , l_itmnumdig
                                   , lr_historico.endlgdtipdaf
                                   , lr_historico.endlgddaf
                                   , lr_historico.endlgdnumdaf
                                   , lr_historico.endbrrnomdaf
                                   , lr_historico.ciddesdaf
                                   , lr_historico.ufdcoddaf
                                   , l_lcllttdaf
                                   , l_lcllgtdaf

               open cbdbsr141_04 using lr_historico.succod
                                     , lr_historico.aplnumdig
                                     , l_itmnumdig

               whenever error continue
               fetch cbdbsr141_04 into l_vclchsinc
                                     , l_vclchsfnl
               whenever error stop

               if sqlca.sqlcode <> 0 and sqlca.sqlcode <> 100 then
                   display 'Erro ao acessar abbmveic'
                   exit program 1      
               end if
               let l_sqlcode = SQLCA.SQLCODE

               close cbdbsr141_04

               if l_sqlcode <> notfound then
                   let lr_historico.vclchs = l_vclchsinc clipped, l_vclchsfnl
               end if

               open cbdbsr141_05 using lr_historico.atdsrvnum
                                     , lr_historico.atdsrvano
               foreach cbdbsr141_05 into lr_historico.endlgdtip
                                       , lr_historico.endlgd
                                       , lr_historico.endlgdnum
                                       , lr_historico.endbrrnom
                                       , lr_historico.ciddes
                                       , lr_historico.ufdcod
                                       , l_lclltt
                                       , l_lcllgt

                   call cts18g00(l_lclltt, l_lcllgt, l_lcllttdaf, l_lcllgtdaf)
                       returning l_distancia

                   let lr_historico.distancia = l_distancia * 1000

                   if lr_historico.distancia > l_tolerancia then
                       output to report bdbsr141_report(
                                                    lr_historico.atdsrvnum
                                                  , lr_historico.atdsrvano
                                                  , lr_historico.vcllicnum
                                                  , lr_historico.vclchs
                                                  , lr_historico.succod
                                                  , lr_historico.aplnumdig
                                                  , lr_historico.atddat
                                                  , lr_historico.atdhor
                                                  , lr_historico.endlgdtip
                                                  , lr_historico.endlgd
                                                  , lr_historico.endlgdnum
                                                  , lr_historico.endbrrnom
                                                  , lr_historico.ciddes
                                                  , lr_historico.ufdcod
                                                  , lr_historico.endlgdtipdaf
                                                  , lr_historico.endlgddaf
                                                  , lr_historico.endlgdnumdaf
                                                  , lr_historico.endbrrnomdaf
                                                  , lr_historico.ciddesdaf
                                                  , lr_historico.ufdcoddaf
                                                  , lr_historico.distancia)
                   end if

               end foreach
               close cbdbsr141_05

           end foreach
           close cbdbsr141_03

           let l_assunto = 'Relatorio de divergencias de endereco indexado x DAF: ', l_datinc, ' a ', l_datfnl
       end if

       finish report bdbsr141_report

       display 'Compactando arquivo...'

       let l_comando = 'gzip -f ', m_path clipped
       let l_zip = m_path clipped, '.gz'
       run l_comando

       display 'Enviando e-mail...'

       call ctx22g00_envia_email("BDBSR141", l_assunto, l_zip)
           returning l_retorno

   end if

 end function

#------------------------#
 function bdbsr141_path()
#------------------------#

   let m_path = f_path("DBS","RELATO")

   if  m_path is null then
       let m_path = "."
   end if

   let m_path  = m_path  clipped, "/BDBSR141.xls"

 end function

#------------------------------------#
 report bdbsr141_report(lr_historico)
#------------------------------------#

   define lr_historico record
       atdsrvnum    like datmservico.atdsrvnum
     , atdsrvano    like datmservico.atdsrvano
     , vcllicnum    like datmservico.vcllicnum
     , vclchs       char(20)
     , succod       like datrservapol.succod
     , aplnumdig    like datrservapol.aplnumdig
     , atddat       like datmservico.atddat
     , atdhor       like datmservico.atdhor
     , endlgdtip    like dpcmdafidxsrvhst.endlgdtip
     , endlgd       like dpcmdafidxsrvhst.endlgd
     , endlgdnum    like dpcmdafidxsrvhst.endlgdnum
     , endbrrnom    like dpcmdafidxsrvhst.endbrrnom
     , ciddes       like dpcmdafidxsrvhst.ciddes
     , ufdcod       like dpcmdafidxsrvhst.ufdcod
     , endlgdtipdaf like dpcmdafidxsrvhst.endlgdtip
     , endlgddaf    like dpcmdafidxsrvhst.endlgd
     , endlgdnumdaf like dpcmdafidxsrvhst.endlgdnum
     , endbrrnomdaf like dpcmdafidxsrvhst.endbrrnom
     , ciddesdaf    like dpcmdafidxsrvhst.ciddes
     , ufdcoddaf    like dpcmdafidxsrvhst.ufdcod
     , distancia    decimal(8,1)
   end record

   output
       left margin 0
       right margin 0
       top margin 0
       bottom margin 0

   format
       first page header
           print
               'Numero do servico',                                						 ASCII(09),
               'Ano do servico',                                   						 ASCII(09),
               'Placa do veiculo',                                 						 ASCII(09),
               'Chassi final do veiculo',                          						 ASCII(09),
               'Apolice do servico',                               						 ASCII(09),
               'Sucursal da apolice',                              						 ASCII(09),
               'Data consulta no sistema DAF',                     						 ASCII(09),
               'Hora consulta no sistema DAF',                    						 ASCII(09),
               'Tipo do logradouro do servico',                    						 ASCII(09),
               'Logradouro do servico',                            						 ASCII(09),
               'Numero do logradouro do servico',                  						 ASCII(09),
               'Bairro do logradouro do servico',                  						 ASCII(09),
               'Cidade do logradouro do servico',                  						 ASCII(09),
               'UF do logradouro do servico',                      						 ASCII(09),
               'Tipo do logradouro da coordenada DAF',             						 ASCII(09),
               'Logradouro da coordenada DAF',                     						 ASCII(09),
               'Numero do logradouro da coordenada DAF',           						 ASCII(09),
               'Bairro do logradouro da coordenada DAF',           						 ASCII(09),
               'Cidade do logradouro da coordenada DAF',           						 ASCII(09),
               'UF do logradouro da coordenada DAF',               						 ASCII(09),
               'Distancia entre endereco DAF e endereco indexado - Em Metros', ASCII(09)
       on every row
           print
               lr_historico.atdsrvnum clipped,    ASCII(09),
               lr_historico.atdsrvano clipped,    ASCII(09),
               lr_historico.vcllicnum clipped,    ASCII(09),
               lr_historico.vclchs clipped,       ASCII(09),
               lr_historico.aplnumdig clipped,    ASCII(09),
               lr_historico.succod clipped,       ASCII(09),
               lr_historico.atddat clipped,       ASCII(09),
               lr_historico.atdhor clipped,       ASCII(09),
               lr_historico.endlgdtip clipped,    ASCII(09),
               lr_historico.endlgd clipped,       ASCII(09),
               lr_historico.endlgdnum clipped,    ASCII(09),
               lr_historico.endbrrnom clipped,    ASCII(09),
               lr_historico.ciddes clipped,       ASCII(09),
               lr_historico.ufdcod clipped,       ASCII(09),
               lr_historico.endlgdtipdaf clipped, ASCII(09),
               lr_historico.endlgddaf clipped,    ASCII(09),
               lr_historico.endlgdnumdaf clipped, ASCII(09),
               lr_historico.endbrrnomdaf clipped, ASCII(09),
               lr_historico.ciddesdaf clipped,    ASCII(09),
               lr_historico.ufdcoddaf clipped,    ASCII(09),
               lr_historico.distancia clipped,    ASCII(09)

 end report
