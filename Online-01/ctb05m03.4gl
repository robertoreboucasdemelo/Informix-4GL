###############################################################################
# Nome do Modulo: CTB05M03                                           Wagner   #
#                                                                             #
# Consulta ordem de pagamento por datas (pagto/entrega) e prestador  Mar/2002 #
###############################################################################
# 08/12/2005	Cristiane Silva		PSI		Inclusao de coluna de #
#							valores adicionais    #
#-----------------------------------------------------------------------------#
# 18/07/06   Junior, Meta  AS112372      Migracao de versao do 4gl.           #
# 31/05/10   Robert Lima                 Inclusão de novo filtro de pesquisa  #
#                                        (empresa)                            #
#-----------------------------------------------------------------------------#


 database porto

#-----------------------------------------------------------
 function ctb05m03()
#-----------------------------------------------------------

 define d_ctb05m03  record
    tipdat          dec(1,0),
    tipdatdes       char(09),
    data            date,
    data2	    date,
    empcod          like dbsmopg.empcod,##
    empsgl          like gabkemp.empsgl ##
 end record

 define a_ctb05m03 array[12] of record
    socopgsitdes    char(40),
    qtdopg          dec(4,0),
    qtdsrv          dec(8,0),
    socopgitmcst    dec(15,2),
    opgvlr          dec(15,2)
 end record

 define ws          record
    comando         char(350),
    condicao        char(100),
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

 initialize d_ctb05m03.*    to null
 initialize ws.*            to null

 let ws.comando = "select cpodes     ",
                 "  from iddkdominio",
                 " where cponom  = ? ",
                 "   and cpocod  = ? "
 prepare sel_iddkdominio from ws.comando 
 declare c_iddkdominio cursor for sel_iddkdominio

 open window ctb05m03 at 06,02 with form "ctb05m03"
             attribute (form line first)

 while true

   let int_flag = false
   initialize a_ctb05m03  to null
   let arr_aux  = 1

   input by name d_ctb05m03.tipdat,
                 d_ctb05m03.data, d_ctb05m03.data2,
                 d_ctb05m03.empcod       without defaults

      before field tipdat
             display by name d_ctb05m03.tipdat    attribute (reverse)

      after  field tipdat
             display by name d_ctb05m03.tipdat

             if d_ctb05m03.tipdat is null  then
                error " Tipo deve ser: 1-Entrega, 2-Pagamento"
                next field tipdat
             end if

             case d_ctb05m03.tipdat
                when  1   let d_ctb05m03.tipdatdes = "ENTREGA"
                when  2   let d_ctb05m03.tipdatdes = "PAGAMENTO"
                otherwise error " Tipo deve ser: 1-Entrega, 2-Pagamento"
                          next field tipdat
             end case
             display by name d_ctb05m03.tipdatdes

      before field data
             display by name d_ctb05m03.data      attribute (reverse)

      after  field data
             if d_ctb05m03.data  is null   then
                let d_ctb05m03.data = today
             end if
             display by name d_ctb05m03.data

      before field data2
             display by name d_ctb05m03.data2      attribute (reverse)

      after  field data2
             if d_ctb05m03.data2  is null   then
                let d_ctb05m03.data2 = today
             end if
             display by name d_ctb05m03.data2

      if d_ctb05m03.data2 - d_ctb05m03.data > 30 then
      	error "Período informado nao pode ser superior a 30 dias"
      	next field data2
      end if
      
      before field empcod
      	     display by name d_ctb05m03.empcod      attribute (reverse)
      	     
      after field empcod
      
         ######[Alterado Robert]
	   if d_ctb05m03.empcod is not null then
		call cty14g00_empresa(1, d_ctb05m03.empcod) 
		     returning l_ret,                          
		               l_mensagem,                     
		               d_ctb05m03.empsgl               
		if l_ret <> 1 then                             
		  #erro ao buscar descricao                   
		  error l_mensagem                            
		  next field empcod                        
		end if                                         
	   else
	   	let d_ctb05m03.empsgl = "TODAS"
	   end if
	   display by name d_ctb05m03.empsgl 
	 ############################
      
      	
      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   if d_ctb05m03.tipdat  =  1   then
      let ws.condicao =  " where socfatentdat between ? and ?"
   else
      let ws.condicao =  " where socfatpgtdat between ? and ?"
   end if
   let ws.condicao = ws.condicao clipped, " and soctip = 3 "

   ######[Alterado Robert]
   if d_ctb05m03.empcod is not null then
      let ws.condicao = ws.condicao clipped, " and empcod = ", d_ctb05m03.empcod
   end if
   #######################
   
   
   let ws.qtdopg = 0
   let ws.qtdsrv = 0
   let ws.socopgitmcst = 0.00
   let ws.opgvlr = 0.00

   set isolation to dirty read

   let ws.comando  = "select count(*), sum(socopgitmvlr)",
                   "  from dbsmopgitm, dbsmopg ",
                   ws.condicao  clipped,
                   "   and socopgsitcod = ?",
                   "   and dbsmopgitm.socopgnum = dbsmopg.socopgnum"
   prepare sel_dbsmopgitm from ws.comando 
   declare c_dbsmopgitm cursor for sel_dbsmopgitm

   #if d_ctb05m03.tipdat  =  1   then   
   #   let ws.comando = "select sum(cst.socopgitmcst)",
   #		   " from dbsmopgcst cst, dbsmopg opg",
   #		   " where cst.socopgnum = opg.socopgnum",
   #		   " and opg.socfatentdat between ? and ?",
   #		   " and socopgsitcod = ?",
   #		   " and empcod = ?",
   #		   " and soctip = 3"
   #else
      let ws.comando  = "select sum(cst.socopgitmcst)",
   		   " from dbsmopgcst cst, dbsmopg opg",
   		   #" and opg.socfatpgtdat between ? and ?",
   		   ws.condicao  clipped,
   		   " and cst.socopgnum = opg.socopgnum",
   		   " and socopgsitcod = ?",
   		   " and soctip = 3"
   #end if
   display ws.comando
   prepare sel_dbsmopgcst from ws.comando 
   declare c_dbsmopgcst cursor for sel_dbsmopgcst


   let ws.comando  = "select socopgsitcod, count(*)",
                   "  from dbsmopg ",
                   ws.condicao  clipped,
                   " group by socopgsitcod ",
                   " order by socopgsitcod "
   prepare sel_dbsmopg from ws.comando 
   declare c_ctb05m03 cursor for sel_dbsmopg

   message " Aguarde, pesquisando..."  attribute(reverse)

   open    c_ctb05m03 using d_ctb05m03.data, d_ctb05m03.data2

   foreach c_ctb05m03 into  ws.socopgsitcod,
                            a_ctb05m03[arr_aux].qtdopg

      initialize a_ctb05m03[arr_aux].socopgsitdes  to null
      let ws.cponom = "socopgsitcod"
      open  c_iddkdominio using ws.cponom,
                                ws.socopgsitcod
      fetch c_iddkdominio into  a_ctb05m03[arr_aux].socopgsitdes

      if sqlca.sqlcode <> 0   then
         error "Erro (", sqlca.sqlcode, ") na leitura da descricao da situacao!"
      end if

      close c_iddkdominio

      open  c_dbsmopgitm using d_ctb05m03.data, d_ctb05m03.data2,
                               ws.socopgsitcod
      fetch c_dbsmopgitm into  a_ctb05m03[arr_aux].qtdsrv,
                               a_ctb05m03[arr_aux].opgvlr
      close c_dbsmopgitm

      open  c_dbsmopgcst using d_ctb05m03.data, d_ctb05m03.data2,
                               ws.socopgsitcod

      fetch c_dbsmopgcst into  a_ctb05m03[arr_aux].socopgitmcst

      close c_dbsmopgcst


      if a_ctb05m03[arr_aux].qtdsrv is null  then
         let a_ctb05m03[arr_aux].qtdsrv = 0
      end if

      if a_ctb05m03[arr_aux].socopgitmcst is null  then
         let a_ctb05m03[arr_aux].socopgitmcst = 0.00
      end if

      if a_ctb05m03[arr_aux].opgvlr is null  then
         let a_ctb05m03[arr_aux].opgvlr = 0.00
      end if

      let ws.qtdopg = ws.qtdopg + a_ctb05m03[arr_aux].qtdopg
      let ws.qtdsrv = ws.qtdsrv + a_ctb05m03[arr_aux].qtdsrv
      let ws.socopgitmcst = ws.socopgitmcst + a_ctb05m03[arr_aux].socopgitmcst
      let ws.opgvlr = ws.opgvlr + a_ctb05m03[arr_aux].opgvlr

      let arr_aux = arr_aux + 1
      if arr_aux > 12  then
         error "Limite excedido! Foram encontradas mais de 12 situacoes!"
         exit foreach
      end if
   end foreach

   if arr_aux > 1  then
      let arr_aux = arr_aux + 1

      let a_ctb05m03[arr_aux].socopgsitdes = "TOTAL GERAL"
      let a_ctb05m03[arr_aux].qtdopg       = ws.qtdopg
      let a_ctb05m03[arr_aux].qtdsrv       = ws.qtdsrv
      let a_ctb05m03[arr_aux].socopgitmcst = ws.socopgitmcst
      let a_ctb05m03[arr_aux].opgvlr       = ws.opgvlr

      message " (F17)Abandona "

      call set_count(arr_aux)

      display array  a_ctb05m03 to s_ctb05m03.*
         on key(interrupt)
            exit display
      end display

      for scr_aux = 1 to 10
          clear s_ctb05m03[scr_aux].*
      end for
   else
      error " Nao foi encontrada nenhuma O.P. para data informada! "
   end if

end while

let int_flag = false
close window ctb05m03

end function  ###  ctb05m03
