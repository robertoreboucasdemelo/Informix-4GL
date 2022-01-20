###############################################################################
#                         PORTO SEGURO CIA DE SEGUROS GERAIS                  # 
#.............................................................................#
# Sistema          : CENTRAL 24H                                              #
# Modulo           : ctb27m01.4gl                                             #
#                    Cadastro dos Destinatarios das Mensagens para            #
#                    Prestadores                                              #
# Analista Resp.   : Carlos Zyon                                              #
# PSI              : 187801                                                   #
#.............................................................................#
# Desenvolvimento  : Helio (Meta)                                             #
# Liberacao        :                                                          #
#.............................................................................#
#                     * * * A L T E R A C A O * * *                           #
#                                                                             #
# Data        Autor Fabrica        PSI   Alteracao                            #
# ----------  ------------------- ------ -------------------------------------#
#                                                                             #
#                                                                             #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep       char(01)

#------------------------------------------------------------------------------
function ctb27m01_prepare()
#------------------------------------------------------------------------------

define l_sql     char(1000)

   let l_sql = " select prsmsgtitdes, prsmsgstt "
              ," from dpakprsmsg                "
              ," where prsmsgcod = ?            "
   prepare pctb27m0101 from l_sql
   declare cctb27m0101 cursor for pctb27m0101
   
   let l_sql = " select pstcoddig, prsmsgdstsit , cadmat, usrtip "
              ," ,webusrcod, caddat, prsmsgltrdat                "
              ," from dparprsmsgdst                              "
              ," where prsmsgcod = ?                             "
   prepare pctb27m0102 from l_sql
   declare cctb27m0102 cursor for pctb27m0102
   
   let l_sql = " select nomgrr       "
              ," from dpaksocor      "
              ," where pstcoddig = ? "
   prepare pctb27m0103 from l_sql
   declare cctb27m0103 cursor for pctb27m0103

   let l_sql = " select funnom    "
              ," from isskfunc    "
              ," where funmat = ? "
   prepare pctb27m0104 from l_sql
   declare cctb27m0104 cursor for pctb27m0104

   let l_sql = " select webusrnom  "
              ," from isskwebusr   "
              ," where usrtip = ?  "
              ," and webusrcod = ? "
   prepare pctb27m0105 from l_sql
   declare cctb27m0105 cursor for pctb27m0105
   
   let l_sql = " insert into dparprsmsgdst (prsmsgcod    "
              ,"                           ,pstcoddig    "
              ,"                           ,prsmsgdstsit "
              ,"                           ,caddat       "
              ,"                           ,cadusrtip    "
              ,"                           ,cademp       "
              ,"                           ,cadmat)      "
              ," values(?,?,?,?,?,?,?)                   "
   prepare pctb27m0106 from l_sql

   let l_sql = " delete from dparprsmsgdst "
              ," where prsmsgcod = ?  "
              ," and pstcoddig = ?    "
   prepare pctb27m0107 from l_sql
   
   let l_sql = " select pstcoddig    "
              ," from dparprsmsgdst  "
              ," where prsmsgcod = ? "
              ," and pstcoddig = ?   "
   prepare pctb27m0108 from l_sql
   declare cctb27m0108 cursor for pctb27m0108
   
   let m_prep = "S"

end function #ctb27m01_prepare

#------------------------------------------------------------------------------
function ctb27m01(l_prsmsgcod)
#------------------------------------------------------------------------------

define l_prsmsgcod     like dpakprsmsg.prsmsgcod

define lr_ctb27m0101   record
   prsmsgtitdes        like dpakprsmsg.prsmsgtitdes
  ,prsmsgstt           like dpakprsmsg.prsmsgstt
  ,sitdes              char(09)
end record

define al_cbt27m0101   array[1000] of record
   pstcoddig             like dparprsmsgdst.pstcoddig
  ,nomgrr                char(15)
  ,prsmsgdstsit          like dparprsmsgdst.prsmsgdstsit
  ,estdes                char(10)
  ,codigo                char(07)
  ,nome                  char(15)
  ,datahora              char(16)
end record

define lr_ctb27m0102    record
   pstcoddig            like dparprsmsgdst.pstcoddig
  ,nomgrr               char(15)
  ,prsmsgdstsit         like dparprsmsgdst.prsmsgdstsit
  ,estdes               char(10)
  ,codigo               char(07)
  ,nome                 char(15)
  ,datahora             datetime year to minute
end record

define al_cbt27m0101_aux array[1000] of record
   datahora             datetime year to minute
end record

define l_i               smallint
     , l_data_fmt        char(16)
     , l_data_def        char(16)

define l_cadmat          like dparprsmsgdst.cadmat
define l_usrtip          like dparprsmsgdst.usrtip
define l_webusrcod       like dparprsmsgdst.webusrcod
define l_caddat          like dparprsmsgdst.caddat
define l_prsmsgltrdat    like dparprsmsgdst.prsmsgltrdat
define l_pstcoddig       like dparprsmsgdst.pstcoddig
define l_arr             smallint
define l_scr             smallint
define l_inclui          char(01)
define l_current         datetime year to minute
define l_pstcoddig_ant   like dparprsmsgdst.pstcoddig
define l_delete          char(01)
   
   initialize lr_ctb27m0101 to null
   initialize al_cbt27m0101 to null
   initialize al_cbt27m0101_aux to null
   initialize lr_ctb27m0102 to null
   
   let l_i = 1
   let l_cadmat = 0
   let l_usrtip = ""
   let l_webusrcod = 0
   let l_caddat = ""
   let l_prsmsgltrdat = ""
   let l_pstcoddig = 0
   let l_arr = 0
   let l_scr = 0
   let l_inclui = "S"
   let l_pstcoddig_ant = 0
   let l_delete = ""

   if m_prep is null or
      m_prep <> true then
      call ctb27m01_prepare()
   end if
   
   #Busca o titulo e a situacao
   whenever error continue
      open cctb27m0101 using l_prsmsgcod
      fetch cctb27m0101 into lr_ctb27m0101.prsmsgtitdes
                            ,lr_ctb27m0101.prsmsgstt
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode < 0 then
         error "Erro no SELECT cctb27m0101. ",sqlca.sqlcode,"/"
              ,sqlca.sqlerrd[2] 
         sleep 2
         error "Funcao ctb27m01()/",l_prsmsgcod
      end if
      if sqlca.sqlcode = 100 then
         error "Nao existe mensagem com este codigo."
      end if
      exit program(1)
   end if
   close cctb27m0101

   if lr_ctb27m0101.prsmsgstt = "A" then
      let lr_ctb27m0101.sitdes = "ATIVA"
   else
      let lr_ctb27m0101.sitdes = "CANCELADA"
   end if
   
   open window w_ctb27m01 at 6,2 with form "ctb27m01"
      attribute (form line 1)
      
      let int_flag = false
      
      clear form
   
      display l_prsmsgcod to prsmsgcod
      display by name lr_ctb27m0101.*
      
      while true
         open cctb27m0102 using l_prsmsgcod
         foreach cctb27m0102 into al_cbt27m0101[l_i].pstcoddig
                                 ,al_cbt27m0101[l_i].prsmsgdstsit
                                 ,l_cadmat
                                 ,l_usrtip
                                 ,l_webusrcod
                                 ,l_caddat
                                 ,l_prsmsgltrdat
            #Busca o nome do prestador
            whenever error continue
               open cctb27m0103 using al_cbt27m0101[l_i].pstcoddig
               fetch cctb27m0103 into al_cbt27m0101[l_i].nomgrr
            whenever error stop
            if sqlca.sqlcode <> 0 then
               if sqlca.sqlcode < 0 then
                  error "Erro no SELECT cctb27m0103. ",sqlca.sqlcode,"/"
                       ,sqlca.sqlerrd[2]
                  sleep 2
                  error "Funcao ctb27m01()/",al_cbt27m0101[l_i].pstcoddig
                  exit program(1)
               end if
               if sqlca.sqlcode = 100 then
                  let al_cbt27m0101[l_i].nomgrr = "Nao encontrado"
               end if
            end if
            close cctb27m0103
            
            #Estado, Responsavel e Data/Hora
            if al_cbt27m0101[l_i].prsmsgdstsit = 1 then
               let al_cbt27m0101[l_i].estdes = "Aguardando"
               let al_cbt27m0101[l_i].codigo = l_cadmat
               whenever error continue
                  open cctb27m0104 using l_cadmat
                  fetch cctb27m0104 into al_cbt27m0101[l_i].nome
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode < 0 then
                     error "Erro no SELECT cctb27m0104. ",sqlca.sqlcode,"/"
                          ,sqlca.sqlerrd[2]
                     sleep 2
                     error "Funcao ctb27m01()/",l_cadmat
                     exit program(1)
                  end if
               end if
               close cctb27m0104
               let al_cbt27m0101_aux[l_i].datahora = l_caddat
            else
               let al_cbt27m0101[l_i].estdes = "Lida"
               let al_cbt27m0101[l_i].codigo = l_usrtip clipped, l_webusrcod using "<<<<<<<<"
               whenever error continue
                  open cctb27m0105 using l_usrtip
                                        ,l_webusrcod
                  fetch cctb27m0105 into al_cbt27m0101[l_i].nome
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  if sqlca.sqlcode < 0 then
                     error "Erro no SELECT cctb27m0105. ",sqlca.sqlcode,"/"
                          ,sqlca.sqlerrd[2]
                     sleep 2
                     error "Funcao ctb27m01()/",l_usrtip,"/",l_webusrcod
                     exit program(1)
                  end if
               end if
               close cctb27m0105
               let al_cbt27m0101_aux[l_i].datahora = l_prsmsgltrdat
            end if
            
            let l_data_def = al_cbt27m0101_aux[l_i].datahora
            let l_data_fmt = l_data_def[9,10],
                         '/',l_data_def[6,7],
                         '/',l_data_def[1,4],
                         ' ',l_data_def[12,16]
                         
            let al_cbt27m0101[l_i].datahora = l_data_fmt
            
            let l_i = l_i + 1
            if l_i > 1000 then
               error "Array ultrapassou tamanho maximo! Avise a informatica."
               exit program(1)
            end if
         end foreach
         
         call set_count(l_i - 1)
         let int_flag = false
         
         input array al_cbt27m0101 without defaults from s_ctb27m01.*
      
            before row
               let l_arr = arr_curr()
               let l_scr = scr_line()
               
               if l_delete = "N" then
                  let l_arr = 1
                  let l_scr = 1
               end if
               
               display al_cbt27m0101[l_arr].* to
                       s_ctb27m01[l_scr].*
                    
            after row 
               display al_cbt27m0101[l_arr].* to
                       s_ctb27m01[l_scr].*
            
               if l_inclui = "S" then
                  whenever error continue
                     let l_current = current
                     execute pctb27m0106 using l_prsmsgcod
                                              ,al_cbt27m0101[l_arr].pstcoddig
                                              ,al_cbt27m0101[l_arr].prsmsgdstsit
                                              ,l_current
                                              ,g_issk.usrtip
                                              ,g_issk.empcod
                                              ,g_issk.funmat
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     if sqlca.sqlcode < 0 then
                        error "Erro no INSERT pctb27m0106. ",sqlca.sqlcode,"/"
                             ,sqlca.sqlerrd[2]
                        sleep 2
                        error "Funcao ctb27m01()/",l_prsmsgcod,"/"
                             ,al_cbt27m0101[l_arr].pstcoddig,"/"
                             ,al_cbt27m0101[l_arr].prsmsgdstsit,"/"
                             ,l_current,"/",g_issk.usrtip,"/"
                             ,g_issk.empcod,"/",g_issk.funmat
                        exit program(1)
                     end if
                  end if
               end if
            
            before delete
               #let lr_ctb27m0102.*    = al_cbt27m0101[l_arr].*
               
               if al_cbt27m0101[l_arr].prsmsgdstsit = 1 then
                  whenever error continue
                     execute pctb27m0107 using l_prsmsgcod
                                              ,al_cbt27m0101[l_arr].pstcoddig
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     if sqlca.sqlcode < 0 then
                        error "Erro no DELETE pctb27m0107. ",sqlca.sqlcode,"/"
                             ,sqlca.sqlerrd[2]
                        sleep 2
                        error "Funcao ctb27m01()/",l_prsmsgcod,"/"
                             ,al_cbt27m0101[l_arr].pstcoddig
                        exit program(1)
                     end if
                  end if
               else
                  if al_cbt27m0101[l_arr].prsmsgdstsit = 2 then
                     error "Nao eh possivel excluir prestador com estado 2!"
                     let l_delete = "N"
                     display al_cbt27m0101[l_arr].pstcoddig to
                             s_ctb27m01[l_scr].pstcoddig 
                     initialize al_cbt27m0101 to null
                     let l_i = 1
                     exit input
                  end if
                  continue input
               end if            
            
            before field pstcoddig
               if l_delete = "N" then
                  display al_cbt27m0101[l_arr].* to
                          s_ctb27m01[l_scr].* 
                  let l_delete = ""
               end if

               display al_cbt27m0101[l_arr].pstcoddig to
                       s_ctb27m01[l_scr].pstcoddig attribute(reverse)
               let l_pstcoddig_ant = al_cbt27m0101[l_arr].pstcoddig
               let l_inclui = "S"
               if al_cbt27m0101[l_arr].pstcoddig is not null then
                  let l_inclui = "N"
               end if
            
            after field pstcoddig
               display al_cbt27m0101[l_arr].pstcoddig to
                       s_ctb27m01[l_scr].pstcoddig
               if al_cbt27m0101[l_arr].pstcoddig <> l_pstcoddig_ant then
                  error "Nao eh possivel alterar o prestador"
                  let al_cbt27m0101[l_arr].pstcoddig = l_pstcoddig_ant
                  display al_cbt27m0101[l_arr].pstcoddig to
                          s_ctb27m01[l_scr].pstcoddig
               end if
               if l_inclui = "S" then
                  whenever error continue
                     open cctb27m0108 using l_prsmsgcod
                                           ,al_cbt27m0101[l_arr].pstcoddig
                     fetch cctb27m0108 into l_pstcoddig
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     if sqlca.sqlcode < 0 then
                        error "Erro no SELECT cctb27m0108. ",sqlca.sqlcode,"/"
                             ,sqlca.sqlerrd[2]
                        sleep 2
                        error "Funcao ctb27m01()/",l_prsmsgcod,"/"
                             ,al_cbt27m0101[l_arr].pstcoddig
                        exit program(1)
                     end if
                  else
                     error "Ja existe cadastro para este prestador/mensagem"
                     next field pstcoddig
                  end if
               
                  whenever error continue
                     open cctb27m0103 using al_cbt27m0101[l_arr].pstcoddig
                     fetch cctb27m0103 into al_cbt27m0101[l_arr].nomgrr
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     if sqlca.sqlcode < 0 then
                        error "Erro no SELECT cctb27m0103. ",sqlca.sqlcode,"/"
                             ,sqlca.sqlerrd[2]
                        sleep 2
                        error "Funcao ctb27m01()/",al_cbt27m0101[l_arr].pstcoddig
                        exit program(1)
                     end if
                     if sqlca.sqlcode = 100 then
                        if al_cbt27m0101[l_arr].pstcoddig is not null then
                           error "Nao existe prestador com esse codigo!"
                           next field pstcoddig
                        else
                           let l_inclui = "N"
                           continue input
                        end if
                     end if
                  end if
                  close cctb27m0103
   
                  display al_cbt27m0101[l_arr].nomgrr to
                          s_ctb27m01[l_scr].nomgrr
   
                  #Estado
                  if al_cbt27m0101[l_arr].prsmsgdstsit is null then
                     let  al_cbt27m0101[l_arr].prsmsgdstsit = 1
                  end if
   
                  display al_cbt27m0101[l_arr].prsmsgdstsit to
                          s_ctb27m01[l_scr].prsmsgdstsit
               
                  #Descricao do estado
                  if al_cbt27m0101[l_arr].prsmsgdstsit = 1 then
                     let al_cbt27m0101[l_arr].estdes = "Aguardando"
                  else
                     let al_cbt27m0101[l_arr].estdes = "Lida"
                  end if
                  display al_cbt27m0101[l_arr].estdes to
                          s_ctb27m01[l_scr].estdes
               
                  #Responsavel
                  if al_cbt27m0101[l_arr].codigo is null then
                     let al_cbt27m0101[l_arr].codigo = g_issk.funmat
                  end if
               
                  display al_cbt27m0101[l_arr].codigo to
                          s_ctb27m01[l_scr].codigo
               
                  #Nome do responsavel
                  whenever error continue
                     open cctb27m0104 using al_cbt27m0101[l_arr].codigo
                     fetch cctb27m0104 into al_cbt27m0101[l_arr].nome
                  whenever error stop
                  if sqlca.sqlcode <> 0 then
                     if sqlca.sqlcode < 0 then
                        error "Erro no SELECT cctb27m0104. ",sqlca.sqlcode,"/"
                             ,sqlca.sqlerrd[2]
                        sleep 2
                        error "Funcao ctb27m01()/",al_cbt27m0101[l_arr].codigo
                        exit program(1)
                     end if
                  end if
                  close cctb27m0104
               
                  display al_cbt27m0101[l_arr].nome to
                          s_ctb27m01[l_scr].nome
         
                  #Data/hora
                  let al_cbt27m0101_aux[l_arr].datahora = current

                  let l_data_def = al_cbt27m0101_aux[l_arr].datahora
                  let l_data_fmt = l_data_def[9,10],
                               '/',l_data_def[6,7],
                               '/',l_data_def[1,4],
                               ' ',l_data_def[12,16]
                               
                  let al_cbt27m0101[l_arr].datahora = l_data_fmt
               
                  display al_cbt27m0101[l_arr].datahora to
                          s_ctb27m01[l_scr].datahora
               end if
            

            
            on key(interrupt, control-c, f17)
               exit input
         end input


      if int_flag then
         let int_flag = false
         initialize lr_ctb27m0101 to null
         clear form
         exit while
      end if

   end while
   
   close window w_ctb27m01

end function #ctb27m01

