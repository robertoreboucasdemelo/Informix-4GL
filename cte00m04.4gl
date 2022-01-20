#-----------------------------------------------------------------------------#
#                                 PORTO SEGURO                                #
#.............................................................................#
#                                                                             #
#  Modulo              : cte00m04                                             #
#  Analista Responsavel: Ligia Mattge                                         #
#  PSI/OSF             : 170178/18902 - Cadastro das acoes.                   #
#                                                                             #
#.............................................................................#
#                                                                             #
#  Desenvolvimento     : Fabrica de Software - Gustavo Bayarri                #
#  Data                : 20/05/2003                                           #
#-----------------------------------------------------------------------------#

#globals "/homedsa/fontes/ct24h/producao/glct.4gl"
globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_dackaca     array[50]  of record
       coracacod     like dackaca.coracacod
      ,coracades     like dackaca.coracades
      ,ghost         char(01)
end record

define m_aux         array[50]  of record
       coracacod     like dackaca.coracacod
end record

define m_del         array[50]  of record
       corasscod     like dackaca.corasscod
      ,coracacod     like dackaca.coracacod
end record

define m_isskfunc      record
       tecmat          char(06)
      ,tecnom          like isskfunc.funnom
      ,anlmat          char(06)
      ,anlnom          like isskfunc.funnom
end record

define m_d           smallint
      ,m_corasscod   like dackaca.corasscod
      ,m_tecmat_ant  like isskfunc.funmat
      ,m_anlmat_ant  like isskfunc.funmat
      ,m_operacao    char(01)
      ,m_conv_cod    like datkgeral.grlchv

#---------------------------------------------------------------
function cte00m04(l_corasscod)
#---------------------------------------------------------------

  define l_corasscod     like dackaca.corasscod

  define l_comando       char(500)
        ,l_pri_vez       smallint
        ,l_tecmat        like isskfunc.funmat
        ,l_anlmat        like isskfunc.funmat
        ,l_auxiliar      char(12)

  #################
  #### PREPARE ####
  #################

  let l_comando = "select coracacod, coracades      "
                 ,"from dackaca                     "
                 ,"where corasscod = ?              "
                 ,"order by coracacod               "

  prepare pcte00m04001 from l_comando
  declare ccte00m04001 cursor for pcte00m04001

  let l_comando = "select rowid                     "
                 ,"from dackaca                     "
                 ,"where corasscod = ?              "
                 ,"  and coracacod = ?              "

  prepare pcte00m04002 from l_comando
  declare ccte00m04002 cursor for pcte00m04002

  let l_comando = "insert into dackaca (corasscod,  "
                 ,"coracacod, coracades)            "
                 ,"values(?, ?, ?)                  "

  prepare pcte00m04003 from l_comando

  let l_comando = "select funnom                    "
                 ,"from isskfunc                    "
                 ,"where empcod = 1                 "
                 ,"  and usrtip = 'F'               "
                 ,"  and funmat = ?                 "

  prepare pcte00m04004 from l_comando
  declare ccte00m04003 cursor for pcte00m04004

  let l_comando = "insert into datkgeral (grlchv,   "
                 ,"grlinf, atldat, atlhor, atlemp,  "
                 ,"atlmat)                          "
                 ,"values(?, ?, ?, ?, ?, ?)         "

  prepare pcte00m04005 from l_comando

  let l_comando = "update datkgeral set grlinf = ?  "
                 ,"                    ,atldat = ?  "
                 ,"                    ,atlhor = ?  "
                 ,"                    ,atlemp = ?  "
                 ,"                    ,atlmat = ?  "
                 ,"where grlchv = ?                 "

  prepare pcte00m04006 from l_comando

  let l_comando = "select grlinf[01,12]             "
                 ,"from datkgeral                   "
                 ,"where grlchv = ?                 "

  prepare pcte00m04007 from l_comando
  declare ccte00m04004 cursor for pcte00m04007

  let l_comando = "delete from dackaca              "
                 ,"where corasscod = ?              "
                 ,"  and coracacod = ?              "

  prepare pcte00m04008 from l_comando

  let l_comando = "update dackaca set coracacod = ? "
                 ,"                  ,coracades = ? "
                 ,"where corasscod = ?              "
                 ,"  and coracacod = ?              "

  prepare pcte00m04009 from l_comando

  let l_comando = "select grlinf[07,12]             "
                 ,"from datkgeral                   "
                 ,"where grlchv = ?                 "

  prepare pcte00m04010 from l_comando
  declare ccte00m04005 cursor for pcte00m04010

  #####################
  #### FIM PREPARE ####
  #####################

  initialize m_dackaca to null
  initialize m_del     to null
  initialize m_aux     to null

  let m_corasscod  = l_corasscod
  let m_tecmat_ant = null
  let m_anlmat_ant = null
  let m_operacao   = 'T'
  let l_pri_vez    = true

  open window w_cte00m04 at 06,02 with form "cte00m04"
       attribute(form line 1)

  input by name m_isskfunc.tecmat
               ,m_isskfunc.anlmat without defaults

     before field tecmat
        display by name m_isskfunc.tecmat attribute (reverse)

        let m_conv_cod        = m_corasscod

        let l_auxiliar        = null
        let m_isskfunc.tecmat = null
        open  ccte00m04004 using m_conv_cod
        whenever error continue
        fetch ccte00m04004 into  l_auxiliar
        whenever error stop

        if sqlca.sqlcode    <> 0 then
           if sqlca.sqlcode <  0 then
              error "Nao acessou codigo acao p/ a Matricula do Coord. Tecnico,"
                   ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                   ,sqlca.sqlerrd[2], " )"
              close ccte00m04004
              return
           end if
        end if
        close ccte00m04004

        let m_isskfunc.tecmat = l_auxiliar[01,06]
        let m_tecmat_ant      = m_isskfunc.tecmat
        let m_isskfunc.tecnom = null
        open  ccte00m04003 using m_tecmat_ant
        whenever error continue
        fetch ccte00m04003 into  m_isskfunc.tecnom
        whenever error stop

        if sqlca.sqlcode    <> 0 then
           if sqlca.sqlcode <  0 then
              error " Nao foi possivel acessar a Matricula do Coord. Tecnico,"
                   ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                   ,sqlca.sqlerrd[2], " )"
              close ccte00m04003
              return
           end if
        else
           display by name m_isskfunc.tecmat
           display by name m_isskfunc.tecnom
        end if

        let m_isskfunc.anlmat = l_auxiliar[07,12]
        let l_anlmat          = m_isskfunc.anlmat
        let m_isskfunc.anlnom = null
        open  ccte00m04003 using l_anlmat
        whenever error continue
        fetch ccte00m04003 into  m_isskfunc.anlnom
        whenever error stop

        if sqlca.sqlcode    <> 0 then
           if sqlca.sqlcode <  0 then
              error " Nao foi possivel acessar a Matricula do Coord. Analise,"
                   ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                   ,sqlca.sqlerrd[2], " )"
              close ccte00m04003
              return
           end if
        else
           display by name m_isskfunc.anlmat
           display by name m_isskfunc.anlnom
        end if

        if l_pri_vez then
           call cte00m04_array(l_pri_vez)
           let l_pri_vez = false
           next field tecmat
        end if

     after field tecmat
        display by name m_isskfunc.tecmat

        if fgl_lastkey() = fgl_keyval('left') then
           next field tecmat
        end if

        let l_tecmat          = m_isskfunc.tecmat
        let m_isskfunc.tecnom = null

        if l_tecmat is not null and
           l_tecmat <> "000000" then

           open  ccte00m04003 using l_tecmat
           whenever error continue
           fetch ccte00m04003 into  m_isskfunc.tecnom
           whenever error stop

           if sqlca.sqlcode    <> 0 then
              if sqlca.sqlcode <  0 then
                 error " Nao foi possivel acessar a Matricula do Coord. Tecnico"
                      ,", (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                      ,sqlca.sqlerrd[2], " )"
                 close ccte00m04003
                 return
              end if
              close ccte00m04003
              error "Nome do Coordenador Tecnico nao encontrado!"
              next field tecmat
           end if
           close ccte00m04003
        end if

        display by name m_isskfunc.tecnom

     before field anlmat
        display by name m_isskfunc.anlmat attribute (reverse)

        let m_conv_cod        = m_corasscod

        let m_isskfunc.anlmat = null
        open  ccte00m04005 using m_conv_cod
        whenever error continue
        fetch ccte00m04005 into  m_isskfunc.anlmat
        whenever error stop

        if sqlca.sqlcode    <> 0 then
           if sqlca.sqlcode <  0 then
              error "Nao acessou codigo acao p/ a Matricula do Coord. Analise,"
                   ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                   ,sqlca.sqlerrd[2], " )"
              close ccte00m04005
              return
           end if
        end if
        close ccte00m04005

        let m_anlmat_ant      = m_isskfunc.anlmat
        let m_isskfunc.anlnom = null
        open  ccte00m04003 using m_anlmat_ant
        whenever error continue
        fetch ccte00m04003 into  m_isskfunc.anlnom
        whenever error stop

        if sqlca.sqlcode    <> 0 then
           if sqlca.sqlcode <  0 then
              error " Nao foi possivel acessar a Matricula do Coord. Analise,"
                   ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                   ,sqlca.sqlerrd[2], " )"
              close ccte00m04003
              return
           end if
        else
           display by name m_isskfunc.anlmat
           display by name m_isskfunc.anlnom
        end if
        close ccte00m04003

     after field anlmat
        display by name m_isskfunc.anlmat

        if fgl_lastkey() = fgl_keyval('left') then
           next field anlmat
        end if

        let l_anlmat          = m_isskfunc.anlmat
        let m_isskfunc.anlnom = null

        if l_anlmat is not null and
           l_anlmat <> "000000" then
           open  ccte00m04003 using l_anlmat
           whenever error continue
           fetch ccte00m04003 into  m_isskfunc.anlnom
           whenever error stop

           if sqlca.sqlcode    <> 0 then
              if sqlca.sqlcode <  0 then
                 error " Nao foi possivel acessar a Matricula do Coord. Analise"
                      ,", (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                      ,sqlca.sqlerrd[2], " )"
                 close ccte00m04003
                 return
              end if
              close ccte00m04003
              error "Nome do Coordenador Analise nao encontrado!"
              next field anlmat
           end if
           close ccte00m04003
        end if

        display by name m_isskfunc.anlnom
        call cte00m04_array(l_pri_vez)
        next field tecmat

     on key (interrupt, control-c)
        let int_flag = true
        exit input

  end input

  if int_flag then
     let int_flag = false
     close window w_cte00m04
  end if

end function

#---------------------------------------------------------------
function cte00m04_array(l_par_in)
#---------------------------------------------------------------

  define l_par_in         record
         privez           smallint
  end record

  define l_arr            smallint
        ,l_arr_aux        integer
        ,l_scr_aux        integer
        ,l_aux_coracacod  like dackaca.coracacod
        ,l_rowid          smallint
        ,l_today          date
        ,l_current        datetime hour to second
        ,l_coracades      like dackaca.coracades
        ,l_k              integer
        ,l_grlinf         like datkgeral.grlinf

  let l_arr = 1
  let m_d   = 0
  open    ccte00m04001 using m_corasscod
  foreach ccte00m04001 into  m_dackaca[l_arr].coracacod
                            ,m_dackaca[l_arr].coracades

     let m_dackaca[l_arr].ghost = 'T'
     let l_arr = l_arr + 1

     if l_arr > 50 then
        error "Limite excedido, avise a informatica! "
        exit foreach
     end if

  end foreach

  call set_count(l_arr - 1)

  while not int_flag
     input array m_dackaca without defaults from s_cte00m04.*

        before row
           if l_par_in.privez then
              exit input
           end if
           let l_arr_aux = arr_curr()
           let l_scr_aux = scr_line()

        before insert
           let l_arr_aux                  = arr_curr()
           let l_scr_aux                  = scr_line()
           let m_operacao                 = "I"
           let m_dackaca[l_arr_aux].ghost = "N"

        before delete
           let m_d = m_d + 1
           let m_del[m_d].corasscod = m_corasscod
           let m_del[m_d].coracacod = m_dackaca[l_arr_aux].coracacod
           let m_operacao = 'D'

           if l_arr_aux < arr_count() then
              for l_k = l_arr_aux to (arr_count()-1)
                  let m_aux[l_k].* = m_aux[l_k + 1].*
              end for
           end if
           let  l_k = arr_count()
           initialize m_aux[l_k].* to null

        before field coracacod
           display m_dackaca[l_arr_aux].coracacod to
                   s_cte00m04[l_scr_aux].coracacod attribute (reverse)
           let l_aux_coracacod = m_dackaca[l_arr_aux].coracacod

        after  field coracacod
           display m_dackaca[l_arr_aux].coracacod to
                   s_cte00m04[l_scr_aux].coracacod

           if fgl_lastkey() = fgl_keyval('left') then
              next field coracacod
           end if

           let l_rowid = fgl_lastkey()

           if fgl_lastkey() <> fgl_keyval('up')   and
              fgl_lastkey() <> fgl_keyval('left') and
              fgl_lastkey() <> fgl_keyval('down') then

              let l_k = 0
              for l_k = 1 to arr_count()
                  if m_dackaca[l_arr_aux].coracacod=m_dackaca[l_k].coracacod and
                     l_k <> l_arr_aux then
                     let m_dackaca[l_arr_aux].coracacod = l_aux_coracacod
                     error "Nao cadastrar codigo acao para o "
                          ,"mesmo codigo assunto!"
                     next field coracacod
                  end if
              end for
              if l_aux_coracacod is not null                       and
                 l_aux_coracacod <> m_dackaca[l_arr_aux].coracacod and
                 m_dackaca[l_arr_aux].ghost <> "N"                 then
                 let m_operacao                     = 'A'
                 let m_dackaca[l_arr_aux].ghost     = "M"

                 if  m_aux[l_arr_aux].coracacod is not null then
                     let m_aux[l_arr_aux].coracacod = l_aux_coracacod
                 end if

                 if m_dackaca[l_arr_aux].coracacod is null then
                    error "Codigo invalido"
                    next field coracacod
                 end if

                 open  ccte00m04002 using m_corasscod
                                         ,m_dackaca[l_arr_aux].coracacod
                 whenever error continue
                 fetch ccte00m04002
                 whenever error stop

                 if sqlca.sqlcode    = 0 then
                    close ccte00m04002
                    error "Nao cadastrar codigo acao para o "
                         ,"mesmo codigo assunto!"
                    next field coracacod
                 else
                    if sqlca.sqlcode <  0 then
                       error "Nao foi possivel acessar a tabela de acao -> "
                            ,m_dackaca[l_arr_aux].coracacod
                            ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                            ,sqlca.sqlerrd[2], " )"
                       close ccte00m04002
                       next field coracacod
                    end if
                    close ccte00m04002
                 end if
                 display m_dackaca[l_arr_aux].coracacod to
                         s_cte00m04[l_scr_aux].coracacod
              else
                 if l_rowid = 2014 then
                 else
                    next field coracades
                 end if
              end if
           else
              if m_dackaca[l_arr_aux].coracacod is null then
                 if m_dackaca[l_arr_aux].ghost = "N"  and
                    fgl_lastkey() = fgl_keyval('up')  then
                    display  m_dackaca[l_arr_aux].* to s_cte00m04[l_scr_aux].*
                    continue input
                 end if
                 error "Codigo invalido"
                 next field coracacod
              end if
           end if

        before field coracades
           let l_coracades = m_dackaca[l_arr_aux].coracades
           display m_dackaca[l_arr_aux].coracades to
                   s_cte00m04[l_scr_aux].coracades attribute (reverse)

        after  field coracades
           display m_dackaca[l_arr_aux].coracades to
                   s_cte00m04[l_scr_aux].coracades

           if fgl_lastkey() <> fgl_keyval('up')   and
              fgl_lastkey() <> fgl_keyval('left') and
              fgl_lastkey() <> fgl_keyval('down') then

              if m_dackaca[l_arr_aux].coracades is null or
                 m_dackaca[l_arr_aux].coracades = " "   then
                 error"Descricao invalida."
                 next field coracades
              end if

              if m_dackaca[l_arr_aux].ghost     <> "N"         and
                 m_dackaca[l_arr_aux].coracades <> l_coracades then
                 let m_operacao                 = 'A'
                 let m_dackaca[l_arr_aux].ghost = "M"
                 let m_aux[l_arr_aux].coracacod = l_aux_coracacod
              end if
           else
              if fgl_lastkey() <> fgl_keyval('left')  and
                 fgl_lastkey() <> fgl_keyval('right') then
                 next field coracades
              end if
              display  m_dackaca[l_arr_aux].* to s_cte00m04[l_scr_aux].*
           end if

        on key (f8)

           let l_today          = today
           let l_current        = current

           if m_isskfunc.tecmat is null then
              let m_isskfunc.tecmat = "000000"
           end if

           if m_isskfunc.anlmat is null then
              let m_isskfunc.anlmat = "000000"
           end if

           let l_grlinf[01,06]  = m_isskfunc.tecmat
           let l_grlinf[07,12]  = m_isskfunc.anlmat
           if (m_tecmat_ant is not null           and
               m_tecmat_ant <> m_isskfunc.tecmat) or
              (m_anlmat_ant is not null           and
               m_anlmat_ant <> m_isskfunc.anlmat) then

              begin work
              whenever error continue
              execute pcte00m04006 using l_grlinf
                                        ,l_today
                                        ,l_current
                                        ,g_issk.empcod
                                        ,g_issk.funmat
                                        ,m_conv_cod
              whenever error stop

              if sqlca.sqlcode <> 0 then
                 error "Problema na alteracao na tabela DATKGERAL,"
                      ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                      ,sqlca.sqlerrd[2], " )"
                 rollback work
                 exit input
              end if
              commit work
           else
              if m_tecmat_ant is null or
                 m_anlmat_ant is null then

                 begin work
                 whenever error continue
                 execute pcte00m04005 using m_conv_cod
                                           ,l_grlinf
                                           ,l_today
                                           ,l_current
                                           ,g_issk.empcod
                                           ,g_issk.funmat
                 whenever error stop

                 if sqlca.sqlcode <> 0 then
                    error "Problema na inclusao na tabela DATKGERAL,"
                         ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                         ,sqlca.sqlerrd[2], " )"
                    rollback work
                    exit input
                 end if
                 commit work
              end if
           end if

           if m_operacao = 'I' or
              m_operacao = 'A' or
              m_operacao = 'D' then
              call cte00m04_atualiza(arr_count())
           end if

           initialize m_aux to null

           display m_dackaca[l_arr_aux].coracacod to
                   s_cte00m04[l_scr_aux].coracacod

           let m_operacao = 'T'
           let int_flag   = true
           exit input

        on key (interrupt, control-c)
           display m_dackaca[l_arr_aux].coracacod to
                   s_cte00m04[l_scr_aux].coracacod

           display m_dackaca[l_arr_aux].coracades to
                   s_cte00m04[l_scr_aux].coracades
           exit input

     end input

     if l_par_in.privez then
        exit while
     end if

  end while

  if int_flag then
     let int_flag = false
  end if

end function

#-----------------------------------
function cte00m04_atualiza(l_linhas)
#-----------------------------------

define l_linhas smallint
      ,l_men    char(100)
      ,l_result smallint
      ,l_i      integer

  let l_result = 0

  begin work

  if m_d > 0 and l_result = 0 then
     for l_i = 1 to m_d
         whenever error continue
         execute pcte00m04008 using m_del[l_i].corasscod
                                   ,m_del[l_i].coracacod
         whenever error stop

         if sqlca.sqlcode <> 0 then
            let l_men ="Problemas na Exclusao de DACKACA,"
                       ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                       ,sqlca.sqlerrd[2], " )"
            let l_result = 1
            exit for
         end if
     end for
  end if

  if l_result = 0 then
  for l_i = 1 to l_linhas
      if m_dackaca[l_i].coracacod is not null then
         if m_dackaca[l_i].ghost = 'M' then
            whenever error continue
            execute pcte00m04009 using m_dackaca[l_i].coracacod
                                      ,m_dackaca[l_i].coracades
                                      ,m_corasscod
                                      ,m_aux[l_i].coracacod
            whenever error stop

            if sqlca.sqlcode <> 0 then
               let l_men = "Problemas na Atualizacao de DACKACA,"
                          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                          ,sqlca.sqlerrd[2], " )"
               let l_result = 1
               exit for
            end if
         end if
         if m_dackaca[l_i].ghost = 'N' then
            whenever error continue
            execute pcte00m04003 using m_corasscod
                                      ,m_dackaca[l_i].coracacod
                                      ,m_dackaca[l_i].coracades
            whenever error stop
            if sqlca.sqlcode <> 0 then
               let l_men = "Problemas na Inclusao de DACKACA,"
                          ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ", "
                          ,sqlca.sqlerrd[2], " )"
               let l_result = 1
               exit for
            end if
         end if
      end if
  end for
  end if

  if l_result = 1 then
     error l_men
     sleep 2
     Rollback work
  else
     commit work
  end if

end function
