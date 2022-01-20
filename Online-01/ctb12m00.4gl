###############################################################################
# Nome do Modulo: CTB12M00                                           Marcelo  #
#                                                                    Gilberto #
# Consulta ordem de pagamento por datas (pagto/entrega) e prestador  Fev/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 13/12/1999  PSI 9637-7   Wagner       Incluir display da origem da OP       #
#-----------------------------------------------------------------------------#
# 17/12/1999  PSI 9805-1   Gilberto     Permitir pesquisa por periodo.        #
#-----------------------------------------------------------------------------#
# 13/07/2001  Claudinha    Ruiz         tirar o prepare gcaksusep,gcakfilial, #
#                                       gcakcorr.                             #
#-----------------------------------------------------------------------------#
# 04/12/2006  PSI 205206   Priscila     Incluir filtro por empresa            #
#-----------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32          #
#-----------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel    #
###############################################################################

database porto

define m_prep_sql    smallint

#-----------------------------------------------------------
function ctb12m00_prepare()
#-----------------------------------------------------------

 define l_sql   char(350)

 let l_sql = "select cpodes     ",
                 "  from iddkdominio",
                 " where cponom  = ? ",
                 "   and cpocod  = ? "
 prepare comando_aux2  from  l_sql
 declare c_ctb12m00idd  cursor for  comando_aux2

 let l_sql = "select nomgrr    ",
                 "  from dpaksocor ",
                 " where pstcoddig = ?"
 prepare comando_aux4  from  l_sql
 declare c_ctb12m00prs  cursor for  comando_aux4

 let l_sql = "select segnom    ",
                 "  from gsakseg   ",
                 " where segnumdig = ?"
 prepare comando_aux5  from  l_sql
 declare c_ctb12m00seg  cursor for  comando_aux5

#let l_sql = "select cornom    ",
#                "  from gcaksusep, gcakcorr",
#                " where gcaksusep.corsus   = ?",
#                "   and gcakcorr.corsuspcp = gcaksusep.corsuspcp"
#prepare comando_aux6  from  l_sql
#declare c_ctb12m00cor  cursor for  comando_aux6

  #PSI 205206
  let l_sql = "select b.ciaempcod ",
              " from dbsmopgitm a, datmservico b ",
              " where a.socopgnum = ? ",
              "   and a.atdsrvnum = b.atdsrvnum ",
              "   and a.atdsrvano = b.atdsrvano "
  prepare pctb12m00006 from l_sql
  declare cctb12m00006 cursor for pctb12m00006

  let m_prep_sql = true

end function


#-----------------------------------------------------------
 function ctb12m00()
#-----------------------------------------------------------

 define d_ctb12m00  record
    tipdat          dec(1,0),
    tipdatdes       char(07),
    incdat          date,
    fnldat          date,
    pstcoddig       like dbsmopg.pstcoddig,
    nomgrr          like dpaksocor.nomgrr,
    ciaempcod       like datmservico.ciaempcod,    #PSI 205206
    empsgl          like gabkemp.empsgl,           #PSI 205206
    total           char(12)
 end record

 define a_ctb12m00 array[2500] of record
    socopgnum       like dbsmopg.socopgnum,
    socfatentdat    like dbsmopg.socfatentdat,
    socfatpgtdat    like dbsmopg.socfatpgtdat,
    socopgfavnom    like dbsmopgfav.socopgfavnom,
    socopgorgdes    char(10),
    socopgfasdes    char(22),
    socopgsitdes    char(40)
 end record

 define ws          record
    selecao          char(350),
    condicao        char(250),
    socopgsitcod    like dbsmopg.socopgsitcod,
    socopgorgcod    like dbsmopg.socopgorgcod,
    socopgfascod    like dbsmopgfas.socopgfascod,
    pstcoddig       like dbsmopg.pstcoddig,
    segnumdig       like dbsmopg.segnumdig,
    corsus          like dbsmopg.corsus,
    cponom          like iddkdominio.cponom,
    ciaempcod       like datmservico.ciaempcod     #empresa do servico  #PSI 205206
 end record

 define arr_aux     smallint
 define scr_aux     smallint
 
 define l_ret       smallint,
        l_mensagem  char(50),
        l_mesma_emp smallint            #PSI 205206


 initialize d_ctb12m00.*    to null
 initialize ws.*            to null
 initialize a_ctb12m00      to null
 let arr_aux = null
 let scr_aux = null
 let l_ret = null
 let l_mensagem = null
 let l_mesma_emp = null

 if m_prep_sql <> true then
    call ctb12m00_prepare()
 end if

 open window ctb12m00 at 06,02 with form "ctb12m00"
             attribute (form line first)

 while true

   let int_flag = false
   initialize a_ctb12m00    to null
   initialize d_ctb12m00.*  to null
   let arr_aux  = 1

   display by name d_ctb12m00.*

   input by name d_ctb12m00.tipdat,
                 d_ctb12m00.incdat,
                 d_ctb12m00.fnldat,
                 d_ctb12m00.pstcoddig,
                 d_ctb12m00.ciaempcod   without defaults

      before field tipdat
         display by name d_ctb12m00.tipdat    attribute (reverse)

      after  field tipdat
         display by name d_ctb12m00.tipdat

         if d_ctb12m00.tipdat   is null   then
            error " Tipo deve ser: 1-Entrega, 2-Pagamento"
            next field tipdat
         end if

         case  d_ctb12m00.tipdat
               when  1   let d_ctb12m00.tipdatdes = "ENTREGA"
               when  2   let d_ctb12m00.tipdatdes = "PAGTO"
               otherwise error " Tipo deve ser: 1-Entrega, 2-Pagamento"
                         next field tipdat
         end case
         display by name d_ctb12m00.tipdatdes

      before field incdat
         display by name d_ctb12m00.incdat    attribute (reverse)

      after  field incdat
         display by name d_ctb12m00.incdat

         if d_ctb12m00.incdat is null   then
            let d_ctb12m00.incdat = today
            display by name d_ctb12m00.incdat
         end if

         if d_ctb12m00.incdat  <  "01/06/1997"  then
            error " Consulta disponivel a partir de 01/06/1997!"
            next field incdat
         end if

      before field fnldat
         display by name d_ctb12m00.fnldat      attribute (reverse)

      after  field fnldat
         display by name d_ctb12m00.fnldat

         if d_ctb12m00.fnldat is null  then
            let d_ctb12m00.fnldat = d_ctb12m00.incdat
            display by name d_ctb12m00.fnldat
         end if

         if d_ctb12m00.fnldat < d_ctb12m00.incdat  then
            error " Data de pagamento final nao deve ser menor que data pagamento inicial!"
            next field fnldat
         end if

         if d_ctb12m00.fnldat > d_ctb12m00.incdat + 30 units day  then
            error " Periodo para pesquisa esta' limitado a 30 dias!"
            next field fnldat
         end if

      before field pstcoddig
         display by name d_ctb12m00.pstcoddig attribute (reverse)

      after  field pstcoddig
         display by name d_ctb12m00.pstcoddig

         if fgl_lastkey() = fgl_keyval("left")   or
            fgl_lastkey() = fgl_keyval("up")     then
            next field fnldat
         end if

         initialize d_ctb12m00.nomgrr  to null

         if d_ctb12m00.pstcoddig is not null   then
            open  c_ctb12m00prs using d_ctb12m00.pstcoddig
            fetch c_ctb12m00prs into  d_ctb12m00.nomgrr

            if sqlca.sqlcode <> 0   then
               error " Prestador nao cadastrado!"
               next field pstcoddig
            end if

            close c_ctb12m00prs
         end if
         display by name d_ctb12m00.nomgrr
         
      #PSI 205206   
      before field ciaempcod
         display by name d_ctb12m00.ciaempcod attribute (reverse)
         
      after field ciaempcod   
         display by name d_ctb12m00.ciaempcod

         if fgl_lastkey() = fgl_keyval("left")   or
            fgl_lastkey() = fgl_keyval("up")     then
            next field pstcoddig
         end if
         
         initialize d_ctb12m00.empsgl  to null
         
         #Buscar descricao da empresa informada
         if d_ctb12m00.ciaempcod is not null then
            call cty14g00_empresa(1, d_ctb12m00.ciaempcod)
                 returning l_ret,
                           l_mensagem,
                           d_ctb12m00.empsgl
            if l_ret <> 1 then
               #erro ao buscar descricao
               error l_mensagem
               next field ciaempcod
            end if               
         else
            let d_ctb12m00.empsgl = "TODAS"
         end if
         display by name d_ctb12m00.empsgl

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   if d_ctb12m00.tipdat  =  1   then
      if d_ctb12m00.pstcoddig  is null   then
         let ws.condicao =  "  from dbsmopg ",
                            " where socfatentdat between ? and ? "
      else
         let ws.condicao =  "  from dbsmopg ",
                            " where socfatentdat between ? and ? ",
                            "   and pstcoddig    = ? "
      end if
   else
      if d_ctb12m00.pstcoddig  is null   then
         let ws.condicao =  "  from dbsmopg ",
                            " where socfatpgtdat between ? and ? "
      else
         let ws.condicao =  "  from dbsmopg ",
                            " where socfatpgtdat between ? and ? ",
                            "   and pstcoddig    = ? "
      end if
   end if
   let ws.condicao = ws.condicao clipped, " and soctip = 1 "

   let ws.selecao= "select socopgnum,   ",
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
   prepare comando_sql from ws.selecao
   declare c_ctb12m00  cursor for  comando_sql

   if d_ctb12m00.pstcoddig is null  then
      open c_ctb12m00  using  d_ctb12m00.incdat,
                              d_ctb12m00.fnldat
   else
      open c_ctb12m00  using  d_ctb12m00.incdat,
                              d_ctb12m00.fnldat,
                              d_ctb12m00.pstcoddig
   end if

   foreach  c_ctb12m00  into  a_ctb12m00[arr_aux].socopgnum,
                              a_ctb12m00[arr_aux].socfatentdat,
                              a_ctb12m00[arr_aux].socfatpgtdat,
                              ws.socopgsitcod,
                              ws.socopgorgcod,
                              ws.pstcoddig,
                              ws.segnumdig,
                              ws.corsus

      initialize a_ctb12m00[arr_aux].socopgfavnom  to null

      #PSI 205206
      #verificar se OP encontrada tem itens (servicos) de mesma empresa que 
      # a empresa solicitada no input de pesquisa
      if d_ctb12m00.ciaempcod is not null then
         let l_mesma_emp = true
         open cctb12m00006 using a_ctb12m00[arr_aux].socopgnum
         foreach cctb12m00006 into ws.ciaempcod
             if ws.ciaempcod <> d_ctb12m00.ciaempcod then
                let l_mesma_emp = false
             end if
         end foreach
         if l_mesma_emp <> true then
            #ignora OP encontrada, pois servico da OP tem empresa diferente
            continue foreach
         end if
      end if

      if ws.pstcoddig is not null  then
         open  c_ctb12m00prs  using ws.pstcoddig
         fetch c_ctb12m00prs  into  a_ctb12m00[arr_aux].socopgfavnom
         close c_ctb12m00prs
      end if

      if ws.segnumdig is not null  then
         open  c_ctb12m00seg  using ws.segnumdig
         fetch c_ctb12m00seg  into  a_ctb12m00[arr_aux].socopgfavnom
         close c_ctb12m00seg
      end if

      if ws.corsus is not null  then
        #open  c_ctb12m00cor  using ws.corsus
        #fetch c_ctb12m00cor  into  a_ctb12m00[arr_aux].socopgfavnom
        #close c_ctb12m00cor
         select cornom
            into a_ctb12m00[arr_aux].socopgfavnom
            from gcaksusep, gcakcorr
           where gcaksusep.corsus   = ws.corsus
             and gcakcorr.corsuspcp = gcaksusep.corsuspcp
      end if

      # MONTA DESCRICAO DA ORIGEM DA O.P.
      #----------------------------------
      initialize a_ctb12m00[arr_aux].socopgorgdes  to null
      let ws.cponom = "socopgorgcod"
      if  ws.socopgorgcod is null then
          let  ws.socopgorgcod = 1    # DIGITADA
      end if
      open  c_ctb12m00idd  using  ws.cponom,
                                  ws.socopgorgcod
      fetch c_ctb12m00idd  into   a_ctb12m00[arr_aux].socopgorgdes

      if sqlca.sqlcode <> 0   then
         error "Erro (", sqlca.sqlcode, ") na leitura da descricao da origem!"
      end if

      # MONTA DESCRICAO DA SITUACAO DA O.P.
      #------------------------------------
      initialize a_ctb12m00[arr_aux].socopgsitdes  to null
      let ws.cponom = "socopgsitcod"
      open  c_ctb12m00idd  using  ws.cponom,
                                  ws.socopgsitcod
      fetch c_ctb12m00idd  into   a_ctb12m00[arr_aux].socopgsitdes

      if sqlca.sqlcode <> 0   then
         error "Erro (", sqlca.sqlcode, ") na leitura da descricao da situacao!"
      end if

      # MONTA DESCRICAO DA FASE DA O.P.
      #--------------------------------
      initialize ws.socopgfascod                   to null
      initialize a_ctb12m00[arr_aux].socopgfasdes  to null
      let ws.cponom = "socopgfascod"

      # PSI 221074 - BURINI
      call cts50g00_sel_max_etapa(a_ctb12m00[arr_aux].socopgnum)
           returning l_ret,
                     l_mensagem,
                     ws.socopgfascod 

      if l_ret <> 1   then
         error l_mensagem
      else
         open  c_ctb12m00idd  using  ws.cponom,
                                     ws.socopgfascod
         fetch c_ctb12m00idd  into   a_ctb12m00[arr_aux].socopgfasdes

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

      let d_ctb12m00.total = "Total ", arr_aux - 1  using "&&&&"
      display by name d_ctb12m00.total    attribute(reverse)

      call set_count(arr_aux-1)

      display array  a_ctb12m00 to s_ctb12m00.*
        on key(interrupt)
           exit display

        on key(F8)
           let arr_aux = arr_curr()
           call ctb12m01(a_ctb12m00[arr_aux].socopgnum)
      end display

      display " "  to  total
      for scr_aux=1 to 4
          clear s_ctb12m00[scr_aux].*
      end for
   else
      error " Nao existe O.P. para pesquisa!"
   end if

end while

let int_flag = false
close window ctb12m00

end function  ###  ctb12m00
