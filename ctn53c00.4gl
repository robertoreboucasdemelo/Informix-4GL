database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_entrada record
                      datini  date,
                      horaini datetime hour to minute,
                      datfim  date,
                      horafim datetime hour to minute,
                      lgdnom  char(60),
                      cidnom  char(30),
                      ufdcod  char(02),
                      dist    decimal(8,2)
                  end record

define mr_aux     record
                      lgdtip       like datkmpalgd.lgdtip,
                      lgdnom       like datmlcl.lgdnom,
                      lgdnum       like datmlcl.lgdnum,
                      brrnom       like datmlcl.brrnom,
                      lgdcep       like datmlcl.lgdcep,
                      lgdcepcmp    like datmlcl.lgdcepcmp,
                      lclltt       like datmlcl.lclltt,
                      lcllgt       like datmlcl.lcllgt,
                      c24lclpdrcod like datmlcl.c24lclpdrcod,
                      cidnom       like datmlcl.cidnom,
                      ufdcod       like datmlcl.ufdcod
                  end record

define lr_emeviacod record
                        emeviacod like datkemevia.emeviacod
                    end record

define ws record
              retflg char (01)
          end record

#--------------------------#
 function ctn53c00_prepare()
#--------------------------#

     define l_sql    char(500)

     let l_sql = "select rec.mdtcod, ",
                       " rec.ufdcod, ",
                       " rec.cidnom, ",
                       " rec.brrnom, ",
                       " rec.caddat, ",
                       " rec.cadhor, ",
                       " rec.mdtmvtseq, ",
                       " SQRT(  POW(ABS(? - rec.lclltt),2) + ",
                              " POW(ABS(? - rec.lcllgt),2) ",
                           " ) * 108 DistanciaKM ",
                  " from datmmdtmvt rec ",
                 " Where caddat between ? and ? ",
                   " and cadhor between ? and ? ",
                 " order by 8 "

     prepare pc_ctn53c00_01 from l_sql
     declare cc_ctn53c00_01 cursor for pc_ctn53c00_01

 end function

#-------------------#
 function ctn53c00()
#-------------------#

    define l_ret   smallint,
           l_msg   char(50)

    if  not ctx25g05_rota_ativa() then
        error 'Consulta disponivel apenas com a roterização ativa'
        sleep 2
    else
        open window w_ctn53c00 at 4,2 with form 'ctn53c00'
             attribute(prompt line last)

        if  ctn53c00_entrada_dados() then
            call ctn53c00_verifica_veic()
        else
            error 'Operacao cancelada.'
            sleep 3
        end if

        close window w_ctn53c00
    end if

end function

#-------------------------------#
function ctn53c00_entrada_dados()
#-------------------------------#

    define l_ret      smallint,
           l_mensagem char(50),
           l_aux      char(65)

    initialize mr_entrada.*,
               mr_aux.*,
               l_ret,
               l_mensagem to null

    call ctn53c00_prepare()

    let int_flag = false

    input by name mr_entrada.*

        before field datini
           display by name mr_entrada.datini attribute (reverse)

        after field datini
           display by name mr_entrada.datini

           if  mr_entrada.datini is null then
               error 'A data inicial nao pode ser nula'
               next field datini
           end if

        before field horaini
           display by name mr_entrada.horaini attribute (reverse)

        after field horaini
           display by name mr_entrada.horaini

        before field datfim
           display by name mr_entrada.datfim attribute (reverse)

        after field datfim
           display by name mr_entrada.datfim

           if  mr_entrada.datfim is null then
               error 'A data final nao pode ser nula'
               next field datfim
           end if

        before field horafim
           display by name mr_entrada.horafim attribute (reverse)

        after field horafim
           display by name mr_entrada.horafim

           call ctn58c00_calcula_hora()
                returning l_ret,
                          l_mensagem

           if  l_ret <> 1 then
               error l_mensagem
               next field datini
           end if


           if  not fgl_lastkey() = fgl_keyval("up") then

               call ctx25g05("C",
                             "          INFORME O LOGRADOURO PARA PESQUISAR O VEICULO POR APROXIMACAO        ",
                             mr_aux.ufdcod,
                             mr_aux.cidnom,
                             mr_aux.lgdtip,
                             mr_aux.lgdnom,
                             mr_aux.lgdnum,
                             mr_aux.brrnom,
                             "",
                             "",
                             "",
                             "",
                             "",
                             "")
                   returning mr_aux.lgdtip,
                             mr_aux.lgdnom,
                             mr_aux.lgdnum,
                             mr_aux.brrnom,
                             l_aux,
                             mr_aux.lgdcep,
                             mr_aux.lgdcepcmp,
                             mr_aux.lclltt,
                             mr_aux.lcllgt,
                             mr_aux.c24lclpdrcod,
                             mr_aux.ufdcod,
                             mr_aux.cidnom

               if  mr_aux.lgdnom is not null then

                   if  mr_aux.c24lclpdrcod  = 3 or
                       mr_aux.c24lclpdrcod  = 4 or # PSI 252891
                       mr_aux.c24lclpdrcod  = 5 then

                       let mr_entrada.lgdnom = mr_aux.lgdtip clipped, '. ',
                                               mr_aux.lgdnom

                       if  mr_aux.lgdnum is not null then
                           let mr_entrada.lgdnom = mr_entrada.lgdnom clipped, ', ',
                                                   mr_aux.lgdnum using '<<<<<'
                       end if

                       let mr_entrada.lgdnom = mr_entrada.lgdnom clipped,
                                               ' - ', mr_aux.brrnom

                       display by name mr_aux.lgdnom

                       let mr_entrada.cidnom = mr_aux.cidnom
                       display by name mr_entrada.cidnom

                       let mr_entrada.ufdcod = mr_aux.ufdcod
                       display by name mr_entrada.ufdcod
                   else
                       error 'Validos apenas enderecos indexados'
                       next field datfim
                   end if
               else
                   error 'Endereco invalido.'
                   next field datfim
               end if
           else
               next field dataini
           end if

        after field dist

           if  mr_entrada.dist is not null then
               if  mr_entrada.dist > 10000 then
                   error 'Distancia maxima de 10000 metros ultrapassada.'
                   next field dist
               end if

               if  mr_entrada.dist < 50 then
                   error 'Distancia minina de 50 metros.'
                   next field dist
               end if
           else
               error 'Campo distancia nao pdoe ser nula.'
               next field dist
           end if

    end input

    if  not int_flag then
        return true
    else
        return false
    end if

end function

#--------------------------------#
 function ctn58c00_calcula_hora()
#--------------------------------#

    define l_hora_limite    datetime year to minute,
           l_hora_ini       datetime year to minute,
           l_hora_fim       datetime year to minute,
           l_hora_aux       char(16),
           l_ret            smallint,
           l_mensagem       char(50)

    initialize l_hora_limite,
               l_hora_ini,
               l_hora_fim,
               l_mensagem to null

    let l_ret = 1
    let l_hora_aux = ''

    let l_hora_aux    = extend(mr_entrada.datfim, year to day) clipped,' ',
                        mr_entrada.horafim
    let l_hora_fim    = l_hora_aux

    let l_hora_aux    = ''

    let l_hora_aux    = extend(mr_entrada.datini, year to day) clipped,' ',
                        mr_entrada.horaini
    let l_hora_ini    = l_hora_aux

    let l_hora_limite = (l_hora_ini + 1 units hour)

    if  (l_hora_fim = l_hora_ini) then
        let l_ret = 2
        let l_mensagem = 'O Intevalo minimo deve ser de um minuto'
    else
        if  (l_hora_ini < l_hora_fim) then

            if  (l_hora_fim > l_hora_limite) then
                let l_ret = 2
                let l_mensagem = 'O Intevalo maximo deve ser de uma hora'
            end if
        else
            let l_ret = 2
            let l_mensagem = 'Hora inicial deve ser inferior a hora final'
        end if
    end if

    return l_ret,
           l_mensagem

end function

#---------------------------------#
 function ctn53c00_verifica_veic()
#---------------------------------#

    define lr_veic record
                       dist      decimal(8,2),
                       mdtcod    like datmmdtmvt.mdtcod,
                       caddat    date,
                       cadhor    datetime hour to second,
                       ufdcod    like datmmdtmvt.ufdcod,
                       cidnom    like datmmdtmvt.cidnom,
                       brrnom    like datmmdtmvt.brrnom,
                       mdtmvtseq like datmmdtmvt.mdtmvtseq
                   end record

    define la_veic array[500] of record
                       aux       char(01),
                       dist      decimal(8,2),
                       mdtcod    like datmmdtmvt.mdtcod,
                       caddat    date,
                       cadhor    datetime hour to second,
                       ufdcod    like datmmdtmvt.ufdcod,
                       cidnom    like datmmdtmvt.cidnom,
                       brrnom    like datmmdtmvt.brrnom
                   end record

    define la_aux  array[500] of record
                       mdtmvtseq like datmmdtmvt.mdtmvtseq
                   end record

    define l_ind         smallint,
           l_arr_curr    smallint,
           l_scr_curr    smallint,
           l_msg         char(50),
           l_hora1       char(08),
           l_hora2       char(08),
           l_dist_limite decimal(8,2)

    initialize l_ind,
               l_arr_curr,
               l_scr_curr,
               la_veic,
               l_msg,
               l_hora1,
               l_hora2,
               l_dist_limite to null

    let l_hora1 = extend(mr_entrada.horaini, hour to hour) clipped, ":",
                  extend(mr_entrada.horaini, minute to minute) clipped, ":00"

    let l_hora2 = extend(mr_entrada.horafim, hour to hour) clipped, ":",
                  extend(mr_entrada.horafim, minute to minute) clipped, ":00"

    open cc_ctn53c00_01 using mr_aux.lclltt,
                              mr_aux.lcllgt,
                              mr_entrada.datini,
                              mr_entrada.datfim,
                              l_hora1,
                              l_hora2

    fetch cc_ctn53c00_01 into lr_veic.mdtcod,
                              lr_veic.ufdcod,
                              lr_veic.cidnom,
                              lr_veic.brrnom,
                              lr_veic.caddat,
                              lr_veic.cadhor,
                              lr_veic.mdtmvtseq,
                              lr_veic.dist

    case sqlca.sqlcode
        when 0

             let l_ind = 1

             let l_dist_limite = (mr_entrada.dist/1000)

             foreach cc_ctn53c00_01 into lr_veic.mdtcod,
                                         lr_veic.ufdcod,
                                         lr_veic.cidnom,
                                         lr_veic.brrnom,
                                         lr_veic.caddat,
                                         lr_veic.cadhor,
                                         lr_veic.mdtmvtseq,
                                         lr_veic.dist

                 if  lr_veic.dist < l_dist_limite then

                     let  la_veic[l_ind].aux     = " "
                     let  la_veic[l_ind].dist    = lr_veic.dist
                     let  la_veic[l_ind].mdtcod  = lr_veic.mdtcod

                     #let l_data = extend(lr_veic.caddat, day to day) clipped, "/",
                     #             extend(lr_veic.caddat, month to month) clipped, "/",
                     #             extend(lr_veic.caddat, year to year)
                     #
                     #display l_data
                     #let  la_veic[l_ind].caddat  = l_data

                     let  la_veic[l_ind].caddat  = lr_veic.caddat


                     #let l_hora3 = extend(lr_veic.cadhor, hour to hour) clipped, ":",
                     #              extend(lr_veic.cadhor, minute to minute)

                     let  la_veic[l_ind].cadhor  = lr_veic.cadhor

                     let  la_veic[l_ind].ufdcod  = lr_veic.ufdcod
                     let  la_veic[l_ind].cidnom  = lr_veic.cidnom
                     let  la_veic[l_ind].brrnom  = lr_veic.brrnom

                     let  la_aux[l_ind].mdtmvtseq = lr_veic.mdtmvtseq

                     let l_ind = l_ind + 1
                 end if

             end foreach

             if  la_veic[1].dist is null then
                 error 'Nao existem dados a serem listados.'
                 sleep 2
                 return
             end if

             open window w_ctn53c00a at 4,2 with form 'ctn53c00a'
                  attribute(prompt line last,border)

             call set_count(l_ind - 1)

             display "(F8) Seleciona " at 21,2

             display array la_veic to s_ctn53c00.*

                 #before row
                 #    let l_arr_curr = arr_curr()
                 #    let l_scr_curr = scr_line()
                 #    let la_veic[l_arr_curr].aux = ">"
                 #    display la_veic[l_arr_curr].aux to
                 #            s_ctn53c00[l_scr_curr].aux
                 #
                 #after row
                 #    let l_arr_curr = arr_curr()
                 #    let l_scr_curr = scr_line()
                 #    let la_veic[l_arr_curr].aux = ""
                 #    display la_veic[l_arr_curr].aux to
                 #            s_ctn53c00[l_scr_curr].aux

                 on key (f8)

                     display  "                  " at 21,2

                     let l_arr_curr = arr_curr()
                     call ctn44c01(la_aux[l_arr_curr].mdtmvtseq)

                     display  "(F8) Seleciona " at 21,2

             end display
             let l_msg = ""

             close window w_ctn53c00a
        when 100
             error 'Nao existem dados a serem listados.'
             sleep 2
        otherwise
             error 'ERRO: ',sqlca.sqlcode clipped, ' AVISE A INFORMATICA'
             sleep 2
    end case

end function
