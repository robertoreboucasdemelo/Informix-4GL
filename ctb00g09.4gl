#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Teleatendimento / Porto Socorro                             #
# Modulo         : ctb00g09                                                    #
#                  Qualificar a disponibilidade do veiculo.                    #
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 188603                                                      #
#..............................................................................#
# Desenvolvimento: META, Marcos M.P.                                           #
# Data           : 07/04/2005                                                  #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data       Analista Resp/Autor Fabrica  PSI/Alteracao                        #
# ---------- ---------------------------- -------------------------------------#
#------------------------------------------------------------------------------#
database porto

define m_flgprep         smallint,
       m_tabela          char(80),
       teste             integer,
       tested            like datmmdtmvt.caddat,
       testeh            like datmmdtmvt.cadhor


#=> PREPARA COMANDOS SQL DO MODULO
#-------------------------------------------------------------------------------
function ctb00g09_prep()
#-------------------------------------------------------------------------------
   define l_prep         char(1500)

   if m_flgprep then
      return true
   end if

   let m_tabela = "datkgeral"
   let l_prep = "select grlinf",
                "  from datkgeral",
                " where grlchv = ?"
   whenever error continue
   prepare pctb00g090101 from l_prep
   declare cctb00g090101 cursor for pctb00g090101
   whenever error stop
   if sqlca.sqlcode <> 0 then
      return false
   end if

   let m_tabela = "datmmdtmvt"
   let l_prep = "select a.mdtbotprgseq, a.mdtmvtseq, a.caddat, a.cadhor",
                "  from datmmdtmvt     a",
                " where mdtmvtseq = ",
                        "(select max(b.mdtmvtseq)",
                        "  from datmmdtmvt     b",
                        " where b.mdtcod       = ?",
                        "   and b.caddat      >= ?",
                        "   and (  ( b.caddat  = ? and",
                        "            b.cadhor <= ? )",
                        "       or ( b.caddat  < ? )  )",
                        "   and b.mdtmvtstt    = 2", #=> Processado OK
                        "   and b.mdtmvttipcod = 2", #=> Botao
                        "   and b.mdtbotprgseq in (1,2,3,8,9,10,11,14,15,18))"
   whenever error continue
   prepare pctb00g090202 from l_prep
   declare cctb00g090202 cursor for pctb00g090202
   whenever error stop
   if sqlca.sqlcode <> 0 then
      return false
   end if

   let m_flgprep = true

display "Disponibilidade", "	",
        "Codigo do MDT", "	",
        "Codigo do prestador", "	",
        "Nome do prestador", "	",
        "Data inicial", "	",
        "Data final", "	",
        "M=Manha T=Tarde", "	",
        "Numero de dias no periodo", "	",
        "Numero de dias indisponiveis no periodo", "	",
        "Percentual de disponibilidade minima", "	",
        "Codigo erro", "	",
        "Mensagem erro", "	",
        "Qualificado", "	"
   return true

end function

#=> FUNCAO PRINCIPAL DO MODULO - QUALIFICA DISPONIBILIDADE DO VEICULO
#-------------------------------------------------------------------------------
function ctb00g09_qualifdisp(lr_param)
#-------------------------------------------------------------------------------
   define lr_param       record
          mdtcod         like datkveiculo.mdtcod,     #=> Codigo do MDT
          pstcoddig      like dpaksocor.pstcoddig,    #=> Codigo do prestador
          nomgrr         like dpaksocor.nomgrr,       #=> Nome do prestador
          dataini        date,                        #=> Data inicial
          datafim        date,                        #=> Data final
          pertip         char(01)                     #=> M=Manha T=Tarde
   end record

   define lr_retorno     record
          coderro        integer,   #=> Codigo erro lr_retorno / 0=Ok <>0=Error
          msgerro        char(50),  #=> Mensagem erro lr_retorno
          percindisp     integer    ##dec(8,2)  #=> Percentual de disponibilidade minima
   end record

   define lr_aux         record
          dataint        integer,   #=> Dia  para a pesquisa
          datapesq       date,      #=> Data para a pesquisa
          dtinipesq      date,      #=> Data para corte inicial da pesquisa
          totdias        integer,   #=> Numero de dias no periodo
          diaindisp      char(01),  #=> Flag de dia indisponivel
          totindisp      integer,   #=> Numero de dias indisponiveis no periodo
          percindisp     integer,   ##dec(8,2),  #=> Percentual de disponibilidade minima
          horaini        integer,   #=> Primeira hora cheia
          horafim        integer,   #=> Ultima hora cheia
          horint         integer,   #=> Hora inteira para o loop
          horachar       char(08),  #=> Hora alfa
          horapesq       datetime hour to second, #=> Hora da pesquisa
          mdtbotprgseq   like datmmdtmvt.mdtbotprgseq,  #=> Estado do botao
          grlchv         like datkgeral.grlchv,
          grlchv2        like datkgeral.grlchv,
          hrinifim       char(10),
          percdef        dec(6,2),
          maxdiaind      smallint   #=> Quantidade maxima de dias indisponiveis
   end record

   define msgdebug char(500)

   initialize lr_aux.* to null

   let lr_retorno.coderro     = 0
   let lr_retorno.msgerro     = "Disponibilidade nao atendida"
   #let lr_retorno.qualificado = "N"
   let lr_retorno.percindisp = 0

   #=> CONSISTE PARAMETROS RECEBIDOS
   if lr_param.mdtcod is null then
      let lr_retorno.coderro = 1
      let lr_retorno.msgerro = "Parametro 'Codigo MDT' nao recebido (ctb00g09)!"
      display "Disponibilidade", "	",
              lr_param.mdtcod, "	",
              lr_param.pstcoddig, "	",
              lr_param.nomgrr, "	",
              lr_param.dataini, "	",
              lr_param.datafim, "	",
              lr_param.pertip, "	",
              lr_aux.totdias, "	",
              lr_aux.totindisp, "	",
              lr_aux.percindisp, "	",
              lr_retorno.coderro, "	",
              lr_retorno.msgerro, "	",
              lr_retorno.percindisp, "	"
              #lr_retorno.qualificado, "	"

      return lr_retorno.*
   end if

   if lr_param.dataini is null or
      lr_param.datafim is null then
      let lr_retorno.coderro = 1
      let lr_retorno.msgerro = "Periodo para pesquisa nao recebido (ctb00g09)!"
      display "Disponibilidade", "	",
              lr_param.mdtcod, "	",
              lr_param.pstcoddig, "	",
              lr_param.nomgrr, "	",
              lr_param.dataini, "	",
              lr_param.datafim, "	",
              lr_param.pertip, "	",
              lr_aux.totdias, "	",
              lr_aux.totindisp, "	",
              lr_aux.percindisp, "	",
              lr_retorno.coderro, "	",
              lr_retorno.msgerro, "	",
              lr_retorno.percindisp, "	"
              #lr_retorno.qualificado, "	"

      return lr_retorno.*
   end if

   #=> PREPARA COMANDOS SQL DO MODULO
   if not ctb00g09_prep() then
      let lr_retorno.coderro = sqlca.sqlcode
      let lr_retorno.msgerro = "Erro ao preparar ", m_tabela clipped,
                               "(ctb00g09):", sqlca.sqlerrd[2]
      display "Disponibilidade", "	",
              lr_param.mdtcod, "	",
              lr_param.pstcoddig, "	",
              lr_param.nomgrr, "	",
              lr_param.dataini, "	",
              lr_param.datafim, "	",
              lr_param.pertip, "	",
              lr_aux.totdias, "	",
              lr_aux.totindisp, "	",
              lr_aux.percindisp, "	",
              lr_retorno.coderro, "	",
              lr_retorno.msgerro, "	",
              lr_retorno.percindisp, "	"
              #lr_retorno.qualificado, "	"

      return lr_retorno.*
   end if

   #=> VERIFICA PERIODO MANHA OU TARDE
   if lr_param.pertip = "M" or
      lr_param.pertip = "T"
      then
      if lr_param.pertip = "M" then
         let lr_aux.horaini  = 06
         let lr_aux.horafim  = 10
         let lr_aux.grlchv   = "PSOPERCDSPMANHA"
         let lr_aux.grlchv2  = "PSOINIFIMDSPMNH"
         let lr_aux.percdef  = 0.85
      else
         let lr_aux.horaini = 17
         let lr_aux.horafim = 20
         let lr_aux.grlchv  = "PSOPERCDSPTARDE"
         let lr_aux.grlchv2 = "PSOINIFIMDSPTRD"
         let lr_aux.percdef = 0.75
      end if

      #=>   OBTEM PERCENTUAL DE DISPONIBILIDADE - DATKGERAL
      whenever error continue
      open  cctb00g090101 using lr_aux.grlchv
      fetch cctb00g090101  into lr_aux.percindisp
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            let lr_aux.percindisp = lr_aux.percdef
         else
            let lr_retorno.coderro = sqlca.sqlcode
            let lr_retorno.msgerro = "Erro ao selecionar datkgeral (ctb00g09):",
                                     sqlca.sqlerrd[2]
            display "Disponibilidade", "	",
                    lr_param.mdtcod, "	",
                    lr_param.pstcoddig, "	",
                    lr_param.nomgrr, "	",
                    lr_param.dataini, "	",
                    lr_param.datafim, "	",
                    lr_param.pertip, "	",
                    lr_aux.totdias, "	",
                    lr_aux.totindisp, "	",
                    lr_aux.percindisp, "	",
                    lr_retorno.coderro, "	",
                    lr_retorno.msgerro, "	",
                    lr_retorno.percindisp, "	"
                    #lr_retorno.qualificado, "	"

            return lr_retorno.*
         end if
      else
         if lr_aux.percindisp is null then
            let lr_aux.percindisp = lr_aux.percdef
         else
            let lr_aux.percindisp = (lr_aux.percindisp / 100)
         end if
      end if

      close cctb00g090101

      #=>   OBTEM HORA INICIO E FIM PARA CALCULO DE DISPONIBILIDADE - DATKGERAL
      whenever error continue
      open  cctb00g090101 using lr_aux.grlchv2
      fetch cctb00g090101  into lr_aux.hrinifim
      whenever error stop

      ## se nao conseguiu ler parametro busca pelo parametro antigo
      if sqlca.sqlcode <> 0 then
         display "Nao foi possivel ler parametro ", lr_aux.grlchv2, " sistema considerou horario padrao."

      else
         if lr_aux.hrinifim is not null then
            ## se valor parametro esta cadastrado e é diferente de nulo sistema substitui valor default
            let lr_aux.horaini  = lr_aux.hrinifim[1,2]
            let lr_aux.horafim  = lr_aux.hrinifim[4,5]
         end if
      end if

      close cctb00g090101

   else
      let lr_aux.horaini    = 00
      let lr_aux.horafim    = 23
      let lr_aux.percindisp = 1.00
   end if

   #=> CALCULA O NUMERO DE DIAS DO PERIODO
   let lr_aux.totdias = (lr_param.datafim - lr_param.dataini) + 1
   let lr_aux.maxdiaind = (lr_aux.totdias - (lr_aux.totdias * lr_aux.percindisp) + 1)

   #=> CALCULA O NUMERO DE DIAS INDISPONIVEL
   let lr_aux.totindisp = 0

   #=> PESQUISA DIA A DIA
   for lr_aux.dataint = 0 to (lr_aux.totdias - 1)

      #=> FLAG DE DIA INDISPONIVEL
      let lr_aux.diaindisp = "N"

      #=> INICIA A PESQUISA COM A DATA INICIAL
      let lr_aux.datapesq = lr_param.dataini + lr_aux.dataint units day
      let lr_aux.dtinipesq = lr_aux.datapesq - 1 units day

      let msgdebug = "Disp Analitica", "	", lr_param.pertip, "	",
                     "MDT", lr_param.mdtcod, "	", lr_aux.datapesq

      for lr_aux.horint = lr_aux.horaini to lr_aux.horafim

         #=> MONTA A HORA PARA A PESQUISA
         let lr_aux.horachar = lr_aux.horint using "&&", ":00:00"
         let lr_aux.horapesq = lr_aux.horachar
         let lr_aux.horapesq = lr_aux.horapesq - 1 units second

         #=> OBTEM O ESTADO DO VEICULO EM CADA HORA CHEIA - DATMMDTMVT
         whenever error continue
         open  cctb00g090202 using lr_param.mdtcod,
                                   lr_aux.dtinipesq,
                                   lr_aux.datapesq,
                                   lr_aux.horapesq,
                                   lr_aux.datapesq
         fetch cctb00g090202  into lr_aux.mdtbotprgseq,
                                   teste,
                                   tested,
                                   testeh
         whenever error stop
         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode <> notfound then
               let lr_retorno.coderro = sqlca.sqlcode
               let lr_retorno.msgerro = "Erro ao selecionar datmmdtmvt ",
                                        "(ctb00g09): ", sqlca.sqlerrd[2]
            else
               let lr_retorno.coderro = 100
               let lr_retorno.msgerro = "Sem movimento GPS"
               let lr_aux.diaindisp = "S"
               let msgdebug = msgdebug clipped, "	", lr_aux.horint using "&&", "h SEM"
            end if
            exit for
         end if

         #=> VERIFICA "10-QRX" OU "11-QTP"
         if lr_aux.mdtbotprgseq = 10 or
            lr_aux.mdtbotprgseq = 11 then
            let lr_aux.diaindisp = "S"
            let msgdebug = msgdebug clipped, "	", lr_aux.horint using "&&", "h NOK", lr_aux.mdtbotprgseq, teste, " ",tested," ", testeh
            exit for
         else
            let msgdebug = msgdebug clipped, "	", lr_aux.horint using "&&", "h OK", lr_aux.mdtbotprgseq, teste," ", tested," ", testeh
         end if

      end for #=> HORA

      # usar somente para debug, pois mostra todos os minutos em cada servico que passar
      # display msgdebug clipped

      #=>   TRATAMENTO DE ERRO
      if lr_retorno.coderro <> 0 and lr_retorno.coderro <> notfound then
         exit for
      end if

      #=>   VERIFICA HOUVE ALGUMA INDISPONIBILIDADE NO DIA
      if lr_aux.diaindisp = "S" then
         let lr_aux.totindisp = ( lr_aux.totindisp + 1 )
      end if

   end for #=> DIA

   #=> TRATAMENTO DE ERRO
   if lr_retorno.coderro <> 0 and lr_retorno.coderro <> 100 then
      display "Disponibilidade", "	",
              lr_param.mdtcod, "	",
              lr_param.pstcoddig, "	",
              lr_param.nomgrr, "	",
              lr_param.dataini, "	",
              lr_param.datafim, "	",
              lr_param.pertip, "	",
              lr_aux.totdias, "	",
              lr_aux.totindisp, "	",
              lr_aux.percindisp, "	",
              lr_retorno.coderro, "	",
              lr_retorno.msgerro, "	",
              lr_retorno.percindisp, "	"
              #lr_retorno.qualificado, "	"

      return lr_retorno.*
   end if

   #=> CALCULA O PERCENTUAL DE DISPONIBILIDADE
   let lr_retorno.msgerro = ( (lr_aux.totdias - lr_aux.totindisp) / lr_aux.totdias * 100) using "<<&", "%"
   #if ( (lr_aux.totdias - lr_aux.totindisp) / lr_aux.totdias ) > (lr_aux.percindisp) then

   if lr_retorno.coderro = 100 then
      let lr_retorno.coderro = 0
   end if

   #if lr_aux.totindisp > lr_aux.maxdiaind then
   #   #let lr_retorno.qualificado = "N"
   #   let lr_retorno.percindisp = 0
   #else
   #   #let lr_retorno.qualificado = "S"

   let lr_retorno.percindisp = ((lr_aux.totdias - lr_aux.totindisp) / lr_aux.totdias * 100)
   #end if

   display "Disponibilidade", "	",
           lr_param.mdtcod, "	",
           lr_param.pstcoddig, "	",
           lr_param.nomgrr, "	",
           lr_param.dataini, "	",
           lr_param.datafim, "	",
           lr_param.pertip, "	",
           lr_aux.totdias, "	",
           lr_aux.totindisp, "	",
           lr_aux.percindisp, "	",
           lr_retorno.coderro, "	",
           lr_retorno.msgerro, "	",
           lr_retorno.percindisp, "	"
           #lr_retorno.qualificado, "	"

   return lr_retorno.*

end function


