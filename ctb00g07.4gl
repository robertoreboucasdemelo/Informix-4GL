#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Teleatendimento / Porto Socorro                             #
# Modulo         : ctb00g07                                                    #
#                  Qualificar a satisfacao com o socorrista.                   #
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 188603                                                      #
#..............................................................................#
# Desenvolvimento: META, Marcos M.P.                                           #
# Data           : 06/04/2005                                                  #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data        Resp         PSI         Alteracao                               #
# ----------  -----------  ----------  ----------------------------------------#
# 26/07/2010  Fabio Costa  PSI 258610  Revisao da consulta SAC                 #
#------------------------------------------------------------------------------#
database porto

define m_flgprep         smallint,
       m_tabela          char(80)


#=> PREPARA COMANDOS SQL DO MODULO
#-------------------------------------------------------------------------------
function ctb00g07_prep()
#-------------------------------------------------------------------------------
   define l_prep         char(1500)

   if m_flgprep then
      return true
   end if

   let m_tabela = "datkgeral"
   let l_prep = "select grlinf",
                "  from datkgeral",
                " where grlchv = 'PSOPERCSATISFAC'"
   whenever error continue
   prepare pctb00g070101 from l_prep
   declare cctb00g070101 cursor for pctb00g070101
   whenever error stop
   if sqlca.sqlcode <> 0 then
      return false
   end if

   let m_tabela = "datmsrvacp"
   #let l_prep = "select count(*)",
   #             "  from datmsrvacp a",
   #             " where a.atdetpcod in (3,4)",
   #             "   and a.atdetpdat >= ?",
   #             "   and a.atdetpdat <= ?",
   #             "   and a.srrcoddig  = ?",
   #             "   and a.atdsrvseq  = (select max(ult.atdsrvseq)",
   #                                    "  from datmsrvacp ult",
   #                                    " where ult.atdsrvnum = a.atdsrvnum",
   #                                    "   and ult.atdsrvano = a.atdsrvano)"
                                       
    let l_prep = "select count(*) ",
                  " from datmservico srv, ",
                       " datmsrvacp  acp ",
                 " where srv.atdetpcod in (3,4) ",
                   " and srv.atdsrvseq = acp.atdsrvseq ",
                   " and srv.atdsrvnum = acp.atdsrvnum ",
                   " and srv.atdsrvano = acp.atdsrvano ",                     
                   " and acp.atdetpdat >= ? ",                            
                   " and acp.atdetpdat <= ? ",                           
                   " and acp.srrcoddig  = ? "                          
                                  
   whenever error continue
   prepare pctb00g070202 from l_prep
   declare cctb00g070202 cursor for pctb00g070202
   whenever error stop
   if sqlca.sqlcode <> 0 then
      return false
   end if

   let m_flgprep = true

   display "Satisfacao", "	",
           "Codigo do Socorrista", "	",
           "Codigo do Prestador", "	",
           "Nome do Prestador", "	",
           "Data inicial", "	",
           "Data final", "	",
           "Numero de servicos", "	",
           "Numero de reclamacoes", "	",
           "Percentual de satisfacao", "	",
           "Socorrista pesquisa", "	",
           "Codigo erro", "	",
           "Mensagem erro", "	",
           "Qualificado", "	"

   return true

end function


#=> FUNCAO PRINCIPAL DO MODULO - QUALIFICA SATISFACAO COM O SOCORRISTA
#-------------------------------------------------------------------------------
function ctb00g07_qualifsatisf(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          srrcoddig      like datksrr.srrcoddig,  #=> Codigo do Socorrista
          pstcoddig      like dpaksocor.pstcoddig,#=> Codigo do Prestador
          nomgrr         like dpaksocor.nomgrr,   #=> Nome do Prestador
          dataini        date,                    #=> Data inicial
          datafim        date                     #=> Data final
   end record

   define lr_retorno     record
          coderro        integer,    #=> Codigo erro / 0=Ok <>0=Error
          msgerro        char(100),  #=> Mensagem erro
          ##qualificado    char(01)  #=> 'S'im ou 'N'ao
          numsrv         integer,                 #=> Numero de servicos
          numrec         integer,                 #=> Numero de reclamacoes
          percsatisf     dec(8,4)    #=> Percentual de satisfacao
   end record

   define lr_aux         record
          datainisac     datetime year to second,  #=> Para pesq SAC
          datafimsac     datetime year to second,  #=> Para pesq SAC
          #numsrv         integer,                 #=> Numero de servicos
          #numrec         integer,                 #=> Numero de reclamacoes
          #percsatisf     dec(8,4),                #=> Percentual de satisfacao
          srrtxt         varchar(40,0),
          psttxt	 varchar(40,0),
          srrmat         varchar(40,0),
          pstmat	 varchar(40,0)
   end record  
   
   define l_sql char(10000)

   #=> INICIALIZA VARIAVEIS
   initialize lr_aux.* to null

   let lr_retorno.coderro     = 0
   let lr_retorno.msgerro     = ""
   #let lr_retorno.qualificado = "N"
   let lr_retorno.percsatisf = 0

   #=> PREPARA COMANDOS SQL DO MODULO
   if not ctb00g07_prep() then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.msgerro = "Erro ao preparar ", m_tabela clipped,
                               " (ctb00g07): ", sqlca.sqlerrd[2]

      display "Satisfacao", "	",
              lr_param.srrcoddig, "	",
              lr_param.pstcoddig, "	",
              lr_param.nomgrr, "	",
              lr_aux.datainisac, "	",
              lr_aux.datafimsac, "	",
              lr_retorno.numsrv, "	",
              lr_retorno.numrec, "	",
              lr_retorno.percsatisf, "	",
              lr_aux.srrtxt, "	",
              lr_retorno.coderro, "	",
              lr_retorno.msgerro, "	"
              #lr_retorno.qualificado, "	"

      return lr_retorno.*
   end if

   #=> OBTEM PERCENTUAL DE SATISFACAO
   {#ligia 06/01/09 PSI 229784
      whenever error continue
      open  cctb00g070101
      fetch cctb00g070101  into lr_aux.percsatisf
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let lr_aux.percsatisf = 0.005 #=> VALOR PADRAO
         else
            let lr_retorno.coderro = sqlca.sqlcode
            let lr_retorno.msgerro = "Erro ao selecionar datkgeral (ctb00g07): ",
                                     sqlca.sqlerrd[2]
   display "Satisfacao", "	",
           lr_param.srrcoddig, "	",
           lr_param.pstcoddig, "	",
           lr_param.nomgrr, "	",
           lr_aux.datainisac, "	",
           lr_aux.datafimsac, "	",
           lr_retorno.numsrv, "	",
           lr_retorno.numrec, "	",
           lr_retorno.percsatisf, "	",
           lr_aux.srrtxt, "	",
           lr_retorno.coderro, "	",
           lr_retorno.msgerro, "	"
           #lr_retorno.qualificado, "	"

            return lr_retorno.*
         end if
      else
         if lr_aux.percsatisf is null then
            let lr_aux.percsatisf = 0.005 #=> VALOR PADRAO
         else
            let lr_aux.percsatisf = (lr_aux.percsatisf / 1000)
         end if
      end if
   } #ligia 06/01/09 PSI 229784

   #=> OBTEM NUMERO DE SERVICOS REALIZADOS PELO PRESTADOR NO PERIODO
   whenever error continue
   open  cctb00g070202 using lr_param.dataini,
                             lr_param.datafim,
                             lr_param.srrcoddig
   fetch cctb00g070202  into lr_retorno.numsrv
   whenever error stop

   if sqlca.sqlcode <> 0 or
      lr_retorno.numsrv = 0
      then
      if sqlca.sqlcode <> 0 then
         let lr_retorno.coderro = sqlca.sqlcode
         let lr_retorno.msgerro = "Erro ao selecionar datmsrvacp (ctb00g07): ",
                                  sqlca.sqlerrd[2]
      end if

      display "Satisfacao", "	",
              lr_param.srrcoddig, "	",
              lr_param.pstcoddig, "	",
              lr_param.nomgrr, "	",
              lr_aux.datainisac, "	",
              lr_aux.datafimsac, "	",
              lr_retorno.numsrv, "	",
              lr_retorno.numrec, "	",
              lr_retorno.percsatisf, "	",
              lr_aux.srrtxt, "	",
              lr_retorno.coderro, "	",
              lr_retorno.msgerro, "	"
              #lr_retorno.qualificado, "	"

      return lr_retorno.*
   end if

   #=> PREPARA VARIAVEIS DE DATA PARA O SAC
   let lr_aux.datainisac = lr_param.dataini
   let lr_aux.datafimsac = lr_param.datafim
   let lr_aux.datafimsac = lr_aux.datafimsac + 1 units day - 1 units second

   #=> OBTEM NUMERO DE RECLAMACOES NO SISTEMA DO SAC
   let lr_aux.srrtxt = lr_param.srrcoddig using "<<<<<<<<<&"
   let lr_aux.srrmat = lr_aux.srrtxt clipped, " *"
   let lr_aux.psttxt = lr_param.pstcoddig using "<<<<<<<<<&"
   let lr_aux.pstmat = lr_aux.psttxt clipped, " *"

 display "lr_aux.srrtxt = ", lr_aux.srrtxt
 display "lr_aux.psttxt = ", lr_aux.psttxt
 display "lr_aux.srrmat = ", lr_aux.srrmat
 display "lr_aux.pstmat = ", lr_aux.pstmat

   # Consulta SAC alterada em 23/09/2010 conforme indicacao do William Lima
   #ALTERADO select count(distinct a.sacocrnum) Ocorrencias
   #ALTERADO from sjcmocr a,
   #ALTERADO      sjctobj b,
   #ALTERADO      sjctobj c,
   #ALTERADO      sjctobj d,
   #ALTERADO      sjcmocradc e,
   #ALTERADO      sjctobj f,
   #ALTERADO      sjcmocradc g
   #ALTERADO where (a.sacocrhordat between lr_aux.datainisac and lr_aux.datafimsac)
   #ALTERADO   and b.sacobjcod = a.sacocrclscod
   #ALTERADO   and c.sacobjcod = b.sacobjpcpcod
   #ALTERADO   and d.sacobjcod = c.sacobjpcpcod
   #ALTERADO   and e.sacocrnum = a.sacocrnum
   #ALTERADO   and f.sacobjcod = e.sacocradcitm
   #ALTERADO   and g.sacocrnum = a.sacocrnum
   #ALTERADO   and ( (b.sacobjdes in ('PORTO SOCORRO - AUTO',
   #ALTERADO                          'PORTO SOCORRO - LINHA BRANCA',
   #ALTERADO                          'PORTO SOCORRO - LINHA BÁSICA',
   #ALTERADO                          'PORTO SOCORRO - HELP DESK',
   #ALTERADO                          'PORTO SOCORRO - CARTÕES',
   #ALTERADO                          'PORTO SOCORRO - FROTA COMPARTILHADA')
   #ALTERADO      and b.sacobjtip = 514 and b.sacobjpcpcod = 604)
   #ALTERADO      or (c.sacobjdes in ('PORTO SOCORRO - AUTO',
   #ALTERADO                          'PORTO SOCORRO - LINHA BRANCA',
   #ALTERADO                          'PORTO SOCORRO - LINHA BÁSICA',
   #ALTERADO                          'PORTO SOCORRO - HELP DESK',
   #ALTERADO                          'PORTO SOCORRO - CARTÕES',
   #ALTERADO                          'PORTO SOCORRO - FROTA COMPARTILHADA')
   #ALTERADO      and c.sacobjtip = 514 and c.sacobjpcpcod = 604)
   #ALTERADO      or (d.sacobjdes in ('PORTO SOCORRO - AUTO',
   #ALTERADO                          'PORTO SOCORRO - LINHA BRANCA',
   #ALTERADO                          'PORTO SOCORRO - LINHA BÁSICA',
   #ALTERADO                          'PORTO SOCORRO - HELP DESK',
   #ALTERADO                          'PORTO SOCORRO - CARTÕES',
   #ALTERADO                          'PORTO SOCORRO - FROTA COMPARTILHADA')
   #ALTERADO      and d.sacobjtip = 514 and d.sacobjpcpcod = 604) )
   #ALTERADO      and (e.sacocradccnt = lr_aux.srrtxt or e.sacocradccnt matches lr_aux.srrmat)
   #ALTERADO      and (f.sacobjdes    = lr_aux.psttxt or f.sacobjdes    matches lr_aux.pstmat)
   #ALTERADO      and f.sacobjtip     = 512
   #ALTERADO      and g.sacocradcitm  = 204627
   #ALTERADO      and g.sacocradccnt  = 'SIM'   
     
     let l_sql = " select count(distinct a.sacocrnum) Ocorrencias",
                   " from sjcmocr a, ",
                        " sjctobj b, ",
                        " sjctobj c, ",
                        " sjctobj d, ",
                        " sjcmocradc e, ",
                        " sjctobj f, ",
                        " sjcmocradc g ",
                  " where (a.sacocrhordat between ? and ?) ",
                    " and b.sacobjcod = a.sacocrclscod ",
                    " and c.sacobjcod = b.sacobjpcpcod ",
                    " and d.sacobjcod = c.sacobjpcpcod ",
                    " and ((b.sacobjdes in ('PORTO SOCORRO - AUTO', ",
                                          " 'PORTO SOCORRO - LINHA BRANCA', ",
                                          " 'PORTO SOCORRO - LINHA BÁSICA', ",
                                          " 'PORTO SOCORRO - HELP DESK', ",
                                          " 'PORTO SOCORRO - CARTÕES', ",
                                          " 'PORTO SOCORRO - FROTA COMPARTILHADA', ",
                                          " 'PORTO SOCORRO - PET') ",
                         " and b.sacobjtip = 514 and b.sacobjpcpcod = 604) ",
                     " or (c.sacobjdes in ('PORTO SOCORRO - AUTO', ",
                                         " 'PORTO SOCORRO - LINHA BRANCA', ",
                                         " 'PORTO SOCORRO - LINHA BÁSICA', ",
                                         " 'PORTO SOCORRO - HELP DESK', ",
                                         " 'PORTO SOCORRO - CARTÕES', ",
                                         " 'PORTO SOCORRO - FROTA COMPARTILHADA', ",
                                         " 'PORTO SOCORRO - PET') ",
                         " and c.sacobjtip = 514 and c.sacobjpcpcod = 604) ",
                     " or (d.sacobjdes in ('PORTO SOCORRO - AUTO', ",
                                         " 'PORTO SOCORRO - LINHA BRANCA', ",
                                         " 'PORTO SOCORRO - LINHA BÁSICA', ",
                                         " 'PORTO SOCORRO - HELP DESK', ",
                                         " 'PORTO SOCORRO - CARTÕES', ",
                                         " 'PORTO SOCORRO - FROTA COMPARTILHADA', ",
                                         " 'PORTO SOCORRO - PET') ",
                   " and d.sacobjtip = 514 and d.sacobjpcpcod = 604)) ",
                   " and e.sacocrnum = a.sacocrnum ",
                   " and f.sacobjcod = e.sacocradcitm ",
                   " and f.sacobjtip = 512 ",
                   " and g.sacocrnum = a.sacocrnum ",
                   " and g.sacocradcitm = 277546 ",
                   " and g.sacocradccnt = '", lr_aux.psttxt clipped, "'|| '|SIM' ",
                   " and (e.sacocradccnt = '", lr_aux.srrtxt clipped, "'",
                   "   or e.sacocradccnt matches '", lr_aux.srrtxt clipped, "*') ",
                   " and (f.sacobjdes    = '",lr_aux.psttxt clipped,"'",
                   "   or f.sacobjdes    matches '", lr_aux.psttxt clipped, "*') "

   
   display l_sql clipped
   
   whenever error continue
   prepare pctb00g070303 from l_sql
   declare cctb00g070303 cursor for pctb00g070303
   
   open  cctb00g070303  using lr_aux.datainisac, 
                              lr_aux.datafimsac
   fetch cctb00g070303  into lr_retorno.numrec
   whenever error stop

   display "sqlca.sqlcode = ", sqlca.sqlcode
   
   if sqlca.sqlcode <> 0 then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.msgerro = "Erro ao selecionar dados do SAC (ctb00g07): ",
                               sqlca.sqlerrd[2]

      display "Satisfacao", "	",
              lr_param.srrcoddig, "	",
              lr_param.pstcoddig, "	",
              lr_param.nomgrr, "	",
              lr_aux.datainisac, "	",
              lr_aux.datafimsac, "	",
              lr_retorno.numsrv, "	",
              lr_retorno.numrec, "	",
              lr_retorno.percsatisf, "	",
              lr_aux.srrtxt, "	",
              lr_retorno.coderro, "	",
              lr_retorno.msgerro, "	"
              #lr_retorno.qualificado, "	"

      return lr_retorno.*
   end if

   close cctb00g070303

   #=> CALCULA O PERCENTUAL DE SATISFACAO
   if lr_retorno.numrec > 0 then
      let lr_retorno.percsatisf = (lr_retorno.numrec / lr_retorno.numsrv)*100
   else
      let lr_retorno.percsatisf = 0
   end if

   #if ( lr_aux.numrec / lr_aux.numsrv ) <= lr_aux.percsatisf then
   #   let lr_retorno.qualificado = "S"
   #end if

   #let lr_retorno.msgerro = lr_retorno.numrec using "<<&",
   #                         "/",
   #                         lr_retorno.numsrv using "<<<&",
   #                         " = ",
   #                         ( lr_retorno.numrec / lr_retorno.numsrv *1000) using "<<<&",
   #                         " em 1000"

   let lr_retorno.msgerro = lr_retorno.numsrv using "<<&"," servicos entre ",
                            lr_param.dataini," e ", lr_param.datafim,". ",
                            lr_retorno.numrec using "<<<&"," reclamacoes. ",
                            "Indice de ", (lr_retorno.percsatisf*10)
                             using "<<&.&&", " em 1000."

   display "Satisfacao", "	",
           lr_param.srrcoddig, "	",
           lr_param.pstcoddig, "	",
           lr_param.nomgrr, "	",
           lr_aux.datainisac, "	",
           lr_aux.datafimsac, "	",
           lr_retorno.numsrv, "	",
           lr_retorno.numrec, "	",
           lr_retorno.percsatisf, "	",
           lr_aux.srrtxt, "	",
           lr_retorno.coderro, "	",
           lr_retorno.msgerro, "	"
           #lr_retorno.qualificado, "	"

   return lr_retorno.*

end function
