#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24 HORAS                           #
# MODULO.........: bdbsr008                                                   #
# ANALISTA RESP..: Marcio Augusto Fajan                                       #
# PSI/OSF........: PSI-2012-26565/EV                                          #
# OBJETIVO.......: Extrair as movimentacoes das reservas de veiculo solicitada#
#                  as locadoras associadas a corporacao                       #
# ........................................................................... #
# DESENVOLVIMENTO: Claudinei de Oliveira , BRQ                                #
# LIBERACAO......: 12/12/2012                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 26/05/14   Rodolfo Massini            Alteracao na forma de envio de        #
#                                       e-mail (SENDMAIL para FIGRC009)       # 
###############################################################################
database porto

define m_arq        char(500)
      ,m_path       char(100)
      ,m_arqnome    char(200)

#------------------------------------------------------#
#                       MAIN                           #
#------------------------------------------------------#
main

   call fun_dba_abre_banco('CT24HS')
   
   call bdbsr008_busca_path()
   
   call bdbsr008_prepare()

   if not figrc012_sitename("CT24HS","","") then
      exit program(1)
   end if

   call bdbsr008_emitirRelatorio()
   
   call bdbsr008_envia_email()

end main

#------------------------------------------------------#
function bdbsr008_prepare()
#------------------------------------------------------#

   define l_sql char(2000)

   let l_sql = "select t1.atdsrvnum, t1.atdsrvano, t1.atdsrvseq,    ",
               "       t2.atdetpdes, t1.atdetpdat, t1.atdetphor,    ",
               "       t6.lcvcod, trim(t6.lcvnom), trim(t5.empnom), ",
               "       t1.funmat, t1.empcod, t6.acntip              ",
               "  from datmsrvacp as t1                             ",
               "       inner join datketapa as t2                   ",
               "           on  t2.atdetpcod    = t1.atdetpcod       ",
               "       inner join datmservico as t3                 ",
               "           on  t3.atdsrvnum    = t1.atdsrvnum       ",
               "           and t3.atdsrvano    = t1.atdsrvano       ",
               "       inner join datmavisrent as t4                ",
               "           on  t4.atdsrvnum    = t1.atdsrvnum       ",
               "           and t4.atdsrvano    = t1.atdsrvano       ",
               "       inner join gabkemp as t5                     ",
               "           on  t5.empcod       = t3.ciaempcod       ",
               "       inner join datklocadora as t6                ",
               "           on  t6.lcvcod       = t4.lcvcod          ",
               " where t3.atddat >= ?                               ",
               "order by t1.atdsrvnum, t1.atdsrvano, t1.atdsrvseq   "
   prepare pbdbsr008001 from l_sql
   declare cbdbsr008001 cursor for pbdbsr008001

   let l_sql = "select grlinf from datkgeral   ",
               " where grlchv = 'PSOLOCDIAREL' "
   prepare pbdbsr008002 from l_sql
   declare cbdbsr008002 cursor for pbdbsr008002

   let l_sql = "select relpamtxt            ",
               "   from igbmparam           ",
               "  where relsgl = 'BDBSR008' "
   prepare pbdbsr008003 from l_sql
   declare cbdbsr008003 cursor for pbdbsr008003

end function

#------------------------------------------------------#
function bdbsr008_emitirRelatorio()
#------------------------------------------------------#
   define lr_rel record
           atdsrvnum   like datmsrvacp.atdsrvnum  #Número do Serviço
          ,atdsrvano   like datmsrvacp.atdsrvano  #Ano do Serviço
          ,atdsrvseq   like datmsrvacp.atdsrvseq  #Sequencia
          ,atdetpdes   like datketapa.atdetpdes   #Descrição da Etapa
          ,atdetpdat   like datmsrvacp.atdetpdat  #Data da Gravação da Etapa
          ,atdetphor   like datmsrvacp.atdetphor  #Hora da Gravação da Etapa
          ,lcvcod      like datklocadora.lcvcod   #Código da Locadora
          ,lcvnom      like datklocadora.lcvnom   #Nome Locadora
          ,empnom      like gabkemp.empnom        #Nome Empresa
          ,funmat      like datmsrvacp.funmat      #Matricula Atualizacao
          ,empcod      like datmsrvacp.empcod      #Empresa Atualizacao
          ,acntip      like datklocadora.acntip   #Tipo Acionamento
   end record

   define l_atddat     like datmservico.atddat
         ,l_lstemail   char (1000)
         ,m_arqnome    char (100)


   call bdbsr008_conspdatret() returning l_atddat

   start report bdbsr008_rep to m_arq

   whenever error continue
   open cbdbsr008001 using l_atddat

   foreach cbdbsr008001 into lr_rel.atdsrvnum
                            ,lr_rel.atdsrvano
                            ,lr_rel.atdsrvseq
                            ,lr_rel.atdetpdes
                            ,lr_rel.atdetpdat
                            ,lr_rel.atdetphor
                            ,lr_rel.lcvcod
                            ,lr_rel.lcvnom
                            ,lr_rel.empnom
                            ,lr_rel.funmat
                            ,lr_rel.empcod
                            ,lr_rel.acntip

      output to report bdbsr008_rep(lr_rel.*)
   end foreach

   if sqlca.sqlcode <> 0   and
      sqlca.sqlcode <> 100 then
      display "Erro ao montar relatorio de reservas. sqlcode: ", sqlca.sqlcode sleep 2
      exit program
   end if

   close cbdbsr008001
   whenever error stop

   finish report bdbsr008_rep


end function

#------------------------------------------------------#
report bdbsr008_rep(lr_rel)
#------------------------------------------------------#
   define lr_rel record
           atdsrvnum   like datmsrvacp.atdsrvnum  #Número do Serviço
          ,atdsrvano   like datmsrvacp.atdsrvano  #Ano do Serviço
          ,atdsrvseq   like datmsrvacp.atdsrvseq  #Sequencia
          ,atdetpdes   like datketapa.atdetpdes   #Descrição da Etapa
          ,atdetpdat   like datmsrvacp.atdetpdat  #Data da Gravação da Etapa
          ,atdetphor   like datmsrvacp.atdetphor  #Hora da Gravação da Etapa
          ,lcvcod      like datklocadora.lcvcod   #Código da Locadora
          ,lcvnom      like datklocadora.lcvnom   #Nome Locadora
          ,empnom      like gabkemp.empnom        #Nome Empresa
          ,funmat      like datmsrvacp.funmat     #Matricula Atualizacao
          ,empcod      like datmsrvacp.empcod     #Empresa Atualizacao
          ,acntip      like datklocadora.acntip   #Tipo Acionamento
   end record

   define l_funnom      like isskfunc.funnom
   define l_acndes      char(20)


   output
      right  margin 0
      left   margin 0
      bottom margin 0
      top    margin 0

   format
      first page header
         print "Numero do Servico"      , ascii(59)
              ,"Ano Servico"            , ascii(59)
              ,"Sequencia"              , ascii(59)
              ,"Descricao Etapa"        , ascii(59)
              ,"Matricula Resp."        , ascii(59)
              ,"Nome Resp."             , ascii(59)
              ,"Data da Gravacao Etapa" , ascii(59)
              ,"Hora da Gravacao Etapa" , ascii(59)
              ,"Codigo da Locadora"     , ascii(59)
              ,"Nome Locadora"          , ascii(59)
              ,"Nome Empresa"           , ascii(59)
              ,"Tipo de Acion."         , ascii(59)
              ,"Desc tipo de Acion."    , ascii(59)

      on every row

         whenever error continue

         select funnom into l_funnom
          from isskfunc
          where funmat = lr_rel.funmat
           and  empcod = lr_rel.empcod

         whenever error stop

         if lr_rel.acntip = 1 then
          let l_acndes = 'Internet'
         else
          if lr_rel.acntip = 2 then
             let l_acndes = 'Fax'
          end if
         end if


         print lr_rel.atdsrvnum  clipped   ,ascii(59)
              ,lr_rel.atdsrvano  clipped   ,ascii(59)
              ,lr_rel.atdsrvseq  clipped   ,ascii(59)
              ,lr_rel.atdetpdes  clipped   ,ascii(59)
              ,lr_rel.funmat     clipped   ,ascii(59)
              ,l_funnom          clipped   ,ascii(59)
              ,lr_rel.atdetpdat  using     "dd/mm/yyyy"  clipped ,ascii(59)
              ,lr_rel.atdetphor  clipped   ,ascii(59)
              ,lr_rel.lcvcod     clipped   ,ascii(59)
              ,lr_rel.lcvnom     clipped   ,ascii(59)
              ,lr_rel.empnom     clipped   ,ascii(59)
              ,lr_rel.acntip     clipped   ,ascii(59)
              ,l_acndes          clipped   ,ascii(59)

end report

#------------------------------------------------------#
function bdbsr008_conspdatret()
#------------------------------------------------------#

   define l_argval1 smallint
         ,l_atddat  like datmservico.atddat

   define l_grlinf like datkgeral.grlinf

   let l_grlinf  = null
   let l_argval1 = 0

   let l_argval1 = arg_val(1)

   if l_argval1 is null or
      l_argval1 = 0     then
      whenever error continue
      open  cbdbsr008002
      fetch cbdbsr008002 into l_grlinf

      if sqlca.sqlcode <> 0 then
         display "Erro consulta tabela que retorna parametro Data. sqlcode: ", sqlca.sqlcode sleep 2
         exit program
      end if

      let l_argval1 = l_grlinf

      close cbdbsr008002
      whenever error stop

   end if

   let l_atddat = current - l_argval1 units day

   return l_atddat

end function

#------------------------------------------------------#
function bdbsr008_emaillstret()
#------------------------------------------------------#
   define l_lstemail   char(1000)

   define l_cpodes     like iddkdominio.cpodes

   let l_lstemail = null

   whenever error continue
   open  cbdbsr008003

   foreach cbdbsr008003 into l_cpodes
      if sqlca.sqlcode != 0 or
         sqlca.sqlcode  = 100 then
         exit foreach
      end if

      if l_lstemail is null then
         let l_lstemail = l_cpodes clipped
      else
         let l_lstemail = l_lstemail clipped ,"," ,l_cpodes clipped
      end if

   end foreach

   if sqlca.sqlcode <> 0 then
      display "Erro na consulta da tabela de emails. sqlcode: ", sqlca.sqlcode sleep 2
      exit program
   end if

   close cbdbsr008003
   whenever error stop

   return l_lstemail

end function


function bdbsr008_envia_email()

   define l_retorno smallint 
   define l_assunto char(200)
   define l_comando char(100)
      
   let l_assunto = null
   let l_comando = null
   let l_retorno = null 
   
   let l_assunto = "Relatorio de Acionamento de Carro Extra por E-mail"

   let l_comando = "gzip -f ", m_arq 
   run l_comando  
   
   let m_arq = m_arq clipped, ".gz"
   display "m_arq: ", m_arq clipped

   let l_retorno = ctx22g00_envia_email("BDBSR008", l_assunto, m_arq)
   
      if l_retorno <> 0 then
         if l_retorno <> 99 then
            display "Erro ao enviar email(ctx22g00) - ", m_arq clipped
         else
            display "Nao existe email cadastrado para o modulo - BDBSR008"
         end if
      end if 

end function


function bdbsr008_busca_path()

   define l_dataarq char(8)
   
   let l_dataarq = extend(today, year to year),
                   extend(today, month to month),
                   extend(today, day to day)

   let m_path = f_path("DBS","RELATO")
   
   if  m_path is null then
      let m_path = "."
   end if

   let m_arqnome = arg_val(2)

   if m_arqnome = " " then
      let m_arqnome = "/bdbsr008_", l_dataarq, ".csv"
   else
      let m_arqnome = "/", m_arqnome clipped,"_", l_dataarq, ".csv"
   end if

   let m_arq = m_path clipped, m_arqnome clipped

end function