###############################################################################
# Nome do Modulo: CTA05M05                                           Wagner   #
#                                                                             #
# Resumo do acompanhamento                                           Mai/2001 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 01/03/2002  CORREIO      Wagner       Incluir dptsgl psocor nas pesquisas.  #
#-----------------------------------------------------------------------------#
# 15/11/2006  psi205206    RUiz         Alteracoes para Azul Seguros          #
#-----------------------------------------------------------------------------#
# 11/10/2010  Carla Rampazzo PSI 260606 Tratar Fluxo de Reclamacao p/PSS(107) #
#-----------------------------------------------------------------------------#
# 14/02/2011 Carla Rampazzo PSI         Fluxo de Reclamacao p/ PortoSeg(518)  #
#-----------------------------------------------------------------------------#

###############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


#--------------------------------------------------------------------
 function cta05m05()
#--------------------------------------------------------------------

 define d_cta05m05   record
    rcldtini         date,
    rcldtfim         date,
    rclsglast        char (01),
    rcltotpen        dec (11,0),
    rcltotana        dec (11,0),
    rcltotagu        dec (11,0),
    rcltotsol        dec (11,0),
    rcltotimp        dec (11,0),
    rcltotaco        dec (11,0),
    rcltxt           char (59),
    rcltotlin        dec (11,0)
 end record

 define a_cta05m05   array[50] of record
    rclastcod        char (03),
    rclastpen        dec (11,0),
    rclastana        dec (11,0),
    rclastagu        dec (11,0),
    rclastsol        dec (11,0),
    rclastimp        dec (11,0),
    rclastaco        dec (11,0)
 end record

 define m_cta05m05   array[100] of record
    rclastcod        char (03),
    rcltot           array[06] of dec(11,0)
 end record

 define ws           record
    rclastcod        like datmligacao.c24astcod   ,
    c24astcod        like datmligacao.c24astcod   ,
    c24astdes        like datkassunto.c24astdes   ,
    c24rclsitcod     like datmsitrecl.c24rclsitcod,
    lignum           like datmligacao.lignum
 end record

 define arr_aux      smallint
 define arr_aux2     smallint
 define scr_aux      smallint

 define sql_comando  char (500)


#--------------------------------------------------------------------
# Cursor para obtencao da ultima situacao da reclamacao
#--------------------------------------------------------------------
 let sql_comando = "select c24rclsitcod",
                   "  from datmsitrecl  ",
                   " where lignum = ?   ",
                   "   and c24rclsitcod = (select max(c24rclsitcod)",
                                          "  from datmsitrecl",
                                          " where lignum = ?)"

 prepare select_sitrecl from sql_comando
 declare c_cta05m05_sitrecl cursor with hold for select_sitrecl

#--------------------------------------------------------------------
# Cursor para obtencao dos dados adicionais da reclamacao
#--------------------------------------------------------------------
 let sql_comando = "select datmligacao.c24astcod, ",
                   "       datmligacao.lignum     ",
                   "  from datmligacao ",
                   " where datmligacao.ligdat between ? and ? "

 prepare select_ligrecl from sql_comando
 declare c_cta05m05_ligrecl cursor with hold for select_ligrecl

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do assunto da reclamacao
#--------------------------------------------------------------------
 let sql_comando = "select c24astcod, c24astdes from datkassunto",
                   " where c24astcod = ? "

 prepare select_assunto from sql_comando
 declare c_cta05m05_assunto cursor with hold for select_assunto

#--------------------------------------------------------------------
# Cursor para carga da matriz
#--------------------------------------------------------------------
 let sql_comando = "select c24astcod from datkassunto",
                   " where c24astagp = ? "

 prepare select_matriz from sql_comando
 declare c_cta05m05_matriz cursor with hold for select_matriz


 open window w_cta05m05 at 06,02 with form "cta05m05"
             attribute(form line 1)

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
#set isolation to dirty read
 initialize a_cta05m05    to null
 initialize ws.*          to null

 while true
    let int_flag             = false
    clear form
    initialize d_cta05m05.* to null
    initialize a_cta05m05   to null
    initialize m_cta05m05   to null
    let d_cta05m05.rcldtini = today
    let d_cta05m05.rcldtfim = today


    input by name d_cta05m05.rcldtini,
                  d_cta05m05.rcldtfim,
                  d_cta05m05.rclsglast without defaults

       before field rcldtini
          display by name d_cta05m05.rcldtini  attribute (reverse)

       after  field rcldtini
          if d_cta05m05.rcldtini is null  then
             let d_cta05m05.rcldtini = today
          end if
          display by name d_cta05m05.rcldtini

       before field rcldtfim
          display by name d_cta05m05.rcldtfim  attribute (reverse)

       after  field rcldtfim
          display by name d_cta05m05.rcldtfim

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field rcldtini
          end if

          if d_cta05m05.rcldtfim is null  then
             let d_cta05m05.rcldtfim = today
             display by name d_cta05m05.rcldtfim
          end if

          if d_cta05m05.rcldtfim < d_cta05m05.rcldtini then
              error " Data final nao pode ser menor que data inicial!"
              next field rcldtfim
           end if

           if (d_cta05m05.rcldtfim - d_cta05m05.rcldtini) > 15  then
              error " Periodo da pesquisa nao pode ser superior a 15 dias!"
              next field rcldtfim
           end if

       before field rclsglast
          display by name d_cta05m05.rclsglast  attribute (reverse)

       after  field rclsglast
          display by name d_cta05m05.rclsglast

          if fgl_lastkey() = fgl_keyval ("up")     or
             fgl_lastkey() = fgl_keyval ("left")   then
             next field rcldtfim
          end if


          if g_issk.dptsgl = "ct24hs" or
             g_issk.dptsgl = "psocor" or
             g_issk.dptsgl = "dsvatd" or
             g_issk.dptsgl = "tlprod" or
             g_issk.dptsgl = "desenv" or
             g_issk.dptsgl = "riojan" and
            (g_issk.funmat =  68787   or g_issk.funmat = 68822) then
             # Usuario ok
          else
             let d_cta05m05.rclsglast = "X"
             exit input
          end if

          if d_cta05m05.rclsglast is null  then
             error " Informar W ou X(PORTO) ou K(AZUL) ou 1(PSS) ou 5(PortoSeg)!"
             next field  rclsglast
          end if

          if d_cta05m05.rclsglast <> "W"   and
             d_cta05m05.rclsglast <> "X"   and
             d_cta05m05.rclsglast <> "1"   and
             d_cta05m05.rclsglast <> "5"   and
             d_cta05m05.rclsglast <> "K"   then

             error " Disponivel so p/ siglas W e X(PORTO), K(AZUL), 1(PSS) ou 5(PortoSeg)!"
             next field  rclsglast
          end if

          exit input

       on key (interrupt)
          exit input

    end input

    if int_flag = true  then
       exit while
    end if

    message " Aguarde, pesquisando..."  attribute(reverse)

    let arr_aux = 1
    open c_cta05m05_matriz using d_cta05m05.rclsglast
    foreach c_cta05m05_matriz into ws.c24astcod
       let m_cta05m05[arr_aux].rclastcod = ws.c24astcod
       let m_cta05m05[arr_aux].rcltot[1] = 0
       let m_cta05m05[arr_aux].rcltot[2] = 0
       let m_cta05m05[arr_aux].rcltot[3] = 0
       let m_cta05m05[arr_aux].rcltot[4] = 0
       let m_cta05m05[arr_aux].rcltot[5] = 0
       let m_cta05m05[arr_aux].rcltot[6] = 0
       let arr_aux = arr_aux + 1
    end foreach

    open c_cta05m05_ligrecl  using  d_cta05m05.rcldtini,
                                    d_cta05m05.rcldtfim

    foreach c_cta05m05_ligrecl  into ws.rclastcod, ws.lignum

       if ws.rclastcod[1,1] <> d_cta05m05.rclsglast then
          continue foreach
       end if

       open  c_cta05m05_sitrecl  using  ws.lignum,
                                        ws.lignum
       fetch c_cta05m05_sitrecl  into   ws.c24rclsitcod
       close c_cta05m05_sitrecl

       for arr_aux = 1 to 100
           if m_cta05m05[arr_aux].rclastcod is null then
              let arr_aux = 100
              exit for
           else
              if m_cta05m05[arr_aux].rclastcod = ws.rclastcod then
                 exit for
              end if
           end if
       end for

       case ws.c24rclsitcod
           when  0 let m_cta05m05[arr_aux].rcltot[1] =
                       m_cta05m05[arr_aux].rcltot[1] + 1

           when 10 let m_cta05m05[arr_aux].rcltot[2] =
                       m_cta05m05[arr_aux].rcltot[2] + 1

           when 15 let m_cta05m05[arr_aux].rcltot[3] =
                       m_cta05m05[arr_aux].rcltot[3] + 1

           when 20 let m_cta05m05[arr_aux].rcltot[4] =
                       m_cta05m05[arr_aux].rcltot[4] + 1

           when 30 let m_cta05m05[arr_aux].rcltot[5] =
                       m_cta05m05[arr_aux].rcltot[5] + 1

           when 40 let m_cta05m05[arr_aux].rcltot[6] =
                       m_cta05m05[arr_aux].rcltot[6] + 1
       end case

    end foreach

    let d_cta05m05.rcltotpen = 0
    let d_cta05m05.rcltotana = 0
    let d_cta05m05.rcltotagu = 0
    let d_cta05m05.rcltotsol = 0
    let d_cta05m05.rcltotimp = 0
    let d_cta05m05.rcltotaco = 0

    let arr_aux = 1

    for arr_aux2 = 1 to 100
        if m_cta05m05[arr_aux2].rclastcod is not null then
           let a_cta05m05[arr_aux].rclastcod = m_cta05m05[arr_aux2].rclastcod
           let a_cta05m05[arr_aux].rclastpen = m_cta05m05[arr_aux2].rcltot[1]
           let a_cta05m05[arr_aux].rclastana = m_cta05m05[arr_aux2].rcltot[2]
           let a_cta05m05[arr_aux].rclastagu = m_cta05m05[arr_aux2].rcltot[3]
           let a_cta05m05[arr_aux].rclastsol = m_cta05m05[arr_aux2].rcltot[4]
           let a_cta05m05[arr_aux].rclastimp = m_cta05m05[arr_aux2].rcltot[5]
           let a_cta05m05[arr_aux].rclastaco = m_cta05m05[arr_aux2].rcltot[6]
           let d_cta05m05.rcltotpen          = d_cta05m05.rcltotpen +
                                               m_cta05m05[arr_aux2].rcltot[1]
           let d_cta05m05.rcltotana          = d_cta05m05.rcltotana +
                                               m_cta05m05[arr_aux2].rcltot[2]
           let d_cta05m05.rcltotagu          = d_cta05m05.rcltotagu +
                                               m_cta05m05[arr_aux2].rcltot[3]
           let d_cta05m05.rcltotsol          = d_cta05m05.rcltotsol +
                                               m_cta05m05[arr_aux2].rcltot[4]
           let d_cta05m05.rcltotimp          = d_cta05m05.rcltotimp +
                                               m_cta05m05[arr_aux2].rcltot[5]
           let d_cta05m05.rcltotaco          = d_cta05m05.rcltotaco +
                                               m_cta05m05[arr_aux2].rcltot[6]
           let arr_aux = arr_aux + 1
        else
           exit for
        end if
    end for

    call set_count(arr_aux-1)

    message " (F17)Abandona"

    display by name  d_cta05m05.rcltotpen, d_cta05m05.rcltotana,
                     d_cta05m05.rcltotagu, d_cta05m05.rcltotsol,
                     d_cta05m05.rcltotimp, d_cta05m05.rcltotaco

    options insert  key  F35,
            delete  key  F36

    input array a_cta05m05 without defaults from s_cta05m05.*

         before row
            let arr_aux = arr_curr()
            let scr_aux = scr_line()

         before field rclastcod
            let ws.rclastcod = a_cta05m05[arr_aux].rclastcod

            open  c_cta05m05_assunto  using  a_cta05m05[arr_aux].rclastcod
            fetch c_cta05m05_assunto  into   ws.c24astcod, ws.c24astdes
            close c_cta05m05_assunto

            let d_cta05m05.rcltxt    = "Total da linha: ",ws.c24astcod,
                                        "-", ws.c24astdes
            let d_cta05m05.rcltotlin = a_cta05m05[arr_aux].rclastpen +
                                       a_cta05m05[arr_aux].rclastana +
                                       a_cta05m05[arr_aux].rclastagu +
                                       a_cta05m05[arr_aux].rclastsol +
                                       a_cta05m05[arr_aux].rclastimp +
                                       a_cta05m05[arr_aux].rclastaco

            display by name d_cta05m05.rcltxt
            display by name d_cta05m05.rcltotlin attribute(reverse)


         after  field rclastcod
            let a_cta05m05[arr_aux].rclastcod = ws.rclastcod
            display a_cta05m05[arr_aux].rclastcod to
                    s_cta05m05[scr_aux].rclastcod


         on key (interrupt)
            initialize a_cta05m05 to null
            exit input

    end input

    let int_flag = false

 end while

 let int_flag = false
#set lock mode to wait
 close window w_cta05m05

end function  ##-- cta05m05

