###############################################################################
# Nome do Modulo: CTB17M00                                           Marcelo  #
#                                                                    Gilberto #
#                                                                    Wagner   #
# Consulta Analise de servicos                                       Nov/1999 #
###############################################################################
# Alteracoes:                                                                 # 
#                                                                             # 
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             # 
#-----------------------------------------------------------------------------# 
# 29/03/2000  PSI 10428-0  Wagner       Incluir funcao para consulta do histo-#
#                                       rico (cta05m04).                      #
#-----------------------------------------------------------------------------# 
# 11/04/2000  PSI 10426-4  Wagner       Permitir mais de um evento de analise #
#                                       para o mesmo servico.                 #
#-----------------------------------------------------------------------------# 
# 30/05/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
#-----------------------------------------------------------------------------# 
# 27/06/2001  PSI 13252-7  Wagner       Inclusao pesquisa por QRA.            #
#-----------------------------------------------------------------------------# 
# 18/10/2001  PSI 13253-5  Wagner       Inclusao pesq.analise historico QRA   #
#-----------------------------------------------------------------------------# 
# 06/11/2001  Correio      Wagner       Conf.Eduardo aumentar range pesquisa  #
#                                       de 10 para 31 dias.  PROVISORIO       #
#-----------------------------------------------------------------------------# 
# 10/07/2006  PSI 197858   Priscila     Ordenar por fase - reestruturacao tela#
#                                       reconstrucao do codigo fonte          #
#-----------------------------------------------------------------------------# 
# 25/10/2006  Correio      Priscila     Buscar fase de analise para cada seq  #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define d_ctb17m00   record
    atdsrvorg        like datmservico.atdsrvorg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    pstcoddig        like dpaksocor.pstcoddig,
    nomgrr           like dpaksocor.nomgrr,
    srrcoddig        like datksrr.srrcoddig,
    srrabvnom        like datksrr.srrabvnom,
    c24evtcod        like datkevt.c24evtcod,
    c24evtrdzdes     like datkevt.c24evtrdzdes,
    c24fsecod        like datkfse.c24fsecod,
    c24fsedes        like datkfse.c24fsedes,
    dataini          date,
    datafim          date,
    total            char(06)
 end record 
    
 define a_ctb17m00   array[2000] of record
    atdsrvorg_arr    like datmservico.atdsrvorg,
    atdsrvnum_arr    like datmsrvanlhst.atdsrvnum,
    atdsrvano_arr    like datmsrvanlhst.atdsrvano,
    atddat_arr       like datmservico.atddat,
    atdhor_arr       like datmservico.atdhor,
    srvtipabvdes_arr like datksrvtip.srvtipabvdes,
    c24evtrdzdes_arr like datkevt.c24evtrdzdes,
    c24fsedes_arr    like datkfse.c24fsedes,
    pstcoddig_arr    like datmservico.atdprscod,
    nomgrr_arr       like dpaksocor.nomgrr,
    caddat_arr       like datmsrvanlhst.caddat,
    funnom_arr       like isskfunc.funnom
 end record
 
 #array auxiliar - com informações que nao estão na tela do array principal
 define a2_ctb17m00   array[2000] of record
    c24evtcod        like datkevt.c24evtcod 
 end record

 define m_prepare  smallint
 define m_arr_aux  smallint
 define m_atualiza smallint

#-----------------------------------------------------------
 function ctb17m00_prepare()                             
#-----------------------------------------------------------
 define l_sql char(600)

 #------------------------------------------------ 
 # SQL - nome prestador
 #------------------------------------------------ 
 let l_sql = "select nomgrr                  ",
                "  from dpaksocor               ",
                " where dpaksocor.pstcoddig = ? "
 prepare pctb17m00001 from l_sql
 declare cctb17m00001  cursor for  pctb17m00001

 #------------------------------------------------ 
 # SQL - nome motorista 
 #------------------------------------------------ 
 let l_sql = "select srrabvnom             ",
                "  from datksrr               ",
                " where datksrr.srrcoddig = ? "
 prepare pctb17m00002 from l_sql
 declare cctb17m00002  cursor for  pctb17m00002

 #------------------------------------------------ 
 # SQL - Descricao da fase
 #------------------------------------------------ 
 let l_sql = "select c24fsedes              ",
                "  from datkfse                ",
                " where datkfse.c24fsecod =  ? "
 prepare pctb17m00003 from l_sql
 declare cctb17m00003  cursor for  pctb17m00003

 #------------------------------------------------ 
 # SQL descricao do evento
 #------------------------------------------------ 
 let l_sql = "select c24evtrdzdes           ",
                "  from datkevt                ",
                " where datkevt.c24evtcod =  ? "
 prepare pctb17m00004 from l_sql
 declare cctb17m00004  cursor for  pctb17m00004

 #------------------------------------------------ 
 # SQL - Descricao do tipo de servico
 #------------------------------------------------ 
 let l_sql = "select srvtipabvdes             ",
                "  from datksrvtip               ",
                " where datksrvtip.atdsrvorg = ? "
 prepare pctb17m00005 from l_sql
 declare cctb17m00005  cursor for  pctb17m00005

 #------------------------------------------------ 
 # SQL - Nome do funcionario
 #------------------------------------------------ 
 let l_sql = "select funnom              ",
                "  from isskfunc            ",
                " where isskfunc.empcod = 1 ",
                "   and isskfunc.funmat = ? " 
 prepare pctb17m00006 from l_sql
 declare cctb17m00006  cursor for  pctb17m00006

 #------------------------------------------------ 
 # SQL - Ultima fase do servico 
 #------------------------------------------------ 
 let l_sql = "select c24fsecod     ", 
                 "  from datmsrvanlhst ",
                 " where atdsrvnum = ? ",
                 "   and atdsrvano = ? ",
                 "   and c24evtcod = ? ",
                 "   and srvanlhstseq = (select max(srvanlhstseq)",
                                       "   from datmsrvanlhst  ",
                                       "  where atdsrvnum = ?  ",
                                       "    and atdsrvano = ?  ",
                                       "    and c24evtcod = ? )"
 prepare pctb17m00007 from l_sql 
 declare cctb17m00007 cursor for pctb17m00007  

 #------------------------------------------------ 
 # SQL - Numero da ligacao           
 #------------------------------------------------ 
 let l_sql = "select lignum        ", 
                 "  from datmligacao   ",
                 " where atdsrvnum = ? ",
                 "   and atdsrvano = ? ",
                 "   and lignum    > 0 "
 prepare pctb17m00008 from l_sql 
 declare cctb17m00008 cursor for pctb17m00008  
 
 #------------------------------------------------ 
 # SQL - Origem do servico           
 #------------------------------------------------
 let l_sql = "select atdsrvorg     ",
             " from datmservico    ",
             " where atdsrvnum = ? ",
             "   and atdsrvano = ? "
 prepare pctb17m00009 from l_sql 
 declare cctb17m00009 cursor for pctb17m00009      
 
 #------------------------------------------------ 
 # SQL - Existe historico de analise para servico
 #------------------------------------------------
 let l_sql = "select count(*)    ",   
             " from datmsrvanlhst ",
             " where datmsrvanlhst.atdsrvnum    = ?  ",
             "   and datmsrvanlhst.atdsrvano    = ?  ",
             "   and datmsrvanlhst.c24evtcod    <> 0 ", 
             "   and datmsrvanlhst.srvanlhstseq  = 1 "   
 prepare pctb17m00010 from l_sql 
 declare cctb17m00010 cursor for pctb17m00010      
 
 #------------------------------------------------ 
 # SQL - Historico de analise para socorrista
 #------------------------------------------------
 let l_sql = " select datmsrranlhst.c24evtcod,   ",
             "        datmsrranlhst.fasmdcdat,   ",
             "        datmsrranlhst.cadmat   ,   ",   
             "        datmsrranlhst.socopgfascod ",
             "  from datmsrranlhst               ",
             " where datmsrranlhst.srrcoddig = ? ",
             "   and datmsrranlhst.c24evtcod <> 0 ",  
             "   and datmsrranlhst.evtocrdat is not null      ",
             "   and datmsrranlhst.evtanlseq = 1              ",
             "   and datmsrranlhst.fasmdcdat between ? and ?  " 
 prepare pctb17m00012 from l_sql                                        
 declare cctb17m00012 cursor for pctb17m00012 
 
 #------------------------------------------------ 
 # SQL - sequencia do historico de analise do servico
 #------------------------------------------------
 let l_sql = " select datmsrvanlhst.c24fsecod,   ",    #25/10/06 Pri
             "        datmsrvanlhst.srvanlhstseq,",
             "        datmsrvanlhst.caddat,      ",
             "        datmsrvanlhst.cadmat       ",
             " from datmsrvanlhst                ",
             "where datmsrvanlhst.atdsrvnum = ?  ",
             "  and datmsrvanlhst.atdsrvano = ?  ",
             "  and datmsrvanlhst.c24evtcod = ?  "
 prepare pctb17m00014 from l_sql                           
 declare cctb17m00014 cursor for pctb17m00014  
 
 let m_prepare = true

end function

#-----------------------------------------------------------
 function ctb17m00()                             
#-----------------------------------------------------------

 initialize d_ctb17m00.*    to null

 open window ctb17m00 at 06,02 with form "ctb17m00"
             attribute (form line first)    
 
 while true
   initialize a_ctb17m00  to null
   initialize a2_ctb17m00  to null

   #chamar funcao para dar input dos dados - carrega d_ctb17m00
   call ctb17m00_input()

   if int_flag then
      exit while
   else
      let m_atualiza = true
   end if

   #chamar funcao para carregar array a_ctb17m00
   call ctb17m00_carrega_dados()

   #chamar funcao para exibir dados do array na tela
   call ctb17m00_display_array()
       
 end while

 close window ctb17m00
 let int_flag = false

end function  #  ctb17m00

#-----------------------------------------------------------
function ctb17m00_input()
#-----------------------------------------------------------
   define l_count  smallint
   
   if m_prepare <> true then
      call ctb17m00_prepare()
   end if

   let int_flag = false

   input by name d_ctb17m00.atdsrvnum,
                 d_ctb17m00.atdsrvano,    
                 d_ctb17m00.pstcoddig,    
                 d_ctb17m00.srrcoddig,    
                 d_ctb17m00.c24evtcod,    
                 d_ctb17m00.c24fsecod,    
                 d_ctb17m00.dataini,    
                 d_ctb17m00.datafim  without defaults

      before field atdsrvnum   
             initialize d_ctb17m00 to null
             display by name d_ctb17m00.*
             display by name d_ctb17m00.atdsrvnum    attribute (reverse)
   
      after  field atdsrvnum   
             display by name d_ctb17m00.atdsrvnum    

             if d_ctb17m00.atdsrvnum   is null   then
                next field pstcoddig   
             end if
   
   
      before field atdsrvano   
             display by name d_ctb17m00.atdsrvano    attribute (reverse)
   
      after  field atdsrvano   
             display by name d_ctb17m00.atdsrvano    

             if fgl_lastkey() = fgl_keyval("left")   or 
                fgl_lastkey() = fgl_keyval("up")     then
                next field atdsrvnum
             end if

             if d_ctb17m00.atdsrvano   is null   then
                error " Ano do servico tem que ser informado!"
                next field atdsrvano   
             end if

             #buscar origem do servico informado
             open cctb17m00009 using d_ctb17m00.atdsrvnum,
                                     d_ctb17m00.atdsrvano
             fetch cctb17m00009 into d_ctb17m00.atdsrvorg
             
             if sqlca.sqlcode <> 0 then
                error " Servico nao existe no sistema!"
                close cctb17m00009
                next field atdsrvano   
             end if
             close cctb17m00009
             display by name d_ctb17m00.atdsrvorg    

             #verifica se existe historico de analise para servico
             let l_count = 0
             open cctb17m00010 using d_ctb17m00.atdsrvnum,
                                     d_ctb17m00.atdsrvano
             fetch cctb17m00010 into l_count

             if l_count = 0 then
                error " Nao existe nenhum historico de analise para este servico!"
                close cctb17m00010
                next field atdsrvano   
             end if
             close cctb17m00009
             
             exit input 
             
      before field pstcoddig
             initialize d_ctb17m00 to null
             display by name d_ctb17m00.*
             display by name d_ctb17m00.pstcoddig attribute (reverse)

      after  field pstcoddig
             display by name d_ctb17m00.pstcoddig

             if fgl_lastkey() = fgl_keyval("left")   or 
                fgl_lastkey() = fgl_keyval("up")     then
                next field atdsrvnum
             end if

             if d_ctb17m00.pstcoddig   is null   then
                #se nao informou prestador vai para socorrista
                next field srrcoddig   
             end if

             initialize d_ctb17m00.nomgrr  to null
             display by name d_ctb17m00.nomgrr  

             #busca nome de guerra do prestador
             open  cctb17m00001 using d_ctb17m00.pstcoddig
             fetch cctb17m00001 into  d_ctb17m00.nomgrr
             close cctb17m00001                 
             if d_ctb17m00.nomgrr is null  then 
                error " Prestador nao cadastrado!"
                next field pstcoddig
             end if
             display by name d_ctb17m00.nomgrr    
             #se informou prestador pula o campo do socorrista
             next field c24evtcod   

      before field srrcoddig
             initialize d_ctb17m00 to null
             display by name d_ctb17m00.*
             display by name d_ctb17m00.srrcoddig attribute (reverse)

      after  field srrcoddig
             display by name d_ctb17m00.srrcoddig

             if fgl_lastkey() = fgl_keyval("left")   or 
                fgl_lastkey() = fgl_keyval("up")     then
                next field pstcoddig
             end if

             if d_ctb17m00.srrcoddig   is null   then
                next field c24evtcod   
             end if

             initialize d_ctb17m00.srrabvnom  to null
             display by name d_ctb17m00.srrabvnom  

             #busca nome do socorrista
             open  cctb17m00002 using d_ctb17m00.srrcoddig
             fetch cctb17m00002 into  d_ctb17m00.srrabvnom
             close cctb17m00002                 
             if d_ctb17m00.srrabvnom is null  then 
                error " Motorista nao cadastrado!"
                next field srrcoddig
             end if
             display by name d_ctb17m00.srrabvnom    

      before field c24evtcod
             display by name d_ctb17m00.c24evtcod    attribute (reverse)

      after  field c24evtcod   
             display by name d_ctb17m00.c24evtcod   

             if fgl_lastkey() = fgl_keyval("left")   or 
                fgl_lastkey() = fgl_keyval("up")     then
                if d_ctb17m00.pstcoddig is not null   then
                   next field pstcoddig
                else
                   next field srrcoddig
                end if
             end if

             if d_ctb17m00.c24evtcod is null  then
                let d_ctb17m00.c24evtrdzdes = "TODOS" 
             else
                #buscar descricao do evento
                open  cctb17m00004 using d_ctb17m00.c24evtcod 
                fetch cctb17m00004 into  d_ctb17m00.c24evtrdzdes 
                close cctb17m00004                   
                if d_ctb17m00.c24evtrdzdes is null then 
                   error " Codigo do evento nao encontrado!" 
                   next field c24evtcod
                end if    
             end if
             display by name d_ctb17m00.c24evtrdzdes

      before field c24fsecod
             display by name d_ctb17m00.c24fsecod    attribute (reverse)

      after  field c24fsecod   
             display by name d_ctb17m00.c24fsecod   

             if fgl_lastkey() = fgl_keyval("left")   or 
                fgl_lastkey() = fgl_keyval("up")     then
                next field c24evtcod
             end if

             if d_ctb17m00.c24fsecod is null  then
                let d_ctb17m00.c24fsedes = "TODAS" 
             else
                #buscar descrição da fase
                open  cctb17m00003 using d_ctb17m00.c24fsecod 
                fetch cctb17m00003 into  d_ctb17m00.c24fsedes 
                close cctb17m00003                   
                if d_ctb17m00.c24fsedes is null then 
                   error " Codigo da fase nao encontrada!" 
                   next field c24fsecod
                end if    
             end if
             display by name d_ctb17m00.c24fsedes
             
      before field dataini       
             display by name d_ctb17m00.dataini      attribute (reverse)

      after  field dataini       
             display by name d_ctb17m00.dataini  

             if fgl_lastkey() = fgl_keyval("left")   or 
                fgl_lastkey() = fgl_keyval("up")     then
                next field c24fsecod
             end if

             if d_ctb17m00.dataini  is null then
                error " Data inicial obrigatoria para pesquisa!"
                next field dataini
             end if 

      before field datafim       
             display by name d_ctb17m00.datafim      attribute (reverse)

      after  field datafim       
             display by name d_ctb17m00.datafim  

             if fgl_lastkey() = fgl_keyval("left")   or 
                fgl_lastkey() = fgl_keyval("up")     then
                next field dataini
             end if

             if d_ctb17m00.datafim  is null then
                error " Data final obrigatoria para pesquisa!"
                next field datafim
             end if 

             if d_ctb17m00.dataini > d_ctb17m00.datafim then
                error " Data inicial maior que data final!"
                next field datafim
             end if

             #PSI 197858 - Alteracao do periodo de pesquisa de 30 para 180 dias
             if (d_ctb17m00.datafim - d_ctb17m00.dataini) > 180 then 
                error " Periodo de pesquisa nao pode ser maior que 180 dias!"
                next field datafim
             end if
             exit input 

      on key (interrupt)
         let int_flag = true
         exit input 
         
   end input 

end function



#-----------------------------------------------------------
function ctb17m00_carrega_dados()
#-----------------------------------------------------------
 define ws           record
    atdsrvnum        like datmsrvanlhst.atdsrvnum,
    atdsrvano        like datmsrvanlhst.atdsrvano,
    srvanlhstseq     like datmsrvanlhst.srvanlhstseq,
    atddat           like datmservico.atddat,
    atdhor           like datmservico.atdhor,
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    atdprscod        like datmservico.atdprscod,
    nomgrr           like dpaksocor.nomgrr,
    atdsrvorg        like datmservico.atdsrvorg,
    c24evtcod        like datkevt.c24evtcod,
    c24evtrdzdes     like datkevt.c24evtrdzdes,
    c24fsecod        like datkfse.c24fsecod,
    c24fsedes        like datkfse.c24fsedes,
    cadmat           like isskfunc.funmat,
    funnom           like isskfunc.funnom,
    caddat           like datmsrvanlhst.caddat,
    totpesq          smallint,  
    fasmdcdat        like datmsrranlhst.fasmdcdat,
    flganl           char (01)  
 end record

   define arr_aux     smallint
   define l_select    char(700)
   
   initialize ws.*            to null
   let l_select = null
   let arr_aux = 0

   if m_prepare <> true then
      call ctb17m00_prepare()
   end if

   #PSI 197858 - Vou continuar utilizando tabela temporaria para que
   # após carregar todos os registros de analise do servico e os registros
   # da analise do socorrista eu consiga ordenar por fase
   let l_select= "select datmservico.atdsrvnum,    ",
                  "       datmservico.atdsrvano,   ",
                  "       datmservico.atddat,      ",
                  "       datmservico.atdhor,      ",
                  "       datmservico.atdprscod,   ",
                  "       datmservico.atdsrvorg,   ",
                  "       datmsrvanlhst.c24evtcod, ",
                  "       datmsrvanlhst.c24fsecod, ",   
                  "       datmsrvanlhst.caddat,    ",        
                  "       datmsrvanlhst.cadmat,    ",
                  "       '0' flganl               "
   
   if d_ctb17m00.atdsrvnum is not null then
      #busca pelo numero do servico
      let l_select = l_select clipped ,
                       "  from datmservico, datmsrvanlhst ",
                       " where datmservico.atdsrvnum = ? ",
                       "   and datmservico.atdsrvano = ? "
   else
      if d_ctb17m00.pstcoddig is null then
         if d_ctb17m00.srrcoddig is null then
            #busca pela data
            let l_select = l_select clipped ,
                           "  from datmservico, datmsrvanlhst ",
                           " where datmservico.atddat between ? and ? "
         else
            #busca pelo socorrista
            let l_select = l_select clipped ,
                           "  from datmservico, datmsrvanlhst ",
                           " where datmservico.atddat between ? and ? ",
                           "   and  datmservico.srrcoddig = ?  "
         end if
      else 
         #busca pelo codigo prestador
         let l_select = l_select clipped ,
                        "  from datmservico, datmsrvanlhst ",
                        " where datmservico.atddat between ? and ? ",
                        "   and  datmservico.atdprscod = ?  "
      end if
   end if 

   let l_select = l_select clipped ,
                     "   and datmsrvanlhst.atdsrvnum = datmservico.atdsrvnum",
                     "   and datmsrvanlhst.atdsrvano = datmservico.atdsrvano",
                     "   and datmsrvanlhst.c24evtcod   <> 0  ",
                     "   and datmsrvanlhst.srvanlhstseq = 1  ",
                    # "   order by datmsrvanlhst.c24fsecod    ",            #PSI 197858 - Ordenar por 
                     "  into temp tmp_anlhst with no log     "             # fase de analise
   prepare pctb17m00011 from l_select
     
   message " Aguarde, pesquisando..."  attribute(reverse)

   if d_ctb17m00.atdsrvnum is not null then
      execute pctb17m00011  using d_ctb17m00.atdsrvnum,
                                  d_ctb17m00.atdsrvano 
   else
      if d_ctb17m00.pstcoddig is null then
         if d_ctb17m00.srrcoddig is null then
            execute pctb17m00011 using  d_ctb17m00.dataini,
                                        d_ctb17m00.datafim
         else
            execute pctb17m00011 using  d_ctb17m00.dataini,
                                        d_ctb17m00.datafim,
                                        d_ctb17m00.srrcoddig
         end if
      else
         execute pctb17m00011 using  d_ctb17m00.dataini,
                                     d_ctb17m00.datafim,
                                     d_ctb17m00.pstcoddig
      end if
   end if 

   # se informou o codigo do socorrista, buscar analise de historico do socorrista
   if d_ctb17m00.srrcoddig is not null then
      # caso nao tenha encontrado nenhum servico em analise para o socorrista
      # criar tabela temporaria, pois ela ainda nao existe
      whenever error continue
      select atdsrvnum from tmp_anlhst
      if status = 310 or
         status = 958 then
         create temp table tmp_anlhst
                (atdsrvnum  decimal (10,0),
                 atdsrvano  decimal (2,0),
                 atddat     date,
                 atdhor     char (05),
                 atdprscod  integer,
                 atdsrvorg  decimal (2,0),
                 c24evtcod  smallint,
                 c24fsecod  smallint,
                 caddat     date,
                 cadmat     decimal (6,0),
                 flganl     char(01) ) with no log           #PSI 197858
      end if
      whenever error stop         
      
      #busca analises de socorristas
      open  cctb17m00012 using d_ctb17m00.srrcoddig,
                               d_ctb17m00.dataini,
                               d_ctb17m00.datafim
      foreach cctb17m00012 into  ws.c24evtcod,
                                 ws.fasmdcdat,
                                 ws.cadmat,
                                 ws.c24fsecod
          #carrega tabela temporaria com as analises do socorrista                       
          insert into tmp_anlhst values (0,
                                         0,
                                         ws.fasmdcdat,
                                         "00:00",
                                         0,
                                         0,
                                         ws.c24evtcod,
                                         ws.c24fsecod,
                                         ws.fasmdcdat,
                                         ws.cadmat,
                                         1 )                     
      end foreach                                 
   end if

   let ws.totpesq = 0   

   #PSI 197858 - serviços devem ser ordenados de acordo com a fase
   declare cctb17m00013  cursor for  
    select atdsrvnum,
           atdsrvano,
           atddat   ,
           atdhor   ,
           atdprscod,
           atdsrvorg,
           c24evtcod,
           c24fsecod,
           caddat   ,
           cadmat   ,
           flganl
      from tmp_anlhst
      order by c24fsecod
                 
   foreach  cctb17m00013  into  ws.atdsrvnum, 
                                ws.atdsrvano, 
                                ws.atddat,     
                                ws.atdhor,      
                                ws.atdprscod,
                                ws.atdsrvorg,
                                ws.c24evtcod,
                                ws.c24fsecod,
                                ws.caddat,
                                ws.cadmat,
                                ws.flganl
                              
                              
      #display "Leu registro da temporaria ", ws.atdsrvnum 
      #display "                           ", ws.atdsrvano
      #display "                           ", ws.atddat     
      #display "                           ", ws.atdhor      
      #display "                           ", ws.atdprscod
      #display "                           ", ws.atdsrvorg
      #display "                           ", ws.c24evtcod
      #display "                           ", ws.c24fsecod
      #display "                           ", ws.caddat
      #display "                           ", ws.cadmat
      #display "                           ", ws.flganl
                              

      # Verifica se evento informado é o mesmo evento lido da tabela 
      if d_ctb17m00.c24evtcod is not null then
         if ws.c24evtcod <> d_ctb17m00.c24evtcod then
            display "nao pertence ao evento solicitado!"
            continue foreach
         end if
      end if

      # MONTA DESCRICAO DO EVENTO                  
      let ws.c24evtrdzdes = "NAO ENCONTRADO!" 
      open  cctb17m00004 using ws.c24evtcod
      fetch cctb17m00004 into  ws.c24evtrdzdes 
      close cctb17m00004       
      
      if ws.flganl = "0" then
         # Verifica se a ultima fase do servico é a fase informada 
         if d_ctb17m00.c24fsecod is not null then
            open  cctb17m00007 using ws.atdsrvnum, ws.atdsrvano, ws.c24evtcod,
                                        ws.atdsrvnum, ws.atdsrvano, ws.c24evtcod
            fetch cctb17m00007 into  ws.c24fsecod
            close cctb17m00007                   
            if ws.c24fsecod <> d_ctb17m00.c24fsecod then
               continue foreach
            end if
         end if
      end if  

      # MONTA DESCRICAO DA FASE   
      let ws.c24fsedes = "NAO ENCONTRADO!" 
      open  cctb17m00003 using ws.c24fsecod
      fetch cctb17m00003 into  ws.c24fsedes
      close cctb17m00003    
            
      if ws.flganl = "0" then
         # MONTA DESCRICAO DO PRESTADOR 
         let ws.nomgrr = "NAO ENCONTRADO!" 
         open  cctb17m00001 using ws.atdprscod
         fetch cctb17m00001 into  ws.nomgrr
         close cctb17m00001   
      else      #se registro é referente a analise de socorrista
         let ws.nomgrr = "Bloq.QRA"
      end if      
            
      if ws.flganl = "0" then
         # MONTA DESCRICAO TIPO DE SERVICO     
         let ws.srvtipabvdes = "NAO ENCONTRADO!" 
         open  cctb17m00005 using ws.atdsrvorg 
         fetch cctb17m00005 into  ws.srvtipabvdes 
         close cctb17m00005 
      else  
         let ws.srvtipabvdes = ""
      end if
            
      # MONTA NOME FUNCIONARIO    
      let ws.funnom = "NAO ENCONTRADO!" 
      open  cctb17m00006 using ws.cadmat
      fetch cctb17m00006 into  ws.funnom
      close cctb17m00006    
            
      #carregar array
      let arr_aux = arr_aux + 1

      let a_ctb17m00[arr_aux].atdsrvorg_arr    = ws.atdsrvorg
      let a_ctb17m00[arr_aux].atdsrvnum_arr    = ws.atdsrvnum
      let a_ctb17m00[arr_aux].atdsrvano_arr    = ws.atdsrvano
      let a_ctb17m00[arr_aux].atddat_arr       = ws.atddat
      let a_ctb17m00[arr_aux].atdhor_arr       = ws.atdhor
      let a_ctb17m00[arr_aux].srvtipabvdes_arr = ws.srvtipabvdes
      let a_ctb17m00[arr_aux].c24evtrdzdes_arr = ws.c24evtrdzdes
      let a_ctb17m00[arr_aux].c24fsedes_arr    = ws.c24fsedes
      let a_ctb17m00[arr_aux].pstcoddig_arr    = ws.atdprscod
      let a_ctb17m00[arr_aux].nomgrr_arr       = ws.nomgrr
      let a_ctb17m00[arr_aux].caddat_arr       = ws.caddat
      let a_ctb17m00[arr_aux].funnom_arr       = ws.funnom
      let a2_ctb17m00[arr_aux].c24evtcod       = ws.c24evtcod     

      #se registro de analise de socorrista - somar 1 no total
      #se registro de analise de servico com sequencia 1 - somar 1 no total
      #obs. todos os registros de analise de servico inseridos na tab. temporaria
      #     estao com sequencia 1 conforme clausula where
      let ws.totpesq = ws.totpesq + 1      
      
      #se registro de analise de servico
      if ws.flganl = "0" then
         # buscar todas as sequencias do servico e incluir no array
         #display "buscar sequencias do servico"
         open  cctb17m00014 using ws.atdsrvnum,
                                  ws.atdsrvano,
                                  ws.c24evtcod
         foreach cctb17m00014 into ws.c24fsecod,     #25/10/06 Pri
                                   ws.srvanlhstseq,
                                   ws.caddat,
                                   ws.cadmat
            # se sequencia é igual a 1 despreza, pois ja foi lido na condicao anterior
            if ws.srvanlhstseq = 1 then
               #display "sequencia já lida anterior"
               continue foreach
            end if
            #display "sequencia ", ws.srvanlhstseq, " - ",
            #                      ws.atdsrvnum,
            #                      ws.atdsrvano,
            #                      ws.c24evtcod 
            #Buscar nome do funcionario
            let ws.funnom = "NAO ENCONTRADO!" 
            open  cctb17m00006 using ws.cadmat
            fetch cctb17m00006 into  ws.funnom
            close cctb17m00006  

            # MONTA DESCRICAO DA FASE
            let ws.c24fsedes = "NAO ENCONTRADO!"
            open  cctb17m00003 using ws.c24fsecod
            fetch cctb17m00003 into  ws.c24fsedes
            close cctb17m00003
            
            #carregar array
            let arr_aux = arr_aux + 1
            
            let a_ctb17m00[arr_aux].atdsrvorg_arr    = ws.atdsrvorg
            let a_ctb17m00[arr_aux].atdsrvnum_arr    = ws.atdsrvnum
            let a_ctb17m00[arr_aux].atdsrvano_arr    = ws.atdsrvano
            let a_ctb17m00[arr_aux].atddat_arr       = ws.atddat
            let a_ctb17m00[arr_aux].atdhor_arr       = ws.atdhor
            let a_ctb17m00[arr_aux].srvtipabvdes_arr = ws.srvtipabvdes
            let a_ctb17m00[arr_aux].c24evtrdzdes_arr = ws.c24evtrdzdes
            let a_ctb17m00[arr_aux].c24fsedes_arr    = ws.c24fsedes
            let a_ctb17m00[arr_aux].pstcoddig_arr    = ws.atdprscod
            let a_ctb17m00[arr_aux].nomgrr_arr       = ws.nomgrr
            let a_ctb17m00[arr_aux].caddat_arr       = ws.caddat
            let a_ctb17m00[arr_aux].funnom_arr       = ws.funnom
            let a2_ctb17m00[arr_aux].c24evtcod       = ws.c24evtcod
         end foreach
         close cctb17m00014     
      end if      

      if arr_aux > 2000 then
         exit foreach
      end if 

   end foreach

   #apaga tabela temporaria   
   drop table tmp_anlhst
   
   let m_arr_aux = arr_aux
   let d_ctb17m00.total = ws.totpesq using "##&&&&"
   
end function




#-----------------------------------------------------------
function ctb17m00_display_array()
#-----------------------------------------------------------
  define l_total   char (06)
  define arr_aux   smallint
  define l_lignum  like datmligacao.lignum
  
  let l_total = 0
  
  if m_arr_aux  > 0   then
     message " (F17)Abandona, (F7)Historico, (F8)Seleciona"
     display by name d_ctb17m00.total attribute(reverse)
    
     call set_count(m_arr_aux)

     display array  a_ctb17m00 to s_ctb17m00.*
     
       on key(f17,control-c,interrupt)
          initialize a_ctb17m00 to null
          exit display
     
       on key(F7)
          let arr_aux = arr_curr()
          if a_ctb17m00[arr_aux].atdsrvnum_arr is not null and 
             a_ctb17m00[arr_aux].atdsrvano_arr is not null then
             #buscar número da ligação
             open cctb17m00008 using a_ctb17m00[arr_aux].atdsrvnum_arr,
                                     a_ctb17m00[arr_aux].atdsrvano_arr
             fetch cctb17m00008 into l_lignum
             if l_lignum is not null then
                call cta05m04(l_lignum, 2)
             else
                error " Nao existe relacionamento para este servico!"   
             end if
          end if   
     
       on key(F8)
          let arr_aux = arr_curr()
          if a_ctb17m00[arr_aux].atdsrvnum_arr is not null then
             call ctb16m00_analise(a_ctb17m00[arr_aux].atdsrvnum_arr,
                                   a_ctb17m00[arr_aux].atdsrvano_arr,
                                   a2_ctb17m00[arr_aux].c24evtcod,
                                   2 )
          else
             error " Funcao nao permitida para Bloq.QRA!"
          end if 
     
     end display
  else
     error " Nao existe servicos analisados, para este tipo de pesquisa!"
  end if   
  clear form

end function
