###############################################################################
# Nome do Modulo: CTB05m01                                           Wagner   #
#                                                                             #
# Consulta ordem de pagamento por datas (pagto/entrega) e prestador  Mar/2002 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 18/07/06   Junior, Meta  AS112372      Migracao de versao do 4gl.           # 
#-----------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel    #
#-----------------------------------------------------------------------------# 

 database porto

#-----------------------------------------------------------
 function ctb05m01()
#-----------------------------------------------------------

 define d_ctb05m01  record
    tipdat          dec(1,0),
    tipdatdes       char(07),
    incdat          date,
    fnldat          date,
    pstcoddig       like dbsmopg.pstcoddig,
    nomgrr          like dpaksocor.nomgrr,
    total           char(12)
 end record

 define a_ctb05m01 array[2500] of record
    socopgnum       like dbsmopg.socopgnum,
    socfatentdat    like dbsmopg.socfatentdat,
    socfatpgtdat    like dbsmopg.socfatpgtdat,
    socopgfavnom    like dbsmopgfav.socopgfavnom,
    socopgorgdes    char(10),
    socopgfasdes    char(22),
    socopgsitdes    char(40)
 end record

 define ws          record
    seleciona       char(350),
    condicao        char(250),
    socopgsitcod    like dbsmopg.socopgsitcod,
    socopgorgcod    like dbsmopg.socopgorgcod,
    socopgfascod    like dbsmopgfas.socopgfascod,
    pstcoddig       like dbsmopg.pstcoddig,
    segnumdig       like dbsmopg.segnumdig,
    corsus          like dbsmopg.corsus,
    cponom          like iddkdominio.cponom,
    retorno         smallint,
    mensagem        char(60)
 end record

 define arr_aux     smallint
 define scr_aux     smallint


 initialize d_ctb05m01.*    to null
 initialize ws.*            to null

 let ws.seleciona  = "select cpodes     ",
                 "  from iddkdominio",
                 " where cponom  = ? ",
                 "   and cpocod  = ? "
 prepare comando_aux2  from  ws.seleciona 
 declare c_ctb05m01idd  cursor for  comando_aux2

 let ws.seleciona  = "select nomgrr    ",
                 "  from dpaksocor ",
                 " where pstcoddig = ?"
 prepare comando_aux4  from  ws.seleciona 
 declare c_ctb05m01prs  cursor for  comando_aux4

 let ws.seleciona  = "select segnom    ",
                 "  from gsakseg   ",
                 " where segnumdig = ?"
 prepare comando_aux5  from  ws.seleciona 
 declare c_ctb05m01seg  cursor for  comando_aux5

#let ws.seleciona  = "select cornom    ",
#                "  from gcaksusep, gcakcorr",
#                " where gcaksusep.corsus   = ?",
#                "   and gcakcorr.corsuspcp = gcaksusep.corsuspcp"
#prepare comando_aux6  from  ws.seleciona 
#declare c_ctb05m01cor  cursor for  comando_aux6

 open window ctb05m01 at 06,02 with form "ctb05m01"
             attribute (form line first)

 while true

   let int_flag = false
   initialize a_ctb05m01    to null
   initialize d_ctb05m01.*  to null
   let arr_aux  = 1

   display by name d_ctb05m01.*

   input by name d_ctb05m01.tipdat,
                 d_ctb05m01.incdat,
                 d_ctb05m01.fnldat,
                 d_ctb05m01.pstcoddig  without defaults

      before field tipdat
         display by name d_ctb05m01.tipdat    attribute (reverse)

      after  field tipdat
         display by name d_ctb05m01.tipdat

         if d_ctb05m01.tipdat   is null   then
            error " Tipo deve ser: 1-Entrega, 2-Pagamento"
            next field tipdat
         end if

         case  d_ctb05m01.tipdat
               when  1   let d_ctb05m01.tipdatdes = "ENTREGA"
               when  2   let d_ctb05m01.tipdatdes = "PAGTO"
               otherwise error " Tipo deve ser: 1-Entrega, 2-Pagamento"
                         next field tipdat
         end case
         display by name d_ctb05m01.tipdatdes

      before field incdat
         display by name d_ctb05m01.incdat    attribute (reverse)

      after  field incdat
         display by name d_ctb05m01.incdat

         if d_ctb05m01.incdat is null   then
            let d_ctb05m01.incdat = today
            display by name d_ctb05m01.incdat
         end if

         if d_ctb05m01.incdat  <  "01/06/1997"  then
            error " Consulta disponivel a partir de 01/06/1997!"
            next field incdat
         end if

      before field fnldat
         display by name d_ctb05m01.fnldat      attribute (reverse)

      after  field fnldat
         display by name d_ctb05m01.fnldat

         if d_ctb05m01.fnldat is null  then
            let d_ctb05m01.fnldat = d_ctb05m01.incdat
            display by name d_ctb05m01.fnldat
         end if

         if d_ctb05m01.fnldat < d_ctb05m01.incdat  then
            error " Data de pagamento final nao deve ser menor que data pagamento inicial!"
            next field fnldat
         end if

         if d_ctb05m01.fnldat > d_ctb05m01.incdat + 30 units day  then
            error " Periodo para pesquisa esta' limitado a 30 dias!"
            next field fnldat
         end if

      before field pstcoddig
         display by name d_ctb05m01.pstcoddig attribute (reverse)

      after  field pstcoddig
         display by name d_ctb05m01.pstcoddig

         if fgl_lastkey() = fgl_keyval("left")   or
            fgl_lastkey() = fgl_keyval("up")     then
            next field fnldat
         end if

         initialize d_ctb05m01.nomgrr  to null

         if d_ctb05m01.pstcoddig is not null   then
            open  c_ctb05m01prs using d_ctb05m01.pstcoddig
            fetch c_ctb05m01prs into  d_ctb05m01.nomgrr

            if sqlca.sqlcode <> 0   then
               error " Prestador nao cadastrado!"
               next field pstcoddig
            end if

            close c_ctb05m01prs
         end if
         display by name d_ctb05m01.nomgrr

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   if d_ctb05m01.tipdat  =  1   then
      if d_ctb05m01.pstcoddig  is null   then
         let ws.condicao =  "  from dbsmopg ",
                            " where socfatentdat between ? and ? "
      else
         let ws.condicao =  "  from dbsmopg ",
                            " where socfatentdat between ? and ? ",
                            "   and pstcoddig    = ? "
      end if
   else
      if d_ctb05m01.pstcoddig  is null   then
         let ws.condicao =  "  from dbsmopg ",
                            " where socfatpgtdat between ? and ? "
      else
         let ws.condicao =  "  from dbsmopg ",
                            " where socfatpgtdat between ? and ? ",
                            "   and pstcoddig    = ? "
      end if
   end if
   let ws.condicao = ws.condicao clipped, " and soctip = 3 "

   let ws.seleciona = "select socopgnum,   ",
                  "       socfatentdat,",
                  "       socfatpgtdat,",
                  "       socopgsitcod,",
                  "       socopgorgcod,",
                  "       pstcoddig   ,",
                  "       segnumdig   ,",
                  "       corsus       ",
                  ws.condicao  clipped

   set isolation to dirty read

   message " Aguarde, pesquisando..."  attribute(reverse)
   prepare comando_sql from ws.seleciona 
   declare c_ctb05m01  cursor for  comando_sql

   if d_ctb05m01.pstcoddig is null  then
      open c_ctb05m01  using  d_ctb05m01.incdat,
                              d_ctb05m01.fnldat
   else
      open c_ctb05m01  using  d_ctb05m01.incdat,
                              d_ctb05m01.fnldat,
                              d_ctb05m01.pstcoddig
   end if

   foreach  c_ctb05m01  into  a_ctb05m01[arr_aux].socopgnum,
                              a_ctb05m01[arr_aux].socfatentdat,
                              a_ctb05m01[arr_aux].socfatpgtdat,
                              ws.socopgsitcod,
                              ws.socopgorgcod,
                              ws.pstcoddig,
                              ws.segnumdig,
                              ws.corsus

      initialize a_ctb05m01[arr_aux].socopgfavnom  to null

      if ws.pstcoddig is not null  then
         open  c_ctb05m01prs  using ws.pstcoddig
         fetch c_ctb05m01prs  into  a_ctb05m01[arr_aux].socopgfavnom
         close c_ctb05m01prs
      end if

      if ws.segnumdig is not null  then
         open  c_ctb05m01seg  using ws.segnumdig
         fetch c_ctb05m01seg  into  a_ctb05m01[arr_aux].socopgfavnom
         close c_ctb05m01seg
      end if

      if ws.corsus is not null  then
        #open  c_ctb05m01cor  using ws.corsus
        #fetch c_ctb05m01cor  into  a_ctb05m01[arr_aux].socopgfavnom
        #close c_ctb05m01cor
         select cornom
            into a_ctb05m01[arr_aux].socopgfavnom
            from gcaksusep, gcakcorr
           where gcaksusep.corsus   = ws.corsus
             and gcakcorr.corsuspcp = gcaksusep.corsuspcp
      end if

      # MONTA DESCRICAO DA ORIGEM DA O.P.
      #----------------------------------
      initialize a_ctb05m01[arr_aux].socopgorgdes  to null
      let ws.cponom = "socopgorgcod"
      if  ws.socopgorgcod is null then
          let  ws.socopgorgcod = 1    # DIGITADA
      end if
      open  c_ctb05m01idd  using  ws.cponom,
                                  ws.socopgorgcod
      fetch c_ctb05m01idd  into   a_ctb05m01[arr_aux].socopgorgdes

      if sqlca.sqlcode <> 0   then
         error "Erro (", sqlca.sqlcode, ") na leitura da descricao da origem!"
      end if

      # MONTA DESCRICAO DA SITUACAO DA O.P.
      #------------------------------------
      initialize a_ctb05m01[arr_aux].socopgsitdes  to null
      let ws.cponom = "socopgsitcod"
      open  c_ctb05m01idd  using  ws.cponom,
                                  ws.socopgsitcod
      fetch c_ctb05m01idd  into   a_ctb05m01[arr_aux].socopgsitdes

      if sqlca.sqlcode <> 0   then
         error "Erro (", sqlca.sqlcode, ") na leitura da descricao da situacao!"
      end if

      # MONTA DESCRICAO DA FASE DA O.P.
      #--------------------------------
      initialize ws.socopgfascod                   to null
      initialize a_ctb05m01[arr_aux].socopgfasdes  to null
      let ws.cponom = "socopgfascod"

      # PSI 221074 - BURINI
      call cts50g00_sel_max_etapa(a_ctb05m01[arr_aux].socopgnum)
           returning ws.retorno, 
                     ws.mensagem,
                     ws.socopgfascod
                     
      if ws.retorno <> 1   then
         error ws.mensagem
      else
         open  c_ctb05m01idd  using  ws.cponom,
                                     ws.socopgfascod
         fetch c_ctb05m01idd  into   a_ctb05m01[arr_aux].socopgfasdes

         if sqlca.sqlcode <> 0   then
            error "Erro (", sqlca.sqlcode, ") na leitura da descricao da fase!"
         end if

      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 2500 then
         error "Limite excedido. Pesquisa com mais de 2500 O.Ps.!"
         exit foreach
      end if
   end foreach

   if arr_aux  > 1   then
      message " (F17)Abandona, (F8)Seleciona"

      let d_ctb05m01.total = "Total ", arr_aux - 1  using "&&&&"
      display by name d_ctb05m01.total    attribute(reverse)

      call set_count(arr_aux-1)

      display array  a_ctb05m01 to s_ctb05m01.*
        on key(interrupt)
           exit display

        on key(F8)
           let arr_aux = arr_curr()
           call ctb05m02(a_ctb05m01[arr_aux].socopgnum)
      end display

      display " "  to  total
      for scr_aux=1 to 4
          clear s_ctb05m01[scr_aux].*
      end for
   else
      error " Nao existe O.P. para pesquisa!"
   end if

end while

let int_flag = false
close window ctb05m01

end function  ###  ctb05m01
