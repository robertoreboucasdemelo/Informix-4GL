#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: CTC79M00                                                   #
# ANALISTA RESP..: CARLOS ALBERTO RODRIGUES                                   #
# PSI/OSF........: 198714 - CADASTRO DE EXCECOES DE VEICULOS POR GUINCHO      #
#                  MANUTENCAO DO CADASTRO DE CATEGORIAS TARIFARIAS            #
# ........................................................................... #
# DESENVOLVIMENTO: ALBERTO RODRIGUES / LUCAS SCHEID                           #
# LIBERACAO......:                                                            #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     atlERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

 define am_array     array[20] of record
        soceqpcod    like datkvcleqp.soceqpcod ,
        soceqpdes    like datkvcleqp.soceqpdes ,
        caddat       like datrvclexcgch.caddat ,
        cadmat       like datrvclexcgch.cadmat ,
        funnom_cad   char(20)
 end record

 define m_prep_sql      smallint
 define m_arr           smallint
 define m_cont          smallint
 define m_sql          char(500)
 define m_retorno   smallint

#=============================================================================
 function ctc79m00_prepare()
#=============================================================================

 define l_sql           char(500)

    let l_sql = " select vclmdlnom "
           ,"   from agbkveic "
           ,"  where vclcoddig = ?  "
    prepare pctc79m00001 from l_sql
    declare cctc79m00001 cursor for pctc79m00001

    let l_sql =  " select datrvclexcgch.soceqpcod, "
               , " datkvcleqp.soceqpdes       , "
               , " datrvclexcgch.caddat          , "
               , " datrvclexcgch.cademp          , "
               , " datrvclexcgch.usrtip          , "
               , " datrvclexcgch.cadmat           "
               , "from   datrvclexcgch ,  "
               , "       datkvcleqp    "
               , "where  datrvclexcgch.vclcoddig = ? "
               , "and    datrvclexcgch.soceqpcod = datkvcleqp.soceqpcod "
               , "and    datkvcleqp.soceqpstt = 'A' "
    prepare pctc79m00002 from l_sql
    declare cctc79m00002 cursor for pctc79m00002

    let l_sql =  "select datkvcleqp.soceqpdes  "
               , "from   datkvcleqp    "
               , "where  datkvcleqp.soceqpcod = ? "
               , "and    datkvcleqp.soceqpstt = 'A' "
    prepare pctc79m00003 from l_sql
    declare cctc79m00003 cursor for pctc79m00003

    let l_sql =  "select datrvclexcgch.soceqpcod "
               , "from   datrvclexcgch ,  "
               , "       datkvcleqp    "
               , "where  datrvclexcgch.vclcoddig = ? "
               , "and    datrvclexcgch.soceqpcod = ? "
               , "and    datrvclexcgch.soceqpcod = datkvcleqp.soceqpcod "
               , "and    datkvcleqp.soceqpstt = 'A' "
    prepare pctc79m00004 from l_sql
    declare cctc79m00004 cursor for pctc79m00004

    let l_sql = " delete from datrvclexcgch "
               , "where  datrvclexcgch.vclcoddig = ? "
               , "and    datrvclexcgch.soceqpcod = ? "
    prepare pctc79m00005 from l_sql

 let m_prep_sql = true

 end function

#=============================================================================
 function ctc79m00()
#=============================================================================

 define lr_ctc79m00 record
   vclcoddig like agbkveic.vclcoddig,
   vclmdlnom like agbkveic.vclmdlnom
 end record

 define l_chave     char(10)

 define ml_sql           char(500)

 initialize lr_ctc79m00.* to null

 let m_arr  = 1

 if m_prep_sql <> true or m_prep_sql is null then
    call ctc79m00_prepare()
 end if

 open window w_ctc79m00 at 7,2 with form "ctc79m00"
    attribute(prompt line last,border, form line 1)

 while true

  clear form

  let lr_ctc79m00.vclcoddig = null

  input by name lr_ctc79m00.* without defaults

     before field vclcoddig
       display by name lr_ctc79m00.vclcoddig attribute(reverse)

     after field vclcoddig
       display by name lr_ctc79m00.vclcoddig
       let int_flag = false

       if lr_ctc79m00.vclcoddig is null  or
          lr_ctc79m00.vclcoddig =  0     then
          call agguvcl() returning lr_ctc79m00.vclcoddig
          next field vclcoddig
       end if

       let lr_ctc79m00.vclmdlnom = null

       open cctc79m00001 using lr_ctc79m00.vclcoddig

       fetch cctc79m00001 into lr_ctc79m00.vclmdlnom

       #if lr_ctc79m00.vclmdlnom is null then
       if sqlca.sqlcode = 100 then
          error " Codigo de veiculo nao cadastrado!" sleep 1
          next field vclcoddig
       end if

       close cctc79m00001

       let lr_ctc79m00.vclmdlnom = cts15g00(lr_ctc79m00.vclcoddig)

       display by name lr_ctc79m00.vclcoddig
       display by name lr_ctc79m00.vclmdlnom

  on key(F17,control-c,interrupt)
     let int_flag = true
     exit input
  end input

  if int_flag = false then
     call ctc79m00_input_array(lr_ctc79m00.vclcoddig)
  else
     exit while
  end if

  options delete key F2

 end while

 close window w_ctc79m00

 let int_flag = false

 end function

#=============================================================================
 function ctc79m00_input_array(l_par_vclcoddig)
#=============================================================================

  define l_par_vclcoddig like agbkveic.vclcoddig

  define l_cont    smallint
  define l_arr     smallint
  define l_scr     smallint

  define ws record
         mensagem  char(100),
         erro      smallint ,
         funnom    char(100)
  end record

  define l_resp char(01)

  define l_data    date

  define l_alt_soceqpcod like datrvclexcgch.soceqpcod

  define l_inserir smallint

  let l_cont      = 1
  let l_data      = today
  let l_alt_soceqpcod = null

  let l_inserir = false

  options
    delete key control-p,
    prompt line last,
    insert key f1

  while true

   call ctc79m00_carga_array( l_par_vclcoddig )
   call set_count(m_cont)

   input array am_array without defaults from s_ctc79m00.*

     before row
       let l_arr  = arr_curr()
       let l_scr  = scr_line()
       let l_inserir = false

     before field soceqpcod
       display am_array[l_arr].soceqpcod to s_ctc79m00[l_scr].soceqpcod attribute(reverse)
       display am_array[l_arr].caddat to s_ctc79m00[l_scr].caddat

       let l_alt_soceqpcod = am_array[l_arr].soceqpcod
       if am_array[l_arr].caddat is null then
          let am_array[l_arr].caddat = l_data
          display am_array[l_arr].caddat to s_ctc79m00[l_scr].caddat
       end if

     after field soceqpcod
       display am_array[l_arr].soceqpcod to s_ctc79m00[l_scr].soceqpcod

       if am_array[l_arr].soceqpcod <> l_alt_soceqpcod then
          let am_array[l_arr].soceqpcod = l_alt_soceqpcod
          next field soceqpcod
       end if

       if fgl_lastkey() = 2014 then
          let am_array[l_arr].soceqpcod = null
          let l_inserir = true
       end if

       if fgl_lastkey() = 2005 or    ## f3
          fgl_lastkey() = 2006 then  ## f4
          continue input
       end if

       if fgl_lastkey() = fgl_keyval('up') or
          fgl_lastkey() = fgl_keyval("down") then
          if am_array[l_arr].soceqpcod is not null and
             l_inserir = false then
             continue input
          end if
       end if

       let m_sql  = " select datkvcleqp.soceqpcod ,datkvcleqp.soceqpdes "
                   ," from   datkvcleqp   "

       if am_array[l_arr].soceqpcod is null then
          if fgl_lastkey() = 13 then
             call ofgrc001_popup(10,
                                 14,
                                 "TIPO DE GUINCHO ",
                                 "CODIGO",
                                 "DESCRICAO",
                                 "N",
                                 m_sql,
                                 "",
                                 "X")
             returning m_retorno,
                       am_array[l_arr].soceqpcod,
                       am_array[l_arr].soceqpdes
             if am_array[l_arr].soceqpdes is null or
                am_array[l_arr].soceqpdes = " " then
                error "Informe o Codigo do Guincho " sleep 2
                next field soceqpcod
             end if
          # else
          #   continue input
          end if
       else
           open cctc79m00003 using am_array[l_arr].soceqpcod

           fetch cctc79m00003 into am_array[l_arr].soceqpdes
           if sqlca.sqlcode = 100 then
              error 'Codigo do Guincho Invalido !' sleep 2
              next field soceqpcod

           end if
           display am_array[l_arr].soceqpdes to s_ctc79m00[l_scr].soceqpdes
           close cctc79m00003
       end if

       ## Se Pressionou F1
       if l_inserir = true then
          if ctc79m00_f1( l_par_vclcoddig, am_array[l_arr].soceqpcod )then
             let l_inserir = false
             continue input
          end if
       end if

       if ctc79m00_verifica(l_par_vclcoddig, am_array[l_arr].soceqpcod ) then
          error 'Codigo do Guincho ja cadastrado !' sleep 2
          let l_alt_soceqpcod = null
          let am_array[l_arr].soceqpcod = null
          next field soceqpcod
       else
          # gravar
          begin work
          if ctc79m00_gravar( l_par_vclcoddig            ,
                              am_array[l_arr].soceqpcod  ,
                              am_array[l_arr].caddat     ,
                              g_issk.empcod              ,
                              g_issk.usrtip              ,
                              g_issk.funmat
                            ) then

             commit work
             ## exit input
          else
             error 'Erro INSERT datrvclexcgch ',sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 2
             rollback work
             next field soceqpcod
          end if
       end if

       if am_array[l_arr].funnom_cad is null then
          call cty08g00_nome_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)
          ## call cty08g00_nome_func (1, 3627, "F")
          returning ws.erro, ws.mensagem, ws.funnom
          let am_array[l_arr].funnom_cad = ws.funnom
          let am_array[l_arr].cadmat     = g_issk.funmat
          display am_array[l_arr].funnom_cad to s_ctc79m00[l_scr].funnom_cad
          display am_array[l_arr].cadmat     to s_ctc79m00[l_scr].cadmat
       end if

       next field funnom_cad

       display am_array[l_arr].soceqpcod  to s_ctc79m00[l_scr].soceqpcod
       display am_array[l_arr].soceqpdes  to s_ctc79m00[l_scr].soceqpdes
       display am_array[l_arr].caddat     to s_ctc79m00[l_scr].caddat
       display am_array[l_arr].cadmat     to s_ctc79m00[l_scr].cadmat
       display am_array[l_arr].funnom_cad to s_ctc79m00[l_scr].funnom_cad

         on key(F2)

          let l_resp = "N"

          if am_array[l_arr].soceqpcod is not null then
             prompt "Confirma remocao da linha ? (S/N) " for l_resp
             if upshift(l_resp) = 'S' then
                whenever error continue
                execute pctc79m00005  using l_par_vclcoddig
                                           ,am_array[l_arr].soceqpcod
                whenever error stop
                if sqlca.sqlcode <> 0 then
                   error 'Erro DELETE datrvclexcgch ',sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 2
                   error 'ctc79m00_array()/',am_array[l_arr].soceqpcod sleep 2
                   exit input
                end if
                call ctc79m00_dellinha(l_arr, l_scr)
                exit input
             end if
          end if

         on key(F17,control-c,interrupt)
            let int_flag = true
            exit input
   end input

   if int_flag = true then
      ## let int_flag = false
      exit while
   end if
  end while

 end function

#==============================================================================
 function ctc79m00_dellinha(l_arr, l_scr)
#==============================================================================

 define l_arr        smallint
 define l_scr        smallint
 define l_cont       smallint

   for l_cont = l_arr to 19
      if am_array[l_arr].soceqpcod is not null then
         let am_array[l_cont].* = am_array[l_cont + 1].*
      else
         initialize am_array[l_cont].* to null
      end if
   end for

   for l_cont = l_scr to 3
       display am_array[l_arr].soceqpcod  to s_ctc79m00[l_scr].soceqpcod
       display am_array[l_arr].soceqpdes  to s_ctc79m00[l_scr].soceqpdes
       display am_array[l_arr].caddat     to s_ctc79m00[l_scr].caddat
       display am_array[l_arr].cadmat     to s_ctc79m00[l_scr].cadmat
       display am_array[l_arr].funnom_cad to s_ctc79m00[l_scr].funnom_cad
       let l_arr = l_arr + 1
   end for

   let l_arr = l_arr - 1

 end function ## ctc79m00_dellinha

#=============================================================================
 function ctc79m00_carga_array(l_vclcoddig)
#=============================================================================

 define l_vclcoddig like agbkveic.vclcoddig

 define l_cademp    like datrvclexcgch.cademp
 define l_usrtip    like datrvclexcgch.usrtip

 define l_erro     smallint
 define l_mensagem char(50)

 initialize am_array to null

 let l_erro     = null
 let l_mensagem = null

 let m_cont      = 1

 open cctc79m00002 using l_vclcoddig

 foreach cctc79m00002 into am_array[m_cont].soceqpcod
                          ,am_array[m_cont].soceqpdes
                          ,am_array[m_cont].caddat
                          ,l_cademp
                          ,l_usrtip
                          ,am_array[m_cont].cadmat

     call cty08g00_nome_func (l_cademp, am_array[m_cont].cadmat,l_usrtip )
     ## call cty08g00_nome_func (1, 3627, "F")
     returning l_erro, l_mensagem, am_array[m_cont].funnom_cad

     let m_cont = m_cont + 1

     if m_cont > 20 then
        error 'Limite de Array excedido !!' sleep 2
        exit foreach
     end if


 end foreach

 let m_cont = m_cont -1

end function ## ctc79m00_carga_array

#=============================================================================
 function ctc79m00_gravar(lr_param)
#=============================================================================

 define lr_param record
        vclcoddig    like datrvclexcgch.vclcoddig ,
        soceqpcod    like datrvclexcgch.soceqpcod ,
        caddat       like datrvclexcgch.caddat    ,
        cademp       like datrvclexcgch.cademp    ,
        usrtip       like datrvclexcgch.usrtip    ,
        cadmat       like datrvclexcgch.cadmat
 end record

 whenever error continue
 insert into datrvclexcgch( vclcoddig            ,
                            soceqpcod            ,
                            caddat               ,
                            cademp               ,
                            usrtip               ,
                            cadmat
                          )
                 values (   lr_param.vclcoddig   ,
                            lr_param.soceqpcod   ,
                            lr_param.caddat      ,
                            lr_param.cademp      ,
                            lr_param.usrtip      ,
                            lr_param.cadmat
                        )
 whenever error stop

 if sqlca.sqlcode = 0 then
    return 1
 else
    return 0
 end if

 end function ##  ctc79m00_gravar

#=============================================================================
 function ctc79m00_verifica(lr_param)
#=============================================================================

  define lr_param record
         vclcoddig    like datrvclexcgch.vclcoddig,
         soceqpcod    like datrvclexcgch.soceqpcod
  end record

  define l_vclcoddig  like datrvclexcgch.vclcoddig

  let l_vclcoddig = null

  ## Verificar se guincho já esta cadastrado
  open cctc79m00004 using lr_param.vclcoddig,
                          lr_param.soceqpcod

  fetch cctc79m00004 into l_vclcoddig

  if l_vclcoddig is not null then
     return 1
  end if
  close cctc79m00004

  return 0

 end function ## ctc79m00_verifica



#=============================================================================
 function ctc79m00_f1(lr_param)
#=============================================================================
  define lr_param record
         vclcoddig    like datrvclexcgch.vclcoddig,
         soceqpcod    like datrvclexcgch.soceqpcod
  end record

  define l_vclcoddig  like datrvclexcgch.vclcoddig

  let l_vclcoddig = null

  ## Verificar se guincho já esta cadastrado
  open cctc79m00004 using lr_param.vclcoddig,
                          lr_param.soceqpcod

  fetch cctc79m00004 into l_vclcoddig

  if l_vclcoddig is not null then
     return 1
  end if
  close cctc79m00004

  return 0

 end function ## ctc79m00_f1
