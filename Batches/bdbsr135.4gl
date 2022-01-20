#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: BDBSR135.4GL                                              #
# ANALISTA RESP..: CELSO ISSAMU YAMAHAKI                                     #
# PSI/OSF........: PSI-2011-09700/EV                                         #
# OBJETIVO.......: AUTOMATIZACAO NO PROCESSO DE CONFECCAO DE RELATORIOS      #
#                  ACERTO NA AREA                                            #
#............................................................................#
# DESENVOLVIMENTO: CELSO YAMAHAKI                                            #
# LIBERACAO......: 26/07/2011                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
# 02/08/2011  CELSO YAMAHAKI                INCLUSAO DE CAMPOS EMAIL PAGADOR #
#                                           E NOME PAGADOR                   #
# -------------------------------------------------------------------------- #

database porto

define  m_path         char(100),
        m_path_txt     char(100),
        m_data_inicio  date,
        m_data_fim     date,
        m_data         date,
        m_hora         datetime hour to minute


define mr_bdbsr135   record                      
       ligdat          like datmligacao.ligdat       ,          
       lignum          like datmligacao.lignum       ,         
       atdsrvnum       like datmligacao.atdsrvnum    ,         
       atdsrvano       like datmligacao.atdsrvano    ,         
       c24astcod       like datmligacao.c24astcod    ,         
       atdcstvlr       like datmservico.atdcstvlr,         
       c24solnom       like datmligacao.c24solnom,         
       nom             like datmservico.nom          ,         
       srvcor          like datmservico.corsus,   
       lclddd          like datmlcl.dddcod,    
       lcltelnum       like datmlcl.lcltelnum,         
       lclcttnom       like datmlcl.lclcttnom,         
       atdcor          like datrligcor.corsus,   
       empcod          like datrligmat.empcod,         
       usrtip          like datrligmat.usrtip,         
       funmat          like datrligmat.funmat,         
       rhmfunnom       like isskfunc.rhmfunnom,         
       maiusrnom       like grhkmai.maiusrnom,         
       cgccpfnum       like datrligcgccpf.cgccpfnum,         
       cgcord          like datrligcgccpf.cgcord   ,         
       cgccpfdig       like datrligcgccpf.cgccpfdig,         
       telddd          like datrligtel.dddcod,   
       teltxt          like datrligtel.teltxt,         
       pgttipcodps     like dbscadtippgt.pgttipcodps,         
       pgtmat          like dbscadtippgt.pgtmat     ,         
       pagcor          like dbscadtippgt.corsus   ,   
       cctcod          like dbscadtippgt.cctcod   ,         
       succod          like dbscadtippgt.succod   ,         
       pgtempcod       like dbscadtippgt.pgtempcod,
       rhmfunnompgt    like isskfunc.rhmfunnom,
       maiusrnompgt    char (50) #like grhkmai.maiusrnom    
      
end record                                     

main

   initialize mr_bdbsr135.*,
              m_data,
              m_data_inicio,
              m_data_fim,
              m_hora        to null
   
   
   let m_data = arg_val(1)
         
   # ---> OBTER A DATA E HORA DO BANCO 
   if m_data is null then
      call cts40g03_data_hora_banco(2)
      returning m_data,
                m_hora
                
      let m_data_fim = mdy(month(m_data),01,year(m_data)) - 1 units day
      let m_data_inicio = mdy(month(m_data_fim),01,year(m_data_fim))
   else 
      let m_data_inicio = mdy(month(m_data),01,year(m_data))
      let m_data_fim = mdy(month(m_data),01,year(m_data)) + 1 units month - 1 units day
   end if
   
    
   call fun_dba_abre_banco("CT24HS")   
   call cts40g03_exibe_info("I","BDBSR135")
   call bdbsr135_busca_path()
   display ""
   set isolation to dirty read
   call bdbsr135()
   call cts40g03_exibe_info("F","BDBSR135")
   

end main

#----------------------
function bdbsr135()
#----------------------
   
   define l_c24astcod_pso char (100),
          l_sql           char(3000),          
          l_corsuspcp     like gcakcorr.corsuspcp,
          l_cct           like dbscadtippgt.cctcod 
   
   let l_c24astcod_pso = bdbsr135_dominio('c24astcod_pso') 
   
    start report bdbsr135_relatorio to m_path
    start report bdbsr135_relatorio_txt to m_path_txt
    
    set isolation to dirty read;
  
  
      
  let l_sql = "select ligdat         ,     ",                     
                 "       lig.lignum     ,       ",                  
                 "       lig.atdsrvnum  ,       ",              
                 "       lig.atdsrvano  ,       ",              
                 "       c24astcod      ,       ",              
                 "       srv.atdcstvlr  ,       ",              
                 "       lig.c24solnom  ,       ",              
                 "       nom            ,       ",              
                 "       srv.corsus     srvcor, ",              
                 "       lcl.dddcod     lclddd, ",              
                 "       lcl.lcltelnum  ,       ",              
                 "       lcl.lclcttnom  ,       ",              
                 "       cor.corsus     atdcor, ",              
                 "       mat.empcod     ,       ",              
                 "       mat.usrtip     ,       ",              
                 "       mat.funmat     ,       ",              
                 "       cpf.cgccpfnum  ,       ",              
                 "       cpf.cgcord     ,       ",              
                 "       cpf.cgccpfdig  ,       ",              
                 "       tel.dddcod     telddd, ",              
                 "       tel.teltxt     ,       ",              
                 "       tpg.pgttipcodps,       ",              
                 "       tpg.pgtmat     ,       ",              
                 "       tpg.corsus     pagcor, ",              
                 "       tpg.cctcod     ,        ",              
                 "       tpg.succod     ,        ",              
                 "       tpg.pgtempcod           ",              
                 "                               ",              
                 "  from datmligacao lig,        ",              
                 "       datmservico srv,        ",              
                 "       datmlcl lcl,            ",              
                 "       outer datrligcor cor,   ",              
                 "       outer datrligmat mat,   ",              
                 "       outer datrligcgccpf cpf,",              
                 "       outer datrligtel tel,   ",              
                 "       outer dbscadtippgt tpg  ",              
                 " where c24astcod in (",l_c24astcod_pso,")",                       
                 "   and ligdat between '", m_data_inicio,"' and '", m_data_fim,"'",
                 "   and srv.atdsrvnum = lig.atdsrvnum ",              
                 "   and srv.atdsrvano = lig.atdsrvano ",               
                 "   and lcl.atdsrvnum = lig.atdsrvnum ",              
                 "   and lcl.atdsrvano = lig.atdsrvano ",              
                 "   and tpg.nrosrv    = lig.atdsrvnum ",              
                 "   and tpg.anosrv    = lig.atdsrvano ",              
                 "   and c24endtip = 1                 ",              
                 "   and cor.lignum = lig.lignum       ",              
                 "   and mat.lignum = lig.lignum       ",              
                 "   and cpf.lignum = lig.lignum       ",              
                 "   and tel.lignum = lig.lignum       ",
                 " into temp temp_s11 "              
  
   prepare pbdbsr135_02 from l_sql 
   
   
   
   execute  pbdbsr135_02
   
   
   
   declare cbdbsr135_01 cursor with hold for
   
   select temp_s11.ligdat       ,       
          temp_s11.lignum       ,       
          temp_s11.atdsrvnum    ,       
          temp_s11.atdsrvano    ,       
          temp_s11.c24astcod    ,       
          temp_s11.atdcstvlr    ,       
          temp_s11.c24solnom    ,       
          temp_s11.nom          ,       
          temp_s11.srvcor       ,       
          temp_s11.lclddd       ,       
          temp_s11.lcltelnum    ,       
          temp_s11.lclcttnom    ,       
          temp_s11.atdcor       ,       
          temp_s11.empcod       ,       
          temp_s11.usrtip       ,       
          temp_s11.funmat       ,       
          fun.rhmfunnom         ,       
          mai.maiusrnom         ,       
          temp_s11.cgccpfnum    ,       
          temp_s11.cgcord       ,       
          temp_s11.cgccpfdig    ,       
          temp_s11.telddd       ,       
          temp_s11.teltxt       ,       
          temp_s11.pgttipcodps  ,       
          temp_s11.pgtmat       ,       
          temp_s11.pagcor       ,       
          temp_s11.cctcod       ,       
          temp_s11.succod       ,       
          temp_s11.pgtempcod            
     from temp_s11,    
          outer isskfunc fun,
          outer grhkmai mai
    where temp_s11.pgtempcod = fun.empcod
      and temp_s11.usrtip = fun.usrtip
      and temp_s11.funmat = fun.funmat
      and mai.mailgicod [1]   = temp_s11.usrtip
      and mai.mailgicod [2,3] = temp_s11.pgtempcod
      and mai.mailgicod [4,8] = temp_s11.funmat
   
      whenever error continue
   
      
      foreach cbdbsr135_01 into mr_bdbsr135.ligdat        ,
                                mr_bdbsr135.lignum        ,
                                mr_bdbsr135.atdsrvnum     ,
                                mr_bdbsr135.atdsrvano     ,
                                mr_bdbsr135.c24astcod     ,
                                mr_bdbsr135.atdcstvlr     ,
                                mr_bdbsr135.c24solnom     ,
                                mr_bdbsr135.nom           ,
                                mr_bdbsr135.srvcor        ,
                                mr_bdbsr135.lclddd        ,
                                mr_bdbsr135.lcltelnum     ,
                                mr_bdbsr135.lclcttnom     ,
                                mr_bdbsr135.atdcor        ,
                                mr_bdbsr135.empcod        ,
                                mr_bdbsr135.usrtip        ,
                                mr_bdbsr135.funmat        ,
                                mr_bdbsr135.rhmfunnom     ,
                                mr_bdbsr135.maiusrnom     ,
                                mr_bdbsr135.cgccpfnum     ,
                                mr_bdbsr135.cgcord        ,
                                mr_bdbsr135.cgccpfdig     ,
                                mr_bdbsr135.telddd        ,
                                mr_bdbsr135.teltxt        ,
                                mr_bdbsr135.pgttipcodps   ,
                                mr_bdbsr135.pgtmat        ,
                                mr_bdbsr135.pagcor        ,
                                mr_bdbsr135.cctcod        ,
                                mr_bdbsr135.succod        ,
                                mr_bdbsr135.pgtempcod     
         
         case mr_bdbsr135.pgttipcodps
            when 1
               select rhmfunnom
                 into mr_bdbsr135.rhmfunnompgt
                 from isskfunc
                where funmat = mr_bdbsr135.pgtmat
                  and empcod = mr_bdbsr135.pgtempcod
               
               if status = notfound then
                  let mr_bdbsr135.rhmfunnompgt = ""   
               end if   
            
               select maiusrnom
                 into mr_bdbsr135.maiusrnompgt
                 from grhkmai
                where mailgicod [1]   = mr_bdbsr135.usrtip   
                  and mailgicod [2,3] = mr_bdbsr135.pgtempcod
                  and mailgicod [4,8] = mr_bdbsr135.pgtmat
               
               if status = notfound then
                  let mr_bdbsr135.maiusrnompgt = ""   
               end if
            when 2
               select cornom, gcaksusep.corsuspcp
                 into mr_bdbsr135.rhmfunnompgt, l_corsuspcp
                 from gcakcorr,gcaksusep          
                where gcaksusep.corsuspcp = gcakcorr.corsuspcp 
                  and gcaksusep.corsus =  mr_bdbsr135.pagcor
               
               if status = notfound then
                  let mr_bdbsr135.rhmfunnompgt = ""
               end if
               
               select maicod 
                 into mr_bdbsr135.maiusrnompgt
                 from gcakescfil
                where corsuspcp = l_corsuspcp
               
               if status = notfound then
                  let mr_bdbsr135.maiusrnompgt = ""
               end if               
            
            when 3
               
               let l_cct = (mr_bdbsr135.cctcod mod 10000) 
               
               select distinct b.cctdptnom
                 into mr_bdbsr135.rhmfunnompgt 
                 from ctgrlcldpt a,ctgkdpt b 
                where a.cctdptcod = b.cctdptcod 
                  and a.empcod = mr_bdbsr135.pgtempcod
                  and a.succod = mr_bdbsr135.succod
                  and a.cctdptcod  = l_cct
               
               if status = notfound then
                  let mr_bdbsr135.rhmfunnompgt = ""
               end if
               
               
         end case
                           
         output to report bdbsr135_relatorio()   
         output to report bdbsr135_relatorio_txt()                                              
                                                                                                                
         initialize mr_bdbsr135.* , l_corsuspcp, l_cct to null                          
                                                                   
      end foreach                                                  
                                                                   
      close cbdbsr135_01                                           
      whenever error stop
   
   finish report bdbsr135_relatorio
   finish report bdbsr135_relatorio_txt
   
   call bdbsr135_envia_email(m_data_inicio, m_data_fim)

end function


#-------------------------------------#
report bdbsr135_relatorio()
#-------------------------------------#

   
             
  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header
			       
        print "DATA"              , ASCII(09), #1
              "NUMERO_LIG"        , ASCII(09), #2
              "NUMERO_SERV"       , ASCII(09), #3
              "ANO"               , ASCII(09), #4
              "ASSUNTO"           , ASCII(09), #5
              "VALOR"             , ASCII(09), #6
              "SOLICITANTE"       , ASCII(09), #7
              "NOME"              , ASCII(09), #8
              "CORSUS"            , ASCII(09), #9
              "DDD_DO_LOCAL"      , ASCII(09), #10
              "TELEFONE_DO_LOCAL" , ASCII(09), #11
              "CONTATO_DO_LOCAL"  , ASCII(09), #12
              "CORSUS_RELACIONADA", ASCII(09), #13
              "EMPRESA"           , ASCII(09), #14
              "TIPO"              , ASCII(09), #15
              "MATRICULA"         , ASCII(09), #16
              "NOME_RH"           , ASCII(09), #17
              "EMAIL_PORTO"       , ASCII(09), #18
              "CGC/CPF_NUMERO"    , ASCII(09), #19
              "FILIAL"            , ASCII(09), #20
              "DIGITO"            , ASCII(09), #21
              "DDD"               , ASCII(09), #22
              "TELEFONE"          , ASCII(09), #23
              "TIPO_PAGAMENTO"    , ASCII(09), #24
              "MATRICULA_PAGADOR" , ASCII(09), #25
              "SUSEP"             , ASCII(09), #26
              "CENTRO_DE_CUSTO"   , ASCII(09), #27
              "SUCURSAL"          , ASCII(09), #28
              "EMPRESA"           , ASCII(09), #29
              "NOME_PAGADOR"      , ASCII(09), #30
              "E-MAIL_PAGADOR"    , ASCII(09)  #31
                                          
         
  on every row
     
     
     print mr_bdbsr135.ligdat      , ASCII(09);  #1 
     print mr_bdbsr135.lignum      , ASCII(09);  #2 
     print mr_bdbsr135.atdsrvnum   , ASCII(09);  #3 
     print mr_bdbsr135.atdsrvano   , ASCII(09);  #4 
     print mr_bdbsr135.c24astcod   , ASCII(09);  #5 
     print mr_bdbsr135.atdcstvlr   , ASCII(09);  #6 
     print mr_bdbsr135.c24solnom   , ASCII(09);  #7 
     print mr_bdbsr135.nom         , ASCII(09);  #8 
     print mr_bdbsr135.srvcor      , ASCII(09);  #9 
     print mr_bdbsr135.lclddd      , ASCII(09);  #10
     print mr_bdbsr135.lcltelnum   , ASCII(09);  #11
     print mr_bdbsr135.lclcttnom   , ASCII(09);  #12
     print mr_bdbsr135.atdcor      , ASCII(09);  #13
     print mr_bdbsr135.empcod      , ASCII(09);  #14
     print mr_bdbsr135.usrtip      , ASCII(09);  #15
     print mr_bdbsr135.funmat      , ASCII(09);  #16
     print mr_bdbsr135.rhmfunnom   , ASCII(09);  #17
     print mr_bdbsr135.maiusrnom   , ASCII(09);  #18
     print mr_bdbsr135.cgccpfnum   , ASCII(09);  #19
     print mr_bdbsr135.cgcord      , ASCII(09);  #20
     print mr_bdbsr135.cgccpfdig   , ASCII(09);  #21
     print mr_bdbsr135.telddd      , ASCII(09);  #22
     print mr_bdbsr135.teltxt      , ASCII(09);  #23
     print mr_bdbsr135.pgttipcodps , ASCII(09);  #24
     print mr_bdbsr135.pgtmat      , ASCII(09);  #25
     print mr_bdbsr135.pagcor      , ASCII(09);  #26
     print mr_bdbsr135.cctcod      , ASCII(09);  #27
     print mr_bdbsr135.succod      , ASCII(09);  #28
     print mr_bdbsr135.pgtempcod   , ASCII(09);  #29
     print mr_bdbsr135.rhmfunnompgt, ASCII(09);  #30
     print mr_bdbsr135.maiusrnompgt              #31
  
  
end report



function bdbsr135_calcula_datafim(l_data)

   define l_data date
   
   let l_data = l_data + 1 units month - 1 units day
   
   return l_data


end function


function bdbsr135_busca_path()

   define l_dataarq char(8)
   define l_data    date
   
   let l_data = today
   display "l_data: ", l_data
   let l_dataarq = extend(l_data, year to year),
                   extend(l_data, month to month),
                   extend(l_data, day to day)
   display "l_dataarq: ", l_dataarq

   # ---> INICIALIZACAO DAS VARIAVEIS
   let m_path = null

   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
   let m_path = f_path("DBS","LOG")
   
   if m_path is null then
      let m_path = "."
   end if
   let m_path = m_path clipped, "/BDBSR135.log" 
   call startlog(m_path)
   
   # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
   let m_path = f_path("DBS", "RELATO")
   
   if m_path is null then
      let m_path = "."
   end if

   let m_path_txt = m_path clipped, "/BDBSR135_", l_dataarq, ".txt"  
   let m_path = m_path clipped, "/BDBSR135.xls"
   
end function


#-----------------------------------------#
function bdbsr135_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         data_inicial date,
         data_final   date
  end record

  define l_assunto     char(100),
         l_erro_envio  integer,
         l_comando     char(200)

  # ---> INICIALIZACAO DAS VARIAVEIS
  let l_comando    = null
  let l_erro_envio = null
  let l_assunto    = "Relatorio Acerto na Area  - ",
                     
                     " do mes: ",
                     month(lr_parametro.data_inicial),
                     "/",year(lr_parametro.data_inicial)

  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", m_path

  run l_comando
  let m_path = m_path clipped, ".gz"

  let l_erro_envio = ctx22g00_envia_email("BDBSR135", l_assunto, m_path)

  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", m_path
     else
        display "Nao existe email cadastrado para o modulo - BDBSR135"
     end if
  end if

end function

#Funcao que retorna todos os dominios concatenados separados por ',' e entre "'"
#---------------------------------
function bdbsr135_dominio(l_cponom)
#---------------------------------
   
         
   define l_cponom     like iddkdominio.cponom,
          l_cponom_aux like iddkdominio.cponom,
          l_retorno char(500),
          l_qtd     smallint,
          l_cont    smallint
   
   initialize l_cponom_aux, l_retorno to null
   
   whenever error continue
   
   select count(cpodes)
   into   l_qtd
   from   iddkdominio
   where  cponom = l_cponom
   
   let l_cont = 0
   declare cdominio cursor for
      
      select cpodes
      from   iddkdominio
      where  cponom = l_cponom
      
      foreach cdominio into l_cponom_aux  
         
         let l_cponom_aux = "'",l_cponom_aux clipped, "'"
         let l_cont = l_cont + 1         
         if l_qtd = 1 then
            let l_retorno = l_retorno clipped, l_cponom_aux clipped
            return l_retorno clipped
         else
            if l_cont = 1 then
               let l_retorno = l_retorno clipped, l_cponom_aux clipped
            else
               let l_retorno = l_retorno clipped, ',', l_cponom_aux clipped
            end if
         end if
         
         initialize l_cponom_aux to null
      
         
      end foreach
   whenever error stop
   return l_retorno clipped


end function

#-------------------------------------#
report bdbsr135_relatorio_txt()
#-------------------------------------#

   
             
  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

  format

     on every row
     
     
     print mr_bdbsr135.ligdat      , ASCII(09);  #1 
     print mr_bdbsr135.lignum      , ASCII(09);  #2 
     print mr_bdbsr135.atdsrvnum   , ASCII(09);  #3 
     print mr_bdbsr135.atdsrvano   , ASCII(09);  #4 
     print mr_bdbsr135.c24astcod   , ASCII(09);  #5 
     print mr_bdbsr135.atdcstvlr   , ASCII(09);  #6 
     print mr_bdbsr135.c24solnom   , ASCII(09);  #7 
     print mr_bdbsr135.nom         , ASCII(09);  #8 
     print mr_bdbsr135.srvcor      , ASCII(09);  #9 
     print mr_bdbsr135.lclddd      , ASCII(09);  #10
     print mr_bdbsr135.lcltelnum   , ASCII(09);  #11
     print mr_bdbsr135.lclcttnom   , ASCII(09);  #12
     print mr_bdbsr135.atdcor      , ASCII(09);  #13
     print mr_bdbsr135.empcod      , ASCII(09);  #14
     print mr_bdbsr135.usrtip      , ASCII(09);  #15
     print mr_bdbsr135.funmat      , ASCII(09);  #16
     print mr_bdbsr135.rhmfunnom   , ASCII(09);  #17
     print mr_bdbsr135.maiusrnom   , ASCII(09);  #18
     print mr_bdbsr135.cgccpfnum   , ASCII(09);  #19
     print mr_bdbsr135.cgcord      , ASCII(09);  #20
     print mr_bdbsr135.cgccpfdig   , ASCII(09);  #21
     print mr_bdbsr135.telddd      , ASCII(09);  #22
     print mr_bdbsr135.teltxt      , ASCII(09);  #23
     print mr_bdbsr135.pgttipcodps , ASCII(09);  #24
     print mr_bdbsr135.pgtmat      , ASCII(09);  #25
     print mr_bdbsr135.pagcor      , ASCII(09);  #26
     print mr_bdbsr135.cctcod      , ASCII(09);  #27
     print mr_bdbsr135.succod      , ASCII(09);  #28
     print mr_bdbsr135.pgtempcod   , ASCII(09);  #29
     print mr_bdbsr135.rhmfunnompgt, ASCII(09);  #30
     print mr_bdbsr135.maiusrnompgt              #31
  
  
end report