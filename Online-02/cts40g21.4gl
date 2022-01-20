#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS40G21                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTO.                      #
#                  DESBLOQUEIA OS SERVICOS QUE FICARAM BLOQUEADOS.            #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 06/07/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 28/01/2009 Adriano Santos  PSI235849  Considerar serviço SINISTRO RE        #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g21_prep smallint

#-------------------------#
function cts40g21_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = null

  let l_sql = " select atdsrvnum, ",
                     " atdsrvano, ",
                     " c24opemat ",
                " from datmservico ",
               " where atdsrvorg in (9,13) ", # PSI 235849 Adriano Santos 28/01/2009
                 " and atdfnlflg = 'A' ",
                 " and atdlibflg = 'S' "

  prepare pcts40g21001 from l_sql
  declare ccts40g21001 cursor for pcts40g21001

  let l_sql = " select atdsrvnum, ",
                     " atdsrvano, ",
                     " c24opemat ",
                " from datmservico ",
               " where atdsrvorg in (1,2,3,4,5,6,7,17) ",
                 " and atdfnlflg = 'A' ",
                 " and atdlibflg = 'S' "

  prepare pcts40g21002 from l_sql
  declare ccts40g21002 cursor for pcts40g21002

  let l_sql = " update datmservico ",
                 " set c24opemat = ? ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare pcts40g21003 from l_sql

  let m_cts40g21_prep = true

end function

#------------------------#
function cts40g21(l_batch)
#------------------------#

  define l_batch     char(04), # RE -> bdbsa068   AUTO -> bdbsa069
         l_cont      smallint,
         l_i         smallint,
         l_c24opemat like datmservico.c24opemat,
         l_matricula like datmservico.c24opemat,
         l_msg_erro  char(80)

  define al_array    array[2000] of record
         atdsrvnum   like datmservico.atdsrvnum,
         atdsrvano   like datmservico.atdsrvano
  end record

  if m_cts40g21_prep is null or
     m_cts40g21_prep <> true then
     call cts40g21_prepare()
  end if

  let l_cont      = null
  let l_i         = null
  let l_c24opemat = null
  let l_msg_erro  = null
  let l_matricula = null

  for l_i = 1 to 2000
     let al_array[l_i].atdsrvnum = null
     let al_array[l_i].atdsrvano = null
  end for

  let l_i = 1

  case l_batch

     when("RE")
        open ccts40g21001
        foreach ccts40g21001 into al_array[l_i].atdsrvnum,
                                  al_array[l_i].atdsrvano,
                                  l_matricula

           if l_matricula = 999999 then
              let l_i = (l_i + 1)

              if l_i > 2000 then
                 exit foreach
              end if
           end if

        end foreach
        close ccts40g21001

     when("AUTO")
        open ccts40g21002
        foreach ccts40g21002 into al_array[l_i].atdsrvnum,
                                  al_array[l_i].atdsrvano,
                                  l_matricula

        if l_matricula = 999999 then
           let l_i = (l_i + 1)

           if l_i > 2000 then
              exit foreach
           end if
        end if

        end foreach
        close ccts40g21002

  end case

  let l_i = (l_i - 1)

  for l_cont = 1 to l_i
     whenever error continue
     execute pcts40g21003 using l_c24opemat,
                                al_array[l_i].atdsrvnum,
                                al_array[l_i].atdsrvano
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let l_msg_erro = "Erro UPDATE pcts40g21003 /", sqlca.sqlcode, "/",
                                                       sqlca.sqlerrd[2]
        call errorlog(l_msg_erro)
        let l_msg_erro = "CTS40G21()/", al_array[l_i].atdsrvnum, "/",
                                        al_array[l_i].atdsrvano
        call errorlog(l_msg_erro)
        exit for
     else
        call cts00g07_apos_servdesbloqueia(al_array[l_i].atdsrvnum,al_array[l_i].atdsrvano)
     end if
  end for

end function
