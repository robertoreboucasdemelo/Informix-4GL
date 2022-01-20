#---------------------------------------------------------------------------#
# Menu de Modulo: CTS15M05                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao das prorrogacoes de reservas                          Ago/1996 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 11/11/1998  PSI 7055-6   Gilberto     Inclusao do campo EMPCOD referente  #
#                                       ao funcionario que registrou a pro- #
#                                       rrogacao da reserva.                #
#---------------------------------------------------------------------------#
# 11/12/2000  PSI 10631-3  Wagner       Incluir Centro de custo para pro-   #
#                                       rrogacao da reserva.                #
#---------------------------------------------------------------------------#
# 16/03/2004 OSF 33367     Teresinha S. Alteracao da funcao cts15m04        #
# --------------------------------------------------------------------------#
# 02/03/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
# 17/05/2011  Ligia, Fornax             Carro extra - fase II
# --------------------------------------------------------------------------#
# 21/02/2013  Raul, BIZ                 Correcao da limitacao de prorrogacao#
#---------------------------------------------------------------------------#
globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_empcod   like isskfunc.empcod
define m_funmat   like isskfunc.funmat

define am_motivos array[10] of record
          itarsrcaomtvcod   like datkitarsrcaomtv.itarsrcaomtvcod,
          itarsrcaomtvdes   like datkitarsrcaomtv.itarsrcaomtvdes,
          dialimqtd         like datkitarsrcaomtv.dialimqtd
end record
define m_qtde_motivos integer
#--------------------------------------------------------------------
 function cts15m05_prep()
#--------------------------------------------------------------------
   define l_sql char(1000)

   let l_sql = ' select max(aviproseq) from datmprorrog ',
               ' where atdsrvnum = ? ',
               ' and atdsrvano = ? '

   prepare pcts15m05001 from l_sql
   declare ccts15m05001 cursor for pcts15m05001

   let l_sql = ' insert into datmprorrog  ',
               '             ( atdsrvnum   , atdsrvano   , ',
               '               vclretdat   , vclrethor   , ',
               '               aviprodiaqtd, empcod      , ',
               '               funmat      , aviprosoldat, ',
               '               aviprosolhor, aviprostt   , ',
               '               aviproseq   , cctempcod   , ',
               '               cctsuccod   , cctcod      ) '
   prepare pcts15m05002 from l_sql

end function
#--------------------------------------------------------------------
 function cts15m05(param)
#--------------------------------------------------------------------

  define param        record
     atdsrvnum        like datmprorrog.atdsrvnum  ,
     atdsrvano        like datmprorrog.atdsrvano  ,
     lcvcod           like datkavislocal.lcvcod   ,
     aviestcod        like datkavislocal.aviestcod,
     endcep           like datkavislocal.endcep   ,
     avialgmtv        like datmavisrent.avialgmtv ,
     dtentvcl         date,
     avivclgrp         like datkavisveic.avivclgrp,
     lcvsinavsflg      like datmavisrent.lcvsinavsflg
  end record

  define a_cts15m05   array[40] of record   #ligia 17/05/11
     aviprosoldat     like datmprorrog.aviprosoldat,
     aviprosolhor     like datmprorrog.aviprosolhor,
     aviprodiaqtd     like datmprorrog.aviprodiaqtd,
     vcldevdat        like datmprorrog.vclretdat   ,
     vcldevhor        like datmprorrog.vclrethor   ,
     #cctempcod        like datmprorrog.cctempcod   ,
     #cctsuccod        like datmprorrog.cctsuccod   ,
     #cctcod           like datmprorrog.cctcod      ,
     funnom           like isskfunc.funnom         ,
     aviprostt        like datmprorrog.aviprostt   ,
     aviproseq        like datmprorrog.aviproseq
  end record

  define d_cts15m05   record
     aviproseq        like datmprorrog.aviproseq   ,
     vclretdat        like datmprorrog.vclretdat   ,
     vclrethor        like datmprorrog.vclrethor   ,
     aviprodiaqtd     like datmprorrog.aviprodiaqtd,
     aviprosoldat     like datmprorrog.aviprosoldat,
     aviprosolhor     like datmprorrog.aviprosolhor,
     funmat           like datmprorrog.funmat      ,
     aviprostt        like datmprorrog.aviprostt   ,
     cctempcod        like datmprorrog.cctempcod   ,
     cctsuccod        like datmprorrog.cctsuccod   ,
     cctcod           like datmprorrog.cctcod
  end record

  define ws           record
     empcod           like datmprorrog.empcod,
     funmat           like datmprorrog.funmat,
     faxflg           smallint,
     procan           char(01),
     confirma         char(01),
     erro             smallint  ,
     mens             char(100)
  end record

  define l_count			smallint
  define arr_aux      smallint
  define scr_aux      smallint
  define l_ciaempcod like datmservico.ciaempcod
        ,l_avidiaqtd smallint
        ,l_aviprodiaqtd smallint
        ,l_saldo     integer
        ,l_index     integer
 define l_totaldias   smallint,
 		  l_datareserva date,     #Data da primeira reserva
 		  l_qtddia      smallint  #Quantidade de dias da primeira reserva

  define l_data     date,
         l_hora2    datetime hour to minute

	define	w_pf1	integer
	define	l_erro  char(70)
  	define l_dev_dat_emp date,
               l_dev_dat_usr date,
               l_datac       char(20),
               l_aviproseq   like datmprorrog.aviproseq

	let  l_aviproseq =  null
	let  l_erro      =  null
	let  arr_aux     =  null
	let  scr_aux     =  null
	let  l_ciaempcod =  null
	let  l_avidiaqtd =  0
	let  l_dev_dat_emp = null
	let  l_dev_dat_usr = null
	let  l_datac = null
	let  l_index = 0

        let g_data_ret = null
        let g_data_dev = null

        initialize  a_cts15m05  to  null

	initialize  d_cts15m05.*  to  null

	initialize  ws.*  to  null

  if param.atdsrvnum is null or
     param.atdsrvano is null then
     return
  end if

  initialize ws.procan to null
  let ws.faxflg = FALSE

  open window w_cts15m05 at 10,02 with form "cts15m05"
       attribute(form line first)

  message " (F17)Abandona, (F1)Prorrog, (F9)Cancela (F8) Resumo Reserva"

   while TRUE

     declare c_cts15m05_001  cursor for
        select aviproseq   , vclretdat   , vclrethor   ,
               aviprodiaqtd, aviprosoldat, aviprosolhor,
               ####cctempcod   , cctsuccod   , cctcod      ,#ligia 17/05/11
               empcod      , funmat      , aviprostt
          from datmprorrog
         where atdsrvnum = param.atdsrvnum  and
               atdsrvano = param.atdsrvano
         order by aviproseq

     initialize a_cts15m05  to null
     initialize ws.funmat   to null
     let arr_aux = 1
     let l_totaldias = 0

     foreach c_cts15m05_001 into a_cts15m05[arr_aux].aviproseq   ,
                             d_cts15m05.vclretdat   ,
                             d_cts15m05.vclrethor   ,
                             a_cts15m05[arr_aux].aviprodiaqtd,
                             a_cts15m05[arr_aux].aviprosoldat,
                             a_cts15m05[arr_aux].aviprosolhor,
                             #a_cts15m05[arr_aux].cctempcod, #ligia 17/05/11
                             #a_cts15m05[arr_aux].cctsuccod,
                             #a_cts15m05[arr_aux].cctcod,
                             ws.empcod, ws.funmat            ,
                             a_cts15m05[arr_aux].aviprostt

        let a_cts15m05[arr_aux].vcldevdat = d_cts15m05.vclretdat +
                                            a_cts15m05[arr_aux].aviprodiaqtd
                                            units day

        let a_cts15m05[arr_aux].vcldevhor = d_cts15m05.vclrethor

        let a_cts15m05[arr_aux].funnom = "*** NAO CADASTRADO ***"

        select funnom
          into a_cts15m05[arr_aux].funnom
          from isskfunc
         where empcod = ws.empcod
           and funmat = ws.funmat

        let a_cts15m05[arr_aux].funnom = upshift(a_cts15m05[arr_aux].funnom)

        let arr_aux = arr_aux + 1
        if arr_aux > 40 then
           error " Limite excedido, reserva com 40 prorrogacoes!"
           exit foreach
        end if
     end foreach

     call set_count(arr_aux-1)

     if arr_aux = 1 then
        error "Nao existem prorrogacoes para esta reserva!"
     end if

     display array a_cts15m05 to s_cts15m05.*

         on key (interrupt,control-c)
            initialize a_cts15m05   to null
            let int_flag = true
            exit display

         on key (F1)
            initialize d_cts15m05.* to null

             # ligia 17/05/11
             #call cts08g01("A","S", "",
             #               "PARA CONSULTAS UTILIZE A FUNCAO ",
             #               "F8-CONS DADOS.",
             #               "DESEJA REALIZAR A PRORROGACAO ?"
             #                )
             #         returning ws.confirma

             #if ws.confirma = "S" then

             if g_documento.ciaempcod <> 84 then
                  ## PSI 244.183 Cadastro de veiculos : Carro Extra
                       if (param.avialgmtv   =   5  and
                           param.avivclgrp   <> "A" and
                           param.avivclgrp   <> "B" and
                           param.lcvsinavsflg = 'S') or
                           (param.avialgmtv   = 4    and
                            param.avivclgrp   <> "A" and
                            param.avivclgrp   <> "B" ) then
                           call cts08g01("I","N", "",
                                                  "O VEICULO SELECIONADO NECESSITA DA LIBE-",
                                                  "RACAO DA COORDENACAO/APOIO DEVIDO AO ",
                                                  "GRUPO E MOTIVO DA RESERVA"
                                                   )
                           returning ws.confirma
                           ### Criar Loop para digitacao
                           while true
                              call cts15m00b()
                                   returning ws.erro,
                                             ws.mens,
                                             m_empcod,
                                             m_funmat
                              if ws.erro = 0 then
                                 exit while
                              end if
                           end while
                       end if
                   select vclretdat, vclrethor, aviprodiaqtd
                   into d_cts15m05.vclretdat,
                        d_cts15m05.vclrethor,
                        d_cts15m05.aviprodiaqtd
                   from datmprorrog
                   where atdsrvnum = param.atdsrvnum  and
                        atdsrvano = param.atdsrvano  and
                        aviproseq = ( select max(aviproseq)
                                        from datmprorrog
                                       where atdsrvnum = param.atdsrvnum  and
                                             atdsrvano = param.atdsrvano  and
                                             aviprostt = "A" )

                        if sqlca.sqlcode = notfound  then
                           select aviretdat, avirethor, aviprvent
                             into d_cts15m05.vclretdat,
                                  d_cts15m05.vclrethor,
                                  d_cts15m05.aviprodiaqtd
                             from datmavisrent
                            where atdsrvnum = param.atdsrvnum  and
                                  atdsrvano = param.atdsrvano
                        end if

                        let d_cts15m05.vclretdat = d_cts15m05.vclretdat +
                                                   d_cts15m05.aviprodiaqtd units day

                        initialize d_cts15m05.aviprodiaqtd to null

                        call cts15m04("P"                 , param.avialgmtv        ,
                                      param.aviestcod     , d_cts15m05.vclretdat   ,
                                      d_cts15m05.vclrethor, d_cts15m05.aviprodiaqtd,
                                     #param.lcvcod, param.endcep ) -- OSF 33367
                                      param.lcvcod        , param.endcep ,param.dtentvcl )
                            returning d_cts15m05.vclretdat   , d_cts15m05.vclrethor,
                                      d_cts15m05.aviprodiaqtd, d_cts15m05.cctempcod,
                                      d_cts15m05.cctsuccod   , d_cts15m05.cctcod

                        if d_cts15m05.vclretdat    is null    or
                           d_cts15m05.vclrethor    is null    or
                           d_cts15m05.aviprodiaqtd is null    then
                           error "Data/Hora da retirada e Dias de Utilizacao sao obrigatorios !"
                        else
                           if param.avialgmtv = 7 then
                                  error "Reserva Terceiro Qualquer - Motivo 7 - sem direito a prorrogacao !" sleep 3
                                  exit display
                           end if

                           if g_fatura_emp > 0 then

                              let l_dev_dat_emp = d_cts15m05.vclretdat +
                                                  g_fatura_emp

                              let l_datac = year(d_cts15m05.vclretdat)
                                                 using '&&&&', '-',
                                            month(d_cts15m05.vclretdat)
                                                  using '&&','-',
                                            day(d_cts15m05.vclretdat)
                                                using '&&', ' ',
                                            d_cts15m05.vclrethor,":00"

                              let g_data_ret = l_datac

                              let l_datac = year(l_dev_dat_emp)
                                                 using '&&&&', '-',
                                            month(l_dev_dat_emp)
                                                  using '&&','-',
                                            day(l_dev_dat_emp)
                                                using '&&', ' ',
                                            d_cts15m05.vclrethor,":00"

                              let g_data_dev = l_datac

                           end if

                           begin work

                           if d_cts15m05.cctcod is not null and
                              g_fatura_emp > 0 and
                              g_fatura_usr > 0 then

                              ## insere prorrog p/fat a CIA
                              call cts15m05_prorrog(param.atdsrvnum,
                                                    param.atdsrvano,
                                                    d_cts15m05.vclretdat,
                                                    d_cts15m05.vclrethor,
                                                    g_fatura_emp,
                                                    g_issk.empcod,
                                                    g_issk.funmat,
                                                    "", "", "")
                                   returning ws.faxflg, ws.procan, l_aviproseq

                              call ctd33g00_ins_resumo
                                   (param.atdsrvnum,
                                    param.atdsrvano,
                                    l_aviproseq,
                                    d_cts15m05.vclretdat,
                                    d_cts15m05.vclrethor,
                                    l_dev_dat_emp,
                                    g_fatura_emp,
                                    g_documento.ciaempcod)
                                    returning l_erro

                              if g_fatura_usr > 0 then

                                 if g_fatura_emp > 0 then
                                    let d_cts15m05.vclretdat = l_dev_dat_emp
                                 end if

                                 let l_dev_dat_usr = d_cts15m05.vclretdat +
                                                     g_fatura_usr

                                 let l_datac = year(l_dev_dat_usr)
                                                    using '&&&&', '-',
                                               month(l_dev_dat_usr)
                                                     using '&&','-',
                                               day(l_dev_dat_usr)
                                                   using '&&', ' ',
                                               d_cts15m05.vclrethor,":00"

                                 let g_data_dev = l_datac
                              end if

                              call cts15m05_prorrog(param.atdsrvnum,
                                                    param.atdsrvano,
                                                    d_cts15m05.vclretdat,
                                                    d_cts15m05.vclrethor,
                                                    g_fatura_usr,
                                                    g_issk.empcod,
                                                    g_issk.funmat,
                                                    d_cts15m05.cctempcod,
                                                    d_cts15m05.cctsuccod,
                                                    d_cts15m05.cctcod)
                                   returning ws.faxflg, ws.procan, l_aviproseq

                              call ctd33g00_ins_resumo
                                   (param.atdsrvnum,
                                    param.atdsrvano,
                                    l_aviproseq,
                                    d_cts15m05.vclretdat,
                                    d_cts15m05.vclrethor,
                                    g_data_dev,
                                    g_fatura_usr, g_documento.ciaempcod)
                                    returning l_erro
                           else
                              ## insere prorrogacao
                              call cts15m05_prorrog(param.atdsrvnum,
                                                    param.atdsrvano,
                                                    d_cts15m05.vclretdat,
                                                    d_cts15m05.vclrethor,
                                                    d_cts15m05.aviprodiaqtd,
                                                    g_issk.empcod,
                                                    g_issk.funmat,
                                                    d_cts15m05.cctempcod,
                                                    d_cts15m05.cctsuccod,
                                                    d_cts15m05.cctcod)
                                   returning ws.faxflg, ws.procan, l_aviproseq

                              if g_fatura_emp > 0 then
                                 call ctd33g00_ins_resumo
                                      (param.atdsrvnum,
                                       param.atdsrvano,
                                       l_aviproseq,
                                       d_cts15m05.vclretdat,
                                       d_cts15m05.vclrethor,
                                       l_dev_dat_emp,
                                       g_fatura_emp,
                                       g_documento.ciaempcod)
                                       returning l_erro
                              end if

                              if g_fatura_usr > 0 then

                                 if g_fatura_emp > 0 then
                                    let d_cts15m05.vclretdat = l_dev_dat_emp
                                 end if

                                 let l_dev_dat_usr = d_cts15m05.vclretdat +
                                                     g_fatura_usr

                                 let l_datac = year(l_dev_dat_usr)
                                                    using '&&&&', '-',
                                               month(l_dev_dat_usr)
                                                     using '&&','-',
                                               day(l_dev_dat_usr)
                                                   using '&&', ' ',
                                               d_cts15m05.vclrethor,":00"

                                 let g_data_dev = l_datac

                                 call ctd33g00_ins_resumo
                                      (param.atdsrvnum,
                                       param.atdsrvano,
                                       l_aviproseq,
                                       d_cts15m05.vclretdat,
                                       d_cts15m05.vclrethor,
                                       g_data_dev,
                                       g_fatura_usr, 0)
                                       returning l_erro
                              end if

                           end if

                           if l_erro is not null then
                              error l_erro
                              rollback work
                           else
                              COMMIT WORK
                           end if

                        end if

                        let int_flag = false
                        exit display
                   else
                         # Itau
                        select vclretdat, vclrethor, aviprodiaqtd
                        into d_cts15m05.vclretdat,
                             d_cts15m05.vclrethor,
                             d_cts15m05.aviprodiaqtd
                        from datmprorrog
                        where atdsrvnum = param.atdsrvnum  and
                             atdsrvano = param.atdsrvano  and
                             aviproseq = ( select max(aviproseq)
                                        from datmprorrog
                                       where atdsrvnum = param.atdsrvnum  and
                                             atdsrvano = param.atdsrvano      )

                        if sqlca.sqlcode = notfound  then
                           select aviretdat, avirethor, aviprvent
                             into d_cts15m05.vclretdat,
                                  d_cts15m05.vclrethor,
                                  d_cts15m05.aviprodiaqtd
                             from datmavisrent
                            where atdsrvnum = param.atdsrvnum  and
                                  atdsrvano = param.atdsrvano
                        end if


                        call cts64m01_motivos_multiplos(param.avialgmtv,
                                                        param.atdsrvnum,
                                                        param.atdsrvano,
                                                        "P")
                             returning m_qtde_motivos,
                                       am_motivos[1].*,
                                       am_motivos[2].*,
                                       am_motivos[3].*,
                                       am_motivos[4].*,
                                       am_motivos[5].*,
                                       am_motivos[6].*,
                                       am_motivos[7].*,
                                       am_motivos[8].*,
                                       am_motivos[9].*



                         for l_index = 1 to 9

                             if am_motivos[l_index].itarsrcaomtvcod is not null then
                                let l_avidiaqtd = l_avidiaqtd +
                                                  am_motivos[l_index].dialimqtd
                             end if
                         end for

                        let d_cts15m05.vclretdat = d_cts15m05.vclretdat +
                                                   d_cts15m05.aviprodiaqtd units day

                        let d_cts15m05.aviprodiaqtd = l_avidiaqtd

                        call cts15m04("P"                 , param.avialgmtv        ,
                                      param.aviestcod     , d_cts15m05.vclretdat   ,
                                      d_cts15m05.vclrethor, d_cts15m05.aviprodiaqtd,
                                      param.lcvcod        , param.endcep ,param.dtentvcl )
                            returning d_cts15m05.vclretdat   , d_cts15m05.vclrethor,
                                      d_cts15m05.aviprodiaqtd, d_cts15m05.cctempcod,
                                      d_cts15m05.cctsuccod   , d_cts15m05.cctcod

                        if d_cts15m05.vclretdat is null then
                           exit display
                        end if

                        if d_cts15m05.vclretdat    is null    or
                           d_cts15m05.vclrethor    is null    or
                           d_cts15m05.aviprodiaqtd is null    then
                           error "Data/Hora da retirada e Dias de Utilizacao sao obrigatorios !"

                        else
                           BEGIN WORK
                              select max(aviproseq)
                                into d_cts15m05.aviproseq
                                from datmprorrog
                               where atdsrvnum = param.atdsrvnum  and
                                     atdsrvano = param.atdsrvano

                              if d_cts15m05.aviproseq is null then
                                 let d_cts15m05.aviproseq = 0
                              end if

                              let d_cts15m05.aviproseq = d_cts15m05.aviproseq + 1

                              call cts40g03_data_hora_banco(2)
                                   returning l_data, l_hora2

                              insert into datmprorrog
                                     ( atdsrvnum   , atdsrvano   ,
                                       vclretdat   , vclrethor   ,
                                       aviprodiaqtd, empcod      ,
                                       funmat      , aviprosoldat,
                                       aviprosolhor, aviprostt   ,
                                       aviproseq   , cctempcod   ,
                                       cctsuccod   , cctcod      )
                              values ( param.atdsrvnum        , param.atdsrvano     ,
                                       d_cts15m05.vclretdat   , d_cts15m05.vclrethor,
                                       d_cts15m05.aviprodiaqtd, g_issk.empcod       ,
                                       g_issk.funmat , l_data  , l_hora2,"A",
                                       d_cts15m05.aviproseq   , d_cts15m05.cctempcod,
                                       d_cts15m05.cctsuccod   , d_cts15m05.cctcod    )

                              if sqlca.sqlcode <> 0 then
                                 error "Erro (", sqlca.sqlcode, ") na gravacao da prorrogacao. AVISE A INFORMATICA!"
                                 rollback work
                              else
                                 error "Prorrogacao efetuada com sucesso!"
                                 let ws.faxflg = TRUE
                                 let ws.procan = "P"  # prorrogacao
                              end if
                           COMMIT WORK
                        end if
                        let int_flag = false
                        exit display
                  end if
              #end if

         on key (F8)

{ #ligia - fornax - 03/06/11
               select vclretdat, vclrethor, aviprodiaqtd
                 into d_cts15m05.vclretdat,
                      d_cts15m05.vclrethor,
                      d_cts15m05.aviprodiaqtd
                 from datmprorrog
                where atdsrvnum = param.atdsrvnum  and
                      atdsrvano = param.atdsrvano  and
                      aviprostt = "A" and
                      aviproseq = ( select max(aviproseq)
                                      from datmprorrog
                                     where atdsrvnum = param.atdsrvnum  and
                                           atdsrvano = param.atdsrvano )

               if sqlca.sqlcode = notfound  then
                  select aviretdat, avirethor, aviprvent
                    into d_cts15m05.vclretdat,
                         d_cts15m05.vclrethor,
                         d_cts15m05.aviprodiaqtd
                    from datmavisrent
                   where atdsrvnum = param.atdsrvnum  and
                         atdsrvano = param.atdsrvano

               end if

         let d_cts15m05.vclretdat = d_cts15m05.vclretdat +
                                    d_cts15m05.aviprodiaqtd units day


           call cts15m04("C" , param.avialgmtv,
                          param.aviestcod, d_cts15m05.vclretdat,
                          d_cts15m05.vclrethor, d_cts15m05.aviprodiaqtd,
                          param.lcvcod, param.endcep ,param.dtentvcl )
                returning d_cts15m05.vclretdat   , d_cts15m05.vclrethor,
                          d_cts15m05.aviprodiaqtd, d_cts15m05.cctempcod,
                          d_cts15m05.cctsuccod   , d_cts15m05.cctcod

}
                call cts15m18(param.atdsrvano, param.atdsrvnum)



         on key (F9)
            let arr_aux = arr_curr()

            if a_cts15m05[arr_aux].aviproseq is not null and
               a_cts15m05[arr_aux].aviproseq  > 0        then


              if g_documento.ciaempcod <> 84 then

                 if a_cts15m05[arr_aux].aviprostt = "C" then
                    error "Prorrogacao ja encontra-se CANCELADA"
                 else

                    if a_cts15m05[arr_aux+1].aviprostt = "A" then
                       call cts08g01("I","N", "", "",
                                     "CANCELE A PRORROGACAO MAIS RECENTE", "")
                            returning ws.confirma
                    else

                       call cts08g01("A","S", "", "",
                                     "DESEJA CANCELAR TOTALMENTE",
                                     "ESTA PRORROGACAO ?")
                            returning ws.confirma

                       if ws.confirma = "S" then

                          update datmprorrog
                             set (empcod, funmat, aviprostt) =
                                 (g_issk.empcod, g_issk.funmat,"C")
                           where atdsrvnum    = param.atdsrvnum  and
                                 atdsrvano    = param.atdsrvano  and
                                 aviproseq    = a_cts15m05[arr_aux].aviproseq

                          if sqlca.sqlcode <> 0 then
                             error "Erro (",sqlca.sqlcode,") no cancelamento da prorrogacao. AVISE A INFORMATICA!"
                          else
                             error "Prorrogacao cancelada!"
                             let ws.faxflg = TRUE
                             let ws.procan = "C"  # cancelamento de prorrogacao
                          end if

                       else

                          select vclretdat, vclrethor
                            into d_cts15m05.vclretdat,
                                 d_cts15m05.vclrethor
                            from datmprorrog
                           where atdsrvnum = param.atdsrvnum
                             and atdsrvano = param.atdsrvano
                             and aviproseq = a_cts15m05[arr_aux].aviproseq

                          call cts15m04("M", param.avialgmtv,
                                        param.aviestcod     , d_cts15m05.vclretdat   ,
                                        d_cts15m05.vclrethor,
                                        a_cts15m05[arr_aux].aviprodiaqtd,
                                        param.lcvcod        , param.endcep ,param.dtentvcl )
                               returning d_cts15m05.vclretdat   , d_cts15m05.vclrethor,
                                         d_cts15m05.aviprodiaqtd, d_cts15m05.cctempcod,
                                         d_cts15m05.cctsuccod   , d_cts15m05.cctcod

                          let a_cts15m05[arr_aux].aviprodiaqtd = d_cts15m05.aviprodiaqtd

                          if d_cts15m05.vclretdat    is null    or
                             d_cts15m05.vclrethor    is null    or
                             d_cts15m05.aviprodiaqtd is null    then
                             error "Data/Hora da retirada e Dias de Utilizacao sao obrigatorios !"
                          else
                             if param.avialgmtv = 7 then
                                error "Reserva Terceiro Qualquer - Motivo 7 - sem direito a prorrogacao !" sleep 3
                                exit display
                             end if

                             BEGIN WORK
                             call cts40g03_data_hora_banco(2)
                                   returning l_data, l_hora2

                             update datmprorrog set vclretdat = d_cts15m05.vclretdat,
                                                    vclrethor = d_cts15m05.vclrethor,
                                                    aviprodiaqtd = d_cts15m05.aviprodiaqtd
                                    where atdsrvnum = param.atdsrvnum
                                      and atdsrvano = param.atdsrvano
                                      and aviproseq = a_cts15m05[arr_aux].aviproseq

                             if sqlca.sqlcode <> 0 then
                                error "Erro (", sqlca.sqlcode, ") na gravacao da prorrogacao. AVISE A INFORMATICA!"
                                rollback work
                             else
                                error "Prorrogacao efetuada com sucesso!"
                                let ws.faxflg = TRUE
                                let ws.procan = "P"  # prorrogacao
                             end if

                             ## ligia - fornax - 26/05/11
                             let l_erro = null

                             call ctd33g00_del_resumo (param.atdsrvnum,
                                                       param.atdsrvano,
                                                       a_cts15m05[arr_aux].aviproseq)
                                  returning l_erro

                             if g_fatura_emp > 0 and l_erro is null then

                                let l_dev_dat_emp = d_cts15m05.vclretdat + g_fatura_emp

                                call ctd33g00_ins_resumo (param.atdsrvnum,
                                                          param.atdsrvano,
                                                          a_cts15m05[arr_aux].aviproseq,
                                                          d_cts15m05.vclretdat,
                                                          d_cts15m05.vclrethor,
                                                          l_dev_dat_emp,
                                                          g_fatura_emp,
                                                          g_documento.ciaempcod)
                                     returning l_erro

                                let l_datac = year(d_cts15m05.vclretdat) using '&&&&', '-',
                                              month(d_cts15m05.vclretdat) using '&&','-',
                                              day(d_cts15m05.vclretdat) using '&&', ' ',
                                              d_cts15m05.vclrethor,":00"
                                let g_data_ret = l_datac

                                let l_datac = year(l_dev_dat_emp) using '&&&&', '-',
                                              month(l_dev_dat_emp) using '&&','-',
                                              day(l_dev_dat_emp) using '&&', ' ',
                                              d_cts15m05.vclrethor,":00"
                                let g_data_dev = l_datac

                             end if

                             if g_fatura_usr > 0 then

                                if g_fatura_emp > 0 then
                                   let d_cts15m05.vclretdat = l_dev_dat_emp
                                end if

                                let l_dev_dat_usr = d_cts15m05.vclretdat + g_fatura_usr

                                call ctd33g00_ins_resumo (param.atdsrvnum,
                                                          param.atdsrvano,
                                                          a_cts15m05[arr_aux].aviproseq,
                                                          d_cts15m05.vclretdat,
                                                          d_cts15m05.vclrethor,
                                                          l_dev_dat_usr,
                                                          g_fatura_usr, 0)
                                     returning l_erro
                             end if

                             if l_erro is not null then
                                error l_erro
                                rollback work
                             else
                                COMMIT WORK
                             end if

                          end if

                       end if

                       let int_flag = true
                       exit display

                    end if
                 end if
              else
                 update datmprorrog
                  set (empcod, funmat, aviprostt) =
                      (g_issk.empcod, g_issk.funmat,"C")
                  where atdsrvnum    = param.atdsrvnum  and
                        atdsrvano    = param.atdsrvano  and
                        aviproseq    = a_cts15m05[arr_aux].aviproseq

                 if sqlca.sqlcode <> 0 then
                    error "Erro (",sqlca.sqlcode,") no cancelamento da prorrogacao. AVISE A INFORMATICA!"
                 else
                    error "Prorrogacao cancelada!"
                    let ws.faxflg = TRUE
                    let ws.procan = "C"  # cancelamento de prorrogacao
                 end if
              end if

            end if
   end display

   if int_flag   then
      exit while
   end if

end while

close window w_cts15m05
let int_flag = false

if ws.faxflg = TRUE  then
   ##########call cts15m03(param.atdsrvnum, param.atdsrvano, "F")
   if g_documento.ciaempcod = 1 then
       call cts15m00_acionamento(param.atdsrvnum,
                                 param.atdsrvano,
                                 param.lcvcod,
                                 param.aviestcod,0,'',ws.procan)
  else
    if g_documento.ciaempcod = 35 then
       call cts15m15_acionamento(param.atdsrvnum,
                                 param.atdsrvano,
                                 param.lcvcod,
                                 param.aviestcod,0,'',ws.procan)
    end if
  end if
    if g_documento.ciaempcod = 84 then
       call cts64m00_acionamento(param.atdsrvnum,
                                 param.atdsrvano,
                                 param.lcvcod,
                                 param.aviestcod,0,'')
    end if
end if
return ws.procan,d_cts15m05.aviprodiaqtd

end function  ###  cts15m05

function cts15m05_prorrog(lr_param)

   define lr_param    record
          atdsrvnum   like datmprorrog.atdsrvnum,
          atdsrvano   like datmprorrog.atdsrvano,
          vclretdat   like datmprorrog.vclretdat,
          vclrethor   like datmprorrog.vclrethor,
          aviprodiaqtd like datmprorrog.aviprodiaqtd,
          empcod      like datmprorrog.empcod,
          funmat      like datmprorrog.funmat,
          cctempcod   like datmprorrog.cctempcod,
          cctsuccod   like datmprorrog.cctsuccod,
          cctcod      like datmprorrog.cctcod
   end record

   define l_data     date,
          l_hora2    datetime hour to minute,
          l_aviprostt like datmprorrog.aviprostt,
          l_aviproseq like datmprorrog.aviproseq

   let l_data = null
   let l_hora2 = null
   let l_aviproseq = null
   let l_aviprostt = null

   call cts15m05_prep()

   open ccts15m05001 using lr_param.atdsrvnum, lr_param.atdsrvano
   fetch ccts15m05001 into l_aviproseq
   close ccts15m05001

   if l_aviproseq is null then
      let l_aviproseq = 0
   end if

   let l_aviproseq = l_aviproseq + 1

   call cts40g03_data_hora_banco(2) returning l_data, l_hora2

   let l_aviprostt = "A"
   execute pcts15m05002 using lr_param.atdsrvnum, lr_param.atdsrvano,
                              lr_param.vclretdat, lr_param.vclrethor,
                              lr_param.aviprodiaqtd,lr_param.empcod,
                              lr_param.funmat, l_data , l_hora2, l_aviprostt,
                              l_aviproseq, lr_param.cctempcod,
                              lr_param.cctsuccod, lr_param.cctcod

   if sqlca.sqlcode <> 0 then
      error "Erro (", sqlca.sqlcode, ") na gravacao da prorrogacao. AVISE A INFORMATICA!"
      return false, "", 0
   else
      error "Prorrogacao efetuada com sucesso!"
      ###let ws.faxflg = TRUE
      ###let ws.procan = "P"  # prorrogacao
      return true, "P", l_aviproseq
   end if

end function  ###  cts15m05_prorrog
