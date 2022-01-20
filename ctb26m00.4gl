#----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: CTB26M00.4GL                                              #
# ANALISTA RESP..: CARLOS ZYON                                               #
# PSI/OSF........: 185.035 / 36870                                           #
# OBJETIVO.......: INTERFACE DE PARAMETRIZACAO DE EMAIL.                     #
#............................................................................#
# DESENVOLVIMENTO: META, BRUNO GAMA                                          #
# LIBERACAO......: 28/06/2004                                                #
#............................................................................#
#                                                                            #
#                        * * *  ALTERACOES  * * *                            #
#                                                                            #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                        #
# ----------  -------------   ------------  -------------------------------- #
#                                                                            #
# -------------------------------------------------------------------------- #

globals '/homedsa/projetos/geral/globals/glct.4gl'

 define am_ctb26m00     array[500] of record
    codigo              like datkgeral.grlchv
   ,descricao           like datkgeral.grlinf
 end record

 define am_array     array[100] of record
    relpamseq        like igbmparam.relpamseq
   ,relpamtxt        like igbmparam.relpamtxt
   ,relpamtip        like igbmparam.relpamtip
 end record

 define m_prep_sql      smallint
 define m_arr           smallint

#=============================================================================
 function ctb26m00_prepare()
#=============================================================================

 define l_sql           char(500)

    let l_sql = " select grlchv "
               ,"      , grlinf "
               ,"   from datkgeral "
               ,"  where grlchv[1,6] = ? "
    prepare pctb26m00001 from l_sql
    declare cctb26m00001 cursor for pctb26m00001

    let l_sql = " select relpamseq "
               ,"      , relpamtxt "
               ,"      , relpamtip "
               ,"   from igbmparam "
               ,"  where relsgl = ? "
               ,"  order by 1 "
    prepare pctb26m00002 from l_sql
    declare cctb26m00002 cursor for pctb26m00002

    let l_sql = " select max(relpamseq) "
               ,"   from igbmparam "
               ,"  where relsgl = ? "
    prepare pctb26m00003 from l_sql
    declare cctb26m00003 cursor for pctb26m00003

    let l_sql = " insert into igbmparam "
               ,"      ( relsgl,    relpamseq, "
               ,"        relpamtxt, relpamtip ) "
               ," values ( ? , ?, ?, 0) "
    prepare pctb26m00004 from l_sql

    let l_sql = " delete from igbmparam "
               ,"  where relsgl = ? "
               ,"    and relpamseq = ? "
    prepare pctb26m00005 from l_sql

    let l_sql = " update igbmparam "
               ,"    set relpamtxt = ? "
               ,"  where relsgl = ? "
               ,"    and relpamseq = ? "
    prepare pctb26m00006 from l_sql

    let l_sql = " select grlchv, ",
                       " grlinf ",
                  " from datkgeral ",
                 " where grlchv[1,6] = 'C24REL' ",
                    " or grlchv[1,6] = 'PSOREL' "
    prepare pctb26m00007 from l_sql
    declare cctb26m00007 cursor for pctb26m00007

 let m_prep_sql = true

 end function

#=============================================================================
 function ctb26m00()
#=============================================================================

 define lr_ctb26m00 record
   rotina           char(100)
 end record

 define l_flag      smallint
 define l_chave     char(10)

 initialize lr_ctb26m00.* to null
 initialize am_ctb26m00 to null
 let l_flag = false
 let m_arr  = 1

 if m_prep_sql <> true or m_prep_sql is null then
    call ctb26m00_prepare()
 end if

 open window w_ctb26m00 at 2,2 with form "ctb26m00"
    attribute(prompt line last,border)

 input by name lr_ctb26m00.* without defaults

    before field rotina
       let l_flag = ctb26m00_popup()

       if l_flag <> true then
          display am_ctb26m00[m_arr].descricao to rotina
          let l_chave = am_ctb26m00[m_arr].codigo
       end if

       exit input

    on key(F17,control-c,interrupt)
       let l_flag = true
       exit input

 end input

 if l_flag = true then
    error 'Nenhuma Rotina/Relatorio selecionada' sleep 2
 else
    call ctb26m00_array(l_chave)
 end if

 options  delete key F2

 let int_flag = false
 close window w_ctb26m00

 end function

#=============================================================================
 function ctb26m00_popup()
#=============================================================================

 define l_flag         smallint
 define l_cont         smallint
 define l_executa_sql  smallint
 define l_chave        like datkgeral.grlchv
 define l_grlchv       like datkgeral.grlchv

 let l_flag        = false
 let l_cont        = 1
 let l_chave       = null
 let l_grlchv      = null
 let l_executa_sql = true

 #-----------------------------------------------------
 # VERIFICA O DEPARTAMENTO E SELECIONA A CHAVE CORRETA
 #-----------------------------------------------------

 case g_issk.dptsgl

    when("ct24hs") # CENTRAL 24 HORAS
       let l_grlchv = "C24REL"
       if g_issk.funmat = 13851 then # matricula da Rosana
          let l_grlchv = null
          let l_executa_sql = false
          foreach cctb26m00007 into l_chave, am_ctb26m00[l_cont].descricao
             let am_ctb26m00[l_cont].codigo = l_chave[8,15]
             let l_cont = l_cont + 1
             if l_cont > 500 then
                error 'Limite de Array excedido !!' sleep 2
                exit foreach
             end if
          end foreach
       end if

    when("psocor") # PORTO SOCORRO
       let l_grlchv = "PSOREL"

    when("desenv") # DESENVOLVIMENTO
       let l_executa_sql = false
       open cctb26m00007
       foreach cctb26m00007 into l_chave, am_ctb26m00[l_cont].descricao
          let am_ctb26m00[l_cont].codigo = l_chave[8,15]
          let l_cont = l_cont + 1
          if l_cont > 500 then
             error 'Limite de Array excedido !!' sleep 2
             exit foreach
          end if
       end foreach

 end case

 if l_executa_sql then

    open cctb26m00001 using l_grlchv

    foreach cctb26m00001 into l_chave
                             ,am_ctb26m00[l_cont].descricao

       let am_ctb26m00[l_cont].codigo = l_chave[8,15]

       let l_cont = l_cont + 1

       if l_cont > 500 then
          error 'Limite de Array excedido !!' sleep 2
          exit foreach
       end if

    end foreach

 end if

 call set_count(l_cont -1)

 if l_cont > 0 then

    open window w_ctb26m00a at 4,13 with form "ctb26m00a"

    display array am_ctb26m00 to s_ctb26m00a.*

       on key (F8)
         let m_arr = arr_curr()
         let int_flag = false
         exit display

       on key(F17,control-c,interrupt)
         let int_flag = true
         exit display

    end display

    let int_flag = false
    close window w_ctb26m00a
 else
    error 'Nenhum registro encontrado em DATKGERAL' sleep 2
    let l_flag = true
 end if

 return l_flag

 end function

#=============================================================================
 function ctb26m00_array(l_param)
#=============================================================================

 define l_param      char(10)
 define l_cont       smallint
 define l_arr        smallint
 define l_scr        smallint
 define l_resp       char(01)
 define l_opcao      char(01)
 define l_seq        smallint
 define l_email_aux  like igbmparam.relpamtxt

 initialize am_array to null
 let l_cont      = 1
 let l_opcao     = " "
 let l_email_aux = null
 let int_flag    = false

 open cctb26m00002 using l_param

 foreach cctb26m00002 into am_array[l_cont].relpamseq
                          ,am_array[l_cont].relpamtxt
                          ,am_array[l_cont].relpamtip

     let l_cont = l_cont + 1

     if l_cont > 100 then
        error 'Limite de Array excedido !!' sleep 2
        exit foreach
     end if

 end foreach

 options  delete key control-p

 let l_cont = l_cont - 1

 if l_cont = 0 then
    while true
       prompt "Nao ha cadastro para esse codigo. Deseja Incluir ? (S/N) " for l_resp

       if upshift(l_resp) <> "N" and
          upshift(l_resp) <> "S" then
          continue while
       else
          exit while
       end if
    end while

    if upshift(l_resp) = "N" then
       return
    end if

    let l_opcao = "I"

 end if

 call set_count(l_cont)

 while true

 let int_flag = false

 input array am_array without defaults from s_ctb26m00.*

       before row
         let l_arr  = arr_curr()
         let l_scr  = scr_line()

       before insert
         let l_opcao = "I"

       before field seq
         if l_opcao = "I" then
            open cctb26m00003 using l_param
            whenever error continue
            fetch cctb26m00003 into l_seq
            whenever error stop
            if sqlca.sqlcode <> 0 then
               error 'Erro de SQL - cctb26m00003 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
               error 'ctb26m00_array()/',l_param sleep 2
               let int_flag = true
               exit input
            end if

            if l_seq is null then
               let l_seq = 0
            end if

            let am_array[l_arr].relpamseq = l_seq + 1
            display am_array[l_arr].relpamseq to s_ctb26m00[l_scr].seq
         end if

       before field email
            if l_opcao <> "I" then
               let l_email_aux = am_array[l_arr].relpamtxt
            end if

       after field email

            if (am_array[l_arr].relpamtxt is null or
                am_array[l_arr].relpamtxt = " ") and
                am_array[l_arr].relpamseq is not null then
               error 'Campo nao pode ser nulo' sleep 2
               next field email
            end if

            if (fgl_lastkey() = fgl_keyval("down") or
                fgl_lastkey() = fgl_keyval("left")) and
               (am_array[l_arr].relpamtxt is null or
                am_array[l_arr].relpamtxt = " ") and
                am_array[l_arr + 1].relpamseq is null then
                let int_flag = false
                exit input
            end if

            if l_opcao = "I" then
               if not ctb26m00_verifica_email(l_arr) then
                  error 'Email incorreto' sleep 2
                  next field email
               end if

               whenever error continue
               execute pctb26m00004 using l_param
                                         ,am_array[l_arr].relpamseq
                                         ,am_array[l_arr].relpamtxt
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error 'Erro de SQL - pctb26m00004 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                  error 'ctb26m00_array()/',l_param sleep 2
                  let int_flag = true
                  exit input
               else
                  error 'Email cadastrado com sucesso !' sleep 2
               end if
               let l_opcao = " "
               let int_flag = false
               exit input
            else
               if am_array[l_arr].relpamtxt <> l_email_aux then
                  whenever error continue
                  execute pctb26m00006 using am_array[l_arr].relpamtxt
                                            ,l_param
                                            ,am_array[l_arr].relpamseq
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     error 'Erro de SQL - pctb26m00006 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                     error 'ctb26m00_array()/',l_param sleep 2
                     let int_flag = true
                     exit input
                  end if
               end if
            end if

       on key(F2)

          display am_array[l_arr].* to s_ctb26m00[l_scr].*

          if am_array[l_arr].relpamseq is not null then
             prompt "Confirma remocao da linha ? (S/N) " for l_resp
             if upshift(l_resp) = 'S' then
                whenever error continue
                execute pctb26m00005  using l_param
                                           ,am_array[l_arr].relpamseq
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   error 'Erro DELETE igbmparam ',sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 2
                   error 'ctb26m00_array()/',am_array[l_arr].relpamseq sleep 2
                   let int_flag = true
                   exit input
                end if
                call ctb26m00_dellinha(l_arr, l_scr)
             end if
          end if


       on key(F17,control-c,interrupt)
          if l_opcao = "I" then
             error 'Inclusao cancelada' sleep 2
          end if
          let int_flag = true
          exit input

 end input

 if int_flag = true then
    exit while
 end if

 end while

 end function

#==============================================================================
 function ctb26m00_dellinha(l_arr, l_scr)
#==============================================================================

 define l_arr        smallint
 define l_scr        smallint
 define l_cont       smallint

   for l_cont = l_arr to 99
      if am_array[l_arr].relpamseq is not null then
         let am_array[l_cont].* = am_array[l_cont + 1].*
      else
         initialize am_array[l_cont].* to null
      end if
   end for

   for l_cont = l_scr to 10
      display am_array[l_arr].relpamseq  to s_ctb26m00[l_cont].seq
      display am_array[l_arr].relpamtxt  to s_ctb26m00[l_cont].email
      display am_array[l_arr].relpamtip  to s_ctb26m00[l_cont].tipo
      let l_arr = l_arr + 1
   end for

   let l_arr = l_arr - 1

 end function

#==============================================================================
 function ctb26m00_verifica_email(l_arr)
#==============================================================================

    define l_cont    smallint
          ,l_email   char(050)
          ,l_flag    smallint
          ,l_arr     smallint

    let l_flag  = false
    let l_email = am_array[l_arr].relpamtxt

    for l_cont = 1 to length(l_email)
        if l_email[l_cont] = ' ' then
           let l_flag = false
           exit for
        else
           if l_email[l_cont] = '@' then
              let l_flag = true
           end if
        end if
    end for

    if l_flag = true then
       return true
    end if

    return false

 end function


