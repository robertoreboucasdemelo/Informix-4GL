###############################################################################
# Nome do Modulo: ctc73m00                                     Cristiane Silva#
#                                                                             #
# Cadastro de Especialidades Porto Socorro                           Out/2005 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 17/08/2008  PSI 221635   Fabio Costa  Adicionar descricao WEB               #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint

  define am_ctc73m00  array[50] of record
         navega    char(01),
         espcod    smallint,
         espdes    char(20),
         webespdes char(60),
         espsit    char(01)
  end record

  define m_contador smallint

#--------------#
function ctc73m00()
#--------------#
  define l_sucesso     smallint

  let l_sucesso = true

  options
     prompt line last,
     insert key f1
     
  if m_prep_sql is null or m_prep_sql <> true then
   call ctc73m00_prepare()
  end if
  
  open window w_ctc73m00 at 7,2 with form "ctc73m00"
     attributes(form line 1)

  call ctc73m00_carrega_array()
  
  call ctc73m00_entra_dados()
  
  let int_flag = false
  
end function

#----------------------#
function ctc73m00_prepare()
#----------------------#

  define l_sql char(300)

  let m_prep_sql = false
  {
  create temp table array_tmp (espcod       smallint,
                               espdes       char(20),
                               espsit       char(01),
                               webespdes    char(60) ) with no log
  }
  let l_sql = " select espcod, espdes, webespdes, espsit ",
              " from dbskesp order by 1 "
  prepare pctc73m00001 from l_sql
  declare cctc73m00001 cursor for pctc73m00001
  
  let l_sql = " insert into dbskesp(espcod, espdes, espsit, atldat, funmat, ",
              "                     webespdes )",
              " values (?,?,?, today,?,? ) "
  prepare pctc73m00002 from l_sql
  
  let l_sql = " update dbskesp set (espdes, espsit, webespdes) = (?,?,?) ",
              " where espcod = ? "
  prepare pctc73m00003 from l_sql
  
  let l_sql = " select max(espcod) from dbskesp "
  prepare pctc73m00004 from l_sql
  declare cctc73m00004 cursor for pctc73m00004

  let m_prep_sql = true

end function

#----------------------------#
function ctc73m00_carrega_array()
#----------------------------#

  initialize am_ctc73m00 to null

  let m_contador = 1

  open cctc73m00001

  foreach cctc73m00001 into am_ctc73m00[m_contador].espcod,
                            am_ctc73m00[m_contador].espdes,
                            am_ctc73m00[m_contador].webespdes,
                            am_ctc73m00[m_contador].espsit

     let m_contador = m_contador + 1

     if m_contador = 51 then
        error "O limite de 50 registros foi ultrapassado"
        sleep 2
        exit foreach
     end if

  end foreach
  
  let m_contador = m_contador - 1

end function

#--------------------------#
function ctc73m00_entra_dados()
#--------------------------#

  define l_operacao      char(01),
         l_arr           smallint,
         l_scr           smallint,
         l_codigo        smallint,
         l_resposta      char(01),
         l_situacao_ant  char(01),
         l_descricao_ant char(01),
         l_espcod	       smallint

  let l_arr           = null
  let l_situacao_ant  = null
  let l_descricao_ant = null
  let l_scr           = null
  let l_resposta      = null

  let int_flag = false

  let l_operacao = " "

  call set_count(m_contador)

  while true

     input array am_ctc73m00 without defaults from s_ctc73m00.*

        before row
           let l_arr = arr_curr()
           let l_scr = scr_line()

        before field navega
           if l_operacao = "I" then
              next field espcod
           end if

        after field navega
           if fgl_lastkey() = 2014 then
              let l_operacao = "I"
           else
              if fgl_lastkey() = fgl_keyval('down') then
                 if am_ctc73m00[l_arr + 1].espcod is null then
                    next field navega
                 else
                    continue input
                 end if
              end if

              if fgl_lastkey() = 2005 or    ## f3
                 fgl_lastkey() = 2006 then  ## f4
                 continue input
              end if

              if fgl_lastkey() = fgl_keyval('up') then
                 continue input
              else
                 next field navega
              end if
           end if

        before field espcod
           display am_ctc73m00[l_arr].espcod to s_ctc73m00[l_scr].espcod 
           attribute(reverse)

           if l_operacao = "A" then
              display am_ctc73m00[l_arr].espcod to s_ctc73m00[l_scr].espcod
           end if

           if l_operacao = "I" then
           
              open cctc73m00004
              whenever error continue
              fetch cctc73m00004 into l_espcod
              whenever error stop
              
              if sqlca.sqlcode <> 0 then
                  error "Erro Select cctc73m00004 " sleep 3
              end if
              
              if l_espcod is null or l_espcod = 0 then
                 let l_espcod = 1
              else
                 let l_espcod = l_espcod + 1
              end if
              
              let am_ctc73m00[l_arr].espcod = l_espcod
              display am_ctc73m00[l_arr].espcod to s_ctc73m00[l_scr].espcod
              
           end if

           next field espdes

        after field espcod
           display am_ctc73m00[l_arr].espcod to s_ctc73m00[l_scr].espcod

           if am_ctc73m00[l_arr].espcod is null then
              error "Codigo nao pode ser nulo"
              next field espcod
           end if

           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = fgl_keyval('down') then
              next field espcod
           end if

        before field espdes
           display am_ctc73m00[l_arr].espdes to s_ctc73m00[l_scr].espdes 
           attribute(reverse)

        after field espdes
           display am_ctc73m00[l_arr].espdes to s_ctc73m00[l_scr].espdes

           if am_ctc73m00[l_arr].espdes is null then
              error "Descricao nao pode ser nula" sleep 2
              next field espdes
           end if

           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = fgl_keyval('down') then
              next field espdes
           end if
           
        before field webespdes
           display am_ctc73m00[l_arr].webespdes to s_ctc73m00[l_scr].webespdes 
           attribute(reverse)
           
        after field webespdes
           display am_ctc73m00[l_arr].webespdes to s_ctc73m00[l_scr].webespdes 
           
        before field espsit
           display am_ctc73m00[l_arr].espsit to s_ctc73m00[l_scr].espsit 
           attribute(reverse)

        after field espsit
           display am_ctc73m00[l_arr].espsit to s_ctc73m00[l_scr].espsit

           if fgl_lastkey() = fgl_keyval('left') then
              next field espdes
           end if

           if fgl_lastkey() = fgl_keyval('up') or
              fgl_lastkey() = fgl_keyval('down') then
              next field espsit
           end if


           if am_ctc73m00[l_arr].espsit is null or
              am_ctc73m00[l_arr].espsit = " " then
              error "Descricao nao pode ser nula" sleep 2
              next field espsit
           end if

           if am_ctc73m00[l_arr].espsit <> "C" and
              am_ctc73m00[l_arr].espsit <> "A" then
              error "Digite A-Ativo ou C-Cancelado"
              next field espsit
           end if

           while true
              if l_operacao = "I" then
                 prompt 'Confirma inclusao do registro? (S/N)' for l_resposta
              else
                 prompt 'Confirma alteracao do registro? (S/N)' for l_resposta
              end if

              let l_resposta = upshift(l_resposta)

              if l_resposta = 'S' or l_resposta = 'N' or int_flag then
                 exit while
              end if
           end while

           if int_flag then
              let int_flag = true
              let l_resposta = "N"
           end if

           if l_resposta = "S" then
              if l_operacao = "I" then
                 if ctc73m00_executa_operacao("I",
                                           am_ctc73m00[l_arr].espcod,
                                           am_ctc73m00[l_arr].espdes,
                                           am_ctc73m00[l_arr].espsit,
                                           am_ctc73m00[l_arr].webespdes ) then
                    error "Registro incluido com sucesso" 
                    sleep 2
                 else
                    let int_flag = true
                    exit input
                 end if
              else
                 if ctc73m00_executa_operacao("A",
                                           am_ctc73m00[l_arr].espcod,
                                           am_ctc73m00[l_arr].espdes,
                                           am_ctc73m00[l_arr].espsit,
                                           am_ctc73m00[l_arr].webespdes ) then
                    error "Registro alterado com sucesso" 
                    sleep 2
                 else
                    let int_flag = true
                    exit input
                 end if
              end if
           else
              if l_operacao = "I" then
                 call ctc73m00_deleta_linha(l_arr, l_scr)
              else
                 let am_ctc73m00[l_arr].espdes = l_descricao_ant
                 let am_ctc73m00[l_arr].espsit  = l_situacao_ant

                 display am_ctc73m00[l_arr].espdes to s_ctc73m00[l_scr].espdes
                 display am_ctc73m00[l_arr].espsit to s_ctc73m00[l_scr].espsit

              end if
           end if

           let l_operacao = " "

           next field navega

           
       on key(f6)
          if l_operacao = "I" or
             l_operacao = "A" then
             error "F6 nao pode ser teclada neste momento "
          else
             let l_operacao = "A"
             let l_descricao_ant = am_ctc73m00[l_arr].espdes
             let l_situacao_ant = am_ctc73m00[l_arr].espsit
             next field espdes
          end if
          
       on key (control-c, f17, interrupt)
          initialize am_ctc73m00[l_arr].* to null
          let int_flag = true
          let m_contador = 0
          exit input

     end input

     if int_flag then
        close window w_ctc73m00
        exit while
     end if

  end while

end function

#---------------------------------------#
function ctc73m00_deleta_linha(l_arr, l_scr)
#---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint
         
  for l_cont = l_arr to 49
     if am_ctc73m00[l_arr].espcod is not null then
        let am_ctc73m00[l_cont].* = am_ctc73m00[l_cont + 1].*
     else
        initialize am_ctc73m00[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 6
     display am_ctc73m00[l_arr].espcod    to s_ctc73m00[l_cont].espcod
     display am_ctc73m00[l_arr].espdes    to s_ctc73m00[l_cont].espdes
     display am_ctc73m00[l_arr].webespdes to s_ctc73m00[l_cont].webespdes
     display am_ctc73m00[l_arr].espsit    to s_ctc73m00[l_cont].espsit
     let l_arr = l_arr + 1
  end for

end function

#-------------------------------------------#
function ctc73m00_executa_operacao(lr_parametro)
#-------------------------------------------#

  define lr_parametro  record
         tipo_operacao char(01),
         espcod        smallint,
         espdes        char(20),
         espsit        char(01),
         webespdes     char(60)
  end record

  define l_sucesso     smallint
  define l_espcod      smallint

  let l_sucesso = true

  case lr_parametro.tipo_operacao

     when "A" # --ALTERACAO

        whenever error continue
        execute pctc73m00003 using lr_parametro.espdes,
                                   lr_parametro.espsit,
                                   lr_parametro.webespdes,
                                   lr_parametro.espcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro UPDATE pctc73m00003 " sleep 3
           let l_sucesso = false
        end if

     when "I" # --INCLUSAO

        whenever error continue
        execute pctc73m00002 using lr_parametro.espcod,
                                   lr_parametro.espdes,
                                   lr_parametro.espsit,
                                   g_issk.funmat,
                                   lr_parametro.webespdes
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro INSERT pctc73m00002 " sleep 3
           let l_sucesso = false
        end if

  end case

  return l_sucesso

end function
                                                               