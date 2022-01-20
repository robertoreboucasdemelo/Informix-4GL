#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: CENTRAL 24H                                                #
# Modulo.........: ctc00m11                                                   #
# Analista Resp..: Priscila Staingel                                          #
# PSI/OSF........: 198714                                                     #
#                  Modulo para cadastro dos tipos de assistencia para um      #
#                  prestador                                                  #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 07/08/2007 Burini          CT7082424  Alteração na inclusão do historico    #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql    smallint

#---------------------------------------------------------------
function ctc00m11_prepare()
#---------------------------------------------------------------
  define l_sql     char(500)

  let l_sql = "select a.asitipcod, a.caddat, a.cademp, "
             ," a.cadmat, a.cadusrtip, b.asitipdes                  "
             ,"from datrassprs a, datkasitip b  "
             ,"where a.pstcoddig  =  ? "
             ,"  and b.asitipcod  =  a.asitipcod "
  prepare pctc00m11001 from l_sql
  declare cctc00m11001 cursor for pctc00m11001

  let l_sql = "select asitipstt, asitipdes     "
             ," from datkasitip                "
             ," where datkasitip.asitipcod = ? "
  prepare pctc00m11002 from l_sql
  declare cctc00m11002 cursor for pctc00m11002

  let l_sql = "select asitipcod               "
             ,"from datrassprs                "
             ,"where datrassprs.pstcoddig = ? "
             ,"  and datrassprs.asitipcod = ? "
  prepare pctc00m11003 from l_sql
  declare cctc00m11003 cursor for pctc00m11003

  let l_sql = " delete from datrassprs         "
             ," where datrassprs.pstcoddig = ? "
             ,"   and datrassprs.asitipcod = ? "
  prepare pctc00m11004 from l_sql

  let l_sql = " insert into datrassprs ( pstcoddig, asitipcod, cadusrtip, "
             ,"                          cademp, cadmat, caddat  )        "
             ,"  values (?, ?, ?, ?, ?, ?)                                "
  prepare pctc00m11005 from l_sql

  let l_sql = " select funnom    "
             ," from isskfunc    "
             ," where empcod = ? "
             ,"   and funmat = ? "
             ,"   and usrtip = ? "
  prepare pctc00m11006 from l_sql
  declare cctc00m11006 cursor for pctc00m11006

  let m_prep_sql = true

end function



#---------------------------------------------------------------
function ctc00m11(param)
#---------------------------------------------------------------

 define param        record
    pstcoddig        like datrassprs.pstcoddig,
    rspnom           like dpaksocor.rspnom
 end record

 define a_ctc00m11   array[30] of record
    asitipcod        like datrassprs.asitipcod,
    asitipdes        like datkasitip.asitipdes,
    caddat           like datrassprs.caddat,
    cadfunnom        like isskfunc.funnom
 end record

 define ws           record
    asitipcod        like datrassprs.asitipcod,
    asitipstt        like datkasitip.asitipstt,
    cademp           like datrassprs.cademp,
    cadmat           like datrassprs.cadmat,
    cadusrtip        like datrassprs.cadusrtip,
    operacao         char (01),
    confirma         char (01)
 end record

 define l_sql        char(100),
        l_result     smallint

 define arr_aux      integer
 define scr_aux      integer

 define l_prshstdes  char(2000)

# if not get_niv_mod(g_issk.prgsgl, "ctc00m11") then
#    error " Modulo sem nivel de consulta e atualizacao!"
#    return
# end if

 initialize a_ctc00m11  to null
 initialize ws.*        to null
 let int_flag  =  false
 let arr_aux   =  1

 if m_prep_sql is null or
     m_prep_sql <> true then
     call ctc00m11_prepare()
 end if

 open window w_ctc00m11 at 6,2 with form "ctc00m11"
      attribute(form line first, comment line last - 2)

 display by name param.pstcoddig   attribute(reverse)
 display by name param.rspnom      attribute(reverse)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    message " (F17)Abandona"
 else
    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"
 end if

 open cctc00m11001 using param.pstcoddig
 foreach cctc00m11001 into  a_ctc00m11[arr_aux].asitipcod,
                            a_ctc00m11[arr_aux].caddat,
                            ws.cademp,
                            ws.cadmat,
                            ws.cadusrtip,
                            a_ctc00m11[arr_aux].asitipdes

    call ctc00m11_func (ws.cademp, ws.cadmat, ws.cadusrtip)
         returning a_ctc00m11[arr_aux].cadfunnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  30   then
       error " Limite excedido, socorrista com mais de 30 tipos de assistencia!"
       exit foreach
    end if
 end foreach


 #---------------------------------------------------------------
 # Nivel de acesso apenas para consulta
 #---------------------------------------------------------------
 call set_count(arr_aux-1)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display array a_ctc00m11 to s_ctc00m11.*

       on key (interrupt,control-c)
          initialize a_ctc00m11  to null
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

    let int_flag = false

    input array a_ctc00m11  without defaults from  s_ctc00m11.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao    = "a"
             let ws.asitipcod   =  a_ctc00m11[arr_aux].asitipcod
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc00m11[arr_aux]  to null
          display a_ctc00m11[arr_aux].*  to  s_ctc00m11[scr_aux].*

       before field asitipcod
          display a_ctc00m11[arr_aux].asitipcod to s_ctc00m11[scr_aux].asitipcod attribute (reverse)

       after field asitipcod
          display a_ctc00m11[arr_aux].asitipcod to s_ctc00m11[scr_aux].asitipcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc00m11[arr_aux].asitipcod   is null   then
             error " Tipo de assistencia deve ser informado!"
             #chamar pop-up com opcoes de tipo de assistencia
             let l_sql = "select asitipcod, asitipdes from datkasitip ",
                         " where asitipstt = 'A' order by asitipdes"
             call ofgrc001_popup(10, 15, "Tipos de Assistencia", "Codigo", "Descricao", "N",
                                 l_sql, "", "D")
                  returning l_result, a_ctc00m11[arr_aux].asitipcod, a_ctc00m11[arr_aux].asitipdes
             next field asitipcod
          else
             #caso tenha digitado um codigo - buscar descricao e situação do tipo de assistencia
             open cctc00m11002 using a_ctc00m11[arr_aux].asitipcod
             fetch cctc00m11002 into ws.asitipstt,
                                     a_ctc00m11[arr_aux].asitipdes
             if sqlca.sqlcode  =  notfound   then
                error " Tipo de assistencia nao cadastrada!"
                next field asitipcod
             end if
             if ws.asitipstt  <>  "A"   then
                error " Tipo de assistencia cancelada!"
                next field asitipcod
             end if
          end if

          display a_ctc00m11[arr_aux].asitipdes to s_ctc00m11[scr_aux].asitipdes

          #-------------------------------------------------------------
          # Verifica se assistencia ja' cadastrada (inclusao)
          #-------------------------------------------------------------
          if ws.operacao  =  "i"   then
             open cctc00m11003 using param.pstcoddig,
                                     a_ctc00m11[arr_aux].asitipcod
             fetch cctc00m11003 into ws.asitipcod

             if sqlca.sqlcode  =  0   then
                error " Tipo de assistencia ja' cadastrada p/ este socorrista!"
                next field asitipcod
             end if

             let a_ctc00m11[arr_aux].caddat = today

             display a_ctc00m11[arr_aux].caddat      to
                     s_ctc00m11[scr_aux].caddat

             call ctc00m11_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)
                  returning a_ctc00m11[arr_aux].cadfunnom

             display a_ctc00m11[arr_aux].cadfunnom to s_ctc00m11[scr_aux].cadfunnom
          end if

          if ws.operacao  =  "a"   then
             if ws.asitipcod  <>  a_ctc00m11[arr_aux].asitipcod    then
                error " Tipo de assistencia nao deve ser alterado!"
                next field asitipcod
             end if
          end if

      on key (interrupt)
          exit input

      before delete
         let ws.operacao = "d"
         if a_ctc00m11[arr_aux].asitipcod   is null   then
            continue input
         else
            let  ws.confirma = "N"
            call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
                 returning ws.confirma

            if ws.confirma = "N" then
               exit input
            end if

            begin work
               whenever error continue
               execute pctc00m11004 using param.pstcoddig,
                                          a_ctc00m11[arr_aux].asitipcod
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error "Erro DELETE pctc00m11004 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
                  error "CTC00m11 ctc00m11_exclui() ", a_ctc00m11[arr_aux].asitipcod
               end if

               let l_prshstdes =
                   "Assistencia [", a_ctc00m11[arr_aux].asitipcod using "<<<<&", " - ",
                   a_ctc00m11[arr_aux].asitipdes clipped,"] excluida!"

               call ctc00m02_grava_hist(param.pstcoddig,
                                        l_prshstdes,"E")
            commit work
            initialize a_ctc00m11[arr_aux].* to null
            display    a_ctc00m11[arr_aux].* to s_ctc00m11[scr_aux].*
         end if

       after row
          if ws.operacao = "i" then
             begin work
             whenever error continue
             execute pctc00m11005 using param.pstcoddig,
                                        a_ctc00m11[arr_aux].asitipcod,
                                        g_issk.usrtip,
                                        g_issk.empcod,
                                        g_issk.funmat,
                                        a_ctc00m11[arr_aux].caddat
             whenever error stop
             if sqlca.sqlcode <> 0 then
                error "Erro DELETE pctc00m11004 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
                error "CTC00m11 ctc00m11_inclui() ", a_ctc00m11[arr_aux].asitipcod
              end if

              let l_prshstdes =
                  "Assistencia [", a_ctc00m11[arr_aux].asitipcod using "<<<<&", " - ",
                  a_ctc00m11[arr_aux].asitipdes clipped,"] incluida!"

              call ctc00m02_grava_hist(param.pstcoddig,
                                       l_prshstdes,"I")
             commit work
             let ws.operacao = " "
          end if

    end input

    if int_flag   then
       exit while
    end if

 end while

 let int_flag = false

 close cctc00m11001

 close window w_ctc00m11

end function   ###-- ctc00m11


#---------------------------------------------------------
function ctc00m11_func(param)
#---------------------------------------------------------

 define param         record
    empcod            like isskfunc.empcod,
    funmat            like isskfunc.funmat,
    usrtip            like isskfunc.usrtip
 end record

 define ws            record
    funnom            like isskfunc.funnom
 end record


 initialize ws.*    to null

 open cctc00m11006 using param.empcod, param.funmat, param.usrtip
 fetch cctc00m11006 into ws.funnom
 if sqlca.sqlcode  =  notfound   then
    error "Problemas ao buscar nome do funcionario do cadastro do tipo de assistencia!"
 end if

 return ws.funnom

end function   # ctc00m11_func


