############################################################################
# Nome do Modulo: CTN06C04                                           Pedro #
#                                                                          #
# Consulta Prestador por Servicos atraves do Cep                  Out/1994 #
#--------------------------------------------------------------------------#
# 14/09/2000  PSI 11575-4  Raji      Incluido para o campo qualidade o aces#
#                                    so na iddkdominio.                    #
#--------------------------------------------------------------------------#
#                       * * * A L T E R A C A O * * *                      #
# ........................................................................ #
# Data        Autor Fabrica   OSF/PSI     Alteracao                        #
# ---------- -------------  ------------- ---------------------------------#
# 27/01/2004 Sonia Sasaki   31631/177903  Inclusao F6 e execucao da funcao #
#                                         cta11m00 (Motivos de recusa).    #
# 17/11/2006 Ligia Mattge   PSI 205206    ciaempcod                        #
#                                                                          #
# 28/01/2009 Adriano Santos PSI 235849    Considerar serviço SINISTRO RE   #
#                                         na pesquisa de prestador         #
# 09/03/2010 Adriano Santos PSI 242853    Substituir relacionamento GRP NTZ#
#                                         com PST por NTZ                  #
#--------------------------------------------------------------------------#

#---------------------------------------------------------------
# Modulo de consulta na tabela dpaksocor
# Gerado por: ct24h em: 27/10/94
#---------------------------------------------------------------

#database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctn06c04_prep smallint,
         m_atdsrvorg  like datmservico.atdsrvorg,
         m_socntzcod  like datksocntz.socntzcod, # PSI 242853
         m_socntzdes  like datksocntz.socntzdes

#define i              smallint
define gm_seqpesquisa smallint
define ws_pstcoddig   like dpaksocor.pstcoddig
define confirma       char(1)

define w_ctn06c04 record
       pstsrvtip  char (03),
       pstsrvdes  like   dpckserv.pstsrvdes,
       ciaempcod  like   gabkemp.empcod,
       empnom     like   gabkemp.empnom
end record

#-------------------------#
function ctn06c04_prepare()
#-------------------------#

  define l_sql char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_sql  =  null

  let l_sql = " select atdsrvorg ",
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

   prepare p_ctn06c04_001 from l_sql
   declare c_ctn06c04_001 cursor for p_ctn06c04_001

  let m_ctn06c04_prep = true

end function

#---------------------------------------------------------------
function ctn06c04(k_ctn06c04)
#---------------------------------------------------------------

   define k_ctn06c04 record
       endcep        like glaklgd.lgdcep
   end record



   if m_ctn06c04_prep is null or
      m_ctn06c04_prep <> true then
      call ctn06c04_prepare()
   end if

   #let m_socntzgrpcod = null
   #let m_socntzgrpdes = null
   let m_socntzcod = null # PSI 242853
   let m_socntzdes = null
   let m_atdsrvorg = null

   open window ctn06c04 at 04,02 with form "ctn06c04"

   let gm_seqpesquisa = 0
   let int_flag       = false

   menu "PRESTADOR_SERVICO"

   command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
           message ""
           initialize w_ctn06c04.* to null

           if k_ctn06c04.endcep    is  null then
              error "Nenhum logradouro foi selecionado!"
              next option "Encerra"
           else
              clear form
              call pesquisa_ctn06c04(k_ctn06c04.*)
                   returning ws_pstcoddig
              let  gm_seqpesquisa = 0
              #if  i > 1  then
                  #next option "Encerra"
                  if ws_pstcoddig is not null and
                     ws_pstcoddig <> 0 then
                      exit menu
                  else
                      next option "Proxima_regiao"
                  end if
              #else
              #    next option "Proxima_regiao"
              #end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa proxima regiao do cep"
           message ""
           if k_ctn06c04.endcep is null     then
              error "Nenhum Cep Selecionado!"
              next option "Encerra"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn06c04(k_ctn06c04.*)
                   returning ws_pstcoddig
              #if  i  >  1   then
              #    #next option "Encerra"
                  if ws_pstcoddig is not null and
                     ws_pstcoddig <> 0 then
                      exit menu
                  else
                      next option "Proxima_regiao"
                  end if
              #else
              #    next option "Proxima_regiao"
              #end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   let int_flag = false
   close window ctn06c04
   return ws_pstcoddig

end function  # ctn06c04

#-------------------------------------------------------------------
function pesquisa_ctn06c04(k_ctn06c04)
#-------------------------------------------------------------------

   define k_ctn06c04 record
          endcep     like glaklgd.lgdcep
   end    record

   define a_ctn06c04   array[200] of record
          nomgrr       like dpaksocor.nomgrr   ,
          pstcoddig    like dpaksocor.pstcoddig,
          situacao     char (10)             ,
          endlgd       like dpaksocor.endlgd   ,
          endbrr       like dpaksocor.endbrr   ,
          endcid       like dpaksocor.endcid   ,
          endufd       like dpaksocor.endufd   ,
          endcep       like dpaksocor.endcep   ,
          endcepcmp    like dpaksocor.endcepcmp,
          dddcod       like dpaksocor.dddcod   ,
          teltxt       like dpaksocor.teltxt   ,
          horsegsexinc like dpaksocor.horsegsexinc,
          horsegsexfnl like dpaksocor.horsegsexfnl,
          horsabinc    like dpaksocor.horsabinc,
          horsabfnl    like dpaksocor.horsabfnl,
          hordominc    like dpaksocor.hordominc,
          hordomfnl    like dpaksocor.hordomfnl,
          pstobs       like dpaksocor.pstobs   ,
          qualidade    char (12)                ,
          tabela       char (06)
   end    record

   define ws           record
      prssitcod        like dpaksocor.prssitcod,
      vlrtabflg        like dpaksocor.vlrtabflg,
      qldgracod        like dpaksocor.qldgracod
   end record
   define lr_ctn25c00  record
          resultado    smallint,  # 1 Obteve a descricao 2 Nao achou a descricao 3 Erro de banco
          mensagem     char(80),
          asitipdes    like datkasitip.asitipdes
   end record
   define l_srvrcumtvcod    like datmsrvacp.srvrcumtvcod
          ,l_resultado     smallint
          ,l_mensagem      char(60)

   define  w_pf1   integer
   define l_sql char(1000)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_srvrcumtvcod  =  null
	let	l_resultado  =  null
	let	l_mensagem  =  null
	let	w_pf1  =  null
	let	l_sql  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	for	w_pf1  =  1  to  200
		initialize  a_ctn06c04[w_pf1].*  to  null
	end	for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  ws.*,
	            lr_ctn25c00.*  to  null

   let l_sql = null
   let l_resultado  = null
   let l_mensagem    = null
   let ws_pstcoddig = null

  initialize a_ctn06c04 to null

  if g_documento.atdsrvnum is not null then
     call cts10g06_dados_servicos(10, g_documento.atdsrvnum,
                                      g_documento.atdsrvano)
          returning l_resultado, l_mensagem, w_ctn06c04.ciaempcod

     call cty14g00_empresa(1, w_ctn06c04.ciaempcod)
          returning l_resultado, l_mensagem,  w_ctn06c04.empnom

     display by name w_ctn06c04.ciaempcod attribute (reverse)
     display by name w_ctn06c04.empnom attribute (reverse)

  end if
  open c_ctn06c04_001 using g_documento.atdsrvnum,
                          g_documento.atdsrvano

  whenever error continue
  fetch c_ctn06c04_001 into m_atdsrvorg
  whenever error stop
  if m_atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009
      let m_atdsrvorg = null
  end if
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let m_atdsrvorg = null
     else
        error "Erro SELECT c_ctn06c04_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "CTN06C04/ctn06c04() ", g_documento.atdsrvnum, "/",
                                      g_documento.atdsrvano sleep 3
        return ws_pstcoddig
     end if
  end if

  close c_ctn06c04_001
  if m_atdsrvorg = 9 or m_atdsrvorg = 13 then
      whenever error continue
        select socntzcod
          into w_ctn06c04.pstsrvtip
          from datmsrvre
         where atdsrvnum = g_documento.atdsrvnum
           and atdsrvano = g_documento.atdsrvano
      whenever error stop
      if  w_ctn06c04.pstsrvtip is not null and w_ctn06c04.pstsrvtip <> " " then
          call ctx24g01_descricao(w_ctn06c04.pstsrvtip)
               returning l_resultado, l_mensagem, w_ctn06c04.pstsrvdes
          display w_ctn06c04.pstsrvtip to pstsrvtip
          display w_ctn06c04.pstsrvdes to pstsrvdes
      end if
  else
      if m_atdsrvorg = 18 then
          whenever error continue
             select asitipcod into w_ctn06c04.pstsrvtip
               from datmservico
              where atdsrvnum = g_documento.atdsrvnum
                and atdsrvano = g_documento.atdsrvano
          whenever error stop
          if  sqlca.sqlcode = 0 then
              call ctn25c00_descricao(w_ctn06c04.pstsrvtip)
                  returning lr_ctn25c00.*
              let w_ctn06c04.pstsrvdes = lr_ctn25c00.asitipdes
          else
              let w_ctn06c04.pstsrvtip = null
              let w_ctn06c04.pstsrvdes = null
          end if
          display by name w_ctn06c04.pstsrvtip
          display by name w_ctn06c04.pstsrvdes
      end if
  end if

   input by name w_ctn06c04.pstsrvtip, w_ctn06c04.ciaempcod without defaults

         before field pstsrvtip
                display by name w_ctn06c04.pstsrvtip attribute (reverse)
                display by name w_ctn06c04.ciaempcod attribute (reverse)

         after  field pstsrvtip
                display by name w_ctn06c04.pstsrvtip

                if m_atdsrvorg is null then
                   if cts08g01("C",
                               "S",
                               "",
                               "DESEJA CONSULTAR SOMENTE",
                               "PRESTADORES DE RE ?","") = "S"  then
                      let m_atdsrvorg = 9
                   else
                      let m_atdsrvorg = 0
                   end if
                end if

                if m_atdsrvorg = 9 then

                   if w_ctn06c04.pstsrvtip is null then
                      #call ctx24g00_popup_grupo() #psi195138
                      #     returning l_resultado, w_ctn06c04.pstsrvtip
                      call ctx24g01_popup_natureza() # PSI 242853
                           returning l_resultado, w_ctn06c04.pstsrvtip
                      if w_ctn06c04.pstsrvtip is null or
                         w_ctn06c04.pstsrvtip = " " then
                         next field pstsrvtip
                      end if
                   end if

                   call ctx24g01_descricao(w_ctn06c04.pstsrvtip)
                        returning l_resultado, l_mensagem, w_ctn06c04.pstsrvdes

                   if l_resultado <> 1 then
                      error l_mensagem
                      next field pstsrvtip
                   end if
               else

                   select pstsrvdes
                     into w_ctn06c04.pstsrvdes
                     from dpckserv
                    where pstsrvtip  =  w_ctn06c04.pstsrvtip

                   if sqlca.sqlcode = notfound then
                      error "Tipo de servico nao cadastrado!"

                      call ctn06c03() returning w_ctn06c04.pstsrvtip,
                                                w_ctn06c04.pstsrvdes

                      if w_ctn06c04.pstsrvtip is null or
                         w_ctn06c04.pstsrvtip =  " "  then
                         error "Tipo de servico e' obrigatorio!"
                         next field pstsrvtip
                      end if
                   end if

                end if

                display w_ctn06c04.pstsrvtip to pstsrvtip
                display w_ctn06c04.pstsrvdes to pstsrvdes

         before field ciaempcod
                display by name w_ctn06c04.ciaempcod attribute (reverse)

         after  field ciaempcod

                if w_ctn06c04.ciaempcod is null then
                   call cty14g00_popup_empresa()
                        returning l_resultado, w_ctn06c04.ciaempcod,
                                  w_ctn06c04.empnom
                else

                   #if w_ctn06c04.ciaempcod <> 1 and
                   #   w_ctn06c04.ciaempcod <> 27 and
                   #   w_ctn06c04.ciaempcod <> 35 and
                   #   w_ctn06c04.ciaempcod <> 40 then
                   #   error "Informe a empresa: 1-Porto, 35-Azul ou 40-PortoSeg"
                   #   next field ciaempcod
                   #end if

                   call cty14g00_empresa(1, w_ctn06c04.ciaempcod)
                        returning l_resultado, l_mensagem,  w_ctn06c04.empnom

                   if l_resultado <> 1 then
                      error l_mensagem
                      next field ciaempcod
                   end if
                end if

                display by name w_ctn06c04.empnom attribute (reverse)
   end input

   let int_flag = false

   message " Aguarde, pesquisando... ", k_ctn06c04.endcep   attribute(reverse)

   let l_sql = ' select dpaksocor.nomgrr, ',
               '        dpaksocor.pstcoddig, ',
               '        dpaksocor.prssitcod, ',
               '        dpaksocor.endlgd, ',
               '        dpaksocor.endbrr, ',
               '        dpaksocor.endcid, ',
               '        dpaksocor.endufd, ',
               '        dpaksocor.endcep, ',
               '        dpaksocor.endcepcmp, ',
               '        dpaksocor.dddcod, ',
               '        dpaksocor.teltxt, ',
               '        dpaksocor.horsegsexinc, ',
               '        dpaksocor.horsegsexfnl, ',
               '        dpaksocor.horsabinc, ',
               '        dpaksocor.horsabfnl, ',
               '        dpaksocor.hordominc, ',
               '        dpaksocor.hordomfnl, ',
               '        dpaksocor.pstobs   , ',
               '        dpaksocor.vlrtabflg, ',
               '        dpaksocor.qldgracod '

   if m_atdsrvorg = 9 then
      let l_sql = l_sql clipped,
               '   from dpaksocor, dparpstntz ', # PSI 242853
               '  where dpaksocor.endcep    = ?   and ',
               '        dpaksocor.endlgd   is not null             and ',
               '        dpaksocor.pstcoddig = dpaksocor.pstcoddig  and ',
               '        dparpstntz.pstcoddig = dpaksocor.pstcoddig    and ',
               '        dparpstntz.socntzcod = ? ',
               '  order by endcep desc, qldgracod '

   else
      let l_sql = l_sql clipped,
               '   from dpaksocor, dpatserv ',
               '  where dpaksocor.endcep    = ?   and ',
               '        dpaksocor.endlgd   is not null             and ',
               '        dpaksocor.pstcoddig = dpaksocor.pstcoddig  and ',
               '        dpatserv.pstcoddig = dpaksocor.pstcoddig    and ',
               '        dpatserv.pstsrvtip = ? ',
               '  order by endcep desc, qldgracod '
   end if

   prepare pctn06c04002 from l_sql
   declare cctn06c04002 cursor for pctn06c04002
   open cctn06c04002 using k_ctn06c04.endcep, w_ctn06c04.pstsrvtip

   while not int_flag

      let i = 1

      foreach cctn06c04002 into a_ctn06c04[i].nomgrr   ,
                              a_ctn06c04[i].pstcoddig,
                              ws.prssitcod           ,
                              a_ctn06c04[i].endlgd   ,
                              a_ctn06c04[i].endbrr   ,
                              a_ctn06c04[i].endcid   ,
                              a_ctn06c04[i].endufd   ,
                              a_ctn06c04[i].endcep   ,
                              a_ctn06c04[i].endcepcmp,
                              a_ctn06c04[i].dddcod   ,
                              a_ctn06c04[i].teltxt   ,
                              a_ctn06c04[i].horsegsexinc,
                              a_ctn06c04[i].horsegsexfnl,
                              a_ctn06c04[i].horsabinc,
                              a_ctn06c04[i].horsabfnl,
                              a_ctn06c04[i].hordominc,
                              a_ctn06c04[i].hordomfnl,
                              a_ctn06c04[i].pstobs   ,
                              ws.vlrtabflg           ,
                              ws.qldgracod

         if w_ctn06c04.ciaempcod is not null then

            call ctd03g00_valida_emppst(w_ctn06c04.ciaempcod,
                                        a_ctn06c04[i].pstcoddig)
                 returning l_resultado, l_mensagem

            if l_resultado <> 1 then
               continue foreach
            end if

         end if

         if ws.prssitcod = "A"  then
            let a_ctn06c04[i].situacao = "ATIVO"
         else
            continue foreach
         end if

         if ws.vlrtabflg = "S"   then
            let a_ctn06c04[i].tabela = "TABELA"
         end if

         select cpodes
           into a_ctn06c04[i].qualidade
           from iddkdominio
          where iddkdominio.cponom = "qldgracod"
            and iddkdominio.cpocod = ws.qldgracod

         let i = i + 1

         if i > 200 then
            error "Limite de consulta excedido (200). AVISE A INFORMATICA!"
            exit foreach
         end if

      end foreach

      message " (F17)Abandona, (F6)Recusa, (F8)Seleciona, (F9)Servicos do prestador"

      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn06c04 to s_ctn06c04.*
             on key (interrupt,control-m)
                exit display

             on key (F6)
                let i = arr_curr()

                  let m_atdsrvorg = null

                  open c_ctn06c04_001 using g_documento.atdsrvnum,
                                          g_documento.atdsrvano

                  whenever error continue
                  fetch c_ctn06c04_001 into m_atdsrvorg
                  whenever error stop

                if sqlca.sqlcode = 0 then
                   call cta11m00 ( m_atdsrvorg
                                  ,g_documento.atdsrvnum
                                  ,g_documento.atdsrvano
                                  ,a_ctn06c04[i].pstcoddig
                                  ,"S" )
                        returning l_srvrcumtvcod
                else
                   if sqlca.sqlcode < 0 then
                      error "Erro ", sqlca.sqlcode using "<<<<<&",
                            " na selecao da tabela datmservico."
                   end if
                end if

                close c_ctn06c04_001

             on key (F8)

                let i = arr_curr()
                let ws_pstcoddig = a_ctn06c04[i].pstcoddig

                call cts08g01("A","S","PRESTADOR SELECIONADO",
                              a_ctn06c04[i].nomgrr,"ESTA CORRETO ?","")
                returning confirma

                if confirma = "S" then
                   let int_flag =  true
#                  error "Prestador selecionado !!"
                   exit display
                end if

             on key (F9)
                let i = arr_curr()
                if m_atdsrvorg = 9 then
                   #call ctn06c10(a_ctn06c04[i].pstcoddig)
                   #     returning m_socntzgrpcod, m_socntzgrpdes
                   call ctn06c11(a_ctn06c04[i].pstcoddig)
                        returning m_socntzcod, m_socntzdes # PSI 242853
                else
                   call ctn06c08(a_ctn06c04[i].pstcoddig)
                end if

          end display
      else
          error "Este servico nao foi localizado neste cep - Tente Proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false
   return ws_pstcoddig

end function  #  ctn06c04

#-------------------------------------------------------------------
function proxreg_ctn06c04(k_ctn06c04)
#-------------------------------------------------------------------

   define k_ctn06c04 record
          endcep     like  glaklgd.lgdcep
   end    record

   define a_ctn06c04   array[200] of record
          nomgrr       like dpaksocor.nomgrr      ,
          pstcoddig    like dpaksocor.pstcoddig   ,
          situacao     char (10)                  ,
          endlgd       like dpaksocor.endlgd      ,
          endbrr       like dpaksocor.endbrr      ,
          endcid       like dpaksocor.endcid      ,
          endufd       like dpaksocor.endufd      ,
          endcep       like dpaksocor.endcep      ,
          endcepcmp    like dpaksocor.endcepcmp   ,
          dddcod       like dpaksocor.dddcod      ,
          teltxt       like dpaksocor.teltxt      ,
          horsegsexinc like dpaksocor.horsegsexinc,
          horsegsexfnl like dpaksocor.horsegsexfnl,
          horsabinc    like dpaksocor.horsabinc   ,
          horsabfnl    like dpaksocor.horsabfnl   ,
          hordominc    like dpaksocor.horsabinc   ,
          hordomfnl    like dpaksocor.hordomfnl   ,
          pstobs       like dpaksocor.pstobs      ,
          qualidade    char(12)                   ,
          tabela       char(06)
   end    record

   define ws           record
      prssitcod        like dpaksocor.prssitcod,
      vlrtabflg        like dpaksocor.vlrtabflg,
      qldgracod        like dpaksocor.qldgracod
   end record

   define aux_cep      char(5)
   define l_srvrcumtvcod    like datmsrvacp.srvrcumtvcod
   define l_sql char(1000)
   define  w_pf1   integer
          ,l_resultado     smallint
          ,l_mensagem      char(60)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	aux_cep  =  null
	let	l_srvrcumtvcod  =  null
	let	l_sql  =  null
	let	w_pf1  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	for	w_pf1  =  1  to  200
		initialize  a_ctn06c04[w_pf1].*  to  null
	end	for

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  ws.*  to  null

   let l_sql = null
   let ws_pstcoddig = null

        let     aux_cep  =  null

        for     w_pf1  =  1  to  200
                initialize  a_ctn06c04[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

   let  aux_cep = k_ctn06c04.endcep

   if   gm_seqpesquisa   =   1  then
        if aux_cep[4,5]     =   "00"  then
           let  gm_seqpesquisa   =   2
        end if
   end if

   case gm_seqpesquisa
     when  1
       let  aux_cep[5,5] = "*"
     when  2
       let  aux_cep[4,5] = "* "
     when  3
       let  aux_cep[3,5] = "*  "
     when  4
       let  aux_cep[2,5] = "*   "
     otherwise
       error "Nao ha' nenhum prestador com este servico localizado nesta regiao!"
       message " "
       return ws_pstcoddig
   end case

   message " Aguarde, pesquisando... ", aux_cep    attribute(reverse)

   let l_sql = ' select dpaksocor.nomgrr, ',
               '        dpaksocor.pstcoddig, ',
               '        dpaksocor.prssitcod, ',
               '        dpaksocor.endlgd, ',
               '        dpaksocor.endbrr, ',
               '        dpaksocor.endcid, ',
               '        dpaksocor.endufd, ',
               '        dpaksocor.endcep, ',
               '        dpaksocor.endcepcmp, ',
               '        dpaksocor.dddcod, ',
               '        dpaksocor.teltxt, ',
               '        dpaksocor.horsegsexinc, ',
               '        dpaksocor.horsegsexfnl, ',
               '        dpaksocor.horsabinc, ',
               '        dpaksocor.horsabfnl, ',
               '        dpaksocor.hordominc, ',
               '        dpaksocor.hordomfnl, ',
               '        dpaksocor.pstobs   , ',
               '        dpaksocor.vlrtabflg, ',
               '        dpaksocor.qldgracod '

   if m_atdsrvorg = 9 then
      let l_sql = l_sql clipped,
               '   from dpaksocor, dparpstntz ', # PSI 242853
               '  where dpaksocor.endcep matches "', aux_cep clipped, '" and ',
               '        dpaksocor.endlgd   is not null             and ',
               '        dpaksocor.pstcoddig = dpaksocor.pstcoddig  and ',
               '        dparpstntz.pstcoddig = dpaksocor.pstcoddig    and ',
               '        dparpstntz.socntzcod = ', w_ctn06c04.pstsrvtip ,
               '  order by endcep desc, qldgracod '

   else
      let l_sql = l_sql clipped,
               '   from dpaksocor, dpatserv ',
               '  where dpaksocor.endcep matches "', aux_cep clipped, '" and ',
               '        dpaksocor.endlgd   is not null             and ',
               '        dpaksocor.pstcoddig = dpaksocor.pstcoddig  and ',
               '        dpatserv.pstcoddig = dpaksocor.pstcoddig    and ',
               '        dpatserv.pstsrvtip = ', w_ctn06c04.pstsrvtip ,
               '  order by endcep desc, qldgracod '

   end if

   prepare p_ctn06c04_002 from l_sql
   declare c_ctn06c04_002 cursor for p_ctn06c04_002

   let int_flag = false
   while not int_flag

      let i = 1

      foreach c_ctn06c04_002 into a_ctn06c04[i].nomgrr   ,
                                 a_ctn06c04[i].pstcoddig,
                                 ws.prssitcod           ,
                                 a_ctn06c04[i].endlgd   ,
                                 a_ctn06c04[i].endbrr   ,
                                 a_ctn06c04[i].endcid   ,
                                 a_ctn06c04[i].endufd   ,
                                 a_ctn06c04[i].endcep   ,
                                 a_ctn06c04[i].endcepcmp,
                                 a_ctn06c04[i].dddcod   ,
                                 a_ctn06c04[i].teltxt   ,
                                 a_ctn06c04[i].horsegsexinc,
                                 a_ctn06c04[i].horsegsexfnl,
                                 a_ctn06c04[i].horsabinc,
                                 a_ctn06c04[i].horsabfnl,
                                 a_ctn06c04[i].hordominc,
                                 a_ctn06c04[i].hordomfnl,
                                 a_ctn06c04[i].pstobs   ,
                                 ws.vlrtabflg           ,
                                 ws.qldgracod

         if w_ctn06c04.ciaempcod is not null then

            call ctd03g00_valida_emppst(w_ctn06c04.ciaempcod,
                                        a_ctn06c04[i].pstcoddig)
                 returning l_resultado, l_mensagem

            if l_resultado <> 1 then
               continue foreach
            end if

         end if

         if ws.prssitcod = "A"  then
            let a_ctn06c04[i].situacao = "ATIVO"
         else
            continue foreach
         end if

         if ws.vlrtabflg = "S"   then
            let a_ctn06c04[i].tabela = "TABELA"
         end if

         select cpodes
           into a_ctn06c04[i].qualidade
           from iddkdominio
          where iddkdominio.cponom = "qldgracod"
            and iddkdominio.cpocod = ws.qldgracod

         let i = i + 1

         if i > 200 then
            error "Limite de consulta excedido (200). AVISE A INFORMATICA!"
            exit foreach
         end if
      end foreach

      message " (F17)Abandona, (F6)Recusa, (F8)Seleciona, (F9)Servicos do prestador"

      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn06c04 to s_ctn06c04.*
             on key (interrupt,control-c)
                exit display

             on key (F6)
                let i = arr_curr()

                select atdsrvorg into m_atdsrvorg
                  from datmservico
                 where atdsrvnum = g_documento.atdsrvnum
                   and atdsrvano = g_documento.atdsrvano

                call cta11m00 ( m_atdsrvorg
                               ,g_documento.atdsrvnum
                               ,g_documento.atdsrvano
                               ,a_ctn06c04[i].pstcoddig
                               ,"S" )
                     returning l_srvrcumtvcod

                exit display

             on key (F8)

                let i = arr_curr()
                let ws_pstcoddig = a_ctn06c04[i].pstcoddig

                call cts08g01("A","S","PRESTADOR SELECIONADO",
                              a_ctn06c04[i].nomgrr,"ESTA CORRETO ?","")
                returning confirma

                if confirma = "S" then
                   let int_flag =  true
#                  error "Prestador selecionado !!"
                   exit display
                end if

             on key (F9)
                let  i = arr_curr()
                if m_atdsrvorg = 9 then
                   #call ctn06c10(a_ctn06c04[i].pstcoddig)
                   #     returning m_socntzgrpcod, m_socntzgrpdes
                   call ctn06c11(a_ctn06c04[i].pstcoddig)
                        returning m_socntzcod, m_socntzdes # PSI 242853
                else
                   call ctn06c08(a_ctn06c04[i].pstcoddig)
                end if
          end display
      else
          error "Este servico nao foi localizado nesta regiao - Tente Proxima regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false
   return ws_pstcoddig

end function  #  proxreg_ctn06c04
