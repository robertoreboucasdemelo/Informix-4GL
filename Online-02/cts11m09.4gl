#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24hrs                                             #
# Modulo.........: cts11m09                                                  #
# Objetivo.......: Exibe as opcoes de voos cotados pelo Portal de Negocios   #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 196878                                                    #
#............................................................................#
# Desenvolvimento: Alinne, META                                              #
# Liberacao      : 17/02/2006                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl" ## psi201987
globals  "/homedsa/projetos/geral/globals/figrc072.4gl"

database porto

   define m_prep_cts11m09 smallint

#-----------------------------------------#
 function cts11m09_prepare()
#-----------------------------------------#

   define l_sql char(400)

   let l_sql = ' select aerciacod '
              ,'       ,trpaerempnom '
              ,'       ,trpaervoonum '
              ,'       ,trpaerptanum '
              ,'       ,trpaerlzdnum '
              ,'       ,vooopc       '
              ,'       ,escvoo       '
              ,'   from datmtrppsgaer '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'    and voocnxseq = 1 ' # <> 1 sao as conexoes
              ,'order by vooopc '

   prepare p_cts11m09_001 from l_sql
   declare c_cts11m09_001 cursor for p_cts11m09_001

   let l_sql = ' update datmtrppsgaer '
              ,'    set escvoo = ? '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'    and vooopc    = ? '
              ##,'    and voocnxseq = 1 '

   prepare p_cts11m09_002 from l_sql

   let l_sql = ' select vooopc from datmtrppsgaer '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'    and escvoo = "S" '

   prepare p_cts11m09_003 from l_sql
   declare c_cts11m09_002 cursor for p_cts11m09_003

   let l_sql = ' select sum(totpsgvlr) from datmtrppsgaer '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
              ,'    and vooopc = ? '

   prepare p_cts11m09_004 from l_sql
   declare c_cts11m09_003 cursor for p_cts11m09_004

   let m_prep_cts11m09 = true

 end function

#-----------------------------------------#
 function cts11m09_voo(lr_param)
#-----------------------------------------#

   define lr_param record
                   atdsrvnum like datmtrppsgaer.atdsrvnum
                  ,atdsrvano like datmtrppsgaer.atdsrvano
                   end record

   define al_voo array[050] of record
                 aerciacod    like datmtrppsgaer.aerciacod
                ,trpaerempnom like datmtrppsgaer.trpaerempnom
                ,trpaervoonum like datmtrppsgaer.trpaervoonum
                ,vooescolhido char(013)
                ,trpaerptanum like datmtrppsgaer.trpaerptanum
                ,trpaerlzdnum like datmtrppsgaer.trpaerlzdnum
                 end record

   define al_voo_aux array[050] of record
                     vooopc       like datmtrppsgaer.vooopc
                     end record

   define lr_ret     record
          resultado  smallint,
          mensagem   char(50),
          ramcod     like datrservapol.ramcod,
          succod     like datrservapol.succod,
          aplnumdig  like datrservapol.aplnumdig,
          itmnumdig  like datrservapol.itmnumdig
   end record

   define l_aerciacod like datmtrppsgaer.aerciacod
         ,l_escvoo    like datmtrppsgaer.escvoo
         ,l_arr       smallint
         ,l_totpsgvlr like datmtrppsgaer.totpsgvlr
         ,l_dddcod    char(4)
         ,l_telnum    char(10)
         ,l_conf      char(1)
         ,l_segnumdig like gsakseg.segnumdig

   define l_ult_etapa like datmsrvacp.atdetpcod

   initialize al_voo     to null
   initialize al_voo_aux to null
   initialize lr_ret.*   to null

   let l_aerciacod = null
   let l_escvoo    = null
   let l_arr       = 1
   let l_totpsgvlr = 0

   if m_prep_cts11m09 is null or
      m_prep_cts11m09 <> true then
      call cts11m09_prepare()
   end if

   open c_cts11m09_001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano

   foreach c_cts11m09_001 into al_voo[l_arr].aerciacod
                            ,al_voo[l_arr].trpaerempnom
                            ,al_voo[l_arr].trpaervoonum
                            ,al_voo[l_arr].trpaerptanum
                            ,al_voo[l_arr].trpaerlzdnum
                            ,al_voo_aux[l_arr].vooopc
                            ,l_escvoo

      if l_escvoo = 'S' then
         let al_voo[l_arr].vooescolhido = 'Voo escolhido'
      end if

      let l_arr = l_arr + 1

      if l_arr > 50 then
         error 'Tamanho do array excedido!' sleep 2
         exit foreach
      end if

   end foreach

   if l_arr = 1 then
      let l_aerciacod = cts11m05(lr_param.atdsrvnum, lr_param.atdsrvano, al_voo_aux[l_arr].vooopc, 'I')
      return l_aerciacod, al_voo_aux[l_arr].vooopc
   end if

   #buscar a ultima etapa do servico
   call cts10g04_ultima_etapa(lr_param.atdsrvnum, lr_param.atdsrvano)
        returning l_ult_etapa

   let l_arr = l_arr - 1

   call set_count(l_arr)

   open window w_cts11m09 at 10,2 with form 'cts11m09'
      attribute(border, form line 1, message line last)

   if l_ult_etapa = 46 or l_ult_etapa = 47 or l_ult_etapa = 4 then
      message ' (F5)Consultar Opcao    (Control-c)Sair '
   else
      message ' (F5)Consultar Opcao   (F8)Selecionar Opcao   (Control-c)Sair '
   end if

   display array al_voo to s_cts11m09.*

      on key(f5)
         let l_arr = arr_curr()
         let l_aerciacod = cts11m05(lr_param.atdsrvnum, lr_param.atdsrvano, al_voo_aux[l_arr].vooopc, 'C')

      on key(f8)
         let l_arr = arr_curr()
         let l_conf = null
         if l_ult_etapa = 46 or l_ult_etapa = 47  or l_ult_etapa = 4 then
            error "Opcao F8 nao ativa para etapa do servico"
         else

            open c_cts11m09_003 using lr_param.atdsrvnum
                                   ,lr_param.atdsrvano
                                   , al_voo_aux[l_arr].vooopc
            fetch c_cts11m09_003 into l_totpsgvlr
            close c_cts11m09_003

            if l_totpsgvlr > 1000 then
               call cts08g01("A","S","",
                             "O LIMITE DE COBERTURA FOI EXCEDIDO" ,
                             "CONFIRMA ESTE VOO ? ","")
                    returning l_conf

               if l_conf = "N" then
                  call cts28g00_apol_serv(1,lr_param.atdsrvnum, lr_param.atdsrvano)
                       returning lr_ret.*

                  call figrc072_setTratarIsolamento()
                  call cty05g00_segnumdig(lr_ret.succod, lr_ret.aplnumdig,
                                          lr_ret.itmnumdig, 1, '','')
                       returning lr_ret.resultado, lr_ret.mensagem,
                                 l_segnumdig

                  if g_isoAuto.sqlCodErr <> 0 then
                     display "Pesquisa do Codigo do Segurado Indisponivel! Erro: "
                           ,g_isoAuto.sqlCodErr
                  end if
                  call cty17g00_ssgttel (1,l_segnumdig,g_documento.c24soltipcod) ## psi201987
                       returning l_dddcod, l_telnum

                  #call cts09g00(lr_ret.ramcod, lr_ret.succod,
                  #              lr_ret.aplnumdig, lr_ret.itmnumdig, 1)
                  #     returning l_dddcod, l_telnum
               end if

            end if

            if l_totpsgvlr <= 1000 or l_conf is null or l_conf = "S" then
               if not cts11m09_atualiza(lr_param.atdsrvnum, lr_param.atdsrvano,  al_voo_aux[l_arr].vooopc) then
                  let l_aerciacod = al_voo[l_arr].aerciacod
               else
                  let l_aerciacod = null
               end  if
               exit display

            end if
         end if

      on key(interrupt,control-c,f17)
         let l_aerciacod = null
         exit display

   end display

   close window w_cts11m09

   let int_flag = false

   return l_aerciacod, al_voo_aux[l_arr].vooopc

 end function

#-----------------------------------------#
 function cts11m09_atualiza(lr_param)
#-----------------------------------------#

   define lr_param record
                   atdsrvnum like datmtrppsgaer.atdsrvnum
                  ,atdsrvano like datmtrppsgaer.atdsrvano
                  ,vooopc    like datmtrppsgaer.vooopc
                   end record

   define l_vooopc like datmtrppsgaer.vooopc
         ,l_escvoo like datmtrppsgaer.escvoo
         ,l_erro smallint

   let l_erro = false
   let l_vooopc = ''

   open c_cts11m09_002 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano

   fetch c_cts11m09_002 into l_vooopc
   if sqlca.sqlcode <> notfound then
      let l_escvoo = ""
      execute p_cts11m09_002 using l_escvoo
                                ,lr_param.atdsrvnum
                                ,lr_param.atdsrvano
                                ,l_vooopc
   end if

   close c_cts11m09_002
   let l_escvoo = "S"

   whenever error continue
   execute p_cts11m09_002 using l_escvoo
                             ,lr_param.atdsrvnum
                             ,lr_param.atdsrvano
                             ,lr_param.vooopc
   whenever error stop

   if sqlca.sqlcode <> 0 then
      error 'Erro UPDATE pcts11m09002: ',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
      error 'CTS11M09/cts11m09_atualiza/ ',lr_param.atdsrvnum
                                    ,' / ',lr_param.atdsrvano
                                    ,' / ',lr_param.vooopc    sleep 2
      let l_erro = true
   end if

   return l_erro

 end function
