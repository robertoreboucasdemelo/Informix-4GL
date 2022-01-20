#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema       :                                                             #
# Modulo        : bdbsr010.4gl                                                #
#                 Acionamentos Brasil                                         #
# Analista Resp.: Wagner Agostinho                                            #
# PSI           :                                                             #
#               :                                                             #
#                                                                             #
#.............................................................................#
# Desenvolvimento: Fabrica de Software, Alexandre Souza                       #
# Liberacao      :   /  /                                                     #
#.............................................................................#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 29/06/2004 Marcio, Meta      PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
# ---------- --------------------- ------ ------------------------------------#
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
###############################################################################

database porto


   define m_bdbsr010       record
          socvclcod        like datmservico.socvclcod
         ,atddat           like datmservico.atddat
         ,atdsrvorg        like datmservico.atdsrvorg
         ,atdsrvnum        like datmservico.atdsrvnum
         ,atdsrvano        like datmservico.atdsrvano
         ,atdhorpvt        like datmservico.atdhorpvt
         ,asitipcod        like datmservico.asitipcod
         ,srvtipabvdes     like datksrvtip.srvtipabvdes
         ,mpacidcod        like dpaksocor.mpacidcod
         ,pstcoddig        like dpaksocor.pstcoddig
         ,nomgrr           like dpaksocor.nomgrr
         ,qldgracod        like dpaksocor.qldgracod
         ,endcid           like dpaksocor.endcid
         ,endufd           like dpaksocor.endufd
         ,cidnom           like datmlcl.cidnom
         ,ufdcod           like datmlcl.ufdcod
         ,mdtcod           like datkmdt.mdtcod
         ,mdtstt           like datkmdt.mdtstt
         ,lclltt           like datmlcl.lclltt
         ,lcllgt           like datmlcl.lcllgt
         ,distancia        integer
         ,atdprscod        like datmservico.atdprscod
   end record

   define ws_data_de   date
         ,ws_data_ate  date
         ,ws_auxdat    char(10)
         ,ws_flgcab    smallint
         ,ws_pathrel01 char(60)
         ,ws_run       char(400)
         ,ws_atdetpcod like datmsrvacp.atdetpcod

   define m_totreg         integer
         ,m_cmd            char(200)

 define m_path  char(100)

   main


   define l_dia   date
         ,l_hora  datetime hour to second

   let l_dia  = today
   let l_hora = time

#  display "INICIO DO PROCESSAMENTO: ", l_dia, " ", l_hora

   call fun_dba_abre_banco("CT24HS")
   call bdbsr010()

   let l_dia  = today
   let l_hora = time

#  display ""
#  display "FIM DO PROCESSAMENTO: ", l_dia, " ", l_hora

end main

#------------------------------------------------------------------------------
function bdbsr010()
#------------------------------------------------------------------------------

   define l_retorno smallint

   define l_regmdt     char(01)
   define l_flgsta     char(01)

   define l_ret        record
          result       integer
         ,sclltt       like datkmpacid.lclltt
         ,scllgt       like datkmpacid.lcllgt
   end record

   initialize m_bdbsr010.*
             ,l_ret.*      to null

   let m_totreg = 0
   let l_regmdt = "N"
   let l_flgsta = "N"
   let ws_flgcab    = 0

   let m_path = f_path("DBS","ARQUIVO")
    if m_path is null then
       let m_path = "."
    end if

   let ws_pathrel01 = m_path clipped,"/BDBSR010.TXT"

   #----------------------------------
   # Data para execucao
   #----------------------------------
   let ws_auxdat = arg_val(1)

   if ws_auxdat is null  or
      ws_auxdat =  "  "  then
      if time  >= "17:00"   and
         time  <= "23:59"   then
         let ws_auxdat = today
      else
         let ws_auxdat = today - 1
      end if
   else
     if length(ws_auxdat) < 10  then
         display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
         exit program
     end if
   end if

   let ws_auxdat   = "01","/", ws_auxdat[4,5],"/", ws_auxdat[7,10]
   let ws_data_ate = ws_auxdat
   let ws_data_ate = ws_data_ate - 1 units day

   let ws_auxdat   = ws_data_ate
   let ws_auxdat   = "01","/", ws_auxdat[4,5],"/", ws_auxdat[7,10]
   let ws_data_de  = ws_auxdat
   #----------------------------------

   #----------------------------------
   # Nome arquivo destino
   #----------------------------------
   let ws_pathrel01 = m_path clipped,"/BDBSR010","_", ws_auxdat[4,5],".TXT"
   #----------------------------------

   let m_cmd = "select socvclcod "
                    ,",atddat "
                    ,",atdsrvorg "
                    ,",atdsrvnum "
                    ,",atdsrvano "
                    ,",atdhorpvt "
                    ,",asitipcod "
                    ,",atdprscod "
              ,"  from datmservico "
              ," where atddat between ? and ? "
   prepare pbdbsr010001 from m_cmd
   declare cbdbsr010001 cursor for pbdbsr010001

   let m_cmd = "select mdtcod "
              ,"  from datkveiculo "
              ," where socvclcod = ? "
   prepare pbdbsr010002 from m_cmd
   declare cbdbsr010002 cursor for pbdbsr010002

   let m_cmd = "select mdtcod "
              ,"  from datkmdt "
              ," where mdtcod = ? "
   prepare pbdbsr010003 from m_cmd
   declare cbdbsr010003 cursor for pbdbsr010003

   let m_cmd = "select srvtipabvdes "
              ,"  from datksrvtip "
              ," where atdsrvorg = ? "
   prepare pbdbsr010004 from m_cmd
   declare cbdbsr010004 cursor for pbdbsr010004

   let m_cmd = "select pstcoddig "
                    ,",nomgrr "
                    ,",qldgracod "
                    ,",endcid "
                    ,",endufd "
                    ,",mpacidcod "
              ,"  from dpaksocor "
              ," where pstcoddig = ? "
   prepare pbdbsr010005 from m_cmd
   declare cbdbsr010005 cursor for pbdbsr010005

   let m_cmd = "select cidnom "
                    ,",ufdcod "
                    ,",lclltt "
                    ,",lcllgt "
              ,"  from datmlcl "
              ," where atdsrvnum = ? "
                ," and atdsrvano = ? "
                ," and c24endtip = 1 "
   prepare pbdbsr010006 from m_cmd
   declare cbdbsr010006 cursor for pbdbsr010006

   let m_cmd = "select atdetpcod    ",
               "  from datmsrvacp   ",
               " where atdsrvnum = ?",
               "   and atdsrvano = ?",
               "   and atdsrvseq = (select max(atdsrvseq)",
                                   "  from datmsrvacp    ",
                                   " where atdsrvnum = ? ",
                                   "   and atdsrvano = ?)"
   prepare sel_datmsrvacp from m_cmd
   declare c_datmsrvacp cursor for sel_datmsrvacp

   let m_cmd = "select cpodes ",
               "  from iddkdominio ",
               " where iddkdominio.cponom = 'qldgracod' ",
               "   and iddkdominio.cpocod = ? "
   prepare sel_iddkdominio from m_cmd
   declare c_iddkdominio cursor for sel_iddkdominio


#------------ INICIO DO PROCRESSO --------------
   open cbdbsr010001 using ws_data_de
                          ,ws_data_ate
   foreach cbdbsr010001 into m_bdbsr010.socvclcod
                            ,m_bdbsr010.atddat
                            ,m_bdbsr010.atdsrvorg
                            ,m_bdbsr010.atdsrvnum
                            ,m_bdbsr010.atdsrvano
                            ,m_bdbsr010.atdhorpvt
                            ,m_bdbsr010.asitipcod
                            ,m_bdbsr010.atdprscod

      if m_bdbsr010.atdsrvorg = 1  or   # SOCORRO
         m_bdbsr010.atdsrvorg = 2  or   # TRANSPORTE
         m_bdbsr010.atdsrvorg = 4  or   # REMOCAO
         m_bdbsr010.atdsrvorg = 5  or   # RPT
         m_bdbsr010.atdsrvorg = 6  or   # DAF
         m_bdbsr010.atdsrvorg = 7  or   # REPLACE
         m_bdbsr010.atdsrvorg = 17 then # REPLACE CONGENERES
         # OK servicos validos
      else
         continue foreach
      end if

      #-----------------------------
      # Verifica etapa dos servicos
      #-----------------------------
      open  c_datmsrvacp using  m_bdbsr010.atdsrvnum
                               ,m_bdbsr010.atdsrvano
                               ,m_bdbsr010.atdsrvnum
                               ,m_bdbsr010.atdsrvano
      fetch c_datmsrvacp into  ws_atdetpcod
      close c_datmsrvacp
      if ws_atdetpcod <> 4 then
         continue foreach
      end if

      #---> Ok sem MDT <---#
      let l_regmdt = "N"

      whenever error continue
      open cbdbsr010002 using m_bdbsr010.socvclcod
      whenever error stop

      if sqlca.sqlcode < 0 then
         display "ERRO NO CURSOR: cbdbsr010002, Nro.: ",sqlca.sqlcode
         exit program(1)
      end if

      whenever error continue
      fetch cbdbsr010002 into m_bdbsr010.mdtcod
      whenever error stop

      if sqlca.sqlcode < 0 then
         display "ERRO NO CURSOR: cbdbsr010002, Nro.: ",sqlca.sqlcode
         exit program(1)
      else
         if sqlca.sqlcode = notfound then
            let l_regmdt = "S"
         else
            #---> Ok sem MDT <---#
            whenever error continue
            open cbdbsr010003 using m_bdbsr010.mdtcod
            whenever error stop

            if sqlca.sqlcode < 0 then
               display "ERRO NO CURSOR: cbdbsr010003, Nro.: ",sqlca.sqlcode
               exit program(1)
            end if

            whenever error continue
            fetch cbdbsr010003 into m_bdbsr010.mdtstt
            whenever error stop

            if sqlca.sqlcode < 0 then
               display "ERRO NO CURSOR: cbdbsr010003, Nro.: ",sqlca.sqlcode
               exit program(1)
            end if

            if m_bdbsr010.mdtstt = 0 then
               continue foreach
            else
               if m_bdbsr010.mdtstt = 1 then
                  let l_regmdt = "S"
               end if
            end if
         end if
      end if

      if l_regmdt = "S" then
         if l_flgsta = "N" then
            #---> Inicia Arquivo <---#
            start report rel_bdbsr010 to ws_pathrel01
            let l_flgsta = "S"
         end if

         whenever error continue
         open cbdbsr010004 using m_bdbsr010.atdsrvorg
         whenever error stop

         if sqlca.sqlcode < 0 then
            display "ERRO NO CURSOR: cbdbsr010004, Nro.: ",sqlca.sqlcode
            exit program(1)
         end if

         whenever error continue
         fetch cbdbsr010004 into m_bdbsr010.srvtipabvdes
         whenever error stop

         if sqlca.sqlcode < 0 then
            display "ERRO NO CURSOR: cbdbsr010004, Nro.: ",sqlca.sqlcode
            exit program(1)
         else
            if sqlca.sqlcode = 100 then
               continue foreach
            end if
         end if

         whenever error continue
         open cbdbsr010005 using m_bdbsr010.atdprscod
         whenever error stop

         if sqlca.sqlcode < 0 then
            display "ERRO NO CURSOR: cbdbsr010005, Nro.: ",sqlca.sqlcode
            exit program(1)
         end if

         whenever error continue
         fetch cbdbsr010005 into m_bdbsr010.pstcoddig
                                ,m_bdbsr010.nomgrr
                                ,m_bdbsr010.qldgracod
                                ,m_bdbsr010.endcid
                                ,m_bdbsr010.endufd
                                ,m_bdbsr010.mpacidcod
         whenever error stop

         if sqlca.sqlcode < 0 then
            display "ERRO NO CURSOR: cbdbsr010005, Nro.: ",sqlca.sqlcode
            exit program(1)
         else
            if sqlca.sqlcode = 100 then
               continue foreach
            end if
         end if

         whenever error continue
         open cbdbsr010006 using m_bdbsr010.atdsrvnum
                                ,m_bdbsr010.atdsrvano
         whenever error stop

         if sqlca.sqlcode < 0 then
            display "ERRO NO CURSOR: cbdbsr010006, Nro.: ",sqlca.sqlcode
            exit program(1)
         end if

         whenever error continue
         fetch cbdbsr010006 into m_bdbsr010.cidnom
                                ,m_bdbsr010.ufdcod
                                ,m_bdbsr010.lclltt
                                ,m_bdbsr010.lcllgt
         whenever error stop

         if sqlca.sqlcode < 0 then
            display "ERRO NO CURSOR: cbdbsr010006, Nro.: ",sqlca.sqlcode
            exit program(1)
         else
            if sqlca.sqlcode = 100 then
               continue foreach
            end if
         end if

         call cts23g00_inf_cidade(3
                                 ,m_bdbsr010.mpacidcod
                                 ,""
                                 ,"")
            returning l_ret.result
                     ,l_ret.sclltt
                     ,l_ret.scllgt

         call cts18g00(l_ret.sclltt
                      ,l_ret.scllgt
                      ,m_bdbsr010.lclltt
                      ,m_bdbsr010.lcllgt)
            returning m_bdbsr010.distancia

         #---> Gera Arquivo <---#
         output to report rel_bdbsr010()

      end if
   end foreach

   if l_flgsta <> "N" then
      #---> Termina Arquivo <---#
      finish report rel_bdbsr010

      let ws_run = "Acionamento Brasil"
      let l_retorno = ctx22g00_envia_email("BDBSR010",
                                           ws_run,
                                           ws_pathrel01)
      if l_retorno <> 0 then
         if l_retorno <> 99 then
            display "Erro ao enviar email(ctx22g00) - ",ws_pathrel01
         else
            display "Nao existe email cadastrado para este modulo - BDBSR010"
         end if
      end if

      #------------------------------------------------------------------
      # E-MAIL PORTO SOCORRO
      #------------------------------------------------------------------
      #let ws_run =  "mailx -s 'Acionamento Brasil: ",
      #              ws_auxdat[4,5],"/", ws_auxdat[7,10], "' ",
      #              "agostinho_wagner/spaulo_info_sistemas@u55 < ",
      #              ws_pathrel01 clipped
      #run ws_run
   end if

end function

#------------------------------------------------------------------------------
report rel_bdbsr010()
#------------------------------------------------------------------------------

  define ws_descqual   char(20)

  output left margin   0
         right margin  0
         page length   1
         top margin    0
         bottom margin 0

  format

    on every row

       if ws_flgcab = 0 then
          let ws_flgcab = 1
          print column 001, "Dt_Atend.",      "|"
                          , "Origem_Srv",     "|"
                          , "Tipo_Srv",       "|"
                          , "Nr_Srv",         "|"
                          , "Ano_Srv",        "|"
                          , "Cidade_Srv",     "|"
                          , "UF_Srv",         "|"
                          , "Cod_Prestador",  "|"
                          , "Nome_Prestador", "|"
                          , "Qualidade",      "|"
                          , "Cidade_Prest.",  "|"
                          , "UF_Prest.",      "|"
                          , "Previsao",       "|"
                          , "Distancia",      "|"
                          , "Tipo_Assist.",   "|"
                          , ascii(13)
       end if

       whenever error continue
       open  c_iddkdominio using m_bdbsr010.qldgracod
       fetch c_iddkdominio into  ws_descqual
       close c_iddkdominio
       whenever error stop

       print column 001, m_bdbsr010.atddat,         "|"
                       , m_bdbsr010.atdsrvorg,      "|"
                       , m_bdbsr010.srvtipabvdes,   "|"
                       , m_bdbsr010.atdsrvnum,      "|"
                       , m_bdbsr010.atdsrvano,      "|"
                       , m_bdbsr010.cidnom clipped, "|"
                       , m_bdbsr010.ufdcod,         "|"
                       , m_bdbsr010.pstcoddig,      "|"
                       , m_bdbsr010.nomgrr clipped, "|"
#                      , m_bdbsr010.qldgracod,      "|"
                       , ws_descqual clipped,       "|"
                       , m_bdbsr010.endcid clipped, "|"
                       , m_bdbsr010.endufd,         "|"
                       , m_bdbsr010.atdhorpvt,      "|"
                       , m_bdbsr010.distancia,      "|"
                       , m_bdbsr010.asitipcod,      "|"
                       , ascii(13)

end report
#---------------------------------------------------------------------------
