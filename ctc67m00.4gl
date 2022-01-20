#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CADASTROS DE CLIENTES I -  CSSI -  CENTRAL 24H             #
# MODULO.........: ctc67m00                                                   #
# ANALISTA RESP..: Fabio Costa / Guilherme Rosa                               #
# PSI/OSF........: PSi-2013-07173 - Consulta de Clientes I                    #
#                  Manter Historico do cadastro de clientes I                 #
# ........................................................................... #
# DESENVOLVIMENTO: MARCIA FRANZON - INTERA                         15/07/2013 #
# ........................................................................... #
globals "/homedsa/projetos/geral/globals/glct.4gl"

DEFINE d_data      date,
       d_datachar  char(10),
       d_rlzsrvano dec(2,0),
       arr_aux     smallint,
       scr_aux     smallint,
       msg_erro    char(200),
       l_arr       SMALLINT

define l_trans     char(01)
define l_tpoper    char(01)
DEFINE ws               RECORD
       tipcli           char(01),
       cpfcpjnum        like datkipecli.cpfcpjnum,
       cpjfilnum        like datkipecli.cpjfilnum,
       cpfcpjdig        like datkipecli.cpfcpjdig,
       temvclflg        char (01),
       temsrrflg        char (01)
END RECORD
#---------------------------------------------
# Rotina principal
#----------------------------------------------

DEFINE l_indice          INTEGER
DEFINE p_resp            CHAR(01)
DEFINE l_sql             CHAR(5000)
DEFINE prompt_key        CHAR(01)
DEFINE l_cliacptxt       CHAR(2000)

define  d_observ  RECORD
       srvaltobstxt      like datripeclisrv.srvaltobstxt
end RECORD

DEFINE k_ctc67m00        RECORD
       tipcli            CHAR(01)
      ,cpfcpjnum         like datkipecli.cpfcpjnum
      ,cpjfilnum         like datkipecli.cpjfilnum
      ,cpfcpjdig         like datkipecli.cpfcpjdig
end RECORD

DEFINE k_ipeclinum       like datkipecli.ipeclinum

DEFINE d_ctc67m00        RECORD
       clisitcod         like datkipecli.clisitcod
      ,clinom            like datkipecli.clinom
      ,celtelnum         like datkipecli.celtelnum
      ,telnum            like datkipecli.telnum
      ,cidnom            like datkipecli.cidnom
      ,ufdsgl            like datkipecli.ufdsgl
end RECORD

DEFINE c_ctc67m00        RECORD
       usrtipcod         like datkipecli.usrtipcod
      ,empcod            like datkipecli.empcod
      ,usrmatnum         like datkipecli.usrmatnum
      ,regiclhrrdat      like datkipecli.regiclhrrdat
      ,regalthrrdat      like datkipecli.regalthrrdat
end RECORD

DEFINE lr_ctc67m00_ant   RECORD
       clisitcod         like datkipecli.clisitcod
      ,clinom            like datkipecli.clinom
      ,celtelnum         like datkipecli.celtelnum
      ,telnum            like datkipecli.telnum
      ,cidnom            like datkipecli.cidnom
      ,ufdsgl            like datkipecli.ufdsgl
end RECORD

DEFINE d_desclisitcod    CHAR(09)

DEFINE a_ctc67m00_end array[100]       of RECORD
       srvnum            like datripeclisrv.srvnum
      ,rlzsrvano         like datripeclisrv.rlzsrvano
      ,srvnom            like datripeclisrv.srvnom
      ,srvsoldat         like datripeclisrv.srvsoldat
      ,srvsitcod         char(08)
end RECORD

DEFINE m_prep_sql       smallint

#colocado para desenvolver
#main
#call ctc67m00()
#let g_issk.funmat = '616335'
#let g_issk.usrtip = 'F'
#let g_issk.empcod = '043'
#end main

#----------------------------------------------
FUNCTION ctc67m00_prepare()
#----------------------------------------------

 LET l_sql = " INSERT into datkipecli (ipeclinum  ,"
                                   ," clinom      ,"
                                   ," cpfcpjnum   ,"
                                   ," cpjfilnum   ,"
                                   ," cpfcpjdig   ,"
                                   ," telnum      ,"
                                   ," celtelnum   ,"
                                   ," cidnom      ,"
                                   ," ufdsgl      ,"
                                   ," clisitcod   ,"
                                   ," usrtipcod   ,"
                                   ," empcod      ,"
                                   ," usrmatnum   ,"
                                   ," regiclhrrdat,"
                                   ," regalthrrdat)"
                   ," VALUES ( 0,?,?,?,?,?,?,?,?,?,?,?,?,today,' ') "
 prepare pctc67m00001 FROM l_sql

 LET l_sql = " SELECT ipeclinum   ,"
                   ," clisitcod   ,"
                   ," clinom      ,"
                   ," celtelnum   ,"
                   ," telnum      ,"
                   ," cidnom      ,"
                   ," ufdsgl       "
            ," FROM datkipecli "
            ," WHERE cpfcpjnum = ? "
            ," AND   cpjfilnum = ? "
            ," AND   cpfcpjdig = ? "
 prepare pctc67m00002 FROM l_sql
 declare cctc67m00002 cursor FOR pctc67m00002

 LET l_sql = " SELECT ipeclinum   ,"
                   ," clisitcod   ,"
                   ," clinom      ,"
                   ," celtelnum   ,"
                   ," telnum      ,"
                   ," cidnom      ,"
                   ," ufdsgl       "
            ," FROM datkipecli "
            ," WHERE cpfcpjnum = ? "
            ," AND   cpfcpjdig = ? "
 prepare pctc67m00003 FROM l_sql
 declare cctc67m00003 cursor FOR pctc67m00003

 LET l_sql = "UPDATE datkipecli SET clinom         = ?"
                                   ,",telnum       = ?"
                                   ,",celtelnum    = ?"
                                   ,",cidnom       = ?"
                                   ,",ufdsgl       = ?"
                                   ,",clisitcod    = ?"
                                   ,",usrtipcod    = ?"
                                   ,",empcod       = ?"
                                   ,",usrmatnum    = ?"
                                   ,",regalthrrdat = ?"
                             ," WHERE ipeclinum = ? "

 prepare pctc67m00004 FROM l_sql

 LET l_sql = " INSERT into datmipecliacp (ipeclinum,"
                                       ," regaltdat,"
                                       ," regalthrr,"
                                       ," txtlinnum,"
                                       ," cliacptxt,"
                                       ," usrtipcod,"
                                       ," empcod   ,"
                                       ," usrmatnum)"
            ," values(?,?,?,?,?, ?,?, ?) "
 prepare pctc67m00005 FROM l_sql

 LET l_sql = " SELECT ipeclinum, regaltdat, regalthrr, txtlinnum,"
                     ,"cliacptxt, usrtipcod, empcod, usrmatnum"
              ,"  FROM datmipecliacp  "
            ," WHERE ipeclinum = ? "
    ," order by  regaltdat , txtlinnum  desc"
 prepare pctc67m00006 FROM l_sql
 declare cctc67m00006 cursor FOR pctc67m00006

 LET l_sql = "UPDATE datkipecli SET regalthrrdat = today "
			     ,"    ,usrmatnum = ? "
			     ,"    ,usrtipcod = ? "
			     ,"    ,empcod    = ? "
                             ," WHERE ipeclinum = ? "

 prepare pctc67m00007 FROM l_sql

 LET l_sql = "UPDATE datkipecli SET clisitcod = 'C' "
			       ,"  ,regalthrrdat = today "
			       ,"  , usrmatnum   = ? "
			       ,"  , usrtipcod   = ? "
			       ,"  , empcod      = ? "
			       ,"  WHERE ipeclinum = ?"

 prepare pctc67m00011 FROM l_sql

 LET l_sql = " INSERT into datripeclisrv (ipeclinum    ,"
                                       ," srvnum      ,"
                                       ," rlzsrvano   ,"
                                       ," srvnom      ,"
                                       ," srvsoldat   ,"
                                       ," srvsitcod   ,"
                                       ," srvaltobstxt)"
            ," values(?,?,?,?,?,?,?) "
 prepare pctc67m00008 FROM l_sql

 LET l_sql = " SELECT ipeclinum, srvnum, rlzsrvano,"
                ,"     srvnom, srvsoldat, srvsitcod,"
                ,"     srvaltobstxt  FROM datripeclisrv  "
            ," WHERE ipeclinum = ? "
	    ," and   srvnum    = ? "
	    ," and   rlzsrvano = ? "
    ," order by  srvsitcod,srvsoldat  "
 prepare pctc67m00009 FROM l_sql

 LET l_sql = "UPDATE datripeclisrv SET srvaltobstxt = ? "
			     ,"       ,srvsitcod = ? "
                             ," WHERE ipeclinum = ? "
                             ," and   srvnum    = ? "
                             ," and   rlzsrvano = ? "

 prepare pctc67m00010 FROM l_sql

 LET l_sql = "SELECT srvnum,  srvnom,rlzsrvano, srvsoldat, srvsitcod "
	    ," FROM   datripeclisrv "
            ," WHERE  ipeclinum = ? "
            ," ORDER BY srvsitcod,srvsoldat , srvnum "
 prepare cctc67m00012 from l_sql
 declare pctc67m00012 cursor with hold for cctc67m00012

 LET l_sql = "SELECT unique ipeclinum "
           , " FROM datripeclisrv "
           , " WHERE ipeclinum = ?"
           , " and   srvsitcod = 'I' "
 prepare cctc67m00013 from l_sql

 LET l_sql = " SELECT srvnum,  rlzsrvano, srvnom, srvsoldat, srvsitcod "
            ," FROM   datripeclisrv "
            ," WHERE  ipeclinum = ? "
            ," ORDER BY srvsitcod,srvsoldat , srvnum "
 prepare cctc67m00014 from l_sql
 declare pctc67m00014 cursor with hold for cctc67m00014

  LET l_sql = " SELECT max(txtlinnum) "
             ," FROM datmipecliacp "
             ," WHERE ipeclinum =  ? "
 prepare cctc67m00015 from l_sql

LET m_prep_sql = true

END FUNCTION

#----------------------------------------------
 FUNCTION ctc67m00()
#----------------------------------------------
# Menu do modulo
#---------------

  DEFINE l_comando      char(100),
         l_ret          smallint,
         l_operacional  smallint,
         l_indice       smallint,
         l_endfat       smallint,
         l_msg          char(70)

  IF m_prep_sql is null or
     m_prep_sql <> true then
     call ctc67m00_prepare()
  END if
  
  
{
  IF not get_niv_mod(g_issk.prgsgl, "ctc67m00") then
     ERROR " Modulo sem nivel de consulta e atualizacao!"
     return
  END if
}

options
  PROMPT LINE LAST

  open window w_ctc67m00 at 04,02 with form "ctc67m00"
   attribute(message line last -1 , comment line last -1)

  LET int_flag = false

  initialize  a_ctc67m00_end to   null
  initialize  d_ctc67m00.*   to   null
  initialize  c_ctc67m00.*   to   null
  initialize  k_ctc67m00.*   to   null

  menu "ASSUNTOS"
     before menu
        hide option all
	IF get_niv_mod(g_issk.prgsgl , 'ctc67m00') THEN
	   if g_issk.acsnivcod >= g_issk.acsnivcns then
	      show option "Seleciona","Historico"
           end if
	   if g_issk.acsnivcod >= g_issk.acsnivatl then
	      show option "Seleciona", "Inclui","Cancela","Modifica","Historico"
	   end if
        END IF

	   if g_issk.acsnivcod >= g_issk.acsnivcns then
	      show option "Seleciona","Historico"
           end if
	   if g_issk.acsnivcod >= g_issk.acsnivatl then
	      show option "Seleciona", "Inclui","Cancela","Modifica","Historico"
	   end if
        show option "Encerra"

  command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
               call ctc67m00_seleciona()

  command key ("I") "Inclui" "Inclui Registro na Tabela"
               call ctc67m00_inclui("i")


  command key ("C") "Cancela" "Cancela situacao de cliente I"
               IF k_ipeclinum is not null AND
                  k_ipeclinum > 0        then
                  IF d_ctc67m00.clisitcod = "C"  then
                     ERROR "Situacaodo cliente ja' cancelada!"
		     next option "Seleciona"
		  else
                     call ctc67m00_cancela(k_ipeclinum)
                  END if
                  next option "Seleciona"
               else
                  ERROR " Nenhum registro selecionado!"
                  message ""
                  next option "Seleciona"
               END if


  command key ("M") "Modifica"
               "Modifica registro corrente selecionado"
               IF k_ipeclinum is not null AND
                  k_ipeclinum > 0        then
                  call ctc67m00_modifica("m")
                  next option "Seleciona"
               else
                  message ""
                  ERROR " Nenhum registro selecionado!"
                  next option "Seleciona"
               END if


  command key ("H") "Historico"
               "Historico cadastrado para o Cliente"
               IF k_ipeclinum is not null and
                  k_ipeclinum > 0       then
                  call ctc67m02(k_ipeclinum,
                                  k_ctc67m00.cpfcpjnum ,
                                  k_ctc67m00.cpjfilnum
                                 ,k_ctc67m00.cpfcpjdig)
               else
                  message  " "
                  ERROR " Nenhum registro selecionado!"
                  next option "Seleciona"
               END if

  command key (interrupt,'E') "Encerra" "Retorna ao menu anterior"
              exit menu
  END menu

  close window w_ctc67m00

END FUNCTION    #-- ctc67m00


#---------------------------------------
FUNCTION ctc67m00_seleciona()
#---------------------------------------

    CLEAR FORM
    let k_ipeclinum = 0
    initialize  a_ctc67m00_end to   null
    initialize  d_ctc67m00.*   to   null
    initialize  c_ctc67m00.*   to   null
    initialize  k_ctc67m00.*   to   null
    LET int_flag = false

    let d_data = today
    let d_datachar = d_data
    let d_rlzsrvano = d_datachar[09,10] USING "&&"

    input by name k_ctc67m00.tipcli,
                  k_ctc67m00.cpfcpjnum,
                  k_ctc67m00.cpjfilnum,
                  k_ctc67m00.cpfcpjdig  without defaults

       before field tipcli
              display by name k_ctc67m00.tipcli attribute(reverse)

       after  field tipcli
              IF  k_ctc67m00.tipcli IS NULL OR
                 (k_ctc67m00.tipcli <> 'F' AND
                  k_ctc67m00.tipcli <> 'J') THEN
                  ERROR 'Informar tipo de pessoa (F)isica ou (J)juridica'
                  next field tipcli
              END if
              display by name k_ctc67m00.tipcli


       before field cpfcpjnum
              display by name k_ctc67m00.cpfcpjnum attribute(reverse)

       after  field cpfcpjnum
              IF  k_ctc67m00.cpfcpjnum is null or
                  k_ctc67m00.cpfcpjnum = ' '   or
                  k_ctc67m00.cpfcpjnum = 0     THEN
                  ERROR 'CNPJ/CPF Base é obrigatorio'
                  next field cpfcpjnum
              END if
              display by name k_ctc67m00.cpfcpjnum


       before field cpjfilnum
              IF k_ctc67m00.tipcli = 'F' THEN
                 NEXT FIELD cpfcpjdig
              END IF

       after  field cpjfilnum
              IF (k_ctc67m00.cpjfilnum is null OR
                  k_ctc67m00.cpjfilnum = ' '   OR
                  k_ctc67m00.cpjfilnum =  0)   AND
                  k_ctc67m00.tipcli = 'J'      THEN
                  ERROR 'Filial de CNPJ obrigatorio'
                  next field cpjfilnum
              END if

              display by name k_ctc67m00.cpjfilnum

       before field cpfcpjdig
              display by name k_ctc67m00.cpfcpjdig attribute(reverse)

       after  field cpfcpjdig
              IF  k_ctc67m00.cpfcpjdig is null or
                  k_ctc67m00.cpfcpjdig = ' '   THEN
                  ERROR 'Digiro CNPJ/CPF obrigatorio'
                  next field cpfcpjdig
              END if
              display by name k_ctc67m00.cpfcpjdig

       on key (interrupt,accept)
          error ' Operacao cancelada '
          exit input


    END input

    IF int_flag then
       LET int_flag = false
       return
    END if

    call ctc67m00_ler('S')
	 returning l_tpoper

    if int_flag = true then
       return
    end if

    LET l_indice = 1

    OPEN pctc67m00012 USING k_ipeclinum

    FOREACH pctc67m00012 into a_ctc67m00_end[l_indice].srvnum
                           ,a_ctc67m00_end[l_indice].srvnom
                           ,a_ctc67m00_end[l_indice].rlzsrvano
                           ,a_ctc67m00_end[l_indice].srvsoldat
                           ,a_ctc67m00_end[l_indice].srvsitcod

            IF a_ctc67m00_end[l_indice].srvsitcod = 'P' THEN
               LET a_ctc67m00_end[l_indice].srvsitcod = 'Pago'
            END if
            IF a_ctc67m00_end[l_indice].srvsitcod = 'I' THEN
               LET a_ctc67m00_end[l_indice].srvsitcod = 'Pendente'
            END if

            LET l_indice = l_indice + 1
            IF l_indice > 100 THEN
	       ERROR 'Numero de servicos ultrapassou limite. Avise informatica'
	       exit foreach
            end if
    END FOREACH

    IF l_indice = 1 THEN
       ERROR 'Nao existem servico cadastrado para este cliente'
       RETURN
    END IF

    if g_issk.acsnivcod >= g_issk.acsnivcns then
       display "                                                  F4-Historico"
       at 20,02
    end if

    IF g_issk.acsnivcod >= g_issk.acsnivatl THEN
       display "          F1-Inclui Servico   F2-Alterar Status   F4-Historico   F8-Salva" at 20,02
    END IF

    call set_count(l_indice-1)

    DISPLAY ARRAY a_ctc67m00_end TO s_ctc67m00.*

       on key (f1)
         IF g_issk.acsnivcod >= g_issk.acsnivatl THEN
             call  ctc67m00_incserv('i')
            IF int_flag = true then
               LET k_ipeclinum = 0
               initialize d_ctc67m00.* to null
               initialize a_ctc67m00_end to null
               ERROR " Operacao cancelada!"
               CLEAR FORM
            END IF
             exit display
	 ELSE
	    error 'acesso não permitido'
         END IF

       on key (f2)
         IF g_issk.acsnivcod >= g_issk.acsnivatl THEN
              let arr_aux = arr_curr()
              let scr_aux = scr_line()

              IF a_ctc67m00_end[arr_aux].srvsitcod = 'Pago' then
		 ERROR 'Servico JA consta com Pago'
              else
                 display a_ctc67m00_end[arr_aux].srvnum
	              TO s_ctc67m00[scr_aux].srvnum
                 display a_ctc67m00_end[arr_aux].rlzsrvano
	              TO s_ctc67m00[scr_aux].rlzsrvano
                 display a_ctc67m00_end[arr_aux].srvnom
	              to s_ctc67m00[scr_aux].srvnom
                 display a_ctc67m00_end[arr_aux].srvsoldat
	              to s_ctc67m00[scr_aux].srvsoldat
                 display a_ctc67m00_end[arr_aux].srvsitcod
	              to s_ctc67m00[scr_aux].srvsitcod
		 if l_trans = 'N' or l_trans is null then
                    begin work
		    let l_trans = 'S'
		 end if
                 call ctc67m01()
		   returning d_observ.srvaltobstxt
                   IF d_observ.srvaltobstxt = " " OR
	              d_observ.srvaltobstxt IS NULL then
                      LET k_ipeclinum = 0
                      initialize d_ctc67m00.* to null
                      initialize a_ctc67m00_end to null
                      ERROR " Operacao cancelada!"
                      CLEAR FORM
		      if l_trans = 'S' THEN
	                 LET  l_trans = 'N'
	                 ROLLBACK WORK
                      end if
	              RETURN
                 END IF
                 if d_observ.srvaltobstxt is not null and
                    d_observ.srvaltobstxt <> ' '      THEN
		    whenever error continue
		    EXECUTE pctc67m00010 USING
		                       d_observ.srvaltobstxt
		                      ,'P'
                                      ,k_ipeclinum
		                      ,a_ctc67m00_end[arr_aux].srvnum
		                      ,a_ctc67m00_end[arr_aux].rlzsrvano
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
		       error 'Problemas na gravacao da observacao' sleep 2
		       if l_trans = 'S' then
			  let l_trans = 'N'
			  rollback work
                       end if
		       return
                    end if
		    LET a_ctc67m00_end[arr_aux].srvsitcod = 'Pago'
                        display a_ctc67m00_end[arr_aux].srvsitcod
	                to s_ctc67m00[scr_aux].srvsitcod
		 end iF

		 EXECUTE cctc67m00013 USING k_ipeclinum
		       if status = notfound then
			  whenever error continue
                          EXECUTE  pctc67m00011 USING g_issk.funmat
						      ,g_issk.usrtip
						      ,g_issk.empcod
						      ,k_ipeclinum
                          whenever error stop
			  if sqlca.sqlcode <> 0 then
			     ERROR 'Erro gravacao status cliente ' sleep 2
			     let int_flag = true
			     if l_trans = 'S' then
				let l_trans = 'N'
				rollback work
                             end if
			     return
                          end if
                       end if

                 let int_flag = false
                 LET l_cliacptxt = " Situacao do cliente Alterada de [Pendente] para [Pago]"
                 CALL ctc67m00_grava_hist(k_ipeclinum,l_cliacptxt,'A')
		 LET l_cliacptxt = " OBS : " , d_observ.srvaltobstxt
                 CALL ctc67m00_grava_hist(k_ipeclinum,l_cliacptxt,'i')

                 if int_flag = true then
                    if l_trans = 'S' then
	               let l_trans = 'N'
	               ROLLBACK WORK
	               ERROR 'Altercao cancelada'
	               CLEAR FORM
	               return
                    end if
                 else
                    COMMIT WORK
                     let l_trans = 'N'
                     ERROR " Alteracao efetuada com sucesso!"
                 end if

                 display a_ctc67m00_end[arr_aux].srvnum
	         TO s_ctc67m00[scr_aux].srvnum attribute(reverse)
                 display a_ctc67m00_end[arr_aux].rlzsrvano
	         TO s_ctc67m00[scr_aux].rlzsrvano attribute(reverse)
                 display a_ctc67m00_end[arr_aux].srvnom
	         to s_ctc67m00[scr_aux].srvnom  attribute(reverse)
                 display a_ctc67m00_end[arr_aux].srvsoldat
	         to s_ctc67m00[scr_aux].srvsoldat attribute(reverse)
                 display a_ctc67m00_end[arr_aux].srvsitcod
	         to s_ctc67m00[scr_aux].srvsitcod attribute(reverse)
              end if
        ELSE
	    error "Acesso nao permitido"
        END IF

       on key (f4)
               IF k_ipeclinum is not null and
                  k_ipeclinum > 0       then
		  IF l_trans = 'N' or l_trans is null  then
		     let l_trans = 'S'
		     begin work
                  END IF
                  call ctc67m02(k_ipeclinum,
                                  k_ctc67m00.cpfcpjnum ,
                                  k_ctc67m00.cpjfilnum
                                 ,k_ctc67m00.cpfcpjdig)
		  IF l_trans = 'S' THEN
		     LET l_trans = 'N'
		     COMMIT WORK
                  END IF
               end if

       on key (f8)
         IF g_issk.acsnivcod >= g_issk.acsnivatl THEN
	   if l_trans = 'S' then
	      COMMIT WORK
	      ERROR 'Menutencao de servicos concluida'
	      let l_trans = 'N'
	      CLEAR FORM
              let k_ipeclinum = 0
              initialize  a_ctc67m00_end to   null
              initialize  d_ctc67m00.*   to   null
              initialize  c_ctc67m00.*   to   null
              initialize  k_ctc67m00.*   to   null
	      exit display
           else
	      ERROR 'Nenhuma manutencao de servicos foi solicitada'
	      let int_flag = true
	      CLEAR FORM
              let k_ipeclinum = 0
              initialize  a_ctc67m00_end to   null
              initialize  d_ctc67m00.*   to   null
              initialize  c_ctc67m00.*   to   null
              initialize  k_ctc67m00.*   to   null
              exit display
           end if
        ELSE
	  error 'Operacao não permitida'
        END IF

       on key(interrupt,control-c,esc)
	  if l_trans = 'S' then
	     ROLLBACK WORK
	     let l_trans = 'N'
          end if
	  ERROR 'Operacao cancelada'
          exit display

    END  display

    IF int_flag then
       LET int_flag = false
       return
    END if

END FUNCTION   #-- ctc67m00_seleciona

#-----------------------------------------------------------
FUNCTION ctc67m00_ler(l_operacao)
#-----------------------------------------------------------

    DEFINE  l_operacao     char(01), l_prompt char(1)

    initialize d_ctc67m00.*   to null
    initialize a_ctc67m00_end to null

    whenever error continue
    IF k_ctc67m00.tipcli = 'F' THEN
       open cctc67m00003 USING k_ctc67m00.cpfcpjnum
        ,k_ctc67m00.cpfcpjdig
       fetch cctc67m00003 into k_ipeclinum,d_ctc67m00.*
    ELSE
       open cctc67m00002 USING k_ctc67m00.cpfcpjnum
        ,k_ctc67m00.cpjfilnum
        ,k_ctc67m00.cpfcpjdig
       fetch cctc67m00002 into k_ipeclinum, d_ctc67m00.*
    END IF
    #display 'sqlca.sqlcode: ', sqlca.sqlcode
    if sqlca.sqlcode < 0 then
       ERROR 'Problemas com a selecao de documentos (datkipecli)'
       let int_flag = true
       RETURN l_operacao
    END IF

    let lr_ctc67m00_ant.* = d_ctc67m00.*

    
    IF sqlca.sqlcode  =  100   THEN
       IF l_operacao = "S" THEN
           #display 'entrei no if'
           PROMPT "CPF/CNPJ Não encontrado" for l_prompt 
	   RETURN  l_operacao
      END IF
    ELSE
       let l_operacao = 'm'
    END IF

    IF d_ctc67m00.clisitcod = 'A' THEN
       LET d_desclisitcod = 'ATIVO'
    ELSE
       LET d_desclisitcod = 'CANCELADO'
    END IF
whenever ERROR stop
    display  BY NAME d_ctc67m00.*
    display  d_desclisitcod to s_ctc67m00_01.desclisitcod

    RETURN l_operacao

END FUNCTION

#--------------------------
FUNCTION ctc67m00_array()
#--------------------------

    LET l_indice = 1
    ERROR ' '

    if g_issk.acsnivcod >= g_issk.acsnivcns then
       display "                                                  F4-Historico"at 20,02
    END IF

    IF g_issk.acsnivcod >= g_issk.acsnivatl THEN
       display "          F1-Inclui Servico   F2-Alterar Status   F4-Historico   F8-Salva" at 20,02
    END IF
    OPEN pctc67m00014 USING k_ipeclinum

    FOREACH pctc67m00014 into a_ctc67m00_end[l_indice].srvnum
                              ,a_ctc67m00_end[l_indice].rlzsrvano
                              ,a_ctc67m00_end[l_indice].srvnom
                              ,a_ctc67m00_end[l_indice].srvsoldat
                              ,a_ctc67m00_end[l_indice].srvsitcod

            IF a_ctc67m00_end[l_indice].srvsitcod = 'P' THEN
               LET a_ctc67m00_end[l_indice].srvsitcod = 'Pago'
            END if
            IF a_ctc67m00_end[l_indice].srvsitcod = 'I' THEN
               LET a_ctc67m00_end[l_indice].srvsitcod = 'Pendente'
            END if

            LET l_indice = l_indice + 1

    END FOREACH
    CLOSE pctc67m00014

    IF l_indice = 1 THEN
       ERROR 'Nao existem servico cadastrado para este cliente'
    END IF

    call set_count(l_indice-1)

    DISPLAY ARRAY a_ctc67m00_end TO s_ctc67m00.*


       on key (f1)
         IF g_issk.acsnivcod >= g_issk.acsnivatl THEN
            call  ctc67m00_incserv('i')
            IF int_flag = true then
               LET k_ipeclinum = 0
               initialize d_ctc67m00.* to null
               initialize a_ctc67m00_end to null
               ERROR " Operacao cancelada!"
               CLEAR FORM
            END IF
            exit display
	 ELSE
	    ERROR 'Opcao nao permitida'
	 END IF

       on key (f2)
          IF g_issk.acsnivcod >= g_issk.acsnivatl THEN
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
	     IF a_ctc67m00_end[arr_aux].srvsitcod = 'Pago' then
	        ERROR 'Servico ja consta com Pago'
	     else
                display a_ctc67m00_end[arr_aux].srvnum
	             TO s_ctc67m00[scr_aux].srvnum
                display a_ctc67m00_end[arr_aux].rlzsrvano
	             TO s_ctc67m00[scr_aux].rlzsrvano
                display a_ctc67m00_end[arr_aux].srvnom
	             to s_ctc67m00[scr_aux].srvnom
                display a_ctc67m00_end[arr_aux].srvsoldat
	             to s_ctc67m00[scr_aux].srvsoldat
                display a_ctc67m00_end[arr_aux].srvsitcod
	             to s_ctc67m00[scr_aux].srvsitcod
	        if l_trans = 'N' or l_trans is null then
	            begin work
	            let l_trans = 'S'
	        end if

                call ctc67m01()
	             returning d_observ.srvaltobstxt

                IF d_observ.srvaltobstxt = " " OR
	           d_observ.srvaltobstxt IS NULL then
                   LET k_ipeclinum = 0
                   initialize d_ctc67m00.* to null
                   initialize a_ctc67m00_end to null
                   ERROR " Operacao cancelada!"
                   CLEAR FORM
		   if l_trans = 'S' THEN
	              LET  l_trans = 'N'
	              ROLLBACK WORK
		   end if
	           RETURN
                END IF  #mmf260813
                if d_observ.srvaltobstxt is not null and
                   d_observ.srvaltobstxt <> ' '      THEN
		    whenever error continue
		    EXECUTE pctc67m00010 USING d_observ.srvaltobstxt
		                              ,'P'
                                              ,k_ipeclinum
		                              ,a_ctc67m00_end[arr_aux].srvnum
		                              ,a_ctc67m00_end[arr_aux].rlzsrvano
                    whenever error stop
                    if sqlca.sqlcode <> 0 then
		       error 'Problemas na gravacao da observacao' sleep 2
		       if l_trans = 'S' then
			  let l_trans = 'N'
			  rollback work
                       end if
		       return
                    end if
		    LET a_ctc67m00_end[arr_aux].srvsitcod = 'Pago'
		    display a_ctc67m00_end[arr_aux].srvsitcod
		         to s_ctc67m00[scr_aux].srvsitcod
	        end if

	        EXECUTE cctc67m00013 USING k_ipeclinum
	           if sqlca.sqlcode = 100 then
		      whenever error continue
                      EXECUTE  pctc67m00011 USING g_issk.funmat
					          ,g_issk.usrtip
					          ,g_issk.empcod
					          ,k_ipeclinum
                      whenever error stop
		      IF sqlca.sqlcode <> 0 then
                         ERROR "Erro (", sqlca.sqlcode, ") no cancelamento da situacao do  cliente. AVISE A INFORMATICA!" SLEEP 2
                         let msg_erro =  "Erro (", sqlca.sqlcode, ") no cancelamento da situacao do  cliente. AVISE A INFORMATICA!" SLEEP 2
	                 call errorlog(msg_erro)
		         if l_trans = 'S' THEN
	                    LET  l_trans = 'N'
	                    ROLLBACK WORK
		         end if
			 return
	              end if
                   end if
	        display a_ctc67m00_end[arr_aux].srvnum
	             TO s_ctc67m00[scr_aux].srvnum
	        display a_ctc67m00_end[arr_aux].rlzsrvano
	             TO s_ctc67m00[scr_aux].rlzsrvano
	        display a_ctc67m00_end[arr_aux].srvnom
	             to s_ctc67m00[scr_aux].srvnom
	        display a_ctc67m00_end[arr_aux].srvsoldat
	             to s_ctc67m00[scr_aux].srvsoldat
	        display a_ctc67m00_end[arr_aux].srvsitcod
	             to s_ctc67m00[scr_aux].srvsitcod
                 let int_flag = false
                 LET l_cliacptxt = " Situacao do cliente Alterada de [Pendente] para [Pago]"
                 CALL ctc67m00_grava_hist(k_ipeclinum,l_cliacptxt,'A')

                 if int_flag = true then
                    if l_trans = 'S' then
	               let l_trans = 'N'
	               ROLLBACK WORK
	               ERROR 'Altercao cancelada'
	               CLEAR FORM
	               return
                    end if
                 else
                    COMMIT WORK
                     let l_trans = 'N'
                     ERROR " Alteracao efetuada com sucesso!"
                 end if
              end if
           ELSE
	      error 'Opcao nao permitida'
           END IF

       on key (f4)
               IF k_ipeclinum is not null and
                  k_ipeclinum > 0       then
		  IF l_trans = 'N' THEN
		     LET l_trans = 'S'
		     BEGIN WORK
                  END IF
                  call ctc67m02(k_ipeclinum,
                                  k_ctc67m00.cpfcpjnum ,
                                  k_ctc67m00.cpjfilnum
                                 ,k_ctc67m00.cpfcpjdig)
		  IF l_trans = 'S' THEN
		     LET l_trans = 'N'
		     COMMIT WORK
                  END IF
               end if

       on key (f8)
	        if l_trans = 'S' then
	           COMMIT WORK
	            let l_trans = 'N'
	          CLEAR FORM
		  error 'Operacao Concluida'
                  let k_ipeclinum = 0
                  initialize  a_ctc67m00_end to   null
                  initialize  d_ctc67m00.*   to   null
                  initialize  c_ctc67m00.*   to   null
                  initialize  k_ctc67m00.*   to   null
		  exit display
	        end if

       on key(interrupt)
	  error ' Operacao cancelada '
                  let k_ipeclinum = 0
                  initialize  a_ctc67m00_end to   null
                  initialize  d_ctc67m00.*   to   null
                  initialize  c_ctc67m00.*   to   null
                  initialize  k_ctc67m00.*   to   null
          exit display

    END  display

END FUNCTION


#---------------------------------------------------------
FUNCTION ctc67m00_inclui(param)
#---------------------------------------------------------

  DEFINE param RECORD
         operacao     char(01)
  END RECORD

  CLEAR FORM
  let k_ipeclinum = 0
  initialize d_ctc67m00.*   to null
  initialize a_ctc67m00_end to null
  initialize k_ctc67m00.*   to null
  initialize c_ctc67m00.*   to null

  call ctc67m00_input(param.operacao)

  IF int_flag = true then
     LET int_flag = false
     initialize d_ctc67m00.* to null
     initialize a_ctc67m00_end to null
     ERROR " Operacao cancelada !"
     CLEAR FORM
     return
  END IF

  if param.operacao = 'm' then
     return
  end if



  LET c_ctc67m00.usrmatnum    = g_issk.funmat
  LET c_ctc67m00.empcod       = g_issk.empcod
  LET c_ctc67m00.usrtipcod    = g_issk.usrtip

  whenever ERROR continue
  EXECUTE pctc67m00001 USING d_ctc67m00.clinom
                             ,k_ctc67m00.cpfcpjnum
                             ,k_ctc67m00.cpjfilnum
                             ,k_ctc67m00.cpfcpjdig
                             ,d_ctc67m00.telnum
                             ,d_ctc67m00.celtelnum
                             ,d_ctc67m00.cidnom
                             ,d_ctc67m00.ufdsgl
                             ,d_ctc67m00.clisitcod
                             ,c_ctc67m00.usrtipcod
                             ,c_ctc67m00.empcod
                             ,c_ctc67m00.usrmatnum
  IF sqlca.sqlcode <> 0 then
     let msg_erro = 'Erro INSERT pctc67m00001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
     call errorlog(msg_erro)
     ERROR 'ctc67m00 / ctc67m00_inclui() ' , sqlca.sqlcode  sleep 2
     let k_ipeclinum = 0
     initialize d_ctc67m00.*   to null
     initialize a_ctc67m00_end to null
     initialize k_ctc67m00.*   to null
     initialize c_ctc67m00.*   to null
     clear form
     return
  END if

  let k_ipeclinum = sqlca.sqlerrd[2]

  whenever ERROR stop

  let l_cliacptxt =   "Cliente incluido [", k_ipeclinum clipped, "] !"

  IF l_trans = 'N' or l_trans is null  then
     begin work
     let l_trans = 'S'
  end if

  call ctc67m00_grava_hist(k_ipeclinum, l_cliacptxt, 'i')

  if int_flag = true then
     if l_trans = 'S' then
	ROLLBACK WORK
	let l_trans = 'N'
     end if
     initialize d_ctc67m00.*   to null
     initialize a_ctc67m00_end to null
     initialize k_ctc67m00.*   to null
     initialize c_ctc67m00.*   to null
     clear form
     return
  end if

  call  ctc67m00_incserv('i')
  IF int_flag = true then
     LET k_ipeclinum = 0
     initialize d_ctc67m00.* to null
     initialize a_ctc67m00_end to null
     ERROR " Operacao cancelada!"
     CLEAR FORM
  END IF


END FUNCTION   #-- ctc67m00_inclui

#-----------------------------------------------------------
FUNCTION ctc67m00_incserv(ws)
#-----------------------------------------------------------

define ws    RECORD
       operacao          char(01)
end RECORD

 let int_flag = false
 let d_data      = today
 let d_datachar  = d_data

 if ws.operacao = "i" then
    initialize a_ctc67m00_end to null
 end if

while true

 display "                                                                 F8-Salva" at 20,02
 input array a_ctc67m00_end without defaults from s_ctc67m00.*
       before row
              let arr_aux = arr_curr()
              let scr_aux = scr_line()

       before field srvnum
              display a_ctc67m00_end[arr_aux].srvnum to
                      s_ctc67m00[scr_aux].srvnum attribute (reverse)

       after field srvnum
	      
           if a_ctc67m00_end[arr_aux].srvnum is null or
		    a_ctc67m00_end[arr_aux].srvnum = 0     then
		        error " Numero de servico e' de preenchimanto obrigatorio!"
		        next field srvnum
           end if

       before field rlzsrvano
              display a_ctc67m00_end[arr_aux].rlzsrvano to
                      s_ctc67m00[scr_aux].rlzsrvano attribute (reverse)
       
       after field rlzsrvano
       
           if a_ctc67m00_end[arr_aux].rlzsrvano is null then
		        error "Ano do servico e' de preenchimanto obrigatorio!"
		        next field rlzsrvano
           end if
           
           if a_ctc67m00_end[arr_aux].rlzsrvano > d_datachar[09,10] using "&&" then
		        error "Ano do servico e' maior que ano atual!"
		        next field rlzsrvano           
           end if

            for l_arr = 1 TO 100
		     if ((a_ctc67m00_end[l_arr].srvnum is null or
		        a_ctc67m00_end[l_arr].srvnum = 0) or
                  (a_ctc67m00_end[l_arr].rlzsrvano is null)) then
		        continue for
		     end if
		     
		     if ((a_ctc67m00_end[arr_aux].srvnum =
		         a_ctc67m00_end[l_arr].srvnum)  and
		         (a_ctc67m00_end[arr_aux].rlzsrvano =
		         a_ctc67m00_end[l_arr].rlzsrvano) and
		        (arr_aux <> l_arr)) then
		        error " Servico ja informado "
		        next field srvnum
               end if
            end for

            if ws.operacao = "i" then
     		  whenever error continue
                      EXECUTE pctc67m00009 using k_ipeclinum
     				            ,a_ctc67m00_end[arr_aux].srvnum
     				            ,a_ctc67m00_end[arr_aux].rlzsrvano
                 whenever error stop
     		  
                 if sqlca.sqlcode < 0 then
     		      error "Erro na selecao do cliente"
     		      next field srvnum
                 else
                     if sqlca.sqlcode = 0 then
     		         error "Servico ja cadastrado para este cliente !"
                        next field srvnum
     	           end if
     		  end if
            end if      

       before field srvnom
              display a_ctc67m00_end[arr_aux].srvnom to
                      s_ctc67m00[scr_aux].srvnom attribute (reverse)
       after field srvnom
	      IF a_ctc67m00_end[arr_aux].srvnom IS NULL OR
		 a_ctc67m00_end[arr_aux].srvnom =  ' '  THEN
		 ERROR " Nome de servico e' de preenchimanto obrigatorio!"
		 next field srvnom
              END IF

       before field srvsoldat
              display a_ctc67m00_end[arr_aux].srvsoldat to
                      s_ctc67m00[scr_aux].srvsoldat attribute (reverse)
              if ws.operacao = "i" then
		 LET a_ctc67m00_end[arr_aux].srvsoldat = TODAY
		 display a_ctc67m00_end[arr_aux].srvsoldat to
	                 s_ctc67m00[scr_aux].srvsoldat
                 next field srvsitcod
              end if

       after field srvsoldat
	      IF a_ctc67m00_end[arr_aux].srvsoldat IS NULL OR
		 a_ctc67m00_end[arr_aux].srvsoldat =  ' '  THEN
		 ERROR " Data de servico e' de preenchimanto obrigatorio!"
		 next field srvnum
              END IF

       before field srvsitcod
              display a_ctc67m00_end[arr_aux].srvsitcod to
                      s_ctc67m00[scr_aux].srvsitcod attribute (reverse)
              if ws.operacao = "i" then
	         LET a_ctc67m00_end[arr_aux].srvsitcod = "Pendente"
	             display a_ctc67m00_end[arr_aux].srvsitcod to
	                     s_ctc67m00[scr_aux].srvsitcod
              end if

       after field srvsitcod
	     if ws.operacao = "i" then
	        LET a_ctc67m00_end[arr_aux].srvsitcod = "Pendente"
             ELSE
	        IF a_ctc67m00_end[arr_aux].srvsitcod = 'I' THEN
                   LET a_ctc67m00_end[arr_aux].srvsitcod = "Pendente"
                ELSE
	           if a_ctc67m00_end[arr_aux].srvsitcod = 'P' THEN
	              LET a_ctc67m00_end[arr_aux].srvsitcod = 'Pago'
                   ELSE
		      ERROR " Situacao do servico e' de preenchimento obrigatorio!"                   next field srvsitcod
		   END IF
                END IF
             END IF
             display a_ctc67m00_end[arr_aux].srvsitcod to
	             s_ctc67m00[scr_aux].srvsitcod

   on key (interrupt, accept)
      let int_flag  = true
      ERROR " Operacao cancelada "
      exit input

   on key (f8)
      let int_flag = false
      IF a_ctc67m00_end[arr_aux].srvnum IS NOT NULL AND
	 a_ctc67m00_end[arr_aux].srvnum > 0 THEN
         IF  a_ctc67m00_end[arr_aux].srvsitcod  IS NULL OR
	     a_ctc67m00_end[arr_aux].srvsoldat  IS NULL OR
	     a_ctc67m00_end[arr_aux].srvnom     IS NULL OR
             a_ctc67m00_end[arr_aux].rlzsrvano  IS NULL THEN
	     ERROR 'Todos campos devem ser informados'
         else
             IF l_trans = 'N' or l_trans is null  then
                begin work
                let l_trans = 'S'
	     end if
             let int_flag = false
             exit input
         end if
      ELSE
	 IF a_ctc67m00_end[01].srvnum IS NOT NULL AND
	    a_ctc67m00_end[01].srvnum  > 0 THEN
            IF l_trans = 'N' or l_trans is null  then
                begin work
                let l_trans = 'S'
	     end if
             let int_flag = false
             exit input
         end if
      end if

 END INPUT
 display "                                                                         " at 20,02

 if int_flag = true then
    exit while
 end if

  let int_flag = false
  let l_indice = 0


  IF a_ctc67m00_end[1].srvnum IS NULL OR
     a_ctc67m00_end[1].srvnum = 0 THEN
     error 'Nao existem dados a serem incluidos'
     exit while
  END IF

  FOR l_indice = 1 to 100
      IF a_ctc67m00_end[l_indice].srvnum is null or
         a_ctc67m00_end[l_indice].srvnum = 0     then
	 EXIT FOR
      END IF

      if l_indice > 100 then
         ERROR 'numero de linhas de servico ultrapassada'
         exit while
      end if

     IF ws.operacao = "i" then
        LET a_ctc67m00_end[l_indice].srvsitcod = 'I'
     ELSE
        IF a_ctc67m00_end[l_indice].srvsitcod  = 'I' OR
           a_ctc67m00_end[l_indice].srvsitcod  =  'Pendente' THEN
	   LET a_ctc67m00_end[l_indice].srvsitcod = 'I'
        ELSE
	   LET a_ctc67m00_end[l_indice].srvsitcod = 'P'
	END IF
     END IF
     whenever error continue
     EXECUTE pctc67m00008 USING k_ipeclinum
                                    ,a_ctc67m00_end[l_indice].srvnum
                                    ,a_ctc67m00_end[l_indice].rlzsrvano
                                    ,a_ctc67m00_end[l_indice].srvnom
                                    ,a_ctc67m00_end[l_indice].srvsoldat
                                    ,a_ctc67m00_end[l_indice].srvsitcod
				   ,' '
         whenever ERROR stop
         IF sqlca.sqlcode <> 0 then
            let msg_erro = 'Erro INSERT pctc67m00008 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
            ERROR  'ctc67m00 / inclui_servicos_ctc67m00_1() '  sleep 2
	    ROLLBACK WORK
	    call errorlog(msg_erro)
	    let l_trans = 'N'
            let k_ipeclinum = 0
            initialize d_ctc67m00.*   to null
            initialize a_ctc67m00_end to null
            initialize k_ctc67m00.*   to null
            initialize c_ctc67m00.*   to null
            clear form
            exit for
         END if

	 # gravacao da data de alteracao
	 whenever error continue
         EXECUTE pctc67m00007 USING g_issk.funmat,
			     g_issk.usrtip,
			     g_issk.empcod,
			     k_ipeclinum

         whenever ERROR stop
         IF sqlca.sqlcode <> 0 then
            let msg_erro =  'Erro UPDATE pctc67m00007 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
	    call errorlog(msg_erro)
            ERROR  'ctc67m00 / inclui_servicos_ctc67m00_2() '  sleep 2
	    ROLLBACK WORK
	    let l_trans = 'N'
            let k_ipeclinum = 0
            initialize d_ctc67m00.*   to null
            initialize a_ctc67m00_end to null
            initialize k_ctc67m00.*   to null
            initialize c_ctc67m00.*   to null
            clear form
            exit for
         END if

         let l_cliacptxt =   "Servico incluido [", a_ctc67m00_end[l_indice].srvnum USING "&&&&&&&" clipped, "] "
	 LET l_cliacptxt = l_cliacptxt clipped," Nome do servico [", a_ctc67m00_end[l_indice].srvnom clipped, "] "
         IF l_trans = 'N' or l_trans is null  then
            begin work
            let l_trans = 'S'
         end if
         call ctc67m00_grava_hist(k_ipeclinum, l_cliacptxt, 'i')

	 IF int_flag = true then
            ERROR 'Operacao cancelada'
            if l_trans = 'S' then
	       ROLLBACK WORK
	       let l_trans = 'N'
               let k_ipeclinum = 0
               initialize d_ctc67m00.*   to null
               initialize a_ctc67m00_end to null
               initialize k_ctc67m00.*   to null
               initialize c_ctc67m00.*   to null
               clear form
	       exit for
            end if
         end if
     END FOR

  IF l_trans = 'S' THEN
     COMMIT WORK
#    LET k_ipeclinum = 0
     ERROR 'Operacao concluida'
     let l_trans = 'N'
  ELSE
     ERROR "Nao foram efetuadas alterações"
     LET k_ipeclinum = 0
     exit while
  END IF
  exit while

end while

END FUNCTION
#-----------------------------------------------------------
FUNCTION ctc67m00_modifica(param)
#-----------------------------------------------------------

  DEFINE param          RECORD
    operacao            char(01)
  END RECORD

  DEFINE l_cliacptxt  char(2000),
         l_length     smallint,
         teste        char(1) ,
         l_ret        smallint,
         l_indice     smallint,
         l_count      smallint,
         l_endfat     smallint,
         l_res        integer,
         l_msg        char(70),
         l_today      date

  LET lr_ctc67m00_ant.* = d_ctc67m00.*

  initialize a_ctc67m00_end to null

  LET int_flag = false

  call ctc67m00_input(param.operacao)

  IF int_flag then
     LET k_ipeclinum = 0
     initialize d_ctc67m00.* to null
     initialize a_ctc67m00_end to null
     ERROR " Operacao cancelada!"
     CLEAR FORM
     return
  END if

  let l_today = today


  call cts08g01("A","S","","DESEJA SALVAR ALTERACOES EFETUADAS ?","","")
       RETURNING  prompt_key

  IF prompt_key = "N" THEN
     ERROR " Operacao cancelada!"
     CALL ctc67m00_array()
     CLEAR FORM
     return
  END IF

  LET c_ctc67m00.usrmatnum    = g_issk.funmat
  LET c_ctc67m00.empcod       = g_issk.empcod
  LET c_ctc67m00.usrtipcod    = g_issk.usrtip

  begin work
  whenever ERROR continue
  EXECUTE pctc67m00004 USING d_ctc67m00.clinom
                             ,d_ctc67m00.telnum
                             ,d_ctc67m00.celtelnum
                             ,d_ctc67m00.cidnom
                             ,d_ctc67m00.ufdsgl
                             ,d_ctc67m00.clisitcod
                             ,c_ctc67m00.usrtipcod
                             ,c_ctc67m00.empcod
                             ,c_ctc67m00.usrmatnum
                             ,l_today
                             ,k_ipeclinum
  whenever error stop
  IF sqlca.sqlcode <> 0  then
     let msg_erro =  'Erro na atualizacao do datkipecli: ', sqlca.sqlcode
     ERROR 'Erro na atualizacao do datkipecli: ', sqlca.sqlcode,' / ',
           sqlca.sqlerrd[2]
     sleep 2
     call errorlog(msg_erro)
     initialize d_ctc67m00.*  to null
     initialize a_ctc67m00_end  to null
     initialize k_ctc67m00.*  to null
     let int_flag = true
     ROLLBACK WORK
     return
  END if

  ## Verifica se alguma das informacoes foi alterada     ##
  ## e concatena na descricao para gravacao do historico ##
  LET l_cliacptxt = null

  IF (d_ctc67m00.clinom is null and lr_ctc67m00_ant.clinom is not null) or
     (d_ctc67m00.clinom is not null and lr_ctc67m00_ant.clinom is null) or
     (d_ctc67m00.clinom <> lr_ctc67m00_ant.clinom) then
       LET l_cliacptxt = l_cliacptxt clipped,
          " Nome Cliente Alterado de [", lr_ctc67m00_ant.clinom clipped,"] para [", d_ctc67m00.clinom clipped,"],"
  END if

  IF (d_ctc67m00.telnum is null and lr_ctc67m00_ant.telnum is  not null) or
     (d_ctc67m00.telnum is not null and lr_ctc67m00_ant.telnum is  null) or
     (d_ctc67m00.telnum <> lr_ctc67m00_ant.telnum) then
       LET l_cliacptxt = l_cliacptxt clipped, " Telefone Cliente alterado de [", lr_ctc67m00_ant.telnum USING "&&&&&&&&&&" clipped,"] para [", d_ctc67m00.telnum USING "&&&&&&&&&&"  clipped,"],"
  END if

  IF (d_ctc67m00.celtelnum is null and lr_ctc67m00_ant.celtelnum is not null) or
     (d_ctc67m00.celtelnum is not null and lr_ctc67m00_ant.celtelnum is null) or
     (d_ctc67m00.celtelnum <> lr_ctc67m00_ant.celtelnum) then
       LET l_cliacptxt = l_cliacptxt clipped, " Celular Cliente alterado de [", lr_ctc67m00_ant.celtelnum USING "&&&&&&&&&&&" clipped,"] para [",d_ctc67m00.celtelnum using "&&&&&&&&&&&" clipped,"],"
  END if

  IF  (d_ctc67m00.cidnom is null and lr_ctc67m00_ant.cidnom is not null)   or
      (d_ctc67m00.cidnom is not null  and lr_ctc67m00_ant.cidnom is null)  or
      (d_ctc67m00.cidnom              <> lr_ctc67m00_ant.cidnom )     then
      LET l_cliacptxt = l_cliacptxt clipped," Cidade alterada de [",lr_ctc67m00_ant.cidnom clipped,"] para [",d_ctc67m00.cidnom clipped,"],"
  END if

  IF  (d_ctc67m00.ufdsgl is null and lr_ctc67m00_ant.ufdsgl is not null)   or
      (d_ctc67m00.ufdsgl is not null and lr_ctc67m00_ant.ufdsgl is null)   or
      (d_ctc67m00.ufdsgl <> lr_ctc67m00_ant.ufdsgl)               then
      LET l_cliacptxt = l_cliacptxt clipped, " UF alterada de [", lr_ctc67m00_ant.ufdsgl clipped,"] para [", d_ctc67m00.ufdsgl clipped,"],"
  END if

  IF (d_ctc67m00.clisitcod is null and lr_ctc67m00_ant.clisitcod is not null)
      or (d_ctc67m00.clisitcod  is not null and
  lr_ctc67m00_ant.clisitcod is null)or
         (d_ctc67m00.clisitcod <> lr_ctc67m00_ant.clisitcod) then
     LET l_cliacptxt = l_cliacptxt clipped," Situacao do cliente Alterada de [", lr_ctc67m00_ant.clisitcod clipped,"] para [",d_ctc67m00.clisitcod clipped,"],"
  END if

  let int_flag = false
  #Retira a virgula do final da string (se houver),
  #coloca o ponto e grava na tabela de historico
  let l_length = length(l_cliacptxt clipped)
  if  l_cliacptxt is not null and l_length > 0 then
      if  l_cliacptxt[1] = " " then
	  let l_cliacptxt = l_cliacptxt[2,l_length]
	  let l_length = length(l_cliacptxt clipped)
      end if

      if  l_cliacptxt[l_length] = "," then
          let l_cliacptxt = l_cliacptxt[1,l_length - 1], "."
      end if
  end if

  CALL ctc67m00_grava_hist(k_ipeclinum,l_cliacptxt,'A')

  if int_flag = true then
     ROLLBACK WORK
     ERROR 'Altercao cancelada'
     CLEAR FORM
     return
  else
     COMMIT WORK
     ERROR " Alteracao efetuada com sucesso!"
  end if
  CALL ctc67m00_array()
  initialize d_ctc67m00.* to null
  initialize a_ctc67m00_end to null
  initialize k_ctc67m00.* to null
  CLEAR FORM

END FUNCTION    #-- ctc67m00_modifica

#--------------------------------------------------------------
FUNCTION ctc67m00_input(param)
#--------------------------------------------------------------

  DEFINE param RECORD
         operacao  char(01)
  END RECORD

  LET l_sql = null
  LET int_flag = false

  input by name  k_ctc67m00.tipcli
                ,k_ctc67m00.cpfcpjnum
                ,k_ctc67m00.cpjfilnum
                ,k_ctc67m00.cpfcpjdig
                ,d_ctc67m00.clisitcod
                ,d_ctc67m00.clinom
                ,d_ctc67m00.celtelnum
                ,d_ctc67m00.telnum
                ,d_ctc67m00.cidnom
                ,d_ctc67m00.ufdsgl
         without defaults

       before field tipcli
              display by name k_ctc67m00.tipcli attribute(reverse)
	      if param.operacao = 'm' then
		 display by name k_ctc67m00.tipcli
		 display by name k_ctc67m00.cpfcpjnum
		 display by name k_ctc67m00.cpjfilnum
		 display by name k_ctc67m00.cpfcpjnum
		 next field clisitcod
              end if

       after  field tipcli
              IF (k_ctc67m00.tipcli <> 'F' AND
                  k_ctc67m00.tipcli <> 'J') OR
                  k_ctc67m00.tipcli IS NULL THEN
                  ERROR 'Informar tipo de pessoa (F)isica ou (J)juridica'
                  next field tipcli
              END if
              display by name k_ctc67m00.tipcli

       before field cpfcpjnum
	      if param.operacao = 'm' then
		 next field clisitcod
              end if
              display by name k_ctc67m00.cpfcpjnum    attribute(reverse)

       after field cpfcpjnum
             IF k_ctc67m00.cpfcpjnum is null  or
                k_ctc67m00.cpfcpjnum =  " "   then
                ERROR " Base cnpj/cpf deve ser informado !"
                next field cpfcpjnum
             END if
             display by name k_ctc67m00.cpfcpjnum


       before field cpjfilnum
             display by name k_ctc67m00.cpjfilnum   attribute(reverse)
	     if param.operacao = 'm' then
	        next field clisitcod
             end if
             IF k_ctc67m00.tipcli = 'F' THEN
                display by name k_ctc67m00.cpjfilnum
                next field cpfcpjdig
             END if

       after field cpjfilnum
             IF (k_ctc67m00.cpfcpjnum is null  or
                k_ctc67m00.cpfcpjnum =  " ")   and
                k_ctc67m00.tipcli = 'J' then
                ERROR " Filial cnpj deve ser informada !"
                next field cpjfilnum
             END if
             display by name k_ctc67m00.cpjfilnum

       before field cpfcpjdig
             display by name k_ctc67m00.cpfcpjdig    attribute(reverse)
	      if param.operacao = 'm' then
		 next field clisitcod
              end if

       after field cpfcpjdig
             IF k_ctc67m00.cpfcpjnum is null  or
                k_ctc67m00.cpfcpjnum =  " "   then
                ERROR " Digito cnpj/cpf deve ser informado !"
                next field cpfcpjnum
             END if
             display by name k_ctc67m00.cpfcpjdig
             IF k_ctc67m00.tipcli  =  "J"    then
                call F_FUNDIGIT_DIGITOCGC(k_ctc67m00.cpfcpjnum,
                                          k_ctc67m00.cpjfilnum)
                     returning ws.cpfcpjdig
             else
                call F_FUNDIGIT_DIGITOCPF(k_ctc67m00.cpfcpjnum)
                     returning ws.cpfcpjdig
             END if

             IF ws.cpfcpjdig         is null           or
                k_ctc67m00.cpfcpjdig <> ws.cpfcpjdig   then
                ERROR " Digito do cnpj/Cpf incorreto!"
                next field cpfcpjnum
             END if

             IF param.operacao = 'i' THEN
                CALL ctc67m00_ler("i")
		     returning l_tpoper
                let param.operacao = l_tpoper

		if param.operacao = 'i' then
		   let int_flag = false
		   continue input
                end if

		call cts08g01 ("A","S","CLIENTE CADASTRADO NO SISTEMA",
			       d_desclisitcod  ,
			       "DESEJA ALTERAR INFORMACOES DO CLIENTE?","")
                              returning prompt_key

               IF prompt_key = "N" THEN
                  CLEAR FORM
		  initialize k_ipeclinum to null
                  initialize d_ctc67m00.* to null
                  initialize a_ctc67m00_end to null
                  initialize k_ctc67m00.* to null
		  let int_flag = true
                  EXIT INPUT
	       ELSE
                  call ctc67m00_modifica("m")
		  exit input
               END IF
             END IF

       before field clisitcod
             IF param.operacao = 'i' THEN
                LET d_ctc67m00.clisitcod = 'A'
                display by name d_ctc67m00.clisitcod
                LET d_desclisitcod = 'ATIVO'
	        DISPLAY  d_desclisitcod to s_ctc67m00_01.desclisitcod
                NEXT FIELD clinom
             END IF
             display by name d_ctc67m00.clisitcod    attribute(reverse)

      after field clisitcod
             IF d_ctc67m00.clisitcod is null  or
               (d_ctc67m00.clisitcod <>  "A" AND
                d_ctc67m00.clisitcod <>  "C") THEN
                ERROR " Situacao do cliente deve ser  (A)tivo ou (C)ancelado !"
                next field clisitcod
             END if

             IF d_ctc67m00.clisitcod = 'A' THEN
                LET d_desclisitcod = 'ATIVO'
             ELSE
                LET d_desclisitcod = 'CANCELADO'
             END IF
             display by name d_ctc67m00.clisitcod
	     display  d_desclisitcod to s_ctc67m00_01.desclisitcod

      before field clinom
             display by name d_ctc67m00.clinom    attribute(reverse)
      after field clinom
             IF d_ctc67m00.clinom is null  or
                d_ctc67m00.clinom =  " "   then
                ERROR " Nome Cliente deve ser informado !"
                next field clinom
             END if
             display by name d_ctc67m00.clinom

      before field celtelnum
             display by name d_ctc67m00.celtelnum    attribute(reverse)
      after field celtelnum
             IF d_ctc67m00.celtelnum is null  or
                d_ctc67m00.celtelnum =  " "   then
                ERROR " Nr Celular deve ser informado !"
                next field celtelnum
             END if
             display by name d_ctc67m00.celtelnum

      before field telnum
             display by name d_ctc67m00.telnum        attribute(reverse)
      after field telnum
             IF d_ctc67m00.telnum is null  or
                d_ctc67m00.telnum =  " "   then
                ERROR " Telefone deve ser informado !"
                next field telnum
             END if
             display by name d_ctc67m00.telnum

      before field cidnom
             display by name d_ctc67m00.cidnom              attribute(reverse)
      after field cidnom
             IF d_ctc67m00.cidnom is null  or
                d_ctc67m00.cidnom =  " "   then
                ERROR " cidade  deve ser informada !"
                next field cidnom
             END if
             display by name d_ctc67m00.cidnom

      before field ufdsgl
             display by name d_ctc67m00.ufdsgl              attribute(reverse)
      after field ufdsgl
             IF d_ctc67m00.ufdsgl is null  or
                d_ctc67m00.ufdsgl =  " "   then
                ERROR " uf deve ser informada !"
                next field ufdsgl
             END if
             display by name d_ctc67m00.ufdsgl

  on key (interrupt,accept)
     let int_flag = true
     error ' Operacao cancelada '
     exit input

  END input


END FUNCTION    #-- ctc67m00_input

#------------------------------------------------------------
FUNCTION ctc67m00_cancela(k_ipeclinum)
#------------------------------------------------------------

 DEFINE  k_ipeclinum      like datkipecli.ipeclinum

  LET int_flag = false

  DISPLAY BY NAME k_ctc67m00.tipcli
  DISPLAY BY NAME k_ctc67m00.cpfcpjnum
  DISPLAY BY NAME k_ctc67m00.cpjfilnum
  DISPLAY BY NAME k_ctc67m00.cpfcpjdig
  DISPLAY BY NAME d_ctc67m00.clisitcod
  DISPLAY BY NAME d_ctc67m00.clinom
  DISPLAY BY NAME d_ctc67m00.celtelnum
  DISPLAY BY NAME d_ctc67m00.telnum
  DISPLAY BY NAME d_ctc67m00.cidnom
  DISPLAY BY NAME d_ctc67m00.ufdsgl
  DISPLAY BY NAME d_ctc67m00.clisitcod

     whenever error continue
     EXECUTE  pctc67m00011 USING g_issk.funmat
			         ,g_issk.usrtip
		                 ,g_issk.empcod
		                 ,k_ipeclinum
     whenever error stop
     IF sqlca.sqlcode <> 0  then
        ERROR "Erro (", sqlca.sqlcode, ") no cancelamento da situacao do  cliente. AVISE A INFORMATICA!" SLEEP 2
        let msg_erro =  "Erro (", sqlca.sqlcode, ") no cancelamento da situacao do  cliente. AVISE A INFORMATICA!" SLEEP 2
	call errorlog(msg_erro)
     else
        LET d_desclisitcod = 'CANCELADO'
	LET d_ctc67m00.clisitcod = 'C'
	display by name d_ctc67m00.clisitcod
	display d_desclisitcod to s_ctc67m00_01.desclisitcod
        ERROR " Situacao cancelada!"
	LET l_cliacptxt = "Situacao do cliente Alterada de [ATIVO} para [CANCELADO]"
        IF l_trans = 'N' or l_trans is null  then
           begin work
           let l_trans = 'S'
        end if
        whenever error continue
        EXECUTE pctc67m00007 USING g_issk.funmat,
			           g_issk.usrtip,
			           g_issk.empcod,
			           k_ipeclinum
        whenever error stop
            if sqlca.sqlcode <> 0 then
               let msg_erro =  'Erro UPDATE pctc67m00007 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
	       call errorlog(msg_erro)
               ERROR  'ctc67m00 / ctc67m00_cancela() '  sleep 2
	       if l_trans = 'S' then
		  let l_trans = 'N'
		  rollback work
		  let int_flag = true
		  return
               end if
          end if

        CALL ctc67m00_grava_hist(k_ipeclinum,l_cliacptxt,'C')

        if int_flag = true then
           if l_trans = 'S' then
	      let l_trans = 'N'
	      ROLLBACK WORK
	      ERROR 'Altercao historico cancelada'
           end if
        else
           ERROR " Alteracao efetuada com sucesso!"
        end if
     END if

  LET int_flag = false

END FUNCTION   ### ctc67m00_cancela


#-------------------------------------#
FUNCTION ctc67m00_grava_hist(lr_param)
#-------------------------------------#
  DEFINE lr_param    RECORD
         ipeclinum   like datkipecli.ipeclinum,
         cliacptxt   char(2000),
         operacao    char(1)
  END RECORD

  DEFINE lr_ret      RECORD
         texto1      char(70)
        ,texto2      char(70)
        ,texto3      char(70)
        ,texto4      char(70)
        ,texto5      char(70)
        ,texto6      char(70)
        ,texto7      char(70)
        ,texto8      char(70)
        ,texto9      char(70)
        ,texto10     char(70)
  END RECORD

  DEFINE l_stt       smallint
        ,l_path      char(100)
        ,l_cmd2      char(4000)
        ,l_texto2    char(3000)

  DEFINE l_txtlinnum  like datmipecliacp.txtlinnum,
         l_cliacptxt2 like datmipecliacp.cliacptxt,
         l_texto      like datmipecliacp.cliacptxt,
         l_cmtnom     like isskfunc.funnom,
         l_data       date,
         l_hora       datetime hour to fraction(4),
         l_hora_ant   datetime hour to fraction(4),
         l_count,
         l_iter,
         l_length,
         l_length2    smallint,
         l_msg        char(50),
         l_erro       smallint,
         l_cmd        char(100),
         l_corpo_email char(1000),
         teste         char(1)

  LET l_msg = null

  IF m_prep_sql is null or
     m_prep_sql <> true then
     call ctc67m00_prepare()
  END if

  #Buscar ultimo item de historico cadastrado para o cliente
  LET l_txtlinnum = 0
  EXECUTE  cctc67m00015 into l_txtlinnum
			 USING lr_param.ipeclinum

  IF l_txtlinnum is null or l_txtlinnum = 0 then
     LET l_txtlinnum = 1
  else
     LET l_txtlinnum = l_txtlinnum + 1
  END if


  LET l_length = length(lr_param.cliacptxt clipped)
  IF  l_length mod 70 = 0 then
      LET l_iter = l_length / 70
  else
      LET l_iter = l_length / 70 + 1
  END if

  LET l_corpo_email = null
  LET l_length2     = 0
  LET l_erro        = 0

  FOR l_count = 1 to l_iter

      let l_data = today
      let l_hora = current

      IF  l_count = l_iter then
          LET l_cliacptxt2 = lr_param.cliacptxt[l_length2 + 1, l_length]
      else
          LET l_length2 = l_length2 + 70
          LET l_cliacptxt2 = lr_param.cliacptxt[l_length2 - 69, l_length2]
      END if


      IF  l_hora_ant = l_hora then
          sleep 1
	  let l_hora = current
      END IF

      # grava historico para o cliente
      whenever error continue
      EXECUTE pctc67m00005 USING lr_param.ipeclinum,
                                  l_data,
                                  l_hora,
                                  l_txtlinnum,
                                  l_cliacptxt2,
                                  g_issk.usrtip,
                                  g_issk.empcod,
                                  g_issk.funmat
      whenever error stop
      IF sqlca.sqlcode <> 0  then
          ERROR "Erro (", sqlca.sqlcode, ") na inclusao do historico (datmipecliacp). " sleep 2
	  LET msg_erro = "Erro (", sqlca.sqlcode, ") na inclusao do historico (datmipecliacp). "
	  call errorlog(msg_erro)
	  let l_erro = sqlca.sqlcode
	  let int_flag = true
      END if

      IF l_erro <> 0 then
         exit for
      END if

      LET l_txtlinnum  = l_txtlinnum + 1
      LET l_hora_ant = l_hora

  END for
  whenever error continue
  EXECUTE pctc67m00007 USING g_issk.funmat,
			     g_issk.usrtip,
			     g_issk.empcod,
			     k_ipeclinum
  whenever error stop
            if sqlca.sqlcode <> 0 then
               let msg_erro =  'Erro UPDATE pctc67m00007 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
	       call errorlog(msg_erro)
               ERROR  'ctc67m00 / ctc67m00_grava_hist() '  sleep 2
	       if l_trans = 'S' then
		  let l_trans = 'N'
		  rollback work
		  let int_flag = true
		  return
               end if
          end if

END FUNCTION

#----------------------------
FUNCTION ctc67m00_confmodif()
#----------------------------

define l_today date

  let l_today = today


  CALL cts08g01("A","S","DESEJA SALVAR AS ALTERACOES EFETUADAS?","","","")
           returning prompt_key

  IF prompt_key = "N" THEN
     ERROR " Operacao cancelada!"
     CALL ctc67m00_array()
     CLEAR FORM
     return
  END IF

  LET c_ctc67m00.usrmatnum    = g_issk.funmat
  LET c_ctc67m00.empcod       = g_issk.empcod
  LET c_ctc67m00.usrtipcod    = g_issk.usrtip
  IF l_trans = 'N' or l_trans is null  then
     begin work
     let l_trans = 'S'
  end if
  whenever ERROR continue
  EXECUTE pctc67m00004 USING d_ctc67m00.clinom
                             ,d_ctc67m00.telnum
                             ,d_ctc67m00.celtelnum
                             ,d_ctc67m00.cidnom
                             ,d_ctc67m00.ufdsgl
                             ,d_ctc67m00.clisitcod
                             ,c_ctc67m00.usrtipcod
                             ,c_ctc67m00.empcod
                             ,c_ctc67m00.usrmatnum
                             ,l_today
                             ,k_ipeclinum

  whenever error stop
  IF sqlca.sqlcode <> 0  then
     let msg_erro =  'Erro na atualizacao do datkipecli: ', sqlca.sqlcode,' / ',
           sqlca.sqlerrd[2]
     ERROR  'Erro na atualizacao do datkipecli: ', sqlca.sqlcode,' / ', sqlca.sqlerrd[2] sleep 2
     call errorlog(msg_erro)
     initialize d_ctc67m00.*  to null
     initialize a_ctc67m00_end  to null
     initialize k_ctc67m00.*  to null
     if l_trans = 'S' then
	ROLLBACK WORK
	let l_trans = 'N'
     end if
     return
  END if

  ## Verifica se alguma das informacoes foi alterada     ##
  ## e concatena na descricao para gravacao do historico ##
  LET l_cliacptxt = null

  IF (d_ctc67m00.clinom is null and lr_ctc67m00_ant.clinom is not null) or
     (d_ctc67m00.clinom is not null and lr_ctc67m00_ant.clinom is null) or
     (d_ctc67m00.clinom <> lr_ctc67m00_ant.clinom) then
       LET l_cliacptxt = l_cliacptxt clipped,
          " Nome Cliente Alterado de [", lr_ctc67m00_ant.clinom clipped,"] para [", d_ctc67m00.clinom clipped,"],"
  END if

  IF (d_ctc67m00.telnum is null and lr_ctc67m00_ant.telnum is  not null) or
     (d_ctc67m00.telnum is not null and lr_ctc67m00_ant.telnum is  null) or
     (d_ctc67m00.telnum <> lr_ctc67m00_ant.telnum) then
       LET l_cliacptxt = l_cliacptxt clipped, " Telefone Cliente alterado de [", lr_ctc67m00_ant.telnum clipped,"] para [", d_ctc67m00.telnum clipped,"],"
  END if

  IF (d_ctc67m00.celtelnum is null and lr_ctc67m00_ant.celtelnum is not null) or
     (d_ctc67m00.celtelnum is not null and lr_ctc67m00_ant.celtelnum is null) or
     (d_ctc67m00.celtelnum <> lr_ctc67m00_ant.celtelnum) then
       LET l_cliacptxt = l_cliacptxt clipped, " Celular Cliente alterado de [", lr_ctc67m00_ant.celtelnum clipped,"] para [",d_ctc67m00.celtelnum clipped,"],"
  END if

  IF  (d_ctc67m00.cidnom is null and lr_ctc67m00_ant.cidnom is not null)   or
      (d_ctc67m00.cidnom is not null  and lr_ctc67m00_ant.cidnom is null)  or
      (d_ctc67m00.cidnom              <> lr_ctc67m00_ant.cidnom )     then
      LET l_cliacptxt = l_cliacptxt clipped," Cidade alterada de [",lr_ctc67m00_ant.cidnom clipped,"] para [",d_ctc67m00.cidnom clipped,"],"
  END if

  IF  (d_ctc67m00.ufdsgl is null and lr_ctc67m00_ant.ufdsgl is not null)   or
      (d_ctc67m00.ufdsgl is not null and lr_ctc67m00_ant.ufdsgl is null)   or
      (d_ctc67m00.ufdsgl <> lr_ctc67m00_ant.ufdsgl)               then
      LET l_cliacptxt = l_cliacptxt clipped, " UF alterada de [", lr_ctc67m00_ant.ufdsgl clipped,"] para [", d_ctc67m00.ufdsgl clipped,"],"
  END if

  IF (d_ctc67m00.clisitcod is null and lr_ctc67m00_ant.clisitcod is not null)
      or (d_ctc67m00.clisitcod  is not null and
  lr_ctc67m00_ant.clisitcod is null)or
         (d_ctc67m00.clisitcod <> lr_ctc67m00_ant.clisitcod) then
     LET l_cliacptxt = l_cliacptxt clipped," Situacao do cliente Alterada de [", lr_ctc67m00_ant.clisitcod clipped,"] para [",d_ctc67m00.clisitcod clipped,"],"
  END if

  IF l_trans = 'N' or l_trans is null  then
     begin work
     let l_trans = 'S'
  end if

  let int_flag = false
  CALL ctc67m00_grava_hist(k_ipeclinum,l_cliacptxt,'A')

  if int_flag = true then
     if l_trans = 'S' then
	let l_trans = 'N'
	ROLLBACK WORK
	ERROR 'Altercao cancelada'
	CLEAR FORM
	return
     end if
  else
     COMMIT WORK
     let l_trans = 'N'
     ERROR " Alteracao efetuada com sucesso!"
  end if
  CALL ctc67m00_array()
  CLEAR FORM
END FUNCTION
