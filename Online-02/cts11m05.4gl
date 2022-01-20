###############################################################################
# Nome do Modulo: CTS11M05                                           Marcelo  #
#                                                                    Gilberto #
# Conclusao Reserva de Passagem Aerea - Informacoes Adicionais       Jun/1999 #
###############################################################################
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 17/02/2006 Andrei, Meta  PSI196878 Alterar o recebimento de parametros da  #
#                                    cts11m05()                              #
#----------------------------------------------------------------------------#
 database porto

 define m_prep_sql smallint

 define am_cts11m05 array[10] of record
                               aerciacod        like datmtrppsgaer.aerciacod,
                               trpaerempnom     like datmtrppsgaer.trpaerempnom,
                               trpaervoonum     like datmtrppsgaer.trpaervoonum,
                               aerpsgrsrflg     like datkciaaer.aerpsgrsrflg,
                               aerpsgemsflg     like datkciaaer.aerpsgemsflg,
                               trpaerptanum     like datmtrppsgaer.trpaerptanum,
                               trpaerlzdnum     like datmtrppsgaer.trpaerlzdnum,
                               adlpsgvlr        like datmtrppsgaer.adlpsgvlr,
                               crnpsgvlr        like datmtrppsgaer.crnpsgvlr,
                               totpsgvlr        like datmtrppsgaer.totpsgvlr,
                               arpembcod        like datmtrppsgaer.arpembcod,
                               arpembnom        like datkaeroporto.arpnom,
                               arpembcidnom     like datkaeroporto.cidnom,
                               arpembufdcod     like datkaeroporto.ufdcod,
                               trpaersaidat     like datmtrppsgaer.trpaersaidat,
                               trpaersaihor     like datmtrppsgaer.trpaersaihor,
                               arpchecod        like datmtrppsgaer.arpchecod,
                               arpchenom        like datkaeroporto.arpnom,
                               arpchecidnom     like datkaeroporto.cidnom,
                               arpcheufdcod     like datkaeroporto.ufdcod,
                               trpaerchedat     like datmtrppsgaer.trpaerchedat,
                               trpaerchehor     like datmtrppsgaer.trpaerchehor
                           end record

#---------------------------
function cts11m05_prepare()
#---------------------------

 define l_sql char(500)

 let l_sql = 'select aerciacod, voocnxseq,  trpaerempnom, '
            ,'       trpaervoonum,  trpaerptanum,  trpaerlzdnum, '
            ,'       adlpsgvlr, crnpsgvlr, totpsgvlr, '
            ,'       arpembcod,  trpaersaidat, trpaersaihor, '
            ,'       arpchecod,  trpaerchedat, trpaerchehor '
            ,'  from datmtrppsgaer '
            ,' where atdsrvnum = ? '
            ,'   and atdsrvano = ? '
            ,'   and vooopc    = ? '
            ,' order by voocnxseq  '
 prepare pcts11m05001 from l_sql
 declare ccts11m05001 cursor for pcts11m05001
 let l_sql = 'insert into datmtrppsgaer '
            ,'(atdsrvnum, atdsrvano, voocnxseq, '
            ,' arpembcod, trpaersaidat, trpaersaihor, '
            ,' arpchecod, trpaerchedat, trpaerchehor, '
            ,' trpaervoonum, trpaerlzdnum, trpaerptanum, '
            ,' trpaerempnom, aerciacod, escvoo, vooopc, '
            ,' adlpsgvlr, crnpsgvlr, totpsgvlr) '
            ,' values '
            ,' (?,?,?,?,?,?,?,?,?,?,?,?,?,?,"S",1,?,?,?) '

 prepare pcts11m05002 from l_sql
 let l_sql = "select arpnom, cidnom, ufdcod",
             "  from datkaeroporto",
             " where arpcod = ?"
  prepare pcts11m05003 from l_sql
  declare ccts11m05003 cursor for pcts11m05003

  let l_sql = "select aerpsgrsrflg, aerpsgemsflg "
             ," from datkciaaer "
             ," where aerciacod = ? "
  prepare pcts11m05004 from l_sql
  declare ccts11m05004 cursor for pcts11m05004
 let m_prep_sql = true
end function
#---------------------------
function cts11m05(lr_param)
#---------------------------
 define lr_param record
                 atdsrvnum like datmtrppsgaer.atdsrvnum
                ,atdsrvano like datmtrppsgaer.atdsrvano
                ,vooopc    like datmtrppsgaer.vooopc
                ,acao      char(001)
             end record
 define l_i         smallint
       ,l_sql       char(150)
       ,l_resultado smallint
       ,l_mensagem  char(100)
       ,l_erro      smallint
 define l_voocnxseq like datmtrppsgaer.voocnxseq
       ,l_aerciacod like datmtrppsgaer.aerciacod
 define a_cts11m05   array[10] of record
    trpaerempnom     like datmtrppsgaer.trpaerempnom,
    trpaervoonum     like datmtrppsgaer.trpaervoonum,
    trpaerptanum     like datmtrppsgaer.trpaerptanum,
    trpaerlzdnum     like datmtrppsgaer.trpaerlzdnum,
    adlpsgvlr        like datmtrppsgaer.adlpsgvlr,
    crnpsgvlr        like datmtrppsgaer.crnpsgvlr,
    totpsgvlr        like datmtrppsgaer.totpsgvlr,
    arpembcod        like datmtrppsgaer.arpembcod,
    arpembnom        like datkaeroporto.arpnom,
    arpembcidnom     like datkaeroporto.cidnom,
    arpembufdcod     like datkaeroporto.ufdcod,
    trpaersaidat     like datmtrppsgaer.trpaersaidat,
    trpaersaihor     like datmtrppsgaer.trpaersaihor,
    arpchecod        like datmtrppsgaer.arpchecod,
    arpchenom        like datkaeroporto.arpnom,
    arpchecidnom     like datkaeroporto.cidnom,
    arpcheufdcod     like datkaeroporto.ufdcod,
    trpaerchedat     like datmtrppsgaer.trpaerchedat,
    trpaerchehor     like datmtrppsgaer.trpaerchehor
 end record

 define ws           record
    sql              char (300),
    lgdcep           like datkaeroporto.lgdcep,
    lgdcepcmp        like datkaeroporto.lgdcepcmp,
    arrqtd           dec (1,0),
    retflg           char (01),
    privez           char (01),
    operacao         char (01),
    confirma         char (01)
 end record

 define key_F3       smallint
 define key_F4       smallint

 define arr_aux      smallint
 define scr_aux      smallint

 define l_data       date,
        l_hora2      datetime hour to minute

#--------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------

	define	w_pf1	integer

	let	key_F3  =  null
	let	key_F4  =  null
	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  10
		initialize  am_cts11m05[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize am_cts11m05  to null
 initialize ws.*        to null
 if m_prep_sql is null or
    m_prep_sql <> true then
    call cts11m05_prepare()
 end if
 let l_i = 1
 let l_voocnxseq = 1
 let int_flag  = false

 let key_F3 = 2005
 let key_F4 = 2006

 let ws.retflg = "N"
 let ws.privez = "S"

# let am_cts11m05[1].trpaerempnom = voo1.trpaerempnom
# let am_cts11m05[1].trpaervoonum = voo1.trpaervoonum
# let am_cts11m05[1].trpaerptanum = voo1.trpaerptanum
# let am_cts11m05[1].trpaerlzdnum = voo1.trpaerlzdnum
# let am_cts11m05[1].arpembcod    = voo1.arpembcod
# let am_cts11m05[1].trpaersaidat = voo1.trpaersaidat
# let am_cts11m05[1].trpaersaihor = voo1.trpaersaihor
# let am_cts11m05[1].arpchecod    = voo1.arpchecod
# let am_cts11m05[1].trpaerchedat = voo1.trpaerchedat
# let am_cts11m05[1].trpaerchehor = voo1.trpaerchehor
#
# let am_cts11m05[2].trpaerempnom = voo2.trpaerempnom
# let am_cts11m05[2].trpaervoonum = voo2.trpaervoonum
# let am_cts11m05[2].trpaerptanum = voo2.trpaerptanum
# let am_cts11m05[2].trpaerlzdnum = voo2.trpaerlzdnum
# let am_cts11m05[2].arpembcod    = voo2.arpembcod
# let am_cts11m05[2].trpaersaidat = voo2.trpaersaidat
# let am_cts11m05[2].trpaersaihor = voo2.trpaersaihor
# let am_cts11m05[2].arpchecod    = voo2.arpchecod
# let am_cts11m05[2].trpaerchedat = voo2.trpaerchedat
# let am_cts11m05[2].trpaerchehor = voo2.trpaerchehor
#
# let am_cts11m05[3].trpaerempnom = voo3.trpaerempnom
# let am_cts11m05[3].trpaervoonum = voo3.trpaervoonum
# let am_cts11m05[3].trpaerptanum = voo3.trpaerptanum
# let am_cts11m05[3].trpaerlzdnum = voo3.trpaerlzdnum
# let am_cts11m05[3].arpembcod    = voo3.arpembcod
# let am_cts11m05[3].trpaersaidat = voo3.trpaersaidat
# let am_cts11m05[3].trpaersaihor = voo3.trpaersaihor
# let am_cts11m05[3].arpchecod    = voo3.arpchecod
# let am_cts11m05[3].trpaerchedat = voo3.trpaerchedat
# let am_cts11m05[3].trpaerchehor = voo3.trpaerchehor



#--------------------------------------------------------------
# Preparacao dos comandos SQL
#--------------------------------------------------------------
 let ws.sql = "select arpnom, cidnom, ufdcod",
              "  from datkaeroporto",
              " where arpcod = ?"
 prepare sel_datkaeroporto from ws.sql
 declare c_datkaeroporto cursor for sel_datkaeroporto

# for arr_aux = 1  to  3
#    if am_cts11m05[arr_aux].trpaerempnom is null  and
#       am_cts11m05[arr_aux].arpembcod    is null  and
#       am_cts11m05[arr_aux].arpchecod    is null  then
#       exit for
#    end if
#
#    open  c_datkaeroporto using am_cts11m05[arr_aux].arpembcod
#    fetch c_datkaeroporto into  am_cts11m05[arr_aux].arpembnom,
#                                am_cts11m05[arr_aux].arpembcidnom,
#                                am_cts11m05[arr_aux].arpembufdcod
#    close c_datkaeroporto
#
#    open  c_datkaeroporto using am_cts11m05[arr_aux].arpchecod
#    fetch c_datkaeroporto into  am_cts11m05[arr_aux].arpchenom,
#                                am_cts11m05[arr_aux].arpchecidnom,
#                                am_cts11m05[arr_aux].arpcheufdcod
#    close c_datkaeroporto
# end for
  if lr_param.acao = 'C' then
     let arr_aux = cts11m05_array(lr_param.atdsrvnum
                                 ,lr_param.atdsrvano
                                 ,lr_param.vooopc)

     if arr_aux < 0 then
        return am_cts11m05[1].aerciacod
     end if
  else
     let arr_aux = 0
  end if

# if arr_aux > 1  then
#    call cts08g01("A","N","","VOO COM CONEXAO OU","TROCA DE AERONAVE!","") returning ws.confirma
# end if

 call set_count(arr_aux)

 open window cts11m05 at 05,06 with form "cts11m05"
      attribute (border, form line 1, message line last, comment line last-1)


 if lr_param.acao = 'C' then
    message ' (F17)Abandona   (F3)Proximo   (F4)Anterior '

    display array am_cts11m05 to s_cts11m05.*

       on key (control-c, f17, interrupt)
          let int_flag = false
          exit display

    end display

    close window cts11m05
    return am_cts11m05[1].aerciacod
 end if

 message " (F17)Abandona, (F2)Excluir, (F3)Avancar, (F4)Retroceder "

 while true
#---------------------------------------------------------------
# Inicializacao do indexador do array
#---------------------------------------------------------------
 for arr_aux = 1 to 10
    if ws.privez = "N"  then
       if arr_aux > ws.arrqtd  then
          initialize am_cts11m05[arr_aux].*  to null
       end if
    end if

    if am_cts11m05[arr_aux].trpaerempnom is null  and
       am_cts11m05[arr_aux].arpembcod    is null  and
       am_cts11m05[arr_aux].arpchecod    is null  then
       exit for
    end if
 end for

 let ws.privez = "N"
 input array am_cts11m05 without defaults from s_cts11m05.*
    before row
       let arr_aux = arr_curr()
       let scr_aux = scr_line()
       if arr_aux <= arr_count()  then
          let ws.operacao = "a"
       end if

       if arr_aux > 10  then
          error " Limite de conexoes permitidas atingido! "
          let int_flag = true
          exit input
       end if

    before insert
       let ws.operacao = "i"
       initialize am_cts11m05[arr_aux].* to null
       display    am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*

    after  delete
       error " Conexao/voo excluido! "
       exit input
    before field aerciacod
       display am_cts11m05[arr_aux].aerciacod to
               s_cts11m05[scr_aux].aerciacod attribute (reverse)
       let l_aerciacod = am_cts11m05[arr_aux].aerciacod
    after field aerciacod
       display am_cts11m05[arr_aux].aerciacod to
               s_cts11m05[scr_aux].aerciacod
       if lr_param.acao = 'I' then
          if am_cts11m05[arr_aux].aerciacod is null then
             let l_sql = 'select aerciacod, aercianom '
                        ,'  from datkciaaer '
                        ,' order by aercianom '
             call ofgrc001_popup(12, 20, 'Cia Aereas', '', '', 'A', l_sql, '', 'D')
                returning l_erro
                         ,am_cts11m05[arr_aux].aerciacod
                         ,am_cts11m05[arr_aux].trpaerempnom

             if l_erro <> 0 then
                next field aerciacod
             end if
             #buscar se cia aerea reserva e emite passagem
             open ccts11m05004 using am_cts11m05[arr_aux].aerciacod
             whenever error continue
             fetch ccts11m05004 into am_cts11m05[arr_aux].aerpsgrsrflg,
                                     am_cts11m05[arr_aux].aerpsgemsflg
             whenever error stop
             if sqlca.sqlcode <> 0 then
                error "Erro ao buscar se cia aerea reserva e emite passagem."
                next field aerciacod
             end if
          else
#             //Obter o nome da Cia aerea
             call ctc10g00_dados_cia(2, am_cts11m05[arr_aux].aerciacod)
                returning l_resultado
                         ,l_mensagem
                         ,am_cts11m05[arr_aux].trpaerempnom
                         ,am_cts11m05[arr_aux].aerpsgrsrflg
                         ,am_cts11m05[arr_aux].aerpsgemsflg
             if l_resultado <> 1 then
                error l_mensagem
                next field aerciacod
             end if
          end if
       end if

       display am_cts11m05[arr_aux].trpaerempnom to
                           s_cts11m05[scr_aux].trpaerempnom
       display am_cts11m05[arr_aux].aerpsgrsrflg to
                           s_cts11m05[scr_aux].aerpsgrsrflg
       display am_cts11m05[arr_aux].aerpsgemsflg to
                           s_cts11m05[scr_aux].aerpsgemsflg
    before field trpaerempnom
       display am_cts11m05[arr_aux].trpaerempnom to
               s_cts11m05[scr_aux].trpaerempnom attribute (reverse)

    after  field trpaerempnom
       display am_cts11m05[arr_aux].trpaerempnom to
               s_cts11m05[scr_aux].trpaerempnom
       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field aerciacod
       end if

       if fgl_lastkey() = key_F4                    and
          am_cts11m05[arr_aux].trpaerempnom is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
#          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
#             error " Nao existem linhas nesta direcao!"
#             next field trpaerempnom
#          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field trpaervoonum
       display am_cts11m05[arr_aux].trpaervoonum to
               s_cts11m05[scr_aux].trpaervoonum attribute (reverse)

    after field trpaervoonum
       display am_cts11m05[arr_aux].trpaervoonum to
               s_cts11m05[scr_aux].trpaervoonum

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field trpaerempnom
       end if

       if fgl_lastkey() = key_F4                    and
          am_cts11m05[arr_aux].trpaervoonum is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field trpaerptanum
       display am_cts11m05[arr_aux].trpaerptanum to
               s_cts11m05[scr_aux].trpaerptanum attribute (reverse)

    after field trpaerptanum
       display am_cts11m05[arr_aux].trpaerptanum to
               s_cts11m05[scr_aux].trpaerptanum

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field trpaervoonum
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field trpaerptanum
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field trpaerlzdnum
       display am_cts11m05[arr_aux].trpaerlzdnum to
               s_cts11m05[scr_aux].trpaerlzdnum attribute (reverse)

    after field trpaerlzdnum
       display am_cts11m05[arr_aux].trpaerlzdnum to
               s_cts11m05[scr_aux].trpaerlzdnum

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field trpaerptanum
       end if

       if fgl_lastkey() = key_F4                    and
          am_cts11m05[arr_aux].trpaerlzdnum is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].trpaerlzdnum is null  and
             am_cts11m05[arr_aux].trpaerptanum is null  then
             call cts08g01("C","S","","NUMERO DO PTA E DO LOCALIZADOR","NAO FORAM INFORMADOS!","") returning ws.confirma
             if ws.confirma = "N"  then
                next field trpaerptanum
             end if
          end if
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field trpaerlzdnum
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field adlpsgvlr
       display am_cts11m05[arr_aux].adlpsgvlr to
               s_cts11m05[scr_aux].adlpsgvlr attribute (reverse)

    after  field adlpsgvlr
       display am_cts11m05[arr_aux].adlpsgvlr to
               s_cts11m05[scr_aux].adlpsgvlr

    before field crnpsgvlr
       display am_cts11m05[arr_aux].crnpsgvlr to
               s_cts11m05[scr_aux].crnpsgvlr attribute (reverse)

    after  field crnpsgvlr
       display am_cts11m05[arr_aux].crnpsgvlr to
               s_cts11m05[scr_aux].crnpsgvlr

    before field totpsgvlr
       display am_cts11m05[arr_aux].totpsgvlr to
               s_cts11m05[scr_aux].totpsgvlr attribute (reverse)

    after  field totpsgvlr
       display am_cts11m05[arr_aux].totpsgvlr to
               s_cts11m05[scr_aux].totpsgvlr

    before field arpembcod
       display am_cts11m05[arr_aux].arpembcod to
               s_cts11m05[scr_aux].arpembcod attribute (reverse)

    after field arpembcod
       display am_cts11m05[arr_aux].arpembcod to
               s_cts11m05[scr_aux].arpembcod

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field trpaerlzdnum
       end if

       if fgl_lastkey() = key_F4                 and
          am_cts11m05[arr_aux].arpembcod is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             call ctn00c02 ("SP","SAO PAULO","","")
                 returning ws.lgdcep, ws.lgdcepcmp

             if ws.lgdcep is null  or
                ws.lgdcep  =  0    then
                error " Nenhum criterio foi selecionado!"
                next field arpembcod
             else
                call ctn42c00(ws.lgdcep) returning am_cts11m05[arr_aux].arpembcod
             end if
             next field arpembcod
          end if

          open  c_datkaeroporto using am_cts11m05[arr_aux].arpembcod
          fetch c_datkaeroporto into  am_cts11m05[arr_aux].arpembnom,
                                      am_cts11m05[arr_aux].arpembcidnom,
                                      am_cts11m05[arr_aux].arpembufdcod

          if sqlca.sqlcode = notfound  then
             error " Aeroporto de embarque nao cadastrado! "
             call ctn00c02 ("SP","SAO PAULO","","")
                 returning ws.lgdcep, ws.lgdcepcmp

             if ws.lgdcep is null  or
                ws.lgdcep  =  0    then
                error " Nenhum criterio foi selecionado!"
                next field arpembcod
             else
                call ctn42c00(ws.lgdcep) returning am_cts11m05[arr_aux].arpembcod
             end if
             next field arpembcod
          end if

          display am_cts11m05[arr_aux].arpembnom    to
                  s_cts11m05[scr_aux].arpembnom
          display am_cts11m05[arr_aux].arpembcidnom to
                  s_cts11m05[scr_aux].arpembcidnom
          display am_cts11m05[arr_aux].arpembufdcod to
                  s_cts11m05[scr_aux].arpembufdcod
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field trpaersaidat
       display am_cts11m05[arr_aux].trpaersaidat to
               s_cts11m05[scr_aux].trpaersaidat attribute (reverse)

    after field trpaersaidat
       display am_cts11m05[arr_aux].trpaersaidat to
               s_cts11m05[scr_aux].trpaersaidat

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field arpembcod
       end if

       if fgl_lastkey() = key_F4                    and
          am_cts11m05[arr_aux].trpaersaidat is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          if a_cts11m05[arr_aux].trpaersaidat < l_data  then
             error " Data para embarque nao pode ser anterior a hoje! "
             next field trpaersaidat
          end if

          if a_cts11m05[arr_aux].trpaersaidat > l_data + 90 units day then
             error " Data para embarque nao pode ser maior que hoje! "
             next field trpaersaidat
          end if
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field trpaersaihor
       display am_cts11m05[arr_aux].trpaersaihor to
               s_cts11m05[scr_aux].trpaersaihor attribute (reverse)

    after field trpaersaihor
       display am_cts11m05[arr_aux].trpaersaihor to
               s_cts11m05[scr_aux].trpaersaihor

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field trpaersaidat
       end if

       if fgl_lastkey() = key_F4                    and
          am_cts11m05[arr_aux].trpaersaihor is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          if a_cts11m05[arr_aux].trpaersaidat = l_data  and
             a_cts11m05[arr_aux].trpaersaihor <= l_hora2  then
             error " Hora prevista para embarque deve ter duas horas de antecedencia!"
             next field trpaersaihor
          end if

          if arr_aux = 1  then
             call cts08g01("I","N","","FAVOR ESTAR PRESENTE NO AEROPORTO DE","EMBARQUE COM DUAS HORAS DE ANTECEDENCIA!","") returning ws.confirma
          end if
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field arpchecod
       display am_cts11m05[arr_aux].arpchecod to
               s_cts11m05[scr_aux].arpchecod attribute (reverse)

    after field arpchecod
       display am_cts11m05[arr_aux].arpchecod to
               s_cts11m05[scr_aux].arpchecod

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field trpaersaihor
       end if

       if fgl_lastkey() = key_F4                 and
          am_cts11m05[arr_aux].arpchecod is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             call ctn00c02 ("SP","SAO PAULO","","")
                 returning ws.lgdcep, ws.lgdcepcmp

             if ws.lgdcep is null  or
                ws.lgdcep  =  0    then
                error " Nenhum criterio foi selecionado!"
                next field arpchecod
             else
                call ctn42c00(ws.lgdcep) returning am_cts11m05[arr_aux].arpchecod
             end if
          end if

          open  c_datkaeroporto using am_cts11m05[arr_aux].arpchecod
          fetch c_datkaeroporto into  am_cts11m05[arr_aux].arpchenom,
                                      am_cts11m05[arr_aux].arpchecidnom,
                                      am_cts11m05[arr_aux].arpcheufdcod

          if sqlca.sqlcode = notfound  then
             error " Aeroporto de chegada nao cadastrado! "
             call ctn00c02 ("SP","SAO PAULO","","")
                 returning ws.lgdcep, ws.lgdcepcmp

             if ws.lgdcep is null  or
                ws.lgdcep  =  0    then
                error " Nenhum criterio foi selecionado!"
                next field arpchecod
             else
                call ctn42c00(ws.lgdcep) returning am_cts11m05[arr_aux].arpchecod
             end if
             next field arpchecod
          end if

          display am_cts11m05[arr_aux].arpchenom    to
                  s_cts11m05[scr_aux].arpchenom
          display am_cts11m05[arr_aux].arpchecidnom to
                  s_cts11m05[scr_aux].arpchecidnom
          display am_cts11m05[arr_aux].arpcheufdcod to
                  s_cts11m05[scr_aux].arpcheufdcod
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field archecod
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field trpaerchedat
       display am_cts11m05[arr_aux].trpaerchedat to
               s_cts11m05[scr_aux].trpaerchedat attribute (reverse)

    after field trpaerchedat
       display am_cts11m05[arr_aux].trpaerchedat to
               s_cts11m05[scr_aux].trpaerchedat

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field arpchecod
       end if

       if fgl_lastkey() = key_F4                    and
          am_cts11m05[arr_aux].trpaerchedat is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          if a_cts11m05[arr_aux].trpaerchedat < l_data  then
             error " Data para chegada nao pode ser anterior a hoje! "
             next field trpaerchedat
          end if

          if a_cts11m05[arr_aux].trpaerchedat > l_data + 90 units day then
             error " Data para chegada nao pode ser maior que hoje! "
             next field trpaerchedat
          end if
       end if

       if fgl_lastkey() = fgl_keyval("down")   or
          fgl_lastkey() = key_F3               then
          if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
             error " Nao existem linhas nesta direcao!"
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerempnom is null  then
             error " Empresa aerea deve ser informada!"
             next field trpaerempnom
          end if

          if am_cts11m05[arr_aux].trpaervoonum is null  then
             error " Numero do voo deve ser informado!"
             next field trpaervoonum
          end if

          if am_cts11m05[arr_aux].arpembcod is null  then
             error " Aeroporto de embarque deve ser informado!"
             next field arpembcod
          end if

          if am_cts11m05[arr_aux].trpaersaidat is null  then
             error " Data para embarque deve ser informada! "
             next field trpaersaidat
          end if

          if am_cts11m05[arr_aux].trpaersaihor is null  then
             error " Hora prevista para embarque deve ser informada! "
             next field trpaersaihor
          end if

          if am_cts11m05[arr_aux].arpchecod is null  then
             error " Aeroporto de chegada deve ser informado!"
             next field arpchecod
          end if

          if am_cts11m05[arr_aux].trpaerchedat is null  then
             error " Data para chegada deve ser informada! "
             next field trpaerchedat
          end if

          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if
       end if

    before field trpaerchehor
       display am_cts11m05[arr_aux].trpaerchehor to
               s_cts11m05[scr_aux].trpaerchehor attribute (reverse)

    after field trpaerchehor
       display am_cts11m05[arr_aux].trpaerchehor to
               s_cts11m05[scr_aux].trpaerchehor

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field trpaerchedat
       end if

       if fgl_lastkey() = key_F4                    and
          am_cts11m05[arr_aux].trpaerchehor is null  then
          initialize am_cts11m05[arr_aux].* to null
          initialize ws.operacao to null
          display am_cts11m05[arr_aux].* to s_cts11m05[scr_aux].*
       else
          if am_cts11m05[arr_aux].trpaerchehor is null  then
             error " Hora prevista para chegada deve ser informada! "
             next field trpaerchehor
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
          if a_cts11m05[arr_aux].trpaerchedat  = l_data  and
             am_cts11m05[arr_aux].trpaerchehor <= am_cts11m05[arr_aux].trpaersaihor  then
             error " Hora prevista para chegada nao pode ser anterior a hora prevista para embarque!"
             next field trpaerchehor
          end if

          if fgl_lastkey() = fgl_keyval("down")   or
             fgl_lastkey() = key_F3               then
             if am_cts11m05[arr_aux + 1].trpaerempnom is null  then
                error " Nao existem linhas nesta direcao!"
                next field trpaerchehor
             end if

             if am_cts11m05[arr_aux].trpaerempnom is null  then
                error " Empresa aerea deve ser informada!"
                next field trpaerempnom
             end if

             if am_cts11m05[arr_aux].trpaervoonum is null  then
                error " Numero do voo deve ser informado!"
                next field trpaervoonum
             end if

             if am_cts11m05[arr_aux].arpembcod is null  then
                error " Aeroporto de embarque deve ser informado!"
                next field arpembcod
             end if

             if am_cts11m05[arr_aux].trpaersaidat is null  then
                error " Data para embarque deve ser informada! "
                next field trpaersaidat
             end if

             if am_cts11m05[arr_aux].trpaersaihor is null  then
                error " Hora prevista para embarque deve ser informada! "
                next field trpaersaihor
             end if

             if am_cts11m05[arr_aux].arpchecod is null  then
                error " Aeroporto de chegada deve ser informado!"
                next field arpchecod
             end if

             if am_cts11m05[arr_aux].trpaerchedat is null  then
                error " Data para chegada deve ser informada! "
                next field trpaerchedat
             end if

             if am_cts11m05[arr_aux].trpaerchehor is null  then
                error " Hora prevista para chegada deve ser informada! "
                next field trpaerchehor
             end if
          end if

          if lr_param.acao = 'I' then
             call cts11m05_inclui(lr_param.atdsrvnum
                                 ,lr_param.atdsrvano
                                 ,l_voocnxseq
                                 ,arr_aux )
          end if

          if arr_aux > 3  then
             error " Limite de conexoes permitidas atingido! "
             let int_flag = true
             exit input
          end if

          if arr_aux < 3  then
             call cts08g01("C","S","","VOO COM CONEXAO OU TROCA DE AERONAVES?","","") returning ws.confirma

             if ws.confirma = "N"  then
                error ""
                let int_flag = true
                exit input
             end if
             if ws.confirma = "S" then
                let l_voocnxseq = l_voocnxseq + 1
             end if
          end if
       end if
    on key (interrupt)
       exit input

 end input

 if int_flag  then
    let int_flag = false
    exit while
 end if

 end while

 options insert key F1

 close window cts11m05

 if am_cts11m05[1].trpaerempnom is not null  and
    am_cts11m05[1].trpaervoonum is not null  and
    am_cts11m05[1].arpembcod    is not null  and
    am_cts11m05[1].trpaersaidat is not null  and
    am_cts11m05[1].trpaersaihor is not null  and
    am_cts11m05[1].arpchenom    is not null  and
    am_cts11m05[1].trpaerchedat is not null  and
    am_cts11m05[1].trpaerchehor is not null  then
    let ws.retflg = "S"
 end if
 return am_cts11m05[1].aerciacod

# return am_cts11m05[1].trpaerempnom,
#        am_cts11m05[1].trpaervoonum,
#        am_cts11m05[1].trpaerptanum,
#        am_cts11m05[1].trpaerlzdnum,
#        am_cts11m05[1].arpembcod   ,
#        am_cts11m05[1].trpaersaidat,
#        am_cts11m05[1].trpaersaihor,
#        am_cts11m05[1].arpchecod   ,
#        am_cts11m05[1].trpaerchedat,
#        am_cts11m05[1].trpaerchehor,
#        am_cts11m05[2].trpaerempnom,
#        am_cts11m05[2].trpaervoonum,
#        am_cts11m05[2].trpaerptanum,
#        am_cts11m05[2].trpaerlzdnum,
#        am_cts11m05[2].arpembcod   ,
#        am_cts11m05[2].trpaersaidat,
#        am_cts11m05[2].trpaersaihor,
#        am_cts11m05[2].arpchecod   ,
#        am_cts11m05[2].trpaerchedat,
#        am_cts11m05[2].trpaerchehor,
#        am_cts11m05[3].trpaerempnom,
#        am_cts11m05[3].trpaervoonum,
#        am_cts11m05[3].trpaerptanum,
#        am_cts11m05[3].trpaerlzdnum,
#        am_cts11m05[3].arpembcod   ,
#        am_cts11m05[3].trpaersaidat,
#        am_cts11m05[3].trpaersaihor,
#        am_cts11m05[3].arpchecod   ,
#        am_cts11m05[3].trpaerchedat,
#        am_cts11m05[3].trpaerchehor,
#        ws.retflg

end function  ###  cts11m05

#----------------------------------------
function cts11m05_inclui(lr_param, l_pos)
#----------------------------------------

 define lr_param record
                 atdsrvnum     like datmtrppsgaer.atdsrvnum
                ,atdsrvano     like datmtrppsgaer.atdsrvano
                ,voocnxseq     like datmtrppsgaer.voocnxseq
             end record

 define l_pos smallint
 whenever error continue
 execute pcts11m05002 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
                           ,lr_param.voocnxseq
                           ,am_cts11m05[l_pos].arpembcod
                           ,am_cts11m05[l_pos].trpaersaidat
                           ,am_cts11m05[l_pos].trpaersaihor
                           ,am_cts11m05[l_pos].arpchecod
                           ,am_cts11m05[l_pos].trpaerchedat
                           ,am_cts11m05[l_pos].trpaerchehor
                           ,am_cts11m05[l_pos].trpaervoonum
                           ,am_cts11m05[l_pos].trpaerlzdnum
                           ,am_cts11m05[l_pos].trpaerptanum
                           ,am_cts11m05[l_pos].trpaerempnom
                           ,am_cts11m05[l_pos].aerciacod
                           ,am_cts11m05[l_pos].adlpsgvlr
                           ,am_cts11m05[l_pos].crnpsgvlr
                           ,am_cts11m05[l_pos].totpsgvlr
 whenever error stop
 if sqlca.sqlcode = 0 then
    error 'Inclusao efetuada com sucesso'
 else
    error 'Erro INSERT pcts11m05002 / ', sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]
    error 'CTS11M05 / cts11m05_inclui() / ',lr_param.atdsrvnum,             ' / '
                                           ,lr_param.atdsrvano,             ' / '
                                           ,lr_param.voocnxseq,             ' / '
                                           ,am_cts11m05[l_pos].arpembcod,     ' / '
                                           ,am_cts11m05[l_pos].trpaersaidat,  ' / '
                                           ,am_cts11m05[l_pos].trpaersaihor,  ' / '
                                           ,am_cts11m05[l_pos].arpchecod,     ' / '
                                           ,am_cts11m05[l_pos].trpaerchedat,  ' / '
                                           ,am_cts11m05[l_pos].trpaerchehor,  ' / '
                                           ,am_cts11m05[l_pos].trpaervoonum,  ' / '
                                           ,am_cts11m05[l_pos].trpaerlzdnum,  ' / '
                                           ,am_cts11m05[l_pos].trpaerptanum,  ' / '
                                           ,am_cts11m05[l_pos].trpaerempnom,  ' / '
                                           ,am_cts11m05[l_pos].aerciacod
 end if

end function

#--------------------------------
function cts11m05_array(lr_param)
#--------------------------------

 define lr_param record
                 atdsrvnum like datmtrppsgaer.atdsrvnum
                ,atdsrvano like datmtrppsgaer.atdsrvano
                ,vooopc    like datmtrppsgaer.vooopc
             end record
 define l_i smallint
 define l_voocnxseq like datmtrppsgaer.voocnxseq

 initialize am_cts11m05  to null

 let l_i = 1
 open ccts11m05001 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano
                        ,lr_param.vooopc
 foreach ccts11m05001 into am_cts11m05[l_i].aerciacod
                          ,l_voocnxseq
                          ,am_cts11m05[l_i].trpaerempnom
                          ,am_cts11m05[l_i].trpaervoonum
                          ,am_cts11m05[l_i].trpaerptanum
                          ,am_cts11m05[l_i].trpaerlzdnum
                          ,am_cts11m05[l_i].adlpsgvlr
                          ,am_cts11m05[l_i].crnpsgvlr
                          ,am_cts11m05[l_i].totpsgvlr
                          ,am_cts11m05[l_i].arpembcod
                          ,am_cts11m05[l_i].trpaersaidat
                          ,am_cts11m05[l_i].trpaersaihor
                          ,am_cts11m05[l_i].arpchecod
                          ,am_cts11m05[l_i].trpaerchedat
                          ,am_cts11m05[l_i].trpaerchehor
    open ccts11m05003 using am_cts11m05[l_i].arpembcod
    whenever error continue
    fetch ccts11m05003 into am_cts11m05[l_i].arpembnom
                           ,am_cts11m05[l_i].arpembcidnom
                           ,am_cts11m05[l_i].arpembufdcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let am_cts11m05[l_i].arpembnom    = null
          let am_cts11m05[l_i].arpembcidnom = null
          let am_cts11m05[l_i].arpembufdcod = null
       else
          error 'Erro SELECT ccts11m05003 / ', sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]
          error 'CTS11M05 / cts11m05_array() / ',am_cts11m05[l_i].arpembcod
          initialize am_cts11m05 to null
          let l_i = 0
          exit foreach
       end if
    end if
    open ccts11m05003 using am_cts11m05[l_i].arpchecod
    whenever error continue
    fetch ccts11m05003 into am_cts11m05[l_i].arpchenom
                           ,am_cts11m05[l_i].arpchecidnom
                           ,am_cts11m05[l_i].arpcheufdcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let am_cts11m05[l_i].arpchenom    = null
          let am_cts11m05[l_i].arpchecidnom = null
          let am_cts11m05[l_i].arpcheufdcod = null
       else
          error 'Erro SELECT ccts11m05003 / ', sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]
          error 'CTS11M05 / cts11m05_array() / ',am_cts11m05[l_i].arpchecod
          initialize am_cts11m05 to null
          let l_i = 0
          exit foreach
       end if
    end if

    open ccts11m05004 using am_cts11m05[l_i].aerciacod
    whenever error continue
    fetch ccts11m05004 into am_cts11m05[l_i].aerpsgrsrflg
                           ,am_cts11m05[l_i].aerpsgemsflg
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let am_cts11m05[l_i].aerpsgrsrflg = null
          let am_cts11m05[l_i].aerpsgemsflg = null
       else
          error 'Erro SELECT ccts11m05004 / ', sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]
          error 'CTS11M05 / cts11m05_array() / ',am_cts11m05[l_i].arpchecod
          initialize am_cts11m05 to null
          let l_i = 0
          exit foreach
       end if
    end if

    let l_i = l_i + 1
    if l_i > 10 then
      error 'Numero de registro excedeu o limite'
      exit foreach
    end if
 end foreach
 let l_i = l_i - 1

 return l_i
end function
