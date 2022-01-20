############################################################################
# Nome de Modulo: CTB02M17                                        Wagner   #
#                                                                          #
# Exibe totais da OP por Centro de Custo                          Nov/2000 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO RESPONSAVEL    DESCRICAO                         #
#--------------------------------------------------------------------------#
# 12/04/2005  PSI.191167  META,MarcosMP  Unificacao do acesso as tabelas do#
#                Analista Raji Jahchan   Centro de Custos.                 #
#--------------------------------------------------------------------------#
# 29/12/2009 Amilton,Meta                Projeto SUCCOD - Smallint         #
#--------------------------------------------------------------------------#
############################################################################

database porto

#--------------------------------------------------------------------
 function ctb02m17(param)
#--------------------------------------------------------------------

  define param       record
     socopgnum       like dbsmopgitm.socopgnum
  end record

  define ws           record
     socopgitmvlr     like dbsmopgitm.socopgitmvlr,
     c24utidiaqtd     like dbsmopgitm.c24utidiaqtd,
     c24pagdiaqtd     like dbsmopgitm.c24pagdiaqtd,
     slcemp           like datmavisrent.slcemp,
     slcsuccod        like datmavisrent.slcsuccod,
     slccctcod        like datmavisrent.slccctcod,
     vclloctip        like datmavisrent.vclloctip,
     socopgitmcst     like dbsmopgcst.socopgitmcst,
     avialgmtv        like datmavisrent.avialgmtv,
     aviprvent        like datmavisrent.aviprvent,
     cctflg           smallint,
     atdsrvnum        like dbsmopgitm.atdsrvnum,
     atdsrvano        like dbsmopgitm.atdsrvano,
     aviprodiaqtd     like datmprorrog.aviprodiaqtd,
     aviprodiaqtd_tot like datmprorrog.aviprodiaqtd,
     c24utidiaqtd_pro like dbsmopgitm.c24utidiaqtd,
     socopgitmvlr_pro like dbsmopgitm.socopgitmvlr,
     socopgitmcst_pro like dbsmopgcst.socopgitmcst,
     saldo            like dbsmopgitm.c24utidiaqtd
  end record

  define a_ctb02m17   array[50] of record
     flgorigem        char (01),
     slcemp           like datmavisrent.slcemp,
     slcsuccod        like datmavisrent.slcsuccod,
     slccctcod        like datmavisrent.slccctcod,
     cctnom           like ctokcentrosuc.cctnom,
     acmqtd           dec(6,0),
     c24utidiaqtd     like dbsmopgitm.c24utidiaqtd,
     acmtot           dec(15,5),
     acmcst           dec(15,5),
     acmvlr           dec(15,5)
  end record

  define p_ctb02m17   array[50] of record
     atdsrvnum        like dbsmopgitm.atdsrvnum,
     atdsrvano        like dbsmopgitm.atdsrvano
  end record

#=> PSI.191167 - VARIAVEIS ENTRADA/SAIDA P/ FUNCAO 'fctgc102_vld_dep'
  define lr_param     record
         empcod       like ctgklcl.empcod,          -- Empresa
         succod       like ctgklcl.succod,          -- Sucursal
         cctlclcod    like ctgklcl.cctlclcod,       -- Local
         cctdptcod    like ctgrlcldpt.cctdptcod     -- Departamento
  end record
  define lr_ret record
         erro         smallint,                     -- 0-Ok 1-erro
         mens         char(40),
         cctlclnom    like ctgklcl.cctlclnom,       -- Nome do local
         cctdptnom    like ctgkdpt.cctdptnom,       -- Nome depto (antigo cctnom)
         cctdptrspnom like ctgrlcldpt.cctdptrspnom, -- Responsavel pelo depto
         cctdptlclsit like ctgrlcldpt.cctdptlclsit, -- Sit depto (A)tivo (I)nativo
         cctdpttip    like ctgkdpt.cctdpttip        -- Tipo de departamento
  end record

  define arr_aux      smallint
  define scr_aux      smallint


  open window w_ctb02m17 at 08,02 with form "ctb02m17"
       attribute(form line first)

  initialize a_ctb02m17   to null
  initialize p_ctb02m17   to null
  initialize ws.*         to null

  let ws.cctflg = 0

  message " Aguarde, pesquisando... "  attribute(reverse)

  create temp table tmpcct
      (flgorigem    char(1),
       slcemp       decimal(2,0),
       slcsuccod    smallint,  #decimal(2,0), # Projeto Succod
       slccctcod    integer,
       socopgitmvlr decimal(15,2),
       socopgitmcst decimal(15,2),
       qtdreserva   integer,
       c24utidiaqtd decimal(6,0),
       atdsrvnum    decimal(10,0),
       atdsrvano    decimal(2,0)) with no log
  create index  idx_tmpcct on tmpcct (slcemp, slcsuccod, slccctcod)

  #------------------------------------------------------
  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #------------------------------------------------------
  declare c_ctb02m17  cursor for
    select dbsmopgitm.socopgitmvlr,
           dbsmopgitm.c24utidiaqtd,
           dbsmopgitm.c24pagdiaqtd,
           datmavisrent.slcemp,
           datmavisrent.slcsuccod,
           datmavisrent.slccctcod,
           datmavisrent.avialgmtv,
           datmavisrent.aviprvent,
           datmavisrent.vclloctip,
           dbsmopgcst.socopgitmcst,
           dbsmopgitm.atdsrvnum,
           dbsmopgitm.atdsrvano
      from dbsmopgitm, datmavisrent, outer dbsmopgcst
     where dbsmopgitm.socopgnum    = param.socopgnum
       and datmavisrent.atdsrvnum  = dbsmopgitm.atdsrvnum
       and datmavisrent.atdsrvano  = dbsmopgitm.atdsrvano
       and dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum
       and dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

  foreach c_ctb02m17 into ws.socopgitmvlr, ws.c24utidiaqtd,
                          ws.c24pagdiaqtd, ws.slcemp      ,
                          ws.slcsuccod   , ws.slccctcod   ,
                          ws.avialgmtv   , ws.aviprvent   ,
                          ws.vclloctip   , ws.socopgitmcst,
                          ws.atdsrvnum   , ws.atdsrvano


     if ws.socopgitmcst is null then
        let ws.socopgitmcst  = 0
     end if

     #----------------------------
     # Verifica se tem prorrogacao
     #----------------------------
     select sum(aviprodiaqtd)
       into ws.aviprodiaqtd_tot
       from datmprorrog
       where atdsrvnum = ws.atdsrvnum
         and atdsrvano = ws.atdsrvano
         and cctcod    is not null
         and aviprostt = "A"

     if ws.aviprodiaqtd_tot is null then
        let ws.aviprodiaqtd_tot = 0
     end if

     if ws.avialgmtv <> 4 then   # Motivo diferente de DEPTO.
        let ws.saldo = ws.c24pagdiaqtd - ws.aviprvent
        declare c_prorrog cursor for
         select aviprodiaqtd, cctempcod, cctsuccod, cctcod
           from datmprorrog
          where atdsrvnum = ws.atdsrvnum
            and atdsrvano = ws.atdsrvano
            and cctcod    is not null
            and aviprostt = "A"

        foreach c_prorrog into ws.aviprodiaqtd, ws.slcemp   ,
                               ws.slcsuccod   , ws.slccctcod

           if ws.saldo < ws.aviprodiaqtd then
              let ws.aviprodiaqtd = ws.saldo
           end if

           let ws.socopgitmvlr_pro = ws.socopgitmvlr / ws.c24pagdiaqtd *
                                     ws.aviprodiaqtd
           let ws.socopgitmcst_pro = ws.socopgitmcst / ws.c24pagdiaqtd *
                                     ws.aviprodiaqtd

           let ws.cctflg = 1
           call ctb02m17_gravatmp ("P", ws.slcemp          ,
                                        ws.slcsuccod       ,
                                        ws.slccctcod       ,
                                        ws.socopgitmvlr_pro,
                                        ws.socopgitmcst_pro,
                                        ws.aviprodiaqtd    ,
                                        ws.atdsrvnum       ,
                                        ws.atdsrvano       )

           let ws.saldo = ws.saldo - ws.aviprodiaqtd

        end foreach

        continue foreach
     end if

     if ws.vclloctip <> 3  then   # tipo 3 Departamento
        continue foreach
     end if

     if ws.slccctcod is not null then
        let ws.cctflg = 1
        if ws.aviprodiaqtd_tot = 0 then
           call ctb02m17_gravatmp ("R", ws.slcemp      ,
                                        ws.slcsuccod   ,
                                        ws.slccctcod   ,
                                        ws.socopgitmvlr,
                                        ws.socopgitmcst,
                                        ws.c24utidiaqtd,
                                        ws.atdsrvnum   ,
                                        ws.atdsrvano   )
        else
           #----------------------------------
           # Grava reserva por centro de custo
           #----------------------------------
           let ws.socopgitmvlr_pro = ws.socopgitmvlr / ws.c24pagdiaqtd *
                                     ws.aviprvent
           let ws.socopgitmcst_pro = ws.socopgitmcst / ws.c24pagdiaqtd *
                                     ws.aviprvent

           call ctb02m17_gravatmp ("R", ws.slcemp          ,
                                        ws.slcsuccod       ,
                                        ws.slccctcod       ,
                                        ws.socopgitmvlr_pro,
                                        ws.socopgitmcst_pro,
                                        ws.aviprvent       ,
                                        ws.atdsrvnum       ,
                                        ws.atdsrvano       )

           #----------------------------------
           # Grava prorrogacoes por c.de custo
           #----------------------------------
           let ws.saldo = ws.c24pagdiaqtd - ws.aviprvent
           declare c_prorrog1 cursor for
            select aviprodiaqtd, cctempcod, cctsuccod, cctcod
              from datmprorrog
             where atdsrvnum = ws.atdsrvnum
               and atdsrvano = ws.atdsrvano
               and cctcod    is not null
               and aviprostt = "A"

           foreach c_prorrog1 into ws.aviprodiaqtd, ws.slcemp   ,
                                   ws.slcsuccod   , ws.slccctcod

              if ws.saldo < ws.aviprodiaqtd then
                 let ws.aviprodiaqtd = ws.saldo
              end if

              let ws.socopgitmvlr_pro = ws.socopgitmvlr / ws.c24pagdiaqtd *
                                        ws.aviprodiaqtd
              let ws.socopgitmcst_pro = ws.socopgitmcst / ws.c24pagdiaqtd *
                                        ws.aviprodiaqtd

              call ctb02m17_gravatmp ("P", ws.slcemp          ,
                                           ws.slcsuccod       ,
                                           ws.slccctcod       ,
                                           ws.socopgitmvlr_pro,
                                           ws.socopgitmcst_pro,
                                           ws.aviprodiaqtd    ,
                                           ws.atdsrvnum       ,
                                           ws.atdsrvano       )

              let ws.saldo = ws.saldo - ws.aviprodiaqtd

           end foreach

        end if

     end if

  end foreach

  if ws.cctflg = 1 then

     declare c_tmpcct cursor for
      select flgorigem   , slcemp      , slcsuccod   , slccctcod   ,
             socopgitmvlr, socopgitmcst, qtdreserva  , c24utidiaqtd,
             atdsrvnum   , atdsrvano
        from tmpcct
       order by 1,2,3

     let arr_aux = 1
     foreach c_tmpcct into a_ctb02m17[arr_aux].flgorigem   ,
                           a_ctb02m17[arr_aux].slcemp      ,
                           a_ctb02m17[arr_aux].slcsuccod   ,
                           a_ctb02m17[arr_aux].slccctcod   ,
                           a_ctb02m17[arr_aux].acmvlr      ,
                           a_ctb02m17[arr_aux].acmcst      ,
                           a_ctb02m17[arr_aux].acmqtd      ,
                           a_ctb02m17[arr_aux].c24utidiaqtd,
                           p_ctb02m17[arr_aux].atdsrvnum   ,
                           p_ctb02m17[arr_aux].atdsrvano

        let a_ctb02m17[arr_aux].acmtot = a_ctb02m17[arr_aux].acmvlr +
                                        (a_ctb02m17[arr_aux].acmcst * (-1))

#=>     PSI.191167 - ACESSA 'CENTRO DE CUSTO'
        let lr_param.empcod    = a_ctb02m17[arr_aux].slcemp
        let lr_param.succod    = a_ctb02m17[arr_aux].slcsuccod
        let lr_param.cctlclcod = (a_ctb02m17[arr_aux].slccctcod / 10000)
        let lr_param.cctdptcod = (a_ctb02m17[arr_aux].slccctcod mod 10000) 
        call fctgc102_vld_dep(lr_param.*)
             returning lr_ret.*
        if lr_ret.erro <> 0 then
           error lr_ret.mens clipped, " ", a_ctb02m17[arr_aux].slccctcod
           sleep 3
        end if
        let a_ctb02m17[arr_aux].cctnom = lr_ret.cctdptnom

        let arr_aux = arr_aux + 1

        if arr_aux > 50 then
           exit foreach
        end if

     end foreach

     call set_count(arr_aux -1)
     message " (F17)Abandona, (F8)Seleciona"


     display array a_ctb02m17 to s_ctb02m17.*
        on key (interrupt,control-c)
           exit display

        on key (F8)
           let arr_aux = arr_curr()
           if a_ctb02m17[arr_aux].flgorigem  is not null and
              a_ctb02m17[arr_aux].flgorigem  =  "P"      then
              if a_ctb02m17[arr_aux].acmqtd  = 1         then
                 # so existe 1 prorrogacao da reserva
                 error " Prorrogacao por C./custo da reserva : ",
                         p_ctb02m17[arr_aux].atdsrvnum,"/",
                         p_ctb02m17[arr_aux].atdsrvano using "&&"
              else
                 # Nao exibe itens reserva por prorrogacoes
                 error " Prorrogacao por C./Custo com varias reservas! nao e' possivel relatar! "
              end if
           else
              if a_ctb02m17[arr_aux].slccctcod  is not null then
                 call ctb02m10(param.socopgnum, 4,
                               a_ctb02m17[arr_aux].slcemp,
                               a_ctb02m17[arr_aux].slcsuccod,
                               a_ctb02m17[arr_aux].slccctcod)
              end if
           end if
     end display
  else
     error " Nao ha reservas para departamentos com Centro de Custo!"
  end if

  drop table tmpcct

  let int_flag = false
  close c_ctb02m17
  close window w_ctb02m17

end function  ###  ctb02m17

#------------------------------------------------------
function ctb02m17_gravatmp(param)
#------------------------------------------------------

  define param       record
     flgorigem       char (01),
     slcemp          like datmavisrent.slcemp,
     slcsuccod       like datmavisrent.slcsuccod,
     slccctcod       like datmavisrent.slccctcod,
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     c24utidiaqtd    like dbsmopgitm.c24utidiaqtd,
     atdsrvnum       like dbsmopgitm.atdsrvnum,
     atdsrvano       like dbsmopgitm.atdsrvano
  end record

  define ws          record
     flgorigem       char (01),
     flgorigem_new   char (01)
  end record

  select flgorigem
    into ws.flgorigem
    from tmpcct
   where slcemp    = param.slcemp
     and slcsuccod = param.slcsuccod
     and slccctcod = param.slccctcod

  if sqlca.sqlcode = notfound then
     insert into tmpcct values (param.flgorigem   , param.slcemp      ,
                                param.slcsuccod   , param.slccctcod   ,
                                param.socopgitmvlr, param.socopgitmcst,
                                   1              , param.c24utidiaqtd,
                                param.atdsrvnum   , param.atdsrvano   )
  else
     case ws.flgorigem
       when "P"  if param.flgorigem = "P" then
                    let ws.flgorigem_new = "P"
                 else
                    let ws.flgorigem_new = "*"
                 end if

       when "*"  let ws.flgorigem_new = "*"

       otherwise if param.flgorigem = "P" then
                    let ws.flgorigem_new = "*"
                 end if
     end case

     update tmpcct set flgorigem    = ws.flgorigem_new,
                       socopgitmvlr = socopgitmvlr + param.socopgitmvlr,
                       socopgitmcst = socopgitmcst + param.socopgitmcst,
                       socopgitmcst = socopgitmcst + param.socopgitmcst,
                       qtdreserva   = qtdreserva   + 1              ,
                       c24utidiaqtd = c24utidiaqtd + param.c24utidiaqtd
                    where slcemp    = param.slcemp
                      and slcsuccod = param.slcsuccod
                      and slccctcod = param.slccctcod

  end if

end function # --- ctb02m17_gravatmp
