#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ............................................................................#
# Sistema.......: RADAR                                                       #
# Modulo........: bdbsr012                                                    #
# Analista Resp.: Debora Paez                                                 #
# PSI...........: 220710                                                      #
# Objetivo......: Pesquisar periodicamente os socorristas                     #
#.............................................................................#
# Desenvolvimento: Luiz Alberto, Meta                                         #
# Liberacao......: 23/04/2008                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
# ---------- ----------------- ---------- ----------------------------------- #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ----------------------------------- #
#                                                                             #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_log      char(200)
       ,m_path     char(100)
       ,m_arquivo  char(200)
       ,m_lidos    integer

main

   let m_path = null
   let m_log  = null
   let m_lidos = 0

   call fun_dba_abre_banco('CT24HS')

   let m_log = f_path('DBS','LOG')

   if m_log is null or
      m_log = ' '   then
      let m_log = '.'
   end if

   let m_log  = m_log clipped, '/dbs_bdbsr012.log'

   let m_path = f_path('DBS','RELATO')

   if m_path is null or
      m_path = ' '   then
      let m_path = '.'
   end if

   let m_arquivo = m_path clipped, '/bdbsr012.xls'

   call startlog(m_log)

   display '-------------------------------------------------------------------------'
   let m_log = 'Inicio do processamento: ',
               today using 'dd/mm/yyyy',' as ', time
   display m_log  clipped
   call errorlog(m_log)
   display ''

   call bdbsr012_prepare()
   call bdbsr012()

   display ''
   let m_log = 'Numero de registros lidos......: ', m_lidos
   display m_log  clipped
   call errorlog(m_log)

   display ''
   let m_log = 'Final do processamento: ',
                today using 'dd/mm/yyyy',' as ', time
   display m_log  clipped
   call errorlog(m_log)
   display '-------------------------------------------------------------------------'

end main

#--------------------------#
function bdbsr012_prepare()
#--------------------------#
   define l_sql char(500)

   let l_sql = 'select count (srrcoddig) '
              ,'  from datksrr '
              ,' where srrtip = 1 ' ## somente socorrista Porto Socorro
              ,' and srrstt = 1 '   ## somente os ativos

   prepare pbdbsr012001 from l_sql
   declare cbdbsr012001 cursor for pbdbsr012001

   let l_sql = 'select srrcoddig '
              ,'      ,srrnom '
              ,'      ,cgccpfnum '
              ,'      ,cgcord '
              ,'      ,cgccpfdig '
              ,'      ,pestip '
              ,'      ,socanlsitcod '
              ,'  from datksrr '
              ,' where (rdranlultdat is null '
              ,'    or rdranlultdat <= ?) '
              ,'   and srrtip = 1' ## somente socorrista Porto Socorro
              ,'   and srrstt = 1' ## somente os ativos

   prepare pbdbsr012002 from l_sql
   declare cbdbsr012002 cursor with hold for pbdbsr012002


end function

#------------------#
function bdbsr012()
#------------------#
   define l_nulo         char(001)
   define l_msg          char(080)
   define l_texto        char(070)
   define l_cpodes       char(050)
   define l_situacao     char(001)
   define l_sit_rd       smallint
   define l_sit_ps       smallint
   define l_cgccpf       char(018)
   define l_count        integer
   define l_coderro      smallint
   define l_ok           smallint
   define l_imprime      smallint
   define l_data         date
   define l_data_bco     date
   define l_data_hoje    date
   define l_hora         datetime hour to minute
   define l_srrcoddig    like datksrr.srrcoddig
   define l_srrnom       like datksrr.srrnom
   define l_cgcord       like datksrr.cgcord
   define l_cgccpfdig    like datksrr.cgccpfdig
   define l_pestip       like datksrr.pestip
   define l_srrhstseq    like datmsrrhst.srrhstseq
   define l_cgccpfaux    like datksrr.cgccpfnum

   let l_data         = date
   let l_data_hoje    = today
   let l_imprime      = false
   let l_ok           = false
   let l_pestip       = null
   let l_srrnom       = null
   let l_nulo         = null
   let l_situacao     = null
   let l_sit_rd       = null
   let l_sit_ps       = null
   let l_msg          = null
   let l_texto        = null
   let l_cpodes       = null
   let l_data_bco     = null
   let l_cgccpf       = null
   let l_cgccpfaux    = null
   let m_lidos        = 0
   let l_hora         = 0
   let l_count        = 0
   let l_srrcoddig    = 0
   let l_cgcord       = 0
   let l_cgccpfdig    = 0
   let l_coderro      = 0
   let l_srrhstseq    = 0

   open cbdbsr012001

   whenever error continue
   fetch cbdbsr012001 into l_count
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let m_log = 'Erro SELECT cbdbsr012001 / ', sqlca.sqlcode, ' / ', sqlca.sqlerrd[2]
      display m_log  clipped
      call errorlog(m_log)
      let m_log = 'bdbsr012 / bdbsr012() '
      display m_log  clipped
      call errorlog(m_log)
      exit program(1)
   end if

   let l_count = l_count / 6

   start report bdbsr012_relatorio to m_arquivo

   call cts40g03_data_hora_banco(2)
   returning l_data_bco
            ,l_hora

   let l_data = l_data_bco - 6 units month

   open cbdbsr012002 using l_data

   foreach cbdbsr012002 into l_srrcoddig
                            ,l_srrnom
                            ,l_cgccpfaux
                            ,l_cgcord
                            ,l_cgccpfdig
                            ,l_pestip
                            ,l_sit_ps

      if l_cgccpfaux is null then
         continue foreach
      end if

      let m_lidos = m_lidos + 1

      if m_lidos > l_count then
         exit foreach
      end if

      let g_issk.empcod = 1
      let g_issk.funmat = 999999
      let g_issk.usrtip = "F"
      let l_imprime = true

      call ffpta070(l_pestip
                   ,l_cgccpfaux
                   ,l_cgcord
                   ,l_cgccpfdig
                   ,3
                   ,' '
                   ,3)
         returning l_coderro
                  ,l_situacao
                  ,l_msg

      case l_situacao
           when "L"
                 let l_sit_rd = 1
                 let l_imprime = false
           when "S"
                 let l_sit_rd = 2
                 let l_sit_ps = 1
           when "R"
                 let l_sit_rd = 3
                 let l_sit_ps = 1
           when "B"
                 let l_sit_rd = 4
                 let l_sit_ps = 1
           otherwise
                 let l_sit_rd = 0
                 let l_sit_ps = 1
      end case

      call cty11g00_iddkdominio("rdranlsitcod" ,l_sit_rd)
           returning l_coderro ,l_msg ,l_cpodes

      if l_coderro <> 1 then
         let l_msg = l_sit_rd, " ", l_situacao
      end if

      let l_texto = 'SITUACAO DO RADAR EM '
                   ,l_data_bco
                   ,' '
                   ,l_cpodes clipped
                   ,' '
                   ,l_msg

      begin work
      call ctd18g01_grava_hist(l_srrcoddig
                              ,l_texto
                              ,l_data_bco
                              ,1
                              ,999999
                              ,'F')
           returning l_coderro ,l_msg

      if l_coderro <> 1 then
         display l_msg clipped
         rollback work
         continue foreach
      end if

      call ctd18g00_update_socorrista (l_data_bco
                                      ,l_sit_rd
                                      ,l_sit_ps
                                      ,l_data_bco
                                      ,l_srrcoddig)

           returning l_coderro ,l_msg

      if l_coderro <> 1 then
         display l_msg clipped
         rollback work
         continue foreach
      end if

      commit work

      if l_imprime then
         if l_pestip = 'J' then
            let l_cgccpf = l_cgccpfaux  using '&&,&&&,&&&'
                          ,'/'
                          ,l_cgcord    using '&&&&'
                          , '-'
                          ,l_cgccpfdig using '&&'
            let l_cgccpf[3] = '.'
            let l_cgccpf[7] = '.'
         else
            let l_cgccpf = l_cgccpfaux  using '&&&,&&&,&&&'
                          ,'-'
                          ,l_cgccpfdig using '&&'
            let l_cgccpf[4] = '.'
            let l_cgccpf[8] = '.'
         end if

         output to report bdbsr012_relatorio(l_srrcoddig
                                            ,l_srrnom
                                            ,l_cgccpf
                                            ,l_pestip)
         let l_ok = true
      end if

   end foreach

   finish report bdbsr012_relatorio

   if l_ok then
      let l_ok = ctx22g00_envia_email('BDBSR012'
                                     ,'Socorristas com ocorrencias no Radar'
                                     ,m_arquivo)

      if l_ok <> 0 then
         let m_log = 'Erro no envio do email / ', l_ok
         display m_log  clipped
         call errorlog(m_log)
      end if
   end if

end function

#----------------------------------#
report bdbsr012_relatorio(lr_param)
#----------------------------------#
   define lr_param      record
           srrcoddig    like datksrr.srrcoddig
          ,srrnom       like datksrr.srrnom
          ,cgccpf       char(018)
          ,pestip       like datksrr.pestip
   end record

   output
     right  margin 80
     left   margin 0
     bottom margin 0
     top    margin 0
     page   length 01

   format
     on every row
        if pageno = 01 then
           print column 001, "RELATORIO DE SOCORRISTAS COM OCORRENCIAS NO RADAR"
           print column 001, "CODIGO", ASCII(09),
                             "NOME", ASCII(09),
                             "CPF CNPF", ASCII(09),
                             "TIPO", ASCII(09)
           skip 1 line
        end if

        print column 001, lr_param.srrcoddig  using '&&&&&', ASCII(09),
                          lr_param.srrnom, ASCII(09),
                          lr_param.cgccpf, ASCII(09),
                          lr_param.pestip, ASCII(09)

    on last row
       skip 1 line
       print column 001, "Total de socorristas:", ASCII(09),
                         count(*)  using '#####&', ASCII(09)

end report

