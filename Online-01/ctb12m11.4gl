###############################################################################
# Nome do Modulo: ctb12m11                                           Marcelo  #
#                                                                    Gilberto #
# Consulta ordem de pagamento por datas (pagto/entrega) e prestador  Fev/1997 #
###############################################################################
# 08/12/2005	Cristiane Silva		PSI		Inclusao de coluna de #
#							valores adicionais    #
#-----------------------------------------------------------------------------#
# 04/12/2006    Priscila Staingel       PSI 205206      Incluir filtro por    #
#                                                        empresa              #
#-----------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32          #
#                                                                             #
###############################################################################

database porto

define m_prep_sql    smallint

#-----------------------------------------------------------
function ctb12m11_prepare()
#-----------------------------------------------------------
 define l_sql   char(200)

 let l_sql = "select cpodes     ",
                 "  from iddkdominio",
                 " where cponom  = ? ",
                 "   and cpocod  = ? "
 prepare pctb12m11001 from l_sql
 declare cctb12m11001 cursor for pctb12m11001                
 
 let m_prep_sql = true
 
end function

#-----------------------------------------------------------
 function ctb12m11()
#-----------------------------------------------------------

 define d_ctb12m11  record
    tipdat          dec(1,0),
    tipdatdes       char(09),
    data            date,
    data2	    date,
    ciaempcod       like datmservico.ciaempcod,    #PSI 205206
    empsgl          like gabkemp.empsgl            #PSI 205206
 end record

 define a_ctb12m11 array[12] of record
    socopgsitdes    char(40),
    qtdopg          dec(4,0),
    qtdsrv          dec(8,0),
    socopgitmcst    dec(15,2),
    opgvlr          dec(15,2)
 end record

 define ws          record
    selecao          char(500),
    condicao        char(500),
    socopgsitcod    like dbsmopg.socopgsitcod,
    qtdopg          dec(4,0),
    qtdsrv          dec(8,0),
    socopgitmcst    like dbsmopgcst.socopgitmcst,
    opgvlr          dec(15,2),
    cponom          like iddkdominio.cponom
 end record

 define arr_aux     smallint
 define scr_aux     smallint
 
 define l_ret       smallint,
        l_mensagem  char(50)

 initialize d_ctb12m11.*    to null
 initialize ws.*            to null
 initialize a_ctb12m11      to null
 let arr_aux = null
 let scr_aux = null
 let l_ret = null
 let l_mensagem = null

 if m_prep_sql <> true then
    call ctb12m11_prepare()
 end if

 open window ctb12m11 at 06,02 with form "ctb12m11"
             attribute (form line first)

 while true

   let int_flag = false
   initialize a_ctb12m11  to null
   let arr_aux  = 1

   input by name d_ctb12m11.tipdat,
                 d_ctb12m11.data, 
                 d_ctb12m11.data2,
                 d_ctb12m11.ciaempcod       without defaults

      before field tipdat
             display by name d_ctb12m11.tipdat    attribute (reverse)

      after  field tipdat
             display by name d_ctb12m11.tipdat

             if d_ctb12m11.tipdat is null  then
                error " Tipo deve ser: 1-Entrega, 2-Pagamento"
                next field tipdat
             end if

             case d_ctb12m11.tipdat
                when  1   let d_ctb12m11.tipdatdes = "ENTREGA"
                when  2   let d_ctb12m11.tipdatdes = "PAGAMENTO"
                otherwise error " Tipo deve ser: 1-Entrega, 2-Pagamento"
                          next field tipdat
             end case
             display by name d_ctb12m11.tipdatdes

      before field data
             display by name d_ctb12m11.data      attribute (reverse)

      after  field data
             if d_ctb12m11.data  is null   then
                let d_ctb12m11.data = today
             end if
             display by name d_ctb12m11.data

      before field data2
             display by name d_ctb12m11.data2      attribute (reverse)

      after  field data2
             if d_ctb12m11.data2  is null   then
                let d_ctb12m11.data2 = today
             end if
             display by name d_ctb12m11.data2

             if d_ctb12m11.data2 - d_ctb12m11.data > 30 then
             	error "Período informado nao pode ser superior a 30 dias"
      	        next field data2
             end if

      #PSI 205206   
      before field ciaempcod
         display by name d_ctb12m11.ciaempcod attribute (reverse)
         
      after field ciaempcod   
         display by name d_ctb12m11.ciaempcod

         if fgl_lastkey() = fgl_keyval("left")   or
            fgl_lastkey() = fgl_keyval("up")     then
            next field data2
         end if
         
         initialize d_ctb12m11.empsgl  to null
         
         #Buscar descricao da empresa informada
         if d_ctb12m11.ciaempcod is not null then
            call cty14g00_empresa(1, d_ctb12m11.ciaempcod)
                 returning l_ret,
                           l_mensagem,
                           d_ctb12m11.empsgl
            if l_ret <> 1 then
               #erro ao buscar descricao
               error l_mensagem
               next field ciaempcod
            end if               
         else
            let d_ctb12m11.empsgl = "TODAS"
         end if
         display by name d_ctb12m11.empsgl


      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   let ws.qtdopg = 0
   let ws.qtdsrv = 0
   let ws.socopgitmcst = 0.00
   let ws.opgvlr = 0.00

   set isolation to dirty read

   #PSI 205206 - novos prepares para incluir ciaempcod
   #if d_ctb12m11.tipdat  =  1   then
   #   let ws.selecao = "select sum(cst.socopgitmcst)",
   #		   " from dbsmopgcst cst, dbsmopg opg",
   #		   " where cst.socopgnum = opg.socopgnum",
   #		   " and opg.socfatentdat between ? and ?",
   #		   " and socopgsitcod = ?",
   #		   " and soctip = 1"
   #
   #else
   #   let ws.selecao = "select sum(cst.socopgitmcst)",
   #		   " from dbsmopgcst cst, dbsmopg opg",
   #		   " where cst.socopgnum = opg.socopgnum",
   #		   " and opg.socfatpgtdat between ? and ?",
   #		   " and socopgsitcod = ?",
   #		   " and soctip = 1"
   #end if
   #prepare sel_dbsmopgcst from ws.selecao
   #declare c_dbsmopgcst cursor for sel_dbsmopgcst
   #
   #if d_ctb12m11.tipdat  =  1   then
   #   let ws.condicao =  " where socfatentdat between ? and ?"
   #else
   #   let ws.condicao =  " where socfatpgtdat between ? and ?"
   #end if
   #let ws.condicao = ws.condicao clipped, " and soctip = 1 "
   #
   #let ws.selecao = "select count(*), sum(socopgitmvlr)",
   #                "  from dbsmopgitm, dbsmopg",
   #                ws.condicao  clipped,
   #                "   and socopgsitcod = ?",
   #                "   and dbsmopgitm.socopgnum = dbsmopg.socopgnum"
   #prepare sel_dbsmopgitm from ws.selecao
   #declare c_dbsmopgitm cursor for sel_dbsmopgitm
   #
   #let ws.selecao = "select socopgsitcod, count(*)",
   #                "  from dbsmopg ",
   #                ws.condicao  clipped,
   #                " group by socopgsitcod ",
   #                " order by socopgsitcod "
   #prepare sel_dbsmopg from ws.selecao
   #declare c_ctb12m11 cursor for sel_dbsmopg

   #a data é utilizada em todos os prepares possiveis
   if d_ctb12m11.tipdat  =  1   then
      #se tipo é 1 - ENTRADA
      let ws.condicao =  " where a.socfatentdat between ? and ?"
   else
      #se tipo é 2 - PAGAMENTO 
      let ws.condicao =  " where a.socfatpgtdat between ? and ?"
   end if
   let ws.condicao = ws.condicao clipped, " and a.soctip = 1 " 
   
   #buscar a quantidade de OP´s em uma situação
   let ws.selecao = " select a.socopgsitcod, count(distinct a.socopgnum)"       
   if d_ctb12m11.ciaempcod is null then
      #se nao informou empresa, busca OP´s pela data
      let ws.selecao = ws.selecao clipped, " from dbsmopg a ",
                       ws.condicao  clipped,
                       " group by a.socopgsitcod ",
                       " order by a.socopgsitcod "
   else
      #se informou empresa, busca OP´s pela data e relaciona com os itens e o servico
      # para buscar apenas as OP´s que têm servicos com a empresa informada
      let ws.selecao = ws.selecao clipped, " from dbsmopg a, dbsmopgitm b, datmservico c ",
                      ws.condicao  clipped, 
                      " and a.socopgnum = b.socopgnum ",
                      " and b.atdsrvnum = c.atdsrvnum ",
                      " and b.atdsrvano = c.atdsrvano ",
                      " and c.ciaempcod = ?           ",                
                      " group by a.socopgsitcod ",
                      " order by a.socopgsitcod "
   end if
   prepare sel_dbsmopg from ws.selecao       
   declare c_ctb12m11 cursor for sel_dbsmopg 
   
   #buscar a quantidade de itens e o valor total desses itens
   let ws.selecao = "select count(b.socopgitmnum), sum(b.socopgitmvlr)"
   if d_ctb12m11.ciaempcod is null then
      #se nao informou empresa, busca itens pela data
      let ws.selecao = ws.selecao clipped, " from dbsmopg a, dbsmopgitm b ",
                      ws.condicao  clipped,
                      "   and a.socopgsitcod = ?",
                      "   and a.socopgnum = b.socopgnum"
   else
      # se informou empresa, busca itens pela data e relaciona com o servico
      # para buscar apenas os itens das OP´s que têm servico com a empresa informada
      let ws.selecao = ws.selecao clipped, " from dbsmopg a, dbsmopgitm b, datmservico c ",
                      ws.condicao  clipped, 
                      " and a.socopgsitcod = ?",
                      " and a.socopgnum = b.socopgnum ",
                      " and b.atdsrvnum = c.atdsrvnum ",
                      " and b.atdsrvano = c.atdsrvano ",
                      " and c.ciaempcod = ?           "                
   end if
   prepare sel_dbsmopgitm from ws.selecao
   declare c_dbsmopgitm cursor for sel_dbsmopgitm
   
   #busca a soma dos itens de custo
   let ws.selecao = "select sum(cst.socopgitmcst)"
   if d_ctb12m11.ciaempcod is null then
      #se nao informou empresa, busca custo da OP de acordo com a data
      let ws.selecao = ws.selecao clipped, " from dbsmopgcst cst, dbsmopg a, dbsmopgitm b ",
                      ws.condicao clipped, 
                      " and a.socopgsitcod = ? ",
                      " and cst.socopgnum = a.socopgnum",
                      " and cst.socopgitmnum = b.socopgitmnum",
                      " and a.socopgnum = b.socopgnum"
   else
      #se informou empresa, busca custo da OP de acordo com a data e relaciona
      # item e servico, para buscar apenas as OP´s que têm servico de acordo
      # com a empresa informada
      let ws.selecao = ws.selecao clipped, " from dbsmopgcst cst, dbsmopg a, ",
                      " dbsmopgitm b, datmservico c ",
                      ws.condicao clipped, 
                      " and a.socopgsitcod = ? ",
                      " and a.socopgnum = b.socopgnum ",
                      " and b.socopgnum = cst.socopgnum",   
                      " and b.socopgitmnum = cst.socopgitmnum",   
                      " and b.atdsrvnum = c.atdsrvnum ",
                      " and b.atdsrvano = c.atdsrvano ",
                      " and c.ciaempcod = ?           "                              
   end if
   prepare sel_dbsmopgcst from ws.selecao
   declare c_dbsmopgcst cursor for sel_dbsmopgcst   
   
   message " Aguarde, pesquisando..."  attribute(reverse)

   #PSI 205206
   if d_ctb12m11.ciaempcod is null then
      open    c_ctb12m11 using d_ctb12m11.data, d_ctb12m11.data2
   else
      open    c_ctb12m11 using d_ctb12m11.data, 
                               d_ctb12m11.data2,
                               d_ctb12m11.ciaempcod
   end if   

   foreach c_ctb12m11 into  ws.socopgsitcod,
                            a_ctb12m11[arr_aux].qtdopg

      initialize a_ctb12m11[arr_aux].socopgsitdes  to null
      let ws.cponom = "socopgsitcod"
      open  cctb12m11001 using ws.cponom,
                                ws.socopgsitcod
      fetch cctb12m11001 into  a_ctb12m11[arr_aux].socopgsitdes

      if sqlca.sqlcode <> 0   then
         error "Erro (", sqlca.sqlcode, ") na leitura da descricao da situacao!"
      end if

      close cctb12m11001

      #PSI 205206
      if d_ctb12m11.ciaempcod is null then
          open  c_dbsmopgitm using d_ctb12m11.data, d_ctb12m11.data2,
                                   ws.socopgsitcod
      else
          open  c_dbsmopgitm using d_ctb12m11.data, 
                                   d_ctb12m11.data2,
                                   ws.socopgsitcod,
                                   d_ctb12m11.ciaempcod      
      end if                             
      fetch c_dbsmopgitm into  a_ctb12m11[arr_aux].qtdsrv,
      			       a_ctb12m11[arr_aux].opgvlr
      close c_dbsmopgitm

      #PSI 205206
      if d_ctb12m11.ciaempcod is null then
          open  c_dbsmopgcst using d_ctb12m11.data, d_ctb12m11.data2,
                                   ws.socopgsitcod
      else
          open  c_dbsmopgcst using d_ctb12m11.data, 
                                   d_ctb12m11.data2,
                                   ws.socopgsitcod,
                                   d_ctb12m11.ciaempcod      
      end if                             

      fetch c_dbsmopgcst into  a_ctb12m11[arr_aux].socopgitmcst

      close c_dbsmopgcst

      if a_ctb12m11[arr_aux].qtdsrv is null  then
         let a_ctb12m11[arr_aux].qtdsrv = 0
      end if

      if a_ctb12m11[arr_aux].socopgitmcst is null  then
         let a_ctb12m11[arr_aux].socopgitmcst = 0.00
      end if

      if a_ctb12m11[arr_aux].opgvlr is null  then
         let a_ctb12m11[arr_aux].opgvlr = 0.00
      end if

      let ws.qtdopg = ws.qtdopg + a_ctb12m11[arr_aux].qtdopg
      let ws.qtdsrv = ws.qtdsrv + a_ctb12m11[arr_aux].qtdsrv
      let ws.socopgitmcst = ws.socopgitmcst + a_ctb12m11[arr_aux].socopgitmcst
      let ws.opgvlr = ws.opgvlr + a_ctb12m11[arr_aux].opgvlr

      let arr_aux = arr_aux + 1
      if arr_aux > 12  then
         error "Limite excedido! Foram encontradas mais de 12 situacoes!"
         exit foreach
      end if
   end foreach

   if arr_aux > 1  then
      let arr_aux = arr_aux + 1

      let a_ctb12m11[arr_aux].socopgsitdes = "TOTAL GERAL"
      let a_ctb12m11[arr_aux].qtdopg       = ws.qtdopg
      let a_ctb12m11[arr_aux].qtdsrv       = ws.qtdsrv
      let a_ctb12m11[arr_aux].socopgitmcst = ws.socopgitmcst
      let a_ctb12m11[arr_aux].opgvlr       = ws.opgvlr

      message " (F17)Abandona "

      call set_count(arr_aux)

      display array  a_ctb12m11 to s_ctb12m11.*
         on key(interrupt)
            exit display
      end display

      for scr_aux = 1 to 10      #qtde de linhas de array na tela
          clear s_ctb12m11[scr_aux].*
      end for
   else
      error " Nao foi encontrada nenhuma O.P. para data informada! "
   end if

end while

let int_flag = false
close window ctb12m11

end function  ###  ctb12m11
