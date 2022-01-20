#############################################################################
# Nome do Modulo: CTB11M00                                          Marcelo #
#                                                                  Gilberto #
# Protocolo da ordem de pagamento - Porto Socorro                  Dez/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 18/07/1999  Via correio  Gilberto     Alterar prazo para pagamento de 20  #
#                                       para 30 dias.                       #
#---------------------------------------------------------------------------#
# 22/09/1999  Via correio  Gilberto     Nao permitir alteracao da data de   #
#                                       entrega.                            #
#---------------------------------------------------------------------------#
# 13/12/1999  PSI 9637-7   Wagner       Incluir a atualizacao do campo      #
#                                       socopgorgcod como 1 na digitacao OP #
#---------------------------------------------------------------------------#
# 10/11/2000  PSI 10631-3  Wagner       Incluir gravacao/pesquisa do campo  #
#                                       soctip (tipo de op).                #
#---------------------------------------------------------------------------#
# 04/06/2001  PSI 13253-5  Wagner       Inclusao nova situacao prestador    #
#                                       B-Bloqueado.                        #
#---------------------------------------------------------------------------#
# 22/08/2003  PSI 172332   Ale Souza    Critica automatica  por numero de   #
#             OSF 24740                 Nota Fiscal.                        #
#---------------------------------------------------------------------------#
# 18/07/2006  PSI 197858  Cristiane Silva  Subtrair do valor total os des-  #
#					   			   contos, se houver.               #
#---------------------------------------------------------------------------#
# 29/12/2006 Priscila Staingel PSI205206 Exibir se a OP é da Azul ou Porto  #
#                                        sendo q todos os itens da OP devem #
#                                        ser da mesma empresa               #
#---------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel  #
# 27/05/2009  PSI 198404   Fabio Costa  Impedir edicao de OP com status 10  #
#                                       e 11, digitacao da NF apos os itens #
# 26/04/2010  PSI 198404   Fabio Costa  Tratar reembolso segurado Azul, tipo#
#                                       favorecido, NFS na OP, verific. NFS #
#############################################################################
#database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_dominio record
       erro      smallint  ,
       mensagem  char(100) ,
       cpodes    like iddkdominio.cpodes
end record

#------------------------------------------------------------
function ctb11m00()
#------------------------------------------------------------

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define l_pstcoddig like dbsmopg.pstcoddig
   define l_qldgracod like dpaksocor.qldgracod
 
   let l_pstcoddig = null
   let l_qldgracod = null
   
   if not get_niv_mod(g_issk.prgsgl, "ctb11m00") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   let int_flag = false

   initialize ctb11m00.*   to  null
   initialize k_ctb11m00.* to  null
   
   let l_pstcoddig = 0

   open window ctb11m00 at 04,02 with form "ctb11m00"

   menu "PROTOCOLO"

       before menu
          hide option all
          if  g_issk.acsnivcod >= g_issk.acsnivcns  then        # NIVEL 1
                show option "Seleciona", "Proximo", "Anterior", "enVia OP"
          end if
          if  g_issk.acsnivcod >= g_issk.acsnivatl  then        # NIVEL 5
                show option "Seleciona", "Proximo", "Anterior",
                            "Modifica", "Inclui", "enVia OP"
          end if
          if  g_issk.acsnivcod  = 8   then                      # NIVEL 8
                show option "Remove"
          end if
          show option "Encerra"

   command "Seleciona" "Pesquisa protocolo conforme criterios"
            call seleciona_ctb11m00() returning k_ctb11m00.*, ctb11m00.*
            if k_ctb11m00.socopgnum is not null  then
               message ""
               next option "Proximo"
            else
               error " Nenhum protocolo selecionado!"
               message ""
               next option "Seleciona"
            end if

   command "Proximo" "Mostra proxima protocolo selecionado"
            message ""
            if k_ctb11m00.socopgnum is not null then
               call proximo_ctb11m00(k_ctb11m00.*)
                    returning k_ctb11m00.*, ctb11m00.*
            else
               error " Nenhum protocolo nesta direcao!"
               next option "Seleciona"
            end if

   command "Anterior" "Mostra protocolo anterior selecionado"
            message ""
            if k_ctb11m00.socopgnum is not null then
               call anterior_ctb11m00(k_ctb11m00.*)
                    returning k_ctb11m00.*, ctb11m00.*
            else
               error " Nenhum protocolo nesta direcao!"
               next option "Seleciona"
            end if

   command "Modifica" "Modifica protocolo corrente selecionado"
            message ""
            if k_ctb11m00.socopgnum  is not null
               then
               if ctb11m00.socopgsitcod  <>  7   and  #-> EMITIDA
                  ctb11m00.socopgsitcod  <>  8   and  #-> CANCELADA
                  ctb11m00.socopgsitcod  <>  10  and  #-> aguard emissao People
                  ctb11m00.socopgsitcod  <>  11       #-> aguard cancel People
                  then
                  if ctb11m00.socopgsitcod  >  1   and   #-> PASSOU FASE PROT.
                     g_issk.acsnivcod       <  6
                     then
                     error " Nivel de acesso nao permite alteracao!"
                  else
                     call modifica_ctb11m00(k_ctb11m00.*, ctb11m00.*)
                          returning k_ctb11m00.*
                     next option "Seleciona"
                  end if
               else
                  error " Ordem de pagamento nao deve ser alterada!"
               end if
            else
               error " Nenhum protocolo selecionado!"
               next option "Seleciona"
            end if

   command "Remove" "Remove protocolo corrente selecionado"
            message ""
            if k_ctb11m00.socopgnum is not null then
               call remove_ctb11m00(k_ctb11m00.*)
                    returning k_ctb11m00.*
               next option "Seleciona"
            else
               error " Nenhum protocolo selecionado!"
               next option "Seleciona"
            end if

   command "Inclui" "Inclui protocolo"
            message ""
            call inclui_ctb11m00()
            next option "Seleciona"

   command key ("V") "enVia OP" "Envia OP para Prestador"
       message ""
       if k_ctb11m00.socopgnum is not null then
       		
       		whenever error continue
	       	 
		       	  select pstcoddig
		              	into l_pstcoddig
		          	from dbsmopg
		          	where socopgnum = k_ctb11m00.socopgnum
		
			select qldgracod into l_qldgracod
			  	from dpaksocor      
			  	where pstcoddig = l_pstcoddig	    
		
		whenever error stop  
	  
	  if l_qldgracod <> 1 then
	          call ctb11m17(k_ctb11m00.socopgnum,l_pstcoddig,'E','O')
	   else
	   	error " Nao e possivel enviar a OP!"
          	next option "Seleciona"
          end if
       else
          error " Nenhuma ordem de pagamento selecionada!"
          next option "Seleciona"
       end if
       
   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
            exit menu
   end menu

   close window ctb11m00

end function  ###  ctb11m00

#------------------------------------------------------------
function seleciona_ctb11m00()
#------------------------------------------------------------

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   clear form
   let int_flag = false
   initialize  ctb11m00.*  to null

   input by name k_ctb11m00.socopgnum

      before field socopgnum
          display by name k_ctb11m00.socopgnum attribute (reverse)

          if k_ctb11m00.socopgnum is null then
             let k_ctb11m00.socopgnum = 0
          end if

      after  field socopgnum
          display by name k_ctb11m00.socopgnum

      on key (interrupt)
          exit input
   end input

   if int_flag  then
      let int_flag = false
      initialize ctb11m00.*   to null
      initialize k_ctb11m00.* to null
      error " Operacao cancelada!"
      clear form
      return k_ctb11m00.*, ctb11m00.*
   end if

   if k_ctb11m00.socopgnum  =  0   then
      select min (dbsmopg.socopgnum)
        into k_ctb11m00.socopgnum
        from dbsmopg
       where socopgnum > k_ctb11m00.socopgnum
         and soctip    = 1

      display by name k_ctb11m00.socopgnum
   end if

   call ler_ctb11m00(k_ctb11m00.*)  returning  ctb11m00.*

   if ctb11m00.socopgnum  is not null
      then
      display by name ctb11m00.socopgnum    ,
                      ctb11m00.socopgsitcod ,
                      ctb11m00.socopgsitdes ,
                      ctb11m00.favtip       ,
                      ctb11m00.favtipdes    ,
                      ctb11m00.soctrfcod    ,
                      ctb11m00.soctrfdes    ,
                      ctb11m00.pstcoddig    ,
                      ctb11m00.nomrazsoc    ,
                      ctb11m00.corsus       ,
                      ctb11m00.cornom       ,
                      ctb11m00.segnumdig    ,
                      ctb11m00.segnom       ,
                      ctb11m00.pestip       ,
                      ctb11m00.cgccpfnum    ,
                      ctb11m00.cgcord       ,
                      ctb11m00.cgccpfdig    ,
                      ctb11m00.socpgtdoctip ,
                      ctb11m00.socpgtdocdes ,
                      ctb11m00.nfsnum       ,
                      ctb11m00.socfatentdat ,
                      ctb11m00.socfatpgtdat ,
                      ctb11m00.socfatitmqtd ,
                      ctb11m00.socfattotvlr ,
                      ctb11m00.socfatrelqtd ,
                      ctb11m00.linhamsg     ,
                      ctb11m00.empcod       ,
                      ctb11m00.empnom        
          
      display by name  ctb11m00.empresa  attribute(reverse)  #PSI 205206
   else
      error " Protocolo nao cadastrado!"
      initialize ctb11m00.*    to null
      initialize k_ctb11m00.*  to null
   end if

   return k_ctb11m00.*, ctb11m00.*

end function  ###  seleciona_ctb11m00

#------------------------------------------------------------
function proximo_ctb11m00(k_ctb11m00)
#------------------------------------------------------------

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   initialize ctb11m00.*   to null

   select min (dbsmopg.socopgnum)
     into ctb11m00.socopgnum
     from dbsmopg
    where socopgnum > k_ctb11m00.socopgnum
      and soctip    = 1

   if ctb11m00.socopgnum  is not null   then
      let k_ctb11m00.socopgnum = ctb11m00.socopgnum
      call ler_ctb11m00(k_ctb11m00.*)  returning  ctb11m00.*

      if ctb11m00.socopgnum  is not null
         then
         display by name ctb11m00.socopgnum    ,
                         ctb11m00.socopgsitcod ,
                         ctb11m00.socopgsitdes ,
                         ctb11m00.favtip       ,
                         ctb11m00.favtipdes    ,
                         ctb11m00.soctrfcod    ,
                         ctb11m00.soctrfdes    ,
                         ctb11m00.pstcoddig    ,
                         ctb11m00.nomrazsoc    ,
                         ctb11m00.corsus       ,
                         ctb11m00.cornom       ,
                         ctb11m00.segnumdig    ,
                         ctb11m00.segnom       ,
                         ctb11m00.pestip       ,
                         ctb11m00.cgccpfnum    ,
                         ctb11m00.cgcord       ,
                         ctb11m00.cgccpfdig    ,
                         ctb11m00.socpgtdoctip ,
                         ctb11m00.socpgtdocdes ,
                         ctb11m00.nfsnum       ,
                         ctb11m00.socfatentdat ,
                         ctb11m00.socfatpgtdat ,
                         ctb11m00.socfatitmqtd ,
                         ctb11m00.socfattotvlr ,
                         ctb11m00.socfatrelqtd ,
                         ctb11m00.linhamsg     ,
                         ctb11m00.empcod       ,
                         ctb11m00.empnom        
                      
         display by name  ctb11m00.empresa  attribute(reverse)  #PSI 205206
      else
         error " Nao ha' protocolo nesta direcao!"
         initialize ctb11m00.*    to null
         initialize k_ctb11m00.*  to null
      end if
   else
      error " Nao ha' protocolo nesta direcao!"
      initialize ctb11m00.*    to null
      initialize k_ctb11m00.*  to null
   end if

   return k_ctb11m00.*, ctb11m00.*

end function  ###  proximo_ctb11m00

#------------------------------------------------------------
function anterior_ctb11m00(k_ctb11m00)
#------------------------------------------------------------

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   let int_flag = false
   initialize ctb11m00.*  to null

   select max (dbsmopg.socopgnum)
     into ctb11m00.socopgnum
     from dbsmopg
    where socopgnum < k_ctb11m00.socopgnum
      and soctip    = 1

   if ctb11m00.socopgnum  is  not  null  then
      let k_ctb11m00.socopgnum = ctb11m00.socopgnum
      call ler_ctb11m00(k_ctb11m00.*)  returning  ctb11m00.*

      if ctb11m00.socopgnum  is not null
         then
         display by name ctb11m00.socopgnum    ,
                         ctb11m00.socopgsitcod ,
                         ctb11m00.socopgsitdes ,
                         ctb11m00.favtip       ,
                         ctb11m00.favtipdes    ,
                         ctb11m00.soctrfcod    ,
                         ctb11m00.soctrfdes    ,
                         ctb11m00.pstcoddig    ,
                         ctb11m00.nomrazsoc    ,
                         ctb11m00.corsus       ,
                         ctb11m00.cornom       ,
                         ctb11m00.segnumdig    ,
                         ctb11m00.segnom       ,
                         ctb11m00.pestip       ,
                         ctb11m00.cgccpfnum    ,
                         ctb11m00.cgcord       ,
                         ctb11m00.cgccpfdig    ,
                         ctb11m00.socpgtdoctip ,
                         ctb11m00.socpgtdocdes ,
                         ctb11m00.nfsnum       ,
                         ctb11m00.socfatentdat ,
                         ctb11m00.socfatpgtdat ,
                         ctb11m00.socfatitmqtd ,
                         ctb11m00.socfattotvlr ,
                         ctb11m00.socfatrelqtd ,
                         ctb11m00.linhamsg     ,
                         ctb11m00.empcod       ,
                         ctb11m00.empnom        
                      
         display by name  ctb11m00.empresa  attribute(reverse)  #PSI 205206
      else
         error " Nao ha' protocolo nesta direcao!"
         initialize ctb11m00.*    to null
         initialize k_ctb11m00.*  to null
      end if
   else
      error " Nao ha' protocolo nesta direcao!"
      initialize ctb11m00.*    to null
      initialize k_ctb11m00.*  to null
   end if

   return k_ctb11m00.*, ctb11m00.*

end function  ###  anterior_ctb11m00

#------------------------------------------------------------
function modifica_ctb11m00(k_ctb11m00, ctb11m00)
#------------------------------------------------------------

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ws           record
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          soctip       like dbsmopg.soctip
   end record
   
   define lr_retorno record
          retorno   smallint,      
          mensagem  char(60)         
   end record
   
   define l_sqlca   integer ,
          l_sqlerr  integer
          
   call input_ctb11m00("a", k_ctb11m00.* , ctb11m00.*) returning ctb11m00.*

   if int_flag  then
      let int_flag = false
      initialize k_ctb11m00.*  to null
      initialize ctb11m00.*    to null
      error " Operacao cancelada!"
      clear form
      return k_ctb11m00.*
   end if

   initialize ws.*   to null
   initialize lr_retorno.* to null

   select socfatitmqtd   , socfattotvlr   , soctip
     into ws.socfatitmqtd, ws.socfattotvlr, ws.soctip
     from dbsmopg
    where socopgnum = k_ctb11m00.socopgnum
    
    
   whenever error continue
   
   begin work
      update dbsmopg  set (pstcoddig,
                           corsus,
                           segnumdig,
                           pestip,
                           cgccpfnum,
                           cgcord,
                           cgccpfdig,
                           socfatentdat,
                           socfatpgtdat,
                           socfatitmqtd,
                           socfattotvlr,
                           socfatrelqtd,
                           soctrfcod,
                           atldat,
                           funmat,
                           socpgtdoctip,
                           favtip,
                           nfsnum,
                           empcod)
                       =  (ctb11m00.pstcoddig,
                           ctb11m00.corsus,
                           ctb11m00.segnumdig,
                           ctb11m00.pestip,
                           ctb11m00.cgccpfnum,
                           ctb11m00.cgcord,
                           ctb11m00.cgccpfdig,
                           ctb11m00.socfatentdat,
                           ctb11m00.socfatpgtdat,
                           ctb11m00.socfatitmqtd,
                           ctb11m00.socfattotvlr,
                           ctb11m00.socfatrelqtd,
                           ctb11m00.soctrfcod,
                           today,
                           g_issk.funmat,
                           ctb11m00.socpgtdoctip,
                           ctb11m00.favtip,
                           ctb11m00.nfsnum,
                           ctb11m00.empcod)
      where socopgnum  =  k_ctb11m00.socopgnum
      
      whenever error stop
      
      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteração da protocolo!"
         rollback work
         initialize ctb11m00.*   to null
         initialize k_ctb11m00.* to null
         return k_ctb11m00.*
      # else
      #    error " Alteracao efetuada com sucesso!"
      end if
      
      # update NFSNUM nos itens das OP
      if ctb11m00.nfsnum is not null and
         ctb11m00.nfsnum > 0
         then
         
         call ctd20g01_upd_nfs_opgitm(k_ctb11m00.socopgnum,
                                      ctb11m00.socopgsitcod,
                                      ctb11m00.nfsnum)
              returning l_sqlca, l_sqlerr
              
         if l_sqlca != 0
            then
            if l_sqlca != 100
               then
               if l_sqlca = 99
                  then
                  error " Não permitido alterar Documento Fiscal nesta OP "
                  sleep 2
               else
                  error " Erro na atualização do Documento Fiscal ", l_sqlca
                  rollback work
                  initialize ctb11m00.*   to null
                  initialize k_ctb11m00.* to null
                  return k_ctb11m00.*
               end if
            end if
         else
            if sqlca.sqlerrd[3] = 0
               then
               error " OP ainda não possui itens, Documento Fiscal gravado na OP "
               sleep 1
            else
               error " Atualização do Documento Fiscal ok em ", l_sqlerr, " itens"
               sleep 1
               
               # num de NF gravado nos itens, atualiza etapa para "Digitada"
               call cts50g00_atualiza_etapa(k_ctb11m00.socopgnum, 3, 
                                            g_issk.funmat)
                                  returning lr_retorno.retorno,
                                            lr_retorno.mensagem
                                            
               if lr_retorno.retorno != 1
                  then
                  error lr_retorno.mensagem
                  sleep 2
                  rollback work
                  initialize ctb11m00.*   to null
                  initialize k_ctb11m00.* to null
                  return k_ctb11m00.*
               end if
            end if
         end if
      end if
      
   commit work
   error " Alteracao efetuada com sucesso!"
   sleep 1
   
   #---------------------------------------------------
   # Se houver alteracao na qtde/valor fazer batimento
   #---------------------------------------------------
   if ctb11m00.socfatitmqtd <> ws.socfatitmqtd   or
      ctb11m00.socfattotvlr <> ws.socfattotvlr 
      then
      call ctb11m09(k_ctb11m00.socopgnum, "ctb11m00", 
                    ctb11m00.pstcoddig, ctb11m00.pestip, ctb11m00.segnumdig)
   end if

   clear form
   message ""
   return k_ctb11m00.*

end function  ###  modifica_ctb11m00

#------------------------------------------------------------
function inclui_ctb11m00()
#------------------------------------------------------------

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record
   
   define lr_retorno record
                         retorno   smallint,      
                         mensagem  char(60)         
                     end record    

   define ws           record
          time         char(08),
          hora         char(05)
   end record

   define prompt_key   char (01)

   clear form

   initialize ctb11m00.*   to null
   initialize k_ctb11m00.* to null
   initialize ws.*         to null

   call input_ctb11m00("i",k_ctb11m00.*, ctb11m00.*) returning ctb11m00.*

   if int_flag  then
      let int_flag = false
      initialize ctb11m00.*  to null
      error " Operacao cancelada!"
      clear form
      return
   end if

   declare c_ctb11m00m  cursor with hold  for
      select max(socopgnum)
        from dbsmopg
       where socopgnum > 0

   foreach c_ctb11m00m  into  ctb11m00.socopgnum
       exit foreach
   end foreach

   if ctb11m00.socopgnum is null   then
      let ctb11m00.socopgnum = 0
   end if
   let ctb11m00.socopgnum = ctb11m00.socopgnum + 1
   let ws.time = time
   let ws.hora = ws.time[1,5]

   whenever error continue

   begin work
      insert into dbsmopg (socopgnum,
                           socopgsitcod,
                           pstcoddig,
                           corsus,
                           segnumdig,
                           pestip,
                           cgccpfnum,
                           cgcord,
                           cgccpfdig,
                           socfatentdat,
                           socfatpgtdat,
                           socfatitmqtd,
                           socfattotvlr,
                           socfatrelqtd,
                           soctrfcod,
                           socopgorgcod,
                           atldat,
                           funmat,
                           soctip,
                           favtip,
                           nfsnum,
                           empcod,
                           socpgtdoctip)
                  values  (ctb11m00.socopgnum,
                           ctb11m00.socopgsitcod,
                           ctb11m00.pstcoddig,
                           ctb11m00.corsus,
                           ctb11m00.segnumdig,
                           ctb11m00.pestip,
                           ctb11m00.cgccpfnum,
                           ctb11m00.cgcord,
                           ctb11m00.cgccpfdig,
                           ctb11m00.socfatentdat,
                           ctb11m00.socfatpgtdat,
                           ctb11m00.socfatitmqtd,
                           ctb11m00.socfattotvlr,
                           ctb11m00.socfatrelqtd,
                           ctb11m00.soctrfcod,
                           1 ,
                           today, g_issk.funmat,
                           1 ,
                           ctb11m00.favtip,
                           ctb11m00.nfsnum,
                           ctb11m00.empcod,
                           ctb11m00.socpgtdoctip)

      if sqlca.sqlcode <>  0   then
         error " Erro (",sqlca.sqlcode,") na inclusao do protocolo!"
         rollback work
         return
      end if

      # PSI 221074 - BURINI
      call cts50g00_insere_etapa(ctb11m00.socopgnum, 1, g_issk.funmat)
           returning lr_retorno.retorno, lr_retorno.mensagem

      if lr_retorno.retorno <>  1   then
         error lr_retorno.mensagem
         rollback work
         return
      end if

   commit work

   whenever error stop

   display by name ctb11m00.socopgnum attribute (reverse)
   error " Verifique o codigo do protocolo e tecle ENTER!"
   prompt "" for char prompt_key
   
   error " Inclusao efetuada com sucesso!"
   sleep 1
   
   error "Digite o numero do Documento Fiscal na OP apos a digitacao dos itens"
   sleep 1
   
   clear form

end function  ###  inclui_ctb11m00

#--------------------------------------------------------------------
function input_ctb11m00(operacao_aux, k_ctb11m00, ctb11m00)
#--------------------------------------------------------------------

   define operacao_aux char (01)

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ws           record
          favtipsva    smallint,
          socopgnum    like dbsmopg.socopgnum,
          pstcoddig    like dbsmopg.pstcoddig,
          prssitcod    like dpaksocor.prssitcod,
          diasem       smallint,
          dataini      date,
          datafim      date,
          mensagem     char (40),
          confirma     char (01),
          cgccpfdig    like dbsmopg.cgccpfdig,
          pestipcad    like dbsmopg.pestip,
          cgccpfnumcad like dbsmopg.cgccpfnum,
          cgccpfdigcad like dbsmopg.cgccpfdig,
          socopgdscvlr like dbsmopg.socopgdscvlr,
          confirma2    char (01)
   end record

   define lr_ctc00m15 record
       empcod       like dparpstsrvprc.empcod,
       atdsrvorg    like dparpstsrvprc.atdsrvorg,
       asitipcod    like dparpstsrvprc.asitipcod,
       dattrfvig    date
   end record

   define lr_erro record
        err     smallint,
        msgerr  char(100)
   end record

   define lr_seg_ita record 
        segnom   like datmitaapl.segnom,
        errocod  smallint,
        erromsg  char(80)
   end record 

   define l_soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum

   define l_ret         char (01),
          l_res         smallint,
          l_msg         char(80)

   let int_flag    = false
   let ws.confirma = "n"
   let l_ret       = null
   initialize ws.*   to null
   initialize lr_seg_ita.* to null
   let l_res = null 
   let l_msg = null 

   input by name ctb11m00.socopgnum,
                 ctb11m00.favtip,
                 ctb11m00.empcod,
                 ctb11m00.pstcoddig,
                 ctb11m00.corsus,
                 ctb11m00.segnumdig,
                 ctb11m00.pestip,
                 ctb11m00.cgccpfnum,
                 ctb11m00.cgcord,
                 ctb11m00.cgccpfdig,
                 ctb11m00.socpgtdoctip,
                 ctb11m00.nfsnum,
                 ctb11m00.socfatentdat,
                 ctb11m00.socfatpgtdat,
                 ctb11m00.socfatitmqtd,
                 ctb11m00.socfattotvlr,
                 ctb11m00.socfatrelqtd   without defaults

      before field socopgnum
             if operacao_aux = "i"   then
                let ctb11m00.socopgsitcod = 1
                let ctb11m00.socopgsitdes = "NAO ANALISADA"
                display by name ctb11m00.socopgsitcod
                display by name ctb11m00.socopgsitdes
             end if
             next field favtip
             display by name ctb11m00.socopgnum attribute (reverse)

      after  field socopgnum
             display by name ctb11m00.socopgnum

      before field favtip
             if operacao_aux  =  "a"   then
                if ctb11m00.socopgsitcod  >  1 then  #--> passou do protocolo
                   next field socfatpgtdat
                end if
             end if
             display by name ctb11m00.favtip   attribute (reverse)
             let ws.favtipsva = ctb11m00.favtip

      after  field favtip
             display by name ctb11m00.favtip

             if ctb11m00.favtip   is null   then
                error " Tipo do favorecido deve ser informado!"
                next field favtip
             end if

             if ws.favtipsva  is not null           and
                ws.favtipsva  <>  ctb11m00.favtip   then
                initialize ctb11m00.pstcoddig  to null
                initialize ctb11m00.nomrazsoc  to null
                initialize ctb11m00.corsus     to null
                initialize ctb11m00.cornom     to null
                initialize ctb11m00.segnumdig  to null
                initialize ctb11m00.segnom     to null
                initialize ctb11m00.soctrfcod  to null
                initialize ctb11m00.soctrfdes  to null
                initialize ctb11m00.pestip     to null
                initialize ctb11m00.cgccpfnum  to null
                initialize ctb11m00.cgcord     to null
                initialize ctb11m00.cgccpfdig  to null
                display by name ctb11m00.pstcoddig
                display by name ctb11m00.nomrazsoc
                display by name ctb11m00.corsus
                display by name ctb11m00.cornom
                display by name ctb11m00.segnumdig
                display by name ctb11m00.segnom
                display by name ctb11m00.soctrfcod
                display by name ctb11m00.soctrfdes
                display by name ctb11m00.pestip
                display by name ctb11m00.cgccpfnum
                display by name ctb11m00.cgcord
                display by name ctb11m00.cgccpfdig
             end if
             
             case ctb11m00.favtip
                  when  1  let ctb11m00.favtipdes = "PRESTADOR"
                           display by name ctb11m00.favtipdes
                           next field empcod

                  when  2  let ctb11m00.favtipdes = "CORRETOR"
                           display by name ctb11m00.favtipdes
                           next field empcod

                  when  3  let ctb11m00.favtipdes = "SEGURADO"
                           display by name ctb11m00.favtipdes
                           next field empcod

                  otherwise
                           error " Tipo de favorecido invalido!"
                           next field favtip
             end case
             
      before field empcod
             display by name ctb11m00.empcod attribute (reverse)
      
             # padrao empresa Porto
             if ctb11m00.empcod is null
                then
                let ctb11m00.empcod = 1
             end if
             
      after field empcod
             display by name ctb11m00.empcod

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field favtip
             end if
             
             if ctb11m00.empcod is not null 
                then
                call cty14g00_empresa(1, ctb11m00.empcod)
                     returning l_ret, l_msg, ctb11m00.empnom
                     
                if l_ret != 1
                   then
                   error l_msg clipped
                   let ctb11m00.empcod = null
                   next field empcod
                end if
             else
                call cty14g00_popup_empresa()
                     returning l_ret, ctb11m00.empcod, ctb11m00.empnom
                if ctb11m00.empcod is null 
                   then
                   next field empcod
                end if
             end if
             
             call cty14g00_empresa_abv(ctb11m00.empcod)
                  returning l_ret, l_msg, ctb11m00.empresa
                  
             display by name ctb11m00.empcod, ctb11m00.empnom, ctb11m00.empresa
             
             case ctb11m00.favtip
                when  3
                   if ctb11m00.empcod = 35 or ctb11m00.empcod = 84
                      then
                      initialize ctb11m00.segnumdig to null
                      display by name ctb11m00.segnumdig
                      next field pestip
                   else
                      next field segnumdig
                   end if
                when 1
                   next field pstcoddig
                when 2
                   next field corsus
                otherwise
                   error ' Favorecido não definido '
                   next field favtip
             end case
             
      before field pstcoddig
             display by name ctb11m00.pstcoddig    attribute (reverse)

      after  field pstcoddig
             display by name ctb11m00.pstcoddig

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field empcod
             end if

             if ctb11m00.pstcoddig   is null   then
                error " Informe uma das chaves para pesquisar codigo do prestador"
                call ctb12m02(ctb11m00.pstcoddig)
                     returning ctb11m00.pstcoddig,
                               ctb11m00.pestip,
                               ctb11m00.cgccpfnum,
                               ctb11m00.cgcord,
                               ctb11m00.cgccpfdig

                let ws.confirma = "s"
                next field pstcoddig
             end if

             initialize ctb11m00.soctrfdes   to null
             initialize ws.prssitcod         to null
             display by name ctb11m00.soctrfdes

             select nomrazsoc, pestip,
                    cgccpfnum, cgcord,
                    cgccpfdig, prssitcod
               into ctb11m00.nomrazsoc, ctb11m00.pestip,
                    ctb11m00.cgccpfnum, ctb11m00.cgcord,
                    ctb11m00.cgccpfdig, ws.prssitcod
               from dpaksocor
              where dpaksocor.pstcoddig = ctb11m00.pstcoddig

             if sqlca.sqlcode <> 0    then
                error " Prestador nao cadastrado!"
                next field pstcoddig
             else
                if ws.prssitcod <> "A"  then
                   case ws.prssitcod
                     when "C"  error " Prestador cancelado!"
                     when "P"  error " Prestador em proposta!"
                     when "B"  error " Prestador bloqueado!"
                   end case
                   next field pstcoddig
                end if

                #PSI208264 - Busca os dados do servico pela OP
                if  ctb11m00.socopgnum > 0 then
                    call ctc00m15_retddssrv(ctb11m00.socopgnum)
                        returning lr_ctc00m15.*,
                                  lr_erro.*
                    if  lr_erro.err <> 0 then
                        error lr_erro.msgerr clipped
                        next field pstcoddig
                    end if

                    call ctc00m15_rettrfvig(ctb11m00.pstcoddig,
                                            lr_ctc00m15.empcod,
                                            lr_ctc00m15.atdsrvorg,
                                            lr_ctc00m15.asitipcod,
                                            lr_ctc00m15.dattrfvig)
                        returning ctb11m00.soctrfcod,
                                  l_soctrfvignum,
                                  lr_erro.*
                    if  lr_erro.err <> 0 then
                        error lr_erro.msgerr clipped
                        next field pstcoddig
                    end if
                end if

                if operacao_aux  =  "i"   and
                   ws.confirma   =  "n"   then
                   error " Confirme os dados do prestador "
                   call ctb12m02(ctb11m00.pstcoddig)
                        returning ctb11m00.pstcoddig,
                                  ctb11m00.pestip,
                                  ctb11m00.cgccpfnum,
                                  ctb11m00.cgcord,
                                  ctb11m00.cgccpfdig
                end if

                if ctb11m00.pstcoddig  <  11   then
                   initialize  ctb11m00.pestip,
                               ctb11m00.cgccpfnum,
                               ctb11m00.cgcord,
                               ctb11m00.cgccpfdig   to null
                else
                   if ctb11m00.pestip     is null   or
                      ctb11m00.cgccpfnum  is null   or
                      ctb11m00.cgccpfdig  is null   then
                      error " Prestador sem CGC/CPF cadastrado ou CGC/CPF incorreto!"
                      next field pstcoddig
                   end if
                end if

                display by name ctb11m00.nomrazsoc
                display by name ctb11m00.soctrfcod
                display by name ctb11m00.pestip
                display by name ctb11m00.cgccpfnum
                display by name ctb11m00.cgcord
                display by name ctb11m00.cgccpfdig

                if ctb11m00.soctrfcod  is not null    then
                   select soctrfdes
                     into ctb11m00.soctrfdes
                     from dbsktarifasocorro
                    where soctrfcod = ctb11m00.soctrfcod
                   display by name ctb11m00.soctrfdes
                end if
             end if

             let ws.pestipcad    = ctb11m00.pestip
             let ws.cgccpfnumcad = ctb11m00.cgccpfnum
             let ws.cgccpfdigcad = ctb11m00.cgccpfdig

             next field pestip

      before field corsus
             display by name ctb11m00.corsus    attribute (reverse)

      after  field corsus
             display by name ctb11m00.corsus

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field empcod
             end if

             if ctb11m00.corsus   is null   then
                error " Susep do corretor deve ser informado!"
                next field corsus
             end if

             select cornom
               into ctb11m00.cornom
               from gcaksusep, gcakcorr
              where gcaksusep.corsus     = ctb11m00.corsus      and
                    gcakcorr.corsuspcp   = gcaksusep.corsuspcp

             if sqlca.sqlcode <> 0    then
                error " Susep nao cadastrada!"
                next field corsus
             else
                display by name ctb11m00.cornom
             end if
             next field pestip

      before field segnumdig
             display by name ctb11m00.segnumdig    attribute (reverse)

             initialize ctb11m00.segnom     to null
             initialize ctb11m00.pestip     to null
             initialize ctb11m00.cgccpfnum  to null
             initialize ctb11m00.cgcord     to null
             initialize ctb11m00.cgccpfdig  to null
             display by name ctb11m00.segnom
             display by name ctb11m00.pestip
             display by name ctb11m00.cgccpfnum
             display by name ctb11m00.cgcord
             display by name ctb11m00.cgccpfdig
             
      after  field segnumdig
             display by name ctb11m00.segnumdig

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field empcod
             end if

             if ctb11m00.empcod is null
                then
                error ' Empresa não definida '
                next field empcod
             end if
             
             # PSI 198404 People: tratamento reembolso Azul e ISAR, cliente nao tem cadastro corporativo
             if ctb11m00.empcod = 35 or ctb11m00.empcod = 84
                then
                next field pestip
             else
                if ctb11m00.segnumdig is null
                   then
                   error " Codigo do segurado deve ser informado!"
                   next field segnumdig
                else
                   call ctd20g07_dados_cli(ctb11m00.segnumdig)
                        returning l_res, l_msg,
                                  ctb11m00.segnom,
                                  ctb11m00.cgccpfnum,
                                  ctb11m00.cgcord,
                                  ctb11m00.cgccpfdig,
                                  ctb11m00.pestip
                   
                   if l_res = 0
                      then
                      display by name ctb11m00.segnom
                      display by name ctb11m00.pestip
                      display by name ctb11m00.cgccpfnum
                      display by name ctb11m00.cgcord
                      display by name ctb11m00.cgccpfdig
                   else
                      error l_msg clipped
                      initialize ctb11m00.segnom     to null
                      initialize ctb11m00.pestip     to null
                      initialize ctb11m00.cgccpfnum  to null
                      initialize ctb11m00.cgcord     to null
                      initialize ctb11m00.cgccpfdig  to null
                      display by name ctb11m00.segnom
                      display by name ctb11m00.pestip
                      display by name ctb11m00.cgccpfnum
                      display by name ctb11m00.cgcord
                      display by name ctb11m00.cgccpfdig
                      next field segnumdig
                   end if
                end if
             end if
             
      before field pestip
             display by name ctb11m00.pestip   attribute(reverse)

      after  field pestip
             display by name ctb11m00.pestip

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                case ctb11m00.favtip
                     when  1  next field pstcoddig
                     when  2  next field corsus
                     when  3
                        if ctb11m00.empcod = 35 or ctb11m00.empcod = 84
                           then
                           next field empcod
                        else
                           next field segnumdig
                        end if
                end case
             end if

             if ctb11m00.pestip   is null   then
                error " Tipo de pessoa deve ser informado!"
                next field pestip
             end if

             if ctb11m00.pestip  <>  "F"   and
                ctb11m00.pestip  <>  "J"   then
                error " Tipo de pessoa invalido!"
                next field pestip
             end if

             if ctb11m00.pestip  =  "F"   then
                initialize ctb11m00.cgcord  to null
                display by name ctb11m00.cgcord
             end if

      before field cgccpfnum
             display by name ctb11m00.cgccpfnum   attribute(reverse)

      after  field cgccpfnum
             display by name ctb11m00.cgccpfnum

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field pestip
             end if

             if ctb11m00.cgccpfnum   is null   or
                ctb11m00.cgccpfnum   =  0      then
                error " Numero do Cgc/Cpf deve ser informado!"
                next field cgccpfnum
             end if

             if ctb11m00.pestip  =  "F"   then
                next field cgccpfdig
             end if

      before field cgcord
             display by name ctb11m00.cgcord   attribute(reverse)

      after  field cgcord
             display by name ctb11m00.cgcord

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field cgccpfnum
             end if

             if ctb11m00.cgcord   is null   or
                ctb11m00.cgcord   =  0      then
                error " Filial do Cgc/Cpf deve ser informada!"
                next field cgcord
             end if

      before field cgccpfdig
             display by name ctb11m00.cgccpfdig  attribute(reverse)

      after  field cgccpfdig
             display by name ctb11m00.cgccpfdig

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                if ctb11m00.pestip  =  "J"  then
                   next field cgcord
                else
                   next field cgccpfnum
                end if
             end if

             if ctb11m00.cgccpfdig   is null
                then
                error " Digito do Cgc/Cpf deve ser informado!"
                next field cgccpfdig
             end if

             if ctb11m00.pestip  =  "J"
                then
                call F_FUNDIGIT_DIGITOCGC(ctb11m00.cgccpfnum, ctb11m00.cgcord)
                     returning ws.cgccpfdig
             else
                call F_FUNDIGIT_DIGITOCPF(ctb11m00.cgccpfnum)
                     returning ws.cgccpfdig
             end if

             if ws.cgccpfdig is null or
                ctb11m00.cgccpfdig <> ws.cgccpfdig 
                then
                error " Digito Cgc/Cpf incorreto!"
                next field cgccpfnum
             else
                
                case ctb11m00.empcod
                   when 35
                   	if ctb11m00.favtip = 3 then
                   	   let l_res = 0   
                           let l_msg = null
                           call ctd02g01_azlapl_sel(2, ctb11m00.cgccpfnum,
                                               ctb11m00.cgcord,
                                               ctb11m00.cgccpfdig)
                                returning l_res, l_msg, ctb11m00.segnom
                            if l_res = 0 then
                               let ctb11m00.segnumdig = 35353535  # codigo generico reembolso Azul
                               display by name ctb11m00.segnom
                            else
                               error ' ', l_msg clipped
                               sleep 1
                               initialize ctb11m00.segnom, ctb11m00.segnumdig to null
                               display by name ctb11m00.segnom, ctb11m00.segnumdig
                               next field cgccpfdig
                            end if
                   	end if 
                   when	84   
                      if ctb11m00.favtip = 3 then
                         let ctb11m00.pstcoddig = 3
                         call ctb00g01_seg_itau(ctb11m00.cgccpfnum,
                                                ctb11m00.cgcord,
                                                ctb11m00.cgccpfdig)
                              returning lr_seg_ita.segnom, 
                                        lr_seg_ita.errocod,
                                        lr_seg_ita.erromsg 
                         
                         if lr_seg_ita.errocod <> 0 then
                            error lr_seg_ita.erromsg 
                            next field cgccpfnum 
                         else
                            let ctb11m00.segnumdig = 84848484  # codigo generico reembolso ISAR
                            display by name ctb11m00.segnom                                    
                         end if
                      end if  
                end case
             end if

             if ctb11m00.favtip  is not null    and
                ctb11m00.pstcoddig  >  11       then
                if ctb11m00.pestip     <>  ws.pestipcad      or
                   ctb11m00.cgccpfnum  <>  ws.cgccpfnumcad   or
                   ctb11m00.cgccpfdig  <>  ws.cgccpfdigcad   then
                   error " Cgc/Cpf diferente do cadastro!"
                   next field cgccpfdig
                end if
             end if

      before field socpgtdoctip
             display by name ctb11m00.socpgtdoctip    attribute (reverse)

      after  field socpgtdoctip
             display by name ctb11m00.socpgtdoctip

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field cgccpfdig
             end if
             
             if ctb11m00.socpgtdoctip <> 1 and
                ctb11m00.socpgtdoctip <> 2 and
                ctb11m00.socpgtdoctip <> 3 and
                ctb11m00.socpgtdoctip <> 4 then
                let ctb11m00.socpgtdoctip = 0
                display by name ctb11m00.socpgtdoctip

                error " Informe o Tipo de Docto: 1-Nota Fiscal, 2-Recibo, 3-R.P.A., 4-NF Eletronica"
                next field socpgtdoctip
             end if
             
             if ctb11m00.socpgtdoctip is null and
                ctb11m00.nfsnum is not null
                then
                error " Digite o tipo de documento "
                next field socpgtdoctip
             end if
             
             if ctb11m00.socpgtdoctip =  0  or
                ctb11m00.socpgtdoctip is null 
                then
                initialize ctb11m00.socpgtdocdes to null
                display by name ctb11m00.socpgtdoctip, ctb11m00.socpgtdocdes
                next field socfatentdat
             else
                initialize m_dominio.* to null
                
                call cty11g00_iddkdominio('socpgtdoctip', ctb11m00.socpgtdoctip)
                     returning m_dominio.*
                     
                if m_dominio.erro = 1
                   then
                   let ctb11m00.socpgtdocdes = m_dominio.cpodes clipped
                else
                   initialize ctb11m00.socpgtdocdes to null
                   error "Tipo documento fiscal: ", m_dominio.mensagem
                end if
                display by name ctb11m00.socpgtdoctip, ctb11m00.socpgtdocdes
             end if
             
      # PSI 198404 - Por enquanto a informacao so serve para a verificacao se 
      # a NF esta duplicada pois no momento do protocolo a OP nao tem itens e 
      # nao e possivel gravar o NFSNUM
      before field nfsnum
             if ctb11m00.socpgtdoctip =  0    or
                ctb11m00.socpgtdoctip is null then
                next field socfatentdat
             end if
             
             display by name ctb11m00.nfsnum    attribute (reverse)

      after  field nfsnum
             display by name ctb11m00.nfsnum

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socpgtdoctip
             end if
             
             # Retirado a pedido do PS em 22/06/2009
             # if ctb11m00.socpgtdoctip = 1 or 
             #    ctb11m00.socpgtdoctip = 4 
             #    then
             #    if ctb11m00.nfsnum =  0    or
             #       ctb11m00.nfsnum is null then
             #       error " Informe o Numero do Documento Fiscal "
             #       next field nfsnum
             #    end if
             # end if
             
             if ctb11m00.nfsnum <> 0 and
                ctb11m00.nfsnum is not null then

                if ctb11m00.socopgnum is null then
                   let ctb11m00.socopgnum = 0
                end if

                call ctb00g01_vernfs(1         #---> soctip =  1 - Porto Socorr
                                    ,ctb11m00.pestip
                                    ,ctb11m00.cgccpfnum
                                    ,ctb11m00.cgcord
                                    ,ctb11m00.cgccpfdig
                                    ,ctb11m00.socopgnum
                                    ,ctb11m00.socpgtdoctip
                                    ,ctb11m00.nfsnum)
                   returning l_ret

                if l_ret = "S" then
                   error " Documento duplicado! "
                   next field nfsnum
                end if
             end if

      before field socfatentdat
             if operacao_aux  =  "a"  then
                display by name ctb11m00.socfatentdat
                next field socfatpgtdat
             end if

             display by name ctb11m00.socfatentdat    attribute (reverse)

      after  field socfatentdat
             display by name ctb11m00.socfatentdat

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then

                if ctb11m00.socpgtdoctip =  0    or
                   ctb11m00.socpgtdoctip is null then
                   next field cgccpfdig
                else
                   next field cgccpfdig
                end if
             end if

             if ctb11m00.socfatentdat   is null    then
                error " Data de entrega deve ser informada!"
                next field socfatentdat
             end if

             if ctb11m00.socfatentdat  >  today   then
                error " Data de entrega nao deve ser maior que data atual!"
                next field socfatentdat
             end if

             if ctb11m00.socfatentdat  <  today - 2 units day   then
                error " Data entrega nao deve ser anterior a 3 dias!"
                next field socfatentdat
             end if

             let ws.diasem = weekday(ctb11m00.socfatentdat)
             if ws.diasem  =  0    or
                ws.diasem  =  6    then
                error " Data de entrega nao deve ser sabado ou domingo!"
                next field socfatentdat
             end if

             initialize  ws.socopgnum   to null

             if operacao_aux  =  "i"   then
                if ctb11m00.favtip    = 1   and
                   ctb11m00.pstcoddig > 11  then
                   declare  c_ctb11m00ent  cursor for
                      select socopgnum
                        from dbsmopg
                       where socfatentdat = ctb11m00.socfatentdat    and
                             pstcoddig    = ctb11m00.pstcoddig

                   foreach  c_ctb11m00ent  into  ws.socopgnum
                      exit foreach
                   end foreach

                   if ws.socopgnum  is not null   and
                      g_issk.acsnivcod  <  6      then
                      error " Ja' existe O.P. com mesmo prestador/data entrega!"
                      next field socfatentdat
                   end if
                end if
             end if

      before field socfatpgtdat
             display by name ctb11m00.socfatpgtdat    attribute (reverse)

      after  field socfatpgtdat
             display by name ctb11m00.socfatpgtdat

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                if operacao_aux  =  "a"   then
                   if ctb11m00.socopgsitcod  >  1   then
                      error " Data entrega/favorecido nao deve ser alterado!"
                      next field socfatpgtdat
                   else
                      next field cgccpfdig
                   end if
                end if
                next field socfatentdat
             end if

             call ctb01g00(operacao_aux, ctb11m00.favtip,
                           ctb11m00.pstcoddig, ctb11m00.socfatpgtdat)
                  returning l_res, l_msg

             if l_res = 2 then
                if l_msg is not null then
                   error l_msg
                end if
                next field socfatpgtdat
             end if

      before field socfatitmqtd
             display by name ctb11m00.socfatitmqtd    attribute (reverse)

      after  field socfatitmqtd
             display by name ctb11m00.socfatitmqtd

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socfatpgtdat
             end if

             if ctb11m00.socfatitmqtd   is null    or
                ctb11m00.socfatitmqtd   =  0       then
                error " Quantidade total de servicos deve ser informada!"
                next field socfatitmqtd
             end if

             #--------------------------------------------------------------
             # O.P. de reembolso pode ser informado no maximo dois servicos
             #--------------------------------------------------------------
             if ctb11m00.segnumdig  is not null   or
                ctb11m00.corsus     is not null   then
                if ctb11m00.socfatitmqtd  >  2   then
                   error " O.P. de reembolso deve conter no maximo 2 servicos!"
                   next field socfatitmqtd
                end if
             end if

      before field socfattotvlr
             display by name ctb11m00.socfattotvlr    attribute (reverse)

      after  field socfattotvlr
             display by name ctb11m00.socfattotvlr

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socfatitmqtd
             end if

             if ctb11m00.socfattotvlr   is null    or
                ctb11m00.socfattotvlr   =  0       then
                error " Valor total dos servicos deve ser informado!"
                next field socfattotvlr
             end if

             if operacao_aux = "a"  then
                initialize ws.socopgdscvlr to null

                select socopgdscvlr
                  into ws.socopgdscvlr
                  from dbsmopg
                 where socopgnum = k_ctb11m00.socopgnum

                if ws.socopgdscvlr is not null  then
                   if ws.socopgdscvlr  >=  ctb11m00.socfattotvlr   then
                      error " Valor desconto nao deve ser maior ou igual ao valor total da O.P.!"
                      next field socfattotvlr
                   end if

                   if ctb11m00.pestip   =  "F"                           and
                      ws.socopgdscvlr  >=  ctb11m00.socfattotvlr * 0.90  then
                      error " Valor desconto nao deve ser maior ou igual a 90% do valor total da O.P.!"
                      next field socfattotvlr
                   end if
                end if
             end if

      before field socfatrelqtd
             if operacao_aux  =  "a"   then
                if ctb11m00.socopgsitcod  >  1    then  #--> passou do protocolo
                   exit input
                end if
             end if
             display by name ctb11m00.socfatrelqtd    attribute (reverse)

      after  field socfatrelqtd
             display by name ctb11m00.socfatrelqtd

             if fgl_lastkey() = fgl_keyval ("up")     or
                fgl_lastkey() = fgl_keyval ("left")   then
                next field socfattotvlr
             end if

             if ctb11m00.favtip  <>  1   then
                if ctb11m00.socfatrelqtd   is not null   then
                   error " Reembolso segurado/corretor nao utiliza relacao!"
                   next field socfatrelqtd
                end if
             end if

             if ctb11m00.socfatrelqtd   =  0       then
                error " Quantidade de relacoes nao deve ser igual a zero!"
                next field socfatrelqtd
             end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      initialize ctb11m00.*  to null
      return ctb11m00.*
   end if

   return ctb11m00.*

end function  ###  input_ctb11m00

#--------------------------------------------------------------------
function remove_ctb11m00(k_ctb11m00)
#--------------------------------------------------------------------

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ws           record
          socopgfascod like dbsmopgfas.socopgfascod,
          socopgnum    like dbsmopg.socopgnum
   end record
   
     define lr_retorno record
                           retorno      smallint,      
                           mensagem     char(60),
                           socopgfascod like dbsmopgfas.socopgfascod
                       end record         

   menu "Confirma Exclusao ?"

      command "Nao" "Nao exclui o protocolo"
              clear form
              initialize ctb11m00.*   to null
              initialize k_ctb11m00.* to null
              error " Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui protocolo"
              call ler_ctb11m00(k_ctb11m00.*) returning ctb11m00.*

              if sqlca.sqlcode = notfound  then
                 initialize ctb11m00.*   to null
                 initialize k_ctb11m00.* to null
                 error " Protocolo nao localizado!"
              else

                 #----------------------------------------------------
                 # Verifica fase da O.P.
                 #----------------------------------------------------
                 initialize ws.socopgfascod  to null

                 # PSI 221074 - BURINI
                 call cts50g00_sel_max_etapa(k_ctb11m00.socopgnum)
                      returning lr_retorno.retorno,     
                                lr_retorno.mensagem,    
                                ws.socopgfascod
                 
                 if ws.socopgfascod  <>  01   then
                    error " O.P. nao esta na fase de protocolo, portanto nao deve ser removida!"
                    exit menu
                 end if

                 #----------------------------------------------------
                 # Verifica itens da O.P.
                 #----------------------------------------------------
                 declare c_ctb11m00itm  cursor for
                    select socopgnum
                      into ws.socopgnum
                      from dbsmopgitm
                     where socopgnum = k_ctb11m00.socopgnum

                 initialize ws.socopgnum   to null
                 foreach  c_ctb11m00itm  into  ws.socopgnum
                    exit foreach
                 end foreach

                 if ws.socopgnum  is not null   then
                    error " O.P. possui itens digitados, portanto nao deve ser removida!"
                    exit menu
                 end if

                 #------------------------------------------------------
                 # Verifica custos da O.P.
                 #------------------------------------------------------
                 declare c_ctb11m00cst  cursor for
                    select socopgnum
                      into ws.socopgnum
                      from dbsmopgcst
                     where socopgnum = k_ctb11m00.socopgnum

                 initialize ws.socopgnum   to null
                 foreach  c_ctb11m00cst  into  ws.socopgnum
                    exit foreach
                 end foreach

                 if ws.socopgnum  is not null   then
                    error " O.P. possui custos digitados, portanto nao deve ser removida!"
                    exit menu
                 end if

                 #-------------------------------------------------------
                 # Verifica favorecido da O.P.
                 #-------------------------------------------------------
                 declare c_ctb11m00fav  cursor for
                    select socopgnum
                      into ws.socopgnum
                      from dbsmopgfav
                     where socopgnum = k_ctb11m00.socopgnum

                 initialize ws.socopgnum   to null
                 foreach  c_ctb11m00fav  into  ws.socopgnum
                    exit foreach
                 end foreach

                 if ws.socopgnum  is not null   then
                    error " O.P. possui favorecido, portanto nao deve ser removida!"
                    exit menu
                 end if

                 begin work
                    delete from dbsmopg
                     where dbsmopg.socopgnum = k_ctb11m00.socopgnum

                    # PSI 221074 - BURINI
                    call cts50g00_delete_etapa(k_ctb11m00.socopgnum)
                         returning lr_retorno.retorno,     
                                   lr_retorno.mensagem

                    delete from dbsmopgobs
                     where dbsmopgobs.socopgnum = k_ctb11m00.socopgnum
                 commit work

                 if sqlca.sqlcode <> 0   then
                    initialize ctb11m00.*   to null
                    initialize k_ctb11m00.* to null
                    error " Erro (",sqlca.sqlcode,") na exlusao do protocolo!"
                 else
                    initialize ctb11m00.*   to null
                    initialize k_ctb11m00.* to null
                    error   " Protocolo excluido!"
                    message ""
                    clear form
                 end if
              end if

              exit menu
   end menu

   return k_ctb11m00.*

end function  ###  remove_ctb11m00

#---------------------------------------------------------
function ler_ctb11m00(k_ctb11m00)
#---------------------------------------------------------

   define ctb11m00     record
          socopgnum    like dbsmopg.socopgnum,
          socopgsitcod like dbsmopg.socopgsitcod,
          socopgsitdes char (30),
          empresa      char (5),         #PSI 205206
          favtip       smallint,
          favtipcab    char (14),
          favtipcod    char (08),
          favtipnom    char (40),
          favtipdes    char (12),
          soctrfcod    like dbsmopg.soctrfcod,
          soctrfdes    like dbsktarifasocorro.soctrfdes,
          pstcoddig    like dbsmopg.pstcoddig,
          nomrazsoc    like dpaksocor.nomrazsoc,
          corsus       like gcaksusep.corsus,
          cornom       like gcakcorr.cornom,
          segnumdig    like gsakseg.segnumdig,
          segnom       like gsakseg.segnom,
          pestip       like dbsmopg.pestip,
          cgccpfnum    like dbsmopg.cgccpfnum,
          cgcord       like dbsmopg.cgcord,
          cgccpfdig    like dbsmopg.cgccpfdig,
          socpgtdoctip like dbsmopg.socpgtdoctip,
          socpgtdocdes char(15),
          nfsnum       like dbsmopgitm.nfsnum,
          socfatentdat like dbsmopg.socfatentdat,
          socfatpgtdat like dbsmopg.socfatpgtdat,
          socfatitmqtd like dbsmopg.socfatitmqtd,
          socfattotvlr like dbsmopg.socfattotvlr,
          socfatrelqtd like dbsmopg.socfatrelqtd,
          linhamsg     char (70),
          empcod       like dbsmopg.empcod,
          empnom       like gabkemp.empnom
   end record

   define k_ctb11m00   record
          socopgnum    like dbsmopg.socopgnum
   end record

   define ws           record
          funmat       like isskfunc.funmat,
          funnom       like isskfunc.funnom,
          socopgfasdat like dbsmopgfas.socopgfasdat,
          soctip       like dbsmopg.soctip,
          socopgfashor like dbsmopgfas.socopgfashor,
          desconto     decimal(15,2),
          dscvlr      like dbsmopg.socopgdscvlr
   end record

   define l_ciaempcod   like datmservico.ciaempcod,      #PSI 205206
          l_ciaempcodOP like datmservico.ciaempcod,
          l_ret         smallint,
          l_mensagem    char(50),
          l_nfsnum      like dbsmopgitm.nfsnum

   define lr_ctc00m15 record
       empcod       like dparpstsrvprc.empcod,
       atdsrvorg    like dparpstsrvprc.atdsrvorg,
       asitipcod    like dparpstsrvprc.asitipcod,
       dattrfvig    date
   end record

   define lr_erro record
        err     smallint,
        msgerr  char(100)
   end record

   define l_fav record
          errcod     smallint ,
          msg        char(80)
   end record
   
   define l_soctrfvignum    like dbsmvigtrfsocorro.soctrfvignum

   initialize ctb11m00.*   to null
   initialize ws.*         to null
   initialize l_fav.*      to null
   
   initialize l_ciaempcod, l_ciaempcodOP, l_ret, l_mensagem, l_nfsnum to null

   select socopgnum,
          socopgsitcod,
          pstcoddig,
          corsus,
          segnumdig,
          pestip,
          cgccpfnum,
          cgcord,
          cgccpfdig,
          socfatentdat,
          socfatpgtdat,
          socfatitmqtd,
          socfattotvlr,
          socfatrelqtd,
          soctip,
          socpgtdoctip,
          empcod,
          favtip,
          nfsnum
     into ctb11m00.socopgnum,
          ctb11m00.socopgsitcod,
          ctb11m00.pstcoddig,
          ctb11m00.corsus,
          ctb11m00.segnumdig,
          ctb11m00.pestip,
          ctb11m00.cgccpfnum,
          ctb11m00.cgcord,
          ctb11m00.cgccpfdig,
          ctb11m00.socfatentdat,
          ctb11m00.socfatpgtdat,
          ctb11m00.socfatitmqtd,
          ctb11m00.socfattotvlr,
          ctb11m00.socfatrelqtd,
          ws.soctip,
          ctb11m00.socpgtdoctip,
          ctb11m00.empcod,
          ctb11m00.favtip,
          ctb11m00.nfsnum
     from dbsmopg
    where socopgnum = k_ctb11m00.socopgnum

   if sqlca.sqlcode = notfound   then
      error " Protocolo nao cadastrado!"
      initialize ctb11m00.*    to null
      initialize k_ctb11m00.*  to null
      return ctb11m00.*
   end if

#   select sum(dscvlr)
#   into ws.desconto
#   from dbsropgdsc
#   where socopgnum = k_ctb11m00.socopgnum

#   if sqlca.sqlcode = 0 then
#   	if ws.desconto is not null and ws.desconto > 0.00 then
#   		let ctb11m00.socfattotvlr = ctb11m00.socfattotvlr - ws.desconto
#   	else
#   		select socopgdscvlr into ws.dscvlr
#   		from dbsmopg
#   		where socopgnum = k_ctb11m00.socopgnum

#   		if ws.dscvlr is not null then
#   			let ctb11m00.socfattotvlr = ctb11m00.socfattotvlr - ws.dscvlr
#   		end if
#   	end if
#   end if

   if ws.soctip <> 1   then
      error " Este numero de protocolo nao pertence ao Porto Socorro!"
      sleep 4
      initialize ctb11m00.*    to null
      initialize k_ctb11m00.*  to null
      return ctb11m00.*
   end if
   
   #PSI 205206
   #verificar qual a empresa dos itens da OP - caso exista
   declare cctb11m00001 cursor for
      select b.ciaempcod, a.nfsnum
         from dbsmopgitm a, outer datmservico b
         where a.socopgnum = k_ctb11m00.socopgnum
           and a.atdsrvnum = b.atdsrvnum
           and a.atdsrvano = b.atdsrvano
           
   foreach cctb11m00001 into l_ciaempcod, l_nfsnum
       #se empresa da OP é nula
       if l_ciaempcodOP is null 
          then
          #empresa da OP recebe empresa do item
          let l_ciaempcodOP = l_ciaempcod
          
          #busca descricao da empresa
          # call cty14g00_empresa(1, l_ciaempcodOP)
          #      returning l_ret,
          #                l_mensagem,
          #                ctb11m00.empresa
          
       else
          #verificar se empresa da OP e empresa do item são iguais
          if l_ciaempcodOP <> l_ciaempcod then
             error "Itens da OP com empresas diferentes!"
          end if
       end if
   end foreach
   
   # atribuir numero da NFS do item
   if ctb11m00.nfsnum is null and l_nfsnum is not null
      then
      let ctb11m00.nfsnum = l_nfsnum
   end if
   
   # busca descricao da empresa, se nao houver itens mostra N/D
   call cty14g00_empresa_abv(ctb11m00.empcod)
        returning l_ret, l_mensagem, ctb11m00.empresa

   call cty14g00_empresa(1, ctb11m00.empcod)
        returning l_ret, l_mensagem, ctb11m00.empnom
        
   # buscar dados do favorecido conforme tipo
   call ctb00g01_dados_favtip(3, ctb11m00.pstcoddig, ctb11m00.segnumdig,
                              '', '', ctb11m00.corsus,
                              ctb11m00.empcod,
                              ctb11m00.cgccpfnum,
                              ctb11m00.cgcord,
                              ctb11m00.cgccpfdig,
                              ctb11m00.favtip)
                    returning l_fav.errcod,
                              l_fav.msg,
                              ctb11m00.favtip,
                              ctb11m00.favtipcod,
                              ctb11m00.favtipcab,
                              ctb11m00.favtipnom,
                              ctb11m00.favtipdes  
   
   if l_fav.errcod != 0
      then
      error l_fav.msg
      sleep 1
      initialize ctb11m00.*    to null
      initialize k_ctb11m00.*  to null
      return ctb11m00.*
   else
      case ctb11m00.favtip
         when 1
            let ctb11m00.nomrazsoc = ctb11m00.favtipnom
         when 2
            let ctb11m00.cornom = ctb11m00.favtipnom 
         when 3
            let ctb11m00.segnom = ctb11m00.favtipnom
      end case
   end if
   
   if ctb11m00.favtip = 1
      then
      #PSI208264 - Busca data do atendimento do servico e
      #com a data busca a tarifa vigente
      if  ctb11m00.socopgnum > 0 then
          call ctc00m15_retddssrv(ctb11m00.socopgnum)
              returning lr_ctc00m15.*, lr_erro.*
          if  lr_erro.err <> 0 then
              error lr_erro.msgerr clipped
          end if

          call ctc00m15_rettrfvig(ctb11m00.pstcoddig,
                                  lr_ctc00m15.empcod,
                                  lr_ctc00m15.atdsrvorg,
                                  lr_ctc00m15.asitipcod,
                                  ctb11m00.socfatentdat)
              returning ctb11m00.soctrfcod,
                        l_soctrfvignum,
                        lr_erro.*
          if  lr_erro.err <> 0 then
              error lr_erro.msgerr clipped
          end if
      end if

      if ctb11m00.soctrfcod  is not null   then
         select soctrfdes
           into ctb11m00.soctrfdes
           from dbsktarifasocorro
          where soctrfcod = ctb11m00.soctrfcod
      end if
   end if
   
   initialize m_dominio.* to null
   
   call cty11g00_iddkdominio('socopgsitcod', ctb11m00.socopgsitcod)
        returning m_dominio.*
        
   if m_dominio.erro = 1
      then
      let ctb11m00.socopgsitdes = m_dominio.cpodes clipped
   else
      error " Erro (",sqlca.sqlcode,") na leitura da situação!"
      initialize ctb11m00.*    to null
      initialize k_ctb11m00.*  to null
      return ctb11m00.*
   end if
   
   #-----------------------------------------------------------------
   # Monta data de protocolo
   #-----------------------------------------------------------------
   select socopgfasdat, socopgfashor, funmat
     into ws.socopgfasdat, ws.socopgfashor, ws.funmat
     from dbsmopgfas
    where socopgnum    = k_ctb11m00.socopgnum    and
          socopgfascod = 01

   if sqlca.sqlcode <> 0    then
      error " Erro (",sqlca.sqlcode,") na leitura do codigo da fase!"
      initialize ctb11m00.*    to null
      initialize k_ctb11m00.*  to null
      return ctb11m00.*
   end if

   select funnom
     into ws.funnom
     from isskfunc
    where empcod = 01
      and funmat = ws.funmat

   let ctb11m00.linhamsg = "Protocolado em.: ", ws.socopgfasdat, " as ",
                           ws.socopgfashor, " por ", ws.funnom

   #----------------------------------------------------------------
   if ctb11m00.socpgtdoctip is not null and 
      ctb11m00.socpgtdoctip > 0
      then
      initialize m_dominio.* to null
      
      call cty11g00_iddkdominio('socpgtdoctip', ctb11m00.socpgtdoctip)
           returning m_dominio.*
           
      if m_dominio.erro = 1
         then
         let ctb11m00.socpgtdocdes = m_dominio.cpodes clipped
      else
         initialize ctb11m00.socpgtdocdes to null
         error "Tipo documento fiscal: ", m_dominio.mensagem
      end if
   end if
   
   return ctb11m00.*
   
end function  ###  ler_ctb11m00

