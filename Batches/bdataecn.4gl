#.............................................................................#
#                           PORTO SEGURO                                      #
#.............................................................................#
#                                                                             #
#  Modulo              : bdataecn.4gl                                         #
#  Analista Responsavel: Marcus Leite                                         #
#  PSI                 : 199516 - Gera arquivo com dados                      #
#                                 de corretores para                          #
#                                 lotus notes                                 #
#.............................................................................#
#                                                                             #
#  Desenvolvimento     : Marcus Leite                                         #
#  Data                :                                                      #
#                                                                             #
#.............................................................................#
#                     * * * A L T E R A C A O * * *                           #
#.............................................................................#
#    Data        Autor        Origem                  Alteracao               #
# ---------- ------------- ------------ --------------------------------------#
# 20/10/2011 Marcos Goes   CT-111021275 Alteracao no indice da temporaria     #
#                                       tabcor para unique evitando inclusao  #
#                                       em duplicidade, o que estava gerando  #
#                                       travamento da aplicacao por conta do  #
#                                       volume de dados na tabela.            #
#                                                                             #
#.............................................................................#

database porto

-------[record de trabalho]----------
define l_registros record
       corsus        like gcaksusep.corsus,
       cornom        like gcakcorr.cornom,
       maides        like gcakfilial.maides
end record

-------[record para uso da funcao fgckc811]----------------------------
define l_endereco    record
       endlgd        like gcakfilial.endlgd
      ,endnum        like gcakfilial.endnum
      ,endcmp        like gcakfilial.endcmp
      ,endbrr        like gcakfilial.endbrr
      ,endcid        like gcakfilial.endcid
      ,endcep        like gcakfilial.endcep
      ,endcepcmp     like gcakfilial.endcepcmp
      ,endufd        like gcakfilial.endufd
      ,dddcod        like gcakfilial.dddcod
      ,teltxt        like gcakfilial.teltxt
      ,dddfax        like gcakfilial.dddfax
      ,factxt        like gcakfilial.factxt
      ,maides        like gcakfilial.maides
      ,crrdstcod     like gcaksusep.crrdstcod
      ,crrdstnum     like gcaksusep.crrdstnum
      ,crrdstsuc     like gcaksusep.crrdstsuc
      ,status        smallint
end record

define l_contador            integer                  
define l_UltimoProcessamento char(100)       
define l_corsus              char(6)                  
define l_path                like ibpkdirlog.dirfisnom
define w_dirfisnom           like ibpkdirlog.dirfisnom

define l_remetente  char(50)   
define l_assunto    char(50)   
define l_para       char(1000) 
define l_comando    char(32766)
define l_status     smallint   
define l_retorno    char(5000)
define l_aux        char(25) 

------------------------------------------------
main
------------------------------------------------
      
   defer interrupt
   display "*********** Inicio do pgm bdataecn *************"
   call bdataecn_prepare()
   call bdataecn_run()
   display "*********** Fim do pgm bdataecn ****************"
   #let l_retorno   = "Qtde de Corretores com email = ", l_contador            
   #let l_remetente = "EmailCorr.ct24hs@correioporto"
   #let l_assunto   = "Carga email Corr x Notes - bdataecn - Data: ", l_UltimoProcessamento  
   #let l_para      = "carlos_ruiz@correioporto"     
   #let l_comando   = ' echo "', l_retorno clipped     
   #                 ,'" | send_email.sh '             
   #                 ,' -r ' ,l_remetente clipped      
   #                 ,' -a ' ,l_para      clipped      
   #                 ,' -s "',l_assunto   clipped, '" '
   #run l_comando returning l_status                 
end main

------------------------------------------------
function bdataecn_prepare()
------------------------------------------------
	define l_sql char(500)
	let l_sql  =  null
        
	--[ Criar tabela temporaria ]--
	create temp table tabcor (corsus char(06))with no log
	if sqlca.sqlcode <> 0 then
	   display "Erro criacao temp: ", sqlca.sqlcode, " - ", sqlca.sqlerrd[2]
	   exit program(1)
	end if 
        display "** Tab Temp - tabcor criada ok **"
               	                                   
	create unique index corr on tabcor (corsus)                                    
	if sqlca.sqlcode <> 0 then                                              
	   display "Erro criacao indice: ", sqlca.sqlcode, " - ", sqlca.sqlerrd[2]
	   exit program(1)                                                      
	end if                                                                  
	display "** Indice tabcor criado ok **"    
	                                           
	--[cursor principal contem os codigos que foram ]----------------
	--[ alterados somente nas tabelas relevantes    ]----------------
	let l_sql  =                               
	"select corsuspcp from gcakescfil ",       
		"where ( caddat >  ?  or atldat >  ? )   ",
	" union ",
	"select corsuspcp from gcakfilial ",
		"where ( caddat >  ?  or atldat >  ? )  ",
	" union ",
	"select corsuspcp from gcakcorr ",
		"where ( caddat >  ?  or atldat >  ? )  "
	prepare ptst_001 from l_sql
	declare ctst_001 cursor with hold for ptst_001
                
	--[cursor com todos os agregados do principal]--------------------
	let l_sql  =
	   "Select b.corsus ",
		"from tabcor a, gcaksusep b ",
		"where a.corsus = b.corsuspcp "
	prepare ptst_0011 from l_sql
	declare ctst_0011 cursor with hold for ptst_0011
                        
	--[cursor com o nome do corretor]--------------------------------
	let l_sql  =
	   "Select c.corsus, b.cornom ",
		      "from tabcor a, gcakcorr b, gcaksusep c ",
		      "where a.corsus = c.corsuspcp and c.corsuspcp = b.corsuspcp "
	prepare ptst_002 from l_sql
	declare ctst_002 cursor with hold for ptst_002

end function

----------------------------------------------------------------------------
function bdataecn_run()
----------------------------------------------------------------------------

   ---[inicio]-----------------------------------------------
   let l_contador            = 0
   let l_UltimoProcessamento = null
   let l_corsus              = null
   let l_remetente           = null
   let l_assunto             = null
   let l_para                = null
   let l_comando             = null
   let l_status              = null
   let l_retorno             = null
   let l_aux                 = null

   initialize l_registros.* to null
   initialize l_endereco.*  to null

   ----[localiza ultimo processamento]-----------------------------
   whenever error continue
     select relpamtxt into l_UltimoProcessamento
       from porto@u18w:Igbmparam
      where relsgl = "ECN"
   whenever error stop

   if sqlca.sqlcode = 100 then
      insert into porto@u18w:Igbmparam values ("ECN",0,0, "01/01/1900" )
      let l_UltimoProcessamento = "01/01/1900"
      display "** Gerando controle de data para processamento - ", l_UltimoProcessamento
   else
      if sqlca.sqlcode <> 0 then
         display "Erro acesso igbmparam: ", sqlca.sqlcode, " - ", sqlca.sqlerrd[2]
         exit program(1)
      end if
   end if
 
   # corrigido a busca pela igbmparam da u18w                             
   # foi incluso a funcao abre banco - 30/10/08
   if l_UltimoProcessamento = "17/10/2008" then # data na igbm da u01
      let l_UltimoProcessamento = "30/10/2008"
   end if

   let l_aux = current
   display "** Inicio da Pesquisa das suseps com a data = ", 
               l_UltimoProcessamento clipped," ",l_aux clipped
    
   ---[abre cursor principal usando a data do ultimo processamento]--
   open ctst_001 using l_UltimoProcessamento,
                       l_UltimoProcessamento,
   		       l_UltimoProcessamento,
     		       l_UltimoProcessamento,
   		       l_UltimoProcessamento,
   		       l_UltimoProcessamento


   ----[insere emails na tabela temporaria]----------------------
   whenever error continue
      let l_aux = current
      display "** Grava suseps na temp. tabcor cursor ctst_001 - ", l_aux clipped
      foreach ctst_001 into l_corsus
        insert into tabcor(corsus) values ( l_corsus )
             
        if sqlca.sqlcode <> -239 and 
           sqlca.sqlcode <> 239 and 
           sqlca.sqlcode <> -268 and 
           sqlca.sqlcode <> 268 and 
           sqlca.sqlcode <> 0 then
           display "Erro insert tabcor(1): ", sqlca.sqlcode, " - ", sqlca.sqlerrd[2]
           exit program(1)
        end if
      end foreach
      
           select 1
              from tabcor
              where corsus="55424J"
           if sqlca.sqlcode = notfound then
              insert into tabcor(corsus) values ("55424J")
              display "** corretor incluso - susep 55424J **"
           end if
                  
      let l_aux = current
      display "** Fim da gravacao na temp. - ", l_aux
   whenever error stop
   
  
   ----[pesquisa agregados da susep principal]---------------------
   whenever error continue
      let l_aux = current
      display "** Grava agregados na temp. tabcor cursor ctst_0011 - ", l_aux
      foreach ctst_0011 into l_corsus
        #display "** cursor ctst_0011 - susep = ", l_corsus
        insert into tabcor(corsus) values ( l_corsus )
        
        if sqlca.sqlcode <> -239 and 
           sqlca.sqlcode <> 239 and 
           sqlca.sqlcode <> -268 and 
           sqlca.sqlcode <> 268 and 
           sqlca.sqlcode <> 0 then
           display "Erro insert tabcor(2): ", sqlca.sqlcode, " - ", sqlca.sqlerrd[2]
           exit program(1)
        end if
      end foreach
      let l_aux = current                            
      display "** Fim da gravacao na temp. - ", l_aux
   whenever error stop

   ----[localiza o diretorio de saida ]-------------------------
   call f_path("DBS", "ARQUIVO") returning w_dirfisnom
   let l_path = w_dirfisnom  clipped, "/lista_corretores.txt"

   ----[abre cursor final que executa o relatorio]--------------
   open ctst_002
   start report bdataecn_arquivo to l_path

   foreach ctst_002 into l_registros.*
     #display "** cursor ctst_002 - susep = ", l_registros.corsus
     
     call fgckc811(l_registros.corsus) returning l_endereco.*
     if l_endereco.maides <> " "   then
        output to report bdataecn_arquivo(l_registros.corsus,
     		                          l_registros.cornom, 
     		                          l_endereco.maides)
        let l_contador = l_contador + 1
     end if 
        if l_registros.corsus =  "55424J" then                      
           display "** email da susep 55424J = ",  l_endereco.maides
        end if                                                      
   end foreach

   finish report bdataecn_arquivo

   ----[Atualiza Igbmparam]-------------------------------------
   update porto@u18w:Igbmparam set relpamtxt = today where relsgl = "ECN"
    
   display "** Qtde e Corretores com email cadastrado = ",l_contador
        
end function


--------------------------------------------------------
report bdataecn_arquivo (l_corsus, l_cornom, l_maides )
---------------------------------------------------------

	define
		l_corsus like gcaksusep.corsus,
	  	l_cornom like gcakcorr.cornom,
	  	l_maides like gcakfilial.maides

   ----[arquivo de saida ]-------------------------------
	output
     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

	format
		on every row

		print l_corsus, l_cornom, l_maides

end report
