###########################################################################
# Nome do Modulo: CTN29C00                                       Gilberto #
#                                                                 Marcelo #
# Consulta oficinas do produto - AUTO REVENDAS                   Out/1996 #
###########################################################################

database porto

globals '/homedsa/projetos/geral/globals/glct.4gl' 

define gm_seqpesquisa   smallint
define arr_aux          smallint

#------------------------------------------------------------
function ctn29c00(par)
#------------------------------------------------------------
# Menu do modulo
# --------------
 define par           record
        endcep        like glaklgd.lgdcep
 end record

 define k_ctn29c00    record
        succod        like abbmitem.succod    ,
        aplnumdig     like abbmitem.aplnumdig ,
        itmnumdig     like abbmitem.itmnumdig ,
        vclmrccod     like agbkmarca.vclmrccod,
        revflg        char(01)
 end record



	initialize  k_ctn29c00.*  to  null

 let int_flag = false
 initialize k_ctn29c00.* to  null

 open window ctn29c00 at 4,2 with form "ctn29c00"

 menu "AUTO_REVENDAS"

   command key ("S") "Seleciona"  "Pesquisa tabela conforme criterios"
           message ""
           if par.endcep is null     then
              error " Nenhum logradouro foi selecionado!"
              next option "Encerra"
           else
              clear form
              call seleciona_ctn29c00(par.*) returning k_ctn29c00.*
              if k_ctn29c00.revflg = "s"   then
                 call pesquisa_ctn29c00(k_ctn29c00.*, par.*, "s")
              else
                 error " Apolice nao possui Auto Revendas !"
                 continue menu
              end if

              let  gm_seqpesquisa = 0
              if  arr_aux  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa Proxima Regiao do Cep"
           message ""
           if par.endcep is null     then
              error " Nenhum Cep Selecionado!"
              next option "Encerra"
           else
              if k_ctn29c00.revflg = "s"   then
                 let  gm_seqpesquisa = gm_seqpesquisa + 1
                 call pesquisa_ctn29c00(k_ctn29c00.*, par.*, "p")
              else
                 error " Apolice nao possui Auto Revendas !"
                 continue menu
              end if

              if  arr_aux  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu

 end menu

 close window ctn29c00

end function  ###  ctn29c00

#------------------------------------------------------------
 function seleciona_ctn29c00(par)
#------------------------------------------------------------

 define par          record
        endcep       like glaklgd.lgdcep
 end record

 define d_ctn29c00   record
        succod       like abbmitem.succod   ,
        aplnumdig    like abbmitem.aplnumdig,
        itmnumdig    like abbmitem.itmnumdig,
        vcldes       char(60)               ,
        nfscnsnom    like abbm0km.nfscnsnom
 end record

 define ws           record
        vclmrccod    like agbkmarca.vclmrccod,
        vcltipcod    like agbktip.vcltipcod  ,
        vclcoddig    like agbkveic.vclcoddig ,
        vclmrcnom    like agbkmarca.vclmrcnom,
        vcltipnom    like agbktip.vcltipnom  ,
        vclmdlnom    like agbkveic.vclmdlnom ,
        revflg       char(01)
 end record

 define ws_funapol   record
        resultado    char(01)      ,
        dctnumseq    decimal(04,00),
        vclsitatu    decimal(04,00),
        autsitatu    decimal(04,00),
        dmtsitatu    decimal(04,00),
        dpssitatu    decimal(04,00),
        appsitatu    decimal(04,00),
        vidsitatu    decimal(04,00)
 end record



	initialize  d_ctn29c00.*  to  null

	initialize  ws.*  to  null

	initialize  ws_funapol.*  to  null

 clear form
 initialize d_ctn29c00.*, ws.*, ws_funapol.*  to null

 input by name d_ctn29c00.succod   ,
               d_ctn29c00.aplnumdig,
               d_ctn29c00.itmnumdig

    before field succod
        display by name d_ctn29c00.succod attribute (reverse)

    after  field succod
        display by name d_ctn29c00.succod

        if d_ctn29c00.succod  is null  then
           error " Sucursal deve ser informada!"
           next field succod
        end if

        select succod from gabksuc
         where succod = d_ctn29c00.succod

        if sqlca.sqlcode = notfound  then
           error " Sucursal nao cadastrada!"
           next field succod
        end if

    before field aplnumdig
        display by name d_ctn29c00.aplnumdig  attribute (reverse)

    after  field aplnumdig
        display by name d_ctn29c00.aplnumdig

        if fgl_lastkey() = fgl_keyval("up")     or
           fgl_lastkey() = fgl_keyval("left")   then
           next field succod
        end if

        if d_ctn29c00.aplnumdig  is null  then
           error " Apolice deve ser informada!"
           next field aplnumdig
        end if

    before field itmnumdig
        display by name d_ctn29c00.itmnumdig  attribute (reverse)

    after  field itmnumdig
        display by name d_ctn29c00.itmnumdig

        if fgl_lastkey() = fgl_keyval("up")     or
           fgl_lastkey() = fgl_keyval("left")   then
           next field aplnumdig
        end if

        if d_ctn29c00.itmnumdig  is null  then
           error " Item deve ser informado!"
           next field itmnumdig
        end if

        select * from abbmitem
         where succod    = d_ctn29c00.succod     and
               aplnumdig = d_ctn29c00.aplnumdig  and
               itmnumdig = d_ctn29c00.itmnumdig

        if sqlca.sqlcode = notfound  then
           error " Apolice/Item nao cadastrado!"
           next field itmnumdig
        end if

        # -------------  LEITURA DAS TABELAS  ---------------
        call f_funapol_ultima_situacao
             (d_ctn29c00.succod, d_ctn29c00.aplnumdig, d_ctn29c00.itmnumdig)
              returning  ws_funapol.*

        # ----------------  DADOS DO VEICULO  ----------------
        select vclcoddig
          into ws.vclcoddig
          from abbmveic
         where abbmveic.succod     = d_ctn29c00.succod     and
               abbmveic.aplnumdig  = d_ctn29c00.aplnumdig  and
               abbmveic.itmnumdig  = d_ctn29c00.itmnumdig  and
               abbmveic.dctnumseq  = ws_funapol.vclsitatu

        if sqlca.sqlcode  <>  notfound   then
           select vclmrccod, vcltipcod, vclmdlnom
             into ws.vclmrccod, ws.vcltipcod, ws.vclmdlnom
             from agbkveic
            where agbkveic.vclcoddig = ws.vclcoddig

           select vclmrcnom
             into ws.vclmrcnom
             from agbkmarca
            where agbkmarca.vclmrccod = ws.vclmrccod

           select vcltipnom
             into ws.vcltipnom
             from agbktip
            where agbktip.vclmrccod = ws.vclmrccod    and
                  agbktip.vcltipcod = ws.vcltipcod

           let d_ctn29c00.vcldes = ws.vclmrcnom  clipped, " ",
                                   ws.vcltipnom  clipped, " ",
                                   ws.vclmdlnom
        else
           error " Dados do veiculo nao encontrado!"
        end if

        # -----------  DADOS DO AUTO REVENDAS  -------------
        initialize d_ctn29c00.nfscnsnom   to null
        let ws.revflg = "n"
        select cndeslcod
          from abbmcondesp
         where abbmcondesp.succod     =  d_ctn29c00.succod     and
               abbmcondesp.aplnumdig  =  d_ctn29c00.aplnumdig  and
               abbmcondesp.itmnumdig  =  d_ctn29c00.itmnumdig  and
               abbmcondesp.dctnumseq  =  ws_funapol.dctnumseq  and
               abbmcondesp.cndeslcod  =  50

        if sqlca.sqlcode  =   0        then
           let ws.revflg = "s"
        else
           if sqlca.sqlcode  <>  100   then
              error " Erro (",sqlca.sqlcode,") leitura dos dados do Auto Revenda !"
           end if
        end if

        select nfscnsnom
          into d_ctn29c00.nfscnsnom
          from abbm0km
         where abbm0km.succod     =  d_ctn29c00.succod     and
               abbm0km.aplnumdig  =  d_ctn29c00.aplnumdig  and
               abbm0km.itmnumdig  =  d_ctn29c00.itmnumdig  and
               abbm0km.dctnumseq  =  ws_funapol.vclsitatu

        if sqlca.sqlcode  <>  0    and
           sqlca.sqlcode  <>  100  then
           error " Erro (",sqlca.sqlcode,") na leitura dos dados da concessionaria!"
        end if

        display by name d_ctn29c00.*

        if d_ctn29c00.nfscnsnom   is not null    then
           display by name d_ctn29c00.nfscnsnom   attribute(reverse)
        end if

     on key (interrupt)
            exit input

  end input

 if int_flag  then
    initialize d_ctn29c00.*  to null
    clear form
    error  " Operacao cancelada!"
 end if

 let int_flag = false

 return d_ctn29c00.succod   , d_ctn29c00.aplnumdig, d_ctn29c00.itmnumdig,
        ws.vclmrccod        , ws.revflg

end function  ###  seleciona_ctn29c00

#----------------------------------------------------------------
 function pesquisa_ctn29c00(par)
#----------------------------------------------------------------

 define par           record
        succod        like abbmitem.succod    ,
        aplnumdig     like abbmitem.aplnumdig ,
        itmnumdig     like abbmitem.itmnumdig ,
        vclmrccod     like agbkmarca.vclmrccod,
        revflg        char(01)                ,
        endcep        like glaklgd.lgdcep     ,
        psqflg        char(01)
 end record

 define a_ctn29c00 array [100] of record
        nomrazsoc     like gkpkpos.nomrazsoc ,
        pstcoddig     like gkpkpos.pstcoddig ,
        endlgd        like gkpkpos.endlgd    ,
        endbrr        like gkpkpos.endbrr    ,
        endcid        like gkpkpos.endcid    ,
        endufd        like gkpkpos.endufd    ,
        dddcod        like gkpkpos.dddcod    ,
        teltxt        like gkpkpos.teltxt
 end record

 define ws            record
        endcep        like glaklgd.lgdcep    ,
        msgindic      char(70)               ,
        comando       char(300)              ,
        nomrazsoc     like gkpkpos.nomrazsoc ,
        pstcoddig     like gkpkpos.pstcoddig ,
        endlgd        like gkpkpos.endlgd    ,
        endbrr        like gkpkpos.endbrr    ,
        endcid        like gkpkpos.endcid    ,
        endufd        like gkpkpos.endufd    ,
        dddcod        like gkpkpos.dddcod    ,
        teltxt        like gkpkpos.teltxt
 end record



	define	w_pf1	integer


	for	w_pf1  =  1  to  100
		initialize  a_ctn29c00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 let int_flag = false
 initialize  ws.*         to null
 initialize  a_ctn29c00   to null
 let arr_aux  = 1

 if par.psqflg  =  "s"  then
    message " Aguarde, pesquisando... ", par.endcep   attribute (reverse)

    declare c_ctn29c00s  cursor for
      select nomrazsoc, pstcoddig, endlgd    ,
             endbrr   , endcid   , endufd    ,
             dddcod   , teltxt
        from gkpkpos, sgokofi
       where gkpkpos.endcep     =  par.endcep
         and gkpkpos.pstcoddig  >  0
         and sgokofi.vclmrccod  =  par.vclmrccod
         and sgokofi.ofnnumdig  =  gkpkpos.pstcoddig
         and sgokofi.autrevflg  =  "S"

    foreach c_ctn29c00s  into  a_ctn29c00[arr_aux].nomrazsoc ,
                               a_ctn29c00[arr_aux].pstcoddig ,
                               a_ctn29c00[arr_aux].endlgd    ,
                               a_ctn29c00[arr_aux].endbrr    ,
                               a_ctn29c00[arr_aux].endcid    ,
                               a_ctn29c00[arr_aux].endufd    ,
                               a_ctn29c00[arr_aux].dddcod    ,
                               a_ctn29c00[arr_aux].teltxt

        let arr_aux = arr_aux + 1
        if arr_aux  >  100   then
           error " Limite excedido! Existem mais de 100 oficinas para pesquisa!"
           exit foreach
        end if

    end foreach

 else

    let ws.endcep = par.endcep
    if   gm_seqpesquisa   =   1  then
         if ws.endcep[4,5]     =   "00"  then
            let  gm_seqpesquisa   =   2
         end if
    end if

    case gm_seqpesquisa
      when  1
        let  ws.endcep[5,5] = "*"
      when  2
        let  ws.endcep[4,5] = "* "
      when  3
        let  ws.endcep[3,5] = "*  "
      when  4
        let  ws.endcep[2,5] = "*   "
      otherwise
        error " Nenhuma oficina localizada nesta regiao!"
        return
    end case
    message " Aguarde, pesquisando... ", ws.endcep   attribute (reverse)

    let ws.comando  = "select ofnnumdig            ",
                      "  from sgokofi              ",
                      " where sgokofi.ofnnumdig  =  ?             ",
                      "   and sgokofi.vclmrccod  = ", par.vclmrccod,
                      "   and sgokofi.autrevflg  =  'S'"
    prepare sel_ctn29c00pr from ws.comando
    declare c_ctn29c00pr cursor for sel_ctn29c00pr

    declare c_ctn29c00p  cursor for
      select pstcoddig, nomrazsoc, endlgd
             endbrr   , endcid   , endufd
             dddcod   , teltxt
        from gkpkpos
       where gkpkpos.endcep    matches ws.endcep
         and gkpkpos.pstcoddig  >  0

    foreach c_ctn29c00p  into  ws.pstcoddig ,
                               ws.nomrazsoc ,
                               ws.endlgd    ,
                               ws.endbrr    ,
                               ws.endcid    ,
                               ws.endufd    ,
                               ws.dddcod    ,
                               ws.teltxt

       open  c_ctn29c00pr  using  ws.pstcoddig
       foreach c_ctn29c00pr into  a_ctn29c00[arr_aux].pstcoddig
          let a_ctn29c00[arr_aux].nomrazsoc = ws.nomrazsoc
          let a_ctn29c00[arr_aux].endlgd    = ws.endlgd
          let a_ctn29c00[arr_aux].endbrr    = ws.endbrr
          let a_ctn29c00[arr_aux].endcid    = ws.endcid
          let a_ctn29c00[arr_aux].endufd    = ws.endufd
          let a_ctn29c00[arr_aux].dddcod    = ws.dddcod
          let a_ctn29c00[arr_aux].teltxt    = ws.teltxt

          let arr_aux = arr_aux + 1
          if arr_aux  >  100   then
             error " Limite excedido! Existem mais de 100 oficinas para pesquisa !"
             exit foreach
          end if
       end foreach
       if arr_aux  >  100   then
          error " Limite excedido! Existem mais de 100 oficinas para pesquisa !"
          exit foreach
       end if
    end foreach

 end if
 message " "

 if arr_aux  >  1   then
    message " (F17)Abandona, (F8)Indicacao "
    call set_count(arr_aux-1)

    display array a_ctn29c00 to s_ctn29c00.*
        on key(F8)
           initialize ws.msgindic   to null
           let arr_aux = arr_curr()
           insert into ssamofnapol (succod   , aplnumdig, itmnumdig,
                                    atldat   , atlhor   , funmat   ,
                                    ofnnumdig)
                            values (par.succod   , par.aplnumdig,
                                    par.itmnumdig, today        ,
                                    current hour to minute      ,
                                    g_issk.funmat,
                                    a_ctn29c00[arr_aux].pstcoddig)

            if sqlca.sqlcode <> 0    then
               error " Erro (",sqlca.sqlcode,") na gravacao da indicacao!"
            else
               let ws.msgindic = " INDICACAO PARA  *",
                                 a_ctn29c00[arr_aux].nomrazsoc  clipped,
                                 "*  REGISTRADA"
               error ws.msgindic
            end if

        on key(F17)
           exit display

    end display
 else
    error " Nenhum registro localizado nesta regiao - Tente Proxima_regiao!"
 end if

 let int_flag = false

end function  ###  pesquisa_ctn29c00
