###############################################################################
# Nome do Modulo: cts00m30                                           Marcus   #
#                                                                    Ruiz     #
# Tela de Acompanhamento Servicos Internet                           Ago/2001 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Alterado caminho da global          #
###############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define d1_cts00m30  record
   servico         char(13),
   srvtipdes       like datksrvtip.srvtipdes
end record

define d_cts00m30 record
   caddat          like datmsrvint.caddat,
   cadhor          datetime hour to minute,
   funnom          like isskfunc.funnom    ,
   origem          char (50)               ,
   atldat          like datmsrvintcmp.atldat,
   atlhor          datetime hour to minute  ,
   funnom1         like isskfunc.funnom     ,
   origem1         char (50)                ,
   srvcmptxt1      like datmsrvintcmp.srvcmptxt,
   srvcmptxt2      like datmsrvintcmp.srvcmptxt,
   srvcmptxt3      like datmsrvintcmp.srvcmptxt,
   srvcmptxt4      like datmsrvintcmp.srvcmptxt
end record

define a_cts00m30  array[30] of record
   caddat          like datmsrvint.caddat  ,
   cadhor          datetime hour to minute ,
   funnom          like isskfunc.funnom    ,
   origem          char (50)               ,
   atldat          like datmsrvintcmp.atldat,
   atlhor          datetime hour to minute  ,
   funnom1         like isskfunc.funnom,
   origem1         char (50)                ,
   srvcmptxt1      like datmsrvintcmp.srvcmptxt,
   srvcmptxt2      like datmsrvintcmp.srvcmptxt,
   srvcmptxt3      like datmsrvintcmp.srvcmptxt,
   srvcmptxt4      like datmsrvintcmp.srvcmptxt
end record
define arr_aux     smallint
define scr_aux     smallint

#main
# call cts00m30(1001494,1)
#end main
#-----------------------------------------------------------
 function cts00m30(param)
#-----------------------------------------------------------

   define param  record
      atdsrvnum       like datmsrvint.atdsrvnum,
      atdsrvano       like datmsrvint.atdsrvano
   end record
   define ws    record
      atdsrvorg       like datmservico.atdsrvorg
   end record



	initialize  ws.*  to  null

   select atdsrvorg
      into ws.atdsrvorg
      from datmservico
     where atdsrvnum = param.atdsrvnum  and
           atdsrvano = param.atdsrvano

   let d1_cts00m30.servico = ws.atdsrvorg    using "&&", "/",
                            param.atdsrvnum using "&&&&&&&", "-",
                            param.atdsrvano using "&&"

   let d1_cts00m30.srvtipdes = "*** NAO CADASTRADO! ***"

   select srvtipdes
     into d1_cts00m30.srvtipdes
     from datksrvtip
    where atdsrvorg = ws.atdsrvorg

   open window cts00m30 at 04,02 with form "cts00m30"
               attribute(border,form line first)

   display by name d1_cts00m30.servico
   display by name d1_cts00m30.srvtipdes

   menu "COMPLEMENTOS."
     command key ("C") "Consulta" "Consulta complemento enviado"
         call cts00m30_consulta(param.*)

     command key ("V") "enVia" "Envia complemento do servico"
         call cts00m30_envia(param.*)

     command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
         exit menu
   end menu
   close window cts00m30
 end function

#-------------------------------[ consulta ]-------------------------------
 function cts00m30_consulta(param)
#--------------------------------------------------------------------------
     define param record
         atdsrvnum  like datmsrvint.atdsrvnum,
         atdsrvano  like datmsrvint.atdsrvano
     end record
     define ws    record
        sql         char (800),
        cadmat      like datmsrvint.cadmat,
        cademp      like datmsrvint.cademp,
        atlmat      like datmsrvintcmp.atlmat,
        atlemp      like datmsrvintcmp.atlemp,
        cadorg      like datmsrvint.cadorg,
        srvcmptxt   like datmsrvintcmp.srvcmptxt,
        dptsgl      like isskfunc.dptsgl,
        usrcod      like isskusuario.usrcod,
        funnom      like isskfunc.funnom,
        cadusrtip   like datmsrvintcmp.cadusrtip,
        atlusrtip   like datmsrvintcmp.atlusrtip,
        pstcoddig   like datmsrvintcmp.pstcoddig
     end record



	initialize  ws.*  to  null

     let ws.sql = "select caddat    ,",
                  "       cadhor    ,",
                  "       cadmat    ,",
                  "       cadorg    ,",
                  "       cademp    ,",
                  "       cadusrtip ,",
                  "       atlmat    ,",
                  "       atldat    ,",
                  "       atlhor    ,",
                  "       atlemp    ,",
                  "       atlusrtip ,",
                  "       srvcmptxt ,",
                  "       pstcoddig  ",
                  "  from datmsrvintcmp ",
                  " where atdsrvnum = ?",
                  "   and atdsrvano = ?"
     prepare sel_datmsrvintcmp from ws.sql
     declare c_datmsrvintcmp cursor for sel_datmsrvintcmp

     let ws.sql = "select funnom    ",
                  "  from isskfunc  ",
                  " where empcod = '1'",
                  "   and funmat = ?"
     prepare sel_isskfunc from ws.sql
     declare c_isskfunc cursor for sel_isskfunc

     initialize a_cts00m30     to null
     initialize ws.*           to null
     let int_flag = false
     let arr_aux  = 1

     open c_datmsrvintcmp using param.atdsrvnum,
                                param.atdsrvano

     foreach c_datmsrvintcmp into a_cts00m30[arr_aux].caddat,
                                  a_cts00m30[arr_aux].cadhor,
                                  ws.cadmat                 ,
                                  ws.cadorg                 ,
                                  ws.cademp                 ,
                                  ws.cadusrtip              ,
                                  ws.atlmat                 ,
                                  a_cts00m30[arr_aux].atldat,
                                  a_cts00m30[arr_aux].atlhor,
                                  ws.atlemp                 ,
                                  ws.atlusrtip              ,
                                  ws.srvcmptxt              ,
                                  ws.pstcoddig
        let a_cts00m30[arr_aux].srvcmptxt1 = ws.srvcmptxt[001,075]
        let a_cts00m30[arr_aux].srvcmptxt2 = ws.srvcmptxt[076,150]
        let a_cts00m30[arr_aux].srvcmptxt3 = ws.srvcmptxt[151,225]
        let a_cts00m30[arr_aux].srvcmptxt4 = ws.srvcmptxt[226,250]
        if ws.cademp = 0 then   # internet
           let ws.cademp = null
        end if
        call F_FUNGERAL_USR(ws.cadmat,
                            ws.cademp,
                            ws.cadusrtip,
                            "","")
              returning  ws.dptsgl,
                         ws.usrcod,
                         ws.funnom,
                         a_cts00m30[arr_aux].funnom
       #open  c_isskfunc using ws.cadmat
       #fetch c_isskfunc into a_cts00m30[arr_aux].funnom
       #close c_isskfunc

        let a_cts00m30[arr_aux].origem = "** NAO CADASTRADO **"
        select cpodes
           into  a_cts00m30[arr_aux].origem
           from  iddkdominio
          where  cponom = "orgsrvint"
            and  cpocod = ws.cadorg

        if ws.atlemp = 0 then   # internet
           let ws.atlemp = null
        end if
        call F_FUNGERAL_USR(ws.atlmat,
                            ws.atlemp,
                            ws.atlusrtip,
                            "","")
              returning  ws.dptsgl,
                         ws.usrcod,
                         ws.funnom,
                         a_cts00m30[arr_aux].funnom1
       #open  c_isskfunc using ws.atlmat
       #fetch c_isskfunc into a_cts00m30[arr_aux].funnom1
       #close c_isskfunc

        let arr_aux = arr_aux + 1
        if arr_aux > 30  then
           error " Limite excedido. Servico possui mais de 30 complementos!"
           exit foreach
        end if

     end foreach
     if arr_aux > 1  then
        call set_count(arr_aux-1)

        display array a_cts00m30 to s_cts00m30.*
              on key(interrupt, control-c)
                 exit display
        end display
     else
        error " Nao existem complementos para este servico!"
     end if
     let int_flag = false
    #close window cts00m30
 end function

 ------------------------------[ enviar ]----------------------------------
 function cts00m30_envia(param1)
 --------------------------------------------------------------------------

    define param1 record
        atdsrvnum   like datmsrvint.atdsrvnum,
        atdsrvano   like datmsrvint.atdsrvano
    end record
    define ws     record
        cadorg      like datmsrvint.cadorg,
        srvcmptxt   like datmsrvintcmp.srvcmptxt,
        pstcoddig   like datmsrvintcmp.pstcoddig,
        atdetpseq   like datmsrvint.atdetpseq
    end record



	initialize  ws.*  to  null

    initialize d_cts00m30.*   to null
    initialize a_cts00m30     to null

    let d_cts00m30.caddat = today
    let d_cts00m30.cadhor = current hour to second

    select funnom
       into d_cts00m30.funnom
       from isskfunc
      where empcod = g_issk.empcod
        and funmat = g_issk.funmat

    let ws.cadorg  =  0
    let d_cts00m30.origem = "** NAO CADASTRADO **"
    select cpodes
       into  d_cts00m30.origem
       from  iddkdominio
      where  cponom = "orgsrvint"
        and  cpocod = ws.cadorg

    select max(atdetpseq)
       into ws.atdetpseq
       from datmsrvint
    where atdsrvnum = param1.atdsrvnum and
       atdsrvano = param1.atdsrvano

    select pstcoddig
      into ws.pstcoddig
    from datmsrvint
   where atdsrvano = param1.atdsrvano and
         atdsrvnum = param1.atdsrvnum and
         atdetpseq = ws.atdetpseq

    display by name d_cts00m30.*

    input by name d_cts00m30.srvcmptxt1,
                  d_cts00m30.srvcmptxt2,
                  d_cts00m30.srvcmptxt3,
                  d_cts00m30.srvcmptxt4

       before field srvcmptxt1
          display  by name d_cts00m30.srvcmptxt1 attribute (reverse)

       after field srvcmptxt1
          display by name d_cts00m30.srvcmptxt1

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field srvcmptxt2
          end if
          next field srvcmptxt2

       before field srvcmptxt2
          display  by name d_cts00m30.srvcmptxt2 attribute (reverse)

       after field srvcmptxt2
          display by name d_cts00m30.srvcmptxt2

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field srvcmptxt3
          end if
          next field srvcmptxt3

       before field srvcmptxt3
          display  by name d_cts00m30.srvcmptxt3 attribute (reverse)

       after field srvcmptxt3
          display by name d_cts00m30.srvcmptxt3

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field srvcmptxt4
          end if
          next field srvcmptxt4

       before field srvcmptxt4
          display  by name d_cts00m30.srvcmptxt4 attribute (reverse)

       after field srvcmptxt4
          display by name d_cts00m30.srvcmptxt4

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field srvcmptxt4
          end if
          exit input

      on key (interrupt)
         exit input

   end input
   if not int_flag then
      if d_cts00m30.srvcmptxt1 is not null or
         d_cts00m30.srvcmptxt2 is not null or
         d_cts00m30.srvcmptxt3 is not null or
         d_cts00m30.srvcmptxt4 is not null then
         let ws.srvcmptxt[001,075] = d_cts00m30.srvcmptxt1
         let ws.srvcmptxt[076,150] = d_cts00m30.srvcmptxt2
         let ws.srvcmptxt[151,225] = d_cts00m30.srvcmptxt3
         let ws.srvcmptxt[226,250] = d_cts00m30.srvcmptxt4
         begin work
         insert into datmsrvintcmp
               (atdsrvnum,
                atdsrvano,
                caddat   ,
                cadhor   ,
                cadorg   ,
                cadmat   ,
                cademp   ,
                cadusrtip,
                atlemp   ,
                atlusrtip,
                atlmat   ,
                atldat   ,
                atlhor   ,
                srvcmptxt,
                pstcoddig)
             values
               (param1.atdsrvnum,
                param1.atdsrvano,
                today           ,
                d_cts00m30.cadhor,
                ws.cadorg       ,
                g_issk.funmat   ,
                g_issk.empcod   ,
                g_issk.usrtip   ,
                "","","","",""  ,
                ws.srvcmptxt    ,
                ws.pstcoddig)
         if sqlca.sqlcode <> 0 then
            error " Erro (", sqlca.sqlcode, ") na inclusao do envio do",
                  " complemento. AVISE A INFORMATICA!"
            rollback work
         else
            error "Inclusao Efetuada"
            commit work
         end if
      end if
   end if
   display by name d_cts00m30.*

   let int_flag = false

 end function  ###  cts00m30

