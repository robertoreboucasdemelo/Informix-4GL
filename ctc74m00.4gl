###############################################################################
# Nome do Modulo: ctc74m00                                     Cristiane Silva#
#                                                                             #
# Naturezas do socorrista selecionado                                Out/2005 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO    RESPONSAVEL  DESCRICAO                           #
#-----------------------------------------------------------------------------#
#19/10/2010   CT-2010-00725  Robert Lima  Foi alterado a exclusão da natureza #
#                                         do socorrista. Exclusão da natureza #
#                                         independente da especialização.     #
#30/11/2010                  Burini       Filtro por naturezas ativas         #
#                                                                             #
#26/08/2015   Chamado 551066 Eliane/Fornax Troca da tecla F2 por F5 - excluir #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_prep_sql smallint

  define am_ctc74m00  array[100] of record
         navega       char(01),
         socntzcod smallint,
         socntzdes char(50),
         espcod       like dbsrntzpstesp.espcod,
         espdes       char(50),
         atldat       like dbsrntzpstesp.atldat,
         funnom       char(25)
  end record

  define m_contador smallint

  define espcod_ant like dbskesp.espcod,
         espdes_ant char(50)

  define m_sair smallint

#----------------------#
function ctc74m00(param)
#----------------------#

  define param      record
         srrcoddig  like datksrr.srrcoddig,
         srrnom     like datksrr.srrnom
  end record

  define ws record
         socntzcod  like datksocntz.socntzcod,
         clscod     like datrsocntzsrvre.clscod,
         sta        smallint,
         mensagem   char(100),
         soccntdes  like datksocntz.socntzdes,
         codigo     like datksocntz.socntzcod,
         erro       smallint,
         funnom     char(100),
         cod        smallint
  end record

  define l_sucesso  smallint

  let l_sucesso = true

  initialize ws to null

  options
     prompt line last,
     insert key f1,
  -- delete key control-y
    delete key f2

  if not get_niv_mod(g_issk.prgsgl, "ctc74m00") then
     error " Modulo sem nivel de consulta e atualizacao!"
     return
  end if

  open window w_ctc74m00 at 05,02 with form "ctc74m00"
     attribute(form line first, comment line last - 2) 
  
  display by name param.srrcoddig
  display by name param.srrnom
  
  if g_issk.acsnivcod  <  g_issk.acsnivatl   then
     message " (F17)Abandona"
  else
     message " (F1)Inclui, (F5)Exclui, (F6)Modifica, (F17)Abandona"
  end if

  call ctc74m00_prepare()

  while true

     call ctc74m00_carrega_array(param.srrcoddig, param.srrnom)

     call ctc74m00_entra_dados(param.srrcoddig, param.srrnom)

     if m_sair = true then
        exit while
     end if

  end while

  options
     delete key f2

  close window w_ctc74m00

  let int_flag = false

end function

#-------------------------#
function ctc74m00_prepare()
#-------------------------#

  define l_sql char(500)
  
  let l_sql = " select a.socntzcod, ",
                     " c.socntzdes, ",
                     " a.espcod, ",
                     " a.atldat, ",
                     " b.funnom ",
                " from dbsrntzpstesp a, ",
                     " outer isskfunc b, ",
                     " datksocntz    c ",
               " where a.srrcoddig = ? ",
                 " and a.funmat = b.funmat ",
                 " and a.usrtip = b.usrtip ",
                 " and a.empcod = b.empcod ",
                 " and a.socntzcod = c.socntzcod ",
                 " and c.socntzstt = 'A' ",
               " order by 1 "

  prepare pctc74m00002 from l_sql
  declare cctc74m00002 cursor for pctc74m00002

  #Inserção do registro
  let l_sql = " insert into dbsrntzpstesp (srrcoddig, socntzcod, espcod, ",
                                         " atldat, funmat, usrtip, empcod) ",
                                 " values (?,?,?, today, ?, ?, ? ) "

  prepare pctc74m00003 from l_sql

  #Seleção da descricao da especialidade
  let l_sql = " select espdes ",
                " from dbskesp ",
               " where espcod = ? "

  prepare pctc74m00005 from l_sql
  declare cctc74m00005 cursor for pctc74m00005

  #Seleção da descrição da natureza
  let l_sql = "select socntzdes from datksocntz where socntzcod = ?"

  prepare pctc74m00006 from l_sql
  declare cctc74m00006 cursor for pctc74m00006

  #Deleção de registro
  let l_sql = " delete from dbsrntzpstesp ",
                    " where srrcoddig = ? ",
                      " and socntzcod = ? "

  prepare pctc74m00007 from l_sql

  #Identifica se registro ja existe
  let l_sql = " select socntzcod, ",
                     " espcod ",
                " from dbsrntzpstesp ",
               " where srrcoddig = ? ",
                 " and socntzcod = ? ",
                 " and espcod = ? "

  prepare pctc74m00009 from l_sql
  declare cctc74m00009 cursor for pctc74m00009

  let l_sql = " select 1 ",
                " from dbsrntzpstesp ",
               " where socntzcod = ? ",
                 " and srrcoddig = ? ",
                 " and espcod = ? "

  prepare pctc74m00010 from l_sql
  declare cctc74m00010 cursor for pctc74m00010

 let m_prep_sql = true

end function

#------------------------------------#
function ctc74m00_carrega_array(param)
#------------------------------------#

  define param    record
      srrcoddig   like datksrr.srrcoddig,
      srrnom      like datksrr.srrnom
  end record

 define l_status       smallint
      , l_mensagem     char(100)
      , l_null         char(01)
      , l_codigo       like datksocntz.socntzcod

  if m_prep_sql is null or m_prep_sql <> true then
     call ctc74m00_prepare()
  end if

  initialize am_ctc74m00 to null

  let m_contador = 1

  open cctc74m00002 using param.srrcoddig

  foreach cctc74m00002 into am_ctc74m00[m_contador].socntzcod,
                            am_ctc74m00[m_contador].socntzdes,
                            am_ctc74m00[m_contador].espcod,
                            am_ctc74m00[m_contador].atldat,
                            am_ctc74m00[m_contador].funnom

        call ctc16m03_inf_natureza(am_ctc74m00[m_contador].socntzcod,'A')
             returning l_status, l_mensagem, l_null, l_codigo

        if  l_codigo = 1 then # Linha Branca
            open cctc74m00005 using am_ctc74m00[m_contador].espcod
            fetch cctc74m00005 into am_ctc74m00[m_contador].espdes
            close cctc74m00005
        else
            let am_ctc74m00[m_contador].espcod = 1
            let am_ctc74m00[m_contador].espdes = ""
        end if

     let m_contador = m_contador + 1

     if m_contador > 100 then
        error "O limite de 100 registros foi ultrapassado. AVISE A INFORMATICA !" sleep 3
        exit foreach
     end if

  end foreach
  
  close cctc74m00002

 #let m_contador = m_contador - 1

end function

#----------------------------------#
function ctc74m00_entra_dados(param)
#----------------------------------#

  define param           record
         srrcoddig       like datksrr.srrcoddig,
         srrnom          like datksrr.srrnom
  end record

  define ws              record
         socntzcod       like datksocntz.socntzcod,
         clscod          like datrsocntzsrvre.clscod,
         sta             smallint,
         mensagem        char(100),
         socntzdes       like datksocntz.socntzdes,
         codigo          like datksocntz.socntzcod,
         erro            smallint,
         funnom          char(100),
         espcod          like dbskesp.espcod,
         espdes          like dbskesp.espdes,
         cod             smallint
  end record

  define l_operacao      char(01),
         l_arr           smallint,
         l_scr           smallint,
         l_codigo        smallint,
         l_resposta      char(01),
         l_situacao_ant  char(01),
         l_descricao_ant char(01),
         l_cod_ant       smallint,
         l_espcod        smallint,
         l_nulo          char(004),
         l_msg           char(800),
         l_espdes        char(50),
         l_socntzdes     char(50),
         l_data          date

 define l_sucesso        smallint
 define l_mensagem       char(100)
 define l_erro           smallint
 define l_mesg           char(2000)
 define l_status         smallint
      , l_null           char(01)

  let l_operacao       = null
  let l_arr            = null
  let l_scr            = null
  let l_codigo         = null
  let l_msg            = null
  let l_resposta       = null
  let l_situacao_ant   = null
  let l_descricao_ant  = null
  let l_cod_ant        = null
  let l_espcod         = null
  let l_nulo           = null
  let l_espdes         = null
  let l_socntzdes      = null
  let l_data           = null
  let l_sucesso        = null
  let l_data           = today
  let l_sucesso        = true
  let espcod_ant       = null
  let espdes_ant       = null

  initialize ws to null

  let int_flag = false

  let l_operacao = " "

  let m_sair = false

  call set_count(m_contador)
  
     
 #---------------------------------------------------------------
 # Nivel de acesso apenas para consulta
 #---------------------------------------------------------------
 call set_count(m_contador-1)
 
 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display array am_ctc74m00 to s_ctc74m00.*
 
       on key (control-c, f17, interrupt)
          display "350 - on key (control-c, f17, interrupt)"
          initialize am_ctc74m00  to null
          let m_sair = true
          exit display 
    end display
 end if

 #---------------------------------------------------------------
 # Nivel de acesso para consulta/atualizacao
 #---------------------------------------------------------------
 while true
 
    if g_issk.acsnivcod  <  g_issk.acsnivatl   then
       exit while
    end if

     input array am_ctc74m00 without defaults from s_ctc74m00.*

         before row
           let l_arr = arr_curr()
           let l_scr = scr_line()

        before field navega
           if l_operacao = "I" then
              next field socntzcod
           end if

        after field navega

            if fgl_lastkey() = 2014 then
              let l_operacao = "I"
           else
              if fgl_lastkey() = fgl_keyval("down") then
                 if am_ctc74m00[l_arr + 1].socntzcod is null then
                    next field navega
                 else
                    continue input
                 end if
              end if

              if fgl_lastkey() = 2005 or    ## f3
                 fgl_lastkey() = 2006 then  ## f4
                 continue input
              end if

              if fgl_lastkey() = fgl_keyval("up") then
                 continue input
              else
                 next field navega
              end if

           end if

        before field socntzcod

        display am_ctc74m00[l_arr].socntzcod to s_ctc74m00[l_scr].socntzcod attribute(reverse)

        if l_operacao = "A" then
              display am_ctc74m00[l_arr].socntzcod to s_ctc74m00[l_scr].socntzcod
        end if

        after field socntzcod
           display am_ctc74m00[l_arr].socntzcod to s_ctc74m00[l_scr].socntzcod

        if l_operacao = "I" then
                if am_ctc74m00[l_arr].socntzcod is null then
                        error "Codigo nao pode ser nulo"
                        call cts12g00 (1, l_nulo, l_nulo, l_nulo, l_nulo, l_nulo, l_nulo, l_nulo)
                        returning ws.socntzcod, ws.clscod
                        if ws.socntzcod is not null then

                                open cctc74m00009 using param.srrcoddig,  am_ctc74m00[l_arr].socntzcod, am_ctc74m00[l_arr].espcod
                                fetch cctc74m00009 into ws.cod
                                close cctc74m00009

                                if ws.cod is null then
                                        let am_ctc74m00[l_arr].socntzcod = ws.socntzcod
                                        display am_ctc74m00[l_arr].socntzcod to s_ctc74m00[l_scr].socntzcod
                                        open cctc74m00006 using ws.socntzcod
                                                whenever error continue
                                                        fetch cctc74m00006 into l_socntzdes
                                                whenever error stop
                                        if sqlca.sqlcode <> 0 then
                                                error "Erro Select cctc73m00006 " sleep 3
                                        end if

                                        close cctc74m00006

                                        let am_ctc74m00[l_arr].socntzdes = l_socntzdes
                                        display am_ctc74m00[l_arr].socntzdes to s_ctc74m00[l_scr].socntzdes
                                else
                                        error "Codigo ja existente !"
                                        let ws.cod = null
                                        let am_ctc74m00[l_arr].socntzcod = null
                                        next field socntzcod
                                end if
                        else
                                continue input
                                next field espcod
                        end if
                else

                        open cctc74m00009 using param.srrcoddig, am_ctc74m00[l_arr].socntzcod, am_ctc74m00[l_arr].espcod
                        fetch cctc74m00009 into ws.cod
                        close cctc74m00009
                        if ws.cod is null then
                                open cctc74m00006 using am_ctc74m00[l_arr].socntzcod
                                        whenever error continue
                                                fetch cctc74m00006 into l_socntzdes
                                        whenever error stop
                                        if sqlca.sqlcode <> 0 then
                                                error "Codigo nao encontrado !"
                                                close cctc74m00006
                                                next field socntzcod
                                        end if
                                        close cctc74m00006
                                        let am_ctc74m00[l_arr].socntzdes = l_socntzdes
                                        display am_ctc74m00[l_arr].socntzdes to s_ctc74m00[l_scr].socntzdes
                        else
                                error "Codigo ja existente !"
                                let ws.cod = null
                                let am_ctc74m00[l_arr].socntzcod = null
                                next field socntzcod
                        end if
                end if
          end if

        next field espcod

        before field espcod
           call ctc16m03_inf_natureza(am_ctc74m00[l_arr].socntzcod,'A')
                returning l_status, l_mensagem, l_null, l_codigo

           if  l_codigo = 1 then # Linha Branca
                display am_ctc74m00[l_arr].espcod to s_ctc74m00[l_scr].espcod attribute(reverse)
           else
                let am_ctc74m00[l_arr].espcod = null
                display am_ctc74m00[l_arr].espcod to s_ctc74m00[l_scr].espcod
                let am_ctc74m00[l_arr].espcod = 1
                let am_ctc74m00[l_arr].espdes = ""
                display am_ctc74m00[l_arr].espdes to s_ctc74m00[l_scr].espdes
                next field atldat
           end if



        after field espcod
           display am_ctc74m00[l_arr].espcod to s_ctc74m00[l_scr].espcod

           if fgl_lastkey() = fgl_keyval("up") or
              fgl_lastkey() = fgl_keyval("down") or
              fgl_lastkey() = fgl_keyval("left") then
              next field espcod
           end if

           if am_ctc74m00[l_arr].espcod is null or
              am_ctc74m00[l_arr].espcod = " " then

              call ctc75m00()
                   returning am_ctc74m00[l_arr].espcod,
                             am_ctc74m00[l_arr].espdes

              if am_ctc74m00[l_arr].espcod is null or
                 am_ctc74m00[l_arr].espcod =  " " then
                 error "Informe o codigo da especialidade"
                 let am_ctc74m00[l_arr].espcod = null
                 next field espcod
              end if

           end if

           open cctc74m00010 using am_ctc74m00[l_arr].socntzcod,
                                   param.srrcoddig,
                                   am_ctc74m00[l_arr].espcod

           whenever error continue
           fetch cctc74m00010
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode <> notfound then
                 error "Erro SELECT cctc74m00010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
                 next field espcod
              end if
           else
              error "O Socorrista ja possui esta natureza cadastrada, verifique !"
              let am_ctc74m00[l_arr].espcod = null
              next field espcod
           end if

           close cctc74m00010

           open cctc74m00005 using am_ctc74m00[l_arr].espcod
           whenever error continue
           fetch cctc74m00005 into am_ctc74m00[l_arr].espdes
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode <> notfound then
                 error "Codigo nao encontrado !"
                 next field espcod
              end if
           end if

           close cctc74m00005

           display am_ctc74m00[l_arr].espcod to s_ctc74m00[l_scr].espcod
           display am_ctc74m00[l_arr].espdes to s_ctc74m00[l_scr].espdes

           next field atldat

        before field espdes
          display am_ctc74m00[l_arr].espdes to s_ctc74m00[l_scr].espdes attribute(reverse)

        after field espdes
           display am_ctc74m00[l_arr].espdes to s_ctc74m00[l_scr].espdes

           if fgl_lastkey() = fgl_keyval("left") then
                next field espcod
           end if

           if fgl_lastkey() = fgl_keyval("up") or
              fgl_lastkey() = fgl_keyval("down") then
              next field atldat
           end if

           if am_ctc74m00[l_arr].espdes is null then
                open cctc74m00005 using am_ctc74m00[l_arr].espcod
                whenever error continue
                fetch cctc74m00005 into l_espdes
                whenever error stop

                if sqlca.sqlcode <> 0 then
                   if sqlca.sqlcode = notfound then
                      let am_ctc74m00[l_arr].espcod = null
                      next field espcod
                   else
                      error "Erro Select cctc73m00004 " sleep 3
                   end if
                end if

                close cctc74m00005
                let am_ctc74m00[l_arr].espdes = l_espdes
                display am_ctc74m00[l_arr].espdes to s_ctc74m00[l_scr].espdes
           end if

           next field atldat

           before field atldat
                display am_ctc74m00[l_arr].atldat to s_ctc74m00[l_scr].atldat

                if am_ctc74m00[l_arr].atldat is null then
                   let am_ctc74m00[l_arr].atldat = l_data
                   display am_ctc74m00[l_arr].atldat to s_ctc74m00[l_scr].atldat
                end if

                next field funnom

           after field atldat
                display am_ctc74m00[l_arr].atldat to s_ctc74m00[l_scr].atldat

                if fgl_lastkey() = fgl_keyval("left") then
                        next field espdes
                end if

                if fgl_lastkey() = fgl_keyval("up") or
                        fgl_lastkey() = fgl_keyval("down") then
                        next field espdes
                end if



           before field funnom
                display am_ctc74m00[l_arr].funnom to s_ctc74m00[l_scr].funnom

                if am_ctc74m00[l_arr].funnom is null then
                        call cty08g00_nome_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)
                        returning ws.erro, ws.mensagem, ws.funnom
                        let am_ctc74m00[l_arr].funnom = ws.funnom
                        display am_ctc74m00[l_arr].funnom to s_ctc74m00[l_scr].funnom

                end if

           after field funnom
                display am_ctc74m00[l_arr].funnom to s_ctc74m00[l_scr].funnom

                if fgl_lastkey() = fgl_keyval("left") then
                   next field atldat
                end if

                if fgl_lastkey() = fgl_keyval("up") or
                   fgl_lastkey() = fgl_keyval("down") then
                   next field atldat
                end if

        while true

              if l_operacao = "I" then
                 prompt "Confirma a inclusao do registro ? (S/N): " for l_resposta
              end if

              if l_operacao = "A" then
                 prompt "Confirma a alteracao do registro ? (S/N): " for l_resposta
              end if

              let l_resposta = upshift(l_resposta)

              if l_resposta = "S" or l_resposta = "N" or int_flag then
                 exit while
              end if

       end while

           if int_flag then
              let int_flag = true
              let l_resposta = "N"
           end if

           if l_resposta = "S" then
              if l_operacao = "I" then
                        whenever error continue 
                                execute pctc74m00003 using param.srrcoddig,
                                                am_ctc74m00[l_arr].socntzcod,
                                                am_ctc74m00[l_arr].espcod,
                                                g_issk.funmat,
                                                g_issk.usrtip,
                                                g_issk.empcod
                        whenever error stop
                        if sqlca.sqlcode <> 0 then
                                error "Erro INSERT pctc73m00003 " sleep 3
                                let int_flag = true
                                exit input
                        else
                                error "Registro incluido com sucesso !" sleep 1
                        end if

                        #-------------------------------------------------------------
                        # SE O DEPARTAMENTO FOR CT24HS ENVIA E-MAIL PARA PORTO SOCORRO
                        #-------------------------------------------------------------
                        if g_issk.dptsgl = "ct24hs" or
                           g_issk.dptsgl = "tlprod" or
                           g_issk.dptsgl = "dsvatd" then
                           let l_msg = "Socorrista...: ",
                                       param.srrcoddig using "<<<<<<<&",
                                       " - ", param.srrnom clipped, ascii(13),
                                       "Natureza.....: ",
                                       am_ctc74m00[l_arr].socntzcod using "<<<<&", " - ",
                                       am_ctc74m00[l_arr].socntzdes clipped, ascii(13),
                                       "Especialidade: ",
                                       am_ctc74m00[l_arr].espcod using "<<<<&", " - ",
                                       am_ctc74m00[l_arr].espdes

                           call cts20g08("NATUREZAS DO SOCORRISTA", # NOME DO CADASTRO
                                         "Inclusao",                # TIPO DA OPERACAO
                                         "CTC74M00",                # NOME DO 4GL
                                         g_issk.empcod,
                                         g_issk.usrtip,
                                         g_issk.funmat,
                                         l_msg clipped)

                        end if
                        let l_mensagem = 'Inclusao no cadastro do socorrista. Codigo : ',
		                              param.srrcoddig using "<<<<<<<&"
                        let l_mesg = "Natureza  [" clipped, am_ctc74m00[l_arr].socntzcod clipped,
                                  " - ",am_ctc74m00[l_arr].socntzdes clipped,"] Incluida !"

		        let l_erro =  ctc44m00_grava_hist(param.srrcoddig
                                                         ,l_mesg
                                                         ,today
                                                        ,l_mensagem,"I")
              end if

              if l_operacao = "A" then
                whenever error continue

                execute pctc74m00007 using  param.srrcoddig,
                                am_ctc74m00[l_arr].socntzcod

                whenever error stop
                if sqlca.sqlcode <> 0 then
                        error "Erro Delete pctc74m00007 " sleep 3
                        let int_flag = true
                        exit input
                end if

                #-------------------------------------------------------------
                # SE O DEPARTAMENTO FOR CT24HS ENVIA E-MAIL PARA PORTO SOCORRO
                #-------------------------------------------------------------
                if g_issk.dptsgl = "ct24hs" or
                   g_issk.dptsgl = "tlprod" or
                   g_issk.dptsgl = "dsvatd" then
                   let l_msg = "Socorrista...: ",
                               param.srrcoddig using "<<<<<<<&",
                               " - ", param.srrnom clipped, ascii(13),
                               "Natureza.....: ",
                               am_ctc74m00[l_arr].socntzcod using "<<<<&", " - ",
                               am_ctc74m00[l_arr].socntzdes clipped, ascii(13),
                               "Especialidade: ",
                               espcod_ant using "<<<<&", " - ",
                               espdes_ant

                   call cts20g08("NATUREZAS DO SOCORRISTA", # NOME DO CADASTRO
                                 "Exclusao",                # TIPO DA OPERACAO
                                 "CTC74M00",                # NOME DO 4GL
                                 g_issk.empcod,
                                 g_issk.usrtip,
                                 g_issk.funmat,
                                 l_msg clipped)

                end if

                let l_mensagem = 'Exclusao no cadastro do socorrista. Codigo : ',
		                 param.srrcoddig using "<<<<<<<&"
                let l_mesg = "Natureza  [" clipped, am_ctc74m00[l_arr].socntzcod clipped,
                                  " - ",am_ctc74m00[l_arr].socntzdes clipped,"] Excluida !"

		let l_erro =  ctc44m00_grava_hist(param.srrcoddig
                                                 ,l_mesg
                                                 ,today
                                                 ,l_mensagem,"I")

                whenever error continue
                execute pctc74m00003 using param.srrcoddig,
                                am_ctc74m00[l_arr].socntzcod,
                                am_ctc74m00[l_arr].espcod,
                                g_issk.funmat,
                                g_issk.usrtip,
                                g_issk.empcod

                whenever error stop
                if sqlca.sqlcode <> 0 then
                        error "Erro INSERT pctc73m00003 " sleep 3
                        let int_flag = true
                        exit input
                else
                        error "Registro alterado com sucesso !" sleep 1
                end if

                #-------------------------------------------------------------
                # SE O DEPARTAMENTO FOR CT24HS ENVIA E-MAIL PARA PORTO SOCORRO
                #-------------------------------------------------------------
                if g_issk.dptsgl = "ct24hs" or
                   g_issk.dptsgl = "tlprod" or
                   g_issk.dptsgl = "dsvatd" then
                   let l_msg = "Socorrista...: ",
                               param.srrcoddig using "<<<<<<<&",
                               " - ", param.srrnom clipped, ascii(13),
                               "Natureza.....: ",
                               am_ctc74m00[l_arr].socntzcod using "<<<<&", " - ",
                               am_ctc74m00[l_arr].socntzdes clipped, ascii(13),
                               "Especialidade: ",
                               am_ctc74m00[l_arr].espcod using "<<<<&", " - ",
                               am_ctc74m00[l_arr].espdes

                   call cts20g08("NATUREZAS DO SOCORRISTA", # NOME DO CADASTRO
                                 "Inclusao",                # TIPO DA OPERACAO
                                 "CTC74M00",                # NOME DO 4GL
                                 g_issk.empcod,
                                 g_issk.usrtip,
                                 g_issk.funmat,
                                 l_msg clipped)


                end if
                let l_mensagem = 'Inclusao  no cadastro do socorrista. Codigo : ',
                                     param.srrcoddig using "<<<<<<<&"
                let l_mesg = "Natureza [" clipped, am_ctc74m00[l_arr].socntzcod clipped,
                                " - ",am_ctc74m00[l_arr].socntzdes clipped,"] Inclusao !"

		let l_erro =  ctc44m00_grava_hist(param.srrcoddig
                                                 ,l_mesg
                                                 ,today
                                                 ,l_mensagem,"I")
            end if

           else
              if l_operacao = "I" then
                 let am_ctc74m00[l_arr].espcod = espcod_ant
                 let am_ctc74m00[l_arr].espdes = espdes_ant
                 call ctc74m00_deleta_linha(l_arr, l_scr)
              else
                 let am_ctc74m00[l_arr].espcod = espcod_ant
                 let am_ctc74m00[l_arr].espdes = espdes_ant
                 call ctc74m00_deleta_linha(l_arr, l_scr)
              end if
           end if

           let l_operacao = " "
           message " (F1)Inclui, (F5)Exclui, (F6)Modifica, (F17)Abandona"
           next field navega

        on key (F5)

          while true
             prompt "Confirma a exclusao ? (S/N): " for l_resposta

             let l_resposta = upshift(l_resposta)

             if l_resposta = "S" or l_resposta = "N" or int_flag then
                exit while
             else
                error "Digite (S)SIM ou (N)NAO"
             end if

          end while

          if int_flag then
             let l_resposta = "N"
             let int_flag = false
          end if

         if upshift(l_resposta) = "S" then
         whenever error continue
                execute pctc74m00007 using param.srrcoddig,
                                am_ctc74m00[l_arr].socntzcod

         whenever error stop
                if sqlca.sqlcode <> 0 then
                        error "Erro DELETE pctc73m00007 " sleep 3
                else
                   #-------------------------------------------------------------
                   # SE O DEPARTAMENTO FOR CT24HS ENVIA E-MAIL PARA PORTO SOCORRO
                   #-------------------------------------------------------------
                   if g_issk.dptsgl = "ct24hs" or
                      g_issk.dptsgl = "tlprod" or
                      g_issk.dptsgl = "dsvatd" then
                      let l_msg = "Socorrista...: ",
                                  param.srrcoddig using "<<<<<<<&",
                                  " - ", param.srrnom clipped, ascii(13),
                                  "Natureza.....: ",
                                  am_ctc74m00[l_arr].socntzcod using "<<<<&", " - ",
                                  am_ctc74m00[l_arr].socntzdes clipped, ascii(13),
                                  "Especialidade: ",
                                  am_ctc74m00[l_arr].espcod using "<<<<&", " - ",
                                  am_ctc74m00[l_arr].espdes

                      call cts20g08("NATUREZAS DO SOCORRISTA", # NOME DO CADASTRO
                                    "Exclusao",                # TIPO DA OPERACAO
                                    "CTC74M00",                # NOME DO 4GL
                                    g_issk.empcod,
                                    g_issk.usrtip,
                                    g_issk.funmat,
                                    l_msg clipped)

                   end if
                   let l_mensagem = 'Exclusao no cadastro do socorrista. Codigo : ',
		                       param.srrcoddig
                   let l_mesg = "Natureza [" clipped, am_ctc74m00[l_arr].socntzcod clipped,
                                  " - ",am_ctc74m00[l_arr].socntzdes clipped,"]  Excluida !"

 		   let l_erro =  ctc44m00_grava_hist(param.srrcoddig
                                                    ,l_mesg
                                                    ,today
                                                    ,l_mensagem,"I")

                   error "Registro excluido com sucesso !" sleep 1
                   call ctc74m00_deleta_linha(l_arr,l_scr)

                end if

          let m_contador = arr_count()
	  message " (F1)Inclui, (F5)Exclui, (F6)Modifica, (F17)Abandona"
          exit input

          else
             error "Delecao cancelada !" sleep 1
          end if

       on key (f6)
          if l_operacao = "I" or
             l_operacao = "A" or
             l_operacao = "E" then
             error "F6 nao pode ser teclada neste momento ! "
          else
             let l_operacao = "A"
             let espcod_ant = am_ctc74m00[l_arr].espcod
             let espdes_ant = am_ctc74m00[l_arr].espdes
             let l_descricao_ant = am_ctc74m00[l_arr].espdes
             let am_ctc74m00[l_arr].espcod = null
             let am_ctc74m00[l_arr].espdes = null
             display am_ctc74m00[l_arr].espcod to s_ctc74m00[l_scr].espcod
             display am_ctc74m00[l_arr].espdes to s_ctc74m00[l_scr].espdes
             next field espcod
          end if

       on key (control-c, f17, interrupt)
          initialize am_ctc74m00 to null
          let int_flag = true
          let m_sair = true
          let m_contador = 0
          exit input

     end input

     if int_flag then
        exit while
    end if

  end while

end function

#------------------------------------------#
function ctc74m00_deleta_linha(l_arr, l_scr)
#------------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_cont  =  null

  for l_cont = l_arr to 99
     if am_ctc74m00[l_arr].espcod is not null then
        let am_ctc74m00[l_cont].* = am_ctc74m00[l_cont + 1].*
     else
        initialize am_ctc74m00[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 8
     display am_ctc74m00[l_arr].espcod    to s_ctc74m00[l_cont].espcod
     display am_ctc74m00[l_arr].espdes    to s_ctc74m00[l_cont].espdes
     let l_arr = l_arr + 1
  end for

end function

#----------------------------------------------#
function ctc74m00_executa_operacao(lr_parametro)
#----------------------------------------------#

  define lr_parametro  record
         tipo_operacao char(01),
         srrcoddig     smallint,
         socntzcod  smallint,
         espcod        smallint,
         funmat        smallint,
         espcod_ant    smallint
  end record

  define l_sucesso     smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sucesso  =  null

  let l_sucesso = true

  case lr_parametro.tipo_operacao

     when "A" # --ALTERACAO

whenever error continue

        execute pctc74m00007 using  lr_parametro.srrcoddig,
                                lr_parametro.socntzcod

        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro Delete pctc74m00007 " sleep 3
           let l_sucesso = false
        end if

        whenever error continue
                execute pctc74m00003 using lr_parametro.srrcoddig,
                                lr_parametro.socntzcod,
                                lr_parametro.espcod,
                                g_issk.funmat,
                                g_issk.usrtip,
                                g_issk.empcod

                whenever error stop

                if sqlca.sqlcode <> 0 then
                        error "Erro INSERT pctc73m00003 " sleep 3
                        let l_sucesso = false
                end if

     when "I" # --INCLUSAO
                whenever error continue
                execute pctc74m00003 using lr_parametro.srrcoddig,
                                lr_parametro.socntzcod,
                                lr_parametro.espcod,
                                g_issk.funmat,
                                g_issk.usrtip,
                                g_issk.empcod

                whenever error stop

                if sqlca.sqlcode <> 0 then
                        error "Erro INSERT pctc73m00003 " sleep 3
                        let l_sucesso = false
                end if


     when "E" # --EXCLUSAO

        whenever error continue
        execute pctc74m00007 using lr_parametro.srrcoddig,
                                lr_parametro.socntzcod


        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro DELETE pctc73m00007 " sleep 3
           let l_sucesso = false
        end if

  end case

  return l_sucesso

end function
