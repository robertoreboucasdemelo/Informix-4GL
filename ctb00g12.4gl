#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Teleatendimento / Porto Socorro                             #
# Modulo         : ctb00g12                                                    #
#                  Qualificar a resolubilidade dos socorristas RE              #
# Analista Resp. : Ligia Mattge                                                #
# PSI            : 229784                                                      #
#..............................................................................#
# Desenvolvimento:                                                             #
# Data           :                                                             #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data       Analista Resp/Autor Fabrica  PSI/Alteracao                        #
# ---------- ---------------------------- -------------------------------------#
#------------------------------------------------------------------------------#
database porto

define m_flgprep         smallint

#=> PREPARA COMANDOS SQL DO MODULO
#-------------------------------------------------------------------------------
function ctb00g12_prep()
#-------------------------------------------------------------------------------
   define l_prep         char(1500)
   
   if m_flgprep then
      return true
   end if
   
   ## obterm os servigos de RE do socorrista dentro do periodo
   let l_prep = "select distinct acp.atdsrvnum, acp.atdsrvano, acp.atdetpdat ",
                 " from datmservico srv, ",
                      " datmsrvacp  acp ",
                " where acp.atdetpdat >= ? ",
                  " and acp.atdetpdat <= ? ",
                  " and srv.srrcoddig = ? ",
                  " and pstcoddig     = ? ",
                  " and srv.atdetpcod = 3 ",
                  " and srv.atdsrvnum = acp.atdsrvnum ",
                  " and srv.atdsrvano = acp.atdsrvano "
   
   whenever error continue
   prepare pctb00g12001 from l_prep
   declare cctb00g12001 cursor for pctb00g12001
   whenever error stop
   if sqlca.sqlcode <> 0 then
      return false
   end if

   ## obtem os servicos de retorno do servico original
   let l_prep = "select atdsrvnum, atdsrvano from datmsrvre ",
                " where atdorgsrvnum = ? ",
                "   and atdorgsrvano = ? ",
                " order by 1 "

   whenever error continue
   prepare pctb00g12002 from l_prep
   declare cctb00g12002 cursor for pctb00g12002
   whenever error stop
   if sqlca.sqlcode <> 0 then
      return false
   end if

   ## obtem a etapa do servico de retorno para ver se foi acionado mesmo
   let l_prep = "select atdetpdat from datmsrvacp a ",
                "   where a.atdetpcod = 10 ",
                "   and a.atdsrvnum = ?",
                "   and a.atdsrvano = ?",
                "   and a.atdsrvseq = (select max(ult.atdsrvseq)",
                                      "  from datmsrvacp ult",
                                      " where ult.atdsrvnum = a.atdsrvnum",
                                      "   and ult.atdsrvano = a.atdsrvano)"
   whenever error continue
   prepare pctb00g12003 from l_prep
   declare cctb00g12003 cursor for pctb00g12003
   whenever error stop
   if sqlca.sqlcode <> 0 then
      return false
   end if

   let m_flgprep = true

   display "Resolubilidade", "	",
           "Cod Socorrista", "	",
           "Cod Prestador", "	",
           "Nome Prestador", "	",
           "Numero do servico original", "	",
           "Ano do servico original", "	",
           "Data do servico original", "	",
           "Numero do servico RET", "	",
           "Ano do servico RET", "	",
           "Data do servico RET", "	",
           "Tot servicos", "	",
           "Tot retornos", "	",
           "Perc Resolub", "	",
           "Msg RET ?", "	"

   return true

end function


#=> FUNCAO PRINCIPAL DO MODULO - QUALIFICA A RESOLUBILIDADE DO SOCORRISTA RE
#-------------------------------------------------------------------------------
function ctb00g12_qualifresolub(lr_param)
#-------------------------------------------------------------------------------

   define lr_param       record
          srrcoddig      like datksrr.srrcoddig,  #=> Codigo do Socorrista
          pstcoddig      like dpaksocor.pstcoddig,#=> Codigo do Prestador
          nomgrr         char(10), ##like dpaksocor.nomgrr,   #=> Nome do Prestador
          dataini        date,                    #=> Data inicial
          datafim        date                     #=> Data final
   end record

   define lr_retorno     record
          coderro        integer,  #=> Codigo erro / 0=Ok <>0=Error
          msgerro        char(120), #=> Mensagem erro
          numsrv         integer,                 #=> Numero de servicos
          numret         integer,                 #=> Numero de retornos
          percresolub    dec(8,4)  #=> Percentual de resolubilidade 
   end record

   define l_atdsrvnum_org like datmservico.atdsrvnum,
          l_atdsrvano_org like datmservico.atdsrvano,
          l_atdsrvnum_ret like datmservico.atdsrvnum,
          l_atdsrvano_ret like datmservico.atdsrvano,
          l_data_org      date,
          l_data_ret      date,
          l_data_garantia date

   define l_tot_srv     integer,
          l_tot_ret     integer,
          l_tot_sem_ret integer

   let lr_retorno.coderro     = 0
   let lr_retorno.msgerro     = ""
   let lr_retorno.numsrv      = 0
   let lr_retorno.numret      = 0
   let lr_retorno.percresolub = 0

   let l_atdsrvnum_org = null
   let l_atdsrvano_org = null
   let l_atdsrvnum_ret = null
   let l_atdsrvano_ret = null
   let l_data_org = null
   let l_data_ret = null
   let l_data_garantia = null

   let l_tot_srv = 0
   let l_tot_ret = 0
   let l_tot_sem_ret = 0

#=> PREPARA COMANDOS SQL DO MODULO
   if not ctb00g12_prep() then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.msgerro = "Erro ao preparar em (ctb00g12): ", 
                               sqlca.sqlerrd[2]
      display "Resolubilidade", "	",
              lr_param.srrcoddig using "<<<<<<<<<<", "	",
              lr_param.pstcoddig using "<<<<<<<<<<", "	",
              lr_param.nomgrr, "	",
              l_atdsrvnum_org using "<<<<<<<<<", "	",
              l_atdsrvano_org using "<<", "	",
              l_data_org, "	",
              l_atdsrvnum_ret using "<<<<<<<<<", "	",
              l_atdsrvano_ret using "<<", "	",
              l_data_ret, "	",
              lr_retorno.numsrv using "<<<<<<", "	",
              lr_retorno.numret using "<<<<<<", "	",
              lr_retorno.percresolub using "<<<<<<", "	",
              lr_retorno.msgerro clipped,"	"
      return lr_retorno.*
   end if

#=> OBTEM OS SERVICOS REALIZADOS PELO PRESTADOR NO PERIODO
   whenever error continue
   open  cctb00g12001 using lr_param.dataini,
                            lr_param.datafim,
                            lr_param.srrcoddig,
                            lr_param.pstcoddig

   let l_tot_srv = 0
   let l_tot_ret = 0

   ##obtem os servicos originais do socorrista
   foreach cctb00g12001 into l_atdsrvnum_org, l_atdsrvano_org, l_data_org

      let l_data_garantia = l_data_org + 3 units month

      let l_atdsrvnum_ret = null
      let l_atdsrvano_ret = null

      ##obte o servico de retorno
      open  cctb00g12002 using l_atdsrvnum_org, l_atdsrvano_org
      fetch cctb00g12002 into l_atdsrvnum_ret, l_atdsrvano_ret

      if sqlca.sqlcode <> notfound then

         ##verifica se esta acionado para contar
         let l_data_ret = null
         open  cctb00g12003 using l_atdsrvnum_ret, l_atdsrvano_ret
         fetch cctb00g12003 into l_data_ret
   
         if sqlca.sqlcode = 0 then
   
            ##considera somente se o retorno estiver dentro da garantia 90 dias.
            if l_data_ret <= l_data_garantia then
               display "Resolubilidade", "	",
                       lr_param.srrcoddig using "<<<<<<<<<<", "	",
                       lr_param.pstcoddig using "<<<<<<<<<<", "	",
                       lr_param.nomgrr, "	",
                       l_atdsrvnum_org using "<<<<<<<<<", "	",
                       l_atdsrvano_org using "<<", "	",
                       l_data_org, "	",
                       l_atdsrvnum_ret using "<<<<<<<<<", "	",
                       l_atdsrvano_ret using "<<", "	",
                       l_data_ret, "	",
                       lr_retorno.numsrv using "<<<<<<", "	",
                       lr_retorno.numret using "<<<<<<", "	",
                       lr_retorno.percresolub using "<<<<<<", "	",
                       "S","	"
               let l_tot_ret = l_tot_ret + 1

            else
               display "Resolubilidade", "	",
                       lr_param.srrcoddig using "<<<<<<<<<<", "	",
                       lr_param.pstcoddig using "<<<<<<<<<<", "	",
                       lr_param.nomgrr, "	",
                       l_atdsrvnum_org using "<<<<<<<<<", "	",
                       l_atdsrvano_org using "<<", "	",
                       l_data_org, "	",
                       l_atdsrvnum_ret using "<<<<<<<<<", "	",
                       l_atdsrvano_ret using "<<", "	",
                       l_data_ret, "	",
                       lr_retorno.numsrv using "<<<<<<", "	",
                       lr_retorno.numret using "<<<<<<", "	",
                       lr_retorno.percresolub using "<<<<<<", "	",
                       "Servico RET aberto apos a garantia","	"
            end if
         else
               display "Resolubilidade", "	",
                       lr_param.srrcoddig using "<<<<<<<<<<", "	",
                       lr_param.pstcoddig using "<<<<<<<<<<", "	",
                       lr_param.nomgrr, "	",
                       l_atdsrvnum_org using "<<<<<<<<<", "	",
                       l_atdsrvano_org using "<<", "	",
                       l_data_org, "	",
                       l_atdsrvnum_ret using "<<<<<<<<<", "	",
                       l_atdsrvano_ret using "<<", "	",
                       l_data_ret, "	",
                       lr_retorno.numsrv using "<<<<<<", "	",
                       lr_retorno.numret using "<<<<<<", "	",
                       lr_retorno.percresolub using "<<<<<<", "	",
                       "Servico RET nao acionado","	"
         end if
   
         close cctb00g12003
   
      else
               display "Resolubilidade", "	",
                       lr_param.srrcoddig using "<<<<<<<<<<", "	",
                       lr_param.pstcoddig using "<<<<<<<<<<", "	",
                       lr_param.nomgrr, "	",
                       l_atdsrvnum_org using "<<<<<<<<<", "	",
                       l_atdsrvano_org using "<<", "	",
                       l_data_org, "	",
                       l_atdsrvnum_ret using "<<<<<<<<<", "	",
                       l_atdsrvano_ret using "<<", "	",
                       l_data_ret, "	",
                       lr_retorno.numsrv using "<<<<<<", "	",
                       lr_retorno.numret using "<<<<<<", "	",
                       lr_retorno.percresolub using "<<<<<<", "	",
                       "N","	"
      end if

      let l_tot_srv = l_tot_srv + 1

   end foreach

   whenever error stop

   if sqlca.sqlcode <> 0 and sqlca.sqlcode <> notfound then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.msgerro = "Erro ao selecionar retornos (ctb00g12): ",
                                sqlca.sqlcode
   end if

   if lr_retorno.coderro <> 0 then
               display "Resolubilidade", "	",
                       lr_param.srrcoddig using "<<<<<<<<<<", "	",
                       lr_param.pstcoddig using "<<<<<<<<<<", "	",
                       lr_param.nomgrr, "	",
                       l_atdsrvnum_org using "<<<<<<<<<", "	",
                       l_atdsrvano_org using "<<", "	",
                       l_data_org, "	",
                       l_atdsrvnum_ret using "<<<<<<<<<", "	",
                       l_atdsrvano_ret using "<<", "	",
                       l_data_ret, "	",
                       lr_retorno.numsrv using "<<<<<<", "	",
                       lr_retorno.numret using "<<<<<<", "	",
                       lr_retorno.percresolub using "<<<<<<", "	",
                       lr_retorno.coderro using "<<<<<", "	",
                       lr_retorno.msgerro clipped,"	"
      return lr_retorno.*
   end if

   #=> CALCULA O PERCENTUAL DE RESOLUBILIDADE
   let l_tot_sem_ret = l_tot_srv - l_tot_ret

   if l_tot_srv = 0 then
      let lr_retorno.percresolub = 0
   else
      if l_tot_srv > 0 and l_tot_ret > 0 then
         let lr_retorno.percresolub = (l_tot_sem_ret / l_tot_srv) * 100
      else
         let lr_retorno.percresolub = 100
      end if
   end if

   #let lr_retorno.msgerro = l_tot_ret using "<<&",
   #                         "/",
   #                         l_tot_srv using "<<<&",
   #                         " = ",
   #                         ( l_tot_ret / l_tot_srv) * 1000 using "<<<&",
   #                         " em 1000"

   let lr_retorno.msgerro = l_tot_srv using "<<<&"," servicos entre ",
                            lr_param.dataini," e ", lr_param.datafim, ".",
                            l_tot_ret using "<<&"," tiveram retorno.",
                            l_tot_sem_ret using "<<&"," nao tiveram retorno. ",
                            "Resolubilidade de ", lr_retorno.percresolub 
                            using "<<&.&&", "%."

   let lr_retorno.numsrv = l_tot_srv
   let lr_retorno.numret = l_tot_ret

               display "Resolubilidade", "	",
                       lr_param.srrcoddig using "<<<<<<<<<<", "	",
                       lr_param.pstcoddig using "<<<<<<<<<<", "	",
                       lr_param.nomgrr, "	",
                       l_atdsrvnum_org using "<<<<<<<<<", "	",
                       l_atdsrvano_org using "<<", "	",
                       l_data_org, "	",
                       l_atdsrvnum_ret using "<<<<<<<<<", "	",
                       l_atdsrvano_ret using "<<", "	",
                       l_data_ret, "	",
                       lr_retorno.numsrv using "<<<<<<", "	",
                       lr_retorno.numret using "<<<<<<", "	",
                       lr_retorno.percresolub using "<<<<<<", "	",
                       "S","	"

   return lr_retorno.*

end function
