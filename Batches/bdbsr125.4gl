#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: BDBSR125                                                   #
# ANALISTA RESP..: SERGIO BURINI                                              #
# PSI/OSF........: RELATORIOS DE SERVIÇOS RIS                                 #
# ........................................................................... #
# DESENVOLVIMENTO: SERGIO BURINI                                              #
# LIBERACAO......: 07/07/2009                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
#11/05/2012  Rafael BRQ                 Alteração impressão Detalhado         #
#-----------------------------------------------------------------------------#
#08/06/2015  RCP, Fornax     RELTXT     Criar versao .txt dos relatoriosi.    #
#-----------------------------------------------------------------------------#
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

database porto

 define m_path     char(100),
        m_path_txt char(100),  #--> RELTXT
        m_path2    char(100),
        m_path2_txt char(100), #--> RELTXT
        m_data     date,
        m_totpend  integer,
        m_totenvok integer,
        m_totenvfp integer,
        m_totsrv   integer

 define mr_bdbsr125 record
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano,
     atdprscod like datmservico.atdprscod,
     risldostt like dpamris.risldostt,
     empcod    like datmservico.empcod,    # PSI-2011-22593
     vcllicnum like datmservico.vcllicnum, # PSI-2011-22593
     srrcoddig like datmservico.srrcoddig  # PSI-2011-22593
 end record

 define mr_datmservico record
     empcod       like datmservico.empcod ,
     atdsrvnum    like datmservico.atdsrvnum,
     atdsrvano    like datmservico.atdsrvano,
     vcllicnum    like datmservico.vcllicnum,
     srrcoddig    like datmservico.srrcoddig,
     socvclcod    like datmservico.socvclcod,
     atdprscod    like datmservico.atdprscod
end record


define mr_dpcmgpsrislau record
     rislaucod    like dpcmgpsrislau.rislaucod,
     relmodnom    like dpcmgpsrislau.relmodnom
end record

define mr_dpaksocor record
     pstcoddig    like dpaksocor.pstcoddig,
     nomgrr       like dpaksocor.nomgrr,
     dddcod       like dpaksocor.dddcod,
     teltxt       like dpaksocor.teltxt
end record

define mr_datksrr record
     srrcoddig    like datksrr.srrcoddig,
     srrabvnom    like datksrr.srrabvnom
end record

define mr_datkveiculo record
     socvclcod    like datkveiculo.socvclcod,
     atdvclsgl    like datkveiculo.atdvclsgl,
     celdddcod    like datkveiculo.celdddcod,
     celtelnum    like datkveiculo.celtelnum,
     mdtcod       like datkveiculo.mdtcod
end record

define mr_datkmdt record
     mdtcod       like datkmdt.mdtcod,
     mdtcfgcod    like datkmdt.mdtcfgcod
end record

define mr_datmlcl record
     atdsrvnum    like datmlcl.atdsrvnum,
     atdsrvano    like datmlcl.atdsrvano,
     lgdtip       like datmlcl.lgdtip,
     lgdnom       like datmlcl.lgdnom,
     lgdnum       like datmlcl.lgdnum,
     lclbrrnom    like datmlcl.lclbrrnom,
     cidnom       like datmlcl.cidnom,
     ufdcod       like datmlcl.ufdcod,
     lgdcep       like datmlcl.lgdcep,
     lgdcepcmp    like datmlcl.lgdcepcmp
end record

define mr_dpamris record
     empcod       like dpamris.empcod,
     atdsrvnum    like dpamris.atdsrvnum,
     atdsrvano    like dpamris.atdsrvano,
     envdat       like dpamris.envdat,
     risldostt    like dpamris.risldostt
end record

define mr_dpcmrislauqst record
     rislaucod    like dpcmrislauqst.rislaucod,
     qsttxt       like dpcmrislauqst.qsttxt
end record

define mr_datmservicocmp record
      atdsrvnum  like datmservicocmp.atdsrvnum,
      atdsrvano  like datmservicocmp.atdsrvano,
      sindat     like datmservicocmp.sindat,
      sinhor     like datmservicocmp.sinhor
end record

define mr_iddkdominio record
      cpocod     like iddkdominio.cpocod,
      cpodes     like iddkdominio.cpodes,
      cponom     like iddkdominio.cpodes
end record

define mr_datkassunto record
   c24astcod   like datkassunto.c24astcod
end record

define l_cid_uf             char(20)
define l_data                 char (20)

 main

     let m_data = arg_val(1)

     if  m_data is null then
         let m_data = today - 1 units day
     end if

     call cts40g03_exibe_info("I", "BDBSR125")

     set isolation to dirty read

     call bdbsr125_path()
     call bdbsr125_prepare()
     call bdbsr125()
     call bdbsr125_envia_mail()

     call cts40g03_exibe_info("FI", "BDBSR125")

 end main

#------------------------#
 function bdbsr125_path()
#------------------------#

     define l_datarq char(08)
     define l_data   date

     let m_path  = null
     let m_path2 = null

     let m_path = f_path("DBS","RELATO")

     if  m_path is null then
         let m_path = "."
     end if

     let l_data = m_data + 1

     let l_datarq = extend(l_data, year to year),
                    extend(l_data, month to month),
                    extend(l_data, day to day)

     let m_path2 = m_path

    #let m_path_txt  = m_path  clipped, "/BDBSR125_RIS_", l_datarq, ".txt" #--> RELTXT
     let m_path      = m_path  clipped, "/BDBSR125_RIS_", l_datarq, ".xls"
     let m_path2_txt = m_path2 clipped, "/BDBSR125_RIS_DETALHADO_", l_datarq, ".txt" #--> RELTXT
     let m_path2     = m_path2 clipped, "/BDBSR125_RIS_DETALHADO_", l_datarq, ".xls"

 end function

#------------------------------#
 function bdbsr125_envia_mail()
#------------------------------#

     define lr_mail record
             rem     char(50)
            ,des     char(10000)
            ,ccp     char(10000)
            ,cco     char(10000)
            ,ass     char(500)
            ,msg     char(32000)
            ,idr     char(20)
            ,tip     char(4)
     end record

      define lr_anexo record
           anexo1    char (300)
          ,anexo2    char (300)
          ,anexo3    char (300)
     end record

     define   lr_mail_erro   smallint
     define   cmd            char(500)
     define   l_destino      char(1500)
     define   l_sql1        char(1500)

     initialize lr_mail.*, lr_anexo.* to null

     let l_sql1 = " select relpamtxt  "
                  ,"   from igbmparam  "
                  ,"  where relsgl = ? "
     prepare pbdbsr125018 from l_sql1
     declare cbdbsr125018 cursor for pbdbsr125018


     let lr_mail.ass = "Relatório de Serviços RIS ", m_data

     let cmd = "gzip -f ", m_path
     run cmd
     let m_path = m_path clipped, ".gz "

     let lr_anexo.anexo1 = m_path

     let cmd = "gzip -f ", m_path2
     run cmd
     let m_path2 = m_path2 clipped, ".gz "

     let lr_anexo.anexo2 = m_path2

     let lr_mail.rem = 'portosocorro@portoseguro.com.br'
     let lr_mail.msg = 'BDBSR125' clipped
     let lr_mail.idr = 'P0603000'
     let lr_mail.tip = 'text'

     open cbdbsr125018 using lr_mail.msg
     foreach cbdbsr125018 into l_destino

     #display "l_destino : ", l_destino
        if lr_mail.des is null then
           let lr_mail.des = l_destino
        else
           let lr_mail.des = lr_mail.des clipped,',',l_destino
        end if
     end foreach

     let lr_mail_erro = ctx22g00_envia_email_anexos(lr_mail.*, lr_anexo.*)

     display  "lr_mail_erro: ", lr_mail_erro

     if  lr_mail_erro <> 0 then
         if  lr_mail_erro <> 99 then
             display "Erro ao enviar email(ctx22g00) - ", lr_mail_erro
         else
             display "Nao existe email cadastrado para o modulo - BDBSR125"
         end if
     end if

 end function

#---------------------------#
 function bdbsr125_prepare()
#---------------------------#

     define l_sql  char(1500)

     let l_sql = ' select dat.atdsrvnum ',
                       ' ,dat.atdsrvano ',
                       ' ,dat.atdprscod ',
                       ' ,dpa.risldostt ',
                       ' ,dat.empcod    ', # PSI-2011-22593
                       ' ,dat.vcllicnum ', # PSI-2011-22593
                       ' ,dat.srrcoddig ', # PSI-2011-22593
                   ' from datmservico dat ',
                       ' ,dpamris     dpa ',
                  ' where dat.atdsrvnum = dpa.atdsrvnum ',
                    ' and dat.atdsrvano = dpa.atdsrvano ',
                    ' and dat.atddat    = ? ',
                    ' order by 3, 2, 1, 4 '


     prepare pbdbsr125001 from l_sql               #detalhado antigo
     declare cbdbsr125001 cursor for pbdbsr125001

     let l_sql = ' select nomgrr ',
                   ' from dpaksocor ',
                  ' where pstcoddig = ? '

     prepare pbdbsr125002 from l_sql
     declare cbdbsr125002 cursor for pbdbsr125002



     let l_sql = ' select datmservico.ciaempcod ,',
                 '        datmservico.atdsrvnum,',
                 '        datmservico.atdsrvano,',
                 '        datmservico.vcllicnum,',
                 '        datmservico.srrcoddig,',
                 '        datmservico.socvclcod,',
                 '        datmservico.atdprscod',
                 '   from datmservico ' ,
                 '   where datmservico.atddat = ?',
                 ' order by 3, 2, 1, 4 '

     prepare pbdbsr125003 from l_sql
     declare cbdbsr125003 cursor for pbdbsr125003

     let l_sql = ' select dpcmgpsrislau.rislaucod,',
                  '        dpcmgpsrislau.relmodnom',
                  '   from dpcmgpsrislau',
                  #'  where dpcmgpsrislau.rislaucod = ? ',  #datmservico.rislaucod
                  '   where dpcmgpsrislau.atdsrvnum = ? ',  #datmservico.atdsrvnum
                  '    and dpcmgpsrislau.atdsrvano = ? '   #datmservico.atdsrvano

     prepare pbdbsr125004 from l_sql
     declare cbdbsr125004 cursor for pbdbsr125004

     let l_sql = ' select dpaksocor.nomgrr,',
                  '        dpaksocor.dddcod,',
                  '        dpaksocor.teltxt,',
                  '        dpaksocor.pstcoddig',
                  '   from dpaksocor',
                  '  where dpaksocor.pstcoddig = ? '  #dpcmgpsrislau.pstcoddig

     prepare pbdbsr125005 from l_sql
     declare cbdbsr125005 cursor for pbdbsr125005

     let l_sql = ' select datksrr.srrabvnom ',
                  '   from datksrr',
                  '  where datksrr.srrcoddig = ? '  #datmservico.srrcoddig

     prepare pbdbsr125006 from l_sql
     declare cbdbsr125006 cursor for pbdbsr125006

     let l_sql = ' select datkveiculo.atdvclsgl,',
                  '        datkveiculo.celdddcod,',
                  '        datkveiculo.celtelnum,',
                  '        datkveiculo.mdtcod',
                  '   from datkveiculo',
                  '  where datkveiculo.socvclcod = ? ' #datmservico.socvclcod

     prepare pbdbsr125007 from l_sql
     declare cbdbsr125007 cursor for pbdbsr125007

     let l_sql = ' select datkmdt.mdtcfgcod',
                  '   from datkmdt',
                  '  where datkmdt.mdtcod = ? ' #datkveiculo.mdtcod

     prepare pbdbsr125008 from l_sql
     declare cbdbsr125008 cursor for pbdbsr125008

     let l_sql = ' select datmlcl.lgdtip,',
                  '        datmlcl.lgdnom,',
                  '        datmlcl.lgdnum,',
                  '        datmlcl.lclbrrnom,',
                  '        datmlcl.cidnom,',
                  '        datmlcl.ufdcod,',
                  '        datmlcl.lgdcep,',
                  '        datmlcl.lgdcepcmp',
                  '   from datmlcl',
                  '  where datmlcl.atdsrvnum = ? ',  #datmservico.atdsrvnum
                  '    and datmlcl.atdsrvano = ? ',  #datmservico.atdsrvano
                  '    and datmlcl.c24endtip = 1'

     prepare pbdbsr125009 from l_sql
     declare cbdbsr125009 cursor for pbdbsr125009

     let l_sql = ' select datmservicocmp.sindat,',
                  '        datmservicocmp.sinhor',
                  '   from datmservicocmp',
                  '  where datmservicocmp.atdsrvnum = ? ', #datmservico.atdsrvnum
                  '    and datmservicocmp.atdsrvano = ? '  #datmservico.atdsrvano

     prepare pbdbsr125010 from l_sql
     declare cbdbsr125010 cursor for pbdbsr125010

     let l_sql = ' select dpamris.envdat,',
                  '        dpamris.risldostt',
                  '   from dpamris',
                  '  where dpamris.empcod = ? ',     #datmservico.empcod
                  '    and dpamris.atdsrvnum = ? ',  #datmservico.atdsrvnum
                  '    and dpamris.atdsrvano = ? '   #datmservico.atdsrvano

     prepare pbdbsr125011 from l_sql
     declare cbdbsr125011 cursor for pbdbsr125011

     let l_sql = ' select dpcmrislauqst.qsttxt ',
                   '   from dpcmrislauqst',
                   '  where dpcmrislauqst.rislaucod = ? ' #dpcmgpsrislau.rislaucod

     prepare pbdbsr125012 from l_sql
     declare cbdbsr125012 cursor for pbdbsr125012

     let l_sql = '  select iddkdominio.cpodes     ',
                   '    from iddkdominio            ',
                   '   where iddkdominio.cponom = ? ',  #l_var = 'eqttipcod'
                   '     and iddkdominio.cpocod = ? '   #mr_datkmdt.mdtcfgcod

     prepare pbdbsr125013 from l_sql
     declare cbdbsr125013 cursor for pbdbsr125013

     let l_sql = ' select datkassunto.c24astcod ',
                   '    from datkassunto, datmligacao ',
                   '   where datkassunto.c24astcod = datmligacao.c24astcod ',
                   '     and datmligacao.atdsrvnum = ? ',   #datmservico.atdsrvnum
                   '     and datmligacao.atdsrvano = ? ',   #datmservico.atdsrvano
                   '     and datmligacao.lignum    = (select min(lignum)',
                   '                                    from datmligacao ligpri',
                   '                                   where ligpri.atdsrvnum = datmligacao.atdsrvnum ',
                   '                                     and ligpri.atdsrvano = datmligacao.atdsrvano)'

     prepare pbdbsr125014 from l_sql
     declare cbdbsr125014 cursor for pbdbsr125014

     let l_sql = '      select cponom',
                   '        from iddkdominio',
                   '       where cpodes = ? '  #mr_datkassunto.c24astcod'

     prepare pbdbsr125015 from l_sql
     declare cbdbsr125015 cursor for pbdbsr125015

     let l_sql = ' select 1',
                   '   from dpamris',
                   '  where atdsrvnum = ? ',
                   '    and atdsrvano = ? ',
                   '    and empcod = ? '
     prepare pbdbsr125016 from l_sql
     declare cbdbsr125016 cursor for pbdbsr125016

     let l_sql = ' select 1',
                   '   from dpcmgpsrislau, dpcmrislauqst',
                   '  where dpcmgpsrislau.rislaucod = dpcmrislauqst.rislaucod',
                   '    and dpcmgpsrislau.atdsrvnum = ? ',
                   '    and dpcmgpsrislau.atdsrvano = ? '
     prepare pbdbsr125017 from l_sql
     declare cbdbsr125017 cursor for pbdbsr125017

 end function

#-------------------#
 function bdbsr125()
#-------------------#

     define l_ulpstcoddig like datmservico.atdprscod
     define l_var    char(10)
     define l_web    smallint
     define l_gps    smallint

     let l_ulpstcoddig = null
     let m_totpend  = 0
     let m_totenvok = 0
     let m_totenvfp = 0
     let m_totsrv   = 0

     start report bdbsr125_ris       to m_path
    #start report bdbsr125_ris_txt   to m_path_txt #--> RELTXT
     start report bdbsr125_detalhado to m_path2
     start report bdbsr125_detalhado_txt to m_path2_txt #--> RELTXT

     initialize mr_datmservico to null
     initialize mr_dpaksocor to null
     initialize mr_datksrr to null
     initialize mr_datkveiculo to null
     initialize mr_datkmdt to null
     initialize mr_datmlcl to null
     initialize mr_dpamris to null
     initialize mr_dpcmrislauqst to null
     initialize mr_datmservicocmp to null
     initialize mr_iddkdominio to null
     initialize mr_datkassunto to null
     initialize l_cid_uf to null
     initialize l_data to null


     open cbdbsr125003  using m_data
     foreach cbdbsr125003 into mr_datmservico.empcod ,
                               mr_datmservico.atdsrvnum,
                               mr_datmservico.atdsrvano,
                               mr_datmservico.vcllicnum,
                               mr_datmservico.srrcoddig,
                               mr_datmservico.socvclcod,
                               mr_datmservico.atdprscod

          initialize mr_dpaksocor to null
          initialize mr_datksrr to null
          initialize mr_datkveiculo to null
          initialize mr_datkmdt to null
          initialize mr_datmlcl to null
          initialize mr_dpamris to null
          initialize mr_dpcmrislauqst to null
          initialize mr_datmservicocmp to null
          initialize mr_iddkdominio to null
          initialize mr_datkassunto to null
          initialize mr_dpcmgpsrislau to null
          initialize l_cid_uf to null
          initialize l_data to null

          let l_web = 0
          let l_gps = 0

         if  mr_datmservico.atdprscod is null then
             continue foreach
         end if

          open cbdbsr125016 using mr_datmservico.atdsrvnum,
                                  mr_datmservico.atdsrvano,
                                  mr_datmservico.empcod
          fetch cbdbsr125016 into l_web

          if l_web <> 1 then
               open cbdbsr125017 using mr_datmservico.atdsrvnum,
                                       mr_datmservico.atdsrvano
               fetch cbdbsr125017 into l_gps

               if l_gps <> 1 then
                    continue foreach
               end if
          end if

         if  l_ulpstcoddig is null then
             let l_ulpstcoddig = mr_datmservico.atdprscod
         end if

         if  mr_datmservico.atdprscod <> l_ulpstcoddig then
             output to report bdbsr125_ris(l_ulpstcoddig)
            #output to report bdbsr125_ris_txt(l_ulpstcoddig) #--> RELTXT

             let l_ulpstcoddig = mr_datmservico.atdprscod
             let m_totpend  = 0
             let m_totenvok = 0
             let m_totenvfp = 0
             let m_totsrv   = 0

         end if

         if l_web = 1 then
            case mr_bdbsr125.risldostt
               when 0 # NAO PREENCHIDO = PENDENTE
                  let m_totpend = m_totpend + 1
               when 1 # ENVIADO DENTRO DO PRAZO = OK
                  let m_totenvok = m_totenvok + 1
               when 2 # ENVIADO FORA DO PRAZO
                  let m_totenvfp = m_totenvfp + 1
            end case
         else
            let m_totenvok = m_totenvok + 1
         end if

         open cbdbsr125004 using mr_datmservico.atdsrvnum,
                               mr_datmservico.atdsrvano
         fetch cbdbsr125004 into mr_dpcmgpsrislau.rislaucod,
                                 mr_dpcmgpsrislau.relmodnom
         close cbdbsr125004

         open cbdbsr125005 using mr_datmservico.atdprscod   #mr_dpcmgpsrislau.pstcoddig
         fetch cbdbsr125005 into mr_dpaksocor.nomgrr,
                                 mr_dpaksocor.dddcod,
                                 mr_dpaksocor.teltxt,
                                 mr_dpaksocor.pstcoddig
         close cbdbsr125005

         open cbdbsr125006 using mr_datmservico.srrcoddig
         fetch cbdbsr125006 into mr_datksrr.srrabvnom
         close cbdbsr125006

         open cbdbsr125007 using mr_datmservico.socvclcod
         fetch cbdbsr125007 into mr_datkveiculo.atdvclsgl,
                                 mr_datkveiculo.celdddcod,
                                 mr_datkveiculo.celtelnum,
                                 mr_datkveiculo.mdtcod
         close cbdbsr125007

         open cbdbsr125008 using mr_datkveiculo.mdtcod
         fetch cbdbsr125008 into mr_datkmdt.mdtcfgcod
         close cbdbsr125008

         open cbdbsr125009 using mr_datmservico.atdsrvnum,
                                mr_datmservico.atdsrvano
         fetch cbdbsr125009 into mr_datmlcl.lgdtip,
                                 mr_datmlcl.lgdnom,
                                 mr_datmlcl.lgdnum,
                                 mr_datmlcl.lclbrrnom,
                                 mr_datmlcl.cidnom,
                                 mr_datmlcl.ufdcod,
                                 mr_datmlcl.lgdcep,
                                 mr_datmlcl.lgdcepcmp
         close cbdbsr125009

         open cbdbsr125010 using mr_datmservico.atdsrvnum,
                                mr_datmservico.atdsrvano
         fetch cbdbsr125010 into mr_datmservicocmp.sindat,
                                 mr_datmservicocmp.sinhor
         close cbdbsr125010

         open cbdbsr125011 using mr_datmservico.empcod,
                                mr_datmservico.atdsrvnum,
                                mr_datmservico.atdsrvano
         fetch cbdbsr125011 into mr_dpamris.envdat,
                                 mr_dpamris.risldostt
         close cbdbsr125011

         open cbdbsr125012 using mr_dpcmgpsrislau.rislaucod
         fetch cbdbsr125012 into mr_dpcmrislauqst.qsttxt
         close cbdbsr125012

         let l_var = 'eqttipcod'
         open cbdbsr125013 using l_var, mr_datkmdt.mdtcfgcod
         fetch cbdbsr125013 into  mr_iddkdominio.cpodes
         close cbdbsr125013

         open cbdbsr125014 using mr_datmservico.atdsrvnum,
                                     mr_datmservico.atdsrvano
         fetch cbdbsr125014 into mr_datkassunto.c24astcod
         close cbdbsr125014

         open cbdbsr125015 using mr_datkassunto.c24astcod
         fetch cbdbsr125015 into  mr_iddkdominio.cponom
         close cbdbsr125015

         let m_totsrv = m_totsrv + 1

         output to report bdbsr125_detalhado()
         output to report bdbsr125_detalhado_txt() #--> RELTXT
     end foreach
     close cbdbsr125003

     if mr_datmservico.atdsrvnum is null then
          output to report bdbsr125_detalhado()
          output to report bdbsr125_detalhado_txt() #--> RELTXT
     end  if

     output to report bdbsr125_ris(l_ulpstcoddig)
    #output to report bdbsr125_ris_txt(l_ulpstcoddig) #--> RELTXT

     finish report bdbsr125_ris
    #finish report bdbsr125_ris_txt #--> RELTXT
     finish report bdbsr125_detalhado
     finish report bdbsr125_detalhado_txt #--> RELTXT

 end function

#------------------------#
 report bdbsr125_detalhado()
#------------------------#

     define l_risldosttdes      char(020)
     define l_num_ano           char(20)
     define l_fone_prest        char(20)
     define l_fone_viatu        char(20)
     define l_tip_nome_log      char(20)
     define l_data_sinistro     char(20)
     define l_cep               char(10)
     define l_tip_preenchimento char(5)
     define l_veic_sinistrado   char(10)


     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    07

     format

         first page header

         print "RELATORIO SERVIÇOS RIS DETALHADO."
         print ""
         print "EMPRESA"                   ,    ASCII(09),
               "NUMERO/ANO SERVICO"        ,    ASCII(09),
               "MODELO_RELATÓRIO"          ,    ASCII(09),
               "VEIC_SINISTRADO"           ,    ASCII(09),
               "PLACA"                     ,    ASCII(09),
               "COD_PRESTADOR"             ,    ASCII(09),
               "RAZAO SOCIAL"              ,    ASCII(09),
               "TELEFONE_PRESTADOR"        ,    ASCII(09),
               "QRA SOCORRISTA"            ,    ASCII(09),
               "NOME SOCORRISTA"           ,    ASCII(09),
               "COD VTR"                   ,    ASCII(09),
               "TELEFONE_VIATURA"          ,    ASCII(09),#
               "MID_VRT"                   ,    ASCII(09),
               "COD_EQUIP_VTR"             ,    ASCII(09),
               "DESCRICAO_EQUIP_VTR"       ,    ASCII(09),
               "TIPO_NOME_LOGRADOURO_OCOR" ,    ASCII(09),
               "NUMERO_LOGRADOURO_OCOR"    ,    ASCII(09),
               "BAIRRO_OCORRENCIA"         ,    ASCII(09),
               "CIDADE_UF_OCORRENCIA"      ,    ASCII(09),
               "CEP_OCORRENCIA"            ,    ASCII(09),
               "DATA_PREENCHIMENTO"        ,    ASCII(09), #--> FX-080515
               "DATA_SINISTRO"             ,    ASCII(09),
               "TIPO_PREENCHIMENTO"        ,    ASCII(09),
               "STATUS"                    ,    ASCII(09),
               "STRING DO RIS GPS"         ,    ASCII(09)


     on every row
         initialize l_num_ano,
                    l_fone_prest,
                    l_fone_viatu,
                    l_tip_nome_log,
                    l_cid_uf,
                    l_data_sinistro,
                    l_cep,
                    l_veic_sinistrado,
                    l_tip_preenchimento,
                    l_risldosttdes to null

         if mr_datmservico.atdsrvnum is not null then
               let l_num_ano = mr_datmservico.atdsrvnum clipped, '/', mr_datmservico.atdsrvano clipped
         end if
         let l_fone_prest = mr_dpaksocor.dddcod clipped, ' ', mr_dpaksocor.teltxt clipped
         let l_tip_nome_log = mr_datmlcl.lgdtip clipped, ' ', mr_datmlcl.lgdnom clipped

         if mr_datkveiculo.celdddcod is not null then
               let l_fone_viatu = mr_datkveiculo.celdddcod clipped, ' ', mr_datkveiculo.celtelnum clipped
         end if

         if mr_datmlcl.cidnom is not null or mr_datmlcl.cidnom <> "" then
               let l_cid_uf = mr_datmlcl.cidnom clipped, '/', mr_datmlcl.ufdcod clipped
         end if

         let l_data_sinistro = mr_datmservicocmp.sindat clipped, " ", mr_datmservicocmp.sinhor clipped
         if mr_datmlcl.lgdcep is not null or mr_datmlcl.lgdcep <> "" then
               let l_cep = mr_datmlcl.lgdcep clipped, '-', mr_datmlcl.lgdcepcmp clipped
         end if

         if mr_datmservico.atdsrvnum is not null then
              if  mr_iddkdominio.cponom = 'mdlqueris02' then
                 let l_veic_sinistrado = 'TERCEIRO'
              else
                 let l_veic_sinistrado = 'SEGURADO'
              end if

              if mr_dpcmrislauqst.qsttxt is null then
                 let l_tip_preenchimento = 'WEB'
              else
                 let l_tip_preenchimento = 'GPS'
              end if
         end if

         if l_tip_preenchimento = 'WEB' then
              case mr_dpamris.risldostt
                  when 0
                       let l_risldosttdes = "PENDENTE"
                  when 1
                       let l_risldosttdes = "DENTRO DO PRAZO"
                  when 2
                       let l_risldosttdes = "FORA DO PRAZO"
              end case
          else
               let l_risldosttdes = "DENTRO DO PRAZO"
          end if
         print mr_datmservico.empcod       ,ASCII(09),
               l_num_ano                   ,ASCII(09),
               mr_dpcmgpsrislau.relmodnom  ,ASCII(09),  #MODELO RELATORIO
               l_veic_sinistrado           ,ASCII(09),  #VEICULO SINISTRADO
               mr_datmservico.vcllicnum    ,ASCII(09),
               mr_datmservico.atdprscod    ,ASCII(09),
#               mr_dpcmgpsrislau.pstcoddig  ,ASCII(09),
               mr_dpaksocor.nomgrr         ,ASCII(09),
               l_fone_prest                ,ASCII(09),
               mr_datmservico.srrcoddig    ,ASCII(09),
               mr_datksrr.srrabvnom        ,ASCII(09),
               mr_datkveiculo.atdvclsgl    ,ASCII(09),
               l_fone_viatu                ,ASCII(09),
               mr_datkveiculo.mdtcod       ,ASCII(09),
               mr_datkmdt.mdtcfgcod        ,ASCII(09),
               mr_iddkdominio.cpodes       ,ASCII(09),
               l_tip_nome_log              ,ASCII(09),
               mr_datmlcl.lgdnum           ,ASCII(09),
               mr_datmlcl.lclbrrnom        ,ASCII(09),
               l_cid_uf                    ,ASCII(09),
               l_cep                       ,ASCII(09),
               l_data_sinistro             ,ASCII(09),
               l_tip_preenchimento         ,ASCII(09),
               l_risldosttdes              ,ASCII(09),
               mr_dpcmrislauqst.qsttxt     ,ASCII(09)

      on last row
         print ""
         if mr_datmservico.atdsrvnum is null then
           let m_data = ""
         end if
         print "DATA PREENCHIMENTO DOS LAUDOS", ASCII(09), m_data, ASCII(09)

 end report

#-------------------------------------------#
 report bdbsr125_detalhado_txt() #--> RELTXT
#-------------------------------------------#

     define l_risldosttdes      char(020)
     define l_num_ano           char(20)
     define l_fone_prest        char(20)
     define l_fone_viatu        char(20)
     define l_tip_nome_log      char(20)
     define l_data_sinistro     char(20)
     define l_cep               char(10)
     define l_tip_preenchimento char(5)
     define l_veic_sinistrado   char(10)

     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    01

     format

     on every row
         initialize l_num_ano,
                    l_fone_prest,
                    l_fone_viatu,
                    l_tip_nome_log,
                    l_cid_uf,
                    l_data_sinistro,
                    l_cep,
                    l_veic_sinistrado,
                    l_tip_preenchimento,
                    l_risldosttdes to null

         if mr_datmservico.atdsrvnum is not null then
               let l_num_ano = mr_datmservico.atdsrvnum clipped, '/', mr_datmservico.atdsrvano clipped
         end if

         let l_fone_prest = mr_dpaksocor.dddcod clipped, ' ', mr_dpaksocor.teltxt clipped
         let l_tip_nome_log = mr_datmlcl.lgdtip clipped, ' ', mr_datmlcl.lgdnom clipped

         if mr_datkveiculo.celdddcod is not null then
               let l_fone_viatu = mr_datkveiculo.celdddcod clipped, ' ', mr_datkveiculo.celtelnum clipped
         end if

         if mr_datmlcl.cidnom is not null or mr_datmlcl.cidnom <> "" then
               let l_cid_uf = mr_datmlcl.cidnom clipped, '/', mr_datmlcl.ufdcod clipped
         end if

         let l_data_sinistro = mr_datmservicocmp.sindat clipped, " ", mr_datmservicocmp.sinhor clipped
         if mr_datmlcl.lgdcep is not null or mr_datmlcl.lgdcep <> "" then
               let l_cep = mr_datmlcl.lgdcep clipped, '-', mr_datmlcl.lgdcepcmp clipped
         end if

         if mr_datmservico.atdsrvnum is not null then
              if  mr_iddkdominio.cponom = 'mdlqueris02' then
                 let l_veic_sinistrado = 'TERCEIRO'
              else
                 let l_veic_sinistrado = 'SEGURADO'
              end if

              if mr_dpcmrislauqst.qsttxt is null then
                 let l_tip_preenchimento = 'WEB'
              else
                 let l_tip_preenchimento = 'GPS'
              end if
         end if

         if l_tip_preenchimento = 'WEB' then
              case mr_dpamris.risldostt
                  when 0
                       let l_risldosttdes = "PENDENTE"
                  when 1
                       let l_risldosttdes = "DENTRO DO PRAZO"
                  when 2
                       let l_risldosttdes = "FORA DO PRAZO"
              end case
         else
               let l_risldosttdes = "DENTRO DO PRAZO"
         end if

         print mr_datmservico.empcod       ,ASCII(09),
               l_num_ano                   ,ASCII(09),
               mr_dpcmgpsrislau.relmodnom  ,ASCII(09),  #MODELO RELATORIO
               l_veic_sinistrado           ,ASCII(09),  #VEICULO SINISTRADO
               mr_datmservico.vcllicnum    ,ASCII(09),
               mr_datmservico.atdprscod    ,ASCII(09),
#               mr_dpcmgpsrislau.pstcoddig  ,ASCII(09),
               mr_dpaksocor.nomgrr         ,ASCII(09),
               l_fone_prest                ,ASCII(09),
               mr_datmservico.srrcoddig    ,ASCII(09),
               mr_datksrr.srrabvnom        ,ASCII(09),
               mr_datkveiculo.atdvclsgl    ,ASCII(09),
               l_fone_viatu                ,ASCII(09),
               mr_datkveiculo.mdtcod       ,ASCII(09),
               mr_datkmdt.mdtcfgcod        ,ASCII(09),
               mr_iddkdominio.cpodes       ,ASCII(09),
               l_tip_nome_log              ,ASCII(09),
               mr_datmlcl.lgdnum           ,ASCII(09),
               mr_datmlcl.lclbrrnom        ,ASCII(09),
               l_cid_uf                    ,ASCII(09),
               l_cep                       ,ASCII(09),
	             l_data_sinistro             ,ASCII(09),
               l_tip_preenchimento         ,ASCII(09),
               l_risldosttdes              ,ASCII(09),
               mr_dpcmrislauqst.qsttxt     ,ASCII(09),
               m_data

 end report

#--------------------#
 report bdbsr125_ris(l_ulpstcoddig)
#--------------------#

     define m_nomgrr like dpaksocor.nomgrr,
            l_ulpstcoddig like datmservico.atdprscod

     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    07

     format

         first page header

         print "RELATORIO GERAL SERVIÇOS RIS."
         print ""
         print "PRESTADOR",            ASCII(09),
               "NOME",                 ASCII(09),
               "TOTAL DE ATENDIMENTO", ASCII(09),
               "DENTRO DO PRAZO",             ASCII(09),
               "FORA DO PRAZO",        ASCII(09),
               "PENDENTES",            ASCII(09)

     on every row

        print l_ulpstcoddig, ASCII(09);

        open cbdbsr125002 using l_ulpstcoddig
        fetch cbdbsr125002 into m_nomgrr

        print m_nomgrr,   ASCII(09),
              m_totsrv,   ASCII(09),
              m_totenvok, ASCII(09),
              m_totenvfp, ASCII(09),
              m_totpend,  ASCII(09)

 end report

#--------------------------------------------------#
 report bdbsr125_ris_txt(l_ulpstcoddig) #--> RELTXT
#--------------------------------------------------#

     define m_nomgrr like dpaksocor.nomgrr,
            l_ulpstcoddig like datmservico.atdprscod

     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    01

     format

     on every row

        print l_ulpstcoddig, ASCII(09);

        open cbdbsr125002 using l_ulpstcoddig
        fetch cbdbsr125002 into m_nomgrr

        print m_nomgrr,   ASCII(09),
              m_totsrv,   ASCII(09),
              m_totenvok, ASCII(09),
              m_totenvfp, ASCII(09),
              m_totpend,  ASCII(09)

 end report
