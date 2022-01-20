#############################################################################
# Nome do Modulo: CTN06C01                                            Pedro #
#                                                                           #
# Consulta de Oficinas por Cep                                     Set/1994 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 06/10/1998               Gilberto     Fazer "leitura suja" da tabela de   #
#                                       oficinas para evitar queda da tela  #
#                                       por causa de registros locados.     #
#---------------------------------------------------------------------------#
# 06/03/2001  PSI 12599-7  Raji         Inclusao da marca da oficina.       #
#---------------------------------------------------------------------------#
# 23/05/2001  PSI 13081-8  Ruiz         Nao mostrar oficinas com ofnstt="S" #
#---------------------------------------------------------------------------#
# ------------------------------------------------------------------------------
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 04/10/2004 Paulo, Meta       PSI187682  Incluir a informacao LEV/TRAZ na   #
#                                         tela.                              #
##############################################################################

 database porto

 define  gm_seqpesquisa integer
 define  gm_seleciona   char (01)

#---------------------------------------------------------------
 function ctn06c01(param)
#---------------------------------------------------------------

 define param      record
    endcep         like  glaklgd.lgdcep,
    psqtip         dec(1,0),               ##  (1)Cep, (2)Nome
    grtmecflg      char (01),              ##  Flag Garantia Mecanica
    tela           char (08)
 end record

 define k_ctn06c01 record
    pstcoddig      like gkpkpos.pstcoddig,
    nomrazsoc      like gkpkpos.nomrazsoc,
    endlgd         like gkpkpos.endlgd,
    endbrr         like gkpkpos.endbrr,
    endcid2        like gkpkpos.endcid,
    endufd2        like gkpkpos.endufd,
    vclmrccod      like agbkmarca.vclmrccod,
    vclmrcnom      like agbkmarca.vclmrcnom
 end record



	initialize  k_ctn06c01.*  to  null

 open window w_ctn06c01 at 04,02 with form "ctn06c01"

 initialize k_ctn06c01.*   to null

 menu "OFICINAS"

    before menu
          hide option all
          show option "Seleciona"
          show option "Encerra"

         if param.psqtip  =  1   then
            show option "Proxima_regiao"
         end if

    command key ("S") "Seleciona"  "Pesquisa Tabela Conforme Criterios"
           message ""
           if param.psqtip =  1      and
              param.endcep is null   then
              error "Nenhum logradouro foi selecionado!"
              next option "Encerra"
           else
              let gm_seleciona   = "N"
              let gm_seqpesquisa = 0
              call pesquisa_ctn06c01(param.*,
                                     k_ctn06c01.vclmrccod,
                                     k_ctn06c01.vclmrcnom, "","")
                   returning k_ctn06c01.pstcoddig,
                             k_ctn06c01.nomrazsoc,
                             k_ctn06c01.endlgd   ,
                             k_ctn06c01.endbrr   ,
                             k_ctn06c01.endcid2  ,
                             k_ctn06c01.endufd2  ,
                             k_ctn06c01.vclmrccod,
                             k_ctn06c01.vclmrcnom,
                             gm_seleciona

              if gm_seleciona  =  "S"   then
                 exit menu
              end if
              if param.psqtip  =  1   then
                 next option "Proxima_regiao"
              end if
           end if

    command key ("P") "Proxima_regiao" "Pesquisa Proxima Regiao do Cep"
           message ""
           if param.endcep is null     then
              error "Nenhum Cep Selecionado!"
              next option "Encerra"
           else
              let gm_seleciona    = "N"
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call pesquisa_ctn06c01(param.*,
                                     k_ctn06c01.vclmrccod,
                                     k_ctn06c01.vclmrcnom, "","")
                   returning k_ctn06c01.pstcoddig,
                             k_ctn06c01.nomrazsoc,
                             k_ctn06c01.endlgd   ,
                             k_ctn06c01.endbrr   ,
                             k_ctn06c01.endcid2  ,
                             k_ctn06c01.endufd2  ,
                             k_ctn06c01.vclmrccod,
                             k_ctn06c01.vclmrcnom,
                             gm_seleciona
           end if
           if gm_seleciona  =  "S"   then
              exit menu
           end if

           if gm_seqpesquisa  >  4   then
              next option "Encerra"
           end if

    command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   let int_flag = false
   close window w_ctn06c01

   return k_ctn06c01.pstcoddig,
          k_ctn06c01.nomrazsoc,
          k_ctn06c01.endlgd   ,
          k_ctn06c01.endbrr   ,
          k_ctn06c01.endcid2  ,
          k_ctn06c01.endufd2

end function  ###  ctn06c01


#-------------------------------------------------------------------
 function pesquisa_ctn06c01(param, d_ctn06c01)
#-------------------------------------------------------------------

 define param       record
    endcep          like glaklgd.lgdcep,
    psqtip          dec(1,0),
    grtmecflg       char (01),
    tela            char (08)
 end record

 define d_ctn06c01  record
    vclmrccod       like agbkmarca.vclmrccod,
    vclmrcnom       like agbkmarca.vclmrcnom,
    nomepsq         char (25),
    nometip         char (01)
 end record

 define a_ctn06c01 array[150] of record
    nomrazsoc      like gkpkpos.nomrazsoc,
    pstcoddig      like gkpkpos.pstcoddig,
    srvnoite       char (10),
    endlgd         like gkpkpos.endlgd,
    endbrr         like gkpkpos.endbrr,
    endcid2        like gkpkpos.endcid,
    endufd2        like gkpkpos.endufd,
    endcep2        like glaklgd.lgdcep,
    endcepcmp      like glaklgd.lgdcepcmp,
    dddcod         like gkpkpos.dddcod,
    telnum1        like gkpkpos.telnum1,
    telnum2        like gkpkpos.telnum2,
    tipo           char (14),
    marca          char (16),
    hormnhinc      like gkpkpos.hormnhinc,
    hormnhfnl      like gkpkpos.hormnhfnl,
    hortrdinc      like gkpkpos.hortrdinc,
    hortrdfnl      like gkpkpos.hortrdfnl,
    horsabinc      like gkpkpos.horsabinc,
    horsabfnl      like gkpkpos.horsabfnl,
    servicos       char (19),
    ofnobs         like sgokofi.ofnobs,
    qualidade      char (10),
    leva_traz      char(08)                                    ### PSI187682 - Paulo
 end record

 define ws          record
    comando1        char (800),
    comando2        char (300),
    nomepsq         char (25),
    qtdchar         smallint,
    vclcoddig       like agbkveic.vclcoddig,
    vclmdlnom       like agbkveic.vclmdlnom,
    tpcflg          like sgokofi.tpcflg,
    mcnflg          like sgokofi.mcnflg,
    eltflg          like sgokofi.eltflg,
    fnrflg          like sgokofi.fnrflg,
    pntflg          like sgokofi.pntflg,
    ofnstt          like sgokofi.ofnstt,
    vclmrccod       like sgokofi.vclmrccod,
    ofncvnflg       char (01),
    ofnocpprc       smallint,
    ofngrtmecflg    like sgokofi.ofngrtmecflg,
    qualidade       like sgokofi.qldgracod,
    confirma        char (01)
 end record

 define arr_aux     smallint
 define scr_aux     smallint

 define l_flag_leva_traz   char(01)                             ### PSI187682 - Paulo

	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  150
		initialize  a_ctn06c01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_ctn06c01    to null
 initialize ws.*          to null
 let arr_aux  =  1

 input  by  name d_ctn06c01.vclmrccod,
                 d_ctn06c01.vclmrcnom,
                 d_ctn06c01.nomepsq,
                 d_ctn06c01.nometip    without defaults

    before field vclmrccod
        if param.psqtip  =  1   then
           if gm_seqpesquisa  >  0   then
              exit input
           end if
        else
           next field nomepsq
        end if
        display by name d_ctn06c01.vclmrccod  attribute (reverse)

    after  field vclmrccod
        display by name d_ctn06c01.vclmrccod

        if d_ctn06c01.vclmrccod  is not null   then
           select vclmrcnom, vclmrccod
             into d_ctn06c01.vclmrcnom, d_ctn06c01.vclmrccod
             from agbkmarca
            where vclmrccod = d_ctn06c01.vclmrccod

           if status = notfound then
              error "Codigo da marca invalido!"
              call agguvcl2("")
                   returning d_ctn06c01.vclmrcnom, d_ctn06c01.vclmrccod
              next field  vclmrccod
           end if
        else
           let d_ctn06c01.vclmrcnom = "TODAS"
        end if

        display by name d_ctn06c01.vclmrccod
        display by name d_ctn06c01.vclmrcnom
        exit input

    before field nomepsq
        display by name d_ctn06c01.nomepsq  attribute (reverse)

    after  field nomepsq
        display by name d_ctn06c01.nomepsq

        if fgl_lastkey() = fgl_keyval ("up")     or
           fgl_lastkey() = fgl_keyval ("left")   then
           next field  nomepsq
        end if

        if d_ctn06c01.nomepsq  is null   then
           error " Nome para pesquisa deve ser informado!"
           next field nomepsq
        end if

        let ws.qtdchar = (length (d_ctn06c01.nomepsq))

        if  ws.qtdchar < 4   then
            error " Minimo de 4 letras para pesquisar!"
            next field nomepsq
        end if

    before field nometip
        display by name d_ctn06c01.nometip  attribute (reverse)

    after  field nometip
        display by name d_ctn06c01.nometip

        if fgl_lastkey() = fgl_keyval ("up")     or
           fgl_lastkey() = fgl_keyval ("left")   then
           next field  nomepsq
        end if

        if ((d_ctn06c01.nometip  is null)   or
            (d_ctn06c01.nometip  <> "G"     and
             d_ctn06c01.nometip  <> "R"))    then
           error " Tipo deve ser: (G)uerra ou (R)azao social!"
           next field nometip
        end if

        let ws.nomepsq = d_ctn06c01.nomepsq clipped, "*"

        on key (interrupt)
           exit input

 end input


 if not int_flag    then
#-------------------------------------------------------------------
# Pesquisa por CEP
#-------------------------------------------------------------------
    if param.psqtip  =  1   then

       if gm_seqpesquisa = 0   then
          let ws.comando2 = " from  gkpkpos, sgokofi ",
                            " where gkpkpos.endcep    = ? ",
                            "   and sgokofi.ofnnumdig = gkpkpos.pstcoddig ",
                            " order by qldgracod, ",
                            "          endcep "

          if d_ctn06c01.vclmrccod  is not null    and
             d_ctn06c01.vclmrccod  >  0           then
             let ws.comando2 = " from  gkpkpos, sgokofi ",
                               " where gkpkpos.endcep    = ? ",
                               "   and sgokofi.ofnnumdig = gkpkpos.pstcoddig ",
                               "   and sgokofi.vclmrccod = ? ",
                               " order by qldgracod, ",
                               "          endcep "
          end if
       end if

       if gm_seqpesquisa  >  0   then
          if gm_seqpesquisa    = 1     then
             if param.endcep[4,5] = "00"  then
                let gm_seqpesquisa = 2
             end if
          end if

          case gm_seqpesquisa
            when  1
                  let param.endcep[5,5] = "*"
            when  2
                  let param.endcep[4,5] = "* "
            when  3
                  let param.endcep[3,5] = "*  "
            when  4
                  let param.endcep[2,5] = "*   "
            otherwise
                  error "Nao ha' nenhuma oficina localizada nesta regiao!"
                  message " "
                  initialize a_ctn06c01  to null
                  return a_ctn06c01[arr_aux].pstcoddig,
                         a_ctn06c01[arr_aux].nomrazsoc,
                         a_ctn06c01[arr_aux].endlgd   ,
                         a_ctn06c01[arr_aux].endbrr   ,
                         a_ctn06c01[arr_aux].endcid2  ,
                         a_ctn06c01[arr_aux].endufd2  ,
                         d_ctn06c01.vclmrccod,
                         d_ctn06c01.vclmrcnom,
                         gm_seleciona
          end case

          let ws.comando2 = " from  gkpkpos, sgokofi ",
                            " where gkpkpos.endcep matches '",param.endcep,"'",
                            "   and sgokofi.ofnnumdig = gkpkpos.pstcoddig ",
                            " order by qldgracod, ",
                            "          endcep "

          if d_ctn06c01.vclmrccod  is not null    and
             d_ctn06c01.vclmrccod  >  0           then
             let ws.comando2 = " from  gkpkpos, sgokofi ",
                              "where gkpkpos.endcep matches '",param.endcep,"'",
                               "   and sgokofi.ofnnumdig = gkpkpos.pstcoddig ",
                               "   and sgokofi.vclmrccod = ? ",
                               " order by qldgracod, ",
                               "          endcep "
          end if
       end if
    end if

#-------------------------------------------------------------------
# Pesquisa por NOME
#-------------------------------------------------------------------
    if param.psqtip  =  2   then
       if d_ctn06c01.nometip  =  "G"   then
          let ws.comando2 =" from  gkpkpos, sgokofi ",
                           " where gkpkpos.nomgrr matches '",ws.nomepsq,"'",
                           "   and sgokofi.ofnnumdig = gkpkpos.pstcoddig ",
                           " order by qldgracod, ",
                           "          endcep "
       end if

       if d_ctn06c01.nometip  =  "R"   then
          let ws.comando2 =" from  gkpkpos, sgokofi ",
                           " where gkpkpos.nomrazsoc matches '",ws.nomepsq,"'",
                           "   and sgokofi.ofnnumdig = gkpkpos.pstcoddig ",
                           " order by qldgracod, ",
                           "          endcep "
       end if
    end if

    let ws.comando1 = " select nomrazsoc, pstcoddig, srvnteflg, ",
                             " endlgd   , endbrr   , endcid   , ",
                             " endufd   , endcep   , endcepcmp, ",
                             " dddcod   , telnum1  , telnum2  , ",
                             " ofnstt   , ofnobs   , hormnhinc, ",
                             " hormnhfnl, hortrdinc, hortrdfnl, ",
                             " horsabinc, horsabfnl, tpcflg   , ",
                             " mcnflg   , eltflg   , fnrflg   , ",
                             " pntflg   , qldgracod, vclmrccod, ",
                             " ofngrtmecflg, trzlvasrvflg ",             ### PSI187682 - Paulo
                        ws.comando2 clipped

    set isolation to dirty read

    message " Aguarde, pesquisando... ", param.endcep   attribute(reverse)
    prepare p_ctn06c01_001 from ws.comando1
    declare c_ctn06c01_001 cursor for p_ctn06c01_001

    if param.psqtip  =  1   then
       if gm_seqpesquisa  =  0   then
          if d_ctn06c01.vclmrccod  is not null    and
             d_ctn06c01.vclmrccod  >  0           then
             open c_ctn06c01_001  using param.endcep, d_ctn06c01.vclmrccod
          else
             open c_ctn06c01_001  using param.endcep
          end if
       end if

       if gm_seqpesquisa  >  0   then
          if d_ctn06c01.vclmrccod  is not null    and
             d_ctn06c01.vclmrccod  >  0           then
             open c_ctn06c01_001  using d_ctn06c01.vclmrccod
          else
             open c_ctn06c01_001
          end if
       end if
    end if

    if param.psqtip  =  2   then
       open c_ctn06c01_001
    end if

    foreach c_ctn06c01_001 into a_ctn06c01[arr_aux].nomrazsoc,
                            a_ctn06c01[arr_aux].pstcoddig,
                            a_ctn06c01[arr_aux].srvnoite ,
                            a_ctn06c01[arr_aux].endlgd,
                            a_ctn06c01[arr_aux].endbrr,
                            a_ctn06c01[arr_aux].endcid2,
                            a_ctn06c01[arr_aux].endufd2,
                            a_ctn06c01[arr_aux].endcep2,
                            a_ctn06c01[arr_aux].endcepcmp,
                            a_ctn06c01[arr_aux].dddcod,
                            a_ctn06c01[arr_aux].telnum1,
                            a_ctn06c01[arr_aux].telnum2,
                            ws.ofnstt,
                            a_ctn06c01[arr_aux].ofnobs,
                            a_ctn06c01[arr_aux].hormnhinc,
                            a_ctn06c01[arr_aux].hormnhfnl,
                            a_ctn06c01[arr_aux].hortrdinc,
                            a_ctn06c01[arr_aux].hortrdfnl,
                            a_ctn06c01[arr_aux].horsabinc,
                            a_ctn06c01[arr_aux].horsabfnl,
                            ws.tpcflg,
                            ws.mcnflg,
                            ws.eltflg,
                            ws.fnrflg,
                            ws.pntflg,
                            a_ctn06c01[arr_aux].qualidade,
                            ws.vclmrccod,
                            ws.ofngrtmecflg,
                            l_flag_leva_traz                                ### PSI187682 - Paulo

       if l_flag_leva_traz = 'S' then                                       ### PSI187682 - Paulo
          let a_ctn06c01[arr_aux].leva_traz = 'LEV/TRAZ'
       else
          let a_ctn06c01[arr_aux].leva_traz = null
       end if

#-------------------------------------------------------------------
# Pesquisa pela opcao GARANTIA MECANICA
#-------------------------------------------------------------------
       if param.grtmecflg =  "S"  then
          if ws.ofngrtmecflg = "S"  then
          else
             continue foreach
          end if
       end if
       if ws.ofnstt  =  "S"  then  # nao indicar oficinas substituida 23/05/01.
          continue foreach
       end if

       if ws.tpcflg  =  "S"   then
          let a_ctn06c01[arr_aux].servicos =
              a_ctn06c01[arr_aux].servicos clipped,"TAP",","
       end if

       if ws.mcnflg  =  "S"   then
          let a_ctn06c01[arr_aux].servicos =
              a_ctn06c01[arr_aux].servicos clipped,"MEC",","
       end if

       if ws.fnrflg  =  "S"   then
          let a_ctn06c01[arr_aux].servicos =
              a_ctn06c01[arr_aux].servicos clipped,"FUN",","
       end if

       if ws.pntflg  =  "S"   then
          let a_ctn06c01[arr_aux].servicos =
              a_ctn06c01[arr_aux].servicos clipped,"PIN",","
       end if

       if ws.eltflg  =  "S"   then
          let a_ctn06c01[arr_aux].servicos =
              a_ctn06c01[arr_aux].servicos clipped,"ELE",","
       end if

       if ws.ofnstt  =  "C"   then
          let ws.qualidade                  = a_ctn06c01[arr_aux].qualidade
          let a_ctn06c01[arr_aux].qualidade = "OBSERVACAO"
          if param.grtmecflg       = "S" then     # vem do laudo
             case ws.qualidade
                when 1  let a_ctn06c01[arr_aux].qualidade = "OTIMO"
                when 2  let a_ctn06c01[arr_aux].qualidade = "BOM"
                when 3  let a_ctn06c01[arr_aux].qualidade = "REGULAR"
                when 4  let a_ctn06c01[arr_aux].qualidade = "RUIM"
             end case
          end if
       else
          case a_ctn06c01[arr_aux].qualidade
             when 1  let a_ctn06c01[arr_aux].qualidade = "OTIMO"
             when 2  let a_ctn06c01[arr_aux].qualidade = "BOM"
             when 3  let a_ctn06c01[arr_aux].qualidade = "REGULAR"
             when 4  let a_ctn06c01[arr_aux].qualidade = "RUIM"
          end case
       end if

       case a_ctn06c01[arr_aux].srvnoite
          when "S"  let a_ctn06c01[arr_aux].srvnoite = "AT. NOITE"
          when "N"  let a_ctn06c01[arr_aux].srvnoite = "NAO NOITE"
       end case

       let a_ctn06c01[arr_aux].tipo = "PARTICULAR"
       if ws.vclmrccod  is not null   and
          ws.vclmrccod  <> 0          then
          let a_ctn06c01[arr_aux].tipo = "CONCESSIONARIA"

          # MARCA DA CONCESSIONARIA
             select vclmrcnom
               into a_ctn06c01[arr_aux].marca
               from agbkmarca
              where vclmrccod = ws.vclmrccod

             if status = notfound then
                let a_ctn06c01[arr_aux].marca = "MARCA INVALIDA"
             end if
       end if

       let arr_aux = arr_aux + 1
       if arr_aux > 150   then
          error "Limite excedido. Pesquisa com mais de 150 oficinas!"
          exit foreach
       end if
    end foreach

    set isolation to committed read

    if arr_aux  >  1  then
       if param.tela = "ctg3" then
          message " (F17)Abandona "
       else
          message " (F17)Abandona, (F8)Seleciona"
       end if
       call set_count(arr_aux-1)

       while true
         let ws.confirma = "S"
         display array a_ctn06c01 to s_ctn06c01.*
            on key (interrupt,control-c)
               let arr_aux = 1
               initialize a_ctn06c01  to null
               exit display

            on key (F8)
               if param.tela    = "ctg3" then
                  exit display
               end if
               let arr_aux      = arr_curr()
               select ofnstt
                     into ws.ofnstt
                     from sgokofi
                    where ofnnumdig = a_ctn06c01[arr_aux].pstcoddig
               if ws.ofnstt     = "C"  then
                  call cts08g01("C","S","",
                                " OFICINA EM OBSERVACAO ! ",
                                " CONFIRMA A ESCOLHA DA MESMA?",
                                "")
                       returning ws.confirma
                  if ws.confirma = "N"  then
                     exit display
                  end if
               end if
               let gm_seleciona = "S"
               error " Oficina selecionada!"
               exit display
         end display
         if ws.confirma = "S" then
            exit while
         end if
       end while
    else
       message " "
       if param.psqtip  =  1   then
          error "Nenhuma oficina localizada neste cep - Tente Proxima regiao!"
          initialize a_ctn06c01  to null
       else
          error "Nenhuma oficina localizada!"
          initialize a_ctn06c01  to null
       end if
   end if
 end if

 let int_flag = false

 return a_ctn06c01[arr_aux].pstcoddig,
        a_ctn06c01[arr_aux].nomrazsoc,
        a_ctn06c01[arr_aux].endlgd   ,
        a_ctn06c01[arr_aux].endbrr   ,
        a_ctn06c01[arr_aux].endcid2  ,
        a_ctn06c01[arr_aux].endufd2  ,
        d_ctn06c01.vclmrccod,
        d_ctn06c01.vclmrcnom,
        gm_seleciona

end function  ###  ctn06c01
