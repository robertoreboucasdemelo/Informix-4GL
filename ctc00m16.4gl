#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: PSOCORRO                                                   #
# Modulo.........: ctc00m16                                                   #
# Analista Resp..: Adriano Santos                                             #
# PSI/OSF........: 198714                                                     #
#                  Modulo para cadastro das naturezas para um prestador       #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql    smallint

#---------------------------------------------------------------
function ctc00m16_prepare()
#---------------------------------------------------------------
  define l_sql     char(500)

  let l_sql = "select a.socntzcod, a.atldat, a.atlemp, "
             ," a.atlmat, a.atlusrtip, b.socntzdes     "
             ,"from dparpstntz a, datksocntz b  "
             ,"where a.pstcoddig  =  ? "
             ,"  and b.socntzcod  =  a.socntzcod "
  prepare pctc00m16001 from l_sql
  declare cctc00m16001 cursor for pctc00m16001

  let l_sql = "select socntzstt, socntzdes     "
             ," from datksocntz                "
             ," where datksocntz.socntzcod = ? "
  prepare pctc00m16002 from l_sql
  declare cctc00m16002 cursor for pctc00m16002

  let l_sql = "select socntzcod               "
             ,"from dparpstntz                "
             ,"where dparpstntz.pstcoddig = ? "
             ,"  and dparpstntz.socntzcod = ? "
  prepare pctc00m16003 from l_sql
  declare cctc00m16003 cursor for pctc00m16003

  let l_sql = " delete from dparpstntz         "
             ," where dparpstntz.pstcoddig = ? "
             ,"   and dparpstntz.socntzcod = ? "
  prepare pctc00m16004 from l_sql

  let l_sql = " insert into dparpstntz ( pstcoddig, socntzcod, atlusrtip, "
             ,"                          atlemp, atlmat, atldat  )        "
             ,"  values (?, ?, ?, ?, ?, ?)                                "
  prepare pctc00m16005 from l_sql

  let l_sql = " select funnom    "
             ," from isskfunc    "
             ," where empcod = ? "
             ,"   and funmat = ? "
             ,"   and usrtip = ? "
  prepare pctc00m16006 from l_sql
  declare cctc00m16006 cursor for pctc00m16006

  let m_prep_sql = true

end function



#---------------------------------------------------------------
function ctc00m16(param)
#---------------------------------------------------------------

 define param        record
    pstcoddig        like dparpstntz.pstcoddig,
    rspnom           like dpaksocor.rspnom
 end record

 define a_ctc00m16   array[300] of record
    socntzcod        like dparpstntz.socntzcod,
    socntzdes        like datksocntz.socntzdes,
    atldat           like dparpstntz.atldat,
    altfunnom        like isskfunc.funnom
 end record

 define ws           record
    socntzcod        like dparpstntz.socntzcod,
    socntzstt        like datksocntz.socntzstt,
    atlemp           like dparpstntz.atlemp,
    atlmat           like dparpstntz.atlmat,
    atlusrtip        like dparpstntz.atlusrtip,
    operacao         char (01),
    confirma         char (01)
 end record

 define l_sql        char(100),
        l_result     smallint

 define arr_aux      integer
 define scr_aux      integer

 define l_prshstdes  char(2000)

# if not get_niv_mod(g_issk.prgsgl, "ctc00m16") then
#    error " Modulo sem nivel de consulta e atualizacao!"
#    return
# end if

 initialize a_ctc00m16  to null
 initialize ws.*        to null
 let int_flag  =  false
 let arr_aux   =  1

 if m_prep_sql is null or
     m_prep_sql <> true then
     call ctc00m16_prepare()
 end if

 open window w_ctc00m16 at 6,2 with form "ctc00m16"
      attribute(form line first, comment line last - 2)

 display by name param.pstcoddig   attribute(reverse)
 display by name param.rspnom      attribute(reverse)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    message " (F17)Abandona"
 else
    message " (F17)Abandona, (F1)Inclui, (F2)Exclui"
 end if

 open cctc00m16001 using param.pstcoddig
 foreach cctc00m16001 into  a_ctc00m16[arr_aux].socntzcod,
                            a_ctc00m16[arr_aux].atldat,
                            ws.atlemp,
                            ws.atlmat,
                            ws.atlusrtip,
                            a_ctc00m16[arr_aux].socntzdes

    call ctc00m16_func (ws.atlemp, ws.atlmat, ws.atlusrtip)
         returning a_ctc00m16[arr_aux].altfunnom

    let arr_aux = arr_aux + 1
    if arr_aux  >  300   then
       error " Limite excedido, prestador com mais de 300 tipos de natureza!"
       exit foreach
    end if
 end foreach


 #---------------------------------------------------------------
 # Nivel de acesso apenas para consulta
 #---------------------------------------------------------------
 call set_count(arr_aux-1)

 if g_issk.acsnivcod  <  g_issk.acsnivatl   then
    display array a_ctc00m16 to s_ctc00m16.*

       on key (interrupt,control-c)
          initialize a_ctc00m16  to null
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

    input array a_ctc00m16  without defaults from  s_ctc00m16.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          if arr_aux <= arr_count()  then
             let ws.operacao    = "a"
             let ws.socntzcod   =  a_ctc00m16[arr_aux].socntzcod
          end if

       before insert
          let ws.operacao = "i"
          initialize a_ctc00m16[arr_aux]  to null
          display a_ctc00m16[arr_aux].*  to  s_ctc00m16[scr_aux].*

       before field socntzcod
          display a_ctc00m16[arr_aux].socntzcod to s_ctc00m16[scr_aux].socntzcod attribute (reverse)

       after field socntzcod
          display a_ctc00m16[arr_aux].socntzcod to s_ctc00m16[scr_aux].socntzcod

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = fgl_keyval("left")   then
             let ws.operacao = " "
          end if

          if a_ctc00m16[arr_aux].socntzcod   is null   then
             error " Tipo de natureza deve ser informado!"
             #chamar pop-up com opcoes de tipo de natureza
             let l_sql = "select socntzcod, socntzdes from datksocntz ",
                         " where socntzstt = 'A' order by socntzdes"
             call ofgrc001_popup(10, 15, "Tipos de Natureza", "Codigo", "Descricao", "N",
                                 l_sql, "", "D")
                  returning l_result, a_ctc00m16[arr_aux].socntzcod, a_ctc00m16[arr_aux].socntzdes
             next field socntzcod
          else
             #caso tenha digitado um codigo - buscar descricao e situação do tipo de natureza
             open cctc00m16002 using a_ctc00m16[arr_aux].socntzcod
             fetch cctc00m16002 into ws.socntzstt,
                                     a_ctc00m16[arr_aux].socntzdes
             if sqlca.sqlcode  =  notfound   then
                error " Tipo de natureza nao cadastrada!"
                next field socntzcod
             end if
             if ws.socntzstt  <>  "A"   then
                error " Tipo de natureza cancelada!"
                next field socntzcod
             end if
          end if

          display a_ctc00m16[arr_aux].socntzdes to s_ctc00m16[scr_aux].socntzdes

          #-------------------------------------------------------------
          # Verifica se natureza ja' cadastrada (inclusao)
          #-------------------------------------------------------------
          if ws.operacao  =  "i"   then
             open cctc00m16003 using param.pstcoddig,
                                     a_ctc00m16[arr_aux].socntzcod
             fetch cctc00m16003 into ws.socntzcod

             if sqlca.sqlcode  =  0   then
                error " Tipo de natureza ja' cadastrada p/ este prestador!"
                next field socntzcod
             end if

             let a_ctc00m16[arr_aux].atldat = today

             display a_ctc00m16[arr_aux].atldat      to
                     s_ctc00m16[scr_aux].atldat

             call ctc00m16_func (g_issk.empcod, g_issk.funmat, g_issk.usrtip)
                  returning a_ctc00m16[arr_aux].altfunnom

             display a_ctc00m16[arr_aux].altfunnom to s_ctc00m16[scr_aux].altfunnom
          end if

          if ws.operacao  =  "a"   then
             if ws.socntzcod  <>  a_ctc00m16[arr_aux].socntzcod    then
                error " Tipo de natureza nao deve ser alterado!"
                next field socntzcod
             end if
          end if

      on key (interrupt)
          exit input

      before delete
         let ws.operacao = "d"
         if a_ctc00m16[arr_aux].socntzcod   is null   then
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
               execute pctc00m16004 using param.pstcoddig,
                                          a_ctc00m16[arr_aux].socntzcod
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  error "Erro DELETE pctc00m16004 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
                  error "ctc00m16 ctc00m16_exclui() ", a_ctc00m16[arr_aux].socntzcod
               end if

               let l_prshstdes =
                   "Natureza [", a_ctc00m16[arr_aux].socntzcod using "<<<<&", " - ",
                   a_ctc00m16[arr_aux].socntzdes clipped,"] excluida!"

               call ctc00m02_grava_hist(param.pstcoddig,
                                        l_prshstdes,"E")
            commit work
            initialize a_ctc00m16[arr_aux].* to null
            display    a_ctc00m16[arr_aux].* to s_ctc00m16[scr_aux].*
         end if

       after row
          if ws.operacao = "i" then
             begin work
             whenever error continue
             execute pctc00m16005 using param.pstcoddig,
                                        a_ctc00m16[arr_aux].socntzcod,
                                        g_issk.usrtip,
                                        g_issk.empcod,
                                        g_issk.funmat,
                                        a_ctc00m16[arr_aux].atldat
             whenever error stop
             if sqlca.sqlcode <> 0 then
                error "Erro DELETE pctc00m16004 / ", sqlca.sqlcode, " / ", sqlca.sqlerrd[2] sleep 2
                error "ctc00m16 ctc00m16_inclui() ", a_ctc00m16[arr_aux].socntzcod
              end if

              let l_prshstdes =
                  "Natureza [", a_ctc00m16[arr_aux].socntzcod using "<<<<&", " - ",
                  a_ctc00m16[arr_aux].socntzdes clipped,"] incluida!"

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

 close cctc00m16001

 close window w_ctc00m16

end function   ###-- ctc00m16


#---------------------------------------------------------
function ctc00m16_func(param)
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

 open cctc00m16006 using param.empcod, param.funmat, param.usrtip
 fetch cctc00m16006 into ws.funnom
 if sqlca.sqlcode  =  notfound   then
    error "Problemas ao buscar nome do funcionario do cadastro do tipo de natureza!"
 end if

 return ws.funnom

end function   # ctc00m16_func


