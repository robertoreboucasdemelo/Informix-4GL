{----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: CTS00M41.4GL                                              #
# ANALISTA RESP..: SERGIO BURINI                                             #
# PSI/OSF........: 254924                                                    #
# OBJETIVO.......: TOTALIZADOR DE SERVIÇOS                                   #
#............................................................................#
# DESENVOLVIMENTO: SERGIO BURINI                                             #
# LIBERACAO......: 07/04/2010                                                #
#............................................................................}

database porto

 define mr_entrada record
     tipo      smallint,
     tipodes   char(04),
     atddat    like datmservico.atddat,
     empcod    like gabkemp.empcod,
     empdes    like gabkemp.empnom,
     cidsednom like datmlcl.cidnom,
     ufdcodsed like datmlcl.ufdcod,
     atdetpcod like datketapa.atdetpcod,
     atdetpdes like datketapa.atdetpdes
 end record

 define ma_total array[24] of record
     atdhor     char(03),
     qtdsrvimd  integer,
     qtdsrvprg  integer,
     qtdsrvtot  integer,
     qtd1  integer,
     qtd2  integer,
     qtd3  integer,
     qtd4  integer,
     qtd5  integer
 end record

 define mr_result record
     qtdtotsrvimd integer,
     qtdtotsrvprg integer,
     qtdtotsrv    integer,
     qtdtotsrv1 integer,
     qtdtotsrv2 integer,
     qtdtotsrv3 integer,
     qtdtotsrv4 integer,
     qtdtotsrv5 integer
 end record

 define mr_aux record
     cidcod    like datmsrvrgl.cidcod,
     cidnom    like glakcid.cidnom,
     ufdcod    like glakcid.ufdcod,
     cidcodsed like datmsrvrgl.cidcod,
     cidsednom like glakcid.cidnom,
     ufdcodsed like glakcid.ufdcod,
     asitipcod like datmservico.asitipcod,
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano,
     atddatprg char(020),
     atdhorprg like datmservico.atdhorprg
 end record

 define m_ind  smallint,
        m_hora smallint

#-------------------#
 function cts00m41()
#-------------------#

     define l_mensagem char(100),
            l_retorno  smallint,
            l_cidade   char(50),
            l_origem   like datmservico.atdsrvorg

     open window w_cts00m41 at 3,2 with form 'cts00m41'
       attribute(form line 1, border)

     while true

          initialize mr_entrada.*,
                     ma_total,
                     mr_aux.*,
                     mr_result to null

          let int_flag = false

          clear form

          input by name mr_entrada.tipo,
                        mr_entrada.atddat,
                        mr_entrada.empcod,
                        mr_entrada.cidsednom,
                        mr_entrada.ufdcodsed,
                        mr_entrada.atdetpcod

              after field tipo

                 if  mr_entrada.tipo is null or
                     mr_entrada.tipo = "" then
                     let mr_entrada.tipo = 1
                     display by name mr_entrada.tipo
                 else
                     if  mr_entrada.tipo <> 1 and
                         mr_entrada.tipo <> 2 then
                         let mr_entrada.tipo = " "
                         let mr_entrada.tipodes = " "
                         display by name mr_entrada.tipodes
                         error 'Opção inválida.'
                         next field tipo
                     end if
                 end if

                 if  mr_entrada.tipo = 1 then
                     let mr_entrada.tipodes = "AUTO"
                 else
                     let mr_entrada.tipodes = "RE"
                 end if

                 display by name mr_entrada.tipodes

              after field atddat

                 if  mr_entrada.atddat is null or
                     mr_entrada.atddat = " " then
                     let mr_entrada.atddat = today
                 end if

                 display by name mr_entrada.atddat

              after field empcod

                 if  mr_entrada.empcod is not null and
                     mr_entrada.empcod <> " " then
                     call cty14g00_empresa(1,mr_entrada.empcod)
                          returning l_retorno,
                                    l_mensagem,
                                    mr_entrada.empdes

                     if  l_retorno <> 1 then
                         error "Empresa nao cadastrada."

                         call cty14g00_popup_empresa()
                              returning l_retorno,
                                        mr_entrada.empcod,
                                        mr_entrada.empdes
                         next field empcod
                     end if

                     display by name mr_entrada.empdes
                     display by name mr_entrada.empcod
                 end if

              after field cidsednom

                 if  mr_entrada.cidsednom is not null and
                     mr_entrada.cidsednom <> " " then
                     next field ufdcodsed
                 else
                     let mr_entrada.ufdcodsed = null
                     display by name mr_entrada.ufdcodsed
                     if  fgl_lastkey() = fgl_keyval("up")   or
                         fgl_lastkey() = fgl_keyval("left") then
                         next field empcod
                     else
                         next field atdetpcod
                     end if
                 end if

             after field ufdcodsed

                 if  mr_entrada.cidsednom is not null and
                     mr_entrada.cidsednom <> " " then

                     if mr_entrada.ufdcodsed is null or
                        mr_entrada.ufdcodsed = " " then
                        error "Cidade/Estado incompleto."
                        next field cidsednom
                     end if

                     whenever error continue
                     select mpacidcod
                       into mr_aux.cidcod
                       from datkmpacid
                      where cidnom = mr_entrada.cidsednom
                        and ufdcod = mr_entrada.ufdcodsed
                     whenever error stop

                     if  sqlca.sqlcode = notfound then
                         error "Cidade não encontrada"

                         call cts06g04(mr_entrada.cidsednom, mr_entrada.ufdcodsed)
                              returning mr_aux.cidcod, mr_entrada.cidsednom, mr_entrada.ufdcodsed

                         next field cidsednom
                     end if

                     if  not int_flag then

                         call ctd01g00_obter_cidsedcod(1, mr_aux.cidcod)
                              returning l_retorno,
                                        l_mensagem,
                                        mr_aux.cidcodsed

                         call cty10g00_cidade_uf(mr_aux.cidcodsed)
                              returning l_retorno,
                                        l_mensagem,
                                        mr_aux.cidsednom,
                                        mr_aux.ufdcodsed

                         display by name mr_aux.cidsednom,
                                         mr_aux.ufdcodsed
                     end if
                 else
                     let mr_entrada.ufdcodsed = null
                     display by name mr_entrada.ufdcodsed
                 end if

             before field atdetpcod

                if  mr_entrada.atdetpcod is null or
                    mr_entrada.atdetpcod = " " then
                    let mr_entrada.atdetpcod = 1

                    select atdetpdes
                      into mr_entrada.atdetpdes
                      from datketapa
                     where atdetpcod = mr_entrada.atdetpcod
                       and atdetpstt = "A"

                    display by name mr_entrada.atdetpdes
                end if

             after field atdetpcod

                if  mr_entrada.atdetpcod is not null and
                    mr_entrada.atdetpcod <> " " then

                    select atdetpdes
                      into mr_entrada.atdetpdes
                      from datketapa
                     where atdetpcod = mr_entrada.atdetpcod
                       and atdetpstt = "A"

                    if  mr_entrada.tipo = 1 then
                        let l_origem = 1
                    else
                        let l_origem = 9
                    end if

                    if  sqlca.sqlcode = notfound then
                        call ctn26c00(l_origem) returning mr_entrada.atdetpcod
                        next field atdetpcod
                    end if

                    select b.atdetpdes
                      into mr_entrada.atdetpdes
                      from datrsrvetp a,
                           datketapa  b
                     where a.atdsrvorg    = l_origem
                       and a.atdetpcod    = mr_entrada.atdetpcod
                       and a.atdetpcod    = b.atdetpcod
                       and a.atdsrvetpstt = "A"

                    if  sqlca.sqlcode = notfound then
                        error "Etapa não pertence a esse tipo de serviço"
                        next field atdetpcod
                    end if

                    display by name mr_entrada.atdetpdes
                else
                    let mr_entrada.atdetpdes = ""
                    display by name mr_entrada.atdetpdes
                end if

                if  fgl_lastkey() = fgl_keyval("up")   or
                    fgl_lastkey() = fgl_keyval("left") then
                    if  mr_aux.ufdcodsed is not null and
                        mr_aux.ufdcodsed <> " " then
                        next field ufdcodsed
                    else
                        next field cidsednom
                    end if
                end if

                exit input

          end input

          if  not int_flag then
              call cts00m41_busca_servicos()

          else
              exit while
          end if

     end while

     close window w_cts00m41

 end function

#----------------------------------#
 function cts00m41_busca_servicos()
#----------------------------------#

     define l_atdsrvorg char(50),
            l_horaini   datetime year to second,
            l_horafim   datetime year to second,
            l_hora      interval hour to minute,
            l_aux       datetime hour to minute,
            l_aux2      char(0002),
            l_sql       char(5000),
            l_pressf6   smallint,
            l_outer     char(10)

     let l_horaini = mr_entrada.atddat

     let mr_result.qtdtotsrv1    = 0
     let mr_result.qtdtotsrv2    = 0
     let mr_result.qtdtotsrv3    = 0
     let mr_result.qtdtotsrv4    = 0
     let mr_result.qtdtotsrv5    = 0
     let mr_result.qtdtotsrvimd    = 0
     let mr_result.qtdtotsrvprg    = 0
     let mr_result.qtdtotsrv       = 0

     for m_ind=1 to 24
         let ma_total[m_ind].qtdsrvprg = 0
         let ma_total[m_ind].qtdsrvimd = 0
         let ma_total[m_ind].qtdsrvtot = 0
         let ma_total[m_ind].atdhor    = 0
         let ma_total[m_ind].qtd1      = 0
         let ma_total[m_ind].qtd2      = 0
         let ma_total[m_ind].qtd3      = 0
         let ma_total[m_ind].qtd4      = 0
         let ma_total[m_ind].qtd5      = 0
     end for

     let m_ind = 1

     while (m_ind <= 24)

         let l_horafim = ((l_horaini + 1 units hour) - 1 units second)
         let ma_total[m_ind].atdhor = extend(l_horaini, hour to hour) clipped, "h"

         if  mr_entrada.tipo = 1 then
             let l_atdsrvorg = "1,2,4,5,6,7,17"
         else
             let l_atdsrvorg = "9"
         end if
         
         if  mr_aux.cidcodsed is not null and
             mr_aux.cidcodsed <> " " then
             let l_outer = " "
         else
            let l_outer = "outer"    
         end if
         
         let l_sql = "select srv.atdsrvnum, ",
                           " srv.atdsrvano, ",
                           " srv.atddatprg, ",
                           " srv.atdhorprg, ",
                           " srv.asitipcod ",
                      " from datmservico srv, ",
                           " datmlcl lcl, ",
                           " datkmpacid cid, ",
                           " ",l_outer clipped," datrcidsed sed, ",
                           " datmsrvacp acp ",
                     " where srvprsacnhordat between '", l_horaini,"' and '", l_horafim, "' ",
                       " and atdsrvorg in (", l_atdsrvorg clipped,") ",
                       " and srv.atdsrvnum = lcl.atdsrvnum ",
                       " and srv.atdsrvano = lcl.atdsrvano ",
                       " and acp.atdsrvnum = lcl.atdsrvnum ",
                       " and acp.atdsrvano = lcl.atdsrvano ",
                       " and acp.atdsrvseq = (select max(atdsrvseq) ",
                                              " from datmsrvacp acp2 ",
                                             " where acp.atdsrvnum = acp2.atdsrvnum ",
                                               " and acp.atdsrvano = acp2.atdsrvano) "

         if  mr_entrada.atdetpcod is not null and
             mr_entrada.atdetpcod <> " " then
             let l_sql = l_sql clipped, " and acp.atdetpcod = ", mr_entrada.atdetpcod
         end if

         let l_sql = l_sql clipped, " and lcl.c24endtip = 1 ",
                                    " and lcl.cidnom = cid.cidnom ",
                                    " and lcl.ufdcod = cid.ufdcod ",
                                    " and sed.cidcod = cid.mpacidcod "

         if  mr_entrada.empcod is not null and
             mr_entrada.empcod <> " " then
             let l_sql = l_sql clipped, " and srv.ciaempcod = ", mr_entrada.empcod
         end if

         if  mr_aux.cidcodsed is not null and
             mr_aux.cidcodsed <> " " then
             let l_sql = l_sql clipped, " and sed.cidsedcod = ", mr_aux.cidcodsed
         end if

         let l_sql = l_sql clipped, " order by srvprsacnhordat "

         prepare p_cts00m41_001 from l_sql
         declare c_cts00m41_001 cursor for p_cts00m41_001

         foreach c_cts00m41_001 into mr_aux.atdsrvnum,
                                   mr_aux.atdsrvano,
                                   mr_aux.atddatprg,
                                   mr_aux.atdhorprg,
                                   mr_aux.asitipcod

             if  mr_aux.atddatprg <> mr_entrada.atddat then
                 continue foreach
             end if

             if  mr_aux.atddatprg is not null then
                 let l_aux2 = extend(mr_aux.atdhorprg, hour to hour)
                 let m_hora = l_aux2 + 1
                 let ma_total[m_hora].qtdsrvprg = ma_total[m_hora].qtdsrvprg + 1
             else
                 let m_hora = m_ind
                 let ma_total[m_hora].qtdsrvimd = ma_total[m_hora].qtdsrvimd + 1
             end if

             call cts00m41_totaliza()

         end foreach

         let ma_total[m_ind].qtdsrvtot = ma_total[m_ind].qtdsrvprg +
                                         ma_total[m_ind].qtdsrvimd

         let mr_result.qtdtotsrvimd = mr_result.qtdtotsrvimd +
                                      ma_total[m_ind].qtdsrvimd

         let mr_result.qtdtotsrvprg = mr_result.qtdtotsrvprg +
                                      ma_total[m_ind].qtdsrvprg

         # SOMA DOS CAMPOS
         let mr_result.qtdtotsrv1 = mr_result.qtdtotsrv1 +
                                    ma_total[m_ind].qtd1
         let mr_result.qtdtotsrv2 = mr_result.qtdtotsrv2 +
                                    ma_total[m_ind].qtd2
         let mr_result.qtdtotsrv3 = mr_result.qtdtotsrv3 +
                                    ma_total[m_ind].qtd3
         let mr_result.qtdtotsrv4 = mr_result.qtdtotsrv4 +
                                    ma_total[m_ind].qtd4
         let mr_result.qtdtotsrv5 = mr_result.qtdtotsrv5 +
                                    ma_total[m_ind].qtd5

         # SOMA DOS SERVIÇOS (TOTAL)
         let mr_result.qtdtotsrv = mr_result.qtdtotsrv +
                                   ma_total[m_ind].qtdsrvtot

         let m_ind = m_ind + 1
         let l_horaini = l_horaini + 1 units hour

     end while

     call set_count(m_ind-1)

     call cts00m41_cabecalho()

     error ""

     let l_pressf6 = false
     display by name mr_result.*
     display array ma_total to s_totsrv.*

         on key (f6)
            let l_pressf6 = true
            exit display

     end display

     let int_flag = false
     if  l_pressf6 then
         error "Atualizando tela."
         call cts00m41_busca_servicos()
     end if

 end function

#-----------------------------#
 function cts00m41_cabecalho()
#-----------------------------#

 define lr_cabecalho record
     cabecalho1 char(10),
     cabecalho2 char(10),
     cabecalho3 char(10),
     cabecalho4 char(10),
     cabecalho5 char(10)
 end record

 define l_tipo char(020),
        l_ind  smallint,
        l_desc char(015)

 if  mr_entrada.tipo = 1 then
     let l_tipo = "cts00m41camposauto"
 else
     let l_tipo = "cts00m41camposre"
 end if

 declare c_cts00m41_002 cursor for
  select cpocod,
         cpodes
    from iddkdominio
   where cponom = l_tipo

 foreach  c_cts00m41_002 into l_ind, l_desc

     case l_ind
         when 1
              let lr_cabecalho.cabecalho1 = l_desc
         when 2
              let lr_cabecalho.cabecalho2 = l_desc
         when 3
              let lr_cabecalho.cabecalho3 = l_desc
         when 4
              let lr_cabecalho.cabecalho4 = l_desc
         when 5
              let lr_cabecalho.cabecalho5 = l_desc
     end case

 end foreach

 display by name lr_cabecalho.*

 end function

#----------------------------#
 function cts00m41_totaliza()
#----------------------------#

  define l_sql   char(1000),
         l_ind   smallint,
         l_campo char(0020),
         l_comp  char(0015)

  if  mr_entrada.tipo = 2 then

      declare c_cts00m41_003 cursor for
      select socntzgrpcod
        from datmsrvre srv,
             datksocntz ntz
       where atdsrvnum = mr_aux.atdsrvnum
         and atdsrvano = mr_aux.atdsrvano
         and srv.socntzcod = ntz.socntzcod

      open c_cts00m41_003
      fetch c_cts00m41_003 into mr_aux.asitipcod

  end if

  # VERIFICA EM QUAL CAMPO O SERVICO DEVERA SER SOMADO
  if  mr_aux.asitipcod is not null and
      mr_aux.asitipcod <> " " then

      let l_campo = "cts00m41", downshift(mr_entrada.tipodes)

      let l_sql = "select cponom ",
                   " from iddkdominio ",
                  " where ("

      for l_ind=1 to 4
          if  l_ind <> 1 then
              let l_sql = l_sql clipped, " or "
          end if

          let l_sql = l_sql clipped, " cponom = 'campo", l_ind using "<<<<&" clipped, l_campo clipped, "'"
      end for

      let l_sql = l_sql clipped, ") and cpocod = ", mr_aux.asitipcod

      prepare p_cts00m41_002 from l_sql
      declare c_cts00m41_004 cursor for p_cts00m41_002

      open c_cts00m41_004
      fetch c_cts00m41_004 into l_campo

      let l_campo = l_campo[6]
  else
      let l_campo = 5
  end if

  case l_campo
     when 1
         let ma_total[m_hora].qtd1 = ma_total[m_hora].qtd1 + 1
     when 2
         let ma_total[m_hora].qtd2 = ma_total[m_hora].qtd2 + 1
     when 3
         let ma_total[m_hora].qtd3 = ma_total[m_hora].qtd3 + 1
     when 4
         let ma_total[m_hora].qtd4 = ma_total[m_hora].qtd4 + 1
     otherwise
         let ma_total[m_hora].qtd5 = ma_total[m_hora].qtd5 + 1
  end case

 end function
