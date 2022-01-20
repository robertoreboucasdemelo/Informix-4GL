###############################################################################
# Nome do Modulo: CTB03m02                                           Wagner   #
#                                                                             #
# Consulta ordem de pagamento por datas (pagto/entrega) e Locadora   Mai/2001 #
###############################################################################
###############################################################################
# 08/12/2005	Cristiane Silva		PSI		Inclusao de coluna de #
#							valores adicionais    #
#----------------------------------------------------------------------------# 
# 18/07/06   Junior, Meta  AS112372      Migracao de versao do 4gl.          # 
#----------------------------------------------------------------------------# 

database porto
#-----------------------------------------------------------
 function ctb03m02()
#-----------------------------------------------------------

 define d_ctb03m02  record
    tipdat          dec(1,0),
    tipdatdes       char(09),
    data            date,
    data2	    date,
    ciaempcod       like datmservico.ciaempcod,
    empsgl          like gabkemp.empsgl
 end record

 define a_ctb03m02 array[12] of record
    socopgsitdes    char(40),
    qtdopg          dec(4,0),
    qtdsrv          dec(8,0),
    socopgitmcst    dec(15,2),
    opgvlr          dec(15,2)
 end record

 define ws          record
    seleciona       char(800),
    condicao        char(500),
    socopgsitcod    like dbsmopg.socopgsitcod,
    qtdopg          dec(4,0),
    qtdsrv          dec(8,0),
    socopgitmcst    like dbsmopgcst.socopgitmcst,
    opgvlr          dec(15,2),
    cponom          like iddkdominio.cponom,
    cpodat          char(20)
 end record

 define arr_aux     smallint,
        scr_aux     smallint,
        l_retorno   integer,
        l_mensagem  char(100)


 initialize d_ctb03m02.*    to null
 initialize ws.*            to null

 let ws.seleciona =  "select cpodes     ",
                 "  from iddkdominio",
                 " where cponom  = ? ",
                 "   and cpocod  = ? "
 prepare sel_iddkdominio from ws.seleciona 
 declare c_iddkdominio cursor for sel_iddkdominio

 open window ctb03m02 at 06,02 with form "ctb03m02"
             attribute (form line first)

 while true

   let int_flag = false
   initialize a_ctb03m02  to null
   let arr_aux  = 1

   input by name d_ctb03m02.tipdat,
                 d_ctb03m02.data,
                 d_ctb03m02.data2,
                 d_ctb03m02.ciaempcod  without defaults

      before field tipdat
             display by name d_ctb03m02.tipdat    attribute (reverse)

      after  field tipdat
             display by name d_ctb03m02.tipdat

             if d_ctb03m02.tipdat is null  then
                error " Tipo deve ser: 1-Entrega, 2-Pagamento"
                next field tipdat
             end if

             case d_ctb03m02.tipdat
                when  1   let d_ctb03m02.tipdatdes = "ENTREGA"
                when  2   let d_ctb03m02.tipdatdes = "PAGAMENTO"
                otherwise error " Tipo deve ser: 1-Entrega, 2-Pagamento"
                          next field tipdat
             end case
             display by name d_ctb03m02.tipdatdes

      before field data
             display by name d_ctb03m02.data      attribute (reverse)

      after  field data
             if d_ctb03m02.data  is null   then
                let d_ctb03m02.data = today
             end if
             display by name d_ctb03m02.data

      before field data2
             display by name d_ctb03m02.data2     attribute (reverse)

      after  field data2
             if d_ctb03m02.data2  is null   then
                let d_ctb03m02.data2 = today
             end if
             display by name d_ctb03m02.data2

             if d_ctb03m02.data2 - d_ctb03m02.data > 30 then
             	error "Período informado nao pode ser superior a 30 dias"
             	next field data2
             end if

      before field ciaempcod
           display by name d_ctb03m02.ciaempcod attribute (reverse)
           
      after field ciaempcod
           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field data2
           end if   
           if d_ctb03m02.ciaempcod is null then
              let d_ctb03m02.empsgl = "TODAS"
           else
              #------------------------------------------------------------------
              # Busca descrição da empresa
              #------------------------------------------------------------------
              call cty14g00_empresa(1, d_ctb03m02.ciaempcod)
                   returning l_retorno,
                             l_mensagem,
                             d_ctb03m02.empsgl
           end if                  
           display by name d_ctb03m02.ciaempcod attribute (reverse)
           display by name d_ctb03m02.empsgl attribute (reverse)

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   if d_ctb03m02.tipdat  =  1   then
      let ws.cpodat = "socfatentdat"
   else
      let ws.cpodat = "socfatpgtdat"
   end if

   let ws.condicao =  " where ", ws.cpodat clipped, " between ? and ? and soctip = 2"
   
   if d_ctb03m02.ciaempcod is not null then
      let ws.condicao = ws.condicao clipped, " and ", d_ctb03m02.ciaempcod using "<<<<#",
          " = (select srv.ciaempcod" ,
               " from datmservico srv, dbsmopgitm itm",
              " where itm.socopgnum = opg.socopgnum",
                " and srv.atdsrvnum = itm.atdsrvnum",
                " and srv.atdsrvano = itm.atdsrvano",
                " and itm.socopgitmnum = (select min(itmmin.socopgitmnum)",
                                          " from dbsmopgitm itmmin",
                                         " where itmmin.socopgnum = opg.socopgnum))"
   end if

   let ws.qtdopg = 0
   let ws.qtdsrv = 0
   let ws.socopgitmcst = 0.00
   let ws.opgvlr = 0.00

   set isolation to dirty read

   let ws.seleciona  = "select count(*), sum(socopgitmvlr)",
                   "  from dbsmopgitm itm, dbsmopg opg",
                   ws.condicao  clipped,
                   "   and opg.socopgsitcod = ?",
                   "   and opg.socopgnum = itm.socopgnum"
   prepare sel_dbsmopgitm from ws.seleciona 
   declare c_dbsmopgitm cursor for sel_dbsmopgitm

   let ws.seleciona  = "select sum(cst.socopgitmcst)",
 	   " from dbsmopgcst cst, dbsmopg opg",
 	   ws.condicao  clipped,
 	   " and cst.socopgnum = opg.socopgnum",
 	   " and socopgsitcod = ?"
   prepare sel_dbsmopgcst from ws.seleciona 
   declare c_dbsmopgcst cursor for sel_dbsmopgcst

   let ws.seleciona  = "select socopgsitcod, count(*)",
                   "  from dbsmopg opg ",
                   ws.condicao  clipped,
                   " group by opg.socopgsitcod ",
                   " order by opg.socopgsitcod "
   prepare sel_dbsmopg from ws.seleciona 
   declare c_ctb03m02 cursor for sel_dbsmopg

   message " Aguarde, pesquisando..."  attribute(reverse)

   open    c_ctb03m02 using d_ctb03m02.data, d_ctb03m02.data2

   foreach c_ctb03m02 into  ws.socopgsitcod,
                            a_ctb03m02[arr_aux].qtdopg

      initialize a_ctb03m02[arr_aux].socopgsitdes  to null
      let ws.cponom = "socopgsitcod"
      open  c_iddkdominio using ws.cponom,
                                ws.socopgsitcod
      fetch c_iddkdominio into  a_ctb03m02[arr_aux].socopgsitdes

      if sqlca.sqlcode <> 0   then
         error "Erro (", sqlca.sqlcode, ") na leitura da descricao da situacao!"
      end if

      close c_iddkdominio

      open  c_dbsmopgitm using d_ctb03m02.data, d_ctb03m02.data2,
                               ws.socopgsitcod
      fetch c_dbsmopgitm into  a_ctb03m02[arr_aux].qtdsrv,
                               a_ctb03m02[arr_aux].opgvlr
      close c_dbsmopgitm

      open  c_dbsmopgcst using d_ctb03m02.data, d_ctb03m02.data2,
                               ws.socopgsitcod

      fetch c_dbsmopgcst into  a_ctb03m02[arr_aux].socopgitmcst

      close c_dbsmopgcst


      if a_ctb03m02[arr_aux].qtdsrv is null  then
         let a_ctb03m02[arr_aux].qtdsrv = 0
      end if

      if a_ctb03m02[arr_aux].socopgitmcst is null  then
         let a_ctb03m02[arr_aux].socopgitmcst = 0.00
      end if

      if a_ctb03m02[arr_aux].opgvlr is null  then
         let a_ctb03m02[arr_aux].opgvlr = 0.00
      end if

      let ws.qtdopg = ws.qtdopg + a_ctb03m02[arr_aux].qtdopg
      let ws.qtdsrv = ws.qtdsrv + a_ctb03m02[arr_aux].qtdsrv
      let ws.socopgitmcst = ws.socopgitmcst + a_ctb03m02[arr_aux].socopgitmcst
      let ws.opgvlr = ws.opgvlr + a_ctb03m02[arr_aux].opgvlr

      let arr_aux = arr_aux + 1
      if arr_aux > 12  then
         error "Limite excedido! Foram encontradas mais de 12 situacoes!"
         exit foreach
      end if
   end foreach

   if arr_aux > 1  then
      let arr_aux = arr_aux + 1

      let a_ctb03m02[arr_aux].socopgsitdes = "TOTAL GERAL"
      let a_ctb03m02[arr_aux].qtdopg       = ws.qtdopg
      let a_ctb03m02[arr_aux].qtdsrv       = ws.qtdsrv
      let a_ctb03m02[arr_aux].socopgitmcst = ws.socopgitmcst
      let a_ctb03m02[arr_aux].opgvlr       = ws.opgvlr

      message " (F17)Abandona "

      call set_count(arr_aux)

      display array  a_ctb03m02 to s_ctb03m02.*
         on key(interrupt)
            exit display
      end display

      for scr_aux = 1 to 11
          clear s_ctb03m02[scr_aux].*
      end for
   else
      error " Nao foi encontrada nenhuma O.P. para data informada! "
   end if

end while

let int_flag = false
close window ctb03m02

end function  ###  ctb03m02
