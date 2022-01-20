#-----------------------------------------------------------------------------#
#                                 PORTO SEGURO                                #
#.............................................................................#
#                                                                             #
#  Modulo              : cts00m35                                             #
#  Analista Responsavel: Raji Jahchan                                         #
#  PSI/OSF             : 166480/19372 - Tela  para acompanhamento da execucao #
#                                       do servico enviado via GPS.           #
#                                                                             #
#.............................................................................#
#                                                                             #
#  Desenvolvimento     : Fabrica de Software - Gustavo Bayarri                #
#  Data                : 26/05/2003                                           #
#-----------------------------------------------------------------------------#

database porto

  define m_prepare         char(01)

#----------------------------------------------
function cts00m35_prepare()
#----------------------------------------------

  define l_comando         char(500)

  let l_comando = null

  #################
  #### PREPARE ####
  #################

  let l_comando = "select mdtmvtseq, mdttrxnum, caddat, cadhor, mdtcod,       "
                 ,"mdtbotprgseq, mdtmvtstt, lclltt, lcllgt                    "
                 ,"from datmmdtmvt                                            "
                 ,"where atdsrvnum = ?                                        "
                 ,"  and atdsrvano = ?                                        "
                 ,"order by mdtmvtseq desc                                    "

  prepare p_cts00m35_001 from l_comando
  declare c_cts00m35_001 cursor for p_cts00m35_001

  let l_comando = "select cpodes                                              "
                 ,"from iddkdominio                                           "
                 ,"where cponom = 'mdtmvtstt'                                 "
                 ,"  and cpocod = ?                                           "

  prepare p_cts00m35_002 from l_comando
  declare c_cts00m35_002 cursor for p_cts00m35_002

  let l_comando = "select mdtbottxt                                           "
                 ,"from datrmdtbotprg, datkmdtbot                             "
                 ,"where datrmdtbotprg.mdtbotprgseq =  ?                      "
                 ,"  and datkmdtbot.mdtbotcod       = datrmdtbotprg.mdtbotcod "

  prepare p_cts00m35_003 from l_comando
  declare c_cts00m35_003 cursor for p_cts00m35_003

  #####################
  #### FIM PREPARE ####
  #####################

end function

#---------------------------------------------------------------
function cts00m35(l_param)
#---------------------------------------------------------------
  define l_param           record
         num_serv          decimal(10,0)
        ,ano_serv          decimal(2,0)
  end record

  define ld_cts00m35       record
         srvnum            char(10)
        ,total             decimal(4,0)
  end record

  define la_datmmdtmvt     array[30] of record
         mdtmvtseq         like datmmdtmvt.mdtmvtseq
        ,mdttrxnum         like datmmdtmvt.mdttrxnum
        ,caddat            like datmmdtmvt.caddat
        ,cadhor            char(05)
        ,mdtcod            like datmmdtmvt.mdtcod
        ,mdtbottxt         like datkmdtbot.mdtbottxt
        ,mdtmvtsttdes      like iddkdominio.cpodes
        ,dist              decimal (7,0)
  end record

  define la_aux_datmmdtmvt array[30] of record
         mdtbotprgseq      like datmmdtmvt.mdtbotprgseq
        ,mdtmvtstt         like datmmdtmvt.mdtmvtstt
  end record
   define ws            record
      mdtcod            like datmmdtmvt.mdtcod,
      lclltt            like datmmdtmvt.lclltt,
      lcllgt            like datmmdtmvt.lcllgt,
      dist              decimal (7,0)
   end record
   define ws_ant        record
      mdtcod            like datmmdtmvt.mdtcod,
      lclltt            like datmmdtmvt.lclltt,
      lcllgt            like datmmdtmvt.lcllgt,
      dist              decimal (7,0)
   end record

  define l_arr_aux         smallint
  define l_scr_aux         smallint

  define l_i               smallint
        ,l_mdterrcod       like datmmdterr.mdterrcod
        ,l_cadhor          char(08)

  if m_prepare is null then
     let m_prepare = "S"
     call cts00m35_prepare()
  end if
  initialize ws.*         to null
  initialize ws_ant.*     to null
  let l_arr_aux = null
  let l_scr_aux = null
  open window w_cts00m35 at 06,02 with form "cts00m35"
              attribute (form line first)

  let ld_cts00m35.total  = 0
  let ld_cts00m35.srvnum = null
  let ld_cts00m35.srvnum = l_param.num_serv using '&&&&&&&'
                          ,"-"
                          ,l_param.ano_serv using '&&'

  let l_i = null
  for l_i = 1 to 30
      initialize la_datmmdtmvt[l_i].* to null
  end for

  let l_i = null
  for l_i = 1 to 30
      initialize la_aux_datmmdtmvt[l_i].* to null
  end for

  let l_arr_aux = 1
  open    c_cts00m35_001 using l_param.num_serv
                            ,l_param.ano_serv

  foreach c_cts00m35_001 into  la_datmmdtmvt[l_arr_aux].mdtmvtseq
                            ,la_datmmdtmvt[l_arr_aux].mdttrxnum
                            ,la_datmmdtmvt[l_arr_aux].caddat
                            ,l_cadhor
                            ,la_datmmdtmvt[l_arr_aux].mdtcod
                            ,la_aux_datmmdtmvt[l_arr_aux].mdtbotprgseq
                            ,la_aux_datmmdtmvt[l_arr_aux].mdtmvtstt
                            ,ws.lclltt
                            ,ws.lcllgt
     let la_datmmdtmvt[l_arr_aux].cadhor = l_cadhor[01,05]

     open  c_cts00m35_003 using la_aux_datmmdtmvt[l_arr_aux].mdtbotprgseq
     whenever error continue
     fetch c_cts00m35_003 into  la_datmmdtmvt[l_arr_aux].mdtbottxt
     whenever error stop

     if sqlca.sqlcode   <> 0 then
        if sqlca.sqlcode <  0 then
           error " Nao foi possivel acessar o Botao/Tp.Mov.,"
                ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
           close c_cts00m35_003
           return
        end if
        error " Nao foi encontrado o Botao/Tp.Mov.,"
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        close c_cts00m35_003
        continue foreach
     end if
     close c_cts00m35_003

     open  c_cts00m35_002 using la_aux_datmmdtmvt[l_arr_aux].mdtmvtstt
     whenever error continue
     fetch c_cts00m35_002 into  la_datmmdtmvt[l_arr_aux].mdtmvtsttdes
     whenever error stop

     if sqlca.sqlcode   <> 0 then
        if sqlca.sqlcode <  0 then
           error " Nao foi possivel acessar a Situacao,"
                ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
           close c_cts00m35_002
           return
        end if
        error " Nao foi encontrado a Situacao,"
             ," (Sqlcode = ", sqlca.sqlcode using '-<<<<<&', ")"
        close c_cts00m35_002
        continue foreach
     end if
     close c_cts00m35_002
     if   ws_ant.mdtcod is not null and
         (ws_ant.mdtcod  = la_datmmdtmvt[l_arr_aux].mdtcod) then
         call ctn44c00_dist(ws_ant.lclltt,
                            ws_ant.lcllgt,
                            ws.lclltt,
                            ws.lcllgt)
         returning ws_ant.dist
         if ws_ant.dist is not null then
            let la_datmmdtmvt[l_arr_aux - 1].dist = ws_ant.dist
         else
            let la_datmmdtmvt[l_arr_aux - 1].dist = ' '
         end if
     else
         if ws.lclltt is null or ws.lclltt = ' ' or ws.lclltt = 0 or
            ws.lcllgt is null or ws.lcllgt = ' ' or ws.lcllgt = 0 then
            let la_datmmdtmvt[l_arr_aux].dist = ' '
         else
            let la_datmmdtmvt[l_arr_aux].dist = 0
         end if
         if l_arr_aux > 1 then
            if ws_ant.lclltt is null or ws_ant.lclltt = ' ' or ws_ant.lclltt = 0 or
               ws_ant.lcllgt is null or ws_ant.lcllgt = ' ' or ws_ant.lcllgt = 0 then
               let la_datmmdtmvt[l_arr_aux - 1].dist = ' '
            else
               let la_datmmdtmvt[l_arr_aux - 1].dist = 0
            end if
         end if
     end if
     let ws_ant.mdtcod  = la_datmmdtmvt[l_arr_aux].mdtcod
     let ws_ant.lclltt  = ws.lclltt
     let ws_ant.lcllgt  = ws.lcllgt
     let ld_cts00m35.total = ld_cts00m35.total + 1
     let l_arr_aux         = l_arr_aux + 1
     if l_arr_aux > 30 then
        error " Limite excedido. Servico possui mais de 30 etapas",
              " de acompanhamento!"
        exit foreach
     end if

  end foreach
  if ws.lclltt is null or ws.lclltt = ' ' or ws.lclltt = 0 or
     ws.lcllgt is null or ws.lcllgt = ' ' or ws.lcllgt = 0 then
     let la_datmmdtmvt[l_arr_aux - 1].dist = ' '
  else
     let la_datmmdtmvt[l_arr_aux - 1].dist = 0
  end if
  if l_arr_aux > 1  then

     display by name ld_cts00m35.srvnum
                    ,ld_cts00m35.total

     call set_count(l_arr_aux-1)

     display array la_datmmdtmvt to s_cts00m35.*
        on key(interrupt, control-c)
           exit display

        on key (F8)
          let l_arr_aux = arr_curr()
          let l_scr_aux = scr_line()
          call ctn44c01(la_datmmdtmvt[l_arr_aux].mdtmvtseq)
     end display
  else
     error " Nao existem etapas cadastradas para este servico!"
     sleep(2)
 end if

 close window w_cts00m35
end function
