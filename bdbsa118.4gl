#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# .......................................................................... #
# Sistema........: Porto Socorro                                             #
# Modulo.........: bdbsa118                                                  #
# Objetivo.......: O programa faz a leitura  da tabela de provisionamento e  #
#                  grava a baixa do provisionamento.                         #
# Analista Resp. : Norton Nery                                               #
# PSI            : 227340                                                    #
#............................................................................#
# Desenvolvimento: Thomas Ferrao - META                                      #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI     Alteracao                                 #
# --------   ------------- ------  ------------------------------------------#
# 23/03/2010 Fabio Costa   198404  Trocar baixa de servicos nao provisionados#
#                                  por servicos nao pagos                    #
#----------------------------------------------------------------------------#
# 09/05/2013 Beatriz Araujo PSI-2013-10084/EV Evolutivo Camada Contabil      #
#                                             integração com o Porto Socorro #
# 12/11/2014 Rodolfo Massini  14-19758/PR  Alteracoes para o projeto "Entrada#
#                                          Camada Contabil"                  #
#----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/dssqa/producao/I4GLParams.4gl"

define m_atddat date
     , m_prc  integer
     , m_bxa  integer
     , m_err  integer
        
main

   define l_path char(080)
        , l_log  char(080)

   let m_prc = 0
   let m_bxa = 0
   let m_err = 0
   
   call fun_dba_abre_banco('CT24HS')
   
    #-----------------------
    #CT: 14080010
    #Descricao: O programa caia ao ler um registro "locado".
    #-----------------------
    set lock mode to wait 60
    #Fim CT: 14080010
   
   let l_path = f_path('DBS', 'LOG')

   if l_path is null or
      l_path = ' '   then
      let l_path = '.'
   end if

   let l_path = l_path clipped, "/dbs_bdbsa118.log"

   call startlog(l_path)

   let m_atddat = arg_val(1)

   ##  Verifica data recebida como parametro  ##
   if m_atddat is null or
      m_atddat = " "   then
       let m_atddat = today
   else
       if m_atddat > today then
          display "*** ERRO NO PARAMETRO: DATA INVALIDA! ***"
          exit program(1)
       end if
   end if

   let l_log = 'Inicio do processamento: ',today,' as: ',time
   display l_log clipped

   display 'Arquivo: ', l_path clipped
   
   call bdbsa118_prepare()

   call bdbsa118_processamento_camada()
   
   display "------------------------------------------------------------"
   display " RESUMO BDBSA118 Camada:  "
   display " Provisoes processadas......: ", m_prc using "#######&&"
   display " Provisoes baixa com sucesso: ", m_bxa using "#######&&"
   display " Provisoes baixa com erro...: ", m_err using "#######&&"
   display "------------------------------------------------------------"
   
   let m_prc = 0
   let m_bxa = 0
   let m_err = 0
   
   
   call bdbsa118_processamento_ifx()

   display "------------------------------------------------------------"
   display " RESUMO BDBSA118 Informix:  "
   display " Provisoes processadas......: ", m_prc using "#######&&"
   display " Provisoes baixa com sucesso: ", m_bxa using "#######&&"
   display " Provisoes baixa com erro...: ", m_err using "#######&&"
   display "------------------------------------------------------------"

   let l_log = 'Final  do processamento:',today,' as: ',time
   display l_log clipped

end main

#--------------------------------
function bdbsa118_prepare()
#--------------------------------

   define l_sql char(500)

   # Beatriz Araujo - Fonte com os dados da integracao contabil via informix
   
   let l_sql = "select atdsrvnum,   ",
               "       atdsrvano,   ",
               "       regiclhrrdat ",
               "  from dbsmatdpovhst",
               " where extend(regiclhrrdat, year to month) = extend(?, year to month)",
               "   and evntipcod = 1"
   prepare pbdbsa118001 from l_sql
   declare cbdbsa118001 cursor for pbdbsa118001
   
   
   let l_sql =  "select max(regiclhrrdat)",
                "  from dbsmatdpovhst    ",
                " where atdsrvnum = ?    ",
                "   and atdsrvano = ?    "
   prepare pbdbsa118002 from l_sql
   declare cbdbsa118002 cursor for pbdbsa118002

   let l_sql = ' select pgtdat ',
               ' from datmservico    ',
               ' where atdsrvnum = ? ',
               '   and atdsrvano = ? '
   prepare pbdbsa118003 from l_sql
   declare cbdbsa118003 cursor for pbdbsa118003
   
   let l_sql = ' select  atdsrvnum, atdsrvano   '
              ,' from ctimsocprv                '
              ,' where extend(atdsrvabrdat, year to month) = extend(?, year to month) '
              ,' and prvtip    = "D"'
              ,' and prvmvttip = 1  '
   prepare pbdbsa118001_i from l_sql
   declare cbdbsa118001_i cursor for pbdbsa118001_i
   
   let l_sql =  'select  atdsrvnum, atdsrvano '
               ,'from  ctimsocprv             '
               ,'where atdsrvnum  = ?         '
               ,'and   atdsrvano  = ?         '
               ,'and   (   (prvtip = "C" and prvmvttip = 3) '
               ,      ' or (prvtip = "D" and prvmvttip = 4))'
   prepare pbdbsa118002_i from l_sql
   declare cbdbsa118002_i cursor for pbdbsa118002_i

   let l_sql = ' select atdsrvnum, pgtdat ',
               ' from datmservico    ',
               ' where atdsrvnum = ? ',
               '   and atdsrvano = ? '
   prepare p_srv_sel from l_sql
   declare c_srv_sel cursor for p_srv_sel
   
end function

#--------------------------------
function bdbsa118_processamento_camada()
#--------------------------------
  define l_atdsrvabrdat date
  
  define lr_bdbsa118 record
    atdsrvnum    like dbsmatdpovhst.atdsrvnum,   
    atdsrvano    like dbsmatdpovhst.atdsrvano,   
    regiclhrrdat like dbsmatdpovhst.regiclhrrdat,   
    maxData      like dbsmatdpovhst.regiclhrrdat,
    pgtdat       like datmservico.pgtdat
  end record
  
   define lr_ctb00g16 record    
    ctbevnpamcod like dbskctbevnpam.ctbevnpamcod, 
    srvpovevncod like dbskctbevnpam.srvpovevncod, 
    srvajsevncod like dbskctbevnpam.srvajsevncod, 
    srvbxaevncod like dbskctbevnpam.srvbxaevncod, 
    empcod       like dbskctbevnpam.empcod      , 
    pcpsgrramcod like dbskctbevnpam.pcpsgrramcod, 
    pcpsgrmdlcod like dbskctbevnpam.pcpsgrmdlcod, 
    ctbsgrramcod like dbskctbevnpam.ctbsgrramcod, 
    ctbsgrmdlcod like dbskctbevnpam.ctbsgrmdlcod, 
    pgoclsflg    like dbskctbevnpam.pgoclsflg   , 
    srvdcrcod    like dbskctbevnpam.srvdcrcod   , 
    itaasstipcod like dbskctbevnpam.itaasstipcod, 
    bemcod       like dbskctbevnpam.bemcod      , 
    srvatdctecod like dbskctbevnpam.srvatdctecod, 
    c24astagp    like dbskctbevnpam.c24astagp   , 
    atopamflg    like dbskctbevnpam.atopamflg   ,
    srvvlr       like dbsmatdpovhst.srvvlr
 end record
 
 # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
 define lr_apolice record
   succod       like datrservapol.succod    , 
   ramcod       like datrservapol.ramcod    , 
   modalidade   like rsamseguro.rmemdlcod   , 
   aplnumdig    like datrservapol.aplnumdig , 
   itmnumdig    like datrservapol.itmnumdig ,
   edsnumref    like datrservapol.edsnumref ,            
   prporg       like datrligprp.prporg      ,  
   prpnumdig    like datrligprp.prpnumdig   ,
   corsus       like abamcor.corsus     
 end record
 # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
 
 define lr_erro record         
     err    smallint,          
     msgerr char(1000)          
  end record  
                   
  define l_dt_aux    char(10)
  
  let lr_erro.err = null

  initialize lr_bdbsa118.* to null 
  initialize lr_erro.* to null
  initialize lr_ctb00g16.* to null
  initialize lr_apolice.* to null # PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
  
  let l_atdsrvabrdat = m_atddat - 7 units month
  let l_dt_aux       =  year (l_atdsrvabrdat),"-", month(l_atdsrvabrdat) using "&&"
  display "l_dt_aux: ",l_dt_aux
  open cbdbsa118001 using l_dt_aux

  foreach cbdbsa118001 into lr_bdbsa118.atdsrvnum,
                            lr_bdbsa118.atdsrvano,
                            lr_bdbsa118.regiclhrrdat
                           
                           
     let m_prc = m_prc + 1
     
     display 'Servico: ', lr_bdbsa118.atdsrvnum,'-',lr_bdbsa118.atdsrvano
        
     whenever error continue
        open cbdbsa118002 using lr_bdbsa118.atdsrvnum
                               ,lr_bdbsa118.atdsrvano
        
        fetch cbdbsa118002 into  lr_bdbsa118.maxData
        
        if sqlca.sqlcode < 0  then
           display 'Erro SELECT cbdbsa118002: ',sqlca.sqlcode,' | ',sqlca.sqlerrd[2]
           display 'bdbsa118/ bdbsa118_processamento() / '
           continue foreach
        end if
     whenever error stop

     if lr_bdbsa118.maxData > lr_bdbsa118.regiclhrrdat then
        display "Servico com operacaoes recentes: ",lr_bdbsa118.maxData
        continue foreach
     else
       
        whenever error continue
           open cbdbsa118003 using lr_bdbsa118.atdsrvnum, lr_bdbsa118.atdsrvano
           fetch cbdbsa118003 into lr_bdbsa118.pgtdat
           
           if sqlca.sqlcode != 0 then
              continue foreach
           end if
           
           if lr_bdbsa118.pgtdat is not null  # servico pago nao fazer baixa
              then
              display "Servico pago: ",lr_bdbsa118.pgtdat
              continue foreach
           end if
        whenever error stop
        
        
        
        call ctb00g16_bxaprvdsp(lr_bdbsa118.atdsrvnum, lr_bdbsa118.atdsrvano)
             returning lr_erro.err,
                       lr_erro.msgerr,
                       lr_ctb00g16.ctbevnpamcod,
                       lr_ctb00g16.srvpovevncod,
                       lr_ctb00g16.srvajsevncod,
                       lr_ctb00g16.srvbxaevncod,
                       lr_ctb00g16.empcod      ,
                       lr_ctb00g16.pcpsgrramcod,
                       lr_ctb00g16.pcpsgrmdlcod,
                       lr_ctb00g16.ctbsgrramcod,
                       lr_ctb00g16.ctbsgrmdlcod,
                       lr_ctb00g16.pgoclsflg   ,
                       lr_ctb00g16.srvdcrcod   ,
                       lr_ctb00g16.itaasstipcod,
                       lr_ctb00g16.bemcod      ,
                       lr_ctb00g16.srvatdctecod,
                       lr_ctb00g16.c24astagp   ,
                       lr_ctb00g16.atopamflg   ,
                       lr_ctb00g16.srvvlr  
 
        if lr_erro.err <> 0 
           then
           display 'Erro: ', lr_erro.err
           display "Mensagem: ", lr_erro.msgerr clipped
           let m_err = m_err + 1
        else
           let m_bxa = m_bxa + 1
           
           # Inicio - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
           call cts00g09_apolice(lr_bdbsa118.atdsrvnum, 
                                 lr_bdbsa118.atdsrvano,
                                 4,                     # Tipo de Retorno
                                 lr_ctb00g16.empcod ,
                                 0)                     # Tipo da OP (0 = N/A)
     
                  
                 returning lr_apolice.succod,    
                           lr_apolice.ramcod,    
                           lr_apolice.modalidade,
                           lr_apolice.aplnumdig, 
                           lr_apolice.itmnumdig, 
                           lr_apolice.edsnumref, 
                           lr_apolice.prporg,    
                           lr_apolice.prpnumdig,
                           lr_apolice.corsus
              
           call ctb00g16_envio_contabil(lr_ctb00g16.srvbxaevncod, 
                                        lr_ctb00g16.empcod      ,
                                        lr_apolice.succod       ,
                                        lr_ctb00g16.ctbsgrramcod, 
                                        lr_ctb00g16.ctbsgrmdlcod, 
                                        lr_apolice.aplnumdig    ,                           
                                        lr_apolice.itmnumdig    ,
                                        lr_apolice.edsnumref    ,
                                        lr_apolice.prporg       , 
                                        lr_apolice.prpnumdig    ,
                                        lr_apolice.corsus       ,
                                        lr_ctb00g16.srvvlr      ,
                                        lr_bdbsa118.atdsrvnum   ,
                                        lr_bdbsa118.atdsrvano   ,
                                        0                       , 
                                        lr_ctb00g16.srvatdctecod,
                                        today)
           # Fim - PSI-2014-19758/PR por Rodolfo Massini - Projeto Camada Contabil
           
        end if
     end if
     
  end foreach

end function

#--------------------------------
function bdbsa118_processamento_ifx()
#--------------------------------
  define  l_erro      smallint
         ,l_msg   char (50)
         ,l_atdsrvabrdat date

  define lr_bdbsa118_1 record
      atdsrvnum like ctimsocprv.atdsrvnum
     ,atdsrvano like ctimsocprv.atdsrvano
  end record

  define lr_bdbsa118_2 record
      atdsrvnum like ctimsocprv.atdsrvnum
     ,atdsrvano like ctimsocprv.atdsrvano
  end record

  define lr_param  record
       evento                  char(06)
      ,empresa                 char(50)
      ,dt_movto                date
      ,chave_primaria          char(50)
      ,op                      char(50)
      ,apolice                 char(50)
      ,sucursal                char(50)
      ,projeto                 char(50)
      ,dt_chamado              date
      ,fvrcod                  char(50)
      ,fvrnom                  char(50)
      ,nfnum                   char(50)
      ,corsus                  char(50)
      ,cctnum                  char(50)
      ,modalidade              char(50)
      ,ramo                    char(50)
      ,opgvlr                  char(50)
      ,dt_vencto               date
      ,dt_ocorrencia           date
  end record

  define l_srvpgt record
         atdsrvnum  like datmservico.atdsrvnum, 
         pgtdat     like datmservico.pgtdat   
  end record
                   
  define l_dt_aux    char(10)
  define teste       char(1)

  let l_erro = null

  initialize lr_bdbsa118_1.* to null
  initialize lr_bdbsa118_2.* to null
  initialize l_srvpgt.* to null
  initialize lr_param.* to null
  initialize l_atdsrvabrdat to  null

  let l_atdsrvabrdat = m_atddat - 7 units month
  let l_dt_aux       =  year (l_atdsrvabrdat),"-", month(l_atdsrvabrdat) using "&&"

  open cbdbsa118001_i using l_dt_aux

  foreach cbdbsa118001_i into lr_bdbsa118_1.atdsrvnum
                           ,lr_bdbsa118_1.atdsrvano
                           
     initialize l_srvpgt.* to null
     
     let m_prc = m_prc + 1
   
     open cbdbsa118002_i using lr_bdbsa118_1.atdsrvnum
                            ,lr_bdbsa118_1.atdsrvano

     whenever error continue
     fetch cbdbsa118002_i into  lr_bdbsa118_2.atdsrvnum
                             ,lr_bdbsa118_2.atdsrvano

     whenever error stop

     if sqlca.sqlcode < 0  then
        display 'Erro SELECT cbdbsa118002: ',sqlca.sqlcode,' | ',sqlca.sqlerrd[2]
        display 'bdbsa118/ bdbsa118_processamento() / '
        continue foreach
     end if

     if lr_bdbsa118_1.atdsrvnum = lr_bdbsa118_2.atdsrvnum and
        lr_bdbsa118_1.atdsrvano = lr_bdbsa118_2.atdsrvano 
        then
        continue foreach
     else

        whenever error continue
        open c_srv_sel using lr_bdbsa118_1.atdsrvnum, lr_bdbsa118_1.atdsrvano
        fetch c_srv_sel into l_srvpgt.atdsrvnum, l_srvpgt.pgtdat
        whenever error stop
        
        if sqlca.sqlcode != 0
           then
           continue foreach
        end if
        
        if l_srvpgt.pgtdat is not null  # servico pago nao fazer baixa
           then
           continue foreach
        end if
        
        display 'Servico: ', l_srvpgt.atdsrvnum, '-',lr_bdbsa118_1.atdsrvano 
        
        call ctb00g03_bxaprvdsp(lr_bdbsa118_1.atdsrvnum, lr_bdbsa118_1.atdsrvano)
             returning l_erro
                      ,lr_param.evento
                      ,lr_param.empresa
                      ,lr_param.dt_movto
                      ,lr_param.chave_primaria
                      ,lr_param.op
                      ,lr_param.apolice
                      ,lr_param.sucursal
                      ,lr_param.projeto
                      ,lr_param.dt_chamado
                      ,lr_param.fvrcod
                      ,lr_param.fvrnom
                      ,lr_param.nfnum
                      ,lr_param.corsus
                      ,lr_param.cctnum
                      ,lr_param.modalidade
                      ,lr_param.ramo
                      ,lr_param.opgvlr
                      ,lr_param.dt_vencto
                      ,lr_param.dt_ocorrencia
 
        if l_erro <> 0 
           then
           display 'Erro: ', l_erro
           let m_err = m_err + 1
        else
           let m_bxa = m_bxa + 1
        end if
     end if
     
  end foreach

end function
