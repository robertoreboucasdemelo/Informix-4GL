###############################################################################
# Nome do Modulo: cte02m00                                           Ruiz     #
#                                                                    Akio     #
# Acompanhamento de pendencias                                       Mai/2000 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 13/09/2000  PSI 11546-0  Raji         Indice de localizacao por SUSEP.      #
#-----------------------------------------------------------------------------#
# 02/04/2001  PSI 12801-5  Wagner       Acesso iddkdominio 'c24pndsitcod'     #
#-----------------------------------------------------------------------------#
# 01/03/2002  CORREIO      Wagner       Incluir dptsgl psocor nas pesquisas.  #
##################################################################################
#                                                                                #
#                       * * * Alteracoes * * *                                   #
#                                                                                #
# Data        Autor Fabrica  Origem        Alteracao                             #
# ----------  -------------- ---------     --------------------------------------#
# 28/01/2004  ivone meta     PSI172308     Acrescentar valores nulos na chamada  #
#                            OSF31216      da funcao cte02m01                    #
#--------------------------------------------------------------------------------#
# 10/09/2005 T. Solda,Meta   PSIMelhorias  Chamada da funcao "fun_dba_abre_banco"#
#                                          e troca da "systables" por "dual"     #
#--------------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glcte.4gl'
{
 main
  let g_issk.empcod =  1
  let g_issk.funmat = 61566
  call cte02m00()
 end main
}
#--------------------------------------------------------------------
 function cte02m00()
#--------------------------------------------------------------------

 define d_cte02m00   record
    pnddat           like dacmatdpndsit.caddat    ,
    pndsitcod        like dacmatdpndsit.c24pndsitcod,
    pndsitdsc        char (15)                    ,
    pndasscod        like dackass.corasscod       ,
    lignum           like dacmatdpndsit.corlignum ,
    ligano           like dacmatdpndsit.corligano ,
    corsus           like dacrligsus.corsus       ,
    totqtd           char (12)                    ,
    agora            datetime hour to second
 end record

 define ws           record
    errflg           smallint                     ,
    totqtd           smallint                     ,
    pndfnldat        like dacmatdpndsit.caddat    ,
    pndfnlhor        like dacmatdpndsit.cadhor    ,
    pndrlzhor        char (08)                    ,
    pndsitcod        like dacmatdpndsit.c24pndsitcod,
    c24astcod        like dackass.corasscod       ,
    c24rclsitcod     like dacmatdpndsit.c24pndsitcod,
    corassdes        like dackass.corassdes       ,
    seq              smallint                     ,
    prpnumpcp        like dacrligorc.prpnumpcp
 end record

 define a_cte02m00   array[1000] of record
    corlignum        like dacmatdpndsit.corlignum ,
    corligano        like dacmatdpndsit.corligano ,
    caddat           like dacmatdpndsit.caddat    ,
    cadhor           char (05)                    ,
    dddcod           like dacmpndret.dddcod       ,
    ctttel           like dacmpndret.ctttel       ,
    pndretcttnom     like dacmpndret.pndretcttnom ,
    corligitmseq     like dacmatdpndsit.corligitmseq,
    corasscod        like dacmligass.corasscod    ,
    corassdes        like dackass.corassdes       ,
    c24pndsitcod     like dacmatdpndsit.c24pndsitcod,
    pndsitdes        char (15)                    ,
    pndtmp           interval hour(04) to minute
 end record

 define a1_cte02m00  array[1000] of record
    corligitmseq     like dacmatdpndsit.corligitmseq
 end record

 define arr_aux      smallint
 define scr_aux      smallint
 define l_acesso     smallint

 define sql_comando  char (900)

 define l_param      char (001)                              #psi172308 ivone


#--------------------------------------------------------------------
# Cursor para obtencao da ultima situacao da pendencia
#--------------------------------------------------------------------
 let sql_comando = "select c24pndsitcod  ,",
                #  "       corligitmseq  ,",
                   "       caddat        ,",
                   "       cadhor         ",
                   "  from dacmatdpndsit  ",
                   " where corlignum = ?  ",
                   "   and corligano = ?  ",
                   "   and corligitmseq = ?  ", #HPN
                   "   and c24pndsitcod = (select max(c24pndsitcod)",
                                          "  from dacmatdpndsit",
                                          " where corlignum = ?",
                                          "   and corligano = ?",
                                          "   and corligitmseq = ?)" #HPN

 prepare select_sitrecl from sql_comando
 declare c_cte02m00_sitrecl cursor with hold for select_sitrecl

#--------------------------------------------------------------------
# Cursor para obtencao dos dados adicionais da pendencia
#--------------------------------------------------------------------
 let sql_comando = "select dacmlig.ligdat             , ",
                   "       dacmlig.lighorinc          , ",
                   "       dacmpndret.dddcod          , ",
                   "       dacmpndret.ctttel          , ",
                   "       dacmpndret.pndretcttnom    , ",
                   "       dacmligass.corasscod         ",
                   "  from dacmlig,dacmpndret,dacmligass",
                   " where dacmligass.corlignum    = ?  ",
                   "   and dacmligass.corligano    = ?  ",
                   "   and dacmligass.corligitmseq = ?  ",
                   "   and dacmpndret.corlignum = dacmligass.corlignum",
                   "   and dacmpndret.corligano = dacmligass.corligano",
                   "   and dacmlig.corlignum    = dacmligass.corlignum",
                   "   and dacmlig.corligano    = dacmligass.corligano"

 prepare select_ligrecl from sql_comando
 declare c_cte02m00_ligrecl cursor with hold for select_ligrecl

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do assunto da pendencia
#--------------------------------------------------------------------
 let sql_comando = "select corassdes from dackass",
                   " where corasscod = ? "

 prepare select_assunto from sql_comando
 declare c_cte02m00_assunto cursor with hold for select_assunto

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do codigo de situacao
#--------------------------------------------------------------------
 let sql_comando = "select cpodes from iddkdominio",
                   " where cponom = 'c24pndsitcod'",
                   "   and cpocod = ?"

 prepare select_dominio from sql_comando
 declare c_cte02m00_dominio cursor with hold for select_dominio


#--------------------------------------------------------------------
# Cursor para obtencao do numero do orcamento
#--------------------------------------------------------------------
 let sql_comando = "select prpnumpcp from dacrligorc",
                   " where corlignum = ?  ",
                   "   and corligano = ?  ",
                   "   and corligitmseq = ?  "
 prepare select_dacrligorc from sql_comando
 declare c_cte02m00_dacrligorc cursor with hold for select_dacrligorc


 open window w_cte02m00 at 06,02 with form "cte02m00"
             attribute(form line 1)

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
 initialize a_cte02m00    to null
 initialize ws.*          to null
 initialize d_cte02m00    to null 

 let d_cte02m00.pndsitcod = 0

 open  c_cte02m00_dominio  using  d_cte02m00.pndsitcod
 fetch c_cte02m00_dominio  into   d_cte02m00.pndsitdsc
 close c_cte02m00_dominio

 if weekday(today) = 1  then
    let d_cte02m00.pnddat = today - 3 units day
 else
    let d_cte02m00.pnddat = today - 1 units day
 end if

 while true
    let d_cte02m00.ligano    = year(today)
    let int_flag             = false
    let d_cte02m00.agora     = current
    let d_cte02m00.totqtd    = null

    clear form
    display by name d_cte02m00.*

    input by name d_cte02m00.pnddat   ,
                  d_cte02m00.pndsitcod,
                  d_cte02m00.pndasscod,
                  d_cte02m00.lignum   ,
                  d_cte02m00.ligano   ,
                  d_cte02m00.corsus  without defaults

       before field pnddat
          display by name d_cte02m00.pnddat  attribute (reverse)

       after  field pnddat
          if fgl_lastkey() = fgl_keyval("down")  then
             display by name d_cte02m00.pnddat
             next field lignum
          end if

          if d_cte02m00.pnddat is null  then
             let d_cte02m00.pnddat = today
          end if

          if d_cte02m00.pnddat < today - 90 units day  then
             error " Nao deve ser informada data anterior a 90 dias!"
             next field pnddat
          end if

          display by name d_cte02m00.pnddat

       before field pndsitcod
          display by name d_cte02m00.pndsitcod  attribute (reverse)

       after  field pndsitcod
          display by name d_cte02m00.pndsitcod

          if fgl_lastkey() = fgl_keyval("down")  then
             next field corsus
          else
             if d_cte02m00.pndsitcod is null  or
                d_cte02m00.pndsitcod =  " "   then
                let d_cte02m00.pndsitdsc = "TODOS"
             else
                open  c_cte02m00_dominio  using  d_cte02m00.pndsitcod
                fetch c_cte02m00_dominio  into   d_cte02m00.pndsitdsc
                if sqlca.sqlcode = notfound  then
                   error " Situacao invalida!"
                   call cta05m01() returning d_cte02m00.pndsitcod
                   next field pndsitcod
                end if
                close c_cte02m00_dominio
             end if
          end if

          display by name d_cte02m00.pndsitdsc

       before field pndasscod
          display by name d_cte02m00.pndasscod  attribute (reverse)

       after  field pndasscod
          display by name d_cte02m00.pndasscod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field pndsitcod
          end if

          if d_cte02m00.pndasscod is not null  then
             open  c_cte02m00_assunto  using  d_cte02m00.pndasscod
             fetch c_cte02m00_assunto
             if sqlca.sqlcode = notfound  then
                error " Codigo de assunto invalido!"
                call cto00m04("","cte02m00")
                     returning d_cte02m00.pndasscod, # pop_up
                               ws.corassdes          # assuntos
                next field pndasscod
             end if
             close c_cte02m00_assunto
         #else
         #   call cto00m04("","") returning d_cte02m00.pndasscod, # pop_up
         #                                  ws.corassdes          # assuntos
         #   next field pndasscod
          end if

          exit input

       before field lignum
          display by name d_cte02m00.lignum  attribute (reverse)

       after  field lignum
          display by name d_cte02m00.lignum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field pnddat
          else
             if d_cte02m00.lignum is null  then
                error " Numero da pendencia  deve ser informado!"
                next field lignum
             else
                next field ligano
             end if
          end if

       before field ligano
          display by name d_cte02m00.ligano  attribute (reverse)

       after  field ligano
          display by name d_cte02m00.ligano

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field lignum
          else
             exit input
          end if

       before field corsus
          display by name d_cte02m00.corsus  attribute (reverse)

       after  field corsus
          display by name d_cte02m00.corsus

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field pnddat
          else
             if d_cte02m00.corsus is null  then
                error " Numero SUSEP deve ser informado!"
                next field corsus
             end if
          end if

       on key (interrupt)
          let int_flag = true
          exit input

    end input

    if int_flag = true  then
       let arr_aux = 1
       initialize a_cte02m00[arr_aux].* to null
       exit while
    end if

    while TRUE

      message " Aguarde, pesquisando..."  attribute(reverse)

      let ws.totqtd = 0
      let arr_aux   = 1

      if d_cte02m00.lignum is not null  then
         let sql_comando  = "select corlignum,             ",
                            "       corligano,             ",
                            "       corligitmseq           ",
                            " from dacmatdpndsit           ",
                            " where corlignum = ?          ",
                            "   and corligano = ?          ",
                            "   and c24pndsitcod = 0       ",
                            " group by corlignum,corligano,corligitmseq ",
                            " order by corlignum           "
      else
         if d_cte02m00.corsus is not null then
            let sql_comando  = "select b.corlignum,                 ",
                               "       b.corligano,                 ",
                               "       b.corligitmseq               ",
                               "  from dacrligsus a, dacmatdpndsit b",
                               " where corsus   =  ?    and         ",
                               "       a.corlignum = b.corlignum and",
                               "       a.corligano = b.corligano and",
                               "       b.caddat    >= ? and         ",
                               "       b.c24pndsitcod = 0           ",
                               " group by b.corlignum,b.corligano,b.corligitmseq",
                               " order by b.corlignum               "
         else
            let sql_comando  = "select corlignum,             ",
                               "       corligano,             ",
                               "       corligitmseq           ",
                               "  from dacmatdpndsit          ",
                               " where caddat    >= ?    and  ",
                               "       c24pndsitcod = 0       ",
                               " group by corlignum,corligano,corligitmseq ",
                               " order by corlignum           "
         end if
      end if
      prepare select_main  from sql_comando
      declare c_cte02m00 cursor with hold for select_main

      if d_cte02m00.lignum is not null  then
         open c_cte02m00  using  d_cte02m00.lignum,
                                 d_cte02m00.ligano
      else
         if d_cte02m00.corsus is not null then
            open c_cte02m00  using  d_cte02m00.corsus,
                                    d_cte02m00.pnddat
         else
            open c_cte02m00  using  d_cte02m00.pnddat
         end if
      end if

      foreach c_cte02m00  into   a_cte02m00[arr_aux].corlignum,
                                 a_cte02m00[arr_aux].corligano,
                                 a_cte02m00[arr_aux].corligitmseq
         open  c_cte02m00_sitrecl  using  a_cte02m00[arr_aux].corlignum,
                                          a_cte02m00[arr_aux].corligano,
                                          a_cte02m00[arr_aux].corligitmseq, #HPN
                                          a_cte02m00[arr_aux].corlignum,
                                          a_cte02m00[arr_aux].corligano,
                                          a_cte02m00[arr_aux].corligitmseq  #HPN
         fetch c_cte02m00_sitrecl  into   a_cte02m00[arr_aux].c24pndsitcod,
                                         #a_cte02m00[arr_aux].corligitmseq,
                                          ws.pndfnldat,ws.pndfnlhor
         close c_cte02m00_sitrecl

         if d_cte02m00.lignum  is null   then
            if d_cte02m00.pndsitcod is not null and
               a_cte02m00[arr_aux].c24pndsitcod <> d_cte02m00.pndsitcod  then
               initialize a_cte02m00[arr_aux].*  to null
               continue foreach
            end if
         end if

         open  c_cte02m00_ligrecl  using  a_cte02m00[arr_aux].corlignum,
                                          a_cte02m00[arr_aux].corligano,
                                          a_cte02m00[arr_aux].corligitmseq
         fetch c_cte02m00_ligrecl  into   a_cte02m00[arr_aux].caddat   ,
                                          ws.pndrlzhor                 ,
                                          a_cte02m00[arr_aux].dddcod   ,
                                          a_cte02m00[arr_aux].ctttel   ,
                                          a_cte02m00[arr_aux].pndretcttnom   ,
                                          a_cte02m00[arr_aux].corasscod
         close c_cte02m00_ligrecl
         if d_cte02m00.lignum is null  then
            if d_cte02m00.pndasscod is not null  then
               if a_cte02m00[arr_aux].corasscod <> d_cte02m00.pndasscod  then
                  initialize a_cte02m00[arr_aux].*  to null
                  continue foreach
               end if
            end if
         end if

         let a_cte02m00[arr_aux].cadhor    = ws.pndrlzhor[1,5]

         open  c_cte02m00_assunto  using  a_cte02m00[arr_aux].corasscod
         fetch c_cte02m00_assunto  into   a_cte02m00[arr_aux].corassdes
         close c_cte02m00_assunto

         open  c_cte02m00_dominio  using  a_cte02m00[arr_aux].c24pndsitcod
         fetch c_cte02m00_dominio  into   a_cte02m00[arr_aux].pndsitdes
         close c_cte02m00_dominio

         if a_cte02m00[arr_aux].corasscod <  5  or
            a_cte02m00[arr_aux].corasscod = 34  or
            a_cte02m00[arr_aux].corasscod = 36  or      # Os codigos 314 a 336
           (a_cte02m00[arr_aux].corasscod >= 314 and    # estao associados ao
            a_cte02m00[arr_aux].corasscod <= 336) then  # codigo 4
            open c_cte02m00_dacrligorc using a_cte02m00[arr_aux].corlignum,
                                             a_cte02m00[arr_aux].corligano,
                                             a_cte02m00[arr_aux].corligitmseq
            fetch c_cte02m00_dacrligorc into ws.prpnumpcp
            if ws.prpnumpcp is not null then
               let a_cte02m00[arr_aux].pndretcttnom = "         15/",
                                       ws.prpnumpcp using "&&&&&&&&"
            end if
         end if

         if a_cte02m00[arr_aux].c24pndsitcod >= 2  then
            call cte02m00_espera(a_cte02m00[arr_aux].caddat,
                                 a_cte02m00[arr_aux].cadhor,
                                 ws.pndfnldat, ws.pndrlzhor)
                       returning a_cte02m00[arr_aux].pndtmp
         else
            call cte02m00_espera(a_cte02m00[arr_aux].caddat   ,
                                 a_cte02m00[arr_aux].cadhor   ,"","")
                       returning a_cte02m00[arr_aux].pndtmp
         end if

         let ws.totqtd = ws.totqtd + 1

         let arr_aux = arr_aux + 1
         if arr_aux  >  1000   then
            error " Limite excedido. Foram encontradas mais de 1000 pendencias!"
            exit foreach
         end if

      end foreach

      let d_cte02m00.totqtd =  ws.totqtd using "&&&"
      display by name d_cte02m00.totqtd  attribute(reverse)

      if arr_aux = 1  then
         message ""
         error " Nao existem pendencias para a pesquisa!"
         let int_flag = true
         exit while
      else
         call set_count(arr_aux-1)

         message " (F17)Abandona, (F6)Atualiza tela, (F8)Seleciona"

         options insert  key  F35,
                 delete  key  F36,
                 comment line 08

         let ws.errflg = false

         input array a_cte02m00 without defaults from s_cte02m00.*
            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()

               display a_cte02m00[arr_aux].corlignum     to
                       s_cte02m00[scr_aux].corlignum     attribute(reverse)

               display a_cte02m00[arr_aux].corligano     to
                       s_cte02m00[scr_aux].corligano     attribute(reverse)

#              display a_cte02m00[arr_aux].corligitmseq  to
#                      s_cte02m00[scr_aux].corligitmseq  attribute(reverse)

               display a_cte02m00[arr_aux].corasscod  to
                       s_cte02m00[scr_aux].corasscod  attribute(reverse)

               display a_cte02m00[arr_aux].corassdes  to
                       s_cte02m00[scr_aux].corassdes  attribute(reverse)

               display a_cte02m00[arr_aux].c24pndsitcod  to
                       s_cte02m00[scr_aux].c24pndsitcod  attribute(reverse)

               display a_cte02m00[arr_aux].pndsitdes  to
                       s_cte02m00[scr_aux].pndsitdes  attribute(reverse)

            before field corasscod
               if a_cte02m00[arr_aux].corasscod    is null  and
                  a_cte02m00[arr_aux].c24pndsitcod is null  then
                  let int_flag = false
                  exit input
               end if

               call cta00m06_acionamento(g_issk.dptsgl)
               returning l_acesso 
               
               # Alteração acesso ao acionamento
               if l_acesso = false then 
                  display a_cte02m00[arr_aux].corasscod to
                          s_cte02m00[scr_aux].corasscod
                  next field c24pndsitcod
               else 
                 if ws.errflg = false  then
                     let ws.c24astcod = a_cte02m00[arr_aux].corasscod
                  else
                     let ws.errflg = false
                  end if

                  display a_cte02m00[arr_aux].corasscod to
                          s_cte02m00[scr_aux].corasscod attribute (reverse)               
               end if    
               
               
               
               {if g_issk.dptsgl <> "ct24hs"  and
                  g_issk.dptsgl <> "psocor"  and
                  g_issk.dptsgl <> "dsvatd"  and
                  g_issk.dptsgl <> "desenv"  then
                  display a_cte02m00[arr_aux].corasscod to
                          s_cte02m00[scr_aux].corasscod
                  next field c24pndsitcod
               else
                  if ws.errflg = false  then
                     let ws.c24astcod = a_cte02m00[arr_aux].corasscod
                  else
                     let ws.errflg = false
                  end if

                  display a_cte02m00[arr_aux].corasscod to
                          s_cte02m00[scr_aux].corasscod attribute (reverse)
               end if}

            after  field corasscod
               display a_cte02m00[arr_aux].corasscod to
                       s_cte02m00[scr_aux].corasscod attribute(reverse)

               if fgl_lastkey() = fgl_keyval("down")  then
                  if a_cte02m00[arr_aux + 1].corasscod is null  then
                     error " Nao ha' mais pendencias  nesta direcao!"
                     next field corasscod
                  end if
               end if

               if a_cte02m00[arr_aux].corasscod is null  or
                  a_cte02m00[arr_aux].corasscod =  "  "  then
                  error " Codigo da pendencia  e' item obrigatorio!"
                  let ws.errflg = true
                 call cto00m04("","cte02m00")
                      returning a_cte02m00[arr_aux].corasscod,
                                a_cte02m00[arr_aux].corassdes
                  next field corasscod
               end if

               if a_cte02m00[arr_aux].corasscod <> ws.c24astcod  and
                  a_cte02m00[arr_aux].c24pndsitcod >= 2          then
                  error " Pendencia  ja' solucionada nao pode ser alterada!"
                  let a_cte02m00[arr_aux].corasscod = ws.c24astcod
                  next field corasscod
               end if

               open  c_cte02m00_assunto  using  a_cte02m00[arr_aux].corasscod
               fetch c_cte02m00_assunto  into   a_cte02m00[arr_aux].corassdes
               if sqlca.sqlcode = notfound  then
                  error " Codigo da Pendencia invalido!"
                  let ws.errflg = true
                  call cto00m04("","cte02m00")
                       returning a_cte02m00[arr_aux].corasscod,
                                 a_cte02m00[arr_aux].corassdes
                  next field corasscod
               else
                 display a_cte02m00[arr_aux].corassdes to
                         s_cte02m00[scr_aux].corassdes attribute(reverse)
               end if
               close c_cte02m00_assunto

            before field c24pndsitcod
               if ws.errflg = false  then
                  let ws.c24rclsitcod = a_cte02m00[arr_aux].c24pndsitcod
               else
                  let ws.errflg = false
               end if

               display a_cte02m00[arr_aux].c24pndsitcod to
                       s_cte02m00[scr_aux].c24pndsitcod attribute (reverse)

            after  field c24pndsitcod
               display a_cte02m00[arr_aux].c24pndsitcod to
                       s_cte02m00[scr_aux].c24pndsitcod attribute(reverse)

               if a_cte02m00[arr_aux].c24pndsitcod is null  then
                  error " Codigo da situacao da pendencia e' item obrigatorio!"
                  let ws.errflg = true
                  call cta05m01() returning a_cte02m00[arr_aux].c24pndsitcod
                  next field c24pndsitcod
               end if

               if fgl_lastkey() = fgl_keyval("down")  then
                  if a_cte02m00[arr_aux + 1].c24pndsitcod is null  then
                     error " Nao ha' mais pendencias nesta direcao!"
                     next field c24pndsitcod
                  end if
               end if

               if ws.c24rclsitcod <> a_cte02m00[arr_aux].c24pndsitcod  then
                  open  c_cte02m00_dominio  using  a_cte02m00[arr_aux].c24pndsitcod
                  fetch c_cte02m00_dominio  into   a_cte02m00[arr_aux].pndsitdes
                  if sqlca.sqlcode = notfound  then
                     error " Situacao invalida!"
                     let a_cte02m00[arr_aux].c24pndsitcod = ws.c24rclsitcod
                     next field c24pndsitcod
                  end if
                  close c_cte02m00_dominio

                  if ws.c24rclsitcod >= 2  then
                     error " Pendencia concluida nao pode ser alterada!"
                     let a_cte02m00[arr_aux].c24pndsitcod = ws.c24rclsitcod
                     next field c24pndsitcod
                  end if

                  if a_cte02m00[arr_aux].c24pndsitcod < ws.c24rclsitcod  then
                     error " Situacao informada nao pode ser inferior a situacao atual!"
                     let a_cte02m00[arr_aux].c24pndsitcod = ws.c24rclsitcod
                     next field c24pndsitcod
                  end if

                  if ws.c24rclsitcod = 0                   and
                     a_cte02m00[arr_aux].c24pndsitcod > 1  then
                     error " Situacao informada nao confere com codigo da proxima etapa!"
                     let a_cte02m00[arr_aux].c24pndsitcod = ws.c24rclsitcod
                     next field c24pndsitcod
                  end if

                  if ws.c24rclsitcod = 1                   and
                     a_cte02m00[arr_aux].c24pndsitcod < 1  then
                     error " Situacao informada nao confere com codigo da proxima etapa!"
                     let a_cte02m00[arr_aux].c24pndsitcod = ws.c24rclsitcod
                     next field c24pndsitcod
                  end if

                  display a_cte02m00[arr_aux].pndsitdes to
                          s_cte02m00[scr_aux].pndsitdes attribute(reverse)
               end if

            after row
               if ws.c24astcod <> a_cte02m00[arr_aux].corasscod  then
                  update dacmligass
                     set corasscod = a_cte02m00[arr_aux].corasscod
                   where corlignum    = a_cte02m00[arr_aux].corlignum
                     and corligano    = a_cte02m00[arr_aux].corligano
                     and corligitmseq = a_cte02m00[arr_aux].corligitmseq
               end if

               if ws.c24rclsitcod <> a_cte02m00[arr_aux].c24pndsitcod  then
#                 select max(corligitmseq)
#                        into ws.seq
#                        from dacmatdpndsit
#                        where corlignum = a_cte02m00[arr_aux].corlignum
#                          and corligano = a_cte02m00[arr_aux].corligano
#                 if status = notfound  then
#                    let ws.seq = 0
#                 end if
#                 let ws.seq = ws.seq + 1

                  select *
                         from dacmatdpndsit
                         where corlignum = a_cte02m00[arr_aux].corlignum
                           and corligano = a_cte02m00[arr_aux].corligano
                           and corligitmseq = a_cte02m00[arr_aux].corligitmseq
                           and c24pndsitcod = a_cte02m00[arr_aux].c24pndsitcod
                  if status = notfound  then
                     insert into dacmatdpndsit (corlignum   ,
                                                corligano   ,
                                                corligitmseq,
                                                c24pndsitcod,
                                                cadmat,
                                                caddat      ,
                                                cadhor,
                                                cademp)
                                      values (a_cte02m00[arr_aux].corlignum,
                                              a_cte02m00[arr_aux].corligano,
   #                                          ws.seq                       ,
                                              a_cte02m00[arr_aux].corligitmseq,
                                              a_cte02m00[arr_aux].c24pndsitcod,
                                              g_issk.funmat, today, current,
                                              g_issk.empcod )
                  end if
               end if

               initialize ws.c24astcod    to null
               initialize ws.c24rclsitcod to null

               display a_cte02m00[arr_aux].corlignum     to
                       s_cte02m00[scr_aux].corlignum

               display a_cte02m00[arr_aux].corligano     to
                       s_cte02m00[scr_aux].corligano

               display a_cte02m00[arr_aux].corasscod  to
                       s_cte02m00[scr_aux].corasscod

               display a_cte02m00[arr_aux].corassdes  to
                       s_cte02m00[scr_aux].corassdes

               display a_cte02m00[arr_aux].c24pndsitcod  to
                       s_cte02m00[scr_aux].c24pndsitcod

               display a_cte02m00[arr_aux].pndsitdes  to
                       s_cte02m00[scr_aux].pndsitdes

            on key (interrupt)
               let int_flag = true
               initialize a_cte02m00 to null
               let arr_aux = arr_curr()
               exit input

            on key (F6)
               let d_cte02m00.agora  =  current
               display by name d_cte02m00.agora  attribute(reverse)
               let int_flag = false
               exit input

            on key (F8)
               if a_cte02m00[arr_aux].corlignum  is not null   then
                  let arr_aux = arr_curr()
                  let scr_aux = scr_line()

                  options comment line last
                  let l_param = null
                  call cte02m01(a_cte02m00[arr_aux].corlignum,
                                a_cte02m00[arr_aux].corligano,
                                a_cte02m00[arr_aux].corligitmseq,
                                l_param,l_param,l_param,l_param,l_param,l_param)      #psi172308 ivone
                  options comment line 08

                  display a_cte02m00[arr_aux].*  to
                          s_cte02m00[scr_aux].*
               else
                  error " Pendencia nao selecionada!"
               end if

         end input

         options comment line last
      end if

      if int_flag = true  then
         exit while
      end if

    end while

 end while

 let int_flag = false
 close window w_cte02m00

end function  ##-- cte02m00


#-----------------------------------------------------------
 function cte02m00_espera(param)
#-----------------------------------------------------------

 define param        record
    rclrlzdat        like datmsitrecl.rclrlzdat,
    pndrlzhor        char (05),
    rclfnldat        like datmsitrecl.rclrlzdat,
    rclfnlhor        char (08)
 end record

 define ws           record
    incdat           date,
    fnldat           date,
    resdat           integer,
    time             char (05),
    chrhor           char (07),
    inchor           interval hour(05) to minute,
    fnlhor           interval hour(05) to minute,
    reshor           interval hour(06) to minute
 end record

 let ws.incdat = param.rclrlzdat
 if param.rclfnldat is null  or
    param.rclfnldat < param.rclrlzdat  then
    let ws.fnldat = today
 else
    let ws.fnldat = param.rclfnldat
 end if

 let ws.inchor = param.pndrlzhor
 if param.rclfnlhor is null  then
    let ws.time = time
 else
    let ws.time = param.rclfnlhor[1,5]
 end if

 let ws.fnlhor = ws.time

 let ws.resdat = (ws.fnldat - ws.incdat) * 24
 let ws.reshor = (ws.fnlhor - ws.inchor)

 let ws.chrhor = ws.resdat using "###&" , ":00"
 let ws.reshor = ws.reshor + ws.chrhor

 return ws.reshor

end function  ###  cte02m00_espera
