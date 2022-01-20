##############################################################################
# Nome do Modulo: cta08m00                                             Ruiz  #
#                                                                            #
# Consulta criterios de servicos gratuitos                          Abr/2002 #
#----------------------------------------------------------------------------#
# 23/05/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#----------------------------------------------------------------------------#
# 01/02/2006  Priscila Staingel   Zeladoria     Busca data e hora no banco   #
#----------------------------------------------------------------------------#
# 18/07/06   Junior, Meta  AS112372      Migracao de versao do 4gl.          #
#----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

define wg_grava_ligacao char(01)
#---------------------------------------------------------
function cta08m00()
#---------------------------------------------------------

 define d_cta08m00     record
    viginc             like abamapol.viginc    ,
    vigfnl             like abamapol.vigfnl    ,
    ctgtrfcod          like abbmcasco.ctgtrfcod,
    vclcoddig          like abbmveic.vclcoddig ,
    vclnom             char(50)                ,
    vclanomdl          like abbmveic.vclanomdl ,
    vcllicnum          like abbmveic.vcllicnum ,
    chassi             char (20)               ,
    corsus             like gcaksusep.corsus   ,
    cornom             like gcakcorr.cornom    ,
    vclcircid          like abbmdoc.vclcircid
 end record

 define a_cta08m00 array[30] of record
    discoddig          like adbmitem.discoddig,
    disnom             like agckdisp.disnom   ,
    opcao              char (01)              ,
    descr              char (12)
 end record

 define ret008 array[30] of record
    discoddig          like adbmitem.discoddig,
    disnom             like agckdisp.disnom,
    flag               char (01),
    rlzflag            char (01),
    rlzdt              date
 end record

 define ws             record
    vclchsinc          like abbmveic.vclchsinc,
    vclchsfnl          like abbmveic.vclchsfnl,
    vclmrccod          like agbkmarca.vclmrccod,
    vcltipcod          like agbktip.vcltipcod,
    vclmdlnom          like agbkveic.vclmdlnom,
    vclmrcnom          like agbkmarca.vclmrcnom,
    vcltipnom          like agbktip.vcltipnom ,
    edsnumref          like abamdoc.edsnumref ,
    segnumdig          like gsakseg.segnumdig ,
    consulta           dec (1,0)              ,
    discoddig          like adbmitem.discoddig,
    endcep             like glaklgd.lgdcep,
    endcepcmp          like glaklgd.lgdcepcmp,
    pergunta           char(01)                   ,
    lignum             like datmligacao.lignum    ,
    atdsrvnum          like datmservico.atdsrvnum ,
    atdsrvano          like datmservico.atdsrvano ,
    sqlcode            integer                    ,
    tabname            like systables.tabname     ,
    msg                char(80)                ,
    hora               char (05)                  ,
    data               date                       ,
    ok                 char (01)                  ,
    vclcircid          like abbmdoc.vclcircid     ,
    ufdcod             like glakcid.ufdcod        ,
    F8                 dec (01,0)                 ,
    F9                 dec (01,0)                 ,
    param              char(100)
 end record

 define w_count integer
 define arr_aux integer
 define scr_aux integer

 define l_data     date,
        l_hora2    datetime hour to minute

	define	w_pf1	integer

	let	w_count  =  null
	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  30
		initialize  a_cta08m00[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  30
		initialize  ret008[w_pf1].*  to  null
	end	for

	initialize  d_cta08m00.*  to  null

	initialize  ws.*  to  null

 initialize wg_grava_ligacao to null

 whenever error continue
      create temp table temp_cta08m00
         (discoddig  decimal (4,0)) with no log
 whenever error continue
 if sqlca.sqlcode != 0 then
   if sqlca.sqlcode = -310 or
      sqlca.sqlcode = -958 then
      delete from temp_cta08m00
   else
      error "ERRO CreateTempTable temp_cta08m00 -> ",sqlca.sqlcode
      return
   end if
 else
   create index temp_cta08m00_idx
   on temp_cta08m00 (discoddog)
		MESSAGE "" # By Robi
 end if

 whenever error continue
      create temp table temp_ctn05c03a
         (discoddig  decimal (4,0),
          disnom     char(40)     ,
          descr      char(12) ) with no log
 whenever error continue
 if sqlca.sqlcode != 0 then
   if sqlca.sqlcode = -310 or
      sqlca.sqlcode = -958 then
      delete from temp_ctn05c03a
   else
      error "ERRO CreateTempTable temp_ctn05c03a -> ",sqlca.sqlcode
      return
   end if
 else
   create index temp_ctn05c03a_idx
   on temp_ctn05c03a (discoddog)
		MESSAGE "" # By Robi
 end if
 call get_param()
 let ws.param = arg_val(15)
 if ws.param[1,5] = "Benef" then
    let wg_grava_ligacao      = "N"
    let g_documento.succod    = ws.param[6,7]
    let g_documento.ramcod    = ws.param[8,11]
    let g_documento.aplnumdig = ws.param[12,20]
    let g_documento.itmnumdig = ws.param[21,27]
 end if

 open window w_cta08m00 at 05,02 with form "cta08m00"
           attribute (form line 1)
 message " Aguarde, formatando os dados..."  attribute(reverse)

 if ws.param[1,5] = "Benef" then
    display "(F17)Aband.,(F5)Espelho,(F6)NovoEnd.,(F8)Espec.(F9)TodosServicos" to msg
 else
    display "(F17)Aband.,(F1)Help,(F5)Espelho,(F6)NovoEnd.,(F8)Espec.(F9)TodosServicos" to msg
 end if


 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
 initialize d_cta08m00.* to null
 initialize ws.*         to null
 let ws.data  =  l_data
 let ws.hora  =  l_hora2

 #-------------------------------------------------------------------------
 # Ultima situacao da apolice
 #-------------------------------------------------------------------------
 call f_funapol_ultima_situacao
      (g_documento.succod, g_documento.aplnumdig, g_documento.itmnumdig)
       returning g_funapol.*
 if g_funapol.dctnumseq is null  then
    select min(dctnumseq)
      into g_funapol.dctnumseq
      from abbmdoc
     where succod    = g_documento.succod
       and aplnumdig = g_documento.aplnumdig
       and itmnumdig = g_documento.itmnumdig
 end if
 #--------------------------------------------------------------------------
 # Se a ultima situacao nao for encontrada, atualiza ponteiros novamente
 #--------------------------------------------------------------------------
 if g_funapol.resultado = "O"  then
    select edsnumdig
      into ws.edsnumref
      from abamdoc
     where abamdoc.succod    =  g_documento.succod      and
           abamdoc.aplnumdig =  g_documento.aplnumdig   and
           abamdoc.dctnumseq =  g_funapol.dctnumseq
    if sqlca.sqlcode = notfound  then
       let ws.edsnumref = 0
    end if
    call f_funapol_auto(g_documento.succod   , g_documento.aplnumdig,
                        g_documento.itmnumdig, ws.edsnumref)
              returning g_funapol.*
 end if
 #--------------------------------------------------------------------------
 # Numero do segurado e tipo de endosso
 #--------------------------------------------------------------------------
 select segnumdig,vclcircid
   into ws.segnumdig,d_cta08m00.vclcircid
   from abbmdoc
  where abbmdoc.succod    =  g_documento.succod      and
        abbmdoc.aplnumdig =  g_documento.aplnumdig   and
        abbmdoc.itmnumdig =  g_documento.itmnumdig   and
        abbmdoc.dctnumseq =  g_funapol.dctnumseq
 let ws.vclcircid = d_cta08m00.vclcircid
 if  ws.vclcircid[1,7] = "GRANDE " then
     let ws.vclcircid = ws.vclcircid[8,45]
 end if
 declare c_cta08m00_001 cursor for
    select ufdcod
       from glakcid
      where cidnom=ws.vclcircid
 fetch c_cta08m00_001 into ws.ufdcod

 whenever error continue
 #--------------------------------------------------------------------------
 # Dados do corretor
 #--------------------------------------------------------------------------
 select corsus into d_cta08m00.corsus
   from abamcor
  where succod    = g_documento.succod         and
        aplnumdig = g_documento.aplnumdig      and
        corlidflg = "S"

 if sqlca.sqlcode = notfound   then
    let d_cta08m00.cornom = "Corretor nao cadastrado!"
 else
    if sqlca.sqlcode < 0  then
       error "Dados do CORRETOR nao disponiveis no momento!"
    else
       select cornom
         into d_cta08m00.cornom
         from gcaksusep, gcakcorr
        where gcaksusep.corsus     = d_cta08m00.corsus   and
              gcakcorr.corsuspcp   = gcaksusep.corsuspcp

       if sqlca.sqlcode = notfound   then
          let d_cta08m00.cornom = "Corretor nao cadastrado!"
       end if
    end if
 end if
 whenever error stop
 #--------------------------------------------------------------------------
 # Dados do veiculo
 #--------------------------------------------------------------------------
 select vclcoddig, vclanomdl,
        vcllicnum, vclchsinc, vclchsfnl
   into d_cta08m00.vclcoddig, d_cta08m00.vclanomdl,
        d_cta08m00.vcllicnum, ws.vclchsinc        ,
        ws.vclchsfnl
   from abbmveic
  where abbmveic.succod     = g_documento.succod     and
        abbmveic.aplnumdig  = g_documento.aplnumdig  and
        abbmveic.itmnumdig  = g_documento.itmnumdig  and
        abbmveic.dctnumseq  = g_funapol.vclsitatu
  if sqlca.sqlcode = notfound  then
     select vclcoddig, vclanomdl,
            vcllicnum, vclchsinc, vclchsfnl
       into d_cta08m00.vclcoddig, d_cta08m00.vclanomdl,
            d_cta08m00.vcllicnum, ws.vclchsinc        ,
             ws.vclchsfnl
       from abbmveic
      where succod    = g_documento.succod       and
            aplnumdig = g_documento.aplnumdig    and
            itmnumdig = g_documento.itmnumdig    and
            dctnumseq = (select max(dctnumseq)
                           from abbmveic
                          where succod    = g_documento.succod     and
                                aplnumdig = g_documento.aplnumdig  and
                                itmnumdig = g_documento.itmnumdig)
 end if
 if sqlca.sqlcode <> notfound  then
    select vclmrccod, vcltipcod, vclmdlnom
      into ws.vclmrccod, ws.vcltipcod, ws.vclmdlnom
      from agbkveic
     where agbkveic.vclcoddig = d_cta08m00.vclcoddig

    select vclmrcnom
      into ws.vclmrcnom
      from agbkmarca
     where vclmrccod = ws.vclmrccod

    select vcltipnom
      into ws.vcltipnom
      from agbktip
     where vclmrccod = ws.vclmrccod    and
           vcltipcod = ws.vcltipcod

    let d_cta08m00.vclnom  =  ws.vclmrcnom clipped,
                              " ", ws.vcltipnom clipped,
                              " ", ws.vclmdlnom clipped
    let d_cta08m00.chassi  =  ws.vclchsinc clipped, ws.vclchsfnl clipped
 else
    error "Dados do veiculo nao encontrado!"
 end if
 #--------------------------------------------------------------------------
 # vigencia da apolice
 #--------------------------------------------------------------------------
 select viginc, vigfnl
   into d_cta08m00.viginc ,
        d_cta08m00.vigfnl
   from abamapol
  where abamapol.succod    = g_documento.succod     and
        abamapol.aplnumdig = g_documento.aplnumdig

 #--------------------------------------------------------------------------
 # Categoria
 #--------------------------------------------------------------------------
 select ctgtrfcod
   into d_cta08m00.ctgtrfcod
   from abbmcasco
  where abbmcasco.succod    = g_documento.succod     and
        abbmcasco.aplnumdig = g_documento.aplnumdig  and
        abbmcasco.itmnumdig = g_documento.itmnumdig  and
        abbmcasco.dctnumseq = g_funapol.autsitatu

 display by name d_cta08m00.*
 #----------------------------------------------------------------------------

 call fadic008(g_documento.succod,
               g_documento.aplnumdig,
               g_documento.itmnumdig)
    returning ret008[1].*, ret008[2].*, ret008[3].*, ret008[4].*,
              ret008[5].*, ret008[6].*, ret008[7].*, ret008[8].*,
              ret008[9].*, ret008[10].*,ret008[11].*,ret008[12].*,
              ret008[13].*,ret008[14].*,ret008[15].*,ret008[16].*,
              ret008[17].*,ret008[18].*,ret008[19].*,ret008[20].*,
              ret008[21].*,ret008[22].*,ret008[23].*,ret008[24].*,
              ret008[25].*,ret008[26].*,ret008[27].*,ret008[28].*,
              ret008[29].*,ret008[30].*,ws.ok
 if g_issk.funmat = 601566 then
    display "*** ws.ok = ", ws.ok
 end if
 if ws.ok is not null then
    error  "Problemas no acesso a funcao - fadic008, Avise Informatica"
    prompt "" for char ws.pergunta
    close window w_cta08m00
    return
 end if

 let int_flag = false

 while not int_flag
   let arr_aux = 1
   select count(*) into w_count
        from temp_ctn05c03a
   if w_count > 0 then
      delete from temp_ctn05c03a
   end if
   while true
       if ret008[arr_aux].discoddig is null then
          exit while
       end if
       let a_cta08m00[arr_aux].discoddig = ret008[arr_aux].discoddig
       let a_cta08m00[arr_aux].disnom    = ret008[arr_aux].disnom
       if  ret008[arr_aux].flag          = "N" then
           let a_cta08m00[arr_aux].descr = "Novo Servico"
       end if
       if  ret008[arr_aux].rlzdt  is not null  then
           let a_cta08m00[arr_aux].descr = ret008[arr_aux].rlzdt
           if ret008[arr_aux].rlzdt < d_cta08m00.viginc  then # fora vigencia
              let a_cta08m00[arr_aux].descr = null
           end if
       end if
       insert into temp_ctn05c03a
          values (a_cta08m00[arr_aux].discoddig,
                  a_cta08m00[arr_aux].disnom   ,
                  a_cta08m00[arr_aux].descr)
       let arr_aux = arr_aux + 1
       if arr_aux > 30 then
          error " Limite de consulta excedido. Avise a informatica!"
          sleep 3
          exit while
       end if
   end while
   call set_count(arr_aux-1)

   options insert key f35 ,
           delete key f36

   input array a_cta08m00 without defaults from s_cta08m00.*

      before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()
          let ws.consulta = 0

      after field opcao
          if a_cta08m00[arr_aux].discoddig is null then
             exit input
          end if
          display a_cta08m00[arr_aux].opcao     to
                  s_cta08m00[scr_aux].opcao
          if a_cta08m00[arr_aux].opcao <> "X" and
             a_cta08m00[arr_aux].opcao is not null then
             error " Escolha com X "
             next field opcao
          end if

      on key (interrupt,control-c)
          if wg_grava_ligacao = "N" then
          else
             call cta08m00_gera_ligacao()
             let int_flag = true
          end if
          exit input

      on key(F1)
         if g_documento.c24astcod is not null then
            call ctc58m00_vis(g_documento.c24astcod)
         end if

      on key(F5)
         ##call cta01m00()
          call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

      on key(F6)
         if ws.F8 is null and
            ws.F9 is null then
            error "Selecione F8 ou F9"
            next field opcao
         end if
         let ws.consulta = 1
         exit input

     #on key(F7)
     #   error " Registre as informacoes no historico!"
     #   let g_documento.acao = "INC"
     #   call cta03n00(g_documento.lignum, g_issk.funmat,
     #                 ws.data, ws.hora)
     #   let int_flag = true
     #   exit input

      on key(F8)
         let arr_aux = 1
         initialize ws.F8 to null
         select count(*) into w_count
             from temp_cta08m00
         if w_count > 0 then
            delete from temp_cta08m00
         end if
         while true
            if a_cta08m00[arr_aux].opcao = "X" then
               insert into temp_cta08m00 --[esta tabela sera lida no ctn05c03]--
               values (a_cta08m00[arr_aux].discoddig)
            end if
            let arr_aux = arr_aux + 1
            if a_cta08m00[arr_aux].discoddig is null then
               exit while
            end if
         end while
         select count(*) into w_count
            from temp_cta08m00
         if w_count > 0 then
            let ws.consulta = 1
            let ws.F8       = 1
         else
            error "E necessario a escolha de um servico"
         end if
         exit input

       on key(F9)
         let arr_aux = 1
         initialize ws.F9 to null
         select count(*) into w_count
             from temp_cta08m00
         if w_count > 0 then
            delete from temp_cta08m00
         end if
         while true
            insert into temp_cta08m00 --[esta tabela sera lida no ctn05c03]--
            values (a_cta08m00[arr_aux].discoddig)
            let arr_aux = arr_aux + 1
            if a_cta08m00[arr_aux].discoddig is null then
               exit while
            end if
         end while
         select count(*) into w_count
            from temp_cta08m00
         if w_count > 0 then
            let ws.F9       = 1
            let ws.consulta = 1
         end if
         exit input
   end input
   if int_flag  then
       exit while
   end if
   if ws.consulta = 1 then
      let ws.consulta = 0
      while true
         initialize ws.endcep    to null
         initialize ws.endcepcmp to null
        #call ctn00c02 ("SP","SAO PAULO"," "," ")
         call ctn00c02 (ws.ufdcod,ws.vclcircid," "," ")
                   returning ws.endcep, ws.endcepcmp
         if ws.endcep is null  then
            error "Nenhum criterio foi selecionado!"
            continue while
         else
            let int_flag = false
            call ctn05c03(ws.endcep)
            if int_flag then # este int_flag foi marcado na tela ctn05c03
               exit while
            end if
         end if
         if ws.endcep is not null then
            exit while
         end if
      end while
   end if
 end while

 let int_flag = false
 let arr_aux = arr_curr()

 close window w_cta08m00

end function

#-----------------------------------------------------------------------------
function cta08m00_gera_ligacao()
#-----------------------------------------------------------------------------
 define ws  record
     pergunta           char(01)                   ,
     lignum             like datmligacao.lignum    ,
     atdsrvnum          like datmservico.atdsrvnum ,
     atdsrvano          like datmservico.atdsrvano ,
     sqlcode            integer                    ,
     tabname            like systables.tabname     ,
     msg                char(80)                ,
     hora               char (05)                  ,
     data               date
 end record

 define l_data    date,
        l_hora2   datetime hour to minute

	initialize  ws.*  to  null

 initialize ws.*         to null
 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2

 let ws.data  =  l_data
 let ws.hora  =  l_hora2

 #---------------------------------------------------------------
 # Busca numeracao ligacao
 #---------------------------------------------------------------
 begin work
 call cts10g03_numeracao( 1, "" )
     returning ws.lignum   ,
               ws.atdsrvnum,
               ws.atdsrvano,
               ws.sqlcode  ,
               ws.msg
 if  ws.sqlcode <> 0  then
     let ws.msg = "cta08m00 - ",ws.msg
     call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
     rollback work
     prompt "" for char ws.pergunta
     return
 end if
 let g_documento.lignum = ws.lignum
 #---------------------------------------------------------------
 # Grava ligacao
 #---------------------------------------------------------------
 call cts10g00_ligacao ( ws.lignum               ,
                         ws.data                 ,
                         ws.hora                 ,
                         g_documento.c24soltipcod,
                         g_documento.solnom      ,
                         g_documento.c24astcod   ,
                         g_issk.funmat           ,
                         g_documento.ligcvntip   ,
                         g_c24paxnum             ,
                         "","", "","", "",""     ,
                         g_documento.succod      ,
                         g_documento.ramcod      ,
                         g_documento.aplnumdig   ,
                         g_documento.itmnumdig   ,
                         g_documento.edsnumref   ,
                         g_documento.prporg      ,
                         g_documento.prpnumdig   ,
                         g_documento.fcapacorg   ,
                         g_documento.fcapacnum   ,
                         "","","",""             ,
                         "", "", "", "" )
             returning ws.tabname,
                       ws.sqlcode
 if  ws.sqlcode  <>  0  then
     error " Erro (", ws.sqlcode, ") na gravacao da",
           " tabela ", ws.tabname clipped,".AVISE A INFORMATICA!"
     rollback work
     prompt "" for char ws.pergunta
     return
 end if
 commit work
 error " Registre as informacoes no historico!"
 let g_documento.acao = "INC"
 call cta03n00(g_documento.lignum, g_issk.funmat,
               ws.data, ws.hora)
end function
