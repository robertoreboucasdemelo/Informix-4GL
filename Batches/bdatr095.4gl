#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       :                                                              #
# Modulo        : bdatr095                                                     #
# Analista Resp.: Amilton Lorenco                                              #
# PSI           :                                                              #
#..............................................................................#
# Desenvolvimento: Johnny Alves  BizTalking  em 04/06/2012                     #
# Liberacao      :                                                             #
#..............................................................................#
#                                                                              #
#                  * * * ALTERACOES * * *                                      #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
#                                                                              #
#------------------------------------------------------------------------------#
database porto

 globals  "/homedsa/projetos/geral/globals/sg_glob3.4gl"
 globals  "/homedsa/projetos/geral/globals/glct.4gl"

globals
   define g_ismqconn smallint
end globals
 define m_log        char(500)
 define m_hostname   like ibpkdbspace.srvnom
       ,m_hostname1  like ibpkdbspace.srvnom

 define mr_count      record
        lidos         integer
       ,processados   integer
       ,desprezados   integer
       ,total_apolice integer
       ,total_auto    integer
       ,total_imovel  integer
       ,total_locacao integer
 end record

 define mr_tempo     record
        current_ini  datetime year to second  #tempo inicio do processo
       ,current_cur  datetime year to second  #tempo corrente
       ,interval     interval hour to second  #intervalo de tempo
 end record

 define m_rel           smallint
main

let m_hostname  = null
let m_hostname1 = null
    call fun_dba_abre_banco("CT24HS")

    let m_hostname = fun_dba_servidor("CT24HS")
    let m_hostname1 = fun_dba_servidor("EMISAUTO")

    let m_log = f_path("DAT","LOG")
    if m_log is null then
       let m_log = "."
    end if

    let m_log = m_log clipped,"/bdatr095.log"


    call startlog(m_log)

    set isolation to dirty read

    display "========================================",
            "========================================"
    display ""

    initialize mr_count.*, mr_tempo.* to null

    let mr_tempo.current_ini    = current

    display 'CRIANDO TABELA TEMPORARIA'

    call bdatr095_criatemp()
    call bdatr095_prepare()
    begin work
    call bdatr095()

   display "#---------------------------------------",
           "---------------------------------------#"
   display "# Total de Lidos.......: ", mr_count.lidos
   display "# Total de Processados.: ", mr_count.processados
   display "# Total de Desprezados.: ", mr_count.desprezados
   display "#---------------------------------------",
          "---------------------------------------#"

   let mr_tempo.current_cur    = current
   let mr_tempo.interval       = mr_tempo.current_cur - mr_tempo.current_ini
   display mr_tempo.current_cur, ".: Tempo total de processamento : ",
           mr_tempo.interval


   display ""
   display "========================================",
           "========================================"
    display 'DELETANDO INFORMAÇOES DA TABELA TEMPORARIA'
    delete from tmp_apolice
    if sqlca.sqlcode <> 0 then
         display "ERRO: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
                          " AO DELETAR INFORMARÇOES DA TABELA."
     else
         display "INFORMARÇOES DELETADAS COM SUCESSO"
     end if
     {display 'DROPANDO A TABELA TEMPORARIA'}
   {whenever error continue
   drop table tmp_apolice
   whenever error stop
   if sqlca.sqlcode <> 0 then
        display "ERRO: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
               " AO DROPAR A TABELA TEMPORARIA."
     else
        display "TABELA DROPADA COM SUCESSO"
     end if}

     display mr_tempo.current_cur, ".: FIM DO BDATR095 "


end main      #--Fim Main--#
#------------------------------------------------------------------------------#
function bdatr095_criatemp()
#------------------------------------------------------------------------------#
   create temp table tmp_apolice(succod     smallint
                                ,ramcod     smallint
                                ,aplnumdig  decimal(9,0)
                                ,itmnumdig  decimal(7,0)) with no log
     if sqlca.sqlcode <> 0 then
        display "ERRO: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
               " NA CRIACAO DA TABELA TEMPORARIA."
     else
        display "TABELA TEMPORARIA CRIADA COM SUCESSO"
     end if
     create unique index tmp_ind1 on
                         tmp_apolice(succod
                                    ,ramcod
                                    ,aplnumdig
                                    ,itmnumdig)
      if sqlca.sqlcode <> 0 then
        display "ERRO: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
               " NA CRIACAO DO INDICE TABELA TEMPORARIA."
      else
         display "INDICE CRIADOS COM SUCESSO"
     end if
end function
#------------------------------------------------------------------------------#
function bdatr095_prepare()
#------------------------------------------------------------------------------#

  define l_sql char(8000)

  let l_sql = " select a.atdsrvnum                            "
             ,"       ,a.atdsrvano                            "
             ,"       ,a.ligdat                               "
             ,"   from datmligacao a                          "
             ,"       ,datmservico b                          "
             ,"  where a.atdsrvnum = b.atdsrvnum              "
             ,"    and a.atdsrvano = b.atdsrvano              "
             ,"    and a.ciaempcod = 1                        "
             ,"    and a.c24astcod not in ('ALT','CON','CAN','RET','REC') "
             ,"    and b.atdetpcod <> 5                       "
             ,"    and a.ligdat = today - 1                   "

   prepare pbdatr095001 from l_sql
   declare cbdatr095001 cursor for pbdatr095001

   let l_sql = " select succod             "
              ,"       ,ramcod             "
              ,"       ,aplnumdig          "
              ,"       ,itmnumdig          "
              ,"       ,edsnumref          "
              ,"   from porto@",m_hostname clipped,":datrservapol "
              ,"  where ramcod not in (31,14) "
              ,"    and atdsrvnum = ?      "
              ,"    and atdsrvano = ?      "

   prepare pbdatr095002 from l_sql
   declare cbdatr095002 cursor with hold for pbdatr095002

   let l_sql = " select count(*)      "
              ," from datrservapol a  "
              ,"     ,datmligacao b   "
              ,"     ,datmservico c   "
              ," where a.succod = ?   "
              ," and a.ramcod = ?     "
              ," and a.aplnumdig = ?  "
              ," and a.itmnumdig = ?  "
              ," and a.edsnumref = ?  "
              ," and a.atdsrvnum = b.atdsrvnum "
              ," and a.atdsrvano = b.atdsrvano "
              ," and a.atdsrvnum = c.atdsrvnum "
              ," and a.atdsrvano = c.atdsrvano "
              ," and b.c24astcod in (select c24astcod from datkassunto "
              ,"                      where c24astagp = 'S')           "
              ," and c.atdetpcod not in (5,6) "

   prepare pbdatr095003 from l_sql
   declare cbdatr095003 cursor with hold for pbdatr095003

   let l_sql = " select count(*)     "
              ,"   ,nvl(sum(c.atdcstvlr),0) as valor "
              ," from datrligapol a  "
              ,"     ,datmligacao b  "
              ,"     ,datmservico c  "
              ," where a.lignum = b.lignum "
              ," and b.atdsrvnum = c.atdsrvnum "
              ," and b.atdsrvano = c.atdsrvano "
              ," and a.succod = ?  "
              ," and a.ramcod = ? "
              ," and a.aplnumdig = ? "
              ," and a.itmnumdig = ? "
              ," and b.atdsrvnum is not null "
              ," and b.atdsrvano is not null "
              ," and c.atdsrvorg in (9) "
              ," and b.c24astcod not in ('ALT','CON','CAN','RET','REC') "
              ," and c.atdetpcod not in (5,6)  "

   prepare pbdatr095004 from l_sql
   declare cbdatr095004 cursor with hold for pbdatr095004

   let l_sql = " select vcllicnum     "
              ,"   from porto@",m_hostname1 clipped,":abbmveic "
              ,"  where succod    = ? "
              ,"    and aplnumdig = ? "
              ,"    and itmnumdig = ? "
              ,"    and dctnumseq = ? "

   prepare pbdatr095005 from l_sql
   declare cbdatr095005 cursor with hold for pbdatr095005

   let l_sql = " select clscod from porto@",m_hostname1 clipped,":abbmclaus ",
               " where ",
               " succod = ? ",
               " and aplnumdig = ? ",
               " and itmnumdig = ? ",
               " and dctnumseq = ? ",
               " and clscod in ('034','033','035','044','046','047','048') "

   prepare pbdatr095006 from l_sql
   declare cbdatr095006 cursor with hold for pbdatr095006

     let l_sql = " select min(dctnumseq)  "
                ,"   from abbmdoc         "
                ,"  where succod = ?      "
                ,"    and aplnumdig = ?   "
                ,"    and itmnumdig = ?   "

   prepare pbdatr095007 from l_sql
   declare cbdatr095007 cursor with hold for pbdatr095007



   let l_sql = " select cpodes      "
              ,"   from datkdominio "
              ,"  where cponom = ?  "

   prepare pbdatr095009 from l_sql
   declare cbdatr095009 cursor with hold for pbdatr095009


  #Retorna o ultimo servico da apolice
  let l_sql = " select first 1 b.atdsrvnum  "
             ,"       ,b.atdsrvano          "
             ,"       ,b.ligdat             "
             ," from datrligapol a          "
             ,"     ,datmligacao b          "
             ,"     ,datmservico c          "
             ," where a.lignum = b.lignum   "
             ," and b.atdsrvnum = c.atdsrvnum "
             ," and b.atdsrvano = c.atdsrvano "
             ," and a.succod = ?             "
             ," and a.ramcod = ?             "
             ," and a.aplnumdig = ?          "
             ," and a.itmnumdig = ?          "
             ," and b.atdsrvnum is not null  "
             ," and b.atdsrvano is not null  "
             ," and b.c24astcod like 'S%'    "
             ," and c.atdetpcod not in (5,6) "
             ," order by atdsrvnum desc      "

   prepare pbdatr095011 from l_sql
   declare cbdatr095011 cursor with hold for pbdatr095011

   let l_sql = " select count(*)    "
              ,"   ,nvl(sum(c.atdcstvlr),0) as valor "
              ," from datrligapol a "
              ,"     ,datmligacao b "
              ,"     ,datmservico c "
              ," where a.lignum = b.lignum     "
              ," and a.succod = ?  "
              ," and a.ramcod = ?  "
              ," and a.aplnumdig = ?  "
              ," and a.itmnumdig = ?  "
              ," and b.atdsrvnum is not null "
              ," and b.atdsrvano is not null "
              ," and b.atdsrvnum = c.atdsrvnum "
              ," and b.atdsrvano = c.atdsrvano "
              ," and c.atdsrvorg in (1,2,3,4,5,6,7) "
              ," and b.c24astcod not in ('ALT','CON','CAN','RET') "
              ," and c.atdetpcod not in (5,6)"

   prepare pbdatr095012 from l_sql
   declare cbdatr095012 cursor with hold for pbdatr095012


   let l_sql = " select cgccpfnum   "
              ,"       ,cgcord      "
              ,"       ,cgccpfdig   "
              ,"       ,pestip      "
              ,"   from gsakseg     "
              ,"  where segnumdig = ?   "

   prepare pbdatr095013 from l_sql
   declare cbdatr095013 cursor with hold for pbdatr095013


   let l_sql = " select count(*)       "
              ,"   ,nvl(sum(c.atdcstvlr),0) as valor "
              ," from datrligapol a    "
              ,"     ,datmligacao b    "
              ,"     ,datmservico c    "
              ," where a.lignum = b.lignum "
              ,"   and b.atdsrvnum = c.atdsrvnum "
              ,"   and b.atdsrvano = c.atdsrvano "
              ,"   and a.succod = ? "
              ,"   and a.ramcod = ? "
              ,"   and a.aplnumdig = ? "
              ,"   and a.itmnumdig = ? "
              ,"   and b.atdsrvnum is not null "
              ,"   and b.atdsrvano is not null "
              ,"   and c.atdsrvorg in (8) "
              ,"   and b.c24astcod not in ('ALT','CON','CAN','RET') "
              ,"   and c.atdetpcod not in (5,6) "

   prepare pbdatr095014 from l_sql
   declare cbdatr095014 cursor with hold for pbdatr095014


    let l_sql =  " select corsus          "
                ,"  from porto@",m_hostname1 clipped,":abamcor  "
                ,"  where succod = ?      "
                ,"    and aplnumdig = ?   "
                ,"    and corlidflg = 'S' "
   prepare pbdatr095015 from l_sql
   declare cbdatr095015 cursor with hold for pbdatr095015

   let l_sql = " select 1 from tmp_apolice  "
                ," where succod    = ? "
                ,"   and ramcod    = ? "
                ,"   and aplnumdig = ? "
                ,"   and itmnumdig = ? "
   prepare pbdatr095016 from l_sql
   declare cbdatr095016 cursor with hold for pbdatr095016


    let l_sql = " insert into tmp_apolice "
               ,"             (succod     "
               ,"             ,aplnumdig  "
               ,"             ,ramcod     "
               ,"             ,itmnumdig) "
               ,"  values (?,?,?,?)       "
   prepare pbdatr095017 from l_sql

   let l_sql = " select segnumdig            "
               ,"        from abbmdoc         "
               ,"       where succod = ?      "
               ,"         and aplnumdig = ?   "
               ,"         and itmnumdig = ?   "
               ,"         and dctnumseq = ?   "
   prepare pbdatr095018 from l_sql
   declare cbdatr095018 cursor for pbdatr095018
   let l_sql = " select segnumdig            "
               ,"        from abbmdoc         "
               ,"       where succod = ?      "
               ,"         and aplnumdig = ?   "
               ,"         and itmnumdig = ?   "
               ,"         and dctnumseq = ?   "
   prepare pbdatr095019 from l_sql
   declare cbdatr095019 cursor for pbdatr095019
   let l_sql = "select segnumdig from rsamseguro a, rsdmdocto b ",
               " where ",
               " a.sgrorg = b.sgrorg ",
  		         " and a.sgrnumdig = b.sgrnumdig ",
  		         " and a.succod = ? ",
  		         " and a.ramcod =  ? ",
  		         " and a.aplnumdig = ? "
  	prepare pbdatr095020 from l_sql
    declare cbdatr095020 cursor for pbdatr095020
    let l_sql = "select b.corsus from rsamseguro a, rsampcorre b ",
                " where ",
                " a.sgrorg = b.sgrorg ",
    	          " and a.sgrnumdig = b.sgrnumdig ",
    	          " and a.succod = ? ",
    	          " and a.ramcod =  ? ",
    	          " and a.aplnumdig = ? "
     prepare pbdatr095021 from l_sql
     declare cbdatr095021 cursor for pbdatr095021
  	let l_sql = " select lclnumseq,rmerscseq "
               ," from datmrsclcllig "
               ," where "
               ," lignum = ? "
     prepare pbdatr095022 from l_sql
     declare cbdatr095022 cursor for pbdatr095022
     let l_sql = " select b.prporg,b.prpnumdig "
                ," from rsamseguro a, rsdmdocto b "
                ," where "
                ," a.sgrorg = b.sgrorg "
                ," and a.sgrnumdig = b.sgrnumdig "
                ," and a.succod = ? "
                ," and a.ramcod = ? "
                ," and a.aplnumdig = ? "
      prepare pbdatr095023 from l_sql
      declare cbdatr095023 cursor for pbdatr095023
      let l_sql = " select clscod  "
                 ," from rsdmclaus  "
                 ," where prporg  = ? "
                 ," and prpnumdig = ? "
                 ," and lclnumseq = ? "
                 ," and rmerscseq = ? "
                 ," and clsstt    = 'A' "
                 ," and clscod in ('102','103','104','105','106','107','108')"
      prepare pbdatr095024 from l_sql
      declare cbdatr095024 cursor for pbdatr095024
end function


#------------------------------------------------------------------------------#
function bdatr095()
#------------------------------------------------------------------------------#
   define lr_datmligacao     record
          atdsrvnum	         like datmprorrog.atdsrvnum
         ,atdsrvano	         like datmprorrog.atdsrvano
         ,ligdat             like datmligacao.ligdat
         ,c24funmat          like datmligacao.c24funmat
         ,c24astcod          like datmligacao.c24astcod
         ,c24astcod1         like datmligacao.c24astcod
         ,lignum             like datmligacao.lignum
         ,ciaempcod          like datmligacao.ciaempcod
   end record

   define lr_datrservapol    record
          succod             like datrservapol.succod
         ,ramcod             like datrservapol.ramcod
         ,aplnumdig          like datrservapol.aplnumdig
         ,itmnumdig          like datrservapol.itmnumdig
         ,edsnumref          like datrservapol.edsnumref
   end record

   define lr_datrservapolaux record
          atdsrvnum          like datrservapol.atdsrvnum
         ,atdsrvano          like datrservapol.atdsrvano
   end record
   define lr_re record
       lclnumseq like datmrsclcllig.lclnumseq
      ,rmerscseq like datmrsclcllig.rmerscseq
      ,prporg    like rsdmdocto.prporg
      ,prpnumdig like rsdmdocto.prpnumdig
   end record

   define lr_cgccpf record
          cgccpfnum like gsakseg.cgccpfnum
         ,cgcord    like gsakseg.cgcord
         ,cgccpfdig like gsakseg.cgccpfdig
         ,pestip    like gsakseg.pestip
   end record


   define lr_abbmveic        record
          vcllicnum          like abbmveic.vcllicnum
   end record

   define lr_datrsrvcls      record
          clscod             like datrsrvcls.clscod
   end record

   define lr_mens        		 record
          para             	 char(10000)
         ,cc             		 char(10000)
         ,anexo          		 char(32000)
         ,assunto        		 char(500)
         ,msg            		 char(500)
   end record


   define l_qtde             smallint
   define l_apolice          char(050)
   define l_apolice_ant      char(050)
   define l_numserv          char(200)
   define l_ligdat           like datmligacao.ligdat
   define l_cgccpf           char(40)
   define l_vlr_imov         decimal(10,2)
   define l_vlr_auto         decimal(10,2)
   define l_vlr_locacao      decimal(10,2)
   define l_susep            like abamcor.corsus
   define dirfisnom          char(32000)                #Diretorio
   define param_email        like datkdominio.cponom    #Nome do campo para email
   define l_cont             integer
   define emails             array[20] of char(70)
   define dataini            date
   define dataaux            char(10)
   define l_arquivo          char(100)
   define l_quant            smallint
   define l_quantidade       smallint
   define l_segnumdig        integer


   initialize  lr_datmligacao.* ,lr_datrservapol.*,lr_datrservapolaux.*
              ,lr_abbmveic.*, lr_cgccpf.*,l_apolice ,l_apolice_ant,l_numserv
              ,lr_datrsrvcls.*,lr_re.* to null

   let l_qtde = 0
   let l_quant = 0

   let param_email  = "email_bdatr095"

  let dataini = today - 1
  let dataaux = dataini
  let dataaux = dataaux[01,02],'-',dataaux[04,05],'-',dataaux[07,10]
  display "dataaux = ",dataaux clipped

  call f_path("DAT","RELATO")
     returning dirfisnom




  let l_arquivo = '/rel_bdatr095_', dataaux , '.xls'
  display 'arquivo: ',l_arquivo sleep 2

  #let dirfisnom = "/asheeve/",l_arquivo clipped
  let dirfisnom = dirfisnom clipped, l_arquivo

display '466 - dirfisnom: ',dirfisnom sleep 2


   #Inicializa Prepare
   call bdatr095_prepare()

   start report  rep_bdatr095  to dirfisnom
   let mr_count.lidos         = 0
   let mr_count.processados   = 0
   let mr_count.desprezados   = 0
   let mr_count.total_apolice = 0
   let mr_count.total_imovel  = 0
   let mr_count.total_auto    = 0
   let mr_count.total_locacao = 0
   let l_ligdat  = null
   let l_quantidade = 0
   let l_segnumdig = null

   open cbdatr095001
   display "Criando relatorio..."
   foreach cbdatr095001 into lr_datmligacao.atdsrvnum
                            ,lr_datmligacao.atdsrvano
                            ,lr_datmligacao.ligdat
                            ,lr_datmligacao.lignum
                            ,lr_datmligacao.ciaempcod

      let mr_count.lidos = mr_count.lidos + 1
      let l_vlr_imov = 0
      let l_vlr_auto = 0


      open cbdatr095002 using lr_datmligacao.atdsrvnum
                             ,lr_datmligacao.atdsrvano

      fetch cbdatr095002 into lr_datrservapol.succod
                             ,lr_datrservapol.ramcod
                             ,lr_datrservapol.aplnumdig
                             ,lr_datrservapol.itmnumdig
                             ,lr_datrservapol.edsnumref

      if sqlca.sqlcode < 0 then
         let m_log = "Problemas ao acesso do cursor cbdatr095002.Erro:"
                ,sqlca.sqlcode,'/',sqlca.sqlerrd[2],'/'
                ,'servico=>',lr_datmligacao.atdsrvnum
                ,'ano    =>',lr_datmligacao.atdsrvano
         call errorlog(m_log)
      else
         if sqlca.sqlcode = 100 then
            let mr_count.desprezados = mr_count.desprezados + 1
            continue foreach
         end if
      end if



       let l_apolice = lr_datrservapol.succod using    '<<&&' ,"-",
                       lr_datrservapol.ramcod using    '<<<&&' ,"-",
                       lr_datrservapol.aplnumdig using '<<<<<<<<&&' ,"-",
                       lr_datrservapol.itmnumdig using '<<&&' ,"-",
                       lr_datrservapol.edsnumref using '<<<<<<<<<&&'

      open cbdatr095003 using lr_datrservapol.succod
                             ,lr_datrservapol.ramcod
                             ,lr_datrservapol.aplnumdig
                             ,lr_datrservapol.itmnumdig
                             ,lr_datrservapol.edsnumref

      fetch cbdatr095003 into l_qtde


      if sqlca.sqlcode < 0 then
         let m_log = "Problemas ao acesso do cursor cbdatr095003.Erro:"
                ,sqlca.sqlcode,'/',sqlca.sqlerrd[2],'/'
                ,'sucursal=>',lr_datrservapol.succod
                ,'ramo    =>',lr_datrservapol.ramcod
                ,'apolice =>',lr_datrservapol.aplnumdig
                ,'item    =>',lr_datrservapol.itmnumdig
                ,'endosso =>',lr_datrservapol.edsnumref
         call errorlog(m_log)
      else
         if sqlca.sqlcode = 100 then
            let mr_count.desprezados = mr_count.desprezados + 1
            continue foreach
         end if
      end if

      let lr_abbmveic.vcllicnum =null
      if  lr_datrservapol.ramcod = 531 or
          lr_datrservapol.ramcod = 31  then
          call f_funapol_ultima_situacao (lr_datrservapol.succod
                                         ,lr_datrservapol.aplnumdig
                                         ,lr_datrservapol.itmnumdig)
                    returning g_funapol.*

            if g_funapol.dctnumseq is null  then
               open cbdatr095007 using lr_datrservapol.succod
                                      ,lr_datrservapol.aplnumdig
                                      ,lr_datrservapol.itmnumdig
                fetch cbdatr095007 into g_funapol.dctnumseq
            end if

            open cbdatr095005 using lr_datrservapol.succod
                                   ,lr_datrservapol.aplnumdig
                                   ,lr_datrservapol.itmnumdig
                                   ,g_funapol.dctnumseq

            fetch cbdatr095005 into lr_abbmveic.vcllicnum


            if sqlca.sqlcode < 0 then
               let m_log ="Problemas ao acesso do cursor cbdatr095005.Erro:"
                      ,sqlca.sqlcode,'/',sqlca.sqlerrd[2],'/'
                      ,'sucursal=>',lr_datrservapol.succod
                      ,'ramo    =>',lr_datrservapol.ramcod
                      ,'apolice =>',lr_datrservapol.aplnumdig
                      ,'item    =>',lr_datrservapol.itmnumdig
                      ,'endosso =>',lr_datrservapol.edsnumref
               call errorlog(m_log)
            else
               if sqlca.sqlcode = 100 then
                  let mr_count.desprezados = mr_count.desprezados + 1
                  continue foreach
               end if
            end if
      end if

      call bdatr095_obter_susep(lr_datrservapol.succod
                               ,lr_datrservapol.ramcod
                               ,lr_datrservapol.aplnumdig)
           returning l_susep
          {open cbdatr095015 using lr_datrservapol.succod
                                 ,lr_datrservapol.aplnumdig

          fetch cbdatr095015 into l_susep

          if sqlca.sqlcode < 0 then
               let m_log ="Problemas ao acesso do cursor cbdatr095015.Erro:"
                      ,sqlca.sqlcode,'/',sqlca.sqlerrd[2],'/'
                      ,'sucursal=>',lr_datrservapol.succod
                      ,'ramo    =>',lr_datrservapol.ramcod
               call errorlog(m_log)
            else
               if sqlca.sqlcode = 100 then
                  let mr_count.desprezados = mr_count.desprezados + 1
                  continue foreach
               end if
            end if
          end if}

          call bdatr095_obter_segnumdig(lr_datrservapol.succod,
                                        lr_datrservapol.ramcod,
                                        lr_datrservapol.aplnumdig,
                                        lr_datrservapol.itmnumdig,
                                        g_funapol.dctnumseq)
               returning l_segnumdig
          open cbdatr095013 using  l_segnumdig

          fetch cbdatr095013 into lr_cgccpf.cgccpfnum
                                 ,lr_cgccpf.cgcord
                                 ,lr_cgccpf.cgccpfdig
                                 ,lr_cgccpf.pestip

          if sqlca.sqlcode < 0 then
               let m_log ="Problemas ao acesso do cursor cbdatr095005.Erro:"
                      ,sqlca.sqlcode,'/',sqlca.sqlerrd[2],'/'
                      ,'sucursal=>',lr_datrservapol.succod
                      ,'ramo    =>',lr_datrservapol.ramcod
                      ,'apolice =>',lr_datrservapol.aplnumdig
                      ,'item    =>',lr_datrservapol.itmnumdig
                      ,'endosso =>',lr_datrservapol.edsnumref
               call errorlog(m_log)
            else
               if sqlca.sqlcode = 100 then
                  let mr_count.desprezados = mr_count.desprezados + 1
                  continue foreach
               end if
            end if

          let lr_datrsrvcls.clscod = null
          if  lr_datrservapol.ramcod = 531 or
              lr_datrservapol.ramcod = 31  then
              open cbdatr095006 using lr_datrservapol.succod
                                     ,lr_datrservapol.aplnumdig
                                     ,lr_datrservapol.itmnumdig
                                     ,g_funapol.dctnumseq

              foreach cbdatr095006 into lr_datrsrvcls.clscod

                if lr_datrsrvcls.clscod = "034" or
                   lr_datrsrvcls.clscod = "071" or
                   lr_datrsrvcls.clscod = "077" then
                  if cta13m00_verifica_clausula(lr_datrservapol.succod ,
                                                lr_datrservapol.aplnumdig,
                                                lr_datrservapol.itmnumdig,
                                                g_funapol.dctnumseq ,
                                                lr_datrsrvcls.clscod) then

                   continue foreach

                  end if
                end if
                end foreach
          else
              whenever error continue
              open cbdatr095022 using lr_datmligacao.lignum
              fetch cbdatr095022 into lr_re.lclnumseq,
                                      lr_re.rmerscseq
              whenever error stop
              close cbdatr095022

              open cbdatr095023 using lr_datrservapol.succod
                                      ,lr_datrservapol.ramcod
                                      ,lr_datrservapol.aplnumdig
              fetch cbdatr095023 into lr_re.prporg
                                     ,lr_re.prpnumdig
              close cbdatr095023
              open cbdatr095024 using lr_re.prporg
                                     ,lr_re.prpnumdig
                                     ,lr_re.lclnumseq
                                     ,lr_re.rmerscseq
              fetch cbdatr095024 into lr_datrsrvcls.clscod
              close cbdatr095024
         end if
      if l_qtde < 1 then
         let mr_count.desprezados = mr_count.desprezados + 1
         let lr_datrservapol.succod = null
         let lr_datrservapol.ramcod = null
         let lr_datrservapol.aplnumdig = null
         let lr_datrservapol.itmnumdig = null
         let lr_datrservapol.edsnumref = null
         continue foreach
      else

         open cbdatr095004 using lr_datrservapol.succod
                                ,lr_datrservapol.ramcod
                                ,lr_datrservapol.aplnumdig
                                ,lr_datrservapol.itmnumdig
         fetch cbdatr095004 into mr_count.total_imovel
                                ,l_vlr_imov

         open cbdatr095012 using lr_datrservapol.succod
                                ,lr_datrservapol.ramcod
                                ,lr_datrservapol.aplnumdig
                                ,lr_datrservapol.itmnumdig
         fetch cbdatr095012 into mr_count.total_auto
                                ,l_vlr_auto

         open cbdatr095014 using lr_datrservapol.succod
                                ,lr_datrservapol.ramcod
                                ,lr_datrservapol.aplnumdig
                                ,lr_datrservapol.itmnumdig
         fetch cbdatr095014 into mr_count.total_locacao
                                ,l_vlr_locacao

         open cbdatr095016 using lr_datrservapol.succod
                                ,lr_datrservapol.ramcod
                                ,lr_datrservapol.aplnumdig
                                ,lr_datrservapol.itmnumdig

         fetch cbdatr095016 into l_quantidade


         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode = 100 then
               display "ENTROU NO INSERT TEMP"
               let l_quant = 0

               execute pbdatr095017 using lr_datrservapol.succod
                                         ,lr_datrservapol.aplnumdig
                                         ,lr_datrservapol.ramcod
                                         ,lr_datrservapol.itmnumdig

               if sqlca.sqlcode <> 0 then
                  display "ERRO INSERT (pbdatr095017) SQLCODE : ",sqlca.sqlcode
               end if


               open cbdatr095011 using lr_datrservapol.succod
                                      ,lr_datrservapol.ramcod
                                      ,lr_datrservapol.aplnumdig
                                      ,lr_datrservapol.itmnumdig
               foreach cbdatr095011 into lr_datrservapolaux.atdsrvnum,
                                         lr_datrservapolaux.atdsrvano,
                                         l_ligdat


                  let l_quant = l_quant + 1

                  let l_apolice = lr_datrservapol.succod    using '<<&&' ,"-",
                                  lr_datrservapol.ramcod    using '<<<&&' ,"-",
                                  lr_datrservapol.aplnumdig using '<<<<<<<<&&' ,"-",
                                  lr_datrservapol.itmnumdig using '<<&&' ,"-",
                                  lr_datrservapol.edsnumref using '<<<<<<<&&'

                  let l_cgccpf = bdatr095_formata_cgccpf(lr_cgccpf.cgccpfnum
                                                         ,lr_cgccpf.cgcord
                                                         ,lr_cgccpf.cgccpfdig)

                  let l_numserv = lr_datrservapolaux.atdsrvnum  using '<<<<<<<<<<<&' ,"/",
                                  lr_datrservapolaux.atdsrvano using '&&'

                   let mr_count.processados = mr_count.processados + 1
                   let m_rel = true
                   output to report rep_bdatr095( lr_datrservapol.succod
                                                 ,lr_datrservapol.ramcod
                                                 ,lr_datrservapol.aplnumdig
                                                 ,lr_datrservapol.itmnumdig
                                                 ,lr_datrservapol.edsnumref
                                                 ,lr_abbmveic.vcllicnum
                                                 ,l_ligdat
                                                 ,l_numserv
                                                 ,lr_datrsrvcls.clscod
                                                 ,l_cgccpf
                                                 ,l_susep
                                                 ,mr_count.total_apolice
                                                 ,mr_count.total_imovel
                                                 ,mr_count.total_auto
                                                 ,mr_count.total_locacao
                                                 ,l_vlr_imov
                                                 ,l_vlr_auto
                                                 ,l_vlr_locacao)

                  let l_apolice_ant = l_apolice
               end foreach
            else
               display "ERRO SELECT (cbdatr095016) SQLCODE: ",sqlca.sqlcode
            end if
         end if
      end if
   end foreach


finish report  rep_bdatr095

if mr_count.processados >= 1 then

 display "Criando e-mail..."
 
  call bdatr095_compacta(dirfisnom)
		     returning dirfisnom

  let l_cont = 1

  open cbdatr095009 using param_email
  foreach cbdatr095009 into emails[l_cont]

    if l_cont = 1 then
      let lr_mens.para = emails[l_cont] clipped
    else
      let lr_mens.para =lr_mens.para clipped
                        ,","
                        ,emails[l_cont] clipped
    end if
    let l_cont = l_cont + 1
  end foreach

  let lr_mens.anexo = dirfisnom

  let lr_mens.assunto = "Controle de Atendimento Produto - ",dataini

  let lr_mens.msg =  "<html><body><font face = Times New Roman>Prezado(s), <br><br>"
                    ,"Segue anexo Relat&oacute;rio <br><br>"
                    ,"Refer&ecirc;ncia: " ,dataini,  ". <br><br>"
                    ,"Atenciosamente, <br><br>"
                    ,"Corpora&ccedil;&atilde;o Porto Seguro - http://www.portoseguro.com.br"
                    ,"<br><br></font></body></html>"


   call send_email_bdatr095(lr_mens.para
                           ,lr_mens.cc
                           ,lr_mens.anexo
                           ,lr_mens.assunto
                           ,lr_mens.msg)

end if

end function

#------------------------------------------------------------------------------#
function send_email_bdatr095(lr_mens)
#------------------------------------------------------------------------------#
  define lr_mens  record
         para     char(10000)
        ,cc       char(10000)
        ,anexo    char(32000)
        ,assunto  char(500)
        ,msg      char(400)
  end record

  define  l_mail       record
          de           char(500)   # De
         ,para         char(10000)  # Para
         ,cc           char(10000)   # cc
         ,cco          char(500)   # cco
         ,assunto      char(500)   # Assunto do e-mail
         ,mensagem     char(32766) # Nome do Anexo
         ,id_remetente char(20)
         ,tipo         char(4)     #
  end  record
  
  define l_coderro  smallint
  
  define msg_erro char(500)
  
  define  l_sistema   char(10)
         ,l_remet     char(50)
         ,l_cmd     	char(8000)
         ,l_ret     	smallint
         ,l_assunto 	char(200)

  let l_sistema  = "CT24HS"
  let l_remet = "ct24hs.email@portoseguro.com.br"
  initialize l_cmd to null
  let l_ret = null


  display 'Enviando e-mail para: ', lr_mens.para clipped

  #PSI-2013-23297 - Inicio
  let l_mail.de = l_remet
  let l_mail.para =  lr_mens.para
  let l_mail.cc = ""
  let l_mail.cco = ""
  let l_mail.assunto =  lr_mens.assunto
  let l_mail.mensagem = lr_mens.msg
  let l_mail.id_remetente = "CT24HS"
  let l_mail.tipo = "html"
  
  if m_rel = true then
    call figrc009_attach_file(lr_mens.anexo)
    display "Arquivo anexado com sucesso"
  else
    let l_mail.mensagem = "Nao existem registros a serem processados."
  end if

  call figrc009_mail_send1 (l_mail.*)
     returning l_coderro,msg_erro
  #PSI-2013-23297 - Fim

  if l_coderro = 0  then
    let l_assunto = 'Email enviado com sucesso! ',current
  else
    let l_assunto = 'Email nao enviado        ! ',current
  end if

  display l_assunto

end function

#------------------------------------------------------------------------------
function bdatr095_formata_cgccpf(l_param)
#------------------------------------------------------------------------------

define l_param   record
       cgccpfnum like gsakpes.cgccpfnum,
       cgcord    like gsakpes.cgcord,
       cgccpfdig like gsakpes.cgccpfdig
end record

define l_cgccpf char(12)
define l_format char(20)


    let l_cgccpf = l_param.cgccpfnum using '&&&&&&<<<<<<'
    let l_cgccpf = l_cgccpf[4,6],".",l_cgccpf[7,9],".",l_cgccpf[10,12]

    if l_param.cgcord is null or
       l_param.cgcord = 0     then
          let l_format =  l_cgccpf clipped ,"-", l_param.cgccpfdig using '&&'
    else
          let l_format =  l_cgccpf clipped ,"/", l_param.cgcord using '&&&&' ,"-", l_param.cgccpfdig using '&&'
    end if

    return l_format

end function



#------------------------------------------------------------------------------#
report rep_bdatr095(lr_param)
#------------------------------------------------------------------------------#

   define lr_param      record
          succod        like datrligapol.succod
         ,ramcod        like datrligapol.ramcod
         ,aplnumdig     like datrligapol.aplnumdig
         ,itmnumdig     like datrligapol.itmnumdig
         ,edsnumref     like datrligapol.edsnumref
         ,vcllicnum     like abbmveic.vcllicnum
         ,ligdat        like datmligacao.ligdat
         ,numserv       char(200)
         ,clscod        like datrsrvcls.clscod
         ,cpf           char(30)
         ,susep         like abamcor.corsus
         ,total         smallint
         ,total_imovel  smallint
         ,total_auto    smallint
         ,total_locacao smallint
         ,vlr_imov      decimal(10,2)
         ,vlr_auto      decimal(10,2)
         ,vlr_locacao   decimal(10,2)
   end record

   define l_total  char(12)


   output
      left   margin 000
      top    margin 000
      bottom margin 000

     format
        first page header
        print '<html>'
                ,'<body>'
                ,'<table border=1>'
                  ,'<tr>'
                   ,'<td colspan=8 align="center" bgcolor=DodgerBlue>DOCUMENTO</td>'
                   ,'<td colspan=2 align="center" bgcolor=DodgerBlue>DADOS DO ULTIMO SERVICO ABERTO</td>'
                   ,'<td bgcolor=DodgerBlue>Clausula</td>'
                   ,'<td colspan=3 align="center" width=140 bgcolor=DodgerBlue>Quantidade/Tipo</td>'
                   ,'<td colspan=2 align="center" bgcolor=DodgerBlue>Total de Servicos</td>'
                 ,'</tr>'
                 ,'<tr>'
                   ,'<td width=85 bgcolor=DodgerBlue>Sucursal</td>'
                   ,'<td width=85 bgcolor=DodgerBlue>Ramo</td>'
                   ,'<td width=85 bgcolor=DodgerBlue>Apolice</td>'
                   ,'<td width=85 bgcolor=DodgerBlue>Item</td>'
                   ,'<td width=85 bgcolor=DodgerBlue>Endosso</td>'
                   ,'<td width=200 bgcolor=DodgerBlue>CPF/CNPF</td>'
                   ,'<td width=200 bgcolor=DodgerBlue>SUSEP</td>'
                   ,'<td width=85  bgcolor=DodgerBlue>Placa</td>'
                   ,'<td width=100  bgcolor=DodgerBlue>Data</td>'
                   ,'<td width=130 bgcolor=DodgerBlue>Numero</td>'
                   ,'<td width=130 bgcolor=DodgerBlue></td>'
                   ,'<td width=90 bgcolor=DodgerBlue>Imovel</td>'
                   ,'<td width=80 bgcolor=DodgerBlue>Auto</td>'
                   ,'<td width=80 bgcolor=DodgerBlue>Locacao</td>'
                   ,'<td align="center" width=90 bgcolor=DodgerBlue>Quantidade</td>'
                   ,'<td align="center" width=90 bgcolor=DodgerBlue>Valor</td>'
                 ,'</tr>'

     #after group of lr_param.apolice
     on every row
          let lr_param.total = 0
          let lr_param.total = lr_param.total_imovel + lr_param.total_auto + lr_param.total_locacao
          let l_total = 0
          let l_total = lr_param.vlr_imov + lr_param.vlr_auto + lr_param.vlr_locacao using "########&.&&"


          print "<tr height=3D19 style=3D'height:14.4pt'>"
               ,"<td height=3D19 width=120 style=3D'height:14.4pt'>",lr_param.succod,"</td>"
               ,"<td height=3D19 width=120 style=3D'height:14.4pt'>",lr_param.ramcod,"</td>"
               ,"<td height=3D19 width=120 style=3D'height:14.4pt'>",lr_param.aplnumdig,"</td>"
               ,"<td height=3D19 width=120 style=3D'height:14.4pt'>",lr_param.itmnumdig,"</td>"
               ,"<td height=3D19 width=120 style=3D'height:14.4pt'>",lr_param.edsnumref,"</td>"
               ,"<td height=3D19 width=120 style=3D'height:14.4pt'>",lr_param.cpf,"</td>"
               ,"<td height=3D19 width=120 style=3D'height:14.4pt'>",lr_param.susep,"</td>"
               ,"<td width=85>",lr_param.vcllicnum,"</td>"
               ,"<td class=3Dxl66 width=65 align=3Dright>",lr_param.ligdat,"</td>"
               ,"<td width=150>",lr_param.numserv,"</td>"
               ,"<td align=3Dright width=70>",lr_param.clscod,"</td>"
               ,"<td width=90>",lr_param.total_imovel clipped,"</td>"
               ,"<td width=80>",lr_param.total_auto clipped,"</td>"
               ,"<td width=90>",lr_param.total_locacao clipped,"</td>"
               ,"<td width=80>",lr_param.total clipped,"</td>"
               ,"<td width=80 style='mso-number-format:R$\\##\\.\\##\\##0\\,00'>",l_total clipped,"</td>"
               ,"</tr>"

end report
#------------------------------------------------------#
function bdatr095_obter_segnumdig(l_param)
#------------------------------------------------------#
define l_param    record
       succod     like datrservapol.succod
      ,ramcod     like datrservapol.ramcod
      ,aplnumdig  like datrservapol.aplnumdig
      ,itmnumdig  like datrservapol.itmnumdig
      ,edsnumref  like datrservapol.edsnumref
end record

define l_segnumdig integer

let l_segnumdig = null
  if l_param.ramcod = 531 or
     l_param.ramcod = 31  then
     open cbdatr095019 using l_param.succod
                            ,l_param.aplnumdig
                            ,l_param.itmnumdig
                            ,l_param.edsnumref
        fetch cbdatr095019 into l_segnumdig
  else
     open cbdatr095020 using l_param.succod
                            ,l_param.ramcod
                            ,l_param.aplnumdig
       fetch cbdatr095020 into l_segnumdig
  end if
  
  if l_segnumdig is null then
     #display "teste segurado"
  end if
  return l_segnumdig
  
end function

#----------------------------------------------#
function bdatr095_obter_susep (l_param)
#----------------------------------------------#
define l_param    record
       succod     like datrservapol.succod
      ,ramcod     like datrservapol.ramcod
      ,aplnumdig  like datrservapol.aplnumdig
end record   

define l_susep            like abamcor.corsus

let l_susep = null
   if l_param.ramcod = 531 or
      l_param.ramcod = 31  then
       open cbdatr095015 using l_param.succod
                              ,l_param.aplnumdig
       fetch cbdatr095015 into l_susep
       close cbdatr095015
   else
       open cbdatr095021 using l_param.succod
                              ,l_param.ramcod
                              ,l_param.aplnumdig
       fetch cbdatr095021 into l_susep
       close cbdatr095021
   end if
   return l_susep
end function

#=============================================#
function bdatr095_compacta(dirfisnom)
#=============================================#

  define dirfisnom    char(100),
         l_comando    char(100)

  let l_comando = null

  # -> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", dirfisnom
  run l_comando
  let dirfisnom = dirfisnom clipped, ".gz"

  return dirfisnom

end function
