#-----------------------------------------------------------------------------#
# Modulo:   ctn52c00                                                          #
# Objetivo: Consulta de Inconsistencias da Frota                              #
# Sistema : Central 24h                                                       #
# Autor   : Raji Jahchan                                                      #
#           Mariana - Fsw                                                     #
# Data    : 15/01/03                                                          #
# 13/07/2007 Ligia Mattge PSI 210838 retorno param de ctn44c02/ctx25g01       #
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glcte.4gl"

define vl_a_ctn5200     array[5000] of record
       mdtcod           like datmmdtinc.mdtcod,
       sgl              like datkveiculo.atdvclsgl,
       srrcoddig        like datmmdtinc.srrcoddig,
       srrnom           like datksrr.srrnom,
       inconsistencia   like datmmdtinc.mdtinctip,
       caddat           like datmmdtinc.caddat,
       cadhor           char(5),
       atdtrxdat        like datmmdtinc.atdtrxdat,
       atdtrxhor        char(5)
                        end record

define l_param          record
       caddat_de        like datmmdtinc.caddat,
       caddat_ate       like datmmdtinc.caddat,
       atdvclsgl        like datkveiculo.atdvclsgl,
       mdtinctip        like datmmdtinc.mdtinctip
                        end record

define w_descricao      char(26)
define l_arr            integer,
       l_scr            integer
define l_comando        char(1000)

  define vl_a_ctn5200a    array[5000] of record
         lclltt           like datmmdtinc.lclltt,
         lcllgt           like datmmdtinc.lcllgt
  end record

  define m_ctn52c00_prep  smallint,
         m_achou          smallint

#-------------------------#
function ctn52c00_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select cpodes ",
                " from iddkdominio ",
               " where cponom = 'mdtinctip' ",
                 " and cpocod = ? "

  prepare p_ctn52c00_001 from l_sql
  declare c_ctn52c00_001 cursor for p_ctn52c00_001

  let l_sql = " select unique mdtcod ",
                " from datmmdtinc ",
               " where mdtcod = ? "

  prepare p_ctn52c00_002 from l_sql
  declare c_ctn52c00_002 cursor for p_ctn52c00_002

  let m_ctn52c00_prep = true

end function

#-----------------#
function ctn52c00()
#-----------------#

  define lr_popup record
         lin      smallint,
         col      smallint,
         titulo   char(054),
         tit2     char(012),
         tit3     char(040),
         tipcod   char(001),
         cmd_sql  char(300),
         aux_sql  char(100),
         tipo     char(001)
  end record

  define l_cod_erro smallint

  if m_ctn52c00_prep is null or
     m_ctn52c00_prep <> true then
     call ctn52c00_prepare()
  end if

 initialize lr_popup to null

 let l_cod_erro       = null
 let lr_popup.lin     = 11
 let lr_popup.col     = 21
 let lr_popup.titulo  = "TIPOS DE INCONSISTENCIAS"
 let lr_popup.tit2    = "CODIGO"
 let lr_popup.tit3    = "DESCRICAO"
 let lr_popup.tipcod  = "A"
 let lr_popup.aux_sql = null
 let lr_popup.tipo    = "D"

 let int_flag = false

  open window w_ctn52c00 at 4,2 with form "ctn52c00"
     attribute(form line 1)

  input by name l_param.*

    before field caddat_de
       let l_param.caddat_de = today
       display by name l_param.caddat_de attribute(reverse)

    after field caddat_de
       display by name l_param.caddat_de

    before field caddat_ate
       let l_param.caddat_ate = today
       display by name l_param.caddat_ate attribute(reverse)

    after field caddat_ate
       display by name l_param.caddat_ate

       if fgl_lastkey() = fgl_keyval("up") or
          fgl_lastkey() = fgl_keyval("left") then
          next field caddat_de
       end if

       if l_param.caddat_ate is not null and
          l_param.caddat_de is null then
          error " Informe o periodo inicial"
          next field caddat_de
       end if

       if l_param.caddat_ate is not null and
          l_param.caddat_ate < l_param.caddat_de then
          error " Periodo final deve ser maior que o inicial"
          next field caddat_de
       end if

    before field atdvclsgl
       display by name l_param.atdvclsgl attribute(reverse)

    after field atdvclsgl
       display by name l_param.atdvclsgl

       if fgl_lastkey() = fgl_keyval("up") or
          fgl_lastkey() = fgl_keyval("left") then
          next field caddat_ate
       end if

      if l_param.atdvclsgl is not null then
         select atdvclsgl
           from datkveiculo
          where atdvclsgl = l_param.atdvclsgl

          if sqlca.sqlcode <> 0 then
             error "Sigla nao existente"
             next field atdvclsgl
          end if
      end if

    before field mdtinctip
       display l_param.mdtinctip to mdtinctip attribute(reverse)

    after field mdtinctip
       display l_param.mdtinctip to mdtinctip

       if fgl_lastkey() = fgl_keyval("up") or
          fgl_lastkey() = fgl_keyval("left") then
          next field atdvclsgl
       end if

       let w_descricao = null

       # --> VERIFICA SE O CODIGO DIGITADO EXISTE
       open c_ctn52c00_001 using l_param.mdtinctip
       whenever error continue
       fetch c_ctn52c00_001 into w_descricao
       whenever error stop

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode = notfound then
             let w_descricao = null
          else
             error "Erro SELECT c_ctn52c00_001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 2
             error "ctn52c00() / ", l_param.mdtinctip sleep 2
             close c_ctn52c00_001
             let l_param.mdtinctip = null
             next field mdtinctip
          end if
       end if

       close c_ctn52c00_001

       if w_descricao is null then

          let lr_popup.cmd_sql = " select cpocod, cpodes from iddkdominio ",
                                 " where cponom = 'mdtinctip' order by cpodes "

          # --> CHAMA A POPUP-UP COM AS OPCOES DISPONIVEIS
          call ofgrc001_popup(lr_popup.*)
               returning l_cod_erro, l_param.mdtinctip, w_descricao

          if l_cod_erro <> 0 then

             if l_cod_erro = 1 then
                error "Selecione um tipo de inconsistencia"
             else
                error "Erro na funcao ofgrc001_popup() !"
             end if

             let l_param.mdtinctip = null
             let w_descricao       = null
             display l_param.mdtinctip to mdtinctip
             display w_descricao to descricao
             next field mdtinctip

          end if

       end if

   display l_param.mdtinctip to mdtinctip
   display w_descricao to descricao

   display by name l_param.*

   call ctn52c00_array()

   if not m_achou then
      error "Nao ha dados para exibicao!"
      initialize l_param to null
      let w_descricao = null
      display by name l_param.*
      display " " to total
      display w_descricao to descricao
   end if

   next field caddat_de

   on key (control-c, interrupt)
      let int_flag = true
      initialize l_param.* to null
      exit input

 end input

 let int_flag = false

 close window w_ctn52c00

end function

#---------------------------------#
function ctn52c00_array()
#---------------------------------#

define ws record
   cadhor    char(10),
   atdtrxhor char(10)
end record

define l_resp char(1),
        l_msg  record
        msg1   char(40),
        msg2   char(40),
        msg3   char(40),
        msg4   char(40)
        end record
 initialize l_msg.*  to null
 let l_resp = null



        initialize  ws.*  to  null

 let l_comando = " select a.mdtcod , b.atdvclsgl, a.srrcoddig ,",
                 "        a.mdtinctip  , a.caddat , a.cadhor , ",
                 "        a.atdtrxdat , a.atdtrxhor , a.lclltt , a.lcllgt ",
                 "   from datmmdtinc a, datkveiculo b " ,
                 "  where a.caddat between ? and ? ",
                 "    and a.mdtcod = b.mdtcod "

 if l_param.atdvclsgl is not null then
    let l_comando = l_comando clipped,
                    " and b.atdvclsgl = '", l_param.atdvclsgl, "'"
 end if

 if l_param.mdtinctip is not null then
    let l_comando = l_comando clipped,
                    " and a.mdtinctip = ", l_param.mdtinctip
 end if

 let l_comando = l_comando clipped,
     " order by mdtcod, mdtinctip, caddat, cadhor "

 prepare p_ctn52c00001 from l_comando
 declare c_ctn52c00001 cursor for p_ctn52c00001

 let l_comando = " select srrnom ",
                 "   from datksrr ",
                 "  where srrcoddig = ? "

 prepare p_ctn52c00005 from l_comando
 declare c_ctn52c00005 cursor for p_ctn52c00005

 let m_achou = false

 let l_arr = 1

    open c_ctn52c00001 using l_param.caddat_de,
                             l_param.caddat_ate
    foreach c_ctn52c00001 into vl_a_ctn5200[l_arr].mdtcod,
                               vl_a_ctn5200[l_arr].sgl,
                               vl_a_ctn5200[l_arr].srrcoddig,
                               vl_a_ctn5200[l_arr].inconsistencia,
                               vl_a_ctn5200[l_arr].caddat,
                               ws.cadhor,
                               vl_a_ctn5200[l_arr].atdtrxdat,
                               ws.atdtrxhor,
                               vl_a_ctn5200a[l_arr].lclltt,
                               vl_a_ctn5200a[l_arr].lcllgt

         let vl_a_ctn5200[l_arr].cadhor = ws.cadhor[1,5]
         let vl_a_ctn5200[l_arr].atdtrxhor = ws.atdtrxhor[1,5]


         open c_ctn52c00_001 using vl_a_ctn5200[l_arr].inconsistencia
         fetch c_ctn52c00_001 into vl_a_ctn5200[l_arr].inconsistencia
         close c_ctn52c00_001

         open c_ctn52c00005 using vl_a_ctn5200[l_arr].srrcoddig
         fetch c_ctn52c00005 into vl_a_ctn5200[l_arr].srrnom

         let l_arr = l_arr + 1

         if l_arr > 5000 then
            error "Limite de array excedido, avise a informatica !"
            exit foreach
         end if

    end foreach


 call set_count(l_arr - 1)
 let l_arr = l_arr - 1

 display l_arr to total

 if l_arr > 0 then
    let m_achou = true
    display array vl_a_ctn5200 to s_ctn52c00.*

    on key(control-c, interrupt)
       exit display

    on key(f4)
     call ctn52c00_poll()

    on key(f5)
     call ctn52c00_atualiza_servidor()

    on key(f6)
     call ctn52c00_configura_tempo()

    on key(f8)
     let l_arr = arr_curr()
     let l_scr = scr_line()

     error " Aguarde..."
     if ctx25g05_rota_ativa() then      # Verifica ambiente de ROTERIZACAO
        call ctx25g01(vl_a_ctn5200a[l_arr].lclltt,
                      vl_a_ctn5200a[l_arr].lcllgt,"O")
              returning l_msg.msg1, l_msg.msg2, l_msg.msg3, l_msg.msg4
     else
        call ctn44c02(vl_a_ctn5200a[l_arr].lclltt,
                      vl_a_ctn5200a[l_arr].lcllgt)
              returning l_msg.msg1, l_msg.msg2, l_msg.msg3, l_msg.msg4
     end if

     if l_msg.msg1 is not null then
        call cts08g01("A","", l_msg.msg1, l_msg.msg2, l_msg.msg3, l_msg.msg4 )
             returning l_resp
     end if

     error " "

     end display
 else
    let m_achou = false
 end if

end function

#--------------------------------#
function ctn52c00_poll()
#--------------------------------#

define w_param       record
       mdtcod        like datmmdtinc.mdtcod,
       atdvclsgl     like datkveiculo.atdvclsgl
                     end record

define ws            record
       msgtxt        char(500),
       mdtmsgnum     integer,
       dataatu       date,
       horaatu       datetime hour to second
                     end record



        initialize  w_param.*  to  null

        initialize  ws.*  to  null

   let ws.msgtxt = "POLL"

   open window w_ctn52c00a at 8,4 with form "ctn52c00a"
     attribute(border, message line last)

  current window is w_ctn52c00a

  input by name w_param.*

   after field mdtcod
     if w_param.mdtcod is not null then

        open c_ctn52c00_002 using w_param.mdtcod
        fetch c_ctn52c00_002

        if sqlca.sqlcode <> 0 then
           error "Codigo nao existente"
           close c_ctn52c00_002
           next field mdtcod
        end if

        close c_ctn52c00_002

     end if

   after field atdvclsgl
     if w_param.atdvclsgl is not null then
        select atdvclsgl
          from datkveiculo
         where atdvclsgl = w_param.atdvclsgl

         if sqlca.sqlcode <> 0 then
            error "Sigla nao existente"
            next field atdvclsgl
         end if
      end if

    if w_param.mdtcod is null and
       w_param.atdvclsgl is not null then
       select mdtcod
         into w_param.mdtcod
         from datkveiculo
        where atdvclsgl = w_param.atdvclsgl
    end if


    if w_param.mdtcod is null and
       w_param.atdvclsgl is null then
       error " Informe o MDT ou a Sigla do Veiculo"
       next field mdtcod
    end if

    on key (control-c, interrupt)
       exit input

  end input

  current window is w_ctn52c00a


#---> Grava tabelas para envio de mensagem
  if not int_flag then
     whenever error continue
       display  "Gravando informacoes..." at 9,2
       sleep 1
       insert into datmmdtmsg (mdtmsgnum,
                               mdtmsgorgcod,
                               mdtcod,
                               mdtmsgstt,
                               mdtmsgavstip)
                       values (0,
                               1,
                               w_param.mdtcod,
                               1,
                               4)

        let ws.mdtmsgnum = sqlca.sqlerrd[2]

        select today, current
          into ws.dataatu, ws.horaatu
          from dual                # BUSCA DATA E HORA DO BANCO

        insert into datmmdtlog (mdtmsgnum,
                                mdtlogseq,
                                mdtmsgstt,
                                atldat,
                                atlhor,
                                atlemp,
                                atlmat)
                         values (ws.mdtmsgnum,
                                 1,
                                 1,
                                 ws.dataatu,
                                 ws.horaatu,
                                 1,
                                 g_issk.funmat)

         insert into datmmdtmsgtxt (mdtmsgnum,
                                    mdtmsgtxtseq,
                                    mdtmsgtxt)
                            values (ws.mdtmsgnum,
                                    1,
                                    ws.msgtxt)
     whenever error stop
  else
     let int_flag = false
  end if

 close window w_ctn52c00a

end function
#-----------------------------------#
function ctn52c00_atualiza_servidor()
#-----------------------------------#

define ws               record
       msgtxt           char(500),
       mdtmsgnum        integer,
       dataatu          date,
       horaatu          datetime hour to second
                        end record

define l_mdtcod         like datmmdtinc.mdtcod


        let     l_mdtcod  =  null

        initialize  ws.*  to  null

   let ws.msgtxt = "IGUALAR STATUS"
   let l_mdtcod  = 1


   whenever error continue
     error "Atualizando..."
     sleep 1
     insert into datmmdtmsg (mdtmsgnum,
                             mdtmsgorgcod,
                             mdtcod,
                             mdtmsgstt,
                             mdtmsgavstip)
                     values (0,
                             1,
                             1,  #mdt fixo = 1
                             1,
                             4)

         let ws.mdtmsgnum = sqlca.sqlerrd[2]

      select today, current
        into ws.dataatu, ws.horaatu
        from dual                # BUSCA DATA E HORA DO BANCO

      insert into datmmdtlog (mdtmsgnum,
                              mdtlogseq,
                              mdtmsgstt,
                              atldat,
                              atlhor,
                              atlemp,
                              atlmat)
                       values (ws.mdtmsgnum,
                               1,
                               1,
                               ws.dataatu,
                               ws.horaatu,
                               1,
                               g_issk.funmat)

       insert into datmmdtmsgtxt (mdtmsgnum,
                                  mdtmsgtxtseq,
                                  mdtmsgtxt)
                          values (ws.mdtmsgnum,
                                  1,
                                  ws.msgtxt)
 whenever error stop

  error "              "

 end function

#------------------------------------#
function ctn52c00_configura_tempo()
#------------------------------------#

define w_tempo            record
       atlrap             interval hour(4) to minute,
       vellim             dec(03,0),
       atllen             interval hour(4) to minute
                          end record

define ws                 record
       msgtxt             char(500),
       mdtmsgnum          integer,
       dataatu            date,
       horaatu            datetime hour to second
                          end record


        initialize  w_tempo.*  to  null

        initialize  ws.*  to  null

  let int_flag = false

  open window w_ctn52c00b at 5,6 with form "ctn52c00b"
    attribute(border, message line last)

  current window is w_ctn52c00b

  input by name w_tempo.*

  after field atlrap
    if w_tempo.atlrap is not null then
       if w_tempo.atlrap < '00:30' or
          w_tempo.atlrap > '30:00' then
          error "Valor esta fora da faixa permitida"
          next field atlrap
       end if
    else
       error "Campo de preenchimento obrigatorio"
       next field atlrap
    end if

  after field vellim
    if w_tempo.vellim is not null then
       if w_tempo.vellim < 5 or
          w_tempo.vellim > 30 then
          error "Valor esta fora da faixa permitida"
          next field vellim
       end if
    else
       error "Campo de preenchimento obrigatorio"
       next field vellim
    end if

  after field atllen
    if w_tempo.atllen is not null then
       if w_tempo.atllen < '03:00' or
          w_tempo.atllen > '50:00' then
          error "Valor esta fora da faixa permitida"
          next field atllen
       end if
    else
       error "Campo de preenchimento obrigatorio"
       next field atllen
    end if


    on key (control-c, interrupt)
       exit input
       let int_flag = true

  end input

  current window is w_ctn52c00b

  let ws.msgtxt = "ATUALIZACAO;" , w_tempo.atlrap clipped,";",
                                   w_tempo.vellim clipped,";",
                                   w_tempo.atllen clipped,";"

  whenever error continue

  if not int_flag then
     display "Atualizando taxa..." at 10,2
     sleep 1
     insert into datmmdtmsg (mdtmsgnum,
                             mdtmsgorgcod,
                             mdtcod,
                             mdtmsgstt,
                             mdtmsgavstip)
                     values (0,
                             1,
                             1,  #mdt fixo = 1
                             1,
                             4)

         let ws.mdtmsgnum = sqlca.sqlerrd[2]

      select today, current
        into ws.dataatu, ws.horaatu
        from dual                # BUSCA DATA E HORA DO BANCO

      insert into datmmdtlog (mdtmsgnum,
                              mdtlogseq,
                              mdtmsgstt,
                              atldat,
                              atlhor,
                              atlemp,
                              atlmat)
                       values (ws.mdtmsgnum,
                               1,
                               1,
                               ws.dataatu,
                               ws.horaatu,
                               1,
                               g_issk.funmat)

       insert into datmmdtmsgtxt (mdtmsgnum,
                                  mdtmsgtxtseq,
                                  mdtmsgtxt)
                          values (ws.mdtmsgnum,
                                  1,
                                  ws.msgtxt)
  else
    let int_flag = false
  end if
  whenever error stop

 close window  w_ctn52c00b
 end function
